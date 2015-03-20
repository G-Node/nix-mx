
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

    const mxArray * cellElemPtr(size_t pos, int index) const {
        const mxArray *cell_element_ptr = mxGetCell(array[pos], index);
        return cell_element_ptr;
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
        mwSize size = mxGetNumberOfElements(array[pos]);

        mwIndex index;
        std::vector<nix::Value> vals;
        const mxArray *cell_element_ptr;

        for (index = 0; index < size; index++)  {
            cell_element_ptr = mxGetCell(array[pos], index);
            vals.push_back(mx_array_to_value(cell_element_ptr));
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

    std::vector<nix::Value> extractFromStruct(size_t pos) const {

        // Note: nix::Value is not able to its attributes "uncertainty"
        // "checksum", "filename", "encoder" or "reference" at the moment.
        // The setters are implemented and the attribute values are
        // correctly set to the nix::Value entity, but they will not
        // actually be written to the nix file. Once this issue has been
        // fixed on the nix side, the current implementation should work
        // fine.

        std::vector<nix::Value> vals;

        mwSize total_num_of_cells = mxGetNumberOfElements(array[pos]);
        for (mwIndex index = 0; index<total_num_of_cells; index++)  {
            const mxArray *cell_element_ptr = mxGetCell(array[pos], index);

            if (mxGetClassID(cell_element_ptr) == mxSTRUCT_CLASS){

                nix::Value currVal;

                mwSize total_num_of_elements = mxGetNumberOfElements(cell_element_ptr);
                int number_of_fields = mxGetNumberOfFields(cell_element_ptr);

                for (mwIndex struct_idx = 0; struct_idx < total_num_of_elements; struct_idx++)  {
                    for (int field_index = 0; field_index < number_of_fields; field_index++)  {
                        const char  *field_name = mxGetFieldNameByNumber(cell_element_ptr, field_index);
                        const mxArray *field_array_ptr = mxGetFieldByNumber(cell_element_ptr, struct_idx, field_index);

                        if (field_array_ptr != nullptr) {
                            if (strcmp(field_name, "value") == 0){
                                if (mxGetClassID(field_array_ptr) == mxDOUBLE_CLASS){
                                    double curr;
                                    const void *data = mxGetData(field_array_ptr);
                                    memcpy(&curr, data, sizeof(double));
                                    currVal.set(curr);
                                }
                                else if (mxGetClassID(field_array_ptr) == mxLOGICAL_CLASS){
                                    const mxLogical *curr = mxGetLogicals(field_array_ptr);
                                    currVal.set(curr[0]);
                                }
                                else if (mxGetClassID(field_array_ptr) == mxCHAR_CLASS){
                                    char *tmp = mxArrayToString(field_array_ptr);
                                    std::string curr_string = tmp;
                                    currVal.set(curr_string);
                                    mxFree(tmp);
                                }
                                else { mexPrintf("Unsupported value data type\n"); }

                            }
                            else if (strcmp(field_name, "uncertainty") == 0){
                                if (mxGetClassID(field_array_ptr) == mxDOUBLE_CLASS){
                                    double curr;
                                    const void *data = mxGetData(field_array_ptr);
                                    memcpy(&curr, data, sizeof(double));
                                    currVal.uncertainty = curr;
                                }
                            }
                            else if (strcmp(field_name, "checksum") == 0){
                                if (mxGetClassID(field_array_ptr) == mxCHAR_CLASS){
                                    char *tmp = mxArrayToString(field_array_ptr);
                                    std::string curr_string = tmp;
                                    currVal.checksum = curr_string;
                                    mxFree(tmp);
                                }
                            }
                            else if (strcmp(field_name, "encoder") == 0){
                                if (mxGetClassID(field_array_ptr) == mxCHAR_CLASS){
                                    char *tmp = mxArrayToString(field_array_ptr);
                                    std::string curr_string = tmp;
                                    currVal.encoder = curr_string;
                                    mxFree(tmp);
                                }
                            }
                            else if (strcmp(field_name, "filename") == 0){
                                if (mxGetClassID(field_array_ptr) == mxCHAR_CLASS){
                                    char *tmp = mxArrayToString(field_array_ptr);
                                    std::string curr_string = tmp;
                                    currVal.filename = curr_string;
                                    mxFree(tmp);
                                }
                            }
                            else if (strcmp(field_name, "reference") == 0){
                                if (mxGetClassID(field_array_ptr) == mxCHAR_CLASS){
                                    char *tmp = mxArrayToString(field_array_ptr);
                                    std::string curr_string(tmp);
                                    currVal.reference = tmp;
                                    mxFree(tmp);
                                }
                            }
                        }
                    }
                }
                vals.push_back(currVal);
            }
            else
            {
                mexWarnMsgTxt("Unsupported value wrapper data type");
            }
        }
        return vals;
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
