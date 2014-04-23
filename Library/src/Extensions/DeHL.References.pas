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

{$I ../DeHL.Defines.inc}
unit DeHL.References;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Serialization,
     DeHL.Exceptions,
     DeHL.Types;
type
  ///  <summary>Auto-free support for objects.</summary>
  ///  <remarks>A scoped reference performs automatic freeing for enclosed objects. Once a object is stored in
  ///  a scoped reference, it is guaranteed to be released when the reference goes out of scope.</remarks>
  Scoped<T: class> = record
  { Interfaces }
  private type
    IHold = interface;

    IGuard = interface
      function GetHold(): Scoped<T>.IHold;
    end;

    IHold = interface
      function AcquireWeak: Scoped<T>.IGuard;
      function AcquireShared: Scoped<T>.IGuard;
      procedure ReleaseShared;
      function IsAlive: Boolean;
      function UseCount: NativeUInt;
    end;

    THold = class(TInterfacedObject, IHold)
    private
      FInstance: T;
      FSharedRefCount: Integer;

    public
      constructor Create(const AInstance: T);
       destructor Destroy; override;

      function AcquireWeak: Scoped<T>.IGuard;
      function AcquireShared: Scoped<T>.IGuard;
      procedure ReleaseShared;
      function IsAlive: Boolean;
      function UseCount: NativeUInt;
    end;

    TSharedGuard = class(TInterfacedObject, IGuard)
    private
      FHold: IHold;

    public
      constructor Create(const AHold: Scoped<T>.IHold);
      destructor Destroy; override;

      function GetHold(): Scoped<T>.IHold;
    end;

    TWeakGuard = class(TInterfacedObject, IGuard)
    private
      FHold: IHold;

    public
      constructor Create(const AHold: IHold);

      function GetHold(): IHold;
    end;

  private
    FInstance: T;
    FGuard: IGuard;

    function GetIsValid: Boolean; inline;
    function GetRef: T; inline;

    { Type bashing }
    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a scoped reference with a given object.</summary>
    ///  <param name="AInstance">The instance to be placed into a scoped reference.</param>
    ///  <remarks>If <paramref name="AInstance"/> is <c>nil</c> an "invalid" scoped reference is created.</remarks>
    constructor Create(const AInstance: T);

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AValue">The value to put into a scoped reference.</param>
    ///  <returns>The scoped reference.</returns>
    class operator Implicit(const AInstance: T): Scoped<T>; inline; static;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AValue">The scoped reference to convert.</param>
    ///  <returns>The enclosed object. If this scoped reference is not valid, <c>nil</c> is returned.</returns>
    class operator Implicit(const AScoped: Scoped<T>): T; inline; static;

    ///  <summary>Specifies whether the scoped reference is "valid".</summary>
    ///  <returns><c>True</c> if the reference contains a valid object; <c>False</c> otherwise.</returns>
    ///  <remarks>A scoped reference can only be invalid if the constructor was called with a <c>nil</c> value.</remarks>
    property IsValid: Boolean read GetIsValid;

    ///  <summary>Returns the object reference.</summary>
    ///  <returns>The contained object or <c>nil</c> if the reference is not "valid".</returns>
    property Ref: T read GetRef;
  end;

  //
  //  Weak Reference
  //
  Weak<T: class> = record
  private
    FInstance: T;
    FGuard: Scoped<T>.IGuard;

    function GetIsValid: Boolean; inline;
    function GetUseCount: NativeUInt; inline;

    { Type bashing }
    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Specifies whether the weak reference is "valid".</summary>
    ///  <returns><c>True</c> if the reference contains a valid object; <c>False</c> otherwise.</returns>
    ///  <remarks>A weak reference can become "invalid" is all shared references to the same object
    ///  went out of scope and the object was destroyed. An "invalid" weak reference can be converted only to an "invalid" shared
    ///  reference.</remarks>
    property IsValid: Boolean read GetIsValid;

    ///  <summary>Specifies the number of shared references to the object.</summary>
    ///  <returns>A positive number specifying the number of shared references held to the object.</returns>
    ///  <remarks>An "invalid" weak reference has <c>0</c> use count.</remarks>
    property UseCount: NativeUInt read GetUseCount;
  end;

  ///  <summary>Shared reference to an object.</summary>
  ///  <remarks>This type represents a shared reference to an object that required automatic freeing.</remarks>
  Shared<T: class> = record
  private
    FInstance: T;
    FGuard: Scoped<T>.IGuard;

    function GetIsValid: Boolean; inline;
    function GetRef: T; inline;
    function GetUseCount: NativeUInt; inline;

    { Type bashing }
    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a shared reference with a given object.</summary>
    ///  <param name="AInstance">The instance to be placed into a shared reference.</param>
    ///  <remarks>If <paramref name="AInstance"/> is <c>nil</c> an "invalid" shared reference is created.</remarks>
    constructor Create(const AInstance: T); overload;

    ///  <summary>Converts a weak container to a shared container.</summary>
    ///  <param name="AWeak">The weak container from which a shared one needs to be created.</param>
    ///  <remarks>If <paramref name="AWeak"/> is an "invalid" weak container, an "invalid" shared container is created.</remarks>
    constructor Create(const AWeak: Weak<T>); overload;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AInstance">The object to put into a shared reference.</param>
    ///  <returns>The shared reference.</returns>
    class operator Implicit(const AInstance: T): Shared<T>; inline; static;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AShared">The shared reference to convert.</param>
    ///  <returns>The enclosed object. <c>nil</c> is returned if the reference is "invalid".</returns>
    class operator Implicit(const AShared: Shared<T>): T; inline; static;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AShared">The shared reference to convert.</param>
    ///  <returns>A weak reference to the same enclosed object. An "invalid" weak reference
    ///  created if this shared reference is "invalid".</returns>
    class operator Implicit(const AShared: Shared<T>): Weak<T>; inline; static;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="AWeak">The weak reference to convert.</param>
    ///  <returns>A shared reference to the same enclosed object. An "invalid" shared reference
    ///  is created if the weak reference is "invalid".</returns>
    class operator Implicit(const AWeak: Weak<T>): Shared<T>; inline; static;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <returns>A weak reference to the same enclosed object. An "invalid" weak reference
    ///  created if this shared reference is "invalid".</returns>
    function ToWeak: Weak<T>;

    ///  <summary>Specifies whether the shared reference is "valid".</summary>
    ///  <returns><c>True</c> if the reference contains a valid object; <c>False</c> otherwise.</returns>
    ///  <remarks>A shared reference can only be invalid if the constructor was called with a <c>nil</c> value.</remarks>
    property IsValid: Boolean read GetIsValid;

    ///  <summary>Specifies the number of shared references to the object.</summary>
    ///  <returns>A positive number specifying the number of shared references held to the object.</returns>
    ///  <remarks>An "invalid" shared reference has <c>0</c> use count.</remarks>
    property UseCount: NativeUInt read GetUseCount;

    ///  <summary>Returns the object reference.</summary>
    ///  <returns>The contained object or <c>nil</c> if the reference is not "valid".</returns>
    property Ref: T read GetRef;
  end;

  ///  <summary>A type that exposes only static methods useful for creating and manipulating
  ///  reference types.</summary>
  Reference = record
  private type
    { Scoped Support }
    TScopedType<T: class> = class(TRecordType<Scoped<T>>)
    private
      FType: IType<T>;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Scoped<T>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Scoped<T>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const AType: IType<T>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Scoped<T>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Scoped<T>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Scoped<T>): String; override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Scoped<T>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Scoped<T>): Boolean; override;
    end;

    { Weak Support }
    TWeakType<T: class> = class(TRecordType<Weak<T>>)
    private
      FType: IType<T>;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Weak<T>;
        const AContext: ISerializationContext); override;
      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Weak<T>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const AType: IType<T>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Weak<T>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Weak<T>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Weak<T>): String; override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Weak<T>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Weak<T>): Boolean; override;
    end;

    { Shared Support }
    TSharedType<T: class> = class(TRecordType<Shared<T>>)
    private
      FType: IType<T>;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Shared<T>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Shared<T>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const AType: IType<T>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Shared<T>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Shared<T>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Shared<T>): String; override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Shared<T>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Shared<T>): Boolean; override;
    end;

  public
    ///  <summary>Initializes a shared reference with a given object.</summary>
    ///  <param name="AInstance">The instance to be placed into a shared reference.</param>
    ///  <returns>A new shared reference.</returns>
    ///  <remarks>If <paramref name="AInstance"/> is <c>nil</c> an "invalid" shared reference is created.</remarks>
    class function Shared<T: class>(const AInstance: T): Shared<T>; static; inline;

    ///  <summary>Initializes a scoped reference with a given object.</summary>
    ///  <param name="AInstance">The instance to be placed into a scoped reference.</param>
    ///  <returns>A new scoped reference.</returns>
    ///  <remarks>If <paramref name="AInstance"/> is <c>nil</c> an "invalid" scoped reference is created.</remarks>
    class function Scoped<T: class>(const AInstance: T): Scoped<T>; static; inline;

    ///  <summary>Returns a type class that describes a scoped reference of a given type.</summary>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.References|Scoped&lt;T&gt;">DeHL.References.Scoped&lt;T&gt;</see> type.</returns>
    class function GetScopedType<T: class>(): IType<Scoped<T>>; overload; static;

    ///  <summary>Returns a type class that describes a scoped reference of a given type.</summary>
    ///  <param name="AType">The type class describing the object on which the reference operates.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.References|Scoped&lt;T&gt;">DeHL.References.Scoped&lt;T&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    class function GetScopedType<T: class>(const AType: IType<T>): IType<Scoped<T>>; overload; static;

    ///  <summary>Returns a type class that describes a weak reference of a given type.</summary>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.References|Weak&lt;T&gt;">DeHL.References.Weak&lt;T&gt;</see> type.</returns>
    class function GetWeakType<T: class>(): IType<Weak<T>>; overload; static;

    ///  <summary>Returns a type class that describes a weak reference of a given type.</summary>
    ///  <param name="AType">The type class describing the object on which the reference operates.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.References|Weak&lt;T&gt;">DeHL.References.Weak&lt;T&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    class function GetWeakType<T: class>(const AType: IType<T>): IType<Weak<T>>; overload; static;

    ///  <summary>Returns a type class that describes a shared reference of a given type.</summary>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.References|Shared&lt;T&gt;">DeHL.References.Shared&lt;T&gt;</see> type.</returns>
    class function GetSharedType<T: class>(): IType<Shared<T>>; overload; static;

    ///  <summary>Returns a type class that describes a shared reference of a given type.</summary>
    ///  <param name="AType">The type class describing the object on which the reference operates.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.References|Shared&lt;T&gt;">DeHL.References.Shared&lt;T&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    class function GetSharedType<T: class>(const AType: IType<T>): IType<Shared<T>>; overload; static;
  end;

