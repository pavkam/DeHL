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
unit Tests.FixedArray;
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
 TTestFixedArray = class(TDeHLTestCase)
 published
   procedure TestCreation();
   procedure TestIndexer();
   procedure TestConsume();
   procedure TestEnumerator();

   procedure TestToVariantArray;
   procedure TestTypeSupport;
 end;

implementation

{ TTestFixedArray }

procedure TTestFixedArray.TestConsume;
var
  Arr: TFixedArray<Integer>;
  IL: TArray<Integer>;
begin
  SetLength(IL, 3);

  IL[0] := 100;
  IL[1] := 200;
  IL[2] := 300;

  Arr := TFixedArray<Integer>.Consume(IL);

  Check(Arr.Length = 3, 'Array length expected to be 3');

  Check(Arr[0] = 100, 'Arr[0] expected to be 100');
  Check(Arr[1] = 200, 'Arr[1] expected to be 200');
  Check(Arr[2] = 300, 'Arr[2] expected to be 300');
end;

procedure TTestFixedArray.TestCreation;
var
  Arr, Arr2    : TFixedArray<Integer>;
  ASupport : IType<Integer>;
begin
  ASupport := TType<Integer>.Default;

  Arr := TFixedArray<Integer>.Create([1, 2, 3]);
  Check(Arr.Length = 3, 'Array length expected to be 3');

  Check(Arr[0] = 1, 'Arr[0] expected to be 1');
  Check(Arr[1] = 2, 'Arr[1] expected to be 2');
  Check(Arr[2] = 3, 'Arr[2] expected to be 3');

  { Check with no init }
  Check(Arr2.Length = 0, 'Length of Arr2 expected to be 0');
end;

procedure TTestFixedArray.TestEnumerator;
var
  LEnum: IEnumerator<Integer>;
  LArray: TFixedArray<Integer>;
begin
  LEnum := LArray.GetEnumerator;
  CheckFalse(LEnum.MoveNext);

  LArray := TFixedArray<Integer>.Create([10]);

  LEnum := LArray.GetEnumerator;
  CheckTrue(LEnum.MoveNext);
  CheckEquals(10, LEnum.Current);
  CheckFalse(LEnum.MoveNext);
end;

procedure TTestFixedArray.TestIndexer;
var
  Arr: TFixedArray<String>;
begin
  Arr := TFixedArray<String>.Create(['Alex', 'John', 'Mary']);

  Check(Arr.Length = 3, 'Length is expected to be 3');
  Check(Arr[0] = 'Alex', 'Expected Arr[0] = "Alex"');
  Check(Arr[1] = 'John', 'Expected Arr[1] = "John"');
  Check(Arr[2] = 'Mary', 'Expected Arr[2] = "Mary"');

  CheckException(EArgumentOutOfRangeException,
    procedure()
    begin
      if (Arr[3] = '') then exit;
    end,
    'EArgumentOutOfRangeException not thrown in indexer.'
  );
end;

procedure TTestFixedArray.TestToVariantArray;
var
  _AI: TFixedArray<Integer>;
  _AS: TFixedArray<String>;
  _AB: TFixedArray<Boolean>;

  _AO: TFixedArray<TObject>;

  __AI, __AS, __AB: Variant;
  I: Integer;
begin
  _AI := TFixedArray<Integer>.Create([Random(MaxInt), Random(MaxInt), Random(MaxInt), Random(MaxInt), Random(MaxInt)]);
  _AS := TFixedArray<String>.Create([IntToStr(Random(MaxInt)), IntToStr(Random(MaxInt)), IntToStr(Random(MaxInt)),
    IntToStr(Random(MaxInt)), IntToStr(Random(MaxInt))]);
  _AB := TFixedArray<Boolean>.Create([Boolean(Random(MaxInt)), Boolean(Random(MaxInt)), Boolean(Random(MaxInt)),
    Boolean(Random(MaxInt)), Boolean(Random(MaxInt))]);

  _AO := TFixedArray<TObject>.Create([nil]);

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

procedure TTestFixedArray.TestTypeSupport;
var
  DefaultSupport: IType<TFixedArray<Integer>>;
  v1, v2        : TFixedArray<Integer>;
begin
  DefaultSupport := TType<TFixedArray<Integer>>.Default;

  { Normal }
  v1 := TFixedArray<Integer>.Create([1, 1]);
  v2 := TFixedArray<Integer>.Create([1, 2]);

  { Default }
  Check(DefaultSupport.Compare(v1, v2) < 0, '(Default) Expected v1 < v2');
  Check(DefaultSupport.Compare(v2, v1) > 0, '(Default) Expected v2 > v1');
  Check(DefaultSupport.Compare(v1, v1) = 0, '(Default) Expected v1 = v1');

  Check(DefaultSupport.AreEqual(v1, v1), '(Default) Expected v1 eq v1');
  Check(not DefaultSupport.AreEqual(v1, v2), '(Default) Expected v1 neq v2');

  Check(DefaultSupport.GenerateHashCode(v1) <> DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v1 neq v2');
  Check(DefaultSupport.GenerateHashCode(v2) = DefaultSupport.GenerateHashCode(v2), '(Default) Expected hashcode v2 eq v2');

  Check(DefaultSupport.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(DefaultSupport.Name = 'TFixedArray<System.Integer>', 'Type Name = "TFixedArray<System.Integer>"');
  Check(DefaultSupport.Size = 4, 'Type Size = 4');
  Check(DefaultSupport.TypeInfo = TypeInfo(TFixedArray<Integer>), 'Type information provider failed!');
  Check(DefaultSupport.Family = tfArray, 'Type Family = tfArray');

  v1 := TFixedArray<Integer>.Create([1, 2, 3]);
  Check(DefaultSupport.GetString(v1) = '(3 Elements)', '(Default) Expected GetString() = "(3 Elements)"');
end;

initialization
  TestFramework.RegisterTest(TTestFixedArray.Suite);

end.
