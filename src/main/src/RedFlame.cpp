//----------------------------------------------------------------
//
// File: RedFlame.cpp
//
//----------------------------------------------------------------

#include "RedFlame.h"
#include <iostream>
#include "lib-gen/BuildInfo.h"
#include "lib-gen/StringUtils.h"
#include "lib-codec/EnumChannelDirection.h"
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
    (void)argc;
    (void)argv;
    ChannelDirection ld = ChannelDirection::Forward;
    (void) ld;
    std::string x("QuestionEverything");
    std::string y = LibGen::StringUtils::toLower(x);
    LibGen::BuildInfo bld("RedFlame");
    std::cout << bld.fullInfo() << std::endl;
    Properties props;
    (void)props;
}

//----------------------------------------------------------------
