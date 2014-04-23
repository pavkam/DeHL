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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.LinkedList;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Collections.LinkedList,
     DeHL.Collections.Base;

type
 TTestLinkedList = class(TDeHLTestCase)
 published
   procedure TestCreationAndDestroy();
   procedure TestCreateWithDynFixArrays();
   procedure TestAddAfter();
   procedure TestAddBefore();
   procedure TestAddFirst();
   procedure TestAddLast();
   procedure TestClear();
   procedure TestContains();
   procedure TestFind();
   procedure TestRemove();
   procedure TestRemoveFirst();
   procedure TestRemoveLast();
   procedure TestRemoveAndReturnFirst();
   procedure TestRemoveAndReturnLast();
   procedure TestInsertionOrder();
   procedure TestExceptions();
   procedure TestICollection();
   procedure TestEnumerator();

   procedure TestObjectVariant();

   procedure TestCleanup();
 end;

implementation

{ TTestLinkedList }

procedure TTestLinkedList.TestAddAfter;
var
 List : TLinkedList<String>;
begin
 { Initialize the list = 'First'}
 List := TLinkedList<String>.Create();
 List.AddFirst('First');

 { Add after with new node }
 List.AddAfter(List.FirstNode, TLinkedListNode<String>.Create('Second'));
 Check(List.LastNode.Value = 'Second', 'AddAfter(Node, Node) failed!');

 { Add after with value }
 List.AddAfter(List.FirstNode, 'Third');
 Check(List.FirstNode.Next.Value = 'Third', 'AddAfter(Node, Value) failed!');

 { Add after with ref = node, value }
 List.AddAfter('Second', 'Fourth');
 Check(List.LastNode.Value = 'Fourth', 'AddAfter(Value, Value) failed!');

 { Free }
 List.Free();
end;

procedure TTestLinkedList.TestAddBefore;
var
 List : TLinkedList<String>;
begin
 { Initialize the list = 'First'}
 List := TLinkedList<String>.Create();
 List.AddFirst('First');

 { Add after with new node }
 List.AddBefore(List.FirstNode, TLinkedListNode<String>.Create('Second'));
 Check(List.FirstNode.Value = 'Second', 'AddBefore(Node, Node) failed!');

 { Add after with value }
 List.AddBefore(List.LastNode, 'Third');
 Check(List.LastNode.Previous.Value = 'Third', 'AddBefore(Node, Value) failed!');

 { Add after with ref = node, value }
 List.AddBefore('Second', 'Fourth');
 Check(List.FirstNode.Value = 'Fourth', 'AddBefore(Value, Value) failed!');

 { Free }
 List.Free();
end;

procedure TTestLinkedList.TestAddFirst;
var
 List : TLinkedList<Double>;
 d1   : Double;
 d2   : Double;
 d3   : Double;

begin
 { Initialize the list }
 List := TLinkedList<Double>.Create();

 d1 := 1.1;
 d2 := 2;
 d3 := -45.6;

 List.AddFirst(d1);

 Check(List.FirstNode.Value = d1, 'AddFirst(Value) failed!');
 Check(List.FirstNode.Next = nil, 'AddFirst(Value) failed! (nil not preserved)');

 List.AddFirst(d2);
 Check(List.FirstNode.Value = d2, 'AddFirst(Value) failed!');
 Check(List.LastNode.Value = d1, 'AddFirst(Value) failed! (not moved further)');
 Check(List.LastNode.Next = nil, 'AddFirst(Value) failed! (nil not preserved)');

 List.AddFirst(TLinkedListNode<Double>.Create(d3));
 Check(List.FirstNode.Value = d3, 'AddFirst(Node) failed!');
 Check(List.LastNode.Previous = List.FirstNode.Next, 'AddFirst(Node) failed! (not moved further)');
 Check(List.LastNode.Value = d1, 'AddFirst(Node) failed! (not moved further)');
 Check(List.LastNode.Next = nil, 'AddFirst(Node) failed! (nil not preserved)');

 { Free }
 List.Free();
