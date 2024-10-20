//---------------------------------------------------------------
//
// File: StringUtils.cpp
//
//---------------------------------------------------------------

#include "gen/StringUtils.h"  // Our interface
#include <algorithm>          // std::equal
#include <sstream>            // For stringstream
#include <stdio.h>            // for vsnprintf

using namespace Gen;
using std::string;

const std::string StringUtils::whiteSpace(" \t\v\f\r\n");

/*-----------------------------------------------------------*//**

Returns a std::string formated with printf style arguments.

@param[in] pFmt
    The format specification.

@return
    Formatted string.
*/
std::string
StringUtils::toString(const char* pFmt, ...)
{
    va_list args;
    va_start(args, pFmt);

    char buf[1024];

    unsigned n = vsnprintf(buf, sizeof(buf), pFmt, args);
    va_end(args);

    if (n < sizeof(buf))
    {
        return std::string(buf);
    }

    va_start(args, pFmt);

    // Buffer not big enough.
    char* pBuf = new char[n + 1];
    vsnprintf(pBuf, n + 1, pFmt, args);
    va_end(args);

    std::string s(pBuf);
    delete[] pBuf;
    return s;
}

/*-----------------------------------------------------------*//**

Determine if a string starts with the given string.

@param[in] s1
    The string to operate on.

@param[in] s2
    The string to look for.

@return
    True if s1 starts with s2, otherwise false.
*/
bool
StringUtils::startsWith(const std::string& s1, const std::string& s2)
{
    if (s2.empty())
    {
        return false;
    }
    return s1.find(s2) == 0;
}

/*-----------------------------------------------------------*//**

Determine if a string starts with any of the characters in a 
given string.

@param[in] s1
    The string to operate on.

@param[in] any
    The characters to look for as a std::string.

@return
    True if s1 starts with any characters in any, otherwise false.
*/
bool
StringUtils::startsWithAnyOf(const std::string& s1, const std::string& any)
{
    return s1.find_first_not_of(any) != 0;
}

/*-----------------------------------------------------------*//**

Determine if the string ends with the given string.

@param[in] s1
    The string to operate on.

@param[in] s2
    The string to look for.

@return
    True if s1 ends with s2, otherwise false.
*/
bool
StringUtils::endsWith(const std::string& s1, const std::string& s2)
{
    string::size_type pos = s1.rfind(s2);
    return (pos + s2.length()) == s1.length();
}

/*-----------------------------------------------------------*//**

Determine if a string ends with any of the characters in a 
given string.

@param[in] s1
    The string to operate on.

@param[in] any
    The characters to look for as a std::string.

@return
    True if s1 ends with any of the characters in any, otherwise false.
*/
bool
StringUtils::endsWithAnyOf(const std::string& s1, const std::string& any)
{
    return s1.find_last_not_of(any) != s1.length() - 1;;
}

/*-----------------------------------------------------------*//**

Determine if a string contains any characters in the given string.

@param[in] s1
    The string to operate on.

@param[in] any
    The characters to look for in s.

@return
    True if s1 contains and characters in any, otherwise false.
*/
bool
StringUtils::containsAnyOf(const std::string& s1, const std::string& any)
{
    return s1.find_first_of(any) != string::npos;
}

/*-----------------------------------------------------------*//**

Removes the substring s2 from the back of string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] s2
    The substring to remove.
*/
void
StringUtils::trimEnd(std::string& s1, const std::string& s2)
{
    string::size_type endpos = s1.find_last_not_of(s2);
    s1.erase(endpos + 1);
}

/*-----------------------------------------------------------*//**

Removes the substring s2 from the front of string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] s2
    The substring to remove.
*/
void
StringUtils::trimFront(std::string& s1, const std::string& s2)
{
    string::size_type startpos = s1.find_first_not_of(s2);
    if (startpos != 0)
    {
        s1.erase(0, startpos);
    }
}

/*-----------------------------------------------------------*//**

Removes the substring s2 from the front and back of string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] s2
    The substring to remove.
*/
void
StringUtils::trim(std::string& s1, const std::string& s2)
{
    trimFront(s1, s2);
    trimEnd(s1, s2);
}

/*-----------------------------------------------------------*//**

Removes the C-style substring from the front and back of 
string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] pChars
    The C-style substring to remove.
*/
void
StringUtils::trim(std::string& s1, const char* pChars)
{
    string s2(pChars);
    trimFront(s1, s2);
    trimEnd(s1, s2);
}

/*-----------------------------------------------------------*//**

Removes the given character from the front and back of string
in-place.

@param[in,out] s1
    The string to operate on.

@param[in] c
    The character to remove.
*/
void
StringUtils::trim(std::string& s1, char c)
{
    string s2(1, c);
    trimFront(s1, s2);
    trimEnd(s1, s2);
}

/*-----------------------------------------------------------*//**

Replace all occurences of one substring with another.

@param[in,out] s1
    The string to operate on.

@param[in] substringOld
    The substring within s that needs replacing.

@param[in] substringNew
    The replacement substring.
*/
void
StringUtils::replace(std::string& s1,
                     const std::string& substringOld,
                     const std::string& substringNew)
{
    string::size_type pos;
    while ((pos = s1.find(substringOld)) != string::npos)
    {
        s1.erase(pos, substringOld.length());
        s1.insert(pos, substringNew);
    }
}

/*-----------------------------------------------------------*//**

Return the total number of occurrences of c in s1.

@param[in] s1
    The string to operate on.

@param[in] c
    The character to count.

@return
    The total number of occurrences of c in s1.
*/
int
StringUtils::countCharInString(const std::string& s1, char c)
{
    std::string::const_iterator i;
    int rv = 0;

    for (i = s1.begin(); i != s1.end(); i++)
    {
        if (*i == c)
        {
            rv++;
        }
    }

    return rv;
}

/*-----------------------------------------------------------*//**

Predicate for insensitive comparison of string objects.

@param[in] s1
    The first character to use for comparison.

@param[in] s2
    The second character to use for comparison.

@return
    True if the characters have the same case-insensitive
    content, otherwise false.
*/
bool
StringUtils::insensitivePredicate(
    const std::string::value_type &s1,
    const std::string::value_type &s2)
{
    return toupper(s1) == toupper(s2);
}

/*-----------------------------------------------------------*//**

Case insensitive comparison of two string objects.

@param[in] s1
    The first string to use for comparison.

@param[in] s2
    The second string to use for comparison.

@return
    True, if the strings have the same case-insensitive
    content, otherwise false.
*/
bool
StringUtils::insensitiveEquals(const std::string& s1, const std::string& s2)
{
    return s1.size() == s2.size() && std::equal(
        s1.begin(),
        s1.end(),
        s2.begin(),
        insensitivePredicate);
}

/*-----------------------------------------------------------*//**

Returns a new string converted to upper case.

@param[in] s1
    The string to convert.

@return
    The converted string.
*/
std::string
StringUtils::toUpper(const std::string& s1)
{
    std::string result("");
    for (char c : s1)
    { 
        result += std::toupper(c); 
    } 
    return result; 
}

/*-----------------------------------------------------------*//**

Returns a new string converted to lower case.

@param[in] s1
    The string to convert.

@return
    The converted string.
*/
std::string
StringUtils::toLower(const std::string& s1)
{
    std::string result(""); 
    for (char c : s1)
    { 
        result += std::tolower(c); 
    } 
    return result; 
}

//----------------------------------------------------------------
