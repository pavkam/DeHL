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
unit DeHL.Collections.Base;
interface
uses
  SysUtils,
  DeHL.Base,
  DeHL.StrConsts,
  DeHL.Arrays,
  DeHL.Exceptions,
  DeHL.Types,
  DeHL.Serialization,
  DeHL.Conversion,
  DeHL.Tuples;

{$REGION 'Base Collection Interfaces'}
type
  ///  <summary>Base interface inherited by all specific collection interfaces.</summary>
  ///  <remarks>This interface defines a set of traits common to all collections implemented in DeHL.</remarks>
  ICollection<T> = interface(IEnumerable<T>)

    ///  <summary>Returns the number of elements in the collection.</summary>
    ///  <returns>A positive value specifying the number of elements in the collection.</returns>
    ///  <remarks>For associative collections such a dictionaries or multimaps, this value represents the
    ///  number of key-value pairs stored in the collection. A call to this method can be costly because some
    ///  collections cannot detect the number of stored elements directly, resorting to enumerating themselves.</remarks>
    function GetCount(): NativeUInt;

    ///  <summary>Checks whether the collection is empty.</summary>
    ///  <returns><c>True</c> if the collection is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the collection is empty. It is optimized
    ///  in most collections to offer a fast response.</remarks>
    function Empty(): Boolean;

    ///  <summary>Returns the single element stored in the collection.</summary>
    ///  <returns>The element in collection.</returns>
    ///  <remarks>This method checks if the collection contains just one element, in which case it is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionNotOneException">There is more than one element in the collection.</exception>
    function Single(): T;

    ///  <summary>Returns the single element stored in the collection, or a default value.</summary>
    ///  <param name="ADefault">The default value returned if there is less or more elements in the collection.</param>
    ///  <returns>The element in the collection if the condition is satisfied; <paramref name="ADefault"/> is returned otherwise.</returns>
    ///  <remarks>This method checks if the collection contains just one element, in which case it is returned. Otherwise
    ///  the value in <paramref name="ADefault"/> is returned.</remarks>
    function SingleOrDefault(const ADefault: T): T;

    ///  <summary>Copies the values stored in the collection to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the collection.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T); overload;

    ///  <summary>Copies the values stored in the collection to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the collection.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const AStartIndex: NativeUInt); overload;

    ///  <summary>Creates a new Delphi array with the contents of the collection.</summary>
    ///  <remarks>The length of the new array is equal to the value of <c>Count</c> property.</remarks>
    function ToArray(): TArray<T>;

    ///  <summary>Creates a new fixed array with the contents of the collection.</summary>
    ///  <remarks>The length of the new array is equal to the value of <c>Count</c> property.</remarks>
    function ToFixedArray(): TFixedArray<T>;

    ///  <summary>Creates a new dynamic array with the contents of the collection.</summary>
    ///  <remarks>The length of the new array is equal to the value of <c>Count</c> property.</remarks>
    function ToDynamicArray(): TDynamicArray<T>;

    ///  <summary>Specifies the number of elements in the collection.</summary>
    ///  <returns>A positive value specifying the number of elements in the collection.</returns>
    ///  <remarks>For associative collections such a dictionaries or multimaps, this value represents the
    ///  number of key-value pairs stored in the collection. Accesing this property can be costly because some
    ///  collections cannot detect the number of stored elements directly, resorting to enumerating themselves.</remarks>
    property Count: NativeUInt read GetCount;
  end;

  { Pre-declarations }
  IList<T> = interface;
  ISet<T> = interface;
  IDictionary<TKey, TValue> = interface;
  IEnexCollection<T> = interface;

  ///  <summary>Offers extended set of Enex operations.</summary>
  ///  <remarks>This type is exposed by Enex collections, and serves simply as a bridge between the interfaces
  ///  and some advanced operations that require parameterized methods. For example expressions such as
  ///  <c>List.Op.Cast&lt;Integer&gt;</c> are based on this type.</remarks>
  TEnexExtOps<T> = record
  private
    FType: IType<T>;
    FInstance: Pointer;
    FKeepAlive: IInterface;

  public
    ///  <summary>Represents a "select" operation.</summary>
    ///  <param name="ASelector">A selector method invoked for each element in the collction.</param>
    ///  <param name="AType">A type object representing the elements in the output collection.</param>
    ///  <returns>A new collection containing the selected values.</returns>
    ///  <remarks>This method is use when it is required to select values related to the ones in the operated collection.
    ///  For example, you can select collection of integers where each integer is a field of a class in the original collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASelector"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    function Select<TOut>(const ASelector: TFunc<T, TOut>; const AType: IType<TOut>): IEnexCollection<TOut>; overload;

    ///  <summary>Represents a "select" operation.</summary>
    ///  <param name="ASelector">A selector method invoked for each element in the collction.</param>
    ///  <returns>A new collection containing the selected values.</returns>
    ///  <remarks>This method is use when it is required to select values related to the ones in the operated collection.
    ///  For example, you can select collection of integers where each integer is a field of a class in the original collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASelector"/> is <c>nil</c>.</exception>
    function Select<TOut>(const ASelector: TFunc<T, TOut>): IEnexCollection<TOut>; overload;

    ///  <summary>Represents a "where, select object" operation.</summary>
    ///  <returns>A new collection containing the selected values.</returns>
    ///  <remarks>This method can be used on a collection containing objects. The operation involves two steps,
    ///  where and select. First, each object is checked to be derived from <c>TOut</c>. If that is true, it is then
    ///  cast to <c>TOut</c>. The result of the operation is a new collection that contains only the objects of a given
    ///  class. For example, <c>AList.Op.Select&lt;TMyObject&gt;</c> results in a new collection that only contains
    ///  "TMyObject" instances.</remarks>
    ///  <exception cref="DeHL.Exceptions|ETypeException">The collection's elements are not objects.</exception>
    function Select<TOut: class>(): IEnexCollection<TOut>; overload;

    ///  <summary>Represents a cast operation.</summary>
    ///  <param name="AType">A type object representing the elements in the output collection.</param>
    ///  <returns>A new collection containing the casted values.</returns>
    ///  <remarks>This method converts each element from the input collection to an element in the output collection. For example,
    ///  given a list of integers "AList", the operation <c>AList.Op.Cast&lt;string&gt;</c> results in a new collction that contains
    ///  the string representations of the integer values. This method uses the
    ///  <see cref="DeHL.Conversion|TConverter&lt;TIn, TOut&gt;">DeHL.Conversion.TConverter&lt;TIn, TOut&gt;</see> class to convert each element
    ///  from the input collection to an element in the output collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported">Cannot convert an element from the input collection.</exception>
    function Cast<TOut>(const AType: IType<TOut>): IEnexCollection<TOut>; overload;

    ///  <summary>Represents a cast operation.</summary>
    ///  <returns>A new collection containing the casted values.</returns>
    ///  <remarks>This method converts each element from the input collection to an element in the output collection. For example,
    ///  given a list of integers "AList", the operation <c>AList.Op.Cast&lt;string&gt;</c> results in a new collction that contains
    ///  the string representations of the integer values. This method uses the
    ///  <see cref="DeHL.Conversion|TConverter&lt;TIn, TOut&gt;">DeHL.Conversion.TConverter&lt;TIn, TOut&gt;</see> class to convert each element
    ///  from the input collection to an element in the output collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported">Cannot convert an element from the input collection.</exception>
    function Cast<TOut>(): IEnexCollection<TOut>; overload;
  end;

  ///  <summary>Base Enex (Extended enumerable) interface inherited by all specific collection interfaces.</summary>
  ///  <remarks>This interface defines a set of traits common to all collections implemented in DeHL. It also introduces
  ///  a large se of extended operations that can pe performed on any collection that supports enumerability.</remarks>
  IEnexCollection<T> = interface(ICollection<T>)
    ///  <summary>Checks whether the elements in this collections are equal to the elements in another collection.</summary>
    ///  <param name="ACollection">The collection to compare to.</param>
    ///  <returns><c>True</c> if the collections are equal; <c>False</c> if the collections are different.</returns>
    ///  <remarks>This methods checks that each element at position X in this collection is equal to an element at position X in
    ///  the provided collection. If the number of elements in both collections are different, then the collections are considered different.
    ///  Note that comparison of element is done using the type object used by this collection. This means that comparing this collection
    ///  to another one might yeild a different result than comparing the other collection to this one.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function EqualsTo(const ACollection: IEnumerable<T>): Boolean;

    ///  <summary>Creates a new list containing the elements of this collection.</summary>
    ///  <returns>A list containing the elements copied from this collection.</returns>
    ///  <remarks>This method also copies the type object of this collection. Be careful if the type object
    ///  performs cleanup on the elements.</remarks>
    function ToList(): IList<T>;

    ///  <summary>Creates a new set containing the elements of this collection.</summary>
    ///  <returns>A set containing the elements copied from this collection.</returns>
    ///  <remarks>This method also copies the type object of this collection. Be careful if the type object
    ///  performs cleanup on the elements.</remarks>
    function ToSet(): ISet<T>;

    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the collection considered to have the biggest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Max(): T;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the collection considered to have the smallest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Min(): T;

    ///  <summary>Returns the first element.</summary>
    ///  <returns>The first element in collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function First(): T;

    ///  <summary>Returns the first element or a default if the collection is empty.</summary>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>The first element in collection if the collection is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function FirstOrDefault(const ADefault: T): T;

    ///  <summary>Returns the first element that satisfies the given predicate.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <returns>The first element that satisfies the given predicate.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the predicate.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhere(const APredicate: TFunc<T, Boolean>): T;

    ///  <summary>Returns the first element that satisfies the given predicate or a default value.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given predicate; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhereOrDefault(const APredicate: TFunc<T, Boolean>; const ADefault: T): T;

    ///  <summary>Returns the first element that does not satisfy the given predicate.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <returns>The first element that does not satisfy the given predicate.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements that do not satisfy the predicate.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhereNot(const APredicate: TFunc<T, Boolean>): T;

    ///  <summary>Returns the first element that does not satisfy the given predicate or a default value.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that does not satisfy the given predicate; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhereNotOrDefault(const APredicate: TFunc<T, Boolean>; const ADefault: T): T;

    ///  <summary>Returns the first element lower than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLower(const ABound: T): T;

    ///  <summary>Returns the first element lower than a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLowerOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element lower than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLowerOrEqual(const ABound: T): T;

    ///  <summary>Returns the first element lower than or equal to a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLowerOrEqualOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element greater than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreater(const ABound: T): T;

    ///  <summary>Returns the first element greater than a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreaterOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreaterOrEqual(const ABound: T): T;

    ///  <summary>Returns the first element greater than or equal to a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreaterOrEqualOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element situated within the given bounds.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereBetween(const ALower, AHigher: T): T;

    ///  <summary>Returns the first element situated within the given bounds or a default.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereBetweenOrDefault(const ALower, AHigher: T; const ADefault: T): T;

    ///  <summary>Returns the last element.</summary>
    ///  <returns>The last element in collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Last(): T;

    ///  <summary>Returns the last element or a default if the collection is empty.</summary>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>The last element in collection if the collection is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function LastOrDefault(const ADefault: T): T;

    ///  <summary>Aggregates a value based on the collection's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <returns>A value that contains the collection's aggregated value.</returns>
    ///  <remarks>This method returns the first element if the collection only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Aggregate(const AAggregator: TFunc<T, T, T>): T;

    ///  <summary>Aggregates a value based on the collection's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>A value that contains the collection's aggregated value. If the collection is empty, <paramref name="ADefault"/> is returned.</returns>
    ///  <remarks>This method returns the first element if the collection only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    function AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <returns>The element from the specified position.</returns>
    ///  <remarks>This method is slow for collections that cannot reference their elements by indexes; for example: linked lists</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function ElementAt(const AIndex: NativeUInt): T;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>The element from the specified position if the collection is not empty and the position is not out of bounds; otherwise
    ///  the value of <paramref name="ADefault"/> is returned.</returns>
    ///  <remarks>This method is slow for collections that cannot reference their elements by indexes; for example: linked lists</remarks>
    function ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T;

    ///  <summary>Check whether at least one element in the collection satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if the at least one element satisfies a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole collection and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>True</c>. The logical equivalent of this operation is "OR".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Any(const APredicate: TFunc<T, Boolean>): Boolean;

    ///  <summary>Checks that all elements in the collection satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if all elements satisfy a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole collection and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>False</c>. The logical equivalent of this operation is "AND".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function All(const APredicate: TFunc<T, Boolean>): Boolean;

    ///  <summary>Selects only the elements that satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Where(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Selects only the elements that do not satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the elements that do not satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function WhereNot(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are less than a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereLower(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are less than or equal to a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereLowerOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are greater than a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereGreater(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereGreaterOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements whose values are contained whithin a given interval.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The upper bound.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    ///  <remarks>The elements that are equal to the lower or upper bounds, are also included.</remarks>
    function WhereBetween(const ALower, AHigher: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection excluding duplicates.</summary>
    ///  <returns>A new collection that contains the distinct elements.</returns>
    function Distinct(): IEnexCollection<T>;

    ///  <summary>Returns a new ordered collection that contains the elements from this collection.</summary>
    ///  <param name="AAscending">Specifies whether the elements are ordered ascending or descending.</param>
    ///  <returns>A new ordered collection.</returns>
    function Ordered(const AAscending: Boolean = true): IEnexCollection<T>; overload;

    ///  <summary>Returns a new ordered collection that contains the elements from this collection.</summary>
    ///  <param name="ASortProc">The comparison method.</param>
    ///  <returns>A new ordered collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASortProc"/> is <c>nil</c>.</exception>
    function Ordered(const ASortProc: TCompareOverride<T>): IEnexCollection<T>; overload;

    ///  <summary>Revereses the contents of the collection.</summary>
    ///  <returns>A new collection that contains the elements from this collection but in reverse order.</returns>
    function Reversed(): IEnexCollection<T>;

    ///  <summary>Concatenates this collection with another collection.</summary>
    ///  <param name="ACollection">A collection to concatenate.</param>
    ///  <returns>A new collection that contains the elements from this collection followed by elements
    ///  from the given collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Concat(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Creates a new collection that contains the elements from both collections taken a single time.</summary>
    ///  <param name="ACollection">The collection to unify with.</param>
    ///  <returns>A new collection that contains the elements from this collection followed by elements
    ///  from the given collection except the elements that already are present in this collection. This operation can be seen as
    ///  a "concat" operation followed by a "distinct" operation. </returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Union(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Creates a new collection that contains the elements from this collection minus the ones in the given collection.</summary>
    ///  <param name="ACollection">The collection to exclude.</param>
    ///  <returns>A new collection that contains the elements from this collection minus the those elements that are common between
    ///  this and the given collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Exclude(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Creates a new collection that contains the elements that are present in both collections.</summary>
    ///  <param name="ACollection">The collection to interset with.</param>
    ///  <returns>A new collection that contains the elements that are common to both collections.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Intersect(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Select the elements that whose indexed are located in the given range.</summary>
    ///  <param name="AStart">The lower bound.</param>
    ///  <param name="AEnd">The upper bound.</param>
    ///  <returns>A new collection that contains the elements whose indexes in this collection are locate between <paramref name="AStart"/>
    ///  and <paramref name="AEnd"/>. Note that this method does not check the indexes. This means that a bad combination of parameters will
    ///  simply result in an empty or incorrect result.</returns>
    function Range(const AStart, AEnd: NativeUInt): IEnexCollection<T>;

    ///  <summary>Selects only a given amount of elements.</summary>
    ///  <param name="ACount">The number of elements to select.</param>
    ///  <returns>A new collection that contains only the first <paramref name="ACount"/> elements.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ACount"/> is zero.</exception>
    function Take(const ACount: NativeUInt): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while a given rule is satisfied.</summary>
    ///  <param name="APredicate">The rule to satisfy.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function TakeWhile(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are lower than a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileLower(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are lower than
    ///  or equals to a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileLowerOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are greater than
    ///  a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileGreater(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are greater than
    ///  or equals to a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileGreaterOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are between a given range of values.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileBetween(const ALower, AHigher: T): IEnexCollection<T>;

    ///  <summary>Skips a given amount of elements.</summary>
    ///  <param name="ACount">The number of elements to skip.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ACount"/> is zero.</exception>
    function Skip(const ACount: NativeUInt): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while a given rule is satisfied.</summary>
    ///  <param name="APredicate">The rule to satisfy.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function SkipWhile(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are lower than a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileLower(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are lower than or equal to a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileLowerOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are greater than a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileGreater(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileGreaterOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are between a given range of values.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileBetween(const ALower, AHigher: T): IEnexCollection<T>;

    ///  <summary>Exposes a type that provides extended Enex operations such as "select" or "cast".</summary>
    ///  <returns>A record that exposes more Enex operations that otherwise would be impossible.</returns>
    function Op: TEnexExtOps<T>;
  end;

  ///  <summary>The Enex interface implemented in collections that allow indexed element access.</summary>
  ///  <remarks>This interface is inherited by other more specific interfaces such as lists. Indexed collections
  ///  allow their elements to be accesed given a numeric index.</remarks>
  IEnexIndexedCollection<T> = interface(IEnexCollection<T>)
    ///  <summary>Returns the item from a given index.</summary>
    ///  <param name="AIndex">The index in the collection.</param>
    ///  <returns>The element at the specified position.</returns>
    ///  <remarks>This method is similar to <c>ElementAt</c>. The only difference is that this method is guaranteed
    ///  to provide the fastest lookup (normally <c>ElementAt</c> should also use the same method in indexed collections).</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function GetItem(const AIndex: NativeUInt): T;

    ///  <summary>Returns the item from a given index.</summary>
    ///  <param name="AIndex">The index in the collection.</param>
    ///  <returns>The element at the specified position.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    property Items[const AIndex: NativeUInt]: T read GetItem; default;
  end;

  ///  <summary>Base Enex (Extended enumerable) interface inherited by all specific associative collection interfaces.</summary>
  ///  <remarks>This interface defines a set of traits common to all associative collections implemented in DeHL. It also introduces
  ///  a large se of extended operations that can pe performed on any collection that supports enumerability.</remarks>
  IEnexAssociativeCollection<TKey, TValue> = interface(ICollection<KVPair<TKey, TValue>>)
    ///  <summary>Creates a new dictionary containing the elements of this collection.</summary>
    ///  <returns>A dictionary containing the elements copied from this collection.</returns>
    ///  <remarks>This method also copies the type objects of this collection. Be careful if the type object
    ///  performs cleanup on the elements.</remarks>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The collection contains more than
    ///  one key-value pair with the same key.</exception>
    function ToDictionary(): IDictionary<TKey, TValue>;

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to return the associated value.</param>
    ///  <returns>The value associated with the given key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">No such key in the collection.</exception>
    function ValueForKey(const AKey: TKey): TValue;

    ///  <summary>Checks whether the collection contains a given key-value pair.</summary>
    ///  <param name="AKey">The key part of the pair.</param>
    ///  <param name="AValue">The value part of the pair.</param>
    ///  <returns><c>True</c> if the given key-value pair exists; <c>False</c> otherwise.</returns>
    function KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean;

    ///  <summary>Returns the biggest key.</summary>
    ///  <returns>The biggest key stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MaxKey(): TKey;

    ///  <summary>Returns the smallest key.</summary>
    ///  <returns>The smallest key stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MinKey(): TKey;

    ///  <summary>Returns the biggest value.</summary>
    ///  <returns>The biggest value stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MaxValue(): TValue;

    ///  <summary>Returns the smallest value.</summary>
    ///  <returns>The smallest value stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MinValue(): TValue;

    ///  <summary>Returns an Enex collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the collection.</returns>
    function SelectKeys(): IEnexCollection<TKey>;

    ///  <summary>Returns a Enex collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the collection.</returns>
    function SelectValues(): IEnexCollection<TValue>;

    ///  <summary>Specifies the collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the collection.</returns>
    property Keys: IEnexCollection<TKey> read SelectKeys;

    ///  <summary>Specifies the collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the collection.</returns>
    property Values: IEnexCollection<TValue> read SelectValues;

    ///  <summary>Selects all the key-value pairs from the collection excluding the duplicates by key.</summary>
    ///  <returns>A new collection that contains the distinct pairs.</returns>
    function DistinctByKeys(): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects all the key-value pairs from the collection excluding the duplicates by value.</summary>
    ///  <returns>A new collection that contains the distinct pairs.</returns>
    function DistinctByValues(): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Checks whether this collection includes the key-value pairs in another collection.</summary>
    ///  <param name="ACollection">The collection to check against.</param>
    ///  <returns><c>True</c> if this collection includes the elements in another; <c>False</c> otherwise.</returns>
    function Includes(const ACollection: IEnumerable<KVPair<TKey, TValue>>): Boolean;

    ///  <summary>Selects only the key-value pairs that satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Where(const APredicate: TFunc<TKey, TValue, Boolean>): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs that do not satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the pairs that do not satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function WhereNot(const APredicate: TFunc<TKey, TValue, Boolean>): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are less than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyLower(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are less than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyLowerOrEqual(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are greater than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyGreater(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyGreaterOrEqual(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are are contained whithin a given interval.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The upper bound.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyBetween(const ALower, AHigher: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are less than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueLower(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are less than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueLowerOrEqual(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are greater than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueGreater(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueGreaterOrEqual(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are are contained whithin a given interval.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The upper bound.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueBetween(const ALower, AHigher: TValue): IEnexAssociativeCollection<TKey, TValue>;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>stack</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>stack</c>.</remarks>
  IStack<T> = interface(IEnexCollection<T>)
    ///  <summary>Clears the contents of the stack.</summary>
    ///  <remarks>This method clears the stack and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Pushes an element to the top of the stack.</summary>
    ///  <param name="AValue">The value to push.</param>
    procedure Push(const AValue: T);

    ///  <summary>Retreives the element from the top of the stack.</summary>
    ///  <returns>The value at the top of the stack.</returns>
    ///  <remarks>This method removes the element from the top of the stack.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Pop(): T;

    ///  <summary>Reads the element from the top of the stack.</summary>
    ///  <returns>The value at the top of the stack.</returns>
    ///  <remarks>This method does not remove the element from the top of the stack. It merely reads it's value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The stack is empty.</exception>
    function Peek(): T;

    ///  <summary>Removes an element from the stack.</summary>
    ///  <param name="AValue">The value to remove. If there is no such element in the stack, nothing happens.</param>
    procedure Remove(const AValue: T);

    ///  <summary>Checks whether the stack contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the stack; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>queue</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>queue</c>.</remarks>
  IQueue<T> = interface(IEnexCollection<T>)
    ///  <summary>Clears the contents of the queue.</summary>
    ///  <remarks>This method clears the queue and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Appends an element to the top of the queue.</summary>
    ///  <param name="AValue">The value to append.</param>
    procedure Enqueue(const AValue: T);

    ///  <summary>Retreives the element from the bottom of the queue.</summary>
    ///  <returns>The value at the bottom of the queue.</returns>
    ///  <remarks>This method removes the element from the bottom of the queue.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Dequeue(): T;

    ///  <summary>Reads the element from the bottom of the queue.</summary>
    ///  <returns>The value at the bottom of the queue.</returns>
    ///  <remarks>This method does not remove the element from the bottom of the queue. It merely reads it's value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Peek(): T;

    ///  <summary>Checks whether the queue contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the queue; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>priority queue</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>priority queue</c>.</remarks>
  IPriorityQueue<TPriority, TValue> = interface(IEnexAssociativeCollection<TPriority, TValue>)
    ///  <summary>Clears the contents of the priority queue.</summary>
    ///  <remarks>This method clears the priority queue and invokes type object's cleaning routines for each key and value.</remarks>
    procedure Clear();

    ///  <summary>Adds an element to the priority queue.</summary>
    ///  <param name="AValue">The value to append.</param>
    ///  <remarks>The lowest possible priority of the element is assumed. This means that the element is appended to the top of the queue.</remarks>
    procedure Enqueue(const AValue: TValue); overload;

    ///  <summary>Adds an element to the priority queue.</summary>
    ///  <param name="AValue">The value to add.</param>
    ///  <param name="APriority">The priority of the value.</param>
    ///  <remarks>The given priority is used to calculate the position of the value in the queue. Based on the priority the element might occupy any
    ///  given position (for example it might even end up at the bottom position).</remarks>
    procedure Enqueue(const AValue: TValue; const APriority: TPriority); overload;

    ///  <summary>Retreives the element from the bottom of the priority queue.</summary>
    ///  <returns>The value at the bottom of the priority queue.</returns>
    ///  <remarks>This method removes the element from the bottom of the priority queue.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Dequeue(): TValue;

    ///  <summary>Reads the element from the bottom of the priority queue.</summary>
    ///  <returns>The value at the bottom of the priority queue.</returns>
    ///  <remarks>This method does not remove the element from the bottom of the priority queue. It merely reads it's value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The queue is empty.</exception>
    function Peek(): TValue;

    ///  <summary>Checks whether the priority queue contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the queue; <c>False</c> otherwise.</returns>
    function Contains(const AValue: TValue): Boolean;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>set</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>set</c>.</remarks>
  ISet<T> = interface(IEnexCollection<T>)
    ///  <summary>Clears the contents of the set.</summary>
    ///  <remarks>This method clears the set and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Adds an element to the set.</summary>
    ///  <param name="AValue">The value to add.</param>
    ///  <remarks>If the set already contains the given value, nothing happens.</remarks>
    procedure Add(const AValue: T);

    ///  <summary>Removes a given value from the set.</summary>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>If the set does not contain the given value, nothing happens.</remarks>
    procedure Remove(const AValue: T);

    ///  <summary>Checks whether the set contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the set; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>bag</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>bag</c>.</remarks>
  IBag<T> = interface(IEnexCollection<T>)
    ///  <summary>Clears the contents of the bag.</summary>
    ///  <remarks>This method clears the bag and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Adds an element to the bag.</summary>
    ///  <param name="AValue">The element to add.</param>
    ///  <param name="AWeight">The weight of the element.</param>
    ///  <remarks>If the bag already contains the given value, it's stored weight is incremented to by <paramref name="AWeight"/>.
    ///  If the value of <paramref name="AWeight"/> is zero, nothing happens.</remarks>
    procedure Add(const AValue: T; const AWeight: NativeUInt = 1);

    ///  <summary>Removes an element from the bag.</summary>
    ///  <param name="AValue">The value to remove.</param>
    ///  <param name="AWeight">The weight to remove.</param>
    ///  <remarks>This method decreses the weight of the stored item by <paramref name="AWeight"/>. If the resulting weight is less
    ///  than zero or zero, the element is removed for the bag. If <paramref name="AWeight"/> is zero, nothing happens.</remarks>
    procedure Remove(const AValue: T; const AWeight: NativeUInt = 1);

    ///  <summary>Removes an element from the bag.</summary>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>This method completely removes an item from the bag ignoring it's stored weight. Nothing happens if the given value
    ///  is not in the bag to begin with.</remarks>
    procedure RemoveAll(const AValue: T);

    ///  <summary>Checks whether the bag contains an element with at least the required weight.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <param name="AWeight">The smallest allowed weight.</param>
    ///  <returns><c>True</c> if the condition is met; <c>False</c> otherwise.</returns>
    ///  <remarks>This method checks whether the bag contains the given value and that the contained value has at least the
    ///  given weight.</remarks>
    function Contains(const AValue: T; const AWeight: NativeUInt = 1): Boolean;

    ///  <summary>Returns the weight of an element.</param>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns>The weight of the value.</returns>
    ///  <remarks>If the value is not found in the bag, zero is returned.</remarks>
    function GetWeight(const AValue: T): NativeUInt;

    ///  <summary>Sets the weight of an element.</param>
    ///  <param name="AValue">The value to set the weight for.</param>
    ///  <param name="AWeight">The new weight.</param>
    ///  <remarks>If the value is not found in the bag, this method acts like an <c>Add</c> operation; otherwise
    ///  the weight of the stored item is adjusted.</remarks>
    procedure SetWeight(const AValue: T; const AWeight: NativeUInt);

    ///  <summary>Sets or gets the weight of an item in the bag.</summary>
    ///  <param name="AValue">The value.</param>
    ///  <remarks>If the value is not found in the bag, this method acts like an <c>Add</c> operation; otherwise
    ///  the weight of the stored item is adjusted.</remarks>
    property Weights[const AValue: T]: NativeUInt read GetWeight write SetWeight; default;
  end;

  ///  <summary>The Enex interface that defines the basic behavior of all <c>map</c>-like collections.</summary>
  ///  <remarks>This interface is inherited by all DeHL interfaces that provide <c>map</c>-like functionality.</remarks>
  IMap<TKey, TValue> = interface(IEnexAssociativeCollection<TKey, TValue>)
    ///  <summary>Clears the contents of the map.</summary>
    ///  <remarks>This method clears the map and invokes type object's cleaning routines for key and value.</remarks>
    procedure Clear();

{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    ///  <summary>Adds a key-value pair to the map.</summary>
    ///  <param name="APair">The key-value pair to add.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The map already contains a pair with the given key.</exception>
    procedure Add(const APair: KVPair<TKey, TValue>); overload;
{$ENDIF}

    ///  <summary>Adds a key-value pair to the map.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The map already contains a pair with the given key.</exception>
    procedure Add(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value pair using a given key.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <remarks>This invokes type object's cleaning routines for value
    ///  associated with the key. If the specified key was not found in the map, nothing happens.</remarks>
    procedure Remove(const AKey: TKey);

    ///  <summary>Checks whether the map contains a key-value pair identified by the given key.</summary>
    ///  <param name="AKey">The key to check for.</param>
    ///  <returns><c>True</c> if the map contains a pair identified by the given key; <c>False</c> otherwise.</returns>
    function ContainsKey(const AKey: TKey): Boolean;

    ///  <summary>Checks whether the map contains a key-value pair that contains a given value.</summary>
    ///  <param name="AValue">The value to check for.</param>
    ///  <returns><c>True</c> if the map contains a pair containing the given value; <c>False</c> otherwise.</returns>
    ///  <remarks>This operation should be avoided. Its perfomance is poor is most map implementations.</remarks>
    function ContainsValue(const AValue: TValue): Boolean;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>dictionary</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>dictionary</c>.</remarks>
  IDictionary<TKey, TValue> = interface(IMap<TKey, TValue>)
    ///  <summary>Tries to obtain the value associated with a given key.</summary>
    ///  <param name="AKey">The key for which to try to retreive the value.</param>
    ///  <param name="AFoundValue">The found value (if the result is <c>True</c>).</param>
    ///  <returns><c>True</c> if the dictionary contains a value for the given key; <c>False</c> otherwise.</returns>
    function TryGetValue(const AKey: TKey; out AFoundValue: TValue): Boolean;

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to try to retreive the value.</param>
    ///  <returns>The value associated with the key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the dictionary.</exception>
    function GetItem(const AKey: TKey): TValue;

    ///  <summary>Sets the value for a given key.</summary>
    ///  <param name="AKey">The key for which to set the value.</param>
    ///  <param name="AValue">The value to set.</param>
    ///  <remarks>If the dictionary does not contain the key, this method acts like <c>Add</c>; otherwise the
    ///  value of the specified key is modified.</remarks>
    procedure SetItem(const AKey: TKey; const AValue: TValue);

    ///  <summary>Gets or sets the value for a given key.</summary>
    ///  <param name="AKey">The key for to operate on.</param>
    ///  <returns>The value associated with the key.</returns>
    ///  <remarks>If the dictionary does not contain the key, this method acts like <c>Add</c> if assignment is done to this property;
    ///  otherwise the value of the specified key is modified.</remarks>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The trying to read the value of a key that is
    ///  not found in the dictionary.</exception>
    property Items[const AKey: TKey]: TValue read GetItem write SetItem; default;
  end;

  ///  <summary>The Enex interface that defines the basic behavior of all <c>map</c>-like collections that associate a
  ///  key with multiple values.</summary>
  ///  <remarks>This interface is inherited by all DeHL interfaces that provide <c>multi-map</c>-like functionality.</remarks>
  ICollectionMap<TKey, TValue> = interface(IMap<TKey, TValue>)

    ///  <summary>Removes a key-value pair using a given key and value.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>A multi-map allows storing multiple values for a given key. This method allows removing only the
    ///  specified value from the collection of values associated with the given key.</remarks>
    procedure Remove(const AKey: TKey; const AValue: TValue); overload;

{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    ///  <summary>Removes a key-value pair using a given key and value.</summary>
    ///  <param name="APair">The key and its associated value to remove.</param>
    ///  <remarks>A multi-map allows storing multiple values for a given key. This method allows removing only the
    ///  specified value from the collection of values associated with the given key.</remarks>
    procedure Remove(const APair: KVPair<TKey, TValue>); overload;
{$ENDIF}

    ///  <summary>Checks whether the multi-map contains a given key-value combination.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsValue(const AKey: TKey; const AValue: TValue): Boolean; overload;

{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    ///  <summary>Checks whether the multi-map contains a given key-value combination.</summary>
    ///  <param name="APair">The key-value pair to check for.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsValue(const APair: KVPair<TKey, TValue>): Boolean; overload;
{$ENDIF}
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>bidirectional multi-map</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>bidirectional multi-map</c>. In a
  ///  <c>bidirectional multi-map</c>, both the key and the value are treated as "keys".</remarks>
  IBidiMap<TKey, TValue> = interface(IMap<TKey, TValue>)
    ///  <summary>Removes a key-value pair using a given key.</summary>
    ///  <param name="AKey">The key (and its associated values) to remove.</param>
    ///  <remarks>This method removes all the values that are associated with the given key. The type object's cleanup
    ///  routines are used to cleanup the values that are dropped from the map.</remarks>
    procedure RemoveKey(const AKey: TKey);

    ///  <summary>Removes a key-value pair using a given value.</summary>
    ///  <param name="AValue">The value (and its associated keys) to remove.</param>
    ///  <remarks>This method removes all the keys that are associated with the given value. The type object's cleanup
    ///  routines are used to cleanup the keys that are dropped from the map.</remarks>
    procedure RemoveValue(const AValue: TValue);

    ///  <summary>Removes a specific key-value combination.</summary>
    ///  <param name="AKey">The key to remove.</param>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>This method only remove a key-value combination if that combination actually exists in the dictionary.
    ///  If the key is associated with another value, nothing happens.</remarks>
    procedure Remove(const AKey: TKey; const AValue: TValue); overload;

{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    ///  <summary>Removes a key-value combination.</summary>
    ///  <param name="APair">The pair to remove.</param>
    ///  <remarks>This method only remove a key-value combination if that combination actually exists in the dictionary.
    ///  If the key is associated with another value, nothing happens.</remarks>
    procedure Remove(const APair: KVPair<TKey, TValue>); overload;
{$ENDIF}

    ///  <summary>Checks whether the map contains the given key-value combination.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsPair(const AKey: TKey; const AValue: TValue): Boolean; overload;

{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    ///  <summary>Checks whether the map contains a given key-value combination.</summary>
    ///  <param name="APair">The key-value pair combination.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsPair(const APair: KVPair<TKey, TValue>): Boolean; overload;
{$ENDIF}

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    function GetValueList(const AKey: TKey): IEnexCollection<TValue>;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    property ByKeys[const AKey: TKey]: IEnexCollection<TValue> read GetValueList;

    ///  <summary>Returns the collection of keys associated with a value.</summary>
    ///  <param name="AValue">The value for which to obtain the associated keys.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The value is not found in the collection.</exception>
    function GetKeyList(const AValue: TValue): IEnexCollection<TKey>;

    ///  <summary>Returns the collection of keys associated with a value.</summary>
    ///  <param name="AValue">The value for which to obtain the associated keys.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The value is not found in the collection.</exception>
    property ByValues[const AValue: TValue]: IEnexCollection<TKey> read GetKeyList;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>multi-map</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>multi-map</c>. In a
  ///  <c>multi-map</c>, a key is associated with multiple values, not just one.</remarks>
  IMultiMap<TKey, TValue> = interface(ICollectionMap<TKey, TValue>)
    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    function GetItemList(const AKey: TKey): IEnexIndexedCollection<TValue>;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    property Items[const AKey: TKey]: IEnexIndexedCollection<TValue> read GetItemList; default;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <param name="AValues">The Enex collection that stores the associated values.</param>
    ///  <returns><c>True</c> if the key exists in the collection; <c>False</c> otherwise;</returns>
    function TryGetValues(const AKey: TKey; out AValues: IEnexIndexedCollection<TValue>): Boolean; overload;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>The associated collection if the key if valid; an empty collection otherwise.</returns>
    function TryGetValues(const AKey: TKey): IEnexIndexedCollection<TValue>; overload;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>distinct multi-map</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>distinct multi-map</c>. In a
  ///  <c>dictinct multi-map</c>, a key is associated with multiple distinct values.</remarks>
  IDistinctMultiMap<TKey, TValue> = interface(ICollectionMap<TKey, TValue>)
    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    function GetItemList(const Key: TKey): IEnexCollection<TValue>;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    property Items[const Key: TKey]: IEnexCollection<TValue> read GetItemList; default;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <param name="AValues">The Enex collection that stores the associated values.</param>
    ///  <returns><c>True</c> if the key exists in the collection; <c>False</c> otherwise;</returns>
    function TryGetValues(const AKey: TKey; out AValues: IEnexCollection<TValue>): Boolean; overload;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>The associated collection if the key if valid; an empty collection otherwise.</returns>
    function TryGetValues(const AKey: TKey): IEnexCollection<TValue>; overload;
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>list</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>list</c>.</remarks>
  IList<T> = interface(IEnexIndexedCollection<T>)
    ///  <summary>Clears the contents of the list.</summary>
    ///  <remarks>This method clears the set and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Appends an element to the list.</summary>
    ///  <param name="AValue">The value to append.</param>
    procedure Add(const AValue: T); overload;

    ///  <summary>Appends the elements from a collection to the list.</summary>
    ///  <param name="ACollection">The values to append.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    procedure Add(const ACollection: IEnumerable<T>); overload;

    ///  <summary>Checks whether the list contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the list; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;

    ///  <summary>Removes an element from the list at a given index.</summary>
    ///  <param name="AIndex">The index from which to remove the element.</param>
    ///  <remarks>This method removes the specified element and moves all following elements to the left by one.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    procedure RemoveAt(const AIndex: NativeUInt);

    ///  <summary>Removes a given value from the list.</summary>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>If the list does not contain the given value, nothing happens.</remarks>
    procedure Remove(const AValue: T);

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
  end;

  ///  <summary>The Enex interface that defines the behavior of an <c>unordered list</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of an <c>unordered list</c>.</remarks>
  IUnorderedList<T> = interface(IList<T>)
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
  end;

  ///  <summary>The Enex interface that defines the behavior of a <c>sorted list</c>.</summary>
  ///  <remarks>This interface is implemented by all DeHL collections that provide the functionality of a <c>sorted list</c>.
  ///  A <c>sorted list</c> maintains its elements in an ordered fashion at all times. Whenever a new element is added, it is
  ///  automatically inserted in the right position.</remarks>
  IOrderedList<T> = interface(IList<T>)
    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the list considered to have the biggest value. This is either the
    ///  last or the first element (depending on the sorting order).</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Max(): T;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the list considered to have the smallest value. This is either the
    ///  last or the first element (depending on the sorting order).</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Min(): T;
  end;

  ///  <summary>A special interface implemented by collections that support the concept of capacity.</summary>
  ///  <remarks>This interface specifies a set of method that allow controlling the capactity of a collection.</remarks>
  IDynamic = interface
    ///  <summary>Returns the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the collection can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this method is greater or equal to the amount of elements in the collection. If this value
    ///  if greater then the number of elements, it means that the collection has some extra capacity to operate upon.</remarks>
    function GetCapacity(): NativeUInt;

    ///  <summary>Removes the excess capacity from the collection.</summary>
    ///  <remarks>This method can be called manually to force the collection to drop the extra capacity it might hold. For example,
    ///  after performing some massive operations of a big list, call this method to ensure that all extra memory held by the
    ///  collection is released.</remarks>
    procedure Shrink();

    ///  <summary>Forces the collection to increase its capacity.</summary>
    ///  <remarks>Call this method to force the collection to increase its capacity ahead of time. Manually adjusting the capacity
    ///  can be useful in certain situations. Each collection specifies its "growing" strategy. Most collections grow by a factor of two
    ///  <c>(New Capacity = Old Capacity * 2)</c>.</remarks>
    procedure Grow();

    ///  <summary>Specifies the current capacity.</summary>
    ///  <returns>A positive number that specifies the number of elements that the collection can hold before it
    ///  needs to grow again.</returns>
    ///  <remarks>The value of this property is greater or equal to the amount of elements in the collection. If this value
    ///  if greater then the number of elements, it means that the collection has some extra capacity to operate upon.</remarks>
    property Capacity: NativeUInt read GetCapacity;
  end;
{$ENDREGION}

{$REGION 'Base Collection Classes'}
type
  ///  <summary>Base class for all Enex enumerator objects.</summary>
  ///  <remarks>All Enex collection are expected to provide enumerators that derive from
  ///  this class.</remarks>
  TEnumerator<T> = class abstract(TRefCountedObject, IEnumerator<T>)
    ///  <summary>Returns the current element of the enumerated collection.</summary>
    ///  <remarks>This method is the getter for <c>Current</c> property. Use the property to obtain the element instead.</remarks>
    ///  <returns>The current element of the enumerated collection.</returns>
    function GetCurrent(): T; virtual; abstract;

    ///  <summary>Moves the enumerator to the next element of collection.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to move the "pointer" to the next element in
    ///  the collection (if there are elements left). Also note that many specific enumerator implementations may throw various
    ///  exceptions if the enumerated collection was changed while enumerating.</remarks>
    ///  <returns><c>True</c> if the enumerator succesefully selected the next element; <c>False</c> is there are
    ///  no more elements to be enumerated.</returns>
    function MoveNext(): Boolean; virtual; abstract;

    ///  <summary>Returns the current element of the enumerated collection.</summary>
    ///  <remarks>This property can only return a valid element if <c>MoveNext</c> was priorly called and returned <c>True</c>;
    ///  otherwise the behavior of this property is undefined.
    ///  </remarks>
    ///  <returns>The current element of the enumerated collection.</returns>
    property Current: T read GetCurrent;
  end;

  ///  <summary>Base class for all collections.</summary>
  ///  <remarks>All collections are derived from this base class. It implements most Enex operations based on
  ///  enumerability and introduces serialization support.</remarks>
  TCollection<T> = class abstract(TRefCountedObject, ISerializable, ICollection<T>, IEnumerable<T>)
  protected
    ///  <summary>Returns the number of elements in the collection.</summary>
    ///  <returns>A positive value specifying the number of elements in the collection.</returns>
    ///  <remarks>A call to this method can be costly because some
    ///  collections cannot detect the number of stored elements directly, resorting to enumerating themselves.</remarks>
    function GetCount(): NativeUInt; virtual;

    ///  <summary>Called when the serialization process is about to begin.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    ///  <remarks>Descendant classes are supposed to override this method even if no preparation is required. If this method remains
    ///  un-overridden, the serialization will fail.</remarks>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartSerializing(const AData: TSerializationData); virtual;

    ///  <summary>Called when the serialization process is about to end.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    ///  <remarks>Override this method in descending classes if any post-serialization steps are required.</remarks>
    procedure EndSerializing(const AData: TSerializationData); virtual;

    ///  <summary>Called when the deserialization process is about to begin.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <remarks>Descendant classes are supposed to override this method even if no preparation is required. If this method remains
    ///  un-overridden, the deserialization will fail.</remarks>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartDeserializing(const AData: TDeserializationData); virtual;

    ///  <summary>Called when the deserialization process is about to end.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <remarks>Override this method in descending classes if any post-deserialization steps are required.</remarks>
    procedure EndDeserializing(const AData: TDeserializationData); virtual;

    ///  <summary>Called when the the collection needs to serialize its contents.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    ///  <remarks>Descending classes need to override this method to actually provide code that serializes the contents of
    ///  the collection.</remarks>
    procedure Serialize(const AData: TSerializationData); virtual; abstract;

    ///  <summary>Called when the the collection needs to be deserialize its contents.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <remarks>Descending classes need to override this method to actually provide code that deserializes the contents of
    ///  the collection.</remarks>
    procedure Deserialize(const AData: TDeserializationData); virtual; abstract;
  public
    ///  <summary>Checks whether the collection is empty.</summary>
    ///  <returns><c>True</c> if the collection is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the collection is empty. It is optimized
    ///  in most collections to offer a fast response.</remarks>
    function Empty(): Boolean; virtual;

    ///  <summary>Returns the single element stored in the collection.</summary>
    ///  <returns>The element in collection.</returns>
    ///  <remarks>This method checks if the collection contains just one element, in which case it is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionNotOneException">There is more than one element in the collection.</exception>
    function Single(): T; virtual;

    ///  <summary>Returns the single element stored in the collection, or a default value.</summary>
    ///  <param name="ADefault">The default value returned if there is less or more elements in the collection.</param>
    ///  <returns>The element in the collection if the condition is satisfied; <paramref name="ADefault"/> is returned otherwise.</returns>
    ///  <remarks>This method checks if the collection contains just one element, in which case it is returned. Otherwise
    ///  the value in <paramref name="ADefault"/> is returned.</remarks>
    function SingleOrDefault(const ADefault: T): T; virtual;

    ///  <summary>Copies the values stored in the collection to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the collection.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T); overload;

    ///  <summary>Copies the values stored in the collection to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the collection.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the collection.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const AStartIndex: NativeUInt); overload; virtual;

    ///  <summary>Creates a new Delphi array with the contents of the collection.</summary>
    ///  <remarks>The length of the new array is equal to the value of <c>Count</c> property.</remarks>
    function ToArray(): TArray<T>; virtual;

    ///  <summary>Creates a new fixed array with the contents of the collection.</summary>
    ///  <remarks>The length of the new array is equal to the value of <c>Count</c> property.</remarks>
    function ToFixedArray(): TFixedArray<T>; virtual;

    ///  <summary>Creates a new dynamic array with the contents of the collection.</summary>
    ///  <remarks>The length of the new array is equal to the value of <c>Count</c> property.</remarks>
    function ToDynamicArray(): TDynamicArray<T>; virtual;

    ///  <summary>Returns a new enumerator object used to enumerate the collection.</summary>
    ///  <remarks>This method is usually called by compiler generated code. It's purpose is to create an enumerator
    ///  object that is used to actually traverse the collection.
    ///  Note that many collections generate enumerators that depend on the state of the collection. If the collection is changed
    ///  after the enumerator has been obtained, the enumerator is considered invalid. All subsequent operations on that enumerator
    ///  will throw exceptions.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<T>; virtual; abstract;

    ///  <summary>Specifies the number of elements in the collection.</summary>
    ///  <returns>A positive value specifying the number of elements in the collection.</returns>
    ///  <remarks>Accesing this property can be costly because some
    ///  collections cannot detect the number of stored elements directly, resorting to enumerating themselves.</remarks>
    property Count: NativeUInt read GetCount;
  end;

  ///  <summary>Base class for all non-associative Enex collections.</summary>
  ///  <remarks>All normal Enex collections (ex. list or stack) are derived from this base class.
  ///  It implements the extended Enex operations based on enumerability and introduces functional
  ///  serialization support.</remarks>
  TEnexCollection<T> = class abstract(TCollection<T>, IComparable, IEnexCollection<T>)
  private
    FElementType: IType<T>;

  protected
    ///  <summary>Specifies the type object that describes the stored elements.</summary>
    ///  <returns>A type object describing the stored elements.</returns>
    property ElementType: IType<T> read FElementType;

    ///  <summary>Installs the type object.</summary>
    ///  <param name="AType">The type object to install.</returns>
    ///  <remarks>This method stores a given type object. The passed type object is then used
    ///  by the collection to perform all required operation on the elements operated upon.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    procedure InstallType(const AType: IType<T>); virtual;

    ///  <summary>Called when the an element has been deserialized and needs to be inserted into the collection.</summary>
    ///  <param name="AElement">The element that was deserialized.</param>
    ///  <remarks>Derived collection classes need to implement this method to provide proper insertion mechanics
    ///  for the deserialized elements. For example, a simple list only needs to call the <c>Add</c> method for each
    ///  passed element.</remarks>
    procedure DeserializeElement(const AElement: T); virtual;

    ///  <summary>Called when the the collection needs to serialize its contents.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    ///  <remarks>This method is overridded and provides the default serialization support based on enumerability. To provide
    ///  an optimized serialization method, override this method (and <c>Deserialize</c>) in descending classes.</remarks>
    procedure Serialize(const AData: TSerializationData); override;

    ///  <summary>Called when the the collection needs to deserialize its contents.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <remarks>This method is overridded and provides the default deserialization support based on enumerability. To provide
    ///  an optimized deserialization method, override this method (and <c>Serialize</c>) in descending classes.</remarks>
    procedure Deserialize(const AData: TDeserializationData); override;
  public
    //TODO: doc me
    constructor Create();

    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the collection considered to have the biggest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Max(): T; virtual;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the collection considered to have the smallest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Min(): T; virtual;

    ///  <summary>Returns the first element.</summary>
    ///  <returns>The first element in collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function First(): T; virtual;

    ///  <summary>Returns the first element or a default if the collection is empty.</summary>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>The first element in collection if the collection is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function FirstOrDefault(const ADefault: T): T; virtual;

    ///  <summary>Returns the first element that satisfies the given predicate.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <returns>The first element that satisfies the given predicate.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the predicate.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhere(const APredicate: TFunc<T, Boolean>): T; virtual;

    ///  <summary>Returns the first element that satisfies the given predicate or a default value.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given predicate; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhereOrDefault(const APredicate: TFunc<T, Boolean>; const ADefault: T): T; virtual;

    ///  <summary>Returns the first element that does not satisfy the given predicate.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <returns>The first element that does not satisfy the given predicate.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements that do not satisfy the predicate.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhereNot(const APredicate: TFunc<T, Boolean>): T;

    ///  <summary>Returns the first element that does not satisfy the given predicate or a default value.</summary>
    ///  <param name="APredicate">The predicate to use.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that does not satisfy the given predicate; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function FirstWhereNotOrDefault(const APredicate: TFunc<T, Boolean>; const ADefault: T): T;

    ///  <summary>Returns the first element lower than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLower(const ABound: T): T;

    ///  <summary>Returns the first element lower than a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLowerOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element lower than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLowerOrEqual(const ABound: T): T;

    ///  <summary>Returns the first element lower than or equal to a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereLowerOrEqualOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element greater than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreater(const ABound: T): T;

    ///  <summary>Returns the first element greater than a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreaterOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreaterOrEqual(const ABound: T): T;

    ///  <summary>Returns the first element greater than or equal to a given value or a default.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereGreaterOrEqualOrDefault(const ABound: T; const ADefault: T): T;

    ///  <summary>Returns the first element situated within the given bounds.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <returns>The first element that satisfies the given condition.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereBetween(const ALower, AHigher: T): T;

    ///  <summary>Returns the first element situated within the given bounds or a default.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <param name="ADefault">The default value.</param>
    ///  <returns>The first element that satisfies the given condition; or <paramref name="ADefault"/> otherwise.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionFilteredEmptyException">No elements satisfy the condition.</exception>
    function FirstWhereBetweenOrDefault(const ALower, AHigher: T; const ADefault: T): T;

    ///  <summary>Returns the last element.</summary>
    ///  <returns>The last element in collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Last(): T; virtual;

    ///  <summary>Returns the last element or a default if the collection is empty.</summary>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>The last element in collection if the collection is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function LastOrDefault(const ADefault: T): T; virtual;

    ///  <summary>Aggregates a value based on the collection's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <returns>A value that contains the collection's aggregated value.</returns>
    ///  <remarks>This method returns the first element if the collection only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function Aggregate(const AAggregator: TFunc<T, T, T>): T; virtual;

    ///  <summary>Aggregates a value based on the collection's elements.</summary>
    ///  <param name="AAggregator">The aggregator method.</param>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>A value that contains the collection's aggregated value. If the collection is empty, <paramref name="ADefault"/> is returned.</returns>
    ///  <remarks>This method returns the first element if the collection only has one element. Otherwise,
    ///  <paramref name="AAggregator"/> is invoked for each two elements (first and second; then the result of the first two
    ///  and the third, and so on). The simples example of aggregation is the "sum" operation where you can obtain the sum of all
    ///  elements in the value.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AAggregator"/> is <c>nil</c>.</exception>
    function AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T; virtual;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <returns>The element from the specified position.</returns>
    ///  <remarks>This method is slow for collections that cannot reference their elements by indexes; for example: linked lists</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    function ElementAt(const AIndex: NativeUInt): T; virtual;

    ///  <summary>Returns the element at a given position.</summary>
    ///  <param name="AIndex">The index from which to return the element.</param>
    ///  <param name="ADefault">The default value returned if the collection is empty.</param>
    ///  <returns>The element from the specified position if the collection is not empty and the position is not out of bounds; otherwise
    ///  the value of <paramref name="ADefault"/> is returned.</returns>
    ///  <remarks>This method is slow for collections that cannot reference their elements by indexes; for example: linked lists</remarks>
    function ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T; virtual;

    ///  <summary>Check whether at least one element in the collection satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if the at least one element satisfies a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole collection and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>True</c>. The logical equivalent of this operation is "OR".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; virtual;

    ///  <summary>Checks that all elements in the collection satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if all elements satisfy a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole collection and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>False</c>. The logical equivalent of this operation is "AND".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function All(const APredicate: TFunc<T, Boolean>): Boolean; virtual;

    ///  <summary>Checks whether the elements in this collections are equal to the elements in another collection.</summary>
    ///  <param name="ACollection">The collection to compare to.</param>
    ///  <returns><c>True</c> if the collections are equal; <c>False</c> if the collections are different.</returns>
    ///  <remarks>This methods checks that each element at position X in this collection is equal to an element at position X in
    ///  the provided collection. If the number of elements in both collections are different, then the collections are considered different.
    ///  Note that comparison of element is done using the type object used by this collection. This means that comparing this collection
    ///  to another one might yeild a different result than comparing the other collection to this one.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function EqualsTo(const ACollection: IEnumerable<T>): Boolean; virtual;

    ///  <summary>Selects only the elements that satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Where(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Selects only the elements that do not satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the elements that do not satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function WhereNot(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are less than a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereLower(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are less than or equal to a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereLowerOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are greater than a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereGreater(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements that are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The element to compare against.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    function WhereGreaterOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects only the elements whose values are contained whithin a given interval.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The upper bound.</param>
    ///  <returns>A new collection that contains only the elements that satisfy the relationship.</returns>
    ///  <remarks>The elements that are equal to the lower or upper bounds, are also included.</remarks>
    function WhereBetween(const ALower, AHigher: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection excluding duplicates.</summary>
    ///  <returns>A new collection that contains the distinct elements.</returns>
    function Distinct(): IEnexCollection<T>; virtual;

    ///  <summary>Returns a new ordered collection that contains the elements from this collection.</summary>
    ///  <param name="AAscending">Specifies whether the elements are ordered ascending or descending.</param>
    ///  <returns>A new ordered collection.</returns>
    function Ordered(const AAscending: Boolean = true): IEnexCollection<T>; overload; virtual;

    ///  <summary>Returns a new ordered collection that contains the elements from this collection.</summary>
    ///  <param name="ASortProc">The comparison method.</param>
    ///  <returns>A new ordered collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ASortProc"/> is <c>nil</c>.</exception>
    function Ordered(const ASortProc: TCompareOverride<T>): IEnexCollection<T>; overload; virtual;

    ///  <summary>Revereses the contents of the collection.</summary>
    ///  <returns>A new collection that contains the elements from this collection but in reverse order.</returns>
    function Reversed(): IEnexCollection<T>; virtual;

    ///  <summary>Concatenates this collection with another collection.</summary>
    ///  <param name="ACollection">A collection to concatenate.</param>
    ///  <returns>A new collection that contains the elements from this collection followed by elements
    ///  from the given collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Concat(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Creates a new collection that contains the elements from both collections taken a single time.</summary>
    ///  <param name="ACollection">The collection to unify with.</param>
    ///  <returns>A new collection that contains the elements from this collection followed by elements
    ///  from the given collection except the elements that already are present in this collection. This operation can be seen as
    ///  a "concat" operation followed by a "distinct" operation. </returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Union(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Creates a new collection that contains the elements from this collection minus the ones in the given collection.</summary>
    ///  <param name="ACollection">The collection to exclude.</param>
    ///  <returns>A new collection that contains the elements from this collection minus the those elements that are common between
    ///  this and the given collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Exclude(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Creates a new collection that contains the elements that are present in both collections.</summary>
    ///  <param name="ACollection">The collection to interset with.</param>
    ///  <returns>A new collection that contains the elements that are common to both collections.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    function Intersect(const ACollection: IEnumerable<T>): IEnexCollection<T>;

    ///  <summary>Select the elements that whose indexed are located in the given range.</summary>
    ///  <param name="AStart">The lower bound.</param>
    ///  <param name="AEnd">The upper bound.</param>
    ///  <returns>A new collection that contains the elements whose indexes in this collection are locate between <paramref name="AStart"/>
    ///  and <paramref name="AEnd"/>. Note that this method does not check the indexes. This means that a bad combination of parameters will
    ///  simply result in an empty or incorrect result.</returns>
    function Range(const AStart, AEnd: NativeUInt): IEnexCollection<T>;

    ///  <summary>Selects only a given amount of elements.</summary>
    ///  <param name="ACount">The number of elements to select.</param>
    ///  <returns>A new collection that contains only the first <paramref name="ACount"/> elements.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ACount"/> is zero.</exception>
    function Take(const ACount: NativeUInt): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while a given rule is satisfied.</summary>
    ///  <param name="APredicate">The rule to satisfy.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function TakeWhile(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are lower than a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileLower(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are lower than
    ///  or equals to a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileLowerOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are greater than
    ///  a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileGreater(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are greater than
    ///  or equals to a given value.</summary>
    ///  <param name="ABound">The value to check against.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileGreaterOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Selects all the elements from the collection while elements are between a given range of values.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <returns>A new collection that contains the selected elements.</returns>
    ///  <remarks>This method selects all elements from the collection while the given rule is satisfied.</remarks>
    function TakeWhileBetween(const ALower, AHigher: T): IEnexCollection<T>;

    ///  <summary>Skips a given amount of elements.</summary>
    ///  <param name="ACount">The number of elements to skip.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ACount"/> is zero.</exception>
    function Skip(const ACount: NativeUInt): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while a given rule is satisfied.</summary>
    ///  <param name="APredicate">The rule to satisfy.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function SkipWhile(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are lower than a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileLower(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are lower than or equal to a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileLowerOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are greater than a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileGreater(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to check.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileGreaterOrEqual(const ABound: T): IEnexCollection<T>;

    ///  <summary>Skips all the elements from the collection while elements are between a given range of values.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The higher bound.</param>
    ///  <returns>A new collection that contains the elements that were not skipped.</returns>
    function SkipWhileBetween(const ALower, AHigher: T): IEnexCollection<T>;

    ///  <summary>Exposes a type that provides extended Enex operations such as "select" or "cast".</summary>
    ///  <returns>A record that exposes more Enex operations that otherwise would be impossible.</returns>
    function Op: TEnexExtOps<T>;

    ///  <summary>Creates a new list containing the elements of this collection.</summary>
    ///  <returns>A list containing the elements copied from this collection.</returns>
    ///  <remarks>This method also copies the type object of this collection. Be careful if the type object
    ///  performs cleanup on the elements.</remarks>
    function ToList(): IList<T>;

    ///  <summary>Creates a new set containing the elements of this collection.</summary>
    ///  <returns>A set containing the elements copied from this collection.</returns>
    ///  <remarks>This method also copies the type object of this collection. Be careful if the type object
    ///  performs cleanup on the elements.</remarks>
    function ToSet(): ISet<T>;

    ///  <summary>Compares the elements in this collection to another collection.</summary>
    ///  <param name="AObject">The instance to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero, <c>Self</c> is less than <paramref name="AObject"/>. If the result is zero,
    ///  <c>Self</c> is equal to <paramref name="AObject"/>. And finally, if the result is greater than zero, <c>Self</c> is greater
    ///  than <paramref name="AObject"/>.</returns>
    function CompareTo(AObject: TObject): Integer;

    ///  <summary>Generates the hash code of all the elements in the collection.</summary>
    ///  <returns>An integer value representing the hash codes of all the elements in the collection.</returns>
    function GetHashCode(): Integer; override;

    ///  <summary>Checks whether this collection is equal to another collection.</summary>
    ///  <param name="Obj">The collection to check against.</param>
    ///  <returns><c>True</c> if collections are equal; <c>False</c> otherwise.</returns>
    ///  <remarks>This method checks whether <paramref name="Obj"/> is not <c>nil</c>, and that
    ///  <paramref name="Obj"/> is a Enex collection. Then, elements are checked for equality one by one.</remarks>
    function Equals(Obj: TObject): Boolean; override;
  end;

  ///  <summary>Base class for all associative Enex collections.</summary>
  ///  <remarks>All associative Enex collections (ex. dictionary or multi-map) are derived from this base class.
  ///  It implements the extended Enex operations based on enumerability and introduces functional
  ///  serialization support.</remarks>
  TEnexAssociativeCollection<TKey, TValue> = class abstract(TCollection<KVPair<TKey, TValue>>,
      IEnexAssociativeCollection<TKey, TValue>)
  private
    FKeyType: IType<TKey>;
    FValueType: IType<TValue>;

  protected
    ///  <summary>Specifies the type object that describes the keys of the stored pairs.</summary>
    ///  <returns>A type object describing the keys.</returns>
    property KeyType: IType<TKey> read FKeyType;

    ///  <summary>Specifies the type object that describes the values of the stored pairs.</summary>
    ///  <returns>A type object describing the values.</returns>
    property ValueType: IType<TValue> read FValueType;

    ///  <summary>Installs the type objects describing the key and the value or the stored pairs.</summary>
    ///  <param name="AKeyType">The key's type object to install.</param>
    ///  <param name="AValueType">The value's type object to install.</param>
    ///  <remarks>This method stores the given type objects. The passed type objects are then used
    ///  by the collection to perform all required operation on the elements operated upon.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    procedure InstallTypes(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); virtual;

    ///  <summary>Called when the an pair has been deserialized and needs to be inserted into the collection.</summary>
    ///  <param name="AKey">The key that was deserialized.</param>
    ///  <param name="AValue">The value that was deserialized.</param>
    ///  <remarks>Derived collection classes need to implement this method to provide proper insertion mechanics
    ///  for the deserialized elements. For example, a simple dictionary only needs to call the <c>Add</c> method for each
    ///  passed pair.</remarks>
    procedure DeserializePair(const AKey: TKey; const AValue: TValue); virtual;

    ///  <summary>Called when the the collection needs to serialize its contents.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    ///  <remarks>This method is overridded and provides the default serialization support based on enumerability. To provide
    ///  an optimized serialization method, override this method (and <c>Deserialize</c>) in descending classes.</remarks>
    procedure Serialize(const AData: TSerializationData); override;

    ///  <summary>Called when the the collection needs to deserialize its contents.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <remarks>This method is overridded and provides the default deserialization support based on enumerability. To provide
    ///  an optimized deserialization method, override this method (and <c>Serialize</c>) in descending classes.</remarks>
    procedure Deserialize(const AData: TDeserializationData); override;
  public
    //TODO: doc me
    constructor Create();

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to return the associated value.</param>
    ///  <returns>The value associated with the given key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">No such key in the collection.</exception>
    function ValueForKey(const AKey: TKey): TValue; virtual;

    ///  <summary>Checks whether the collection contains a given key-value pair.</summary>
    ///  <param name="AKey">The key part of the pair.</param>
    ///  <param name="AValue">The value part of the pair.</param>
    ///  <returns><c>True</c> if the given key-value pair exists; <c>False</c> otherwise.</returns>
    function KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean; virtual;

    ///  <summary>Returns the biggest key.</summary>
    ///  <returns>The biggest key stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MaxKey(): TKey; virtual;

    ///  <summary>Returns the smallest key.</summary>
    ///  <returns>The smallest key stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MinKey(): TKey; virtual;

    ///  <summary>Returns the biggest value.</summary>
    ///  <returns>The biggest value stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MaxValue(): TValue; virtual;

    ///  <summary>Returns the smallest value.</summary>
    ///  <returns>The smallest value stored in the collection.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The collection is empty.</exception>
    function MinValue(): TValue; virtual;

    ///  <summary>Checks whether this collection includes the key-value pairs in another collection.</summary>
    ///  <param name="ACollection">The collection to check against.</param>
    ///  <returns><c>True</c> if this collection includes the elements in another; <c>False</c> otherwise.</returns>
    function Includes(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>): Boolean; virtual;

    ///  <summary>Returns an Enex collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the collection.</returns>
    function SelectKeys(): IEnexCollection<TKey>; virtual;

    ///  <summary>Returns a Enex collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the collection.</returns>
    function SelectValues(): IEnexCollection<TValue>; virtual;

    ///  <summary>Selects all the key-value pairs from the collection excluding the duplicates by key.</summary>
    ///  <returns>A new collection that contains the distinct pairs.</returns>
    function DistinctByKeys(): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects all the key-value pairs from the collection excluding the duplicates by value.</summary>
    ///  <returns>A new collection that contains the distinct pairs.</returns>
    function DistinctByValues(): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs that satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Where(const APredicate: TFunc<TKey, TValue, Boolean>): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs that do not satisfy a given rule.</summary>
    ///  <param name="APredicate">The predicate that represents the rule.</param>
    ///  <returns>A new collection that contains only the pairs that do not satisfy the given rule.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function WhereNot(const APredicate: TFunc<TKey, TValue, Boolean>): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are less than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyLower(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are less than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyLowerOrEqual(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are greater than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyGreater(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyGreaterOrEqual(const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose keys are are contained whithin a given interval.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The upper bound.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereKeyBetween(const ALower, AHigher: TKey): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are less than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueLower(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are less than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueLowerOrEqual(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are greater than a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueGreater(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are greater than or equal to a given value.</summary>
    ///  <param name="ABound">The value to compare against.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueGreaterOrEqual(const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Selects only the key-value pairs whose values are are contained whithin a given interval.</summary>
    ///  <param name="ALower">The lower bound.</param>
    ///  <param name="AHigher">The upper bound.</param>
    ///  <returns>A new collection that contains only the pairs that satisfy the relationship.</returns>
    function WhereValueBetween(const ALower, AHigher: TValue): IEnexAssociativeCollection<TKey, TValue>;

    ///  <summary>Creates a new dictionary containing the elements of this collection.</summary>
    ///  <returns>A dictionary containing the elements copied from this collection.</returns>
    ///  <remarks>This method also copies the type objects of this collection. Be careful if the type object
    ///  performs cleanup on the elements.</remarks>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The collection contains more than
    ///  one key-value pair with the same key.</exception>
    function ToDictionary(): IDictionary<TKey, TValue>;
  end;
{$ENDREGION}

type
  ///  <summary>A static type that exposes collection related utility methods.</summary>
  ///  <remarks>The methods exposed by this type are utilitary and useful in some circumstances. This type
  ///  also serves as a public container for all "private" types that should not be used in user code.</remarks>
  Collection = record
  public
    ///  <summary>Generates a new collection that contains a given value for a given number of times.</summary>
    ///  <param name="AElement">The element to fill the collection with.</param>
    ///  <param name="ACount">The number of times the element is present in the collection (the length of the collection).</param>
    ///  <param name="AType">The type object describing the elements in the new collection.</param>
    ///  <returns>A new collection containing the <paramref name="AElement"/>, <paramref name="ACount"/> times.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AElement"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ACount"/> is zero.</exception>
    class function Fill<T>(const AElement: T; const ACount: NativeUInt; const AType: IType<T>): IEnexCollection<T>; overload; static;

    //TODO: doc me
    class function Fill<T>(const AElement: T; const ACount: NativeUInt): IEnexCollection<T>; overload; static;
    //TODO: doc me
    class function Interval<T>(const AStart, AEnd, AIncrement: T; const AType: IType<T>): IEnexCollection<T>; overload; static;
    //TODO: doc me
    class function Interval<T>(const AStart, AEnd, AIncrement: T): IEnexCollection<T>; overload; static;
    //TODO: doc me
    class function Interval<T>(const AStart, AEnd: T; const AType: IType<T>): IEnexCollection<T>; overload; static;
    //TODO: doc me
    class function Interval<T>(const AStart, AEnd: T): IEnexCollection<T>; overload; static;
  end;


  //TODO: doc all these classes :(
type
  { The "Where" collection }
  TEnexWhereCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Where" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexWhereCollection<T>;
      FIter: IEnumerator<T>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexWhereCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexCollection<T>;
    FPredicate: TFunc<T, Boolean>;
    FInvertResult: Boolean;
  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>;
      const APredicate: TFunc<T, Boolean>; const AInvertResult: Boolean); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const APredicate: TFunc<T, Boolean>;
      const AType: IType<T>; const AInvertResult: Boolean); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Select" collection }
  TEnexSelectCollection<T, TOut> = class sealed(TEnexCollection<TOut>, IEnexCollection<TOut>)
  private
  type
    { The "Select" enumerator }
    TEnumerator = class(TEnumerator<TOut>)
    private
      FEnum: TEnexSelectCollection<T, TOut>;
      FIter: IEnumerator<T>;
      FCurrent: TOut;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexSelectCollection<T, TOut>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TOut; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexCollection<T>;
    FSelector: TFunc<T, TOut>;

  protected
    { Enex: Defaults }
    function GetCount(): NativeUInt; override;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const ASelector: TFunc<T, TOut>; const AType: IType<TOut>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const ASelector: TFunc<T, TOut>; const AType: IType<TOut>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<TOut>; override;

    { Enex Overrides }
    function Empty(): Boolean; override;
    function First(): TOut; override;
    function Last(): TOut; override;
    function Single(): TOut; override;
    function ElementAt(const Index: NativeUInt): TOut; override;
  end;

  { The "Select Class" collection }
  TEnexSelectClassCollection<T, TOut: class> = class sealed(TEnexCollection<TOut>, IEnexCollection<TOut>)
  private
  type
    { The "Select Class" enumerator }
    TEnumerator = class(TEnumerator<TOut>)
    private
      FEnum: TEnexSelectClassCollection<T, TOut>;
      FIter: IEnumerator<T>;
      FCurrent: TOut;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexSelectClassCollection<T, TOut>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TOut; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexCollection<T>;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const AType: IType<TOut>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const AType: IType<TOut>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<TOut>; override;
  end;

  { The "Cast" collection }
  TEnexCastCollection<T, TOut> = class sealed(TEnexCollection<TOut>, IEnexCollection<TOut>)
  private
  type
    { The "Cast" enumerator }
    TEnumerator = class(TEnumerator<TOut>)
    private
      FEnum: TEnexCastCollection<T, TOut>;
      FIter: IEnumerator<T>;
      FCurrent: TOut;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexCastCollection<T, TOut>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TOut; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexCollection<T>;
    FConverter: IConverter<T, TOut>;

  protected
    { Enex: Defaults }
    function GetCount(): NativeUInt; override;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const AOutType: IType<TOut>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const AInType: IType<T>; const AOutType: IType<TOut>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<TOut>; override;

    { Enex Overrides }
    function Empty(): Boolean; override;
    function First(): TOut; override;
    function Last(): TOut; override;
    function Single(): TOut; override;
    function ElementAt(const Index: NativeUInt): TOut; override;
  end;

  { The "Concatenation" collection }
  TEnexConcatCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Concatenation" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexConcatCollection<T>;
      FIter1, FIter2: IEnumerator<T>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexConcatCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FEnum1: TEnexCollection<T>;
    FEnum2: TEnexCollection<T>;
    FDeleteEnum1,
      FDeleteEnum2: Boolean;
  protected
    { ICollection support/hidden }
    function GetCount(): NativeUInt; override;

  public
    { Constructors }
    constructor Create(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: TEnexCollection<T>); overload;

    constructor CreateIntf(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf2(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf1(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: TEnexCollection<T>; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;

    { Enex Overrides }
    function Empty(): Boolean; override;
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;
    function All(const APredicate: TFunc<T, Boolean>): Boolean; override;
  end;

  { The "Union" collection }
  TEnexUnionCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Union" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexUnionCollection<T>;
      FIter1, FIter2: IEnumerator<T>;
      FSet: ISet<T>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexUnionCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FEnum1: TEnexCollection<T>;
    FEnum2: TEnexCollection<T>;
    FDeleteEnum1,
      FDeleteEnum2: Boolean;
  public
    { Constructors }
    constructor Create(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: TEnexCollection<T>); overload;

    constructor CreateIntf(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf2(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf1(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: TEnexCollection<T>; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Exclusion" collection }
  TEnexExclusionCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Exclusion" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexExclusionCollection<T>;
      FIter: IEnumerator<T>;
      FSet: ISet<T>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexExclusionCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FEnum1: TEnexCollection<T>;
    FEnum2: TEnexCollection<T>;
    FDeleteEnum1,
      FDeleteEnum2: Boolean;

  public
    { Constructors }
    constructor Create(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: TEnexCollection<T>); overload;

    constructor CreateIntf(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf2(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf1(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: TEnexCollection<T>; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Intersection" collection }
  TEnexIntersectionCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Intersection" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexIntersectionCollection<T>;
      FIter: IEnumerator<T>;
      FSet: ISet<T>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexIntersectionCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FEnum1: TEnexCollection<T>;
    FEnum2: TEnexCollection<T>;
    FDeleteEnum1,
      FDeleteEnum2: Boolean;

  public
    { Constructors }
    constructor Create(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: TEnexCollection<T>); overload;

    constructor CreateIntf(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf2(const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>); overload;

    constructor CreateIntf1(const AEnumerable1: IEnumerable<T>;
      const AEnumerable2: TEnexCollection<T>; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Distinct" collection }
  TEnexDistinctCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Distinct" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexDistinctCollection<T>;
      FIter: IEnumerator<T>;
      FSet: ISet<T>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexDistinctCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FEnum: TEnexCollection<T>;
    FDeleteEnum: Boolean;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Range" collection }
  TEnexRangeCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Range" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexRangeCollection<T>;
      FIter: IEnumerator<T>;
      FIdx: NativeUInt;
    public
      { Constructor }
      constructor Create(const AEnum: TEnexRangeCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FStart, FEnd: NativeUInt;
    FEnum: TEnexCollection<T>;
    FDeleteEnum: Boolean;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const AStart, AEnd: NativeUInt); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const AStart, AEnd: NativeUInt; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Skip" collection }
  TEnexSkipCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Skip" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexSkipCollection<T>;
      FIter: IEnumerator<T>;
      FIdx: NativeUInt;
    public
      { Constructor }
      constructor Create(const AEnum: TEnexSkipCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FCount: NativeUInt;
    FEnum: TEnexCollection<T>;
    FDeleteEnum: Boolean;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const ACount: NativeUInt); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const ACount: NativeUInt; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Take" collection }
  TEnexTakeCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Take" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexTakeCollection<T>;
      FIter: IEnumerator<T>;
      FIdx: NativeUInt;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexTakeCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FCount: NativeUInt;
    FEnum: TEnexCollection<T>;
    FDeleteEnum: Boolean;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const ACount: NativeUInt); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const ACount: NativeUInt; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Fill" collection }
  TEnexFillCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Fill" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexFillCollection<T>;
      FCount: NativeUInt;
    public
      { Constructor }
      constructor Create(const AEnum: TEnexFillCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FElement: T;
    FCount: NativeUInt;

  protected
    { Enex: Defaults }
    function GetCount(): NativeUInt; override;
  public
    { Constructors }
    constructor Create(const AElement: T; const Count: NativeUInt; const AType: IType<T>);

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;

    { Enex Overrides }
    function Empty(): Boolean; override;
    function Max(): T; override;
    function Min(): T; override;
    function First(): T; override;
    function FirstOrDefault(const ADefault: T): T; override;
    function Last(): T; override;
    function LastOrDefault(const ADefault: T): T; override;
    function Single(): T; override;
    function SingleOrDefault(const ADefault: T): T; override;
    function Aggregate(const AAggregator: TFunc<T, T, T>): T; override;
    function AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T; override;
    function ElementAt(const Index: NativeUInt): T; override;
    function ElementAtOrDefault(const Index: NativeUInt; const ADefault: T): T; override;
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;
    function All(const APredicate: TFunc<T, Boolean>): Boolean; override;
    function EqualsTo(const AEnumerable: IEnumerable<T>): Boolean; override;
  end;

  { The "Interval" collection }
  TEnexIntervalCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Interval" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexIntervalCollection<T>;
      FNow: T;
      FNowVariant: Variant;
    public
      { Constructor }
      constructor Create(const AEnum: TEnexIntervalCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FLower, FHigher, FIncrement: T;

  public
    { Constructors }
    constructor Create(const ALower, AHigher, AIncrement: T; const AType: IType<T>);

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;

    { Enex Overrides }
    function Empty(): Boolean; override;
    function Min(): T; override;
    function First(): T; override;
    function FirstOrDefault(const ADefault: T): T; override;
  end;

  { The "Take While" collection }
  TEnexTakeWhileCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Take While" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexTakeWhileCollection<T>;
      FIter: IEnumerator<T>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexTakeWhileCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexCollection<T>;
    FPredicate: TFunc<T, Boolean>;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const APredicate: TFunc<T, Boolean>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const APredicate: TFunc<T, Boolean>; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Skip While" collection }
  TEnexSkipWhileCollection<T> = class sealed(TEnexCollection<T>)
  private
  type
    { The "Skip While" enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FEnum: TEnexSkipWhileCollection<T>;
      FIter: IEnumerator<T>;
      FStop: Boolean;
    public
      { Constructor }
      constructor Create(const AEnum: TEnexSkipWhileCollection<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexCollection<T>;
    FPredicate: TFunc<T, Boolean>;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexCollection<T>; const APredicate: TFunc<T, Boolean>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<T>; const APredicate: TFunc<T, Boolean>; const AType: IType<T>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Wrap" collection }
  TEnexWrapCollection<T> = class sealed(TEnexCollection<T>)
  private
    FEnum: IEnumerable<T>;

  public
    { Constructors }
    constructor Create(const AEnumerable: IEnumerable<T>; const AType: IType<T>);

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<T>; override;
  end;

  { The "Wrap associative" collection }
  TEnexAssociativeWrapCollection<TKey, TValue> = class sealed(TEnexAssociativeCollection<TKey, TValue>,
    IEnexAssociativeCollection<TKey, TValue>)
  private
    FEnum: IEnumerable<KVPair<TKey, TValue>>;

  public
    { Constructors }
    constructor Create(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>; const AKeyType: IType<TKey>;
      const AValueType: IType<TValue>);

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<KVPair<TKey, TValue>>; override;
  end;

  { The "Select Keys" collection }
  TEnexSelectKeysCollection<TKey, TValue> = class sealed(TEnexCollection<TKey>)
  private
  type
    { The "Select Keys" enumerator }
    TEnumerator = class(TEnumerator<TKey>)
    private
      FEnum: TEnexSelectKeysCollection<TKey, TValue>;
      FIter: IEnumerator<KVPair<TKey, TValue>>;
      FCurrent: TKey;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexSelectKeysCollection<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TKey; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexAssociativeCollection<TKey, TValue>;

  protected
    { Enex: Defaults }
    function GetCount(): NativeUInt; override;
  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexAssociativeCollection<TKey, TValue>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
      const AKeyType: IType<TKey>; const AValueType: IType<TValue>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<TKey>; override;
  end;

  { The "Select Values" collection }
  TEnexSelectValuesCollection<TKey, TValue> = class sealed(TEnexCollection<TValue>)
  private
  type
    { The "Select Keys" enumerator }
    TEnumerator = class(TEnumerator<TValue>)
    private
      FEnum: TEnexSelectValuesCollection<TKey, TValue>;
      FIter: IEnumerator<KVPair<TKey, TValue>>;
      FCurrent: TValue;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexSelectValuesCollection<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TValue; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexAssociativeCollection<TKey, TValue>;

  protected
    { Enex: Defaults }
    function GetCount(): NativeUInt; override;
  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexAssociativeCollection<TKey, TValue>); overload;
    constructor CreateIntf(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
      const AKeyType: IType<TKey>; const AValueType: IType<TValue>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<TValue>; override;
  end;

  { The "Where" associative collection }
  TEnexAssociativeWhereCollection<TKey, TValue> = class sealed(TEnexAssociativeCollection<TKey, TValue>,
      IEnexAssociativeCollection<TKey, TValue>)
  private
  type
    { The "Where" associative enumerator }
    TEnumerator = class(TEnumerator<KVPair<TKey, TValue>>)
    private
      FEnum: TEnexAssociativeWhereCollection<TKey, TValue>;
      FIter: IEnumerator<KVPair<TKey, TValue>>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexAssociativeWhereCollection<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): KVPair<TKey, TValue>; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexAssociativeCollection<TKey, TValue>;
    FPredicate: TFunc<TKey, TValue, Boolean>;
    FInvertResult: Boolean;
  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexAssociativeCollection<TKey, TValue>;
        const APredicate: TFunc<TKey, TValue, Boolean>; const AInvertResult: Boolean); overload;

    constructor CreateIntf(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
      const APredicate: TFunc<TKey, TValue, Boolean>;
      const AKeyType: IType<TKey>; const AValueType: IType<TValue>; const AInvertResult: Boolean); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<KVPair<TKey, TValue>>; override;
  end;

  { The "Distinct By Keys" associative collection }
  TEnexAssociativeDistinctByKeysCollection<TKey, TValue> = class sealed(TEnexAssociativeCollection<TKey, TValue>)
  private
  type
    { The "Distinct By Keys" associative enumerator }
    TEnumerator = class(TEnumerator<KVPair<TKey, TValue>>)
    private
      FEnum: TEnexAssociativeDistinctByKeysCollection<TKey, TValue>;
      FIter: IEnumerator<KVPair<TKey, TValue>>;
      FSet: ISet<TKey>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexAssociativeDistinctByKeysCollection<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): KVPair<TKey, TValue>; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexAssociativeCollection<TKey, TValue>;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexAssociativeCollection<TKey, TValue>); overload;

    constructor CreateIntf(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>; const AKeyType: IType<TKey>;
      const AValueType: IType<TValue>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<KVPair<TKey, TValue>>; override;
  end;

  { The "Distinct By Values" associative collection }
  TEnexAssociativeDistinctByValuesCollection<TKey, TValue> = class sealed(TEnexAssociativeCollection<TKey, TValue>)
  private
  type
    { The "Distinct By Keys" associative enumerator }
    TEnumerator = class(TEnumerator<KVPair<TKey, TValue>>)
    private
      FEnum: TEnexAssociativeDistinctByValuesCollection<TKey, TValue>;
      FIter: IEnumerator<KVPair<TKey, TValue>>;
      FSet: ISet<TValue>;

    public
      { Constructor }
      constructor Create(const AEnum: TEnexAssociativeDistinctByValuesCollection<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): KVPair<TKey, TValue>; override;
      function MoveNext(): Boolean; override;
    end;

  var
    FDeleteEnum: Boolean;
    FEnum: TEnexAssociativeCollection<TKey, TValue>;

  public
    { Constructors }
    constructor Create(const AEnumerable: TEnexAssociativeCollection<TKey, TValue>); overload;

    constructor CreateIntf(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>; const AKeyType: IType<TKey>;
      const AValueType: IType<TValue>); overload;

    { Destructor }
    destructor Destroy(); override;

    { IEnumerable<T> }
    function GetEnumerator(): IEnumerator<KVPair<TKey, TValue>>; override;
  end;

implementation
uses
  DeHL.Collections.HashSet,
  DeHL.Collections.List,
  DeHL.Collections.Dictionary;


{ TEnexExtOps<T> }

function TEnexExtOps<T>.Cast<TOut>: IEnexCollection<TOut>;
begin
  { Call super-function }
  Result := Cast<TOut>(TType<TOut>.Default);
end;

function TEnexExtOps<T>.Select<TOut>: IEnexCollection<TOut>;
begin
  { Make sure that T is a class }
  FType.RestrictTo([tfClass]);
  Result := TEnexSelectClassCollection<TObject, TOut>.Create(FInstance, TType<TOut>.Default);
end;

function TEnexExtOps<T>.Cast<TOut>(const AType: IType<TOut>): IEnexCollection<TOut>;
begin
  { Check arguments }
  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Create a new Enex collection }
  Result := TEnexCastCollection<T, TOut>.Create(FInstance, AType);
end;

function TEnexExtOps<T>.Select<TOut>(const ASelector: TFunc<T, TOut>): IEnexCollection<TOut>;
begin
  { With default type support }
  Result := Select<TOut>(ASelector, TType<TOut>.Default);
end;

function TEnexExtOps<T>.Select<TOut>(const ASelector: TFunc<T, TOut>; const AType: IType<TOut>): IEnexCollection<TOut>;
begin
  { Check arguments }
  if not Assigned(ASelector) then
    ExceptionHelper.Throw_ArgumentNilError('ASelector');

  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Create a new Enex collection }
  Result := TEnexSelectCollection<T, TOut>.Create(FInstance, ASelector, AType);
end;

{ TCollection<T> }

procedure TCollection<T>.CopyTo(var AArray: array of T);
begin
  { Call upper version }
  CopyTo(AArray, 0);
end;

procedure TCollection<T>.CopyTo(var AArray: array of T; const AStartIndex: NativeUInt);
var
  Enum: IEnumerator<T>;
  L, I: NativeUInt;
begin
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  { Retrieve the enumerator object }
  Enum := GetEnumerator();
  L := NativeUInt(Length(AArray));
  I := AStartIndex;

  { Iterate until ANY element supports the predicate }
  while Enum.MoveNext() do
  begin
    if I >= L then
      ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray/AStartIndex');

    AArray[I] := Enum.Current;
    Inc(I);
  end;
end;

function TCollection<T>.Empty: Boolean;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Check if empty }
  Result := (not Enum.MoveNext());
end;

procedure TCollection<T>.EndDeserializing(const AData: TDeserializationData);
begin
  // Nothing here, please come again!
end;

procedure TCollection<T>.EndSerializing(const AData: TSerializationData);
begin
  // Nothing here, please take your bussiness elsewhere!
end;

function TCollection<T>.GetCount: NativeUInt;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Iterate till the end }
  Result := 0;
  while Enum.MoveNext() do Inc(Result);
end;

function TCollection<T>.Single: T;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if Enum.MoveNext() then
    Result := Enum.Current
  else
    ExceptionHelper.Throw_CollectionEmptyError();

  { Fail if more than one elements are there }
  if Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement();
end;

function TCollection<T>.SingleOrDefault(const ADefault: T): T;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if Enum.MoveNext() then
    Result := Enum.Current
  else
    Exit(ADefault);

  { Fail if more than one elements are there }
  if Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement();
end;

procedure TCollection<T>.StartDeserializing(const AData: TDeserializationData);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AData.CurrentElementInfo.Name, ClassName);
end;

procedure TCollection<T>.StartSerializing(const AData: TSerializationData);
begin
  { Unsupported by default }
  ExceptionHelper.Throw_Unserializable(AData.CurrentElementInfo.Name, ClassName);
end;

function TCollection<T>.ToArray: TArray<T>;
var
  LCount: NativeUInt;
  LResult: TArray<T>;
begin
  LCount := Count;

  if LCount > 0 then
  begin
    { Set the length of array }
    SetLength(LResult, LCount);

    { Copy all elements to array }
    CopyTo(LResult);
  end else
    SetLength(LResult, 0);

  Result := LResult;
end;

function TCollection<T>.ToDynamicArray: TDynamicArray<T>;
var
  LCount: NativeUInt;
  LArray: TArray<T>;

begin
  LCount := Count;

  if LCount > 0 then
  begin
    { Set the length of array }
    SetLength(LArray, LCount);

    { Copy all elements to array }
    CopyTo(LArray);
  end;

  Result := TDynamicArray<T>.Consume(LArray);
end;

function TCollection<T>.ToFixedArray: TFixedArray<T>;
var
  LCount: NativeUInt;
  LArray: TArray<T>;

begin
  LCount := Count;

  if LCount > 0 then
  begin
    { Set the length of array }
    SetLength(LArray, LCount);

    { Copy all elements to array }
    CopyTo(LArray);
  end;

  Result := TFixedArray<T>.Consume(LArray);
end;

{ TEnexCollection<T> }

procedure TEnexCollection<T>.InstallType(const AType: IType<T>);
begin
  { Pass through }
  FElementType := AType;
end;

function TEnexCollection<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
var
  Enum: IEnumerator<T>;
begin
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := Enum.Current;

  { Iterate over the last N - 1 elements }
  while Enum.MoveNext() do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, Enum.Current);
  end;
end;

function TEnexCollection<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
var
  Enum: IEnumerator<T>;
begin
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    Exit(ADefault);

  { Select the first element as comparison base }
  Result := Enum.Current;

  { Iterate over the last N - 1 elements }
  while Enum.MoveNext() do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, Enum.Current);
  end;
end;

function TEnexCollection<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  Enum: IEnumerator<T>;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Iterate while ALL elements support the predicate }
  while Enum.MoveNext() do
  begin
    if not APredicate(Enum.Current) then
      Exit(false);
  end;

  Result := true;
end;

function TEnexCollection<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  Enum: IEnumerator<T>;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Iterate until ANY element supports the predicate }
  while Enum.MoveNext() do
  begin
    if APredicate(Enum.Current) then
      Exit(true);
  end;

  Result := false;
end;

function TEnexCollection<T>.CompareTo(AObject: TObject): Integer;
var
  LType: IType<T>;
  LIterSelf, LIterTo: IEnumerator<T>;
  LMovSelf, LMovTo: Boolean;
begin
  { Check if we can continue }
  if (AObject = nil) or (not AObject.InheritsFrom(TEnexCollection<T>)) then
    Result := 1
  else begin
    { Assume equality }
    Result := 0;

    { Get the type }
    LType := ElementType;

    { Get enumerators }
    LIterSelf := GetEnumerator();
    LIterTo := TEnexCollection<T>(AObject).GetEnumerator();

    while true do
    begin
      { Iterate and verify that both enumerators moved }
      LMovSelf := LIterSelf.MoveNext();
      LMovTo := LIterTo.MoveNext();

      { If one moved but the other did not - error }
      if LMovSelf <> LMovTo then
      begin
        { Decide on the return value }
        if LMovSelf then
          Result := 1
        else
          Result := -1;

        Break;
      end;

      { If neither moved, we've reached the end }
      if not LMovSelf then
        Break;

      { Verify both values are identical }
      Result := LType.Compare(LIterSelf.Current, LIterTo.Current);
      if Result <> 0 then
        Break;
    end;
  end;
end;

function TEnexCollection<T>.Concat(const ACollection: IEnumerable<T>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Create concatenation iterator }
  Result := TEnexConcatCollection<T>.CreateIntf2(Self, ACollection, ElementType);
end;

constructor TEnexCollection<T>.Create;
begin
  InstallType(TType<T>.Default);
end;

procedure TEnexCollection<T>.Deserialize(const AData: TDeserializationData);
var
  I, LCount: NativeUInt;
  LValue: T;
begin
  { Build the serialization info struct }
  StartDeserializing(AData);

  { Start the composite }
  LCount := AData.ExpectListBlock(SSerElements, FElementType.TypeInfo);

  if LCount > 0 then
    for I := 0 to LCount - 1 do
    begin
      { Obtain the element }
      FElementType.Deserialize(LValue, AData);

      { Add it to the collection }
      DeserializeElement(LValue);
    end;

  { Stop the process }
  AData.EndBlock();

  EndDeserializing(AData);
end;

procedure TEnexCollection<T>.DeserializeElement(const AElement: T);
begin
 // Do nothing by default.
end;

function TEnexCollection<T>.Distinct: IEnexCollection<T>;
begin
  { Create a new enumerator }
  Result := TEnexDistinctCollection<T>.Create(Self);
end;

function TEnexCollection<T>.ElementAt(const AIndex: NativeUInt): T;
var
  Enum: IEnumerator<T>;
  Count: NativeUInt;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();
  Count := 0;

  while Enum.MoveNext() do
  begin
    { If we reached thge element, exit }
    if Count = AIndex then
      Exit(Enum.Current);

    Inc(Count);
  end;

  { Fail! }
  ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
end;

function TEnexCollection<T>.ElementAtOrDefault(const AIndex: NativeUInt; const ADefault: T): T;
var
  Enum: IEnumerator<T>;
  Count: NativeUInt;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();
  Count := 0;

  while Enum.MoveNext() do
  begin
    { If we reached thge element, exit }
    if Count = AIndex then
      Exit(Enum.Current);

    Inc(Count);
  end;

  { Return default value }
  Result := ADefault;
end;

function TEnexCollection<T>.Equals(Obj: TObject): Boolean;
begin
  { Call comparison }
  Result := (CompareTo(Obj) = 0);
end;

function TEnexCollection<T>.EqualsTo(const ACollection: IEnumerable<T>): Boolean;
var
  LType: IType<T>;
  LIter1, LIter2: IEnumerator<T>;
  Moved1, Moved2: Boolean;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Get the type }
  LType := ElementType;

  { Get enumerators }
  LIter1 := GetEnumerator();
  LIter2 := ACollection.GetEnumerator();

  while true do
  begin
    { Iterate and verify that both enumerators moved }
    Moved1 := LIter1.MoveNext();
    Moved2 := LIter2.MoveNext();

    { If one moved but the other did not - error }
    if Moved1 <> Moved2 then
      Exit(false);

    { If neither moved, we've reached the end }
    if not Moved1 then
      break;

    { Verify both values are identical }
    if not LType.AreEqual(LIter1.Current, LIter2.Current) then
      Exit(false);
  end;

  { It worked! }
  Result := true;
end;

function TEnexCollection<T>.Exclude(const ACollection: IEnumerable<T>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Create concatenation iterator }
  Result := TEnexExclusionCollection<T>.CreateIntf2(Self, ACollection, ElementType);
end;

function TEnexCollection<T>.First: T;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if Enum.MoveNext() then
    Result := Enum.Current
  else
    ExceptionHelper.Throw_CollectionEmptyError();
end;

function TEnexCollection<T>.FirstOrDefault(const ADefault: T): T;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise return default! }
  if Enum.MoveNext() then
    Result := Enum.Current
  else
    Result := ADefault;
end;

function TEnexCollection<T>.FirstWhere(const APredicate: TFunc<T, Boolean>): T;
var
  LIter: IEnumerator<T>;
  LWasOne: Boolean;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Retrieve the enumerator object }
  LIter := GetEnumerator();
  LWasOne := false;

  { Do the funky stuff already }
  while LIter.MoveNext do
  begin
    LWasOne := true;

    if APredicate(LIter.Current) then
      Exit(LIter.Current);
  end;

  { Failure to find what we need }
  if LWasOne then
    ExceptionHelper.Throw_CollectionHasNoFilteredElements()
  else
    ExceptionHelper.Throw_CollectionEmptyError();
end;

function TEnexCollection<T>.FirstWhereBetween(const ALower, AHigher: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhere(
    function(Arg1: T): Boolean
    begin
      Result := (LType.Compare(Arg1, ALower) >= 0) and
                (LType.Compare(Arg1, AHigher) <= 0)
    end
  );
end;

function TEnexCollection<T>.FirstWhereBetweenOrDefault(const ALower, AHigher, ADefault: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhereOrDefault(
    function(Arg1: T): Boolean
    begin
      Result := (LType.Compare(Arg1, ALower) >= 0) and
                (LType.Compare(Arg1, AHigher) <= 0)
    end,
    ADefault
  );
end;

function TEnexCollection<T>.FirstWhereGreater(const ABound: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhere(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) > 0;
    end
  );
end;

function TEnexCollection<T>.FirstWhereGreaterOrDefault(const ABound, ADefault: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhereOrDefault(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) > 0;
    end,
    ADefault
  );
end;

function TEnexCollection<T>.FirstWhereGreaterOrEqual(const ABound: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhere(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) >= 0;
    end
  );
end;

function TEnexCollection<T>.FirstWhereGreaterOrEqualOrDefault(const ABound, ADefault: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhereOrDefault(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) >= 0;
    end,
    ADefault
  );
end;

function TEnexCollection<T>.FirstWhereLower(const ABound: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhere(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) < 0;
    end
  );
end;

function TEnexCollection<T>.FirstWhereLowerOrDefault(const ABound, ADefault: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhereOrDefault(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) < 0;
    end,
    ADefault
  );
end;

function TEnexCollection<T>.FirstWhereLowerOrEqual(const ABound: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhere(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) <= 0;
    end
  );
end;

function TEnexCollection<T>.FirstWhereLowerOrEqualOrDefault(const ABound, ADefault: T): T;
var
  LType: IType<T>;
begin
  { Get the type }
  LType := ElementType;

  Result := FirstWhereOrDefault(
    function(Arg1: T): Boolean
    begin
      Result := LType.Compare(Arg1, ABound) <= 0;
    end,
    ADefault
  );
end;

function TEnexCollection<T>.FirstWhereNot(const APredicate: TFunc<T, Boolean>): T;
var
  LType: IType<T>;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Get the type }
  LType := ElementType;

  Result := FirstWhere(
    function(Arg1: T): Boolean
    begin
      Result := not APredicate(Arg1);
    end
  );
end;

function TEnexCollection<T>.FirstWhereNotOrDefault(
  const APredicate: TFunc<T, Boolean>; const ADefault: T): T;
var
  LType: IType<T>;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Get the type }
  LType := ElementType;

  Result := FirstWhereOrDefault(
    function(Arg1: T): Boolean
    begin
      Result := not APredicate(Arg1);
    end,
    ADefault
  );
end;

function TEnexCollection<T>.FirstWhereOrDefault(const APredicate: TFunc<T, Boolean>; const ADefault: T): T;
var
  LIter: IEnumerator<T>;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Retrieve the enumerator object }
  LIter := GetEnumerator();

  { Do the funky stuff already }
  while LIter.MoveNext do
    if APredicate(LIter.Current) then
      Exit(LIter.Current);

  { Failure to find what we need }
  Result := ADefault;
end;

function TEnexCollection<T>.GetHashCode: Integer;
const
  CMagic = $0F;

var
  LIter: IEnumerator<T>;
  LType: IType<T>;
begin
  { Obtain the enumerator }
  LIter := GetEnumerator();
  LType := ElementType;

  { Start at 0 }
  Result := 0;

  { ... }
  while LIter.MoveNext() do
    Result := CMagic * Result + LType.GenerateHashCode(LIter.Current);
end;

function TEnexCollection<T>.Intersect(const ACollection: IEnumerable<T>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Create concatenation iterator }
  Result := TEnexIntersectionCollection<T>.CreateIntf2(Self, ACollection, ElementType);
end;

function TEnexCollection<T>.Last: T;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Iterate till the last element in the enum }
  while true do
  begin
    Result := Enum.Current;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexCollection<T>.LastOrDefault(const ADefault: T): T;
var
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise return default! }
  if not Enum.MoveNext() then
    Exit(ADefault);

  { Iterate till the last element in the enum }
  while true do
  begin
    Result := Enum.Current;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexCollection<T>.Max: T;
var
  Tps: IType<T>;
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();
  Tps := ElementType;

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := Enum.Current;

  { Iterate till the last element in the enum }
  while true do
  begin
    if Tps.Compare(Enum.Current, Result) > 0 then
      Result := Enum.Current;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexCollection<T>.Min: T;
var
  LType: IType<T>;
  Enum: IEnumerator<T>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();
  LType := ElementType;

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := Enum.Current;

  { Iterate till the last element in the enum }
  while true do
  begin
    if LType.Compare(Enum.Current, Result) < 0 then
      Result := Enum.Current;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexCollection<T>.Op: TEnexExtOps<T>;
begin
  { Build up the record + keep an optional reference to the object }
  Result.FInstance := Self;
  Result.FKeepAlive := Self.ExtractReference;
  Result.FType := FElementType;
end;

function TEnexCollection<T>.Range(const AStart, AEnd: NativeUInt): IEnexCollection<T>;
begin
  { Create a new Enex collection }
  Result := TEnexRangeCollection<T>.Create(Self, AStart, AEnd);
end;

function TEnexCollection<T>.Reversed: IEnexCollection<T>;
var
  List: TList<T>;
begin
  { Create an itermediary list }
  List := TList<T>.Create(Self);
  List.Reverse();

  { Pass the list further }
  Result := List;
end;

procedure TEnexCollection<T>.Serialize(const AData: TSerializationData);
var
  LEnum: IEnumerator<T>;
begin
  { Retrieve the enumerator object and type }
  LEnum := GetEnumerator();

  { Mark the start }
  StartSerializing(AData);

  AData.StartListBlock(SSerElements, FElementType.TypeInfo, Count);

  { Serialize all elements in }
  while LEnum.MoveNext() do
    FElementType.Serialize(LEnum.Current, AData);

  { Mark the end }
  AData.EndBlock();

  EndSerializing(AData);
end;

function TEnexCollection<T>.Skip(const ACount: NativeUInt): IEnexCollection<T>;
begin
  { Check parameters }
  if ACount = 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  { Create a new Enex collection }
  Result := TEnexSkipCollection<T>.Create(Self, ACount);
end;

function TEnexCollection<T>.SkipWhile(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Create a new Enex collection }
  Result := TEnexSkipWhileCollection<T>.Create(Self, APredicate);
end;

function TEnexCollection<T>.SkipWhileBetween(const ALower, AHigher: T): IEnexCollection<T>;
var
  LLower, LHigher: T;
  LType: IType<T>;
begin
  { Locals }
  LLower := ALower;
  LHigher := AHigher;
  LType := ElementType;

  { Use SkipWhile() and pass an anonymous function }
  Result := SkipWhile(
    function(Arg1: T): Boolean
    begin
      Exit((LType.Compare(Arg1, LLower) >= 0) and (LType.Compare(Arg1, LHigher) <= 0));
    end
  );
end;

function TEnexCollection<T>.SkipWhileGreater(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use SkipWhile() and pass an anonymous function }
  Result := SkipWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) > 0);
    end
  );
end;

function TEnexCollection<T>.SkipWhileGreaterOrEqual(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use SkipWhile() and pass an anonymous function }
  Result := SkipWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) >= 0);
    end
  );
