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
unit DeHL.Serialization.XML;
interface
uses SysUtils,
     XMLDoc,
     XMLIntf,
     TypInfo,
     Rtti,
     DeHL.StrConsts,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Nullable,
     DeHL.Serialization,
     DeHL.Serialization.Abstract,
     DeHL.Collections.Base,
     DeHL.Collections.Stack,
     DeHL.Collections.HashSet,
     DeHL.Collections.Dictionary;

type
  ///  <summary>Annotate this attribute on a type or a field to control its name.</summary>
  ///  <remarks>The name specified through this attribute is used by the XML serializer to name either the elements
  ///  or the value attributes.</remarks>
  XmlName = class abstract(TCustomAttribute)
  private
    FName: String;
    FNamespace: String;

  public
    ///  <summary>Creates an instance of <c>XmlName</c> attribute.</summary>
    ///  <param name="AName">The new name offered to the serialized entitity. If an empty string is passed, the original name is used.</param>
    ///  <param name="ANamespace">The XML namespace of the serialized entity.</param>
    ///  <remarks>Note that <paramref name="AName"/> should contain an unique name. If there are more fields that are given the same name
    ///  conflicts appear and the serialization process aborts.</remarks>
    constructor Create(const AName: String = ''; const ANamespace: String = '');
  end;

  ///  <summary>Annotate this attribute on an array to change the name used when serializing elements of an array.</summary>
  ///  <remarks>The name specified through this attribute is used by the XML serializer to name the elements of an array.</remarks>
  XmlArrayElement = class sealed(TCustomAttribute)
  private
    FName: String;

  public
    ///  <summary>Creates an instance of <c>XmlArrayElement</c> attribute.</summary>
    ///  <param name="AName">The new name offered to the serialized array elements. If an empty string is passed, the original name is used.</param>
    constructor Create(const AName: String);
  end;

  ///  <summary>Annotate this attribute on a field to force the serializer to use an XML element for it.</summary>
  ///  <remarks>By default, the XML serializer will try to store simple fields as attributes on the parent object's element. This attribute
  ///  forces the serializer to create a new child element for the serialized value. This attribute has no effect if the field is a complex
  ///  type such as array, record or class.</remarks>
  XmlElement = class sealed(TCustomAttribute);

  ///  <summary>Annotate this attribute on a field to force the serializer to use an XML attribute for it.</summary>
  ///  <remarks>By default, the XML serializer will try to store simple fields as attributes on the parent object's element.
  ///  Use this attribute to explicitly state that an attribute is preferred to an element.</remarks>
  XmlAttribute = class sealed(TCustomAttribute);

  ///  <summary>Annotate this attribute on a field to force the serializer to skip references that have a <c>nil</c> value.</summary>
  ///  <remarks>This attribute controls whether the serializer will include a reference (object, dynamic array, etc.) value in the
  ///  output XML node if it is <c>nil</c>. To force the serializer to skip these values, apply this attribute.</remarks>
  XmlNullable = class sealed(TCustomAttribute);

  ///  <summary>Internal record! Used as a generic type parameter for the speciailized serializer.</summary>
  ///  <remarks>This type is used to carry some specific data between type nested levels.</remarks>
  TXmlSerializeData = record
  private
    FNS, FElementName: String;

    function ChangeNS(const AString: String): TXmlSerializeData;
    function ChangeElementName(const AString: String): TXmlSerializeData;
  end;

  ///  <summary>XML serialization engine. Use <c>TXMLDocument</c> to do the XML processing.</summary>
  ///  <remarks>This engine should be used when it is required to serialize an object in platform-independant way.
  ///  XML is an open standard that can be loaded and processed by all frameworks. Do not use this serialization engine
  ///  if all that is needed is a simple storage facility. For that purpose see,
  ///  <see cref="DeHL.Serialization.Binary|TBinarySerializer&lt;T&gt;">DeHL.Serialization.Binary.TBinarySerializer&lt;T&gt;</see></remarks>
  TXmlSerializer<T> = class sealed(TSerializer<T, IXMLNode, TXmlSerializeData>)
  private type
    { Inner serialization scope }
    TXmlSerializationContext = class(TAbstractSerializationContext<TXmlSerializeData>)
    private
      FTopNode, FCurrentNode: IXMLNode;
      FSerializer: TXmlSerializer<T>;

      { State }
      FNSSet: THashSet<String>;
      FIsNullable, FAsElement: Boolean;
      FNS, FName: String;

      { Process attributes }
      procedure ProcessAttributes(const AIsArray: Boolean);
      function CurrentName: string; inline;

      { Creates a new node and ++ }
      function MakeNode(const ATag, ANS: String; out AStatus: TWriteStatus): IXMLNode;
      procedure MakeAttr(const ANode: IXMLNode; const AName, ANS, APrefix, AValue: String; out AStatus: TWriteStatus);

      { Reads node and attrs }
      function GetNode(const AName, ANS: String; const AIndex: NativeUInt): IXMLNode;
      function ReadAttr(const ANode: IXMLNode; const AName, ANS: String; out AStatus: TReadStatus): String;


      { Register a NS at the top element }
      function RegisterNSAtTop(const APrefix, AURI: String): Boolean;

      { Resets this context }
      procedure Reset;

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
      { Constructor and destructor }
      constructor Create(const ASerializer: TXmlSerializer<T>);
       destructor Destroy; override;

      { Writing }
      function WriteValue(const AValue: UnicodeString): TWriteStatus; overload; override;

      { Reading }
      function ReadValue(out AValue: UnicodeString): TReadStatus; overload; override;

      { Control for text flow }
      function InReadableForm: Boolean; override;
    end;

  private
    { Node names }
    FReferenceIdAttribute, FReferenceToAttribute,
      FClassAttribute, FElementsAttribute: String;

    FDefaultToTags: Boolean;
    FXSI, FXSD, FSerializerNS: String;
  protected
    ///  <summary>Overriden method. Creates a new engine-specific serialization context.</summary>
    ///  <returns>The context object specific to this engine.</returns>
    function CreateContext(): TAbstractSerializationContext<TXmlSerializeData>; override;

    ///  <summary>Overriden method. Prepares the specific context for serialization.</summary>
    ///  <param name="AMedium">The XML node to which the serialized data is written.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AMedium"/> is <c>nil</c></exception>
    procedure PrepareForSerialization(const AMedium: IXMLNode); override;

    ///  <summary>Overriden method. Prepares the specific context for deserialization.</summary>
    ///  <param name="AMedium">The XML node from which the serialized data is read.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AMedium"/> is <c>nil</c></exception>
    procedure PrepareForDeserialization(const AMedium: IXMLNode); override;
  public
    ///  <summary>Initializes the internals of this object.</summary>
    ///  <remarks>Do not call this method directly. It is a part of object creation process.</remarks>
    procedure AfterConstruction; override;

    ///  <summary>Specifies the name of a special XML attribute used by this serialization engine to store an unique ID associated with
    ///  a reference type.</summary>
    ///  <returns>The name of the special XML attribute.</returns>
    ///  <remarks>This property cannot be an empty string. This would result in failed serialization.</remarks>
    property ReferenceIdAttribute: String read FReferenceIdAttribute write FReferenceIdAttribute;

    ///  <summary>Specifies the name of a special XML attribute used by this serialization engine to store an ID to a reference type.</summary>
    ///  <returns>The name of the special XML attribute.</returns>
    ///  <remarks>The XML attribute specified by this property is used when a "link" is made between two reference types.
    ///  This property cannot be an empty string. This would result in failed serialization.</remarks>
    property ReferenceToAttribute: String read FReferenceToAttribute write FReferenceToAttribute;

    ///  <summary>Specifies the name of a special XML attribute used by this serialization engine to store the name of the class for a
    ///  serialized object.</summary>
    ///  <returns>The name of the special XML attribute.</returns>
    ///  <remarks>This property cannot be an empty string. This would result in failed serialization.</remarks>
    property ClassTypeAttribute: String read FClassAttribute write FClassAttribute;

    ///  <summary>Specifies the name of a special XML attribute used by this serialization engine to store the number or elements in a serialized array.</summary>
    ///  <returns>The name of the special XML attribute.</returns>
    ///  <remarks>This property cannot be an empty string. This would result in failed serialization.</remarks>
    property CountOfElementsAttribute: String read FElementsAttribute write FElementsAttribute;

    ///  <summary>Specifies whether the serialization engine stores all fields in separate XML elements.</summary>
    ///  <returns><c>True</c> if this option is set; <c>False</c> otherwise.</returns>
    ///  <remarks>For a value of <c>True</c>, the engine will store each field into a separate XML element. Setting this property
    ///  to <c>False</c> allows the serialization engine to store some fields as XML attributes on the parent class element.
    ///  This behaviour can be overridden by the use of <see cref="DeHL.Serialization.XML|XmlElement">DeHL.Serialization.XML.XmlElement</see>
    ///  and <see cref="DeHL.Serialization.XML|XmlAttribute">DeHL.Serialization.XML.XmlAttribute</see> attributes.</remarks>
    property DefaultFieldsToElements: Boolean read FDefaultToTags write FDefaultToTags;

    ///  <summary>Specifies the DeHL specific XML namespace.</summary>
    ///  <returns>DeHL specific namespace value.</returns>
    ///  <remarks>The value specified by this property is used for DeHL specific attributes, such as reference ID, type names and etc.
    ///  Setting this property to an empty string, forces the serializer not to use a specific namespace (but this practice is dangerous because
    ///  the attributes used by DeHL can conflict with field names).</remarks>
    property SerializerNamespace: string read FSerializerNS write FSerializerNS;

    ///  <summary>Specifies the global XSD attribute value.</summary>
    ///  <returns>The XSD attribute value. If an empty value is assigned, no XSD attribute is added to the root element.</returns>
    property XSD: String read FXSD write FXSD;

    ///  <summary>Specifies the global XSI attribute value.</summary>
    ///  <returns>The XSI attribute value. If an empty value is assigned, no XSI attribute is added to the root element.</returns>
    property XSI: String read FXSI write FXSI;
  end;

