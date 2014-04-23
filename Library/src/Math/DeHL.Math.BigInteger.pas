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
unit DeHL.Math.BigInteger;
interface
uses SysUtils,
     Variants,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Math.Types,
     DeHL.Math.BigCardinal;

type
  ///  <summary>An unlimited precision integer number.</summary>
  BigInteger = record
  private type
    { Internal-only types }
    TData = class;
    IData = interface
      function GetData: BigInteger.TData;
    end;
    TData = class(TInterfacedObject, IData)
      FSign: SmallInt;
      FMagnitude: BigCardinal;
      function GetData: TData;
      class function Make(const AMag: BigCardinal; const ASign: SmallInt): IData;
    end;

  private
    class var FVarType: TVarType;

    { Internal cache }
    class var FCached_Numbers: array[-10..10] of IData;

    { Initialization }
    class constructor Create;
    class destructor Destroy;

    class function GetMinusOne: BigInteger; inline; static;
    class function GetMinusTen: BigInteger; inline; static;
    class function GetOne: BigInteger; inline; static;
    class function GetTen: BigInteger; inline; static;
    class function GetZero: BigInteger; inline; static;
  private
    FData: IData;

    { Purely internals }
    function GetData(): TData; inline;

    { For property support }
    function GetIsNegative: Boolean; inline;
    function GetIsPositive: Boolean; inline;
    function GetIsZero: Boolean; inline;
    function GetIsEven: Boolean; inline;
    function GetIsOdd: Boolean; inline;
    function GetSign: SmallInt; inline;
  public
    ///  <summary>Initializes a <c>BigInteger</c> with a given value.</summary>
    ///  <param name="ANumber">A <c>UInt64</c> value.</param>
    ///  <remarks>The generated integer value is positive.</remarks>
    constructor Create(const ANumber: UInt64); overload;

    ///  <summary>Initializes a <c>BigInteger</c> with a given value.</summary>
    ///  <param name="ANumber">An <c>Int64</c> value.</param>
    ///  <remarks>The sign and the magnitude of the given value are used.</remarks>
    constructor Create(const ANumber: Int64); overload;

    ///  <summary>Initializes a <c>BigInteger</c> with a given value.</summary>
    ///  <param name="ANumber">A <c>Cardinal</c> value.</param>
    ///  <remarks>The generated integer value is positive.</remarks>
    constructor Create(const ANumber: Cardinal); overload;

    ///  <summary>Initializes a <c>BigInteger</c> with a given value.</summary>
    ///  <param name="ANumber">An <c>Integer</c> value.</param>
    ///  <remarks>The sign and the magnitude of the given value are used.</remarks>
    constructor Create(const ANumber: Integer); overload;

    ///  <summary>Initializes a <c>BigInteger</c> with a given value.</summary>
    ///  <param name="ANumber">A <c>UInt64</c> value.</param>
    ///  <remarks>The sign and the magnitude of the given value are used.</remarks>
    constructor Create(const ANumber: BigInteger); overload;

    ///  <summary>Initializes a <c>BigInteger</c> with a given value.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value.</param>
    ///  <remarks>The generated integer value is positive.</remarks>
    constructor Create(const ANumber: BigCardinal); overload;

    ///  <summary>Compares this <c>BigInteger</c> to another <c>BigInteger</c>.</summary>
    ///  <param name="ANumber">The <c>BigInteger</c> value to compare with.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, this <c>BigInteger</c> is less than <paramref name="ANumber"/>.
    ///  If the result is zero, this <c>BigInteger</c> is equal to <paramref name="ANumber"/>. And finally,
    ///  if the result is greater than zero, this <c>BigInteger</c> is greater than <paramref name="ANumber"/>.</returns>
    function CompareTo(const ANumber: BigInteger): NativeInt;

    ///  <summary>Converts this <c>BigInteger</c> to a <c>ShortInt</c> value.</summary>
    ///  <returns>The less-significant <c>ShortInt</c> of this <c>BigInteger</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigInteger</c> can be converted to a <c>ShortInt</c> without
    ///  loss in precision.</remarks>
    function ToShortInt(): ShortInt; inline;

    ///  <summary>Converts this <c>BigInteger</c> to a <c>SmallInt</c> value.</summary>
    ///  <returns>The less significant <c>SmallInt</c> of this <c>BigInteger</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigInteger</c> can be converted to a <c>SmallInt</c> without
    ///  loss of precision.</remarks>
    function ToSmallInt(): SmallInt; inline;

    ///  <summary>Converts this <c>BigInteger</c> to an <c>Integer</c> value.</summary>
    ///  <returns>The less significant <c>Integer</c> of this <c>BigInteger</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigInteger</c> can be converted to an <c>Integer</c> without
    ///  loss of precision.</remarks>
    function ToInteger(): Integer; inline;

    ///  <summary>Converts this <c>BigInteger</c> to an <c>Int64</c> value.</summary>
    ///  <returns>The less significant <c>Integer</c> of this <c>BigInteger</c>.</returns>
    ///  <remarks>Use this method only when the value of the <c>BigInteger</c> can be converted to an <c>Int64</c> without
    ///  loss of precision.</remarks>
    function ToInt64(): Int64; inline;

    ///  <summary>Checks whether this <c>BigInteger</c> is zero.</summary>
    ///  <returns><c>True</c> if this <c>BigInteger</c> is zero; <c>False</c> otherwise.</returns>
    property IsZero: Boolean read GetIsZero;

    ///  <summary>Checks whether this <c>BigInteger</c> is negative.</summary>
    ///  <returns><c>True</c> if this <c>BigInteger</c> is negative; <c>False</c> otherwise.</returns>
    property IsNegative: Boolean read GetIsNegative;

    ///  <summary>Checks whether this <c>BigInteger</c> is zero or positive.</summary>
    ///  <returns><c>True</c> if this <c>BigInteger</c> is zero or positive; <c>False</c> otherwise.</returns>
    property IsPositive: Boolean read GetIsPositive;

    ///  <summary>Checks whether this <c>BigInteger</c> is odd.</summary>
    ///  <returns><c>True</c> if this <c>BigInteger</c> is odd; <c>False</c> otherwise.</returns>
    property IsOdd: Boolean read GetIsOdd;

    ///  <summary>Checks whether this <c>BigInteger</c> is even.</summary>
    ///  <returns><c>True</c> if this <c>BigInteger</c> is even; <c>False</c> otherwise.</returns>
    property IsEven: Boolean read GetIsEven;

    ///  <summary>Specifies the sign of this <c>BigInteger</c>.</summary>
    ///  <returns><c>-1</c> if this <c>BigInteger</c> is negative, <c>0</c> if this <c>BigInteger</c> is zero, and
    ///  <c>1</c> if this <c>BigInteger</c> is positive.</returns>
    property Sign: SmallInt read GetSign;

    ///  <summary>Calculates the quotient and the remainder of a division operation.</summary>
    ///  <param name="ADivisor">A <c>BigInteger</c> value to divide to.</param>
    ///  <param name="ARemainder">An output <c>BigInteger</c> value containing the remainder.</param>
    ///  <returns>The quotient resulting from the division operation.</returns>
    ///  <exception cref="SysUtils|EDivByZero">If <paramref name="ADivisor"/> is zero.</exception>
    function DivMod(const ADivisor: BigInteger; out ARemainder: BigInteger): BigInteger;

    ///  <summary>Returns the absolute value of this <c>BigInteger</c>.</summary>
    ///  <returns>A new <c>BigInteger</c> that contains the absolute value of this <c>BigInteger</c>.</returns>
    function Abs(): BigInteger;

    ///  <summary>Raises a number to a specified power.</summary>
    ///  <param name="AExponent">A <c>NativeUInt</c> value that represents the exponent.</param>
    ///  <returns>The result of the exponentiation operation.</returns>
    function Pow(const AExponent: NativeUInt): BigInteger;

    ///  <summary>Tries to convert a string value to a <c>BigInteger</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <param name="ABigInteger">An output <c>BigInteger</c> converted from the given string.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    class function TryParse(const AString: string; out ABigInteger: BigInteger): Boolean; static;

    ///  <summary>Converts a string value to a <c>BigInteger</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <returns>The converted <c>BigInteger</c> value.</returns>
    ///  <exception cref="SysUtils|EConvertError">The string does not represent a valid number.</exception>
    class function Parse(const AString: string): BigInteger; inline; static;

    ///  <summary>Converts this <c>BigInteger</c> to a string value.</summary>
    ///  <returns>The string representation of this <c>BigInteger</c>.</returns>
    function ToString(): string;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ALeft">A <c>BigInteger</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigInteger</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft, ARight: BigInteger): Boolean;

    ///  <summary>Overloaded "<>" operator.</summary>
    ///  <param name="ALeft">A <c>BigInteger</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigInteger</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ALeft, ARight: BigInteger): Boolean;

    ///  <summary>Overloaded "&gt;" operator.</summary>
    ///  <param name="ALeft">A <c>BigInteger</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigInteger</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ALeft, ARight: BigInteger): Boolean;

    ///  <summary>Overloaded "&gt;=" operator.</summary>
    ///  <param name="ALeft">A <c>BigInteger</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigInteger</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ALeft, ARight: BigInteger): Boolean;

    ///  <summary>Overloaded "&lt;" operator.</summary>
    ///  <param name="ALeft">A <c>BigInteger</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigInteger</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ALeft, ARight: BigInteger): Boolean;

    ///  <summary>Overloaded "&lt;=" operator.</summary>
    ///  <param name="ALeft">A <c>BigInteger</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigInteger</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ALeft, ARight: BigInteger): Boolean;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">First <c>BigInteger</c> value.</param>
    ///  <param name="ARight">Second <c>BigInteger</c> value.</param>
    ///  <returns>A <c>BigInteger</c> value that contains the sum of the two values.</returns>
    class operator Add(const ALeft, ARight: BigInteger): BigInteger;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ALeft">First <c>BigInteger</c> value.</param>
    ///  <param name="ARight">Second <c>BigInteger</c> value.</param>
    ///  <returns>A <c>BigInteger</c> value that contains the difference of the two values.</returns>
    class operator Subtract(const ALeft, ARight: BigInteger): BigInteger;

    ///  <summary>Overloaded "*" operator.</summary>
    ///  <param name="ALeft">First <c>BigInteger</c> value.</param>
    ///  <param name="ARight">Second <c>BigInteger</c> value.</param>
    ///  <returns>A <c>BigInteger</c> value that contains the product of the two values.</returns>
    class operator Multiply(const ALeft, ARight: BigInteger): BigInteger;

    ///  <summary>Overloaded "div" operator.</summary>
    ///  <param name="ALeft">The dividend <c>BigInteger</c> value.</param>
    ///  <param name="ARight">The divisor <c>BigInteger</c> value.</param>
    ///  <returns>A <c>BigInteger</c> value that contains the quotient.</returns>
    ///  <exception cref="SysUtils|EDivByZero">If <paramref name="ARight"/> is zero.</exception>
    class operator IntDivide(const ALeft, ARight: BigInteger): BigInteger;

    ///  <summary>Overloaded "mod" operator.</summary>
    ///  <param name="ALeft">The dividend <c>BigInteger</c> value.</param>
    ///  <param name="ARight">The divisor <c>BigInteger</c> value.</param>
    ///  <returns>A <c>BigInteger</c> value that contains the remainder.</returns>
    class operator Modulus(const ALeft, ARight: BigInteger): BigInteger;

    ///  <summary>Overloaded unary "-" operator.</summary>
    ///  <param name="AValue">A <c>BigInteger</c> value.</param>
    ///  <returns>A <c>BigInteger</c> that has the same magnitude but an inverted sign.</returns>
    class operator Negative(const AValue: BigInteger): BigInteger;

    ///  <summary>Overloaded unary "+" operator.</summary>
    ///  <param name="AValue">A <c>BigInteger</c> value.</param>
    ///  <returns>The same <c>BigInteger</c> value.</returns>
    ///  <remarks>This operation is a nop.</remarks>
    class operator Positive(const AValue: BigInteger): BigInteger;

    ///  <summary>Overloaded unary "Inc" operator.</summary>
    ///  <param name="AValue">A <c>BigInteger</c> value to increment by one.</param>
    ///  <returns>A <c>BigInteger</c> value whose result is <c><paramref name="AValue"/> + 1</c>.</returns>
    class operator Inc(const AValue: BigInteger): BigInteger;

    ///  <summary>Overloaded unary "Dec" operator.</summary>
    ///  <param name="AValue">A <c>BigInteger</c> value to decrement by one.</param>
    ///  <returns>A <c>BigInteger</c> value whose result is <c><paramref name="AValue"/> - 1</c>.</returns>
    class operator Dec(const AValue: BigInteger): BigInteger;

    ///  <summary>Overloaded "shl" operator.</summary>
    ///  <param name="AValue">A <c>BigInteger</c> value to shift left.</param>
    ///  <param name="ACount">The number of bits to shift left by.</param>
    ///  <returns>A new shifted <c>BigInteger</c>.</returns>
    ///  <remarks>Since a <c>BigInteger</c> has no limit in size, this operation does not wrap at a certain bit length.</remarks>
    class operator LeftShift(const AValue: BigInteger; const ACount: NativeUInt): BigInteger;

    ///  <summary>Overloaded "shr" operator.</summary>
    ///  <param name="AValue">A <c>BigInteger</c> value to shift right.</param>
    ///  <param name="ACount">The number of bits to shift right by.</param>
    ///  <returns>A new shifted <c>BigInteger</c>.</returns>
    ///  <remarks>If <paramref name="ACount"/> is greater than the bit length of this <c>BigInteger</c>, zero is obtained.</remarks>
    class operator RightShift(const AValue: BigInteger; const ACount: NativeUInt): BigInteger;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Byte</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Byte): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Word</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Word): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Cardinal</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Cardinal): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>UInt64</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: UInt64): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>SmallInt</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: SmallInt): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>ShortInt</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: ShortInt): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">An <c>Integer</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Integer): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">An <c>Int64</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: Int64): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    class operator Implicit(const ANumber: BigCardinal): BigInteger; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigInteger</c> value to convert.</param>
    ///  <returns>A <c>Variant</c> value containing the converted value.</returns>
    ///  <remarks>The returned <c>Variant</c> contains a custom variant type.</remarks>
    class operator Implicit(const ANumber: BigInteger): Variant; inline;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigInteger</c> value to convert.</param>
    ///  <returns>A <c>ShortInt</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigInteger): ShortInt; inline;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigInteger</c> value to convert.</param>
    ///  <returns>A <c>SmallInt</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigInteger): SmallInt; inline;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigInteger</c> value to convert.</param>
    ///  <returns>An <c>Integer</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigInteger): Integer; inline;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigInteger</c> value to convert.</param>
    ///  <returns>An <c>Int64</c> value containing the converted value.</returns>
    class operator Explicit(const ANumber: BigInteger): Int64; inline;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>Variant</c> value to convert.</param>
    ///  <returns>A <c>BigInteger</c> value containing the converted value.</returns>
    ///  <remarks>This method may raise various exceptions if the provided <c>Variant</c>
    ///  cannot be converted properly.</remarks>
    class operator Explicit(const ANumber: Variant): BigInteger;

    ///  <summary>Specifies the ID of the <c>Variant</c> values containing a <c>BigInteger</c>.</summary>
    ///  <returns>A <c>TVarType</c> value that specifies the ID.</returns>
    ///  <remarks>Use this value to identify <c>Variant</c>s that contain <c>BigInteger</c> values.</remarks>
    class property VarType: TVarType read FVarType;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents a
    ///  <see cref="DeHL.Math.BigInteger|BigInteger">DeHL.Math.BigInteger.BigInteger</see> type.</returns>
    class function GetType(): IType<BigInteger>; static;

    ///  <summary>Returns <c>0</c>.</summary>
    ///  <returns>A <c>BigInteger</c> value containing zero.</returns>
    class property Zero: BigInteger read GetZero;

    ///  <summary>Returns <c>1</c>.</summary>
    ///  <returns>A <c>BigInteger</c> value containing one.</returns>
    class property One: BigInteger read GetOne;

    ///  <summary>Returns <c>-1</c>.</summary>
    ///  <returns>A <c>BigInteger</c> value containing minus one.</returns>
    class property MinusOne: BigInteger read GetMinusOne;

    ///  <summary>Returns <c>10</c>.</summary>
    ///  <returns>A <c>BigInteger</c> value containing ten.</returns>
    class property Ten: BigInteger read GetTen;

    ///  <summary>Returns <c>-10</c>.</summary>
    ///  <returns>A <c>BigInteger</c> value containing minus ten.</returns>
    class property MinusTen: BigInteger read GetMinusTen;
  end;

