(*
* Copyright (c) 2009-2010, Ciobanu Alexandru
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
unit DeHL.Nullable;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.StrConsts,
     DeHL.Exceptions,
     DeHL.Serialization,
     DeHL.Types;

type
  ///  <summary>A nullable generic type.</summary>
  ///  <remarks>A nullable can either hold a value of a given type or can be empty. Most operations on
  ///  empty nullables result in exceptions.</remarks>
  Nullable<T> = record
{$HINTS OFF}
  private
    class var __Marker: IInterface;

    class constructor Create();
    class destructor Destroy();
{$HINTS ON}

  private
    FMarker: IInterface;
    FValue: T;

    function GetIsNull: Boolean; inline;
    function GetValue: T; inline;
    procedure SetValue(const Value: T); inline;
    function GetValueOrDefault: T; inline;
  public
    ///  <summary>Initializes a nullable value.</summary>
    ///  <param name="AValue">The value to be placed in the nullable.</param>
    constructor Create(const AValue: T);

    ///  <summary>Specifies whether this nullable is empty.</summary>
    ///  <returns><c>True</c> if the nullable is empty; <c>False</c> if the nullable has a value.</returns>
    property IsNull: Boolean read GetIsNull;

    ///  <summary>Sets or gets the nullable's value.</summary>
    ///  <returns>The enclosed value.</returns>
    ///  <exception cref="DeHL.Exceptions|ENullValueException">The reading of an empty nullable.</exception>
    property Value: T read GetValue write SetValue;

    ///  <summary>Gets the nullable's value.</summary>
    ///  <returns>The enclosed value. If the nullable is empty, the default for the type is returned.</returns>
    property ValueOrDefault: T read GetValueOrDefault;

    ///  <summary>Drops the enclosed value making the nullable empty.</summary>
    procedure MakeNull(); inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AValue">The nullable to convert.</param>
    ///  <returns>The enclosed value.</returns>
    ///  <exception cref="DeHL.Exceptions|ENullValueException">The nullable is empty.</exception>
    class operator Implicit(const AValue: Nullable<T>): T; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AValue">The value to put into a nullable.</param>
    ///  <returns>The nullable value.</returns>
    class operator Implicit(const AValue: T): Nullable<T>; inline;
  end;

  ///  <summary>Type class used to describe <see cref="DeHL.Nullable|Nullable&lt;T&gt;">DeHL.Nullable.Nullable&lt;T&gt;</see>
  ///  values.</summary>
  TNullableType<T> = class(TMagicType<Nullable<T>>)
  private
    FType: IType<T>;

  protected
    ///  <summary>Serializes a nullable.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing
    ///  the field/element being serialized.</param>
    ///  <param name="AValue">The nullable being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <remarks>This method uses the type object describing the enclosed type. All calls are routed
    ///  to that type object.</remarks>
    ///  <exception><exception cref="DeHL.Exceptions|ESerializationException"/>Various serialization reasons.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Nullable<T>; const AContext: ISerializationContext); override;

    ///  <summary>Deserializes a nullable.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing
    ///  the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized nullable.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <remarks>This method uses the type object describing the enclosed type. All calls are routed
    ///  to that type object.</remarks>
    ///  <exception><exception cref="DeHL.Exceptions|ESerializationException"/>Various deserialization reasons.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Nullable<T>; const AContext: IDeserializationContext); override;

  public
    ///  <summary>Instantiates a <see cref="DeHL.Nullable|TNullableType&lt;T&gt;">DeHL.Nullable.TNullableType&lt;T&gt;</see>
    ///  object.</summary>
    constructor Create(); overload; override;

    ///  <summary>Instantiates a <see cref="DeHL.Nullable|TNullableType&lt;T&gt;">DeHL.Nullable.TNullableType&lt;T&gt;</see>
    ///  object.</summary>
    ///  <param name="AType">An instance of a type class describing the type sored in the nullable.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); reintroduce; overload;

    ///  <summary>Compares two nullables.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - AValue1 is less than AValue2. If the result is zero -
    ///  AValue1 is equal to AValue2. And finally, if the result is greater than zero - AValue1 is greater than AValue2.</returns>
    ///  <remarks>This method uses the type object decribing the enclosed type. All calls are routed
    ///  to that type object. If the nullables are empty, the default value for that type are used.</remarks>
    function Compare(const AValue1, AValue2: Nullable<T>): NativeInt; override;

    ///  <summary>Generates a hash code for a nullable.</summary>
    ///  <remarks>This method uses the type object decribing the enclosed type. All calls are routed
    ///  to that type object. If the nullables are empty, the default value for that type are used.</remarks>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: Nullable<T>): NativeInt; override;

    ///  <summary>The life-time management employed by nullable values.</summary>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    ///  <remarks>A nullable is merely a container. The life-time management of the nullable is decided by the
    ///  type of the values it operates upon. For example, for a <c>Nullable&lt;string&gt;</c>, this method returns
    ///  <c>tmCompiler</c>, because <c>string</c> is compiler managed..</remarks>
    function Management(): TTypeManagement; override;

    ///  <summary>Performs cleanup of a nullable.</summary>
    ///  <remarks>This method uses the type object decribing the enclosed type. All calls are routed
    ///  to that type object. If the nullables are empty, the default value for that type are used.</remarks>
    ///  <param name="AValue">The value to cleanup.</param>
    procedure Cleanup(var AValue: Nullable<T>); override;

    ///  <summary>Returns the string representation of the nullable.</summary>
    ///  <remarks>This method uses the type object decribing the enclosed type. All calls are routed
    ///  to that type object. If the nullables are empty, the default value for that type are used.</remarks>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>A string value describing the value.</returns>
    function GetString(const AValue: Nullable<T>): String; override;

    ///  <summary>Tries to convert the nullable to a <c>Variant</c>.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <param name="ORes">The <c>Variant</c> value.</param>
    ///  <remarks>This method uses the type object decribing the enclosed type. All calls are routed
    ///  to that type object. If the nullables are empty, the default value for that type are used.</remarks>
    ///  <returns><c>True</c> if the conversion succeded; <c>False</c> otherwise.</returns>
    function TryConvertToVariant(const AValue: Nullable<T>; out ORes: Variant): Boolean; override;

    ///  <summary>Tries to convert a <c>Variant</c> to a nullable.</summary>
    ///  <param name="AValue">The <c>Variant</c> to convert.</param>
    ///  <param name="ORes">The fixed array.</param>
    ///  <remarks>This method uses the type object decribing the enclosed type. All calls are routed
    ///  to that type object. If the nullables are empty, the default value for that type are used.</remarks>
    ///  <returns><c>True</c> if the conversion succeded; <c>False</c> otherwise.</returns>
    function TryConvertFromVariant(const AValue: Variant; out ORes: Nullable<T>): Boolean; override;
  end;

implementation

{ Nullable<T> }

constructor Nullable<T>.Create(const AValue: T);
begin
  SetValue(AValue);
end;

class constructor Nullable<T>.Create;
begin
  __Marker := TInterfacedObject.Create();

  { Register custom type }
  if not TType<Nullable<T>>.IsRegistered then
    TType<Nullable<T>>.Register(TNullableType<T>);
end;

class destructor Nullable<T>.Destroy;
begin
  __Marker := nil;

  { Unregister the custom type }
  if not TType<Nullable<T>>.IsRegistered then
    TType<Nullable<T>>.Unregister();
end;

function Nullable<T>.GetIsNull: Boolean;
begin
  Result := (FMarker = nil);
end;

function Nullable<T>.GetValue: T;
begin
  if FMarker = nil then
    ExceptionHelper.Throw_NullValueRequested();

  Result := FValue;
end;

function Nullable<T>.GetValueOrDefault: T;
begin
  { So simple }
  if FMarker = nil then
    Result := default(T)
  else
    Result := FValue;
end;

class operator Nullable<T>.Implicit(const AValue: T): Nullable<T>;
begin
  { Initialize a value }
  Result := Nullable<T>.Create(AValue);
end;

class operator Nullable<T>.Implicit(const AValue: Nullable<T>): T;
begin
  Result := AValue.GetValue();
end;

procedure Nullable<T>.MakeNull;
begin
  { Kill value }
  FValue := Default(T);
  FMarker := nil;
end;

procedure Nullable<T>.SetValue(const Value: T);
begin
  FMarker := __Marker;
  FValue := Value;
end;

{ TNullableType<T> }

procedure TNullableType<T>.Cleanup(var AValue: Nullable<T>);
begin
  { Use the enclosed type }
  if not AValue.IsNull then
    FType.Cleanup(AValue.FValue);
end;

function TNullableType<T>.Compare(const AValue1, AValue2: Nullable<T>): NativeInt;
begin
  { Use the enclosed type }
  Result := FType.Compare(AValue1.ValueOrDefault, AValue2.ValueOrDefault);
end;

constructor TNullableType<T>.Create(const AType: IType<T>);
begin
  inherited Create();

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  FType := AType;
end;

constructor TNullableType<T>.Create;
begin
  inherited;

  { Obtain the type }
  FType := TType<T>.Default;
end;

function TNullableType<T>.GenerateHashCode(const AValue: Nullable<T>): NativeInt;
begin
  { Use the enclosed type }
  Result := FType.GenerateHashCode(AValue.ValueOrDefault);
end;

function TNullableType<T>.GetString(const AValue: Nullable<T>): String;
begin
  { Use the enclosed type }
  Result := FType.GetString(AValue.ValueOrDefault);
end;

function TNullableType<T>.Management: TTypeManagement;
begin
  Result := FType.Management;
end;

function TNullableType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: Nullable<T>): Boolean;
var
  LV: T;
