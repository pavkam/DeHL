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
unit DeHL.Serialization.Ini;
interface
uses SysUtils,
     Classes,
     IniFiles,
     TypInfo,
     Rtti,
     DeHL.StrConsts,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Serialization.Abstract,
     DeHL.Collections.Stack;

type
  ///  <summary>Annotate this attribute on a type or a field to control its name in the output Ini file.</summary>
  ///  <remarks>This attribute controls the name of a serialized entitity in the output Ini file. For complex entities such as
  ///  objects, arrays and records, it controls the name of the section; for simple entities such as basic types, it controls the
  ///  name of the Ini key.</remarks>
  IniName = class abstract(TCustomAttribute)
  private
    FName: String;

  public
    ///  <summary>Creates an instance of <c>IniName</c> attribute.</summary>
    ///  <param name="AName">The name of the entity used in Ini files. If an empty string is passed, the original name is used.</param>
    ///  <remarks>Note that <paramref name="AName"/> should contain an unique name. If there are more fields that are given the same name
    ///  conflicts appear and the serialization process aborts.</remarks>
    constructor Create(const AName: String = ''); overload;
  end;

  ///  <summary>Annotate this attribute on a array to control the naming of its elements in an Ini file.</summary>
  ///  <remarks>This attribute should be applied on an array if the naming chosen for each element needs to be changed.
  ///  An array is serialized in an Ini file into its own section. In that section, each element of the array is serialized by using
  ///  the name of the element type, suffixed with the index. For example for <c>array of Integer</c> the elements would be named
  ///  <c>IntegerN=X</c> where <c>N</c> is the index in the array and <c>X</c> the value of the element on that position. If
  ///  <c>[IniArrayElement('OtherName')]</c> is applied to the array, the element names would look like <c>OtherNameN=X</c>.</remarks>
  IniArrayElement = class sealed(IniName);

  ///  <summary>Ini serialization engine. Supports registry Ini files.</summary>
  ///  <remarks>This serialization engine is the least robust but offers the possibility to store any type to an Ini file (or registry).
  ///  The recommended use involves storing and reading configuration objects. Serialization and deserialization of complex types
  ///  is slow and error-prone, and thus not encouraged.</remarks>
  TIniSerializer<T> = class sealed(TSerializer<T, TCustomIniFile, String>)
  private type
    { Inner serialization scope }
    TIniSerializationContext = class(TAbstractSerializationContext<String>)
    private
      FIniFile: TCustomIniFile;
      FSerializer: TIniSerializer<T>;

      { State }
      FCurrentSection, FName: String;

      { Encoding/decoding }
      procedure Append(const Ch: Char; var X: NativeInt; var S: String); inline;
      function EncodeValue(const A: string): string;
      function DecodeValue(const A: string): string;

      { Simple function }
      function CurrentName: string; inline;

      { Attribute reading }
      procedure ProcessAttributes(const AIsArray: Boolean);
      function PrepareWriteComplex(const AIsArray: Boolean): TWriteStatus;
      function PrepareReadComplex(const AIsArray: Boolean; out ORefId: NativeUInt; out OIsRef: Boolean): TReadStatus;
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

      { Called upon closing of a type }
      procedure CloseComplexType(); override;

      { For attribute support }
      procedure PrepareWriteValue(); override;
      procedure PrepareReadValue(); override;
    public
      { Consyructor and destructor }
      constructor Create(const ASerializer: TIniSerializer<T>);
       destructor Destroy; override;

      { Writing }
      function WriteValue(const AValue: Cardinal): TWriteStatus; overload; override;
      function WriteValue(const AValue: Integer): TWriteStatus; overload; override;
      function WriteValue(const AValue: Double): TWriteStatus; overload; override;
      function WriteValue(const AValue: UnicodeString): TWriteStatus; overload; override;
      function WriteValue(const AValue: Boolean): TWriteStatus; overload; override;
      function WriteValue(const AValue: TDateTime): TWriteStatus; overload; override;
      function WriteBinaryValue(const APtrToData: Pointer; const ASize: NativeUInt): TWriteStatus; overload; override;

      { Reading }
      function ReadValue(out AValue: Cardinal): TReadStatus; overload; override;
      function ReadValue(out AValue: Integer): TReadStatus; overload; override;
      function ReadValue(out AValue: Double): TReadStatus; overload; override;
      function ReadValue(out AValue: UnicodeString): TReadStatus; overload; override;
      function ReadValue(out AValue: Boolean): TReadStatus; overload; override;
      function ReadValue(out AValue: TDateTime): TReadStatus; overload; override;

      function ReadBinaryValue(const ASupplier: TGetBinaryMethod): TReadStatus; override;

      { Control for text flow }
      function InReadableForm: Boolean; override;
    end;

  private
     FPathSeparator, FClassIdentifierValueName,
       FReferenceIdValueName, FArrayLengthValueName: string;
     FEncodeValues: Boolean;

  protected
    ///  <summary>Overriden method. Creates a new engine-specific serialization context.</summary>
    ///  <returns>The context object specific to this engine.</returns>
    function CreateContext(): TAbstractSerializationContext<String>; override;

    ///  <summary>Overriden method. Prepares the specific context for serialization.</summary>
    ///  <param name="AMedium">The Ini file to which the serialized data is written.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AMedium"/> is <c>nil</c></exception>
    procedure PrepareForSerialization(const AMedium: TCustomIniFile); override;

    ///  <summary>Overriden method. Prepares the specific context for deserialization.</summary>
    ///  <param name="AMedium">The Ini file from which the serialized data is read.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AMedium"/> is <c>nil</c></exception>
    procedure PrepareForDeserialization(const AMedium: TCustomIniFile); override;

  public
    ///  <summary>Initializes the internals of this object.</summary>
    ///  <remarks>Do not call this method directly. It is a part of object creation process.</remarks>
    procedure AfterConstruction; override;

    ///  <summary>Specifies the section path separator.</summary>
    ///  <returns>A character used to separate nested sections in an Ini file.</returns>
    ///  <remarks>The value of this property is used for nested section names (ex. <c>[SomeObject\FSomeOtherObj]</c>).
    ///  The nested sections are used when serializing objects that contain other objects and etc.</remarks>
    property SectionPathSeparator: string read FPathSeparator write FPathSeparator;

    ///  <summary>Specifies the name of a special Ini key that stores the class name.</summary>
    ///  <returns>A string that specifies the class name identifier.</returns>
    ///  <remarks>When an object is serialized, a new section is created to store its contents. Whithin that section
    ///  each of object's fields are stored as classic Ini <c>Key=Value</c> pairs. This property specifies the name of a special
    ///  key that contains the name of the object's class. Class name is used at deserialization time to properly
    ///  instantiate the class.</remarks>
    property ClassIdentifierValueName: string read FClassIdentifierValueName write FClassIdentifierValueName;

    ///  <summary>Specifies the name of a special Ini key that stores a reference Id.</summary>
    ///  <returns>A string that specifies the reference Id identifier.</returns>
    ///  <remarks>When an object (or any other type based on references, such as dynamic array or pointer to record) is serialized,
    ///  a new section is created to store its contents. The value of this property is a special
    ///  key that contains an unique ID associated with this serialized reference type. This value is used at serialization and
    ///  deserialization time to properly reference values between each other.</remarks>
    property ReferenceIdValueName: string read FReferenceIdValueName write FReferenceIdValueName;

    ///  <summary>Specifies the name of a special Ini key that stores the length of a serialized array.</summary>
    ///  <returns>A string that specifies the array length identifier.</returns>
    ///  <remarks>For Ini sections that represent an array, this value is used as a special property that specifies the number
    ///  of elements in the array.</remarks>
    property ArrayLengthValueName: string read FArrayLengthValueName write FArrayLengthValueName;

    ///  <summary>Specifies whether the serialized values are encoded.</summary>
    ///  <returns><c>True</c> if the values are encoded; <c>False</c> otherwise.</returns>
    ///  <remarks>Each value stored in an Ini file has the form of <c>Key=Value</c>. There are certain restrictions
    ///  that the values must abide to (ex. a value cannot contain the newline character). Setting this property to <c>True</c>
    ///  ensures that the values are properly encoded with special characters escaped. Setting this proprty to <c>False</c> may result
    ///  in a corruped Ini file.</remarks>
    property EncodeValues: Boolean read FEncodeValues write FEncodeValues;
  end;