implementation
uses DeHL.StrConsts;

{ BigInteger.TData }

class function BigInteger.TData.Make(const AMag: BigCardinal; const ASign: SmallInt): IData;
var
  LInst: TData;
begin
  { Create a new data block }
  LInst := TData.Create;
  Result := LInst;
  LInst.FMagnitude := AMag;
  LInst.FSign := ASign;
end;

function BigInteger.TData.GetData: TData;
begin
  Result := Self;
end;

type
  { BigInteger Support }
  TBigIntegerType = class(TRecordType<BigInteger>)
  private
    FBigCardinalType: IType<BigCardinal>;

  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: BigInteger; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: BigInteger; const AContext: IDeserializationContext); override;

  public
    { Constructor }
    constructor Create(); override;

    { Comparator }
    function Compare(const AValue1, AValue2: BigInteger): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: BigInteger): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: BigInteger): String; override;

    { Type information }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: BigInteger; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: BigInteger): Boolean; override;
  end;

  { Math extensions for the BigInteger type }
  TBigIntegerMathExtension = class sealed(TIntegerMathExtension<BigInteger>)
  public
    { Standard operations }
    function Add(const AValue1, AValue2: BigInteger): BigInteger; override;
    function Subtract(const AValue1, AValue2: BigInteger): BigInteger; override;
    function Multiply(const AValue1, AValue2: BigInteger): BigInteger; override;
    function IntegralDivide(const AValue1, AValue2: BigInteger): BigInteger; override;
    function Modulo(const AValue1, AValue2: BigInteger): BigInteger; override;

    { Sign-related operations }
    function Negate(const AValue: BigInteger): BigInteger; override;
    function Abs(const AValue: BigInteger): BigInteger; override;

    { Neutral Math elements }
    function Zero: BigInteger; override;
    function One: BigInteger; override;
    function MinusOne: BigInteger; override;
  end;

  { Variant Support }

