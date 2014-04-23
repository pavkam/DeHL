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
unit DeHL.Math.BigDecimal;
interface
uses SysUtils,
     Variants,
     DeHL.Base,
     DeHL.Types,
     DeHL.Cloning,
     DeHL.Serialization,
     DeHL.Exceptions,
     DeHL.Math.Types,
     DeHL.Math.BigCardinal,
     DeHL.Math.BigInteger;

type
  ///  <summary>Defines a number of rounding modes used by the <c>BigDecimal</c> type.</summary>
  TRoundingMode = (
    ///  <summary>Rounds up from zero.</summary>
    rmUp,
    ///  <summary>Rounds down towards zero until.</summary>
    rmDown,
    ///  <summary>Rounds towards positive infinity.</summary>
    rmCeiling,
    ///  <summary>Rounds towards negative infinity.</summary>
    rmFloor,
    ///  <summary>Rounds each digit (including <c>5</c>) towards the left digit.</summary>
    rmHalfUp,
    ///  <summary>Rounds each digit (excluding <c>5</c>) towards the left digit.</summary>
    rmHalfDown,
    ///  <summary>Rounds each digit towards the left digit. <c>5</c> is rounded to the even digit.</summary>
    rmHalfEven,
    ///  <summary>No rounding is performed. This is the default mode.</summary>
    rmNone
  );

  ///  <summary>Unlimited precision decimal number.</summary>
  ///  <remarks>This type offers both controllable and unlimited precision arithmetic. For code that requires
  ///  precise calculation with fixed rules, <c>BigDecimal</c> is the best choice. <c>BigDecimal</c> does not suffer
  ///  from the problems usually associated with floating-point numbers.</remarks>
  BigDecimal = record
  private type
    { Internal-only types }
    TData = class;
    IData = interface
      function GetData: BigDecimal.TData;
    end;
    TData = class(TInterfacedObject, IData)
      FBigInteger: BigInteger;
      FBigIntegerStr: string;
      FScale: NativeInt;
      FPrecision: NativeUInt;
      function GetData: TData;
      class function Make(
        const ABigInteger: BigInteger;
        const AScale: NativeInt;
        const APrecision: NativeUInt): IData;
    end;

  private
    class var FVarType: TVarType;

    { Internal cache }
    class var FCached_Numbers: array[-10..10] of IData;
    class var FFastPower: array[0..10] of BigInteger;

    { Initialization }
    class constructor Create;
    class destructor Destroy;

    { Getters }
    class function GetMinusOne: BigDecimal; inline; static;
    class function GetMinusTen: BigDecimal; inline; static;
    class function GetOne: BigDecimal; inline; static;
    class function GetTen: BigDecimal; inline; static;
    class function GetZero: BigDecimal; inline; static;
  private
    FData: IData;

    { Internals }
    function GetData(): TData; inline;
    class function InternalGetPrecision(const AData: TData): NativeUInt; static;
    class function InternalGetBigIntegerStr(const AData: TData): string; static;
    class function InternalGetBigIntegerAbsStr(const AData: TData): string; static;

    class function CutAndValidate(const AStr: string; const AThSep: Char; var ADotIdx: NativeInt): string; static;
    class function InternalTryParse(const AStr: string; out ANumber: BigDecimal;
      const ADecSep, AThSep: Char): Boolean; static;

    function InternalToString(const AScientific: Boolean; const ADecSep: Char): string;
    class function InternalDivide(const ADividend, ADivisor: TData; const ANewScale: NativeInt;
      const ARoundingMode: TRoundingMode): BigDecimal; static;
    function InternalPow(const APower: NativeInt; const AUseScale: Boolean; const ANewScale: NativeInt;
      const ARoundingMode: TRoundingMode): BigDecimal;
    class function PowerOfTen(const APower: NativeInt): BigInteger; static;

    { Getters }
    function GetPrecision: NativeUInt;
    function GetScale: NativeInt;
    function GetIsNegative: Boolean;
    function GetIsPositive: Boolean;
    function GetIsZero: Boolean;
    function GetSign: SmallInt;
  public
    ///  <summary>Initializes a <c>BigDecimal</c> with a given <c>Integer</c> value and an option scale.</summary>
    ///  <param name="AValue">The value to use for the new <c>BigDecimal</c>.</param>
    ///  <param name="AScale">An optional scale. The default value is <c>0</c>.</param>
    ///  <remarks>The <paramref name="AScale"/> parameter specifies the number of digits that are considered to be on the
    ///  right of the decimal separator. In essence, the numerical value of this <c>BigDecimal</c> is
    ///  <c><paramref name="AValue"/> * 10^(-<paramref name="AScale"/>)</c>.</remarks>
    constructor Create(const AValue: Integer; const AScale: NativeInt = 0); overload;

    ///  <summary>Initializes a <c>BigDecimal</c> with a given <c>Cardinal</c> value and an option scale.</summary>
    ///  <param name="AValue">The value to use for the new <c>BigDecimal</c>.</param>
    ///  <param name="AScale">An optional scale. The default value is <c>0</c>.</param>
    ///  <remarks>The <paramref name="AScale"/> parameter specifies the number of digits that are considered to be on the
    ///  right of the decimal separator. In essence, the numerical value of this <c>BigDecimal</c> is
    ///  <c><paramref name="AValue"/> * 10^(-<paramref name="AScale"/>)</c>.</remarks>
    constructor Create(const AValue: Cardinal; const AScale: NativeInt = 0); overload;

    ///  <summary>Initializes a <c>BigDecimal</c> with a given <c>Int64</c> value and an option scale.</summary>
    ///  <param name="AValue">The value to use for the new <c>BigDecimal</c>.</param>
    ///  <param name="AScale">An optional scale. The default value is <c>0</c>.</param>
    ///  <remarks>The <paramref name="AScale"/> parameter specifies the number of digits that are considered to be on the
    ///  right of the decimal separator. In essence, the numerical value of this <c>BigDecimal</c> is
    ///  <c><paramref name="AValue"/> * 10^(-<paramref name="AScale"/>)</c>.</remarks>
    constructor Create(const AValue: Int64; const AScale: NativeInt = 0); overload;

    ///  <summary>Initializes a <c>BigDecimal</c> with a given <c>UInt64</c> value and an option scale.</summary>
    ///  <param name="AValue">The value to use for the new <c>BigDecimal</c>.</param>
    ///  <param name="AScale">An optional scale. The default value is <c>0</c>.</param>
    ///  <remarks>The <paramref name="AScale"/> parameter specifies the number of digits that are considered to be on the
    ///  right of the decimal separator. In essence, the numerical value of this <c>BigDecimal</c> is
    ///  <c><paramref name="AValue"/> * 10^(-<paramref name="AScale"/>)</c>.</remarks>
    constructor Create(const AValue: UInt64; const AScale: NativeInt = 0); overload;

    ///  <summary>Initializes a <c>BigDecimal</c> with a given <c>BigInteger</c> value and an option scale.</summary>
    ///  <param name="AValue">The value to use for the new <c>BigDecimal</c>.</param>
    ///  <param name="AScale">An optional scale. The default value is <c>0</c>.</param>
    ///  <remarks>The <paramref name="AScale"/> parameter specifies the number of digits that are considered to be on the
    ///  right of the decimal separator. In essence, the numerical value of this <c>BigDecimal</c> is
    ///  <c><paramref name="AValue"/> * 10^(-<paramref name="AScale"/>)</c>.</remarks>
    constructor Create(const AValue: BigInteger; const AScale: NativeInt = 0); overload;

    ///  <summary>Initializes a <c>BigDecimal</c> with a given <c>BigCardinal</c> value and an option scale.</summary>
    ///  <param name="AValue">The value to use for the new <c>BigDecimal</c>.</param>
    ///  <param name="AScale">An optional scale. The default value is <c>0</c>.</param>
    ///  <remarks>The <paramref name="AScale"/> parameter specifies the number of digits that are considered to be on the
    ///  right of the decimal separator. In essence, the numerical value of this <c>BigDecimal</c> is
    ///  <c><paramref name="AValue"/> * 10^(-<paramref name="AScale"/>)</c>.</remarks>
    constructor Create(const AValue: BigCardinal; const AScale: NativeInt = 0); overload;

    ///  <summary>Initializes a <c>BigDecimal</c> with a given <c>Double</c> value.</summary>
    ///  <param name="AValue">The value to use for the new <c>BigDecimal</c>.</param>
    ///  <remarks>This method decomposes a <c>Double</c> value and then initializes the <c>BigDecimal</c>
    ///  based on the extracted mantissa and exponent. Note that this constructor is not recommended for use since
    ///  a floating-point value cannot be  perfectly converted into a <c>BigDecimal</c>. In case this constructor
    ///  is required, make sure to round the resulting <c>BigDecimal</c>.</remarks>
    constructor Create(const AValue: Double); overload;

    ///  <summary>Compares this <c>BigDecimal</c> to another <c>BigDecimal</c>.</summary>
    ///  <param name="ANumber">The <c>BigDecimal</c> value to compare with.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - this <c>BigDecimal</c> is less than <paramref name="ANumber"/>.
    ///  If the result is zero - this <c>BigDecimal</c> is equal to <paramref name="ANumber"/>. And finally,
    ///  if the result is greater than zero - this <c>BigDecimal</c> is greater than <paramref name="ANumber"/>.</returns>
    ///  <remarks>This method does not take trailing zeros into account, thus, for example <c>1.200</c> if considered to be equal to
    ///  <c>1.2</c>.</remarks>
    function CompareTo(const ANumber: BigDecimal): NativeInt;

    ///  <summary>Converts this <c>BigDecimal</c> to a <c>Double</c> value.</summary>
    ///  <returns>A <c>Double</c> that contains a value "equal" to this <c>BigDecimal</c>.</returns>
    ///  <remarks>Because <c>BigDecimal</c> can store very large numbers, this method may return a value that is not nearly
    ///  equal to the <c>BigDecimal</c>'s value. Be sure to use this method only for relatively small <c>BigDecimal</c> values.</remarks>
    function ToDouble: Double; inline;

    ///  <summary>Truncates this <c>BigDecimal</c>.</summary>
    ///  <returns>A <c>BigInteger</c> that contains the truncated <c>BigDecimal</c>.</returns>
    ///  <remarks>This method removes all the digits following the decimal point and returns only the integral part of the
    ///  this <c>BigDecimal</c> value.</remarks>
    function Truncate: BigInteger;

    ///  <summary>Returns the absoulte value of this <c>BigDecimal</c>.</summary>
    ///  <returns>A new <c>BigDecimal</c> that contains the absolute value of this <c>BigDecimal</c>.</returns>
    function Abs: BigDecimal;

    ///  <summary>Checks whether this <c>BigDecimal</c> is zero.</summary>
    ///  <returns><c>True</c> if this <c>BigDecimal</c> is zero; <c>False</c> otherwise.</returns>
    property IsZero: Boolean read GetIsZero;

    ///  <summary>Checks whether this <c>BigDecimal</c> is negative.</summary>
    ///  <returns><c>True</c> if this <c>BigDecimal</c> is negative; <c>False</c> otherwise.</returns>
    property IsNegative: Boolean read GetIsNegative;

    ///  <summary>Checks whether this <c>BigDecimal</c> is zero or positive.</summary>
    ///  <returns><c>True</c> if this <c>BigDecimal</c> is zero or positive; <c>False</c> otherwise.</returns>
    property IsPositive: Boolean read GetIsPositive;

    ///  <summary>Returns the precision of this <c>BigDecimal</c>.</summary>
    ///  <returns>A positive number specifying the precision of this <c>BigDecimal</c>.</returns>
    ///  <remarks>The precision represents the number of digits contained whithin this <c>BigDecimal</c> value.
    ///  For example the precision of <c>10.22</c> is <c>4</c>.</remarks>
    property Precision: NativeUInt read GetPrecision;

    ///  <summary>Returns the scale of this <c>BigDecimal</c>.</summary>
    ///  <returns>A positive or negative number specifying the scale of this <c>BigDecimal</c>.</returns>
    ///  <remarks>The scale is an integer value that specifies the number of digits situated to the right of the decimal point.
    ///  If the scale is negative, then it represents the number of zeros between the decimal point the actual number.
    ///  In essence the numerical value of this <c>BigDecimal</c> is <c>N * 10^(-Scale)</c>. For example, <c>6.99</c> has a scale of
    ///  <c>2</c> while <c>1900</c> can be represented as <c>19</c> with the scale of <c>-2</c>.</remarks>
    property Scale: NativeInt read GetScale;

    ///  <summary>Specifies the sign of this <c>BigDecimal</c>.</summary>
    ///  <returns><c>-1</c> if this <c>BigDecimal</c> is negative; <c>0</c> if this <c>BigDecimal</c> is zero; and
    ///  <c>1</c> if this <c>BigDecimal</c> is positive.</returns>
    property Sign: SmallInt read GetSign;

    ///  <summary>Divides this <c>BigDecimal</c> to another <c>BigDecimal</c>.</summary>
    ///  <param name="ADivisor">The <c>BigDecimal</c> to divide to.</param>
    ///  <param name="ANewScale">The scale that will be used for the resulting <c>BigDecimal</c>.</param>
    ///  <param name="ARoundingMode">The rounding mode. Default is <c>rmNone</c>.</param>
    ///  <returns>A new <c>BigDecimal</c> containing the division result.</returns>
    ///  <exception cref="SysUtils|EDivByZero"><paramref name="ADivisor"/> is zero.</exception>
    ///  <exception cref="SysUtils|EInvalidOp">The numbers cannot be divided without rounding and
    ///  <paramref name="ARoundingMode"/> is set to <c>rmNone</c>.</exception>
    ///  <remarks>This method divides this <c>BigDecimal</c> to <paramref name="ADivisor"/>. In the division process it is important
    ///  to specify the scale of the result, because the number of digits after the decimal point can vary a lot.
    ///  <paramref name="ARoundingMode"/> is used to adjust the result to the desired <paramref name="ANewScale"/>.
    ///  For example, the result of <c>1/3</c> is <c>0.3333...</c>. If <paramref name="ANewScale"/> is set to <c>2</c> and
    ///  <paramref name="ARoundingMode"/> is set to <c>rmUp</c>, the result of the operation is <c>0.34</c>. The "infinte" number was
    ///  rounded using the provided rule, until the desired scale is reached.</remarks>
    function Divide(const ADivisor: BigDecimal; const ANewScale: NativeInt;
      const ARoundingMode: TRoundingMode = rmNone): BigDecimal; overload;

    ///  <summary>Divides this <c>BigDecimal</c> to another <c>BigDecimal</c>.</summary>
    ///  <param name="ADivisor">The <c>BigDecimal</c> to divide to.</param>
    ///  <param name="ARoundingMode">The rounding mode. Default is <c>rmNone</c>.</param>
    ///  <returns>A new <c>BigDecimal</c> containing the division result.</returns>
    ///  <exception cref="SysUtils|EDivByZero"><paramref name="ADivisor"/> is zero.</exception>
    ///  <exception cref="SysUtils|EInvalidOp">The numbers cannot be divided without rounding and
    ///  <paramref name="ARoundingMode"/> is set to <c>rmNone</c>.</exception>
    ///  <remarks>The scale of the result is calculated as the difference between the <c>BigDecimal</c>'s scale
    ///  and the <paramref name="ADivisor"/>'s scale. <paramref name="ARoundingMode"/> is used to adjust the result until the
    ///  calculated scale is reached. Use the first version of this method if explicit scale control is required.</remarks>
    function Divide(const ADivisor: BigDecimal;
      const ARoundingMode: TRoundingMode = rmNone): BigDecimal; overload; inline;

    ///  <summary>Rounds this <c>BigDecimal</c> to a given precision.</summary>
    ///  <param name="ANewPrecision">The new precision.</param>
    ///  <param name="ARoundingMode">The rounding mode. Default is <c>rmNone</c>.</param>
    ///  <returns>A new <c>BigDecimal</c> containing the rounded result.</returns>
    ///  <exception cref="SysUtils|EInvalidOp">Cannot round cleanly if the mode is <c>rmNone</c>.</exception>
    ///  <remarks>This method rounds the <c>BigDecimal</c> to the given precision using the supplied mode.
    ///  The scale is adjusted so that the required precision is met. For example, rounding <c>1.78</c> to a precision of <c>2</c>
    ///  with a mode of <c>rmUp</c> results in <c>1.8</c>. The same principle applies when rounding integral decimals; for example
    ///  <c>178</c> is rounded to <c>180</c> if the same rules are used. The resulting number is <c>180</c>,
    ///  the precision is <c>2</c>, and the scale is <c>-1</c>.</remarks>
    function Round(const ANewPrecision: NativeUInt; const ARoundingMode: TRoundingMode = rmHalfEven): BigDecimal;

    ///  <summary>Re-scales this <c>BigDecimal</c>.</summary>
    ///  <param name="ANewScale">The new scale.</param>
    ///  <param name="ARoundingMode">The rounding mode. Default is <c>rmNone</c>.</param>
    ///  <returns>A new <c>BigDecimal</c> with an adjusted scale.</returns>
    ///  <remarks>This method only allows adjusting a positive scale. This means that you can only adjust the number
    ///  of digits following the decimal point. If the new scale is bigger than the current scale, no precision is lost. If
    ///  the new scale is smaller than the current one, the removed digits are rounded using the supplied rounding mode.
    ///  For example, rescaling <c>1.22</c> to the scale of <c>5</c> results in a number equal to <c>1.22000</c>; rescaling
    ///  <c>1.22</c> to the scale of <c>1</c> and using <c>rmUp</c> rounding mode results in a number equal to <c>1.3</c>.</remarks>
    ///  <exception cref="SysUtils|EArgumentOutOfRangeException"><paramref name="ANewScale"/> is negative.</exception>
    ///  <exception cref="SysUtils|EInvalidOp">The number cannot be rescaled without rounding and
    ///  <paramref name="ARoundingMode"/> is set to <c>rmNone</c>.</exception>
    function Rescale(const ANewScale: NativeInt; const ARoundingMode: TRoundingMode = rmNone): BigDecimal; inline;

    ///  <summary>Scales this <c>BigDecimal</c> by a power of ten.</summary>
    ///  <param name="AScale">The power of ten to scale with.</param>
    ///  <returns>A new <c>BigDecimal</c> whose value is the original <c>BigDecimal</c> multiplied by ten at a given power.</returns>
    ///  <remarks>The resulting number is equal to <c>N * 10^<paramref name="AScale"/></c>. This method is the preferred way
    ///  of scaling to the power of ten because it simply adjusts the scale and does not multiply anything.</remarks>
    function ScaleByPowerOfTen(const AScale: NativeInt): BigDecimal; inline;

    ///  <summary>Raises this <c>BigDecimal</c> to a given power.</summary>
    ///  <param name="AExponent">The exponent. Can be negative.</param>
    ///  <param name="ARoundingMode">The rounding mode. Default is <c>rmNone</c>.</param>
    ///  <returns>A new <c>BigDecimal</c> whose value is <c>N^<paramref name="AExponent"/></c>.</returns>
    ///  <remarks>If <paramref name="AExponent"/> is negative, <paramref name="ARoundingMode"/> is used to round the
    ///  result. The scale is automatically calculated.</remarks>
    ///  <exception cref="SysUtils|EInvalidOp">The operation cannot continue without rounding and
    ///  <paramref name="ARoundingMode"/> is set to <c>rmNone</c>.</exception>
    function Pow(const AExponent: NativeInt; const ARoundingMode: TRoundingMode = rmNone): BigDecimal; overload; inline;

    ///  <summary>Raises this <c>BigDecimal</c> to a given power.</summary>
    ///  <param name="AExponent">The exponent. Can be negative.</param>
    ///  <param name="ANewScale">The new scale. Cannot be negative.</param>
    ///  <param name="ARoundingMode">The rounding mode. Default is <c>rmNone</c>.</param>
    ///  <returns>A new <c>BigDecimal</c> whose value is <c>N^<paramref name="AExponent"/></c>.</returns>
    ///  <remarks>If <paramref name="AExponent"/> is negative, <paramref name="ARoundingMode"/> is used to round the
    ///  result. The scale is automatically calculated.</remarks>
    ///  <exception cref="SysUtils|EInvalidOp">The operation cannot continue without rounding and
    ///  <paramref name="ARoundingMode"/> is set to <c>rmNone</c>.</exception>
    ///  <exception cref="SysUtils|EArgumentOutOfRangeException"><paramref name="ANewScale"/> is negative.</exception>
    function Pow(const AExponent: NativeInt; const ANewScale: NativeInt;
      const ARoundingMode: TRoundingMode = rmNone): BigDecimal; overload; inline;

    ///  <summary>Tries to convert a string value to a <c>BigDecimal</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <param name="AFormatSettings">The format settings. Both decimal and thousands separators are used.</param>
    ///  <param name="ANumber">An output <c>BigDecimal</c> converted from the given string.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    class function TryParse(const AString: string; out ANumber: BigDecimal;
      const AFormatSettings: TFormatSettings): Boolean; overload; static;

    ///  <summary>Tries to convert a string value to a <c>BigDecimal</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <param name="ANumber">An output <c>BigDecimal</c> converted from the given string.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    class function TryParse(const AString: string; out ANumber: BigDecimal): Boolean; overload; static;

    ///  <summary>Converts a string value to a <c>BigDecimal</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <param name="AFormatSettings">The format settings. Both decimal and thousands separators are used.</param>
    ///  <returns>The converted <c>BigDecimal</c> value.</returns>
    ///  <exception cref="SysUtils|EConvertError">The string does not represent a valid number.</exception>
    class function Parse(const AString: string; const AFormatSettings: TFormatSettings): BigDecimal; overload; static;

    ///  <summary>Converts a string value to a <c>BigDecimal</c>.</summary>
    ///  <param name="AString">A string value.</param>
    ///  <returns>The converted <c>BigDecimal</c> value.</returns>
    ///  <exception cref="SysUtils|EConvertError">The string does not represent a valid number.</exception>
    class function Parse(const AString: string): BigDecimal; overload; static;

    ///  <summary>Converts this <c>BigDecimal</c> to a string value.</summary>
    ///  <param name="AScientificFormat">Specifies whether scientifir notation is used. Default is <c>False</c>.</param>
    ///  <param name="AFormatSettings">Specifies the format settings.</param>
    ///  <returns>The string representation of this <c>BigDecimal</c>.</returns>
    ///  <remarks>If scientific notation is used, a number of "D.XXXXE(+|-)NNN" form is created. Even though this option is provided,
    ///  it is recommended that this <c>BigDecimal</c> be converted to a <c>Double</c> and then formatted properly using the Delphi
    ///  RTL routines.</remarks>
    function ToString(const AFormatSettings: TFormatSettings; const AScientificFormat: Boolean = true): string; overload;

    ///  <summary>Converts this <c>BigDecimal</c> to a string value.</summary>
    ///  <param name="AScientificFormat">Specifies whether scientific notation is used. Default is <c>False</c>.</param>
    ///  <returns>The string representation of this <c>BigDecimal</c>.</returns>
    ///  <remarks>If scientific notation is used, a number of "D.XXXXE(+|-)NNN" form is created. Even though this option is provided,
    ///  it is recommended that this <c>BigDecimal</c> be converted to a <c>Double</c> and then formatted properly using the Delphi
    ///  RTL routines.</remarks>
    function ToString(const AScientificFormat: Boolean = true): string; overload;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ALeft">A <c>BigDecimal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigDecimal</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are equal; <c>False</c> otherwise.</returns>
    ///  <remarks>This operator calls the <see cref="DeHL.Math.BigDecimal|BigDecimal.CompareTo">DeHL.Math.BigDecimal.BigDecimal.CompareTo</see>
    ///  method.</remarks>
    class operator Equal(const ALeft, ARight: BigDecimal): Boolean; inline;

    ///  <summary>Overloaded "<>" operator.</summary>
    ///  <param name="ALeft">A <c>BigDecimal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigDecimal</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are different; <c>False</c> otherwise.</returns>
    ///  <remarks>This operator calls <see cref="DeHL.Math.BigDecimal|BigDecimal.CompareTo">DeHL.Math.BigDecimal.BigDecimal.CompareTo</see>
    ///  method.</remarks>
    class operator NotEqual(const ALeft, ARight: BigDecimal): Boolean; inline;

    ///  <summary>Overloaded "&gt;" operator.</summary>
    ///  <param name="ALeft">A <c>BigDecimal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigDecimal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    ///  <remarks>This operator calls the <see cref="DeHL.Math.BigDecimal|BigDecimal.CompareTo">DeHL.Math.BigDecimal.BigDecimal.CompareTo</see>
    ///  method.</remarks>
    class operator GreaterThan(const ALeft, ARight: BigDecimal): Boolean; inline;

    ///  <summary>Overloaded "&gt;=" operator.</summary>
    ///  <param name="ALeft">A <c>BigDecimal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigDecimal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    ///  <remarks>This operator calls the <see cref="DeHL.Math.BigDecimal|BigDecimal.CompareTo">DeHL.Math.BigDecimal.BigDecimal.CompareTo</see>
    ///  method.</remarks>
    class operator GreaterThanOrEqual(const ALeft, ARight: BigDecimal): Boolean; inline;

    ///  <summary>Overloaded "&lt;" operator.</summary>
    ///  <param name="ALeft">A <c>BigDecimal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigDecimal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    ///  <remarks>This operator calls the <see cref="DeHL.Math.BigDecimal|BigDecimal.CompareTo">DeHL.Math.BigDecimal.BigDecimal.CompareTo</see>
    ///  method.</remarks>
    class operator LessThan(const ALeft, ARight: BigDecimal): Boolean; inline;

    ///  <summary>Overloaded "&lt;=" operator.</summary>
    ///  <param name="ALeft">A <c>BigDecimal</c> value to compare.</param>
    ///  <param name="ARight">The <c>BigDecimal</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    ///  <remarks>This operator calls the <see cref="DeHL.Math.BigDecimal|BigDecimal.CompareTo">DeHL.Math.BigDecimal.BigDecimal.CompareTo</see>
    ///  method.</remarks>
    class operator LessThanOrEqual(const ALeft, ARight: BigDecimal): Boolean; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">First <c>BigDecimal</c> value.</param>
    ///  <param name="ARight">Second <c>BigDecimal</c> value.</param>
    ///  <returns>A <c>BigDecimal</c> value that contains the sum of the two values.</returns>
    class operator Add(const ALeft, ARight: BigDecimal): BigDecimal;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ALeft">First <c>BigDecimal</c> value.</param>
    ///  <param name="ARight">Second <c>BigDecimal</c> value.</param>
    ///  <returns>A <c>BigDecimal</c> value that contains the difference of the two values.</returns>
    class operator Subtract(const ALeft, ARight: BigDecimal): BigDecimal;

    ///  <summary>Overloaded "*" operator.</summary>
    ///  <param name="ALeft">First <c>BigDecimal</c> value.</param>
    ///  <param name="ARight">Second <c>BigDecimal</c> value.</param>
    ///  <returns>A <c>BigDecimal</c> value that contains the product of the two values.</returns>
    ///  <remarks>The scale of the resulting <c>BigDecimal</c> is exteded to hold the newly introduced digits.</remarks>
    class operator Multiply(const ALeft, ARight: BigDecimal): BigDecimal;

    ///  <summary>Overloaded "div" operator.</summary>
    ///  <param name="ALeft">The dividend <c>BigDecimal</c> value.</param>
    ///  <param name="ARight">The divisor <c>BigDecimal</c> value.</param>
    ///  <returns>A <c>BigDecimal</c> value that contains the quotient.</returns>
    ///  <exception cref="SysUtils|EDivByZero">If <paramref name="ARight"/> is zero.</exception>
    ///  <exception cref="SysUtils|EInvalidOp">The numbers cannot be divided without rounding.</exception>
    ///  <remarks>Even though this operator is provided, it is recommended that the
    ///  <see cref="DeHL.Math.BigDecimal|BigDecimal.Divide">DeHL.Math.BigDecimal.BigDecimal.Divide</see> method be used instead.</remarks>
    class operator Divide(const ALeft, ARight: BigDecimal): BigDecimal;

    ///  <summary>Overloaded unary "-" operator.</summary>
    ///  <param name="AValue">A <c>BigDecimal</c> value.</param>
    ///  <returns>A <c>BigDecimal</c> that has the same magnitude but an inverted sign.</returns>
    class operator Negative(const AValue: BigDecimal): BigDecimal;

    ///  <summary>Overloaded unary "+" operator.</summary>
    ///  <param name="AValue">A <c>BigDecimal</c> value.</param>
    ///  <returns>The same <c>BigDecimal</c> value.</returns>
    ///  <remarks>This operation is a nop.</remarks>
    class operator Positive(const AValue: BigDecimal): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Cardinal</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>A scale of zero is assumed.</remarks>
    class operator Implicit(const ANumber: Cardinal): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>UInt64</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>A scale of zero is assumed.</remarks>
    class operator Implicit(const ANumber: UInt64): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">An <c>Integer</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>A scale of zero is assumed.</remarks>
    class operator Implicit(const ANumber: Integer): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">An <c>Int64</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>A scale of zero is assumed.</remarks>
    class operator Implicit(const ANumber: Int64): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>Double</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>Try to avoid using this implicit conversion. A floating-point number cannot be represented properly
    ///  and results in a <c>BigDecimal</c> value that needs further adjustments.</remarks>
    class operator Implicit(const ANumber: Double): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigCardinal</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>A scale of zero is assumed.</remarks>
    class operator Implicit(const ANumber: BigCardinal): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigInteger</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>A scale of zero is assumed.</remarks>
    class operator Implicit(const ANumber: BigInteger): BigDecimal; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigDecimal</c> value to convert.</param>
    ///  <returns>A <c>Variant</c> value containing the converted value.</returns>
    ///  <remarks>The returned <c>Variant</c> contains a custom variant type.</remarks>
    class operator Implicit(const ANumber: BigDecimal): Variant;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigDecimal</c> value to convert.</param>
    ///  <returns>A <c>Double</c> value containing the converted value.</returns>
    ///  <remarks>See <see cref="DeHL.Math.BigDecimal|BigDecimal.ToDouble">DeHL.Math.BigDecimal.BigDecimal.ToDouble</see> on the
    ///  implications of using this conversion.</remarks>
    class operator Explicit(const ANumber: BigDecimal): Double; inline;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>BigDecimal</c> value to convert.</param>
    ///  <returns>A <c>Extended</c> value containing the converted value.</returns>
    ///  <remarks>See <see cref="DeHL.Math.BigDecimal|BigDecimal.ToDouble">DeHL.Math.BigDecimal.BigDecimal.ToDouble</see> on the
    ///  implications of using this conversion.</remarks>
    class operator Explicit(const ANumber: BigDecimal): Extended; inline;

    ///  <summary>Overloaded "Explicit" operator.</summary>
    ///  <param name="ANumber">A <c>Variant</c> value to convert.</param>
    ///  <returns>A <c>BigDecimal</c> value containing the converted value.</returns>
    ///  <remarks>This method may raise various exceptions if the provided <c>Variant</c>
    ///  cannot be converted properly.</remarks>
    class operator Explicit(const ANumber: Variant): BigDecimal;

    ///  <summary>Specifies the ID of the <c>Variant</c> values containing a <c>BigDecimal</c>.</summary>
    ///  <returns>A <c>TVarType</c> value that specifies the ID.</returns>
    ///  <remarks>Use this value to identify <c>Variant</c>s that contain <c>BigDecimal</c> values.</remarks>
    class property VarType: TVarType read FVarType;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents the
    ///  <see cref="DeHL.Math.BigDecimal|BigDecimal">DeHL.Math.BigDecimal.BigDecimal</see> type.</returns>
    class function GetType(): IType<BigDecimal>; static;

    ///  <summary>Returns <c>0</c>.</summary>
    ///  <returns>A <c>BigDecimal</c> value containing zero.</returns>
    class property Zero: BigDecimal read GetZero;

    ///  <summary>Returns <c>1</c>.</summary>
    ///  <returns>A <c>BigDecimal</c> value containing one.</returns>
    class property One: BigDecimal read GetOne;

    ///  <summary>Returns <c>-1</c>.</summary>
    ///  <returns>A <c>BigDecimal</c> value containing minus one.</returns>
    class property MinusOne: BigDecimal read GetMinusOne;

    ///  <summary>Returns <c>10</c>.</summary>
    ///  <returns>A <c>BigDecimal</c> value containing ten.</returns>
    class property Ten: BigDecimal read GetTen;

    ///  <summary>Returns <c>-10</c>.</summary>
    ///  <returns>A <c>BigDecimal</c> value containing minus ten.</returns>
    class property MinusTen: BigDecimal read GetMinusTen;
  end;

