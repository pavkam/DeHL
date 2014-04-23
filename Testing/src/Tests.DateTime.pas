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
unit Tests.DateTime;
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
 TTestDateTime = class(TTestCase)
 private
   procedure TestDateTimeValue(const TestName : String; const DateTime : TDateTime;
        const Year, Month, Day, Hour, Minute, Second, Milli : Word);

 published
   procedure TestCreation();
   procedure TestMaths();
   procedure TestOperators();
   procedure TestExceptions();
   procedure TestUnixTime();
   procedure TestSysTime();
   procedure TestType();
 end;

implementation


{ TTestDateTime }

procedure TTestDateTime.TestCreation;
var
 FromDateTime : TDateTime;
 FromData     : TDateTime;
 FromNow      : TDateTime;
 FromStr      : TDateTime;

 xNow         : TDateTime;
 Year, Month, Day,
   Hour, Minute, Second, Milli : Word;
begin
 xNow     := Now;

 FromDateTime := TDateTime.Create(xNow);
 FromData     := TDateTime.Create(2008, 01, 01, 10, 00, 00, 000);
 FromNow      := TDateTime.Now;
 FromStr      := TDateTime.Create(DateTimeToStr(xNow));

 DecodeDate(xNow, Year, Month, Day);
 DecodeTime(xNow, Hour, Minute, Second, Milli);

 TestDateTimeValue('FromDateTime', FromDateTime, Year, Month, Day, Hour, Minute, Second, Milli);
 TestDateTimeValue('FromData', FromData, 2008, 01, 01, 10, 00, 00, 000);
 TestDateTimeValue('FromNow', FromNow, FromNow.Date.Year, FromNow.Date.Month, FromNow.Date.Day,
                              FromNow.Time.Hour, FromNow.Time.Minute, FromNow.Time.Second, FromNow.Time.Millisecond);
 TestDateTimeValue('FromStr', FromStr, Year, Month, Day, Hour, Minute, Second, 0);
end;

procedure TTestDateTime.TestDateTimeValue(const TestName: String;
  const DateTime: TDateTime; const Year, Month, Day, Hour, Minute, Second,
  Milli: Word);
var
  xDateTime         : TDateTime;
  __DateTime,
      __DateTimeFmt : String;
  __DateTimeX,
      __DateTimeXFmt: String;

  Fs                : TFormatSettings;
begin
  try
    xDateTime := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, Milli);
    GetLocaleFormatSettings(GetUserDefaultLCID(), Fs);

    __DateTime := DateTimeToStr(xDateTime);
    __DateTimeFmt := DateTimeToStr(xDateTime, Fs);

     DateTimeToString(__DateTimeX, 'yyyy/mm/dd hh:mm:ss z', xDateTime);
     DateTimeToString(__DateTimeXFmt, 'yyyy/mm/dd hh:mm:ss z', xDateTime, Fs);
  except
    Fail('(' + TestName + ') Wrong time properties passed in!');
  end;

  Check(DateTime.Date.Year = Year, '(' + TestName + ') Expected Year is wrong!');
  Check(DateTime.Date.Month = Month, '(' + TestName + ') Expected Month is wrong!');
  Check(DateTime.Date.Day = Day, '(' + TestName + ') Expected Day is wrong!');
  Check(DateTime.Time.Hour = Hour, '(' + TestName + ') Expected Hour is wrong!');
  Check(DateTime.Time.Minute = Minute, '(' + TestName + ') Expected Minute is wrong!');
  Check(DateTime.Time.Second = Second, '(' + TestName + ') Expected Second is wrong!');
  Check(DateTime.Time.Millisecond = Milli, '(' + TestName + ') Expected Millisecond is wrong!');

  Check(DateTime.ToString() = __DateTime, '(' + TestName + ') Expected string representation is wrong!');
  Check(DateTime.ToString(Fs) = __DateTimeFmt, '(' + TestName + ') Expected formatted string representation is wrong!');

  Check(DateTime.ToString('yyyy/mm/dd hh:mm:ss z') = __DateTimeX, '(' + TestName + ') Expected string representation is wrong! (Fmt)');
  Check(DateTime.ToString('yyyy/mm/dd hh:mm:ss z', Fs) = __DateTimeXFmt, '(' + TestName + ') Expected formatted string representation is wrong! (Fmt)');
