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
unit DeHL.Collections.List;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>list</c> collection.</summary>
  ///  <remarks>This type uses an internal array to store its values.</remarks>
  TList<T> = class(TEnexCollection<T>, IEnexIndexedCollection<T>,
    IList<T>, IUnorderedList<T>, IDynamic)
  private type
    {$REGION 'Internal Types'}
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FList: TList<T>;
      FCurrentIndex: NativeUInt;

    public
      { Constructor }
      constructor Create(const AList: TList<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;
    {$ENDREGION}

  private var
    FArray: TArray<T>;
    FLength: NativeUInt;
    FVer: NativeUInt;

  protected
    ///  <summary>Called when the serialization process is about to begin.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    procedure StartSerializing(const AData: TSerializationData); override;

    ///  <summary>Called when the deserialization process is about to begin.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartDeserializing(const AData: TDeserializationData); override;

    ///  <summary>Called when an element has been deserialized and needs to be inserted into the list.</summary>
    ///  <param name="AElement">The element that was deserialized.</param>
    ///  <remarks>This method simply adds the element to the list.</remarks>
    procedure DeserializeElement(const AElement: T); override;

    ///  <summary>Returns the item from a given index.</summary>
    ///  <param name="AIndex">The index in the list.</param>
    ///  <returns>The element at the specified position.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function GetItem(const AIndex: NativeUInt): T;

    ///  <summary>Sets the item at a given index.</summary>
    ///  <param name="AIndex">The index in the list.</param>
    ///  <param name="AValue">The new value.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    procedure SetItem(const AIndex: NativeUInt; const AValue: T);

    ///  <summary>Returns the number of elements in the list.</summary>
    ///  <returns>A positive value specifying the number of elements in the list.</returns>
    function GetCount(): NativeUInt; override;

    ///  <summary>Returns the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the list can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this method is greater or equal to the amount of elements in the list. If this value
    ///  is greater then the number of elements, it means that the list has some extra capacity to operate upon.</remarks>
    function GetCapacity(): NativeUInt;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The list's initial capacity.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const ACollection: IEnumerable<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: array of T); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TDynamicArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TFixedArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AInitialCapacity">The list's initial capacity.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AInitialCapacity: NativeUInt); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const ACollection: IEnumerable<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: array of T); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TDynamicArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the list.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the list.</summary>
    ///  <remarks>This method clears the list and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Appends an element to the list.</summary>
    ///  <param name="AValue">The value to append.</param>
    procedure Add(const AValue: T); overload;

    ///  <summary>Appends the elements from a collection to the list.</summary>
    ///  <param name="ACollection">The values to append.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    procedure Add(const ACollection: IEnumerable<T>); overload;

    ///  <summary>Inserts an element into the list.</summary>
    ///  <param name="AIndex">The index to insert to.</param>
    ///  <param name="AValue">The value to insert.</param>
    ///  <remarks>All elements starting with <paramref name="AIndex"/> are moved to the right by one and then
    ///  <paramref name="AValue"/> is placed at position <paramref name="AIndex"/>.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    procedure Insert(const AIndex: NativeUInt; const AValue: T); overload;

    ///  <summary>Inserts the elements of a collection into the list.</summary>
    ///  <param name="AIndex">The index to insert to.</param>
    ///  <param name="ACollection">The values to insert.</param>
    ///  <remarks>All elements starting with <paramref name="AIndex"/> are moved to the right by the length of
    ///  <paramref name="ACollection"/> and then <paramref name="AValue"/> is placed at position <paramref name="AIndex"/>.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    procedure Insert(const AIndex: NativeUInt; const ACollection: IEnumerable<T>); overload;

    ///  <summary>Removes a given value from the list.</summary>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>If the list does not contain the given value, nothing happens.</remarks>
    procedure Remove(const AValue: T);

    ///  <summary>Removes an element from the list at a given index.</summary>
    ///  <param name="AIndex">The index from which to remove the element.</param>
    ///  <remarks>This method removes the specified element and moves all following elements to the left by one.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    procedure RemoveAt(const AIndex: NativeUInt);

    ///  <summary>Reverses the elements in this list.</summary>
    ///  <param name="AStartIndex">The start index.</param>
    ///  <param name="ACount">The count of elements.</param>
    ///  <remarks>This method reverses <paramref name="ACount"/> number of elements in
    ///  the the list, starting with <paramref name="AStartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    procedure Reverse(const AStartIndex, ACount: NativeUInt); overload;

    ///  <summary>Reverses the elements in this list.</summary>
    ///  <param name="AStartIndex">The start index.</param>
    ///  <remarks>This method reverses all elements in the list, starting with <paramref name="AStartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    procedure Reverse(const AStartIndex: NativeUInt); overload;

    ///  <summary>Reverses the elements in this list.</summary>
    procedure Reverse(); overload;

    ///  <summary>Sorts the contents of this list.</summary>
    ///  <param name="AStartIndex">The start index.</param>
    ///  <param name="ACount">The count of elements.</param>
    ///  <param name="AAscending">Specifies whether ascending or descending sorting is performed. Default is <c>True</c>.</param>
    ///  <remarks>This method sorts <paramref name="ACount"/> number of elements in
    ///  the list, starting with <paramref name="AStartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    procedure Sort(const AStartIndex, ACount: NativeUInt; const AAscending: Boolean = true); overload;

    ///  <summary>Sorts the contents of this list.</summary>
    ///  <param name="AStartIndex">The start index.</param>
    ///  <param name="AAscending">Specifies whether ascending or descending sorting is performed. Default is <c>True</c>.</param>
    ///  <remarks>This method sorts all elements in the list, starting with <paramref name="AStartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    procedure Sort(const AStartIndex: NativeUInt; const AAscending: Boolean = true); overload;

    ///  <summary>Sorts the contents of this list.</summary>
    ///  <param name="AAscending">Specifies whether ascending or descending sorting is performed. Default is <c>True</c>.</param>
    procedure Sort(const AAscending: Boolean = true); overload;

    ///  <summary>Sorts the contents of this list using a given comparison method.</summary>
    ///  <param name="AStartIndex">The start index.</param>
    ///  <param name="ACount">The count of elements.</param>
    ///  <param name="ASortProc">The method used to compare elements.</param>
    ///  <remarks>This method sorts <paramref name="ACount"/> number of elements in
    ///  the list, starting with <paramref name="AStartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASortProc"/> is <c>nil</c>.</exception>
    procedure Sort(const AStartIndex, ACount: NativeUInt; const ASortProc: TCompareOverride<T>); overload;

    ///  <summary>Sorts the contents of this list using a given comparison method.</summary>
    ///  <param name="AStartIndex">The start index.</param>
    ///  <param name="ASortProc">The method used to compare elements.</param>
    ///  <remarks>This method sorts all elements in the list, starting with <paramref name="AStartIndex"/> element.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASortProc"/> is <c>nil</c>.</exception>
    procedure Sort(const AStartIndex: NativeUInt; const ASortProc: TCompareOverride<T>); overload;

    ///  <summary>Sorts the contents of this list using a given comparison method.</summary>
    ///  <param name="ASortProc">The method used to compare elements.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASortProc"/> is <c>nil</c>.</exception>
    procedure Sort(const ASortProc: TCompareOverride<T>); overload;

    ///  <summary>Checks whether the list contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the list; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;

    ///  <summary>Searches for the first appearance of a given element in this list.</summary>
    ///  <param name="AValue">The value to search for.</param>
    ///  <param name="AStartIndex">The index to from which the search starts.</param>
    ///  <param name="ACount">The number of elements after the starting one to check against.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value indicating the index of the value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    function IndexOf(const AValue: T; const AStartIndex, ACount: NativeUInt): NativeInt; overload;

    ///  <summary>Searches for the first appearance of a given element in this list.</summary>
    ///  <param name="AValue">The value to search for.</param>
    ///  <param name="AStartIndex">The index to from which the search starts.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value indicating the index of the value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    function IndexOf(const AValue: T; const AStartIndex: NativeUInt): NativeInt; overload;

    ///  <summary>Searches for the first appearance of a given element in this list.</summary>
    ///  <param name="AValue">The value to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value indicating the index of the value.</returns>
    function IndexOf(const AValue: T): NativeInt; overload;

    ///  <summary>Searches for the last appearance of a given element in this list.</summary>
    ///  <param name="AValue">The value to search for.</param>
    ///  <param name="AStartIndex">The index to from which the search starts.</param>
    ///  <param name="ACount">The number of elements after the starting one to check against.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value indicating the index of the value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    function LastIndexOf(const AValue: T; const AStartIndex, ACount: NativeUInt): NativeInt; overload;

    ///  <summary>Searches for the last appearance of a given element in this list.</summary>
    ///  <param name="AValue">The value to search for.</param>
    ///  <param name="AStartIndex">The index to from which the search starts.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value indicating the index of the value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    function LastIndexOf(const AValue: T; const AStartIndex: NativeUInt): NativeInt; overload;

    ///  <summary>Searches for the last appearance of a given element in this list.</summary>
    ///  <param name="AValue">The value to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value indicating the index of the value.</returns>
    function LastIndexOf(const AValue: T): NativeInt; overload;

    ///  <summary>Specifies the number of elements in the list.</summary>
    ///  <returns>A positive value specifying the number of elements in the list.</returns>
    property Count: NativeUInt read FLength;

    ///  <summary>Specifies the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the list can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this property is greater or equal to the amount of elements in the list. If this value
    ///  if greater then the number of elements, it means that the list has some extra capacity to operate upon.</remarks>
    property Capacity: NativeUInt read GetCapacity;

    ///  <summary>Returns the item from a given index.</summary>
    ///  <param name="AIndex">The index in the collection.</param>
    ///  <returns>The element at the specified position.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    property Items[const AIndex: NativeUInt]: T read GetItem; default;

    ///  <summary>Returns a new enumerator object used to enumerate this list.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the list.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<T>; override;

    ///  <summary>Removes the excess capacity from the list.</summary>
    ///  <remarks>This method can be called manually to force the list to drop the extra capacity it might hold. For example,
    ///  after performing some massive operations of a big list, call this method to ensure that all extra memory held by the
    ///  list is released.</remarks>
    procedure Shrink();

    ///  <summary>Forces the list to increase its capacity.</summary>
    ///  <remarks>Call this method to force the list to increase its capacity ahead of time. Manually adjusting the capacity
    ///  can be useful in certain situations.</remarks>
    procedure Grow();

    ///  <summary>Copies the specified elements into a new list.</summary>
    ///  <param name="AStartIndex">The index to from which the copy starts.</param>
    ///  <param name="ACount">The number of elements to copy.</param>
    ///  <returns>A new list containing the copied elements.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is invalid.</exception>
    function Copy(const AStartIndex: NativeUInt; const ACount: NativeUInt): TList<T>; overload;

    ///  <summary>Copies the specified elements into a new list.</summary>
    ///  <param name="AStartIndex">The index to from which the copy starts.</param>
    ///  <returns>A new list containing the copied elements.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    function Copy(const AStartIndex: NativeUInt): TList<T>; overload;

    ///  <summary>Creates a copy of this list.</summary>
    ///  <returns>A new list containing the copied elements.</returns>
    function Copy(): TList<T>; overload;

    ///  <summary>Copies the values stored in the list to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the list.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the list.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const AStartIndex: NativeUInt); overload; override;

    ///  <summary>Checks whether the list is empty.</summary>
    ///  <returns><c>True</c> if the list is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the list is empty.</remarks>
    function Empty(): Boolean; override;

    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the list considered to have the biggest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The list is empty.</exception>
    function Max(): T; override;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the list considered to have the smallest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The list is empty.</exception>
    function Min(): T; override;

    ///  <summary>Returns the first element.</summary>
    ///  <returns>The first element in the list.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The list is empty.</exception>
    function First(): T; override;

    ///  <summary>Returns the first element or a default if the list is empty.</summary>
    ///  <param name="ADefault">The default value returned if the list is empty.</param>
    ///  <returns>The first element in list if the list is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function FirstOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the last element.</summary>
    ///  <returns>The last element in the list.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The list is empty.</exception>
    function Last(): T; override;

    ///  <summary>Returns the last element or a default if the list is empty.</summary>
    ///  <param name="ADefault">The default value returned if the list is empty.</param>
    ///  <returns>The last element in list if the list is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function LastOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the single element stored in the list.</summary>
    ///  <returns>The element in list.</returns>
    ///  <remarks>This method checks if the list contains just one element, in which case it is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The list is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionNotOneException">There is more than one element in the list.</exception>
    function Single(): T; override;

    ///  <summary>Returns the single element stored in the list, or a default value.</summary>
    ///  <param name="ADefault">The default value returned if there is less or more elements in the list.</param>
    ///  <returns>The element in the list if the condition is satisfied; <paramref name="ADefault"/> is returned otherwise.</returns>
    ///  <remarks>This method checks if the list contains just one element, in which case it is returned. Otherwise
    ///  the value in <paramref name="ADefault"/> is returned.</remarks>
    function SingleOrDefault(const ADefault: T): T; override;

    ///  <summary>Aggregates a value based on the list's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <returns>A value that contains the list's aggregated value.</returns>
    ///  <remarks>This method returns the first element if the list only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The list is empty.</exception>
    function Aggregate(const AAggregator: TFunc<T, T, T>): T; override;

    ///  <summary>Aggregates a value based on the list's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <param name="ADefault">The default value returned if the list is empty.</param>
    ///  <returns>A value that contains the list's aggregated value. If the list is empty, <paramref name="ADefault"/> is returned.</returns>
    ///  <remarks>This method returns the first element if the list only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    function AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T; override;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <returns>The element from the specified position.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The list is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function ElementAt(const AIndex: NativeUInt): T; override;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <param name="ADefault">The default value returned if the list is empty.</param>
    ///  <returns>The element from the specified position if the list is not empty and the position is not out of bounds; otherwise
    ///  the value of <paramref name="ADefault"/> is returned.</returns>
    function ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T; override;

    ///  <summary>Check whether at least one element in the list satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if the at least one element satisfies a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole list and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>True</c>. The logical equivalent of this operation is "OR".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;

    ///  <summary>Checks that all elements in the list satisfy a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if all elements satisfy a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole list and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>False</c>. The logical equivalent of this operation is "AND".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function All(const APredicate: TFunc<T, Boolean>): Boolean; override;

    ///  <summary>Checks whether the elements in this list are equal to the elements in another collection.</summary>
    ///  <param name="ACollection">The collection to compare to.</param>
    ///  <returns><c>True</c> if the collections are equal; <c>False</c> if the collections are different.</returns>
    ///  <remarks>This methods checks that each element at position X in this list is equal to an element at position X in
    ///  the provided collection. If the number of elements in both collections are different, then the collections are considered different.
    ///  Note that comparison of element is done using the type object used by this list. This means that comparing this collection
    ///  to another one might yeild a different result than comparing the other collection to this one.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function EqualsTo(const ACollection: IEnumerable<T>): Boolean; override;
  end;

  ///  <summary>The generic <c>list</c> collection designed to store objects.</summary>
  ///  <remarks>This type uses an internal array to store its objects.</remarks>
  TObjectList<T: class> = class(TList<T>)
  private
    FWrapperType: TObjectWrapperType<T>;

    { Getters/Setters for OwnsObjects }
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const AValue: Boolean);

  protected
    ///  <summary>Installs the type object.</summary>
    ///  <param name="AType">The type object to install.</param>
    ///  <remarks>This method installs a custom wrapper designed to suppress the cleanup of objects on request.
    ///  Make sure to call this method in descendant classes.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
     procedure InstallType(const AType: IType<T>); override;

  public
    ///  <summary>Specifies whether this list owns the objects stored in it.</summary>
    ///  <returns><c>True</c> if the list owns its objects; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the list controls the life-time of the stored objects.</remarks>
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

