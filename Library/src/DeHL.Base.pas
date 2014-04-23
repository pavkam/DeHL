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
unit DeHL.Base;
interface

uses
  Windows,
  SysUtils,
  Rtti,
  TypInfo;

type
{$HINTS OFF}
  ///  <summary>Base for all reference counted objects in DeHL.</summary>
  ///  <remarks><see cref="DeHL.Base|TRefCountedObject">DeHL.Base.TRefCountedObject</see> is designed to be used as a base class for all
  ///  objects that implement interfaces and require reference counting.</remarks>
  TRefCountedObject = class abstract(TInterfacedObject, IInterface)
  private
    FKeepAliveList: TArray<IInterface>;
    FInConstruction: Boolean;

  protected
    { Life-time }
    procedure KeepObjectAlive(const AObject: TRefCountedObject);
    procedure ReleaseObject(const AObject: TRefCountedObject; const FreeObject:
      Boolean = false);

    ///  <summary>Extract an interafce reference for this object.</summary>
    ///  <remarks>If the reference count is zero, then no reference is extracted.</remarks>
    ///  <returns>An interface reference or <c>nil</c>.</returns>
    function ExtractReference(): IInterface;

    ///  <summary>Specifies whether the object is currently being constructed.</summary>
    ///  <returns><c>True</c> if the object is in construction; <c>False</c> otherwise.</returns>
    property Constructing: Boolean read FInConstruction;
  public
    ///  <summary>Initializes the internals of the <see cref="DeHL.Base|TRefCountedObject">DeHL.Base.TRefCountedObject</see> objects.</summary>
    ///  <remarks>Do not call this method directly. It is part of the object creation process.</remarks>
    class function NewInstance: TObject; override;

    ///  <summary>Initializes the internals of the <see cref="DeHL.Base|TRefCountedObject">DeHL.Base.TRefCountedObject</see> objects.</summary>
    ///  <remarks>Do not call this method directly. It is part of the object creation process.</remarks>
    procedure AfterConstruction; override;
  end;
{$HINTS ON}

  ///  <summary>Base for all non-reference counted objects in DeHL.</summary>
  ///  <remarks><see cref="DeHL.Base|TSingletonObject">DeHL.Base.TSingletonObject</see> is designed to be used
  ///  as a base class for all objects that implement interfaces but do not require reference counting.</remarks>
  TSingletonObject = class abstract(TObject, IInterface)
  protected
    ///  <summary>Called automatically when an interface reference is requested.</summary>
    ///  <remarks>This method is not implemented and thus the interface extraction will always fail.</remarks>
    ///  <param name="IID">The GUID of the interface to extract.</param>
    ///  <param name="Obj">The location where the obtained interface reference is placed.</param>
    ///  <returns>Always returns <see cref="System.E_NOINTERFACE">System.E_NOINTERFACE</see>.</returns>
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;

    ///  <summary>Called automatically when an interface reference is being kept.</summary>
    ///  <remarks>This method is not implemented and thus reference counting is disabled.</remarks>
    ///  <returns>Always returns <c>-1</c>.</returns>
    function _AddRef: Integer; stdcall;

    ///  <summary>Called automatically when an interface reference is being lost.</summary>
    ///  <remarks>This method is not implemented and thus reference counting is disabled.</remarks>
    ///  <returns>Always returns <c>-1</c>.</returns>
    function _Release: Integer; stdcall;
  end;

{$HINTS OFF}
  ///  <summary>Base for all simple classes in DeHL.</summary>
  ///  <remarks><see cref="DeHL.Base|TSimpleObject">DeHL.Base.TSimpleObject</see> is designed to be used
  ///  as a base class for all classes that do not implement interfaces and do not require reference counting.</remarks>
  TSimpleObject = class abstract(TObject)
  public
    ///  <summary>Instantiates a <see cref="DeHL.Base|TSimpleObject">DeHL.Base.TSimpleObject</see> object.</summary>
    ///  <remarks>Do not call this method directly!</remarks>
    ///  <exception cref="DeHL.Exceptions|EDefaultConstructorNotAllowed">On each call.</exception>
    constructor Create();
  end;
{$HINTS ON}

