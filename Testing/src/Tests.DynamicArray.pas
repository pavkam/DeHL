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
unit Tests.DynamicArray;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.List,
     DeHL.Collections.Base,
     DeHL.Arrays;

type
  TTestDynamicArray = class(TDeHLTestCase)
  published
    procedure TestCreation();
    procedure TestExtend();
    procedure TestShrink();
    procedure TestExtendAndInsert();
    procedure TestExtendAndInsert_array();
    procedure TestExtendAndInsert_FixedArray();
    procedure TestExtendAndInsert_DynamicArray();
    procedure TestRemove1AndShrink();
    procedure TestInsert();
    procedure TestInsert_array();
    procedure TestInsert_FixedArray();
    procedure TestInsert_DynamicArray();
    procedure TestRemove1();
    procedure TestAppend();
    procedure TestAppend_array();
    procedure TestAppend_FixedArray();
    procedure TestAppend_DynamicArray();
    procedure TestFill();
    procedure TestDispose();
    procedure TestSort();
    procedure TestBinarySearch();
    procedure TestReverse();
    procedure TestToFixedArray();
    procedure TestFromFixedArray();
    procedure TestToVariantArray;
    procedure TestConsume();
    procedure TestTypeSupport;

    procedure TestEnumerator;

    procedure TestBug0();
  end;


implementation

{ TTestDynamicArray }

procedure TTestDynamicArray.TestAppend;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(5);
  Arr.Append(6);
  Arr.Append(7);
  Arr.Append(8);

  Check(Arr.Length = 4, 'Length(Array) expected to be 4');

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 6, 'Array[1] expected to be 6');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 8, 'Array[3] expected to be 8');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      if (Arr[4] = 9) then exit;
    end,
    'EArgumentOutOfRangeException not thrown in indexer.'
  );
end;

procedure TTestDynamicArray.TestAppend_array;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append([5, 6, 7, 8]);

  Check(Arr.Length = 4, 'Length(Array) expected to be 4');

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 6, 'Array[1] expected to be 6');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 8, 'Array[3] expected to be 8');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      if (Arr[4] = 9) then exit;
    end,
    'EArgumentOutOfRangeException not thrown in indexer.'
  );
end;

procedure TTestDynamicArray.TestAppend_DynamicArray;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(TDynamicArray<Integer>.Create([5, 6, 7, 8]));
  Arr.Append(TDynamicArray<Integer>.Create([]));

  Check(Arr.Length = 4, 'Length(Array) expected to be 4');

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 6, 'Array[1] expected to be 6');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 8, 'Array[3] expected to be 8');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      if (Arr[4] = 9) then exit;
    end,
    'EArgumentOutOfRangeException not thrown in indexer.'
  );
end;

procedure TTestDynamicArray.TestAppend_FixedArray;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(TFixedArray<Integer>.Create([5, 6, 7, 8]));
  Arr.Append(TFixedArray<Integer>.Create([]));

  Check(Arr.Length = 4, 'Length(Array) expected to be 4');

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 6, 'Array[1] expected to be 6');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 8, 'Array[3] expected to be 8');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      if (Arr[4] = 9) then exit;
    end,
    'EArgumentOutOfRangeException not thrown in indexer.'
  );
end;

procedure TTestDynamicArray.TestBinarySearch;
var
  Arr      : TDynamicArray<Integer>;
  ASupport : IType<Integer>;
