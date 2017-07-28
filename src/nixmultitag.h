// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_MULTITAG
#define NIX_MX_MULTITAG

#include "arguments.h"

namespace nixmultitag {

    mxArray *describe(const nix::MultiTag &multitag);

    void addReference(const extractor &input, infusor &output);

    void addReferences(const extractor &input, infusor &output);

    void addSource(const extractor &input, infusor &output);

    void addSources(const extractor &input, infusor &output);

    void createFeature(const extractor &input, infusor &output);

    void addPositions(const extractor &input, infusor &output);

    void openReferenceIdx(const extractor &input, infusor &output);

    void openFeatureIdx(const extractor &input, infusor &output);

    void openSourceIdx(const extractor &input, infusor &output);

    void compare(const extractor &input, infusor &output);

    void sourcesFiltered(const extractor &input, infusor &output);

    void referencesFiltered(const extractor &input, infusor &output);

    void featuresFiltered(const extractor &input, infusor &output);

    void retrieveDataIdx(const extractor &input, infusor &output);

    void retrieveFeatureDataIdx(const extractor &input, infusor &output);

} // namespace nixmultitag

#endif
