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
unit DeHL.Collections.Stack;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>stack (LIFO)</c> collection.</summary>
  ///  <remarks>This type uses an internal array to store its values.</remarks>
  TStack<T> = class(TEnexCollection<T>, IStack<T>, IDynamic)
  private type
    {$REGION 'Internal Types'}
    { Generic Stack List Enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FStack: TStack<T>;
      FCurrentIndex: NativeUInt;

    public
      { Constructor }
      constructor Create(const AStack: TStack<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;
    {$ENDREGION}

  private var
    FArray: TArray<T>;
    FLength: NativeUInt;
    FVer: NativeUInt;

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

    ///  <summary>Returns the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the stack can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this method is greater or equal to the amount of elements in the stack. If this value
    ///  is greater then the number of elements, it means that the stack has some extra capacity to operate upon.</remarks>
    function GetCapacity(): NativeUInt;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The stack's initial capacity.</param>
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
    ///  <param name="AType">A type object decribing the elements in the stack.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the stack.</param>
    ///  <param name="AInitialCapacity">The stack's initial capacity.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the stack.</param>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const ACollection: IEnumerable<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the stack.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: array of T); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the stack.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TDynamicArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the stack.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
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
    property Count: NativeUInt read FLength;

    ///  <summary>Specifies the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the stack can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this property is greater or equal to the amount of elements in the stack. If this value
    ///  if greater then the number of elements, it means that the stack has some extra capacity to operate upon.</remarks>
    property Capacity: NativeUInt read GetCapacity;

    ///  <summary>Removes the excess capacity from the stack.</summary>
    ///  <remarks>This method can be called manually to force the stack to drop the extra capacity it might hold. For example,
    ///  after performing some massive operations of a big list, call this method to ensure that all extra memory held by the
    ///  stack is released.</remarks>
    procedure Shrink();

    ///  <summary>Forces the stack to increase its capacity.</summary>
    ///  <remarks>Call this method to force the stack to increase its capacity ahead of time. Manually adjusting the capacity
    ///  can be useful in certain situations.</remarks>
    procedure Grow();

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
  ///  <remarks>This type uses an internal array to store its objects.</remarks>
  TObjectStack<T: class> = class(TStack<T>)
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

const
  DefaultArrayLength = 10;

{ TStack<T> }

function TStack<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
var
  I: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := FArray[0];

  { Iterate over the last N - 1 elements }
  for I := 1 to FLength - 1 do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, FArray[I]);
  end;
end;

function TStack<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
var
  I: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FLength = 0 then
    Exit(ADefault);

  { Select the first element as comparison base }
  Result := FArray[0];

  { Iterate over the last N - 1 elements }
  for I := 1 to FLength - 1 do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, FArray[I]);
  end;
end;

function TStack<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  I: NativeUInt;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if FLength > 0 then
    for I := 0 to FLength - 1 do
      if not APredicate(FArray[I]) then
        Exit(false);

  Result := true;
end;

function TStack<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  I: NativeUInt;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if FLength > 0 then
    for I := 0 to FLength - 1 do
      if APredicate(FArray[I]) then
        Exit(true);

  Result := false;
end;

procedure TStack<T>.Clear;
var
  I: NativeInt;
begin
  if (ElementType <> nil) and (ElementType.Management() = tmManual) and (FLength > 0) then
  begin
    { Should cleanup each element individually }
    for I := 0 to FLength - 1 do
      ElementType.Cleanup(FArray[I]);
  end;

  { Simply reset all to default }
  SetLength(FArray, DefaultArrayLength);
  FLength := 0;

  Inc(FVer);
end;

function TStack<T>.Contains(const AValue: T): Boolean;
var
  I: NativeInt;
begin
  { Defaults }
  Result := False;
  if (FLength = 0) then Exit;

  for I := 0 to FLength - 1 do
  begin
    if ElementType.AreEqual(FArray[I], AValue) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TStack<T>.CopyTo(var AArray: array of T; const AStartIndex: NativeUInt);
begin
  { Check for indexes }
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - AStartIndex) < FLength then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Copy all elements safely }
  &Array<T>.SafeMove(FArray, AArray, 0, AStartIndex, FLength, ElementType);
end;

constructor TStack<T>.Create(const AType: IType<T>; const ACollection: IEnumerable<T>);
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
    Push(V);
end;

constructor TStack<T>.Create;
begin
  Create(TType<T>.Default);
end;

constructor TStack<T>.Create(const AInitialCapacity: NativeUInt);
begin
  Create(TType<T>.Default, AInitialCapacity);
end;

constructor TStack<T>.Create(const ACollection: IEnumerable<T>);
begin
  Create(TType<T>.Default, ACollection);
end;

constructor TStack<T>.Create(const AType: IType<T>);
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);
end;

constructor TStack<T>.Create(const AType: IType<T>; const AInitialCapacity: NativeUInt);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  InstallType(AType);

  FLength := 0;
  FVer := 0;
  SetLength(FArray, AInitialCapacity);
end;

procedure TStack<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Push(AElement);
end;

