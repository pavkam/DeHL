(*
* Copyright (c) 2009-2010, Ciobanu Alexandru
* All rights reserved.
*
* Ideea based on Matt McCutchen's C++ Big Integer Library
* which was released to public domain. Site: http://mattmccutchen.net/bigint/index.html
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
unit DeHL.Math.BigCardinal;
interface
uses SysUtils,
     Variants,
     DeHL.Base,
     DeHL.Cloning,
     DeHL.Serialization,
     DeHL.Exceptions,
     DeHL.Math.Types,
     DeHL.Types;

type
  ///  <summary>An unlimited precision natural number.</summary>
  BigCardinal = record
  private
  type
    TNumberPiece = NativeUInt;
    TNumberPieceArray = array of TNumberPiece;

  const
    BytesInPiece  = SizeOf(TNumberPiece);
    BitsInPiece   = BytesInPiece * 8;
    BCDDigitBits  = 4;
    BCDMask       = $F;


  private
    class var FVarType: TVarType;

    class var FOne_Array: TNumberPieceArray;
    class var FTen_Array: TNumberPieceArray;

    { Initialization }
    class constructor Create;
    class destructor Destroy;

    class function GetOne: BigCardinal; inline; static;
    class function GetTen: BigCardinal; inline; static;
    class function GetZero: BigCardinal; inline; static;
  var
    FLength: NativeUInt;

    [CloneKind(ckReference)]
    FArray: TNumberPieceArray;

    { Length utils }
    procedure SetLength(const ALength: NativeUInt); inline;
    procedure RemoveLeadingZeroes(); inline;

    { Internals }
    class function GetShiftedPiece(const A: BigCardinal; const Index, Count: NativeUInt): TNumberPiece; static; inline;
    procedure CalcModulus(const Divisor: BigCardinal; var Quotient: BigCardinal);
    procedure CopyPieces(var Dest; const Count: NativeUInt); inline;

{$HINTS OFF}
    procedure SetPieces(const Source; const Count: NativeUInt); inline;
{$HINTS ON}

    { For BCD support }
    function GetBCDDigitFrom(const Piece, Bit: NativeUInt): NativeUInt;
    function SetBCDDigitFrom(const Piece, Bit: NativeUInt; const Value: NativeUInt): NativeUInt;
    function BitLength(): NativeUInt;

    function ToBCD(): BigCardinal;

    { Property support }
    function GetIsEven: Boolean;
    function GetIsOdd: Boolean;
    function GetIsZero: Boolean;
  public
    ///  <summary>Initializes a <c>BigCardinal</c> with a given value.</summary>
    ///  <param name="ANumber">A <c>UInt64</c> value.</param>
    constructor Create(const ANumber: UInt64); overload;

    ///  <summary>Initializes a <c>BigCardinal</c> with a given value.</summary>
    ///  <param name="ANumber">An <c>Int64</c> value.</param>
    ///  <remarks><paramref name="ANumber"/> is treated as an unsigned number.</remarks>
    constructor Create(const ANumber: Int64); overload;

    ///  <summary>Initializes a <c>BigCardinal</c> with a given value.</summary>
    ///  <param name="ANumber">A <c>Cardinal</c> value.</param>
    constructor Create(const ANumber: Cardinal); overload;

    ///  <summary>Initializes a <c>BigCardinal</c> with a given value.</summary>
    ///  <param name="ANumber">An <c>Integer</c> value.</param>
    ///  <remarks><paramref name="ANumber"/> is treated as an unsigned number.</remarks>
    constructor Create(const ANumber: Integer); overload;

    ///  <summary>Initializes a <c>BigCardinal</c> with a given value.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to copy.</param>
    constructor Create(const ANumber: BigCardinal); overload;

    ///  <summary>Compares this <c>BigCardinal</c> to another <c>BigCardinal</c>.</summary>
    ///  <param name="ANumber">The <c>BigCardinal</c> value to compare with.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, this <c>BigCardinal</c> is less than <paramref name="ANumber"/>.
    ///  If the result is zero, this <c>BigCardinal</c> is equal to <paramref name="ANumber"/>. And finally,
    ///  if the result is greater than zero, this <c>BigCardinal</c> is greater than <paramref name="ANumber"/>.</returns>
    function CompareTo(const ANumber: BigCardinal): NativeInt;

    ///  <summary>Checks whether this <c>BigCardinal</c> is zero.</summary>
    ///  <returns><c>True</c> if this <c>BigCardinal</c> is zero; <c>False</c> otherwise.</returns>
    property IsZero: Boolean read GetIsZero;

    ///  <summary>Checks whether this <c>BigCardinal</c> is odd.</summary>
    ///  <returns><c>True</c> if this <c>BigCardinal</c> is odd; <c>False</c> otherwise.</returns>
    property IsOdd: Boolean read GetIsOdd;

    ///  <summary>Checks whether this <c>BigCardinal</c> is even.</summary>
    ///  <returns><c>True</c> if this <c>BigCardinal</c> is even; <c>False</c> otherwise.</returns>
    property IsEven: Boolean read GetIsEven;

    ///  <summary>Calculates the quotient and the remainder of a division operation.</summary>
    ///  <param name="ADivisor">A <c>BigCardinal</c> value to divide to.</param>
    ///  <param name="ARemainder">An output <c>BigCardinal</c> value containing the remainder.</param>
    ///  <returns>The quotient resulting from the division operation.</returns>
    ///  <exception cref="SysUtils|EDivByZero">If <paramref name="ADivisor"/> is zero.</exception>
    function DivMod(const ADivisor: BigCardinal; out ARemainder: BigCardinal): BigCardinal;

    ///  <summary>Raises a number to a specified power.</summary>
    ///  <param name="AExponent">A <c>NativeUInt</c> value that represents the exponent.</param>
    ///  <returns>The result of the exponentiation operation.</returns>
    function Pow(const AExponent: NativeUInt): BigCardinal;

    ///  <summary>Performs the <c>N^exp % M</c> operation.</summary>
    ///  <param name="AExponent">A <c>BigCardinal</c> value that represents the exponent.</param>
    ///  <param name="AModulus">A <c>BigCardinal</c> value that represents the modulus.</param>
    ///  <returns>The result of the operation.</returns>
    function ModPow(const AExponent: BigCardinal; const AModulus: BigCardinal): BigCardinal;

    ///  <summary>Tries to convert a string value to a <c>BigCardinal</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <param name="ABigCardinal">An output <c>BigCardinal</c> converted from the given string.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    ///  <remarks>Prefix the string with the '$' character to specify a hex value.</remarks>
    class function TryParse(const AString: string; out ABigCardinal: BigCardinal): Boolean; static;

    ///  <summary>Tries to convert a hex-string value to a <c>BigCardinal</c>.</summary>
    ///  <param name="AString">A hex-string value.</param>
    ///  <param name="ABigCardinal">An output <c>BigCardinal</c> converted from the given string.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    class function TryParseHex(const AString: string; out ABigCardinal: BigCardinal): Boolean; static;

    ///  <summary>Converts a string value to a <c>BigCardinal</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <returns>The converted <c>BigCardinal</c> value.</returns>
    ///  <remarks>Prefix the string with the '$' character to specify a hex value.</remarks>
    ///  <exception cref="SysUtils|EConvertError">The string does not represent a valid number.</exception>
    class function Parse(const AString: string): BigCardinal; static;

    ///  <summary>Converts a hex-string value to a <c>BigCardinal</c>.</summary>
    ///  <param name="AString">A hex-string value.</param>
    ///  <returns>The converted <c>BigCardinal</c> value.</returns>
    ///  <exception cref="SysUtils|EConvertError">The string does not represent a valid number.</exception>
    class function ParseHex(const AString: string): BigCardinal; static;

    ///  <summary>Converts this <c>BigCardinal</c> to a string value.</summary>
    ///  <returns>The string representation of this <c>BigCardinal</c>.</returns>
    function ToString(): string;

    ///  <summary>Converts this <c>BigCardinal</c> to a hex-string value.</summary>
    ///  <returns>The hex-string representation of this <c>BigCardinal</c>.</returns>
    function ToHexString(): string;

    ///  <summary>Converts this <c>BigCardinal</c> to a <c>Byte</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Byte</c> without
    ///  loss of precision.</remarks>
    function ToByte(): Byte; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to a <c>Word</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Word</c> without
    ///  loss of precision.</remarks>
    function ToWord(): Word; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to a <c>Cardinal</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Cardinal</c> without
    ///  loss of precision.</remarks>
    function ToCardinal(): Cardinal; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to a <c>UInt64</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>UInt64</c> without
    ///  loss of precision.</remarks>
    function ToUInt64(): UInt64; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to a <c>ShortInt</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Byte</c> without
    ///  loss of precision.</remarks>
    function ToShortInt(): ShortInt; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to a <c>SmallInt</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Word</c> without
    ///  loss of precision.</remarks>
    function ToSmallInt(): SmallInt; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to an <c>Integer</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Cardinal</c> without
    ///  loss of precision.</remarks>
    function ToInteger(): Integer; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to an <c>Int64</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>UInt64</c> without
    ///  loss of precision.</remarks>
    function ToInt64(): Int64; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to an <c>AnsiChar</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Byte</c> without
    ///  loss of precision.</remarks>
    function ToAnsiChar(): AnsiChar; inline;

    ///  <summary>Converts this <c>BigCardinal</c> to a <c>WideChar</c> value.</summary>
    ///  <returns>The less significant <c>Byte</c> of this <c>BigCardinal</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigCardinal</c> can be converted to a <c>Word</c> without
    ///  loss of precision.</remarks>
    function ToWideChar(): WideChar; inline;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ALeft">A <c>BigCardinal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigCardinal</c> value to compare to.</param>
    ///  <returns><c>True</c> if the values are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft, ARight: BigCardinal): Boolean;

    ///  <summary>Overloaded "<>" operator.</summary>
    ///  <param name="ALeft">A <c>BigCardinal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigCardinal</c> value to compare to.</param>
    ///  <returns><c>True</c> if the values are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ALeft, ARight: BigCardinal): Boolean;

    ///  <summary>Overloaded "&gt;" operator.</summary>
    ///  <param name="ALeft">A <c>BigCardinal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigCardinal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ALeft, ARight: BigCardinal): Boolean;

    ///  <summary>Overloaded "&gt;=" operator.</summary>
    ///  <param name="ALeft">A <c>BigCardinal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigCardinal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ALeft, ARight: BigCardinal): Boolean;

    ///  <summary>Overloaded "&lt;" operator.</summary>
    ///  <param name="ALeft">A <c>BigCardinal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigCardinal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ALeft, ARight: BigCardinal): Boolean;

    ///  <summary>Overloaded "&lt;=" operator.</summary>
    ///  <param name="ALeft">A <c>BigCardinal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigCardinal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ALeft, ARight: BigCardinal): Boolean;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">First <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">Second <c>BigCardinal</c> value.</param>
    ///  <returns>A <c>BigCardinal</c> value that contains the sum of the two values.</returns>
    class operator Add(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ALeft">First <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">Second <c>BigCardinal</c> value.</param>
    ///  <returns>A <c>BigCardinal</c> value that contains the difference of the two values.</returns>
    ///  <exception cref="SysUtils|EOverflow">If <paramref name="ALeft"/> is less than <paramref name="ARight"/>
    ///  and DeHL is compiled with the {$Q+} option.</exception>
    class operator Subtract(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "*" operator.</summary>
    ///  <param name="ALeft">First <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">Second <c>BigCardinal</c> value.</param>
    ///  <returns>A <c>BigCardinal</c> value that contains the product of the two values.</returns>
    class operator Multiply(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "div" operator.</summary>
    ///  <param name="ALeft">The dividend <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">The divisor <c>BigCardinal</c> value.</param>
    ///  <returns>A <c>BigCardinal</c> value that contains the quotient.</returns>
    ///  <exception cref="SysUtils|EDivByZero">If <paramref name="ARight"/> is zero.</exception>
    class operator IntDivide(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "mod" operator.</summary>
    ///  <param name="ALeft">The dividend <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">The divisor <c>BigCardinal</c> value.</param>
    ///  <returns>A <c>BigCardinal</c> value that contains the remainder.</returns>
    class operator Modulus(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded unary "-" operator.</summary>
    ///  <param name="AValue">A <c>BigCardinal</c> value.</param>
    ///  <returns>A <c>BigCardinal</c> value converted to complement of two.</returns>
    ///  <remarks>Even though this operation is allowed, it is not recommended to use it.</remarks>
    class operator Negative(const AValue: BigCardinal): BigCardinal;

    ///  <summary>Overloaded unary "+" operator.</summary>
    ///  <param name="AValue">A <c>BigCardinal</c> value.</param>
    ///  <returns>The same <c>BigCardinal</c> value.</returns>
    ///  <remarks>This operation is a nop.</remarks>
    class operator Positive(const AValue: BigCardinal): BigCardinal;

    ///  <summary>Overloaded unary "Inc" operator.</summary>
    ///  <param name="AValue">A <c>BigCardinal</c> value to increment by one.</param>
    ///  <returns>A <c>BigCardinal</c> value whose result is <c><paramref name="AValue"/> + 1</c>.</returns>
    class operator Inc(const AValue: BigCardinal): BigCardinal;

    ///  <summary>Overloaded unary "Dec" operator.</summary>
    ///  <param name="AValue">A <c>BigCardinal</c> value to decrement by one.</param>
    ///  <returns>A <c>BigCardinal</c> value whose result is <c><paramref name="AValue"/> - 1</c>.</returns>
    ///  <exception cref="SysUtils|EOverflow">If <paramref name="ALeft"/> is zero and DeHL is compiled with the {$Q+} option.</exception>
    class operator Dec(const AValue: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "shl" operator.</summary>
    ///  <param name="AValue">A <c>BigCardinal</c> value to shift left.</param>
    ///  <param name="ACount">The number of bits to shift left by.</param>
    ///  <returns>A new shifted <c>BigCardinal</c>.</returns>
    ///  <remarks>Because a <c>BigCardinal</c> has no limit in size, this operation does not wrap at a certain bit length.</remarks>
    class operator LeftShift(const AValue: BigCardinal; const ACount: NativeUInt): BigCardinal;

    ///  <summary>Overloaded "shr" operator.</summary>
    ///  <param name="AValue">A <c>BigCardinal</c> value to shift right.</param>
    ///  <param name="ACount">The number of bits to shift right by.</param>
    ///  <returns>A new shifted <c>BigCardinal</c>.</returns>
    ///  <remarks>If <paramref name="ACount"/> is greater than the bit length of this <c>BigCardinal</c>, zero is obtained.</remarks>
    class operator RightShift(const AValue: BigCardinal; const ACount: NativeUInt): BigCardinal;

    ///  <summary>Overloaded "and" operator.</summary>
    ///  <param name="ALeft">The first <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">The second <c>BigCardinal</c> value.</param>
    ///  <returns>The result of the <c>and</c> operation.</returns>
    ///  <remarks>If the bit length of the two numbers is different, zeros are assumed for the missing length. This means
    ///  that a longer number will get some of its most significant bits set to zero.</remarks>
    class operator BitwiseAnd(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded unary "not" operator.</summary>
    ///  <param name="AValue">A <c>BigCardinal</c> value to invert bit-by-bit.</param>
    ///  <returns>A <c>BigCardinal</c> value whose bits are inverted.</returns>
    class operator LogicalNot(const AValue: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "or" operator.</summary>
    ///  <param name="ALeft">The first <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">The second <c>BigCardinal</c> value.</param>
    ///  <returns>The result of the <c>or</c> operation.</returns>
    ///  <remarks>If the bit length of the two numbers is different, zeros are assumed for the missing length.</remarks>
    class operator BitwiseOr(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "xor" operator.</summary>
    ///  <param name="ALeft">The first <c>BigCardinal</c> value.</param>
    ///  <param name="ARight">The second <c>BigCardinal</c> value.</param>
    ///  <returns>The result of the <c>xor</c> operation.</returns>
    ///  <remarks>If the bit length of the two numbers is different, zeros are assumed for the missing length.</remarks>
    class operator BitwiseXor(const ALeft, ARight: BigCardinal): BigCardinal;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Byte</c> value to convert.</param>
    ///  <returns>A <c>BigCardinal</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Byte): BigCardinal;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Word</c> value to convert.</param>
    ///  <returns>A <c>BigCardinal</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Word): BigCardinal;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Byte</c> value to convert.</param>
    ///  <returns>A <c>BigCardinal</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Cardinal): BigCardinal;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>UInt64</c> value to convert.</param>
    ///  <returns>A <c>BigCardinal</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: UInt64): BigCardinal;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>A <c>Variant</c> value containing the converted value.</returns>
    ///  <remarks>The returned <c>Variant</c> contains a custom variant type.</remarks>
    class operator Implicit(const ANumber: BigCardinal): Variant;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>A <c>ShortInt</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigCardinal): ShortInt;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>A <c>SmallInt</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigCardinal): SmallInt;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>An <c>Integer</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigCardinal): Integer;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>An <c>Int64</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigCardinal): Int64;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>An <c>AnsiChar</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigCardinal): AnsiChar;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>A <c>WideChar</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigCardinal): WideChar;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>Variant</c> value to convert.</param>
    ///  <returns>A <c>BigCardinal</c> value containing the converted value.</returns>
    ///  <remarks>This method may raise various exceptions if the provided <c>Variant</c>
    ///  cannot be converted properly.</remarks>
    class operator Explicit(const ANumber: Variant): BigCardinal;

    ///  <summary>Specifies the ID of the <c>Variant</c> values containing a <c>BigCardinal</c>.</summary>
    ///  <returns>A <c>TVarType</c> value that specifies the ID.</returns>
    ///  <remarks>Use this value to identify <c>Variant</c>s that contain <c>BigCardinal</c> values.</remarks>
    class property VarType: TVarType read FVarType;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents the
    ///  <see cref="DeHL.Math.BigCardinal|BigCardinal">DeHL.Math.BigCardinal.BigCardinal</see> type.</returns>
    class function GetType(): IType<BigCardinal>; static;

    ///  <summary>Returns <c>0</c>.</summary>
    ///  <returns>A <c>BigCardinal</c> value containing 0.</returns>
    class property Zero: BigCardinal read GetZero;

    ///  <summary>Returns <c>1</c>.</summary>
    ///  <returns>A <c>BigCardinal</c> value containing 1.</returns>
    class property One: BigCardinal read GetOne;

    ///  <summary>Returns <c>10</c>.</summary>
    ///  <returns>A <c>BigCardinal</c> value containing 10.</returns>
    class property Ten: BigCardinal read GetTen;
  end;

implementation

{ Disable overflow-cheks! but preserve the value first }
{$IFOPT Q+}
{$DEFINE BIGCARDINAL_OVERFLOW_CHECKS}
{$ENDIF}

{$Q-}

type
  { BigCardinal Support }
  TBigCardinalType = class(TRecordType<BigCardinal>)
  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: BigCardinal; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: BigCardinal; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: BigCardinal): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: BigCardinal): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: BigCardinal): String; override;

    { Type information }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: BigCardinal; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: BigCardinal): Boolean; override;
  end;

  { Math extensions for the BigCardinal type }
  TBigCardinalMathExtension = class sealed(TUnsignedIntegerMathExtension<BigCardinal>)
  public
    { Standard operations }
    function Add(const AValue1, AValue2: BigCardinal): BigCardinal; override;
    function Subtract(const AValue1, AValue2: BigCardinal): BigCardinal; override;
    function Multiply(const AValue1, AValue2: BigCardinal): BigCardinal; override;
    function IntegralDivide(const AValue1, AValue2: BigCardinal): BigCardinal; override;
    function Modulo(const AValue1, AValue2: BigCardinal): BigCardinal; override;

    { Neutral Math elements }
    function Zero: BigCardinal; override;
    function One: BigCardinal; override;
  end;


