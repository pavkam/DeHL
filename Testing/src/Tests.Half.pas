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
unit Tests.Half;
interface
uses SysUtils,
     Math,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Math.Half;

type
  TTestHalf = class(TDeHLTestCase)
  private
    FHalf: Half;
    function GetWord: Word;
    property FWord: Word read GetWord;

  published
    procedure Test_Implicit_Single_Half;
    procedure Test_Implicit_Half_Single;
    procedure Test_Implicit_Variant_Half;
    procedure Test_Implicit_Half_Variant;
    procedure Test_Add_Half_Half;
    procedure Test_Add_Half_Single;
    procedure Test_Add_Single_Half;
    procedure Test_Subtract_Half_Half;
    procedure Test_Subtract_Half_Single;
    procedure Test_Subtract_Single_Half;
    procedure Test_Multiply_Half_Half;
    procedure Test_Multiply_Half_Single;
    procedure Test_Multiply_Single_Half;
    procedure Test_Divide_Half_Half;
    procedure Test_Divide_Half_Single;
    procedure Test_Divide_Single_Half;
    procedure Test_Negative;
    procedure Test_Positive;
    procedure Test_Equal_Half_Half;
    procedure Test_Equal_Half_Single;
    procedure Test_Equal_Single_Half;
    procedure Test_NotEqual_Half_Half;
    procedure Test_NotEqual_Half_Single;
    procedure Test_NotEqual_Single_Half;
    procedure Test_GreaterThan_Half_Half;
    procedure Test_GreaterThan_Half_Single;
    procedure Test_GreaterThan_Single_Half;
    procedure Test_GreaterThanOrEqual_Half_Half;
    procedure Test_GreaterThanOrEqual_Half_Single;
    procedure Test_GreaterThanOrEqual_Single_Half;
    procedure Test_LessThan_Half_Half;
    procedure Test_LessThan_Half_Single;
    procedure Test_LessThan_Single_Half;
    procedure Test_LessThanOrEqual_Half_Half;
    procedure Test_LessThanOrEqual_Half_Single;
    procedure Test_LessThanOrEqual_Single_Half;
    procedure Test_Min;
    procedure Test_Max;
    procedure Test_Zero;
    procedure Test_MinusZero;
    procedure Test_One;
    procedure Test_MinusOne;
    procedure Test_Ten;
    procedure Test_MinusTen;
    procedure Test_Infinity;
    procedure Test_MinusInfinity;
    procedure Test_GetType;

    procedure Test_TypeSupport;
  end;

implementation


{ TTestHalf }

function TTestHalf.GetWord: Word;
var
  LHalf: Half absolute Result;
begin
  LHalf := FHalf;
end;

procedure TTestHalf.Test_Add_Half_Half;
begin
  FHalf := Half(1) + Half(2.3);
  CheckEquals(17049, FWord);
end;

procedure TTestHalf.Test_Add_Half_Single;
begin
  FHalf := Half(1) + 2.3;
  CheckEquals(17049, FWord);
end;

procedure TTestHalf.Test_Add_Single_Half;
begin
  FHalf := 1 + Half(2.3);
  CheckEquals(17049, FWord);
end;

procedure TTestHalf.Test_Divide_Half_Half;
begin
  FHalf := Half(10)/Half(4.4);
  CheckEquals(16524, FWord);
end;

procedure TTestHalf.Test_Divide_Half_Single;
begin
  FHalf := Half(10)/4.4;
  CheckEquals(16524, FWord);
end;

procedure TTestHalf.Test_Divide_Single_Half;
begin
  FHalf := 10/Half(4.4);
  CheckEquals(16524, FWord);
end;

procedure TTestHalf.Test_Equal_Half_Half;
begin
  CheckTrue(Half(10) = Half(10));
  CheckFalse(Half(10) = Half(-10));
end;

procedure TTestHalf.Test_Equal_Half_Single;
begin
  CheckTrue(Half(10) = 10);
  CheckFalse(Half(10) = -10);
end;

procedure TTestHalf.Test_Equal_Single_Half;
begin
  CheckTrue(10 = Half(10));
  CheckFalse(10 = Half(-10));
end;

procedure TTestHalf.Test_GetType;
begin
  CheckTrue(Half.GetType <> nil);
end;

procedure TTestHalf.Test_GreaterThanOrEqual_Half_Half;
begin
  CheckTrue(Half(10) >= Half(10));
  CheckTrue(Half(20) >= Half(10));
  CheckTrue(Half(10) >= Half(-10));
  CheckTrue(Half(-0) >= Half(0));
