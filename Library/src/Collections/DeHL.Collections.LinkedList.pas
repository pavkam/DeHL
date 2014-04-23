(*
* Copyright (c) 2008-2009, Ciobanu Alexandru
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
unit DeHL.Collections.LinkedList;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Exceptions,
     DeHL.Collections.Base,
     DeHL.Arrays;

type
  { Forward declaration }
  TLinkedList<T> = class;

  { Generic Linked List Node }
  //TODO: doc me
  TLinkedListNode<T> = class(TSimpleObject)
  private
    FRemoved: Boolean;
    FData: T;
    FNext: TLinkedListNode<T>;
    FPrev: TLinkedListNode<T>;
    FList: TLinkedList<T>;

  public
    { Constructors }
    //TODO: doc me
    constructor Create(Value: T);

    { Destructors }
    //TODO: doc me
    destructor Destroy(); override;

    { Properties }
    //TODO: doc me
    property Next: TLinkedListNode<T> read FNext;
    //TODO: doc me
    property Previous: TLinkedListNode<T> read FPrev;

    //TODO: doc me
    property List: TLinkedList<T> read FList;
    //TODO: doc me
    property Value: T read FData write FData;
  end;

  { Generic Linked List }
  TLinkedList<T> = class(TEnexCollection<T>)
  type
    { Generic Linked List Enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FLinkedList: TLinkedList<T>;
      FCurrentNode: TLinkedListNode<T>;

    public
      { Constructor }
      constructor Create(const AList: TLinkedList<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FFirst: TLinkedListNode<T>;
    FLast: TLinkedListNode<T>;
    FCount: NativeUInt;
    FVer : NativeUInt;
  protected
    { Serialization overrides }
    //TODO: doc me
    procedure StartSerializing(const AData: TSerializationData); override;
    //TODO: doc me
    procedure StartDeserializing(const AData: TDeserializationData); override;
    //TODO: doc me
    procedure DeserializeElement(const AElement: T); override;

    { Hidden ICollection support }
    //TODO: doc me
    function GetCount(): NativeUInt; override;
  public
    { Constructors }
    //TODO: doc me
    constructor Create(); overload;
    //TODO: doc me
    constructor Create(const AEnumerable: IEnumerable<T>); overload;
    //TODO: doc me
    constructor Create(const AArray: array of T); overload;
    //TODO: doc me
    constructor Create(const AArray: TDynamicArray<T>); overload;
    //TODO: doc me
    constructor Create(const AArray: TFixedArray<T>); overload;

    //TODO: doc me
    constructor Create(const AType: IType<T>); overload;
    //TODO: doc me
    constructor Create(const AType: IType<T>; const AEnumerable: IEnumerable<T>); overload;
    //TODO: doc me
    constructor Create(const AType: IType<T>; const AArray: array of T); overload;
    //TODO: doc me
    constructor Create(const AType: IType<T>; const AArray: TDynamicArray<T>); overload;
    //TODO: doc me
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>); overload;

    { Destructors }
    //TODO: doc me
    destructor Destroy(); override;

    { Adding }
    //TODO: doc me
    procedure AddAfter(const ARefNode: TLinkedListNode<T>; const ANode: TLinkedListNode<T>); overload;
    //TODO: doc me
    procedure AddAfter(const ARefNode: TLinkedListNode<T>; const AValue: T); overload;
    //TODO: doc me
    procedure AddAfter(const ARefValue: T; const AValue: T); overload;

    //TODO: doc me
    procedure AddBefore(const ARefNode: TLinkedListNode<T>; const ANode: TLinkedListNode<T>); overload;
    //TODO: doc me
    procedure AddBefore(const ARefNode: TLinkedListNode<T>; const AValue: T); overload;
    //TODO: doc me
    procedure AddBefore(const ARefValue: T; const AValue: T); overload;

    //TODO: doc me
    procedure AddFirst(const ANode: TLinkedListNode<T>); overload;
    //TODO: doc me
    procedure AddFirst(const AValue: T); overload;

    //TODO: doc me
    procedure AddLast(const ANode: TLinkedListNode<T>); overload;
    //TODO: doc me
    procedure AddLast(const AValue: T); overload;

    { Removing }
    //TODO: doc me
    procedure Clear();

    { All kind of cool removal options }
    //TODO: doc me
    procedure Remove(const AValue: T); overload;
    //TODO: doc me
    procedure RemoveFirst();
    //TODO: doc me
    procedure RemoveLast();

    //TODO: doc me
    function RemoveAndReturnFirst(): T;
    //TODO: doc me
    function RemoveAndReturnLast(): T;

    { Lookup }
    //TODO: doc me
    function Contains(const AValue: T): Boolean;
    //TODO: doc me
    function Find(const AValue: T): TLinkedListNode<T>;
    //TODO: doc me
    function FindLast(const AValue: T): TLinkedListNode<T>;

    { Properties }
    //TODO: doc me
    property Count: NativeUInt read FCount;
    //TODO: doc me
    property FirstNode: TLinkedListNode<T> read FFirst;
    //TODO: doc me
    property LastNode : TLinkedListNode<T> read FLast;

    { ICollection/IEnumerable Support  }
    //TODO: doc me
    procedure CopyTo(var AArray: array of T; const StartIndex: NativeUInt); overload; override;

    //TODO: doc me
    function GetEnumerator(): IEnumerator<T>; override;

    { Enex Overrides }
    //TODO: doc me
    function Empty(): Boolean; override;
    //TODO: doc me
    function Max(): T; override;
    //TODO: doc me
    function Min(): T; override;
    //TODO: doc me
    function First(): T; override;
    //TODO: doc me
    function FirstOrDefault(const ADefault: T): T; override;
    //TODO: doc me
    function Last(): T; override;
    //TODO: doc me
    function LastOrDefault(const ADefault: T): T; override;
    //TODO: doc me
    function Single(): T; override;
    //TODO: doc me
    function SingleOrDefault(const ADefault: T): T; override;
    //TODO: doc me
    function Aggregate(const AAggregator: TFunc<T, T, T>): T; override;
    //TODO: doc me
    function AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T; override;
    //TODO: doc me
    function ElementAt(const Index: NativeUInt): T; override;
    //TODO: doc me
    function ElementAtOrDefault(const Index: NativeUInt; const ADefault: T): T; override;
    //TODO: doc me
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;
    //TODO: doc me
    function All(const APredicate: TFunc<T, Boolean>): Boolean; override;
    //TODO: doc me
    function EqualsTo(const AEnumerable: IEnumerable<T>): Boolean; override;
  end;

  { The object variant }
  //TODO: doc me
  TObjectLinkedList<T: class> = class(TLinkedList<T>)
  private
    FWrapperType: TObjectWrapperType<T>;

    { Getters/Setters for OwnsObjects }
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);

  protected
    { Override in descendants to support proper stuff }
    //TODO: doc me
    procedure InstallType(const AType: IType<T>); override;

  public
    { Object owning }
    //TODO: doc me
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

{ HSimpleLinkedListNode<T> }

constructor TLinkedListNode<T>.Create(Value: T);
begin
  { Assign the value }
  FData := Value;

  { Initialize internals to nil }
  FPrev := nil;
  FNext := nil;
  FList := nil;
end;

destructor TLinkedListNode<T>.Destroy;
begin

  { Link the parent with the next and skip me! }
  if (FPrev <> nil) then
  begin
    FPrev.FNext := FNext;

    { Chnage the last element if required }
    if (FNext = nil) and (FList <> nil) then
       FList.FLast := FPrev;
  end else
  begin
    { This is the first element - update parent list }
    if (FList <> nil) then
       FList.FFirst := FNext;
  end;

  { Update back link }
  if (FNext <> nil) then
     FNext.FPrev := FPrev;

  { Changethe value of the count property in the parent list }
  if (FList <> nil) then
  begin
    { Clean myself up }
    if (FList.ElementType.Management() = tmManual) and (not FRemoved) then
      FList.ElementType.Cleanup(FData);

    Dec(FList.FCount);
    Inc(FList.FVer);
  end;

  { Manually assign last value }
  if FList.FCount = 0 then
     FList.FLast := nil;

  inherited;
end;

{ TLinkedList<T> }

procedure TLinkedList<T>.AddAfter(const ARefNode: TLinkedListNode<T>; const AValue: T);
begin
  { Re-route }
  AddAfter(ARefNode, TLinkedListNode<T>.Create(AValue));
end;

procedure TLinkedList<T>.AddAfter(const ARefNode: TLinkedListNode<T>; const ANode: TLinkedListNode<T>);
var
  Current: TLinkedListNode<T>;
begin
  if ARefNode = nil then
     ExceptionHelper.Throw_ArgumentNilError('ARefNode');

  if ANode = nil then
     ExceptionHelper.Throw_ArgumentNilError('ANode');

  if ARefNode.FList <> Self then
     ExceptionHelper.Throw_ElementNotPartOfCollectionError('ARefNode');

  if ANode.FList <> nil then
     ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  { Test for immediate value }
  if (FFirst = nil) then Exit;

  { Start value }
  Current := FFirst;

  while Current <> nil do
  begin

    if (Current = ARefNode) then
    begin
      ANode.FPrev := Current;
      ANode.FNext := Current.FNext;
      Current.FNext := ANode;

      if (ANode.FNext <> nil) then
          ANode.FNext.FPrev := ANode
      else
          FLast := ANode;

      Inc(FCount);
      Inc(FVer);
      ANode.FList := Self;

      Exit;
    end;

    Current := Current.FNext;
  end;
end;

procedure TLinkedList<T>.AddBefore(const ARefNode: TLinkedListNode<T>; const AValue: T);
begin
  { Re-route }
  AddBefore(ARefNode, TLinkedListNode<T>.Create(AValue));
end;

procedure TLinkedList<T>.AddBefore(const ARefNode: TLinkedListNode<T>; const ANode: TLinkedListNode<T>);
var
  Current: TLinkedListNode<T>;
begin
  if ARefNode = nil then
     ExceptionHelper.Throw_ArgumentNilError('ARefNode');

  if ANode = nil then
     ExceptionHelper.Throw_ArgumentNilError('ANode');

  if ARefNode.FList <> Self then
     ExceptionHelper.Throw_ElementNotPartOfCollectionError('ARefNode');

  if ANode.FList <> nil then
     ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  { Test for immediate value }
  if (FFirst = nil) then Exit;

  { Start value }
  Current := FFirst;

  while Current <> nil do
  begin

    if (Current = ARefNode) then
    begin
      ANode.FNext := Current;
      ANode.FPrev := Current.FPrev;
      Current.FPrev := ANode;

      if ANode.FPrev <> nil then
         ANode.FPrev.FNext := ANode;

      Inc(FCount);
      Inc(FVer);

      ANode.FList := Self;

      if Current = FFirst then
         FFirst := ANode;

      Exit;
    end;

    Current := Current.FNext;
  end;
end;

procedure TLinkedList<T>.AddFirst(const AValue: T);
begin
  { Re-route }
  AddFirst(TLinkedListNode<T>.Create(AValue));
end;

procedure TLinkedList<T>.AddFirst(const ANode: TLinkedListNode<T>);
begin
  if ANode = nil then
     ExceptionHelper.Throw_ArgumentNilError('ANode');

  if ANode.FList <> nil then
     ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  { Plug in the new node }
  ANode.FNext := FFirst;

  if FFirst <> nil then
     FFirst.FPrev := ANode;

  FFirst := ANode;

  if (FLast = nil) then
      FLast := FFirst;

  ANode.FList := Self;

  Inc(FCount);
  Inc(FVer);
end;

procedure TLinkedList<T>.AddLast(const AValue: T);
begin
  { Re-route }
  AddLast(TLinkedListNode<T>.Create(AValue));
end;

function TLinkedList<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
var
  Node: TLinkedListNode<T>;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  { Check length }
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  Node := FFirst;
  Result := Node.FData;

  while True do
  begin
    Node := Node.FNext;

    if Node = nil then
      Exit;

    { Aggregate a value }
    Result := AAggregator(Result, Node.FData);
  end;
end;

function TLinkedList<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
var
  Node: TLinkedListNode<T>;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  { Check length }
  if FCount = 0 then
    Exit(ADefault);

  { Default one }
  Node := FFirst;
  Result := Node.FData;

  while True do
  begin
    Node := Node.FNext;

    if Node = nil then
      Exit;

    { Aggregate a value }
    Result := AAggregator(Result, Node.FData);
  end;
end;

function TLinkedList<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  Node: TLinkedListNode<T>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Default one }
  Node := FFirst;
  while Node <> nil do
  begin
    if not APredicate(Node.FData) then
      Exit(false);

    Node := Node.FNext;
  end;

  Result := true;
