#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixgen {

    handle open_data_array(nix::DataArray inDa)
    {
        nix::DataArray da = inDa;
        handle h = handle(da);
        return h;
    }

    mxArray* list_data_arrays(std::vector<nix::DataArray> daIn)
    {
        std::vector<nix::DataArray> arr = daIn;

        struct_builder sb({ arr.size() }, { "id", "type", "name" });

        for (const auto &da : arr) {
            sb.set(da.id());
            sb.set(da.type());
            sb.set(da.name());

            sb.next();
        }
        return sb.array();
    }

    mxArray* has_entity(bool boolIn, std::vector<const char *> currLabel)
    {
        uint8_t currHas = boolIn ? 1 : 0;
        struct_builder sb({ 1 }, currLabel);
        sb.set(currHas);
        return sb.array();
    }

    mxArray* has_metadata_section(nix::Section currSection)
    {
        bool hasMetadataSection = false;
        // check if an actual, initialized section has been returned
        if (currSection != nix::none)
        {
            hasMetadataSection = true;
        }

        return nixgen::has_entity(hasMetadataSection, { "hasMetadataSection" });
    }

    mxArray* list_features(std::vector<nix::Feature> featIn)
    {
        std::vector<nix::Feature> arr = featIn;
        struct_builder sb({ arr.size() }, { "id" });
        for (const auto &da : arr) {
            sb.set(da.id());
            sb.next();
        }
        return sb.array();
    }

    mxArray* list_sources(std::vector<nix::Source> sourceIn)
    {
        std::vector<nix::Source> arr = sourceIn;
        struct_builder sb({ arr.size() }, { "id", "type", "name", "definition", "sourceCount" });
        for (const auto &da : arr) {
            sb.set(da.id());
            sb.set(da.type());
            sb.set(da.name());
            sb.set(da.definition());
            sb.set(da.sourceCount());
            sb.next();
        }
        return sb.array();
    }

    handle open_source(nix::Source sourceIn)
    {
        nix::Source currSource = sourceIn;
        handle currSourceHandle = handle(currSource);
        return currSourceHandle;
    }

    handle open_feature(nix::Feature featIn)
    {
        nix::Feature currFeat = featIn;
        handle currTagFeatHandle = handle(currFeat);
        return currTagFeatHandle;
    }

    handle open_metadata_section(nix::Section secIn)
    {
        nix::Section currMDSec = secIn;
        handle currTagMDSecHandle = handle(currMDSec);
        return currTagMDSecHandle;
    }

} // namespace nixgen