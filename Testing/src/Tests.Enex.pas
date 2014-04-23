(*
* Copyright (c) 2009-2010, Ciobanu Alexandru
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
unit Tests.Enex;
interface
uses SysUtils,
     Math,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Math.Algorithms,
     DeHL.Arrays,
     DeHL.WideCharSet,
     DeHL.Tuples,
     DeHL.Collections.Base,
     DeHL.Collections.Heap,
     DeHL.Collections.List,
     DeHL.Collections.SortedList,
     DeHL.Collections.ArraySet,
     DeHL.Collections.Bag,
     DeHL.Collections.SortedBag,
     DeHL.Collections.Dictionary,
     DeHL.Collections.SortedDictionary,
     DeHL.Collections.HashSet,
     DeHL.Collections.SortedSet,
     DeHL.Collections.LinkedList,
     DeHL.Collections.MultiMap,
     DeHL.Collections.SortedMultiMap,
     DeHL.Collections.DoubleSortedMultiMap,
     DeHL.Collections.DistinctMultiMap,
     DeHL.Collections.SortedDistinctMultiMap,
     DeHL.Collections.DoubleSortedDistinctMultiMap,
     DeHL.Collections.BidiMap,
     DeHL.Collections.SortedBidiMap,
     DeHL.Collections.DoubleSortedBidiMap,
     DeHL.Collections.Queue,
     DeHL.Collections.PriorityQueue,
     DeHL.Collections.Stack,
     DeHL.Collections.LinkedStack;

const
  ListElements = 1000;
  ListMax = 1000;

type
 TEnexCollectionInternalProc = procedure(const Collection: IEnexCollection<Integer>) of object;
 TEnexAssocCollectionInternalProc = procedure(const Collection: IEnexAssociativeCollection<Integer, Integer>) of object;

 TTestEnex = class(TDeHLTestCase)
 private
   { COMMON TO ALL }
   procedure InternalEnexTestGetCount(const Collection: IEnexCollection<Integer>);
   procedure InternalEnexTestEmpty(const Collection: IEnexCollection<Integer>);
   procedure InternalEnexTestCopyTo(const Collection: IEnexCollection<Integer>);
   procedure InternalEnexTestToArray(const Collection: IEnexCollection<Integer>);
   procedure InternalEnexTestToFixedArray(const Collection: IEnexCollection<Integer>);
   procedure InternalEnexTestToDynamicArray(const Collection: IEnexCollection<Integer>);
   procedure InternalEnexTestSingle(const Collection: IEnexCollection<Integer>);
   procedure InternalEnexTestSingleOrDefault(const Collection: IEnexCollection<Integer>);

   procedure InternalAssocEnexTestGetCount(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalAssocEnexTestEmpty(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalAssocEnexTestCopyTo(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalAssocEnexTestToArray(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalAssocEnexTestToDynamicArray(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalAssocEnexTestToFixedArray(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalAssocEnexTestSingle(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalAssocEnexTestSingleOrDefault(const Collection: IEnexAssociativeCollection<Integer, Integer>);

   { IEnexAssociativeCollection only }
   procedure InternalTestMinKey(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestMaxKey(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestMinValue(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestMaxValue(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestValueForKey(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestKeyHasValue(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestAssocWhere(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestAssocWhereNot(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestIncludes(const Collection: IEnexAssociativeCollection<Integer, Integer>);

   procedure InternalTestDistinctByKeys(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestDistinctByValues(const Collection: IEnexAssociativeCollection<Integer, Integer>);

   procedure InternalTestWhereKeyLower(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereKeyLowerOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereKeyGreater(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereKeyGreaterOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereKeyBetween(const Collection: IEnexAssociativeCollection<Integer, Integer>);

   procedure InternalTestWhereValueLower(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereValueLowerOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereValueGreater(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereValueGreaterOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
   procedure InternalTestWhereValueBetween(const Collection: IEnexAssociativeCollection<Integer, Integer>);

   procedure InternalTestToDictionary(const Collection: IEnexAssociativeCollection<Integer, Integer>);

   { IEnexCollection only }
   procedure InternalTestMin(const Collection: IEnexCollection<Integer>);
   procedure InternalTestMax(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirst(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstOrDefault(const Collection: IEnexCollection<Integer>);

   procedure InternalTestFirstWhere(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereNot(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereNotOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereLower(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereLowerOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereLowerOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereLowerOrEqualOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereGreater(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereGreaterOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereGreaterOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereGreaterOrEqualOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereBetween(const Collection: IEnexCollection<Integer>);
   procedure InternalTestFirstWhereBetweenOrDefault(const Collection: IEnexCollection<Integer>);

   procedure InternalTestLast(const Collection: IEnexCollection<Integer>);
   procedure InternalTestLastOrDefault(const Collection: IEnexCollection<Integer>);

   procedure InternalTestAggregate(const Collection: IEnexCollection<Integer>);
   procedure InternalTestAggregateOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestElementAt(const Collection: IEnexCollection<Integer>);
   procedure InternalTestElementAtOrDefault(const Collection: IEnexCollection<Integer>);
   procedure InternalTestAny(const Collection: IEnexCollection<Integer>);
   procedure InternalTestAll(const Collection: IEnexCollection<Integer>);
   procedure InternalTestEqualTo(const Collection: IEnexCollection<Integer>);

   procedure InternalTestWhere(const Collection: IEnexCollection<Integer>);
   procedure InternalTestWhereNot(const Collection: IEnexCollection<Integer>);
   procedure InternalTestWhereLower(const Collection: IEnexCollection<Integer>);
   procedure InternalTestWhereLowerOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestWhereGreater(const Collection: IEnexCollection<Integer>);
   procedure InternalTestWhereGreaterOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestWhereBetween(const Collection: IEnexCollection<Integer>);

   procedure InternalTestDistinct(const Collection: IEnexCollection<Integer>);
   procedure InternalTestOrdered(const Collection: IEnexCollection<Integer>);
   procedure InternalTestReversed(const Collection: IEnexCollection<Integer>);
   procedure InternalTestConcat(const Collection: IEnexCollection<Integer>);
   procedure InternalTestUnion(const Collection: IEnexCollection<Integer>);
   procedure InternalTestExclude(const Collection: IEnexCollection<Integer>);
   procedure InternalTestIntersect(const Collection: IEnexCollection<Integer>);
   procedure InternalTestRange(const Collection: IEnexCollection<Integer>);

   procedure InternalTestTake(const Collection: IEnexCollection<Integer>);
   procedure InternalTestTakeWhile(const Collection: IEnexCollection<Integer>);
   procedure InternalTestTakeWhileLower(const Collection: IEnexCollection<Integer>);
   procedure InternalTestTakeWhileLowerOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestTakeWhileGreater(const Collection: IEnexCollection<Integer>);
   procedure InternalTestTakeWhileGreaterOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestTakeWhileBetween(const Collection: IEnexCollection<Integer>);

   procedure InternalTestSkip(const Collection: IEnexCollection<Integer>);
   procedure InternalTestSkipWhile(const Collection: IEnexCollection<Integer>);
   procedure InternalTestSkipWhileLower(const Collection: IEnexCollection<Integer>);
   procedure InternalTestSkipWhileLowerOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestSkipWhileGreater(const Collection: IEnexCollection<Integer>);
   procedure InternalTestSkipWhileGreaterOrEqual(const Collection: IEnexCollection<Integer>);
   procedure InternalTestSkipWhileBetween(const Collection: IEnexCollection<Integer>);

   procedure InternalTestToList(const Collection: IEnexCollection<Integer>);
   procedure InternalTestToSet(const Collection: IEnexCollection<Integer>);

   { Testing }
   procedure TestGenericEnexCollection(const TestProc: TEnexCollectionInternalProc);
   procedure TestGenericAssocEnexCollection(const TestProc: TEnexAssocCollectionInternalProc);

 published
   { Collections }
   procedure TestWhereCollection();
   procedure TestSelectCollection();
   procedure TestSelectClassCollection();
   procedure TestCastCollection();
   procedure TestConcatCollection();
   procedure TestUnionCollection();
   procedure TestExclusionCollection();
   procedure TestIntersectionCollection();
   procedure TestDistinctCollection();
   procedure TestRangeCollection();
   procedure TestSkipCollection();
   procedure TestTakeCollection();
   procedure TestSkipWhileCollection();
   procedure TestTakeWhileCollection();
   procedure TestFillCollection();
   procedure TestIntervalCollection();
   procedure TestWrapCollection();

   { Associative collections }
   procedure TestAssociativeWrapCollection();
   procedure TestSelectKeysCollection();
   procedure TestSelectValuesCollection();
   procedure TestAssociativeWhereCollection();

   procedure TestDistinctByKeysCollection();
   procedure TestDistinctByValuesCollection();

   { Functionality }
   procedure TestEmpty();
   procedure TestGetCount();
   procedure TestMin();
   procedure TestMax();
   procedure TestMinKey();
   procedure TestMaxKey();
   procedure TestMinValue();
   procedure TestMaxValue();
   procedure TestValueForKey();
   procedure TestKeyHasValue();
   procedure TestFirst();
   procedure TestFirstOrDefault();

   procedure TestFirstWhere();
   procedure TestFirstWhereOrDefault();
   procedure TestFirstWhereNot();
   procedure TestFirstWhereNotOrDefault();
   procedure TestFirstWhereLower();
   procedure TestFirstWhereLowerOrDefault();
   procedure TestFirstWhereLowerOrEqual();
   procedure TestFirstWhereLowerOrEqualOrDefault();
   procedure TestFirstWhereGreater();
   procedure TestFirstWhereGreaterOrDefault();
   procedure TestFirstWhereGreaterOrEqual();
   procedure TestFirstWhereGreaterOrEqualOrDefault();
   procedure TestFirstWhereBetween();
   procedure TestFirstWhereBetweenOrDefault();

   procedure TestLast();
   procedure TestLastOrDefault();
   procedure TestSingle();
   procedure TestSingleOrDefault();
   procedure TestAggregate();
   procedure TestAggregateOrDefault();
   procedure TestElementAt();
   procedure TestElementAtOrDefault();
   procedure TestAny();
   procedure TestAll();
   procedure TestEqualTo();
   procedure TestIncludes();
   procedure TestSelect2();
   procedure TestSelect3();
   procedure TestCast();

   procedure TestAssocWhere();
   procedure TestAssocWhereNot();

   procedure TestDistinctByKeys();
   procedure TestDistinctByValues();

   procedure TestWhereKeyLower();
   procedure TestWhereKeyLowerOrEqual();
   procedure TestWhereKeyGreater();
   procedure TestWhereKeyGreaterOrEqual();
   procedure TestWhereKeyBetween();

   procedure TestWhereValueLower();
   procedure TestWhereValueLowerOrEqual();
   procedure TestWhereValueGreater();
   procedure TestWhereValueGreaterOrEqual();
   procedure TestWhereValueBetween();

   procedure TestWhere();
   procedure TestWhereNot();
   procedure TestWhereLower();
   procedure TestWhereLowerOrEqual();
   procedure TestWhereGreater();
   procedure TestWhereGreaterOrEqual();
   procedure TestWhereBetween();

   procedure TestDistinct();
   procedure TestOrdered();
   procedure TestReversed();
   procedure TestConcat();
   procedure TestUnion();
   procedure TestExclude();
   procedure TestIntersect();
   procedure TestRange();

   procedure TestTake();
   procedure TestTakeWhile();
   procedure TestTakeWhileLower();
   procedure TestTakeWhileLowerOrEqual();
   procedure TestTakeWhileGreater();
   procedure TestTakeWhileGreaterOrEqual();
   procedure TestTakeWhileBetween();

   procedure TestSkip();
   procedure TestSkipWhile();
   procedure TestSkipWhileLower();
   procedure TestSkipWhileLowerOrEqual();
   procedure TestSkipWhileGreater();
   procedure TestSkipWhileGreaterOrEqual();
   procedure TestSkipWhileBetween();

   procedure TestToList();
   procedure TestToSet();
   procedure TestToDictionary();

   procedure TestCopyTo();
   procedure TestToArray();
   procedure TestToFixedArray();
   procedure TestToDynamicArray();

   { Statics }
   procedure TestFill();
   procedure TestInterval();

   { Misc }
   procedure TestLongChain();
 end;

 TTestEnexOther = class(TDeHLTestCase)
 published
   procedure TestObjEquals_Simple;
   procedure TestObjContains_Simple;
   procedure TestObjCompareTo_Simple;
   procedure TestObjHashCode_Simple;
 end;

implementation

var
   { All types of pre-made collections }
   LHeap_Full,
   LList_Full,
   LSortedList_Full,
   LAraySet_Full,
   LBag_Full,
   LSortedBag_Full,
   LHashSet_Full,
   LSortedSet_Full,
   LLinkedList_Full,
   LQueue_Full,
   LLinkedQueue_Full,
   LStack_Full,
   LLinkedStack_Full,
   LWrapColl_Full,
   LFillColl_Full,
   LIntervalColl_Full,
   LWhereColl_Full,
   LSelectColl_Full,
   LCastColl_Full,
   LConcatColl_Full,
   LUnionColl_Full,
   LExclColl_Full,
   LInterColl_Full,
   LDistinctColl_Full,
   LRangeColl_Full,
   LSkipColl_Full,
   LTakeColl_Full,
   LSkipWhileColl_Full,
   LTakeWhileColl_Full,
   LSelectKeysColl_Full,
   LSelectValuesColl_Full,
   LDictKey_Full,
   LDictVal_Full,
   LSoDictKey_Full,
   LSoDictVal_Full,
   LSoMMKey_Full,
   LSoMMVal_Full,
   LDoSoMMKey_Full,
   LDoSoMMVal_Full,
   LMMKey_Full,
   LMMVal_Full,
   LSoBDMKey_Full,
   LSoBDMVal_Full,
   LDoSoBDMKey_Full,
   LDoSoBDMVal_Full,
   LBDMKey_Full,
   LBDMVal_Full,
   LSoSMKey_Full,
   LSoSMVal_Full,
   LDoSoSMKey_Full,
   LDoSoSMVal_Full,
   LSMKey_Full,
   LSMVal_Full: IEnexCollection<Integer>;

   LHeap_One,
   LList_One,
   LSortedList_One,
   LAraySet_One,
   LBag_One,
   LSortedBag_One,
   LHashSet_One,
   LSortedSet_One,
   LLinkedList_One,
   LQueue_One,
   LLinkedQueue_One,
   LStack_One,
   LLinkedStack_One,
   LWrapColl_One,
   LFillColl_One,
   LIntervalColl_One,
   LWhereColl_One,
   LSelectColl_One,
   LCastColl_One,
   LConcatColl_One,
   LUnionColl_One,
   LExclColl_One,
   LInterColl_One,
   LDistinctColl_One,
   LRangeColl_One,
   LSkipColl_One,
   LTakeColl_One,
   LSkipWhileColl_One,
   LTakeWhileColl_One,
   LSelectKeysColl_One,
   LSelectValuesColl_One,
   LDictKey_One,
   LDictVal_One,
   LSoDictKey_One,
   LSoDictVal_One,
   LSoMMKey_One,
   LSoMMVal_One,
   LDoSoMMKey_One,
   LDoSoMMVal_One,
   LMMKey_One,
   LMMVal_One,
   LSoBDMKey_One,
   LSoBDMVal_One,
   LDoSoBDMKey_One,
   LDoSoBDMVal_One,
   LBDMKey_One,
   LBDMVal_One,
   LSoSMKey_One,
   LSoSMVal_One,
   LDoSoSMKey_One,
   LDoSoSMVal_One,
   LSMKey_One,
   LSMVal_One: IEnexCollection<Integer>;

   LHeap_Empty,
   LList_Empty,
   LSortedList_Empty,
   LAraySet_Empty,
   LBag_Empty,
   LSortedBag_Empty,
   LHashSet_Empty,
   LSortedSet_Empty,
   LLinkedList_Empty,
   LQueue_Empty,
   LLinkedQueue_Empty,
   LStack_Empty,
   LLinkedStack_Empty,
   LWrapColl_Empty,
   LWhereColl_Empty,
   LSelectColl_Empty,
   LCastColl_Empty,
   LConcatColl_Empty,
   LUnionColl_Empty,
   LExclColl_Empty,
   LInterColl_Empty,
   LDistinctColl_Empty,
   LRangeColl_Empty,
   LSkipColl_Empty,
   LTakeColl_Empty,
   LSkipWhileColl_Empty,
   LTakeWhileColl_Empty,
   LSelectKeysColl_Empty,
   LSelectValuesColl_Empty,
   LDictKey_Empty,
   LDictVal_Empty,
   LSoDictKey_Empty,
   LSoDictVal_Empty,
   LSoMMKey_Empty,
   LSoMMVal_Empty,
   LDoSoMMKey_Empty,
   LDoSoMMVal_Empty,
   LMMKey_Empty,
   LMMVal_Empty,
   LSoBDMKey_Empty,
   LSoBDMVal_Empty,
   LDoSoBDMKey_Empty,
   LDoSoBDMVal_Empty,
   LBDMKey_Empty,
   LBDMVal_Empty,
   LSoSMKey_Empty,
   LSoSMVal_Empty,
   LDoSoSMKey_Empty,
   LDoSoSMVal_Empty,
   LSMKey_Empty,
   LSMVal_Empty: IEnexCollection<Integer>;

   LAssocDByKeysColl_Full,
   LAssocDByValuesColl_Full,
   LAssocWrapColl_Full,
   LAssocWhereColl_Full,
   LAssocDByKeysColl_One,
   LAssocDByValuesColl_One,
   LAssocWrapColl_One,
   LAssocWhereColl_One,
   LAssocDByKeysColl_Empty,
   LAssocDByValuesColl_Empty,
   LAssocWrapColl_Empty,
   LAssocWhereColl_Empty: IEnexAssociativeCollection<Integer, Integer>;

   { Keeping references }
   LPrioQueue_Full,
   LPrioQueue_One,
   LPrioQueue_Empty: TPriorityQueue<Integer, Integer>;

   LDictionary_Full,
   LDictionary_One,
   LDictionary_Empty: TDictionary<Integer, Integer>;

   LSortedDictionary_Full,
   LSortedDictionary_One,
   LSortedDictionary_Empty: TSortedDictionary<Integer, Integer>;

   LMM_Full,
   LMM_One,
   LMM_Empty: TMultiMap<Integer, Integer>;

   LSoMM_Full,
   LSoMM_One,
   LSoMM_Empty: TSortedMultiMap<Integer, Integer>;

   LDoSoMM_Full,
   LDoSoMM_One,
   LDoSoMM_Empty: TDoubleSortedMultiMap<Integer, Integer>;

   LBDM_Full,
   LBDM_One,
   LBDM_Empty: TBidiMap<Integer, Integer>;

   LSoBDM_Full,
   LSoBDM_One,
   LSoBDM_Empty: TSortedBidiMap<Integer, Integer>;

   LDoSoBDM_Full,
   LDoSoBDM_One,
   LDoSoBDM_Empty: TDoubleSortedBidiMap<Integer, Integer>;

   LSM_Full,
   LSM_One,
   LSM_Empty: TDistinctMultiMap<Integer, Integer>;

   LSoSM_Full,
   LSoSM_One,
   LSoSM_Empty: TSortedDistinctMultiMap<Integer, Integer>;

   LDoSoSM_Full,
   LDoSoSM_One,
   LDoSoSM_Empty: TDoubleSortedDistinctMultiMap<Integer, Integer>;


function AverageOf(const Collection: IEnexCollection<Integer>): Integer;
var
  I, X: Integer;
begin
  Result := 0;
  X := 0;

  for I in Collection do
  begin
    Inc(Result, I);
    Inc(X);
  end;

  Result := Result div X;
end;

function MakeOrderedIntegerList(const AStart, AEnd: Cardinal): IEnexCollection<Integer>;
var
  List: TList<Integer>;
  I: Cardinal;
begin
  { Create a list and populate it with data }
  List := TList<Integer>.Create();

  for I := AStart to AEnd do
    List.Add(I);

  Result := List;
end;

function MakeOrderedIntegerDictionary(const AStart, AEnd: Cardinal): TDictionary<Integer, Integer>;
var
  Dict: TDictionary<Integer, Integer>;
  I: Cardinal;
begin
  { Create a list and populate it with data }
  Dict := TDictionary<Integer, Integer>.Create();

  for I := AStart to AEnd do
    Dict.Add(I, I + 1);

  Result := Dict;
end;

function MakeRandomIntegerDictionary(const AStart, AEnd, ARand: Cardinal): IDictionary<Integer, Integer>;
var
  Dict: TDictionary<Integer, Integer>;
  I: Cardinal;
begin
  { Create a list and populate it with data }
  Dict := TDictionary<Integer, Integer>.Create();

  for I := AStart to AEnd do
    Dict[Random(ARand)] := Random(ARand);

  Result := Dict;
end;

function MakeOrderedStringList(const AStart, AEnd: Cardinal): IEnexCollection<String>;
var
  List: TList<String>;
  I: Cardinal;
begin
  { Create a list and populate it with data }
  List := TList<String>.Create();

  for I := AStart to AEnd do
    List.Add(IntToStr(I));

  Result := List;
end;

function MakeRandomIntegerList(const ACount, AMax: Cardinal): IEnexCollection<Integer>;
var
  List: TList<Integer>;
  I: Cardinal;
begin
  Randomize;

  { Create a list and populate it with data }
  List := TList<Integer>.Create();

  for I := 0 to ACount - 1 do
    List.Add(Random(AMax));

  Result := List;
end;

{ TTestEnex }

procedure TTestEnex.InternalTestAggregate(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  I: Integer;
  Sum: Int64;
begin
  { Verify Call }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Aggregate(nil);
    end,
    'ENilArgumentException not thrown in Aggregate (nil selector).'
  );

  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  Sum := 0;

  if List.Count > 0 then
  begin
    for I := 0 to List.Count - 1 do
      Sum := Sum + List[I];

    Check(Collection.Aggregate(function(Arg1, Arg2:Integer): Integer begin Exit(Arg1 + Arg2) end) = Sum, 'Invalid Aggregate() value');
  end else
  begin
    { Verify constructors }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.Aggregate(function(Arg1, Arg2:Integer): Integer begin Exit(Arg1 + Arg2) end)
      end,
      'ECollectionEmptyException not thrown in Aggregate (0 Count).'
    );
  end;

  List.Free;
end;

procedure TTestEnex.InternalTestAggregateOrDefault(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  I: Integer;
  Sum: Int64;
begin
  { Verify Call }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.AggregateOrDefault(nil, -1);
    end,
    'ENilArgumentException not thrown in Aggregate (nil selector).'
  );

  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  Sum := 0;

  if List.Count > 0 then
  begin
    for I := 0 to List.Count - 1 do
      Sum := Sum + List[I];

    Check(Collection.AggregateOrDefault(function(Arg1, Arg2:Integer): Integer begin Exit(Arg1 + Arg2) end, -1) = Sum, 'Invalid AggregateOrDefault() value');
  end else
  begin
    Check(Collection.AggregateOrDefault(function(Arg1, Arg2:Integer): Integer begin Exit(Arg1 + Arg2) end, -1) = -1, 'Invalid AggregateOrDefault() value');
  end;

  List.Free;
end;

procedure TTestEnex.InternalTestAll(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  I: Integer;
  Condition: Boolean;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);
  Condition := true;

  if List.Count > 0 then
  begin
    for I := 0 to List.Count - 1 do
    begin
      if not (List[I] < (ListMax div 2)) then
      begin
        Condition := false;
        break;
      end;
    end;
  end;

  Check(Collection.All(function(Arg1: Integer): Boolean begin Exit(Arg1 < (ListMax div 2)) end) = Condition, 'Invalid All() value');

  List.Free;
end;

procedure TTestEnex.InternalTestAny(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  I: Integer;
  Condition: Boolean;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);
  Condition := false;

  if List.Count > 0 then
  begin
    for I := 0 to List.Count - 1 do
    begin
      if List[I] < (ListMax div 2) then
      begin
        Condition := true;
        break;
      end;
    end;
  end else
    Condition := false;

  Check(Collection.Any(function(Arg1: Integer): Boolean begin Exit(Arg1 < (ListMax div 2)) end) = Condition, 'Invalid All() value');

  List.Free;
end;

procedure TTestEnex.InternalTestAssocWhere(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;

begin
  { Check exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Where(nil);
    end,
    'ENilArgumentException not thrown in Where (nil type).'
  );

  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.Where(function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 > 50); end).Includes(WhereEnum), 'Failed at  > 50');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(not Odd(Arg1)); end, TType<Integer>.Default, TType<Integer>.Default, True);

  Check(Collection.Where(function(Arg1, Arg2: Integer): Boolean begin Exit(Odd(Arg1)); end).Includes(WhereEnum), 'Failed at Odd');
end;

procedure TTestEnex.InternalTestAssocWhereNot(
  const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;

begin
  { Check exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.WhereNot(nil);
    end,
    'ENilArgumentException not thrown in Where (nil type).'
  );

  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default, TType<Integer>.Default, True);

  Check(Collection.WhereNot(function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 > 50); end).Includes(WhereEnum), 'Failed at > 50');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Odd(Arg1)); end, TType<Integer>.Default, TType<Integer>.Default, True);

  Check(Collection.WhereNot(function(Arg1, Arg2: Integer): Boolean begin Exit(Odd(Arg1)); end).Includes(WhereEnum), 'Failed at Odd');
end;

procedure TTestEnex.InternalTestConcat(const Collection: IEnexCollection<Integer>);
var
  Enum1: IEnexCollection<Integer>;
  ConcatEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeRandomIntegerList(ListElements, ListMax);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Concat(nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  { Now apply predicates }
  ConcatEnum := TEnexConcatCollection<Integer>.CreateIntf(Collection, Enum1, TType<Integer>.Default);
  Check(Collection.Concat(Enum1).EqualsTo(ConcatEnum), 'Concat failed!');
end;

procedure TTestEnex.InternalAssocEnexTestCopyTo(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
  Arr: array of KVPair<Integer, Integer>;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);

  { Initialize an array }
  SetLength(Arr, 0);

  { Verify proper exceptions }
  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.CopyTo(Arr, 1);
    end,
    'EArgumentOutOfRangeException not thrown in CopyTo (0 - 1).'
  );

  if List.Count > 1 then
  begin
  	{ Initialize an array }
  	SetLength(Arr, List.Count - 1);

  	{ Verify proper exceptions }
    CheckException(EArgumentOutOfSpaceException,
      procedure() begin
        Collection.CopyTo(Arr);
      end,
      'EArgumentOutOfSpaceException not thrown in CopyTo (N-1 - 1).'
    );

    { Initialize an array }
    SetLength(Arr, List.Count);

    { Verify proper exceptions }
    CheckException(EArgumentOutOfSpaceException,
      procedure() begin
        Collection.CopyTo(Arr, 1);
      end,
      'EArgumentOutOfSpaceException not thrown in CopyTo (N - 1).'
    );
  end;

  if List.Count = 1 then
  begin
  	{ Initialize an array }
  	SetLength(Arr, List.Count - 1);

  	{ Verify proper exceptions }
    CheckException(EArgumentOutOfRangeException,
      procedure() begin
        Collection.CopyTo(Arr);
      end,
      'EArgumentOutOfRangeException not thrown in CopyTo (N-1 - 1).'
    );

    { Verify proper exceptions }
    CheckException(EArgumentOutOfRangeException,
      procedure() begin
        Collection.CopyTo(Arr, 1);
      end,
      'EArgumentOutOfRangeException not thrown in CopyTo (N - 1).'
    );
  end;


  { Now to a real test over the elements }
  if List.Count > 0 then
  begin
    SetLength(Arr, List.Count);
    Collection.CopyTo(Arr);

    for I := 0 to Length(Arr) - 1 do
      Check((Arr[I].Key = List[I].Key) and (Arr[I].Value = List[I].Value), 'CopyTo failed!');
  end;

  List.Free();
end;

procedure TTestEnex.InternalAssocEnexTestEmpty(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
begin
  { Create an ordered list }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);

  Check(Collection.Empty() = (List.Count = 0), 'Invalid Empty() value');

  List.Free;
end;

procedure TTestEnex.InternalAssocEnexTestGetCount(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
begin
  { Create an ordered list }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);

  Check(Collection.GetCount() = List.Count, 'Invalid GetCount() value');

  List.Free;
end;

procedure TTestEnex.InternalAssocEnexTestSingle(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
begin
  { Create an ordered list }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);

  if List.Count = 0 then
  begin
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.Single();
      end,
      'ECollectionEmptyException not thrown in Single (more than 1).'
    );
  end else
  if List.Count > 1 then
  begin
    CheckException(ECollectionNotOneException,
      procedure() begin
        Collection.Single();
      end,
      'ECollectionNotOneException not thrown in Single (more than 1).'
    );
  end else
    Check((Collection.Single().Key = List[0].Key) and (Collection.Single().Value = List[0].Value), 'Invalid Single() value');

  List.Free;
end;

procedure TTestEnex.InternalAssocEnexTestSingleOrDefault(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
  KV: KVPair<Integer, Integer>;
begin
  { Create an ordered list }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);
  KV := KVPair<Integer, Integer>.Create(-1, -1);

  if List.Count = 0 then
  begin
    KV := Collection.SingleOrDefault(KV);
    Check((KV.Key = -1) and (KV.Value = -1), 'Invalid SingleOrDefault() value');
  end else
  if List.Count > 1 then
  begin
    CheckException(ECollectionNotOneException,
      procedure() begin
        Collection.SingleOrDefault(KV);
      end,
      'ECollectionNotOneException not thrown in Single (more than 1).'
    );
  end else
  begin
    KV := Collection.SingleOrDefault(KV);
    Check((KV.Key = List[0].Key) and (KV.Value = List[0].Value), 'Invalid SingleOrDefault() value');
  end;

  List.Free;
end;

procedure TTestEnex.InternalAssocEnexTestToDynamicArray(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
  Arr: TDynamicArray<KVPair<Integer, Integer>>;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);
  Arr := Collection.ToDynamicArray();

  Check(List.Count = Arr.Length, 'Invalid count of elements copied');

  if List.Count > 0 then
    for I := 0 to List.Count - 1 do
      Check((List[I].Key = Arr[I].Key) and (List[I].Value = Arr[I].Value), 'Invalid elements copied!');

  List.Free();
end;

procedure TTestEnex.InternalAssocEnexTestToFixedArray(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
  Arr: TFixedArray<KVPair<Integer, Integer>>;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);
  Arr := Collection.ToFixedArray();

  Check(List.Count = Arr.Length, 'Invalid count of elements copied');

  if List.Count > 0 then
    for I := 0 to List.Count - 1 do
      Check((List[I].Key = Arr[I].Key) and (List[I].Value = Arr[I].Value), 'Invalid elements copied!');

  List.Free();
end;

procedure TTestEnex.InternalAssocEnexTestToArray(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  List: TList<KVPair<Integer, Integer>>;
  Arr: TArray<KVPair<Integer, Integer>>;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<KVPair<Integer, Integer>>.Create(Collection);
  Arr := Collection.ToArray();

  Check(List.Count = Length(Arr), 'Invalid count of elements copied');

  if List.Count > 0 then
    for I := 0 to List.Count - 1 do
      Check((List[I].Key = Arr[I].Key) and (List[I].Value = Arr[I].Value), 'Invalid elements copied!');

  List.Free();
end;

procedure TTestEnex.InternalEnexTestCopyTo(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  Arr: array of Integer;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<Integer>.Create(Collection);

  { Initialize an array }
  SetLength(Arr, 0);

  { Verify proper exceptions }
  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.CopyTo(Arr, 1);
    end,
    'EArgumentOutOfRangeException not thrown in CopyTo (0 - 1).'
  );

  if List.Count > 1 then
  begin
  	{ Initialize an array }
  	SetLength(Arr, List.Count - 1);

  	{ Verify proper exceptions }
    CheckException(EArgumentOutOfSpaceException,
      procedure() begin
        Collection.CopyTo(Arr);
      end,
      'EArgumentOutOfSpaceException not thrown in CopyTo (N-1 - 1).'
    );

    { Initialize an array }
    SetLength(Arr, List.Count);

    { Verify proper exceptions }
    CheckException(EArgumentOutOfSpaceException,
      procedure() begin
        Collection.CopyTo(Arr, 1);
      end,
      'EArgumentOutOfSpaceException not thrown in CopyTo (N - 1).'
    );
  end;

  if List.Count = 1 then
  begin
  	{ Initialize an array }
  	SetLength(Arr, List.Count - 1);

  	{ Verify proper exceptions }
    CheckException(EArgumentOutOfRangeException,
      procedure() begin
        Collection.CopyTo(Arr);
      end,
      'EArgumentOutOfRangeException not thrown in CopyTo (N-1 - 1).'
    );

    { Verify proper exceptions }
    CheckException(EArgumentOutOfRangeException,
      procedure() begin
        Collection.CopyTo(Arr, 1);
      end,
      'EArgumentOutOfRangeException not thrown in CopyTo (N - 1).'
    );
  end;


  { Now to a real test over the elements }
  if List.Count > 0 then
  begin
    SetLength(Arr, List.Count);
    Collection.CopyTo(Arr);

    for I := 0 to Length(Arr) - 1 do
      Check(Arr[I] = List[I], 'CopyTo failed!');
  end;

  List.Free();
end;

procedure TTestEnex.InternalTestDistinct(const Collection: IEnexCollection<Integer>);
var
  DistinctEnum: IEnexCollection<Integer>;
begin
  DistinctEnum := TEnexDistinctCollection<Integer>.CreateIntf(Collection, TType<Integer>.Default);
  Check(Collection.Distinct().EqualsTo(DistinctEnum), 'Distinct() failed!');
end;

procedure TTestEnex.InternalTestDistinctByKeys(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  XEnum, YEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  XEnum := Collection.DistinctByKeys;
  YEnum := TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.CreateIntf(Collection, TType<Integer>.Default,
    TType<Integer>.Default);

  Check(XEnum.Includes(YEnum), 'XEnum should include YEnum');
  Check(YEnum.Includes(XEnum), 'YEnum should include XEnum');
end;

procedure TTestEnex.InternalTestDistinctByValues(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  XEnum, YEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  XEnum := Collection.DistinctByValues;
  YEnum := TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.CreateIntf(Collection, TType<Integer>.Default,
    TType<Integer>.Default);

  Check(XEnum.Includes(YEnum), 'XEnum should include YEnum');
  Check(YEnum.Includes(XEnum), 'YEnum should include XEnum');
end;

procedure TTestEnex.InternalTestElementAt(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  if List.Count = 0 then
  begin
    CheckException(EArgumentOutOfRangeException,
      procedure() begin
        Collection.ElementAt(0);
      end,
      'EArgumentOutOfRangeException not thrown in ElementAt (empty).'
    );
  end else
  begin
    CheckException(EArgumentOutOfRangeException,
      procedure() begin
        Collection.ElementAt(List.Count);
      end,
      'EArgumentOutOfRangeException not thrown in ElementAt (count).'
    );

    Check(Collection.ElementAt(0) = List[0], 'Failed at 0');
    Check(Collection.ElementAt(List.Count - 1) = List[List.Count - 1], 'Failed at Count - 1');
  end;

  List.Free;
end;

procedure TTestEnex.InternalTestElementAtOrDefault(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  if List.Count = 0 then
  begin
    Check(Collection.ElementAtOrDefault(0, -1) = -1, 'Failed at 0 (-1)');
    Check(Collection.ElementAtOrDefault(100, -2) = -2, 'Failed at 0 (-2)');
  end else
  begin
    Check(Collection.ElementAtOrDefault(0, -1) = List[0], 'Failed at 0');
    Check(Collection.ElementAtOrDefault(List.Count - 1, -1) = List[List.Count - 1], 'Failed at Count - 1');
    Check(Collection.ElementAtOrDefault(List.Count, -1) = -1, 'Failed at Count (-1)');
  end;

  List.Free;
end;

procedure TTestEnex.InternalEnexTestEmpty(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  Check(Collection.Empty() = (List.Count = 0), 'Invalid Empty() value');

  List.Free;
end;

procedure TTestEnex.InternalTestEqualTo(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create a list }
  List := TList<Integer>.Create(Collection);
  Check(Collection.EqualsTo(List), 'EqualsTo failed for the same Collection!');

  if List.Count > 0 then
  begin
    List.RemoveAt(0);
    Check(not Collection.EqualsTo(List), 'EqualsTo succeded for different Collections!');

    List.Clear();
    Check(not Collection.EqualsTo(List), 'EqualsTo succeded for different Collections (empty)!');
  end;

  List.Free;
end;

procedure TTestEnex.InternalTestExclude(const Collection: IEnexCollection<Integer>);
var
  Enum1: IEnexCollection<Integer>;
  ExcludeEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeRandomIntegerList(ListElements, ListMax);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Exclude(nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  { Now apply predicates }
  ExcludeEnum := TEnexExclusionCollection<Integer>.CreateIntf(Collection, Enum1, TType<Integer>.Default);
  Check(Collection.Exclude(Enum1).EqualsTo(ExcludeEnum), 'Concat failed!');
end;

procedure TTestEnex.InternalTestFirst(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  if List.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.First();
      end,
      'ECollectionEmptyException not thrown in First (0 Count).'
    );
  end else
    Check(Collection.First() = List[0], 'Invalid First() value');

  List.Free;
end;

procedure TTestEnex.InternalTestFirstOrDefault(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  I: Integer;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);
  I := Collection.FirstOrDefault(-1);

  if List.Count = 0 then
    Check(I = -1, 'Invalid FirstOrDefault() value')
  else
    Check(I = List[0], 'Invalid FirstOrDefault() value');

  List.Free;
end;

procedure TTestEnex.InternalTestFirstWhere(const Collection: IEnexCollection<Integer>);
var
  LLast: Integer;
begin
  { 1. Check for ENilArgumentException }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.FirstWhere(nil);
    end,
    'ENilArgumentException not thrown in FirstWhere (nil pred).'
  );

  if Collection.Empty then
  begin
    { 2. Check for ECollectionEmptyException on empty exceptions }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.FirstWhere(function(Arg1: Integer): Boolean
        begin
          Result := false;
        end);
      end,
      'ECollectionEmptyException not thrown in FirstWhere (0 Count).'
    );
  end else
  begin
    { 3. Check for ECollectionFilteredEmptyException no elements selected }
    CheckException(ECollectionFilteredEmptyException,
      procedure() begin
        Collection.FirstWhere(function(Arg1: Integer): Boolean
        begin
          Result := false;
        end);
      end,
      'ECollectionFilteredEmptyException not thrown in FirstWhere (N Count).'
    );

    LLast := Collection.Last();

    { 4. Check for good result }
    CheckEquals(LLast, Collection.FirstWhere(function(Arg1: Integer): Boolean
    begin
      Result := LLast = Arg1;
    end));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereBetween(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  { 1. Check for empty collection }
  if Collection.Empty then
  begin
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.FirstWhereBetween(1, 2);
      end,
      'ECollectionEmptyException not thrown in FirstWhereBetween (0 Count).'
    );
  end else
  begin
    { 2. Check for ECollectionFilteredEmptyException no elements selected }
    CheckException(ECollectionFilteredEmptyException,
      procedure() begin
        Collection.FirstWhereBetween(-100, -900);
      end,
      'ECollectionFilteredEmptyException not thrown in FirstWhereBetween (N Count).'
    );

    { 3. Check for good result }
    LElem := Collection.FirstWhereBetween(AverageOf(Collection) div 2, AverageOf(Collection));
    CheckTrue(LElem >= (AverageOf(Collection) div 2));
    CheckTrue(LElem <= AverageOf(Collection));
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereBetweenOrDefault(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  if Collection.Empty then
  begin
    CheckEquals(-100, Collection.FirstWhereBetweenOrDefault(1, 2, -100));
  end else
  begin
    CheckEquals(-100, Collection.FirstWhereBetweenOrDefault(-5, -10, -100));

    LElem := Collection.FirstWhereBetweenOrDefault(AverageOf(Collection) div 2, AverageOf(Collection), -100);
    CheckTrue(LElem >= (AverageOf(Collection) div 2));
    CheckTrue(LElem <= AverageOf(Collection));
    CheckNotEquals(LElem, -100);
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereGreater(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  { 1. Check for empty collection }
  if Collection.Empty then
  begin
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.FirstWhereGreater(1);
      end,
      'ECollectionEmptyException not thrown in FirstWhereGreater (0 Count).'
    );
  end else
  begin
    { 2. Check for ECollectionFilteredEmptyException no elements selected }
    CheckException(ECollectionFilteredEmptyException,
      procedure() begin
        Collection.FirstWhereGreater(MaxInt);
      end,
      'ECollectionFilteredEmptyException not thrown in FirstWhereGreater (N Count).'
    );

    { 3. Check for good result }
    LElem := Collection.FirstWhereGreater(AverageOf(Collection)-1);
    CheckTrue(LElem > AverageOf(Collection)-1);
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereGreaterOrDefault(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  if Collection.Empty then
  begin
    CheckEquals(-100, Collection.FirstWhereGreaterOrDefault(1, -100));
  end else
  begin
    CheckEquals(-100, Collection.FirstWhereGreaterOrDefault(MaxInt, -100));

    LElem := Collection.FirstWhereGreaterOrDefault(AverageOf(Collection)-1, -100);
    CheckTrue(LElem > AverageOf(Collection)-1);
    CheckNotEquals(LElem, -100);
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereGreaterOrEqual(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  { 1. Check for empty collection }
  if Collection.Empty then
  begin
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.FirstWhereGreaterOrEqual(1);
      end,
      'ECollectionEmptyException not thrown in FirstWhereGreaterOrEqual (0 Count).'
    );
  end else
  begin
    { 2. Check for ECollectionFilteredEmptyException no elements selected }
    CheckException(ECollectionFilteredEmptyException,
      procedure() begin
        Collection.FirstWhereGreaterOrEqual(MaxInt);
      end,
      'ECollectionFilteredEmptyException not thrown in FirstWhereGreaterOrEqual (N Count).'
    );

    { 3. Check for good result }
    LElem := Collection.FirstWhereGreaterOrEqual(AverageOf(Collection));
    CheckTrue(LElem >= AverageOf(Collection));
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereGreaterOrEqualOrDefault(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  if Collection.Empty then
  begin
    CheckEquals(-100, Collection.FirstWhereGreaterOrEqualOrDefault(1, -100));
  end else
  begin
    CheckEquals(-100, Collection.FirstWhereGreaterOrEqualOrDefault(MaxInt, -100));

    LElem := Collection.FirstWhereGreaterOrEqualOrDefault(AverageOf(Collection), -100);
    CheckTrue(LElem >= AverageOf(Collection));
    CheckNotEquals(LElem, -100);
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereLower(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  { 1. Check for empty collection }
  if Collection.Empty then
  begin
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.FirstWhereLower(1);
      end,
      'ECollectionEmptyException not thrown in FirstWhereLower (0 Count).'
    );
  end else
  begin
    { 2. Check for ECollectionFilteredEmptyException no elements selected }
    CheckException(ECollectionFilteredEmptyException,
      procedure() begin
        Collection.FirstWhereLower(-1);
      end,
      'ECollectionFilteredEmptyException not thrown in FirstWhereLower (N Count).'
    );

    { 3. Check for good result }
    LElem := Collection.FirstWhereLower(AverageOf(Collection)+1);
    CheckTrue(LElem < AverageOf(Collection)+1);
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereLowerOrDefault(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  if Collection.Empty then
  begin
    CheckEquals(-100, Collection.FirstWhereLowerOrDefault(1, -100));
  end else
  begin
    CheckEquals(-100, Collection.FirstWhereLowerOrDefault(-1, -100));

    LElem := Collection.FirstWhereLowerOrDefault(AverageOf(Collection)+1, -100);
    CheckTrue(LElem < AverageOf(Collection)+1);
    CheckNotEquals(LElem, -100);
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereLowerOrEqual(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  { 1. Check for empty collection }
  if Collection.Empty then
  begin
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.FirstWhereLowerOrEqual(1);
      end,
      'ECollectionEmptyException not thrown in FirstWhereLowerOrEqual (0 Count).'
    );
  end else
  begin
    { 2. Check for ECollectionFilteredEmptyException no elements selected }
    CheckException(ECollectionFilteredEmptyException,
      procedure() begin
        Collection.FirstWhereLowerOrEqual(-1);
      end,
      'ECollectionFilteredEmptyException not thrown in FirstWhereLowerOrEqual (N Count).'
    );

    { 3. Check for good result }
    LElem := Collection.FirstWhereLowerOrEqual(AverageOf(Collection));
    CheckTrue(LElem <= AverageOf(Collection));
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereLowerOrEqualOrDefault(const Collection: IEnexCollection<Integer>);
var
  LElem: Integer;
begin
  if Collection.Empty then
  begin
    CheckEquals(-100, Collection.FirstWhereLowerOrEqualOrDefault(1, -100));
  end else
  begin
    CheckEquals(-100, Collection.FirstWhereLowerOrEqualOrDefault(-1, -100));

    LElem := Collection.FirstWhereLowerOrEqualOrDefault(AverageOf(Collection), -100);
    CheckTrue(LElem <= AverageOf(Collection));
    CheckNotEquals(LElem, -100);
    CheckTrue(Collection.ToList.Contains(LElem));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereNot(const Collection: IEnexCollection<Integer>);
var
  LFirst: Integer;
begin
  { 1. Check for ENilArgumentException }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.FirstWhereNot(nil);
    end,
    'ENilArgumentException not thrown in FirstWhereNot (nil pred).'
  );

  if Collection.Empty then
  begin
    { 2. Check for ECollectionEmptyException on empty exceptions }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.FirstWhereNot(function(Arg1: Integer): Boolean
        begin
          Result := true;
        end);
      end,
      'ECollectionEmptyException not thrown in FirstWhereNot (0 Count).'
    );
  end else
  begin
    { 3. Check for ECollectionFilteredEmptyException no elements selected }
    CheckException(ECollectionFilteredEmptyException,
      procedure() begin
        Collection.FirstWhereNot(function(Arg1: Integer): Boolean
        begin
          Result := true;
        end);
      end,
      'ECollectionFilteredEmptyException not thrown in FirstWhereNot (N Count).'
    );

    LFirst := Collection.First();

    { 4. Check for good result }
    CheckEquals(LFirst, Collection.FirstWhereNot(function(Arg1: Integer): Boolean
    begin
      Result := LFirst <> Arg1;
    end));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereNotOrDefault(const Collection: IEnexCollection<Integer>);
var
  LFirst: Integer;
begin
  { 1. Check for ENilArgumentException }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.FirstWhereNotOrDefault(nil, 0);
    end,
    'ENilArgumentException not thrown in FirstWhereNotOrDefault (nil pred).'
  );

  if Collection.Empty then
  begin
    CheckEquals(-100, Collection.FirstWhereNotOrDefault(
      function(Arg1: Integer): Boolean
      begin
        Result := false;
      end,
      -100)
    );
  end else
  begin
    CheckEquals(-100, Collection.FirstWhereNotOrDefault(
      function(Arg1: Integer): Boolean
      begin
        Result := true;
      end,
      -100)
    );

    LFirst := Collection.First();

    { 4. Check for good result }
    CheckEquals(LFirst, Collection.FirstWhereNotOrDefault(function(Arg1: Integer): Boolean
    begin
      Result := LFirst <> Arg1;
    end, -100));
  end;
end;

procedure TTestEnex.InternalTestFirstWhereOrDefault(const Collection: IEnexCollection<Integer>);
var
  LLast: Integer;
begin
  { 1. Check for ENilArgumentException }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.FirstWhereOrDefault(nil, -1);
    end,
    'ENilArgumentException not thrown in FirstWhereOrDefault (nil pred).'
  );

  if Collection.Empty then
  begin
    CheckEquals(-100, Collection.FirstWhereOrDefault(
      function(Arg1: Integer): Boolean
      begin
        Result := false;
      end,
      -100)
    );
  end else
  begin
    CheckEquals(-100, Collection.FirstWhereOrDefault(
      function(Arg1: Integer): Boolean
      begin
        Result := false;
      end,
      -100)
    );

    LLast := Collection.Last();

    { 4. Check for good result }
    CheckEquals(LLast, Collection.FirstWhereOrDefault(function(Arg1: Integer): Boolean
    begin
      Result := LLast = Arg1;
    end, -100));
  end;
end;

procedure TTestEnex.InternalEnexTestGetCount(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  Check(Collection.GetCount() = List.Count, 'Invalid GetCount() value');

  List.Free;
end;

procedure TTestEnex.InternalTestIncludes(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  Dict: IDictionary<Integer, Integer>;
  KV: KVPair<Integer, Integer>;
begin
  Dict := TDictionary<Integer, Integer>.Create();

  for KV in Collection do
    Dict.SetItem(KV.Key, KV.Value);

  Dict.Add(-1, -1);

  Check(Collection.Includes(Collection), 'Collection is always set to include itself');
  Check(Dict.Includes(Collection), 'Dict is always set to include Collection');
  Check(not Collection.Includes(Dict), 'Collection does not include Dict');
end;

procedure TTestEnex.InternalTestIntersect(const Collection: IEnexCollection<Integer>);
var
  Enum1: IEnexCollection<Integer>;
  IntersectEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeRandomIntegerList(ListElements, ListMax);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Intersect(nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  { Now apply predicates }
  IntersectEnum := TEnexIntersectionCollection<Integer>.CreateIntf(Collection, Enum1, TType<Integer>.Default);
  Check(Collection.Intersect(Enum1).EqualsTo(IntersectEnum), 'Concat failed!');
end;

procedure TTestEnex.InternalTestKeyHasValue(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  Dict: IDictionary<Integer, Integer>;
  KV: KVPair<Integer, Integer>;
begin
  { Create an ordered list }
  Dict := TDictionary<Integer, Integer>.Create();

  for KV in Collection do
    Dict.SetItem(KV.Key, KV.Value);

  for KV in Dict do
    Check(Collection.KeyHasValue(KV.Key, KV.Value), 'ValueForKey failed for existing key!');

  { Bad case }
  Check(not Collection.KeyHasValue(-1, -1), 'ValueForKey failed for unexisting key!');
end;

procedure TTestEnex.InternalTestLast(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  if List.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.Last();
      end,
      'ECollectionEmptyException not thrown in Last (0 Count).'
    );
  end else
    Check(Collection.Last() = List[List.Count - 1], 'Invalid Last() value');

  List.Free;
end;

procedure TTestEnex.InternalTestLastOrDefault(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  I: Integer;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);
  I := Collection.LastOrDefault(-1);

  if List.Count = 0 then
    Check(I = -1, 'Invalid LastOrDefault() value')
  else
    Check(I = List[List.Count - 1], 'Invalid LastOrDefault() value');

  List.Free;
end;

procedure TTestEnex.InternalTestMax(const Collection: IEnexCollection<Integer>);
var
  OrList: TSortedList<Integer>;
begin
  { Create an ordered list }
  OrList := TSortedList<Integer>.Create(Collection);

  if OrList.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.Max();
      end,
      'ECollectionEmptyException not thrown in Max (0 Count).'
    );
  end else
    Check(Collection.Max() = OrList[OrList.Count - 1], 'Invalid Max() value');

  OrList.Free;
end;

procedure TTestEnex.InternalTestMaxKey(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  OrList: TSortedList<Integer>;
begin
  { Create an ordered list }
  OrList := TSortedList<Integer>.Create(Collection.SelectKeys());

  if OrList.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.MaxKey();
      end,
      'ECollectionEmptyException not thrown in MaxKey (0 Count).'
    );
  end else
    Check(Collection.MaxKey() = OrList[OrList.Count - 1], 'Invalid MaxKey() value');

  OrList.Free;
end;

procedure TTestEnex.InternalTestMaxValue(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  OrList: TSortedList<Integer>;
begin
  { Create an ordered list }
  OrList := TSortedList<Integer>.Create(Collection.SelectValues());

  if OrList.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.MaxValue();
      end,
      'ECollectionEmptyException not thrown in MaxValue (0 Count).'
    );
  end else
    Check(Collection.MaxValue() = OrList[OrList.Count - 1], 'Invalid MaxValue() value');

  OrList.Free;
end;

procedure TTestEnex.InternalTestMin(const Collection: IEnexCollection<Integer>);
var
  OrList: TSortedList<Integer>;
begin
  { Create an ordered list }
  OrList := TSortedList<Integer>.Create(Collection);

  if OrList.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.Min();
      end,
      'ECollectionEmptyException not thrown in Min (0 Count).'
    );
  end else
    Check(Collection.Min() = OrList[0], 'Invalid Min() value');

  OrList.Free;
end;

procedure TTestEnex.InternalTestMinKey(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  OrList: TSortedList<Integer>;
begin
  { Create an ordered list }
  OrList := TSortedList<Integer>.Create(Collection.SelectKeys());

  if OrList.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.MinKey();
      end,
      'ECollectionEmptyException not thrown in MinKey (0 Count).'
    );
  end else
    Check(Collection.MinKey() = OrList[0], 'Invalid MinKey() value');

  OrList.Free;
end;

procedure TTestEnex.InternalTestMinValue(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  OrList: TSortedList<Integer>;
begin
  { Create an ordered list }
  OrList := TSortedList<Integer>.Create(Collection.SelectValues());

  if OrList.Count = 0 then
  begin
    { Error! }
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.MinValue();
      end,
      'ECollectionEmptyException not thrown in MinValue (0 Count).'
    );
  end else
    Check(Collection.MinValue() = OrList[0], 'Invalid MinValue() value');

  OrList.Free;
end;

procedure TTestEnex.InternalTestRange(const Collection: IEnexCollection<Integer>);
var
  RangeEnum: IEnexCollection<Integer>;
begin

  { Test }
  RangeEnum := TEnexRangeCollection<Integer>.CreateIntf(Collection, 0, 0, TType<Integer>.Default);
  Check(Collection.Range(0, 0).EqualsTo(RangeEnum), 'Failed at 1');

  RangeEnum := TEnexRangeCollection<Integer>.CreateIntf(Collection, 200, 400, TType<Integer>.Default);
  Check(Collection.Range(200, 400).EqualsTo(RangeEnum), 'Failed at 2');

  RangeEnum := TEnexRangeCollection<Integer>.CreateIntf(Collection, 0, 1, TType<Integer>.Default);
  Check(Collection.Range(0, 1).EqualsTo(RangeEnum), 'Failed at 3');

  RangeEnum := TEnexRangeCollection<Integer>.CreateIntf(Collection, 0, 50, TType<Integer>.Default);
  Check(Collection.Range(0, 50).EqualsTo(RangeEnum), 'Failed at 4');

  RangeEnum := TEnexRangeCollection<Integer>.CreateIntf(Collection, 50, 200, TType<Integer>.Default);
  Check(Collection.Range(50, 200).EqualsTo(RangeEnum), 'Failed at 5');
end;

procedure TTestEnex.InternalTestReversed(const Collection: IEnexCollection<Integer>);
var
  AList: TList<Integer>;
begin
  AList := TList<Integer>.Create(Collection);
  AList.Reverse();

  Check(AList.EqualsTo(Collection.Reversed()), 'Sorted() Failed!');
  AList.Free;
end;

procedure TTestEnex.InternalEnexTestSingle(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  if List.Count = 0 then
  begin
    CheckException(ECollectionEmptyException,
      procedure() begin
        Collection.Single();
      end,
      'ECollectionEmptyException not thrown in Single (more than 1).'
    );
  end else
  if List.Count > 1 then
  begin
    CheckException(ECollectionNotOneException,
      procedure() begin
        Collection.Single();
      end,
      'ECollectionNotOneException not thrown in Single (more than 1).'
    );
  end else
    Check(Collection.Single() = List[0], 'Invalid Single() value');

  List.Free;
end;

procedure TTestEnex.InternalEnexTestSingleOrDefault(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
begin
  { Create an ordered list }
  List := TList<Integer>.Create(Collection);

  if List.Count = 0 then
  begin
    Check(Collection.SingleOrDefault(-1) = -1, 'Invalid SingleOrDefault() value');
  end else
  if List.Count > 1 then
  begin
    CheckException(ECollectionNotOneException,
      procedure() begin
        Collection.SingleOrDefault(-1);
      end,
      'ECollectionNotOneException not thrown in Single (more than 1).'
    );
  end else
    Check(Collection.SingleOrDefault(-1) = List[0], 'Invalid SingleOrDefault() value');

  List.Free;
end;

procedure TTestEnex.InternalEnexTestToDynamicArray(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  Arr: TDynamicArray<Integer>;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<Integer>.Create(Collection);
  Arr := Collection.ToDynamicArray();

  Check(List.Count = Arr.Length, 'Invalid count of elements copied');

  if List.Count > 0 then
    for I := 0 to List.Count - 1 do
      Check(List[I] = Arr[I], 'Invalid elements copied!');

  List.Free();
end;

procedure TTestEnex.InternalEnexTestToFixedArray(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  Arr: TFixedArray<Integer>;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<Integer>.Create(Collection);
  Arr := Collection.ToFixedArray();

  Check(List.Count = Arr.Length, 'Invalid count of elements copied');

  if List.Count > 0 then
    for I := 0 to List.Count - 1 do
      Check(List[I] = Arr[I], 'Invalid elements copied!');

  List.Free();
end;

procedure TTestEnex.InternalEnexTestToArray(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  Arr: TArray<Integer>;
  I: Cardinal;
begin
  { Copy the collection }
  List := TList<Integer>.Create(Collection);
  Arr := Collection.ToArray();

  Check(List.Count = Length(Arr), 'Invalid count of elements copied');

  if List.Count > 0 then
    for I := 0 to List.Count - 1 do
      Check(List[I] = Arr[I], 'Invalid elements copied!');

  List.Free();
end;

procedure TTestEnex.InternalTestSkip(const Collection: IEnexCollection<Integer>);
var
  SkipEnum: IEnexCollection<Integer>;
  List: TList<Integer>;
begin
  { Check exceptions }
  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Skip(0);
    end,
    'EArgumentOutOfRangeException not thrown in Where (0 Count).'
  );

  List := TList<Integer>.Create(Collection);

  if List.Count = 0 then
  begin
    Check(Collection.Skip(1).FirstOrDefault(-1) = -1, 'No elements should be in the list');
    Exit;
  end;

  { Now do test }
  SkipEnum := TEnexSkipCollection<Integer>.CreateIntf(Collection, List.Count, TType<Integer>.Default);
  Check(Collection.Skip(List.Count).EqualsTo(SkipEnum), 'Failed to skip count');

  SkipEnum := TEnexSkipCollection<Integer>.CreateIntf(Collection, (List.Count div 2) + 1, TType<Integer>.Default);
  Check(Collection.Skip((List.Count div 2) + 1).EqualsTo(SkipEnum), 'Failed to skip count');
end;


procedure TTestEnex.InternalTestSkipWhile(const Collection: IEnexCollection<Integer>);
var
  SkipWhileEnum: IEnexCollection<Integer>;
begin
  { Check exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.SkipWhile(nil);
    end,
    'ENilArgumentException not thrown in Where (nil predicate).'
  );

  { Now do test }
  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default);
  Check(Collection.SkipWhile(function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end).EqualsTo(SkipWhileEnum), 'Failed at  > 50');

  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Odd(Arg1)); end, TType<Integer>.Default);
  Check(Collection.SkipWhile(function(Arg1: Integer): Boolean begin Exit(Odd(Arg1)); end).EqualsTo(SkipWhileEnum), 'Failed at Odd');
end;

procedure TTestEnex.InternalTestSkipWhileBetween(const Collection: IEnexCollection<Integer>);
var
  SkipWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit((Arg1 >= -5) and (Arg1 <= 100)); end, TType<Integer>.Default);
  Check(Collection.SkipWhileBetween(-5, 100).EqualsTo(SkipWhileEnum), 'Failed at >= -5, <= 100');

  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit((Arg1 >= 200) and (Arg1 <= 201)); end, TType<Integer>.Default);
  Check(Collection.SkipWhileBetween(200, 201).EqualsTo(SkipWhileEnum), 'Failed at >= 200, <= 201');
end;

procedure TTestEnex.InternalTestSkipWhileGreater(const Collection: IEnexCollection<Integer>);
var
  SkipWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 > -1); end, TType<Integer>.Default);
  Check(Collection.SkipWhileGreater(-1).EqualsTo(SkipWhileEnum), 'Failed at > -1');

  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 > 500); end, TType<Integer>.Default);
  Check(Collection.SkipWhileGreater(500).EqualsTo(SkipWhileEnum), 'Failed at > 500');
end;

procedure TTestEnex.InternalTestSkipWhileGreaterOrEqual(const Collection: IEnexCollection<Integer>);
var
  SkipWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 >= -1); end, TType<Integer>.Default);
  Check(Collection.SkipWhileGreaterOrEqual(-1).EqualsTo(SkipWhileEnum), 'Failed at >= -1');

  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 >= 500); end, TType<Integer>.Default);
  Check(Collection.SkipWhileGreaterOrEqual(500).EqualsTo(SkipWhileEnum), 'Failed at >= 500');
end;

procedure TTestEnex.InternalTestSkipWhileLower(const Collection: IEnexCollection<Integer>);
var
  SkipWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 < -1); end, TType<Integer>.Default);
  Check(Collection.SkipWhileLower(-1).EqualsTo(SkipWhileEnum), 'Failed at < -1');

  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 < 500); end, TType<Integer>.Default);
  Check(Collection.SkipWhileLower(500).EqualsTo(SkipWhileEnum), 'Failed at < 500');
end;

procedure TTestEnex.InternalTestSkipWhileLowerOrEqual(const Collection: IEnexCollection<Integer>);
var
  SkipWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 <= -1); end, TType<Integer>.Default);
  Check(Collection.SkipWhileLowerOrEqual(-1).EqualsTo(SkipWhileEnum), 'Failed at <= -1');

  SkipWhileEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 <= 500); end, TType<Integer>.Default);
  Check(Collection.SkipWhileLowerOrEqual(500).EqualsTo(SkipWhileEnum), 'Failed at <= 500');
end;

procedure TTestEnex.InternalTestOrdered(const Collection: IEnexCollection<Integer>);
var
  AList: TList<Integer>;
  ASList: TList<string>;
begin
  { Typed sort }
  AList := TList<Integer>.Create(Collection);
  AList.Sort();

  Check(AList.EqualsTo(Collection.Ordered()), 'Ordered(type) Failed!');
  AList.Free;

  { Comp sort }
  ASList := TList<string>.Create(Collection.Op.Cast<string>);
  ASList.Sort(function(const ALeft, ARight: String): NativeInt
  begin
    Result := StrToInt(ALeft) - StrToInt(ARight);
  end);

  Check(ASList.EqualsTo(Collection.Ordered().Op.Cast<string>), 'Ordered(comp) Failed!');
  ASList.Free;
end;

procedure TTestEnex.InternalTestTake(const Collection: IEnexCollection<Integer>);
var
  List: TList<Integer>;
  IE: IEnumerable<Integer>;
  I: Cardinal;
begin
  { Check exceptions }
  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Take(0);
    end,
    'EArgumentOutOfRangeException not thrown in Take (0 Count).'
  );

  List := TList<Integer>.Create(Collection);

  for I := 1 to List.Count do
  begin
    IE := List.Copy(0, I);
    Check(Collection.Take(I).EqualsTo(IE), 'Failed copy at ' + IntToStr(I));
  end;

  List.Free;
  exit;

  if List.Count > 0 then
    Check(Collection.Take(List.Count * 2).EqualsTo(List.Copy(0, List.Count)), 'Failed copy at max * 2')
  else
    Check(Collection.Take(100).EqualsTo(TList<Integer>.Create()), 'Failed copy at empty');

  List.Free;
end;

procedure TTestEnex.InternalTestTakeWhile(const Collection: IEnexCollection<Integer>);
var
  TakeWhileEnum: IEnexCollection<Integer>;
begin
  { Check exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.TakeWhile(nil);
    end,
    'ENilArgumentException not thrown in Where (nil predicate).'
  );

  { Now do test }
  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default);
  Check(Collection.TakeWhile(function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end).EqualsTo(TakeWhileEnum), 'Failed at  > 50');

  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Odd(Arg1)); end, TType<Integer>.Default);
  Check(Collection.TakeWhile(function(Arg1: Integer): Boolean begin Exit(Odd(Arg1)); end).EqualsTo(TakeWhileEnum), 'Failed at Odd');
end;

procedure TTestEnex.InternalTestTakeWhileBetween(const Collection: IEnexCollection<Integer>);
var
  TakeWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit((Arg1 >= -5) and (Arg1 <= 100)); end, TType<Integer>.Default);
  Check(Collection.TakeWhileBetween(-5, 100).EqualsTo(TakeWhileEnum), 'Failed at >= -5, <= 100');

  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit((Arg1 >= 200) and (Arg1 <= 201)); end, TType<Integer>.Default);
  Check(Collection.TakeWhileBetween(200, 201).EqualsTo(TakeWhileEnum), 'Failed at >= 200, <= 201');
end;

procedure TTestEnex.InternalTestTakeWhileGreater(const Collection: IEnexCollection<Integer>);
var
  TakeWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 > -1); end, TType<Integer>.Default);
  Check(Collection.TakeWhileGreater(-1).EqualsTo(TakeWhileEnum), 'Failed at > -1');

  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 > 500); end, TType<Integer>.Default);
  Check(Collection.TakeWhileGreater(500).EqualsTo(TakeWhileEnum), 'Failed at > 500');