end;

function TLinkedList<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  Node: TLinkedListNode<T>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Default one }
  Node := FFirst;
  while Node <> nil do
  begin
    if APredicate(Node.FData) then
      Exit(true);

    Node := Node.FNext;
  end;

  Result := false;
end;

procedure TLinkedList<T>.AddLast(const ANode: TLinkedListNode<T>);
begin
  if ANode = nil then
     ExceptionHelper.Throw_ArgumentNilError('ANode');

  if ANode.FList <> nil then
     ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  { Plug in the new node }
  ANode.FPrev := FLast;

  if FLast <> nil then
     FLast.FNext := ANode;

  FLast := ANode;

  if (FFirst = nil) then
      FFirst := FLast;

  ANode.FList := Self;

  Inc(FCount);
  Inc(FVer);
end;

procedure TLinkedList<T>.Clear;
begin
  { Delete one-by-one }
  while FFirst <> nil do
        FFirst.Free();
end;

function TLinkedList<T>.Contains(const AValue: T): Boolean;
begin
  { Simply re-route }
  Result := (Find(AValue) <> nil);
end;

procedure TLinkedList<T>.CopyTo(var AArray: array of T;
  const StartIndex: NativeUInt);
var
  Current: TLinkedListNode<T>;
  Index  : NativeUInt;
