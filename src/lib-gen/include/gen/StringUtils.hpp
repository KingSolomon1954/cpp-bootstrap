//---------------------------------------------------------------
//
// File: StringUtils.hpp
//
//---------------------------------------------------------------

#pragma once

namespace Gen
{

/*-----------------------------------------------------------*//**

Determine if a string starts with the given C-style string.

@param[in] s1
    The string to search.

@param[in] pChars
    The C-style string to look for.

@return
    True if s1 starts with the given string, otherwise false.
*/
inline bool
StringUtils::startsWith(const std::string& s1, const char* pChars)
{
    return startsWith(s1, std::string(pChars));
}

/*-----------------------------------------------------------*//**

Determine if a string starts with the given character.

@param[in] s1
    The string to search.

@param[in] c
    The character to look for.

@return
    True if s1 starts with the given character, otherwise false.
*/
inline bool
StringUtils::startsWith(const std::string& s1, char c)
{
    return startsWith(s1, std::string(1, c));
}

/*-----------------------------------------------------------*//**

Determine if a string starts with any of the characters in a 
given C-style string.

@param[in] s1
    The string to operator on.

@param[in] pChars
    The characters to look for as a C-style string.

@return
    True if s1 starts with any characters in pChars, otherwise false.
*/
inline bool
StringUtils::startsWithAnyOf(const std::string& s1, const char* pChars)
{
    return startsWithAnyOf(s1, std::string(pChars));
}

/*-----------------------------------------------------------*//**

Determine if the string ends with the given C-style string.

@param[in] s1
    The string to operate on.

@param[in] pChars
    The C-style string to look for.

@return
    True if s1 ends with pChar, otherwise false.
*/
inline bool
StringUtils::endsWith(const std::string& s1, const char* pChars)
{
    return endsWith(s1, std::string(pChars));
}

/*-----------------------------------------------------------*//**

Determine if the string ends with the given character.

@param[in] s1
    The string to operate on.

@param[in] c
    The character to look for.

@return
    True if s1 ends with c, otherwise false.
*/
inline bool
StringUtils::endsWith(const std::string& s1, char c)
{
    return endsWith(s1, std::string(1, c));
}

/*-----------------------------------------------------------*//**

Determine if a string ends with any of the characters in 
the given C-style string.

@param[in] s1
    The string to operate on.

@param[in] pChars
    The characters to look for as a C-style.

@return
    True if s1 ends with any of the characters in pChars, otherwise false.
*/
inline bool
StringUtils::endsWithAnyOf(const std::string& s1, const char* pChars)
{
    return endsWithAnyOf(s1, std::string(pChars));
}

/*-----------------------------------------------------------*//**

Determine if a string contains any characters in the given
C-style string.

@param[in] s1
    The string to operate on.

@param[in] pChars
    The C-style string to look for in s1.

@return
    True if s1 contains the characters in pChars, otherwise false.
*/
inline bool
StringUtils::containsAnyOf(const std::string& s1, const char* pChars)
{
    return containsAnyOf(s1, std::string(pChars));
}

/*-----------------------------------------------------------*//**

Removes the C-style string from the end of string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] pChars
    The C-style string to remove.
*/
inline void
StringUtils::trimEnd(std::string& s1, const char* pChars)
{
    trimEnd(s1, std::string(pChars));
}

/*-----------------------------------------------------------*//**

Removes the character from the end of string s1 in-place.

@param[in,out] s1
    The string to operator on.

@param[in] c
    The character to remove.
*/
inline void
StringUtils::trimEnd(std::string& s1, char c)
{
    trimEnd(s1, std::string(1, c));
}

/*-----------------------------------------------------------*//**

Removes the C-style string from the front of string s1 in-place.

@param[in,out] s1
    The string to operator on.

@param[in] pChars
    The character to remove.
*/
inline void
StringUtils::trimFront(std::string& s1, const char* pChars)
{
    trimFront(s1, std::string(pChars));
}

/*-----------------------------------------------------------*//**

Removes the character c from the front of string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] c
    The character to remove.
*/
inline void
StringUtils::trimFront(std::string& s1, char c)
{
    trimFront(s1, std::string(1, c));
}

/*-----------------------------------------------------------*//**

Prepend string s2 to s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] s2
    The string to prepend.
*/
inline void
StringUtils::prepend(std::string& s1, const std::string& s2)
{
    s1.insert(0, s2);
}

/*-----------------------------------------------------------*//**

Prepend character c to the string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] c
    The character to prepend.
*/
inline void
StringUtils::prepend(std::string& s1, char c)
{
    s1.insert(0, 1, c);
}

/*-----------------------------------------------------------*//**

Prepend C-style string to the string s1 in-place.

@param[in,out] s1
    The string to operate on.

@param[in] pChars
    The C-style string to prepend.
*/
inline void
StringUtils::prepend(std::string& s1, const char* pChars)
{
    s1.insert(0, pChars);
}

/*-----------------------------------------------------------*//**

Replace all occurences of one substring with another.

@param[in,out] s1
    The string to operate on.

@param[in] substringOld
    The C-style substring within s1 that needs replacing.

@param[in] substringNew
    The C-style replacement substring.
*/
inline void
StringUtils::replace(std::string& s1,
                     const char* substringOld,
                     const char* substringNew)
{
    replace(s1, std::string(substringOld), std::string(substringNew));
}

//---------------------------------------------------------------

}  // namespace Gen
