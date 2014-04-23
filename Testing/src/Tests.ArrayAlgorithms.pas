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
unit Tests.ArrayAlgorithms;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays;

type
  TTestArrayAlgorithms = class(TDeHLTestCase)
  published
    procedure TestAlgReverse;
    procedure TestAlgSort_Type;
    procedure TestAlgSort_Comp;
    procedure TestAlgBSearch;
    procedure TestSafeMove;
    procedure TestClone;
    procedure TestEnumerator;

    procedure TestToVariantArray;
  end;

implementation

{ TTestArrayAlgorithms }

procedure TTestArrayAlgorithms.TestAlgBSearch;
var
  Arr      : array of Integer;
  ASupport : IType<Integer>;
begin
  ASupport := TType<Integer>.Default;

  SetLength(Arr, 5);

  { Search 1 }
  Arr[0] := 1;
  Arr[1] := 2;
  Arr[2] := 3;
  Arr[3] := 4;
  Arr[4] := 5;

  Check(&Array<Integer>.BinarySearch(Arr, 2, ASupport) = 1, 'Expected to find 2 at position 1');
  Check(&Array<Integer>.BinarySearch(Arr, 5, ASupport) = 4, 'Expected to find 5 at position 4');
  Check(&Array<Integer>.BinarySearch(Arr, 1, ASupport) = 0, 'Expected to find 1 at position 0');

  Check(&Array<Integer>.BinarySearch(Arr, 2, ASupport, false) = -1, 'Expected to find 2 at position -1 (bad rev)');

  &Array<Integer>.Reverse(Arr);

  Check(&Array<Integer>.BinarySearch(Arr, 2, ASupport, false) = 3, 'Expected to find 2 at position 3');
  Check(&Array<Integer>.BinarySearch(Arr, 5, ASupport, false) = 0, 'Expected to find 5 at position 0');
  Check(&Array<Integer>.BinarySearch(Arr, 1, ASupport, false) = 4, 'Expected to find 1 at position 4');

  Check(&Array<Integer>.BinarySearch(Arr, 2, ASupport) = -1, 'Expected to find 2 at position -1 (bad rev)');

  &Array<Integer>.BinarySearch(Arr, 2, ASupport);

  { Search 2 }
  Check(&Array<Integer>.BinarySearch(Arr, 4, 0, 3, ASupport, False) = 1, 'Expected to find 4 at position 1');
  Check(&Array<Integer>.BinarySearch(Arr, 5, 0, 4, ASupport, False) = 0, 'Expected to find 5 at position 0');
  Check(&Array<Integer>.BinarySearch(Arr, 2, 2, 3, ASupport, False) = 1, 'Expected to find 2 at position 1');

  &Array<Integer>.Reverse(Arr);

  Check(&Array<Integer>.BinarySearch(Arr, 4, 2, 3, ASupport) = 1, 'Expected to find 4 at position 1');
  Check(&Array<Integer>.BinarySearch(Arr, 5, 3, 2, ASupport) = 1, 'Expected to find 5 at position 1');
  Check(&Array<Integer>.BinarySearch(Arr, 2, 1, 2, ASupport) = 0, 'Expected to find 2 at position 0');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.BinarySearch(Arr, 2, 0, 6, ASupport);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.BinarySearch(Arr, 2, 4, 2, ASupport);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.BinarySearch(Arr, 2, 0, 6, ASupport, False);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.BinarySearch(Arr, 2, 4, 2, ASupport, False);
    end,
    'EArgumentOutOfRangeException not thrown in BinarySearch (index)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      &Array<Integer>.BinarySearch(Arr, 4, 2, 3, nil);
    end,
    'ENilArgumentException not thrown in BinarySearch (nil support)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      &Array<Integer>.BinarySearch(Arr, 4, nil);
    end,
    'ENilArgumentException not thrown in BinarySearch (nil support)'
  );
end;

procedure TTestArrayAlgorithms.TestAlgReverse;
var
  Arr : array of Integer;