begin
  ASupport := TType<Integer>.Default;

  { Search 1 }
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Append(4);
  Arr.Append(5);

  Check(Arr.BinarySearch(2, ASupport) = 1, 'Expected to find 2 at position 1');
  Check(Arr.BinarySearch(5, ASupport) = 4, 'Expected to find 5 at position 4');
  Check(Arr.BinarySearch(1, ASupport) = 0, 'Expected to find 1 at position 0');

  Check(Arr.BinarySearch(2, ASupport, False) = -1, 'Expected to find 2 at position -1 (bad rev)');

  Arr.Reverse();

  Check(Arr.BinarySearch(2, ASupport, False) = 3, 'Expected to find 2 at position 3');
  Check(Arr.BinarySearch(5, ASupport, False) = 0, 'Expected to find 5 at position 0');
  Check(Arr.BinarySearch(1, ASupport, False) = 4, 'Expected to find 1 at position 4');

  Check(Arr.BinarySearch(2, ASupport) = -1, 'Expected to find 2 at position -1 (bad rev)');

  { Search 2 }
  Check(Arr.BinarySearch(4, 0, 3, ASupport, False) = 1, 'Expected to find 4 at position 1');
  Check(Arr.BinarySearch(5, 0, 4, ASupport, False) = 0, 'Expected to find 5 at position 0');
  Check(Arr.BinarySearch(2, 2, 3, ASupport, False) = 1, 'Expected to find 2 at position 1');

  Arr.Reverse();

  Check(Arr.BinarySearch(4, 2, 3, ASupport) = 1, 'Expected to find 4 at position 1');
  Check(Arr.BinarySearch(5, 3, 2, ASupport) = 1, 'Expected to find 5 at position 1');
  Check(Arr.BinarySearch(2, 1, 2, ASupport) = 0, 'Expected to find 2 at position 0');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.BinarySearch(2, 0, 6, ASupport);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.BinarySearch(2, 4, 2, ASupport);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.BinarySearch(2, 0, 6, ASupport, False);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.BinarySearch(2, 4, 2, ASupport, False);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Arr.BinarySearch(4, 2, 3, nil);
    end,
    'ENilArgumentException not thrown in BinarySearch (nil support)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Arr.BinarySearch(4, nil);
    end,
    'ENilArgumentException not thrown in BinarySearch (nil support)'
  );
end;

procedure TTestDynamicArray.TestBug0;
var
  Arr: TDynamicArray<Integer>;
begin
  { Add 1 elements in }
  Arr := TDynamicArray<Integer>.Create([111]);
  Arr.Remove(0);
  CheckEquals(1, Arr.Length, 'Remove/Expected length');
  CheckEquals(111, Arr[0], 'Remove/Arr[0]');

  { Add 1 elements in }
  Arr := TDynamicArray<Integer>.Create([333]);
  Arr.RemoveAndShrink(0);
  CheckEquals(0, Arr.Length, 'RemoveAndShrink/Expected length');
end;

procedure TTestDynamicArray.TestConsume;
var
  Arr: TDynamicArray<Integer>;
  IL: TArray<Integer>;
begin
  SetLength(IL, 3);

  IL[0] := 100;
  IL[1] := 200;
  IL[2] := 300;

  Arr := TDynamicArray<Integer>.Consume(IL);

  Check(Arr.Length = 3, 'Array length expected to be 3');

  Check(Arr[0] = 100, 'Arr[0] expected to be 100');
  Check(Arr[1] = 200, 'Arr[1] expected to be 200');
  Check(Arr[2] = 300, 'Arr[2] expected to be 300');
end;

procedure TTestDynamicArray.TestCreation;
var
  Arr    : TDynamicArray<Integer>;
  IL     : array of Integer;

  ASupport : IType<Integer>;
begin
  ASupport := TType<Integer>.Default;

  Arr.Append(1);
  Arr.Append(2);

  Arr.Sort(ASupport, False);

  Check(Arr[0] = 2, 'Arr[0] expected to be 2');
  Check(Arr[1] = 1, 'Arr[1] expected to be 1');

  { Check with capacity }
  Arr := TDynamicArray<Integer>.Create(2);

  Check(Arr.Length = 2, 'Length(Array) expected to be 2');
  Arr[0] := 2;
  Arr[1] := 3;

  Check(Arr[0] = 2, 'Arr[0] expected to be 2');
  Check(Arr[1] = 3, 'Arr[1] expected to be 3');

  Arr.Sort(ASupport, False);

  Check(Arr[0] = 3, 'Arr[0] expected to be 3');
  Check(Arr[1] = 2, 'Arr[1] expected to be 2');


  SetLength(IL, 3);
  IL[0] := 10;
  IL[1] := 20;
  IL[2] := 30;

  Arr := TDynamicArray<Integer>.Create(IL);

  Check(Arr.Length = 3, 'Length(Array) expected to be 3');
  Check(Arr[0] = 10, 'Arr[0] expected to be 10');
  Check(Arr[1] = 20, 'Arr[1] expected to be 20');
  Check(Arr[2] = 30, 'Arr[2] expected to be 30');
