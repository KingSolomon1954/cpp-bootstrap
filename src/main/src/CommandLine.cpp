//----------------------------------------------------------------
//
// File: CommandLine.cpp
//
//----------------------------------------------------------------

#include "CommandLine.h"
#include <iostream>
#include <string>
#include <cxxopts.hpp>
#include <rang.hpp>
#include "gen/BuildInfo.h"

using namespace App;

/*-----------------------------------------------------------*//**

Constructor

@param[in] argc
    Number of items in argv array.

@param[in] argv
    Array of command line args.

@param[in] bld
    Build info
*/
CommandLine::CommandLine(int argc, char* argv[],
                         const Gen::BuildInfo& bld)
{
    cxxopts::Options options("C++Bootstrap", "A brief description");

    options.add_options()
        ("f,foo", "Param foo",
         cxxopts::value<int>()->default_value("10"))
        
        ("b,bar", "Param bar",
         cxxopts::value<std::string>())
        
        ("d,debug", "Enable debugging",
         cxxopts::value<bool>()->default_value("false"))
        
        ("v,version", "Print version info then exit")
        
        ("h,help", "Print usage")
    ;

    auto result = options.parse(argc, argv);

    if (result.count("help"))
    {
        std::cout << options.help() << std::endl;
        exit(0);
    }
    if (result.count("version"))
    {
        std::cout << rang::style::bold
            << bld.shortInfo() << rang::style::reset;
        exit(0);
    }
    bool debug = result["debug"].as<bool>();
    (void)debug;
    
    int foo = result["foo"].as<int>();    
    (void)foo;
    
    std::string bar;
    if (result.count("bar"))
        bar = result["bar"].as<std::string>();
}

//----------------------------------------------------------------