implementation
uses Windows;

{ THold<T> }

function Scoped<T>.THold.AcquireShared: IGuard;
begin
  { Create a new shared guard object, pass myself in as an interface ref.
    Then increment the shared ref count.

    Default -- NIL, since we assume that no shared refs exist anymore and thus a
    weak ref cannot generate a shared one anymore.
  }
  InterlockedIncrement(FSharedRefCount);
  Result := TSharedGuard.Create(Self);
end;

function Scoped<T>.THold.AcquireWeak: IGuard;
begin
  { No need to worry about increments or decrements here }
  Result := TWeakGuard.Create(Self);
end;

constructor Scoped<T>.THold.Create(const AInstance: T);
begin
  { Assume we're starting from a shared pointer by default! }
  FInstance := AInstance;
end;

destructor Scoped<T>.THold.Destroy;
begin
  { This one should never be non-NIL, but ... who cares }
  FInstance.Free;

  inherited;
end;

function Scoped<T>.THold.IsAlive: Boolean;
begin
  Result := (FSharedRefCount > 0);
end;

procedure Scoped<T>.THold.ReleaseShared;
begin
  { Employ my own reference counting here }
  if InterlockedDecrement(FSharedRefCount) = 0 then
    FreeAndNil(FInstance);
end;

function Scoped<T>.THold.UseCount: NativeUInt;
begin
  Result := FSharedRefCount;
end;

{ TWeakGuard<T> }

constructor Scoped<T>.TWeakGuard.Create(const AHold: IHold);
begin
  { Simply assign the interface ref }
  FHold := AHold;
end;

function Scoped<T>.TWeakGuard.GetHold: IHold;
begin
  { Return the hold reference }
  Result := FHold;
end;

{ TSharedGuard<T> }

constructor Scoped<T>.TSharedGuard.Create(const AHold: IHold);
begin
  { Simply assign the interface ref }
  FHold := AHold;
end;

destructor Scoped<T>.TSharedGuard.Destroy;
begin
  { Since this is a shared reference, make sure we're decrementing the ref count
    of the hold (to release the actual instance inside if necessary) }
  FHold.ReleaseShared;

  inherited;
end;

function Scoped<T>.TSharedGuard.GetHold: IHold;
begin
  { Simply assign the interface ref }
  Result := FHold;
end;

{ Shared<T> }

constructor Shared<T>.Create(const AInstance: T);
begin
  { Assign the actual instance, then greate a new hold object and
    acquire a shared reference to it. }
  if AInstance <> nil then
  begin
    FInstance := AInstance;
    FGuard := Scoped<T>.THold.Create(AInstance).AcquireShared();
  end else
    FGuard := nil;
end;

constructor Shared<T>.Create(const AWeak: Weak<T>);
begin
  { If the weak ref is initialized, try to acquired a shared ref }
  if AWeak.FGuard <> nil then
  begin
    FInstance := AWeak.FInstance;
    FGuard := AWeak.FGuard.GetHold().AcquireShared();
  end else
    FGuard := nil;
end;

class constructor Shared<T>.Create;
begin
  { Register custom type }
  if not TType<Shared<T>>.IsRegistered then
    TType<Shared<T>>.Register(Reference.TSharedType<T>);
end;

class destructor Shared<T>.Destroy;
begin
  { Unregister the custom type }
  if TType<Shared<T>>.IsRegistered then
    TType<Shared<T>>.Unregister();
end;

function Shared<T>.GetIsValid: Boolean;
begin
  Result := (FGuard <> nil);
end;

function Shared<T>.GetRef: T;
begin
  { ... }
  if FGuard <> nil then
    Result := FInstance
  else
    Result := nil;
end;

function Shared<T>.GetUseCount: NativeUInt;
begin
  if FGuard <> nil then
    Result := FGuard.GetHold.UseCount
  else
    Result := 0;
end;

class operator Shared<T>.Implicit(const AInstance: T): Shared<T>;
begin
  Result := Shared<T>.Create(AInstance);
end;

class operator Shared<T>.Implicit(const AShared: Shared<T>): T;
begin
  Result := AShared.GetRef;
end;

function Shared<T>.ToWeak: Weak<T>;
begin
  { If the shared ref is initialized, try to acquired a weak ref }
  if FGuard <> nil then
  begin
    Result.FInstance := FInstance;
    Result.FGuard := FGuard.GetHold().AcquireWeak();
  end else
    Result.FGuard := nil;
end;

class operator Shared<T>.Implicit(const AShared: Shared<T>): Weak<T>;
begin
  { Convert to weak }
  Result := AShared.ToWeak();
end;

class operator Shared<T>.Implicit(const AWeak: Weak<T>): Shared<T>;
begin
  { Convert to shared }
  Result := Shared<T>.Create(AWeak);
end;

{ Weak<T> }

class constructor Weak<T>.Create;
begin
  { Register custom type }
  if not TType<Weak<T>>.IsRegistered then
    TType<Weak<T>>.Register(Reference.TWeakType<T>);
end;

class destructor Weak<T>.Destroy;
begin
  { Unregister the custom type }
  if TType<Scoped<T>>.IsRegistered then
    TType<Scoped<T>>.Unregister();
end;

function Weak<T>.GetIsValid: Boolean;
begin
  Result := false;

  if FGuard <> nil then
  begin
    Result := FGuard.GetHold.IsAlive;

    { Release the local guard }
    if not Result then
      FGuard := nil;
  end;
end;

function Weak<T>.GetUseCount: NativeUInt;
begin
  if FGuard <> nil then
    Result := FGuard.GetHold.UseCount
  else
    Result := 0;
end;

{ Scoped<T> }

constructor Scoped<T>.Create(const AInstance: T);
begin
  { Assign the actual instance, then greate a new hold object and
    acquire a shared reference to it. }
  if AInstance <> nil then
  begin
    FInstance := AInstance;
    FGuard := Scoped<T>.THold.Create(AInstance).AcquireShared();
  end else
    FGuard := nil;
end;

class constructor Scoped<T>.Create;
begin
  { Register custom type }
  if not TType<Scoped<T>>.IsRegistered then
    TType<Scoped<T>>.Register(Reference.TScopedType<T>);
end;

class destructor Scoped<T>.Destroy;
begin
  { Unregister the custom type }
  if TType<Scoped<T>>.IsRegistered then
    TType<Scoped<T>>.Unregister();
end;

function Scoped<T>.GetIsValid: Boolean;
begin
  Result := (FGuard <> nil);
end;

function Scoped<T>.GetRef: T;
begin
  { ... }
  if FGuard <> nil then
    Result := FInstance
  else
    Result := nil;
end;

class operator Scoped<T>.Implicit(const AInstance: T): Scoped<T>;
begin
  Result := Scoped<T>.Create(AInstance);
end;

class operator Scoped<T>.Implicit(const AScoped: Scoped<T>): T;
begin
  Result := AScoped.GetRef;
end;

{ TScopedType<T> }

function Reference.TScopedType<T>.Compare(const AValue1, AValue2: Scoped<T>): NativeInt;
begin
  { Call the internal type }
  Result := FType.Compare(AValue1, AValue2);
end;

constructor Reference.TScopedType<T>.Create(const AType: IType<T>);
begin
  inherited Create();

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  FType := AType;
end;

procedure Reference.TScopedType<T>.DoDeserialize(const AInfo: TValueInfo;
  out AValue: Scoped<T>; const AContext: IDeserializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

procedure Reference.TScopedType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: Scoped<T>; const AContext: ISerializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

constructor Reference.TScopedType<T>.Create;
begin
  inherited;

  { Obtain the type }
  FType := TType<T>.Default;
end;

function Reference.TScopedType<T>.GenerateHashCode(const AValue: Scoped<T>): NativeInt;
begin
  { Call the internal type }
  Result := FType.GenerateHashCode(AValue);
end;

function Reference.TScopedType<T>.GetString(const AValue: Scoped<T>): String;
begin
  { Call the internal type }
  Result := FType.GetString(AValue);
end;

function Reference.TScopedType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: Scoped<T>): Boolean;
var
  LV: T;
begin
  { Use the enclosed type }
  Result := FType.TryConvertFromVariant(AValue, LV);

  if Result then
    ORes := LV;
end;

function Reference.TScopedType<T>.TryConvertToVariant(const AValue: Scoped<T>; out ORes: Variant): Boolean;
begin
  { Use the enclosed type }
  Result := FType.TryConvertToVariant(AValue, ORes);
end;

{ TWeakType<T> }

function Reference.TWeakType<T>.Compare(const AValue1, AValue2: Weak<T>): NativeInt;
begin
  { Call the internal type }
  Result := FType.Compare(Shared<T>(AValue1), Shared<T>(AValue2));
end;

constructor Reference.TWeakType<T>.Create(const AType: IType<T>);
begin
  inherited Create();

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  FType := AType;
end;

procedure Reference.TWeakType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: Weak<T>; const AContext: IDeserializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

procedure Reference.TWeakType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: Weak<T>; const AContext: ISerializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

constructor Reference.TWeakType<T>.Create;
begin
  inherited;

  { Obtain the type }
  FType := TType<T>.Default;
end;

function Reference.TWeakType<T>.GenerateHashCode(const AValue: Weak<T>): NativeInt;
begin
  { Call the internal type }
  Result := FType.GenerateHashCode(Shared<T>(AValue));
end;

function Reference.TWeakType<T>.GetString(const AValue: Weak<T>): String;
begin
  { Call the internal type }
  Result := FType.GetString(Shared<T>(AValue));
end;

function Reference.TWeakType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: Weak<T>): Boolean;
begin
  { You cannot convert to a weak ref }
  Result := false;