{$IFDEF BUG_BASE_INTFS}
type
  ///  <summary>Base interface describing all enumerators in DeHL.</summary>
  ///  <remarks><see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> is implemented by
  ///  all enumerator objects in DeHL.</remarks>
  IEnumerator<T> = interface
    ///  <summary>Returns the current element of the enumerated collection.</summary>
    ///  <remarks><see cref="DeHL.Base|IEnumerator&lt;T&gt;.GetCurrent">DeHL.Base.IEnumerator&lt;T&gt;.GetCurrent</see> is the
    ///  getter method for the <see cref="DeHL.Base|IEnumerator&lt;T&gt;.Current">DeHL.Base.IEnumerator&lt;T&gt;.Current</see>
    ///  property. Use the property to obtain the element instead.</remarks>
    ///  <returns>The current element of the enumerated collection.</returns>
    function GetCurrent(): T;

    ///  <summary>Moves the enumerator to the next element of collection.</summary>
    ///  <remarks><see cref="DeHL.Base|IEnumerator&lt;T&gt;.MoveNext">DeHL.Base.IEnumerator&lt;T&gt;.MoveNext</see> is usually
    ///  called by compiler generated code. Its purpose is to move the "pointer" to the next element in the collection
    ///  (if there are elements left). Also note that many enumerator implementations may throw various exceptions if the
    ///  enumerated collections were changed in the meantime.</remarks>
    ///  <returns><c>True</c> if the enumerator successfully selected the next element; <c>False</c> if there are
    ///  no more elements to be enumerated.</returns>
    function MoveNext(): Boolean;

    ///  <summary>Returns the current element of the traversed collection.</summary>
    ///  <remarks><see cref="DeHL.Base|IEnumerator&lt;T&gt;.Current">DeHL.Base.IEnumerator&lt;T&gt;.Current</see> can only return a
    ///  valid element if <see cref="DeHL.Base|IEnumerator&lt;T&gt;.MoveNext">DeHL.Base.IEnumerator&lt;T&gt;.MoveNext</see> was
    ///  priorly called and returned <c>True</c>; otherwise the behavior of this property is undefined. Note that many enumerator implementations
    ///  may throw exceptions if the collection was changed in the meantime.
    ///  </remarks>
    ///  <returns>The current element of the enumerater collection.</returns>
    property Current: T read GetCurrent;
  end;

  ///  <summary>Base interface describing all enumerable collections in DeHL.</summary>
  ///  <remarks><see cref="DeHL.Base|IEnumerable&lt;T&gt;">DeHL.Base.IEnumerable&lt;T&gt;</see> is implemented by all
  ///  enumerable collections in DeHL.</remarks>
  IEnumerable<T> = interface
    ///  <summary>Returns an <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> interface that is used
    ///  to enumerate the collection.</summary>
    ///  <remarks><see cref="DeHL.Base|IEnumerable&lt;T&gt;.MoveNext">DeHL.Base.IEnumerable&lt;T&gt;.MoveNext</see> is usually
    ///  called by compiler generated code. Its purpose is to create an enumerator object that is used to actually traverse
    ///  the collections.
    ///  Note that many collections generate enumerators that depend on the state of the collection. If the collection is changed
    ///  after the <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> had been obtained,
    ///  <see cref="DeHL.Exceptions|ECollectionChangedException">DeHL.Exceptions.ECollectionChangedException</see> is thrown.</remarks>
    ///  <returns>The <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> interface.</returns>
    function GetEnumerator(): IEnumerator<T>;
  end;

  ///  <summary>Specifies common traits for classes that support comparability.</summary>
  ///  <remarks><see cref="DeHL.Base|IComparable">DeHL.Base.IComparable</see> can be implemented by any class that requires
  ///  comparability. If a class implements <see cref="DeHL.Base|IComparable">DeHL.Base.IComparable</see>, most of the code in DeHL
  ///  is able to properly order the instances of the implementer class by calling the
  ///  <see cref="DeHL.Base|IComparable.CompareTo">DeHL.Base.IComparable.CompareTo</see> method and checking the result.
  ///  </remarks>
  IComparable = interface
    ['{3CA89306-B7E7-4407-888A-A59D80C3CD6B}']

    ///  <summary>Compares two instances of the same class.</summary>
    ///  <remarks><see cref="DeHL.Base|IComparable.CompareTo">DeHL.Base.IComparable.CompareTo</see> is used to compare two
    ///  instances of the same class. This method returns the result of the comparison operations. The comparison should be based on the
    ///  objects' semantic value rather than their memory addresses. If the <paramref name="AObject"/> parameter is of a different
    ///  class, usually an exception is thrown. Normally, all objects should check for a <c>nil</c> value and act accordingly.</remarks>
    ///  <param name="AObject">The instance to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <c>Self</c> is less than <paramref name="AObject"/>. If the result is zero,
    ///  <c>Self</c> is equal to <paramref name="AObject"/>. And finally, if the result is greater than zero, <c>Self</c> is greater
    ///  than <paramref name="AObject"/>.</returns>
    function CompareTo(AObject: TObject): Integer; { Signature compatibility }
  end;

  ///  <summary>Specifies common traits for classes that support comparability.</summary>
  ///  <remarks><see cref="DeHL.Base|IComparable&lt;T&gt;">DeHL.Base.IComparable&lt;T&gt;</see> can be implemented by any class that requires
  ///  comparability. This interface is provided for convenience reasons but is not used by DeHL code.
  ///  </remarks>
  IComparable<T> = interface(IComparable)
    ///  <summary>Compares an instance of a class with a given generic type.</summary>
    ///  <remarks><see cref="DeHL.Base|IComparable&lt;T&gt;.CompareTo">DeHL.Base.IComparable&lt;T&gt;.CompareTo</see> is useful if the
    ///  object can be compared with a given generic type. For example, a
    ///  <see cref="DeHL.Box|TBox&lt;Integer&gt;.CompareTo">DeHL.Box.TBox&lt;Integer&gt;.CompareTo</see> can be compared with an Integer.</remarks>
    ///  <param name="AValue">The values to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <c>Self</c> is less than <paramref name="AValue"/>. If the result is zero,
    ///  <c>Self</c> is equal to <paramref name="AValue"/>. And finally, if the result is greater than
    /// zero, <c>Self</c> is greater than <paramref name="AValue"/>.</returns>
    function CompareTo(AValue: T): Integer; { Signature compatibility }
  end;
{$ENDIF}