implementation
{ XmlName }

constructor XmlName.Create(const AName, ANamespace: String);
begin
  { Copy into }
  FName := AName;
  FNamespace := ANamespace;
end;

{ XmlArrayElement }

constructor XmlArrayElement.Create(const AName: String);
begin
  FName := AName;
end;

{ TXmlSerializer<T> }

procedure TXmlSerializer<T>.AfterConstruction;
begin
  inherited;

  FReferenceToAttribute := SReferenceToAttribute;
  FReferenceIdAttribute := SReferenceIdAttribute;
  FClassAttribute := SClassAttribute;
  FElementsAttribute := SElementsAttribute;
  FDefaultToTags := true;
  FXSI := SXSI;
  FXSD := SXSD;
  FSerializerNS := SSerializerNamespace;
end;

function TXmlSerializer<T>.CreateContext: TAbstractSerializationContext<TXmlSerializeData>;
begin
  Result := TXmlSerializationContext.Create(Self);
end;

procedure TXmlSerializer<T>.PrepareForDeserialization(const AMedium: IXMLNode);
begin
  if AMedium = nil then
    ExceptionHelper.Throw_ArgumentNilError('AMedium');

  { Clean-up }
  TXmlSerializationContext(Context).Reset;
  TXmlSerializationContext(Context).FCurrentNode := AMedium;