destructor TStack<T>.Destroy;
begin
  { Some clean-up }
  Clear();

  inherited;
end;

function TStack<T>.ElementAt(const Index: NativeUInt): T;
begin
  if (Index >= FLength) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');

  Result := FArray[Index];
end;

function TStack<T>.ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T;
begin
  { Check range }
  if (AIndex >= FLength) then
     Result := ADefault
  else
     Result := FArray[AIndex];
end;

function TStack<T>.Empty: Boolean;
begin
  Result := (FLength = 0);
end;

function TStack<T>.EqualsTo(const ACollection: IEnumerable<T>): Boolean;
var
  V: T;
  I: NativeUInt;
begin
  I := 0;

  for V in ACollection do
  begin
    if I >= FLength then
      Exit(false);

    if not ElementType.AreEqual(FArray[I], V) then
      Exit(false);

    Inc(I);
  end;

  if I < FLength then
    Exit(false);

  Result := true;
end;

function TStack<T>.First: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FArray[0];
end;

function TStack<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else
    Result := FArray[0];
end;

function TStack<T>.GetCapacity: NativeUInt;
begin
  Result := Length(FArray);
end;

function TStack<T>.GetCount: NativeUInt;
begin
  { Use the variable }
  Result := FLength;
end;

function TStack<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

procedure TStack<T>.Grow;
var
  ListLength: NativeUInt;
begin
  ListLength := Capacity;

  if ListLength = 0 then
     ListLength := DefaultArrayLength
  else
     ListLength := ListLength * 2;

  SetLength(FArray, ListLength);
end;

function TStack<T>.Last: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FArray[FLength - 1];
end;

function TStack<T>.LastOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else
    Result := FArray[FLength - 1];
end;

function TStack<T>.Max: T;
var
  I: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  Result := FArray[0];

  for I := 1 to FLength - 1 do
    if ElementType.Compare(FArray[I], Result) > 0 then
      Result := FArray[I];
end;

function TStack<T>.Min: T;
var
  I: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  Result := FArray[0];

  for I := 1 to FLength - 1 do
    if ElementType.Compare(FArray[I], Result) < 0 then
      Result := FArray[I];
end;

function TStack<T>.Peek: T;
begin
  if FLength > 0 then
     Result := FArray[FLength - 1]
  else
     ExceptionHelper.Throw_CollectionEmptyError();
end;

function TStack<T>.Pop: T;
begin
  if FLength > 0 then
  begin
     Result := FArray[FLength - 1];
     Dec(FLength);
     Inc(FVer);
  end
  else
     ExceptionHelper.Throw_CollectionEmptyError();
end;

procedure TStack<T>.Push(const AValue: T);
begin
  { Enure enough capacity }
  if (FLength >= Capacity) then
    Grow();

  { Add the element to the stack and increase the index }
  FArray[FLength] := AValue;
  Inc(FLength);
  Inc(FVer);
end;

procedure TStack<T>.Remove(const AValue: T);
var
  I, FoundIndex: NativeInt;
begin
  { Defaults }
  if (FLength = 0) then Exit;
  FoundIndex := -1;

  for I := 0 to FLength - 1 do
  begin
    if ElementType.AreEqual(FArray[I], AValue) then
    begin
      FoundIndex := I;
      Break;
    end;
  end;

  if (FoundIndex > -1) then
  begin
    { Move the list }
    if FLength > 1 then
      for I := FoundIndex to FLength - 2 do
        FArray[I] := FArray[I + 1];

    Dec(FLength);
    Inc(FVer);
  end;
end;

procedure TStack<T>.Shrink;
begin
  { Cut the capacity if required }
  if FLength < Capacity then
  begin
    SetLength(FArray, FLength);
  end;
end;

function TStack<T>.Single: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError()
  else if FLength > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FArray[0];
end;

function TStack<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else if FLength > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FArray[0];
end;

procedure TStack<T>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TStack<T>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

constructor TStack<T>.Create(const AArray: array of T);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TStack<T>.Create(const AType: IType<T>; const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Copy array }
  for I := 0 to Length(AArray) - 1 do
  begin
    Push(AArray[I]);
  end;
end;

constructor TStack<T>.Create(const AArray: TFixedArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TStack<T>.Create(const AArray: TDynamicArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TStack<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
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

constructor TStack<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
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

{ TStack<T>.TEnumerator }

constructor TStack<T>.TEnumerator.Create(const AStack: TStack<T>);
begin
  { Initialize }
  FStack := AStack;
  KeepObjectAlive(FStack);

  FCurrentIndex := 0;
  FVer := AStack.FVer;
end;

destructor TStack<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FStack);
  inherited;
end;

function TStack<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FStack.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  if FCurrentIndex > 0 then
    Result := FStack.FArray[FCurrentIndex - 1]
  else
    Result := default(T);
end;

function TStack<T>.TEnumerator.MoveNext: Boolean;
begin
  if FVer <> FStack.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FCurrentIndex < FStack.FLength;
  Inc(FCurrentIndex);
end;

{ TObjectStack<T> }

procedure TObjectStack<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectStack<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectStack<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.
