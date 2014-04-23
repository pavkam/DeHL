(*
* Copyright (c) 2010, Ciobanu Alexandru
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

{$I ../DeHL.Defines.inc}
unit DeHL.Strings;
interface
uses SysUtils,
     StrUtils,
     Character,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Cloning,
     DeHL.Serialization,
     DeHL.Collections.Base,
     DeHL.WideCharSet;

type
  ///  <summary>Describes different modes in which strings are compared</summary>
  ///  <remarks>This type is mainly used by <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> in
  ///  operations that require string comparison, such as <c>IndexOf</c> or even <c>Replace</c></remarks>
  TStringComparison =
  (
    ///  <summary>The comparison is perfomed using current locale rules.</summary>
    scLocale,
    ///  <summary>The comparison is perfomed using current locale rules and is case-independant.</summary>
    scLocaleIgnoreCase,
    ///  <summary>The comparison is perfomed using Unicode rules.</summary>
    scInvariant,
    ///  <summary>The comparison is perfomed using Unicode rules and is case-independant.</summary>
    scInvariantIgnoreCase,
    ///  <summary>The comparison is perfomed using Unicode character tables.</summary>
    scOrdinal,
    ///  <summary>The comparison is perfomed using Unicode character tables and is case-independant.</summary>
    scOrdinalIgnoreCase
  );

  ///  <summary>An object-oriented immutable Unicode string type.</summary>
  TString = record
  private const
    CEmpty = '';

    { Defines the position of the first character in the string }
{$IFDEF TSTRING_ZERO_INDEXED}
    CFirstCharacterIndex = 0;
{$ELSE}
    CFirstCharacterIndex = 1;
{$ENDIF}

  private type
    { The enumerator object }
    TEnumerator = class(TEnumerator<Char>)
    private
      FString: string;
      FIndex: NativeInt;
      FCurrent: Char;
    public
      { Constructor }
      constructor Create(const AString: string);

      function GetCurrent(): Char; override;
      function MoveNext(): Boolean; override;
    end;

    TEnumerable = class(TEnexCollection<Char>)
    private
      FString: string;

    protected
      { Implement to support count of elements }
      function GetCount(): NativeUInt; override;

    public
      { The constructor }
      constructor Create(const AString: string);

      { IEnumerable<T> }
      function GetEnumerator(): IEnumerator<Char>; override;

      { Checks whether a collection is empty }
      function Empty(): Boolean; override;

      { Other Enex stuffz }
      function First(): Char; override;
      function FirstOrDefault(const ADefault: Char): Char; override;
      function Last(): Char; override;
      function LastOrDefault(const ADefault: Char): Char; override;
      function ElementAt(const Index: NativeUInt): Char; override;
      function ElementAtOrDefault(const Index: NativeUInt; const ADefault: Char): Char; override;

      { Implement to support copy }
      procedure CopyTo(var AArray: array of Char; const StartIndex: NativeUInt); override;
    end;

  private
    [CloneKind(ckReference)]
    FString: string;

    { Internal comparison and intialization }
    class function InternalCompare(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt; const LType: TStringComparison): NativeInt; static;
    class constructor Create;
    class destructor Destroy;

    { Internals }
    function GetChar(const AIndex: NativeInt): Char; inline;
    function GetLength: NativeUInt; inline;
    function GetIsEmpty: Boolean; inline;
    function GetIsWhiteSpace: Boolean;

    { ... }
    class function GetEmpty: TString; static; inline;
  public
    ///  <summary>Initializes a <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> value with a given Delphi string.</summary>
    ///  <param name="AString">The Delphi string.</param>
    constructor Create(const AString: string); overload;

    ///  <summary>Initializes a <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> value from another string value.</summary>
    ///  <param name="AString">A <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> value.</param>
    constructor Create(const AString: TString); overload;

    ///  <summary>Initializes a <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> value from a UTF-8 encoded string.</summary>
    ///  <param name="AUTF8String">A <c>RawByteString</c> value that contains UTF-8 encoded contents.</param>
    ///  <returns>A new string.</returns>
    class function FromUTF8String(const AUTF8String: RawByteString): TString; static;

    ///  <summary>Initializes a <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> value from a UTF-32 encoded string.</summary>
    ///  <param name="AUTF8String">A <c>UCS4String</c> value that contains UTF-32 encoded contents.</param>
    ///  <returns>A new string.</returns>
    class function FromUCS4String(const AUCS4String: UCS4String): TString; static;

    ///  <summary>Returns an enumerator used to traverse the contents of the string.</summary>
    ///  <returns>An <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> that can traverse this set.</returns>
    function GetEnumerator(): IEnumerator<Char>;

    ///  <summary>Returns a collection object that represents this string's characters.</summary>
    ///  <remarks>A new collection is created each time you call this method.</remarks>
    ///  <returns>An <see cref="DeHL.Collections.Base|IEnexCollection&lt;T&gt;">DeHL.Collections.Base.IEnexCollection&lt;T&gt;</see>
    ///  representing the characters in the string.</returns>
    function AsCollection(): IEnexCollection<Char>;

    ///  <summary>Returns the number of characters in the string.</summary>
    ///  <returns>The number of characters in the string.</returns>
    property Length: NativeUInt read GetLength;

    ///  <summary>Default indexed property.</summary>
    ///  <param name="AIndex">The index from which to read the character.</param>
    ///  <returns>The character at the specified index.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="Index"/> is out of bounds.</exception>
    property Chars[const AIndex: NativeInt]: Char read GetChar; default;

    ///  <summary>Checks whether the string is empty.</summary>
    ///  <returns><c>True</c> is the string is empty; <c>False</c> otherwise.</returns>
    property IsEmpty: Boolean read GetIsEmpty;

    ///  <summary>Checks whether the string is empty or is formed only from whitespaces.</summary>
    ///  <returns><c>True</c> is the string is empty or contains only whitespaces; <c>False</c> otherwise.</returns>
    ///  <remarks>Trimming a string has this property equal to <c>True</c> would result in an empty string.</remarks>
    property IsWhiteSpace: Boolean read GetIsWhiteSpace;

    ///  <summary>Converts this string to a Delphi string.</summary>
    ///  <returns>The converted Delphi string.</returns>
    function ToString(): string; inline;

    ///  <summary>Converts this string to an UTF-8 encoded string.</summary>
    ///  <returns>A <c>RawByteString</c> containing the converted value.</returns>
    function ToUTF8String(): RawByteString; inline;

    ///  <summary>Converts this string to an UTF-32 encoded string.</summary>
    ///  <returns>An <c>UCS4String</c> containing the converted value.</returns>
    function ToUCS4String(): UCS4String; inline;

    ///  <summary>Trims the string from the left.</summary>
    ///  <param name="ACharSet">A set defining the characters to trim.</param>
    ///  <returns>A new left-trimmed string.</returns>
    ///  <remarks>This method removes all characters defined by the set from the beginning of the string.</remarks>
    function TrimLeft(const ACharSet: TWideCharSet): TString; overload;

    ///  <summary>Trims the string from the left.</summary>
    ///  <returns>A new left-trimmed string.</returns>
    ///  <remarks>This method removes all Unicode whitespace characters from the beginning of the string.</remarks>
    function TrimLeft(): TString; overload;

    ///  <summary>Trims the string from the right.</summary>
    ///  <param name="ACharSet">A set defining the characters to trim.</param>
    ///  <returns>A new right-trimmed string.</returns>
    ///  <remarks>This method removes all characters defined by the set from the end of the string.</remarks>
    function TrimRight(const ACharSet: TWideCharSet): TString; overload;

    ///  <summary>Trims the string from the right.</summary>
    ///  <returns>A new right-trimmed string.</returns>
    ///  <remarks>This method removes all Unicode whitespace characters from the end of the string.</remarks>
    function TrimRight(): TString; overload;

    ///  <summary>Trims the string.</summary>
    ///  <param name="ACharSet">A set defining the characters to trim.</param>
    ///  <returns>A new trimmed string.</returns>
    ///  <remarks>This method removes all characters defined by the set from the beginning and from the end of the string.</remarks>
    function Trim(const ACharSet: TWideCharSet): TString; overload;

    ///  <summary>Trims the string.</summary>
    ///  <returns>A new trimmed string.</returns>
    ///  <remarks>This method removes Unicode whitespace characters from the beginning and from the end of the string.</remarks>
    function Trim(): TString; overload;

    ///  <summary>Inserts a given character to the beginning of the string.</summary>
    ///  <param name="ACount">The number of times that the character is inserted.</param>
    ///  <param name="AChar">The character to insert.</param>
    ///  <returns>A new left-padded string.</returns>
    ///  <remarks>This method generates a new string by inserting <paramref name="AChar"/>, <paramref name="ACount"/> times
    ///  into the beginning of the string. For example, padding <c>'John'</c> with <c>'_'</c> two times results in: <c>'__John'</c></remarks>
    function PadLeft(const ACount: NativeUInt; const AChar: Char = ' '): TString; inline;

    ///  <summary>Appends a given character to the end of the string.</summary>
    ///  <param name="ACount">The number of times that the character is appended.</param>
    ///  <param name="AChar">The character to append.</param>
    ///  <returns>A new right-padded string.</returns>
    ///  <remarks>This method generates a new string by appending <paramref name="AChar"/>, <paramref name="ACount"/> times
    ///  to the end of the string. For example, padding <c>'John'</c> with <c>'_'</c> two times results in: <c>'John__'</c></remarks>
    function PadRight(const ACount: NativeUInt; const AChar: Char = ' '): TString; inline;

    ///  <summary>Checks if a given sub-string is part of this string.</summary>
    ///  <param name="AWhat">The string to search for.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>True</c> if the string was found; <c>False</c> otherwise.</returns>
    function Contains(const AWhat: string; const ACompareOption: TStringComparison = scInvariant): Boolean; inline;

    ///  <summary>Searches for the first appearance of a given sub-string in this string.</summary>
    ///  <param name="AWhat">The string to search for.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>-1</c> if the sub-string was not found; otherwise a positive value indicating the index of the sub-string.</returns>
    function IndexOf(const AWhat: string; const ACompareOption: TStringComparison = scInvariant): NativeInt; inline;

    ///  <summary>Searches for the last appearance of a given sub-string in this string.</summary>
    ///  <param name="AWhat">The string to search for.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>-1</c> if the sub-string was not found; otherwise a positive value indicating the index of the sub-string.</returns>
    function LastIndexOf(const AWhat: string; const ACompareOption: TStringComparison = scInvariant): NativeInt; inline;

    ///  <summary>Searches for the first appearance of any of the given sub-strings in this string.</summary>
    ///  <param name="AWhat">The strings to search for.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>-1</c> if none of sub-strings were found; otherwise a positive value indicating the index of a found sub-string.</returns>
    function IndexOfAny(const AWhat: array of string; const ACompareOption: TStringComparison = scInvariant): NativeInt;

    ///  <summary>Searches for the last appearance of any of the given sub-strings in this string.</summary>
    ///  <param name="AWhat">The strings to search for.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>-1</c> if none of sub-strings were found; otherwise a positive value indicating the index of a found sub-string.</returns>
    function LastIndexOfAny(const AWhat: array of string; const ACompareOption: TStringComparison = scInvariant): NativeInt;

    ///  <summary>Checks if the string start with a given sub-string.</summary>
    ///  <param name="AWhat">The string to check for.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>True</c> if the string starts with the given sub-string; <c>False</c> otherwise.</returns>
    function StartsWith(const AWhat: string; const ACompareOption: TStringComparison = scInvariant): Boolean;

    ///  <summary>Checks if the string ends with a given sub-string.</summary>
    ///  <param name="AWhat">The string to check for.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>True</c> if the string ends with the given sub-string; <c>False</c> otherwise.</returns>
    function EndsWith(const AWhat: string; const ACompareOption: TStringComparison = scInvariant): Boolean;

    ///  <summary>Splits the string into sub-strings using a set of separator characters.</summary>
    ///  <param name="ADelimiters">A set of delimiter characters.</param>
    ///  <param name="ARemoveEmptyEntries">A boolean value indicatind whether empty sub-strings should be removed from the resulting array.</param>
    ///  <returns>An array of strings representing each split sub-string.</returns>
    ///  <remarks>This method splits the string by using the characters in the delimiters set. For example,
    ///  a string <c>'Hello World. Bye'</c>, can be split to <c>['Hello', 'World', '', 'Bye']</c> if charaters
    ///  <c>' '</c> and <c>'.'</c> are used as delimiters. If it is desired to remove the empty entries from the result array,
    ///  <paramref name="ARemoveEmptyEntries"/> should be set to <c>True</c>.</remarks>
    function Split(const ADelimiters: TWideCharSet; const ARemoveEmptyEntries: Boolean = false): TArray<TString>; overload;

    ///  <summary>Splits the string into sub-strings using a separator character.</summary>
    ///  <param name="ADelimiter">The delimiter character.</param>
    ///  <param name="ARemoveEmptyEntries">A boolean value indicatind whether empty sub-strings should be removed from the resulting array.</param>
    ///  <returns>An array of strings representing each split sub-string.</returns>
    ///  <remarks>This method splits the string by using the delimiter character. For example,
    ///  a string <c>'One.Two..Three'</c>, can be split to <c>['One', 'Two', '', 'Three']</c> if <c>'.'</c> character is used as delimiter.
    ///  If it is desired to remove the empty entries from the result array, <paramref name="ARemoveEmptyEntries"/>
    ///  should be set to <c>True</c>.</remarks>
    function Split(const ADelimiter: Char; const ARemoveEmptyEntries: Boolean = false): TArray<TString>; overload; inline;

    ///  <summary>Copies a given number of charcters to a new string.</summary>
    ///  <param name="AStart">The start index.</param>
    ///  <param name="ACount">The number of characters.</param>
    ///  <returns>A new string containing the copied characters.</returns>
    ///  <remarks>This method copies <paramref name="ACount"/> characters starting with <paramref name="AStart"/> index.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    function Substring(const AStart: NativeInt; const ACount: NativeUInt): TString; overload;

    ///  <summary>Copies a given number of charcters to a new string.</summary>
    ///  <param name="AStart">The start index.</param>
    ///  <returns>A new string containing the copied characters.</returns>
    ///  <remarks>This method copies all characters starting with <paramref name="AStart"/> index.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStart"/> is out of bounds.</exception>
    function Substring(const AStart: NativeInt): TString; overload;

    ///  <summary>Inserts a string into this string.</summary>
    ///  <param name="AIndex">The index where to insert.</param>
    ///  <param name="AWhat">The string to insert.</param>
    ///  <returns>A new string.</returns>
    ///  <returns>A new string containing the results of this opperation.</returns>
    ///  <remarks>If <paramref name="AIndex"/> is equal to the length of the this string, and append operation is issued.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function Insert(const AIndex: NativeInt; const AWhat: string): TString;

    ///  <summary>Replaces all encounters of a given character with another character.</summary>
    ///  <param name="AWhat">The character to replace.</param>
    ///  <param name="AWith">The character to replace with.</param>
    ///  <returns>A new string containing the results of this opperation.</returns>
    function Replace(const AWhat, AWith: Char): TString; overload;

    ///  <summary>Replaces all encounters of a given string with another string.</summary>
    ///  <param name="AWhat">The string to replace.</param>
    ///  <param name="AWith">The string to replace with.</param>
    ///  <param name="ACompareOption">The comparison mode used when searching for <paramref name="AWhat"/>. Default is <c>scInvariant</c>.</param>
    ///  <returns>A new string containing the results of this opperation.</returns>
    function Replace(const AWhat, AWith: string; const ACompareOption: TStringComparison = scInvariant): TString; overload; inline;

    ///  <summary>Removes a part of the string.</summary>
    ///  <param name="AStart">The starting index.</param>
    ///  <param name="ACount">The number of characters to remove.</param>
    ///  <returns>A new string containing the results of this opperation.</returns>
    ///  <remarks>This method removes <paramref name="ACount"/> characters starting with <paramref name="AStart"/> index.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    function Remove(const AStart: NativeInt; const ACount: NativeUInt): TString; overload;

    ///  <summary>Removes a part of the string.</summary>
    ///  <param name="AStart">The starting index.</param>
    ///  <returns>A new string containing the results of this opperation.</returns>
    ///  <remarks>This method removes all characters starting with <paramref name="AStart"/> index.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStart"/> is out of bounds.</exception>
    function Remove(const AStart: NativeInt): TString; overload;

    ///  <summary>Reverses the contents of the string.</summary>
    ///  <returns>A new string containing the results of this opperation.</returns>
    function Reverse(): TString; inline;

    ///  <summary>Duplicates a string for a given number of times.</summary>
    ///  <param name="ACount">The number of times to dupe. Default is <c>2</c>.</param>
    ///  <returns>A new string containing the results of this opperation.</returns>
    ///  <remarks>If <paramref name="ACount"/> is <c>0</c>, an empty string is returned; if <paramref name="ACount"/>
    ///  is <c>1</c>, the original string is returned; otherwise a new string containing the original one duplicated <paramref name="ACount"/>
    ///  times is returned.</remarks>
    function Dupe(const ACount: NativeUInt = 2): TString;

    ///  <summary>Converts the string to upper case.</summary>
    ///  <returns>A new upper case string.</returns>
    function ToUpper(): TString;

    ///  <summary>Converts the string to upper case ignoring locale information.</summary>
    ///  <returns>A new upper case string.</returns>
    function ToUpperInvariant(): TString; inline;

    ///  <summary>Converts the string to lower case.</summary>
    ///  <returns>A new lower case string.</returns>
    function ToLower(): TString;

    ///  <summary>Converts the string to lower case ignoring locale information.</summary>
    ///  <returns>A new lower case string.</returns>
    function ToLowerInvariant(): TString; inline;

    ///  <summary>Concatenates two strings.</summary>
    ///  <param name="AStr1">The first string.</param>
    ///  <param name="AStr2">The second string.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    class function Concat(const AStr1, AStr2: string): TString; overload; static; inline;

    ///  <summary>Concatenates three strings.</summary>
    ///  <param name="AStr1">The first string.</param>
    ///  <param name="AStr2">The second string.</param>
    ///  <param name="AStr3">The third string.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    class function Concat(const AStr1, AStr2, AStr3: string): TString; overload; static; inline;

    ///  <summary>Concatenates four strings.</summary>
    ///  <param name="AStr1">The first string.</param>
    ///  <param name="AStr2">The second string.</param>
    ///  <param name="AStr3">The third string.</param>
    ///  <param name="AStr4">The fourth string.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    class function Concat(const AStr1, AStr2, AStr3, AStr4: string): TString; overload; static; inline;

    ///  <summary>Concatenates five strings.</summary>
    ///  <param name="AStr1">The first string.</param>
    ///  <param name="AStr2">The second string.</param>
    ///  <param name="AStr3">The third string.</param>
    ///  <param name="AStr4">The fourth string.</param>
    ///  <param name="AStr5">The fifth string.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    class function Concat(const AStr1, AStr2, AStr3, AStr4, AStr5: string): TString; overload; static; inline;

    ///  <summary>Concatenates an array of strings.</summary>
    ///  <param name="AStrings">An array of strings.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    ///  <remarks>If <paramref name="AStrings"/> contains zero elements, an empty string is returned.</remarks>
    class function Concat(const AStrings: array of string): TString; overload; static;

    ///  <summary>Concatenates a collection of strings.</summary>
    ///  <param name="AStrings">An collection of strings.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    ///  <remarks>If <paramref name="AStrings"/> contains zero elements, an empty string is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AStrings"/> is <c>nil</c>.</exception>
    class function Concat(const AStrings: IEnumerable<string>): TString; overload; static;

    ///  <summary>Concatenates an array of strings using a separator.</summary>
    ///  <param name="ASeparator">The separator string placed between each concatenated string.</param>
    ///  <param name="AStrings">An array of strings.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    ///  <remarks>If <paramref name="AStrings"/> contains zero elements, an empty string is returned.</remarks>
    class function Join(const ASeparator: string; const AStrings: array of string): TString; overload; static;

    ///  <summary>Concatenates a collection of strings using a separator.</summary>
    ///  <param name="ASeparator">The separator string placed between each concatenated string.</param>
    ///  <param name="AStrings">A collection of strings.</param>
    ///  <returns>A new string formed from the concatenation of the supplied strings.</returns>
    ///  <remarks>If <paramref name="AStrings"/> contains zero elements, an empty string is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AStrings"/> is <c>nil</c>.</exception>
    class function Join(const ASeparator: string; const AStrings: IEnumerable<string>): TString; overload; static;

    ///  <summary>Formats a given array of const using a format string.</summary>
    ///  <param name="AFormat">The format string.</param>
    ///  <param name="AParams">An array of const to format.</param>
    ///  <returns>A new formatted string.</returns>
    ///  <remarks>This method uses Delphi's formatting method.</remarks>
    class function Format(const AFormat: string; const AParams: array of const): TString; overload; static;

    ///  <summary>Formats a given array of const using a format string.</summary>
    ///  <param name="AFormat">The format string.</param>
    ///  <param name="AParams">An array of const to format.</param>
    ///  <param name="AFormatSettings">The format settings to use when formatting.</param>
    ///  <returns>A new formatted string.</returns>
    ///  <remarks>This method uses Delphi's formatting method.</remarks>
    class function Format(const AFormat: string; const AParams: array of const;
      const AFormatSettings: TFormatSettings): TString; overload; static;

    ///  <summary>Compares two strings.</summary>
    ///  <param name="ALeft">The value to compare.</param>
    ///  <param name="ARight">The value to compare to.</param>
    ///  <param name="ACompareOption">The comparison mode used when comparing strings. Default is <c>scInvariant</c>.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - <paramref name="ALeft"/> is less than <paramref name="ARight"/>. If the result is zero -
    ///  <paramref name="ALeft"/> is equal to <paramref name="ARight"/>. And finally, if the result is greater than zero -
    ///  <paramref name="ALeft"/> is greater than <paramref name="ARight"/>.</returns>
    class function Compare(const ALeft, ARight: string; const ACompareOption: TStringComparison = scInvariant): NativeInt; static; inline;

    ///  <summary>Compares this string to another string.</summary>
    ///  <param name="AString">The value to compare to.</param>
    ///  <param name="ACompareOption">The comparison mode used when comparing strings. Default is <c>scInvariant</c>.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - this string is less than <paramref name="AString"/>. If the result is zero -
    ///  this string is equal to <paramref name="AString"/>. And finally, if the result is greater than zero -
    ///  this string is greater than <paramref name="AString"/>.</returns>
    function CompareTo(const AString: string; const ACompareOption: TStringComparison = scInvariant): NativeInt; inline;

    ///  <summary>Checks two strings for equality.</summary>
    ///  <param name="ALeft">The value to compare.</param>
    ///  <param name="ARight">The value to compare to.</param>
    ///  <param name="ACompareOption">The comparison mode used when comparing strings. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>True</c> if the strings are equal (using the given comparison mode); <c>False</c> otherwise.</returns>
    class function Equal(const ALeft, ARight: string; const ACompareOption: TStringComparison = scInvariant): Boolean; overload; static; inline;

    ///  <summary>Checks whether this string is equal to another string.</summary>
    ///  <param name="AString">The value to compare to.</param>
    ///  <param name="ACompareOption">The comparison mode used when comparing strings. Default is <c>scInvariant</c>.</param>
    ///  <returns><c>True</c> if the strings are equal (using the given comparison mode); <c>False</c> otherwise.</returns>
    function EqualsWith(const AString: string; const ACompareOption: TStringComparison = scInvariant): Boolean; inline;

    ///  <summary>Returns an empty string.</summary>
    ///  <returns>An empty string.</returns>
    class property Empty: TString read GetEmpty;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <returns>A Delphi string.</returns>
    class operator Implicit(const AString: TString): string; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AString">A Delphi string.</param>
    ///  <returns>A string.</returns>
    class operator Implicit(const AString: String): TString; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AString">A string.</param>
    ///  <returns>A <c>Variant</c> value.</returns>
    class operator Implicit(const AString: TString): Variant; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">First string to concatenate.</param>
    ///  <param name="ARight">Second string to concatenate.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft, ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The character to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: Char): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The character to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: Char; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>NativeInt</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: NativeInt): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>NativeInt</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: NativeInt; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>NativeUInt</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: NativeUInt): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>NativeUInt</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: NativeUInt; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>Int64</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: Int64): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>Int64</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: Int64; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>UInt64</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: UInt64): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>UInt64</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: UInt64; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>Extended</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: Extended): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>Extended</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: Extended; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>Currrency</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: Currency): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>Currency</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: Currency; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>Boolean</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: Boolean): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>Boolean</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: Boolean; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>TDateTime</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: TDateTime): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>TDateTime</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TDateTime; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>TDate</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: TDate): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>TDate</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TDate; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>TTime</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: TTime): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>TTime</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TTime; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The string to concatenate.</param>
    ///  <param name="ARight">The <c>Variant</c> to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: TString; const ARight: Variant): TString; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">The <c>Variant</c> to concatenate.</param>
    ///  <param name="ARight">The string to concatenate with.</param>
    ///  <returns>The resulting string.</returns>
    class operator Add(const ALeft: Variant; const ARight: TString): TString; inline;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ALeft">The value to compare.</param>
    ///  <param name="ARight">The value to compare to.</param>
    ///  <returns><c>True</c> if the strings are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft: TString; const ARight: TString): Boolean; inline;

    ///  <summary>Overloaded "<>" operator.</summary>
    ///  <param name="ALeft">The value to compare.</param>
    ///  <param name="ARight">The value to compare to.</param>
    ///  <returns><c>True</c> if the strings are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ALeft: TString; const ARight: TString): Boolean; inline;

    { .NET Compatibility / On-demand }
{$IFDEF TSTRING_DOT_NET_METHODS}
    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    function ToCharArray(): TArray<Char>; deprecated 'Use TString.ToString';

    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    class function IsNullOrEmpty(const AString: TString): Boolean; static; inline; deprecated 'Use TString.IsEmpty';

    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    class function IsNullOrWhiteSpace(const AString: TString): Boolean; static; inline; deprecated 'Use TString.IsWhiteSpace';

    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    function TrimStart(const ACharSet: TWideCharSet): TString; overload; inline; deprecated 'Use TString.TrimLeft';

    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    function TrimStart(): TString; overload; inline; deprecated 'Use TString.TrimLeft.';

    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    function TrimEnd(const ACharSet: TWideCharSet): TString; overload; inline; deprecated 'Use TString.TrimRight';

    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    function TrimEnd(): TString; overload; inline; deprecated 'Use TString.TrimRight';

    ///  <summary>.NET compatibility method. Not compiled by default.</summary>
    function Equal(const AString: string; const ACompareOption: TStringComparison
      = scInvariant): Boolean; overload; inline; deprecated 'Use TString.EqualsWith';
{$ENDIF}

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <param name="ACompareOption">The comparison mode used by the type object's compare methods.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents
    ///  <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> type.</returns>
    class function GetType(const ACompareOption: TStringComparison = scInvariant): IType<TString>; static;
  end;

  ///  <summary>Creates a new <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> from a Delphi string.</summary>
  ///  <param name="AString">A Delphi string to convert.</param>
  ///  <returns>A new <see cref="DeHL.Strings|TString">DeHL.Strings.TString</see> value.</returns>
  ///  <remarks>This method can be used to write expression faster (ex. <c>U('Some Constant').ToUpper().Trim()</c>)</remarks>
  function U(const AString: string): TString; inline;

implementation
{$IFDEF MSWINDOWS}uses Windows;{$ENDIF}

function U(const AString: string): TString;
begin
  Result.FString := Astring;
end;

type
  { Used only internally }
  TStringCompareProc = function(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt): NativeInt;


  { TString type support }
  TTStringType = class sealed(TRecordType<TString>)
  private
    FComparison: TStringComparison;

  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TString; const Acontext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TString; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: TString): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: TString): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: TString): String; override;

    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: TString; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TString): Boolean; override;

    { Costructors }
    constructor Create(); overload; override;
    constructor Create(const ACompareOption: TStringComparison); reintroduce; overload;
  end;

