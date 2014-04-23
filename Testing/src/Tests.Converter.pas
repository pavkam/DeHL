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
unit Tests.Converter;
interface
uses SysUtils, Variants, Math,
     Character,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Conversion,
     DeHL.Box,
     DeHL.Math.BigCardinal,
     DeHL.Math.BigInteger,
     DeHL.DateTime;

type
  TTestConverter = class(TDeHLTestCase)
  published
    procedure TestTConverter;
    procedure TestClone;
    procedure TestClone2;
    procedure Test_Case_0();
    procedure Test_Case_1();
    procedure Test_Case_2_ClassClass();
    procedure Test_Case_2_ClassIntf();
    procedure Test_Case_2_ClassRefClassRef();
    procedure Test_Case_2_IntfIntf();
    procedure Test_Case_3();
    procedure Test_Case_4();
    procedure Test_Case_5_0();
    procedure Test_Case_5_1();
    procedure Test_Case_6();
    procedure Test_Case_7();
    procedure Test_Method();
  end;

implementation


{ TTestConverter }

procedure TTestConverter.TestClone;
var
  LConv, LCopy: TConverter<Integer, Integer>;
begin
  LConv := TConverter<Integer, Integer>.Create();
  LCopy := LConv.Clone as TConverter<Integer, Integer>;

  CheckEquals(1, LCopy.Convert(1), 'Types not copied properly');
  CheckEquals(-1, LCopy.Convert(-1), 'Types not copied properly');

  LConv.Free;
  LCopy.Free;
end;

procedure TTestConverter.TestClone2;
var
  LConv, LCopy: TConverter<string, string>;
  LIntf: IType<string>;
begin
  LIntf := TExType<string>.Create();
  LConv := TConverter<string, string>.Create(LIntf, TType<string>.Default);
  LCopy := LConv.Clone as TConverter<string, string>;

  CheckEquals('>>1', LCopy.Convert('1'), 'From type not copied properly');

  LConv.Free;
  LCopy.Free;
end;

procedure TTestConverter.TestTConverter;
var
  ConvIS: IConverter<Integer, String>;
  ConvBI: IConverter<Boolean, Integer>;
  ConvDD: IConverter<Double, Double>;

  DoubleConst: Double;
begin
  { Test ctors }
  CheckException(ENilArgumentException, procedure begin
    TConverter<Integer, Integer>.Create(nil, TType<Integer>.Default);
  end, 'ENilArgumentException not thrown in Create (nil type 1)');

  CheckException(ENilArgumentException, procedure begin
    TConverter<Integer, Integer>.Create(TType<Integer>.Default, nil);
  end, 'ENilArgumentException not thrown in Create (nil type 2)');


  { Set up all converters }
  ConvIS := TConverter<Integer, String>.Create(TType<Integer>.Default, TType<String>.Default);
  ConvBI := TConverter<Boolean, Integer>.Create();
  ConvDD := TConverter<Double, Double>.Create();

  { Int/String }
  Check(ConvIS.Convert(1) = '1', '(Int/Str) Expected conversion to be equal to "1"');
  Check(ConvIS.Convert(-78) = '-78', '(Int/Str) Expected conversion to be equal to "-78"');
  Check(ConvIS.Convert(0) = '0', '(Int/Str) Expected conversion to be equal to "0"');

  { Boolean/Int }
  Check(ConvBI.Convert(true) <> 0, '(Bool/Int) Expected conversion to not be equal to "0"');
  Check(ConvBI.Convert(false) = 0, '(Bool/Int) Expected conversion to be equal to "0"');

  { Double/Double }
  DoubleConst := 1;
  Check(ConvDD.Convert(DoubleConst)= DoubleConst, '(Double/Double) Expected conversion to not be equal to "1"');

  DoubleConst := 1.1;
  Check(ConvDD.Convert(DoubleConst) = DoubleConst, '(Double/Double) Expected conversion to be equal to "1.1"');

  DoubleConst := -4.155555;
  Check(ConvDD.Convert(DoubleConst) = DoubleConst, '(Double/Double) Expected conversion to be equal to "-4.155555"');
end;

procedure TTestConverter.Test_Case_0;
var
  LConv: IConverter<Integer, Integer>;
begin
  LConv := TConverter<Integer, Integer>.Create;

  CheckEquals(MaxInt, LConv.Convert(MaxInt), 'Case 0/0');
  CheckEquals(0, LConv.Convert(0), 'Case 0/0');
  CheckEquals(-1, LConv.Convert(-1), 'Case 0/0');
