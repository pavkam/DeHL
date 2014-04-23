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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.BigDecimal;
interface

uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     Math,
     DeHL.Math.BigCardinal,
     DeHL.Math.BigInteger,
     DeHL.Math.BigDecimal;

type
  TTestBigDecimal = class(TDeHLTestCase)
  private
    FOldDec, FOldTh: Char;

    procedure TestOp(const X, Y: BigDecimal; const AComp: NativeInt);
  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure Test_Create_Integer_Scale;
    procedure Test_Create_Cardinal_Scale;
    procedure Test_Create_Int64_Scale;
    procedure Test_Create_UInt64_Scale;
    procedure Test_Create_BigInteger_Scale;
    procedure Test_Create_BigCardinal_Scale;
    procedure Test_Create_Double;
    procedure Test_ToDouble;
    procedure Test_ToBigInteger;
    procedure Test_CompareTo_And_Ops;
    procedure Test_Abs;
    procedure Test_IsZero;
    procedure Test_IsNegative;
    procedure Test_IsPositive;
    procedure Test_Precision;
    procedure Test_Scale;
    procedure Test_Sign;
    procedure Test_Rescale;
    procedure Test_Pow;
    procedure Test_ScaleByPowerOfTen;
    procedure Test_Divide;
    procedure Test_Round;
    procedure Test_TryParse_FmtSettings;
    procedure Test_TryParse;
    procedure Test_Parse_FmtSettings;
    procedure Test_Parse;
    procedure Test_ToString_FmtSettings;
    procedure Test_ToString;
    procedure Test_Op_Add;
    procedure Test_Op_Subtract;
    procedure Test_Op_Multiply;
    procedure Test_Op_Divide;
    procedure Test_Op_Negative;
    procedure Test_Op_Positive;
    procedure Test_Implicit_From_Cardinal;
    procedure Test_Implicit_From_UInt64;
    procedure Test_Implicit_From_Integer;
    procedure Test_Implicit_From_In64;
    procedure Test_Implicit_From_Double;
    procedure Test_Implicit_From_BigCardinal;
    procedure Test_Implicit_From_BigInteger;
    procedure Test_Implicit_To_Variant;
    procedure Test_Explicit_From_Variant;
    procedure Test_Explicit_To_Double;
    procedure Test_Explicit_To_Extended;
    procedure Test_VarType;
    procedure Test_VariantSupport;
    procedure Test_GetType;
    procedure Test_Type;
    procedure Test_Zero;
    procedure Test_One;
    procedure Test_MinusOne;
    procedure Test_Ten;
    procedure Test_MinusTen;

    { Situational tests ... more to come }
    procedure Test_Conformance_1;
    procedure Test_Conformance_2;
    procedure Test_Conformance_3;
    procedure Test_Conformance_4;
    procedure Test_Conformance_5;
  end;

implementation
uses
  Variants;

{ TTestBigDecimal }

procedure TTestBigDecimal.SetUp;
begin
  inherited;

  FOldDec := DecimalSeparator;
  FOldTh := ThousandSeparator;

  DecimalSeparator := '.';
  ThousandSeparator := ',';
end;

procedure TTestBigDecimal.TearDown;
begin
  inherited;

  DecimalSeparator := FOldDec;
  ThousandSeparator := FOldTh;
end;

procedure TTestBigDecimal.TestOp(const X, Y: BigDecimal; const AComp: NativeInt);
begin
  { Actual comparison }
  CheckTrue(X.CompareTo(Y) = AComp);
  CheckTrue(Y.CompareTo(X) = -AComp);

  { Equality }
  CheckEquals(AComp = 0, X = Y);
  CheckEquals(AComp = 0, Y = X);

  { Inequality }
  CheckEquals(AComp <> 0, X <> Y);
  CheckEquals(AComp <> 0, Y <> X);

  { Greater than }
  CheckEquals(AComp > 0, X > Y);
  CheckEquals(AComp > 0, Y < X);

  { Lower than }
  CheckEquals(AComp < 0, X < Y);
  CheckEquals(AComp < 0, Y > X);

  { Greater than or Equal }
  CheckEquals(AComp >= 0, X >= Y);
  CheckEquals(AComp >= 0, Y <= X);

  { Lower than or Equal }
  CheckEquals(AComp <= 0, X <= Y);
  CheckEquals(AComp <= 0, Y >= X);
end;

procedure TTestBigDecimal.Test_Conformance_1;
var
  D: BigDecimal;