end;

function TEnexCollection<T>.SkipWhileLower(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use SkipWhile() and pass an anonymous function }
  Result := SkipWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) < 0);
    end
  );
end;

function TEnexCollection<T>.SkipWhileLowerOrEqual(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use SkipWhile() and pass an anonymous function }
  Result := SkipWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) <= 0);
    end
  );
end;

function TEnexCollection<T>.Ordered(const ASortProc: TCompareOverride<T>): IEnexCollection<T>;
var
  List: TList<T>;
begin
  { Create an itermediary list }
  List := TList<T>.Create(Self);
  List.Sort(ASortProc);

  { Pass the list further }
  Result := List;
end;

function TEnexCollection<T>.Ordered(const AAscending: Boolean = true): IEnexCollection<T>;
var
  List: TList<T>;
begin
  { Create an itermediary list }
  List := TList<T>.Create(Self);
  List.Sort(AAscending);

  { Pass the list further }
  Result := List;
end;

function TEnexCollection<T>.Take(const ACount: NativeUInt): IEnexCollection<T>;
begin
  { Check parameters }
  if ACount = 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  { Create a new Enex collection }
  Result := TEnexTakeCollection<T>.Create(Self, ACount);
end;

function TEnexCollection<T>.TakeWhile(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Create a new Enex collection }
  Result := TEnexTakeWhileCollection<T>.Create(Self, APredicate);
