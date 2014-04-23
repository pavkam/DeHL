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
unit Tests.TypeSupport;
interface
uses SysUtils,
     Generics.Defaults,
     Variants,
     DateUtils,
     Character,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types;

type
  TTestTypes = class(TDeHLTestCase)
  protected
    FOldSep: Char;
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestByte;
    procedure TestShortInt;
    procedure TestWord;
    procedure TestSmallInt;
    procedure TestCardinal;
    procedure TestInteger;
    procedure TestUInt64;
    procedure TestInt64;
    procedure TestNativeInt;
    procedure TestNativeUInt;

    procedure TestBoolean;
    procedure TestByteBool;
    procedure TestWordBool;
    procedure TestLongBool;

    procedure TestSysDate;
    procedure TestSysTime;
    procedure TestSysDateTime;

    procedure TestSingle;
    procedure TestDouble;
    procedure TestReal;
    procedure TestExtended;
    procedure TestComp;
    procedure TestCurrency;

    procedure TestShortString;
    procedure TestAnsiString;
    procedure TestWideString;
    procedure TestUnicodeString;
    procedure TestUTF8String;
    procedure TestUCS4String;

    procedure TestInsShortString;
    procedure TestInsAnsiString;
    procedure TestInsWideString;
    procedure TestInsUnicodeString;
    procedure TestInsUTF8String;
    procedure TestInsUCS4String;

    procedure TestAnsiChar;
    procedure TestWideChar;
    procedure TestChar;
    procedure TestUCS4Char;

    procedure TestInterface;
    procedure TestVariant;
    procedure TestOleVariant;
    procedure TestClassRef;
    procedure TestClass_Cleanup;
    procedure TestClass_NoCleanup;

    procedure TestPointer;

    procedure TestRecord;
    procedure TestRecord_With_RTTI;
    procedure TestDynArray;
    procedure TestRawByteString;
    procedure TestStaticArray;
    procedure TestStaticArray_With_RTTI;
    procedure TestEnumeration;
    procedure TestSet;

    procedure TestRoutine;
    procedure TestAnonymousMethod;
    procedure TestMethod;

    { Other tests }
    procedure TestAsComparer;
    procedure TestAsEqualityComparer;

    procedure TestStandardAccessor;
    procedure TestWrapper0;
    procedure TestWrapper1;
    procedure TestWrapper2;
    procedure TestDefaultRestriction;
    procedure TestCustomTypeRegistration;
    procedure TestExtenders;
    procedure TestTypeClassInheritance;
    procedure TestTypeCaching;

    procedure TestDefault_Comparer;
    procedure TestDefault_Comparer_Restriction;
    procedure TestStandard_Comparer;
    procedure TestStandard_Comparer_Restriction;
  end;

type
  MyInt = type Integer;
  NoRTTIType = array[0..1] of Byte;

  TMyCustomType = class(TType<MyInt>)
    function Compare(const AValue1, AValue2: MyInt): NativeInt; override;
    function GenerateHashCode(const AValue: MyInt): NativeInt; override;
    function GetString(const AValue: MyInt): String; override;
    function Family(): TTypeFamily; override;
    function TryConvertToVariant(const AValue: MyInt; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: MyInt): Boolean; override;
  end;

  TMyClass = class
  end;

  TMySecondClass = class(TMyClass)
  end;

  TMyThirdClass = class(TMySecondClass)
  end;

  TMyCustomClassType = class(TType<TMyClass>)
    function GetString(const AValue: TMyClass): String; override;
  end;

  TMyExtension = class(TTypeExtension)
  end;

  TYourExtension = class(TTypeExtension)
  end;


implementation

type
  TTestObj = class(TObject)
    FInt : Integer;

    function GetHashCode() : Integer; override;
    function Equals(Obj : TObject) : Boolean; override;
    function ToString() : String; override;

    constructor Create(X : Integer);
  end;


{ TTestObj }

constructor TTestObj.Create;
begin
  FInt := X;
end;

function TTestObj.Equals(Obj: TObject): Boolean;
begin
  Result := (Obj as TTestObj).FInt = FInt;
end;

function TTestObj.GetHashCode: Integer;
begin
  Result := FInt;
end;


function TTestObj.ToString: String;
begin
 Result := IntToStr(FInt);
end;

{ TTestTypes }

procedure TTestTypes.SetUp;
begin
  inherited;

  { Set the new float separator }
  FOldSep := DecimalSeparator;
  DecimalSeparator := '.';
end;

procedure TTestTypes.TearDown;
begin
  inherited;

  { Set the old float separator }
  DecimalSeparator := FOldSep;
end;

procedure TTestTypes.TestAnonymousMethod;
var
  DefaultSupport: IType<TProc>;
  Proc1, Proc2: TProc;
