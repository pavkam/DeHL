(*
* Copyright (c) 2009, Ciobanu Alexandru
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
unit Tests.LinkedQueue;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Collections.LinkedList,
     DeHL.Collections.LinkedQueue;

type
  TTestLinkedQueue = class(TDeHLTestCase)
  published
    procedure TestCreationAndDestroy();
    procedure TestCreateWithDynFixArrays();
    procedure TestEnqueueDequeuePeekClearCount();
    procedure TestCopyTo();
    procedure TestEnumerator();
    procedure TestExceptions();
    procedure TestBigCounts();

    procedure TestObjectVariant();

    procedure TestCleanup();
  end;

implementation

{ TTestLinkedQueue }

procedure TTestLinkedQueue.TestBigCounts;
const
  NrItems = 100000;
var
  Queue   : TLinkedQueue<Integer>;
  I, SumK : Integer;
begin
  Queue := TLinkedQueue<Integer>.Create();

  SumK := 0;

  for I := 0 to NrItems - 1 do
  begin
    Queue.Enqueue(I);
    SumK := SumK + I;
  end;

  while Queue.Count > 0 do
  begin
    SumK := SumK - Queue.Dequeue;
  end;

  Check(SumK = 0, 'Failed to dequeue all items in the queue!');

  Queue.Free;
end;

procedure TTestLinkedQueue.TestCleanup;
var
  Queue : TLinkedQueue<Integer>;
  ElemCache: Integer;
  I: Integer;
begin
  ElemCache := 0;

  { Create a new queue }
  Queue := TLinkedQueue<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end)
  );

  { Add some elements }
  Queue.Enqueue(1);
  Queue.Enqueue(2);
  Queue.Enqueue(4);
  Queue.Enqueue(8);

  { Peek }
  Queue.Peek();

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  Queue.Dequeue();
  Queue.Dequeue();
  Queue.Contains(10);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  { Simply walk the queue }
  for I in Queue do
    if I > 0 then;


  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  Queue.Clear();
  Check(ElemCache = 12, 'Expected cache = 12');

  ElemCache := 0;

  Queue.Enqueue(1);
  Queue.Enqueue(2);
  Queue.Enqueue(4);
  Queue.Enqueue(8);

  Queue.Free;

  Check(ElemCache = 15, 'Expected cache = 15');
end;

procedure TTestLinkedQueue.TestCopyTo;
var
  Queue : TLinkedQueue<Integer>;
  IL    : array of Integer;
begin
  Queue := TLinkedQueue<Integer>.Create();

  { Add elements to the list }
  Queue.Enqueue(1);
  Queue.Enqueue(2);
  Queue.Enqueue(3);
  Queue.Enqueue(4);
  Queue.Enqueue(5);

  { Check the copy }
  SetLength(IL, 5);
  Queue.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 2, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  Queue.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 2, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 5, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Queue.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Queue.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  Queue.Free();
end;

procedure TTestLinkedQueue.TestCreateWithDynFixArrays;
var
  DA: TDynamicArray<Integer>;
  FA: TFixedArray<Integer>;

  DAL: TLinkedQueue<Integer>;
  FAL: TLinkedQueue<Integer>;
begin
  DA := TDynamicArray<Integer>.Create([5, 6, 2, 3, 1, 1]);
  FA := TFixedArray<Integer>.Create([5, 6, 2, 3, 1, 1]);

  DAL := TLinkedQueue<Integer>.Create(DA);
  FAL := TLinkedQueue<Integer>.Create(FA);

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

procedure TTestLinkedQueue.TestCreationAndDestroy;
var
  Queue : TLinkedQueue<Integer>;
  List  : TLinkedList<Integer>;
  IL    : array of Integer;
begin
  { With default capacity }
  Queue := TLinkedQueue<Integer>.Create();

  Queue.Enqueue(10);
  Queue.Enqueue(20);
  Queue.Enqueue(30);
  Queue.Enqueue(40);

  Check(Queue.Count = 4, 'Queue count expected to be 4');

  Queue.Free();

  { With Copy }
  List := TLinkedList<Integer>.Create();
  List.AddLast(1);
  List.AddLast(2);
  List.AddLast(3);
  List.AddLast(4);

  Queue := TLinkedQueue<Integer>.Create(List);

  Check(Queue.Count = 4, 'Queue count expected to be 4');
  Check(Queue.Dequeue = 1, 'Queue Dequeue expected to be 1');
  Check(Queue.Dequeue = 2, 'Queue Dequeue expected to be 2');
  Check(Queue.Dequeue = 3, 'Queue Dequeue expected to be 3');
  Check(Queue.Dequeue = 4, 'Queue Dequeue expected to be 4');

  List.Free();
  Queue.Free();

  { Copy from array tests }
  SetLength(IL, 5);

  IL[0] := 1;
  IL[1] := 2;
  IL[2] := 3;
  IL[3] := 4;
  IL[4] := 5;

  Queue := TLinkedQueue<Integer>.Create(IL);
  Queue.Enqueue(6);

  Check(Queue.Count = 6, 'Queue count expected to be 6');
  Check(Queue.Dequeue = 1, 'Queue Dequeue expected to be 1');
  Check(Queue.Dequeue = 2, 'Queue Dequeue expected to be 2');
  Check(Queue.Dequeue = 3, 'Queue Dequeue expected to be 3');
  Check(Queue.Dequeue = 4, 'Queue Dequeue expected to be 4');
  Check(Queue.Dequeue = 5, 'Queue Dequeue expected to be 5');
  Check(Queue.Dequeue = 6, 'Queue Dequeue expected to be 6');

  Queue.Free;