type
  ///  <summary>Provides methods to create instances of classes indirectly.</summary>
  ///  <remarks><see cref="DeHL.Base|Activator">DeHL.Base.Activator</see> defines several static methods that can be used to create
  ///  instances of classes by the name of the class, type information, or a given RTTI object.
  ///  <see cref="DeHL.Base|Activator">DeHL.Base.Activator</see>
  ///  is primarily used by the serialization module to instantiate objects by the known class name.
  ///  Note that if the class is not RTTI-visible, all supplied methods fail.
  ///  </remarks>
  Activator = record
  public
    ///  <summary>Creates an instance based on the given class name.</summary>
    ///  <remarks>The instance is created by calling the first parameterless constructor. If the class does not define one, the ancestor's
    ///  parameterless constructor is used (down to <see cref="System.TObject">System.TObject</see>).</remarks>
    ///  <param name="AQualifiedName">The qualified class name. The name must include the unit and the class
    ///  (ex. DeHL.Base.TRefCountedObject).</param>
    ///  <returns>An instance of the class.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException">The class is either private or has no RTTI.</exception>
    class function CreateInstance(const AQualifiedName: String): TObject; overload; static;

    ///  <summary>Creates an instance based on the given class reference.</summary>
    ///  <remarks>The instance is created by calling the first parameterless constructor. If the class does not define one, the ancestor's
    ///  parameterless constructor is used (down to <see cref="System.TObject">System.TObject</see>).</remarks>
    ///  <param name="AClassInfo">The class reference.</param>
    ///  <returns>An instance of the class.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException">The class is either private or has no RTTI.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AClassInfo"/> is <c>nil</c>.</exception>
    class function CreateInstance(const AClassInfo: TClass): TObject; overload; static;

    ///  <summary>Creates an instance based on the given type information.</summary>
    ///  <remarks>The instance is created by calling the first parameterless constructor. If the class does not define one, the ancestor's
    ///  parameterless constructor is used (down to <see cref="System.TObject">System.TObject</see>).</remarks>
    ///  <param name="ATypeInfo">The type information.</param>
    ///  <returns>An instance of the class if the provided type information depicts a class; otherwise <c>nil</c> is returned.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException">The class is either private or has no RTTI.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ATypeInfo"/> is <c>nil</c>.</exception>
    class function CreateInstance(const ATypeInfo: PTypeInfo): TObject; overload; static;

    ///  <summary>Creates an instance based on the given RTTI object.</summary>
    ///  <remarks>The instance is created by calling the first parameterless constructor. If the class does not define one, the ancestor's
    ///  parameterless constructor is used (down to <see cref="System.TObject">System.TObject</see>).</remarks>
    ///  <param name="ARttiObject">The type information.</param>
    ///  <returns>An instance of the class.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException">The class is either private or has no RTTI.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ATypeInfo"/> is <c>nil</c>.</exception>
    class function CreateInstance(const ARttiObject: TRttiInstanceType): TObject; overload; static;
  end;

