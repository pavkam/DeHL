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
unit DeHL.Serialization.Binary;
interface
uses SysUtils,
     Classes,
     TypInfo,
     Rtti,
     DeHL.StrConsts,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Serialization.Abstract,
     DeHL.Collections.Dictionary;

type
//TODO: put me in a IFDEF
 { Supported types }
    TStreamPointType = (
      sptByte,
      sptWord,
      sptCardinal,
      sptUInt64,
      sptShortInt,
      sptSmallInt,
      sptInteger,
      sptInt64,
      sptSingle,
      sptDouble,
      sptComp,
      sptExtended,
      sptCurrency,
      sptAnsiChar,
      sptWideChar,
      sptAnsiString,
      sptUnicodeString,
      sptBoolean,
      sptDateTime,
      sptBinary,
      sptIdentifier,
      sptReference,
      sptClass,
      sptRecord,
      sptArray
    );

    { A set of these types }
    TStreamPointTypes = set of TStreamPointType;

  ///  <summary>Binary serialization engine. Supports unidirectional streaming.</summary>
  ///  <remarks>This serialization engine offers a fast, binary, non-human-readable serialization support. The serialized data
  ///  is not strongly-typed (the type of the entity is not stored along with the actual data).</remarks>
  TBinarySerializer<T> = class sealed(TSerializer<T, TStream, Boolean>)
  private type
    { Inner serialization scope }
    TBinarySerializationContext = class(TAbstractSerializationContext<Boolean>)
    private
      FStream: TStream;
      FSerializer: TBinarySerializer<T>;

      function ReadBuffer(var ABuffer; const ASize: NativeUInt): Boolean;
      function WriteBuffer(const ABuffer; const ASize: NativeUInt): Boolean;

      function WritePoint(const AType: TStreamPointType): TWriteStatus; inline;
      function WriteNatural(const ANatural: NativeUInt): TWriteStatus;
      function WriteIdentifier(const AString: String): TWriteStatus;
      function WriteValuePrefix(const AType: TStreamPointType): TWriteStatus;

      function ReadPoint(out OType: TStreamPointType): TReadStatus;
      function ReadNatural(out ONatural: NativeUInt): TReadStatus;
      function ReadIdentifier(out OString: String): TReadStatus;

      function ReadValuePrefix(const ATypes: TStreamPointTypes; out APoint: TStreamPointType): TReadStatus; overload;
{$HINTS OFF} // Irrelevant warning appears
      function ReadValuePrefix(const AType: TStreamPointType): TReadStatus; overload;
{$HINTS ON}
    protected
      { Reference and block control }
      function WriteReference(const AReferenceId: NativeUInt): TWriteStatus; override;

      { Preparation for complex types }
      function PrepareWriteClass(const AClass: TClass; const AReferenceId: NativeUInt): TWriteStatus; override;
      function PrepareWriteRecord(const AReferenceId: NativeUInt): TWriteStatus; override;
      function PrepareWriteArray(const AReferenceId: NativeUInt; const AElementCount: NativeUInt): TWriteStatus; override;

      function PrepareReadClass(out OClass: TClass; out OReferenceId: NativeUInt; out AIsReference: Boolean): TReadStatus; override;
      function PrepareReadRecord(out OReferenceId: NativeUInt; out AIsReference: Boolean): TReadStatus; override;
      function PrepareReadArray(out OReferenceId: NativeUInt; out OArrayLength: NativeUInt; out AIsReference: Boolean): TReadStatus; override;
    public
      { Constructor and destructor }
      constructor Create(const ASerializer: TBinarySerializer<T>);
       destructor Destroy; override;

      { Writing }
      function WriteValue(const AValue: Byte): TWriteStatus; overload; override;
      function WriteValue(const AValue: Word): TWriteStatus; overload; override;
      function WriteValue(const AValue: Cardinal): TWriteStatus; overload; override;
      function WriteValue(const AValue: UInt64): TWriteStatus; overload; override;
      function WriteValue(const AValue: ShortInt): TWriteStatus; overload; override;
      function WriteValue(const AValue: SmallInt): TWriteStatus; overload; override;
      function WriteValue(const AValue: Integer): TWriteStatus; overload; override;
      function WriteValue(const AValue: Int64): TWriteStatus; overload; override;
      function WriteValue(const AValue: Single): TWriteStatus; overload; override;
      function WriteValue(const AValue: Double): TWriteStatus; overload; override;
      function WriteValue(const AValue: Comp): TWriteStatus; overload; override;
      function WriteValue(const AValue: Extended): TWriteStatus; overload; override;
      function WriteValue(const AValue: Currency): TWriteStatus; overload; override;
      function WriteValue(const AValue: AnsiChar): TWriteStatus; overload; override;
      function WriteValue(const AValue: WideChar): TWriteStatus; overload; override;
      function WriteValue(const AValue: AnsiString): TWriteStatus; overload; override;
      function WriteValue(const AValue: UnicodeString): TWriteStatus; overload; override;
      function WriteValue(const AValue: Boolean): TWriteStatus; overload; override;
      function WriteValue(const AValue: TDateTime): TWriteStatus; overload; override;
      function WriteBinaryValue(const APtrToData: Pointer; const ASize: NativeUInt): TWriteStatus; overload; override;

      { Reading }
      function ReadValue(out AValue: Byte): TReadStatus; overload; override;
      function ReadValue(out AValue: Word): TReadStatus; overload; override;
      function ReadValue(out AValue: Cardinal): TReadStatus; overload; override;
      function ReadValue(out AValue: UInt64): TReadStatus; overload; override;
      function ReadValue(out AValue: ShortInt): TReadStatus; overload; override;
      function ReadValue(out AValue: SmallInt): TReadStatus; overload; override;
      function ReadValue(out AValue: Integer): TReadStatus; overload; override;
      function ReadValue(out AValue: Int64): TReadStatus; overload; override;
      function ReadValue(out AValue: Single): TReadStatus; overload; override;
      function ReadValue(out AValue: Double): TReadStatus; overload; override;
      function ReadValue(out AValue: Comp): TReadStatus; overload; override;
      function ReadValue(out AValue: Extended): TReadStatus; overload; override;
      function ReadValue(out AValue: Currency): TReadStatus; overload; override;
      function ReadValue(out AValue: AnsiChar): TReadStatus; overload; override;
      function ReadValue(out AValue: WideChar): TReadStatus; overload; override;
      function ReadValue(out AValue: AnsiString): TReadStatus; overload; override;
      function ReadValue(out AValue: UnicodeString): TReadStatus; overload; override;
      function ReadValue(out AValue: Boolean): TReadStatus; overload; override;
      function ReadValue(out AValue: TDateTime): TReadStatus; overload; override;
      function ReadBinaryValue(const ASupplier: TGetBinaryMethod): TReadStatus; overload; override;

      { Control for text flow }
      function InReadableForm: Boolean; override;
    end;

  protected
    ///  <summary>Overriden method. Creates a new engine-specific serialization context.</summary>
    ///  <returns>The context object specific to this engine.</returns>
    function CreateContext(): TAbstractSerializationContext<Boolean>; override;

    ///  <summary>Overriden method. Prepares the specific context for serialization.</summary>
    ///  <param name="AMedium">The stream to which the serialized data is written.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AMedium"/> is <c>nil</c></exception>
    procedure PrepareForSerialization(const AMedium: TStream); override;

    ///  <summary>Overriden method. Prepares the specific context for deserialization.</summary>
    ///  <param name="AMedium">The stream from which the serialized data is read.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AMedium"/> is <c>nil</c></exception>
    procedure PrepareForDeserialization(const AMedium: TStream); override;
  end;


