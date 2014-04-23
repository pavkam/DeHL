(*
* Copyright (c) 2008-2009, Lucian Bentea
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
unit DeHL.Collections.BinaryTree;

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
  TBinaryTree<T> = class;

  { Generic Binary Tree Node }
  TBinaryTreeNode<T> = class sealed(TSimpleObject)
  private
    FRemoved: Boolean;
    FData: T;
    FLeft,
      FRight, FParent: TBinaryTreeNode<T>;
    FBinaryTree: TBinaryTree<T>;

    function IsAPartOf(const BinaryTree: TBinaryTree<T>): Boolean;

  public
    { Constructors }
    constructor Create(const Value: T; const ATree: TBinaryTree<T>);

    { Destructors }
    destructor Destroy(); override;

    { Properties }
    property Value: T read FData write FData;
    property Left: TBinaryTreeNode<T> read FLeft;
    property Right: TBinaryTreeNode<T> read FRight;
    property Parent: TBinaryTreeNode<T> read FParent;
    property BinaryTree: TBinaryTree<T> read FBinaryTree;
  end;

  { Generic Binary Tree }
  TBinaryTree<T> = class(TEnexCollection<T>)
  private
  type
    { Generic Binary Tree Enumerator (uses post-order traversal)}
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FBinaryTree: TBinaryTree<T>;
      FCurrentIndex: NativeUInt;
      FTraverseArray: TFixedArray<T>;

    public
      { Constructor }
      constructor Create(const ATree: TBinaryTree<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FRoot: TBinaryTreeNode<T>;
    FCount: NativeUInt;
    FVer: NativeUInt;

    procedure RecFind(const ARefNode: TBinaryTreeNode<T>; const AValue: T; var Node: TBinaryTreeNode<T>);
    procedure CopyTree(var ASrcNode, ADestNode: TBinaryTreeNode<T>);
    procedure CopyToArray(var AArray: array of T; var Index: NativeInt; const ARefNode: TBinaryTreeNode<T>);

    { Pre/Post/In order listing }
    procedure PreOrderSearchArray(const ARefNode: TBinaryTreeNode<T>; var AArray: TDynamicArray<T>);
    procedure InOrderSearchArray(const ARefNode: TBinaryTreeNode<T>; var AArray: TDynamicArray<T>);
    procedure PostOrderSearchArray(const ARefNode: TBinaryTreeNode<T>; var AArray: TDynamicArray<T>);

  protected
    { Hidden ICollection support }
    function GetCount(): NativeUInt; override;
  public
    { Constructors }
    constructor Create(const AValue: T); overload;
    constructor Create(const ATree: TBinaryTree<T>); overload;

    constructor Create(const AType: IType<T>; const AValue: T); overload;
    constructor Create(const AType: IType<T>; const ATree: TBinaryTree<T>); overload;

    { Destructors }
    destructor Destroy(); override;

    { Adds a left child to ARefNode }
    procedure AddLeft(const ARefNode: TBinaryTreeNode<T>; const AValue: T); overload;
    procedure AddLeft(const ARefNode: TBinaryTreeNode<T>; const ANode: TBinaryTreeNode<T>); overload;

    { Adds a right child to ARefNode }
    procedure AddRight(const ARefNode: TBinaryTreeNode<T>; const AValue: T); overload;
    procedure AddRight(const ARefNode: TBinaryTreeNode<T>; const ANode: TBinaryTreeNode<T>); overload;

    { Removing }
    procedure Clear();

    { looks for AValue, remove it, and all its subtree }
    procedure Remove(const AValue: T); overload;

    { remove ARefNode and its subtree }
    procedure Remove(const ARefNode: TBinaryTreeNode<T>); overload;

    { Lookup }
    function Contains(const AValue: T): Boolean;
    function Find(const AValue: T): TBinaryTreeNode<T>;

    { Properties }
    property Count: NativeUInt read FCount;
    property Root: TBinaryTreeNode<T> read FRoot;

    { Copy to array support (it traverses the tree in post-order when copying the elements) }
    procedure CopyTo(var AArray: array of T); overload; override;
    procedure CopyTo(var AArray: array of T; const StartIndex: NativeUInt); overload; override;

    { Traverse the tree in various orders}
    function PreOrder(): TFixedArray<T>;
    function InOrder(): TFixedArray<T>;
    function PostOrder(): TFixedArray<T>;

    { used in "for I in Tree" blocks }
    function GetEnumerator(): IEnumerator<T>; override;

    { Enex Overrides }
    function Empty(): Boolean; override;
  end;

  { The object variant }
  TObjectBinaryTree<T: class> = class(TBinaryTree<T>)
  private
    FWrapperType: TObjectWrapperType<T>;

    { Getters/Setters for OwnsObjects }
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);

  protected
    { Override in descendants to support proper stuff }
    procedure InstallType(const AType: IType<T>); override;

  public
    { Object owning }
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

{ TBinaryTree<T> }

procedure TBinaryTree<T>.AddLeft(const ARefNode, ANode: TBinaryTreeNode<T>);
begin
  if ARefNode = nil then
    ExceptionHelper.Throw_ArgumentNilError('ARefNode');

  if ANode = nil then
    ExceptionHelper.Throw_ArgumentNilError('ANode');

  if ARefNode.FBinaryTree <> Self then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('ARefNode');

  if ANode.FBinaryTree <> Self then
    ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  if ANode.IsAPartOf(Self) then
    ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  if ARefNode.FLeft <> nil then
    ExceptionHelper.Throw_PositionOccupiedError();

  ANode.FBinaryTree := Self;
  ANode.FParent := ARefNode;
  ARefNode.FLeft := ANode;

  Inc(FCount);
  Inc(FVer);
end;

procedure TBinaryTree<T>.AddLeft(const ARefNode: TBinaryTreeNode<T>; const AValue: T);
begin
  AddLeft(ARefNode, TBinaryTreeNode<T>.Create(AValue, Self));
end;

procedure TBinaryTree<T>.AddRight(const ARefNode, ANode: TBinaryTreeNode<T>);
begin
  if ARefNode = nil then
    ExceptionHelper.Throw_ArgumentNilError('ARefNode');

  if ANode = nil then
    ExceptionHelper.Throw_ArgumentNilError('ANode');

  if ARefNode.FBinaryTree <> Self then
    ExceptionHelper.Throw_ElementNotPartOfCollectionError('ARefNode');

  if ANode.FBinaryTree <> Self then
    ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  if ANode.IsAPartOf(Self) then
    ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError('ANode');

  if ARefNode.FRight <> nil then
    ExceptionHelper.Throw_PositionOccupiedError();

  ANode.FBinaryTree := Self;
  ANode.FParent := ARefNode;
  ARefNode.FRight := ANode;

  Inc(FCount);
  Inc(FVer);
end;

procedure TBinaryTree<T>.AddRight(const ARefNode: TBinaryTreeNode<T>; const AValue: T);
begin
  AddRight(ARefNode, TBinaryTreeNode<T>.Create(AValue, Self));
end;

procedure TBinaryTree<T>.Clear;
begin
  if (FRoot <> nil) then
  begin
    FRoot.Free;
    FRoot := nil;

    Inc(FVer);
  end;
end;

function TBinaryTree<T>.Contains(const AValue: T): Boolean;
begin
  { Simply re-route }
  Result := (Find(AValue) <> nil);
end;

procedure TBinaryTree<T>.CopyTree(var ASrcNode, ADestNode: TBinaryTreeNode<T>);
var
  tmp: TBinaryTreeNode<T>;
begin
  if (ASrcNode.FLeft <> nil) then
  begin
    tmp := TBinaryTreeNode<T>.Create(ASrcNode.FLeft.FData, Self);
    tmp.FParent := ADestNode;
    ADestNode.FLeft := tmp;
    Inc(FCount);
    CopyTree(ASrcNode.FLeft, ADestNode.FLeft);
  end;

  if (ASrcNode.FRight <> nil) then
  begin
    tmp := TBinaryTreeNode<T>.Create(ASrcNode.FRight.FData, SElf);
    tmp.FParent := ADestNode;
    ADestNode.FRight := tmp;
    Inc(FCount);
    CopyTree(ASrcNode.FRight, ADestNode.FRight);
  end;
end;

procedure TBinaryTree<T>.CopyTo(var AArray: array of T; const StartIndex: NativeUInt);
var
  Index: NativeInt;
begin
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  { Check for indexes }
  if (NativeUInt(Length(AArray)) - StartIndex) < FCount then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Copy from tree to array }
  Index := StartIndex;
  CopyToArray(AArray, Index, FRoot);
