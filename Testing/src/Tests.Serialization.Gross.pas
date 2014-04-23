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
unit Tests.Serialization.Gross;
interface
uses SysUtils,
     Types,
     DateUtils,
     Math,
     ComObj,
     Classes,
     XmlIntf,
     XmlDoc,
     IniFiles,
     Tests.Utils,
     TestFramework,
     DeHL.Box,
     DeHL.Tuples,
     DeHL.Strings,
     DeHL.Arrays,
     DeHL.Cloning,
     DeHL.WideCharSet,
     DeHL.Nullable,
     DeHL.Bytes,
     DeHL.DateTime,
     DeHL.Base,
     DeHL.Math.BigCardinal,
     DeHL.Math.BigInteger,
     DeHL.Math.BigDecimal,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.List,
     DeHL.Collections.SortedList,
     DeHL.Collections.Dictionary,
     DeHl.Collections.DoubleSortedBidiMap,
     DeHL.Serialization,
     DeHL.Serialization.Ini,
     DeHL.Serialization.Binary,
     DeHL.Serialization.XML;

type
  TTestGrossSerialization = class(TDeHLTestCase)
  private
    class function SerializeInXML<T>(const AValue: T): T; static;
    class function SerializeInIni<T>(const AValue: T): T; static;
    class function SerializeInBinary<T>(const AValue: T): T; static;

  published
    procedure Test_Simple;
    procedure Test_Integers;
    procedure Test_Floats;
    procedure Test_Strings;
    procedure Test_Booleans;
    procedure Test_Arrays;
    procedure Test_DTs;
    procedure Test_EnumsAndSets;
    procedure Test_ClassSelfRef;
    procedure Test_RecordSelfRef;
    procedure Test_ClassComplicated;
    procedure Test_ClassSameFields;
    procedure Test_Bad_Serialized;
    procedure Test_NonSerializable;
    procedure Test_CustomISerializable;
    procedure Test_BigCardinal;
    procedure Test_BigInteger;
    procedure Test_BigDecimal;
    procedure Test_Date;
    procedure Test_Metaclass;
    procedure Test_DateTime;
    procedure Test_Time;
    procedure Test_Box;
    procedure Test_KVP;
    procedure Test_Tuple_1;
    procedure Test_Tuple_2;
    procedure Test_Tuple_3;
    procedure Test_Tuple_4;
    procedure Test_Tuple_5;
    procedure Test_Tuple_6;
    procedure Test_Tuple_7;
    procedure Test_Nullable;
    procedure Test_WideCharSet;
    procedure Test_FixedArray;
    procedure Test_DynamicArray;
    procedure Test_Buffer;

    procedure Test_Bug0;
  end;

type
  TTestEnexSerialization = class(TDeHLTestCase)
  published
    procedure Test_List;
    procedure Test_SortedList;
    procedure Test_Dictionary;
    procedure Test_DoubleSortedBidiMap;
  end;

type
  { Exception for fiedl tests }
  EFieldFailError = class(Exception)
    constructor Create(const AFieldName, AExp, AActual: String);
  end;

{ Integers record }
type
  TIntsRecord = record
  private
    FByte_Zero, FByte_Lo, FByte_Hi: Byte;
    FShortInt_Zero, FShortInt_Lo, FShortInt_Hi: ShortInt;
    FWord_Zero, FWord_Lo, FWord_Hi: Word;
    FSmallInt_Zero, FSmallInt_Lo, FSmallInt_Hi: SmallInt;
    FCardinal_Zero, FCardinal_Lo, FCardinal_Hi: Cardinal;
    FInteger_Zero, FInteger_Lo, FInteger_Hi: Integer;
    FUInt64_Zero, FUInt64_Lo, FUInt64_Hi: UInt64;
    FInt64_Zero, FInt64_Lo, FInt64_Hi: Int64;

  public
    class function Create(): TIntsRecord; static;
    procedure CompareTo(const AOther: TIntsRecord);
  end;

{ Floats record }
type
  TFloatsRecord = record
  private
    FHalf_Zero, FHalf_Lo, FHalf_Hi: Single;
    FSingle_Zero, FSingle_Lo, FSingle_Hi: Single;
    FDouble_Zero, FDouble_Lo, FDouble_Hi: Double;
    FExtended_Zero, FExtended_Lo, FExtended_Hi: Extended;
    FCurrency_Zero, FCurrency_Lo, FCurrency_Hi: Currency;
    FComp_Zero, FComp_Lo, FComp_Hi: Comp;
  public
    class function Create(): TFloatsRecord; static;
    procedure CompareTo(const AOther: TFloatsRecord);
  end;

{ Strings record }
type
  TStringsRecord = record
  private
    FShortString_Empty, FShortString_One, FShortString_Long: ShortString;
    FUnicodeString_Empty, FUnicodeString_One, FUnicodeString_Long: UnicodeString;
    FAnsiString_Empty, FAnsiString_One, FAnsiString_Long: AnsiString;
    FWideString_Empty, FWideString_One, FWideString_Long: WideString;

    FUcs4String_Empty, FUcs4String_One, FUcs4String_Long: UCS4String;
    FRawByteString_Empty, FRawByteString_One, FRawByteString_Long: RawByteString;

    FAnsiChar_Zero, FAnsiChar_Lo, FAnsiChar_Hi: AnsiChar;
    FWideChar_Zero, FWideChar_Lo, FWideChar_Hi: WideChar;
    FUcs4Char_Zero, FUcs4Char_Lo, FUcs4Char_Hi: UCS4Char;

    FTString_Empty, FTString_One, FTString_Long: TString;
  public
    class function Create(): TStringsRecord; static;
    procedure CompareTo(const AOther: TStringsRecord);
  end;

{ Boolean record }
type
  TBooleanRecord = record
  private
    FBoolean_True, FBoolean_False: Boolean;
    FByteBool_True, FByteBool_False: ByteBool;
    FWordBool_True, FWordBool_False: WordBool;
    FLongBool_True, FLongBool_False: LongBool;

  public
    class function Create(): TBooleanRecord; static;
    procedure CompareTo(const AOther: TBooleanRecord);
  end;

{ Arrays record }
type
  TOneStrArray = array[0..0] of String;
  TOneIntArray = array[0..0] of Integer;

  TThreeStrArray = array[1..3] of String;
  TThreeIntArray = array[1..3] of Integer;

  TTwoStrArray = array[0..0, 0..0] of String;
  TTwoIntArray = array[0..0, 0..0] of Integer;

  TFourStrArray = array[1..2, 0..1] of String;
  TFourIntArray = array[1..2, 0..1] of Integer;

  TArraysRecord = record
  private
    { Dynamic arrays }
    FDynArrayStr_Empty, FDynArrayStr_One, FDynArrayStr_Many: TArray<String>;
    FDynArrayInt_Empty, FDynArrayInt_One, FDynArrayInt_Many: TIntegerDynArray;

    { One dimensional arrays }
    FOneDimArrayStr_One: TOneStrArray;
    FOneDimArrayStr_Three: TThreeStrArray;
    FOneDimArrayInt_One: TOneIntArray;
    FOneDimArrayInt_Three: TThreeIntArray;

    { Two dim arrays }
    FTwoDimArrayStr_Two: TTwoStrArray;
    FTwoDimArrayStr_Four: TFourStrArray;
    FTwoDimArrayInt_Two: TTwoIntArray;
    FTwoDimArrayInt_Four: TFourIntArray;
  public
    class function Create(): TArraysRecord; static;
    procedure CompareTo(const AOther: TArraysRecord);
  end;

{ Date-time record }
type
  TDateTimeRecord = record
  private
    FDateTime_Zero, FDateTime_Now: System.TDateTime;
    FTime_Zero, FTime_Now: System.TTime;
    FDate_Zero, FDate_Now: System.TDate;

  public
    class function Create(): TDateTimeRecord; static;
    procedure CompareTo(const AOther: TDateTimeRecord);
  end;

{ Enums and sets }
type
  TSomeEnum = (someOne, someTwo, someThree);
  TSomeSet = set of TSomeEnum;

  TEnumSetRecord = record
  private
    FEnum_One, FEnum_Two: TSomeEnum;
    FSet_Empty, FSet_One, FSet_All: TSomeSet;

  public
    class function Create(): TEnumSetRecord; static;
    procedure CompareTo(const AOther: TEnumSetRecord);
  end;

{ Check for a chained class }
type
  TChainedClass = class
  public
    FSelf: TObject;
    FNil: TObject;

  public
    constructor Create();
  end;

{ Records by ref test }
type
  PLinkedItem = ^TLinkedItem;
  TLinkedItem = record
    FData: String;

    [CloneKind(ckDeep)]
    FSelf, FNil: PLinkedItem;
  end;

{ Class with array of different subclasses }
type
  TContainer = class
  public type
    TOne = class
      FOneField: String;
      constructor Create;
      procedure Test;
    end;

    TTwo = class(TOne)
      FTwoField: Cardinal;
      constructor Create;
      procedure Test;
    end;

    TThree = class
      // no fields
    end;

  private
    [CloneKind(ckDeep)]
    FArray: array of TObject;

  public
    constructor Create(const CreateSubs: Boolean);
    destructor Destroy(); override;

    procedure Test(const WithSubs: Boolean);
  end;

{ Non-serialized and non-serializable check }
type
  TBadSerRecord = record
    P: Pointer;
    S: String;
  end;

  TBadSerRecord_NonSer = record
    [NonSerialized]
    P: Pointer;
    S: String;
  end;

{ Class with custom ser. handler }
type
  TSpecialKukuClass = class(TRefCountedObject, ISerializable, IDeserializationCallback)
  public
    FSequence: String;

  public
    constructor Create();

    { Implementoooors }
    procedure Serialize(const AData: TSerializationData);
    procedure Deserialize(const AData: TDeserializationData);
    procedure Deserialized(const AData: TDeserializationData);
  end;

{ Test interitance with same field names }
type
  TInhBase = class
  private
    FField: String;

  public
    procedure Test; virtual;
    constructor Create();
  end;

  TInhDerived = class(TInhBase)
  private
    FField: String;

  public
    procedure Test; override;
    constructor Create();
  end;

  TInhDerived2 = class(TInhDerived)
  private
    FField: String;

  public
    procedure Test; override;
    constructor Create();
  end;

implementation


{ TFieldFailError }

constructor EFieldFailError.Create(const AFieldName, AExp, AActual: String);
begin
  inherited CreateFmt('Field [%s]. Expected = "%s" but actual was "%s".', [AFieldName, AExp, AActual]);
end;

{ TIntsRecord }

