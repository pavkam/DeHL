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
unit Tests.SortedSet;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHl.Collections.Base,
     DeHL.Arrays,
     DeHL.Collections.Stack,
     DeHL.Collections.SortedSet;

type
  TTestSortedSet = class(TDeHLTestCase)
  published
    procedure TestCreationAndDestroy();
    procedure TestCreateWithDynFixArrays();
    procedure TestCountClearAdd();
    procedure TestContains();
    procedure TestCopyTo();
    procedure TestEnumerator();
    procedure TestExceptions();
    procedure TestHardCore();
    procedure TestCorrectOrdering();

    procedure TestObjectVariant();

    procedure TestCleanup();
  end;

implementation

{ TTestQueue }

procedure TTestSortedSet.TestCountClearAdd;
var
  TheSet  : TSortedSet<String>;
  Stack : TStack<String>;
begin
  TheSet := TSortedSet<String>.Create();
  Stack := TStack<String>.Create();

  Stack.Push('s1');
  Stack.Push('s2');
  Stack.Push('s3');

  TheSet.Add('1');
  TheSet.Add('2');
  TheSet.Add('3');

  Check((TheSet.Count = 3) and (TheSet.Count = TheSet.GetCount()), 'TheSet count expected to be 3');

  { 1 2 3 }
  TheSet.Add('0');

  { 1 2 3 0 }
  TheSet.Add('-1');

  { 1 2 3 0 -1 }
  TheSet.Add('5');

  Check((TheSet.Count = 6) and (TheSet.Count = TheSet.GetCount()), 'TheSet count expected to be 6');


  TheSet.Remove('1');

  Check((TheSet.Count = 5) and (TheSet.Count = TheSet.GetCount()), 'TheSet count expected to be 5');

  TheSet.Remove('5');
  TheSet.Remove('3');
  TheSet.Remove('2');
  TheSet.Remove('-1');
  TheSet.Remove('0');

  Check((TheSet.Count = 0) and (TheSet.Count = TheSet.GetCount()), 'TheSet count expected to be 0');

  TheSet.Free;
  Stack.Free;

end;

procedure TTestSortedSet.TestCopyTo;
var
  TheSet  : TSortedSet<Integer>;
  IL    : array of Integer;
begin
  TheSet := TSortedSet<Integer>.Create();

  { Add elements to the TheSet }
  TheSet.Add(1);
  TheSet.Add(2);
  TheSet.Add(3);
  TheSet.Add(4);
  TheSet.Add(5);

  { Check the copy }
  SetLength(IL, 5);
  TheSet.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 2, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  TheSet.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 2, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 5, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin TheSet.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin TheSet.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  TheSet.Free();
end;

procedure TTestSortedSet.TestCorrectOrdering;
const
  MaxNr = 1000;
  MaxRnd = 10000;

var
  AscSet, DescSet : TSortedSet<Integer>;
  I, PI  : Integer;
begin
  { One ascending }
  AscSet := TSortedSet<Integer>.Create(true);

  { ... and one not }
  DescSet := TSortedSet<Integer>.Create(false);

  Randomize;

  { Fill sets with filth }
  for I := 0 to MaxNr - 1 do
  begin
    AscSet.Add(Random(MaxRnd));
    DescSet.Add(Random(MaxRnd));
  end;

  { Enumerate the ascending and check that each key is bigger than the prev one }
  PI := -1;
  for I in AscSet do
  begin
    Check(I > PI, 'Failed enumeration! Expected that -- always: Vi > Vi-1 for ascending sorted set.');
    PI := I;
  end;

  { Enumerate the ascending and check that each key is lower than the prev one }
  PI := MaxRnd;
  for I in DescSet do
  begin
    Check(I < PI, 'Failed enumeration! Expected that -- always: Vi-1 > Vi for descending sorted set.');
    PI := I;
  end;

  AscSet.Free;
  DescSet.Free;
end;

procedure TTestSortedSet.TestCleanup;
var
  ASet : TSortedSet<Integer>;
  ElemCache: Integer;
  I: Integer;