end;

function Reference.TWeakType<T>.TryConvertToVariant(const AValue: Weak<T>; out ORes: Variant): Boolean;
begin
  { Use the enclosed type }
  Result := FType.TryConvertToVariant(Shared<T>(AValue), ORes);
end;

{ TSharedType<T> }

function Reference.TSharedType<T>.Compare(const AValue1, AValue2: Shared<T>): NativeInt;
begin
  { Call the internal type }
  Result := FType.Compare(AValue1, AValue2);
end;

constructor Reference.TSharedType<T>.Create(const AType: IType<T>);
begin
  inherited Create();

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  FType := AType;
end;

procedure Reference.TSharedType<T>.DoDeserialize(const AInfo: TValueInfo;
  out AValue: Shared<T>; const AContext: IDeserializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

procedure Reference.TSharedType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: Shared<T>; const AContext: ISerializationContext);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AInfo.Name, Name);
end;

constructor Reference.TSharedType<T>.Create;
begin
  inherited;

  { Obtain the type }
  FType := TType<T>.Default;
end;

function Reference.TSharedType<T>.GenerateHashCode(const AValue: Shared<T>): NativeInt;
begin
  { Call the internal type }
  Result := FType.GenerateHashCode(AValue);
end;

function Reference.TSharedType<T>.GetString(const AValue: Shared<T>): String;
begin
  { Call the internal type }
  Result := FType.GetString(AValue);
