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
unit DeHL.Collections.Queue;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>queue (FIFO)</c> collection.</summary>
  ///  <remarks>This type uses an internal array to store its values.</remarks>
  TQueue<T> = class(TEnexCollection<T>, IQueue<T>, IDynamic)
  private type
    {$REGION 'Internal Types'}
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FQueue: TQueue<T>;
      FElement: T;
      FCount, FHead: NativeUInt;

    public
      { Constructor }
      constructor Create(const AQueue : TQueue<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;
    {$ENDREGION}

  private var
    FVer: NativeUInt;
    FHead: NativeUInt;
    FTail: NativeUInt;
    FLength: NativeUInt;
    FArray: TArray<T>;

    procedure SetCapacity(NewCapacity : NativeUInt);
  protected
    ///  <summary>Called when the serialization process is about to begin.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    procedure StartSerializing(const AData: TSerializationData); override;

    ///  <summary>Called when the deserialization process is about to begin.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartDeserializing(const AData: TDeserializationData); override;

    ///  <summary>Called when the an element has been deserialized and needs to be inserted into the queue.</summary>
    ///  <param name="AElement">The element that was deserialized.</param>
    ///  <remarks>This method simply adds the element to the queue.</remarks>
    procedure DeserializeElement(const AElement: T); override;

    ///  <summary>Returns the number of elements in the queue.</summary>
    ///  <returns>A positive value specifying the number of elements in the queue.</returns>
    function GetCount(): NativeUInt; override;

    ///  <summary>Returns the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the queue can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this method is greater or equal to the amount of elements in the queue. If this value
    ///  is greater then the number of elements, it means that the queue has some extra capacity to operate upon.</remarks>
    function GetCapacity(): NativeUInt;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The queue's initial capacity.</param>
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
    ///  <param name="AInitialCapacity">The queue's initial capacity.</param>
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
    ///  <param name="AType">A type object decribing the elements in the queue.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the queue.</summary>
    ///  <remarks>This method clears the queue and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Appends an element to the top of the queue.</summary>
    ///  <param name="AValue">The value to append.</param>
    procedure Enqueue(const AValue: T);

    ///  <summary>Retreives the element from the bottom of the queue.</summary>
    ///  <returns>The value at the bottom of the queue.</returns>
    ///  <remarks>This method removes the element from the bottom of the queue.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Dequeue(): T;

    ///  <summary>Reads the element from the bottom of the queue.</summary>
    ///  <returns>The value at the bottom of the queue.</returns>
    ///  <remarks>This method does not remove the element from the bottom of the queue. It merely reads it's value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Peek(): T;

    ///  <summary>Checks whether the queue contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the queue; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;

    ///  <summary>Specifies the number of elements in the queue.</summary>
    ///  <returns>A positive value specifying the number of elements in the queue.</returns>
    property Count: NativeUInt read FLength;

    ///  <summary>Specifies the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the queue can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this property is greater or equal to the amount of elements in the queue. If this value
    ///  if greater then the number of elements, it means that the queue has some extra capacity to operate upon.</remarks>
    property Capacity: NativeUInt read GetCapacity;

    ///  <summary>Removes the excess capacity from the queue.</summary>
    ///  <remarks>This method can be called manually to force the queue to drop the extra capacity it might hold. For example,
    ///  after performing some massive operations of a big list, call this method to ensure that all extra memory held by the
    ///  queue is released.</remarks>
    procedure Shrink();

    ///  <summary>Forces the queue to increase its capacity.</summary>
    ///  <remarks>Call this method to force the queue to increase its capacity ahead of time. Manually adjusting the capacity
    ///  can be useful in certain situations.</remarks>
    procedure Grow();

    ///  <summary>Returns a new enumerator object used to enumerate this queue.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the queue.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<T>; override;

    ///  <summary>Copies the values stored in the queue to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the queue.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the queue.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const AStartIndex: NativeUInt); overload; override;

    ///  <summary>Checks whether the queue is empty.</summary>
    ///  <returns><c>True</c> if the queue is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the queue is empty.</remarks>
    function Empty(): Boolean; override;

    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the queue considered to have the biggest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Max(): T; override;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the queue considered to have the smallest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Min(): T; override;

    ///  <summary>Returns the first element.</summary>
    ///  <returns>The first element in the queue.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function First(): T; override;

    ///  <summary>Returns the first element or a default if the queue is empty.</summary>
    ///  <param name="ADefault">The default value returned if the queue is empty.</param>
    ///  <returns>The first element in queue if the queue is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function FirstOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the last element.</summary>
    ///  <returns>The last element in the queue.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Last(): T; override;

    ///  <summary>Returns the last element or a default if the queue is empty.</summary>
    ///  <param name="ADefault">The default value returned if the queue is empty.</param>
    ///  <returns>The last element in queue if the queue is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function LastOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the single element stored in the queue.</summary>
    ///  <returns>The element in queue.</returns>
    ///  <remarks>This method checks if the queue contains just one element, in which case it is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionNotOneException">There is more than one element in the queue.</exception>
    function Single(): T; override;

    ///  <summary>Returns the single element stored in the queue, or a default value.</summary>
    ///  <param name="ADefault">The default value returned if there is less or more elements in the queue.</param>
    ///  <returns>The element in the queue if the condition is satisfied; <paramref name="ADefault"/> is returned otherwise.</returns>
    ///  <remarks>This method checks if the queue contains just one element, in which case it is returned. Otherwise
    ///  the value in <paramref name="ADefault"/> is returned.</remarks>
    function SingleOrDefault(const ADefault: T): T; override;

    ///  <summary>Aggregates a value based on the queue's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <returns>A value that contains the queue's aggregated value.</returns>
    ///  <remarks>This method returns the first element if the queue only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Aggregate(const AAggregator: TFunc<T, T, T>): T; override;

    ///  <summary>Aggregates a value based on the queue's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <param name="ADefault">The default value returned if the queue is empty.</param>
    ///  <returns>A value that contains the queue's aggregated value. If the queue is empty, <paramref name="ADefault"/> is returned.</returns>
    ///  <remarks>This method returns the first element if the queue only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    function AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T; override;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <returns>The element from the specified position.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function ElementAt(const Index: NativeUInt): T; override;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <param name="ADefault">The default value returned if the queue is empty.</param>
    ///  <returns>The element from the specified position if the queue is not empty and the position is not out of bounds; otherwise
    ///  the value of <paramref name="ADefault"/> is returned.</returns>
    function ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T; override;

    ///  <summary>Check whether at least one element in the queue satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if the at least one element satisfies a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole queue and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>True</c>. The logical equivalent of this operation is "OR".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;

    ///  <summary>Checks that all elements in the queue satisfy a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if all elements satisfy a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole queue and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>False</c>. The logical equivalent of this operation is "AND".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function All(const APredicate: TFunc<T, Boolean>): Boolean; override;

    ///  <summary>Checks whether the elements in this queue are equal to the elements in another collection.</summary>
    ///  <param name="ACollection">The collection to compare to.</param>
    ///  <returns><c>True</c> if the collections are equal; <c>False</c> if the collections are different.</returns>
    ///  <remarks>This methods checks that each element at position X in this queue is equal to an element at position X in
    ///  the provided collection. If the number of elements in both collections are different, then the collections are considered different.
    ///  Note that comparison of element is done using the type object used by this queue. This means that comparing this collection
    ///  to another one might yeild a different result than comparing the other collection to this one.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function EqualsTo(const ACollection: IEnumerable<T>): Boolean; override;
  end;

  ///  <summary>The generic <c>queue (FIFO)</c> collection designed to store objects.</summary>
  ///  <remarks>This type uses an internal array to store its objects.</remarks>
  TObjectQueue<T: class> = class(TQueue<T>)
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
    ///  <summary>Specifies whether this queue owns the objects stored in it.</summary>
    ///  <returns><c>True</c> if the queue owns its objects; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the queue controls the life-time of the stored objects.</remarks>
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

const
  DefaultArrayLength = 8;

{ TQueue<T> }

function TQueue<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
var
  I, H: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := FArray[FHead];

  H := (FHead + 1) mod NativeUInt(Length(FArray));

  for I := 1 to FLength - 1 do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, FArray[H]);

    { Circulate Head }
    H := (H + 1) mod NativeUInt(Length(FArray));
  end;