end;

procedure TTestDateTime.TestExceptions;
var
 bWasEx : Boolean;
 Fs     : TFormatSettings;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID(), Fs);

  { Wrong Month }
  bWasEx := False;

  try
    TDateTime.Create(1, 13, 1, 0, 0, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong Month).');

  { Wrong Month x2 }
  bWasEx := False;

  try
    TDateTime.Create(1, 0, 1, 0, 0, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong Month x2).');

  { Wrong Day }
  bWasEx := False;

  try
    TDateTime.Create(1, 1, 45, 0, 0, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong Day).');

  { Wrong Day x2 }
  bWasEx := False;

  try
    TDateTime.Create(1, 1, 0, 0, 0, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong Day x2).');

  { Wrong Hour }
  bWasEx := False;

  try
    TDateTime.Create(2008, 1, 1, 24, 1, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong Hour).');

  { Wrong Minute }
  bWasEx := False;

  try
    TDateTime.Create(2008, 1, 1, 22, 60, 0, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong Minute).');

  { Wrong Second }
  bWasEx := False;

  try
    TDateTime.Create(2008, 1, 1, 5, 1, 60, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong Second).');

  { Wrong MSec }
  bWasEx := False;

  try
    TDateTime.Create(2008, 1, 1, 22, 1, 0, 1000);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.Create() (Wrong MSec).');

  { Wrong String }

  bWasEx := False;

  try
    TDateTime.Create('albadalba');
  except
    on EArgumentFormatException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentFormatException not thrown in TDateTime.Create() (Wrong String).');

  { Wrong String with Format }

  bWasEx := False;

  try
    TDateTime.Create('albadalba', Fs);
  except
    on EArgumentFormatException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentFormatException not thrown in TDateTime.Create() (Wrong String with format).');

  { Minus value (Year) }

  bWasEx := False;

  try
    TDateTime.Create(2008, 1, 1, 0, 0, 0, 0).AddYears(-2009);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.AddYears() (- value obtained).');

  { Minus value (Month) }

  bWasEx := False;

  try
    TDateTime.Create(1, 10, 1, 0, 0, 0, 0).AddMonths(-200);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDateTime.AddMonths() (- value obtained).');

end;

procedure TTestDateTime.TestMaths;
var
  FromData : TDateTime;

