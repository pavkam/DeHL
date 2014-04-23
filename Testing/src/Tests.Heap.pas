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
unit Tests.Heap;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHl.Collections.Base,
     DeHL.Arrays,
     DeHL.Collections.Heap;

type
  TTestHeap = class(TDeHLTestCase)
  published
    procedure TestCreationAndDestroy();
    procedure TestClear();
    procedure TestAdd();
    procedure TestExtract();
    procedure TestRemove();
    procedure TestTryGetValue();
    procedure TestContains();
    procedure TestCount();
    procedure TestCapacity();
    procedure TestItems();
    procedure TestShrink();
    procedure TestGrow();
    procedure TestCopyTo();
    procedure TestEnumerator();
    procedure TestHardCore();

    procedure TestObjectVariant();
    procedure TestCleanup();
  end;

implementation

{ TTestHeap }

procedure TTestHeap.TestAdd;
var
  LHeap: THeap<Integer>;
  LId: Cardinal;
begin
  LHeap := THeap<Integer>.Create();

  LId := LHeap.Add(100);
  Check(LHeap[LId] = 100, 'Expected 100 to be added to the heap!');

  LId := LHeap.Add(200);
  Check(LHeap[LId] = 200, 'Expected 100 to be added to the heap!');

  LId := LHeap.Add(500);
  Check(LHeap[LId] = 500, 'Expected 100 to be added to the heap!');

  Check(LHeap.Count = 3, 'Expetced count of 3');

  LHeap.Free;
end;

procedure TTestHeap.TestCapacity;
var
  LHeap: THeap<Integer>;
  I: Integer;
begin
  LHeap := THeap<Integer>.Create(50);

  Check(LHeap.Capacity = 50, 'Expected capacity of 50');

  for I := 0 to 50 do
    LHeap.Add(I);

  Check(LHeap.Capacity = 100, 'Expected capacity of 100');

  LHeap.Free;
end;

procedure TTestHeap.TestCleanup;
var
  LHeap : THeap<Integer>;
  ElemCache: Integer;
  I: Integer;
  L1, L2: Cardinal;
begin
  ElemCache := 0;

  { Create a new LHeap }
  LHeap := THeap<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end)
  );

  { Add some elements }
  L1 := LHeap.Add(1);
  L2 := LHeap.Add(2);
  LHeap.Add(4);
  LHeap.Add(8);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  LHeap.Extract(L1);
  LHeap.Extract(L2);
  LHeap.TryGetValue(L1, I);

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  { Simply walk the LHeap }
  for I in LHeap do
    if I > 0 then;

  Check(ElemCache = 0, 'Nothing should have be cleaned up yet!');

  LHeap.Clear();
  Check(ElemCache = 12, 'Expected cache = 12');

  ElemCache := 0;

  L1 := LHeap.Add(1);
  LHeap.Add(2);
  LHeap.Add(4);
  LHeap.Add(8);

  LHeap.Remove(L1);
  Check(ElemCache = 1, 'Expected cache = 1');

  ElemCache := 0;

  LHeap.Free;
  Check(ElemCache = 14, 'Expected cache = 14');
end;

procedure TTestHeap.TestClear;
var
  LHeap: THeap<Integer>;
  I: Integer;
begin
  LHeap := THeap<Integer>.Create();

  for I := 0 to 50 do
    LHeap.Add(I);

  Check(LHeap.Count = 51, 'Expected count of 51');
  LHeap.Clear;

  Check(LHeap.Count = 0, 'Expected count of 0');

  LHeap.Free;
end;

procedure TTestHeap.TestContains;
var
  LHeap: THeap<Integer>;
  L1: Cardinal;
begin
  LHeap := THeap<Integer>.Create(30);

  L1 := LHeap.Add(1);
  LHeap.Add(2);
  LHeap.Add(3);

  Check(LHeap.Contains(L1), 'Expected L1 and success.');
  Check(LHeap.Contains(L1), 'Expected L2 and success.');
  Check(LHeap.Contains(L1), 'Expected L3 and success.');
  Check(not LHeap.Contains(100), 'Expected failure for 100.');

  LHeap.Remove(L1);
  Check(not LHeap.Contains(L1), 'Expected failure for L1.');

  LHeap.Free;
end;

procedure TTestHeap.TestCopyTo;
var
  LHeap  : THeap<Integer>;
  IL    : array of Integer;
