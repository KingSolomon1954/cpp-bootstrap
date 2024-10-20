//----------------------------------------------------------------
//
// File: EnumChannelDirectionTest.cpp
//
//----------------------------------------------------------------

#include "codec/EnumChannelDirection.h"

#include <sstream>
#include <doctest/doctest.h>

//----------------------------------------------------------------

TEST_CASE("Codec::EnumChannelDirectionTest: toString")
{
    std::string s;
    ChannelDirection val;

    val = ChannelDirection::Forward;
    s = EnumChannelDirection::toString(val);
    CHECK(s == "Forward");

    val = ChannelDirection::Return;
    s = EnumChannelDirection::toString(val);
    CHECK(s == "Return");

    val = ChannelDirection::NotApplicable;
    s = EnumChannelDirection::toString(val);
    CHECK(s == "NotApplicable");
}

//----------------------------------------------------------------

TEST_CASE("Codec::EnumChannelDirectionTest: fromString")
{
    std::string s;

    s = "forward";
    CHECK(ChannelDirection::Forward == EnumChannelDirection::fromString(s));

    s = "RETURN";
    CHECK(ChannelDirection::Return == EnumChannelDirection::fromString(s));

    s = "NotAPPLicable";
    CHECK(ChannelDirection::NotApplicable == EnumChannelDirection::fromString(s));

    CHECK_THROWS_AS((void)EnumChannelDirection::fromString("XYZ"),
                    std::invalid_argument);
}

//---------------------------------------------------------------

TEST_CASE("Codec::EnumChannelDirectionTest: isConvertibleFrom")
{
    std::string s;

    s = "forward";
    CHECK(EnumChannelDirection::isConvertibleFrom(s));

    s = "RETURN";
    CHECK(EnumChannelDirection::isConvertibleFrom(s));

    s = "NotAPPLicable";
    CHECK(EnumChannelDirection::isConvertibleFrom(s));

    s = "XYZ";
    CHECK(!EnumChannelDirection::isConvertibleFrom(s));
}

//---------------------------------------------------------------

TEST_CASE("Codec::EnumChannelDirectionTest: fromUnsigned")
{
    CHECK(ChannelDirection::NotApplicable == EnumChannelDirection::fromUnsigned(1u));
    CHECK(ChannelDirection::Forward       == EnumChannelDirection::fromUnsigned(2u));
    CHECK(ChannelDirection::Return        == EnumChannelDirection::fromUnsigned(3u));
    CHECK(ChannelDirection::Invalid       == EnumChannelDirection::fromUnsigned(99u));
}

//---------------------------------------------------------------

TEST_CASE("Codec::EnumChannelDirectionTest: listAsString")
{
    std::string s = "NotApplicable Forward Return";
    CHECK(s == EnumChannelDirection::listAsString());
}

//---------------------------------------------------------------

TEST_CASE("Codec::EnumChannelDirectionTest: ostreamOperator")
{
    ChannelDirection channelDir = ChannelDirection::Forward;

    std::stringstream ss;
    ss << channelDir;

    CHECK(ss.str() == "Forward");
}

//----------------------------------------------------------------