type
  { Mapping the BigCardinal into TVarData structure }
  TBigIntegerVarData = packed record
    { Var type, will be assigned at runtime }
    VType: TVarType;
    { Reserved stuff }
    Reserved1, Reserved2, Reserved3: Word;
    { A reference to the enclosed big cardinal }
    BigIntegerIntf: BigInteger.IData;
    { Reserved stuff }
    Reserved4: LongWord;
  end;

type
  { Manager for our variant type }
  TBigIntegerVariantType = class(TCustomVariantType)
  private
    { Will create a big cardinal, or raise an error }
    function VarDataToBigInteger(const Value: TVarData): BigInteger;
    procedure BigIntegerToVarData(const Value: BigInteger; var OutValue: TVarData);
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
  SgtBigIntegerVariantType: TBigIntegerVariantType;

{ TBigCardinalVariantType }

procedure TBigIntegerVariantType.BinaryOp(var Left: TVarData; const Right: TVarData; const &Operator: TVarOp);
begin
  { Select the appropriate operation }
  case &Operator of
    opAdd:
      BigIntegerToVarData(VarDataToBigInteger(Left) + VarDataToBigInteger(Right), Left);
    opIntDivide:
      BigIntegerToVarData(VarDataToBigInteger(Left) div VarDataToBigInteger(Right), Left);
    opModulus:
      BigIntegerToVarData(VarDataToBigInteger(Left) mod VarDataToBigInteger(Right), Left);
    opMultiply:
      BigIntegerToVarData(VarDataToBigInteger(Left) * VarDataToBigInteger(Right), Left);
    opSubtract:
      BigIntegerToVarData(VarDataToBigInteger(Left) - VarDataToBigInteger(Right), Left);
  else
    RaiseInvalidOp;
  end;