end;

procedure TBinaryTree<T>.CopyToArray(var AArray: array of T; var Index: NativeInt; const ARefNode: TBinaryTreeNode<T>);
begin
  if (ARefNode.Left <> nil) then
    CopyToArray(AArray, Index, ARefNode.Left);

  if (ARefNode.Right <> nil) then
    CopyToArray(AArray, Index, ARefNode.Right);

  AArray[Index] := ARefNode.FData;
  Inc(Index);
end;

procedure TBinaryTree<T>.CopyTo(var AArray: array of T);
begin
  { Call the more generic copy to }
  CopyTo(AArray, 0);
end;

constructor TBinaryTree<T>.Create(const AType: IType<T>; const AValue: T);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  InstallType(AType);

  FRoot := TBinaryTreeNode<T>.Create(AValue, Self);
  FCount := 1;
  FVer := 0;
end;

constructor TBinaryTree<T>.Create(const AValue: T);
begin
  Create(TType<T>.Default, AValue);
end;

constructor TBinaryTree<T>.Create(const AType: IType<T>; const ATree: TBinaryTree<T>);
begin
  if (ATree = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ATree');

  Create(AType, ATree.FRoot.FData);

  { Try to copy the given tree }
  CopyTree(ATree.FRoot, FRoot);
end;

constructor TBinaryTree<T>.Create(const ATree: TBinaryTree<T>);
begin
  Create(TType<T>.Default, ATree);
end;

destructor TBinaryTree<T>.Destroy;
begin
  { Clear the tree first }
  Clear();

  inherited;
end;

function TBinaryTree<T>.Empty: Boolean;
begin
  Result := (FCount = 0);
end;

function TBinaryTree<T>.Find(const AValue: T): TBinaryTreeNode<T>;
var
  tmp: TBinaryTreeNode<T>;
begin
  tmp := nil;
  RecFind(Self.FRoot, AValue, tmp);
  Result := tmp;
end;

function TBinaryTree<T>.GetCount: NativeUInt;
begin
  Result := FCount;
end;

function TBinaryTree<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

function TBinaryTree<T>.InOrder: TFixedArray<T>;
var
  Arr: TDynamicArray<T>;
begin
  InOrderSearchArray(FRoot, Arr);
  Result := Arr.ToFixedArray();
end;

procedure TBinaryTree<T>.InOrderSearchArray(const ARefNode: TBinaryTreeNode<T>;
  var AArray: TDynamicArray<T>);
begin
  if (ARefNode.Left <> nil) then
    InOrderSearchArray(ARefNode.Left, AArray);

  AArray.Append(ARefNode.FData);

  if (ARefNode.Right <> nil) then
    InOrderSearchArray(ARefNode.Right, AArray);
end;

function TBinaryTree<T>.PostOrder: TFixedArray<T>;
var
  Arr: TDynamicArray<T>;
begin
  PostOrderSearchArray(FRoot, Arr);
  Result := Arr.ToFixedArray();
end;

procedure TBinaryTree<T>.PostOrderSearchArray(
  const ARefNode: TBinaryTreeNode<T>; var AArray: TDynamicArray<T>);
begin
  if (ARefNode.Left <> nil) then
    PostOrderSearchArray(ARefNode.Left, AArray);

  if (ARefNode.Right <> nil) then
    PostOrderSearchArray(ARefNode.Right, AArray);

  AArray.Append(ARefNode.FData);
end;

function TBinaryTree<T>.PreOrder: TFixedArray<T>;
var
  Arr: TDynamicArray<T>;
begin
  PreOrderSearchArray(FRoot, Arr);
  Result := Arr.ToFixedArray();
end;

procedure TBinaryTree<T>.PreOrderSearchArray(const ARefNode: TBinaryTreeNode<T>;
  var AArray: TDynamicArray<T>);
begin
  AArray.Append(ARefNode.FData);

  if (ARefNode.Left <> nil) then
    PreOrderSearchArray(ARefNode.Left, AArray);

  if (ARefNode.Right <> nil) then
    PreOrderSearchArray(ARefNode.Right, AArray);
end;

procedure TBinaryTree<T>.RecFind(const ARefNode: TBinaryTreeNode<T>; const AValue: T; var Node: TBinaryTreeNode<T>);
begin
  if Node = nil then
  begin
    if (ElementType.AreEqual(ARefNode.FData, AValue)) then
    begin
      Node := ARefNode;
      Exit;
    end;

    if (ARefNode.Left <> nil) then
      RecFind(ARefNode.Left, AValue, Node);

    if (ARefNode.Right <> nil) then
      RecFind(ARefNode.Right, AValue, Node);
  end;
end;

procedure TBinaryTree<T>.Remove(const ARefNode: TBinaryTreeNode<T>);
begin
  if (ARefNode = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ARefNode');

  if (ARefNode.FBinaryTree <> Self) then
     ExceptionHelper.Throw_ElementNotPartOfCollectionError('ARefNode');

  ARefNode.Free;
end;

procedure TBinaryTree<T>.Remove(const AValue: T);
var
  Node, Parent: TBinaryTreeNode<T>;
  Left: Boolean;
begin
  Node := Find(AValue);

  if Node = FRoot then
    Clear()
  else
    if Node <> nil then
    begin
      Parent := Node.Parent;
      Left := True;

      if ((Parent.FRight <> nil) And ElementType.AreEqual(Parent.FRight.FData, AValue)) then
        Left := False;

      Node.FRemoved := true;
      Node.Free();

      if Left then
        Parent.FLeft := nil
      else
        Parent.FRight := nil;
    end;
end;

{ TBinaryTreeNode<T> }

constructor TBinaryTreeNode<T>.Create(const Value: T; const ATree: TBinaryTree<T>);
begin
  if ATree = nil then
     ExceptionHelper.Throw_ArgumentNilError('ATree');

  { Assign the value }
  FData := Value;

  { Initialize internals to nil }
  FLeft       := nil;
  FRight      := nil;
  FParent     := nil;
  FBinaryTree := ATree;
end;

destructor TBinaryTreeNode<T>.Destroy;
begin
  if FLeft <> nil then
    FLeft.Free();

  if FRight <> nil then
    FRight.Free();

  if (FBinaryTree <> nil)  then
  begin
    { Is this node root? }
    if FParent = nil then
       FBinaryTree.FRoot := nil
    else
    begin
      { Disconnect fron the parent node }
      if FParent.FLeft = Self then
        FParent.FLeft := nil
      else
        FParent.FRight := nil;
    end;

    { Clean myself up }
    if (FBinaryTree.ElementType.Management() = tmManual) and (not FRemoved) then
       FBinaryTree.ElementType.Cleanup(FData);

    Dec(FBinaryTree.FCount);
    Inc(FBinaryTree.FVer);
  end;

  inherited;
end;

function TBinaryTreeNode<T>.IsAPartOf(const BinaryTree: TBinaryTree<T>): Boolean;
begin
  if (FBinaryTree <> BinaryTree) then
    Exit(False);

  if (FParent = nil) then
  begin
    if FBinaryTree.FRoot = Self then
      Exit(True)
    else
      Exit(False);
  end
  else
    Exit(True);
end;

{ TBinaryTree<T>.TEnumerator }

constructor TBinaryTree<T>.TEnumerator.Create(const ATree: TBinaryTree<T>);
begin
   { Initialize }
  FBinaryTree := ATree;
  KeepObjectAlive(ATree);

  FTraverseArray := FBinaryTree.PostOrder();
  FCurrentIndex := 0;
  FVer := ATree.FVer;
end;

destructor TBinaryTree<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FBinaryTree);
  inherited;
end;

function TBinaryTree<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FBinaryTree.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  if FCurrentIndex > 0 then
    Result := FTraverseArray.Items[FCurrentIndex - 1]
  else
    Result := default(T);
end;

function TBinaryTree<T>.TEnumerator.MoveNext: Boolean;
begin
  if FVer <> FBinaryTree.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FCurrentIndex < FTraverseArray.Length;
  Inc(FCurrentIndex);
end;

{ TObjectBinaryTree<T> }

procedure TObjectBinaryTree<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectBinaryTree<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectBinaryTree<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.

