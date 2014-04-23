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

{$I ../DeHL.Defines.inc}
unit DeHL.Serialization.Abstract;
interface
uses SysUtils,
     IniFiles,
     TypInfo,
     Rtti,
     DeHL.StrConsts,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Nullable,
     DeHL.Serialization,
     DeHL.Collections.Base,
     DeHL.Collections.Stack,
     DeHL.Collections.List,
     DeHL.Collections.HashSet,
     DeHL.Collections.Dictionary,
     DeHL.Collections.MultiMap;

type
  //TODO: doc me
  { Error notification type }
  TReadStatus = (
    rsSuccess,            { All went OK }
    rsReadError,          { Medium read error }
    rsIncompatibleType,   { The type of the expected value and the one in the medium differ }
    rsUnexpected,         { The next value to be read is different from the one here }
    rsNotBinary           { Not a binary value }
  );

  //TODO: doc me
  { Error notification type }
  TWriteStatus = (
    wsSuccess,            { All went OK }
    wsWriteError,         { Medium write error }
    wsInvalidIdent,       { Invalid identifier for writing. The name of the value is not valid in context. }
    wsIdentRedeclared     { Identifier was already stored }
  );

  //TODO: doc me
  { Describes the current complex type }
  TComplexType = (
    ctNone,
    ctClass,
    ctRecord,
    ctArray
  );

  //TODO: doc me
  { Serialization context base class }
  TAbstractSerializationContext<TData> =
    class abstract(TRefCountedObject, IContext, ISerializationContext, IDeserializationContext)
  private type
    { Stack entry }
    TStackEntry = record
      FType: TComplexType;
      FMaxElementIndex, FElementIndex: NativeUInt;
      FElementInfo: TValueInfo;
      FRefId: NativeUInt;
      FName: string;
      FData: TData; // Custom;
    end;

  private const
    CHex: array[0..15] of WideChar = '0123456789ABCDEF';

  private var
    { State based }
    FCurrentRefId: NativeUInt;
    FCurrentType: TStackEntry;
    FTypeStack: TStack<TStackEntry>;

    { Globals }
    FTypeCache: TDictionary<PTypeInfo, TObject>;
    FPointerToReference: TDictionary<Pointer, NativeUInt>;
    FReferenceToPointer: TDictionary<NativeUInt, Pointer>;
    FContext: TRttiContext;

    { Validates the result of a read operation. Throws exception if failed }
    procedure CheckRead(const AResult: TReadStatus); inline;
    procedure CheckWrite(const AResult: TWriteStatus); inline;

    { Returns the path of the current element }
    function Path(): string; overload;
{$HINTS OFF}  // Compiler complaints too much
    function Path(const AInfo: TValueInfo): string; overload;
{$HINTS ON}
    { Compiler bug. Must use pass-through methods }
    function GetType: TComplexType; inline;
    function GetRefId: NativeUInt; inline;
    function GetElementIndex: NativeUInt; inline;
    function GetElementInfo: TValueInfo; inline;

    { .. Custom }
    function GetCustom: TData; inline;
    procedure SetCustom(const AData: TData); inline;
  protected
    { Use in descendants }
    //TODO: doc me
    function GetClassByQualifiedName(const AName: String): TClass; overload;
    //TODO: doc me
    function GetClassByQualifiedName(const AUnit, AName: String): TClass; overload;

    { ISerializationContext members }
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Byte); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: ShortInt); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Word); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: SmallInt); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Cardinal); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Integer); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: UInt64); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Int64); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Single); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Double); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Extended); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Currency); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Comp); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: AnsiChar); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: WideChar); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: AnsiString); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: UnicodeString); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: Boolean); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: TDateTime); overload;
    //TODO: doc me
    procedure AddValue(const AInfo: TValueInfo; const AValue: TClass); overload;
    //TODO: doc me
    procedure AddBinaryValue(const AInfo: TValueInfo; const AValue; const ASize: NativeUInt); overload;

    { IDeserializationContext members }
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Byte); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: ShortInt); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Word); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: SmallInt); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Cardinal); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Integer); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: UInt64); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Int64); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Single); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Double); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Extended); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Currency); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Comp); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: AnsiChar); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: WideChar); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: AnsiString); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: UnicodeString); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: Boolean); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: TDateTime); overload;
    //TODO: doc me
    procedure GetValue(const AInfo: TValueInfo; out AValue: TClass); overload;
    //TODO: doc me
    procedure GetBinaryValue(const AInfo: TValueInfo; const ASupplier: TGetBinaryMethod); overload;

    { Reference and block control }
    //TODO: doc me
    function WriteReference(const AReferenceId: NativeUInt): TWriteStatus; virtual; abstract;

    { Preparation for complex types }
    //TODO: doc me
    function PrepareWriteClass(const AClass: TClass; const AReferenceId: NativeUInt): TWriteStatus; virtual; abstract;
    //TODO: doc me
    function PrepareWriteRecord(const AReferenceId: NativeUInt): TWriteStatus; virtual; abstract;
    //TODO: doc me
    function PrepareWriteArray(const AReferenceId: NativeUInt; const AElementCount: NativeUInt): TWriteStatus; virtual; abstract;

    //TODO: doc me
    function PrepareReadClass(out OClass: TClass; out OReferenceId: NativeUInt; out AIsReference: Boolean): TReadStatus; virtual; abstract;
    //TODO: doc me
    function PrepareReadRecord(out OReferenceId: NativeUInt; out AIsReference: Boolean): TReadStatus; virtual; abstract;
    //TODO: doc me
    function PrepareReadArray(out OReferenceId: NativeUInt; out OArrayLength: NativeUInt; out AIsReference: Boolean): TReadStatus; virtual; abstract;

    { Called when each of these types are finished }
    //TODO: doc me
    procedure CloseComplexType(); virtual;

    { Before and after for fields/values/elements }
    //TODO: doc me
    procedure PrepareWriteValue(); virtual;
    //TODO: doc me
    procedure PrepareReadValue(); virtual;

    { To be used in derivates }
    //TODO: doc me
    property CurrentElementInfo: TValueInfo read GetElementInfo;
    //TODO: doc me
    property CurrentElementIndex: NativeUInt read GetElementIndex;
    //TODO: doc me
    property CurrentType: TComplexType read GetType;
    //TODO: doc me
    property CurrentTypeReferenceId: NativeUInt read GetRefId;
    //TODO: doc me
    property CurrentCustomData: TData read GetCustom write SetCustom;

    { Control for text flow }
    //TODO: doc me
    function InReadableForm: Boolean; virtual; abstract;
  public

    { Consructor and destructor. Initialization }
    //TODO: doc me
    constructor Create();
    //TODO: doc me
    destructor Destroy(); override;

    (*
         Writing
    *)

    { Redirected to UInt64 }
    //TODO: doc me
    function WriteValue(const AValue: Byte): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: Word): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: Cardinal): TWriteStatus; overload; virtual;

    { Redirected to Int64 }
    //TODO: doc me
    function WriteValue(const AValue: UInt64): TWriteStatus; overload; virtual;
    //TODO: doc me
    { Redirected to Int64 }
    function WriteValue(const AValue: ShortInt): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: SmallInt): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: Integer): TWriteStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function WriteValue(const AValue: Int64): TWriteStatus; overload; virtual;

    { Redirected to Extended }
    //TODO: doc me
    function WriteValue(const AValue: Single): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: Double): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: Comp): TWriteStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function WriteValue(const AValue: Extended): TWriteStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function WriteValue(const AValue: Currency): TWriteStatus; overload; virtual;
    { Redirected to AnsiString }
    //TODO: doc me
    function WriteValue(const AValue: AnsiChar): TWriteStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function WriteValue(const AValue: WideChar): TWriteStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function WriteValue(const AValue: AnsiString): TWriteStatus; overload; virtual;

    { -- BASE -- }
    //TODO: doc me
    function WriteValue(const AValue: UnicodeString): TWriteStatus; overload; virtual; abstract;

    { Redirected to UnicodeString }
    //TODO: doc me
    function WriteValue(const AValue: Boolean): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: TDateTime): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteValue(const AValue: TClass): TWriteStatus; overload; virtual;
    //TODO: doc me
    function WriteBinaryValue(const APtrToData: Pointer; const ASize: NativeUInt): TWriteStatus; overload; virtual;

    (*
         Reading
    *)
    { Redirected to UInt64 }
    //TODO: doc me
    function ReadValue(out AValue: Byte): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: Word): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: Cardinal): TReadStatus; overload; virtual;
    { Redirected to Int64 }
    //TODO: doc me
    function ReadValue(out AValue: UInt64): TReadStatus; overload; virtual;
    { Redirected to Int64 }
    //TODO: doc me
    function ReadValue(out AValue: ShortInt): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: SmallInt): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: Integer): TReadStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function ReadValue(out AValue: Int64): TReadStatus; overload; virtual;

    { Redirected to Extended }
    //TODO: doc me
    function ReadValue(out AValue: Single): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: Double): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: Comp): TReadStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function ReadValue(out AValue: Extended): TReadStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function ReadValue(out AValue: Currency): TReadStatus; overload; virtual;
    { Redirected to AnsiString }
    //TODO: doc me
    function ReadValue(out AValue: AnsiChar): TReadStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function ReadValue(out AValue: WideChar): TReadStatus; overload; virtual;
    { Redirected to UnicodeString }
    //TODO: doc me
    function ReadValue(out AValue: AnsiString): TReadStatus; overload; virtual;
    { -- BASE -- }
    //TODO: doc me
    function ReadValue(out AValue: UnicodeString): TReadStatus; overload; virtual; abstract;
    { Redirected to UnicodeString }
    //TODO: doc me
    function ReadValue(out AValue: Boolean): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadBinaryValue(const ASupplier: TGetBinaryMethod): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: TDateTime): TReadStatus; overload; virtual;
    //TODO: doc me
    function ReadValue(out AValue: TClass): TReadStatus; overload; virtual;
    { -- WRITE: Control functions -- }
    //TODO: doc me
    function GetTypeInformation(const ATypeInfo: PTypeInfo): TRttiType;
    //TODO: doc me
    function GetTypeObject(const ATypeInfo: PTypeInfo; const ADelegate: TFunc<TObject>): TObject;
    //TODO: doc me
    procedure StartRecordType(const AInfo: TValueInfo); overload;
    //TODO: doc me
     function StartRecordType(const AInfo: TValueInfo; const AReference: Pointer): Boolean; overload;
     //TODO: doc me
     function StartClassType(const AInfo: TValueInfo; const AClass: TClass; const AReference: TObject): Boolean; overload;