end;

function Reference.TSharedType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: Shared<T>): Boolean;
var
  LV: T;
begin
  { Use the enclosed type }
  Result := FType.TryConvertFromVariant(AValue, LV);

  if Result then
    ORes := LV;
end;

function Reference.TSharedType<T>.TryConvertToVariant(const AValue: Shared<T>; out ORes: Variant): Boolean;
begin
  { Use the enclosed type }
  Result := FType.TryConvertToVariant(AValue, ORes);
end;

{ Reference }

class function Reference.GetScopedType<T>: IType<Scoped<T>>;
begin
  Result := Reference.TScopedType<T>.Create();
end;

class function Reference.GetSharedType<T>: IType<Shared<T>>;
begin
  Result := Reference.TSharedType<T>.Create();
end;

class function Reference.GetWeakType<T>: IType<Weak<T>>;
begin
  Result := Reference.TWeakType<T>.Create();
end;

class function Reference.Scoped<T>(const AInstance: T): Scoped<T>;
begin
  Result := Scoped<T>.Create(AInstance);
end;

class function Reference.Shared<T>(const AInstance: T): Shared<T>;
begin
  Result := Shared<T>.Create(AInstance);
end;

class function Reference.GetScopedType<T>(const AType: IType<T>): IType<Scoped<T>>;
begin
  Result := Reference.TScopedType<T>.Create(AType);
end;

class function Reference.GetSharedType<T>(const AType: IType<T>): IType<Shared<T>>;
begin
  Result := Reference.TSharedType<T>.Create(AType);
end;

class function Reference.GetWeakType<T>(const AType: IType<T>): IType<Weak<T>>;
begin
  Result := Reference.TWeakType<T>.Create(AType);
end;

end.
