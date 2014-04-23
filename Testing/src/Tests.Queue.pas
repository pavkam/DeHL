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
unit Tests.Queue;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Collections.LinkedList,
     DeHL.Collections.Queue;

type
 TTestQueue = class(TDeHLTestCase)
 published
   procedure TestCreationAndDestroy();
   procedure TestCreateWithDynFixArrays();
   procedure TestEnqueueDequeuePeekClearCount();
   procedure TestCopyTo();
   procedure TestIDynamic();
   procedure TestEnumerator();
   procedure TestExceptions();
   procedure TestBigCounts();
   procedure Test_Bug_1();

   procedure TestObjectVariant();

   procedure TestCleanup();
 end;

implementation

{ TTestQueue }

procedure TTestQueue.TestBigCounts;
const
  NrItems = 100000;
var
  Queue   : TQueue<Integer>;
  I, SumK : Integer;
begin
  Queue := TQueue<Integer>.Create();

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

procedure TTestQueue.Test_Bug_1;
const
  NrPts = 1223;
var
  Queue: TQueue<Integer>;
  I, Sum, Sum2: Integer;
begin
  Queue := TQueue<Integer>.Create();

  Sum := 0;

  for I := 0 to NrPts - 1 do
  begin
    Queue.Enqueue(I);
    Sum := Sum + I;
  end;

  Sum2 := 0;

  { Try to enumerate the queue }
  for I in Queue do
  begin
    Sum2 := Sum2 + I;
  end;

  Check(Sum = Sum2, 'Enumeration on Queue failed!');
  Queue.Free;
end;

procedure TTestQueue.TestCleanup;
var
  Queue : TQueue<Integer>;
  ElemCache: Integer;
  I: Integer;
begin
  ElemCache := 0;

  { Create a new queue }
  Queue := TQueue<Integer>.Create(
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
  Queue.Shrink();
  Queue.Grow();

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

procedure TTestQueue.TestCopyTo;
var
  Queue : TQueue<Integer>;
  IL    : array of Integer;
begin
  Queue := TQueue<Integer>.Create();

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

procedure TTestQueue.TestCreateWithDynFixArrays;
var
  DA: TDynamicArray<Integer>;
  FA: TFixedArray<Integer>;

  DAL: TQueue<Integer>;
  FAL: TQueue<Integer>;
begin
  DA := TDynamicArray<Integer>.Create([5, 6, 2, 3, 1, 1]);
  FA := TFixedArray<Integer>.Create([5, 6, 2, 3, 1, 1]);

  DAL := TQueue<Integer>.Create(DA);
  FAL := TQueue<Integer>.Create(FA);

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

procedure TTestQueue.TestCreationAndDestroy;
var
  Queue : TQueue<Integer>;
  List  : TLinkedList<Integer>;
  IL    : array of Integer;
begin
  { With default capacity }
  Queue := TQueue<Integer>.Create();

  Queue.Enqueue(10);
  Queue.Enqueue(20);
  Queue.Enqueue(30);
  Queue.Enqueue(40);

  Check(Queue.Count = 4, 'Queue count expected to be 4');

  Queue.Free();

  { With preset capacity }
  Queue := TQueue<Integer>.Create(0);

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

  Queue := TQueue<Integer>.Create(List);

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

  Queue := TQueue<Integer>.Create(IL);
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

procedure TTestQueue.TestEnumerator;
var
  Queue : TQueue<Integer>;
  I, X  : Integer;
begin
  Queue := TQueue<Integer>.Create();

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

procedure TTestQueue.TestExceptions;
var
  Queue   : TQueue<Integer>;
  NullArg : IType<Integer>;
begin
  NullArg := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      Queue := TQueue<Integer>.Create(NullArg);
      Queue.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Queue := TQueue<Integer>.Create(NullArg, 10);
      Queue.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Queue := TQueue<Integer>.Create(TType<Integer>.Default, nil);
      Queue.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  Queue := TQueue<Integer>.Create();
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

procedure TTestQueue.TestIDynamic;
const
  NrElem = 1000;

var
  AQueue: TQueue<Integer>;
  I: Integer;
begin
  { With intitial capacity }
  AQueue := TQueue<Integer>.Create(100);

  AQueue.Shrink();
  Check(AQueue.Capacity = 0, 'Capacity expected to be 0');
  Check(AQueue.GetCapacity() = AQueue.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AQueue.Grow();
  Check(AQueue.Capacity > 0, 'Capacity expected to be > 0');
  Check(AQueue.GetCapacity() = AQueue.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AQueue.Shrink();
  AQueue.Enqueue(10);
  AQueue.Enqueue(20);
  AQueue.Enqueue(30);
  Check(AQueue.Capacity > AQueue.Count, 'Capacity expected to be > Count');
  Check(AQueue.GetCapacity() = AQueue.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AQueue.Shrink();
  Check(AQueue.Capacity = AQueue.Count, 'Capacity expected to be = Count');
  Check(AQueue.GetCapacity() = AQueue.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AQueue.Grow();
  Check(AQueue.Capacity > AQueue.Count, 'Capacity expected to be > Count');
  Check(AQueue.GetCapacity() = AQueue.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AQueue.Clear();
  AQueue.Shrink();
  Check(AQueue.Capacity = 0, 'Capacity expected to be = 0');
  Check(AQueue.GetCapacity() = AQueue.Capacity, 'GetCapacity() expected to be equal to Capacity');

  for I := 0 to NrElem - 1 do
    AQueue.Enqueue(I);

  for I := 0 to NrElem - 1 do
    AQueue.Dequeue();

  Check(AQueue.Capacity > NrElem, 'Capacity expected to be > NrElem');
  Check(AQueue.GetCapacity() = AQueue.Capacity, 'GetCapacity() expected to be equal to Capacity');

  AQueue.Free;
end;

procedure TTestQueue.TestObjectVariant;
var
  ObjQueue: TObjectQueue<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjQueue := TObjectQueue<TTestObject>.Create();
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

procedure TTestQueue.TestEnqueueDequeuePeekClearCount;
var
  Queue : TQueue<Integer>;
  I     : Integer;
begin
  Queue := TQueue<Integer>.Create();

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

  Queue := TQueue<Integer>.Create();

  for I := 0 to 2048 do
      Queue.Enqueue(I);

  for I := 0 to 2048 do
      Check(Queue.Dequeue() = I, 'Dequeue failed for I=' + IntToStr(I) + '.');

  Queue.Free();
end;

initialization
  TestFramework.RegisterTest(TTestQueue.Suite);

end.
