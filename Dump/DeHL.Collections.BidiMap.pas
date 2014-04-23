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

{$I ../defines.inc}
unit DeHL.Collections.BidiMap;
interface
uses
  SysUtils,
  DeHL.Base,
  DeHL.Exceptions,
  DeHL.Types,
  DeHL.Arrays,
  DeHl.KeyValuePair,
  DeHL.Collections.Base,
  DeHL.Collections.DistinctMultiMap;

type
  { Class that represents the bidirectional map }
  TBidiMap<TKey, TValue> = class(TEnexAssociativeCollection<TKey, TValue>)
  private type
    { References to the Key and Value types }
    TKeyRef = ^TKey;
    TValueRef = ^TValue;

    { Type class that uses referenced keys }
    TKeyRefType = class(TType<TKeyRef>)
    private
      FSelf: TBidiMap<TKey, TValue>;

    public
      function Compare(const AValue1, AValue2: TKeyRef): Integer; override;
      function AreEqual(const AValue1, AValue2: TKeyRef): Boolean; override;
      function GenerateHashCode(const AValue: TKeyRef): Integer; override;
      function GetString(const AValue: TKeyRef): String; override;
      function Management(): TTypeManagement; override;
    end;

    { Type class that uses referenced values }
    TValueRefType = class(TType<TValueRef>)
    private
      FSelf: TBidiMap<TKey, TValue>;

    public
      function Compare(const AValue1, AValue2: TValueRef): Integer; override;
      function AreEqual(const AValue1, AValue2: TValueRef): Boolean; override;
      function GenerateHashCode(const AValue: TValueRef): Integer; override;
      function GetString(const AValue: TValueRef): String; override;
      function Management(): TTypeManagement; override;
    end;

  private
    FByKeyMap: TDistinctMultiMap<TKeyRef, TValueRef>;
    FByValueMap: TDistinctMultiMap<TValueRef, TKeyRef>;
    FVer: Cardinal;
    FAllCount: Cardinal;

    { Getters for the keys and values }
    function GetKeyList(const AValue: TValue): IEnexCollection<TKey>;
    function GetValueList(const AKey: TKey): IEnexCollection<TValue>;

    { Actually performs the heavy-lifting }
    procedure InsertPair(const AKey: TKey; const AValue: TValue);

    { Cool internal routines }
    procedure FreeKeySpot(const AKey: TKey; const Cleanup: Boolean);
    procedure FreeValueSpot(const AValue: TValue; const Cleanup: Boolean);

    function FillKeySpot(const AKey: TKey): TKeyRef;
    function FillValueSpot(const AValue: TValue): TValueRef;
  public
    { Constructors }
    constructor Create(); overload;
    constructor Create(const AEnumerable: IEnumerable<TKeyValuePair<TKey,TValue>>); overload;
    constructor Create(const AArray: array of TKeyValuePair<TKey,TValue>); overload;
    constructor Create(const AArray: TDynamicArray<TKeyValuePair<TKey, TValue>>); overload;
    constructor Create(const AArray: TFixedArray<TKeyValuePair<TKey, TValue>>); overload;

    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AEnumerable: IEnumerable<TKeyValuePair<TKey,TValue>>); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: array of TKeyValuePair<TKey,TValue>); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TDynamicArray<TKeyValuePair<TKey,TValue>>); overload;
    constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
          const AArray: TFixedArray<TKeyValuePair<TKey,TValue>>); overload;

    { Destructor }
    destructor Destroy(); override;

    { Clearing }
    procedure Clear();

    { Adding }
    procedure Add(const APair: TKeyValuePair<TKey, TValue>); overload;
    procedure Add(const AKey: TKey; const AValue: TValue); overload;

    { Removal }
    procedure RemoveKey(const AKey: TKey);
    procedure RemoveValue(const AValue: TValue);

    procedure Remove(const AKey: TKey; const AValue: TValue); overload;
    procedure Remove(const APair: TKeyValuePair<TKey, TValue>); overload;

    { Lookup }
    function ContainsKey(const AKey: TKey): Boolean;
    function ContainsValue(const AValue: TValue): Boolean;

    function ContainsPair(const AKey: TKey; const AValue: TValue): Boolean; overload;
    function ContainsPair(const APair: TKeyValuePair<TKey, TValue>): Boolean; overload;

    { Properties }
    property Values[const AKey: TKey]: IEnexCollection<TValue> read GetValueList;
    property Keys[const AValue: TValue]: IEnexCollection<TKey> read GetKeyList;
    property Count: Cardinal read FAllCount;
  end;


