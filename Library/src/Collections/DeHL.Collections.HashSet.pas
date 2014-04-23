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
unit DeHL.Collections.HashSet;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Exceptions,
     DeHL.Math.Algorithms,
     DeHL.Collections.Base,
     DeHL.Arrays;

type
  ///  <summary>The generic <c>set</c> collection.</summary>
  ///  <remarks>This type uses hashing techniques to store its values.</remarks>
  THashSet<T> = class(TEnexCollection<T>, ISet<T>)
  private type
    {$REGION 'Internal Types'}
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FDict: THashSet<T>;
      FCurrentIndex: NativeInt;
      FValue: T;

    public
      { Constructor }
      constructor Create(const ADict: THashSet<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

    TEntry = record
      FHashCode: NativeInt;
      FNext: NativeInt;
      FKey: T;
    end;

    TBucketArray = array of NativeInt;
    {$ENDREGION}

  private var
    FBucketArray: TBucketArray;
    FEntryArray: TArray<TEntry>;
    FCount: NativeInt;
    FFreeCount: NativeInt;
    FFreeList: NativeInt;
    FVer: NativeUInt;

    { Internal }
    procedure InitializeInternals(const Capacity: NativeUInt);
    procedure Insert(const AKey: T; const ShouldAdd: Boolean = true);
    function FindEntry(const AKey: T): NativeInt;
    procedure Resize();
    function Hash(const AKey: T): NativeInt;

  protected
    ///  <summary>Called when the serialization process is about to begin.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    procedure StartSerializing(const AData: TSerializationData); override;

    ///  <summary>Called when the deserialization process is about to begin.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartDeserializing(const AData: TDeserializationData); override;

    ///  <summary>Called when the an element has been deserialized and needs to be inserted into the set.</summary>
    ///  <param name="AElement">The element that was deserialized.</param>
    ///  <remarks>This method simply adds the element to the set.</remarks>
    procedure DeserializeElement(const AElement: T); override;

    ///  <summary>Returns the number of elements in the set.</summary>
    ///  <returns>A positive value specifying the number of elements in the set.</returns>
    function GetCount(): NativeUInt; override;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The set's initial capacity.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const ACollection: IEnumerable<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: array of T); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TDynamicArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TFixedArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The set's initial capacity.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const ACollection: IEnumerable<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: array of T); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TDynamicArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the set.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the set.</summary>
    ///  <remarks>This method clears the set and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Adds an element to the set.</summary>
    ///  <param name="AValue">The value to add.</param>
    ///  <remarks>If the set already contains the given value, nothing happens.</remarks>
    procedure Add(const AValue: T);

    ///  <summary>Removes a given value from the set.</summary>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>If the set does not contain the given value, nothing happens.</remarks>
    procedure Remove(const AValue: T);

    ///  <summary>Checks whether the set contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the set; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;

    ///  <summary>Specifies the number of elements in the set.</summary>
    ///  <returns>A positive value specifying the number of elements in the set.</returns>
    property Count: NativeUInt read GetCount;

    ///  <summary>Returns a new enumerator object used to enumerate this set.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the set.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator() : IEnumerator<T>; override;

    ///  <summary>Copies the values stored in the set to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the set.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the set.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const StartIndex: NativeUInt); overload; override;

    ///  <summary>Checks whether the set is empty.</summary>
    ///  <returns><c>True</c> if the set is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the set is empty.</remarks>
    function Empty(): Boolean; override;
  end;

  ///  <summary>The generic <c>set</c> collection designed to store objects.</summary>
  ///  <remarks>This type uses hashing techniques to store its objects.</remarks>
  TObjectHashSet<T: class> = class(THashSet<T>)
  private
    FWrapperType: TObjectWrapperType<T>;

    { Getters/Setters for OwnsObjects }
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);

  protected
    ///  <summary>Installs the type object.</summary>
    ///  <param name="AType">The type object to install.</param>
    ///  <remarks>This method installs a custom wrapper designed to suppress the cleanup of objects on request. Make sure to call this method in
    ///  descendant classes.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    procedure InstallType(const AType: IType<T>); override;

  public
    ///  <summary>Specifies whether this set owns the objects stored in it.</summary>
    ///  <returns><c>True</c> if the set owns its objects; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the set controls the life-time of the stored objects.</remarks>
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

const
  DefaultArrayLength = 32;

{ THashSet<T> }

procedure THashSet<T>.Add(const AValue: T);
begin
 { Call insert }
 Insert(AValue, False);
end;

procedure THashSet<T>.Clear;
var
  I: NativeInt;
  KC, MKC: Boolean;
begin
  if FCount > 0 then
  begin
    for I := 0 to Length(FBucketArray) - 1 do
      FBucketArray[I] := -1;
  end;

  { Cleanup each key if necessary }
  if (Length(FEntryArray) > 0) then
  begin
    KC := (ElementType <> nil) and (ElementType.Management = tmManual);
    MKC := (ElementType <> nil) and (ElementType.Management = tmCompiler);

    if KC or MKC then
    begin
      for I := 0 to Length(FEntryArray) - 1 do
        if FEntryArray[I].FHashCode >= 0 then
        begin
          if KC then
            ElementType.Cleanup(FEntryArray[I].FKey)

          else if MKC then
            FEntryArray[I].FKey := default(T);
        end;
    end;
  end;

  if Length(FEntryArray) > 0 then
     FillChar(FEntryArray[0], Length(FEntryArray) * SizeOf(TEntry), 0);

  FFreeList := -1;
  FCount := 0;
  FFreeCount := 0;

  Inc(FVer);
end;