procedure TIntsRecord.CompareTo(const AOther: TIntsRecord);
begin
  if FByte_Zero <> AOther.FByte_Zero then
    raise EFieldFailError.Create('FByte_Zero', UIntToStr(FByte_Zero), UIntToStr(AOther.FByte_Zero));

  if FByte_Lo <> AOther.FByte_Lo then
    raise EFieldFailError.Create('FByte_Lo', UIntToStr(FByte_Lo), UIntToStr(AOther.FByte_Lo));

  if FByte_Hi <> AOther.FByte_Hi then
    raise EFieldFailError.Create('FByte_Hi', UIntToStr(FByte_Hi), UIntToStr(AOther.FByte_Hi));


  if FShortInt_Zero <> AOther.FShortInt_Zero then
    raise EFieldFailError.Create('FShortInt_Zero', IntToStr(FShortInt_Zero), IntToStr(AOther.FShortInt_Zero));

  if FShortInt_Lo <> AOther.FShortInt_Lo then
    raise EFieldFailError.Create('FShortInt_Lo', IntToStr(FShortInt_Lo), IntToStr(AOther.FShortInt_Lo));

  if FShortInt_Hi <> AOther.FShortInt_Hi then
    raise EFieldFailError.Create('FShortInt_Hi', IntToStr(FShortInt_Hi), IntToStr(AOther.FShortInt_Hi));


  if FWord_Zero <> AOther.FWord_Zero then
    raise EFieldFailError.Create('FWord_Zero', UIntToStr(FWord_Zero), UIntToStr(AOther.FWord_Zero));

  if FWord_Lo <> AOther.FWord_Lo then
    raise EFieldFailError.Create('FWord_Lo', UIntToStr(FWord_Lo), UIntToStr(AOther.FWord_Lo));

  if FWord_Hi <> AOther.FWord_Hi then
    raise EFieldFailError.Create('FWord_Hi', UIntToStr(FWord_Hi), UIntToStr(AOther.FWord_Hi));


  if FSmallInt_Zero <> AOther.FSmallInt_Zero then
    raise EFieldFailError.Create('FSmallInt_Zero', IntToStr(FSmallInt_Zero), IntToStr(AOther.FSmallInt_Zero));

  if FSmallInt_Lo <> AOther.FSmallInt_Lo then
    raise EFieldFailError.Create('FSmallInt_Lo', IntToStr(FSmallInt_Lo), IntToStr(AOther.FSmallInt_Lo));

  if FSmallInt_Hi <> AOther.FSmallInt_Hi then
    raise EFieldFailError.Create('FSmallInt_Hi', IntToStr(FSmallInt_Hi), IntToStr(AOther.FSmallInt_Hi));


  if FCardinal_Zero <> AOther.FCardinal_Zero then
    raise EFieldFailError.Create('FCardinal_Zero', UIntToStr(FCardinal_Zero), UIntToStr(AOther.FCardinal_Zero));

  if FCardinal_Lo <> AOther.FCardinal_Lo then
    raise EFieldFailError.Create('FCardinal_Lo', UIntToStr(FCardinal_Lo), UIntToStr(AOther.FCardinal_Lo));

  if FCardinal_Hi <> AOther.FCardinal_Hi then
    raise EFieldFailError.Create('FCardinal_Hi', UIntToStr(FCardinal_Hi), UIntToStr(AOther.FCardinal_Hi));


  if FInteger_Zero <> AOther.FInteger_Zero then
    raise EFieldFailError.Create('FInteger_Zero', IntToStr(FInteger_Zero), IntToStr(AOther.FInteger_Zero));

  if FInteger_Lo <> AOther.FInteger_Lo then
    raise EFieldFailError.Create('FInteger_Lo', IntToStr(FInteger_Lo), IntToStr(AOther.FInteger_Lo));

  if FInteger_Hi <> AOther.FInteger_Hi then
    raise EFieldFailError.Create('FInteger_Hi', IntToStr(FInteger_Hi), IntToStr(AOther.FInteger_Hi));


  if FUInt64_Zero <> AOther.FUInt64_Zero then
    raise EFieldFailError.Create('FUInt64_Zero', UIntToStr(FUInt64_Zero), UIntToStr(AOther.FUInt64_Zero));

  if FUInt64_Lo <> AOther.FUInt64_Lo then
    raise EFieldFailError.Create('FUInt64_Lo', UIntToStr(FUInt64_Lo), UIntToStr(AOther.FUInt64_Lo));

  if FUInt64_Hi <> AOther.FUInt64_Hi then
    raise EFieldFailError.Create('FUInt64_Hi', UIntToStr(FUInt64_Hi), UIntToStr(AOther.FUInt64_Hi));


  if FInt64_Zero <> AOther.FInt64_Zero then
    raise EFieldFailError.Create('FInt64_Zero', IntToStr(FInt64_Zero), IntToStr(AOther.FInt64_Zero));

  if FInt64_Lo <> AOther.FInt64_Lo then
    raise EFieldFailError.Create('FInt64_Lo', IntToStr(FInt64_Lo), IntToStr(AOther.FInt64_Lo));

  if FInt64_Hi <> AOther.FInt64_Hi then
    raise EFieldFailError.Create('FInt64_Hi', IntToStr(FInt64_Hi), IntToStr(AOther.FInt64_Hi));
end;

class function TIntsRecord.Create: TIntsRecord;
begin
  Result.FByte_Zero := 0;
  Result.FByte_Lo := Low(Byte);
  Result.FByte_Hi := High(Byte);

  Result.FShortInt_Zero := 0;
  Result.FShortInt_Lo := Low(ShortInt);
  Result.FShortInt_Hi := High(ShortInt);

  Result.FWord_Zero := 0;
  Result.FWord_Lo := Low(Word);
  Result.FWord_Hi := High(Word);

  Result.FSmallInt_Zero := 0;
  Result.FSmallInt_Lo := Low(SmallInt);
  Result.FSmallInt_Hi := High(SmallInt);

  Result.FCardinal_Zero := 0;
  Result.FCardinal_Lo := Low(Cardinal);
  Result.FCardinal_Hi := High(Cardinal);

  Result.FInteger_Zero := 0;
  Result.FInteger_Lo := Low(Integer);
  Result.FInteger_Hi := High(Integer);

  Result.FUInt64_Zero := 0;
  Result.FUInt64_Lo := Low(UInt64);
  Result.FUInt64_Hi := High(UInt64);

  Result.FInt64_Zero := 0;
  Result.FInt64_Lo := Low(Int64);
  Result.FInt64_Hi := High(Int64);
end;

{ TFloatsRecord }

procedure TFloatsRecord.CompareTo(const AOther: TFloatsRecord);
begin
  if FHalf_Zero <> AOther.FHalf_Zero then
    raise EFieldFailError.Create('FHalf_Zero', FloatToStr(FHalf_Zero), FloatToStr(AOther.FHalf_Zero));

  if FHalf_Lo <> AOther.FHalf_Lo then
    raise EFieldFailError.Create('FHalf_Lo', FloatToStr(FHalf_Lo), FloatToStr(AOther.FHalf_Lo));

  if FHalf_Hi <> AOther.FHalf_Hi then
    raise EFieldFailError.Create('FHalf_Hi', FloatToStr(FHalf_Hi), FloatToStr(AOther.FHalf_Hi));


  if FSingle_Zero <> AOther.FSingle_Zero then
    raise EFieldFailError.Create('FSingle_Zero', FloatToStr(FSingle_Zero), FloatToStr(AOther.FSingle_Zero));

  if FSingle_Lo <> AOther.FSingle_Lo then
    raise EFieldFailError.Create('FSingle_Lo', FloatToStr(FSingle_Lo), FloatToStr(AOther.FSingle_Lo));

  if FSingle_Hi <> AOther.FSingle_Hi then
    raise EFieldFailError.Create('FSingle_Hi', FloatToStr(FSingle_Hi), FloatToStr(AOther.FSingle_Hi));


  if FDouble_Zero <> AOther.FDouble_Zero then
    raise EFieldFailError.Create('FDouble_Zero', FloatToStr(FDouble_Zero), FloatToStr(AOther.FDouble_Zero));

  if FDouble_Lo <> AOther.FDouble_Lo then
    raise EFieldFailError.Create('FDouble_Lo', FloatToStr(FDouble_Lo), FloatToStr(AOther.FDouble_Lo));

  if FDouble_Hi <> AOther.FDouble_Hi then
    raise EFieldFailError.Create('FDouble_Hi', FloatToStr(FDouble_Hi), FloatToStr(AOther.FDouble_Hi));


  if FExtended_Zero <> AOther.FExtended_Zero then
    raise EFieldFailError.Create('FExtended_Zero', FloatToStr(FExtended_Zero), FloatToStr(AOther.FExtended_Zero));

  if FExtended_Lo <> AOther.FExtended_Lo then
    raise EFieldFailError.Create('FExtended_Lo', FloatToStr(FExtended_Lo), FloatToStr(AOther.FExtended_Lo));

  if FExtended_Hi <> AOther.FExtended_Hi then
    raise EFieldFailError.Create('FExtended_Hi', FloatToStr(FExtended_Hi), FloatToStr(AOther.FExtended_Hi));


  if FCurrency_Zero <> AOther.FCurrency_Zero then
    raise EFieldFailError.Create('FCurrency_Zero', FloatToStr(FCurrency_Zero), FloatToStr(AOther.FCurrency_Zero));

  if FCurrency_Lo <> AOther.FCurrency_Lo then
    raise EFieldFailError.Create('FCurrency_Lo', FloatToStr(FCurrency_Lo), FloatToStr(AOther.FCurrency_Lo));

  if FCurrency_Hi <> AOther.FCurrency_Hi then
    raise EFieldFailError.Create('FCurrency_Hi', FloatToStr(FCurrency_Hi), FloatToStr(AOther.FCurrency_Hi));


  if FComp_Zero <> AOther.FComp_Zero then
    raise EFieldFailError.Create('FComp_Zero', FloatToStr(FComp_Zero), FloatToStr(AOther.FComp_Zero));

  if FComp_Lo <> AOther.FComp_Lo then
    raise EFieldFailError.Create('FComp_Lo', FloatToStr(FComp_Lo), FloatToStr(AOther.FComp_Lo));

  if FComp_Hi <> AOther.FComp_Hi then
    raise EFieldFailError.Create('FComp_Hi', FloatToStr(FComp_Hi), FloatToStr(AOther.FComp_Hi));

end;

class function TFloatsRecord.Create: TFloatsRecord;
begin
  Result.FSingle_Zero := 0;
  Result.FSingle_Lo := -1000.7878;
  Result.FSingle_Hi := 10000.733;

  Result.FHalf_Zero := 0;
  Result.FHalf_Lo := -1000.7878;
  Result.FHalf_Hi := 10000.733;

  Result.FDouble_Zero := 0;
  Result.FDouble_Lo := MinSingle - 100;
  Result.FDouble_Hi := MaxSingle + 100;

  Result.FExtended_Zero := 0;
  Result.FExtended_Lo := MinDouble - 100;
  Result.FExtended_Hi := MaxDouble + 100;

  Result.FCurrency_Zero := 0;
  Result.FCurrency_Lo := -289892.3232;
  Result.FCurrency_Hi := 37889881.32322;

  Result.FComp_Zero := 0;
  Result.FComp_Lo := -2789788728;
  Result.FComp_Hi := 2121212121;
end;

{ TStringsRecord }

procedure TStringsRecord.CompareTo(const AOther: TStringsRecord);
begin
  if FShortString_Empty <> AOther.FShortString_Empty then
    raise EFieldFailError.Create('FShortString_Empty', string(FShortString_Empty), string(AOther.FShortString_Empty));

  if FShortString_One <> AOther.FShortString_One then
    raise EFieldFailError.Create('FShortString_One', string(FShortString_One), string(AOther.FShortString_One));

  if FShortString_Long <> AOther.FShortString_Long then
    raise EFieldFailError.Create('FShortString_Long', string(FShortString_Long), string(AOther.FShortString_Long));


  if FUnicodeString_Empty <> AOther.FUnicodeString_Empty then
    raise EFieldFailError.Create('FUnicodeString_Empty', FUnicodeString_Empty, AOther.FUnicodeString_Empty);

  if FUnicodeString_One <> AOther.FUnicodeString_One then
    raise EFieldFailError.Create('FUnicodeString_One', FUnicodeString_One, AOther.FUnicodeString_One);

  if FUnicodeString_Long <> AOther.FUnicodeString_Long then
    raise EFieldFailError.Create('FUnicodeString_Long', FUnicodeString_Long, AOther.FUnicodeString_Long);


  if FAnsiString_Empty <> AOther.FAnsiString_Empty then
    raise EFieldFailError.Create('FAnsiString_Empty', string(FAnsiString_Empty), string(AOther.FAnsiString_Empty));

  if FAnsiString_One <> AOther.FAnsiString_One then
    raise EFieldFailError.Create('FAnsiString_One', string(FAnsiString_One), string(AOther.FAnsiString_One));

  if FAnsiString_Long <> AOther.FAnsiString_Long then
    raise EFieldFailError.Create('FAnsiString_Long', string(FAnsiString_Long), string(AOther.FAnsiString_Long));


  if FWideString_Empty <> AOther.FWideString_Empty then
    raise EFieldFailError.Create('FWideString_Empty', FWideString_Empty, AOther.FWideString_Empty);

  if FWideString_One <> AOther.FWideString_One then
    raise EFieldFailError.Create('FWideString_One', FWideString_One, AOther.FWideString_One);

  if FWideString_Long <> AOther.FWideString_Long then
    raise EFieldFailError.Create('FWideString_Long', FWideString_Long, AOther.FWideString_Long);


  if FTString_Empty <> AOther.FTString_Empty then
    raise EFieldFailError.Create('FTString_Empty', FTString_Empty, AOther.FTString_Empty);

  if FTString_One <> AOther.FTString_One then
    raise EFieldFailError.Create('FTString_One', FTString_One, AOther.FTString_One);

  if FTString_Long <> AOther.FTString_Long then
    raise EFieldFailError.Create('FTString_Long', FTString_Long, AOther.FTString_Long);


  if FRawByteString_Empty <> AOther.FRawByteString_Empty then
    raise EFieldFailError.Create('FRawByteString_Empty', FRawByteString_Empty, AOther.FRawByteString_Empty);

  if FRawByteString_One <> AOther.FRawByteString_One then
    raise EFieldFailError.Create('FRawByteString_One', FRawByteString_One, AOther.FRawByteString_One);

  if FRawByteString_Long <> AOther.FRawByteString_Long then
    raise EFieldFailError.Create('FRawByteString_Long', FRawByteString_Long, AOther.FRawByteString_Long);


  if UCS4StringToWideString(FUcs4String_Empty) <> UCS4StringToWideString(AOther.FUcs4String_Empty) then
    raise EFieldFailError.Create('FUcs4String_Empty', UCS4StringToWideString(FUcs4String_Empty), UCS4StringToWideString(AOther.FUcs4String_Empty));

  if UCS4StringToWideString(FUcs4String_One) <> UCS4StringToWideString(AOther.FUcs4String_One) then
    raise EFieldFailError.Create('FUcs4String_One', UCS4StringToWideString(FUcs4String_One), UCS4StringToWideString(AOther.FUcs4String_One));

  if UCS4StringToWideString(FUcs4String_Long) <> UCS4StringToWideString(AOther.FUcs4String_Long) then
    raise EFieldFailError.Create('FUcs4String_Long', UCS4StringToWideString(FUcs4String_Long), UCS4StringToWideString(AOther.FUcs4String_Long));


  if FAnsiChar_Zero <> AOther.FAnsiChar_Zero then
    raise EFieldFailError.Create('FAnsiChar_Zero', string(FAnsiChar_Zero), string(AOther.FAnsiChar_Zero));

  if FAnsiChar_Lo <> AOther.FAnsiChar_Lo then
    raise EFieldFailError.Create('FAnsiChar_Lo', string(FAnsiChar_Lo), string(AOther.FAnsiChar_Lo));

  if FAnsiChar_Hi <> AOther.FAnsiChar_Hi then
    raise EFieldFailError.Create('FAnsiChar_Hi', string(FAnsiChar_Hi), string(AOther.FAnsiChar_Hi));


  if FWideChar_Zero <> AOther.FWideChar_Zero then
    raise EFieldFailError.Create('FWideChar_Zero', FWideChar_Zero, AOther.FWideChar_Zero);

  if FWideChar_Lo <> AOther.FWideChar_Lo then
    raise EFieldFailError.Create('FWideChar_Lo', FWideChar_Lo, AOther.FWideChar_Lo);

  if FWideChar_Hi <> AOther.FWideChar_Hi then
    raise EFieldFailError.Create('FWideChar_Hi', FWideChar_Hi, AOther.FWideChar_Hi);


  if FUcs4Char_Zero <> AOther.FUcs4Char_Zero then
    raise EFieldFailError.Create('FUcs4Char_Zero', IntToStr(FUcs4Char_Zero), IntToStr(AOther.FUcs4Char_Zero));

  if FUcs4Char_Lo <> AOther.FUcs4Char_Lo then
    raise EFieldFailError.Create('FUcs4Char_Lo', IntToStr(FUcs4Char_Lo), IntToStr(AOther.FUcs4Char_Lo));

  if FUcs4Char_Hi <> AOther.FUcs4Char_Hi then
    raise EFieldFailError.Create('FUcs4Char_Hi', IntToStr(FUcs4Char_Hi), IntToStr(AOther.FUcs4Char_Hi));
