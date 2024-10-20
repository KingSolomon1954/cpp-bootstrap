//----------------------------------------------------------------
//
// File: CommandLine.h
//
//----------------------------------------------------------------

#pragma once

namespace Gen
{
    class BuildInfo;  // fwd
}

namespace App {

class CommandLine
{
public:
    /// @name Lifecycle
    /// @{
    CommandLine(int argc, char* argv[], const Gen::BuildInfo& bld);
   ~CommandLine() = default;
    /// @}

    /// @name Modifiers
    /// @{
    /// @}

    /// @name Observers
    /// @{
    /// @}
};

/*-----------------------------------------------------------*//**

@class CommandLine

@brief Process command line arguments.

Supply class description.

*/

} // namespace App

//----------------------------------------------------------------