const
  DefaultArrayLength = 32;

{ TList<T> }

procedure TList<T>.Add(const ACollection: IEnumerable<T>);
begin
  { Call Insert }
  Insert(FLength, ACollection);
end;

function TList<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
var
  I: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := FArray[0];

  { Iterate over the last N - 1 elements }
  for I := 1 to FLength - 1 do
  begin
    { Aggregate a AValue }
    Result := AAggregator(Result, FArray[I]);
  end;
end;

function TList<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
var
  I: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FLength = 0 then
    Exit(ADefault);

  { Select the first element as comparison base }
  Result := FArray[0];

  { Iterate over the last N - 1 elements }
  for I := 1 to FLength - 1 do
  begin
    { Aggregate a AValue }
    Result := AAggregator(Result, FArray[I]);
  end;
end;

function TList<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  I: NativeUInt;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if FLength > 0 then
    for I := 0 to FLength - 1 do
      if not APredicate(FArray[I]) then
        Exit(false);

  Result := true;
end;

function TList<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  I: NativeUInt;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if FLength > 0 then
    for I := 0 to FLength - 1 do
      if APredicate(FArray[I]) then
        Exit(true);

  Result := false;
end;

procedure TList<T>.Add(const AValue: T);
begin
  { Call Insert }
  Insert(FLength, AValue);
