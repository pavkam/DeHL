(*
* Copyright (c) 2008-2009, Susnea Andrei
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
unit Tests.ArraySet;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Collections.Stack,
     DeHL.Collections.ArraySet;

type
 TTestArraySet = class(TDeHLTestCase)
 published
   procedure TestCreationAndDestroy();
   procedure TestCreateWithDynFixArrays();
   procedure TestCountClearAdd();
   procedure TestContains();
   procedure TestCopyTo();
   procedure TestIDynamic();
   procedure TestEnumerator();
   procedure TestExceptions();

   procedure TestObjectVariant();

   procedure TestCleanup();
 end;

implementation

{ TTestArraySet }

procedure TTestArraySet.TestCountClearAdd;
var
  ArraySet  : TArraySet<String>;
  Stack : TStack<String>;
begin
  ArraySet := TArraySet<String>.Create(0);
  Stack := TStack<String>.Create();

  Stack.Push('s1');
  Stack.Push('s2');
  Stack.Push('s3');

  ArraySet.Add('1');
  ArraySet.Add('2');
  ArraySet.Add('3');

  Check((ArraySet.Count = 3) and (ArraySet.Count = ArraySet.GetCount()), 'ArraySet count expected to be 3');

  { 1 2 3 }
  ArraySet.Add('0');

  { 1 2 3 0 }
  ArraySet.Add('-1');

  { 1 2 3 0 -1 }
  ArraySet.Add('5');

  Check((ArraySet.Count = 6) and (ArraySet.Count = ArraySet.GetCount()), 'ArraySet count expected to be 6');


  ArraySet.Remove('1');

  Check((ArraySet.Count = 5) and (ArraySet.Count = ArraySet.GetCount()), 'ArraySet count expected to be 5');

  ArraySet.Remove('5');
  ArraySet.Remove('3');
  ArraySet.Remove('2');
  ArraySet.Remove('-1');
  ArraySet.Remove('0');

  Check((ArraySet.Count = 0) and (ArraySet.Count = ArraySet.GetCount()), 'ArraySet count expected to be 0');

  ArraySet.Free;
  Stack.Free;

end;

procedure TTestArraySet.TestCopyTo;
var
  ArraySet  : TArraySet<Integer>;
  IL    : array of Integer;
begin
  ArraySet := TArraySet<Integer>.Create();

  { Add elements to the ArraySet }
  ArraySet.Add(1);
  ArraySet.Add(2);
  ArraySet.Add(3);
  ArraySet.Add(4);
  ArraySet.Add(5);

  { Check the copy }
  SetLength(IL, 5);
  ArraySet.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 2, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  ArraySet.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 2, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 5, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin ArraySet.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin ArraySet.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  ArraySet.Free();
end;

procedure TTestArraySet.TestCleanup;
var
  ASet : TArraySet<Integer>;
  ElemCache: Integer;
  I: Integer;
begin
  ElemCache := 0;

  { Create a new ASet }
  ASet := TArraySet<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end)
  );

  { Add some elements }
  ASet.Add(1);
  ASet.Add(2);
  ASet.Add(4);
  ASet.Add(8);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  ASet.Remove(1);
  ASet.Remove(2);
  ASet.Contains(10);
  ASet.Shrink();
  ASet.Grow();

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  { Simply walk the ASet }
  for I in ASet do
    if I > 0 then;

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  ASet.Clear();
  Check(ElemCache = 12, 'Expected cache = 12');

  ElemCache := 0;

  ASet.Add(1);
  ASet.Add(2);
  ASet.Add(4);
  ASet.Add(8);

  ASet.Free;

  Check(ElemCache = 15, 'Expected cache = 15');
end;

procedure TTestArraySet.TestContains;
var
  ArraySet  : TArraySet<Integer>;
