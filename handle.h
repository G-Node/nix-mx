#ifndef NIX_MX_HANDLE_H
#define NIX_MX_HANDLE_H

#include "mex.h"
#include <nix.hpp>

// *** nix entities holder ***

template<typename T>
struct entity_to_id { };

template<>
struct entity_to_id<nix::File> {
    static int value() { return 1; }
};

template<>
struct entity_to_id<nix::Block> {
    static int value() { return 2; }
};

template<>
struct entity_to_id<nix::DataArray> {
    static int value() { return 3; }
};

template<>
struct entity_to_id<nix::Tag> {
    static int value() { return 4; }
};

template<>
struct entity_to_id<nix::Source> {
    static int value() { return 5; }
};

template<>
struct entity_to_id<nix::Feature> {
    static int value() { return 6; }
};

template<>
struct entity_to_id<nix::MultiTag> {
    static int value() { return 7; }
};

template<>
struct entity_to_id<nix::Section> {
    static int value() { return 8; }
};



class handle {
public:

    template<typename T>
    explicit handle(const T &obj) : et(new cell<T>(obj)) {
        //every time we create a new entity cell
        //we increase the lock count by one so
        //we don't get unloaded before we have
        //destructed/destroyed all the entities
        mexLock();
    }

    explicit handle(uint64_t h) : et(reinterpret_cast<entity *>(h)) { }

    template<typename T>
    T get() const {
        if (et == nullptr) {
            throw std::runtime_error("called get on empty handle");
        }

        int eid = entity_to_id<T>::value();
        if (eid != et->id) {
            throw std::runtime_error("tried to get a entity of wrong type");
        }

        return dynamic_cast<cell<T> *>(et)->obj;
    }

    uint64_t address() const {
        return reinterpret_cast<uint64_t >(et);
    }

    void destroy() {
        et->destory();
        delete et;
        et = nullptr;
    }

private:
    struct entity {

        template<typename T>
        entity(const T &e) : id(entity_to_id<T>::value()) { }

        int id;

        virtual void destory() = 0;

        virtual ~entity() {

            //counterpart of mexLock in handle's ctor,
            // look there for more information
            mexUnlock();
            id = 0;
        }
    };

    template<typename T>
    struct cell : public entity {
        cell(const T &obj) : entity(obj), obj(obj) { }

        virtual void destory() override {
            obj = nix::none;
        }

        T obj;
    };


    entity *et;
};



#endif //NIX_MX_HANDLE_H