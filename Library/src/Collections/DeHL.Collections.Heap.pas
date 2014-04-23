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
unit DeHL.Collections.Heap;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>heap</c> collection.</summary>
  ///  <remarks>This type is used to store its values in non-indexed fashion.</remarks>
  THeap<T> = class(TEnexCollection<T>, IDynamic)
  private type
    {$REGION 'Internal Types'}
    { Internal type to store heap entries }
    TEntry = record
      FNext: NativeInt;
      FValue: T;
    end;

    { Array of internal entries }
    TEntryArray = TArray<TEntry>;

    { Heap Enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FHeap: THeap<T>;
      FCurrentIndex: NativeUInt;
      FCurrent: T;
    public
      { Constructor }
      constructor Create(const AHeap: THeap<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;
    {$ENDREGION}

  private var
    FArray: TEntryArray;
    FFirstFree: NativeInt;

    FCount: NativeUInt;
    FVer: NativeUInt;

    { Setters and getters }
    function GetItem(const AId: NativeUInt): T;
    procedure SetItem(const AId: NativeUInt; const Value: T);

  protected
    ///  <summary>Returns the number of elements in the heap.</summary>
    ///  <returns>A positive value specifying the number of elements in the heap.</returns>
    function GetCount(): NativeUInt; override;

    ///  <summary>Returns the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the heap can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this method is greater or equal to the amount of elements in the heap. If this value
    ///  is greater then the number of elements, it means that the heap has some extra capacity to operate upon.</remarks>
    function GetCapacity(): NativeUInt;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The heap's initial capacity.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The heap's initial capacity.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the heap.</summary>
    ///  <remarks>This method clears the heap and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Adds an element to the heap.</summary>
    ///  <param name="AValue">The value to add.</param>
    ///  <returns>A number that uniquely identifies the element in the heap. This number should not be considered an index.</returns>
    function Add(const AValue: T): NativeUInt;

    ///  <summary>Removes the item from the heap.</summary>
    ///  <param name="AId">The ID of item.</param>
    ///  <returns>The value identified by the ID.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException"><paramref name="AId"/> is not a valid id for this heap.</exception>
    function Extract(const AId: NativeUInt): T;

    ///  <summary>Removes the item from the heap.</summary>
    ///  <param name="AId">The ID of item.</param>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException"><paramref name="AId"/> is not a valid id for this heap.</exception>
    ///  <remarks>This method invokes type object's cleaning routines for the removed value.</remarks>
    procedure Remove(const AId: NativeUInt);

    ///  <summary>Checks whether the heap contains a given ID.</summary>
    ///  <param name="AId">The ID to check.</param>
    ///  <returns><c>True</c> if the ID was issues by this heap and is valid; <c>False</c> otherwise.</returns>
    function Contains(const AId: NativeUInt): Boolean;

    ///  <summary>Tries to obtain the value associated with a given ID.</summary>
    ///  <param name="AId">The ID for which to try to retreive the value.</param>
    ///  <param name="AFoundValue">The found value (if the result is <c>True</c>).</param>
    ///  <returns><c>True</c> if the heap contains a value for the given ID; <c>False</c> otherwise.</returns>
    function TryGetValue(const AId: NativeUInt; out AFoundValue: T): Boolean;

    ///  <summary>Specifies the number of elements in the heap.</summary>
    ///  <returns>A positive value specifying the number of elements in the heap.</returns>
    property Count: NativeUInt read FCount;

    ///  <summary>Specifies the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the heap can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this property is greater or equal to the amount of elements in the heap. If this value
    ///  if greater then the number of elements, it means that the heap has some extra capacity to operate upon.</remarks>
    property Capacity: NativeUInt read GetCapacity;

    ///  <summary>Returns the item from associated with a given ID.</summary>
    ///  <param name="AId">The ID of the value.</param>
    ///  <returns>The element associated with the specified ID.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException"><paramref name="AId"/> is not a valid ID for this heap.</exception>
    property Items[const AId: NativeUInt]: T read GetItem write SetItem; default;

    ///  <summary>Removes the excess capacity from the heap.</summary>
    ///  <remarks>This method can be called manually to force the heap to drop the extra capacity it might hold. For example,
    ///  after performing some massive operations of a big heap, call this method to ensure that all extra memory held by the
    ///  heap is released.</remarks>
    procedure Shrink();

    ///  <summary>Forces the heap to increase its capacity.</summary>
    ///  <remarks>Call this method to force the heap to increase its capacity ahead of time. Manually adjusting the capacity
    ///  can be useful in certain situations.</remarks>
    procedure Grow();

    ///  <summary>Returns a new enumerator object used to enumerate this heap.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the heap.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<T>; override;

    ///  <summary>Copies the values stored in the heap to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the heap.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the heap.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const AStartIndex: NativeUInt); overload; override;

    ///  <summary>Checks whether the heap is empty.</summary>
    ///  <returns><c>True</c> if the heap is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the heap is empty.</remarks>
    function Empty(): Boolean; override;
  end;

  ///  <summary>The generic <c>heap</c> collection designed to store objects..</summary>
  ///  <remarks>This type is used to store its objects in non-indexed fashion.</remarks>
  TObjectHeap<T: class> = class(THeap<T>)
  private
    FWrapperType: TObjectWrapperType<T>;

    { Getters/Setters for OwnsObjects }
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);

  protected
    ///  <summary>Installs the type object.</summary>
    ///  <param name="AType">The type object to install.</param>
    ///  <remarks>This method installs a custom wrapper designed to suppress the cleanup of objects on request.
    ///  Make sure to call this method in descendant classes.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
     procedure InstallType(const AType: IType<T>); override;

  public
    ///  <summary>Specifies whether this heap owns the objects stored in it.</summary>
    ///  <returns><c>True</c> if the heap owns its objects; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the heap controls the life-time of the stored objects.</remarks>
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

const
  DefaultArrayLength = 32;

{ THeap<T> }

function THeap<T>.Add(const AValue: T): NativeUInt;
begin
  { Grow if required }
  if FCount = NativeUInt(Length(FArray)) then
    Grow();

  { Adjust the free list }
  Result := FFirstFree;
  FFirstFree := FArray[FFirstFree].FNext;

  { Actually store the value }
  FArray[Result].FNext := -1;
  FArray[Result].FValue := AValue;

  Inc(FVer);
  Inc(FCount);
end;

procedure THeap<T>.Clear;
var
  CV: Boolean;
  I: NativeInt;
begin
  CV := (ElementType <> nil) and (ElementType.Management = tmManual);

  for I := 0 to Length(FArray) - 1 do
  begin
    if CV and (FArray[I].FNext = -1) then
      ElementType.Cleanup(FArray[I].FValue);

    { Adjust the next free list indices }
    FArray[I].FNext := I + 1;
  end;

  { The first free one starts at zero }
  FFirstFree := 0;

  Inc(FVer);
  FCount := 0;
end;

function THeap<T>.Contains(const AId: NativeUInt): Boolean;
begin
  { Check the ID }
  Result := (AId < NativeUInt(Length(FArray))) and (FArray[AId].FNext = -1);
end;

procedure THeap<T>.CopyTo(var AArray: array of T; const AStartIndex: NativeUInt);
var
  I, X: NativeUInt;
begin
  { Check for indexes }
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  if (NativeUInt(Length(AArray)) - AStartIndex) < FCount then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Copy all good values to the array }
  X := AStartIndex;

  { Iterate over the internal array and add what is good }
  for I := 0 to Length(FArray) - 1 do
    if FArray[I].FNext = -1 then
    begin
      AArray[X] := FArray[I].FValue;
      Inc(X);
    end;
