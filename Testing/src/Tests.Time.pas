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
unit Tests.Time;
interface
uses SysUtils, DateUtils,
     Windows,
     Tests.Utils,
     TestFramework,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.DateTime,
     TimeSpan;

type
 TTestTime = class(TTestCase)
 private
   procedure TestTimeValue(const TestName : String; const Time : TTime; const Hour, Minute, Second, Milli : Word);

 published
   procedure TestCreation();
   procedure TestMaths();
   procedure TestOperators();
   procedure TestExceptions();
   procedure TestProperties();
   procedure TestSysTime();
   procedure TestType();
 end;

implementation


{ TTestTime }

procedure TTestTime.TestOperators;
var
  xTime1, xTime2, xTime3 : TTime;
  vTime : System.TDateTime;
begin
  { Implicit conversions }
  xTime1 := TTime.Create(10, 00, 00, 00);
  vTime  := xTime1;
  xTime2 := vTime;

  TestTimeValue('Implicit', xTime1, xTime2.Hour, xTime2.Minute, xTime2.Second, xTime2.Millisecond);

  { Add operators }
  xTime1 := xTime1 + TTimeSpan.FromMilliseconds(1500);
  TestTimeValue('TTime + TTimeSpan', xTime1, 10, 00, 01, 500);

  xTime1 := TTimeSpan.FromSeconds(70) + xTime1;
  TestTimeValue('TTimeSpan + TTime', xTime1, 10, 01, 11, 500);

  { Subtract operators }
  xTime1 := xTime1 - TTimeSpan.FromSeconds(10);
  TestTimeValue('TTime - TTimeSpan', xTime1, 10, 01, 1, 500);

  xTime3 := TTime.Create(00, 00, 00, 00);
  xTime3 := xTime3 + (xTime1 - xTime2);

  TestTimeValue('TTime - TTime', xTime3, 00, 01, 1, 500);

  xTime3 := TTime.Create(00, 00, 00, 00);
  xTime3 := xTime3 + (xTime2 - xTime1);

  TestTimeValue('TTime - TTime', xTime3, 00, 01, 1, 500);

  { Equality }
  xTime1 := TTime.Now;
  xTime2 := xTime1 + TTimeSpan.FromSeconds(1);

  Check(xTime1 = xTime1, '(TTime = TTime) Failed for the same value!');
  Check(not (xTime1 = xTime2), 'not (TTime = TTime) Failed for the same value!');
  Check(not (xTime2 = xTime1), 'not (TTime = TTime) Failed for the same value!');
  Check(xTime1 <> xTime2, '(TTime <> TTime) Failed for the different values!');
  Check(xTime2 <> xTime1, '(TTime <> TTime) Failed for the different values!');
  Check(not (xTime2 <> xTime2), 'not (TTime <> TTime) Failed for the different values!');

  { Greater }
  xTime1 := TTime.Now;
  xTime2 := xTime1 + TTimeSpan.FromSeconds(1);

  Check(xTime2 > xTime1, '(TTime > TTime) Failed!');
  Check(not (xTime2 > xTime2), 'not (TTime > TTime) Failed!');
  Check(not (xTime1 > xTime2), 'not (TTime > TTime) Failed!');
  Check(xTime2 >= xTime1, '(TTime >= TTime) Failed!');
  Check(xTime2 >= xTime2, '(TTime >= TTime) Failed!');
  Check(not (xTime1 >= xTime2), 'not (TTime >= TTime) Failed!');

  { Less }
  xTime1 := TTime.Now;
  xTime2 := xTime1 + TTimeSpan.FromSeconds(1);

  Check(xTime1 < xTime2, '(TTime < TTime) Failed!');
  Check(not (xTime1 < xTime1), 'not (TTime < TTime) Failed!');
  Check(not (xTime2 < xTime1), 'not (TTime < TTime) Failed!');

  Check(xTime1 <= xTime2, '(TTime <= TTime) Failed!');
  Check(xTime1 <= xTime1, '(TTime <= TTime) Failed!');
  Check(not (xTime2 <= xTime1), 'not (TTime <= TTime) Failed!');
end;

procedure TTestTime.TestProperties;
var
  xTime : TTime;
begin
  xTime := TTime.Create(11, 00, 00, 00);
  Check(not xTime.IsPM, 'Must not be PM');

  xTime := xTime.AddHours(1);
  Check(xTime.IsPM, 'Must be PM');
end;

procedure TTestTime.TestSysTime;
var
  DT0: TTime;
  DT1: TTime;
begin
  DT0 := TTime.SystemNow;
  Sleep(100);
  DT1 := TTime.SystemNow;

  Check((DT1 - DT0).TotalMilliseconds > 90, 'SystemNow expected to be consistently over 90ms');
end;

procedure TTestTime.TestCreation;
var
 FromTime : TTime;
 FromData : TTime;
 FromNow  : TTime;
 FromStr  : TTime;

 xNow     : TDateTime;
 Hour, Minute, Second, Milli : Word;
begin
 xNow     := Now;

 FromTime := TTime.Create(xNow);
 FromData := TTime.Create(10, 19, 59, 5);
 FromNow  := TTime.Now;
 FromStr  := TTime.Create(TimeToStr(xNow));

 DecodeTime(xNow, Hour, Minute, Second, Milli);

 TestTimeValue('FromTime', FromTime, Hour, Minute, Second, Milli);
 TestTimeValue('FromData', FromData, 10, 19, 59, 5);
 TestTimeValue('FromNow', FromNow, FromNow.Hour, FromNow.Minute, FromNow.Second, FromNow.Millisecond);
 TestTimeValue('FromStr', FromStr, Hour, Minute, Second, 0);
end;