implementation

{ TBinarySerializer<T> }

function TBinarySerializer<T>.CreateContext: TAbstractSerializationContext<Boolean>;
begin
  Result := TBinarySerializationContext.Create(Self);
end;

procedure TBinarySerializer<T>.PrepareForDeserialization(const AMedium: TStream);
begin
  if AMedium = nil then
    ExceptionHelper.Throw_ArgumentNilError('AMedium');

  TBinarySerializationContext(Context).FStream := AMedium;
end;

procedure TBinarySerializer<T>.PrepareForSerialization(const AMedium: TStream);
begin
  if AMedium = nil then
    ExceptionHelper.Throw_ArgumentNilError('AMedium');

  TBinarySerializationContext(Context).FStream := AMedium;
end;

{ TBinarySerializer<T>.TBinarySerializationContext }

constructor TBinarySerializer<T>.TBinarySerializationContext.Create(const ASerializer: TBinarySerializer<T>);
begin
  inherited Create();

  { Initialize }
  FSerializer := ASerializer;
end;

destructor TBinarySerializer<T>.TBinarySerializationContext.Destroy;
begin
  inherited;
end;

function TBinarySerializer<T>.TBinarySerializationContext.InReadableForm: Boolean;
begin
  Result := False;
end;

function TBinarySerializer<T>.TBinarySerializationContext.PrepareReadArray(out OReferenceId: NativeUInt;
  out OArrayLength: NativeUInt; out AIsReference: Boolean): TReadStatus;