{ Utility functions }

procedure Fill4BitDigits(var S: String; const Value: BigCardinal);
const
  Digits: array[$0..$F] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8',
    '9', 'A', 'B', 'C', 'D', 'E', 'F');

var
  PieceBytes: array[0..(BigCardinal.BytesInPiece - 1)] of Byte;
  Piece: BigCardinal.TNumberPiece absolute PieceBytes;

  I, X: NativeUInt;
begin
  SetLength(S, Value.FLength * (BigCardinal.BytesInPiece * 2));

  for I := 0 to Value.FLength - 1 do
  begin
    Piece := Value.FArray[I];
    X := (Value.FLength - 1 - I) * (BigCardinal.BytesInPiece * 2);

    S[X + 8] := Digits[(PieceBytes[0] and $F)];
    S[X + 7] := Digits[(PieceBytes[0] shr 4)];

    S[X + 6] := Digits[(PieceBytes[1] and $F)];
    S[X + 5] := Digits[(PieceBytes[1] shr 4)];

    S[X + 4] := Digits[(PieceBytes[2] and $F)];
    S[X + 3] := Digits[(PieceBytes[2] shr 4)];

    S[X + 2] := Digits[(PieceBytes[3] and $F)];
    S[X + 1] := Digits[(PieceBytes[3] shr 4)];
  end;
