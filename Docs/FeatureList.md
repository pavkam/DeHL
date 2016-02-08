# Library Feature List

> This document is a Markdown conversion of a page from the original *DeHL* project's *GoogleCode* wiki. The original was recovered from a [Wayback machine snapshot](http://web.archive.org/web/20140402003803/http://code.google.com/p/delphilhlplib/wiki/FeatureList) of 02 April 2014 and was last updated on 07 December 2010.

The DeHL library provides a few generic data types and classes. The main point of the library is to provide generic and object-oriented code for the most important and time consuming tasks in your daily code.

The library is logically split into 4 parts for now:

* **The Core**. Provides support classes for the rest of the library. Most developers will not find the core classes and routines interesting as they are mostly designed to provide internal support.

* **Type** module provides a set of classes and routines that are being used in all collection classes to enable all Delphi data-types to provide a set of required information like *hash codes*, *equality*, *comparability*, *lifetime management* and so on. DeHL's type objects also provide almost direct integration with RTL's `Generics.Collections`.

* **Generic serialization** provides an easy way to serialize and deserialize objects, records, arrays and simple types. There are three serialization engines supported so far: Xml, Ini and Binary.

* **Converter** allows converting from a type to another without knowing the actual details of the types. Allows for custom conversions.

* **Scoped objects** which can be used for automatic memory management for objects. There are three types here: *Scoped*, *Shared* and *Weak*.

* **Boxing** which can be used to store any value in a heap object

* **Nullable types**.

* **Tuple** and **KVPair** types.

* **Singleton** provides a consistent way of accessing just one instance of a class across all application.

* **Wide CharSet** type provides all the benefits and ease of use of a normal Delphi set for wide characters.

* **TString** type provides an OO facade to Delphi strings.

* **Half** is a half precision floating point number. It is useful in certain circumstances.

* **BigDecimal** is a great way of big calculations on big number with floating point but with a controllable precision.

* **BigInteger** and **BigCardinal** are 2 records that provide support for unlimited-size integer numbers. You can use them in any if your code with minimal hassle. These 2 provide all the usual operators and functions you would expect from a normal integer data type.

* **Date and Time** module provides support for date and time manipulation. There are four types present in this module:

    * **TDateTime** record that eases the manipulation of date/time values.
    * **TTime** record to work exclusively with time values.
    * **TDate** record to work exclusively with date values.
    * **TTimeSpan** record that can be used to store differences between two date/time values.

* **Collections** module contains a number of collection classes that you can use in your daily code:

    * **Enex** (Enumerable Extensions) provide Linq-like possibilities for all DeHL collections.
    * **THeap** provides an array-based "put all you want in there" structure.
    * **TArraySet** provides an array-based implementation of the Set collection.
    * **TBag** provides a hash-based implementation of the Bag collection.
    * **TSortedBag** provides a tree-based implementation of the Bag collection.
    * **TDictionary** provides a hash-based implementation of the Map collection.
    * **TSortedDictionary** provides a tree-based implementation of the Map collection.
    * **TDynamicArray** is a record that allows simple manipulations on dynamic arrays.
    * **THashSet** provides a hash-based implementation of the Set collection.
    * **TSortedSet** provides a tree-based implementation of the Set collection.
    * **TLinkedList** provides a generic linked list. You can manipulate the nodes directly or use the list for that.
    * **TList** provides an array-based list.
    * **TMultiMap** provides a hash-based multi-map implementation.
    * **TSortedMultiMap** provides a tree-based multi-map implementation.
    * **TDoubleSortedMultiMap** provides a tree-based multi-map implementation in which the values are also sorted.
    * **TDistinctMultiMap** provides a hash-based multi-map (with distinct values) implementation.
    * **TSortedDistinctMultiMap** provides a tree-based multi-map (with distinct values) implementation.
    * **TDoubleSorteDistinctdMultiMap** provides a tree-based multi-map (with distinct values) implementation in which the values are also sorted.
    * **TBidiMap** provides a hash-based bi-directional multi-map implementation.
    * **TSortedBidiMap** provides a tree-based bi-directional multi-map implementation.
    * **TDoubleSortedBidiMap** provides a tree-based bi-directional multi-map implementation in which the values are also sorted.
    * **TQueue** provides an array-based implementation of a FIFO collection.
    * **TPriorityQueue** provides an array-based priority-based queue collection.
    * **TStack** provides an array-based implementation of a LIFO collection.
    * **TLinkedQueue** provides an linked-list based implementation of a FIFO collection.
    * **TLinkedStack** provides an linked-list based implementation of a LIFO collection.
    * Other utility types and routines.