end;

procedure TTestDynamicArray.TestDispose;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Append(4);
  Arr.Append(5);
  Arr.Append(6);

  Arr.Dispose();

  Check(Arr.Length = 0, 'Length(Array) expected to be 0');
end;

procedure TTestDynamicArray.TestEnumerator;
var
  LEnum: IEnumerator<Integer>;
  LArray: TDynamicArray<Integer>;
begin
  LEnum := LArray.GetEnumerator;
  CheckFalse(LEnum.MoveNext);

  LArray := TDynamicArray<Integer>.Create([10]);

  LEnum := LArray.GetEnumerator;
  CheckTrue(LEnum.MoveNext);
  CheckEquals(10, LEnum.Current);
  CheckFalse(LEnum.MoveNext);
end;

procedure TTestDynamicArray.TestExtend;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Extend(1);
  Check(Arr.Length = 1, 'Length(Array) expected to be 1');

  Arr.Extend(3);
  Check(Arr.Length = 4, 'Length(Array) expected to be 4');

  Arr.Extend(10);
  Check(Arr.Length = 14, 'Length(Array) expected to be 14');
end;

procedure TTestDynamicArray.TestExtendAndInsert;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.ExtendAndInsert(0, 100);
  Check(Arr.Length = 1, 'Length(Array) expected to be 1');
  Check(Arr[0] = 100, 'Array[0] expected to be 100');

  Arr.ExtendAndInsert(0, 200);
  Check(Arr.Length = 2, 'Length(Array) expected to be 2');
  Check(Arr[0] = 200, 'Array[0] expected to be 200');
  Check(Arr[1] = 100, 'Array[1] expected to be 100');

  Arr.ExtendAndInsert(1, 300);
  Check(Arr.Length = 3, 'Length(Array) expected to be 3');
  Check(Arr[0] = 200, 'Array[0] expected to be 200');
  Check(Arr[1] = 300, 'Array[1] expected to be 300');
  Check(Arr[2] = 100, 'Array[2] expected to be 100');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.ExtendAndInsert(4, 400);
    end,
    'EArgumentOutOfRangeException not thrown in ExtendAndInsert'
  );

  Arr.ExtendAndInsert(3, 800);
  Check(Arr.Length = 4, 'Length(Array) expected to be 4');
  Check(Arr[0] = 200, 'Array[0] expected to be 200');
  Check(Arr[1] = 300, 'Array[1] expected to be 300');
  Check(Arr[2] = 100, 'Array[2] expected to be 100');
  Check(Arr[3] = 800, 'Array[2] expected to be 800');
end;

procedure TTestDynamicArray.TestExtendAndInsert_array;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.ExtendAndInsert(0, [100, 200]);
  Check(Arr.Length = 2, 'Length(Array) expected to be 2');
  Check(Arr[0] = 100, 'Array[0] expected to be 100');
  Check(Arr[1] = 200, 'Array[1] expected to be 200');

  Arr.ExtendAndInsert(0, []);
  Arr.ExtendAndInsert(0, [300]);
  Check(Arr.Length = 3, 'Length(Array) expected to be 3');
  Check(Arr[0] = 300, 'Array[0] expected to be 300');
  Check(Arr[1] = 100, 'Array[1] expected to be 100');
  Check(Arr[2] = 200, 'Array[2] expected to be 200');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.ExtendAndInsert(4, [400]);
    end,
    'EArgumentOutOfRangeException not thrown in ExtendAndInsert'
  );

  Arr.ExtendAndInsert(1, [800, 900]);
  Check(Arr.Length = 5, 'Length(Array) expected to be 5');
  Check(Arr[0] = 300, 'Array[0] expected to be 300');
  Check(Arr[1] = 800, 'Array[1] expected to be 800');
  Check(Arr[2] = 900, 'Array[2] expected to be 900');
  Check(Arr[3] = 100, 'Array[3] expected to be 100');
  Check(Arr[4] = 200, 'Array[4] expected to be 200');
end;