end;

function TrimLeftZeros(const Str: String): String; inline;
var
  I, X: NativeUInt;
begin
  Result := Str;

  if Str = '' then
    Exit;

  X := 0;

  for I := 1 to Length(Str) do
  begin
    if Str[I] <> '0' then
    begin
      X := I - 1;
      break;
    end;
  end;

  if X > 0 then
    Delete(Result, 1, X);
end;

{ Variant Support }

type
  PBigCardinal = ^BigCardinal;

  { Mapping the BigCardinal into TVarData structure }
  TBigCardinalVarData = packed record
    { Var type, will be assigned at runtime }
    VType: TVarType;
    { Reserved stuff }
    Reserved1, Reserved2, Reserved3: Word;
    { A reference to the enclosed big cardinal }
    BigCardinalPtr: PBigCardinal;
    { Reserved stuff }
    Reserved4: LongWord;
  end;

  { Manager for our variant type }
  TBigCardinalVariantType = class(TCustomVariantType)
  private
    { Will create a big cardinal, or raise an error }
    function VarDataToBigCardinal(const Value: TVarData): BigCardinal;
    procedure BigCardinalToVarData(const Value: BigCardinal; var OutValue: TVarData);
  public
    procedure Clear(var V: TVarData); override;
    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean); override;
    procedure Cast(var Dest: TVarData; const Source: TVarData); override;
    procedure CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType); override;
    procedure BinaryOp(var Left: TVarData; const Right: TVarData; const Operator: TVarOp); override;
    procedure UnaryOp(var Right: TVarData; const Operator: TVarOp); override;
    procedure Compare(const Left, Right: TVarData; var Relationship: TVarCompareResult); override;
    function IsClear(const V: TVarData): Boolean; override;
  end;

var
  { Our singleton that manages tour variant types }
  SgtBigCardinalVariantType: TBigCardinalVariantType;


{ TBigCardinalVariantType }

procedure TBigCardinalVariantType.BinaryOp(var Left: TVarData; const Right: TVarData; const &Operator: TVarOp);
begin
  { Select the appropriate operation }
  case &Operator of
    opAdd:
      BigCardinalToVarData(VarDataToBigCardinal(Left) + VarDataToBigCardinal(Right), Left);
    opAnd:
      BigCardinalToVarData(VarDataToBigCardinal(Left) and VarDataToBigCardinal(Right), Left);
    opIntDivide:
      BigCardinalToVarData(VarDataToBigCardinal(Left) div VarDataToBigCardinal(Right), Left);
    opModulus:
      BigCardinalToVarData(VarDataToBigCardinal(Left) mod VarDataToBigCardinal(Right), Left);
    opMultiply:
      BigCardinalToVarData(VarDataToBigCardinal(Left) * VarDataToBigCardinal(Right), Left);
    opOr:
      BigCardinalToVarData(VarDataToBigCardinal(Left) or VarDataToBigCardinal(Right), Left);
    opShiftLeft:
      BigCardinalToVarData(VarDataToBigCardinal(Left) shl VarDataToBigCardinal(Right), Left);
    opShiftRight:
      BigCardinalToVarData(VarDataToBigCardinal(Left) shr VarDataToBigCardinal(Right), Left);
    opSubtract:
      BigCardinalToVarData(VarDataToBigCardinal(Left) - VarDataToBigCardinal(Right), Left);
    opXor:
      BigCardinalToVarData(VarDataToBigCardinal(Left) xor VarDataToBigCardinal(Right), Left);
  else
    RaiseInvalidOp;
  end;
end;

procedure TBigCardinalVariantType.Cast(var Dest: TVarData; const Source: TVarData);
begin
  { Cast the source to our cardinal type }
  VarDataInit(Dest);
  BigCardinalToVarData(VarDataToBigCardinal(Source), Dest);
end;

procedure TBigCardinalVariantType.CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType);
var
  Big: BigCardinal;
  Temp: TVarData;
  WStr: WideString;
