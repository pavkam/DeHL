(*
* Copyright (c) 2008-2010, Ciobanu Alexandru
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

{$I ../DeHL.Defines.inc}
unit DeHL.Arrays;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Exceptions;

type
  ///  <summary>A static class containing array manipulation methods.</summary>
  ///  <remarks><see cref="DeHL.Arrays|&amp;Array&lt;T&gt;">DeHL.Arrays.&amp;Array&lt;T&gt;</see> contains
  ///  a number of static methods that allows the caller to perform the standard array manipulations like
  ///  sorting, and traversing.</remarks>
  &Array<T> = record
{$IFDEF OPTIMIZED_SORT}
  private type
    { Stack entry }
    TStackEntry = record
      First, Last: NativeInt;
    end;

    { Required for the non-recursive QSort }
    TQuickSortStack = array[0..63] of TStackEntry;
{$ENDIF}

    { Enumerator designed for all arrays }
    TEnumerator = class(TRefCountedObject, IEnumerator<T>)
    private
      FArray: TArray<T>;
      FIndex: NativeUInt;
      FCurrent: T;

    public
      function GetCurrent(): T;
      function MoveNext(): Boolean;
    end;

  private
    class procedure QuickSort(var AArray: array of T; Left, Right: NativeInt;
      const AType: IType<T>; const Ascending: Boolean); overload; static;

{$HINTS OFF}
    class procedure QuickSort(var AArray: array of T; Left, Right: NativeInt;
      const ASortProc: TCompareOverride<T>); overload; static;
{$HINTS ON}
  public
    ///  <summary>Reverses the elements in an array.</summary>
    ///  <param name="AArray">The array which elements are to be reversed.</param>
    class procedure Reverse(var AArray: array of T); overload; static;

    ///  <summary>Reverses the elements in an array.</summary>
    ///  <param name="AArray">The array which elements are to be reversed.</param>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements.</param>
    ///  <remarks>This method reverses <paramref name="Count"/> number of elements in
    ///  the <paramref name="AArray"/>, starting with <paramref name="StartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    class procedure Reverse(var AArray: array of T; const StartIndex, Count: NativeUInt); overload; static;

    ///  <summary>Sorts the contents of an array.</summary>
    ///  <param name="AArray">The array to be sorted.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">Determines whether ascending or descending sorting is performed.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    class procedure Sort(var AArray: array of T; const AType: IType<T>;
      const Ascending: Boolean = true); overload; static;

    ///  <summary>Sorts the contents of an array.</summary>
    ///  <param name="AArray">The array to be sorted.</param>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">Determines whether ascending or descending sorting is performed.</param>
    ///  <remarks>This method sorts <paramref name="Count"/> number of elements in
    ///  the <paramref name="AArray"/>, starting with <paramref name="StartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    class procedure Sort(var AArray: array of T; const StartIndex, Count: NativeUInt;
      const AType: IType<T>; const Ascending: Boolean = true); overload; static;

    ///  <summary>Sorts the contents of an array.</summary>
    ///  <param name="AArray">The array to be sorted.</param>
    ///  <param name="ASortProc">An anonymous method used to compare elements two-by-two.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASortProc"/> is <c>nil</c>.</exception>
    class procedure Sort(var AArray: array of T; const ASortProc: TCompareOverride<T>); overload; static;

    ///  <summary>Sorts the contents of an array.</summary>
    ///  <param name="AArray">The array to be sorted.</param>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements.</param>
    ///  <param name="ASortProc">An anonymous method used to compare elements two-by-two.</param>
    ///  <remarks>This method sorts <paramref name="Count"/> number of elements in
    ///  the <paramref name="AArray"/>, starting with <paramref name="StartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASortProc"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    class procedure Sort(var AArray: array of T; const StartIndex, Count: NativeUInt;
      const ASortProc: TCompareOverride<T>); overload; static;

    ///  <summary>Obtain the index of an element in the array using binary search algorithm.</summary>
    ///  <param name="AArray">The array to be searched.</param>
    ///  <param name="Element">The searched element.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">The direction that the array is sorted; <c>True</c> for ascending
    ///  and <c>False</c> otherwise;</param>
    ///  <returns>The index of the searched element in the array if it was found. Otherwise <c>-1</c> is returned.</returns>
    ///  <remarks>This method assumes that <paramref name="AArray"/> is sorted and that <paramref name="Ascending"/> correctly
    ///  specifies the sort direction. The search will fail otherwise.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    class function BinarySearch(var AArray: array of T; const Element: T;
      const AType: IType<T>; const Ascending: Boolean = true): NativeInt; overload; static;

    ///  <summary>Obtain the index of an element in the array using binary search algorithm.</summary>
    ///  <param name="AArray">The array to be searched.</param>
    ///  <param name="Element">The searched element.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">The direction that the array is sorted; <c>True</c> for ascending
    ///  and <c>False</c> otherwise;</param>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements consider.</param>
    ///  <returns>The index of the searched element in the array if it was found. Otherwise <c>-1</c> is returned.</returns>
    ///  <remarks>This method assumes that <paramref name="AArray"/> is sorted and that <paramref name="Ascending"/> correctly
    ///  specifies the sort direction. The search will fail otherwise</remarks>
    ///  <remarks>The returned index is relative to the <paramref name="StartIndex"/> argument. For instance, if the element was found
    ///  exactly at <paramref name="StartIndex"/> location, the result will be <c>0</c>.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    class function BinarySearch(var AArray: array of T; const Element: T;
      const StartIndex, Count: NativeUInt; const AType: IType<T>;
      const Ascending: Boolean = true): NativeInt; overload; static;

    ///  <summary>Copies elements from an array to another array.</summary>
    ///  <param name="SrcArray">The array from which to copy elements.</param>
    ///  <param name="DstArray">The array to which to copy elements.</param>
    ///  <param name="SrcIndex">The index in the source array.</param>
    ///  <param name="DstIndex">The index in the destination array.</param>
    ///  <param name="Count">The number of elements to copy from source to destination.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the arrays.</param>
    ///  <remarks>This method does not perform bound checking! If the indexes are incorrect no exception is directly thrown.
    ///  <paramref name="AType"/> is used to decide whether the move is performed element by element (for compiler managed types)
    ///  or by directly moving memory.</remarks>
    class procedure SafeMove(const SrcArray: array of T; var DstArray: array of T;
      const SrcIndex, DstIndex, Count: NativeUInt; const AType: IType<T>); static;

    ///  <summary>Creates a copy of an array.</summary>
    ///  <param name="SrcArray">The array to clone.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <returns>An array that has the same size and the same elements as the original array.</returns>
    ///  <remarks>This method uses <c>SafeMove</c> to copy the elements from the source to the result array.</remarks>
    class function Clone(const SrcArray: array of T; const AType: IType<T>): TArray<T>; static;

    ///  <summary>Creates <c>Variant</c> array from a given array.</summary>
    ///  <param name="AArray">The array to be converted.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <returns>A <c>Variant</c> value that stores the array.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeIncompatibleWithVariantArray">Array elements cannot be used in a <c>Variant</c> array.</exception>
    class function ToVariantArray(const AArray: array of T; const AType: IType<T>): Variant; overload; static;

    ///  <summary>Creates <c>Variant</c> array from a given array.</summary>
    ///  <param name="AArray">The array to be converted.</param>
    ///  <returns>A <c>Variant</c> value that stores the array.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeIncompatibleWithVariantArray">Array elements cannot be used in a
    ///  <c>Variant</c> array.</exception>
    class function ToVariantArray(const AArray: array of T): Variant; overload; static;

    ///  <summary>Creates an enumerator that can be used to traverse the array.</summary>
    ///  <param name="AArray">The array for which the enumerator is to be created.</param>
    ///  <returns>A <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> interface.</returns>
    ///  <remarks>The generated enumerator does not raise any exceptions if the contents of the array are changed while enumerating.</remarks>
    class function CreateEnumerator(const AArray: TArray<T>): IEnumerator<T>; static;
  end;

  ///  <summary>An immutable dynamic array.</summary>
  ///  <remarks>The contents of the array cannot be modified. Once a fixed array is created
  ///  it can only be read.</remarks>
  TFixedArray<T> = record
  private
    FArray: TArray<T>;

    { Getter functions }
    function GetItemAt(const Index: NativeUInt): T; inline;
    function GetLength: NativeUInt; inline;

