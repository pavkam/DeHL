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
unit HelperLib.Collections.BitSet;
interface
uses SysUtils,
     HelperLib.Base,
     HelperLib.TypeSupport,
     HelperLib.Collections.Utils,
     HelperLib.Collections.KeyValuePair,
     HelperLib.Collections.Interfaces,
     HelperLib.Collections.Exceptions;

type
  PCardinal = ^Cardinal;

type
  HBitSet = class

  private //members
  var
  FArray  : array of Cardinal;
  FCount  : Cardinal;
  FACount : Cardinal;

  private //methods
  procedure PushBack();
  function IsSet(AValue : Integer; APos : Integer) : boolean;
  procedure SetBitAtPos(var AValue : Cardinal; var APos : Cardinal);

  public  //methods
  constructor Create(); overload;
  constructor Create(AValue : Integer); overload;
  constructor Create(AValue : HBitSet); overload;
  constructor Create(AArray : array of Integer); overload;

  procedure Clear(); //should call reset()

  procedure Remove(APosS : Cardinal; APosE : Cardinal); overload;
  procedure Remove(APos : Cardinal); overload;

  procedure ShiftLeft(AAmount : Cardinal); //shifts the whole bitset
  procedure ShiftRight(AAmount : Cardinal); //shifts the whole bitset

  procedure RotateLeft(AAmount : Cardinal); //rotates the whole bitset
  procedure RotateRight(AAmount : Cardinal); //rotates the whole bitset

  procedure InsertBit(APos : Cardinal); //inserts bit at pos

  procedure Flip(); overload; //flips the whole bitset
  procedure Flip(APos : Cardinal); overload; //flips the bit at pos

  procedure SetBit(APos : Cardinal; AOp : Boolean = True); //Sets bit at pos if op is true, and clears bit at pos if op is false.
  procedure Reset(); overload; //reset the whole bitset
  procedure Reset(APos : Cardinal); overload; //reset the bit as pos

end;
implementation


{ HBitSet }

procedure HBitSet.Clear;
begin
  SetLength(FArray,0);
  FCount :=0;
end;

constructor HBitSet.Create;
begin
  FArray := nil;
  FCount := 0;
end;

constructor HBitSet.Create(AValue: Integer);
var
  I : integer;
begin
  if AValue = 0 then
    Exit();

  SetLength(FArray,1);
  //determining the number of bits needed
  for I := 31 downto 0 do
  begin
    if IsSet(AValue, I) then
      begin
        FCount := I + 1;
        Break;
      end;
  end;

  //adding the first int into the array
  PushBack();

  //setting the bits
  FArray[0] := FArray[0] or AValue;

end;

constructor HBitSet.Create(AArray: array of Integer);
var
  I : Cardinal;
begin
  SetLength(FArray, Length(AArray));
  for I := 0 to Length(AArray) do
    FArray[I] := AArray[I];
end;

procedure HBitSet.Flip(APos: Cardinal);
begin

end;

procedure HBitSet.Flip;
begin

end;

constructor HBitSet.Create(AValue: HBitSet);
var
  I : Cardinal;
begin
  FCount := AValue.FCount;
  SetLength(FArray, Length(AValue.FArray));
  for I := 0 to Length(AValue.FArray) do
    FArray[I] := AValue.FArray[I];
end;

procedure HBitSet.InsertBit(APos: Cardinal);
begin

end;

function HBitSet.IsSet(AValue, APos: Integer): boolean;
var
  b : boolean;
  label __IsNotSet;
begin
  b := false;

  asm
    push eax;
    push ecx;

    mov eax, 1;
    mov ecx, APos;
    shl eax, cl;

    mov ecx, AValue;
    and ecx, eax;

    cmp ecx, 0

    jz __IsNotSet
    mov b, 1;

    __IsNotSet:
    pop ecx;
    pop eax;
  end;

  Result := b;
end;

procedure HBitSet.PushBack();
begin
  SetLength(FArray, Length(FArray) + 1);
  FArray[Length(FArray) - 1] := 0;
end;

procedure HBitSet.Remove(APos: Cardinal);
var
  I : Cardinal;
  DWordPos : Cardinal;
  DWordOffset : Cardinal;
  NoOfDWords : Cardinal;
  LastBit : Boolean;
  LastPosNeedstToBeShifted : Boolean;
  TempDWord : Cardinal;
