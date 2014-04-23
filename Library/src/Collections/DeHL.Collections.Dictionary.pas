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
unit DeHL.Collections.Dictionary;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Math.Algorithms,
     DeHL.Tuples,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>dictionary</c> collection.</summary>
  ///  <remarks>This type uses hashing mechanisms to store its key-value pairs.</remarks>
  TDictionary<TKey, TValue> = class(TEnexAssociativeCollection<TKey, TValue>, IDictionary<TKey, TValue>)
  private type
    {$REGION 'Internal Types'}
    { Generic Dictionary Pairs Enumerator }
    TPairEnumerator = class(TEnumerator<KVPair<TKey,TValue>>)
    private
      FVer: NativeUInt;
      FDict: TDictionary<TKey, TValue>;
      FCurrentIndex: NativeInt;
      FValue: KVPair<TKey,TValue>;

    public
      { Constructor }
      constructor Create(const ADict: TDictionary<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): KVPair<TKey,TValue>; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic Dictionary Keys Enumerator }
    TKeyEnumerator = class(TEnumerator<TKey>)
    private
      FVer: NativeUInt;
      FDict: TDictionary<TKey, TValue>;
      FCurrentIndex: NativeInt;
      FValue: TKey;
    public
      { Constructor }
      constructor Create(const ADict: TDictionary<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TKey; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic Dictionary Values Enumerator }
    TValueEnumerator = class(TEnumerator<TValue>)
    private
      FVer: NativeUInt;
      FDict: TDictionary<TKey, TValue>;
      FCurrentIndex: NativeInt;
      FValue: TValue;
    public
      { Constructor }
      constructor Create(const ADict: TDictionary<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TValue; override;
      function MoveNext(): Boolean; override;
    end;

    TEntry = record
      FHashCode: NativeInt;
      FNext: NativeInt;
      FKey: TKey;
      FValue: TValue;
    end;

    TBucketArray = array of NativeInt;
    TEntryArray = TArray<TEntry>;

    { Generic Dictionary Keys Collection }
    TKeyCollection = class(TEnexCollection<TKey>)
    private
      FDict: TDictionary<TKey, TValue>;

    protected
      { Hidden }
      function GetCount(): NativeUInt; override;

    public
      { Constructor }
      constructor Create(const ADict: TDictionary<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      { Property }
      property Count: NativeUInt read GetCount;

      { IEnumerable/ ICollection support }
      function GetEnumerator(): IEnumerator<TKey>; override;

      { Copy-To }
      procedure CopyTo(var AArray: array of TKey; const StartIndex: NativeUInt); overload; override;
    end;

    { Generic Dictionary Values Collection }
    TValueCollection = class(TEnexCollection<TValue>)
    private
      FDict: TDictionary<TKey, TValue>;

    protected
      { Hidden }
      function GetCount: NativeUInt; override;

    public
      { Constructor }
      constructor Create(const ADict: TDictionary<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      { Property }
      property Count: NativeUInt read GetCount;

      { IEnumerable/ ICollection support }
      function GetEnumerator(): IEnumerator<TValue>; override;

      { Copy-To }
      procedure CopyTo(var AArray: array of TValue; const StartIndex: NativeUInt); overload; override;
    end;
    {$ENDREGION}

  private var
    FBucketArray: TBucketArray;
    FEntryArray: TEntryArray;
    FKeyCollection: IEnexCollection<TKey>;
    FValueCollection: IEnexCollection<TValue>;
    FCount: NativeInt;
    FFreeCount: NativeInt;
    FFreeList: NativeInt;
    FVer: NativeUInt;

    { Internal }
    procedure InitializeInternals(const Capacity: NativeUInt);
    procedure Insert(const AKey: TKey; const AValue: TValue; const ShouldAdd: Boolean = true);
    function FindEntry(const AKey: TKey): NativeInt;
    procedure Resize();
    function Hash(const AKey: TKey): NativeInt;

  protected
    ///  <summary>Called when the serialization process is about to begin.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    procedure StartSerializing(const AData: TSerializationData); override;

    ///  <summary>Called when the deserialization process is about to begin.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartDeserializing(const AData: TDeserializationData); override;

    ///  <summary>Called when the an pair has been deserialized and needs to be inserted into the dictionary.</summary>
    ///  <param name="AKey">The key that was deserialized.</param>
    ///  <param name="AValue">The value that was deserialized.</param>
    ///  <remarks>This method simply adds the element to the dictionary.</remarks>
    procedure DeserializePair(const AKey: TKey; const AValue: TValue); override;

    ///  <summary>Returns the number of key-value pairs in the dictionary.</summary>
    ///  <returns>A positive value specifying the number of pairs in the dictionary.</returns>
    function GetCount(): NativeUInt; override;

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to try to retreive the value.</param>
    ///  <returns>The value associated with the key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the dictionary.</exception>
    function GetItem(const AKey: TKey): TValue;

    ///  <summary>Sets the value for a given key.</summary>
    ///  <param name="AKey">The key for which to set the value.</param>
    ///  <param name="AValue">The value to set.</param>
    ///  <remarks>If the dictionary does not contain the key, this method acts like <c>Add</c>; otherwise the
    ///  value of the specified key is modified.</remarks>
    procedure SetItem(const AKey: TKey; const Value: TValue);
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The dictionary's initial capacity.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="ACollection"/> contains pairs with equal keys.</exception>
    constructor Create(const ACollection: IEnumerable<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="AArray"/> contains pairs with equal keys.</exception>
    constructor Create(const AArray: array of KVPair<TKey, TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="AArray"/> contains pairs with equal keys.</exception>
    constructor Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="AArray"/> contains pairs with equal keys.</exception>
    constructor Create(const AArray: TFixedArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The dictionary's initial capacity.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
      const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="ACollection"/> contains pairs with equal keys.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
      const ACollection: IEnumerable<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="AArray"/> contains pairs with equal keys.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
      const AArray: array of KVPair<TKey,TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="AArray"/> contains pairs with equal keys.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
      const AArray: TDynamicArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException"><paramref name="AArray"/> contains pairs with equal keys.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
      const AArray: TFixedArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the dictionary.</summary>
    ///  <remarks>This method clears the dictionary and invokes type object's cleaning
    ///  routines for each key and value.</remarks>
    procedure Clear();

    ///  <summary>Adds a key-value pair to the dictionary.</summary>
    ///  <param name="APair">The key-value pair to add.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The dictionary already contains a pair with the given key.</exception>
    procedure Add(const APair: KVPair<TKey,TValue>); overload;

    ///  <summary>Adds a key-value pair to the dictionary.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The dictionary already contains a pair with the given key.</exception>
    procedure Add(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value pair using a given key.</summary>
    ///  <param name="AKey">The key of the pair to remove.</param>
    ///  <remarks>This invokes type object's cleaning routines for value
    ///  associated with the key. If the specified key was not found in the dictionary, nothing happens.</remarks>
    procedure Remove(const AKey: TKey); overload;

    ///  <summary>Checks whether the dictionary contains a key-value pair identified by the given key.</summary>
    ///  <param name="AKey">The key to check for.</param>
    ///  <returns><c>True</c> if the dictionary contains a pair identified by the given key; <c>False</c> otherwise.</returns>
    function ContainsKey(const AKey: TKey): Boolean;

    ///  <summary>Checks whether the dictionary contains a key-value pair that contains a given value.</summary>
    ///  <param name="AValue">The value to check for.</param>
    ///  <returns><c>True</c> if the dictionary contains a pair containing the given value; <c>False</c> otherwise.</returns>
    function ContainsValue(const AValue: TValue): Boolean;

    ///  <summary>Tries to obtain the value associated with a given key.</summary>
    ///  <param name="AKey">The key for which to try to retreive the value.</param>
    ///  <param name="AFoundValue">The found value (if the result is <c>True</c>).</param>
    ///  <returns><c>True</c> if the dictionary contains a value for the given key; <c>False</c> otherwise.</returns>
    function TryGetValue(const AKey: TKey; out AFoundValue: TValue): Boolean;

    ///  <summary>Gets or sets the value for a given key.</summary>
    ///  <param name="AKey">The key for to operate on.</param>
    ///  <returns>The value associated with the key.</returns>
    ///  <remarks>If the dictionary does not contain the key, this method acts like <c>Add</c> if assignment is done to this property;
    ///  otherwise the value of the specified key is modified.</remarks>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The trying to read the value of a key that is
    ///  not found in the dictionary.</exception>
    property Items[const AKey: TKey]: TValue read GetItem write SetItem; default;

    ///  <summary>Specifies the number of key-value pairs in the dictionary.</summary>
    ///  <returns>A positive value specifying the number of pairs in the dictionary.</returns>
    property Count: NativeUInt read GetCount;

    ///  <summary>Specifies the collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the dictionary.</returns>
    property Keys: IEnexCollection<TKey> read FKeyCollection;

    ///  <summary>Specifies the collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the dictionary.</returns>
    property Values: IEnexCollection<TValue> read FValueCollection;

    ///  <summary>Returns a new enumerator object used to enumerate this dictionary.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the dictionary.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<KVPair<TKey,TValue>>; override;

    ///  <summary>Copies the values stored in the dictionary to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the dictionary.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the dictionary.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of KVPair<TKey,TValue>; const StartIndex: NativeUInt); overload; override;

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to return the associated value.</param>
    ///  <returns>The value associated with the given key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">No such key in the dictionary.</exception>
    function ValueForKey(const AKey: TKey): TValue; override;

    ///  <summary>Checks whether the dictionary contains a given key-value pair.</summary>
    ///  <param name="AKey">The key part of the pair.</param>
    ///  <param name="AValue">The value part of the pair.</param>
    ///  <returns><c>True</c> if the given key-value pair exists; <c>False</c> otherwise.</returns>
    function KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean; override;

    ///  <summary>Returns an Enex collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the dictionary.</returns>
    function SelectKeys(): IEnexCollection<TKey>; override;

    ///  <summary>Returns a Enex collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the dictionary.</returns>
    function SelectValues(): IEnexCollection<TValue>; override;
  end;

  ///  <summary>The generic <c>dictionary</c> collection designed to store objects.</summary>
  ///  <remarks>This type uses hashing mechanisms to store its key-value pairs.</remarks>
  TObjectDictionary<TKey, TValue> = class(TDictionary<TKey, TValue>)
  private
    FKeyWrapperType: TMaybeObjectWrapperType<TKey>;
    FValueWrapperType: TMaybeObjectWrapperType<TValue>;

    { Getters/Setters for OwnsKeys }
    function GetOwnsKeys: Boolean;
    procedure SetOwnsKeys(const Value: Boolean);

    { Getters/Setters for OwnsValues }
    function GetOwnsValues: Boolean;
    procedure SetOwnsValues(const Value: Boolean);

  protected
    ///  <summary>Installs the type objects describing the key and the value or the stored pairs.</summary>
    ///  <param name="AKeyType">The key's type object to install.</param>
    ///  <param name="AValueType">The value's type object to install.</param>
    ///  <remarks>This method installs a custom wrapper designed to suppress the cleanup of objects on request.
    ///  Make sure to call this method in descendant classes.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    procedure InstallTypes(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); override;

  public
    ///  <summary>Specifies whether this dictionary owns the keys.</summary>
    ///  <returns><c>True</c> if the dictionary owns the keys; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the dictionary controls the life-time of the stored keys. The value of
    ///  this property has effect only if the keys are objects, otherwise it is ignored.</remarks>
    property OwnsKeys: Boolean read GetOwnsKeys write SetOwnsKeys;

    ///  <summary>Specifies whether this dictionary owns the values.</summary>
    ///  <returns><c>True</c> if the dictionary owns the values; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the dictionary controls the life-time of the stored values. The value of
    ///  this property has effect only if the values are objects, otherwise it is ignored.</remarks>
    property OwnsValues: Boolean read GetOwnsValues write SetOwnsValues;
  end;

{$IFNDEF BUG_URW1133}
type
  TBugReproducer = TDictionary<TTypeClass, String>;
{$ENDIF}

implementation

const
  DefaultArrayLength = 32;

{ TDictionary<TKey, TValue> }

procedure TDictionary<TKey, TValue>.Add(const APair: KVPair<TKey, TValue>);
begin
 { Call insert }
 Insert(APair.Key, APair.Value);
end;

procedure TDictionary<TKey, TValue>.Add(const AKey: TKey; const AValue: TValue);
begin
 { Call insert }
 Insert(AKey, AValue);
end;

procedure TDictionary<TKey, TValue>.Clear;
var
  I, K  : NativeUInt;
  KC, VC, MKC, MVC: Boolean;
begin
  if FCount > 0 then
  begin
    for I := 0 to Length(FBucketArray) - 1 do
        FBucketArray[I] := -1;
  end;

  if Length(FEntryArray) > 0 then
  begin
    KC := (KeyType.Management() = tmManual);
    MKC:= (KeyType.Management() = tmCompiler);
    VC := (ValueType.Management() = tmManual);
    MVC := (ValueType.Management() = tmCompiler);

    if (KC or MKC or VC or MVC) then
    begin
      for I := 0 to Length(FEntryArray) - 1 do
      begin
        if FEntryArray[I].FHashCode >= 0 then
        begin
          { Either manually cleanup or tell compiler/RTL to do so! }
          if KC then
            KeyType.Cleanup(FEntryArray[I].FKey)
          else if MKC then
            FEntryArray[I].FKey := default(TKey);

          { Either manually cleanup or tell compiler/RTL to do so! }
          if VC then
            ValueType.Cleanup(FEntryArray[I].FValue)
          else if MVC then
            FEntryArray[I].FValue := default(TValue);
        end;
      end;
    end;

    FillChar(FEntryArray[0], Length(FEntryArray) * SizeOf(TEntry), 0);
  end;

  FFreeList := -1;
  FCount := 0;
  FFreeCount := 0;

  Inc(FVer);
end;

function TDictionary<TKey, TValue>.ContainsKey(const AKey: TKey): Boolean;
begin
  Result := (FindEntry(AKey) >= 0);
end;

function TDictionary<TKey, TValue>.ContainsValue(const AValue: TValue): Boolean;
var
  I: NativeInt;
begin
  Result := False;

  for I := 0 to FCount - 1 do
  begin
    if (FEntryArray[I].FHashCode >= 0) and (ValueType.AreEqual(FEntryArray[I].FValue, AValue)) then
       begin Result := True; Exit; end;

  end;
end;

procedure TDictionary<TKey, TValue>.CopyTo(
  var AArray: array of KVPair<TKey, TValue>; const StartIndex: NativeUInt);
var
  I, X: NativeInt;
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := StartIndex;

  for I := 0 to FCount - 1 do
  begin
    if (FEntryArray[I].FHashCode >= 0) then
    begin
       AArray[X] := KVPair.Create<TKey, TValue>(FEntryArray[I].FKey, FEntryArray[I].FValue);
       Inc(X);
    end;
  end;
end;

constructor TDictionary<TKey, TValue>.Create;
begin
  Create(TType<TKey>.Default, TType<TValue>.Default);
end;

constructor TDictionary<TKey, TValue>.Create(const AInitialCapacity: NativeUInt);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AInitialCapacity);
end;

constructor TDictionary<TKey, TValue>.Create(
  const ACollection: IEnumerable<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, ACollection);
end;

constructor TDictionary<TKey, TValue>.Create(
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>; const AInitialCapacity: NativeUInt);
begin
  inherited Create();

  { Initialize instance }
  if (AKeyType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AKeyType');

  if (AValueType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AValueType');

  { Install types }
  InstallTypes(AKeyType, AValueType);

  FKeyCollection := TKeyCollection.Create(Self);
  FValueCollection := TValueCollection.Create(Self);

  FVer := 0;
  FCount := 0;
  FFreeCount := 0;
  FFreeList := 0;

  InitializeInternals(AInitialCapacity);
end;

constructor TDictionary<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const ACollection: IEnumerable<KVPair<TKey, TValue>>);
var
  V: KVPair<TKey, TValue>;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType, DefaultArrayLength);

  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Pump in all items }
  for V in ACollection do
  begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    Add(V);
{$ELSE}
    Add(V.Key, V.Value);
{$ENDIF}
  end;
end;

constructor TDictionary<TKey, TValue>.Create(
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>);
begin
  { Call upper constructor }
  Create(AKeyType, AValueType, DefaultArrayLength);
end;

procedure TDictionary<TKey, TValue>.DeserializePair(const AKey: TKey; const AValue: TValue);
begin
  { Simple as hell ... }
  Add(AKey, AValue);
end;

destructor TDictionary<TKey, TValue>.Destroy;
begin
  { Clear first }
  Clear();

  inherited;
end;

function TDictionary<TKey, TValue>.FindEntry(const AKey: TKey): NativeInt;
var
  HashCode: NativeInt;
  I       : NativeInt;
begin
  Result := -1;

  if Length(FBucketArray) > 0 then
  begin
    { Generate the hash code }
    HashCode := Hash(AKey);

    I := FBucketArray[HashCode mod Length(FBucketArray)];

    while I >= 0 do
    begin
      if (FEntryArray[I].FHashCode = HashCode) and KeyType.AreEqual(FEntryArray[I].FKey, AKey) then
         begin Result := I; Exit; end;

      I := FEntryArray[I].FNext;
    end;
  end;
end;

function TDictionary<TKey, TValue>.GetCount: NativeUInt;
begin
  Result := (FCount - FFreeCount);
end;

function TDictionary<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  Result := TDictionary<TKey, TValue>.TPairEnumerator.Create(Self);
end;

function TDictionary<TKey, TValue>.GetItem(const AKey: TKey): TValue;
begin
  if not TryGetValue(AKey, Result) then
    ExceptionHelper.Throw_KeyNotFoundError(KeyType.GetString(AKey));
end;

function TDictionary<TKey, TValue>.Hash(const AKey: TKey): NativeInt;
const
  PositiveMask = not NativeInt(1 shl (SizeOf(NativeInt) * 8 - 1));
begin
  Result := PositiveMask and ((PositiveMask and KeyType.GenerateHashCode(AKey)) + 1);
end;

procedure TDictionary<TKey, TValue>.InitializeInternals(
  const Capacity: NativeUInt);
var
  XPrime: NativeInt;
  I    : NativeInt;
begin
  XPrime := Prime.GetNearestProgressionPositive(Capacity);

  SetLength(FBucketArray, XPrime);
  SetLength(FEntryArray, XPrime);

  for I := 0 to XPrime - 1 do
  begin
    FBucketArray[I] := -1;
    FEntryArray[I].FHashCode := -1;
  end;

  FFreeList := -1;
end;

procedure TDictionary<TKey, TValue>.Insert(const AKey: TKey;
  const AValue: TValue; const ShouldAdd: Boolean);
var
  FreeList: NativeInt;
  Index   : NativeInt;
  HashCode: NativeInt;
  I       : NativeInt;
begin
  FreeList := 0;

  if Length(FBucketArray) = 0 then
     InitializeInternals(0);

  { Generate the hash code }
  HashCode := Hash(AKey);
  Index := HashCode mod Length(FBucketArray);

  I := FBucketArray[Index];

  while I >= 0 do
  begin
    if (FEntryArray[I].FHashCode = HashCode) and KeyType.AreEqual(FEntryArray[I].FKey, AKey) then
    begin
      if (ShouldAdd) then
        ExceptionHelper.Throw_DuplicateKeyError('AKey');

      FEntryArray[I].FValue := AValue;
      Inc(FVer);
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
    if FCount = Length(FEntryArray) then
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
  Inc(FVer);
end;

function TDictionary<TKey, TValue>.KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean;
var
  LValue: TValue;
begin
  Result := TryGetValue(AKey, LValue) and ValueType.AreEqual(LValue, AValue);
end;

procedure TDictionary<TKey, TValue>.Remove(const AKey: TKey);
var
  HashCode: NativeInt;
  Index   : NativeInt;
  I       : NativeInt;
  RemIndex: NativeInt;
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
      if (FEntryArray[I].FHashCode = HashCode) and KeyType.AreEqual(FEntryArray[I].FKey, AKey) then
      begin

        if RemIndex < 0 then
        begin
          FBucketArray[Index] := FEntryArray[I].FNext;
        end else
        begin
          FEntryArray[RemIndex].FNext := FEntryArray[I].FNext;
        end;

        { Cleanup required? }
        if ValueType.Management() = tmManual then
           ValueType.Cleanup(FEntryArray[I].FValue);

        FEntryArray[I].FHashCode := -1;
        FEntryArray[I].FNext := FFreeList;
        FEntryArray[I].FKey := default(TKey);
        FEntryArray[I].FValue := default(TValue);

        FFreeList := I;
        Inc(FFreeCount);
        Inc(FVer);

        Exit;
      end;

      RemIndex := I;
      I := FEntryArray[I].FNext;
    end;

  end;
end;

procedure TDictionary<TKey, TValue>.Resize;
var
  XPrime: NativeInt;
  I     : NativeInt;
  Index : NativeInt;
  NArr  : TBucketArray;
begin
  XPrime := Prime.GetNearestProgressionPositive(FCount * 2);

  SetLength(NArr, XPrime);
  for I := 0 to Length(NArr) - 1 do
    NArr[I] := -1;

  SetLength(FEntryArray, XPrime);

  for I := 0 to FCount - 1 do
  begin
    Index := FEntryArray[I].FHashCode mod XPrime;
    FEntryArray[I].FNext := NArr[Index];
    NArr[Index] := I;
  end;

  { Reset bucket array }
  FBucketArray := NArr;
end;

function TDictionary<TKey, TValue>.SelectKeys: IEnexCollection<TKey>;
begin
  Result := Keys;
end;

function TDictionary<TKey, TValue>.SelectValues: IEnexCollection<TValue>;
begin
  Result := Values;
end;

procedure TDictionary<TKey, TValue>.SetItem(const AKey: TKey;
  const Value: TValue);
begin
  { Simply call insert }
  Insert(AKey, Value, false);
end;

procedure TDictionary<TKey, TValue>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TDictionary<TKey, TValue>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

function TDictionary<TKey, TValue>.TryGetValue(const AKey: TKey; out AFoundValue: TValue): Boolean;
var
  Index: NativeInt;
begin
  Index := FindEntry(AKey);

  if Index >= 0 then
     begin
       AFoundValue := FEntryArray[Index].FValue;
       Exit(True);
     end;

  { Key not found, simply fail }
  AFoundValue := Default(TValue);
  Result := False;
end;

function TDictionary<TKey, TValue>.ValueForKey(const AKey: TKey): TValue;
begin
  Result := GetItem(AKey);
end;

constructor TDictionary<TKey, TValue>.Create(
  const AArray: array of KVPair<TKey, TValue>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TDictionary<TKey, TValue>.Create(
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: array of KVPair<TKey, TValue>);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType, DefaultArrayLength);

  { Copy all items in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;

constructor TDictionary<TKey, TValue>.Create(
  const AArray: TDynamicArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TDictionary<TKey, TValue>.Create(
  const AArray: TFixedArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TDictionary<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TDynamicArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType, DefaultArrayLength);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;

constructor TDictionary<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TFixedArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType, DefaultArrayLength);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;

{ TDictionary<TKey, TValue>.TPairEnumerator }

constructor TDictionary<TKey, TValue>.TPairEnumerator.Create(const ADict: TDictionary<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FCurrentIndex := 0;
  FVer := ADict.FVer;
end;

destructor TDictionary<TKey, TValue>.TPairEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TDictionary<TKey, TValue>.TPairEnumerator.GetCurrent: KVPair<TKey,TValue>;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TDictionary<TKey, TValue>.TPairEnumerator.MoveNext: Boolean;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  while FCurrentIndex < FDict.FCount do
  begin
    if FDict.FEntryArray[FCurrentIndex].FHashCode >= 0 then
    begin
      FValue := KVPair.Create<TKey, TValue>(FDict.FEntryArray[FCurrentIndex].FKey,
                  FDict.FEntryArray[FCurrentIndex].FValue);

      Inc(FCurrentIndex);
      Result := True;
      Exit;
    end;

    Inc(FCurrentIndex);
  end;

  FCurrentIndex := FDict.FCount + 1;
  Result := False;
end;

{ TDictionary<TKey, TValue>.TKeyEnumerator }

constructor TDictionary<TKey, TValue>.TKeyEnumerator.Create(const ADict: TDictionary<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);
  
  FCurrentIndex := 0;
  FVer := ADict.FVer;
  FValue := default(TKey);
end;

destructor TDictionary<TKey, TValue>.TKeyEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TDictionary<TKey, TValue>.TKeyEnumerator.GetCurrent: TKey;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TDictionary<TKey, TValue>.TKeyEnumerator.MoveNext: Boolean;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  while FCurrentIndex < FDict.FCount do
  begin
    if FDict.FEntryArray[FCurrentIndex].FHashCode >= 0 then
    begin
      FValue := FDict.FEntryArray[FCurrentIndex].FKey;

      Inc(FCurrentIndex);
      Result := True;
      Exit;
    end;

    Inc(FCurrentIndex);
  end;

  FCurrentIndex := FDict.FCount + 1;
  Result := False;
end;


{ TDictionary<TKey, TValue>.TValueEnumerator }

constructor TDictionary<TKey, TValue>.TValueEnumerator.Create(const ADict: TDictionary<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FCurrentIndex := 0;
  FVer := ADict.FVer;
end;

destructor TDictionary<TKey, TValue>.TValueEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TDictionary<TKey, TValue>.TValueEnumerator.GetCurrent: TValue;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TDictionary<TKey, TValue>.TValueEnumerator.MoveNext: Boolean;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  while FCurrentIndex < FDict.FCount do
  begin
    if FDict.FEntryArray[FCurrentIndex].FHashCode >= 0 then
    begin
      FValue := FDict.FEntryArray[FCurrentIndex].FValue;

      Inc(FCurrentIndex);
      Result := True;
      Exit;
    end;

    Inc(FCurrentIndex);
  end;

  FCurrentIndex := FDict.FCount + 1;
  Result := False;
end;

{ TDictionary<TKey, TValue>.TKeyCollection }

constructor TDictionary<TKey, TValue>.TKeyCollection.Create(const ADict: TDictionary<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;

  { Install key type }
  InstallType(FDict.KeyType);
end;

destructor TDictionary<TKey, TValue>.TKeyCollection.Destroy;
begin
  inherited;
end;

function TDictionary<TKey, TValue>.TKeyCollection.GetCount: NativeUInt;
begin
  { Number of elements is the same as key }
  Result := FDict.Count;
end;

function TDictionary<TKey, TValue>.TKeyCollection.GetEnumerator: IEnumerator<TKey>;
begin
  Result := TKeyEnumerator.Create(Self.FDict);
end;

procedure TDictionary<TKey, TValue>.TKeyCollection.CopyTo(var AArray: array of TKey; const StartIndex: NativeUInt);
var
  I, X: NativeInt;
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < FDict.Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := StartIndex;

  for I := 0 to FDict.FCount - 1 do
  begin
    if (FDict.FEntryArray[I].FHashCode >= 0) then
    begin
       AArray[X] := FDict.FEntryArray[I].FKey;
       Inc(X);
    end;
  end;
end;

{ TDictionary<TKey, TValue>.TValueCollection }

constructor TDictionary<TKey, TValue>.TValueCollection.Create(const ADict: TDictionary<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;

  { Install key type }
  InstallType(FDict.ValueType);
end;

destructor TDictionary<TKey, TValue>.TValueCollection.Destroy;
begin
  inherited;
end;

function TDictionary<TKey, TValue>.TValueCollection.GetCount: NativeUInt;
begin
  { Number of elements is the same as key }
  Result := FDict.Count;
end;

function TDictionary<TKey, TValue>.TValueCollection.GetEnumerator: IEnumerator<TValue>;
begin
  Result := TValueEnumerator.Create(Self.FDict);
end;

procedure TDictionary<TKey, TValue>.TValueCollection.CopyTo(var AArray: array of TValue; const StartIndex: NativeUInt);
var
  I, X: NativeInt;
begin
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  { Check for indexes }
  if (NativeUInt(Length(AArray)) - StartIndex) < FDict.Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := StartIndex;

  for I := 0 to FDict.FCount - 1 do
  begin
    if (FDict.FEntryArray[I].FHashCode >= 0) then
    begin
       AArray[X] := FDict.FEntryArray[I].FValue;
       Inc(X);
    end;
  end;
end;


{ TObjectDictionary<TKey, TValue> }

function TObjectDictionary<TKey, TValue>.GetOwnsKeys: Boolean;
begin
  Result := FKeyWrapperType.AllowCleanup;
end;

function TObjectDictionary<TKey, TValue>.GetOwnsValues: Boolean;
begin
  Result := FValueWrapperType.AllowCleanup;
end;

procedure TObjectDictionary<TKey, TValue>.InstallTypes(const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
begin
  { Create a wrapper over the real type class and switch it }
  FKeyWrapperType := TMaybeObjectWrapperType<TKey>.Create(AKeyType);
  FValueWrapperType := TMaybeObjectWrapperType<TValue>.Create(AValueType);

  { Install overridden type }
  inherited InstallTypes(FKeyWrapperType, FValueWrapperType);
end;

procedure TObjectDictionary<TKey, TValue>.SetOwnsKeys(const Value: Boolean);
begin
  FKeyWrapperType.AllowCleanup := Value;
end;

procedure TObjectDictionary<TKey, TValue>.SetOwnsValues(const Value: Boolean);
begin
  FValueWrapperType.AllowCleanup := Value;
end;

end.
