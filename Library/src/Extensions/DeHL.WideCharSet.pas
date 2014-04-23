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

{$I ../DeHL.Defines.inc}
unit DeHL.WideCharSet;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Cloning,
     DeHL.Serialization,
     DeHL.Collections.Base;

type
  ///  <summary>A wide char set.</summary>
  ///  <remarks><see cref="DeHL.WideCharSet|TWideCharSet">DeHL.WideCharSet.TWideCharSet</see> is compatible to Delphi's
  ///  "set of AnsiChar". The essential difference is the fact that this type operates on wide characters instead
  ///  of ANSI characters.</remarks>
  TWideCharSet = record
  private const
    CCharSets = 256;

  private type
    { Array of pieces }
    TPieceArray = TArray<TSysCharSet>;

    { The enumerator object }
    TEnumerator = class(TEnumerator<Char>)
    private
      FPieces: TPieceArray;
      FCharId, FCharCount: NativeUInt;
      FChar: Char;
    public
      { Constructor }
      constructor Create(const APieces: TPieceArray);

      function GetCurrent(): Char; override;
      function MoveNext(): Boolean; override;
    end;

    TEnumerable = class(TEnexCollection<Char>)
    private
      FPieces: TPieceArray;

    public
      { The constructor }
      constructor Create(const APieces: TPieceArray);

      { IEnumerable<T> }
      function GetEnumerator(): IEnumerator<Char>; override;
    end;

  private
    [CloneKind(ckReference)]
    FPieces: TPieceArray;

    { Class stuff }
    class constructor Create;
    class destructor Destroy;

    { Sets or unsets a char in the array }
    procedure MarkChar(const AChar: Char; const AMark: Boolean); inline;
  public
    ///  <summary>Initializes a <see cref="DeHL.WideCharSet|TWideCharSet">DeHL.WideCharSet.TWideCharSet</see> value.</summary>
    ///  <param name="ACharSet">Another <see cref="DeHL.WideCharSet|TWideCharSet">DeHL.WideCharSet.TWideCharSet</see> value to copy.</param>
    constructor Create(const ACharSet: TWideCharSet); overload;

    ///  <summary>Initializes a <see cref="DeHL.WideCharSet|TWideCharSet">DeHL.WideCharSet.TWideCharSet</see> value.</summary>
    ///  <param name="ACharSet">An AnsiChar set.</param>
    constructor Create(const ACharSet: TSysCharSet); overload;

    ///  <summary>Initializes a <see cref="DeHL.WideCharSet|TWideCharSet">DeHL.WideCharSet.TWideCharSet</see> value.</summary>
    ///  <param name="AChar">A single char to be added to the set.</param>
    constructor Create(const AChar: Char); overload;

    ///  <summary>Initializes a <see cref="DeHL.WideCharSet|TWideCharSet">DeHL.WideCharSet.TWideCharSet</see> value.</summary>
    ///  <param name="AString">A string containing Wide characters. Each distinct character in the string
    ///  is added to the set.</param>
    constructor Create(const AString: String); overload;

    ///  <summary>Returns an enumerator.</summary>
    ///  <remarks>The traversal is performed from <c>0</c> to <c>65536</c> and only involves the characters that are in the set.</remarks>
    ///  <returns>An <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> that can traverse this set.</returns>
    function GetEnumerator(): IEnumerator<Char>;

    ///  <summary>Returns a collection object.</summary>
    ///  <remarks>A new collection is created each time this method is called.</remarks>
    ///  <returns>An <see cref="DeHL.Collections.Base|IEnexCollection&lt;T&gt;">DeHL.Collections.Base.IEnexCollection&lt;T&gt;</see>
    ///  operating on the characters in this set.</returns>
    function AsCollection(): IEnexCollection<Char>;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ALeft">Left-hand-side wide char set.</param>
    ///  <param name="ARight">Right-hand-side wide char set.</param>
    ///  <returns><c>True</c> if the sets contain the same elements; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft, ARight: TWideCharSet): Boolean;

    ///  <summary>Overloaded "<>" operator.</summary>
    ///  <param name="ALeft">Left-hand-side wide char set.</param>
    ///  <param name="ARight">Right-hand-side wide char set.</param>
    ///  <returns><c>False</c> if the sets contain the same elements; <c>True</c> otherwise.</returns>
    class operator NotEqual(const ALeft, ARight: TWideCharSet): Boolean; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">Left-hand-side wide char set.</param>
    ///  <param name="ARight">Right-hand-side wide char.</param>
    ///  <returns>A char set that contains the combined elements.</returns>
    class operator Add(const ALeft: TWideCharSet; const AChar: Char): TWideCharSet; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">Left-hand-side wide char set.</param>
    ///  <param name="ARight">Right-hand-side wide char set.</param>
    ///  <returns>A char set that contains the combined elements.</returns>
    class operator Add(const ALeft: TWideCharSet; const ARight: TWideCharSet): TWideCharSet;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ALeft">Left-hand-side wide char set.</param>
    ///  <param name="ARight">Right-hand-side wide char.</param>
    ///  <returns>A char set that contains the difference.</returns>
    class operator Subtract(const ALeft: TWideCharSet; AChar: Char): TWideCharSet; inline;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ALeft">Left-hand-side wide char set.</param>
    ///  <param name="ARight">Right-hand-side wide char set.</param>
    ///  <returns>A wide char set that contains the difference.</returns>
    class operator Subtract(const ALeft: TWideCharSet; ARight: TWideCharSet): TWideCharSet;

    ///  <summary>Overloaded "Include" operator.</summary>
    ///  <param name="ALeft">The wide char set in which to include.</param>
    ///  <param name="ARight">Character to include.</param>
    ///  <returns>A char set that contains combined elements.</returns>
    class operator Include(const ALeft: TWideCharSet; const AChar: Char): TWideCharSet; inline;

    ///  <summary>Overloaded "Include" operator.</summary>
    ///  <param name="ALeft">The wide char set in which to include.</param>
    ///  <param name="ARight">The string containing wide characters to include.</param>
    ///  <returns>A char set that contain combined elements.</returns>
    class operator Include(const ALeft: TWideCharSet; const AString: String): TWideCharSet; inline;

    ///  <summary>Overloaded "Include" operator.</summary>
    ///  <param name="ALeft">The wide char set in which to include.</param>
    ///  <param name="ARight">The wide char set to include.</param>
    ///  <returns>A char set that contain combined elements.</returns>
    class operator Include(const ALeft: TWideCharSet; const ASet: TWideCharSet): TWideCharSet; inline;

    ///  <summary>Overloaded "Exclude" operator.</summary>
    ///  <param name="ALeft">The wide char set from which to exclude.</param>
    ///  <param name="ARight">The character to exclude from the set.</param>
    ///  <returns>A char set that contains the difference.</returns>
    class operator Exclude(const ALeft: TWideCharSet; const AChar: Char): TWideCharSet; inline;

    ///  <summary>Overloaded "Exclude" operator.</summary>
    ///  <param name="ALeft">The wide char set from which to exclude.</param>
    ///  <param name="ARight">The string containing wide characters to exclude.</param>
    ///  <returns>A char set that contains the difference.</returns>
    class operator Exclude(const ALeft: TWideCharSet; const AString: String): TWideCharSet; inline;

    ///  <summary>Overloaded "Exclude" operator.</summary>
    ///  <param name="ALeft">The wide char set from which to exclude.</param>
    ///  <param name="ARight">The wide char set to exclude</param>
    ///  <returns>A char set that contains the difference.</returns>
    class operator Exclude(const ALeft: TWideCharSet; const ASet: TWideCharSet): TWideCharSet; inline;

    ///  <summary>Overloaded "In" operator.</summary>
    ///  <param name="AChar">The character to check for inclusion.</param>
    ///  <param name="ARight">The set to check against.</param>
    ///  <returns><c>True</c> is the specified character is found in the set.</returns>
    class operator In(const AChar: Char; const ARight: TWideCharSet): Boolean;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ARight">An ANSI char set.</param>
    ///  <returns>A wide char set containing the ANSI char set.</returns>
    class operator Implicit(const ARight: TSysCharSet): TWideCharSet; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ALeft">The char set.</param>
    ///  <returns>An ANSI char set containing only the wide characters that can be converted to ANSI characters.</returns>
    class operator Implicit(const ALeft: TWideCharSet): TSysCharSet; inline;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents
    ///  <see cref="DeHL.WideCharSet|TWideCharSet">DeHL.WideCharSet.TWideCharSet</see> type.</returns>
    class function GetType(): IType<TWideCharSet>; static;
  end;

  ///  <summary>Checks if a given character is part of the set.</summary>
  ///  <remarks>This function is provided for compatibility with the RTL, and is not recommented to be used.
  ///  Use the <see cref="DeHL.WideCharSet|TWideCharSet> "in" operator instead.
  ///  </remarks>
  ///  <param name="C">The character to be checked.</param>
  ///  <param name="CharSet">The char set to be tested against.</param>
  ///  <returns><c>True</c> if the set contains the character; <c>False</c> otherwise.</returns>
  function CharInSet(C: WideChar; const CharSet: TWideCharSet): Boolean; overload; inline;