end;

procedure TXmlSerializer<T>.PrepareForSerialization(const AMedium: IXMLNode);
begin
  if AMedium = nil then
    ExceptionHelper.Throw_ArgumentNilError('AMedium');

  { Clean-up }
  TXmlSerializationContext(Context).Reset;
  TXmlSerializationContext(Context).FCurrentNode := AMedium;
end;

{ TXmlSerializer<T>.TXmlSerializationContext }

procedure TXmlSerializer<T>.TXmlSerializationContext.CloseComplexType;
begin
  FNS := CurrentCustomData.FNS;

  { Go to parent }
  FCurrentNode := FCurrentNode.ParentNode;
end;

constructor TXmlSerializer<T>.TXmlSerializationContext.Create(const ASerializer: TXmlSerializer<T>);
begin
  inherited Create();

  FNSSet := THashSet<String>.Create();
  FSerializer := ASerializer;
end;

function TXmlSerializer<T>.TXmlSerializationContext.CurrentName: string;
begin
  { Very simple }
  if CurrentType = ctArray then
  begin
    if CurrentCustomData.FElementName <> '' then
      Result := CurrentCustomData.FElementName
    else
      Result := FName;
  end else
    Result := FName;
end;

destructor TXmlSerializer<T>.TXmlSerializationContext.Destroy;
begin
  FNSSet.Free;

  inherited;
