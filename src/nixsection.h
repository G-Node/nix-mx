// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_SECTION
#define NIX_MX_SECTION

#include "arguments.h"

namespace nixsection {

    mxArray *describe(const nix::Section &section);

    void createProperty(const extractor &input, infusor &output);

    void createPropertyWithValue(const extractor &input, infusor &output);

    void referringBlockSources(const extractor &input, infusor &output);

    void referringBlockTags(const extractor &input, infusor &output);

    void referringBlockMultiTags(const extractor &input, infusor &output);

    void referringBlockDataArrays(const extractor &input, infusor &output);

    void openSectionIdx(const extractor &input, infusor &output);

    void openPropertyIdx(const extractor &input, infusor &output);

    void compare(const extractor &input, infusor &output);

    void sectionsFiltered(const extractor &input, infusor &output);

    void propertiesFiltered(const extractor &input, infusor &output);

    void findSections(const extractor &input, infusor &output);

    void findRelated(const extractor &input, infusor &output);

} // namespace nixsection

#endif