end;

procedure TTestEnex.InternalTestTakeWhileGreaterOrEqual(const Collection: IEnexCollection<Integer>);
var
  TakeWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 >= -1); end, TType<Integer>.Default);
  Check(Collection.TakeWhileGreaterOrEqual(-1).EqualsTo(TakeWhileEnum), 'Failed at >= -1');

  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 >= 500); end, TType<Integer>.Default);
  Check(Collection.TakeWhileGreaterOrEqual(500).EqualsTo(TakeWhileEnum), 'Failed at >= 500');
end;

procedure TTestEnex.InternalTestTakeWhileLower(const Collection: IEnexCollection<Integer>);
var
  TakeWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 < -1); end, TType<Integer>.Default);
  Check(Collection.TakeWhileLower(-1).EqualsTo(TakeWhileEnum), 'Failed at < -1');

  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 < 500); end, TType<Integer>.Default);
  Check(Collection.TakeWhileLower(500).EqualsTo(TakeWhileEnum), 'Failed at < 500');
end;

procedure TTestEnex.InternalTestTakeWhileLowerOrEqual(const Collection: IEnexCollection<Integer>);
var
  TakeWhileEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 <= -1); end, TType<Integer>.Default);
  Check(Collection.TakeWhileLowerOrEqual(-1).EqualsTo(TakeWhileEnum), 'Failed at <= -1');

  TakeWhileEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Collection, function(Arg1: Integer): Boolean begin Exit(Arg1 <= 500); end, TType<Integer>.Default);
  Check(Collection.TakeWhileLowerOrEqual(500).EqualsTo(TakeWhileEnum), 'Failed at <= 500');
