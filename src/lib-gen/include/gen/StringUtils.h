//---------------------------------------------------------------
//
// File: StringUtils.h
//
//---------------------------------------------------------------

#pragma once

#include <string>
#include <cstdarg>  // For variable args

namespace Gen
{

class StringUtils
{
public:
    /// @name Lifecycle
    /// @{
    /// @}
    
    /// @name Modifers
    /// @{
    static std::string toUpper(const std::string& s1);
    static std::string toLower(const std::string& s1);
    
    static void trim     (std::string& s1, const std::string& s2 = StringUtils::whiteSpace);
    static void trim     (std::string& s1, const char* pChars);
    static void trim     (std::string& s1, char c);
    static void trimFront(std::string& s1, const std::string& s2 = StringUtils::whiteSpace);
    static void trimFront(std::string& s1, const char* pChars);
    static void trimFront(std::string& s1, char c);
    static void trimEnd  (std::string& s1, const std::string& s2 = StringUtils::whiteSpace);
    static void trimEnd  (std::string& s1, const char* pChars);
    static void trimEnd  (std::string& s1, char c);

    static void prepend(std::string& s1, const std::string& s2);
    static void prepend(std::string& s1, const char* pChars);
    static void prepend(std::string& s1, char c);

    static void replace(std::string& s1,
                        const std::string& oldSubstring,
                        const std::string& newSubstring);
    static void replace(std::string& s1,
                        const char* oldSubstring,
                        const char* newSubstring);
    /// @}

    /// @name Observers
    /// @{
    static std::string toString(const char* pFmt, ...);

    static bool startsWith(const std::string& s1, const std::string& s2);
    static bool startsWith(const std::string& s1, const char* pChars);
    static bool startsWith(const std::string& s1, char c);

    static bool startsWithAnyOf(const std::string& s1, const std::string& s2);
    static bool startsWithAnyOf(const std::string& s1, const char* pChars);

    static bool endsWith(const std::string& s1, const std::string& s2);
    static bool endsWith(const std::string& s1, const char* pChars);
    static bool endsWith(const std::string& s1, char c);

    static bool endsWithAnyOf(const std::string& s1, const std::string& s2);
    static bool endsWithAnyOf(const std::string& s1, const char* pChars);

    static bool containsAnyOf(const std::string& s1, const std::string& s2);
    static bool containsAnyOf(const std::string& s1, const char* pChars);

    static bool insensitiveEquals(const std::string& s1, const std::string& s2);
    static bool insensitivePredicate(const std::string::value_type &s1,
                                     const std::string::value_type &s2);
    static int  countCharInString(const std::string& s1, char c);
    /// @}
    
    static const std::string whiteSpace;  ///< these chars " \t\v\f\r\n"
};

/*-----------------------------------------------------------*//**

@class StringUtils

@brief Some useful static functions for working with std::strings.

Most of these functions change the string in-place.

*/

}  // namespace Gen

//---------------------------------------------------------------

#include "StringUtils.hpp"   // Inlines