end;

procedure TBigIntegerVariantType.Cast(var Dest: TVarData; const Source: TVarData);
begin
  { Cast the source to our cardinal type }
  VarDataInit(Dest);
  BigIntegerToVarData(VarDataToBigInteger(Source), Dest);
end;

procedure TBigIntegerVariantType.CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType);
var
  Big: BigInteger;
  Temp: TVarData;
  WStr: WideString;
begin
  if Source.VType = VarType then
  begin
    { Only continue if we're invoked for our data type }
    Big.FData := TBigIntegerVarData(Source).BigIntegerIntf;

    { Initilize the destination }
    VarDataInit(Dest);
    Dest.VType := AVarType;

    case AVarType of
      varShortInt:
        Dest.VShortInt := Big.ToShortInt();

      varSmallint:
        Dest.VSmallInt := Big.ToSmallInt();

      varInteger:
        Dest.VInteger := Big.ToInteger();

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

procedure TBigIntegerVariantType.Clear(var V: TVarData);
begin
  { Clear the variant type }
  V.VType := varEmpty;

  { And dispose the value }
  TBigIntegerVarData(V).BigIntegerIntf := nil;
end;

procedure TBigIntegerVariantType.Compare(const Left, Right: TVarData; var Relationship: TVarCompareResult);
var
  Res: NativeInt;
begin
  { Compare these values }
  Res := VarDataToBigInteger(Left).CompareTo(VarDataToBigInteger(Right));

  { Return the compare result }
  if Res < 0 then
    Relationship := crLessThan
  else if Res > 0 then
    Relationship := crGreaterThan
  else
    Relationship := crEqual;
end;

procedure TBigIntegerVariantType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
    VarDataCopyNoInd(Dest, Source)
  else
  begin
    with TBigIntegerVarData(Dest) do
    begin
      { Copy the variant type }
      VType := VarType;

      { Copy by value }
      BigIntegerIntf := TBigIntegerVarData(Source).BigIntegerIntf;
    end;
  end;
end;

function TBigIntegerVariantType.IsClear(const V: TVarData): Boolean;
begin
  if V.VType = varEmpty then
    Exit(true);

  { Signal clear value }
  Result := (TBigIntegerVarData(V).BigIntegerIntf = nil);
end;

procedure TBigIntegerVariantType.UnaryOp(var Right: TVarData; const &Operator: TVarOp);
begin
  { Select the appropriate operation }
  case &Operator of
    opNegate:
      BigIntegerToVarData(-VarDataToBigInteger(Right), Right);
  else
    RaiseInvalidOp;
  end;
end;

function TBigIntegerVariantType.VarDataToBigInteger(const Value: TVarData): BigInteger;
begin
  { Check if the var data has a big cardinal inside }
  if Value.VType = VarType then
  begin
    { Copy the value to result }
    Result.FData := TBigIntegerVarData(Value).BigIntegerIntf;
    Exit;
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
      if not BigInteger.TryParse(VarDataToStr(Value), Result) then
        RaiseCastError
    end;
    else
    begin
      { If the incoming value is a big cardinal }
      if Value.VType = BigCardinal.VarType then
        Result := BigCardinal(Variant(Value))
      else
        RaiseCastError;
    end;
  end;
end;

procedure TBigIntegerVariantType.BigIntegerToVarData(const Value: BigInteger; var OutValue: TVarData);
begin
  { Dispose of the old value. Check it it's ours first }
  if OutValue.VType = VarType then
    Clear(OutValue)
  else
    VarDataClear(OutValue);

  with TBigIntegerVarData(OutValue) do
  begin
    { Assign the new variant the var type that was allocated for us }
    VType := VarType;

    { Copy self to this memory }
    Pointer(BigIntegerIntf) := nil;
    BigIntegerIntf := Value.FData;
  end;
end;

{ BigInteger }

function BigInteger.Abs: BigInteger;
var
  LData: TData;
begin
  { Obtain the data }
  LData := GetData();

  { If < 0 then do something; otherwise do nothing }
  if LData.FSign < 0 then
    Result.FData := TData.Make(LData.FMagnitude, -LData.FSign)
  else
    Result.FData := FData;
end;

class operator BigInteger.Add(const ALeft, ARight: BigInteger): BigInteger;
var
  LMagRel: NativeInt;
  LLData, LRData: TData;
begin
  { Get data }
  LLData := ALeft.GetData();
  LRData := ARight.GetData();

  if (LLData.FSign = 0) and (LRData.FSign = 0) then
    Result.FData := FCached_Numbers[0] { 0 + 0 = 0 }
  else if (LLData.FSign = 0) then
    Result.FData := ARight.FData { 0 + R = R }
  else if (LRData.FSign = 0) then
    Result.FData := ALeft.FData { L + 0 = L }
  else begin
    { Both numbers are non-zero }
    if LLData.FSign = LRData.FSign then
    begin
      { 1. Signs are equal => (-X) + (-Y) = -(+X + +Y) or (+X) + (+Y) = +(+X + +Y) }
      Result.FData := TData.Make(LLData.FMagnitude + LRData.FMagnitude, LLData.FSign);
    end else
    begin
      { 2. Different sign => mupltiple cases. First compare the magnitudes. }
      LMagRel := LLData.FMagnitude.CompareTo(LRData.FMagnitude);

      { If magnitudes are equal, the result of the subtraction is zero. }
      if LMagRel = 0 then
        Result.FData := FCached_Numbers[0]
      else if LMagRel > 0 then { Left magnitude is bigger than the right one. }
        Result.FData := TData.Make(LLData.FMagnitude - LRData.FMagnitude, LLData.FSign)
      else { Right magnitude is bigger then the left one. }
        Result.FData := TData.Make(LRData.FMagnitude - LLData.FMagnitude, LRData.FSign);
    end;
  end;
end;

function BigInteger.CompareTo(const ANumber: BigInteger): NativeInt;
var
  LLData, LRData: TData;
begin
  { Get data }
  LLData := GetData();
  LRData := ANumber.GetData();

  if LLData.FSign < LRData.FSign then
    Result := -1
  else if LLData.FSign > LRData.FSign then
    Result := 1
  else begin
    { Both signs are equal. Compare magnitudes and use sign also }
    if LLData.FSign = 0 then
      Result := 0
    else
      { Equal and non-zero signs. Compare magnitudes and decide. }
      Result := LLData.FMagnitude.CompareTo(LRData.FMagnitude) * LLData.FSign;
  end;
end;

constructor BigInteger.Create(const ANumber: UInt64);
begin
  { Try the cache first }
  if ANumber <= NativeUInt(High(FCached_Numbers)) then
    FData := FCached_Numbers[ANumber]
  else begin
    { Otherwise let's see (it's always positive) }
    FData := TData.Make(BigCardinal.Create(ANumber), 1);
  end;
end;

constructor BigInteger.Create(const ANumber: Cardinal);
begin
  { Try the cache first }
  if ANumber <= NativeUInt(High(FCached_Numbers)) then
    FData := FCached_Numbers[ANumber]
  else begin
    { Otherwise let's see (it's always positive) }
    FData := TData.Make(BigCardinal.Create(ANumber), 1);
  end;