end;

procedure TTestEnex.InternalTestToDictionary(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  Dict0, Dict1: IDictionary<Integer, Integer>;
begin
  Dict0 := TDictionary<Integer, Integer>.Create(Collection.DistinctByKeys);
  Dict1 := Collection.DistinctByKeys.ToDictionary();

  Check(Dict0.Includes(Dict1), 'Expected dictionaries lists to be equal! 0');
  Check(Dict1.Includes(Dict0), 'Expected dictionaries lists to be equal! 1');
end;

procedure TTestEnex.InternalTestToList(const Collection: IEnexCollection<Integer>);
var
  List0, List1: IList<Integer>;
begin
  List0 := TList<Integer>.Create(Collection);
  List1 := Collection.ToList();

  Check(List0.EqualsTo(List1), 'Expected both lists to be equal!');
end;

procedure TTestEnex.InternalTestToSet(const Collection: IEnexCollection<Integer>);
var
  Set0, Set1: ISet<Integer>;
begin
  Set0 := THashSet<Integer>.Create(Collection);
  Set1 := Collection.ToSet();

  Check(Set0.EqualsTo(Set1), 'Expected both sets to be equal!');
end;

procedure TTestEnex.InternalTestUnion(const Collection: IEnexCollection<Integer>);
var
  Enum1: IEnexCollection<Integer>;
  UnionEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeRandomIntegerList(ListElements, ListMax);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Union(nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  { Now apply predicates }
  UnionEnum := TEnexUnionCollection<Integer>.CreateIntf(Collection, Enum1, TType<Integer>.Default);
  Check(Collection.Union(Enum1).EqualsTo(UnionEnum), 'Concat failed!');
end;

procedure TTestEnex.InternalTestValueForKey(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  Dict: IDictionary<Integer, Integer>;
  KV: KVPair<Integer, Integer>;
begin
  Dict := TDictionary<Integer, Integer>.Create();

  for KV in Collection do
    Dict.SetItem(KV.Key, KV.Value);

  for KV in Dict do
    Check(Collection.ValueForKey(KV.Key) = KV.Value, 'ValueForKey failed!');

  { Check exceptions }
  CheckException(EKeyNotFoundException,
    procedure() begin
      Collection.ValueForKey(-1);
    end,
    'EKeyNotFoundException not thrown in ValueForKey (-1).'
  );
end;

procedure TTestEnex.InternalTestWhere(const Collection: IEnexCollection<Integer>);
var
  WhereEnum: IEnexCollection<Integer>;

begin
  { Check exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Where(nil);
    end,
    'ENilArgumentException not thrown in Where (nil type).'
  );

  { Now do test }
  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default, False);
  Check(Collection.Where(function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end).EqualsTo(WhereEnum), 'Failed at  > 50');

  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(not Odd(Arg1)); end, TType<Integer>.Default, True);
  Check(Collection.Where(function(Arg1: Integer): Boolean begin Exit(Odd(Arg1)); end).EqualsTo(WhereEnum), 'Failed at Odd');
end;

procedure TTestEnex.InternalTestWhereBetween(const Collection: IEnexCollection<Integer>);
var
  WhereEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit((Arg1 >= -5) and (Arg1 <= 100)); end, TType<Integer>.Default, False);
  Check(Collection.WhereBetween(-5, 100).EqualsTo(WhereEnum), 'Failed at  >= -5, <= 100');

  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit((Arg1 >= 200) and (Arg1 <= 201)); end, TType<Integer>.Default, False);
  Check(Collection.WhereBetween(200, 201).EqualsTo(WhereEnum), 'Failed at >= 200, <= 201');