begin
  D := 0.1950;
  D := D.Rescale(2, rmHalfDown);
  CheckEquals('0.20', D.ToString(false));

  D := BigDecimal.Parse('0.1950');
  D := D.Rescale(2, rmHalfDown);
  CheckEquals('0.19', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Conformance_2;
var
  D, txR, V, R: BigDecimal;
begin
  { The extension of scale and precision }
  D := BigDecimal.Parse('1115.32');
  txR := BigDecimal.Parse('0.0049');
  R := D * txR;
  CheckEquals('5.465068', R.ToString(false));

  { Rescaling }
  R := R.Rescale(2, rmHalfUp);
  CheckEquals('5.47', R.ToString(false));

  { Proper division }
  txR := BigDecimal.Parse('30');
  R := D.Divide(txR, 2, rmHalfUp);
  CheckEquals('37.18', R.ToString(false));

  D := BigDecimal.Parse('9500.00');
  txR := BigDecimal.Parse('0.067');
  V := BigDecimal.Parse('0.25');
  R := (D * txR) * V;
  CheckEquals('159.1250000', R.ToString(false));

  R := R.Rescale(2, rmDown);
  CheckEquals('159.12', R.ToString(false));
end;

procedure TTestBigDecimal.Test_Conformance_3;
var
  X, rUp, rDown, rCeiling,
    rFloor, rHalfUp, rHalfDown,
      rHalfEven, rNone: BigDecimal;
begin
  { 5.5 }
  X := BigDecimal.Parse('5.5');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('6', rUp.ToString(false));
  CheckEquals('5', rDown.ToString(false));
  CheckEquals('6', rCeiling.ToString(false));
  CheckEquals('5', rFloor.ToString(false));
  CheckEquals('6', rHalfUp.ToString(false));
  CheckEquals('5', rHalfDown.ToString(false));
  CheckEquals('6', rHalfEven.ToString(false));

  { 2.5 }
  X := BigDecimal.Parse('2.5');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('3', rUp.ToString(false));
  CheckEquals('2', rDown.ToString(false));
  CheckEquals('3', rCeiling.ToString(false));
  CheckEquals('2', rFloor.ToString(false));
  CheckEquals('3', rHalfUp.ToString(false));
  CheckEquals('2', rHalfDown.ToString(false));
  CheckEquals('2', rHalfEven.ToString(false));

  { 1.6 }
  X := BigDecimal.Parse('1.6');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('2', rUp.ToString(false));
  CheckEquals('1', rDown.ToString(false));
  CheckEquals('2', rCeiling.ToString(false));
  CheckEquals('1', rFloor.ToString(false));
  CheckEquals('2', rHalfUp.ToString(false));
  CheckEquals('2', rHalfDown.ToString(false));
  CheckEquals('2', rHalfEven.ToString(false));

  { 1.1 }
  X := BigDecimal.Parse('1.1');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('2', rUp.ToString(false));
  CheckEquals('1', rDown.ToString(false));
  CheckEquals('2', rCeiling.ToString(false));
  CheckEquals('1', rFloor.ToString(false));
  CheckEquals('1', rHalfUp.ToString(false));
  CheckEquals('1', rHalfDown.ToString(false));
  CheckEquals('1', rHalfEven.ToString(false));

  { 1.0 }
  X := BigDecimal.Parse('1.0');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);
  rNone := X.Round(1, rmNone);

  CheckEquals('1', rUp.ToString(false));
  CheckEquals('1', rDown.ToString(false));
  CheckEquals('1', rCeiling.ToString(false));
  CheckEquals('1', rFloor.ToString(false));
  CheckEquals('1', rHalfUp.ToString(false));
  CheckEquals('1', rHalfDown.ToString(false));
  CheckEquals('1', rHalfEven.ToString(false));
  CheckEquals('1', rNone.ToString(false));

  { -1.0 }
  X := BigDecimal.Parse('-1.0');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);
  rNone := X.Round(1, rmNone);

  CheckEquals('-1', rUp.ToString(false));
  CheckEquals('-1', rDown.ToString(false));
  CheckEquals('-1', rCeiling.ToString(false));
  CheckEquals('-1', rFloor.ToString(false));
  CheckEquals('-1', rHalfUp.ToString(false));
  CheckEquals('-1', rHalfDown.ToString(false));
  CheckEquals('-1', rHalfEven.ToString(false));
  CheckEquals('-1', rNone.ToString(false));

  { -1.1 }
  X := BigDecimal.Parse('-1.1');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('-2', rUp.ToString(false));
  CheckEquals('-1', rDown.ToString(false));
  CheckEquals('-1', rCeiling.ToString(false));
  CheckEquals('-2', rFloor.ToString(false));
  CheckEquals('-1', rHalfUp.ToString(false));
  CheckEquals('-1', rHalfDown.ToString(false));
  CheckEquals('-1', rHalfEven.ToString(false));

  { -1.6 }
  X := BigDecimal.Parse('-1.6');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('-2', rUp.ToString(false));
  CheckEquals('-1', rDown.ToString(false));
  CheckEquals('-1', rCeiling.ToString(false));
  CheckEquals('-2', rFloor.ToString(false));
  CheckEquals('-2', rHalfUp.ToString(false));
  CheckEquals('-2', rHalfDown.ToString(false));
  CheckEquals('-2', rHalfEven.ToString(false));

  { -2.5 }
  X := BigDecimal.Parse('-2.5');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('-3', rUp.ToString(false));
  CheckEquals('-2', rDown.ToString(false));
  CheckEquals('-2', rCeiling.ToString(false));
  CheckEquals('-3', rFloor.ToString(false));
  CheckEquals('-3', rHalfUp.ToString(false));
  CheckEquals('-2', rHalfDown.ToString(false));
  CheckEquals('-2', rHalfEven.ToString(false));

  { -5.5 }
  X := BigDecimal.Parse('-5.5');
  rUp := X.Round(1, rmUp);
  rDown := X.Round(1, rmDown);
  rCeiling := X.Round(1, rmCeiling);
  rFloor := X.Round(1, rmFloor);
  rHalfUp := X.Round(1, rmHalfUp);
  rHalfDown := X.Round(1, rmHalfDown);
  rHalfEven := X.Round(1, rmHalfEven);

  CheckException(EInvalidOp, procedure begin
    rNone := X.Round(1, rmNone);
  end, 'Expected an EInvalidOp!');

  CheckEquals('-6', rUp.ToString(false));
  CheckEquals('-5', rDown.ToString(false));
  CheckEquals('-5', rCeiling.ToString(false));
  CheckEquals('-6', rFloor.ToString(false));
  CheckEquals('-6', rHalfUp.ToString(false));
  CheckEquals('-5', rHalfDown.ToString(false));
  CheckEquals('-6', rHalfEven.ToString(false));
end;


procedure TTestBigDecimal.Test_Conformance_4;
var
  S, PA, PPS, SP, AV: BigDecimal;
begin
  { Some monetary stuff I found laying on the web }
  S := BigDecimal.Parse('754.495');
  PA := BigDecimal.Parse('200.00');
  PPS := BigDecimal.Parse('10.38');
  SP := PA.Divide(PPS, 3, rmHalfUp);
  S := S + SP;
  AV := S * PPS;
  AV := AV.Round(7, rmHalfEven);

  CheckEquals('773.763', S.ToString(false));
  CheckEquals('8031.660', AV.ToString(false));
end;

procedure TTestBigDecimal.Test_Conformance_5;
var
  A, DP, D, T, TP, TX, TT: BigDecimal;
begin
  { Another accounting example found on teh webz }
  A := BigDecimal.Parse('100.05');
  DP := BigDecimal.Parse('0.10');
  D := A * DP;
  D := D.Rescale(2, rmHalfUp);

  T := A - D;
  T := T.Rescale(2, rmHalfUp);
  TP := BigDecimal.Parse('0.05');
  TX := T * TP;
  TX := TX.Rescale(2, rmHalfUp);

  TT := T + TX;
  TT := TT.Rescale(2, rmHalfUp);

  CheckEquals('100.05', A.ToString(false));
  CheckEquals('10.01', D.ToString(false));
  CheckEquals('90.04', T.ToString(false));
  CheckEquals('4.50', TX.ToString(false));
  CheckEquals('94.54', TT.ToString(false));
end;

procedure TTestBigDecimal.Test_Abs;
var
  X: BigDecimal;
begin
  X := 0;
  CheckEquals(X.ToString, X.Abs().ToString);

  X := -10000;
  CheckEquals((-X).ToString, X.Abs().ToString);

  X := BigDecimal.Parse('-38912638721637812638721637821637862178361278.78351276356');
  CheckEquals((-X).ToString, X.Abs().ToString);

  X := BigDecimal.Parse('38912638721637812638721637821637862178361278.78351276356');
  CheckEquals(X.ToString, X.Abs().ToString);
end;

