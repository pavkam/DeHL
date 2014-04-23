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
unit DeHL.Serialization;
interface
uses
  DeHL.Base,
  DeHL.Exceptions,
  TypInfo,
  SysUtils,
  Rtti;

type
  ///  <summary>Describes a type, field, array element or a logical value in a serialization context.</summary>
  ///  <remarks><see cref="DeHL.Serialization|TValueInfo"/> is used in the serialization context to uniquely
  ///  identify a "serialization unit".</remarks>
  TValueInfo = record
  private
    FObject: TRttiNamedObject;
    FLabel: String;

  public
    ///  <summary>Constructs a <see cref="DeHL.Serialization|TValueInfo"/> value.</summary>
    ///  <param name="AType">The RTTI object that identifies the type being serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: TRttiType); overload;

    ///  <summary>Constructs a <see cref="DeHL.Serialization|TValueInfo"/> value.</summary>
    ///  <param name="AField">The RTTI object that identifies the field being serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AField"/> is <c>nil</c>.</exception>
    constructor Create(const AField: TRttiField); overload;

    ///  <summary>Constructs a <see cref="DeHL.Serialization|TValueInfo"/> value.</summary>
    ///  <param name="AField">The RTTI object that identifies the type being serialized.</param>
    ///  <param name="ALabel">The name that will be used for serializing the field.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AField"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    constructor Create(const AField: TRttiField; const ALabel: string); overload;

    ///  <summary>Constructs a <see cref="DeHL.Serialization|TValueInfo"/> value.</summary>
    ///  <param name="ALabel">The name of the logical entity.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    constructor Create(const ALabel: string); overload;

    ///  <summary>Constructs a <see cref="DeHL.Serialization|TValueInfo"/> value.</summary>
    ///  <remarks>This method constructs a <see cref="DeHL.Serialization|TValueInfo"/> value that describes an array element.</remarks>
    ///  <returns>A <see cref="DeHL.Serialization|TValueInfo"/> value.</returns>
    class function Indexed(): TValueInfo; static; inline;

    ///  <summary>Specifies the RTTI object described by this <see cref="DeHL.Serialization|TValueInfo"/> value.</summary>
    ///  <remarks>This property can be <c>nil</c> if the <see cref="DeHL.Serialization|TValueInfo"/> value describes an array element
    ///  or a logical value.</remarks>
    ///  <returns>An RTTI object.</returns>
    property &Object: TRttiNamedObject read FObject;

    ///  <summary>Specifies the name of the described entity.</summary>
    ///  <remarks>This property cannot be an empty string if the described entity is a field, type, or logical entity.</remarks>
    ///  <returns>The name of the entity.</returns>
    property Name: string read FLabel;
  end;

  ///  <summary>Base serialization interface.</summary>
  ///  <remarks>This interface has no direct use. It is used simply to unify both the serialization and
  ///  deserialization interfaces into a single root.</remarks>
  IContext = interface
    ///  <summary>Returns an RTTI object for the given type information.</summary>
    ///  <param name="ATypeInfo">The type information for the type.</param>
    ///  <returns>An RTTI object describing the type.</returns>
    ///  <remarks>This method is invoked in the serialization process to obtain RTTI
    ///  objects for the given type information. Implementers should employ caching techiques to speed up
    ///  this process.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ATypeInfo"/> is <c>nil</c>.</exception>
    function GetTypeInformation(const ATypeInfo: PTypeInfo): TRttiType;

    ///  <summary>Creates a type object and caches it.</summary>
    ///  <param name="ATypeInfo">The type information for the type.</param>
    ///  <param name="ADelegate">The callback that is called when the serializer does not posses
    ///  a type object for the type.</param>
    ///  <returns>A <see cref="DeHL.Types|TType&lt;T&gt;"/> object describing the type.</returns>
    ///  <remarks>This method is a bit tricky. It was introduced to minimize the number of type objects
    ///  created during the serialization process. This method checks whether there already exists a type object
    ///  created for the given type information (and returned); otherwise, ADelegate is called to obtain a new
    ///  type object which is cached internally and then returned to the caller.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ATypeInfo"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ADelegate"/> is <c>nil</c>.</exception>
    function GetTypeObject(const ATypeInfo: PTypeInfo; const ADelegate: TFunc<TObject>): TObject;

    ///  <summary>Specifies whether the serialization ouput is human readable.</summary>
    ///  <remarks>User serialization code can check this property to verify whether the
    ///  output of the serialization process is human readable or not. Based on this knowledge
    ///  a custom type may serialize itself as a string or binary data for example.</remarks>
    ///  <returns><c>True</c> if the output is human readable; <c>False</c> otherwise.</returns>
    function InReadableForm: Boolean;
  end;

  ///  <summary>Serialization context interface. Defines a number of common methods all serializers need to support.</summary>
  ///  <remarks>All user serialization code in the end receives <see cref="DeHL.Serialization|ISerializationContext"/> interface.
  ///  This interface offers basic methods to serialize any type to any output.</remarks>
  ISerializationContext = interface(IContext)
    ///  <summary>Serializes a <c>Byte</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Byte); overload;

    ///  <summary>Serializes a <c>ShortInt</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: ShortInt); overload;

    ///  <summary>Serializes a <c>Word</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Word); overload;

    ///  <summary>Serializes a <c>SmallInt</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: SmallInt); overload;

    ///  <summary>Serializes a <c>Cardinal</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Cardinal); overload;

    ///  <summary>Serializes a <c>Integer</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Integer); overload;

    ///  <summary>Serializes a <c>UInt64</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: UInt64); overload;

    ///  <summary>Serializes a <c>Int64</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Int64); overload;

    ///  <summary>Serializes a <c>Single</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Single); overload;

    ///  <summary>Serializes a <c>Double</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Double); overload;

    ///  <summary>Serializes a <c>Extended</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Extended); overload;

    ///  <summary>Serializes a <c>Currency</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Currency); overload;

    ///  <summary>Serializes a <c>Comp</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Comp); overload;

    ///  <summary>Serializes a <c>AnsiChar</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: AnsiChar); overload;

    ///  <summary>Serializes a <c>WideChar</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: WideChar); overload;

    ///  <summary>Serializes a <c>AnsiString</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: AnsiString); overload;

    ///  <summary>Serializes a <c>UnicodeString</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: UnicodeString); overload;

    ///  <summary>Serializes a <c>Boolean</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: Boolean); overload;

    ///  <summary>Serializes a <c>TDateTime</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: TDateTime); overload;

    ///  <summary>Serializes a <c>TClass</c> value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    procedure AddValue(const AInfo: TValueInfo; const AValue: TClass); overload;

    ///  <summary>Serializes a binary value.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="ASize">The size in bytes of the binary value.</param>
    procedure AddBinaryValue(const AInfo: TValueInfo; const AValue; const ASize: NativeUInt); overload;

    ///  <summary>Notifies the context that a record is being serialized.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the record.</param>
    procedure StartRecordType(const AInfo: TValueInfo); overload;

    ///  <summary>Notifies the context that a record is being serialized.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block. If the record
    ///  being serialized was already serialized, this function should insert a special marker and return False.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the record.</param>
    ///  <param name="AReference">A pointer to the contents of the record. Can be a nil value.</param>
    ///  <returns>True if the record was not already serialized and the user code may proceed further and serialize
    ///  record's contents. False is returned if the passed reference is nil or it the record at that address was already serialized.</returns>
    function StartRecordType(const AInfo: TValueInfo; const AReference: Pointer): Boolean; overload;

    ///  <summary>Notifies the context that a class is being serialized.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block. If the class
    ///  being serialized was already serialized, this function should insert a special marker and return False.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the class.</param>
    ///  <param name="AReference">The object being serialized. Can be a <c>nil</c> value.</param>
    ///  <param name="AClass">The real class of the object.</param>
    ///  <returns>True if the object was not already serialized and the user code may proceed further
    ///  and serialize object's contents. False is returned if the passed reference is nil or it the object at that address
    ///  was already serialized.</returns>
    function StartClassType(const AInfo: TValueInfo; const AClass: TClass; const AReference: TObject): Boolean; overload;

    ///  <summary>Notifies the context that a static array is being serialized.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the array.</param>
    ///  <param name="AElementInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the elements of the array.</param>
    ///  <param name="AElementCount">The number of elements in the array.</param>
    procedure StartArrayType(const AInfo, AElementInfo: TValueInfo; const AElementCount: NativeUInt); overload;

    ///  <summary>Notifies the context that a dynamic array is being serialized.</summary>
    ///  <remarks>Depending on the serializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller need to surround the calls to this method into a try ... except block. If the array
    ///  being serialized was already serialized, this function should insert a special marker and return False.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the array.</param>
    ///  <param name="AElementInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the elements of the array.</param>
    ///  <param name="AReference">The dynamic array being serialized. Can be a nil value.</param>
    ///  <param name="AElementCount">The number of elements in the array.</param>
    ///  <returns>True if the array was not already serialized and the user code may proceed further
    ///  and serialize arrays's contents. False is returned if the passed reference is nil or it the array at that address
    ///  was already serialized.</returns>
    function StartArrayType(const AInfo, AElementInfo: TValueInfo; const AElementCount: NativeUInt; const AReference: Pointer): Boolean; overload;

    ///  <summary>Notifies the context that the serialization of a complex type has ended.</summary>
    ///  <remarks>Each serializer providing the context, can react differently if this method is incorrectly called
    ///  (if there wasn't complex type being serialized).</remarks>
    procedure EndComplexType();
  end;

  ///  <summary>A procedural type that defines user routines involved in binary values deserialization.</summary>
  ///  <param name="ASize">The size in bytes of the memory required by the serializer.</param>
  ///  <returns>A pointer to the memory location where the serializer must store the read data. A <c>nil</c> value
  ///  means that the user code decided that something is wrong.</returns>
  TGetBinaryMethod = reference to function(const ASize: NativeUInt): Pointer;

  ///  <summary>Deserialization context interface. Defines a number of common methods all serializers need to support.</summary>
  ///  <remarks>All user deserialization code in the end receives <see cref="DeHL.Serialization|IDeserializationContext"/> interface.
  ///  This interface offers basic methods to deserialize any type from any output.</remarks>
  IDeserializationContext = interface(IContext)
    ///  <summary>Deserializes a <c>Byte</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Byte); overload;

    ///  <summary>Deserializes a <c>ShortInt</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: ShortInt); overload;

    ///  <summary>Deserializes a <c>Word</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Word); overload;

    ///  <summary>Deserializes a <c>SmallInt</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: SmallInt); overload;

    ///  <summary>Deserializes a <c>Cardinal</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Cardinal); overload;

    ///  <summary>Deserializes a <c>Integer</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Integer); overload;

    ///  <summary>Deserializes a <c>UInt64</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: UInt64); overload;

    ///  <summary>Deserializes a <c>Int64</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Int64); overload;

    ///  <summary>Deserializes a <c>Single</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Single); overload;

    ///  <summary>Deserializes a <c>Double</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Double); overload;

    ///  <summary>Deserializes a <c>Extended</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Extended); overload;

    ///  <summary>Deserializes a <c>Currency</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Currency); overload;

    ///  <summary>Deserializes a <c>Comp</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Comp); overload;

    ///  <summary>Deserializes a <c>AnsiChar</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: AnsiChar); overload;

    ///  <summary>Deserializes a <c>WideChar</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: WideChar); overload;

    ///  <summary>Deserializes a <c>AnsiString</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: AnsiString); overload;

    ///  <summary>Deserializes a <c>UnicodeString</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: UnicodeString); overload;

    ///  <summary>Deserializes a <c>Boolean</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: Boolean); overload;

    ///  <summary>Deserializes a <c>TDateTime</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: TDateTime); overload;

    ///  <summary>Deserializes a <c>TClass</c> value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="AValue">The value being deserialized.</param>
    procedure GetValue(const AInfo: TValueInfo; out AValue: TClass); overload;

    ///  <summary>Deserializes a binary value.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the entity being deserialized.</param>
    ///  <param name="ASupplier">The memory supplier method. This is user provided method that decides where to store the binary data.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASupplier"/> is <c>nil</c>.</exception>
    procedure GetBinaryValue(const AInfo: TValueInfo; const ASupplier: TGetBinaryMethod); overload;

    ///  <summary>Notifies the context that a record needs to be deserialized.</summary>
    ///  <remarks>Depending on the deserializer providing this context there are quite a few possible outcomes of
    ///  this method. The caller needs to surround the calls to this method into a try ... except block.</remarks>
    ///  <param name="AInfo">The <see cref="DeHL.Serialization|TValueInfo"/> value describing the record.</param>
    procedure ExpectRecordType(const AInfo: TValueInfo); overload;

    //TODO: doc me
    function ExpectRecordType(const AInfo: TValueInfo; out AReference: Pointer): Boolean; overload;
    //TODO: doc me
    function ExpectClassType(const AInfo: TValueInfo; var AClass: TClass; out AReference: TObject): Boolean; overload;
    //TODO: doc me
    procedure ExpectArrayType(const AInfo, AElementInfo: TValueInfo; out OArrayLength: NativeUInt); overload;
    //TODO: doc me
    function ExpectArrayType(const AInfo, AElementInfo: TValueInfo; out OArrayLength: NativeUInt; out AReference: Pointer): Boolean; overload;
    //TODO: doc me
    procedure RegisterReference(const AReference: Pointer); overload;
    //TODO: doc me
    procedure EndComplexType(); overload;
  end;

  ///  <summary>Combines the most useful serialization functionality in one single type.</summary>
  ///  <remarks>This type simplifies the serialization process and allows for more readable user code.</remarks>
  TSerializationData = record
  private
    FInContext: ISerializationContext;
    FMicroStack: TArray<TValueInfo>;
    FStackPtr: NativeUInt;
    FElementInfo: TValueInfo;

    procedure MicroPush(const AInfo: TValueInfo);
     function MicroPop(): TValueInfo;
    function GetInReadableForm: Boolean;
  public
    ///  <summary>Initializes a value of this type.</summary>
    ///  <param name="AContext">The serialization context used by this value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AContext"/> is <c>nil</c>.</exception>
    constructor Create(const AContext: ISerializationContext);

    ///  <summary>Serializes a <c>Byte</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Byte); overload;

    ///  <summary>Serializes a <c>ShortInt</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: ShortInt); overload;

    ///  <summary>Serializes a <c>Word</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Word); overload;

    ///  <summary>Serializes a <c>SmallInt</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: SmallInt); overload;

    ///  <summary>Serializes a <c>Cardinal</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Cardinal); overload;

    ///  <summary>Serializes a <c>Integer</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Integer); overload;

    ///  <summary>Serializes a <c>UInt64</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: UInt64); overload;

    ///  <summary>Serializes a <c>Int64</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Int64); overload;

    ///  <summary>Serializes a <c>Single</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Single); overload;

    ///  <summary>Serializes a <c>Double</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Double); overload;

    ///  <summary>Serializes a <c>Extended</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Extended); overload;

    ///  <summary>Serializes a <c>Currency</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Currency); overload;

    ///  <summary>Serializes a <c>Comp</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Comp); overload;

    ///  <summary>Serializes a <c>AnsiChar</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: AnsiChar); overload;

    ///  <summary>Serializes a <c>WideChar</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: WideChar); overload;

    ///  <summary>Serializes a <c>AnsiString</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: AnsiString); overload;

    ///  <summary>Serializes a <c>UnicodeString</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: UnicodeString); overload;

    ///  <summary>Serializes a <c>Boolean</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: Boolean); overload;

    ///  <summary>Serializes a <c>TDateTime</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue: TDateTime); overload;

    ///  <summary>Serializes a binary value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <param name="ASize">The size of the serialized value (in bytes).</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue(const ALabel: String; const AValue; const ASize: NativeUInt); overload;

    ///  <summary>Serializes a generic value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The serialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure AddValue<T>(const ALabel: String; const AValue: T); overload;

    ///  <summary>Serializes a <c>Byte</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Byte); overload;

    ///  <summary>Serializes a <c>ShortInt</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: ShortInt); overload;

    ///  <summary>Serializes a <c>Word</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Word); overload;

    ///  <summary>Serializes a <c>SmallInt</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: SmallInt); overload;

    ///  <summary>Serializes a <c>Cardinal</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Cardinal); overload;

    ///  <summary>Serializes a <c>Integer</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Integer); overload;

    ///  <summary>Serializes a <c>UInt64</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: UInt64); overload;

    ///  <summary>Serializes a <c>Int64</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Int64); overload;

    ///  <summary>Serializes a <c>Single</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Single); overload;

    ///  <summary>Serializes a <c>Double</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Double); overload;

    ///  <summary>Serializes a <c>Extended</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Extended); overload;

    ///  <summary>Serializes a <c>Currency</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Currency); overload;

    ///  <summary>Serializes a <c>Comp</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Comp); overload;

    ///  <summary>Serializes a <c>AnsiChar</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: AnsiChar); overload;

    ///  <summary>Serializes a <c>WideChar</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: WideChar); overload;

    ///  <summary>Serializes a <c>AnsiString</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: AnsiString); overload;

    ///  <summary>Serializes a <c>UnicodeString</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: UnicodeString); overload;

    ///  <summary>Serializes a <c>Boolean</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: Boolean); overload;

    ///  <summary>Serializes a <c>TDateTime</c> array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue: TDateTime); overload;

    ///  <summary>Serializes a binary array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <param name="ASize">The size of the serialized element (in bytes).</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement(const AValue; const ASize: NativeUInt); overload;

    ///  <summary>Serializes a generic array/list element.</summary>
    ///  <param name="AValue">The serialized element.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure AddElement<T>(const AIndex: NativeUInt; const AValue: T); overload;

    ///  <summary>Instructs the serializer that a block (record) is about to be serialized.</summary>
    ///  <param name="ALabel">The label of the block.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure StartBlock(const ALabel: String); overload;

    ///  <summary>Instructs the serializer that a block (record) is about to be serialized.</summary>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure StartBlock(); overload;

    ///  <summary>Instructs the serializer that a list is about to be serialized.</summary>
    ///  <param name="ALabel">The label of the list.</param>
    ///  <param name="AElementLabel">The label of the elements in the list.</param>
    ///  <param name="AElementCount">The number of elements that are going to be serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AElementLabel"/> is <c>empty</c>.</exception>
    procedure StartListBlock(const ALabel, AElementLabel: String; const AElementCount: NativeUInt); overload;

    ///  <summary>Instructs the serializer that a list is about to be serialized.</summary>
    ///  <param name="ALabel">The label of the list.</param>
    ///  <param name="AElementType">The type of elements in the list.</param>
    ///  <param name="AElementCount">The number of elements that are going to be serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AElementType"/> is <c>nil</c>.</exception>
    procedure StartListBlock(const ALabel: String; const AElementType: PTypeInfo; const AElementCount: NativeUInt); overload;

    ///  <summary>Instructs the serializer that a list is about to be serialized.</summary>
    ///  <param name="AElementLabel">The label of the elements in the list.</param>
    ///  <param name="AElementCount">The number of elements that are going to be serialized.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AElementType"/> is <c>nil</c>.</exception>
    procedure StartListBlock(const AElementLabel: String; const AElementCount: NativeUInt); overload;

    ///  <summary>Instructs the serializer that a list is about to be serialized.</summary>
    ///  <param name="AElementType">The type of elements in the list.</param>
    ///  <param name="AElementCount">The number of elements that are going to be serialized.</param>
    ///  <remarks>This method presumes that a list block was started prior. Otherwise the behaviour is undefined.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AElementType"/> is <c>nil</c>.</exception>
    procedure StartListBlock(const AElementType: PTypeInfo; const AElementCount: NativeUInt); overload;

    ///  <summary>Instructs the serializer that a block (or a list) was completely deserialized.</summary>
    ///  <remarks>This method presumes that a list or block was started prior. Otherwise the behaviour is undefined.</remarks>
    procedure EndBlock();

    ///  <summary>Specifies the serialization context that was assigned to this value.</summary>
    ///  <returns>The serialization context.</returns>
    property Context: ISerializationContext read FInContext;

    ///  <summary>Specifies whether the serialization output is human readable.</summary>
    ///  <remarks>User serialization code can check this property to verify whether the
    ///  output of the serialization process is human readable or not. Based on this knowledge
    ///  a custom type may serialize itself as a string or binary data for example.</remarks>
    ///  <returns><c>True</c> if the output is human readable; <c>False</c> otherwise.</returns>
    property InReadableForm: Boolean read GetInReadableForm;

    ///  <summary>Specifies the current element information block.</summary>
    ///  <returns>The element information block.</returns>
    ///  <remarks>This method should not be used directly. It is reserved for internal purpuses only.</remarks>
    property CurrentElementInfo: TValueInfo read FElementInfo;
  end;

  ///  <summary>Combines the most useful deserialization functionality in one single type.</summary>
  ///  <remarks>This type simplifies the deserialization process and allows for more readable user code.</remarks>
  TDeserializationData = record
  private
    FOutContext: IDeserializationContext;
    FMicroStack: TArray<TValueInfo>;
    FStackPtr: NativeUInt;
    FElementInfo: TValueInfo;

    procedure MicroPush(const AInfo: TValueInfo);
     function MicroPop(): TValueInfo;
    function GetInReadableForm: Boolean;
  public
    ///  <summary>Initializes a value of this type.</summary>
    ///  <param name="AContext">The deserialization context used by this value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AContext"/> is <c>nil</c>.</exception>
    constructor Create(const AContext: IDeserializationContext);

    ///  <summary>Deserializes a <c>Byte</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Byte); overload;

    ///  <summary>Deserializes a <c>ShortInt</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: ShortInt); overload;

    ///  <summary>Deserializes a <c>Word</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Word); overload;

    ///  <summary>Deserializes a <c>SmallInt</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: SmallInt); overload;

    ///  <summary>Deserializes a <c>Cardinal</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Cardinal); overload;

    ///  <summary>Deserializes a <c>Integer</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Integer); overload;

    ///  <summary>Deserializes a <c>UInt64</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: UInt64); overload;

    ///  <summary>Deserializes a <c>Int64</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Int64); overload;

    ///  <summary>Deserializes a <c>Single</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Single); overload;

    ///  <summary>Deserializes a <c>Double</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Double); overload;

    ///  <summary>Deserializes a <c>Extended</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Extended); overload;

    ///  <summary>Deserializes a <c>Currency</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Currency); overload;

    ///  <summary>Deserializes a <c>Comp</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Comp); overload;

    ///  <summary>Deserializes a <c>AnsiChar</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: AnsiChar); overload;

    ///  <summary>Deserializes a <c>WideChar</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: WideChar); overload;

    ///  <summary>Deserializes a <c>AnsiString</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: AnsiString); overload;

    ///  <summary>Deserializes a <c>UnicodeString</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: UnicodeString); overload;

    ///  <summary>Deserializes a <c>Boolean</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: Boolean); overload;

    ///  <summary>Deserializes a <c>TDateTime</c> value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue: TDateTime); overload;

    ///  <summary>Deserializes a binary value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="ASize">The size of the expected binary value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue(const ALabel: String; out AValue; const ASize: NativeUInt); overload;

    ///  <summary>Deserializes a generic value with a given label.</summary>
    ///  <param name="ALabel">The label associated with the value.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ALabel"/> is <c>empty</c>.</exception>
    procedure GetValue<T>(const ALabel: String; out AValue: T); overload;

    { Reads elements from the context }
    //TODO: doc me
    procedure GetElement(out AValue: Byte); overload;
    //TODO: doc me
    procedure GetElement(out AValue: ShortInt); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Word); overload;
    //TODO: doc me
    procedure GetElement(out AValue: SmallInt); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Cardinal); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Integer); overload;
    //TODO: doc me
    procedure GetElement(out AValue: UInt64); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Int64); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Single); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Double); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Extended); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Currency); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Comp); overload;
    //TODO: doc me
    procedure GetElement(out AValue: AnsiChar); overload;
    //TODO: doc me
    procedure GetElement(out AValue: WideChar); overload;
    //TODO: doc me
    procedure GetElement(out AValue: AnsiString); overload;
    //TODO: doc me
    procedure GetElement(out AValue: UnicodeString); overload;
    //TODO: doc me
    procedure GetElement(out AValue: Boolean); overload;
    //TODO: doc me
    procedure GetElement(out AValue: TDateTime); overload;
    //TODO: doc me
    procedure GetElement(out AValue; const ASize: NativeUInt); overload;
    //TODO: doc me
    procedure GetElement<T>(out AValue: T); overload;

    { Blocks }
    //TODO: doc me
    procedure ExpectBlock(const ALabel: String); overload;
    //TODO: doc me
    procedure ExpectBlock(); overload;

    //TODO: doc me
    function ExpectListBlock(const ALabel, AElementLabel: String): NativeUInt; overload;
    //TODO: doc me
    function ExpectListBlock(const ALabel: String; const AElementType: PTypeInfo): NativeUInt; overload;   //TODO: test?
    //TODO: doc me
    function ExpectListBlock(const AElementLabel: String): NativeUInt; overload;
    //TODO: doc me
    function ExpectListBlock(const AElementType: PTypeInfo): NativeUInt; overload;            //TODO: test?

    //TODO: doc me
    procedure EndBlock();

    { The enclosed context }
    //TODO: doc me
    property Context: IDeserializationContext read FOutContext;
    //TODO: doc me
    property InReadableForm: Boolean read GetInReadableForm;
    //TODO: doc me
    property CurrentElementInfo: TValueInfo read FElementInfo;
  end;

  ///  <summary>Implement this interface in any class to provide custom serialization and deserialization code.</summary>
  ISerializable = interface
    ['{0570DB9B-F9C8-430F-B635-3757CCAF3C47}']

    ///  <summary>Called by the serialization process when the object needs to be serialized.</summary>
    ///  <remarks>This method is called only once - the first time a reference to the object is found.</remarks>
    ///  <param name="AData">The serialization data block.</param>
    procedure Serialize(const AData: TSerializationData);

    ///  <summary>Called by the deserialization process when the object needs to be deserialized.</summary>
    ///  <remarks>This method is called only once - the first time a reference to the object is found.</remarks>
    ///  <param name="AData">The deserialization data block.</param>
    procedure Deserialize(const AData: TDeserializationData);
  end;

  ///  <summary>Implement this interface in any class if there is a need in finding out when the object's
  ///  deserialization has completely finished.</summary>
  IDeserializationCallback = interface
    ['{7BB78B2C-CFCC-4000-9321-3E15F08FCDC5}']

    ///  <summary>Called by the deserialization process when the object is completely deserialized.</summary>
    ///  <remarks>This method is called only when the class and all it's contents are fully deserialized. This includes
    ///  other contained objects and etc.</remarks>
    ///  <param name="AData">The deserialization data block.</param>
    procedure Deserialized(const AData: TDeserializationData);
  end;

