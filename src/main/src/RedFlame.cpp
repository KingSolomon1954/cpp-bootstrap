//----------------------------------------------------------------
//
// File: RedFlame.cpp
//
//----------------------------------------------------------------

#include "RedFlame.h"
#include <iostream>
#include <rang.hpp>
#include "lib-gen/BuildInfo.h"
#include "lib-gen/StringUtils.h"
#include "lib-codec/EnumChannelDirection.h"
#include "CommandLine.h"
#include "Properties.h"

using namespace App;

/*-----------------------------------------------------------*//**

Constructor

@param[in] argc
    Number of items in argv array.

@param[in] argv
    Array of command line args.
*/
RedFlame::RedFlame(int argc, char* argv[])
{
    LibGen::BuildInfo bld("RedFlame");
    CommandLine cmdline(argc, argv, bld);
    std::cout << bld.fullInfo() << std::endl;
    
    ChannelDirection cd = ChannelDirection::Forward;
    std::cout << "Channel direction: " << rang::fg::yellow
              << cd << rang::fg::reset << std::endl;

    std::string x("QuestionEverything");
    std::string y = LibGen::StringUtils::toLower(x);
    Properties props;
    (void)props;
}

//----------------------------------------------------------------