implementation
uses Math,
     Character,
     StrUtils,
     DeHL.StrConsts;

{ BigDecimal.TData }

function BigDecimal.TData.GetData: TData;
begin
  Result := Self;
end;

class function BigDecimal.TData.Make(const ABigInteger: BigInteger;
  const AScale: NativeInt; const APrecision: NativeUInt): IData;
var
  LInst: TData;
begin
  LInst := TData.Create;
  Result := LInst;

  LInst.FBigInteger := ABigInteger;
  LInst.FScale := AScale;
  LInst.FPrecision := APrecision;
end;

type
  { BigDecimal Support }
  TBigDecimalType = class(TRecordType<BigDecimal>)
  private
    FBigIntegerType: IType<BigInteger>;

  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: BigDecimal; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: BigDecimal; const AContext: IDeserializationContext); override;

  public
    { Constructor }
    constructor Create(); override;

    { Comparator }
    function Compare(const AValue1, AValue2: BigDecimal): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: BigDecimal): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: BigDecimal): String; override;

    { Type information }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: BigDecimal; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: BigDecimal): Boolean; override;
  end;

  { Math extensions for the BigDecimal type }
  TBigDecimalMathExtension = class sealed(TRealMathExtension<BigDecimal>)
  public
    { Standard operations }
    function Add(const AValue1, AValue2: BigDecimal): BigDecimal; override;
    function Subtract(const AValue1, AValue2: BigDecimal): BigDecimal; override;
    function Multiply(const AValue1, AValue2: BigDecimal): BigDecimal; override;
    function Divide(const AValue1, AValue2: BigDecimal): BigDecimal; override;

    { Sign-related operations }
    function Negate(const AValue: BigDecimal): BigDecimal; override;
    function Abs(const AValue: BigDecimal): BigDecimal; override;

    { Neutral Math elements }
    function Zero: BigDecimal; override;
    function One: BigDecimal; override;
    function MinusOne: BigDecimal; override;
  end;