type
  ///  <summary>Annotate a field with this attribute to exclude it from the serialization process.</summary>
  ///  <remarks>This attribute make a field "invisible" to serialization or deserialization processes.</remarks>
  NonSerialized = class sealed(TCustomAttribute) end;

implementation
uses DeHL.Types;

{ TValueInfo }

constructor TValueInfo.Create(const AType: TRttiType);
begin
  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  FLabel  := AType.Name;
  FObject := AType;
end;

constructor TValueInfo.Create(const AField: TRttiField);
begin
  if AField = nil then
    ExceptionHelper.Throw_ArgumentNilError('AField');

  FLabel  := AField.Name;
  FObject := AField;
end;

constructor TValueInfo.Create(const ALabel: string);
begin
  if ALabel = '' then
    ExceptionHelper.Throw_ArgumentNilError('ALabel');

  FLabel  := ALabel;
  FObject := nil;
end;

constructor TValueInfo.Create(const AField: TRttiField; const ALabel: string);
begin
  if AField = nil then
    ExceptionHelper.Throw_ArgumentNilError('AField');

  if ALabel = '' then
    ExceptionHelper.Throw_ArgumentNilError('ALabel');

  FLabel  := ALabel;
  FObject := AField;
end;

class function TValueInfo.Indexed: TValueInfo;
begin
  Result.FObject := nil;
  Result.FLabel  := '';