begin
  FromData := TDateTime.Create(2008, 01, 01, 09, 00, 00, 00);

  { Ms }
  FromData := FromData.AddMilliseconds(500);
  TestDateTimeValue('+500ms', FromData, 2008, 01, 01, 09, 00, 00, 500);

  FromData := FromData.AddMilliseconds(1500);
  TestDateTimeValue('+1500ms', FromData, 2008, 01, 01, 09, 00, 02, 000);

  FromData := FromData.AddMilliseconds(-500);
  TestDateTimeValue('-500ms', FromData, 2008, 01, 01, 09, 00, 01, 500);

  { Sec }
  FromData := FromData.AddSeconds(10);
  TestDateTimeValue('+10s', FromData, 2008, 01, 01, 09, 00, 11, 500);

  FromData := FromData.AddSeconds(59);
  TestDateTimeValue('+59s', FromData, 2008, 01, 01, 09, 01, 10, 500);

  FromData := FromData.AddSeconds(-10);
  TestDateTimeValue('-10s', FromData, 2008, 01, 01, 09, 01, 00, 500);

  { Min }
  FromData := FromData.AddMinutes(5);
  TestDateTimeValue('+5m', FromData, 2008, 01, 01, 09, 06, 00, 500);

  FromData := FromData.AddMinutes(60);
  TestDateTimeValue('+60m', FromData, 2008, 01, 01, 10, 06, 00, 500);

  FromData := FromData.AddMinutes(-7);
  TestDateTimeValue('-7m', FromData, 2008, 01, 01, 09, 59, 00, 500);

  { Hour }
  FromData := FromData.AddHours(2);
  TestDateTimeValue('+2h', FromData, 2008, 01, 01, 11, 59, 00, 500);

  FromData := FromData.AddHours(22);
  TestDateTimeValue('+22h', FromData, 2008, 01, 02, 9, 59, 00, 500);

  FromData := FromData.AddHours(-8);
  TestDateTimeValue('-8h', FromData, 2008, 01, 02, 1, 59, 00, 500);

  { Day }
  FromData := FromData.AddDays(10);
  TestDateTimeValue('+10d', FromData, 2008, 01, 12, 1, 59, 00, 500);

  FromData := FromData.AddDays(22);
  TestDateTimeValue('+22d', FromData, 2008, 02, 03, 1, 59, 00, 500);

  FromData := FromData.AddDays(-3);
  TestDateTimeValue('-3d', FromData, 2008, 01, 31, 1, 59, 00, 500);

  { Month }
  FromData := FromData.AddMonths(11);
  TestDateTimeValue('+11mnths', FromData, 2008, 12, 31, 1, 59, 00, 500);

  FromData := FromData.AddMonths(1);
  TestDateTimeValue('+1mnths', FromData, 2009, 1, 31, 1, 59, 00, 500);

  FromData := FromData.AddMonths(-1);
  TestDateTimeValue('-1mnths', FromData, 2008, 12, 31, 1, 59, 00, 500);

  { Year }
  FromData := FromData.AddYears(5);
  TestDateTimeValue('+5y', FromData, 2013, 12, 31, 1, 59, 00, 500);

  FromData := FromData.AddYears(1);
  TestDateTimeValue('+1y', FromData, 2014, 12, 31, 1, 59, 00, 500);

  FromData := FromData.AddYears(-14);
  TestDateTimeValue('-14y', FromData, 2000, 12, 31, 1, 59, 00, 500);

  { Combined tests }
  FromData := FromData.AddHours(-48);
  TestDateTimeValue('-48h', FromData, 2000, 12, 29, 1, 59, 00, 500);

  FromData := FromData.AddMinutes(-(48 * 60));
  TestDateTimeValue('-(48 * 60)m', FromData, 2000, 12, 27, 1, 59, 00, 500);

  FromData := FromData.AddSeconds(-(48 * 60 * 60));
  TestDateTimeValue('-(48 * 60 * 60)s', FromData, 2000, 12, 25, 1, 59, 00, 500);

  FromData := FromData.AddMilliseconds(-(48 * 60 * 60 * 1000));
  TestDateTimeValue('-(48 * 60 * 60 * 1000)ms', FromData, 2000, 12, 23, 1, 59, 00, 500);
end;

procedure TTestDateTime.TestOperators;
var
  xDateTime1, xDateTime2, xDateTime3 : TDateTime;
  vDateTime : TDateTime;
