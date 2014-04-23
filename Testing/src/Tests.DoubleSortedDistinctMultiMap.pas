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
unit Tests.DoubleSortedDistinctMultiMap;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.List,
     DeHL.Arrays,
     DeHL.Tuples,
     DeHL.Collections.Base,
     DeHL.Collections.DoubleSortedDistinctMultiMap;

type
  TTestDoubleSortedDistinctMultiMap = class(TDeHLTestCase)
  published
    procedure TestCreationAndDestroy();
    procedure TestCreateWithDynFixArrays();
    procedure TestClearAddRemoveCount();
    procedure TestContainsKeyContainsValue();
    procedure TestLists();
    procedure TestTryGetValues();
    procedure TestTryGetValues2();
    procedure TestValues();
    procedure TestKeys();
    procedure TestCopyTo();
    procedure TestValuesCopyTo();
    procedure TestKeysCopyTo();
    procedure TestEnumerator();
    procedure TestKeysEnumerator();
    procedure TestValuesEnumerator();
    procedure TestExceptions();
    procedure TestCorrectOrdering();

    procedure TestObjectVariant();

    procedure TestCleanup();
 end;

implementation

{ TTestDoubleSortedDistinctMultiMap }

procedure TTestDoubleSortedDistinctMultiMap.TestCleanup;
var
  ADict : TDoubleSortedDistinctMultiMap<Integer, Integer>;
  KeyCache, ValCache: Integer;
  X: KVPair<Integer, Integer>;
  I: Integer;
begin
  KeyCache := 0;
  ValCache := 0;

  { Create a new ADict }
  ADict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(KeyCache, Arg1);
    end),
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ValCache, Arg1);
    end)
  );

  { Add some elements }
  ADict.Add(1, 1);
  ADict.Add(1, 2);
  ADict.Add(4, 4);
  ADict.Add(8, 8);

  Check((ValCache + KeyCache) = 0, 'Nothing should have be cleaned up yet!');

  ADict.Remove(1);
  ADict.Remove(4);

  Check(ValCache = 7, 'Expected value cache = 7');
  Check(KeyCache = 0, 'Expected value cache = 0');

  ValCache := 0;
  KeyCache := 0;

  { Simply walk the ADict }
  for X in ADict do
    if X.Key > 0 then;

  for I in ADict.Keys do
    if I > 0 then;

  for I in ADict.Values do
    if I > 0 then;

  Check((ValCache + KeyCache) = 0, 'Nothing should have be cleaned up yet!');

  ADict.Clear();

  Check(ValCache = 8, 'Expected value cache = 8');
  Check(KeyCache = 8, 'Expected key cache = 8');

  ValCache := 0;
  KeyCache := 0;

  ADict.Add(1, 1);
  ADict.Add(1, 2);
  ADict.Add(4, 4);
  ADict.Add(8, 8);

  ADict.Free;

  Check(ValCache = 15, 'Expected value cache = 15');
  Check(KeyCache = 13, 'Expected key cache = 13');
end;

procedure TTestDoubleSortedDistinctMultiMap.TestClearAddRemoveCount;
var
  Dict : TDoubleSortedDistinctMultiMap<Integer, String>;

begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  { Add items }
  Dict.Add(10, 'String 10');
  Dict.Add(20, 'String 20');
  Dict.Add(30, 'String 30');
  Dict.Add(30, 'String 30 (1)');
  Dict.Add(30, 'String 30 (2)');
  Check((Dict.Count = 5) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 5');

  Dict.Add(15, 'String 15');
  Dict.Add(25, 'String 25');
  Dict.Add(25, 'String 25 (1)');
  Check((Dict.Count = 8) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 8');

  Dict.Remove(10);
  Dict.Remove(15);
  Check((Dict.Count = 6) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 6');

  Dict.Remove(25);
  Check((Dict.Count = 4) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 4');

  Dict.Clear();
  Check((Dict.Count = 0) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 0');

  Dict.Add(15, 'String 15');
  Dict.Add(15, 'String 15');
  Check((Dict.Count = 1) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 1');

  Dict.Remove(15);
  Check((Dict.Count = 0) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 0');

  Dict.Add(1, '1');
  Dict.Add(1, '2');
  Dict.Add(1, '3');
  Check((Dict.Count = 3) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 3');

  Dict.Remove(1, '3');
  Check((Dict.Count = 2) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 2');
  Check(Dict[1].Min = '1', 'DoubleSortedDistinctMultiMap[1].Min expected to be "1"');
  Check(Dict[1].Max = '2', 'DoubleSortedDistinctMultiMap[1].Max expected to be "2"');

  Dict.Remove(KVPair<Integer, String>.Create(1, '1'));
  Check((Dict.Count = 1) and (Dict.GetCount() = Dict.Count), 'DoubleSortedDistinctMultiMap count expected to be 1');
  Check(Dict[1].Single = '2', 'DoubleSortedDistinctMultiMap[1].Single expected to be "2"');

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestContainsKeyContainsValue;
var
  Dict : TDoubleSortedDistinctMultiMap<Integer, String>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  { Add items }
  Dict.Add(10, 'String 10');
  Dict.Add(10, 'String 10');
  Dict.Add(20, 'String 20');
  Dict.Add(30, 'String 30');
  Dict.Add(30, 'String 30 (1)');

  Check(Dict.ContainsKey(10), 'DoubleSortedDistinctMultiMap expected to contain key 10.');
  Check(Dict.ContainsKey(20), 'DoubleSortedDistinctMultiMap expected to contain key 20.');
  Check(Dict.ContainsKey(30), 'DoubleSortedDistinctMultiMap expected to contain key 30.');
  Check(not Dict.ContainsKey(40), 'DoubleSortedDistinctMultiMap not expected to contain key 40.');

  Check(Dict.ContainsValue('String 10'), 'DoubleSortedDistinctMultiMap expected to contain value "String 10".');
  Check(Dict.ContainsValue('String 20'), 'DoubleSortedDistinctMultiMap expected to contain value "String 20".');
  Check(Dict.ContainsValue('String 30'), 'DoubleSortedDistinctMultiMap expected to contain value "String 30".');
  Check(Dict.ContainsValue('String 30 (1)'), 'DoubleSortedDistinctMultiMap expected to contain value "String 30 (1)".');
  Check(not Dict.ContainsValue('String 40'), 'DoubleSortedDistinctMultiMap not expected to contain value "String 40".');

  Check(Dict.ContainsValue(10, 'String 10'), 'DoubleSortedDistinctMultiMap expected to contain value 10/"String 10".');
  Check(Dict.ContainsValue(30, 'String 30'), 'DoubleSortedDistinctMultiMap expected to contain value 30/"String 30".');
  Check(Dict.ContainsValue(30, 'String 30 (1)'), 'DoubleSortedDistinctMultiMap expected to contain value 30/"String 30 (1)".');
  Check(not Dict.ContainsValue(30, 'String 30 (2)'), 'DoubleSortedDistinctMultiMap not expected to contain value 30/"String 30 (2)".');
  Check(Dict.ContainsValue(KVPair<Integer, String>.Create(30, 'String 30 (1)')), 'DoubleSortedDistinctMultiMap expected to contain value 30/"String 30 (1)".');

  Dict.Remove(30);

  Check(not Dict.ContainsValue('String 30'), 'DoubleSortedDistinctMultiMap not expected to contain value "String 30".');
  Check(not Dict.ContainsValue('String 30 (1)'), 'DoubleSortedDistinctMultiMap not expected to contain value "String 30 (1)".');
  Check(not Dict.ContainsKey(30), 'DoubleSortedDistinctMultiMap not expected to contain key 30.');

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestKeysCopyTo;
var
  Dict  : TDoubleSortedDistinctMultiMap<Integer, String>;
  IL    : array of Integer;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(1, '1.1');
  Dict.Add(2, '2');
  Dict.Add(3, '3');
  Dict.Add(3, '3');
  Dict.Add(4, '4');
  Dict.Add(5, '5');
  Dict.Add(5, '5.1');

  { Check the copy }
  SetLength(IL, 5);
  Dict.Keys.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 2, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  Dict.Keys.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 2, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 5, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Keys.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyKeysTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Keys.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyKeysTo (too small size +1).'
  );

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestKeysEnumerator;
var
  Dict : TDoubleSortedDistinctMultiMap<Integer, Integer>;
  X    : Integer;
  I    : Integer;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(10, 12);
  Dict.Add(10, 13);
  Dict.Add(10, 14);
  Dict.Add(20, 21);
  Dict.Add(30, 31);
  Dict.Add(30, 32);
  Dict.Add(30, 33);

  X := 0;

  for I in Dict.Keys do
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
      for I in Dict.Keys do
      begin
        Dict.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Dict.Keys.Count = 2, 'Enumerator failed too late');

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestCopyTo;
var
  Dict  : TDoubleSortedDistinctMultiMap<Integer, String>;
  IL    : array of KVPair<Integer, String>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(1, '2');
  Dict.Add(3, '3');
  Dict.Add(3, '4');
  Dict.Add(3, '5');
  Dict.Add(6, '5');

  { Check the copy }
  SetLength(IL, 6);
  Dict.CopyTo(IL);

  Check((IL[0].Key = 1) and (IL[0].Value = '1'), 'Element 0 in the new array is wrong!');
  Check((IL[1].Key = 1) and (IL[1].Value = '2'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 3) and (IL[2].Value = '3'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 3) and (IL[3].Value = '4'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 3) and (IL[4].Value = '5'), 'Element 4 in the new array is wrong!');
  Check((IL[5].Key = 6) and (IL[5].Value = '5'), 'Element 5 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 7);
  Dict.CopyTo(IL, 1);

  Check((IL[1].Key = 1) and (IL[1].Value = '1'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 1) and (IL[2].Value = '2'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 3) and (IL[3].Value = '3'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 3) and (IL[4].Value = '4'), 'Element 4 in the new array is wrong!');
  Check((IL[5].Key = 3) and (IL[5].Value = '5'), 'Element 5 in the new array is wrong!');
  Check((IL[6].Key = 6) and (IL[6].Value = '5'), 'Element 6 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestCorrectOrdering;
const
  MaxNr = 1000;
  MaxRnd = 10;

var
  AscAscMM, AscDescMM, DescDescMM, DescAscMM:
    TDoubleSortedDistinctMultiMap<Integer, Integer>;

  FA: IEnexCollection<Integer>;
  I, PI, X: Integer;
begin
  { ... Create }
  AscAscMM := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(true, true);
  AscDescMM := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(true, false);
  DescDescMM := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(false, false);
  DescAscMM := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(false, true);

  Randomize;

  { Fill dictionaries with filth }
  for I := 0 to MaxNr - 1 do
  begin
    AscAscMM.Add(Random(MaxRnd), I);
    AscDescMM.Add(Random(MaxRnd), I);
    DescDescMM.Add(Random(MaxRnd), I);
    DescAscMM.Add(Random(MaxRnd), I);
  end;

  { Enumerate the ascending/ascending version }
  PI := -1;
  for I in AscAscMM.Keys do
  begin
    { Check key ordering }
    Check(I > PI, 'Failed enumeration! Expected that -- always: Vi > Vi-1 for a/a sorted mmap.');
    PI := I;

    FA := AscAscMM[I];
    if FA.Count > 1 then
      for X := 0 to FA.Count - 2 do
        Check(FA.ElementAt(X) <= FA.ElementAt(X + 1), 'Failed enumeration! Expected that -- always: Xi <= Xi+1 for a/a sorted mmap list.');
  end;

  { Enumerate the ascending/ascending version }
  PI := -1;
  for I in AscDescMM.Keys do
  begin
    { Check key ordering }
    Check(I > PI, 'Failed enumeration! Expected that -- always: Vi > Vi-1 for a/d sorted mmap.');
    PI := I;

    FA := AscDescMM[I];
    if FA.Count > 1 then
      for X := 0 to FA.Count - 2 do
        Check(FA.ElementAt(X) >= FA.ElementAt(X + 1), 'Failed enumeration! Expected that -- always: Xi >= Xi+1 for a/d sorted mmap list.');
  end;

  { Enumerate the ascending/ascending version }
  PI := MaxRnd;
  for I in DescDescMM.Keys do
  begin
    { Check key ordering }
    Check(I < PI, 'Failed enumeration! Expected that -- always: Vi < Vi-1 for d/d sorted mmap.');
    PI := I;

    FA := DescDescMM[I];
    if FA.Count > 1 then
      for X := 0 to FA.Count - 2 do
        Check(FA.ElementAt(X) >= FA.ElementAt(X + 1), 'Failed enumeration! Expected that -- always: Xi >= Xi+1 for d/d sorted mmap list.');
  end;

  { Enumerate the ascending/ascending version }
  PI := MaxRnd;
  for I in DescAscMM.Keys do
  begin
    { Check key ordering }
    Check(I < PI, 'Failed enumeration! Expected that -- always: Vi < Vi-1 for d/a sorted mmap.');
    PI := I;

    FA := DescAscMM[I];
    if FA.Count > 1 then
      for X := 0 to FA.Count - 2 do
        Check(FA.ElementAt(X) <= FA.ElementAt(X + 1), 'Failed enumeration! Expected that -- always: Xi <= Xi+1 for d/a sorted mmap list.');
  end;

  AscAscMM.Free;
  AscDescMM.Free;
  DescDescMM.Free;
  DescAscMM.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestValuesEnumerator;
var
  Dict : TDoubleSortedDistinctMultiMap<Integer, Integer>;
  X    : Integer;
  I    : Integer;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();

  Dict.Add(10, 21);
  Dict.Add(10, 22);
  Dict.Add(30, 31);

  X := 0;

  for I in Dict.Values do
  begin
    if X = 0 then
       Check(I = 21, 'Enumerator failed at 0!')
    else if X = 1 then
       Check(I = 22, 'Enumerator failed at 1!')
    else if X = 2 then
       Check(I = 31, 'Enumerator failed at 2!')
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
      for I in Dict.Values do
      begin
        Dict.ContainsValue(I);
        Dict.Clear();
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Dict.Values.Count = 0, 'Enumerator failed too late');

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestValuesCopyTo;
var
  Dict  : TDoubleSortedDistinctMultiMap<Integer, String>;
  IL    : array of String;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(1, '2');
  Dict.Add(3, '3');
  Dict.Add(3, '4');
  Dict.Add(5, '5');

  { Check the copy }
  SetLength(IL, 5);
  Dict.Values.CopyTo(IL);

  Check(IL[0] = '1', 'Element 0 in the new array is wrong!');
  Check(IL[1] = '2', 'Element 1 in the new array is wrong!');
  Check(IL[2] = '3', 'Element 2 in the new array is wrong!');
  Check(IL[3] = '4', 'Element 3 in the new array is wrong!');
  Check(IL[4] = '5', 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  Dict.Values.CopyTo(IL, 1);

  Check(IL[1] = '1', 'Element 1 in the new array is wrong!');
  Check(IL[2] = '2', 'Element 2 in the new array is wrong!');
  Check(IL[3] = '3', 'Element 3 in the new array is wrong!');
  Check(IL[4] = '4', 'Element 4 in the new array is wrong!');
  Check(IL[5] = '5', 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Values.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyValuesTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Values.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyValuesTo (too small size +1).'
  );

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestCreateWithDynFixArrays;
var
  IL: array of KVPair<Integer, Integer>;
  DA: TDynamicArray<KVPair<Integer, Integer>>;
  FA: TFixedArray<KVPair<Integer, Integer>>;

  DAL: TDoubleSortedDistinctMultiMap<Integer, Integer>;
  FAL: TDoubleSortedDistinctMultiMap<Integer, Integer>;
begin
  { Copy from array tests }
  SetLength(IL, 5);

  IL[0] := KVPair<Integer, Integer>.Create(1, 11);
  IL[1] := KVPair<Integer, Integer>.Create(2, 21);
  IL[2] := KVPair<Integer, Integer>.Create(3, 31);
  IL[3] := KVPair<Integer, Integer>.Create(4, 41);
  IL[4] := KVPair<Integer, Integer>.Create(5, 51);

  DA := TDynamicArray<KVPair<Integer, Integer>>.Create(IL);
  FA := TFixedArray<KVPair<Integer, Integer>>.Create(IL);

  DAL := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(DA);
  FAL := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(FA);

  Check(DAL.Count = 5, 'Expected DAL.Length to be 5');
  Check(DAL[1].Single = 11, 'Expected DAL to contain 1=11');
  Check(DAL[2].Single = 21, 'Expected DAL to contain 2=21');
  Check(DAL[3].Single = 31, 'Expected DAL to contain 3=31');
  Check(DAL[4].Single = 41, 'Expected DAL to contain 4=41');
  Check(DAL[5].Single = 51, 'Expected DAL to contain 5=51');

  Check(FAL.Count = 5, 'Expected FAL.Length to be 5');
  Check(FAL[1].Single = 11, 'Expected FAL to contain 1=11');
  Check(FAL[2].Single = 21, 'Expected FAL to contain 2=21');
  Check(FAL[3].Single = 31, 'Expected FAL to contain 3=31');
  Check(FAL[4].Single = 41, 'Expected FAL to contain 4=41');
  Check(FAL[5].Single = 51, 'Expected FAL to contain 5=51');

  DAL.Free;
  FAL.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestCreationAndDestroy;
var
  Dict, Dict1  : TDoubleSortedDistinctMultiMap<Integer, Integer>;
  IL           : array of KVPair<Integer, Integer>;
begin
  { With default capacity }
  Dict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(10, 21);
  Dict.Add(30, 31);
  Dict.Add(40, 41);

  Check(Dict.Count = 4, 'DoubleSortedDistinctMultiMap count expected to be 4');

  Dict.Free();

  { With preset capacity }
  Dict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);
  Dict.Add(30, 41);

  Check(Dict.Count = 4, 'DoubleSortedDistinctMultiMap count expected to be 4');

  Dict.Free();

  { With Copy }
  Dict1 := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();

  Dict1.Add(101, 111);
  Dict1.Add(101, 211);
  Dict1.Add(101, 211);
  Dict1.Add(401, 411);

  Dict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(Dict1);

  Check(Dict.Count = 3, 'DoubleSortedDistinctMultiMap expected count must be 4');
  Check(Dict[101].Min = 111, 'DoubleSortedDistinctMultiMap expected value not found');
  Check(Dict[101].Max = 211, 'DoubleSortedDistinctMultiMap expected value not found');
  Check(Dict[401].Single = 411, 'DoubleSortedDistinctMultiMap expected value not found');

  Dict.Free();
  Dict1.Free();

  { Copy from array tests }
  SetLength(IL, 5);

  IL[0] := KVPair<Integer, Integer>.Create(1, 11);
  IL[1] := KVPair<Integer, Integer>.Create(1, 21);
  IL[2] := KVPair<Integer, Integer>.Create(1, 31);
  IL[3] := KVPair<Integer, Integer>.Create(4, 41);
  IL[4] := KVPair<Integer, Integer>.Create(5, 51);

  Dict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create(IL);

  Check(Dict.Count = 5, 'Dictionary count expected to be 5');

  Check(Dict[1].Ordered.ElementAt(0) = 11, 'Dict[1] expected to be 11');
  Check(Dict[1].Ordered.ElementAt(1) = 21, 'Dict[1] expected to be 21');
  Check(Dict[1].Ordered.ElementAt(2) = 31, 'Dict[1] expected to be 31');
  Check(Dict[4].Single = 41, 'Dict[4] expected to be 41');
  Check(Dict[5].Single = 51, 'Dict[5] expected to be 51');

  Dict.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestEnumerator;
var
  Dict : TDoubleSortedDistinctMultiMap<Integer, Integer>;
  X    : Integer;
  I    : KVPair<Integer, Integer>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(10, 21);
  Dict.Add(30, 31);

  X := 0;

  for I in Dict do
  begin
    if X = 0 then
       Check((I.Key = 10) and (I.Value = 11), 'Enumerator failed at 0!')
    else if X = 1 then
       Check((I.Key = 10) and (I.Value = 21), 'Enumerator failed at 1!')
    else if X = 2 then
       Check((I.Key = 30) and (I.Value = 31), 'Enumerator failed at 2!')
    else
       Fail('Enumerator failed!');

    Inc(X);
  end;

  { Test exceptions }

  CheckException(ECollectionChangedException,
    procedure()
    var
      I : KVPair<Integer, Integer>;
    begin
      for I in Dict do
      begin
        Dict.Remove(I.Key);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Dict.Count = 1, 'Enumerator failed too late');

  Dict.Free();
end;

procedure TTestDoubleSortedDistinctMultiMap.TestExceptions;
var
  Dict  : TDoubleSortedDistinctMultiMap<Integer, String>;
begin
  CheckException(ENilArgumentException,
    procedure()
    begin
      Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create(nil, TType<String>.Default);
      Dict.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create(TType<Integer>.Default, nil);
      Dict.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create(TType<Integer>.Default, TType<String>.Default, nil);
      Dict.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();
      Dict[1].Count;
    end,
    'EKeyNotFoundException not thrown in Lists[].'
  );
end;

procedure TTestDoubleSortedDistinctMultiMap.TestLists;
var
  Dict  : TDoubleSortedDistinctMultiMap<Integer, String>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(1, 'Mol');
  Dict.Add(2, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(3, 'Zol');

  Check(Dict[1].Count = 2, 'Dict[1].Count expected to be 2');
  Check(Dict[1].Min = 'Lol', 'Dict[1][0] expected to be "Lol"');
  Check(Dict[1].Max = 'Mol', 'Dict[1][1] expected to be "Mol"');

  Check(Dict[2].Count = 1, 'Dict[2].Count expected to be 1');
  Check(Dict[2].Single = 'Lol', 'Dict[2][0] expected to be "Lol"');

  Check(Dict[3].Count = 1, 'Dict[3].Count expected to be 1');
  Check(Dict[3].Single = 'Zol', 'Dict[3][0] expected to be "Zol"');

  Dict.Add(3, 'Mol');

  Check(Dict[1].Count = 2, 'Dict[1].Count expected to be 2');
  Check(Dict[1].Min = 'Lol', 'Dict[1][0] expected to be "Lol"');
  Check(Dict[1].Max = 'Mol', 'Dict[1][1] expected to be "Mol"');
  Check(Dict[2].Count = 1, 'Dict[2].Count expected to be 1');
  Check(Dict[2].Single = 'Lol', 'Dict[2][0] expected to be "Lol"');
  Check(Dict[3].Count = 2, 'Dict[3].Count expected to be 2');
  Check(Dict[3].Max = 'Zol', 'Dict[3][0] expected to be "Zol"');
  Check(Dict[3].Min = 'Mol', 'Dict[3][1] expected to be "Mol"');

  Dict.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestObjectVariant;
var
  ObjMM: TObjectDoubleSortedDistinctMultiMap<TTestObject, TTestObject>;
  TheKeyObject, TheValueObject: TTestObject;
  KeyDied, ValueDied: Boolean;
begin
  ObjMM := TObjectDoubleSortedDistinctMultiMap<TTestObject, TTestObject>.Create();
  Check(not ObjMM.OwnsKeys, 'OwnsKeys must be false!');
  Check(not ObjMM.OwnsValues, 'OwnsValues must be false!');

  TheKeyObject := TTestObject.Create(@KeyDied);
  TheValueObject := TTestObject.Create(@ValueDied);


  ObjMM.Add(TheKeyObject, TheValueObject);
  ObjMM.Clear;

  Check(not KeyDied, 'The key should not have been cleaned up!');
  Check(not ValueDied, 'The value should not have been cleaned up!');

  ObjMM.Add(TheKeyObject, TheValueObject);

  ObjMM.OwnsKeys := true;
  ObjMM.OwnsValues := true;

  Check(ObjMM.OwnsKeys, 'OwnsKeys must be true!');
  Check(ObjMM.OwnsValues, 'OwnsValues must be true!');

  ObjMM.Clear;

  Check(KeyDied, 'The key should have been cleaned up!');
  Check(ValueDied, 'The value should have been cleaned up!');

  ObjMM.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestTryGetValues;
var
  Dict: TDoubleSortedDistinctMultiMap<Integer, String>;
  LSet: IEnexCollection<String>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(1, 'Mol');
  Dict.Add(2, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(3, 'Zol');

  Check(Dict.TryGetValues(1, LSet), 'Expected to be able to get the values');

  Check(LSet.Count = 2, 'Dict[1].Count expected to be 2');
  Check(LSet.Min = 'Lol', 'Dict[1][0] expected to be "Lol"');
  Check(LSet.Max = 'Mol', 'Dict[1][1] expected to be "Mol"');

  Check(Dict.TryGetValues(2, LSet), 'Expected to be able to get the values');

  Check(LSet.Count = 1, 'Dict[2].Count expected to be 1');
  Check(LSet.Single = 'Lol', 'Dict[2][0] expected to be "Lol"');

  Check(Dict.TryGetValues(3, LSet), 'Expected to be able to get the values');

  Check(LSet.Count = 1, 'Dict[3].Count expected to be 1');
  Check(LSet.Single = 'Zol', 'Dict[3][0] expected to be "Zol"');

  Check(not Dict.TryGetValues(20, LSet), '(not) Expected to be able to get the values');

  Dict.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestTryGetValues2;
var
  Dict: TDoubleSortedDistinctMultiMap<Integer, String>;
  LSet: IEnexCollection<String>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(1, 'Mol');
  Dict.Add(2, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(3, 'Zol');

  LSet := Dict.TryGetValues(1);
  Check(not LSet.Empty, 'Expected to be able to get the values');
  Check(LSet.Count = 2, 'Dict[1].Count expected to be 2');
  Check(LSet.Min = 'Lol', 'Dict[1][0] expected to be "Lol"');
  Check(LSet.Max = 'Mol', 'Dict[1][1] expected to be "Mol"');

  LSet := Dict.TryGetValues(2);
  Check(not LSet.Empty, 'Expected to be able to get the values');
  Check(LSet.Count = 1, 'Dict[2].Count expected to be 1');
  Check(LSet.Single = 'Lol', 'Dict[2][0] expected to be "Lol"');

  LSet := Dict.TryGetValues(3);
  Check(not LSet.Empty, 'Expected to be able to get the values');
  Check(LSet.Count = 1, 'Dict[3].Count expected to be 1');
  Check(LSet.Single = 'Zol', 'Dict[3][0] expected to be "Zol"');

  LSet := Dict.TryGetValues(20);
  Check(LSet.Empty, '(not) Expected to be able to get the values');

  Dict.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestKeys;
var
  Dict  : TDoubleSortedDistinctMultiMap<Integer, String>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(1, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Kol');
  Dict.Add(4, 'Vol');

  Check((Dict.Keys.Count = 3), 'Dict.Keys.Count expected to be 3');

  Dict.Remove(4);

  Check((Dict.Keys.Count = 2), 'Dict.Keys.Count expected to be 2');

  Dict.Free;
end;

procedure TTestDoubleSortedDistinctMultiMap.TestValues;
var
  Dict  : TDoubleSortedDistinctMultiMap<Integer, String>;
begin
  Dict := TDoubleSortedDistinctMultiMap<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(1, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Kol');
  Dict.Add(5, 'Vol');

  Check(Dict.Values.Count = 4, 'Dict.Values.Count expected to be 4');

  Dict.Remove(1);

  Check(Dict.Values.Count = 3, 'Dict.Values.Count expected to be 3');

  Dict.Free;
end;

initialization
  TestFramework.RegisterTest(TTestDoubleSortedDistinctMultiMap.Suite);

end.
