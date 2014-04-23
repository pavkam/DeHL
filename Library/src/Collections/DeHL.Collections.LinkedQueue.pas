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
unit DeHL.Collections.LinkedQueue;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Serialization,
     DeHL.Arrays,
     DeHL.Collections.LinkedList,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>queue (FIFO)</c> collection.</summary>
  ///  <remarks>This type uses a linked list to store its values.</remarks>
  TLinkedQueue<T> = class(TEnexCollection<T>, IQueue<T>)
  private var
    FList: TLinkedList<T>;

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
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

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
    property Count: NativeUInt read GetCount;

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
  ///  <remarks>This type uses a linked list to store its objects.</remarks>
  TObjectLinkedQueue<T: class> = class(TLinkedQueue<T>)
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

{ TLinkedQueue<T> }

function TLinkedQueue<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
begin
  { Call the one from the list }
  Result := FList.Aggregate(AAggregator);
end;

function TLinkedQueue<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.AggregateOrDefault(AAggregator, ADefault);
end;

function TLinkedQueue<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  { Call the one from the list }
  Result := FList.All(APredicate);
end;

function TLinkedQueue<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  { Call the one from the list }
  Result := FList.Any(APredicate);
end;

procedure TLinkedQueue<T>.Clear;
begin
  { Clear the internal list }
  if FList <> nil then
    FList.Clear();
end;

function TLinkedQueue<T>.Contains(const AValue: T): Boolean;
begin
  { Use the list }
  Result := FList.Contains(AValue);
end;

procedure TLinkedQueue<T>.CopyTo(var AArray: array of T; const AStartIndex: NativeUInt);
begin
  { Invoke the copy-to from the list below }
  FList.CopyTo(AArray, AStartIndex);
end;

constructor TLinkedQueue<T>.Create(const AType: IType<T>; const ACollection: IEnumerable<T>);
var
  V: T;
begin
  { Call upper constructor }
  Create(AType);

  { Initialize instance }
  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Try to copy the given Enumerable }
  for V in ACollection do
    Enqueue(V);
end;

constructor TLinkedQueue<T>.Create;
begin
  Create(TType<T>.Default);
end;

constructor TLinkedQueue<T>.Create(const ACollection: IEnumerable<T>);
begin
  Create(TType<T>.Default, ACollection);
end;

constructor TLinkedQueue<T>.Create(const AType: IType<T>);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  { Initialize internals }
  InstallType(AType);

  FList := TLinkedList<T>.Create(ElementType);
end;

function TLinkedQueue<T>.ElementAt(const Index: NativeUInt): T;
begin
  { Call the one from the list }
  Result := FList.ElementAt(Index);
end;

function TLinkedQueue<T>.ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.ElementAtOrDefault(AIndex, ADefault);
end;

function TLinkedQueue<T>.Empty: Boolean;
begin
  { Call the one from the list }
  Result := FList.Empty;
end;

procedure TLinkedQueue<T>.Enqueue(const AValue: T);
begin
  { Add a new node to the linked list }
  FList.AddLast(AValue);
end;

function TLinkedQueue<T>.EqualsTo(const ACollection: IEnumerable<T>): Boolean;
begin
  { Call the one from the list }
  Result := FList.EqualsTo(ACollection);
end;

function TLinkedQueue<T>.First: T;
begin
  { Call the one from the list }
  Result := FList.First;
end;

function TLinkedQueue<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.FirstOrDefault(ADefault);
end;

procedure TLinkedQueue<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Enqueue(AElement);
end;

destructor TLinkedQueue<T>.Destroy;
begin
  { Cleanup }
  Clear();

  inherited;
end;

function TLinkedQueue<T>.Dequeue: T;
begin
  { Call the list ... again! }
  Result := FList.RemoveAndReturnFirst();
end;

function TLinkedQueue<T>.GetCount: NativeUInt;
begin
  Result := FList.Count;
end;

function TLinkedQueue<T>.GetEnumerator: IEnumerator<T>;
begin
  { Get the list enumerator }
  Result := FList.GetEnumerator();
end;

function TLinkedQueue<T>.Last: T;
begin
  { Call the one from the list }
  Result := FList.Last;
end;

function TLinkedQueue<T>.LastOrDefault(const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.LastOrDefault(ADefault);
end;

function TLinkedQueue<T>.Max: T;
begin
  { Call the one from the list }
  Result := FList.Max;
end;

function TLinkedQueue<T>.Min: T;
begin
  { Call the one from the list }
  Result := FList.Min;
end;

function TLinkedQueue<T>.Peek: T;
begin
  if FList.FirstNode = nil then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FList.FirstNode.Value;
end;

function TLinkedQueue<T>.Single: T;
begin
  { Call the one from the list }
  Result := FList.Single;
end;

function TLinkedQueue<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.SingleOrDefault(ADefault);
end;

procedure TLinkedQueue<T>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TLinkedQueue<T>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

constructor TLinkedQueue<T>.Create(const AArray: array of T);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedQueue<T>.Create(const AType: IType<T>; const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy array }
  for I := 0 to Length(AArray) - 1 do
  begin
    Enqueue(AArray[I]);
  end;
end;

constructor TLinkedQueue<T>.Create(const AArray: TFixedArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedQueue<T>.Create(const AArray: TDynamicArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedQueue<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
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

constructor TLinkedQueue<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
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

{ TObjectLinkedQueue<T> }

procedure TObjectLinkedQueue<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectLinkedQueue<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectLinkedQueue<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.