end;

constructor BigInteger.Create(const ANumber: BigInteger);
begin
  { Just copy the enclosed data }
  FData := ANumber.FData;
end;

constructor BigInteger.Create(const ANumber: Int64);
var
  S: SmallInt;
begin
  { Try the cache first }
  if (ANumber >= Low(FCached_Numbers)) and (ANumber <= High(FCached_Numbers)) then
    FData := FCached_Numbers[ANumber]
  else begin
    if ANumber < 0 then S := -1
    else if ANumber > 0 then S := 1
    else S := 0;

    { Otherwise let's see (detect sign ) }
    FData := TData.Make(BigCardinal.Create(ANumber * S), S);
  end;
end;

constructor BigInteger.Create(const ANumber: Integer);
var
  S: SmallInt;
begin
  { Try the cache first }
  if (ANumber >= Low(FCached_Numbers)) and (ANumber <= High(FCached_Numbers)) then
    FData := FCached_Numbers[ANumber]
  else begin
    if ANumber < 0 then S := -1
    else if ANumber > 0 then S := 1
    else S := 0;

    { Otherwise let's see (detect sign ) }
    FData := TData.Make(BigCardinal.Create(ANumber * S), S);
  end;
end;

class operator BigInteger.Dec(const AValue: BigInteger): BigInteger;
var
  LData: TData;
begin
  { Get data }
  LData := AValue.GetData();

  if (LData.FSign = 0) then
    Result.FData := FCached_Numbers[-1] { 0 - 1 = -1 }
  else if LData.FSign < 0 then
    Result.FData := TData.Make(LData.FMagnitude + BigCardinal.One, LData.FSign)
  else begin { LData.FSign > 0 }
    { It's a negative number. Check for -1 otherwise continue. }
    if LData.FMagnitude.CompareTo(BigCardinal.One) = 0 then
      Result.FData := FCached_Numbers[0]
    else
      Result.FData := TData.Make(LData.FMagnitude - BigCardinal.One, LData.FSign)
  end;
end;

class destructor BigInteger.Destroy;
begin
  { Unregister DeHL stuff (math extension goes first) }
  TMathExtension<BigInteger>.Unregister;
  TType<BigInteger>.Unregister;

  { Uregister our custom variant }
  FreeAndNil(SgtBigIntegerVariantType);
end;

function BigInteger.DivMod(const ADivisor: BigInteger; out ARemainder: BigInteger): BigInteger;
var
  LLData, LRData: TData;
  LQuotientMag, LRemainderMag: BigCardinal;
begin
  { Obtain the data object }
  LLData := GetData();
  LRData := ADivisor.GetData();

  { Left one is zero = 0 }
  if LLData.FSign = 0 then
  begin
    { Remainder and quotient are zero }
    Result.FData := FCached_Numbers[0];
    ARemainder.FData := Result.FData;
    Exit;
  end;

  { If dividing by zero ... well, error }
  if LRData.FSign = 0 then
    ExceptionHelper.Throw_DivByZeroError();

  { Do the normal division (unsigned) }
  LQuotientMag := LLData.FMagnitude.DivMod(LRData.FMagnitude, LRemainderMag);

  { Initialize quotient }
  if LQuotientMag.IsZero then
    Result.FData := FCached_Numbers[0]
  else
    Result.FData := TData.Make(LQuotientMag, LLData.FSign * LRData.FSign); { Combination of signs }

  { Initialize remainder }
  if LRemainderMag.IsZero then
    ARemainder.FData := FCached_Numbers[0]
  else
    ARemainder.FData := TData.Make(LRemainderMag, LLData.FSign); { Depends only on the dividend's sign }
end;

class operator BigInteger.Implicit(const ANumber: Cardinal): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: UInt64): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: Byte): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: Word): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: Integer): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: Int64): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: SmallInt): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: ShortInt): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Inc(const AValue: BigInteger): BigInteger;
var
  LData: TData;