end;

function TQueue<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
var
  I, H: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FLength = 0 then
    Exit(ADefault);

  { Select the first element as comparison base }
  Result := FArray[FHead];

  H := (FHead + 1) mod NativeUInt(Length(FArray));

  for I := 1 to FLength - 1 do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, FArray[H]);

    { Circulate Head }
    H := (H + 1) mod NativeUInt(Length(FArray));
  end;
end;

function TQueue<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  I, H: NativeUInt;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if FLength > 0 then
  begin
    H := FHead;
    for I := 0 to FLength - 1 do
    begin
      if not APredicate(FArray[H]) then
        Exit(false);

      { Circulate Head }
      H := (H + 1) mod NativeUInt(Length(FArray));
    end;
  end;

  Result := true;
end;

function TQueue<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  I, H: NativeUInt;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if FLength > 0 then
  begin
    H := FHead;
    for I := 0 to FLength - 1 do
    begin
      if APredicate(FArray[H]) then
        Exit(true);

      { Circulate Head }
      H := (H + 1) mod NativeUInt(Length(FArray));
    end;
  end;

  Result := false;
end;

procedure TQueue<T>.Clear;
var
  Element: T;
begin
  if (ElementType <> nil) and (ElementType.Management() = tmManual) then
  begin
    { If must cleanup, use the dequeue method }
    while Count > 0 do
    begin
      Element := Dequeue();
      ElementType.Cleanup(Element);
    end;
  end else
  begin
    { Clear all internals }
    FTail := 0;
    FHead := 0;
    FLength := 0;

    Inc(FVer);
  end;