end;

{ TSerializationData }


procedure TSerializationData.AddValue(const ALabel: String; const AValue: Int64);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: UInt64);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Single);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Extended);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Double);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Integer);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: ShortInt);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Byte);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Word);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Cardinal);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: SmallInt);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Currency);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Boolean);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: UnicodeString);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddElement(const AValue: UInt64);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Integer);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Int64);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Double);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Single);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: ShortInt);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Byte);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Word);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Cardinal);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: SmallInt);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: UnicodeString);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: AnsiString);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Boolean);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue; const ASize: NativeUInt);
begin
  { Write the value }
  FInContext.AddBinaryValue(FElementInfo, AValue, ASize);
end;

procedure TSerializationData.AddElement(const AValue: TDateTime);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Currency);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Extended);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: Comp);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: WideChar);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement(const AValue: AnsiChar);
begin
  { Write the value }
  FInContext.AddValue(FElementInfo, AValue);
end;

procedure TSerializationData.AddElement<T>(const AIndex: NativeUInt; const AValue: T);
var
  LType: IType<T>;
begin
  { Get the type class }
  LType := TType<T>.Default;

  { Write the value }
  LType.Serialize(FElementInfo, AValue, FInContext);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue; const ASize: NativeUInt);
begin
  FInContext.AddBinaryValue(TValueInfo.Create(ALabel), AValue, ASize);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: TDateTime);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: AnsiChar);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: Comp);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: AnsiString);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue(const ALabel: String; const AValue: WideChar);
