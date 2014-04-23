(*
* Copyright (c) 2009, Ciobanu Alexandru
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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.MathTypes;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Math.Half,
     DeHL.Math.BigDecimal,
     DeHL.Math.BigCardinal,
     DeHL.Math.BigInteger,
     DeHL.Math.Types;

type
  TTestMathTypes = class(TDeHLTestCase)
  published
    procedure TestByte;
    procedure TestShortInt;
    procedure TestWord;
    procedure TestSmallInt;
    procedure TestCardinal;
    procedure TestInteger;
    procedure TestNativeUInt;
    procedure TestNativeInt;
    procedure TestUInt64;
    procedure TestInt64;
    procedure TestBigCardinal;
    procedure TestBigInteger;
    procedure TestBigDecimal;
    procedure TestHalf;
    procedure TestSingle;
    procedure TestDouble;
    procedure TestExtended;
    procedure TestCurrency;
    procedure TestComp;

    { Important tests }
    procedure TestOpCommon;
    procedure TestOpNatural;
    procedure TestOpInteger;

    procedure TestRegisterAndUnregister;
    procedure TestExceptionForNoExtension;
  end;

type
  TMyDouble = type Double;

  { Math extensions for the Double type }
  TMyDoubleMathExtension = class sealed(TRealMathExtension<Double>)
  public
    { Standard operations }
    function Add(const AValue1, AValue2: Double): Double; override;
    function Subtract(const AValue1, AValue2: Double): Double; override;
    function Multiply(const AValue1, AValue2: Double): Double; override;
    function Divide(const AValue1, AValue2: Double): Double; override;

    { Sign-related operations }
    function Negate(const AValue: Double): Double; override;
    function Abs(const AValue: Double): Double; override;

    { Neutral Math elements }
    function Zero: Double; override;
    function One: Double; override;
    function MinusOne: Double; override;
  end;

implementation

{ TTestMathTypes }

procedure TTestMathTypes.TestBigCardinal;
var
  Implicit: IUnsignedIntegerMathExtension<BigCardinal>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<BigCardinal>.Natural;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(20, 30) = 50, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, 20) = 200, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
end;

procedure TTestMathTypes.TestBigDecimal;
var
  Implicit: IRealMathExtension<BigDecimal>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<BigDecimal>.Real;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Divide(10, -2) = -5, 'Implicit.Divide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = BigDecimal.Zero, 'Implicit.Zero failed!');
  Check(Implicit.One = BigDecimal.One, 'Implicit.One failed!');
  Check(Implicit.MinusOne = BigDecimal.MinusOne, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestBigInteger;
var
  Implicit: IIntegerMathExtension<BigInteger>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<BigInteger>.Integer;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestByte;
var
  Implicit: IUnsignedIntegerMathExtension<Byte>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Byte>.Natural;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(20, 30) = 50, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, 20) = 200, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
end;

procedure TTestMathTypes.TestCardinal;
var
  Implicit: IUnsignedIntegerMathExtension<Cardinal>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Cardinal>.Natural;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(20, 30) = 50, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, 20) = 200, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
end;

procedure TTestMathTypes.TestComp;
var
  Implicit: IRealMathExtension<Comp>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Comp>.Real;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Divide(10, -2) = -5, 'Implicit.Divide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestCurrency;
var
  Implicit: IRealMathExtension<Currency>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Currency>.Real;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Divide(10, -2) = -5, 'Implicit.Divide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestDouble;
var
  Implicit: IRealMathExtension<Double>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Double>.Real;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Divide(10, -2) = -5, 'Implicit.Divide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestExceptionForNoExtension;
begin
  CheckException(ETypeException, procedure begin
    TMathExtension<string>.Real();
  end, 'Expected ETypeException exception in Real(string)');
end;

procedure TTestMathTypes.TestExtended;
var
  Implicit: IRealMathExtension<Extended>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Extended>.Real;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Divide(10, -2) = -5, 'Implicit.Divide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestHalf;
