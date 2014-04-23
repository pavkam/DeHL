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
unit Tests.Stack;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.LinkedList,
     DeHL.Arrays,
     DeHL.Collections.Stack;

type
 TTestStack = class(TDeHLTestCase)
 published
   procedure TestCreationAndDestroy();
   procedure TestCreateWithDynFixArrays();
   procedure TestPushPopPeek();
   procedure TestClearRemoveCount();
   procedure TestCopyTo();
   procedure TestIDynamic();
   procedure TestEnumerator();
   procedure TestExceptions();

   procedure TestObjectVariant();

   procedure TestCleanup();
 end;

implementation

{ TTestStack }

procedure TTestStack.TestCleanup;
var
  Stack : TStack<Integer>;
  ElemCache: Integer;
  I: Integer;
  LType: IType<Integer>;
begin
  ElemCache := 0;

  LType := TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end);

  { Create a new Stack }
  Stack := TStack<Integer>.Create(LType);

  { Add some elements }
  Stack.Push(1);
  Stack.Push(2);
  Stack.Push(4);
  Stack.Push(8);

  { Peek }
  Stack.Peek();

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  Stack.Pop();
  Stack.Pop();
  Stack.Contains(10);
  Stack.Shrink();
  Stack.Grow();

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  { Simply walk the Stack }
  for I in Stack do
    if I > 0 then;

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  Stack.Clear();
  Check(ElemCache = 3, 'Expected cache = 3');

  ElemCache := 0;

  Stack.Push(1);
  Stack.Push(2);
  Stack.Push(4);
  Stack.Push(8);

  Stack.Free;

  Check(ElemCache = 15, 'Expected cache = 15');
end;

procedure TTestStack.TestClearRemoveCount;
var
  Stack : TStack<Integer>;
begin
  Stack := TStack<Integer>.Create();

  { Check initialization }
  Stack.Push(1);
  Stack.Push(4);

  Check(Stack.Count = 2, 'Stack Count expected to be 2');
  Check(Stack.GetCount() = 2, 'Stack GetCount expected to be 2');
  Check(Stack.Peek() = 4, 'Stack Peek expected to be 4');

  Stack.Push(10);
  Stack.Push(40);

  Check(Stack.Count = 4, 'Stack Count expected to be 4');
  Check(Stack.GetCount() = 4, 'Stack GetCount expected to be 4');
  Check(Stack.Peek() = 40, 'Stack Peek expected to be 40');

  { Check removing }
  Stack.Remove(4);

  Check(Stack.Count = 3, 'Stack Count expected to be 3');
  Check(Stack.GetCount() = 3, 'Stack GetCount expected to be 3');

  Stack.Remove(40);

  Check(Stack.Count = 2, 'Stack Count expected to be 2');
  Check(Stack.GetCount() = 2, 'Stack GetCount expected to be 2');
  Check(Stack.Peek() = 10, 'Stack Peek expected to be 10');

  Stack.Remove(1);
  Stack.Remove(10);

  Check(Stack.Count = 0, 'Stack Count expected to be 0');
  Check(Stack.GetCount() = 0, 'Stack GetCount expected to be 0');

  Stack.Free();
end;

procedure TTestStack.TestCopyTo;
var
  Stack : TStack<Integer>;
  IL    : array of Integer;
begin
  Stack := TStack<Integer>.Create();

  { Add elements to the list }
  Stack.Push(1);
  Stack.Push(2);
  Stack.Push(3);
  Stack.Push(4);
  Stack.Push(5);

  { Check the copy }
  SetLength(IL, 5);
  Stack.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 2, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  Stack.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 2, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 5, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Stack.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Stack.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  Stack.Free();
end;

procedure TTestStack.TestCreateWithDynFixArrays;
var
  DA: TDynamicArray<Integer>;
  FA: TFixedArray<Integer>;

  DAL: TStack<Integer>;
  FAL: TStack<Integer>;
begin
  DA := TDynamicArray<Integer>.Create([5, 6, 2, 3, 1, 1]);
  FA := TFixedArray<Integer>.Create([5, 6, 2, 3, 1, 1]);

  DAL := TStack<Integer>.Create(DA);
  FAL := TStack<Integer>.Create(FA);

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

procedure TTestStack.TestCreationAndDestroy;
var
  Stack : TStack<Integer>;
  List  : TLinkedList<Integer>;
  IL    : array of Integer;
begin
  { With default capacity }
  Stack := TStack<Integer>.Create();

  Stack.Push(10);
  Stack.Push(20);
  Stack.Push(30);
  Stack.Push(40);

  Check(Stack.Count = 4, 'Stack count expected to be 4');

  Stack.Free();

  { With preset capacity }
  Stack := TStack<Integer>.Create(0);

  Stack.Push(10);
  Stack.Push(20);
  Stack.Push(30);
  Stack.Push(40);

  Check(Stack.Count = 4, 'Stack count expected to be 4');

  Stack.Free();

  { With Copy }
  List := TLinkedList<Integer>.Create();
  List.AddLast(1);
  List.AddLast(2);
  List.AddLast(3);
  List.AddLast(4);

  Stack := TStack<Integer>.Create(List);

  Check(Stack.Count = 4, 'Stack count expected to be 4');
  Check(Stack.Pop = 4, 'Stack Pop expected to be 4');
  Check(Stack.Pop = 3, 'Stack Pop expected to be 3');
  Check(Stack.Pop = 2, 'Stack Pop expected to be 2');
  Check(Stack.Pop = 1, 'Stack Pop expected to be 1');

  List.Free();
  Stack.Free();

  { Copy from array tests }
  SetLength(IL, 5);

  IL[0] := 1;
  IL[1] := 2;
  IL[2] := 3;
  IL[3] := 4;
  IL[4] := 5;

  Stack := TStack<Integer>.Create(IL);

  Check(Stack.Count = 5, 'Stack count expected to be 5');
  Check(Stack.Pop = 5, 'Stack Pop expected to be 5');
  Check(Stack.Pop = 4, 'Stack Pop expected to be 4');
  Check(Stack.Pop = 3, 'Stack Pop expected to be 3');
  Check(Stack.Pop = 2, 'Stack Pop expected to be 2');
  Check(Stack.Pop = 1, 'Stack Pop expected to be 1');

  Stack.Free;
