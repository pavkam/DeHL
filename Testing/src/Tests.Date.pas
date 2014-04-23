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
unit Tests.Date;
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
 TTestDate = class(TTestCase)
 private
   procedure TestDateValue(const TestName : String; const Date : TDate; const Year, Month, Day : Word);

 published
   procedure TestCreation();
   procedure TestMaths();
   procedure TestOperators();
   procedure TestExceptions();
   procedure TestProperties();
   procedure TestDayOfWeek();
   procedure TestSysTime();
   procedure TestType();
 end;

implementation

{ TTestDate }

procedure TTestDate.TestCreation;
var
 FromTime : TDate;
 FromData : TDate;
 FromNow  : TDate;
 FromStr  : TDate;

 xNow     : TDateTime;
 Year, Month, Day  : Word;
begin
 xNow     := Now;

 FromTime := TDate.Create(xNow);
 FromData := TDate.Create(2006, 10, 5);
 FromNow  := TDate.Now;
 FromStr  := TDate.Create(DateToStr(xNow));

 DecodeDate(xNow, Year, Month, Day);

 TestDateValue('FromTime', FromTime, Year, Month, Day);
 TestDateValue('FromData', FromData, 2006, 10, 5);
 TestDateValue('FromNow', FromNow, FromNow.Year, FromNow.Month, FromNow.Day);
 TestDateValue('FromStr', FromStr, Year, Month, Day);
end;

procedure TTestDate.TestDateValue(const TestName: String; const Date: TDate;
  const Year, Month, Day: Word);
var
  xDateTime         : TDateTime;
  __Date, __DateFmt : String;
  Fs                : TFormatSettings;
begin
  try
    xDateTime := EncodeDate(Year, Month, Day);
    GetLocaleFormatSettings(GetUserDefaultLCID(), Fs);

    __Date := DateToStr(xDateTime);
    __DateFmt := DateToStr(xDateTime, Fs);
  except
    Fail('(' + TestName + ') Wrong date properties passed in!');
  end;

  Check(Date.Year = Year, '(' + TestName + ') Expected Year is wrong!');
  Check(Date.Month = Month, '(' + TestName + ') Expected Month is wrong!');
  Check(Date.Day = Day, '(' + TestName + ') Expected Day is wrong!');

  Check(Date.ToString() = __Date, '(' + TestName + ') Expected string representation is wrong!');
  Check(Date.ToString(Fs) = __DateFmt, '(' + TestName + ') Expected formatted string representation is wrong!');
end;

procedure TTestDate.TestDayOfWeek;
var
  Date: TDate;
begin
  { Check if the days of the week are true }
  Date := TDate.Create(2008, 12, 28);
  Check(Date.DayOfTheWeek = dowSunday, 'Expected DOW = Sunday');

  Date := TDate.Create(2013, 12, 3);
  Check(Date.DayOfTheWeek = dowTuesday, 'Expected DOW = Tuesday');

  Date := TDate.Create(1985, 8, 22);
  Check(Date.DayOfTheWeek = dowThursday, 'Expected DOW = Thursday');

  Date := TDate.Create(1980, 1, 1);
  Check(Date.DayOfTheWeek = dowTuesday, 'Expected DOW = Tuesday');

  Date := TDate.Create(1982, 3, 1);
  Check(Date.DayOfTheWeek = dowMonday, 'Expected DOW = Monday');

  { Not! }
  Date := TDate.Create(1982, 3, 2);
  Check(Date.DayOfTheWeek <> dowSunday, 'Expected DOW <> Sunday');

  Date := TDate.Create(2013, 12, 4);
  Check(Date.DayOfTheWeek <> dowSaturday, 'Expected DOW <> Saturday');
end;

