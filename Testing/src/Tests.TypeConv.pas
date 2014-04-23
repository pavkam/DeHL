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
unit Tests.TypeConv;
interface
uses SysUtils, Variants, Math,
     Character,
     Tests.Utils,
     TestFramework,
     DeHL.Serialization,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Box,
     DeHL.References,
     DeHL.Nullable,
     DeHL.Tuples,
     DeHL.Strings,
     DeHL.Bytes,
     DeHL.Math.Half,
     DeHL.Math.BigCardinal,
     DeHL.Math.BigInteger,
     DeHL.Math.BigDecimal,
     DeHL.DateTime;

type
  TBigRec = record
    v: Int64;
    x: Int64;
  end;

  TRTTIBigRec = record
    s: String;
    v: Int64;
    x: Int64;
  end;

  TProcOfObject = procedure of object;

  TArrayOfInt = array of Integer;
  TBigArr = array[0..1] of Int64;
  TRTTIBigArr = array[0..1] of String;
  T3Bytes = packed array[0..2] of Byte;

  TTestTypeConvertions = class(TDeHLTestCase)
  private
    { Used in all tests }
    LVariant: Variant;

  private
    function EqFloats(const A, B: Extended): Boolean; overload;

    { Float Testing }
    procedure TestFromHalf(const AValue: Half);
    procedure TestToHalf(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromSingle(const AValue: Single);
    procedure TestToSingle(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromDouble(const AValue: Double);
    procedure TestToDouble(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromReal(const AValue: Real);
    procedure TestToReal(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromExtended(const AValue: Extended; const ExtNotValid: Boolean);
    procedure TestToExtended(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromComp(const AValue: Comp);
    procedure TestToComp(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromCurrency(const AValue: Currency);
    procedure TestToCurrency(const AVar: Variant; const VarNotValid: Boolean);

    { String Testing }
    procedure TestFromShortString(const AValue: ShortString);
    procedure TestToShortString(const AVar: Variant);

    procedure TestFromAnsiString(const AValue: AnsiString);
    procedure TestToAnsiString(const AVar: Variant);

    procedure TestFromWideString(const AValue: WideString);
    procedure TestToWideString(const AVar: Variant);

    procedure TestFromUnicodeString(const AValue: UnicodeString);
    procedure TestToUnicodeString(const AVar: Variant);

    procedure TestFromUTF8String(const AValue: UTF8String);
    procedure TestToUTF8String(const AVar: Variant);

    procedure TestFromString(const AValue: String);
    procedure TestToString(const AVar: Variant);

    procedure TestFromTString(const AValue: TString);
    procedure TestToTString(const AVar: Variant);

    procedure TestFromUCS4String(const AValue: UCS4String);
    procedure TestToUCS4String(const AVar: Variant);

    { Integer Testing }
    procedure TestFromByte(const AValue: Byte);
    procedure TestToByte(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromShortInt(const AValue: ShortInt);
    procedure TestToShortInt(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromWord(const AValue: Word);
    procedure TestToWord(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromSmallInt(const AValue: SmallInt);
    procedure TestToSmallInt(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromCardinal(const AValue: Cardinal);
    procedure TestToCardinal(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromNativeUInt(const AValue: NativeUInt);
    procedure TestToNativeUInt(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromInteger(const AValue: Integer);
    procedure TestToInteger(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromNativeInt(const AValue: NativeInt);
    procedure TestToNativeInt(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromUInt64(const AValue: UInt64);
    procedure TestToUInt64(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromInt64(const AValue: Int64);
    procedure TestToInt64(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromPointer(const AValue: Pointer);
    procedure TestToPointer(const AVar: Variant; const VarNotValid: Boolean);

    { Boolean testing }
    procedure TestFromBoolean(const AValue: Boolean);
    procedure TestToBoolean(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromByteBool(const AValue: ByteBool);
    procedure TestToByteBool(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromWordBool(const AValue: WordBool);
    procedure TestToWordBool(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromLongBool(const AValue: LongBool);
    procedure TestToLongBool(const AVar: Variant; const VarNotValid: Boolean);

    { Character Testing }
    procedure TestFromAnsiChar(const AValue: AnsiChar);
    procedure TestToAnsiChar(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromWideChar(const AValue: WideChar);
    procedure TestToWideChar(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromChar(const AValue: Char);
    procedure TestToChar(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromUCS4Char(const AValue: UCS4Char);
    procedure TestToUCS4Char(const AVar: Variant; const VarNotValid: Boolean);

    { Variant testing }
    procedure TestFromVariant(const AValue: Variant);
    procedure TestToVariant(const AVar: Variant);

    procedure TestFromOleVariant(const AValue: OleVariant);
    procedure TestToOleVariant(const AVar: Variant);

    { Others }
    procedure TestFromInterface(const AValue: IInterface);
    procedure TestToInterface();

    procedure TestFromAnonymousMethod(const AValue: TProc);
    procedure TestToAnonymousMethod();

    procedure TestFromRoutine(const AValue: TProcedure);
    procedure TestToRoutine(const AVar: Variant; const VarNotValid: Boolean);

    procedure TestFromMethod(const AValue: TProcOfObject);
    procedure TestToMethod();

    procedure TestFromClassRef(const AValue: TClass);
    procedure TestToClassRef();

    procedure TestFromClass(const AValue: TObject);
    procedure TestToClass();

    procedure TestFromRecord(const AValue: TBigRec);
    procedure TestToRecord();

    procedure TestFromRTTIRecord(const AValue: TRTTIBigRec);
    procedure TestToRTTIRecord();

    procedure TestFromArray(const AValue: TBigArr);
    procedure TestToArray();

    procedure TestFromRTTIArray(const AValue: TRTTIBigArr);
    procedure TestToRTTIArray();

    procedure TestFrom3Bytes(const AValue: T3Bytes);
    procedure TestTo3Bytes();

    procedure TestFromNullInteger(const AValue: Integer);
    procedure TestToNullInteger(const AVar: Variant; const VarNotValid: Boolean);

  published
    { Integer types }
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
    procedure TestPointer;

    { Char types }
    procedure TestAnsiChar;
    procedure TestWideChar;
    procedure TestChar;
    procedure TestUCS4Char;

    { System Dates }
    procedure TestSysDate;
    procedure TestSysDateTime;
    procedure TestSysTime;

    { Boolean types }
    procedure TestBoolean;
    procedure TestByteBool;
    procedure TestWordBool;
    procedure TestLongBool;

    { Float types }
    procedure TestSingle;
    procedure TestHalf;
    procedure TestDouble;
    procedure TestReal;
    procedure TestExtended;
    procedure TestComp;
    procedure TestCurrency;

    { String types }
    procedure TestString;
    procedure TestShortString;
    procedure TestAnsiString;
    procedure TestWideString;
    procedure TestUnicodeString;
    procedure TestUTF8String;
    procedure TestUCS4String;

    { Variant }
    procedure TestVariant;
    procedure TestOleVariant;

    { No-type-conv }
    procedure TestInterface;
    procedure TestClass;
    procedure TestRecord;
    procedure TestRecord_With_RTTI;
    procedure TestDynArray;
    procedure TestRawByteString;
    procedure TestStaticArray;
    procedure TestStaticArray_With_RTTI;
    procedure Test3Bytes;

    procedure TestClassRef;
    procedure TestRoutine;

    procedure TestAnonymousMethod;
    procedure TestMethod;

    { Own types }
    procedure TestBigCardinal;
    procedure TestBigInteger;
    procedure TestBigDecimal;
    procedure TestDate;
    procedure TestDateTime;
    procedure TestTime;
    procedure TestBox;
    procedure TestScoped;
    procedure TestShared;
    procedure TestWeak;
    procedure TestNullable;
    procedure TestTString;
    procedure TestBuffer;

    procedure TestTuple_1;
    procedure TestTuple_2;
    procedure TestTuple_3;
    procedure TestTuple_4;
    procedure TestTuple_5;
    procedure TestTuple_6;
    procedure TestTuple_7;

    procedure TestKVPair;
  end;

implementation


{ TTestTypeConvertions }

function TTestTypeConvertions.EqFloats(const A, B: Extended): Boolean;
begin
  try
    if IsInfinite(A) and IsInfinite(B) then
      Exit(true);
  except
    { nothing on error }
  end;

  if IsNan(A) and IsNan(B) then
    Exit(true);

  Result := System.Abs(A - B) < 0.001;
end;

procedure TTestTypeConvertions.Test3Bytes;
var
 a, b: T3Bytes;
begin
  a[0] := 1;
  b[0] := 100;

  TestFrom3Bytes(a);
  TestFrom3Bytes(b);
  TestTo3Bytes();
end;

procedure TTestTypeConvertions.TestAnonymousMethod;
var
  Intf: TProc;
begin
  Intf := procedure begin end;

  TestFromAnonymousMethod(Intf);
  TestFromAnonymousMethod(nil);
  TestToAnonymousMethod();
end;

procedure TTestTypeConvertions.TestAnsiChar;
begin
  TestFromAnsiChar('A');
  TestFromAnsiChar(Low(AnsiChar));
  TestFromAnsiChar(High(AnsiChar));

  TestToAnsiChar('', true);
  TestToAnsiChar(false, false);
  TestToAnsiChar(12.0, false);
  TestToAnsiChar(33, false);
  TestToAnsiChar('1', false);
  TestToAnsiChar('z', false);
end;

procedure TTestTypeConvertions.TestAnsiString;
begin
  TestFromAnsiString('');
  TestFromAnsiString('Hello World');

  TestToAnsiString('');
  TestToAnsiString(-22.2);
  TestToAnsiString(Now);
  TestToAnsiString(false);
end;

procedure TTestTypeConvertions.TestBigCardinal;
var
  II: IType<BigCardinal>;
  BC: BigCardinal;
  V: Variant;
begin
  II := TType<BigCardinal>.Default;

  { Test From BigCardinal }
  BC := BigCardinal.Parse('3217898990328019376215315672563761235521763512673567123440908109174083265479134');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  BC := BigCardinal.Parse('0');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  BC := BigCardinal.Parse('$FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  { Test To Big Cardinal }
  V := BigCardinal.Parse('3217898990328019376215315672563761235521763512673567123440908109174083265479134');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := BigCardinal.Parse('0');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := BigCardinal.Parse('$FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := 10;
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := 41342434;
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := '111';
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  { Expected Errors }

  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, BC));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := 1.0092;
  Check(not II.TryConvertFromVariant(V, BC));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := Now;
  Check(not II.TryConvertFromVariant(V, BC));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestBigDecimal;
var
  II: IType<BigDecimal>;
  BC: BigDecimal;
  V: Variant;
begin
  II := TType<BigDecimal>.Default;

  { Test From BigInteger }
  BC := BigDecimal.Parse('-3217898990328019376215315672563761235521763' + DecimalSeparator + '512673567123440908109174083265479134');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  BC := BigDecimal.Parse('0');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  BC := BigDecimal.Parse('17772882771' + DecimalSeparator + '0000011');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  { Test To BigDecimal }
  V := BigDecimal.Parse('-3217898990328019376215315672563761235521763512673567123440908109174083265479134');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := BigDecimal.Parse('0');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := BigDecimal.Parse('3213213123111111222222222' + DecimalSeparator + '888');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := -10;
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := 41342434;
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := '-111';
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString(false) = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  { Expected Errors }

  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, BC));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestBigInteger;
var
  II: IType<BigInteger>;
  BC: BigInteger;
  V: Variant;
begin
  II := TType<BigInteger>.Default;

  { Test From BigInteger }
  BC := BigInteger.Parse('-3217898990328019376215315672563761235521763512673567123440908109174083265479134');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  BC := BigInteger.Parse('0');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  BC := BigInteger.Parse('$FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  Check(II.TryConvertToVariant(BC, V) and (V = Variant(BC)));
  Check(II.ConvertToVariant(BC) = V);

  { Test To BigInteger }
  V := BigInteger.Parse('-3217898990328019376215315672563761235521763512673567123440908109174083265479134');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := BigInteger.Parse('0');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := BigInteger.Parse('$FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := -10;
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := 41342434;
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  V := '-111';
  Check(II.TryConvertFromVariant(V, BC) and (BC.ToString = V));
  Check(II.ConvertFromVariant(V) = BC.ToString);

  { Expected Errors }

  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, BC));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := 1.0092;
  Check(not II.TryConvertFromVariant(V, BC));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := Now;
  Check(not II.TryConvertFromVariant(V, BC));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestBoolean;
begin
  TestFromBoolean(true);
  TestFromBoolean(false);

  TestToBoolean('', true);
  TestToBoolean('0', false);
  TestToBoolean('12', false);
  TestToBoolean(67, false);
  TestToBoolean(true, false);
  TestToBoolean(false, false);
end;

procedure TTestTypeConvertions.TestBox;
var
  II: IType<TBox<Integer>>;
  Box: TBox<Integer>;
begin
  II := TType<TBox<Integer>>.Default();
  Box := TBox<Integer>.Create(100);

  Check(not II.TryConvertToVariant(Box, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(Box);
  end, '');

  Check(not II.TryConvertFromVariant('23', Box));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(23);
  end, '');

  Box.Free;
end;

procedure TTestTypeConvertions.TestBuffer;
var
  II: IType<TBuffer>;
  LVar: Variant;
  LVal: TBuffer;
begin
  { ... to variant }
  II := TBuffer.GetType;

  LVal := TBuffer.Create('Hello');

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = Ord('H'), 'Expected Variant 1 = H');
  Check(LVar[1] = Ord('e'), 'Expected Variant 2 = e');
  Check(LVar[2] = Ord('l'), 'Expected Variant 3 = l');
  Check(LVar[3] = Ord('l'), 'Expected Variant 4 = l');
  Check(LVar[4] = Ord('o'), 'Expected Variant 5 = o');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = Ord('H'), 'Expected Variant 1 = H');
  Check(LVar[1] = Ord('e'), 'Expected Variant 2 = e');
  Check(LVar[2] = Ord('l'), 'Expected Variant 3 = l');
  Check(LVar[3] = Ord('l'), 'Expected Variant 4 = l');
  Check(LVar[4] = Ord('o'), 'Expected Variant 5 = o');

  { ... from variant }
  LVar := VarArrayOf([Ord('H'), Ord('a')]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal[0] = Ord('H'), 'Expected 1 = H');
  Check(LVal[1] = Ord('a'), 'Expected 2 = a');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal[0] = Ord('H'), 'Expected 1 = H');
  Check(LVal[1] = Ord('a'), 'Expected 2 = a');

  { ... error stuff }
  LVar := VarArrayOf([]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');


  LVar := VarArrayOf(['hahaha']);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestByte;
begin
  TestFromByte(High(Byte));
  TestFromByte(Low(Byte));

  TestToByte('', true);
  TestToByte('0', false);
  TestToByte('12', false);
  TestToByte(67, false);
end;

procedure TTestTypeConvertions.TestByteBool;
begin
  TestFromByteBool(true);
  TestFromByteBool(false);

  TestToByteBool('', true);
  TestToByteBool('0', false);
  TestToByteBool('12', false);
  TestToByteBool(67, false);
  TestToByteBool(true, false);
  TestToByteBool(false, false);
end;

procedure TTestTypeConvertions.TestCardinal;
begin
  TestFromCardinal(High(Cardinal));
  TestFromCardinal(Low(Cardinal));

  TestToCardinal('', true);
  TestToCardinal('0', false);
  TestToCardinal(12.0, false);
  TestToCardinal(55, false);
end;

procedure TTestTypeConvertions.TestChar;
begin
  TestFromChar('A');
  TestFromChar(Low(Char));
  TestFromChar(High(Char));

  TestToChar('', true);
  TestToChar(false, false);
  TestToChar(12.0, false);
  TestToChar(33, false);
  TestToChar('1', false);
  TestToChar('z', false);
end;

procedure TTestTypeConvertions.TestClass;
begin
  TestFromClass(TInterfacedObject.Create);
  TestFromClass(nil);
  TestToClass();
end;

procedure TTestTypeConvertions.TestClassRef;
var
  Intf: TClass;
begin
  Intf := TTestTypeConvertions;

  TestFromClassRef(Intf);
  TestFromClassRef(nil);
  TestToClassRef();
end;

procedure TTestTypeConvertions.TestComp;
begin
  TestFromComp(1323123.3123444);
  TestFromComp(-11788775.222);
  TestFromComp(0);

  TestToComp('--', true);
  TestToComp('0', false);
  TestToComp(12.001, false);
  TestToComp(false, false);
end;

procedure TTestTypeConvertions.TestCurrency;
begin
  TestFromCurrency(66788.67);
  TestFromCurrency(43332.88);
  TestFromCurrency(0);

  TestToCurrency('--', true);
  TestToCurrency('0', false);
  TestToCurrency(12.001, false);
  TestToCurrency(false, false);
end;

procedure TTestTypeConvertions.TestDate;
var
  II: IType<TDate>;
  RDT: System.TDateTime;
  DT: TDate;
  V: Variant;
begin
  II := TType<TDate>.Default;

  { Check TDate to Variant }
  RDT := Now;
  DT := TDate.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  RDT := 1;
  DT := TDate.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  RDT := 122.5;
  DT := TDate.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  { Check Variant to TDate }
  RDT := Now;
  DT := TDate.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 1;
  DT := TDate.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 122.5;
  DT := TDate.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 0;
  DT := TDate.Create(RDT);
  V := false;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  { Known error conditions }
  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := DateToStr(Now);
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := '';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := BigCardinal.Parse('894723984739847239847329982');
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestDateTime;
var
  II: IType<TDateTime>;
  RDT: System.TDateTime;
  DT: TDateTime;
  V: Variant;
begin
  II := TType<TDateTime>.Default;

  { Check TDateTime to Variant }
  RDT := Now;
  DT := TDateTime.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  RDT := 1;
  DT := TDateTime.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  RDT := 122.5;
  DT := TDateTime.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  { Check Variant to TDateTime }
  RDT := Now;
  DT := TDateTime.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 1;
  DT := TDateTime.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 122.5;
  DT := TDateTime.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 0;
  DT := TDateTime.Create(RDT);
  V := false;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  V := BigCardinal.Parse('894424234');
  RDT := V;
  DT := TDateTime.Create(RDT);
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  { Known error conditions }
  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := DateTimeToStr(Now);
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := '';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestDouble;
begin
  TestFromDouble(MaxDouble);
  TestFromDouble(MinDouble);
  TestFromDouble(0);

  TestToDouble('--', true);
  TestToDouble('0', false);
  TestToDouble(12.001, false);
  TestToDouble(false, false);
end;

procedure TTestTypeConvertions.TestDynArray;
var
  II: IType<TArrayOfInt>;
  LType: TArrayOfInt;
  V: Variant;
begin
  II := TType<TArrayOfInt>.Default;

  { ... from variant }
  Check(not II.TryConvertFromVariant(VarArrayOf([]), LType), 'Should have failed');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(VarArrayOf([]));
  end, '');

  Check(II.TryConvertFromVariant(VarArrayOf([1, 2, 3]), LType), '<- Variant failed');
  Check(Length(LType) = 3, 'Length = 3');
  Check(LType[0] = 1, '[0] = 1');
  Check(LType[1] = 2, '[1] = 2');
  Check(LType[2] = 3, '[2] = 3');

  LType := nil;
  V := VarArrayOf([1, 2, 3]);

  LType := II.ConvertFromVariant(V);

  Check(Length(LType) = 3, 'Length = 3');
  Check(LType[0] = 1, '[0] = 1');
  Check(LType[1] = 2, '[1] = 2');
  Check(LType[2] = 3, '[2] = 3');

  LType := II.ConvertFromVariant(VarArrayOf(['1', 2.0]));

  Check(Length(LType) = 2, 'Length = 2');
  Check(LType[0] = 1, '[0] = 1');
  Check(LType[1] = 2, '[1] = 2');

  { ... to variant }
  LType := TArrayOfInt.Create(10, 15, 20);
  Check(II.TryConvertToVariant(LType, LVariant), '-> Variant failed');

  Check(VarArrayHighBound(LVariant, 1) = 2, 'Length = 3');
  Check(LVariant[0] = 10, '[0] = 10');
  Check(LVariant[1] = 15, '[1] = 15');
  Check(LVariant[2] = 20, '[2] = 20');

  LVariant := II.ConvertToVariant(LType);
  Check(VarArrayHighBound(LVariant, 1) = 2, 'Length = 3');
  Check(LVariant[0] = 10, '[0] = 10');
  Check(LVariant[1] = 15, '[1] = 15');
  Check(LVariant[2] = 20, '[2] = 20');

  LType := nil;
  LVariant := II.ConvertToVariant(LType);
  Check(VarArrayHighBound(LVariant, 1) = -1, 'Length = 0');
end;

procedure TTestTypeConvertions.TestExtended;
begin
  TestFromExtended(MaxExtended, true);
  TestFromExtended(MinExtended, false);
  TestFromExtended(0, false);
  TestFromExtended(-0.2234, false);
  TestFromExtended(2272.1125, false);

  TestToExtended('--', true);
  TestToExtended('0', false);
  TestToExtended(12.001, false);
  TestToExtended(false, false);
end;

procedure TTestTypeConvertions.TestFrom3Bytes(const AValue: T3Bytes);
var
  II: IType<T3Bytes>;
  VValue: T3Bytes;
begin
  II := TType<T3Bytes>.Default;
  VValue := AValue;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(VValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromAnonymousMethod(const AValue: TProc);
var
  II: IType<TProc>;
begin
  II := TType<TProc>.Default;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(AValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromAnsiChar(const AValue: AnsiChar);
var
  II: IType<AnsiChar>;
begin
  II := TType<AnsiChar>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (AnsiString(LVariant) = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromAnsiString(const AValue: AnsiString);
var
  II: IType<AnsiString>;
  VValue: AnsiString;
begin
  II := TType<AnsiString>.Default;
  VValue := AValue;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromArray(const AValue: TBigArr);
var
  II: IType<TBigArr>;
  VValue: TBigArr;
begin
  II := TType<TBigArr>.Default;
  VValue := AValue;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(VValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromBoolean(const AValue: Boolean);
var
  II: IType<Boolean>;
begin
  II := TType<Boolean>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromByte(const AValue: Byte);
var
  II: IType<Byte>;
begin
  II := TType<Byte>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromByteBool(const AValue: ByteBool);
var
  II: IType<ByteBool>;
begin
  II := TType<ByteBool>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromCardinal(const AValue: Cardinal);
var
  II: IType<Cardinal>;
begin
  II := TType<Cardinal>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromChar(const AValue: Char);
var
  II: IType<Char>;
begin
  II := TType<Char>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = String(AValue)));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromClass(const AValue: TObject);
var
  II: IType<TObject>;
begin
  II := TType<TObject>.Default;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(AValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromClassRef(const AValue: TClass);
var
  II: IType<TClass>;
begin
  II := TType<TClass>.Default;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(AValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromComp(const AValue: Comp);
var
  II: IType<Comp>;

begin
  II := TType<Comp>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromCurrency(const AValue: Currency);
var
  II: IType<Currency>;

begin
  II := TType<Currency>.Default;

  Check(II.TryConvertToVariant(AValue, LVariant) and (EqFloats(AValue, LVariant)));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromDouble(const AValue: Double);
var
  II: IType<Double>;

begin
  II := TType<Double>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;


procedure TTestTypeConvertions.TestFromExtended(const AValue: Extended; const ExtNotValid: Boolean);
var
  II: IType<Extended>;

begin
  II := TType<Extended>.Default;

  if not ExtNotValid then
  begin
    Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
    Check(II.ConvertToVariant(AValue) = LVariant);
  end else
  begin
    Check(not II.TryConvertToVariant(AValue, LVariant));

    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertToVariant(AValue);
    end, '');
  end;
end;

procedure TTestTypeConvertions.TestFromHalf(const AValue: Half);
var
  II: IType<Half>;

begin
  II := TType<Half>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromInt64(const AValue: Int64);
var
  II: IType<Int64>;
begin
  II := TType<Int64>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromInteger(const AValue: Integer);
var
  II: IType<Integer>;
begin
  II := TType<Integer>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromInterface(const AValue: IInterface);
var
  II: IType<IInterface>;
begin
  II := TType<IInterface>.Default;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(AValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromLongBool(const AValue: LongBool);
var
  II: IType<LongBool>;
begin
  II := TType<LongBool>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromMethod(const AValue: TProcOfObject);
var
  II: IType<TProcOfObject>;
begin
  II := TType<TProcOfObject>.Default;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(AValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromNativeInt(const AValue: NativeInt);
var
  II: IType<NativeInt>;
begin
  II := TType<NativeInt>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromNativeUInt(const AValue: NativeUInt);
var
  II: IType<NativeUInt>;
begin
  II := TType<NativeUInt>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromNullInteger(const AValue: Integer);
var
  II: IType<Nullable<Integer>>;
begin
  II := TNullableType<Integer>.Create;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromOleVariant(const AValue: OleVariant);
var
  II: IType<OleVariant>;
begin
  II := TType<OleVariant>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromPointer(const AValue: Pointer);
var
  II: IType<Pointer>;
begin
  II := TType<Pointer>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = Cardinal(AValue)));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromReal(const AValue: Real);
var
  II: IType<Real>;

begin
  II := TType<Real>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromRecord(
  const AValue: TBigRec);
var
  II: IType<TBigRec>;
  VValue: TBigRec;
begin
  II := TType<TBigRec>.Default;
  VValue := AValue;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(VValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromRoutine(const AValue: TProcedure);
var
  II: IType<TProcedure>;
begin
  II := TType<TProcedure>.Default;

  Check(II.TryConvertToVariant(AValue, LVariant) and (LVariant = Cardinal(@AValue)));
  Check(II.ConvertToVariant(AValue) = Cardinal(@AValue));
end;

procedure TTestTypeConvertions.TestFromRTTIArray(
  const AValue: TRTTIBigArr);
var
  II: IType<TRTTIBigArr>;
  VValue: TRTTIBigArr;
begin
  II := TType<TRTTIBigArr>.Default;
  VValue := AValue;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(VValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromRTTIRecord(
  const AValue: TRTTIBigRec);
var
  II: IType<TRTTIBigRec>;
  VValue: TRTTIBigRec;
begin
  II := TType<TRTTIBigRec>.Default;
  VValue := AValue;

  Check(not II.TryConvertToVariant(AValue, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(VValue);
  end, '');
end;

procedure TTestTypeConvertions.TestFromShortInt(const AValue: ShortInt);
var
  II: IType<ShortInt>;
begin
  II := TType<ShortInt>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromShortString(const AValue: ShortString);
var
  II: IType<ShortString>;
  VValue: ShortString;
begin
  II := TType<ShortString>.Default;
  VValue := AValue;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromSingle(const AValue: Single);
var
  II: IType<Single>;

begin
  II := TType<Single>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromSmallInt(const AValue: SmallInt);
var
  II: IType<SmallInt>;
begin
  II := TType<SmallInt>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromString(const AValue: String);
var
  II: IType<String>;
  VValue: UnicodeString;
begin
  II := TType<String>.Default;
  VValue := AValue;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromTString(const AValue: TString);
var
  II: IType<TString>;
  VValue: UnicodeString;
begin
  II := TType<TString>.Default;
  VValue := AValue;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromUCS4Char(const AValue: UCS4Char);
var
  II: IType<UCS4Char>;
begin
  II := TType<UCS4Char>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = ConvertFromUtf32(AValue)));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromUCS4String(const AValue: UCS4String);
var
  II: IType<UCS4String>;
begin
  II := TType<UCS4String>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = UCS4StringToUnicodeString(AValue)));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromUInt64(const AValue: UInt64);
var
  II: IType<UInt64>;
begin
  II := TType<UInt64>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromUnicodeString(const AValue: UnicodeString);
var
  II: IType<UnicodeString>;
begin
  II := TType<UnicodeString>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromUTF8String(const AValue: UTF8String);
var
  II: IType<UTF8String>;
begin
  II := TType<UTF8String>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromVariant(const AValue: Variant);
var
  II: IType<Variant>;
begin
  II := TType<Variant>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromWideChar(const AValue: WideChar);
var
  II: IType<WideChar>;
begin
  II := TType<WideChar>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = WideString(AValue)));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromWideString(const AValue: WideString);
var
  II: IType<WideString>;
begin
  II := TType<WideString>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromWord(const AValue: Word);
var
  II: IType<Word>;
begin
  II := TType<Word>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestFromWordBool(const AValue: WordBool);
var
  II: IType<WordBool>;
begin
  II := TType<WordBool>.Default;

  Check((II.TryConvertToVariant(AValue, LVariant)) and (LVariant = AValue));
  Check(II.ConvertToVariant(AValue) = LVariant);
end;

procedure TTestTypeConvertions.TestHalf;
begin
  TestFromHalf(MaxHalf);
  TestFromHalf(MinHalf);
  TestFromHalf(0);

  TestToHalf('--', true);
  TestToHalf('0', false);
  TestToHalf(12.001, false);
  TestToHalf(false, false);
end;

procedure TTestTypeConvertions.TestInt64;
begin
  TestFromInt64(0);
  TestFromInt64(High(Int64));
  TestFromInt64(Low(Int64));

  TestToInt64('', true);
  TestToInt64('0', false);
  TestToInt64(12.0, false);
  TestToInt64(false, false);
end;

procedure TTestTypeConvertions.TestInteger;
begin
  TestFromInteger(0);
  TestFromInteger(High(Integer));
  TestFromInteger(Low(Integer));

  TestToInteger('', true);
  TestToInteger('0', false);
  TestToInteger(12.0, false);
  TestToInteger(false, false);
end;

procedure TTestTypeConvertions.TestInterface;
var
  Intf: IInterface;
begin
  Intf := TInterfacedObject.Create;

  TestFromInterface(Intf);
  TestFromInterface(nil);
  TestToInterface();
end;

procedure TTestTypeConvertions.TestKVPair;
var
  II: IType<KVPair<Integer, Integer>>;
  LVar: Variant;
  LVal: KVPair<Integer, Integer>;
begin
  { ... to variant }
  II := KVPair.GetType<Integer, Integer>(TType<Integer>.Default, TType<Integer>.Default);
  LVal := KVPair<Integer, Integer>.Create(10, 20);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant key = 10');
  Check(LVar[1] = 20, 'Expected Variant value = 20');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant key = 10');
  Check(LVar[1] = 20, 'Expected Variant value = 20');

  { ... from variant }
  LVar := VarArrayOf([10, 20]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Key = 10, 'Expected key = 10');
  Check(LVal.Value = 20, 'Expected value = 20');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Key = 10, 'Expected key = 10');
  Check(LVal.Value = 20, 'Expected value = 20');

  { ... error stuff }
  LVar := VarArrayOf([10]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 200, 1]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf(['lolo', 1]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestLongBool;
begin
  TestFromLongBool(true);
  TestFromLongBool(false);

  TestToLongBool('', true);
  TestToLongBool('0', false);
  TestToLongBool('12', false);
  TestToLongBool(67, false);
  TestToLongBool(true, false);
  TestToLongBool(false, false);
end;

procedure TTestTypeConvertions.TestMethod;
var
  Intf: TProcOfObject;
begin
  Intf := TestMethod;

  TestFromMethod(Intf);
  TestFromMethod(nil);
  TestToMethod();
end;

procedure TTestTypeConvertions.TestNativeInt;
begin
  TestFromNativeInt(0);
  TestFromNativeInt(High(NativeInt));
  TestFromNativeInt(Low(NativeInt));

  TestToNativeInt('', true);
  TestToNativeInt('0', false);
  TestToNativeInt(12.0, false);
  TestToNativeInt(false, false);
end;

procedure TTestTypeConvertions.TestNativeUInt;
begin
  TestFromNativeUInt(High(NativeUInt));
  TestFromNativeUInt(Low(NativeUInt));

  TestToNativeUInt('', true);
  TestToNativeUInt('0', false);
  TestToNativeUInt(12.0, false);
  TestToNativeUInt(55, false);
end;

procedure TTestTypeConvertions.TestNullable;
begin
  TestFromNullInteger(0);
  TestFromNullInteger(High(Integer));
  TestFromNullInteger(Low(Integer));

  TestToNullInteger('', true);
  TestToNullInteger('0', false);
  TestToNullInteger(12.0, false);
  TestToNullInteger(false, false);
end;

procedure TTestTypeConvertions.TestOleVariant;
begin
  TestFromOleVariant('');
  TestFromOleVariant('Hello World');
  TestFromOleVariant(22);
  TestFromOleVariant(Now);
  TestFromOleVariant(true);

  TestToOleVariant(0);
  TestToOleVariant('-1');
  TestToOleVariant(Now);
  TestToOleVariant(1.1);
end;

procedure TTestTypeConvertions.TestPointer;
begin
  TestFromPointer(Ptr(High(Cardinal)));
  TestFromPointer(Ptr(Low(Cardinal)));

  TestToPointer('', true);
  TestToPointer('0', false);
  TestToPointer(12.0, false);
  TestToPointer(55, false);
end;

procedure TTestTypeConvertions.TestRawByteString;
var
  II: IType<RawByteString>;
  LVar: Variant;
  LVal: RawByteString;
begin
  { ... to variant }
  II := TType<RawByteString>.Default;
  LVal := 'Hello';

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = Ord('H'), 'Expected Variant 1 = H');
  Check(LVar[1] = Ord('e'), 'Expected Variant 2 = e');
  Check(LVar[2] = Ord('l'), 'Expected Variant 3 = l');
  Check(LVar[3] = Ord('l'), 'Expected Variant 4 = l');
  Check(LVar[4] = Ord('o'), 'Expected Variant 5 = o');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = Ord('H'), 'Expected Variant 1 = H');
  Check(LVar[1] = Ord('e'), 'Expected Variant 2 = e');
  Check(LVar[2] = Ord('l'), 'Expected Variant 3 = l');
  Check(LVar[3] = Ord('l'), 'Expected Variant 4 = l');
  Check(LVar[4] = Ord('o'), 'Expected Variant 5 = o');

  { ... from variant }
  LVar := VarArrayOf([Ord('H'), Ord('a')]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal[1] = 'H', 'Expected 1 = H');
  Check(LVal[2] = 'a', 'Expected 2 = a');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal[1] = 'H', 'Expected 1 = H');
  Check(LVal[2] = 'a', 'Expected 2 = a');

  { ... error stuff }
  LVar := VarArrayOf([]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  LVar := VarArrayOf(['hahaha']);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestReal;
begin
  TestFromReal(MaxDouble);
  TestFromReal(MinDouble);
  TestFromReal(0);

  TestToReal('--', true);
  TestToReal('0', false);
  TestToReal(12.001, false);
  TestToReal(false, false);
end;

procedure TTestTypeConvertions.TestRecord;
var
 a, b: TBigRec;
begin
  a.v := 1;
  b.v := 100;

  TestFromRecord(a);
  TestFromRecord(b);
  TestToRecord();
end;

procedure TTestTypeConvertions.TestRecord_With_RTTI;
var
 a, b: TRTTIBigRec;
begin
  a.s := '1';
  b.s := '100';

  TestFromRTTIRecord(a);
  TestFromRTTIRecord(b);
  TestToRTTIRecord();
end;

procedure TestProc;
begin

end;

procedure TTestTypeConvertions.TestRoutine;
begin
  TestFromRoutine(TestProc);
  TestFromRoutine(Ptr(Low(Cardinal)));

  TestToRoutine('', true);
  TestToRoutine('0', false);
  TestToRoutine(12.0, false);
  TestToRoutine(55, false);
end;

procedure TTestTypeConvertions.TestScoped;
var
  II: IType<Scoped<TObject>>;
  LObj: Scoped<TObject>;
begin
  II := Reference.GetScopedType<TObject>;
  LObj := TObject.Create();

  Check(not II.TryConvertToVariant(LObj, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(LObj);
  end, '');

  Check(not II.TryConvertFromVariant('23', LObj));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(23);
  end, '');
end;

procedure TTestTypeConvertions.TestShared;
var
  II: IType<Shared<TObject>>;
  LObj: Shared<TObject>;
begin
  II := Reference.GetSharedType<TObject>;
  LObj := TObject.Create();

  Check(not II.TryConvertToVariant(LObj, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(LObj);
  end, '');

  Check(not II.TryConvertFromVariant('23', LObj));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(23);
  end, '');
end;

procedure TTestTypeConvertions.TestShortInt;
begin
  TestFromShortInt(0);
  TestFromShortInt(High(ShortInt));
  TestFromShortInt(Low(ShortInt));

  TestToShortInt('', true);
  TestToShortInt('0', false);
  TestToShortInt(12.0, false);
  TestToShortInt(false, false);
end;

procedure TTestTypeConvertions.TestShortString;
begin
  TestFromShortString('');
  TestFromShortString('Hello World');

  TestToShortString('');
  TestToShortString(-22.2);
  TestToShortString(Now);
  TestToShortString(false);
end;

procedure TTestTypeConvertions.TestSingle;
begin
  TestFromSingle(MaxSingle);
  TestFromSingle(MinSingle);
  TestFromSingle(0);

  TestToSingle('--', true);
  TestToSingle('0', false);
  TestToSingle(12.001, false);
  TestToSingle(false, false);
end;

procedure TTestTypeConvertions.TestSmallInt;
begin
  TestFromSmallInt(0);
  TestFromSmallInt(High(ShortInt));
  TestFromSmallInt(Low(ShortInt));

  TestToSmallInt('', true);
  TestToSmallInt('0', false);
  TestToSmallInt(12.0, false);
  TestToSmallInt(false, false);
end;

procedure TTestTypeConvertions.TestStaticArray;
var
 a, b: TBigArr;
begin
  a[0] := 1;
  b[0] := 100;

  TestFromArray(a);
  TestFromArray(b);
  TestToArray();
end;

procedure TTestTypeConvertions.TestStaticArray_With_RTTI;
var
 a, b: TRTTIBigArr;
begin
  a[0] := '1';
  b[0] := '100';

  TestFromRTTIArray(a);
  TestFromRTTIArray(b);
  TestToRTTIArray();
end;

procedure TTestTypeConvertions.TestString;
begin
  TestFromString('');
  TestFromString('Hello World');

  TestToString('');
  TestToString(-22.2);
  TestToString(Now);
  TestToString(false);
end;

procedure TTestTypeConvertions.TestSysDate;
var
  II: IType<System.TDate>;
  DT: System.TDate;
  V: Variant;
begin
  II := TType<System.TDate>.Default;

  { Check TDate to Variant }
  DT := Now;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  DT := 1;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  DT := 122.5;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  { Check Variant to TDate }
  DT := Now;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 1;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 122.5;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 0;
  V := false;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  { Known error conditions }
  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := DateToStr(Now);
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := '';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestSysDateTime;
var
  II: IType<System.TDateTime>;
  DT: System.TDateTime;
  V: Variant;
begin
  II := TType<System.TDateTime>.Default;

  { Check TDateTime to Variant }
  DT := Now;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  DT := 1;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  DT := 122.5;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  { Check Variant to TDateTime }
  DT := Now;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 1;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 122.5;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 0;
  V := false;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  { Known error conditions }
  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := DateTimeToStr(Now);
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := '';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestSysTime;
var
  II: IType<System.TTime>;
  DT: System.TTime;
  V: Variant;
begin
  II := TType<System.TTime>.Default;

  { Check TTime to Variant }
  DT := Now;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  DT := 1;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  DT := 122.5;
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  { Check Variant to TTime }
  DT := Now;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 1;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 122.5;
  V := DT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  DT := 0;
  V := false;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  { Known error conditions }
  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := TimeToStr(Now);
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := '';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestTime;
var
  II: IType<TTime>;
  RDT: System.TTime;
  DT: TTime;
  V: Variant;
begin
  II := TType<TTime>.Default;

  { Check TTime to Variant }
  RDT := Now;
  DT := TTime.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  RDT := 1;
  DT := TTime.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  RDT := 122.5;
  DT := TTime.Create(RDT);
  Check(II.TryConvertToVariant(DT, V) and (V = DT));
  Check(II.ConvertToVariant(DT) = V);

  { Check Variant to TTime }
  RDT := Now;
  DT := TTime.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 1;
  DT := TTime.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 122.5;
  DT := TTime.Create(RDT);
  V := RDT;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  RDT := 0;
  DT := TTime.Create(RDT);
  V := false;
  Check(II.TryConvertFromVariant(V, DT) and (V = DT));
  Check(II.ConvertFromVariant(V) = DT);

  { Known error conditions }
  V := 'Hello';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := TimeToStr(Now);
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := '';
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');

  V := BigCardinal.Parse('894723984739847239847329982');
  Check(not II.TryConvertFromVariant(V, DT));
  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(V);
  end, '');
end;

procedure TTestTypeConvertions.TestTo3Bytes;
var
  II: IType<T3Bytes>;
  LType: T3Bytes;
begin
  II := TType<T3Bytes>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToAnonymousMethod;
var
  II: IType<TProc>;
  LType: TProc;
begin
  II := TType<TProc>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToAnsiChar(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<AnsiChar>;
  X: AnsiChar;
  v: Variant;
begin
  { Obtain type support }
  II := TType<AnsiChar>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AnsiString(AVar)[1]));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AnsiString(AVar)[1]);
  end;
end;

procedure TTestTypeConvertions.TestToAnsiString(const AVar: Variant);
var
  II: IType<AnsiString>;
  X: AnsiString;
begin
  { Obtain type support }
  II := TType<AnsiString>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = AnsiString(AVar)));
  Check(II.ConvertFromVariant(AVar) = AnsiString(AVar));
end;

procedure TTestTypeConvertions.TestToArray;
var
  II: IType<TBigArr>;
  LType: TBigArr;
begin
  II := TType<TBigArr>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToBoolean(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Boolean>;
  X: Boolean;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Boolean>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = Boolean(AVar)));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = Boolean(AVar));
  end;
end;

procedure TTestTypeConvertions.TestToByte(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Byte>;
  X: Byte;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Byte>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToByteBool(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<ByteBool>;
  X: ByteBool;
  v: Variant;
begin
  { Obtain type support }
  II := TType<ByteBool>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = ByteBool(AVar)));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = ByteBool(AVar));
  end;
end;

procedure TTestTypeConvertions.TestToCardinal(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Cardinal>;
  X: Cardinal;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Cardinal>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToChar(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Char>;
  X: Char;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Char>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = String(AVar)[1]));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = String(AVar)[1]);
  end;
end;

procedure TTestTypeConvertions.TestToClass;
var
  II: IType<TObject>;
  LType: TObject;
begin
  II := TType<TObject>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToClassRef;
var
  II: IType<TClass>;
  LType: TClass;
begin
  II := TType<TClass>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToComp(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Double>;
  X: Double;
  v: Variant;

begin
  { Obtain type support }
  II := TType<Double>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check(II.TryConvertFromVariant(AVar, X) and EqFloats(X, AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(EqFloats(II.ConvertFromVariant(AVar), Single(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToCurrency(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Currency>;
  X: Currency;
  v: Variant;

begin
  { Obtain type support }
  II := TType<Currency>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check(II.TryConvertFromVariant(AVar, X) and EqFloats(X, AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(EqFloats(II.ConvertFromVariant(AVar), Single(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToDouble(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Double>;
  X: Double;
  v: Variant;

begin
  { Obtain type support }
  II := TType<Double>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check(II.TryConvertFromVariant(AVar, X) and EqFloats(X, AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(EqFloats(II.ConvertFromVariant(AVar), Single(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToExtended(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Extended>;
  X: Extended;
  v: Variant;

begin
  { Obtain type support }
  II := TType<Extended>.Default;
  v := AVar;

  if VarNotValid then
  begin

    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check(II.TryConvertFromVariant(AVar, X) and EqFloats(X, AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(EqFloats(II.ConvertFromVariant(AVar), Single(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToHalf(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Half>;
  X: Half;
  v: Variant;

begin
  { Obtain type support }
  II := TType<Half>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check(II.TryConvertFromVariant(AVar, X) and EqFloats(X, AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(EqFloats(II.ConvertFromVariant(AVar), Half(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToInt64(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Int64>;
  X: Int64;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Int64>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToInteger(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Integer>;
  X: Integer;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Integer>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToInterface;
var
  II: IType<IInterface>;
  LType: IInterface;
begin
  II := TType<IInterface>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToLongBool(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<LongBool>;
  X: LongBool;
  v: Variant;
begin
  { Obtain type support }
  II := TType<LongBool>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = LongBool(AVar)));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = LongBool(AVar));
  end;
end;

procedure TTestTypeConvertions.TestToMethod;
var
  II: IType<TProcOfObject>;
  LType: TProcOfObject;
begin
  II := TType<TProcOfObject>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToNativeInt(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<NativeInt>;
  X: NativeInt;
  v: Variant;
begin
  { Obtain type support }
  II := TType<NativeInt>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToNativeUInt(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<NativeUInt>;
  X: NativeUInt;
  v: Variant;
begin
  { Obtain type support }
  II := TType<NativeUInt>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToNullInteger(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Nullable<Integer>>;
  X: Nullable<Integer>;
  v: Variant;
begin
  { Obtain type support }
  II := TNullableType<Integer>.Create;

  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X.Value = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar).Value = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToOleVariant(const AVar: Variant);
var
  II: IType<OleVariant>;
  X: OleVariant;
begin
  II := TType<OleVariant>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  Check(II.ConvertFromVariant(AVar) = AVar);
end;

procedure TTestTypeConvertions.TestToPointer(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Pointer>;
  X: Pointer;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Pointer>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (Cardinal(X) = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = Pointer(Cardinal(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToReal(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Real>;
  X: Real;
  v: Variant;

begin
  { Obtain type support }
  II := TType<Real>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check(II.TryConvertFromVariant(AVar, X) and EqFloats(X, AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(EqFloats(II.ConvertFromVariant(AVar), Single(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToRecord;
var
  II: IType<TBigRec>;
  LType: TBigRec;
begin
  II := TType<TBigRec>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToRoutine(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<TProcedure>;
  X: TProcedure;
  v: Variant;
begin
  { Obtain type support }
  II := TType<TProcedure>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (Cardinal(@X) = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(Cardinal(@II.ConvertFromVariant(AVar)) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToRTTIArray;
var
  II: IType<TRTTIBigArr>;
  LType: TRTTIBigArr;
begin
  II := TType<TRTTIBigArr>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToRTTIRecord;
var
  II: IType<TRTTIBigRec>;
  LType: TRTTIBigRec;
begin
  II := TType<TRTTIBigRec>.Default;

  Check(not II.TryConvertFromVariant('23', LType));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant('21');
  end, '');
end;

procedure TTestTypeConvertions.TestToShortInt(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<ShortInt>;
  X: ShortInt;
  v: Variant;
begin
  { Obtain type support }
  II := TType<ShortInt>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToShortString(const AVar: Variant);
var
  II: IType<ShortString>;
  X: ShortString;
begin
  { Obtain type support }
  II := TType<ShortString>.Default;


  Check((II.TryConvertFromVariant(AVar, X)) and (X = ShortString(AVar)));
  Check(II.ConvertFromVariant(AVar) = ShortString(AVar));
end;

procedure TTestTypeConvertions.TestToSingle(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Single>;
  X: Single;
  v: Variant;

begin
  { Obtain type support }
  II := TType<Single>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check(II.TryConvertFromVariant(AVar, X) and EqFloats(X, AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(EqFloats(II.ConvertFromVariant(AVar), Single(AVar)));
  end;
end;

procedure TTestTypeConvertions.TestToSmallInt(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<SmallInt>;
  X: SmallInt;
  v: Variant;
begin
  { Obtain type support }
  II := TType<SmallInt>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToString(const AVar: Variant);
var
  II: IType<String>;
  X: String;
begin
  { Obtain type support }
  II := TType<String>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = String(AVar)));
  Check(II.ConvertFromVariant(AVar) = String(AVar));
end;

procedure TTestTypeConvertions.TestToTString(const AVar: Variant);
var
  II: IType<TString>;
  X: TString;
begin
  { Obtain type support }
  II := TType<TString>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = TString(AVar)));
  Check(II.ConvertFromVariant(AVar) = TString(AVar));
end;

procedure TTestTypeConvertions.TestToUCS4Char(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<UCS4Char>;
  X: UCS4Char;
  v: Variant;
begin
  { Obtain type support }
  II := TType<UCS4Char>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (ConvertFromUtf32(X) = String(AVar)[1]));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(ConvertFromUtf32(II.ConvertFromVariant(AVar)) = String(AVar)[1]);
  end;
end;

procedure TTestTypeConvertions.TestToUCS4String(const AVar: Variant);
var
  II: IType<UCS4String>;
  X: UCS4String;
begin
  { Obtain type support }
  II := TType<UCS4String>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (UCS4StringToUnicodeString(X) = String(AVar)));
  Check(UCS4StringToUnicodeString(II.ConvertFromVariant(AVar)) = String(AVar));
end;

procedure TTestTypeConvertions.TestToUInt64(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<UInt64>;
  X: UInt64;
  v: Variant;
begin
  { Obtain type support }
  II := TType<UInt64>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;

procedure TTestTypeConvertions.TestToUnicodeString(const AVar: Variant);
var
  II: IType<UnicodeString>;
  X: UnicodeString;
begin
  { Obtain type support }
  II := TType<UnicodeString>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = UnicodeString(AVar)));
  Check(II.ConvertFromVariant(AVar) = UnicodeString(AVar));
end;

procedure TTestTypeConvertions.TestToUTF8String(const AVar: Variant);
var
  II: IType<UTF8String>;
  X: UTF8String;
begin
  { Obtain type support }
  II := TType<UTF8String>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = UTF8String(AVar)));
  Check(II.ConvertFromVariant(AVar) = UTF8String(AVar));
end;

procedure TTestTypeConvertions.TestToVariant(const AVar: Variant);
var
  II: IType<Variant>;
  X: Variant;
begin
  II := TType<Variant>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  Check(II.ConvertFromVariant(AVar) = AVar);
end;

procedure TTestTypeConvertions.TestToWideChar(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<WideChar>;
  X: WideChar;
  v: Variant;
begin
  { Obtain type support }
  II := TType<WideChar>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = WideString(AVar)[1]));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = WideString(AVar)[1]);
  end;
end;

procedure TTestTypeConvertions.TestToWideString(const AVar: Variant);
var
  II: IType<WideString>;
  X: WideString;
begin
  { Obtain type support }
  II := TType<WideString>.Default;

  Check((II.TryConvertFromVariant(AVar, X)) and (X = WideString(AVar)));
  Check(II.ConvertFromVariant(AVar) = WideString(AVar));
end;

procedure TTestTypeConvertions.TestToWord(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<Word>;
  X: Word;
  v: Variant;
begin
  { Obtain type support }
  II := TType<Word>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = AVar));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = AVar);
  end;
end;


procedure TTestTypeConvertions.TestToWordBool(const AVar: Variant; const VarNotValid: Boolean);
var
  II: IType<WordBool>;
  X: WordBool;
  v: Variant;
begin
  { Obtain type support }
  II := TType<WordBool>.Default;
  v := AVar;

  if VarNotValid then
  begin
    Check(not II.TryConvertFromVariant(AVar, X));
  end else
  begin
    Check((II.TryConvertFromVariant(AVar, X)) and (X = WordBool(AVar)));
  end;

  if VarNotValid then
  begin
    CheckException(ETypeConversionNotSupported, procedure begin
      II.ConvertFromVariant(v);
    end, '');
  end else
  begin
    Check(II.ConvertFromVariant(AVar) = WordBool(AVar));
  end;
end;

procedure TTestTypeConvertions.TestTString;
begin
  TestFromTString('');
  TestFromTString('Hello World');

  TestToTString('');
  TestToTString(-22.2);
  TestToTString(Now);
  TestToTString(false);
end;

procedure TTestTypeConvertions.TestTuple_1;
var
  II: IType<Tuple<Integer>>;
  LVar: Variant;
  LVal: Tuple<Integer>;
begin
  { ... to variant }
  II := Tuple.GetType<Integer>(
    TType<Integer>.Default
    );

  LVal := Tuple<Integer>.Create(10);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');

  { ... from variant }
  LVar := VarArrayOf([10]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Value1 = 10, 'Expected 1 = 10');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Value1 = 10, 'Expected 1 = 10');

  { ... error stuff }
  LVar := VarArrayOf([]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf(['hahaha']);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestTuple_2;
var
  II: IType<Tuple<Integer, Integer>>;
  LVar: Variant;
  LVal: Tuple<Integer, Integer>;
begin
  { ... to variant }
  II := Tuple.GetType<Integer, Integer>(
    TType<Integer>.Default,
    TType<Integer>.Default
    );

  LVal := Tuple<Integer, Integer>.Create(10, 20);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');

  { ... from variant }
  LVar := VarArrayOf([10, 20]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');

  { ... error stuff }
  LVar := VarArrayOf([10]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 'hahaha']);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestTuple_3;
var
  II: IType<Tuple<Integer, Integer, Integer>>;
  LVar: Variant;
  LVal: Tuple<Integer, Integer, Integer>;
begin
  { ... to variant }
  II := Tuple.GetType<Integer, Integer, Integer>(
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default
    );

  LVal := Tuple<Integer, Integer, Integer>.Create(10, 20, 30);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');

  { ... from variant }
  LVar := VarArrayOf([10, 20, 30]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');

  { ... error stuff }
  LVar := VarArrayOf([10, 20]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 40]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 'hahaha', 30]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestTuple_4;
var
  II: IType<Tuple<Integer, Integer, Integer, Integer>>;
  LVar: Variant;
  LVal: Tuple<Integer, Integer, Integer, Integer>;
begin
  { ... to variant }
  II := Tuple.GetType<Integer, Integer, Integer, Integer>(
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default
    );

  LVal := Tuple<Integer, Integer, Integer, Integer>.Create(10, 20, 30, 40);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');

  { ... from variant }
  LVar := VarArrayOf([10, 20, 30, 40]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');

  { ... error stuff }
  LVar := VarArrayOf([10, 20, 30]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 40, 50]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 'hahaha']);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestTuple_5;
var
  II: IType<Tuple<Integer, Integer, Integer, Integer, Integer>>;
  LVar: Variant;
  LVal: Tuple<Integer, Integer, Integer, Integer, Integer>;
begin
  { ... to variant }
  II := Tuple.GetType<Integer, Integer, Integer, Integer, Integer>(
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default
    );

  LVal := Tuple<Integer, Integer, Integer, Integer, Integer>.Create(10, 20, 30, 40, 50);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');
  Check(LVar[4] = 50, 'Expected Variant 5 = 50');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');
  Check(LVar[4] = 50, 'Expected Variant 5 = 50');

  { ... from variant }
  LVar := VarArrayOf([10, 20, 30, 40, 50]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');
  Check(LVal.Value5 = 50, 'Expected 5 = 50');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');
  Check(LVal.Value5 = 50, 'Expected 5 = 50');

  { ... error stuff }
  LVar := VarArrayOf([10, 20, 30, 40]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 40, 50, 60]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 'hahaha', 50]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestTuple_6;
var
  II: IType<Tuple<Integer, Integer, Integer, Integer, Integer, Integer>>;
  LVar: Variant;
  LVal: Tuple<Integer, Integer, Integer, Integer, Integer, Integer>;
begin
  { ... to variant }
  II := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer>(
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default
    );

  LVal := Tuple<Integer, Integer, Integer, Integer, Integer, Integer>.Create(10, 20, 30, 40, 50, 60);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');
  Check(LVar[4] = 50, 'Expected Variant 5 = 50');
  Check(LVar[5] = 60, 'Expected Variant 6 = 60');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');
  Check(LVar[4] = 50, 'Expected Variant 5 = 50');
  Check(LVar[5] = 60, 'Expected Variant 6 = 60');

  { ... from variant }
  LVar := VarArrayOf([10, 20, 30, 40, 50, 60]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');
  Check(LVal.Value5 = 50, 'Expected 5 = 50');
  Check(LVal.Value6 = 60, 'Expected 6 = 60');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');
  Check(LVal.Value5 = 50, 'Expected 5 = 50');
  Check(LVal.Value6 = 60, 'Expected 6 = 60');

  { ... error stuff }
  LVar := VarArrayOf([10, 20, 30, 40, 50]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 40, 50, 60, 70]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 'hahaha', 50, 60]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestTuple_7;
var
  II: IType<Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>>;
  LVar: Variant;
  LVal: Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>;
begin
  { ... to variant }
  II := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default,
    TType<Integer>.Default
    );

  LVal := Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>.Create(10, 20, 30, 40, 50, 60, 70);

  Check(II.TryConvertToVariant(LVal, LVar), 'Expected the conversion not to fail');
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');
  Check(LVar[4] = 50, 'Expected Variant 5 = 50');
  Check(LVar[5] = 60, 'Expected Variant 6 = 60');
  Check(LVar[6] = 70, 'Expected Variant 7 = 70');

  LVar := II.ConvertToVariant(LVal);
  Check(LVar[0] = 10, 'Expected Variant 1 = 10');
  Check(LVar[1] = 20, 'Expected Variant 2 = 20');
  Check(LVar[2] = 30, 'Expected Variant 3 = 30');
  Check(LVar[3] = 40, 'Expected Variant 4 = 40');
  Check(LVar[4] = 50, 'Expected Variant 5 = 50');
  Check(LVar[5] = 60, 'Expected Variant 6 = 60');
  Check(LVar[6] = 70, 'Expected Variant 7 = 70');

  { ... from variant }
  LVar := VarArrayOf([10, 20, 30, 40, 50, 60, 70]);

  Check(II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion not to fail');
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');
  Check(LVal.Value5 = 50, 'Expected 5 = 50');
  Check(LVal.Value6 = 60, 'Expected 6 = 60');
  Check(LVal.Value7 = 70, 'Expected 7 = 70');

  LVal := II.ConvertFromVariant(LVar);
  Check(LVal.Value1 = 10, 'Expected 1 = 10');
  Check(LVal.Value2 = 20, 'Expected 2 = 20');
  Check(LVal.Value3 = 30, 'Expected 3 = 30');
  Check(LVal.Value4 = 40, 'Expected 4 = 40');
  Check(LVal.Value5 = 50, 'Expected 5 = 50');
  Check(LVal.Value6 = 60, 'Expected 6 = 60');
  Check(LVal.Value7 = 70, 'Expected 7 = 70');

  { ... error stuff }
  LVar := VarArrayOf([10, 20, 30, 40, 50, 60]);

  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 40, 50, 60, 70, 80]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := VarArrayOf([10, 20, 30, 'hahaha', 50, 60, 70]);
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');

  {.}

  LVar := 1;
  Check(not II.TryConvertFromVariant(LVar, LVal), 'Expected the conversion to fail');

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(LVar);
  end, '');
end;

procedure TTestTypeConvertions.TestUCS4Char;
begin
  TestFromUCS4Char(ConvertToUtf32('A', 1));
  TestFromUCS4Char(ConvertToUtf32('-', 1));
  TestFromUCS4Char(ConvertToUtf32('1', 1));

  TestToUCS4Char('', true);
  TestToUCS4Char(false, false);
  TestToUCS4Char(12.0, false);
  TestToUCS4Char(33, false);
  TestToUCS4Char('1', false);
  TestToUCS4Char('z', false);
end;

procedure TTestTypeConvertions.TestUCS4String;
begin
  TestFromUCS4String(UnicodeStringToUCS4String(''));
  TestFromUCS4String(UnicodeStringToUCS4String('Hello World'));

  TestToUCS4String('');
  TestToUCS4String(-22.2);
  TestToUCS4String(Now);
  TestToUCS4String(false);
end;

procedure TTestTypeConvertions.TestUInt64;
begin
  TestFromUInt64(High(UInt64));
  TestFromUInt64(Low(UInt64));

  TestToUInt64('', true);
  TestToUInt64('0', false);
  TestToUInt64(12.0, false);
  TestToUInt64(55, false);
end;

procedure TTestTypeConvertions.TestUnicodeString;
begin
  TestFromUnicodeString('');
  TestFromUnicodeString('Hello World');

  TestToUnicodeString('');
  TestToUnicodeString(-22.2);
  TestToUnicodeString(Now);
  TestToUnicodeString(false);
end;

procedure TTestTypeConvertions.TestUTF8String;
begin
  TestFromUTF8String('');
  TestFromUTF8String('Hello World');

  TestToUTF8String('');
  TestToUTF8String(-22.2);
  TestToUTF8String(Now);
  TestToUTF8String(false);
end;

procedure TTestTypeConvertions.TestVariant;
begin
  TestFromVariant('');
  TestFromVariant('Hello World');
  TestFromVariant(22);
  TestFromVariant(Now);
  TestFromVariant(true);

  TestToVariant(0);
  TestToVariant('-1');
  TestToVariant(Now);
  TestToVariant(1.1);
end;

procedure TTestTypeConvertions.TestWeak;
var
  II: IType<Weak<TObject>>;
  LObj: Weak<TObject>;
begin
  II := Reference.GetWeakType<TObject>;
  LObj := Reference.Shared(TObject.Create());

  Check(not II.TryConvertToVariant(LObj, LVariant));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertToVariant(LObj);
  end, '');

  Check(not II.TryConvertFromVariant('23', LObj));

  CheckException(ETypeConversionNotSupported, procedure begin
    II.ConvertFromVariant(23);
  end, '');
end;

procedure TTestTypeConvertions.TestWideChar;
begin
  TestFromWideChar('A');
  TestFromWideChar(Low(WideChar));
  TestFromWideChar(High(WideChar));

  TestToWideChar('', true);
  TestToWideChar(false, false);
  TestToWideChar(12.0, false);
  TestToWideChar(33, false);
  TestToWideChar('1', false);
  TestToWideChar('z', false);
end;

procedure TTestTypeConvertions.TestWideString;
begin
  TestFromWideString('');
  TestFromWideString('Hello World');

  TestToWideString('');
  TestToWideString(-22.2);
  TestToWideString(Now);
  TestToWideString(false);
end;

procedure TTestTypeConvertions.TestWord;
begin
  TestFromWord(High(Word));
  TestFromWord(Low(Word));

  TestToWord('', true);
  TestToWord('0', false);
  TestToWord(12.0, false);
  TestToWord(55, false);
end;

procedure TTestTypeConvertions.TestWordBool;
begin
  TestFromWordBool(true);
  TestFromWordBool(false);

  TestToWordBool('', true);
  TestToWordBool('0', false);
  TestToWordBool('12', false);
  TestToWordBool(67, false);
  TestToWordBool(true, false);
  TestToWordBool(false, false);
end;

initialization
  TestFramework.RegisterTest(TTestTypeConvertions.Suite);

end.