end;

procedure TList<T>.Clear;
var
  I: NativeInt;
begin
  if (ElementType <> nil) and (ElementType.Management() = tmManual) and (FLength > 0) then
  begin
    { Should cleanup each element individually }
    for I := 0 to FLength - 1 do
      ElementType.Cleanup(FArray[I]);
  end;

  { Reset the length }
  FLength := 0;
end;

function TList<T>.Contains(const AValue: T): Boolean;
begin
  { Pass the call to AIndex of }
  Result := (IndexOf(AValue) > -1);
end;

function TList<T>.Copy(const AStartIndex: NativeUInt): TList<T>;
begin
  { Pass the call down to the more generic function }
  Copy(AStartIndex, (FLength - AStartIndex));
end;

function TList<T>.Copy(const AStartIndex, ACount: NativeUInt): TList<T>;
var
  NewList: TList<T>;

begin
  { Check for zero elements }
  if (FLength = 0) then
  begin
    Result := TList<T>.Create(ElementType);
    Exit;
  end;
  
  { Check for indexes }
  if (AStartIndex >= FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  { Check for indexes }
  if ((AStartIndex + ACount) > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  { Create a new list }
  NewList := TList<T>.Create(ElementType, ACount);

  { Copy all elements safely }
  &Array<T>.SafeMove(FArray, NewList.FArray, AStartIndex, 0, ACount, ElementType);

  { Set new count }
  NewList.FLength := ACount;

  Result := NewList;
end;

procedure TList<T>.CopyTo(var AArray: array of T; const AStartIndex: NativeUInt);
begin
  { Check for indexes }
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  if (NativeUInt(Length(AArray)) - AStartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Copy all elements safely }
  &Array<T>.SafeMove(FArray, AArray, 0, AStartIndex, FLength, ElementType);
end;

constructor TList<T>.Create(const AArray: TFixedArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TList<T>.Create(const AArray: TDynamicArray<T>);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TList<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Add(AArray[I]);
    end;
end;

constructor TList<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Add(AArray[I]);
    end;
end;

constructor TList<T>.Create(const AType: IType<T>);
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);
end;

constructor TList<T>.Create(const AType: IType<T>;
  const ACollection: IEnumerable<T>);
var
  V: T;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Initialize instance }
  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  Add(ACollection);
end;

constructor TList<T>.Create;
begin
  Create(TType<T>.Default);
end;

constructor TList<T>.Create(const AInitialCapacity: NativeUInt);
begin
  Create(TType<T>.Default, AInitialCapacity);
end;

constructor TList<T>.Create(const ACollection: IEnumerable<T>);
begin
  Create(TType<T>.Default, ACollection);
end;

constructor TList<T>.Create(const AType: IType<T>;
  const AInitialCapacity: NativeUInt);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  { Install the type }
  InstallType(AType);

  FLength := 0;
  FVer := 0;
  SetLength(FArray, AInitialCapacity);
end;

procedure TList<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Add(AElement);
end;

destructor TList<T>.Destroy;
begin
  { Clear list first }
  Clear();

  inherited;
end;

function TList<T>.ElementAt(const AIndex: NativeUInt): T;
begin
  { Simply use the getter }
  Result := GetItem(AIndex);
end;

function TList<T>.ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T;
begin
  { Check range }
  if (AIndex >= FLength) then
     Result := ADefault
  else
    Result := FArray[AIndex];
end;

function TList<T>.Empty: Boolean;
begin
  Result := (FLength = 0);
end;

function TList<T>.EqualsTo(const ACollection: IEnumerable<T>): Boolean;
var
  V: T;
  I: NativeUInt;
begin
  I := 0;

  for V in ACollection do
  begin
    if I >= FLength then
      Exit(false);

    if not ElementType.AreEqual(FArray[I], V) then
      Exit(false);

    Inc(I);
  end;

  if I < FLength then
    Exit(false);

  Result := true;
end;

function TList<T>.First: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FArray[0];
end;

function TList<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else
    Result := FArray[0];
end;

function TList<T>.GetCapacity: NativeUInt;
begin
  Result := Length(FArray);
end;

function TList<T>.GetCount: NativeUInt;
begin
  Result := FLength;
end;

function TList<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create an enumerator }
  Result := TEnumerator.Create(Self);
