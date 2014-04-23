(*
* Copyright (c) 2010, Ciobanu Alexandru
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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.TString;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Exceptions,
     DeHL.WideCharSet,
     DeHL.Collections.List,
     DeHL.Types,
     DeHL.Strings;

const
{$IFDEF TSTRING_ZERO_INDEXED}
  CFirstCharacterIndex = 0;
{$ELSE}
  CFirstCharacterIndex = 1;
{$ENDIF}

type
  TTestString = class(TDeHLTestCase)
  published
    procedure Test_U;
    procedure Test_Create_String();
    procedure Test_Create_TString();
    procedure Test_FromUTF8String();
    procedure Test_FromUCS4String();
    procedure Test_Op_Implicit_ToString;
    procedure Test_Op_Implicit_ToVariant;
    procedure Test_Op_Implicit_FromString;
    procedure Test_AsCollection();
    procedure Test_Enumerator();
    procedure Test_Length;
    procedure Test_Chars;
    procedure Test_IsEmpty;
    procedure Test_IsWhiteSpace;
    procedure Test_ToString();
    procedure Test_ToUTF8String();
    procedure Test_ToUCS4String();
    procedure Test_TrimLeft_TWideCharSet;
    procedure Test_TrimLeft;
    procedure Test_TrimRight_TWideCharSet;
    procedure Test_TrimRight;
    procedure Test_Trim_TWideCharSet;
    procedure Test_Trim;
    procedure Test_PadLeft;
    procedure Test_PadRight;
    procedure Test_Contains;
    procedure Test_IndexOf;
    procedure Test_LastIndexOf;
    procedure Test_IndexOfAny;
    procedure Test_LastIndexOfAny;
    procedure Test_StartsWith;
    procedure Test_EndsWith;
    procedure Test_Split_TWideCharSet;
    procedure Test_Split_Char;
    procedure Test_Substring;
    procedure Test_Substring_Start;
    procedure Test_Insert;
    procedure Test_Replace_Char;
    procedure Test_Replace;
    procedure Test_Remove;
    procedure Test_Remove_Start;
    procedure Test_Reverse;
    procedure Test_Dupe;
    procedure Test_ToUpper;
    procedure Test_ToUpperInvariant;
    procedure Test_ToLower;
    procedure Test_ToLowerInvariant;
    procedure Test_Concat_2;
    procedure Test_Concat_3;
    procedure Test_Concat_4;
    procedure Test_Concat_5;
    procedure Test_Concat_Array;
    procedure Test_Concat_IEnumerable;
    procedure Test_Join_Array;
    procedure Test_Join_IEnumerable;
    procedure Test_Format;
    procedure Test_Format_FmtSettings;
    procedure Test_Compare;
    procedure Test_CompareTo;
    procedure Test_Equal;
    procedure Test_EqualsWith;
    procedure Test_Empty;
    procedure Test_TypeObject;
    procedure Test_Op_Add_TString;
    procedure Test_Op_Add_Char;
    procedure Test_Op_Add_Integer;
    procedure Test_Op_Add_Cardinal;
    procedure Test_Op_Add_Int64;
    procedure Test_Op_Add_UInt64;
    procedure Test_Op_Add_Extended;
    procedure Test_Op_Add_Currency;
    procedure Test_Op_Add_Boolean;
    procedure Test_Op_Add_TDateTime;
    procedure Test_Op_Add_TDate;
    procedure Test_Op_Add_TTime;
    procedure Test_Op_Add_Variant;
    procedure Test_Op_Equal;
    procedure Test_Op_Not_Equal;
    procedure Test_TypeSupport;
  end;

implementation

{ TTestString }

procedure TTestString.Test_AsCollection;
var
  C: char;
  L: string;
begin
  CheckEquals('abrcd', TString.Concat(U('abracadabra').AsCollection.Distinct.Op.Cast<string>));
  CheckEquals(11, U('abracadabra').AsCollection.Count);

  L := '';
  for C in U('тестинг').AsCollection do
    L := L + C;

  CheckEquals('тестинг', L);
end;

procedure TTestString.Test_Chars;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := #0;
  LStr3 := 'Hello World!';
  LStr4 := 'тестинг';

{$IFDEF TSTRING_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin if LStr1[CFirstCharacterIndex] = '1' then; end,
    'EArgumentOutOfRangeException not thrown in LStr1[0].'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin if LStr2[CFirstCharacterIndex + 1] = '1' then; end,
    'EArgumentOutOfRangeException not thrown in LStr1[0].'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin if LStr3[CFirstCharacterIndex - 1] = '1' then; end,
    'EArgumentOutOfRangeException not thrown in LStr1[0].'
  );
{$ENDIF}

  CheckEquals(#0, LStr2[CFirstCharacterIndex]);
  CheckEquals('H', LStr3[CFirstCharacterIndex]);
  CheckEquals('!', LStr3[CFirstCharacterIndex + 11]);
  CheckEquals('т', LStr4[CFirstCharacterIndex]);
  CheckEquals('г', LStr4[CFirstCharacterIndex + 6]);
end;

procedure TTestString.Test_Compare;
begin
  CheckTrue(0 = TString.Compare('Hello', 'Hello'));
  CheckTrue(0 = TString.Compare('тестинг', 'тестинг'));
  CheckTrue(0 < TString.Compare('Hello', 'helLo'));
  CheckTrue(0 > TString.Compare('тестинг', 'ТесТинг'));
  CheckTrue(0 < TString.Compare('Hello', 'helLo', scLocale));
  CheckTrue(0 > TString.Compare('helLo', 'Hello', scLocale));
  CheckTrue(0 > TString.Compare('тестинг', 'ТесТинг', scLocale));
  CheckTrue(0 < TString.Compare('ТесТинг', 'тестинг', scLocale));
  CheckTrue(0 = TString.Compare('helLo', 'Hello', scLocaleIgnoreCase));
  CheckTrue(0 = TString.Compare('Hello', 'helLo', scLocaleIgnoreCase));
  CheckTrue(0 = TString.Compare('ТесТинг', 'тестинг', scLocaleIgnoreCase));
  CheckTrue(0 = TString.Compare('тестинг', 'ТесТинг', scLocaleIgnoreCase));
  CheckTrue(0 > TString.Compare('helLo', 'Hello', scInvariant));
  CheckTrue(0 < TString.Compare('Hello', 'helLo', scInvariant));
  CheckTrue(0 < TString.Compare('ТесТинг', 'тестинг', scInvariant));
  CheckTrue(0 > TString.Compare('тестинг', 'ТесТинг', scInvariant));
  CheckTrue(0 = TString.Compare('helLo', 'Hello', scInvariantIgnoreCase));
  CheckTrue(0 = TString.Compare('Hello', 'helLo', scInvariantIgnoreCase));
  CheckTrue(0 = TString.Compare('ТесТинг', 'тестинг', scInvariantIgnoreCase));
  CheckTrue(0 = TString.Compare('тестинг', 'ТесТинг', scInvariantIgnoreCase));
  CheckTrue(0 < TString.Compare('helLo', 'Hello', scOrdinal));
  CheckTrue(0 > TString.Compare('Hello', 'helLo', scOrdinal));
  CheckTrue(0 > TString.Compare('ТесТинг', 'тестинг', scOrdinal));
  CheckTrue(0 < TString.Compare('тестинг', 'ТесТинг', scOrdinal));
  CheckTrue(0 = TString.Compare('helLo', 'Hello', scOrdinalIgnoreCase));
  CheckTrue(0 = TString.Compare('Hello', 'helLo', scOrdinalIgnoreCase));
  CheckTrue(0 = TString.Compare('ТесТинг', 'тестинг', scOrdinalIgnoreCase));
  CheckTrue(0 = TString.Compare('тестинг', 'ТесТинг', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_CompareTo;
begin
  CheckTrue(0 = U('Hello').CompareTo('Hello'));
  CheckTrue(0 = U('тестинг').CompareTo('тестинг'));
  CheckTrue(0 < U('Hello').CompareTo('helLo'));
  CheckTrue(0 > U('тестинг').CompareTo('ТесТинг'));
  CheckTrue(0 < U('Hello').CompareTo('helLo', scLocale));
  CheckTrue(0 > U('helLo').CompareTo('Hello', scLocale));
  CheckTrue(0 > U('тестинг').CompareTo('ТесТинг', scLocale));
  CheckTrue(0 < U('ТесТинг').CompareTo('тестинг', scLocale));
  CheckTrue(0 = U('helLo').CompareTo('Hello', scLocaleIgnoreCase));
  CheckTrue(0 = U('Hello').CompareTo('helLo', scLocaleIgnoreCase));
  CheckTrue(0 = U('ТесТинг').CompareTo('тестинг', scLocaleIgnoreCase));
  CheckTrue(0 = U('тестинг').CompareTo('ТесТинг', scLocaleIgnoreCase));
  CheckTrue(0 > U('helLo').CompareTo('Hello', scInvariant));
  CheckTrue(0 < U('Hello').CompareTo('helLo', scInvariant));
  CheckTrue(0 < U('ТесТинг').CompareTo('тестинг', scInvariant));
  CheckTrue(0 > U('тестинг').CompareTo('ТесТинг', scInvariant));
  CheckTrue(0 = U('helLo').CompareTo('Hello', scInvariantIgnoreCase));
  CheckTrue(0 = U('Hello').CompareTo('helLo', scInvariantIgnoreCase));
  CheckTrue(0 = U('ТесТинг').CompareTo('тестинг', scInvariantIgnoreCase));
  CheckTrue(0 = U('тестинг').CompareTo('ТесТинг', scInvariantIgnoreCase));
  CheckTrue(0 < U('helLo').CompareTo('Hello', scOrdinal));
  CheckTrue(0 > U('Hello').CompareTo('helLo', scOrdinal));
  CheckTrue(0 > U('ТесТинг').CompareTo('тестинг', scOrdinal));
  CheckTrue(0 < U('тестинг').CompareTo('ТесТинг', scOrdinal));
  CheckTrue(0 = U('helLo').CompareTo('Hello', scOrdinalIgnoreCase));
  CheckTrue(0 = U('Hello').CompareTo('helLo', scOrdinalIgnoreCase));
  CheckTrue(0 = U('ТесТинг').CompareTo('тестинг', scOrdinalIgnoreCase));
  CheckTrue(0 = U('тестинг').CompareTo('ТесТинг', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_Concat_2;
begin
  CheckEquals('', TString.Concat('', '').ToString);
  CheckEquals('one two', TString.Concat('one ', 'two'));
  CheckEquals('Zevra Runner', TString.Concat('', 'Zevra Runner'));
end;

procedure TTestString.Test_Concat_3;
begin
  CheckEquals('', TString.Concat('', '', '').ToString);
  CheckEquals('one two three', TString.Concat('one ', 'two', ' three'));
  CheckEquals('Zevra Runner', TString.Concat('', 'Zevra Runner', ''));
end;

procedure TTestString.Test_Concat_4;
begin
  CheckEquals('', TString.Concat('', '', '', '').ToString);
  CheckEquals('one two three four', TString.Concat('one ', 'two', ' three ', 'four'));
  CheckEquals('Zevra Runner', TString.Concat('', '', 'Zevra Runner', ''));
end;

procedure TTestString.Test_Concat_5;
begin
  CheckEquals('', TString.Concat('', '', '', '', '').ToString);
  CheckEquals('one two three four five', TString.Concat('one ', 'two', ' three ', 'four', ' five'));
  CheckEquals('Zevra Runner', TString.Concat('', '', '', 'Zevra Runner', ''));
end;

procedure TTestString.Test_Concat_Array;
var
  LOut: TString;
  LExp: string;
  I, X: Integer;
  LStrs: TArray<string>;
begin
  LOut := '';

  for I := 1 to 10 do
  begin
    SetLength(LStrs, I);
    LExp := '';
    for X := 0 to I - 1 do
    begin
      LExp := LExp + Chr(Ord('A') + X);
      LStrs[X] := Chr(Ord('A') + X);
    end;

    LOut := TString.Concat(LStrs);

    CheckEquals(LExp, LOut.ToString, U('iteration = ') + I);
  end;
end;

procedure TTestString.Test_Concat_IEnumerable;
var
  LList: TList<string>;
begin
  LList := TList<string>.Create;
  CheckEquals('', TString.Concat(LList).ToString);

  LList.Add('I ');
  LList.Add('am ');
  LList.Add('list');
  CheckEquals('I am list', TString.Concat(LList).ToString);

  LList.Free;
end;

procedure TTestString.Test_Contains;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := 'Hello World';
  LStr3 := 'Boom!'#0'Blam';
  LStr4 := 'вопрос';

  { Default }
  CheckFalse(LStr1.Contains(''));
  CheckFalse(LStr1.Contains(' '));
  CheckFalse(LStr2.Contains(''));
  CheckTrue(LStr2.Contains('Hello'));
  CheckFalse(LStr2.Contains('Hello World!!!!!'));
  CheckTrue(LStr2.Contains('Hello World'));
  CheckFalse(LStr2.Contains('hello World'));
  CheckTrue(LStr2.Contains(' '));
  CheckFalse(LStr2.Contains('_'));
  CheckTrue(LStr3.Contains(#0));
  CheckTrue(LStr3.Contains('Blam'));
  CheckTrue(LStr4.Contains('вопрос'));
  CheckFalse(LStr4.Contains('ВоПрос'));
  CheckTrue(LStr4.Contains('рос'));
  CheckFalse(LStr4.Contains('Рос'));

  { scLocale }
  CheckFalse(LStr1.Contains('', scLocale));
  CheckFalse(LStr1.Contains(' ', scLocale));
  CheckFalse(LStr2.Contains('', scLocale));
  CheckTrue(LStr2.Contains('Hello', scLocale));
  CheckFalse(LStr2.Contains('Hello World!!!!!', scLocale));
  CheckTrue(LStr2.Contains('Hello World', scLocale));
  CheckFalse(LStr2.Contains('hello World', scLocale));
  CheckTrue(LStr2.Contains(' ', scLocale));
  CheckFalse(LStr2.Contains('_', scLocale));
  CheckTrue(LStr3.Contains(#0, scLocale));
  CheckTrue(LStr3.Contains('Blam', scLocale));
  CheckTrue(LStr4.Contains('вопрос', scLocale));
  CheckFalse(LStr4.Contains('ВоПрос', scLocale));
  CheckTrue(LStr4.Contains('рос', scLocale));
  CheckFalse(LStr4.Contains('Рос', scLocale));

  { scLocaleIgnoreCase }
  CheckFalse(LStr1.Contains('', scLocaleIgnoreCase));
  CheckFalse(LStr1.Contains(' ', scLocaleIgnoreCase));
  CheckFalse(LStr2.Contains('', scLocaleIgnoreCase));
  CheckTrue(LStr2.Contains('Hello', scLocaleIgnoreCase));
  CheckFalse(LStr2.Contains('Hello World!!!!!', scLocaleIgnoreCase));
  CheckTrue(LStr2.Contains('Hello World', scLocaleIgnoreCase));
  CheckTrue(LStr2.Contains('hello World', scLocaleIgnoreCase));
  CheckTrue(LStr2.Contains(' ', scLocaleIgnoreCase));
  CheckFalse(LStr2.Contains('_', scLocaleIgnoreCase));
  CheckTrue(LStr3.Contains(#0, scLocaleIgnoreCase));
  CheckTrue(LStr3.Contains('Blam', scLocaleIgnoreCase));
  CheckTrue(LStr4.Contains('вопрос', scLocaleIgnoreCase));
  CheckTrue(LStr4.Contains('ВоПрос', scLocaleIgnoreCase));
  CheckTrue(LStr4.Contains('рос', scLocaleIgnoreCase));
  CheckTrue(LStr4.Contains('Рос', scLocaleIgnoreCase));

  { scInvariant }
  CheckFalse(LStr1.Contains('', scInvariant));
  CheckFalse(LStr1.Contains(' ', scInvariant));
  CheckFalse(LStr2.Contains('', scInvariant));
  CheckTrue(LStr2.Contains('Hello', scInvariant));
  CheckFalse(LStr2.Contains('Hello World!!!!!', scInvariant));
  CheckTrue(LStr2.Contains('Hello World', scInvariant));
  CheckFalse(LStr2.Contains('hello World', scInvariant));
  CheckTrue(LStr2.Contains(' ', scInvariant));
  CheckFalse(LStr2.Contains('_', scInvariant));
  CheckTrue(LStr3.Contains(#0, scInvariant));
  CheckTrue(LStr3.Contains('Blam', scInvariant));
  CheckTrue(LStr4.Contains('вопрос', scInvariant));
  CheckFalse(LStr4.Contains('ВоПрос', scInvariant));
  CheckTrue(LStr4.Contains('рос', scInvariant));
  CheckFalse(LStr4.Contains('Рос', scInvariant));

  { scInvariantIgnoreCase }
  CheckFalse(LStr1.Contains('', scInvariantIgnoreCase));
  CheckFalse(LStr1.Contains(' ', scInvariantIgnoreCase));
  CheckFalse(LStr2.Contains('', scInvariantIgnoreCase));
  CheckTrue(LStr2.Contains('Hello', scInvariantIgnoreCase));
  CheckFalse(LStr2.Contains('Hello World!!!!!', scInvariantIgnoreCase));
  CheckTrue(LStr2.Contains('Hello World', scInvariantIgnoreCase));
  CheckTrue(LStr2.Contains('hello World', scInvariantIgnoreCase));
  CheckTrue(LStr2.Contains(' ', scInvariantIgnoreCase));
  CheckFalse(LStr2.Contains('_', scInvariantIgnoreCase));
  CheckTrue(LStr3.Contains(#0, scInvariantIgnoreCase));
  CheckTrue(LStr3.Contains('Blam', scInvariantIgnoreCase));
  CheckTrue(LStr4.Contains('вопрос', scInvariantIgnoreCase));
  CheckTrue(LStr4.Contains('ВоПрос', scInvariantIgnoreCase));
  CheckTrue(LStr4.Contains('рос', scInvariantIgnoreCase));
  CheckTrue(LStr4.Contains('Рос', scInvariantIgnoreCase));

  { scOrdinal }
  CheckFalse(LStr1.Contains('', scOrdinal));
  CheckFalse(LStr1.Contains(' ', scOrdinal));
  CheckFalse(LStr2.Contains('', scOrdinal));
  CheckTrue(LStr2.Contains('Hello', scOrdinal));
  CheckFalse(LStr2.Contains('Hello World!!!!!', scOrdinal));
  CheckTrue(LStr2.Contains('Hello World', scOrdinal));
  CheckFalse(LStr2.Contains('hello World', scOrdinal));
  CheckTrue(LStr2.Contains(' ', scOrdinal));
  CheckFalse(LStr2.Contains('_', scOrdinal));
  CheckTrue(LStr3.Contains(#0, scOrdinal));
  CheckTrue(LStr3.Contains('Blam', scOrdinal));
  CheckTrue(LStr4.Contains('вопрос', scOrdinal));
  CheckFalse(LStr4.Contains('ВоПрос', scOrdinal));
  CheckTrue(LStr4.Contains('рос', scOrdinal));
  CheckFalse(LStr4.Contains('Рос', scOrdinal));

  { scOrdinalIgnoreCase }
  CheckFalse(LStr1.Contains('', scOrdinalIgnoreCase));
  CheckFalse(LStr1.Contains(' ', scOrdinalIgnoreCase));
  CheckFalse(LStr2.Contains('', scOrdinalIgnoreCase));
  CheckTrue(LStr2.Contains('Hello', scOrdinalIgnoreCase));
  CheckFalse(LStr2.Contains('Hello World!!!!!', scOrdinalIgnoreCase));
  CheckTrue(LStr2.Contains('Hello World', scOrdinalIgnoreCase));
  CheckTrue(LStr2.Contains('hello World', scOrdinalIgnoreCase));
  CheckTrue(LStr2.Contains(' ', scOrdinalIgnoreCase));
  CheckFalse(LStr2.Contains('_', scOrdinalIgnoreCase));
  CheckTrue(LStr3.Contains(#0, scOrdinalIgnoreCase));
  CheckTrue(LStr3.Contains('Blam', scOrdinalIgnoreCase));
  CheckTrue(LStr4.Contains('вопрос', scOrdinalIgnoreCase));
  CheckTrue(LStr4.Contains('ВоПрос', scOrdinalIgnoreCase));
  CheckTrue(LStr4.Contains('рос', scOrdinalIgnoreCase));
  CheckTrue(LStr4.Contains('Рос', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_Create_String;
var
  LString: TString;
begin
  CheckTrue(LString.IsEmpty, 'Expected string to be empty (no init)');

  LString := '';
  CheckTrue(LString.IsEmpty, 'Expected string to be empty (after init)');

  LString := #0;
  CheckTrue(not LString.IsEmpty, 'Expected string not to be empty (after init)');

  LString := 'Hello string';
  CheckEquals('Hello string', LString.ToString, 'Expected proper string (after init)');
end;

procedure TTestString.Test_Create_TString;
var
  LString, LNew: TString;
begin
  LNew := '';
  LString := LNew;
  CheckTrue(LString.IsEmpty, 'Expected empty string (after ass)');

  LNew := #0;
  LString := LNew;
  CheckEquals(#0, LString.ToString, 'Expected proper on zero');

  LNew := 'Hello World';
  LString := LNew;
  CheckEquals('Hello World', LString.ToString, 'Expected proper');
end;

procedure TTestString.Test_Dupe;
begin
  CheckEquals('', U('').Dupe(0));
  CheckEquals('', U('').Dupe(100));

  CheckEquals('', U('1').Dupe(0));
  CheckEquals('1', U('1').Dupe(1));
  CheckEquals('11111', U('1').Dupe(5));
  CheckEquals('11', U('1').Dupe);
end;

procedure TTestString.Test_Empty;
begin
  CheckEquals('', TString.Empty.ToString);
  CheckTrue(TString.Empty.IsEmpty);
end;

procedure TTestString.Test_EndsWith;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := 'Hello World';
  LStr3 := 'Boom!'#0'Blam';
  LStr4 := 'вопрос';

  { Default }
  CheckFalse(LStr1.EndsWith(''));
  CheckFalse(LStr1.EndsWith(' '));
  CheckFalse(LStr2.EndsWith(''));
  CheckTrue(LStr2.EndsWith('World'));
  CheckFalse(LStr2.EndsWith('Hello World!!!!!'));
  CheckTrue(LStr2.EndsWith('Hello World'));
  CheckFalse(LStr2.EndsWith('world'));
  CheckFalse(LStr2.EndsWith(' '));
  CheckFalse(LStr2.EndsWith('_'));
  CheckFalse(LStr3.EndsWith(#0));
  CheckTrue(LStr3.EndsWith(#0'Blam'));
  CheckFalse(LStr3.EndsWith('Boom!'));
  CheckTrue(LStr4.EndsWith('вопрос'));
  CheckFalse(LStr4.EndsWith('ВоПрос'));
  CheckTrue(LStr4.EndsWith('рос'));
  CheckFalse(LStr4.EndsWith('Во'));

  { scLocale }
  CheckFalse(LStr1.EndsWith('', scLocale));
  CheckFalse(LStr1.EndsWith(' ', scLocale));
  CheckFalse(LStr2.EndsWith('', scLocale));
  CheckTrue(LStr2.EndsWith('World', scLocale));
  CheckFalse(LStr2.EndsWith('Hello World!!!!!', scLocale));
  CheckTrue(LStr2.EndsWith('Hello World', scLocale));
  CheckFalse(LStr2.EndsWith('world', scLocale));
  CheckFalse(LStr2.EndsWith(' ', scLocale));
  CheckFalse(LStr2.EndsWith('_', scLocale));
  CheckFalse(LStr3.EndsWith(#0, scLocale));
  CheckFalse(LStr3.EndsWith(#0'blam', scLocale));
  CheckFalse(LStr3.EndsWith('Boom!', scLocale));
  CheckTrue(LStr4.EndsWith('вопрос', scLocale));
  CheckFalse(LStr4.EndsWith('ВоПрос', scLocale));
  CheckTrue(LStr4.EndsWith('рос', scLocale));
  CheckFalse(LStr4.EndsWith('Во', scLocale));

  { scLocaleIgnoreCase }
  CheckFalse(LStr1.EndsWith('', scLocaleIgnoreCase));
  CheckFalse(LStr1.EndsWith(' ', scLocaleIgnoreCase));
  CheckFalse(LStr2.EndsWith('', scLocaleIgnoreCase));
  CheckTrue(LStr2.EndsWith('World', scLocaleIgnoreCase));
  CheckFalse(LStr2.EndsWith('Hello World!!!!!', scLocaleIgnoreCase));
  CheckTrue(LStr2.EndsWith('Hello World', scLocaleIgnoreCase));
  CheckTrue(LStr2.EndsWith('world', scLocaleIgnoreCase));
  CheckFalse(LStr2.EndsWith(' ', scLocaleIgnoreCase));
  CheckFalse(LStr2.EndsWith('_', scLocaleIgnoreCase));
  CheckFalse(LStr3.EndsWith(#0, scLocaleIgnoreCase));
  CheckTrue(LStr3.EndsWith(#0'blam', scLocaleIgnoreCase));
  CheckFalse(LStr3.EndsWith('Boom!', scLocaleIgnoreCase));
  CheckTrue(LStr4.EndsWith('вопрос', scLocaleIgnoreCase));
  CheckTrue(LStr4.EndsWith('ВоПрос', scLocaleIgnoreCase));
  CheckTrue(LStr4.EndsWith('рос', scLocaleIgnoreCase));
  CheckFalse(LStr4.EndsWith('Во', scLocaleIgnoreCase));

  { scInvariant }
  CheckFalse(LStr1.EndsWith('', scInvariant));
  CheckFalse(LStr1.EndsWith(' ', scInvariant));
  CheckFalse(LStr2.EndsWith('', scInvariant));
  CheckTrue(LStr2.EndsWith('World', scInvariant));
  CheckFalse(LStr2.EndsWith('Hello World!!!!!', scInvariant));
  CheckTrue(LStr2.EndsWith('Hello World', scInvariant));
  CheckFalse(LStr2.EndsWith('world', scInvariant));
  CheckFalse(LStr2.EndsWith(' ', scInvariant));
  CheckFalse(LStr2.EndsWith('_', scInvariant));
  CheckFalse(LStr3.EndsWith(#0, scInvariant));
  CheckFalse(LStr3.EndsWith(#0'blam', scInvariant));
  CheckFalse(LStr3.EndsWith('Boom!', scInvariant));
  CheckTrue(LStr4.EndsWith('вопрос', scInvariant));
  CheckFalse(LStr4.EndsWith('ВоПрос', scInvariant));
  CheckTrue(LStr4.EndsWith('рос', scInvariant));
  CheckFalse(LStr4.EndsWith('Во', scInvariant));

  { scInvariantIgnoreCase }
  CheckFalse(LStr1.EndsWith('', scInvariantIgnoreCase));
  CheckFalse(LStr1.EndsWith(' ', scInvariantIgnoreCase));
  CheckFalse(LStr2.EndsWith('', scInvariantIgnoreCase));
  CheckTrue(LStr2.EndsWith('World', scInvariantIgnoreCase));
  CheckFalse(LStr2.EndsWith('Hello World!!!!!', scInvariantIgnoreCase));
  CheckTrue(LStr2.EndsWith('Hello World', scInvariantIgnoreCase));
  CheckTrue(LStr2.EndsWith('world', scInvariantIgnoreCase));
  CheckFalse(LStr2.EndsWith(' ', scInvariantIgnoreCase));
  CheckFalse(LStr2.EndsWith('_', scInvariantIgnoreCase));
  CheckFalse(LStr3.EndsWith(#0, scInvariantIgnoreCase));
  CheckTrue(LStr3.EndsWith(#0'blam', scInvariantIgnoreCase));
  CheckFalse(LStr3.EndsWith('Boom!', scInvariantIgnoreCase));
  CheckTrue(LStr4.EndsWith('вопрос', scInvariantIgnoreCase));
  CheckTrue(LStr4.EndsWith('ВоПрос', scInvariantIgnoreCase));
  CheckTrue(LStr4.EndsWith('рос', scInvariantIgnoreCase));
  CheckFalse(LStr4.EndsWith('Во', scInvariantIgnoreCase));

  { scOrdinal }
  CheckFalse(LStr1.EndsWith('', scOrdinal));
  CheckFalse(LStr1.EndsWith(' ', scOrdinal));
  CheckFalse(LStr2.EndsWith('', scOrdinal));
  CheckTrue(LStr2.EndsWith('World', scOrdinal));
  CheckFalse(LStr2.EndsWith('Hello World!!!!!', scOrdinal));
  CheckTrue(LStr2.EndsWith('Hello World', scOrdinal));
  CheckFalse(LStr2.EndsWith('world', scOrdinal));
  CheckFalse(LStr2.EndsWith(' ', scOrdinal));
  CheckFalse(LStr2.EndsWith('_', scOrdinal));
  CheckFalse(LStr3.EndsWith(#0, scOrdinal));
  CheckFalse(LStr3.EndsWith(#0'blam', scOrdinal));
  CheckFalse(LStr3.EndsWith('Boom!', scOrdinal));
  CheckTrue(LStr4.EndsWith('вопрос', scOrdinal));
  CheckFalse(LStr4.EndsWith('ВоПрос', scOrdinal));
  CheckTrue(LStr4.EndsWith('рос', scOrdinal));
  CheckFalse(LStr4.EndsWith('Во', scOrdinal));

  { scOrdinalIgnoreCase }
  CheckFalse(LStr1.EndsWith('', scOrdinalIgnoreCase));
  CheckFalse(LStr1.EndsWith(' ', scOrdinalIgnoreCase));
  CheckFalse(LStr2.EndsWith('', scOrdinalIgnoreCase));
  CheckTrue(LStr2.EndsWith('World', scOrdinalIgnoreCase));
  CheckFalse(LStr2.EndsWith('Hello World!!!!!', scOrdinalIgnoreCase));
  CheckTrue(LStr2.EndsWith('Hello World', scOrdinalIgnoreCase));
  CheckTrue(LStr2.EndsWith('world', scOrdinalIgnoreCase));
  CheckFalse(LStr2.EndsWith(' ', scOrdinalIgnoreCase));
  CheckFalse(LStr2.EndsWith('_', scOrdinalIgnoreCase));
  CheckFalse(LStr3.EndsWith(#0, scOrdinalIgnoreCase));
  CheckTrue(LStr3.EndsWith(#0'blam', scOrdinalIgnoreCase));
  CheckFalse(LStr3.EndsWith('Boom!', scOrdinalIgnoreCase));
  CheckTrue(LStr4.EndsWith('вопрос', scOrdinalIgnoreCase));
  CheckTrue(LStr4.EndsWith('ВоПрос', scOrdinalIgnoreCase));
  CheckTrue(LStr4.EndsWith('рос', scOrdinalIgnoreCase));
  CheckFalse(LStr4.EndsWith('Во', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_Enumerator;
var
  LString: TString;
  C: Char;
  X: Integer;
begin
  LString := 'abc';

  X := 0;

  for C in LString do
  begin
    if X = 0 then
       CheckEquals('a', C, 'Enumerator failed at 0!')
    else if X = 1 then
       CheckEquals('b', C, 'Enumerator failed at 0!')
    else if X = 2 then
       CheckEquals('c', C, 'Enumerator failed at 0!')
    else
       Fail('Enumerator failed!');

    Inc(X);
  end;
end;

procedure TTestString.Test_Equal;
begin
  CheckTrue(TString.Equal('Hello', 'Hello'));
  CheckTrue(TString.Equal('тестинг', 'тестинг'));

  CheckFalse(TString.Equal('Hello', 'helLo'));
  CheckFalse(TString.Equal('тестинг', 'ТесТинг'));

  CheckFalse(TString.Equal('Hello', 'helLo', scLocale));
  CheckFalse(TString.Equal('тестинг', 'ТесТинг', scLocale));

  CheckTrue(TString.Equal('Hello', 'helLo', scLocaleIgnoreCase));
  CheckTrue(TString.Equal('тестинг', 'ТесТинг', scLocaleIgnoreCase));

  CheckFalse(TString.Equal('Hello', 'helLo', scInvariant));
  CheckFalse(TString.Equal('тестинг', 'ТесТинг', scInvariant));

  CheckTrue(TString.Equal('Hello', 'helLo', scInvariantIgnoreCase));
  CheckTrue(TString.Equal('тестинг', 'ТесТинг', scInvariantIgnoreCase));

  CheckFalse(TString.Equal('Hello', 'helLo', scOrdinal));
  CheckFalse(TString.Equal('тестинг', 'ТесТинг', scOrdinal));

  CheckTrue(TString.Equal('Hello', 'helLo', scOrdinalIgnoreCase));
  CheckTrue(TString.Equal('тестинг', 'ТесТинг', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_EqualsWith;
begin
  CheckTrue(U('Hello').EqualsWith('Hello'));
  CheckTrue(U('тестинг').EqualsWith('тестинг'));

  CheckFalse(U('Hello').EqualsWith('helLo'));
  CheckFalse(U('тестинг').EqualsWith('ТесТинг'));

  CheckFalse(U('Hello').EqualsWith('helLo', scLocale));
  CheckFalse(U('тестинг').EqualsWith('ТесТинг', scLocale));

  CheckTrue(U('Hello').EqualsWith('helLo', scLocaleIgnoreCase));
  CheckTrue(U('тестинг').EqualsWith('ТесТинг', scLocaleIgnoreCase));

  CheckFalse(U('Hello').EqualsWith('helLo', scInvariant));
  CheckFalse(U('тестинг').EqualsWith('ТесТинг', scInvariant));

  CheckTrue(U('Hello').EqualsWith('helLo', scInvariantIgnoreCase));
  CheckTrue(U('тестинг').EqualsWith('ТесТинг', scInvariantIgnoreCase));

  CheckFalse(U('Hello').EqualsWith('helLo', scOrdinal));
  CheckFalse(U('тестинг').EqualsWith('ТесТинг', scOrdinal));

  CheckTrue(U('Hello').EqualsWith('helLo', scOrdinalIgnoreCase));
  CheckTrue(U('тестинг').EqualsWith('ТесТинг', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_Format;
begin
  CheckEquals('-10-Haha', TString.Format('%d-%s', [-10, 'Haha']).ToString);
end;

procedure TTestString.Test_Format_FmtSettings;
begin
  CheckEquals('-10-Haha', TString.Format('%d-%s', [-10, 'Haha'], FormatSettings).ToString);
end;

procedure TTestString.Test_FromUCS4String;
var
  LString: TString;
  LUcs4: UCS4String;
begin
  LUcs4 := UnicodeStringToUCS4String('тестинг');
  LString := TString.FromUCS4String(LUcs4);
  CheckEquals('тестинг', LString.ToString, 'Expected proper russian');

  LUcs4 := UnicodeStringToUCS4String('');
  LString := TString.FromUCS4String(LUcs4);
  CheckEquals('', LString.ToString, 'Expected proper empty');
end;

procedure TTestString.Test_FromUTF8String;
var
  LString: TString;
  LUtf8: RawByteString;
begin
  LUtf8 := UTF8Encode('тестинг');
  LString := TString.FromUTF8String(LUtf8);
  CheckEquals('тестинг', LString.ToString, 'Expected proper russian');

  LUtf8 := UTF8Encode('');
  LString := TString.FromUTF8String(LUtf8);
  CheckEquals('', LString.ToString, 'Expected proper empty');
end;

procedure TTestString.Test_IndexOf;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := 'Hello World';
  LStr3 := 'Boom!'#0'Blam';
  LStr4 := 'вопрос';

  { Default }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(''));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(' '));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf(''));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOf('l'));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello'));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('Hello World!!!!!'));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello World'));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('hello World'));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOf(' '));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('_'));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOf(#0));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOf('Blam'));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('вопрос'));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('ВоПрос'));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('рос'));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('Рос'));

  { scLocale }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf('', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(' ', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('', scLocale));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOf('l', scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('Hello World!!!!!', scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello World', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('hello World', scLocale));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOf(' ', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('_', scLocale));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOf(#0, scLocale));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOf('Blam', scLocale));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('вопрос', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('ВоПрос', scLocale));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('рос', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('Рос', scLocale));

  { scLocaleIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf('', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(' ', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOf('l', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('Hello World!!!!!', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello World', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('hello World', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOf(' ', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('_', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOf(#0, scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOf('Blam', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('вопрос', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('ВоПрос', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('рос', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('Рос', scLocaleIgnoreCase));

  { scInvariant }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf('', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(' ', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('', scInvariant));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOf('l', scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('Hello World!!!!!', scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello World', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('hello World', scInvariant));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOf(' ', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('_', scInvariant));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOf(#0, scInvariant));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOf('Blam', scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('вопрос', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('ВоПрос', scInvariant));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('рос', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('Рос', scInvariant));

  { scInvariantIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf('', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(' ', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOf('l', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('Hello World!!!!!', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello World', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('hello World', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOf(' ', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('_', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOf(#0, scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOf('Blam', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('вопрос', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('ВоПрос', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('рос', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('Рос', scInvariantIgnoreCase));

  { scOrdinal }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf('', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(' ', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOf('l', scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('Hello World!!!!!', scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello World', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('hello World', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOf(' ', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('_', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOf(#0, scOrdinal));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOf('Blam', scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('вопрос', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('ВоПрос', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('рос', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOf('Рос', scOrdinal));

  { scOrdinalIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf('', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOf(' ', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOf('l', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('Hello World!!!!!', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('Hello World', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOf('hello World', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOf(' ', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOf('_', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOf(#0, scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOf('Blam', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('вопрос', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOf('ВоПрос', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('рос', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOf('Рос', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_IndexOfAny;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := 'Hello World';
  LStr3 := 'Boom!'#0'Blam';
  LStr4 := 'вопрос';

  { Default }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny(['']));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([' ', 'W']));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['']));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOfAny(['l', 'o']));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['He', 'Hello', '']));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['Hello World!!!!!']));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['Hello World']));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.IndexOfAny(['hello', 'World']));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOfAny([' ', 'W']));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['_', '...', '-']));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOfAny([#0]));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOfAny(['Blam', 'boom']));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['вопрос']));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOfAny(['ВоПрос', 'вопРос']));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOfAny(['рос', 'Рос']));

  { scLocale }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([''], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([' ', 'W'], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny([''], scLocale));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOfAny(['l', 'o'], scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['He', 'Hello', ''], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['Hello World!!!!!'], scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['Hello World'], scLocale));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.IndexOfAny(['hello', 'World'], scLocale));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOfAny([' ', 'W'], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['_', '...', '-'], scLocale));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOfAny([#0], scLocale));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOfAny(['Blam', 'boom'], scLocale));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['вопрос'], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOfAny(['ВоПрос', 'вопРос'], scLocale));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOfAny(['рос', 'Рос'], scLocale));

  { scLocaleIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([''], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([' ', 'W'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny([''], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOfAny(['l', 'o'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['He', 'Hello', ''], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['Hello World!!!!!'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['Hello World'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['hello', 'World'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOfAny([' ', 'W'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['_', '...', '-'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOfAny([#0], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr3.IndexOfAny(['Blam', 'boom'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['вопрос'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['ВоПрос', 'вопРос'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOfAny(['рос', 'Рос'], scLocaleIgnoreCase));

  { scInvariant }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([''], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([' ', 'W'], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny([''], scInvariant));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOfAny(['l', 'o'], scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['He', 'Hello', ''], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['Hello World!!!!!'], scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['Hello World'], scInvariant));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.IndexOfAny(['hello', 'World'], scInvariant));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOfAny([' ', 'W'], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['_', '...', '-'], scInvariant));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOfAny([#0], scInvariant));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOfAny(['Blam', 'boom'], scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['вопрос'], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOfAny(['ВоПрос', 'вопРос'], scInvariant));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOfAny(['рос', 'Рос'], scInvariant));

  { scInvariantIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([''], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([' ', 'W'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny([''], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOfAny(['l', 'o'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['He', 'Hello', ''], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['Hello World!!!!!'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['Hello World'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['hello', 'World'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOfAny([' ', 'W'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['_', '...', '-'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOfAny([#0], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr3.IndexOfAny(['Blam', 'boom'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['вопрос'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['ВоПрос', 'вопРос'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOfAny(['рос', 'Рос'], scInvariantIgnoreCase));

  { scOrdinal }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([''], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([' ', 'W'], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny([''], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOfAny(['l', 'o'], scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['He', 'Hello', ''], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['Hello World!!!!!'], scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['Hello World'], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.IndexOfAny(['hello', 'World'], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOfAny([' ', 'W'], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['_', '...', '-'], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOfAny([#0], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.IndexOfAny(['Blam', 'boom'], scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['вопрос'], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.IndexOfAny(['ВоПрос', 'вопРос'], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOfAny(['рос', 'Рос'], scOrdinal));

  { scOrdinalIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([''], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.IndexOfAny([' ', 'W'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny([''], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 2, LStr2.IndexOfAny(['l', 'o'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['He', 'Hello', ''], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['Hello World!!!!!'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['Hello World'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.IndexOfAny(['hello', 'World'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.IndexOfAny([' ', 'W'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.IndexOfAny(['_', '...', '-'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.IndexOfAny([#0], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr3.IndexOfAny(['Blam', 'boom'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['вопрос'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.IndexOfAny(['ВоПрос', 'вопРос'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.IndexOfAny(['рос', 'Рос'], scOrdinalIgnoreCase));
end;

procedure TTestString.Test_Insert;
begin
  CheckEquals('Haha', U('').Insert(CFirstCharacterIndex, 'Haha'));
  CheckEquals('on--e', U('one').Insert(CFirstCharacterIndex + 2, '--'));
  CheckEquals('o..ne', U('one').Insert(CFirstCharacterIndex + 1, '..'));
  CheckEquals('one...', U('one').Insert(CFirstCharacterIndex + 3, '...'));

{$IFDEF TSTRING_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Insert(CFirstCharacterIndex - 1, ''); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Insert(CFirstCharacterIndex + 4, '...'); end,
    'EArgumentOutOfRangeException not thrown in 3.'
  );
{$ENDIF}
end;

procedure TTestString.Test_IsEmpty;
var
  LString: TString;
begin
  LString := '';
  CheckTrue(LString.IsEmpty);

  LString := #0;
  CheckFalse(LString.IsEmpty);

  LString := 'Blah blah';
  CheckFalse(LString.IsEmpty);
end;

procedure TTestString.Test_IsWhiteSpace;
var
  LString: TString;
begin
  LString := '';
  CheckTrue(LString.IsWhiteSpace);

  LString := #0;
  CheckFalse(LString.IsWhiteSpace);

  LString := '  ';
  CheckTrue(LString.IsWhiteSpace);

  LString := '  '#9#9;
  CheckTrue(LString.IsWhiteSpace);

  LString := '       .    ';
  CheckFalse(LString.IsWhiteSpace);
end;

procedure TTestString.Test_Join_Array;
var
  LOut: TString;
  LExp: string;
  I, X: Integer;
  LStrs: TArray<string>;
begin
  LOut := '';

  for I := 1 to 10 do
  begin
    SetLength(LStrs, I);
    LExp := '';
    for X := 0 to I - 1 do
    begin
      if X = 0 then
        LExp := 'A'
      else
        LExp := LExp + '..//..' + Chr(Ord('A') + X);

      LStrs[X] := Chr(Ord('A') + X);
    end;

    LOut := TString.Join('..//..', LStrs);

    CheckEquals(LExp, LOut.ToString, U('iteration = ') + I);
  end;
end;

procedure TTestString.Test_Join_IEnumerable;
var
  LList: TList<string>;
begin
  LList := TList<string>.Create;
  CheckEquals('', TString.Join('--', LList).ToString);

  LList.Add('I');
  LList.Add('am');
  LList.Add('list');
  CheckEquals('I/и/am/и/list', TString.Join('/и/', LList).ToString);

  LList.Free;
end;

procedure TTestString.Test_LastIndexOf;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := 'Hello World';
  LStr3 := 'Boom!'#0'Blam';
  LStr4 := 'вопрос';

  { Default }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(''));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(' '));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf(''));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOf('l'));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello'));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('Hello World!!!!!'));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello World'));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('hello World'));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.LastIndexOf(' '));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('_'));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOf(#0));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOf('Blam'));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('вопрос'));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('ВоПрос'));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('рос'));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('Рос'));

  { scLocale }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf('', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(' ', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('', scLocale));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOf('l', scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('Hello World!!!!!', scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello World', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('hello World', scLocale));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.LastIndexOf(' ', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('_', scLocale));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOf(#0, scLocale));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOf('Blam', scLocale));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('вопрос', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('ВоПрос', scLocale));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('рос', scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('Рос', scLocale));

  { scLocaleIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf('', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(' ', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOf('l', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('Hello World!!!!!', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello World', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('hello World', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.LastIndexOf(' ', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('_', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOf(#0, scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOf('Blam', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('вопрос', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('ВоПрос', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('рос', scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('Рос', scLocaleIgnoreCase));

  { scInvariant }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf('', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(' ', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('', scInvariant));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOf('l', scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('Hello World!!!!!', scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello World', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('hello World', scInvariant));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.LastIndexOf(' ', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('_', scInvariant));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOf(#0, scInvariant));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOf('Blam', scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('вопрос', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('ВоПрос', scInvariant));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('рос', scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('Рос', scInvariant));

  { scInvariantIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf('', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(' ', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOf('l', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('Hello World!!!!!', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello World', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('hello World', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.LastIndexOf(' ', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('_', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOf(#0, scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOf('Blam', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('вопрос', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('ВоПрос', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('рос', scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('Рос', scInvariantIgnoreCase));

  { scOrdinal }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf('', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(' ', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOf('l', scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('Hello World!!!!!', scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello World', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('hello World', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.LastIndexOf(' ', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('_', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOf(#0, scOrdinal));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOf('Blam', scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('вопрос', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('ВоПрос', scOrdinal));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('рос', scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOf('Рос', scOrdinal));

  { scOrdinalIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf('', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOf(' ', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOf('l', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('Hello World!!!!!', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('Hello World', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOf('hello World', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr2.LastIndexOf(' ', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOf('_', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOf(#0, scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOf('Blam', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('вопрос', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOf('ВоПрос', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('рос', scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOf('Рос', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_LastIndexOfAny;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := 'Hello World';
  LStr3 := 'Boom!'#0'Blam';
  LStr4 := 'вопрос';

  { Default }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny(['']));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([' ', 'W']));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['']));
  CheckEquals(CFirstCharacterIndex + 7, LStr2.LastIndexOfAny(['L', 'o']));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['He', 'Hello']));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['Hello World!!!!!']));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['Hello World']));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny(['hello', 'World', '']));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny([' ', 'W']));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['_', '...', '-']));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOfAny([#0]));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOfAny(['Blam', 'boom']));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['вопрос']));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOfAny(['ВоПрос', 'вопРос']));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOfAny(['рос', 'Рос']));

  { scLocale }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([''], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([' ', 'W'], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny([''], scLocale));
  CheckEquals(CFirstCharacterIndex + 7, LStr2.LastIndexOfAny(['L', 'o'], scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['He', 'Hello'], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['Hello World!!!!!'], scLocale));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['Hello World'], scLocale));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny(['hello', 'World', ''], scLocale));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny([' ', 'W'], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['_', '...', '-'], scLocale));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOfAny([#0], scLocale));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOfAny(['Blam', 'boom'], scLocale));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['вопрос'], scLocale));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOfAny(['ВоПрос', 'вопРос'], scLocale));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOfAny(['рос', 'Рос'], scLocale));

  { scLocaleIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([''], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([' ', 'W'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny([''], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOfAny(['L', 'o'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['He', 'Hello'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['Hello World!!!!!'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['Hello World'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny(['hello', 'World', ''], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny([' ', 'W'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['_', '...', '-'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOfAny([#0], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOfAny(['Blam', 'boom'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['вопрос'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['ВоПрос', 'вопРос'], scLocaleIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOfAny(['рос', 'Рос'], scLocaleIgnoreCase));

  { scInvariant }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([''], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([' ', 'W'], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny([''], scInvariant));
  CheckEquals(CFirstCharacterIndex + 7, LStr2.LastIndexOfAny(['L', 'o'], scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['He', 'Hello'], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['Hello World!!!!!'], scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['Hello World'], scInvariant));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny(['hello', 'World', ''], scInvariant));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny([' ', 'W'], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['_', '...', '-'], scInvariant));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOfAny([#0], scInvariant));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOfAny(['Blam', 'boom'], scInvariant));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['вопрос'], scInvariant));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOfAny(['ВоПрос', 'вопРос'], scInvariant));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOfAny(['рос', 'Рос'], scInvariant));

  { scInvariantIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([''], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([' ', 'W'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny([''], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOfAny(['L', 'o'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['He', 'Hello'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['Hello World!!!!!'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['Hello World'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny(['hello', 'World', ''], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny([' ', 'W'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['_', '...', '-'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOfAny([#0], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOfAny(['Blam', 'boom'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['вопрос'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['ВоПрос', 'вопРос'], scInvariantIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOfAny(['рос', 'Рос'], scInvariantIgnoreCase));

  { scOrdinal }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([''], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([' ', 'W'], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny([''], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 7, LStr2.LastIndexOfAny(['L', 'o'], scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['He', 'Hello'], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['Hello World!!!!!'], scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['Hello World'], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny(['hello', 'World', ''], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny([' ', 'W'], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['_', '...', '-'], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOfAny([#0], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOfAny(['Blam', 'boom'], scOrdinal));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['вопрос'], scOrdinal));
  CheckEquals(CFirstCharacterIndex - 1, LStr4.LastIndexOfAny(['ВоПрос', 'вопРос'], scOrdinal));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOfAny(['рос', 'Рос'], scOrdinal));

  { scOrdinalIgnoreCase }
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([''], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr1.LastIndexOfAny([' ', 'W'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny([''], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 9, LStr2.LastIndexOfAny(['L', 'o'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['He', 'Hello'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['Hello World!!!!!'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr2.LastIndexOfAny(['Hello World'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny(['hello', 'World', ''], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr2.LastIndexOfAny([' ', 'W'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex - 1, LStr2.LastIndexOfAny(['_', '...', '-'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 5, LStr3.LastIndexOfAny([#0], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 6, LStr3.LastIndexOfAny(['Blam', 'boom'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['вопрос'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex, LStr4.LastIndexOfAny(['ВоПрос', 'вопРос'], scOrdinalIgnoreCase));
  CheckEquals(CFirstCharacterIndex + 3, LStr4.LastIndexOfAny(['рос', 'Рос'], scOrdinalIgnoreCase));
end;

procedure TTestString.Test_Length;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := #0;
  LStr3 := 'Hello World!';
  LStr4 := 'тестинг';

  CheckEquals(0, LStr1.Length);
  CheckEquals(1, LStr2.Length);
  CheckEquals(12, LStr3.Length);
  CheckEquals(7, LStr4.Length);
end;

procedure TTestString.Test_Op_Add_Boolean;
var
  LT: TString;
  LS: string;
begin
  LT := U('It is ') + True;
  LS := 'It is ' + SysUtils.BoolToStr(True, True);
  CheckEquals(LS, LT.ToString);

  LT := U('It is ') + False;
  LS := 'It is ' + SysUtils.BoolToStr(False, True);
  CheckEquals(LS, LT.ToString);

  LT := True + U(' is the value');
  LS := SysUtils.BoolToStr(True, True) + ' is the value';
  CheckEquals(LS, LT.ToString);

  LT := False + U(' is the value');
  LS := SysUtils.BoolToStr(False, True) + ' is the value';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_Cardinal;
var
  LT: TString;
  LS: string;
begin
  LT := U('--') + Cardinal(0);
  LS := '--' + UIntToStr(Cardinal(0));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + Cardinal(High(Cardinal));
  LS := '--' + UIntToStr(Cardinal(High(Cardinal)));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + Cardinal(Low(Cardinal));
  LS := '--' + UIntToStr(Cardinal(Low(Cardinal)));
  CheckEquals(LS, LT.ToString);


  LT := Cardinal(0) + U('--');
  LS := UIntToStr(Cardinal(0)) + '--';
  CheckEquals(LS, LT.ToString);

  LT := Cardinal(High(Cardinal)) + U('--');
  LS := UIntToStr(Cardinal(High(Cardinal))) + '--';
  CheckEquals(LS, LT.ToString);

  LT := Cardinal(Low(Cardinal)) + U('--');
  LS := UIntToStr(Cardinal(Low(Cardinal))) + '--';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_Char;
var
  LString: TString;
begin
  LString := 'The char is ';
  LString := LString + Char('т');

  CheckEquals('The char is т', LString.ToString);

  LString := ' is the char';
  LString := Char('т') + LString;

  CheckEquals('т is the char', LString.ToString);
end;

procedure TTestString.Test_Op_Add_Currency;
var
  LT: TString;
  LS: string;
begin
  LT := U('--') + FloatToCurr(0.0);
  LS := '--' + CurrToStr(0.0);
  CheckEquals(LS, LT.ToString);

  LT := U('--') + FloatToCurr(16662.25676512);
  LS := '--' + CurrToStr(16662.25676512);
  CheckEquals(LS, LT.ToString);

  LT := U('--') + FloatToCurr(-16662.25676512);
  LS := '--' + CurrToStr(-16662.25676512);
  CheckEquals(LS, LT.ToString);

  LT := FloatToCurr(0) + U('--');
  LS := CurrToStr(0) + '--';
  CheckEquals(LS, LT.ToString);

  LT := FloatToCurr(16662.25676512) + U('--');
  LS := CurrToStr(16662.25676512) + '--';
  CheckEquals(LS, LT.ToString);

  LT := FloatToCurr(-16662.25676512) + U('--');
  LS := CurrToStr(-16662.25676512) + '--';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_Extended;
var
  LT: TString;
  LS: string;
begin
  LT := U('--') + 0.0;
  LS := '--' + FloatToStr(0.0);
  CheckEquals(LS, LT.ToString);

  LT := U('--') + 16662.25676512;
  LS := '--' + FloatToStr(16662.25676512);
  CheckEquals(LS, LT.ToString);

  LT := U('--') + -16662.25676512;
  LS := '--' + FloatToStr(-16662.25676512);
  CheckEquals(LS, LT.ToString);

  LT := 0.0 + U('--');
  LS := FloatToStr(0) + '--';
  CheckEquals(LS, LT.ToString);

  LT := 16662.25676512 + U('--');
  LS := FloatToStr(16662.25676512) + '--';
  CheckEquals(LS, LT.ToString);

  LT := -16662.25676512 + U('--');
  LS := FloatToStr(-16662.25676512) + '--';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_Int64;
var
  LT: TString;
  LS: string;
begin
  LT := U('--') + Int64(0);
  LS := '--' + IntToStr(Int64(0));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + Int64(High(Int64));
  LS := '--' + IntToStr(Int64(High(Int64)));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + Int64(Low(Int64));
  LS := '--' + IntToStr(Int64(Low(Int64)));
  CheckEquals(LS, LT.ToString);


  LT := Int64(0) + U('--');
  LS := IntToStr(Int64(0)) + '--';
  CheckEquals(LS, LT.ToString);

  LT := Int64(High(Int64)) + U('--');
  LS := IntToStr(Int64(High(Int64))) + '--';
  CheckEquals(LS, LT.ToString);

  LT := Int64(Low(Int64)) + U('--');
  LS := IntToStr(Int64(Low(Int64))) + '--';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_Integer;
var
  LT: TString;
  LS: string;
begin
  LT := U('--') + Integer(0);
  LS := '--' + IntToStr(Integer(0));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + Integer(High(Integer));
  LS := '--' + IntToStr(Integer(High(Integer)));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + Integer(Low(Integer));
  LS := '--' + IntToStr(Integer(Low(Integer)));
  CheckEquals(LS, LT.ToString);


  LT := Integer(0) + U('--');
  LS := IntToStr(Integer(0)) + '--';
  CheckEquals(LS, LT.ToString);

  LT := Integer(High(Integer)) + U('--');
  LS := IntToStr(Integer(High(Integer))) + '--';
  CheckEquals(LS, LT.ToString);

  LT := Integer(Low(Integer)) + U('--');
  LS := IntToStr(Integer(Low(Integer))) + '--';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_TDate;
var
  LT: TString;
  LS: string;
  LNow: TDate;
begin
  LNow := Now;
  LT := U('It is ') + LNow;
  LS := 'It is ' + DateToStr(LNow);
  CheckEquals(LS, LT.ToString);

  LT := LNow + U(' is the time');
  LS := DateToStr(LNow) + ' is the time';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_TDateTime;
var
  LT: TString;
  LS: string;
  LNow: TDateTime;
begin
  LNow := Now;
  LT := U('It is ') + LNow;
  LS := 'It is ' + DateTimeToStr(LNow);
  CheckEquals(LS, LT.ToString);

  LT := LNow + U(' is the time');
  LS := DateTimeToStr(LNow) + ' is the time';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_TString;
var
  LString: TString;
begin
  LString := U('Hello') + ' ' + U('World');
  CheckEquals('Hello World', LString.ToString);

  LString := 'Blah' + U('') + ' is the ' + U('Word');
  CheckEquals('Blah is the Word', LString.ToString);
end;

procedure TTestString.Test_Op_Add_TTime;
var
  LT: TString;
  LS: string;
  LNow: TTime;
begin
  LNow := Now;
  LT := U('It is ') + LNow;
  LS := 'It is ' + TimeToStr(LNow);
  CheckEquals(LS, LT.ToString);

  LT := LNow + U(' is the time');
  LS := TimeToStr(LNow) + ' is the time';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_UInt64;
var
  LT: TString;
  LS: string;
begin
  LT := U('--') + UInt64(0);
  LS := '--' + UIntToStr(UInt64(0));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + UInt64(High(UInt64));
  LS := '--' + UIntToStr(UInt64(High(UInt64)));
  CheckEquals(LS, LT.ToString);

  LT := U('--') + UInt64(Low(UInt64));
  LS := '--' + UIntToStr(UInt64(Low(UInt64)));
  CheckEquals(LS, LT.ToString);


  LT := UInt64(0) + U('--');
  LS := UIntToStr(UInt64(0)) + '--';
  CheckEquals(LS, LT.ToString);

  LT := UInt64(High(UInt64)) + U('--');
  LS := UIntToStr(UInt64(High(UInt64))) + '--';
  CheckEquals(LS, LT.ToString);

  LT := UInt64(Low(UInt64)) + U('--');
  LS := UIntToStr(UInt64(Low(UInt64))) + '--';
  CheckEquals(LS, LT.ToString);
end;

procedure TTestString.Test_Op_Add_Variant;
var
  LString: TString;
begin
  LString := U('Hello') + ' ' + Variant('World');
  CheckEquals('Hello World', LString.ToString);

  LString := OleVariant('Blah') + U('') + ' is the ' + OleVariant('Word');
  CheckEquals('Blah is the Word', LString.ToString);
end;

procedure TTestString.Test_Op_Equal;
begin
  CheckTrue(U('') = U(''));
  CheckTrue(U('123') = U('123'));
  CheckTrue(U('abc') = U('abc'));
  CheckFalse(U('abc') = U('ABC'));
  CheckTrue(U('тестинг') = U('тестинг'));
  CheckFalse(U('тестинг') = U('ТЕСтинГ'));
  CheckFalse(U('') = U('123'));
end;

procedure TTestString.Test_Op_Implicit_FromString;
var
  LString: string;
  LVal: TString;
begin
  LString := 'Hello World';
  LVal := LString;
  CheckEquals('Hello World', LVal.ToString);

  LString := '';
  LVal := LString;
  CheckEquals('', LVal.ToString);

  LString := #0;
  LVal := LString;
  CheckEquals(#0, LVal.ToString);
end;

procedure TTestString.Test_Op_Implicit_ToString;
var
  LString: TString;
  LVal: string;
begin
  LString := TString.Create('Hello World');
  LVal := LString;
  CheckEquals('Hello World', LVal);

  LString := TString.Create('');
  LVal := LString;
  CheckEquals('', LVal);

  LString := TString.Create(#0);
  LVal := LString;
  CheckEquals(#0, LVal);
end;

procedure TTestString.Test_Op_Implicit_ToVariant;
var
  LVar: Variant;
  LOleVar: OleVariant;
begin
  LVar := U('тестинг');
  CheckEquals('тестинг', string(LVar));

  LOleVar := U('тестинг');
  CheckEquals('тестинг', string(LOleVar));
end;

procedure TTestString.Test_Op_Not_Equal;
begin
  CheckFalse(U('') <> U(''));
  CheckFalse(U('123') <> U('123'));
  CheckFalse(U('abc') <> U('abc'));
  CheckTrue(U('abc') <> U('ABC'));
  CheckFalse(U('тестинг') <> U('тестинг'));
  CheckTrue(U('тестинг') <> U('ТЕСтинГ'));
  CheckTrue(U('') <> U('123'));
end;

procedure TTestString.Test_PadLeft;
var
  LString: TString;
begin
  LString := TString.Create('').PadLeft(0);
  CheckEquals('', LString.ToString);

  LString := TString.Create('').PadLeft(5);
  CheckEquals('     ', LString.ToString);

  LString := TString.Create('[]').PadLeft(0, '.');
  CheckEquals('[]', LString.ToString);

  LString := TString.Create('[]').PadLeft(5, '.');
  CheckEquals('.....[]', LString.ToString);
end;

procedure TTestString.Test_PadRight;
var
  LString: TString;
begin
  LString := TString.Create('').PadRight(0);
  CheckEquals('', LString.ToString);

  LString := TString.Create('').PadRight(5);
  CheckEquals('     ', LString.ToString);

  LString := TString.Create('[]').PadRight(0, '.');
  CheckEquals('[]', LString.ToString);

  LString := TString.Create('[]').PadRight(5, '.');
  CheckEquals('[].....', LString.ToString);
end;

procedure TTestString.Test_Remove;
begin
  CheckEquals('ne', U('one').Remove(CFirstCharacterIndex, 1));
  CheckEquals('', U('one').Remove(CFirstCharacterIndex, 3));
  CheckEquals('one', U('one').Remove(CFirstCharacterIndex, 0));

{$IFDEF TSTRING_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Remove(CFirstCharacterIndex - 1, 0); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Remove(CFirstCharacterIndex, 4); end,
    'EArgumentOutOfRangeException not thrown in 4.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Remove(CFirstCharacterIndex + 3, 1); end,
    'EArgumentOutOfRangeException not thrown in 1.'
  );
{$ENDIF}
end;

procedure TTestString.Test_Remove_Start;
begin
  CheckEquals('', U('one').Remove(CFirstCharacterIndex));
  CheckEquals('o', U('one').Remove(CFirstCharacterIndex + 1));
  CheckEquals('on', U('one').Remove(CFirstCharacterIndex + 2));

{$IFDEF TSTRING_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Remove(CFirstCharacterIndex - 1); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Remove(CFirstCharacterIndex + 3); end,
    'EArgumentOutOfRangeException not thrown in +3.'
  );
{$ENDIF}
end;

procedure TTestString.Test_Replace;
var
  LInput: TString;
begin
  LInput := 'Hello Руссия';

  CheckEquals('Hello Руссия', LInput.Replace('Hello Руссия!', '...').ToString);
  CheckEquals('...', LInput.Replace('Hello Руссия', '...').ToString);
  CheckEquals('Hello Руссия', LInput.Replace('', '...').ToString);
  CheckEquals('... Руссия', LInput.Replace('Hello', '...').ToString);
  CheckEquals('Hello Руссия', LInput.Replace('HellO', '...', scLocale).ToString);
  CheckEquals('... Руссия', LInput.Replace('HellO', '...', scLocaleIgnoreCase).ToString);
  CheckEquals('Hello Руссия', LInput.Replace('HellO', '...', scInvariant).ToString);
  CheckEquals('... Руссия', LInput.Replace('HellO', '...', scInvariantIgnoreCase).ToString);
  CheckEquals('Hello Руссия', LInput.Replace('HellO', '...', scLocale).ToString);
  CheckEquals('... Руссия', LInput.Replace('HellO', '...', scOrdinalIgnoreCase).ToString);

  CheckEquals('Hello Руссия', LInput.Replace('РуссиЯ', 'Руссия', scOrdinalIgnoreCase).ToString);
  CheckEquals('Hello Руссия', LInput.Replace('Руссия', 'Руссия').ToString);
end;

procedure TTestString.Test_Replace_Char;
begin
  CheckEquals('', U('').Replace(Char('.'), Char('x')));
  CheckEquals('xx', U('..').Replace(Char('.'), Char('x')));
  CheckEquals('во рос', U('вопрос').Replace(Char('п'), Char(' ')));
end;

procedure TTestString.Test_Reverse;
begin
  CheckEquals('', U('').Reverse);
  CheckEquals('4321', U('1234').Reverse);
  CheckEquals('2'#0'1', U('1'#0'2').Reverse);
end;

procedure TTestString.Test_Split_Char;
var
  LStrings: TArray<TString>;
begin
  LStrings := U('').Split(Char('.'), true);
  CheckTrue(Length(LStrings) = 0);

  LStrings := U('...').Split(Char('.'), true);
  CheckTrue(Length(LStrings) = 0);

  LStrings := U('...').Split(Char('.'));
  CheckTrue(Length(LStrings) = 4);
  CheckEquals('', LStrings[0].ToString);
  CheckEquals('', LStrings[1].ToString);
  CheckEquals('', LStrings[2].ToString);
  CheckEquals('', LStrings[3].ToString);

  LStrings := U('Hello World!').Split(Char(' '));
  CheckTrue(Length(LStrings) = 2);
  CheckEquals('Hello', LStrings[0].ToString);
  CheckEquals('World!', LStrings[1].ToString);

  LStrings := U('Hello!World!').Split(Char('!'), false);
  CheckTrue(Length(LStrings) = 3);
  CheckEquals('Hello', LStrings[0].ToString);
  CheckEquals('World', LStrings[1].ToString);
  CheckEquals('', LStrings[2].ToString);

  LStrings := U('Hello!World!').Split(Char('!'), true);
  CheckTrue(Length(LStrings) = 2);
  CheckEquals('Hello', LStrings[0].ToString);
  CheckEquals('World', LStrings[1].ToString);
end;

procedure TTestString.Test_Split_TWideCharSet;
var
  LStrings: TArray<TString>;
begin
  LStrings := U('').Split(TWideCharSet.Create(' ./'), true);
  CheckTrue(Length(LStrings) = 0);

  LStrings := U('./').Split(TWideCharSet.Create(' ./'), true);
  CheckTrue(Length(LStrings) = 0);

  LStrings := U('./ ').Split(TWideCharSet.Create(' ./'));
  CheckTrue(Length(LStrings) = 4);
  CheckEquals('', LStrings[0].ToString);
  CheckEquals('', LStrings[1].ToString);
  CheckEquals('', LStrings[2].ToString);
  CheckEquals('', LStrings[3].ToString);

  LStrings := U('Hello World!').Split(TWideCharSet.Create(' '));
  CheckTrue(Length(LStrings) = 2);
  CheckEquals('Hello', LStrings[0].ToString);
  CheckEquals('World!', LStrings[1].ToString);

  LStrings := U('Hello World!').Split(TWideCharSet.Create(' !'), false);
  CheckTrue(Length(LStrings) = 3);
  CheckEquals('Hello', LStrings[0].ToString);
  CheckEquals('World', LStrings[1].ToString);
  CheckEquals('', LStrings[2].ToString);

  LStrings := U('Hello World!').Split(TWideCharSet.Create(' !'), true);
  CheckTrue(Length(LStrings) = 2);
  CheckEquals('Hello', LStrings[0].ToString);
  CheckEquals('World', LStrings[1].ToString);
end;

procedure TTestString.Test_StartsWith;
var
  LStr1, LStr2, LStr3, LStr4: TString;
begin
  LStr1 := '';
  LStr2 := 'Hello World';
  LStr3 := 'Boom!'#0'Blam';
  LStr4 := 'вопрос';

  { Default }
  CheckFalse(LStr1.StartsWith(''));
  CheckFalse(LStr1.StartsWith(' '));
  CheckFalse(LStr2.StartsWith(''));
  CheckTrue(LStr2.StartsWith('Hello'));
  CheckFalse(LStr2.StartsWith('Hello World!!!!!'));
  CheckTrue(LStr2.StartsWith('Hello World'));
  CheckFalse(LStr2.StartsWith('hello'));
  CheckFalse(LStr2.StartsWith(' '));
  CheckFalse(LStr2.StartsWith('_'));
  CheckFalse(LStr3.StartsWith(#0));
  CheckTrue(LStr3.StartsWith('Boom!'#0));
  CheckFalse(LStr3.StartsWith('Blam'));
  CheckTrue(LStr4.StartsWith('вопрос'));
  CheckFalse(LStr4.StartsWith('ВоПрос'));
  CheckFalse(LStr4.StartsWith('рос'));

  { scLocale }
  CheckFalse(LStr1.StartsWith('', scLocale));
  CheckFalse(LStr1.StartsWith(' ', scLocale));
  CheckFalse(LStr2.StartsWith('', scLocale));
  CheckTrue(LStr2.StartsWith('Hello', scLocale));
  CheckFalse(LStr2.StartsWith('Hello World!!!!!', scLocale));
  CheckTrue(LStr2.StartsWith('Hello World', scLocale));
  CheckFalse(LStr2.StartsWith('hello', scLocale));
  CheckFalse(LStr2.StartsWith(' ', scLocale));
  CheckFalse(LStr2.StartsWith('_', scLocale));
  CheckFalse(LStr3.StartsWith(#0, scLocale));
  CheckFalse(LStr3.StartsWith('boom!'#0, scLocale));
  CheckFalse(LStr3.StartsWith('Blam', scLocale));
  CheckTrue(LStr4.StartsWith('вопрос', scLocale));
  CheckFalse(LStr4.StartsWith('ВоПрос', scLocale));
  CheckFalse(LStr4.StartsWith('рос', scLocale));

  { scLocaleIgnoreCase }
  CheckFalse(LStr1.StartsWith('', scLocaleIgnoreCase));
  CheckFalse(LStr1.StartsWith(' ', scLocaleIgnoreCase));
  CheckFalse(LStr2.StartsWith('', scLocaleIgnoreCase));
  CheckTrue(LStr2.StartsWith('Hello', scLocaleIgnoreCase));
  CheckFalse(LStr2.StartsWith('Hello World!!!!!', scLocaleIgnoreCase));
  CheckTrue(LStr2.StartsWith('Hello World', scLocaleIgnoreCase));
  CheckTrue(LStr2.StartsWith('hello', scLocaleIgnoreCase));
  CheckFalse(LStr2.StartsWith(' ', scLocaleIgnoreCase));
  CheckFalse(LStr2.StartsWith('_', scLocaleIgnoreCase));
  CheckFalse(LStr3.StartsWith(#0, scLocaleIgnoreCase));
  CheckTrue(LStr3.StartsWith('boom!'#0, scLocaleIgnoreCase));
  CheckFalse(LStr3.StartsWith('Blam', scLocaleIgnoreCase));
  CheckTrue(LStr4.StartsWith('вопрос', scLocaleIgnoreCase));
  CheckTrue(LStr4.StartsWith('ВоПрос', scLocaleIgnoreCase));
  CheckFalse(LStr4.StartsWith('рос', scLocaleIgnoreCase));

  { scInvariant }
  CheckFalse(LStr1.StartsWith('', scInvariant));
  CheckFalse(LStr1.StartsWith(' ', scInvariant));
  CheckFalse(LStr2.StartsWith('', scInvariant));
  CheckTrue(LStr2.StartsWith('Hello', scInvariant));
  CheckFalse(LStr2.StartsWith('Hello World!!!!!', scInvariant));
  CheckTrue(LStr2.StartsWith('Hello World', scInvariant));
  CheckFalse(LStr2.StartsWith('hello', scInvariant));
  CheckFalse(LStr2.StartsWith(' ', scInvariant));
  CheckFalse(LStr2.StartsWith('_', scInvariant));
  CheckFalse(LStr3.StartsWith(#0, scInvariant));
  CheckFalse(LStr3.StartsWith('boom!'#0, scInvariant));
  CheckFalse(LStr3.StartsWith('Blam', scInvariant));
  CheckTrue(LStr4.StartsWith('вопрос', scInvariant));
  CheckFalse(LStr4.StartsWith('ВоПрос', scInvariant));
  CheckFalse(LStr4.StartsWith('рос', scInvariant));

  { scInvariantIgnoreCase }
  CheckFalse(LStr1.StartsWith('', scInvariantIgnoreCase));
  CheckFalse(LStr1.StartsWith(' ', scInvariantIgnoreCase));
  CheckFalse(LStr2.StartsWith('', scInvariantIgnoreCase));
  CheckTrue(LStr2.StartsWith('Hello', scInvariantIgnoreCase));
  CheckFalse(LStr2.StartsWith('Hello World!!!!!', scInvariantIgnoreCase));
  CheckTrue(LStr2.StartsWith('Hello World', scInvariantIgnoreCase));
  CheckTrue(LStr2.StartsWith('hello', scInvariantIgnoreCase));
  CheckFalse(LStr2.StartsWith(' ', scInvariantIgnoreCase));
  CheckFalse(LStr2.StartsWith('_', scInvariantIgnoreCase));
  CheckFalse(LStr3.StartsWith(#0, scInvariantIgnoreCase));
  CheckTrue(LStr3.StartsWith('boom!'#0, scInvariantIgnoreCase));
  CheckFalse(LStr3.StartsWith('Blam', scInvariantIgnoreCase));
  CheckTrue(LStr4.StartsWith('вопрос', scInvariantIgnoreCase));
  CheckTrue(LStr4.StartsWith('ВоПрос', scInvariantIgnoreCase));
  CheckFalse(LStr4.StartsWith('рос', scInvariantIgnoreCase));

  { scOrdinal }
  CheckFalse(LStr1.StartsWith('', scOrdinal));
  CheckFalse(LStr1.StartsWith(' ', scOrdinal));
  CheckFalse(LStr2.StartsWith('', scOrdinal));
  CheckTrue(LStr2.StartsWith('Hello', scOrdinal));
  CheckFalse(LStr2.StartsWith('Hello World!!!!!', scOrdinal));
  CheckTrue(LStr2.StartsWith('Hello World', scOrdinal));
  CheckFalse(LStr2.StartsWith('hello', scOrdinal));
  CheckFalse(LStr2.StartsWith(' ', scOrdinal));
  CheckFalse(LStr2.StartsWith('_', scOrdinal));
  CheckFalse(LStr3.StartsWith(#0, scOrdinal));
  CheckFalse(LStr3.StartsWith('boom!'#0, scOrdinal));
  CheckFalse(LStr3.StartsWith('Blam', scOrdinal));
  CheckTrue(LStr4.StartsWith('вопрос', scOrdinal));
  CheckFalse(LStr4.StartsWith('ВоПрос', scOrdinal));
  CheckFalse(LStr4.StartsWith('рос', scOrdinal));

  { scOrdinalIgnoreCase }
  CheckFalse(LStr1.StartsWith('', scOrdinalIgnoreCase));
  CheckFalse(LStr1.StartsWith(' ', scOrdinalIgnoreCase));
  CheckFalse(LStr2.StartsWith('', scOrdinalIgnoreCase));
  CheckTrue(LStr2.StartsWith('Hello', scOrdinalIgnoreCase));
  CheckFalse(LStr2.StartsWith('Hello World!!!!!', scOrdinalIgnoreCase));
  CheckTrue(LStr2.StartsWith('Hello World', scOrdinalIgnoreCase));
  CheckTrue(LStr2.StartsWith('hello', scOrdinalIgnoreCase));
  CheckFalse(LStr2.StartsWith(' ', scOrdinalIgnoreCase));
  CheckFalse(LStr2.StartsWith('_', scOrdinalIgnoreCase));
  CheckFalse(LStr3.StartsWith(#0, scOrdinalIgnoreCase));
  CheckTrue(LStr3.StartsWith('boom!'#0, scOrdinalIgnoreCase));
  CheckFalse(LStr3.StartsWith('Blam', scOrdinalIgnoreCase));
  CheckTrue(LStr4.StartsWith('вопрос', scOrdinalIgnoreCase));
  CheckTrue(LStr4.StartsWith('ВоПрос', scOrdinalIgnoreCase));
  CheckFalse(LStr4.StartsWith('рос', scOrdinalIgnoreCase));
end;

procedure TTestString.Test_Substring;
begin
  CheckEquals('o', U('one').Substring(CFirstCharacterIndex, 1));
  CheckEquals('one', U('one').Substring(CFirstCharacterIndex, 3));
  CheckEquals('', U('one').Substring(CFirstCharacterIndex, 0));
  CheckEquals('e', U('one').Substring(CFirstCharacterIndex + 2, 1));

{$IFDEF TSTRING_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Substring(CFirstCharacterIndex - 1, 0); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Substring(CFirstCharacterIndex, 4); end,
    'EArgumentOutOfRangeException not thrown in 4.'
  );
{$ENDIF}
end;

procedure TTestString.Test_Substring_Start;
begin
  CheckEquals('one', U('one').Substring(CFirstCharacterIndex));
  CheckEquals('ne', U('one').Substring(CFirstCharacterIndex + 1));
  CheckEquals('e', U('one').Substring(CFirstCharacterIndex + 2));

{$IFDEF TSTRING_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Substring(CFirstCharacterIndex - 1); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin U('one').Substring(CFirstCharacterIndex + 3); end,
    'EArgumentOutOfRangeException not thrown in +3.'
  );
{$ENDIF}
end;

procedure TTestString.Test_ToLower;
var
  LInput: TString;
begin
  LInput := 'Hello Руссия 123!';
  CheckEquals('hello руссия 123!', LInput.ToLower.ToString);
end;

procedure TTestString.Test_ToLowerInvariant;
var
  LInput: TString;
begin
  LInput := 'Hello Руссия 123!';
  CheckEquals('hello руссия 123!', LInput.ToLowerInvariant.ToString);
end;

procedure TTestString.Test_ToString;
var
  LString: TString;
  LVal: string;
begin
  LString := TString.Create('Hello World');
  LVal := LString.ToString;
  CheckEquals('Hello World', LVal);

  LString := TString.Create('');
  LVal := LString.ToString;
  CheckEquals('', LVal);

  LString := TString.Create(#0);
  LVal := LString.ToString;
  CheckEquals(#0, LVal);
end;

procedure TTestString.Test_ToUCS4String;
var
  LString: TString;
  LUcs4: UCS4String;
begin
  LString := 'тестинг';
  LUcs4 := LString.ToUCS4String;
  CheckEquals('тестинг', UCS4StringToUnicodeString(LUcs4), 'Expected proper russian');

  LString := '';
  LUcs4 := LString.ToUCS4String;
  CheckEquals('', UCS4StringToUnicodeString(LUcs4), 'Expected proper empty');
end;

procedure TTestString.Test_ToUpper;
var
  LInput: TString;
begin
  LInput := 'Hello Руссия 123!';

  CheckEquals('HELLO РУССИЯ 123!', LInput.ToUpper.ToString);
end;

procedure TTestString.Test_ToUpperInvariant;
var
  LInput: TString;
begin
  LInput := 'Hello Руссия 123!';

  CheckEquals('HELLO РУССИЯ 123!', LInput.ToUpperInvariant.ToString);
end;

procedure TTestString.Test_ToUTF8String;
var
  LString: TString;
  LUtf8: RawByteString;
begin
  LString := 'тестинг';
  LUtf8 := LString.ToUTF8String;
  CheckEquals('тестинг', UTF8ToString(LUtf8), 'Expected proper russian');

  LString := '';
  LUtf8 := LString.ToUTF8String;
  CheckEquals('', UTF8ToString(LUtf8), 'Expected proper empty');
end;

procedure TTestString.Test_Trim;
var
  LString: TString;
begin
  LString := '       '#9;
  LString := LString.Trim;
  CheckEquals('', LString.ToString);

  LString := '';
  LString := LString.Trim;
  CheckEquals('', LString.ToString);

  LString := '          abracadabra       ';
  LString := LString.Trim;
  CheckEquals('abracadabra', LString.ToString);

  LString := '   вопрос    ';
  LString := LString.Trim;
  CheckEquals('вопрос', LString.ToString);
end;

procedure TTestString.Test_TrimLeft;
var
  LString: TString;
begin
  LString := '       '#9;
  LString := LString.TrimLeft;
  CheckEquals('', LString.ToString);

  LString := '';
  LString := LString.TrimLeft;
  CheckEquals('', LString.ToString);

  LString := '          abracadabra       ';
  LString := LString.TrimLeft;
  CheckEquals('abracadabra       ', LString.ToString);
end;

procedure TTestString.Test_TrimLeft_TWideCharSet;
var
  LString: TString;
begin
  LString := ' ./H Screw this test   ...';
  LString := LString.TrimLeft(TWideCharSet.Create('H/. '));
  CheckEquals('Screw this test   ...', LString.ToString);

  LString := '';
  LString := LString.TrimLeft(TWideCharSet.Create('abcd'));
  CheckEquals('', LString.ToString);

  LString := 'abracadabra';
  LString := LString.TrimLeft(TWideCharSet.Create('abcdefghijklmnopqrstuvwxyz'));
  CheckEquals('', LString.ToString);
end;

procedure TTestString.Test_TrimRight;
var
  LString: TString;
begin
  LString := '       '#9;
  LString := LString.TrimRight;
  CheckEquals('', LString.ToString);

  LString := '';
  LString := LString.TrimRight;
  CheckEquals('', LString.ToString);

  LString := '          abracadabra       ';
  LString := LString.TrimRight;
  CheckEquals('          abracadabra', LString.ToString);
end;

procedure TTestString.Test_TrimRight_TWideCharSet;
var
  LString: TString;
begin
  LString := '   ...Screw this test ./H ';
  LString := LString.TrimRight(TWideCharSet.Create('H/. '));
  CheckEquals('   ...Screw this test', LString.ToString);

  LString := '';
  LString := LString.TrimRight(TWideCharSet.Create('abcd'));
  CheckEquals('', LString.ToString);

  LString := 'abracadabra';
  LString := LString.TrimRight(TWideCharSet.Create('abcdefghijklmnopqrstuvwxyz'));
  CheckEquals('', LString.ToString);
end;

procedure TTestString.Test_Trim_TWideCharSet;
var
  LString: TString;
begin
  LString := ' ./H Screw this test   ...';
  LString := LString.Trim(TWideCharSet.Create('H/. '));
  CheckEquals('Screw this test', LString.ToString);

  LString := '';
  LString := LString.Trim(TWideCharSet.Create('abcd'));
  CheckEquals('', LString.ToString);

  LString := 'abracadabra';
  LString := LString.Trim(TWideCharSet.Create('abcdefghijklmnopqrstuvwxyz'));
  CheckEquals('', LString.ToString);

  LString := 'вопрос    ';
  LString := LString.Trim(TWideCharSet.Create('рос в'));
  CheckEquals('п', LString.ToString);
end;

procedure TTestString.Test_TypeObject;
begin
  CheckFalse(TString.GetType().AreEqual('тестинг', 'ТесТинг'));
  CheckFalse(TString.GetType(scLocale).AreEqual('тестинг', 'ТесТинг'));
  CheckTrue(TString.GetType(scLocaleIgnoreCase).AreEqual('тестинг', 'ТесТинг'));
  CheckFalse(TString.GetType(scInvariant).AreEqual('тестинг', 'ТесТинг'));
  CheckTrue(TString.GetType(scInvariantIgnoreCase).AreEqual('тестинг', 'ТесТинг'));
  CheckFalse(TString.GetType(scOrdinal).AreEqual('тестинг', 'ТесТинг'));
  CheckTrue(TString.GetType(scOrdinalIgnoreCase).AreEqual('тестинг', 'ТесТинг'));
end;

procedure TTestString.Test_TypeSupport;
var
  LType: IType<TString>;
  V: TString;
begin
  LType := TType<TString>.Default;

  { Default }
  Check(LType.Compare('AA', 'AB') < 0, '(Default) Expected AA < AB');
  Check(LType.Compare('AB', 'AA') > 0, '(Default) Expected AB > AA');
  Check(LType.Compare('AA', 'AA') = 0, '(Default) Expected AA = AA');
  Check(LType.Compare('aa', 'AA') < 0, '(Default) Expected aa > AA');

  Check(LType.AreEqual('abc', 'abc'), '(Default) Expected abc eq abc');
  Check(not LType.AreEqual('abc', 'ABC'), '(Default) Expected abc neq ABC');

  Check(LType.GenerateHashCode('ABC') <> LType.GenerateHashCode('abc'), '(Default) Expected hashcode ABC neq abc');
  Check(LType.GenerateHashCode('abcd') = LType.GenerateHashCode('abcd'), '(Default) Expected hashcode abcd eq abcd');

  Check(LType.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(LType.Name = 'TString', 'Type Name = "TString"');
  Check(LType.Size = 4, 'Type Size = 4');
  Check(LType.TypeInfo = TypeInfo(TString), 'Type information provider failed!');
  Check(LType.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(LType.GetString(V) = 'Hello', '(Default) Expected GetString() = "Hello"');
end;

procedure TTestString.Test_U;
begin
  CheckTrue(U('').IsEmpty, 'Expected U to be empty (after init)');
  CheckFalse(U(#0).IsEmpty, 'Expected U not to be empty (after init)');
  CheckEquals('Hello string', U('Hello string').ToString, 'Expected proper U (after init)');
end;

initialization
  TestFramework.RegisterTest(TTestString.Suite);

end.