end;

procedure TTestEnex.InternalTestWhereGreater(const Collection: IEnexCollection<Integer>);
var
  WhereEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 > -1); end, TType<Integer>.Default, False);
  Check(Collection.WhereGreater(-1).EqualsTo(WhereEnum), 'Failed at  > -1');

  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 > 500); end, TType<Integer>.Default, False);
  Check(Collection.WhereGreater(500).EqualsTo(WhereEnum), 'Failed at > 500');
end;

procedure TTestEnex.InternalTestWhereGreaterOrEqual(const Collection: IEnexCollection<Integer>);
var
  WhereEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 >= -1); end, TType<Integer>.Default, False);
  Check(Collection.WhereGreaterOrEqual(-1).EqualsTo(WhereEnum), 'Failed at  >= -1');

  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 >= 500); end, TType<Integer>.Default, False);
  Check(Collection.WhereGreaterOrEqual(500).EqualsTo(WhereEnum), 'Failed at >= 500');
end;

procedure TTestEnex.InternalTestWhereKeyBetween(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit((Arg1 >= -5) and (Arg1 <= 100)); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyBetween(-5, 100).Includes(WhereEnum), 'Failed at  >= -5, <= 100');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit((Arg1 >= 200) and (Arg1 <= 201)); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyBetween(200, 201).Includes(WhereEnum), 'Failed at >= 200, <= 201');
end;

procedure TTestEnex.InternalTestWhereKeyGreater(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 > -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyGreater(-1).Includes(WhereEnum), 'Failed at > -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 > 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyGreater(500).Includes(WhereEnum), 'Failed at > 500');
end;

procedure TTestEnex.InternalTestWhereKeyGreaterOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 >= -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyGreaterOrEqual(-1).Includes(WhereEnum), 'Failed at >= -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 >= 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyGreaterOrEqual(500).Includes(WhereEnum), 'Failed at >= 500');
end;

procedure TTestEnex.InternalTestWhereKeyLower(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 < -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyLower(-1).Includes(WhereEnum), 'Failed at < -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 < 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyLower(500).Includes(WhereEnum), 'Failed at < 500');
end;

procedure TTestEnex.InternalTestWhereKeyLowerOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 <= -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyLowerOrEqual(-1).Includes(WhereEnum), 'Failed at <= -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg1 <= 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereKeyLowerOrEqual(500).Includes(WhereEnum), 'Failed at <= 500');
end;

procedure TTestEnex.InternalTestWhereLower(const Collection: IEnexCollection<Integer>);
var
  WhereEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 < -1); end, TType<Integer>.Default, False);
  Check(Collection.WhereLower(-1).EqualsTo(WhereEnum), 'Failed at < -1');

  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 < 500); end, TType<Integer>.Default, False);
  Check(Collection.WhereLower(500).EqualsTo(WhereEnum), 'Failed at < 500');
end;

procedure TTestEnex.InternalTestWhereLowerOrEqual(const Collection: IEnexCollection<Integer>);
var
  WhereEnum: IEnexCollection<Integer>;
begin
  { Now do test }
  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 <= -1); end, TType<Integer>.Default, False);
  Check(Collection.WhereLowerOrEqual(-1).EqualsTo(WhereEnum), 'Failed at <= -1');

  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 <= 500); end, TType<Integer>.Default, False);
  Check(Collection.WhereLowerOrEqual(500).EqualsTo(WhereEnum), 'Failed at <= 500');
end;

procedure TTestEnex.InternalTestWhereNot(const Collection: IEnexCollection<Integer>);
var
  WhereEnum: IEnexCollection<Integer>;

begin
  { Check exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.WhereNot(nil);
    end,
    'ENilArgumentException not thrown in WhereNot (nil type).'
  );

  { Now do test }
  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default, True);
  Check(Collection.WhereNot(function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end).EqualsTo(WhereEnum), 'Failed at > 50');

  WhereEnum := TEnexWhereCollection<Integer>.CreateIntf(Collection,
    function(Arg1: Integer): Boolean begin Exit(Odd(Arg1)); end, TType<Integer>.Default, True);
  Check(Collection.WhereNot(function(Arg1: Integer): Boolean begin Exit(Odd(Arg1)); end).EqualsTo(WhereEnum), 'Failed at Odd');
end;

procedure TTestEnex.InternalTestWhereValueBetween(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit((Arg2 >= -5) and (Arg2 <= 100)); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueBetween(-5, 100).Includes(WhereEnum), 'Failed at  >= -5, <= 100');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit((Arg2 >= 200) and (Arg2 <= 201)); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueBetween(200, 201).Includes(WhereEnum), 'Failed at >= 200, <= 201');
end;

procedure TTestEnex.InternalTestWhereValueGreater(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 > -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueGreater(-1).Includes(WhereEnum), 'Failed at > -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 > 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueGreater(500).Includes(WhereEnum), 'Failed at > 500');
end;

procedure TTestEnex.InternalTestWhereValueGreaterOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 >= -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueGreaterOrEqual(-1).Includes(WhereEnum), 'Failed at >= -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 >= 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueGreaterOrEqual(500).Includes(WhereEnum), 'Failed at >= 500');
end;

procedure TTestEnex.InternalTestWhereValueLower(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 < -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueLower(-1).Includes(WhereEnum), 'Failed at < -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 < 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueLower(500).Includes(WhereEnum), 'Failed at < 500');
end;

procedure TTestEnex.InternalTestWhereValueLowerOrEqual(const Collection: IEnexAssociativeCollection<Integer, Integer>);
var
  WhereEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Now do test }
  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 <= -1); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueLowerOrEqual(-1).Includes(WhereEnum), 'Failed at <= -1');

  WhereEnum := TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(Collection,
    function(Arg1, Arg2: Integer): Boolean begin Exit(Arg2 <= 500); end, TType<Integer>.Default, TType<Integer>.Default, False);

  Check(Collection.WhereValueLowerOrEqual(500).Includes(WhereEnum), 'Failed at <= 500');
end;

procedure TTestEnex.TestAggregate;
begin
  TestGenericEnexCollection(InternalTestAggregate);
end;

procedure TTestEnex.TestAggregateOrDefault;
begin
  TestGenericEnexCollection(InternalTestAggregateOrDefault);
end;

procedure TTestEnex.TestAll;
begin
  TestGenericEnexCollection(InternalTestAll);
end;

procedure TTestEnex.TestAny;
begin
  TestGenericEnexCollection(InternalTestAny);
end;

