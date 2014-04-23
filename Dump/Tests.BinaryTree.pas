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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.BinaryTree;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.BinaryTree,
     DeHL.Collections.Base,
     DeHL.Collections.List,
     DeHL.Arrays;

type
 TTestBinaryTree = class(TDeHLTestCase)
 published
   procedure TestClear();
   procedure TestFind();
   procedure TestContains();
   procedure TestRemove();
   procedure TestCreationAndDestroy();
   procedure TestCopyTo();
   procedure TestExceptions();
   procedure TestGenArrayLists();
   procedure TestEnumerator();

   procedure TestObjectVariant();

   procedure TestCleanup();
 end;

implementation

{ TTestBinaryTree }

procedure TTestBinaryTree.TestCleanup;
var
  ATree : TBinaryTree<Integer>;
  ElemCache: Integer;
  I: Integer;
begin
  ElemCache := 0;

  { Create a new ATree }
  ATree := TBinaryTree<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end), 1
  );

  { Add some elements }
  ATree.AddLeft(ATree.Root, 2);
  ATree.AddRight(ATree.Root, 4);
  ATree.AddLeft(ATree.Root.Left, 8);
  ATree.AddRight(ATree.Root.Left, 16);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  ATree.Remove(8);
  ATree.Remove(16);
  ATree.Contains(10);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  { Simply walk the ATree }
  for I in ATree do
    if I > 0 then;

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  ATree.Clear();
  Check(ElemCache = 7, 'Expected cache = 7');

  ATree.Destroy;

  { Create a new ATree }
  ATree := TBinaryTree<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end), 1
  );

  ElemCache := 0;

  ATree.AddLeft(ATree.Root, 2);
  ATree.AddRight(ATree.Root, 4);
  ATree.AddLeft(ATree.Root.Left, 8);
  ATree.AddRight(ATree.Root.Left, 16);

  ATree.Root.Left.Left.Free;
  Check(ElemCache = 8, 'Expected cache = 8');

  ElemCache := 0;
  ATree.Free;

  Check(ElemCache = 23, 'Expected cache = 23');
end;

procedure TTestBinaryTree.TestClear;
var
 Tree : TBinaryTree<String>;
begin
 { Initialize the list = 'First'}
 Tree := TBinaryTree<String>.Create('root');

 Tree.AddLeft(Tree.Root, '1');
 Tree.AddRight(Tree.Root, '2');
 Tree.AddLeft(Tree.Root.Left, 'a');
 Tree.AddRight(Tree.Root.Left, 'b');

 Check(Tree.Count = 5, 'Count is incorrect!');

 Tree.Clear();

 Check(Tree.Count = 0, 'Count is incorrect!');

 Check(Tree.Root = nil, 'Root must be nil.');

 Tree.Free();
end;

procedure TTestBinaryTree.TestFind;
var
 Tree : TBinaryTree<String>;
begin
 { Initialize the tree}
 Tree := TBinaryTree<String>.Create(TStringType.Create(True), 'root');

 Tree.AddLeft(Tree.Root, 'First');
 Tree.AddRight(Tree.Root, 'Second');
 Tree.AddLeft(Tree.Root.Right, 'Third');
 Tree.AddRight(Tree.Root.Right, 'ThIrd');

 { Normal find }
 Check(Tree.Find('FIRST') <> nil, 'Did not find "FIRST" in the list (Insensitive)');
 Check(Tree.Find('FIRST').Value = 'First', 'Found node is not the one searched for ("FIRST") in the list (Insensitive)');

 Check(Tree.Find('tHIRD') <> nil, 'Did not find "tHIRD" in the list (Insensitive)');
 Check(Tree.Find('tHIRD').Value = 'Third', 'Found node is not the one searched for ("tHIRD") in the list (Insensitive)');

 Check(Tree.Find('sEcOnD') <> nil, 'Did not find "sEcOnD" in the list (Insensitive)');
 Check(Tree.Find('sEcOnD').Value = 'Second', 'Found node is not the one searched for ("sEcOnD") in the list (Insensitive)');

 Check(Tree.Find('Lom') = nil, 'Found "Lom" when it''s not contained there! (Insensitive)');

 Tree.Free();
end;

procedure TTestBinaryTree.TestGenArrayLists;
var
  Tree: TBinaryTree<Integer>;
  InOrderArr,
    PreOrderArr,
      PostOrderArr : TFixedArray<Integer>;