procedure TTestBigDecimal.Test_CompareTo_And_Ops;
begin
  TestOp(0, 0, 0);
  TestOp(1, 0, 1);
  TestOp(-1, 0, -1);

  TestOp(3.14, 3.14, 0);

  TestOp(
    BigDecimal.Parse('3617253762153716235216735123761233123213.99'),
    BigDecimal.Parse('3617253762153716235216735123761233123214.00'),
    -1
  );

  TestOp(
    BigDecimal.Parse('100'),
    BigDecimal.Parse('100.0000000000'),
    0
  );

  TestOp(
    BigDecimal.Create(1, -2),
    BigDecimal.Create(100),
    0
  );

  TestOp(
    BigDecimal.Create(1, 2),
    BigDecimal.Parse('0.01'),
    0
  );
end;


procedure TTestBigDecimal.Test_Create_BigCardinal_Scale;
var
  D: BigDecimal;
begin
  D := BigDecimal.Create(BigCardinal(0));
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Create(BigCardinal(0), 10);
  CheckEquals('0.0000000000', D.ToString(false));

  D := BigDecimal.Create(BigCardinal(1));
  CheckEquals('1', D.ToString(false));

  D := BigDecimal.Create(BigCardinal(1), 10);
  CheckEquals('0.0000000001', D.ToString(false));

  D := BigDecimal.Create(BigCardinal(1), -10);
  CheckEquals('10000000000', D.ToString(false));

  D := BigDecimal.Create(BigCardinal(550), 2);
  CheckEquals('5.50', D.ToString(false));

  D := BigDecimal.Create(BigCardinal.Parse('378126357812632178637821632138726138721'), 2);
  CheckEquals('3781263578126321786378216321387261387.21', D.ToString(false));

  D := BigDecimal.Create(BigCardinal.Parse('378126357812632178637821632138726138721'));
  CheckEquals('378126357812632178637821632138726138721', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Create_BigInteger_Scale;
var
  D: BigDecimal;
begin
  D := BigDecimal.Create(BigInteger(0));
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Create(BigInteger(0), 10);
  CheckEquals('0.0000000000', D.ToString(false));

  D := BigDecimal.Create(BigInteger(1));
  CheckEquals('1', D.ToString(false));

  D := BigDecimal.Create(BigInteger(1), 10);
  CheckEquals('0.0000000001', D.ToString(false));

  D := BigDecimal.Create(BigInteger(1), -10);
  CheckEquals('10000000000', D.ToString(false));

  D := BigDecimal.Create(BigInteger(-550), 2);
  CheckEquals('-5.50', D.ToString(false));

  D := BigDecimal.Create(BigInteger.Parse('-378126357812632178637821632138726138721'), 2);
  CheckEquals('-3781263578126321786378216321387261387.21', D.ToString(false));

  D := BigDecimal.Create(BigInteger.Parse('-378126357812632178637821632138726138721'));
  CheckEquals('-378126357812632178637821632138726138721', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Create_Cardinal_Scale;
var
  D: BigDecimal;
begin
  D := BigDecimal.Create(Cardinal(0));
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Create(Cardinal(0), 10);
  CheckEquals('0.0000000000', D.ToString(false));

  D := BigDecimal.Create(Cardinal(1));
  CheckEquals('1', D.ToString(false));

  D := BigDecimal.Create(Cardinal(1), 10);
  CheckEquals('0.0000000001', D.ToString(false));

  D := BigDecimal.Create(Cardinal(1), -10);
  CheckEquals('10000000000', D.ToString(false));

  D := BigDecimal.Create(Cardinal(550), 2);
  CheckEquals('5.50', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Create_Double;
var
  D: BigDecimal;
begin
  D := BigDecimal.Create(1.0);
  CheckEquals('1', D.ToString(false));

  D := BigDecimal.Create(100.0);
  CheckEquals('100', D.ToString(false));

  D := BigDecimal.Create(-0.1);
  CheckEquals('-0.1000000000000000055511151231257827021181583404541015625', D.ToString(false));

  D := BigDecimal.Create(-66.11);
  CheckEquals('-66.1099999999999994315658113919198513031005859375', D.ToString(false));

  CheckException(EInvalidOp, procedure begin
    D := BigDecimal.Create(NaN);
  end, 'Expected an EInvalidOp!');

  CheckException(EInvalidOp, procedure begin
    D := BigDecimal.Create(Infinity);
  end, 'Expected an EInvalidOp!');
end;

procedure TTestBigDecimal.Test_Create_Int64_Scale;
var
  D: BigDecimal;
begin
  D := BigDecimal.Create(Int64(0));
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Create(Int64(0), 10);
  CheckEquals('0.0000000000', D.ToString(false));

  D := BigDecimal.Create(Int64(1));
  CheckEquals('1', D.ToString(false));

  D := BigDecimal.Create(Int64(1), 10);
  CheckEquals('0.0000000001', D.ToString(false));

  D := BigDecimal.Create(Int64(1), -10);
  CheckEquals('10000000000', D.ToString(false));

  D := BigDecimal.Create(Int64(-550), 2);
  CheckEquals('-5.50', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Create_Integer_Scale;
var
  D: BigDecimal;
begin
  D := BigDecimal.Create(Integer(0));
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Create(Integer(0), 10);
  CheckEquals('0.0000000000', D.ToString(false));

  D := BigDecimal.Create(Integer(1));
  CheckEquals('1', D.ToString(false));

  D := BigDecimal.Create(Integer(1), 10);
  CheckEquals('0.0000000001', D.ToString(false));

  D := BigDecimal.Create(Integer(1), -10);
  CheckEquals('10000000000', D.ToString(false));

  D := BigDecimal.Create(Integer(-550), 2);
  CheckEquals('-5.50', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Create_UInt64_Scale;
var
  D: BigDecimal;
begin
  D := BigDecimal.Create(UInt64(0));
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Create(UInt64(0), 10);
  CheckEquals('0.0000000000', D.ToString(false));

  D := BigDecimal.Create(UInt64(1));
  CheckEquals('1', D.ToString(false));

  D := BigDecimal.Create(UInt64(1), 10);
  CheckEquals('0.0000000001', D.ToString(false));

  D := BigDecimal.Create(UInt64(1), -10);
  CheckEquals('10000000000', D.ToString(false));

  D := BigDecimal.Create(UInt64(550), 2);
  CheckEquals('5.50', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Divide;
var
  X, Y, Z: BigDecimal;
begin
  X := 0;
  Y := 1;
  Z := X.Divide(Y);
  CheckEquals('0', Z.ToString);

  X := 5;
  Y := 5;
  Z := X.Divide(Y);
  CheckEquals('1', Z.ToString);

  X := 10;
  Y := 2;
  Z := X.Divide(Y);
  CheckEquals('5', Z.ToString);

  X := BigDecimal.Parse('-12.50');
  Y := 10;
  Z := X.Divide(Y);
  CheckEquals('-1.25', Z.ToString);

  { Exceptional cases }
  CheckException(EInvalidOp, procedure begin
    X := 100;
    Y := 3;
    Z := X.Divide(Y);
  end, 'Expected an EInvalidOp!');

  CheckException(EInvalidOp, procedure begin
    X := 1;
    Y := 2;
    Z := X.Divide(Y);
  end, 'Expected an EInvalidOp!');

  CheckException(EDivByZero, procedure begin
    X := 100;
    Y := 0;
    Z := X.Divide(Y);
  end, 'Expected an EDivByZero!');

  { More complex tests }
  X := -100;
  Y := 3;
  Z := X.Divide(Y, rmHalfEven);
  CheckEquals('-33', Z.ToString);

  Z := X.Divide(Y, 2, rmHalfEven);
  CheckEquals('-33.33', Z.ToString);

  Z := X.Divide(Y, 2, rmHalfUp);
  CheckEquals('-33.33', Z.ToString);

  Z := X.Divide(-Y, 1, rmHalfDown);
  CheckEquals('33.3', Z.ToString);

  Z := X.Divide(Y, 2, rmUp);
  CheckEquals('-33.34', Z.ToString);

  Z := X.Divide(Y, rmUp);
  CheckEquals('-34', Z.ToString);
end;

procedure TTestBigDecimal.Test_Explicit_From_Variant;
var
  D, F: BigDecimal;
  V: Variant;
begin
  D := BigDecimal.Parse('100');
  V := D;
  F := BigDecimal(V);
  CheckTrue(F = D);

  D := BigDecimal.Parse('5666213812379812739128731928371928378216626723123.88');
  V := D;
  F := BigDecimal(V);
  CheckTrue(F = D);

  V := 100;
  F := BigDecimal(V);
  CheckTrue(F = 100);
end;

procedure TTestBigDecimal.Test_Explicit_To_Double;
var
  D: BigDecimal;
  E: Double;
begin
  D := 100;
  E := Double(D);
  CheckTrue(SameValue(E, 100));

  D := -0.15;
  E := Double(D);
  CheckTrue(SameValue(E, -0.15));
end;

procedure TTestBigDecimal.Test_Explicit_To_Extended;
var
  D: BigDecimal;
  E: Extended;
begin
  D := 100;
  E := Extended(D);
  CheckTrue(SameValue(E, 100));

  D := -0.15;
  E := Extended(D);
  CheckTrue(SameValue(E, -0.15));
end;

procedure TTestBigDecimal.Test_GetType;
begin
  CheckTrue(BigDecimal.GetType <> nil);
  CheckTrue(BigDecimal.GetType.Family = tfReal);
  CheckTrue(BigDecimal.GetType.TypeInfo = TypeInfo(BigDecimal));
end;

procedure TTestBigDecimal.Test_Implicit_From_BigCardinal;
var
  B: BigCardinal;
  D: BigDecimal;
begin
  B := 0;
  D := B;
  CheckEquals('0', D.ToString);

  B := 100;
  D := B;
  CheckEquals('100', D.ToString);

  B := BigCardinal.Parse('378612783612873612873682613786127382163781236872136127836218736');
  D := B;
  CheckEquals('378612783612873612873682613786127382163781236872136127836218736', D.ToString);
end;

procedure TTestBigDecimal.Test_Implicit_From_BigInteger;
var
  B: BigInteger;
  D: BigDecimal;
begin
  B := 0;
  D := B;
  CheckEquals('0', D.ToString);

  B := -100;
  D := B;
  CheckEquals('-100', D.ToString);

  B := BigInteger.Parse('-378612783612873612873682613786127382163781236872136127836218736');
  D := B;
  CheckEquals('-378612783612873612873682613786127382163781236872136127836218736', D.ToString);
end;

procedure TTestBigDecimal.Test_Implicit_From_Cardinal;
var
  D: BigDecimal;
begin
  D := Cardinal(0);
  CheckEquals('0', D.ToString(false));

  D := Cardinal(1);
  CheckEquals('1', D.ToString(false));

  D := Cardinal(2221212121);
  CheckEquals('2221212121', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Implicit_From_Double;
var
  D: BigDecimal;
begin
  CheckException(EInvalidOp, procedure begin
    D := NaN;
  end, 'Expected an EInvalidOp!');

  CheckException(EInvalidOp, procedure begin
    D := Infinity;
  end, 'Expected an EInvalidOp!');

  D := 1.0;
  CheckEquals('1', D.ToString(false));

  D := 100.0;
  CheckEquals('100', D.ToString(false));

  D := -0.1;
  CheckEquals('-0.1000000000000000055511151231257827021181583404541015625', D.ToString(false));

  D := -66.11;
  CheckEquals('-66.1099999999999994315658113919198513031005859375', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Implicit_From_In64;
var
  D: BigDecimal;
begin
  D := Int64(0);
  CheckEquals('0', D.ToString(false));

  D := Int64(1);
  CheckEquals('1', D.ToString(false));

  D := Int64(-67627816222221212);
  CheckEquals('-67627816222221212', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Implicit_From_Integer;
var
  D: BigDecimal;
begin
  D := Integer(0);
  CheckEquals('0', D.ToString(false));

  D := Integer(1);
  CheckEquals('1', D.ToString(false));

  D := Integer(-222121212);
  CheckEquals('-222121212', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Implicit_From_UInt64;
var
  D: BigDecimal;
begin
  D := UInt64(0);
  CheckEquals('0', D.ToString(false));

  D := UInt64(1);
  CheckEquals('1', D.ToString(false));

  D := UInt64(67627816222221212);
  CheckEquals('67627816222221212', D.ToString(false));
end;

procedure TTestBigDecimal.Test_Implicit_To_Variant;
var
  D: BigDecimal;
  V: Variant;
begin
  D := BigDecimal.Parse('100');
  V := D;
  CheckEquals(D.ToString, string(V));

  D := BigDecimal.Parse('5666213812379812739128731928371928378216626723123.88');
  V := D;
  CheckEquals(D.ToString, string(V));

  D := 100;
  V := D;
  CheckEquals(D.ToString, string(V));

  D := BigDecimal.Parse('-3687123672835666213812379812739128731928371928378216626723123.31232312388');
  V := D;
  CheckEquals(D.ToString, string(V));
end;

procedure TTestBigDecimal.Test_IsNegative;
var
  D: BigDecimal;
begin
  CheckFalse(BigDecimal(D).IsNegative);

  CheckFalse(BigDecimal(0).IsNegative);
  CheckFalse(BigDecimal(1).IsNegative);
  CheckFalse(BigDecimal(11.22).IsNegative);
  CheckTrue(BigDecimal(-11.22).IsNegative);
  CheckFalse(BigDecimal(32673512763).IsNegative);
  CheckFalse(BigDecimal.Parse('37861238762138716238721638172387126317823').IsNegative);
  CheckTrue(BigDecimal.Parse('-37861238762138716238721638172.387126317823').IsNegative);
end;

procedure TTestBigDecimal.Test_IsPositive;
var
  D: BigDecimal;
begin
  CheckTrue(BigDecimal(D).IsPositive);

  CheckTrue(BigDecimal(0).IsPositive);
  CheckTrue(BigDecimal(1).IsPositive);
  CheckTrue(BigDecimal(11.22).IsPositive);
  CheckFalse(BigDecimal(-11.22).IsPositive);
  CheckTrue(BigDecimal(32673512763).IsPositive);
  CheckTrue(BigDecimal.Parse('37861238762138716238721638172387126317823').IsPositive);
  CheckFalse(BigDecimal.Parse('-37861238762138716238721638172.387126317823').IsPositive);
end;

procedure TTestBigDecimal.Test_IsZero;
var
  D: BigDecimal;
begin
  CheckTrue(D.IsZero);
  CheckTrue(BigDecimal.Zero.IsZero);
  CheckFalse(BigDecimal.One.IsZero);
end;

procedure TTestBigDecimal.Test_MinusOne;
begin
  CheckTrue(BigDecimal.MinusOne = -1);
end;

procedure TTestBigDecimal.Test_MinusTen;
begin
  CheckTrue(BigDecimal.MinusTen = -10);
end;

procedure TTestBigDecimal.Test_One;
begin
  CheckTrue(BigDecimal.One = 1);
end;

procedure TTestBigDecimal.Test_Op_Add;
var
  X: BigDecimal;
begin
  X := BigDecimal(0) + BigDecimal(0);
  CheckEquals('0', X.ToString(false));

  X := BigDecimal.Parse('1.00') + BigDecimal(0);
  CheckEquals('1.00', X.ToString(false));

  X := BigDecimal.Parse('1.10') + BigDecimal.Parse('0.001');
  CheckEquals('1.101', X.ToString(false));

  X := BigDecimal.Parse('-5.55') + BigDecimal.Parse('-1.11');
  CheckEquals('-6.66', X.ToString(false));

  X := BigDecimal.Parse('1.00001') + BigDecimal.Parse('-1.00');
  CheckEquals('0.00001', X.ToString(false));
end;

procedure TTestBigDecimal.Test_Op_Divide;
var
  X, Y, Z: BigDecimal;
begin
  X := 0;
  Y := 1;
  Z := X / Y;
  CheckEquals('0', Z.ToString);

  X := 5;
  Y := 5;
  Z := X / Y;
  CheckEquals('1', Z.ToString);

  X := 10;
  Y := 2;
  Z := X / Y;
  CheckEquals('5', Z.ToString);

  X := BigDecimal.Parse('-12.50');
  Y := 10;
  Z := X / Y;
  CheckEquals('-1.25', Z.ToString);

  { Exceptional cases }
  CheckException(EInvalidOp, procedure begin
    X := 100;
    Y := 3;
    Z := X / Y;
  end, 'Expected an EInvalidOp!');

  CheckException(EInvalidOp, procedure begin
    X := 1;
    Y := 2;
    Z := X / Y;
  end, 'Expected an EInvalidOp!');

  CheckException(EDivByZero, procedure begin
    X := 100;
    Y := 0;
    Z := X / Y;
  end, 'Expected an EDivByZero!');
end;

procedure TTestBigDecimal.Test_Op_Multiply;
var
  X: BigDecimal;
begin
  X := BigDecimal(0) * BigDecimal(0);
  CheckEquals('0', X.ToString(false));

  X := BigDecimal(1) * BigDecimal(0);
  CheckEquals('0', X.ToString(false));

  X := BigDecimal(1.122) * BigDecimal(0);
  CheckEquals('0', X.ToString(false));

  X := BigDecimal(0) * BigDecimal(-1111.77);
  CheckEquals('0', X.ToString(false));

  X := BigDecimal(100) * BigDecimal(10);
  CheckEquals('1000', X.ToString(false));

  X := BigDecimal.Parse('100.10') * BigDecimal(2);
  CheckEquals('200.20', X.ToString(false));

  X := BigDecimal.Parse('00.50') * BigDecimal(2);
  CheckEquals('1.00', X.ToString(false));
end;

procedure TTestBigDecimal.Test_Op_Negative;
var
  X, Y: BigDecimal;
begin
  X := 0; Y := -X;
  CheckTrue(X = Y);

  X := 10000; Y := -X;
  CheckTrue(Y = -10000);

  X := BigDecimal.Parse('-312783612783612783612321783.8821212'); Y := -X;
  CheckTrue(Y = BigDecimal.Parse('312783612783612783612321783.8821212'));

  X := BigDecimal.Parse('-3.67'); Y := -X;
  CheckTrue(Y = BigDecimal.Parse('3.67'));
end;

procedure TTestBigDecimal.Test_Op_Positive;
var
  X, Y: BigDecimal;
begin
  X := 0; Y := +X;
  CheckTrue(X = Y);

  X := 10000; Y := +X;
  CheckTrue(X = Y);

  X := BigDecimal.Parse('-312783612783612783612321783.8821212'); Y := +X;
  CheckTrue(X = Y);

  X := BigDecimal.Parse('-3.67'); Y := +X;
  CheckTrue(X = Y);
end;

procedure TTestBigDecimal.Test_Op_Subtract;
var
  X: BigDecimal;
begin
  X := BigDecimal(0) - BigDecimal(0);
  CheckEquals('0', X.ToString(false));

  X := BigDecimal.Parse('1.00') - BigDecimal(0);
  CheckEquals('1.00', X.ToString(false));

  X := BigDecimal.Parse('1.10') - BigDecimal.Parse('0.001');
  CheckEquals('1.099', X.ToString(false));

  X := BigDecimal.Parse('-5.55') - BigDecimal.Parse('-1.11');
  CheckEquals('-4.44', X.ToString(false));

  X := BigDecimal.Parse('1.00001') - BigDecimal.Parse('-1.00');
  CheckEquals('2.00001', X.ToString(false));
end;

procedure TTestBigDecimal.Test_Parse;
var
  D: BigDecimal;
begin
  D := BigDecimal.Parse('0');
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Parse('0.0');
  CheckEquals('0.0', D.ToString(false));

  D := BigDecimal.Parse(',000.000,');
  CheckEquals('0.000', D.ToString(false));

  D := BigDecimal.Parse('-0');
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Parse(' +0');
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Parse('   -99');
  CheckEquals('-99', D.ToString(false));

  D := BigDecimal.Parse('1,000.88');
  CheckEquals('1000.88', D.ToString(false));

  D := BigDecimal.Parse(',100.999,');
  CheckEquals('100.999', D.ToString(false));

  D := BigDecimal.Parse('-3652167,532,163,526,532,635,621,321,321.893,281,3928132111');
  CheckEquals('-3652167532163526532635621321321.8932813928132111', D.ToString(false));

  D := BigDecimal.Parse('1,234.5E-4');
  CheckEquals('0.12345', D.ToString());

  D := BigDecimal.Parse('0E+7');
  CheckEquals('0E+7', D.ToString());

  D := BigDecimal.Parse(',123E+6');
  CheckEquals('1.23E+8', D.ToString());

  D := BigDecimal.Parse('12.3E+7');
  CheckEquals('1.23E+8', D.ToString());

  D := BigDecimal.Parse('- 1');
  CheckEquals('-1', D.ToString(false));

  { Bad cases }
  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse(' +1. 0');
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('0.1,000');
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('10,00.000,');
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('1,23,456.789');
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('123A.99');
  end, 'Expected EConvertError!');
end;

procedure TTestBigDecimal.Test_Parse_FmtSettings;
var
  D: BigDecimal;
  L: TFormatSettings;
begin
  L.DecimalSeparator := '|';
  L.ThousandSeparator := '_';

  D := BigDecimal.Parse('0', L);
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Parse('0|0', L);
  CheckEquals('0.0', D.ToString(false));

  D := BigDecimal.Parse('_000|000_', L);
  CheckEquals('0.000', D.ToString(false));

  D := BigDecimal.Parse('-0', L);
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Parse(' +0', L);
  CheckEquals('0', D.ToString(false));

  D := BigDecimal.Parse('   -99', L);
  CheckEquals('-99', D.ToString(false));

  D := BigDecimal.Parse('1_000|88', L);
  CheckEquals('1000.88', D.ToString(false));

  D := BigDecimal.Parse('_100|999_', L);
  CheckEquals('100.999', D.ToString(false));

  D := BigDecimal.Parse('-3652167_532_163_526_532_635_621_321_321|893_281_3928132111', L);
  CheckEquals('-3652167532163526532635621321321.8932813928132111', D.ToString(false));

  D := BigDecimal.Parse('1_234|5E-4', L);
  CheckEquals('0.12345', D.ToString());

  D := BigDecimal.Parse('0E+7', L);
  CheckEquals('0E+7', D.ToString());

  D := BigDecimal.Parse('_123E+6', L);
  CheckEquals('1.23E+8', D.ToString());

  D := BigDecimal.Parse('12|3E+7', L);
  CheckEquals('1.23E+8', D.ToString());

  D := BigDecimal.Parse('- 1', L);
  CheckEquals('-1', D.ToString(false));

  { Bad cases }
  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse(' +1| 0', L);
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('0|1_000', L);
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('10_00|000,', L);
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('1_23,456|789', L);
  end, 'Expected EConvertError!');

  CheckException(EConvertError, procedure begin
    D := BigDecimal.Parse('123A.99', L);
  end, 'Expected EConvertError!');
end;

procedure TTestBigDecimal.Test_Pow;
var
  D: BigDecimal;
begin
  CheckEquals('0', D.Pow(5).ToString(false));
  CheckEquals('1', D.Pow(0).ToString(false));

  D := 3;
  CheckEquals('1', D.Pow(0).ToString(false));
  CheckEquals('3', D.Pow(1).ToString(false));
  CheckEquals('9.00', D.Pow(2, 2).ToString(false));

  D := 2;
  CheckEquals('0.5', D.Pow(-1, 1, rmHalfEven).ToString(false));
  CheckEquals('0.5', D.Pow(-1, 1, rmUp).ToString(false));
  CheckEquals('1', D.Pow(-1, 0, rmUp).ToString(false));
  CheckEquals('0.250', D.Pow(-2, 3, rmDown).ToString(false));
end;

procedure TTestBigDecimal.Test_Precision;
var
  D: BigDecimal;
begin
  CheckEquals(1, BigDecimal(D).Precision);

  CheckEquals(2, BigDecimal.Create(10, 0).Precision);
  CheckEquals(2, BigDecimal.Create(10, 1).Precision);
  CheckEquals(3, BigDecimal.Create(100).Precision);
  CheckEquals(55, BigDecimal.Create(-0.1).Precision);
  CheckEquals(48, BigDecimal.Create(-66.11).Precision);
end;

procedure TTestBigDecimal.Test_Rescale;
var
  LDec: BigDecimal;
begin
  { Normal rescaling }
  LDec := BigDecimal.Parse('100').Rescale(0);
  CheckEquals('100', LDec.ToString(false));

  LDec := BigDecimal.Parse('100.20').Rescale(1);
  CheckEquals('100.2', LDec.ToString(false));

  LDec := BigDecimal.Parse('-1.99').Rescale(3);
  CheckEquals('-1.990', LDec.ToString(false));

  LDec := BigDecimal.Parse('0').Rescale(3);
  CheckEquals(3, LDec.Scale);
  CheckEquals('0.000', LDec.ToString(false));

  { Check for rounding error }
  CheckException(EInvalidOp, procedure begin
    LDec := BigDecimal.Parse('-1.99').Rescale(1);
  end, 'Expected an exception!');

  CheckException(EInvalidOp, procedure begin
    LDec := BigDecimal.Parse('-1.1').Rescale(0);
  end, 'Expected an exception!');

  CheckException(EInvalidOp, procedure begin
    LDec := BigDecimal.Parse('0.1').Rescale(0);
  end, 'Expected an exception!');

  { Rescaling with rounding }
  LDec := BigDecimal.Parse('100.1').Rescale(0, rmUp);
  CheckEquals('101', LDec.ToString(false));

  LDec := BigDecimal.Parse('100.29').Rescale(1, rmDown);
  CheckEquals('100.2', LDec.ToString(false));

  LDec := BigDecimal.Parse('-1.99').Rescale(3, rmUp { not used } );
  CheckEquals('-1.990', LDec.ToString(false));

  LDec := BigDecimal.Parse('0.000000000012').Rescale(1, rmCeiling);
  CheckEquals('0.1', LDec.ToString(false));
end;

procedure TTestBigDecimal.Test_Round;
var
  X, R: BigDecimal;
begin
  X := BigDecimal.Parse('12345');
  R := X.Round(2);
  CheckEquals('12000', R.ToString(false));

  X := BigDecimal.Parse('12.23');
  R := X.Round(4);
  CheckEquals('12.23', R.ToString(false));

  X := BigDecimal.Parse('12.23');
  R := X.Round(5);
  CheckEquals('12.23', R.ToString(false));

  X := BigDecimal.Parse('-12.23');
  R := X.Round(3);
  CheckEquals('-12.2', R.ToString(false));

  X := BigDecimal.Parse('-12.23');
  R := X.Round(3, rmUp);
  CheckEquals('-12.3', R.ToString(false));

  CheckException(Exception, procedure begin
    X := BigDecimal.Parse('-12.23');
    R := X.Round(3, rmNone);
  end,
  'Expected an exception!');
end;

procedure TTestBigDecimal.Test_Scale;
var
  D: BigDecimal;
begin
  CheckEquals(0, BigDecimal(D).Scale);

  CheckEquals(0, BigDecimal.Create(10, 0).Scale);
  CheckEquals(1, BigDecimal.Create(10, 1).Scale);
  CheckEquals(0, BigDecimal.Create(100).Scale);
  CheckEquals(55, BigDecimal.Create(-0.1).Scale);
  CheckEquals(-5, BigDecimal.Create(1, -5).Scale);
end;

procedure TTestBigDecimal.Test_ScaleByPowerOfTen;
var
  X: BigDecimal;
begin
  X := X.ScaleByPowerOfTen(1);
  CheckEquals('00', X.ToString(false));

  X := X.ScaleByPowerOfTen(5);
  CheckEquals('000000', X.ToString(false));

  X := 2;
  X := X.ScaleByPowerOfTen(2);
  CheckEquals('200', X.ToString(false));

  X := X.ScaleByPowerOfTen(-4);
  CheckEquals('0.02', X.ToString(false));

  X := X.ScaleByPowerOfTen(-1);
  CheckEquals('0.002', X.ToString(false));
end;

procedure TTestBigDecimal.Test_Sign;
var
  X: BigDecimal;
begin
  CheckEquals(0, X.Sign);
  CheckEquals(0, BigDecimal.Zero.Sign);
  CheckEquals(1, BigDecimal.One.Sign);
  CheckEquals(1, BigDecimal.Ten.Sign);
  CheckEquals(-1, BigDecimal.MinusOne.Sign);
  CheckEquals(-1, BigDecimal.MinusTen.Sign);
end;

procedure TTestBigDecimal.Test_Ten;
begin
  CheckTrue(BigDecimal.Ten = 10);
end;

procedure TTestBigDecimal.Test_ToBigInteger;
var
  LInt: BigInteger;
begin
  LInt := BigDecimal.Parse('100.99').Truncate;
  CheckEquals('100', LInt.ToString);

  LInt := BigDecimal.Parse('-0.01').Truncate;
  CheckEquals('0', LInt.ToString);

  LInt := BigDecimal.Parse('-199.99999999').Truncate;
  CheckEquals('-199', LInt.ToString);

  LInt := BigDecimal.Parse('-32132132132139999882223232111113232.32132132132139999882223232111113232').Truncate;
  CheckEquals('-32132132132139999882223232111113232', LInt.ToString);
end;

procedure TTestBigDecimal.Test_ToDouble;
var
  D: BigDecimal;
  E: Double;
begin
  D := 100;
  E := D.ToDouble;
  CheckTrue(SameValue(E, 100));

  D := -0.15;
  E := D.ToDouble;
  CheckTrue(SameValue(E, -0.15));
end;

procedure TTestBigDecimal.Test_ToString;
var
  S: string;
begin
  { non-E notation }
  S := '-1';
  CheckEquals(S, BigDecimal.Parse(S).ToString(false));

  S := '-100.10';
  CheckEquals(S, BigDecimal.Parse(S).ToString(false));

  S := '38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S).ToString(false));

  S := '-0.38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S).ToString(false));

  S := '1111111111111111111111111111111111111111111111111111111111111111111111111.88';
  CheckEquals(S, BigDecimal.Parse(S).ToString(false));

  { E notation }
  S := '-1';
  CheckEquals(S, BigDecimal.Parse(S).ToString());

  S := '-100.10';
  CheckEquals(S, BigDecimal.Parse(S).ToString());

  S := '38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S).ToString());

  S := '-0.38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S).ToString());

  S := '1111111111111111111111111111111111111111111111111111111111111111111111111.88';
  CheckEquals(S, BigDecimal.Parse(S).ToString());

  S := '12345';
  CheckEquals('1.2E+4', BigDecimal.Parse(S).Round(2).ToString());
  CheckEquals('1E+1', BigDecimal.Create(1, -1).ToString());
  CheckEquals('1.2E+6', BigDecimal.Create(12, -5).ToString());
  CheckEquals('0E+5', BigDecimal.Create(0, -5).ToString());
end;

procedure TTestBigDecimal.Test_ToString_FmtSettings;
var
  S: string;
  L: TFormatSettings;
begin
  { non-E notation }
  S := '-1';
  L.DecimalSeparator := '|';

  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L, false));

  S := '-100|10';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L, false));

  S := '38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L, false));

  S := '-0|38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L, false));

  S := '1111111111111111111111111111111111111111111111111111111111111111111111111|88';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L, false));

  { E notation }
  S := '-1';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L));

  S := '-100|10';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L));

  S := '38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L));

  S := '-0|38172636578125376123523217635127635213762';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L));

  S := '1111111111111111111111111111111111111111111111111111111111111111111111111|88';
  CheckEquals(S, BigDecimal.Parse(S, L).ToString(L));

  S := '12345';
  CheckEquals('1|2E+4', BigDecimal.Parse(S, L).Round(2).ToString(L));
  CheckEquals('1E+1', BigDecimal.Create(1, -1).ToString(L));
  CheckEquals('1|2E+6', BigDecimal.Create(12, -5).ToString(L));
  CheckEquals('0E+5', BigDecimal.Create(0, -5).ToString(L));