begin
  FInContext.AddValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TSerializationData.AddValue<T>(const ALabel: String; const AValue: T);
var
  FType: IType<T>;
begin
  FType := TType<T>.Default;
  FType.Serialize(TValueInfo.Create(ALabel), AValue, FInContext);
end;

constructor TSerializationData.Create(const AContext: ISerializationContext);
begin
  if AContext = nil then
    ExceptionHelper.Throw_ArgumentNilError('AContext');

  { Simple copy }
  FInContext := AContext;

  { Initialize the microstack }
  SetLength(FMicroStack, 16);
  FStackPtr := 0;
  FElementInfo := TValueInfo.Indexed;
end;

procedure TSerializationData.EndBlock;
begin
  { First end the composite type }
  FInContext.EndComplexType();

  { Extract the last stored element }
  FElementInfo := MicroPop();
end;

function TSerializationData.GetInReadableForm: Boolean;
begin
  Result := FInContext.InReadableForm;
end;

function TSerializationData.MicroPop: TValueInfo;
begin
  ASSERT(FStackPtr > 0); // Must fail since context should fail first

  { Move back }
  Dec(FStackPtr);

  { And get the value  }
  Result := FMicroStack[FStackPtr];
end;

procedure TSerializationData.MicroPush(const AInfo: TValueInfo);
var
  LLength: NativeUInt;