//TODO: doc me
    procedure StartArrayType(const AInfo, AElementInfo: TValueInfo; const AElementCount: NativeUInt); overload;
    //TODO: doc me
     function StartArrayType(const AInfo, AElementInfo: TValueInfo; const AElementCount: NativeUInt; const AReference: Pointer): Boolean; overload;

    { -- READ: Control functions -- }
//TODO: doc me
    procedure ExpectRecordType(const AInfo: TValueInfo); overload;
    //TODO: doc me
     function ExpectRecordType(const AInfo: TValueInfo; out AReference: Pointer): Boolean; overload;
     //TODO: doc me
     function ExpectClassType(const AInfo: TValueInfo; var AClass: TClass; out AReference: TObject): Boolean; overload;
//TODO: doc me
    procedure ExpectArrayType(const AInfo, AElementInfo: TValueInfo; out OArrayLength: NativeUInt); overload;
//TODO: doc me
     function ExpectArrayType(const AInfo, AElementInfo: TValueInfo; out OArrayLength: NativeUInt; out AReference: Pointer): Boolean; overload;

    { -- Control functions -- }
//TODO: doc me
    procedure RegisterReference(const AReference: Pointer); overload;
//TODO: doc me
    procedure EndComplexType();
  end;

//TODO: doc me
  { The base class for all serialization engines }
  TSerializer<T, TMedium, TData> = class(TRefCountedObject)
  private
    FInContext: ISerializationContext;
    FOutContext: IDeserializationContext;
    FContext: TAbstractSerializationContext<TData>;
    FType: IType<T>;
    FInfo: TValueInfo;

  protected
    { Use in overridables }