begin
  ArraySet := TArraySet<Integer>.Create();

  ArraySet.Add(1);
  ArraySet.Add(2);
  ArraySet.Add(3);
  ArraySet.Add(4);   {-}
  ArraySet.Add(5);
  ArraySet.Add(6);
  ArraySet.Add(4);   {-}
  ArraySet.Add(7);
  ArraySet.Add(8);
  ArraySet.Add(9);

  Check(ArraySet.Contains(1), 'Set expected to contain 1');
  Check(ArraySet.Contains(2), 'Set expected to contain 2');
  Check(ArraySet.Contains(3), 'Set expected to contain 3');
  Check(ArraySet.Contains(4), 'Set expected to contain 4');
  Check(not ArraySet.Contains(10), 'Set not expected to contain 10');

  ArraySet.Free();
end;

procedure TTestArraySet.TestCreateWithDynFixArrays;
var
  DA: TDynamicArray<Integer>;
  FA: TFixedArray<Integer>;

  DAL: TArraySet<Integer>;
  FAL: TArraySet<Integer>;
begin
  DA := TDynamicArray<Integer>.Create([5, 6, 2, 3, 1, 1]);
  FA := TFixedArray<Integer>.Create([5, 6, 2, 3, 1, 1]);

  DAL := TArraySet<Integer>.Create(DA);
  FAL := TArraySet<Integer>.Create(FA);

  Check(DAL.Count = 5, 'Expected DAL.Length to be 5');
  Check(DAL.Contains(5), 'Expected DAL to contain 5');
  Check(DAL.Contains(6), 'Expected DAL to contain 6');
  Check(DAL.Contains(2), 'Expected DAL to contain 2');
  Check(DAL.Contains(3), 'Expected DAL to contain 3');
  Check(DAL.Contains(1), 'Expected DAL to contain 1');

  Check(FAL.Count = 5, 'Expected FAL.Length to be 5');
  Check(FAL.Contains(5), 'Expected FAL to contain 5');
  Check(FAL.Contains(6), 'Expected FAL to contain 6');
  Check(FAL.Contains(2), 'Expected FAL to contain 2');
  Check(FAL.Contains(3), 'Expected FAL to contain 3');
  Check(FAL.Contains(1), 'Expected FAL to contain 1');

  DAL.Free;
  FAL.Free;
end;

procedure TTestArraySet.TestCreationAndDestroy;
var
  ArraySet : TArraySet<Integer>;
  Stack : TStack<Integer>;
  IL    : array of Integer;
begin
  { With default capacity }
  ArraySet := TArraySet<Integer>.Create();

  ArraySet.Add(10);
  ArraySet.Add(20);
  ArraySet.Add(30);
  ArraySet.Add(40);

  Check(ArraySet.Count = 4, 'ArraySet count expected to be 4');

  ArraySet.Free();

  { With preset capacity }
  ArraySet := TArraySet<Integer>.Create(0);

  ArraySet.Add(10);
  ArraySet.Add(20);
  ArraySet.Add(30);
  ArraySet.Add(40);

  Check(ArraySet.Count = 4, 'ArraySet count expected to be 4');

  ArraySet.Free();

  { With Copy }
  Stack := TStack<Integer>.Create();
  Stack.Push(1);
  Stack.Push(2);
  Stack.Push(3);
  Stack.Push(4);

  ArraySet := TArraySet<Integer>.Create(Stack);

  Check(ArraySet.Count = 4, 'ArraySet count expected to be 4');
  Check(ArraySet.Contains(1), 'ArraySet[1] expected to exist');
  Check(ArraySet.Contains(2), 'ArraySet[2] expected to exist');
  Check(ArraySet.Contains(3), 'ArraySet[3] expected to exist');
  Check(ArraySet.Contains(4), 'ArraySet[4] expected to exist');

  ArraySet.Free();
  Stack.Free();

  { Copy from array tests }
  SetLength(IL, 6);

  IL[0] := 1;
  IL[1] := 2;
  IL[2] := 3;
  IL[3] := 4;
  IL[4] := 5;
  IL[5] := 5;

  ArraySet := TArraySet<Integer>.Create(IL);

  Check(ArraySet.Count = 5, 'ArraySet count expected to be 5');
  Check(ArraySet.Contains(1), 'ArraySet expected to contain 1');
  Check(ArraySet.Contains(2), 'ArraySet expected to contain 2');
  Check(ArraySet.Contains(3), 'ArraySet expected to contain 3');
  Check(ArraySet.Contains(4), 'ArraySet expected to contain 4');
  Check(ArraySet.Contains(5), 'ArraySet expected to contain 5');

  ArraySet.Free;
