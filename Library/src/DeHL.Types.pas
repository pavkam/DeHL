(*
* Copyright (c) 2008-2010, Ciobanu Alexandru
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

{$I DeHL.Defines.inc}
unit DeHL.Types;
interface
uses SysUtils,
     Generics.Defaults,
     Classes,
     TypInfo,
     Rtti,
     DeHL.Base,
     DeHL.StrConsts,
     DeHL.Exceptions,
     DeHL.Serialization;

type
  ///  <summary>Used to describe how a type's life-time is to be managed.</summary>
  ///  <remarks>Every type reports its life-time management through the <see cref="DeHL.Types|IType&lt;T&gt;.Management"/>
  ///  method. This value is used by any collection to decide, for example, if the values it holds should be cleaned
  ///  or ignored.</remarks>
  TTypeManagement = (
    ///  <summary>Values of the given type do not require cleaning.</summary>
    ///  <remarks>Simple types are usually the ones that fall into this category. An Integer, for example,
    ///  does not need any life-time management.</remarks>
    tmNone,
    ///  <summary>Values of the given type require manual cleaning.</summary>
    ///  <remarks>For example, an object requires manual cleaning. There may be other types that need to report this
    ///  type of management.</remarks>
    tmManual,
    ///  <summary>Values of the given type are managed by the compiler.</summary>
    ///  <remarks>Strings, interfaces, dynamic arrays, records that contain strings and etc. are
    ///  perfect examples of types that are managed by the compiler.</remarks>
    tmCompiler
  );

  ///  <summary>Used to describe the family of a type.</summary>
  ///  <remarks>Every type reports its family through the <see cref="DeHL.Types|IType&lt;T&gt;.Family">DeHL.Types.IType&lt;T&gt;.Family</see>
  ///  method. This value can be used to restrict generic classes to accept only some types.</remarks>
  TTypeFamily = (
    ///  <summary>Unknown family.</summary>
    tfUnknown,
    ///  <summary>Unsigned integers.</summary>
    tfUnsignedInteger,
    ///  <summary>Signed integers.</summary>
    tfSignedInteger,
    ///  <summary>Pointers.</summary>
    tfPointer,
    ///  <summary>Booleans.</summary>
    tfBoolean,
    ///  <summary>Methods.</summary>
    tfMethod,
    ///  <summary>Floating-point numbers.</summary>
    tfReal,
    ///  <summary>Characters.</summary>
    tfCharacter,
    ///  <summary>Strings.</summary>
    tfString,
    ///  <summary>Date and Time.</summary>
    tfDate,
    ///  <summary>Interfaces.</summary>
    tfInterface,
    ///  <summary>Classes.</summary>
    tfClass,
    ///  <summary>Class references.</summary>
    tfClassReference,
    ///  <summary>Variants.</summary>
    tfVariant,
    ///  <summary>Arrays.</summary>
    tfArray,
    ///  <summary>Records.</summary>
    tfRecord
  );

  ///  <summary>A set of type families.</summary>
  TTypeFamilySet = set of TTypeFamily;

type
  ///  <summary>Base class for all type extensions.</summary>
  ///  <remarks>A type extension allows plugging in other "functionality"
  ///  into the existing <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> objects.
  ///  For example, the math module of DeHL uses type extensions to inject math functionality into the type system.
  ///  </remarks>
  TTypeExtension = class abstract(TRefCountedObject)
  public
    ///  <summary>Instantiates a <see cref="DeHL.Types|TTypeExtension">DeHL.Types.TTypeExtension</see> object.</summary>
    ///  <remarks>This constructor needs to be overridden in descending classes.</remarks>
    constructor Create(); virtual;
  end;

  ///  <summary>The metaclass for <see cref="DeHL.Types|TTypeExtension">DeHL.Types.TTypeExtension</see>.</summary>
  TTypeExtensionClass = class of TTypeExtension;

  ///  <summary>The type extender "injector" class.</summary>
  ///  <remarks>After descending from <see cref="DeHL.Types|TTypeExtension">DeHL.Types.TTypeExtension</see>, it is required to
  ///  instantiate an object of type <see cref="DeHL.Types|TTypeExtender">DeHL.Types.TTypeExtender</see> to actually link the
  ///  type extension object to the type object. This class provides the functionality
  ///  to create the necessary links between type objects and the extension objects.</remarks>
  TTypeExtender = class sealed(TRefCountedObject)
  private
    { Cannot make it typed here! }
    FExtensions: TObject;

    { Creates a new type extension specific to the type }
    function CreateExtensionFor(const AObject: TObject): TTypeExtension;
  public
    ///  <summary>Instantiates a <see cref="DeHL.Types|TTypeExtender">DeHL.Types.TTypeExtender</see> object.</summary>
    constructor Create();

    ///  <summary>Destroys the current instance.</summary>
    ///  <remarks>Do not call this method directly; call <see cref="System.TObject.Free">System.TObject.Free</see> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Creates a link between a given type extender and a type object.</summary>
    ///  <remarks>The generic parameter "T" is used to retrieve the type object. Then a link is made between
    ///  that type object (describing the T argument) and the extension object.</remarks>
    ///  <param name="AExtension">The extension object. No exception is raised if this parameter is <c>nil</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ETypeExtensionException">An extension was already registered for the type.</exception>
    procedure Register<T>(const AExtension: TTypeExtensionClass);

    ///  <summary>Removes the link between any extension and the type.</summary>
    ///  <remarks>The generic parameter "T" is used to retrieve the type object. Then the link between
    ///  that type object (describing the T argument) and any extension object is removed.</remarks>
    ///  <exception cref="DeHL.Exceptions|ETypeExtensionException">No type extension registered for the described type.</exception>
    procedure Unregister<T>();
  end;

  ///  <summary>The base interface used to describe a Delphi type.</summary>
  ///  <remarks><see cref="DeHL.Types|IType">DeHL.Types.IType</see> is inherited by other interfaces that add more
  ///  functionality to a type object.</remarks>
  IType = interface
    ///  <summary>The unqualified name of the described type. Can be empty.</summary>
    ///  <returns>A string containing the name.</returns>
    function Name(): String;

    ///  <summary>The size of a value of the given type. Similar to SizeOf(T).</summary>
    ///  <returns>A nonzero, unsigned integer.</returns>
    function Size(): NativeUInt;

    ///  <summary>The type information of the described type.</summary>
    ///  <returns>A <see cref="TypInfo.PTypeInfo">TypInfo.PTypeInfo</see> value.</returns>
    function TypeInfo(): PTypeInfo;

    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement;

    ///  <summary>The family of the described type.</summary>
    ///  <returns>A <see cref="DeHL.Types|TTypeFamily">DeHL.Types.TTypeFamily</see> value.</returns>
    function Family(): TTypeFamily;

    ///  <summary>Asserts that the family of the described type is allowed.</summary>
    ///  <param name="Families">A set of <see cref="DeHL.Types|TTypeFamily">DeHL.Types.TTypeFamily</see> families to check against.</param>
    ///  <exception cref="DeHL.Exceptions|ETypeException">The type family is not contained in the provided set.</exception>
    procedure RestrictTo(const Families: TTypeFamilySet);

    ///  <summary>Tries to obtain a given extension for this type object.</summary>
    ///  <param name="AExtender">The extender object that maintains the links between the types and extensions.</param>
    ///  <returns>A newly created extension object, if such a link exists; <c>nil</c> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AExtender"/> is <c>nil</c>.</exception>
//DI - "inherits inherits?"
    function GetExtension(const AExtender: TTypeExtender): TTypeExtension;
  end;

  ///  <summary>The second-base interface used to describe a Delphi type.</summary>
  ///  <remarks><see cref="DeHL.Types|IConvertibleType&lt;T&gt;"/> inherits <see cref="DeHL.Types.IType">DeHL.Types.IConvertibleType&lt;T&gt;"/> inherits <see cref="DeHL.Types.IType</see> and
  ///  is inherited by other interfaces that add more functionality to a type object. This interface
  ///  adds the "convertability" to and from Variant that most type objects implement.
  ///  </remarks>
  IConvertibleType<T> = interface(IType)
    ///  <summary>Tries to convert a value of the described type to a Variant.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <param name="ORes">The Variant containing the converted value.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    function TryConvertToVariant(const AValue: T; out ORes: Variant): Boolean;

    ///  <summary>Converts a value of the described type to a Variant.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <returns>A <c>Variant</c> containing the converted value.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported">
    ///  <paramref name="AValue"/> cannot be converted to a <c>Variant</c>.</exception>
    function ConvertToVariant(const AValue: T): Variant;

    ///  <summary>Tries to convert a Variant to a value of the described type.</summary>
    ///  <param name="AValue">The Variant to convert.</param>
    ///  <param name="ORes">The converted value.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    function TryConvertFromVariant(const AValue: Variant; out ORes: T): Boolean;

    ///  <summary>Converts a Variant to a value of the described type.</summary>
    ///  <param name="AValue">The Variant to convert.</param>
    ///  <returns>The converted value if the conversion succeeded.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported"><paramref name="AValue"/> cannot be converted.</exception>
    function ConvertFromVariant(const AValue: Variant): T;
  end;

  ///  <summary>The most important interface used to describe a Delphi type.</summary>
  ///  <remarks><see cref="DeHL.Types|IType&lt;T&gt;"/> inherits <see cref="DeHL.Types.IConvertibleType&lt;T&gt;"/>.
  ///  This interface adds the rest of the required methods: comparison, hash code generation, cleanup, serialization, etc.
  ///  </remarks>
  IType<T> = interface(IConvertibleType<T>)
    ///  <summary>Compares two values of the described type.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <paramref name="AValue1"/> is less than <paramref name="AValue2"/>. If the result is zero,
    ///  <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>. And finally, if the result is greater than zero,
    ///  <paramref name="AValue1"/> is greater than <paramref name="AValue2"/>.</returns>
    function Compare(const AValue1, AValue2: T): NativeInt;

    ///  <summary>Checks whether two values of the described type are equal.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns><c>True</c> if <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>; <c>False</c> otherwise.</returns>
    function AreEqual(const AValue1, AValue2: T): Boolean;

    ///  <summary>Generates a hash code for a value of the described type.</summary>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: T): NativeInt;

    ///  <summary>Returns the string representation of a value of the described type.</summary>
    ///  <remarks>For most types, the value returned by this method represents the value as a string. For example,
    ///  calling this method for an integer would return the integer in a string form.</remarks>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>A string value describing the value.</returns>
    function GetString(const AValue: T): String;

    ///  <summary>Performs the cleanup of a value of the described type.</summary>
    ///  <remarks>This method is only relevant for types that report <see cref="DeHL.Types|IType.Management">DeHL.Types.IType.Management</see> as
    ///  tmManual; Otherwise it is ignored.</remarks>
    ///  <param name="AValue">The value to clean up.</param>
    procedure Cleanup(var AValue: T);

    ///  <summary>Serializes a value of the described type.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing
    ///  the field/element being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AContext"/> is <c>nil</c></exception>
    procedure Serialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext); overload;

    ///  <summary>Serializes a value of the described type.</summary>
    ///  <param name="ALabel">The name of the element being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TSerializationData">DeHL.Serialization.TSerializationData</see> to which the value is serialized.</param>
    procedure Serialize(const ALabel: String; const AValue: T; const AData: TSerializationData); overload;

    ///  <summary>Serializes a value of the described type.</summary>
    ///  <remarks>This method may only be called when serializing an element of an array. Otherwise, an undefined behavior occurs.</remarks>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TSerializationData">DeHL.Serialization.TSerializationData</see> to which the value is serialized.</param>
    procedure Serialize(const AValue: T; const AData: TSerializationData); overload;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"/><paramref name="AContext"/> is <c>nil</c>.</exception>
    procedure Deserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext); overload;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <param name="ALabel">The name of the element being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TDeserializationData">DeHL.Serialization.TDeserializationData</see> from which the value is deserialized.</param>
    procedure Deserialize(const ALabel: String; out AValue: T; const AData: TDeserializationData); overload;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <remarks>This method may only be called when serializing an element of an array. Otherwise, an undefined behavior occurs.</remarks>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TDeserializationData">DeHL.Serialization.TDeserializationData</see> from which the value is deserialized.</param>
    procedure Deserialize(out AValue: T; const AData: TDeserializationData); overload;

    ///  <summary>Returns a <see cref="Generics.Defaults.IComparer&lt;T&gt;">Generics.Defaults.IComparer&lt;T&gt;</see>.</summary>
    ///  <remarks>This method is provided for RTL compatibility and is useful only when combining DeHL types with RTL
    ///  collections.</remarks>
    ///  <returns>A <see cref="Generics.Defaults.IComparer&lt;T&gt;">Generics.Defaults.IComparer&lt;T&gt;</see>.</returns>
    function AsComparer(): IComparer<T>;

    ///  <summary>Returns a <see cref="Generics.Defaults.IEqualityComparer&lt;T&gt;"/>.</summary>
    ///  <remarks>This method is provided for RTL compatibility and is useful only when combining DeHL types with RTL
    ///  collections.</remarks>
    ///  <returns>A <see cref="Generics.Defaults.IEqualityComparer&lt;T&gt;"/>.</returns>
    function AsEqualityComparer(): IEqualityComparer<T>;
  end;

  ///  <summary>Specialized <see cref="DeHL.Types|IType&lt;T&gt;"/> used for class type objects.</summary>
  ///  <remarks><see cref="DeHL.Types|IClassType&lt;T&gt;"/> inherits <see cref="DeHL.Types.IType&lt;T&gt;"/>.
  ///  This interface only introduces a method to control whether the type object performs cleanup on
  ///  the instances of the classes it manages.
  ///  </remarks>
  IClassType<T: class> = interface(IType<T>)
    ///  <summary>Sets whether the described class instances are cleaned up.</summary>
    ///  <param name="ShouldCleanup">A Boolean value indicating if the cleanup should be performed.</param>
    procedure SetShouldCleanup(const ShouldCleanup: Boolean);
  end;

  ///  <summary>Meta-class for <see cref="DeHL.Types|TType">DeHL.Types.TType</see>.</summary>
  TTypeClass = class of TType;

  ///  <summary>The base class used to describe a Delphi type.</summary>
  ///  <remarks><see cref="DeHL.Types|TType">DeHL.Types.TType</see> is inherited by other classes that add more
  ///  functionality to a type object. <see cref="DeHL.Types|TType">DeHL.Types.TType</see> also implements
  ///  <see cref="DeHL.Types|IType">DeHL.Types.IType</see> and provides basic implementations for all the methods.</remarks>
  TType = class abstract(TRefCountedObject, IType)
  private type
    TSerializationGuts = record
      FType: TRttiType;
      FInContext: ISerializationContext;
      FOutContext: IDeserializationContext;

      constructor Create(const AType: TRttiType; const AInContext: ISerializationContext;
        const AOutContext: IDeserializationContext);
    end;

  private class var
    { HACK -- Cannot reference the dictionary/list directly }
    FCustomTypes: TObject;

  private var
    { Fields }
    FTypeSize: NativeUInt;
    FTypeInfo: PTypeInfo;
    FTypeFamily: TTypeFamily;
    FManagement: TTypeManagement;

    procedure SetTypeInfo(const ATypeInfo: PTypeInfo; const ATypeSize: NativeUInt);

    { Serialization utils }
    class function Skippable(const AField: TRttiField): Boolean;

    class procedure SerProcessFields(const AGuts: TSerializationGuts; const AInfo: TValueInfo;
      const ACount: NativeUInt; const APtrToField: Pointer; const ASerialize: Boolean);

    class procedure SerProcessStaticArray(const AGuts: TSerializationGuts; const AInfo: TValueInfo; const APtrToFirst: Pointer; const ASerialize: Boolean);
    class procedure SerProcessStructClass(const AGuts: TSerializationGuts; const APtrToInstance: Pointer; const ASerialize: Boolean);

    procedure InternalSerialize(const AInfo: TValueInfo; const APtrToValue: Pointer; const AContext: ISerializationContext); virtual; abstract;
    procedure InternalDeserialize(const AInfo: TValueInfo; const APtrToValue: Pointer; const AContext: IDeserializationContext); virtual; abstract;

    class function IsClassStructSerializable(const AType: TRttiType): Boolean;

    { Statics }
    class function GetParentTypeInfo(const ClassInfo: PTypeInfo): PTypeInfo; static;
    class function CreateBinaryType(const Size: NativeUInt): Pointer; static;
    class function CreateCharType(const Size: NativeUInt): Pointer; static;
    class function CreateIntegerType(const OrdinalType: TOrdType): Pointer; static;
    class function CreateFloatType(const FloatType: TFloatType): Pointer; static;
    class function CreateStringType(const Kind: TTypeKind): Pointer; static;
    class function CreateClassType(): Pointer; static;
    class function CreateVariantType(): Pointer; static;
    class function CreateInt64Type(const TypeData: PTypeData): Pointer; static;
    class function CreateDynamicArrayType(const ElementSize: NativeUInt; const TypeInfo: PTypeInfo): Pointer; static;

    class function CreateDefault(const TypeInfo: PTypeInfo; const TypeSize: NativeUInt;
      const AllowCustom: Boolean; const AArrayClass, ARecordClass: TTypeClass): Pointer; static;

    class function CreateCustomType(const TypeInfo: PTypeInfo): Pointer; static;
  public
    ///  <summary>Instantiates a <see cref="DeHL.Types|TType">DeHL.Types.TType</see> object.</summary>
    ///  <remarks>This constructor needs to be overridden in descending classes. In <see cref="DeHL.Types|TType">DeHL.Types.TType</see>
    ///  is is declared as abstract. </remarks>
    constructor Create(); virtual; abstract;

    ///  <summary>The unqualified name of the described type. It can be empty.</summary>
    ///  <returns>A string containing the name.</returns>
    function Name(): String; virtual;

    ///  <summary>The size of a value of the given type. Similar to <c>SizeOf(T)</c>.</summary>
    ///  <returns>A nonzero, unsigned integer.</returns>
    function Size(): NativeUInt; virtual;

    ///  <summary>The type information of the described type.</summary>
    ///  <returns>A <see cref="TypInfo.PTypeInfo">TypInfo.PTypeInfo</see> value. Can be a <c>nil</c> value.</returns>
    function TypeInfo(): PTypeInfo; virtual;

    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; virtual;

    ///  <summary>The family of the described type.</summary>
    ///  <returns>A <see cref="DeHL.Types|TTypeFamily">DeHL.Types.TTypeFamily</see> value.</returns>
    function Family(): TTypeFamily; virtual;

    ///  <summary>Asserts that the described type's family is what is needed.</summary>
    ///  <remarks>This method checks whether <see cref="DeHL.Types|IType.Family">DeHL.Types.IType.Family</see> is in the given set of
    ///  allowed families.</remarks>
    ///  <param name="Families">A set of <see cref="DeHL.Types|TTypeFamily">DeHL.Types.TTypeFamily</see> families to check against.</param>
    ///  <exception cref="DeHL.Exceptions|ETypeException">The described type is not present in the set.</exception>
    procedure RestrictTo(const AllowedFamilies: TTypeFamilySet); virtual;

    ///  <summary>Tries to obtain a given extension for this type object.</summary>
    ///  <param name="AExtender">The extender object that maintains the links between the types and extensions.</param>
    ///  <returns>A newly created extension object, if such a link exists; <c>nil</c> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AExtender"/> is <c>nil</c>.</exception>
    function GetExtension(const AExtender: TTypeExtender): TTypeExtension; virtual;
  end;

  ///  <summary>Anonymous procedure type that can be used to override the default comparison
  ///  behavior of a type object.</summary>
  TCompareOverride<T> = reference to function(const ALeft, ARight: T): NativeInt;

  ///  <summary>Anonymous procedure type that can be used to override the default hashing
  ///  behavior of a type object.</summary>
  THashOverride<T> = reference to function(const AValue: T): NativeInt;

  ///  <summary>The most important base class used to describe a Delphi type.</summary>
  ///  <remarks><see cref="DeHL.Types|TType&lt;T&gt;"/> inherits <see cref="DeHL.Types.TType"/> and implements
  ///  <see cref="DeHL.Types|IType&lt;T&gt;"/>.
  ///  This class adds the rest of the required methods: converting, comparison, hash code generation, cleanup, serialization, etc.
  ///  </remarks>
  TType<T> = class abstract(TType, IType<T>, IComparer<T>, IEqualityComparer<T>)
  private class var
    FCachedDefaultInstance,
      FCachedStandardInstance: TType<T>;

    FCachedDefaultInstanceIntf,
      FCachedStandardInstanceIntf: IInterface;

    { Creates custom stuff }
    class procedure DisposeCachedDefaultInstance(); static;
    class function CreateDefault(const AllowCustom: Boolean): TType<T>; static;

    procedure InternalSerialize(const AInfo: TValueInfo; const APtrToValue: Pointer; const AContext: ISerializationContext); override;
    procedure InternalDeserialize(const AInfo: TValueInfo; const APtrToValue: Pointer; const AContext: IDeserializationContext); override;

    { Name changing }
    function IEqualityComparer<T>.Equals = IEqualityComparerEquals;
    function IEqualityComparer<T>.GetHashCode = IEqualityComparerGetHashCode;
    function IComparer<T>.Compare = IComparerCompare;
  protected type
    TValRef = ^T;

  protected
    ///  <summary>Serializes a value of the described type.</summary>
    ///  <remarks>This method must be overridden in descending classes to implement proper serialization. By default,
    ///  an exception is thrown.</remarks>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing the field/element
    ///  being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">The value failed to serialize.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext); virtual;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <remarks>This method must be overridden in descending classes to implement proper serialization. By default,
    ///  an exception is thrown.</remarks>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">The value failed to serialize.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext); virtual;

    ///  <summary>Internal method. Do not call directly!</summary>
    function IEqualityComparerEquals(const Left, Right: T): Boolean;

    ///  <summary>Internal method. Do not call directly!</summary>
    function IEqualityComparerGetHashCode(const Value: T): Integer;

    ///  <summary>Internal method. Do not call directly!</summary>
    function IComparerCompare(const Left, Right: T): Integer;
  public
    ///  <summary>Instantiates a <see cref="DeHL.Types|TType&lt;T&gt;">DeHL.Types.TType&lt;T&gt;</see> object.</summary>
    ///  <remarks>This constructor can be overridden in descending classes. By default, this constructor collects Delphi
    ///  type information and prepares the type object for use.</remarks>
    constructor Create(); override;

    ///  <summary>Compares two values of the described type.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <paramref name="AValue1"/> is less than <paramref name="AValue2"/>. If the result is zero,
    ///  <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>. And finally, if the result is greater than zero,
    ///  <paramref name="AValue1"/> is greater than <paramref name="AValue2"/>.</returns>
    function Compare(const AValue1, AValue2: T): NativeInt; virtual; abstract;

    ///  <summary>Checks whether two values of the described type are equal.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns><c>True</c> if <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>; <c>False</c> otherwise.</returns>
    function AreEqual(const AValue1, AValue2: T): Boolean;

    ///  <summary>Generates a hash code for a value of the described type.</summary>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: T): NativeInt; virtual; abstract;

    ///  <summary>Performs the cleanup of a value of the described type.</summary>
    ///  <remarks>This method is only relevant for types that report <see cref="DeHL.Types|IType.Management">DeHL.Types.IType.Management</see> as
    ///  tmManual; otherwise it is ignored.</remarks>
    ///  <param name="AValue">The value to clean up.</param>
    procedure Cleanup(var AValue: T); virtual;

    ///  <summary>Returns the string representation of a value of the described type.</summary>
    ///  <remarks>For most types, the value returned by this method represents the value as a string. For example,
    ///  calling this method for an integer would return the integer in a string form.</remarks>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>A string value describing the value.</returns>
    function GetString(const AValue: T): String; virtual; abstract;

    ///  <summary>Serializes a value of the described type.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing the
    ///  field/element being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AContext"/> is <c>nil</c>.</exception>
    procedure Serialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext); overload;

    ///  <summary>Serializes a value of the described type.</summary>
    ///  <param name="ALabel">The name of the element being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TSerializationData">DeHL.Serialization.TSerializationData</see> to which the value is serialized.</param>
    procedure Serialize(const ALabel: String; const AValue: T; const AData: TSerializationData); overload;

    ///  <summary>Serializes a value of the described type.</summary>
    ///  <remarks>This method may only be called when serializing an element of an array. Otherwise, an undefined behavior occurs.</remarks>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TSerializationData">DeHL.Serialization.TSerializationData</see> to which the value is serialized.</param>
    procedure Serialize(const AValue: T; const AData: TSerializationData); overload;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing the field/element
    ///  being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AContext"/> is <c>nil</c>.</exception>
    procedure Deserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext); overload;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <param name="ALabel">The name of the element being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TDeserializationData">DeHL.Serialization.TDeserializationData</see> from which the value is deserialized.</param>
    procedure Deserialize(const ALabel: String; out AValue: T; const AData: TDeserializationData); overload;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <remarks>This method may only be called when serializing an element of an array. Otherwise, an undefined behavior occurs.</remarks>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AData">A <see cref="DeHL.Serialization|TDeserializationData">DeHL.Serialization.TDeserializationData</see> from which the value is deserialized.</param>
    procedure Deserialize(out AValue: T; const AData: TDeserializationData); overload;

    ///  <summary>Tries to convert a value of the described type to a Variant.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <param name="ORes">The Variant containing the converted value.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    function TryConvertToVariant(const AValue: T; out ORes: Variant): Boolean; virtual;

    ///  <summary>Converts a value of the described type to a Variant.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <returns>A <c>Variant</c> value containing the converted value.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported">Value conversion failed.</exception>
    function ConvertToVariant(const AValue: T): Variant;

    ///  <summary>Tries to convert a Variant to a value of the described type.</summary>
    ///  <param name="AValue">The Variant to convert.</param>
    ///  <param name="ORes">The converted value.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    function TryConvertFromVariant(const AValue: Variant; out ORes: T): Boolean; virtual;

    ///  <summary>Converts a <c>Variant</c> to a value of the described type.</summary>
    ///  <param name="AValue">A <c>Variant</c> value to convert from.</param>
    ///  <returns>The converted value.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported">Value conversion failed.</exception>
    function ConvertFromVariant(const AValue: Variant): T;

    ///  <summary>Returns a <see cref="Generics.Defaults.IComparer&lt;T&gt;">Generics.Defaults.IComparer&lt;T&gt;</see>.</summary>
    ///  <remarks>This method is provided for RTL compatibility and is useful only when combining DeHL types with the RTL
    ///  collections.</remarks>
    ///  <returns>A <see cref="Generics.Defaults.IComparer&lt;T&gt;">Generics.Defaults.IComparer&lt;T&gt;</see>.</returns>
    function AsComparer(): IComparer<T>;

    ///  <summary>Returns a <see cref="Generics.Defaults.IEqualityComparer&lt;T&gt;">Generics.Defaults.IEqualityComparer&lt;T&gt;</see>.</summary>
    ///  <remarks>This method is provided for RTL compatibility and is useful only when combining DeHL types with the RTL
    ///  collections.</remarks>
    ///  <returns>A <see cref="Generics.Defaults.IEqualityComparer&lt;T&gt;">Generics.Defaults.IEqualityComparer&lt;T&gt;</see>.</returns>
    function AsEqualityComparer(): IEqualityComparer<T>;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects.</remarks>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    class function Default: IType<T>; overload; static;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects; it also
    ///  allows to override the default comparison or hashing used by the type object.</remarks>
    ///  <param name="AComparer">An anonymous method to override the default comparison mechanism.</param>
    ///  <param name="AHasher">An anonymous method to override the default hashing mechanism.</param>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AComparer"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AHasher"/> is <c>nil</c>.</exception>
    class function Default(const AComparer: TCompareOverride<T>; const AHasher: THashOverride<T>): IType<T>; overload; static;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects.</remarks>
    ///  <param name="AllowedFamilies">A set of type families to check against. If the family of <c>T</c> is not in the
    ///  provided set, an exception is thrown.</param>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeException">The type family is not in the specified set.</exception>
    class function Default(const AllowedFamilies: TTypeFamilySet): IType<T>; overload; static;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects; it also
    ///  allows to override the default comparison or hashing used by the type object.</remarks>
    ///  <param name="AComparer">An anonymous method to override the default comparison mechanism.</param>
    ///  <param name="AHasher">An anonymous method to override the default hashing mechanism.</param>
    ///  <param name="AllowedFamilies">A set of type families to check against.</param>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AComparer"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AHasher"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeException">The type family is not in the specified set.</exception>
    class function Default(const AllowedFamilies: TTypeFamilySet; const AComparer: TCompareOverride<T>;
      const AHasher: THashOverride<T>): IType<T>; overload; static;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects; it does not
    ///  return custom type objects, but selects the standard ones.</remarks>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    class function Standard: IType<T>; overload; static;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects; it does not
    ///  return custom type objects, but selects the standard ones. It also
    ///  allows to override the default comparison or hashing used by the type object.</remarks>
    ///  <param name="AComparer">An anonymous method to override the default comparison mechanism.</param>
    ///  <param name="AHasher">An anonymous method to override the default hashing mechanism.</param>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AComparer"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AHasher"/> is <c>nil</c>.</exception>
    class function Standard(const AComparer: TCompareOverride<T>; const AHasher: THashOverride<T>): IType<T>; overload; static;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects; it does not
    ///  return custom type objects, but selects the standard ones.</remarks>
    ///  <param name="AllowedFamilies">A set of type families to check against.</param>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeException"/>The type family is not in the specified set.</exception>
    class function Standard(const AllowedFamilies: TTypeFamilySet): IType<T>; overload; static;

    ///  <summary>Returns a <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing the <c>T</c> generic type.</summary>
    ///  <remarks>This method uses caching techniques to speed up the creation and lookup of type objects; it does not
    ///  return custom type objects, but selects the standard ones. It also
    ///  allows to override the default comparison or hashing used by the type object.</remarks>
    ///  <param name="AComparer">An anonymous method to override the default comparison mechanism.</param>
    ///  <param name="AHasher">An anonymous method to override the default hashing mechanism.</param>
    ///  <param name="AllowedFamilies">A set of type families to check against.</param>
    ///  <returns>A <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> interface.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AComparer"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AHasher"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeException">The type family is not in the specified set.</exception>
    class function Standard(const AllowedFamilies: TTypeFamilySet; const AComparer: TCompareOverride<T>;
      const AHasher: THashOverride<T>): IType<T>; overload; static;

    ///  <summary>Registers a custom type object for <c>T</c> generic type.</summary>
    ///  <param name="AType">A class reference that describes the custom class.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeException">A type class is already registered for the described type or the
    ///  type does not provide type information.</exception>
    class procedure Register(const AType: TTypeClass); static;

    ///  <summary>Unregisters the custom type object for the <c>T</c> generic type.</summary>
    ///  <param name="AType">A class reference that describes the custom class.</param>
    ///  <exception cref="DeHL.Exceptions|ETypeException">No type class is registered for the described type or the
    ///  type does not provide type information.</exception>
    class procedure Unregister(); static;

    ///  <summary>Checks whether there is a custom type object registered for this <c>T</c> type.</summary>
    ///  <returns><c>True</c> if there is a registered custom type; <c>False</c> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeException"/>The type does not provide type information.</exception>
    class function IsRegistered(): Boolean; static;
  end;

  ///  <summary>Base class for custom type objects that are compiler-managed.</summary>
  TMagicType<T> = class abstract(TType<T>)
  public
    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <returns>Always <c>tmCompiler</c>.</returns>
    function Management(): TTypeManagement; override;
  end;

  ///  <summary>Base class for custom type objects that are manually managed.</summary>
  TManualType<T> = class abstract(TType<T>)
  public
    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <returns>Always <c>tmManual</c>.</returns>
    function Management(): TTypeManagement; override;
  end;

  ///  <summary>Base class for custom type objects that wrap other type objects.</summary>
  TWrapperType<T> = class(TType<T>)
  private
    FType: IType<T>;

  protected
    ///  <summary>Serializes a value of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing the field/element being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Value serialization failed.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext); override;

    ///  <summary>Deserializes a value of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Value deserialization failed.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext); override;
  public
    ///  <summary>Compares two values of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <paramref name="AValue1"/> is less than <paramref name="AValue2"/>. If the result is zero,
    ///  <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>. And finally, if the result is greater than zero,
    ///  <paramref name="AValue1"/> is greater than <paramref name="AValue2"/>.</returns>
    function Compare(const AValue1, AValue2: T): NativeInt; override;

    ///  <summary>Generates a hash code for a value of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: T): NativeInt; override;

    ///  <summary>Returns the string representation of a value of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>A string value describing the value.</returns>
    function GetString(const AValue: T): String; override;

    ///  <summary>Performs the cleanup of a value of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <param name="AValue">The value to cleanup.</param>
    procedure Cleanup(var AValue: T); override;

    ///  <summary>The unqualified name of the described type. Can be empty.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <returns>A string containing the name.</returns>
    function Name(): String; override;

    ///  <summary>The size of a value of the given type. Similar to <c>SizeOf(T)</c>.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <returns>A nonzero, unsigned integer.</returns>
    function Size(): NativeUInt; override;

    ///  <summary>The type information of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <returns>A <see cref="TypInfo.PTypeInfo">TypInfo.PTypeInfo</see> value. Can be a <c>nil</c> value.</returns>
    function TypeInfo(): PTypeInfo; override;

    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; override;

    ///  <summary>The family of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <returns>A <see cref="DeHL.Types|TTypeFamily">DeHL.Types.TTypeFamily</see> value.</returns>
    function Family(): TTypeFamily; override;

    ///  <summary>Tries to convert a value of the described type to a Variant.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <param name="ORes">The Variant containing the converted value.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    function TryConvertToVariant(const AValue: T; out ORes: Variant): Boolean; override;

    ///  <summary>Tries to convert a Variant to a value of the described type.</summary>
    ///  <remarks>Calls the same method on the wrapped type.</remarks>
    ///  <param name="AValue">The Variant to convert.</param>
    ///  <param name="ORes">The converted value.</param>
    ///  <returns><c>True</c> if the conversion succeeded; <c>False</c> otherwise.</returns>
    function TryConvertFromVariant(const AValue: Variant; out ORes: T): Boolean; override;

    ///  <summary>Throws an exception if called.</summary>
    ///  <exception cref="DeHL.Exceptions|EDefaultConstructorNotAllowed">Always thrown.</exception>
    constructor Create(); overload; override;

    ///  <summary>Creates an instance of <see cref="DeHL.Types|TWrapperType&lt;T&gt;">DeHL.Types.TWrapperType&lt;T&gt;</see>.</summary>
    ///  <param name="AType">The type that will be wrapped.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); reintroduce; overload;
  end;

  ///  <summary>A wrapper type class that allows overriding the comparison and hashing operations.</summary>
  TComparerWrapperType<T> = class(TWrapperType<T>)
  private
    FComparer: TCompareOverride<T>;
    FHasher: THashOverride<T>;

  public
    ///  <summary>Compares two values of the described type.</summary>
    ///  <remarks>Redirects this call to the enclosed comparer method.</remarks>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <paramref name="AValue1"/> is less than <paramref name="AValue2"/>. If the result is zero,
    ///  <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>. And finally, if the result is greater than zero,
    ///  <paramref name="AValue1"/> is greater than <paramref name="AValue2"/>.</returns>
    function Compare(const AValue1, AValue2: T): NativeInt; override;

    ///  <summary>Generates a hash code for a value of the described type.</summary>
    ///  <remarks>Redirects this call to the enclosed hashing method.</remarks>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: T): NativeInt; override;

    ///  <summary>Creates an instance of <see cref="DeHL.Types|TWrapperType&lt;T&gt;">DeHL.Types.TWrapperType&lt;T&gt;</see>.</summary>
    ///  <param name="AType">The type that will be wrapped.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); overload;

    ///  <summary>Creates an instance of <see cref="DeHL.Types|TWrapperType&lt;T&gt;">DeHL.Types.TWrapperType&lt;T&gt;</see>.</summary>
    ///  <param name="AComparer">Comparer method.</param>
    ///  <param name="AHasher">Hasher method.</param>
    ///  <param name="AType">The type that will be wrapped.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AComparer"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AHasher"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AComparer: TCompareOverride<T>; const AHasher: THashOverride<T>); overload;
  end;

  ///  <summary>A wrapper type class that allows suppressing the cleanup functions.</summary>
  TSuppressedWrapperType<T> = class(TWrapperType<T>)
  private
    FAllowCleanup: Boolean;

  public
    ///  <summary>Performs the cleanup of a value of the described type.</summary>
    ///  <remarks>This method calls the wrapped type's cleanup routines only if <c>AllowCleanup</c> is set to <c>True</c>.</remarks>
    ///  <param name="AValue">The value to clean up.</param>
    procedure Cleanup(var AValue: T); override;

    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <remarks>This method returns the wrapped type's management mode only if <c>AllowCleanup</c> is set to <c>True</c>. Otherwise,
    ///  <c>tmNone</c> (or <c>tmCompiler</c> if the wrapped type is managed) is returned.</remarks>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; override;

    ///  <summary>Allows prohibiting the cleanup operation.</summary>
    ///  <returns>A <c>Boolean</c> value specifying whether the cleanup is enabled or disabled.</returns>
    property AllowCleanup: Boolean read FAllowCleanup write FAllowCleanup;
  end;

  ///  <summary>A wrapper type class that allows suppressing the cleanup functions only for objects.</summary>
  TObjectWrapperType<T: class> = class(TSuppressedWrapperType<T>)
  public
    ///  <summary>Performs the cleanup of an object.</summary>
    ///  <remarks>This method directly frees the object if <c>AllowCleanup</c> is set to <c>True</c>.</remarks>
    ///  <param name="AValue">The object to clean up.</param>
    procedure Cleanup(var AValue: T); override;

    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <remarks>This method returns the wrapped type's management mode only if <c>AllowCleanup</c> is set to <c>True</c>. Otherwise,
    ///  <c>tmNone</c> is returned.</remarks>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; override;
  end;

  ///  <summary>A wrapper type class that allows suppressing the cleanup functions (with special treatment for objects).</summary>
  TMaybeObjectWrapperType<T> = class(TSuppressedWrapperType<T>)
  public
    ///  <summary>Performs the cleanup of a value.</summary>
    ///  <remarks>This method functions only if <c>AllowCleanup</c> is set to <c>True</c>. If <c>T</c> is a class type, freeing is performed;
    ///  otherwise the wrapped class type's cleanup method is invoked.</remarks>
    ///  <param name="AValue">The value to clean up.</param>
    procedure Cleanup(var AValue: T); override;

    ///  <summary>The life-time management employed by values of the described type.</summary>
    ///  <remarks>This method returns the wrapped type's management mode only if <c>AllowCleanup</c> is set to <c>True</c>. Otherwise,
    ///  <c>tmNone</c> (or <c>tmCompiler</c> if the wrapped type is managed) is returned.</remarks>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; override;
  end;

  ///  <summary>A type class that represents the class types.</summary>
  TClassType<T: class> = class(TType<T>, IClassType<T>)
  private
    FMustKillClass, FCanBeSerialized, FCanBeSerializedVerified: Boolean;

  private
    procedure InternalGetInterface(const AObject: TObject; const AIID: TGUID; var AOut: Pointer);
    procedure CheckSerializable(const AInfo: TValueInfo; const AContext: IContext);

  protected
    ///  <summary>Serializes an object.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see>
    ///  describing the field/element being serialized.</param>
    ///  <param name="AValue">The object being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the object is serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Object serialization failed.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext); override;

    ///  <summary>Deserializes an object.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see>
    ///  describing the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized object.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the object is deserialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Object deserialization failed.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext); override;

  public
    ///  <summary>Compares two objects.</summary>
    ///  <param name="AValue1">The object that is being compared.</param>
    ///  <param name="AValue1">The object that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <paramref name="AValue1"/> is less than <paramref name="AValue2"/>. If the result is zero,
    ///  <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>. And finally, if the result is greater than zero,
    ///  <paramref name="AValue1"/> is greater than <paramref name="AValue2"/>.</returns>
    ///  <remarks>If the compared objects implement <see cref="DeHL.Base|IComparable">DeHL.Base.IComparable</see>, the methods exposed
    ///  by it are used for comparison. Otherwise, <c>Equals</c> and other techniques are used to compare them. Note that the value
    ///  returned by this method may not correspond to reality in the case in which objects cannot be compared.</remarks>
    function Compare(const AValue1, AValue2: T): NativeInt; override;

    ///  <summary>Generates a hash code for the object.</summary>
    ///  <param name="AValue">The object to generate hash code for.</param>
    ///  <returns>An integer object containing the hash code.</returns>
    ///  <remarks>For a <c>nil</c> object, <c>0</c> is returned; otherwise, the object's <c>GetHashCode</c> method is called.</remarks>
    function GenerateHashCode(const AValue: T): NativeInt; override;

    ///  <summary>Returns the string representation of an object.</summary>
    ///  <param name="AValue">The object to generate a string for.</param>
    ///  <returns>The object's string representation.</returns>
    ///  <remarks>For a <c>nil</c> object, an empty string is returned; otherwise, the object's <c>ToString</c> method is called.</remarks>
    function GetString(const AValue: T): String; override;

    ///  <summary>The life-time management employed by objects of the described type.</summary>
    ///  <remarks>This method returns <c>tmManual</c> if the type class is configured to clean up the objects.
    ///  Otherwise this method returns <c>tmNone</c>.</remarks>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; override;

    ///  <summary>Configures the type object to clean (or not) the objects.</summary>
    ///  <param name="ShouldCleanup">A <c>Boolean</c> value indicating if the cleanup should be performed.</param>
    procedure SetShouldCleanup(const ShouldCleanup: Boolean);

    ///  <summary>Frees an object if the type class is configured to do so.</summary>
    ///  <param name="AValue">The object to free. This parameter is set to <c>nil</c> if the object was cleaned.</param>
    procedure Cleanup(var AValue: T); override;

    ///  <summary>Creates an instance of this type class.</summary>
    constructor Create(); overload; override;

    ///  <summary>Creates an instance of this type class with a given default cleanup behavior.</summary>
    ///  <param name="ShouldCleanup">A <c>Boolean</c> value indicating whether the represented object should be freed.</param>
    constructor Create(const ShouldCleanup: Boolean); reintroduce; overload;
  end;

  ///  <summary>A type class that represents the static array types.</summary>
  TArrayType<T> = class sealed(TType<T>)
  private
    FIsMagic: Boolean;

  protected
    ///  <summary>Serializes a static array.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see>
    ///  describing the field/element being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Value serialization failed.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext); override;

    ///  <summary>Deserializes a static array.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see>
    ///  describing the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Value deserialization failed.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext); override;
  public
    ///  <summary>Compares two static arrays.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <paramref name="AValue1"/> is less than <paramref name="AValue2"/>. If the result is zero,
    ///  <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>. And finally, if the result is greater than zero,
    ///  <paramref name="AValue1"/> is greater than <paramref name="AValue2"/>.</returns>
    function Compare(const AValue1, AValue2: T): NativeInt; override;

    ///  <summary>Generates a hash code for a static array.</summary>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: T): NativeInt; override;

    ///  <summary>The life-time management for the described static array type.</summary>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; override;

    ///  <summary>Returns the string representation of a static array.</summary>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>The value's string representation.</returns>
    function GetString(const AValue: T): String; override;

    ///  <summary>Creates an instance of this type class.</summary>
    constructor Create(); override;
  end;

  ///  <summary>A type class that represents the record types.</summary>
  TRecordType<T> = class(TType<T>)
  private
    FIsMagic, FCanBeSerialized, FCanBeSerializedVerified: Boolean;

    { Check if serializable }
    procedure CheckSerializable(const AContext: IContext; const AInfo: TValueInfo);

  protected
    ///  <summary>Serializes a record.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see>
    ///  describing the field/element being serialized.</param>
    ///  <param name="AValue">The value being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Value serialization failed.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext); override;

    ///  <summary>Deserializes a record.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see>
    ///  describing the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized value.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Value deserialization failed.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext); override;
  public
    ///  <summary>Compares two records.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <paramref name="AValue1"/> is less than <paramref name="AValue2"/>. If the result is zero,
    ///  <paramref name="AValue1"/> is equal to <paramref name="AValue2"/>. And finally, if the result is greater than zero,
    ///  <paramref name="AValue1"/> is greater than <paramref name="AValue2"/>.</returns>
    function Compare(const AValue1, AValue2: T): NativeInt; override;

    ///  <summary>Generates a hash code for a record.</summary>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: T): NativeInt; override;

    ///  <summary>The life-time management for the described record type.</summary>
    ///  <returns>A <see cref="DeHL.Types|TTypeManagement">DeHL.Types.TTypeManagement</see> value.</returns>
    function Management(): TTypeManagement; override;

    ///  <summary>Returns the string representation of a record.</summary>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>The value's string representation.</returns>
    function GetString(const AValue: T): String; override;

    ///  <summary>Creates an instance of this type class.</summary>
    constructor Create(); override;
  end;

  ///  <summary>A helper type that exposes methods to obtain type objects that represent strings.</summary>
  TStringType = record
  public
    ///  <summary>Returns a type object that represents a <c>ShortString</c>.</summary>
    ///  <param name="ACaseInsensitive">Supply <c>True</c> to force the type object to be case-insensitive.</param>
    ///  <returns>A type object for the specified string type.</returns>
    class function Short(const ACaseInsensitive: Boolean): IType<ShortString>; static;

    ///  <summary>Returns a type object that represents an <c>AnsiString</c>.</summary>
    ///  <param name="ACaseInsensitive">Supply <c>True</c> to force the type object to be case-insensitive.</param>
    ///  <returns>A type object for the specified string type.</returns>
    class function ANSI(const ACaseInsensitive: Boolean): IType<AnsiString>; static;

    ///  <summary>Returns a type object that represents a <c>WideString</c>.</summary>
    ///  <param name="ACaseInsensitive">Supply <c>True</c> to force the type object to be case-insensitive.</param>
    ///  <returns>A type object for the specified string type.</returns>
    class function Wide(const ACaseInsensitive: Boolean): IType<WideString>; static;

    ///  <summary>Returns a type object that represents a <c>UnicodeString</c>.</summary>
    ///  <param name="ACaseInsensitive">Supply <c>True</c> to force the type object to be case-insensitive.</param>
    ///  <returns>A type object for the specified string type.</returns>
    class function Unicode(const ACaseInsensitive: Boolean): IType<UnicodeString>; static;

    ///  <summary>Returns a type object that represents a <c>UCS4String</c>.</summary>
    ///  <param name="ACaseInsensitive">Supply <c>True</c> to force the type object to be case-insensitive.</param>
    ///  <returns>A type object for the specified string type.</returns>
    class function UCS4(const ACaseInsensitive: Boolean): IType<UCS4String>; static;

    ///  <summary>Returns a type object that represents a <c>UTF8String</c>.</summary>
    ///  <param name="ACaseInsensitive">Supply <c>True</c> to force the type object to be case-insensitive.</param>
    ///  <returns>A type object for the specified string type.</returns>
    class function UTF8(const ACaseInsensitive: Boolean): IType<UTF8String>; static;
  end;