begin
  LLength := Length(FMicroStack);

  { Check whether to extend the array }
  if FStackPtr = LLength then
    SetLength(FMicroStack, LLength * 2);

  { Store the value }
  FMicroStack[FStackPtr] := AInfo;

  { And move forward }
  Inc(FStackPtr);
end;

procedure TSerializationData.StartBlock(const ALabel: String);
begin
  { Start a composite }
  FInContext.StartRecordType(TValueInfo.Create(ALabel));

  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

procedure TSerializationData.StartListBlock(const ALabel, AElementLabel: String; const AElementCount: NativeUInt);
begin
  { Start a composite }
  FInContext.StartArrayType(TValueInfo.Create(ALabel), TValueInfo.Create(AElementLabel), AElementCount);

  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

procedure TSerializationData.StartBlock();
begin
  { Start a composite }
  FInContext.StartRecordType(FElementInfo);

  { Store elements }
  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

procedure TSerializationData.StartListBlock(const ALabel: String;
  const AElementType: PTypeInfo; const AElementCount: NativeUInt);
var
  LRttiType: TRttiType;
begin
  if AElementType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AElementType');

  { Obtain the Rtti type }
  LRttiType := FInContext.GetTypeInformation(AElementType);

  { Start a composite }
  FInContext.StartArrayType(TValueInfo.Create(ALabel), TValueInfo.Create(LRttiType), AElementCount);

  { Store elements }
  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