{$IF RTLVersion < 22}
// TODO: doc me!
type
  PNativeInt = ^NativeInt;
  PNativeUInt = ^NativeUInt;
{$IFEND}

type
  ///  <summary>Internally used &lt;Pointer, Pointer&gt; dictionary.</summary>
  ///  <remarks><see cref="DeHL.Base|TCorePointerDictionary">DeHL.Base.TCorePointerDictionary</see> is used in portions of DeHL
  ///  where it is not desired to reference the whole collections module. For example, the DeHL type system requires several dictionaries,
  ///  but it cannot reference the collection classes for several reasons (including the size).
  ///  </remarks>
  TCorePointerDictionary = class
  private type
    TEntry = record
      FHashCode: NativeInt;
      FNext: NativeInt;
      FKey: Pointer;
      FValue: Pointer;
    end;

    TBucketArray = array of NativeInt;
    TEntryArray = TArray<TEntry>;

  var
    FBucketArray: TBucketArray;
    FEntryArray: TEntryArray;

    FCount: NativeUInt;
    FFreeCount: NativeInt;
    FFreeList: NativeInt;

    { Internal }
    procedure InitializeInternals(const Capacity: NativeUInt);
    procedure Insert(const AKey: Pointer; const AValue: Pointer; const ShouldAdd: Boolean = true);
    function FindEntry(const AKey: Pointer): NativeInt;
    procedure Resize();
    function Hash(const AKey: Pointer): NativeInt;
    function GetItem(const Key: Pointer): Pointer;
    procedure SetItem(const Key: Pointer; const Value: Pointer);

  public
    ///  <summary>Creates an empty dictionary.</summary>
    ///  <remarks>The default, nonzero capacity is used.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates an empty dictionary with a given capacity.</summary>
    ///  <param name="InitialCapacity">A nonzero initial capacity for the dictionary.</param>
    constructor Create(const InitialCapacity: NativeUInt); overload;

    ///  <summary>Destroys the current instance.</summary>
    ///  <remarks>Do not call this method directly; call <see cref="System.TObject.Free">System.TObject.Free</see> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the dictionary.</summary>
    ///  <remarks>If the key or value is a pointer that needs cleaning up, use the second overload.</remarks>
    procedure Clear(); overload;

    ///  <summary>Clears the contents of the dictionary and performs proper cleanup.</summary>
    ///  <remarks>This overload of <see cref="DeHL.Base|TCorePointerDictionary.Clear">DeHL.Base.TCorePointerDictionary.Clear</see>
    ///  accepts two anonymous methods that are called for each key and value that are being removed from the dictionary. This method
    ///  should be used when the key or/and value need to be cleaned up.</remarks>
    ///  <param name="AKeyClearProc">The anonymous procedure called for each removed key. Pass <c>nil</c> if keys do not need cleanup.</param>
    ///  <param name="AValClearProc">The anonymous procedure called for each removed value. Pass <c>nil</c> if values do not need cleanup.</param>
    procedure Clear(const AKeyClearProc, AValClearProc: TProc<Pointer>); overload;

    ///  <summary>Adds a new key-value pair into the dictionary.</summary>
    ///  <param name="AKey">The key.</param>
    ///  <param name="AValue">The associated value.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The <paramref name="AKey"/> is already registered in
    ///  the dictionary.</exception>
    procedure Add(const AKey: Pointer; const AValue: Pointer);

    ///  <summary>Removes a key-value pair from the dictionary.</summary>
    ///  <param name="AKey">The key. If the key is not found in the dictionary, nothing happens.</param>
    procedure Remove(const AKey: Pointer);

    ///  <summary>Checks whether a key is registered in the dictionary.</summary>
    ///  <param name="AKey">The key to check for.</param>
    ///  <returns><c>True</c> if there is a key-value pair with the given key; <c>False</c> otherwise.</returns>
    function ContainsKey(const AKey: Pointer): Boolean;

    ///  <summary>Tries to obtain a value from the dictionary.</summary>
    ///  <param name="AKey">The value's associated key.</param>
    ///  <param name="FoundValue">The value (if the key was found); otherwise an undefined value.</param>
    ///  <returns><c>True</c> if the key was found; <c>False</c> otherwise.</returns>
    function TryGetValue(const AKey: Pointer; out FoundValue: Pointer): Boolean;

    ///  <summary>Default class property. Provides the key-value mapping.</summary>
    ///  <remarks>If the property is being written to, the key-value pair is inserted or replaces an already existing one.</remarks>
    ///  <param name="AKey">The value's associated key.</param>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">Read operation with an unknown key.</exception>
    property Items[const Key: Pointer]: Pointer read GetItem write SetItem; default;

    ///  <summary>Specifies the number of key-value pairs stored in the dictionary.</summary>
    ///  <returns>The number of pairs in the dictionary.</returns>
    property Count: NativeUInt read FCount;
  end;