begin
  if Source.VType = VarType then
  begin
    { Only continue if we're invoked for our data type }
    Big := TBigCardinalVarData(Source).BigCardinalPtr^;

    { Initilize the destination }
    VarDataInit(Dest);
    Dest.VType := AVarType;

    case AVarType of
      varByte:
        Dest.VByte := Big.ToByte();

      varShortInt:
        Dest.VShortInt := Big.ToShortInt();

      varWord:
        Dest.VWord := Big.ToWord();

      varSmallint:
        Dest.VSmallInt := Big.ToSmallInt();

      varInteger:
        Dest.VInteger := Big.ToInteger();

      varLongWord:
        Dest.VLongWord := Big.ToCardinal();

      varUInt64:
        Dest.VUInt64 := Big.ToUInt64();

      varInt64:
        Dest.VInt64 := Big.ToInt64();

      varOleStr:
      begin
        { Clear out the type to avoid the deep clear! }
        Dest.VType := 0;
        WStr := Big.ToString();
        VarDataFromOleStr(Dest, WStr);
      end;

      varString:
      begin
        { Clear out the type to avoid the deep clear! }
        Dest.VType := 0;
        VarDataFromLStr(Dest, AnsiString(Big.ToString()));
      end;

      varUString:
      begin
        { Clear out the type to avoid the deep clear! }
        Dest.VType := 0;
        VarDataFromStr(Dest, Big.ToString());
      end

      else
      begin
        { No default convertion found! Trying to use the string }
        try
          VarDataInit(Temp);
          VarDataFromStr(Temp, Big.ToString());
          VarDataCastTo(Dest, Temp, AVarType);
        finally
          { Dispose our variant }
          VarDataClear(Temp);
        end;
      end;
    end;
  end else
    inherited;
end;

procedure TBigCardinalVariantType.Clear(var V: TVarData);
begin
  { Clear the variant type }
  V.VType := varEmpty;

  { And dispose the value }
  Dispose(TBigCardinalVarData(V).BigCardinalPtr);
  TBigCardinalVarData(V).BigCardinalPtr := nil;
end;

procedure TBigCardinalVariantType.Compare(const Left, Right: TVarData; var Relationship: TVarCompareResult);
var
  Res: NativeInt;
begin
  { Compare these values }
  Res := VarDataToBigCardinal(Left).CompareTo(VarDataToBigCardinal(Right));

  { Return the compare result }
  if Res < 0 then
    Relationship := crLessThan
  else if Res > 0 then
    Relationship := crGreaterThan
  else
    Relationship := crEqual;
end;

procedure TBigCardinalVariantType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
    VarDataCopyNoInd(Dest, Source)
  else
  begin
    with TBigCardinalVarData(Dest) do
    begin
      { Copy the variant type }
      VType := VarType;

      { Initialize the pointer }
      New(BigCardinalPtr);

      { Copy by value }
      BigCardinalPtr^ := TBigCardinalVarData(Source).BigCardinalPtr^;
    end;
  end;
end;

function TBigCardinalVariantType.IsClear(const V: TVarData): Boolean;
begin
  if V.VType = varEmpty then
    Exit(true);

  { Signal clear value }
  Result := (TBigCardinalVarData(V).BigCardinalPtr = nil);
end;

procedure TBigCardinalVariantType.UnaryOp(var Right: TVarData; const &Operator: TVarOp);
begin
  { Select the appropriate operation }
  case &Operator of
    opNegate:
      BigCardinalToVarData(-VarDataToBigCardinal(Right), Right);
    opNot:
      BigCardinalToVarData(not VarDataToBigCardinal(Right), Right);
  else
    RaiseInvalidOp;
  end;
end;

function TBigCardinalVariantType.VarDataToBigCardinal(const Value: TVarData): BigCardinal;
begin
  { Check if the var data has a big cardinal inside }
  if Value.VType = VarType then
  begin
    { Copy the value to result }
    Exit(TBigCardinalVarData(Value).BigCardinalPtr^);
  end;

  { OK, try to convert the incoming var type to somethin useful }
  case Value.VType of
    varByte:
      Result := Value.VByte;

    varShortInt:
      Result := Value.VShortInt;

    varWord:
      Result := Value.VWord;

    varSmallint:
      Result := Value.VSmallInt;

    varInteger:
      Result := Value.VInteger;

    varLongWord:
      Result := Value.VLongWord;

    varUInt64:
      Result := Value.VUInt64;

    varInt64:
      Result := Value.VInt64;

    varString, varUString, varOleStr:
    begin
      { Be careful here, a string may not be a good number }
      if not BigCardinal.TryParse(VarDataToStr(Value), Result) then
        RaiseCastError;
    end;

    else
      RaiseCastError;
  end;
end;

procedure TBigCardinalVariantType.BigCardinalToVarData(const Value: BigCardinal; var OutValue: TVarData);
begin
  { Dispose of the old value. Check it it's ours first }
  if OutValue.VType = VarType then
    Clear(OutValue)
  else
    VarDataClear(OutValue);

  with TBigCardinalVarData(OutValue) do
  begin
    { Assign the new variant the var type that was allocated for us }
    VType := VarType;

    { Allocate space for our big cardinal pointer }
    New(BigCardinalPtr);

    { Copy self to this memory }
    BigCardinalPtr^ := Value;
  end;
end;


{ BigCardinal }

class operator BigCardinal.Add(const ALeft, ARight: BigCardinal): BigCardinal;
var
  I: NativeUInt;
  A, B: ^BigCardinal;
  Temp: TNumberPiece;
  CarryIn, CarryOut: Boolean;
begin
  { Check for zeroes }
  if (ALeft.FArray = nil) and (ARight.FArray = nil) then
  begin
    Result := Zero;
    Exit;
  end;

  if ALeft.FArray = nil then
  begin
    Result := ARight;
    Exit;
  end;

  if ARight.FArray = nil then
  begin
    Result := ALeft;
    Exit;
  end;

  { Get the maximum length }
  if ALeft.FLength >= ARight.FLength then
    begin A := @ALeft; B := @ARight; end
  else
    begin A := @ARight; B := @ALeft; end;

  { Initialize Result }
  Result.SetLength(A.FLength + 1);

  CarryIn := False;

	for I := 0 to B.FLength - 1 do
  begin
    { Disable overflow check in this code! }
    Temp := A.FArray[I] + B.FArray[I];

		CarryOut := (Temp < A.FArray[I]);

		if CarryIn then
    begin
      Inc(Temp);
      CarryOut := CarryOut or (Temp = 0);
    end;

		Result.FArray[I] := Temp;
		CarryIn := CarryOut;
  end;

  I := B.FLength;

  { Resolve carry }
  while (I < A.FLength) and (CarryIn) do
  begin
    Temp := A.FArray[I] + 1;
		CarryIn := (Temp = 0);
		Result.FArray[I] := Temp;

    { Increase the control variable }
    Inc(I);
  end;

  { Copy remaining cards }
  while (I < A.FLength) do
  begin
    Result.FArray[I] := A.FArray[I];
    { Increase the control variable }
    Inc(I);
  end;

  { Resolve carry }
	if (CarryIn) then
		Result.FArray[I] := 1
	else
		Dec(Result.FLength);
end;

class operator BigCardinal.BitwiseAnd(const ALeft, ARight: BigCardinal): BigCardinal;
var
  I: NativeUInt;
begin
  { Init result }
  Result := Zero;

  { In case of one 0 bad things happen }
  if (ALeft.FArray = nil) or (ARight.FArray = nil) then
    Exit;

  { Select the shortest int }
  if ALeft.FLength >= ARight.FLength then
    Result.SetLength(ARight.FLength)
  else
    Result.SetLength(ALeft.FLength);

	for I := 0 to Result.FLength - 1 do
		Result.FArray[I] := ALeft.FArray[I] and ARight.FArray[I];

  { Remove zeroes }
  Result.RemoveLeadingZeroes();
end;

class operator BigCardinal.LogicalNot(const AValue: BigCardinal): BigCardinal;
var
  I: NativeInt;
  X: TNumberPiece;
begin
  { Special case = nil }
  if AValue.FArray = nil then
  begin
    Result.SetLength(1);
    X := 0;
    Result.FArray[0] := not X;
    Exit;
  end;

  Result.SetLength(AValue.FLength);

  { Do the NOT operation }
  for I := 0 to AValue.FLength - 1 do
    Result.FArray[I] := not AValue.FArray[I];

  { Cleanup what remains }
  Result.RemoveLeadingZeroes();
end;

class operator BigCardinal.BitwiseOr(const ALeft, ARight: BigCardinal): BigCardinal;
var
  I: NativeUInt;
  A, B: ^BigCardinal;

begin
  { In case of one 0 nothing happens }
  if ALeft.FArray = nil then
  begin
    Result := ARight;
    Exit;
  end;

  if ARight.FArray = nil then
  begin
    Result := ALeft;
    Exit;
  end;

	if (ALeft.FLength >= ARight.FLength) then
  begin
		A := @ALeft;
		B := @ARight;
	end else
  begin
		A := @ARight;
		B := @ALeft;
	end;

  { Initialize Result }
  Result.SetLength(A.FLength);

  { Do the OR operation }
	for I := 0 to B.FLength - 1 do
		Result.FArray[I] := A.FArray[I] or B.FArray[I];

  { And continue further ... }
  I := B.FLength;

  while I < A.FLength do
  begin
    Result.FArray[I] := A.FArray[I];
    Inc(I);
  end;

  Result.FLength := A.FLength;
end;

class operator BigCardinal.BitwiseXor(const ALeft, ARight: BigCardinal): BigCardinal;
var
  I: NativeUInt;
  A, B: ^BigCardinal;

begin
  { In case of one 0 nothing happens }
  if ALeft.FArray = nil then
  begin
    Result := ARight;
    Exit;
  end;

  if ARight.FArray = nil then
  begin
    Result := ALeft;
    Exit;
  end;

	if (ALeft.FLength >= ARight.FLength) then
  begin
		A := @ALeft;
		B := @ARight;
	end else
  begin
		A := @ARight;
		B := @ALeft;
	end;

  { Initialize Result }
  Result.SetLength(A.FLength + 1);

  { Do the XOR operation }
	for I := 0 to B.FLength - 1 do
		Result.FArray[I] := A.FArray[I] xor B.FArray[I];

  { And continue further ... }
  I := B.FLength;

  while I < A.FLength do
  begin
    Result.FArray[I] := A.FArray[I];
    Inc(I);
  end;

  { Possible zeroes }
  Result.RemoveLeadingZeroes();
end;

function BigCardinal.CompareTo(const ANumber: BigCardinal): NativeInt;
var
  I: NativeInt;
begin
  if FLength < ANumber.FLength then
    Exit(-1)
  else if FLength > ANumber.FLength then
    Exit(1)
  else if FLength > 0 then
  begin
    { Check from the most important card to the less one }
    for I := FLength - 1 downto 0 do
    begin
      { Retun on two conditions if required }
      if FArray[I] > ANumber.FArray[I] then
        Exit(1)
      else if FArray[I] < ANumber.FArray[I] then
        Exit(-1);
    end;
  end;

  { Equality }
  Result := 0;
end;

procedure BigCardinal.CopyPieces(var Dest; const Count: NativeUInt);
var
  RealCount: NativeUInt;
begin
  FillChar(Dest, Count, 0);

  { Do nothing }
  if FArray = nil then
    Exit;

  { Find out what length is good }
  if (FLength * BytesInPiece) < Count then
    RealCount := FLength * BytesInPiece
  else
    RealCount := Count;

  { And now do a move operation }
  Move(FArray[0], Dest, RealCount);
end;

constructor BigCardinal.Create(const ANumber: BigCardinal);
begin
  { Just copy! }
  Self := ANumber;
end;

class constructor BigCardinal.Create;
begin
  { DeHL type support stuff }
  TType<BigCardinal>.Register(TBigCardinalType);
  TMathExtension<BigCardinal>.Register(TBigCardinalMathExtension);

  { Register our custom variant type }
  SgtBigCardinalVariantType := TBigCardinalVariantType.Create();
  FVarType := SgtBigCardinalVariantType.VarType;

  { Initialize locals }
  FOne_Array := BigCardinal(1).FArray;
  FTen_Array := BigCardinal(10).FArray;
end;

constructor BigCardinal.Create(const ANumber: Int64);
begin
  if ANumber <> 0 then
  begin
{$IF SizeOf(TNumberPiece) >= SizeOf(Int64)}
    System.SetLength(FArray, 1);
    FArray[0] := ANumber;
    FLength := 1;
{$ELSEIF (SizeOf(TNumberPiece) * 2) = SizeOf(Int64)}
    System.SetLength(FArray, 2);
    FArray[0] := ANumber and $00000000FFFFFFFF;
    FArray[1] := ANumber shr BitsInPiece;
    FLength := 2;
{$ELSE}
    SetPieces(ANumber, SizeOf(Int64));
{$IFEND}

    { Cleanup afterwards }
    RemoveLeadingZeroes();
  end else
    Self := Zero;
end;

constructor BigCardinal.Create(const ANumber: Integer);
begin
  if ANumber <> 0 then
  begin
{$IF SizeOf(TNumberPiece) >= SizeOf(Integer)}
    System.SetLength(FArray, 1);
    FArray[0] := ANumber;
    FLength := 1;
{$ELSE}
    SetPieces(ANumber, SizeOf(Integer));
{$IFEND}

    { Cleanup afterwards }
    RemoveLeadingZeroes();
  end
  else
    Self := Zero;
end;

class operator BigCardinal.Dec(const AValue: BigCardinal): BigCardinal;
begin
  { Simply decrease 1 }
  Result := AValue - 1;
end;

class destructor BigCardinal.Destroy;
begin
  { Unregister DeHL stuff (math extension goes first) }
  TMathExtension<BigCardinal>.Unregister;
  TType<BigCardinal>.Unregister;

  { Uregister our custom variant }
  FreeAndNil(SgtBigCardinalVariantType);
end;

function BigCardinal.DivMod(const ADivisor: BigCardinal; out ARemainder: BigCardinal): BigCardinal;
begin
  { Ensure everything is allocated }
  System.SetLength(ARemainder.FArray, FLength);
  ARemainder.FLength := FLength;
  Move(FArray[0], ARemainder.FArray[0], FLength * BytesInPiece);

  ARemainder.CalcModulus(ADivisor, Result);
end;

class operator BigCardinal.Implicit(const ANumber: BigCardinal): Variant;
begin
  { Clear out the result }
  VarClear(Result);

  with TBigCardinalVarData(Result) do
  begin
    { Assign the new variant the var type that was allocated for us }
    VType := FVarType;

    { Allocate space for our big cardinal pointer }
    New(BigCardinalPtr);

    { Copy self to this memory }
    BigCardinalPtr^ := ANumber;
  end;
end;

class operator BigCardinal.Inc(const AValue: BigCardinal): BigCardinal;
begin
  { Simply increase 1 }
  Result := AValue + 1;
end;

class operator BigCardinal.IntDivide(const ALeft, ARight: BigCardinal): BigCardinal;
var
  R: BigCardinal;
begin
  { Ensure everything is allocated }
  System.SetLength(R.FArray, ALeft.FLength);
  R.FLength := ALeft.FLength;
  Move(ALeft.FArray[0], R.FArray[0], ALeft.FLength * BytesInPiece);

  R.CalcModulus(ARight, Result);
end;

constructor BigCardinal.Create(const ANumber: UInt64);
begin
  if ANumber <> 0 then
  begin
{$IF SizeOf(TNumberPiece) >= SizeOf(UInt64)}
    System.SetLength(FArray, 1);
    FArray[0] := ANumber;
    FLength := 1;
{$ELSEIF (SizeOf(TNumberPiece) * 2) = SizeOf(UInt64)}
    System.SetLength(FArray, 2);
    FArray[0] := ANumber and $00000000FFFFFFFF;
    FArray[1] := ANumber shr BitsInPiece;
    FLength := 2;
{$ELSE}
    SetPieces(ANumber, SizeOf(UInt64));
{$IFEND}

    { Cleanup afterwards }
    RemoveLeadingZeroes();
  end else
    Self := Zero;
end;

constructor BigCardinal.Create(const ANumber: Cardinal);
begin
  if ANumber <> 0 then
  begin
{$IF SizeOf(TNumberPiece) >= SizeOf(Cardinal)}
    System.SetLength(FArray, 1);
    FArray[0] := ANumber;
    FLength := 1;
{$ELSE}
    SetPieces(ANumber, SizeOf(Cardinal));
{$IFEND}

    { Cleanup afterwards }
    RemoveLeadingZeroes();
  end else
    Self := Zero;
end;

procedure BigCardinal.SetLength(const ALength: NativeUInt);
begin
  { Assuming that all is initialized }
  System.SetLength(FArray, ALength);
  FLength := ALength;
  FillChar(FArray[0], BytesInPiece * ALength, 0);
end;

procedure BigCardinal.SetPieces(const Source; const Count: NativeUInt);
var
  IncSize: NativeUInt;
begin
  ASSERT(Count > 0);

  { Decide the new size of the array }
  IncSize := (Count div BytesInPiece);

  if (Count mod BytesInPiece) > 0 then
    Inc(IncSize);

  { Set the required length }
  SetLength(IncSize);

  { Copy the value in }
  Move(Source, FArray[0], Count);
end;

function BigCardinal.BitLength(): NativeUInt;
var
  I, X: NativeUInt;
begin
  { Do nothing on 0 length }
  if (FArray = nil) or (FLength = 0) then
    Exit(0);

  Result := FLength * BitsInPiece;

  for I := FLength - 1 to 0 do
  begin
    if FArray[I] = 0 then
      Dec(Result, BitsInPiece)
    else
    begin
      { Not an empty piece, Let's check the real last bit }
      for X := BitsInPiece - 1 downto 0 do
      begin
        { Fount a bit here, consider this to be the bit length }
        if (FArray[I] and (1 shl X)) <> 0 then
        begin
          Dec(Result, BitsInPiece - X - 1);
          Exit;
        end;
      end;
    end;
  end;
end;

function BigCardinal.GetBCDDigitFrom(const Piece, Bit: NativeUInt): NativeUInt;
const
  Offsets: array[1..3] of NativeUInt = (1, 3, 7);
var
  Overflow: NativeUInt;
begin
  { In case of no overflow do the usual }
  if (Bit <= (BitsInPiece - BCDDigitBits)) or (Piece = (FLength - 1)) then
    Exit((FArray[Piece] shr Bit) and BCDMask);

  { Calculate the overflow }
  Overflow := Bit - (BitsInPiece - BCDDigitBits);

  { Get the normal part and the overflowed }
  Result := (FArray[Piece] shr Bit) or ((FArray[Piece + 1] and Offsets[Overflow]) shl (BCDDigitBits - Overflow));
end;

function BigCardinal.GetIsEven: Boolean;
begin
  Result := (System.Length(FArray) = 0) or
            ((System.Length(FArray) > 0) and
            (FLength > 0) and
            ((FArray[0] and 1) = 0));
end;

function BigCardinal.GetIsOdd: Boolean;
begin
  Result := not GetIsEven;
end;

function BigCardinal.GetIsZero: Boolean;
begin
  Result := (FLength = 0) or (System.Length(FArray) = 0);
end;

class function BigCardinal.GetOne: BigCardinal;
begin
  { 0, [10] }
  Result.FLength := 1;
  Result.FArray := FOne_Array;
end;

function BigCardinal.SetBCDDigitFrom(const Piece, Bit: NativeUInt; const Value: NativeUInt): NativeUInt;
const
  Offsets: array[1..3] of NativeUInt = (1, 3, 7);

var
  Overflow: NativeUInt;
begin
  Result := 0;

  { In case of no overflow do the usual }
  if (Bit <= (BitsInPiece - BCDDigitBits)) then
  begin
    FArray[Piece] := (FArray[Piece] and (not (BCDMask shl Bit))) or (Value shl Bit);
    Exit;
  end;

  { Calculate the overflow }
  Overflow := Bit - (BitsInPiece - BCDDigitBits);

  if (Piece = (FLength - 1)) then
  begin
    { We must extend the array! }
    System.SetLength(FArray, FLength + 1);
    FLength := FLength + 1;

    { Set the overflowed bits }
    Result := BitsInPiece;
  end;

  { Set the normal part first }
  FArray[Piece] := (FArray[Piece] and (not (BCDMask shl Bit))) or (Value shl Bit);
  FArray[Piece + 1] := (FArray[Piece + 1] and (not Offsets[Overflow])) or (Value shr (BCDDigitBits - Overflow));
end;

function BigCardinal.ToBCD(): BigCardinal;
var
  TotalBits: NativeUInt;
  I, J: NativeUInt;
  PieceIdx: NativeUInt;
  BCDDigit, StartBit: NativeUInt;

begin
  { Check array length first }
  if (FArray = nil) or (FLength = 0) then
     Exit;

  { Create a copy of Self }
  Result.SetLength(FLength);
  Move(FArray[0], Result.FArray[0], FLength * BytesInPiece);

  { Calculate the total number of bits }
  TotalBits := Result.BitLength();// FLength * BitsInPiece;

  { Iterate over all bits: Start at high and do not continue till the last bit! }
  for I := TotalBits - 1 downto 1 do
  begin
    { Start the BCD normalization cycle at the moving bit }
    J := I;

    while J <= (TotalBits - 1) do
    begin
      { Gather all info }
      PieceIdx := J div BitsInPiece;
      StartBit := J mod BitsInPiece;

      { Get the BCD Digit at starting point }
      { check for inter-piece BCDs }
      BCDDigit := Result.GetBCDDigitFrom(PieceIdx, StartBit);

      { If the digit >= 5 add 3 to it! }
      if BCDDigit >= 5 then
      begin
        { Add the number of bits }
        BCDDigit := BCDDigit + 3;

        { Set the BCD back and extend if necessary }
        Result.SetBCDDigitFrom(PieceIdx, StartBit, BCDDigit);

        { Is this the last iteration for this shift stage? If Yes, recalculate the bit length once again }
        if ((J + BCDDigitBits) > (TotalBits - 1)) then
          TotalBits := Result.BitLength();
      end;

      Inc(J, BCDDigitBits);
    end;
  end;

  { Remove leading 0's }
  Result.RemoveLeadingZeroes();
end;

class operator BigCardinal.Equal(const ALeft, ARight: BigCardinal): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) = 0);
end;

class operator BigCardinal.Explicit(const ANumber: BigCardinal): ShortInt;
begin
  { Call convertion code }
  Result := ANumber.ToShortInt();
end;

class operator BigCardinal.Explicit(const ANumber: BigCardinal): AnsiChar;
begin
  { Call convertion code }
  Result := ANumber.ToAnsiChar();
end;

class operator BigCardinal.Explicit(const ANumber: BigCardinal): WideChar;
begin
  { Call convertion code }
  Result := ANumber.ToWideChar();
end;

class operator BigCardinal.Explicit(const ANumber: BigCardinal): Int64;
begin
  { Call convertion code }
  Result := ANumber.ToInt64();
end;

class operator BigCardinal.Explicit(const ANumber: BigCardinal): SmallInt;
begin
  { Call convertion code }
  Result := ANumber.ToSmallInt();
end;

class operator BigCardinal.Explicit(const ANumber: BigCardinal): Integer;
begin
  { Call convertion code }
  Result := ANumber.ToInteger();
end;

class function BigCardinal.GetShiftedPiece(const A: BigCardinal; const Index, Count: NativeUInt): TNumberPiece;
var
  P1, P2: TNumberPiece;
begin
  { Calculate part 1 }
  if (Index = 0) or (Count = 0) then
    P1 := 0
  else
    P1 := (A.FArray[Index - 1] shr (BitsInPiece - Count));

  { Calculate part 2 }
  if (Index = A.FLength) then
    P2 := 0
  else
    P2 := (A.FArray[Index] shl Count);

  { Cumulate part 1 and 2 }
	Result := P1 or P2;
end;

class function BigCardinal.GetTen: BigCardinal;
begin
  { 0, [10] }
  Result.FLength := 1;
  Result.FArray := FTen_Array;
end;

class function BigCardinal.GetType: IType<BigCardinal>;
begin
  Result := TBigCardinalType.Create();
end;

class function BigCardinal.GetZero: BigCardinal;
begin
  { 0, nil }
  Result.FLength := 0;
  Result.FArray := nil;
end;

class operator BigCardinal.GreaterThan(const ALeft, ARight: BigCardinal): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) > 0);
end;

