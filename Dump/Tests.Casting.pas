(*
* Copyright (c) 2008, Ciobanu Alexandru
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
* THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

unit Tests.Casting;
interface
uses SysUtils,
     Windows,
     TestFramework,
     HelperLib.Cast;

type
 TTestCasting = class(TTestCase)
   procedure TestToStringCastingInts();
   procedure TestToStringCastingFloats();
   procedure TestToStringCastingStrings();
   procedure TestToStringCastingBools();
 end;

implementation

{ TTestCasting }

procedure TTestCasting.TestToStringCastingBools;
begin
  Check(Cast.ToString(Boolean(true)) = 'True', 'Boolean'); Check(Cast.ToString(Boolean(false)) = 'False', 'Boolean');
  Check(Cast.ToString(ByteBool(true)) = 'True', 'ByteBool'); Check(Cast.ToString(ByteBool(false)) = 'False', 'ByteBool');
  Check(Cast.ToString(WordBool(true)) = 'True', 'WordBool'); Check(Cast.ToString(WordBool(false)) = 'False', 'WordBool');
  Check(Cast.ToString(LongBool(true)) = 'True', 'LongBool'); Check(Cast.ToString(LongBool(false)) = 'False', 'LongBool');
end;

procedure TTestCasting.TestToStringCastingFloats;
var
 s1, s2 : Single;
 r1, r2 : Real;
 u1, u2 : Real48;
 d1, d2 : Double;
 e1, e2 : Extended;
 c1, c2 : Currency;
 p1, p2 : Comp;
 Fs     : TFormatSettings;
 Sep    : Char;

 s      : String;
begin
  s1 := 1.10; s2 := -0.23;
  r1 := 1.10; r2 := -0.23;
  u1 := 1.10; u2 := -0.23;
  d1 := 1.10; d2 := -0.23;
  e1 := 1.10; e2 := -0.23;
  c1 := 1.10; c2 := -0.23;
  p1 := 123456; p2 := 654321;

  GetLocaleFormatSettings(GetUserDefaultLCID(), Fs);
  Sep := Fs.DecimalSeparator;


  s := Cast.ToString(u2);

  { Normal mode }
  Check(Cast.ToString(s1) = '1' + Sep + '10000002384186', 'Single'); Check(Cast.ToString(s2) = '-0' + Sep + '230000004172325', 'Single');
  Check(Cast.ToString(r1) = '1' + Sep + '1', 'Real'); Check(Cast.ToString(r2) = '-0' + Sep + '23', 'Real');
  Check(Cast.ToString(u1) = '1' + Sep + '10000000000036', 'Real48'); Check(Cast.ToString(u2) = '-0'+ Sep + '230000000000018', 'Real48');
  Check(Cast.ToString(d1) = '1' + Sep + '1', 'Double'); Check(Cast.ToString(d2) = '-0' + Sep + '23', 'Double');
  Check(Cast.ToString(e1) = '1' + Sep + '1', 'Extended'); Check(Cast.ToString(e2) = '-0' + Sep + '23', 'Extended');
  Check(Cast.ToString(c1) = '1' + Sep + '1', 'Currency'); Check(Cast.ToString(c2) = '-0' + Sep + '23', 'Currency');
  Check(Cast.ToString(p1) = '123456', 'Comp'); Check(Cast.ToString(p2) = '654321', 'Comp');

  Fs.DecimalSeparator := '/';
  Sep := Fs.DecimalSeparator;

  { Locale mode }
  Check(Cast.ToString(s1, Fs) = '1' + Sep + '10000002384186', 'Single (NewLocale)'); Check(Cast.ToString(s2, Fs) = '-0' + Sep + '230000004172325', 'Single (NewLocale)');
  Check(Cast.ToString(r1, Fs) = '1' + Sep + '1', 'Real (NewLocale)'); Check(Cast.ToString(r2, Fs) = '-0' + Sep + '23', 'Real (NewLocale)');
  Check(Cast.ToString(u1, Fs) = '1' + Sep + '10000000000036', 'Real48 (NewLocale)'); Check(Cast.ToString(u2, Fs) = '-0' + Sep + '230000000000018', 'Real48 (NewLocale)');
  Check(Cast.ToString(d1, Fs) = '1' + Sep + '1', 'Double (NewLocale)'); Check(Cast.ToString(d2, Fs) = '-0' + Sep + '23', 'Double (NewLocale)');
  Check(Cast.ToString(e1, Fs) = '1' + Sep + '1', 'Extended (NewLocale)'); Check(Cast.ToString(e2, Fs) = '-0' + Sep + '23', 'Extended (NewLocale)');
  Check(Cast.ToString(c1, Fs) = '1' + Sep + '1', 'Currency (NewLocale)'); Check(Cast.ToString(c2, Fs) = '-0' + Sep + '23', 'Currency (NewLocale)');
  Check(Cast.ToString(p1, Fs) = '123456', 'Comp (NewLocale)'); Check(Cast.ToString(p2, Fs) = '654321', 'Comp (NewLocale)');
end;

procedure TTestCasting.TestToStringCastingInts;
begin
  Check(Cast.ToString(SmallInt(-125)) = '-125', 'SmallInt'); Check(Cast.ToString(SmallInt(10)) = '10', 'SmallInt');
  Check(Cast.ToString(Byte(255)) = '255', 'Byte'); Check(Cast.ToString(Byte(0)) = '0', 'Byte');
  Check(Cast.ToString(ShortInt(-125)) = '-125', 'ShortInt'); Check(Cast.ToString(ShortInt(10)) = '10', 'ShortInt');
  Check(Cast.ToString(Word(8000)) = '8000', 'Word'); Check(Cast.ToString(Word(0)) = '0', 'Word');
  Check(Cast.ToString(Integer(-40000)) = '-40000', 'Integer'); Check(Cast.ToString(Integer(10)) = '10', 'Integer');
  Check(Cast.ToString(Cardinal(80000)) = '80000', 'Cardinal'); Check(Cast.ToString(Cardinal(0)) = '0', 'Cardinal');
  Check(Cast.ToString(Int64(-40000)) = '-40000', 'Int64'); Check(Cast.ToString(Int64(10)) = '10', 'Int64');
  Check(Cast.ToString(UInt64(80000)) = '80000', 'UInt64'); Check(Cast.ToString(UInt64(0)) = '0', 'UInt64');
  Check(Cast.ToString(Pointer(1)) = '1', 'Pointer'); Check(Cast.ToString(Pointer($FF)) = '255', 'Pointer');
end;

procedure TTestCasting.TestToStringCastingStrings;
begin
  Check(Cast.ToString(ShortString('Test1')) = 'Test1', 'ShortString'); Check(Cast.ToString(ShortString('Te' + #0 + 'st2')) = 'Te' + #0 + 'st2', 'ShortString');
  Check(Cast.ToString(String('Test1')) = 'Test1', 'String'); Check(Cast.ToString(String('Te' + #0 + 'st2')) = 'Te' + #0 + 'st2', 'String');
  Check(Cast.ToString(Char(65)) = 'A', 'Char'); Check(Cast.ToString(String('_')) = '_', 'Char');
  Check(Cast.ToString(PChar('Hello')) = 'Hello', 'PChar'); Check(Cast.ToString(PChar('A' + 'B' + 'C')) = 'ABC', 'PChar');
end;

initialization
  TestFramework.RegisterTest(TTestCasting.Suite);

end.