var
  LPoint: TStreamPointType;
begin
  { Try to read stuff }
  Result := ReadValuePrefix([sptArray, sptReference], LPoint);

  if Result <> rsSuccess then
    Exit;

  if LPoint = sptReference then
  begin
    { Is reference ... read it and exit }
    Result := ReadNatural(OReferenceId);
    AIsReference := true;

    Exit;
  end;

  Result := ReadNatural(OArrayLength);

  AIsReference := false;

  if Result = rsSuccess then
    Result := ReadNatural(OReferenceId);
end;

function TBinarySerializer<T>.TBinarySerializationContext.PrepareReadClass(out OClass: TClass;
  out OReferenceId: NativeUInt; out AIsReference: Boolean): TReadStatus;
var
  LUnit, LClass: String;
  LPoint: TStreamPointType;
begin
  { Try to read stuff }
  Result := ReadValuePrefix([sptClass, sptReference], LPoint);

  if Result <> rsSuccess then
    Exit;

  if LPoint = sptReference then
  begin
    { Is reference ... read it and exit }
    Result := ReadNatural(OReferenceId);
    AIsReference := true;

    Exit;
  end else

  AIsReference := false;

  Result :=  ReadIdentifier(LUnit);

  if Result = rsSuccess then
    Result :=  ReadIdentifier(LClass);

  if Result = rsSuccess then
    Result := ReadNatural(OReferenceId);

  { Obtain the class info }
  if Result = rsSuccess then
    OClass := GetClassByQualifiedName(LUnit, LClass);
end;

function TBinarySerializer<T>.TBinarySerializationContext.PrepareReadRecord(out OReferenceId: NativeUInt;
  out AIsReference: Boolean): TReadStatus;
var
  LPoint: TStreamPointType;
begin
  { Try to read stuff }
  Result := ReadValuePrefix([sptRecord, sptReference], LPoint);

  if Result <> rsSuccess then
    Exit;

  { Mark as reference }
  AIsReference := (LPoint = sptReference);

  { Read the ref id }
  Result := ReadNatural(OReferenceId);
end;

function TBinarySerializer<T>.TBinarySerializationContext.PrepareWriteArray(const AReferenceId: NativeUInt; const AElementCount: NativeUInt): TWriteStatus;
begin
  { Write the stream point and the reference id }
  Result := WriteValuePrefix(sptArray);

  { Write count of elements }
  if Result = wsSuccess then
    Result := WriteNatural(AElementCount);

  { Write reference Id }
  if Result = wsSuccess then
    Result := WriteNatural(AReferenceId);
end;

function TBinarySerializer<T>.TBinarySerializationContext.PrepareWriteClass(const AClass: TClass; const AReferenceId: NativeUInt): TWriteStatus;
begin
  { Write the stream point and the reference id }
  Result := WriteValuePrefix(sptClass);

  { Write the unit and class name }
  if Result = wsSuccess then
    Result := WriteIdentifier(AClass.UnitName);

  if Result = wsSuccess then
    Result := WriteIdentifier(AClass.ClassName);

  { Write reference id }
  if Result = wsSuccess then
    Result := WriteNatural(AReferenceId);
end;

function TBinarySerializer<T>.TBinarySerializationContext.PrepareWriteRecord(const AReferenceId: NativeUInt): TWriteStatus;
begin
  { Write the stream point and the reference id }
  Result := WriteValuePrefix(sptRecord);

  { Reference Id please! }
  if Result = wsSuccess then
    Result := WriteNatural(AReferenceId);
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadBinaryValue(const ASupplier: TGetBinaryMethod): TReadStatus;
var
  LLength: NativeUInt;
  LPtr: Pointer;
begin
  { Try to read stuff }
  Result := ReadValuePrefix(sptBinary);

  if Result = rsSuccess then
    Result := ReadNatural(LLength);

  { Obtain the required pointer }
  LPtr := ASupplier(LLength);

  if (Result = rsSuccess) and (LLength > 0) and (LPtr <> nil) then
    if not ReadBuffer(LPtr^, LLength) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadBuffer(var ABuffer; const ASize: NativeUInt): Boolean;
begin
  Result := true;

  try
    FStream.ReadBuffer(ABuffer, ASize);
  except
    Result := false;
  end;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadIdentifier(out OString: String): TReadStatus;