end;

function TEnexCollection<T>.TakeWhileBetween(const ALower, AHigher: T): IEnexCollection<T>;
var
  LLower, LHigher: T;
  LType: IType<T>;
begin
  { Locals }
  LLower := ALower;
  LHigher := AHigher;
  LType := ElementType;

  { Use TakeWhile() and pass an anonymous function }
  Result := TakeWhile(
    function(Arg1: T): Boolean
    begin
      Exit((LType.Compare(Arg1, LLower) >= 0) and (LType.Compare(Arg1, LHigher) <= 0));
    end
  );
end;

function TEnexCollection<T>.TakeWhileGreater(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use TakeWhile() and pass an anonymous function }
  Result := TakeWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) > 0);
    end
  );
end;

function TEnexCollection<T>.TakeWhileGreaterOrEqual(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use TakeWhile() and pass an anonymous function }
  Result := TakeWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) >= 0);
    end
  );
end;

function TEnexCollection<T>.TakeWhileLower(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use TakeWhile() and pass an anonymous function }
  Result := TakeWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) < 0);
    end
  );
end;

function TEnexCollection<T>.TakeWhileLowerOrEqual(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use TakeWhile() and pass an anonymous function }
  Result := TakeWhile(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) <= 0);
    end
  );
end;

function TEnexCollection<T>.ToList: IList<T>;
begin
  { Simply make up a list }
  Result := TList<T>.Create(Self);
