(*
* Copyright (c) 2008, Susnea Andrei
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
* THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

unit Tests.Map;
interface
uses SysUtils, TestFramework,
     HelperLib.TypeSupport,
     HelperLib.Collections.Dictionary,
     HelperLib.Collections.KeyValuePair,
     HelperLib.Collections.Map,
     HelperLib.Collections.Exceptions;

type
 TExceptionClosure = reference to procedure;
 TClassOfException = class of Exception;

 TTestMap = class(TTestCase)
 private
   procedure CheckException(ExType : TClassOfException; Proc : TExceptionClosure; const Msg : String);

 published
   procedure TestCreationAndDestroy();
   procedure TestInsertAddRemoveClearCount();
   procedure TestContainsFindItems();
   procedure TestCopyTo();
   procedure TestEnumerator();
   procedure TestExceptions();
   procedure TestBigCounts();
 end;

implementation

{ TTestQueue }

procedure TTestMap.CheckException(ExType: TClassOfException;
  Proc: TExceptionClosure; const Msg: String);
var
  bWasEx : Boolean;
begin
  bWasEx := False;

  try
    { Cannot self-link }
    Proc();
  except
    on E : Exception do
    begin
       if E is ExType then
          bWasEx := True;
    end;
  end;

  Check(bWasEx, Msg);
end;


procedure TTestMap.TestBigCounts;
const
  NrCount = 1000;

var
  Map  : HMap<Integer, Integer>;
  I, X : Integer;
  KV   : HKeyValuePair<Integer, Integer>;
  CIn, SumV, SumK  : Int64;
begin
  Map := HMap<Integer, Integer>.Create();

  Randomize;

  CIn := 0;
  SumV := 0;
  SumK := 0;

  for I := 0 to NrCount - 1 do
  begin
    X := Random(MaxInt);

    if not Map.Contains(X) then
    begin
      Map.Insert(X, I);
      Inc(CIn);

      SumV := SumV + I;
      SumK := SumK + X;
    end;
  end;

  Check(Map.Count = CIn, 'Expected count to be ' + IntToStr(CIn));

  for I := 0 to Map.Count - 1 do
  begin
    KV := Map[I];

    SumV := SumV - KV.Value;
    SumK := SumK - KV.Key;
  end;

  Check(SumK = 0, 'Expectency to cover all keys failed!');
  Check(SumV = 0, 'Expectency to cover all values failed!');

  Map.Free;
end;

procedure TTestMap.TestContainsFindItems;
var
  Map  : HMap <String, Integer>;
begin
  Map := HMap<String, Integer>.Create();

  { Add some stuff }
  Map.Insert('Key 1', 1);
  Map.Insert('Key 2', 2);
  Map.Insert('Key 3', 3);
  Map.Insert('Key 4', 4);
  Map.Insert('Key 5', 5);

  { First checks }
  Check(Map.Contains('Key 1'), 'Map expected to contain "Key 1"');
  Check(Map.Contains('Key 2'), 'Map expected to contain "Key 2"');
  Check(Map.Contains('Key 3'), 'Map expected to contain "Key 3"');
  Check(Map.Contains('Key 4'), 'Map expected to contain "Key 4"');
  Check(Map.Contains('Key 5'), 'Map expected to contain "Key 5"');
  Check(not Map.Contains('Key 6'), 'Map expected not to contain "Key 6"');

  { Indexer }
  Check(Map[0].Key = 'Key 1', 'Map[0] expected to be "Key 1"');
  Check(Map[1].Key = 'Key 2', 'Map[1] expected to be "Key 2"');
  Check(Map[2].Key = 'Key 3', 'Map[2] expected to be "Key 3"');
  Check(Map[3].Key = 'Key 4', 'Map[3] expected to be "Key 4"');
  Check(Map[4].Key = 'Key 5', 'Map[4] expected to be "Key 5"');

  { Find checks }
  Check(Map.Find('Key 1') = 1, 'Map expected to find "Key 1" = 1');
  Check(Map.Find('Key 2') = 2, 'Map expected to find "Key 2" = 2');
  Check(Map.Find('Key 3') = 3, 'Map expected to find "Key 3" = 3');
  Check(Map.Find('Key 4') = 4, 'Map expected to find "Key 4" = 4');
  Check(Map.Find('Key 5') = 5, 'Map expected to find "Key 5" = 5');

  Map.Free;
end;

procedure TTestMap.TestCopyTo;
var
  Map     : HMap <Integer, String>;
  IL      : array of HKeyValuePair<Integer, String>;
begin
  Map := HMap<Integer, String>.Create();

  Map.Insert(4, '4');
  Map.Insert(1, '1');
  Map.Insert(89, '89');
  Map.Insert(7, '7');
  Map.Insert(123, '123');

  { Check the copy }
  SetLength(IL, 5);
  Map.CopyTo(IL);


  Check((IL[0].Key = 4) and (IL[0].Value = '4'), 'Element 0 in the new array is wrong!');
  Check((IL[1].Key = 1) and (IL[1].Value = '1'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 89) and (IL[2].Value = '89'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 7) and (IL[3].Value = '7'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 123) and (IL[4].Value = '123'), 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  Map.CopyTo(IL, 1);

  Check((IL[1].Key = 4) and (IL[1].Value = '4'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 1) and (IL[2].Value = '1'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 89) and (IL[3].Value = '89'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 7) and (IL[4].Value = '7'), 'Element 4 in the new array is wrong!');
  Check((IL[5].Key = 123) and (IL[5].Value = '123'), 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfRangeException,
    procedure() begin Map.CopyTo(IL); end,
    'EArgumentOutOfRangeException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfRangeException,
    procedure() begin Map.CopyTo(IL, 1); end,
    'EArgumentOutOfRangeException not thrown in CopyTo (too small size +1).'
  );

  Map.Free();
end;

procedure TTestMap.TestCreationAndDestroy;
var
  Map : HMap <Integer, Boolean>;
  Dict : HDictionary<Integer, Boolean>;

begin
  Map := HMap<Integer, Boolean>.Create();

  Map.Insert(1, False);
  Map.Insert(5, True);
  Map.Insert(3, True);
  Map.Insert(2, False);

  { Check map values }
  Check((Map.Count = 4) and (Map.Count = Map.GetCount()), 'Count of elements expected to be 4');

  Map.Insert(6, True);
  Check((Map.Count = 5) and (Map.Count = Map.GetCount()), 'Count of elements expected to be 5');

  Map.Free;

  { Copy constructor }
  Dict := HDictionary<Integer, Boolean>.Create();
  Dict.Add(1, False);
  Dict.Add(2, False);
  Dict.Add(3, True);
  Dict.Add(4, True);

  Map := HMap<Integer, Boolean>.Create(Dict);

  { Check map values }
  Check((Map.Count = 4) and (Map.Count = Map.GetCount()), 'Count of elements expected to be 4');

  { First checks }
  Check(Map.Contains(1), 'Map expected to contain 1');
  Check(Map.Contains(2), 'Map expected to contain 2');
  Check(Map.Contains(3), 'Map expected to contain 3');
  Check(Map.Contains(4), 'Map expected to contain 4');
  Check(not Map.Contains(6), 'Map expected not to contain 6');

  Map.Free;
  Dict.Free;
end;

procedure TTestMap.TestEnumerator;
var
  Map : HMap<Integer, Integer>;
  X   : Integer;
  I   : HKeyValuePair<Integer, Integer>;
begin
  Map := HMap<Integer, Integer>.Create();

  Map.Insert(10, 11);
  Map.Insert(20, 21);
  Map.Insert(30, 31);

  X := 0;

  for I in Map do
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


  CheckException(ECollectionChanged,
    procedure()
    var
      I : HKeyValuePair<Integer, Integer>;
    begin
      for I in Map do
      begin
        Map.Remove(I.Key);
      end;
    end,
    'ECollectionChanged not thrown in Enumerator!'
  );

  Check(Map.Count = 2, 'Enumerator failed too late');

  Map.Free();
end;

procedure TTestMap.TestExceptions;
var
  Map     : HMap<String, Integer>;
  NullArg : ITypeSupport<String>;
begin
  NullArg := nil;

  CheckException(EArgumentException,
    procedure()
    begin
      Map := HMap<String, Integer>.Create(NullArg);
      Map.Free();
    end,
    'EArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(EArgumentException,
    procedure()
    begin
      Map := HMap<String, Integer>.Create(NullArg, nil);
      Map.Free();
    end,
    'EArgumentException not thrown in constructor (nil comparer).'
  );

  CheckException(EArgumentException,
    procedure()
    begin
      Map := HMap<String, Integer>.Create(HTypeSupport<String>.Default, nil);
      Map.Free();
    end,
    'EArgumentException not thrown in constructor (nil enum).'
  );

  Map := HMap<String, Integer>.Create();

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Map.Insert('A', 2);
      Map.Insert('A', 7);
    end,
    'EDuplicateKeyException not thrown in Insert.'
  );

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      Map.Remove('H');
    end,
    'EKeyNotFoundException not thrown in Remove.'
  );

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      Map.Find('H');
    end,
    'EKeyNotFoundException not thrown in Find.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Map.Insert('first', 1);
      Map.Insert('second', 2);

      if Map[10].Key = 'string' then
         Exit;
    end,
    'EArgumentOutOfRangeException not thrown (Items[X]).'
  );

  Map.Free;