var
  LPoint: TStreamPointType;
  LUtf8Str: RawByteString;
  LLength: NativeUInt;
begin
  { Write the indentifier point }
  Result := ReadPoint(LPoint);

  if (Result = rsSuccess) then
    if (LPoint <> sptIdentifier) then
      Result := rsUnexpected;

  if (Result = rsSuccess) then
    Result := ReadNatural(LLength);

  if (Result = rsSuccess) then
  begin
    SetLength(LUtf8Str, LLength);

    if LLength > 0 then
    begin
      if not ReadBuffer(LUtf8Str[1], LLength) then
        Result := rsReadError
      else
        OString := UTF8ToString(LUtf8Str);
    end;
  end;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadNatural(out ONatural: NativeUInt): TReadStatus;
const
{$IF SizeOf(NativeUInt) > SizeOf(Cardinal)}
  CAllowed = [sptByte, sptWord, sptCardinal, sptInt64];
{$ELSE}
  CAllowed = [sptByte, sptWord, sptCardinal];
{$IFEND}

var
  LPoint: TStreamPointType;
  LByte: Byte;
  LWord: Word;
  LCard: Cardinal;
begin
  { Read the stream point type }
  Result := ReadPoint(LPoint);

  if (Result = rsSuccess) then
    if not (LPoint in CAllowed) then
      Result := rsUnexpected;

  { Exit if failed }
  if Result <> rsSuccess then
    Exit;

  { Detect the proper value to use }
  if LPoint = sptByte then
  begin
    { Was a byte }
    if not ReadBuffer(LByte, SizeOf(Byte)) then
      Result := rsReadError
    else
      ONatural := LByte;
  end else
  if LPoint = sptWord then
  begin
    { Was a word }
    if not ReadBuffer(LWord, SizeOf(Word)) then
      Result := rsReadError
    else
      ONatural := LWord;
  end else
{$IF SizeOf(NativeUInt) > SizeOf(Cardinal)}
  if LPoint = sptCardinal then
  begin
    { Was a cardinal }
    if not ReadBuffer(LCard, SizeOf(Cardinal)) then
      Result := rsReadError
    else
      ONatural := LCard;
  end else
{$IFEND}
  begin
    { Was a cardinal }
    if not ReadBuffer(ONatural, SizeOf(NativeUInt)) then
      Result := rsReadError
  end;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadPoint(out OType: TStreamPointType): TReadStatus;
var
  LByte: Byte;
begin
  Result := rsSuccess;

  { Try to read the point }
  if not ReadBuffer(LByte, SizeOf(Byte)) then
    Result := rsReadError;

  { Check the type please }
  if not (TStreamPointType(LByte) in [sptByte .. sptArray]) then
    Result := rsReadError;

  if Result = rsSuccess then
    OType := TStreamPointType(LByte);
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: UInt64): TReadStatus;
begin
  Result := ReadValuePrefix(sptUInt64);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(UInt64)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: ShortInt): TReadStatus;
begin
  Result := ReadValuePrefix(sptShortInt);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(ShortInt)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Cardinal): TReadStatus;
begin
  Result := ReadValuePrefix(sptCardinal);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Cardinal)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Byte): TReadStatus;
begin
  Result := ReadValuePrefix(sptByte);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Byte)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Word): TReadStatus;
begin
  Result := ReadValuePrefix(sptWord);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Word)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: WideChar): TReadStatus;
begin
  Result := ReadValuePrefix(sptWideChar);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(WideChar)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: AnsiChar): TReadStatus;
begin
  Result := ReadValuePrefix(sptAnsiChar);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(AnsiChar)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Currency): TReadStatus;
begin
  Result := ReadValuePrefix(sptCurrency);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Currency)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: AnsiString): TReadStatus;
var
  LStrCodePage: NativeUInt;
  LStrLength: NativeUInt;
begin
  { Read read ... and again read }
  Result := ReadValuePrefix(sptAnsiString);

  if Result = rsSuccess then
    Result := ReadNatural(LStrCodePage);

  if Result = rsSuccess then
    Result := ReadNatural(LStrLength);

  if Result = rsSuccess then
  begin
    SetLength(AValue, LStrLength);

    if (LStrLength > 0) then
    begin
      { Try and read }
      if not ReadBuffer(AValue[1], LStrLength * SizeOf(AnsiChar)) then
        Result := rsReadError
      else
        PWord(NativeInt(AValue) - 12)^  := LStrCodePage;     { Set codepage }
    end;
  end;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: TDateTime): TReadStatus;