{$HINTS OFF}
    class constructor Create();
    class destructor Destroy();
{$HINTS ON}
  public
    ///  <summary>Creates a fixed array.</summary>
    ///  <param name="AArray">The array from which the fixed array copies its values.</param>
    constructor Create(const AArray: array of T); overload;

    ///  <summary>Default read-only indexed property.</summary>
    ///  <param name="Index">The index from which to read the element.</param>
    ///  <returns>The element at the specified index.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="Index"/> is out of bounds.</exception>
    property Items[const Index: NativeUInt]: T read GetItemAt; default;

    ///  <summary>Returns the number of elements in the fixed array.</summary>
    ///  <returns>The number of elements in the array.</returns>
    property Length: NativeUInt read GetLength;

    ///  <summary>Convert this fixed array to a <c>Variant</c> array.</summary>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <returns>A <c>Variant</c> array.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeIncompatibleWithVariantArray">Array elements cannot be used in a
    ///  <c>Variant</c> array.</exception>
    function ToVariantArray(const AType: IType<T>): Variant; overload;

    ///  <summary>Convert this fixed array to a <c>Variant</c> array.</summary>
    ///  <returns>A <c>Variant</c> array.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeIncompatibleWithVariantArray">Array elements cannot be used in a
    ///  <c>Variant</c> array.</exception>
    function ToVariantArray(): Variant; overload;

    ///  <summary>Returns an enumerator that can be used to traverse the array.</summary>
    ///  <returns>A <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> interface.</returns>
    function GetEnumerator(): IEnumerator<T>;

    ///  <summary>Creates a fixed array by consuming another array.</summary>
    ///  <param name="AArray">The array to consume.</param>
    ///  <returns>A new fixed array.</returns>
    ///  <remarks>Consuming means that <paramref name="AArray"/> is directly assigned to
    ///  the internal reference. The consumed array should not be modified afterward.</remarks>
    class function Consume(const AArray: TArray<T>): TFixedArray<T>; overload; static;
  end;

  ///  <summary>A dynamic array.</summary>
  ///  <remarks>This type is a thin wrapper around Delphi's dynamic array. It's main purpose is to provide
  ///  several usability improvements.</remarks>
  TDynamicArray<T> = record
  private
    FArray: TArray<T>;

    { Set/Get functions }
    function GetItemAt(const Index: NativeUInt): T; inline;
    procedure SetItemAt(const Index: NativeUInt; const Value: T); inline;

    function GetLength: NativeUInt; inline;
    procedure SetLength(const Value: NativeUInt); inline;

