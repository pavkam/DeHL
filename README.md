# DeHL

> This is a fork that attempts to keep alive the  **discontinued** *Delphi Helper Library* by Ciobanu Alexandru. See below for further information about the fork.

## Overview of the library

The most important features of `DeHL` are:
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

You can find more information about the library here:

* [Introduction to DeHL](Docs/Introduction.md)
* [Feature List](Docs/FeatureList.md)

## About this fork

This is a fork of the **discontinued** [*Delphi Helper Library*](https://github.com/pavkam/DeHL) by [Ciobanu Alexandru](https://github.com/pavkam).

DeHL was *discontinued* on 09.01.2012.

The code appears to be based on the *DeHL* v0.8.4 release. It is not known whether any commits were made to the code we have here after the release of v0.8.4. (No history was included in the original GitHub project).

It is not my intention to make any significant changes to the library, but it may get tweaked to meet my needs.

## Documentation

The source code is fully documented using XMLDoc. In the Delphi IDE hover the mouse over an identifier to get a full description. 

## License

Licensed under the BSD License -- see [LICENSE.txt](LICENSE.txt). The original library is copyright (c) 2008-2010, Ciobanu Alexandru.

## Bugs

Please notify any bugs using the Issue Tracker.

**Note:** This is not a top priority project for me, so I may not fix all bugs. So, if you can, fix the bug yourself and submit your changes. Pull requests are the way to go!

> Using the Wayback Machine a list of [outstanding issues](http://web.archive.org/web/20121026095237/http://code.google.com/p/delphilhlplib/issues/list) from the original project has been found, but unfortunately the issue detail pages are not archived, so there's not much to go on.