end;

procedure TTestLinkedList.TestAddLast;
var
 List : TLinkedList<Double>;
 d1   : Double;
 d2   : Double;
 d3   : Double;
begin
 { Initialize the list }
 List := TLinkedList<Double>.Create();

 d1 := 1.1;
 d2 := 2;
 d3 := -45.6;

 List.AddLast(d1);
 Check(List.FirstNode.Value = d1, 'AddLast(Value) failed!');
 Check(List.FirstNode.Next = nil, 'AddLast(Value) failed! (nil not preserved)');

 List.AddLast(d2);
 Check(List.FirstNode.Value = d1, 'AddLast(Value) failed!');
 Check(List.LastNode.Value = d2, 'AddLast(Value) failed! (not moved further)');
 Check(List.LastNode.Next = nil, 'AddLast(Value) failed! (nil not preserved)');

 List.AddLast(TLinkedListNode<Double>.Create(d3));
 Check(List.FirstNode.Value = d1, 'AddLast(Node) failed!');
 Check(List.LastNode.Value = d3, 'AddLast(Node) failed! (not moved further)');
 Check(List.LastNode.Next = nil, 'AddLast(Node) failed! (nil not preserved)');

 { Free }
 List.Free();
end;

procedure TTestLinkedList.TestCleanup;
var
  AList : TLinkedList<Integer>;
  ElemCache: Integer;
  I: Integer;
begin
  ElemCache := 0;

  { Create a new AList }
  AList := TLinkedList<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end)
  );

  { Add some elements }
  AList.AddLast(1);
  AList.AddLast(2);
  AList.AddLast(4);
  AList.AddLast(8);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  AList.Remove(8);
  AList.Remove(4);
  AList.Contains(10);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  AList.RemoveAndReturnLast();
  AList.RemoveAndReturnFirst();

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  AList.AddFirst(1);
  AList.AddLast(2);

  { Simply walk the AList }
  for I in AList do
    if I > 0 then;

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  { Add back }
  AList.AddLast(4);
  AList.AddLast(8);

  AList.RemoveFirst;
  AList.RemoveLast;

  Check(ElemCache = 9, 'Expected cache = 9');
  ElemCache := 0;

  AList.Clear();
  Check(ElemCache = 6, 'Expected cache = 6');

  AList.AddLast(1);
  AList.AddLast(2);
  AList.AddLast(4);
  AList.AddLast(8);

  { Remove using other methods }
  ElemCache := 0;
  AList.FirstNode.Free();
  Check(ElemCache = 1, 'Expected cache = 1');

  ElemCache := 0;
  AList.Free;

  Check(ElemCache = 14, 'Expected cache = 14');
end;

procedure TTestLinkedList.TestClear;
var
 List : TLinkedList<String>;
begin
 { Initialize the list = 'First'}
 List := TLinkedList<String>.Create();
 List.AddFirst('First');
 List.AddLast('Second');
 List.AddLast('Third');

 Check(List.Count = 3, 'Count is incorrect!');

 List.Clear();
 Check(List.Count = 0, 'Count is incorrect!');

 Check(List.FirstNode = nil, 'First element must be nil.');
 Check(List.LastNode = nil, 'Last element must be nil.');

 List.Free();
end;

procedure TTestLinkedList.TestContains;
var
 List : TLinkedList<String>;
begin
 { Initialize the list = 'First'}
 List := TLinkedList<String>.Create(TStringType.Unicode(True));
 List.AddFirst('First');
 List.AddLast('Second');
 List.AddLast('Third');

 Check(List.Contains('FIRST'), 'Did not find "FIRST" in the list (Insensitive)');
 Check(List.Contains('tHIRD'), 'Did not find "tHIRD" in the list (Insensitive)');
 Check(List.Contains('sEcOnD'), 'Did not find "sEcOnD" in the list (Insensitive)');
 Check((not List.Contains('Yuppy')), 'Did find "Yuppy" in the list (Insensitive)');

 List.Free();
end;