implementation

type
  { WideChar set type support }
  TWideCharSetType = class sealed(TRecordType<TWideCharSet>)
  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TWideCharSet; const Acontext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TWideCharSet; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: TWideCharSet): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: TWideCharSet): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: TWideCharSet): String; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: TWideCharSet; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TWideCharSet): Boolean; override;
  end;

{ TWideCharSetType }

function TWideCharSetType.Compare(const AValue1, AValue2: TWideCharSet): NativeInt;
begin
  { No ordering }
  if AValue1 = AValue2 then
    Result := 0
  else
    Result := 1;
end;

procedure TWideCharSetType.DoDeserialize(const AInfo: TValueInfo; out AValue: TWideCharSet; const AContext: IDeserializationContext);
var
  LStr: String;
begin
  AContext.GetValue(AInfo, LStr);
  AValue := TWideCharSet.Create(LStr);
end;

procedure TWideCharSetType.DoSerialize(const AInfo: TValueInfo; const AValue: TWideCharSet; const AContext: ISerializationContext);
begin
  { The value of the charset is a simple string }
  AContext.AddValue(AInfo, GetString(AValue));
end;

function TWideCharSetType.GenerateHashCode(const AValue: TWideCharSet): NativeInt;
begin
  { Generate the hash }
  Result := BinaryHash(@AValue.FPieces[0], Length(AValue.FPieces) * SizeOf(TSysCharSet));
