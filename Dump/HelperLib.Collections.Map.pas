(*
* Copyright (c) 2008, Susnea Andrei
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
* THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

unit HelperLib.Collections.Map;
interface
uses SysUtils,
     HelperLib.Base,
     HelperLib.TypeSupport,
     HelperLib.Collections.Utils,
     HelperLib.Collections.KeyValuePair,
     HelperLib.Collections.Interfaces,
     HelperLib.Collections.Exceptions;

type
  {Generic Map}
  HMap<TKey, TValue> = class(HRefCountedObject, ICollection<HKeyValuePair<TKey, TValue>>, IEnumerable<HKeyValuePair<TKey, TValue>>)
  private
  type
    { Map specific KV Pair }
    HMapKeyValuePair = class
    private
      FKey    : TKey;
      FValue  : TValue;
      FParent : HMapKeyValuePair;
      FLeft   : HMapKeyValuePair;
      FRight  : HMapKeyValuePair;
      FMap    : HMap<TKey, TValue>;
      FShouldDelete : boolean;

    public
      { Constructors }
      constructor Create(const AKey : TKey; const AValue : TValue); overload;
      constructor Create(const APair : HMapKeyValuePair); overload;

      { Destructor }
      destructor Destroy(); override;

      { Assign value of another pair }
      procedure Assign(const APair : HMapKeyValuePair);

      { Properties }
      property Key   : TKey read FKey;
      property Value : TValue read FValue;
      property Left  : HMapKeyValuePair read FLeft;
      property Right : HMapKeyValuePair read FRight;
    end;

  var
    FComp     : ITypeSupport<TKey>;
    FVer      : Cardinal;
    FCount    : Cardinal;
    FRoot     : HMapKeyValuePair;
    FCurrentPosition : integer;
    FFound    : boolean;

    function GetElementAt(Index: Cardinal): HKeyValuePair<TKey, TValue>;

    function FindPair(const AKey : TKey; const RaiseError : Boolean = true) : HMapKeyValuePair;
    procedure RecDelete(const APair : HMapKeyValuePair);
    procedure CopyTraverseTree(var APair : HMapKeyValuePair; var AArray : array of HKeyValuePair<TKey,TValue>; AHead : Cardinal);
    procedure DeleteAndBalance(var APair : HMapKeyValuePair);
    function FindInorderAncestor( APair : HMapKeyValuePair ) : HMapKeyValuePair;
    function TraverseTreeUpToPosition( APair : HMapKeyValuePair; DesiredPosition : Cardinal) : HMapKeyValuePair;
    procedure Remove(const APair: HMapKeyValuePair); overload;

  protected
    { ICollection support }

    function GetCount() : Cardinal;
    procedure Add(const AValue : HKeyValuePair<TKey, TValue>);

  public
    { Constructors }
    constructor Create(); overload;
    constructor Create(const AEnumerable : IEnumerable<HKeyValuePair<TKey, TValue>>); overload;

    constructor Create(const ASupport : ITypeSupport<TKey>); overload;
    constructor Create(const ASupport : ITypeSupport<TKey>; const AEnumerable : IEnumerable<HKeyValuePair<TKey, TValue>>); overload;

    { Modifying }
    procedure Clear();
    procedure Insert(const AKey : TKey; const AValue : TValue); overload;
    procedure Insert(const APair : HKeyValuePair<TKey, TValue>); overload;

    procedure Remove(const AKey : TKey); overload;

    { Finding }
    function Contains(const AKey : TKey) : Boolean;
    function Find(const AKey : TKey) : TValue;

    { Properties }
    property Count : Cardinal read FCount;
    property Items[Index : Cardinal] : HKeyValuePair<TKey, TValue> read GetElementAt; default;

    { ICollection/IEnumerable Support  }
    procedure CopyTo(var AArray : array of HKeyValuePair<TKey, TValue>); overload;
    procedure CopyTo(var AArray : array of HKeyValuePair<TKey, TValue>; const StartIndex : Cardinal); overload;

    function GetEnumerator() : IEnumerator<HKeyValuePair<TKey, TValue>>;
  end;

  HMapEnumerator<TKey, TValue> = class(HRefCountedObject, IEnumerator<HKeyValuePair<TKey, TValue>>)
  private
    FVer          : Cardinal;
    FMap          : HMap<TKey, TValue>;
    FCurrentIdx   : Integer;

  public
    { Constructor }
    constructor Create(const AMap : HMap<TKey, TValue>);

    { Destructor }
    destructor Destroy(); override;

    function GetCurrent() : HKeyValuePair<TKey, TValue>;
    function MoveNext() : Boolean;

    property Current : HKeyValuePair<TKey, TValue> read GetCurrent;
  end;
implementation

{ HMapKeyValuePair<TKey, TValue> }

constructor HMap<TKey, TValue>.HMapKeyValuePair.Create(const AKey: TKey;
  const AValue: TValue);
begin
  FKey    := AKey;
  FValue  := AValue;

  FLeft   := nil;
  FRight  := nil;
  FMap    := nil;
  FParent := nil;
  FShouldDelete := true;
end;

constructor HMap<TKey, TValue>.HMapKeyValuePair.Create(
  const APair: HMapKeyValuePair);
begin
  FKey    := APair.Key;
  FValue  := APair.Value;

  FLeft   := nil;
  FRight  := nil;
  FMap    := nil;
  FParent := nil;
  FShouldDelete := true;
end;

procedure HMap<TKey, TValue>.HMapKeyValuePair.Assign(
  const APair: HMapKeyValuePair);
begin
  FKey := APair.FKey;
  FValue := APair.FValue;
end;

destructor HMap<TKey, TValue>.HMapKeyValuePair.Destroy;
begin
  //this happens incase we want to destroy an item
  //not connected to any Map.
  if FMap <> nil then
    Dec(FMap.FCount);
  inherited;
end;

{ HMap<TKey, TValue> }

procedure HMap<TKey, TValue>.Add(const AValue: HKeyValuePair<TKey, TValue>);
begin
  { Pass to normal function }
  Insert(AValue);
end;

procedure HMap<TKey, TValue>.Clear;
begin
  { Invoke recursive delete }
  RecDelete(FRoot);
  FRoot := nil;
  FCount :=0;
  Inc(FVer);
end;

function HMap<TKey, TValue>.Contains(const AKey: TKey): Boolean;
begin
  { Simply check }
  Result := (FindPair(AKey, false) <> nil);
end;

procedure HMap<TKey, TValue>.CopyTo(
  var AArray: array of HKeyValuePair<TKey, TValue>);
begin
  CopyTo(AArray, 0);
end;

procedure HMap<TKey, TValue>.CopyTo(
  var AArray: array of HKeyValuePair<TKey, TValue>;
  const StartIndex: Cardinal);
begin
  { Check for indexes }
  if Range.OutOfBounds(Length(AArray), StartIndex, Count) then
     raise EArgumentOutOfRangeException.Create('Insuficient space in AArray!');

  CopyTraverseTree(FRoot, AArray, StartIndex);
end;

procedure HMap<TKey, TValue>.CopyTraverseTree(
  var APair: HMapKeyValuePair; var AArray : array of HKeyValuePair<TKey,TValue>; AHead : Cardinal);
begin
  if APair = nil then
  Exit();

  AArray[AHead] := HKeyValuePair<TKey, TValue>.Create(APair.FKey, APair.FValue);

  if APair.FLeft <> nil then
    AHead := AHead + 1;
    APair.FMap.CopyTraverseTree(APair.FLeft, AArray, AHead);

  if APair.FRight <> nil then
    AHead := AHead + 1;
    APair.FMap.CopyTraverseTree(APair.FRight, AArray, AHead);

end;

constructor HMap<TKey, TValue>.Create(const ASupport: ITypeSupport<TKey>;
  const AEnumerable: IEnumerable<HKeyValuePair<TKey, TValue>>);
var
  V : HKeyValuePair<TKey, TValue>;
begin
  { Initialize instance }
  if (ASupport = nil) then
     raise EArgumentException.Create('ASupport parameter is nil');

  { Initialize instance }
  if (AEnumerable = nil) then
     raise EArgumentException.Create('AEnumerable parameter is nil');

  FComp  := ASupport;
  FRoot  := nil;
  FVer   := 0;
  FCount := 0;
  FCurrentPosition := 0;
  FFound := false;

  { Try to copy the given Enumerable }
  for V in AEnumerable do
  begin
    { Perform a simple push }
    Insert(V.Key, V.Value);
  end;
end;

constructor HMap<TKey, TValue>.Create;
begin
  Create(HTypeSupport<TKey>.Default);
end;

constructor HMap<TKey, TValue>.Create(
  const AEnumerable: IEnumerable<HKeyValuePair<TKey, TValue>>);
begin
  FCurrentPosition := 0;
  FFound := false;
  Create(HTypeSupport<TKey>.Default, AEnumerable);
end;

procedure HMap<TKey, TValue>.DeleteAndBalance(var APair: HMapKeyValuePair);
var
  temp : HMapKeyValuePair;
  parent : HMapKeyValuePair;
begin

  if (APair.FLeft = nil) and (APair.FRight = nil) then
    if FRoot = APair then
      begin
        FRoot := nil;
        Exit();
      end
    else if APair.FParent.FLeft = APair then
          begin
         APair.FParent.FLeft := nil;
         Exit();
          end
         else begin
         APair.FParent.FRight := nil;
         Exit();
         end;


  if APair.FLeft = nil then
  begin
    temp := APair;
    //APair := APair.FRight;
    if APair.FParent = nil then
      begin
        FRoot := APair.FRight;
        APair.FParent := nil;
        Exit();
      end;

    if APair.FParent.FRight = APair then
      APair.FParent.FRight := APair.FRight
      else
      APair.FParent.FLeft := APair.FLeft;
  end
  else if APair.FRight = nil then
  begin
    temp := APair;
    //APair := APair.FLeft;
    if APair.FParent = nil then
      begin
        FRoot := APair.FLeft;
        Exit();
      end;
    if APair.FParent.FRight = APair then
      APair.FParent.FRight := APair.FRight
      else
      APair.FParent.FLeft := APair.FLeft;
  end else
    begin
      temp:= APair.FMap.FindInorderAncestor(APair);
      APair.Assign(temp);
      APair.FShouldDelete := false;

      Remove(temp);
    end;

end;

constructor HMap<TKey, TValue>.Create(const ASupport: ITypeSupport<TKey>);
begin
  { Initialize instance }
  if (ASupport = nil) then
     raise EArgumentException.Create('ASupport parameter is nil');

  FComp  := ASupport;
  FRoot  := nil;
  FVer   := 0;
  FCount := 0;
  FCurrentPosition := 0;
  FFound := false;
end;

function HMap<TKey, TValue>.Find(const AKey: TKey): TValue;
var
  Pair : HMapKeyValuePair;
begin
  Pair := FindPair(AKey, false);

  if Pair = nil then
     raise EKeyNotFoundException.Create('Key defined by AKey not found in the collection.');

  Result := Pair.Value;
end;

function HMap<TKey, TValue>.FindPair(
  const AKey: TKey; const RaiseError: Boolean): HMapKeyValuePair;
var
  hasSons : boolean;
  currentValue : HMapKeyValuePair;
begin
  hasSons := true;
  if FRoot = nil then
    begin
    Result := nil;
    Exit();
    end;
  currentValue := FRoot;

  while hasSons = true do
    begin
      hasSons := false;
      if FComp.AreEqual(currentValue.Key,AKey) then
        begin
          Result := currentValue;
          Exit();
        end;

      if ( currentValue.FLeft <> nil ) and (FComp.Compare(currentValue.Key,AKey) > 0) then
        begin
          currentValue := currentValue.FLeft;
          hasSons := true;
          Continue;
        end;

      if ( currentValue.FRight <> nil ) and (FComp.Compare(currentValue.Key,AKey) < 0) then
        begin
          currentValue := currentValue.FRight;
          hasSons := true;
          Continue;
        end;

      if RaiseError then
         raise EArgumentException.Create('Key not found! Tree is created wrong!!!!')
      else
         begin Result := nil; Exit; end;

    end;


end;

function HMap<TKey, TValue>.FindInorderAncestor(
  APair: HMapKeyValuePair): HMapKeyValuePair;
var
  currentNode : HMapKeyValuePair;
  hasSons : boolean;
begin
  currentNode := APair.FRight;
  Result := currentNode;
  hasSons := true;

  while hasSons = true do
  hasSons := false;
  begin
    if (FComp.Compare(Result.Key, currentNode.Key) < 0) and (FComp.Compare(currentNode.Key, APair.Key) > 0 )then
      Result := currentNode;
    if currentNode.FLeft <> nil then
      begin
      hasSons := true;
      currentNode := currentNode.FLeft;
      end;
  end;

end;

function HMap<TKey, TValue>.GetCount: Cardinal;
begin
  Result := FCount;
end;

function HMap<TKey, TValue>.GetElementAt(
  Index: Cardinal): HKeyValuePair<TKey, TValue>;
var
  Pair : HMapKeyValuePair;
begin
  FCurrentPosition := 0;
  FFound := false;
  if Index > FCount - 1 then
    raise EArgumentOutOfRangeException.Create('Index out of bounds');

  Pair := TraverseTreeUpToPosition(FRoot, Index);
  Result := HKeyValuePair<TKey, TValue>.Create(Pair.FKey, Pair.FValue);
end;

function HMap<TKey, TValue>.GetEnumerator: IEnumerator<HKeyValuePair<TKey, TValue>>;
begin
  Result := HMapEnumerator<TKey, TValue>.Create(Self);
end;

procedure HMap<TKey, TValue>.Insert(const AKey: TKey; const AValue: TValue);
begin
  Insert(HKeyValuePair<TKey,TValue>.Create(AKey, AValue));
end;

procedure HMap<TKey, TValue>.Insert(const APair: HKeyValuePair<TKey, TValue>);
var
  currentValue : HMapKeyValuePair;
  hasSons : boolean;
  ObjPair : HMapKeyValuePair;
begin

  if FRoot = nil then
     begin
     ObjPair := HMapKeyValuePair.Create(APair.Key, APair.Value);

     ObjPair.FMap := Self;
     FRoot := ObjPair;
     FCount := 1;

     Inc(FVer);
     Exit();
     end;

  currentValue := FRoot;

  hasSons := true;

//  while (currentValue.FLeft <> nil) and (currentValue.FRight <> nil) do
  while (hasSons = true) do
  begin
  hasSons := false;
  if FComp.AreEqual(APair.Key, currentValue.Key) then
     raise EDuplicateKeyException.Create('Key already found');

  if FComp.Compare(APair.Key,currentValue.Key) < 0 then
    begin
      if currentValue.FLeft = nil then
        begin
          ObjPair := HMapKeyValuePair.Create(APair.Key, APair.Value);
          ObjPair.FParent := currentValue;
          ObjPair.FMap := Self;
          FCount := FCount + 1;
          currentValue.FLeft := ObjPair;

          Inc(FVer);
          Exit();
        end
      else
        currentValue := currentValue.FLeft;
        hasSons := true;
    end;

  if FComp.Compare(APair.Key,currentValue.Key) > 0 then
    begin
      if currentValue.FRight = nil then
        begin
          ObjPair := HMapKeyValuePair.Create(APair.Key, APair.Value);
          ObjPair.FParent := currentValue;
          ObjPair.FMap := Self;
          FCount := FCount + 1;
          currentValue.FRight := ObjPair;

          Inc(FVer);
          Exit();
        end
      else
        currentValue := currentValue.FRight;
        hasSons := true;
    end;
  end;
end;

procedure HMap<TKey, TValue>.RecDelete(const APair: HMapKeyValuePair);
begin
  if APair = nil then
  Exit();

  if APair.FLeft <> nil then
  begin
     APair.FMap.RecDelete(APair.FLeft);
     APair.FLeft := nil;
  end;

  if APair.FRight <> nil then
  begin
     APair.FMap.RecDelete(APair.FRight);
     APair.FRight := nil;
  end;

  APair.Free;
end;

procedure HMap<TKey, TValue>.Remove(const AKey: TKey);
var
  Pair : HMapKeyValuePair;
begin
  Pair := FindPair(AKey, false);

  if Pair = nil then
     raise EKeyNotFoundException.Create('Key defined by AKey not found in the collection.');

  Self.Remove(Pair);
end;

function HMap<TKey, TValue>.TraverseTreeUpToPosition(
  APair: HMapKeyValuePair; DesiredPosition: Cardinal): HMapKeyValuePair;
begin
  if APair = nil then
  Exit();

  if FCurrentPosition = DesiredPosition then
    begin
      Result := APair;
      FFound := true;
      Exit();
    end;


  if APair.FLeft <> nil then
  begin
    if FFound = true then
      Exit();
    FCurrentPosition := FCurrentPosition + 1;
    Result := APair.FMap.TraverseTreeUpToPosition(APair.FLeft, DesiredPosition);
  end;

  if APair.FRight <> nil then
  begin
    if FFound = true then
      Exit();
     FCurrentPosition := FCurrentPosition + 1;
     Result := APair.FMap.TraverseTreeUpToPosition(APair.FRight, DesiredPosition);
  end;
end;

procedure HMap<TKey, TValue>.Remove(
  const APair: HMapKeyValuePair);
var
 Temp : HMapKeyValuePair;
begin
  if APair.FMap <> Self then
     raise EArgumentException.Create('APair is not a part of this map.');

  Temp := APair;
  DeleteAndBalance(Temp);
  Inc(FVer);

  { Simply invoke destructor}
 if APair.FShouldDelete = true then
    APair.Free();

 APair.FShouldDelete := true;
end;

{ HMapEnumerator<TKey, TValue> }

constructor HMapEnumerator<TKey, TValue>.Create(const AMap: HMap<TKey, TValue>);
begin
  FVer := AMap.FVer;
  FMap := AMap;
  FCurrentIdx := -1;
end;

destructor HMapEnumerator<TKey, TValue>.Destroy;
begin
  { Nothing }
  inherited;
end;

function HMapEnumerator<TKey, TValue>.GetCurrent: HKeyValuePair<TKey, TValue>;
begin
  if FVer <> FMap.FVer then
     raise ECollectionChanged.Create('Parent collection has changed!');

  if FCurrentIdx > -1 then
     Result := FMap[FCurrentIdx];
end;

function HMapEnumerator<TKey, TValue>.MoveNext: Boolean;
begin
  if FVer <> FMap.FVer then
     raise ECollectionChanged.Create('Parent collection has changed!');

  Inc(FCurrentIdx);
  Result := (FCurrentIdx < FMap.Count);
end;

end.