procedure TTestLinkedList.TestCreateWithDynFixArrays;
var
  DA: TDynamicArray<Integer>;
  FA: TFixedArray<Integer>;

  DAL: TLinkedList<Integer>;
  FAL: TLinkedList<Integer>;
begin
  DA := TDynamicArray<Integer>.Create([5, 6, 2, 3, 1, 1]);
  FA := TFixedArray<Integer>.Create([5, 6, 2, 3, 1, 1]);

  DAL := TLinkedList<Integer>.Create(DA);
  FAL := TLinkedList<Integer>.Create(FA);

  Check(DAL.Count = 6, 'Expected DAL.Length to be 6');
  Check(DAL.Contains(5), 'Expected DAL to contain 5');
  Check(DAL.Contains(6), 'Expected DAL to contain 6');
  Check(DAL.Contains(2), 'Expected DAL to contain 2');
  Check(DAL.Contains(3), 'Expected DAL to contain 3');
  Check(DAL.Contains(1), 'Expected DAL to contain 1');

  Check(FAL.Count = 6, 'Expected FAL.Length to be 6');
  Check(FAL.Contains(5), 'Expected FAL to contain 5');
  Check(FAL.Contains(6), 'Expected FAL to contain 6');
  Check(FAL.Contains(2), 'Expected FAL to contain 2');
  Check(FAL.Contains(3), 'Expected FAL to contain 3');
  Check(FAL.Contains(1), 'Expected FAL to contain 1');

  DAL.Free;
  FAL.Free;
end;

procedure TTestLinkedList.TestCreationAndDestroy;
var
 List, CopyList : TLinkedList<Integer>;
 IL             : array of Integer;
begin
 { Initialize the list }
 List := TLinkedList<Integer>.Create();
 List.AddFirst(1);
 List.AddFirst(2);
 List.AddFirst(3);
 List.AddFirst(4);
 List.AddFirst(5);
 { Expected result = 5 4 3 2 1 }

 Check(List.Count = 5, 'Count must be 5 elements!');

 Check(List.FirstNode.Value = 5, 'Expected 5 but got another value!');
 Check(List.FirstNode.Next.Value = 4, 'Expected 4 but got another value!');
 Check(List.FirstNode.Next.Next.Value = 3, 'Expected 3 but got another value!');
 Check(List.LastNode.Previous.Value = 2, 'Expected 2 but got another value!');
 Check(List.LastNode.Value = 1, 'Expected 1 but got another value!');

 { Free the first element = 4 3 2 1 }
 List.FirstNode.Free();

 Check(List.Count = 4, 'Count must be 4 elements!');
 Check(List.FirstNode.Value = 4, 'Expected 4 but got another value!');
 Check(List.FirstNode.Next.Value = 3, 'Expected 3 but got another value!');
 Check(List.FirstNode.Next.Next.Value = 2, 'Expected 2 but got another value!');
 Check(List.LastNode.Value = 1, 'Expected 1 but got another value!');

 { Free the second element = 4 2 1 }
 List.FirstNode.Next.Free();

 Check(List.Count = 3, 'Count must be 3 elements!');
 Check(List.FirstNode.Value = 4, 'Expected 4 but got another value!');
 Check(List.FirstNode.Next.Value = 2, 'Expected 2 but got another value!');
 Check(List.LastNode.Value = 1, 'Expected 1 but got another value!');

 { Test the copy}
 CopyList := TLinkedList<Integer>.Create(List);

 Check(CopyList.Count = 3, '(Copy) Count must be 3 elements!');
 Check(CopyList.FirstNode.Value = 4, '(Copy) Expected 4 but got another value!');
 Check(CopyList.FirstNode.Next.Value = 2, '(Copy) Expected 2 but got another value!');
 Check(CopyList.LastNode.Value = 1, '(Copy) Expected 1 but got another value!');

 { Free the list }
 List.Free;
 CopyList.Free;

 { Test array copy }
 SetLength(IL, 5);
 IL[0] := -1;
 IL[1] := -2;
 IL[2] := -3;
 IL[3] := -4;
 IL[4] := -5;

 CopyList := TLinkedList<Integer>.Create(IL);

 Check(CopyList.Count = 5, '(Copy From Array) Count must be 5 elements!');
 Check(CopyList.FirstNode.Value = -1, '(Copy From Array) Expected -1 but got another value!');
 Check(CopyList.FirstNode.Next.Value = -2, '(Copy From Array) Expected -2 but got another value!');
 Check(CopyList.FirstNode.Next.Next.Value = -3, '(Copy From Array) Expected -3 but got another value!');
 Check(CopyList.FirstNode.Next.Next.Next.Value = -4, '(Copy From Array) Expected -4 but got another value!');
 Check(CopyList.FirstNode.Next.Next.Next.Next.Value = -5, '(Copy From Array) Expected -5 but got another value!');

 CopyList.Free;