begin
  SetLength(Arr, 5);

  { Reverse 1 }
  Arr[0] := 1;
  Arr[1] := 2;
  Arr[2] := 3;
  Arr[3] := 4;
  Arr[4] := 5;

  &Array<Integer>.Reverse(Arr);

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 1, 'Array[4] expected to be 1');

  &Array<Integer>.Reverse(Arr);

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = 2, 'Array[1] expected to be 2');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 4, 'Array[3] expected to be 4');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  { Reverse 2 }
  &Array<Integer>.Reverse(Arr, 0, 2);

  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 1, 'Array[1] expected to be 1');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 4, 'Array[3] expected to be 4');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  &Array<Integer>.Reverse(Arr, 1, 3);

  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 1, 'Array[3] expected to be 1');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  &Array<Integer>.Reverse(Arr, 4, 1);

  Check(Arr[0] = 2, 'Array[0] expected to be 2');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 1, 'Array[3] expected to be 1');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  { Check exceptions }
  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.Reverse(Arr, 0, 6);
    end,
    'EArgumentOutOfRangeException not thrown in Reverse'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.Reverse(Arr, 4, 2);
    end,
    'EArgumentOutOfRangeException not thrown in Reverse'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.Reverse(Arr, 3, 3);
    end,
    'EArgumentOutOfRangeException not thrown in Reverse'
  );
end;

procedure TTestArrayAlgorithms.TestAlgSort_Comp;
var
  Arr: array of String;
  AComp, AInvComp: TCompareOverride<String>;
begin
  AComp := function(const ALeft, ARight: String): NativeInt
  begin
    Result := StrToInt(ALeft) - StrToInt(ARight);
  end;
  AInvComp := function(const ALeft, ARight: String): NativeInt
  begin
    Result := StrToInt(ARight) - StrToInt(ALeft);
  end;

  SetLength(Arr, 5);

  { Check Sort 1 }
  Arr[0] := '5';
  Arr[1] := '4';
  Arr[2] := '3';
  Arr[3] := '2';
  Arr[4] := '1';

  &Array<String>.Sort(Arr, AComp);

  Check(Arr[0] = '1', 'Array[0] expected to be 1');
  Check(Arr[1] = '2', 'Array[1] expected to be 2');
  Check(Arr[2] = '3', 'Array[2] expected to be 3');
  Check(Arr[3] = '4', 'Array[3] expected to be 4');
  Check(Arr[4] = '5', 'Array[4] expected to be 5');

  { Check Sort 2 }
  &Array<String>.Sort(Arr, 0, 3, AInvComp);

  Check(Arr[0] = '3', 'Array[0] expected to be 3');
  Check(Arr[1] = '2', 'Array[1] expected to be 2');
  Check(Arr[2] = '1', 'Array[2] expected to be 1');
  Check(Arr[3] = '4', 'Array[3] expected to be 4');
  Check(Arr[4] = '5', 'Array[4] expected to be 5');

  &Array<String>.Sort(Arr, 2, 3, AInvComp);

  Check(Arr[0] = '3', 'Array[0] expected to be 3');
  Check(Arr[1] = '2', 'Array[1] expected to be 2');
  Check(Arr[2] = '5', 'Array[2] expected to be 5');
  Check(Arr[3] = '4', 'Array[3] expected to be 4');
  Check(Arr[4] = '1', 'Array[4] expected to be 1');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<String>.Sort(Arr, 0, 6, AComp);
    end,
    'EArgumentOutOfRangeException not thrown in Sort (index)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      &Array<String>.Sort(Arr, 0, 2, TCompareOverride<String>(nil));
    end,
    'ENilArgumentException not thrown in Sort (nil comp)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      &Array<String>.Sort(Arr, TCompareOverride<String>(nil));
    end,
    'ENilArgumentException not thrown in Sort (nil comp)'
  );
end;

procedure TTestArrayAlgorithms.TestAlgSort_Type;
var
  Arr      : array of Integer;
  ASupport : IType<Integer>;