class operator BigCardinal.GreaterThanOrEqual(const ALeft, ARight: BigCardinal): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) >= 0);
end;

class operator BigCardinal.Implicit(const ANumber: Word): BigCardinal;
begin
  { Simply call ctor }
  Result := BigCardinal.Create(ANumber);
end;

class operator BigCardinal.Implicit(const ANumber: Byte): BigCardinal;
begin
  { Simply call ctor }
  Result := BigCardinal.Create(ANumber);
end;

class operator BigCardinal.Implicit(const ANumber: UInt64): BigCardinal;
begin
  { Simply call ctor }
  Result := BigCardinal.Create(ANumber);
end;

class operator BigCardinal.LeftShift(const AValue: BigCardinal; const ACount: NativeUInt): BigCardinal;
var
  ShiftedPieces: NativeUInt;
  ShiftedBits: NativeUInt;
  I, J: NativeUInt;
begin
  { Do nothing on 0 }
  if (ACount = 0) or (AValue.FArray = nil) then
  begin
    Result := AValue;
    Exit;
  end;

  { Calculate shifts }
  ShiftedPieces := ACount div BitsInPiece;
  ShiftedBits := ACount mod BitsInPiece;

  { Init and ensure capacity }
  Result.SetLength(AValue.FLength + ShiftedPieces + 1);

  I := ShiftedPieces;

	for J := 0 to AValue.FLength do
  begin
    { Actually shift the bits in the card }
		Result.FArray[I] := GetShiftedPiece(AValue, J, ShiftedBits);
    Inc(I);
  end;

  { Remove leading 0's }
  Result.RemoveLeadingZeroes();
end;

class operator BigCardinal.LessThan(const ALeft, ARight: BigCardinal): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) < 0);
end;