{
   These bridge functions are required to properly call the SysUtils wide
   versions.
}
function __LocaleCaseSensitive(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt): NativeInt;
begin
  Result := SysUtils.AnsiStrLComp(ALeft, ARight, MaxLen);
end;

function __LocaleCaseInsensitive(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt): NativeInt;
begin
  Result := SysUtils.AnsiStrLIComp(ALeft, ARight, MaxLen);
end;

function __InvariantCaseSensitive(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt): NativeInt;
begin
{$IF defined(MSWINDOWS)}
  Result := CompareStringW(LOCALE_INVARIANT, 0, ALeft, MaxLen, ARight, MaxLen) - CSTR_EQUAL;
{$ELSE}
  Result := SysUtils.StrLComp(ALeft, ARight, MaxLen);
{$IFEND}
end;

function __InvariantCaseInsensitive(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt): NativeInt;
begin
{$IF defined(MSWINDOWS)}
  Result := CompareStringW(LOCALE_INVARIANT, NORM_IGNORECASE, ALeft, MaxLen, ARight, MaxLen) - CSTR_EQUAL;
{$ELSE}
  Result := SysUtils.StrLIComp(ALeft, ARight, MaxLen);
{$IFEND}
end;

function __OrdinalCaseSensitive(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt): NativeInt;
begin
  { Very simple. Call the binary compare utility routine }
  Result := BinaryCompare(ALeft, ARight, MaxLen * SizeOf(WideChar));