begin
  LHeap := THeap<Integer>.Create();

  { Add elements to the LHeap }
  LHeap.Add(1);
  LHeap.Add(2);
  LHeap.Add(3);
  LHeap.Add(4);
  LHeap.Add(5);

  { Check the copy }
  SetLength(IL, 5);
  LHeap.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 2, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  LHeap.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 2, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 5, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin LHeap.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin LHeap.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  LHeap.Free();
end;

procedure TTestHeap.TestCount;
var
  LHeap: THeap<Integer>;
  I: Integer;
begin
  LHeap := THeap<Integer>.Create();

  for I := 0 to 50 do
  begin
    LHeap.Add(I);
    Check(LHeap.Count = I + 1, 'Expected count of ' + IntToStr(I + 1));
  end;

  LHeap.Free;
end;

procedure TTestHeap.TestCreationAndDestroy;
var
  LHeap: THeap<Integer>;
begin
  { Simple Creation }
  LHeap := THeap<Integer>.Create();
  Check(LHeap.Count = 0, 'Wrong creation state');
  LHeap.Free;

  { Capacity-based Creation }
  LHeap := THeap<Integer>.Create(111);
  Check(LHeap.Count = 0, 'Wrong creation state');
  Check(LHeap.Capacity = 111, 'Wrong creation state (cap)');
  LHeap.Free;

  { Simple Creation (TType) }
  LHeap := THeap<Integer>.Create(TType<Integer>.Default);
  Check(LHeap.Count = 0, 'Wrong creation state');
  LHeap.Free;

  CheckException(ENilArgumentException,
    procedure()
    begin
      LHeap := THeap<Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );

  { Capacity-based Creation (TType) }
  LHeap := THeap<Integer>.Create(TType<Integer>.Default, 111);
  Check(LHeap.Count = 0, 'Wrong creation state');
  Check(LHeap.Capacity = 111, 'Wrong creation state (cap)');
  LHeap.Free;

  CheckException(ENilArgumentException,
    procedure()
    begin
      LHeap := THeap<Integer>.Create(nil, 100);
    end,
    'ENilArgumentException not thrown in constructor (nil comparer).'
  );
end;

procedure TTestHeap.TestEnumerator;
var
  LHeap: THeap<Integer>;
  I, X, Y: Integer;
begin
  LHeap := THeap<Integer>.Create();

  Y := LHeap.Add(10);
  LHeap.Add(20);
  LHeap.Add(30);

  X := 0;

  for I in LHeap do
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
      I: Integer;
    begin
      for I in LHeap do
      begin
        if I > 0 then LHeap.Remove(Y);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(LHeap.Count = 2, 'Enumerator failed too late');

  LHeap.Free();
end;

procedure TTestHeap.TestExtract;
var
  LHeap: THeap<Integer>;
  L1, L2, L3: Cardinal;
begin
  LHeap := THeap<Integer>.Create();

  L1 := LHeap.Add(1);
  L2 := LHeap.Add(2);
  L3 := LHeap.Add(3);

  Check(LHeap.Extract(L3) = 3, 'Expected 3');

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      LHeap.Extract(L3);
    end,
    'EKeyNotFoundException not thrown in Extract'
  );

  Check(LHeap.Extract(L2) = 2, 'Expected 2');
  Check(LHeap.Extract(L1) = 1, 'Expected 1');

  Check(LHeap.Count = 0, 'Expected count of 0');
  LHeap.Free;
end;

procedure TTestHeap.TestGrow;
var
  LHeap: THeap<Integer>;
begin
  LHeap := THeap<Integer>.Create(50);
  Check(LHeap.Capacity = 50, 'Expected capacity of 50');

  LHeap.Grow;
  Check(LHeap.Capacity = 100, 'Expected capacity of 100');

  LHeap.Grow;
  Check(LHeap.Capacity = 200, 'Expected capacity of 200');

  LHeap.Free;
end;

procedure TTestHeap.TestHardCore;
const
  MaxTries = 10000;

var
  LHeap: THeap<Integer>;
  I, V, LSum: Integer;
