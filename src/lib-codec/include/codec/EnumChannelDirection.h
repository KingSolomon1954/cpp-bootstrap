//----------------------------------------------------------------
//
// File: EnumChannelDirection.h
//
//----------------------------------------------------------------

#pragma once

#include <string>
#include <ostream>
#include <array>

/*-----------------------------------------------------------*//**

@brief Indicates forward or return channel traffic flow.

@ingroup free

*/
enum class ChannelDirection
{
    Invalid = 0,   ///< Used for conversion errors
    NotApplicable, ///< Direction doesn't apply, note this is valid
    Forward,       ///< Traffic channel flows forward
    Return         ///< Traffic channel flows return
};

namespace EnumChannelDirection
{
    ChannelDirection fromString(const std::string& s);
    ChannelDirection fromUnsigned(unsigned v)                noexcept;
    std::string      toString(ChannelDirection d)            noexcept;
    bool             isConvertibleFrom(const std::string& s) noexcept;
    std::string      listAsString();

    /** Initialized array of enums for iterating. */
    constexpr const std::array<ChannelDirection, 3> enumerators
    {
        // ChannelDirection::Invalid,     // Purposefully leave out
        ChannelDirection::NotApplicable,
        ChannelDirection::Forward,
        ChannelDirection::Return
    };
}

std::ostream& operator<< (std::ostream& out, const ChannelDirection& d);

/*-----------------------------------------------------------*//**

@namespace EnumChannelDirection

@brief Functions that operate on ChannelDirection enum.

This is a small namespace holding functions that only
operate on ChannelDirection enum.

This is part of lib Codec.

*/

//-----------------------------------------------------------------