end;

function TWideCharSetType.GetString(const AValue: TWideCharSet): String;
var
  LChar: Char;
begin
  Result := '';

  { Build up the string }
  for LChar in AValue do
    Result := Result + LChar;
end;

function TWideCharSetType.TryConvertFromVariant(const AValue: Variant; out ORes: TWideCharSet): Boolean;
begin
  try
    ORes := TWideCharSet.Create(String(AValue));
    Result := true;
  except
    Result := false;
  end;
end;

function TWideCharSetType.TryConvertToVariant(const AValue: TWideCharSet; out ORes: Variant): Boolean;
begin
  ORes := GetString(AValue);
  Result := true;
end;


{ TWideCharSet }

{ The global overload for CharInSet that works with Wide char sets }
function CharInSet(C: WideChar; const CharSet: TWideCharSet): Boolean; overload; inline;
begin
  { Nothing more :) }
  Result := C in CharSet;
end;

class operator TWideCharSet.Add(const ALeft: TWideCharSet; const AChar: Char): TWideCharSet;
begin
  { Copy the input and add the char }
  Result := TWideCharSet.Create(ALeft);
  Result.MarkChar(AChar, true);
end;

constructor TWideCharSet.Create(const ACharSet: TSysCharSet);
begin
  { Grow the length with the necessary pieces to hold the sys set }
  SetLength(FPieces, 1);
  FPieces[0] := ACharSet;
end;

constructor TWideCharSet.Create(const ACharSet: TWideCharSet);
var
  L: NativeUInt;
begin
  { Copy the original }
  L := Length(ACharSet.FPieces);
  SetLength(FPieces, L);

  if L > 0 then
    Move(ACharSet.FPieces[0], FPieces[0], L * SizeOf(TSysCharSet));
end;

class operator TWideCharSet.Add(const ALeft: TWideCharSet; const ARight: TWideCharSet): TWideCharSet;
var
  I, L, R: NativeUInt;
