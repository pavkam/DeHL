# Introduction  

> This document is a Markdown conversion, with some typos corrected, of a page from the original *DeHL* project's *GoogleCode* wiki. The original was recovered from a [Wayback machine snapshot](http://web.archive.org/web/20120630131025/http://code.google.com/p/delphilhlplib/wiki/Introduction) of 30 June 2012 and was last updated on 20 June 2010.

This article will try to respond to some questions about what is DeHL, what it tries to achieve and even how.

## What is DeHL

DeHL is an abbreviation that stands for *Delphi Helper Library*. DeHL is a library which makes use of the newly introduced features in Delphi 2009; features like **Generics and Anonymous Methods**. It tries to fill in the gaps in the Delphi RTL by providing what most developers already have in other development platforms.

## Why choose DeHL

There are two kinds of developer that can take advantage of DeHL's features

* Application developers
* Library developers

Application developers will love the comprehensive collection of generic collection classes that DeHL exposes. These collections range from the simple `TList` and `TQueue` to the more advanced ones like `TSortedDictionary`. All these collection classes have their own preferred use case scenarios -- but this is a part of another article.

Library developers will be stunned to find a lot of functionality perfect to develop complex generic classes.

## Design Goals

This section lists some of the design goals taken into account when creating DeHL.

### Flexibility

Flexibility is the key for extensibility. DeHL was designed with this goal in mind to be able to provide future extensions in a easy non-intrusive way. This flexibility of course leads to the inevitable loss in performance in some scenarios. This speed loss is not essential since those circumstances put more emphasis on the quality and maintainability of the code rather than speed.

### It's a Delphi library

The code must act and look as a Delphi library. The classes must complement the Delphi ones and not look extraneous to the platform. Unfortunately dues to some other design issues in some parts the available Delphi RTL features are not flexible enough to use.

### The best features

DeHL proposes to reuse the best concepts of all worlds. The design will make use of parts of .NET, STL or other frameworks over there. The simple fact that someone did it before does not stop DeHL from adopting some feature.

### The missing root

Since Delphi language doesn't know the concept of a single rooted type system, developing complex and generic code becomes really hard in time. `Generics.Defaults` unit provided by the Delphi RTL is nowhere near the level of sophistication required to develop a really useful generic class. DeHL works around this limitation by providing a type support framework that allows using a set of "extension" classes that complement a type.
