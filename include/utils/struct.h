#include "mkarray.h"
#include "mex.h"

#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"

// *** datatype converter

struct struct_builder {

	struct_builder(std::vector<size_t> dims, std::vector<const char *> f)
		: n(0), pos(0), fields(f) {
		sa = mxCreateStructArray(dims.size(), dims.data(), fields.size(), fields.data());
	}

	template<typename T>
	void set(T&& value) {
		set(pos++, std::forward<T>(value));
	}

	template<typename T>
	void set(const std::string &key, T&& value) {
		mxSetFieldByNumber(sa, n, pos++, std::forward<T>(value));
	}

	template<typename T>
	void set(const int field_idx, T&& value) {
		set(n, field_idx, std::forward<T>(value));
	}

	template<typename T>
	void set(const mwIndex struct_idx, const int field_idx, T&& value) {
		set(struct_idx, field_idx, make_mx_array(std::forward<T>(value)));
	}

	void set(const mwIndex struct_idx, const int field_idx, mxArray *value) {
		mxSetFieldByNumber(sa, struct_idx, field_idx, value);
	}

	mwIndex next() {
		pos = 0;
		return ++n;
	}

	int skip() {
		return ++pos;
	}

	mxArray *array() {
		return sa;
	}

private:
	mxArray *sa;
	mwIndex n;
	int pos;

	std::vector<const char *> fields;
};