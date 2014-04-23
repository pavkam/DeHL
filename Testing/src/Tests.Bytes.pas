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
unit Tests.Bytes;
interface
uses SysUtils,
     Variants,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.WideCharSet,
     DeHL.Collections.List,
     DeHL.Types,
     DeHL.Bytes;

type
  TTestBuffer = class(TDeHLTestCase)
  published
    procedure Test_Create_Bytes;
    procedure Test_Create_String;
    procedure Test_GetEnumerator;
    procedure Test_AsCollection;
    procedure Test_Length_Get;
    procedure Test_Bytes;
    procedure Test_IsEmpty;
    procedure Test_Ref;
    procedure Test_ToRawByteString;
    procedure Test_ToBytes;
    procedure Test_Contains_Buffer;
    procedure Test_Contains_Byte;
    procedure Test_Contains_String;
    procedure Test_IndexOf_Buffer;
    procedure Test_IndexOf_Byte;
    procedure Test_IndexOf_String;
    procedure Test_LastIndexOf_Buffer;
    procedure Test_LastIndexOf_Byte;
    procedure Test_LastIndexOf_String;
    procedure Test_StartsWith_Buffer;
    procedure Test_StartsWith_Byte;
    procedure Test_StartsWith_String;
    procedure Test_EndsWith_Buffer;
    procedure Test_EndsWith_Byte;
    procedure Test_EndsWith_String;
    procedure Test_Copy_Count;
    procedure Test_Copy;
    procedure Test_CopyTo_Start_Count;
    procedure Test_CopyTo_Start;
    procedure Test_CopyTo;
    procedure Test_Append_Buffer;
    procedure Test_Append_Byte;
    procedure Test_Append_String;
    procedure Test_Insert_Buffer;
    procedure Test_Insert_Byte;
    procedure Test_Insert_String;
    procedure Test_Replace_Buffer;
    procedure Test_Replace_Byte;
    procedure Test_Replace_String;
    procedure Test_Remove_Count;
    procedure Test_Remove;
    procedure Test_Reverse;
    procedure Test_Clear;
    procedure Test_Compare;
    procedure Test_CompareTo;
    procedure Test_Equal;
    procedure Test_EqualsWith;
    procedure Test_Empty;
    procedure Test_Op_Implicit_ToString;
    procedure Test_Op_Implicit_ToBuffer;
    procedure Test_Op_Implicit_ToVariant;
    procedure Test_Op_Add_Buffer;
    procedure Test_Op_Add_Byte;
    procedure Test_Op_Equal;
    procedure Test_Op_NotEqual;
    procedure Test_GetType;
    procedure Test_TypeSupport;
  end;

implementation

{ TTestBuffer }

procedure TTestBuffer.Test_Append_Buffer;
var
  LBuffer: TBuffer;