end;

procedure TTestConverter.Test_Case_1;
var
  LConv: IConverter<Byte, UInt64>;
begin
  LConv := TConverter<Byte, UInt64>.Create;

  CheckEquals(0, LConv.Convert(0), 'Case 1');
  CheckEquals(255, LConv.Convert(255), 'Case 1');
end;

procedure TTestConverter.Test_Case_2_ClassClass;
var
  LConv: IConverter<TObject, TInterfacedObject>;
  LObj: TObject;
  LRes: TInterfacedObject;
begin
  LConv := TConverter<TObject, TInterfacedObject>.Create;

  LObj := TObject.Create;
    CheckFalse(LConv.TryConvert(LObj, LRes), 'Case 2/0 (f)');
  LObj.Free;

  LObj := TInterfacedObject.Create;
    CheckTrue(LConv.TryConvert(LObj, LRes), 'Case 2/0 (f)');
    CheckTrue(LObj = LRes, 'Case 2 (r)');
  LObj.Free;

  LObj := TRefCountedObject.Create;
    CheckTrue(LConv.TryConvert(LObj, LRes), 'Case 2/0 (f)');
    CheckTrue(LObj = LRes, 'Case 2 (r)');
  LObj.Free;
end;

procedure TTestConverter.Test_Case_2_ClassIntf;
var
  LConv: IConverter<TObject, IInterface>;
  LObj: TObject;
  LRes: IInterface;
begin
  LConv := TConverter<TObject, IInterface>.Create;

  LObj := TObject.Create;
    CheckFalse(LConv.TryConvert(LObj, LRes), 'Case 2/1 (f)');
  LObj.Free;

  LObj := TInterfacedObject.Create;
    CheckTrue(LConv.TryConvert(LObj, LRes), 'Case 2/1 (f)');
    CheckTrue((LRes as TInterfacedObject) = LObj, 'Case 2/1 (r)');
end;

procedure TTestConverter.Test_Case_2_ClassRefClassRef;
var
  LConv: IConverter<TClass, TInterfacedClass>;
  LObj: TClass;
  LRes: TInterfacedClass;
begin
  LConv := TConverter<TClass, TInterfacedClass>.Create;

  LObj := TObject;
    CheckFalse(LConv.TryConvert(LObj, LRes), 'Case 2/2 (f)');

  LObj := TInterfacedObject;
    CheckTrue(LConv.TryConvert(LObj, LRes), 'Case 2/2 (f)');
    CheckTrue(LRes = LObj, 'Case 2/2 (r)');

  LObj := TRefCountedObject;
    CheckTrue(LConv.TryConvert(LObj, LRes), 'Case 2/2 (f)');
    CheckTrue(LObj = LRes, 'Case 2/2 (r)');
end;

type
  IMyCoolIntf = interface
    ['{075828A0-9F21-4905-A7C6-5163D7BB5341}']
  end;

  TMyCoolObj = class(TInterfacedObject, IMyCoolIntf);

procedure TTestConverter.Test_Case_2_IntfIntf;
var
  LConv: IConverter<IInterface, IMyCoolIntf>;
  LObj: IInterface;
  LRes: IMyCoolIntf;
begin
  LConv := TConverter<IInterface, IMyCoolIntf>.Create;

  LObj := TInterfacedObject.Create;
    CheckFalse(LConv.TryConvert(LObj, LRes), 'Case 2/3 (f)');

  LObj := TMyCoolObj.Create;
    CheckTrue(LConv.TryConvert(LObj, LRes), 'Case 2/3 (f)');
    CheckTrue((LRes as TMyCoolObj) = (LRes as TMyCoolObj), 'Case 2/3 (r)');
end;

type
  TMySpecialInt0 = type Integer;
  TMySpecialInt1 = type Integer;
  TMySpecialByte0 = type Byte;

procedure TTestConverter.Test_Case_3;
var
  LConv: IConverter<TMySpecialInt0, Int64>;
begin
  LConv := TConverter<TMySpecialInt0, Int64>.Create;

  CheckEquals(MaxInt, LConv.Convert(MaxInt), 'Case 3');
  CheckEquals(0, LConv.Convert(0), 'Case 3');
end;

procedure TTestConverter.Test_Case_4;
var
  LConv: IConverter<Byte, TMySpecialInt0>;
begin
  LConv := TConverter<Byte, TMySpecialInt0>.Create;

  CheckEquals(255, LConv.Convert(255), 'Case 4');
  CheckEquals(0, LConv.Convert(0), 'Case 4');