end;

function __OrdinalCaseInsensitive(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt): NativeInt;
var
  LUpLeft, LUpRight: String;
begin
  if MaxLen = 0 then
    Exit(0); // Equal for 0 length

  { Create strings }
  SetString(LUpLeft, ALeft, MaxLen);
  SetString(LUpRight, ARight, MaxLen);

  { Upper case them }
  LUpLeft := Character.ToUpper(LUpLeft);
  LUpRight := Character.ToUpper(LUpRight);

  { And finally we can compare! }
  Result := BinaryCompare(Pointer(LUpLeft), Pointer(LUpRight), MaxLen * SizeOf(WideChar));
end;

var
  { Used for comparison utilities }
  FStrCompareFuncs: array[TStringComparison] of TStringCompareProc;

{ TString }

class operator TString.Add(const ALeft, ARight: TString): TString;
begin
  Result := ALeft.FString + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: NativeInt): TString;
begin
  Result := ALeft.FString + IntToStr(ARight);
end;

class operator TString.Add(const ALeft: NativeInt; const ARight: TString): TString;
begin
  Result := IntToStr(ALeft) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: NativeUInt): TString;
begin
  Result := ALeft.FString + UIntToStr(ARight);
end;

class operator TString.Add(const ALeft: NativeUInt; const ARight: TString): TString;
begin
  Result := UIntToStr(ALeft) + ARight.FString;