end;

class function TStringsRecord.Create: TStringsRecord;
begin
  Result.FShortString_Empty := '';
  Result.FShortString_One := '1';
  Result.FShortString_Long := 'Testing Serialization!';

  Result.FUnicodeString_Empty := '';
  Result.FUnicodeString_One := '2';
  Result.FUnicodeString_Long := 'тестинг сериализэйшан!';

  Result.FAnsiString_Empty := '';
  Result.FAnsiString_One := '3';
  Result.FAnsiString_Long := 'Ansi Testing Serialization!';

  Result.FWideString_Empty := '';
  Result.FWideString_One := '4';
  Result.FWideString_Long := 'Re-тестинг сериализэйшан!';

  Result.FTString_Empty := '';
  Result.FTString_One := '4';
  Result.FTString_Long := 'Re-тестинг сериализэйшан!';

  Result.FUcs4String_Empty := WideStringToUCS4String('');
  Result.FUcs4String_One := WideStringToUCS4String('4');
  Result.FUcs4String_Long := WideStringToUCS4String('Re-тестинг сериализэйшан!');

  Result.FRawByteString_Empty := '';
  Result.FRawByteString_One := '4';
  Result.FRawByteString_Long := 'A block of data';

  Result.FAnsiChar_Zero := #9;
  Result.FAnsiChar_Lo := ' ';
  Result.FAnsiChar_Hi := 'z';

  Result.FWideChar_Zero := #9;
  Result.FWideChar_Lo := ' ';
  Result.FWideChar_Hi := #$FF00;

  Result.FUcs4Char_Zero := 9;
  Result.FUcs4Char_Lo := 32;
  Result.FUcs4Char_Hi := $FF00;
end;

{ TBooleanRecord }

procedure TBooleanRecord.CompareTo(const AOther: TBooleanRecord);
begin
  if FBoolean_True <> AOther.FBoolean_True then
    raise EFieldFailError.Create('FBoolean_True', BoolToStr(FBoolean_True), BoolToStr(AOther.FBoolean_True));

  if FBoolean_False <> AOther.FBoolean_False then
    raise EFieldFailError.Create('FBoolean_False', BoolToStr(FBoolean_False), BoolToStr(AOther.FBoolean_False));


  if FByteBool_True <> AOther.FByteBool_True then
    raise EFieldFailError.Create('FByteBool_True', BoolToStr(FByteBool_True), BoolToStr(AOther.FByteBool_True));

  if FByteBool_False <> AOther.FByteBool_False then
    raise EFieldFailError.Create('FByteBool_False', BoolToStr(FByteBool_False), BoolToStr(AOther.FByteBool_False));


  if FWordBool_True <> AOther.FWordBool_True then
    raise EFieldFailError.Create('FWordBool_True', BoolToStr(FWordBool_True), BoolToStr(AOther.FWordBool_True));

  if FWordBool_False <> AOther.FWordBool_False then
    raise EFieldFailError.Create('FWordBool_False', BoolToStr(FWordBool_False), BoolToStr(AOther.FWordBool_False));


  if FLongBool_True <> AOther.FLongBool_True then
    raise EFieldFailError.Create('FLongBool_True', BoolToStr(FLongBool_True), BoolToStr(AOther.FLongBool_True));

  if FLongBool_False <> AOther.FLongBool_False then
    raise EFieldFailError.Create('FLongBool_False', BoolToStr(FLongBool_False), BoolToStr(AOther.FLongBool_False));
end;

class function TBooleanRecord.Create: TBooleanRecord;
begin
  Result.FBoolean_True := true;
  Result.FBoolean_False := false;

  Result.FByteBool_True := true;
  Result.FByteBool_False := false;

  Result.FWordBool_True := true;
  Result.FWordBool_False := false;

  Result.FLongBool_True := true;
  Result.FLongBool_False := false;
end;

{ TArraysRecord }

procedure TArraysRecord.CompareTo(const AOther: TArraysRecord);
var
  I: Integer;
begin
  if Length(FDynArrayStr_Empty) <> Length(AOther.FDynArrayStr_Empty) then
    raise EFieldFailError.Create('(len) FDynArrayStr_Empty', '...', '...');

  if Length(FDynArrayStr_One) <> Length(AOther.FDynArrayStr_One) then
    raise EFieldFailError.Create('(len) FDynArrayStr_One', '...', '...')
  else
  begin
    for I := 0 to Length(FDynArrayStr_One) - 1 do
      if FDynArrayStr_One[I] <> AOther.FDynArrayStr_One[I] then
        raise EFieldFailError.Create('(' + IntToStr(I) + ') FDynArrayStr_One', '...', '...');
  end;

  if Length(FDynArrayStr_Many) <> Length(AOther.FDynArrayStr_Many) then
    raise EFieldFailError.Create('(len) FDynArrayStr_Many', '...', '...')
  else
  begin
    for I := 0 to Length(FDynArrayStr_Many) - 1 do
      if FDynArrayStr_Many[I] <> AOther.FDynArrayStr_Many[I] then
        raise EFieldFailError.Create('(' + IntToStr(I) + ') FDynArrayStr_Many', '...', '...');
  end;

  if Length(FDynArrayInt_Empty) <> Length(AOther.FDynArrayInt_Empty) then
    raise EFieldFailError.Create('(len) FDynArrayInt_Empty', '...', '...');

  if Length(FDynArrayInt_One) <> Length(AOther.FDynArrayInt_One) then
    raise EFieldFailError.Create('(len) FDynArrayInt_One', '...', '...')
  else
  begin
    for I := 0 to Length(FDynArrayInt_One) - 1 do
      if FDynArrayInt_One[I] <> AOther.FDynArrayInt_One[I] then
        raise EFieldFailError.Create('(' + IntToStr(I) + ') FDynArrayInt_One', '...', '...');
  end;

  if Length(FDynArrayInt_Many) <> Length(AOther.FDynArrayInt_Many) then
    raise EFieldFailError.Create('(len) FDynArrayInt_Many', '...', '...')
  else
  begin
    for I := 0 to Length(FDynArrayInt_Many) - 1 do
      if FDynArrayInt_Many[I] <> AOther.FDynArrayInt_Many[I] then
        raise EFieldFailError.Create('(' + IntToStr(I) + ') FDynArrayInt_Many', '...', '...');
  end;

  if FOneDimArrayStr_One[0] <> AOther.FOneDimArrayStr_One[0] then
    raise EFieldFailError.Create('FOneDimArrayStr_One', FOneDimArrayStr_One[0], AOther.FOneDimArrayStr_One[0]);

  if FOneDimArrayInt_One[0] <> AOther.FOneDimArrayInt_One[0] then
    raise EFieldFailError.Create('FOneDimArrayInt_One', IntToStr(FOneDimArrayInt_One[0]), IntToStr(AOther.FOneDimArrayInt_One[0]));


  if FOneDimArrayStr_Three[1] <> AOther.FOneDimArrayStr_Three[1] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[1]', FOneDimArrayStr_Three[1], AOther.FOneDimArrayStr_Three[1]);

  if FOneDimArrayStr_Three[2] <> AOther.FOneDimArrayStr_Three[2] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[2]', FOneDimArrayStr_Three[2], AOther.FOneDimArrayStr_Three[2]);

  if FOneDimArrayStr_Three[3] <> AOther.FOneDimArrayStr_Three[3] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[3]', FOneDimArrayStr_Three[3], AOther.FOneDimArrayStr_Three[3]);


  if FOneDimArrayInt_Three[1] <> AOther.FOneDimArrayInt_Three[1] then
    raise EFieldFailError.Create('FOneDimArrayInt_Three[1]', IntToStr(FOneDimArrayInt_Three[1]), IntToStr(AOther.FOneDimArrayInt_Three[1]));

  if FOneDimArrayInt_Three[2] <> AOther.FOneDimArrayInt_Three[2] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[2]', IntToStr(FOneDimArrayInt_Three[2]), IntToStr(AOther.FOneDimArrayInt_Three[2]));

  if FOneDimArrayInt_Three[3] <> AOther.FOneDimArrayInt_Three[3] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[3]', IntToStr(FOneDimArrayInt_Three[3]), IntToStr(AOther.FOneDimArrayInt_Three[3]));


  if FTwoDimArrayStr_Two[0, 0] <> AOther.FTwoDimArrayStr_Two[0, 0] then
    raise EFieldFailError.Create('FTwoDimArrayStr_Two', FTwoDimArrayStr_Two[0, 0], AOther.FTwoDimArrayStr_Two[0, 0]);

  if FTwoDimArrayInt_Two[0, 0] <> AOther.FTwoDimArrayInt_Two[0, 0] then
    raise EFieldFailError.Create('FTwoDimArrayInt_Two', IntToStr(FTwoDimArrayInt_Two[0, 0]), IntToStr(AOther.FTwoDimArrayInt_Two[0, 0]));


  if FTwoDimArrayStr_Four[1, 0] <> AOther.FTwoDimArrayStr_Four[1, 0] then
    raise EFieldFailError.Create('FTwoDimArrayStr_Four[1, 0]', FTwoDimArrayStr_Four[1, 0], AOther.FTwoDimArrayStr_Four[1, 0]);

  if FTwoDimArrayStr_Four[1, 1] <> AOther.FTwoDimArrayStr_Four[1, 1] then
    raise EFieldFailError.Create('FTwoDimArrayStr_Four[1, 1]', FTwoDimArrayStr_Four[1, 1], AOther.FTwoDimArrayStr_Four[1, 1]);

  if FTwoDimArrayStr_Four[2, 0] <> AOther.FTwoDimArrayStr_Four[2, 0] then
    raise EFieldFailError.Create('FTwoDimArrayStr_Four[2, 0]', FTwoDimArrayStr_Four[2, 0], AOther.FTwoDimArrayStr_Four[2, 0]);

  if FTwoDimArrayStr_Four[2, 1] <> AOther.FTwoDimArrayStr_Four[2, 1] then
    raise EFieldFailError.Create('FTwoDimArrayStr_Four[2, 1]', FTwoDimArrayStr_Four[2, 1], AOther.FTwoDimArrayStr_Four[2, 1]);


  if FTwoDimArrayInt_Four[1, 0] <> AOther.FTwoDimArrayInt_Four[1, 0] then
    raise EFieldFailError.Create('FOneDimArrayInt_Three[1, 0]', IntToStr(FTwoDimArrayInt_Four[1, 0]), IntToStr(AOther.FTwoDimArrayInt_Four[1, 0]));

  if FTwoDimArrayInt_Four[1, 1] <> AOther.FTwoDimArrayInt_Four[1, 1] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[1, 1]', IntToStr(FTwoDimArrayInt_Four[1, 1]), IntToStr(AOther.FTwoDimArrayInt_Four[1, 1]));

  if FTwoDimArrayInt_Four[2, 0] <> AOther.FTwoDimArrayInt_Four[2, 0] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[2, 0]', IntToStr(FTwoDimArrayInt_Four[2, 0]), IntToStr(AOther.FTwoDimArrayInt_Four[2, 0]));

  if FTwoDimArrayInt_Four[2, 1] <> AOther.FTwoDimArrayInt_Four[2, 1] then
    raise EFieldFailError.Create('FOneDimArrayStr_Three[2, 1]', IntToStr(FTwoDimArrayInt_Four[2, 1]), IntToStr(AOther.FTwoDimArrayInt_Four[2, 1]));
