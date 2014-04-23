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
unit Tests.SortedDictionary;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.List,
     DeHL.Arrays,
     DeHL.Tuples,
     DeHL.Collections.SortedDictionary;

type
  TTestSortedDictionary = class(TDeHLTestCase)
  published
    procedure TestCreationAndDestroy();
    procedure TestCreateWithDynFixArrays();
    procedure TestClearAddRemoveCount();
    procedure TestContainsKeyContainsValue();
    procedure TestItems();
    procedure TestValues();
    procedure TestTryGetValue();
    procedure TestKeys();
    procedure TestCopyTo();
    procedure TestValuesCopyTo();
    procedure TestKeysCopyTo();
    procedure TestEnumerator();
    procedure TestKeysEnumerator();
    procedure TestValuesEnumerator();
    procedure TestExceptions();
    procedure TestBigSize();
    procedure TestCorrectOrdering();

    procedure TestObjectVariant();

    procedure TestCleanup();
  end;

implementation

{ TTestSortedDictionary }

procedure TTestSortedDictionary.TestBigSize;
const
  NrElem = 10000;

var
  Dict : TSortedDictionary<Integer, Integer>;
  X : Integer;

  KSum, VSum, VVSum : UInt64;
begin
  KSum := 0;
  VSum := 0;
  Dict := TSortedDictionary<Integer, Integer>.Create();

  for X := 0 to NrElem do
  begin
    Dict.Add(X, X * 2);
    KSum := KSum + X;
    VSum := VSum + (X * 2);
  end;

  VVSum := VSum;

  Check(Dict.Count = NrElem + 1, 'Dictionary Count expected to be ' + IntToStr(NrElem + 1));

  for X in Dict.Keys do
  begin
    KSum := KSum - X;
    VVSum := VVSum - Dict[X];
  end;

  for X in Dict.Values do
  begin
    VSum := VSum - X;
  end;

  Check(KSum = 0, 'Dictionary key enumeration failed! Not all keys were found.');
  Check(VVSum = 0, 'Dictionary key/values enumeration failed! Not all values were found.');
  Check(VSum = 0, 'Dictionary values enumeration failed! Not all values were found.');

  Dict.Free;
  { -- check inverse }

  KSum := 0;
  VSum := 0;
  Dict := TSortedDictionary<Integer, Integer>.Create();

  for X := NrElem downto 0 do
  begin
    Dict.Add(X, X * 2);
    KSum := KSum + X;
    VSum := VSum + (X * 2);
  end;

  VVSum := VSum;

  Check(Dict.Count = NrElem + 1, 'Dictionary Count expected to be ' + IntToStr(NrElem + 1));

  for X in Dict.Keys do
  begin
    KSum := KSum - X;
    VVSum := VVSum - Dict[X];
  end;

  for X in Dict.Values do
  begin
    VSum := VSum - X;
  end;

  Check(KSum = 0, 'Dictionary key enumeration failed! Not all keys were found.');
  Check(VVSum = 0, 'Dictionary key/values enumeration failed! Not all values were found.');
  Check(VSum = 0, 'Dictionary values enumeration failed! Not all values were found.');


  Dict.Free;
end;

procedure TTestSortedDictionary.TestCleanup;
var
  ADict : TSortedDictionary<Integer, Integer>;
  KeyCache, ValCache: Integer;
  X: KVPair<Integer, Integer>;
  I: Integer;
begin
  KeyCache := 0;
  ValCache := 0;

  { Create a new ADict }
  ADict := TSortedDictionary<Integer, Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(KeyCache, Arg1);
    end),
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ValCache, Arg1);
    end)
  );

  { Add some elements }
  ADict.Add(1, 1);
  ADict.Add(2, 2);
  ADict.Add(4, 4);
  ADict.Add(8, 8);

  Check((ValCache + KeyCache) = 0, 'Nothing should have be cleaned up yet!');

  ADict.Remove(1);
  ADict.Remove(2);

  Check(ValCache = 3, 'Expected value cache = 3');
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

  Check(ValCache = 12, 'Expected value cache = 12');
  Check(KeyCache = 12, 'Expected key cache = 12');

  ValCache := 0;
  KeyCache := 0;

  ADict.Add(1, 1);
  ADict.Add(2, 2);
  ADict.Add(4, 4);
  ADict.Add(8, 8);

  ADict.Free;

  Check(ValCache = 15, 'Expected value cache = 15');
  Check(KeyCache = 15, 'Expected key cache = 15');