end;

class function TString.Concat(const AStr1, AStr2, AStr3: string): TString;
begin
  Result.FString := AStr1 + AStr2 + AStr3;
end;

class function TString.Concat(const AStr1, AStr2: string): TString;
begin
  Result.FString := AStr1 + AStr2;
end;

class function TString.Concat(const AStr1, AStr2, AStr3, AStr4, AStr5: string): TString;
begin
  Result.FString := AStr1 + AStr2 + AStr3 + AStr4 + AStr5;
end;

class function TString.Concat(const AStr1, AStr2, AStr3, AStr4: string): TString;
begin
  Result.FString := AStr1 + AStr2 + AStr3 + AStr4;
end;

function TString.Contains(const AWhat: string; const ACompareOption: TStringComparison): Boolean;
begin
  { Call IndexOf }
  Result := IndexOf(AWhat, ACompareOption) > (CFirstCharacterIndex - 1);
end;

class constructor TString.Create;
begin
  { Register custom type }
  if not TType<TString>.IsRegistered then
    TType<TString>.Register(TTStringType);
end;

class function TString.FromUTF8String(const AUTF8String: RawByteString): TString;
begin
  { Decode utf8 }
  Result.FString := System.UTF8ToUnicodeString(AUtf8String);
end;

class function TString.FromUCS4String(const AUCS4String: UCS4String): TString;
begin
  { Decode ucs4 string }
  Result.FString := System.UCS4StringToUnicodeString(AUcs4String);