procedure TTestEnex.TestAssociativeWrapCollection;
var
  Dict: IDictionary<Integer, Integer>;
  XEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Make a list }
  Dict := MakeOrderedIntegerDictionary(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWrapCollection<Integer, Integer>.Create(nil, TType<Integer>.Default, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWrapCollection<Integer, Integer>.Create(Dict, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWrapCollection<Integer, Integer>.Create(Dict, TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  XEnum := TEnexAssociativeWrapCollection<Integer, Integer>.Create(Dict, TType<Integer>.Default, TType<Integer>.Default);
  Check(XEnum.Includes(Dict), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestAssocWhere;
begin
  TestGenericAssocEnexCollection(InternalTestAssocWhere);
end;

procedure TTestEnex.TestAssocWhereNot;
begin
  TestGenericAssocEnexCollection(InternalTestAssocWhereNot);
end;

procedure TTestEnex.TestAssociativeWhereCollection;
var
  Enum: TDictionary<Integer, Integer>;
  EnumIntf: IDictionary<Integer, Integer>;
  Enum2: IEnexAssociativeCollection<Integer, Integer>;
  Predicate: TFunc<Integer, Integer, Boolean>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerDictionary(0, 100);
  EnumIntf := Enum;

  Predicate := function(Arg1, Arg2: Integer): Boolean begin
    Exit(Arg1 > 50);
  end;

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWhereCollection<Integer, Integer>.Create(nil, Predicate, False);
    end,
    'ENilArgumentException not thrown in Create (nil coll).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWhereCollection<Integer, Integer>.Create(Enum, nil, False);
    end,
    'ENilArgumentException not thrown in Create (nil pred).'
  );


  { ............. }

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(EnumIntf, Predicate, TType<Integer>.Default, nil, False);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(EnumIntf, Predicate, nil, TType<Integer>.Default, False);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(nil, Predicate, TType<Integer>.Default, TType<Integer>.Default, False);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeWhereCollection<Integer, Integer>.CreateIntf(EnumIntf, nil, TType<Integer>.Default, TType<Integer>.Default, False);
    end,
    'ENilArgumentException not thrown in Create (nil pred).'
  );

  { Now apply predicates }
  Enum2 := TEnexAssociativeWhereCollection<Integer, Integer>.Create(Enum, Predicate, False);

  { Verify! }
  Check(Enum2.SelectKeys().EqualsTo(MakeOrderedIntegerList(51, 100)), 'Enum2 does not contain the right keys!');
  Check(Enum2.SelectValues().EqualsTo(MakeOrderedIntegerList(52, 101)), 'Enum2 does not contain the right values!');
end;

procedure TTestEnex.TestCast;
var
  List: TList<Integer>;
  List2: TList<String>;

  I: Integer;
begin
  List := TList<Integer>.Create();

  { Fill list }
  for I := 0 to 999 do
    List.Add(Random(I));

  { Verify exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      List.Op.Cast<String>(nil);
    end,
    'ENilArgumentException not thrown in Cast (nil type).'
  );

  { Populate list 2 with strings }
  List2 := TList<String>.Create(List.Op.Cast<String>());

  { Check lengths }
  Check(List.Count = List2.Count);

  { Check elements }
  for I := 0 to List2.Count - 1 do
    Check(IntToStr(List[I]) = List2[I], 'Conversion failed!');

  List.Free;
  List2.Free;
end;

procedure TTestEnex.TestCastCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<String>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexCastCollection<Integer, String>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default),
        nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexCastCollection<Integer, String>.Create(nil, TType<String>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexCastCollection<Integer, String>.CreateIntf(nil, TType<Integer>.Default, TType<String>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexCastCollection<Integer, String>.CreateIntf(Enum, nil, TType<String>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil in type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexCastCollection<Integer, String>.CreateIntf(Enum, TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil out type).'
  );

  { Now apply predicates }
  XEnum := TEnexCastCollection<Integer, String>.CreateIntf(Enum, TType<Integer>.Default, TType<String>.Default);
  Check(XEnum.EqualsTo(MakeOrderedStringList(0, 100)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestConcat;
begin
  TestGenericEnexCollection(InternalTestConcat);
end;

procedure TTestEnex.TestConcatCollection;
var
  Enum1, Enum2: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(101, 200);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.Create(
        nil,
        TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default));
    end,
    'ENilArgumentException not thrown in Create (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.Create(
        TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default),
        nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum 2).'
  );


  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf(Enum1, Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf1(nil, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf1(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf1(Enum1, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), nil);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil type).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf2(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexConcatCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexConcatCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 200)), 'XEnum does not contain the right elements!');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 1);
  Enum2 := MakeOrderedIntegerList(1, 2);
  XEnum := TEnexConcatCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);

  Check(XEnum.First = 0, 'XEnum.First = 0');
  Check(XEnum.Last = 2, 'XEnum.Last = 2');
  Check(Accumulator.Sum<Integer>(XEnum) = 4, 'XEnum.Sum = 4');
end;

procedure TTestEnex.TestCopyTo;
begin
  TestGenericEnexCollection(InternalEnexTestCopyTo);
  TestGenericAssocEnexCollection(InternalAssocEnexTestCopyTo);
end;

procedure TTestEnex.TestDistinct;
begin
  TestGenericEnexCollection(InternalTestDistinct);
end;

procedure TTestEnex.TestDistinctByKeys;
begin
  TestGenericAssocEnexCollection(InternalTestDistinctByKeys);
end;

procedure TTestEnex.TestDistinctByKeysCollection;
var
  Enum: TDictionary<Integer, Integer>;
  MM: TMultiMap<Integer, Integer>;
  XEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerDictionary(0, 1000);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.CreateIntf(nil, TType<Integer>.Default, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.CreateIntf(Enum, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.CreateIntf(Enum, TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type2).'
  );

  { Now apply predicates }
  XEnum := TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.Create(Enum);
  Check(XEnum.Includes(Enum), 'XEnum does not contain the right elements!');
  Enum.Free;

  { Other situations }
  Enum := TDictionary<Integer, Integer>.Create();
  Enum.Add(1, 2);
  Enum.Add(2, 1);

  MM := TMultiMap<Integer, Integer>.Create();
  MM.Add(1, 2);
  MM.Add(1, 1);
  MM.Add(2, 1);
  MM.Add(2, 100);

  XEnum := TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.Create(Enum);
  Check(XEnum.Includes(Enum), 'XEnum does not contain the right elements!');
  Check(Enum.Includes(XEnum), 'XEnum does not contain the right elements!');

  MM.Free;
  Enum.Free;
end;

procedure TTestEnex.TestDistinctByValues;
begin
  TestGenericAssocEnexCollection(InternalTestDistinctByValues);
end;

procedure TTestEnex.TestDistinctByValuesCollection;
var
  Enum: TDictionary<Integer, Integer>;
  MM: TMultiMap<Integer, Integer>;
  XEnum: IEnexAssociativeCollection<Integer, Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerDictionary(0, 1000);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.CreateIntf(nil, TType<Integer>.Default, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.CreateIntf(Enum, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.CreateIntf(Enum, TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type2).'
  );

  { Now apply predicates }
  XEnum := TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.Create(Enum);
  Check(XEnum.Includes(Enum), 'XEnum does not contain the right elements!');
  Enum.Free;

  { Other situations }
  Enum := TDictionary<Integer, Integer>.Create();
  Enum.Add(1, 2);
  Enum.Add(2, 1);

  MM := TMultiMap<Integer, Integer>.Create();
  MM.Add(1, 2);
  MM.Add(2, 1);
  MM.Add(3, 1);
  MM.Add(4, 2);

  XEnum := TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.Create(Enum);
  Check(XEnum.Includes(Enum), 'XEnum does not contain the right elements!');
  Check(Enum.Includes(XEnum), 'XEnum does not contain the right elements!');

  MM.Free;
  Enum.Free;
end;

procedure TTestEnex.TestDistinctCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 1000);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexDistinctCollection<Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexDistinctCollection<Integer>.CreateIntf(nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexDistinctCollection<Integer>.CreateIntf(Enum, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexDistinctCollection<Integer>.CreateIntf(Enum, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 1000)), 'XEnum does not contain the right elements!');


  { Other situations }
  Enum := TList<Integer>.Create([1, 1, 2, 3, 3, 2]);
  XEnum := TEnexDistinctCollection<Integer>.CreateIntf(Enum, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(1, 3)), 'XEnum does not contain the right elements!');

  Enum := TList<Integer>.Create([1, 1, 1, 3, 3, 4, 4, 4, 1, 1, 2 ]);
  XEnum := TEnexDistinctCollection<Integer>.CreateIntf(Enum, TType<Integer>.Default);

  Check(XEnum.EqualsTo(TList<Integer>.Create([1, 3, 4, 2 ])), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestElementAt;
begin
  TestGenericEnexCollection(InternalTestElementAt);
end;

procedure TTestEnex.TestElementAtOrDefault;
begin
  TestGenericEnexCollection(InternalTestElementAtOrDefault);
end;

procedure TTestEnex.TestEmpty;
begin
  TestGenericEnexCollection(InternalEnexTestEmpty);
  TestGenericAssocEnexCollection(InternalAssocEnexTestEmpty);
end;

procedure TTestEnex.TestEqualTo;
begin
  TestGenericEnexCollection(InternalTestEqualTo);
end;

procedure TTestEnex.TestExclude;
begin
  TestGenericEnexCollection(InternalTestExclude);
end;

procedure TTestEnex.TestExclusionCollection;
var
  Enum1, Enum2: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(101, 200);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.Create(
        nil,
        TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default));
    end,
    'ENilArgumentException not thrown in Create (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.Create(
        TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default),
        nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum 2).'
  );


  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf(Enum1, Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf1(nil, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf1(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf1(Enum1, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), nil);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil type).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf2(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexExclusionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 100)), 'XEnum does not contain the right elements!');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 1);
  Enum2 := MakeOrderedIntegerList(1, 2);
  XEnum := TEnexExclusionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);

  Check(XEnum.First = 0, 'XEnum.First = 0');
  Check(XEnum.Last = 0, 'XEnum.Last = 0');
  Check(Accumulator.Sum<Integer>(XEnum) = 0, 'XEnum.Sum = 0');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(0, 98);
  XEnum := TEnexExclusionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(99, 100)), 'XEnum does not contain the right elements!');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(50, 110);
  XEnum := TEnexExclusionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 49)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestFill;
var
  FillEnum: IEnexCollection<Integer>;

begin
  { Check exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Fill<Integer>(1, 1, nil);
    end,
    'ENilArgumentException not thrown in Fill (nil type).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Fill<Integer>(1, 0, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Fill (0 Count).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Fill<Integer>(1, 0);
    end,
    'EArgumentOutOfRangeException not thrown in Fill (0 Count).'
  );

  { Now do test }
  FillEnum := TEnexFillCollection<Integer>.Create(1, 100, TType<Integer>.Default);
  Check(Collection.Fill<Integer>(1, 100).EqualsTo(FillEnum), 'Failed at 100 elements');

  FillEnum := TEnexFillCollection<Integer>.Create(1, 1, TType<Integer>.Default);
  Check(Collection.Fill<Integer>(1, 1).EqualsTo(FillEnum), 'Failed at 1 elements');

  FillEnum := TEnexFillCollection<Integer>.Create(1, 22, TType<Integer>.Default);
  Check(Collection.Fill<Integer>(1, 22).EqualsTo(FillEnum), 'Failed at 22 elements');
end;

procedure TTestEnex.TestFillCollection;
var
  XEnum: IEnexCollection<Integer>;

begin
  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexFillCollection<Integer>.Create(1, 1, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      TEnexFillCollection<Integer>.Create(1, 0, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Create (0 Count).'
  );


  { Test }
  XEnum := TEnexFillCollection<Integer>.Create(1, 1, TType<Integer>.Default);
  Check(XEnum.EqualsTo(TList<Integer>.Create([1])), 'XEnum does not contain the right elements!');

  XEnum := TEnexFillCollection<Integer>.Create(1, 5, TType<Integer>.Default);
  Check(XEnum.EqualsTo(TList<Integer>.Create([1, 1, 1, 1, 1])), 'XEnum does not contain the right elements!');

  XEnum := TEnexFillCollection<Integer>.Create(-1, 2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(TList<Integer>.Create([-1, -1])), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestFirst;
begin
  TestGenericEnexCollection(InternalTestFirst);
end;

procedure TTestEnex.TestFirstOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstOrDefault);
end;

procedure TTestEnex.TestFirstWhere;
begin
  TestGenericEnexCollection(InternalTestFirstWhere);
end;

procedure TTestEnex.TestFirstWhereBetween;
begin
  TestGenericEnexCollection(InternalTestFirstWhereBetween);
end;

procedure TTestEnex.TestFirstWhereBetweenOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstWhereBetweenOrDefault);
end;

procedure TTestEnex.TestFirstWhereGreater;
begin
  TestGenericEnexCollection(InternalTestFirstWhereGreater);
end;

procedure TTestEnex.TestFirstWhereGreaterOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstWhereGreaterOrDefault);
end;

procedure TTestEnex.TestFirstWhereGreaterOrEqual;
begin
  TestGenericEnexCollection(InternalTestFirstWhereGreaterOrEqual);
end;

procedure TTestEnex.TestFirstWhereGreaterOrEqualOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstWhereGreaterOrEqualOrDefault);
end;

procedure TTestEnex.TestFirstWhereLower;
begin
  TestGenericEnexCollection(InternalTestFirstWhereLower);
end;

procedure TTestEnex.TestFirstWhereLowerOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstWhereLowerOrDefault);
end;

procedure TTestEnex.TestFirstWhereLowerOrEqual;
begin
  TestGenericEnexCollection(InternalTestFirstWhereLowerOrEqual);
end;

procedure TTestEnex.TestFirstWhereLowerOrEqualOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstWhereLowerOrEqualOrDefault);
end;

procedure TTestEnex.TestFirstWhereNot;
begin
  TestGenericEnexCollection(InternalTestFirstWhereNot);
end;

procedure TTestEnex.TestFirstWhereNotOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstWhereNotOrDefault);
end;

procedure TTestEnex.TestFirstWhereOrDefault;
begin
  TestGenericEnexCollection(InternalTestFirstWhereOrDefault);
end;

procedure TTestEnex.TestGenericAssocEnexCollection(const TestProc: TEnexAssocCollectionInternalProc);
begin
  { With real data }
  TestProc(LPrioQueue_Full);
  TestProc(LDictionary_Full);
  TestProc(LSortedDictionary_Full);
  TestProc(LMM_Full);
  TestProc(LSoMM_Full);
  TestProc(LDoSoMM_Full);
  TestProc(LBDM_Full);
  TestProc(LSoBDM_Full);
  TestProc(LDoSoBDM_Full);
  TestProc(LSM_Full);
  TestProc(LSoSM_Full);
  TestProc(LDoSoSM_Full);
  TestProc(LAssocWrapColl_Full);
  TestProc(LAssocWhereColl_Full);
  TestProc(LAssocDByKeysColl_Full);
  TestProc(LAssocDByValuesColl_Full);

  { With one element }
  TestProc(LPrioQueue_One);
  TestProc(LDictionary_One);
  TestProc(LSortedDictionary_One);
  TestProc(LMM_One);
  TestProc(LSoMM_One);
  TestProc(LDoSoMM_One);
  TestProc(LBDM_One);
  TestProc(LSoBDM_One);
  TestProc(LDoSoBDM_One);
  TestProc(LSM_One);
  TestProc(LSoSM_One);
  TestProc(LDoSoSM_One);
  TestProc(LAssocWrapColl_One);
  TestProc(LAssocWhereColl_One);
  TestProc(LAssocDByKeysColl_One);
  TestProc(LAssocDByValuesColl_One);

  { With no data }
  TestProc(LPrioQueue_Empty);
  TestProc(LDictionary_Empty);
  TestProc(LSortedDictionary_Empty);
  TestProc(LMM_Empty);
  TestProc(LSoMM_Empty);
  TestProc(LDoSoMM_Empty);
  TestProc(LBDM_Empty);
  TestProc(LSoBDM_Empty);
  TestProc(LDoSoBDM_Empty);
  TestProc(LSM_Empty);
  TestProc(LSoSM_Empty);
  TestProc(LDoSoSM_Empty);
  TestProc(LAssocWrapColl_Empty);
  TestProc(LAssocWhereColl_Empty);
  TestProc(LAssocDByKeysColl_Empty);
  TestProc(LAssocDByValuesColl_Empty);
end;

procedure TTestEnex.TestGenericEnexCollection(const TestProc: TEnexCollectionInternalProc);
begin
  { With real data }
  TestProc(LHeap_Full);
  TestProc(LList_Full);
  TestProc(LSortedList_Full);
  TestProc(LAraySet_Full);
  TestProc(LBag_Full);
  TestProc(LSortedBag_Full);
  TestProc(LHashSet_Full);
  TestProc(LSortedSet_Full);
  TestProc(LLinkedList_Full);
  TestProc(LQueue_Full);
  TestProc(LLinkedQueue_Full);
  TestProc(LStack_Full);
  TestProc(LLinkedStack_Full);
  TestProc(LWrapColl_Full);
  TestProc(LFillColl_Full);
  TestProc(LIntervalColl_Full);
  TestProc(LWhereColl_Full);
  TestProc(LSelectColl_Full);
  TestProc(LCastColl_Full);
  TestProc(LConcatColl_Full);
  TestProc(LUnionColl_Full);
  TestProc(LExclColl_Full);
  TestProc(LInterColl_Full);
  TestProc(LDistinctColl_Full);
  TestProc(LRangeColl_Full);
  TestProc(LSkipColl_Full);
  TestProc(LTakeColl_Full);
  TestProc(LSkipWhileColl_Full);
  TestProc(LTakeWhileColl_Full);
  TestProc(LSelectKeysColl_Full);
  TestProc(LSelectValuesColl_Full);
  TestProc(LDictKey_Full);
  TestProc(LDictVal_Full);
  TestProc(LSoDictKey_Full);
  TestProc(LSoDictVal_Full);
  TestProc(LMMKey_Full);
  TestProc(LMMVal_Full);
  TestProc(LSoMMKey_Full);
  TestProc(LSoMMVal_Full);
  TestProc(LDoSoMMKey_Full);
  TestProc(LDoSoMMVal_Full);
  TestProc(LBDMKey_Full);
  TestProc(LBDMVal_Full);
  TestProc(LSoBDMKey_Full);
  TestProc(LSoBDMVal_Full);
  TestProc(LDoSoBDMKey_Full);
  TestProc(LDoSoBDMVal_Full);
  TestProc(LSMKey_Full);
  TestProc(LSMVal_Full);
  TestProc(LSoSMKey_Full);
  TestProc(LSoSMVal_Full);
  TestProc(LDoSoSMKey_Full);
  TestProc(LDoSoSMVal_Full);

  { With one element }
  TestProc(LHeap_One);
  TestProc(LList_One);
  TestProc(LSortedList_One);
  TestProc(LAraySet_One);
  TestProc(LBag_One);
  TestProc(LSortedBag_One);
  TestProc(LHashSet_One);
  TestProc(LSortedSet_One);
  TestProc(LLinkedList_One);
  TestProc(LQueue_One);
  TestProc(LLinkedQueue_One);
  TestProc(LStack_One);
  TestProc(LLinkedStack_One);
  TestProc(LWrapColl_One);
  TestProc(LFillColl_One);
  TestProc(LIntervalColl_One);
  TestProc(LWhereColl_One);
  TestProc(LSelectColl_One);
  TestProc(LCastColl_One);
  TestProc(LConcatColl_One);
  TestProc(LUnionColl_One);
  TestProc(LExclColl_One);
  TestProc(LInterColl_One);
  TestProc(LDistinctColl_One);
  TestProc(LRangeColl_One);
  TestProc(LSkipColl_One);
  TestProc(LTakeColl_One);
  TestProc(LSkipWhileColl_One);
  TestProc(LTakeWhileColl_One);
  TestProc(LSelectKeysColl_One);
  TestProc(LSelectValuesColl_One);
  TestProc(LDictKey_One);
  TestProc(LDictVal_One);
  TestProc(LSoDictKey_One);
  TestProc(LSoDictVal_One);
  TestProc(LMMKey_One);
  TestProc(LMMVal_One);
  TestProc(LSoMMKey_One);
  TestProc(LSoMMVal_One);
  TestProc(LDoSoMMKey_One);
  TestProc(LDoSoMMVal_One);
  TestProc(LBDMKey_One);
  TestProc(LBDMVal_One);
  TestProc(LSoBDMKey_One);
  TestProc(LSoBDMVal_One);
  TestProc(LDoSoBDMKey_One);
  TestProc(LDoSoBDMVal_One);
  TestProc(LSMKey_One);
  TestProc(LSMVal_One);
  TestProc(LSoSMKey_One);
  TestProc(LSoSMVal_One);
  TestProc(LDoSoSMKey_One);
  TestProc(LDoSoSMVal_One);

  { With no data }
  TestProc(LHeap_Empty);
  TestProc(LList_Empty);
  TestProc(LSortedList_Empty);
  TestProc(LAraySet_Empty);
  TestProc(LBag_Empty);
  TestProc(LSortedBag_Empty);
  TestProc(LHashSet_Empty);
  TestProc(LSortedSet_Empty);
  TestProc(LLinkedList_Empty);
  TestProc(LQueue_Empty);
  TestProc(LLinkedQueue_Empty);
  TestProc(LStack_Empty);
  TestProc(LLinkedStack_Empty);
  TestProc(LWrapColl_Empty);
  TestProc(LWhereColl_Empty);
  TestProc(LSelectColl_Empty);
  TestProc(LCastColl_Empty);
  TestProc(LConcatColl_Empty);
  TestProc(LUnionColl_Empty);
  TestProc(LExclColl_Empty);
  TestProc(LInterColl_Empty);
  TestProc(LDistinctColl_Empty);
  TestProc(LRangeColl_Empty);
  TestProc(LSkipColl_Empty);
  TestProc(LTakeColl_Empty);
  TestProc(LSkipWhileColl_Empty);
  TestProc(LTakeWhileColl_Empty);
  TestProc(LSelectKeysColl_Empty);
  TestProc(LSelectValuesColl_Empty);
  TestProc(LDictKey_Empty);
  TestProc(LDictVal_Empty);
  TestProc(LSoDictKey_Empty);
  TestProc(LSoDictVal_Empty);
  TestProc(LMMKey_Empty);
  TestProc(LMMVal_Empty);
  TestProc(LSoMMKey_Empty);
  TestProc(LSoMMVal_Empty);
  TestProc(LDoSoMMKey_Empty);
  TestProc(LDoSoMMVal_Empty);
  TestProc(LBDMKey_Empty);
  TestProc(LBDMVal_Empty);
  TestProc(LSoBDMKey_Empty);
  TestProc(LSoBDMVal_Empty);
  TestProc(LDoSoBDMKey_Empty);
  TestProc(LDoSoBDMVal_Empty);
  TestProc(LSMKey_Empty);
  TestProc(LSMVal_Empty);
  TestProc(LSoSMKey_Empty);
  TestProc(LSoSMVal_Empty);
  TestProc(LDoSoSMKey_Empty);
  TestProc(LDoSoSMVal_Empty);