end;

procedure TTestStack.TestEnumerator;
var
  Stack : TStack<Integer>;
  I, X  : Integer;
begin
  Stack := TStack<Integer>.Create();

  Stack.Push(10);
  Stack.Push(20);
  Stack.Push(30);

  X := 0;

  for I in Stack do
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
      for I in Stack do
      begin
        Stack.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Stack.Count = 2, 'Enumerator failed too late');

  Stack.Free();
end;

procedure TTestStack.TestExceptions;
var
  Stack   : TStack<Integer>;
  NullArg : IType<Integer>;
begin
  NullArg := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      Stack := TStack<Integer>.Create(NullArg);
      Stack.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Stack := TStack<Integer>.Create(NullArg, 10);
      Stack.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Stack := TStack<Integer>.Create(TType<Integer>.Default, nil);
      Stack.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  Stack := TStack<Integer>.Create();
  Stack.Push(1);
  Stack.Pop();

  CheckException(ECollectionEmptyException,
    procedure() begin Stack.Pop(); end,
    'ECollectionEmptyException not thrown in Pop.'
  );

  CheckException(ECollectionEmptyException,
    procedure() begin Stack.Peek(); end,
    'ECollectionEmptyException not thrown in Peek.'
  );

  Stack.Free();
end;

procedure TTestStack.TestIDynamic;
const
  NrElem = 1000;

var
  AStack: TStack<Integer>;
  I: Integer;
begin
  { With intitial capacity }
  AStack := TStack<Integer>.Create(100);

  AStack.Shrink();
  Check(AStack.Capacity = 0, 'Capacity expected to be 0');
  Check(AStack.GetCapacity() = AStack.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AStack.Grow();
  Check(AStack.Capacity > 0, 'Capacity expected to be > 0');
  Check(AStack.GetCapacity() = AStack.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AStack.Shrink();
  AStack.Push(10);
  AStack.Push(20);
  AStack.Push(30);
  Check(AStack.Capacity > AStack.Count, 'Capacity expected to be > Count');
  Check(AStack.GetCapacity() = AStack.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AStack.Shrink();
  Check(AStack.Capacity = AStack.Count, 'Capacity expected to be = Count');
  Check(AStack.GetCapacity() = AStack.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AStack.Grow();
  Check(AStack.Capacity > AStack.Count, 'Capacity expected to be > Count');
  Check(AStack.GetCapacity() = AStack.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AStack.Clear();
  AStack.Shrink();
  Check(AStack.Capacity = 0, 'Capacity expected to be = 0');
  Check(AStack.GetCapacity() = AStack.Capacity, 'GetCapacity() expected to be equal to Capacity');


  for I := 0 to NrElem - 1 do
    AStack.Push(I);

  for I := 0 to NrElem - 1 do
    AStack.Pop();

  Check(AStack.Capacity > NrElem, 'Capacity expected to be > NrElem');
  Check(AStack.GetCapacity() = AStack.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AStack.Free;
end;

procedure TTestStack.TestObjectVariant;
var
  ObjStack: TObjectStack<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjStack := TObjectStack<TTestObject>.Create();
  Check(not ObjStack.OwnsObjects, 'OwnsObjects must be false!');

  TheObject := TTestObject.Create(@ObjectDied);
  ObjStack.Push(TheObject);
  ObjStack.Clear;

  Check(not ObjectDied, 'The object should not have been cleaned up!');
  ObjStack.Push(TheObject);
  ObjStack.OwnsObjects := true;
  Check(ObjStack.OwnsObjects, 'OwnsObjects must be true!');

  ObjStack.Clear;

  Check(ObjectDied, 'The object should have been cleaned up!');
  ObjStack.Free;
end;

procedure TTestStack.TestPushPopPeek;
var
  Stack : TStack<Integer>;
begin
  Stack := TStack<Integer>.Create();

  { Check initialization }
  Stack.Push(1);
  Stack.Push(4);

  Check(Stack.Count = 2, 'Stack Count expected to be 2');
  Check(Stack.GetCount() = 2, 'Stack GetCount expected to be 2');
  Check(Stack.Peek() = 4, 'Stack Peek expected to be 4');

  Stack.Push(10);
  Stack.Push(40);

  Check(Stack.Count = 4, 'Stack Count expected to be 4');
  Check(Stack.GetCount() = 4, 'Stack GetCount expected to be 4');
  Check(Stack.Peek() = 40, 'Stack Peek expected to be 40');

  { Check removing }
  Stack.Pop();

  Check(Stack.Count = 3, 'Stack Count expected to be 3');
  Check(Stack.GetCount() = 3, 'Stack GetCount expected to be 3');

  Stack.Pop();

  Check(Stack.Count = 2, 'Stack Count expected to be 2');
  Check(Stack.GetCount() = 2, 'Stack GetCount expected to be 2');
  Check(Stack.Peek() = 4, 'Stack Peek expected to be 4');

  Stack.Pop();
  Stack.Pop();

  Check(Stack.Count = 0, 'Stack Count expected to be 0');
  Check(Stack.GetCount() = 0, 'Stack GetCount expected to be 0');

  Stack.Free();
end;

initialization
  TestFramework.RegisterTest(TTestStack.Suite);

end.