procedure TTestDate.TestExceptions;
var
 bWasEx : Boolean;
 Fs     : TFormatSettings;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID(), Fs);

  { Wrong Month }
  bWasEx := False;

  try
    TDate.Create(1, 13, 1);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.Create() (Wrong Month).');

  { Wrong Month x2 }
  bWasEx := False;

  try
    TDate.Create(1, 0, 1);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.Create() (Wrong Month x2).');

  { Wrong Day }
  bWasEx := False;

  try
    TDate.Create(1, 1, 45);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.Create() (Wrong Day).');

  { Wrong Day x2 }
  bWasEx := False;

  try
    TDate.Create(1, 1, 0);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.Create() (Wrong Day x2).');

  { Wrong String }

  bWasEx := False;

  try
    TDate.Create('albadalba');
  except
    on EArgumentFormatException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentFormatException not thrown in TDate.Create() (Wrong String).');

  { Wrong String with Format }

  bWasEx := False;

  try
    TDate.Create('albadalba', Fs);
  except
    on EArgumentFormatException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentFormatException not thrown in TDate.Create() (Wrong String with format).');

  { Minus value (Year) }

  bWasEx := False;

  try
    TDate.Create(2008, 1, 1).AddYears(-2009);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.AddYears() (- value obtained).');

  { Minus value (Month) }

  bWasEx := False;

  try
    TDate.Create(1, 10, 1).AddMonths(-200);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.AddMonths() (- value obtained).');

  { Minus value (Day) }

  bWasEx := False;

  try
    TDate.Create(1, 1, 1).AddDays(-200);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.AddDays() (- value obtained).');

  { Subtract 2 Dates }

  bWasEx := False;

  try
    TDate.Create(2008, 1, 1) - TDate.Create(2009, 1, 1);
  except
    on EArgumentOutOfRangeException do
       bWasEx := True;
    on Exception do;
  end;

  Check(bWasEx, 'EArgumentOutOfRangeException not thrown in TDate.Operator-() (- value obtained).');
end;

procedure TTestDate.TestMaths;
var
  FromData : TDate;

begin
  FromData := TDate.Create(2008, 01, 01);

  { Day }
  FromData := FromData.AddDays(10);
  TestDateValue('+10d', FromData, 2008, 01, 11);

  FromData := FromData.AddDays(22);
  TestDateValue('+22d', FromData, 2008, 02, 02);

  FromData := FromData.AddDays(-3);
  TestDateValue('-3d', FromData, 2008, 01, 30);

  { Month }
  FromData := FromData.AddMonths(10);
  TestDateValue('+10m', FromData, 2008, 11, 30);

  FromData := FromData.AddMonths(2);
  TestDateValue('+2m', FromData, 2009, 1, 30);

  FromData := FromData.AddMonths(-1);
  TestDateValue('-1m', FromData, 2008, 12, 30);

  { Year }
  FromData := FromData.AddYears(5);
  TestDateValue('+5y', FromData, 2013, 12, 30);

  FromData := FromData.AddYears(1);
  TestDateValue('+1y', FromData, 2014, 12, 30);

  FromData := FromData.AddYears(-14);
  TestDateValue('-14y', FromData, 2000, 12, 30);
end;

procedure TTestDate.TestOperators;
var
  xDate1, xDate2, xDate3 : TDate;
  vDate : System.TDateTime;