begin
  Result := ReadValuePrefix(sptDateTime);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(TDateTime)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValuePrefix(const AType: TStreamPointType): TReadStatus;
var
  LDummy: TStreamPointType;
begin
  Result := ReadValuePrefix([AType], LDummy);
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValuePrefix(const ATypes: TStreamPointTypes;
  out APoint: TStreamPointType): TReadStatus;
var
  LIndent: String;
  LIndex: NativeUInt;
begin
  { Try to read the point }
  Result := ReadPoint(APoint);

  if Result = rsSuccess then
    if not (APoint in ATypes) then
      Result := rsIncompatibleType;

  { Boom! }
  if Result <> rsSuccess then
    Exit;

  { Read the label only if required }
  if CurrentType <> ctArray then
  begin
    Result := ReadIdentifier(LIndent);

    { Validate }
    if Result = rsSuccess then
      if CurrentElementInfo.Name <> LIndent then
        Result := rsUnexpected;
  end else
  begin
    Result := ReadNatural(LIndex);

    { Validate }
    if Result = rsSuccess then
      if CurrentElementIndex <> LIndex then
        Result := rsUnexpected;
  end;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Boolean): TReadStatus;
begin
  Result := ReadValuePrefix(sptBoolean);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Boolean)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: UnicodeString): TReadStatus;
var
  LStrLength: NativeUInt;
begin
  { Read read ... and again read }
  Result := ReadValuePrefix(sptUnicodeString);

  if Result = rsSuccess then
    Result := ReadNatural(LStrLength);

  if Result = rsSuccess then
  begin
    SetLength(AValue, LStrLength);

    if (LStrLength > 0) then
      if not ReadBuffer(AValue[1], LStrLength * SizeOf(WideChar)) then
        Result := rsReadError;
  end;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Int64): TReadStatus;
begin
  Result := ReadValuePrefix(sptInt64);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Int64)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Integer): TReadStatus;
begin
  Result := ReadValuePrefix(sptInteger);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Integer)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: SmallInt): TReadStatus;
begin
  Result := ReadValuePrefix(sptSmallInt);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(SmallInt)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Single): TReadStatus;
begin
  Result := ReadValuePrefix(sptSingle);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Single)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Extended): TReadStatus;
begin
  Result := ReadValuePrefix(sptExtended);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Extended)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Comp): TReadStatus;
begin
  Result := ReadValuePrefix(sptComp);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Comp)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.ReadValue(out AValue: Double): TReadStatus;
begin
  Result := ReadValuePrefix(sptDouble);

  if Result = rsSuccess then
    if not ReadBuffer(AValue, SizeOf(Double)) then
      Result := rsReadError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteBinaryValue(const APtrToData: Pointer; const ASize: NativeUInt): TWriteStatus;
begin
  { Do da dew }
  Result := WriteValuePrefix(sptBinary);

  { Write Length and then the contents }
  if Result = wsSuccess then
    WriteNatural(ASize);

  { and the contents }
  if (ASize > 0) and (Result = wsSuccess) then
    if not WriteBuffer(APtrToData^, ASize) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteBuffer(const ABuffer; const ASize: NativeUInt): Boolean;
begin
  Result := true;

  try
    FStream.WriteBuffer(ABuffer, ASize);
  except
    Result := false;
  end;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteNatural(const ANatural: NativeUInt): TWriteStatus;