var
  ///  <summary>Internal interface reference.</summary>
  ///  <remarks>Do not change the value of this variable! Any change
  ///  can lead to serious problems in other parts of DeHL.</remarks>
  __Marker: IInterface;

implementation
uses
  DeHL.Exceptions;

{ TSingletonObject }

function TSingletonObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  { Do nothing }
  Result := E_NOINTERFACE;
end;

function TSingletonObject._AddRef: Integer;
begin
  { Do nothing }
  Result := -1;
end;

function TSingletonObject._Release: Integer;
begin
  { Do nothing }
  Result := -1;
end;

{ TSimpleObject }

constructor TSimpleObject.Create;
begin
  { Throw a default exception }
  ExceptionHelper.Throw_DefaultConstructorNotAllowedError();
end;

{ TRefCountedObject }

procedure TRefCountedObject.AfterConstruction;
begin
  FInConstruction := false;
  inherited AfterConstruction();
end;

function TRefCountedObject.ExtractReference(): IInterface;
var
  Ref: NativeInt;
begin
  { While constructing, an object has an implicit ref count of 1 }
  if FInConstruction then
    Ref := 1
  else
    Ref := 0;

  {
      If the object is referenced in other places as an
      interface, get a new one, otherwise return nil
   }
  if RefCount > Ref then
    Result := Self
  else
    Result := nil;