end;

procedure TTestLinkedList.TestEnumerator;
var
  List1 : TLinkedList<Integer>;
  I, X  : Integer;
begin
  List1 := TLinkedList<Integer>.Create();

  List1.AddLast(10);
  List1.AddLast(20);
  List1.AddLast(30);

  X := 0;

  for I in List1 do
  begin
    if X = 0 then
       Check(I = 10, 'Enumerator failed at 0!')
    else if X = 1 then
       Check(I = 20, 'Enumerator failed at 1!')
    else if X = 2 then
       Check(I = 30, 'Enumerator failed at 2!')
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
      for I in List1 do
      begin
        List1.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(List1.Count = 2, 'Enumerator failed too late');

  List1.Free;
end;

procedure TTestLinkedList.TestExceptions;
var
  List1, List2, ListX : TLinkedList<Integer>;
  NullArg : IType<Integer>;
begin
  NullArg := nil;

  List1 := TLinkedList<Integer>.Create();
  List2 := TLinkedList<Integer>.Create();

  List1.AddLast(1);
  List2.AddLast(1);

  List1.AddLast(2);
  List2.AddLast(2);

  CheckException(ENilArgumentException,
    procedure()
    begin
      ListX := TLinkedList<Integer>.Create(NullArg);
      ListX.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      ListX := TLinkedList<Integer>.Create(TType<Integer>.Default, nil);
      ListX.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enumerable).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddLast(List2.LastNode); end,
    'EElementAlreadyInACollection not thrown in AddLast (cross-link).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddFirst(List2.LastNode); end,
    'EElementAlreadyInACollection not thrown in AddFirst (cross-link).'
  );

  CheckException(EElementNotPartOfCollection,
    procedure() begin List1.AddAfter(List2.LastNode, 1); end,
    'EElementNotPartOfCollection not thrown in AddFirst (cross-link).'
  );

  CheckException(EElementNotPartOfCollection,
    procedure() begin List1.AddBefore(List2.LastNode, 1); end,
    'EElementNotPartOfCollection not thrown in AddBefore (cross-link).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddLast(List1.LastNode); end,
    'EElementAlreadyInACollection not thrown in AddLast (self-link).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddFirst(List1.LastNode); end,
    'EElementAlreadyInACollection not thrown in AddFirst (self-link).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddBefore(List1.FirstNode, List1.LastNode); end,
    'EElementAlreadyInACollection not thrown in AddBefore (self-link).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddAfter(List1.FirstNode, List1.LastNode); end,
    'EElementAlreadyInACollection not thrown in AddAfter (self-link).'
  );

  CheckException(ENilArgumentException,
    procedure() begin List1.AddAfter(nil, 5); end,
    'ENilArgumentException not thrown in AddAfter (nil ref).'
  );

  CheckException(ENilArgumentException,
    procedure() begin List1.AddAfter(List1.FirstNode, nil); end,
    'ENilArgumentException not thrown in AddAfter (nil val).'
  );

  CheckException(ENilArgumentException,
    procedure() begin List1.AddBefore(nil, 5); end,
    'ENilArgumentException not thrown in AddBefore (nil ref).'
  );

  CheckException(ENilArgumentException,
    procedure() begin List1.AddBefore(List1.FirstNode, nil); end,
    'ENilArgumentException not thrown in AddBefore (nil val).'
  );

  CheckException(ENilArgumentException,
    procedure() begin List1.AddFirst(nil); end,
    'ENilArgumentException not thrown in AddFirst (nil val).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddFirst(List1.FirstNode); end,
    'EElementAlreadyInACollection not thrown in AddAfter (cross-link).'
  );

  CheckException(ENilArgumentException,
    procedure() begin List1.AddLast(nil); end,
    'ENilArgumentException not thrown in AddLast (nil val).'
  );

  CheckException(EElementAlreadyInACollection,
    procedure() begin List1.AddLast(List1.FirstNode); end,
    'EElementAlreadyInACollection not thrown in AddLast (cross-link).'
  );


  ListX := TLinkedList<Integer>.Create();

  CheckException(ECollectionEmptyException,
    procedure() begin ListX.RemoveAndReturnFirst() end,
    'ECollectionEmptyException not thrown in RemoveAndReturnFirst.'
  );

  CheckException(ECollectionEmptyException,
    procedure() begin ListX.RemoveAndReturnLast() end,
    'ECollectionEmptyException not thrown in RemoveAndReturnLast.'
  );

  List1.Free();
  List2.Free();
  ListX.Free();