///  <summary>Computes a hash for a given memory block.</summary>
///  <param name="AData">The pointer to the memory location.</param>
///  <param name="ASize">The size of memory block.</param>
///  <returns>A hash code for the given memory block.</returns>
function BinaryHash(const AData: Pointer; const ASize: NativeUInt): NativeInt;

///  <summary>Compares two memory blocks.</summary>
///  <param name="ALeft">The pointer to the memory location to compare.</param>
///  <param name="ARight">The pointer to the memory location to compare to.</param>
///  <param name="ASize">The size of memory blocks.</param>
///  <returns>An integer value depicting the result of the comparison operation.
///  If the result is less than zero, <paramref name="ALeft"/> is less than <paramref name="ARight"/>. If the result is zero,
///  <paramref name="ALeft"/> is equal to <paramref name="ARight"/>. And finally, if the result is greater than zero,
///  <paramref name="ALeft"/> is greater than <paramref name="ARight"/>.</returns>
function BinaryCompare(const ALeft, ARight: Pointer; const ASize: NativeUInt): NativeInt;

implementation
uses Windows,
     StrUtils,
     Character,
     Variants,
     AnsiStrings,
     DateUtils;

type
  TInternalDictionary = TCorePointerDictionary;
  TExtensionDictionary = TCorePointerDictionary;