end;

function TList<T>.GetItem(const AIndex: NativeUInt): T;
begin
  { Check range }
  if (AIndex >= FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');

  { Get AValue }
  Result := FArray[AIndex];
end;

procedure TList<T>.Grow;
begin
  { Grow the array }
  if FLength < DefaultArrayLength then
     SetLength(FArray, FLength + DefaultArrayLength)
  else
     SetLength(FArray, FLength * 2);
end;

function TList<T>.IndexOf(const AValue: T): NativeInt;
begin
  { Call more generic function }
  Result := IndexOf(AValue, 0, FLength);
end;

function TList<T>.IndexOf(const AValue: T;
  const AStartIndex: NativeUInt): NativeInt;
begin
  { Call more generic function }
  Result := IndexOf(AValue, AStartIndex, (FLength - AStartIndex));
end;

function TList<T>.IndexOf(const AValue: T; const AStartIndex,
  ACount: NativeUInt): NativeInt;
var
  I: NativeInt;
begin
  Result := -1;

  if FLength = 0 then
     Exit;
  
  { Check for indexes }
  if (AStartIndex >= FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  { Check for indexes }
  if ((AStartIndex + ACount) > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  { Search for the AValue }
  for I := AStartIndex to ((AStartIndex + ACount) - 1) do
      if ElementType.AreEqual(FArray[I], AValue) then
      begin
        Result := I;
        Exit;
      end;       
end;

procedure TList<T>.Insert(const AIndex: NativeUInt; const AValue: T);
var
  I  : NativeInt;
  Cap: NativeUInt;
begin
  if AIndex > FLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');

  if FLength = NativeUInt(Length(FArray)) then
    Grow();

  { Move the array to the right }
  if AIndex < FLength then
     for I := FLength downto (AIndex + 1) do
         FArray[I] := FArray[I - 1];

  Inc(FLength);

  { Put the element into the new position }
  FArray[AIndex] := AValue;
  Inc(FVer);
end;

procedure TList<T>.Insert(const AIndex: NativeUInt;
  const ACollection: IEnumerable<T>);
var
  V: T;
  I: NativeInt;
begin
  if AIndex > FLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');

  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  I := AIndex;
  
  { Enumerate and add }
  for V in ACollection do
  begin
    Insert(I, V);
    Inc(I);
  end;
end;

function TList<T>.LastIndexOf(const AValue: T;
  const AStartIndex: NativeUInt): NativeInt;
begin
  { Call more generic function }
  Result := LastIndexOf(AValue, AStartIndex, (FLength - AStartIndex));
end;

function TList<T>.Last: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FArray[FLength - 1];
end;

function TList<T>.LastIndexOf(const AValue: T): NativeInt;
begin
  { Call more generic function }
  Result := LastIndexOf(AValue, 0, FLength);
end;

function TList<T>.LastOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else
    Result := FArray[FLength - 1];
end;

function TList<T>.Max: T;
var
  I: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  Result := FArray[0];

  for I := 1 to FLength - 1 do
    if ElementType.Compare(FArray[I], Result) > 0 then
      Result := FArray[I];
end;

function TList<T>.Min: T;
var
  I: NativeUInt;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Default one }
  Result := FArray[0];

  for I := 1 to FLength - 1 do
    if ElementType.Compare(FArray[I], Result) < 0 then
      Result := FArray[I];
end;

function TList<T>.LastIndexOf(const AValue: T; const AStartIndex,
  ACount: NativeUInt): NativeInt;
var
  I: NativeInt;
begin
  Result := -1;

  if FLength = 0 then
     Exit;

  { Check for indexes }
  if (AStartIndex >= FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  { Check for indexes }
  if ((AStartIndex + ACount) > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  { Search for the AValue }
  for I := ((AStartIndex + ACount) - 1) downto AStartIndex do
      if ElementType.AreEqual(FArray[I], AValue) then
      begin
        Result := I;
        Exit;
      end;       
end;

procedure TList<T>.Remove(const AValue: T);
var
  I, FoundIndex: NativeInt;
begin
  { Defaults }
  if (FLength = 0) then Exit;
  FoundIndex := -1;

  for I := 0 to FLength - 1 do
  begin
    if ElementType.AreEqual(FArray[I], AValue) then
    begin
      FoundIndex := I;
      Break;
    end;
  end;

  if FoundIndex > -1 then
  begin
    { Move the list }
    if FLength > 1 then
      for I := FoundIndex to FLength - 2 do
        FArray[I] := FArray[I + 1];

    Dec(FLength);
    Inc(FVer);
  end;
end;

procedure TList<T>.RemoveAt(const AIndex: NativeUInt);
var
  I: NativeInt;
begin
  if AIndex >= FLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');

  if (FLength = 0) then Exit;

  { Clanup the element at the specified AIndex if required }
  if ElementType.Management() = tmManual then
    ElementType.Cleanup(FArray[AIndex]);

  { Move the list }
  if FLength > 1 then
    for I := AIndex to FLength - 2 do
      FArray[I] := FArray[I + 1];

  Dec(FLength);
  Inc(FVer);
end;

procedure TList<T>.Reverse(const AStartIndex, ACount: NativeUInt);
begin
  { Check for indexes }
  if ((AStartIndex + ACount) > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex/ACount');

  &Array<T>.Reverse(FArray, AStartIndex, ACount);
end;

procedure TList<T>.Reverse(const AStartIndex: NativeUInt);
begin
  { Check for indexes }
  if (AStartIndex > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  &Array<T>.Reverse(FArray, AStartIndex, (FLength - AStartIndex));
end;

procedure TList<T>.Reverse;
begin
  &Array<T>.Reverse(FArray, 0, FLength);
end;

procedure TList<T>.Sort(const AStartIndex, ACount: NativeUInt; const AAscending: Boolean);
begin
  { Check for indexes }
  if ((AStartIndex + ACount) > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex/ACount');

  &Array<T>.Sort(FArray, AStartIndex, ACount, ElementType, AAscending);
end;

procedure TList<T>.Sort(const AStartIndex: NativeUInt; const AAscending: Boolean);
begin
  { Check for indexes }
  if (AStartIndex > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  &Array<T>.Sort(FArray, AStartIndex, (FLength - AStartIndex), ElementType, AAscending);
end;

procedure TList<T>.SetItem(const AIndex: NativeUInt; const AValue: T);
begin
  { Check range }
  if (AIndex >= FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');

  { Get AValue }
  FArray[AIndex] := AValue;
end;

procedure TList<T>.Shrink;
begin
  { Cut the capacity if required }
  if FLength < Capacity then
  begin
    SetLength(FArray, FLength);
  end;
end;

function TList<T>.Single: T;
begin
  { Check length }
  if FLength = 0 then
    ExceptionHelper.Throw_CollectionEmptyError()
  else if FLength > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FArray[0];
end;

function TList<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Check length }
  if FLength = 0 then
    Result := ADefault
  else if FLength > 1 then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement()
  else
    Result := FArray[0];
end;

procedure TList<T>.Sort(const AStartIndex, ACount: NativeUInt; const ASortProc: TCompareOverride<T>);
begin
  { Check for indexes }
  if ((AStartIndex + ACount) > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex/ACount');

  &Array<T>.Sort(FArray, AStartIndex, ACount, ASortProc);
end;

procedure TList<T>.Sort(const AStartIndex: NativeUInt; const ASortProc: TCompareOverride<T>);
begin
  { Check for indexes }
  if (AStartIndex > FLength) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  &Array<T>.Sort(FArray, AStartIndex, (FLength - AStartIndex), ASortProc);
end;

procedure TList<T>.Sort(const ASortProc: TCompareOverride<T>);
begin
  &Array<T>.Sort(FArray, 0, FLength, ASortProc);
end;

procedure TList<T>.Sort(const AAscending: Boolean);
begin
  &Array<T>.Sort(FArray, 0, FLength, ElementType, AAscending);
end;

procedure TList<T>.StartDeserializing(const AData: TDeserializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

procedure TList<T>.StartSerializing(const AData: TSerializationData);
begin
  // Do nothing, just say that I am here and I can be serialized
end;

function TList<T>.Copy: TList<T>;
begin
  { Call a more generic function }
  Result := Copy(0, FLength);
end;

constructor TList<T>.Create(const AArray: array of T);
begin
  Create(TType<T>.Default, AArray);
end;

constructor TList<T>.Create(const AType: IType<T>; const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType, DefaultArrayLength);

  { Copy from array }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;

{ TList<T>.TEnumerator }

constructor TList<T>.TEnumerator.Create(const AList: TList<T>);
begin
  { Initialize }
  FList := AList;
  KeepObjectAlive(FList);

  FCurrentIndex := 0;
  FVer := FList.FVer;
end;

destructor TList<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FList);
  inherited;
end;

function TList<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FList.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  if FCurrentIndex > 0 then
    Result := FList.FArray[FCurrentIndex - 1]
  else
    Result := default(T);
end;

function TList<T>.TEnumerator.MoveNext: Boolean;
begin
  if FVer <> FList.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FCurrentIndex < FList.FLength;
  Inc(FCurrentIndex);
end;

{ TObjectList<T> }

procedure TObjectList<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectList<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectList<T>.SetOwnsObjects(const AValue: Boolean);
begin
  FWrapperType.AllowCleanup := AValue;
end;

end.
