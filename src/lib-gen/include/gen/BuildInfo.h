//----------------------------------------------------------------
//
// File: BuildInfo.h
//
//----------------------------------------------------------------

#pragma once

#include <string>
#include <string_view>

namespace Gen {

class BuildInfo
{
public:
    /// @name Lifecycle
    /// @{
    BuildInfo(std::string_view appName);
    BuildInfo(std::string_view appName,
              unsigned         bldMajor,
              unsigned         bldMinor,
              unsigned         bldPatch,
              unsigned         bldNumber,
              unsigned         bldEpochSecs,
              std::string_view bldDateTime,
              std::string_view bldCreator,
              std::string_view bldBranch,
              std::string_view bldCommitHash);
   ~BuildInfo();
    /// @}

    /// @name Observers
    /// @{
    std::string_view appName()    const;
    std::string_view quadlet()    const;
    std::string_view triplet()    const;
    std::string_view doublet()    const;
    std::string_view dateTime()   const;
    std::string_view creator()    const;
    std::string_view branch()     const;
    std::string_view commitHash() const;
    unsigned         major()      const;
    unsigned         minor()      const;
    unsigned         patch()      const;
    unsigned         bldnum()     const;
    unsigned         epoch()      const;
    std::string      shortInfo()  const;
    std::string      fullInfo()   const;
    /// @}

    /// @name Modifiers
    /// @{
    /// @}
    
private:
    std::string appName_;
    unsigned    major_;
    unsigned    minor_;
    unsigned    patch_;
    unsigned    bldNum_;
    unsigned    epochSecs_;
    std::string dateTime_;
    std::string creator_;
    std::string branch_;
    std::string commitHash_;
    std::string quadlet_;
    std::string triplet_;
    std::string doublet_;
};

/*-----------------------------------------------------------*//**

@class BuildInfo

@brief Captured information about a program's build.

Build information is specified at constructor time. This class makes
build information available to the program in several forms.

The calling program is responsible for obtaining and supplying
initial build information to the constructor.

*/

//----------------------------------------------------------------
    
} // namespace Gen