class operator BigCardinal.LessThanOrEqual(const ALeft, ARight: BigCardinal): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) <= 0);
end;

function BigCardinal.ModPow(const AExponent, AModulus: BigCardinal): BigCardinal;
var
  I, LBit: Integer;
  LOne: Boolean;
  LElement: TNumberPiece;
begin
  {
    Special cases:
      1. (X^0 mod 1) => 1 mod 1 => 0
      2. (X^0 mod M) => 1 mod M => 1
      3. (1^E mod 1) => 1 mod 1 => 0
      4. (1^E mod M) => 1 mod M => 1
      5. (0^E mod M) => 0 mod M => 0
  }
  if Self.IsZero then
    Result := Zero
  else if (AExponent.IsZero) or (Self.CompareTo(One) = 0) then
  begin
    if AModulus = One then
      Result := Zero
    else
      Result := One;

    Exit;
  end else
  begin
    Result := One;

    LOne := True;

    for I := AExponent.FLength - 1 downto 0 do
    begin
      LBit := 1 shl (BitsInPiece - 1);
      LElement := AExponent.FArray[I];

      repeat

        if not LOne then
        begin
          Result := Result * Result;
          Result := Result mod AModulus;
        end;
        if LElement and LBit <> 0 then
        begin
          Result := Result * Self;
          Result := Result mod AModulus;

          LOne := False;
        end;

        LBit := LBit shr 1;

      until LBit = 0;

    end;

    Result.RemoveLeadingZeroes;
  end;
end;

class operator BigCardinal.Modulus(const ALeft, ARight: BigCardinal): BigCardinal;
var
  Q: BigCardinal;
begin
  System.SetLength(Result.FArray, ALeft.FLength);
  Result.FLength := ALeft.FLength;
  Move(ALeft.FArray[0], Result.FArray[0], ALeft.FLength * BytesInPiece);

  Result.CalcModulus(ARight, Q);
end;

class operator BigCardinal.Multiply(const ALeft, ARight: BigCardinal): BigCardinal;
var
  I, J, K, I2: NativeUInt;
  Temp: TNumberPiece;
  CarryIn, CarryOut: Boolean;