procedure TTestDynamicArray.TestExtendAndInsert_DynamicArray;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.ExtendAndInsert(0, TDynamicArray<Integer>.Create([100, 200]));
  Check(Arr.Length = 2, 'Length(Array) expected to be 2');
  Check(Arr[0] = 100, 'Array[0] expected to be 100');
  Check(Arr[1] = 200, 'Array[1] expected to be 200');

  Arr.ExtendAndInsert(0, TDynamicArray<Integer>.Create([]));
  Arr.ExtendAndInsert(0, TDynamicArray<Integer>.Create([300]));
  Check(Arr.Length = 3, 'Length(Array) expected to be 3');
  Check(Arr[0] = 300, 'Array[0] expected to be 300');
  Check(Arr[1] = 100, 'Array[1] expected to be 100');
  Check(Arr[2] = 200, 'Array[2] expected to be 200');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.ExtendAndInsert(4, TDynamicArray<Integer>.Create([400]));
    end,
    'EArgumentOutOfRangeException not thrown in ExtendAndInsert'
  );

  Arr.ExtendAndInsert(1, TDynamicArray<Integer>.Create([800, 900]));
  Check(Arr.Length = 5, 'Length(Array) expected to be 5');
  Check(Arr[0] = 300, 'Array[0] expected to be 300');
  Check(Arr[1] = 800, 'Array[1] expected to be 800');
  Check(Arr[2] = 900, 'Array[2] expected to be 900');
  Check(Arr[3] = 100, 'Array[3] expected to be 100');
  Check(Arr[4] = 200, 'Array[4] expected to be 200');
end;

procedure TTestDynamicArray.TestExtendAndInsert_FixedArray;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.ExtendAndInsert(0, TFixedArray<Integer>.Create([100, 200]));
  Check(Arr.Length = 2, 'Length(Array) expected to be 2');
  Check(Arr[0] = 100, 'Array[0] expected to be 100');
  Check(Arr[1] = 200, 'Array[1] expected to be 200');

  Arr.ExtendAndInsert(0, TFixedArray<Integer>.Create([]));
  Arr.ExtendAndInsert(0, TFixedArray<Integer>.Create([300]));
  Check(Arr.Length = 3, 'Length(Array) expected to be 3');
  Check(Arr[0] = 300, 'Array[0] expected to be 300');
  Check(Arr[1] = 100, 'Array[1] expected to be 100');
  Check(Arr[2] = 200, 'Array[2] expected to be 200');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.ExtendAndInsert(4, TFixedArray<Integer>.Create([400]));
    end,
    'EArgumentOutOfRangeException not thrown in ExtendAndInsert'
  );

  Arr.ExtendAndInsert(1, TFixedArray<Integer>.Create([800, 900]));
  Check(Arr.Length = 5, 'Length(Array) expected to be 5');
  Check(Arr[0] = 300, 'Array[0] expected to be 300');
  Check(Arr[1] = 800, 'Array[1] expected to be 800');
  Check(Arr[2] = 900, 'Array[2] expected to be 900');
  Check(Arr[3] = 100, 'Array[3] expected to be 100');
  Check(Arr[4] = 200, 'Array[4] expected to be 200');
end;

procedure TTestDynamicArray.TestFill;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);

  Arr.Fill(-1);

  Check(Arr[0] = -1, 'Array[0] expected to be -1');
  Check(Arr[1] = -1, 'Array[1] expected to be -1');
  Check(Arr[2] = -1, 'Array[2] expected to be -1');

  Arr.Append(2);
  Arr.Append(3);

  Arr.Fill(3, 2, -2);

  Check(Arr[0] = -1, 'Array[0] expected to be -1');
  Check(Arr[1] = -1, 'Array[1] expected to be -1');
  Check(Arr[2] = -1, 'Array[2] expected to be -1');
  Check(Arr[3] = -2, 'Array[3] expected to be -2');
  Check(Arr[4] = -2, 'Array[4] expected to be -2');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Fill(0, 100, -4);
    end,
    'EArgumentOutOfRangeException not thrown in Fill'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Fill(5, 1, -4);
    end,
    'EArgumentOutOfRangeException not thrown in Fill'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Fill(0, 6, -4);
    end,
    'EArgumentOutOfRangeException not thrown in Fill'
  );
end;

procedure TTestDynamicArray.TestFromFixedArray;
var
  DArr: TDynamicArray<String>;
  FArr: TFixedArray<String>;