end;

function TEnexCollection<T>.ToSet: ISet<T>;
begin
  { Simply make up a bag }
  Result := THashSet<T>.Create(Self);
end;

function TEnexCollection<T>.Union(const ACollection: IEnumerable<T>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Create concatenation iterator }
  Result := TEnexUnionCollection<T>.CreateIntf2(Self, ACollection, ElementType);
end;

function TEnexCollection<T>.Where(const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Create a new Enex collection }
  Result := TEnexWhereCollection<T>.Create(Self, APredicate, False); // Don't invert the result
end;

function TEnexCollection<T>.WhereBetween(const ALower, AHigher: T): IEnexCollection<T>;
var
  LLower, LHigher: T;
  LType: IType<T>;
begin
  { Locals }
  LLower := ALower;
  LHigher := AHigher;
  LType := ElementType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: T): Boolean
    begin
      Exit((LType.Compare(Arg1, LLower) >= 0) and (LType.Compare(Arg1, LHigher) <= 0));
    end
  );
end;

function TEnexCollection<T>.WhereGreater(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) > 0);
    end
  );
end;

function TEnexCollection<T>.WhereGreaterOrEqual(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) >= 0);
    end
  );
end;

function TEnexCollection<T>.WhereLower(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) < 0);
    end
  );
end;