end;

procedure TTestEnex.TestGetCount;
begin
  TestGenericEnexCollection(InternalEnexTestGetCount);
  TestGenericAssocEnexCollection(InternalAssocEnexTestGetCount);
end;

procedure TTestEnex.TestIncludes;
begin
  TestGenericAssocEnexCollection(InternalTestIncludes);
end;

procedure TTestEnex.TestIntersect;
begin
  TestGenericEnexCollection(InternalTestIntersect);
end;

procedure TTestEnex.TestIntersectionCollection;
var
  Enum1, Enum2: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(101, 200);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.Create(
        nil,
        TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default));
    end,
    'ENilArgumentException not thrown in Create (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.Create(
        TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default),
        nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum 2).'
  );


  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf(Enum1, Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf1(nil, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf1(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexExclusionCollection<Integer>.CreateIntf1(Enum1, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), nil);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf2(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntersectionCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexIntersectionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.FirstOrDefault(-1) = -1, 'XEnum must be empty!');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 1);
  Enum2 := MakeOrderedIntegerList(1, 2);
  XEnum := TEnexIntersectionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);

  Check(XEnum.First = 1, 'XEnum.First = 1');
  Check(XEnum.Last = 1, 'XEnum.Last = 1');
  Check(Accumulator.Sum<Integer>(XEnum) = 1, 'XEnum.Sum = 1');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(0, 98);
  XEnum := TEnexIntersectionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 98)), 'XEnum does not contain the right elements!');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(50, 200);
  XEnum := TEnexIntersectionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(50, 100)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestInterval;
var
  XEnum: IEnexCollection<Integer>;
  List: TList<Integer>;
begin
  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      Collection.Interval<Integer>(0, 1, 1, nil);
    end,
    'ENilArgumentException not thrown in Interval (nil type).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Interval<Integer>(1, 1, 1, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Interval (Min = Max).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Interval<Integer>(2, 1, 1, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Interval (Min > Max).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Interval<Integer>(2, 1, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Interval (Min > Max).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      Collection.Interval<Integer>(2, 1);
    end,
    'EArgumentOutOfRangeException not thrown in Interval (Min > Max).'
  );

  CheckException(ETypeException,
    procedure() begin
      Collection.Interval<String>('', '', '', TType<String>.Default);
    end,
    'ETypeException not thrown in Interval (not number).'
  );

  CheckException(ETypeException,
    procedure() begin
      Collection.Interval<Boolean>(true, true);
    end,
    'ETypeException not thrown in Interval (not number).'
  );

  { Test }
  XEnum := Collection.Interval<Integer>(0, 1);
  Check(XEnum.EqualsTo(TList<Integer>.Create([0, 1])), 'XEnum does not contain the right elements!');

  XEnum := Collection.Interval<Integer>(1, 5, 2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(TList<Integer>.Create([1, 3, 5])), 'XEnum does not contain the right elements!');

  XEnum := Collection.Interval<Integer>(-1, 5, 3);
  Check(XEnum.EqualsTo(TList<Integer>.Create([-1, 2, 5])), 'XEnum does not contain the right elements!');

  XEnum := Collection.Interval<Integer>(1, 3, 1);
  List := TList<Integer>.Create(XEnum);

  Check(List[0] = 1 , 'DEnum does not contain the right elements!');
  Check(List[1] = 2 , 'DEnum does not contain the right elements!');
  Check(List[2] = 3 , 'DEnum does not contain the right elements!');

  List.Free;
end;

procedure TTestEnex.TestIntervalCollection;
var
  XEnum: IEnexCollection<Integer>;
  List: TList<Integer>;
begin
  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexIntervalCollection<Integer>.Create(0, 1, 1, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      TEnexIntervalCollection<Integer>.Create(1, 1, 1, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Create (Min = Max).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      TEnexIntervalCollection<Integer>.Create(2, 1, 1, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Create (Min > Max).'
  );

  CheckException(ETypeException,
    procedure() begin
      TEnexIntervalCollection<String>.Create('', '', '', TType<String>.Default);
    end,
    'ETypeException not thrown in Create (not number).'
  );

  CheckException(ETypeException,
    procedure() begin
      TEnexIntervalCollection<Boolean>.Create(true, true, true, TType<Boolean>.Default);
    end,
    'ETypeException not thrown in Create (not number).'
  );

  { Test }
  XEnum := TEnexIntervalCollection<Integer>.Create(0, 1, 1, TType<Integer>.Default);
  Check(XEnum.EqualsTo(TList<Integer>.Create([0, 1])), 'XEnum does not contain the right elements!');

  XEnum := TEnexIntervalCollection<Integer>.Create(1, 5, 2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(TList<Integer>.Create([1, 3, 5])), 'XEnum does not contain the right elements!');

  XEnum := TEnexIntervalCollection<Integer>.Create(-1, 5, 3, TType<Integer>.Default);
  Check(XEnum.EqualsTo(TList<Integer>.Create([-1, 2, 5])), 'XEnum does not contain the right elements!');

  XEnum := TEnexIntervalCollection<Integer>.Create(1, 3, 1, TType<Integer>.Default);
  List := TList<Integer>.Create(XEnum);

  Check(List[0] = 1 , 'DEnum does not contain the right elements!');
  Check(List[1] = 2 , 'DEnum does not contain the right elements!');
  Check(List[2] = 3 , 'DEnum does not contain the right elements!');

  List.Free;
end;

procedure TTestEnex.TestKeyHasValue;
begin
  TestGenericAssocEnexCollection(InternalTestKeyHasValue);
end;

procedure TTestEnex.TestLast;
begin
  TestGenericEnexCollection(InternalTestLast);
end;

procedure TTestEnex.TestLastOrDefault;
begin
  TestGenericEnexCollection(InternalTestLastOrDefault);
end;

procedure TTestEnex.TestLongChain;
var
  SumR, SumR2, SumC, SumC2, I: Integer;
begin
  SumC := 0;
  SumC2 := 0;

  for I := 31 to 49 do
  begin
    SumC := SumC + I;

    if not Odd(I) then
      SumC2 := SumC2 + I;
  end;

  SumR := Accumulator.Sum<Integer>(Collection.Interval<Integer>(0, 100).
    WhereLower(50).
    WhereGreater(30).
    Take(100));

  SumR2 := Accumulator.Sum<Integer>(Collection.Interval<Integer>(0, 100).
    WhereLower(50).
    WhereGreater(30).
    Intersect(
      Collection.Interval<Integer>(30, 50, 2)
    ));

  Check(SumR = SumC, Format('SumC <> SumR (%d <> %d)', [SumC, SumR]) );
  Check(SumR2 = SumC2, Format('SumC2 <> SumR2 (%d <> %d)', [SumC2, SumR2]) );

end;

procedure TTestEnex.TestMax;
begin
  TestGenericEnexCollection(InternalTestMax);
end;

procedure TTestEnex.TestMaxKey;
begin
  TestGenericAssocEnexCollection(InternalTestMaxKey);
end;

procedure TTestEnex.TestMaxValue;
begin
  TestGenericAssocEnexCollection(InternalTestMaxValue);
end;

procedure TTestEnex.TestMin;
begin
  TestGenericEnexCollection(InternalTestMin);
end;

procedure TTestEnex.TestMinKey;
begin
  TestGenericAssocEnexCollection(InternalTestMinKey);
end;

procedure TTestEnex.TestMinValue;
begin
  TestGenericAssocEnexCollection(InternalTestMinValue);
end;

procedure TTestEnex.TestRange;
begin
  TestGenericEnexCollection(InternalTestRange);
end;

procedure TTestEnex.TestRangeCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexRangeCollection<Integer>.Create(nil, 0, 0);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexRangeCollection<Integer>.CreateIntf(nil, 0, 0, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexRangeCollection<Integer>.CreateIntf(Enum, 0, 0, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  { Test }
  XEnum := TEnexRangeCollection<Integer>.CreateIntf(Enum, 0, 0, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-1) = 0, 'Expected to have one element and to be 0');

  XEnum := TEnexRangeCollection<Integer>.CreateIntf(Enum, 200, 400, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-1) = -1, 'Expected to be empty.');

  XEnum := TEnexRangeCollection<Integer>.CreateIntf(Enum, 0, 1, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 1)), 'XEnum does not contain the right elements!');

  XEnum := TEnexRangeCollection<Integer>.CreateIntf(Enum, 0, 50, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 50)), 'XEnum does not contain the right elements!');

  XEnum := TEnexRangeCollection<Integer>.CreateIntf(Enum, 50, 200, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(50, 100)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestReversed;
begin
  TestGenericEnexCollection(InternalTestReversed);
end;

procedure TTestEnex.TestSelect2;
var
  List: TList<Integer>;
  List2: TList<String>;

  I: Integer;
begin
  List := TList<Integer>.Create();

  { Fill list }
  for I := 0 to 999 do
    List.Add(Random(I));

  { Verify exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      List.Op.Select<String>(nil);
    end,
    'ENilArgumentException not thrown in Select (nil func).'
  );

  { Verify exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      List.Op.Select<String>(function(Arg1: Integer): string begin end, nil);
    end,
    'ENilArgumentException not thrown in Select (nil type).'
  );

  { Populate list 2 with strings }
  List2 := TList<String>.Create(List.Op.Select<String>(function(Arg1: Integer): string begin Exit(IntToStr(Arg1)); end));

  { Check lengths }
  Check(List.Count = List2.Count);

  { Check elements }
  for I := 0 to List2.Count - 1 do
    Check(IntToStr(List[I]) = List2[I], 'Select failed!');

  List.Free;
  List2.Free;
end;

type
  TX = class(TObject);
  T1 = class(TX);
  T2 = class(TX);
  T3 = class(T2);

procedure TTestEnex.TestSelect3;
var
  LBadList: TList<Integer>;
  LList: TList<TX>;
  L0: TInterfacedObject;
  L1: T1;
  L2: T2;
  L3: T3;
  L4: TObject;

  C1, C2: Integer;
begin
  LList := TList<TX>.Create(TClassType<TX>.Create(true));
  LList.Add(T1.Create);
  LList.Add(T2.Create);
  LList.Add(nil);
  LList.Add(T3.Create);


  for L0 in LList.Op.Select<TInterfacedObject> do
    Fail('Did not expect anything to be enumerated by Select<TInterfacedObject>! But got ' + L0.ClassName);

  C1 := 0;
  for L1 in LList.Op.Select<T1> do
  begin
    if L1 is T1 then
      Inc(C1)
    else
      Fail('Unexpected class enumerated by Select<T1>! Got ' + L1.ClassName);
  end;

  CheckEquals(1, C1, 'Expected one apparition of T1 in list.');


  C1 := 0; C2 := 0;
  for L2 in LList.Op.Select<T2> do
  begin
    if L2 is T3 then
      Inc(C2)
    else if L2 is T2 then
      Inc(C1)
    else
      Fail('Unexpected class enumerated by Select<T2>! Got ' + L2.ClassName);
  end;

  CheckEquals(1, C1, 'Expected one apparition of T2 in list.');
  CheckEquals(1, C2, 'Expected one apparition of T3 in list.');


  C1 := 0;
  for L3 in LList.Op.Select<T3> do
  begin
    if L3 is T3 then
      Inc(C1)
    else
      Fail('Unexpected class enumerated by Select<T3>! Got ' + L3.ClassName);
  end;

  CheckEquals(1, C1, 'Expected one apparition of T3 in list.');


  C1 := 0;
  for L4 in LList.Op.Select<TObject> do
    Inc(C1);

  CheckEquals(3, C1, 'Expected three apparitions of TObject in list.');

  LList.Free;

  LBadList := TList<Integer>.Create;

  { Verify restrictioned access }
  CheckException(ETypeException, procedure begin
    LBadList.Op.Select<TObject>;
  end, 'Expected a restriction problem!');

  LBadList.Free;
end;

procedure TTestEnex.TestSelectClassCollection;
var
  LList: TList<TObject>;
  LIList: IEnexCollection<TObject>;
begin
  LList := TList<TObject>.Create;
  LIList := LList;

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectClassCollection<TObject, TObject>.Create(LList, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectClassCollection<TObject, TObject>.Create(nil, TType<TObject>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );


  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectClassCollection<TObject, TObject>.CreateIntf(LIList, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectClassCollection<TObject, TObject>.CreateIntf(nil, TType<TObject>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  { The rest is tested by TestSelect3 }
end;

procedure TTestEnex.TestSelectCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<String>;
  YEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectCollection<Integer, String>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default),
        nil, TType<String>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil predicate).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectCollection<Integer, String>.Create(nil, function(Arg1: Integer): String begin Exit(IntToStr(Arg1)); end,
        TType<String>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectCollection<Integer, String>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default),
        function(Arg1: Integer): String begin Exit(IntToStr(Arg1)); end, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectCollection<Integer, String>.CreateIntf(nil, function(Arg1: Integer): String begin Exit(IntToStr(Arg1)); end, TType<String>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectCollection<Integer, String>.CreateIntf(Enum, nil, TType<String>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil pred).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectCollection<Integer, String>.CreateIntf(Enum, function(Arg1: Integer): String begin Exit(IntToStr(Arg1)); end, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexSelectCollection<Integer, String>.CreateIntf(Enum, function(Arg1: Integer): String begin Exit(IntToStr(Arg1)); end, TType<String>.Default);
  Check(XEnum.EqualsTo(MakeOrderedStringList(0, 100)), 'YEnum does not contain the right elements!');

  YEnum := TEnexSelectCollection<Integer, Integer>.CreateIntf(Enum, function(Arg1: Integer): Integer begin Exit(Arg1 * 2); end, TType<Integer>.Default);

  Check(YEnum.Min = 0, 'Expected XEnum.Min equal to 0');
  Check(YEnum.Max = 200, 'Expected XEnum.Max equal to 200');
  Check(YEnum.First = 0, 'Expected XEnum.First equal to 0');
  Check(YEnum.Last = 200, 'Expected XEnum.Last equal to 200');

  YEnum := TEnexSelectCollection<Integer, Integer>.CreateIntf(Enum, function(Arg1: Integer): Integer begin Exit(Arg1 + 10); end, TType<Integer>.Default);
  Check(YEnum.EqualsTo(MakeOrderedIntegerList(10, 110)), 'YEnum does not contain the right elements!');
end;

procedure TTestEnex.TestSelectKeysCollection;
var
  Enum: TDictionary<Integer, Integer>;
  KeysEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerDictionary(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectKeysCollection<Integer, Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create (nil coll).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectKeysCollection<Integer, Integer>.CreateIntf(Enum, TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectKeysCollection<Integer, Integer>.CreateIntf(Enum, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectKeysCollection<Integer, Integer>.CreateIntf(nil, TType<Integer>.Default, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  { Now apply predicates }
  KeysEnum := TEnexSelectKeysCollection<Integer, Integer>.Create(Enum);
  Check(KeysEnum.EqualsTo(MakeOrderedIntegerList(0, 100)), 'KeysEnum does not contain the right elements!');

  Enum.Free;
end;

procedure TTestEnex.TestSelectValuesCollection;
var
  Enum: TDictionary<Integer, Integer>;
  ValsEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerDictionary(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectValuesCollection<Integer, Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create (nil coll).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectValuesCollection<Integer, Integer>.CreateIntf(Enum, TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectValuesCollection<Integer, Integer>.CreateIntf(Enum, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSelectValuesCollection<Integer, Integer>.CreateIntf(nil, TType<Integer>.Default, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  { Now apply predicates }
  ValsEnum := TEnexSelectValuesCollection<Integer, Integer>.Create(Enum);
  Check(ValsEnum.EqualsTo(MakeOrderedIntegerList(1, 101)), 'ValsEnum does not contain the right elements!');

  Enum.Free;
end;

procedure TTestEnex.TestSingle;
begin
  TestGenericEnexCollection(InternalEnexTestSingle);
  TestGenericAssocEnexCollection(InternalAssocEnexTestSingle);
end;

procedure TTestEnex.TestSingleOrDefault;
begin
  TestGenericEnexCollection(InternalEnexTestSingleOrDefault);
  TestGenericAssocEnexCollection(InternalAssocEnexTestSingleOrDefault);
end;

procedure TTestEnex.TestSkip;
begin
  TestGenericEnexCollection(InternalTestSkip);
end;

procedure TTestEnex.TestSkipCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipCollection<Integer>.Create(nil, 1);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      TEnexSkipCollection<Integer>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default), 0);
    end,
    'EArgumentOutOfRangeException not thrown in Create (0 count).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipCollection<Integer>.CreateIntf(nil, 1, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipCollection<Integer>.CreateIntf(Enum, 1, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      TEnexSkipCollection<Integer>.CreateIntf(Enum, 0, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Create (0 count).'
  );

  { Test }
  XEnum := TEnexSkipCollection<Integer>.CreateIntf(Enum, 1, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(1, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipCollection<Integer>.CreateIntf(Enum, 50, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(50, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipCollection<Integer>.CreateIntf(Enum, 98, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(98, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipCollection<Integer>.CreateIntf(Enum, 200, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-1) = -1, 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestSkipWhile;
begin
  TestGenericEnexCollection(InternalTestSkipWhile);
end;

procedure TTestEnex.TestSkipWhileBetween;
begin
  TestGenericEnexCollection(InternalTestSkipWhileBetween);
end;

procedure TTestEnex.TestSkipWhileCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);


  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipWhileCollection<Integer>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default), nil);
    end,
    'ENilArgumentException not thrown in Create (nil predicate).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipWhileCollection<Integer>.Create(nil, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipWhileCollection<Integer>.CreateIntf(nil, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil pred).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 < 50); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(50, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 <= 5); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(6, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > -1); end, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-2) = -2, 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > 100); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 = 0); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(1, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexSkipWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 = -1); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 100)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestSkipWhileGreater;
begin
  TestGenericEnexCollection(InternalTestSkipWhileGreater);
end;

procedure TTestEnex.TestSkipWhileGreaterOrEqual;
begin
  TestGenericEnexCollection(InternalTestSkipWhileGreaterOrEqual);
end;

procedure TTestEnex.TestSkipWhileLower;
begin
  TestGenericEnexCollection(InternalTestSkipWhileLower);
end;

procedure TTestEnex.TestSkipWhileLowerOrEqual;
begin
  TestGenericEnexCollection(InternalTestSkipWhileLowerOrEqual);
end;

procedure TTestEnex.TestOrdered;
begin
  TestGenericEnexCollection(InternalTestOrdered);
end;

procedure TTestEnex.TestTake;
begin
  TestGenericEnexCollection(InternalTestTake);
end;

procedure TTestEnex.TestTakeCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeCollection<Integer>.Create(nil, 1);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      TEnexTakeCollection<Integer>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default), 0);
    end,
    'EArgumentOutOfRangeException not thrown in Create (0 count).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeCollection<Integer>.CreateIntf(nil, 1, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeCollection<Integer>.CreateIntf(Enum, 1, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin
      TEnexTakeCollection<Integer>.CreateIntf(Enum, 0, TType<Integer>.Default);
    end,
    'EArgumentOutOfRangeException not thrown in Create (0 count).'
  );

  { Test }
  XEnum := TEnexTakeCollection<Integer>.CreateIntf(Enum, 1, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-1) = 0, 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeCollection<Integer>.CreateIntf(Enum, 50, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 49)), 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeCollection<Integer>.CreateIntf(Enum, 98, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 97)), 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeCollection<Integer>.CreateIntf(Enum, 200, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 100)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestTakeWhile;
begin
  TestGenericEnexCollection(InternalTestTakeWhile);
end;

procedure TTestEnex.TestTakeWhileBetween;
begin
  TestGenericEnexCollection(InternalTestTakeWhileBetween);
end;

procedure TTestEnex.TestTakeWhileCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);


  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeWhileCollection<Integer>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default), nil);
    end,
    'ENilArgumentException not thrown in Create (nil predicate).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeWhileCollection<Integer>.Create(nil, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeWhileCollection<Integer>.CreateIntf(nil, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil pred).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 < 50); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 49)), 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 <= 5); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 5)), 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > -1); end, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > 100); end, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-2) = -2, 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 = 0); end, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-1) = 0, 'XEnum does not contain the right elements!');

  XEnum := TEnexTakeWhileCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 = 5); end, TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-2) = -2, 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestTakeWhileGreater;
begin
  TestGenericEnexCollection(InternalTestTakeWhileGreater);
end;

procedure TTestEnex.TestTakeWhileGreaterOrEqual;
begin
  TestGenericEnexCollection(InternalTestTakeWhileGreaterOrEqual);
end;

procedure TTestEnex.TestTakeWhileLower;
begin
  TestGenericEnexCollection(InternalTestTakeWhileLower);
end;

procedure TTestEnex.TestTakeWhileLowerOrEqual;
begin
  TestGenericEnexCollection(InternalTestTakeWhileLowerOrEqual);
end;

procedure TTestEnex.TestToDictionary;
begin
  TestGenericAssocEnexCollection(InternalTestToDictionary);
end;

procedure TTestEnex.TestToDynamicArray;
begin
  TestGenericEnexCollection(InternalEnexTestToDynamicArray);
  TestGenericAssocEnexCollection(InternalAssocEnexTestToDynamicArray);
end;

procedure TTestEnex.TestToFixedArray;
begin
  TestGenericEnexCollection(InternalEnexTestToFixedArray);
  TestGenericAssocEnexCollection(InternalAssocEnexTestToFixedArray);
end;

procedure TTestEnex.TestToList;
begin
  TestGenericEnexCollection(InternalTestToList);
end;

procedure TTestEnex.TestToSet;
begin
  TestGenericEnexCollection(InternalTestToSet);
end;

procedure TTestEnex.TestToArray;
begin
  TestGenericEnexCollection(InternalEnexTestToArray);
  TestGenericAssocEnexCollection(InternalAssocEnexTestToArray);
end;

procedure TTestEnex.TestUnion;
begin
  TestGenericEnexCollection(InternalTestUnion);
end;

procedure TTestEnex.TestUnionCollection;
var
  Enum1, Enum2: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make two lists }
  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(101, 200);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.Create(
        nil,
        TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default));
    end,
    'ENilArgumentException not thrown in Create (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.Create(
        TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default),
        nil);
    end,
    'ENilArgumentException not thrown in Create (nil enum 2).'
  );


  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf(Enum1, Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf1(nil, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf1(Enum1, nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf1(Enum1, TEnexWrapCollection<Integer>.Create(Enum2, TType<Integer>.Default), nil);
    end,
    'ENilArgumentException not thrown in CreateIntf1 (nil type).'
  );



  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf2(nil, Enum2, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 1).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil enum 2).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexUnionCollection<Integer>.CreateIntf2(TEnexWrapCollection<Integer>.Create(Enum1, TType<Integer>.Default), Enum2, nil);
    end,
    'ENilArgumentException not thrown in CreateIntf2 (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexUnionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 200)), 'XEnum does not contain the right elements!');

  { Make other two lists }
  Enum1 := MakeOrderedIntegerList(0, 1);
  Enum2 := MakeOrderedIntegerList(1, 2);
  XEnum := TEnexUnionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);

  Check(XEnum.First = 0, 'XEnum.First = 0');
  Check(XEnum.Last = 2, 'XEnum.Last = 2');
  Check(Accumulator.Sum<Integer>(XEnum) = 3, 'XEnum.Sum = 3');

  Enum1 := MakeOrderedIntegerList(0, 100);
  Enum2 := MakeOrderedIntegerList(50, 110);
  XEnum := TEnexUnionCollection<Integer>.CreateIntf(Enum1, Enum2, TType<Integer>.Default);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 110)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestValueForKey;