//TODO: doc me
    property Context: TAbstractSerializationContext<TData> read FContext;

    { Overridables }
    //TODO: doc me
    function CreateContext(): TAbstractSerializationContext<TData>; virtual; abstract;
    //TODO: doc me
    procedure PrepareForSerialization(const AMedium: TMedium); virtual; abstract;
    //TODO: doc me
    procedure PrepareForDeserialization(const AMedium: TMedium); virtual; abstract;

  public
  //TODO: doc me
    constructor Create(); overload;
    //TODO: doc me
    constructor Create(const AType: IType<T>); overload;

    { Serialization of everything! }
    //TODO: doc me
    procedure Serialize(const AValue: T; const AMedium: TMedium);
    //TODO: doc me
    procedure Deserialize(out AValue: T; const AMedium: TMedium);
  end;

implementation

{ TAbstractSerializationContext }

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Int64): TWriteStatus;
begin
  { Redirect to UnicodeString }
  Result := WriteValue(IntToStr(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Integer): TWriteStatus;
begin
  { Redirect to Int64 }
  Result := WriteValue(Int64(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Single): TWriteStatus;
var
  LExtended: Extended;
begin
  { Redirect to Extended }
  LExtended := AValue;
  Result := WriteValue(LExtended);
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Comp): TWriteStatus;
var
  LExtended: Extended;
begin
  { Redirect to Extended }
  LExtended := CompToDouble(AValue);
  Result := WriteValue(LExtended);
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Double): TWriteStatus;
var
  LExtended: Extended;