begin
  L := Length(ALeft.FPieces);
  R := Length(ARight.FPieces);

  { Special cases }
  if L = 0 then
    Exit(ARight);

  if R = 0 then
    Exit(ALeft);

  if L > R then
  begin
    Result := TWideCharSet.Create(ALeft);

    for I := 0 to R - 1 do
      Result.FPieces[I] := Result.FPieces[I] + ARight.FPieces[I];
  end else
  begin
    Result := TWideCharSet.Create(ARight);

    for I := 0 to L - 1 do
      Result.FPieces[I] := Result.FPieces[I] + ALeft.FPieces[I];
  end
end;

function TWideCharSet.AsCollection: IEnexCollection<Char>;
begin
  Result := TEnumerable.Create(FPieces);
end;

constructor TWideCharSet.Create(const AString: String);
var
  LChar: Char;
begin
  { Kill myself }
  FPieces := nil;

  { Simply add all the stuff in }
  for LChar in AString do
    MarkChar(LChar, true);
end;

class constructor TWideCharSet.Create;
begin
  { Register the type }
  TType<TWideCharSet>.Register(TWideCharSetType);
end;

class destructor TWideCharSet.Destroy;
begin
  { Unregister the type }
  TType<TWideCharSet>.Unregister();
end;

class operator TWideCharSet.Exclude(const ALeft: TWideCharSet; const AString: string): TWideCharSet;
var
  LChar: Char;
begin
  { Copy the input }
  Result := TWideCharSet.Create(ALeft);

  { Simply remove all the stuff }
  for LChar in AString do
    Result.MarkChar(LChar, false);
end;

constructor TWideCharSet.Create(const AChar: Char);
begin
  { Kill myself }
  FPieces := nil;

  { Mark the char in the set }
  MarkChar(AChar, true);
end;

class operator TWideCharSet.Exclude(const ALeft: TWideCharSet; const AChar: Char): TWideCharSet;
begin
  { Copy the input and remove the char }
  Result := TWideCharSet.Create(ALeft);
  Result.MarkChar(AChar, false);
end;

class operator TWideCharSet.Include(const ALeft: TWideCharSet; const AChar: Char): TWideCharSet;
begin
  { Copy the input and add the char }
  Result := TWideCharSet.Create(ALeft);
  Result.MarkChar(AChar, true);
end;

class operator TWideCharSet.Implicit(const ARight: TSysCharSet): TWideCharSet;
begin
  { Call the constructor }
  Result := TWideCharSet.Create(ARight);
end;

class operator TWideCharSet.Implicit(const ALeft: TWideCharSet): TSysCharSet;
begin
  { Exit on empty set }
  if Length(ALeft.FPieces) = 0 then
    Result := []
  else
    Result := ALeft.FPieces[0];
end;

class operator TWideCharSet.Include(const ALeft: TWideCharSet; const AString: string): TWideCharSet;
var
  LChar: Char;
begin
  { Copy the input }
  Result := TWideCharSet.Create(ALeft);

  { Simply add all the stuff in }
  for LChar in AString do
    Result.MarkChar(LChar, true);
end;

procedure TWideCharSet.MarkChar(const AChar: Char; const AMark: Boolean);
var
  LPieceIndex: NativeInt;  {REQ}
  LPieceChar: AnsiChar;
begin
  { Calculate piece indexes }
  LPieceIndex := Word(AChar) div CCharSets;
  LPieceChar := AnsiChar(Word(AChar) mod CCharSets);

  { No piece defined just yet }
  if LPieceIndex >= Length(FPieces) then
  begin
    { Exit on un-marking ... nothing to do here actually }
    if not AMark then
      Exit;

    { Increase the length slightly }
    SetLength(FPieces, LPieceIndex + 1);
  end;

  { Set or clear the bit at the specified position }
  if AMark then
    Include(FPieces[LPieceIndex], LPieceChar)
  else
  begin
    Exclude(FPieces[LPieceIndex], LPieceChar);

    { Corner case, need to decrese the size accordingly }
    if (LPieceIndex = Length(FPieces) - 1) then
    begin
      while (LPieceIndex >= 0) and (FPieces[LPieceIndex] = []) do
        Dec(LPieceIndex);

      SetLength(FPieces, LPieceIndex + 1);
    end;
  end;