end;

procedure TRefCountedObject.KeepObjectAlive(const AObject: TRefCountedObject);
var
  I, L: NativeInt;
  II: IInterface;
begin
  { Skip nil references }
  if AObject = nil then
    Exit;

  { Cannot self-ref! }
  if AObject = Self then
    ExceptionHelper.Throw_CannotSelfReferenceError();

  { Extract an optional reference, do not continue if failed }
  II := AObject.ExtractReference();
  if II = nil then
    Exit;

  L := Length(FKeepAliveList);

  { Find a free spot }
  if L > 0 then
    for I := 0 to L - 1 do
      if FKeepAliveList[I] = nil then
      begin
        FKeepAliveList[I] := II;
        Exit;
      end;

  { No free spots, extend array and insert the ref there }
  SetLength(FKeepAliveList, L + 1);
  FKeepAliveList[L] := II;
end;

class function TRefCountedObject.NewInstance: TObject;
begin
  Result := inherited NewInstance();

  { Set in construction! }
  TRefCountedObject(Result).FInConstruction := true;
end;

procedure TRefCountedObject.ReleaseObject(const AObject: TRefCountedObject;
  const FreeObject: Boolean = false);
var
  I, L: NativeInt;
  II: IInterface;
begin
  { Do nothing on nil references, since it may be calle din destructors }
  if AObject = nil then
    Exit;

  { Cannot self-ref! }
  if AObject = Self then
    ExceptionHelper.Throw_CannotSelfReferenceError();

  { Extract an optional reference, if none received, exit }
  II := AObject.ExtractReference();
  if II = nil then
  begin
    if FreeObject then
      AObject.Free;

    Exit;
  end;

  L := Length(FKeepAliveList);

  { Find a free spot }
  if L > 0 then
    for I := 0 to L - 1 do
      if FKeepAliveList[I] = II then
      begin
        { Release the spot and kill references to the interface }
        FKeepAliveList[I] := nil;
        II := nil;
        Exit;
      end;
end;


{ Activator }

class function Activator.CreateInstance(const ATypeInfo: PTypeInfo): TObject;
var
  LCtx: TRttiContext;
  LType: TRttiType;
begin
  if ATypeInfo = nil then
    ExceptionHelper.Throw_ArgumentNilError('ATypeInfo');

  LType := LCtx.GetType(ATypeInfo);

  if LType is TRttiInstanceType then
    Result := CreateInstance(TRttiInstanceType(LType))
  else
    Result := nil;
end;

class function Activator.CreateInstance(const ARttiObject: TRttiInstanceType): TObject;
var
  LMethod: TRttiMethod;
begin
  if ARttiObject = nil then
    ExceptionHelper.Throw_ArgumentNilError('ARttiObject');

  { Invoke the first parameterless constructor found. }
  for LMethod in ARttiObject.GetMethods() do
    if LMethod.HasExtendedInfo and LMethod.IsConstructor then
      if LMethod.GetParameters() = nil then
        Exit(LMethod.Invoke(ARttiObject.MetaclassType, []).AsObject);

  { Not found ... Use the old fashioned way }
  Result := ARttiObject.MetaclassType.Create();
end;

class function Activator.CreateInstance(const AClassInfo: TClass): TObject;
var
  LCtx: TRttiContext;
begin
  if AClassInfo = nil then
    ExceptionHelper.Throw_ArgumentNilError('AClassInfo');

  { Create an instance }
  Result := CreateInstance(TRttiInstanceType(LCtx.GetType(AClassInfo)));
end;

class function Activator.CreateInstance(const AQualifiedName: String): TObject;
var
  LType: TRttiInstanceType;
  LCtx: TRttiContext;
