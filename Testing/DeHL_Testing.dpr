program DeHL_Testing;
{

  DDDD           H   H  L
  D   D   eeee   H   H  L
  D   D  eeeeee  HHHHH  L      TESTING PROJECT!
  D   D  e       H   H  L
  DDDD    eeee   H   H  LLLL

}
{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  Tests.Utils in 'src\Utils\Tests.Utils.pas',
  Tests.Base in 'src\Tests.Base.pas',
  Tests.TypeSupport in 'src\Tests.TypeSupport.pas',
  Tests.TypeConv in 'src\Tests.TypeConv.pas',
  Tests.FixedArray in 'src\Tests.FixedArray.pas',
  Tests.DynamicArray in 'src\Tests.DynamicArray.pas',
  Tests.ArrayAlgorithms in 'src\Tests.ArrayAlgorithms.pas',
  Tests.KeyValuePair in 'src\Tests.KeyValuePair.pas',
  Tests.TString in 'src\Tests.TString.pas',
  Tests.Bytes in 'src\Tests.Bytes.pas',
  Tests.Tuples in 'src\Tests.Tuples.pas',
  Tests.Nullable in 'src\Tests.Nullable.pas',
  Tests.Box in 'src\Tests.Box.pas',
  Tests.References in 'src\Tests.References.pas',
  Tests.Singleton in 'src\Tests.Singleton.pas',
  Tests.Converter in 'src\Tests.Converter.pas',
  Tests.WideCharSet in 'src\Tests.WideCharSet.pas',
  Tests.Date in 'src\Tests.Date.pas',
  Tests.DateTime in 'src\Tests.DateTime.pas',
  Tests.Time in 'src\Tests.Time.pas',
  Tests.BigCardinal in 'src\Tests.BigCardinal.pas',
  Tests.BigInteger in 'src\Tests.BigInteger.pas',
  Tests.BigDecimal in 'src\Tests.BigDecimal.pas',
  Tests.Half in 'src\Tests.Half.pas',
  Tests.MathTypes in 'src\Tests.MathTypes.pas',
  Tests.MathAlgorithms in 'src\Tests.MathAlgorithms.pas',
  Tests.Serialization in 'src\Tests.Serialization.pas',
  Tests.Serialization.Gross in 'src\Tests.Serialization.Gross.pas',
  Tests.Cloning in 'src\Tests.Cloning.pas',
  Tests.Enex in 'src\Tests.Enex.pas',
  Tests.Stack in 'src\Tests.Stack.pas',
  Tests.Queue in 'src\Tests.Queue.pas',
  Tests.PriorityQueue in 'src\Tests.PriorityQueue.pas',
  Tests.List in 'src\Tests.List.pas',
  Tests.Dictionary in 'src\Tests.Dictionary.pas',
  Tests.ArraySet in 'src\Tests.ArraySet.pas',
  Tests.HashSet in 'src\Tests.HashSet.pas',
  Tests.Bag in 'src\Tests.Bag.pas',
  Tests.MultiMap in 'src\Tests.MultiMap.pas',
  Tests.LinkedList in 'src\Tests.LinkedList.pas',
  Tests.LinkedStack in 'src\Tests.LinkedStack.pas',
  Tests.LinkedQueue in 'src\Tests.LinkedQueue.pas',
  Tests.SortedList in 'src\Tests.SortedList.pas',
  Tests.SortedDictionary in 'src\Tests.SortedDictionary.pas',
  Tests.SortedSet in 'src\Tests.SortedSet.pas',
  Tests.SortedBag in 'src\Tests.SortedBag.pas',
  Tests.SortedMultiMap in 'src\Tests.SortedMultiMap.pas',
  Tests.DoubleSortedMultiMap in 'src\Tests.DoubleSortedMultiMap.pas',
  Tests.DistinctMultiMap in 'src\Tests.DistinctMultiMap.pas',
  Tests.SortedDistinctMultiMap in 'src\Tests.SortedDistinctMultiMap.pas',
  Tests.DoubleSortedDistinctMultiMap in 'src\Tests.DoubleSortedDistinctMultiMap.pas',
  Tests.Interop in 'src\Tests.Interop.pas',
  Tests.VCLStringLists in 'src\Tests.VCLStringLists.pas',
  Tests.BidiMap in 'src\Tests.BidiMap.pas',
  Tests.SortedBidiMap in 'src\Tests.SortedBidiMap.pas',
  Tests.DoubleSortedBidiMap in 'src\Tests.DoubleSortedBidiMap.pas',
  Tests.Heap in 'src\Tests.Heap.pas';

{$R *.RES}
begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