{$HINTS OFF}
    class constructor Create();
    class destructor Destroy();
{$HINTS ON}
  public
    ///  <summary>Creates a dynamic array.</summary>
    ///  <param name="AArray">The array from which the dynamic array copies its values.</param>
    constructor Create(const AArray: array of T); overload;

    ///  <summary>Creates a dynamic array.</summary>
    ///  <param name="AArray">The fixed array from which the dynamic array copies its values.</param>
    constructor Create(const AArray: TFixedArray<T>); overload;

    ///  <summary>Creates a dynamic array.</summary>
    ///  <param name="InitialLength">The length of the array new array.</param>
    ///  <remarks>The contents of the new array are undefined.</remarks>
    constructor Create(const InitialLength: NativeUInt); overload;

    ///  <summary>Extends this array.</summary>
    ///  <param name="Count">The number of elements to add to the array.</param>
    ///  <remarks>The new elements are added to the end of the array and their contents are undefined.</remarks>
    procedure Extend(const Count: NativeUInt);

    ///  <summary>Shrinks this array.</summary>
    ///  <param name="Count">The number of elements to remove from the array.</param>
    ///  <remarks>The elements are removed from the end of the array.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="Count"/> is bigger than the length of the array.</exception>
    procedure Shrink(const Count: NativeUInt);

    ///  <summary>Extends this array with a new element.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new element.</param>
    ///  <param name="Element">The element to be added.</param>
    ///  <remarks>This method extends the array by one and then inserts the given element into the specified position. If <paramref name="AtIndex"/>
    ///  is equal to the length of the array, the value is appended.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure ExtendAndInsert(const AtIndex: NativeUInt; const Element: T); overload;

    ///  <summary>Extends this array with a new elements.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new elements.</param>
    ///  <param name="Elements">An array of elements to be added.</param>
    ///  <remarks>This method extends the array by the length of the given array and then
    ///  inserts the array into the specified position. If <paramref name="AtIndex"/>
    ///  is equal to the length of the array, the values are appended.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure ExtendAndInsert(const AtIndex: NativeUInt; const Elements: array of T); overload;

    ///  <summary>Extends this array with a new elements.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new elements.</param>
    ///  <param name="Elements">A fixed array to be added.</param>
    ///  <remarks>This method extends the array by the length of the given array and then
    ///  inserts the array into the specified position. If <paramref name="AtIndex"/>
    ///  is equal to the length of the array, the values are appended.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure ExtendAndInsert(const AtIndex: NativeUInt; const Elements: TFixedArray<T>); overload;

    ///  <summary>Extends this array with a new elements.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new elements.</param>
    ///  <param name="Elements">A dynamic array to be added.</param>
    ///  <remarks>This method extends the array by the length of the given array and then
    ///  inserts the array into the specified position. If <paramref name="AtIndex"/>
    ///  is equal to the length of the array, the values are appended.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure ExtendAndInsert(const AtIndex: NativeUInt; const Elements: TDynamicArray<T>); overload;

    ///  <summary>Shrinks this array by removing an element from a given position.</summary>
    ///  <param name="FromIndex">The index from which to remove the element.</param>
    ///  <returns>The element that was removed.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="FromIndex"/> is out of bounds.</exception>
    function RemoveAndShrink(const FromIndex: NativeUInt): T;

    ///  <summary>Inserts an element into a specified position.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new element.</param>
    ///  <param name="Element">The element to be added.</param>
    ///  <remarks>This method does not extend the array. It merely pushes the elements by one to the right and inserts the given
    ///  element. The last element in the array is lost.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure Insert(const AtIndex: NativeUInt; const Element: T); overload;

    ///  <summary>Inserts a number of elements into a specified position.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new element.</param>
    ///  <param name="Elements">The array of elements to be added.</param>
    ///  <remarks>This method does not extend the array. It merely pushes the elements to the right and inserts the given
    ///  array. The last elements in the array are lost.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure Insert(const AtIndex: NativeUInt; const Elements: array of T); overload;

    ///  <summary>Inserts a number of elements into a specified position.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new element.</param>
    ///  <param name="Elements">The array of elements to be added.</param>
    ///  <remarks>This method does not extend the array. It merely pushes the elements to the right and inserts the given
    ///  array. The last elements in the array are lost.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure Insert(const AtIndex: NativeUInt; const Elements: TFixedArray<T>); overload;

    ///  <summary>Inserts a number of elements into a specified position.</summary>
    ///  <param name="AtIndex">The index in the array where to add the new element.</param>
    ///  <param name="Elements">The array of elements to be added.</param>
    ///  <remarks>This method does not extend the array. It merely pushes the elements to the right and inserts the given
    ///  array. The last elements in the array are lost.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AtIndex"/> is out of bounds.</exception>
    procedure Insert(const AtIndex: NativeUInt; const Elements: TDynamicArray<T>); overload;

    ///  <summary>Removes an element from a given position.</summary>
    ///  <param name="FromIndex">The index from which to remove the element.</param>
    ///  <returns>The element that was removed.</returns>
    ///  <remarks>The length of the array is not decreased. This method only removes the element and the moves the content of the array
    ///  left by one. The last element in the array contains an undefined value after this operation.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="FromIndex"/> is out of bounds.</exception>
    function Remove(const FromIndex: NativeUInt): T;

    ///  <summary>Appends an element to the array.</summary>
    ///  <param name="Element">The appended element.</param>
    ///  <remarks>This method extends the array by one and then inserts the given element into the back of the array.</remarks>
    procedure Append(const Element: T); overload;

    ///  <summary>Appends elements to the array.</summary>
    ///  <param name="Elements">The appended elements.</param>
    ///  <remarks>This method extends the array by the length of the supplied array and then inserts the
    ///  that array into the back of this array.</remarks>
    procedure Append(const Elements: array of T); overload;

    ///  <summary>Appends elements to the array.</summary>
    ///  <param name="Elements">The appended elements.</param>
    ///  <remarks>This method extends the array by the length of the supplied array and then inserts the
    ///  that array into the back of this array.</remarks>
    procedure Append(const Elements: TFixedArray<T>); overload;

    ///  <summary>Appends elements to the array.</summary>
    ///  <param name="Elements">The appended elements.</param>
    ///  <remarks>This method extends the array by the length of the supplied array and then inserts the
    ///  that array into the back of this array.</remarks>
    procedure Append(const Elements: TDynamicArray<T>); overload;

    ///  <summary>Fills the array with a given element.</summary>
    ///  <param name="Element">The element to fill array with.</param>
    ///  <remarks>This method sets each element to the value of <paramref name="Element"/>.</remarks>
    procedure Fill(const Element: T); overload;

    ///  <summary>Fills a segment of the array with a given element.</summary>
    ///  <param name="Element">The element to fill array with.</param>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements.</param>
    ///  <remarks>This method sets <paramref name="Count"/> elements, starting with <paramref name="StartIndex"/>
    ///  to the value of <paramref name="Element"/>.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    procedure Fill(const StartIndex, Count: NativeUInt; const Element: T); overload;

    ///  <summary>Clears the array and sets it length to zero.</summary>
    procedure Dispose(); overload;

    ///  <summary>Reverses the elements in the array.</summary>
    procedure Reverse(); overload;

    ///  <summary>Reverses the elements in the array.</summary>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements.</param>
    ///  <remarks>This method reverses <paramref name="Count"/> number of elements in
    ///  the array, starting with <paramref name="StartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    procedure Reverse(const StartIndex, Count: NativeUInt); overload;

    ///  <summary>Sorts the contents of the array.</summary>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">Determines whether ascending or descending sorting is performed.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    procedure Sort(const AType: IType<T>; const Ascending: Boolean = true); overload;

    ///  <summary>Sorts the contents of the array.</summary>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">Determines whether ascending or descending sorting is performed.</param>
    ///  <remarks>This method sorts <paramref name="Count"/> number of elements in
    ///  the array, starting with <paramref name="StartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    procedure Sort(const StartIndex, Count: NativeUInt; const AType: IType<T>; const Ascending: Boolean = true); overload;

    ///  <summary>Obtain the index of an element in the array using binary search algorithm.</summary>
    ///  <param name="Element">The searched element.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">The direction that the array is sorted; <c>True</c> for ascending
    ///  and <c>False</c> otherwise;</param>
    ///  <returns>The index of the searched element in the array if it was found. Otherwise <c>-1</c> is returned.</returns>
    ///  <remarks>This method assumes that the array is sorted and that <paramref name="Ascending"/> correctly
    ///  specifies the sort direction. The search will fail otherwise.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    function BinarySearch(const Element: T; const AType: IType<T>; const Ascending: Boolean = true): NativeInt; overload;

    ///  <summary>Obtain the index of an element in the array using binary search algorithm.</summary>
    ///  <param name="Element">The searched element.</param>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <param name="Ascending">The direction that the array is sorted; <c>True</c> for ascending
    ///  and <c>False</c> otherwise;</param>
    ///  <param name="StartIndex">The start index.</param>
    ///  <param name="Count">The count of elements consider.</param>
    ///  <returns>The index of the searched element in the array if it was found. Otherwise <c>-1</c> is returned.</returns>
    ///  <remarks>This method assumes that the array is sorted and that <paramref name="Ascending"/> correctly
    ///  specifies the sort direction. The search will fail otherwise.</remarks>
    ///  <remarks>The returned index is relative to the <paramref name="StartIndex"/> argument. For instance, if the element was found
    ///  exactly at <paramref name="StartIndex"/> location, the result will be <c>0</c>.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    function BinarySearch(const Element: T; const StartIndex, Count: NativeUInt; const AType: IType<T>;
      const Ascending: Boolean = true): NativeInt; overload;

    ///  <summary>Default indexed property.</summary>
    ///  <param name="Index">The index from which to read or write the element.</param>
    ///  <returns>The element at the specified index.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="Index"/> is out of bounds.</exception>
    property Items[const Index: NativeUInt]: T read GetItemAt write SetItemAt; default;

    ///  <summary>Returns the number of elements in the array.</summary>
    ///  <returns>The number of elements in the array.</returns>
    property Length: NativeUInt read GetLength write SetLength;

    ///  <summary>Convert this array to a <c>Variant</c> array.</summary>
    ///  <param name="AType">The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> describing
    ///  the elements of the array.</param>
    ///  <returns>A <c>Variant</c> array.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeIncompatibleWithVariantArray">Array elements cannot be used in a
    ///  <c>Variant</c> array.</exception>
    function ToVariantArray(const AType: IType<T>): Variant; overload;

    ///  <summary>Convert this array to a <c>Variant</c> array.</summary>
    ///  <returns>A <c>Variant</c> array.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeIncompatibleWithVariantArray">Array elements cannot be used in a
    ///  <c>Variant</c> array.</exception>
    function ToVariantArray(): Variant; overload;

    ///  <summary>Returns an enumerator that can be used to traverse the array.</summary>
    ///  <returns>A <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> interface.</returns>
    ///  <remarks>The generated enumerator does not raise any exceptions if the contents of the array are changed while enumerating.</remarks>
    function GetEnumerator(): IEnumerator<T>;

    ///  <summary>Creates a dynamic array by consuming another array.</summary>
    ///  <param name="AArray">The array to consume.</param>
    ///  <returns>A new dynamic array.</returns>
    ///  <remarks>Consuming means that <paramref name="AArray"/> is directly assigned to
    ///  the internal reference. The consumed array should not be modified afterward.</remarks>
    class function Consume(const AArray: TArray<T>): TDynamicArray<T>; overload; static;

    ///  <summary>Returns an immutable array.</summary>
    ///  <returns>A new fixed array containing the elements of this array.</returns>
    ///  <remarks>The elements of the new array are copied from this array and not consumed. This means that
    ///  this array can be manipulated safely after this method call.</remarks>
    function ToFixedArray(): TFixedArray<T>;
  end;

  ///  <summary> Type class used to describe <see cref="DeHL.Arrays|TFixedArrayType&lt;T&gt;">DeHL.Arrays.TFixedArrayType&lt;T&gt;</see>
  ///  values.</summary>
  TFixedArrayType<T> = class sealed(TMagicType<TFixedArray<T>>)
  private
    FType: IType<TArray<T>>;

  protected
    ///  <summary>Serializes a fixed array.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing
    ///  the field/element being serialized.</param>
    ///  <param name="AValue">The fixed array being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <remarks>This method uses the type object describing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <exception><exception cref="DeHL.Exceptions|ESerializationException"/>Various serialization reasons.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TFixedArray<T>; const AContext: ISerializationContext); override;

    ///  <summary>Deserializes a fixed array.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing
    ///  the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized array.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <remarks>This method uses the type object describing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <exception><exception cref="DeHL.Exceptions|ESerializationException"/>Various deserialization reasons.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TFixedArray<T>; const AContext: IDeserializationContext); override;

  public
    ///  <summary>Compares two fixed arrays.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - AValue1 is less than AValue2. If the result is zero -
    ///  AValue1 is equal to AValue2. And finally, if the result is greater than zero - AValue1 is greater than AValue2.</returns>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    function Compare(const AValue1, AValue2: TFixedArray<T>): NativeInt; override;

    ///  <summary>Generates a hash code for a fixed array.</summary>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: TFixedArray<T>): NativeInt; override;

    ///  <summary>Returns the string representation of the fixed array.</summary>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>A string value describing the value.</returns>
    function GetString(const AValue: TFixedArray<T>): String; override;

    ///  <summary>Returns the family of fixed arrays</summary>
    ///  <returns>Always <c>tfArray</c>.</returns>
    function Family(): TTypeFamily; override;

    ///  <summary>Tries to convert the array to a <c>Variant</c> array.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <param name="ORes">The <c>Variant</c> array.</param>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <returns><c>True</c> if the conversion succeded; <c>False</c> otherwise.</returns>
    function TryConvertToVariant(const AValue: TFixedArray<T>; out ORes: Variant): Boolean; override;

    ///  <summary>Tries to convert a <c>Variant</c> array to a fixed array.</summary>
    ///  <param name="AValue">The <c>Variant</c> array to convert.</param>
    ///  <param name="ORes">The fixed array.</param>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <returns><c>True</c> if the conversion succeded; <c>False</c> otherwise.</returns>
    function TryConvertFromVariant(const AValue: Variant; out ORes: TFixedArray<T>): Boolean; override;

    ///  <summary>Instantiates a <see cref="DeHL.Arrays|TFixedArrayType&lt;T&gt;">DeHL.Arrays.TFixedArrayType&lt;T&gt;</see>
    ///  object.</summary>
    constructor Create(); overload; override;

    ///  <summary>Instantiates a <see cref="DeHL.Arrays|TFixedArrayType&lt;T&gt;">DeHL.Arrays.TFixedArrayType&lt;T&gt;</see>
    ///  object.</summary>
    ///  <param name="AArrayType">An instance of a type class describing a Delphi dynamic array for the same generic type.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AArrayType"/> is <c>nil</c>.</exception>
    constructor Create(const AArrayType: IType<TArray<T>>); reintroduce; overload;
  end;

  ///  <summary> Type class used to describe <see cref="DeHL.Arrays|TDynamicArrayType&lt;T&gt;">DeHL.Arrays.TDynamicArrayType&lt;T&gt;</see>
  ///  values.</summary>
  TDynamicArrayType<T> = class sealed(TMagicType<TDynamicArray<T>>)
  private
    FType: IType<TArray<T>>;

  protected
    ///  <summary>Serializes a dynamic array.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing
    ///  the field/element being serialized.</param>
    ///  <param name="AValue">The array being serialized.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|ISerializationContext">DeHL.Serialization.ISerializationContext</see>
    ///  to which the value is serialized.</param>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <exception><exception cref="DeHL.Exceptions|ESerializationException"/>Various serialization reasons.</exception>
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TDynamicArray<T>; const AContext: ISerializationContext); override;

    ///  <summary>Deserializes a dynamic array.</summary>
    ///  <param name="AInfo">A <see cref="DeHL.Serialization|TValueInfo">DeHL.Serialization.TValueInfo</see> describing
    ///  the field/element being deserialized.</param>
    ///  <param name="AValue">The deserialized array.</param>
    ///  <param name="AContext">A <see cref="DeHL.Serialization|IDeserializationContext">DeHL.Serialization.IDeserializationContext</see>
    ///  from which the value is deserialized.</param>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <exception><exception cref="DeHL.Exceptions|ESerializationException"/>Various deserialization reasons.</exception>
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TDynamicArray<T>; const AContext: IDeserializationContext); override;
  public
    ///  <summary>Compares two dynamic arrays.</summary>
    ///  <param name="AValue1">The value that is being compared.</param>
    ///  <param name="AValue1">The value that is being compared to.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - AValue1 is less than AValue2. If the result is zero -
    ///  AValue1 is equal to AValue2. And finally, if the result is greater than zero - AValue1 is greater than AValue2.</returns>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    function Compare(const AValue1, AValue2: TDynamicArray<T>): NativeInt; override;

    ///  <summary>Generates a hash code for a dynamic array.</summary>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <param name="AValue">The value to generate hash code for.</param>
    ///  <returns>An integer value containing the hash code.</returns>
    function GenerateHashCode(const AValue: TDynamicArray<T>): NativeInt; override;

    ///  <summary>Returns the string representation of the dynamic array.</summary>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <param name="AValue">The value to generate a string for.</param>
    ///  <returns>A string value describing the value.</returns>
    function GetString(const AValue: TDynamicArray<T>): String; override;

    ///  <summary>Returns the family of dynamic arrays</summary>
    ///  <returns>Always <c>tfArray</c>.</returns>
    function Family(): TTypeFamily; override;

    ///  <summary>Tries to convert a dynamic to a <c>Variant</c> array.</summary>
    ///  <param name="AValue">The value to convert.</param>
    ///  <param name="ORes">The <c>Variant</c> array.</param>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <returns><c>True</c> if the conversion succeded; <c>False</c> otherwise.</returns>
    function TryConvertToVariant(const AValue: TDynamicArray<T>; out ORes: Variant): Boolean; override;

    ///  <summary>Tries to convert a <c>Variant</c> array to a dynamic array.</summary>
    ///  <param name="AValue">The <c>Variant</c> array to convert.</param>
    ///  <param name="ORes">The array.</param>
    ///  <remarks>This method uses the type object decribing the wrapped Delphi array. All calls are routed
    ///  to that type object.</remarks>
    ///  <returns><c>True</c> if the conversion succeded; <c>False</c> otherwise.</returns>
    function TryConvertFromVariant(const AValue: Variant; out ORes: TDynamicArray<T>): Boolean; override;

    ///  <summary>Instantiates a <see cref="DeHL.Arrays|TDynamicArrayType&lt;T&gt;">DeHL.Arrays.TDynamicArrayType&lt;T&gt;</see>
    ///  object.</summary>
    constructor Create(); overload; override;

    ///  <summary>Instantiates a <see cref="DeHL.Arrays|TDynamicArrayType&lt;T&gt;">DeHL.Arrays.TDynamicArrayType&lt;T&gt;</see>
    ///  object.</summary>
    ///  <param name="AArrayType">An instance of a type class describing a Delphi dynamic array for the same generic type.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AArrayType"/> is <c>nil</c>.</exception>
    constructor Create(const AArrayType: IType<TArray<T>>); reintroduce; overload;
  end;