end;

procedure TTestHalf.Test_GreaterThanOrEqual_Half_Single;
begin
  CheckTrue(Half(10) >= 10);
  CheckTrue(Half(20) >= 10);
  CheckTrue(Half(10) >= -10);
  CheckTrue(Half(-0) >= 0);
end;

procedure TTestHalf.Test_GreaterThanOrEqual_Single_Half;
begin
  CheckTrue(10 >= Half(10));
  CheckTrue(20 >= Half(10));
  CheckTrue(10 >= Half(-10));
  CheckTrue(-0 >= Half(0));
end;

procedure TTestHalf.Test_GreaterThan_Half_Half;
begin
  CheckFalse(Half(10) > Half(10));
  CheckTrue(Half(20) > Half(10));
  CheckTrue(Half(10) > Half(-10));
  CheckFalse(Half(-0) > Half(0));
end;

procedure TTestHalf.Test_GreaterThan_Half_Single;
begin
  CheckFalse(Half(10) > 10);
  CheckTrue(Half(20) > 10);
  CheckTrue(Half(10) > -10);
  CheckFalse(Half(-0) > 0);
end;

procedure TTestHalf.Test_GreaterThan_Single_Half;
begin
  CheckFalse(10 > Half(10));
  CheckTrue(20 > Half(10));
  CheckTrue(10 > Half(-10));
  CheckFalse(-0 > Half(0));
end;

procedure TTestHalf.Test_Implicit_Half_Single;
begin
  FHalf := 0;
  CheckEquals(0, Single(FHalf));

  FHalf := 100;
  CheckEquals(100, Single(FHalf));

  FHalf := -10.54;
  CheckTrue(Abs(-10.54 - Single(FHalf)) < 0.01);
end;

procedure TTestHalf.Test_Implicit_Half_Variant;
var
  V: Variant;
begin
  V := Half(0);
  CheckTrue(CompareValue(Single(V), 0) = 0);

  V := Half(100);
  CheckTrue(CompareValue(Single(V), 100) = 0);

  V := Half(-10.54);
  CheckTrue(Abs(-10.54 - Single(V)) < 0.01);
end;

procedure TTestHalf.Test_Implicit_Single_Half;
begin
  FHalf := 0;
  CheckEquals(0, FWord);

  FHalf := 100;
  CheckEquals(22080, FWord);

  FHalf := -10.54;
  CheckEquals(51525, FWord);
end;

procedure TTestHalf.Test_Implicit_Variant_Half;
begin
  FHalf := Variant(0);
  CheckEquals(0, FWord);

  FHalf := Variant(100);
  CheckEquals(22080, FWord);

  FHalf := Variant(-10.54);
  CheckEquals(51525, FWord);
end;

procedure TTestHalf.Test_Infinity;
begin
  FHalf := Half.Infinity;
  CheckEquals(31743, FWord);
end;

procedure TTestHalf.Test_LessThanOrEqual_Half_Half;
begin
  CheckTrue(Half(10) <= Half(10));
  CheckFalse(Half(20) <= Half(10));
  CheckFalse(Half(10) <= Half(-10));
  CheckTrue(Half(-0) <= Half(0));
end;

procedure TTestHalf.Test_LessThanOrEqual_Half_Single;
begin
  CheckTrue(Half(10) <= 10);
  CheckFalse(Half(20) <= 10);
  CheckFalse(Half(10) <= -10);
  CheckTrue(Half(-0) <= 0);
end;

procedure TTestHalf.Test_LessThanOrEqual_Single_Half;
begin
  CheckTrue(10 <= Half(10));
  CheckFalse(20 <= Half(10));
  CheckFalse(10 <= Half(-10));
  CheckTrue(-0 <= Half(0));
end;

procedure TTestHalf.Test_LessThan_Half_Half;
begin
  CheckFalse(Half(10) < Half(10));
  CheckTrue(Half(-3) < Half(0));
  CheckFalse(Half(20) < Half(10));
  CheckFalse(Half(10) < Half(-10));
  CheckFalse(Half(-0) < Half(0));
end;

procedure TTestHalf.Test_LessThan_Half_Single;
begin
  CheckFalse(Half(10) < 10);
  CheckTrue(Half(-3) < 0);
  CheckFalse(Half(20) < 10);
  CheckFalse(Half(10) < -10);
  CheckFalse(Half(-0) < 0);