end;

procedure TTestSortedDictionary.TestClearAddRemoveCount;
var
  Dict : TSortedDictionary<Integer, String>;

begin
  Dict := TSortedDictionary<Integer, String>.Create();

  { Add items }
  Dict.Add(10, 'String 10');
  Dict.Add(20, 'String 20');
  Dict.Add(30, 'String 30');

  Check((Dict.Count = 3) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 3');

  Dict.Add(15, 'String 15');
  Dict.Add(25, 'String 25');
  Dict.Add(35, 'String 35');

  Check((Dict.Count = 6) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 6');

  Dict.Remove(10);
  Dict.Remove(15);

  Check((Dict.Count = 4) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 4');

  Dict.Remove(25);

  Check((Dict.Count = 3) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 3');

  Dict.Clear();

  Check((Dict.Count = 0) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 0');

  Dict.Add(15, 'String 15');

  Check((Dict.Count = 1) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 1');

  Dict.Remove(15);

  Check((Dict.Count = 0) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 0');

  Dict.Free();
end;

procedure TTestSortedDictionary.TestContainsKeyContainsValue;
var
  Dict : TSortedDictionary<Integer, String>;
begin
  Dict := TSortedDictionary<Integer, String>.Create();

  { Add items }
  Dict.Add(10, 'String 10');
  Dict.Add(20, 'String 20');
  Dict.Add(30, 'String 30');

  Check(Dict.ContainsKey(10), 'Dictionary expected to contain key 10.');
  Check(Dict.ContainsKey(20), 'Dictionary expected to contain key 20.');
  Check(Dict.ContainsKey(30), 'Dictionary expected to contain key 30.');
  Check(not Dict.ContainsKey(40), 'Dictionary not expected to contain key 40.');

  Check(Dict.ContainsValue('String 10'), 'Dictionary expected to contain value "String 10".');
  Check(Dict.ContainsValue('String 20'), 'Dictionary expected to contain value "String 20".');
  Check(Dict.ContainsValue('String 30'), 'Dictionary expected to contain value "String 30".');
  Check(not Dict.ContainsValue('String 40'), 'Dictionary not expected to contain value "String 40".');

  Dict.Remove(30);

  Check(not Dict.ContainsValue('String 30'), 'Dictionary not expected to contain value "String 30".');
  Check(not Dict.ContainsKey(30), 'Dictionary not expected to contain key 30.');

  Dict.Free();
end;

procedure TTestSortedDictionary.TestKeysCopyTo;
var
  Dict  : TSortedDictionary<Integer, String>;
  IL    : array of Integer;
begin
  Dict := TSortedDictionary<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(2, '2');
  Dict.Add(3, '3');
  Dict.Add(4, '4');
  Dict.Add(5, '5');

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

procedure TTestSortedDictionary.TestKeysEnumerator;
var
  Dict : TSortedDictionary<Integer, Integer>;
  X    : Integer;
  I    : Integer;
begin
  Dict := TSortedDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);

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

procedure TTestSortedDictionary.TestObjectVariant;
var
  ObjDict: TObjectSortedDictionary<TTestObject, TTestObject>;
  TheKeyObject, TheValueObject: TTestObject;
  KeyDied, ValueDied: Boolean;
begin
  ObjDict := TObjectSortedDictionary<TTestObject, TTestObject>.Create();
  Check(not ObjDict.OwnsKeys, 'OwnsKeys must be false!');
  Check(not ObjDict.OwnsValues, 'OwnsValues must be false!');

  TheKeyObject := TTestObject.Create(@KeyDied);
  TheValueObject := TTestObject.Create(@ValueDied);


  ObjDict.Add(TheKeyObject, TheValueObject);
  ObjDict.Clear;

  Check(not KeyDied, 'The key should not have been cleaned up!');
  Check(not ValueDied, 'The value should not have been cleaned up!');

  ObjDict.Add(TheKeyObject, TheValueObject);

  ObjDict.OwnsKeys := true;
  ObjDict.OwnsValues := true;

  Check(ObjDict.OwnsKeys, 'OwnsKeys must be true!');
  Check(ObjDict.OwnsValues, 'OwnsValues must be true!');

  ObjDict.Clear;

  Check(KeyDied, 'The key should have been cleaned up!');
  Check(ValueDied, 'The value should have been cleaned up!');

  ObjDict.Free;
end;

procedure TTestSortedDictionary.TestTryGetValue;
var
  Dict  : TSortedDictionary<Integer, String>;
  Value : String;
begin
  Dict := TSortedDictionary<Integer, String>.Create();
  Dict.Add(1, 'One');
  Dict.Add(2, 'Two');
  Dict.Add(3, 'Three');

  Check(Dict.TryGetValue(1, Value), '1 should have been present in the dictionary!');
  Check(Value = 'One', '1 should have been linked to "One"!');

  Check(Dict.TryGetValue(2, Value), '2 should have been present in the dictionary!');
  Check(Value = 'Two', '2 should have been linked to "Two"!');

  Check(not Dict.TryGetValue(4, Value), '4 should not have been present in the dictionary!');

  Check(Dict.TryGetValue(3, Value), '3 should have been present in the dictionary!');
  Check(Value = 'Three', '3 should have been linked to "Three"!');

  Dict.Free;
end;

procedure TTestSortedDictionary.TestCopyTo;
var
  Dict  : TSortedDictionary<Integer, String>;
  IL    : array of KVPair<Integer, String>;
begin
  Dict := TSortedDictionary<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(2, '2');
  Dict.Add(3, '3');
  Dict.Add(4, '4');
  Dict.Add(5, '5');
  Dict.Add(6, '5');

  { Check the copy }
  SetLength(IL, 6);
  Dict.CopyTo(IL);

  Check((IL[0].Key = 1) and (IL[0].Value = '1'), 'Element 0 in the new array is wrong!');
  Check((IL[1].Key = 2) and (IL[1].Value = '2'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 3) and (IL[2].Value = '3'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 4) and (IL[3].Value = '4'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 5) and (IL[4].Value = '5'), 'Element 4 in the new array is wrong!');
  Check((IL[5].Key = 6) and (IL[5].Value = '5'), 'Element 5 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 7);
  Dict.CopyTo(IL, 1);

  Check((IL[1].Key = 1) and (IL[1].Value = '1'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 2) and (IL[2].Value = '2'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 3) and (IL[3].Value = '3'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 4) and (IL[4].Value = '4'), 'Element 4 in the new array is wrong!');
  Check((IL[5].Key = 5) and (IL[5].Value = '5'), 'Element 5 in the new array is wrong!');
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

procedure TTestSortedDictionary.TestCorrectOrdering;
const
  MaxNr = 1000;
  MaxRnd = 10000;

var
  AscDict, DescDict : TSortedDictionary<Integer, Integer>;
  I, PI, X : Integer;

  Max, Min: Integer;
begin
  { One ascending }
  AscDict := TSortedDictionary<Integer, Integer>.Create(true);

  { ... and one not }
  DescDict := TSortedDictionary<Integer, Integer>.Create(false);

  Randomize;

  Max := -1;
  Min := MaxRnd;

  { Fill dictionaries with filth }
  for I := 0 to MaxNr - 1 do
  begin
    X := Random(MaxRnd);

    if X > Max then
      Max := X;

    if X < Min then
      Min := X;

    AscDict[X] := I;
    DescDict[X] := I;
  end;

  Check(AscDict.MinKey = Min, 'Expected Ascendent Dictionary MinKey = Min');
  Check(AscDict.MaxKey = Max, 'Expected Ascendent Dictionary MaxKey = Max');
  Check(DescDict.MinKey = Min, 'Expected Ascendent Dictionary MinKey = Min');
  Check(DescDict.MaxKey = Max, 'Expected Ascendent Dictionary MaxKey = Max');

  { Enumerate the ascending and check that each key is bigger than the prev one }
  PI := -1;
  for I in AscDict.Keys do
  begin
    Check(I > PI, 'Failed enumeration! Expected that -- always: Vi > Vi-1 for ascending sorted dictionary.');
    PI := I;
  end;

  { Enumerate the ascending and check that each key is lower than the prev one }
  PI := MaxRnd;
  for I in DescDict.Keys do
  begin
    Check(I < PI, 'Failed enumeration! Expected that -- always: Vi-1 > Vi for descending sorted dictionary.');
    PI := I;
  end;

  AscDict.Free;
  DescDict.Free;
end;

procedure TTestSortedDictionary.TestValuesEnumerator;
var
  Dict : TSortedDictionary<Integer, Integer>;
  X    : Integer;
  I    : Integer;
begin
  Dict := TSortedDictionary<Integer, Integer>.Create();

  Dict.Add(10, 21);
  Dict.Add(20, 21);
  Dict.Add(30, 31);

  X := 0;

  for I in Dict.Values do
  begin
    if X = 0 then
       Check(I = 21, 'Enumerator failed at 0!')
    else if X = 1 then
       Check(I = 21, 'Enumerator failed at 1!')
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

procedure TTestSortedDictionary.TestValuesCopyTo;
var
  Dict  : TSortedDictionary<Integer, String>;
  IL    : array of String;
begin
  Dict := TSortedDictionary<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(2, '2');
  Dict.Add(3, '3');
  Dict.Add(4, '4');
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

procedure TTestSortedDictionary.TestCreateWithDynFixArrays;
var
  IL: array of KVPair<Integer, Integer>;
  DA: TDynamicArray<KVPair<Integer, Integer>>;
  FA: TFixedArray<KVPair<Integer, Integer>>;

  DAL: TSortedDictionary<Integer, Integer>;
  FAL: TSortedDictionary<Integer, Integer>;
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

  DAL := TSortedDictionary<Integer, Integer>.Create(DA);
  FAL := TSortedDictionary<Integer, Integer>.Create(FA);

  Check(DAL.Count = 5, 'Expected DAL.Length to be 5');
  Check(DAL[1] = 11, 'Expected DAL to contain 1=11');
  Check(DAL[2] = 21, 'Expected DAL to contain 2=21');
  Check(DAL[3] = 31, 'Expected DAL to contain 3=31');
  Check(DAL[4] = 41, 'Expected DAL to contain 4=41');
  Check(DAL[5] = 51, 'Expected DAL to contain 5=51');

  Check(FAL.Count = 5, 'Expected FAL.Length to be 5');
  Check(FAL[1] = 11, 'Expected FAL to contain 1=11');
  Check(FAL[2] = 21, 'Expected FAL to contain 2=21');
  Check(FAL[3] = 31, 'Expected FAL to contain 3=31');
  Check(FAL[4] = 41, 'Expected FAL to contain 4=41');
  Check(FAL[5] = 51, 'Expected FAL to contain 5=51');

  DAL.Free;
  FAL.Free;
end;

procedure TTestSortedDictionary.TestCreationAndDestroy;
var
  Dict, Dict1  : TSortedDictionary<Integer, Integer>;
  IL           : array of KVPair<Integer, Integer>;
begin
  { With default capacity }
  Dict := TSortedDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);
  Dict.Add(40, 41);

  Check(Dict.Count = 4, 'Dictionary count expected to be 4');

  Dict.Free();

  { With Copy }
  Dict1 := TSortedDictionary<Integer, Integer>.Create();

  Dict1.Add(101, 111);
  Dict1.Add(201, 211);
  Dict1.Add(301, 311);
  Dict1.Add(401, 411);

  Dict := TSortedDictionary<Integer, Integer>.Create(Dict1);

  Check(Dict.Count = 4, 'Dictionary expected count must be 4');
  Check(Dict[101] = 111, 'Dictionary expected value not found');
  Check(Dict[201] = 211, 'Dictionary expected value not found');
  Check(Dict[301] = 311, 'Dictionary expected value not found');
  Check(Dict[401] = 411, 'Dictionary expected value not found');

  Dict.Free();
  Dict1.Free();

  { Copy from array tests }
  SetLength(IL, 5);

  IL[0] := KVPair<Integer, Integer>.Create(1, 11);
  IL[1] := KVPair<Integer, Integer>.Create(2, 21);
  IL[2] := KVPair<Integer, Integer>.Create(3, 31);
  IL[3] := KVPair<Integer, Integer>.Create(4, 41);
  IL[4] := KVPair<Integer, Integer>.Create(5, 51);

  Dict := TSortedDictionary<Integer, Integer>.Create(IL);

  Check(Dict.Count = 5, 'Dictionary count expected to be 5');

  Check(Dict[1] = 11, 'Dict[1] expected to be 11');
  Check(Dict[2] = 21, 'Dict[1] expected to be 21');
  Check(Dict[3] = 31, 'Dict[1] expected to be 31');
  Check(Dict[4] = 41, 'Dict[1] expected to be 41');
  Check(Dict[5] = 51, 'Dict[1] expected to be 51');

  Dict.Free;
end;

procedure TTestSortedDictionary.TestEnumerator;
var
  Dict : TSortedDictionary<Integer, Integer>;
  X    : Integer;
  I    : KVPair<Integer, Integer>;
begin
  Dict := TSortedDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);

  X := 0;

  for I in Dict do
  begin
    if X = 0 then
       Check((I.Key = 10) and (I.Value = 11), 'Enumerator failed at 0!')
    else if X = 1 then
       Check((I.Key = 20) and (I.Value = 21), 'Enumerator failed at 1!')
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

  Check(Dict.Count = 2, 'Enumerator failed too late');

  Dict.Free();
end;

procedure TTestSortedDictionary.TestExceptions;
var
  Dict  : TSortedDictionary<Integer, String>;
begin
  CheckException(ENilArgumentException,
    procedure()
    begin
      Dict := TSortedDictionary<Integer, String>.Create(nil, TType<String>.Default);
      Dict.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Dict := TSortedDictionary<Integer, String>.Create(TType<Integer>.Default, nil);
      Dict.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Dict := TSortedDictionary<Integer, String>.Create(TType<Integer>.Default, TType<String>.Default, nil);
      Dict.Free();
    end,
    'ENilArgumentException not thrown in constructor (nil enum).'
  );

  Dict := TSortedDictionary<Integer, String>.Create();
  Dict.Add(1, '1');

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.Add(1, '2');
    end,
    'EDuplicateKeyException not thrown in Add.'
  );

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.Add(KVPair<Integer, String>.Create(1, '6'));
    end,
    'EDuplicateKeyException not thrown in Add(Pair).'
  );

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      Dict[2];
    end,
    'EKeyNotFoundException not thrown in Items[].'
  );
end;

procedure TTestSortedDictionary.TestItems;
var
  Dict  : TSortedDictionary<Integer, String>;
begin
  Dict := TSortedDictionary<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(2, 'Lol');
  Dict.Add(3, 'Zol');

  Check(Dict[1] = 'Lol', 'Dict[1] expected to be "Lol"');
  Check(Dict[2] = 'Lol', 'Dict[2] expected to be "Lol"');
  Check(Dict[3] = 'Zol', 'Dict[3] expected to be "Zol"');

  Dict[1] := 'Mol';

  Check(Dict[1] = 'Mol', 'Dict[1] expected to be "Mol"');
  Check(Dict[2] = 'Lol', 'Dict[2] expected to be "Lol"');
  Check(Dict[3] = 'Zol', 'Dict[3] expected to be "Zol"');

  Dict.Free;
end;

procedure TTestSortedDictionary.TestKeys;
var
  Dict  : TSortedDictionary<Integer, String>;
begin
  Dict := TSortedDictionary<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(2, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Kol');
  Dict.Add(5, 'Vol');

  Check((Dict.Keys.Count = Dict.Count) and (Dict.Count = 5), 'Dict.Keys.Count expected to be 5');

  Dict.Remove(5);

  Check((Dict.Keys.Count = Dict.Count) and (Dict.Count = 4), 'Dict.Keys.Count expected to be 4');

  Dict.Free;
end;

procedure TTestSortedDictionary.TestValues;
var
  Dict  : TSortedDictionary<Integer, String>;
begin
  Dict := TSortedDictionary<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(2, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Kol');
  Dict.Add(5, 'Vol');

  Check(Dict.Values.Count = 5, 'Dict.Values.Count expected to be 4');

  Dict.Remove(1);

  Check(Dict.Values.Count = 4, 'Dict.Values.Count expected to be 4');

  Dict.Free;
end;

initialization
  TestFramework.RegisterTest(TTestSortedDictionary.Suite);

end.
