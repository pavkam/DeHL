(*
* Copyright (c) 2008-2010, Ciobanu Alexandru
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
unit Tests.BigCardinal;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Math.BigCardinal;

type
  TTestBigCardinal = class(TDeHLTestCase)
  private
    procedure TestAllCompOperators(const X, Y: BigCardinal; const IsStrict: Boolean);

  published
    procedure TestCreateAndToXXX();
    procedure TestIntToStrAndBack();
    procedure TestIntToStrAndTryBack();
    procedure TestHexToStrAndBack();
    procedure TestHexToStrAndTryBack();
    procedure TestIntToStrHexAndBack();
    procedure TestIntToStrHexAndTryBack();
    procedure TestCompOps();
    procedure TestArithmOps();
    procedure TestBitOps();
    procedure TestImplicits();
    procedure TestExplicits();
    procedure TestBigPow2();
    procedure TestDiv2ShrEq();
    procedure TestMul2ShlEq();
    procedure TestExceptions();
    procedure TestArithmOverflows();
    procedure TestStatNums();
    procedure TestIsProps();
    procedure TestPow();
    procedure TestDivMod();
    procedure TestGetType();
    procedure TestType();
    procedure TestVariantSupport();

    procedure Test_Bug_0();
  end;


implementation

procedure TTestBigCardinal.TestAllCompOperators(const X, Y: BigCardinal; const IsStrict: Boolean);
var
  AErr: String;
begin
  AErr := ' (X = "' + X.ToString + '"; Y = "' + X.ToString + '")';

  Check(X = X, 'Expected X = X' + AErr);
  Check(Y = Y, 'Expected Y = Y' + AErr);

  Check(X.CompareTo(X) = 0, 'Expected X.CompareTo(X) = 0' + AErr);
  Check(Y.CompareTo(Y) = 0, 'Expected Y.CompareTo(Y) = 0' + AErr);

  Check(X >= X, 'Expected X >= X' + AErr);
  Check(X <= X, 'Expected X <= X' + AErr);

  Check(Y >= Y, 'Expected Y >= Y' + AErr);
  Check(Y <= Y, 'Expected Y <= Y' + AErr);

  Check(not (X > X), 'Expected not (X > X)' + AErr);
  Check(not (X < X), 'Expected not (X < X)' + AErr);
  Check(not (Y > Y), 'Expected not (Y > Y)' + AErr);
  Check(not (Y < Y), 'Expected not (Y > Y)' + AErr);

  Check(X >= Y, 'Expected X >= Y' + AErr);
  Check(Y <= X, 'Expected Y <= X' + AErr);

  if not IsStrict then
  begin
    Check(X > Y, 'Expected X > Y' + AErr);
    Check(Y < X, 'Expected Y < X' + AErr);

    Check(X.CompareTo(Y) > 0, 'Expected X.CompareTo(Y) > 0' + AErr);
    Check(Y.CompareTo(X) < 0, 'Expected Y.CompareTo(X) < 0' + AErr);

    Check(X <> Y, 'Expected X <> Y' + AErr);
    Check(Y <> X, 'Expected Y <> X' + AErr);

    Check(not (Y = X), 'Expected not (Y = X)' + AErr);
    Check(not (X = Y), 'Expected not (X = Y)' + AErr);
  end else
  begin
    Check(X.CompareTo(Y) = 0, 'Expected X.CompareTo(Y) = 0' + AErr);
    Check(y.CompareTo(X) = 0, 'Expected Y.CompareTo(X) = 0' + AErr);

    Check(not (X > Y), 'Expected not (X > Y)' + AErr);
    Check(not (Y > X), 'Expected not (Y > X)' + AErr);

    Check(not (X < Y), 'Expected not (X > Y)' + AErr);
    Check(not (Y < X), 'Expected not (Y > X)' + AErr);

    Check(Y = X, 'Expected Y = X' + AErr);
    Check(X = Y, 'Expected X = Y' + AErr);

    Check(not (Y <> X), 'Expected not (Y <> X)' + AErr);
    Check(not (X <> Y), 'Expected not (X <> Y)' + AErr);
  end
end;

procedure TTestBigCardinal.TestArithmOps;
var
  X, Y, Z: BigCardinal;
begin
  X := BigCardinal.Parse('742038403297403256248056320847328947309842374092374392743974023904732904');

  { Subtraction 1 }
  Z := X - 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732903', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732903"');

  { Addition 1 }
  Z := X + 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732905', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732905"');

  { Multiplication 1 }
  Z := X * 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Division 1 }
  Z := X div 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Modulo 1 }
  Z := X mod 1;
  Check(Z.ToString = '0', 'Expected Z = "0"');

  { ---------------------------------------------------- }

  X := BigCardinal.Parse('34662493847238423894629524590275259020753492304930000947329473482347387474');

  { Subtraction 0 }
  Z := X - 0;
  Check(Z.ToString = '34662493847238423894629524590275259020753492304930000947329473482347387474', 'Expected Z = "34662493847238423894629524590275259020753492304930000947329473482347387474"');

  { Addition 0 }
  Z := X + 0;
  Check(Z.ToString = '34662493847238423894629524590275259020753492304930000947329473482347387474', 'Expected Z = "34662493847238423894629524590275259020753492304930000947329473482347387474"');

  { Multiplication 0 }
  Z := X * 0;
  Check(Z.ToString = '0', 'Expected Z = "0"');

  { ---------------------------------------------------- }

  X := BigCardinal.Parse('12222222220000000000000000000000000000000000000000000000000000');
  Y := BigCardinal.Parse('2222222220000000000000000000000000000000000000000000000000000');

  { Subtraction x }
  Z := X - Y;
  Check(Z.ToString = '10000000000000000000000000000000000000000000000000000000000000', 'Expected Z = "10000000000000000000000000000000000000000000000000000000000000"');

  { Addition x }
  Z := X + Y;
  Check(Z.ToString = '14444444440000000000000000000000000000000000000000000000000000', 'Expected Z = "14444444440000000000000000000000000000000000000000000000000000"');

  { Multiplication 400 }
  Z := X * 400;
  Check(Z.ToString = '4888888888000000000000000000000000000000000000000000000000000000', 'Expected Z = "4888888888000000000000000000000000000000000000000000000000000000"');

  { Division 100000 }
  Z := X div 100000;
  Check(Z.ToString = '122222222200000000000000000000000000000000000000000000000', 'Expected Z = "122222222200000000000000000000000000000000000000000000000"');

  { Division 200 }
  Z := X div 200;
  Check(Z.ToString = '61111111100000000000000000000000000000000000000000000000000', 'Expected Z = "61111111100000000000000000000000000000000000000000000000000"');

  { --------------------------------- SOME BASICS --------------- }
  X := 10;
  Y := 10;

  Check(X - Y = 0, 'X - Y expected to be 0');
  Check(X + Y = 20, 'X + Y expected to be 20');
  Check(X * Y = 100, 'X * Y expected to be 100');
  Check(X div Y = 1, 'X div Y expected to be 1');
  Check(X mod Y = 0, 'X mod Y expected to be 0');

  { Some other stuff }
  X := 10;
  X := +X;
  Check(X = 10, 'X was expected to be 10');


  X := BigCardinal.Parse('734832789423798427394625642736436434634623452367438527598465298562398423');
  Check(X = +X, 'X was expected to be equal to +X');

  { Check Inc, Dec }
  X := BigCardinal.Parse('734832789423798427394625642736436434634623452367438527598465298562398423');

  Inc(X);
  Check(X = BigCardinal.Parse('734832789423798427394625642736436434634623452367438527598465298562398424'), 'X was expected to be equal to "734832789423798427394625642736436434634623452367438527598465298562398424"');

  Dec(X);
  Check(X = BigCardinal.Parse('734832789423798427394625642736436434634623452367438527598465298562398423'), 'X was expected to be equal to "734832789423798427394625642736436434634623452367438527598465298562398423"');

  X := 100;

  Inc(X, 100);
  Check(X = 200, 'X was expected to be 200');

  Dec(X, 50);
  Check(X = 150, 'X was expected to be 150');