begin
  ASupport := TType<Integer>.Default;

  SetLength(Arr, 5);

  { Check Sort 1 }
  Arr[0] := 5;
  Arr[1] := 4;
  Arr[2] := 3;
  Arr[3] := 2;
  Arr[4] := 1;

  &Array<Integer>.Sort(Arr, ASupport);

  Check(Arr[0] = 1, 'Array[0] expected to be 1');
  Check(Arr[1] = 2, 'Array[1] expected to be 2');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 4, 'Array[3] expected to be 4');
  Check(Arr[4] = 5, 'Array[4] expected to be 5');

  &Array<Integer>.Sort(Arr, ASupport, False);

  Check(Arr[0] = 5, 'Array[0] expected to be 5');
  Check(Arr[1] = 4, 'Array[1] expected to be 4');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 1, 'Array[4] expected to be 1');

  { Check Sort 2 }
  &Array<Integer>.Sort(Arr, 0, 2, ASupport);

  Check(Arr[0] = 4, 'Array[0] expected to be 4');
  Check(Arr[1] = 5, 'Array[1] expected to be 5');
  Check(Arr[2] = 3, 'Array[2] expected to be 3');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 1, 'Array[4] expected to be 1');

  &Array<Integer>.Sort(Arr, 2, 3, ASupport);

  Check(Arr[0] = 4, 'Array[0] expected to be 4');
  Check(Arr[1] = 5, 'Array[1] expected to be 5');
  Check(Arr[2] = 1, 'Array[2] expected to be 1');
  Check(Arr[3] = 2, 'Array[3] expected to be 2');
  Check(Arr[4] = 3, 'Array[4] expected to be 3');

  &Array<Integer>.Sort(Arr, 1, 3, ASupport, False);

  Check(Arr[0] = 4, 'Array[0] expected to be 4');
  Check(Arr[1] = 5, 'Array[1] expected to be 5');
  Check(Arr[2] = 2, 'Array[2] expected to be 2');
  Check(Arr[3] = 1, 'Array[3] expected to be 1');
  Check(Arr[4] = 3, 'Array[4] expected to be 3');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.Sort(Arr, 0, 6, ASupport);
    end,
    'EArgumentOutOfRangeException not thrown in Sort (index)'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      &Array<Integer>.Sort(Arr, 0, 6, ASupport, False);
    end,
    'EArgumentOutOfRangeException not thrown in Sort (index)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      &Array<Integer>.Sort(Arr, 0, 2, IType<Integer>(nil));
    end,
    'ENilArgumentException not thrown in Sort (nil support)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      &Array<Integer>.Sort(Arr, IType<Integer>(nil));
    end,
    'ENilArgumentException not thrown in Sort (nil support)'
  );
end;

procedure TTestArrayAlgorithms.TestClone;
var
  A, B: TArray<string>;
begin
  { Move 2 arrays safely }
  SetLength(A, 4);
  SetLength(B, 4);

  A[0] := 'Element 0';
  A[1] := 'Element 1';
  A[2] := 'Element 2';
  A[3] := 'Element 3';

  B := &Array<String>.Clone(A, TType<String>.Default);

  Check(StringRefCount(A[0]) = 2, 'A[0] should be referenced 2 times');
  Check(StringRefCount(B[0]) = 2, 'B[0] should be referenced 2 times');
  Check(StringRefCount(A[1]) = 2, 'A[1] should be referenced 2 times');
  Check(StringRefCount(B[1]) = 2, 'B[1] should be referenced 2 times');
  Check(StringRefCount(A[2]) = 2, 'A[2] should be referenced 2 times');
  Check(StringRefCount(B[2]) = 2, 'B[2] should be referenced 2 times');
  Check(StringRefCount(A[3]) = 2, 'A[3] should be referenced 2 times');
  Check(StringRefCount(B[3]) = 2, 'B[3] should be referenced 2 times');

  Check(B[0] = 'Element 0', 'B[0] expected to be equal to "Element 0"');
  Check(B[1] = 'Element 1', 'B[1] expected to be equal to "Element 1"');
  Check(B[2] = 'Element 2', 'B[2] expected to be equal to "Element 2"');
  Check(B[3] = 'Element 3', 'B[3] expected to be equal to "Element 3"');
end;

procedure TTestArrayAlgorithms.TestEnumerator;
var
  LEnum: IEnumerator<Integer>;
  LArray: TArray<Integer>;