(* ALL INTERNAL TYPES! *)
type
  TByteType = class sealed(TType<Byte>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Byte; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Byte; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Byte): NativeInt; override;
    function GenerateHashCode(const AValue: Byte): NativeInt; override;
    function GetString(const AValue: Byte): String; override;
    function TryConvertToVariant(const AValue: Byte; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Byte): Boolean; override;
    constructor Create(); override;
  end;

  TShortIntType = class sealed(TType<ShortInt>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: ShortInt; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: ShortInt; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: ShortInt): NativeInt; override;
    function GenerateHashCode(const AValue: ShortInt): NativeInt; override;
    function GetString(const AValue: ShortInt): String; override;
    function TryConvertToVariant(const AValue: ShortInt; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: ShortInt): Boolean; override;
    constructor Create(); override;
  end;

  TWordType = class sealed(TType<Word>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Word; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Word; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Word): NativeInt; override;
    function GenerateHashCode(const AValue: Word): NativeInt; override;
    function GetString(const AValue: Word): String; override;
    function TryConvertToVariant(const AValue: Word; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Word): Boolean; override;
    constructor Create(); override;
  end;

  TSmallIntType = class sealed(TType<SmallInt>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: SmallInt; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: SmallInt; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: SmallInt): NativeInt; override;
    function GenerateHashCode(const AValue: SmallInt): NativeInt; override;
    function GetString(const AValue: SmallInt): String; override;
    function TryConvertToVariant(const AValue: SmallInt; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: SmallInt): Boolean; override;
    constructor Create(); override;
  end;

  TCardinalType = class sealed(TType<Cardinal>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Cardinal; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Cardinal; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Cardinal): NativeInt; override;
    function GenerateHashCode(const AValue: Cardinal): NativeInt; override;
    function GetString(const AValue: Cardinal): String; override;
    function TryConvertToVariant(const AValue: Cardinal; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Cardinal): Boolean; override;
    constructor Create(); override;
  end;

  TIntegerType = class sealed(TType<Integer>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Integer; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Integer; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Integer): NativeInt; override;
    function GenerateHashCode(const AValue: Integer): NativeInt; override;
    function GetString(const AValue: Integer): String; override;
    function TryConvertToVariant(const AValue: Integer; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Integer): Boolean; override;
    constructor Create(); override;
  end;

  TInt64Type = class sealed(TType<Int64>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Int64; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Int64; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Int64): NativeInt; override;
    function GenerateHashCode(const AValue: Int64): NativeInt; override;
    function GetString(const AValue: Int64): String; override;
    function TryConvertToVariant(const AValue: Int64; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Int64): Boolean; override;
    constructor Create(); override;
  end;

  TUInt64Type = class sealed(TType<UInt64>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: UInt64; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: UInt64; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: UInt64): NativeInt; override;
    function GenerateHashCode(const AValue: UInt64): NativeInt; override;
    function GetString(const AValue: UInt64): String; override;
    function TryConvertToVariant(const AValue: UInt64; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: UInt64): Boolean; override;
    constructor Create(); override;
  end;

  TPointerType = class sealed(TType<Pointer>)
  private
    FCanBeSerialized, FCanBeSerializedVerified: Boolean;
    function GetElementType(const AContext: IContext; const AInfo: TValueInfo): TRttiType;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Pointer; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Pointer; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Pointer): NativeInt; override;
    function GenerateHashCode(const AValue: Pointer): NativeInt; override;
    function GetString(const AValue: Pointer): String; override;
    function TryConvertToVariant(const AValue: Pointer; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Pointer): Boolean; override;
    constructor Create(); override;
  end;

  TAnsiCharType = class sealed(TType<AnsiChar>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: AnsiChar; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: AnsiChar; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: AnsiChar): NativeInt; override;
    function GenerateHashCode(const AValue: AnsiChar): NativeInt; override;
    function GetString(const AValue: AnsiChar): String; override;
    function TryConvertToVariant(const AValue: AnsiChar; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: AnsiChar): Boolean; override;
    constructor Create(); override;
  end;

  TWideCharType = class sealed(TType<WideChar>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: WideChar; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: WideChar; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: WideChar): NativeInt; override;
    function GenerateHashCode(const AValue: WideChar): NativeInt; override;
    function GetString(const AValue: WideChar): String; override;
    function TryConvertToVariant(const AValue: WideChar; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: WideChar): Boolean; override;
    constructor Create(); override;
  end;

  TUCS4CharType = class sealed(TType<UCS4Char>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: UCS4Char; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: UCS4Char; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: UCS4Char): NativeInt; override;
    function GenerateHashCode(const AValue: UCS4Char): NativeInt; override;
    function GetString(const AValue: UCS4Char): String; override;
    function TryConvertToVariant(const AValue: UCS4Char; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: UCS4Char): Boolean; override;
    constructor Create(); override;
  end;

  TSingleType = class sealed(TType<Single>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Single; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Single; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Single): NativeInt; override;
    function GenerateHashCode(const AValue: Single): NativeInt; override;
    function GetString(const AValue: Single): String; override;
    function TryConvertToVariant(const AValue: Single; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Single): Boolean; override;
    constructor Create(); override;
  end;

  TDoubleType = class sealed(TType<Double>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Double; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Double; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Double): NativeInt; override;
    function GenerateHashCode(const AValue: Double): NativeInt; override;
    function GetString(const AValue: Double): String; override;
    function TryConvertToVariant(const AValue: Double; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Double): Boolean; override;
    constructor Create(); override;
  end;

  TCurrencyType = class sealed(TType<Currency>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Currency; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Currency; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Currency): NativeInt; override;
    function GenerateHashCode(const AValue: Currency): NativeInt; override;
    function GetString(const AValue: Currency): String; override;
    function TryConvertToVariant(const AValue: Currency; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Currency): Boolean; override;
    constructor Create(); override;
  end;

  TExtendedType = class sealed(TType<Extended>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Extended; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Extended; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Extended): NativeInt; override;
    function GenerateHashCode(const AValue: Extended): NativeInt; override;
    function GetString(const AValue: Extended): String; override;
    function TryConvertToVariant(const AValue: Extended; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Extended): Boolean; override;
    constructor Create(); override;
  end;

  TCompType = class sealed(TType<Comp>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Comp; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Comp; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Comp): NativeInt; override;
    function GenerateHashCode(const AValue: Comp): NativeInt; override;
    function GetString(const AValue: Comp): String; override;
    function TryConvertToVariant(const AValue: Comp; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Comp): Boolean; override;
    constructor Create(); override;
  end;

  TShortStringType = class sealed(TType<ShortString>)
  private
    FCaseInsensitive: Boolean;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: ShortString; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: ShortString; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: ShortString): NativeInt; override;
    function GenerateHashCode(const AValue: ShortString): NativeInt; override;
    function GetString(const AValue: ShortString): String; override;
    function TryConvertToVariant(const AValue: ShortString; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: ShortString): Boolean; override;
    constructor Create(); overload; override;
    constructor Create(const CaseInsensitive: Boolean); reintroduce; overload;
  end;

  TAnsiStringType = class sealed(TType<AnsiString>)
  private
    FCaseInsensitive: Boolean;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: AnsiString; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: AnsiString; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: AnsiString): NativeInt; override;
    function GenerateHashCode(const AValue: AnsiString): NativeInt; override;
    function GetString(const AValue: AnsiString): String; override;
    function TryConvertToVariant(const AValue: AnsiString; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: AnsiString): Boolean; override;
    constructor Create(); overload; override;
    constructor Create(const CaseInsensitive: Boolean); reintroduce; overload;
  end;

  TWideStringType = class sealed(TType<WideString>)
  private
    FCaseInsensitive: Boolean;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: WideString; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: WideString; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: WideString): NativeInt; override;
    function GenerateHashCode(const AValue: WideString): NativeInt; override;
    function GetString(const AValue: WideString): String; override;
    function TryConvertToVariant(const AValue: WideString; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: WideString): Boolean; override;
    constructor Create(); overload; override;
    constructor Create(const CaseInsensitive: Boolean); reintroduce; overload;
  end;

  TUnicodeStringType = class sealed(TType<UnicodeString>)
  private
    FCaseInsensitive: Boolean;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: UnicodeString; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: UnicodeString; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: UnicodeString): NativeInt; override;
    function GenerateHashCode(const AValue: UnicodeString): NativeInt; override;
    function GetString(const AValue: UnicodeString): String; override;
    function TryConvertToVariant(const AValue: UnicodeString; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: UnicodeString): Boolean; override;
    constructor Create(); overload; override;
    constructor Create(const CaseInsensitive: Boolean); reintroduce; overload;
  end;

  TUCS4StringType = class sealed(TType<UCS4String>)
  private
    FCaseInsensitive: Boolean;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: UCS4String; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: UCS4String; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: UCS4String): NativeInt; override;
    function GenerateHashCode(const AValue: UCS4String): NativeInt; override;
    function GetString(const AValue: UCS4String): String; override;
    function TryConvertToVariant(const AValue: UCS4String; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: UCS4String): Boolean; override;
    constructor Create(); overload; override;
    constructor Create(const CaseInsensitive: Boolean); reintroduce; overload;
  end;

  TUTF8StringType = class sealed(TType<UTF8String>)
  private
    FCaseInsensitive: Boolean;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: UTF8String; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: UTF8String; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: UTF8String): NativeInt; override;
    function GenerateHashCode(const AValue: UTF8String): NativeInt; override;
    function GetString(const AValue: UTF8String): String; override;
    function TryConvertToVariant(const AValue: UTF8String; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: UTF8String): Boolean; override;
    constructor Create(); overload; override;
    constructor Create(const CaseInsensitive: Boolean); reintroduce; overload;
  end;

  TInterfaceType = class sealed(TType<IInterface>)
  public
    function Compare(const AValue1, AValue2: IInterface): NativeInt; override;
    function GenerateHashCode(const AValue: IInterface): NativeInt; override;
    function GetString(const AValue: IInterface): String; override;
    constructor Create(); override;
  end;

  TMetaclassType = class sealed(TType<TClass>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TClass; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TClass; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: TClass): NativeInt; override;
    function GenerateHashCode(const AValue: TClass): NativeInt; override;
    function GetString(const AValue: TClass): String; override;
    constructor Create(); override;
  end;

  TVariantType = class sealed(TType<Variant>)
  public
    function Compare(const AValue1, AValue2: Variant): NativeInt; override;
    function GenerateHashCode(const AValue: Variant): NativeInt; override;
    function GetString(const AValue: Variant): String; override;
    function TryConvertToVariant(const AValue: Variant; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Variant): Boolean; override;
    constructor Create(); override;
  end;

  TBinaryType = class sealed(TType<Pointer>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Pointer; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Pointer; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Pointer): NativeInt; override;
    function GenerateHashCode(const AValue: Pointer): NativeInt; override;
    function GetString(const AValue: Pointer): String; override;
    constructor Create(); overload; override;
    constructor Create(const Size: NativeUInt); reintroduce; overload;
  end;

  __TMethod = procedure of object;

  TMethodType = class sealed(TType<__TMethod>)
  public
    function Compare(const AValue1, AValue2: __TMethod): NativeInt; override;
    function GenerateHashCode(const AValue: __TMethod): NativeInt; override;
    function GetString(const AValue: __TMethod): String; override;
    constructor Create(); override;
  end;

  TProcedureType = class sealed(TType<Pointer>)
  public
    function Compare(const AValue1, AValue2: Pointer): NativeInt; override;
    function GenerateHashCode(const AValue: Pointer): NativeInt; override;
    function GetString(const AValue: Pointer): String; override;
    function TryConvertToVariant(const AValue: Pointer; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Pointer): Boolean; override;
    constructor Create(); override;
  end;

  __T3BytesRec = packed record
    b1, b2, b3: Byte;
  end;

  T3BytesType = class sealed(TType<__T3BytesRec>)
  public
    function Compare(const AValue1, AValue2: __T3BytesRec): NativeInt; override;
    function GenerateHashCode(const AValue: __T3BytesRec): NativeInt; override;
    function GetString(const AValue: __T3BytesRec): String; override;
    constructor Create(); override;
  end;

  TDynArrayType = class sealed(TMagicType<TBoundArray>)
  private
    FSizeOfElement: NativeUInt;
    FArrayTypeInfo: PTypeInfo;
    function GetElementType(const AContext: IContext; const AInfo: TValueInfo): TRttiType;
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TBoundArray; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TBoundArray; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: TBoundArray): NativeInt; override;
    function GenerateHashCode(const AValue: TBoundArray): NativeInt; override;
    function GetString(const AValue: TBoundArray): String; override;
    function TryConvertToVariant(const AValue: TBoundArray; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TBoundArray): Boolean; override;
    constructor Create(); overload; override;
    constructor Create(const SizeOfElement: NativeUInt; const TypeInfo: PTypeInfo); reintroduce; overload;
  end;

  TBooleanType = class sealed(TType<Boolean>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Boolean; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Boolean; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: Boolean): NativeInt; override;
    function GenerateHashCode(const AValue: Boolean): NativeInt; override;
    function GetString(const AValue: Boolean): String; override;
    function TryConvertToVariant(const AValue: Boolean; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Boolean): Boolean; override;
    constructor Create(); override;
  end;

  TByteBoolType = class sealed(TType<ByteBool>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: ByteBool; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: ByteBool; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: ByteBool): NativeInt; override;
    function GenerateHashCode(const AValue: ByteBool): NativeInt; override;
    function GetString(const AValue: ByteBool): String; override;
    function TryConvertToVariant(const AValue: ByteBool; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: ByteBool): Boolean; override;
    constructor Create(); override;
  end;

  TWordBoolType = class sealed(TType<WordBool>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: WordBool; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: WordBool; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: WordBool): NativeInt; override;
    function GenerateHashCode(const AValue: WordBool): NativeInt; override;
    function GetString(const AValue: WordBool): String; override;
    function TryConvertToVariant(const AValue: WordBool; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: WordBool): Boolean; override;
    constructor Create(); override;
  end;

  TLongBoolType = class sealed(TType<LongBool>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: LongBool; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: LongBool; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: LongBool): NativeInt; override;
    function GenerateHashCode(const AValue: LongBool): NativeInt; override;
    function GetString(const AValue: LongBool): String; override;
    function TryConvertToVariant(const AValue: LongBool; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: LongBool): Boolean; override;
    constructor Create(); override;
  end;

  TDateType = class sealed(TType<TDate>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TDate; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TDate; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: TDate): NativeInt; override;
    function GenerateHashCode(const AValue: TDate): NativeInt; override;
    function GetString(const AValue: TDate): String; override;
    function TryConvertToVariant(const AValue: TDate; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TDate): Boolean; override;
    constructor Create(); override;
  end;

  TTimeType = class sealed(TType<TTime>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TTime; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TTime; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: TTime): NativeInt; override;
    function GenerateHashCode(const AValue: TTime): NativeInt; override;
    function GetString(const AValue: TTime): String; override;
    function TryConvertToVariant(const AValue: TTime; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TTime): Boolean; override;
    constructor Create(); override;
  end;

  TDateTimeType = class sealed(TType<TDateTime>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TDateTime; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TDateTime; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: TDateTime): NativeInt; override;
    function GenerateHashCode(const AValue: TDateTime): NativeInt; override;
    function GetString(const AValue: TDateTime): String; override;
    function TryConvertToVariant(const AValue: TDateTime; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TDateTime): Boolean; override;
    constructor Create(); override;
  end;

  TRawByteStringType = class sealed(TType<RawByteString>)
  protected
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: RawByteString; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: RawByteString; const AContext: IDeserializationContext); override;
  public
    function Compare(const AValue1, AValue2: RawByteString): NativeInt; override;
    function GenerateHashCode(const AValue: RawByteString): NativeInt; override;
    function GetString(const AValue: RawByteString): String; override;
    function TryConvertToVariant(const AValue: RawByteString; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: RawByteString): Boolean; override;
    constructor Create(); override;
  end;