begin
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < FCount then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Test for immediate value }
  if (FFirst = nil) then Exit;

  { Start value }
  Current := FFirst;
  Index := StartIndex;

  while Current <> nil do
  begin
    AArray[Index] := Current.Value;
    Current := Current.FNext;
    Inc(Index);
  end;
end;

constructor TLinkedList<T>.Create;
begin
  Create(TType<T>.Default);
end;

constructor TLinkedList<T>.Create(const AEnumerable: IEnumerable<T>);
begin
  Create(TType<T>.Default, AEnumerable);
end;

constructor TLinkedList<T>.Create(const AType: IType<T>);
begin
  { Initialize instance }
  if (AType = nil) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Install the type }
  InstallType(AType);

  FFirst := nil;
  FLast := nil;
  FCount := 0;
  FVer := 0;
end;

constructor TLinkedList<T>.Create(const AType: IType<T>;
  const AEnumerable: IEnumerable<T>);
var
  V: T;
begin
  { Call upper constructor }
  Create(AType);

  if (AEnumerable = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Try to copy the given Enumerable }
  for V in AEnumerable do
  begin
    { Perform a simple copy }
    AddLast(V);
  end;
end;

function TLinkedList<T>.GetCount: NativeUInt;
begin
  Result := FCount;
end;