end;

function TQueue<T>.Contains(const AValue: T): Boolean;
var
  I       : NativeUInt;
  Capacity: NativeUInt;
begin
  { Do a look-up in all the queue }
  Result := False;

  I := FHead;
  Capacity := Length(FArray);

  while I <> FTail do
  begin
    if ElementType.AreEqual(FArray[I], AValue) then
    begin
      Result := True;
      Break;
    end;

    { Next + wrap over }
    I := (I + 1) mod Capacity;
  end;

end;
                 
procedure TQueue<T>.CopyTo(var AArray: array of T; const AStartIndex: NativeUInt);
var
  I, X    : NativeUInt;
  Capacity: NativeUInt;

begin
  { Check for indexes }
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - AStartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := AStartIndex;
  I := FHead;
  Capacity := Length(FArray);

  while FTail <> I do
  begin
    { Copy value }
    AArray[X] := FArray[I];

    { Next + wrap over }
    I := (I + 1) mod Capacity;
    Inc(X);
  end;
end;

constructor TQueue<T>.Create(const AType: IType<T>;
  const ACollection: IEnumerable<T>);
var
  V: T;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Initialize instance }
  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Try to copy the given Enumerable }
  for V in ACollection do
  begin
    { Perform a simple push }
    Enqueue(V);
  end;
end;

constructor TQueue<T>.Create;
begin
  Create(TType<T>.Default);
end;

constructor TQueue<T>.Create(const AInitialCapacity: NativeUInt);
begin
  Create(TType<T>.Default, AInitialCapacity);
end;

constructor TQueue<T>.Create(const ACollection: IEnumerable<T>);
begin
  Create(TType<T>.Default, ACollection);
end;

constructor TQueue<T>.Create(const AType: IType<T>;
  const AInitialCapacity: NativeUInt);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  InstallType(AType);

  FVer := 0;
  FTail := 0;
  FLength := 0;
  FHead := 0;
  SetLength(FArray, AInitialCapacity);
end;

constructor TQueue<T>.Create(const AType: IType<T>);
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);
end;

function TQueue<T>.ElementAt(const Index: NativeUInt): T;
var
  H: NativeUInt;
begin
  if (Index >= FLength) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');

  H := (FHead + Index) mod NativeUInt(Length(FArray));
  Result := FArray[H];
end;

function TQueue<T>.ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T;
var
  H: NativeUInt;
begin
  if (AIndex >= FLength) then
    Exit(ADefault);

  H := (FHead + AIndex) mod NativeUInt(Length(FArray));
  Result := FArray[H];
end;

function TQueue<T>.Empty: Boolean;
begin
  Result := (FLength = 0);
end;

procedure TQueue<T>.Enqueue(const AValue: T);
var
  NewCapacity: NativeUInt;
begin
  { Ensure Capacity }
  if FLength = NativeUInt(Length(FArray)) then
  begin
    NewCapacity := Length(FArray) * 2;

    if NewCapacity < DefaultArrayLength then
       NewCapacity := Length(FArray) + DefaultArrayLength;

    SetCapacity(NewCapacity);
  end;

  { Place the element to the end of the list }
  FArray[FTail] := AValue;  
  FTail := (FTail + 1) mod NativeUInt(Length(FArray));
  
  Inc(FLength);
  Inc(FVer);
end;

function TQueue<T>.EqualsTo(const ACollection: IEnumerable<T>): Boolean;
var
  V: T;
  I, H: NativeUInt;
begin
  I := 0;
  H := FHead;

  for V in ACollection do
  begin
    if I >= FLength then
      Exit(false);

    if not ElementType.AreEqual(FArray[H], V) then
      Exit(false);

    H := (H + 1) mod NativeUInt(Length(FArray));
    Inc(I);
  end;

  if I < FLength then
    Exit(false);

  Result := true;
end;

function TQueue<T>.First: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FArray[FHead];
end;

function TQueue<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else
    Result := FArray[FHead];
end;

procedure TQueue<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Enqueue(AElement);
end;

destructor TQueue<T>.Destroy;
begin
  { Cleanup }
  Clear();

  inherited;
end;

function TQueue<T>.Dequeue: T;
begin
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Get the head }
  Result := FArray[FHead];

  { Circulate Head }
  FHead := (FHead + 1) mod NativeUInt(Length(FArray));

  Dec(FLength);
  Inc(FVer);