end;

procedure TTestArraySet.TestEnumerator;
var
  ArraySet : TArraySet<Integer>;
  I, X  : Integer;
begin
  ArraySet := TArraySet<Integer>.Create();

  ArraySet.Add(10);
  ArraySet.Add(20);
  ArraySet.Add(30);

  X := 0;

  for I in ArraySet do
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
      for I in ArraySet do
      begin
        ArraySet.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(ArraySet.Count = 2, 'Enumerator failed too late');

  ArraySet.Free();
end;

procedure TTestArraySet.TestExceptions;
var
  ArraySet : TArraySet<Integer>;
  NullArg  : IType<Integer>;
begin
  NullArg := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      ArraySet := TArraySet<Integer>.Create(NullArg);
      ArraySet.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      ArraySet := TArraySet<Integer>.Create(NullArg, 10);
      ArraySet.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      ArraySet := TArraySet<Integer>.Create(TType<Integer>.Default, nil);
      ArraySet.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  ArraySet.Free();
end;

procedure TTestArraySet.TestIDynamic;
const
  NrElem = 1000;

var
  ASet: TArraySet<Integer>;
  I: Integer;
begin
  { With intitial capacity }
  ASet := TArraySet<Integer>.Create(100);

  ASet.Shrink();
  Check(ASet.Capacity = 0, 'Capacity expected to be 0');
  Check(ASet.GetCapacity() = ASet.Capacity, 'GetCapacity() expected to be equal to Capacity');

  ASet.Grow();
  Check(ASet.Capacity > 0, 'Capacity expected to be > 0');
  Check(ASet.GetCapacity() = ASet.Capacity, 'GetCapacity() expected to be equal to Capacity');

  ASet.Shrink();
  ASet.Add(10);
  ASet.Add(20);
  ASet.Add(30);
  Check(ASet.Capacity > ASet.Count, 'Capacity expected to be > Count');
  Check(ASet.GetCapacity() = ASet.Capacity, 'GetCapacity() expected to be equal to Capacity');

  ASet.Shrink();
  Check(ASet.Capacity = ASet.Count, 'Capacity expected to be = Count');
  Check(ASet.GetCapacity() = ASet.Capacity, 'GetCapacity() expected to be equal to Capacity');

  ASet.Grow();
  Check(ASet.Capacity > ASet.Count, 'Capacity expected to be > Count');
  Check(ASet.GetCapacity() = ASet.Capacity, 'GetCapacity() expected to be equal to Capacity');

  ASet.Clear();
  ASet.Shrink();
  Check(ASet.Capacity = 0, 'Capacity expected to be = 0');
  Check(ASet.GetCapacity() = ASet.Capacity, 'GetCapacity() expected to be equal to Capacity');


  for I := 0 to NrElem - 1 do
    ASet.Add(I);

  for I := 0 to NrElem - 1 do
    ASet.Remove(I);

  Check(ASet.Capacity > NrElem, 'Capacity expected to be > NrElem');
  Check(ASet.GetCapacity() = ASet.Capacity, 'GetCapacity() expected to be equal to Capacity');

  ASet.Free;
end;

procedure TTestArraySet.TestObjectVariant;
var
  ObjSet: TObjectArraySet<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjSet := TObjectArraySet<TTestObject>.Create();
  Check(not ObjSet.OwnsObjects, 'OwnsObjects must be false!');

  TheObject := TTestObject.Create(@ObjectDied);
  ObjSet.Add(TheObject);
  ObjSet.Clear;

  Check(not ObjectDied, 'The object should not have been cleaned up!');
  ObjSet.Add(TheObject);
  ObjSet.OwnsObjects := true;
  Check(ObjSet.OwnsObjects, 'OwnsObjects must be true!');

  ObjSet.Clear;

  Check(ObjectDied, 'The object should have been cleaned up!');
  ObjSet.Free;
end;

initialization
  TestFramework.RegisterTest(TTestArraySet.Suite);

end.