function TLinkedList<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

function TLinkedList<T>.Last: T;
begin
  { Check length }
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FLast.FData;
end;

function TLinkedList<T>.LastOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FCount = 0 then
    Result := ADefault
  else
    Result := FLast.FData;
end;

function TLinkedList<T>.Max: T;
var
  Node: TLinkedListNode<T>;
begin
  { Check length }
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  Node := FFirst;
  Result := Node.FData;

  while True do
  begin
    Node := Node.FNext;

    if Node = nil then
      Exit;

    if ElementType.Compare(Node.FData, Result) > 0 then
      Result := Node.FData;
  end;
end;

function TLinkedList<T>.Min: T;
var
  Node: TLinkedListNode<T>;
begin
  { Check length }
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  Node := FFirst;
  Result := Node.FData;

  while True do
  begin
    Node := Node.FNext;

    if Node = nil then
      Exit;

    if ElementType.Compare(Node.FData, Result) < 0 then
      Result := Node.FData;
  end;
end;

procedure TLinkedList<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  AddLast(AElement);
end;

destructor TLinkedList<T>.Destroy;
begin
  { Clear the list first }
  Clear();

  inherited;
end;

function TLinkedList<T>.ElementAt(const Index: NativeUInt): T;
var
  Node: TLinkedListNode<T>;
  I: NativeUInt;