begin
  LastBit := false;
  LastPosNeedstToBeShifted := false;
  if APos < 0 then
    raise EArgumentOutOfRangeException.Create('Cannot remove bit before bitset start');

  if APos > FCount then
    raise EArgumentOutOfRangeException.Create('Cannot remove bit after bitset end');

  if APos = 0 then
  begin
    DWordPos := 0;
    DWordOffset := 0;
  end
  else
  begin
    DWordPos := APos div 32;
    DWordOffset := APos mod 32;
  end;

  NoOfDWords := (FCount - APos) div 32;

  //if the last dword has 1 bit set then we remove the last dword
  if FCount mod 32 = 1 then
  begin
    SetLength(FArray, Length(FArray) - 1);
  end;

  //now for moving the values
  for I := DWordPos + 1 to Length(FArray) - 2 do
  begin
    LastPosNeedstToBeShifted := true;
    //determining the last bit of the next dword
    if (FArray[I+1] and (1 shl 32)) > 0 then
      LastBit := true
      else
      LastBit := false;
    //shifting left the current dword and setting the last position
    FArray[I] := FArray[I] shl 1;
    if LastBit = true then
      FArray[I] := FArray[I] or 1
    else
      FArray[I] := FArray[I] and (not 1);
  end;

  //now for the last position
  if LastPosNeedstToBeShifted then
  FArray[Length(FArray)] := FArray[Length(FArray)] shl 1;

  //ok now for the current dword
  TempDWord := 1;
  for I := 0 to 31 - DWordOffset do
    begin
    TempDWord := TempDWord shl 1;
    TempDWord := TempDWord or (1 shl I);
    end;
  if LastBit = true then
    begin
    TempDWord := TempDWord shl 1;
    TempDWord := TempDWord or 1;
    end
    else
    begin
    TempDWord := TempDWord shl 1;
    TempDWord := TempDWord and (not 1);
    end;

end;

procedure HBitSet.Reset;
begin
  Clear();
end;

procedure HBitSet.Reset(APos: Cardinal);
var
  DWordPos : Cardinal;
  DWordOffset : Cardinal;
begin
  DWordOffset := APos mod 32;
  DWordPos := APos div 32;

  FArray[DWordPos] := FArray[DWordPos] or (not (1 shl APos));
end;

procedure HBitSet.Remove(APosS, APosE: Cardinal);
var
  DWordPos : Cardinal;
  DWordOffset : Cardinal;
  NoDWords : Cardinal;
  NoBitsToRemove : Cardinal;

begin
  NoBitsToRemove := APosE - APosS;
  if FCount = 0 then
    raise EArgumentOutOfRangeException.Create('Cannot remove from empty bitset!');

  if APosS < 0 then
    raise EArgumentOutOfRangeException.Create('Cannot set start removing position before bitset start');

  if APosE > 0 then
    raise EArgumentOutOfRangeException.Create('Cannot set end removing position after bitset end');

  if APosS > APosE then
    raise EArgumentOutOfRangeException.Create('Cannot have start position greater than end position');

  if NoBitsToRemove = 0 then
    begin
    Remove(APosS);
    Exit;
    end;

  if NoBitsToRemove > 32 then
    begin
    NoDWords := (APosE - APosS) div 32;
    //to finish
    end;



end;

procedure HBitSet.RotateLeft(AAmount: Cardinal);
begin

end;

procedure HBitSet.RotateRight(AAmount: Cardinal);
begin

end;

procedure HBitSet.SetBit(APos: Cardinal; AOp: Boolean);
begin

end;

procedure HBitSet.SetBitAtPos(var AValue : Cardinal; var APos: Cardinal);
var
  DWordPos : Cardinal;
  DWordOffset : Cardinal;
begin
  DWordOffset := APos mod 32;
  DWordPos := APos div 32;

  FArray[DWordPos] := FArray[DWordPos] or (1 shl APos);
end;

procedure HBitSet.ShiftLeft(AAmount: Cardinal);
begin

end;

procedure HBitSet.ShiftRight(AAmount: Cardinal);
begin

end;

end.
