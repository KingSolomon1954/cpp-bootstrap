//----------------------------------------------------------------
//
// File: EnumChannelDirection.cpp
//
//----------------------------------------------------------------

#include "codec/EnumChannelDirection.h"
#include "gen/StringUtils.h"

using namespace EnumChannelDirection;
using namespace Gen;

constexpr const char* InvalidStr       = "Invalid";
constexpr const char* NotApplicableStr = "NotApplicable";
constexpr const char* ForwardStr       = "Forward";
constexpr const char* ReturnStr        = "Return";

/*-----------------------------------------------------------*//**

Convert enum to string.

@param[in] d
    The enum of interest.

@return
    Enum as a string.
*/
std::string
EnumChannelDirection::toString(ChannelDirection d) noexcept
{
    switch (d)
    {
        case ChannelDirection::Invalid:       return InvalidStr;
        case ChannelDirection::NotApplicable: return NotApplicableStr;
        case ChannelDirection::Forward:       return ForwardStr;
        case ChannelDirection::Return:        return ReturnStr;
    }
    return InvalidStr;
}

/*-----------------------------------------------------------*//**

Convert ChannelDirection string to enum.

@param[in] s
    The channel's direction as a string. Matches against these strings
    "Forward", "Return", or "notapplicable". Matching is
    not sensitive to case.

@return
    Enum value.

@throws std::invalid_argument
    Throws for unrecognized strings. isConvertibleFrom()
    can be used if throw is not needed.
*/
ChannelDirection
EnumChannelDirection::fromString(const std::string& s)
{
    for (auto val : enumerators)
    {
        if (StringUtils::insensitiveEquals(s, toString(val)))
        {
            return val;
        }
    }

    throw std::invalid_argument(
        "EnumChannelDirection: Conversion error: "
        "Invalid conversion to enum: " +
        s +
        ", does not match any of " +
        listAsString());
}

/*-----------------------------------------------------------*//**

Returns a std::string of the enums separated by a space.

@return
    Returns a std::string of the enums separated by a space.
*/
std::string
EnumChannelDirection::listAsString()
{
    std::string s;
    for (auto val : enumerators)
    {
        s += toString(val);
        s += " ";
    }
    StringUtils::trimEnd(s);
    return s;
}

/*-----------------------------------------------------------*//**

Determines if given string can convert to enum.

@param[in] s
    The string of interest.

@return
    True if convertible; false otherwise.
*/
bool
EnumChannelDirection::isConvertibleFrom(const std::string& s) noexcept
{
    for (auto val : enumerators)
    {
        if (StringUtils::insensitiveEquals(s, toString(val)))
        {
            return true;
        }
    }
    return false;
}

/*-----------------------------------------------------------*//**

Convert to enum from unsigned integer.

@param[in] v
    The enum as an unsigned integer.

@return
    Enum value. Returns Invalid for an unrecognized conversion.
*/
ChannelDirection
EnumChannelDirection::fromUnsigned(unsigned v) noexcept
{
    if (v == static_cast<unsigned>(ChannelDirection::Forward))
    {
        return ChannelDirection::Forward;
    }
    else if (v == static_cast<unsigned>(ChannelDirection::Return))
    {
        return ChannelDirection::Return;
    }
    else if (v == static_cast<unsigned>(ChannelDirection::NotApplicable))
    {
        return ChannelDirection::NotApplicable;
    }
    else
    {
        return ChannelDirection::Invalid;
    }
}

/*-----------------------------------------------------------*//**

Stream output operator for ::ChannelDirection.

@param[in,out] out
    The output stream.

@param[in] d
    The channel direction.

@return
    The output stream.

@ingroup free
*/
std::ostream&
operator<< (std::ostream& out, const ChannelDirection& d)
{
    out << EnumChannelDirection::toString(d);
    return out;
}

//-----------------------------------------------------------------
