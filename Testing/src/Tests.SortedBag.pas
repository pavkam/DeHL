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
unit Tests.SortedBag;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Collections.Stack,
     DeHL.Collections.List,
     DeHL.Collections.SortedBag;

type
  TTestSortedBag = class(TDeHLTestCase)
  published
    procedure TestCreationAndDestroy();
    procedure TestCreateWithDynFixArrays();
    procedure TestAdd();
    procedure TestRemove();
    procedure TestRemoveAll();
    procedure TestClear();
    procedure TestCount();
    procedure TestContains();
    procedure TestIndexer();
    procedure TestCopyTo();
    procedure TestEnumerator();
    procedure TestExceptions();

    procedure TestObjectVariant();

    procedure TestCorrectOrdering();
  end;

implementation

{ TTestDictionary }

procedure TTestSortedBag.TestAdd;
var
  ABag: TSortedBag<Integer>;
begin
  ABag := TSortedBag<Integer>.Create();

  ABag.Add(10, 2);
  ABag.Add(8, 0);
  ABag.Add(5, 5);
  Check(ABag.Count = 7, 'Count expected to be 7');

  ABag.Add(5, 2);
  Check(ABag.Count = 9, 'Count excepted to be 9');

  Check(ABag[10] = 2, 'Expected ABag[10] = 2');
  Check(ABag[8] = 0, 'Expected ABag[8] = 0');
  Check(ABag[5] = 7, 'Expected ABag[5] = 7');

  ABag.Free;
end;

procedure TTestSortedBag.TestClear;
var
  ABag: TSortedBag<Integer>;
begin
  ABag := TSortedBag<Integer>.Create();

  ABag.Add(100, 2);
  ABag.Add(4, 400);
  Check(ABag.Count = 402, 'Count expected to be 402');

  ABag.Clear();
  Check(ABag.Count = 0, 'Count expected to be 0');

  ABag.Free();
end;

procedure TTestSortedBag.TestContains;
var
  ABag: TSortedBag<Integer>;
begin
  ABag := TSortedBag<Integer>.Create();

  ABag.Add(1, 100);
  ABag.Add(2, 2);
  ABag.Add(3, 0);
  ABag.Add(4, 90);
  Check(ABag.Count = 192, 'Count expected to be 192');

  Check(ABag.Contains(1), 'Contains(1) expected to be true');
  Check(ABag.Contains(1, 0), 'Contains(1, 0) expected to be true');
  Check(ABag.Contains(1, 50), 'Contains(1, 50) expected to be true');
  Check(ABag.Contains(1, 100), 'Contains(1, 100) expected to be true');
  Check(not ABag.Contains(1, 101), 'Contains(1, 101) expected to be false');

  Check(ABag.Contains(2), 'Contains(2) expected to be true');
  Check(ABag.Contains(2, 0), 'Contains(2, 0) expected to be true');
  Check(ABag.Contains(2, 1), 'Contains(2, 1) expected to be true');
  Check(ABag.Contains(2, 2), 'Contains(2, 2) expected to be true');
  Check(not ABag.Contains(2, 100), 'Contains(2, 100) expected to be false');

  Check(not ABag.Contains(3), 'Contains(3) expected to be false');
  Check(ABag.Contains(3, 0), 'Contains(3, 0) expected to be true');

  Check(ABag.Contains(4), 'Contains(4) expected to be true');
  Check(ABag.Contains(4, 0), 'Contains(1, 0) expected to be true');
  Check(ABag.Contains(4, 50), 'Contains(4, 50) expected to be true');
  Check(ABag.Contains(4, 90), 'Contains(4, 90) expected to be true');
  Check(not ABag.Contains(4, 91), 'Contains(4, 91) expected to be false');

  ABag.Free();
end;

procedure TTestSortedBag.TestCopyTo;
var
  ABag: TSortedBag<Integer>;
  IL: array of Integer;
begin
  ABag := TSortedBag<Integer>.Create();

  { Add elements to the ArraySet }
  ABag.Add(1);
  ABag.Add(1);
  ABag.Add(3, 1);
  ABag.Add(4, 2);
  ABag.Add(5, 0);

  { Check the copy }
  SetLength(IL, 5);
  ABag.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  ABag.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 1, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 4, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin ABag.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin ABag.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  ABag.Free();
end;

procedure TTestSortedBag.TestCorrectOrdering;
const
  MaxNr = 1000;
  MaxRnd = 10000;

var
  AscBag, DescBag : TSortedBag<Integer>;
  I, PI  : Integer;