begin
  { Get data }
  LData := AValue.GetData();

  if (LData.FSign = 0) then
    Result.FData := FCached_Numbers[1] { 0 + 1 = 1 }
  else if LData.FSign > 0 then
    Result.FData := TData.Make(LData.FMagnitude + BigCardinal.One, LData.FSign)
  else begin { LData.FSign < 0 }
    { It's a negative number. Check for -1 otherwise continue. }
    if LData.FMagnitude.CompareTo(BigCardinal.One) = 0 then
      Result.FData := FCached_Numbers[0]
    else
      Result.FData := TData.Make(LData.FMagnitude - BigCardinal.One, LData.FSign)
  end;
end;

class operator BigInteger.IntDivide(const ALeft, ARight: BigInteger): BigInteger;
var
  LDummy: BigInteger;
begin
  { Call internal }
  Result := ALeft.DivMod(ARight, LDummy);
end;

class operator BigInteger.Equal(const ALeft, ARight: BigInteger): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) = 0);
end;

class operator BigInteger.Explicit(const ANumber: BigInteger): ShortInt;
begin
  { Call convertion code }
  Result := ANumber.ToShortInt();
end;

class operator BigInteger.Explicit(const ANumber: BigInteger): Int64;
begin
  { Call convertion code }
  Result := ANumber.ToInt64();
end;

class operator BigInteger.Explicit(const ANumber: BigInteger): SmallInt;
begin
  { Call convertion code }
  Result := ANumber.ToSmallInt();
end;

class operator BigInteger.Explicit(const ANumber: BigInteger): Integer;
begin
  { Call convertion code }
  Result := ANumber.ToInteger();
end;

function BigInteger.GetData: TData;
begin
  { Try to get the enclused object. If this number is not well formed,
    use zero's information. }
  if Assigned(FData) then
    Result := FData.GetData()
  else
    Result := FCached_Numbers[0].GetData();
end;

function BigInteger.GetIsEven: Boolean;
begin
  { Obtain the object and check for sign }
  Result := GetData().FMagnitude.IsEven;
end;

function BigInteger.GetIsNegative: Boolean;
begin
  { Obtain the object and check for sign }
  Result := (GetData().FSign < 0);
end;

function BigInteger.GetIsOdd: Boolean;
begin
  { Obtain the object and check for sign }
  Result := GetData().FMagnitude.IsOdd;
end;

function BigInteger.GetIsPositive: Boolean;
begin
  { Obtain the object and check for sign }
  Result := (GetData().FSign >= 0);
end;

function BigInteger.GetIsZero: Boolean;
begin
  { Obtain the object and check for sign }
  Result := (GetData().FSign = 0);
end;

class function BigInteger.GetMinusOne: BigInteger;
begin
  { Serve a cached number please }
  Result.FData := FCached_Numbers[-1];
end;

class function BigInteger.GetMinusTen: BigInteger;
begin
  { Serve a cached number please }
  Result.FData := FCached_Numbers[-10];
end;

class function BigInteger.GetOne: BigInteger;
begin
  { Serve a cached number please }
  Result.FData := FCached_Numbers[1];
end;

function BigInteger.GetSign: SmallInt;
begin
  { Obtain the object and check for sign }
  Result := GetData().FSign;
end;

class function BigInteger.GetTen: BigInteger;
begin
  { Serve a cached number please }
  Result.FData := FCached_Numbers[10];
end;

class function BigInteger.GetType: IType<BigInteger>;
begin
  Result := TBigIntegerType.Create();
end;

class function BigInteger.GetZero: BigInteger;
begin
  { Serve a cached number please }
  Result.FData := FCached_Numbers[0];
end;

class operator BigInteger.GreaterThan(const ALeft, ARight: BigInteger): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) > 0);
end;

class operator BigInteger.GreaterThanOrEqual(const ALeft, ARight: BigInteger): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) >= 0);
end;

class operator BigInteger.LeftShift(const AValue: BigInteger; const ACount: NativeUInt): BigInteger;
var
  LData: TData;
begin
  { Check for zero shift }
  if ACount = 0 then
    Result.FData := AValue.FData
  else
  begin
    { Get the data }
    LData := AValue.GetData();
    Result.FData := TData.Make(LData.FMagnitude shl ACount, LData.FSign);
  end;
end;

class operator BigInteger.LessThan(const ALeft, ARight: BigInteger): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) < 0);
end;

class operator BigInteger.LessThanOrEqual(const ALeft, ARight: BigInteger): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) <= 0);
end;

class operator BigInteger.Modulus(const ALeft, ARight: BigInteger): BigInteger;
begin
  { Call internal }
  ALeft.DivMod(ARight, Result);
end;

class operator BigInteger.Multiply(const ALeft, ARight: BigInteger): BigInteger;
var
  LLData, LRData: TData;
begin
  { Get data }
  LLData := ALeft.GetData();
  LRData := ARight.GetData();

  { Either one is zero = 0 }
  if (LLData.FSign = 0) or (LLData.FSign = 0) then
    Result.FData := FCached_Numbers[0]
  else
    Result.FData := TData.Make(LLData.FMagnitude * LRData.FMagnitude,
      LLData.FSign * LRData.FSign);
end;

class operator BigInteger.Negative(const AValue: BigInteger): BigInteger;
var
  LData: TData;
begin
  { Get data }
  LData := AValue.GetData();

  { Check for zero and continue otherwise }
  if LData.FSign = 0 then
    Result.FData := FCached_Numbers[0]
  else
    Result.FData := TData.Make(LData.FMagnitude, -LData.FSign);