implementation
uses Variants;

{ Disable overflow and range checks }
{$Q-}
{$R-}

{ TFixedArray<T> }

class constructor TFixedArray<T>.Create();
begin
  { Register custom type }
  if not TType<TFixedArray<T>>.IsRegistered then
    TType<TFixedArray<T>>.Register(TFixedArrayType<T>);
end;

class destructor TFixedArray<T>.Destroy();
begin
  { Unregister the custom type }
  if not TType<TFixedArray<T>>.IsRegistered then
    TType<TFixedArray<T>>.Unregister();
end;

function TFixedArray<T>.GetItemAt(const Index: NativeUInt): T;
begin
  if Index >= NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');

  Result := FArray[Index];
end;

function TFixedArray<T>.GetLength: NativeUInt;
begin
  Result := NativeUInt(System.Length(FArray));
end;

class function TFixedArray<T>.Consume(const AArray: TArray<T>): TFixedArray<T>;
begin
  { Consume the array directly }
  Result.FArray := AArray;
end;

constructor TFixedArray<T>.Create(const AArray: array of T);
var
  I: NativeInt;
begin
  { Copy all internals }
  SetLength(FArray, System.Length(AArray));

  for I := 0 to System.Length(AArray) - 1 do
  begin
    FArray[I] := AArray[I];
  end;