begin
  { Use the enclosed type }
  Result := FType.TryConvertFromVariant(AValue, LV);

  if Result then
    ORes.Value := LV;
end;

function TNullableType<T>.TryConvertToVariant(const AValue: Nullable<T>; out ORes: Variant): Boolean;
begin
  { Use the enclosed type }
  Result := FType.TryConvertToVariant(AValue.ValueOrDefault, ORes);
end;

procedure TNullableType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: Nullable<T>; const AContext: IDeserializationContext);
var
  LIsDefined: Boolean;
begin
  { Pass over }
  AContext.ExpectRecordType(AInfo);

  { Get contents }
  AContext.GetValue(TValueInfo.Create(SIsDefined), LIsDefined);
  FType.Deserialize(TValueInfo.Create(SSerValue), AValue.FValue, AContext);

  if LIsDefined then
    AValue.FMarker := __Marker;

  AContext.EndComplexType();
end;

procedure TNullableType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: Nullable<T>; const AContext: ISerializationContext);
begin
  { Pass over }
  AContext.StartRecordType(AInfo);

  AContext.AddValue(TValueInfo.Create(SIsDefined), not AValue.IsNull);
  FType.Serialize(TValueInfo.Create(SSerValue), AValue.ValueOrDefault, AContext);

  AContext.EndComplexType();
end;

end.