begin
  SetLength(LArray, 0);
  LEnum := &Array<Integer>.CreateEnumerator(LArray);
  CheckFalse(LEnum.MoveNext);

  SetLength(LArray, 1);
  LArray[0] := 10;

  LEnum := &Array<Integer>.CreateEnumerator(LArray);
  CheckTrue(LEnum.MoveNext);
  CheckEquals(10, LEnum.Current);
  CheckFalse(LEnum.MoveNext);
end;

procedure TTestArrayAlgorithms.TestSafeMove;
var
  A, B: array of String;
begin
  { Move 2 arrays safely }
  SetLength(A, 4);
  SetLength(B, 4);

  A[0] := 'Element 0';
  A[1] := 'Element 1';
  A[2] := 'Element 2';
  A[3] := 'Element 3';

  &Array<String>.SafeMove(A, B, 0, 0, 4, TType<String>.Default);

  Check(StringRefCount(A[0]) = 2, 'A[0] should be referenced 2 times');
  Check(StringRefCount(B[0]) = 2, 'B[0] should be referenced 2 times');
  Check(StringRefCount(A[1]) = 2, 'A[1] should be referenced 2 times');
  Check(StringRefCount(B[1]) = 2, 'B[1] should be referenced 2 times');
  Check(StringRefCount(A[2]) = 2, 'A[2] should be referenced 2 times');
  Check(StringRefCount(B[2]) = 2, 'B[2] should be referenced 2 times');
  Check(StringRefCount(A[3]) = 2, 'A[3] should be referenced 2 times');
  Check(StringRefCount(B[3]) = 2, 'B[3] should be referenced 2 times');

  Check(B[0] = 'Element 0', 'B[0] expected to be equal to "Element 0"');
  Check(B[1] = 'Element 1', 'B[1] expected to be equal to "Element 1"');
  Check(B[2] = 'Element 2', 'B[2] expected to be equal to "Element 2"');
  Check(B[3] = 'Element 3', 'B[3] expected to be equal to "Element 3"');
end;

procedure TTestArrayAlgorithms.TestToVariantArray;
var
  _AI: array of Integer;
  _AS: array of String;
  _AB: array of Boolean;

  _AO: array of TObject;

  __AI, __AS, __AB: Variant;
  I: Integer;
begin
  SetLength(_AI, 5);
  SetLength(_AS, 5);
  SetLength(_AB, 5);

  { Integers }
  _AI[0] := Random(MaxInt);
  _AI[1] := Random(MaxInt);
  _AI[2] := Random(MaxInt);
  _AI[3] := Random(MaxInt);
  _AI[4] := Random(MaxInt);

  { Strings }
  _AS[0] := IntToStr(Random(MaxInt));
  _AS[1] := IntToStr(Random(MaxInt));
  _AS[2] := IntToStr(Random(MaxInt));
  _AS[3] := IntToStr(Random(MaxInt));
  _AS[4] := IntToStr(Random(MaxInt));

  { Boolean }
  _AB[0] := Boolean(Random(MaxInt));
  _AB[1] := Boolean(Random(MaxInt));
  _AB[2] := Boolean(Random(MaxInt));
  _AB[3] := Boolean(Random(MaxInt));
  _AB[4] := Boolean(Random(MaxInt));

  { ... Obtain variant arrays }
  __AI := &Array<Integer>.ToVariantArray(_AI);
  __AS := &Array<String>.ToVariantArray(_AS);
  __AB := &Array<Boolean>.ToVariantArray(_AB);

  for I := 0 to 4 do
  begin
    Check(__AI[I] = _AI[I], 'Copy failed for integer array');
    Check(__AS[I] = _AS[I], 'Copy failed for string array');
    Check(__AB[I] = _AB[I], 'Copy failed for boolean array');
  end;

  SetLength(_AO, 1);

  CheckException(ETypeIncompatibleWithVariantArray,
    procedure()
    begin
      &Array<TObject>.ToVariantArray(_AO);
    end,
    'ETypeIncompatibleWithVariantArray not thrown in ToVariantArray (wrong element type)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      &Array<Integer>.ToVariantArray(_AI, nil);
    end,
    'ENilArgumentException not thrown in ToVariantArray (nil type)'
  );
end;

initialization
  TestFramework.RegisterTest(TTestArrayAlgorithms.Suite);
end.