begin
  { Defaults tp nil }
  LType := nil;

  try
    LType := LCtx.FindType(AQualifiedName) as TRttiInstanceType;
  except // Catch and forget. Will fail later on
  end;

  { Call the other method now }
  Result := CreateInstance(TRttiInstanceType(LType))
end;

{ TCorePointerDictionary }

const
  DefaultArrayLength = 32;

procedure TCorePointerDictionary.Add(const AKey: Pointer; const AValue: Pointer);
begin
  { Call insert }
  Insert(AKey, AValue);
end;

procedure TCorePointerDictionary.Clear;
var
  I: NativeUInt;
begin
  if FCount > 0 then
    for I := 0 to Length(FBucketArray) - 1 do
      FBucketArray[I] := -1;

  if Length(FEntryArray) > 0 then
    FillChar(FEntryArray[0], Length(FEntryArray) * SizeOf(TEntry), 0);

  FFreeList := -1;
  FCount := 0;
  FFreeCount := 0;
end;

procedure TCorePointerDictionary.Clear(const AKeyClearProc, AValClearProc: TProc<Pointer>);
var
  I: NativeUInt;
begin
  { Clear each key or value }
  if Length(FEntryArray) > 0 then
    for I := 0 to Length(FEntryArray) - 1 do
      if FEntryArray[I].FHashCode >= 0 then
      begin
        if Assigned(AKeyClearProc) then
          AKeyClearProc(FEntryArray[I].FKey);

        if Assigned(AValClearProc) then
          AValClearProc(FEntryArray[I].FValue);
      end;

  { Call the simplified clear after our work }
  Clear();
end;

function TCorePointerDictionary.ContainsKey(const AKey: Pointer): Boolean;
begin
  Result := (FindEntry(AKey) >= 0);
end;

constructor TCorePointerDictionary.Create;
begin
  Create(DefaultArrayLength);
end;

constructor TCorePointerDictionary.Create(const InitialCapacity: NativeUInt);
begin
  FCount := 0;
  FFreeCount := 0;
  FFreeList := 0;

  InitializeInternals(InitialCapacity);
end;

destructor TCorePointerDictionary.Destroy;
begin
  { Clear first }
  Clear();

  inherited;
end;

function TCorePointerDictionary.FindEntry(const AKey: Pointer): NativeInt;
var
  HashCode: NativeInt;
  I: NativeInt;
begin
  Result := -1;

  if Length(FBucketArray) > 0 then
  begin
    { Generate the hash code }
    HashCode := Hash(AKey);

    I := FBucketArray[HashCode mod Length(FBucketArray)];

    while I >= 0 do
    begin
      if (FEntryArray[I].FHashCode = HashCode) and (FEntryArray[I].FKey = AKey) then
         begin Result := I; Exit; end;

      I := FEntryArray[I].FNext;
    end;
  end;
end;

function TCorePointerDictionary.GetItem(const Key: Pointer): Pointer;
begin
  if not TryGetValue(Key, Result) then
    ExceptionHelper.Throw_KeyNotFoundError(IntToHex(NativeInt(Key), 8));
end;

function TCorePointerDictionary.Hash(const AKey: Pointer): NativeInt;
const
  PositiveMask = not NativeInt(1 shl (SizeOf(NativeInt) * 8 - 1));
begin
  Result := PositiveMask and ((PositiveMask and NativeInt(AKey)) + 1);
end;

procedure TCorePointerDictionary.InitializeInternals(const Capacity: NativeUInt);
var
  I: NativeInt;
begin
  SetLength(FBucketArray, Capacity);
  SetLength(FEntryArray, Capacity);

  for I := 0 to Capacity - 1 do
  begin
    FBucketArray[I] := -1;
    FEntryArray[I].FHashCode := -1;
  end;

  FFreeList := -1;
end;

procedure TCorePointerDictionary.Insert(const AKey: Pointer; const AValue: Pointer; const ShouldAdd: Boolean);
var
  FreeList, Index,
    HashCode, I: NativeInt;