end;

function TFixedArray<T>.ToVariantArray(const AType: IType<T>): Variant;
begin
  { Call helper }
  Result := &Array<T>.ToVariantArray(FArray, AType);
end;

function TFixedArray<T>.ToVariantArray(): Variant;
begin
  { Call helper }
  Result := &Array<T>.ToVariantArray(FArray);
end;

function TFixedArray<T>.GetEnumerator(): IEnumerator<T>;
begin
  Result := &Array<T>.CreateEnumerator(FArray);
end;

{ TDynamicArray<T> }

procedure TDynamicArray<T>.Append(const Element: T);
var
  PrevLen: NativeInt;
begin
  { +1 length and add last element }
  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + 1);
  FArray[PrevLen] := Element;
end;

procedure TDynamicArray<T>.Append(const Elements: array of T);
var
  PrevLen, I: NativeInt;
begin
  { +N length and add last element }
  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + System.Length(Elements));

  { Copy the elements in }
  for I := 0 to System.Length(Elements) - 1 do
    FArray[PrevLen + I] := Elements[I];
end;

procedure TDynamicArray<T>.Append(const Elements: TFixedArray<T>);
var
  PrevLen, I: NativeInt;
begin
  { +N length and add last element }
  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + System.Length(Elements.FArray));

  { Copy the elements in }
  for I := 0 to System.Length(Elements.FArray) - 1 do
    FArray[PrevLen + I] := Elements.FArray[I];
end;

procedure TDynamicArray<T>.Append(const Elements: TDynamicArray<T>);
var
  PrevLen, I: NativeInt;
begin
  { +N length and add last element }
  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + System.Length(Elements.FArray));

  { Copy the elements in }
  for I := 0 to System.Length(Elements.FArray) - 1 do
    FArray[PrevLen + I] := Elements.FArray[I];
end;

function TDynamicArray<T>.BinarySearch(const Element: T;
  const AType: IType<T>; const Ascending: Boolean): NativeInt;
begin
  { call the more generic function }
  Result := &Array<T>.BinarySearch(FArray, Element, AType, Ascending);
end;

function TDynamicArray<T>.BinarySearch(const Element: T; const StartIndex,
  Count: NativeUInt; const AType: IType<T>; const Ascending: Boolean): NativeInt;
begin
  Result := &Array<T>.BinarySearch(FArray, Element, StartIndex, Count, AType, Ascending);
end;

class constructor TDynamicArray<T>.Create();
begin
  { Register custom type }
  if not TType<TDynamicArray<T>>.IsRegistered then
    TType<TDynamicArray<T>>.Register(TDynamicArrayType<T>);
end;

class destructor TDynamicArray<T>.Destroy();
begin
  { Unregister the custom type }
  if not TType<TDynamicArray<T>>.IsRegistered then
    TType<TDynamicArray<T>>.Unregister();
end;

constructor TDynamicArray<T>.Create(const InitialLength: NativeUInt);
begin
  { Set length }
  System.SetLength(FArray, InitialLength);
end;

class function TDynamicArray<T>.Consume(const AArray: TArray<T>): TDynamicArray<T>;
begin
  { Consume the array directly }
  Result.FArray := AArray;
end;

procedure TDynamicArray<T>.Dispose;
begin
  { Simply reset the new length }
  System.SetLength(FArray, 0);
end;

procedure TDynamicArray<T>.Extend(const Count: NativeUInt);
var
  PrevLen: NativeUInt;
begin
  { +1 length and add last element }
  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + Count);
end;

procedure TDynamicArray<T>.ExtendAndInsert(const AtIndex: NativeUInt; const Element: T);
var
  PrevLen, I: NativeUInt;
begin
  if AtIndex > NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  { +1 length  }
  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + 1);

  { Move to the right }
  for I := PrevLen downto AtIndex do
      FArray[I] := FArray[I - 1];

  { Insert }
  FArray[AtIndex] := Element;
end;

procedure TDynamicArray<T>.ExtendAndInsert(const AtIndex: NativeUInt; const Elements: array of T);
var
  PrevLen, I, L: NativeUInt;
begin
  if AtIndex > NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  { +N length }
  L := System.Length(Elements);

  { Do nothing on 0 }
  if L = 0 then
    Exit;

  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + L);

  { Move to the right }
  if PrevLen <> 0 then
    for I := PrevLen - 1 downto AtIndex do
      FArray[I + L] := FArray[I];

  { Insert list }
  for I := 0 to L - 1 do
    FArray[AtIndex + I] := Elements[I];
end;

procedure TDynamicArray<T>.ExtendAndInsert(const AtIndex: NativeUInt; const Elements: TFixedArray<T>);
var
  PrevLen, I, L: NativeUInt;