implementation

{ TIniSerializer<T> }

procedure TIniSerializer<T>.AfterConstruction;
begin
  inherited;

  FClassIdentifierValueName := SClassIdentifierValueName;
  FReferenceIdValueName := SReferenceIdValueName;
  FPathSeparator := SSectionPathSeparator;
  FArrayLengthValueName := SArrayLengthValueName;

  FEncodeValues := true;
end;

function TIniSerializer<T>.CreateContext: TAbstractSerializationContext<String>;
begin
  Result := TIniSerializationContext.Create(Self);
end;

procedure TIniSerializer<T>.PrepareForDeserialization(const AMedium: TCustomIniFile);
begin
  if AMedium = nil then
    ExceptionHelper.Throw_ArgumentNilError('AMedium');

  { Clean-up }
  TIniSerializationContext(Context).FIniFile := AMedium;
  TIniSerializationContext(Context).FCurrentSection := '';
end;

procedure TIniSerializer<T>.PrepareForSerialization(const AMedium: TCustomIniFile);
begin
  if AMedium = nil then
    ExceptionHelper.Throw_ArgumentNilError('AMedium');

  { Clean-up }
  TIniSerializationContext(Context).FIniFile := AMedium;
  TIniSerializationContext(Context).FCurrentSection := '';
end;

