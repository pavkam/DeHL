(*
* Copyright (c) 2010, Ciobanu Alexandru
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
unit DeHL.Collections.Tree;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.Base,
     DeHL.Arrays,
     DeHL.Collections.List;

type
  { Forward declaration }
  TTree<T> = class;

  TTreeNode<T> = class sealed(TSimpleObject)
  private type
    { SiblingsAfter enumerable }
    TSiblingsEnumerable = class sealed(TEnexCollection<TTreeNode<T>>)
    private
      FStart, FEnd: TTreeNode<T>;
      FTree: TTree<T>;

    public
      constructor Create(const ATree: TTree<T>);
      destructor Destroy; override;

      { IEnumerable<T> }
      function GetEnumerator(): IEnumerator<TTreeNode<T>>; override;
    end;

    { SiblingsAfter enumerator }
    TSiblingsEnumerator = class(TEnumerator<TTreeNode<T>>)
    private
      FStart, FEnd, FCurrent: TTreeNode<T>;
      FEnum: TSiblingsEnumerable;
      FVer: NativeUInt;

    public
      constructor Create(const AEnum: TSiblingsEnumerable);
      destructor Destroy; override;

      function GetCurrent(): TTreeNode<T>; override;
      function MoveNext(): Boolean; override;
    end;

  private
    FNoClean: Boolean;
    FData: T;
    FTree: TTree<T>;
    FParent, FLeftSibling,
      FRightSibling, FFirstChild, FLastChild: TTreeNode<T>;

    FLevel: NativeUInt;

    function CloneNode(): TTreeNode<T>;
    function IsAPartOf(const ATree: TTree<T>): Boolean;
  public
    { Constructors }
    constructor Create(const Value: T; const ATree: TTree<T>);
    destructor Destroy(); override;

    { Enumerables }
    function SiblingsAfter(const AIncludingThis: Boolean = false): IEnexCollection<TTreeNode<T>>;
    function SiblingsBefore(const AIncludingThis: Boolean = false): IEnexCollection<TTreeNode<T>>;
    function Children(): IEnexCollection<TTreeNode<T>>;

    { Operations }
    procedure AddSiblingAfter(const ASibling: TTreeNode<T>);
    procedure AddSiblingBefore(const ASibling: TTreeNode<T>);
    procedure AddChild(const AChild: TTreeNode<T>);

    function FindChild(const AValue: T): TTreeNode<T>;

    { Properties }
    property Value: T read FData write FData;
    property PreviousSibling: TTreeNode<T> read FLeftSibling;
    property NextSibling: TTreeNode<T> read FRightSibling;
    property Parent: TTreeNode<T> read FParent;
    property Tree: TTree<T> read FTree;
    property Level: NativeUInt read FLevel;
  end;

  TTree<T> = class(TEnexCollection<T>)
  private type
    { Basic enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FTree: TTree<T>;
      FVer: NativeUInt;
      FCurrent: TTreeNode<T>;

    public
      { Constructor }
      constructor Create(const ATree: TTree<T>);
      destructor Destroy; override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  private
    FRoot: TTreeNode<T>;
    FCount: NativeUInt;
    FVer: NativeUInt;

    { Recursive copy }
    procedure CopyToArray(var AArray: array of T; const AIndex: NativeInt; const ARefNode: TTreeNode<T>);

    { Internal only }
{$HINTS OFF}
    constructor Create(const AType: IType<T>; const ARoot: TTreeNode<T>); overload;
{$HINTS ON}
  protected
    { Hidden ICollection support }
    function GetCount(): NativeUInt; override;

  public
    { Constructors }
    constructor Create(const AValue: T); overload;
    constructor Create(const ATree: TTree<T>); overload;

    constructor Create(const AType: IType<T>; const AValue: T); overload;
    constructor Create(const AType: IType<T>; const ATree: TTree<T>); overload;

    { Destructors }
    destructor Destroy(); override;

    { Adds a child to the given node }
    procedure Add(const AParentNode: TTreeNode<T>; const AValue: T); overload;

    { Removing }
    procedure Clear();

    { looks for AValue, remove it, and all its subtree }
    procedure Remove(const AValue: T); overload;

    { Lookup }
    function Contains(const AValue: T): Boolean;
    function Find(const AValue: T): TTreeNode<T>;

    { Properties }
    property Count: NativeUInt read FCount;
    property Root: TTreeNode<T> read FRoot;

    { Copy to array support (it traverses the tree in post-order when copying the elements) }
    procedure CopyTo(var AArray: array of T); overload; override;
    procedure CopyTo(var AArray: array of T; const StartIndex: NativeUInt); overload; override;

    { IEnumerable }
    function GetEnumerator(): IEnumerator<T>; override;

    { Enex Overrides }
    function Empty(): Boolean; override;
  end;


implementation

{ TTree<T> }

procedure TTree<T>.Add(const AParentNode: TTreeNode<T>; const AValue: T);
begin
  if AParentNode = nil then
    ExceptionHelper.Throw_ArgumentNilError('AParentNode');

  if AParentNode.FTree <> Self then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('AParentNode');

  AParentNode.AddChild(TTreeNode<T>.Create(AValue, Self));
end;

procedure TTree<T>.Clear;
begin
  if (FRoot <> nil) then
  begin
    FRoot.Free;
    FRoot := nil;

    Inc(FVer);
  end;
end;

function TTree<T>.Contains(const AValue: T): Boolean;
begin
  { Simply re-route }
  Result := (Find(AValue) <> nil);
end;

procedure TTree<T>.CopyTo(var AArray: array of T; const StartIndex: NativeUInt);
var
  LIndex: NativeInt;
begin
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  { Check for indexes }
  if (NativeUInt(Length(AArray)) - StartIndex) < FCount then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Copy from tree to array }
  LIndex := StartIndex;
  CopyToArray(AArray, LIndex, FRoot);
end;

procedure TTree<T>.CopyToArray(var AArray: array of T; const AIndex: NativeInt; const ARefNode: TTreeNode<T>);
var
  LCurrent: TTreeNode<T>;
  LIndex: NativeUInt;
begin
  LIndex := AIndex;
  AArray[AIndex] := ARefNode.FData;

  LCurrent := ARefNode.FFirstChild;
  while LCurrent <> nil do
  begin
    { Copy each child in }
    Inc(LIndex);
    CopyToArray(AArray, LIndex, ARefNode);
  end;
end;

procedure TTree<T>.CopyTo(var AArray: array of T);
begin
  { Call the more generic copy to }
  CopyTo(AArray, 0);
end;

constructor TTree<T>.Create(const ATree: TTree<T>);
begin
  Create(TType<T>.Default, ATree);
end;

constructor TTree<T>.Create(const AType: IType<T>; const AValue: T);
begin
  { Call the upper ctor }
  Create(AType, TTreeNode<T>.Create(AValue, Self));
end;

constructor TTree<T>.Create(const AType: IType<T>; const ATree: TTree<T>);
begin
  if (ATree = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ATree');

  { Copy the tree with a cloned node }
  Create(AType, ATree.FRoot.CloneNode());
end;

constructor TTree<T>.Create(const AType: IType<T>; const ARoot: TTreeNode<T>);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  if (ARoot = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ARoot');

  InstallType(AType);

  FRoot := ARoot;
  FCount := 1;
  FVer := 0;
end;

constructor TTree<T>.Create(const AValue: T);
begin
  Create(TType<T>.Default, AValue);
end;

destructor TTree<T>.Destroy;
begin
  { Clear the tree first }
  Clear();

  inherited;
end;

function TTree<T>.Empty: Boolean;
begin

end;

function TTree<T>.Find(const AValue: T): TTreeNode<T>;
begin
  Result := FRoot.FindChild(AValue);
end;

function TTree<T>.GetCount: NativeUInt;
begin
  Result := FCount;
end;

function TTree<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

procedure TTree<T>.Remove(const AValue: T);
var
  LNode: TTreeNode<T>;
begin
  { Find the node }
  LNode := Find(AValue);

  { And remove it if found }
  if LNode <> nil then
  begin
    LNode.FNoClean := true;
    LNode.Free;
  end;
end;

{ TTreeNode<T> }

procedure TTreeNode<T>.AddChild(const AChild: TTreeNode<T>);
begin
  if AChild = nil then
    ExceptionHelper.Throw_ArgumentNilError('AChild');

  if FTree <> nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if AChild.FTree <> FTree then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('AChild');

  if AChild.IsAPartOf(FTree) then
    ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('AChild');

  { Link myself to the child }
  AChild.FParent := Self;

  { Set the child's level accordingly }
  AChild.FLevel := FLevel + 1;

  { Link in the node }
  if FLastChild = nil then
    FFirstChild := AChild
  else begin
    FLastChild.FRightSibling := AChild;
    AChild.FLeftSibling := FLastChild;
  end;

  { set the last node }
  FLastChild := AChild;

  { Update the tree }
  Inc(FTree.FCount);
  Inc(FTree.FVer);
end;

procedure TTreeNode<T>.AddSiblingAfter(const ASibling: TTreeNode<T>);
begin
  if ASibling = nil then
    ExceptionHelper.Throw_ArgumentNilError('ASibling');

  if FTree <> nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if FParent = nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if ASibling.FTree <> FTree then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('ASibling');

  if ASibling.IsAPartOf(FTree) then
    ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ASibling');

  { Link parent to the sibling }
  ASibling.FParent := FParent;

  { Set the sibling's level accordingly }
  ASibling.FLevel := FLevel;

  { Link in the node }
  ASibling.FLeftSibling := Self;
  ASibling.FRightSibling := FRightSibling;

  if FRightSibling <> nil then
    FRightSibling.FLeftSibling := ASibling
  else
    FParent.FLastChild := ASibling;

  FRightSibling := ASibling;

  { Update the tree }
  Inc(FTree.FCount);
  Inc(FTree.FVer);
end;

procedure TTreeNode<T>.AddSiblingBefore(const ASibling: TTreeNode<T>);
begin
  if ASibling = nil then
    ExceptionHelper.Throw_ArgumentNilError('ASibling');

  if FTree <> nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if FParent = nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if ASibling.FTree <> FTree then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('ASibling');

  if ASibling.IsAPartOf(FTree) then
    ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ASibling');

  { Link parent to the sibling }
  ASibling.FParent := FParent;

  { Set the sibling's level accordingly }
  ASibling.FLevel := FLevel;

  { Link in the node }
  ASibling.FLeftSibling := FLeftSibling;
  ASibling.FRightSibling := Self;

  if FLeftSibling <> nil then
    FLeftSibling.FRightSibling := ASibling
  else
    FParent.FFirstChild := ASibling;

  FLeftSibling := ASibling;

  { Update the tree }
  Inc(FTree.FCount);
  Inc(FTree.FVer);
end;

function TTreeNode<T>.Children: IEnexCollection<TTreeNode<T>>;
var
  LResult: TSiblingsEnumerable;
begin
  if FTree <> nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  LResult := TSiblingsEnumerable.Create(FTree);
  LResult.FStart := FFirstChild;
  LResult.FEnd := nil;

  { -<< }
  Result := LResult;
end;

function TTreeNode<T>.CloneNode: TTreeNode<T>;
var
  LCurrent: TTreeNode<T>;
begin
  Result := TTreeNode<T>.Create(FData, FTree);
  Result.FNoClean := FNoClean;
  Result.FLevel := FLevel;

  LCurrent := FFirstChild;
  while LCurrent <> nil do
    Result.AddChild(LCurrent.CloneNode());
end;

constructor TTreeNode<T>.Create(const Value: T; const ATree: TTree<T>);
begin
  if ATree = nil then
     ExceptionHelper.Throw_ArgumentNilError('ATree');

  { Assign the value }
  FData := Value;

  { Initialize internals to nil }
  FTree := ATree;
end;

destructor TTreeNode<T>.Destroy;
begin
  { Free first child. The destructor of each child will adjust the parent accordingly }
  while FFirstChild <> nil do
    FFirstChild.Free;

  { Adjust my right and left siblings, remove myself }
  if (FLeftSibling <> nil) then
    FLeftSibling.FRightSibling := FRightSibling;

  if (FRightSibling <> nil) then
    FRightSibling.FLeftSibling := FLeftSibling;

  { Remove myself as the first in the child list }
  if (FParent <> nil) and (FParent.FFirstChild = Self) then
    FParent.FFirstChild := FRightSibling;

  { Remove myself as the last in the child list }
  if (FParent <> nil) and (FParent.FLastChild = Self) then
    FParent.FLastChild := FLeftSibling;

  { In case this is the root node, disconnect from the tree }
  if (FTree <> nil) then
  begin
    if (FParent = nil) then
      FTree.FRoot := nil;

    { Clean myself up }
    if (FTree.ElementType.Management() = tmManual) and (not FNoClean) then
      FTree.ElementType.Cleanup(FData);

    Dec(FTree.FCount);
    Inc(FTree.FVer);
  end;

  inherited;
end;

function TTreeNode<T>.FindChild(const AValue: T): TTreeNode<T>;
var
  LCurrent: TTreeNode<T>;
begin
  if FTree <> nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if FTree.ElementType.AreEqual(FData, AValue) then
    Exit(Self);

  LCurrent := FFirstChild;
  Result := nil;

  while LCurrent <> nil do
  begin
    Result := LCurrent.FindChild(AValue);
    if Result <> nil then
      Break;

    LCurrent := FRightSibling;
  end;
end;

function TTreeNode<T>.IsAPartOf(const ATree: TTree<T>): Boolean;
begin
  if (FTree <> ATree) then
    Exit(False);

  if (FParent = nil) then
  begin
    if FTree.FRoot = Self then
      Exit(True)
    else
      Exit(False);
  end
  else
    Exit(True);
end;


function TTreeNode<T>.SiblingsAfter(const AIncludingThis: Boolean): IEnexCollection<TTreeNode<T>>;
var
  LResult: TSiblingsEnumerable;
begin
  if FTree <> nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if FParent = nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  LResult := TSiblingsEnumerable.Create(FTree);
  LResult.FEnd := nil;

  { Enumerate! }
  if AIncludingThis then
    LResult.FStart := Self
  else
    LResult.FStart := Self.FRightSibling;

  { -<< }
  Result := LResult;
end;

function TTreeNode<T>.SiblingsBefore(const AIncludingThis: Boolean): IEnexCollection<TTreeNode<T>>;
var
  LResult: TSiblingsEnumerable;
begin
  if FTree <> nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  if FParent = nil then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('Self');

  LResult := TSiblingsEnumerable.Create(FTree);
  LResult.FStart := FParent.FFirstChild;

  { Enumerate! }
  if AIncludingThis then
    LResult.FEnd := Self.FRightSibling
  else
    LResult.FEnd := Self;

  { -<< }
  Result := LResult;
end;

{ TTree<T>.TEnumerator }

constructor TTree<T>.TEnumerator.Create(const ATree: TTree<T>);
begin
  KeepObjectAlive(FTree);

  FTree := ATree;
  FVer := FTree.FVer;
end;

destructor TTree<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FTree);
  inherited;
end;

function TTree<T>.TEnumerator.GetCurrent: T;
begin
  if (FVer <> FTree.FVer) then
     ExceptionHelper.Throw_CollectionChangedError();

  if FCurrent <> nil then
    Result := FCurrent.FData
  else
    Result := default(T);
end;

function TTree<T>.TEnumerator.MoveNext: Boolean;
begin
  if (FVer <> FTree.FVer) then
     ExceptionHelper.Throw_CollectionChangedError();

  if FCurrent = nil then
    FCurrent := FTree.FRoot
  else
  begin
    if (FCurrent.FFirstChild <> nil) then // Select the first child
      FCurrent := FCurrent.FFirstChild
    else if FCurrent.FRightSibling <> nil then // Select the sibling if no child is possible
      FCurrent := FCurrent.FRightSibling
    else begin
      { No siblings to go to next, select parent's sibling }
      if (FCurrent.FParent <> nil) and (FCurrent.FParent.FRightSibling <> nil) then
        FCurrent := FCurrent.FParent.FRightSibling
      else
        FCurrent := nil; // Cannot go up.
    end;
  end;

  { Check for end }
  Result := (FCurrent <> nil);
end;

{ TTreeNode<T>.TSiblingsEnumerable }

constructor TTreeNode<T>.TSiblingsEnumerable.Create(const ATree: TTree<T>);
begin
  FTree := ATree;
  KeepObjectAlive(FTree);
end;

destructor TTreeNode<T>.TSiblingsEnumerable.Destroy;
begin
  ReleaseObject(FTree);
  inherited;
end;

function TTreeNode<T>.TSiblingsEnumerable.GetEnumerator: IEnumerator<TTreeNode<T>>;
var
  LResult: TSiblingsEnumerator;
begin
  LResult := TSiblingsEnumerator.Create(Self);
  LResult.FStart := FStart;
  LResult.FEnd := FEnd;
  LResult.FVer := FTree.FVer;

  Result := LResult;
end;

{ TTreeNode<T>.TSiblingsEnumerator }

constructor TTreeNode<T>.TSiblingsEnumerator.Create(const AEnum: TSiblingsEnumerable);
begin
  FEnum := AEnum;
  KeepObjectAlive(AEnum);
end;

destructor TTreeNode<T>.TSiblingsEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TTreeNode<T>.TSiblingsEnumerator.GetCurrent: TTreeNode<T>;
begin
  if (FVer <> FEnum.FTree.FVer) then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FCurrent;
end;

function TTreeNode<T>.TSiblingsEnumerator.MoveNext: Boolean;
begin
  if (FVer <> FEnum.FTree.FVer) then
     ExceptionHelper.Throw_CollectionChangedError();

  { Start and continue until FEnd or NIL is reached }
  if FCurrent = nil then
    FCurrent := FStart
  else
    FCurrent := FCurrent.FRightSibling;

  Result := (FCurrent <> nil) and (FCurrent <> FEnd);
end;

end.
