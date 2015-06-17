
#ifndef NIX_MX_ARGUMENTS_H
#define NIX_MX_ARGUMENTS_H

#include "handle.h"
#include "datatypes.h"
#include "mkarray.h"
#include "mknix.h"
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

protected:
    T **array;
    size_t number;
};

class extractor : public argument_helper<const mxArray> {
public:
    extractor(const mxArray **arr, int n) : argument_helper(arr, n) { }

    // extractors

    std::string str(size_t pos) const {
        return mx_to_str(array[pos]);
    }

    template<typename T>
    T num(size_t pos) const {
        return mx_to_num<T>(array[pos]);
    }

    template<typename T>
    std::vector<T> vec(size_t pos) const {
        return mx_to_vector<T>(array[pos]);
    }

    std::vector<nix::Value> vec(size_t pos) const {
        return mx_to_values(array[pos]);
    }

    nix::NDSize ndsize(size_t pos) const {
        return mx_to_ndsize(array[pos]);
    }
    
    nix::DataType dtype(size_t pos) const {
        return dtype_mex2nix(array[pos]);
    }

    nix::LinkType ltype(size_t pos) const {
        return mx_to_linktype(array[pos]);
    }

    bool logical(size_t pos) const {
        return mx_to_bool(array[pos]);
    }

    // helpers

    template<typename T>
    T entity(size_t pos) const {
        return hdl(pos).get<T>();
    }

    handle hdl(size_t pos) const {
		handle h = handle(num<uint64_t>(pos));
        return h;
    }

    mxClassID class_id(size_t pos) const {
        return mxGetClassID(array[pos]);
    }

    bool is_str(size_t pos) const {
        mxClassID category = class_id(pos);
        return category == mxCHAR_CLASS;
    }

    double* get_raw(size_t pos) const {
        return mxGetPr(array[pos]);
    }

private:
};

template<>
inline std::vector<std::string> extractor::vec(size_t pos) const {
	return mx_to_strings(array[pos]);
}


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