var
  Implicit: IRealMathExtension<Half>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Half>.Real;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Divide(10, -2) = -5, 'Implicit.Divide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = Half.Zero, 'Implicit.Zero failed!');
  Check(Implicit.One = Half.One, 'Implicit.One failed!');
  Check(Implicit.MinusOne = Half.MinusOne, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestInt64;
var
  Implicit: IIntegerMathExtension<Int64>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Int64>.Integer;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestInteger;
var
  Implicit: IIntegerMathExtension<Integer>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Integer>.Integer;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestNativeInt;
var
  Implicit: IIntegerMathExtension<NativeInt>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<NativeInt>.Integer;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestNativeUInt;
var
  Implicit: IUnsignedIntegerMathExtension<NativeUInt>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<NativeUInt>.Natural;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(20, 30) = 50, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, 20) = 200, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
end;

procedure TTestMathTypes.TestOpCommon;
begin
  { Verify basic operations }
  CheckException(ENilArgumentException, procedure begin
    TMathExtension<Byte>.Common(nil);
  end, 'Expected ENilArgumentException exception in Common(nil)');

  CheckException(ETypeException, procedure begin
    TMathExtension<Boolean>.Common();
  end, 'Expected ETypeException exception in Common()');

  Check(TMathExtension<Byte>.Common(TType<Byte>.Default) <> nil, 'Expected a valid math extension!');

  { Verify every known type }
  Check(TMathExtension<Byte>.Common <> nil, 'Expected a valid value for Byte-Common');
  Check(TMathExtension<ShortInt>.Common <> nil, 'Expected a valid value for ShortInt-Common');
  Check(TMathExtension<Word>.Common <> nil, 'Expected a valid value for Word-Common');
  Check(TMathExtension<SmallInt>.Common <> nil, 'Expected a valid value for SmallInt-Common');
  Check(TMathExtension<Cardinal>.Common <> nil, 'Expected a valid value for Cardinal-Common');
  Check(TMathExtension<Integer>.Common <> nil, 'Expected a valid value for Integer-Common');
  Check(TMathExtension<NativeUInt>.Common <> nil, 'Expected a valid value for NativeUInt-Common');
  Check(TMathExtension<NativeInt>.Common <> nil, 'Expected a valid value for NativeInt-Common');
  Check(TMathExtension<UInt64>.Common <> nil, 'Expected a valid value for UInt64-Common');
  Check(TMathExtension<Int64>.Common <> nil, 'Expected a valid value for Int64-Common');
  Check(TMathExtension<BigCardinal>.Common <> nil, 'Expected a valid value for BigCardinal-Common');
  Check(TMathExtension<BigInteger>.Common <> nil, 'Expected a valid value for BigInteger-Common');
  Check(TMathExtension<Single>.Common <> nil, 'Expected a valid value for BigInteger-Common');
  Check(TMathExtension<Double>.Common <> nil, 'Expected a valid value for BigInteger-Common');
  Check(TMathExtension<Real>.Common <> nil, 'Expected a valid value for BigInteger-Common');
  Check(TMathExtension<Extended>.Common <> nil, 'Expected a valid value for BigInteger-Common');
  Check(TMathExtension<Currency>.Common <> nil, 'Expected a valid value for BigInteger-Common');
  Check(TMathExtension<Comp>.Common <> nil, 'Expected a valid value for BigInteger-Common');
end;