implementation

{ TBidiMap<TKey, TValue>.TKeyRefType }

function TBidiMap<TKey, TValue>.TKeyRefType.AreEqual(const AValue1, AValue2: TKeyRef): Boolean;
begin
  Result := FSelf.KeyType.AreEqual(AValue1^, AValue2^);
end;

function TBidiMap<TKey, TValue>.TKeyRefType.Compare(const AValue1, AValue2: TKeyRef): Integer;
begin
  Result := FSelf.KeyType.Compare(AValue1^, AValue2^);
end;

function TBidiMap<TKey, TValue>.TKeyRefType.GenerateHashCode(const AValue: TKeyRef): Integer;
begin
  Result := FSelf.KeyType.GenerateHashCode(AValue^);
end;

function TBidiMap<TKey, TValue>.TKeyRefType.GetString(const AValue: TKeyRef): String;
begin
  Result := FSelf.KeyType.GetString(AValue^);
end;

function TBidiMap<TKey, TValue>.TKeyRefType.Management: TTypeManagement;
begin
  Result := tmNone;
end;

{ TBidiMap<TKey, TValue>.TValueRefType }

function TBidiMap<TKey, TValue>.TValueRefType.AreEqual(const AValue1, AValue2: TValueRef): Boolean;
begin
  Result := FSelf.ValueType.AreEqual(AValue1^, AValue2^);
end;

function TBidiMap<TKey, TValue>.TValueRefType.Compare(const AValue1, AValue2: TValueRef): Integer;
begin
  Result := FSelf.ValueType.Compare(AValue1^, AValue2^);
end;

function TBidiMap<TKey, TValue>.TValueRefType.GenerateHashCode(const AValue: TValueRef): Integer;
begin
  Result := FSelf.ValueType.GenerateHashCode(AValue^);
end;

function TBidiMap<TKey, TValue>.TValueRefType.GetString(const AValue: TValueRef): String;
begin
  Result := FSelf.ValueType.GetString(AValue^);
end;

function TBidiMap<TKey, TValue>.TValueRefType.Management: TTypeManagement;
begin
  Result := tmNone;
end;

{ TBidiMap<TKey, TValue> }

constructor TBidiMap<TKey, TValue>.Create(const AArray: TDynamicArray<TKeyValuePair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TBidiMap<TKey, TValue>.Create(const AArray: TFixedArray<TKeyValuePair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TBidiMap<TKey, TValue>.Create(const AArray: array of TKeyValuePair<TKey, TValue>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AArray);
end;

constructor TBidiMap<TKey, TValue>.Create;
begin
  Create(TType<TKey>.Default, TType<TValue>.Default);
end;

constructor TBidiMap<TKey, TValue>.Create(const AEnumerable: IEnumerable<TKeyValuePair<TKey, TValue>>);
begin
  Create(TType<TKey>.Default, TType<TValue>.Default, AEnumerable);
end;

constructor TBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TDynamicArray<TKeyValuePair<TKey, TValue>>);
var
  I: Cardinal;
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

procedure TBidiMap<TKey, TValue>.Add(const AKey: TKey; const AValue: TValue);
var
  LKeyRef: TKeyRef;
  LValueRef: TValueRef;
begin
  if FByKeyMap.ContainsKey(@AKey) then


end;

procedure TBidiMap<TKey, TValue>.Add(const APair: TKeyValuePair<TKey, TValue>);
begin
  { Call the insertion module }
  InsertPair(APair.Key, APair.Value);
end;

procedure TBidiMap<TKey, TValue>.Clear;
begin
  if FByKeyMap <> nil then
    FByKeyMap.Clear;

  if FByValueMap <> nil then
    FByValueMap.Clear;

  Inc(FVer);
  FAllCount := 0;
end;

function TBidiMap<TKey, TValue>.ContainsKey(const AKey: TKey): Boolean;
begin

end;

function TBidiMap<TKey, TValue>.ContainsPair(
  const APair: TKeyValuePair<TKey, TValue>): Boolean;
begin

end;

function TBidiMap<TKey, TValue>.ContainsPair(const AKey: TKey;
  const AValue: TValue): Boolean;
begin

end;

function TBidiMap<TKey, TValue>.ContainsValue(const AValue: TValue): Boolean;
begin

end;

constructor TBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: TFixedArray<TKeyValuePair<TKey, TValue>>);
var
  I: Cardinal;
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

