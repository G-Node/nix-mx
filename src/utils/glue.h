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

template<typename T, typename Enabled = void>
struct ex_getter{};

template<typename T>
struct ex_getter<T, typename std::enable_if<std::is_arithmetic<T>::value>::type> {
    static T get(const extractor &input, int pos) {
        return input.num<T>(static_cast<size_t>(pos + 2));
    }
};

template<typename T>
struct ex_getter<std::vector<T>> {
    static std::vector<T> get(const extractor &input, int pos) {
        return input.vec<T>(static_cast<size_t>(pos + 2));
    }
};

template<>
struct ex_getter < std::string > {
    static std::string get(const extractor &input, int pos) {
        return input.str(static_cast<size_t>(pos + 2));
    }
};

template<typename Klazz>
struct ex_getter < std::function<bool(const Klazz&)> > {
    static std::function<bool(const Klazz &)> get(const extractor &input, int pos) {
        auto fn = [](const Klazz &cls) {
            return true;
        };

        return fn;
    }
};

template<typename Klazz>
struct ex_getter < Klazz, typename std::enable_if<entity_to_id<Klazz>::is_valid>::type > {
	static Klazz get(const extractor &input, int pos) {
		return input.entity<Klazz>(pos + 2);
	}
};


// we nest to be extracted values within matryoshka structs:
//    a matryoshka struct with the value for pos N extracts that
//    value and contains a matryoshka struct within itself that
//    extracts the value for pos N-1, etc pp...

template<typename>
struct matryoshka {};

template<typename Ret, typename Klazz>
struct matryoshka<Ret(Klazz::*)()> {
    typedef void arg_type;
    typedef Ret  return_type;
    enum { n_args = 0 };
};

template<typename Ret, typename Klazz, typename T, typename... Args>
struct matryoshka < Ret(Klazz::*)(T, Args...) > {
    typedef matryoshka<Ret(Klazz::*)(Args...)> fd_type;
    typedef typename std::remove_reference<T>::type arg_value;
    typedef typename std::remove_const<arg_value>::type arg_type;
    typedef Ret return_type;

    enum { n_args = sizeof...(Args) + 1}; //+1 because we split out T

    arg_type get(const extractor &input, int pos) {
        return ex_getter<arg_type>::get(input, pos);
    }

    fd_type inner;
};


// remove constness from member function pointer
template<typename>
struct vanilla_mptr{};

template<typename Ret, typename K, typename... Args>
struct vanilla_mptr < Ret(K::*)(Args...) > {
    typedef Ret(K::*type)(Args...);
};

template<typename Ret, typename K, typename... Args>
struct vanilla_mptr < Ret(K::*)(Args...) const> {
    typedef Ret(K::*type)(Args...);
};

// for the return type resolution
template<int N, typename F>
struct matryoshka_return_type {
    typedef typename std::remove_reference<F>::type vanilla;
    typedef typename matryoshka_return_type<N - 1, typename vanilla::fd_type>::type type;
};

template<typename F>
struct matryoshka_return_type<0, F> {
    typedef typename std::remove_reference<F>::type vanilla;
    typedef typename vanilla::arg_type type;
};


// for the actual unwrapping of nested values
template<int N, typename Ret>
struct matryoshka_unwrapper {
    typedef matryoshka_unwrapper<N - 1, Ret> up;

    template<typename F>
    static Ret value(F &&f, const extractor &input, int pos) {
        //must dig deeper ...
        return up::value(f.inner, input, pos);
    }
};

template<typename Ret>
struct matryoshka_unwrapper<0, Ret> {

    template<typename F>
    static Ret value(F &&f, const extractor &input, int pos) {
        return f.get(input, pos);
    }
};

// get a value via the nested matryoshkas
template<int I, typename F>
typename matryoshka_return_type<I, F>::type
matryoshka_get(const extractor &input, F &&f) {
    typedef typename matryoshka_return_type<I, F>::type Ret;
    return matryoshka_unwrapper<I, Ret>::value(std::forward<F>(f), input, I);
}

// generate lists
template<int ...>
struct iseq { };

template<int N, int... tail>
struct cons {
    typedef typename cons<N - 1, N - 1, tail...>::type type;
};

template<int... tail>
struct cons<0, tail...> {
    typedef iseq<tail...> type;
};

// invoker abstraction

template<typename Klazz, typename Fn, typename return_type>
struct invoker{
	template<typename Args, int... I>
	static void invoke(Fn wrapped, Args &&args, const extractor &input, infusor &output, iseq<I...>) {
		Klazz entity = input.entity<Klazz>(1);
		return_type ret = (entity.*wrapped)(matryoshka_get<I>(input, std::forward<Args>(args))...);
		output.set(0, ret);
	}
};

template<typename Klazz, typename Fn>
struct invoker<Klazz, Fn, void> {
	template<typename Args, int...I>
	static void invoke(Fn wrapped, Args &&args, const extractor &input, infusor &output) {
		Klazz entity = input.entity<Klazz>(1);
		(entity.*wrapped)(matryoshka_get<I>(input, args)...);
	}
};



// the functor that wraps the member function pointer
// and extracts the arguments
template<typename Klazz, typename Fn>
struct funcbox : box {
    typedef typename vanilla_mptr<Fn>::type vanilla_fn;
    typedef matryoshka<vanilla_fn> matryoshka_t;
	typedef typename matryoshka_t::return_type fn_ret_t;

    template<typename F>
    funcbox(F &&the_function) :
            wrapped (the_function) { }

    void operator()(const extractor &input, infusor &output) {
        typedef typename cons<matryoshka_t::n_args>::type idx_type;
        //invoke(input, output, idx_type());
		invoker<Klazz, Fn, fn_ret_t>::invoke(wrapped, args, input, output, idx_type());
    }

    template<int... I>
    void invoke(const extractor &input, infusor &output, iseq<I...>) {
        Klazz entity = input.entity<Klazz>(1);
        typename matryoshka_t::return_type ret = (entity.*wrapped)(matryoshka_get<I>(input, args)...);
        output.set(0, ret);
    }

    Fn wrapped;
    matryoshka_t args;
};

template<typename Klazz>
struct getter : box {
    typedef mxArray *(*get_fun)(const Klazz &k);

    getter(get_fun f) : fun(f) { }

    void operator()(const extractor &input, infusor &output) {
        Klazz entity = input.entity<Klazz>(1);
        mxArray *res = fun(entity);
        output.set(0, res);
    }

    get_fun fun;
};


struct fntbox : box {
    typedef void(*fn_t)(const extractor &input, infusor &output);

    fntbox(fn_t f) : fun(f) { }

    void operator()(const extractor &input, infusor &output) {
        fun(input, output);
    }

private:
    fn_t fun;
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

    template<typename F>
    classdef &reg(const std::string &name, F &&f) {
        funky::box *b = new funky::funcbox<Klass, F>(f);
        lib->add(prefix + "::" + name, b);
        return *this;
    }

    classdef &desc(typename funky::getter<Klass>::get_fun fun) {
        funky::box *b = new funky::getter<Klass>(fun);
        lib->add(prefix + "::describe", b);
        return *this;
    }


private:
    std::string  prefix;
    registry    *lib;
};

}

#endif