function THashSet<T>.Contains(const AValue: T): Boolean;
begin
  Result := (FindEntry(AValue) >= 0);
end;

procedure THashSet<T>.CopyTo(
  var AArray: array of T; const StartIndex: NativeUInt);
var
  I, X: NativeInt;
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := StartIndex;

  for I := 0 to FCount - 1 do
  begin
    if (FEntryArray[I].FHashCode >= 0) then
    begin
       AArray[X] := FEntryArray[I].FKey;
       Inc(X);
    end;
  end;
end;

constructor THashSet<T>.Create;
begin
  Create(TType<T>.Default);
end;

constructor THashSet<T>.Create(const AInitialCapacity: NativeUInt);
begin
  Create(TType<T>.Default, AInitialCapacity);
end;

constructor THashSet<T>.Create(const ACollection: IEnumerable<T>);
begin
  Create(TType<T>.Default, ACollection);
end;

constructor THashSet<T>.Create(const AType: IType<T>; const AInitialCapacity: NativeUInt);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  { Install the type }
  InstallType(AType);

  FVer := 0;
  FCount := 0;
  FFreeCount := 0;
  FFreeList := 0;

  InitializeInternals(AInitialCapacity);
end;

constructor THashSet<T>.Create(const AType: IType<T>; const ACollection: IEnumerable<T>);
var
  V : T;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Pump in all items }
  for V in ACollection do
    Add(V);
end;

constructor THashSet<T>.Create(const AType: IType<T>);
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);
end;

procedure THashSet<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Add(AElement);
end;

destructor THashSet<T>.Destroy;
begin
  { Clear first }
  Clear();

  inherited;
end;

function THashSet<T>.Empty: Boolean;
begin
  Result := (FCount = 0);
end;

function THashSet<T>.FindEntry(const AKey: T): NativeInt;
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
      if (FEntryArray[I].FHashCode = HashCode) and ElementType.AreEqual(FEntryArray[I].FKey, AKey) then
         begin Result := I; Exit; end;

      I := FEntryArray[I].FNext;
    end;
  end;
end;

function THashSet<T>.GetCount: NativeUInt;
begin
  Result := (FCount - FFreeCount);
end;

function THashSet<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := THashSet<T>.TEnumerator.Create(Self);
end;

function THashSet<T>.Hash(const AKey: T): NativeInt;
const
  PositiveMask = not NativeInt(1 shl (SizeOf(NativeInt) * 8 - 1));
begin
  Result := PositiveMask and ((PositiveMask and ElementType.GenerateHashCode(AKey)) + 1);
end;

procedure THashSet<T>.InitializeInternals(const Capacity: NativeUInt);
var
  XPrime: NativeInt;
  I: NativeInt;
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

procedure THashSet<T>.Insert(const AKey: T; const ShouldAdd: Boolean);
var
  FreeList: NativeInt;
  Index: NativeInt;
  HashCode: NativeInt;
  I: NativeInt;
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
    if (FEntryArray[I].FHashCode = HashCode) and ElementType.AreEqual(FEntryArray[I].FKey, AKey) then
    begin
      if (ShouldAdd) then
        ExceptionHelper.Throw_DuplicateKeyError('AKey');

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
  FEntryArray[FreeList].FNext := FBucketArray[Index];

  FBucketArray[Index] := FreeList;
  Inc(FVer);
end;

procedure THashSet<T>.Remove(const AValue: T);
var
  HashCode, Index, I, RemIndex: NativeInt;
begin
  if Length(FBucketArray) > 0 then
  begin
    { Generate the hash code }
    HashCode := Hash(AValue);

    Index := HashCode mod Length(FBucketArray);
    RemIndex := -1;

    I := FBucketArray[Index];

    while I >= 0 do
    begin
      if (FEntryArray[I].FHashCode = HashCode) and ElementType.AreEqual(FEntryArray[I].FKey, AValue) then
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
        FEntryArray[I].FKey := default(T);

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

procedure THashSet<T>.Resize;
var
  XPrime, I, Index: NativeInt;
  NArr: TBucketArray;
begin
  XPrime := Prime.GetNearestProgressionPositive(FCount * 2);

  SetLength(NArr, XPrime);

  for I := 0 to Length(NArr) - 1 do
  begin
    NArr[I] := -1;
  end;

  SetLength(FEntryArray, XPrime);

  for I := 0 to FCount - 1 do
  begin
    Index := FEntryArray[I].FHashCode mod XPrime;
    FEntryArray[I].FNext := NArr[Index];
    NArr[Index] := I;
  end;

  { Reset bucket array }
  FBucketArray := nil;
  FBucketArray := NArr;
end;

procedure THashSet<T>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure THashSet<T>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

{ THashSet<T>.HPairEnumerator }

constructor THashSet<T>.TEnumerator.Create(const ADict : THashSet<T>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FCurrentIndex := 0;
  FVer := ADict.FVer;
end;

destructor THashSet<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function THashSet<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FDict.FVer then
    ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function THashSet<T>.TEnumerator.MoveNext: Boolean;
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

constructor THashSet<T>.Create(const AArray: array of T);
begin
  Create(TType<T>.Default, AArray);
end;

constructor THashSet<T>.Create(const AType: IType<T>;
  const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Copy all in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;

constructor THashSet<T>.Create(const AArray: TFixedArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor THashSet<T>.Create(const AArray: TDynamicArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor THashSet<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Add(AArray[I]);
    end;
end;

constructor THashSet<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Add(AArray[I]);
    end;
end;

{ TObjectHashSet<T> }

procedure TObjectHashSet<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectHashSet<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectHashSet<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.