begin
  { One ascending }
  AscBag := TSortedBag<Integer>.Create(true);

  { ... and one not }
  DescBag := TSortedBag<Integer>.Create(false);

  Randomize;

  { Fill sets with filth }
  for I := 0 to MaxNr - 1 do
  begin
    AscBag.Add(Random(MaxRnd));
    DescBag.Add(Random(MaxRnd));
  end;

  { Enumerate the ascending and check that each key is bigger than the prev one }
  PI := -1;
  for I in AscBag do
  begin
    Check(I >= PI, 'Failed enumeration! Expected that -- always: Vi >= Vi-1 for ascending sorted bag.');
    PI := I;
  end;

  { Enumerate the ascending and check that each key is lower than the prev one }
  PI := MaxRnd;
  for I in DescBag do
  begin
    Check(I <= PI, 'Failed enumeration! Expected that -- always: Vi-1 >= Vi for descending sorted bag.');
    PI := I;
  end;

  AscBag.Free;
  DescBag.Free;
end;

procedure TTestSortedBag.TestCount;
var
  ABag: TSortedBag<Integer>;
begin
  ABag := TSortedBag<Integer>.Create();
  Check(ABag.Count = 0, 'Count expected to be 0');

  ABag.Add(10);
  Check(ABag.Count = 1, 'Count expected to be 1');

  ABag.Add(10, 5);
  Check(ABag.Count = 6, 'Count expected to be 6');

  ABag.Add(29, 9);
  Check(ABag.Count = 15, 'Count expected to be 15');

  ABag.Add(101, 0);
  Check(ABag.Count = 15, 'Count expected to be 15');

  ABag.Remove(29);
  Check(ABag.Count = 14, 'Count expected to be 14');

  ABag.RemoveAll(10);
  Check(ABag.Count = 8, 'Count expected to be 8');

  ABag.Clear();
  Check(ABag.Count = 0, 'Count expected to be 0');

  ABag.Free();
end;

procedure TTestSortedBag.TestCreateWithDynFixArrays;
var
  DA: TDynamicArray<Integer>;
  FA: TFixedArray<Integer>;

  DAL: TSortedBag<Integer>;
  FAL: TSortedBag<Integer>;
begin
  DA := TDynamicArray<Integer>.Create([5, 6, 2, 3, 1, 1]);
  FA := TFixedArray<Integer>.Create([5, 6, 2, 3, 1, 1]);

  DAL := TSortedBag<Integer>.Create(DA);
  FAL := TSortedBag<Integer>.Create(FA);

  Check(DAL.Count = 6, 'Expected DAL.Length to be 6');
  Check(DAL.Contains(5), 'Expected DAL to contain 5');
  Check(DAL.Contains(6), 'Expected DAL to contain 6');
  Check(DAL.Contains(2), 'Expected DAL to contain 2');
  Check(DAL.Contains(3), 'Expected DAL to contain 3');
  Check(DAL.Contains(1, 2), 'Expected DAL to contain 1 (2)');

  Check(FAL.Count = 6, 'Expected FAL.Length to be 6');
  Check(FAL.Contains(5), 'Expected FAL to contain 5');
  Check(FAL.Contains(6), 'Expected FAL to contain 6');
  Check(FAL.Contains(2), 'Expected FAL to contain 2');
  Check(FAL.Contains(3), 'Expected FAL to contain 3');
  Check(FAL.Contains(1, 2), 'Expected FAL to contain 1 (2)');

  DAL.Free;
  FAL.Free;
end;

procedure TTestSortedBag.TestCreationAndDestroy;
var
  ABag : TSortedBag<Integer>;
  Stack : TStack<Integer>;
  IL    : array of Integer;
begin
  { With default capacity }
  ABag := TSortedBag<Integer>.Create();

  ABag.Add(10, 2);
  ABag.Add(20);
  ABag.Add(30, 1);
  ABag.Add(40, 3);

  Check(ABag.Count = 7, 'ABag count expected to be 7');

  ABag.Free();

  { With Copy }
  Stack := TStack<Integer>.Create();
  Stack.Push(1);
  Stack.Push(1);
  Stack.Push(3);
  Stack.Push(4);

  ABag := TSortedBag<Integer>.Create(Stack);

  Check(ABag.Count = 4, 'ABag count expected to be 4');
  Check(ABag.Contains(1, 2), 'ABag expected to contain 1 twice');
  Check(ABag.Contains(3), 'ABag expected to contain 3');
  Check(ABag.Contains(4), 'ABag expected to contain 4');

  ABag.Free();
  Stack.Free();

  { Copy from array tests }
  SetLength(IL, 6);

  IL[0] := 1;
  IL[1] := 2;
  IL[2] := 3;
  IL[3] := 4;
  IL[4] := 5;
  IL[5] := 5;

  ABag := TSortedBag<Integer>.Create(IL);

  Check(ABag.Count = 6, 'ABag count expected to be 6');

  Check(ABag.Contains(1, 1), 'ABag expected to contain 1');
  Check(ABag.Contains(2, 1), 'ABag expected to contain 2');
  Check(ABag.Contains(3, 1), 'ABag expected to contain 3');
  Check(ABag.Contains(4, 1), 'ABag expected to contain 4');
  Check(ABag.Contains(5, 2), 'ABag expected to contain 5 twice');

  ABag.Free;