function TEnexCollection<T>.WhereLowerOrEqual(const ABound: T): IEnexCollection<T>;
var
  LBound: T;
  LType: IType<T>;
begin
  { Locals }
  LBound := ABound;
  LType := ElementType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: T): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) <= 0);
    end
  );
end;

function TEnexCollection<T>.WhereNot(
  const APredicate: TFunc<T, Boolean>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Create a new Enex collection }
  Result := TEnexWhereCollection<T>.Create(Self, APredicate, True); // Invert the result
end;

{ TEnexAssociativeCollection<TKey, TValue> }

constructor TEnexAssociativeCollection<TKey, TValue>.Create;
begin
  InstallTypes(TType<TKey>.Default, TType<TValue>.Default);
end;

procedure TEnexAssociativeCollection<TKey, TValue>.Deserialize(const AData: TDeserializationData);
var
  I, LCount: NativeUInt;
  LKey: TKey;
  LValue: TValue;
begin
  StartDeserializing(AData);

  { Open up the composite }
  LCount := AData.ExpectListBlock(SSerElements, SSerPair);

  if LCount > 0 then
    for I := 0 to LCount - 1 do
    begin
      { Open the scope for the K/V pair }
      AData.ExpectBlock();

      { Obtain the element }
      FKeyType.Deserialize(SSerKey, LKey, AData);
      FValueType.Deserialize(SSerValue, LValue, AData);

      AData.EndBlock();

      { Add it to the collection }
      DeserializePair(LKey, LValue);
    end;

  { Stop the process }
  AData.EndBlock();
  EndDeserializing(AData);