end;

class operator BigInteger.NotEqual(const ALeft, ARight: BigInteger): Boolean;
begin
  Result := (ALeft.CompareTo(ARight) <> 0);
end;

class function BigInteger.Parse(const AString: string): BigInteger;
begin
  { Call the Try version }
  if not TryParse(AString, Result) then
    ExceptionHelper.Throw_ArgumentConverError('AString');
end;

class operator BigInteger.Positive(const AValue: BigInteger): BigInteger;
begin
  { Nothing ... }
  Result.FData := AValue.FData;
end;

function BigInteger.Pow(const AExponent: NativeUInt): BigInteger;
var
  LData: TData;
  LPowMag: BigCardinal;
  LNewSign: SmallInt;
begin
  { Obtain the data }
  LData := GetData();

  { Multiply magnitudes first }
  LPowMag := LData.FMagnitude.Pow(AExponent);

  { Adjust sign }
  if (LData.FSign < 0) and Odd(AExponent) then
    LNewSign := -1
  else
  begin
    if LPowMag.IsZero then
      LNewSign := 0
    else
      LNewSign := 1;
  end;

  { Create a new integer }
  Result.FData := TData.Make(LPowMag, LNewSign);
end;

class operator BigInteger.RightShift(const AValue: BigInteger; const ACount: NativeUInt): BigInteger;
var
  LData: TData;
  LNewMag: BigCardinal;
begin
  { Check for zero shift }
  if ACount = 0 then
    Result.FData := AValue.FData
  else
  begin
    { Get the data }
    LData := AValue.GetData();
    LNewMag := LData.FMagnitude shr ACount;

    { Check for zero before continuing }
    if LNewMag.IsZero then
      Result.FData := FCached_Numbers[0]
    else
      Result.FData := TData.Make(LNewMag, LData.FSign);
  end;
end;

class operator BigInteger.Subtract(const ALeft, ARight: BigInteger): BigInteger;
var
  LMagRel: NativeInt;
  LLData, LRData: TData;
begin
  { Get data }
  LLData := ALeft.GetData();
  LRData := ARight.GetData();

  if (LLData.FSign = 0) and (LRData.FSign = 0) then
    Result.FData := FCached_Numbers[0] { 0 - 0 = 0 }
  else if (LLData.FSign = 0) then
    Result.FData := TData.Make(LRData.FMagnitude, -LRData.FSign) { 0 - R = -R }
  else if (LRData.FSign = 0) then
    Result.FData := ALeft.FData { L - 0 = L }
  else begin
    { Both numbers are non-zero }
    if LLData.FSign <> LRData.FSign then
    begin
      { 1. Signs differ => (-X) - (+Y) = -(X + Y) or (+X) - (-Y) = +(X +Y) }
      Result.FData := TData.Make(LLData.FMagnitude + LRData.FMagnitude, LLData.FSign);
    end else
    begin
      { 2. Same sign => mupltiple cases. First compare the magnitudes. }
      LMagRel := LLData.FMagnitude.CompareTo(LRData.FMagnitude);

      { If magnitudes are equal, the reault of the subtraction is zero. }
      if LMagRel = 0 then
        Result.FData := FCached_Numbers[0]
      else if LMagRel > 0 then { Left magnitude is bigger than the right one. }
        Result.FData := TData.Make(LLData.FMagnitude - LRData.FMagnitude, LLData.FSign)
      else { Right magnitude is bigger then the left one. }
        Result.FData := TData.Make(LRData.FMagnitude - LLData.FMagnitude, -LRData.FSign);
    end;
  end;
end;

function BigInteger.ToInt64: Int64;
var
  LData: TData;
begin
  { Obtain the data and the multiply stuff }
  LData := GetData();

  { Zero or not }
  if LData.FSign <> 0 then
    Result := LData.FSign * LData.FMagnitude.ToInt64()
  else
    Result := 0;
end;

function BigInteger.ToInteger: Integer;
var
  LData: TData;
begin
  { Obtain the data and the multiply stuff }
  LData := GetData();

  { Zero or not }
  if LData.FSign <> 0 then
    Result := LData.FSign * LData.FMagnitude.ToInteger()
  else
    Result := 0;
end;

function BigInteger.ToShortInt: ShortInt;
var
  LData: TData;
begin
  { Obtain the data and the multiply stuff }
  LData := GetData();

  { Zero or not }
  if LData.FSign <> 0 then
    Result := LData.FSign * LData.FMagnitude.ToShortInt()
  else
    Result := 0;
end;

function BigInteger.ToSmallInt: SmallInt;
var
  LData: TData;
begin
  { Obtain the data and the multiply stuff }
  LData := GetData();

  { Zero or not }
  if LData.FSign <> 0 then
    Result := LData.FSign * LData.FMagnitude.ToSmallInt()
  else
    Result := 0;
end;

function BigInteger.ToString: string;
var
  LData: TData;
begin
  { Obtain the data }
  LData := GetData();

  { Obtain the magnitude (natural) }
  Result := LData.FMagnitude.ToString();

  { Append the minus sign if needed }
  if LData.FSign < 0 then
    Result := '-' + Result;
end;

class function BigInteger.TryParse(const AString: string; out ABigInteger: BigInteger): Boolean;
var
  S2: String;
  LMagnitude: BigCardinal;
  LSign: SmallInt;
begin
  Result := false;
  S2 := TrimLeft(AString);

  if Length(S2) = 0 then
    Exit;

  { Check the sign part }
  if S2[1] = '-' then
  begin
    LSign := -1;
    Delete(S2, 1, 1);
  end
  else if S2[1] = '+' then
  begin
    LSign := 1;
    Delete(S2, 1, 1);
  end else LSign := 1;

  { Call BigCardinal.TryParse }
  Result := BigCardinal.TryParse(S2, LMagnitude);

  if Result then
  begin
    { Check the sign again!! }
    if LMagnitude.IsZero then
      LSign := 0;

    { And finally make it! }
    ABigInteger.FData := TData.Make(LMagnitude, LSign);
  end;
end;

constructor BigInteger.Create(const ANumber: BigCardinal);
begin
  { Create using big cardinal }
  FData := TData.Make(ANumber, 1);
end;