begin
  { Check for zeroes: 0 * x = 0}
  if (ALeft.FArray = nil) or (ARight.FArray = nil) then
  begin
    Result := Zero;
    Exit;
  end;

  { Ensure capacity }
  Result.SetLength(ALeft.FLength + ARight.FLength);

  { Calculate what we need }
  for I := 0 to ALeft.FLength - 1 do
  begin

		for I2 := 0 to BitsInPiece - 1 do
		begin
    	if ((ALeft.FArray[I] and (1 shl I2)) = 0) then
				continue;

      CarryIn := False;
      K := I;

      for J := 0 to ARight.FLength do
      begin
        { Disable overflow check in this code! }
        Temp := Result.FArray[K] + GetShiftedPiece(ARight, J, I2);

				CarryOut := (Temp < Result.FArray[K]);

				if (CarryIn) then
        begin
					Inc(Temp);
					CarryOut := CarryOut or (Temp = 0);
				end;

				Result.FArray[K] := Temp;
				CarryIn := CarryOut;

        Inc(K);
      end;

      while CarryIn do
      begin
        Inc(Result.FArray[K]);
        CarryIn := (Result.FArray[K] = 0);

        Inc(K);
      end;
    end;
  end;

  { Cleanup result }
  Result.RemoveLeadingZeroes();
end;

class operator BigCardinal.Implicit(const ANumber: Cardinal): BigCardinal;
begin
  { Simply call ctor }
  Result := BigCardinal.Create(ANumber);
end;

class operator BigCardinal.Negative(const AValue: BigCardinal): BigCardinal;
var
  I: NativeInt;
  C: TNumberPiece;