end;

procedure TEnexAssociativeCollection<TKey, TValue>.DeserializePair(const AKey: TKey; const AValue: TValue);
begin
  // Nothing here ...
end;

function TEnexAssociativeCollection<TKey, TValue>.DistinctByKeys: IEnexAssociativeCollection<TKey, TValue>;
begin
  Result := TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.Create(Self);
end;

function TEnexAssociativeCollection<TKey, TValue>.DistinctByValues: IEnexAssociativeCollection<TKey, TValue>;
begin
  Result := TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.Create(Self);
end;

function TEnexAssociativeCollection<TKey, TValue>.Includes(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>): Boolean;
var
  Enum: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Retrieve the enumerator object }
  Enum := AEnumerable.GetEnumerator();

  { Iterate till the last element in the enum }
  while Enum.MoveNext do
  begin
    if not KeyHasValue(Enum.Current.Key, Enum.Current.Value) then
      Exit(false);
  end;

  { We got here, it means all is OK }
  Result := true;
end;

procedure TEnexAssociativeCollection<TKey, TValue>.InstallTypes(const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
begin
  FKeyType := AKeyType;
  FValueType := AValueType;
end;

function TEnexAssociativeCollection<TKey, TValue>.KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean;
var
  Enum: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Iterate till the last element in the enum }
  while Enum.MoveNext do
  begin
    if KeyType.AreEqual(Enum.Current.Key, AKey) and
       ValueType.AreEqual(Enum.Current.Value, AValue) then
      Exit(true);
  end;

  { No found! }
  Result := false;
end;

function TEnexAssociativeCollection<TKey, TValue>.MaxKey: TKey;
var
  Enum: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := Enum.Current.Key;

  { Iterate till the last element in the enum }
  while true do
  begin
    if KeyType.Compare(Enum.Current.Key, Result) > 0 then
      Result := Enum.Current.Key;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexAssociativeCollection<TKey, TValue>.MaxValue: TValue;
var
  Enum: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := Enum.Current.Value;

  { Iterate till the last element in the enum }
  while true do
  begin
    if ValueType.Compare(Enum.Current.Value, Result) > 0 then
      Result := Enum.Current.Value;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexAssociativeCollection<TKey, TValue>.MinKey: TKey;
var
  Enum: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := Enum.Current.Key;

  { Iterate till the last element in the enum }
  while true do
  begin
    if KeyType.Compare(Enum.Current.Key, Result) < 0 then
      Result := Enum.Current.Key;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexAssociativeCollection<TKey, TValue>.MinValue: TValue;
var
  Enum: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Get the first object in the enumeration, otherwise fail! }
  if not Enum.MoveNext() then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := Enum.Current.Value;

  { Iterate till the last element in the enum }
  while true do
  begin
    if ValueType.Compare(Enum.Current.Value, Result) < 0 then
      Result := Enum.Current.Value;

    { Exit if we hit the last element }
    if not Enum.MoveNext() then
      Exit;
  end;
end;

function TEnexAssociativeCollection<TKey, TValue>.SelectKeys: IEnexCollection<TKey>;
begin
  { Create a selector }
  Result := TEnexSelectKeysCollection<TKey, TValue>.Create(Self);
end;

function TEnexAssociativeCollection<TKey, TValue>.SelectValues: IEnexCollection<TValue>;
begin
  { Create a selector }
  Result := TEnexSelectValuesCollection<TKey, TValue>.Create(Self);
end;

procedure TEnexAssociativeCollection<TKey, TValue>.Serialize(const AData: TSerializationData);
var
  LEnum: IEnumerator<KVPair<TKey, TValue>>;
  LKeyInfo, LValInfo, LElemInfo: TValueInfo;
begin
  { Retrieve the enumerator object and type }
  LEnum := GetEnumerator();

  LKeyInfo := TValueInfo.Create(SSerKey);
  LValInfo := TValueInfo.Create(SSerValue);
  LElemInfo := TValueInfo.Indexed;

  { Mark the start }
  StartSerializing(AData);

  AData.StartListBlock(SSerElements, SSerPair, Count);

  { Serialize all elements in }
  while LEnum.MoveNext() do
  begin
    { Open the scope for the K/V pair }
    AData.StartBlock();

    { Serialize the K/V pair }
    FKeyType.Serialize(SSerKey, LEnum.Current.Key, AData);
    FValueType.Serialize(SSerValue, LEnum.Current.Value, AData);

    AData.EndBlock();
  end;

  { The end }
  AData.EndBlock();

  EndSerializing(AData);
end;

function TEnexAssociativeCollection<TKey, TValue>.ToDictionary: IDictionary<TKey, TValue>;
begin
  Result := TDictionary<TKey, TValue>.Create(Self);
end;

function TEnexAssociativeCollection<TKey, TValue>.ValueForKey(const AKey: TKey): TValue;
var
  Enum: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Retrieve the enumerator object and type }
  Enum := GetEnumerator();

  { Iterate till the last element in the enum }
  while Enum.MoveNext do
  begin
    if KeyType.AreEqual(Enum.Current.Key, AKey) then
      Exit(Enum.Current.Value);
  end;

  { If nothing found, simply raise an exception }
  ExceptionHelper.Throw_KeyNotFoundError(KeyType.GetString(AKey));
end;

function TEnexAssociativeCollection<TKey, TValue>.Where(
  const APredicate: TFunc<TKey, TValue, Boolean>): IEnexAssociativeCollection<TKey, TValue>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Create a new Enex collection }
  Result := TEnexAssociativeWhereCollection<TKey, TValue>.Create(Self, APredicate, False); // Don't invert the result
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereKeyBetween(const ALower,
  AHigher: TKey): IEnexAssociativeCollection<TKey, TValue>;
var
  LLower, LHigher: TKey;
  LType: IType<TKey>;
begin
  { Locals }
  LLower := ALower;
  LHigher := AHigher;

  LType := KeyType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit((LType.Compare(Arg1, LLower) >= 0) and (LType.Compare(Arg1, LHigher) <= 0));
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereKeyGreater(
  const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TKey;
  LType: IType<TKey>;
begin
  { Locals }
  LBound := ABound;

  LType := KeyType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) > 0);
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereKeyGreaterOrEqual(
  const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TKey;
  LType: IType<TKey>;
begin
  { Locals }
  LBound := ABound;

  LType := KeyType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) >= 0);
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereKeyLower(
  const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TKey;
  LType: IType<TKey>;
begin
  { Locals }
  LBound := ABound;

  LType := KeyType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) < 0);
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereKeyLowerOrEqual(
  const ABound: TKey): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TKey;
  LType: IType<TKey>;
begin
  { Locals }
  LBound := ABound;

  LType := KeyType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg1, LBound) <= 0);
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereNot(
  const APredicate: TFunc<TKey, TValue, Boolean>): IEnexAssociativeCollection<TKey, TValue>;
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  { Create a new Enex collection }
  Result := TEnexAssociativeWhereCollection<TKey, TValue>.Create(Self, APredicate, True); // Invert the result
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereValueBetween(
  const ALower, AHigher: TValue): IEnexAssociativeCollection<TKey, TValue>;
var
  LLower, LHigher: TValue;
  LType: IType<TValue>;
begin
  { Locals }
  LLower := ALower;
  LHigher := AHigher;

  LType := ValueType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit((LType.Compare(Arg2, LLower) >= 0) and (LType.Compare(Arg2, LHigher) <= 0));
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereValueGreater(
  const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TValue;
  LType: IType<TValue>;
begin
  { Locals }
  LBound := ABound;

  LType := ValueType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg2, LBound) > 0);
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereValueGreaterOrEqual(
  const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TValue;
  LType: IType<TValue>;
begin
  { Locals }
  LBound := ABound;

  LType := ValueType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg2, LBound) >= 0);
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereValueLower(
  const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TValue;
  LType: IType<TValue>;
begin
  { Locals }
  LBound := ABound;

  LType := ValueType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg2, LBound) < 0);
    end
  );
end;

function TEnexAssociativeCollection<TKey, TValue>.WhereValueLowerOrEqual(
  const ABound: TValue): IEnexAssociativeCollection<TKey, TValue>;
var
  LBound: TValue;
  LType: IType<TValue>;
begin
  { Locals }
  LBound := ABound;

  LType := ValueType;

  { Use Where() and pass an anonymous function }
  Result := Where(
    function(Arg1: TKey; Arg2: TValue): Boolean
    begin
      Exit(LType.Compare(Arg2, LBound) <= 0);
    end
  );
end;


{ TEnexWhereCollection<T> }

constructor TEnexWhereCollection<T>.Create(const AEnumerable: TEnexCollection<T>;
  const APredicate: TFunc<T, Boolean>; const AInvertResult: Boolean);
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Installing the element type }
  InstallType(AEnumerable.ElementType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FPredicate := APredicate;
  FDeleteEnum := false;
  FInvertResult := AInvertResult;
end;

constructor TEnexWhereCollection<T>.CreateIntf(
  const AEnumerable: IEnumerable<T>;
  const APredicate: TFunc<T, Boolean>;
  const AType: IType<T>;
  const AInvertResult: Boolean);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, AType), APredicate, AInvertResult);

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexWhereCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexWhereCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexWhereCollection<T>.TEnumerator }

constructor TEnexWhereCollection<T>.TEnumerator.Create(const AEnum: TEnexWhereCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter:= AEnum.FEnum.GetEnumerator();
end;

destructor TEnexWhereCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexWhereCollection<T>.TEnumerator.GetCurrent: T;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FIter.Current;
end;

function TEnexWhereCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  { Iterate until given condition is met on an element }
  while True do
  begin
    Result := FIter.MoveNext;

    { Terminate on sub-enum termination }
    if not Result then
      Exit;

    { Check whether the current element meets the condition and exit }
    { ... otherwise continue to the next iteration }
    if FEnum.FPredicate(FIter.Current) xor FEnum.FInvertResult then
      Exit;
  end;
end;

{ TEnexSelectCollection<T, TOut> }

constructor TEnexSelectCollection<T, TOut>.Create(const AEnumerable: TEnexCollection<T>;
  const ASelector: TFunc<T, TOut>; const AType: IType<TOut>);
begin
  { Check arguments }
  if not Assigned(ASelector) then
    ExceptionHelper.Throw_ArgumentNilError('ASelector');

  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Installing the element type }
  InstallType(AType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FSelector := ASelector;
  FDeleteEnum := false;
end;

constructor TEnexSelectCollection<T, TOut>.CreateIntf(
  const AEnumerable: IEnumerable<T>;
  const ASelector: TFunc<T, TOut>;
  const AType: IType<TOut>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, TType<T>.Default), ASelector, AType);

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexSelectCollection<T, TOut>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexSelectCollection<T, TOut>.ElementAt(const Index: NativeUInt): TOut;
begin
  Result := FSelector(FEnum.ElementAt(Index));
end;

function TEnexSelectCollection<T, TOut>.Empty: Boolean;
begin
  Result := FEnum.Empty;
end;

function TEnexSelectCollection<T, TOut>.First: TOut;
begin
  Result := FSelector(FEnum.First);
end;

function TEnexSelectCollection<T, TOut>.GetCount: NativeUInt;
begin
  Result := FEnum.GetCount();
end;

function TEnexSelectCollection<T, TOut>.GetEnumerator: IEnumerator<TOut>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

function TEnexSelectCollection<T, TOut>.Last: TOut;
begin
  Result := FSelector(FEnum.Last);
end;

function TEnexSelectCollection<T, TOut>.Single: TOut;
begin
  Result := FSelector(FEnum.Single);
end;

{ TEnexSelectCollection<T, TOut>.TEnumerator }