end;

function TQueue<T>.GetCapacity: NativeUInt;
begin
  Result := Length(FArray);
end;

function TQueue<T>.GetCount: NativeUInt;
begin
  Result := FLength;
end;

function TQueue<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

procedure TQueue<T>.Grow;
var
  NewCapacity: NativeUInt;
begin
  { Ensure Capacity }
  if FLength = NativeUInt(Length(FArray)) then
  begin
    NewCapacity := Length(FArray) * 2;

    if NewCapacity < DefaultArrayLength then
       NewCapacity := Length(FArray) + DefaultArrayLength;

    SetCapacity(NewCapacity);
  end;
end;

function TQueue<T>.Last: T;
var
  T: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  T := (FTail - 1) mod NativeUInt(Length(FArray));
  Result := FArray[T];
end;

function TQueue<T>.LastOrDefault(const ADefault: T): T;
var
  T: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else
  begin
    T := (FTail - 1) mod NativeUInt(Length(FArray));
    Result := FArray[T];
  end;
end;

function TQueue<T>.Max: T;
var
  I, H: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  H := FHead;
  Result := FArray[H];

  H := (H + 1) mod NativeUInt(Length(FArray));

  for I := 1 to FLength - 1 do
  begin
    if ElementType.Compare(FArray[H], Result) > 0 then
      Result := FArray[I];

    { Circulate Head }
    H := (H + 1) mod NativeUInt(Length(FArray));
  end;
end;

function TQueue<T>.Min: T;
var
  I, H: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  H := FHead;
  Result := FArray[H];

  H := (H + 1) mod NativeUInt(Length(FArray));

  for I := 1 to FLength - 1 do
  begin
    if ElementType.Compare(FArray[H], Result) < 0 then
      Result := FArray[I];

    { Circulate Head }
    H := (H + 1) mod NativeUInt(Length(FArray));
  end;
end;

function TQueue<T>.Peek: T;
begin
  if FTail = FHead then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FArray[FHead];
end;

procedure TQueue<T>.SetCapacity(NewCapacity: NativeUInt);
var
 NewArray: TArray<T>;
begin
  { Create new array }
  SetLength(NewArray, NewCapacity);

  if (FLength > 0) then
  begin
    if FHead < FTail then
       Move(FArray[FHead], NewArray[0], FLength * SizeOf(T))
    else
    begin
       Move(FArray[FHead], NewArray[0], (FLength - FHead) * SizeOf(T));
       Move(FArray[0], NewArray[NativeUInt(Length(FArray)) - FHead], FTail * SizeOf(T));
    end;
  end;

  { Switch arrays }
  FArray := nil;
  FArray := NewArray;
  
  FTail := FLength;
  FHead := 0;
  Inc(FVer);
end;

procedure TQueue<T>.Shrink;
begin
  { Ensure Capacity }
  if FLength < Capacity then
  begin
    SetCapacity(FLength);
  end;
end;

function TQueue<T>.Single: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError()
  else if FLength > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FArray[FHead];
end;

function TQueue<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else if FLength > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FArray[FHead];
end;

procedure TQueue<T>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TQueue<T>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

constructor TQueue<T>.Create(const AArray: array of T);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TQueue<T>.Create(const AType: IType<T>; const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Copy array }
  for I := 0 to Length(AArray) - 1 do
  begin
    Enqueue(AArray[I]);
  end;
end;

constructor TQueue<T>.Create(const AArray: TFixedArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TQueue<T>.Create(const AArray: TDynamicArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TQueue<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Enqueue(AArray[I]);
    end;
end;

constructor TQueue<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Enqueue(AArray[I]);
    end;
end;

{ TQueue<T>.TEnumerator }

constructor TQueue<T>.TEnumerator.Create(const AQueue: TQueue<T>);
begin
  { Initialize }
  FQueue := AQueue;
  KeepObjectAlive(FQueue);

  FCount := 0;
  FElement := Default(T);
  FHead  := FQueue.FHead;
  FVer := AQueue.FVer;
end;

destructor TQueue<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FQueue);
  inherited;
end;

function TQueue<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FQueue.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FElement;
end;

function TQueue<T>.TEnumerator.MoveNext: Boolean;
begin
  if FVer <> FQueue.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  if (FCount >= FQueue.FLength) then
    Exit(false)
  else
    Result := true;

  FElement := FQueue.FArray[FHead];

  { Circulate Head }
  FHead := (FHead + 1) mod NativeUInt(Length(FQueue.FArray));
  Inc(FCount);
end;

{ TObjectQueue<T> }

procedure TObjectQueue<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectQueue<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectQueue<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.