begin
  LHeap := THeap<Integer>.Create(2);
  LSum := 0;

  { Do a large number of tries before seeing if all went fine }
  for I := 0 to MaxTries - 1 do
  begin
    if Random(2) = 0 then
    begin
      LHeap.Add(I);
      LSum := LSum + I;
    end else
    begin
      V := Random(LHeap.Capacity);

      if LHeap.Contains(V) then
        LSum := LSum - LHeap.Extract(V);
    end;
  end;

  { Now check what is left inside and calculate the remains }
  for V in LHeap do
    LSum := LSum - V;

  Check(LSum = 0, 'The big crunching failed!');

  LHeap.Free;
end;

procedure TTestHeap.TestItems;
var
  LHeap: THeap<Integer>;
  L1, L2, L3: Cardinal;
begin
  LHeap := THeap<Integer>.Create();

  L1 := LHeap.Add(0);
  L2 := LHeap.Add(-50);
  L3 := LHeap.Add(-100);

  Check(LHeap[L1] = 0, 'Expected 0 for L1');
  Check(LHeap[L2] = -50, 'Expected -50 for L2');
  Check(LHeap[L3] = -100, 'Expected -100 for L3');

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      if LHeap[30] = 0 then;
    end,
    'EKeyNotFoundException not thrown in Items[]'
  );

  LHeap[L1] := 1;
  Check(LHeap[L1] = 1, 'Expected 1 for L1');

  LHeap.Free;
end;

procedure TTestHeap.TestObjectVariant;
var
  ObjHeap: TObjectHeap<TTestObject>;
  TheObject: TTestObject;
  ObjectDied: Boolean;
begin
  ObjHeap := TObjectHeap<TTestObject>.Create();
  Check(not ObjHeap.OwnsObjects, 'OwnsObjects must be false!');

  TheObject := TTestObject.Create(@ObjectDied);
  ObjHeap.Add(TheObject);
  ObjHeap.Clear;

  Check(not ObjectDied, 'The object should not have been cleaned up!');
  ObjHeap.Add(TheObject);
  ObjHeap.OwnsObjects := true;
  Check(ObjHeap.OwnsObjects, 'OwnsObjects must be true!');

  ObjHeap.Clear;

  Check(ObjectDied, 'The object should have been cleaned up!');
  ObjHeap.Free;
end;

procedure TTestHeap.TestRemove;
var
  LHeap: THeap<Integer>;
  L1, L2, L3: Cardinal;
begin
  LHeap := THeap<Integer>.Create();

  L1 := LHeap.Add(1);
  L2 := LHeap.Add(2);
  L3 := LHeap.Add(3);

  LHeap.Remove(L3);
  Check(LHeap.Count = 2, 'Expected count of 2');

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      LHeap.Remove(L3);
    end,
    'EKeyNotFoundException not thrown in Extract'
  );

  Check(LHeap[L2] = 2, 'Expected 2');
  Check(LHeap[L1] = 1, 'Expected 1');

  LHeap.Remove(L2);
  LHeap.Remove(L1);

  Check(LHeap.Count = 0, 'Expected count of 0');
  LHeap.Free;
end;

procedure TTestHeap.TestShrink;
var
  LHeap: THeap<Integer>;
begin
  LHeap := THeap<Integer>.Create(30);

  LHeap.Shrink;
  Check(LHeap.Capacity = 0, 'capacity should be 0');

  LHeap.Add(1);
  LHeap.Shrink;
  Check(LHeap.Capacity = 1, 'capacity should be 1');

  LHeap.Grow;
  LHeap.Shrink;
  Check(LHeap.Capacity = 1, 'capacity should be 1');

  LHeap.Free;
end;

procedure TTestHeap.TestTryGetValue;
var
  LHeap: THeap<Integer>;
  L1, L2, L3: Cardinal;
  I: Integer;
begin
  LHeap := THeap<Integer>.Create(30);

  L1 := LHeap.Add(1);
  L2 := LHeap.Add(2);
  L3 := LHeap.Add(3);

  Check(LHeap.TryGetValue(L1, I) and (I = 1), 'Expected 1 and success.');
  Check(LHeap.TryGetValue(L2, I) and (I = 2), 'Expected 2 and success.');
  Check(LHeap.TryGetValue(L3, I) and (I = 3), 'Expected 3 and success.');

  Check(not LHeap.TryGetValue(100, I), 'Expected failure for 100.');

  LHeap.Free;
end;

initialization
  TestFramework.RegisterTest(TTestHeap.Suite);

end.