end;

class function TArraysRecord.Create: TArraysRecord;
begin
  { Dynamic arrays }
  SetLength(Result.FDynArrayStr_Empty, 0);
  Result.FDynArrayStr_One := TArray<String>.Create('A lovely string');
  Result.FDynArrayStr_Many := TArray<String>.Create('One', 'More', 'String');

  SetLength(Result.FDynArrayInt_Empty, 0);
  Result.FDynArrayInt_One := TIntegerDynArray.Create(1);
  Result.FDynArrayInt_Many := TIntegerDynArray.Create(10, 9, 8);

  { One dimensional arrays }
  Result.FOneDimArrayStr_One[0] := '(0)';
  Result.FOneDimArrayStr_Three[1] := '(1)'; Result.FOneDimArrayStr_Three[2] := '(2)'; Result.FOneDimArrayStr_Three[3] := '(3)';
  Result.FOneDimArrayInt_One[0] := 10;
  Result.FOneDimArrayInt_Three[1] := 11; Result.FOneDimArrayInt_Three[2] := 12; Result.FOneDimArrayInt_Three[3] := 13;

    { Two dim arrays }
  Result.FTwoDimArrayStr_Two[0, 0] := '(0,0)';
  Result.FTwoDimArrayStr_Four[1,0] := '(1,0)'; Result.FTwoDimArrayStr_Four[1,1] := '(1,1)';
  Result.FTwoDimArrayStr_Four[2,0] := '(2,0)'; Result.FTwoDimArrayStr_Four[2,1] := '(2,1)';

  Result.FTwoDimArrayInt_Two[0, 0] := 100;
  Result.FTwoDimArrayInt_Four[1,0] := 100; Result.FTwoDimArrayInt_Four[1,1] := 110;
  Result.FTwoDimArrayInt_Four[2,0] := 200; Result.FTwoDimArrayInt_Four[2,1] := 210;
end;

{ TDateTimeRecord }

procedure TDateTimeRecord.CompareTo(const AOther: TDateTimeRecord);
begin
  if FDateTime_Zero <> AOther.FDateTime_Zero then
    raise EFieldFailError.Create('FDateTime_Zero', DateTimeToStr(FDateTime_Zero), DateTimeToStr(AOther.FDateTime_Zero));

  if System.Abs(FDateTime_Now - AOther.FDateTime_Now) > 0.0001 then
    raise EFieldFailError.Create('FDateTime_Now', DateTimeToStr(FDateTime_Now), DateTimeToStr(AOther.FDateTime_Now));


  if FTime_Zero <> AOther.FTime_Zero then
    raise EFieldFailError.Create('FTime_Zero', TimeToStr(FTime_Zero), TimeToStr(AOther.FTime_Zero));

  if System.Abs(FTime_Now - AOther.FTime_Now) > 0.0001 then
    raise EFieldFailError.Create('FTime_Now', TimeToStr(FTime_Now), TimeToStr(AOther.FTime_Now));


  if FDate_Zero <> AOther.FDate_Zero then
    raise EFieldFailError.Create('FDate_Zero', DateToStr(FDate_Zero), DateToStr(AOther.FDate_Zero));

  if not SameDate(FDate_Now, AOther.FDate_Now) then
    raise EFieldFailError.Create('FDate_Now', DateToStr(FDate_Now), DateToStr(AOther.FDate_Now));

end;

class function TDateTimeRecord.Create: TDateTimeRecord;
begin
  Result.FDateTime_Zero := 0;
  Result.FDateTime_Now := Now;

  Result.FTime_Zero := 0;
  Result.FTime_Now := Time;

  Result.FDate_Zero := 0;
  Result.FDate_Now := Date;
end;

{ TEnumSetRecord }

procedure TEnumSetRecord.CompareTo(const AOther: TEnumSetRecord);
begin
  if FEnum_One <> AOther.FEnum_One then
    raise EFieldFailError.Create('FEnum_One', IntToStr(Integer(FEnum_One)), IntToStr(Integer(AOther.FEnum_One)));

  if FEnum_Two <> AOther.FEnum_Two then
    raise EFieldFailError.Create('FEnum_Two', IntToStr(Integer(FEnum_Two)), IntToStr(Integer(AOther.FEnum_Two)));


  if FSet_Empty <> AOther.FSet_Empty then
    raise EFieldFailError.Create('FSet_Empty', '...', '...');

  if FSet_One <> AOther.FSet_One then
    raise EFieldFailError.Create('FSet_One', '...', '...');

  if FSet_All <> AOther.FSet_All then
    raise EFieldFailError.Create('FSet_All', '...', '...');
end;

class function TEnumSetRecord.Create: TEnumSetRecord;
begin
  Result.FEnum_One := someOne;
  Result.FEnum_Two := someTwo;

  Result.FSet_Empty := [];
  Result.FSet_One := [someOne];
  Result.FSet_All := [someOne .. someThree];
end;

{ TChainedClass }

constructor TChainedClass.Create;
begin
  FSelf := Self;
  FNil := nil;
end;

{ TContainer }

constructor TContainer.Create(const CreateSubs: Boolean);
begin
  SetLength(FArray, 6);

  { 0 }
  FArray[0] := TOne.Create();

  { 1 }
  FArray[1] := TTwo.Create();

  { 2 }
  FArray[2] := TThree.Create();

  { 3 --> 0 }
  FArray[3] := FArray[0];

  { 4 --> nil }
  FArray[4] := nil;

  { 5 -- Another container }
  if CreateSubs then
    FArray[5] := TContainer.Create(false)
  else
    FArray[5] := Self;
end;

destructor TContainer.Destroy;
begin
  if Length(FArray) > 0 then
    FArray[0].Free;

  if Length(FArray) > 1 then
    FArray[1].Free;

  if Length(FArray) > 2 then
    FArray[2].Free;

  if Length(FArray) > 5 then
    if FArray[5] <> Self then
      FArray[5].Free;

  inherited;
end;

procedure TContainer.Test(const WithSubs: Boolean);
begin
  if Length(FArray) <> 6 then
    raise EFieldFailError.Create('(length) FArray', '6', IntToStr(Length(FArray)));

  if FArray[0] = nil then
    raise EFieldFailError.Create('FArray[0]', 'non-nil', 'nil');

  if not (FArray[0] is TOne) then
    raise EFieldFailError.Create('(class) FArray[0]', 'TOne', FArray[0].ClassName);

  { Test object }
  (FArray[0] as TOne).Test;


  if FArray[1] = nil then
    raise EFieldFailError.Create('FArray[1]', 'non-nil', 'nil');

  if not (FArray[1] is TTwo) then
    raise EFieldFailError.Create('(class) FArray[1]', 'TTwo', FArray[1].ClassName);

  { Test object }
  (FArray[1] as TTwo).Test;

  if FArray[2] = nil then
    raise EFieldFailError.Create('FArray[2]', 'non-nil', 'nil');

  if not (FArray[2] is TThree) then
    raise EFieldFailError.Create('(class) FArray[2]', 'TThree', FArray[2].ClassName);


  if FArray[3] <> FArray[0] then
    raise EFieldFailError.Create('FArray[3]', 'equals to FArray[0]', 'different');


  if FArray[4] <> nil then
    raise EFieldFailError.Create('FArray[4]', 'nil', 'different');


  if WithSubs then
  begin
    if FArray[5] = nil then
      raise EFieldFailError.Create('FArray[5]', 'non-nil', 'nil');

    if not (FArray[5] is TContainer) then
      raise EFieldFailError.Create('(class) FArray[5]', 'TContainer', FArray[5].ClassName);

    { Invoke sub test }
    (FArray[5] as TContainer).Test(false);
  end else
  begin
    if FArray[5] <> Self then
      raise EFieldFailError.Create('FArray[5]', '=Self', '<>Self');
  end;
end;

{ TContainer.TOne }

constructor TContainer.TOne.Create;
begin
  FOneField := 'TOne';
end;

procedure TContainer.TOne.Test;
begin
  if FOneField <> 'TOne' then
    raise EFieldFailError.Create('TOne.FOneField', 'TOne', FOneField);
end;

{ TContainer.TTwo }

constructor TContainer.TTwo.Create;
begin
  FOneField := 'TTwo';
  FTwoField := $DEADBABE;
end;

procedure TContainer.TTwo.Test;
begin
  if FOneField <> 'TTwo' then
    raise EFieldFailError.Create('TTwo.FOneField', 'TTwo', FOneField);

  if FTwoField <> $DEADBABE then
    raise EFieldFailError.Create('TTwo.FTwoField', '$DEADBABE', IntToStr(FTwoField));
end;

{ TSpecialKukuClass }

constructor TSpecialKukuClass.Create;
begin
  FSequence := FSequence + 'c';
end;

procedure TSpecialKukuClass.Deserialize(const AData: TDeserializationData);
begin
  FSequence := FSequence + 'de';
end;

procedure TSpecialKukuClass.Deserialized(const AData: TDeserializationData);
begin
  FSequence := FSequence + 'dd';
end;

procedure TSpecialKukuClass.Serialize(const AData: TSerializationData);
begin
  FSequence := FSequence + 'se';
end;

{ TInhBase }

constructor TInhBase.Create();
begin
  FField := '1';
end;

procedure TInhBase.Test;
begin
  if FField <> '1' then
    raise EFieldFailError.Create('TInhBase.FField', '1', FField);
end;

{ TInhDerived }

constructor TInhDerived.Create();
begin
  inherited;
  FField := '2';
end;

procedure TInhDerived.Test;
begin
  inherited;

  if FField <> '2' then
    raise EFieldFailError.Create('TInhDerived.FField', '2', FField);
end;

{ TInhDerived2 }

constructor TInhDerived2.Create();
begin
  inherited;
  FField := '3';
end;

procedure TInhDerived2.Test;
begin
  inherited;

  if FField <> '3' then
    raise EFieldFailError.Create('TInhDerived2.FField', '3', FField);
end;

{ TTestGrossSerialization }

class function TTestGrossSerialization.SerializeInBinary<T>(const AValue: T): T;
var
  LBinFile: TMemoryStream;
  LBinSerializer: TBinarySerializer<T>;
begin
  { Create the serializer and an XML document }
  LBinSerializer := TBinarySerializer<T>.Create();
  LBinFile := TMemoryStream.Create();

  { Serialize the structure }
  try
    LBinSerializer.Serialize(AValue, LBinFile);
    LBinFile.Seek(0, soFromBeginning);
    LBinSerializer.Deserialize(Result, LBinFile);
  finally
    LBinFile.Free;
    LBinSerializer.Free;
  end;
end;

class function TTestGrossSerialization.SerializeInIni<T>(const AValue: T): T;
var
  LIniFile: TMemIniFile;
  LIniSerializer: TIniSerializer<T>;
begin
  { Create the serializer and an XML document }
  LIniSerializer := TIniSerializer<T>.Create();
  LIniFile := TMemIniFile.Create('_no_file_', TEncoding.UTF8);

  try
    { Serialize the structure }
    LIniSerializer.Serialize(AValue, LIniFile);
    LIniSerializer.Deserialize(Result, LIniFile);
  finally
    LIniFile.Free;
    LIniSerializer.Free;
  end;
end;

class function TTestGrossSerialization.SerializeInXML<T>(const AValue: T): T;
var
  LXmlFile: IXMLDocument;
  LXmlSerializer: TXmlSerializer<T>;
begin
  { Create the serializer and an XML document }
  LXmlSerializer := TXmlSerializer<T>.Create();
  LXmlFile := TXMLDocument.Create(nil);
  LXmlFile.Active := true;

  { Serialize the structure }
  try
    LXmlSerializer.Serialize(AValue, LXmlFile.Node);
    LXmlSerializer.Deserialize(Result, LXmlFile.Node);
  finally
    LXmlSerializer.Free;
  end;
end;


procedure TTestGrossSerialization.Test_Arrays;
var
  LInput: TArraysRecord;
  LOutXml, LOutIni, LOutBin: TArraysRecord;
begin
  LInput := TArraysRecord.Create;

  LOutXml := SerializeInXML<TArraysRecord>(LInput);
  LOutIni := SerializeInIni<TArraysRecord>(LInput);
  LOutBin := SerializeInBinary<TArraysRecord>(LInput);

  LInput.CompareTo(LOutXml);
  LInput.CompareTo(LOutIni);
  LInput.CompareTo(LOutBin);