{ Variant Support }

type
  { Mapping the BigDecimal into TVarData structure }
  TBigDecimalVarData = packed record
    { Var type, will be assigned at runtime }
    VType: TVarType;
    { Reserved stuff }
    Reserved1, Reserved2, Reserved3: Word;
    { A reference to the enclosed big cardinal }
    BigDecimalRef: BigDecimal.IData;
    { Reserved stuff }
    Reserved4: LongWord;
  end;

  { Manager for our variant type }
  TBigDecimalVariantType = class(TCustomVariantType)
  private
    { Will create a big cardinal, or raise an error }
    function VarDataToBigDecimal(const Value: TVarData): BigDecimal;
    procedure BigDecimalToVarData(const Value: BigDecimal; var OutValue: TVarData);
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
  SgtBigDecimalVariantType: TBigDecimalVariantType;

{ TBigDecimalVariantType }

procedure TBigDecimalVariantType.BinaryOp(var Left: TVarData; const Right: TVarData; const &Operator: TVarOp);
begin
  { Select the appropriate operation }
  case &Operator of
    opAdd:
      BigDecimalToVarData(VarDataToBigDecimal(Left) + VarDataToBigDecimal(Right), Left);
    opDivide:
      { Use rmHalfEven for teh division. People will surely use variant division ... }
      BigDecimalToVarData(
        VarDataToBigDecimal(Left).Divide(VarDataToBigDecimal(Right), rmHalfEven),
        Left
      );
    opMultiply:
      BigDecimalToVarData(VarDataToBigDecimal(Left) * VarDataToBigDecimal(Right), Left);
    opSubtract:
      BigDecimalToVarData(VarDataToBigDecimal(Left) - VarDataToBigDecimal(Right), Left);
  else
    RaiseInvalidOp;
  end;