end;

procedure TTestConverter.Test_Case_5_0;
var
  LConv: IConverter<TMySpecialInt0, TMySpecialInt1>;
begin
  LConv := TConverter<TMySpecialInt0, TMySpecialInt1>.Create;

  CheckEquals(MaxInt, LConv.Convert(MaxInt), 'Case 5/0');
  CheckEquals(0, LConv.Convert(0), 'Case 5/0');
  CheckEquals(-1, LConv.Convert(-1), 'Case 5/0');
end;

procedure TTestConverter.Test_Case_5_1;
var
  LConv: IConverter<TMySpecialByte0, TMySpecialInt1>;
begin
  LConv := TConverter<TMySpecialByte0, TMySpecialInt1>.Create;

  CheckEquals(255, LConv.Convert(255), 'Case 5/1');
  CheckEquals(0, LConv.Convert(0), 'Case 5/1');
end;

procedure TTestConverter.Test_Case_6;
var
  LConv: IConverter<TMySpecialByte0, Variant>;
begin
  LConv := TConverter<TMySpecialByte0, Variant>.Create;

  CheckEquals(255, LConv.Convert(255), 'Case 6');
  CheckEquals(0, LConv.Convert(0), 'Case 6');
end;

procedure TTestConverter.Test_Case_7;
var
  LConv: IConverter<Variant, TMySpecialByte0>;
begin
  LConv := TConverter<Variant, TMySpecialByte0>.Create;

  CheckEquals(255, LConv.Convert(255), 'Case 7');
  CheckEquals(0, LConv.Convert(0), 'Case 7');
end;

function AsIntf(const AAnonMethod): IInterface;
begin
  Pointer(Result) := Pointer(AAnonMethod);
end;

type
  TXAnon = class(TInterfacedObject, TConvertProc<TMySpecialInt0, TMySpecialInt1>)
  public
    function Invoke(const AIn: TMySpecialInt0; out AOut: TMySpecialInt1): Boolean;
  end;

{ TXAnon }

function TXAnon.Invoke(const AIn: TMySpecialInt0; out AOut: TMySpecialInt1): Boolean;
begin
  AOut := AIn + 1;
  Exit(true);
end;


procedure TTestConverter.Test_Method;
var
  LConv: IConverter<TMySpecialInt0, TMySpecialInt1>;
  LMethod, LMethodOf: TConvertProc<TMySpecialInt0, TMySpecialInt1>;
  LAnon: TXAnon;
begin
  { Check the initial = nil }
  CheckTrue(TConverter<TMySpecialInt0, TMySpecialInt1>.Method = nil, 'Expected NIL for (sp0, sp1)');

  { Use a sentinel interface to check if the anon method lives or dies }
  LAnon := TXAnon.Create();
  LMethod := LAnon;

  { Register a converter }
  TConverter<TMySpecialInt0, TMySpecialInt1>.Method := LMethod;
  CheckEquals(2, LAnon.RefCount, 'LMethod ref count <> 2!');

  { Check the initial <> nil }
  LMethodOf := TConverter<TMySpecialInt0, TMySpecialInt1>.Method;
  CheckTrue(AsIntf(LMethodOf) = AsIntf(LMethod), 'Expected LMethod for (sp0, sp1)');
  LMethod := nil; // Kill local ref (-1)
  LMethodOf := nil;

  CheckEquals(1, LAnon.RefCount, 'LMethod was destroyed!');

  { Test our new converter }
  LConv := TConverter<TMySpecialInt0, TMySpecialInt1>.Create;
  CheckEquals(255, LConv.Convert(254), '+1 failed');
  CheckEquals(1, LConv.Convert(0), '+1 failed');

  { Now let's release the converter }
  TConverter<TMySpecialInt0, TMySpecialInt1>.Method := nil;
  CheckTrue(TConverter<TMySpecialInt0, TMySpecialInt1>.Method = nil, 'Expected NIL for (sp0, sp1)');
  CheckEquals(1, LAnon.RefCount, 'LMethod was not destroyed!');

  { Re-Test the converter }
  LConv := TConverter<TMySpecialInt0, TMySpecialInt1>.Create;
  CheckEquals(254, LConv.Convert(254), '=0 failed');
  CheckEquals(0, LConv.Convert(0), '=0 failed');
end;


initialization
  TestFramework.RegisterTest(TTestConverter.Suite);

end.