begin
  { Default one }
  Node := FFirst;
  I := 0;

  while Node <> nil do
  begin
    if I = Index then
      Exit(Node.FData);

    Node := Node.FNext;
    Inc(I);
  end;

  ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');
end;

function TLinkedList<T>.ElementAtOrDefault(const Index: NativeUInt; const ADefault: T): T;
var
  Node: TLinkedListNode<T>;
  I: NativeUInt;
begin
  { Default one }
  Node := FFirst;
  I := 0;

  while Node <> nil do
  begin
    if I = Index then
      Exit(Node.FData);

    Node := Node.FNext;
    Inc(I);
  end;

  Result := ADefault;
end;

function TLinkedList<T>.Empty: Boolean;
begin
  Result := (FCount = 0);
end;

function TLinkedList<T>.EqualsTo(const AEnumerable: IEnumerable<T>): Boolean;
var
  Node: TLinkedListNode<T>;
  V: T;
begin
  Node := FFirst;

  for V in AEnumerable do
  begin
    if Node = nil then
      Exit(false);

    if not ElementType.AreEqual(Node.FData, V) then
      Exit(false);

    Node := Node.FNext;
  end;

  if Node <> nil then
    Exit(false);

  Result := true;
end;

function TLinkedList<T>.Find(const AValue: T): TLinkedListNode<T>;
var
  Current: TLinkedListNode<T>;
begin
  Result := nil;

  { Test for immediate value }
  if (FFirst = nil) then Exit;

  { Start value }
  Current := FFirst;

  while Current <> nil do
  begin

    if ElementType.AreEqual(Current.FData, AValue) then
    begin
      Result := Current;
      exit;
    end;

    Current := Current.FNext;
  end;

end;

function TLinkedList<T>.FindLast(const AValue: T): TLinkedListNode<T>;
var
  Current: TLinkedListNode<T>;
begin
  Result := nil;

  { Test for immediate value }
  if (FLast = nil) then Exit;

  { Start value }
  Current := FLast;

  while Current <> nil do
  begin

    if ElementType.AreEqual(Current.FData, AValue) then
    begin
      Result := Current;
      exit;
    end;

    Current := Current.FPrev;
  end;

end;

function TLinkedList<T>.First: T;
begin
  { Check length }
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FFirst.FData;
end;

function TLinkedList<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FCount = 0 then
    Result := ADefault
  else
    Result := FFirst.FData;
end;

procedure TLinkedList<T>.Remove(const AValue: T);
var
  FoundNode: TLinkedListNode<T>;