end;

procedure TTestGrossSerialization.Test_Booleans;
var
  LInput: TBooleanRecord;
  LOutXml, LOutIni, LOutBin: TBooleanRecord;
begin
  LInput := TBooleanRecord.Create;

  LOutXml := SerializeInXML<TBooleanRecord>(LInput);
  LOutIni := SerializeInIni<TBooleanRecord>(LInput);
  LOutBin := SerializeInBinary<TBooleanRecord>(LInput);

  LInput.CompareTo(LOutXml);
  LInput.CompareTo(LOutIni);
  LInput.CompareTo(LOutBin);
end;

type
  TStringBox = TBox<String>;

procedure TTestGrossSerialization.Test_Box;
var
  LInput0, LInput1: TStringBox;
  LOutXml0, LOutIni0, LOutBin0,
    LOutXml1, LOutIni1, LOutBin1: TStringBox;
begin
  LInput0 := TStringBox.Create(); LInput0.Unbox;
  LInput1 := TStringBox.Create('One Two Three');

  LOutXml0 := nil; LOutXml1 := nil;
  LOutIni0 := nil; LOutIni1 := nil;
  LOutBin0 := nil; LOutBin1 := nil;
  try
    LOutXml0 := SerializeInXML<TStringBox>(LInput0);
    LOutIni0 := SerializeInIni<TStringBox>(LInput0);
    LOutBin0 := SerializeInBinary<TStringBox>(LInput0);
    LOutXml1 := SerializeInXML<TStringBox>(LInput1);
    LOutIni1 := SerializeInIni<TStringBox>(LInput1);
    LOutBin1 := SerializeInBinary<TStringBox>(LInput1);

    CheckTrue(LOutXml0 <> nil, 'LOutXml0 is nil');
    CheckTrue(LOutIni0 <> nil, 'LOutIni0 is nil');
    CheckTrue(LOutBin0 <> nil, 'LOutBin0 is nil');
    CheckTrue(LOutXml1 <> nil, 'LOutXml1 is nil');
    CheckTrue(LOutIni1 <> nil, 'LOutIni1 is nil');
    CheckTrue(LOutBin1 <> nil, 'LOutBin1 is nil');

    CheckTrue(not LOutXml0.HasBoxedValue, 'LOutXml0 has a boxed value');
    CheckTrue(not LOutIni0.HasBoxedValue, 'LOutIni0 has a boxed value');
    CheckTrue(not LOutBin0.HasBoxedValue, 'LOutBin0 has a boxed value');
    CheckTrue(LOutXml1.HasBoxedValue, 'LOutXml1 does not have a boxed value');
    CheckTrue(LOutIni1.HasBoxedValue, 'LOutIni1 does not have a boxed value');
    CheckTrue(LOutBin1.HasBoxedValue, 'LOutBin1 does not have a boxed value');

    CheckEquals(LInput1.Peek, LOutXml1.Peek, 'LOutXml1 boxed value');
    CheckEquals(LInput1.Peek, LOutXml1.Peek, 'LOutIni1 boxed value');
    CheckEquals(LInput1.Peek, LOutXml1.Peek, 'LOutBin1 boxed value');
  finally
    LInput0.Free;
    LInput1.Free;

    LOutXml0.Free;
    LOutIni0.Free;
    LOutBin0.Free;
    LOutXml1.Free;
    LOutIni1.Free;
    LOutBin1.Free;
  end;
end;

type
  TInnerArray = array of string;
  TOuterArray = array of TInnerArray;

  TNestedArrayTestClass = class
    FSomeArray: TOuterArray;

    constructor Create();
    procedure Test(const AOther: TNestedArrayTestClass);
  end;

constructor TNestedArrayTestClass.Create();
begin
  FSomeArray := TOuterArray.Create(TInnerArray.Create('one', 'two'), nil, TInnerArray.Create('three'));
end;

procedure TNestedArrayTestClass.Test(const AOther: TNestedArrayTestClass);
begin
  { Main array }
  if Length(FSomeArray) <> Length(AOther.FSomeArray) then
    raise EFieldFailError.Create('(len) FSomeArray', '...', '...');


  if Length(FSomeArray[0]) <> Length(AOther.FSomeArray[0]) then
    raise EFieldFailError.Create('(len) FSomeArray[0]', '...', '...');

  if Length(FSomeArray[1]) <> Length(AOther.FSomeArray[1]) then
    raise EFieldFailError.Create('(len) FSomeArray[1]', '...', '...');

  if Length(FSomeArray[2]) <> Length(AOther.FSomeArray[2]) then
    raise EFieldFailError.Create('(len) FSomeArray[2]', '...', '...');


  if FSomeArray[0][0] <> AOther.FSomeArray[0][0] then
    raise EFieldFailError.Create('FSomeArray[0][0]', FSomeArray[0][0], AOther.FSomeArray[0][0]);

  if FSomeArray[0][1] <> AOther.FSomeArray[0][1] then
    raise EFieldFailError.Create('FSomeArray[0][1]', FSomeArray[0][1], AOther.FSomeArray[0][1]);

  if FSomeArray[2][0] <> AOther.FSomeArray[2][0] then
    raise EFieldFailError.Create('FSomeArray[2][0]', FSomeArray[2][0], AOther.FSomeArray[2][0]);
end;

procedure TTestGrossSerialization.Test_Buffer;
var
  LInput0, LInput1: TBuffer;
  LOutXml0, LOutIni0, LOutBin0,
    LOutXml1, LOutIni1, LOutBin1: TBuffer;
begin
  LInput0 := TBuffer.Create([]);
  LInput1 := TBuffer.Create([1, 2, 3]);

  LOutXml0 := SerializeInXML<TBuffer>(LInput0);
  LOutIni0 := SerializeInIni<TBuffer>(LInput0);
  LOutBin0 := SerializeInBinary<TBuffer>(LInput0);

  LOutXml1 := SerializeInXML<TBuffer>(LInput1);
  LOutIni1 := SerializeInIni<TBuffer>(LInput1);
  LOutBin1 := SerializeInBinary<TBuffer>(LInput1);

  CheckTrue(LOutXml0.Length = 0, '(not empty!) Xml serialization failed!');
  CheckTrue(LOutIni0.Length = 0, '(not empty!) Ini serialization failed!');
  CheckTrue(LOutBin0.Length = 0, '(not empty!) Bin serialization failed!');

  CheckTrue(LOutXml1.Length = 3, '(empty!) Xml serialization failed!');
  CheckTrue(LOutIni1.Length = 3, '(empty!) Ini serialization failed!');
  CheckTrue(LOutBin1.Length = 3, '(empty!) Bin serialization failed!');

  CheckEquals(LInput1[0], LOutXml1[0], 'Xml serialization failed! [0]');
  CheckEquals(LInput1[1], LOutXml1[1], 'Xml serialization failed! [1]');
  CheckEquals(LInput1[2], LOutXml1[2], 'Xml serialization failed! [2]');

  CheckEquals(LInput1[0], LOutIni1[0], 'Ini serialization failed! [0]');
  CheckEquals(LInput1[1], LOutIni1[1], 'Ini serialization failed! [1]');
  CheckEquals(LInput1[2], LOutIni1[2], 'Ini serialization failed! [2]');

  CheckEquals(LInput1[0], LOutBin1[0], 'Bin serialization failed! [0]');
  CheckEquals(LInput1[1], LOutBin1[1], 'Bin serialization failed! [1]');
  CheckEquals(LInput1[2], LOutBin1[2], 'Bin serialization failed! [2]');
end;

procedure TTestGrossSerialization.Test_Bug0;
var
  LInput: TNestedArrayTestClass;
  LOutXml, LOutIni, LOutBin: TNestedArrayTestClass;
begin
  LInput := TNestedArrayTestClass.Create();

  LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;
  try
    LOutXml := SerializeInXML<TNestedArrayTestClass>(LInput);
    LOutIni := SerializeInIni<TNestedArrayTestClass>(LInput);
    LOutBin := SerializeInBinary<TNestedArrayTestClass>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    LInput.Test(LOutXml);
    LInput.Test(LOutIni);
    LInput.Test(LOutBin);
  finally
    LInput.Free;
    LOutXml.Free;
    LOutIni.Free;
    LOutBin.Free;
  end;
end;

procedure TTestGrossSerialization.Test_ClassComplicated;
var
  LInput: TContainer;
  LOutXml, LOutIni, LOutBin: TContainer;
begin
  LInput := TContainer.Create(true);

  LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;
  try
    LOutXml := TContainer(SerializeInXML<TObject>(LInput));
    LOutIni := TContainer(SerializeInIni<TObject>(LInput));
    LOutBin := TContainer(SerializeInBinary<TObject>(LInput));

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckTrue(LOutXml is TContainer, 'LOutXml is not TContainer');
    CheckTrue(LOutIni is TContainer, 'LOutIni is not TContainer');
    CheckTrue(LOutBin is TContainer, 'LOutBin is not TContainer');

    LOutXml.Test(true);
    LOutIni.Test(true);
    LOutBin.Test(true);
  finally
    LInput.Free;
    LOutXml.Free;
    LOutIni.Free;
    LOutBin.Free;
  end;
end;

procedure TTestGrossSerialization.Test_ClassSameFields;
var
  LInput: TInhDerived2;
  LOutXml, LOutIni, LOutBin: TInhDerived2;
begin
  LInput := TInhDerived2.Create();

  LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;

  try
    LOutXml := SerializeInXML<TInhDerived2>(LInput);
    LOutIni := SerializeInIni<TInhDerived2>(LInput);
    LOutBin := SerializeInBinary<TInhDerived2>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    LOutXml.Test();
    LOutIni.Test();
    LOutBin.Test();
  finally
    LInput.Free;
    LOutXml.Free;
    LOutIni.Free;
    LOutBin.Free;
  end;
end;

procedure TTestGrossSerialization.Test_ClassSelfRef;
var
  LInput: TChainedClass;
  LOutXml, LOutIni, LOutBin: TChainedClass;
begin
  LInput := TChainedClass.Create;

  LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;
  try
    LOutXml := SerializeInXML<TChainedClass>(LInput);
    LOutIni := SerializeInIni<TChainedClass>(LInput);
    LOutBin := SerializeInBinary<TChainedClass>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckTrue(LOutXml.FSelf = LOutXml, 'LOutXml.FSelf <> LOutXml');
    CheckTrue(LOutIni.FSelf = LOutIni, 'LOutIni.FSelf <> LOutIni');
    CheckTrue(LOutBin.FSelf = LOutBin, 'LOutBin.FSelf <> LOutBin');

    CheckTrue(LOutXml.FNil = nil, 'LOutXml.FSelf <> nil');
    CheckTrue(LOutIni.FNil = nil, 'LOutIni.FSelf <> nil');
    CheckTrue(LOutBin.FNil = nil, 'LOutBin.FSelf <> nil');
  finally
    LInput.Free;
    LOutXml.Free;
    LOutIni.Free;
    LOutBin.Free;
  end;
end;

procedure TTestGrossSerialization.Test_CustomISerializable;
var
  LInput: TSpecialKukuClass;
  LOutXml, LOutIni, LOutBin: TSpecialKukuClass;
begin
  LInput := TSpecialKukuClass.Create;

  LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;

  try
    LOutXml := SerializeInXML<TSpecialKukuClass>(LInput);
    LOutIni := SerializeInIni<TSpecialKukuClass>(LInput);
    LOutBin := SerializeInBinary<TSpecialKukuClass>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckEquals('csesese', LInput.FSequence, 'LInput sequence broken');
    CheckEquals('cdedd', LOutXml.FSequence, 'LOutXml sequence broken');
    CheckEquals('cdedd', LOutIni.FSequence, 'LOutXml sequence broken');
    CheckEquals('cdedd', LOutBin.FSequence, 'LOutXml sequence broken');

    { Check ref counts! }
    CheckEquals(0, LInput.RefCount, 'LInput ref count broken');
    CheckEquals(0, LOutXml.RefCount, 'LOutXml ref count broken');
    CheckEquals(0, LOutIni.RefCount, 'LOutIni ref count broken');
    CheckEquals(0, LOutBin.RefCount, 'LOutBin ref count broken');
  finally
    LInput.Free;
    LOutXml.Free;
    LOutIni.Free;
    LOutBin.Free;
  end;
end;

procedure TTestGrossSerialization.Test_Date;
var
  LInput: TDate;
  LOutXml, LOutIni, LOutBin: TDate;
