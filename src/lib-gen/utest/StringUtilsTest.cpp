//----------------------------------------------------------------
//
// File: StringUtilsTest.cpp
//
//----------------------------------------------------------------

#include "gen/StringUtils.h"

#include <string.h>     // For memset()
#include <inttypes.h>   // For PRIdPTR
#include <doctest/doctest.h>

using namespace Gen;
using std::string;

//----------------------------------------------------------------

TEST_CASE("Gen::StringUtilsTest: all")
{
    const std::string src("aragorn is the king");
    
    string f = "aragorn";
    CHECK(StringUtils::startsWith(src, f));
    CHECK(StringUtils::startsWith(src, "aragorn"));
    CHECK(StringUtils::startsWith(src, 'a'));

    f = "king";
    CHECK(StringUtils::endsWith(src, f));
    CHECK(StringUtils::endsWith(src, "king"));
    CHECK(StringUtils::endsWith(src, 'g'));

    string a;
    string empty;
    CHECK(!StringUtils::startsWith(empty, a));
    CHECK(!StringUtils::startsWith(empty, "duke"));
    CHECK(!StringUtils::startsWith(empty, ""));

    a = src;
    string b("gn");
    StringUtils::trimEnd(a, b);
    CHECK(a == "aragorn is the ki");

    a = src;
    StringUtils::trimEnd(a, "gn");
    CHECK(a == "aragorn is the ki");

    a = src;
    StringUtils::trimEnd(a, 'g');
    CHECK(a == "aragorn is the kin");

    a = src;
    b = "xyz";
    StringUtils::trimEnd(a, b);
    CHECK(a == src);

    a = src;
    StringUtils::trimEnd(a, empty);
    CHECK(a == src);
    StringUtils::trimEnd(empty, a);
    CHECK(empty.empty());
    StringUtils::trimEnd(empty, empty);
    CHECK(empty.empty());

    a = src;
    b = "gra";
    StringUtils::trimFront(a, b);
    CHECK(a == "orn is the king");

    a = src;
    StringUtils::trimFront(a, "gra");
    CHECK(a == "orn is the king");

    a = src;
    StringUtils::trimFront(a, 'a');
    CHECK(a == "ragorn is the king");

    a = src;
    StringUtils::trimFront(a, "");
    CHECK(a == src);

    a = src;
    StringUtils::trimFront(a, "xyz");
    CHECK(a == src);

    a = src;
    b = "ag";
    StringUtils::trim(a, b);
    CHECK(a == "ragorn is the kin");

    a = src;
    StringUtils::trim(a, "agr");
    CHECK(a == "orn is the kin");

    a = src;
    StringUtils::trim(a, 'a');
    CHECK(a == "ragorn is the king");

    a = " 	\raragorn is the king 	\r\n";
    StringUtils::trim(a);
    CHECK(a == "aragorn is the king");

    a = "gh";
    CHECK(StringUtils::endsWithAnyOf(src, a));
    CHECK(!StringUtils::endsWithAnyOf(src, "XYZ"));

    a = "ha";
    CHECK(StringUtils::startsWithAnyOf(src, a));
    CHECK(!StringUtils::startsWithAnyOf(src, "XYZ"));

    a = "king queen king queen king";
    string oldSubstring("queen");
    string newSubstring("king");
    StringUtils::replace(a, oldSubstring, newSubstring);
    CHECK(a == "king king king king king");

    a = "king queen king queen king";
    StringUtils::replace(a, "king", "queen");
    CHECK(a == "queen queen queen queen queen");

    a = StringUtils::toString("I am number %d", 1);
    CHECK(a == "I am number 1");

    char* pCharArray = new char[2048];
    memset(pCharArray, 'A', 2048);
    pCharArray[2047] = '\0';
    string alpha("I am a number %");
    a = StringUtils::toString((alpha + PRIdPTR + " %s").c_str(), 1, pCharArray);

    CHECK(a.length() == 2047u + 16u);
    delete [] pCharArray;

    // test_out_ << "length: " << a.length() << std::endl;
}

//----------------------------------------------------------------