end;

procedure TTestLinkedList.TestFind;
var
 List : TLinkedList<String>;
begin
 { Initialize the list = 'First'}
 List := TLinkedList<String>.Create(TStringType.Unicode(True));
 List.AddFirst('First');
 List.AddLast('Second');
 List.AddLast('Third');
 List.AddLast('ThIrd');

 { Normal find }
 Check(List.Find('FIRST') <> nil, 'Did not find "FIRST" in the list (Insensitive)');
 Check(List.Find('FIRST').Value = 'First', 'Found node is not the one searched for ("FIRST") in the list (Insensitive)');

 Check(List.Find('tHIRD') <> nil, 'Did not find "tHIRD" in the list (Insensitive)');
 Check(List.Find('tHIRD').Value = 'Third', 'Found node is not the one searched for ("tHIRD") in the list (Insensitive)');

 Check(List.Find('sEcOnD') <> nil, 'Did not find "sEcOnD" in the list (Insensitive)');
 Check(List.Find('sEcOnD').Value = 'Second', 'Found node is not the one searched for ("sEcOnD") in the list (Insensitive)');

 { Last find }
 Check(List.FindLast('FIRST') <> nil, 'Did not find "FIRST" in the list (Insensitive)');
 Check(List.FindLast('FIRST').Value = 'First', 'Found node is not the one searched for ("FIRST") in the list (Insensitive)');

 Check(List.FindLast('tHIRD') <> nil, 'Did not find "tHIRD" in the list (Insensitive)');
 Check(List.FindLast('tHIRD').Value = 'ThIrd', 'Found node is not the one searched for ("tHIRD") in the list (Insensitive)');

 Check(List.FindLast('sEcOnD') <> nil, 'Did not find "sEcOnD" in the list (Insensitive)');
 Check(List.FindLast('sEcOnD').Value = 'Second', 'Found node is not the one searched for ("sEcOnD") in the list (Insensitive)');

 { Last checks }
 Check(List.Find('Third') <> List.FindLast('Third'), 'Find and FindLast must not return the same value (Insensitive)');
 Check(List.Find('Lom') = nil, 'Found "Lom" when it''s not contained there! (Insensitive)');

 List.Free();
end;

procedure TTestLinkedList.TestICollection;
var
  List : TLinkedList<Integer>;
  IL   : array of Integer;
