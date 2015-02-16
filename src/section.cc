#include <iostream>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

static void section_describe(const extractor &input, infusor &output)
{
	mexPrintf("[+] section_describe\n");

	nix::Section section = input.entity<nix::Section>(1);

	struct_builder sb({ 1 }, { "id", "type", "name", "definition", "position", "units", "extent", "featuresCount", "sourcesCount", "dataArrayReferenceCount" });

	//sb.set(currTag.id());

	output.set(0, sb.array());
}