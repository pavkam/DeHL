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

unit Tests.TimeCheck;
interface
uses SysUtils, TestFramework,
     HelperLib.TypeSupport,
     HelperLib.Collections.Dictionary,
     HelperLib.Collections.KeyValuePair,
     HelperLib.Collections.Map,
     HelperLib.Collections.Exceptions,
     HelperLib.Date.DateTime,
     HelperLib.Date.TimeSpan;

type
 TExceptionClosure = reference to procedure;
 TClassOfException = class of Exception;

 TTestTimeAvgs = class(TTestCase)
 private
   function CreateDictionary(const NrElem : Integer; const RandomRange : Integer; var LastKey : Integer) : HDictionary<Integer, Integer>;
   function CreateMap(const NrElem : Integer; const RandomRange : Integer; var LastKey : Integer) : HMap<Integer, Integer>;

 published
   procedure TestMapVsDictAvgInsert();
   procedure TestMapVsDictFindAverage();
   procedure TestMapVsUnsortedArray();
 end;

implementation


{ TTestTimeMediums }

function TTestTimeAvgs.CreateDictionary(const NrElem,
  RandomRange: Integer; var LastKey : Integer): HDictionary<Integer, Integer>;
var
  I, X : integer;
  Dict : HDictionary<Integer,Integer>;

begin
  Dict := HDictionary<Integer,Integer>.Create();

  Randomize;

  for I := 0 to NrElem - 1 do
  begin
    X  := Random(RandomRange);

    if not Dict.ContainsKey(X) then
    begin
      Dict.Add(X, I);
      LastKey := X;
    end;
  end;

  Result := Dict;
end;

function TTestTimeAvgs.CreateMap(const NrElem,
  RandomRange: Integer; var LastKey : Integer): HMap<Integer, Integer>;
var
  I, X : integer;
  Map : HMap<Integer,Integer>;

begin
  Map := HMap<Integer,Integer>.Create();

  Randomize;

  for I := 0 to NrElem - 1 do
  begin
    X  := Random(RandomRange);

    if not Map.Contains(X) then
       Map.Insert(X, I);
  end;

  LastKey := Map[Map.Count - 1].Key;
  Result := Map;
end;

procedure TTestTimeAvgs.TestMapVsDictAvgInsert;
const
  NrItems = 100000;
var
  I, X, MapLastKey, DictLastKey: integer;
  Map  : HMap<Integer, Integer>;
  Dict : HDictionary<Integer,Integer>;

  DS, DE : HDateTime;
  MS, ME : HDateTime;

  DT, MT : HTimeSpan;
begin

  { inserting elements into dict and map }

  DS := HDateTime.Now;
  Dict := CreateDictionary(NrItems, $FFFF, DictLastKey);
  DE := HDateTime.Now;

  MS := HDateTime.Now;
  Map  := CreateMap(NrItems,$FFFF, MapLastKey);
  ME := HDateTime.Now;

  DT := (DE - DS);
  MT := (ME - MS);

  Check((MT.TotalMilliseconds / 8) >= DT.TotalMilliseconds, 'Map should be 8x slower than Dictionary at medium insert times.');

  Dict.Free;
  Map.Free;
end;

procedure TTestTimeAvgs.TestMapVsDictFindAverage;
const
  NrItems = 100000;
var
  I, X, MapLastKey, DictLastKey, DictKeysFound, MapKeysFound: integer;
  Map  : HMap<Integer, Integer>;
  Dict : HDictionary<Integer,Integer>;

  DS, DE : HDateTime;
  MS, ME : HDateTime;

  DT, MT : HTimeSpan;
  RandomKeyArray : array of Integer;
begin
  DictKeysFound := 0;
  MapKeysFound  := 0;
  Dict := CreateDictionary(NrItems, $FFFF, DictLastKey);
  Map  := CreateMap(NrItems,$FFFF, MapLastKey);
  randomize;

  { searching for random elements }
  SetLength(RandomKeyArray,NrItems);
  for I := 0 to NrItems - 1 do
    begin
      RandomKeyArray[I] := Random($FFFF);
    end;


  DS := HDateTime.Now;
  for I := 0 to NrItems - 1 do
    begin
      if Dict.ContainsKey(RandomKeyArray[I]) then
        Inc(DictKeysFound);
    end;
  DE := HDateTime.Now;

  MS := HDateTime.Now;
  for I := 0 to NrItems - 1 do
    begin
      if Map.Contains(RandomKeyArray[I]) then
        Inc(MapKeysFound);
    end;
  ME := HDateTime.Now;

  DT := (DE - DS);
  MT := (ME - MS);

  Check((MT.TotalMilliseconds / 5) >= DT.TotalMilliseconds, 'Map should be 5x slower than Dictionary at medium Contains times.');

  if MapKeysFound > DictKeysFound then
    begin
      Dict.Free;
      Map.Free;
      Exit();
    end;

  Dict.Free;
  Map.Free;

end;

procedure TTestTimeAvgs.TestMapVsUnsortedArray;
const
  NrItems = 10000;
var
  I, J, X, MapLastKey, DKeyFound, MKeyFound: integer;
  Map  : HMap<Integer, Integer>;

  DS, DE : HDateTime;
  MS, ME : HDateTime;

  DT, MT : HTimeSpan;
  RandomKeyArray : array of Integer;
  RandomValuesArray : array of HKeyValuePair<Integer,Integer>;
begin

  Map  := CreateMap(NrItems,$FFFF, MapLastKey);
  randomize;

  { searching for random elements }
  SetLength(RandomKeyArray,NrItems);
  for I := 0 to NrItems - 1 do
    begin
      RandomKeyArray[I] := Random($FFFF);
    end;

  SetLength(RandomValuesArray,NrItems);
  for I := 0 to NrItems - 1 do
    begin
      RandomValuesArray[I].Create(Random($FFFF),Random($FFFF));
      //RandomValuesArray[I].Value := Random($FFFF);
    end;


  DS := HDateTime.Now;
  for I := 0 to NrItems - 1 do
    for J := 0 to NrItems - 1 do
    begin
      if RandomValuesArray[J].Key = RandomKeyArray[I] then
        Inc(DKeyFound);
    end;
  DE := HDateTime.Now;

  MS := HDateTime.Now;
  for I := 0 to NrItems - 1 do
    begin
      if Map.Contains(RandomKeyArray[I]) then
        Inc(MKeyFound);
    end;
  ME := HDateTime.Now;

  DT := (DE - DS);
  MT := (ME - MS);

  Check(MT.TotalMilliseconds < DT.TotalMilliseconds, 'Map should be faster than n^2.');

  if MKeyFound > DKeyFound then
    begin
      Map.Free;
      Exit();
    end;

  Map.Free;

end;

initialization
  TestFramework.RegisterTest(TTestTimeAvgs.Suite);

end.