begin
  List := TLinkedList<Integer>.Create();

  { Add elements to the list }
  List.AddFirst(1);
  List.AddLast(2);
  List.AddLast(3);
  List.AddLast(4);
  List.AddLast(5);

  { Test Count }
  Check(List.GetCount = 5, 'CountOfElements must be 5!');

  List.Remove(2);
  List.Remove(-9);
  Check(List.GetCount = 4, 'CountOfElements must be 4!');

  List.AddLast(10);
  List.AddLast(11);
  Check(List.GetCount = 6, 'CountOfElements must be 6!');

  { Check the copy }
  SetLength(IL, 6);
  List.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 3, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 4, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 5, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 10, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 11, 'Element 5 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 7);
  List.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 10, 'Element 5 in the new array is wrong!');
  Check(IL[6] = 11, 'Element 6 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin List.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 6);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin List.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  List.Free();
end;

procedure TTestLinkedList.TestInsertionOrder;
var
 List : TLinkedList<Integer>;
begin
 List := TLinkedList<Integer>.Create();

 List.AddFirst(1);
 List.AddLast(2);
 List.AddLast(3);
 List.AddLast(4);
 List.AddLast(5);
 List.AddFirst(6);
 List.AddAfter(4, 7);
 List.AddBefore(3, 8);

 { Result = 6 1 2 8 3 4 7 5 }
 Check(List.FirstNode.Value = 6, '(List Order) Expected 6!');
 Check(List.FirstNode.Next.Value = 1, '(List Order) Expected 1!');
 Check(List.FirstNode.Next.Next.Value = 2, '(List Order) Expected 2!');
 Check(List.FirstNode.Next.Next.Next.Value = 8, '(List Order) Expected 8!');
 Check(List.FirstNode.Next.Next.Next.Next.Value = 3, '(List Order) Expected 3!');
 Check(List.LastNode.Value = 5, '(List Order) Expected 5!');
 Check(List.LastNode.Previous.Value = 7, '(List Order) Expected 7!');
 Check(List.LastNode.Previous.Previous.Value = 4, '(List Order) Expected 4!');

 { Remove a few elements and then check }
 List.RemoveFirst();
 List.RemoveLast();
 List.Remove(3);
 List.Remove(4);

 { Result = 1 2 8 7 }
 Check(List.FirstNode.Value = 1, '(List Order) Expected 1!');
 Check(List.FirstNode.Next.Value = 2, '(List Order) Expected 2!');
 Check(List.FirstNode.Next.Next.Value = 8, '(List Order) Expected 8!');
 Check(List.FirstNode.Next.Next.Next.Value = 7, '(List Order) Expected 7!');

 Check(List.LastNode.Value = 7, '(List Order) Expected 7!');
 Check(List.LastNode.Previous.Value = 8, '(List Order) Expected 8!');
 Check(List.LastNode.Previous.Previous.Value = 2, '(List Order) Expected 2!');
 Check(List.LastNode.Previous.Previous.Previous.Value = 1, '(List Order) Expected 1!');

 List.FirstNode.Next.Free();

 { Result = 1 8 7 }
 Check(List.FirstNode.Value = 1, '(List Order) Expected 1!');
 Check(List.FirstNode.Next.Value = 8, '(List Order) Expected 8!');
 Check(List.FirstNode.Next.Next.Value = 7, '(List Order) Expected 7!');

 Check(List.LastNode.Value = 7, '(List Order) Expected 7!');
 Check(List.LastNode.Previous.Value = 8, '(List Order) Expected 8!');
 Check(List.LastNode.Previous.Previous.Value = 1, '(List Order) Expected 1!');

 List.Free();
end;

procedure TTestLinkedList.TestObjectVariant;
var
  ObjList: TObjectLinkedList<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjList := TObjectLinkedList<TTestObject>.Create();
  Check(not ObjList.OwnsObjects, 'OwnsObjects must be false!');

  TheObject := TTestObject.Create(@ObjectDied);
  ObjList.AddLast(TheObject);
  ObjList.Clear;

  Check(not ObjectDied, 'The object should not have been cleaned up!');
  ObjList.AddLast(TheObject);
  ObjList.OwnsObjects := true;
  Check(ObjList.OwnsObjects, 'OwnsObjects must be true!');

  ObjList.Clear;

  Check(ObjectDied, 'The object should have been cleaned up!');
  ObjList.Free;
end;

procedure TTestLinkedList.TestRemove;
var
 List : TLinkedList<Double>;
begin
 { Initialize the list }
 List := TLinkedList<Double>.Create();

 List.AddLast(1);
 List.AddLast(2);
 List.AddLast(3);
 List.AddLast(4);

 List.Remove(3);
 Check(List.Count = 3, 'List count must be 3');
 Check(List.LastNode.Previous.Value = 2, 'Elements did not link properly!');

 List.Remove(List.Find(1).Value);
 Check(List.Count = 2, 'List count must be 2');
 Check(List.FirstNode.Value = 2, 'Elements did not link properly!');
 Check(List.LastNode.Value = 4, 'Elements did not link properly!');

 { Free }
 List.Free();
end;

procedure TTestLinkedList.TestRemoveAndReturnFirst;
var
  List : TLinkedList<String>;
  S: String;
begin
  { Initialize the list }
  List := TLinkedList<String>.Create(TStringType.Unicode(True));

  List.AddLast('One');
  List.AddLast('Two');
  List.AddLast('Three');
  List.AddLast('Four');

  S := List.RemoveAndReturnFirst();
  Check(List.Count = 3, 'List count must be 3');
  Check(S = 'One', 'Removed the wrong element!');
  Check(List.FirstNode.Value = 'Two', 'Removed the wrong element!');

  S := List.RemoveAndReturnFirst();
  Check(List.Count = 2, 'List count must be 2');
  Check(S = 'Two', 'Removed the wrong element!');
  Check(List.FirstNode.Value = 'Three', 'Removed the wrong element!');

  { Free }
  List.Free();
end;

procedure TTestLinkedList.TestRemoveAndReturnLast;
var
  List : TLinkedList<String>;
  S: String;
begin
  { Initialize the list }
  List := TLinkedList<String>.Create(TStringType.Unicode(True));

  List.AddLast('One');
  List.AddLast('Two');
  List.AddLast('Three');
  List.AddLast('Four');

  S := List.RemoveAndReturnLast();
  Check(List.Count = 3, 'List count must be 3');
  Check(S = 'Four', 'Removed the wrong element!');
  Check(List.LastNode.Value = 'Three', 'Removed the wrong element!');

  S := List.RemoveAndReturnLast();
  Check(List.Count = 2, 'List count must be 2');
  Check(S = 'Three', 'Removed the wrong element!');
  Check(List.LastNode.Value = 'Two', 'Removed the wrong element!');

  { Free }
  List.Free();
end;

procedure TTestLinkedList.TestRemoveFirst;
var
 List : TLinkedList<String>;
begin
 { Initialize the list }
 List := TLinkedList<String>.Create(TStringType.Unicode(True));

 List.AddLast('One');
 List.AddLast('Two');
 List.AddLast('Three');
 List.AddLast('Four');

 List.RemoveFirst();
 Check(List.Count = 3, 'List count must be 3');
 Check(List.FirstNode.Value = 'Two', 'Removed the wrong element!');

 List.RemoveFirst();
 Check(List.Count = 2, 'List count must be 2');
 Check(List.FirstNode.Value = 'Three', 'Removed the wrong element!');

 { Free }
 List.Free();
end;

procedure TTestLinkedList.TestRemoveLast;
var
 List : TLinkedList<String>;
begin
 { Initialize the list }
 List := TLinkedList<String>.Create(TStringType.Unicode(True));

 List.AddLast('One');
 List.AddLast('Two');
 List.AddLast('Three');
 List.AddLast('Four');

 List.RemoveLast();
 Check(List.Count = 3, 'List count must be 3');
 Check(List.LastNode.Value = 'Three', 'Removed the wrong element!');

 List.RemoveLast();
 Check(List.Count = 2, 'List count must be 2');
 Check(List.LastNode.Value = 'Two', 'Removed the wrong element!');

 { Free }
 List.Free();
end;

initialization
  TestFramework.RegisterTest(TTestLinkedList.Suite);

end.