procedure TTestMathTypes.TestOpInteger;
begin
  { Verify basic operations }
  CheckException(ENilArgumentException, procedure begin
    TMathExtension<Integer>.Integer(nil);
  end, 'Expected ENilArgumentException exception in Integer(nil)');

  CheckException(ETypeException, procedure begin
    TMathExtension<Boolean>.Integer();
  end, 'Expected ETypeException exception in Integer()');

  Check(TMathExtension<Integer>.Integer(TType<Integer>.Default) <> nil, 'Expected a valid math extension!');

  { Verify every known type }
  CheckException(ETypeException, procedure begin
    TMathExtension<Byte>.Integer();
  end, 'Expected type restriction for Byte-Integer');

  Check(TMathExtension<ShortInt>.Integer <> nil, 'Expected a valid value for ShortInt-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Word>.Integer();
  end, 'Expected type restriction for Word-Integer');

  Check(TMathExtension<SmallInt>.Integer <> nil, 'Expected a valid value for SmallInt-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Cardinal>.Integer();
  end, 'Expected type restriction for Cardinal-Integer');

  Check(TMathExtension<Integer>.Integer <> nil, 'Expected a valid value for Integer-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<NativeUInt>.Integer();
  end, 'Expected type restriction for NativeUInt-Integer');

  Check(TMathExtension<NativeInt>.Integer <> nil, 'Expected a valid value for NativeInt-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<UInt64>.Integer();
  end, 'Expected type restriction for UInt64-Integer');

  Check(TMathExtension<Int64>.Integer <> nil, 'Expected a valid value for Int64-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<BigCardinal>.Integer();
  end, 'Expected type restriction for BigCardinal-Integer');

  Check(TMathExtension<BigInteger>.Integer <> nil, 'Expected a valid value for BigInteger-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Single>.Integer();
  end, 'Expected type restriction for Single-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Double>.Integer();
  end, 'Expected type restriction for Double-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Real>.Integer();
  end, 'Expected type restriction for Real-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Extended>.Integer();
  end, 'Expected type restriction for Extended-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Currency>.Integer();
  end, 'Expected type restriction for Currency-Integer');

  CheckException(ETypeException, procedure begin
    TMathExtension<Comp>.Integer();
  end, 'Expected type restriction for Comp-Integer');
end;

procedure TTestMathTypes.TestOpNatural;
begin
  { Verify basic operations }
  CheckException(ENilArgumentException, procedure begin
    TMathExtension<Byte>.Natural(nil);
  end, 'Expected ENilArgumentException exception in Natural(nil)');

  CheckException(ETypeException, procedure begin
    TMathExtension<Boolean>.Natural();
  end, 'Expected ETypeException exception in Natural()');

  Check(TMathExtension<Byte>.Natural(TType<Byte>.Default) <> nil, 'Expected a valid math extension!');

  { Verify every known type }
  Check(TMathExtension<Byte>.Natural <> nil, 'Expected a valid value for Byte-Natural');
  Check(TMathExtension<ShortInt>.Natural <> nil, 'Expected a valid value for ShortInt-Natural');
  Check(TMathExtension<Word>.Natural <> nil, 'Expected a valid value for Word-Natural');
  Check(TMathExtension<SmallInt>.Natural <> nil, 'Expected a valid value for SmallInt-Natural');
  Check(TMathExtension<Cardinal>.Natural <> nil, 'Expected a valid value for Cardinal-Natural');
  Check(TMathExtension<Integer>.Natural <> nil, 'Expected a valid value for Integer-Natural');
  Check(TMathExtension<NativeUInt>.Natural <> nil, 'Expected a valid value for NativeUInt-Natural');
  Check(TMathExtension<NativeInt>.Natural <> nil, 'Expected a valid value for NativeInt-Natural');
  Check(TMathExtension<UInt64>.Natural <> nil, 'Expected a valid value for UInt64-Natural');
  Check(TMathExtension<Int64>.Natural <> nil, 'Expected a valid value for Int64-Natural');
  Check(TMathExtension<BigCardinal>.Natural <> nil, 'Expected a valid value for BigCardinal-Natural');
  Check(TMathExtension<BigInteger>.Natural <> nil, 'Expected a valid value for BigInteger-Natural');

  CheckException(ETypeException, procedure begin
    TMathExtension<Single>.Integer();
  end, 'Expected type restriction for Single-Natural');

  CheckException(ETypeException, procedure begin
    TMathExtension<Double>.Integer();
  end, 'Expected type restriction for Double-Natural');

  CheckException(ETypeException, procedure begin
    TMathExtension<Real>.Integer();
  end, 'Expected type restriction for Real-Natural');

  CheckException(ETypeException, procedure begin
    TMathExtension<Extended>.Integer();
  end, 'Expected type restriction for Extended-Natural');

  CheckException(ETypeException, procedure begin
    TMathExtension<Currency>.Integer();
  end, 'Expected type restriction for Currency-Natural');

  CheckException(ETypeException, procedure begin
    TMathExtension<Comp>.Integer();
  end, 'Expected type restriction for Comp-Natural');