end;

procedure TBigDecimalVariantType.Cast(var Dest: TVarData; const Source: TVarData);
begin
  { Cast the source to our cardinal type }
  VarDataInit(Dest);
  BigDecimalToVarData(VarDataToBigDecimal(Source), Dest);
end;

procedure TBigDecimalVariantType.CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType);
var
  Big: BigDecimal;
  Temp: TVarData;
  WStr: WideString;
begin
  if Source.VType = VarType then
  begin
    { Only continue if we're invoked for our data type }
    Big.FData := TBigDecimalVarData(Source).BigDecimalRef;

    { Initilize the destination }
    VarDataInit(Dest);
    Dest.VType := AVarType;

    case AVarType of
      varShortInt:
        Dest.VShortInt := Big.Truncate().ToShortInt();

      varSmallint:
        Dest.VSmallInt := Big.Truncate().ToSmallInt();

      varInteger:
        Dest.VInteger := Big.Truncate().ToInteger();

      varInt64:
        Dest.VInt64 := Big.Truncate().ToInt64();

      varDouble:
        Dest.VDouble := Big.ToDouble();

      varCurrency:
        Dest.VCurrency := Big.ToDouble();

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

procedure TBigDecimalVariantType.Clear(var V: TVarData);
begin
  { Clear the variant type }
  V.VType := varEmpty;

  { And dispose the value }
  TBigDecimalVarData(V).BigDecimalRef := nil; // Should be disposed by def.
end;

procedure TBigDecimalVariantType.Compare(const Left, Right: TVarData; var Relationship: TVarCompareResult);
var
  Res: NativeInt;
begin
  { Compare these values }
  Res := VarDataToBigDecimal(Left).CompareTo(VarDataToBigDecimal(Right));

  { Return the compare result }
  if Res < 0 then
    Relationship := crLessThan
  else if Res > 0 then
    Relationship := crGreaterThan
  else
    Relationship := crEqual;
end;

procedure TBigDecimalVariantType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
    VarDataCopyNoInd(Dest, Source)
  else
  begin
    with TBigDecimalVarData(Dest) do
    begin
      { Copy the variant type }
      VType := VarType;

      { Copy by value }
      BigDecimalRef := TBigDecimalVarData(Source).BigDecimalRef;
    end;
  end;
end;

function TBigDecimalVariantType.IsClear(const V: TVarData): Boolean;
begin
  if V.VType = varEmpty then
    Exit(true);

  { Signal clear value }
  Result := (TBigDecimalVarData(V).BigDecimalRef = nil);
end;

procedure TBigDecimalVariantType.UnaryOp(var Right: TVarData; const &Operator: TVarOp);
begin
  { Select the appropriate operation }
  case &Operator of
    opNegate:
      BigDecimalToVarData(-VarDataToBigDecimal(Right), Right);
  else
    RaiseInvalidOp;
  end;
end;

function TBigDecimalVariantType.VarDataToBigDecimal(const Value: TVarData): BigDecimal;
begin
  { Check if the var data has a big cardinal inside }
  if Value.VType = VarType then
  begin
    { Copy the value to result }
    Result.FData := TBigDecimalVarData(Value).BigDecimalRef;
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

    varSingle:
      Result := Value.VSingle;

    varDouble:
      Result := Value.VDouble;

    varCurrency:
      Result := Value.VCurrency;

    varString, varUString, varOleStr:
    begin
      { Be careful here, a string may not be a good number }
      if not BigDecimal.TryParse(VarDataToStr(Value), Result) then
        RaiseCastError;
    end;

    else
      RaiseCastError;
  end;
end;

procedure TBigDecimalVariantType.BigDecimalToVarData(const Value: BigDecimal; var OutValue: TVarData);
begin
  { Dispose of the old value. Check it it's ours first }
  if OutValue.VType = VarType then
    Clear(OutValue)
  else
    VarDataClear(OutValue);

  with TBigDecimalVarData(OutValue) do
  begin
    { Assign the new variant the var type that was allocated for us }
    VType := VarType;

    { Clear the location first, the copy self ref }
    Pointer(BigDecimalRef) := nil;
    BigDecimalRef := Value.FData;
  end;
end;

{ BigDecimal }

constructor BigDecimal.Create(const AValue: Cardinal; const AScale: NativeInt);
begin
  { Try the cache first }
  if (AValue <= NativeUInt(High(FCached_Numbers))) and (AScale = 0) then
    FData := FCached_Numbers[AValue]
  else begin
    { Otherwise let's see (it's always positive) }
    FData := TData.Make(BigInteger.Create(AValue), AScale, 0);
  end;
end;

constructor BigDecimal.Create(const AValue: Integer; const AScale: NativeInt);
begin
  { Try the cache first }
  if (AValue >= Low(FCached_Numbers)) and (AValue <= High(FCached_Numbers)) and (AScale = 0) then
    FData := FCached_Numbers[AValue]
  else begin
    { Otherwise let's see (detect sign ) }
    FData := TData.Make(BigInteger.Create(AValue), AScale, 0);
  end;
end;

constructor BigDecimal.Create(const AValue: Int64; const AScale: NativeInt);
begin
  { Try the cache first }
  if (AValue >= Low(FCached_Numbers)) and (AValue <= High(FCached_Numbers)) and (AScale = 0) then
    FData := FCached_Numbers[AValue]
  else begin
    { Otherwise let's see (detect sign ) }
    FData := TData.Make(BigInteger.Create(AValue), AScale, 0);
  end;
end;

constructor BigDecimal.Create(const AValue: BigCardinal; const AScale: NativeInt);
begin
  { Construct a new object }
  FData := TData.Make(BigInteger.Create(AValue), AScale, 0);
end;

constructor BigDecimal.Create(const AValue: BigInteger; const AScale: NativeInt);
begin
  { Construct a new object }
  FData := TData.Make(AValue, AScale, 0);
end;

constructor BigDecimal.Create(const AValue: UInt64; const AScale: NativeInt);
begin
  { Try the cache first }
  if (AValue <= NativeUInt(High(FCached_Numbers))) and (AScale = 0) then
    FData := FCached_Numbers[AValue]
  else begin
    { Otherwise let's see (it's always positive) }
    FData := TData.Make(BigInteger.Create(AValue), AScale, 0);
  end;
end;

class operator BigDecimal.Implicit(const ANumber: Integer): BigDecimal;
begin
  Result := BigDecimal.Create(ANumber);
end;

class operator BigDecimal.Implicit(const ANumber: Int64): BigDecimal;
begin
  Result := BigDecimal.Create(ANumber);
end;

class operator BigDecimal.Implicit(const ANumber: Cardinal): BigDecimal;
begin
  Result := BigDecimal.Create(ANumber);
end;

class operator BigDecimal.Implicit(const ANumber: UInt64): BigDecimal;
begin
  Result := BigDecimal.Create(ANumber);
end;

class operator BigDecimal.Implicit(const ANumber: BigInteger): BigDecimal;
begin
  Result := BigDecimal.Create(ANumber);
end;

class operator BigDecimal.Implicit(const ANumber: BigDecimal): Variant;
begin
  { Clear out the result }
  VarClear(Result);

  with TBigDecimalVarData(Result) do
  begin
    { Assign the new variant the var type that was allocated for us }
    VType := FVarType;

    { Copy self to this memory }
    BigDecimalRef := ANumber.FData;
  end;
end;

class operator BigDecimal.Implicit(const ANumber: Double): BigDecimal;
begin
  Result := BigDecimal.Create(ANumber);
end;

class operator BigDecimal.Implicit(const ANumber: BigCardinal): BigDecimal;
begin
  Result := BigDecimal.Create(ANumber);
end;

class operator BigDecimal.LessThan(const ALeft, ARight: BigDecimal): Boolean;
begin
  Result := ALeft.CompareTo(ARight) < 0;
end;

class operator BigDecimal.LessThanOrEqual(const ALeft, ARight: BigDecimal): Boolean;
begin
  Result := ALeft.CompareTo(ARight) <= 0;
end;

class operator BigDecimal.Multiply(const ALeft, ARight: BigDecimal): BigDecimal;
var
  LLData, LRData: TData;
begin
  { Get data }
  LLData := ALeft.GetData();
  LRData := ARight.GetData();

  if LLData.FBigInteger.IsZero or LRData.FBigInteger.IsZero then
    Result.FData := FCached_Numbers[0] { Zero }
  else
    Result.FData := TData.Make(LLData.FBigInteger * LRData.FBigInteger,
      LLData.FScale + LRData.FScale, 0);
end;

class operator BigDecimal.Negative(const AValue: BigDecimal): BigDecimal;
var
  LData: TData;
begin
  { Get data }
  LData := AValue.GetData();

  if LData.FBigInteger.IsZero then
    Result.FData := FCached_Numbers[0] { Zero }
  else
    Result.FData := TData.Make(-LData.FBigInteger, LData.FScale, LData.FPrecision);
end;

class operator BigDecimal.NotEqual(const ALeft, ARight: BigDecimal): Boolean;
begin
  Result := ALeft.CompareTo(ARight) <> 0;
end;

class function BigDecimal.Parse(const AString: string; const AFormatSettings: TFormatSettings): BigDecimal;
begin
  { Call internal }
  if not InternalTryParse(AString, Result, AFormatSettings.DecimalSeparator,
    AFormatSettings.ThousandSeparator)
  then
    ExceptionHelper.Throw_ArgumentConverError('AString');
end;

class function BigDecimal.Parse(const AString: string): BigDecimal;
begin
  { Call internal }
{$IF RTLVersion >= 22}
  if not InternalTryParse(AString, Result, FormatSettings.DecimalSeparator, FormatSettings.ThousandSeparator)
{$ELSE}
  if not InternalTryParse(AString, Result, DecimalSeparator, ThousandSeparator)
{$IFEND}
  then
    ExceptionHelper.Throw_ArgumentConverError('AString');
end;

class operator BigDecimal.Positive(const AValue: BigDecimal): BigDecimal;
begin
  { NOP }
  Result.FData := AValue.FData;
end;

function BigDecimal.Pow(const AExponent: NativeInt; const ANewScale: NativeInt; const ARoundingMode: TRoundingMode): BigDecimal;
begin
  { Call internal method. Use a new scale }
  Result := InternalPow(AExponent, true, ANewScale, ARoundingMode);
end;

function BigDecimal.Pow(const AExponent: NativeInt; const ARoundingMode: TRoundingMode): BigDecimal;
begin
  { Call internal method. Don't use a new scale }
  Result := InternalPow(AExponent, false, 0, ARoundingMode);
end;

class function BigDecimal.PowerOfTen(const APower: NativeInt): BigInteger;
begin
  ASSERT(APower >= 0);

  { Try a fast lookup first; if it fails -- use the Pow }
  if APower <= 10 then
    Result := FFastPower[APower]
  else
    Result := BigInteger.Ten.Pow(APower);
end;

function BigDecimal.Rescale(const ANewScale: NativeInt; const ARoundingMode: TRoundingMode): BigDecimal;
var
  LDiff: NativeInt;
  LPrec: NativeUInt;
  LData: TData;
begin
  { Get data }
  LData := GetData();

  { Only allow positive scales to be passed. We can only increment
    the number of digits to the right. }
  if ANewScale < 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('ANewScale');

  { Obtain the current scale }
  LDiff := ANewScale - LData.FScale; { the number of digits to add/remove }

  { Check if there is nothing to do  }
  if LDiff = 0 then
    Result.FData := FData
  else if LDiff > 0 then
  begin
    { Adding new digits. It's easy. Multiply by 10^diff and set new scale }
    LPrec := LData.FPrecision;

    { If the precision was defined, update it. Otherwise do not touch it. }
    if LPrec <> 0 then
      Inc(LPrec, LDiff);

    Result.FData := TData.Make(
      LData.FBigInteger * PowerOfTen(LDiff),
      ANewScale,
      LPrec
    );
  end else
    { Removing digits ... not that easy. We'll use division! }
    Result := Divide(One, ANewScale, ARoundingMode);
end;

function BigDecimal.Round(const ANewPrecision: NativeUInt; const ARoundingMode: TRoundingMode): BigDecimal;
var
  LDigits: NativeInt;
  LDivisor: BigDecimal;

  LData: TData;
begin
  { Get data }
  LData := GetData();

  { Calculate the digits to remove }
  LDigits := InternalGetPrecision(LData) - ANewPrecision;

  { Calculate the desired/obtained precisions }
  if (ANewPrecision = 0) or (LDigits <= 0) then
  begin
    Result.FData := FData;
    Exit;
  end;

  { Scale the Decimal by 10 to be able to round it }
  LDivisor := BigDecimal.Create(PowerOfTen(LDigits));
  Result := InternalDivide(LData, LDivisor.GetData(), LData.FScale, ARoundingMode);

  { Update result using the given rounding mode }
  LData := Result.GetData();
  Dec(LData.FScale, LDigits);
  LData.FPrecision := ANewPrecision;
end;

function BigDecimal.ScaleByPowerOfTen(const AScale: NativeInt): BigDecimal;
var
  LData: TData;
begin
  { Get data }
  LData := GetData();

  if (AScale = 0) then
    Result.FData := FData
  else if LData.FBigInteger.IsZero then
    Result.FData := TData.Make(BigInteger.Zero, -AScale, 0)
  else begin
    { Create a new BigDecimal that has the same unscaled value, precision and
      a modified scale }
    Result.FData := TData.Make(LData.FBigInteger, LData.FScale - AScale, LData.FPrecision);
  end;
end;

class operator BigDecimal.Subtract(const ALeft, ARight: BigDecimal): BigDecimal;
begin
  { Use Add as base (with negated right) }
  Result := ALeft + (-ARight);
end;

function BigDecimal.Truncate: BigInteger;
var
  LData: TData;
begin
  { Get data }
  LData := GetData();

  { Depending on the scale, either multiply or divide the number }
  if (LData.FBigInteger.IsZero) then
    Result := BigInteger.Zero
  else if LData.FScale > 0 then
    Result := LData.FBigInteger div PowerOfTen(LData.FScale)
  else if LData.FScale < 0 then
    Result := LData.FBigInteger * PowerOfTen(-LData.FScale)
  else { LData.FScale = 0 }
    Result := LData.FBigInteger;
end;

function BigDecimal.ToDouble: Double;
var
  LData: TData;
  LBigInt: BigInteger;
  L64: Int64;
begin
  { Get data }
  LData := GetData();

  if LData.FBigInteger.IsZero then
    Result := 0
  else begin
    { For zero of negative scales we can probably do something
      a bit more optimized. }
    if LData.FScale <= 0 then
    begin
      { Adjust the scale (make it zero) }
      if LData.FScale < 0 then
        LBigInt := LData.FBigInteger * PowerOfTen(-LData.FScale)
      else
        LBigInt := LData.FBigInteger;

      { Now we have a number that might fit into a float directly }
      L64 := LBigInt.ToInt64;
      if L64 = LBigInt then
        Result := L64
      else
        Result := StrToFloat(LBigInt.ToString());
    end else
      Result := StrToFloat(ToString());
  end;
end;

function BigDecimal.ToString(const AFormatSettings: TFormatSettings;
  const AScientificFormat: Boolean): string;
begin
  { Call internal method }
  Result := InternalToString(AScientificFormat, AFormatSettings.DecimalSeparator);
end;

function BigDecimal.ToString(const AScientificFormat: Boolean): string;
begin
  { Call internal method }
{$IF RTLVersion >= 22}
  Result := InternalToString(AScientificFormat, FormatSettings.DecimalSeparator);
{$ELSE}
  Result := InternalToString(AScientificFormat, DecimalSeparator);
{$IFEND}
end;

class function BigDecimal.TryParse(const AString: string;
  out ANumber: BigDecimal; const AFormatSettings: TFormatSettings): Boolean;
begin
  { Call internal }
  Result := InternalTryParse(AString, ANumber, AFormatSettings.DecimalSeparator,
    AFormatSettings.ThousandSeparator);
end;

class function BigDecimal.TryParse(const AString: string; out ANumber: BigDecimal): Boolean;
begin
  { Call internal }
{$IF RTLVersion >= 22}
  Result := InternalTryParse(AString, ANumber, FormatSettings.DecimalSeparator, FormatSettings.ThousandSeparator);
{$ELSE}
  Result := InternalTryParse(AString, ANumber, DecimalSeparator, ThousandSeparator);
{$IFEND}
end;

function BigDecimal.Abs: BigDecimal;
var
  LData: TData;
begin
  { Get data }
  LData := GetData();

  if LData.FBigInteger.IsZero then
    Result.FData := FCached_Numbers[0] { Zero }
  else
    Result.FData := TData.Make(LData.FBigInteger.Abs(), LData.FScale, LData.FPrecision);
end;

class operator BigDecimal.Add(const ALeft, ARight: BigDecimal): BigDecimal;
var
  LLData, LRData: TData;
  LTemp: BigInteger;
begin
  { Get data }
  LLData := ALeft.GetData();
  LRData := ARight.GetData();

  { First check for NILs in either side }
  if LLData.FBigInteger.IsZero then
    Result.FData := ARight.FData
  else if LRData.FBigInteger.IsZero then
    Result.FData := ALeft.FData
  else begin
    { Add the numbers by adjusting scales accordingly }
    if LRData.FScale = LLData.FScale then
      Result.FData := TData.Make(LRData.FBigInteger + LLData.FBigInteger, LRData.FScale, 0)
    else if LRData.FScale > LLData.FScale then
    begin
      LTemp := LLData.FBigInteger * PowerOfTen(LRData.FScale - LLData.FScale);
      Result := BigDecimal.Create(LTemp + LRData.FBigInteger, LRData.FScale);
    end else if LRData.FScale < LLData.FScale then
    begin
      LTemp := LRData.FBigInteger * PowerOfTen(LLData.FScale - LRData.FScale);
      Result := BigDecimal.Create(LLData.FBigInteger + LTemp, LLData.FScale);
    end;
  end;
end;

function BigDecimal.CompareTo(const ANumber: BigDecimal): NativeInt;
var
  LLData, LRData: TData;
  LLAdjExp, LRAdjExp: NativeInt;
begin
  { Obtain the data }
  LLData := GetData();
  LRData := ANumber.GetData();

  { OK, here comes the checking part }
  if LLData.FBigInteger.IsZero then
    Result := -LRData.FBigInteger.Sign { 0 = 0; 0 > -X; 0 < X }
  else if LRData.FBigInteger.IsZero then
    Result := LLData.FBigInteger.Sign { 0 = 0; -X < 0; X > 0 }
  else begin
    { Both numbers are well defined, and non-zero.
      Calculate the adjusted exponents. These values
      basically say how "long" is the integral part. }
    if LLData.FScale = LRData.FScale then
      Result := LLData.FBigInteger.CompareTo(LRData.FBigInteger) { same scale, simple compare pls }
    else
    begin
      LLAdjExp := NativeInt(InternalGetPrecision(LLData)) - LLData.FScale;
      LRAdjExp := NativeInt(InternalGetPrecision(LRData)) - LRData.FScale;

      if LLAdjExp > LRAdjExp then
      begin
        { This number has a "longer" integral part. If this number is positive,
          then it means it's bigger than ANumber }
        Result := LLData.FBigInteger.Sign;
      end else if LLAdjExp < LRAdjExp then
      begin
        { This number has a "shorter" integral part. If this number is positive,
          then it means it's smalles than ANumber }
        Result := -LLData.FBigInteger.Sign;
      end else
      begin
        { Both numbers have the same "integral length". We need to match their scales
          and do a comparison. }
        if LLData.FScale < LRData.FScale then
        begin
          LLData := Rescale(LRData.FScale).GetData();
          Result := LLData.FBigInteger.CompareTo(LRData.FBigInteger)
        end else
        begin
          LRData := ANumber.Rescale(LLData.FScale).GetData();
          Result := LLData.FBigInteger.CompareTo(LRData.FBigInteger);
        end;
      end;
    end;
  end;
end;

constructor BigDecimal.Create(const AValue: Double);
const
  CDouble_Mantissa_Bits = 52;
  CDouble_Exponent_Bits = 11;
  CDouble_Mantissa_Sign_Bit = (Int64(1) shl CDouble_Mantissa_Bits);
  CDouble_Mantissa_Mask = CDouble_Mantissa_Sign_Bit - 1;
  CDouble_Exponent_Mask = (Int64(1) shl CDouble_Exponent_Bits) - 1;
  CDouble_Denormal_Bias: array[Boolean] of NativeInt = (1023, 1022);

var
  LValueAs64: Int64 absolute AValue;
  LMantissa: Int64;
  LExponent: Int64;
  LIsDenormal: Boolean;

  LScale: NativeInt;
  LBigInteger: BigInteger;
begin
  if IsInfinite(AValue) or IsNan(AValue) then
    ExceptionHelper.Throw_InvalidFloatParam('AValue');

  { Dissect the received double value }
  LMantissa := LValueAs64 and CDouble_Mantissa_Mask;
  LExponent := (UInt64(LValueAs64) shr CDouble_Mantissa_Bits) and CDouble_Exponent_Mask;
  LIsDenormal := (LExponent = 0);

  { Correct exponent }
  Dec(LExponent, CDouble_Denormal_Bias[LIsDenormal] + CDouble_Mantissa_Bits);

  if not LIsDenormal then
    LMantissa := LMantissa or CDouble_Mantissa_Sign_Bit;

  { Remove 10s }
  while (LExponent < 0) and ((LMantissa and 1) = 0) do
  begin
    Inc(LExponent);
    LMantissa := LMantissa shr 1;
  end;

  { Initialize the integer value }
  if LValueAs64 < 0 then
    LBigInteger := -LMantissa
  else
    LBigInteger := LMantissa;

  { Adjust exponent }
  if LExponent < 0 then
  begin
    LScale := -LExponent;
    LBigInteger := LBigInteger * BigInteger(5).Pow(LScale);
  end else
  begin
    LBigInteger := LBigInteger shl LExponent;
    LScale := 0;
  end;

  { Initialize self! }
  FData := TData.Make(LBigInteger, LScale, 0);
end;


class destructor BigDecimal.Destroy;
begin
  { Unregister DeHL stuff (math extension goes first) }
  TMathExtension<BigDecimal>.Unregister;
  TType<BigDecimal>.Unregister;

  { Uregister our custom variant }
  FreeAndNil(SgtBigDecimalVariantType);
end;

class operator BigDecimal.Divide(const ALeft, ARight: BigDecimal): BigDecimal;
begin
  { Call the public Divide method }
  Result := ALeft.Divide(ARight, rmNone);
end;

function BigDecimal.Divide(const ADivisor: BigDecimal; const ARoundingMode: TRoundingMode): BigDecimal;
var
  LLData, LRData: TData;
begin
  { Obtain the data }
  LLData := GetData();
  LRData := ADivisor.GetData();

  { Call division with specified scale }
  Result := InternalDivide(LLData, LRData, LLData.FScale - LRData.FScale, ARoundingMode);
end;

class function BigDecimal.InternalDivide(const ADividend, ADivisor: TData;
  const ANewScale: NativeInt; const ARoundingMode: TRoundingMode): BigDecimal;
const
  CModeAdjust: array[Boolean] of TRoundingMode = (rmDown, rmUp);

var
  LPower, LComp: NativeInt;
  LDividendInt, LDivisorInt,
    LQuotientInt, LRemainderInt: BigInteger;
  LIsPositive: Boolean;
  LRealMode: TRoundingMode;
begin
  ASSERT(Assigned(ADividend));
  ASSERT(Assigned(ADivisor));

  { Obvious initial tests }
  if ADividend.FBigInteger.IsZero then
  begin
    { Check whether we want to rescale 0 ... not useful but hey! }
    if ADividend.FScale = ANewScale then
      Result.FData := FCached_Numbers[0] { Zero }
    else
      Result.FData := TData.Make(BigInteger.Zero, ANewScale, 0);
  end else if ADivisor.FBigInteger.IsZero then
    ExceptionHelper.Throw_DivByZeroError()
  else begin
    { Adjust the divisor's power proper }
    LPower := ANewScale - (ADividend.FScale - ADivisor.FScale);

    if LPower < 0 then
    begin
      LDivisorInt := ADivisor.FBigInteger * PowerOfTen(-LPower);
      LPower := 0;
    end else
      LDivisorInt := ADivisor.FBigInteger;

    { Adjust dividend's power. If it was negative, it's  NOP }
    LDividendInt := ADividend.FBigInteger * PowerOfTen(LPower);
    LQuotientInt := LDividendInt.DivMod(LDivisorInt, LRemainderInt);

    { If there is no remainder, nothing to do but return }
    if LRemainderInt.IsZero then
      Result.FData := TData.Make(LQuotientInt, ANewScale, 0)
    else begin
      { No luck. We actually have to round! Prepare for this }
      LIsPositive := not (ADividend.FBigInteger.IsNegative xor LDivisorInt.IsNegative);

      { If no rounding was specified, then raise an exception. We need rounding! }
      if ARoundingMode = rmNone then
        ExceptionHelper.Throw_NeedsRounding();

      { Transform the meta-rounding modes into real ones.
        rmCeiling -> rmDown if positive or rmUp if negative
        rmFloor -> rmUp if positive or rmDown if negative
        rmHalfUp, rmHalfDown and rmHalfEven -> rmUp and rmDown based on  set of
         well-defined properties.
      }
      if ARoundingMode = rmCeiling then
        LRealMode := CModeAdjust[LIsPositive]
      else if ARoundingMode = rmFloor then
        LRealMode := CModeAdjust[not LIsPositive]
      else
      begin
        { Use the provided rounding mode }
        LRealMode := ARoundingMode;

        { Adjust the numbers for rounding purposes }
        LRemainderInt := LRemainderInt.Abs() shl 1;
        LDivisorInt := LDivisorInt.Abs();
    
        LComp := LRemainderInt.CompareTo(LDivisorInt);

        if LRealMode = rmHalfUp then
          LRealMode := CModeAdjust[LComp >= 0]
        else if LRealMode = rmHalfDown then
          LRealMode := CModeAdjust[LComp > 0]
        else if LRealMode = rmHalfEven then
        begin
          if LComp = 0 then
            LRealMode := CModeAdjust[LQuotientInt.IsOdd]
          else
            LRealMode := CModeAdjust[LComp > 0]
        end;
      end;

      { If the mode is rmUp, add 1 (for positives) and -1 (for negatives) }
      if LRealMode = rmUp then
      begin
        if LIsPositive then
          Inc(LQuotientInt)
        else
          Dec(LQuotientInt);
      end;

      { Finally create the result using the quotient and specifying the new FScale }
      Result.FData := TData.Make(LQuotientInt, ANewScale, 0);
    end;
  end;
end;

class function BigDecimal.InternalGetBigIntegerAbsStr(const AData: TData): string;
begin
  ASSERT(Assigned(AData));

  Result := InternalGetBigIntegerStr(AData);

  { For negative number do not get the - sign }
  if AData.FBigInteger.IsNegative then
    Result := Copy(Result, 2, Length(Result));
end;

class function BigDecimal.InternalGetBigIntegerStr(const AData: TData): string;
begin
  ASSERT(Assigned(AData));

  if AData.FBigIntegerStr = '' then
    AData.FBigIntegerStr := AData.FBigInteger.ToString();

  Result := AData.FBigIntegerStr;
end;

class function BigDecimal.InternalGetPrecision(const AData: TData): NativeUInt;
begin
  ASSERT(Assigned(AData));

  { Check for default (zero) }
  if (AData.FPrecision = 0) then
    AData.FPrecision := Length(InternalGetBigIntegerAbsStr(AData));

  Result := AData.FPrecision;
end;

function BigDecimal.InternalPow(const APower: NativeInt;
  const AUseScale: Boolean; const ANewScale: NativeInt;
  const ARoundingMode: TRoundingMode): BigDecimal;
var
  LLData: TData;
  I, AAbsPower: NativeInt;
begin
  { Get Data }
  LLData := GetData();

  { Get the absolute of the power }
  AAbsPower := System.Abs(APower);

  { Check for zero power, zero number }
  if AAbsPower = 0 then
    Result.FData := FCached_Numbers[1]
  else if LLData.FBigInteger.IsZero then
    Result.FData := FCached_Numbers[0]
  else begin
    { Not a zero power and not a zero number }
    Result.FData := FCached_Numbers[1];

    { Raise to the power }
    for I := 1 to AAbsPower do
      Result := Self * Result;

    { If the power is negative, then divide to 1 }
    if APower < 0 then
    begin
      if AUseScale then
        Result := One.Divide(Result, ANewScale, ARoundingMode)
      else
        Result := One.Divide(Result, ARoundingMode);
    end else if AUseScale then
      Result := Result.Rescale(ANewScale, ARoundingMode); //TODO: hmm.. is this ok?
  end;
end;

function BigDecimal.InternalToString(const AScientific: Boolean; const ADecSep: Char): string;
var
  LLData: TData;
  LDecSepIdx: NativeInt;
  LNatural: string;
  LOutStr: string;
  LOutIdx: NativeInt;
  LIsNegative: Boolean;

  procedure AppendStr(const AStr: string);
  begin
    MoveChars(AStr[1], LOutStr[LOutIdx], Length(AStr));
    Inc(LOutIdx, Length(AStr));
  end;

  procedure AppendStr1(const AStr: string; const AIdx: NativeInt);
  var
    L: NativeInt;
  begin
    L := Length(AStr) - AIdx + 1;

    MoveChars(AStr[AIdx], LOutStr[LOutIdx], L);
    Inc(LOutIdx, L);
  end;

  procedure AppendStr2(const AStr: string; const AIdx, ACnt: NativeInt);
  begin
    MoveChars(AStr[AIdx], LOutStr[LOutIdx], ACnt);
    Inc(LOutIdx, ACnt);
  end;

  procedure AppendCh(const ACh: Char);
  begin
    LOutStr[LOutIdx] := ACh;
    Inc(LOutIdx);
  end;

begin
  { Get Data }
  LLData := GetData();

  { Preparations. If the scale is 0 we return the BigInteger->string. }
  if (LLData.FScale = 0) then   //TODO: verify if this is correct for zero
    Result := InternalGetBigIntegerStr(LLData)
  else begin
    { See if this decimal is negative }
    LIsNegative := LLData.FBigInteger.IsNegative;

    { Convert the internal interger to string. We will use it. }
    LNatural := InternalGetBigIntegerAbsStr(LLData);

    { Calculate the position of the decimal separator }
    LDecSepIdx := Length(LNatural) - LLData.FScale;

    { Prepare enough space for the outpus string }
    SetLength(LOutStr, Length(LNatural) + 14); { +14 will give us more }
    LOutIdx := 1;

    { For negative numbers, prefix it with '-' }
    if LIsNegative then AppendCh('-');

    { Start dancing! }
    if AScientific then
    begin
      if (LLData.FScale > 0) and ((LDecSepIdx - 1) >= -6) then
      begin
        { The number doesn't require E or scientific notation }
        if (LDecSepIdx <= 0) then
        begin
          { The number is sub-unitary (N < 1), act accordingly }

          { Append the "0." prefix }
          AppendCh('0');
          AppendCh(ADecSep);

          { Pad with zeroes until we normalize the scale. }
          AppendStr(DupeString('0', -LDecSepIdx));

          { Finally append the BigInteger }
          AppendStr(LNatural);
        end else
        begin
          { Simply extend the number with a decimal separator }
          AppendStr2(LNatural, 1, LDecSepIdx);
          AppendCh(ADecSep);
          AppendStr1(LNatural, LDecSepIdx + 1);
        end;
      end else
      begin
        if Length(LNatural) > 1 then
        begin
          { If we have more than one digit in the number, put the decimal
            separator after the first digit }
          AppendCh(LNatural[1]);
          AppendCh(ADecSep);
          AppendStr1(LNatural, 2);
        end else
          AppendStr(LNatural); // No decimal separators

        { Now append 'E' and the exponent }
        AppendCh('E');

        { If the exponent is positive, make sure we add '+' }
        if LDecSepIdx - 1 >= 0 then
          AppendCh('+');

        { Append the exponent (if it is negative '-' will appear on it's own }
        AppendStr(IntToStr(LDecSepIdx - 1));
      end;
    end else
    begin
      { PLAIN STRING, NON-SCIENTIFIC FORMATTING }
      if LDecSepIdx <= 0 then
      begin
        { Append the "0." prefix }
        AppendCh('0');
        AppendCh(ADecSep);

        { Pad with zeroes until we normalize the scale. }
        AppendStr(DupeString('0', -LDecSepIdx));

        { Finally append the BigInteger }
        AppendStr(LNatural);
      end else if LDecSepIdx < Length(LNatural) then
      begin
        { Place the "dot" properly }
        AppendStr2(LNatural, 1, LDecSepIdx);
        AppendCh(ADecSep);
        AppendStr1(LNatural, LDecSepIdx + 1);
      end else
      begin
        { Plain string. Append zeros instead. }
        AppendStr(LNatural);
        AppendStr(DupeString('0', LDecSepIdx - Length(LNatural)));
      end;
    end;

    { Obtain the result }
    Result := Copy(LOutStr, 1, LOutIdx - 1);
  end;
end;

class function BigDecimal.InternalTryParse(const AStr: string;
  out ANumber: BigDecimal; const ADecSep, AThSep: Char): Boolean;
var
  LIdx, LEIdx, LScale, I: NativeInt;
  LEVal: Int64;
  LIsNeg: Boolean;
  LNum: string;
  LIntVal: BigInteger;

begin
  Result := false;

  if Length(AStr) = 0 then
    Exit;

  LIdx := 1;

  (*
     Step 1: Skip whitespaces until we find any non-whitespace
  *)
  while (LIdx < Length(AStr)) and IsWhiteSpace(AStr, LIdx) do
    Inc(LIdx);

  if LIdx > Length(AStr) then
    Exit;

  (*
     Step 2: Check if the next char is + or -
  *)
  LIsNeg := false;
  if CharInSet(AStr[LIdx], ['-', '+']) then
  begin
    LIsNeg := AStr[LIdx] = '-';
    Inc(LIdx);
  end;

  (*
     Step 3: Check if this number is in scientific format (has Exxx) suffixed
  *)
  LEIdx := Length(AStr) + 1;
  LEVal := 0;
  for I := LIdx to Length(AStr) do
    if (AStr[I] = 'E') or (AStr[I] = 'e') then
    begin
      { We found an E/e. Treat the following as a number }
      if not TryStrToInt64(Copy(AStr, I + 1, Length(AStr)), LEVal) then
         Exit;

      LEIdx := I;
      break;
    end;

  (*
     Step 4: Extract the actual number
  *)

  { Copy the remaining part }
  LNum := Copy(AStr, LIdx, LEIdx - LIdx);

  if Length(LNum) = 0 then
    Exit;


  { Indentify the "dot" }
  LEIdx := Pos(ADecSep, LNum);

  { Ceck for the dot being the first char }
  if (LEIdx = 1) or (LEIdx = Length(LNum)) then
    Exit;

  { Only validate if there is a thousands separator specified }
  if AThSep <> #0 then
    LNum := CutAndValidate(LNum, AThSep, LEIdx);

  (*
     Step 5: Generate the scale
  *)

  if LEIdx > 0 then
  begin
    LScale := Length(LNum) - LEIdx;
    Delete(LNum, LEIdx, 1);
  end else
    LScale := 0;

  Dec(LScale, LEVal);

  { Try to parse what's left }
  if not BigInteger.TryParse(LNum, LIntVal) then
    Exit;

  if LIsNeg then
    LIntVal := -LIntVal;

  { EXIT! }
  Result := true;
  ANumber := BigDecimal.Create(LIntVal, LScale);
end;

class operator BigDecimal.Explicit(const ANumber: BigDecimal): Double;
begin
  Result := ANumber.ToDouble;
end;

class operator BigDecimal.Equal(const ALeft, ARight: BigDecimal): Boolean;
begin
  Result := ALeft.CompareTo(ARight) = 0;
end;

class operator BigDecimal.Explicit(const ANumber: BigDecimal): Extended;
begin
  Result := ANumber.ToDouble;
end;

function BigDecimal.GetData: TData;
begin
  { Try to get the enclused object. If this number is not well formed,
    use zero's information. }
  if Assigned(FData) then
    Result := FData.GetData()
  else
    Result := FCached_Numbers[0].GetData();
end;

function BigDecimal.GetIsNegative: Boolean;
begin
  { Simple }
  Result := GetData().FBigInteger.IsNegative;
end;

function BigDecimal.GetIsPositive: Boolean;
begin
  { Simple }
  Result := GetData().FBigInteger.IsPositive;
end;

function BigDecimal.GetIsZero: Boolean;
begin
  { Simple }
  Result := GetData().FBigInteger.IsZero;
end;

class function BigDecimal.GetMinusOne: BigDecimal;
begin
  Result.FData := FCached_Numbers[-1];
end;

class function BigDecimal.GetMinusTen: BigDecimal;
begin
  Result.FData := FCached_Numbers[-10];
end;

class function BigDecimal.GetOne: BigDecimal;
begin
  Result.FData := FCached_Numbers[1];
end;

function BigDecimal.GetPrecision: NativeUInt;
begin
  { Simple }
  Result := InternalGetPrecision(GetData());
end;

function BigDecimal.GetScale: NativeInt;
begin
  { Simple }
  Result := GetData().FScale;
end;

function BigDecimal.GetSign: SmallInt;
begin
  { Simple }
  Result := GetData().FBigInteger.Sign;
end;

class function BigDecimal.GetTen: BigDecimal;
begin
  Result.FData := FCached_Numbers[10];
end;

class function BigDecimal.GetType: IType<BigDecimal>;
begin
  Result := TBigDecimalType.Create();
end;

class function BigDecimal.GetZero: BigDecimal;
begin
  Result.FData := FCached_Numbers[0];
end;

class operator BigDecimal.GreaterThan(const ALeft, ARight: BigDecimal): Boolean;
begin
  Result := ALeft.CompareTo(ARight) > 0;
end;

class operator BigDecimal.GreaterThanOrEqual(const ALeft, ARight: BigDecimal): Boolean;
begin
  Result := ALeft.CompareTo(ARight) >= 0;
end;

class constructor BigDecimal.Create;
var
  I: NativeInt;
begin
  { DeHL type support stuff }
  TType<BigDecimal>.Register(TBigDecimalType);
  TMathExtension<BigDecimal>.Register(TBigDecimalMathExtension);

  { Register our custom variant type }
  SgtBigDecimalVariantType := TBigDecimalVariantType.Create();

  { Set the value of the varBigInteger }
  FVarType := SgtBigDecimalVariantType.VarType;

  { Initialize statics }
  for I := Low(FCached_Numbers) to High(FCached_Numbers) do
  begin
    { Build up the number }
    FCached_Numbers[I] := TData.Make(BigInteger.Create(I), 0, 0);
  end;

  { Prepare the "fast pow lookup table" }
  FFastPower[0] := BigInteger.One;
  for I := 1 to 10 do
    FFastPower[I] := FFastPower[I - 1] * BigInteger.Ten;
end;

class function BigDecimal.CutAndValidate(const AStr: string; const AThSep: Char; var ADotIdx: NativeInt): string;
var
  LFiLeft, LFiRight: NativeInt;
  I, D, R: NativeInt;
begin
  Result := '';

  { Do a fast check for the presence of ',' chars }
  if Pos(AThSep, AStr) = 0 then
    Exit(AStr);

  if ADotIdx = 0 then
  begin
    { No dots }
    LFiLeft := Length(AStr);
    LFiRight := 0;
  end else
  begin
    LFiLeft := ADotIdx - 1;
    LFiRight := ADotIdx + 1;
  end;

  R := 0;
  D := 0;
  for I := LFiLeft downto 1 do
  begin
    if D = 3 then
    begin
      D := 0;

      { Skip mandatory check }
      if (AStr[I] = AThSep) then
      begin
        Inc(R);
        Dec(ADotIdx);
        continue;
      end;
    end else
      Inc(D);

    { Mandatory check }
    if not CharInSet(AStr[I], ['0' .. '9']) then
      Exit;
  end;

  if LFiRight > 0 then
  begin
    D := 0;
    for I := LFiRight to Length(AStr) do
    begin
      if D = 3 then
      begin
        D := 0;

        { Skip mandatory check }
        if (AStr[I] = AThSep) then
        begin
          Inc(R);
          continue;
        end;
      end else
        Inc(D);

      { Mandatory check }
      if not CharInSet(AStr[I], ['0' .. '9']) then
        Exit;
    end;
  end;

  { If everything is OK, simply remove the ',' chars }
  D := 1;
  SetLength(Result, Length(AStr) - R);

  for I := 1 to Length(AStr) do
  begin
    if AStr[I] = AThSep then
      continue;

    Result[D] := AStr[I];
    Inc(D);
  end;
end;

function BigDecimal.Divide(const ADivisor: BigDecimal;
  const ANewScale: NativeInt; const ARoundingMode: TRoundingMode): BigDecimal;
var
  LLData, LRData: TData;
begin
  { Get data }
  LLData := GetData();
  LRData := ADivisor.GetData();

  { Check for imputs. InternalDivide expects well defined numbers }
  Result := InternalDivide(LLData, LRData, ANewScale, ARoundingMode);
end;

class operator BigDecimal.Explicit(const ANumber: Variant): BigDecimal;
begin
  { Call this one }
  Result := SgtBigDecimalVariantType.VarDataToBigDecimal(TVarData(ANumber));
end;

{ TBigDecimalType }

function TBigDecimalType.Compare(const AValue1, AValue2: BigDecimal): NativeInt;
begin
  Result := AValue1.CompareTo(AValue2);
end;

constructor TBigDecimalType.Create;
begin
  inherited;
  FBigIntegerType := BigInteger.GetType();
end;

procedure TBigDecimalType.DoDeserialize(const AInfo: TValueInfo;
  out AValue: BigDecimal; const AContext: IDeserializationContext);
var
  FScale: NativeInt;
  FPrec: NativeUInt;
  FInt: BigInteger;
  LStr: string;
begin
  { Either use my routine or call the inherited one to do the job }
  if AContext.InReadableForm then
  begin
    AContext.GetValue(AInfo, LStr);
    AValue := BigDecimal.Parse(LStr);
  end else
  begin
    { Open }
    AContext.ExpectRecordType(AInfo);

    { Extract each part of the record }
{$IF SizeOf(NativeInt) = SizeOf(Integer)}
    AContext.GetValue(TValueInfo.Create(SScale), Integer(FScale));
    AContext.GetValue(TValueInfo.Create(SPrecision), Cardinal(FPrec));
{$ELSE}
    AContext.GetValue(TValueInfo.Create(SScale), Int64(FScale));
    AContext.GetValue(TValueInfo.Create(SPrecision), UInt64(FPrec));
{$IFEND}
    FBigIntegerType.Deserialize(TValueInfo.Create(SUnscaledValue), FInt, AContext);

    { And instantiate a decimal }
    AValue.FData := BigDecimal.TData.Make(FInt, FScale, FPrec);

    { Close }
    AContext.EndComplexType();
  end;
end;

procedure TBigDecimalType.DoSerialize(const AInfo: TValueInfo;
  const AValue: BigDecimal; const AContext: ISerializationContext);
var
  LData: BigDecimal.TData;
begin
  { Either use my routine or call the inherited one to do the job }
  if AContext.InReadableForm then
    AContext.AddValue(AInfo, AValue.ToString(false))
  else
  begin
    { Open }
    AContext.StartRecordType(AInfo);

    LData := AValue.GetData();

    { Extract each part of the record }
    AContext.AddValue(TValueInfo.Create(SScale), LData.FScale);
    AContext.AddValue(TValueInfo.Create(SPrecision), LData.FPrecision);

    FBigIntegerType.Serialize(TValueInfo.Create(SUnscaledValue), LData.FBigInteger, AContext);

    { Close }
    AContext.EndComplexType();
  end;
end;

function TBigDecimalType.Family: TTypeFamily;
begin
  Result := tfReal;
end;

function TBigDecimalType.GenerateHashCode(const AValue: BigDecimal): NativeInt;
var
  LData: BigDecimal.TData;
begin
  { Get data }
  LData := AValue.GetData();

  { Generate a relevant hash }
  Result := FBigIntegerType.GenerateHashCode(LData.FBigInteger) xor LData.FScale
end;

function TBigDecimalType.GetString(const AValue: BigDecimal): String;
begin
  Result := AValue.ToString();
end;

function TBigDecimalType.TryConvertFromVariant(const AValue: Variant; out ORes: BigDecimal): Boolean;
begin
  { May not be a valid BigCardinal }
  try
    ORes := SgtBigDecimalVariantType.VarDataToBigDecimal(TVarData(AValue));
  except
    Exit(false);
  end;

  Result := true;
end;

function TBigDecimalType.TryConvertToVariant(const AValue: BigDecimal; out ORes: Variant): Boolean;
begin
  ORes := AValue;
  Result := true;
end;

{ TBigDecimalMathExtension }

function TBigDecimalMathExtension.Abs(const AValue: BigDecimal): BigDecimal;
begin
  Result := AValue.Abs();
end;

function TBigDecimalMathExtension.Add(const AValue1, AValue2: BigDecimal): BigDecimal;
begin
  Result := AValue1 + AValue2;
end;

function TBigDecimalMathExtension.Divide(const AValue1, AValue2: BigDecimal): BigDecimal;
begin
  Result := AValue1 / AValue2;
end;

function TBigDecimalMathExtension.MinusOne: BigDecimal;
begin
  Result := BigDecimal.MinusOne;
end;

function TBigDecimalMathExtension.Multiply(const AValue1, AValue2: BigDecimal): BigDecimal;
begin
  Result := AValue1 * AValue2;
end;

function TBigDecimalMathExtension.Negate(const AValue: BigDecimal): BigDecimal;
begin
  Result := -AValue;
end;

function TBigDecimalMathExtension.One: BigDecimal;
begin
  Result := BigDecimal.One;
end;

function TBigDecimalMathExtension.Subtract(const AValue1, AValue2: BigDecimal): BigDecimal;
begin
  Result := AValue1 - AValue2;
end;

function TBigDecimalMathExtension.Zero: BigDecimal;
begin
  Result := BigDecimal.Zero;
end;

end.
