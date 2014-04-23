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

{
  General restriction -- DeHL 0.8+ requires minimum Delphi 2010.
}
{$IF CompilerVersion < 21}
  {$MESSAGE ERROR 'DeHL requires at least Delphi 2010 to build and run.'}
{$IFEND}

{
   Type:  Compiler BUG.
   When:  At Compile
   Tags:  Generics, Collections
   Where: DeHL.Collections.Base and descendants
   How:   All associative collection interfaces defined in the unit
          usually declare an Add(Key, Pair) and an Add(Pair<Key, Pair>) methods.
          Implementing these interfaces causes an error. The second Add method is
          not recognized by the compiler as implemented. I suspect this is because TKeyValuePair
          instantiations are different between the interface and the class implementing that interface.
}
{$IF CompilerVersion < 22}
  {$DEFINE BUG_GENERIC_INCOMPAT_TYPES}
{$IFEND}

{
   Type:  Compiler BUG.
   When:  At Run time
   Tags:  Generics, Class constructors and Destructors
   Where: DeHL.Types.TType<T>
   How:   A specialized generic type does not get its class constructor and
          destructor called when the type is instantiated in the main program.
          This results in some interface references not being cleared.
}
{$DEFINE BUG_NO_GEN_CDTOR_IN_MAIN}

{
   Type:  Compiler BUG.
   When:  At Compile
   Tags:  Generics, Collections, Class Type
   Where: DeHL.Collections.Dictionary.TBugReproducer
   How:   Instantiated type TBugReproducer = TDictionary<TTypeClass, String> fails
          with internal error. Cannot tell who is the culprit here.
}
{$DEFINE BUG_URW1133}


{
   Type:  Compiler BUG.
   When:  Testing
   Tags:  Generics, Collections, Objects
   Where: DeHL.Collections.Interop.TStringList<T> and TWideStringList<T>
   How:   The IS operator used to check if a given object (TObject) parameter
          actually descends from TBox<T> fails miserably. Compiler inserts wrong
          addresses for the ClassType (in EAX).
}
{$IF CompilerVersion < 22}
  {$DEFINE BUG_IS_OP_CLASS}
{$IFEND}

{
   Type:  RTL BUG.
   When:  Testing
   Tags:  Generics, Arrays, RTTI
   Where: DeHL.Types,TDynArrayType
   How:   Rtti data exposed by TRttiDynamicArrayType does not take into
          account typeData^.elType, which makes some array of arrays fail.
}
{$IF RTLVersion < 22}
  {$DEFINE BUG_RTTI_ELEMENTTYPE}
{$IFEND}

{
   Type:  RTL BUG.
   When:  At Compile
   Tags:  Generics, Interfaces
   Where: DeHL.Base.IEnumerator<T>, DeHL.Base.IEnumerable<T>,
          DeHL.Base.IComparable, DeHL.Base.IComparable<T>
   How:   System.IEnumerator<T> descends from System.IEnumerator (object-based),
          which makes it impossible to use. Same goes for IEnumerable<T>.
          IComparable (object-based) requires a GUID to be queried in TClassType<T>
          for comparison purposes.
}
{$DEFINE BUG_BASE_INTFS}

{
   Type:  Compiler BUG.
   When:  At Compile
   Tags:  Generics, Anonymous methods, Strings
   Where: DeHL.Converter.TConverter<TIn, TOut>
   How:   Assignment operation between an AnsiChar and a ShortString.
}
{$IF CompilerVersion < 22}
  {$DEFINE BUG_ANSI_CHAR_IMPLICIT_STRING_OP}
{$IFEND}

{
  TArray optimization. Consider using a local "stack" variable instead of
  actually recurring. This should speed up QuickSort a bit.
}
{$DEFINE OPTIMIZED_SORT}

{
  TString option:
    If enabled, TString is zero-indexed (first char starts at zero).
}
{$DEFINE TSTRING_ZERO_INDEXED}

{
  TString option:
    If enabled, TString performs range checking on all index-based operations.
}
{$DEFINE TSTRING_CHECK_RANGES}

{
  TString option:
    If enabled, TString exposes a few methods provided for .NET compatibility.
}
{$DEFINE TSTRING_DOT_NET_METHODS}

{
  TBuffer option:
    If enabled, TBuffer performs range checking on all index-based operations.
}
{$DEFINE TBUFFER_CHECK_RANGES}