end;

procedure TTestMathTypes.TestRegisterAndUnregister;
begin
  TMathExtension<Double>.Unregister();

  { Register it back }
  TMathExtension<Double>.Register(TMyDoubleMathExtension);

  { Try again! }
  CheckException(ETypeExtensionException, procedure begin
    TMathExtension<Double>.Register(TMyDoubleMathExtension);
  end, 'Expected ETypeExtensionException exception in Register(Double)');

  { Unregister }
  TMathExtension<Double>.Unregister();

  { Try again! }
  CheckException(ETypeExtensionException, procedure begin
    TMathExtension<Double>.Unregister();
  end, 'Expected ETypeExtensionException exception in Unregister(Double)');

  { Register it back }
  TMathExtension<Double>.Register(TMyDoubleMathExtension);
end;

procedure TTestMathTypes.TestShortInt;
var
  Implicit: IIntegerMathExtension<ShortInt>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<ShortInt>.Integer;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestSingle;
var
  Implicit: IRealMathExtension<Single>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Single>.Real;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Divide(10, -2) = -5, 'Implicit.Divide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestSmallInt;
var
  Implicit: IIntegerMathExtension<SmallInt>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<SmallInt>.Integer;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(-20, 30) = 10, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, -2) = -20, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Negate(-10) = 10, 'Implicit.Negate failed!');
  Check(Implicit.Abs(-10) = 10, 'Implicit.Abs failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
  Check(Implicit.MinusOne = -1, 'Implicit.MinusOne failed!');
end;

procedure TTestMathTypes.TestUInt64;
var
  Implicit: IUnsignedIntegerMathExtension<UInt64>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<UInt64>.Natural;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(20, 30) = 50, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, 20) = 200, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
end;

procedure TTestMathTypes.TestWord;
var
  Implicit: IUnsignedIntegerMathExtension<Word>;
begin
  { Obtain the math extensions }
  Implicit := TMathExtension<Word>.Natural;

  Check(Implicit <> nil, 'Implicit math extension was not acquired!');

  { Perform basic operations }
  Check(Implicit.Add(20, 30) = 50, 'Implicit.Add failed!');
  Check(Implicit.Subtract(30, 20) = 10, 'Implicit.Subtract failed!');
  Check(Implicit.Multiply(10, 20) = 200, 'Implicit.Multiply failed!');
  Check(Implicit.Modulo(10, 3) = 1, 'Implicit.Modulo failed!');
  Check(Implicit.IntegralDivide(10, 3) = 3, 'Implicit.IntegralDivide failed!');
  Check(Implicit.Zero = 0, 'Implicit.Zero failed!');
  Check(Implicit.One = 1, 'Implicit.One failed!');
end;

{ TMyDoubleMathExtension }

function TMyDoubleMathExtension.Abs(const AValue: Double): Double;
begin
  Result := System.Abs(AValue);
end;

function TMyDoubleMathExtension.Add(const AValue1, AValue2: Double): Double;
begin
  Result := AValue1 + AValue2;
end;

function TMyDoubleMathExtension.Divide(const AValue1, AValue2: Double): Double;
begin
  Result := AValue1 / AValue2;
end;

function TMyDoubleMathExtension.MinusOne: Double;
begin
  Result := -1;
end;

function TMyDoubleMathExtension.Multiply(const AValue1, AValue2: Double): Double;
begin
  Result := AValue1 * AValue2;
end;

function TMyDoubleMathExtension.Negate(const AValue: Double): Double;
begin
  Result := -AValue;
end;

function TMyDoubleMathExtension.One: Double;
begin
  Result := 1;
end;

function TMyDoubleMathExtension.Subtract(const AValue1, AValue2: Double): Double;
begin
  Result := AValue1 - AValue2;
end;

function TMyDoubleMathExtension.Zero: Double;
begin
  Result := 0;
end;

initialization
  TestFramework.RegisterTest(TTestMathTypes.Suite);

end.