end;

procedure TTestSortedBag.TestEnumerator;
var
  ABag : TSortedBag<Integer>;
  I, X  : Integer;
begin
  ABag := TSortedBag<Integer>.Create();

  ABag.Add(10, 2);
  ABag.Add(20, 3);
  ABag.Add(30);

  X := 0;

  for I in ABag do
  begin
    if (X >= 0) and (X <= 1) then
       Check(I = 10, 'Enumerator failed at 0...1!')
    else if (X >= 2) and (X <= 4) then
       Check(I = 20, 'Enumerator failed at 2...4!')
    else if X = 5 then
       Check(I = 30, 'Enumerator failed at 5!')
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
      for I in ABag do
      begin
        ABag.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(ABag.Count = 5, 'Enumerator failed too late');
  ABag.Free();
end;

procedure TTestSortedBag.TestExceptions;
var
  ABag: TSortedBag<Integer>;
  NullArg: IType<Integer>;
begin
  NullArg := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      ABag := TSortedBag<Integer>.Create(NullArg);
      ABag.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      ABag := TSortedBag<Integer>.Create(TType<Integer>.Default, nil);
      ABag.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  ABag.Free();
end;

procedure TTestSortedBag.TestIndexer;
var
  ABag : TSortedBag<String>;
begin
  ABag := TSortedBag<String>.Create();

  ABag.Add('Apples');
  ABag.Add('Melons', 0);
  ABag.Add('Looks', 10);

  Check(ABag['Apples'] = 1, 'Expected ABag[''Apples''] = 1');
  Check(ABag['Melons'] = 0, 'Expected ABag[''Melons''] = 0');
  Check(ABag['Looks'] = 10, 'Expected ABag[''Looks''] = 10');

  ABag['Apples'] := 20;
  ABag['Melons'] := 1;
  ABag['Looks'] := 0;
  ABag['Kittens'] := 12;

  Check(ABag['Apples'] = 20, 'Expected ABag[''Apples''] = 20');
  Check(ABag['Melons'] = 1, 'Expected ABag[''Melons''] = 0');
  Check(ABag['Looks'] = 0, 'Expected ABag[''Looks''] = 0');
  Check(ABag['Kittens'] = 12, 'Expected ABag[''Kittens''] = 12');

  ABag.Free();
end;

procedure TTestSortedBag.TestObjectVariant;
var
  ObjBag: TObjectSortedBag<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjBag := TObjectSortedBag<TTestObject>.Create();
  Check(not ObjBag.OwnsObjects, 'OwnsObjects must be false!');

  TheObject := TTestObject.Create(@ObjectDied);
  ObjBag.Add(TheObject);
  ObjBag.Clear;

  Check(not ObjectDied, 'The object should not have been cleaned up!');
  ObjBag.Add(TheObject);
  ObjBag.OwnsObjects := true;
  Check(ObjBag.OwnsObjects, 'OwnsObjects must be true!');

  ObjBag.Clear;

  Check(ObjectDied, 'The object should have been cleaned up!');
  ObjBag.Free;
end;

procedure TTestSortedBag.TestRemove;
var
  ABag : TSortedBag<String>;
begin
  ABag := TSortedBag<String>.Create();

  ABag.Add('Apples');
  ABag.Add('Melons', 2);
  ABag.Add('Looks', 10);

  ABag.Remove('Apples', 0);
  ABag.Remove('Melons', 2);
  ABag.Remove('Looks', 5);

  Check(ABag['Apples'] = 1, 'Expected ABag[''Apples''] = 1');
  Check(ABag['Melons'] = 0, 'Expected ABag[''Melons''] = 0');
  Check(ABag['Looks'] = 5, 'Expected ABag[''Looks''] = 5');
  Check(ABag.Count = 6, 'Expected ABag.Count = 6');

  ABag.Free();
end;

procedure TTestSortedBag.TestRemoveAll;
var
  ABag : TSortedBag<String>;
begin
  ABag := TSortedBag<String>.Create();

  ABag.Add('Apples');
  ABag.Add('Melons', 2);
  ABag.Add('Looks', 10);

  ABag.RemoveAll('Apples');
  ABag.RemoveAll('Melons');
  ABag.RemoveAll('Looks');

  Check(ABag['Apples'] = 0, 'Expected ABag[''Apples''] = 0');
  Check(ABag['Melons'] = 0, 'Expected ABag[''Melons''] = 0');
  Check(ABag['Looks'] = 0, 'Expected ABag[''Looks''] = 0');
  Check(ABag.Count = 0, 'Expected ABag.Count = 0');

  ABag.Free();
end;

initialization
  TestFramework.RegisterTest(TTestSortedBag.Suite);

end.