begin
  { Do a NEG operation (Two's complement) on the value }
  if (AValue.FArray = nil) then
  begin
    Result := AValue;
    Exit;
  end;

  { Copy the array over }
  Result.SetLength(AValue.FLength);
  C := 0; // Initial carry is zero

  for I := 0 to AValue.FLength - 1 do
  begin
    { Calculate two's compliment for this piece }
    Result.FArray[I] := -(AValue.FArray[I] + C);

    { Check for carry for the next operation }
    if AValue.FArray[I] = 0 then C := 0 else C := 1;
  end;

  { Clean yourself up! }
  Result.RemoveLeadingZeroes();
end;

class operator BigCardinal.NotEqual(const ALeft, ARight: BigCardinal): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) <> 0);
end;

class function BigCardinal.Parse(const AString: string): BigCardinal;
begin
  { Call the Try version }
  if not TryParse(AString, Result) then
    ExceptionHelper.Throw_ArgumentConverError('AString');
end;

class function BigCardinal.ParseHex(const AString: string): BigCardinal;
begin
  { Call the Try version }
  if not TryParseHex(AString, Result) then
    ExceptionHelper.Throw_ArgumentConverError('AString');
end;

class operator BigCardinal.Positive(const AValue: BigCardinal): BigCardinal;
begin
  { Nothing ... }
  Result := AValue;
end;

function BigCardinal.Pow(const AExponent: NativeUInt): BigCardinal;
var
  I: NativeUInt;
begin
  Result := One;

  for I := 1 to AExponent do
    Result := Self * Result;
end;

procedure BigCardinal.RemoveLeadingZeroes;
begin
  { Repeat undefinetly }
  while (FLength > 0) do
  begin
    { Decrease the FLength variable is f it points to a 0}
    if FArray[FLength - 1] = 0 then
      Dec(FLength)
    else
     Break; { Finish when a non-zero found }
  end;

  { If no elemens are in the array, set to nil }
  { There is code that depends on the array being nil }
  if FLength = 0 then
    System.SetLength(FArray, 0);
end;

class operator BigCardinal.RightShift(const AValue: BigCardinal; const ACount: NativeUInt): BigCardinal;
var
  ShiftedPieces: NativeUInt;
  ShiftedBits: NativeUInt;
  I, J: NativeUInt;
begin
  { Do nothing on 0 count }
  if (ACount = 0) or (AValue.FArray = nil) then
  begin
    Result := AValue;
    Exit;
  end;

  { Calculate shifts }
  ShiftedPieces := (ACount + BitsInPiece - 1) div BitsInPiece;
  ShiftedBits := (ShiftedPieces * BitsInPiece) - ACount;

  { Check implicit shifts }
	if (ShiftedPieces >= AValue.FLength + 1) then
  begin
    Result := Zero;
    Exit();
  end;

  { Initialize and ensure capacity }
  Result.SetLength(AValue.FLength - ShiftedPieces + 1);

  { Do the actual stuff }
  I := 0;

	for J := ShiftedPieces to AValue.FLength do
  begin
    { Actually shift the bits in the card }
		Result.FArray[I] := GetShiftedPiece(AValue, J, ShiftedBits);
    Inc(I);
  end;

  { Remove leading 0's }
  Result.RemoveLeadingZeroes();
end;

class operator BigCardinal.Subtract(const ALeft, ARight: BigCardinal): BigCardinal;
var
  I: NativeUInt;
  Temp: TNumberPiece;
  LLeft: BigCardinal;
  BorrowIn, BorrowOut: Boolean;
begin
  { Check for zeroes }
  if (ALeft.FArray = nil) and (ARight.FArray = nil) then
  begin
    Result := Zero;
    Exit;
  end;

  { Right is 0 - do nothing }
  if ARight.FArray = nil then
  begin
    Result := ALeft;
    Exit;
  end;

  { Left is 0 - set the temp lngth }

  if (ALeft.FArray = nil) or (ALeft.FLength < ARight.FLength) then
  begin
    {$IFDEF BIGCARDINAL_OVERFLOW_CHECKS}
    ExceptionHelper.Throw_OverflowError();
    {$ENDIF}

    { LLeft must be copied from the original }
    LLeft.SetLength(ARight.FLength);
    LLeft.FLength := ARight.FLength;

    if (ALeft.FArray <> nil) and (ALeft.FLength > 0) then
      Move(ALeft.FArray[0], LLeft.FArray[0], ALeft.FLength * BytesInPiece);
  end else
      LLeft := ALeft;

  { Ensure capacity }
  Result.SetLength(LLeft.FLength);

  BorrowIn := False;

  { Calculate subtraction for each card }
  for I := 0 to ARight.FLength - 1 do
  begin
    { Disable overflow check in this code! }
    Temp := LLeft.FArray[I] - ARight.FArray[I];

		BorrowOut := (Temp > LLeft.FArray[i]);

		if (BorrowIn) then
    begin
			BorrowOut := BorrowOut or (Temp = 0);
			Dec(Temp);
		end;

		Result.FArray[I] := Temp;
		BorrowIn := BorrowOut;
  end;

  { And continue ... }
  I := ARight.FLength;

  while (I < LLeft.FLength) and (BorrowIn) do
  begin
    BorrowIn := (LLeft.FArray[I] = 0);
    Result.FArray[I] := LLeft.FArray[I] - 1;

    Inc(I);
  end;

  {$IFDEF BIGCARDINAL_OVERFLOW_CHECKS}
  { A carry still wanted ... exception! }
  if (BorrowIn) then
  begin
    { Clean-up the result }
    Result := BigCardinalZero;
    ExceptionHelper.Throw_OverflowError();
  end;
  {$ENDIF}

  { Finish the subtraction - copy leftovers }
  while (I < LLeft.FLength) do
  begin
    Result.FArray[I] := LLeft.FArray[I];
    Inc(I);
  end;

  { Cleanup the result }
  Result.RemoveLeadingZeroes();
end;

function BigCardinal.ToAnsiChar: AnsiChar;
begin
  CopyPieces(Result, SizeOf(AnsiChar));
end;

function BigCardinal.ToByte: Byte;
begin
  CopyPieces(Result, SizeOf(Byte));
end;

function BigCardinal.ToCardinal: Cardinal;
begin
  CopyPieces(Result, SizeOf(Cardinal));
end;

function BigCardinal.ToHexString: string;
begin
  if IsZero then
    Exit('0');

  { For small numbers call the Cardinal converter }
  if SizeOf(Cardinal) >= (FLength * BigCardinal.BytesInPiece) then
  begin
    Result := TrimLeftZeros(IntToHex(ToCardinal(), 8));
    Exit;
  end;

  { For 64 bit numbers call the int64 converter }
  if SizeOf(UInt64) >= (FLength * BigCardinal.BytesInPiece) then
  begin
    Result := TrimLeftZeros(IntToHex(ToUInt64(), 16));
    Exit;
  end;

  { Fill in the digits }
  Fill4BitDigits(Result, Self);

  { Reduce the number of zeroes at the beggining }
  Result := TrimLeftZeros(Result);
end;

function BigCardinal.ToInt64: Int64;
begin
  CopyPieces(Result, SizeOf(Int64));
end;

function BigCardinal.ToInteger: Integer;
begin
  CopyPieces(Result, SizeOf(Integer));
end;

function BigCardinal.ToShortInt: ShortInt;
begin
  CopyPieces(Result, SizeOf(ShortInt));
end;

function BigCardinal.ToSmallInt: SmallInt;
begin
  CopyPieces(Result, SizeOf(SmallInt));
end;

function BigCardinal.ToString: string;
var
  BCDValue: BigCardinal;

begin
  { Do nothing for value 0 }
  if IsZero then
    Exit('0');

  { For small numbers call the Cardinal converter }
  if SizeOf(Cardinal) >= (FLength * BigCardinal.BytesInPiece) then
    Exit(UIntToStr(ToCardinal()));

  { For 64 bit numbers call the int64 converter }
  if SizeOf(UInt64) >= (FLength * BigCardinal.BytesInPiece) then
    Exit(UIntToStr(ToUInt64()));

  { Generate a BCD version }
  BCDValue := ToBCD();

  { Fill in the digits }
  Fill4BitDigits(Result, BCDValue);

  { Reduce the number of zeroes at the beggining }
  Result := TrimLeftZeros(Result);
end;

function BigCardinal.ToUInt64: UInt64;
begin
  CopyPieces(Result, SizeOf(UInt64));
end;

function BigCardinal.ToWideChar: WideChar;
begin
  CopyPieces(Result, SizeOf(WideChar));
end;

function BigCardinal.ToWord: Word;
begin
  CopyPieces(Result, SizeOf(Word));
end;

class function BigCardinal.TryParse(const AString: string; out ABigCardinal: BigCardinal): Boolean;
var
  M: BigCardinal;
  I: NativeUInt;
  S2: String;
begin
  { Default = 0 }
  Result := false;

  S2 := TrimLeft(AString);

  { Empty string case }
  if S2 = '' then
    Exit;

  { Call the HEX version }
  if S2[1] = '$' then
  begin
    Delete(S2, 1, 1);
    Exit( TryParseHex(S2, ABigCardinal) );
  end;

  M := 1;

  for I := Length(S2) downto 1 do
  begin
    if CharInSet(S2[I], ['0' .. '9']) then
      ABigCardinal := ABigCardinal + (NativeUInt(Ord(S2[I]) - Ord('0')) * M)
    else
      Exit;

    { + 1 base high }
    M := M * 10;
  end;

  Result := true;
end;

class function BigCardinal.TryParseHex(const AString: string; out ABigCardinal: BigCardinal): Boolean;
var
  M: BigCardinal;
  I: NativeUInt;
  S2: String;
begin
  { Default = 0 }
  Result := false;

  S2 := TrimLeft(AString);

  { Empty string case }
  if S2 = '' then
    Exit;

  M := 1;
  ABigCardinal := 0;
  for I := Length(S2) downto 1 do
  begin
    if CharInSet(S2[I], ['0' .. '9']) then
      ABigCardinal := ABigCardinal + (NativeUInt(Ord(S2[I]) - Ord('0')) * M)
    else if CharInSet(S2[I], ['A' .. 'F']) then
      ABigCardinal := ABigCardinal + (NativeUInt(Ord(S2[I]) - Ord('A') + $A) * M)
    else if CharInSet(S2[I], ['a' .. 'f']) then
      ABigCardinal := ABigCardinal + (NativeUInt(Ord(S2[I]) - Ord('a') + $A) * M)
    else
      Exit;

    { + 1 base high }
    M := M * $10;
  end;

  Result := true;
end;

procedure BigCardinal.CalcModulus(const Divisor: BigCardinal; var Quotient: BigCardinal);
var
  I, J, K, I2: NativeUInt;
  OrigLen: NativeUInt;
  Temp: TNumberPiece;
  BorrowIn, BorrowOut: Boolean;
  XBuffer: TNumberPieceArray;
begin
  { Check for 0 divisor }
  if Divisor.FArray = nil then
    ExceptionHelper.Throw_DivByZeroError();

  { Special case }
  if (FArray = nil) or (FLength < Divisor.FLength) then
  begin
    { Q = 0 and R = DVD }
    Quotient := Zero;
    Exit;
  end;

  { Reset the lengths }
	OrigLen := FLength;
  System.SetLength(FArray, FLength + 1);
  FArray[FLength] := 0;
  Inc(FLength);

  { Init a temporary buffer }
  System.SetLength(XBuffer, FLength);
  FillChar(XBuffer[0], BytesInPiece * FLength, 0);

  { Initialize quotient }
  Quotient.SetLength(OrigLen - Divisor.FLength + 1);

	I := Quotient.FLength;

	while (I > 0) do
  begin
		Dec(I);

		Quotient.FArray[I] := 0;
		I2 := BitsInPiece;

    while I2 > 0 do
    begin
      Dec(I2);

      BorrowIn := False;
      K := I;

      for J := 0 to Divisor.FLength do
      begin
        Temp := FArray[K] - GetShiftedPiece(Divisor, J, I2);
				BorrowOut := (Temp > FArray[k]);

				if (BorrowIn)  then
        begin
					BorrowOut := BorrowOut or (Temp = 0);
					Dec(Temp);
				end;

				XBuffer[K] := Temp;
				BorrowIn := BorrowOut;

        { Inc ... }
        Inc(K);
      end;

      while (K < OrigLen) and (BorrowIn) do
      begin
        BorrowIn := (FArray[K] = 0);
				XBuffer[K] := FArray[K] - 1;

        Inc(K);
      end;

			if (not BorrowIn) then
      begin
				Quotient.FArray[I] := Quotient.FArray[I] or (TNumberPiece(1) shl I2);

				while (K > I) do
        begin
          Dec(K);
					FArray[K] := XBuffer[k];
				end;
			end;

    end;
  end;

  { Clean-up variables }
  Quotient.RemoveLeadingZeroes();
  RemoveLeadingZeroes();
end;


class operator BigCardinal.Explicit(const ANumber: Variant): BigCardinal;
begin
  { Call this one }
  Result := SgtBigCardinalVariantType.VarDataToBigCardinal(TVarData(ANumber));
end;

{ TBigCardinalType }

function TBigCardinalType.Compare(const AValue1, AValue2: BigCardinal): NativeInt;
begin
  Result := AValue1.CompareTo(AValue2);
end;

procedure TBigCardinalType.DoDeserialize(const AInfo: TValueInfo; out AValue: BigCardinal; const AContext: IDeserializationContext);
var
  LStr: String;
begin
  { Either use my routine or call the inherited one to do the job }
  if AContext.InReadableForm then
  begin
    AContext.GetValue(AInfo, LStr);
    AValue := BigCardinal.Parse(LStr);
  end else
    inherited DoDeserialize(AInfo, AValue, AContext);
end;

procedure TBigCardinalType.DoSerialize(const AInfo: TValueInfo; const AValue: BigCardinal; const AContext: ISerializationContext);
begin
  { Either use my routine or call the inherited one to do the job }
  if AContext.InReadableForm then
    AContext.AddValue(AInfo, AValue.ToString())
  else
    inherited DoSerialize(AInfo, AValue, AContext);
end;

function TBigCardinalType.Family: TTypeFamily;
begin
  Result := tfUnsignedInteger;
end;

function TBigCardinalType.GenerateHashCode(const AValue: BigCardinal): NativeInt;
begin
  { Exit with 0 on 0 size }
  if AValue.FArray = nil then
    Exit(0);

  { Call the Type-Support provided function }
  Result := BinaryHash(Addr(AValue.FArray[0]), AValue.FLength * BigCardinal.BytesInPiece);
end;

function TBigCardinalType.GetString(const AValue: BigCardinal): String;
begin
  Result := AValue.ToString();
end;

function TBigCardinalType.TryConvertFromVariant(const AValue: Variant; out ORes: BigCardinal): Boolean;
begin
  { May not be a valid BigCardinal }
  try
    ORes := SgtBigCardinalVariantType.VarDataToBigCardinal(TVarData(AValue));
  except
    Exit(false);
  end;

  Result := true;
end;

function TBigCardinalType.TryConvertToVariant(const AValue: BigCardinal; out ORes: Variant): Boolean;
begin
  { Simple variant conversion }
  ORes := AValue;
  Result := true;
end;

{ TBigCardinalMathExtension }

function TBigCardinalMathExtension.Add(const AValue1, AValue2: BigCardinal): BigCardinal;
begin
  Result := AValue1 + AValue2;
end;

function TBigCardinalMathExtension.IntegralDivide(const AValue1, AValue2: BigCardinal): BigCardinal;
begin
  Result := AValue1 div AValue2;
end;

function TBigCardinalMathExtension.Modulo(const AValue1, AValue2: BigCardinal): BigCardinal;
begin
  Result := AValue1 mod AValue2;
end;

function TBigCardinalMathExtension.Multiply(const AValue1, AValue2: BigCardinal): BigCardinal;
begin
  Result := AValue1 * AValue2;
end;

function TBigCardinalMathExtension.One: BigCardinal;
begin
  Result := BigCardinal.One;
end;

function TBigCardinalMathExtension.Subtract(const AValue1, AValue2: BigCardinal): BigCardinal;
begin
  Result := AValue1 - AValue2;
end;

function TBigCardinalMathExtension.Zero: BigCardinal;
begin
  Result := BigCardinal.Zero;
end;

end.