procedure TTestTime.TestExceptions;
var
 bWasEx : Boolean;
 Fs     : TFormatSettings;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID(), Fs);

  { Wrong Hour }
  bWasEx := False;

  try
    TTime.Create(24, 1, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TTime.Create() (Wrong Hour).');

  { Wrong Minute }
  bWasEx := False;

  try
    TTime.Create(22, 60, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TTime.Create() (Wrong Minute).');

  { Wrong Second }
  bWasEx := False;

  try
    TTime.Create(5, 1, 60, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TTime.Create() (Wrong Second).');

  { Wrong MSec }
  bWasEx := False;

  try
    TTime.Create(22, 1, 0, 1000);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TTime.Create() (Wrong MSec).');

  { Wrong String }

  bWasEx := False;

  try
    TTime.Create('albadalba');
  except
    on EArgumentFormatException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentFormatException not thrown in TTime.Create() (Wrong String).');

  { Wrong String with Format }

  bWasEx := False;

  try
    TTime.Create('albadalba', Fs);
  except
    on EArgumentFormatException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentFormatException not thrown in TTime.Create() (Wrong String with format).');
end;

procedure TTestTime.TestMaths;
var
  FromData : TTime;

begin
  FromData := TTime.Create(09, 00, 00, 00);

  { Ms }
  FromData := FromData.AddMilliseconds(500);
  TestTimeValue('+500ms', FromData, 09, 00, 00, 500);

  FromData := FromData.AddMilliseconds(1500);
  TestTimeValue('+1500ms', FromData, 09, 00, 02, 000);

  FromData := FromData.AddMilliseconds(-500);
  TestTimeValue('-500ms', FromData, 09, 00, 01, 500);

  { Sec }
  FromData := FromData.AddSeconds(10);
  TestTimeValue('+10s', FromData, 09, 00, 11, 500);

  FromData := FromData.AddSeconds(59);
  TestTimeValue('+59s', FromData, 09, 01, 10, 500);

  FromData := FromData.AddSeconds(-10);
  TestTimeValue('-10s', FromData, 09, 01, 00, 500);

  { Min }
  FromData := FromData.AddMinutes(5);
  TestTimeValue('+5m', FromData, 09, 06, 00, 500);

  FromData := FromData.AddMinutes(60);
  TestTimeValue('+60m', FromData, 10, 06, 00, 500);

  FromData := FromData.AddMinutes(-7);
  TestTimeValue('-7m', FromData, 09, 59, 00, 500);

  { Hour }
  FromData := FromData.AddHours(2);
  TestTimeValue('+2h', FromData, 11, 59, 00, 500);

  FromData := FromData.AddHours(22);
  TestTimeValue('+22h', FromData, 9, 59, 00, 500);

  FromData := FromData.AddHours(-8);
  TestTimeValue('-8h', FromData, 1, 59, 00, 500);
end;

procedure TTestTime.TestTimeValue(const TestName : String; const Time: TTime; const Hour, Minute, Second,
  Milli: Word);
var
  xDateTime         : TDateTime;
  __Time, __TimeFmt : String;
  Fs                : TFormatSettings;
begin
  try
    xDateTime := EncodeTime(Hour, Minute, Second, Milli);
    GetLocaleFormatSettings(GetUserDefaultLCID(), Fs);

    __Time := TimeToStr(xDateTime);
    __TimeFmt := TimeToStr(xDateTime, Fs);
  except
    Fail('(' + TestName + ') Wrong time properties passed in!');
  end;

  Check(Time.Hour = Hour, '(' + TestName + ') Expected Hour is wrong!');
  Check(Time.Minute = Minute, '(' + TestName + ') Expected Minute is wrong!');
  Check(Time.Second = Second, '(' + TestName + ') Expected Second is wrong!');
  Check(Time.Millisecond = Milli, '(' + TestName + ') Expected Millisecond is wrong!');

  Check(Time.ToString() = __Time, '(' + TestName + ') Expected string representation is wrong!');
  Check(Time.ToString(Fs) = __TimeFmt, '(' + TestName + ') Expected formatted string representation is wrong!');
end;

procedure TTestTime.TestType;
var
  Support: IType<TTime>;
  TS1, TS2: TTime;
begin
  Support := TType<TTime>.Default;
  TS1 := TTime.Create(10, 22, 15, 100);
  TS2 := TTime.Create(10, 22, 15, 101);

  Check(Support.Compare(TS1, TS2) < 0, 'Compare(TS1, TS2) was expected to be less than 0');
  Check(Support.Compare(TS2, TS1) > 0, 'Compare(TS2, TS1) was expected to be bigger than 0');
  Check(Support.Compare(TS1, TS1) = 0, 'Compare(TS1, TS1) was expected to be  0');

  Check(Support.AreEqual(TS1, TS1), 'AreEqual(TS1, TS1) was expected to be true');
  Check(not Support.AreEqual(TS1, TS2), 'AreEqual(TS1, TS2) was expected to be false');

  Check(Support.GenerateHashCode(TS1) <> Support.GenerateHashCode(TS2), 'GenerateHashCode(TS1)/TS2 were expected to be different');
  Check(Support.Management() = tmNone, 'Type support = tmNone');

  Check(Support.Name = 'TTime', 'Type Name = "TTime"');
  Check(Support.Size = SizeOf(TTime), 'Type Size = SizeOf(TTime)');
  Check(Support.TypeInfo = TypeInfo(TTime), 'Type information provider failed!');
  Check(Support.Family = tfDate, 'Type Family = tfDate');

  Check(Support.GetString(TS1) = TS1.ToString(), 'Invalid string was generated!');
end;

initialization
  TestFramework.RegisterTest(TTestTime.Suite);

end.
