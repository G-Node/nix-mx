#ifndef NIX_MX_GLUE
#define NIX_MX_GLUE

#include <utils/arguments.h>
#include <map>

namespace glue {

namespace funky {

struct box {
    virtual void operator()(const extractor &input, infusor &output) = 0;
    virtual ~box() {}
};

template<typename Klass, typename Result>
struct getter : box {

    getter(Result (Klass::* func)() const) : fn(func) {}

    virtual void operator()(const extractor &input, infusor &output) override {
        Klass et = input.entity<Klass>(1);
        output.set(0, (et.*fn)());
    };

private:
    Result (Klass:: *fn)() const;
};

};

struct registry {

    bool dispatch(const std::string &name, const extractor &input, infusor &output) {

        auto it = funcs.find(name);
        if (it != funcs.end()) {
            funky::box *b = it->second;
            (*b)(input, output);
            return true;
        }

        return false;
    }

    void add(const std::string &name, funky::box *b) {
        funcs[name] = b;
    }

    ~registry() {
        for (auto &elm : funcs) {
            delete elm.second;
        }
    };

private:
    std::map<std::string, funky::box *> funcs;

};

template<typename Klass>
struct classdef {

    classdef(const std::string &name, registry *reg) : prefix(name), lib(reg) {}

    template<typename Ret>
    classdef &reg(const std::string &name, Ret (Klass::*fn)() const) {
        funky::box *b = new funky::getter<Klass, Ret>(fn);
        lib->add(prefix + "::" + name, b);
        return *this;
    }

private:
    std::string  prefix;
    registry    *lib;
};

}

#endif