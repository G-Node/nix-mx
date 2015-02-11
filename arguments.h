
#ifndef NIX_MX_ARGUMENTS_H
#define NIX_MX_ARGUMENTS_H

#include "handle.h"
#include "datatypes.h"
#include "mkarray.h"

#include <stdexcept>

// *** argument helpers ***

template<typename T>
class argument_helper {
public:

    argument_helper(T **arg, size_t n) : array(arg), number(n) { }

    bool check_size(size_t pos, bool fatal = false) const {
        bool res = pos + 1 > number;
		if (!res && fatal) {
			throw std::out_of_range("argument position is out of bounds");
		}
        return res;
    }

    bool require_arguments(const std::vector<mxClassID> &args, bool fatal = false) const {
        bool res = true;
        if (args.size() > number) {
            res = false;
        } else {
            for (size_t i = 0; i < args.size(); i++) {
                if (mxGetClassID(array[i]) != args[i]) {
                    res = false;
                    break;
                }
            }
        }

        if (!res && fatal) {
            mexErrMsgIdAndTxt("MATLAB:args:numortype", "Wrong number or types of arguments.");
        }

        return res;
    }

	void check_arg_type(int pos, nix::DataType dtype) const {
		if (pos < 0) {
			throw std::invalid_argument("negative position");
		}

		size_t n = static_cast<size_t>(pos);
		check_size(n);

		if (dtype_mex2nix(array[n]) != dtype) {
			throw std::invalid_argument("wrong type");
		}
	}

protected:
    T **array;
    size_t number;
};

class extractor : public argument_helper<const mxArray> {
public:
    extractor(const mxArray **arr, int n) : argument_helper(arr, n) { }

    std::string str(int pos) const {
		check_arg_type(pos, nix::DataType::String);

        char *tmp = mxArrayToString(array[pos]);
        std::string the_string(tmp);
        mxFree(tmp);
        return the_string;
    }

	template<typename T>
	T num(int pos) const {
		nix::DataType dtype = nix::to_data_type<T>::value;
		check_arg_type(pos, dtype);

		const void *data = mxGetData(array[pos]);
		T res;
		memcpy(&res, data, sizeof(T));
		return res;
	}

    uint64_t uint64(int pos) const {
		return num<uint64_t>(pos);
    }

    template<typename T>
    T entity(int pos) const {
        return hdl(pos).get<T>();
    }

    handle hdl(int pos) const {
		handle h = handle(uint64(pos));
        return h;
    }

    mxClassID class_id(int pos) const {
        return mxGetClassID(array[pos]);
    }

    bool is_str(int pos) const {
        mxClassID category = class_id(pos);
        return category == mxCHAR_CLASS;
    }

private:
};


class infusor : public argument_helper<mxArray> {
public:
    infusor(mxArray **arr, int n) : argument_helper(arr, n) { }

	template<typename T>
	void set(size_t pos, T &&value) {
		mxArray *array = make_mx_array(std::forward<T>(value));
		set(pos, array);
	}

    void set(size_t pos, mxArray *arr) {
        array[pos] = arr;
    }

private:
};

#endif