begin
  { Implicit conversions }
  xDateTime1 := TDateTime.Create(2008, 01, 01, 10, 00, 00, 00);
  vDateTime  := xDateTime1;
  xDateTime2 := vDateTime;

  TestDateTimeValue('Implicit', xDateTime1, xDateTime2.Date.Year, xDateTime2.Date.Month, xDateTime2.Date.Day,
         xDateTime2.Time.Hour, xDateTime2.Time.Minute, xDateTime2.Time.Second, xDateTime2.Time.Millisecond);

  { Add operators }
  xDateTime1 := xDateTime1 + TTimeSpan.FromMilliseconds(1500);
  TestDateTimeValue('TDateTime + TTimeSpan', xDateTime1, 2008, 01, 01, 10, 00, 01, 500);

  xDateTime1 := TTimeSpan.FromSeconds(70) + xDateTime1;
  TestDateTimeValue('TTimeSpan + TDateTime', xDateTime1, 2008, 01, 01, 10, 01, 11, 500);

  { Subtract operators }
  xDateTime1 := xDateTime1 - TTimeSpan.FromSeconds(10);
  TestDateTimeValue('TDateTime - TTimeSpan', xDateTime1, 2008, 01, 01, 10, 01, 1, 500);

  xDateTime3 := TDateTime.Create(2008, 01, 02, 00, 00, 00, 00);
  xDateTime3 := xDateTime3 + (xDateTime1 - xDateTime2);

  TestDateTimeValue('TDateTime - TDateTime', xDateTime3, 2008, 01, 02, 00, 01, 1, 500);

  { Equality }
  xDateTime1 := TDateTime.Now;
  xDateTime2 := xDateTime1 + TTimeSpan.FromSeconds(1);

  Check(xDateTime1 = xDateTime1, '(TDateTime = TDateTime) Failed for the same value!');
  Check(not (xDateTime1 = xDateTime2), 'not (TDateTime = TDateTime) Failed for the same value!');
  Check(not (xDateTime2 = xDateTime1), 'not (TDateTime = TDateTime) Failed for the same value!');
  Check(xDateTime1 <> xDateTime2, '(TDateTime <> TDateTime) Failed for the different values!');
  Check(xDateTime2 <> xDateTime1, '(TDateTime <> TDateTime) Failed for the different values!');
  Check(not (xDateTime1 <> xDateTime1), 'not (TDateTime <> TDateTime) Failed for the different values!');

  { Greater }
  xDateTime1 := TDateTime.Now;
  xDateTime2 := xDateTime1 + TTimeSpan.FromSeconds(1);

  Check(xDateTime2 > xDateTime1, '(TDateTime > TDateTime) Failed!');
  Check(not (xDateTime2 > xDateTime2), 'not (TDateTime > TDateTime) Failed!');
  Check(not (xDateTime1 > xDateTime2), 'not (TDateTime > TDateTime) Failed!');

  Check(xDateTime2 >= xDateTime1, '(TDateTime >= TDateTime) Failed!');
  Check(xDateTime2 >= xDateTime2, '(TDateTime >= TDateTime) Failed!');
  Check(not (xDateTime1 >= xDateTime2), 'not (TDateTime >= TDateTime) Failed!');

  { Less }
  xDateTime1 := TDateTime.Now;
  xDateTime2 := xDateTime1 + TTimeSpan.FromSeconds(1);

  Check(xDateTime1 < xDateTime2, '(TDateTime < TDateTime) Failed!');
  Check(not (xDateTime1 < xDateTime1), 'not (TDateTime < TDateTime) Failed!');
  Check(not (xDateTime2 < xDateTime1), 'not (TDateTime < TDateTime) Failed!');

  Check(xDateTime1 <= xDateTime2, '(TDateTime <= TDateTime) Failed!');
  Check(xDateTime1 <= xDateTime1, '(TDateTime <= TDateTime) Failed!');
  Check(not (xDateTime2 <= xDateTime1), 'not (TDateTime <= TDateTime) Failed!');
end;

procedure TTestDateTime.TestSysTime;
var
  DT0: TDateTime;
  DT1: TDateTime;
begin
  DT0 := TDateTime.SystemNow;
  Sleep(100);
  DT1 := TDateTime.SystemNow;

  Check((DT1 - DT0).TotalMilliseconds > 90, 'SystemNow expected to be consistently over 90ms');
end;

procedure TTestDateTime.TestType;
var
  Support: IType<TDateTime>;
  TS1, TS2: TDateTime;