{ TIniSerializer<T>.TIniSerializationContext }

procedure TIniSerializer<T>.TIniSerializationContext.Append(const Ch: Char; var X: NativeInt; var S: String);
begin
  S[X] := '\';
  S[X + 1] := Ch;

  Inc(X);
end;

procedure TIniSerializer<T>.TIniSerializationContext.CloseComplexType;
var
  I: NativeInt;
begin
  { Search for the separator }
  if FCurrentSection <> '' then
    for I := Length(FCurrentSection) downto 1 do
      if FCurrentSection[I] = FSerializer.FPathSeparator then
      begin
        { Dount our separator and please exit }
        Delete(FCurrentSection, I, Length(FCurrentSection));
        Exit;
      end;

  { Erase all }
  FCurrentSection := '';
end;

constructor TIniSerializer<T>.TIniSerializationContext.Create(const ASerializer: TIniSerializer<T>);
begin
  inherited Create();

  { Simple as that }
  FSerializer := ASerializer;
end;

function TIniSerializer<T>.TIniSerializationContext.CurrentName: string;
begin
  { Check what to use }
  if CurrentType = ctArray then
  begin
    { Element name }
    if CurrentCustomData <> '' then
      Result := CurrentCustomData + IntToStr(CurrentElementIndex)
    else
      Result := FName + IntToStr(CurrentElementIndex)
  end else
    Result := FName;
end;

function TIniSerializer<T>.TIniSerializationContext.DecodeValue(const A: string): string;
var
  I, X: NativeInt;