begin
  if Length(FBucketArray) = 0 then
     InitializeInternals(0);

  { Generate the hash code }
  HashCode := Hash(AKey);
  Index := HashCode mod Length(FBucketArray);

  I := FBucketArray[Index];

  while I >= 0 do
  begin
    if (FEntryArray[I].FHashCode = HashCode) and (FEntryArray[I].FKey = AKey) then
    begin
      if (ShouldAdd) then
        ExceptionHelper.Throw_DuplicateKeyError('AKey');

      FEntryArray[I].FValue := AValue;
      Exit;
    end;

    { Move to next }
    I := FEntryArray[I].FNext;
  end;

  { Adjust free spaces }
  if FFreeCount > 0 then
  begin
    FreeList := FFreeList;
    FFreeList := FEntryArray[FreeList].FNext;

    Dec(FFreeCount);
  end else
  begin
    { Adjust index if there is not enough free space }
    if FCount = NativeUInt(Length(FEntryArray)) then
    begin
      Resize();
      Index := HashCode mod Length(FBucketArray);
    end;

    FreeList := FCount;
    Inc(FCount);
  end;

  { Insert the element at the right position and adjust arrays }
  FEntryArray[FreeList].FHashCode := HashCode;
  FEntryArray[FreeList].FKey := AKey;
  FEntryArray[FreeList].FValue := AValue;
  FEntryArray[FreeList].FNext := FBucketArray[Index];

  FBucketArray[Index] := FreeList;
end;

procedure TCorePointerDictionary.Remove(const AKey: Pointer);
var
  HashCode, Index, I, RemIndex: NativeInt;
begin
  if Length(FBucketArray) > 0 then
  begin
    { Generate the hash code }
    HashCode := Hash(AKey);

    Index := HashCode mod Length(FBucketArray);
    RemIndex := -1;

    I := FBucketArray[Index];

    while I >= 0 do
    begin
      if (FEntryArray[I].FHashCode = HashCode) and (FEntryArray[I].FKey = AKey) then
      begin

        if RemIndex < 0 then
        begin
          FBucketArray[Index] := FEntryArray[I].FNext;
        end else
        begin
          FEntryArray[RemIndex].FNext := FEntryArray[I].FNext;
        end;

        FEntryArray[I].FHashCode := -1;
        FEntryArray[I].FNext := FFreeList;
        FEntryArray[I].FKey := default(Pointer);
        FEntryArray[I].FValue := default(Pointer);

        FFreeList := I;
        Inc(FFreeCount);

        Exit;
      end;

      RemIndex := I;
      I := FEntryArray[I].FNext;
    end;

  end;
end;

procedure TCorePointerDictionary.Resize;
var
  LNewLength, I, Index: NativeInt;
  NArr: TBucketArray;
begin
  LNewLength := FCount * 2;
  SetLength(NArr, LNewLength);

  for I := 0 to Length(NArr) - 1 do
  begin
    NArr[I] := -1;
  end;

  SetLength(FEntryArray, LNewLength);

  for I := 0 to FCount - 1 do
  begin
    Index := FEntryArray[I].FHashCode mod LNewLength;
    FEntryArray[I].FNext := NArr[Index];
    NArr[Index] := I;
  end;

  { Reset bucket array }
  FBucketArray := nil;
  FBucketArray := NArr;
end;

procedure TCorePointerDictionary.SetItem(const Key: Pointer; const Value: Pointer);
begin
  { Simply call insert }
  Insert(Key, Value, false);
end;

function TCorePointerDictionary.TryGetValue(const AKey: Pointer; out FoundValue: Pointer): Boolean;
var
  Index: NativeInt;
begin
  Index := FindEntry(AKey);

  if Index >= 0 then
     begin
       FoundValue := FEntryArray[Index].FValue;
       Exit(True);
     end;

  { Key not found, simply fail }
  FoundValue := Default(Pointer);
  Result := False;
end;

initialization
  __Marker := TInterfacedObject.Create();

finalization
  __Marker := nil;

end.