begin
  if AtIndex > NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  { +N length }
  L := System.Length(Elements.FArray);

  { Do nothing on 0 }
  if L = 0 then
    Exit;

  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + L);

  { Move to the right }
  if PrevLen <> 0 then
    for I := PrevLen - 1 downto AtIndex do
      FArray[I + L] := FArray[I];

  { Insert list }
  for I := 0 to L - 1 do
    FArray[AtIndex + I] := Elements.FArray[I];
end;

procedure TDynamicArray<T>.ExtendAndInsert(const AtIndex: NativeUInt; const Elements: TDynamicArray<T>);
var
  PrevLen, I, L: NativeUInt;
begin
  if AtIndex > NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  { +N length }
  L := System.Length(Elements.FArray);

  { Do nothing on 0 }
  if L = 0 then
    Exit;

  PrevLen := System.Length(FArray);
  System.SetLength(FArray, PrevLen + L);

  { Move to the right }
  if PrevLen <> 0 then
    for I := PrevLen - 1 downto AtIndex do
      FArray[I + L] := FArray[I];

  { Insert list }
  for I := 0 to L - 1 do
    FArray[AtIndex + I] := Elements.FArray[I];
end;

procedure TDynamicArray<T>.Fill(const Element: T);
begin
  { Call more generic function }
  Fill(0, System.Length(FArray), Element);
end;

procedure TDynamicArray<T>.Fill(const StartIndex, Count: NativeUInt;
  const Element: T);
var
  I: NativeUInt;
begin
  if (StartIndex + Count) > NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex/Count');

  { Simple fill }
  for I := StartIndex to (StartIndex + Count) - 1 do
      FArray[I] := Element;
end;

function TDynamicArray<T>.GetItemAt(const Index: NativeUInt): T;
begin
  if Index >= NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');

  Result := FArray[Index];
end;

function TDynamicArray<T>.GetLength: NativeUInt;
begin
  Result := NativeUInt(System.Length(FArray));
end;

procedure TDynamicArray<T>.Insert(const AtIndex: NativeUInt; const Element: T);
var
  I: NativeUInt;
begin
  if AtIndex >= NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  { Move to the right }
  for I := NativeUInt(System.Length(FArray)) - 1 downto AtIndex do
      FArray[I] := FArray[I - 1];

  { Insert }
  FArray[AtIndex] := Element;
end;

procedure TDynamicArray<T>.Insert(const AtIndex: NativeUInt; const Elements: array of T);
var
  I, L, Len: NativeUInt;
begin
  Len := NativeUInt(System.Length(FArray));

  if AtIndex >= Len then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  L := NativeUInt(System.Length(Elements));

  if L = 0 then
    Exit;

  { Move to the right }
  if L < (Len - AtIndex) then
    for I := Len - 1 downto AtIndex do
      FArray[I] := FArray[I - L];

  { Insert elements }
  for I := 0 to L - 1 do
  begin
    { Do not continue past array boundaries }
    if I + AtIndex >= Len then
      break;

    FArray[AtIndex + I] := Elements[I];
  end;
end;

procedure TDynamicArray<T>.Insert(const AtIndex: NativeUInt; const Elements: TFixedArray<T>);
var
  I, L, Len: NativeUInt;
begin
  Len := NativeUInt(System.Length(FArray));

  if AtIndex >= Len then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  L := NativeUInt(System.Length(Elements.FArray));

  if L = 0 then
    Exit;

  { Move to the right }
  if L < (Len - AtIndex) then
    for I := Len - 1 downto AtIndex do
      FArray[I] := FArray[I - L];

  { Insert elements }
  for I := 0 to L - 1 do
  begin
    { Do not continue past array boundaries }
    if I + AtIndex >= Len then
      break;

    FArray[AtIndex + I] := Elements.FArray[I];
  end;
end;

procedure TDynamicArray<T>.Insert(const AtIndex: NativeUInt; const Elements: TDynamicArray<T>);
var
  I, L, Len: NativeUInt;
begin
  Len := NativeUInt(System.Length(FArray));

  if AtIndex >= Len then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AtIndex');

  L := NativeUInt(System.Length(Elements.FArray));

  if L = 0 then
    Exit;

  { Move to the right }
  if L < (Len - AtIndex) then
    for I := Len - 1 downto AtIndex do
      FArray[I] := FArray[I - L];

  { Insert elements }
  for I := 0 to L - 1 do
  begin
    { Do not continue past array boundaries }
    if I + AtIndex >= Len then
      break;

    FArray[AtIndex + I] := Elements.FArray[I];
  end;
end;

function TDynamicArray<T>.Remove(const FromIndex: NativeUInt): T;
var
  I  : NativeUInt;
  Len: NativeUInt;
begin
  Len := System.Length(FArray);

  if FromIndex >= Len then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('FromIndex');

  Result := FArray[FromIndex];

  if Len >= 2 then
    for I := FromIndex to Len - 2 do
      FArray[I] := FArray[I + 1];
end;

function TDynamicArray<T>.RemoveAndShrink(const FromIndex: NativeUInt): T;
var
  I  : NativeUInt;
  Len: NativeUInt;
begin
  Len := System.Length(FArray);

  if FromIndex >= Len then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('FromIndex');

  Result := FArray[FromIndex];

  if Len >= 2 then
    for I := FromIndex to Len - 2 do
      FArray[I] := FArray[I + 1];

  System.SetLength(FArray, Len - 1);
end;

procedure TDynamicArray<T>.Reverse;
begin
  &Array<T>.Reverse(FArray);
end;

procedure TDynamicArray<T>.Reverse(const StartIndex, Count: NativeUInt);
begin
  &Array<T>.Reverse(FArray, StartIndex, Count);
end;