end;

procedure TTestHalf.Test_LessThan_Single_Half;
begin
  CheckFalse(10 < Half(10));
  CheckTrue(-3 < Half(0));
  CheckFalse(20 < Half(10));
  CheckFalse(10 < Half(-10));
  CheckFalse(-0 < Half(0));
end;

procedure TTestHalf.Test_Max;
begin
  FHalf := Half.Max;
  CheckEquals(31743, FWord);
end;

procedure TTestHalf.Test_Min;
begin
  FHalf := Half.Min;
  CheckEquals(1024, FWord);
end;

procedure TTestHalf.Test_Multiply_Half_Half;
begin
  FHalf := Half(3) * Half(0.1);
  CheckEquals(13516, FWord);
end;

procedure TTestHalf.Test_Multiply_Half_Single;
begin
  FHalf := Half(3) * 0.1;
  CheckEquals(13516, FWord);
end;

procedure TTestHalf.Test_Multiply_Single_Half;
begin
  FHalf := 3 * Half(0.1);
  CheckEquals(13516, FWord);
end;

procedure TTestHalf.Test_Negative;
begin
  FHalf := -Half(4.55);
  CheckEquals(50316, FWord);
end;

procedure TTestHalf.Test_MinusInfinity;
begin
  FHalf := Half.MinusInfinity;
  CheckEquals(64512, FWord);
end;

procedure TTestHalf.Test_MinusOne;
begin
  FHalf := Half.MinusOne;
  CheckEquals($BC00, FWord);
end;

procedure TTestHalf.Test_MinusTen;
begin
  FHalf := Half.MinusTen;
  CheckEquals($4900, FWord);
end;

procedure TTestHalf.Test_MinusZero;
begin
  FHalf := Half.MinusZero;
  CheckEquals(32768, FWord);
end;

procedure TTestHalf.Test_NotEqual_Half_Half;
begin
  CheckFalse(Half(10) <> Half(10));
  CheckTrue(Half(10) <> Half(-10));
end;

procedure TTestHalf.Test_NotEqual_Half_Single;
begin
  CheckFalse(Half(10) <> 10);
  CheckTrue(Half(10) <> -10);
end;

procedure TTestHalf.Test_NotEqual_Single_Half;
begin
  CheckFalse(10 <> Half(10));
  CheckTrue(10 <> Half(-10));
end;

procedure TTestHalf.Test_One;
begin
  FHalf := Half.One;
  CheckEquals($3C00, FWord);
end;

procedure TTestHalf.Test_Positive;
begin
  FHalf := +Half(4.55);
  CheckEquals(17548, FWord);
end;

procedure TTestHalf.Test_Subtract_Half_Half;
begin
  FHalf := Half(1) - Half(2.3);
  CheckEquals(48434, FWord);
end;

procedure TTestHalf.Test_Subtract_Half_Single;
begin
  FHalf := Half(1) - 2.3;
  CheckEquals(48434, FWord);
end;

procedure TTestHalf.Test_Subtract_Single_Half;
begin
  FHalf := 1 - Half(2.3);
  CheckEquals(48434, FWord);
end;

procedure TTestHalf.Test_Ten;
begin
  FHalf := Half.Ten;
  CheckEquals($C900, FWord);
end;

procedure TTestHalf.Test_TypeSupport;
var
  Support: IType<Half>;
  X, Y: Half;
begin
  Support := TType<Half>.Default;

  X := 10.45;
  Y := 10;

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

  Check(Support.GetString(X) = '10' + DecimalSeparator + '4453125', 'Expected Support.GetString(X) = "10.4453125"');
  Check(Support.GetString(Y) = '10', 'Expected Support.GetString(Y) = "10"');

  Check(Support.Name = 'Half', 'Type Name = "Half"');
  Check(Support.Size = SizeOf(Half), 'Type Size = SizeOf(Half)');
  Check(Support.TypeInfo = TypeInfo(Half), 'Type information provider failed!');
  Check(Support.Family = tfReal, 'Type Family = tfReal');

  Check(Support.Management() = tmNone, 'Type support = tmNone');
end;

procedure TTestHalf.Test_Zero;
begin
  FHalf := Half.Zero;
  CheckEquals(0, FWord);
end;

initialization
  TestFramework.RegisterTest(TTestHalf.Suite);

end.