begin
  FArr := TFixedArray<String>.Create(['One', 'Two', 'Three']);
  DArr := TDynamicArray<String>.Create(FArr);

  { Check correct copy }
  Check(DArr.Length = 3, 'Expected DArr.Length = 3');
  Check(DArr[0] = 'One', 'Expected DArr[0] = "One"');
  Check(DArr[1] = 'Two', 'Expected DArr[1] = "Two"');
  Check(DArr[2] = 'Three', 'Expected DArr[2] = "Three"');
end;

procedure TTestDynamicArray.TestInsert;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Extend(1);

  Arr.Insert(1, -1);

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = -1, 'Array[1] expected to be -1');
  Check(Arr[2] = 2, 'Array[2] expected to be 2');
  Check(Arr[3] = 3, 'Array[3] expected to be 3');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(5, -4);
    end,
    'EArgumentOutOfRangeException not thrown in Insert'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(100, -4);
    end,
    'EArgumentOutOfRangeException not thrown in Insert'
  );

end;

procedure TTestDynamicArray.TestInsert_array;
var
  Arr: TDynamicArray<Integer>;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Extend(1);

  Arr.Insert(1, [-1, -2]);
  Arr.Insert(2, []);

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = -1, 'Array[1] expected to be -1');
  Check(Arr[2] = -2, 'Array[2] expected to be -2');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');

  Arr.Dispose;
  Arr.Append([0, 1, 2, 3, 4, 5]);
  Arr.Insert(2, [7, 8]);

  Check(Arr[0] = 0, 'Array[0] expected to be 0');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 8, 'Array[3] expected to be 8');
  Check(Arr[4] = 2, 'Array[4] expected to be 2');
  Check(Arr[5] = 3, 'Array[5] expected to be 3');

  Arr.Insert(3, [100, 101, 102, 103]);

  Check(Arr[0] = 0, 'Array[0] expected to be 0');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 100, 'Array[3] expected to be 100');
  Check(Arr[4] = 101, 'Array[4] expected to be 101');
  Check(Arr[5] = 102, 'Array[5] expected to be 102');

  Arr.Insert(0, [-1, -2, -3, -4, -5, -6, -7, -8]);

  Check(Arr[0] = -1, 'Array[0] expected to be -1');
  Check(Arr[1] = -2, 'Array[1] expected to be -2');
  Check(Arr[2] = -3, 'Array[2] expected to be -3');
  Check(Arr[3] = -4, 'Array[3] expected to be -4');
  Check(Arr[4] = -5, 'Array[4] expected to be -5');
  Check(Arr[5] = -6, 'Array[5] expected to be -6');

  Check(Arr.Length = 6, 'Expected length of array to remain constant');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(6, [-4]);
    end,
    'EArgumentOutOfRangeException not thrown in Insert (array)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(100, []);
    end,
    'EArgumentOutOfRangeException not thrown in Insert (array)'
  );
end;

procedure TTestDynamicArray.TestInsert_DynamicArray;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Extend(1);

  Arr.Insert(1, TDynamicArray<Integer>.Create([-1, -2]));
  Arr.Insert(2, TDynamicArray<Integer>.Create([]));

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = -1, 'Array[1] expected to be -1');
  Check(Arr[2] = -2, 'Array[2] expected to be -2');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');


  Arr.Dispose;
  Arr.Append([0, 1, 2, 3, 4, 5]);
  Arr.Insert(2, TDynamicArray<Integer>.Create([7, 8]));

  Check(Arr[0] = 0, 'Array[0] expected to be 0');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 8, 'Array[3] expected to be 8');
  Check(Arr[4] = 2, 'Array[4] expected to be 2');
  Check(Arr[5] = 3, 'Array[5] expected to be 3');

  Arr.Insert(3, TDynamicArray<Integer>.Create([100, 101, 102, 103]));

  Check(Arr[0] = 0, 'Array[0] expected to be 0');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 100, 'Array[3] expected to be 100');
  Check(Arr[4] = 101, 'Array[4] expected to be 101');
  Check(Arr[5] = 102, 'Array[5] expected to be 102');

  Arr.Insert(0, TDynamicArray<Integer>.Create([-1, -2, -3, -4, -5, -6, -7, -8]));

  Check(Arr[0] = -1, 'Array[0] expected to be -1');
  Check(Arr[1] = -2, 'Array[1] expected to be -2');
  Check(Arr[2] = -3, 'Array[2] expected to be -3');
  Check(Arr[3] = -4, 'Array[3] expected to be -4');
  Check(Arr[4] = -5, 'Array[4] expected to be -5');
  Check(Arr[5] = -6, 'Array[5] expected to be -6');

  Check(Arr.Length = 6, 'Expected length of array to remain constant');


  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(6, TDynamicArray<Integer>.Create([-4]));
    end,
    'EArgumentOutOfRangeException not thrown in Insert (darray)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(100, TDynamicArray<Integer>.Create([]));
    end,
    'EArgumentOutOfRangeException not thrown in Insert (darray)'
  );