procedure TDynamicArray<T>.SetItemAt(const Index: NativeUInt; const Value: T);
begin
  if Index >= NativeUInt(System.Length(FArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');

  FArray[Index] := Value;
end;

procedure TDynamicArray<T>.SetLength(const Value: NativeUInt);
begin
  { Simply call the system }
  System.SetLength(FArray, Value);
end;

procedure TDynamicArray<T>.Shrink(const Count: NativeUInt);
var
  PrevLen: NativeUInt;
begin
  { -1 length and add last element }
  PrevLen := System.Length(FArray);

  if Count > PrevLen then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('Count');

  System.SetLength(FArray, PrevLen - Count);
end;

procedure TDynamicArray<T>.Sort(const AType: IType<T>; const Ascending: Boolean);
begin
  { Call the more generic variant }
  &Array<T>.Sort(FArray, AType, Ascending);
end;

procedure TDynamicArray<T>.Sort(const StartIndex, Count: NativeUInt;
  const AType: IType<T>; const Ascending: Boolean);
begin
  &Array<T>.Sort(FArray, StartIndex, Count, AType, Ascending);
end;

function TDynamicArray<T>.ToFixedArray: TFixedArray<T>;
begin
  { Make a copy }
  Result := TFixedArray<T>.Create(FArray);
end;

function TDynamicArray<T>.ToVariantArray(const AType: IType<T>): Variant;
begin
  { Call helper }
  Result := &Array<T>.ToVariantArray(FArray, AType);
end;

function TDynamicArray<T>.ToVariantArray(): Variant;
begin
  { Call helper }
  Result := &Array<T>.ToVariantArray(FArray);
end;

constructor TDynamicArray<T>.Create(const AArray: TFixedArray<T>);
var
  I: NativeInt;
begin
  { Copy all internals }
  Length := AArray.Length;

  for I := 0 to Length - 1 do
    FArray[I] := AArray[I];
end;

constructor TDynamicArray<T>.Create(const AArray: array of T);
var
  I: NativeInt;
begin
  { Copy all internals }
  Length := System.Length(AArray);

  for I := 0 to Length - 1 do
    FArray[I] := AArray[I];
end;

function TDynamicArray<T>.GetEnumerator(): IEnumerator<T>;
begin
  Result := &Array<T>.CreateEnumerator(FArray);
end;


{ &Array<T> }

class function &Array<T>.BinarySearch(var AArray: array of T;
  const Element: T; const StartIndex, Count: NativeUInt;
  const AType: IType<T>; const Ascending: Boolean): NativeInt;
var
  Left, Right, Middle: NativeInt;
  CompareResult      : NativeInt;
begin
  if (StartIndex + Count) > NativeUInt(System.Length(AArray)) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex/Count');

  if AType = nil then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  { Do not search for 0 count }
  if Count = 0 then
  begin
    Result := -1;
    Exit;
  end;

  { Check for valid type support }
  Left := StartIndex;
  Right := NativeUInt(Left) + Count - 1;

  while (Left <= Right) do
  begin
    Middle := (Left + Right) div 2;
    CompareResult := AType.Compare(AArray[Middle], Element);

    if not Ascending then
       CompareResult := CompareResult * -1;

    if CompareResult > 0 then
      Right := Middle - 1
    else if CompareResult < 0 then
       Left := Middle + 1
    else
       begin Result := NativeUInt(Middle) - StartIndex; Exit; end;
  end;

  Result := -1;
end;

{$IFNDEF OPTIMIZED_SORT}
class procedure &Array<T>.QuickSort(var AArray: array of T;
  Left, Right: NativeInt; const ASortProc: TCompareOverride<T>);
var
  I, J: NativeInt;
  Pivot, Temp: T;
begin
  ASSERT(Assigned(ASortProc));
  ASSERT(Left <= Right);

  repeat
    I := Left;
    J := Right;

    Pivot := AArray[(Left + Right) div 2];

    repeat
      while ASortProc(AArray[I], Pivot) < 0 do
        Inc(I);

      while ASortProc(AArray[J], Pivot) > 0 do
        Dec(J);

      if I <= J then
      begin

        if I <> J then
        begin
          Temp := AArray[I];
          AArray[I] := AArray[J];
          AArray[J] := Temp;
        end;

        Inc(I);
        Dec(J);
      end;

    until I > J;

    if Left < J then
      QuickSort(AArray, Left, J, ASortProc);

    Left := I;

  until I >= Right;
end;
{$ELSE}
class procedure &Array<T>.QuickSort(var AArray: array of T;
  Left, Right: NativeInt; const ASortProc: TCompareOverride<T>);
var
  SubArray, SubLeft, SubRight: NativeInt;
  Pivot, Temp: T;
  Stack: TQuickSortStack;
begin
  ASSERT(Assigned(ASortProc));
  ASSERT(Left <= Right);

  SubArray := 0;

  Stack[SubArray].First := Left;
  Stack[SubArray].Last := Right;

  repeat
    Left  := Stack[SubArray].First;
    Right := Stack[SubArray].Last;
    Dec(SubArray);
    repeat
      SubLeft := Left;
      SubRight := Right;
      Pivot:= AArray[(Left + Right) shr 1];

      repeat
        while ASortProc(AArray[SubLeft], Pivot) < 0 do
          Inc(SubLeft);

        while ASortProc(AArray[SubRight], Pivot) > 0 do
          Dec(SubRight);

        if SubLeft <= SubRight then
        begin
          Temp := AArray[SubLeft];
          AArray[SubLeft] := AArray[SubRight];
          AArray[SubRight] := Temp;
          Inc(SubLeft);
          Dec(SubRight);
        end;
      until SubLeft > SubRight;

      if SubLeft < Right then
      begin
        Inc(SubArray);
        Stack[SubArray].First := SubLeft;
        Stack[SubArray].Last  := Right;
      end;

      Right := SubRight;
    until Left >= Right;
  until SubArray < 0;
end;
{$ENDIF}

class procedure &Array<T>.QuickSort(var AArray: array of T; Left, Right: NativeInt;
  const AType: IType<T>; const Ascending: Boolean);
begin
  if Ascending then               { Ascending sort }
    QuickSort(AArray, Left, Right,
      function(const ALeft, ARight: T): NativeInt
      begin
        Exit(AType.Compare(ALeft, ARight));
      end
    ) else                        { Descending sort }
    QuickSort(AArray, Left, Right,
      function(const ALeft, ARight: T): NativeInt
      begin
        Exit( - AType.Compare(ALeft, ARight));
      end
    )
end;

class function &Array<T>.BinarySearch(var AArray: array of T;
  const Element: T; const AType: IType<T>;
  const Ascending: Boolean): NativeInt;
begin
  { call the more generic function }
  Result := BinarySearch(AArray, Element, 0, Length(AArray), AType, Ascending);
end;

class procedure &Array<T>.Reverse(var AArray: array of T;
  const StartIndex, Count: NativeUInt);
var
  I : NativeUInt;
  V : T;
begin
  { Check for indexes }
  if ((StartIndex + Count) > NativeUInt(Length(AArray))) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex/Count');

  if Count < 2 then
     Exit;

  { Reverse the array }
  for I := 0 to (Count div 2) - 1 do
  begin
    V := AArray[StartIndex + I];
    AArray[StartIndex + I] := AArray[StartIndex + Count - I - 1];
    AArray[StartIndex + Count - I - 1] := V;
  end;
end;

class procedure &Array<T>.Reverse(var AArray: array of T);
begin
  { Call the more generic function }
  Reverse(AArray, 0, Length(AArray));
end;

class function &Array<T>.Clone(const SrcArray: array of T; const AType: IType<T>): TArray<T>;
var
  L: NativeUInt;
begin
  L := Length(SrcArray);
  if L > 0 then
  begin
    SetLength(Result, L);

    { Do a safe move }
    SafeMove(SrcArray, Result, 0, 0, L, AType);
  end;
end;

class procedure &Array<T>.SafeMove(const SrcArray: array of T; var DstArray: array of T;
    const SrcIndex, DstIndex, Count: NativeUInt; const AType: IType<T>);
var
  I: NativeUInt;
begin
  { Do not check for indexes for performance reasons }
  if AType.Management() = tmCompiler then
  begin
    { Copy - using compiler provided magic }
    for I := 0 to Count - 1 do
      DstArray[I + DstIndex] := SrcArray[I + SrcIndex];
  end else
  begin
    { Move directly }
    Move(SrcArray[SrcIndex], DstArray[DstIndex], Count * SizeOf(T));
  end;
end;

class procedure &Array<T>.Sort(var AArray: array of T;
  const StartIndex, Count: NativeUInt; const AType: IType<T>;
  const Ascending: Boolean);
begin
  { Check for indexes }
  if ((StartIndex + Count) > NativeUInt(System.Length(AArray))) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex/Count');

  if AType = nil then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  if Count < 2 then
     Exit;

  { Start quick sort }
  QuickSort(AArray, StartIndex, (StartIndex + Count) - 1, AType, Ascending);
end;

class procedure &Array<T>.Sort(var AArray: array of T;
  const StartIndex, Count: NativeUInt; const ASortProc: TCompareOverride<T>);
begin
  { Check for indexes }
  if ((StartIndex + Count) > NativeUInt(System.Length(AArray))) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex/Count');

  if not Assigned(ASortProc) then
     ExceptionHelper.Throw_ArgumentNilError('ASortProc');

  if Count < 2 then
     Exit;

  { Start quick sort }
  QuickSort(AArray, StartIndex, (StartIndex + Count) - 1, ASortProc);
end;

class procedure &Array<T>.Sort(var AArray: array of T; const AType: IType<T>; const Ascending: Boolean);
begin
  { Call the more generic variant }
  Sort(AArray, 0, Length(AArray), AType, Ascending);
end;

class procedure &Array<T>.Sort(var AArray: array of T; const ASortProc: TCompareOverride<T>);
begin
  { Call the more generic variant }
  Sort(AArray, 0, Length(AArray), ASortProc);
end;

class function &Array<T>.ToVariantArray(const AArray: array of T; const AType: IType<T>): Variant;
var
  LVariantType, LOrigType: Word;
  Indices: array[0..0] of Integer;
  I: NativeUInt;
begin
  { Check arguments }
  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  Result := Unassigned;

  { Try to create a variant array }
  try
    LOrigType := VarType(AType.ConvertToVariant(default(T)));

    { Modify the Variant type in case it is String or Unicode string which are Delphi only }
    if (LOrigType = varString) or (LOrigType = varUString) then
      LVariantType := varOleStr
    else
      LVariantType := LOrigType;

    Result := VarArrayCreate([0, Length(AArray) - 1], LVariantType);
  except
    ExceptionHelper.Throw_TypeIncompatibleWithVariantArray(AType.Name);
  end;

  { And populate the variant array }
  if Length(AArray) > 0 then
  begin
    if LVariantType <> LOrigType then
    begin
      { Copy the array un-altered }
      for I := 0 to Length(AArray) - 1 do
      begin
        Indices[0] := I;
        VarArrayPut(Result, AType.ConvertToVariant(AArray[I]), Indices);
      end;
    end else
    begin
      { Copy the array with alteration rules }
      for I := 0 to Length(AArray) - 1 do
      begin
        Indices[0] := I;
        VarArrayPut(Result, VarAsType(AType.ConvertToVariant(AArray[I]), LVariantType), Indices);
      end;
    end;
  end;
end;

class function &Array<T>.ToVariantArray(const AArray: array of T): Variant;
begin
  { Call upper function }
  Result := ToVariantArray(AArray, TType<T>.Default);
end;

class function &Array<T>.CreateEnumerator(const AArray: TArray<T>): IEnumerator<T>;
var
  LEnum: TEnumerator;
begin
  { Create an enumerator }
  LEnum := TEnumerator.Create;
  LEnum.FArray := AArray;
  LEnum.FCurrent := default(T);
  LEnum.FIndex := 0;

  { And extract the interface to it }
  Result := LEnum;
end;

{ &Array<T>.TEnumerator }

function &Array<T>.TEnumerator.GetCurrent(): T;
begin
  Result := FCurrent;
end;

function &Array<T>.TEnumerator.MoveNext(): Boolean;
begin
  Result := (FIndex < NativeUInt(Length(FArray)));

  if Result then
  begin
    FCurrent := FArray[FIndex];
    Inc(FIndex);
  end;
end;

{ TFixedArrayType<T> }

constructor TFixedArrayType<T>.Create();
begin
  inherited;

  { Obtain the type }
  FType := TType<TArray<T>>.Default;
end;

constructor TFixedArrayType<T>.Create(const AArrayType: IType<TArray<T>>);
begin
  inherited Create();

  if AArrayType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AArrayType');

  FType := AArrayType;
end;

function TFixedArrayType<T>.Compare(const AValue1, AValue2: TFixedArray<T>): NativeInt;
begin
  { Pass-through }
  Result := FType.Compare(AValue1.FArray, AValue2.FArray);
end;

procedure TFixedArrayType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: TFixedArray<T>; const AContext: ISerializationContext);
begin
  { Pass-through }
  FType.Serialize(AInfo, AValue.FArray, AContext);
end;

procedure TFixedArrayType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: TFixedArray<T>; const AContext: IDeserializationContext);
begin
  { Pass-through }
  FType.Deserialize(AInfo, AValue.FArray, AContext);