end;

constructor THeap<T>.Create;
begin
  Create(TType<T>.Default, DefaultArrayLength);
end;

constructor THeap<T>.Create(const AInitialCapacity: NativeUInt);
begin
  Create(TType<T>.Default, AInitialCapacity);
end;

constructor THeap<T>.Create(const AType: IType<T>);
begin
  Create(AType, DefaultArrayLength);
end;

constructor THeap<T>.Create(const AType: IType<T>; const AInitialCapacity: NativeUInt);
var
  I: NativeUInt;
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  InstallType(AType);

  FCount := 0;
  FVer := 0;

  SetLength(FArray, AInitialCapacity);

  { Add all new entries to the free list }
  for I := 0 to AInitialCapacity - 1 do
    FArray[I].FNext := I + 1;

  FFirstFree := 0;
end;

destructor THeap<T>.Destroy;
begin
  { First, clear myself }
  Clear();

  inherited;
end;

function THeap<T>.Empty: Boolean;
begin
  { Ha! }
  Result := (FCount = 0);
end;

function THeap<T>.Extract(const AId: NativeUInt): T;
begin
  { Check the ID }
  if (AId >= NativeUInt(Length(FArray))) or (FArray[AId].FNext <> -1) then
    ExceptionHelper.Throw_KeyNotFoundError('AId');

  { Extract the result }
  Result := FArray[AId].FValue;

  { Free this spot for other to use }
  FArray[AId].FNext := FFirstFree;
  FArray[AId].FValue := default(T);
  FFirstFree := AId;

  Inc(FVer);
  Dec(FCount);