end;

procedure TTestDynamicArray.TestInsert_FixedArray;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Extend(1);

  Arr.Insert(1, TFixedArray<Integer>.Create([-1, -2]));
  Arr.Insert(2, TFixedArray<Integer>.Create([]));

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = -1, 'Array[1] expected to be -1');
  Check(Arr[2] = -2, 'Array[2] expected to be -2');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');

  Arr.Dispose;
  Arr.Append([0, 1, 2, 3, 4, 5]);
  Arr.Insert(2, TFixedArray<Integer>.Create([7, 8]));

  Check(Arr[0] = 0, 'Array[0] expected to be 0');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 8, 'Array[3] expected to be 8');
  Check(Arr[4] = 2, 'Array[4] expected to be 2');
  Check(Arr[5] = 3, 'Array[5] expected to be 3');

  Arr.Insert(3, TFixedArray<Integer>.Create([100, 101, 102, 103]));

  Check(Arr[0] = 0, 'Array[0] expected to be 0');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 7, 'Array[2] expected to be 7');
  Check(Arr[3] = 100, 'Array[3] expected to be 100');
  Check(Arr[4] = 101, 'Array[4] expected to be 101');
  Check(Arr[5] = 102, 'Array[5] expected to be 102');

  Arr.Insert(0, TFixedArray<Integer>.Create([-1, -2, -3, -4, -5, -6, -7, -8]));

  Check(Arr[0] = -1, 'Array[0] expected to be -1');
  Check(Arr[1] = -2, 'Array[1] expected to be -2');
  Check(Arr[2] = -3, 'Array[2] expected to be -3');
  Check(Arr[3] = -4, 'Array[3] expected to be -4');
  Check(Arr[4] = -5, 'Array[4] expected to be -5');
  Check(Arr[5] = -6, 'Array[5] expected to be -6');

  Check(Arr.Length = 6, 'Expected length of array to remain constant');


  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(6, TFixedArray<Integer>.Create([-4]));
    end,
    'EArgumentOutOfRangeException not thrown in Insert (fxarray)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Insert(100, TFixedArray<Integer>.Create([]));
    end,
    'EArgumentOutOfRangeException not thrown in Insert (fxarray)'
  );
end;

procedure TTestDynamicArray.TestRemove1;
var
  Arr : TDynamicArray<Integer>;
  R   : Integer;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Append(4);

  R := Arr.Remove(0);

  Check(R = 1, 'Removed element expected to be 1');
  Check(Arr.Length = 4, 'Length(Array) expected to be 4');
  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 3, 'Array[1] expected to be 3');
  Check(Arr[2] = 4, 'Array[2] expected to be 4');

  R := Arr.Remove(1);

  Check(R = 3, 'Removed element expected to be 3');
  Check(Arr.Length = 4, 'Length(Array) expected to be 4');
  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');

  Arr[3] := -1;

  Arr.Remove(3);

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Remove(4);
    end,
    'EArgumentOutOfRangeException not thrown in Remove'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Remove(100);
    end,
    'EArgumentOutOfRangeException not thrown in Remove'
  );
end;

procedure TTestDynamicArray.TestRemove1AndShrink;
var
  Arr : TDynamicArray<Integer>;
  R   : Integer;

begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Append(4);
  Arr.Append(5);
  Arr.Append(6);

  R := Arr.RemoveAndShrink(0);

  Check(R = 1, 'Removed element expected to be 1');
  Check(Arr.Length = 5, 'Length(Array) expected to be 5');
  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 3, 'Array[1] expected to be 3');
  Check(Arr[2] = 4, 'Array[2] expected to be 4');
  Check(Arr[3] = 5, 'Array[0] expected to be 5');
  Check(Arr[4] = 6, 'Array[1] expected to be 6');

  R := Arr.RemoveAndShrink(4);

  Check(R = 6, 'Removed element expected to be 6');
  Check(Arr.Length = 4, 'Length(Array) expected to be 4');
  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 3, 'Array[1] expected to be 3');
  Check(Arr[2] = 4, 'Array[2] expected to be 4');
  Check(Arr[3] = 5, 'Array[0] expected to be 5');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.RemoveAndShrink(4);
    end,
    'EArgumentOutOfRangeException not thrown in RemoveAndShrink'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.RemoveAndShrink(100);
    end,
    'EArgumentOutOfRangeException not thrown in RemoveAndShrink'
  );

  Arr.Dispose;

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.RemoveAndShrink(0);
    end,
    'EArgumentOutOfRangeException not thrown in RemoveAndShrink'
  );
end;

procedure TTestDynamicArray.TestReverse;
var
  Arr : TDynamicArray<Integer>;
begin
  { Reverse 1 }
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Append(4);
  Arr.Append(5);

  Arr.Reverse();

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 1, 'Array[4] expected to be 1');

  Arr.Reverse();

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = 2, 'Array[1] expected to be 2');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 4, 'Array[3] expected to be 4');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  { Reverse 2 }
  Arr.Reverse(0, 2);

  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 4, 'Array[3] expected to be 4');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  Arr.Reverse(1, 3);

  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 1, 'Array[3] expected to be 1');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  Arr.Reverse(4, 1);

  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 1, 'Array[3] expected to be 1');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  { Check exceptions }
  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Reverse(0, 6);
    end,
    'EArgumentOutOfRangeException not thrown in Reverse'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Reverse(4, 2);
    end,
    'EArgumentOutOfRangeException not thrown in Reverse'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Reverse(3, 3);
    end,
    'EArgumentOutOfRangeException not thrown in Reverse'
  );
end;

procedure TTestDynamicArray.TestShrink;
var
  Arr : TDynamicArray<Integer>;
begin
  Arr.Append(1);
  Arr.Append(2);
  Arr.Append(3);
  Arr.Append(4);
  Arr.Append(5);
  Arr.Append(6);

  Arr.Shrink(2);
  Check(Arr.Length = 4, 'Length(Array) expected to be 4');
  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = 2, 'Array[1] expected to be 2');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 4, 'Array[0] expected to be 4');

  Arr.Shrink(4);
  Check(Arr.Length = 0, 'Length(Array) expected to be 0');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Shrink(1);
    end,
    'EArgumentOutOfRangeException not thrown in Shrink'
  );

  Arr.Length := 10;

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Shrink(11);
    end,
    'EArgumentOutOfRangeException not thrown in Shrink'
  );
end;

procedure TTestDynamicArray.TestSort;
var
  Arr      : TDynamicArray<Integer>;
  ASupport : IType<Integer>;
begin
  ASupport := TType<Integer>.Default;

  { Check Sort 1 }
  Arr.Append(5);
  Arr.Append(4);
  Arr.Append(3);
  Arr.Append(2);
  Arr.Append(1);

  Arr.Sort(ASupport);

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = 2, 'Array[1] expected to be 2');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 4, 'Array[3] expected to be 4');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  Arr.Sort(ASupport, False);

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 1, 'Array[4] expected to be 1');

  { Check Sort 2 }
  Arr.Sort(0, 2, ASupport);

  Check(Arr[0] = 4, 'Array[0] expected to be 4');
  Check(Arr[1] = 5, 'Array[1] expected to be 5');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 1, 'Array[4] expected to be 1');

  Arr.Sort(2, 3, ASupport);

  Check(Arr[0] = 4, 'Array[0] expected to be 4');
  Check(Arr[1] = 5, 'Array[1] expected to be 5');
  Check(Arr[2] = 1, 'Array[2] expected to be 1');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 3, 'Array[4] expected to be 3');

  Arr.Sort(1, 3, ASupport, False);

  Check(Arr[0] = 4, 'Array[0] expected to be 4');
  Check(Arr[1] = 5, 'Array[1] expected to be 5');
  Check(Arr[2] = 2, 'Array[2] expected to be 2');
  Check(Arr[3] = 1, 'Array[3] expected to be 1');
  Check(Arr[4] = 3, 'Array[4] expected to be 3');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Sort(0, 6, ASupport);
    end,
    'EArgumentOutOfRangeException not thrown in Sort (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      Arr.Sort(0, 6, ASupport, False);
    end,
    'EArgumentOutOfRangeException not thrown in Sort (index)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Arr.Sort(0, 2, nil);
    end,
    'ENilArgumentException not thrown in Sort (nil support)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Arr.Sort(nil);
    end,
    'ENilArgumentException not thrown in Sort (nil support)'
  );