procedure TSerializationData.StartListBlock(const AElementLabel: String; const AElementCount: NativeUInt);
begin
  { Start a composite }
  FInContext.StartArrayType(FElementInfo, TValueInfo.Create(AElementLabel), AElementCount);

  { Store elements }
  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

procedure TSerializationData.StartListBlock(const AElementType: PTypeInfo; const AElementCount: NativeUInt);
var
  LRttiType: TRttiType;
begin
  if AElementType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AElementType');

  { Obtain the Rtti type }
  LRttiType := FInContext.GetTypeInformation(AElementType);

  { Start a composite }
  FInContext.StartArrayType(FElementInfo, TValueInfo.Create(LRttiType), AElementCount);

  { Store elements }
  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

{ TDeserializationData }

constructor TDeserializationData.Create(const AContext: IDeserializationContext);
begin
  if AContext = nil then
    ExceptionHelper.Throw_ArgumentNilError('AContext');

  { Simple copy }
  FOutContext := AContext;

  { Initialize the microstack }
  SetLength(FMicroStack, 16);
  FStackPtr := 0;
  FElementInfo := TValueInfo.Indexed;
end;


procedure TDeserializationData.EndBlock;
begin
  { First end the composite type }
  FOutContext.EndComplexType();

  { Extract the last stored element }
  FElementInfo := MicroPop();
