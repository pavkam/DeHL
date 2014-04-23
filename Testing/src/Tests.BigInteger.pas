(*
* Copyright (c) 2008-2009, Ciobanu Alexandru
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
unit Tests.BigInteger;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Math.BigCardinal,
     DeHL.Math.BigInteger;

type
  TTestBigInteger = class(TDeHLTestCase)
  private
     function FromHex(const AStr: string; const DoNeg: Boolean): BigInteger;
    procedure TestAllCompOperatorsAndCompareTo(const X, Y: BigInteger; const IsStrict: Boolean);

  published
    procedure TestCreateAndToXXX();
    procedure TestIntToStrAndBack();
    procedure TestIntToStrAndTryBack();
    procedure TestCompOps();
    procedure TestArithmOps_Positive();
    procedure TestArithmOps_Negative();
    procedure TestBitOps();
    procedure TestImplicits();
    procedure TestExplicits();
    procedure TestBigPow2_Positive();
    procedure TestBigPow2_Negative();
    procedure TestExceptions();
    procedure TestAbs();
    procedure TestStatNums();
    procedure TestIsProps();
    procedure TestSign();
    procedure TestPow();
    procedure TestDivMod();
    procedure TestGetType();
    procedure TestType();

    procedure TestVariantSupport;
  end;


implementation


function TTestBigInteger.FromHex(const AStr: string; const DoNeg: Boolean): BigInteger;
begin
  Result := BigInteger(BigCardinal.ParseHex(AStr));
  if DoNeg then
    Result := - Result;
end;

procedure TTestBigInteger.TestAbs;
var
  X: BigInteger;
begin
  X := BigInteger.Parse('-438764927489274983274398473946278542397432849632784647326487234324342333333');

  X := X.Abs;
  Check(X.ToString = '438764927489274983274398473946278542397432849632784647326487234324342333333');

  X := X.Abs;
  Check(X.ToString = '438764927489274983274398473946278542397432849632784647326487234324342333333');

  X := BigInteger.Zero.Abs;
  Check(X.ToString = '0');
end;

procedure TTestBigInteger.TestAllCompOperatorsAndCompareTo(const X, Y: BigInteger; const IsStrict: Boolean);
var
  AErr: String;
begin
  AErr := ' (X = "' + X.ToString + '"; Y = "' + Y.ToString + '")';

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

procedure TTestBigInteger.TestArithmOps_Positive;
var
  X, Y, Z: BigInteger;
begin
  X := BigInteger.Parse('742038403297403256248056320847328947309842374092374392743974023904732904');

  { Subtraction 1 }
  Z := X - 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732903', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732903"');

  { Addition 1 }
  Z := X + 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732905', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732905"');

  { Multiplication 1 }
  Z := X * 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Multiplication -1 }
  Z := X * -1;
  Check(Z.ToString = '-742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "-742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Division 1 }
  Z := X div 1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Division -1 }
  Z := X div -1;
  Check(Z.ToString = '-742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "-742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Modulo 1 }
  Z := X mod 1;
  Check(Z.ToString = '0', 'Expected Z = "0"');

  { Modulo -1 }
  Z := X mod -1;
  Check(Z.ToString = '0', 'Expected Z = "0"');

  { ---------------------------------------------------- }

  X := BigInteger.Parse('34662493847238423894629524590275259020753492304930000947329473482347387474');

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

  X := BigInteger.Parse('12222222220000000000000000000000000000000000000000000000000000');
  Y := BigInteger.Parse('2222222220000000000000000000000000000000000000000000000000000');

  { Subtraction x }
  Z := X - Y;
  Check(Z.ToString = '10000000000000000000000000000000000000000000000000000000000000', 'Expected Z = "10000000000000000000000000000000000000000000000000000000000000"');

  { Addition x }
  Z := X + Y;
  Check(Z.ToString = '14444444440000000000000000000000000000000000000000000000000000', 'Expected Z = "14444444440000000000000000000000000000000000000000000000000000"');

  { Multiplication 400 }
  Z := X * 400;
  Check(Z.ToString = '4888888888000000000000000000000000000000000000000000000000000000', 'Expected Z = "4888888888000000000000000000000000000000000000000000000000000000"');

  { Multiplication -400 }
  Z := X * -400;
  Check(Z.ToString = '-4888888888000000000000000000000000000000000000000000000000000000', 'Expected Z = "-4888888888000000000000000000000000000000000000000000000000000000"');

  { Division 100000 }
  Z := X div 100000;
  Check(Z.ToString = '122222222200000000000000000000000000000000000000000000000', 'Expected Z = "122222222200000000000000000000000000000000000000000000000"');

  { Division -100000 }
  Z := X div -100000;
  Check(Z.ToString = '-122222222200000000000000000000000000000000000000000000000', 'Expected Z = "-122222222200000000000000000000000000000000000000000000000"');

  { Division 200 }
  Z := X div 200;
  Check(Z.ToString = '61111111100000000000000000000000000000000000000000000000000', 'Expected Z = "61111111100000000000000000000000000000000000000000000000000"');

  { Division 200 }
  Z := X div -200;
  Check(Z.ToString = '-61111111100000000000000000000000000000000000000000000000000', 'Expected Z = "-61111111100000000000000000000000000000000000000000000000000"');

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


  X := BigInteger.Parse('734832789423798427394625642736436434634623452367438527598465298562398423');
  Check(X = +X, 'X was expected to be equal to +X');

  { Check Inc, Dec }
  X := BigInteger.Parse('734832789423798427394625642736436434634623452367438527598465298562398423');

  Inc(X);
  Check(X = BigInteger.Parse('734832789423798427394625642736436434634623452367438527598465298562398424'), 'X was expected to be equal to "734832789423798427394625642736436434634623452367438527598465298562398424"');

  Dec(X);
  Check(X = BigInteger.Parse('734832789423798427394625642736436434634623452367438527598465298562398423'), 'X was expected to be equal to "734832789423798427394625642736436434634623452367438527598465298562398423"');

  X := 100;

  Inc(X, 100);
  Check(X = 200, 'X was expected to be 200');

  Dec(X, 50);
  Check(X = 150, 'X was expected to be 150');
end;

procedure TTestBigInteger.TestArithmOps_Negative;
var
  X, Y, Z, R: BigInteger;
begin
  X := BigInteger.Parse('-742038403297403256248056320847328947309842374092374392743974023904732904');

  { Subtraction 1 }
  Z := X - 1;
  Check(Z.ToString = '-742038403297403256248056320847328947309842374092374392743974023904732905', 'Expected Z = "-742038403297403256248056320847328947309842374092374392743974023904732905"');

  { Addition 1 }
  Z := X + 1;
  Check(Z.ToString = '-742038403297403256248056320847328947309842374092374392743974023904732903', 'Expected Z = "-742038403297403256248056320847328947309842374092374392743974023904732903"');

  { Multiplication 1 }
  Z := X * 1;
  Check(Z.ToString = '-742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "-742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Multiplication -1 }
  Z := X * -1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Division 1 }
  Z := X div 1;
  Check(Z.ToString = '-742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "-742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Division -1 }
  Z := X div -1;
  Check(Z.ToString = '742038403297403256248056320847328947309842374092374392743974023904732904', 'Expected Z = "742038403297403256248056320847328947309842374092374392743974023904732904"');

  { Modulo 1 }
  Z := X mod 1;
  Check(Z.ToString = '0', 'Expected Z = "0"');

  { Modulo -1 }
  Z := X mod -1;
  Check(Z.ToString = '0', 'Expected Z = "0"');

  { ---------------------------------------------------- }

  X := BigInteger.Parse('-34662493847238423894629524590275259020753492304930000947329473482347387474');

  { Subtraction 0 }
  Z := X - 0;
  Check(Z.ToString = '-34662493847238423894629524590275259020753492304930000947329473482347387474', 'Expected Z = "-34662493847238423894629524590275259020753492304930000947329473482347387474"');

  { Addition 0 }
  Z := X + 0;
  Check(Z.ToString = '-34662493847238423894629524590275259020753492304930000947329473482347387474', 'Expected Z = "-34662493847238423894629524590275259020753492304930000947329473482347387474"');

  { Multiplication 0 }
  Z := X * 0;
  Check(Z.ToString = '0', 'Expected Z = "0"');

  { ---------------------------------------------------- }

  X := BigInteger.Parse('-12222222220000000000000000000000000000000000000000000000000000');
  Y := BigInteger.Parse('-2222222220000000000000000000000000000000000000000000000000000');

  { Addition x }
  Z := X - Y;
  Check(Z.ToString = '-10000000000000000000000000000000000000000000000000000000000000', 'Expected Z = "-10000000000000000000000000000000000000000000000000000000000000"');

  { Subtraction x }
  Z := X + Y;
  Check(Z.ToString = '-14444444440000000000000000000000000000000000000000000000000000', 'Expected Z = "-14444444440000000000000000000000000000000000000000000000000000"');

  { Multiplication 400 }
  Z := X * 400;
  Check(Z.ToString = '-4888888888000000000000000000000000000000000000000000000000000000', 'Expected Z = "-4888888888000000000000000000000000000000000000000000000000000000"');

  { Division 100000 }
  Z := X div 100000;
  Check(Z.ToString = '-122222222200000000000000000000000000000000000000000000000', 'Expected Z = "-122222222200000000000000000000000000000000000000000000000"');

  { Division -100000 }
  Z := X div -100000;
  Check(Z.ToString = '122222222200000000000000000000000000000000000000000000000', 'Expected Z = "122222222200000000000000000000000000000000000000000000000"');

  { Division 200 }
  Z := X div 200;
  Check(Z.ToString = '-61111111100000000000000000000000000000000000000000000000000', 'Expected Z = "-61111111100000000000000000000000000000000000000000000000000"');

  { Division -200 }
  Z := X div -200;
  Check(Z.ToString = '61111111100000000000000000000000000000000000000000000000000', 'Expected Z = "61111111100000000000000000000000000000000000000000000000000"');

  { --------------------------------- SOME BASICS --------------- }
  X := -10;
  Y := -10;

  Check(X - Y = 0, 'X - Y expected to be 0');
  Check(X + Y = -20, 'X + Y expected to be 20');
  Check(X * Y = 100, 'X * Y expected to be 100');
  Check(X div Y = 1, 'X div Y expected to be 1');
  Check(X mod Y = 0, 'X mod Y expected to be 0');

  { Some other stuff }
  X := -10;
  X := +X;
  Check(X = -10, 'X was expected to be -10');

  X := -10;
  X := -X;
  Check(X = 10, 'X was expected to be 10');


  X := BigInteger.Parse('-734832789423798427394625642736436434634623452367438527598465298562398423');
  Check(X = +X, 'X was expected to be equal to +X');

  { Check Inc, Dec }
  X := BigInteger.Parse('-734832789423798427394625642736436434634623452367438527598465298562398423');

  Inc(X);
  Check(X = BigInteger.Parse('-734832789423798427394625642736436434634623452367438527598465298562398422'), 'X was expected to be equal to "-734832789423798427394625642736436434634623452367438527598465298562398422"');

  Dec(X);
  Check(X = BigInteger.Parse('-734832789423798427394625642736436434634623452367438527598465298562398423'), 'X was expected to be equal to "-734832789423798427394625642736436434634623452367438527598465298562398423"');

  X := -100;

  Inc(X, 100);
  Check(X = 0, 'X was expected to be 0');

  Dec(X, 50);
  Check(X = -50, 'X was expected to be -50');

  { Modulo behavior }
  X := -10;

  Z := X div 3;
  R := X mod 3;
  Check(Z = -3, 'Z was expected to be -3');
  Check(R = -1, 'R was expected to be -1');

  Z := X div -3;
  R := X mod -3;
  Check(Z = 3, 'Z was expected to be 3');
  Check(R = -1, 'R was expected to be -1');

  X := 10;

  Z := X div -3;
  R := X mod -3;
  Check(Z = -3, 'Z was expected to be -3');
  Check(R = 1, 'R was expected to be 1');

  Z := X div 3;
  R := X mod 3;
  Check(Z = 3, 'Z was expected to be 3');
  Check(R = 1, 'R was expected to be 1');
end;

procedure TTestBigInteger.TestBigPow2_Positive;
const
 Iters = 500;

var
  X: BigInteger;
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

  Check(X = 2, 'X is supposed to be -2');
end;

procedure TTestBigInteger.TestBitOps;
var
  X, Y: BigInteger;
begin
  { SHR }
  X := FromHex('112233445566778899AABBCCDDEEFF', true);

  Y := X shr 0;
  Check(Y = FromHex('112233445566778899AABBCCDDEEFF', true), 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X shr 8;
  Check(Y = FromHex('112233445566778899AABBCCDDEE', true), 'Expected Y = "112233445566778899AABBCCDDEE"');

  Y := X shr 12;
  Check(Y = FromHex('112233445566778899AABBCCDDE', true), 'Expected Y = "112233445566778899AABBCCDDE"');

  X := FromHex('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', false);
  Y := X shr 1;
  Check(Y = FromHex('7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', false), 'Expected Y = "7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"');

  {SHL}
  X := FromHex('112233445566778899AABBCCDDEEFF', true);

  Y := X shl 0;
  Check(Y = FromHex('112233445566778899AABBCCDDEEFF', true), 'Expected Y = "112233445566778899AABBCCDDEEFF"');

  Y := X shl 8;
  Check(Y = FromHex('112233445566778899AABBCCDDEEFF00', true), 'Expected Y = "112233445566778899AABBCCDDEEFF00"');

  Y := X shl 12;
  Check(Y = FromHex('112233445566778899AABBCCDDEEFF000', true), 'Expected Y = "112233445566778899AABBCCDDEEFF000"');

  X := FromHex('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', false);
  Y := X shl 1;
  Check(Y = FromHex('1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE', false), 'Expected Y = "1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE"');
end;

procedure TTestBigInteger.TestBigPow2_Negative;
const
 Iters = 500;

var
  X: BigInteger;
  I: Integer;
begin
  { Let's calculate the a power of 2 }
  X := -2;

  { multiply by 2 on each iteration}
  for I := 0 to Iters - 1 do
    X := X * 2;

  { Divide by 4 this time twice as fast }
  for I := 0 to (Iters div 2) - 1 do
    X := X div 4;

  Check(X = -2, 'X is supposed to be -2');
end;

procedure TTestBigInteger.TestCompOps;
var
  X, Y, Z, W: BigInteger;
begin
  { Only positive values }
  TestAllCompOperatorsAndCompareTo(X, 0, true);
  TestAllCompOperatorsAndCompareTo(0, Y, true);
  TestAllCompOperatorsAndCompareTo(Z, W, true);

  TestAllCompOperatorsAndCompareTo(0, 0, true);
  TestAllCompOperatorsAndCompareTo(1, 0, false);

  TestAllCompOperatorsAndCompareTo(2000000, 100, false);
  TestAllCompOperatorsAndCompareTo($FFFFFFFF, $FFFFFFFF, true);

  TestAllCompOperatorsAndCompareTo(
    BigInteger.Parse('33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    BigInteger.Parse('33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    true);

  TestAllCompOperatorsAndCompareTo(
    BigInteger.Parse('44821903821093821309839210382091833123213213382130928301293821903821309231029382039489'),
    BigInteger.Parse('33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    false);

  TestAllCompOperatorsAndCompareTo(
    BigInteger.Parse('44821903821093821309839210382091833123213213382130928301293821903821309231029382039489'),
    BigInteger.Parse('0900940923605360892376489562085658065662000286864823086460236515430846'),
    false);

  { And now intermixed }
  TestAllCompOperatorsAndCompareTo(0, 0, true);
  TestAllCompOperatorsAndCompareTo(0, -1, false);
  TestAllCompOperatorsAndCompareTo(-10, -10, true);
  TestAllCompOperatorsAndCompareTo(-10, -11, false);

  TestAllCompOperatorsAndCompareTo(100, -2000000, false);
  TestAllCompOperatorsAndCompareTo(-$FFFFFFFF, -$FFFFFFFF, true);

  TestAllCompOperatorsAndCompareTo(
    BigInteger.Parse('-33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    BigInteger.Parse('-33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    true);

  TestAllCompOperatorsAndCompareTo(
    BigInteger.Parse('44821903821093821309839210382091833123213213382130928301293821903821309231029382039489'),
    BigInteger.Parse('-33821903821093821309839210382091830921830291382130928301293821903821309231029382039489'),
    false);

  TestAllCompOperatorsAndCompareTo(
    BigInteger.Parse('0900940923605360892376489562085658065662000286864823086460236515430846'),
    BigInteger.Parse('-44821903821093821309839210382091833123213213382130928301293821903821309231029382039489'),
    false);
end;

procedure TTestBigInteger.TestCreateAndToXXX;
var
  X, Y: BigInteger;
begin
  { Check un-initialied }
  Check(X.ToShortInt() = 0, 'ToShortInt() expected to be 0');
  Check(X.ToSmallInt() = 0, 'ToSmallInt() expected to be 0');
  Check(X.ToInteger() = 0, 'ToInteger() expected to be 0');
  Check(X.ToInt64() = 0, 'ToInt64() expected to be 0');

  { Test initial value }
  X := X * 2;
  Check(X = 0, '(*) X must be zero by default!');

  { Other tests }
  X := BigInteger.Parse('-894378473298473984723984732984732984374938473928473842379483263745164725372');
  Y := BigInteger.Create(X);
  Check(X.ToInt64() = Y.ToInt64, 'X.ToUInt64() expected to be equal to Y.ToInt64()');

  X := BigInteger.Parse('-100');

  { Lets check int types }
  Check(X.ToShortInt() = -100, 'X.ToShortInt() expected to be -100');
  Check(X.ToSmallInt() = -100, 'X.ToSmallInt() expected to be -100');
  Check(X.ToInteger() = -100, 'X.ToInteger() expected to be -100');
  Check(X.ToInt64() = -100, 'X.ToInt64() expected to be -100');

  { Test create and To from Ints }
  X := BigInteger.Create(Int64(-2200));
  Check(X.ToInt64() = -2200, 'X.ToInt64() is expected to be -2200');

  X := BigInteger.Create(Integer(-88088));
  Check(X.ToInteger() = -88088, 'X.ToInteger() is expected to be -88088');

  X := BigInteger.Create(SmallInt(-8808));
  Check(X.ToSmallInt() = -8808, 'X.ToSmallInt() is expected to be -8808');

  X := BigInteger.Create(ShortInt(-88));
  Check(X.ToShortInt() = -88, 'X.ToShortInt() is expected to be -88');
end;

procedure TTestBigInteger.TestDivMod;
var
  X, Y, R: BigInteger;
begin
  X := BigInteger(-12345) * BigInteger(778881) - BigInteger(123);

  Y := X.DivMod(778881, R);
  CheckTrue(Y = -12345);
  CheckTrue(R = -123);

  Y := X.DivMod(-12345, R);
  CheckTrue(Y = 778881);
  CheckTrue(R = -123);

  X := X + BigInteger(123);
  Y := X.DivMod(778881, R);
  CheckTrue(Y = -12345);
  CheckTrue(R = 0);

  Y := X.DivMod(12345, R);
  CheckTrue(Y = -778881);
  CheckTrue(R = 0);
end;

procedure TTestBigInteger.TestExceptions;
begin
  { Str to Int }
  CheckException(EConvertError, procedure begin
    BigInteger.Parse('');
  end, 'EConvertError not thrown in BigInteger.Parse');

  CheckException(EConvertError, procedure begin
    BigInteger.Parse(' ');
  end, 'EConvertError not thrown in BigInteger.Parse');

  CheckException(EConvertError, procedure begin
    BigInteger.Parse('22 ');
  end, 'EConvertError not thrown in BigInteger.Parse');

  CheckException(EConvertError, procedure begin
    BigInteger.Parse('x');
  end, 'EConvertError not thrown in BigInteger.Parse');

  CheckException(EConvertError, procedure begin
    BigInteger.Parse(' +-8940823098423');
  end, 'EConvertError not thrown in BigInteger.Parse');

  CheckException(EConvertError, procedure begin
    BigInteger.Parse('788 78788');
  end, 'EConvertError not thrown in BigInteger.Parse');

  { Div }
  CheckException(EDivByZero, procedure begin
    BigInteger.Create(10) div BigInteger(0);
  end, 'EDivByZero not thrown in Div operator');

  CheckException(EDivByZero, procedure begin
    BigInteger.Create(-100) div BigInteger(0);
  end, 'EDivByZero not thrown in Div operator');

  CheckException(EDivByZero, procedure begin
    BigInteger.Parse('4387492384723984732984723984732948723984') div BigInteger(0);
  end, 'EDivByZero not thrown in Div operator');

  CheckException(EDivByZero, procedure begin
    BigInteger.Parse('-4387492384723984732984723984732948723984') div BigInteger(0);
  end, 'EDivByZero not thrown in Div operator');

  { Mod }
  CheckException(EDivByZero, procedure begin
    BigInteger.Create(10) mod BigInteger(0);
  end, 'EDivByZero not thrown in Mod operator');

  CheckException(EDivByZero, procedure begin
    BigInteger.Create(-10) mod BigInteger(0);
  end, 'EDivByZero not thrown in Mod operator');

  CheckException(EDivByZero, procedure begin
    BigInteger.Parse('4387492384723984732984723984732948723984') mod BigInteger(0);
  end, 'EDivByZero not thrown in Mod operator');

  CheckException(EDivByZero, procedure begin
    BigInteger.Parse('-4387492384723984732984723984732948723984') mod BigInteger(0);
  end, 'EDivByZero not thrown in Mod operator');

end;

procedure TTestBigInteger.TestExplicits;
var
  X: BigInteger;
  V: Variant;
begin
  X := -120;

  { Signed standards }
  Check(ShortInt(X) = -120, 'ShortInt(X) expected to be -120');
  Check(SmallInt(X) = -120, 'SmallInt(X) expected to be -120');
  Check(Integer(X) = -120, 'Integer(X) expected to be -120');
  Check(Int64(X) = -120, 'Int64(X) expected to be -120');

  X := BigInteger.Parse('-3721673562173561725321673521736125376215376123123213');
  V := X;

  CheckTrue(BigInteger(V) = X, 'explicit = -3721673562173561725321673521736125376215376123123213');
end;

procedure TTestBigInteger.TestGetType;
begin
  CheckTrue(BigInteger.GetType <> nil);
  CheckTrue(BigInteger.GetType.Family = tfSignedInteger);
  CheckTrue(BigInteger.GetType.TypeInfo = TypeInfo(BigInteger));
end;

procedure TTestBigInteger.TestImplicits;
var
  X: BigInteger;

begin
  X := Byte(100);
  Check(X = 100, 'X is supposed to be 100');

  X := Word(10000);
  Check(X = 10000, 'X is supposed to be 10000');

  X := Cardinal($10FFBBAA);
  Check(X = $10FFBBAA, 'X is supposed to be $10FFBBAA');

  X := UInt64($BA10FFBBAA);
  Check(X = $BA10FFBBAA, 'X is supposed to be $BA10FFBBAA');

  X := ShortInt(-100);
  Check(X = -100, 'X is supposed to be -100');

  X := SmallInt(-10000);
  Check(X = -10000, 'X is supposed to be -10000');

  X := Integer(-$10FFBBAA);
  Check(X = -$10FFBBAA, 'X is supposed to be -$10FFBBAA');

  X := Int64(-$BA10FFBBAA);
  Check(X = -$BA10FFBBAA, 'X is supposed to be -$BA10FFBBAA');

  X := BigCardinal.Parse('450923784097235907983474236752309720983492840392483209472308563458');
  Check(X.ToString = '450923784097235907983474236752309720983492840392483209472308563458', 'X is supposed to be "450923784097235907983474236752309720983492840392483209472308563458"');
end;

procedure TTestBigInteger.TestIntToStrAndBack;
var
  X: BigInteger;
  B: String;
begin
  { -- Positives -- }

  { Byte size }
  X := BigInteger.Parse('90');
  B := X.ToString;
  Check(B = '90', 'Expected B to be "90"');

  { Word size }
  X := BigInteger.Parse('16120');
  B := X.ToString;
  Check(B = '16120', 'Expected B to be "16120"');

  { Int size }
  X := BigInteger.Parse('88989998');
  B := X.ToString;
  Check(B = '88989998', 'Expected B to be "88989998"');

  { Int64 size }
  X := BigInteger.Parse('889899989990');
  B := X.ToString;
  Check(B = '889899989990', 'Expected B to be "889899989990"');

  { Check big number }
  X := BigInteger.Parse('779948200474738991364628209377748291298233');
  B := X.ToString;
  Check(B = '779948200474738991364628209377748291298233', 'Expected B to be "779948200474738991364628209377748291298233"');

  { Check even bigger number }
  X := BigInteger.Parse('779948472398473000466100971094770921074720917401200474738991364628209377748291298233');
  B := X.ToString;
  Check(B = '779948472398473000466100971094770921074720917401200474738991364628209377748291298233', 'Expected B to be "779948472398473000466100971094770921074720917401200474738991364628209377748291298233"');

  { Check front spaces }
  X := BigInteger.Parse('  12345678901234567890');
  B := X.ToString;
  Check(B = '12345678901234567890', 'Expected B to be "12345678901234567890"');

  { Check front spaces }
  X := BigInteger.Parse(' 001234567890');
  B := X.ToString;
  Check(B = '1234567890', 'Expected B to be "1234567890"');

  { -- Negatives -- }

  { SmallInt size }
  X := BigInteger.Parse('-90');
  B := X.ToString;
  Check(B = '-90', 'Expected B to be "-90"');

  { ShortInt size }
  X := BigInteger.Parse('-1200');
  B := X.ToString;
  Check(B = '-1200', 'Expected B to be "-1200"');

  { Integer size }
  X := BigInteger.Parse('-88989998');
  B := X.ToString;
  Check(B = '-88989998', 'Expected B to be "-88989998"');

  { Int64 size }
  X := BigInteger.Parse('-889899989990');
  B := X.ToString;
  Check(B = '-889899989990', 'Expected B to be "-889899989990"');

  { Check big number }
  X := BigInteger.Parse('-779948200474738991364628209377748291298233');
  B := X.ToString;
  Check(B = '-779948200474738991364628209377748291298233', 'Expected B to be "-779948200474738991364628209377748291298233"');

  { Check even bigger number }
  X := BigInteger.Parse('-779948472398473000466100971094770921074720917401200474738991364628209377748291298233');
  B := X.ToString;
  Check(B = '-779948472398473000466100971094770921074720917401200474738991364628209377748291298233', 'Expected B to be "-779948472398473000466100971094770921074720917401200474738991364628209377748291298233"');

  { Check front spaces }
  X := BigInteger.Parse('  -12345678901234567890');
  B := X.ToString;
  Check(B = '-12345678901234567890', 'Expected B to be "-12345678901234567890"');

  { Check front spaces }
  X := BigInteger.Parse(' -001234567890');
  B := X.ToString;
  Check(B = '-1234567890', 'Expected B to be "-1234567890"');
end;

procedure TTestBigInteger.TestIntToStrAndTryBack;
var
  X: BigInteger;
  B: String;
begin
  { -- Positives -- }

  { Byte size }
  CheckTrue(BigInteger.TryParse('90', X));
  B := X.ToString;
  Check(B = '90', 'Expected B to be "90"');

  { Word size }
  CheckTrue(BigInteger.TryParse('16120', X));
  B := X.ToString;
  Check(B = '16120', 'Expected B to be "16120"');

  { Int size }
  CheckTrue(BigInteger.TryParse('88989998', X));
  B := X.ToString;
  Check(B = '88989998', 'Expected B to be "88989998"');

  { Int64 size }
  CheckTrue(BigInteger.TryParse('889899989990', X));
  B := X.ToString;
  Check(B = '889899989990', 'Expected B to be "889899989990"');

  { Check big number }
  CheckTrue(BigInteger.TryParse('779948200474738991364628209377748291298233', X));
  B := X.ToString;
  Check(B = '779948200474738991364628209377748291298233', 'Expected B to be "779948200474738991364628209377748291298233"');

  { Check even bigger number }
  CheckTrue(BigInteger.TryParse('779948472398473000466100971094770921074720917401200474738991364628209377748291298233', X));
  B := X.ToString;
  Check(B = '779948472398473000466100971094770921074720917401200474738991364628209377748291298233', 'Expected B to be "779948472398473000466100971094770921074720917401200474738991364628209377748291298233"');

  { Check front spaces }
  CheckTrue(BigInteger.TryParse('  12345678901234567890', X));
  B := X.ToString;
  Check(B = '12345678901234567890', 'Expected B to be "12345678901234567890"');

  { Check front spaces }
  CheckTrue(BigInteger.TryParse(' 001234567890', X));
  B := X.ToString;
  Check(B = '1234567890', 'Expected B to be "1234567890"');

  { -- Negatives -- }

  { SmallInt size }
  CheckTrue(BigInteger.TryParse('-90', X));
  B := X.ToString;
  Check(B = '-90', 'Expected B to be "-90"');

  { ShortInt size }
  CheckTrue(BigInteger.TryParse('-1200', X));
  B := X.ToString;
  Check(B = '-1200', 'Expected B to be "-1200"');

  { Integer size }
  CheckTrue(BigInteger.TryParse('-88989998', X));
  B := X.ToString;
  Check(B = '-88989998', 'Expected B to be "-88989998"');

  { Int64 size }
  CheckTrue(BigInteger.TryParse('-889899989990', X));
  B := X.ToString;
  Check(B = '-889899989990', 'Expected B to be "-889899989990"');

  { Check big number }
  CheckTrue(BigInteger.TryParse('-779948200474738991364628209377748291298233', X));
  B := X.ToString;
  Check(B = '-779948200474738991364628209377748291298233', 'Expected B to be "-779948200474738991364628209377748291298233"');

  { Check even bigger number }
  CheckTrue(BigInteger.TryParse('-779948472398473000466100971094770921074720917401200474738991364628209377748291298233', X));
  B := X.ToString;
  Check(B = '-779948472398473000466100971094770921074720917401200474738991364628209377748291298233', 'Expected B to be "-779948472398473000466100971094770921074720917401200474738991364628209377748291298233"');

  { Check front spaces }
  CheckTrue(BigInteger.TryParse('  -12345678901234567890', X));
  B := X.ToString;
  Check(B = '-12345678901234567890', 'Expected B to be "-12345678901234567890"');

  { Check front spaces }
  CheckTrue(BigInteger.TryParse(' -001234567890', X));
  B := X.ToString;
  Check(B = '-1234567890', 'Expected B to be "-1234567890"');

  CheckFalse(BigInteger.TryParse('', X));
  CheckFalse(BigInteger.TryParse(' ', X));
  CheckFalse(BigInteger.TryParse('22 ', X));
  CheckFalse(BigInteger.TryParse('x', X));
  CheckFalse(BigInteger.TryParse(' +-8940823098423', X));
  CheckFalse(BigInteger.TryParse('788 78788', X));
end;

procedure TTestBigInteger.TestIsProps;
var
  X: BigInteger;
begin
  CheckTrue(X.IsZero, 'x.isZero');
  CheckTrue(X.IsEven, 'x.isEven');
  CheckFalse(X.IsOdd, '!x.isOdd');
  CheckFalse(X.IsNegative, '!x.isNeg');
  CheckTrue(X.IsPositive, 'x.isPos');

  CheckTrue(BigInteger.Zero.IsZero, 'zero.isZero');
  CheckTrue(BigInteger.Zero.IsEven, 'zero.isEven');
  CheckFalse(BigInteger.Zero.IsOdd, '!zero.isOdd');
  CheckFalse(BigInteger.Zero.IsNegative, '!zero.isNeg');
  CheckTrue(BigInteger.Zero.IsPositive, 'zero.isPos');

  CheckFalse(BigInteger.One.IsZero, '!one.isZero');
  CheckFalse(BigInteger.One.IsEven, '!one.isEven');
  CheckTrue(BigInteger.One.IsOdd, 'one.isOdd');
  CheckFalse(BigInteger.One.IsNegative, '!one.isNeg');
  CheckTrue(BigInteger.One.IsPositive, 'one.isPos');

  CheckFalse(BigInteger.Ten.IsZero, '!ten.isZero');
  CheckTrue(BigInteger.Ten.IsEven, 'ten.isEven');
  CheckFalse(BigInteger.Ten.IsOdd, '!ten.isOdd');
  CheckFalse(BigInteger.Ten.IsNegative, '!ten.isNeg');
  CheckTrue(BigInteger.Ten.IsPositive, 'ten.isPos');

  CheckFalse(BigInteger.MinusOne.IsZero, '!one.isZero');
  CheckFalse(BigInteger.MinusOne.IsEven, '!one.isEven');
  CheckTrue(BigInteger.MinusOne.IsOdd, 'one.isOdd');
  CheckTrue(BigInteger.MinusOne.IsNegative, 'one.isNeg');
  CheckFalse(BigInteger.MinusOne.IsPositive, '!one.isPos');

  CheckFalse(BigInteger.MinusTen.IsZero, '!ten.isZero');
  CheckTrue(BigInteger.MinusTen.IsEven, 'ten.isEven');
  CheckFalse(BigInteger.MinusTen.IsOdd, '!ten.isOdd');
  CheckTrue(BigInteger.MinusTen.IsNegative, 'ten.isNeg');
  CheckFalse(BigInteger.MinusTen.IsPositive, '!ten.isPos');
end;

procedure TTestBigInteger.TestPow;
begin
  CheckTrue(BigInteger.Ten.Pow(0) = 1, '10^0');
  CheckTrue(BigInteger.Ten.Pow(1) = 10, '10^1');
  CheckTrue(BigInteger.Ten.Pow(2) = 100, '10^2');

  CheckTrue(BigInteger.MinusTen.Pow(0) = 1, '-10^0');
  CheckTrue(BigInteger.MinusTen.Pow(1) = -10, '-10^1');
  CheckTrue(BigInteger.MinusTen.Pow(2) = 100, '-10^2');
  CheckTrue(BigInteger.MinusTen.Pow(3) = -1000, '-10^3');

  CheckTrue(BigInteger.One.Pow(0) = 1, '1^0');
  CheckTrue(BigInteger.One.Pow(1) = BigInteger.One, '1^1');
  CheckTrue(BigInteger.One.Pow(2) = BigInteger.One, '1^2');

  CheckTrue(BigInteger.MinusOne.Pow(0) = 1, '-1^0');
  CheckTrue(BigInteger.MinusOne.Pow(1) = BigInteger.MinusOne, '-1^1');
  CheckTrue(BigInteger.MinusOne.Pow(2) = BigInteger.One, '-1^2');
  CheckTrue(BigInteger.MinusOne.Pow(3) = BigInteger.MinusOne, '-1^3');

  CheckTrue(BigInteger.Zero.Pow(0) = 1, '0^0');
  CheckTrue(BigInteger.Zero.Pow(1) = BigInteger.Zero, '0^1');
  CheckTrue(BigInteger.Zero.Pow(2) = BigInteger.Zero, '0^2');

  CheckTrue(BigInteger(-5).Pow(0) = 1, '5^0');
  CheckTrue(BigInteger(-5).Pow(1) = -5, '5^1');
  CheckTrue(BigInteger(-5).Pow(2) = 25, '5^2');
end;

procedure TTestBigInteger.TestSign;
var
  X: BigInteger;
begin
  CheckEquals(0, X.Sign);
  CheckEquals(0, BigInteger.Zero.Sign);
  CheckEquals(1, BigInteger.One.Sign);
  CheckEquals(1, BigInteger.Ten.Sign);
  CheckEquals(-1, BigInteger.MinusOne.Sign);
  CheckEquals(-1, BigInteger.MinusTen.Sign);
end;

procedure TTestBigInteger.TestStatNums;
begin
  { Simple }
  CheckTrue(BigInteger.Zero = 0, 'zero');
  CheckTrue(BigInteger.One = 1, 'one');
  CheckTrue(BigInteger.MinusOne = -1, 'min one');
  CheckTrue(BigInteger.Ten = 10, 'ten');
  CheckTrue(BigInteger.MinusTen = -10, 'min ten');
end;

procedure TTestBigInteger.TestType;
var
  Support: IType<BigInteger>;
  X, Y   : BigInteger;
begin
  Support := TType<BigInteger>.Default;

  X := BigInteger.Parse('39712903721983712893712893712893718927389217312321893712986487234623785');
  Y := BigInteger.Parse('-39712903721983712893712893712893718927389217312321893712986487234623785');

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
  Check(Support.GetString(Y) = '-39712903721983712893712893712893718927389217312321893712986487234623785', 'Expected Support.GetString(Y) = "-39712903721983712893712893712893718927389217312321893712986487234623785"');

  Check(Support.Name = 'BigInteger', 'Type Name = "BigInteger"');
  Check(Support.Size = SizeOf(BigInteger), 'Type Size = SizeOf(BigInteger)');
  Check(Support.TypeInfo = TypeInfo(BigInteger), 'Type information provider failed!');
  Check(Support.Family = tfSignedInteger, 'Type Family = tfSignedInteger');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');
end;

procedure TTestBigInteger.TestVariantSupport;
var
  X, Y: Variant;
  M: Integer;
begin
  { Check conversions }
  X := BigInteger.Parse('-39712903721983712893712893712893718927389217312321893712986487234623785');
  Y := BigInteger(100);

  Check(X = '-39712903721983712893712893712893718927389217312321893712986487234623785', 'Variant value expected to be "-39712903721983712893712893712893718927389217312321893712986487234623785"');
  Check(Y = 100, 'Variant value expected to be "100"');

  { Check opeartors a bit }
  X := X + Y;
  Check(X = '-39712903721983712893712893712893718927389217312321893712986487234623685', 'Variant value expected to be "-39712903721983712893712893712893718927389217312321893712986487234623685"');

  X := X - Y;
  Check(X = '-39712903721983712893712893712893718927389217312321893712986487234623785', 'Variant value expected to be "-39712903721983712893712893712893718927389217312321893712986487234623785"');

  X := BigInteger(10);
  Y := X div -3;
  Check(Y = -3, 'Variant value expected to be "-3"');

  X := BigInteger(10);
  Y := X mod 3;
  Check(Y = 1, 'Variant value expected to be "1"');

  X := BigInteger(-100);
  Y := X * 3;
  Check(Y = -300, 'Variant value expected to be "-300"');

  X := BigInteger(-78);

  CheckException(Exception, procedure begin
    Y := X / 4;
  end,
  'Expected an exception!');

  M := X;
  Check(M = -78, 'M''s value expected to be "-78"');

  X := -X;
  Check(X = 78, 'Variant value expected to be "78"');

  VarClear(X);
  Check(X = 0, 'Variant value expected to be "0"');

  X := BigInteger(-100);
  Y := BigInteger(-20);

  Check(X < Y, 'X Expected to be less than Y');
  Check(Y > X, 'Y Expected to be greater than X');
  Check(Y >= X, 'Y Expected to be greater or equal than X');
  Check(X <= Y, 'X Expected to be less or equal than Y');

  { An now some random computations }
  X := '389173892731283721890372089371232893721083921738927138912738196437463278463736478';
  X := X - 8;
  Check(X = '389173892731283721890372089371232893721083921738927138912738196437463278463736470', 'X expected to be "389173892731283721890372089371232893721083921738927138912738196437463278463736470"');
end;

initialization
  TestFramework.RegisterTest(TTestBigInteger.Suite);

end.