begin
  ElemCache := 0;

  { Create a new ASet }
  ASet := TSortedSet<Integer>.Create(
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

procedure TTestSortedSet.TestContains;
var
  TheSet  : TSortedSet<Integer>;
begin
  TheSet := TSortedSet<Integer>.Create();

  TheSet.Add(1);
  TheSet.Add(2);
  TheSet.Add(3);
  TheSet.Add(4);   {-}
  TheSet.Add(5);
  TheSet.Add(6);
  TheSet.Add(4);   {-}
  TheSet.Add(7);
  TheSet.Add(8);
  TheSet.Add(9);

  Check(TheSet.Contains(1), 'Set expected to contain 1');
  Check(TheSet.Contains(2), 'Set expected to contain 2');
  Check(TheSet.Contains(3), 'Set expected to contain 3');
  Check(TheSet.Contains(4), 'Set expected to contain 4');
  Check(not TheSet.Contains(10), 'Set not expected to contain 10');

  TheSet.Free();
end;

procedure TTestSortedSet.TestCreateWithDynFixArrays;
var
  DA: TDynamicArray<Integer>;
  FA: TFixedArray<Integer>;

  DAL: TSortedSet<Integer>;
  FAL: TSortedSet<Integer>;
begin
  DA := TDynamicArray<Integer>.Create([5, 6, 2, 3, 1, 1]);
  FA := TFixedArray<Integer>.Create([5, 6, 2, 3, 1, 1]);

  DAL := TSortedSet<Integer>.Create(DA);
  FAL := TSortedSet<Integer>.Create(FA);

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

procedure TTestSortedSet.TestCreationAndDestroy;
var
  TheSet : TSortedSet<Integer>;
  Stack : TStack<Integer>;
  IL    : array of Integer;
begin
  { With default capacity }
  TheSet := TSortedSet<Integer>.Create();

  TheSet.Add(10);
  TheSet.Add(20);
  TheSet.Add(30);
  TheSet.Add(40);

  Check(TheSet.Count = 4, 'TheSet count expected to be 4)');

  TheSet.Free();

  { With Copy }
  Stack := TStack<Integer>.Create();
  Stack.Push(1);
  Stack.Push(2);
  Stack.Push(3);
  Stack.Push(4);

  TheSet := TSortedSet<Integer>.Create(Stack);

  Check(TheSet.Count = 4, 'TheSet count expected to be 4)');
  Check(TheSet.Contains(1), 'TheSet[1] expected to exist)');
  Check(TheSet.Contains(2), 'TheSet[2] expected to exist)');
  Check(TheSet.Contains(3), 'TheSet[3] expected to exist)');
  Check(TheSet.Contains(4), 'TheSet[4] expected to exist)');

  TheSet.Free();
  Stack.Free();

  { Copy from array tests }
  SetLength(IL, 6);

  IL[0] := 1;
  IL[1] := 2;
  IL[2] := 3;
  IL[3] := 4;
  IL[4] := 5;
  IL[5] := 5;

  TheSet := TSortedSet<Integer>.Create(IL);

  Check(TheSet.Count = 5, 'TheSet count expected to be 5');

  Check(TheSet.Contains(1), 'TheSet expected to contain 1');
  Check(TheSet.Contains(2), 'TheSet expected to contain 2');
  Check(TheSet.Contains(3), 'TheSet expected to contain 3');
  Check(TheSet.Contains(4), 'TheSet expected to contain 4');
  Check(TheSet.Contains(5), 'TheSet expected to contain 5');

  TheSet.Free;
end;

procedure TTestSortedSet.TestEnumerator;
var
  TheSet : TSortedSet<Integer>;
  I, X  : Integer;
begin
  TheSet := TSortedSet<Integer>.Create();

  TheSet.Add(10);
  TheSet.Add(20);
  TheSet.Add(30);

  X := 0;

  for I in TheSet do
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
      for I in TheSet do
      begin
        TheSet.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(TheSet.Count = 2, 'Enumerator failed too late');

  TheSet.Free();
end;

procedure TTestSortedSet.TestExceptions;
var
  TheSet : TSortedSet<Integer>;
  NullArg : IType<Integer>;
begin
  NullArg := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      TheSet := TSortedSet<Integer>.Create(NullArg);
      TheSet.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TheSet := TSortedSet<Integer>.Create(TType<Integer>.Default, nil);
      TheSet.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  TheSet.Free();
end;

procedure TTestSortedSet.TestHardCore;
const
  NrCont = 10000;

var
  ASet: ISet<Integer>;
  I: Integer;

begin
  ASet := TSortedSet<Integer>.Create(TSuppressedWrapperType<Integer>.Create(TType<Integer>.Default()));

  for I := 0 to NrCont - 1 do
    ASet.Add(I);

  for I := 0 to NrCont - 1 do
    ASet.Remove(I);

  Check(ASet.Count = 0, 'Expected an empty set!');
end;

procedure TTestSortedSet.TestObjectVariant;
var
  ObjSet: TObjectSortedSet<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjSet := TObjectSortedSet<TTestObject>.Create();
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
  TestFramework.RegisterTest(TTestSortedSet.Suite);

end.
