//----------------------------------------------------------------
//
// File: BuildInfoTest.cpp
//
//----------------------------------------------------------------

#include "gen/BuildInfo.h"
#include <doctest/doctest.h>

using namespace Gen;
using std::string;

//----------------------------------------------------------------

TEST_CASE("Gen::BuildInfoTest: all")
{
    std::string name("C++Starter");
    BuildInfo b(name);
    CHECK(b.appName() == name);
    CHECK(!b.quadlet().empty());
    CHECK(!b.triplet().empty());
    CHECK(!b.doublet().empty());
    CHECK(!b.dateTime().empty());
    CHECK(!b.creator().empty());
    CHECK(!b.branch().empty());
    CHECK(!b.commitHash().empty());
    CHECK(!b.major() >= 0);
    CHECK(!b.minor() >= 0);
    CHECK(!b.patch() >= 0);
    CHECK(!b.bldnum() >= 0);
    CHECK(!b.shortInfo().empty());
    CHECK(!b.fullInfo().empty());
    // confirm appName and name are de-coupled
    name = "trash";
    CHECK(b.appName() == "C++Starter");
}

//----------------------------------------------------------------