begin
  { Redirect to Extended }
  LExtended := AValue;
  Result := WriteValue(LExtended);
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: SmallInt): TWriteStatus;
begin
  { Redirect to Int64 }
  Result := WriteValue(Int64(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Word): TWriteStatus;
begin
  { Redirect to UInt64 }
  Result := WriteValue(UInt64(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Byte): TWriteStatus;
begin
  { Redirect to UInt64 }
  Result := WriteValue(UInt64(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Cardinal): TWriteStatus;
begin
  { Redirect to UInt64 }
  Result := WriteValue(UInt64(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: ShortInt): TWriteStatus;
begin
  { Redirect to Int64 }
  Result := WriteValue(Int64(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: UInt64): TWriteStatus;
begin
  { Redirect to Int64 }
  Result := WriteValue(Int64(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Boolean): TWriteStatus;
begin
  { Redirect to UnicodeString }
  Result := WriteValue(BoolToStr(AValue, true));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: AnsiString): TWriteStatus;
begin
  { Redirect to UnicodeString }
  Result := WriteValue(String(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: TDateTime): TWriteStatus;
begin
  { Redirect to UnicodeString }
  Result := WriteValue(DateTimeToStr(AValue));
end;

function TAbstractSerializationContext<TData>.WriteBinaryValue(const APtrToData: Pointer; const ASize: NativeUInt): TWriteStatus;
var
  LStr: String;
  I: NativeInt;
  LBytes: PByte;
begin
  SetLength(LStr, ASize * 2);

  LBytes := APtrToData;
  { Generate the HEX string }
  if ASize > 0 then
    for I := 0 to ASize - 1 do
    begin
      LStr[(I * 2) + 1] := CHex[(LBytes + I)^ shr $04];
      LStr[(I * 2) + 2] := CHex[(LBytes + I)^ and $0F];
    end;

  { Redirect to UnicodeString }
  Result := WriteValue(LStr);
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Currency): TWriteStatus;
begin
  { Redirect to UnicodeString }
  Result := WriteValue(CurrToStr(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: Extended): TWriteStatus;
begin
  { Redirect to UnicodeString }
  Result := WriteValue(FloatToStr(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: WideChar): TWriteStatus;
begin
  { Redirect to UnicodeString }
  Result := WriteValue(String(AValue));
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: AnsiChar): TWriteStatus;
begin
  { Redirect to AnsiString }
  Result := WriteValue(AnsiString(AValue));
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: UInt64);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Integer);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Int64);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Double);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Single);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: ShortInt);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Byte);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Word);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Cardinal);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: SmallInt);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Extended);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Boolean);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: UnicodeString);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddBinaryValue(const AInfo: TValueInfo; const AValue; const ASize: NativeUInt);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteBinaryValue(@AValue, ASize);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: TDateTime);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: AnsiString);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Comp);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: Currency);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: WideChar);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo; const AValue: AnsiChar);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.CheckRead(const AResult: TReadStatus);
begin
  case AResult of
    rsReadError:
      ExceptionHelper.Throw_DeserializationReadError(Path(FCurrentType.FElementInfo));

    rsIncompatibleType:
      ExceptionHelper.Throw_InvalidDeserializationValue(Path(FCurrentType.FElementInfo));

    rsUnexpected:
      ExceptionHelper.Throw_UnexpectedDeserializationEntity(Path(FCurrentType.FElementInfo));

    rsNotBinary:
      ExceptionHelper.Throw_InvalidDeserializationValue(Path(FCurrentType.FElementInfo));
  end;
end;

procedure TAbstractSerializationContext<TData>.CheckWrite(const AResult: TWriteStatus);
begin
  // TODO: fix me with proper exceptions
  case AResult of
    wsWriteError:
      ExceptionHelper.Throw_ValueSerializationFailed(Path(FCurrentType.FElementInfo));

    wsInvalidIdent:
      ExceptionHelper.Throw_ValueSerializationFailed(Path(FCurrentType.FElementInfo));

    wsIdentRedeclared:
      ExceptionHelper.Throw_ValueSerializationFailed(Path(FCurrentType.FElementInfo));
  end;
end;

procedure TAbstractSerializationContext<TData>.CloseComplexType;
begin
 // Do nothing by default
end;

constructor TAbstractSerializationContext<TData>.Create();
begin
  inherited;

  { Create internals }
  FContext := TRttiContext.Create();

  FTypeCache := TDictionary<PTypeInfo, TObject>.Create(TType<PTypeInfo>.Default, TClassType<TObject>.Create(true));
  FPointerToReference := TDictionary<Pointer, NativeUInt>.Create();
  FReferenceToPointer := TDictionary<NativeUInt, Pointer>.Create();
  FTypeStack := TStack<TStackEntry>.Create();
end;

destructor TAbstractSerializationContext<TData>.Destroy;
begin
  { Kill internals }
  FReferenceToPointer.Free;
  FContext.Free;
  FTypeStack.Free;
  FPointerToReference.Free;
  FTypeCache.Free;

  inherited;
end;

procedure TAbstractSerializationContext<TData>.EndComplexType;
begin
  if FTypeStack.Count = 0 then
    ExceptionHelper.Throw_MissingCompositeType();

  { Fail for bad arrays }
  if (FCurrentType.FType = ctArray) and (FCurrentType.FMaxElementIndex <> FCurrentType.FElementIndex) then
    ExceptionHelper.Throw_InvalidArray(Path);

  { Call the virtual one for the fun of it }
  CloseComplexType();

  { Get the prev composite from the stack }
  FCurrentType := FTypeStack.Pop();
end;

procedure TAbstractSerializationContext<TData>.ExpectArrayType(const AInfo, AElementInfo: TValueInfo; out OArrayLength: NativeUInt);
var
  LRefId: NativeUInt;
  LIsRef: Boolean;
begin
  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  { And open a new block }
  CheckRead(PrepareReadArray(LRefId, OArrayLength, LIsRef));

  if LIsRef then
    ExceptionHelper.Throw_UnexpectedReferencedType(Path(AInfo));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);

  { Move forward in the tree }
  FTypeStack.Push(FCurrentType);
  FCurrentType.FType := ctArray;
  FCurrentType.FElementIndex := 0;
  FCurrentType.FElementInfo := AElementInfo;
  FCurrentType.FRefId := 0;
  FCurrentType.FName := AInfo.Name;
  FCurrentType.FMaxElementIndex := OArrayLength;

  { Prepare the values now }
  PrepareReadValue();
end;

procedure TAbstractSerializationContext<TData>.ExpectRecordType(const AInfo: TValueInfo);
var
  LRefId: NativeUInt;
  LIsRef: Boolean;