end;

function TXmlSerializer<T>.TXmlSerializationContext.GetNode(const AName,
  ANS: String; const AIndex: NativeUInt): IXMLNode;
var
  I, X: NativeInt;
  LNow: IXMLNode;
begin
  Result := nil;

  { for 0 index use standard lookup }
  if AIndex = 0 then
    Result := FCurrentNode.ChildNodes.FindNode(AName, ANS)
  else
  begin
    { start at zero }
    X := -1;

    for I := 0 to FCurrentNode.ChildNodes.Count - 1 do
    begin
      LNow :=  FCurrentNode.ChildNodes[I];

      if (LNow.NodeType = ntElement) and (LNow.LocalName = AName) then
      begin
        if (LNow.NamespaceURI = ANS) then
          Inc(X);
      end;

      { If found, do exit please }
      if X = NativeInt(AIndex) then
        Exit(LNow);
    end;
  end;

end;

function TXmlSerializer<T>.TXmlSerializationContext.InReadableForm: Boolean;
begin
  Result := True;
end;

procedure TXmlSerializer<T>.TXmlSerializationContext.MakeAttr(const ANode: IXMLNode; const AName, ANS, APrefix, AValue: String;
  out AStatus: TWriteStatus);
begin
  if ANode.HasAttribute(AName, ANS) then
  begin
    AStatus := wsIdentRedeclared;
    Exit;
  end;

  if ANS <> '' then
    RegisterNSAtTop(APrefix, ANS);

  try
    ANode.SetAttributeNS(AName, ANS, AValue);
  except
    AStatus := wsInvalidIdent;
    Exit;
  end;

  AStatus := wsSuccess;
end;