end;

procedure TTestDynamicArray.TestToFixedArray;
var
  DArr: TDynamicArray<String>;
  FArr: TFixedArray<String>;
begin
  DArr.Append('One');
  DArr.Append('Two');
  DArr.Append('Three');

  FArr := DArr.ToFixedArray();

  { Check correct copy }
  Check(FArr.Length = 3, 'Expected FArr.Length = 3');
  Check(FArr[0] = 'One', 'Expected FArr[0] = "One"');
  Check(FArr[1] = 'Two', 'Expected FArr[1] = "Two"');
  Check(FArr[2] = 'Three', 'Expected FArr[2] = "Three"');
end;

procedure TTestDynamicArray.TestToVariantArray;
var
  _AI: TDynamicArray<Integer>;
  _AS: TDynamicArray<String>;
  _AB: TDynamicArray<Boolean>;

  _AO: TDynamicArray<TObject>;

  __AI, __AS, __AB: Variant;
  I: Integer;
begin
  _AI := TDynamicArray<Integer>.Create([Random(MaxInt), Random(MaxInt), Random(MaxInt), Random(MaxInt), Random(MaxInt)]);
  _AS := TDynamicArray<String>.Create([IntToStr(Random(MaxInt)), IntToStr(Random(MaxInt)), IntToStr(Random(MaxInt)),
    IntToStr(Random(MaxInt)), IntToStr(Random(MaxInt))]);
  _AB := TDynamicArray<Boolean>.Create([Boolean(Random(MaxInt)), Boolean(Random(MaxInt)), Boolean(Random(MaxInt)),
    Boolean(Random(MaxInt)), Boolean(Random(MaxInt))]);

  _AO := TDynamicArray<TObject>.Create([nil]);

  { ... Obtain variant arrays }
  __AI := _AI.ToVariantArray();
  __AS := _AS.ToVariantArray();
  __AB := _AB.ToVariantArray();

  for I := 0 to 4 do
  begin
    Check(__AI[I] = _AI[I], 'Copy failed for integer array');
    Check(__AS[I] = _AS[I], 'Copy failed for string array');
    Check(__AB[I] = _AB[I], 'Copy failed for boolean array');
  end;

  CheckException(ETypeIncompatibleWithVariantArray,
    procedure()
    begin
      _AO.ToVariantArray();
    end,
    'ETypeIncompatibleWithVariantArray not thrown in ToVariantArray (wrong element type)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      _AI.ToVariantArray(nil);
    end,
    'ENilArgumentException not thrown in ToVariantArray (nil type)'
  );
end;

procedure TTestDynamicArray.TestTypeSupport;
var
  DefaultSupport: IType<TDynamicArray<Integer>>;
  v1, v2        : TDynamicArray<Integer>;
begin
  DefaultSupport := TType<TDynamicArray<Integer>>.Default;

  { Normal }
  v1 := TDynamicArray<Integer>.Create([1, 1]);
  v2 := TDynamicArray<Integer>.Create([1, 2]);

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'TDynamicArray<System.Integer>', 'Type Name = "TDynamicArray<System.Integer>"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(TDynamicArray<Integer>), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfArray, 'Type Family = tfArray');

  v1 := TDynamicArray<Integer>.Create([1, 2, 3]);
  Check(DefaultSupport.GetString(v1) = '(3 Elements)', '(Default) Expected GetString() = "(3 Elements)"');
end;

initialization
  TestFramework.RegisterTest(TTestDynamicArray.Suite);

end.
