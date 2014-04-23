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
unit DeHL.Collections.LinkedStack;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Collections.LinkedList,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>stack (LIFO)</c> collection.</summary>
  ///  <remarks>This type uses a linked list to store its values.</remarks>
  TLinkedStack<T> = class(TEnexCollection<T>, IStack<T>)
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

    ///  <summary>Called when the an element has been deserialized and needs to be inserted into the stack.</summary>
    ///  <param name="AElement">The element that was deserialized.</param>
    ///  <remarks>This method simply adds the element to the stack.</remarks>
    procedure DeserializeElement(const AElement: T); override;

    ///  <summary>Returns the number of elements in the stack.</summary>
    ///  <returns>A positive value specifying the number of elements in the stack.</returns>
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
    ///  <param name="AType">A type object decribing the elements in the stack.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the stack.</summary>
    ///  <remarks>This method clears the stack and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Pushes an element to the top of the stack.</summary>
    ///  <param name="AValue">The value to push.</param>
    procedure Push(const AValue: T);

    ///  <summary>Retreives the element from the top of the stack.</summary>
    ///  <returns>The value at the top of the stack.</returns>
    ///  <remarks>This method removes the element from the top of the stack.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Pop(): T;

    ///  <summary>Reads the element from the top of the stack.</summary>
    ///  <returns>The value at the top of the stack.</returns>
    ///  <remarks>This method does not remove the element from the top of the stack. It merely reads it's value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Peek(): T;

    ///  <summary>Removes an element from the stack.</summary>
    ///  <param name="AValue">The value to remove. If there is no such element in the stack, nothing happens.</param>
    procedure Remove(const AValue: T);

    ///  <summary>Checks whether the stack contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the stack; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;

    ///  <summary>Specifies the number of elements in the stack.</summary>
    ///  <returns>A positive value specifying the number of elements in the stack.</returns>
    property Count: NativeUInt read GetCount;

    ///  <summary>Returns a new enumerator object used to enumerate this stack.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the stack.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<T>; override;

    ///  <summary>Copies the values stored in the stack to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the stack.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the stack.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const AStartIndex: NativeUInt); overload; override;

    ///  <summary>Checks whether the stack is empty.</summary>
    ///  <returns><c>True</c> if the stack is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the stack is empty.</remarks>
    function Empty(): Boolean; override;

    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the stack considered to have the biggest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Max(): T; override;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the stack considered to have the smallest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Min(): T; override;

    ///  <summary>Returns the first element.</summary>
    ///  <returns>The first element in the stack.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function First(): T; override;

    ///  <summary>Returns the first element or a default if the stack is empty.</summary>
    ///  <param name="ADefault">The default value returned if the stack is empty.</param>
    ///  <returns>The first element in stack if the stack is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function FirstOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the last element.</summary>
    ///  <returns>The last element in the stack.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Last(): T; override;

    ///  <summary>Returns the last element or a default if the stack is empty.</summary>
    ///  <param name="ADefault">The default value returned if the stack is empty.</param>
    ///  <returns>The last element in stack if the stack is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function LastOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the single element stored in the stack.</summary>
    ///  <returns>The element in stack.</returns>
    ///  <remarks>This method checks if the stack contains just one element, in which case it is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionNotOneException">There is more than one element in the stack.</exception>
    function Single(): T; override;

    ///  <summary>Returns the single element stored in the stack, or a default value.</summary>
    ///  <param name="ADefault">The default value returned if there is less or more elements in the stack.</param>
    ///  <returns>The element in the stack if the condition is satisfied; <paramref name="ADefault"/> is returned otherwise.</returns>
    ///  <remarks>This method checks if the stack contains just one element, in which case it is returned. Otherwise
    ///  the value in <paramref name="ADefault"/> is returned.</remarks>
    function SingleOrDefault(const ADefault: T): T; override;

    ///  <summary>Aggregates a value based on the stack's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <returns>A value that contains the stack's aggregated value.</returns>
    ///  <remarks>This method returns the first element if the stack only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Aggregate(const AAggregator: TFunc<T, T, T>): T; override;

    ///  <summary>Aggregates a value based on the stack's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <param name="ADefault">The default value returned if the stack is empty.</param>
    ///  <returns>A value that contains the stack's aggregated value. If the stack is empty, <paramref name="ADefault"/> is returned.</returns>
    ///  <remarks>This method returns the first element if the stack only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    function AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T; override;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <returns>The element from the specified position.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function ElementAt(const Index: NativeUInt): T; override;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <param name="ADefault">The default value returned if the stack is empty.</param>
    ///  <returns>The element from the specified position if the stack is not empty and the position is not out of bounds; otherwise
    ///  the value of <paramref name="ADefault"/> is returned.</returns>
    function ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T; override;

    ///  <summary>Check whether at least one element in the stack satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if the at least one element satisfies a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole stack and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>True</c>. The logical equivalent of this operation is "OR".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;

    ///  <summary>Checks that all elements in the stack satisfy a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if all elements satisfy a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole stack and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>False</c>. The logical equivalent of this operation is "AND".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function All(const APredicate: TFunc<T, Boolean>): Boolean; override;

    ///  <summary>Checks whether the elements in this stack are equal to the elements in another collection.</summary>
    ///  <param name="ACollection">The collection to compare to.</param>
    ///  <returns><c>True</c> if the collections are equal; <c>False</c> if the collections are different.</returns>
    ///  <remarks>This methods checks that each element at position X in this stack is equal to an element at position X in
    ///  the provided collection. If the number of elements in both collections are different, then the collections are considered different.
    ///  Note that comparison of element is done using the type object used by this stack. This means that comparing this collection
    ///  to another one might yeild a different result than comparing the other collection to this one.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function EqualsTo(const ACollection: IEnumerable<T>): Boolean; override;
  end;

  ///  <summary>The generic <c>stack (LIFO)</c> collection designed to store objects.</summary>
  ///  <remarks>This type uses a linked list to store its objects.</remarks>
  TObjectLinkedStack<T: class> = class(TLinkedStack<T>)
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
    ///  <summary>Specifies whether this stack owns the objects stored in it.</summary>
    ///  <returns><c>True</c> if the stack owns its objects; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the stack controls the life-time of the stored objects.</remarks>
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