begin
  { Max length eva! }
  SetLength(Result, Length(A));

  X := 1;
  I := 1;

  while I <= Length(A) do
  begin
    if (A[I] = '\') then
    begin
      if (I <= Length(A)) then
      begin
        Inc(I);

        case AnsiChar(A[I]) of
          '_': Result[X] := ' ';
          'r': Result[X] := #13;
          'n': Result[X] := #10;
          't': Result[X] := #9;
          '\': Result[X] := '\';
          '0': Result[X] := #0;
        end;
      end;
    end else
      Result[X] := A[I];

    Inc(I);
    Inc(X);
  end;

  { reset length }
  SetLength(Result, X - 1);
end;

destructor TIniSerializer<T>.TIniSerializationContext.Destroy;
begin
  inherited;
end;

function TIniSerializer<T>.TIniSerializationContext.EncodeValue(const A: string): string;
var
  I, X: NativeInt;
begin
  { Max length eva! }

  X := 1;

  for I := 1 to Length(A) do
  begin
  SetLength(Result, Length(A) * 2);
    if A[I] = ' ' then
      Append('_', X, Result) else
    if A[I] = #13 then
      Append('r', X, Result) else
    if A[I] = #10 then
      Append('n', X, Result) else
    if A[I] = #9 then
      Append('t', X, Result) else
    if A[I] = '\' then
      Append('\', X, Result) else
    if A[I] = #0 then
      Append('0', X, Result) else
      Result[X] := A[I];

    Inc(X);
  end;

  { reset length }
  SetLength(Result, X - 1);
end;

function TIniSerializer<T>.TIniSerializationContext.InReadableForm: Boolean;
begin
  Result := True;
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareReadArray(out OReferenceId, OArrayLength: NativeUInt;
  out AIsReference: Boolean): TReadStatus;
begin
  { Read the frekking complex }
  Result := PrepareReadComplex(true, OReferenceId, AIsReference);

  if (Result <> rsSuccess) or AIsReference then
    Exit;

  try
    OReferenceId := FIniFile.ReadInteger(FCurrentSection, FSerializer.FReferenceIdValueName, 0);
    OArrayLength := FIniFile.ReadInteger(FCurrentSection, FSerializer.FArrayLengthValueName, 0);
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareReadClass(out OClass: TClass; out OReferenceId: NativeUInt;
  out AIsReference: Boolean): TReadStatus;
var
  LClass: String;
begin
  { Read the frekking complex }
  Result := PrepareReadComplex(false, OReferenceId, AIsReference);

  if (Result <> rsSuccess) or AIsReference then
    Exit;

  try
    LClass := FIniFile.ReadString(FCurrentSection, FSerializer.FClassIdentifierValueName, '');
    OReferenceId := FIniFile.ReadInteger(FCurrentSection, FSerializer.FReferenceIdValueName, 0);

    { Obtain the class type by the name }
    OClass := GetClassByQualifiedName(LClass);
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareReadComplex(const AIsArray: Boolean;
  out ORefId: NativeUInt; out OIsRef: Boolean): TReadStatus;
var
  LExtendedSection: String;
begin
  ProcessAttributes(AIsArray);

  { Obtain the new section name }
  if FCurrentSection = '' then
    LExtendedSection := CurrentName
  else
    LExtendedSection := FCurrentSection + FSerializer.FPathSeparator + CurrentName;

  OIsRef := false;
  ORefId := 0;

  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
  try
    { Succeeds ... }
    OIsRef := true;
    ORefId := FIniFile.ReadInteger(FCurrentSection, CurrentName, 0);
    Exit(rsSuccess);
  except
    Exit(rsReadError);
  end;

  { ... continue further down the road with checking for section ... }
  if not FIniFile.SectionExists(LExtendedSection) then
    Exit(rsUnexpected);

  { Switch sections }
  FCurrentSection := LExtendedSection;
  Result := rsSuccess;
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareReadRecord(out OReferenceId: NativeUInt;
  out AIsReference: Boolean): TReadStatus;
begin
  { Read the frekking complex }
  Result := PrepareReadComplex(false, OReferenceId, AIsReference);

  if (Result <> rsSuccess) or AIsReference then
    Exit;

  try
    OReferenceId := FIniFile.ReadInteger(FCurrentSection, FSerializer.FReferenceIdValueName, 0);
  except
    Result := rsReadError;
  end;
end;

procedure TIniSerializer<T>.TIniSerializationContext.PrepareReadValue;
begin
  inherited;

  { ... }
  ProcessAttributes(false);
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareWriteArray(const AReferenceId, AElementCount: NativeUInt): TWriteStatus;
begin
  Result := PrepareWriteComplex(true);

  if Result <> wsSuccess then
    Exit;

  { Write down the number of elements }
  FIniFile.WriteInteger(FCurrentSection, FSerializer.FArrayLengthValueName, AElementCount);

  if AReferenceId <> 0 then
    FIniFile.WriteInteger(FCurrentSection, FSerializer.FReferenceIdValueName, AReferenceId);
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareWriteClass(const AClass: TClass; const AReferenceId: NativeUInt): TWriteStatus;
begin
  Result := PrepareWriteComplex(false);

  if Result <> wsSuccess then
    Exit;

  FIniFile.WriteString(FCurrentSection, FSerializer.FClassIdentifierValueName, AClass.UnitName + '.' + AClass.ClassName);
  FIniFile.WriteInteger(FCurrentSection, FSerializer.FReferenceIdValueName, AReferenceId);
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareWriteComplex(const AIsArray: Boolean): TWriteStatus;
var
  LExtendedSection: String;
begin
  ProcessAttributes(AIsArray);

  { Obtain the new section name }
  if FCurrentSection = '' then
    LExtendedSection := CurrentName
  else
    LExtendedSection := FCurrentSection + FSerializer.FPathSeparator + CurrentName;

  if FIniFile.SectionExists(LExtendedSection) then
    Exit(wsIdentRedeclared);

  { Switch sections }
  FCurrentSection := LExtendedSection;
  Result := wsSuccess;
end;

function TIniSerializer<T>.TIniSerializationContext.PrepareWriteRecord(const AReferenceId: NativeUInt): TWriteStatus;
begin
  Result := PrepareWriteComplex(false);

  if Result <> wsSuccess then
    Exit;

  if AReferenceId <> 0 then
    FIniFile.WriteInteger(FCurrentSection, FSerializer.FReferenceIdValueName, AReferenceId);
end;

procedure TIniSerializer<T>.TIniSerializationContext.PrepareWriteValue;
begin
  inherited;

  { ... }
  ProcessAttributes(false);
end;

procedure TIniSerializer<T>.TIniSerializationContext.ProcessAttributes(const AIsArray: Boolean);
var
  LAttr: TCustomAttribute;
begin
  { Defaults }
  FName := CurrentElementInfo.Name;

  if AIsArray then
    CurrentCustomData := '';

  { Attribute reading }
  if CurrentElementInfo.&Object <> nil then
    for LAttr in CurrentElementInfo.&Object.GetAttributes() do
    begin
      { IniArrayElement }
      if (LAttr is IniArrayElement) and (IniArrayElement(LAttr).FName <> '') then
        CurrentCustomData := IniArrayElement(LAttr).FName
      else if (LAttr is IniName) and (IniName(LAttr).FName <> '') then { IniName }
        FName := IniName(LAttr).FName;
    end;
end;

function TIniSerializer<T>.TIniSerializationContext.ReadBinaryValue(const ASupplier: TGetBinaryMethod): TReadStatus;
var
  LMemStream: TMemoryStream;
  LLength: NativeInt;
  LPtr: Pointer;
begin
  { Simple Read }
  if not FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := rsUnexpected
  else
  begin
    LLength := 0;
    Result := rsSuccess;
    LMemStream := TMemoryStream.Create();

    { Read error? }
    try
      LLength := FIniFile.ReadBinaryStream(FCurrentSection, CurrentName, LMemStream);
    except
      Result := rsReadError;
    end;

    if Result = rsSuccess then
    begin
      { Obtain the actual pointer to data }
      LPtr := ASupplier(LLength);

      { And load it on }
      if (LPtr <> nil) and (LLength > 0) then
      begin
        LMemStream.Position := 0;
        LMemStream.ReadBuffer(LPtr^, LLength);
      end;
    end;

    LMemStream.Free;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.ReadValue(out AValue: UnicodeString): TReadStatus;
begin
  { Simple Read }
  if not FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := rsUnexpected
  else
  try
    AValue := FIniFile.ReadString(FCurrentSection, CurrentName, '');

    { Decode the value if needed }
    if FSerializer.FEncodeValues then
      AValue := DecodeValue(AValue);

    Result := rsSuccess;
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.ReadValue(out AValue: Double): TReadStatus;
begin
  { Simple Read }
  if not FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := rsUnexpected
  else
  try
    AValue := FIniFile.ReadFloat(FCurrentSection, CurrentName, 0);
    Result := rsSuccess;
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.ReadValue(out AValue: TDateTime): TReadStatus;
begin
  { Simple Read }
  if not FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := rsUnexpected
  else
  try
    AValue := FIniFile.ReadDateTime(FCurrentSection, CurrentName, 0);
    Result := rsSuccess;
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.ReadValue(out AValue: Boolean): TReadStatus;
begin
  { Simple Read }
  if not FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := rsUnexpected
  else
  try
    AValue := FIniFile.ReadBool(FCurrentSection, CurrentName, false);
    Result := rsSuccess;
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.ReadValue(out AValue: Cardinal): TReadStatus;
begin
  { Simple Read }
  if not FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := rsUnexpected
  else
  try
    AValue := FIniFile.ReadInteger(FCurrentSection, CurrentName, 0);
    Result := rsSuccess;
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.ReadValue(out AValue: Integer): TReadStatus;
begin
  { Simple Read }
  if not FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := rsUnexpected
  else
  try
    AValue := FIniFile.ReadInteger(FCurrentSection, CurrentName, 0);
    Result := rsSuccess;
  except
    Result := rsReadError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteBinaryValue(const APtrToData: Pointer; const ASize: NativeUInt): TWriteStatus;
var
  LValueName, LSectionName: string;
  LMemStream: TMemoryStream;
begin
  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared;

  Result := wsWriteError;

  LMemStream := TMemoryStream.Create();
  LMemStream.Write(APtrToData^, ASize);
  LMemStream.Position := 0;

  try
    { Write the actual value }
    FIniFile.WriteBinaryStream(FCurrentSection, CurrentName, LMemStream);
    Result := wsSuccess;
  finally
    LMemStream.Free;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteReference(const AReferenceId: NativeUInt): TWriteStatus;
begin
  ProcessAttributes(false);

  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared
  else
  try
    Result := wsSuccess;
    FIniFile.WriteInteger(FCurrentSection, CurrentName, AReferenceId);
  except
    Result := wsWriteError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteValue(const AValue: UnicodeString): TWriteStatus;
begin
  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared
  else
  try
    { Simple Write }
    if FSerializer.FEncodeValues then
      FIniFile.WriteString(FCurrentSection, CurrentName, EncodeValue(AValue))
    else
      FIniFile.WriteString(FCurrentSection, CurrentName, AValue)
  except
    Result := wsWriteError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteValue(const AValue: Boolean): TWriteStatus;
begin
  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared
  else
  try
    FIniFile.WriteBool(FCurrentSection, CurrentName, AValue);
  except
    Result := wsWriteError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteValue(const AValue: TDateTime): TWriteStatus;
begin
  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared
  else
  try
    FIniFile.WriteDateTime(FCurrentSection, CurrentName, AValue);
  except
    Result := wsWriteError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteValue(const AValue: Cardinal): TWriteStatus;
begin
  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared
  else
  try
    FIniFile.WriteInteger(FCurrentSection, CurrentName, AValue);
  except
    Result := wsWriteError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteValue(const AValue: Integer): TWriteStatus;
begin
  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared
  else
  try
    FIniFile.WriteInteger(FCurrentSection, CurrentName, AValue);
  except
    Result := wsWriteError;
  end;
end;

function TIniSerializer<T>.TIniSerializationContext.WriteValue(const AValue: Double): TWriteStatus;
begin
  { Simple Write }
  if FIniFile.ValueExists(FCurrentSection, CurrentName) then
    Result := wsIdentRedeclared
  else
  try
    FIniFile.WriteFloat(FCurrentSection, CurrentName, AValue);
  except
    Result := wsWriteError;
  end;
end;

{ IniName }

constructor IniName.Create(const AName: String);
begin
  FName := AName;
end;

end.