end;

procedure TTestLinkedQueue.TestEnumerator;
var
  Queue : TLinkedQueue<Integer>;
  I, X  : Integer;
begin
  Queue := TLinkedQueue<Integer>.Create();

  Queue.Enqueue(10);
  Queue.Enqueue(20);
  Queue.Enqueue(30);

  X := 0;

  for I in Queue do
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
      for I in Queue do
      begin
        Queue.Contains(I);
        Queue.Dequeue();
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Queue.Count = 2, 'Enumerator failed too late');

  Queue.Free();
end;

procedure TTestLinkedQueue.TestExceptions;
var
  Queue   : TLinkedQueue<Integer>;
  NullArg : IType<Integer>;
begin
  NullArg := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      Queue := TLinkedQueue<Integer>.Create(NullArg);
      Queue.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Queue := TLinkedQueue<Integer>.Create(TType<Integer>.Default, nil);
      Queue.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  Queue := TLinkedQueue<Integer>.Create();
  Queue.Enqueue(1);
  Queue.Dequeue();

  CheckException(ECollectionEmptyException,
    procedure() begin Queue.Dequeue(); end,
    'ECollectionEmptyException not thrown in Dequeue.'
  );

  CheckException(ECollectionEmptyException,
    procedure() begin Queue.Peek(); end,
    'ECollectionEmptyException not thrown in Peek.'
  );

  Queue.Free();
end;

procedure TTestLinkedQueue.TestObjectVariant;
var
  ObjQueue: TObjectLinkedQueue<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjQueue := TObjectLinkedQueue<TTestObject>.Create();
  Check(not ObjQueue.OwnsObjects, 'OwnsObjects must be false!');

  TheObject := TTestObject.Create(@ObjectDied);
  ObjQueue.Enqueue(TheObject);
  ObjQueue.Clear;

  Check(not ObjectDied, 'The object should not have been cleaned up!');
  ObjQueue.Enqueue(TheObject);
  ObjQueue.OwnsObjects := true;
  Check(ObjQueue.OwnsObjects, 'OwnsObjects must be true!');

  ObjQueue.Clear;

  Check(ObjectDied, 'The object should have been cleaned up!');
  ObjQueue.Free;
end;

procedure TTestLinkedQueue.TestEnqueueDequeuePeekClearCount;
var
  Queue : TLinkedQueue<Integer>;
  I     : Integer;
begin
  Queue := TLinkedQueue<Integer>.Create();

  { Check initialization }
  Queue.Enqueue(1);
  Queue.Enqueue(4);

  Check(Queue.Count = 2, 'Queue Count expected to be 2');
  Check(Queue.GetCount() = 2, 'Queue GetCount expected to be 2');
  Check(Queue.Peek() = 1, 'Queue Peek expected to be 1');

  Queue.Enqueue(10);
  Queue.Enqueue(40);

  Check(Queue.Count = 4, 'Queue Count expected to be 4');
  Check(Queue.GetCount() = 4, 'Queue GetCount expected to be 4');
  Check(Queue.Peek() = 1, 'Queue Peek expected to be 1');

  { Check removing }
  Queue.Dequeue();

  Check(Queue.Count = 3, 'Queue Count expected to be 3');
  Check(Queue.GetCount() = 3, 'Queue GetCount expected to be 3');

  Queue.Dequeue();

  Check(Queue.Count = 2, 'Queue Count expected to be 2');
  Check(Queue.GetCount() = 2, 'Queue GetCount expected to be 2');
  Check(Queue.Peek() = 10, 'Queue Peek expected to be 10');

  Queue.Dequeue();
  Queue.Dequeue();

  Check(Queue.Count = 0, 'Queue Count expected to be 0');
  Check(Queue.GetCount() = 0, 'Queue GetCount expected to be 0');

  Queue.Enqueue(1);

  Check(Queue.Count = 1, 'Queue Count expected to be 1');
  Check(Queue.GetCount() = 1, 'Queue GetCount expected to be 1');

  Queue.Clear();

  Check(Queue.Count = 0, 'Queue Count expected to be 0');
  Check(Queue.GetCount() = 0, 'Queue GetCount expected to be 0');

  Queue.Free();

  Queue := TLinkedQueue<Integer>.Create();

  for I := 0 to 2048 do
      Queue.Enqueue(I);

  for I := 0 to 2048 do
      Check(Queue.Dequeue() = I, 'Dequeue failed for I=' + IntToStr(I) + '.');

  Queue.Free();
end;

initialization
  TestFramework.RegisterTest(TTestLinkedQueue.Suite);

end.