begin
  DefaultSupport := TType<TProc>.Default;

  Proc2 := procedure begin end;
  Proc1 := procedure begin end;

  { Default }
  Check(DefaultSupport.Compare(Proc1, Proc2) <> 0, '(Default) Expected v1 <> v2');

  Check(DefaultSupport.AreEqual(Proc2, Proc2), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(Proc1, Proc2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(Proc2) <> DefaultSupport.GenerateHashCode(Proc1), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(Proc1) = DefaultSupport.GenerateHashCode(Proc1), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'TProc', 'Type Name = "TProc"');
  Check(DefaultSupport.Size = SizeOf(TProc), 'Type Size = SizeOf(TProcedure)');
  Check(DefaultSupport.TypeInfo = TypeInfo(TProc), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfInterface, 'Type Family = tfInterface');

  Check(Pos('(Reference: 0x', DefaultSupport.GetString(Proc1)) = 1, '(Default) Expected GetString() = "(Reference: 0xXXXXXXXX)"');
end;

procedure TTestTypes.TestAnsiChar;
var
  DefaultSupport : IType<AnsiChar>;
  V              : AnsiChar;
begin
  DefaultSupport := TType<AnsiChar>.Default;

  { Default }
  Check(DefaultSupport.Compare('A', 'B') < 0, '(Default) Expected A < B');
  Check(DefaultSupport.Compare('B', 'A') > 0, '(Default) Expected B > A');
  Check(DefaultSupport.Compare('A', 'A') = 0, '(Default) Expected A = A');
  Check(DefaultSupport.Compare('a', 'A') > 0, '(Default) Expected a > A');

  Check(DefaultSupport.AreEqual('a', 'a'), '(Default) Expected a eq a');
  Check(not DefaultSupport.AreEqual('c', 'C'), '(Default) Expected c neq C');

  Check(DefaultSupport.GenerateHashCode('A') <> DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode A neq a');
  Check(DefaultSupport.GenerateHashCode('a') = DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode a eq a');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'AnsiChar', 'Type Name = "AnsiChar"');
  Check(DefaultSupport.Size = 1, 'Type Size = 1');
  Check(DefaultSupport.TypeInfo = TypeInfo(AnsiChar), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfCharacter, 'Type Family = tfCharacter');

  V := 'H';
  Check(DefaultSupport.GetString(V) = 'H', '(Default) Expected GetString() = "H"');
end;

procedure TTestTypes.TestAnsiString;
var
  DefaultSupport : IType<AnsiString>;
  V              : AnsiString;
begin
  DefaultSupport := TType<AnsiString>.Default;

  { Default }
  Check(DefaultSupport.Compare('AA', 'AB') < 0, '(Default) Expected AA < AB');
  Check(DefaultSupport.Compare('AB', 'AA') > 0, '(Default) Expected AB > AA');
  Check(DefaultSupport.Compare('AA', 'AA') = 0, '(Default) Expected AA = AA');

  Check(DefaultSupport.AreEqual('abc', 'abc'), '(Default) Expected abc eq abc');
  Check(not DefaultSupport.AreEqual('abc', 'ABC'), '(Default) Expected abc neq ABC');

  Check(DefaultSupport.GenerateHashCode('ABC') <> DefaultSupport.GenerateHashCode('abc'), '(Default) Expected hashcode ABC neq abc');
  Check(DefaultSupport.GenerateHashCode('abcd') = DefaultSupport.GenerateHashCode('abcd'), '(Default) Expected hashcode abcd eq abcd');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'AnsiString', 'Type Name = "AnsiString"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(AnsiString), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestAsComparer;
var
  LComparer: IComparer<Integer>;
begin
  LComparer := TType<Integer>.Default.AsComparer;

  CheckTrue(LComparer <> nil, '(LComparer) is nil');
  Check(LComparer.Compare(-1, 1) < 0, '(LComparer) Expected -1 < 1');
  Check(LComparer.Compare(1, -1) > 0, '(LComparer) Expected 1 > -1');
  Check(LComparer.Compare(-1, -1) = 0, '(LComparer) Expected -1 = -1');
end;

procedure TTestTypes.TestAsEqualityComparer;
var
  LComparer: IEqualityComparer<Integer>;
begin
  LComparer := TType<Integer>.Default.AsEqualityComparer;

  Check(LComparer.Equals(1, 1), '(LComparer) Expected 1 eq 1');
  Check(not LComparer.Equals(-1, 1), '(LComparer) Expected -1 neq 1');
  Check(LComparer.GetHashCode(-1) <> LComparer.GetHashCode(1), '(LComparer) Expected hashcode -1 neq 1');
  Check(LComparer.GetHashCode(1) = LComparer.GetHashCode(1), '(LComparer) Expected hashcode 1 eq 1');
end;

procedure TTestTypes.TestClassRef;
var
  DefaultSupport: IType<TClass>;
begin
  DefaultSupport := TType<TClass>.Default;

  { Default }
  Check(DefaultSupport.Compare(TTestTypes, TTestTypes) = 0, '(Default) Expected v1 = v1');
  Check(DefaultSupport.Compare(TTestTypes, TMySecondClass) <> 0, '(Default) Expected v1 <> v2');

  Check(DefaultSupport.AreEqual(TTestTypes, TTestTypes), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(TTestTypes, TMySecondClass), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(TTestTypes) <> DefaultSupport.GenerateHashCode(TMySecondClass), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(TTestTypes) = DefaultSupport.GenerateHashCode(TTestTypes), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Size = SizeOf(TClass), 'Type Size = SizeOf(TProcedure)');

  Check(DefaultSupport.TypeInfo = TypeInfo(TClass), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfClassReference, 'Type Family = tfClassReference');
  Check(DefaultSupport.Name = 'TClass', 'Type Name = "TClass"');
  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.GetString(TTestTypes) = 'TTestTypes', '(Default) Expected GetString() = "TTestTypes"');
end;

procedure TTestTypes.TestClass_Cleanup;
var
  DefaultSupport : IClassType<TTestObj>;
  Obj1, Obj2, V  : TTestObj;
begin
  Obj1 := TTestObj.Create(-1);
  Obj2 := TTestObj.Create(1);

  DefaultSupport := TClassType<TTestObj>.Create(true);

  { Default }
  Check(DefaultSupport.Compare(nil, nil) = 0, '(Default) Expected nil = nil');
  Check(DefaultSupport.Compare(Obj1, nil) > 0, '(Default) Expected Obj1 > nil');
  Check(DefaultSupport.Compare(nil, Obj1) < 0, '(Default) Expected nil < Obj1');

  Check(DefaultSupport.AreEqual(nil, nil), '(Default) Expected nil eq nil');
  Check(not DefaultSupport.AreEqual(Obj1, nil), '(Default) Expected Obj1 neq nil');
  Check(not DefaultSupport.AreEqual(nil, Obj1), '(Default) Expected nil neq Obj1');

  Check(DefaultSupport.Compare(Obj1, Obj1) = 0, '(Default) Expected Obj1 = Obj1');
  Check(DefaultSupport.Compare(Obj1, Obj2) <> 0, '(Default) Expected Obj1 <> Obj1');

  Check(DefaultSupport.AreEqual(Obj1, Obj1), '(Default) Expected Obj1 eq Obj1');
  Check(not DefaultSupport.AreEqual(Obj1, Obj2), '(Default) Expected Obj1 neq Obj2');

  Check(DefaultSupport.GenerateHashCode(Obj1) <> DefaultSupport.GenerateHashCode(Obj2), '(Default) Expected hashcode Obj1 neq Obj2');
  Check(DefaultSupport.GenerateHashCode(Obj1) = DefaultSupport.GenerateHashCode(Obj1), '(Default) Expected hashcode Obj1 eq Obj1');

  Check(DefaultSupport.Management() = tmManual, 'Type support = tmManual');

  Check(DefaultSupport.Name = 'TTestObj', 'Type Name = "TTestObj"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(TTestObj), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfClass, 'Type Family = tfClass');

  Obj1.Free;
  Obj2.Free;

  V := TTestObj.Create(101);
  Check(DefaultSupport.GetString(V) = '101', '(Default) Expected GetString() = "101"');

  Check(DefaultSupport.GetString(nil) = '', '(Default) Expected GetString(nil) = ""');

  V.Free;

  { Check cleanup toggle }
  DefaultSupport.SetShouldCleanup(false);
  Check(DefaultSupport.Management() = tmNone, 'Type (toggled) support = tmNone');
end;

procedure TTestTypes.TestClass_NoCleanup;
var
  DefaultSupport : IType<TTestObj>;
  Obj1, Obj2, V  : TTestObj;
begin
  Obj1 := TTestObj.Create(-1);
  Obj2 := TTestObj.Create(1);

  DefaultSupport := TType<TTestObj>.Default;

  { Default }
  Check(DefaultSupport.Compare(nil, nil) = 0, '(Default) Expected nil = nil');
  Check(DefaultSupport.Compare(Obj1, nil) > 0, '(Default) Expected Obj1 > nil');
  Check(DefaultSupport.Compare(nil, Obj1) < 0, '(Default) Expected nil < Obj1');

  Check(DefaultSupport.AreEqual(nil, nil), '(Default) Expected nil eq nil');
  Check(not DefaultSupport.AreEqual(Obj1, nil), '(Default) Expected Obj1 neq nil');
  Check(not DefaultSupport.AreEqual(nil, Obj1), '(Default) Expected nil neq Obj1');


  Check(DefaultSupport.Compare(Obj1, Obj1) = 0, '(Default) Expected Obj1 = Obj1');
  Check(DefaultSupport.Compare(Obj1, Obj2) <> 0, '(Default) Expected Obj1 <> Obj1');

  Check(DefaultSupport.AreEqual(Obj1, Obj1), '(Default) Expected Obj1 eq Obj1');
  Check(not DefaultSupport.AreEqual(Obj1, Obj2), '(Default) Expected Obj1 neq Obj2');

  Check(DefaultSupport.GenerateHashCode(Obj1) <> DefaultSupport.GenerateHashCode(Obj2), '(Default) Expected hashcode Obj1 neq Obj2');
  Check(DefaultSupport.GenerateHashCode(Obj1) = DefaultSupport.GenerateHashCode(Obj1), '(Default) Expected hashcode Obj1 eq Obj1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'TTestObj', 'Type Name = "TTestObj"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(TTestObj), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfClass, 'Type Family = tfClass');

  Obj1.Free;
  Obj2.Free;

  V := TTestObj.Create(101);
  Check(DefaultSupport.GetString(V) = '101', '(Default) Expected GetString() = "101"');

  Check(DefaultSupport.GetString(nil) = '', '(Default) Expected GetString(nil) = ""');

  V.Free;
end;

procedure TTestTypes.TestBoolean;
var
  DefaultSupport : IType<Boolean>;
begin
  DefaultSupport := TType<Boolean>.Default;

  { Default }
  Check(DefaultSupport.Compare(false, true) < 0, '(Default) Expected false < true');
  Check(DefaultSupport.Compare(true, false) > 0, '(Default) Expected true > false');
  Check(DefaultSupport.Compare(true, true) = 0, '(Default) Expected true = true');

  Check(DefaultSupport.AreEqual(false, false), '(Default) Expected false eq false');
  Check(not DefaultSupport.AreEqual(false, true), '(Default) Expected false neq true');

  Check(DefaultSupport.GenerateHashCode(false) <> DefaultSupport.GenerateHashCode(true), '(Default) Expected hashcode false neq true');
  Check(DefaultSupport.GenerateHashCode(false) = DefaultSupport.GenerateHashCode(false), '(Default) Expected hashcode false eq false');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Boolean', 'Type Name = "Boolean"');
  Check(DefaultSupport.Size = 1, 'Type Size = 1');
  Check(DefaultSupport.TypeInfo = TypeInfo(Boolean), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfBoolean, 'Type Family = tfBoolean');

  Check(DefaultSupport.GetString(true) = 'True', '(Default) Expected GetString() = "True"');
end;

procedure TTestTypes.TestByte;
var
  DefaultSupport : IType<Byte>;
begin
  DefaultSupport := TType<Byte>.Default;

  { Default }
  Check(DefaultSupport.Compare(1, 2) < 0, '(Default) Expected 1 < 2');
  Check(DefaultSupport.Compare(2, 1) > 0, '(Default) Expected 2 > 1');
  Check(DefaultSupport.Compare(2, 2) = 0, '(Default) Expected 2 = 2');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(1, 2), '(Default) Expected 1 neq 2');

  Check(DefaultSupport.GenerateHashCode(1) <> DefaultSupport.GenerateHashCode(2), '(Default) Expected hashcode 1 neq 2');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Byte', 'Type Name = "Byte"');
  Check(DefaultSupport.Size = 1, 'Type Size = 1');
  Check(DefaultSupport.TypeInfo = TypeInfo(Byte), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  Check(DefaultSupport.GetString(2) = '2', '(Default) Expected GetString() = "2"');
end;

procedure TTestTypes.TestByteBool;
var
  DefaultSupport : IType<ByteBool>;
begin
  DefaultSupport := TType<ByteBool>.Default;

  { Default }
  Check(DefaultSupport.Compare(false, true) < 0, '(Default) Expected false < true');
  Check(DefaultSupport.Compare(true, false) > 0, '(Default) Expected true > false');
  Check(DefaultSupport.Compare(true, true) = 0, '(Default) Expected true = true');

  Check(DefaultSupport.AreEqual(false, false), '(Default) Expected false eq false');
  Check(not DefaultSupport.AreEqual(false, true), '(Default) Expected false neq true');

  Check(DefaultSupport.GenerateHashCode(false) <> DefaultSupport.GenerateHashCode(true), '(Default) Expected hashcode false neq true');
  Check(DefaultSupport.GenerateHashCode(false) = DefaultSupport.GenerateHashCode(false), '(Default) Expected hashcode false eq false');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'ByteBool', 'Type Name = "ByteBool"');
  Check(DefaultSupport.Size = 1, 'Type Size = 1');
  Check(DefaultSupport.TypeInfo = TypeInfo(ByteBool), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfBoolean, 'Type Family = tfBoolean');

  Check(DefaultSupport.GetString(true) = 'True', '(Default) Expected GetString() = "True"');
end;


procedure TTestTypes.TestCardinal;
var
  DefaultSupport : IType<Cardinal>;
begin
  DefaultSupport := TType<Cardinal>.Default;

  { Explicit }
  Check(DefaultSupport.Compare(1, 2) < 0, '(Default) Expected 1 < 2');
  Check(DefaultSupport.Compare(2, 1) > 0, '(Default) Expected 2 > 1');
  Check(DefaultSupport.Compare(2, 2) = 0, '(Default) Expected 2 = 2');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(1, 2), '(Default) Expected 1 neq 2');

  Check(DefaultSupport.GenerateHashCode(1) <> DefaultSupport.GenerateHashCode(2), '(Default) Expected hashcode 1 neq 2');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Cardinal', 'Type Name = "Cardinal"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(Cardinal), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  Check(DefaultSupport.GetString(24) = '24', '(Default) Expected GetString() = "24"')
end;

procedure TTestTypes.TestComp;
var
  DefaultSupport : IType<Comp>;
  V0             : Comp;
begin
  DefaultSupport := TType<Comp>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Comp', 'Type Name = "Comp"');
  Check(DefaultSupport.Size = 8, 'Type Size = 8');
  Check(DefaultSupport.TypeInfo = TypeInfo(Comp), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfReal, 'Type Family = tfReal');

  V0 := 10.1;
  Check(DefaultSupport.GetString(V0) = '10', '(Default) Expected GetString() = "10"')
end;

procedure TTestTypes.TestCurrency;
var
  DefaultSupport : IType<Currency>;
  V0             : Currency;
begin
  DefaultSupport := TType<Currency>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Currency', 'Type Name = "Currency"');
  Check(DefaultSupport.Size = 8, 'Type Size = 8');
  Check(DefaultSupport.TypeInfo = TypeInfo(Currency), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfReal, 'Type Family = tfReal');

  V0 := 10.1;
  Check(DefaultSupport.GetString(V0) = '10.1', '(Default) Expected GetString() = "10.1"')
end;

{ TMyCustomType }

function TMyCustomType.Compare(const AValue1, AValue2: MyInt): NativeInt;
begin
  Result := AValue1 - AValue2;
end;

function TMyCustomType.Family: TTypeFamily;
begin
  Result := tfClass;
end;

function TMyCustomType.GenerateHashCode(const AValue: MyInt): NativeInt;
begin
  Result := AValue;
end;

function TMyCustomType.GetString(const AValue: MyInt): String;
begin
  Result := IntToStr(AValue);
end;

function TMyCustomType.TryConvertFromVariant(const AValue: Variant; out ORes: MyInt): Boolean;
begin
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TMyCustomType.TryConvertToVariant(const AValue: MyInt; out ORes: Variant): Boolean;
begin
  ORes := AValue;
  Result := true;
end;

procedure TTestTypes.TestCustomTypeRegistration;
var
  Support: IType<MyInt>;
begin
  { Let's check operations on a non RTTI type }
  { Let's check operations }
  CheckException(ENilArgumentException, procedure begin
    TType<MyInt>.Register(nil);
  end, 'ENilArgumentException not thrown (class ref nil) !');

  Check(not TType<MyInt>.IsRegistered, 'TType<MyInt>.IsRegistered expected to be false');

  { And now actually register a type }
  TType<MyInt>.Register(TMyCustomType);
  Check(TType<MyInt>.IsRegistered, 'TType<MyInt>.IsRegistered expected to be true');

  { .. try again }
  CheckException(ETypeException, procedure begin
    TType<MyInt>.Register(TMyCustomType);
  end, 'ETypeException not thrown (seconnd attempt at registering) !');

  { ................. TESTING REG TYPE }

  Support := TType<MyInt>.Default;

  Check(Support.Name = 'MyInt', 'Support.Name expected to be MyInt');
  Check(Support.Size = SizeOf(MyInt), 'Support.Size expected to be SizeOf(MyInt)');
  Check(Support.TypeInfo = TypeInfo(MyInt), 'Support.TypeInfo expected to be TypeInfo(MyInt)');
  Check(Support.Family = tfClass, 'Support.Family expected to be tfClass');

  { ...................................}

  { Unregister the culprit }
  TType<MyInt>.Unregister();

  Check(not TType<MyInt>.IsRegistered, 'TType<MyInt>.IsRegistered expected to be false');

  { .. try again }
  CheckException(ETypeException, procedure begin
    TType<MyInt>.Unregister();
  end, 'ETypeException not thrown (seconnd attempt at unregistering) !');

  { .. Let's unregister something else now }
  CheckException(ETypeException, procedure begin
    TType<Integer>.Unregister();
  end, 'ETypeException not thrown (trying to unreg integer) !');

end;

procedure TTestTypes.TestSysDate;
var
  Support: IType<System.TDate>;
  TS1, TS2: TDate;
begin
  Support := TType<TDate>.Default;
  TS1 := EncodeDate(1990, 6, 22);
  TS2 := EncodeDate(1990, 6, 25);

  Check(Support.Compare(TS1, TS2) < 0, 'Compare(TS1, TS2) was expected to be less than 0');
  Check(Support.Compare(TS2, TS1) > 0, 'Compare(TS2, TS1) was expected to be bigger than 0');
  Check(Support.Compare(TS1, TS1) = 0, 'Compare(TS1, TS1) was expected to be  0');

  Check(Support.AreEqual(TS1, TS1), 'AreEqual(TS1, TS1) was expected to be true');
  Check(not Support.AreEqual(TS1, TS2), 'AreEqual(TS1, TS2) was expected to be false');

  Check(Support.GenerateHashCode(TS1) <> Support.GenerateHashCode(TS2), 'GenerateHashCode(TS1)/TS2 were expected to be different');
  Check(Support.Management() = tmNone, 'Type support = tmNone');

  Check(Support.Name = 'TDate', 'Type Name = "TDate"');
  Check(Support.Size = SizeOf(TDate), 'Type Size = SizeOf(TDate)');
  Check(Support.TypeInfo = TypeInfo(TDate), 'Type information provider failed!');
  Check(Support.Family = tfDate, 'Type Family = tfDate');

  Check(Support.GetString(TS1) = DateToStr(TS1), 'Invalid string was generated!');
end;

procedure TTestTypes.TestSysDateTime;
var
  Support: IType<System.TDateTime>;
  TS1, TS2: TDateTime;
begin
  Support := TType<TDateTime>.Default;
  TS1 := EncodeDateTime(1990, 3, 2, 3, 10, 44, 100);
  TS2 := EncodeDateTime(1990, 3, 2, 3, 10, 44, 101);

  Check(Support.Compare(TS1, TS2) < 0, 'Compare(TS1, TS2) was expected to be less than 0');
  Check(Support.Compare(TS2, TS1) > 0, 'Compare(TS2, TS1) was expected to be bigger than 0');
  Check(Support.Compare(TS1, TS1) = 0, 'Compare(TS1, TS1) was expected to be  0');

  Check(Support.AreEqual(TS1, TS1), 'AreEqual(TS1, TS1) was expected to be true');
  Check(not Support.AreEqual(TS1, TS2), 'AreEqual(TS1, TS2) was expected to be false');

  Check(Support.GenerateHashCode(TS1) <> Support.GenerateHashCode(TS2), 'GenerateHashCode(TS1)/TS2 were expected to be different');
  Check(Support.Management() = tmNone, 'Type support = tmNone');

  Check(Support.Name = 'TDateTime', 'Type Name = "TDateTime"');
  Check(Support.Size = SizeOf(TDateTime), 'Type Size = SizeOf(TDateTime)');
  Check(Support.TypeInfo = TypeInfo(TDateTime), 'Type information provider failed!');
  Check(Support.Family = tfDate, 'Type Family = tfDate');

  Check(Support.GetString(TS1) = DateTimeToStr(TS1), 'Invalid string was generated!');
end;

procedure TTestTypes.TestDefaultRestriction;
var
  LString: IType<String>;
  LInt: IType<Int64>;
  LUnk: IType<TProcedure>;
begin
  { STRING }

  CheckException(ETypeException, procedure begin
    LString := TType<String>.Default([tfSignedInteger]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LString := TType<String>.Default([]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LString := TType<String>.Default([tfVariant]);
  end, 'Expected a restriction problem!');

  LString := TType<String>.Default([tfString]);
  CheckTrue(LString <> nil, 'LString >> Failed to obtain a real object');

  { INT }

  CheckException(ETypeException, procedure begin
    LInt := TType<Int64>.Default([tfString]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LInt := TType<Int64>.Default([tfUnsignedInteger]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LInt := TType<Int64>.Default([]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LInt := TType<Int64>.Default([tfVariant]);
  end, 'Expected a restriction problem!');

  LInt := TType<Int64>.Default([tfSignedInteger]);
  CheckTrue(LString <> nil, 'LInt >> Failed to obtain a real object');

  { TProcedure }

  CheckException(ETypeException, procedure begin
    LUnk := TType<TProcedure>.Default([tfString]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LUnk := TType<TProcedure>.Default([tfUnsignedInteger]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LUnk := TType<TProcedure>.Default([]);
  end, 'Expected a restriction problem!');

  CheckException(ETypeException, procedure begin
    LUnk := TType<TProcedure>.Default([tfVariant]);
  end, 'Expected a restriction problem!');

  LUnk := TType<TProcedure>.Default([tfMethod]);
  CheckTrue(LUnk <> nil, 'LUnk >> Failed to obtain a real object');
end;

procedure TTestTypes.TestDefault_Comparer;
var
  LType: IType<Integer>;
begin
  LType := TType<Integer>.Default(
    function(const ALeft, ARight: Integer): NativeInt
    begin
      Result := -1;
    end,
    function(const AValue: Integer): NativeInt
    begin
      Result := -2;
    end
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TType<Integer>.Default(
      function(const ALeft, ARight: Integer): NativeInt
      begin
        Result := -1;
      end,
      nil
    );
    end,
    'ENilArgumentException not thrown in Default (nil hasher).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
    TType<Integer>.Default(
      nil,
      function(const AValue: Integer): NativeInt
      begin
        Result := -2;
      end
    );
    end,
    'ENilArgumentException not thrown in Default (nil comparer).'
  );

  Check(LType.Compare(-1, 1) = -1, '(LType) Expected -1');
  Check(LType.Compare(100, 150) = -1, '(LType) Expected -1');
  Check(LType.Compare(-233, -78) = -1, '(LType) Expected -1');

  Check(LType.GenerateHashCode(-1) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(100) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(-233) = -2, '(LType) Expected -2');
end;

procedure TTestTypes.TestDefault_Comparer_Restriction;
var
  LType: IType<Integer>;
begin
  LType := TType<Integer>.Default([tfSignedInteger],
    function(const ALeft, ARight: Integer): NativeInt
    begin
      Result := -1;
    end,
    function(const AValue: Integer): NativeInt
    begin
      Result := -2;
    end
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TType<Integer>.Default([tfSignedInteger],
      function(const ALeft, ARight: Integer): NativeInt
      begin
        Result := -1;
      end,
      nil
    );
    end,
    'ENilArgumentException not thrown in Default (nil hasher).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
    TType<Integer>.Default([tfSignedInteger],
      nil,
      function(const AValue: Integer): NativeInt
      begin
        Result := -2;
      end
    );
    end,
    'ENilArgumentException not thrown in Default (nil comparer).'
  );

  CheckException(ETypeException,
    procedure() begin
    TType<Integer>.Default([],
      function(const ALeft, ARight: Integer): NativeInt
      begin
        Result := -1;
      end,
      function(const AValue: Integer): NativeInt
      begin
        Result := -2;
      end
    );
    end,
    'ETypeException not thrown in Default (restriction).'
  );

  Check(LType.Compare(-1, 1) = -1, '(LType) Expected -1');
  Check(LType.Compare(100, 150) = -1, '(LType) Expected -1');
  Check(LType.Compare(-233, -78) = -1, '(LType) Expected -1');

  Check(LType.GenerateHashCode(-1) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(100) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(-233) = -2, '(LType) Expected -2');
end;

procedure TTestTypes.TestDouble;
var
  DefaultSupport : IType<Double>;
  V0             : Double;
begin
  DefaultSupport := TType<Double>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Double', 'Type Name = "Double"');
  Check(DefaultSupport.Size = 8, 'Type Size = 8');
  Check(DefaultSupport.TypeInfo = TypeInfo(Double), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfReal, 'Type Family = tfReal');

  V0 := 10.1;
  Check(DefaultSupport.GetString(V0) = '10.1', '(Default) Expected GetString() = "10.1"')
end;

type
 TMyArrayOfInt = array of Integer;

procedure TTestTypes.TestDynArray;
var
  DefaultSupport : IType<TMyArrayOfInt>;
  v1, v2         : TMyArrayOfInt;
begin
  DefaultSupport := TType<TMyArrayOfInt>.Default;
  SetLength(v1, 2);
  SetLength(v2, 2);

  v1[0] := 1;
  v1[1] := 1;

  v2[0] := 1;
  v2[1] := 2;

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'TMyArrayOfInt', 'Type Name = "TMyArrayOfInt"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(TMyArrayOfInt), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfArray, 'Type Family = tfArray');

  SetLength(v1, 3);
  Check(DefaultSupport.GetString(v1) = '(3 Elements)', '(Default) Expected GetString() = "(3 Elements)"');
end;

type
  TMyEnum = (Alfa, Beta, Teta, Gamma);

procedure TTestTypes.TestEnumeration;
var
  DefaultSupport : IType<TMyEnum>;
  v1, v2, V : TMyEnum;
begin
  DefaultSupport := TType<TMyEnum>.Default;

  v1 := Alfa;
  v2 := Gamma;

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'TMyEnum', 'Type Name = "TMyEnum"');
  Check(DefaultSupport.Size = SizeOf(TMyEnum), 'Type Size = SizeOf(TMyEnum)');
  Check(DefaultSupport.TypeInfo = TypeInfo(TMyEnum), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  V := Gamma;
  Check(DefaultSupport.GetString(V) = '3', '(Default) Expected GetString() = "3"');
end;

procedure TTestTypes.TestExtended;
var
  DefaultSupport : IType<Extended>;
  V0             : Extended;
begin
  DefaultSupport := TType<Extended>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Extended', 'Type Name = "Extended"');
  Check(DefaultSupport.Size = 10, 'Type Size = 10');
  Check(DefaultSupport.TypeInfo = TypeInfo(Extended), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfReal, 'Type Family = tfReal');

  V0 := 10.1;
  Check(DefaultSupport.GetString(V0) = '10.1', '(Default) Expected GetString() = "10.1"')
end;

procedure TTestTypes.TestExtenders;
var
  MyExtender: TTypeExtender;
  LByte: IType<Byte>;
  LWord: IType<Word>;
  LInt: IType<Integer>;

  ExtObj: TTypeExtension;
begin
  { Create an extender }
  MyExtender := TTypeExtender.Create();

  { Register an extension }
  MyExtender.Register<Byte>(TMyExtension);

  { Secondary registration not allowed }
  CheckException(ETypeExtensionException, procedure begin
    MyExtender.Register<Byte>(TMyExtension);
  end, 'Expected an extension related exception!');

  { Unregister an extension }
  MyExtender.Unregister<Byte>();

  { Secondary unregistration not allowed }
  CheckException(ETypeExtensionException, procedure begin
    MyExtender.Unregister<Byte>();
  end, 'Expected an extension related exception!');

  { Register an extension for two types }
  MyExtender.Register<Byte>(TMyExtension);
  MyExtender.Register<Word>(TYourExtension);

  LByte := TType<Byte>.Default;
  LWord := TType<Word>.Default;

  { Obtain an extension from the registered types }
  ExtObj := LByte.GetExtension(MyExtender);
  Check(ExtObj <> nil, 'The obtained extension should not be nil (Byte)');
  Check(ExtObj is TMyExtension, 'The obtained extension is not what it was supposed to be (Byte).');
  FreeAndNil(ExtObj);

  ExtObj := LWord.GetExtension(MyExtender);
  Check(ExtObj <> nil, 'The obtained extension should not be nil (Word)');
  Check(ExtObj is TYourExtension, 'The obtained extension is not what it was supposed to be (Word).');
  ExtObj.Free;

  CheckException(ENilArgumentException, procedure begin
    LWord.GetExtension(nil);
  end, 'Expected an ENilArgumentException exception in GetExtension!');

  LInt := TType<Integer>.Default;
  Check(LInt.GetExtension(MyExtender) = nil, 'The result should have been NIL. There is no extension for Integer.');

  { Unregister my extensions }
  MyExtender.Unregister<Byte>();
  MyExtender.Unregister<Word>();

  Check(LByte.GetExtension(MyExtender) = nil, 'The result should have been NIL. There is no extension for Byte now.');
  Check(LWord.GetExtension(MyExtender) = nil, 'The result should have been NIL. There is no extension for Word now.');

  { Register another one }
  MyExtender.Register<Integer>(TMyExtension);

  { And filannaly kill it }
  MyExtender.Free;
end;

procedure TTestTypes.TestInsAnsiString;
var
  Support : IType<AnsiString>;
  V       : AnsiString;
begin
  Support := TStringType.ANSI(True);

  { Explicit }
  Check(Support.Compare('AA', 'AB') < 0, '(Explicit) Expected AA < AB');
  Check(Support.Compare('AB', 'AA') > 0, '(Explicit) Expected AB > AA');
  Check(Support.Compare('AA', 'AA') = 0, '(Explicit) Expected AA = AA');
  Check(Support.Compare('aa', 'AA') = 0, '(Explicit) Expected aa = AA');

  Check(Support.AreEqual('abc', 'abc'), '(Explicit) Expected abc eq abc');
  Check(Support.AreEqual('abc', 'ABC'), '(Explicit) Expected abc eq ABC');

  Check(Support.GenerateHashCode('ABC') = Support.GenerateHashCode('abc'), '(Explicit) Expected hashcode ABC eq abc');
  Check(Support.GenerateHashCode('abcd') <> Support.GenerateHashCode('abcd0'), '(Explicit) Expected hashcode abcd neq abcd0');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(Support.Name = 'AnsiString', 'Type Name = "AnsiString"');
  Check(Support.Size = 4, 'Type Size = 4');
  Check(Support.TypeInfo = TypeInfo(AnsiString), 'Type information provider failed!');
  Check(Support.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(Support.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestInsShortString;
var
  Support : IType<ShortString>;
  V       : ShortString;
begin
  Support := TStringType.Short(True);

  { Explicit }
  Check(Support.Compare('AA', 'AB') < 0, '(Explicit) Expected AA < AB');
  Check(Support.Compare('AB', 'AA') > 0, '(Explicit) Expected AB > AA');
  Check(Support.Compare('AA', 'AA') = 0, '(Explicit) Expected AA = AA');
  Check(Support.Compare('aa', 'AA') = 0, '(Explicit) Expected aa = AA');

  Check(Support.AreEqual('abc', 'abc'), '(Explicit) Expected abc eq abc');
  Check(Support.AreEqual('abc', 'ABC'), '(Explicit) Expected abc eq ABC');

  Check(Support.GenerateHashCode('ABC') = Support.GenerateHashCode('abc'), '(Explicit) Expected hashcode ABC eq abc');
  Check(Support.GenerateHashCode('abcd') <> Support.GenerateHashCode('abcd0'), '(Explicit) Expected hashcode abcd neq abcd0');

  Check(Support.Management() = tmNone, 'Type support = tmNone');

  Check(Support.Name = 'ShortString', 'Type Name = "ShortString"');
  Check(Support.Size = 256, 'Type Size = 256');
  Check(Support.TypeInfo = TypeInfo(ShortString), 'Type information provider failed!');
  Check(Support.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(Support.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestInsUCS4String;
var
  Support : IType<UCS4String>;
  V       : UCS4String;

  function S(const SS: String): UCS4String;
  begin
    Result := UnicodeStringToUCS4String(SS);
  end;

begin
  Support := TStringType.UCS4(True);

  { Explicit }
  Check(Support.Compare(S('AA'), S('AB')) < 0, '(Explicit) Expected AA < AB');
  Check(Support.Compare(S('AB'), S('AA')) > 0, '(Explicit) Expected AB > AA');
  Check(Support.Compare(S('AA'), S('AA')) = 0, '(Explicit) Expected AA = AA');
  Check(Support.Compare(S('aa'), S('AA')) = 0, '(Explicit) Expected aa = AA');

  Check(Support.AreEqual(S('abc'), S('abc')), '(Explicit) Expected abc eq abc');
  Check(Support.AreEqual(S('abc'), S('ABC')), '(Explicit) Expected abc eq ABC');

  Check(Support.GenerateHashCode(S('ABC')) = Support.GenerateHashCode(S('abc')), '(Explicit) Expected hashcode ABC eq abc');
  Check(Support.GenerateHashCode(S('abcd')) <> Support.GenerateHashCode(S('abcd0')), '(Explicit) Expected hashcode abcd neq abcd0');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(Support.Name = 'UCS4String', 'Type Name = "UCS4String"');
  Check(Support.Size = 4, 'Type Size = 4');
  Check(Support.TypeInfo = TypeInfo(UCS4String), 'Type information provider failed!');
  Check(Support.Family = tfString, 'Type Family = tfString');

  V := S('Hello');
  Check(Support.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestInsUnicodeString;
var
  Support : IType<UnicodeString>;
  V       : UnicodeString;
begin
  Support := TStringType.Unicode(True);

  { Explicit }
  Check(Support.Compare('AA', 'AB') < 0, '(Explicit) Expected AA < AB');
  Check(Support.Compare('AB', 'AA') > 0, '(Explicit) Expected AB > AA');
  Check(Support.Compare('AA', 'AA') = 0, '(Explicit) Expected AA = AA');
  Check(Support.Compare('aa', 'AA') = 0, '(Explicit) Expected aa = AA');

  Check(Support.AreEqual('abc', 'abc'), '(Explicit) Expected abc eq abc');
  Check(Support.AreEqual('abc', 'ABC'), '(Explicit) Expected abc eq ABC');

  Check(Support.GenerateHashCode('ABC') = Support.GenerateHashCode('abc'), '(Explicit) Expected hashcode ABC eq abc');
  Check(Support.GenerateHashCode('abcd') <> Support.GenerateHashCode('abcd0'), '(Explicit) Expected hashcode abcd neq abcd0');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(Support.Name = 'string', 'Type Name = "string"');
  Check(Support.Size = 4, 'Type Size = 4');
  Check(Support.TypeInfo = TypeInfo(UnicodeString), 'Type information provider failed!');
  Check(Support.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(Support.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestInsUTF8String;
var
  Support : IType<UTF8String>;
  V       : UTF8String;
begin
  Support := TStringType.UTF8(True);

  { Explicit }
  Check(Support.Compare('AA', 'AB') < 0, '(Explicit) Expected AA < AB');
  Check(Support.Compare('AB', 'AA') > 0, '(Explicit) Expected AB > AA');
  Check(Support.Compare('AA', 'AA') = 0, '(Explicit) Expected AA = AA');
  Check(Support.Compare('aa', 'AA') = 0, '(Explicit) Expected aa = AA');

  Check(Support.AreEqual('abc', 'abc'), '(Explicit) Expected abc eq abc');
  Check(Support.AreEqual('abc', 'ABC'), '(Explicit) Expected abc eq ABC');

  Check(Support.GenerateHashCode('ABC') = Support.GenerateHashCode('abc'), '(Explicit) Expected hashcode ABC eq abc');
  Check(Support.GenerateHashCode('abcd') <> Support.GenerateHashCode('abcd0'), '(Explicit) Expected hashcode abcd neq abcd0');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(Support.Name = 'UTF8String', 'Type Name = "UTF8String"');
  Check(Support.Size = 4, 'Type Size = 4');
  Check(Support.TypeInfo = TypeInfo(UTF8String), 'Type information provider failed!');
  Check(Support.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(Support.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestInsWideString;
var
  Support : IType<WideString>;
  V       : WideString;
begin
  Support := TStringType.Wide(True);

  { Explicit }
  Check(Support.Compare('AA', 'AB') < 0, '(Explicit) Expected AA < AB');
  Check(Support.Compare('AB', 'AA') > 0, '(Explicit) Expected AB > AA');
  Check(Support.Compare('AA', 'AA') = 0, '(Explicit) Expected AA = AA');
  Check(Support.Compare('aa', 'AA') = 0, '(Explicit) Expected aa = AA');

  Check(Support.AreEqual('abc', 'abc'), '(Explicit) Expected abc eq abc');
  Check(Support.AreEqual('abc', 'ABC'), '(Explicit) Expected abc eq ABC');

  Check(Support.GenerateHashCode('ABC') = Support.GenerateHashCode('abc'), '(Explicit) Expected hashcode ABC eq abc');
  Check(Support.GenerateHashCode('abcd') <> Support.GenerateHashCode('abcd0'), '(Explicit) Expected hashcode abcd neq abcd0');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(Support.Name = 'WideString', 'Type Name = "WideString"');
  Check(Support.Size = 4, 'Type Size = 4');
  Check(Support.TypeInfo = TypeInfo(WideString), 'Type information provider failed!');
  Check(Support.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(Support.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestInt64;
var
  DefaultSupport : IType<Int64>;
begin
  DefaultSupport := TType<Int64>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Int64', 'Type Name = "Int64"');
  Check(DefaultSupport.Size = 8, 'Type Size = 8');
  Check(DefaultSupport.TypeInfo = TypeInfo(Int64), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfSignedInteger, 'Type Family = tfSignedInteger');

  Check(DefaultSupport.GetString(12) = '12', '(Default) Expected GetString() = "12"')
end;

procedure TTestTypes.TestInteger;
var
  DefaultSupport : IType<Integer>;
begin
  DefaultSupport := TType<Integer>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Integer', 'Type Name = "Integer"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(Integer), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfSignedInteger, 'Type Family = tfSignedInteger');

  Check(DefaultSupport.GetString(-89) = '-89', '(Default) Expected GetString() = "-89"')
end;

procedure TTestTypes.TestInterface;
var
  DefaultSupport : IType<IInterface>;
  A, B: IInterface;
begin
  DefaultSupport := TType<IInterface>.Default;
  A := nil;
  B := TInterfacedObject.Create;

  { Default }
  Check(DefaultSupport.Compare(A, B) < 0, '(Default) Expected A < B');
  Check(DefaultSupport.Compare(B, A) > 0, '(Default) Expected B > A');
  Check(DefaultSupport.Compare(A, A) = 0, '(Default) Expected A = A');

  Check(DefaultSupport.AreEqual(A, A), '(Default) Expected A eq A');
  Check(not DefaultSupport.AreEqual(A, B), '(Default) Expected A neq B');

  Check(DefaultSupport.GenerateHashCode(A) <> DefaultSupport.GenerateHashCode(B), '(Default) Expected hashcode A neq B');
  Check(DefaultSupport.GenerateHashCode(B) = DefaultSupport.GenerateHashCode(B), '(Default) Expected hashcode B eq B');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'IInterface', 'Type Name = "IInterface"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(IInterface), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfInterface, 'Type Family = tfInterface');

  Check(Pos('(Reference: 0x', DefaultSupport.GetString(B)) = 1, '(Default) Expected GetString() = "(Reference: 0xXXXXXXXX)"');
end;

procedure TTestTypes.TestLongBool;
var
  DefaultSupport : IType<LongBool>;
begin
  DefaultSupport := TType<LongBool>.Default;

  { Default }
  Check(DefaultSupport.Compare(false, true) < 0, '(Default) Expected false < true');
  Check(DefaultSupport.Compare(true, false) > 0, '(Default) Expected true > false');
  Check(DefaultSupport.Compare(true, true) = 0, '(Default) Expected true = true');

  Check(DefaultSupport.AreEqual(false, false), '(Default) Expected false eq false');
  Check(not DefaultSupport.AreEqual(false, true), '(Default) Expected false neq true');

  Check(DefaultSupport.GenerateHashCode(false) <> DefaultSupport.GenerateHashCode(true), '(Default) Expected hashcode false neq true');
  Check(DefaultSupport.GenerateHashCode(false) = DefaultSupport.GenerateHashCode(false), '(Default) Expected hashcode false eq false');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'LongBool', 'Type Name = "LongBool"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(LongBool), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfBoolean, 'Type Family = tfBoolean');

  Check(DefaultSupport.GetString(true) = 'True', '(Default) Expected GetString() = "True"');
end;

type
  TProcOfObject = procedure of object;

procedure TTestTypes.TestMethod;
var
  DefaultSupport: IType<TProcOfObject>;
begin
  DefaultSupport := TType<TProcOfObject>.Default;

  { Default }
  Check(DefaultSupport.Compare(TestWrapper0, TestStandardAccessor) <> 0, '(Default) Expected v1 <> v2');

  Check(DefaultSupport.AreEqual(TestWrapper0, TestWrapper0), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(TestWrapper0, TestStandardAccessor), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(TestWrapper0) <> DefaultSupport.GenerateHashCode(TestStandardAccessor), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(TestStandardAccessor) = DefaultSupport.GenerateHashCode(TestStandardAccessor), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'TProcOfObject', 'Type Name = "TProcOfObject"');
  Check(DefaultSupport.Size = SizeOf(TProcOfObject), 'Type Size = SizeOf(TProcOfObject)');
  Check(DefaultSupport.TypeInfo = TypeInfo(TProcOfObject), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfMethod, 'Type Family = tfMethod');

  Check(Pos('(Reference: 0x', DefaultSupport.GetString(TestStandardAccessor)) = 1, '(Default) Expected GetString() = "(Reference: 0xXXXXXXXX)"');
end;

procedure TTestTypes.TestNativeInt;
var
  DefaultSupport : IType<NativeInt>;
begin
  DefaultSupport := TType<NativeInt>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'NativeInt', 'Type Name = "NativeInt"');
  Check(DefaultSupport.Size = SizeOf(NativeInt), 'Type Size = SizeOf(NativeInt)');
  Check(DefaultSupport.TypeInfo = TypeInfo(NativeInt), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfSignedInteger, 'Type Family = tfSignedInteger');

  Check(DefaultSupport.GetString(-89) = '-89', '(Default) Expected GetString() = "-89"')
end;

procedure TTestTypes.TestNativeUInt;
var
  DefaultSupport : IType<NativeUInt>;
begin
  DefaultSupport := TType<NativeUInt>.Default;

  { Explicit }
  Check(DefaultSupport.Compare(1, 2) < 0, '(Default) Expected 1 < 2');
  Check(DefaultSupport.Compare(2, 1) > 0, '(Default) Expected 2 > 1');
  Check(DefaultSupport.Compare(2, 2) = 0, '(Default) Expected 2 = 2');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(1, 2), '(Default) Expected 1 neq 2');

  Check(DefaultSupport.GenerateHashCode(1) <> DefaultSupport.GenerateHashCode(2), '(Default) Expected hashcode 1 neq 2');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'NativeUInt', 'Type Name = "NativeUInt"');
  Check(DefaultSupport.Size = SizeOf(NativeUInt), 'Type Size = SizeOf(NativeUInt)');
  Check(DefaultSupport.TypeInfo = TypeInfo(NativeUInt), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  Check(DefaultSupport.GetString(24) = '24', '(Default) Expected GetString() = "24"')
end;

procedure TTestTypes.TestOleVariant;
var
  DefaultSupport : IType<OleVariant>;
  V              : OleVariant;
begin
  DefaultSupport := TType<OleVariant>.Default;

  { Default }
  Check(DefaultSupport.Compare('1', 2) < 0, '(Default) Expected 1 < 2');
  Check(DefaultSupport.Compare('2', '1') > 0, '(Default) Expected 2 > 1');
  Check(DefaultSupport.Compare('A', 'A') = 0, '(Default) Expected A = A');
  Check(DefaultSupport.Compare('a', 'A') > 0, '(Default) Expected a > A');

  Check(DefaultSupport.AreEqual('5', 5), '(Default) Expected 5 eq 5');
  Check(not DefaultSupport.AreEqual('4', 44), '(Default) Expected 4 neq 44');

  Check(DefaultSupport.GenerateHashCode('A') <> DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode A neq a');
  Check(DefaultSupport.GenerateHashCode('2') = DefaultSupport.GenerateHashCode(2), '(Default) Expected hashcode 2 eq 2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'OleVariant', 'Type Name = "OleVariant"');
  Check(DefaultSupport.Size = SizeOf(OleVariant), 'Type Size = SizeOf(OleVariant)');
  Check(DefaultSupport.TypeInfo = TypeInfo(OleVariant), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfVariant, 'Type Family = tfVariant');

  V := 'Hello';
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestPointer;
var
  DefaultSupport : IType<Pointer>;
  A : array[0..6] of Byte;
  V : Pointer;
begin
  DefaultSupport := TType<Pointer>.Default;

  { Default }
  Check(DefaultSupport.Compare(@A[0], @A[6]) < 0, '(Default) Expected @A[0] < @A[6]');
  Check(DefaultSupport.Compare(@A[2], @A[1]) > 0, '(Default) Expected @A[2] > @A[1]');
  Check(DefaultSupport.Compare(@A[4], @A[4]) = 0, '(Default) Expected @A[4] = @A[4]');

  Check(DefaultSupport.AreEqual(@A[0], @A[0]), '(Default) Expected @A[0] eq @A[0]');
  Check(not DefaultSupport.AreEqual(@A[0], @A[1]), '(Default) Expected @A[0] neq @A[1]');

  Check(DefaultSupport.GenerateHashCode(@A[0]) <> DefaultSupport.GenerateHashCode(@A[1]), '(Default) Expected hashcode @A[0] neq @A[1]');
  Check(DefaultSupport.GenerateHashCode(@A[3]) = DefaultSupport.GenerateHashCode(@A[3]), '(Default) Expected hashcode @A[3] eq @A[3]');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Pointer', 'Type Name = "Pointer"');
  Check(DefaultSupport.TypeInfo = TypeInfo(Pointer), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfPointer, 'Type Family = tfPointer');

  Check(DefaultSupport.Size = 4, 'Type Size = 4');

  V := Pointer(10);
  DefaultSupport.Cleanup(V);

  Check(V = Pointer(10), '(Default) Expected V to be Ptr(10)');
  Check(Pos('(Reference: 0x', DefaultSupport.GetString(V)) = 1, '(Default) Expected GetString() = "(Reference: 0xXXXXXXXX)"');
end;

type
  TMyRec = packed record
    I1, I2, I3, I4, I5, I6 : Integer;
  end;

procedure TTestTypes.TestRawByteString;
var
  DefaultSupport : IType<RawByteString>;
  v1, v2         : RawByteString;
begin
  DefaultSupport := TType<RawByteString>.Default;
  SetLength(v1, 2);
  SetLength(v2, 2);

  v1[1] := #1;
  v1[2] := #1;

  v2[1] := #1;
  v2[2] := #2;

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'RawByteString', 'Type Name = "RawByteString"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(RawByteString), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnknown, 'Type Family = tfUnknown');

  SetLength(v1, 3);
  Check(DefaultSupport.GetString(v1) = '(3 Elements)', '(Default) Expected GetString() = "(3 Elements)"');
end;

procedure TTestTypes.TestReal;
var
  DefaultSupport : IType<Real>;
  V0             : Real;
begin
  DefaultSupport := TType<Real>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Real', 'Type Name = "Real"');
  Check(DefaultSupport.Size = 8, 'Type Size = 8');
  Check(DefaultSupport.TypeInfo = TypeInfo(Real), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfReal, 'Type Family = tfReal');

  V0 := 10.1;
  Check(DefaultSupport.GetString(V0) = '10.1', '(Default) Expected GetString() = "10.1"')
end;

procedure TTestTypes.TestRecord;
var
  DefaultSupport : IType<TMyRec>;
  v1, v2         : TMyRec;
  V              : TMyRec;
begin
  DefaultSupport := TType<TMyRec>.Default;

  v1.I1 := 0; v1.I2 := 0; v1.I3 := 0; v1.I4 := 0; v1.I5 := 0; v1.I6 := 0;
  v2.I1 := 1; v2.I2 := 0; v2.I3 := 0; v2.I4 := 0; v2.I5 := 0; v2.I6 := 1;

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Name = 'TMyRec', 'Type Name = "TMyRec"');
  Check(DefaultSupport.TypeInfo = TypeInfo(TMyRec), 'Type information provider failed!');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');
  Check(DefaultSupport.Size = SizeOf(TMyRec), 'Type Size = SizeOf(TMyRec)');
  Check(DefaultSupport.Family = tfRecord, 'Type Family = tfRecord');

  Check(DefaultSupport.GetString(V) = '(24 Bytes)', '(Default) Expected GetString() = "(24 Bytes)"');
end;


type
  TMyRecRTTI = packed record
    I1, I2, I3, I4, I5, I6 : Integer;
    S: String;
  end;

procedure TTestTypes.TestRecord_With_RTTI;
var
  DefaultSupport : IType<TMyRecRTTI>;
  v1, v2         : TMyRecRTTI;
  V              : TMyRecRTTI;
begin
  DefaultSupport := TType<TMyRecRTTI>.Default;

  v1.I1 := 0; v1.I2 := 0; v1.I3 := 0; v1.I4 := 0; v1.I5 := 0; v1.I6 := 0;
  v2.I1 := 1; v2.I2 := 0; v2.I3 := 0; v2.I4 := 0; v2.I5 := 0; v2.I6 := 1;

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'TMyRecRTTI', 'Type Name = "TMyRecRTTI"');
  Check(DefaultSupport.Size = SizeOf(TMyRecRTTI), 'Type Size = SizeOf(TMyRecRTTI)');
  Check(DefaultSupport.TypeInfo = TypeInfo(TMyRecRTTI), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfRecord, 'Type Family = tfRecord');

  Check(DefaultSupport.GetString(V) = '(28 Bytes)', '(Default) Expected GetString() = "(28 Bytes)"');
end;

procedure TestProcedure1;
begin
end;

procedure TestProcedure2;
begin
end;

procedure TTestTypes.TestRoutine;
var
  DefaultSupport: IType<TProcedure>;
begin
  DefaultSupport := TType<TProcedure>.Default;

  { Default }
  Check(DefaultSupport.Compare(TestProcedure1, TestProcedure2) <> 0, '(Default) Expected v1 <> v2');
  Check(DefaultSupport.Compare(TestProcedure2, TestProcedure2) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(TestProcedure2, TestProcedure2), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(TestProcedure1, TestProcedure2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(TestProcedure2) <> DefaultSupport.GenerateHashCode(TestProcedure1), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(TestProcedure1) = DefaultSupport.GenerateHashCode(TestProcedure1), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');
  Check(Pos('(Reference: 0x', DefaultSupport.GetString(TestProcedure1)) = 1, '(Default) Expected GetString() = "(Reference: 0xXXXXXXXX)"');

  Check(DefaultSupport.Name = 'TProcedure', 'Type Name = "TProcedure"');
  Check(DefaultSupport.TypeInfo = TypeInfo(TProcedure), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfMethod, 'Type Family = tfMethod');

  Check(DefaultSupport.Size = SizeOf(TProcedure), 'Type Size = SizeOf(TProcedure)');
end;

type
  TMySet   = set of TMyEnum;

procedure TTestTypes.TestSet;
var
  DefaultSupport : IType<TMySet>;
  v1, v2 : TMySet;
begin
  DefaultSupport := TType<TMySet>.Default;

  v1 := [Alfa, Beta];
  v2 := [Alfa, Gamma];

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'TMySet', 'Type Name = "TMySet"');
  Check(DefaultSupport.Size = SizeOf(TMySet), 'Type Size = SizeOf(TMySet)');
  Check(DefaultSupport.TypeInfo = TypeInfo(TMySet), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  Check(DefaultSupport.GetString(v1) = '3', '(Default) Expected GetString() = "3"');
end;

procedure TTestTypes.TestShortInt;
var
  DefaultSupport : IType<ShortInt>;
begin
  DefaultSupport := TType<ShortInt>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'ShortInt', 'Type Name = "ShortInt"');
  Check(DefaultSupport.Size = 1, 'Type Size = 1');
  Check(DefaultSupport.TypeInfo = TypeInfo(ShortInt), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfSignedInteger, 'Type Family = tfSignedInteger');

  Check(DefaultSupport.GetString(2) = '2', '(Default) Expected GetString() = "2"')
end;

procedure TTestTypes.TestSingle;
var
  DefaultSupport : IType<Single>;
  V0         : Single;
begin
  DefaultSupport := TType<Single>.Default;

  { Default }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Single', 'Type Name = "Single"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(Single), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfReal, 'Type Family = tfReal');

  V0 := 10.1;
  Check(DefaultSupport.GetString(V0) = '10.1000003814697', '(Default) Expected GetString() = "10.1000003814697"')
end;

procedure TTestTypes.TestSmallInt;
var
  DefaultSupport : IType<SmallInt>;
begin
  DefaultSupport := TType<SmallInt>.Default;

  { Explicit }
  Check(DefaultSupport.Compare(-1, 1) < 0, '(Default) Expected -1 < 1');
  Check(DefaultSupport.Compare(1, -1) > 0, '(Default) Expected 1 > -1');
  Check(DefaultSupport.Compare(-1, -1) = 0, '(Default) Expected -1 = -1');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(-1, 1), '(Default) Expected -1 neq 1');

  Check(DefaultSupport.GenerateHashCode(-1) <> DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode -1 neq 1');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'SmallInt', 'Type Name = "SmallInt"');
  Check(DefaultSupport.Size = 2, 'Type Size = 2');
  Check(DefaultSupport.TypeInfo = TypeInfo(SmallInt), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfSignedInteger, 'Type Family = tfSignedInteger');

  Check(DefaultSupport.GetString(-2) = '-2', '(Default) Expected GetString() = "-2"')
end;


type
  TMyArray = packed array[0..2] of Byte;

procedure TTestTypes.TestStandardAccessor;
var
  LDefault: IType<WordBool>;
  LStandard: IType<WordBool>;
  LInt: IType<Integer>;
begin
  { Obtain type classes using two methods }
  LDefault := TType<WordBool>.Default;
  LStandard := TType<WordBool>.Standard();

  { Test compatibility }
  Check(LDefault.TypeInfo = LStandard.TypeInfo, 'TypeInfo must match between types');
  Check(LDefault.Family <> LStandard.Family, 'Family must differ between types');

  { Verify restrictioned access }
  CheckException(ETypeException, procedure begin
    TType<WordBool>.Standard([tfBoolean]);
  end, 'Expected a restriction problem!');

  LInt := TType<Integer>.Standard([tfSignedInteger]);
  Check(LInt <> nil, 'Failed to obtain a real object');
end;

procedure TTestTypes.TestStandard_Comparer;
var
  LType: IType<Integer>;
begin
  LType := TType<Integer>.Standard(
    function(const ALeft, ARight: Integer): NativeInt
    begin
      Result := -1;
    end,
    function(const AValue: Integer): NativeInt
    begin
      Result := -2;
    end
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TType<Integer>.Standard(
      function(const ALeft, ARight: Integer): NativeInt
      begin
        Result := -1;
      end,
      nil
    );
    end,
    'ENilArgumentException not thrown in Standard (nil hasher).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
    TType<Integer>.Standard(
      nil,
      function(const AValue: Integer): NativeInt
      begin
        Result := -2;
      end
    );
    end,
    'ENilArgumentException not thrown in Standard (nil comparer).'
  );

  Check(LType.Compare(-1, 1) = -1, '(LType) Expected -1');
  Check(LType.Compare(100, 150) = -1, '(LType) Expected -1');
  Check(LType.Compare(-233, -78) = -1, '(LType) Expected -1');

  Check(LType.GenerateHashCode(-1) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(100) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(-233) = -2, '(LType) Expected -2');
end;

procedure TTestTypes.TestStandard_Comparer_Restriction;
var
  LType: IType<Integer>;
begin
  LType := TType<Integer>.Standard([tfSignedInteger],
    function(const ALeft, ARight: Integer): NativeInt
    begin
      Result := -1;
    end,
    function(const AValue: Integer): NativeInt
    begin
      Result := -2;
    end
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TType<Integer>.Standard([tfSignedInteger],
      function(const ALeft, ARight: Integer): NativeInt
      begin
        Result := -1;
      end,
      nil
    );
    end,
    'ENilArgumentException not thrown in Standard (nil hasher).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
    TType<Integer>.Standard([tfSignedInteger],
      nil,
      function(const AValue: Integer): NativeInt
      begin
        Result := -2;
      end
    );
    end,
    'ENilArgumentException not thrown in Standard (nil comparer).'
  );

  CheckException(ETypeException,
    procedure() begin
    TType<Integer>.Standard([],
      function(const ALeft, ARight: Integer): NativeInt
      begin
        Result := -1;
      end,
      function(const AValue: Integer): NativeInt
      begin
        Result := -2;
      end
    );
    end,
    'ETypeException not thrown in Standard (restriction).'
  );

  Check(LType.Compare(-1, 1) = -1, '(LType) Expected -1');
  Check(LType.Compare(100, 150) = -1, '(LType) Expected -1');
  Check(LType.Compare(-233, -78) = -1, '(LType) Expected -1');

  Check(LType.GenerateHashCode(-1) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(100) = -2, '(LType) Expected -2');
  Check(LType.GenerateHashCode(-233) = -2, '(LType) Expected -2');
end;

procedure TTestTypes.TestStaticArray;
var
  DefaultSupport : IType<TMyArray>;
  v1, v2         : TMyArray;

begin
  DefaultSupport := TType<TMyArray>.Default;

  FillChar(v1, SizeOf(TMyArray), 0);
  FillChar(v2, SizeOf(TMyArray), 0);

  v2[0] := 1;

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');
  Check(DefaultSupport.Name = 'TMyArray', 'Type Name = "TMyArray"');
  Check(DefaultSupport.TypeInfo = TypeInfo(TMyArray), 'Type information provider failed!');

  Check(DefaultSupport.Size = SizeOf(TMyArray), 'Type Size = SizeOf(TMyArray)');
  Check(DefaultSupport.Family = tfArray, 'Type Family = tfArray');

  Check(DefaultSupport.GetString(v1) = '(3 Bytes)', '(Default) Expected GetString() = "(3 Bytes)"');
end;

type
  TMyArray2 = packed array[0..2] of String;

procedure TTestTypes.TestStaticArray_With_RTTI;
var
  DefaultSupport : IType<TMyArray2>;
  v1, v2         : TMyArray2;

begin
  DefaultSupport := TType<TMyArray2>.Default;

  v2[0] := 'John';

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'TMyArray2', 'Type Name = "TMyArray2"');
  Check(DefaultSupport.Size = SizeOf(TMyArray2), 'Type Size = SizeOf(TMyArray2)');
  Check(DefaultSupport.TypeInfo = TypeInfo(TMyArray2), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfArray, 'Type Family = tfArray');

  Check(DefaultSupport.GetString(v1) = '(12 Bytes)', '(Default) Expected GetString() = "(12 Bytes)"');
end;

procedure TTestTypes.TestSysTime;
var
  Support: IType<System.TTime>;
  TS1, TS2: TTime;
begin
  Support := TType<TTime>.Default;
  TS1 := EncodeTime(10, 22, 15, 100);
  TS2 := EncodeTime(10, 22, 15, 101);

  Check(Support.Compare(TS1, TS2) < 0, 'Compare(TS1, TS2) was expected to be less than 0');
  Check(Support.Compare(TS2, TS1) > 0, 'Compare(TS2, TS1) was expected to be bigger than 0');
  Check(Support.Compare(TS1, TS1) = 0, 'Compare(TS1, TS1) was expected to be  0');

  Check(Support.AreEqual(TS1, TS1), 'AreEqual(TS1, TS1) was expected to be true');
  Check(not Support.AreEqual(TS1, TS2), 'AreEqual(TS1, TS2) was expected to be false');

  Check(Support.GenerateHashCode(TS1) <> Support.GenerateHashCode(TS2), 'GenerateHashCode(TS1)/TS2 were expected to be different');
  Check(Support.Management() = tmNone, 'Type support = tmNone');

  Check(Support.Name = 'TTime', 'Type Name = "TTime"');
  Check(Support.Size = SizeOf(TTime), 'Type Size = SizeOf(TTime)');
  Check(Support.TypeInfo = TypeInfo(TTime), 'Type information provider failed!');
  Check(Support.Family = tfDate, 'Type Family = tfDate');

  Check(Support.GetString(TS1) = TimeToStr(TS1), 'Invalid string was generated!');
end;

procedure TTestTypes.TestTypeCaching;
var
  LPreDef, LAfterDef, LPostDef, LCheckDef: IType<MyInt>;
  SPreDef, SAfterDef, SPostDef: IType<MyInt>;
begin
  { Obtain a pre-def value }
  LPreDef := TType<MyInt>.Default;
  SPreDef := TType<MyInt>.Standard;

  { Register a custom type and obtain a type class }
  TType<MyInt>.Register(TMyCustomType);
  LAfterDef := TType<MyInt>.Default;
  SAfterDef := TType<MyInt>.Standard;

  { Unregister the type and obtain another type }
  TType<MyInt>.Unregister();
  LPostDef := TType<MyInt>.Default;
  LCheckDef := TType<MyInt>.Default;
  SPostDef := TType<MyInt>.Standard;

  { And now verify that caching wroks as expected }
  Check(LPreDef.Family = tfSignedInteger, 'Failed on LPreDef');
  Check(LAfterDef.Family = tfClass, 'Failed on LAfterDef (after custom type was registered)');
  Check(LPostDef.Family = tfSignedInteger, 'Failed on LPostDef (after custom type was unregistered)');
  Check(LCheckDef = LPostDef, 'Failed on LCheckDef = LPostDef');

  Check(SPreDef.Family = tfSignedInteger, 'Failed on SPreDef');
  Check(SAfterDef.Family = tfSignedInteger, 'Failed on SAfterDef');
  Check(SPostDef.Family = tfSignedInteger, 'Failed on SPostDef');
  Check(SPreDef = SAfterDef, 'Failed on SPreDef = SAfterDef');
  Check(SAfterDef = SPostDef, 'Failed on SAfterDef = SPostDef');

  Check(LPreDef <> SPreDef , 'Failed on LPreDef <> SPreDef');
end;

procedure TTestTypes.TestTypeClassInheritance;
var
  S: IType<TMyClass>;
  SS: IType<TMySecondClass>;
  ST: IType<TMyThirdClass>;
begin
  { Register a type for my class }
  TType<TMyClass>.Register(TMyCustomClassType);

  { Retrieve support classes }
  S := TType<TMyClass>.Default;
  SS := TType<TMySecondClass>.Default;
  ST := TType<TMyThirdClass>.Default;

  Check(S.GetString(nil) = 'This is my class!', 'TMyClass failed to give the registered type class');
  Check(SS.GetString(nil) = 'This is my class!', 'TMySecondClass failed to give the registered type class');
  Check(ST.GetString(nil) = 'This is my class!', 'TMyThirdClass failed to give the registered type class');

  TType<TMyClass>.Unregister();
end;

procedure TTestTypes.TestShortString;
var
  DefaultSupport : IType<ShortString>;
  V              : ShortString;
begin
  DefaultSupport := TType<ShortString>.Default;

  { Default }
  Check(DefaultSupport.Compare('AA', 'AB') < 0, '(Default) Expected AA < AB');
  Check(DefaultSupport.Compare('AB', 'AA') > 0, '(Default) Expected AB > AA');
  Check(DefaultSupport.Compare('AA', 'AA') = 0, '(Default) Expected AA = AA');
  Check(DefaultSupport.Compare('aa', 'AA') > 0, '(Default) Expected aa > AA');

  Check(DefaultSupport.AreEqual('abc', 'abc'), '(Default) Expected abc eq abc');
  Check(not DefaultSupport.AreEqual('abc', 'ABC'), '(Default) Expected abc neq ABC');

  Check(DefaultSupport.GenerateHashCode('ABC') <> DefaultSupport.GenerateHashCode('abc'), '(Default) Expected hashcode ABC neq abc');
  Check(DefaultSupport.GenerateHashCode('abcd') = DefaultSupport.GenerateHashCode('abcd'), '(Default) Expected hashcode abcd eq abcd');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'ShortString', 'Type Name = "ShortString"');
  Check(DefaultSupport.Size = 256, 'Type Size = 256');
  Check(DefaultSupport.TypeInfo = TypeInfo(ShortString), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestUCS4Char;
var
  DefaultSupport : IType<UCS4Char>;
  V              : UCS4Char;

  function UCS4Of(const C: Char): UCS4Char;
  begin
    Result := ConvertToUtf32(C, 1);
  end;

begin
  DefaultSupport := TType<UCS4Char>.Default;

  { Default }
  Check(DefaultSupport.Compare(UCS4Of('A'), UCS4Of('B')) < 0, '(Default) Expected A < B');
  Check(DefaultSupport.Compare(UCS4Of('B'), UCS4Of('A')) > 0, '(Default) Expected B > A');
  Check(DefaultSupport.Compare(UCS4Of('A'), UCS4Of('A')) = 0, '(Default) Expected A = A');
  Check(DefaultSupport.Compare(UCS4Of('a'), UCS4Of('A')) > 0, '(Default) Expected a > A');

  Check(DefaultSupport.AreEqual(UCS4Of('a'), UCS4Of('a')), '(Default) Expected a eq a');
  Check(not DefaultSupport.AreEqual(UCS4Of('c'), UCS4Of('C')), '(Default) Expected c neq C');

  Check(DefaultSupport.GenerateHashCode(UCS4Of('A')) <> DefaultSupport.GenerateHashCode(UCS4Of('a')), '(Default) Expected hashcode A neq a');
  Check(DefaultSupport.GenerateHashCode(UCS4Of('a')) = DefaultSupport.GenerateHashCode(UCS4Of('a')), '(Default) Expected hashcode a eq a');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'UCS4Char', 'Type Name = "UCS4Char"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(UCS4Char), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfCharacter, 'Type Family = tfCharacter');

  V := UCS4Of('H');
  Check(DefaultSupport.GetString(V) = 'H', '(Default) Expected GetString() = "H"');
end;

procedure TTestTypes.TestUCS4String;
var
  DefaultSupport : IType<UCS4String>;
  V              : UCS4String;

  function S(const SS: String): UCS4String;
  begin
    Result := UnicodeStringToUCS4String(SS);
  end;

begin
  DefaultSupport := TType<UCS4String>.Default;

  { Default }
  Check(DefaultSupport.Compare(S('AA'), S('AB')) < 0, '(Default) Expected AA < AB');
  Check(DefaultSupport.Compare(S('AB'), S('AA')) > 0, '(Default) Expected AB > AA');
  Check(DefaultSupport.Compare(S('AA'), S('AA')) = 0, '(Default) Expected AA = AA');
  Check(DefaultSupport.Compare(S('aa'), S('AA')) > 0, '(Default) Expected aa > AA');

  Check(DefaultSupport.AreEqual(S('abc'), S('abc')), '(Default) Expected abc eq abc');
  Check(not DefaultSupport.AreEqual(S('abc'), S('ABC')), '(Default) Expected abc neq ABC');

  Check(DefaultSupport.GenerateHashCode(S('ABC')) <> DefaultSupport.GenerateHashCode(S('abc')), '(Default) Expected hashcode ABC neq abc');
  Check(DefaultSupport.GenerateHashCode(S('abcd')) = DefaultSupport.GenerateHashCode(S('abcd')), '(Default) Expected hashcode abcd eq abcd');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'UCS4String', 'Type Name = "UCS4String"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(UCS4String), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfString, 'Type Family = tfString');

  V := S('Hello');
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestUInt64;
var
  DefaultSupport : IType<UInt64>;
begin
  DefaultSupport := TType<UInt64>.Default;

  { Default }
  Check(DefaultSupport.Compare(1, 2) < 0, '(Default) Expected 1 < 2');
  Check(DefaultSupport.Compare(2, 1) > 0, '(Default) Expected 2 > 1');
  Check(DefaultSupport.Compare(2, 2) = 0, '(Default) Expected 2 = 2');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(1, 2), '(Default) Expected 1 neq 2');

  Check(DefaultSupport.GenerateHashCode(1) <> DefaultSupport.GenerateHashCode(2), '(Default) Expected hashcode 1 neq 2');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'UInt64', 'Type Name = "UInt64"');
  Check(DefaultSupport.Size = 8, 'Type Size = 8');
  Check(DefaultSupport.TypeInfo = TypeInfo(UInt64), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  Check(DefaultSupport.GetString(12) = '12', '(Default) Expected GetString() = "12"')
end;

procedure TTestTypes.TestChar;
var
  DefaultSupport : IType<Char>;
  V              : Char;
begin
  DefaultSupport := TType<Char>.Default;

  { Default }
  Check(DefaultSupport.Compare('A', 'B') < 0, '(Default) Expected A < B');
  Check(DefaultSupport.Compare('B', 'A') > 0, '(Default) Expected B > A');
  Check(DefaultSupport.Compare('A', 'A') = 0, '(Default) Expected A = A');
  Check(DefaultSupport.Compare('a', 'A') > 0, '(Default) Expected a > A');

  Check(DefaultSupport.AreEqual('a', 'a'), '(Default) Expected a eq a');
  Check(not DefaultSupport.AreEqual('c', 'C'), '(Default) Expected c neq C');

  Check(DefaultSupport.GenerateHashCode('A') <> DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode A neq a');
  Check(DefaultSupport.GenerateHashCode('a') = DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode a eq a');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Char', 'Type Name = "Char"');
  Check(DefaultSupport.Size = 2, 'Type Size = 2');
  Check(DefaultSupport.TypeInfo = TypeInfo(Char), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfCharacter, 'Type Family = tfCharacter');

  V := 'H';
  Check(DefaultSupport.GetString(V) = 'H', '(Default) Expected GetString() = "H"');
end;

procedure TTestTypes.TestUnicodeString;
var
  DefaultSupport : IType<UnicodeString>;
  V              : UnicodeString;
begin
  DefaultSupport := TType<UnicodeString>.Default;

  { Default }
  Check(DefaultSupport.Compare('AA', 'AB') < 0, '(Default) Expected AA < AB');
  Check(DefaultSupport.Compare('AB', 'AA') > 0, '(Default) Expected AB > AA');
  Check(DefaultSupport.Compare('AA', 'AA') = 0, '(Default) Expected AA = AA');
  Check(DefaultSupport.Compare('aa', 'AA') > 0, '(Default) Expected aa > AA');

  Check(DefaultSupport.AreEqual('abc', 'abc'), '(Default) Expected abc eq abc');
  Check(not DefaultSupport.AreEqual('abc', 'ABC'), '(Default) Expected abc neq ABC');

  Check(DefaultSupport.GenerateHashCode('ABC') <> DefaultSupport.GenerateHashCode('abc'), '(Default) Expected hashcode ABC neq abc');
  Check(DefaultSupport.GenerateHashCode('abcd') = DefaultSupport.GenerateHashCode('abcd'), '(Default) Expected hashcode abcd eq abcd');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'string', 'Type Name = "string"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(UnicodeString), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestUTF8String;
var
  DefaultSupport : IType<UTF8String>;
  V              : UTF8String;
begin
  DefaultSupport := TType<UTF8String>.Default;

  { Default }
  Check(DefaultSupport.Compare('AA', 'AB') < 0, '(Default) Expected AA < AB');
  Check(DefaultSupport.Compare('AB', 'AA') > 0, '(Default) Expected AB > AA');
  Check(DefaultSupport.Compare('AA', 'AA') = 0, '(Default) Expected AA = AA');
  Check(DefaultSupport.Compare('aa', 'AA') > 0, '(Default) Expected aa > AA');

  Check(DefaultSupport.AreEqual('abc', 'abc'), '(Default) Expected abc eq abc');
  Check(not DefaultSupport.AreEqual('abc', 'ABC'), '(Default) Expected abc neq ABC');

  Check(DefaultSupport.GenerateHashCode('ABC') <> DefaultSupport.GenerateHashCode('abc'), '(Default) Expected hashcode ABC neq abc');
  Check(DefaultSupport.GenerateHashCode('abcd') = DefaultSupport.GenerateHashCode('abcd'), '(Default) Expected hashcode abcd eq abcd');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'UTF8String', 'Type Name = "UTF8String"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(UTF8String), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestVariant;
var
  DefaultSupport : IType<Variant>;
  V              : Variant;
begin
  DefaultSupport := TType<Variant>.Default;

  { Default }
  Check(DefaultSupport.Compare('1', 2) < 0, '(Default) Expected 1 < 2');
  Check(DefaultSupport.Compare('2', '1') > 0, '(Default) Expected 2 > 1');
  Check(DefaultSupport.Compare('A', 'A') = 0, '(Default) Expected A = A');
  Check(DefaultSupport.Compare('a', 'A') > 0, '(Default) Expected a > A');

  Check(DefaultSupport.AreEqual('5', 5), '(Default) Expected 5 eq 5');
  Check(not DefaultSupport.AreEqual('4', 44), '(Default) Expected 4 neq 44');

  Check(DefaultSupport.GenerateHashCode('A') <> DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode A neq a');
  Check(DefaultSupport.GenerateHashCode('2') = DefaultSupport.GenerateHashCode(2), '(Default) Expected hashcode 2 eq 2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'Variant', 'Type Name = "Variant"');
  Check(DefaultSupport.Size = SizeOf(Variant), 'Type Size = SizeOf(Variant)');
  Check(DefaultSupport.TypeInfo = TypeInfo(Variant), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfVariant, 'Type Family = tfVariant');

  V := 'Hello';
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestWideChar;
var
  DefaultSupport : IType<WideChar>;
  V              : WideChar;
begin
  DefaultSupport := TType<WideChar>.Default;

  { Default }
  Check(DefaultSupport.Compare('A', 'B') < 0, '(Default) Expected A < B');
  Check(DefaultSupport.Compare('B', 'A') > 0, '(Default) Expected B > A');
  Check(DefaultSupport.Compare('A', 'A') = 0, '(Default) Expected A = A');
  Check(DefaultSupport.Compare('a', 'A') > 0, '(Default) Expected a > A');

  Check(DefaultSupport.AreEqual('a', 'a'), '(Default) Expected a eq a');
  Check(not DefaultSupport.AreEqual('c', 'C'), '(Default) Expected c neq C');

  Check(DefaultSupport.GenerateHashCode('A') <> DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode A neq a');
  Check(DefaultSupport.GenerateHashCode('a') = DefaultSupport.GenerateHashCode('a'), '(Default) Expected hashcode a eq a');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Char', 'Type Name = "Char"');
  Check(DefaultSupport.Size = 2, 'Type Size = 2');
  Check(DefaultSupport.TypeInfo = TypeInfo(WideChar), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfCharacter, 'Type Family = tfCharacter');

  V := 'H';
  Check(DefaultSupport.GetString(V) = 'H', '(Default) Expected GetString() = "H"');
end;

procedure TTestTypes.TestWideString;
var
  DefaultSupport : IType<WideString>;
  V              : WideString;
begin
  DefaultSupport := TType<WideString>.Default;

  { Default }
  Check(DefaultSupport.Compare('AA', 'AB') < 0, '(Default) Expected AA < AB');
  Check(DefaultSupport.Compare('AB', 'AA') > 0, '(Default) Expected AB > AA');
  Check(DefaultSupport.Compare('AA', 'AA') = 0, '(Default) Expected AA = AA');

  Check(DefaultSupport.AreEqual('abc', 'abc'), '(Default) Expected abc eq abc');
  Check(not DefaultSupport.AreEqual('abc', 'ABC'), '(Default) Expected abc neq ABC');

  Check(DefaultSupport.GenerateHashCode('ABC') <> DefaultSupport.GenerateHashCode('abc'), '(Default) Expected hashcode ABC neq abc');
  Check(DefaultSupport.GenerateHashCode('abcd') = DefaultSupport.GenerateHashCode('abcd'), '(Default) Expected hashcode abcd eq abcd');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'WideString', 'Type Name = "WideString"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(WideString), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(DefaultSupport.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestTypes.TestWord;
var
  DefaultSupport : IType<Word>;
begin
  DefaultSupport := TType<Word>.Default;

  { Explicit }
  Check(DefaultSupport.Compare(1, 2) < 0, '(Default) Expected 1 < 2');
  Check(DefaultSupport.Compare(2, 1) > 0, '(Default) Expected 2 > 1');
  Check(DefaultSupport.Compare(2, 2) = 0, '(Default) Expected 2 = 2');

  Check(DefaultSupport.AreEqual(1, 1), '(Default) Expected 1 eq 1');
  Check(not DefaultSupport.AreEqual(1, 2), '(Default) Expected 1 neq 2');

  Check(DefaultSupport.GenerateHashCode(1) <> DefaultSupport.GenerateHashCode(2), '(Default) Expected hashcode 1 neq 2');
  Check(DefaultSupport.GenerateHashCode(1) = DefaultSupport.GenerateHashCode(1), '(Default) Expected hashcode 1 eq 1');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'Word', 'Type Name = "Word"');
  Check(DefaultSupport.Size = 2, 'Type Size = 2');
  Check(DefaultSupport.TypeInfo = TypeInfo(Word), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfUnsignedInteger, 'Type Family = tfUnsignedInteger');

  Check(DefaultSupport.GetString(029) = '29', '(Default) Expected GetString() = "29"')
end;

procedure TTestTypes.TestWordBool;
var
  DefaultSupport : IType<WordBool>;
begin
  DefaultSupport := TType<WordBool>.Default;

  { Default }
  Check(DefaultSupport.Compare(false, true) < 0, '(Default) Expected false < true');
  Check(DefaultSupport.Compare(true, false) > 0, '(Default) Expected true > false');
  Check(DefaultSupport.Compare(true, true) = 0, '(Default) Expected true = true');

  Check(DefaultSupport.AreEqual(false, false), '(Default) Expected false eq false');
  Check(not DefaultSupport.AreEqual(false, true), '(Default) Expected false neq true');

  Check(DefaultSupport.GenerateHashCode(false) <> DefaultSupport.GenerateHashCode(true), '(Default) Expected hashcode false neq true');
  Check(DefaultSupport.GenerateHashCode(false) = DefaultSupport.GenerateHashCode(false), '(Default) Expected hashcode false eq false');

  Check(DefaultSupport.Management() = tmNone, 'Type support = tmNone');

  Check(DefaultSupport.Name = 'WordBool', 'Type Name = "WordBool"');
  Check(DefaultSupport.Size = 2, 'Type Size = 2');
  Check(DefaultSupport.TypeInfo = TypeInfo(WordBool), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfBoolean, 'Type Family = tfBoolean');

  Check(DefaultSupport.GetString(true) = 'True', '(Default) Expected GetString() = "True"');
end;

procedure TTestTypes.TestWrapper1;
var
  LType: IType<TObject>;
  LWrap: TSuppressedWrapperType<TObject>;
  LIntType, LIntWrap: IType<Integer>;
begin
  LType := TClassType<TObject>.Create(true);
  LWrap := TSuppressedWrapperType<TObject>.Create(LType);

  Check(LWrap.Management = tmNone, 'Expected no cleanup for wrapper type!');
  Check(LWrap.Family = LType.Family, 'Family not propagated!');
  Check(LWrap.TypeInfo = LType.TypeInfo, 'TypeInfo not propagated!');
  Check(LWrap.Name = LType.Name, 'Name not propagated!');
  Check(LWrap.Size = LType.Size, 'Size not propagated!');
  Check(not LWrap.AllowCleanup, 'Default should now alow cleanup');

  LWrap.AllowCleanup := true;
  Check(LWrap.Management = tmManual, 'Expected MANUAL cleanup for allowed wrapper type!');
  LWrap.Free;

  { Test a wrapper integer }
  LIntType := TType<Integer>.Default;
  LIntWrap := TSuppressedWrapperType<Integer>.Create(LIntType);

  Check(LIntWrap.Compare(-1, 1) < 0, '(LIntWrap) Expected -1 < 1');
  Check(LIntWrap.Compare(1, -1) > 0, '(LIntWrap) Expected 1 > -1');
  Check(LIntWrap.Compare(-1, -1) = 0, '(LIntWrap) Expected -1 = -1');

  Check(LIntWrap.AreEqual(1, 1), '(LIntWrap) Expected 1 eq 1');
  Check(not LIntWrap.AreEqual(-1, 1), '(LIntWrap) Expected -1 neq 1');

  Check(LIntWrap.GenerateHashCode(-1) <> LIntWrap.GenerateHashCode(1), '(LIntWrap) Expected hashcode -1 neq 1');
  Check(LIntWrap.GenerateHashCode(1) = LIntWrap.GenerateHashCode(1), '(LIntWrap) Expected hashcode 1 eq 1');

  Check(LIntWrap.GetString(-89) = '-89', '(LIntWrap) Expected GetString() = "-89"')
end;

procedure TTestTypes.TestWrapper2;
var
  LIntType, LIntWrap: IType<Integer>;
begin
  { Test a wrapper integer }
  LIntType := TType<Integer>.Default;
  LIntWrap := TComparerWrapperType<Integer>.Create(LIntType,
    function(const ALeft, ARight: Integer): NativeInt
    begin
      Result := -1 * LIntType.Compare(ALeft, ARight);
    end,
    function(const AValue: Integer): NativeInt
    begin
      Result := 0;
    end
  );

  Check(LIntWrap.Compare(-1, 1) > 0, '(LIntWrap) Expected -1 > 1');
  Check(LIntWrap.Compare(1, -1) < 0, '(LIntWrap) Expected 1 < -1');
  Check(LIntWrap.Compare(-1, -1) = 0, '(LIntWrap) Expected -1 = -1');

  Check(LIntWrap.AreEqual(1, 1), '(LIntWrap) Expected 1 eq 1');
  Check(not LIntWrap.AreEqual(-1, 1), '(LIntWrap) Expected -1 neq 1');

  Check(LIntWrap.GenerateHashCode(-1) = LIntWrap.GenerateHashCode(1), '(LIntWrap) Expected hashcode -1 neq 1');
  Check(LIntWrap.GenerateHashCode(1) = LIntWrap.GenerateHashCode(1), '(LIntWrap) Expected hashcode 1 eq 1');
  Check(LIntWrap.GenerateHashCode(100) = 0, '(LIntWrap) Expected hashcode 0');
  Check(LIntWrap.GenerateHashCode(44) = 0, '(LIntWrap) Expected hashcode 44');
end;

procedure TTestTypes.TestWrapper0;
var
  LType: IType<TObject>;
  LWrap: TWrapperType<TObject>;
  LIntType, LIntWrap: IType<Integer>;
begin
  LType := TClassType<TObject>.Create(true);
  LWrap := TWrapperType<TObject>.Create(LType);

  Check(LWrap.Management = tmManual, 'Expected cleanup for wrapper type!');
  Check(LWrap.Family = LType.Family, 'Family not propagated!');
  Check(LWrap.TypeInfo = LType.TypeInfo, 'TypeInfo not propagated!');
  Check(LWrap.Name = LType.Name, 'Name not propagated!');
  Check(LWrap.Size = LType.Size, 'Size not propagated!');

  { Test a wrapper integer }
  LIntType := TType<Integer>.Default;
  LIntWrap := TWrapperType<Integer>.Create(LIntType);

  Check(LIntWrap.Compare(-1, 1) < 0, '(LIntWrap) Expected -1 < 1');
  Check(LIntWrap.Compare(1, -1) > 0, '(LIntWrap) Expected 1 > -1');
  Check(LIntWrap.Compare(-1, -1) = 0, '(LIntWrap) Expected -1 = -1');

  Check(LIntWrap.AreEqual(1, 1), '(LIntWrap) Expected 1 eq 1');
  Check(not LIntWrap.AreEqual(-1, 1), '(LIntWrap) Expected -1 neq 1');

  Check(LIntWrap.GenerateHashCode(-1) <> LIntWrap.GenerateHashCode(1), '(LIntWrap) Expected hashcode -1 neq 1');
  Check(LIntWrap.GenerateHashCode(1) = LIntWrap.GenerateHashCode(1), '(LIntWrap) Expected hashcode 1 eq 1');

  Check(LIntWrap.GetString(-89) = '-89', '(LIntWrap) Expected GetString() = "-89"')
end;

{ TMyCustomClassType }

function TMyCustomClassType.GetString(const AValue: TMyClass): String;
begin
  Result := 'This is my class!';
end;

initialization
  TestFramework.RegisterTest(TTestTypes.Suite);

end.