var
  LByte: Byte;
  LWord: Word;
{$IF SizeOf(NativeUInt) > SizeOf(Cardinal)}
  LCard: Cardinal;
{$IFEND}
begin
  Result := wsSuccess;

  { Detect the proper value to use }
  if ANatural <= High(Byte) then
  begin
    { Fits in a byte }
    WritePoint(sptByte);

    LByte := ANatural;

    if not WriteBuffer(LByte, SizeOf(Byte)) then
      Result := wsWriteError;
  end else
  if ANatural <= High(Word) then
  begin
    { Fits in a word }
    WritePoint(sptWord);

    LWord := ANatural;

    if not WriteBuffer(LWord, SizeOf(Word)) then
      Result := wsWriteError;
  end else
{$IF SizeOf(NativeUInt) > SizeOf(Cardinal)}
  if ANatural <= High(Cardinal) then
  begin
    { Fits in a word }
    WritePoint(sptCardinal);

    LCard := ANatural;

    if not WriteBuffer(LCard, SizeOf(Cardinal)) then
      Result := wsWriteError;
  end else
  begin
    { Doesn't fit anywhere }
    WritePoint(sptUInt64);           //TODO: Figure out how to make this transparent.

    if not WriteBuffer(ANatural, SizeOf(NativeUInt)) then
      Result := wsWriteError;
  end;
{$ELSE}
  begin
    { Doesn't fit anywhere }
    WritePoint(sptCardinal);

    if not WriteBuffer(ANatural, SizeOf(Cardinal)) then
      Result := wsWriteError;
  end;
{$IFEND}
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValuePrefix(const AType: TStreamPointType): TWriteStatus;
begin
  { Write stream point }
  Result := WritePoint(AType);

  if Result <> wsSuccess then
    Exit;

  { Write the label only if required }
  if CurrentType <> ctArray then
    Result := WriteIdentifier(CurrentElementInfo.Name)
  else
    Result := WriteNatural(CurrentElementIndex);
end;

function TBinarySerializer<T>.TBinarySerializationContext.WritePoint(const AType: TStreamPointType): TWriteStatus;
var
  LTypeByte: Byte;
begin
  { And write the type }
  LTypeByte := Ord(AType);

  if not WriteBuffer(LTypeByte, SizeOf(Byte)) then
    Result := wsWriteError
  else
    Result := wsSuccess;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteReference(const AReferenceId: NativeUInt): TWriteStatus;
begin
  { Write prefix }
  Result := WriteValuePrefix(sptReference);

  { And reference ID }
  if Result = wsSuccess then
    Result := WriteNatural(AReferenceId);
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteIdentifier(const AString: String): TWriteStatus;
var
  LUtf8Str: RawByteString;
  LLength: NativeUInt;
begin
  { Write the indentifier point }
  Result := WritePoint(sptIdentifier);

  if Result <> wsSuccess then
    Exit;

  { UTF8-ify }
  LUtf8Str := UTF8Encode(AString);

  { Obtain the length }
  LLength := Length(LUtf8Str);

  { Write the length down }
  Result := WriteNatural(LLength);

  if Result <> wsSuccess then
    Exit;

  { Write contents if required }
  if LLength > 0 then
    if not WriteBuffer(LUtf8Str[1], LLength) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Word): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptWord);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Word)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Byte): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptByte);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Byte)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: UInt64): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptUInt64);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(UInt64)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Cardinal): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptCardinal);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Cardinal)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Boolean): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptBoolean);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Boolean)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: TDateTime): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptDateTime);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(TDateTime)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: AnsiString): TWriteStatus;
var
  LStrCodePage: Word;
  LStrLength: NativeUInt;
begin
  { Obtain string info }
  LStrCodePage := StringCodePage(AValue);
  LStrLength := Length(AValue);

  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptAnsiString);

  { Write CP, Length and then the contents }
  if Result = wsSuccess then
    Result := WriteNatural(LStrCodePage);

  if Result = wsSuccess then
    Result := WriteNatural(LStrLength);

  { and the contents }
  if (LStrLength > 0) and (Result = wsSuccess)  then
    if not WriteBuffer(AValue[1], LStrLength) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: UnicodeString): TWriteStatus;
var
  LStrLength: NativeUInt;
begin
  { Obtain string info }
  LStrLength := Length(AValue);

  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptUnicodeString);

  { Write Length and then the contents }
  if Result = wsSuccess then
    Result := WriteNatural(LStrLength);

  { and the contents }
  if (LStrLength > 0) and (Result = wsSuccess) then
    if not WriteBuffer(AValue[1], LStrLength * SizeOf(WideChar)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Extended): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptExtended);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Extended)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Comp): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptComp);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Comp)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Currency): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptCurrency);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Currency)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: WideChar): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptWideChar);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(WideChar)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: AnsiChar): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptAnsiChar);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(AnsiChar)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Double): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptDouble);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Double)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: SmallInt): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptSmallInt);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(SmallInt)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: ShortInt): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptShortInt);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(ShortInt)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Integer): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptInteger);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Integer)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Single): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptSingle);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Single)) then
      Result := wsWriteError;
end;

function TBinarySerializer<T>.TBinarySerializationContext.WriteValue(const AValue: Int64): TWriteStatus;
begin
  { Prefix, value, then suffix }
  Result := WriteValuePrefix(sptInt64);

  if Result = wsSuccess then
    if not WriteBuffer(AValue, SizeOf(Int64)) then
      Result := wsWriteError;
end;

end.