{ TLinkedStack<T> }

function TLinkedStack<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
begin
  { Call the one from the list }
  Result := FList.Aggregate(AAggregator);
end;

function TLinkedStack<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.AggregateOrDefault(AAggregator, ADefault);
end;

function TLinkedStack<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  { Call the one from the list }
  Result := FList.All(APredicate);
end;

function TLinkedStack<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  { Call the one from the list }
  Result := FList.Any(APredicate);
end;

procedure TLinkedStack<T>.Clear;
begin
  { Clear the internal list }
  if FList <> nil then
    FList.Clear();
end;

function TLinkedStack<T>.Contains(const AValue: T): Boolean;
begin
  { Use the list }
  Result := FList.Contains(AValue);
end;

procedure TLinkedStack<T>.CopyTo(var AArray: array of T; const AStartIndex: NativeUInt);
begin
  { Invoke the copy-to from the list below }
  FList.CopyTo(AArray, AStartIndex);
end;

constructor TLinkedStack<T>.Create(const AType: IType<T>; const ACollection: IEnumerable<T>);
var
  V: T;
begin
  { Call upper constructor }
  Create(AType);

  { Initialize instance }
  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Try to copy the given Enumerable }
  for V in ACollection do
    Push(V);
end;

constructor TLinkedStack<T>.Create;
begin
  Create(TType<T>.Default);
end;

constructor TLinkedStack<T>.Create(const ACollection: IEnumerable<T>);
begin
  Create(TType<T>.Default, ACollection);
end;

constructor TLinkedStack<T>.Create(const AType: IType<T>);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  { Initialize internals }
  InstallType(AType);

  FList := TLinkedList<T>.Create(ElementType);
end;

procedure TLinkedStack<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Push(AElement);
end;

destructor TLinkedStack<T>.Destroy;
begin
  { Some clean-up }
  Clear();

  { Free the list }
  FList.Free;

  inherited;
end;

function TLinkedStack<T>.ElementAt(const Index: NativeUInt): T;
begin
  { Call the one from the list }
  Result := FList.ElementAt(Index);
end;

function TLinkedStack<T>.ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.ElementAtOrDefault(AIndex, ADefault);
end;

function TLinkedStack<T>.Empty: Boolean;
begin
  { Call the one from the list }
  Result := FList.Empty;
end;

function TLinkedStack<T>.EqualsTo(const ACollection: IEnumerable<T>): Boolean;
begin
  { Call the one from the list }
  Result := FList.EqualsTo(ACollection);
end;

function TLinkedStack<T>.First: T;
begin
  { Call the one from the list }
  Result := FList.First;
end;

function TLinkedStack<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.FirstOrDefault(ADefault);
end;

function TLinkedStack<T>.GetCount: NativeUInt;
begin
  { Use the variable }
  Result := FList.Count;
end;

function TLinkedStack<T>.GetEnumerator: IEnumerator<T>;
begin
  { Even use the enumerator provided by the linked list! }
  Result := FList.GetEnumerator();
end;

function TLinkedStack<T>.Last: T;
begin
  { Call the one from the list }
  Result := FList.Last;
end;

function TLinkedStack<T>.LastOrDefault(const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.LastOrDefault(ADefault);
end;

function TLinkedStack<T>.Max: T;
begin
  { Call the one from the list }
  Result := FList.Max;
end;

function TLinkedStack<T>.Min: T;
begin
  { Call the one from the list }
  Result := FList.Min;
end;

function TLinkedStack<T>.Peek: T;
begin
  if FList.LastNode = nil then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FList.LastNode.Value;
end;

function TLinkedStack<T>.Pop: T;
begin
  { Call the list ... again! }
  Result := FList.RemoveAndReturnLast();
end;

procedure TLinkedStack<T>.Push(const AValue: T);
begin
  { Add a new node to the linked list }
  FList.AddLast(AValue);
end;

procedure TLinkedStack<T>.Remove(const AValue: T);
begin
  { Simply use the list }
  FList.Remove(AValue);
end;

function TLinkedStack<T>.Single: T;
begin
  { Call the one from the list }
  Result := FList.Single;
end;

function TLinkedStack<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Call the one from the list }
  Result := FList.SingleOrDefault(ADefault);
end;

procedure TLinkedStack<T>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TLinkedStack<T>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

constructor TLinkedStack<T>.Create(const AArray: array of T);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedStack<T>.Create(const AType: IType<T>; const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy array }
  for I := 0 to Length(AArray) - 1 do
  begin
    Push(AArray[I]);
  end;
end;

constructor TLinkedStack<T>.Create(const AArray: TFixedArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedStack<T>.Create(const AArray: TDynamicArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedStack<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Push(AArray[I]);
    end;
end;

constructor TLinkedStack<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Push(AArray[I]);
    end;
end;

{ TObjectLinkedStack<T> }

procedure TObjectLinkedStack<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectLinkedStack<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectLinkedStack<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.
