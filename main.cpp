#include <iostream>
#include <math.h>
#include <string>
#include <vector>
#include "mex.h"

#include <nix.hpp>


// *** argument helpers ***

template<typename T>
class argument_helper {
public:

    argument_helper(T **arg, size_t n) : array(arg), number(n) { }

    bool check_size(int pos, bool fatal = false) const {
        bool res = pos + 1 > number;
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

    std::string str(int pos) const {
        //make sure it is a string
        char *tmp = mxArrayToString(array[pos]);
        std::string the_string(tmp);
        mxFree(tmp);
        return the_string;
    }


    uint64_t uint64(int pos) const {
        const void *data = mxGetData(array[pos]);
        uint64_t res;
        memcpy(&res, data, sizeof(uint64_t));
        return res;
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

    void set(int pos, std::string str) {
        if (check_size(pos)) {
            return;
        }

        array[pos] = mxCreateString(str.c_str());
    }

private:
};

// *** functions ***

static void open_file(const extractor &input, infusor &output)
{
    input.require_arguments({mxCHAR_CLASS, mxCHAR_CLASS}, true);
    mexPrintf("[+] open_file\n");
    output.set(0, "test");
}


// *** ***

typedef void (*fn_t)(const extractor &input, infusor &output);

struct fendpoint {

fendpoint(std::string name, fn_t fn) : name(name), fn(fn) {}

    std::string name;
    fn_t fn;
};

const std::vector<fendpoint> funcs = {
        {"File::open", open_file}
};

// main entry point
void mexFunction(int            nlhs,
                 mxArray       *lhs[],
                 int            nrhs,
                 const mxArray *rhs[])
{
    extractor input(rhs, nrhs);
    infusor   output(lhs, nlhs);

    std::string cmd = input.str(0);

    mexPrintf("[F] %s\n", cmd.c_str());

    bool processed = false;
    for (const auto &fn : funcs) {
        if (fn.name == cmd) {
            fn.fn(input, output);
            processed = true;
            break;
        }
    }

    if (!processed) {
        mexErrMsgIdAndTxt("MATLAB:arg:dispatch", "Unkown command");
    }
}