end;

class operator TWideCharSet.NotEqual(const ALeft, ARight: TWideCharSet): Boolean;
begin
  Result := not (ALeft = ARight);
end;

class operator TWideCharSet.Subtract(const ALeft: TWideCharSet; ARight: TWideCharSet): TWideCharSet;
var
  I, L, R, M: NativeUInt;
begin
  L := Length(ALeft.FPieces);
  R := Length(ARight.FPieces);

  { Special cases }
  if L = 0 then
    Exit(ARight);

  if R = 0 then
    Exit(ALeft);

  Result := TWideCharSet.Create(ALeft);

  if L > R then
    M := R
  else
    M := L;

  for I := 0 to M - 1 do
    Result.FPieces[I] := Result.FPieces[I] - ARight.FPieces[I];
end;

class operator TWideCharSet.Subtract(const ALeft: TWideCharSet; AChar: Char): TWideCharSet;
begin
  { Copy the input and remove the char }
  Result := TWideCharSet.Create(ALeft);
  Result.MarkChar(AChar, false);
end;

class operator TWideCharSet.In(const AChar: Char; const ARight: TWideCharSet): Boolean;
var
  LPieceIndex: NativeUInt;
  LPieceChar: AnsiChar;
begin
  { Calculate piece indexes }
  LPieceIndex := Word(AChar) div CCharSets;
  LPieceChar := AnsiChar(Word(AChar) mod CCharSets);

  { No piece defined just yet }
  if LPieceIndex >= NativeUInt(Length(ARight.FPieces)) then
    Result := false
  else
    Result := CharInSet(LPieceChar, ARight.FPieces[LPieceIndex]);
end;

class operator TWideCharSet.Equal(const ALeft, ARight: TWideCharSet): Boolean;
begin
  { Exit on different lengths }
  if Length(ALeft.FPieces) <> Length(ARight.FPieces) then
    Exit(false);

  Result := CompareMem(@ALeft.FPieces[0], @ARight.FPieces[0], Length(ALeft.FPieces) * SizeOf(TSysCharSet));
end;

class operator TWideCharSet.Exclude(const ALeft, ASet: TWideCharSet): TWideCharSet;
begin
  Result := ALeft - ASet;
end;

function TWideCharSet.GetEnumerator: IEnumerator<Char>;
begin
  { Create the enumerator }
  Result := TEnumerator.Create(FPieces);
end;

class function TWideCharSet.GetType: IType<TWideCharSet>;
begin
  Result := TWideCharSetType.Create();
end;

class operator TWideCharSet.Include(const ALeft, ASet: TWideCharSet): TWideCharSet;
begin
  Result := ALeft + ASet;
end;

{ TWideCharSet.TEnumerator }

constructor TWideCharSet.TEnumerator.Create(const APieces: TPieceArray);
begin
  inherited Create();

  FPieces := APieces;
  FCharCount := Length(FPieces) * CCharSets;
  FCharId := 0;
end;

function TWideCharSet.TEnumerator.GetCurrent: Char;
begin
  Result := FChar;
end;

function TWideCharSet.TEnumerator.MoveNext: Boolean;
begin
  { Defauls to false }
  Result := false;

  while FCharId < FCharCount do
  begin
    { Check whether the char is in the set specified ANSI set }
    if CharInSet(AnsiChar(FCharId mod CCharSets), FPieces[FCharId div CCharSets]) then
    begin
      FChar := Char(FCharId);

      { Found a char }
      Result := true;
    end;

    Inc(FCharId);

    { Exit on successeful find }
    if Result then
      Exit;
  end;
end;

{ TWideCharSet.TEnumerable }

constructor TWideCharSet.TEnumerable.Create(const APieces: TPieceArray);
begin
  inherited Create();

  { Copy }
  FPieces := APieces;

  { Install the type }
  InstallType(TType<Char>.Default);
end;

function TWideCharSet.TEnumerable.GetEnumerator: IEnumerator<Char>;
begin
  Result := TEnumerator.Create(FPieces);
end;

end.