begin
  LBuffer.Append(TBuffer.Create('One'));
  CheckEquals('One', LBuffer.ToRawByteString);

  LBuffer.Append(TBuffer.Create(''));
  CheckEquals('One', LBuffer.ToRawByteString);

  LBuffer.Append(LBuffer);
  CheckEquals('OneOne', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_Append_Byte;
var
  LBuffer: TBuffer;
begin
  LBuffer.Append(32);
  CheckEquals(#32, LBuffer.ToRawByteString);

  LBuffer.Append(#0);
  CheckEquals(#32#0, LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_Append_String;
var
  LBuffer: TBuffer;
begin
  LBuffer.Append('One');
  CheckEquals('One', LBuffer.ToRawByteString);

  LBuffer.Append('');
  CheckEquals('One', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_AsCollection;
var
  LStr: string;
  V: Char;
begin
  LStr := '';
  for V in TBuffer.Create('abc').AsCollection.Op.Cast<Char> do
    LStr := LStr + V;

  CheckEquals('abc', LStr);
end;

procedure TTestBuffer.Test_Bytes;
var
  LBuffer: TBuffer;
begin
  LBuffer := TBuffer.Create(#22#23#24);

  CheckEquals(22, LBuffer[0]);
  CheckEquals(23, LBuffer[1]);
  CheckEquals(24, LBuffer[2]);

  LBuffer[0] := 55;
  LBuffer[1] := 56;
  LBuffer[2] := 57;

  CheckEquals(55, LBuffer[0]);
  CheckEquals(56, LBuffer[1]);
  CheckEquals(57, LBuffer[2]);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin if LBuffer[-1] = 1 then; end,
    'EArgumentOutOfRangeException not thrown in LBuffer[-1].'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin if LBuffer[3] = 1 then; end,
    'EArgumentOutOfRangeException not thrown in LBuffer[3].'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_Clear;
var
  LBuffer: TBuffer;
begin
  LBuffer := '';
  LBuffer.Clear;
  CheckTrue(LBuffer.IsEmpty);

  LBuffer := 'Caca maca';
  LBuffer.Clear;
  CheckTrue(LBuffer.IsEmpty);

  LBuffer := 'C';
  LBuffer.Clear;
  CheckTrue(LBuffer.IsEmpty);
end;

procedure TTestBuffer.Test_Compare;
var
  L1, L2: TBuffer;
begin
  L1 := '';
  L2 := '';
  CheckEquals(0, TBuffer.Compare(L1, L2));

  L1 := 'HAHA';
  L2 := '';
  CheckTrue(TBuffer.Compare(L1, L2) > 0);

  L1 := '';
  L2 := 'HAHA';
  CheckTrue(TBuffer.Compare(L1, L2) < 0);

  L1 := '123456';
  L2 := '12345';
  CheckTrue(TBuffer.Compare(L1, L2) > 0);

  L1 := '123456';
  L2 := '1234567';
  CheckTrue(TBuffer.Compare(L1, L2) < 0);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckTrue(TBuffer.Compare(L1, L2) < 0);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckTrue(TBuffer.Compare(L2, L1) > 0);

  L1 := 'BlahBlah';
  L2 := 'BlahBlah';
  CheckTrue(TBuffer.Compare(L1, L2) = 0);
  CheckTrue(TBuffer.Compare(L2, L1) = 0);
  CheckTrue(TBuffer.Compare(L1, L1) = 0);
  CheckTrue(TBuffer.Compare(L2, L2) = 0);
end;

procedure TTestBuffer.Test_CompareTo;
var
  L1, L2: TBuffer;
begin
  L1 := '';
  L2 := '';
  CheckEquals(0, L1.CompareTo(L2));

  L1 := 'HAHA';
  L2 := '';
  CheckTrue(L1.CompareTo(L2) > 0);

  L1 := '';
  L2 := 'HAHA';
  CheckTrue(L1.CompareTo(L2) < 0);

  L1 := '123456';
  L2 := '12345';
  CheckTrue(L1.CompareTo(L2) > 0);

  L1 := '123456';
  L2 := '1234567';
  CheckTrue(L1.CompareTo(L2) < 0);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckTrue(L1.CompareTo(L2) < 0);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckTrue(L2.CompareTo(L1) > 0);

  L1 := 'BlahBlah';
  L2 := 'BlahBlah';
  CheckTrue(L2.CompareTo(L1) = 0);
  CheckTrue(L2.CompareTo(L2) = 0);
  CheckTrue(L1.CompareTo(L1) = 0);
  CheckTrue(L1.CompareTo(L2) = 0);
end;

procedure TTestBuffer.Test_Contains_Buffer;
var
  LW, LB1, LB2: TBuffer;
begin
  LW := 'Hello';
  LB1 := '';
  LB2 := 'Hello World!';

  CheckTrue(LW.Contains(LW));
  CheckFalse(LW.Contains(LB1));
  CheckFalse(LW.Contains(LB2));

  CheckFalse(LB1.Contains(LW));
  CheckFalse(LB1.Contains(LB1));
  CheckFalse(LB1.Contains(LB2));

  CheckTrue(LB2.Contains(LW));
  CheckFalse(LB2.Contains(LB1));
  CheckTrue(LB2.Contains(LB2));
end;

procedure TTestBuffer.Test_Contains_Byte;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckFalse(LB1.Contains(33));
  CheckFalse(LB1.Contains(Ord('!')));
  CheckTrue(LB2.Contains(33));
  CheckTrue(LB2.Contains(Ord('!')));
end;

procedure TTestBuffer.Test_Contains_String;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckFalse(LB1.Contains('Hello'));
  CheckTrue(LB2.Contains('Hello'));
  CheckFalse(LB2.Contains('hello'));
end;

procedure TTestBuffer.Test_Copy;
var
  LBuffer, LCopy: TBuffer;
begin
  LBuffer := 'Hello World!';

  LCopy := LBuffer.Copy(0);
  CheckEquals('Hello World!', LCopy.ToRawByteString);

  LCopy := LBuffer.Copy(1);
  CheckEquals('ello World!', LCopy.ToRawByteString);

  LCopy := LBuffer.Copy(11);
  CheckEquals('!', LCopy.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('').Copy(0); end,
    'EArgumentOutOfRangeException not thrown in Copy(0).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Copy(-1); end,
    'EArgumentOutOfRangeException not thrown in Copy(-1).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Copy(12) end,
    'EArgumentOutOfRangeException not thrown in Copy(12).'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_CopyTo;
var
  LBuffer1, LBuffer2: TBuffer;
begin
  LBuffer1 := 'Hello World!';
  LBuffer2 := '------------';

  LBuffer1.CopyTo(LBuffer2.Ref);
  CheckEquals('Hello World!', LBuffer2.ToRawByteString);

  LBuffer1 := '';
{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer1.Ref); end,
    'EArgumentOutOfRangeException not thrown in CopyTo().'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_CopyTo_Start;
var
  LBuffer1, LBuffer2: TBuffer;
begin
  LBuffer1 := 'Hello World!';
  LBuffer2 := '------';

  LBuffer1.CopyTo(LBuffer2.Ref, 6);
  CheckEquals('World!', LBuffer2.ToRawByteString);

  LBuffer1.CopyTo(LBuffer2.Ref, 11);
  CheckEquals('!orld!', LBuffer2.ToRawByteString);

  LBuffer1.CopyTo(LBuffer2.Ref, 10);
  CheckEquals('d!rld!', LBuffer2.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer2.Ref, -1); end,
    'EArgumentOutOfRangeException not thrown in CopyTo(-1).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer2.Ref, 12); end,
    'EArgumentOutOfRangeException not thrown in CopyTo(12).'
  );

  LBuffer1 := '';
  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer2.Ref, 0); end,
    'EArgumentOutOfRangeException not thrown in e/CopyTo(0).'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_CopyTo_Start_Count;
var
  LBuffer1, LBuffer2: TBuffer;
begin
  LBuffer1 := 'Hello World!';
  LBuffer2 := '------';

  LBuffer1.CopyTo(LBuffer2.Ref, 6, 6);
  CheckEquals('World!', LBuffer2.ToRawByteString);

  LBuffer1.CopyTo(LBuffer2.Ref, 11, 1);
  CheckEquals('!orld!', LBuffer2.ToRawByteString);

  LBuffer1.CopyTo(LBuffer2.Ref, 10, 1);
  CheckEquals('dorld!', LBuffer2.ToRawByteString);

  LBuffer1.CopyTo(LBuffer2.Ref, 10, 2);
  CheckEquals('d!rld!', LBuffer2.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer2.Ref, -1, 5); end,
    'EArgumentOutOfRangeException not thrown in CopyTo(-1, 5).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer2.Ref, 12, 1); end,
    'EArgumentOutOfRangeException not thrown in CopyTo(12, 1).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer2.Ref, 0, 13); end,
    'EArgumentOutOfRangeException not thrown in CopyTo(0, 13).'
  );

  LBuffer1 := '';
  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer1.CopyTo(LBuffer2.Ref, 0, 1); end,
    'EArgumentOutOfRangeException not thrown in e/CopyTo(0, 1).'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_Copy_Count;
var
  LBuffer, LCopy: TBuffer;
begin
  LBuffer := 'Hello World!';
  LCopy := LBuffer.Copy(0, 1);
  CheckEquals('H', LCopy.ToRawByteString);

  LCopy := LBuffer.Copy(0, 12);
  CheckEquals('Hello World!', LCopy.ToRawByteString);

  LCopy := LBuffer.Copy(1, 11);
  CheckEquals('ello World!', LCopy.ToRawByteString);

  LCopy := LBuffer.Copy(11, 1);
  CheckEquals('!', LCopy.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('').Copy(0, 0); end,
    'EArgumentOutOfRangeException not thrown in Copy(0, 0).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Copy(-1, 0); end,
    'EArgumentOutOfRangeException not thrown in Copy(-1, 0).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Copy(-1, 10); end,
    'EArgumentOutOfRangeException not thrown in Copy(-1, 10).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Copy(1, 13); end,
    'EArgumentOutOfRangeException not thrown in Copy(1, 13).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Copy(11, 2) end,
    'EArgumentOutOfRangeException not thrown in Copy(11, 2).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Copy(12, 0) end,
    'EArgumentOutOfRangeException not thrown in Copy(12, 0).'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_Create_Bytes;
var
  LBuffer: TBuffer;
begin
  LBuffer := TBuffer.Create([]);
  CheckEquals(0, LBuffer.Length);

  LBuffer := TBuffer.Create([1, 2, 3]);
  CheckEquals(3, LBuffer.Length);
  CheckEquals(1, LBuffer[0]);
  CheckEquals(2, LBuffer[1]);
  CheckEquals(3, LBuffer[2]);
end;

procedure TTestBuffer.Test_Create_String;
var
  LBuffer: TBuffer;
begin
  LBuffer := TBuffer.Create('');
  CheckEquals(0, LBuffer.Length);

  LBuffer := TBuffer.Create('abc'#0'd');
  CheckEquals(5, LBuffer.Length);
  CheckEquals(Ord('a'), LBuffer[0]);
  CheckEquals(Ord('b'), LBuffer[1]);
  CheckEquals(Ord('c'), LBuffer[2]);
  CheckEquals(0, LBuffer[3]);
  CheckEquals(Ord('d'), LBuffer[4]);
end;

procedure TTestBuffer.Test_Empty;
begin
  CheckTrue(TBuffer.Empty.IsEmpty);
  TBuffer.Empty.Append('HA');

  CheckTrue(TBuffer.Empty.IsEmpty);
  CheckTrue(TBuffer.Empty.ToRawByteString = '');
end;

procedure TTestBuffer.Test_EndsWith_Buffer;
var
  LW1, LW2, LB1, LB2: TBuffer;
begin
  LW1 := 'World!';
  LW2 := 'World';

  LB1 := '';
  LB2 := 'Hello World!';

  CheckTrue (LW1.EndsWith(LW1));
  CheckFalse(LW1.EndsWith(LW2));
  CheckFalse(LW1.EndsWith(LB1));
  CheckFalse(LW1.EndsWith(LB2));

  CheckTrue (LW2.EndsWith(LW2));
  CheckFalse(LW2.EndsWith(LW1));
  CheckFalse(LW2.EndsWith(LB1));
  CheckFalse(LW2.EndsWith(LB2));

  CheckFalse(LB1.EndsWith(LW1));
  CheckFalse(LB1.EndsWith(LW2));
  CheckFalse(LB1.EndsWith(LB1));
  CheckFalse(LB1.EndsWith(LB2));

  CheckTrue (LB2.EndsWith(LW1));
  CheckFalse(LB2.EndsWith(LW2));
  CheckFalse(LB2.EndsWith(LB1));
  CheckTrue (LB2.EndsWith(LB2));
end;

procedure TTestBuffer.Test_EndsWith_Byte;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckFalse(LB1.EndsWith(Ord('d')));
  CheckFalse(LB1.EndsWith(Ord('!')));

  CheckFalse(LB2.EndsWith(Ord('d')));
  CheckTrue(LB2.EndsWith(Ord('!')));
end;

procedure TTestBuffer.Test_EndsWith_String;
var
  LW1, LW2: RawByteString;
  LB1, LB2: TBuffer;
begin
  LW1 := 'World!';
  LW2 := 'World';

  LB1 := '';
  LB2 := 'Hello World!';

  CheckTrue (LB2.EndsWith(LB2.ToRawByteString));
  CheckFalse(LB1.EndsWith(LW1));
  CheckFalse(LB1.EndsWith(LW2));
  CheckTrue (LB2.EndsWith(LW1));
  CheckFalse(LB2.EndsWith(LW2));
end;

procedure TTestBuffer.Test_Equal;
var
  L1, L2: TBuffer;
begin
  L1 := '';
  L2 := '';
  CheckTrue(TBuffer.Equal(L1, L2));

  L1 := 'HAHA';
  L2 := '';
  CheckFalse(TBuffer.Equal(L1, L2));

  L1 := '';
  L2 := 'HAHA';
  CheckFalse(TBuffer.Equal(L1, L2));

  L1 := '123456';
  L2 := '12345';
  CheckFalse(TBuffer.Equal(L1, L2));

  L1 := '123456';
  L2 := '1234567';
  CheckFalse(TBuffer.Equal(L1, L2));

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckFalse(TBuffer.Equal(L1, L2));

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckFalse(TBuffer.Equal(L2, L1));

  L1 := 'BlahBlah';
  L2 := 'BlahBlah';
  CheckTrue(TBuffer.Equal(L1, L2));
  CheckTrue(TBuffer.Equal(L2, L1));
  CheckTrue(TBuffer.Equal(L1, L1));
  CheckTrue(TBuffer.Equal(L2, L2));
end;

procedure TTestBuffer.Test_EqualsWith;
var
  L1, L2: TBuffer;
begin
  L1 := '';
  L2 := '';
  CheckTrue(L1.EqualsWith(L2));

  L1 := 'HAHA';
  L2 := '';
  CheckFalse(L1.EqualsWith(L2));

  L1 := '';
  L2 := 'HAHA';
  CheckFalse(L1.EqualsWith(L2));

  L1 := '123456';
  L2 := '12345';
  CheckFalse(L1.EqualsWith(L2));

  L1 := '123456';
  L2 := '1234567';
  CheckFalse(L1.EqualsWith(L2));

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckFalse(L1.EqualsWith(L2));

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckFalse(TBuffer.Equal(L2, L1));

  L1 := 'BlahBlah';
  L2 := 'BlahBlah';
  CheckTrue(L1.EqualsWith(L2));
  CheckTrue(L2.EqualsWith(L1));
  CheckTrue(L1.EqualsWith(L1));
  CheckTrue(L2.EqualsWith(L2));
end;

procedure TTestBuffer.Test_GetEnumerator;
var
  LEnum: IEnumerator<Byte>;
begin
  LEnum := TBuffer.Create('').GetEnumerator;
  CheckFalse(LEnum.MoveNext);

  LEnum := TBuffer.Create('abc'#0).GetEnumerator;
  CheckTrue(LEnum.MoveNext);
  CheckEquals(Ord('a'), LEnum.Current);
  CheckTrue(LEnum.MoveNext);
  CheckEquals(Ord('b'), LEnum.Current);
  CheckTrue(LEnum.MoveNext);
  CheckEquals(Ord('c'), LEnum.Current);
  CheckTrue(LEnum.MoveNext);
  CheckEquals(0, LEnum.Current);
  CheckFalse(LEnum.MoveNext);
end;

procedure TTestBuffer.Test_GetType;
begin
  CheckTrue(TBuffer.GetType <> nil);
  CheckEquals('TBuffer', TBuffer.GetType.Name);
  CheckTrue(TBuffer.GetType.TypeInfo = TypeInfo(TBuffer));
end;

procedure TTestBuffer.Test_IndexOf_Buffer;
var
  LW, LB1, LB2: TBuffer;
begin
  LW := 'llo';
  LB1 := '';
  LB2 := 'Hello World!';

  CheckEquals( 0, LW.IndexOf(LW));
  CheckEquals(-1, LW.IndexOf(LB1));
  CheckEquals(-1, LW.IndexOf(LB2));

  CheckEquals(-1, LB1.IndexOf(LW));
  CheckEquals(-1, LB1.IndexOf(LB1));
  CheckEquals(-1, LB1.IndexOf(LB2));

  CheckEquals( 2, LB2.IndexOf(LW));
  CheckEquals(-1, LB2.IndexOf(LB1));
  CheckEquals( 0, LB2.IndexOf(LB2));
end;

procedure TTestBuffer.Test_IndexOf_Byte;
var
  LW: Byte;
  LB1, LB2: TBuffer;
begin
  LW := Ord('l');
  LB1 := '';
  LB2 := 'Hello World!';

  CheckEquals(-1, LB1.IndexOf(LW));
  CheckEquals(-1, LB1.IndexOf(LB1));
  CheckEquals(-1, LB1.IndexOf(LB2));

  CheckEquals( 2, LB2.IndexOf(LW));
  CheckEquals(-1, LB2.IndexOf(LB1));
  CheckEquals( 0, LB2.IndexOf(LB2));
end;

procedure TTestBuffer.Test_IndexOf_String;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckEquals(-1, LB1.IndexOf('Hello'));
  CheckEquals( 1, LB2.IndexOf('ello'));
  CheckEquals( 2, LB2.IndexOf('llo '));
end;

procedure TTestBuffer.Test_Insert_Buffer;
var
  LBuffer: TBuffer;
begin
  LBuffer := TBuffer.Create('');
  LBuffer.Insert(0, TBuffer.Create('Haha'));
  CheckEquals('Haha', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(2, TBuffer.Create('--'));
  CheckEquals('on--e', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(1, TBuffer.Create('..'));
  CheckEquals('o..ne', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(3, TBuffer.Create('...'));
  CheckEquals('one...', LBuffer.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('one').Insert(- 1, TBuffer.Create('')); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('one').Insert(4, TBuffer.Create('...')); end,
    'EArgumentOutOfRangeException not thrown in 4.'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_Insert_Byte;
var
  LBuffer: TBuffer;
begin
  LBuffer := TBuffer.Create('');
  LBuffer.Insert(0, Ord('H'));
  CheckEquals('H', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(2, Ord('-'));
  CheckEquals('on-e', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(1, Ord('.'));
  CheckEquals('o.ne', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(3, Ord('.'));
  CheckEquals('one.', LBuffer.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('one').Insert(- 1, Ord('=')); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('one').Insert(4, Ord('.')); end,
    'EArgumentOutOfRangeException not thrown in 4.'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_Insert_String;
var
  LBuffer: TBuffer;
begin
  LBuffer := TBuffer.Create('');
  LBuffer.Insert(0, 'Haha');
  CheckEquals('Haha', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(2, '--');
  CheckEquals('on--e', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(1, '..');
  CheckEquals('o..ne', LBuffer.ToRawByteString);

  LBuffer := TBuffer.Create('one');
  LBuffer.Insert(3, '...');
  CheckEquals('one...', LBuffer.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('one').Insert(- 1, ''); end,
    'EArgumentOutOfRangeException not thrown in -1.'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('one').Insert(4, '...'); end,
    'EArgumentOutOfRangeException not thrown in 4.'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_IsEmpty;
var
  LBuffer: TBuffer;
begin
  CheckTrue(LBuffer.IsEmpty);

  LBuffer := 'Hello World';
  CheckFalse(LBuffer.IsEmpty);

  LBuffer.Clear;
  CheckTrue(LBuffer.IsEmpty);
end;

procedure TTestBuffer.Test_LastIndexOf_Buffer;
var
  LW, LB1, LB2: TBuffer;
begin
  LW := 'l';
  LB1 := '';
  LB2 := 'Hello World!';

  CheckEquals( 0, LW.LastIndexOf(LW));
  CheckEquals(-1, LW.LastIndexOf(LB1));
  CheckEquals(-1, LW.LastIndexOf(LB2));

  CheckEquals(-1, LB1.LastIndexOf(LW));
  CheckEquals(-1, LB1.LastIndexOf(LB1));
  CheckEquals(-1, LB1.LastIndexOf(LB2));

  CheckEquals( 9, LB2.LastIndexOf(LW));
  CheckEquals(-1, LB2.LastIndexOf(LB1));
  CheckEquals( 0, LB2.LastIndexOf(LB2));
end;

procedure TTestBuffer.Test_LastIndexOf_Byte;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckEquals(-1, LB1.LastIndexOf(Ord('l')));
  CheckEquals( 9, LB2.LastIndexOf(Ord('l')));
  CheckEquals( 1, LB2.LastIndexOf(Ord('e')));
end;

procedure TTestBuffer.Test_LastIndexOf_String;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckEquals(-1, LB1.LastIndexOf('l'));
  CheckEquals(-1, LB1.LastIndexOf(''));
  CheckEquals(-1, LB2.LastIndexOf(''));
  CheckEquals( 9, LB2.LastIndexOf('l'));
  CheckEquals( 2, LB2.LastIndexOf('ll'));
end;

procedure TTestBuffer.Test_Length_Get;
var
  LBuffer: TBuffer;
begin
  CheckEquals(0, LBuffer.Length);

  LBuffer := TBuffer.Create([1]);
  CheckEquals(1, LBuffer.Length);

  LBuffer.Append(2);
  CheckEquals(2, LBuffer.Length);
end;

procedure TTestBuffer.Test_Op_Add_Buffer;
var
  LBuffer: TBuffer;
begin
  LBuffer := LBuffer + LBuffer;
  CheckTrue(LBuffer.IsEmpty);

  LBuffer := LBuffer + TBuffer.Create('---');
  CheckEquals('---', LBuffer.ToRawByteString);

  LBuffer := LBuffer + LBuffer;
  CheckEquals('------', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_Op_Add_Byte;
var
  LBuffer: TBuffer;
begin
  LBuffer := LBuffer + 0;
  CheckEquals(0, LBuffer[0]);

  LBuffer := LBuffer + 45;
  CheckEquals(0, LBuffer[0]);
  CheckEquals(45, LBuffer[1]);
end;

procedure TTestBuffer.Test_Op_Equal;
var
  L1, L2: TBuffer;
begin
  L1 := '';
  L2 := '';
  CheckTrue(L1 = L2);

  L1 := 'HAHA';
  L2 := '';
  CheckFalse(L1 = L2);

  L1 := '';
  L2 := 'HAHA';
  CheckFalse(L1 = L2);

  L1 := '123456';
  L2 := '12345';
  CheckFalse(L1 = L2);

  L1 := '123456';
  L2 := '1234567';
  CheckFalse(L1 = L2);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckFalse(L1 = L2);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckFalse(L2 = L1);

  L1 := 'BlahBlah';
  L2 := 'BlahBlah';
  CheckTrue(L1 = L2);
  CheckTrue(L2 = L1);
  CheckTrue(L1 = L1);
  CheckTrue(L2 = L2);
end;

procedure TTestBuffer.Test_Op_Implicit_ToBuffer;
var
  LBuffer: TBuffer;
begin
  LBuffer := '';
  CheckTrue(LBuffer.IsEmpty);

  LBuffer := 'Hahaha';
  CheckEquals('Hahaha', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_Op_Implicit_ToString;
var
  LBuffer: TBuffer;
  LS: RawByteString;
begin
  LS := LBuffer;
  CheckEquals('', LS);

  LBuffer := 'Hello World!';
  LS := LBuffer;
  CheckEquals('Hello World!', LS);
end;

procedure TTestBuffer.Test_Op_Implicit_ToVariant;
var
  LBuffer: TBuffer;
  LVar: Variant;
begin
  LVar := LBuffer;
  CheckTrue(VarType(LVar) <> (varArray and varByte));
  CheckEquals(1, VarArrayDimCount(LVar));
  CheckEquals(0, VarArrayLowBound(LVar, 1));
  CheckEquals(-1, VarArrayHighBound(LVar, 1));

  LBuffer := #45#46#0;
  LVar := LBuffer;
  CheckTrue(VarType(LVar) <> (varArray and varByte));
  CheckEquals(1, VarArrayDimCount(LVar));
  CheckEquals(0, VarArrayLowBound(LVar, 1));
  CheckEquals(2, VarArrayHighBound(LVar, 1));
  CheckTrue(LVar[0] = 45);
  CheckTrue(LVar[1] = 46);
  CheckTrue(LVar[2] = 0);
end;

procedure TTestBuffer.Test_Op_NotEqual;
var
  L1, L2: TBuffer;
begin
  L1 := '';
  L2 := '';
  CheckFalse(L1 <> L2);

  L1 := 'HAHA';
  L2 := '';
  CheckTrue(L1 <> L2);

  L1 := '';
  L2 := 'HAHA';
  CheckTrue(L1 <> L2);

  L1 := '123456';
  L2 := '12345';
  CheckTrue(L1 <> L2);

  L1 := '123456';
  L2 := '1234567';
  CheckTrue(L1 <> L2);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckTrue(L1 <> L2);

  L1 := 'HAHA';
  L2 := 'HAHB';
  CheckTrue(L2 <> L1);

  L1 := 'BlahBlah';
  L2 := 'BlahBlah';
  CheckFalse(L1 <> L2);
  CheckFalse(L2 <> L1);
  CheckFalse(L1 <> L1);
  CheckFalse(L2 <> L2);
end;

procedure TTestBuffer.Test_Ref;
var
  LBuffer, LBuffer2: TBuffer;
begin
  LBuffer := 'Hello World!';
  LBuffer2 := LBuffer;
  LBuffer2.Ref^ := Ord('_');

  CheckEquals('Hello World!', LBuffer.ToRawByteString);
  CheckEquals('_ello World!', LBuffer2.ToRawByteString);
end;

procedure TTestBuffer.Test_Remove;
var
  LBuffer: TBuffer;
begin
  LBuffer := 'Hello World!';

  LBuffer.Remove(0);
  CheckEquals('', LBuffer.ToRawByteString);

  LBuffer := 'Hello World!';
  LBuffer.Remove(1);
  CheckEquals('H', LBuffer.ToRawByteString);

  LBuffer := 'Hello World!';
  LBuffer.Remove(11);
  CheckEquals('Hello World', LBuffer.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('').Remove(0); end,
    'EArgumentOutOfRangeException not thrown in Remove(0).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Remove(-1); end,
    'EArgumentOutOfRangeException not thrown in Remove(-1).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Remove(12) end,
    'EArgumentOutOfRangeException not thrown in Remove(12).'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_Remove_Count;
var
  LBuffer: TBuffer;
begin
  LBuffer := 'Hello World!';

  LBuffer.Remove(0, 1);
  CheckEquals('ello World!', LBuffer.ToRawByteString);

  LBuffer := 'Hello World!';
  LBuffer.Remove(0, 12);
  CheckEquals('', LBuffer.ToRawByteString);

  LBuffer := 'Hello World!';
  LBuffer.Remove(1, 11);
  CheckEquals('H', LBuffer.ToRawByteString);

  LBuffer := 'Hello World!';
  LBuffer.Remove(0, 11);
  CheckEquals('!', LBuffer.ToRawByteString);

{$IFDEF TBUFFER_CHECK_RANGES}
  CheckException(EArgumentOutOfRangeException,
    procedure() begin TBuffer.Create('').Remove(0, 0); end,
    'EArgumentOutOfRangeException not thrown in Remove(0, 0).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Remove(-1, 0); end,
    'EArgumentOutOfRangeException not thrown in Remove(-1, 0).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Remove(-1, 10); end,
    'EArgumentOutOfRangeException not thrown in Remove(-1, 10).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Remove(1, 13); end,
    'EArgumentOutOfRangeException not thrown in Remove(1, 13).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Remove(11, 2) end,
    'EArgumentOutOfRangeException not thrown in Remove(11, 2).'
  );

  CheckException(EArgumentOutOfRangeException,
    procedure() begin LBuffer.Remove(12, 0) end,
    'EArgumentOutOfRangeException not thrown in Remove(12, 0).'
  );
{$ENDIF}
end;

procedure TTestBuffer.Test_Replace_Buffer;
var
  LBuffer: TBuffer;
begin
  LBuffer.Replace(TBuffer.Create('Hello'), TBuffer.Create('--'));
  CheckEquals('', LBuffer.ToRawByteString);

  LBuffer := 'Hello World';
  LBuffer.Replace(TBuffer.Create('Hello'), TBuffer.Create('--'));
  CheckEquals('-- World', LBuffer.ToRawByteString);

  LBuffer.Replace(TBuffer.Create('-'), TBuffer.Create('--'));
  CheckEquals('---- World', LBuffer.ToRawByteString);

  LBuffer.Replace(TBuffer.Create(''), TBuffer.Create(''));
  CheckEquals('---- World', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_Replace_Byte;
var
  LBuffer: TBuffer;
begin
  LBuffer.Replace(0, 10);
  CheckEquals('', LBuffer.ToRawByteString);

  LBuffer := 'Hello World';
  LBuffer.Replace(Ord('l'), Ord('-'));
  CheckEquals('He--o Wor-d', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_Replace_String;
var
  LBuffer: TBuffer;
begin
  LBuffer.Replace('Hello', '--');
  CheckEquals('', LBuffer.ToRawByteString);

  LBuffer := 'Hello World';
  LBuffer.Replace('Hello', '--');
  CheckEquals('-- World', LBuffer.ToRawByteString);

  LBuffer.Replace('-', '--');
  CheckEquals('---- World', LBuffer.ToRawByteString);

  LBuffer.Replace('', '');
  CheckEquals('---- World', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_Reverse;
var
  LBuffer: TBuffer;
begin
  LBuffer.Reverse;
  CheckEquals('', LBuffer.ToRawByteString);

  LBuffer := 'Hello World!';
  LBuffer.Reverse;
  CheckEquals('!dlroW olleH', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_StartsWith_Buffer;
var
  LW, LB1, LB2: TBuffer;
begin
  LW := 'Hello';
  LB1 := '';
  LB2 := 'Hello World!';

  CheckTrue(LW.StartsWith(LW));
  CheckFalse(LW.StartsWith(LB1));
  CheckFalse(LW.StartsWith(LB2));

  CheckFalse(LB1.StartsWith(LW));
  CheckFalse(LB1.StartsWith(LB1));
  CheckFalse(LB1.StartsWith(LB2));

  CheckTrue(LB2.StartsWith(LW));
  CheckFalse(LB2.StartsWith(LB1));
  CheckTrue(LB2.StartsWith(LB2));
end;

procedure TTestBuffer.Test_StartsWith_Byte;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckFalse(LB1.StartsWith(Ord('e')));
  CheckFalse(LB1.StartsWith(Ord('H')));

  CheckFalse(LB2.StartsWith(Ord('e')));
  CheckTrue(LB2.StartsWith(Ord('H')));
end;

procedure TTestBuffer.Test_StartsWith_String;
var
  LB1, LB2: TBuffer;
begin
  LB1 := '';
  LB2 := 'Hello World!';

  CheckFalse(LB1.StartsWith('Hello'));
  CheckFalse(LB1.StartsWith(''));
  CheckTrue(LB2.StartsWith('Hello'));
  CheckTrue(LB2.StartsWith('H'));
  CheckFalse(LB2.StartsWith(''));
  CheckTrue(LB2.StartsWith(LB2.ToRawByteString));
end;

procedure TTestBuffer.Test_ToBytes;
var
  LBuffer: TBuffer;
begin
  CheckEquals(0, Length(LBuffer.ToBytes));

  LBuffer := TBuffer.Create([1, 2, 3]);
  CheckEquals(3, Length(LBuffer.ToBytes));
  CheckEquals(1, LBuffer.ToBytes()[0]);
  CheckEquals(2, LBuffer.ToBytes()[1]);
  CheckEquals(3, LBuffer.ToBytes()[2]);
end;

procedure TTestBuffer.Test_ToRawByteString;
var
  LBuffer: TBuffer;
begin
  CheckEquals('', LBuffer.ToRawByteString);

  LBuffer := 'Hello World!';
  CheckEquals('Hello World!', LBuffer.ToRawByteString);
end;

procedure TTestBuffer.Test_TypeSupport;
var
  LType: IType<TBuffer>;
  V: TBuffer;
begin
  LType := TType<TBuffer>.Default;

  { Default }
  Check(LType.Compare('AA', 'AB') < 0, '(Default) Expected AA < AB');
  Check(LType.Compare('AB', 'AA') > 0, '(Default) Expected AB > AA');
  Check(LType.Compare('AA', 'AA') = 0, '(Default) Expected AA = AA');
  Check(LType.Compare('aa', 'AA') > 0, '(Default) Expected aa > AA');

  Check(LType.AreEqual('abc', 'abc'), '(Default) Expected abc eq abc');
  Check(not LType.AreEqual('abc', 'ABC'), '(Default) Expected abc neq ABC');

  Check(LType.GenerateHashCode('ABC') <> LType.GenerateHashCode('abc'), '(Default) Expected hashcode ABC neq abc');
  Check(LType.GenerateHashCode('abcd') = LType.GenerateHashCode('abcd'), '(Default) Expected hashcode abcd eq abcd');

  Check(LType.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(LType.Name = 'TBuffer', 'Type Name = "TBuffer"');
  Check(LType.Size = 4, 'Type Size = 4');
  Check(LType.TypeInfo = TypeInfo(TBuffer), 'Type information provider failed!');
  Check(LType.Family = tfString, 'Type Family = tfString');

  V := 'Hello';
  Check(LType.GetString(V) = '(5 Elements)', '(Default) Expected GetString() = "(5 Elements)"');
end;

initialization
  TestFramework.RegisterTest(TTestBuffer.Suite);

end.