end;

procedure TTestBigDecimal.Test_TryParse;
var
  D: BigDecimal;
begin
  CheckTrue(BigDecimal.TryParse('0', D));
  CheckEquals('0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('0.0', D));
  CheckEquals('0.0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse(',000.000,', D));
  CheckEquals('0.000', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('-0', D));
  CheckEquals('0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse(' +0', D));
  CheckEquals('0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('   -99', D));
  CheckEquals('-99', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('1,000.88', D));
  CheckEquals('1000.88', D.ToString(false));

  CheckTrue(BigDecimal.TryParse(',100.999,', D));
  CheckEquals('100.999', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('-3652167,532,163,526,532,635,621,321,321.893,281,3928132111', D));
  CheckEquals('-3652167532163526532635621321321.8932813928132111', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('1,234.5E-4', D));
  CheckEquals('0.12345', D.ToString());

  CheckTrue(BigDecimal.TryParse('0E+7', D));
  CheckEquals('0E+7', D.ToString());

  CheckTrue(BigDecimal.TryParse(',123E+6', D));
  CheckEquals('1.23E+8', D.ToString());

  CheckTrue(BigDecimal.TryParse('12.3E+7', D));
  CheckEquals('1.23E+8', D.ToString());

  CheckTrue(BigDecimal.TryParse('- 1', D));
  CheckEquals('-1', D.ToString());

  { Bad cases }
  CheckFalse(BigDecimal.TryParse(' +1. 0', D));
  CheckFalse(BigDecimal.TryParse('0.1,000', D));
  CheckFalse(BigDecimal.TryParse('10,00.000,', D));
  CheckFalse(BigDecimal.TryParse('1,23,456.789', D));
  CheckFalse(BigDecimal.TryParse('123A.99', D));
end;

procedure TTestBigDecimal.Test_TryParse_FmtSettings;
var
  D: BigDecimal;
  L: TFormatSettings;
begin
  L.DecimalSeparator := '|';
  L.ThousandSeparator := '_';

  CheckTrue(BigDecimal.TryParse('0', D, L));
  CheckEquals('0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('0|0', D, L));
  CheckEquals('0.0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('_000|000_', D, L));
  CheckEquals('0.000', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('-0', D, L));
  CheckEquals('0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse(' +0', D, L));
  CheckEquals('0', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('   -99', D, L));
  CheckEquals('-99', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('1_000|88', D, L));
  CheckEquals('1000.88', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('_100|999_', D, L));
  CheckEquals('100.999', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('-3652167_532_163_526_532_635_621_321_321|893_281_3928132111', D, L));
  CheckEquals('-3652167532163526532635621321321.8932813928132111', D.ToString(false));

  CheckTrue(BigDecimal.TryParse('1_234|5E-4', D, L));
  CheckEquals('0.12345', D.ToString());

  CheckTrue(BigDecimal.TryParse('0E+7', D, L));
  CheckEquals('0E+7', D.ToString());

  CheckTrue(BigDecimal.TryParse('_123E+6', D, L));
  CheckEquals('1.23E+8', D.ToString());

  CheckTrue(BigDecimal.TryParse('12|3E+7', D, L));
  CheckEquals('1.23E+8', D.ToString());

  CheckTrue(BigDecimal.TryParse('- 1', D, L));
  CheckEquals('-1', D.ToString(false));

  { Bad cases }
  CheckFalse(BigDecimal.TryParse(' +1| 0', D, L));
  CheckFalse(BigDecimal.TryParse('0|1_000', D, L));
  CheckFalse(BigDecimal.TryParse('10_00|000,', D, L));
  CheckFalse(BigDecimal.TryParse('1_23,456|789', D, L));
  CheckFalse(BigDecimal.TryParse('123A.99', D, L));
end;

procedure TTestBigDecimal.Test_Type;
var
  Support: IType<BigDecimal>;
  X, Y: BigDecimal;
begin
  Support := TType<BigDecimal>.Default;

  X := BigDecimal.Parse('397129037219837128937128937128.93718927389217312321893712986487234623785');
  Y := BigDecimal.Parse('297129037219837128937128937128.93718927389217312321893712986487234623785');

  { Test stuff }
  Check(Support.Compare(X, X) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(X, Y) > 0, 'Expected Support.Compare(X, Y) > 0 to be true!');
  Check(Support.Compare(Y, X) < 0, 'Expected Support.Compare(Y, X) < 0 to be true!');

  Check(Support.AreEqual(X, X), 'Expected Support.AreEqual(X, X) to be true!');
  Check(Support.AreEqual(Y, Y), 'Expected Support.AreEqual(Y, Y) to be true!');
  Check(not Support.AreEqual(X, Y), 'Expected Support.AreEqual(X, Y) to be false!');

  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X) to be stable!');
  Check(Support.GenerateHashCode(Y) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(Y) to be stable!');
  Check(Support.GenerateHashCode(Y) <> Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X/Y) to be different!');

  Check(Support.GetString(X) = '397129037219837128937128937128.93718927389217312321893712986487234623785', 'Expected Support.GetString(X)');
  Check(Support.GetString(Y) = '297129037219837128937128937128.93718927389217312321893712986487234623785', 'Expected Support.GetString(Y)');

  Check(Support.Name = 'BigDecimal', 'Type Name = "BigDecimal"');
  Check(Support.Size = SizeOf(BigDecimal), 'Type Size = SizeOf(BigDecimal)');
  Check(Support.TypeInfo = TypeInfo(BigDecimal), 'Type information provider failed!');
  Check(Support.Family = tfReal, 'Type Family = tfReal');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');
end;

procedure TTestBigDecimal.Test_VariantSupport;
var
  X, Y: Variant;
  M: Integer;
begin
  { Check conversions }
  X := BigDecimal.Parse('397129037219837128937128937128937189273892173123218937129864872346237.85');
  Y := BigDecimal(100);

  Check(X = '397129037219837128937128937128937189273892173123218937129864872346237.85', 'Variant value expected to be "397129037219837128937128937128937189273892173123218937129864872346237.85"');
  Check(Y = 100, 'Variant value expected to be "100"');

  { Check opeartors a bit }
  X := X + Y;
  Check(X = '397129037219837128937128937128937189273892173123218937129864872346337.85', 'Variant value expected to be "397129037219837128937128937128937189273892173123218937129864872346337.85"');

  X := X - Y;
  Check(X = '397129037219837128937128937128937189273892173123218937129864872346237.85', 'Variant value expected to be "397129037219837128937128937128937189273892173123218937129864872346237.85"');

  X := BigDecimal(100);
  Y := X / 3;
  CheckEquals('33', string(Y), 'Variant value expected to be "34"');

  X := BigDecimal(100);
  Y := X * 3;
  CheckEquals('300', string(Y), 'Variant value expected to be "300"');

  X := BigDecimal(78);

  CheckException(Exception, procedure begin
    Y := X div 4;
  end,
  'Expected an exception!');

  M := X;
  CheckEquals('78', IntToStr(M), 'M''s value expected to be "78"');

  VarClear(X);
  Check(X = 0, 'Variant value expected to be "0"');

  X := BigDecimal(100);
  Y := BigDecimal(200);

  Check(X < Y, 'X Expected to be less than Y');
  Check(Y > X, 'Y Expected to be greater than X');
  Check(Y >= X, 'Y Expected to be greater or equal than X');
  Check(X <= Y, 'X Expected to be less or equal than Y');
end;

procedure TTestBigDecimal.Test_VarType;
var
  L: Variant;
begin
  L := BigDecimal(10);
  CheckEquals(VarType(L), BigDecimal.VarType);
end;

procedure TTestBigDecimal.Test_Zero;
begin
  CheckTrue(BigDecimal.Zero = 0);
end;

initialization
  TestFramework.RegisterTest(TTestBigDecimal.Suite);

end.