begin
  Tree := TBinaryTree<Integer>.Create(5);
  Tree.AddLeft(Tree.Root, 2);
  Tree.AddRight(Tree.Root, 1);
  Tree.AddLeft(Tree.Root.Left, 8);

  { Generate lists }
  InOrderArr := Tree.InOrder();
  PreOrderArr := Tree.PreOrder();
  PostOrderArr := Tree.PostOrder();

  { Test counts }
  Check(InOrderArr.Length = 4, 'Count of InOrderArr expected to be 4');
  Check(PreOrderArr.Length = 4, 'Count of PreOrderArr expected to be 4');
  Check(PostOrderArr.Length = 4, 'Count of PostOrderArr expected to be 4');

  { Test elements }
  Check(InOrderArr[0] = 8, 'InOrderArr[0] expected to be 8');
  Check(InOrderArr[1] = 2, 'InOrderArr[1] expected to be 2');
  Check(InOrderArr[2] = 5, 'InOrderArr[2] expected to be 5');
  Check(InOrderArr[3] = 1, 'InOrderArr[3] expected to be 1');

  Check(PreOrderArr[0] = 5, 'PreOrderArr[0] expected to be 5');
  Check(PreOrderArr[1] = 2, 'PreOrderArr[1] expected to be 2');
  Check(PreOrderArr[2] = 8, 'PreOrderArr[2] expected to be 8');
  Check(PreOrderArr[3] = 1, 'PreOrderArr[3] expected to be 1');

  Check(PostOrderArr[0] = 8, 'PostOrderArr[0] expected to be 8');
  Check(PostOrderArr[1] = 2, 'PostOrderArr[1] expected to be 2');
  Check(PostOrderArr[2] = 1, 'PostOrderArr[2] expected to be 1');
  Check(PostOrderArr[3] = 5, 'PostOrderArr[3] expected to be 5');

  { Free resources }
  Tree.Free;
end;

procedure TTestBinaryTree.TestObjectVariant;
var
  ObjTree: TObjectBinaryTree<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  TheObject := TTestObject.Create(@ObjectDied);

  ObjTree := TObjectBinaryTree<TTestObject>.Create(TheObject);
  Check(not ObjTree.OwnsObjects, 'OwnsObjects must be false!');
  ObjTree.Free;
  Check(not ObjectDied, 'The object should not have been cleaned up!');

  ObjTree := TObjectBinaryTree<TTestObject>.Create(TheObject);
  ObjTree.OwnsObjects := true;
  Check(ObjTree.OwnsObjects, 'OwnsObjects must be true!');

  ObjTree.Clear;

  Check(ObjectDied, 'The object should have been cleaned up!');
  ObjTree.Free;
end;

procedure TTestBinaryTree.TestContains;
var
 Tree : TBinaryTree<String>;
begin
 { Initialize the list = 'First'}
 Tree := TBinaryTree<String>.Create(TStringType.Create(True), 'root');
 Tree.AddLeft(Tree.Root, 'First');
 Tree.AddRight(Tree.Root, 'Second');
 Tree.AddLeft(Tree.Root.Left, 'Third');

 Check(Tree.Contains('FIRST'), 'Did not find "FIRST" in the list (Insensitive)');
 Check(Tree.Contains('tHIRD'), 'Did not find "tHIRD" in the list (Insensitive)');
 Check(Tree.Contains('sEcOnD'), 'Did not find "sEcOnD" in the list (Insensitive)');
 Check((not Tree.Contains('Yuppy')), 'Did find "Yuppy" in the list (Insensitive)');

 Tree.Free();
end;

procedure TTestBinaryTree.TestRemove;
var
 Tree : TBinaryTree<Extended>;
begin
 { Initialize the list }
 Tree := TBinaryTree<Extended>.Create(0);

 Tree.AddLeft(Tree.Root, 3.1415);
 Tree.AddRight(Tree.Root, 2.71);
 Tree.AddLeft(Tree.Root.Right, 0.1);
 Tree.AddRight(Tree.Root.Right, 0.2);
 Tree.AddLeft(Tree.Root.Right.Right, 0.9999);

 Tree.Remove(2.71);
 Check(Tree.Count = 2, 'Tree count must be 2');

 Tree.Remove(Tree.Find(0).Value);
 Check(Tree.Count = 0, 'Tree count must be 0');

 { Free }
 Tree.Free();
end;