begin
  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  { And open a new block }
  CheckRead(PrepareReadRecord(LRefId, LIsRef));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);

  if LIsRef then
    ExceptionHelper.Throw_UnexpectedReferencedType(Path(AInfo));

  { Move forward in the tree }
  FTypeStack.Push(FCurrentType);
  FCurrentType.FType := ctRecord;
  FCurrentType.FRefId := 0;
  FCurrentType.FName := AInfo.Name;
end;

function TAbstractSerializationContext<TData>.ExpectRecordType(const AInfo: TValueInfo; out AReference: Pointer): Boolean;
var
  LReferenceId: NativeUInt;
  LStatus: TReadStatus;
  LIsRef: Boolean;
begin
  Result := false;
  AReference := nil;

  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  { Read dammit! }
  LStatus := PrepareReadRecord(LReferenceId, LIsRef);
  CheckRead(LStatus);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);

  if LIsRef then
  begin
    if (LReferenceId <> 0) then
      if not FReferenceToPointer.TryGetValue(LReferenceId, AReference) then
        ExceptionHelper.Throw_ReferencePointNotYetDeserialized(Path(AInfo));
  end else
  begin
    if LReferenceId = 0 then
      ExceptionHelper.Throw_ExpectedReferencedType(Path(AInfo));

    { Move forward in the tree }
    FTypeStack.Push(FCurrentType);
    FCurrentType.FType := ctRecord;
    FCurrentType.FName := AInfo.Name;

    { And open a new block }
    FCurrentType.FRefId := LReferenceId;

    Result := true;
  end;
end;

function TAbstractSerializationContext<TData>.ExpectArrayType(const AInfo, AElementInfo: TValueInfo;
  out OArrayLength: NativeUInt; out AReference: Pointer): Boolean;
var
  LReferenceId: NativeUInt;
  LStatus: TReadStatus;
  LIsRef: Boolean;
begin
  Result := false;
  AReference := nil;

  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  { Read dammit! }
  LStatus := PrepareReadArray(LReferenceId, OArrayLength, LIsRef);
  CheckRead(LStatus);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);

  if LIsRef then
  begin
    if (LReferenceId <> 0) then
      if not FReferenceToPointer.TryGetValue(LReferenceId, AReference) then
        ExceptionHelper.Throw_ReferencePointNotYetDeserialized(Path(AInfo));
  end else
  begin
    if LReferenceId = 0 then
      ExceptionHelper.Throw_ExpectedReferencedType(Path(AInfo));

    { Move forward in the tree }
    FTypeStack.Push(FCurrentType);
    FCurrentType.FType := ctArray;
    FCurrentType.FElementIndex := 0;
    FCurrentType.FElementInfo := AElementInfo;
    FCurrentType.FName := AInfo.Name;
    FCurrentType.FMaxElementIndex := OArrayLength;

    { And open a new block }
    FCurrentType.FRefId := LReferenceId;

    { Prepare the values now }
    PrepareReadValue();

    Result := true;
  end;
end;


function TAbstractSerializationContext<TData>.ExpectClassType(const AInfo: TValueInfo; var AClass: TClass; out AReference: TObject): Boolean;
var
  LReferenceId: NativeUInt;
  LNewClass: TClass;
  LStatus: TReadStatus;
  LIsRef: Boolean;
begin
  Result := false;
  AReference := nil;
  LNewClass := nil;

  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  { Read dammit! }
  LStatus := PrepareReadClass(LNewClass, LReferenceId, LIsRef);
  CheckRead(LStatus);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);

  if LIsRef then
  begin
    if (LReferenceId <> 0) then
      if not FReferenceToPointer.TryGetValue(LReferenceId, Pointer(AReference)) then
        ExceptionHelper.Throw_ReferencePointNotYetDeserialized(Path(AInfo));
  end else
  begin
    if LReferenceId = 0 then
      ExceptionHelper.Throw_ExpectedReferencedType(Path(AInfo));

    if LNewClass <> nil then
      AClass := LNewClass;

    { Move forward in the tree }
    FTypeStack.Push(FCurrentType);
    FCurrentType.FType := ctClass;
    FCurrentType.FName := AInfo.Name;

    { And open a new block }
    FCurrentType.FRefId := LReferenceId;

    Result := true;
  end;
end;

procedure TAbstractSerializationContext<TData>.RegisterReference(const AReference: Pointer);
begin
  if FTypeStack.Count = 0 then
    ExceptionHelper.Throw_MissingCompositeType();

  if AReference = nil then
   ExceptionHelper.Throw_RefRegisteredOrIsNil(Path);

  if FPointerToReference.ContainsKey(AReference) then
   ExceptionHelper.Throw_RefRegisteredOrIsNil(Path);

  { Magic }
  FPointerToReference.Add(AReference, FCurrentType.FRefId);
  FReferenceToPointer.Add(FCurrentType.FRefId, AReference);
end;

function TAbstractSerializationContext<TData>.GetClassByQualifiedName(const AName: String): TClass;
var
  LType: TRttiType;
begin
  LType := FContext.FindType(AName);

  { Find out the type }
  if LType is TRttiInstanceType then
    Result := TRttiInstanceType(LType).MetaclassType
  else
    Result := nil;
end;