begin
  LInput := Date;

  LOutXml := SerializeInXML<TDate>(LInput);
  LOutIni := SerializeInIni<TDate>(LInput);
  LOutBin := SerializeInBinary<TDate>(LInput);

  CheckEquals(LInput.ToString(), LOutXml.ToString(), 'Xml serialization failed!');
  CheckEquals(LInput.ToString(), LOutIni.ToString(), 'Ini serialization failed!');
  CheckEquals(LInput.ToString(), LOutBin.ToString(), 'Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_DateTime;
var
  LInput: TDateTime;
  LOutXml, LOutIni, LOutBin: TDateTime;
begin
  LInput := Now;

  LOutXml := SerializeInXML<TDateTime>(LInput);
  LOutIni := SerializeInIni<TDateTime>(LInput);
  LOutBin := SerializeInBinary<TDateTime>(LInput);

  CheckEquals(LInput.ToString(), LOutXml.ToString(), 'Xml serialization failed!');
  CheckEquals(LInput.ToString(), LOutIni.ToString(), 'Ini serialization failed!');
  CheckEquals(LInput.ToString(), LOutBin.ToString(), 'Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_DTs;
var
  LInput: TDateTimeRecord;
  LOutXml, LOutIni, LOutBin: TDateTimeRecord;
begin
  LInput := TDateTimeRecord.Create;

  LOutXml := SerializeInXML<TDateTimeRecord>(LInput);
  LOutIni := SerializeInIni<TDateTimeRecord>(LInput);
  LOutBin := SerializeInBinary<TDateTimeRecord>(LInput);

  LInput.CompareTo(LOutXml);
  LInput.CompareTo(LOutIni);
  LInput.CompareTo(LOutBin);
end;

type
  TIntDynArray = TDynamicArray<Integer>;

procedure TTestGrossSerialization.Test_DynamicArray;
var
  LInput0, LInput1: TIntDynArray;
  LOutXml0, LOutIni0, LOutBin0,
    LOutXml1, LOutIni1, LOutBin1: TIntDynArray;
begin
  LInput0 := TIntDynArray.Create([]);
  LInput1 := TIntDynArray.Create([1, 2, 3]);

  LOutXml0 := SerializeInXML<TIntDynArray>(LInput0);
  LOutIni0 := SerializeInIni<TIntDynArray>(LInput0);
  LOutBin0 := SerializeInBinary<TIntDynArray>(LInput0);

  LOutXml1 := SerializeInXML<TIntDynArray>(LInput1);
  LOutIni1 := SerializeInIni<TIntDynArray>(LInput1);
  LOutBin1 := SerializeInBinary<TIntDynArray>(LInput1);

  CheckTrue(LOutXml0.Length = 0, '(not empty!) Xml serialization failed!');
  CheckTrue(LOutIni0.Length = 0, '(not empty!) Ini serialization failed!');
  CheckTrue(LOutBin0.Length = 0, '(not empty!) Bin serialization failed!');

  CheckTrue(LOutXml1.Length = 3, '(empty!) Xml serialization failed!');
  CheckTrue(LOutIni1.Length = 3, '(empty!) Ini serialization failed!');
  CheckTrue(LOutBin1.Length = 3, '(empty!) Bin serialization failed!');


  CheckEquals(LInput1[0], LOutXml1[0], 'Xml serialization failed! [0]');
  CheckEquals(LInput1[1], LOutXml1[1], 'Xml serialization failed! [1]');
  CheckEquals(LInput1[2], LOutXml1[2], 'Xml serialization failed! [2]');

  CheckEquals(LInput1[0], LOutIni1[0], 'Ini serialization failed! [0]');
  CheckEquals(LInput1[1], LOutIni1[1], 'Ini serialization failed! [1]');
  CheckEquals(LInput1[2], LOutIni1[2], 'Ini serialization failed! [2]');

  CheckEquals(LInput1[0], LOutBin1[0], 'Bin serialization failed! [0]');
  CheckEquals(LInput1[1], LOutBin1[1], 'Bin serialization failed! [1]');
  CheckEquals(LInput1[2], LOutBin1[2], 'Bin serialization failed! [2]');
end;

procedure TTestGrossSerialization.Test_EnumsAndSets;
var
  LInput: TEnumSetRecord;
  LOutXml, LOutIni, LOutBin: TEnumSetRecord;
begin
  LInput := TEnumSetRecord.Create;

  LOutXml := SerializeInXML<TEnumSetRecord>(LInput);
  LOutIni := SerializeInIni<TEnumSetRecord>(LInput);
  LOutBin := SerializeInBinary<TEnumSetRecord>(LInput);

  LInput.CompareTo(LOutXml);
  LInput.CompareTo(LOutIni);
  LInput.CompareTo(LOutBin);
end;

type
  TIntFixedArray = TFixedArray<Integer>;

procedure TTestGrossSerialization.Test_FixedArray;
var
  LInput0, LInput1: TIntFixedArray;
  LOutXml0, LOutIni0, LOutBin0,
    LOutXml1, LOutIni1, LOutBin1: TIntFixedArray;
begin
  LInput0 := TIntFixedArray.Create([]);
  LInput1 := TIntFixedArray.Create([1, 2, 3]);

  LOutXml0 := SerializeInXML<TIntFixedArray>(LInput0);
  LOutIni0 := SerializeInIni<TIntFixedArray>(LInput0);
  LOutBin0 := SerializeInBinary<TIntFixedArray>(LInput0);

  LOutXml1 := SerializeInXML<TIntFixedArray>(LInput1);
  LOutIni1 := SerializeInIni<TIntFixedArray>(LInput1);
  LOutBin1 := SerializeInBinary<TIntFixedArray>(LInput1);

  CheckTrue(LOutXml0.Length = 0, '(not empty!) Xml serialization failed!');
  CheckTrue(LOutIni0.Length = 0, '(not empty!) Ini serialization failed!');
  CheckTrue(LOutBin0.Length = 0, '(not empty!) Bin serialization failed!');

  CheckTrue(LOutXml1.Length = 3, '(empty!) Xml serialization failed!');
  CheckTrue(LOutIni1.Length = 3, '(empty!) Ini serialization failed!');
  CheckTrue(LOutBin1.Length = 3, '(empty!) Bin serialization failed!');


  CheckEquals(LInput1[0], LOutXml1[0], 'Xml serialization failed! [0]');
  CheckEquals(LInput1[1], LOutXml1[1], 'Xml serialization failed! [1]');
  CheckEquals(LInput1[2], LOutXml1[2], 'Xml serialization failed! [2]');

  CheckEquals(LInput1[0], LOutIni1[0], 'Ini serialization failed! [0]');
  CheckEquals(LInput1[1], LOutIni1[1], 'Ini serialization failed! [1]');
  CheckEquals(LInput1[2], LOutIni1[2], 'Ini serialization failed! [2]');

  CheckEquals(LInput1[0], LOutBin1[0], 'Bin serialization failed! [0]');
  CheckEquals(LInput1[1], LOutBin1[1], 'Bin serialization failed! [1]');
  CheckEquals(LInput1[2], LOutBin1[2], 'Bin serialization failed! [2]');
end;

procedure TTestGrossSerialization.Test_Floats;
var
  LInput: TFloatsRecord;
  LOutXml, LOutIni, LOutBin: TFloatsRecord;
begin
  LInput := TFloatsRecord.Create;

  LOutXml := SerializeInXML<TFloatsRecord>(LInput);
  LOutIni := SerializeInIni<TFloatsRecord>(LInput);
  LOutBin := SerializeInBinary<TFloatsRecord>(LInput);

  LInput.CompareTo(LOutXml);
  LInput.CompareTo(LOutIni);
  LInput.CompareTo(LOutBin);
end;

procedure TTestGrossSerialization.Test_Integers;
var
  LInput: TIntsRecord;
  LOutXml, LOutIni, LOutBin: TIntsRecord;
begin
  LInput := TIntsRecord.Create;

  LOutXml := SerializeInXML<TIntsRecord>(LInput);
  LOutIni := SerializeInIni<TIntsRecord>(LInput);
  LOutBin := SerializeInBinary<TIntsRecord>(LInput);

  LInput.CompareTo(LOutXml);
  LInput.CompareTo(LOutIni);
  LInput.CompareTo(LOutBin);
end;

type
  TIntStrKVP = KVPair<Integer, String>;

procedure TTestGrossSerialization.Test_KVP;
var
  LInput: TIntStrKVP;
  LOutXml, LOutIni, LOutBin: TIntStrKVP;
begin
  LInput := TIntStrKVP.Create(123, 'Four__');

  LOutXml := SerializeInXML<TIntStrKVP>(LInput);
  LOutIni := SerializeInIni<TIntStrKVP>(LInput);
  LOutBin := SerializeInBinary<TIntStrKVP>(LInput);

  CheckEquals(LInput.Key, LOutXml.Key, '[key] Xml serialization failed!');
  CheckEquals(LInput.Value, LOutXml.Value, '[val] Xml serialization failed!');
  CheckEquals(LInput.Key, LOutIni.Key, '[key] Ini serialization failed!');
  CheckEquals(LInput.Value, LOutIni.Value, '[val] Ini serialization failed!');
  CheckEquals(LInput.Key, LOutBin.Key, '[key] Binary serialization failed!');
  CheckEquals(LInput.Value, LOutBin.Value, '[val] Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_Metaclass;
var
  LInput: TClass;
  LOutXml, LOutIni, LOutBin: TClass;
begin
  { Real }
  LInput := TTestGrossSerialization;

  LOutXml := SerializeInXML<TClass>(LInput);
  LOutIni := SerializeInIni<TClass>(LInput);
  LOutBin := SerializeInBinary<TClass>(LInput);

  CheckEquals(LInput, LOutXml, 'Xml serialization failed!');
  CheckEquals(LInput, LOutIni, 'Ini serialization failed!');
  CheckEquals(LInput, LOutBin, 'Binary serialization failed!');

  { nil }
  LInput := nil;

  LOutXml := SerializeInXML<TClass>(LInput);
  LOutIni := SerializeInIni<TClass>(LInput);
  LOutBin := SerializeInBinary<TClass>(LInput);

  CheckEquals(LInput, LOutXml, 'Xml serialization failed!');
  CheckEquals(LInput, LOutIni, 'Ini serialization failed!');
  CheckEquals(LInput, LOutBin, 'Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_NonSerializable;
var
  LInput: TBadSerRecord_NonSer;
  LOutXml, LOutIni, LOutBin: TBadSerRecord_NonSer;
begin
  LInput.S := 'One';
  LInput.P := Ptr($BADC0DE);

  LOutXml := SerializeInXML<TBadSerRecord_NonSer>(LInput);
  LOutIni := SerializeInIni<TBadSerRecord_NonSer>(LInput);
  LOutBin := SerializeInBinary<TBadSerRecord_NonSer>(LInput);

  CheckEquals(LInput.S, LOutXml.S, 'Xml ser/deser failed for [NonSerialized]');
  CheckEquals(LInput.S, LOutIni.S, 'Ini ser/deser failed for [NonSerialized]');
  CheckEquals(LInput.S, LOutBin.S, 'Bin ser/deser failed for [NonSerialized]');
end;

type
  TIntNullable = Nullable<Integer>;

procedure TTestGrossSerialization.Test_Nullable;
var
  LInput0, LInput1: TIntNullable;
  LOutXml0, LOutIni0, LOutBin0,
    LOutXml1, LOutIni1, LOutBin1: TIntNullable;
begin
  LInput0 := 100;
  LInput1.MakeNull;

  LOutXml0 := SerializeInXML<TIntNullable>(LInput0);
  LOutIni0 := SerializeInIni<TIntNullable>(LInput0);
  LOutBin0 := SerializeInBinary<TIntNullable>(LInput0);

  LOutXml1 := SerializeInXML<TIntNullable>(LInput1);
  LOutIni1 := SerializeInIni<TIntNullable>(LInput1);
  LOutBin1 := SerializeInBinary<TIntNullable>(LInput1);

  CheckTrue(not LOutXml0.IsNull, '(null!) Xml serialization failed!');
  CheckTrue(not LOutIni0.IsNull, '(null!) Ini serialization failed!');
  CheckTrue(not LOutBin0.IsNull, '(null!) Bin serialization failed!');

  CheckEquals(LInput0.Value, LOutXml0.Value, 'Xml serialization failed! Values differ.');
  CheckEquals(LInput0.Value, LOutIni0.Value, 'Ini serialization failed! Values differ.');
  CheckEquals(LInput0.Value, LOutBin0.Value, 'Bin serialization failed! Values differ.');

  CheckTrue(LOutXml1.IsNull, '(~null!) Xml serialization failed!');
  CheckTrue(LOutIni1.IsNull, '(~null!) Ini serialization failed!');
  CheckTrue(LOutBin1.IsNull, '(~null!) Bin serialization failed!');
end;

procedure TTestGrossSerialization.Test_Bad_Serialized;
var
  LInput: TBadSerRecord;
  LOutXml, LOutIni, LOutBin: Boolean;
begin
  LInput.P := nil;
  LInput.S := '66699';

  try
    LOutXml := false;
    SerializeInXML<TBadSerRecord>(LInput);
  except
    on E: ESerializationException do
       LOutXml := true;
  end;

  try
    LOutIni := false;
    SerializeInIni<TBadSerRecord>(LInput);
  except
    on E: ESerializationException do
       LOutIni := true;
  end;

  try
    LOutBin := false;
    SerializeInBinary<TBadSerRecord>(LInput);
  except
    on E: ESerializationException do
       LOutBin := true;
  end;

  CheckTrue(LOutXml, '(unser. member) Expected exception was not raised for XML.');
  CheckTrue(LOutIni, '(unser. member) Expected exception was not raised for Ini.');
  CheckTrue(LOutBin, '(unser. member) Expected exception was not raised for Binary.');
end;

procedure TTestGrossSerialization.Test_BigCardinal;
var
  LInput: BigCardinal;
  LOutXml, LOutIni, LOutBin: BigCardinal;
begin
  LInput := BigCardinal.Parse('372189378912739286437285630234273462838493207416082644213254314');

  LOutXml := SerializeInXML<BigCardinal>(LInput);
  LOutIni := SerializeInIni<BigCardinal>(LInput);
  LOutBin := SerializeInBinary<BigCardinal>(LInput);

  CheckTrue(LOutXml = LInput, 'Xml serialization failed!');
  CheckTrue(LOutIni = LInput, 'Ini serialization failed!');
  CheckTrue(LOutBin = LInput, 'Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_BigDecimal;
var
  LInput: BigDecimal;
  LOutXml, LOutIni, LOutBin: BigDecimal;
begin
  LInput := BigDecimal.Parse('37218937891273928643728563023427346283' + DecimalSeparator + '8493207416082644213254314');

  LOutXml := SerializeInXML<BigDecimal>(LInput);
  LOutIni := SerializeInIni<BigDecimal>(LInput);
  LOutBin := SerializeInBinary<BigDecimal>(LInput);

  CheckTrue(LOutXml = LInput, 'Xml serialization failed!');
  CheckTrue(LOutIni = LInput, 'Ini serialization failed!');
  CheckTrue(LOutBin = LInput, 'Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_BigInteger;
var
  LInput: BigInteger;
  LOutXml, LOutIni, LOutBin: BigInteger;
begin
  LInput := BigInteger.Parse('-372189378912739286437285630234273462838493207416082644213254314');

  LOutXml := SerializeInXML<BigInteger>(LInput);
  LOutIni := SerializeInIni<BigInteger>(LInput);
  LOutBin := SerializeInBinary<BigInteger>(LInput);

  CheckTrue(LOutXml = LInput, 'Xml serialization failed!');
  CheckTrue(LOutIni = LInput, 'Ini serialization failed!');
  CheckTrue(LOutBin = LInput, 'Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_RecordSelfRef;
var
  LInput: PLinkedItem;
  LOutXml, LOutIni, LOutBin: PLinkedItem;
begin
  New(LInput);
  LInput.FData := 'Hello World!';
  LInput.FSelf := LInput;
  LInput.FNil := nil;

  LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;
  try
    LOutXml := SerializeInXML<PLinkedItem>(LInput);
    LOutIni := SerializeInIni<PLinkedItem>(LInput);
    LOutBin := SerializeInBinary<PLinkedItem>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckTrue(LOutXml^.FSelf = LOutXml, 'LOutXml.FSelf <> LOutXml');
    CheckTrue(LOutIni^.FSelf = LOutIni, 'LOutIni.FSelf <> LOutIni');
    CheckTrue(LOutBin^.FSelf = LOutBin, 'LOutBin.FSelf <> LOutBin');

    CheckTrue(LOutXml^.FNil = nil, 'LOutXml.FSelf <> nil');
    CheckTrue(LOutIni^.FNil = nil, 'LOutIni.FSelf <> nil');
    CheckTrue(LOutBin^.FNil = nil, 'LOutBin.FSelf <> nil');
  finally
    Dispose(LInput);

    if LOutXml <> nil then
      Dispose(LOutXml);

    if LOutIni <> nil then
      Dispose(LOutIni);

    if LOutBin <> nil then
      Dispose(LOutBin);
  end;
end;

procedure TTestGrossSerialization.Test_Simple;
var
  LInput: Integer;
  LOutXml, LOutIni, LOutBin: Integer;
begin
  LInput := -100;

  LOutXml := SerializeInXML<Integer>(LInput);
  LOutIni := SerializeInIni<Integer>(LInput);
  LOutBin := SerializeInBinary<Integer>(LInput);

  CheckEquals(LInput, LOutXml, '(Integer) Xml');
  CheckEquals(LInput, LOutIni, '(Integer) Ini');
  CheckEquals(LInput, LOutBin, '(Integer) Binary');
end;

procedure TTestGrossSerialization.Test_Strings;
var
  LInput: TStringsRecord;
  LOutXml, LOutIni, LOutBin: TStringsRecord;
begin
  LInput := TStringsRecord.Create;

  LOutXml := SerializeInXML<TStringsRecord>(LInput);
  LOutIni := SerializeInIni<TStringsRecord>(LInput);
  LOutBin := SerializeInBinary<TStringsRecord>(LInput);

  LInput.CompareTo(LOutXml);
  LInput.CompareTo(LOutIni);
  LInput.CompareTo(LOutBin);
end;

procedure TTestGrossSerialization.Test_Time;
var
  LInput: TTime;
  LOutXml, LOutIni, LOutBin: TTime;
begin
  LInput := Time;

  LOutXml := SerializeInXML<TTime>(LInput);
  LOutIni := SerializeInIni<TTime>(LInput);
  LOutBin := SerializeInBinary<TTime>(LInput);

  CheckEquals(LInput.ToString(), LOutXml.ToString(), 'Xml serialization failed!');
  CheckEquals(LInput.ToString(), LOutIni.ToString(), 'Ini serialization failed!');
  CheckEquals(LInput.ToString(), LOutBin.ToString(), 'Binary serialization failed!');
end;

type
  TStrTuple = Tuple<string>;

procedure TTestGrossSerialization.Test_Tuple_1;
var
  LInput: TStrTuple;
  LOutXml, LOutIni, LOutBin: TStrTuple;
begin
  LInput := Tuple.Create('Four__');

  LOutXml := SerializeInXML<TStrTuple>(LInput);
  LOutIni := SerializeInIni<TStrTuple>(LInput);
  LOutBin := SerializeInBinary<TStrTuple>(LInput);

  CheckEquals(LInput.Value1, LOutXml.Value1, '[1] Xml serialization failed!');
  CheckEquals(LInput.Value1, LOutIni.Value1, '[1] Ini serialization failed!');
  CheckEquals(LInput.Value1, LOutBin.Value1, '[1] Binary serialization failed!');
end;

type
  TIntStrTuple = Tuple<Integer, string>;

procedure TTestGrossSerialization.Test_Tuple_2;
var
  LInput: TIntStrTuple;
  LOutXml, LOutIni, LOutBin: TIntStrTuple;
begin
  LInput := Tuple.Create(Integer(188), 'Four__');

  LOutXml := SerializeInXML<TIntStrTuple>(LInput);
  LOutIni := SerializeInIni<TIntStrTuple>(LInput);
  LOutBin := SerializeInBinary<TIntStrTuple>(LInput);

  CheckEquals(LInput.Value1, LOutXml.Value1, '[1] Xml serialization failed!');
  CheckEquals(LInput.Value1, LOutIni.Value1, '[1] Ini serialization failed!');
  CheckEquals(LInput.Value1, LOutBin.Value1, '[1] Binary serialization failed!');

  CheckEquals(LInput.Value2, LOutXml.Value2, '[2] Xml serialization failed!');
  CheckEquals(LInput.Value2, LOutIni.Value2, '[2] Ini serialization failed!');
  CheckEquals(LInput.Value2, LOutBin.Value2, '[2] Binary serialization failed!');
end;

type
  TIntIntStrTuple = Tuple<Integer, Integer, string>;

procedure TTestGrossSerialization.Test_Tuple_3;
var
  LInput: TIntIntStrTuple;
  LOutXml, LOutIni, LOutBin: TIntIntStrTuple;
begin
  LInput := Tuple.Create(Integer(-5), Integer(188), 'Four__');

  LOutXml := SerializeInXML<TIntIntStrTuple>(LInput);
  LOutIni := SerializeInIni<TIntIntStrTuple>(LInput);
  LOutBin := SerializeInBinary<TIntIntStrTuple>(LInput);

  CheckEquals(LInput.Value1, LOutXml.Value1, '[1] Xml serialization failed!');
  CheckEquals(LInput.Value1, LOutIni.Value1, '[1] Ini serialization failed!');
  CheckEquals(LInput.Value1, LOutBin.Value1, '[1] Binary serialization failed!');

  CheckEquals(LInput.Value2, LOutXml.Value2, '[2] Xml serialization failed!');
  CheckEquals(LInput.Value2, LOutIni.Value2, '[2] Ini serialization failed!');
  CheckEquals(LInput.Value2, LOutBin.Value2, '[2] Binary serialization failed!');

  CheckEquals(LInput.Value3, LOutXml.Value3, '[3] Xml serialization failed!');
  CheckEquals(LInput.Value3, LOutIni.Value3, '[3] Ini serialization failed!');
  CheckEquals(LInput.Value3, LOutBin.Value3, '[3] Binary serialization failed!');
end;

type
  TBoolIntIntStrTuple = Tuple<Boolean, Integer, Integer, string>;

procedure TTestGrossSerialization.Test_Tuple_4;
var
  LInput: TBoolIntIntStrTuple;
  LOutXml, LOutIni, LOutBin: TBoolIntIntStrTuple;
begin
  LInput := Tuple.Create(true, Integer(-5), Integer(188), 'Four__');

  LOutXml := SerializeInXML<TBoolIntIntStrTuple>(LInput);
  LOutIni := SerializeInIni<TBoolIntIntStrTuple>(LInput);
  LOutBin := SerializeInBinary<TBoolIntIntStrTuple>(LInput);

  CheckEquals(LInput.Value1, LOutXml.Value1, '[1] Xml serialization failed!');
  CheckEquals(LInput.Value1, LOutIni.Value1, '[1] Ini serialization failed!');
  CheckEquals(LInput.Value1, LOutBin.Value1, '[1] Binary serialization failed!');

  CheckEquals(LInput.Value2, LOutXml.Value2, '[2] Xml serialization failed!');
  CheckEquals(LInput.Value2, LOutIni.Value2, '[2] Ini serialization failed!');
  CheckEquals(LInput.Value2, LOutBin.Value2, '[2] Binary serialization failed!');

  CheckEquals(LInput.Value3, LOutXml.Value3, '[3] Xml serialization failed!');
  CheckEquals(LInput.Value3, LOutIni.Value3, '[3] Ini serialization failed!');
  CheckEquals(LInput.Value3, LOutBin.Value3, '[3] Binary serialization failed!');

  CheckEquals(LInput.Value4, LOutXml.Value4, '[4] Xml serialization failed!');
  CheckEquals(LInput.Value4, LOutIni.Value4, '[4] Ini serialization failed!');
  CheckEquals(LInput.Value4, LOutBin.Value4, '[4] Binary serialization failed!');
end;

type
  TStrBoolIntIntStrTuple = Tuple<string, Boolean, Integer, Integer, string>;

procedure TTestGrossSerialization.Test_Tuple_5;
var
  LInput: TStrBoolIntIntStrTuple;
  LOutXml, LOutIni, LOutBin: TStrBoolIntIntStrTuple;
begin
  LInput := Tuple.Create('', true, Integer(222), Integer(188), 'Four__');

  LOutXml := SerializeInXML<TStrBoolIntIntStrTuple>(LInput);
  LOutIni := SerializeInIni<TStrBoolIntIntStrTuple>(LInput);
  LOutBin := SerializeInBinary<TStrBoolIntIntStrTuple>(LInput);

  CheckEquals(LInput.Value1, LOutXml.Value1, '[1] Xml serialization failed!');
  CheckEquals(LInput.Value1, LOutIni.Value1, '[1] Ini serialization failed!');
  CheckEquals(LInput.Value1, LOutBin.Value1, '[1] Binary serialization failed!');

  CheckEquals(LInput.Value2, LOutXml.Value2, '[2] Xml serialization failed!');
  CheckEquals(LInput.Value2, LOutIni.Value2, '[2] Ini serialization failed!');
  CheckEquals(LInput.Value2, LOutBin.Value2, '[2] Binary serialization failed!');

  CheckEquals(LInput.Value3, LOutXml.Value3, '[3] Xml serialization failed!');
  CheckEquals(LInput.Value3, LOutIni.Value3, '[3] Ini serialization failed!');
  CheckEquals(LInput.Value3, LOutBin.Value3, '[3] Binary serialization failed!');

  CheckEquals(LInput.Value4, LOutXml.Value4, '[4] Xml serialization failed!');
  CheckEquals(LInput.Value4, LOutIni.Value4, '[4] Ini serialization failed!');
  CheckEquals(LInput.Value4, LOutBin.Value4, '[4] Binary serialization failed!');

  CheckEquals(LInput.Value5, LOutXml.Value5, '[5] Xml serialization failed!');
  CheckEquals(LInput.Value5, LOutIni.Value5, '[5] Ini serialization failed!');
  CheckEquals(LInput.Value5, LOutBin.Value5, '[5] Binary serialization failed!');
end;

type
  TByteStrBoolIntIntStrTuple = Tuple<Byte, string, Boolean, Integer, Integer, string>;

procedure TTestGrossSerialization.Test_Tuple_6;
var
  LInput: TByteStrBoolIntIntStrTuple;
  LOutXml, LOutIni, LOutBin: TByteStrBoolIntIntStrTuple;
begin
  LInput := Tuple.Create(Byte(0), '', true, Integer(1999), Integer(188), 'Four__');

  LOutXml := SerializeInXML<TByteStrBoolIntIntStrTuple>(LInput);
  LOutIni := SerializeInIni<TByteStrBoolIntIntStrTuple>(LInput);
  LOutBin := SerializeInBinary<TByteStrBoolIntIntStrTuple>(LInput);

  CheckEquals(LInput.Value1, LOutXml.Value1, '[1] Xml serialization failed!');
  CheckEquals(LInput.Value1, LOutIni.Value1, '[1] Ini serialization failed!');
  CheckEquals(LInput.Value1, LOutBin.Value1, '[1] Binary serialization failed!');

  CheckEquals(LInput.Value2, LOutXml.Value2, '[2] Xml serialization failed!');
  CheckEquals(LInput.Value2, LOutIni.Value2, '[2] Ini serialization failed!');
  CheckEquals(LInput.Value2, LOutBin.Value2, '[2] Binary serialization failed!');

  CheckEquals(LInput.Value3, LOutXml.Value3, '[3] Xml serialization failed!');
  CheckEquals(LInput.Value3, LOutIni.Value3, '[3] Ini serialization failed!');
  CheckEquals(LInput.Value3, LOutBin.Value3, '[3] Binary serialization failed!');

  CheckEquals(LInput.Value4, LOutXml.Value4, '[4] Xml serialization failed!');
  CheckEquals(LInput.Value4, LOutIni.Value4, '[4] Ini serialization failed!');
  CheckEquals(LInput.Value4, LOutBin.Value4, '[4] Binary serialization failed!');

  CheckEquals(LInput.Value5, LOutXml.Value5, '[5] Xml serialization failed!');
  CheckEquals(LInput.Value5, LOutIni.Value5, '[5] Ini serialization failed!');
  CheckEquals(LInput.Value5, LOutBin.Value5, '[5] Binary serialization failed!');

  CheckEquals(LInput.Value6, LOutXml.Value6, '[6] Xml serialization failed!');
  CheckEquals(LInput.Value6, LOutIni.Value6, '[6] Ini serialization failed!');
  CheckEquals(LInput.Value6, LOutBin.Value6, '[6] Binary serialization failed!');
end;

type
  TTupByteStrBoolIntIntStrTuple = Tuple<TStrTuple, Byte, string, Boolean, Integer, Integer, string>;

procedure TTestGrossSerialization.Test_Tuple_7;
var
  LInput: TTupByteStrBoolIntIntStrTuple;
  LOutXml, LOutIni, LOutBin: TTupByteStrBoolIntIntStrTuple;
begin
  LInput := Tuple.Create(Tuple.Create('Hello'), Byte(0), '', true, Integer(-5), Integer(188), 'Four__');

  LOutXml := SerializeInXML<TTupByteStrBoolIntIntStrTuple>(LInput);
  LOutIni := SerializeInIni<TTupByteStrBoolIntIntStrTuple>(LInput);
  LOutBin := SerializeInBinary<TTupByteStrBoolIntIntStrTuple>(LInput);

  CheckTrue(TType<TStrTuple>.Default.AreEqual(LInput.Value1, LOutXml.Value1), '[1] Xml serialization failed!');
  CheckTrue(TType<TStrTuple>.Default.AreEqual(LInput.Value1, LOutIni.Value1), '[1] Ini serialization failed!');
  CheckTrue(TType<TStrTuple>.Default.AreEqual(LInput.Value1, LOutBin.Value1), '[1] Binary serialization failed!');

  CheckEquals(LInput.Value2, LOutXml.Value2, '[2] Xml serialization failed!');
  CheckEquals(LInput.Value2, LOutIni.Value2, '[2] Ini serialization failed!');
  CheckEquals(LInput.Value2, LOutBin.Value2, '[2] Binary serialization failed!');

  CheckEquals(LInput.Value3, LOutXml.Value3, '[3] Xml serialization failed!');
  CheckEquals(LInput.Value3, LOutIni.Value3, '[3] Ini serialization failed!');
  CheckEquals(LInput.Value3, LOutBin.Value3, '[3] Binary serialization failed!');

  CheckEquals(LInput.Value4, LOutXml.Value4, '[4] Xml serialization failed!');
  CheckEquals(LInput.Value4, LOutIni.Value4, '[4] Ini serialization failed!');
  CheckEquals(LInput.Value4, LOutBin.Value4, '[4] Binary serialization failed!');

  CheckEquals(LInput.Value5, LOutXml.Value5, '[5] Xml serialization failed!');
  CheckEquals(LInput.Value5, LOutIni.Value5, '[5] Ini serialization failed!');
  CheckEquals(LInput.Value5, LOutBin.Value5, '[5] Binary serialization failed!');

  CheckEquals(LInput.Value6, LOutXml.Value6, '[6] Xml serialization failed!');
  CheckEquals(LInput.Value6, LOutIni.Value6, '[6] Ini serialization failed!');
  CheckEquals(LInput.Value6, LOutBin.Value6, '[6] Binary serialization failed!');

  CheckEquals(LInput.Value7, LOutXml.Value7, '[7] Xml serialization failed!');
  CheckEquals(LInput.Value7, LOutIni.Value7, '[7] Ini serialization failed!');
  CheckEquals(LInput.Value7, LOutBin.Value7, '[7] Binary serialization failed!');
end;

procedure TTestGrossSerialization.Test_WideCharSet;
var
  LInput: TWideCharSet;
  LOutXml, LOutIni, LOutBin: TWideCharSet;
begin
  LInput := TWideCharSet.Create('637821');

  LOutXml := SerializeInXML<TWideCharSet>(LInput);
  LOutIni := SerializeInIni<TWideCharSet>(LInput);
  LOutBin := SerializeInBinary<TWideCharSet>(LInput);

  CheckTrue(LInput = LOutXml, '[charset] Xml serialization failed!');
  CheckTrue(LInput = LOutIni, '[charset] Ini serialization failed!');
  CheckTrue(LInput = LOutBin, '[charset] Bin serialization failed!');
end;

{ TTestEnexSerialization }


type
  TIntStrDict = TDictionary<Integer, String>;

procedure TTestEnexSerialization.Test_Dictionary;
var
  LInput: TIntStrDict;
  LOutXml, LOutIni, LOutBin: TIntStrDict;
begin
  LInput := TIntStrDict.Create();
  LInput.Add(0, 'Hello');
  LInput.Add(4, 'Serialization');
  LInput.Add(2, 'You');
  LInput.Add(8, '');
  LInput.Add(3, 'Are');
  LInput.Add(1, 'Now');
  LInput.Add(9, 'Being');
  LInput.Add(7, 'Tested');
  LInput.Add(5, '.');

  {LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;}
  try
    LOutXml := TTestGrossSerialization.SerializeInXML<TIntStrDict>(LInput);
    LOutIni := TTestGrossSerialization.SerializeInIni<TIntStrDict>(LInput);
    LOutBin := TTestGrossSerialization.SerializeInBinary<TIntStrDict>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckTrue(LOutXml.Includes(LInput), 'LOutXml did not read all');
    CheckTrue(LOutIni.Includes(LInput), 'LOutIni did not read all');
    CheckTrue(LOutBin.Includes(LInput), 'LOutBin did not read all');

    CheckTrue(LInput.Includes(LOutXml), 'LOutXml did not read all');
    CheckTrue(LInput.Includes(LOutIni), 'LOutIni did not read all');
    CheckTrue(LInput.Includes(LOutBin), 'LOutBin did not read all');
  finally
    LInput.Free;
    {LOutXml.Free; -- Ref counted
    LOutIni.Free;
    LOutBin.Free;}
  end;
end;

type
  TIntStrBDM = TDoubleSortedBiDiMap<Integer, String>;

procedure TTestEnexSerialization.Test_DoubleSortedBidiMap;
var
  LInput: TIntStrBDM;
  LOutXml, LOutIni, LOutBin: TIntStrBDM;
begin
  LInput := TIntStrBDM.Create();
  LInput.Add(0, 'Hello');
  LInput.Add(4, 'Serialization');
  LInput.Add(2, 'You');
  LInput.Add(8, '');
  LInput.Add(3, 'Are');
  LInput.Add(1, 'Now');
  LInput.Add(9, 'Being');
  LInput.Add(7, 'Tested');
  LInput.Add(5, '.');

  {LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;}
  try
    LOutXml := TTestGrossSerialization.SerializeInXML<TIntStrBDM>(LInput);
    LOutIni := TTestGrossSerialization.SerializeInIni<TIntStrBDM>(LInput);
    LOutBin := TTestGrossSerialization.SerializeInBinary<TIntStrBDM>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckTrue(LOutXml.Includes(LInput), 'LOutXml did not read all');
    CheckTrue(LOutIni.Includes(LInput), 'LOutIni did not read all');
    CheckTrue(LOutBin.Includes(LInput), 'LOutBin did not read all');

    CheckTrue(LInput.Includes(LOutXml), 'LOutXml did not read all');
    CheckTrue(LInput.Includes(LOutIni), 'LOutIni did not read all');
    CheckTrue(LInput.Includes(LOutBin), 'LOutBin did not read all');
  finally
    LInput.Free;
    {LOutXml.Free; -- Ref counted
    LOutIni.Free;
    LOutBin.Free;}
  end;
end;

type
  TStringList = TList<String>;

procedure TTestEnexSerialization.Test_List;
var
  LInput: TStringList;
  LOutXml, LOutIni, LOutBin: TStringList;
begin
  LInput := TStringList.Create();
  LInput.Add('Hello');
  LInput.Add('Serialization');
  LInput.Add('You');
  LInput.Add('');
  LInput.Add('Are');
  LInput.Add('Now');
  LInput.Add('Being');
  LInput.Add('Tested');
  LInput.Add('.');

  {LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;}
  try
    LOutXml := TTestGrossSerialization.SerializeInXML<TStringList>(LInput);
    LOutIni := TTestGrossSerialization.SerializeInIni<TStringList>(LInput);
    LOutBin := TTestGrossSerialization.SerializeInBinary<TStringList>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckTrue(LOutXml.EqualsTo(LInput), 'LOutXml did not read all');
    CheckTrue(LOutIni.EqualsTo(LInput), 'LOutIni did not read all');
    CheckTrue(LOutBin.EqualsTo(LInput), 'LOutBin did not read all');
  finally
    LInput.Free;
    {LOutXml.Free;  -- Ref counted
    LOutIni.Free;
    LOutBin.Free;}
  end;
end;

type
  TSortedStringList = TSortedList<String>;


procedure TTestEnexSerialization.Test_SortedList;
var
  LInput: TSortedStringList;
  LOutXml, LOutIni, LOutBin: TSortedStringList;
begin
  LInput := TSortedStringList.Create(false);
  LInput.Add('Hello');
  LInput.Add('Serialization');
  LInput.Add('You');
  LInput.Add('');
  LInput.Add('Are');
  LInput.Add('Now');
  LInput.Add('Being');
  LInput.Add('Tested');
  LInput.Add('.');

  {LOutXml := nil;
  LOutIni := nil;
  LOutBin := nil;}
  try
    LOutXml := TTestGrossSerialization.SerializeInXML<TSortedStringList>(LInput);
    LOutIni := TTestGrossSerialization.SerializeInIni<TSortedStringList>(LInput);
    LOutBin := TTestGrossSerialization.SerializeInBinary<TSortedStringList>(LInput);

    CheckTrue(LOutXml <> nil, 'LOutXml is nil');
    CheckTrue(LOutIni <> nil, 'LOutIni is nil');
    CheckTrue(LOutBin <> nil, 'LOutBin is nil');

    CheckTrue(LOutXml.EqualsTo(LInput), 'LOutXml did not read all');
    CheckTrue(LOutIni.EqualsTo(LInput), 'LOutIni did not read all');
    CheckTrue(LOutBin.EqualsTo(LInput), 'LOutBin did not read all');
  finally
    LInput.Free;
    {LOutXml.Free; -- Ref counted
    LOutIni.Free;
    LOutBin.Free;}
  end;
end;

initialization
  TestFramework.RegisterTest(TTestGrossSerialization.Suite);
  TestFramework.RegisterTest(TTestEnexSerialization.Suite);

end.