end;

function THeap<T>.GetCapacity: NativeUInt;
begin
  Result := Length(FArray);
end;

function THeap<T>.GetCount: NativeUInt;
begin
  Result := FCount;
end;

function THeap<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

function THeap<T>.GetItem(const AId: NativeUInt): T;
begin
  { Check the ID }
  if (AId >= NativeUInt(Length(FArray))) or (FArray[AId].FNext <> -1) then
    ExceptionHelper.Throw_KeyNotFoundError('AId');

  { Extract the result }
  Result := FArray[AId].FValue;
end;

procedure THeap<T>.Grow;
var
  LNewLength, LOldLength: NativeUInt;
  I: NativeInt;
begin
  LOldLength := Capacity;

  { Calculate the new size }
  if LOldLength < DefaultArrayLength then
     LNewLength := DefaultArrayLength
  else
     LNewLength := LOldLength * 2;

  { Set the new size }
  SetLength(FArray, LNewLength);

  { Add all new entries to the free list }
  for I := LOldLength to LNewLength - 2 do
    FArray[I].FNext := I + 1;

  { Connect the old free list with the newly added one }
  FArray[LNewLength - 1].FNext := FFirstFree;
  FFirstFree := LOldLength;
end;

procedure THeap<T>.Remove(const AId: NativeUInt);
var
  LValue: T;
begin
  { Obtain the value at position }
  LValue := Extract(AId);

  { Cleanup the value if necessary }
  if ElementType.Management = tmManual then
    ElementType.Cleanup(LValue);
end;

procedure THeap<T>.SetItem(const AId: NativeUInt; const Value: T);
begin
  { Check the ID }
  if (AId >= NativeUInt(Length(FArray))) or (FArray[AId].FNext <> -1) then
    ExceptionHelper.Throw_KeyNotFoundError('AId');

  { Cleanup the old inhabitant }
  if ElementType.Management = tmManual then
    ElementType.Cleanup(FArray[AId].FValue);

  { And set the new one }
  FArray[AId].FValue := Value;
end;

procedure THeap<T>.Shrink;
var
  LLen: NativeInt;
begin
  { Find the last occupied spot }
  LLen := Length(FArray);
  while (LLen > 0) and (FArray[LLen - 1].FNext <> -1) do Dec(LLen);

  { Readjust the array length }
  SetLength(FArray, LLen);
end;

function THeap<T>.TryGetValue(const AId: NativeUInt; out AFoundValue: T): Boolean;
begin
  { Check the ID }
  if (AId >= NativeUInt(Length(FArray))) or (FArray[AId].FNext <> -1) then
    Exit(false);

  { Extract the result }
  AFoundValue := FArray[AId].FValue;
  Result := true;
end;

{ THeap<T>.TEnumerator }

constructor THeap<T>.TEnumerator.Create(const AHeap: THeap<T>);
begin
  FHeap := AHeap;
  FVer := AHeap.FVer;
  FCurrent := default(T);
  FCurrentIndex := 0;

  KeepObjectAlive(FHeap);
end;

destructor THeap<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FHeap);
  inherited;
end;

function THeap<T>.TEnumerator.GetCurrent: T;
begin
  Result := FCurrent;
end;

function THeap<T>.TEnumerator.MoveNext: Boolean;
begin
  if FVer <> FHeap.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  { Go over all array and gather what we need }
  while FCurrentIndex < NativeUInt(Length(FHeap.FArray)) do
  begin
    { If the spot is occupied, take the value and stop }
    if FHeap.FArray[FCurrentIndex].FNext = -1 then
    begin
      FCurrent := FHeap.FArray[FCurrentIndex].FValue;

      Inc(FCurrentIndex);
      Exit(true);
    end else
      Inc(FCurrentIndex);
  end;

  { All array was walked, nothing found, too bad }
  Result := false;
end;

{ TObjectHeap<T> }

function TObjectHeap<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectHeap<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

procedure TObjectHeap<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.
