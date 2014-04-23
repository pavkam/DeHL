(*
* Copyright (c) 2009, Ciobanu Alexandru
* All rights reserved.
*
* Redistribution and use in source and binary forms, wior without
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
unit DeHL.Collections.Abstract;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Tuples,
     DeHL.Arrays,
     DeHL.Serialization,     
     DeHL.Collections.Base;

type
  ///  <summary>The base abstract class for all <c>multi-maps</c> in DeHL.</summary>
  TAbstractMultiMap<TKey, TValue> = class abstract(TEnexAssociativeCollection<TKey, TValue>, IMultiMap<TKey, TValue>)
  private type
    {$REGION 'Internal Types'}
    { Generic MultiMap Pairs Enumerator }
    TPairEnumerator = class(TEnumerator<KVPair<TKey,TValue>>)
    private
      FVer: NativeUInt;
      FDict: TAbstractMultiMap<TKey, TValue>;
      FValue: KVPair<TKey, TValue>;

      FListIndex: NativeUInt;
      FDictEnum: IEnumerator<KVPair<TKey, IList<TValue>>>;
      FList: IList<TValue>;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): KVPair<TKey,TValue>; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic MultiMap Keys Enumerator }
    TKeyEnumerator = class(TEnumerator<TKey>)
    private
      FVer: NativeUInt;
      FDict: TAbstractMultiMap<TKey, TValue>;
      FValue: TKey;
      FDictEnum: IEnumerator<TKey>;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TKey; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic MultiMap Values Enumerator }
    TValueEnumerator = class(TEnumerator<TValue>)
    private
      FVer: NativeUInt;
      FDict: TAbstractMultiMap<TKey, TValue>;
      FValue: TValue;

      FListIndex: NativeUInt;
      FDictEnum: IEnumerator<IList<TValue>>;
      FList: IList<TValue>;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TValue; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic MultiMap Keys Collection }
    TKeyCollection = class(TEnexCollection<TKey>)
    private
      FDict: TAbstractMultiMap<TKey, TValue>;

    protected
      { Hidden }
      function GetCount(): NativeUInt; override;
    public
      { Constructor }
      constructor Create(const ADict: TAbstractMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      { Property }
      property Count: NativeUInt read GetCount;

      { IEnumerable/ ICollection support }
      function GetEnumerator(): IEnumerator<TKey>; override;

      { Copy-To }
      procedure CopyTo(var AArray: array of TKey; const StartIndex: NativeUInt); overload; override;

      { Enex Overrides }
      function Empty(): Boolean; override;
    end;

    { Generic MultiMap Values Collection }
    TValueCollection = class(TEnexCollection<TValue>)
    private
      FDict: TAbstractMultiMap<TKey, TValue>;

    protected

      { Hidden }
      function GetCount: NativeUInt; override;
    public
      { Constructor }
      constructor Create(const ADict: TAbstractMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      { Property }
      property Count: NativeUInt read GetCount;

      { IEnumerable/ ICollection support }
      function GetEnumerator(): IEnumerator<TValue>; override;

      { Copy-To }
      procedure CopyTo(var AArray: array of TValue; const StartIndex: NativeUInt); overload; override;

      { Enex Overrides }
      function Empty(): Boolean; override;
    end;
    {$ENDREGION}

  private
    FVer: NativeUInt;
    FKnownCount: NativeUInt;
    FEmptyList: IEnexIndexedCollection<TValue>;
    FKeyCollection: IEnexCollection<TKey>;
    FValueCollection: IEnexCollection<TValue>;
    FDictionary: IDictionary<TKey, IList<TValue>>;

  protected
    ///  <summary>Specifies the internal dictionary used as back-end.</summary>
    ///  <returns>A dictionary of lists used as back-end.</summary>
    property Dictionary: IDictionary<TKey, IList<TValue>> read FDictionary;

    ///  <summary>Returns the number of pairs in the multi-map.</summary>
    ///  <returns>A positive value specifying the total number of pairs in the multi-map.</returns>
    ///  <remarks>The value returned by this method represents the total number of key-value pairs
    ///  stored in the dictionary. In a multi-map this means that each value associated with a key
    ///  is calculated as a pair. If a key has multiple values associated with it, each key-value
    ///  combination is calculated as one.</remarks>
    function GetCount(): NativeUInt; override;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    function GetItemList(const AKey: TKey): IEnexIndexedCollection<TValue>;

    ///  <summary>Called when the map needs to initialize its internal dictionary.</summary>
    ///  <param name="AKeyType">The type object describing the keys.</param>
    function CreateDictionary(const AKeyType: IType<TKey>): IDictionary<TKey, IList<TValue>>; virtual; abstract;

    ///  <summary>Called when the map needs to initialize a list assoiated with a key.</summary>
    ///  <param name="AValueType">The type object describing the values.</param>
    function CreateList(const AValueType: IType<TValue>): IList<TValue>; virtual; abstract;

  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const ACollection: IEnumerable<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: array of KVPair<TKey,TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TFixedArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const ACollection: IEnumerable<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: array of KVPair<TKey,TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TDynamicArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TFixedArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the multi-map.</summary>
    ///  <remarks>This method clears the multi-map and invokes type object's cleaning routines for key and value.</remarks>
    procedure Clear();

    ///  <summary>Adds a key-value pair to the multi-map.</summary>
    ///  <param name="APair">The key-value pair to add.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The multi-map already contains a pair with the given key.</exception>
    procedure Add(const APair: KVPair<TKey, TValue>); overload;

    ///  <summary>Adds a key-value pair to the multi-map.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The multi-map already contains a pair with the given key.</exception>
    procedure Add(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value pair using a given key.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <remarks>This invokes type object's cleaning routines for value
    ///  associated with the key. If the specified key was not found in the multi-map, nothing happens.</remarks>
    procedure Remove(const AKey: TKey); overload;

    ///  <summary>Removes a key-value pair using a given key and value.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>A multi-map allows storing multiple values for a given key. This method allows removing only the
    ///  specified value from the collection of values associated with the given key.</remarks>
    procedure Remove(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value pair using a given key and value.</summary>
    ///  <param name="APair">The key and its associated value to remove.</param>
    ///  <remarks>A multi-map allows storing multiple values for a given key. This method allows removing only the
    ///  specified value from the collection of values associated with the given key.</remarks>
    procedure Remove(const APair: KVPair<TKey, TValue>); overload;

    ///  <summary>Checks whether the multi-map contains a key-value pair identified by the given key.</summary>
    ///  <param name="AKey">The key to check for.</param>
    ///  <returns><c>True</c> if the map contains a pair identified by the given key; <c>False</c> otherwise.</returns>
    function ContainsKey(const AKey: TKey): Boolean;

    ///  <summary>Checks whether the multi-map contains a key-value pair that contains a given value.</summary>
    ///  <param name="AValue">The value to check for.</param>
    ///  <returns><c>True</c> if the multi-map contains a pair containing the given value; <c>False</c> otherwise.</returns>
    function ContainsValue(const AValue: TValue): Boolean; overload;

    ///  <summary>Checks whether the multi-map contains a given key-value combination.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsValue(const AKey: TKey; const AValue: TValue): Boolean; overload;

    ///  <summary>Checks whether the multi-map contains a given key-value combination.</summary>
    ///  <param name="APair">The key-value pair to check for.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsValue(const APair: KVPair<TKey, TValue>): Boolean; overload;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <param name="AValues">The Enex collection that stores the associated values.</param>
    ///  <returns><c>True</c> if the key exists in the collection; <c>False</c> otherwise;</returns>
    function TryGetValues(const AKey: TKey; out AValues: IEnexIndexedCollection<TValue>): Boolean; overload;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>The associated collection if the key if valid; an empty collection otherwise.</returns>
    function TryGetValues(const AKey: TKey): IEnexIndexedCollection<TValue>; overload;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the multi-map.</exception>
    property Items[const AKey: TKey]: IEnexIndexedCollection<TValue> read GetItemList; default;

    ///  <summary>Returns the number of pairs in the multi-map.</summary>
    ///  <returns>A positive value specifying the total number of pairs in the multi-map.</returns>
    ///  <remarks>The value returned by this method represents the total number of key-value pairs
    ///  stored in the dictionary. In a multi-map this means that each value associated with a key
    ///  is calculated as a pair. If a key has multiple values associated with it, each key-value
    ///  combination is calculated as one.</remarks>
    property Count: NativeUInt read FKnownCount;

    ///  <summary>Specifies the collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the multi-map.</returns>
    property Keys: IEnexCollection<TKey> read FKeyCollection;

    ///  <summary>Specifies the collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the multi-map.</returns>
    property Values: IEnexCollection<TValue> read FValueCollection;

    ///  <summary>Returns a new enumerator object used to enumerate this multi-map.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the multi-map.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<KVPair<TKey,TValue>>; override;

    ///  <summary>Copies the values stored in the multi-map to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the multi-map.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the multi-map.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of KVPair<TKey,TValue>; const AStartIndex: NativeUInt); overload; override;

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to return the associated value.</param>
    ///  <returns>The value associated with the given key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">No such key in the multi-map.</exception>
    function ValueForKey(const AKey: TKey): TValue; override;

    ///  <summary>Checks whether the multi-map contains a given key-value pair.</summary>
    ///  <param name="AKey">The key part of the pair.</param>
    ///  <param name="AValue">The value part of the pair.</param>
    ///  <returns><c>True</c> if the given key-value pair exists; <c>False</c> otherwise.</returns>
    function KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean; override;

    ///  <summary>Returns an Enex collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the multi-map.</returns>
    function SelectKeys(): IEnexCollection<TKey>; override;

    ///  <summary>Returns a Enex collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the multi-map.</returns>
    function SelectValues(): IEnexCollection<TValue>; override;
  end;

  ///  <summary>The base abstract class for all <c>distinct multi-maps</c> in DeHL.</summary>
  TAbstractDistinctMultiMap<TKey, TValue> = class abstract(TEnexAssociativeCollection<TKey, TValue>, IDistinctMultiMap<TKey, TValue>)
  private type
    {$REGION 'Internal Types'}
    { Generic MultiMap Pairs Enumerator }
    TPairEnumerator = class(TEnumerator<KVPair<TKey,TValue>>)
    private
      FVer: NativeUInt;
      FDict: TAbstractDistinctMultiMap<TKey, TValue>;
      FValue: KVPair<TKey, TValue>;

      FSetEnum: IEnumerator<TValue>;
      FDictEnum: IEnumerator<KVPair<TKey, ISet<TValue>>>;
      FSet: ISet<TValue>;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): KVPair<TKey,TValue>; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic MultiMap Keys Enumerator }
    TKeyEnumerator = class(TEnumerator<TKey>)
    private
      FVer: NativeUInt;
      FDict: TAbstractDistinctMultiMap<TKey, TValue>;
      FValue: TKey;
      FDictEnum: IEnumerator<TKey>;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TKey; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic MultiMap Values Enumerator }
    TValueEnumerator = class(TEnumerator<TValue>)
    private
      FVer: NativeUInt;
      FDict: TAbstractDistinctMultiMap<TKey, TValue>;
      FValue: TValue;

      FDictEnum: IEnumerator<ISet<TValue>>;
      FSetEnum: IEnumerator<TValue>;
      FSet: ISet<TValue>;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): TValue; override;
      function MoveNext(): Boolean; override;
    end;

    { Generic MultiMap Keys Collection }
    TKeyCollection = class(TEnexCollection<TKey>)
    private
      FDict: TAbstractDistinctMultiMap<TKey, TValue>;

    protected
      { Hidden }
      function GetCount(): NativeUInt; override;
    public
      { Constructor }
      constructor Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      { Property }
      property Count: NativeUInt read GetCount;

      { IEnumerable/ ICollection support }
      function GetEnumerator(): IEnumerator<TKey>; override;

      { Copy-To }
      procedure CopyTo(var AArray: array of TKey; const StartIndex: NativeUInt); overload; override;

      { Enex Overrides }
      function Empty(): Boolean; override;
    end;

    { Generic MultiMap Values Collection }
    TValueCollection = class(TEnexCollection<TValue>)
    private
      FDict: TAbstractDistinctMultiMap<TKey, TValue>;

    protected
      { Hidden }
      function GetCount: NativeUInt; override;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);

      { Destructor }
      destructor Destroy(); override;

      { Property }
      property Count: NativeUInt read GetCount;

      { IEnumerable/ ICollection support }
      function GetEnumerator(): IEnumerator<TValue>; override;

      { Copy-To }
      procedure CopyTo(var AArray: array of TValue; const StartIndex: NativeUInt); overload; override;

      { Enex Overrides }
      function Empty(): Boolean; override;
    end;
    {$ENDREGION}

  private var
    FVer: NativeUInt;
    FKnownCount: NativeUInt;
    FEmptySet: IEnexCollection<TValue>;
    FKeyCollection: IEnexCollection<TKey>;
    FValueCollection: IEnexCollection<TValue>;
    FDictionary: IDictionary<TKey, ISet<TValue>>;

  protected
    ///  <summary>Specifies the internal dictionary used as back-end.</summary>
    ///  <returns>A dictionary of lists used as back-end.</summary>
    property Dictionary: IDictionary<TKey, ISet<TValue>> read FDictionary;

    ///  <summary>Returns the number of pairs in the multi-map.</summary>
    ///  <returns>A positive value specifying the total number of pairs in the multi-map.</returns>
    ///  <remarks>The value returned by this method represents the total number of key-value pairs
    ///  stored in the dictionary. In a multi-map this means that each value associated with a key
    ///  is calculated as a pair. If a key has multiple values associated with it, each key-value
    ///  combination is calculated as one.</remarks>
    function GetCount(): NativeUInt; override;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the collection.</exception>
    function GetItemList(const AKey: TKey): IEnexCollection<TValue>;

    ///  <summary>Called when the map needs to initialize its internal dictionary.</summary>
    ///  <param name="AKeyType">The type object describing the keys.</param>
    function CreateDictionary(const AKeyType: IType<TKey>): IDictionary<TKey, ISet<TValue>>; virtual; abstract;

    ///  <summary>Called when the map needs to initialize a set assoiated with a key.</summary>
    ///  <param name="AValueType">The type object describing the values.</param>
    function CreateSet(const AValueType: IType<TValue>): ISet<TValue>; virtual; abstract;

  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const ACollection: IEnumerable<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: array of KVPair<TKey,TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TFixedArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const ACollection: IEnumerable<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: array of KVPair<TKey,TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TDynamicArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the multi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the multi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TFixedArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the multi-map.</summary>
    ///  <remarks>This method clears the multi-map and invokes type object's cleaning routines for key and value.</remarks>
    procedure Clear();

    ///  <summary>Adds a key-value pair to the multi-map.</summary>
    ///  <param name="APair">The key-value pair to add.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The multi-map already contains a pair with the given key.</exception>
    procedure Add(const APair: KVPair<TKey, TValue>); overload;

    ///  <summary>Adds a key-value pair to the multi-map.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The multi-map already contains a pair with the given key.</exception>
    procedure Add(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value pair using a given key.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <remarks>This invokes type object's cleaning routines for value
    ///  associated with the key. If the specified key was not found in the multi-map, nothing happens.</remarks>
    procedure Remove(const AKey: TKey); overload;

    ///  <summary>Removes a key-value pair using a given key and value.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>A multi-map allows storing multiple values for a given key. This method allows removing only the
    ///  specified value from the collection of values associated with the given key.</remarks>
    procedure Remove(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value pair using a given key and value.</summary>
    ///  <param name="APair">The key and its associated value to remove.</param>
    ///  <remarks>A multi-map allows storing multiple values for a given key. This method allows removing only the
    ///  specified value from the collection of values associated with the given key.</remarks>
    procedure Remove(const APair: KVPair<TKey, TValue>); overload;

    ///  <summary>Checks whether the multi-map contains a key-value pair identified by the given key.</summary>
    ///  <param name="AKey">The key to check for.</param>
    ///  <returns><c>True</c> if the map contains a pair identified by the given key; <c>False</c> otherwise.</returns>
    function ContainsKey(const AKey: TKey): Boolean;

    ///  <summary>Checks whether the multi-map contains a key-value pair that contains a given value.</summary>
    ///  <param name="AValue">The value to check for.</param>
    ///  <returns><c>True</c> if the multi-map contains a pair containing the given value; <c>False</c> otherwise.</returns>
    function ContainsValue(const AValue: TValue): Boolean; overload;

    ///  <summary>Checks whether the multi-map contains a given key-value combination.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsValue(const AKey: TKey; const AValue: TValue): Boolean; overload;

    ///  <summary>Checks whether the multi-map contains a given key-value combination.</summary>
    ///  <param name="APair">The key-value pair to check for.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsValue(const APair: KVPair<TKey, TValue>): Boolean; overload;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <param name="AValues">The Enex collection that stores the associated values.</param>
    ///  <returns><c>True</c> if the key exists in the collection; <c>False</c> otherwise;</returns>
    function TryGetValues(const AKey: TKey; out AValues: IEnexCollection<TValue>): Boolean; overload;

    ///  <summary>Tries to extract the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>The associated collection if the key if valid; an empty collection otherwise.</returns>
    function TryGetValues(const AKey: TKey): IEnexCollection<TValue>; overload;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the multi-map.</exception>
    property Items[const AKey: TKey]: IEnexCollection<TValue> read GetItemList; default;

    ///  <summary>Returns the number of pairs in the multi-map.</summary>
    ///  <returns>A positive value specifying the total number of pairs in the multi-map.</returns>
    ///  <remarks>The value returned by this method represents the total number of key-value pairs
    ///  stored in the dictionary. In a multi-map this means that each value associated with a key
    ///  is calculated as a pair. If a key has multiple values associated with it, each key-value
    ///  combination is calculated as one.</remarks>
    property Count: NativeUInt read FKnownCount;

    ///  <summary>Specifies the collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the multi-map.</returns>
    property Keys: IEnexCollection<TKey> read FKeyCollection;

    ///  <summary>Specifies the collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the multi-map.</returns>
    property Values: IEnexCollection<TValue> read FValueCollection;

    ///  <summary>Returns a new enumerator object used to enumerate this multi-map.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the multi-map.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<KVPair<TKey,TValue>>; override;

    ///  <summary>Copies the values stored in the multi-map to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the multi-map.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the multi-map.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of KVPair<TKey,TValue>; const AStartIndex: NativeUInt); overload; override;

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to return the associated value.</param>
    ///  <returns>The value associated with the given key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">No such key in the multi-map.</exception>
    function ValueForKey(const AKey: TKey): TValue; override;

    ///  <summary>Checks whether the multi-map contains a given key-value pair.</summary>
    ///  <param name="AKey">The key part of the pair.</param>
    ///  <param name="AValue">The value part of the pair.</param>
    ///  <returns><c>True</c> if the given key-value pair exists; <c>False</c> otherwise.</returns>
    function KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean; override;

    ///  <summary>Returns an Enex collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the multi-map.</returns>
    function SelectKeys(): IEnexCollection<TKey>; override;

    ///  <summary>Returns a Enex collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the multi-map.</returns>
    function SelectValues(): IEnexCollection<TValue>; override;
  end;

  ///  <summary>The base abstract class for all <c>bidi-maps</c> in DeHL.</summary>
  TAbstractBidiMap<TKey, TValue> = class abstract(TEnexAssociativeCollection<TKey, TValue>, IBidiMap<TKey, TValue>)
  private
    FByKeyMap: IDistinctMultiMap<TKey, TValue>;
    FByValueMap: IDistinctMultiMap<TValue, TKey>;

    { Got from the underlying collections }
    FValueCollection: IEnexCollection<TValue>;
    FKeyCollection: IEnexCollection<TKey>;

  protected
    ///  <summary>Specifies the internal map used as back-end to store key relations.</summary>
    ///  <returns>A map used as back-end.</summary>
    property ByKeyMap: IDistinctMultiMap<TKey, TValue> read FByKeyMap;

    ///  <summary>Specifies the internal map used as back-end to store value relations.</summary>
    ///  <returns>A map used as back-end.</summary>
    property ByValueMap: IDistinctMultiMap<TValue, TKey> read FByValueMap;

    ///  <summary>Called when the map needs to initialize its internal key map.</summary>
    ///  <param name="AKeyType">The type object describing the keys.</param>
    function CreateKeyMap(const AKeyType: IType<TKey>;
      const AValueType: IType<TValue>): IDistinctMultiMap<TKey, TValue>; virtual; abstract;

    ///  <summary>Called when the map needs to initialize its internal value map.</summary>
    ///  <param name="AValueType">The type object describing the values.</param>
    function CreateValueMap(const AValueType: IType<TValue>;
      const AKeyType: IType<TKey>): IDistinctMultiMap<TValue, TKey>; virtual; abstract;

    ///  <summary>Returns the number of pairs in the bidi-map.</summary>
    ///  <returns>A positive value specifying the total number of pairs in the bidi-map.</returns>
    function GetCount(): NativeUInt; override;

    ///  <summary>Returns the collection of keys associated with a value.</summary>
    ///  <param name="AValue">The value for which to obtain the associated keys.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The value is not found in the bidi-map.</exception>
    function GetKeyList(const AValue: TValue): IEnexCollection<TKey>;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the bidi-map.</exception>
    function GetValueList(const AKey: TKey): IEnexCollection<TValue>;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const ACollection: IEnumerable<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: array of KVPair<TKey,TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TFixedArray<KVPair<TKey, TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the bidi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the bidi-map.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the bidi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the bidi-map.</param>
    ///  <param name="ACollection">A collection to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const ACollection: IEnumerable<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the bidi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the bidi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: array of KVPair<TKey,TValue>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the bidi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the bidi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TDynamicArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AKeyType">A type object decribing the keys in the bidi-map.</param>
    ///  <param name="AValueType">A type object decribing the values in the bidi-map.</param>
    ///  <param name="AArray">An array to copy pairs from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TFixedArray<KVPair<TKey,TValue>>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the bidi-map.</summary>
    ///  <remarks>This method clears the bidi-map and invokes type object's cleaning routines for key and value.</remarks>
    procedure Clear();

    ///  <summary>Adds a key-value pair to the bidi-map.</summary>
    ///  <param name="APair">The key-value pair to add.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The map already contains a pair with the given key.</exception>
    procedure Add(const APair: KVPair<TKey, TValue>); overload;

    ///  <summary>Adds a key-value pair to the bidi-map.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <exception cref="DeHL.Exceptions|EDuplicateKeyException">The map already contains a pair with the given key.</exception>
    procedure Add(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value pair using a given key.</summary>
    ///  <param name="AKey">The key (and its associated values) to remove.</param>
    ///  <remarks>This method removes all the values that are associated with the given key. The type object's cleanup
    ///  routines are used to cleanup the values that are dropped from the bidi-map.</remarks>
    procedure RemoveKey(const AKey: TKey);

    ///  <summary>Removes a key-value pair using a given key.</summary>
    ///  <param name="AKey">The key of pair.</param>
    ///  <remarks>This invokes type object's cleaning routines for value
    ///  associated with the key. If the specified key was not found in the bidi-map, nothing happens.</remarks>
    procedure Remove(const AKey: TKey); overload;

    ///  <summary>Removes a key-value pair using a given value.</summary>
    ///  <param name="AValue">The value (and its associated keys) to remove.</param>
    ///  <remarks>This method removes all the keys that are associated with the given value. The type object's cleanup
    ///  routines are used to cleanup the keys that are dropped from the bidi-map.</remarks>
    procedure RemoveValue(const AValue: TValue);

    ///  <summary>Removes a specific key-value combination.</summary>
    ///  <param name="AKey">The key to remove.</param>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>This method only remove a key-value combination if that combination actually exists in the bidi-map.
    ///  If the key is associated with another value, nothing happens.</remarks>
    procedure Remove(const AKey: TKey; const AValue: TValue); overload;

    ///  <summary>Removes a key-value combination.</summary>
    ///  <param name="APair">The pair to remove.</param>
    ///  <remarks>This method only remove a key-value combination if that combination actually exists in the bidi-map.
    ///  If the key is associated with another value, nothing happens.</remarks>
    procedure Remove(const APair: KVPair<TKey, TValue>); overload;

    ///  <summary>Checks whether the map contains a key-value pair identified by the given key.</summary>
    ///  <param name="AKey">The key to check for.</param>
    ///  <returns><c>True</c> if the map contains a pair identified by the given key; <c>False</c> otherwise.</returns>
    function ContainsKey(const AKey: TKey): Boolean;

    ///  <summary>Checks whether the map contains a key-value pair that contains a given value.</summary>
    ///  <param name="AValue">The value to check for.</param>
    ///  <returns><c>True</c> if the map contains a pair containing the given value; <c>False</c> otherwise.</returns>
    function ContainsValue(const AValue: TValue): Boolean;

    ///  <summary>Checks whether the map contains the given key-value combination.</summary>
    ///  <param name="AKey">The key associated with the value.</param>
    ///  <param name="AValue">The value associated with the key.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsPair(const AKey: TKey; const AValue: TValue): Boolean; overload;

    ///  <summary>Checks whether the map contains a given key-value combination.</summary>
    ///  <param name="APair">The key-value pair combination.</param>
    ///  <returns><c>True</c> if the map contains the given association; <c>False</c> otherwise.</returns>
    function ContainsPair(const APair: KVPair<TKey, TValue>): Boolean; overload;

    ///  <summary>Returns the collection of values associated with a key.</summary>
    ///  <param name="AKey">The key for which to obtain the associated values.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The key is not found in the bidi-map.</exception>
    property ByKey[const AKey: TKey]: IEnexCollection<TValue> read GetValueList;

    ///  <summary>Returns the collection of keys associated with a value.</summary>
    ///  <param name="AValue">The value for which to obtain the associated keys.</param>
    ///  <returns>An Enex collection that contains the values associated with this key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">The value is not found in the bidi-map.</exception>
    property ByValue[const AValue: TValue]: IEnexCollection<TKey> read GetKeyList;

    ///  <summary>Specifies the collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the bidi-map.</returns>
    property Keys: IEnexCollection<TKey> read FKeyCollection;

    ///  <summary>Specifies the collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the bidi-map.</returns>
    property Values: IEnexCollection<TValue> read FValueCollection;

    ///  <summary>Returns the number of pairs in the bidi-map.</summary>
    ///  <returns>A positive value specifying the total number of pairs in the bidi-map.</returns>
    property Count: NativeUInt read GetCount;

    ///  <summary>Returns a new enumerator object used to enumerate this bidi-map.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the bidi-map.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<KVPair<TKey, TValue>>; override;

    ///  <summary>Copies the values stored in the bidi-map to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the bidi-map.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the bidi-map.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of KVPair<TKey,TValue>; const AStartIndex: NativeUInt); overload; override;

    ///  <summary>Returns the value associated with the given key.</summary>
    ///  <param name="AKey">The key for which to return the associated value.</param>
    ///  <returns>The value associated with the given key.</returns>
    ///  <exception cref="DeHL.Exceptions|EKeyNotFoundException">No such key in the bidi-map.</exception>
    function ValueForKey(const AKey: TKey): TValue; override;

    ///  <summary>Checks whether the bidi-map contains a given key-value pair.</summary>
    ///  <param name="AKey">The key part of the pair.</param>
    ///  <param name="AValue">The value part of the pair.</param>
    ///  <returns><c>True</c> if the given key-value pair exists; <c>False</c> otherwise.</returns>
    function KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean; override;

    ///  <summary>Returns an Enex collection that contains only the keys.</summary>
    ///  <returns>An Enex collection that contains all the keys stored in the bidi-map.</returns>
    function SelectKeys(): IEnexCollection<TKey>; override;

    ///  <summary>Returns a Enex collection that contains only the values.</summary>
    ///  <returns>An Enex collection that contains all the values stored in the bidi-map.</returns>
    function SelectValues(): IEnexCollection<TValue>; override;
  end;

  ///  <summary>The base abstract class for all <c>bags</c> in DeHL.</summary>
  TAbstractBag<T> = class(TEnexCollection<T>, IBag<T>)
  private type
    {$REGION 'Internal Types'}
    { Enumerator }
    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FDict: TAbstractBag<T>;
      FCurrentKV: IEnumerator<KVPair<T, NativeUInt>>;
      FCurrentCount: NativeUInt;
      FValue: T;

    public
      { Constructor }
      constructor Create(const ADict: TAbstractBag<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;
    {$ENDREGION}

  private var
    FDictionary: IDictionary<T, NativeUInt>;
    FVer: NativeUInt;
    FKnownCount: NativeUInt;

  protected
    ///  <summary>Specifies the internal dictionary used as back-end.</summary>
    ///  <returns>A dictionary of lists used as back-end.</summary>
    property Dictionary: IDictionary<T, NativeUInt> read FDictionary;

    ///  <summary>Returns the number of elements in the bag.</summary>
    ///  <returns>A positive value specifying the number of elements in the bag.</returns>
    ///  <remarks>The returned value is calculated by taking each key and multiplying it to its weight in
    ///  the bag. For example an item that has a weight of <c>20</c> will increse the count with <c>20</c>.</remarks>
    function GetCount(): NativeUInt; override;

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

    ///  <summary>Called when the map needs to initialize its internal dictionary.</summary>
    ///  <param name="AType">The type object describing the elements.</param>
    ///  <remarks>This method creates a hash-based dictionary used as the underlying back-end for the bag.</remarks>
    function CreateDictionary(const AType: IType<T>): IDictionary<T, NativeUInt>; virtual; abstract;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(); overload;

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
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const ACollection: IEnumerable<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: array of T); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TDynamicArray<T>); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead.</remarks>
    destructor Destroy(); override;

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

    ///  <summary>Sets or gets the weight of an item in the bag.</summary>
    ///  <param name="AValue">The value.</param>
    ///  <remarks>If the value is not found in the bag, this method acts like an <c>Add</c> operation; otherwise
    ///  the weight of the stored item is adjusted.</remarks>
    property Weights[const AValue: T]: NativeUInt read GetWeight write SetWeight; default;

    ///  <summary>Returns the number of elements in the bag.</summary>
    ///  <returns>A positive value specifying the number of elements in the bag.</returns>
    ///  <remarks>The returned value is calculated by taking each key and multiplying it to its weight in
    ///  the bag. For example an item that has a weight of <c>20</c> will increse the count with <c>20</c>.</remarks>
    property Count: NativeUInt read FKnownCount;

    ///  <summary>Returns a new enumerator object used to enumerate this bag.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the bag.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator(): IEnumerator<T>; override;

    ///  <summary>Copies the values stored in the bag to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the bag.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the bag.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const StartIndex: NativeUInt); overload; override;

    ///  <summary>Checks whether the bag is empty.</summary>
    ///  <returns><c>True</c> if the bag is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the bag is empty.</remarks>
    function Empty(): Boolean; override;

    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the bag considered to have the biggest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The bag is empty.</exception>
    function Max(): T; override;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the bag considered to have the smallest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The bag is empty.</exception>
    function Min(): T; override;

    ///  <summary>Returns the first element.</summary>
    ///  <returns>The first element in the bag.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The bag is empty.</exception>
    function First(): T; override;

    ///  <summary>Returns the first element or a default if the bag is empty.</summary>
    ///  <param name="ADefault">The default value returned if the bag is empty.</param>
    ///  <returns>The first element in bag if the bag is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function FirstOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the last element.</summary>
    ///  <returns>The last element in the bag.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The bag is empty.</exception>
    function Last(): T; override;

    ///  <summary>Returns the last element or a default if the bag is empty.</summary>
    ///  <param name="ADefault">The default value returned if the bag is empty.</param>
    ///  <returns>The last element in bag if the bag is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function LastOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the single element stored in the bag.</summary>
    ///  <returns>The element in bag.</returns>
    ///  <remarks>This method checks if the bag contains just one element, in which case it is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The bag is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionNotOneException">There is more than one element in the bag.</exception>
    function Single(): T; override;

    ///  <summary>Returns the single element stored in the bag, or a default value.</summary>
    ///  <param name="ADefault">The default value returned if there is less or more elements in the bag.</param>
    ///  <returns>The element in the bag if the condition is satisfied; <paramref name="ADefault"/> is returned otherwise.</returns>
    ///  <remarks>This method checks if the bag contains just one element, in which case it is returned. Otherwise
    ///  the value in <paramref name="ADefault"/> is returned.</remarks>
    function SingleOrDefault(const ADefault: T): T; override;

    ///  <summary>Check whether at least one element in the bag satisfies a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if the at least one element satisfies a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole bag and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>True</c>. The logical equivalent of this operation is "OR".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;

    ///  <summary>Checks that all elements in the bag satisfy a given predicate.</summary>
    ///  <param name="APredicate">The predicate to check for each element.</param>
    ///  <returns><c>True</c> if all elements satisfy a given predicate; <c>False</c> otherwise.</returns>
    ///  <remarks>This method traverses the whole bag and checks the value of the predicate for each element. This method
    ///  stops on the first element for which the predicate returns <c>False</c>. The logical equivalent of this operation is "AND".</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="APredicate"/> is <c>nil</c>.</exception>
    function All(const APredicate: TFunc<T, Boolean>): Boolean; override;
  end;

implementation

{ TAbstractMultiMap<TKey, TValue> }

procedure TAbstractMultiMap<TKey, TValue>.Add(const APair: KVPair<TKey, TValue>);
begin
  { Call the other add }
  Add(APair.Key, APair.Value);
end;

procedure TAbstractMultiMap<TKey, TValue>.Add(const AKey: TKey; const AValue: TValue);
var
  List: IList<TValue>;
begin
  { Try to look-up what we need. Create a new list and add it if required. }
  if not FDictionary.TryGetValue(AKey, List) then
  begin
    List := CreateList(FValueType);
    FDictionary[AKey] := List;
  end;

  { Add the new element to the list }
  List.Add(AValue);

  { Increase the version }
  Inc(FKnownCount);
  Inc(FVer);
end;

procedure TAbstractMultiMap<TKey, TValue>.Clear;
var
  List: IList<TValue>;
begin
  if (FDictionary <> nil) then
    { Simply clear out the dictionary }
    FDictionary.Clear();

  { Increase the version }
  FKnownCount := 0;
  Inc(FVer);
end;

function TAbstractMultiMap<TKey, TValue>.ContainsKey(const AKey: TKey): Boolean;
begin
  { Delegate to the dictionary object }
  Result := FDictionary.ContainsKey(AKey);
end;

function TAbstractMultiMap<TKey, TValue>.ContainsValue(const AKey: TKey; const AValue: TValue): Boolean;
var
  List: IList<TValue>;
begin
  { Try to find .. otherwise fail! }
  if FDictionary.TryGetValue(AKey, List) then
    Result := List.Contains(AValue)
  else
    Result := false;
end;

function TAbstractMultiMap<TKey, TValue>.ContainsValue(const APair: KVPair<TKey, TValue>): Boolean;
begin
  { Call upper function }
  Result := ContainsValue(APair.Key, APair.Value);
end;

function TAbstractMultiMap<TKey, TValue>.ContainsValue(const AValue: TValue): Boolean;
var
  List: IList<TValue>;
begin
  { Iterate over the dictionary }
  for List in FDictionary.Values do
  begin
    { Is there anything there? }
    if List.Contains(AValue) then
      Exit(true);
  end;

  { Nothing found }
  Result := false;
end;

procedure TAbstractMultiMap<TKey, TValue>.CopyTo(var AArray: array of KVPair<TKey, TValue>; const AStartIndex: NativeUInt);
var
  Key: TKey;
  List: IList<TValue>;
  X, I: NativeUInt;
begin
  { Check for indexes }
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  if (NativeUInt(Length(AArray)) - AStartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := AStartIndex;

  { Iterate over all lists and copy thtm to array }
  for Key in FDictionary.Keys do
  begin
    List := FDictionary[Key];

    if List.Count > 0 then
      for I := 0 to List.Count - 1 do
        AArray[X + I] := KVPair.Create<TKey, TValue>(Key, List[I]);

    Inc(X, List.Count);
  end;
end;

constructor TAbstractMultiMap<TKey, TValue>.Create;
begin
  Create(TType<TKey>.Default, TType<TValue>.Default);
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(
  const ACollection: IEnumerable<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, ACollection);
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>);
begin
  { Initialize instance }
  if (AKeyType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AKeyType');

  if (AValueType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AValueType');

  { Insatll the types }
  InstallTypes(AKeyType, AValueType);

  { Create the dictionary }
  FDictionary := CreateDictionary(KeyType);

  FKeyCollection := TKeyCollection.Create(Self);
  FValueCollection := TValueCollection.Create(Self);

  { Create an internal empty list }
  FEmptyList := CreateList(ValueType);

  FKnownCount := 0;
  FVer := 0;
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const ACollection: IEnumerable<KVPair<TKey, TValue>>);
var
  V: KVPair<TKey, TValue>;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Pump in all items }
  for V in ACollection do
  begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    Add(V);
{$ELSE}
    Add(V.Key, V.Value);
{$ENDIF}
  end;
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(
  const AArray: array of KVPair<TKey, TValue>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: array of KVPair<TKey, TValue>);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;


constructor TAbstractMultiMap<TKey, TValue>.Create(const AArray: TFixedArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TFixedArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;

constructor TAbstractMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TDynamicArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;


destructor TAbstractMultiMap<TKey, TValue>.Destroy;
begin
  { Clear first }
  Clear();

  inherited;
end;

function TAbstractMultiMap<TKey, TValue>.GetCount: NativeUInt;
begin
  Result := FKnownCount;
end;

function TAbstractMultiMap<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  Result := TPairEnumerator.Create(Self);
end;

function TAbstractMultiMap<TKey, TValue>.GetItemList(const AKey: TKey): IEnexIndexedCollection<TValue>;
var
  List: IList<TValue>;
begin
  if not FDictionary.TryGetValue(AKey, List) then
    ExceptionHelper.Throw_KeyNotFoundError('AKey');

  Result := List;
end;

function TAbstractMultiMap<TKey, TValue>.KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean;
begin
  Result := ContainsValue(AKey, AValue);
end;

procedure TAbstractMultiMap<TKey, TValue>.Remove(const AKey: TKey; const AValue: TValue);
var
  List: IList<TValue>;
begin
  { Simply remove the value from the list at key }
  if FDictionary.TryGetValue(AKey, List) then
  begin
    if List.Contains(AValue) then
    begin
      List.Remove(AValue);

      { Kill the list for one element }
      if List.Count = 0 then
        FDictionary.Remove(AKey);

      Dec(FKnownCount, 1);

      { Increase the version }
      Inc(FVer);
    end;
  end;
end;

procedure TAbstractMultiMap<TKey, TValue>.Remove(const APair: KVPair<TKey, TValue>);
begin
  { Call upper function }
  Remove(APair.Key, APair.Value);
end;

function TAbstractMultiMap<TKey, TValue>.SelectKeys: IEnexCollection<TKey>;
begin
  Result := Keys;
end;

function TAbstractMultiMap<TKey, TValue>.SelectValues: IEnexCollection<TValue>;
begin
  Result := Values;
end;

function TAbstractMultiMap<TKey, TValue>.TryGetValues(const AKey: TKey): IEnexIndexedCollection<TValue>;
begin
  if not TryGetValues(AKey, Result) then
    Result := FEmptyList;
end;

function TAbstractMultiMap<TKey, TValue>.TryGetValues(const AKey: TKey;
  out AValues: IEnexIndexedCollection<TValue>): Boolean;
var
  LList: IList<TValue>;
begin
  { Use the internal stuff }
  Result := FDictionary.TryGetValue(AKey, LList);

  if Result then
    AValues := LList;
end;

function TAbstractMultiMap<TKey, TValue>.ValueForKey(const AKey: TKey): TValue;
begin
  Result := GetItemList(AKey)[0];
end;

procedure TAbstractMultiMap<TKey, TValue>.Remove(const AKey: TKey);
var
  List: IList<TValue>;
begin
  if FDictionary.TryGetValue(AKey, List) then
    Dec(FKnownCount, List.Count);

  { Simply remove the element. The list should be auto-magically collected also }
  FDictionary.Remove(AKey);

  { Increase the version }
  Inc(FVer);
end;

{ TAbstractMultiMap<TKey, TValue>.TPairEnumerator }

constructor TAbstractMultiMap<TKey, TValue>.TPairEnumerator.Create(const ADict: TAbstractMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FVer := ADict.FVer;

  { Get the enumerator }
  FListIndex := 0;
  FDictEnum := FDict.FDictionary.GetEnumerator();
  FList := nil;
end;

destructor TAbstractMultiMap<TKey, TValue>.TPairEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TAbstractMultiMap<TKey, TValue>.TPairEnumerator.GetCurrent: KVPair<TKey,TValue>;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TAbstractMultiMap<TKey, TValue>.TPairEnumerator.MoveNext: Boolean;
begin
  { Repeat until something happens }
  while True do
  begin
    if FVer <> FDict.FVer then
       ExceptionHelper.Throw_CollectionChangedError();

    { We're still in the same KV? }
    if (FList <> nil) and (FListIndex < FList.Count) then
    begin
      { Next element }
      FValue := KVPair<TKey, TValue>.Create(FDictEnum.Current.Key, FList[FListIndex]);

      Inc(FListIndex);
      Result := true;

      Exit;
    end;

    { Get the next KV pair from the dictionary }
    Result := FDictEnum.MoveNext();
    if not Result then
    begin
      FList := nil;
      Exit;
    end;

    { Reset the list }
    FListIndex := 0;
    FList := FDictEnum.Current.Value;
  end;
end;

{ TAbstractMultiMap<TKey, TValue>.TKeyEnumerator }

constructor TAbstractMultiMap<TKey, TValue>.TKeyEnumerator.Create(const ADict: TAbstractMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FVer := ADict.FVer;
  FValue := default(TKey);

  { Create enumerator }
  FDictEnum := FDict.FDictionary.Keys.GetEnumerator();
end;

destructor TAbstractMultiMap<TKey, TValue>.TKeyEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TAbstractMultiMap<TKey, TValue>.TKeyEnumerator.GetCurrent: TKey;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TAbstractMultiMap<TKey, TValue>.TKeyEnumerator.MoveNext: Boolean;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  { Move next and get the value }
  Result := FDictEnum.MoveNext();
  if Result then
    FValue := FDictEnum.Current;
end;


{ TAbstractMultiMap<TKey, TValue>.TValueEnumerator }

constructor TAbstractMultiMap<TKey, TValue>.TValueEnumerator.Create(const ADict: TAbstractMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FVer := ADict.FVer;

  { Get the enumerator }
  FListIndex := 0;
  FDictEnum := FDict.FDictionary.Values.GetEnumerator();
  FList := nil;
end;

destructor TAbstractMultiMap<TKey, TValue>.TValueEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TAbstractMultiMap<TKey, TValue>.TValueEnumerator.GetCurrent: TValue;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TAbstractMultiMap<TKey, TValue>.TValueEnumerator.MoveNext: Boolean;
begin
  { Repeat until something happens }
  while True do
  begin
    if FVer <> FDict.FVer then
       ExceptionHelper.Throw_CollectionChangedError();

    { We're still in the same KV? }
    if (FList <> nil) and (FListIndex < FList.Count) then
    begin
      { Next element }
      FValue := FList[FListIndex];

      Inc(FListIndex);
      Result := true;

      Exit;
    end;

    { Get the next KV pair from the dictionary }
    Result := FDictEnum.MoveNext();
    if not Result then
    begin
      FList := nil;
      Exit;
    end;

    { Reset the list }
    FListIndex := 0;
    FList := FDictEnum.Current;
  end;
end;

{ TAbstractMultiMap<TKey, TValue>.TKeyCollection }

constructor TAbstractMultiMap<TKey, TValue>.TKeyCollection.Create(const ADict: TAbstractMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;

  InstallType(ADict.KeyType);
end;

destructor TAbstractMultiMap<TKey, TValue>.TKeyCollection.Destroy;
begin
  inherited;
end;

function TAbstractMultiMap<TKey, TValue>.TKeyCollection.Empty: Boolean;
begin
  Result := (FDict.FDictionary.Count = 0);
end;

function TAbstractMultiMap<TKey, TValue>.TKeyCollection.GetCount: NativeUInt;
begin
  { Number of elements is the same as key }
  Result := FDict.FDictionary.Count;
end;

function TAbstractMultiMap<TKey, TValue>.TKeyCollection.GetEnumerator: IEnumerator<TKey>;
begin
  Result := TKeyEnumerator.Create(Self.FDict);
end;

procedure TAbstractMultiMap<TKey, TValue>.TKeyCollection.CopyTo(var AArray: array of TKey; const StartIndex: NativeUInt);
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < FDict.FDictionary.Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Simply copy using the dictionary provided methods }
  FDict.FDictionary.Keys.CopyTo(AArray, StartIndex);
end;

{ TAbstractMultiMap<TKey, TValue>.TValueCollection }

constructor TAbstractMultiMap<TKey, TValue>.TValueCollection.Create(const ADict: TAbstractMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;

  InstallType(ADict.ValueType);
end;

destructor TAbstractMultiMap<TKey, TValue>.TValueCollection.Destroy;
begin
  inherited;
end;

function TAbstractMultiMap<TKey, TValue>.TValueCollection.Empty: Boolean;
begin
  Result := (FDict.FDictionary.Count = 0);
end;

function TAbstractMultiMap<TKey, TValue>.TValueCollection.GetCount: NativeUInt;
begin
  { Number of elements is different use the count provided by the dictionary }
  Result := FDict.Count;
end;

function TAbstractMultiMap<TKey, TValue>.TValueCollection.GetEnumerator: IEnumerator<TValue>;
begin
  Result := TValueEnumerator.Create(Self.FDict);
end;

procedure TAbstractMultiMap<TKey, TValue>.TValueCollection.CopyTo(var AArray: array of TValue; const StartIndex: NativeUInt);
var
  List: IList<TValue>;
  X, I: NativeUInt;
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < FDict.Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := StartIndex;

  { Iterate over all lists and copy thtm to array }
  for List in FDict.FDictionary.Values do
  begin
    if List.Count > 0 then
      for I := 0 to List.Count - 1 do
        AArray[X + I] := List[I];

    Inc(X, List.Count);
  end;
end;



{ TAbstractDistinctMultiMap<TKey, TValue> }

procedure TAbstractDistinctMultiMap<TKey, TValue>.Add(const APair: KVPair<TKey, TValue>);
begin
  { Call the other add }
  Add(APair.Key, APair.Value);
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.Add(const AKey: TKey; const AValue: TValue);
var
  LSet: ISet<TValue>;
begin
  { Try to look-up what we need. Create a new list and add it if required. }
  if not FDictionary.TryGetValue(AKey, LSet) then
  begin
    LSet := CreateSet(FValueType);
    FDictionary[AKey] := LSet;
  end;

  { Add the new element to the list }
  if not LSet.Contains(AValue) then
  begin
    LSet.Add(AValue);

    { Increase the version }
    Inc(FKnownCount);
    Inc(FVer);
  end;
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.Clear;
var
  List: IList<TValue>;
begin
  if (FDictionary <> nil) then
    { Simply clear out the dictionary }
    FDictionary.Clear();

  { Increase the version }
  FKnownCount := 0;
  Inc(FVer);
end;

function TAbstractDistinctMultiMap<TKey, TValue>.ContainsKey(const AKey: TKey): Boolean;
begin
  { Delegate to the dictionary object }
  Result := FDictionary.ContainsKey(AKey);
end;

function TAbstractDistinctMultiMap<TKey, TValue>.ContainsValue(const AKey: TKey; const AValue: TValue): Boolean;
var
  LSet: ISet<TValue>;
begin
  { Try to find .. otherwise fail! }
  if FDictionary.TryGetValue(AKey, LSet) then
    Result := LSet.Contains(AValue)
  else
    Result := false;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.ContainsValue(const APair: KVPair<TKey, TValue>): Boolean;
begin
  { Call upper function }
  Result := ContainsValue(APair.Key, APair.Value);
end;

function TAbstractDistinctMultiMap<TKey, TValue>.ContainsValue(const AValue: TValue): Boolean;
var
  LSet: ISet<TValue>;
begin
  { Iterate over the dictionary }
  for LSet in FDictionary.Values do
  begin
    { Is there anything there? }
    if LSet.Contains(AValue) then
      Exit(true);
  end;

  { Nothing found }
  Result := false;
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.CopyTo(
  var AArray: array of KVPair<TKey, TValue>; const AStartIndex: NativeUInt);
var
  Key: TKey;
  Value: TValue;
  LSet: ISet<TValue>;
  X: NativeUInt;
begin
  { Check for indexes }
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  if (NativeUInt(Length(AArray)) - AStartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := AStartIndex;

  { Iterate over all lists and copy thtm to array }
  for Key in FDictionary.Keys do
  begin
    LSet := FDictionary[Key];

    for Value in LSet do
    begin
      AArray[X] := KVPair.Create<TKey, TValue>(Key, Value);
      Inc(X);
    end;
  end;
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create;
begin
  Create(TType<TKey>.Default, TType<TValue>.Default);
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(
  const ACollection: IEnumerable<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, ACollection);
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>);
begin
  { Initialize instance }
  if (AKeyType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AKeyType');

  if (AValueType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AValueType');

  { Install the types }
  InstallTypes(AKeyType, AValueType);

  { Create the dictionary }
  FDictionary := CreateDictionary(KeyType);

  FKeyCollection := TKeyCollection.Create(Self);
  FValueCollection := TValueCollection.Create(Self);

  FEmptySet := CreateSet(ValueType);

  FKnownCount := 0;
  FVer := 0;
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const ACollection: IEnumerable<KVPair<TKey, TValue>>);
var
  V: KVPair<TKey, TValue>;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Pump in all items }
  for V in ACollection do
  begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    Add(V);
{$ELSE}
    Add(V.Key, V.Value);
{$ENDIF}
  end;
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(
  const AArray: array of KVPair<TKey, TValue>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(
  const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: array of KVPair<TKey, TValue>);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;


constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(const AArray: TFixedArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TFixedArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;

constructor TAbstractDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TDynamicArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;

destructor TAbstractDistinctMultiMap<TKey, TValue>.Destroy;
begin
  { Clear first }
  Clear();

  inherited;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.GetCount: NativeUInt;
begin
  Result := FKnownCount;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  Result := TPairEnumerator.Create(Self);
end;

function TAbstractDistinctMultiMap<TKey, TValue>.GetItemList(const AKey: TKey): IEnexCollection<TValue>;
var
  LSet: ISet<TValue>;
begin
  if not FDictionary.TryGetValue(AKey, LSet) then
    ExceptionHelper.Throw_KeyNotFoundError('AKey');

  Result := LSet;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean;
begin
  Result := ContainsValue(AKey, AValue);
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.Remove(const AKey: TKey; const AValue: TValue);
var
  LSet: ISet<TValue>;
begin
  { Simply remove the value from the list at key }
  if FDictionary.TryGetValue(AKey, LSet) then
  begin
    if LSet.Contains(AValue) then
    begin
      LSet.Remove(AValue);

      { Kill the list for one element }
      if LSet.Count = 0 then
        FDictionary.Remove(AKey);

      Dec(FKnownCount, 1);
    end;
  end;

  { Increase th version }
  Inc(FVer);
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.Remove(const APair: KVPair<TKey, TValue>);
begin
  { Call upper function }
  Remove(APair.Key, APair.Value);
end;

function TAbstractDistinctMultiMap<TKey, TValue>.SelectKeys: IEnexCollection<TKey>;
begin
  Result := Keys;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.SelectValues: IEnexCollection<TValue>;
begin
  Result := Values;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TryGetValues(
  const AKey: TKey): IEnexCollection<TValue>;
begin
  if not TryGetValues(AKey, Result) then
    Result := FEmptySet;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TryGetValues(const AKey: TKey;
  out AValues: IEnexCollection<TValue>): Boolean;
var
  LSet: ISet<TValue>;
begin
  { Use the internal stuff }
  Result := FDictionary.TryGetValue(AKey, LSet);

  if Result then
    AValues := LSet;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.ValueForKey(const AKey: TKey): TValue;
begin
  Result := GetItemList(AKey).First;
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.Remove(const AKey: TKey);
var
  LSet: ISet<TValue>;
begin
  if FDictionary.TryGetValue(AKey, LSet) then
    Dec(FKnownCount, LSet.Count);

  { Simply remove the element. The list should be auto-magically collected also }
  FDictionary.Remove(AKey);

  { Increase th version }
  Inc(FVer);
end;

{ TAbstractBidiMap<TKey, TValue> }

constructor TAbstractBidiMap<TKey, TValue>.Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const AArray: TFixedArray<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const AArray: array of KVPair<TKey, TValue>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TAbstractBidiMap<TKey, TValue>.Create;
begin
  Create(TType<TKey>.Default, TType<TValue>.Default);
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const ACollection: IEnumerable<KVPair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, ACollection);
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TDynamicArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;

procedure TAbstractBidiMap<TKey, TValue>.Add(const AKey: TKey; const AValue: TValue);
begin
  { Add the K/V pair to the maps }
  FByKeyMap.Add(AKey, AValue);
  FByValueMap.Add(AValue, AKey);
end;

procedure TAbstractBidiMap<TKey, TValue>.Add(const APair: KVPair<TKey, TValue>);
begin
  Add(APair.Key, APair.Value);
end;

procedure TAbstractBidiMap<TKey, TValue>.Clear;
begin
  if FByKeyMap <> nil then
    FByKeyMap.Clear;

  if FByValueMap <> nil then
    FByValueMap.Clear;
end;

function TAbstractBidiMap<TKey, TValue>.ContainsKey(const AKey: TKey): Boolean;
begin
  Result := FByKeyMap.ContainsKey(AKey);
end;

function TAbstractBidiMap<TKey, TValue>.ContainsPair(const APair: KVPair<TKey, TValue>): Boolean;
begin
  { The the by-key relation since it is correct always }
  Result := FByKeyMap.ContainsValue(APair.Key, APair.Value);
end;

function TAbstractBidiMap<TKey, TValue>.ContainsPair(const AKey: TKey; const AValue: TValue): Boolean;
begin
  { The the by-key relation since it is correct always }
  Result := FByKeyMap.ContainsValue(AKey, AValue);
end;

function TAbstractBidiMap<TKey, TValue>.ContainsValue(const AValue: TValue): Boolean;
begin
  Result := FByValueMap.ContainsKey(AValue);
end;

procedure TAbstractBidiMap<TKey, TValue>.CopyTo(var AArray: array of KVPair<TKey, TValue>; const AStartIndex: NativeUInt);
begin
  { Check for indexes }
  if AStartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('AStartIndex');

  if (NativeUInt(Length(AArray)) - AStartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Call the underlying collection }
  FByKeyMap.CopyTo(AArray, AStartIndex);
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TFixedArray<KVPair<TKey, TValue>>);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
      Add(AArray[I]);
{$ELSE}
      Add(AArray[I].Key, AArray[I].Value);
{$ENDIF}
    end;
end;

destructor TAbstractBidiMap<TKey, TValue>.Destroy;
begin
  { Clear out the instance }
  Clear();

  inherited;
end;

function TAbstractBidiMap<TKey, TValue>.GetCount: NativeUInt;
begin
  { The cound follows the map properties }
  Result := FByKeyMap.Count;
end;

function TAbstractBidiMap<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  { Pass the enumerator from the key map }
  Result := FByKeyMap.GetEnumerator();
end;

function TAbstractBidiMap<TKey, TValue>.GetKeyList(const AValue: TValue): IEnexCollection<TKey>;
begin
  Result := FByValueMap[AValue];
end;

function TAbstractBidiMap<TKey, TValue>.GetValueList(const AKey: TKey): IEnexCollection<TValue>;
begin
  Result := FByKeyMap[AKey];
end;

function TAbstractBidiMap<TKey, TValue>.KeyHasValue(const AKey: TKey; const AValue: TValue): Boolean;
begin
  Result := ContainsPair(AKey, AValue);
end;

procedure TAbstractBidiMap<TKey, TValue>.Remove(const AKey: TKey; const AValue: TValue);
var
  LValues: IEnexCollection<TValue>;
  LValue: TValue;
begin
  { Check whether there is such a key }
  if not FByKeyMap.ContainsValue(AKey, AValue) then
    Exit;

  { Remove the stuff }
  FByKeyMap.Remove(AKey, AValue);
  FByValueMap.Remove(AValue, AKey);
end;

procedure TAbstractBidiMap<TKey, TValue>.Remove(const APair: KVPair<TKey, TValue>);
begin
  Remove(APair.Key, APair.Value);
end;

procedure TAbstractBidiMap<TKey, TValue>.Remove(const AKey: TKey);
begin
  RemoveKey(AKey);
end;

procedure TAbstractBidiMap<TKey, TValue>.RemoveKey(const AKey: TKey);
var
  LValues: IEnexCollection<TValue>;
  LValue: TValue;
begin
  { Check whether there is such a key }
  if not FByKeyMap.TryGetValues(AKey, LValues) then
    Exit;

  { Exclude the key for all values too }
  for LValue in LValues do
    FByValueMap.Remove(LValue, AKey);

  { And finally remove the key }
  FByKeyMap.Remove(AKey);
end;

procedure TAbstractBidiMap<TKey, TValue>.RemoveValue(const AValue: TValue);
var
  LKeys: IEnexCollection<TKey>;
  LValue: TKey;
begin
  { Check whether there is such a key }
  if not FByValueMap.TryGetValues(AValue, LKeys) then
    Exit;

  { Exclude the key for all values too}
  for LValue in LKeys do
    FByKeyMap.Remove(LValue, AValue);

  { And finally remove the key }
  FByValueMap.Remove(AValue);

//  { Cleanup the value if necessary }
//  if ValueType.Management = tmManual then
//    ValueType.Cleanup(LValue);
end;

function TAbstractBidiMap<TKey, TValue>.SelectKeys: IEnexCollection<TKey>;
begin
  { Pass the values on }
  Result := Keys;
end;

function TAbstractBidiMap<TKey, TValue>.SelectValues: IEnexCollection<TValue>;
begin
  { Pass the value on }
  Result := Values;
end;

function TAbstractBidiMap<TKey, TValue>.ValueForKey(const AKey: TKey): TValue;
begin
  Result := FByKeyMap[AKey].First;
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: array of KVPair<TKey, TValue>);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
var
  LKeyWrap: IType<TKey>;
  LValueWrap: IType<TValue>;
begin
  { Initialize instance }
  if (AKeyType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AKeyType');

  if (AValueType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AValueType');

  { Install the types }
  InstallTypes(AKeyType, AValueType);

  { Create type wrappers - basically disabling the cleanup for pne of the maps }
  LKeyWrap := TSuppressedWrapperType<TKey>.Create(KeyType);
  LValueWrap := TSuppressedWrapperType<TValue>.Create(ValueType);

  { Create the maps }
  FByKeyMap := CreateKeyMap(LKeyWrap, ValueType);
  FByValueMap := CreateValueMap(LValueWrap, KeyType);

  { The collections }
  FValueCollection := FByValueMap.Keys;
  FKeyCollection := FByKeyMap.Keys;
end;

constructor TAbstractBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const ACollection: IEnumerable<KVPair<TKey, TValue>>);
var
  V: KVPair<TKey, TValue>;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Pump in all items }
  for V in ACollection do
  begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    Add(V);
{$ELSE}
    Add(V.Key, V.Value);
{$ENDIF}
  end;
end;

{ TAbstractDistinctMultiMap<TKey, TValue>.TPairEnumerator }

constructor TAbstractDistinctMultiMap<TKey, TValue>.TPairEnumerator.Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FVer := ADict.FVer;

  { Get the enumerator }
  FDictEnum := FDict.FDictionary.GetEnumerator();
end;

destructor TAbstractDistinctMultiMap<TKey, TValue>.TPairEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TPairEnumerator.GetCurrent: KVPair<TKey,TValue>;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TPairEnumerator.MoveNext: Boolean;
begin
  { Repeat until something happens }
  while True do
  begin
    if FVer <> FDict.FVer then
       ExceptionHelper.Throw_CollectionChangedError();

    { We're still in the same KV? }
    if (FSetEnum <> nil) and (FSetEnum.MoveNext) then
    begin
      { Next element }
      FValue := KVPair.Create<TKey, TValue>(FDictEnum.Current.Key, FSetEnum.Current);
      Result := true;
      Exit;
    end;

    { Get the next KV pair from the dictionary }
    Result := FDictEnum.MoveNext();
    if not Result then
      Exit;

    { Reset the list }
    FSet := FDictEnum.Current.Value;
    FSetEnum := FSet.GetEnumerator();
  end;
end;

{ TAbstractDistinctMultiMap<TKey, TValue>.TKeyEnumerator }

constructor TAbstractDistinctMultiMap<TKey, TValue>.TKeyEnumerator.Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FVer := ADict.FVer;
  FValue := default(TKey);

  { Create enumerator }
  FDictEnum := FDict.FDictionary.Keys.GetEnumerator();
end;

destructor TAbstractDistinctMultiMap<TKey, TValue>.TKeyEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TKeyEnumerator.GetCurrent: TKey;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TKeyEnumerator.MoveNext: Boolean;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  { Move next and get the value }
  Result := FDictEnum.MoveNext();
  if Result then
    FValue := FDictEnum.Current;
end;


{ TAbstractDistinctMultiMap<TKey, TValue>.TValueEnumerator }

constructor TAbstractDistinctMultiMap<TKey, TValue>.TValueEnumerator.Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);
  FVer := ADict.FVer;

  { Get the enumerator }
  FDictEnum := FDict.FDictionary.Values.GetEnumerator();
end;

destructor TAbstractDistinctMultiMap<TKey, TValue>.TValueEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TValueEnumerator.GetCurrent: TValue;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TValueEnumerator.MoveNext: Boolean;
begin
  { Repeat until something happens }
  while True do
  begin
    if FVer <> FDict.FVer then
       ExceptionHelper.Throw_CollectionChangedError();

    { We're still in the same KV? }
    if (FSetEnum <> nil) and (FSetEnum.MoveNext()) then
    begin
      { Next element }
      FValue := FSetEnum.Current;

      Result := true;
      Exit;
    end;

    { Get the next KV pair from the dictionary }
    Result := FDictEnum.MoveNext();
    if not Result then
      Exit;

    { Reset the list }
    FSet := FDictEnum.Current;
    FSetEnum := FSet.GetEnumerator();
  end;
end;

{ TAbstractDistinctMultiMap<TKey, TValue>.TKeyCollection }

constructor TAbstractDistinctMultiMap<TKey, TValue>.TKeyCollection.Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;

  InstallType(ADict.KeyType);
end;

destructor TAbstractDistinctMultiMap<TKey, TValue>.TKeyCollection.Destroy;
begin
  inherited;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TKeyCollection.Empty: Boolean;
begin
  Result := (FDict.FDictionary.Count = 0);
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TKeyCollection.GetCount: NativeUInt;
begin
  { Number of elements is the same as key }
  Result := FDict.FDictionary.Count;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TKeyCollection.GetEnumerator: IEnumerator<TKey>;
begin
  Result := TKeyEnumerator.Create(Self.FDict);
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.TKeyCollection.CopyTo(var AArray: array of TKey; const StartIndex: NativeUInt);
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < FDict.FDictionary.Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Simply copy using the dictionary provided methods }
  FDict.FDictionary.Keys.CopyTo(AArray, StartIndex);
end;

{ TAbstractDistinctMultiMap<TKey, TValue>.TValueCollection }

constructor TAbstractDistinctMultiMap<TKey, TValue>.TValueCollection.Create(const ADict: TAbstractDistinctMultiMap<TKey, TValue>);
begin
  { Initialize }
  FDict := ADict;

  InstallType(ADict.ValueType);
end;

destructor TAbstractDistinctMultiMap<TKey, TValue>.TValueCollection.Destroy;
begin
  inherited;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TValueCollection.Empty: Boolean;
begin
  Result := (FDict.FDictionary.Count = 0);
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TValueCollection.GetCount: NativeUInt;
begin
  { Number of elements is different use the count provided by the dictionary }
  Result := FDict.Count;
end;

function TAbstractDistinctMultiMap<TKey, TValue>.TValueCollection.GetEnumerator: IEnumerator<TValue>;
begin
  Result := TValueEnumerator.Create(Self.FDict);
end;

procedure TAbstractDistinctMultiMap<TKey, TValue>.TValueCollection.CopyTo(var AArray: array of TValue; const StartIndex: NativeUInt);
var
  LSet: ISet<TValue>;
  Value: TValue;
  X: NativeUInt;
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < FDict.Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := StartIndex;

  { Iterate over all lists and copy thtm to array }
  for LSet in FDict.FDictionary.Values do
  begin
    for Value in LSet do
    begin
      AArray[X] := Value;
      Inc(X);
    end;
  end;
end;

{ TAbstractBag<T> }

procedure TAbstractBag<T>.Add(const AValue: T; const AWeight: NativeUInt);
var
  OldCount: NativeUInt;
begin
  { Check count > 0 }
  if AWeight = 0 then
    Exit;

  { Add or update count }
  if FDictionary.TryGetValue(AValue, OldCount) then
    FDictionary[AValue] := OldCount + AWeight
  else
    FDictionary.Add(AValue, AWeight);

  Inc(FKnownCount, AWeight);
  Inc(FVer);
end;

function TAbstractBag<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.All(APredicate);
end;

function TAbstractBag<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.Any(APredicate);
end;

procedure TAbstractBag<T>.Clear;
begin
  if FDictionary <> nil then
  begin
    { Simply clear the dictionary }
    FDictionary.Clear();

    FKnownCount := 0;
    Inc(FVer);
  end;
end;

function TAbstractBag<T>.Contains(const AValue: T; const AWeight: NativeUInt): Boolean;
var
  InCount: NativeUInt;
begin
  { Check count > 0 }
  if AWeight = 0 then
    Exit(true);

  { Check the counts in the bag }
  Result := (FDictionary.TryGetValue(AValue, InCount)) and (InCount >= AWeight);
end;

procedure TAbstractBag<T>.CopyTo(var AArray: array of T; const StartIndex: NativeUInt);
var
  TempArray: array of KVPair<T, NativeUInt>;
  I, X, Y: NativeUInt;
begin
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  { Check for indexes }
  if (NativeUInt(Length(AArray)) - StartIndex) < Count then
    ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Nothing to do? }
  if Count = 0 then
    Exit;

  { Initialize the temporary array }
  SetLength(TempArray, FDictionary.Count);
  FDictionary.CopyTo(TempArray);

  X := StartIndex;

  { OK! Now let's simply copy }
  for I := 0 to Length(TempArray) - 1 do
  begin
    { Copy one value for a number of counts }
    for Y := 0 to TempArray[I].Value - 1 do
    begin
      AArray[X] := TempArray[I].Key;
      Inc(X);
    end;
  end;
end;

constructor TAbstractBag<T>.Create(const AArray: TFixedArray<T>);
begin
  { Call upper constructor }
  Create(TType<T>.Default, AArray);
end;

constructor TAbstractBag<T>.Create(const AArray: TDynamicArray<T>);
begin
  { Call upper constructor }
  Create(TType<T>.Default, AArray);
end;

constructor TAbstractBag<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>);
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

constructor TAbstractBag<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>);
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

constructor TAbstractBag<T>.Create();
begin
  { Call upper constructor }
  Create(TType<T>.Default);
end;

constructor TAbstractBag<T>.Create(const ACollection: IEnumerable<T>);
begin
  { Call upper constructor }
  Create(TType<T>.Default, ACollection);
end;

constructor TAbstractBag<T>.Create(const AType: IType<T>; const ACollection: IEnumerable<T>);
var
  V: T;
begin
  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Call upper constructor }
  Create(AType);

  { Iterate and add }
  for V in ACollection do
    Add(V);
end;

constructor TAbstractBag<T>.Create(const AType: IType<T>; const AArray: array of T);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType);

  { Copy all items in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;

constructor TAbstractBag<T>.Create(const AType: IType<T>);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  InstallType(AType);
  FDictionary := CreateDictionary(ElementType);

  FVer := 0;
  FKnownCount := 0;
end;

constructor TAbstractBag<T>.Create(const AArray: array of T);
begin
  { Call upper constructor }
  Create(TType<T>.Default, AArray);
end;

destructor TAbstractBag<T>.Destroy;
begin
  { Clear the bag first }
  Clear();

  inherited;
end;

function TAbstractBag<T>.Empty: Boolean;
begin
  Result := (FKnownCount = 0);
end;

function TAbstractBag<T>.First: T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.First();
end;

function TAbstractBag<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.FirstOrDefault(ADefault);
end;

function TAbstractBag<T>.Last: T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.Last();
end;

function TAbstractBag<T>.LastOrDefault(const ADefault: T): T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.LastOrDefault(ADefault);
end;

function TAbstractBag<T>.Max: T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.Max();
end;

function TAbstractBag<T>.Min: T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.Min();
end;

function TAbstractBag<T>.GetCount: NativeUInt;
begin
  { Dictionary knows the real count }
  Result := FKnownCount;
end;

function TAbstractBag<T>.GetWeight(const AValue: T): NativeUInt;
begin
  { Get the count }
  if not FDictionary.TryGetValue(AValue, Result) then
     Result := 0;
end;

function TAbstractBag<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

procedure TAbstractBag<T>.Remove(const AValue: T; const AWeight: NativeUInt);
var
  OldCount: NativeUInt;
begin
  { Check count > 0 }
  if AWeight = 0 then
    Exit;

  { Check that the key os present in the dictionary first }
  if not FDictionary.TryGetValue(AValue, OldCount) then
    Exit;

  if OldCount < AWeight then
    OldCount := 0
  else
    OldCount := OldCount - AWeight;

  { Update the counts }
  if OldCount = 0 then
    FDictionary.Remove(AValue)
  else
    FDictionary[AValue] := OldCount;

  Dec(FKnownCount, AWeight);
  Inc(FVer);
end;

procedure TAbstractBag<T>.RemoveAll(const AValue: T);
var
  OldCount: NativeUInt;
begin
  { Check that the key is present in the dictionary first }
  if not FDictionary.TryGetValue(AValue, OldCount) then
    Exit;

  FDictionary.Remove(AValue);

  Dec(FKnownCount, OldCount);
  Inc(FVer);
end;

procedure TAbstractBag<T>.SetWeight(const AValue: T; const AWeight: NativeUInt);
var
  OldValue: NativeUInt;
begin
  { Check count > 0 }
  if Count = 0 then
    Exit;

  if FDictionary.ContainsKey(AValue) then
  begin
    OldValue := FDictionary[AValue];
    FDictionary[AValue] := AWeight;
  end else
  begin
    OldValue := 0;
    FDictionary.Add(AValue, AWeight);
  end;

  { Change the counts }
  FKnownCount := FKnownCount - OldValue + AWeight;
  Inc(FVer);
end;

function TAbstractBag<T>.Single: T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.Single();
end;

function TAbstractBag<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Use TDictionary's Keys }
  Result := FDictionary.Keys.SingleOrDefault(ADefault);
end;

{ TAbstractBag<T>.TEnumerator }

constructor TAbstractBag<T>.TEnumerator.Create(const ADict: TAbstractBag<T>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FCurrentKV := FDict.FDictionary.GetEnumerator();

  FCurrentCount := 0;
  FValue := Default(T);

  FVer := ADict.FVer;
end;

destructor TAbstractBag<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FDict);

  inherited;
end;

function TAbstractBag<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TAbstractBag<T>.TEnumerator.MoveNext: Boolean;
begin
  { Repeat until something happens }
  while True do
  begin
    if FVer <> FDict.FVer then
       ExceptionHelper.Throw_CollectionChangedError();

    { We're still in the same KV? }
    if FCurrentCount <> 0 then
    begin
      { Decrease the count of the bag item }
      Dec(FCurrentCount);
      Result := true;

      Exit;
    end;

    { Get the next KV pair from the dictionary }
    Result := FCurrentKV.MoveNext();
    if not Result then
      Exit;

    { Copy the key/value }
    FCurrentCount := FCurrentKV.Current.Value;
    FValue := FCurrentKV.Current.Key;
  end;
end;


end.