procedure TTestBinaryTree.TestCreationAndDestroy;
var
 Tree, CopyTree : TBinaryTree<Integer>;
// IL             : array of Integer;
begin
 { Initialize the list }
 Tree := TBinaryTree<Integer>.Create(0);

 Tree.AddLeft(Tree.Root, 1);
 Tree.AddRight(Tree.Root, 2);
 Tree.AddLeft(Tree.Root.Left, 11);
 Tree.AddRight(Tree.Root.Left, 12);

 Check(Tree.Count = 5, 'Count must be 5 elements!');

 Check(Tree.Root.Value = 0, 'Expected 0 but got another value!');
 Check(Tree.Root.Left.Value = 1, 'Expected 1 but got another value!');
 Check(Tree.Root.Right.Value = 2, 'Expected 2 but got another value!');
 Check(Tree.Root.Left.Left.Value = 11, 'Expected 11 but got another value!');
 Check(Tree.Root.Left.Right.Value = 12, 'Expected 12 but got another value!');

 { Test the copy}
 CopyTree := TBinaryTree<Integer>.Create(Tree);

 Check(CopyTree.Count = 5, '(Copy) Count must be 5 elements!');
 Check(CopyTree.Root.Value = 0, 'Expected 0 but got another value!');
 Check(CopyTree.Root.Left.Value = 1, 'Expected 1 but got another value!');
 Check(CopyTree.Root.Right.Value = 2, 'Expected 2 but got another value!');
 Check(CopyTree.Root.Left.Left.Value = 11, 'Expected 11 but got another value!');
 Check(CopyTree.Root.Left.Right.Value = 12, 'Expected 12 but got another value!');

 { Free the list }
 Tree.Free;
 CopyTree.Free;

end;

procedure TTestBinaryTree.TestExceptions;
var
  Tree1, Tree2, TreeX : TBinaryTree<Integer>;
  NullArg : IType<Integer>;
begin
  NullArg := nil;

  Tree1 := TBinaryTree<Integer>.Create(0);
  Tree2 := TBinaryTree<Integer>.Create(0);

  Tree1.AddLeft(Tree1.Root, 1);
  Tree2.AddLeft(Tree2.Root, 1);

  Tree1.AddRight(Tree1.Root, 2);
  Tree2.AddRight(Tree2.Root, 2);

  CheckException(ENilArgumentException,
    procedure()
    begin
      TreeX := TBinaryTree<Integer>.Create(NullArg, 0);
      TreeX.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TreeX := TBinaryTree<Integer>.Create(TType<Integer>.Default, nil);
      TreeX.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil tree).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TreeX := TBinaryTree<Integer>.Create(NullArg, Tree1);
      TreeX.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TreeX := TBinaryTree<Integer>.Create(nil);
      TreeX.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil tree).'
  );


  CheckException(EPositionOccupiedException,
    procedure()
    begin
      Tree1.AddLeft(Tree1.Root, 4);
    end,
    'EPositionOccupiedException not thrown in AddLeft (occupied)!'
  );

  CheckException(EPositionOccupiedException,
    procedure()
    begin
      Tree1.AddRight(Tree1.Root, 4);
    end,
    'EPositionOccupiedException not thrown in AddRight (occupied)!'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Tree1.AddLeft(nil, 4);
    end,
    'ENilArgumentException not thrown in AddLeft (nil ref node)!'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Tree1.AddRight(nil, 4);
    end,
    'ENilArgumentException not thrown in AddRight (nil ref node)!'
  );

  CheckException(EElementNotPartOfCollection,
    procedure()
    begin
      Tree1.AddLeft(Tree2.Root, 4);
    end,
    'EElementNotPartOfCollection not thrown in AddLeft (ref node part of another)!'
  );

  CheckException(EElementNotPartOfCollection,
    procedure()
    begin
      Tree2.AddRight(Tree1.Root, 4);
    end,
    'EElementNotPartOfCollection not thrown in AddRight (ref node part of another)!'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Tree1.AddLeft(Tree1.Root, nil);
    end,
    'ENilArgumentException not thrown in AddLeft (nil add)!'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Tree1.AddRight(Tree1.Root, nil);
    end,
    'ENilArgumentException not thrown in AddRight (nil add)!'
  );

  CheckException(EElementAlreadyInACollection,
    procedure()
    begin
      Tree1.AddLeft(Tree1.Root, Tree2.Root);
    end,
    'EElementAlreadyInACollection not thrown in AddLeft (add part of 2)!'
  );

  CheckException(EElementAlreadyInACollection,
    procedure()
    begin
      Tree1.AddRight(Tree1.Root, Tree2.Root);
    end,
    'EElementAlreadyInACollection not thrown in AddRight (add part of 2)!'
  );

  CheckException(EElementAlreadyInACollection,
    procedure()
    begin
      Tree1.AddLeft(Tree1.Root, Tree1.Root);
    end,
    'EElementAlreadyInACollection not thrown in AddLeft (inter mix)!'
  );

  CheckException(EElementAlreadyInACollection,
    procedure()
    begin
      Tree1.AddRight(Tree1.Root, Tree1.Root);
    end,
    'EElementAlreadyInACollection not thrown in AddRight (inter mix)!'
  );

  CheckException(EElementNotPartOfCollection,
    procedure()
    begin
      Tree1.Remove(Tree2.Root);
    end,
    'EElementNotPartOfCollection not thrown in Remove (2nd tree node)!'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TBinaryTreeNode<Integer>.Create(10, nil);
    end,
    'ENilArgumentException not thrown in TBinaryTreeNode.ctor (nil tree)!'
  );

  Tree1.Free();
  Tree2.Free();
  TreeX.Free();