end;

procedure TDeserializationData.ExpectBlock(const ALabel: String);
begin
  { Start a composite }
  FOutContext.ExpectRecordType(TValueInfo.Create(ALabel));

  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

procedure TDeserializationData.ExpectBlock;
begin
  { Start a composite }
  FOutContext.ExpectRecordType(FElementInfo);

  { Store elements }
  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

function TDeserializationData.ExpectListBlock(const AElementLabel: String): NativeUInt;
begin
  { Start a composite }
  FOutContext.ExpectArrayType(FElementInfo, TValueInfo.Create(AElementLabel), Result);

  { Store elements }
  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

function TDeserializationData.ExpectListBlock(const ALabel, AElementLabel: String): NativeUInt;
begin
  { Start a composite }
  FOutContext.ExpectArrayType(TValueInfo.Create(ALabel), TValueInfo.Create(AElementLabel), Result);

  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

procedure TDeserializationData.GetElement(out AValue: UInt64);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Integer);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Single);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Int64);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Cardinal);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: ShortInt);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Byte);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: SmallInt);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Word);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: UnicodeString);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: AnsiString);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Boolean);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue; const ASize: NativeUInt);
var
  LPtr: Pointer;
  LName: String;
begin
  { Capture }
  LPtr := @AValue;
  LName := FElementInfo.Name;

  { Read the value }
  FOutContext.GetBinaryValue(FElementInfo,
    function(const ASize: NativeUInt): Pointer
    begin
      { Size mismatch? }
      if ASize <> ASize then
        ExceptionHelper.Throw_BinaryValueSizeMismatch(LName, '?');

      { Otherwise give it the pointer }
      Result := LPtr;
    end
  );
