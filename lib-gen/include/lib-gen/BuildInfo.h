//----------------------------------------------------------------
//
// File: BuildInfo.h
//
//----------------------------------------------------------------

#pragma once

#include <string>

namespace LibGen {

class BuildInfo
{
public:
    /// @name Lifecycle
    /// @{
    BuildInfo(const std::string& appName);
    BuildInfo(const std::string& appName,
              unsigned           bldMajor,
              unsigned           bldMinor,
              unsigned           bldPatch,
              unsigned           bldNumber,
              unsigned           bldEpochSecs,
              const std::string& bldDateTime,
              const std::string& bldCreator,
              const std::string& bldBranch,
              const std::string& bldCommitHash);
   ~BuildInfo();
    /// @}

    /// @name Observers
    /// @{
    const std::string& appName()    const;
    const std::string& quadlet()    const;
    const std::string& triplet()    const;
    const std::string& doublet()    const;
    const std::string& dateTime()   const;
    const std::string& creator()    const;
    const std::string& branch()     const;
    const std::string& commitHash() const;
    unsigned           major()      const;
    unsigned           minor()      const;
    unsigned           patch()      const;
    unsigned           number()     const;
    unsigned           epoch()      const;
    std::string        shortInfo()  const;
    std::string        fullInfo()   const;
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
    
} // namespace LibGen