end;

procedure TTestMap.TestInsertAddRemoveClearCount;
var
  Map : HMap <Integer, Boolean>;
begin
  Map := HMap<Integer, Boolean>.Create();

  Map.Insert(3, False);
  Map.Insert(4, True);
  Map.Insert(2, True);

  Check((Map.Count = 3) and (Map.Count = Map.GetCount()), 'Map count expected to be 3');

  Map.Remove(3);
  Check((Map.Count = 2) and (Map.Count = Map.GetCount()), 'Map count expected to be 2');

  Map.Remove(2);
  Map.Remove(4);
  Check((Map.Count = 0) and (Map.Count = Map.GetCount()), 'Map count expected to be 0');

  Map.Insert(10, True);
  Map.Insert(15, True);
  Map.Insert(3, True);
  Map.Insert(7, True);
  Map.Insert(2, True);
  Check((Map.Count = 5) and (Map.Count = Map.GetCount()), 'Map count expected to be 5');

  Map.Clear();

  Check((Map.Count = 0) and (Map.Count = Map.GetCount()), 'Map count expected to be 0');

  //now a little more complicated test
{
       4
     /  \
   2     7
  / \   / \
 1   3 5   8
        \
         6
}
  //left branch
  Map.Insert(4, True);
  Map.Insert(2, True);
  Map.Insert(1, True);
  Map.Insert(3, True);
  //right branch
  Map.Insert(7, True);
  Map.Insert(5, True);
  Map.Insert(6, True);
  Map.Insert(8, True);

  //removing the root
  Map.Remove(4);

  Check((Map.Count = 7) and (Map.Count = Map.GetCount()), 'Map count expected to be 7');

  Map.Free;
end;

initialization
  TestFramework.RegisterTest(TTestMap.Suite);

end.