begin
  TestGenericAssocEnexCollection(InternalTestValueForKey);
end;

procedure TTestEnex.TestWhere;
begin
  TestGenericEnexCollection(InternalTestWhere);
end;

procedure TTestEnex.TestWhereBetween;
begin
  { With real data }
  InternalTestWhereBetween(TList<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));
  InternalTestWhereBetween(TSortedList<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));
  InternalTestWhereBetween(TArraySet<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));
  InternalTestWhereBetween(TBag<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));
  InternalTestWhereBetween(THashSet<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));
  InternalTestWhereBetween(TLinkedList<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));
  InternalTestWhereBetween(TQueue<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));
  InternalTestWhereBetween(TStack<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax)));

  { With no data }
  InternalTestWhereBetween(TList<Integer>.Create());
  InternalTestWhereBetween(TSortedList<Integer>.Create());
  InternalTestWhereBetween(TArraySet<Integer>.Create());
  InternalTestWhereBetween(TBag<Integer>.Create());
  InternalTestWhereBetween(THashSet<Integer>.Create());
  InternalTestWhereBetween(TLinkedList<Integer>.Create());
  InternalTestWhereBetween(TQueue<Integer>.Create());
  InternalTestWhereBetween(TStack<Integer>.Create());
end;

procedure TTestEnex.TestWhereCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
  Pred: TPredicate<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);
  Pred := function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end;

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexWhereCollection<Integer>.Create(TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default), nil, False);
    end,
    'ENilArgumentException not thrown in Create (nil predicate).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexWhereCollection<Integer>.Create(nil, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, False);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexWhereCollection<Integer>.CreateIntf(nil, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default, False);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexWhereCollection<Integer>.CreateIntf(Enum, nil, TType<Integer>.Default, False);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil pred).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexWhereCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, nil, False);
    end,
    'ENilArgumentException not thrown in CreateIntf (nil type).'
  );

  { Now apply predicates }
  XEnum := TEnexWhereCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 > 50); end, TType<Integer>.Default, False);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(51, 100)), 'XEnum does not contain the right elements!');

  XEnum := TEnexWhereCollection<Integer>.CreateIntf(Enum, function(Arg1: Integer): Boolean begin Exit(Arg1 >= 10); end, TType<Integer>.Default, True);
  Check(XEnum.EqualsTo(MakeOrderedIntegerList(0, 9)), 'XEnum does not contain the right elements!');
end;

procedure TTestEnex.TestWhereGreater;
begin
  TestGenericEnexCollection(InternalTestWhereGreater);
end;

procedure TTestEnex.TestWhereGreaterOrEqual;
begin
  TestGenericEnexCollection(InternalTestWhereGreaterOrEqual);
end;

procedure TTestEnex.TestWhereKeyBetween;
begin
  TestGenericAssocEnexCollection(InternalTestWhereKeyBetween);
end;

procedure TTestEnex.TestWhereKeyGreater;
begin
  TestGenericAssocEnexCollection(InternalTestWhereKeyGreater);
end;

procedure TTestEnex.TestWhereKeyGreaterOrEqual;
begin
  TestGenericAssocEnexCollection(InternalTestWhereKeyGreaterOrEqual);
end;

procedure TTestEnex.TestWhereKeyLower;
begin
  TestGenericAssocEnexCollection(InternalTestWhereKeyLower);
end;

procedure TTestEnex.TestWhereKeyLowerOrEqual;
begin
  TestGenericAssocEnexCollection(InternalTestWhereKeyLowerOrEqual);
end;

procedure TTestEnex.TestWhereLower;
begin
  TestGenericEnexCollection(InternalTestWhereLower);
end;

procedure TTestEnex.TestWhereLowerOrEqual;
begin
  TestGenericEnexCollection(InternalTestWhereLowerOrEqual);
end;

procedure TTestEnex.TestWhereNot;
begin
  TestGenericEnexCollection(InternalTestWhereNot);
end;

procedure TTestEnex.TestWhereValueBetween;
begin
  TestGenericAssocEnexCollection(InternalTestWhereValueBetween);
end;

procedure TTestEnex.TestWhereValueGreater;
begin
  TestGenericAssocEnexCollection(InternalTestWhereValueGreater);
end;

procedure TTestEnex.TestWhereValueGreaterOrEqual;
begin
  TestGenericAssocEnexCollection(InternalTestWhereValueGreaterOrEqual);
end;

procedure TTestEnex.TestWhereValueLower;
begin
  TestGenericAssocEnexCollection(InternalTestWhereValueLower);
end;

procedure TTestEnex.TestWhereValueLowerOrEqual;
begin
  TestGenericAssocEnexCollection(InternalTestWhereValueLowerOrEqual);
end;

procedure TTestEnex.TestWrapCollection;
var
  Enum: IEnexCollection<Integer>;
  XEnum: IEnexCollection<Integer>;
