(*
* Copyright (c) 2009, Ciobanu Alexandru
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
unit DeHL.Collections.SortedDistinctMultiMap;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.StrConsts,
     DeHL.Exceptions,
     DeHL.Tuples,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Collections.Base,
     DeHL.Collections.Abstract,
     DeHL.Collections.HashSet,
     DeHL.Collections.SortedDictionary;

type
  { Multi-Map based on a sorted dictionary and a list }
  TSortedDistinctMultiMap<TKey, TValue> = class(TAbstractDistinctMultiMap<TKey, TValue>)
  private
    FAscSort: Boolean;

  protected
    { Provide our implementations }
    function CreateDictionary(const AKeyType: IType<TKey>): IDictionary<TKey, ISet<TValue>>; override;
    function CreateSet(const AValueType: IType<TValue>): ISet<TValue>; override;

    { Serialization overrides }
    procedure StartSerializing(const AData: TSerializationData); override;
    procedure StartDeserializing(const AData: TDeserializationData); override;
    procedure DeserializePair(const AKey: TKey; const AValue: TValue); override;
  public
    { Constructors }
    constructor Create(const Ascending: Boolean = true); overload;
    constructor Create(const AEnumerable: IEnumerable<KVPair<TKey,TValue>>; const Ascending: Boolean = true); overload;
    constructor Create(const AArray: array of KVPair<TKey,TValue>; const Ascending: Boolean = true); overload;
    constructor Create(const AArray: TDynamicArray<KVPair<TKey, TValue>>; const Ascending: Boolean = true); overload;
    constructor Create(const AArray: TFixedArray<KVPair<TKey, TValue>>; const Ascending: Boolean = true); overload;

    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>; const Ascending: Boolean = true); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AEnumerable : IEnumerable<KVPair<TKey,TValue>>; const Ascending: Boolean = true); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray : array of KVPair<TKey,TValue>; const Ascending: Boolean = true); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray : TDynamicArray<KVPair<TKey,TValue>>; const Ascending: Boolean = true); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray : TFixedArray<KVPair<TKey,TValue>>; const Ascending: Boolean = true); overload;

    { Enex - Associative collection }
    function MaxKey(): TKey; override;
    function MinKey(): TKey; override;
  end;

  { The object variant }
  TObjectSortedDistinctMultiMap<TKey, TValue> = class(TSortedDistinctMultiMap<TKey, TValue>)
  private
    FKeyWrapperType: TMaybeObjectWrapperType<TKey>;
    FValueWrapperType: TMaybeObjectWrapperType<TValue>;

    { Getters/Setters for OwnsKeys }
    function GetOwnsKeys: Boolean;
    procedure SetOwnsKeys(const Value: Boolean);

    { Getters/Setters for OwnsValues }
    function GetOwnsValues: Boolean;
    procedure SetOwnsValues(const Value: Boolean);

  protected
    { Override in descendants to Type proper stuff }
    procedure InstallTypes(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); override;

  public

    { Object owning }
    property OwnsKeys: Boolean read GetOwnsKeys write SetOwnsKeys;
    property OwnsValues: Boolean read GetOwnsValues write SetOwnsValues;
  end;

implementation

{ TSortedDistinctMultiMap<TKey, TValue> }

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(
  const AArray: TDynamicArray<KVPair<TKey, TValue>>;
  const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AArray);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(
  const AArray: TFixedArray<KVPair<TKey, TValue>>;
  const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AArray);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(
  const AArray: array of KVPair<TKey, TValue>; const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AArray);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create();
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AEnumerable);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TDynamicArray<KVPair<TKey, TValue>>;
  const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AKeyType, AValueType, AArray);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TFixedArray<KVPair<TKey, TValue>>;
  const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AKeyType, AValueType, AArray);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: array of KVPair<TKey, TValue>; const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AKeyType, AValueType, AArray);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>; const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AKeyType, AValueType);
end;

constructor TSortedDistinctMultiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>;
  const Ascending: Boolean);
begin
  { Do the dew and continue }
  FAscSort := Ascending;
  inherited Create(AKeyType, AValueType, AEnumerable);
end;

function TSortedDistinctMultiMap<TKey, TValue>.CreateDictionary(const AKeyType: IType<TKey>): IDictionary<TKey, ISet<TValue>>;
begin
  { Create a simple dictionary }
  Result := TSortedDictionary<TKey, ISet<TValue>>.Create(AKeyType, TType<ISet<TValue>>.Default, FAscSort);
end;

function TSortedDistinctMultiMap<TKey, TValue>.CreateSet(const AValueType: IType<TValue>): ISet<TValue>;
begin
  { Create a simple list }
  Result := THashSet<TValue>.Create(AValueType);
end;

procedure TSortedDistinctMultiMap<TKey, TValue>.DeserializePair(const AKey: TKey; const AValue: TValue);
begin
  { Very simple }
  Add(AKey, AValue);
end;

function TSortedDistinctMultiMap<TKey, TValue>.MaxKey: TKey;
begin
  Result := Dictionary.MaxKey;
end;

function TSortedDistinctMultiMap<TKey, TValue>.MinKey: TKey;
begin
  Result := Dictionary.MinKey;
end;

procedure TSortedDistinctMultiMap<TKey, TValue>.StartDeserializing(const AData: TDeserializationData);
var
  LAsc: Boolean;
begin
  { Try to obtain the ascending sign }
  AData.GetValue(SSerAscendingKeys, LAsc);

  { Call the constructor in this instance to initialize myself first }
  Create(LAsc);
end;

procedure TSortedDistinctMultiMap<TKey, TValue>.StartSerializing(const AData: TSerializationData);
begin
  { Write the ascending sign }
  AData.AddValue(SSerAscendingKeys, FAscSort);
end;

{ TObjectSortedDistinctMultiMap<TKey, TValue> }

procedure TObjectSortedDistinctMultiMap<TKey, TValue>.InstallTypes(const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
begin
  { Create a wrapper over the real type class and switch it }
  FKeyWrapperType := TMaybeObjectWrapperType<TKey>.Create(AKeyType);
  FValueWrapperType := TMaybeObjectWrapperType<TValue>.Create(AValueType);

  { Install overridden type }
  inherited InstallTypes(FKeyWrapperType, FValueWrapperType);
end;

function TObjectSortedDistinctMultiMap<TKey, TValue>.GetOwnsKeys: Boolean;
begin
  Result := FKeyWrapperType.AllowCleanup;
end;

function TObjectSortedDistinctMultiMap<TKey, TValue>.GetOwnsValues: Boolean;
begin
  Result := FValueWrapperType.AllowCleanup;
end;

procedure TObjectSortedDistinctMultiMap<TKey, TValue>.SetOwnsKeys(const Value: Boolean);
begin
  FKeyWrapperType.AllowCleanup := Value;
end;

procedure TObjectSortedDistinctMultiMap<TKey, TValue>.SetOwnsValues(const Value: Boolean);
begin
  FValueWrapperType.AllowCleanup := Value;
end;

end.