begin
  { Implicit conversions }
  xDate1 := TDate.Create(2008, 01, 01);
  vDate  := xDate1;
  xDate2 := vDate;

  TestDateValue('Implicit', xDate1, xDate1.Year, xDate1.Month, xDate1.Day);

  { Add operators }
  xDate1 := xDate1 + TTimeSpan.FromDays(1);
  TestDateValue('TDate + TTimeSpan', xDate1, 2008, 01, 02);

  xDate1 := TTimeSpan.FromDays(31) + xDate1;
  TestDateValue('TTimeSpan + TDate', xDate1, 2008, 02, 02);

  { Subtract operators }
  xDate1 := xDate1 - TTimeSpan.FromDays(31);
  TestDateValue('TDate - TTimeSpan', xDate1, 2008, 01, 02);

  xDate3 := TDate.Create(2008, 01, 01);
  xDate3 := xDate3 + (xDate1 - xDate2);

  TestDateValue('TDate - TDate', xDate3, 2008, 01, 02);

  xDate3 := TDate.Create(2008, 01, 01);
  xDate3 := xDate3 + (xDate1 - xDate2);

  TestDateValue('TDate - TDate', xDate3, 2008, 01, 02);

  { Equality }
  xDate1 := TDate.Now;
  xDate2 := xDate1 + TTimeSpan.FromHours(24);

  Check(xDate1 = xDate1, '(TDate = TDate) Failed for the same value!');
  Check(not (xDate1 = xDate2), 'not (TDate = TDate) Failed for the same value!');
  Check(not (xDate2 = xDate1), 'not (TDate = TDate) Failed for the same value!');
  Check(xDate1 <> xDate2, '(TDate <> TDate) Failed for the different values!');
  Check(xDate2 <> xDate1, '(TDate <> TDate) Failed for the different values!');
  Check(not (xDate1 <> xDate1), 'not (TDate <> TDate) Failed for the different values!');

  { Greater }
  xDate1 := TDate.Now;
  xDate2 := xDate1 + TTimeSpan.FromHours(48);

  Check(xDate2 > xDate1, '(TDate > TDate) Failed!');
  Check(not (xDate2 > xDate2), 'not (TDate > TDate) Failed!');
  Check(not (xDate1 > xDate2), 'not (TDate > TDate) Failed!');

  Check(xDate2 >= xDate1, '(TDate >= TDate) Failed!');
  Check(xDate2 >= xDate2, '(TDate >= TDate) Failed!');
  Check(not (xDate1 >= xDate2), 'not (TDate >= TDate) Failed!');

  { Less }
  xDate1 := TDate.Now;
  xDate2 := xDate1 + TTimeSpan.FromDays(2);

  Check(xDate1 < xDate2, '(TDate < TDate) Failed!');
  Check(not (xDate1 < xDate1), 'not (TDate < TDate) Failed!');
  Check(not (xDate2 < xDate1), 'not (TDate < TDate) Failed!');

  Check(xDate1 <= xDate2, '(TDate <= TDate) Failed!');
  Check(xDate1 <= xDate1, '(TDate <= TDate) Failed!');
  Check(not (xDate2 <= xDate1), 'not (TDate <= TDate) Failed!');
end;

procedure TTestDate.TestProperties;
var
  xDate : TDate;
begin
  xDate := TDate.Create(2000, 10, 1);
  Check(xDate.IsLeapYear, 'Must be leap year: 2000');

  xDate := TDate.Create(2001, 10, 1);
  Check(not xDate.IsLeapYear, 'Must not be leap year: 2001');

  xDate := TDate.Now;
  Check(xDate.IsToday, 'Must be today!');

  xDate := xDate.AddDays(1);
  Check(not xDate.IsToday, 'Must not be today!');
end;

procedure TTestDate.TestSysTime;
var
  DT0: TDate;
  DT1: TDate;
begin
  DT0 := TDate.SystemNow;
  DT1 := TDate.SystemNow;

  Check(DT0.Year <> 0, 'SystemNow.Year expected to be <> 0');
  Check(DT0.Month <> 0, 'SystemNow.Month expected to be <> 0');
  Check(DT0.Day <> 0, 'SystemNow.Day expected to be <> 0');

  Check(DT0 = DT1, 'SystemNow expected to be consistent.');
end;

procedure TTestDate.TestType;
var
  Support: IType<TDate>;
  TS1, TS2: TDate;
begin
  Support := TType<TDate>.Default;
  TS1 := TDate.Create(1990, 6, 22);
  TS2 := TDate.Create(1990, 6, 25);

  Check(Support.Compare(TS1, TS2) < 0, 'Compare(TS1, TS2) was expected to be less than 0');
  Check(Support.Compare(TS2, TS1) > 0, 'Compare(TS2, TS1) was expected to be bigger than 0');
  Check(Support.Compare(TS1, TS1) = 0, 'Compare(TS1, TS1) was expected to be  0');

  Check(Support.AreEqual(TS1, TS1), 'AreEqual(TS1, TS1) was expected to be true');
  Check(not Support.AreEqual(TS1, TS2), 'AreEqual(TS1, TS2) was expected to be false');

  Check(Support.GenerateHashCode(TS1) <> Support.GenerateHashCode(TS2), 'GenerateHashCode(TS1)/TS2 were expected to be different');
  Check(Support.Management() = tmNone, 'Type support = tmNone');

  Check(Support.Name = 'TDate', 'Type Name = "TDate"');
  Check(Support.Size = SizeOf(TDate), 'Type Size = SizeOf(TDate)');
  Check(Support.TypeInfo = TypeInfo(TDate), 'Type information provider failed!');
  Check(Support.Family = tfDate, 'Type Family = tfDate');

  Check(Support.GetString(TS1) = TS1.ToString(), 'Invalid string was generated!');
end;

initialization
  TestFramework.RegisterTest(TTestDate.Suite);

end.
