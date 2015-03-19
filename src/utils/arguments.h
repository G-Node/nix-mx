
#ifndef NIX_MX_ARGUMENTS_H
#define NIX_MX_ARGUMENTS_H

#include "handle.h"
#include "datatypes.h"
#include "mkarray.h"
#include "nix2mx.h"
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

	void check_arg_type(size_t pos, nix::DataType dtype) const {
		check_size(pos);

		if (dtype_mex2nix(array[pos]) != dtype) {
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

    std::string str(size_t pos) const {
        return mx_array_to_str(array[pos]);
    }

    template<typename T>
    T num(size_t pos) const {
        check_arg_type(pos, nix::to_data_type<T>::value);

        if (mxGetNumberOfElements(array[pos]) < 1) {
            throw std::runtime_error("array empty");
        }

        const void *data = mxGetData(array[pos]);
        T res;
        memcpy(&res, data, sizeof(T));
        return res;
    }

    template<typename T>
    std::vector<T> vec(size_t pos) const {
        std::vector<T> res;

        T *pr;
        void *voidp = mxGetData(array[pos]);
        assert(sizeof(pr) == sizeof(voidp));
        memcpy(&pr, &voidp, sizeof(pr));

        mwSize input_size = mxGetNumberOfElements(array[pos]);
        for (mwSize index = 0; index < input_size; index++)  {
            res.push_back(*pr++);
        }

        return res;
    }

    template<>
    std::vector<std::string> vec(size_t pos) const {
        /*
        To convert to a string vector we actually expect a cell 
        array of strings. It's a logical representation since matlab 
        arrays require that elements have equal length.
        */
        std::vector<std::string> res;
        const mxArray *el_ptr;

        mwSize length = mxGetNumberOfElements(array[pos]);
        mwIndex index;

        for (index = 0; index < length; index++)  {
            el_ptr = mxGetCell(array[pos], index);

            if (!mxIsChar(el_ptr)) {
                throw std::invalid_argument("All elements of a cell array should be of a string type");
            }

            char *tmp = mxArrayToString(el_ptr);
            std::string the_string(tmp);
            res.push_back(the_string);
            mxFree(tmp);
        }

        return res;
    }

    std::vector<nix::Value> vec(size_t pos) const {
        /*
        To convert to a vector of Values we actually expect either
        - a cell array with scalar values, or
        - a cell array with structs each having Value attrs 
            (uncertainty, checksum etc.) as fields, or
        - a regular array
        */
        std::vector<nix::Value> vals;
        const mxArray *cell_element_ptr;

        if (mxGetClassID(array[pos]) == mxCELL_CLASS) {

            mwSize size = mxGetNumberOfElements(array[pos]);
            for (mwIndex index = 0; index < size; index++)  {
                cell_element_ptr = mxGetCell(array[pos], index);

                if (mxGetClassID(cell_element_ptr) == mxSTRUCT_CLASS) {
                    // assume values are given as matlab structs
                    vals.push_back(mx_array_to_value_from_struct(cell_element_ptr));
                }
                else {
                    // assume just a scalar value given
                    vals.push_back(mx_array_to_value_from_scalar(cell_element_ptr));
                }
            }
        }
        else {
            mxClassID cls = mxGetClassID(array[pos]);

            switch (cls)  {
            case mxDOUBLE_CLASS: vals = mx_array_to_value_from_array<double>(array[pos]); break;
            case mxUINT32_CLASS: vals = mx_array_to_value_from_array<uint32_t>(array[pos]); break;
            case mxINT32_CLASS:  vals = mx_array_to_value_from_array<int32_t>(array[pos]); break;
            case mxUINT64_CLASS: vals = mx_array_to_value_from_array<uint64_t>(array[pos]); break;
            case mxINT64_CLASS:  vals = mx_array_to_value_from_array<int64_t>(array[pos]); break;

            default: std::invalid_argument("This type of values is not supported");
            }
        }

        return vals;
    }

    nix::NDSize ndsize(size_t pos) const {
        return mx_array_to_ndsize(array[pos]);
    }
    
    nix::DataType dtype(size_t pos) const {
        return dtype_mex2nix(array[pos]);
    }

    nix::LinkType ltype(size_t pos) const
    {
        const uint8_t link_type = num<uint8_t>(pos);
        nix::LinkType retLinkType;

        switch (link_type) {
        case 0: retLinkType = nix::LinkType::Tagged; break;
        case 1: retLinkType = nix::LinkType::Untagged; break;
        case 2: retLinkType = nix::LinkType::Indexed; break;
        default: throw std::invalid_argument("unkown link type");
        }

        return retLinkType;
    }

	bool logical(size_t pos) const {
		check_arg_type(pos, nix::DataType::Bool);

		const mxLogical *l = mxGetLogicals(array[pos]);
		return l[0];
	}

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