end;

constructor TString.Create(const AString: TString);
begin
  { Simple copy }
  FString := AString.FString;
end;

class destructor TString.Destroy;
begin
  { Unregister custom type }
  if TType<TString>.IsRegistered then
    TType<TString>.Unregister();
end;

function TString.Dupe(const ACount: NativeUInt): TString;
begin
  { Check whether we need to do any work }
  if (ACount = 0) or (System.Length(FString) = 0) then
  begin
    Result.FString := CEmpty;
    Exit;
  end;

  Result.FString := StrUtils.DupeString(FString, ACount);
end;

function TString.EndsWith(const AWhat: string; const ACompareOption: TStringComparison): Boolean;
var
  LLength: NativeUInt;
begin
  LLength := System.Length(FString);

  { Call IndexOf, and test  }
  Result := (LLength > 0) and ((LastIndexOf(AWhat, ACompareOption) + System.Length(AWhat) - CFirstCharacterIndex) =
    System.Length(FString));
end;

class function TString.Equal(const ALeft, ARight: string; const ACompareOption: TStringComparison): Boolean;
begin
  Result := Compare(ALeft, ARight, ACompareOption) = 0;
end;

class operator TString.Equal(const ALeft, ARight: TString): Boolean;
begin
  { Call the compare method }
  Result := (ALeft.CompareTo(ARight) = 0);
end;

function TString.EqualsWith(const AString: string; const ACompareOption: TStringComparison): Boolean;
begin
  Result := CompareTo(AString, ACompareOption) = 0;
end;

class function TString.Format(const AFormat: string; const AParams: array of const;
  const AFormatSettings: TFormatSettings): TString;
begin
  { Forward the call }
  Result := SysUtils.Format(AFormat, AParams, AFormatSettings);
end;

class function TString.Format(const AFormat: string; const AParams: array of const): TString;
begin
  { Forward the call }
  Result := SysUtils.Format(AFormat, AParams);
end;

constructor TString.Create(const AString: string);
begin
  { Simple copy }
  FString := AString;
end;

function TString.GetChar(const AIndex: NativeInt): Char;
var
  LIndex: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AIndex + (1 - CFirstCharacterIndex);

  { Get the char }
{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > System.Length(FString)) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
{$ENDIF}

  Result := FString[LIndex];
end;