end;

procedure TTestBigCardinal.TestArithmOverflows;
var
  X: BigCardinal;
begin
  {$IFOPT Q+}
  { Do nothing if Q+ is present }
  Check(true, '');
  Exit;
  {$ENDIF}

  { Subtraction }
  X := 1;
  X := X - 2;

  Check(X = $FFFFFFFF, 'Expected X = $FFFFFFFF');

  X := 1;
  X := X - 3;
  Check(X = $FFFFFFFE, 'Expected X = $FFFFFFFE');

  X := BigCardinal.Parse('1000000000000000000000000000000000000000000000000000000000000000000000');
  X := X - X;
  Check(X = 0, 'Expected X = 0');

  X := BigCardinal.Parse('$FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  X := X - BigCardinal.Parse('$100000000000000000000000000000000');
  Check(X.ToHexString = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', 'Expected X = FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');

  { Dec }
  X := 0;
  Dec(X);
  Check(X = $FFFFFFFF, 'X expected to be FFFFFFFF');

  X := 1;
  Dec(X, 2);
  Check(X = $FFFFFFFF, 'X expected to be FFFFFFFF');

  { Negative }
  X := 1;
  X := -X;
  Check(X = $FFFFFFFF, 'X was expected to be $FFFFFFFF');

  X := $FFFFFFFFFFFFFFFF;
  X := -X;
  Check(X = 1, 'X was expected to be 1');
end;

procedure TTestBigCardinal.TestBigPow2;
const
 Iters = 500;

var
  X: BigCardinal;
  I: Integer;
begin
  { Let's calculate the a power of 2 }
  X := 2;

  { multiply by 2 on each iteration}
  for I := 0 to Iters - 1 do
    X := X * 2;

  { Divide by 4 this time twice as fast }
  for I := 0 to (Iters div 2) - 1 do
    X := X div 4;

  Check(X = 2, 'X is supposed to be 2');
end;

procedure TTestBigCardinal.TestBitOps;
var
  X, Y: BigCardinal;
begin
  { SHR }
  X := BigCardinal.ParseHex('112233445566778899AABBCCDDEEFF');

  Y := X shr 0;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF', 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X shr 8;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEE', 'Expected Y = "112233445566778899AABBCCDDEE"');

  Y := X shr 12;
  Check(Y.ToHexString = '112233445566778899AABBCCDDE', 'Expected Y = "112233445566778899AABBCCDDE"');

  X := BigCardinal.ParseHex('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  Y := X shr 1;
  Check(Y.ToHexString = '7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', 'Expected Y = "7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"');

  {SHL}
  X := BigCardinal.ParseHex('112233445566778899AABBCCDDEEFF');

  Y := X shl 0;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF', 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X shl 8;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF00', 'Expected Y = "112233445566778899AABBCCDDEEFF00"');

  Y := X shl 12;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF000', 'Expected Y = "112233445566778899AABBCCDDEEFF000"');

  X := BigCardinal.ParseHex('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  Y := X shl 1;
  Check(Y.ToHexString = '1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE', 'Expected Y = "1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE"');

  {XOR}
  X := BigCardinal.ParseHex('112233445566778899AABBCCDDEEFF');
  Y := X xor X;
  Check(Y = 0, 'Expected Y = "0"');

  Y := X xor 0;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF', 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X xor 1;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFE', 'Expected Y = "112233445566778899AABBCCDDEEFE"');

  Y := X xor BigCardinal.ParseHex('002233445566778899AABBCCDDEE00');
  Check(Y.ToHexString = '1100000000000000000000000000FF', 'Expected Y = "1100000000000000000000000000FF"');

  {OR}
  Y := X or X;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF', 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X or 0;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF', 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X or 1;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF', 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X or BigCardinal.ParseHex('FFFF0000000000000000000000FFFF');
  Check(Y.ToHexString = 'FFFF33445566778899AABBCCDDFFFF', 'Expected Y = "FFFF33445566778899AABBCCDDFFFF"');

  {AND}
  Y := X and X;
  Check(Y.ToHexString = '112233445566778899AABBCCDDEEFF', 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X and 0;
  Check(Y.ToHexString = '0', 'Expected Y = "0"');

  Y := X and 1;
  Check(Y.ToHexString = '1', 'Expected Y = "1"');

  Y := X and BigCardinal.ParseHex('FFFF0000000000000000000000FFFF');
  Check(Y.ToHexString = '11220000000000000000000000EEFF', 'Expected Y = "11220000000000000000000000EEFF"');

  {NOT}
  X := BigCardinal.ParseHex('11111111111111111111111111111111');
  Y := not X;
  Check(Y.ToHexString = 'EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE', 'Expected Y = "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"');

  X := BigCardinal.ParseHex('0');
  Y := not X;
  Check(Y.ToHexString = 'FFFFFFFF', 'Expected Y = "FFFFFFFF"');

  X := BigCardinal.ParseHex('FFFFFFFF');
  Y := not X;
  Check(Y.ToHexString = '0', 'Expected Y = "0"');
end;

procedure TTestBigCardinal.TestCompOps;
var
  X, Y, Z, W: BigCardinal;
begin
  TestAllCompOperators(X, 0, true);
  TestAllCompOperators(0, Y, true);
  TestAllCompOperators(Z, W, true);

  TestAllCompOperators(0, 0, true);
  TestAllCompOperators(1, 0, false);

  TestAllCompOperators(2000000, 100, false);
  TestAllCompOperators($FFFFFFFF, $FFFFFFFF, true);

  TestAllCompOperators(
    BigCardinal.Parse('33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    BigCardinal.Parse('33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    true);

  TestAllCompOperators(
    BigCardinal.Parse('44821903821093821309839210382091833123213213382130928301293821903821309231029382039489'),
    BigCardinal.Parse('33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    false);

  TestAllCompOperators(
    BigCardinal.Parse('44821903821093821309839210382091833123213213382130928301293821903821309231029382039489'),
    BigCardinal.Parse('0900940923605360892376489562085658065662000286864823086460236515430846'),
    false);
end;

procedure TTestBigCardinal.TestCreateAndToXXX;
var
  X, Y: BigCardinal;
begin

  { Check un-initialied }
  Check(X.ToByte() = 0, 'ToByte() expected to be 0');
  Check(X.ToWord() = 0, 'ToWord() expected to be 0');
  Check(X.ToCardinal() = 0, 'ToCardinal() expected to be 0');
  Check(X.ToUInt64() = 0, 'ToUInt64() expected to be 0');
  Check(X.ToShortInt() = 0, 'ToShortInt() expected to be 0');
  Check(X.ToSmallInt() = 0, 'ToSmallInt() expected to be 0');
  Check(X.ToInteger() = 0, 'ToInteger() expected to be 0');
  Check(X.ToInt64() = 0, 'ToInt64() expected to be 0');


  { Test initial value }
  X := X * 2;
  Check(X = 0, '(*) X must be zero by default!');

  { Create from Cardinal }
  X := BigCardinal.Create(Cardinal($FFEEBBAA));

  Check(X.ToByte() = $AA, 'ToByte() expected to be $AA');
  Check(X.ToWord() = $BBAA, 'ToWord() expected to be $BBAA');
  Check(X.ToCardinal() = $FFEEBBAA, 'ToCardinal() expected to be $FFEEBBAA');
  Check(X.ToUInt64() = $FFEEBBAA, 'ToUInt64() expected to be $FFEEBBAA');

  { Create from UInt64 }
  X := BigCardinal.Create($11223344FFEEBBAA);

  Check(X.ToByte() = $AA, 'ToByte() expected to be $AA');
  Check(X.ToWord() = $BBAA, 'ToWord() expected to be $BBAA');
  Check(X.ToCardinal() = $FFEEBBAA, 'ToCardinal() expected to be $FFEEBBAA');
  Check(X.ToUInt64() = $11223344FFEEBBAA, 'ToUInt64() expected to be $11223344FFEEBBAA');

  { Create from another BigInt }
  Y := BigCardinal.Create(X);

  Check(X.ToByte() = $AA, 'ToByte() expected to be $AA');
  Check(X.ToWord() = $BBAA, 'ToWord() expected to be $BBAA');
  Check(X.ToCardinal() = $FFEEBBAA, 'ToCardinal() expected to be $FFEEBBAA');
  Check(X.ToUInt64() = $11223344FFEEBBAA, 'ToUInt64() expected to be $11223344FFEEBBAA');

  { Let's raise the size of the Y }
  Y := Y * $100;

  Check(Y.ToByte() = $00, 'ToByte() expected to be $00');
  Check(Y.ToWord() = $AA00, 'ToWord() expected to be $AA00');
  Check(Y.ToCardinal() = $EEBBAA00, 'ToCardinal() expected to be $EEBBAA00');

  Check(Y.ToUInt64() = $223344FFEEBBAA00, 'ToUInt64() expected to be $223344FFEEBBAA00');

  { Other tests }
  X := BigCardinal.Parse('894378473298473984723984732984732984374938473928473842379483263745164725372');
  Y := BigCardinal.Create(X);

  Check(X.ToUInt64() = Y.ToUInt64, 'X.ToUInt64() expected to be equal to Y.ToUInt64()');


  X := BigCardinal.ParseHex('AABBCCDDEEFFAABBCCDDEEFF00112233445566778899');

  { Lets test to chars }
  Check(X.ToAnsiChar() = #$99, 'X.ToAnsiChar() expected to be #$99');
  Check(X.ToWideChar() = #$8899, 'X.ToWideChar() expected to be #$8899');

  { Lets check int types }
  Check(X.ToShortInt() = -103, 'X.ToShortInt() expected to be -103');
  Check(X.ToSmallInt() = -30567, 'X.ToSmallInt() expected to be -30567');
  Check(X.ToInteger() = $66778899, 'X.ToInteger() expected to be $66778899');
  Check(X.ToInt64() = $2233445566778899, 'X.ToInt64() expected to be $2233445566778899');

  { Test create and To from Ints }
  X := BigCardinal.Create(Int64(-2200));
  Check(X.ToInt64() = -2200, 'X.ToInt64() is expected to be -2200');

  X := BigCardinal.Create(Integer(-88088));
  Check(X.ToInteger() = -88088, 'X.ToInteger() is expected to be -88088');

  X := BigCardinal.Create(SmallInt(-8808));
  Check(X.ToSmallInt() = -8808, 'X.ToSmallInt() is expected to be -8808');

  X := BigCardinal.Create(ShortInt(-88));
  Check(X.ToShortInt() = -88, 'X.ToShortInt() is expected to be -88');
end;

procedure TTestBigCardinal.TestDiv2ShrEq;
const
  Iter = 500;
var
  X, Y: BigCardinal;
  I: Integer;
begin
  X := 1;

  { Generate a very big number }
  for I := 1 to Iter - 1 do
    X := X * I;

  { Copy }
  Y := X;

  while (X > 0) and (Y > 0) do
  begin
    X := X div 2;
    Y := Y shr 1;

    Check(X = Y, 'X is supposed to be equal to Y in shl/div combo');
  end;

end;

procedure TTestBigCardinal.TestDivMod;
var
  X, Y, R: BigCardinal;
begin
  X := BigCardinal(12345) * BigCardinal(778881) + BigCardinal(123);

  Y := X.DivMod(778881, R);
  CheckTrue(Y = 12345);
  CheckTrue(R = 123);

  Y := X.DivMod(12345, R);
  CheckTrue(Y = 778881);
  CheckTrue(R = 123);

  X := X - BigCardinal(123);

  Y := X.DivMod(778881, R);
  CheckTrue(Y = 12345);
  CheckTrue(R = 0);

  Y := X.DivMod(12345, R);
  CheckTrue(Y = 778881);
  CheckTrue(R = 0);
end;

procedure TTestBigCardinal.TestExceptions;
{$IFOPT Q+}
var
  B: BigCardinal;
{$ENDIF}
begin
  { Str to Int }
  CheckException(EConvertError, procedure begin
    BigCardinal.Parse('');
  end, 'EConvertError not thrown in BigCardinal.Parse');

  CheckException(EConvertError, procedure begin
    BigCardinal.Parse(' ');
  end, 'EConvertError not thrown in BigCardinal.Parse');

  CheckException(EConvertError, procedure begin
    BigCardinal.Parse('22 ');
  end, 'EConvertError not thrown in BigCardinal.Parse');

  CheckException(EConvertError, procedure begin
    BigCardinal.Parse('x');
  end, 'EConvertError not thrown in BigCardinal.Parse');

  CheckException(EConvertError, procedure begin
    BigCardinal.Parse('-8940823098423');
  end, 'EConvertError not thrown in BigCardinal.Parse');

  CheckException(EConvertError, procedure begin
    BigCardinal.Parse('788 78788');
  end, 'EConvertError not thrown in BigCardinal.Parse');

  { Hex to Int }
  CheckException(EConvertError, procedure begin
    BigCardinal.ParseHex('');
  end, 'EConvertError not thrown in BigCardinal.ParseHex');

  CheckException(EConvertError, procedure begin
    BigCardinal.ParseHex(' ');
  end, 'EConvertError not thrown in BigCardinal.ParseHex');

  CheckException(EConvertError, procedure begin
    BigCardinal.ParseHex('22 ');
  end, 'EConvertError not thrown in BigCardinal.ParseHex');

  CheckException(EConvertError, procedure begin
    BigCardinal.ParseHex('x');
  end, 'EConvertError not thrown in BigCardinal.ParseHex');

  CheckException(EConvertError, procedure begin
    BigCardinal.ParseHex('-ABC32345');
  end, 'EConvertError not thrown in BigCardinal.ParseHex');

  CheckException(EConvertError, procedure begin
    BigCardinal.ParseHex('AAA 55');
  end, 'EConvertError not thrown in BigCardinal.ParseHex');

  {$IFOPT Q+}
  { Subtract }
  CheckException(EOverflow, procedure begin
    BigCardinal.Create(10) - BigCardinal(11);
  end, 'EOverflow not thrown in Subtract operator');
  {$ENDIF}

  { Div }
  CheckException(EDivByZero, procedure begin
    BigCardinal.Create(10) div BigCardinal(0);
  end, 'EDivByZero not thrown in Div operator');

  CheckException(EDivByZero, procedure begin
    BigCardinal.Parse('4387492384723984732984723984732948723984') div BigCardinal(0);
  end, 'EDivByZero not thrown in Div operator');

  { Mod }
  CheckException(EDivByZero, procedure begin
    BigCardinal.Create(10) mod BigCardinal(0);
  end, 'EDivByZero not thrown in Mod operator');

  CheckException(EDivByZero, procedure begin
    BigCardinal.Parse('4387492384723984732984723984732948723984') mod BigCardinal(0);
  end, 'EDivByZero not thrown in Mod operator');

end;

procedure TTestBigCardinal.TestExplicits;
var
  X: BigCardinal;
  V: Variant;
begin
  X := BigCardinal.ParseHex('AABBCCDDEEFFAABBCCDDEEFF00112233445566778899');
  V := X;

  { Standard }
  Check(Byte(X) = $99, 'Byte(X) expected to be $99');
  Check(Word(X) = $8899, 'Word(X) expected to be $8899');
  Check(Cardinal(X) = $66778899, 'Cardinal(X) expected to be $66778899');

  { Char }
  Check(AnsiChar(X) = #$99, 'AnsiChar(X) expected to be #$99');
  Check(WideChar(X) = #$8899, 'AnsiChar(X) expected to be #$8899');

  { Signed standards }
  Check(ShortInt(X) = -103, 'ShortInt(X) expected to be -103');
  Check(SmallInt(X) = -30567, 'SmallInt(X) expected to be -30567');
  Check(Integer(X) = $66778899, 'Integer(X) expected to be $66778899');
  Check(Int64(X) = $2233445566778899, 'Int64(X) expected to be $2233445566778899');

  Check(BigCardinal(V) = X, 'BigCardinal(V) expected to be $AABBCCDDEEFFAABBCCDDEEFF00112233445566778899');
end;

procedure TTestBigCardinal.TestGetType;
begin
  CheckTrue(BigCardinal.GetType <> nil);
  CheckTrue(BigCardinal.GetType.Family = tfUnsignedInteger);
  CheckTrue(BigCardinal.GetType.TypeInfo = TypeInfo(BigCardinal));
end;

procedure TTestBigCardinal.TestHexToStrAndBack;
var
  X: BigCardinal;
  B: String;
begin
  { Byte size }
  X := BigCardinal.ParseHex('A90');
  B := X.ToHexString;
  Check(B = 'A90', 'Expected B to be "A90"');

  { Word size }
  X := BigCardinal.ParseHex('ABCDE');
  B := X.ToHexString;
  Check(B = 'ABCDE', 'Expected B to be "ABCDE"');

  { Int size }
  X := BigCardinal.ParseHex('AABBFFEB');
  B := X.ToHexString;
  Check(B = 'AABBFFEB', 'Expected B to be "AABBFFEB"');

  { Int64 size }
  X := BigCardinal.ParseHex('FFFE6677FE43');
  B := X.ToHexString;
  Check(B = 'FFFE6677FE43', 'Expected B to be "FFFE6677FE43"');

  { Check big number }
  X := BigCardinal.ParseHex('AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA');
  B := X.ToHexString;
  Check(B = 'AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA', 'Expected B to be "AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA"');

  { Check even bigger number }
  X := BigCardinal.ParseHex('AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA');
  B := X.ToHexString;
  Check(B = 'AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA', 'Expected B to be "AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA"');

  { Check front spaces }
  X := BigCardinal.ParseHex('  12345678901234567890ABCDEF');
  B := X.ToHexString;
  Check(B = '12345678901234567890ABCDEF', 'Expected B to be "12345678901234567890ABCDEF"');

  { Check front spaces }
  X := BigCardinal.ParseHex(' 001234567890ABCDEF');
  B := X.ToHexString;
  Check(B = '1234567890ABCDEF', 'Expected B to be "1234567890ABCDEF"');

  { Check small chars }
  X := BigCardinal.ParseHex('abce90a');
  B := X.ToHexString;
  Check(B = 'ABCE90A', 'Expected B to be "ABCE90A"');
end;

procedure TTestBigCardinal.TestHexToStrAndTryBack;
var
  X: BigCardinal;
  B: String;
begin
  { Byte size }
  CheckTrue(BigCardinal.TryParseHex('A90', X));
  B := X.ToHexString;
  Check(B = 'A90', 'Expected B to be "A90"');

  { Word size }
  CheckTrue(BigCardinal.TryParseHex('ABCDE', X));
  B := X.ToHexString;
  Check(B = 'ABCDE', 'Expected B to be "ABCDE"');

  { Int size }
  CheckTrue(BigCardinal.TryParseHex('AABBFFEB', X));
  B := X.ToHexString;
  Check(B = 'AABBFFEB', 'Expected B to be "AABBFFEB"');

  { Int64 size }
  CheckTrue(BigCardinal.TryParseHex('FFFE6677FE43', X));
  B := X.ToHexString;
  Check(B = 'FFFE6677FE43', 'Expected B to be "FFFE6677FE43"');

  { Check big number }
  CheckTrue(BigCardinal.TryParseHex('AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA', X));
  B := X.ToHexString;
  Check(B = 'AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA', 'Expected B to be "AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA"');

  { Check even bigger number }
  CheckTrue(BigCardinal.TryParseHex('AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA', X));
  B := X.ToHexString;
  Check(B = 'AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA', 'Expected B to be "AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA"');

  { Check front spaces }
  CheckTrue(BigCardinal.TryParseHex('  12345678901234567890ABCDEF', X));
  B := X.ToHexString;
  Check(B = '12345678901234567890ABCDEF', 'Expected B to be "12345678901234567890ABCDEF"');

  { Check front spaces }
  CheckTrue(BigCardinal.TryParseHex(' 001234567890ABCDEF', X));
  B := X.ToHexString;
  Check(B = '1234567890ABCDEF', 'Expected B to be "1234567890ABCDEF"');

  { Check small chars }
  CheckTrue(BigCardinal.TryParseHex('abce90a', X));
  B := X.ToHexString;
  Check(B = 'ABCE90A', 'Expected B to be "ABCE90A"');

  CheckFalse(BigCardinal.TryParseHex('', X));
  CheckFalse(BigCardinal.TryParseHex(' ', X));
  CheckFalse(BigCardinal.TryParseHex('22 ', X));
  CheckFalse(BigCardinal.TryParse('x', X));
  CheckFalse(BigCardinal.TryParseHex('-8940823098423', X));
  CheckFalse(BigCardinal.TryParseHex('788 78788', X));
  CheckFalse(BigCardinal.TryParseHex('ABCDEFG', X));
end;

procedure TTestBigCardinal.TestImplicits;
var
  X: BigCardinal;

begin
  X := Byte(100);
  Check(X = 100, 'X is supposed to be 100');

  X := Word(10000);
  Check(X = 10000, 'X is supposed to be 10000');

  X := Cardinal($10FFBBAA);
  Check(X = $10FFBBAA, 'X is supposed to be $10FFBBAA');

  X := UInt64($BA10FFBBAA);
  Check(X = $BA10FFBBAA, 'X is supposed to be $BA10FFBBAA');
end;

procedure TTestBigCardinal.TestIntToStrAndBack;
var
  X: BigCardinal;
  B: String;
begin
  { Byte size }
  X := BigCardinal.Parse('90');
  B := X.ToString;
  Check(B = '90', 'Expected B to be "90"');

  { Word size }
  X := BigCardinal.Parse('16120');
  B := X.ToString;
  Check(B = '16120', 'Expected B to be "16120"');

  { Int size }
  X := BigCardinal.Parse('88989998');
  B := X.ToString;
  Check(B = '88989998', 'Expected B to be "88989998"');

  { Int64 size }
  X := BigCardinal.Parse('889899989990');
  B := X.ToString;
  Check(B = '889899989990', 'Expected B to be "889899989990"');

  { Check big number }
  X := BigCardinal.Parse('779948200474738991364628209377748291298233');
  B := X.ToString;
  Check(B = '779948200474738991364628209377748291298233', 'Expected B to be "779948200474738991364628209377748291298233"');

  { Check even bigger number }
  X := BigCardinal.Parse('779948472398473000466100971094770921074720917401200474738991364628209377748291298233');
  B := X.ToString;
  Check(B = '779948472398473000466100971094770921074720917401200474738991364628209377748291298233', 'Expected B to be "779948472398473000466100971094770921074720917401200474738991364628209377748291298233"');

  { Check front spaces }
  X := BigCardinal.Parse('  12345678901234567890');
  B := X.ToString;
  Check(B = '12345678901234567890', 'Expected B to be "12345678901234567890"');

  { Check front spaces }
  X := BigCardinal.Parse(' 001234567890');
  B := X.ToString;
  Check(B = '1234567890', 'Expected B to be "1234567890"');
end;

procedure TTestBigCardinal.TestIntToStrHexAndBack;
var
  X: BigCardinal;
  B: String;
begin
  { Byte size }
  X := BigCardinal.Parse('$A90');
  B := X.ToHexString;
  Check(B = 'A90', 'Expected B to be "A90"');

  { Word size }
  X := BigCardinal.Parse('$ABCDE');
  B := X.ToHexString;
  Check(B = 'ABCDE', 'Expected B to be "ABCDE"');

  { Int size }
  X := BigCardinal.Parse('$AABBFFEB');
  B := X.ToHexString;
  Check(B = 'AABBFFEB', 'Expected B to be "AABBFFEB"');

  { Int64 size }
  X := BigCardinal.Parse('$FFFE6677FE43');
  B := X.ToHexString;
  Check(B = 'FFFE6677FE43', 'Expected B to be "FFFE6677FE43"');

  { Check big number }
  X := BigCardinal.Parse('$AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA');
  B := X.ToHexString;
  Check(B = 'AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA', 'Expected B to be "AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA"');

  { Check even bigger number }
  X := BigCardinal.Parse('$AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA');
  B := X.ToHexString;
  Check(B = 'AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA', 'Expected B to be "AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA"');

  { Check front spaces }
  X := BigCardinal.Parse('  $12345678901234567890ABCDEF');
  B := X.ToHexString;
  Check(B = '12345678901234567890ABCDEF', 'Expected B to be "12345678901234567890ABCDEF"');

  { Check front spaces }
  X := BigCardinal.Parse(' $001234567890ABCDEF');
  B := X.ToHexString;
  Check(B = '1234567890ABCDEF', 'Expected B to be "1234567890ABCDEF"');

  { Check small chars }
  X := BigCardinal.Parse('$abce90a');
  B := X.ToHexString;
  Check(B = 'ABCE90A', 'Expected B to be "ABCE90A"');
end;

procedure TTestBigCardinal.TestIntToStrHexAndTryBack;
var
  X: BigCardinal;
  B: String;
begin
  { Byte size }
  CheckTrue(BigCardinal.TryParse('$A90', X));
  B := X.ToHexString;
  Check(B = 'A90', 'Expected B to be "A90"');

  { Word size }
  CheckTrue(BigCardinal.TryParse('$ABCDE', X));
  B := X.ToHexString;
  Check(B = 'ABCDE', 'Expected B to be "ABCDE"');

  { Int size }
  CheckTrue(BigCardinal.TryParse('$AABBFFEB', X));
  B := X.ToHexString;
  Check(B = 'AABBFFEB', 'Expected B to be "AABBFFEB"');

  { Int64 size }
  CheckTrue(BigCardinal.TryParse('$FFFE6677FE43', X));
  B := X.ToHexString;
  Check(B = 'FFFE6677FE43', 'Expected B to be "FFFE6677FE43"');

  { Check big number }
  CheckTrue(BigCardinal.TryParse('$AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA', X));
  B := X.ToHexString;
  Check(B = 'AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA', 'Expected B to be "AB3354892933CFFDEF3362DFAAAC33455C3C55555DDEABA"');

  { Check even bigger number }
  CheckTrue(BigCardinal.TryParse('$AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA', X));
  B := X.ToHexString;
  Check(B = 'AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA', 'Expected B to be "AB33A5489246FDE933CFFDB344EF3362DFACEAAAC33455C3BDEFCC5555522AAAC5DDBEABA"');

  { Check front spaces }
  CheckTrue(BigCardinal.TryParse('  $12345678901234567890ABCDEF', X));
  B := X.ToHexString;
  Check(B = '12345678901234567890ABCDEF', 'Expected B to be "12345678901234567890ABCDEF"');

  { Check front spaces }
  CheckTrue(BigCardinal.TryParse(' $001234567890ABCDEF', X));
  B := X.ToHexString;
  Check(B = '1234567890ABCDEF', 'Expected B to be "1234567890ABCDEF"');

  { Check small chars }
  CheckTrue(BigCardinal.TryParse('$abce90a', X));
  B := X.ToHexString;
  Check(B = 'ABCE90A', 'Expected B to be "ABCE90A"');
end;

procedure TTestBigCardinal.TestIsProps;
var
  X: BigCardinal;
begin
  CheckTrue(X.IsZero, 'x.isZero');
  CheckTrue(X.IsEven, 'x.isEven');
  CheckFalse(X.IsOdd, '!x.isOdd');

  CheckTrue(BigCardinal.Zero.IsZero, 'zero.isZero');
  CheckTrue(BigCardinal.Zero.IsEven, 'zero.isEven');
  CheckFalse(BigCardinal.Zero.IsOdd, '!zero.isOdd');

  CheckFalse(BigCardinal.One.IsZero, '!one.isZero');
  CheckFalse(BigCardinal.One.IsEven, '!one.isEven');
  CheckTrue(BigCardinal.One.IsOdd, 'one.isOdd');

  CheckFalse(BigCardinal.Ten.IsZero, '!ten.isZero');
  CheckTrue(BigCardinal.Ten.IsEven, 'ten.isEven');
  CheckFalse(BigCardinal.Ten.IsOdd, '!ten.isOdd');
end;

procedure TTestBigCardinal.TestMul2ShlEq;
const
  Iter = 500;
var
  X, Y: BigCardinal;
  I: Integer;
begin
  X := 1;
  Y := 1;

  { Generate a very big number }
  for I := 0 to Iter - 1 do
  begin
    X := X * 2;
    Y := Y shl 1;

    Check(X = Y, 'X is supposed to be equal to Y in shr/mul combo');
  end;
end;

procedure TTestBigCardinal.TestPow;
begin
  CheckTrue(BigCardinal.Ten.Pow(0) = 1, '10^0');
  CheckTrue(BigCardinal.Ten.Pow(1) = BigCardinal.Ten, '10^1');
  CheckTrue(BigCardinal.Ten.Pow(2) = BigCardinal.Ten * BigCardinal.Ten, '10^2');

  CheckTrue(BigCardinal.One.Pow(0) = 1, '1^0');
  CheckTrue(BigCardinal.One.Pow(1) = BigCardinal.One, '1^1');
  CheckTrue(BigCardinal.One.Pow(2) = BigCardinal.One, '1^2');

  CheckTrue(BigCardinal.Zero.Pow(0) = 1, '0^0');
  CheckTrue(BigCardinal.Zero.Pow(1) = BigCardinal.Zero, '0^1');
  CheckTrue(BigCardinal.Zero.Pow(2) = BigCardinal.Zero, '0^2');

  CheckTrue(BigCardinal(5).Pow(0) = 1, '5^0');
  CheckTrue(BigCardinal(5).Pow(1) = 5, '5^1');
  CheckTrue(BigCardinal(5).Pow(2) = 25, '5^2');
end;

procedure TTestBigCardinal.TestStatNums;
begin
  { Simple }
  CheckTrue(BigCardinal.Zero = 0, 'zero');
  CheckTrue(BigCardinal.One = 1, 'one');
  CheckTrue(BigCardinal.Ten = 10, 'ten');
end;

procedure TTestBigCardinal.TestIntToStrAndTryBack;
var
  X: BigCardinal;
  B: String;
begin
  { Byte size }
  CheckTrue(BigCardinal.TryParse('90', X));
  B := X.ToString;
  Check(B = '90', 'Expected B to be "90"');

  { Word size }
  CheckTrue(BigCardinal.TryParse('16120', X));
  B := X.ToString;
  Check(B = '16120', 'Expected B to be "16120"');

  { Int size }
  CheckTrue(BigCardinal.TryParse('88989998', X));
  B := X.ToString;
  Check(B = '88989998', 'Expected B to be "88989998"');

  { Int64 size }
  CheckTrue(BigCardinal.TryParse('889899989990', X));
  B := X.ToString;
  Check(B = '889899989990', 'Expected B to be "889899989990"');

  { Check big number }
  CheckTrue(BigCardinal.TryParse('779948200474738991364628209377748291298233', X));
  B := X.ToString;
  Check(B = '779948200474738991364628209377748291298233', 'Expected B to be "779948200474738991364628209377748291298233"');

  { Check even bigger number }
  CheckTrue(BigCardinal.TryParse('779948472398473000466100971094770921074720917401200474738991364628209377748291298233', X));
  B := X.ToString;
  Check(B = '779948472398473000466100971094770921074720917401200474738991364628209377748291298233', 'Expected B to be "779948472398473000466100971094770921074720917401200474738991364628209377748291298233"');

  { Check front spaces }
  CheckTrue(BigCardinal.TryParse('  12345678901234567890', X));
  B := X.ToString;
  Check(B = '12345678901234567890', 'Expected B to be "12345678901234567890"');

  { Check front spaces }
  CheckTrue(BigCardinal.TryParse('  001234567890', X));
  B := X.ToString;
  Check(B = '1234567890', 'Expected B to be "1234567890"');

  CheckFalse(BigCardinal.TryParse('', X));
  CheckFalse(BigCardinal.TryParse(' ', X));
  CheckFalse(BigCardinal.TryParse('22 ', X));
  CheckFalse(BigCardinal.TryParse('x', X));
  CheckFalse(BigCardinal.TryParse('-8940823098423', X));
  CheckFalse(BigCardinal.TryParse('788 78788', X));
end;

procedure TTestBigCardinal.TestType;
var
  Support: IType<BigCardinal>;
  X, Y   : BigCardinal;
begin
  Support := TType<BigCardinal>.Default;

  X := BigCardinal.Parse('39712903721983712893712893712893718927389217312321893712986487234623785');
  Y := BigCardinal.Parse('29712903721983712893712893712893718927389217312321893712986487234623785');

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

  Check(Support.GetString(X) = '39712903721983712893712893712893718927389217312321893712986487234623785', 'Expected Support.GetString(X) = "39712903721983712893712893712893718927389217312321893712986487234623785"');
  Check(Support.GetString(Y) = '29712903721983712893712893712893718927389217312321893712986487234623785', 'Expected Support.GetString(Y) = "29712903721983712893712893712893718927389217312321893712986487234623785"');

  Check(Support.Name = 'BigCardinal', 'Type Name = "BigCardinal"');
  Check(Support.Size = SizeOf(BigCardinal), 'Type Size = SizeOf(BigCardinal)');
  Check(Support.TypeInfo = TypeInfo(BigCardinal), 'Type information provider failed!');
  Check(Support.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');
end;

procedure TTestBigCardinal.TestVariantSupport;
var
  X, Y: Variant;
  M: Integer;
begin
  { Check conversions }
  X := BigCardinal.Parse('39712903721983712893712893712893718927389217312321893712986487234623785');
  Y := BigCardinal(100);

  Check(X = '39712903721983712893712893712893718927389217312321893712986487234623785', 'Variant value expected to be "39712903721983712893712893712893718927389217312321893712986487234623785"');
  Check(Y = 100, 'Variant value expected to be "100"');

  { Check opeartors a bit }
  X := X + Y;
  Check(X = '39712903721983712893712893712893718927389217312321893712986487234623885', 'Variant value expected to be "39712903721983712893712893712893718927389217312321893712986487234623885"');

  X := X - Y;
  Check(X = '39712903721983712893712893712893718927389217312321893712986487234623785', 'Variant value expected to be "39712903721983712893712893712893718927389217312321893712986487234623785"');

  X := BigCardinal(1);
  Y := X shl 1;
  Check(Y = '2', 'Variant value expected to be "2"');

  X := BigCardinal(8);
  Y := X shr 1;
  Check(Y = 4, 'Variant value expected to be "4"');

  X := BigCardinal(3);
  Y := X and 1;
  Check(Y = 1, 'Variant value expected to be "1"');

  X := BigCardinal(2);
  Y := X or 1;
  Check(Y = 3, 'Variant value expected to be "3"');

  X := BigCardinal(10);
  Y := X div 3;
  Check(Y = 3, 'Variant value expected to be "3"');

  X := BigCardinal(10);
  Y := X mod 3;
  Check(Y = 1, 'Variant value expected to be "1"');

  X := BigCardinal(100);
  Y := X * 3;
  Check(Y = 300, 'Variant value expected to be "300"');

  X := BigCardinal($FF);
  Y := X xor $F;
  Check(Y = $F0, 'Variant value expected to be "$F0"');

  X := BigCardinal(78);

  CheckException(Exception, procedure begin
    Y := X / 4;
  end,
  'Expected an exception!');

  M := X;
  Check(M = 78, 'M''s value expected to be "78"');

  VarClear(X);
  Check(X = 0, 'Variant value expected to be "0"');

  X := BigCardinal(100);
  Y := BigCardinal(200);

  Check(X < Y, 'X Expected to be less than Y');
  Check(Y > X, 'Y Expected to be greater than X');
  Check(Y >= X, 'Y Expected to be greater or equal than X');
  Check(X <= Y, 'X Expected to be less or equal than Y');

  { An now some random computations }
  X := BigCardinal.Parse('389173892731283721890372089371232893721083921738927138912738196437463278463736478');
  X := X - 8;
  Check(X = '389173892731283721890372089371232893721083921738927138912738196437463278463736470', 'X expected to be "389173892731283721890372089371232893721083921738927138912738196437463278463736470"');

  X := -X;
  Check(X = '497322847235893910871660357774731468867562429713425978513325064154963059549254911796586', 'X expected to be "497322847235893910871660357774731468867562429713425978513325064154963059549254911796586"');

  X := BigCardinal.Parse('0');
  X := not X;
  Check(X = '4294967295', 'X expected to be "4294967295"');

  X := BigCardinal.Parse('$FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  X := not X;
  Check(X = '497323206767011797402436219712648677876351740360231643036479582792017990986772187709440', 'X expected to be "497323206767011797402436219712648677876351740360231643036479582792017990986772187709440"');
end;

procedure TTestBigCardinal.Test_Bug_0;
var
  A, B, C: BigCardinal;
begin
  A := BigCardinal.ParseHex('E0000000000000000000000000000000');
  B := BigCardinal.ParseHex('11111111111111111111111111111111');
  C := (A and B) + 1;

  Check(UIntToStr(C) = '1', 'C expected to be equal to "1"');
end;

initialization
  TestFramework.RegisterTest(TTestBigCardinal.Suite);

end.
