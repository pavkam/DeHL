(*
* Copyright (c) 2008-2009, Ciobanu Alexandru
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
unit Tests.WideCharSet;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Types,
     DeHL.WideCharSet,
     DeHL.Exceptions,
     DeHL.Collections.Base;

type
  TTestWideCharSet = class(TDeHLTestCase)
  published
    procedure TestCreate();
    procedure TestAdd();
    procedure TestSubtract();
    procedure TestInclude();
    procedure TestExclude();
    procedure TestIn();
    procedure TestImplicit();
    procedure TestEqual();
    procedure TestNotEqual();
    procedure TestUnicodeSupport();
    procedure TestEnumerator();
    procedure TestTypeSupport();
    procedure TestAsCollection();

    procedure TestCharInSet();
  end;

implementation

{ TTestWideCharSet }

procedure TTestWideCharSet.TestAsCollection;
var
  C, B: Char;
begin
  B := 'a';

  for C in TWideCharSet.Create(['a' .. 'z']).AsCollection.ToList() do
  begin
    Check(B = C, 'Expected the current character to be "' + B + '"');
    Inc(B);
  end;
end;

procedure TTestWideCharSet.TestCharInSet;
begin
  Check(CharInSet('1', TWideCharSet.Create(['0' .. '9'])), '1 is in [0..9]');
  Check(not CharInSet('5', TWideCharSet.Create(['0' .. '4'])), '5 not in [0..4]');
  Check(CharInSet('a', ['a' .. 'b']), 'a is in [1..b]');
end;

procedure TTestWideCharSet.TestCreate();
var
  LSet: TWideCharSet;
  I: Integer;
begin
  { String ctor }
  LSet := TWideCharSet.Create('One');

  Check('O' in LSet, '"O" expected to be in the set');
  Check('n' in LSet, '"n" expected to be in the set');
  Check('e' in LSet, '"e" expected to be in the set');
  Check(not ('1' in LSet), '"1" not expected to be in the set');

  { Char ctor }
  LSet := TWideCharSet.Create(#65);
  Check('A' in LSet, '"A" expected to be in the set');
  Check(not ('O' in LSet), '"O" not expected to be in the set');

  { System Set ctor }
  LSet := TWideCharSet.Create(['a' .. 'z']);

  for I := Ord('a') to Ord('z') do
    Check(Char(I) in LSet, '#' + IntToStr(I) + ' expected to be in the set');

  LSet := TWideCharSet.Create(TWideCharSet.Create('Hello'));

  Check('H' in LSet, '"H" expected to be in the set');
  Check('e' in LSet, '"e" expected to be in the set');
  Check('l' in LSet, '"l" expected to be in the set');
  Check('o' in LSet, '"o" expected to be in the set');
  Check(not ('1' in LSet), '"1" not expected to be in the set');
end;

procedure TTestWideCharSet.TestAdd();
var
  LSet: TWideCharSet;
begin
  LSet := LSet + 'A';
  Check('A' in LSet, '"A" failed to be added to the set');

  LSet := LSet + 'b';
  Check('A' in LSet, '"A" expected to exist in the set');
  Check('b' in LSet, '"b" failed to be added to the set');

  LSet := LSet + '.';
  Check('.' in LSet, '"." failed to be added to the set');
  Check(not ('1' in LSet), '"1" was not expected to exist in the set');

  { Test set add }
  LSet := ['0', '1', '2'];
  LSet := LSet + ['3', '4', '5'];

  Check('0' in LSet, '"0" failed to be added to the set');
  Check('1' in LSet, '"1" failed to be added to the set');
  Check('2' in LSet, '"2" failed to be added to the set');
  Check('3' in LSet, '"3" failed to be added to the set');
  Check('4' in LSet, '"4" failed to be added to the set');
  Check('5' in LSet, '"5" failed to be added to the set');

  { ... 1 }
  LSet := [];
  LSet := LSet + ['a' .. 'z'];

  Check(LSet = ['a' .. 'z'], 'The wide set expected to be a .. z');

  { ... 2 }
  LSet := ['1' .. '6'];
  LSet := LSet + [];

  Check(LSet = ['1' .. '6'], 'The wide set expected to be 1 .. 6');

  { ... 3 }
  LSet := [];
  LSet := LSet + [];

  Check(LSet = [], 'The wide set expected to be null');
end;

procedure TTestWideCharSet.TestSubtract();
var
  LSet: TWideCharSet;
begin
  LSet := LSet + 'A';
  LSet := LSet - 'A';
  Check(not ('A' in LSet), '"A" failed to be removed from the set');

  LSet := LSet + 'b';
  LSet := LSet + 'c';
  LSet := LSet + 'd';

  LSet := LSet - 'c';

  Check('b' in LSet, '"b" expected to exist in the set');
  Check('d' in LSet, '"d" expected to exist in the set');
  Check(not ('c' in LSet), '"c" failed to be removed from the set');

  { Test set removal }
  LSet := ['0', '1', '2', '3', '4', '5'];
  LSet := LSet - TWideCharSet.Create(['3', '4', '5']);

  Check('0' in LSet, '"0" failed to be added to the set');
  Check('1' in LSet, '"1" failed to be added to the set');
  Check('2' in LSet, '"2" failed to be added to the set');
  Check(not ('3' in LSet), '"3" failed to be removed to the set');
  Check(not ('4' in LSet), '"4" failed to be removed to the set');
  Check(not ('5' in LSet), '"5" failed to be removed to the set');

  { ... 1 }
  LSet := [];
  LSet := LSet - ['a' .. 'z'];

  Check(LSet = [], 'The wide set expected to be null');

  { ... 2 }
  LSet := ['1' .. '6'];
  LSet := LSet - [];

  Check(LSet = ['1' .. '6'], 'The wide set expected to be 1 .. 6');

  { ... 3 }
  LSet := [];
  LSet := LSet - [];

  Check(LSet = [], 'The wide set expected to be null');
end;

procedure TTestWideCharSet.TestInclude();
var
  LSet: TWideCharSet;
begin
  Include(LSet, 'A');
  Check('A' in LSet, '"A" failed to be included to the set');

  Include(LSet, 'b');
  Check('A' in LSet, '"A" expected to exist in the set');
  Check('b' in LSet, '"b" failed to be included to the set');

  Include(LSet, '.,_');
  Check('.' in LSet, '"." failed to be included to the set');
  Check(',' in LSet, '"," failed to be included to the set');
  Check('_' in LSet, '"_" failed to be included to the set');
  Check(not ('1' in LSet), '"1" was not expected to exist in the set');

  { Test set inclusion }
  LSet := ['0', '1', '2'];
  Include(LSet, ['3', '4', '5']);

  Check('0' in LSet, '"0" failed to be added to the set');
  Check('1' in LSet, '"1" failed to be added to the set');
  Check('2' in LSet, '"2" failed to be added to the set');
  Check('3' in LSet, '"3" failed to be added to the set');
  Check('4' in LSet, '"4" failed to be added to the set');
  Check('5' in LSet, '"5" failed to be added to the set');

  { ... 1 }
  LSet := [];
  Include(LSet, ['a' .. 'z']);

  Check(LSet = ['a' .. 'z'], 'The wide set expected to be a .. z');

  { ... 2 }
  LSet := ['1' .. '6'];
  Include(LSet, []);

  Check(LSet = ['1' .. '6'], 'The wide set expected to be 1 .. 6');

  { ... 3 }
  LSet := [];
  Include(LSet, []);

  Check(LSet = [], 'The wide set expected to be null');
end;

procedure TTestWideCharSet.TestExclude();
var
  LSet: TWideCharSet;
begin
  LSet := LSet + 'A';
  Exclude(LSet, 'A');
  Check(not ('A' in LSet), '"A" failed to be excluded from the set');

  LSet := LSet + 'b';
  LSet := LSet + 'c';
  LSet := LSet + 'd';

  Exclude(LSet, 'c');

  Check('b' in LSet, '"b" expected to exist in the set');
  Check('d' in LSet, '"d" expected to exist in the set');
  Check(not ('c' in LSet), '"c" failed to be excluded from the set');

  Exclude(LSet, 'db');
  Check(not ('d' in LSet), '"d" failed to be excluded from the set');
  Check(not ('b' in LSet), '"b" failed to be excluded from the set');

  { Test set exclusion }
  LSet := ['0', '1', '2', '3', '4', '5'];
  Exclude(LSet, ['3', '4', '5']);

  Check('0' in LSet, '"0" failed to be added to the set');
  Check('1' in LSet, '"1" failed to be added to the set');
  Check('2' in LSet, '"2" failed to be added to the set');
  Check(not ('3' in LSet), '"3" failed to be removed to the set');
  Check(not ('4' in LSet), '"4" failed to be removed to the set');
  Check(not ('5' in LSet), '"5" failed to be removed to the set');

  { ... 1 }
  LSet := [];
  Exclude(LSet, ['a' .. 'z']);

  Check(LSet = [], 'The wide set expected to be null');

  { ... 2 }
  LSet := ['1' .. '6'];
  Exclude(LSet, []);

  Check(LSet = ['1' .. '6'], 'The wide set expected to be 1 .. 6');

  { ... 3 }
  LSet := [];
  Exclude(LSet, []);

  Check(LSet = [], 'The wide set expected to be null');
end;

procedure TTestWideCharSet.TestIn();
var
  LSet: TWideCharSet;
begin
  Include(LSet, 'abcde');

  Check('a' in LSet, '"a" expected to be found by in operator');
  Check('b' in LSet, '"b" expected to be found by in operator');
  Check('c' in LSet, '"c" expected to be found by in operator');
  Check('d' in LSet, '"d" expected to be found by in operator');
  Check('e' in LSet, '"e" expected to be found by in operator');

  Check(not('x' in LSet), '"x" not expected to be found by in operator');

  Exclude(LSet, 'b');
  Exclude(LSet, 'c');

  Check('a' in LSet, '"a" expected to be found by in operator');
  Check(not ('b' in LSet), '"b" not expected to be found by in operator');
  Check(not ('c' in LSet), '"c" not expected to be found by in operator');
  Check('d' in LSet, '"d" expected to be found by in operator');
  Check('e' in LSet, '"e" expected to be found by in operator');
end;

procedure TTestWideCharSet.TestImplicit();
var
  LSet: TWideCharSet;
  LSysSet: TSysCharSet;
  I: Byte;
begin
  { Use the system char set }
  LSet := ['a' .. 'z'];

  for I := Ord('a') to Ord('z') do
    Check(Chr(I) in LSet, 'Expected "' + Chr(I) + '" to be in the wide set');

  { and now back }
  LSysSet := LSet;

  for I := Ord('a') to Ord('z') do
    Check(CharInSet(Chr(I), LSysSet), 'Expected "' + Chr(I) + '" to be in the sys set');
end;

procedure TTestWideCharSet.TestEnumerator();
var
  LSet: TWideCharSet;
  LSysSet: TSysCharSet;
  LChar: Char;
begin
  { Use the system char set }
  LSysSet := ['a' .. 'z'];
  LSet := LSysSet;

  for LChar in LSet do
  begin
    Check(CharInSet(LChar, LSysSet), 'Expected "' + LChar + '" to be in the sys set');
    Check(LChar in LSet, 'Expected "' + LChar + '" to be in the wide set');

    Exclude(LSysSet, AnsiChar(LChar));
  end;

  Check(LSysSet = [], 'Expected all chars to be enumerated!');
end;

procedure TTestWideCharSet.TestEqual();
var
  LSet1, LSet2: TWideCharSet;
begin
  LSet1 := ['a' .. 'z'];
  LSet2 := LSet1;
  Check(LSet1 = LSet2, 'Set 1 expected to be equal to set 2');

  LSet2 := LSet2 + '1';
  Check(not (LSet1 = LSet2), 'Set 1 expected to be different from set 2');

  LSet1 := LSet1 + '1';
  Check(LSet1 = LSet2, 'Set 1 expected to be equal to set 2');
end;

procedure TTestWideCharSet.TestNotEqual();
var
  LSet1, LSet2: TWideCharSet;
begin
  LSet1 := ['a' .. 'z'];
  LSet2 := LSet1;
  Check(not (LSet1 <> LSet2), 'Set 1 expected to be equal to set 2');

  LSet2 := LSet2 + '1';
  Check(LSet1 <> LSet2, 'Set 1 expected to be different from set 2');

  LSet1 := LSet1 + '1';
  Check(not (LSet1 <> LSet2), 'Set 1 expected to be equal to set 2');
end;

procedure TTestWideCharSet.TestTypeSupport();
var
  LSet1, LSet2: TWideCharSet;
  Support: IType<TWideCharSet>;
begin
  { Create the type }
  Support := TType<TWideCharSet>.Default;

  LSet1 := ['0'..'9'];
  LSet2 := ['1'..'8'];

  { Test stuff }
  Check(Support.Compare(LSet1, LSet1) = 0, 'Expected Support.Compare(LSet1, LSet1) = 0 to be true!');
  Check(Support.Compare(LSet1, LSet2) = 1, 'Expected Support.Compare(LSet1, LSet2) = 1 to be true!');
  Check(Support.Compare(LSet2, LSet1) = 1, 'Expected Support.Compare(LSet2, LSet1) = 1 to be true!');

  Check(Support.AreEqual(LSet1, LSet1), 'Expected Support.AreEqual(LSet1, LSet1) to be true!');
  Check(Support.AreEqual(LSet2, LSet2), 'Expected Support.AreEqual(LSet2, LSet2) to be true!');
  Check(not Support.AreEqual(LSet1, LSet2), 'Expected Support.AreEqual(LSet1, LSet2) to be false!');

  Check(Support.GenerateHashCode(LSet1) = Support.GenerateHashCode(LSet1), 'Expected Support.GenerateHashCode(LSet1) to be stable!');
  Check(Support.GenerateHashCode(LSet2) = Support.GenerateHashCode(LSet2), 'Expected Support.GenerateHashCode(LSet2) to be stable!');
  Check(Support.GenerateHashCode(LSet2) <> Support.GenerateHashCode(LSet1), 'Expected Support.GenerateHashCode(LSet1/LSet2) to be different!');

  Check(Support.GetString(LSet1) = '0123456789', 'Expected Support.GetString(LSet1) = "0123456789"');
  Check(Support.GetString(LSet2) = '12345678', 'Expected Support.GetString(LSet1) = "12345678"');

  Check(Support.Name = 'TWideCharSet', 'Type Name = "TWideCharSet"');
  Check(Support.Size = SizeOf(TWideCharSet), 'Type Size = SizeOf(TWideCharSet)');
  Check(Support.TypeInfo = TypeInfo(TWideCharSet), 'Type information provider failed!');
  Check(Support.Family = tfRecord, 'Type Family = tfRecord');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');
end;

procedure TTestWideCharSet.TestUnicodeSupport();
var
  LSet, XSet: TWideCharSet;
begin
  LSet := TWideCharSet.Create('Hello, my name is Ваня. I love Îngheţată.');

  Check('В' in LSet, 'Expected to contain the Russian "В" charater');
  Check('я' in LSet, 'Expected to contain the Russian "я" charater');
  Check('Î' in LSet, 'Expected to contain the Romanian "Î" charater');
  Check('ă' in LSet, 'Expected to contain the Romanian "ă" charater');
  Check('m' in LSet, 'Expected to contain the Latin "m" charater');

  Exclude(LSet, 'я');
  Check(not ('я' in LSet), 'Expected to not contain the Russian "я" charater');

  LSet := ['a'];
  LSet := LSet + 'н';

  Check('н' in LSet, 'Expected to contain the Russian "н" charater');

  { Test some dubious cases }
  LSet := TWideCharSet.Create(#566);
  XSet := TWideCharSet.Create('a');
  LSet := LSet + XSet;
  LSet := LSet - #566;

  Check(LSet = XSet, 'Expected XSet and LSet to be equal!');
end;

initialization
  TestFramework.RegisterTest(TTestWideCharSet.Suite);

end.