class function TString.GetEmpty: TString;
begin
  { That's quite it }
  Result.FString := CEmpty;
end;

function TString.GetEnumerator: IEnumerator<Char>;
begin
  Result := TEnumerator.Create(FString);
end;

function TString.GetIsEmpty: Boolean;
begin
  { Check length }
  Result := System.Length(FString) = 0;
end;

function TString.GetIsWhiteSpace: Boolean;
var
  I: NativeInt;
begin
  { Check if each char is whitespace }
  for I := 1 to System.Length(FString) do
    if not Character.IsWhiteSpace(FString, I) then
      Exit(false);

  { String was either empty or contained whitespaces only }
  Result := true;
end;

function TString.GetLength: NativeUInt;
begin
  { Get the char }
  Result := System.Length(FString);
end;

class operator TString.Implicit(const AString: TString): string;
begin
  { Copy back }
  Result := AString.FString;
end;

class operator TString.Implicit(const AString: String): TString;
begin
  { Copy into }
  Result.FString := AString;
end;

class operator TString.Implicit(const AString: TString): Variant;
begin
  { Assign variant }
  Result := AString.FString;
end;

function TString.IndexOf(const AWhat: string; const ACompareOption: TStringComparison): NativeInt;
var
  I: NativeInt;
  L, LW: NativeUInt;
begin
  { Prepare! Calculate lengths }
  L := System.Length(FString);
  LW := System.Length(AWhat);

  Result := CFirstCharacterIndex - 1; // Nothing.

  { Do not continue if there are no substrings or the string is empty }
  if (L = 0) or (LW > L) or (LW = 0) then
    Exit;

  { Start from the beggining and try to search for what we need }
  for I := 1 to (L - LW + 1) do
    if InternalCompare(PWideChar(FString) + I - 1, PWideChar(AWhat), LW, ACompareOption) = 0 then
      Exit(I - 1 + CFirstCharacterIndex);
end;

function TString.IndexOfAny(const AWhat: array of string; const ACompareOption: TStringComparison): NativeInt;
var
  LW: array of NativeUInt;
  I, L, X, C: NativeUInt;
begin
  { Prepare! Calculate lengths }
  L := System.Length(FString);
  C := System.Length(AWhat);
  Result := CFirstCharacterIndex - 1; // Nothing.

  { Do not continue if there are no substrings or the string is empty }
  if (L = 0) or (C = 0) then
    Exit;

  { Setup the lengths }
  SetLength(LW, C);
  for I := 0 to C - 1 do
    LW[I] := System.Length(AWhat[I]);

  { Start from the beggining and try to search for what we need }
  for I := 1 to L do
    for X := 0 to C - 1 do
    begin
      { Check whether the current substr can fit into what's left }
      if (LW[X] > (L - I + 1)) or (LW[X] = 0) then
        continue;

      if InternalCompare(PWideChar(FString) + I - 1, PWideChar(AWhat[X]), LW[X], ACompareOption) = 0 then
        Exit(I - 1 + CFirstCharacterIndex);
    end;
end;

function TString.Insert(const AIndex: NativeInt; const AWhat: string): TString;
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AIndex + (1 - CFirstCharacterIndex);
  LLength := System.Length(FString);

{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > (LLength + 1)) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
{$ENDIF}

  { Assign and unique-fy }
  Result.FString := FString;
  System.Insert(AWhat, Result.FString, LIndex);
end;

class function TString.InternalCompare(const ALeft, ARight: PWideChar; const MaxLen: NativeUInt;
  const LType: TStringComparison): NativeInt;
begin
  Result := FStrCompareFuncs[LType](ALeft, ARight, MaxLen);
end;

{$IFDEF TSTRING_DOT_NET_METHODS}
function TString.ToCharArray: TArray<Char>;
var
  LLength: NativeUInt;
begin
  LLength := System.Length(FString);
  SetLength(Result, LLength);

  if LLength > 0 then
    MoveChars(FString[1], Result[0], LLength);
end;

function TString.Equal(const AString: string; const ACompareOption: TStringComparison): Boolean;
begin
  Result := CompareTo(AString, ACompareOption) = 0;
end;

class function TString.IsNullOrEmpty(const AString: TString): Boolean;
begin
  Result := AString.GetIsEmpty;
end;

class function TString.IsNullOrWhiteSpace(const AString: TString): Boolean;
begin
  Result := AString.GetIsWhiteSpace;
end;

function TString.TrimStart: TString;
begin
  Result := TrimLeft();
end;

function TString.TrimStart(const ACharSet: TWideCharSet): TString;
begin
  Result := TrimLeft(ACharSet);
end;

function TString.TrimEnd: TString;
begin
  Result := TrimRight();
end;

function TString.TrimEnd(const ACharSet: TWideCharSet): TString;
begin
  Result := TrimRight(ACharSet);
end;
{$ENDIF}

class function TString.Join(const ASeparator: string; const AStrings: array of string): TString;
var
  I, L: NativeInt;
begin
  { This may look weird but it's actually optinmized for the most common cases }
  L := System.Length(AStrings);

  case L of
    0: Result.FString := Empty;
    1: Result.FString := AStrings[0];
    2: Result.FString := AStrings[0] + ASeparator + AStrings[1];
    3: Result.FString := AStrings[0] + ASeparator + AStrings[1] + ASeparator + AStrings[2];
    4: Result.FString := AStrings[0] + ASeparator + AStrings[1] + ASeparator +
      AStrings[2] + ASeparator + AStrings[3];
    5: Result.FString := AStrings[0] + ASeparator + AStrings[1] + ASeparator + AStrings[2] +
      ASeparator + AStrings[3] + ASeparator + AStrings[4];
    else
    begin
      Result.FString := AStrings[0];

      for I := 1 to L - 1 do
        Result.FString := Result.FString + ASeparator + AStrings[I];
    end;
  end;
end;

class function TString.Join(const ASeparator: string; const AStrings: IEnumerable<string>): TString;
var
  LString: string;
begin
  if AStrings = nil then
    ExceptionHelper.Throw_ArgumentNilError('AStrings');

  Result.FString := CEmpty;

  for LString in AStrings do
  begin
    if System.Length(Result.FString) = 0 then
      Result.FString := LString
    else
      Result.FString := Result.FString + ASeparator + LString;
  end;
end;

function TString.LastIndexOf(const AWhat: string; const ACompareOption: TStringComparison): NativeInt;
var
  I: NativeInt;
  L, LW: NativeUInt;
begin
  { Prepare! Calculate lengths }
  L := System.Length(FString);
  LW := System.Length(AWhat);

  { Special case of nil string }
  Result := CFirstCharacterIndex - 1; // Nothing.

  { Do not continue if there are no substrings or the string is empty }
  if (L = 0) or (LW > L) or (LW = 0) then
    Exit;

  { Start from the beggining and try to search for what we need }
  for I := (L - LW + 1) downto 1 do
    if InternalCompare(PWideChar(FString) + I - 1, PWideChar(AWhat), LW, ACompareOption) = 0 then
      Exit(I - 1 + CFirstCharacterIndex);
end;

function TString.LastIndexOfAny(const AWhat: array of string; const ACompareOption: TStringComparison): NativeInt;
var
  LW: array of NativeUInt;
  I, L, X, C: NativeUInt;
begin
  { Prepare! Calculate lengths }
  L := System.Length(FString);
  C := System.Length(AWhat);
  Result := CFirstCharacterIndex - 1; // Nothing.

  { Do not continue if there are no substrings or the string is empty }
  if (L = 0) or (C = 0) then
    Exit;

  { Setup the lengths }
  SetLength(LW, C);
  for I := 0 to C - 1 do
    LW[I] := System.Length(AWhat[I]);

  { Start from the beggining and try to search for what we need }
  for I := L downto 1 do
    for X := 0 to C - 1 do
    begin
      { Check whether the current substr can fit into what's left }
      if (LW[X] > (L - I + 1)) or (LW[X] = 0) then
        continue;

      if InternalCompare(PWideChar(FString) + I - 1, PWideChar(AWhat[X]), LW[X], ACompareOption) = 0 then
        Exit(I - 1 + CFirstCharacterIndex);
    end;
end;

class operator TString.NotEqual(const ALeft, ARight: TString): Boolean;
begin
  { Call the compare method }
  Result := (ALeft.CompareTo(ARight) <> 0);
end;

function TString.PadLeft(const ACount: NativeUInt; const AChar: Char): TString;
var
  LPad: string;
  I: NativeInt;
begin
  { Create the pad string }
  SetLength(LPad, ACount);
  for I := 1 to ACount do
    LPad[I] := AChar;

  { [PAD] + String }
  Result.FString := LPad + FString;
end;

function TString.PadRight(const ACount: NativeUInt; const AChar: Char): TString;
var
  LPad: string;
  I: NativeInt;
begin
  { Create the pad string }
  SetLength(LPad, ACount);
  for I := 1 to ACount do
    LPad[I] := AChar;

  { String + [PAD] }
  Result.FString := FString + LPad;
end;

function TString.Replace(const AWhat, AWith: Char): TString;
var
  I: NativeInt;
begin
  { Copy the string }
  Result.FString := FString;

  { Start working }
  for I := 1 to System.Length(FString) do
    if Result.FString[I] = AWhat then
      Result.FString[I] := AWith;
end;

function TString.Remove(const AStart: NativeInt; const ACount: NativeUInt): TString;
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + (1 - CFirstCharacterIndex);
  LLength := System.Length(FString);

{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');

  if (LIndex + NativeInt(ACount) - 1) > LLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');
{$ENDIF}

  Result.FString := FString;
  System.Delete(Result.FString, LIndex, ACount);
end;

function TString.Remove(const AStart: NativeInt): TString;
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + (1 - CFirstCharacterIndex);
  LLength := System.Length(FString);

{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
{$ENDIF}

  Result.FString := FString;
  System.Delete(Result.FString, LIndex, LLength);
end;

function TString.Replace(const AWhat, AWith: string; const ACompareOption: TStringComparison): TString;
var
  LResult: string;
  LLength, LWhatLen, I, L: NativeInt;
begin
  { Init }
  LResult := CEmpty;
  LLength := System.Length(FString);
  LWhatLen := System.Length(AWhat);

  { Nothing to do? }
  if (LLength = 0) or (LWhatLen = 0) or (LWhatLen > LLength) then
  begin
    Result.FString := FString;
    Exit;
  end;

  L := 1;

  { Start from the beggining abd do search }
  for I := 1 to (LLength - LWhatLen + 1) do
    if InternalCompare(PWideChar(FString) + I - 1, PWideChar(AWhat), LWhatLen, ACompareOption) = 0 then
    begin
      LResult := LResult + System.Copy(FString, L, (I - L)) + AWith;
      L := I + LWhatLen;
    end;

  if L < LLength then
    LResult := LResult + System.Copy(FString, L, MaxInt);

  Result.FString := LResult;
end;

function TString.Reverse: TString;
begin
  { Consider surrogate pairs }
  Result := StrUtils.AnsiReverseString(FString);
end;

function TString.Split(const ADelimiters: TWideCharSet; const ARemoveEmptyEntries: Boolean = false): TArray<TString>;
var
  LResCount, I, LLag,
    LPrevIndex, LCurrPiece: NativeInt;
  LPiece: string;
begin
  { Initialize, set all to zero }
  SetLength(Result , 0);

  { Do nothing for empty strings }
  if System.Length(FString) = 0 then
    Exit;

  { Determine the length of the resulting array }
  LResCount := 0;

  for I := 1 to System.Length(FString) do
    if FString[I] in ADelimiters then
      Inc(LResCount);

  { Set the length of the output split array }
  SetLength(Result, LResCount + 1);

  { Split the string and fill the resulting array }
  LPrevIndex := 1;
  LCurrPiece := 0;
  LLag := 0;

  for I := 1 to System.Length(FString) do
    if FString[I] in ADelimiters then
    begin
      LPiece := System.Copy(FString, LPrevIndex, (I - LPrevIndex));

      if ARemoveEmptyEntries and (System.Length(LPiece) = 0) then
        Inc(LLag)
      else
        Result[LCurrPiece - LLag] := LPiece;

      { Adjust prev index and current piece }
      LPrevIndex := I + 1;
      Inc(LCurrPiece);
    end;

  { Copy the remaining piece of the string }
  LPiece := Copy(FString, LPrevIndex, System.Length(FString) - LPrevIndex + 1);

  { Doom! }
  if ARemoveEmptyEntries and (System.Length(LPiece) = 0) then
    Inc(LLag)
  else
    Result[LCurrPiece - LLag] := LPiece;

  { Re-adjust the array for the missing pieces }
  if LLag > 0 then
    System.SetLength(Result, LResCount - LLag + 1);
end;

function TString.Split(const ADelimiter: Char; const ARemoveEmptyEntries: Boolean = false): TArray<TString>;
begin
  { Call the string oveerload }
  Result := Split(TWideCharSet.Create(ADelimiter), ARemoveEmptyEntries);
end;

function TString.StartsWith(const AWhat: string; const ACompareOption: TStringComparison): Boolean;
begin
  { Call IndexOf, and test  }
  Result := IndexOf(AWhat, ACompareOption) = CFirstCharacterIndex;
end;

function TString.Substring(const AStart: NativeInt; const ACount: NativeUInt): TString;
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + (1 - CFirstCharacterIndex);
  LLength := System.Length(FString);

{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStart');

  if (LIndex + NativeInt(ACount) - 1) > LLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');
{$ENDIF}

  Result.FString := Copy(FString, LIndex, ACount);
end;

function TString.Substring(const AStart: NativeInt): TString;
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + (1 - CFirstCharacterIndex);
  LLength := System.Length(FString);

{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStart');
{$ENDIF}

  Result.FString := Copy(FString, LIndex, LLength);
end;

function TString.ToLower: TString;
{$IF defined(MSWINDOWS)}
var
  LLength: NativeInt;
begin
  { Get the in and out lengths }
  LLength := System.Length(FString);
  Result.FString := FString; UniqueString(Result.FString);
  LCMapString(LOCALE_USER_DEFAULT, LCMAP_LOWERCASE,
    PWideChar(Result.FString), LLength, PWideChar(Result.FString), LLength);
{$ELSE}
begin
  Result.FString := AnsiLowerCase(FString);
{$IFEND}
end;

function TString.ToLowerInvariant: TString;
begin
  { Use Character.pas. It doesn't depend on locale options }
  Result.FString := Character.ToLower(FString);
end;

function TString.ToString: string;
begin
  Result := FString;
end;

function TString.ToUCS4String: UCS4String;
begin
  { Convert }
  Result := System.UnicodeStringToUCS4String(FString);
end;

function TString.ToUpper: TString;
{$IF defined(MSWINDOWS)}
var
  LLength: NativeInt;
begin
  { Get the in and out lengths }
  LLength := System.Length(FString);
  Result.FString := FString; UniqueString(Result.FString);
  LCMapString(LOCALE_USER_DEFAULT, LCMAP_UPPERCASE,
    PWideChar(Result.FString), LLength, PWideChar(Result.FString), LLength);
{$ELSE}
begin
  Result.FString := AnsiUpperCase(FString);
{$IFEND}
end;

function TString.ToUpperInvariant: TString;
begin
  { Use Character.pas. It doesn't depend on locale options }
  Result.FString := Character.ToUpper(FString);
end;

function TString.ToUTF8String: RawByteString;
begin
  { Simple call }
  Result := System.UTF8Encode(FString);
end;

function TString.Trim: TString;
var
  I, L, R: NativeInt;
begin
  { Defaults }
  L := System.Length(FString);
  R := 1;

  { Find the left point }
  for I := 1 to System.Length(FString) do
    if not Character.IsWhiteSpace(FString, I) then
    begin
      L := I;
      Break;
    end;

  { Find the right point }
  for I := System.Length(FString) downto 1 do
    if not Character.IsWhiteSpace(FString, I) then
    begin
      R := I;
      Break;
    end;

  { Copy }
  Result.FString := System.Copy(FString, L, (R - L + 1));
end;

function TString.Trim(const ACharSet: TWideCharSet): TString;
var
  I, L, R: NativeInt;
begin
  { Defaults }
  L := System.Length(FString);
  R := 1;

  { Find the left point }
  for I := 1 to System.Length(FString) do
    if not (FString[I] in ACharSet) then
    begin
      L := I;
      Break;
    end;

  { Find the right point }
  for I := System.Length(FString) downto 1 do
    if not (FString[I] in ACharSet) then
    begin
      R := I;
      Break;
    end;

  { Copy }
  Result.FString := System.Copy(FString, L, (R - L + 1));
end;

function TString.TrimLeft: TString;
var
  I: NativeInt;
begin
  { Loop until we get to the first non-whitespace char. We've determined that 1st char is whitespace. }
  for I := 1 to System.Length(FString) do
    if not Character.IsWhiteSpace(FString, I) then
    begin
      { If nothing was done, take the ref, or copy otherwise }
      if I = 1 then
        Result.FString := FString
      else
        Result.FString := System.Copy(FString, I, MaxInt);

      Exit;
    end;

  { It's all whitespaces }
  Result.FString := Empty;
end;

function TString.TrimLeft(const ACharSet: TWideCharSet): TString;
var
  I: NativeInt;
begin
  { Loop until we get to the first non-whitespace char. We've determined that 1st char is whitespace. }
  for I := 1 to System.Length(FString) do
    if not (FString[I] in ACharSet) then
    begin
      { If nothing was done, take the ref, or copy otherwise }
      if I = 1 then
        Result.FString := FString
      else
        Result.FString := System.Copy(FString, I, MaxInt);

      Exit;
    end;

  { It's all whitespaces }
  Result.FString := Empty;
end;

function TString.TrimRight(const ACharSet: TWideCharSet): TString;
var
  I: NativeInt;
begin
  { Loop until we get to the first non-whitespace char. We've determined that 1st char is whitespace. }
  for I := System.Length(FString) downto 1 do
    if not (FString[I] in ACharSet) then
    begin
      { If nothing was done, take the ref, or copy otherwise }
      if I = System.Length(FString) then
        Result.FString := FString
      else
        Result.FString := System.Copy(FString, 1, I);

      Exit;
    end;

  { It's all whitespaces }
  Result.FString := Empty;
end;

function TString.TrimRight: TString;
var
  I: NativeInt;
begin
  { Loop until we get to the first non-whitespace char. We've determined that 1st char is whitespace. }
  for I := System.Length(FString) downto 1 do
    if not Character.IsWhiteSpace(FString, I) then
    begin
      { If nothing was done, take the ref, or copy otherwise }
      if I = System.Length(FString) then
        Result.FString := FString
      else
        Result.FString := System.Copy(FString, 1, I);

      Exit;
    end;

  { It's all whitespaces }
  Result.FString := Empty;
end;

class function TString.GetType(const ACompareOption: TStringComparison): IType<TString>;
begin
  { Create and return the type instance }
  Result := TTStringType.Create(ACompareOption);
end;

class operator TString.Add(const ALeft: Int64; const ARight: TString): TString;
begin
  Result := IntToStr(ALeft) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: Int64): TString;
begin
  Result := ALeft.FString + IntToStr(ARight);
end;

class operator TString.Add(const ALeft: UInt64; const ARight: TString): TString;
begin
  Result := UIntToStr(ALeft) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: UInt64): TString;
begin
  Result := ALeft.FString + UIntToStr(ARight);
end;

class operator TString.Add(const ALeft: TString; const ARight: Boolean): TString;
begin
  Result := ALeft.FString + BoolToStr(ARight, true);
end;

class operator TString.Add(const ALeft: Boolean; const ARight: TString): TString;
begin
  Result := BoolToStr(ALeft, true) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: Char): TString;
begin
  Result := ALeft.FString + ARight;
end;

class operator TString.Add(const ALeft: Char; const ARight: TString): TString;
begin
  Result := ALeft + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: Extended): TString;
begin
  Result := ALeft.FString + FloatToStr(ARight);
end;

class operator TString.Add(const ALeft: Extended; const ARight: TString): TString;
begin
  Result := FloatToStr(ALeft) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: Currency): TString;
begin
  Result := ALeft.FString + CurrToStr(ARight);
end;

class operator TString.Add(const ALeft: Currency; const ARight: TString): TString;
begin
  Result := CurrToStr(ALeft) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: TDateTime): TString;
begin
  Result := ALeft.FString + DateTimeToStr(ARight);
end;

class operator TString.Add(const ALeft: TDateTime; const ARight: TString): TString;
begin
  Result := DateTimeToStr(ALeft) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: TDate): TString;
begin
  Result := ALeft.FString + DateToStr(ARight);
end;

class operator TString.Add(const ALeft: TDate; const ARight: TString): TString;
begin
  Result := DateToStr(ALeft) + ARight.FString;
end;

class operator TString.Add(const ALeft: TString; const ARight: TTime): TString;
begin
  Result := ALeft.FString + TimeToStr(ARight);
end;

class operator TString.Add(const ALeft: TTime; const ARight: TString): TString;
begin
  Result := TimeToStr(ALeft) + ARight.FString;
end;

function TString.AsCollection: IEnexCollection<Char>;
begin
  Result := TEnumerable.Create(FString);
end;

class function TString.Compare(const ALeft, ARight: string; const ACompareOption: TStringComparison): NativeInt;
var
  LLeftLen, LRightLen: NativeInt;
begin
  { Calculate the lengths }
  LLeftLen := System.Length(ALeft);
  LRightLen := System.Length(ARight);

  { The difference }
  Result := LLeftLen - LRightLen;

  { Do a hard-core comparison if the lenghts are equal }
  if Result = 0 then
    Result := InternalCompare(PWideChar(ALeft), PWideChar(ARight), LLeftLen, ACompareOption);
end;

function TString.CompareTo(const AString: string; const ACompareOption: TStringComparison): NativeInt;
begin
  { Call static one }
  Result := Compare(FString, AString, ACompareOption);
end;

class function TString.Concat(const AStrings: array of string): TString;
var
  I, L: NativeInt;
begin
  { This may look weird but it's actually optinmized for the most common cases }
  L := System.Length(AStrings);

  case L of
    0: Result.FString := CEmpty;
    1: Result.FString := AStrings[0];
    2: Result.FString := AStrings[0] + AStrings[1];
    3: Result.FString := AStrings[0] + AStrings[1] + AStrings[2];
    4: Result.FString := AStrings[0] + AStrings[1] + AStrings[2] + AStrings[3];
    5: Result.FString := AStrings[0] + AStrings[1] + AStrings[2] + AStrings[3] + AStrings[4];
    else
    begin
      Result.FString := AStrings[0];

      for I := 1 to L - 1 do
        Result.FString := Result.FString + AStrings[I];
    end;
  end;
end;

class function TString.Concat(const AStrings: IEnumerable<string>): TString;
var
  LString: string;
begin
  if AStrings = nil then
    ExceptionHelper.Throw_ArgumentNilError('AStrings');

  Result.FString := CEmpty;

  for LString in AStrings do
    Result.FString := Result.FString + LString;
end;

class operator TString.Add(const ALeft: TString; const ARight: Variant): TString;
begin
  Result := ALeft.FString + ARight;
end;

class operator TString.Add(const ALeft: Variant; const ARight: TString): TString;
begin
  Result := ALeft + ARight.FString;
end;

{ TString.TEnumerator }

constructor TString.TEnumerator.Create(const AString: string);
begin
  FString := AString;
  FCurrent := #0;
  FIndex := 0;
end;

function TString.TEnumerator.GetCurrent: Char;
begin
  Result := FCurrent;
end;

function TString.TEnumerator.MoveNext: Boolean;
begin
  { Check for end }
  Inc(FIndex);
  Result := FIndex <= System.Length(FString);

  { Read current }
  if Result then
    FCurrent := FString[FIndex];
end;

{ TString.TEnumerable }

procedure TString.TEnumerable.CopyTo(var AArray: array of Char; const StartIndex: NativeUInt);
begin
  if StartIndex >= NativeUInt(System.Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(System.
  Length(AArray)) - StartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Move the chars }
  MoveChars(FString[1], AArray[StartIndex], Count);
end;

constructor TString.TEnumerable.Create(const AString: string);
begin
  inherited Create();

  { Simpla }
  FString := AString;
end;

function TString.TEnumerable.ElementAt(const Index: NativeUInt): Char;
var
  LIndex: NativeInt;
begin
  { Calculate the index proper }
  LIndex := Index + (1 - CFirstCharacterIndex);

  { Get the char }
{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > System.Length(FString)) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');
{$ENDIF}

  Result := FString[LIndex];
end;

function TString.TEnumerable.ElementAtOrDefault(const Index: NativeUInt; const ADefault: Char): Char;
var
  LIndex: NativeInt;
begin
  { Calculate the index proper }
  LIndex := Index + (1 - CFirstCharacterIndex);

  { Get the char }
{$IFDEF TSTRING_CHECK_RANGES}
  if (LIndex > System.Length(FString)) or (LIndex < 1) then
     Exit(ADefault);
{$ENDIF}

  Result := FString[LIndex];
end;

function TString.TEnumerable.Empty: Boolean;
begin
  { Test length }
  Result := System.Length(FString) = 0;
end;

function TString.TEnumerable.First: Char;
begin
  Result := ElementAt(CFirstCharacterIndex);
end;

function TString.TEnumerable.FirstOrDefault(const ADefault: Char): Char;
begin
  Result := ElementAtOrDefault(CFirstCharacterIndex, ADefault);
end;

function TString.TEnumerable.GetCount: NativeUInt;
begin
  { Duuh! }
  Result := System.Length(FString);
end;

function TString.TEnumerable.GetEnumerator: IEnumerator<Char>;
begin
  { Create enumerator }
  Result := TEnumerator.Create(FString);
end;

function TString.TEnumerable.Last: Char;
begin
  Result := ElementAt(CFirstCharacterIndex + Count - 1);
end;

function TString.TEnumerable.LastOrDefault(const ADefault: Char): Char;
begin
  Result := ElementAtOrDefault(CFirstCharacterIndex + Count - 1, ADefault);
end;

{ TUnicodeStringType }

function TTStringType.Compare(const AValue1, AValue2: TString): NativeInt;
begin
  { Simple enough }
  Result := AValue1.CompareTo(AValue2.FString, FComparison);
end;

constructor TTStringType.Create;
begin
  inherited;
  FComparison := scInvariant;
end;

constructor TTStringType.Create(const ACompareOption: TStringComparison);
begin
  inherited Create();
  FComparison := ACompareOption;
end;

function TTStringType.GenerateHashCode(const AValue: TString): NativeInt;
var
  Cpy: TString;
begin
  { Call the generic hasher }
  if Length(AValue) > 0 then
  begin
    if FComparison = scInvariant then
      Result := BinaryHash(Pointer(AValue.FString), AValue.Length * SizeOf(Char))
    else
    begin
      Cpy := AValue.ToUpperInvariant();
      Result := BinaryHash(Pointer(Cpy.FString), AValue.Length * SizeOf(Char));
    end;
  end
  else
     Result := 0;
end;

function TTStringType.GetString(const AValue: TString): String;
begin
  Result := AValue.FString;
end;

function TTStringType.TryConvertFromVariant(const AValue: Variant; out ORes: TString): Boolean;
begin
  { Variant type-cast }
  try
    ORes.FString := UnicodeString(AValue);
  except
    Exit(false);
  end;

  Result := true;
end;

function TTStringType.TryConvertToVariant(const AValue: TString; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue.FString;
  Result := true;
end;

procedure TTStringType.DoDeserialize(const AInfo: TValueInfo; out AValue: TString; const AContext: IDeserializationContext);
var
  LRefValue: UnicodeString;
begin
  AContext.GetValue(AInfo, LRefValue);
  AValue.FString := LRefValue;
end;

procedure TTStringType.DoSerialize(const AInfo: TValueInfo; const AValue: TString; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue.FString);
end;

function TTStringType.Family: TTypeFamily;
begin
  Result := tfString;
end;

initialization
  { Register comparison functions }
  FStrCompareFuncs[scLocale]              := @__LocaleCaseSensitive;
  FStrCompareFuncs[scLocaleIgnoreCase]    := @__LocaleCaseInsensitive;
  FStrCompareFuncs[scInvariant]           := @__InvariantCaseSensitive;
  FStrCompareFuncs[scInvariantIgnoreCase] := @__InvariantCaseInsensitive;
  FStrCompareFuncs[scOrdinal]             := @__OrdinalCaseSensitive;
  FStrCompareFuncs[scOrdinalIgnoreCase]   := @__OrdinalCaseInsensitive;

end.