{ Binary Support functions }

function BinaryHash(const AData: Pointer; const ASize: NativeUInt): NativeInt;
const
  MAGIC_CONST = $7ED55D16;
var
  I: NativeUInt;
  LRemaining: NativeUInt;
  LTemp: NativeInt;
  LNewSize: NativeUInt;
  LPtr: Pointer;
begin
  if (ASize = 0) or (AData = nil) then
  begin
    Result := 0;
    Exit;
  end;

  Result := MAGIC_CONST;
  LRemaining := ASize and 3;
  LNewSize := NativeUInt(ASize shr 2);
  LPtr := AData;

  if LNewSize > 0 then
    for I := 0 to LNewSize - 1 do
    begin
      Inc(Result, PWord(LPtr)^);
      LTemp := (PWordArray(LPtr)^[1] shl 11) xor Result;
      Result := (Result shl 16) xor LTemp;
      Inc(Result, Result shr 11);
      Inc(PWord(LPtr), 2);
    end;

  case LRemaining of
    3:
    begin
      Inc(Result, PWord(LPtr)^);
      Result := Result xor (Result shl 16);
      Result := Result xor (PByteArray(LPtr)^[2] shl 18);
      Inc(Result, Result shr 11);
    end;
    2:
    begin
      Inc(Result, PWord(LPtr)^);
      Result := Result xor (Result shl 11);
      Inc(Result, Result shr 17);
    end;
    1:
    begin
      Inc(Result, PByte(LPtr)^);
      Result := Result xor (Result shl 10);
      Inc(Result, Result shr 1);
    end;
  end;

  Result := Result xor (Result shl 3);
  Inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  Inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  Inc(Result, Result shr 6);
end;

function BinaryCompare(const ALeft, ARight: Pointer; const ASize: NativeUInt): NativeInt;
var
  LLPtr, LRPtr: Pointer;
  LLen: NativeUInt;
begin
  { Init }
  LLPtr := ALeft;
  LRPtr := ARight;
  LLen := ASize;
  Result := 0; // Equal!

  { Compare by NativeInts at first }
  while LLen > SizeOf(NativeInt) do
  begin
    { Compare left to right }
    if PNativeInt(LLPtr)^ > PNativeInt(LRPtr)^ then Exit(1)
    else if PNativeInt(LLPtr)^ < PNativeInt(LRPtr)^ then Exit(-1);

    Dec(LLen, SizeOf(NativeInt));
    Inc(PNativeInt(LLPtr));
    Inc(PNativeInt(LRPtr));
  end;

  { If there are bytes left to compare, use byte traversal }
  if LLen > 0 then
  begin
    while LLen > 0 do
    begin
      Result := PByte(LLPtr)^ - PByte(LRPtr)^;
      if Result <> 0 then
        Exit;

      Dec(LLen);
      Inc(PByte(LLPtr));
      Inc(PByte(LRPtr));
    end;
  end;
end;

{ TType<T> }

class procedure TType<T>.Register(const AType: TTypeClass);
var
  PInfo: PTypeInfo;
  Dict: TInternalDictionary;
begin
  { Extract type information }
  PInfo := System.TypeInfo(T);

  { Check for nil }
  if PInfo = nil then
    ExceptionHelper.Throw_CustomTypeHasNoRTTI();

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  MonitorEnter(FCustomTypes);

  { Type-cast to what wee need }
  Dict := TInternalDictionary(FCustomTypes);

  { Check if this class is not registered yet }
  if Dict.ContainsKey(PInfo) then
  begin
    MonitorExit(FCustomTypes);
    ExceptionHelper.Throw_CustomTypeAlreadyRegistered(GetTypeName(PInfo));
  end;

  { Dispose of the old cached instance and add the new one }
  DisposeCachedDefaultInstance();
  Dict.Add(PInfo, AType);

  MonitorExit(FCustomTypes);
end;

class function TType<T>.Standard: IType<T>;
begin
  { Create a new class and extract an interface from it }
  Result := CreateDefault(false);
end;

procedure TType<T>.Serialize(const ALabel: String; const AValue: T; const AData: TSerializationData);
begin
  { Call the other serialize method }
  Serialize(TValueInfo.Create(ALabel), AValue, AData.Context);
end;

procedure TType<T>.Serialize(const AValue: T; const AData: TSerializationData);
begin
  { Call the other serialize method }
  Serialize(AData.CurrentElementInfo, AValue, AData.Context);
end;

class function TType<T>.Standard(const AllowedFamilies: TTypeFamilySet): IType<T>;
begin
  { First, call the original method }
  Result := Standard();
  Result.RestrictTo(AllowedFamilies);
end;

class procedure TType<T>.Unregister();
var
  PInfo: PTypeInfo;
  Dict: TInternalDictionary;

begin
  { Extract type information }
  PInfo := System.TypeInfo(T);

  { Check for nil }
  if PInfo = nil then
    ExceptionHelper.Throw_CustomTypeHasNoRTTI();

  MonitorEnter(FCustomTypes);

  { Type-cast to what wee need }
  Dict := TInternalDictionary(FCustomTypes);

  { Check if this class is not registered yet }

  if not Dict.ContainsKey(PInfo) then
  begin
    MonitorExit(FCustomTypes);
    ExceptionHelper.Throw_CustomTypeNotYetRegistered(GetTypeName(PInfo));
  end;

  { Dispose of the old cached instance and remove from dictionary }
  DisposeCachedDefaultInstance();
  Dict.Remove(PInfo);

  MonitorExit(FCustomTypes);
end;

function TType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: T): Boolean;
begin
  { Unsupported by default }
  Result := false;
end;

function TType<T>.TryConvertToVariant(const AValue: T; out ORes: Variant): Boolean;
begin
  { Unsupported by default }
  Result := False;
end;

procedure TType<T>.Serialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext);
begin
  { Check scope }
  if AContext = nil then
    ExceptionHelper.Throw_ArgumentNilError('AContext');

  { Call the actual code }
  DoSerialize(AInfo, AValue, AContext);
end;

function TType<T>.IComparerCompare(const Left, Right: T): Integer;
begin
  { Delegate to our implementation }
  Result := Compare(Left, Right);
end;

function TType<T>.IEqualityComparerEquals(const Left, Right: T): Boolean;
begin
  { Delegate to our implementation }
  Result := AreEqual(Left, Right);
end;

function TType<T>.IEqualityComparerGetHashCode(const Value: T): Integer;
begin
  { Delegate to our implementation }
  Result := GenerateHashCode(Value);
end;

procedure TType<T>.InternalDeserialize(const AInfo: TValueInfo; const APtrToValue: Pointer; const AContext: IDeserializationContext);
begin
  { Call the normal serialization }
  DoDeserialize(AInfo, TValRef(APtrToValue)^, AContext);
end;

procedure TType<T>.InternalSerialize(const AInfo: TValueInfo; const APtrToValue: Pointer; const AContext: ISerializationContext);
begin
  { Call the normal serialization }
  DoSerialize(AInfo, TValRef(APtrToValue)^, AContext);
end;

function TType<T>.AreEqual(const AValue1, AValue2: T): Boolean;
begin
  Result := Compare(AValue1, AValue2) = 0;
end;

function TType<T>.AsComparer: IComparer<T>;
begin
  { Return self casted to IComparer<T> }
  Result := Self;
end;

function TType<T>.AsEqualityComparer: IEqualityComparer<T>;
begin
  { Return self casted to IEqualityComparer<T> }
  Result := Self;
end;

procedure TType<T>.Cleanup(var AValue: T);
begin
  { Nothing ... }
end;

function TType<T>.ConvertFromVariant(const AValue: Variant): T;
begin
  if not TryConvertFromVariant(AValue, Result) then
     ExceptionHelper.Throw_ConversionNotSupported(Name);
end;

function TType<T>.ConvertToVariant(const AValue: T): Variant;
begin
  if not TryConvertToVariant(AValue, Result) then
     ExceptionHelper.Throw_ConversionNotSupported('Variant');
end;

constructor TType<T>.Create;
begin
  { Call internal }
  SetTypeInfo(System.TypeInfo(T), SizeOf(T));
end;

class function TType<T>.CreateDefault(const AllowCustom: Boolean): TType<T>;
var
  Instance: TType<T>;
  FieldAddress: Pointer;
  IntfAddress: ^IInterface;
begin
  { Select the appropriate cached value }
  if AllowCustom then
  begin
    Result := FCachedDefaultInstance;
    FieldAddress := @FCachedDefaultInstance;
    IntfAddress := @FCachedDefaultInstanceIntf;
  end else
  begin
    Result := FCachedStandardInstance;
    FieldAddress := @FCachedStandardInstance;
    IntfAddress := @FCachedStandardInstanceIntf;
  end;

  { No cached instance }
  if Result = nil then
  begin
    { Create a new type instance }
    Instance := TType.CreateDefault(System.TypeInfo(T), SizeOf(T), AllowCustom, TArrayType<T>, TRecordType<T>);
    Result := InterlockedCompareExchangePointer(Pointer(FieldAddress^), Instance, nil);

    { Select the type class }
    if Result = nil then
    begin
      Result := Instance;
      IntfAddress^ := Result; { Get me a reference locally }

{$IFDEF BUG_NO_GEN_CDTOR_IN_MAIN}
      { Register this memory as leaked, if this type is instantiated in the main program unit }
      RegisterExpectedMemoryLeak(Result);
{$ENDIF}
    end else
      Instance.Free;
  end;
end;

class function TType<T>.Default(const AllowedFamilies: TTypeFamilySet): IType<T>;
begin
  { First, call the original method }
  Result := Default;
  Result.RestrictTo(AllowedFamilies);
end;

procedure TType<T>.Deserialize(const ALabel: String; out AValue: T; const AData: TDeserializationData);
begin
  { Call the other serialize method }
  Deserialize(TValueInfo.Create(ALabel), AValue, AData.Context);
end;

class function TType<T>.Default(const AComparer: TCompareOverride<T>;
  const AHasher: THashOverride<T>): IType<T>;
begin
  { Create a wrapper around the normal one }
  Result := TComparerWrapperType<T>.Create(Default(), AComparer, AHasher);
end;

class function TType<T>.Default(const AllowedFamilies: TTypeFamilySet;
  const AComparer: TCompareOverride<T>;
  const AHasher: THashOverride<T>): IType<T>;
begin
  { Create a wrapper around the normal one }
  Result := TComparerWrapperType<T>.Create(Default(AllowedFamilies), AComparer, AHasher);
end;

procedure TType<T>.Deserialize(out AValue: T; const AData: TDeserializationData);
begin
  { Call the other serialize method }
  Deserialize(AData.CurrentElementInfo, AValue, AData.Context);
end;

procedure TType<T>.Deserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext);
begin
  { Check scope }
  if AContext = nil then
    ExceptionHelper.Throw_ArgumentNilError('AContext');

  { Call the actual code }
  DoDeserialize(AInfo, AValue, AContext);
end;

class procedure TType<T>.DisposeCachedDefaultInstance;
begin
  { Mark both the class and the interface as "done for" }
  FCachedDefaultInstance := nil;
  FCachedDefaultInstanceIntf := nil;
end;

procedure TType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

procedure TType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

class function TType<T>.IsRegistered(): Boolean;
var
  PInfo: PTypeInfo;
  Dict: TInternalDictionary;

begin
  { Extract type information }
  PInfo := System.TypeInfo(T);
  Result := false;

  { Check for nil }
  if PInfo = nil then
    Exit;

  MonitorEnter(FCustomTypes);

  { Type-cast to what wee need }
  Dict := TInternalDictionary(FCustomTypes);

  { Check if this class is not registered yet }
  if Dict.ContainsKey(PInfo) then
    Result := true;

  MonitorExit(FCustomTypes);
end;

{ TType<T> }

class function TType<T>.Default: IType<T>;
begin
  { Create a new class and extract an interface from it }
  Result := CreateDefault(true);
end;

class function TType<T>.Standard(const AComparer: TCompareOverride<T>;
  const AHasher: THashOverride<T>): IType<T>;
begin
  { Create a wrapper around the normal one }
  Result := TComparerWrapperType<T>.Create(Standard(), AComparer, AHasher);
end;

class function TType<T>.Standard(const AllowedFamilies: TTypeFamilySet;
  const AComparer: TCompareOverride<T>;
  const AHasher: THashOverride<T>): IType<T>;
begin
  { Create a wrapper around the normal one }
  Result := TComparerWrapperType<T>.Create(Standard(AllowedFamilies), AComparer, AHasher);
end;

{ TIntegerType }

function TIntegerType.Compare(const AValue1, AValue2: Integer): NativeInt;
begin
{$IF SizeOf(Integer) < SizeOf(NativeInt)}
  Result := NativeInt(AValue1) - NativeInt(AValue2);
{$ELSE}
  if AValue1 > AValue2 then
     Result := 1
  else if AValue1 < AValue2 then
     Result := -1
  else
     Result := 0;
{$IFEND}
end;

constructor TIntegerType.Create;
begin
  inherited;
  FTypeFamily := tfSignedInteger;
end;

function TIntegerType.GenerateHashCode(const AValue: Integer): NativeInt;
begin
  Result := AValue;
end;

function TIntegerType.GetString(const AValue: Integer): String;
begin
  Result := IntToStr(AValue);
end;