begin
  { Find the node }
  FoundNode := Find(AValue);

  { Free if found }
  if (FoundNode <> nil) then
  begin
    FoundNode.FRemoved := true;
    FoundNode.Free();
  end;
end;

function TLinkedList<T>.RemoveAndReturnFirst: T;
begin
  { Check if there is a First and remove it }
  if FFirst <> nil then
  begin
    FFirst.FRemoved := true;
    Result := FFirst.FData;

    FFirst.Free;
  end else
    ExceptionHelper.Throw_CollectionEmptyError();
end;

function TLinkedList<T>.RemoveAndReturnLast: T;
begin
  { Check if there is a Last and remove it }
  if FLast <> nil then
  begin
    FLast.FRemoved := true;
    Result := FLast.FData;

    FLast.Free;
  end else
    ExceptionHelper.Throw_CollectionEmptyError();
end;

procedure TLinkedList<T>.RemoveFirst;
begin
  { Check if there is a First and remove it }
  if FFirst <> nil then
     FFirst.Free();
end;

procedure TLinkedList<T>.RemoveLast;
begin
  { Check if there is a First and remove it }
  if FLast <> nil then
     FLast.Free();
end;

function TLinkedList<T>.Single: T;
begin
  { Check length }
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError()
  else if FCount > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FFirst.FData;
end;

function TLinkedList<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FCount = 0 then
    Result := ADefault
  else if FCount > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FFirst.FData;
end;

procedure TLinkedList<T>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TLinkedList<T>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TLinkedList<T>.AddAfter(const ARefValue, AValue: T);
var
  FoundNode: TLinkedListNode<T>;
begin
  { Find the node }
  FoundNode := Find(ARefValue);

  if FoundNode = nil then
     ExceptionHelper.Throw_ElementNotPartOfCollectionError('ARefValue');

  AddAfter(FoundNode, TLinkedListNode<T>.Create(AValue));
end;

procedure TLinkedList<T>.AddBefore(const ARefValue, AValue: T);
var
  FoundNode: TLinkedListNode<T>;
begin
  { Find the node }
  FoundNode := Find(ARefValue);

  if FoundNode = nil then
     ExceptionHelper.Throw_ElementNotPartOfCollectionError('ARefValue');

  AddBefore(FoundNode, TLinkedListNode<T>.Create(AValue));
end;

constructor TLinkedList<T>.Create(const AArray: array of T);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedList<T>.Create(const AType: IType<T>; const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy from array }
  for I := 0 to Length(AArray) - 1 do
  begin
    AddLast(AArray[I]);
  end;
end;

constructor TLinkedList<T>.Create(const AArray: TFixedArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedList<T>.Create(const AArray: TDynamicArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TLinkedList<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      AddLast(AArray[I]);
    end;
end;

constructor TLinkedList<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      AddLast(AArray[I]);
    end;
end;

{ TLinkedList<T>.TEnumerator }

constructor TLinkedList<T>.TEnumerator.Create(const AList: TLinkedList<T>);
begin
  { Initialize }
  FLinkedList := AList;
  KeepObjectAlive(FLinkedList);

  FCurrentNode := nil;
  FVer := AList.FVer;
end;

destructor TLinkedList<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FLinkedList);
  inherited;
end;

function TLinkedList<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FLinkedList.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  if FCurrentNode <> nil then
     Result := FCurrentNode.FData
  else
     Result := default(T);
end;

function TLinkedList<T>.TEnumerator.MoveNext: Boolean;
begin
  if FVer <> FLinkedList.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  if FCurrentNode = nil then
     FCurrentNode := FLinkedList.FirstNode
  else
     FCurrentNode := FCurrentNode.FNext;

  Result := (FCurrentNode <> nil);
end;

{ TObjectLinkedList<T> }

procedure TObjectLinkedList<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectLinkedList<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectLinkedList<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;


end.