destructor TBidiMap<TKey, TValue>.Destroy;
begin
  { Clear out the instance }
  Clear();

  { Free the map instances }
  FByKeyMap.Free;
  FByValueMap.Free;

  inherited;
end;

function TBidiMap<TKey, TValue>.FillKeySpot(const AKey: TKey): TKeyRef;
begin

end;

function TBidiMap<TKey, TValue>.FillValueSpot(const AValue: TValue): TValueRef;
begin

end;

procedure TBidiMap<TKey, TValue>.FreeKeySpot(const AKey: TKey; const Cleanup: Boolean);
begin

end;

procedure TBidiMap<TKey, TValue>.FreeValueSpot(const AValue: TValue; const Cleanup: Boolean);
begin

end;

function TBidiMap<TKey, TValue>.GetKeyList(const AValue: TValue): IEnexCollection<TKey>;
begin

end;

function TBidiMap<TKey, TValue>.GetValueList(const AKey: TKey): IEnexCollection<TValue>;
begin

end;

procedure TBidiMap<TKey, TValue>.InsertPair(const AKey: TKey; const AValue: TValue);
begin

end;

procedure TBidiMap<TKey, TValue>.Remove(const AKey: TKey; const AValue: TValue);
begin

end;

procedure TBidiMap<TKey, TValue>.Remove(const APair: TKeyValuePair<TKey, TValue>);
begin

end;

procedure TBidiMap<TKey, TValue>.RemoveKey(const AKey: TKey);
var
  LValues: IEnexCollection<TValueRef>;
  LValue: TValueRef;
begin
  { Check whether there is such a key }
  if not FByKeyMap.ContainsKey(@AKey) then
    ExceptionHelper.Throw_KeyNotFoundError('AKey');

  { Find the values that are related to the key }
  LValues := FByKeyMap[@AKey];

  { Exclude the key for all values too}
  for LValue in LValues do
    FByValueMap.Remove(TValueRef(LValue), TKeyRef(@AKey));

  { And finally remove the key }
  FByKeyMap.Remove(TKeyRef(@AKey));

  { And free the spot of the key }
  FreeKeySpot(AKey, false);
end;

procedure TBidiMap<TKey, TValue>.RemoveValue(const AValue: TValue);
var
  LValues: IEnexCollection<TKeyRef>;
  LValue: TKeyRef;
begin
  { Check whether there is such a key }
  if not FByKeyMap.ContainsKey(@AValue) then
    ExceptionHelper.Throw_KeyNotFoundError('AValue');

  { Find the values that are related to the key }
  LValues := FByValueMap[@AValue];

  { Exclude the key for all values too}
  for LValue in LValues do
    FByKeyMap.Remove(TKeyRef(LValue), TValueRef(@AValue));

  { And finally remove the key }
  FByValueMap.Remove(TValueRef(@AValue));

  { And free the spot of the key }
  FreeValueSpot(AValue, false);
end;

constructor TBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AArray: array of TKeyValuePair<TKey, TValue>);
var
  I: Integer;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  { Copy all items in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;

constructor TBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
var
  LKeyType: TKeyRefType;
  LValueType: TValueRefType;
begin
  { Initialize instance }
  if (AKeyType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AKeyType');

  if (AValueType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AValueType');

  { Install the types }
  InstallTypes(AKeyType, AValueType);

  { Create the intermediary types }
  LKeyType := TKeyRefType.Create();
  LKeyType.FSelf := Self;

  LValueType := TValueRefType.Create();
  LValueType.FSelf := Self;

  { Create the maps }
  FByKeyMap := TDistinctMultiMap<TKeyRef, TValueRef>.Create(LKeyType, LValueType);
  FByValueMap := TDistinctMultiMap<TValueRef, TKeyRef>.Create(LValueType, LKeyType);

  { And initialize the internals }
  FAllCount := 0;
  FVer := 0;
end;

constructor TBidiMap<TKey, TValue>.Create(const AKeyType: IType<TKey>;
  const AValueType: IType<TValue>;
  const AEnumerable: IEnumerable<TKeyValuePair<TKey, TValue>>);
var
  V: TKeyValuePair<TKey, TValue>;
begin
  { Call upper constructor }
  Create(AKeyType, AValueType);

  if (AEnumerable = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  { Pump in all items }
  for V in AEnumerable do
  begin
{$IFNDEF BUG_GENERIC_INCOMPAT_TYPES}
    Add(V);
{$ELSE}
    Add(V.Key, V.Value);
{$ENDIF}
  end;
end;

end.