end;

procedure TDeserializationData.GetElement(out AValue: TDateTime);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: WideChar);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Extended);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Double);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Currency);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: AnsiChar);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement(out AValue: Comp);
begin
  { Read the value }
  FOutContext.GetValue(FElementInfo, AValue);
end;

procedure TDeserializationData.GetElement<T>(out AValue: T);
var
  LType: IType<T>;
begin
  { Get the type class }
  LType := TType<T>.Default;

  { Read the value }
  LType.Deserialize(FElementInfo, AValue, FOutContext);
end;

function TDeserializationData.GetInReadableForm: Boolean;
begin
  Result := FOutContext.InReadableForm;
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Integer);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Cardinal);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Int64);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: UInt64);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: ShortInt);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Byte);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: SmallInt);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Word);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Single);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: UnicodeString);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: AnsiString);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Boolean);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue; const ASize: NativeUInt);
var
  LPtr: Pointer;
  LName: String;
begin
  { Capture }
  LPtr := @AValue;
  LName := ALabel;

  { Read the value }
  FOutContext.GetBinaryValue(TValueInfo.Create(ALabel),
    function(const xSize: NativeUInt): Pointer
    begin
      { Size mismatch? }
      if xSize <> ASize then
        ExceptionHelper.Throw_BinaryValueSizeMismatch(LName, '?');

      { Otherwise give it the pointer }
      Result := LPtr;
    end
  );
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: TDateTime);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: WideChar);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Double);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Extended);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Currency);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: AnsiChar);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue(const ALabel: String; out AValue: Comp);
begin
  FOutContext.GetValue(TValueInfo.Create(ALabel), AValue);
end;

procedure TDeserializationData.GetValue<T>(const ALabel: String; out AValue: T);
var
  FType: IType<T>;
begin
  FType := TType<T>.Default;
  FType.Deserialize(TValueInfo.Create(ALabel), AValue, FOutContext);
end;

function TDeserializationData.MicroPop: TValueInfo;
begin
  ASSERT(FStackPtr > 0); // Must fail since context should fail first

  { Move back }
  Dec(FStackPtr);

  { And get the value  }
  Result := FMicroStack[FStackPtr];
end;

procedure TDeserializationData.MicroPush(const AInfo: TValueInfo);
var
  LLength: NativeUInt;
begin
  LLength := Length(FMicroStack);

  { Check whether to extend the array }
  if FStackPtr = LLength then
    SetLength(FMicroStack, LLength * 2);

  { Store the value }
  FMicroStack[FStackPtr] := AInfo;

  { And move forward }
  Inc(FStackPtr);
end;

function TDeserializationData.ExpectListBlock(const ALabel: String; const AElementType: PTypeInfo): NativeUInt;
var
  LRttiType: TRttiType;
begin
  if AElementType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AElementType');

  { Obtain the Rtti type }
  LRttiType := FOutContext.GetTypeInformation(AElementType);

  { Start a composite }
  FOutContext.ExpectArrayType(TValueInfo.Create(ALabel), TValueInfo.Create(LRttiType), Result);

  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

function TDeserializationData.ExpectListBlock(const AElementType: PTypeInfo): NativeUInt;
var
  LRttiType: TRttiType;
begin
  if AElementType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AElementType');

  { Obtain the Rtti type }
  LRttiType := FOutContext.GetTypeInformation(AElementType);

  { Start a composite }
  FOutContext.ExpectArrayType(FElementInfo, TValueInfo.Create(LRttiType), Result);

  { Store elements }
  MicroPush(FElementInfo);
  FElementInfo := TValueInfo.Indexed;
end;

end.