function TIntegerType.TryConvertFromVariant(const AValue: Variant; out ORes: Integer): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TIntegerType.TryConvertToVariant(const AValue: Integer; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TIntegerType.DoDeserialize(const AInfo: TValueInfo; out AValue: Integer; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TIntegerType.DoSerialize(const AInfo: TValueInfo; const AValue: Integer; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TDoubleType }

function TDoubleType.Compare(const AValue1, AValue2: Double): NativeInt;
begin
  if AValue1 < AValue2 then
     Result := -1
  else if AValue1 > AValue2 then
     Result := 1
  else
     Result := 0;
end;

constructor TDoubleType.Create;
begin
  inherited;
  FTypeFamily := tfReal;
end;

function TDoubleType.GenerateHashCode(const AValue: Double): NativeInt;
{$IF SizeOf(Double) <= SizeOf(NativeInt)}
var
  I: NativeInt absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
    Result := I;
end;
{$ELSE}
var
  LongOp: array[0..1] of Integer absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TDoubleType.GetString(const AValue: Double): String;
begin
  Result := FloatToStr(AValue);
end;

function TDoubleType.TryConvertFromVariant(const AValue: Variant; out ORes: Double): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TDoubleType.TryConvertToVariant(const AValue: Double; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TDoubleType.DoDeserialize(const AInfo: TValueInfo; out AValue: Double; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TDoubleType.DoSerialize(const AInfo: TValueInfo; const AValue: Double; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TByteType }

function TByteType.Compare(const AValue1, AValue2: Byte): NativeInt;
begin
  Result := NativeInt(AValue1) - NativeInt(AValue2);
end;

constructor TByteType.Create;
begin
  inherited;
  FTypeFamily := tfUnsignedInteger;
end;

function TByteType.GenerateHashCode(const AValue: Byte): NativeInt;
begin
  Result := AValue;
end;

function TByteType.GetString(const AValue: Byte): String;
begin
  Result := IntToStr(AValue);
end;

function TByteType.TryConvertFromVariant(const AValue: Variant; out ORes: Byte): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TByteType.TryConvertToVariant(const AValue: Byte; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TByteType.DoDeserialize(const AInfo: TValueInfo; out AValue: Byte; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TByteType.DoSerialize(const AInfo: TValueInfo; const AValue: Byte; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TShortIntType }

function TShortIntType.Compare(const AValue1, AValue2: ShortInt): NativeInt;
begin
  Result := NativeInt(AValue1) - NativeInt(AValue2);
end;

constructor TShortIntType.Create;
begin
  inherited;

  FTypeFamily := tfSignedInteger;
end;

function TShortIntType.GenerateHashCode(const AValue: ShortInt): NativeInt;
begin
  Result := AValue;
end;

function TShortIntType.GetString(const AValue: ShortInt): String;
begin
  Result := IntToStr(AValue);
end;

function TShortIntType.TryConvertFromVariant(const AValue: Variant; out ORes: ShortInt): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TShortIntType.TryConvertToVariant(const AValue: ShortInt; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TShortIntType.DoDeserialize(const AInfo: TValueInfo; out AValue: ShortInt; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TShortIntType.DoSerialize(const AInfo: TValueInfo; const AValue: ShortInt; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TWordType }

function TWordType.Compare(const AValue1, AValue2: Word): NativeInt;
begin
  Result := NativeInt(AValue1) - NativeInt(AValue2);
end;

constructor TWordType.Create;
begin
  inherited;

  FTypeFamily := tfUnsignedInteger;
end;

function TWordType.GenerateHashCode(const AValue: Word): NativeInt;
begin
  Result := AValue;
end;

function TWordType.GetString(const AValue: Word): String;
begin
  Result := IntToStr(AValue);
end;

function TWordType.TryConvertFromVariant(const AValue: Variant; out ORes: Word): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TWordType.TryConvertToVariant(const AValue: Word; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TWordType.DoDeserialize(const AInfo: TValueInfo; out AValue: Word; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TWordType.DoSerialize(const AInfo: TValueInfo; const AValue: Word; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TSmallIntType }

function TSmallIntType.Compare(const AValue1, AValue2: SmallInt): NativeInt;
begin
  Result := NativeInt(AValue1) - NativeInt(AValue2);
end;

constructor TSmallIntType.Create;
begin
  inherited;
  FTypeFamily := tfSignedInteger;
end;

function TSmallIntType.GenerateHashCode(const AValue: SmallInt): NativeInt;
begin
  Result := AValue;
end;

function TSmallIntType.GetString(const AValue: SmallInt): String;
begin
  Result := IntToStr(AValue);
end;

function TSmallIntType.TryConvertFromVariant(const AValue: Variant; out ORes: SmallInt): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TSmallIntType.TryConvertToVariant(const AValue: SmallInt; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TSmallIntType.DoDeserialize(const AInfo: TValueInfo; out AValue: SmallInt; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TSmallIntType.DoSerialize(const AInfo: TValueInfo; const AValue: SmallInt; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TCardinalType }

function TCardinalType.Compare(const AValue1, AValue2: Cardinal): NativeInt;
begin
{$IF SizeOf(Cardinal) < SizeOf(NativeInt)}
  Result := NativeInt(AValue1) - NativeInt(AValue2);
{$ELSE}
  if AValue1 > AValue2 then
     Result := 1
  else if AValue1 < AValue2 then
     Result := -1
  else
     Result := 0;
{$IFEND}
end;

constructor TCardinalType.Create;
begin
  inherited;
  FTypeFamily := tfUnsignedInteger;
end;

function TCardinalType.GenerateHashCode(const AValue: Cardinal): NativeInt;
begin
  Result := Integer(AValue);
end;

function TCardinalType.GetString(const AValue: Cardinal): String;
begin
  Result := IntToStr(AValue);
end;

function TCardinalType.TryConvertFromVariant(const AValue: Variant; out ORes: Cardinal): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TCardinalType.TryConvertToVariant(const AValue: Cardinal; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TCardinalType.DoDeserialize(const AInfo: TValueInfo; out AValue: Cardinal; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TCardinalType.DoSerialize(const AInfo: TValueInfo; const AValue: Cardinal; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TInt64Type }

function TInt64Type.Compare(const AValue1, AValue2: Int64): NativeInt;
begin
  if AValue1 > AValue2 then
     Result := 1
  else if AValue1 < AValue2 then
     Result := -1
  else
     Result := 0;
end;

constructor TInt64Type.Create;
begin
  inherited;
  FTypeFamily := tfSignedInteger;
end;

function TInt64Type.GenerateHashCode(const AValue: Int64): NativeInt;
{$IF SizeOf(Int64) <= SizeOf(NativeInt)}
begin
  Result := NativeInt(AValue);
end;
{$ELSE}
var
  I: array[0..1] of Integer absolute AValue;
begin
  Result := I[0] xor I[1];
end;
{$IFEND}

function TInt64Type.GetString(const AValue: Int64): String;
begin
  Result := IntToStr(AValue);
end;

function TInt64Type.TryConvertFromVariant(const AValue: Variant; out ORes: Int64): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TInt64Type.TryConvertToVariant(const AValue: Int64; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TInt64Type.DoDeserialize(const AInfo: TValueInfo; out AValue: Int64; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TInt64Type.DoSerialize(const AInfo: TValueInfo; const AValue: Int64; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TUInt64Type }

function TUInt64Type.Compare(const AValue1, AValue2: UInt64): NativeInt;
begin
  if AValue1 > AValue2 then
     Result := 1
  else if AValue1 < AValue2 then
     Result := -1
  else
     Result := 0;
end;

constructor TUInt64Type.Create;
begin
  inherited;

  FTypeFamily := tfUnsignedInteger;
end;

function TUInt64Type.GenerateHashCode(const AValue: UInt64): NativeInt;
{$IF SizeOf(UInt64) <= SizeOf(NativeInt)}
begin
  Result := NativeInt(AValue);
end;
{$ELSE}
var
  I: array[0..1] of Integer absolute AValue;
begin
  Result := I[0] xor I[1];
end;
{$IFEND}

function TUInt64Type.GetString(const AValue: UInt64): String;
begin
  Result := IntToStr(AValue);
end;

function TUInt64Type.TryConvertFromVariant(const AValue: Variant; out ORes: UInt64): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TUInt64Type.TryConvertToVariant(const AValue: UInt64; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TUInt64Type.DoDeserialize(const AInfo: TValueInfo; out AValue: UInt64; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TUInt64Type.DoSerialize(const AInfo: TValueInfo; const AValue: UInt64; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TSingleType }

function TSingleType.Compare(const AValue1, AValue2: Single): NativeInt;
begin
  if AValue1 < AValue2 then
     Result := -1
  else if AValue1 > AValue2 then
     Result := 1
  else
     Result := 0;
end;

constructor TSingleType.Create;
begin
  inherited;
  FTypeFamily := tfReal;
end;

function TSingleType.GenerateHashCode(const AValue: Single): NativeInt;
var
  LongOp: Integer absolute AValue;
begin
  Result := LongOp;
end;

function TSingleType.GetString(const AValue: Single): String;
begin
  Result := FloatToStr(AValue);
end;

function TSingleType.TryConvertFromVariant(const AValue: Variant; out ORes: Single): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TSingleType.TryConvertToVariant(const AValue: Single; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TSingleType.DoDeserialize(const AInfo: TValueInfo; out AValue: Single; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TSingleType.DoSerialize(const AInfo: TValueInfo; const AValue: Single; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TExtendedType }

function TExtendedType.Compare(const AValue1, AValue2: Extended): NativeInt;
begin
  if AValue1 < AValue2 then
     Result := -1
  else if AValue1 > AValue2 then
     Result := 1
  else
     Result := 0;
end;

constructor TExtendedType.Create;
begin
  inherited;
  FTypeFamily := tfReal;
end;

function TExtendedType.GenerateHashCode(const AValue: Extended): NativeInt;
var
  Words: array[0..4] of Word absolute AValue;
  Ints : array[0..1] of Integer absolute Words;

begin
  if AValue = 0 then
     Result := 0
  else
     Result := Ints[0] xor Ints[1] xor Words[4];
end;

function TExtendedType.GetString(const AValue: Extended): String;
begin
  Result := FloatToStr(AValue);
end;

function TExtendedType.TryConvertFromVariant(const AValue: Variant; out ORes: Extended): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TExtendedType.TryConvertToVariant(const AValue: Extended; out ORes: Variant): Boolean;
begin
  { Possible overflow }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

procedure TExtendedType.DoDeserialize(const AInfo: TValueInfo; out AValue: Extended; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TExtendedType.DoSerialize(const AInfo: TValueInfo; const AValue: Extended; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TCompType }

function TCompType.Compare(const AValue1, AValue2: Comp): NativeInt;
begin
  if AValue1 < AValue2 then
     Result := -1
  else if AValue1 > AValue2 then
     Result := 1
  else
     Result := 0;
end;

constructor TCompType.Create;
begin
  inherited;

  FTypeFamily := tfReal;
end;

function TCompType.GenerateHashCode(const AValue: Comp): NativeInt;
{$IF SizeOf(Comp) <= SizeOf(NativeInt)}
var
  LongOp: NativeInt absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  LongOp: array[0..1] of Integer absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TCompType.GetString(const AValue: Comp): String;
begin
  Result := FloatToStr(AValue);
end;

function TCompType.TryConvertFromVariant(const AValue: Variant; out ORes: Comp): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TCompType.TryConvertToVariant(const AValue: Comp; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TCompType.DoDeserialize(const AInfo: TValueInfo; out AValue: Comp; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TCompType.DoSerialize(const AInfo: TValueInfo; const AValue: Comp; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TCurrencyType }

function TCurrencyType.Compare(const AValue1, AValue2: Currency): NativeInt;
begin
  if AValue1 < AValue2 then
     Result := -1
  else if AValue1 > AValue2 then
     Result := 1
  else
     Result := 0;
end;

constructor TCurrencyType.Create;
begin
  inherited;
  FTypeFamily := tfReal;
end;

function TCurrencyType.GenerateHashCode(const AValue: Currency): NativeInt;
{$IF SizeOf(Currency) <= SizeOf(NativeInt)}
var
  LongOp: NativeInt absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  LongOp: array[0..1] of Integer absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TCurrencyType.GetString(const AValue: Currency): String;
begin
  Result := FloatToStr(AValue);
end;

function TCurrencyType.TryConvertFromVariant(const AValue: Variant; out ORes: Currency): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TCurrencyType.TryConvertToVariant(const AValue: Currency; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TCurrencyType.DoDeserialize(const AInfo: TValueInfo; out AValue: Currency; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TCurrencyType.DoSerialize(const AInfo: TValueInfo; const AValue: Currency; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TAnsiStringType }

function TAnsiStringType.Compare(const AValue1, AValue2: AnsiString): NativeInt;
begin
  if FCaseInsensitive then
    Result := AnsiCompareText(AValue1, AValue2)
  else
    Result := AnsiCompareStr(AValue1, AValue2);
end;

constructor TAnsiStringType.Create;
begin
  inherited;

  FTypeFamily := tfString;
  FCaseInsensitive := false;
end;

constructor TAnsiStringType.Create(const CaseInsensitive: Boolean);
begin
  inherited Create();

  FTypeFamily := tfString;
  FCaseInsensitive := CaseInsensitive;
end;

function TAnsiStringType.GenerateHashCode(const AValue: AnsiString): NativeInt;
var
  Cpy: AnsiString;
begin
  { Call the generic hasher }
  if Length(AValue) > 0 then
  begin
    if not FCaseInsensitive then
      Result := BinaryHash(Pointer(AValue), Length(AValue) * SizeOf(AnsiChar))
    else
    begin
      Cpy := AnsiUpperCase(AValue);
      Result := BinaryHash(Pointer(Cpy), Length(AValue) * SizeOf(AnsiChar));
    end;
  end
  else
     Result := 0;
end;

function TAnsiStringType.GetString(const AValue: AnsiString): String;
begin
  Result := String(AValue);
end;

function TAnsiStringType.TryConvertFromVariant(const AValue: Variant; out ORes: AnsiString): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AnsiString(AValue);
  except
    Exit(false);
  end;

  Result := true;
end;

function TAnsiStringType.TryConvertToVariant(const AValue: AnsiString; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TAnsiStringType.DoDeserialize(const AInfo: TValueInfo; out AValue: AnsiString; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TAnsiStringType.DoSerialize(const AInfo: TValueInfo; const AValue: AnsiString; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TUnicodeStringType }

function TUnicodeStringType.Compare(const AValue1, AValue2: UnicodeString): NativeInt;
begin
  if FCaseInsensitive then
    Result := CompareText(AValue1, AValue2)
  else
    Result := CompareStr(AValue1, AValue2);
end;

constructor TUnicodeStringType.Create;
begin
  inherited;

  FTypeFamily := tfString;
  FCaseInsensitive := false;
end;

constructor TUnicodeStringType.Create(const CaseInsensitive: Boolean);
begin
  inherited Create();

  FTypeFamily := tfString;
  FCaseInsensitive := CaseInsensitive;
end;

function TUnicodeStringType.GenerateHashCode(const AValue: UnicodeString): NativeInt;
var
  Cpy: String;
begin
  { Call the generic hasher }
  if Length(AValue) > 0 then
  begin
    if not FCaseInsensitive then
      Result := BinaryHash(Pointer(AValue), Length(AValue) * SizeOf(Char))
    else
    begin
      Cpy := UpperCase(AValue);
      Result := BinaryHash(Pointer(Cpy), Length(AValue) * SizeOf(Char));
    end;
  end
  else
     Result := 0;
end;

function TUnicodeStringType.GetString(const AValue: UnicodeString): String;
begin
  Result := AValue;
end;

function TUnicodeStringType.TryConvertFromVariant(const AValue: Variant; out ORes: UnicodeString): Boolean;
begin
  { Variant type-cast }
  try
    ORes := UnicodeString(AValue);
  except
    Exit(false);
  end;

  Result := true;
end;

function TUnicodeStringType.TryConvertToVariant(const AValue: UnicodeString; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TUnicodeStringType.DoDeserialize(const AInfo: TValueInfo; out AValue: UnicodeString; const AContext: IDeserializationContext);
var
  LRefValue: UnicodeString;
begin
  AContext.GetValue(AInfo, LRefValue);
  AValue := LRefValue;
end;

procedure TUnicodeStringType.DoSerialize(const AInfo: TValueInfo; const AValue: UnicodeString; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TWideStringType }

function TWideStringType.Compare(const AValue1, AValue2: WideString): NativeInt;
begin
  if FCaseInsensitive then
    Result := WideCompareText(AValue1, AValue2)
  else
    Result := WideCompareStr(AValue1, AValue2);
end;

constructor TWideStringType.Create;
begin
  inherited;

  FTypeFamily := tfString;
  FCaseInsensitive := false;
end;

constructor TWideStringType.Create(const CaseInsensitive: Boolean);
begin
  inherited Create();

  FTypeFamily := tfString;
  FCaseInsensitive := CaseInsensitive;
end;

function TWideStringType.GenerateHashCode(const AValue: WideString): NativeInt;
var
  Cpy: String;
begin
  { Call the generic hasher }
  if Length(AValue) > 0 then
  begin
    if not FCaseInsensitive then
      Result := BinaryHash(Pointer(AValue), Length(AValue) * SizeOf(WideChar))
    else
    begin
      Cpy := WideUpperCase(AValue);
      Result := BinaryHash(Pointer(Cpy), Length(AValue) * SizeOf(WideChar));
    end;
  end
  else
     Result := 0;
end;

function TWideStringType.GetString(const AValue: WideString): String;
begin
  Result := AValue;
end;

function TWideStringType.TryConvertFromVariant(const AValue: Variant; out ORes: WideString): Boolean;
begin
  { Variant type-cast }
  try
    ORes := WideString(AValue);
  except
    Exit(false);
  end;

  Result := true;
end;

function TWideStringType.TryConvertToVariant(const AValue: WideString; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TWideStringType.DoDeserialize(const AInfo: TValueInfo; out AValue: WideString; const AContext: IDeserializationContext);
var
  LValue: String;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := WideString(LValue);
end;

procedure TWideStringType.DoSerialize(const AInfo: TValueInfo; const AValue: WideString; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TClassType<T> }

procedure TClassType<T>.CheckSerializable(const AInfo: TValueInfo; const AContext: IContext);
begin
  { Verify if the class can be serialized }
  if not FCanBeSerializedVerified then
  begin
    FCanBeSerializedVerified := true;
    FCanBeSerialized := IsClassStructSerializable(AContext.GetTypeInformation(FTypeInfo));
  end;

  { If the class cannot be serialized (not marked as such) fail! }
  if not FCanBeSerialized then
    ExceptionHelper.Throw_MarkedUnserializable(AInfo.Name, Name);
end;

procedure TClassType<T>.Cleanup(var AValue: T);
begin
  if FMustKillClass then
    FreeAndNil(AValue);
end;

function TClassType<T>.Compare(const AValue1, AValue2: T): NativeInt;
var
  LComparable: IComparable;
begin
  { No actual ordering! }
  if (AValue1 = nil) and (AValue2 <> nil) then
    Exit(-1);

  if (AValue1 <> nil) and (AValue2 = nil) then
    Exit(1);

  if (AValue1 = nil) and (AValue2 = nil) then
    Exit(0);

  { OK, check if the 1st object implements IComparable }
  InternalGetInterface(AValue1, IComparable, Pointer(LComparable));

  if LComparable <> nil then
  begin
    { Compare the first value to the second one }
    try
      { Don't trust the comparison to be safe. }
      Result := LComparable.CompareTo(AValue2);
    finally
      { Force nil to the interface so we don't call _Release on it }
      Pointer(LComparable) := nil;
    end;

    exit;
  end;

  { Nothing so far, let's check for equality -- Call the equals on both objects }
  if AValue1.Equals(AValue2) then
     Exit(0);

  { Last case, brute and ugly address check. }
  if NativeInt(TObject(AValue1)) > NativeInt(TObject(AValue2)) then
    Result := 1
  else if NativeInt(TObject(AValue1)) < NativeInt(TObject(AValue2)) then
    Result := -1
  else
    Result := 0;
end;

constructor TClassType<T>.Create;
begin
  { Call the other .ctor }
  Create(false);
end;

constructor TClassType<T>.Create(const ShouldCleanup: Boolean);
var
  LAttr: TCustomAttribute;
begin
  inherited Create();

  FTypeFamily := tfClass;
  FMustKillClass := ShouldCleanup;
  FCanBeSerializedVerified := false;
end;

procedure TClassType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext);
var
  LSerializable: ISerializable;
  LDeserializationCallback: IDeserializationCallback;

  LClass: TClass;
begin
  { Check serialization is supported }
  CheckSerializable(AInfo, AContext);

  { Obtain the class of the object }
  LClass := GetTypeData(FTypeInfo)^.ClassType;

  { Open or create a new scope }
  if AContext.ExpectClassType(AInfo, LClass, TObject(AValue)) then
  begin
    { Create a new object instance }
    AValue := T(Activator.CreateInstance(LClass));

    try
      AContext.RegisterReference(TObject(AValue));

      { Check if the class has it's own serialization code }
      InternalGetInterface(AValue, ISerializable, Pointer(LSerializable));
      InternalGetInterface(AValue, IDeserializationCallback, Pointer(LDeserializationCallback));

      if LSerializable <> nil then
      begin
        { Deserialize }
        LSerializable.Deserialize(TDeserializationData.Create(AContext));

        { Force nil to the interface so we don't call _Release on it }
        Pointer(LSerializable) := nil;
      end else
        SerProcessStructClass(TSerializationGuts.Create(AContext.GetTypeInformation(LClass.ClassInfo),
          nil, AContext), TObject(AValue), false);

      if LDeserializationCallback <> nil then
      begin
        { Deserialize }
        LDeserializationCallback.Deserialized(TDeserializationData.Create(AContext));

        { Force nil to the interface so we don't call _Release on it }
        Pointer(LDeserializationCallback) := nil;
      end;

      { Close the block }
      AContext.EndComplexType();
    except
      { Make sure we kill the instace! }
      FreeAndNil(AValue);

      { re-raise the exception }
      raise;
    end;
  end;
end;

procedure TClassType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext);
var
  LSerializable: ISerializable;
  LClass: TClass;
begin
  { Check serialization is supported }
  CheckSerializable(AInfo, AContext);

  { Check if the class has it's own serialization code }
  InternalGetInterface(AValue, ISerializable, Pointer(LSerializable));

  { Select the actual class type }
  if AValue <> nil then
    LClass := AValue.ClassType
  else
    LClass := TClass(T);

  { Open or create a new scope }
  if AContext.StartClassType(AInfo, LClass, TObject(AValue)) then
  begin
    if LSerializable <> nil then
      LSerializable.Serialize(TSerializationData.Create(AContext))
    else
      SerProcessStructClass(TSerializationGuts.Create(AContext.GetTypeInformation(LClass.ClassInfo), AContext, nil), TObject(AValue), true);

    { Force nil to the interface so we don't call _Release on it }
    Pointer(LSerializable) := nil;

    { Close the block }
    AContext.EndComplexType();
  end;
end;

function TClassType<T>.GenerateHashCode(const AValue: T): NativeInt;
begin
  if AValue = nil then
    Result := 0
  else
    Result := AValue.GetHashCode();
end;

function TClassType<T>.Management: TTypeManagement;
begin
  if FMustKillClass then
    Result := tmManual
  else
    Result := tmNone;
end;

procedure TClassType<T>.SetShouldCleanup(const ShouldCleanup: Boolean);
begin
  FMustKillClass := ShouldCleanup;
end;

function TClassType<T>.GetString(const AValue: T): String;
begin
  if AValue = nil then
    Result := ''
  else
    Result := AValue.ToString();
end;

procedure TClassType<T>.InternalGetInterface(const AObject: TObject; const AIID: TGUID; var AOut: Pointer);
var
  LIntfEntry: PInterfaceEntry;

begin
  AOut := nil;

  { Nothing on nil object }
  if AObject = nil then
    Exit;

  { Obtain the interface entry }
  LIntfEntry := AObject.GetInterfaceEntry(AIID);

  { If there is such an interface and it has an Object offset, get it }
  if (LIntfEntry <> nil) and (LIntfEntry^.IOffset <> 0) then
    AOut := Pointer(NativeUInt(AObject) + NativeUInt(LIntfEntry^.IOffset));

  { Note: No AddRef is performed since we have no idea if the object
    has ref cont > 0 already! We're only using the "pseudo-intf" entry }
end;

{ TVariantType }

function TVariantType.Compare(const AValue1, AValue2: Variant): NativeInt;
begin
  Result := 0;

  try
    { Try to compare }
    if AValue1 < AValue2 then
       Result := -1
    else if AValue1 > AValue2 then
       Result := 1;

  finally
  end;
end;

constructor TVariantType.Create;
begin
  inherited;
  FTypeFamily := tfVariant;
end;

function TVariantType.GenerateHashCode(const AValue: Variant): NativeInt;
var
  S: String;
begin
  try
    { Try to get hash code }
    S := AValue;
    Exit(BinaryHash(Pointer(S), Length(S) * SizeOf(Char)));
  finally
  end;

  Result := -1;
end;

function TVariantType.GetString(const AValue: Variant): String;
begin
  try
    Result := AValue;
  except
    begin
      Result := '';
    end;
  end;
end;

function TVariantType.TryConvertFromVariant(const AValue: Variant; out ORes: Variant): Boolean;
begin
  { Variant assignment }
  ORes := AValue;
  Result := true;
end;

function TVariantType.TryConvertToVariant(const AValue: Variant; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

{ TShortStringType }

function TShortStringType.Compare(const AValue1, AValue2: ShortString): NativeInt;
begin
  if FCaseInsensitive then
    Result := CompareText(String(AValue1), String(AValue2))
  else
    Result := CompareStr(String(AValue1), String(AValue2));
end;

constructor TShortStringType.Create;
begin
  inherited;

  FTypeFamily := tfString;
  FCaseInsensitive := false;
end;

constructor TShortStringType.Create(const CaseInsensitive: Boolean);
begin
  inherited Create();

  FTypeFamily := tfString;
  FCaseInsensitive := CaseInsensitive;
end;

function TShortStringType.GenerateHashCode(const AValue: ShortString): NativeInt;
var
  Cpy: String;
begin
  { Call the generic hasher }
  if Length(AValue) > 0 then
  begin
    if not FCaseInsensitive then
      Result := BinaryHash(@AValue[1], Length(AValue) * SizeOf(Char))
    else
    begin
      Cpy := UpperCase(String(AValue));
      Result := BinaryHash(@Cpy[1], Length(AValue) * SizeOf(Char));
    end;
  end
  else
     Result := 0;
end;

function TShortStringType.GetString(const AValue: ShortString): String;
begin
  Result := String(AValue);
end;

function TShortStringType.TryConvertFromVariant(const AValue: Variant; out ORes: ShortString): Boolean;
begin
  { Variant type-cast }
  try
    ORes := ShortString(AValue);
  except
    Exit(false);
  end;

  Result := true;
end;

function TShortStringType.TryConvertToVariant(const AValue: ShortString; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TShortStringType.DoDeserialize(const AInfo: TValueInfo; out AValue: ShortString; const AContext: IDeserializationContext);
var
  LValue: AnsiString;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := ShortString(LValue);
end;

procedure TShortStringType.DoSerialize(const AInfo: TValueInfo; const AValue: ShortString; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AnsiString(AValue));
end;

{ TBinaryType }

function TBinaryType.Compare(const AValue1, AValue2: Pointer): NativeInt;
begin
  Result := BinaryCompare(AValue1, AValue2, FTypeSize);
end;

constructor TBinaryType.Create;
begin
  ExceptionHelper.Throw_DefaultConstructorNotAllowedError();
end;

constructor TBinaryType.Create(const Size: NativeUInt);
begin
  FTypeSize := Size;
  FTypeFamily := tfUnknown;
end;

procedure TBinaryType.DoDeserialize(const AInfo: TValueInfo; out AValue: Pointer; const AContext: IDeserializationContext);
var
  LName: String;
  LPtr: Pointer;
begin
  { For capture purposes }
  LName := AInfo.Name;
  LPtr := AValue;

  { Deserialize from binary }
  AContext.GetBinaryValue(AInfo,
    function(const ASize: NativeUInt): Pointer
    begin
      { Size mismatch? }
      if ASize <> FTypeSize then
        ExceptionHelper.Throw_BinaryValueSizeMismatch(LName, Name);

      { Supply the pointer }
      Result := LPtr;
    end
  );
end;

procedure TBinaryType.DoSerialize(const AInfo: TValueInfo; const AValue: Pointer; const AContext: ISerializationContext);
begin
  AContext.AddBinaryValue(AInfo, AValue, FTypeSize);
end;

function TBinaryType.GenerateHashCode(const AValue: Pointer): NativeInt;
begin
  Result := BinaryHash(AValue, FTypeSize);
end;

function TBinaryType.GetString(const AValue: Pointer): String;
begin
  Result := Format(SByteCount, [FTypeSize]);
end;

{ T3BytesType }

function T3BytesType.Compare(const AValue1, AValue2: __T3BytesRec): NativeInt;
begin
  Result := BinaryCompare(@AValue1, @AValue2, 3);
end;

constructor T3BytesType.Create;
begin
  inherited;
  FTypeFamily := tfUnknown;
end;

function T3BytesType.GenerateHashCode(const AValue: __T3BytesRec): NativeInt;
begin
  Result := BinaryHash(@AValue, 3);
end;

function T3BytesType.GetString(const AValue: __T3BytesRec): String;
begin
  Result := Format(SByteCount, [3]);
end;


{ TDynArrayType }

function TDynArrayType.Compare(const AValue1, AValue2: TBoundArray): NativeInt;
var
  Len, LenDiff: NativeInt;
begin
  { Protect from NILs }
  if (AValue1 = nil) and (AValue2 = nil) then
    Exit(0)
  else if (AValue1 = nil) then
    Exit(-1)
  else if (AValue2 = nil) then
    Exit(1);

  { And continue }
  Len     := DynArraySize(AValue1);
  LenDiff := Len - DynArraySize(AValue2);

  if LenDiff < 0 then
     Inc(Len, LenDiff);

  Result := BinaryCompare(AValue1, AValue2, FSizeOfElement * NativeUInt(Len));

  if Result = 0 then
     Result := LenDiff;
end;


constructor TDynArrayType.Create;
begin
  ExceptionHelper.Throw_DefaultConstructorNotAllowedError();
end;

constructor TDynArrayType.Create(const SizeOfElement: NativeUInt; const TypeInfo: PTypeInfo);
begin
  FSizeOfElement := SizeOfElement;
  FArrayTypeInfo := TypeInfo;
  FTypeFamily    := tfArray;
end;

procedure TDynArrayType.DoDeserialize(const AInfo: TValueInfo; out AValue: TBoundArray; const AContext: IDeserializationContext);
var
  LLength: NativeUInt;
  LElemType: TRttiType;
begin
  LElemType := GetElementType(AContext, AInfo);

  { Open a new array/check the ref }
  if AContext.ExpectArrayType(AInfo, TValueInfo.Create(LElemType), LLength, Pointer(AValue)) then
  begin
    { Set the new length of the array }
    DynArraySetLength(Pointer(AValue), FTypeInfo, 1, @LLength);

    try
      { The check is required since 0-length arrays tend to be NIL! }
      if LLength > 0 then
      begin
        { Register reference }
        AContext.RegisterReference(Pointer(AValue));

        { The actual deserialization of elements }
        SerProcessFields(TSerializationGuts.Create(LElemType, nil, AContext), TValueInfo.Indexed(), LLength, Pointer(AValue), false);
      end;

      { Close block }
      AContext.EndComplexType();
    except
      { On exception make sure we free the memory! }
      LLength := 0;
      DynArraySetLength(Pointer(AValue), FTypeInfo, 1, @LLength);
      Pointer(AValue) := nil;

      { re-raise }
      raise;
    end;
  end;
end;

procedure TDynArrayType.DoSerialize(const AInfo: TValueInfo; const AValue: TBoundArray; const AContext: ISerializationContext);
var
  LElemType: TRttiType;
  LLength: NativeUInt;
begin
  LElemType := GetElementType(AContext, AInfo);
  LLength := NativeUInt(DynArraySize(AValue));

  { Call internal helper }
  if AContext.StartArrayType(AInfo, TValueInfo.Create(LElemType), LLength, Pointer(AValue)) then
  begin
    SerProcessFields(TSerializationGuts.Create(LElemType, AContext, nil), TValueInfo.Indexed(), LLength, Pointer(AValue), true);

    { Close block }
    AContext.EndComplexType();
  end;
end;

function TDynArrayType.GenerateHashCode(const AValue: TBoundArray): NativeInt;
begin
  Result := BinaryHash(AValue, FSizeOfElement * NativeUInt(DynArraySize(AValue)));
end;

function TDynArrayType.GetElementType(const AContext: IContext; const AInfo: TValueInfo): TRttiType;
var
  LElemType: TRttiType;
  LType: TRttiType;
{$IFDEF BUG_RTTI_ELEMENTTYPE}
  LElemPP: PPTypeInfo;
{$ENDIF}
begin
  LType := AContext.GetTypeInformation(FTypeInfo);

  { Exit if no rtti }
  if (LType = nil) or not (LType is TRttiDynamicArrayType) then
    ExceptionHelper.Throw_WrongOrMissingRTTI(AInfo.Name, Name);

{$IFDEF BUG_RTTI_ELEMENTTYPE}
  LElemPP := GetTypeData(FTypeInfo)^.elType;

  if (LElemPP = nil) or (LElemPP^ = nil) then
    LElemType := TRttiDynamicArrayType(LType).ElementType
  else
    LElemType := AContext.GetTypeInformation(LElemPP^);
{$ELSE}
  LElemType := TRttiDynamicArrayType(LType).ElementType;
{$ENDIF}

  { Inline types are not serializable }
  if (LElemType = nil) then
    ExceptionHelper.Throw_WrongOrMissingRTTI(AInfo.Name, Name);

  Result := LElemType;
end;

function TDynArrayType.GetString(const AValue: TBoundArray): String;
begin
  Result := Format(SElementCount, [DynArraySize(AValue)]);
end;

function TDynArrayType.TryConvertFromVariant(const AValue: Variant; out ORes: TBoundArray): Boolean;
begin
  try
    { Transform the variant array into a normal array }
    DynArrayFromVariant(Pointer(ORes), AValue, FTypeInfo);
    Result := true;
  except
    Result := false;
  end;
end;

function TDynArrayType.TryConvertToVariant(const AValue: TBoundArray; out ORes: Variant): Boolean;
begin
  try
    { Try to convert the dynamic array to the variant }
    DynArrayToVariant(ORes, AValue, FTypeInfo);
    Result := true;
  except
    Result := false;
  end;
end;

{ TAnsiCharType }

function TAnsiCharType.Compare(const AValue1, AValue2: AnsiChar): NativeInt;
begin
  Result := (Ord(AValue1) - Ord(AValue2));
end;

constructor TAnsiCharType.Create;
begin
  inherited;
  FTypeFamily := tfCharacter;
end;

function TAnsiCharType.GenerateHashCode(const AValue: AnsiChar): NativeInt;
begin
  Result := Ord(AValue);
end;

function TAnsiCharType.GetString(const AValue: AnsiChar): String;
begin
  Result := String(AValue);
end;

function TAnsiCharType.TryConvertFromVariant(const AValue: Variant; out ORes: AnsiChar): Boolean;
var
  S: AnsiString;
begin
  { Variant type-cast }
  try
    S := AnsiString(AValue);

    if S = '' then
      Exit(false);

    ORes := S[1];
  except
    Exit(false);
  end;

  Result := true;
end;

function TAnsiCharType.TryConvertToVariant(const AValue: AnsiChar; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TAnsiCharType.DoDeserialize(const AInfo: TValueInfo; out AValue: AnsiChar; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TAnsiCharType.DoSerialize(const AInfo: TValueInfo; const AValue: AnsiChar; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TWideCharType }

function TWideCharType.Compare(const AValue1, AValue2: WideChar): NativeInt;
begin
  Result := (NativeInt(AValue1) - NativeInt(AValue2));
end;

constructor TWideCharType.Create;
begin
  inherited;

  FTypeFamily := tfCharacter;
end;

function TWideCharType.GenerateHashCode(const AValue: WideChar): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TWideCharType.GetString(const AValue: WideChar): String;
begin
  Result := AValue;
end;

function TWideCharType.TryConvertFromVariant(const AValue: Variant; out ORes: WideChar): Boolean;
var
  S: WideString;
begin
  { Variant type-cast }
  try
    S := AValue;

    if S = '' then
      Exit(false);

    ORes := S[1];
  except
    Exit(false);
  end;

  Result := true;
end;

function TWideCharType.TryConvertToVariant(const AValue: WideChar; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TWideCharType.DoDeserialize(const AInfo: TValueInfo; out AValue: WideChar; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TWideCharType.DoSerialize(const AInfo: TValueInfo; const AValue: WideChar; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TManualType<T> }

function TManualType<T>.Management: TTypeManagement;
begin
  Result := tmManual;
end;

{ TMagicType<T> }

function TMagicType<T>.Management: TTypeManagement;
begin
  Result := tmCompiler;
end;

{ TBooleanType }

function TBooleanType.Compare(const AValue1, AValue2: Boolean): NativeInt;
begin
  Result := NativeInt(AValue1) - NativeInt(AValue2);
end;

constructor TBooleanType.Create;
begin
  inherited;
  FTypeFamily := tfBoolean;
end;

function TBooleanType.GenerateHashCode(const AValue: Boolean): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TBooleanType.GetString(const AValue: Boolean): String;
begin
  Result := BoolToStr(AValue, true);
end;

function TBooleanType.TryConvertFromVariant(const AValue: Variant; out ORes: Boolean): Boolean;
begin
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TBooleanType.TryConvertToVariant(const AValue: Boolean; out ORes: Variant): Boolean;
begin
  ORes := AValue;
  Result := true;
end;

procedure TBooleanType.DoDeserialize(const AInfo: TValueInfo; out AValue: Boolean; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TBooleanType.DoSerialize(const AInfo: TValueInfo; const AValue: Boolean; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TByteBoolType }

function TByteBoolType.Compare(const AValue1, AValue2: ByteBool): NativeInt;
begin
  Result := NativeInt(Byte(AValue1)) - NativeInt(Byte(AValue2));
end;

constructor TByteBoolType.Create;
begin
  inherited;
  FTypeFamily := tfBoolean;
end;

function TByteBoolType.GenerateHashCode(const AValue: ByteBool): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TByteBoolType.GetString(const AValue: ByteBool): String;
begin
  Result := BoolToStr(AValue, true);
end;

function TByteBoolType.TryConvertFromVariant(const AValue: Variant; out ORes: ByteBool): Boolean;
begin
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TByteBoolType.TryConvertToVariant(const AValue: ByteBool; out ORes: Variant): Boolean;
begin
  ORes := AValue;
  Result := true;
end;

procedure TByteBoolType.DoDeserialize(const AInfo: TValueInfo; out AValue: ByteBool; const AContext: IDeserializationContext);
var
  LValue: Boolean;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := LValue;
end;

procedure TByteBoolType.DoSerialize(const AInfo: TValueInfo; const AValue: ByteBool; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TWordBoolType }

function TWordBoolType.Compare(const AValue1, AValue2: WordBool): NativeInt;
begin
  Result := NativeInt(Word(AValue1)) - NativeInt(Word(AValue2));
end;

constructor TWordBoolType.Create;
begin
  inherited;
  FTypeFamily := tfBoolean;
end;

function TWordBoolType.GenerateHashCode(const AValue: WordBool): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TWordBoolType.GetString(const AValue: WordBool): String;
begin
  Result := BoolToStr(AValue, true);
end;

function TWordBoolType.TryConvertFromVariant(const AValue: Variant; out ORes: WordBool): Boolean;
begin
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TWordBoolType.TryConvertToVariant(const AValue: WordBool; out ORes: Variant): Boolean;
begin
  ORes := AValue;
  Result := true;
end;

procedure TWordBoolType.DoDeserialize(const AInfo: TValueInfo; out AValue: WordBool; const AContext: IDeserializationContext);
var
  LValue: Boolean;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := LValue;
end;

procedure TWordBoolType.DoSerialize(const AInfo: TValueInfo; const AValue: WordBool; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TLongBoolType }

function TLongBoolType.Compare(const AValue1, AValue2: LongBool): NativeInt;
begin
  Result := NativeInt(Cardinal(AValue2)) - NativeInt(Cardinal(AValue1));
end;

constructor TLongBoolType.Create;
begin
  inherited;
  FTypeFamily := tfBoolean;
end;

function TLongBoolType.GenerateHashCode(const AValue: LongBool): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TLongBoolType.GetString(const AValue: LongBool): String;
begin
  Result := BoolToStr(AValue, true);
end;

function TLongBoolType.TryConvertFromVariant(const AValue: Variant; out ORes: LongBool): Boolean;
begin
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TLongBoolType.TryConvertToVariant(const AValue: LongBool; out ORes: Variant): Boolean;
begin
  ORes := AValue;
  Result := true;
end;

procedure TLongBoolType.DoDeserialize(const AInfo: TValueInfo; out AValue: LongBool; const AContext: IDeserializationContext);
var
  LValue: Boolean;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := LValue;
end;

procedure TLongBoolType.DoSerialize(const AInfo: TValueInfo; const AValue: LongBool; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TDateType }

function TDateType.Compare(const AValue1, AValue2: TDate): NativeInt;
begin
  Result := CompareDate(AValue1, AValue2);
end;

constructor TDateType.Create;
begin
  inherited;
  FTypeFamily := tfDate;
end;

function TDateType.GenerateHashCode(const AValue: TDate): NativeInt;
{$IF SizeOf(TDate) <= SizeOf(NativeInt)}
var
  LongOp: NativeInt absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  LongOp : array[0..1] of Integer absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TDateType.GetString(const AValue: TDate): String;
begin
  Result := DateToStr(AValue);
end;

function TDateType.TryConvertFromVariant(const AValue: Variant; out ORes: TDate): Boolean;
begin
  { May fail }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TDateType.TryConvertToVariant(const AValue: TDate; out ORes: Variant): Boolean;
begin
  { Simple assignment }
  ORes := AValue;
  Result := true;
end;

procedure TDateType.DoDeserialize(const AInfo: TValueInfo; out AValue: TDate; const AContext: IDeserializationContext);
var
  LValue: TDateTime;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := DateOf(LValue);
end;

procedure TDateType.DoSerialize(const AInfo: TValueInfo; const AValue: TDate; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, TDateTime(AValue));
end;

{ TTimeType }

function TTimeType.Compare(const AValue1, AValue2: TTime): NativeInt;
begin
  Result := CompareTime(AValue1, AValue2);
end;

constructor TTimeType.Create;
begin
  inherited;
  FTypeFamily := tfDate;
end;

function TTimeType.GenerateHashCode(const AValue: TTime): NativeInt;
{$IF SizeOf(TTime) <= SizeOf(NativeInt)}
var
  LongOp: NativeInt absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  LongOp : array[0..1] of Integer absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TTimeType.GetString(const AValue: TTime): String;
begin
  Result := TimeToStr(AValue);
end;

function TTimeType.TryConvertFromVariant(const AValue: Variant; out ORes: TTime): Boolean;
begin
  { May fail }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TTimeType.TryConvertToVariant(const AValue: TTime; out ORes: Variant): Boolean;
begin
  { Simple assignment }
  ORes := AValue;
  Result := true;
end;

procedure TTimeType.DoDeserialize(const AInfo: TValueInfo; out AValue: TTime; const AContext: IDeserializationContext);
var
  LValue: TDateTime;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := TimeOf(LValue);
end;

procedure TTimeType.DoSerialize(const AInfo: TValueInfo; const AValue: TTime; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, TDateTime(AValue));
end;

{ TDateTimeType }

function TDateTimeType.Compare(const AValue1, AValue2: TDateTime): NativeInt;
begin
  Result := CompareDateTime(AValue1, AValue2);
end;

constructor TDateTimeType.Create;
begin
  inherited;
  FTypeFamily := tfDate;
end;

function TDateTimeType.GenerateHashCode(const AValue: TDateTime): NativeInt;
{$IF SizeOf(TDateTime) <= SizeOf(NativeInt)}
var
  LongOp: NativeInt absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  LongOp : array[0..1] of Integer absolute AValue;
begin
  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TDateTimeType.GetString(const AValue: TDateTime): String;
begin
  Result := DateTimeToStr(AValue);
end;

function TDateTimeType.TryConvertFromVariant(const AValue: Variant; out ORes: TDateTime): Boolean;
begin
  { May fail }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function TDateTimeType.TryConvertToVariant(const AValue: TDateTime; out ORes: Variant): Boolean;
begin
  { Simple assignment }
  ORes := AValue;
  Result := true;
end;

procedure TDateTimeType.DoDeserialize(const AInfo: TValueInfo; out AValue: TDateTime; const AContext: IDeserializationContext);
begin
  AContext.GetValue(AInfo, AValue);
end;

procedure TDateTimeType.DoSerialize(const AInfo: TValueInfo; const AValue: TDateTime; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue);
end;

{ TUCS4CharType }

function TUCS4CharType.Compare(const AValue1, AValue2: UCS4Char): NativeInt;
begin
  if AValue1 > AValue2 then
    Result := 1
  else if AValue1 < AValue2 then
    Result := -1
  else
    Result := 0;
end;

constructor TUCS4CharType.Create;
begin
  inherited;
  FTypeFamily := tfCharacter;
end;

function TUCS4CharType.GenerateHashCode(const AValue: UCS4Char): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TUCS4CharType.GetString(const AValue: UCS4Char): String;
begin
  Result := ConvertFromUtf32(AValue);
end;

function TUCS4CharType.TryConvertFromVariant(const AValue: Variant; out ORes: UCS4Char): Boolean;
var
  S: String;
begin
  { Variant type-cast }
  try
    S := AValue;
    ORes := ConvertToUtf32(S, 1);
  except
    Exit(false);
  end;

  Result := true;
end;

function TUCS4CharType.TryConvertToVariant(const AValue: UCS4Char; out ORes: Variant): Boolean;
begin
  ORes := ConvertFromUtf32(AValue);
  Result := true;
end;

procedure TUCS4CharType.DoDeserialize(const AInfo: TValueInfo; out AValue: UCS4Char; const AContext: IDeserializationContext);
var
  LValue: String;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := ConvertToUtf32(LValue, 1);
end;

procedure TUCS4CharType.DoSerialize(const AInfo: TValueInfo; const AValue: UCS4Char; const AContext: ISerializationContext);
begin
  { Transform into an UTF16 string }
  AContext.AddValue(AInfo, ConvertFromUtf32(AValue));
end;

{ TUCS4StringType }

function TUCS4StringType.Compare(const AValue1, AValue2: UCS4String): NativeInt;
begin
  if FCaseInsensitive then
    Result := CompareText(UCS4StringToUnicodeString(AValue1), UCS4StringToUnicodeString(AValue2))
  else
    Result := CompareStr(UCS4StringToUnicodeString(AValue1), UCS4StringToUnicodeString(AValue2));
end;

constructor TUCS4StringType.Create(const CaseInsensitive: Boolean);
begin
  inherited Create();

  FTypeFamily := tfString;
  FCaseInsensitive := CaseInsensitive;
end;

constructor TUCS4StringType.Create;
begin
  inherited;

  FTypeFamily := tfString;
  FCaseInsensitive := false;
end;

function TUCS4StringType.GenerateHashCode(const AValue: UCS4String): NativeInt;
var
  Cpy: String;
begin
  { Call the generic hasher }
  if Length(AValue) > 0 then
  begin
    if not FCaseInsensitive then
      Result := BinaryHash(Pointer(AValue), Length(AValue) * SizeOf(UCS4Char))
    else
    begin
      Cpy := UpperCase(UCS4StringToUnicodeString(AValue));
      Result := BinaryHash(Pointer(Cpy), Length(AValue) * SizeOf(Char));
    end;
  end
  else
     Result := 0;
end;

function TUCS4StringType.GetString(const AValue: UCS4String): String;
begin
  Result := UCS4StringToUnicodeString(AValue);
end;

function TUCS4StringType.TryConvertFromVariant(const AValue: Variant; out ORes: UCS4String): Boolean;
begin
  { May fail! }
  try
    ORes := UnicodeStringToUCS4String(AValue);
  except
    Exit(false);
  end;

  Result := true;
end;

function TUCS4StringType.TryConvertToVariant(const AValue: UCS4String; out ORes: Variant): Boolean;
begin
  ORes := UCS4StringToUnicodeString(AValue);
  Result := true;
end;

procedure TUCS4StringType.DoDeserialize(const AInfo: TValueInfo; out AValue: UCS4String; const AContext: IDeserializationContext);
var
  LValue: String;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := UnicodeStringToUCS4String(LValue);
end;

procedure TUCS4StringType.DoSerialize(const AInfo: TValueInfo; const AValue: UCS4String; const AContext: ISerializationContext);
begin
  { Transform into an UTF-16 string }
  AContext.AddValue(AInfo, UCS4StringToUnicodeString(AValue));
end;

{ TUTF8StringType }


function TUTF8StringType.Compare(const AValue1, AValue2: UTF8String): NativeInt;
begin
  if FCaseInsensitive then
    Result := CompareText(String(AValue1), String(AValue2))
  else
    Result := CompareStr(String(AValue1), String(AValue2));
end;

constructor TUTF8StringType.Create;
begin
  inherited;

  FTypeFamily := tfString;
  FCaseInsensitive := false;
end;

constructor TUTF8StringType.Create(const CaseInsensitive: Boolean);
begin
  inherited Create();

  FTypeFamily := tfString;
  FCaseInsensitive := CaseInsensitive;
end;

function TUTF8StringType.GenerateHashCode(const AValue: UTF8String): NativeInt;
var
  Cpy: String;
begin
  { Call the generic hasher }
  if Length(AValue) > 0 then
  begin
    if not FCaseInsensitive then
      Result := BinaryHash(Pointer(AValue), Length(AValue) * SizeOf(Char))
    else
    begin
      Cpy := UpperCase(String(AValue));
      Result := BinaryHash(Pointer(Cpy), Length(AValue) * SizeOf(Char));
    end;
  end
  else
     Result := 0;
end;

function TUTF8StringType.GetString(const AValue: UTF8String): String;
begin
  Result := String(AValue);
end;

function TUTF8StringType.TryConvertFromVariant(const AValue: Variant; out ORes: UTF8String): Boolean;
begin
  { Variant type-cast }
  try
    ORes := UTF8String(AValue);
  except
    Exit(false);
  end;

  Result := true;
end;

function TUTF8StringType.TryConvertToVariant(const AValue: UTF8String; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

procedure TUTF8StringType.DoDeserialize(const AInfo: TValueInfo; out AValue: UTF8String; const AContext: IDeserializationContext);
var
  LValue: String;
begin
  AContext.GetValue(AInfo, LValue);
  AValue := UTF8String(LValue);
end;

procedure TUTF8StringType.DoSerialize(const AInfo: TValueInfo; const AValue: UTF8String; const AContext: ISerializationContext);
begin
  { Transform into a UTF-16 string }
  AContext.AddValue(AInfo, string(AValue));
end;

{ TRawByteStringType }

function TRawByteStringType.Compare(const AValue1, AValue2: RawByteString): NativeInt;
var
  Len, LenDiff: NativeInt;
begin
  Len     := Length(AValue1);
  LenDiff := Len - Length(AValue2);

  if LenDiff < 0 then
     Inc(Len, LenDiff);

  Result := BinaryCompare(@(AValue1[1]), @(AValue2[1]), Len);

  if Result = 0 then
     Result := LenDiff;
end;

constructor TRawByteStringType.Create;
begin
  inherited;
  FTypeFamily := tfUnknown;
end;

function TRawByteStringType.GenerateHashCode(const AValue: RawByteString): NativeInt;
begin
  Result := BinaryHash(@(AValue[1]), Length(AValue));
end;

function TRawByteStringType.GetString(const AValue: RawByteString): String;
begin
  Result := Format(SElementCount, [Length(AValue)]);
end;

function TRawByteStringType.TryConvertFromVariant(const AValue: Variant; out ORes: RawByteString): Boolean;
var
  LBytes: TBytes;
  LLen: NativeInt;
begin
  try
    LBytes := AValue;
    LLen := Length(LBytes);
    SetLength(ORes, LLen);

    if LLen > 0 then
      Move(LBytes[0], ORes[1], LLen);

    Result := true;
  except
    Result := false;
  end;
end;

function TRawByteStringType.TryConvertToVariant(const AValue: RawByteString; out ORes: Variant): Boolean;
var
  LBytes: TBytes;
  LLen: NativeInt;
begin
  try
    LLen := Length(AValue);
    SetLength(LBytes, LLen);

    if LLen > 0 then
      Move(AValue[1], LBytes[0], LLen);

    ORes := LBytes;

    Result := true;
  except
    Result := false;
  end;
end;

procedure TRawByteStringType.DoDeserialize(const AInfo: TValueInfo; out AValue: RawByteString; const AContext: IDeserializationContext);
var
  LName: String;
  LValue: RawByteString;
begin
  LName := AInfo.Name;

  AContext.GetBinaryValue(AInfo,
    function(const ASize: NativeUInt): Pointer
    begin
      { Setup the raw byte string}
      SetLength(LValue, ASize);

      { Supply the pointer }
      Result := Addr(LValue[1]);
    end
  );

  { Finally set the out pointer }
  AValue := LValue;
end;

procedure TRawByteStringType.DoSerialize(const AInfo: TValueInfo; const AValue: RawByteString; const AContext: ISerializationContext);
begin
  { Write as binary block! }
  AContext.AddBinaryValue(AInfo, AValue[1], Length(AValue));
end;

{ TType }

class function TType.CreateCharType(const Size: NativeUInt): Pointer;
begin
  case Size of
     1: Result := TAnsiCharType.Create();
     2: Result := TWideCharType.Create();
     else
         Result := TBinaryType.Create(Size);
  end;
end;

class function TType.CreateBinaryType(const Size: NativeUInt): Pointer;
begin
  case Size of
     1: Result := TByteType.Create();
     2: Result := TWordType.Create();
     3: Result := T3BytesType.Create();
     4: Result := TCardinalType.Create();
     else
         Result := TBinaryType.Create(Size);
  end;
end;

class function TType.CreateIntegerType(const OrdinalType: TOrdType): Pointer;
begin
  Result := nil;

  case OrdinalType of
     otSByte: Result := TShortIntType.Create();
     otUByte: Result := TByteType.Create();
     otSWord: Result := TSmallIntType.Create();
     otUWord: Result := TWordType.Create();
     otSLong: Result := TIntegerType.Create();
     otULong: Result := TCardinalType.Create();
  end;
end;

class function TType.CreateFloatType(const FloatType: TFloatType): Pointer;
begin
  Result := nil;

  case FloatType of
     ftSingle  : Result := TSingleType.Create();
     ftDouble  : Result := TDoubleType.Create();
     ftExtended: Result := TExtendedType.Create();
     ftComp    : Result := TCompType.Create();
     ftCurr    : Result := TCurrencyType.Create();
  end;
end;

class function TType.CreateStringType(const Kind: TTypeKind): Pointer;
begin
  Result := nil;

  case Kind of
     tkString  : Result := TShortStringType.Create();
     tkLString : Result := TAnsiStringType.Create();
     tkWString : Result := TWideStringType.Create();
     tkUString : Result := TUnicodeStringType.Create();
  end;
end;

class function TType.CreateClassType(): Pointer;
begin
  { Hack around the class restriction, The real tyoe info will be added later }
  Result := TClassType<TObject>.Create();
end;

class function TType.CreateCustomType(const TypeInfo: PTypeInfo): Pointer;
var
  PInfo: PTypeInfo;
  Dict: TInternalDictionary;
begin
  Result := nil;
  PInfo := TypeInfo;

  { Check for nil }
  if PInfo = nil then
    ExceptionHelper.Throw_CustomTypeHasNoRTTI();

  MonitorEnter(FCustomTypes);

  { Type-cast to what wee need }
  Dict := TInternalDictionary(FCustomTypes);

  try
    { Check if this class is not registered yet }
    if Dict.ContainsKey(PInfo) then
      Result := TType(TTypeClass(Dict[PInfo]).Create())
    else if PInfo^.Kind = tkClass then
    begin
      { Did not find a direct match. For classes, try ancestry }
      while true do
      begin
        { Find the parent }
        PInfo := GetParentTypeInfo(PInfo);

        { Not a valid parent? break off the loop }
        if PInfo = nil then
          Exit;

        { If there is such a type class registered, use it! }
        if Dict.ContainsKey(PInfo) then
          Exit(TType(TTypeClass(Dict[PInfo]).Create()));
      end;
    end;
  finally
    { Do not forget to release the monitor lock always! }
    MonitorExit(FCustomTypes);
  end;
end;

class function TType.CreateVariantType(): Pointer;
begin
  Result := TVariantType.Create();
end;

function TType.Family: TTypeFamily;
begin
  Result := FTypeFamily;
end;

class function TType.CreateInt64Type(const TypeData: PTypeData): Pointer;
begin
  if TypeData^.MaxInt64Value > TypeData^.MinInt64Value then
     Result := TInt64Type.Create()
  else
     Result := TUInt64Type.Create();
end;

class function TType.CreateDefault(const TypeInfo: PTypeInfo; const TypeSize: NativeUInt;
  const AllowCustom: Boolean; const AArrayClass, ARecordClass: TTypeClass): Pointer;
var
  ResultClass: TType;
  TypeData: PTypeData;
begin
  ResultClass := nil;

  { No type information associated - try a different solution }
  if TypeInfo = nil then
  begin
    ResultClass := CreateBinaryType(TypeSize);
    Result := ResultClass;
    ResultClass.SetTypeInfo(TypeInfo, TypeSize);

    Exit;
  end;

  { Check maybe we have a cusm registered one }
  if AllowCustom and (TypeInfo <> nil) then
  begin
    ResultClass := CreateCustomType(TypeInfo);
    Result := ResultClass;

    if Result <> nil then
    begin
      ResultClass.SetTypeInfo(TypeInfo, TypeSize);
      Exit;
    end;
  end;

  { Retrieve type data }
  TypeData := GetTypeData(TypeInfo);

  case TypeInfo^.Kind of
    tkUnknown:
    begin
      ResultClass := CreateBinaryType(TypeSize);
      ResultClass.FTypeFamily := tfUnknown;
    end;

    tkInteger:     ResultClass := CreateIntegerType(TypeData^.OrdType);
    tkEnumeration: ResultClass := CreateIntegerType(TypeData^.OrdType);
    tkFloat:       ResultClass := CreateFloatType(TypeData^.FloatType);
    tkSet:         ResultClass := CreateBinaryType(TypeSize);
    tkClass:       ResultClass := CreateClassType();
    tkProcedure:   ResultClass := TProcedureType.Create();
    tkMethod:      ResultClass := TMethodType.Create();

    tkChar, tkWChar:
      ResultClass := CreateCharType(TypeSize);

    tkString, tkLString, tkWString, tkUString:
      ResultClass := CreateStringType(TypeInfo^.Kind);

    tkVariant:     ResultClass := CreateVariantType();
    tkArray:       ResultClass := AArrayClass.Create();
    tkRecord:      ResultClass := ARecordClass.Create();
    tkInterface:   ResultClass := TInterfaceType.Create();
    tkInt64:       ResultClass := CreateInt64Type(TypeData);
    tkDynArray:    ResultClass := CreateDynamicArrayType(TypeData^.elSize, TypeInfo);
    tkClassRef:    ResultClass := TMetaclassType.Create();
    tkPointer:     ResultClass := TPointerType.Create();
  end;

  if ResultClass = nil then
     ExceptionHelper.Throw_NoDefaultTypeError(UTF8ToString(TypeInfo^.Name));

  ResultClass.SetTypeInfo(TypeInfo, TypeSize);
  Result := ResultClass;
end;

class function TType.CreateDynamicArrayType(const ElementSize: NativeUInt; const TypeInfo: PTypeInfo): Pointer;
begin
  Result := TDynArrayType.Create(ElementSize, TypeInfo);
end;

function TType.GetExtension(const AExtender: TTypeExtender): TTypeExtension;
begin
  if AExtender = nil then
    ExceptionHelper.Throw_ArgumentNilError('AExtender');

  { Try to obtain an extension for my-self }
  Result := AExtender.CreateExtensionFor(Self);
end;

class function TType.GetParentTypeInfo(const ClassInfo: PTypeInfo): PTypeInfo;
var
  TypeData: PTypeData;
begin
  Result := nil;

  { Exit on nil class info }
  if ClassInfo = nil then
    Exit;

  TypeData := GetTypeData(ClassInfo);

  { Exit on nil type data }
  if (TypeData = nil) or (TypeData^.ParentInfo = nil) then
    Exit;

  Result := TypeData^.ParentInfo^;
end;

class function TType.IsClassStructSerializable(const AType: TRttiType): Boolean;
var
  LAttr: TCustomAttribute;
begin
  if AType <> nil then
    for LAttr in AType.GetAttributes() do
      if LAttr is NonSerialized then
        Exit(false);

  Result := true;
end;

function TType.Management: TTypeManagement;
begin
  Result := FManagement;
end;

function TType.Name: String;
begin
  { Simple call, as usual }
  if FTypeInfo <> nil then
    Result := GetTypeName(FTypeInfo)
  else
    Result := '';
end;

procedure TType.RestrictTo(const AllowedFamilies: TTypeFamilySet);
begin
  { Restrict the family }
  if not (Family in AllowedFamilies) then
    ExceptionHelper.Throw_RuntimeTypeRestrictionFailed(Name);
end;

class procedure TType.SerProcessFields(const AGuts: TSerializationGuts; const AInfo: TValueInfo;
  const ACount: NativeUInt; const APtrToField: Pointer; const ASerialize: Boolean);
var
  LCustom: TType;
  LInfo: TValueInfo;
  LNext: PByte;
  I: NativeInt;
  LCommon: IContext;
  LHandle: PTypeInfo;
  LKind: TTypeKind;
  LSize: NativeUInt;
begin
  { Check for registered types. Handle them specially. }
  LInfo := AInfo;
  LNext := APtrToField;

  if ASerialize then
    LCommon := AGuts.FInContext
  else
    LCommon := AGuts.FOutContext;

  LHandle := AGuts.FType.Handle;
  LKind := AGuts.FType.TypeKind;
  LSize := AGuts.FType.TypeSize;

  LCustom := LCommon.GetTypeObject(LHandle, function(): TObject begin
    { Obtain a custom type }
    Result := CreateCustomType(LHandle);

    { Obtain the normal type only of not and array or record }
    if (Result = nil) and not (LKind in [tkArray, tkRecord]) then
      Result := CreateDefault(LHandle, LSize, false, nil, nil);
  end) as TType;

  { Do the standard drill if we have a type object }
  if LCustom <> nil then
  begin
    for I := 0 to ACount - 1 do
    begin
      if ASerialize then
        LCustom.InternalSerialize(LInfo, LNext, AGuts.FInContext)
      else
        LCustom.InternalDeserialize(LInfo, LNext, AGuts.FOutContext);

      LNext := Ptr(NativeUInt(LNext) + NativeUInt(AGuts.FType.TypeSize));
    end;
  end else if (LKind = tkArray) then
  { Special case for arrays! We cannot reference generics here so we're just going to
    program the logic here instead on the generic TRecordType<T> or TArrayType<T> }
  begin
    for I := 0 to ACount - 1 do
    begin
      SerProcessStaticArray(AGuts, LInfo, LNext, ASerialize);
      LNext := Ptr(NativeUInt(LNext) + NativeUInt(AGuts.FType.TypeSize));
    end;
  end else if (LKind = tkRecord) then
  begin
    { Check if the structure is serializable }
    if not IsClassStructSerializable(AGuts.FType) then
      ExceptionHelper.Throw_MarkedUnserializable(LInfo.Name, AGuts.FType.Name);

    for I := 0 to ACount - 1 do
    begin
      { Start composite }
      if ASerialize then
        AGuts.FInContext.StartRecordType(LInfo)
      else
        AGuts.FOutContext.ExpectRecordType(LInfo);

      { Serializa/Deserialize }
      SerProcessStructClass(AGuts, LNext, ASerialize);

      { End composite }
      if ASerialize then
        AGuts.FInContext.EndComplexType()
      else
        AGuts.FOutContext.EndComplexType();

      LNext := Ptr(NativeUInt(LNext) + NativeUInt(AGuts.FType.TypeSize));
    end;
  end else
    ASSERT(false, 'Type object not obtained! Should never get here!');
end;

class procedure TType.SerProcessStaticArray(const AGuts: TSerializationGuts; const AInfo: TValueInfo;
  const APtrToFirst: Pointer; const ASerialize: Boolean);
var
  LElemType: TRttiType;
  LLength, LStoredLen: NativeUInt;
begin
  LElemType := TRttiArrayType(AGuts.FType).ElementType;

  { Inline types are not serializable }
  if (LElemType = nil) then
    ExceptionHelper.Throw_WrongOrMissingRTTI(AInfo.Name, AGuts.FType.Name);

  LLength := TRttiArrayType(AGuts.FType).TotalElementCount;

  { Open a new block }
  if ASerialize then
    AGuts.FInContext.StartArrayType(AInfo, TValueInfo.Create(LElemType), LLength)
  else
  begin
    AGuts.FOutContext.ExpectArrayType(AInfo, TValueInfo.Create(LElemType), LStoredLen);

    if LStoredLen <> LLength then; // TODO: Fail on different array lengths

  end;

  { Spill you guts in! Or out :) }
  SerProcessFields(TSerializationGuts.Create(LElemType, AGuts.FInContext, AGuts.FOutContext), TValueInfo.Indexed(),
    LLength, APtrToFirst, ASerialize);

  { Close Block }
  if ASerialize then
    AGuts.FInContext.EndComplexType()
  else
    AGuts.FOutContext.EndComplexType();
end;

class procedure TType.SerProcessStructClass(const AGuts: TSerializationGuts; const APtrToInstance: Pointer; const ASerialize: Boolean);
var
  LFieldType: TRttiType;
  LField, LLocalField: TRttiField;
  LOffset: Pointer;
  LName: String;
begin
  { Special case for nil instances }
  if APtrToInstance = nil then
    Exit;

  { Iterate over all fields and serialize them }
  for LField in AGuts.FType.GetFields() do
  begin
    if Skippable(LField) then
      continue;

    LFieldType := LField.FieldType;

    { This field has no RTTI for its type! Skip it }
    if LFieldType = nil then
      ExceptionHelper.Throw_WrongOrMissingRTTI(LField.Name, AGuts.FType.Name);

    { Default }
    LName := LField.Name;

    { For classes, Check for duplicate named fields }
    if (AGuts.FType.TypeKind = tkClass) then
    begin
      { Lookup the field by it's name and. This way we will obtain the field "closer"
        to the derived class. }
      LLocalField := AGuts.FType.GetField(LField.Name);

      { If the found field is actually not the one we are inspecting, it means that
        the field's name designates two fields (one coming from an acestor). In this case
        prefix the name with the fully qualified ancestor name (since more classes can have
        same name and different units);
      }
      if LLocalField <> LField then
        LName := TRttiInstanceType(LField.Parent).DeclaringUnitName + '.' + LField.Parent.Name + '.' + LField.Name
    end;

    { The offset of the field in the "instance" }
    LOffset := Ptr(NativeUInt(LField.Offset) + NativeUInt(APtrToInstance));

    { Serialize! Also place the name label. Use attributes to get the name }
    SerProcessFields(TSerializationGuts.Create(LFieldType, AGuts.FInContext, AGuts.FOutContext),
      TValueInfo.Create(LField, LName), 1, LOffset, ASerialize);
  end;
end;

procedure TType.SetTypeInfo(const ATypeInfo: PTypeInfo; const ATypeSize: NativeUInt);
begin
  { Defaults, are overriden where necessary }
  FTypeInfo := ATypeInfo;
  FTypeSize := ATypeSize;

  { Decide on the management }
  if (FTypeInfo <> nil) and IsManaged(FTypeInfo) then
    FManagement := tmCompiler
  else
    FManagement := tmNone;
end;

function TType.Size: NativeUInt;
begin
  Result := FTypeSize;
end;

class function TType.Skippable(const AField: TRttiField): Boolean;
var
  LAttr: TCustomAttribute;
begin
  { Check for [NonSerialized] attribute }
  for LAttr in AField.GetAttributes() do
    if LAttr is NonSerialized then
      Exit(true);

  Exit(false);
end;

function TType.TypeInfo: PTypeInfo;
begin
  Result := FTypeInfo;
end;

{ TSuppressedWrapperType<T> }

procedure TSuppressedWrapperType<T>.Cleanup(var AValue: T);
begin
  if (FAllowCleanup) or (FType.Management = tmCompiler) then
    FType.Cleanup(AValue);
end;

function TSuppressedWrapperType<T>.Management: TTypeManagement;
var
  LMngmt: TTypeManagement;
begin
  Result := FType.Management;

  { Only dissalow manual cleanup }
  if (not FAllowCleanup) and (Result = tmManual) then
    Result := tmNone;
end;

{ TObjectWrapperType<T> }

procedure TObjectWrapperType<T>.Cleanup(var AValue: T);
begin
  if FAllowCleanup then
    FreeAndNil(AValue);
end;

function TObjectWrapperType<T>.Management: TTypeManagement;
begin
  if FAllowCleanup then
    Result := tmManual
  else
    Result := tmNone;
end;

{ TMaybeObjectWrapperType<T> }

procedure TMaybeObjectWrapperType<T>.Cleanup(var AValue: T);
begin
  { Only free if it's an object! }
  if (FAllowCleanup) and (TypeInfo <> nil) and (TypeInfo^.Kind = tkClass) then
    FreeAndNil(TObject(AValue));
end;

function TMaybeObjectWrapperType<T>.Management: TTypeManagement;
begin
  if FAllowCleanup then
    Result := tmManual
  else
    Result := inherited Management();
end;

{ TTypeExtender }

constructor TTypeExtender.Create;
begin
  { Create an internal dictionary to hold the Type -> Extension relationship }
  FExtensions := TExtensionDictionary.Create();
end;

function TTypeExtender.CreateExtensionFor(const AObject: TObject): TTypeExtension;
var
  Dict: TExtensionDictionary;
  TheClass: TTypeExtensionClass;
begin
  Result := nil;

  { Grab monitor! }
  MonitorEnter(FExtensions);

  try
    Dict := TExtensionDictionary(FExtensions);

    if Dict.TryGetValue(AObject.ClassType, Pointer(TheClass)) then
      Result := TheClass.Create();
  finally
    { Make sure we're always getting here }
    MonitorExit(FExtensions);
  end;
end;

destructor TTypeExtender.Destroy;
begin
  { Destroy the internal object }
  FExtensions.Free;

  inherited;
end;

procedure TTypeExtender.Register<T>(const AExtension: TTypeExtensionClass);
var
  GotType: TType<T>;
  Dict: TExtensionDictionary;
begin
  { Obtain a type support class }
  GotType := TType<T>.CreateDefault(true);

  { Grab monitor! }
  MonitorEnter(FExtensions);

  try
    Dict := TExtensionDictionary(FExtensions);

    if Dict.ContainsKey(GotType.ClassType) then
      ExceptionHelper.Throw_TypeExtensionAlreadyRegistered(GotType.Name);

    Dict.Add(GotType.ClassType, AExtension);
  finally
    { Make sure we're always getting here }
    MonitorExit(FExtensions);
  end;
end;

procedure TTypeExtender.Unregister<T>;
var
  GotType: TType<T>;
  Dict: TExtensionDictionary;
begin
  { Obtain a type support class }
  GotType := TType<T>.CreateDefault(true);

  { Grab monitor! }
  MonitorEnter(FExtensions);

  try
    Dict := TExtensionDictionary(FExtensions);

    if not Dict.ContainsKey(GotType.ClassType) then
      ExceptionHelper.Throw_TypeExtensionNotYetRegistered(GotType.Name);

    Dict.Remove(GotType.ClassType);
  finally
    { Make sure we're always getting here }
    MonitorExit(FExtensions);
  end;
end;

{ TTypeExtension }

constructor TTypeExtension.Create;
begin
  { Do nothing here! }
end;


{ TInterfaceType }

function TInterfaceType.Compare(const AValue1, AValue2: IInterface): NativeInt;
begin
  if NativeUInt(AValue1) > NativeUInt(AValue2) then
    Result := 1
  else if NativeUInt(AValue1) < NativeUInt(AValue2) then
    Result := -1
  else
    Result := 0;
end;

constructor TInterfaceType.Create;
begin
  inherited;
  FTypeFamily := tfInterface;
end;

function TInterfaceType.GenerateHashCode(const AValue: IInterface): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TInterfaceType.GetString(const AValue: IInterface): String;
begin
  Result := Format(SAddress, [NativeUInt(AValue)]);
end;

{ TPointerType }

function TPointerType.Compare(const AValue1, AValue2: Pointer): NativeInt;
begin
  if NativeUInt(AValue1) > NativeUInt(AValue2) then
     Result := 1
  else if NativeUInt(AValue1) < NativeUInt(AValue2) then
     Result := -1
  else
     Result := 0;
end;

constructor TPointerType.Create;
begin
  inherited;
  FCanBeSerializedVerified := false;
  FTypeFamily := tfPointer;
end;

function TPointerType.GenerateHashCode(const AValue: Pointer): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TPointerType.GetElementType(const AContext: IContext; const AInfo: TValueInfo): TRttiType;
var
  LElementType: TRttiType;
  LType: TRttiType;
begin
  { Obtain type information for the element }
  LType := AContext.GetTypeInformation(FTypeInfo);

  if (LType <> nil) then
    LElementType := TRttiPointerType(LType).ReferredType
  else
    LElementType := nil;

  { Serialize/Deserialize if supported }
  if (LElementType <> nil) and (LElementType.TypeKind = tkRecord) then
  begin
    { Verify if the record can be serialized }
    if not FCanBeSerializedVerified then
    begin
      FCanBeSerializedVerified := true;
      FCanBeSerialized := IsClassStructSerializable(LElementType);
    end;

    { If the struct cannot be serialized (not marked as such) fail! }
    if not FCanBeSerialized then
      ExceptionHelper.Throw_MarkedUnserializable(AInfo.Name, Name);
  end else
    ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);

  { ... }
  Result := LElementType;
end;

function TPointerType.GetString(const AValue: Pointer): String;
begin
  Result := Format(SAddress, [NativeUInt(AValue)]);
end;

function TPointerType.TryConvertFromVariant(const AValue: Variant; out ORes: Pointer): Boolean;
begin
  Result := true;

  try
    ORes := Pointer(NativeUInt(AValue));
  except
    Result := false;
  end;
end;

function TPointerType.TryConvertToVariant(const AValue: Pointer; out ORes: Variant): Boolean;
begin
  Result := true;
  ORes := NativeUInt(AValue);
end;


procedure TPointerType.DoDeserialize(const AInfo: TValueInfo; out AValue: Pointer; const AContext: IDeserializationContext);
var
  LElementType: TRttiType;
begin
  { Obtain the element type }
  LElementType := GetElementType(AContext, AInfo);

  { And now do deserialize }
  if AContext.ExpectRecordType(AInfo, AValue) then
  begin
    { Allocate enough memory for the value and initialize it }
    GetMem(AValue, LElementType.TypeSize);
    InitializeArray(AValue, LElementType.Handle, 1);

    try
      { Deserialize }
      AContext.RegisterReference(AValue);
      SerProcessStructClass(TSerializationGuts.Create(LElementType, nil, AContext), AValue, false);
      AContext.EndComplexType();
    except
      { Kill the pointer instance }
      FinalizeArray(AValue, LElementType.Handle, 1);
      FreeMem(AValue);

      AValue := nil;

      { Re-raise }
      raise;
    end;
  end;
end;

procedure TPointerType.DoSerialize(const AInfo: TValueInfo; const AValue: Pointer; const AContext: ISerializationContext);
var
  LElementType: TRttiType;
begin
  { Obtain the element type }
  LElementType := GetElementType(AContext, AInfo);

  if AContext.StartRecordType(AInfo, AValue) then
  begin
    SerProcessStructClass(TSerializationGuts.Create(LElementType, AContext, nil), AValue, true);
    AContext.EndComplexType();
  end;
end;

{ TMetaclassType }

function TMetaclassType.Compare(const AValue1, AValue2: TClass): NativeInt;
begin
  if NativeUInt(AValue1) > NativeUInt(AValue2) then
     Result := 1
  else if NativeUInt(AValue1) < NativeUInt(AValue2) then
     Result := -1
  else
     Result := 0;
end;

constructor TMetaclassType.Create;
begin
  inherited;
  FTypeFamily := tfClassReference;
end;

procedure TMetaclassType.DoDeserialize(const AInfo: TValueInfo;
  out AValue: TClass; const AContext: IDeserializationContext);
begin
  { Read the value }
  AContext.GetValue(AInfo, AValue);
end;

procedure TMetaclassType.DoSerialize(const AInfo: TValueInfo;
  const AValue: TClass; const AContext: ISerializationContext);
begin
  { Add the value }
  AContext.AddValue(AInfo, AValue);
end;

function TMetaclassType.GenerateHashCode(const AValue: TClass): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TMetaclassType.GetString(const AValue: TClass): String;
begin
  Result := AValue.ClassName;
end;

{ TArrayType<T> }

function TArrayType<T>.Compare(const AValue1, AValue2: T): NativeInt;
begin
  Result := BinaryCompare(@AValue1, @AValue2, SizeOf(T));
end;

constructor TArrayType<T>.Create;
begin
  inherited;

  FTypeFamily := tfArray;
  FIsMagic := IsManaged(TypeInfo);
end;

procedure TArrayType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext);
begin
  { Call internal method }
  SerProcessStaticArray(
    TSerializationGuts.Create(AContext.GetTypeInformation(TypeInfo), nil, AContext),
    AInfo, @AValue, false);
end;

procedure TArrayType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext);
begin
  { Call internal method }
  SerProcessStaticArray(
    TSerializationGuts.Create(AContext.GetTypeInformation(TypeInfo), AContext, nil),
    AInfo, @AValue, true);
end;

function TArrayType<T>.GenerateHashCode(const AValue: T): NativeInt;
begin
  Result := BinaryHash(@AValue, SizeOf(T));
end;

function TArrayType<T>.GetString(const AValue: T): String;
begin
  Result := Format(SByteCount, [SizeOf(T)]);
end;

function TArrayType<T>.Management: TTypeManagement;
begin
  if FIsMagic then
    Result := tmCompiler
  else
    Result := tmNone;
end;

{ TRecordType<T> }

procedure TRecordType<T>.CheckSerializable(const AContext: IContext; const AInfo: TValueInfo);
begin
  { Verify if the record can be serialized }
  if not FCanBeSerializedVerified then
  begin
    FCanBeSerializedVerified := true;
    FCanBeSerialized := IsClassStructSerializable(AContext.GetTypeInformation(FTypeInfo));
  end;

  { If the struct cannot be serialized (not marked as such) fail! }
  if not FCanBeSerialized then
    ExceptionHelper.Throw_MarkedUnserializable(AInfo.Name, Name);
end;

function TRecordType<T>.Compare(const AValue1, AValue2: T): NativeInt;
begin
  Result := BinaryCompare(@AValue1, @AValue2, SizeOf(T));
end;

constructor TRecordType<T>.Create;
begin
  inherited;

  FTypeFamily := tfRecord;
  FIsMagic := IsManaged(TypeInfo);
  FCanBeSerializedVerified := false;
end;

procedure TRecordType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext);
begin
  { Make sure that this type can be serialized }
  CheckSerializable(AContext, AInfo);

  { Open a new block }
  AContext.ExpectRecordType(AInfo);

  { Call internal helper }
  SerProcessStructClass(TSerializationGuts.Create(AContext.GetTypeInformation(TypeInfo), nil, AContext), @AValue, false);

  AContext.EndComplexType();
end;

procedure TRecordType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext);
begin
  { Make sure that this type can be serialized }
  CheckSerializable(AContext, AInfo);

  { Open a new block }
  AContext.StartRecordType(AInfo);

  { Call internal helper }
  SerProcessStructClass(TSerializationGuts.Create(AContext.GetTypeInformation(TypeInfo), AContext, nil), @AValue, true);

  AContext.EndComplexType();
end;

function TRecordType<T>.GenerateHashCode(const AValue: T): NativeInt;
begin
  Result := BinaryHash(@AValue, SizeOf(T));
end;

function TRecordType<T>.GetString(const AValue: T): String;
begin
  Result := Format(SByteCount, [SizeOf(T)]);
end;

function TRecordType<T>.Management: TTypeManagement;
begin
  if FIsMagic then
    Result := tmCompiler
  else
    Result := tmNone;
end;

{ TMethodType }

function TMethodType.Compare(const AValue1, AValue2: __TMethod): NativeInt;
var
  LL, LR: TMethod;
begin
  LL := TMethod(AValue1); LR := TMethod(AValue2);
  Result := BinaryCompare(@LL, @LR, SizeOf(__TMethod));
end;

constructor TMethodType.Create;
begin
  inherited;

  FTypeFamily := tfMethod;
end;

function TMethodType.GenerateHashCode(const AValue: __TMethod): NativeInt;
var
  L1: TMethod;
begin
  L1 := TMethod(AValue);
  Result := BinaryHash(@L1, SizeOf(__TMethod));
end;

function TMethodType.GetString(const AValue: __TMethod): String;
begin
  Result := Format(SAddress, [NativeUInt(TMethod(AValue).Code)]);
end;

{ TProcedureType }

function TProcedureType.Compare(const AValue1, AValue2: Pointer): NativeInt;
begin
  if NativeUInt(AValue1) > NativeUInt(AValue2) then
     Result := 1
  else if NativeUInt(AValue1) < NativeUInt(AValue2) then
     Result := -1
  else
     Result := 0;
end;

constructor TProcedureType.Create;
begin
  inherited;
  FTypeFamily := tfMethod;
end;

function TProcedureType.GenerateHashCode(const AValue: Pointer): NativeInt;
begin
  Result := NativeInt(AValue);
end;

function TProcedureType.GetString(const AValue: Pointer): String;
begin
  Result := Format(SAddress, [NativeUInt(AValue)]);
end;

function TProcedureType.TryConvertFromVariant(const AValue: Variant; out ORes: Pointer): Boolean;
begin
  Result := true;

  try
    ORes := Pointer(NativeUInt(AValue));
  except
    Result := false;
  end;
end;

function TProcedureType.TryConvertToVariant(const AValue: Pointer; out ORes: Variant): Boolean;
begin
  Result := true;
  ORes := NativeUInt(AValue);
end;

{ TType.TSerializationGuts }

constructor TType.TSerializationGuts.Create(const AType: TRttiType;
  const AInContext: ISerializationContext;
  const AOutContext: IDeserializationContext);
begin
  FType := AType;
  FInContext := AInContext;
  FOutContext := AOutContext;
end;

{ TWrapperType<T> }

procedure TWrapperType<T>.Cleanup(var AValue: T);
begin
  { Call inner type }
  FType.Cleanup(AValue);
end;

function TWrapperType<T>.Compare(const AValue1, AValue2: T): NativeInt;
begin
  { Call inner type }
  Result := FType.Compare(AValue1, AValue2);
end;

constructor TWrapperType<T>.Create(const AType: IType<T>);
begin
  inherited Create();

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Store the type }
  FType := AType;
end;

constructor TWrapperType<T>.Create;
begin
  { Do not allow default constructor }
  ExceptionHelper.Throw_DefaultConstructorNotAllowedError();
end;

function TWrapperType<T>.Family: TTypeFamily;
begin
  { Call the inner type }
  Result := FType.Family;
end;

function TWrapperType<T>.GenerateHashCode(const AValue: T): NativeInt;
begin
  { Call the inner type }
  Result := FType.GenerateHashCode(AValue);
end;

function TWrapperType<T>.GetString(const AValue: T): String;
begin
  { Call the inner type }
  Result := FType.GetString(AValue);
end;

function TWrapperType<T>.Management: TTypeManagement;
begin
  { Call the inner type! }
  Result := FType.Management();
end;

function TWrapperType<T>.Name: String;
begin
  { Call the inner type }
  Result := FType.Name;
end;

function TWrapperType<T>.Size: NativeUInt;
begin
  { Call the inner type }
  Result := FType.Size;
end;

function TWrapperType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: T): Boolean;
begin
  { Call the inner type }
  Result := FType.TryConvertFromVariant(AValue, ORes);
end;

function TWrapperType<T>.TryConvertToVariant(const AValue: T; out ORes: Variant): Boolean;
begin
  { Call the inner type }
  Result := FType.TryConvertToVariant(AValue, ORes);
end;

procedure TWrapperType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: T; const AContext: IDeserializationContext);
begin
  FType.Deserialize(AInfo, AValue, AContext);
end;

procedure TWrapperType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: T; const AContext: ISerializationContext);
begin
  FType.Serialize(AInfo, AValue, AContext);
end;

function TWrapperType<T>.TypeInfo: PTypeInfo;
begin
  { Call the inner type }
  Result := FType.TypeInfo;
end;

{ TComparerWrapperType<T> }

function TComparerWrapperType<T>.Compare(const AValue1, AValue2: T): NativeInt;
begin
  Result := FComparer(AValue1, AValue2);
end;

constructor TComparerWrapperType<T>.Create(const AType: IType<T>);
begin
  { Do not allow this constructor }
  ExceptionHelper.Throw_DefaultConstructorNotAllowedError();
end;

constructor TComparerWrapperType<T>.Create(const AType: IType<T>;
  const AComparer: TCompareOverride<T>; const AHasher: THashOverride<T>);
begin
  inherited Create(AType);

  if not Assigned(AComparer) then
    ExceptionHelper.Throw_ArgumentNilError('AComparer');

  if not Assigned(AHasher) then
    ExceptionHelper.Throw_ArgumentNilError('AHasher');

  { Internals }
  FComparer := AComparer;
  FHasher := AHasher;
end;

function TComparerWrapperType<T>.GenerateHashCode(const AValue: T): NativeInt;
begin
  Result := FHasher(AValue);
end;

{ TStringType }

class function TStringType.ANSI(const ACaseInsensitive: Boolean): IType<AnsiString>;
begin
  Result := TAnsiStringType.Create(ACaseInsensitive);
end;

class function TStringType.Short(const ACaseInsensitive: Boolean): IType<ShortString>;
begin
  Result := TShortStringType.Create(ACaseInsensitive);
end;

class function TStringType.UCS4(const ACaseInsensitive: Boolean): IType<UCS4String>;
begin
  Result := TUCS4StringType.Create(ACaseInsensitive);
end;

class function TStringType.Unicode(const ACaseInsensitive: Boolean): IType<UnicodeString>;
begin
  Result := TUnicodeStringType.Create(ACaseInsensitive);
end;

class function TStringType.UTF8(const ACaseInsensitive: Boolean): IType<UTF8String>;
begin
  Result := TUTF8StringType.Create(ACaseInsensitive);
end;

class function TStringType.Wide(const ACaseInsensitive: Boolean): IType<WideString>;
begin
  Result := TWideStringType.Create(ACaseInsensitive);
end;

initialization
  { Create the custom type support holder }
  TType.FCustomTypes := TCorePointerDictionary.Create();

  { Register all system types }
  TType<Boolean>.Register(TBooleanType);
  TType<ByteBool>.Register(TByteBoolType);
  TType<WordBool>.Register(TWordBoolType);
  TType<LongBool>.Register(TLongBoolType);
  TType<TDate>.Register(TDateType);
  TType<TTime>.Register(TTimeType);
  TType<TDateTime>.Register(TDateTimeType);
  TType<OleVariant>.Register(TVariantType);
  TType<UCS4Char>.Register(TUCS4CharType);
  TType<UCS4String>.Register(TUCS4StringType);
  TType<UTF8String>.Register(TUTF8StringType);
  TType<RawByteString>.Register(TRawByteStringType);

finalization
  { Unregister all system types }
  TType<Boolean>.Unregister();
  TType<ByteBool>.Unregister();
  TType<WordBool>.Unregister();
  TType<LongBool>.Unregister();
  TType<TDate>.Unregister();
  TType<TTime>.Unregister();
  TType<TDateTime>.Unregister();
  TType<OleVariant>.Unregister();
  TType<UCS4Char>.Unregister();
  TType<UCS4String>.Unregister();
  TType<UTF8String>.Unregister();
  TType<RawByteString>.Unregister();

  { Free the type support holder and the intf list }
  FreeAndNil(TType.FCustomTypes);
end.