begin
  Support := TType<TDateTime>.Default;
  TS1 := TDateTime.Create(1990, 3, 2, 3, 10, 44, 100);
  TS2 := TDateTime.Create(1990, 3, 2, 3, 10, 44, 101);

  Check(Support.Compare(TS1, TS2) < 0, 'Compare(TS1, TS2) was expected to be less than 0');
  Check(Support.Compare(TS2, TS1) > 0, 'Compare(TS2, TS1) was expected to be bigger than 0');
  Check(Support.Compare(TS1, TS1) = 0, 'Compare(TS1, TS1) was expected to be  0');

  Check(Support.AreEqual(TS1, TS1), 'AreEqual(TS1, TS1) was expected to be true');
  Check(not Support.AreEqual(TS1, TS2), 'AreEqual(TS1, TS2) was expected to be false');

  Check(Support.GenerateHashCode(TS1) <> Support.GenerateHashCode(TS2), 'GenerateHashCode(TS1)/TS2 were expected to be different');
  Check(Support.Management() = tmNone, 'Type support = tmNone');

  Check(Support.Name = 'TDateTime', 'Type Name = "TDateTime"');
  Check(Support.Size = SizeOf(TDateTime), 'Type Size = SizeOf(TDateTime)');
  Check(Support.TypeInfo = TypeInfo(TDateTime), 'Type information provider failed!');
  Check(Support.Family = tfDate, 'Type Family = tfDate');

  Check(Support.GetString(TS1) = TS1.ToString(), 'Invalid string was generated!');
end;

procedure TTestDateTime.TestUnixTime;
var
  DT0, DT1: TDateTime;
  Unix: Int64;
begin
  { Make some conversions }
  DT0 := TDateTime.Now;
  Unix := DT0.ToUnixTime();
  DT1 := TDateTime.FromUnixTime(Unix);

  { Check unix conversion - millis can be messed up }
  Check(DT0.Date = DT1.Date, '(Date) Expected DateTime -> Unix -> DateTime to be consistent');
  Check(DT0.Time.Hour = DT1.Time.Hour, '(Hour) Expected DateTime -> Unix -> DateTime to be consistent');
  Check(DT0.Time.Minute = DT1.Time.Minute, '(Minute) Expected DateTime -> Unix -> DateTime to be consistent');
  Check(Abs(DT0.Time.Second - DT1.Time.Second) < 10, '(Second) Expected DateTime -> Unix -> DateTime to be consistent');

  { Check fixed values }
  DT0 := TDateTime.Create(2008, 12, 28, 13, 18, 0, 0);
  DT1 := TDateTime.FromUnixTime(1230470280);

  Check(DT0.ToUnixTime() = 1230470280, 'Unix time expected to be "1230470280"');
  Check(DT0 = DT1, 'Unix time "1230470280" expected to be equal to FromUnixTime conversion');

  DT0 := TDateTime.Create(1998, 4, 3, 14, 6, 22, 0);
  DT1 := TDateTime.FromUnixTime(891612382);
  Check(DT0.ToUnixTime() = 891612382, 'Unix time expected to be "891612382"');
  Check(DT0 = DT1, 'Unix time "891612382" expected to be equal to FromUnixTime conversion');

  DT0 := TDateTime.Create(1970, 1, 1, 0, 0, 0, 0);
  DT1 := TDateTime.FromUnixTime(0);
  Check(DT0.ToUnixTime() = 0, 'Unix time expected to be "0"');
  Check(DT0 = DT1, 'Unix time "0" expected to be equal to FromUnixTime conversion');

  DT0 := TDateTime.Create(1970, 2, 7, 9, 52, 13, 0);
  DT1 := TDateTime.FromUnixTime(3232333);
  Check(DT0.ToUnixTime() = 3232333, 'Unix time expected to be "3232333"');
  Check(DT0 = DT1, 'Unix time "3232333" expected to be equal to FromUnixTime conversion');
end;

initialization
  TestFramework.RegisterTest(TTestDateTime.Suite);

end.