function TAbstractSerializationContext<TData>.GetElementIndex: NativeUInt;
begin
  Result := FCurrentType.FElementIndex;
end;

function TAbstractSerializationContext<TData>.GetElementInfo: TValueInfo;
begin
  Result := FCurrentType.FElementInfo;
end;

function TAbstractSerializationContext<TData>.GetType: TComplexType;
begin
  Result := FCurrentType.FType;
end;

function TAbstractSerializationContext<TData>.GetRefId: NativeUInt;
begin
  Result := FCurrentType.FRefId;
end;

function TAbstractSerializationContext<TData>.GetTypeInformation(const ATypeInfo: PTypeInfo): TRttiType;
begin
  { ... }
  Result := FContext.GetType(ATypeInfo);
end;

function TAbstractSerializationContext<TData>.GetTypeObject(const ATypeInfo: PTypeInfo; const ADelegate: TFunc<TObject>): TObject;
begin
  if not FTypeCache.TryGetValue(ATypeInfo, Result) then
  begin
    { Call the delegate }
    Result := ADelegate();

    { Cache the object }
    FTypeCache.Add(ATypeInfo, Result);
  end;
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: UInt64);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Integer);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Int64);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Double);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Single);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: ShortInt);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Byte);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Word);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Cardinal);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: SmallInt);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: UnicodeString);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: AnsiString);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Boolean);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetBinaryValue(const AInfo: TValueInfo; const ASupplier: TGetBinaryMethod);
begin
  { Check refs }
  if not Assigned(ASupplier) then
    ExceptionHelper.Throw_ArgumentNilError('ASupplier');

  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadBinaryValue(ASupplier));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

function TAbstractSerializationContext<TData>.GetClassByQualifiedName(const AUnit, AName: String): TClass;
begin
  { Call the other one }
  Result := GetClassByQualifiedName(AUnit + '.' + AName);
end;

function TAbstractSerializationContext<TData>.GetCustom: TData;
begin
  Result := FCurrentType.FData;
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: TDateTime);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

function TAbstractSerializationContext<TData>.Path: string;
var
  S: TStackEntry;
begin
  Result := '';

  for S in FTypeStack do
  begin
    if (S.FName <> '') then
      Result := Result + '\' + S.FName;
  end;

  if FCurrentType.FName <> '' then
  begin
    if Result <> '' then
      Result := Result + '\' + FCurrentType.FName
    else
      Result := FCurrentType.FName;
  end;
end;

function TAbstractSerializationContext<TData>.Path(const AInfo: TValueInfo): string;
begin
  Result := Path();

  if Result <> '' then
    Result := Result + '\' + AInfo.Name
  else
    Result := AInfo.Name;
end;

procedure TAbstractSerializationContext<TData>.PrepareReadValue();
begin
 // Nothing by default
end;

procedure TAbstractSerializationContext<TData>.PrepareWriteValue();
begin
 // Nothing by default
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Currency);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Extended);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: Comp);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: WideChar);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo; out AValue: AnsiChar);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Integer): TReadStatus;
var
  LValue: Int64;
begin
  { Redirected to Int64 }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: SmallInt): TReadStatus;
var
  LValue: Int64;
begin
  { Redirected to Int64 }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Single): TReadStatus;
var
  LValue: Extended;
begin
  { Redirected to Extended }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Int64): TReadStatus;
var
  LValue: String;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    if not TryStrToInt64(LValue, AValue) then
      Result := rsIncompatibleType;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: ShortInt): TReadStatus;
var
  LValue: Int64;
begin
  { Redirected to Int64 }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Word): TReadStatus;
var
  LValue: UInt64;
begin
  { Redirected to UInt64 }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Byte): TReadStatus;
var
  LValue: UInt64;
begin
  { Redirected to UInt64 }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: UInt64): TReadStatus;
begin
  { Redirect to Int64 }
  Result := ReadValue(Int64(AValue));
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Cardinal): TReadStatus;
var
  LValue: UInt64;
begin
  { Redirected to UInt64 }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Double): TReadStatus;
var
  LValue: Extended;
begin
  { Redirected to Extended }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Boolean): TReadStatus;
var
  LValue: String;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    if not TryStrToBool(LValue, AValue) then
      Result := rsIncompatibleType;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: AnsiString): TReadStatus;
var
  LValue: String;
begin
  { Redirected to AnsiString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := AnsiString(LValue);
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: TDateTime): TReadStatus;
var
  LValue: String;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    if not TryStrToDateTime(LValue, AValue) then
      Result := rsIncompatibleType;
end;

function TAbstractSerializationContext<TData>.ReadBinaryValue(const ASupplier: TGetBinaryMethod): TReadStatus;
const
  _Z = Byte('0');
  _A = Byte('A');