constructor TEnexSelectCollection<T, TOut>.TEnumerator.Create(const AEnum: TEnexSelectCollection<T, TOut>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
  FCurrent := default(TOut);
end;

destructor TEnexSelectCollection<T, TOut>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexSelectCollection<T, TOut>.TEnumerator.GetCurrent: TOut;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FCurrent;
end;

function TEnexSelectCollection<T, TOut>.TEnumerator.MoveNext: Boolean;
begin
  { Next iteration }
  Result := FIter.MoveNext;

  { Terminate on sub-enum termination }
  if not Result then
    Exit;

  { Return the next "selected" element }
  FCurrent := FEnum.FSelector(FIter.Current);
end;

{ TEnexCastCollection<T, TOut> }

constructor TEnexCastCollection<T, TOut>.Create(const AEnumerable: TEnexCollection<T>; const AOutType: IType<TOut>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  if not Assigned(AOutType) then
    ExceptionHelper.Throw_ArgumentNilError('AOutType');

  { Installing the element type }
  InstallType(AOutType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FDeleteEnum := false;

  { Create converter }
  FConverter := TConverter<T, TOut>.Create(FEnum.ElementType, AOutType);
end;

constructor TEnexCastCollection<T, TOut>.CreateIntf(
  const AEnumerable: IEnumerable<T>;
  const AInType: IType<T>; const AOutType: IType<TOut>);
begin
  { Call the upper constructor }
  try
    Create(TEnexWrapCollection<T>.Create(AEnumerable, AInType), AOutType);
  finally
    { Mark enumerable to be deleted }
    FDeleteEnum := true;
  end;
end;

destructor TEnexCastCollection<T, TOut>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexCastCollection<T, TOut>.ElementAt(const Index: NativeUInt): TOut;
begin
  Result := FConverter.Convert(FEnum.ElementAt(Index));
end;

function TEnexCastCollection<T, TOut>.Empty: Boolean;
begin
  Result := FEnum.Empty;
end;

function TEnexCastCollection<T, TOut>.First: TOut;
begin
  Result := FConverter.Convert(FEnum.First);
end;

function TEnexCastCollection<T, TOut>.GetCount: NativeUInt;
begin
  Result := FEnum.GetCount();
end;

function TEnexCastCollection<T, TOut>.GetEnumerator: IEnumerator<TOut>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

function TEnexCastCollection<T, TOut>.Last: TOut;
begin
  Result := FConverter.Convert(FEnum.Last());
end;

function TEnexCastCollection<T, TOut>.Single: TOut;
begin
  Result := FConverter.Convert(FEnum.Single);
end;

{ TEnexCastCollection<T, TOut>.TEnumerator }

constructor TEnexCastCollection<T, TOut>.TEnumerator.Create(const AEnum: TEnexCastCollection<T, TOut>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter:= AEnum.FEnum.GetEnumerator();
  FCurrent := default(TOut);
end;

destructor TEnexCastCollection<T, TOut>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexCastCollection<T, TOut>.TEnumerator.GetCurrent: TOut;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FCurrent;
end;

function TEnexCastCollection<T, TOut>.TEnumerator.MoveNext: Boolean;
begin
  { Next iteration }
  Result := FIter.MoveNext;

  { Terminate on sub-enum termination }
  if not Result then
    Exit;

  { Return the next "casted" element }
  FCurrent := FEnum.FConverter.Convert(FIter.Current);
end;

{ TEnexConcatCollection<T> }

constructor TEnexConcatCollection<T>.CreateIntf2(
      const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(AEnumerable1, TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum2 := true;
end;

constructor TEnexConcatCollection<T>.CreateIntf(
  const AEnumerable1, AEnumerable2: IEnumerable<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType),
         TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
  FDeleteEnum2 := true;
end;

function TEnexConcatCollection<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  Result := FEnum1.All(APredicate) and FEnum2.All(APredicate);
end;

function TEnexConcatCollection<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  Result := FEnum1.Any(APredicate) or FEnum2.Any(APredicate);
end;

constructor TEnexConcatCollection<T>.Create(
  const AEnumerable1, AEnumerable2: TEnexCollection<T>);
begin
  { Check arguments }
  if not Assigned(AEnumerable1) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable1');

  if not Assigned(AEnumerable2) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable2');

  { Installing the element type }
  InstallType(AEnumerable1.ElementType);

  { Assign internals }
  FEnum1 := AEnumerable1;
  KeepObjectAlive(FEnum1);

  FEnum2 := AEnumerable2;
  KeepObjectAlive(FEnum2);

  FDeleteEnum1 := false;
  FDeleteEnum2 := false;
end;

constructor TEnexConcatCollection<T>.CreateIntf1(
  const AEnumerable1: IEnumerable<T>;
  const AEnumerable2: TEnexCollection<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType), AEnumerable2);

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
end;

destructor TEnexConcatCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum1, FDeleteEnum1);
  ReleaseObject(FEnum2, FDeleteEnum2);

  inherited;
end;

function TEnexConcatCollection<T>.Empty: Boolean;
begin
  Result := (GetCount = 0);
end;

function TEnexConcatCollection<T>.GetCount: NativeUInt;
begin
  Result := FEnum1.GetCount() + FEnum2.GetCount();
end;

function TEnexConcatCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexConcatCollection<T>.TEnumerator }

constructor TEnexConcatCollection<T>.TEnumerator .Create(const AEnum: TEnexConcatCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter1 := AEnum.FEnum1.GetEnumerator();
  FIter2 := AEnum.FEnum2.GetEnumerator();
end;

destructor TEnexConcatCollection<T>.TEnumerator .Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexConcatCollection<T>.TEnumerator .GetCurrent: T;
begin
  { Pass the first and then the last }
  if FIter1 <> nil then
    Result := FIter1.Current
  else
    Result := FIter2.Current;
end;

function TEnexConcatCollection<T>.TEnumerator .MoveNext: Boolean;
begin
  if FIter1 <> nil then
  begin
    { Iterate over 1 }
    Result := FIter1.MoveNext();

    { Succesefully iterated collection 1 }
    if Result then
      Exit;

    { We've reached the bottom of 1 }
    FIter1 := nil;
  end;

  { Iterate over 2 now }
  Result := FIter2.MoveNext();
end;

{ TEnexUnionCollection<T> }

constructor TEnexUnionCollection<T>.CreateIntf2(
      const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(AEnumerable1, TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum2 := true;
end;

constructor TEnexUnionCollection<T>.CreateIntf(
  const AEnumerable1, AEnumerable2: IEnumerable<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType),
         TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
  FDeleteEnum2 := true;
end;

constructor TEnexUnionCollection<T>.Create(
  const AEnumerable1, AEnumerable2: TEnexCollection<T>);
begin
  { Check arguments }
  if not Assigned(AEnumerable1) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable1');

  if not Assigned(AEnumerable2) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable2');

  { Installing the element type }
  InstallType(AEnumerable1.ElementType);

  { Assign internals }
  FEnum1 := AEnumerable1;
  KeepObjectAlive(FEnum1);

  FEnum2 := AEnumerable2;
  KeepObjectAlive(FEnum2);

  FDeleteEnum1 := false;
  FDeleteEnum2 := false;
end;

constructor TEnexUnionCollection<T>.CreateIntf1(
  const AEnumerable1: IEnumerable<T>;
  const AEnumerable2: TEnexCollection<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType), AEnumerable2);

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
end;

destructor TEnexUnionCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum1, FDeleteEnum1);
  ReleaseObject(FEnum2, FDeleteEnum2);

  inherited;
end;

function TEnexUnionCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexUnionCollection<T>.TEnumerator }

constructor TEnexUnionCollection<T>.TEnumerator .Create(const AEnum: TEnexUnionCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter1 := AEnum.FEnum1.GetEnumerator();
  FIter2 := AEnum.FEnum2.GetEnumerator();

  { Create an internal set }
  FSet := THashSet<T>.Create(TSuppressedWrapperType<T>.Create(AEnum.FEnum1.ElementType));
end;

destructor TEnexUnionCollection<T>.TEnumerator .Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexUnionCollection<T>.TEnumerator .GetCurrent: T;
begin
  { Pass the first and then the last }
  if FIter1 <> nil then
    Result := FIter1.Current
  else
    Result := FIter2.Current;
end;

function TEnexUnionCollection<T>.TEnumerator .MoveNext: Boolean;
begin
  if FIter1 <> nil then
  begin
    { Iterate over 1 }
    Result := FIter1.MoveNext();

    { Succesefully iterated collection 1 }
    if Result then
    begin
      { Add the element to the set }
      FSet.Add(FIter1.Current);
      Exit;
    end;

    { We've reached the bottom of 1 }
    FIter1 := nil;
  end;

  { Continue until we find what we need or we get to the bottom }
  while True do
  begin
    { Iterate over 2 now }
    Result := FIter2.MoveNext();

    { Exit on bad result }
    if not Result then
      Exit;

    { Exit if the element is good }
    if not FSet.Contains(FIter2.Current) then
    begin
      FSet.Add(FIter2.Current);
      Exit;
    end;
  end;
end;

{ TEnexExclusionCollection<T> }

constructor TEnexExclusionCollection<T>.CreateIntf2(
      const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(AEnumerable1, TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum2 := true;
end;

constructor TEnexExclusionCollection<T>.CreateIntf(
  const AEnumerable1, AEnumerable2: IEnumerable<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType),
         TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
  FDeleteEnum2 := true;
end;

constructor TEnexExclusionCollection<T>.Create(
  const AEnumerable1, AEnumerable2: TEnexCollection<T>);
begin
  { Check arguments }
  if not Assigned(AEnumerable1) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable1');

  if not Assigned(AEnumerable2) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable2');

  { Installing the element type }
  InstallType(AEnumerable1.ElementType);

  { Assign internals }
  FEnum1 := AEnumerable1;
  KeepObjectAlive(FEnum1);

  FEnum2 := AEnumerable2;
  KeepObjectAlive(FEnum2);

  FDeleteEnum1 := false;
  FDeleteEnum2 := false;
end;

constructor TEnexExclusionCollection<T>.CreateIntf1(
  const AEnumerable1: IEnumerable<T>;
  const AEnumerable2: TEnexCollection<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType), AEnumerable2);

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
end;

destructor TEnexExclusionCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum1, FDeleteEnum1);
  ReleaseObject(FEnum2, FDeleteEnum2);

  inherited;
end;

function TEnexExclusionCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexExclusionCollection<T>.TEnumerator }

constructor TEnexExclusionCollection<T>.TEnumerator .Create(const AEnum: TEnexExclusionCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum1.GetEnumerator();

  { Create an internal set }
  FSet := THashSet<T>.Create(TSuppressedWrapperType<T>.Create(AEnum.FEnum1.ElementType), AEnum.FEnum2);
end;

destructor TEnexExclusionCollection<T>.TEnumerator .Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexExclusionCollection<T>.TEnumerator .GetCurrent: T;
begin
  { Pass 1's enumerator }
  Result := FIter.Current;
end;

function TEnexExclusionCollection<T>.TEnumerator .MoveNext: Boolean;
begin
  { Continue until we find what we need or we get to the bottom }
  while True do
  begin
    { Iterate over 1 }
    Result := FIter.MoveNext();

    { Exit on bad result }
    if not Result then
      Exit;

    { Exit if the element is good }
    if not FSet.Contains(FIter.Current) then
      Exit;
  end;
end;


{ TEnexIntersectionCollection<T> }

constructor TEnexIntersectionCollection<T>.CreateIntf2(
      const AEnumerable1: TEnexCollection<T>;
      const AEnumerable2: IEnumerable<T>; const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(AEnumerable1, TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum2 := true;
end;

constructor TEnexIntersectionCollection<T>.CreateIntf(
  const AEnumerable1, AEnumerable2: IEnumerable<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType),
         TEnexWrapCollection<T>.Create(AEnumerable2, AType));

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
  FDeleteEnum2 := true;
end;

constructor TEnexIntersectionCollection<T>.Create(
  const AEnumerable1, AEnumerable2: TEnexCollection<T>);
begin
  { Check arguments }
  if not Assigned(AEnumerable1) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable1');

  if not Assigned(AEnumerable2) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable2');

  { Installing the element type }
  InstallType(AEnumerable1.ElementType);

  { Assign internals }
  FEnum1 := AEnumerable1;
  KeepObjectAlive(FEnum1);

  FEnum2 := AEnumerable2;
  KeepObjectAlive(FEnum2);

  FDeleteEnum1 := false;
  FDeleteEnum2 := false;
end;

constructor TEnexIntersectionCollection<T>.CreateIntf1(
  const AEnumerable1: IEnumerable<T>;
  const AEnumerable2: TEnexCollection<T>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable1, AType), AEnumerable2);

  { Mark enumerables to be deleted }
  FDeleteEnum1 := true;
end;

destructor TEnexIntersectionCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum1, FDeleteEnum1);
  ReleaseObject(FEnum2, FDeleteEnum2);

  inherited;
end;

function TEnexIntersectionCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create enumerator }
  Result := TEnumerator.Create(Self);
end;

{ Collection.EnexIntersectionCollection<T>.TEnumerator }

constructor TEnexIntersectionCollection<T>.TEnumerator .Create(const AEnum: TEnexIntersectionCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum1.GetEnumerator();

  { Create an internal set }
  FSet := THashSet<T>.Create(TSuppressedWrapperType<T>.Create(AEnum.FEnum1.ElementType), AEnum.FEnum2);
end;

destructor TEnexIntersectionCollection<T>.TEnumerator .Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexIntersectionCollection<T>.TEnumerator .GetCurrent: T;
begin
  { Pass 1's enumerator }
  Result := FIter.Current;
end;

function TEnexIntersectionCollection<T>.TEnumerator .MoveNext: Boolean;
begin
  { Continue until we find what we need or we get to the bottom }
  while True do
  begin
    { Iterate over 1 }
    Result := FIter.MoveNext();

    { Exit on bad result }
    if not Result then
      Exit;

    { Exit if the element is good }
    if FSet.Contains(FIter.Current) then
      Exit;
  end;
end;

{ TEnexRangeCollection<T> }

constructor TEnexRangeCollection<T>.Create(
  const AEnumerable: TEnexCollection<T>; const AStart,
  AEnd: NativeUInt);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Installing the element type }
  InstallType(AEnumerable.ElementType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FStart := AStart;
  FEnd := AEnd;
  FDeleteEnum := false;
end;

constructor TEnexRangeCollection<T>.CreateIntf(
  const AEnumerable: IEnumerable<T>; const AStart,
  AEnd: NativeUInt; const AType: IType<T>);
begin
  { Call upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, AType), AStart, AEnd);

  { Mark for destruction }
  FDeleteEnum := true;
end;

destructor TEnexRangeCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexRangeCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create the enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexRangeCollection<T>.TEnumerator }

constructor TEnexRangeCollection<T>.TEnumerator.Create(const AEnum: TEnexRangeCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
  FIdx  := 0;
end;

destructor TEnexRangeCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexRangeCollection<T>.TEnumerator.GetCurrent: T;
begin
  { PAss the current in the sub-enum }
  Result := FIter.Current;
end;

function TEnexRangeCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  { Skip the required amount of elements }
  if (FIdx <= FEnum.FStart) then
  begin
    while (FIdx <= FEnum.FStart) do
    begin
      { Move cursor }
      Result := FIter.MoveNext();

      if not Result then
        Exit;

      Inc(FIdx);
    end;
  end else
  begin
    { Check if we're finished }
    if (FIdx > FEnum.FEnd) then
      Exit(false);

    { Move the cursor next in the sub-enum, and increase index }
    Result := FIter.MoveNext();
    Inc(FIdx);
  end;
end;

{ TEnexWrapCollection<T> }

constructor TEnexWrapCollection<T>.Create(const AEnumerable: IEnumerable<T>; const AType: IType<T>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Install the type }
  InstallType(AType);

  { Assign internals }
  FEnum := AEnumerable;
end;

function TEnexWrapCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Generate an enumerable from the sub-enum }
  Result := FEnum.GetEnumerator();
end;

{ TEnexDistinctCollection<T> }

constructor TEnexDistinctCollection<T>.Create(const AEnumerable: TEnexCollection<T>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Installing the element type }
  InstallType(AEnumerable.ElementType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FDeleteEnum := false;
end;

constructor TEnexDistinctCollection<T>.CreateIntf(const AEnumerable: IEnumerable<T>; const AType: IType<T>);
begin
  { Call the higher constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, AType));

  { Mark for deletion }
  FDeleteEnum := true;
end;

destructor TEnexDistinctCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexDistinctCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexDistinctCollection<T>.TEnumerator }

constructor TEnexDistinctCollection<T>.TEnumerator.Create(const AEnum: TEnexDistinctCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();

  { Create an internal set }
  FSet := THashSet<T>.Create(TSuppressedWrapperType<T>.Create(AEnum.FEnum.ElementType));
end;

destructor TEnexDistinctCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexDistinctCollection<T>.TEnumerator.GetCurrent: T;
begin
  { Get from sub-enum }
  Result := FIter.Current;
end;

function TEnexDistinctCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  while True do
  begin
    { Iterate }
    Result := FIter.MoveNext;

    if not Result then
      Exit;

    { If the item is distinct, add it to set and continue }
    if not FSet.Contains(FIter.Current) then
    begin
      FSet.Add(FIter.Current);
      Exit;
    end;
  end;
end;

{ TEnexFillCollection<T> }

function TEnexFillCollection<T>.Aggregate(const AAggregator: TFunc<T, T, T>): T;
var
  I: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Select the first element as comparison base }
  Result := FElement;

  { Iterate over the last N - 1 elements }
  for I := 1 to FCount - 1 do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, FElement);
  end;
end;

function TEnexFillCollection<T>.AggregateOrDefault(const AAggregator: TFunc<T, T, T>; const ADefault: T): T;
var
  I: NativeUInt;
begin
  { Check arguments }
  if not Assigned(AAggregator) then
    ExceptionHelper.Throw_ArgumentNilError('AAggregator');

  if FCount = 0 then
    Exit(ADefault);

  { Select the first element as comparison base }
  Result := FElement;

  { Iterate over the last N - 1 elements }
  for I := 1 to FCount - 1 do
  begin
    { Aggregate a value }
    Result := AAggregator(Result, FElement);
  end;
end;

function TEnexFillCollection<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if not APredicate(FElement) then
    Result := false
  else
    Result := true;
end;

function TEnexFillCollection<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if APredicate(FElement) then
    Result := true
  else
    Result := false;
end;

constructor TEnexFillCollection<T>.Create(const AElement: T; const Count: NativeUInt; const AType: IType<T>);
begin
  if Count = 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('Count');

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Install the type }
  InstallType(AType);

  { Copy values in }
  FCount := Count;
  FElement := AElement;
end;

function TEnexFillCollection<T>.ElementAt(const Index: NativeUInt): T;
begin
  if Index = FCount then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');

  Result := FElement;
end;

function TEnexFillCollection<T>.ElementAtOrDefault(const Index: NativeUInt; const ADefault: T): T;
begin
  if Index = FCount then
    Result := ADefault
  else
    Result := FElement;
end;

function TEnexFillCollection<T>.Empty: Boolean;
begin
  Result := (FCount = 0);
end;

function TEnexFillCollection<T>.EqualsTo(const AEnumerable: IEnumerable<T>): Boolean;
var
  V: T;
  I: NativeUInt;
begin
  I := 0;

  for V in AEnumerable do
  begin
    if I >= FCount then
      Exit(false);

    if not ElementType.AreEqual(FElement, V) then
      Exit(false);

    Inc(I);
  end;

  if I < FCount then
    Exit(false);

  Result := true;
end;

function TEnexFillCollection<T>.First: T;
begin
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FElement;
end;

function TEnexFillCollection<T>.FirstOrDefault(const ADefault: T): T;
begin
  if FCount = 0 then
    Result := ADefault
  else
    Result := FElement;
end;

function TEnexFillCollection<T>.GetCount: NativeUInt;
begin
  Result := FCount;
end;

function TEnexFillCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create an enumerator }
  Result := TEnumerator.Create(Self);
end;

function TEnexFillCollection<T>.Last: T;
begin
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FElement;
end;

function TEnexFillCollection<T>.LastOrDefault(const ADefault: T): T;
begin
  if FCount = 0 then
    Result := ADefault
  else
    Result := FElement;
end;

function TEnexFillCollection<T>.Max: T;
begin
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FElement;
end;

function TEnexFillCollection<T>.Min: T;
begin
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FElement;
end;

function TEnexFillCollection<T>.Single: T;
begin
  if FCount = 0 then
    ExceptionHelper.Throw_CollectionEmptyError()
  else if FCount = 1 then
    Result := FElement
  else
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement();
end;

function TEnexFillCollection<T>.SingleOrDefault(const ADefault: T): T;
begin
  if FCount = 0 then
    Result := ADefault
  else if FCount = 1 then
    Result := FElement
  else
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement();
end;


{ TEnexFillCollection<T>.TEnumerator }

constructor TEnexFillCollection<T>.TEnumerator.Create(const AEnum: TEnexFillCollection<T>);
begin
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FCount := 0;
end;

destructor TEnexFillCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexFillCollection<T>.TEnumerator.GetCurrent: T;
begin
  { Pass the element }
  Result := FEnum.FElement;
end;

function TEnexFillCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  { Check for end }
  Result := (FCount < FEnum.FCount);

  if not Result then
    Exit;

  Inc(FCount);
end;

{ TEnexSkipCollection<T> }

constructor TEnexSkipCollection<T>.Create(
  const AEnumerable: TEnexCollection<T>; const ACount: NativeUInt);
begin
  { Check parameters }
  if ACount = 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Installing the element type }
  InstallType(AEnumerable.ElementType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FCount := ACount;
  FDeleteEnum := false;
end;

constructor TEnexSkipCollection<T>.CreateIntf(
  const AEnumerable: IEnumerable<T>; const ACount: NativeUInt; const AType: IType<T>);
begin
  { Call upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, AType), ACount);

  { Mark for destruction }
  FDeleteEnum := true;
end;

destructor TEnexSkipCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexSkipCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create the enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexSkipCollection<T>.TEnumerator }