end;

procedure TTestBinaryTree.TestCopyTo;
var
  Tree : TBinaryTree<Integer>;
  IL   : array of Integer;
begin
  Tree := TBinaryTree<Integer>.Create(0);

  { Add elements to the tree }
  Tree.AddLeft(Tree.Root, -1);
  Tree.AddRight(Tree.Root, -2);

  Tree.AddLeft(Tree.Root.Left, -11);
  Tree.AddRight(Tree.Root.Right, -12);

  { Test Count }
  Check(Tree.GetCount = 5, 'Count must be 5!');

  Tree.Remove(-11);
  Tree.Remove(-12);
  Check(Tree.GetCount = 3, 'Count must be 3!');

  Tree.AddLeft(Tree.Root.Right, -21);
  Tree.AddRight(Tree.Root.Right, -22);
  Tree.AddLeft(Tree.Root.Left, -17);

  Check(Tree.GetCount = 6, 'Count must be 6!');

  { Check the copy }
  SetLength(IL, 6);
  Tree.CopyTo(IL);

  Check(IL[0] = -17, 'Element 0 in the new array is wrong!');
  Check(IL[1] = -1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = -21, 'Element 2 in the new array is wrong!');
  Check(IL[3] = -22, 'Element 3 in the new array is wrong!');
  Check(IL[4] = -2, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 0, 'Element 5 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 7);
  Tree.CopyTo(IL, 1);

  Check(IL[1] = -17, 'Element 0 in the new array is wrong!');
  Check(IL[2] = -1, 'Element 1 in the new array is wrong!');
  Check(IL[3] = -21, 'Element 2 in the new array is wrong!');
  Check(IL[4] = -22, 'Element 3 in the new array is wrong!');
  Check(IL[5] = -2, 'Element 4 in the new array is wrong!');
  Check(IL[6] = 0, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Tree.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 6);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Tree.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  Tree.Free();
end;

procedure TTestBinaryTree.TestEnumerator;
var
  Tree  : TBinaryTree<Integer>;
  I, X  : Integer;
begin
  Tree := TBinaryTree<Integer>.Create(0);
  Tree.AddLeft(Tree.Root, 10);
  Tree.AddRight(Tree.Root, -12);
  Tree.AddLeft(Tree.Root.Left, -30);

  X := 0;

  for I in Tree do
  begin
    if X = 0 then
       Check(I = -30, 'Enumerator failed at 0!')
    else if X = 1 then
       Check(I = 10, 'Enumerator failed at 1!')
    else if X = 2 then
       Check(I = -12, 'Enumerator failed at 2!')
    else if X = 3 then
       Check(I = 0, 'Enumerator failed at 3!')
    else
       Fail('Enumerator failed!');
    Inc(X);
  end;

  { Test exceptions }

  CheckException(ECollectionChangedException,
    procedure()
    var
      I : Integer;
    begin
      for I in Tree do
      begin
        Tree.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Tree.Count = 3, 'Enumerator failed too late');

  Tree.Free;
end;

initialization
  TestFramework.RegisterTest(TTestBinaryTree.Suite);

end.

