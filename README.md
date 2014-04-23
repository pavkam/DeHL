DeHL
====
DeHL (Delphi Helper Library) is *discontinued* starting with 09.01.2012. You can reuse parts of this project for whatever particular needs you have. The source code is BSD licensed.

The most important features of `DeHL` for now are:
  * A set of generic collections classes (*TList*, *TDictionary*, *THashSet*, *TMultiMap*, *TPriorityQueue* and etc).
  * _Linq_-like extensions (called *Enex*) for collections which allow writing queries on collection classes.
  * Date/Time functionality all combined in a few structures (somehow equivalent to .NET's *DateTime* structure)
  * *Type Support* concept that defines a set of default "support classes" for each built-in Delphi types (used as defaults in collections). Custom "type support" classes can be registered for your custom data types.
  * *BigCardinal* and *BigInteger* data types.
  * *BigDecimal* for infinite precision Decimal calculus
  * *Scoped objects* in Delphi.
  * *Nullable* types in Delphi.
  * *Tuples*
  * *Array extensions* and utilities.
  * *Wide charset* implementation.
  * *OOP TString* type.
  * Full *generic serialization* for all included types and collections.
  * Type conversion system with custom conversion support.
  * *... and more!*

All classes and functions have unit tests. We're trying to maintain a large set of tests to find and fix early all possible bugs.