constructor TEnexSkipCollection<T>.TEnumerator.Create(const AEnum: TEnexSkipCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
  FIdx  := 0;
end;

destructor TEnexSkipCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexSkipCollection<T>.TEnumerator.GetCurrent: T;
begin
  { PAss the current in the sub-enum }
  Result := FIter.Current;
end;

function TEnexSkipCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  { Skip the required amount of elements }
  if (FIdx < FEnum.FCount) then
  begin
    while (FIdx < FEnum.FCount) do
    begin
      { Move cursor }
      Result := FIter.MoveNext();

      if not Result then
        Exit;

      Inc(FIdx);
    end;
  end;

  Result := FIter.MoveNext(); { Move the cursor next in the sub-enum }
end;

{ TEnexTakeCollection<T> }

constructor TEnexTakeCollection<T>.Create(
  const AEnumerable: TEnexCollection<T>; const ACount: NativeUInt);
begin
  { Check parameters }
  if ACount = 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Installing the element type }
  InstallType(AEnumerable.ElementType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FCount := ACount;
  FDeleteEnum := false;
end;

constructor TEnexTakeCollection<T>.CreateIntf(
  const AEnumerable: IEnumerable<T>; const ACount: NativeUInt; const AType: IType<T>);
begin
  { Call upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, AType), ACount);

  { Mark for destruction }
  FDeleteEnum := true;
end;

destructor TEnexTakeCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexTakeCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create the enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexTakeCollection<T>.TEnumerator }

constructor TEnexTakeCollection<T>.TEnumerator.Create(const AEnum: TEnexTakeCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
  FIdx  := 0;
end;

destructor TEnexTakeCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexTakeCollection<T>.TEnumerator.GetCurrent: T;
begin
  { PAss the current in the sub-enum }
  Result := FIter.Current;
end;

function TEnexTakeCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  { Check if we're finished}
  if (FIdx >= FEnum.FCount) then
    Exit(false);

  { Move the cursor next in the sub-enum, and increase index }
  Result := FIter.MoveNext();
  Inc(FIdx);
end;

{ TEnexTakeWhileCollection<T> }

constructor TEnexTakeWhileCollection<T>.Create(const AEnumerable: TEnexCollection<T>; const APredicate: TFunc<T, Boolean>);
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Install the type }
  InstallType(AEnumerable.ElementType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FPredicate := APredicate;
  FDeleteEnum := false;
end;

constructor TEnexTakeWhileCollection<T>.CreateIntf(
  const AEnumerable: IEnumerable<T>;
  const APredicate: TFunc<T, Boolean>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, AType), APredicate);

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexTakeWhileCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexTakeWhileCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexTakeWhileCollection<T>.TEnumerator }

constructor TEnexTakeWhileCollection<T>.TEnumerator.Create(const AEnum: TEnexTakeWhileCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter:= AEnum.FEnum.GetEnumerator();
end;

destructor TEnexTakeWhileCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexTakeWhileCollection<T>.TEnumerator.GetCurrent: T;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FIter.Current;
end;

function TEnexTakeWhileCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  Result := FIter.MoveNext;

  { Terminate on sub-enum termination }
  if not Result then
    Exit;

  { When the condition is not met, stop iterating! }
  if not FEnum.FPredicate(FIter.Current) then
    Exit(false);
end;

{ TEnexSkipWhileCollection<T> }

constructor TEnexSkipWhileCollection<T>.Create(const AEnumerable: TEnexCollection<T>; const APredicate: TFunc<T, Boolean>);
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Install the type }
  InstallType(AEnumerable.ElementType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FPredicate := APredicate;
  FDeleteEnum := false;
end;

constructor TEnexSkipWhileCollection<T>.CreateIntf(
  const AEnumerable: IEnumerable<T>;
  const APredicate: TFunc<T, Boolean>;
  const AType: IType<T>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, AType), APredicate);

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexSkipWhileCollection<T>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexSkipWhileCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexSkipWhileCollection<T>.TEnumerator }

constructor TEnexSkipWhileCollection<T>.TEnumerator.Create(const AEnum: TEnexSkipWhileCollection<T>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
  FStop := false;
end;

destructor TEnexSkipWhileCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexSkipWhileCollection<T>.TEnumerator.GetCurrent: T;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FIter.Current;
end;

function TEnexSkipWhileCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  { Iterate until given condition is met on an element }
  if not FStop then
  begin
    while not FStop do
    begin
      Result := FIter.MoveNext;

      { Terminate on sub-enum termination }
      if not Result then
        Exit;

      { When condition is met, move next }
      if FEnum.FPredicate(FIter.Current) then
        Continue;

      { Mark as skipped }
      FStop := true;
    end;
  end else
    Result := FIter.MoveNext;
end;

{ TEnexIntervalCollection<T> }

constructor TEnexIntervalCollection<T>.Create(const ALower, AHigher, AIncrement: T; const AType: IType<T>);
begin
  { Check arguments }
  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Restrict only to numbers! }
  AType.RestrictTo([tfUnsignedInteger, tfSignedInteger, tfReal]);

  if AType.Compare(ALower, AHigher) >= 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('ALower >= AHigher');

  { Install the type }
  InstallType(AType);

  { Copy Values }
  FLower := ALower;
  FHigher := AHigher;
  FIncrement := AIncrement;
end;

function TEnexIntervalCollection<T>.Empty: Boolean;
begin
  { Never empty }
  Result := false;
end;

function TEnexIntervalCollection<T>.First: T;
begin
  { Default }
  Result := FLower;
end;

function TEnexIntervalCollection<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Never empty, so - Default }
  Result := FLower;
end;

function TEnexIntervalCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  { Create enumerator }
  Result := TEnumerator.Create(Self);
end;

function TEnexIntervalCollection<T>.Min: T;
begin
  Result := FLower;
end;

{ TEnexIntervalCollection<T>.TEnumerator }

constructor TEnexIntervalCollection<T>.TEnumerator.Create(const AEnum: TEnexIntervalCollection<T>);
begin
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FNow := FEnum.FLower;
  FNowVariant := FEnum.ElementType.ConvertToVariant(FNow);
end;

destructor TEnexIntervalCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexIntervalCollection<T>.TEnumerator.GetCurrent: T;
begin
  { Pass the next value }
  Result := FNow;
end;

function TEnexIntervalCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  FNow := FEnum.ElementType.ConvertFromVariant(FNowVariant);

  { Check bounds }
  Result := (FEnum.ElementType.Compare(FNow, FEnum.FHigher) <= 0);

  if not Result then
    Exit;

  { Update current position }
  FNowVariant := FNowVariant + FEnum.ElementType.ConvertToVariant(FEnum.FIncrement);
end;

{ TEnexSelectKeysCollection<TKey, TValue> }

constructor TEnexSelectKeysCollection<TKey, TValue>.Create(const AEnumerable: TEnexAssociativeCollection<TKey, TValue>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Install the type }
  InstallType(AEnumerable.KeyType);

  { Assign internals }
  FEnum := AEnumerable;

  KeepObjectAlive(FEnum);
  FDeleteEnum := false;
end;

constructor TEnexSelectKeysCollection<TKey, TValue>.CreateIntf(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
begin
  { Call the upper constructor }
  Create(TEnexAssociativeWrapCollection<TKey, TValue>.Create(AEnumerable, AKeyType, AValueType));

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexSelectKeysCollection<TKey, TValue>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexSelectKeysCollection<TKey, TValue>.GetCount: NativeUInt;
begin
  Result := FEnum.GetCount();
end;

function TEnexSelectKeysCollection<TKey, TValue>.GetEnumerator: IEnumerator<TKey>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexSelectKeysCollection<TKey, TValue>.TEnumerator }

constructor TEnexSelectKeysCollection<TKey, TValue>.TEnumerator.Create(
  const AEnum: TEnexSelectKeysCollection<TKey, TValue>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter:= AEnum.FEnum.GetEnumerator();
  FCurrent := default(TKey);
end;

destructor TEnexSelectKeysCollection<TKey, TValue>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexSelectKeysCollection<TKey, TValue>.TEnumerator.GetCurrent: TKey;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FCurrent;
end;

function TEnexSelectKeysCollection<TKey, TValue>.TEnumerator.MoveNext: Boolean;
begin
  { Next iteration }
  Result := FIter.MoveNext;

  { Terminate on sub-enum termination }
  if not Result then
    Exit;

  { Return the next "selected" key }
  FCurrent := FIter.Current.Key;
end;

{ TEnexSelectValuesCollection<TKey, TValue> }

constructor TEnexSelectValuesCollection<TKey, TValue>.Create(
  const AEnumerable: TEnexAssociativeCollection<TKey, TValue>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Install the type }
  InstallType(AEnumerable.ValueType);

  { Assign internals }
  FEnum := AEnumerable;

  KeepObjectAlive(FEnum);
  FDeleteEnum := false;
end;

constructor TEnexSelectValuesCollection<TKey, TValue>.CreateIntf(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>);
begin
  { Call the upper constructor }
  Create(TEnexAssociativeWrapCollection<TKey, TValue>.Create(AEnumerable, AKeyType, AValueType));

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexSelectValuesCollection<TKey, TValue>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexSelectValuesCollection<TKey, TValue>.GetCount: NativeUInt;
begin
  Result := FEnum.GetCount();
end;

function TEnexSelectValuesCollection<TKey, TValue>.GetEnumerator: IEnumerator<TValue>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexSelectValuesCollection<TKey, TValue>.TEnumerator }

constructor TEnexSelectValuesCollection<TKey, TValue>.TEnumerator.Create(
  const AEnum: TEnexSelectValuesCollection<TKey, TValue>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter:= AEnum.FEnum.GetEnumerator();
  FCurrent := default(TValue);
end;

destructor TEnexSelectValuesCollection<TKey, TValue>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexSelectValuesCollection<TKey, TValue>.TEnumerator.GetCurrent: TValue;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FCurrent;
end;

function TEnexSelectValuesCollection<TKey, TValue>.TEnumerator.MoveNext: Boolean;
begin
  { Next iteration }
  Result := FIter.MoveNext;

  { Terminate on sub-enum termination }
  if not Result then
    Exit;

  { Return the next "selected" key }
  FCurrent := FIter.Current.Value;
end;

{ TEnexAssociativeWhereCollection<TKey, TValue> }

constructor TEnexAssociativeWhereCollection<TKey, TValue>.Create(
  const AEnumerable: TEnexAssociativeCollection<TKey, TValue>;
  const APredicate: TFunc<TKey, TValue, Boolean>;
  const AInvertResult: Boolean);
begin
  { Check arguments }
  if not Assigned(APredicate) then
    ExceptionHelper.Throw_ArgumentNilError('APredicate');

  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Install types }
  InstallTypes(AEnumerable.KeyType, AEnumerable.ValueType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FPredicate := APredicate;
  FDeleteEnum := false;

  FInvertResult := AInvertResult;
end;

constructor TEnexAssociativeWhereCollection<TKey, TValue>.CreateIntf(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const APredicate: TFunc<TKey, TValue, Boolean>;
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AInvertResult: Boolean);
begin
  { Call the upper constructor }
  Create(TEnexAssociativeWrapCollection<TKey, TValue>.Create(AEnumerable, AKeyType, AValueType), APredicate, AInvertResult);

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexAssociativeWhereCollection<TKey, TValue>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexAssociativeWhereCollection<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexAssociativeWhereCollection<TKey, TValue>.TEnumerator }

constructor TEnexAssociativeWhereCollection<TKey, TValue>.TEnumerator.Create(
  const AEnum: TEnexAssociativeWhereCollection<TKey, TValue>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
end;

destructor TEnexAssociativeWhereCollection<TKey, TValue>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexAssociativeWhereCollection<TKey, TValue>.TEnumerator.GetCurrent: KVPair<TKey, TValue>;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FIter.Current;
end;

function TEnexAssociativeWhereCollection<TKey, TValue>.TEnumerator.MoveNext: Boolean;
begin
  { Iterate until given condition is met on an element }
  while True do
  begin
    Result := FIter.MoveNext;

    { Terminate on sub-enum termination }
    if not Result then
      Exit;

    { Check whether the current element meets the condition and exit }
    { ... otherwise continue to the next iteration }
    if FEnum.FPredicate(FIter.Current.Key, FIter.Current.Value) xor FEnum.FInvertResult then
      Exit;
  end;
end;

{ TEnexAssociativeWrapCollection<TKey, TValue> }

constructor TEnexAssociativeWrapCollection<TKey, TValue>.Create(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  if not Assigned(AKeyType) then
    ExceptionHelper.Throw_ArgumentNilError('AKeyType');

  if not Assigned(AValueType) then
    ExceptionHelper.Throw_ArgumentNilError('AValueType');

  { Install both types }
  InstallTypes(AKeyType, AValueType);

  { Assign internals }
  FEnum := AEnumerable;
end;

function TEnexAssociativeWrapCollection<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Generate an enumerable from the sub-enum }
  Result := FEnum.GetEnumerator();
end;

{ TCollection.EnexAssociativeDistinctByKeysCollection<TKey, TValue> }

constructor TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.Create(
  const AEnumerable: TEnexAssociativeCollection<TKey, TValue>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Install types }
  InstallTypes(AEnumerable.KeyType, AEnumerable.ValueType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FDeleteEnum := false;
end;

constructor TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.CreateIntf(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
begin
  { Call the higher constructor }
  Create(TEnexAssociativeWrapCollection<TKey, TValue>.Create(AEnumerable, AKeyType, AValueType));

  { Mark for deletion }
  FDeleteEnum := true;
end;

destructor TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Create an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.TEnumerator }

constructor TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.TEnumerator.Create(
  const AEnum: TEnexAssociativeDistinctByKeysCollection<TKey, TValue>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();

  { Create an internal set }
  FSet := THashSet<TKey>.Create(TSuppressedWrapperType<TKey>.Create(AEnum.FEnum.KeyType));
end;

destructor TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.TEnumerator.GetCurrent: KVPair<TKey, TValue>;
begin
  { Get from sub-enum }
  Result := FIter.Current;
end;

function TEnexAssociativeDistinctByKeysCollection<TKey, TValue>.TEnumerator.MoveNext: Boolean;
begin
  while True do
  begin
    { Iterate }
    Result := FIter.MoveNext;

    if not Result then
      Exit;

    { If the item is distinct, add it to set and continue }
    if not FSet.Contains(FIter.Current.Key) then
    begin
      FSet.Add(FIter.Current.Key);
      Exit;
    end;
  end;
end;


{ TEnexAssociativeDistinctByValuesCollection<TKey, TValue> }

constructor TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.Create(
  const AEnumerable: TEnexAssociativeCollection<TKey, TValue>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Install types }
  InstallTypes(AEnumerable.KeyType, AEnumerable.ValueType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FDeleteEnum := false;
end;

constructor TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.CreateIntf(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
begin
  { Call the higher constructor }
  Create(TEnexAssociativeWrapCollection<TKey, TValue>.Create(AEnumerable, AKeyType, AValueType));

  { Mark for deletion }
  FDeleteEnum := true;
end;

destructor TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Create an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.TEnumerator }

constructor TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.TEnumerator.Create(
  const AEnum: TEnexAssociativeDistinctByValuesCollection<TKey, TValue>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();

  { Create an internal set }
  FSet := THashSet<TValue>.Create(TSuppressedWrapperType<TValue>.Create(AEnum.FEnum.ValueType));
end;

destructor TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.TEnumerator.GetCurrent: KVPair<TKey, TValue>;
begin
  { Get from sub-enum }
  Result := FIter.Current;
end;

function TEnexAssociativeDistinctByValuesCollection<TKey, TValue>.TEnumerator.MoveNext: Boolean;
begin
  while True do
  begin
    { Iterate }
    Result := FIter.MoveNext;

    if not Result then
      Exit;

    { If the item is distinct, add it to set and continue }
    if not FSet.Contains(FIter.Current.Value) then
    begin
      FSet.Add(FIter.Current.Value);
      Exit;
    end;
  end;
end;

{ TEnexSelectClassCollection<T, TOut> }

constructor TEnexSelectClassCollection<T, TOut>.Create(const AEnumerable: TEnexCollection<T>; const AType: IType<TOut>);
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Installing the element type }
  InstallType(AType);

  { Assign internals }
  FEnum := AEnumerable;
  KeepObjectAlive(FEnum);

  FDeleteEnum := false;
end;

constructor TEnexSelectClassCollection<T, TOut>.CreateIntf(const AEnumerable: IEnumerable<T>; const AType: IType<TOut>);
begin
  { Call the upper constructor }
  Create(TEnexWrapCollection<T>.Create(AEnumerable, TType<T>.Default), AType);

  { Mark enumerable to be deleted }
  FDeleteEnum := true;
end;

destructor TEnexSelectClassCollection<T, TOut>.Destroy;
begin
  { Delete the enumerable if required }
  ReleaseObject(FEnum, FDeleteEnum);

  inherited;
end;

function TEnexSelectClassCollection<T, TOut>.GetEnumerator: IEnumerator<TOut>;
begin
  { Generate an enumerator }
  Result := TEnumerator.Create(Self);
end;

{ TEnexSelectClassCollection<T, TOut>.TEnumerator }

constructor TEnexSelectClassCollection<T, TOut>.TEnumerator.Create(const AEnum: TEnexSelectClassCollection<T, TOut>);
begin
  { Initialize }
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
  FCurrent := default(TOut);
end;

destructor TEnexSelectClassCollection<T, TOut>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);
  inherited;
end;

function TEnexSelectClassCollection<T, TOut>.TEnumerator.GetCurrent: TOut;
begin
  { Get current element of the "sub-enumerable" object }
  Result := FCurrent;
end;

function TEnexSelectClassCollection<T, TOut>.TEnumerator.MoveNext: Boolean;
begin
  { Iterate until given condition is met on an element }
  while True do
  begin
    Result := FIter.MoveNext;

    { Terminate on sub-enum termination }
    if not Result then
      Exit;

    { Check if T is TOut. Exit if yes}
    if (FIter.Current <> nil) and (FIter.Current.InheritsFrom(TOut)) then
    begin
      FCurrent := TOut(TObject(FIter.Current));
      Exit;
    end;
  end;
end;

{ Collection }

class function Collection.Fill<T>(const AElement: T; const ACount: NativeUInt): IEnexCollection<T>;
begin
  { Call upper function }
  Result := Fill<T>(AElement, ACount, TType<T>.Default);
end;

class function Collection.Fill<T>(const AElement: T; const ACount: NativeUInt; const AType: IType<T>): IEnexCollection<T>;
begin
  { Check arguments }
  if ACount = 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Create an collection }
  Result := TEnexFillCollection<T>.Create(AElement, ACount, AType);
end;

class function Collection.Interval<T>(const AStart, AEnd, AIncrement: T;
  const AType: IType<T>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Restrict only to numbers! }
  AType.RestrictTo([tfUnsignedInteger, tfSignedInteger, tfReal]);

  if AType.Compare(AStart, AEnd) >= 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStart >= AEnd');

  { Create the collection }
  Result := TEnexIntervalCollection<T>.Create(AStart, AEnd, AIncrement, AType);
end;

class function Collection.Interval<T>(const AStart, AEnd: T): IEnexCollection<T>;
begin
  { Call upper function }
  Result := Interval<T>(AStart, AEnd, TType<T>.Default);
end;

class function Collection.Interval<T>(const AStart, AEnd: T; const AType: IType<T>): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(AType) then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Restrict only to numbers! }
  AType.RestrictTo([tfUnsignedInteger, tfSignedInteger, tfReal]);

  if AType.Compare(AStart, AEnd) >= 0 then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStart >= AEnd');

  { Create the collection }
  Result := TEnexIntervalCollection<T>.Create(AStart, AEnd, AType.ConvertFromVariant(1), AType);
end;

class function Collection.Interval<T>(const AStart, AEnd, AIncrement: T): IEnexCollection<T>;
begin
  { Call upper function }
  Result := Interval<T>(AStart, AEnd, AIncrement, TType<T>.Default);
end;

end.