begin
  { Make a list }
  Enum := MakeOrderedIntegerList(0, 100);

  { Verify constructors }
  CheckException(ENilArgumentException,
    procedure() begin
      TEnexWrapCollection<Integer>.Create(nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in Create (nil enum).'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      TEnexWrapCollection<Integer>.Create(Enum, nil);
    end,
    'ENilArgumentException not thrown in Create (nil type).'
  );

  XEnum := TEnexWrapCollection<Integer>.Create(Enum, TType<Integer>.Default);
  Check(XEnum.EqualsTo(Enum), 'XEnum does not contain the right elements!');

  XEnum := TEnexWrapCollection<Integer>.Create(TList<Integer>.Create(), TType<Integer>.Default);
  Check(XEnum.SingleOrDefault(-1) = -1, 'XEnum does not contain the right elements!');
end;

procedure SetUpEnexTests();
var
  LHeap: THeap<Integer>;
  I: Integer;
begin
  { Create all testable collections! }

  { With real data }
  LHeap := THeap<Integer>.Create();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
    LHeap.Add(I);
  LHeap_Full := LHeap;

  LList_Full := TList<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LSortedList_Full := TSortedList<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LAraySet_Full := TArraySet<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LBag_Full := TBag<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LSortedBag_Full := TSortedBag<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LHashSet_Full := THashSet<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LSortedSet_Full := TSortedSet<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LLinkedList_Full := TLinkedList<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LQueue_Full := TQueue<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LLinkedQueue_Full := TQueue<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LStack_Full := TStack<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));
  LLinkedStack_Full := TLinkedStack<Integer>.Create(MakeRandomIntegerList(ListElements, ListMax));

  { DICTIONARIES }
  LDictionary_Full := TDictionary<Integer, Integer>.Create();
  (LDictionary_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LDictionary_Full[I] := Random(ListMax);
  end;
  LDictKey_Full := LDictionary_Full.Keys;
  LDictVal_Full := LDictionary_Full.Values;

  LSortedDictionary_Full := TSortedDictionary<Integer, Integer>.Create();
  (LSortedDictionary_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LSortedDictionary_Full[I] := Random(ListMax);
  end;
  LSoDictKey_Full := LSortedDictionary_Full.Keys;
  LSoDictVal_Full := LSortedDictionary_Full.Values;

  { MULTI MAPS }

  LMM_Full := TMultiMap<Integer, Integer>.Create();
  (LMM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LMM_Full.Add(I, ListMax);
  end;
  LMMKey_Full := LMM_Full.Keys;
  LMMVal_Full := LMM_Full.Values;

  LSoMM_Full := TSortedMultiMap<Integer, Integer>.Create();
  (LSoMM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LSoMM_Full.Add(I, ListMax);
  end;
  LSoMMKey_Full := LSoMM_Full.Keys;
  LSoMMVal_Full := LSoMM_Full.Values;

  LDoSoMM_Full := TDoubleSortedMultiMap<Integer, Integer>.Create();
  (LDoSoMM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LDoSoMM_Full.Add(I, ListMax);
  end;
  LDoSoMMKey_Full := LDoSoMM_Full.Keys;
  LDoSoMMVal_Full := LDoSoMM_Full.Values;

  { BIDI MAPS }
  LBDM_Full := TBidiMap<Integer, Integer>.Create();
  (LBDM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LBDM_Full.Add(I, ListMax);
  end;
  LBDMKey_Full := LBDM_Full.Keys;
  LBDMVal_Full := LBDM_Full.Values;

  LSoBDM_Full := TSortedBidiMap<Integer, Integer>.Create();
  (LSoBDM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LSoBDM_Full.Add(I, ListMax);
  end;
  LSoBDMKey_Full := LSoBDM_Full.Keys;
  LSoBDMVal_Full := LSoBDM_Full.Values;

  LDoSoBDM_Full := TDoubleSortedBidiMap<Integer, Integer>.Create();
  (LDoSoBDM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LDoSoBDM_Full.Add(I, ListMax);
  end;
  LDoSoBDMKey_Full := LDoSoBDM_Full.Keys;
  LDoSoBDMVal_Full := LDoSoBDM_Full.Values;

  { SET MAPS }
  LSM_Full := TDistinctMultiMap<Integer, Integer>.Create();
  (LSM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LSM_Full.Add(I, ListMax);
  end;
  LSMKey_Full := LSM_Full.Keys;
  LSMVal_Full := LSM_Full.Values;

  LSoSM_Full := TSortedDistinctMultiMap<Integer, Integer>.Create();
  (LSoSM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LSoSM_Full.Add(I, ListMax);
  end;
  LSoSMKey_Full := LSoSM_Full.Keys;
  LSoSMVal_Full := LSoSM_Full.Values;

  LDoSoSM_Full := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();
  (LDoSoSM_Full as IInterface)._AddRef();
  for I in MakeRandomIntegerList(ListElements, ListMax) do
  begin
     LDoSoSM_Full.Add(I, ListMax);
  end;
  LDoSoSMKey_Full := LDoSoSM_Full.Keys;
  LDoSoSMVal_Full := LDoSoSM_Full.Values;

  LPrioQueue_Full := TPriorityQueue<Integer, Integer>.Create();
  (LPrioQueue_Full as IInterface)._AddRef();
  for I in MakeOrderedIntegerList(ListElements, ListMax) do
  begin
     LPrioQueue_Full.Enqueue(I, I + 1);
  end;

  { With one element }
  LHeap := THeap<Integer>.Create();
  LHeap.Add(1);
  LHeap_One := LHeap;

  LList_One := TList<Integer>.Create([1]);
  LSortedList_One := TSortedList<Integer>.Create([2]);
  LAraySet_One := TArraySet<Integer>.Create([3]);
  LBag_One := TBag<Integer>.Create([4]);
  LSortedBag_One := TSortedBag<Integer>.Create([4]);
  LHashSet_One := THashSet<Integer>.Create([5]);
  LSortedSet_One := TSortedSet<Integer>.Create([5]);
  LLinkedList_One := TLinkedList<Integer>.Create([6]);
  LQueue_One := TQueue<Integer>.Create([7]);
  LLinkedQueue_One := TQueue<Integer>.Create([7]);
  LStack_One := TStack<Integer>.Create([8]);
  LLinkedStack_One := TLinkedStack<Integer>.Create([8]);

  LDictionary_One := TDictionary<Integer, Integer>.Create();
  (LDictionary_One as IInterface)._AddRef();
  LDictionary_One.Add(9,9);
  LDictKey_One := LDictionary_One.Keys;
  LDictVal_One := LDictionary_One.Values;

  LSortedDictionary_One := TSortedDictionary<Integer, Integer>.Create();
  (LSortedDictionary_One as IInterface)._AddRef();
  LSortedDictionary_One.Add(9,9);
  LSoDictKey_One := LSortedDictionary_One.Keys;
  LSoDictVal_One := LSortedDictionary_One.Values;

  { MULTI MAPS }
  LMM_One := TMultiMap<Integer, Integer>.Create();
  (LMM_One as IInterface)._AddRef();
  LMM_One.Add(9,9);
  LMMKey_One := LMM_One.Keys;
  LMMVal_One := LMM_One.Values;

  LSoMM_One := TSortedMultiMap<Integer, Integer>.Create();
  (LSoMM_One as IInterface)._AddRef();
  LSoMM_One.Add(9,9);
  LSoMMKey_One := LSoMM_One.Keys;
  LSoMMVal_One := LSoMM_One.Values;

  LDoSoMM_One := TDoubleSortedMultiMap<Integer, Integer>.Create();
  (LDoSoMM_One as IInterface)._AddRef();
  LDoSoMM_One.Add(9,9);
  LDoSoMMKey_One := LDoSoMM_One.Keys;
  LDoSoMMVal_One := LDoSoMM_One.Values;

  { BIDI MAPS }
  LBDM_One := TBidiMap<Integer, Integer>.Create();
  (LBDM_One as IInterface)._AddRef();
  LBDM_One.Add(9,9);
  LBDMKey_One := LBDM_One.Keys;
  LBDMVal_One := LBDM_One.Values;

  LSoBDM_One := TSortedBidiMap<Integer, Integer>.Create();
  (LSoBDM_One as IInterface)._AddRef();
  LSoBDM_One.Add(9,9);
  LSoBDMKey_One := LSoBDM_One.Keys;
  LSoBDMVal_One := LSoBDM_One.Values;

  LDoSoBDM_One := TDoubleSortedBidiMap<Integer, Integer>.Create();
  (LDoSoBDM_One as IInterface)._AddRef();
  LDoSoBDM_One.Add(9,9);
  LDoSoBDMKey_One := LDoSoBDM_One.Keys;
  LDoSoBDMVal_One := LDoSoBDM_One.Values;

  { SET MAPS }
  LSM_One := TDistinctMultiMap<Integer, Integer>.Create();
  (LSM_One as IInterface)._AddRef();
  LSM_One.Add(9,9);
  LSMKey_One := LSM_One.Keys;
  LSMVal_One := LSM_One.Values;

  LSoSM_One := TSortedDistinctMultiMap<Integer, Integer>.Create();
  (LSoSM_One as IInterface)._AddRef();
  LSoSM_One.Add(9,9);
  LSoSMKey_One := LSoSM_One.Keys;
  LSoSMVal_One := LSoSM_One.Values;

  LDoSoSM_One := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();
  (LDoSoSM_One as IInterface)._AddRef();
  LDoSoSM_One.Add(9,9);
  LDoSoSMKey_One := LDoSoSM_One.Keys;
  LDoSoSMVal_One := LDoSoSM_One.Values;

  LPrioQueue_One := TPriorityQueue<Integer, Integer>.Create();
  (LPrioQueue_One as IInterface)._AddRef();
  LPrioQueue_One.Enqueue(Random(ListMax), Random(ListMax));

  { With no data }
  LHeap_Empty := THeap<Integer>.Create();
  LList_Empty := TList<Integer>.Create();
  LSortedList_Empty := TSortedList<Integer>.Create();
  LAraySet_Empty := TArraySet<Integer>.Create();
  LBag_Empty := TBag<Integer>.Create();
  LSortedBag_Empty := TSortedBag<Integer>.Create();
  LHashSet_Empty := THashSet<Integer>.Create();
  LSortedSet_Empty := TSortedSet<Integer>.Create();
  LLinkedList_Empty := TLinkedList<Integer>.Create();
  LQueue_Empty := TQueue<Integer>.Create();
  LLinkedQueue_Empty := TQueue<Integer>.Create();
  LStack_Empty := TStack<Integer>.Create();
  LLinkedStack_Empty := TLinkedStack<Integer>.Create();

  LDictionary_Empty := TDictionary<Integer, Integer>.Create();
  (LDictionary_Empty as IInterface)._AddRef();
  LDictKey_Empty := LDictionary_Empty.Keys;
  LDictVal_Empty := LDictionary_Empty.Values;

  LSortedDictionary_Empty := TSortedDictionary<Integer, Integer>.Create();
  (LSortedDictionary_Empty as IInterface)._AddRef();
  LSoDictKey_Empty := LSortedDictionary_Empty.Keys;
  LSoDictVal_Empty := LSortedDictionary_Empty.Values;

  { MULTI MAPS }
  LMM_Empty := TMultiMap<Integer, Integer>.Create();
  (LMM_Empty as IInterface)._AddRef();
  LMMKey_Empty := LMM_Empty.Keys;
  LMMVal_Empty := LMM_Empty.Values;

  LSoMM_Empty := TSortedMultiMap<Integer, Integer>.Create();
  (LSoMM_Empty as IInterface)._AddRef();
  LSoMMKey_Empty := LSoMM_Empty.Keys;
  LSoMMVal_Empty := LSoMM_Empty.Values;

  LDoSoMM_Empty := TDoubleSortedMultiMap<Integer, Integer>.Create();
  (LDoSoMM_Empty as IInterface)._AddRef();
  LDoSoMMKey_Empty := LDoSoMM_Empty.Keys;
  LDoSoMMVal_Empty := LDoSoMM_Empty.Values;

  { BIDI MAPS }
  LBDM_Empty := TBidiMap<Integer, Integer>.Create();
  (LBDM_Empty as IInterface)._AddRef();
  LBDMKey_Empty := LBDM_Empty.Keys;
  LBDMVal_Empty := LBDM_Empty.Values;

  LSoBDM_Empty := TSortedBidiMap<Integer, Integer>.Create();
  (LSoBDM_Empty as IInterface)._AddRef();
  LSoBDMKey_Empty := LSoBDM_Empty.Keys;
  LSoBDMVal_Empty := LSoBDM_Empty.Values;

  LDoSoBDM_Empty := TDoubleSortedBidiMap<Integer, Integer>.Create();
  (LDoSoBDM_Empty as IInterface)._AddRef();
  LDoSoBDMKey_Empty := LDoSoBDM_Empty.Keys;
  LDoSoBDMVal_Empty := LDoSoBDM_Empty.Values;

  { SET MAPS }
  LSM_Empty := TDistinctMultiMap<Integer, Integer>.Create();
  (LSM_Empty as IInterface)._AddRef();
  LSMKey_Empty := LSM_Empty.Keys;
  LSMVal_Empty := LSM_Empty.Values;

  LSoSM_Empty := TSortedDistinctMultiMap<Integer, Integer>.Create();
  (LSoSM_Empty as IInterface)._AddRef();
  LSoSMKey_Empty := LSoSM_Empty.Keys;
  LSoSMVal_Empty := LSoSM_Empty.Values;

  LDoSoSM_Empty := TDoubleSortedDistinctMultiMap<Integer, Integer>.Create();
  (LDoSoSM_Empty as IInterface)._AddRef();
  LDoSoSMKey_Empty := LDoSoSM_Empty.Keys;
  LDoSoSMVal_Empty := LDoSoSM_Empty.Values;

  LPrioQueue_Empty := TPriorityQueue<Integer, Integer>.Create();
  (LPrioQueue_Empty as IInterface)._AddRef();
end;

procedure SetUpStdEnexTests();
begin
  { With data }
  LWrapColl_Full := TEnexWrapCollection<Integer>.Create(LList_Full, TType<Integer>.Default);
  LFillColl_Full := Collection.Fill<Integer>(Random(ListMax), ListElements);
  LIntervalColl_Full := Collection.Interval<Integer>(0, ListElements);
  LWhereColl_Full := TEnexWhereCollection<Integer>.CreateIntf(LList_Full,
      function(Arg1: Integer): Boolean begin Exit(Arg1 > (ListMax div 2)); end, TType<Integer>.Default, False);
  LSelectColl_Full := TEnexSelectCollection<Integer, Integer>.CreateIntf(LList_Full,
      function(Arg1: Integer): Integer begin Exit(Arg1 + 1); end, TType<Integer>.Default);
  LCastColl_Full := TEnexCastCollection<Integer, Integer>.CreateIntf(LList_Full, TType<Integer>.Default, TType<Integer>.Default);
  LConcatColl_Full := TEnexConcatCollection<Integer>.CreateIntf(LList_Full, LSortedList_Full, TType<Integer>.Default);
  LUnionColl_Full := TEnexUnionCollection<Integer>.CreateIntf(LList_Full, LSortedList_Full, TType<Integer>.Default);
  LExclColl_Full := TEnexExclusionCollection<Integer>.CreateIntf(LList_Full, LSortedList_Full, TType<Integer>.Default);
  LInterColl_Full := TEnexIntersectionCollection<Integer>.CreateIntf(LList_Full, LList_Full, TType<Integer>.Default);
  LDistinctColl_Full := TEnexDistinctCollection<Integer>.CreateIntf(LList_Full, TType<Integer>.Default);
  LRangeColl_Full := TEnexRangeCollection<Integer>.CreateIntf(LList_Full, 0, ListElements - 1, TType<Integer>.Default);
  LSkipColl_Full := TEnexSkipCollection<Integer>.CreateIntf(LList_Full, 1, TType<Integer>.Default);
  LTakeColl_Full := TEnexTakeCollection<Integer>.CreateIntf(LList_Full, ListElements, TType<Integer>.Default);
  LSkipWhileColl_Full := TEnexSkipWhileCollection<Integer>.CreateIntf(LList_Full,
      function(Arg1: Integer): Boolean begin Exit(false); end, TType<Integer>.Default);
  LTakeWhileColl_Full := TEnexTakeWhileCollection<Integer>.CreateIntf(LList_Full,
      function(Arg1: Integer): Boolean begin Exit(true); end, TType<Integer>.Default);

  LSelectKeysColl_Full := TEnexSelectKeysCollection<Integer, Integer>.Create(LDictionary_Full);
  LSelectValuesColl_Full := TEnexSelectValuesCollection<Integer, Integer>.Create(LDictionary_Full);
  LAssocWrapColl_Full := TEnexAssociativeWrapCollection<Integer, Integer>.Create(LDictionary_Full, TType<Integer>.Default, TType<Integer>.Default);

  LAssocWhereColl_Full := TEnexAssociativeWhereCollection<Integer, Integer>.Create(LDictionary_Full,
    function(Arg1, Arg2: Integer): Boolean begin
      Exit(Arg1 > (ListMax div 2));
    end, False);

  LAssocDByKeysColl_Full := TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.Create(LMM_Full);
  LAssocDByValuesColl_Full := TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.Create(LMM_Full);

  { With one element }
  LWrapColl_One := TEnexWrapCollection<Integer>.Create(LList_One, TType<Integer>.Default);
  LFillColl_One := Collection.Fill<Integer>(Random(ListMax), 1);
  LIntervalColl_One := Collection.Interval<Integer>(0, 1, 2);

  LWhereColl_One := TEnexWhereCollection<Integer>.CreateIntf(LList_One,
      function(Arg1: Integer): Boolean begin Exit(true); end, TType<Integer>.Default, False);
  LSelectColl_One := TEnexSelectCollection<Integer, Integer>.CreateIntf(LList_One,
      function(Arg1: Integer): Integer begin Exit(Arg1 + 1); end, TType<Integer>.Default);
  LCastColl_One := TEnexCastCollection<Integer, Integer>.CreateIntf(LList_One, TType<Integer>.Default, TType<Integer>.Default);
  LConcatColl_One := TEnexConcatCollection<Integer>.CreateIntf(LList_One, LSortedList_Empty, TType<Integer>.Default);
  LUnionColl_One := TEnexUnionCollection<Integer>.CreateIntf(LList_One, LList_One, TType<Integer>.Default);
  LExclColl_One := TEnexExclusionCollection<Integer>.CreateIntf(LList_One, LSortedList_Empty, TType<Integer>.Default);
  LInterColl_One := TEnexIntersectionCollection<Integer>.CreateIntf(LList_One, LList_One, TType<Integer>.Default);
  LDistinctColl_One := TEnexDistinctCollection<Integer>.CreateIntf(LList_One, TType<Integer>.Default);
  LRangeColl_One := TEnexRangeCollection<Integer>.CreateIntf(LList_Full, 0, 0, TType<Integer>.Default);
  LSkipColl_One := TEnexSkipCollection<Integer>.CreateIntf(LList_Full, ListElements - 1, TType<Integer>.Default);
  LTakeColl_One := TEnexTakeCollection<Integer>.CreateIntf(LList_Full, 1, TType<Integer>.Default);
  LSkipWhileColl_One := TEnexSkipWhileCollection<Integer>.CreateIntf(LList_One,
      function(Arg1: Integer): Boolean begin Exit(false); end, TType<Integer>.Default);
  LTakeWhileColl_One := TEnexTakeWhileCollection<Integer>.CreateIntf(LList_One,
      function(Arg1: Integer): Boolean begin Exit(true); end, TType<Integer>.Default);

  LSelectKeysColl_One := TEnexSelectKeysCollection<Integer, Integer>.Create(LDictionary_One);
  LSelectValuesColl_One := TEnexSelectValuesCollection<Integer, Integer>.Create(LDictionary_One);
  LAssocWrapColl_One := TEnexAssociativeWrapCollection<Integer, Integer>.Create(LDictionary_One, TType<Integer>.Default, TType<Integer>.Default);

  LAssocWhereColl_One := TEnexAssociativeWhereCollection<Integer, Integer>.Create(LDictionary_One,
    function(Arg1, Arg2: Integer): Boolean begin
      Exit(Arg1 > (ListMax div 2));
    end, False);

  LAssocDByKeysColl_One := TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.Create(LMM_One);
  LAssocDByValuesColl_One := TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.Create(LMM_One);

  { With no elements }
  LWrapColl_Empty := TEnexWrapCollection<Integer>.Create(LList_Empty, TType<Integer>.Default);
  LWhereColl_Empty := TEnexWhereCollection<Integer>.CreateIntf(LList_Full,
      function(Arg1: Integer): Boolean begin Exit(false); end, TType<Integer>.Default, False);
  LSelectColl_Empty := TEnexSelectCollection<Integer, Integer>.CreateIntf(LList_Empty,
      function(Arg1: Integer): Integer begin Exit(Arg1 + 1); end, TType<Integer>.Default);
  LCastColl_Empty := TEnexCastCollection<Integer, Integer>.CreateIntf(LList_Empty, TType<Integer>.Default, TType<Integer>.Default);
  LConcatColl_Empty := TEnexConcatCollection<Integer>.CreateIntf(LList_Empty, LSortedList_Empty, TType<Integer>.Default);
  LUnionColl_Empty := TEnexUnionCollection<Integer>.CreateIntf(LList_Empty, LSortedList_Empty, TType<Integer>.Default);
  LExclColl_Empty := TEnexExclusionCollection<Integer>.CreateIntf(LList_Full, LList_Full, TType<Integer>.Default);
  LInterColl_Empty := TEnexIntersectionCollection<Integer>.CreateIntf(LList_One, LList_Empty, TType<Integer>.Default);
  LDistinctColl_Empty := TEnexDistinctCollection<Integer>.CreateIntf(LList_Empty, TType<Integer>.Default);
  LRangeColl_Empty := TEnexRangeCollection<Integer>.CreateIntf(LList_Full, ListElements + 1, ListElements + 2, TType<Integer>.Default);
  LSkipColl_Empty := TEnexSkipCollection<Integer>.CreateIntf(LList_Full, ListElements, TType<Integer>.Default);
  LTakeColl_Empty := TEnexTakeCollection<Integer>.CreateIntf(LList_Empty, 1, TType<Integer>.Default);
  LSkipWhileColl_Empty := TEnexSkipWhileCollection<Integer>.CreateIntf(LList_Full,
      function(Arg1: Integer): Boolean begin Exit(true); end, TType<Integer>.Default);
  LTakeWhileColl_Empty := TEnexTakeWhileCollection<Integer>.CreateIntf(LList_Full,
      function(Arg1: Integer): Boolean begin Exit(false); end, TType<Integer>.Default);

  LSelectKeysColl_Empty := TEnexSelectKeysCollection<Integer, Integer>.Create(LDictionary_Empty);
  LSelectValuesColl_Empty := TEnexSelectValuesCollection<Integer, Integer>.Create(LDictionary_Empty);
  LAssocWrapColl_Empty := TEnexAssociativeWrapCollection<Integer, Integer>.Create(LDictionary_Empty, TType<Integer>.Default, TType<Integer>.Default);

  LAssocWhereColl_Empty := TEnexAssociativeWhereCollection<Integer, Integer>.Create(LDictionary_Empty,
    function(Arg1, Arg2: Integer): Boolean begin
      Exit(Arg1 > (ListMax div 2));
    end, False);

  LAssocDByKeysColl_Empty := TEnexAssociativeDistinctByKeysCollection<Integer, Integer>.Create(LMM_Empty);
  LAssocDByValuesColl_Empty := TEnexAssociativeDistinctByValuesCollection<Integer, Integer>.Create(LMM_Empty);
end;

{ TTestEnexOther }

procedure TTestEnexOther.TestObjCompareTo_Simple;
var
  L1, L2, L3, L4: TList<Integer>;
  S1: TStack<Integer>;
  X1: TDictionary<Integer, Integer>;
begin
  L1 := TList<Integer>.Create([1, 2, 3]);
  L2 := TList<Integer>.Create([1, 2, 3]);
  L3 := TList<Integer>.Create([2, 3, 1]);
  L4 := TList<Integer>.Create([1, 2, 3, 4]);
  S1 := TStack<Integer>.Create([1, 2, 3]);
  X1 := TDictionary<Integer, Integer>.Create();

  CheckEquals(1, L1.CompareTo(nil));
  CheckEquals(0, L1.CompareTo(L1));
  CheckEquals(0, L1.CompareTo(L2));
  CheckEquals(-1, L1.CompareTo(L3));
  CheckEquals(-1, L1.CompareTo(L4));
  CheckEquals(0, L1.CompareTo(S1));
  CheckEquals(0, S1.CompareTo(L1));
  CheckEquals(1, S1.CompareTo(X1));

  CheckEquals(0, L1.RefCount);
  CheckEquals(0, L2.RefCount);
  CheckEquals(0, L3.RefCount);
  CheckEquals(0, L4.RefCount);
  CheckEquals(0, S1.RefCount);
  CheckEquals(0, X1.RefCount);

  L1.Free;
  L2.Free;
  L3.Free;
  L4.Free;
  S1.Free;
  X1.Free;
end;

procedure TTestEnexOther.TestObjContains_Simple;
var
  L: TObjectList<TList<Integer>>;
  X, Y: TList<Integer>;
begin
  L := TObjectList<TList<Integer>>.Create();
  L.OwnsObjects := true;
  L.Add(TList<Integer>.Create([1, 2, 3]));
  X := TList<Integer>.Create([1, 2, 3]);
  Y := TList<Integer>.Create([1, 2, 3, 4]);

  CheckTrue(L.Contains(X));
  CheckFalse(L.Contains(Y));

  X.Free;
  Y.Free;
  L.Free;
end;

procedure TTestEnexOther.TestObjEquals_Simple;
var
  L1, L2, L3, L4: TList<Integer>;
  S1: TStack<Integer>;
  X1: TDictionary<Integer, Integer>;
begin
  L1 := TList<Integer>.Create([1, 2, 3]);
  L2 := TList<Integer>.Create([1, 2, 3]);
  L3 := TList<Integer>.Create([2, 3, 1]);
  L4 := TList<Integer>.Create([1, 2, 3, 4]);
  S1 := TStack<Integer>.Create([1, 2, 3]);
  X1 := TDictionary<Integer, Integer>.Create();

  CheckFalse(L1.Equals(nil));
  CheckTrue(L1.Equals(L1));
  CheckTrue(L1.Equals(L2));
  CheckFalse(L1.Equals(L3));
  CheckFalse(L1.Equals(L4));
  CheckTrue(L1.Equals(S1));
  CheckTrue(S1.Equals(L1));
  CheckFalse(S1.Equals(X1));

  CheckEquals(0, L1.RefCount);
  CheckEquals(0, L2.RefCount);
  CheckEquals(0, L3.RefCount);
  CheckEquals(0, L4.RefCount);
  CheckEquals(0, S1.RefCount);
  CheckEquals(0, X1.RefCount);

  L1.Free;
  L2.Free;
  L3.Free;
  L4.Free;
  S1.Free;
  X1.Free;
end;

procedure TTestEnexOther.TestObjHashCode_Simple;
var
  L1: TList<Integer>;
begin
  L1 := TList<Integer>.Create();
  CheckEquals(0, L1.GetHashCode());

  L1.Add(1);
  CheckEquals(($0F * 0) + 1, L1.GetHashCode());

  L1.Add(2);
  CheckEquals(($0F * 1) + 2, L1.GetHashCode());

  L1.Add(3);
  CheckEquals(($0F * (($0F * 1) + 2)) + 3, L1.GetHashCode());

  L1.Free;
end;

initialization
  TestFramework.RegisterTest(TTestEnex.Suite);
  TestFramework.RegisterTest(TTestEnexOther.Suite);
  SetUpEnexTests();
  SetUpStdEnexTests()

end.