var
  LValue: String;
  C1, C2: AnsiChar;
  LBytes: PByte;
  I: Integer;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
   if (Length(LValue) mod 2) <> 0 then
     Result := rsNotBinary;

  { May fail }
  if Result <> rsSuccess then
    Exit;

  { Obtain a pointer to the memory where to store data }
  LBytes := ASupplier(Length(LValue) div 2);

  { The pointer is NIL ... means nothing to be done }
  if (LBytes = nil) then
    Exit;

  for I := 0 to (Length(LValue) div 2) - 1 do
  begin
    C1 := AnsiChar(LValue[(I * 2) + 2]);
    C2 := AnsiChar(LValue[(I * 2) + 1]);

    { First 4 bits }
    case C1 of
     '0' .. '9': LBytes^ := Byte(C1) - _Z;
     'A' .. 'F': LBytes^ := Byte(C1) - _A + 10;
     else
       Exit(rsNotBinary);
    end;

    { Last 4 bits }
    case C2 of
     '0' .. '9': LBytes^ := LBytes^ + (Byte(C2) - _Z) * 16;
     'A' .. 'F': LBytes^ := LBytes^ + (Byte(C2) - _A + 10) * 16;
     else
       Exit(rsNotBinary);
    end;

    { Next please! }
    Inc(LBytes);
  end;

end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: WideChar): TReadStatus;
var
  LValue: String;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    if Length(LValue) <> 1 then
      Result := rsIncompatibleType;

  if Result = rsSuccess then
    AValue := LValue[1]
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Extended): TReadStatus;
var
  LValue: String;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    if not TryStrToFloat(LValue, AValue) then
      Result := rsIncompatibleType;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Comp): TReadStatus;
var
  LValue: Extended;
begin
  { Redirected to Extended }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    AValue := LValue;
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: AnsiChar): TReadStatus;
var
  LValue: AnsiString;
begin
  { Redirected to AnsiString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
   if Length(LValue) <> 1 then
     Result := rsIncompatibleType;

  if Result = rsSuccess then
    AValue := LValue[1]
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: Currency): TReadStatus;
var
  LValue: String;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
    if not TryStrToCurr(LValue, AValue) then
      Result := rsIncompatibleType;
end;

procedure TAbstractSerializationContext<TData>.StartRecordType(const AInfo: TValueInfo);
begin
  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  { And open a new block }
  CheckWrite(PrepareWriteRecord(0));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);

  { Move forward in the tree }
  FTypeStack.Push(FCurrentType);
  FCurrentType.FType := ctRecord;
  FCurrentType.FRefId := 0;
  FCurrentType.FName := AInfo.Name;
end;

procedure TAbstractSerializationContext<TData>.StartArrayType(const AInfo, AElementInfo: TValueInfo; const AElementCount: NativeUInt);
begin
  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  { And open a new block }
  CheckWrite(PrepareWriteArray(0, AElementCount));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);

  { Move forward in the tree }
  FTypeStack.Push(FCurrentType);
  FCurrentType.FType := ctArray;
  FCurrentType.FElementIndex := 0;
  FCurrentType.FElementInfo := AElementInfo;
  FCurrentType.FRefId := 0;
  FCurrentType.FName := AInfo.Name;
  FCurrentType.FMaxElementIndex := AElementCount;

  { Prepare the values now }
  PrepareWriteValue();
end;

procedure TAbstractSerializationContext<TData>.SetCustom(const AData: TData);
begin
  FCurrentType.FData := AData;
end;

function TAbstractSerializationContext<TData>.StartArrayType(const AInfo, AElementInfo: TValueInfo;
  const AElementCount: NativeUInt; const AReference: Pointer): Boolean;
var
  LReferenceId: NativeUInt;
begin
  { Prepare }
  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  Result := false;

  { and the actual read ... }
  if (AReference = nil) then
  begin
    CheckWrite(WriteReference(0));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);
  end else if FPointerToReference.TryGetValue(AReference, LReferenceId) then
  begin
    CheckWrite(WriteReference(LReferenceId));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);
  end else
  begin
    { New ref if }
    Inc(FCurrentRefId);

    { And open a new block }
    CheckWrite(PrepareWriteArray(FCurrentRefId, AElementCount));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);

    { Move forward in the tree }
    FTypeStack.Push(FCurrentType);
    FCurrentType.FType := ctArray;
    FCurrentType.FElementIndex := 0;
    FCurrentType.FElementInfo := AElementInfo;
    FCurrentType.FRefId := FCurrentRefId;
    FCurrentType.FName := AInfo.Name;
    FCurrentType.FMaxElementIndex := AElementCount;

    { Store the new pointer }
    FPointerToReference.Add(AReference, FCurrentRefId);

    { Register ref }
    FCurrentType.FRefId := FCurrentRefId;

    { Prepare the values now }
    PrepareWriteValue();

    Result := true;
  end;
end;

function TAbstractSerializationContext<TData>.StartClassType(const AInfo: TValueInfo; const AClass: TClass; const AReference: TObject): Boolean;
var
  LReferenceId: NativeUInt;
begin
  { Preeeeepare }
  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  Result := false;

  { and the actual read ... }
  if (AReference = nil) then
  begin
    CheckWrite(WriteReference(0));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);
  end else if FPointerToReference.TryGetValue(AReference, LReferenceId) then
  begin
    CheckWrite(WriteReference(LReferenceId));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);
  end else
  begin
    { New ref if }
    Inc(FCurrentRefId);

    { And open a new block }
    CheckWrite(PrepareWriteClass(AClass, FCurrentRefId));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);

    { Move forward in the tree }
    FTypeStack.Push(FCurrentType);
    FCurrentType.FType := ctClass;
    FCurrentType.FName := AInfo.Name;

    { Store the new pointer }
    FPointerToReference.Add(AReference, FCurrentRefId);

    { Register ref }
    FCurrentType.FRefId := FCurrentRefId;

    Result := true;
  end;