end;

function TFixedArrayType<T>.Family: TTypeFamily;
begin
  Result := tfArray;
end;

function TFixedArrayType<T>.GenerateHashCode(const AValue: TFixedArray<T>): NativeInt;
begin
  { Pass-through }
  Result := FType.GenerateHashCode(AValue.FArray);
end;

function TFixedArrayType<T>.GetString(const AValue: TFixedArray<T>): String;
begin
  { Pass-through }
  Result := FType.GetString(AValue.FArray);
end;

function TFixedArrayType<T>.TryConvertToVariant(const AValue: TFixedArray<T>; out ORes: Variant): Boolean;
begin
  { Pass-through }
  Result := FType.TryConvertToVariant(AValue.FArray, ORes);
end;

function TFixedArrayType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: TFixedArray<T>): Boolean;
begin
  { Pass-through }
  Result := FType.TryConvertFromVariant(AValue, ORes.FArray);
end;

{ TDynamicArrayType<T> }

constructor TDynamicArrayType<T>.Create();
begin
  inherited;

  { Obtain the type }
  FType := TType<TArray<T>>.Default;
end;

constructor TDynamicArrayType<T>.Create(const AArrayType: IType<TArray<T>>);
begin
  inherited Create();

  if AArrayType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AArrayType');

  FType := AArrayType;
end;

function TDynamicArrayType<T>.Compare(const AValue1, AValue2: TDynamicArray<T>): NativeInt;
begin
  { Pass-through }
  Result := FType.Compare(AValue1.FArray, AValue2.FArray);
end;

procedure TDynamicArrayType<T>.DoSerialize(const AInfo: TValueInfo; const AValue: TDynamicArray<T>; const AContext: ISerializationContext);
begin
  { Pass-through }
  FType.Serialize(AInfo, AValue.FArray, AContext);
end;

procedure TDynamicArrayType<T>.DoDeserialize(const AInfo: TValueInfo; out AValue: TDynamicArray<T>; const AContext: IDeserializationContext);
begin
  { Pass-through }
  FType.Deserialize(AInfo, AValue.FArray, AContext);
end;

function TDynamicArrayType<T>.Family: TTypeFamily;
begin
  Result := tfArray;
end;

function TDynamicArrayType<T>.GenerateHashCode(const AValue: TDynamicArray<T>): NativeInt;
begin
  { Pass-through }
  Result := FType.GenerateHashCode(AValue.FArray);
end;

function TDynamicArrayType<T>.GetString(const AValue: TDynamicArray<T>): String;
begin
  { Pass-through }
  Result := FType.GetString(AValue.FArray);
end;

function TDynamicArrayType<T>.TryConvertToVariant(const AValue: TDynamicArray<T>; out ORes: Variant): Boolean;
begin
  { Pass-through }
  Result := FType.TryConvertToVariant(AValue.FArray, ORes);
end;

function TDynamicArrayType<T>.TryConvertFromVariant(const AValue: Variant; out ORes: TDynamicArray<T>): Boolean;
begin
  { Pass-through }
  Result := FType.TryConvertFromVariant(AValue, ORes.FArray);
end;

end.