function TXmlSerializer<T>.TXmlSerializationContext.MakeNode(const ATag, ANS: String; out AStatus: TWriteStatus): IXMLNode;
begin
  { Default, failure }
  Result := nil;

  { Check for node's existance }
  if (CurrentType <> ctArray) and (FCurrentNode.ChildNodes.FindNode(ATag, ANS) <> nil) then
  begin
    AStatus := wsIdentRedeclared;
    Exit;
  end;

  { Register the namespace at top fi required so }
  try
    if ANS <> '' then
    begin
      RegisterNSAtTop('', ANS);
      Result := FCurrentNode.AddChild(ATag, ANS, false);
    end else
      Result := FCurrentNode.AddChild(ATag);
  except
    { Invalid identifier used }
    AStatus := wsInvalidIdent;
    Exit;
  end;

  { This is the first actual node, lest prefix it }
  if FTopNode = nil then
  begin
    FTopNode := Result;

    if FSerializer.FXSI <> '' then
      RegisterNSAtTop(SXSIAttr, FSerializer.FXSI);

    if FSerializer.FXSD <> '' then
      RegisterNSAtTop(SXSDAttr, FSerializer.FXSD);
  end;

  AStatus := wsSuccess;
end;

function TXmlSerializer<T>.TXmlSerializationContext.PrepareReadArray(out OReferenceId, OArrayLength: NativeUInt;
  out AIsReference: Boolean): TReadStatus;
var
  LClass: String;
  LSomeNode: IXMLNode;
begin
  { Store last used NS }
  CurrentCustomData := CurrentCustomData.ChangeNS(FNS);
  ProcessAttributes(true);

  { Find child }
  if CurrentType = ctArray then
    LSomeNode := GetNode(CurrentName, FNS, CurrentElementIndex)
  else
    LSomeNode := GetNode(CurrentName, FNS, 0);

  { Exit on bad result }
  if LSomeNode = nil then
  begin
    if FIsNullable then
    begin
      OReferenceId := 0;
      AIsReference := true;
      Result := rsSuccess;
    end else
      Result := rsUnexpected;

    Exit;
  end;

  { Check for reference }
  OReferenceId := StrToIntDef(ReadAttr(LSomeNode, FSerializer.FReferenceToAttribute,
      FSerializer.FSerializerNS, Result), 0);

  if Result = rsSuccess then
  begin
    AIsReference := true;
    Exit;
  end;

  { Not reference }
  AIsReference := false;

  { Switch nodes since we go deeper }
  FCurrentNode := LSomeNode;

  { Write the element count }
  OArrayLength := StrToIntDef(ReadAttr(FCurrentNode, FSerializer.FElementsAttribute,
      FSerializer.FSerializerNS, Result), 0);

  { Try to read the ref id }
  if Result = rsSuccess then
    OReferenceId := StrToIntDef(ReadAttr(FCurrentNode, FSerializer.FReferenceIdAttribute,
        FSerializer.FSerializerNS, Result), 0);

  Result := rsSuccess;
end;

function TXmlSerializer<T>.TXmlSerializationContext.PrepareReadClass(out OClass: TClass;
  out OReferenceId: NativeUInt; out AIsReference: Boolean): TReadStatus;
var
  LClass: String;
  LSomeNode: IXMLNode;
begin
  { Store last used NS }
  CurrentCustomData := CurrentCustomData.ChangeNS(FNS);
  ProcessAttributes(false);

  { Find child }
  if CurrentType = ctArray then
    LSomeNode := GetNode(CurrentName, FNS, CurrentElementIndex)
  else
    LSomeNode := GetNode(CurrentName, FNS, 0);

  { Exit on bad result }
  if LSomeNode = nil then
  begin
    if FIsNullable then
    begin
      OReferenceId := 0;
      AIsReference := true;
      Result := rsSuccess;
    end else
      Result := rsUnexpected;

    Exit;
  end;

  { Check for reference }
  OReferenceId := StrToIntDef(ReadAttr(LSomeNode, FSerializer.FReferenceToAttribute,
      FSerializer.FSerializerNS, Result), 0);

  if Result = rsSuccess then
  begin
    AIsReference := true;
    Exit;
  end;

  AIsReference := false;

  { Switch nodes since we go deeper }
  FCurrentNode := LSomeNode;

  { Continue on ... }

  LClass := ReadAttr(FCurrentNode, FSerializer.FClassAttribute,
      FSerializer.FSerializerNS, Result);

  if Result <> rsSuccess then
    Exit;

  OClass := GetClassByQualifiedName(LClass);

  { Try to read the ref id }
  OReferenceId := StrToIntDef(ReadAttr(FCurrentNode, FSerializer.FReferenceIdAttribute,
      FSerializer.FSerializerNS, Result), 0);
end;

function TXmlSerializer<T>.TXmlSerializationContext.PrepareReadRecord(out OReferenceId: NativeUInt;
  out AIsReference: Boolean): TReadStatus;
var
  LClass: String;
  LSomeNode: IXMLNode;
begin
  { Store last used NS }
  CurrentCustomData := CurrentCustomData.ChangeNS(FNS);
  ProcessAttributes(false);

  { Find child }
  if CurrentType = ctArray then
    LSomeNode := GetNode(CurrentName, FNS, CurrentElementIndex)
  else
    LSomeNode := GetNode(CurrentName, FNS, 0);

  { Exit on bad result }
  if LSomeNode = nil then
  begin
    if FIsNullable then
    begin
      OReferenceId := 0;
      AIsReference := true;
      Result := rsSuccess;
    end else
      Result := rsUnexpected;

    Exit;
  end;

  { Check for reference }
  OReferenceId := StrToIntDef(ReadAttr(LSomeNode, FSerializer.FReferenceToAttribute,
      FSerializer.FSerializerNS, Result), 0);

  if Result = rsSuccess then
  begin
    AIsReference := true;
    Exit;
  end;

  { Switch nodes since we go deeper }
  FCurrentNode := LSomeNode;

  AIsReference := false;

  { Try to read the ref id }
  OReferenceId := StrToIntDef(ReadAttr(FCurrentNode, FSerializer.FReferenceIdAttribute,
      FSerializer.FSerializerNS, Result), 0);

  Result := rsSuccess;
end;

procedure TXmlSerializer<T>.TXmlSerializationContext.PrepareReadValue;
begin
  inherited;

  ProcessAttributes(false);
end;

function TXmlSerializer<T>.TXmlSerializationContext.PrepareWriteArray(const AReferenceId, AElementCount: NativeUInt): TWriteStatus;
begin
  { Store last used NS }
  CurrentCustomData := CurrentCustomData.ChangeNS(FNS);
  ProcessAttributes(true);

  { Add child }
  FCurrentNode := MakeNode(CurrentName, FNS, Result);

  { Exit on bad result }
  if Result <> wsSuccess then
    Exit;

  { Write the element count }
  MakeAttr(FCurrentNode, FSerializer.FElementsAttribute,
      FSerializer.FSerializerNS, SSerializerNamespacePrefix, IntToStr(AElementCount), Result);

  { And reference ... if required }
  if (AReferenceId <> 0) and (Result = wsSuccess) then
    MakeAttr(FCurrentNode, FSerializer.FReferenceIdAttribute,
      FSerializer.FSerializerNS, SSerializerNamespacePrefix, IntToStr(AReferenceId), Result);
end;

function TXmlSerializer<T>.TXmlSerializationContext.PrepareWriteClass(const AClass: TClass; const AReferenceId: NativeUInt): TWriteStatus;
begin
  { Store last used NS }
  CurrentCustomData := CurrentCustomData.ChangeNS(FNS);
  ProcessAttributes(false);

  { Add child }
  FCurrentNode := MakeNode(CurrentName, FNS, Result);

  { Exit on bad result }
  if Result <> wsSuccess then
    Exit;

  MakeAttr(FCurrentNode, FSerializer.FClassAttribute,
      FSerializer.FSerializerNS, SSerializerNamespacePrefix, AClass.UnitName + '.' + AClass.ClassName, Result);

  if (AReferenceId <> 0) and (Result = wsSuccess) then
    MakeAttr(FCurrentNode, FSerializer.FReferenceIdAttribute,
      FSerializer.FSerializerNS, SSerializerNamespacePrefix, IntToStr(AReferenceId), Result);
end;

function TXmlSerializer<T>.TXmlSerializationContext.PrepareWriteRecord(const AReferenceId: NativeUInt): TWriteStatus;
begin
  { Store last used NS }
  CurrentCustomData := CurrentCustomData.ChangeNS(FNS);
  ProcessAttributes(false);

  { Add child }
  FCurrentNode := MakeNode(CurrentName, FNS, Result);

  { Exit on bad result }
  if Result <> wsSuccess then
    Exit;

  if AReferenceId <> 0 then
    MakeAttr(FCurrentNode, FSerializer.FReferenceIdAttribute,
      FSerializer.FSerializerNS, SSerializerNamespacePrefix, IntToStr(AReferenceId), Result);
end;

procedure TXmlSerializer<T>.TXmlSerializationContext.PrepareWriteValue;
begin
  inherited;

  ProcessAttributes(false);
end;

procedure TXmlSerializer<T>.TXmlSerializationContext.ProcessAttributes(const AIsArray: Boolean);
var
  LAttr: TCustomAttribute;
  I: NativeInt;
begin
  { Defaults }
  FNS := CurrentCustomData.FNS;
  FName := CurrentElementInfo.Name;

  { Remove all un-usual characters }
  for I := 1 to Length(FName) do
    if (FName[I] = '<') or (FName[I] = '>') or (FName[I] = ',') or (FName[I] = '{') or (FName[I] = '}') then
      FName[I] := '_';

  FIsNullable := false;
  FAsElement := FSerializer.FDefaultToTags;

  if AIsArray then
    CurrentCustomData := CurrentCustomData.ChangeElementName('');

  { Attribute reading }
  if CurrentElementInfo.&Object <> nil then
    for LAttr in CurrentElementInfo.&Object.GetAttributes() do
    begin
      if (LAttr is XmlArrayElement) and (XmlArrayElement(LAttr).FName <> '') then      { XmlArrayElement }
        CurrentCustomData := CurrentCustomData.ChangeElementName(XmlArrayElement(LAttr).FName)
      else if (LAttr is XmlName) then
      begin
        { XmlName }
        if XmlName(LAttr).FName <> '' then
          FName := XmlName(LAttr).FName;

        if XmlName(LAttr).FNamespace <> '' then
          FNS := XmlName(LAttr).FNamespace;
      end else if (LAttr is XmlElement) then      { XmlElement }
        FAsElement := true
      else if (LAttr is XmlAttribute) then      { XmlAttribute }
        FAsElement := false
      else if (LAttr is XmlNullable) then      { XmlNullable }
        FIsNullable := true;
    end;
end;

function TXmlSerializer<T>.TXmlSerializationContext.ReadAttr(const ANode: IXMLNode; const AName, ANS: String;
  out AStatus: TReadStatus): String;
begin
  Result := '';

  { Check if the attribute exists (with NS) }
  if ANode.HasAttribute(AName, ANS) then
  begin
    Result := ANode.GetAttributeNS(AName, ANS);
    AStatus := rsSuccess;
    Exit;
  end;

  { Check if the attribute exists with no NS }
  if ANode.HasAttribute(AName) then
  begin
    { If the node has the same NS as we would expect, then the attr has the same one }
    if ANode.NamespaceURI = ANS then
    begin
      Result := ANode.GetAttributeNS(AName, ANS);
      AStatus := rsSuccess;
    end else
      AStatus := rsUnexpected;

    Exit;
  end;

  { General failure. The NS is missing }
  AStatus := rsUnexpected;
end;

function TXmlSerializer<T>.TXmlSerializationContext.ReadValue(out AValue: UnicodeString): TReadStatus;
var
  LChild: IXMLNode;
begin
  { Add child }
  if FAsElement then
  begin
    { Find child }
    if CurrentType = ctArray then
      LChild := GetNode(CurrentName, FNS, CurrentElementIndex)
    else
      LChild := GetNode(CurrentName, FNS, 0);

    { Do the funky dance now }
    if LChild <> nil then
    begin
      Result := rsSuccess;

      try
        AValue := LChild.Text;
      except
        Result := rsReadError;
      end;
    end else
      Result := rsUnexpected;
  end else
    AValue := ReadAttr(FCurrentNode, CurrentName, FNS, Result);
end;

function TXmlSerializer<T>.TXmlSerializationContext.RegisterNSAtTop(const APrefix, AURI: String): Boolean;
var
  LPrefix: string;
begin
  Result := false;

  { Use the set to determine fast if we know the NS }
  if (FNSSet.Contains(AURI)) or (FTopNode = nil) then
    Exit(True);

  { The NS is already defined. Just skip }
  if FTopNode.FindNamespaceDecl(AURI) <> nil then
  begin
    FNSSet.Add(AURI);
    Exit(True);
  end;

  if APrefix = '' then
    LPrefix := FTopNode.OwnerDocument.GeneratePrefix(FTopNode)
  else
  begin
    { Make sure that the prefix is available (otherwise generate new) }
    if FTopNode.FindNamespaceURI(APrefix) <> '' then
      LPrefix := FTopNode.OwnerDocument.GeneratePrefix(FTopNode)
    else
      LPrefix := APrefix;
  end;

  FTopNode.DeclareNamespace(LPrefix, AURI);
  Result := true;
end;

procedure TXmlSerializer<T>.TXmlSerializationContext.Reset;
begin
  FTopNode := nil;
  FCurrentNode := nil;

  { State }
  FNSSet.Clear;
  FNS := '';
  FName := '';
end;

function TXmlSerializer<T>.TXmlSerializationContext.WriteReference(const AReferenceId: NativeUInt): TWriteStatus;
var
  LRefChild: IXMLNode;
begin
  { Process attributes }
  ProcessAttributes(false);

  if (AReferenceId = 0) and (FIsNullable) then
    Exit;

  { Add child }
  LRefChild := MakeNode(CurrentName, FNS, Result);

  if Result = wsSuccess then
    MakeAttr(LRefChild, FSerializer.FReferenceToAttribute,
      FSerializer.FSerializerNS, SSerializerNamespacePrefix, IntToStr(AReferenceId), Result);
end;

function TXmlSerializer<T>.TXmlSerializationContext.WriteValue(const AValue: UnicodeString): TWriteStatus;
var
  LChild: IXMLNode;
begin
  { Add child }
  if FAsElement then
  begin
    LChild := MakeNode(CurrentName, FNS, Result);

    if Result = wsSuccess then
    try
      LChild.SetText(AValue);
    except
      Result := wsWriteError;
    end;
  end else
    MakeAttr(FCurrentNode, CurrentName, FNS, '', AValue, Result);
end;

{ TXmlSerializeData }

function TXmlSerializeData.ChangeElementName(const AString: String): TXmlSerializeData;
begin
  Result.FElementName := AString;
  Result.FNS := FNS;
end;

function TXmlSerializeData.ChangeNS(const AString: String): TXmlSerializeData;
begin
  Result.FElementName := FElementName;
  Result.FNS := AString;
end;

end.