class constructor BigInteger.Create;
var
  I: NativeInt;
  S: SmallInt;
begin
  { DeHL type support stuff }
  TType<BigInteger>.Register(TBigIntegerType);
  TMathExtension<BigInteger>.Register(TBigIntegerMathExtension);

  { Register our custom variant type }
  SgtBigIntegerVariantType := TBigIntegerVariantType.Create();

  { Set the value of the varBigInteger }
  FVarType := SgtBigIntegerVariantType.VarType;

  { Initialize statics }
  for I := Low(FCached_Numbers) to High(FCached_Numbers) do
  begin
    if I < 0 then S := -1
    else if I > 0 then S := 1
    else S := 0;

    { Build up the number }
    FCached_Numbers[I] := TData.Make(BigCardinal.Create(System.Abs(I)), S);
  end;
end;

class operator BigInteger.Implicit(const ANumber: BigCardinal): BigInteger;
begin
  { Call constructor }
  Result := BigInteger.Create(ANumber);
end;

class operator BigInteger.Implicit(const ANumber: BigInteger): Variant;
begin
  { Clear out the result }
  VarClear(Result);

  with TBigIntegerVarData(Result) do
  begin
    { Assign the new variant the var type that was allocated for us }
    VType := FVarType;

    { Copy self to this memory }
    BigIntegerIntf := ANumber.FData;
  end;
end;

class operator BigInteger.Explicit(const ANumber: Variant): BigInteger;
begin
  { Call this one }
  Result := SgtBigIntegerVariantType.VarDataToBigInteger(TVarData(ANumber));
end;

{ TBigIntegerType }

function TBigIntegerType.Compare(const AValue1, AValue2: BigInteger): NativeInt;
begin
  Result := AValue1.CompareTo(AValue2);
end;

constructor TBigIntegerType.Create;
begin
  inherited;
  FBigCardinalType := BigCardinal.GetType();
end;

procedure TBigIntegerType.DoDeserialize(const AInfo: TValueInfo; out AValue: BigInteger; const AContext: IDeserializationContext);
var
  LStr: String;
  LSign: SmallInt;
  LMagnitude: BigCardinal;
begin
  { Either use my routine or call the inherited one to do the job }
  if AContext.InReadableForm then
  begin
    AContext.GetValue(AInfo, LStr);
    AValue := BigInteger.Parse(LStr);
  end else
  begin
    { Open }
    AContext.ExpectRecordType(AInfo);

    { Extract each part of the record }
    AContext.GetValue(TValueInfo.Create(SSign), LSign);
    FBigCardinalType.Deserialize(TValueInfo.Create(SMagnitude), LMagnitude, AContext);

    { Build up the value }
    AValue.FData := BigInteger.TData.Make(LMagnitude, LSign);

    { Close }
    AContext.EndComplexType();
  end;
end;

procedure TBigIntegerType.DoSerialize(const AInfo: TValueInfo; const AValue: BigInteger;
  const AContext: ISerializationContext);
var
  LData: BigInteger.TData;
begin
  { Either use my routine or call the inherited one to do the job }
  if AContext.InReadableForm then
    AContext.AddValue(AInfo, AValue.ToString())
  else
  begin
    { Open }
    AContext.StartRecordType(AInfo);

    { Get the data }
    LData := AValue.GetData();

    { Extract each part of the record }
    AContext.AddValue(TValueInfo.Create(SSign), LData.FSign);
    FBigCardinalType.Serialize(TValueInfo.Create(SMagnitude), LData.FMagnitude, AContext);

    { Close }
    AContext.EndComplexType();
  end;
end;

function TBigIntegerType.Family: TTypeFamily;
begin
  Result := tfSignedInteger;
end;

function TBigIntegerType.GenerateHashCode(const AValue: BigInteger): NativeInt;
var
  LData: BigInteger.TData;
begin
  { Get Data }
  LData := AValue.GetData();

  { Exit with 0 on 0 size }
  if LData.FSign = 0 then
    Exit(0);

  { Call the Type-Support provided function }
  Result := LData.FSign * FBigCardinalType.GenerateHashCode(LData.FMagnitude);
end;

function TBigIntegerType.GetString(const AValue: BigInteger): String;
begin
  Result := AValue.ToString();
end;

function TBigIntegerType.TryConvertFromVariant(const AValue: Variant; out ORes: BigInteger): Boolean;
begin
  { May not be a valid BigCardinal }
  try
    ORes := SgtBigIntegerVariantType.VarDataToBigInteger(TVarData(AValue));
  except
    Exit(false);
  end;

  Result := true;
end;

function TBigIntegerType.TryConvertToVariant(const AValue: BigInteger; out ORes: Variant): Boolean;
begin
  { Simple variant conversion }
  ORes := AValue;
  Result := true;
end;

{ TBigIntegerMathExtension }

function TBigIntegerMathExtension.Abs(const AValue: BigInteger): BigInteger;
begin
  Result := AValue.Abs();
end;

function TBigIntegerMathExtension.Add(const AValue1, AValue2: BigInteger): BigInteger;
begin
  Result := AValue1 + AValue2;
end;

function TBigIntegerMathExtension.IntegralDivide(const AValue1, AValue2: BigInteger): BigInteger;
begin
  Result := AValue1 div AValue2;
end;

function TBigIntegerMathExtension.MinusOne: BigInteger;
begin
  Result := BigInteger.MinusOne;
end;

function TBigIntegerMathExtension.Modulo(const AValue1, AValue2: BigInteger): BigInteger;
begin
  Result := AValue1 mod AValue2;
end;

function TBigIntegerMathExtension.Multiply(const AValue1, AValue2: BigInteger): BigInteger;
begin
  Result := AValue1 * AValue2;
end;

function TBigIntegerMathExtension.Negate(const AValue: BigInteger): BigInteger;
begin
  Result := -AValue;
end;

function TBigIntegerMathExtension.One: BigInteger;
begin
  Result := BigInteger.One;
end;

function TBigIntegerMathExtension.Subtract(const AValue1, AValue2: BigInteger): BigInteger;
begin
  Result := AValue1 - AValue2;
end;

function TBigIntegerMathExtension.Zero: BigInteger;
begin
  Result := BigInteger.Zero;
end;

end.