end;

function TAbstractSerializationContext<TData>.StartRecordType(const AInfo: TValueInfo; const AReference: Pointer): Boolean;
var
  LReferenceId: NativeUInt;
begin
  { Prepare }
  if FCurrentType.FType <> ctArray then
    FCurrentType.FElementInfo := AInfo;

  Result := false;

  { and the actual read ... }
  if (AReference = nil) then
  begin
    CheckWrite(WriteReference(0));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);
  end else if FPointerToReference.TryGetValue(AReference, LReferenceId) then
  begin
    CheckWrite(WriteReference(LReferenceId));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);
  end else
  begin
    { New ref if }
    Inc(FCurrentRefId);

    { And open a new block }
    CheckWrite(PrepareWriteRecord(FCurrentRefId));

    if FCurrentType.FType = ctArray then
      Inc(FCurrentType.FElementIndex);

    { Move forward in the tree }
    FTypeStack.Push(FCurrentType);
    FCurrentType.FType := ctRecord;
    FCurrentType.FName := AInfo.Name;

    { Store the new pointer }
    FPointerToReference.Add(AReference, FCurrentRefId);

    { Register ref }
    FCurrentType.FRefId := FCurrentRefId;

    Result := true;
  end;
end;

{ TSerializer<T, TSource> }

constructor TSerializer<T, TMedium, TData>.Create;
begin
  { Call the other ctor }
  Create(TType<T>.Default);
end;

constructor TSerializer<T, TMedium, TData>.Create(const AType: IType<T>);
begin
  inherited Create();

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  FType := AType;

  { Open the XML serialization scope }
  FContext := CreateContext();
  FInContext := FContext;
  FOutContext := FContext;

  { Set the initial information }
  FInfo := TValueInfo.Create(FContext.GetTypeInformation(FType.TypeInfo));
end;

procedure TSerializer<T, TMedium, TData>.Deserialize(out AValue: T; const AMedium: TMedium);
begin
  { Reset the context }
  FContext.FPointerToReference.Clear();
  FContext.FReferenceToPointer.Clear();
  FContext.FCurrentRefId := 0;
  FContext.FCurrentType.FType := ctNone;

  { Prepare the serialization }
  PrepareForSerialization(AMedium);

  { Set the initial scope information }
  FType.Deserialize(FInfo, AValue, FOutContext);

  { Ident Level should be 0 }
  if FContext.FTypeStack.Count > 0 then
    ExceptionHelper.Throw_BadSerializationContext(FContext.Path());
end;

procedure TSerializer<T, TMedium, TData>.Serialize(const AValue: T; const AMedium: TMedium);
begin
  { Reset the context }
  FContext.FPointerToReference.Clear();
  FContext.FReferenceToPointer.Clear();
  FContext.FCurrentRefId := 0;
  FContext.FCurrentType.FType := ctNone;

  { Prepare the serialization }
  PrepareForSerialization(AMedium);

  { Set the initial scope information }
  FType.Serialize(FInfo, AValue, FInContext);

  { Ident Level should be 0 }
  if FContext.FTypeStack.Count > 0 then
    ExceptionHelper.Throw_BadSerializationContext(FContext.Path());
end;

procedure TAbstractSerializationContext<TData>.AddValue(const AInfo: TValueInfo;
  const AValue: TClass);
begin
  if FCurrentType.FType <> ctArray then
  begin
    { Prepare }
    FCurrentType.FElementInfo := AInfo;
    PrepareWriteValue();
  end;

  { Call internal }
  WriteValue(AValue);

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

procedure TAbstractSerializationContext<TData>.GetValue(const AInfo: TValueInfo;
  out AValue: TClass);
begin
  if FCurrentType.FType <> ctArray then
  begin
    FCurrentType.FElementInfo := AInfo;

    { Prepare }
    PrepareReadValue();
  end;

  { Call internal }
  CheckRead(ReadValue(AValue));

  if FCurrentType.FType = ctArray then
    Inc(FCurrentType.FElementIndex);
end;

function TAbstractSerializationContext<TData>.WriteValue(const AValue: TClass): TWriteStatus;
var
  LName: string;
begin
  { Create the name }
  if AValue = nil then
    LName := ''
  else
    LName := AValue.UnitName + '.' + AValue.ClassName;

  { Redirect to UnicodeString }
  Result := WriteValue(LName);
end;

function TAbstractSerializationContext<TData>.ReadValue(out AValue: TClass): TReadStatus;
var
  LValue: String;
begin
  { Redirected to UnicodeString }
  Result := ReadValue(LValue);

  if Result = rsSuccess then
  begin
    if LValue = '' then
      AValue := nil
    else begin
      { Get the class }
      AValue := GetClassByQualifiedName(LValue);

      { Did we find the class? }
      if AValue = nil then
        ExceptionHelper.Throw_ClassNotFound(Path, LValue);
    end;
  end;
end;

end.
