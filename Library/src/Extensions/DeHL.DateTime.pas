(*
* Copyright (c) 2008-2010, Ciobanu Alexandru
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
unit DeHL.DateTime;
interface
uses SysUtils,
     DateUtils,
     TimeSpan,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Serialization;

type
  ///  <summary>Defines days of the week in Gregorian calendar</summary>
  TDayOfTheWeek =
  (
    ///  <summary>Identifies Sunday.</summary>
    dowSunday,
    ///  <summary>Identifies Monday.</summary>
    dowMonday,
    ///  <summary>Identifies Tuesday.</summary>
    dowTuesday,
    ///  <summary>Identifies Wednesday.</summary>
    dowWednesday,
    ///  <summary>Identifies Thursday.</summary>
    dowThursday,
    ///  <summary>Identifies Friday.</summary>
    dowFriday,
    ///  <summary>Identifies Saturday.</summary>
    dowSaturday
  );

  ///  <summary>Object-oriented date type.</summary>
  ///  <remarks>This type is designed to only hold the date part of a date-time value.</remarks>
  TDate = record
  private
    FDateTime: System.TDateTime;
    FYear: Word;
    FMonth: Word;
    FDay: Word;
    FDOW: TDayOfTheWeek;

    class function GetDate: TDate; static;
    class function GetSysDate: TDate; static;

    function GetIsLeapYear: Boolean;
    function GetIsToday: Boolean;

    function ReadDOW(const ADateTime: System.TDateTime): TDayOfTheWeek;

    { Static ctors }
    class constructor Create;
    class destructor Destroy;
  public
    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDate">DeHL.DateTime.TDate</see> value.</summary>
    ///  <param name="AYear">The year.</param>
    ///  <param name="AMonth">The month in the year.</param>
    ///  <param name="ADay">The day in the month.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    constructor Create(const AYear, AMonth, ADay: Word); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDate">DeHL.DateTime.TDate</see> value.</summary>
    ///  <param name="ADateTime">A Delphi <c>TDateTime</c> from which the date part is retreived.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADateTime"/> contains an invalid value.</exception>
    constructor Create(const ADateTime: System.TDateTime); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDate">DeHL.DateTime.TDate</see> value.</summary>
    ///  <param name="ADate">A string that is converted to a date using current locale.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException"><paramref name="ADate"/> cannot be converted to a date value.</exception>
    constructor Create(const ADate: String); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDate">DeHL.DateTime.TDate</see> value.</summary>
    ///  <param name="ADate">A string that is converted to a date.</param>
    ///  <param name="FormatSettings">Format settings to use when converting.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException"><paramref name="ADate"/> cannot be converted to a date value.</exception>
    constructor Create(const ADate: String; const FormatSettings: TFormatSettings); overload;

    ///  <summary>Specifies the year.</summary>
    ///  <returns>The year of the date.</returns>
    property Year: Word read FYear;

    ///  <summary>Specifies the month.</summary>
    ///  <returns>The month of the date.</returns>
    property Month: Word read FMonth;

    ///  <summary>Specifies the day.</summary>
    ///  <returns>The day of the date.</returns>
    property Day: Word read FDay;

    ///  <summary>Specifies the day of week.</summary>
    ///  <returns>The day of week.</returns>
    property DayOfTheWeek: TDayOfTheWeek read FDOW;

    ///  <summary>Specifies whether the date is leap.</summary>
    ///  <returns><c>True</c> if the date'd year is leap; <c>False</c> otherwise.</returns>
    property IsLeapYear: Boolean read GetIsLeapYear;

    ///  <summary>Specifies if the date is today.</summary>
    ///  <returns><c>True</c> if the date specifies today; <c>False</c> otherwise.</returns>
    property IsToday: Boolean read GetIsToday;

    ///  <summary>Adds a number of days to this date.</summary>
    ///  <param name="AValue">The number of days to add. Can be a negative number.</param>
    ///  <returns>A new date value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddDays(const AValue: NativeInt): TDate;

    ///  <summary>Adds a number of months to this date.</summary>
    ///  <param name="AValue">The number of months to add. Can be a negative number.</param>
    ///  <returns>A new date value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddMonths(const AValue: NativeInt): TDate;

    ///  <summary>Adds a number of years to this date.</summary>
    ///  <param name="AValue">The number of years to add. Can be a negative number.</param>
    ///  <returns>A new date value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddYears(const AValue: NativeInt): TDate;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ADateTime">A Delphi <c>TDateTime</c> value.</param>
    ///  <returns>A date value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADateTime"/> contains an invalid value.</exception>
    class operator Implicit(const ADateTime: System.TDateTime): TDate;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ADate">A date value.</param>
    ///  <returns>A Delphi <c>TDateTime</c> value.</returns>
    class operator Implicit(const ADate: TDate): System.TDateTime;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ADate">A date value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting date value.</returns>
    class operator Add(const ADate: TDate; const ASpan: TTimeSpan): TDate;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ADate">A date value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting date value.</returns>
    class operator Add(const ASpan: TTimeSpan; const ADate: TDate): TDate;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ADate">A date value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting date value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">The result of the operation is incorrect.</exception>
    class operator Subtract(const ADate: TDate; const ASpan: TTimeSpan): TDate;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ADate">A date value.</param>
    ///  <param name="ADate2">A date value.</param>
    ///  <returns>The resulting date value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADate"/> is less than <paramref name="ADate2"/>.</exception>
    class operator Subtract(const ADate1, ADate2: TDate): TTimeSpan;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ADate1">The value to compare.</param>
    ///  <param name="ADate2">The value to compare to.</param>
    ///  <returns><c>True</c> if the dates are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ADate1, ADate2: TDate): Boolean;

    ///  <summary>Overloaded "&lt;&gt;" operator.</summary>
    ///  <param name="ADate1">The value to compare.</param>
    ///  <param name="ADate2">The value to compare to.</param>
    ///  <returns><c>True</c> if the dates are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ADate1, ADate2: TDate): Boolean;

    ///  <summary>Overloaded "&gt;" operator.</summary>
    ///  <param name="ADate1">The value to compare.</param>
    ///  <param name="ADate2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADate1"/> is greater than <paramref name="ADate2"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ADate1, ADate2: TDate): Boolean;

    ///  <summary>Overloaded "&gt;=" operator.</summary>
    ///  <param name="ADate1">The value to compare.</param>
    ///  <param name="ADate2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADate1"/> is greater than or equal to <paramref name="ADate2"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ADate1, ADate2: TDate): Boolean;

    ///  <summary>Overloaded "&lt;" operator.</summary>
    ///  <param name="ADate1">The value to compare.</param>
    ///  <param name="ADate2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADate1"/> is less than <paramref name="ADate2"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ADate1, ADate2: TDate): Boolean;

    ///  <summary>Overloaded "&lt;=" operator.</summary>
    ///  <param name="ADate1">The value to compare.</param>
    ///  <param name="ADate2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADate1"/> is less than or equal to <paramref name="ADate2"/>; <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ADate1, ADate2: TDate): Boolean;

    ///  <summary>Converts this date value to a string.</summary>
    ///  <returns>The string representation of the date.</returns>
    function ToString(): String; overload;

    ///  <summary>Converts this date value to a string.</summary>
    ///  <param name="FormatSettings">The format settings used for conversion.</param>
    ///  <returns>The string representation of the date.</returns>
    function ToString(const FormatSettings: TFormatSettings): String; overload;

    ///  <summary>Returns the current date.</summary>
    ///  <returns>The date representing today.</returns>
    class property Now: TDate read GetDate;

    ///  <summary>Returns the current system date.</summary>
    ///  <returns>The date representing today in system time.</returns>
    class property SystemNow: TDate read GetSysDate;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <param name="ACompareOption">The comparison mode used by the type object's compare methods.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents
    ///  <see cref="DeHL.DateTime.TDate|TString">DeHL.DateTime.TDate</see> type.</returns>
    class function GetType(): IType<TDate>; static;
  end;

type
  ///  <summary>Object-oriented time type.</summary>
  ///  <remarks>This type is designed to only hold the time part of a date-time value.</remarks>
  TTime = record
  private
    FDateTime: System.TDateTime;
    FHour: Word;
    FMinute: Word;
    FSecond: Word;
    FMilli: Word;

    class function GetTime: TTime; static;
    class function GetSysTime: TTime; static;

    function GetIsPM: Boolean;

    { Static ctors }
    class constructor Create;
    class destructor Destroy;
  public
    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TTime">DeHL.DateTime.TTime</see> value.</summary>
    ///  <param name="AHour">The hour.</param>
    ///  <param name="AMinute">The minute of the hour.</param>
    ///  <param name="ASecond">The second of the minute.</param>
    ///  <param name="AMilli">The millisecond of the second.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    constructor Create(const AHour, AMinute, ASecond, AMilli: Word); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TTime">DeHL.Date.Time.TTime</see> value.</summary>
    ///  <param name="ADateTime">A Delphi <c>TDateTime</c> from which the time part is retreived.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADateTime"/> contains an invalid value.</exception>
    constructor Create(const ADateTime: System.TDateTime); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TTime">DeHL.Date.Time.TTime</see> value.</summary>
    ///  <param name="ATime">A string that is converted to a time value using current locale.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException"><paramref name="ATime"/> cannot be converted to a time value.</exception>
    constructor Create(const ATime: String); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TTime">DeHL.Date.Time.TTime</see> value.</summary>
    ///  <param name="ATime">A string that is converted to a time value.</param>
    ///  <param name="FormatSettings">Format settings to use when converting.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException"><paramref name="ATime"/> cannot be converted to a time value.</exception>
    constructor Create(const ATime: String; const FormatSettings: TFormatSettings); overload;

    ///  <summary>Specifies the hour.</summary>
    ///  <returns>The hour of this time value.</returns>
    property Hour: Word read FHour;

    ///  <summary>Specifies the minute.</summary>
    ///  <returns>The minute of this time value.</returns>
    property Minute: Word read FMinute;

    ///  <summary>Specifies the second.</summary>
    ///  <returns>The second of this time value.</returns>
    property Second: Word read FSecond;

    ///  <summary>Specifies the millisecond.</summary>
    ///  <returns>The millisecond of this time value.</returns>
    property Millisecond: Word read FMilli;

    ///  <summary>Specifies whether the time value is AM or PM.</summary>
    ///  <returns><c>True</c> if the this time value is greater than <c>12:00</c>; <c>False</c> otherwise.</returns>
    property IsPM: Boolean read GetIsPM;

    ///  <summary>Converts this time value to a string.</summary>
    ///  <returns>The string representation of this time value.</returns>
    function ToString(): String; overload;

    ///  <summary>Converts this time value to a string.</summary>
    ///  <param name="FormatSettings">The format settings used for conversion.</param>
    ///  <returns>The string representation of this time value.</returns>
    function ToString(const FormatSettings: TFormatSettings): String; overload;

    ///  <summary>Adds a number of milliseconds to this date.</summary>
    ///  <param name="AValue">The number of milliseconds to add. Can be a negative number.</param>
    ///  <returns>A new date value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddMilliseconds(const AValue: NativeInt): TTime;

    ///  <summary>Adds a number of seconds to this date.</summary>
    ///  <param name="AValue">The number of seconds to add. Can be a negative number.</param>
    ///  <returns>A new date value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddSeconds(const AValue: NativeInt): TTime;

    ///  <summary>Adds a number of minutes to this date.</summary>
    ///  <param name="AValue">The number of minutes to add. Can be a negative number.</param>
    ///  <returns>A new date value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddMinutes(const AValue: NativeInt): TTime;

    ///  <summary>Adds a number of hours to this date.</summary>
    ///  <param name="AValue">The number of hours to add. Can be a negative number.</param>
    ///  <returns>A new date value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddHours(const AValue: NativeInt): TTime;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ADateTime">A Delphi <c>TDateTime</c> value.</param>
    ///  <returns>A time value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADateTime"/> contains an invalid value.</exception>
    class operator Implicit(const ADateTime: System.TDateTime): TTime;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ATime">A time value.</param>
    ///  <returns>A Delphi <c>TDateTime</c> value.</returns>
    class operator Implicit(const ATime: TTime): System.TDateTime;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ATime">A time value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting time value.</returns>
    class operator Add(const ATime: TTime; const ASpan: TTimeSpan): TTime;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ATime">A time value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting time value.</returns>
    class operator Add(const ASpan: TTimeSpan; const ATime: TTime): TTime;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ATime">A time value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting time value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">The result of the operation is incorrect.</exception>
    class operator Subtract(const ATime: TTime; const ASpan: TTimeSpan): TTime;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ATime1">A date value.</param>
    ///  <param name="ATime2">A date value.</param>
    ///  <returns>The resulting date value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ATime1"/> is less than <paramref name="ATime2"/>.</exception>
    class operator Subtract(const ATime1, ATime2: TTime): TTimeSpan;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ATime1">The value to compare.</param>
    ///  <param name="ATime2">The value to compare to.</param>
    ///  <returns><c>True</c> if the times are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ATime1, ATime2: TTime): Boolean;

    ///  <summary>Overloaded "&lt;&gt;" operator.</summary>
    ///  <param name="ATime1">The value to compare.</param>
    ///  <param name="ATime2">The value to compare to.</param>
    ///  <returns><c>True</c> if the times are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ATime1, ATime2: TTime): Boolean;

    ///  <summary>Overloaded "&gt;" operator.</summary>
    ///  <param name="ATime1">The value to compare.</param>
    ///  <param name="ATime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ATime1"/> is greater than <paramref name="ATime2"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ATime1, ATime2: TTime): Boolean;

    ///  <summary>Overloaded "&gt;=" operator.</summary>
    ///  <param name="ATime1">The value to compare.</param>
    ///  <param name="ATime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ATime1"/> is greater than or equal to <paramref name="ATime2"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ATime1, ATime2: TTime): Boolean;

    ///  <summary>Overloaded "&lt;" operator.</summary>
    ///  <param name="ATime1">The value to compare.</param>
    ///  <param name="ATime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ATime1"/> is less than <paramref name="ATime2"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ATime1, ATime2: TTime): Boolean;

    ///  <summary>Overloaded "&lt;=" operator.</summary>
    ///  <param name="ATime1">The value to compare.</param>
    ///  <param name="ATime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ATime1"/> is less than or equal to <paramref name="ATime2"/>; <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ATime1, ATime2: TTime): Boolean;

    ///  <summary>Returns the current time.</summary>
    ///  <returns>The time representing today.</returns>
    class property Now: TTime read GetTime;

    ///  <summary>Returns the current system time.</summary>
    ///  <returns>The time representing today in system time.</returns>
    class property SystemNow: TTime read GetSysTime;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <param name="ACompareOption">The comparison mode used by the type object's compare methods.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents
    ///  <see cref="DeHL.DateTime.TTime|TString">DeHL.DateTime.TTime</see> type.</returns>
    class function GetType(): IType<TTime>; static;
  end;

type
  ///  <summary>Object-oriented date-time type.</summary>
  ///  <remarks>This type is designed to only hold the date and time parts of a date-time value.</remarks>
  TDateTime = record
  private
    FDateTime: System.TDateTime;

    { Class functions }
    class function GetNow: TDateTime; static;
    class function GetSysTime: TDateTime; static;

    { functions }
    function GetDate: TDate;
    function GetTime: TTime;

    { Static ctors }
    class constructor Create;
    class destructor Destroy;
  public
    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDateTime">DeHL.DateTime.TDateTime</see> value.</summary>
    ///  <param name="AYear">The year.</param>
    ///  <param name="AMonth">The month in the year.</param>
    ///  <param name="ADay">The day in the month.</param>
    ///  <param name="AHour">The hour in the day.</param>
    ///  <param name="AMinute">The minute of the hour.</param>
    ///  <param name="ASecond">The second of the minute.</param>
    ///  <param name="AMilli">The millisecond of the second.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    constructor Create(const AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilli: Word); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDateTime">DeHL.DateTime.TDateTime</see> value.</summary>
    ///  <param name="ADateTime">A Delphi <c>TDateTime</c> from which the time part is retreived.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADateTime"/> contains an invalid value.</exception>
    constructor Create(const ADateTime: System.TDateTime); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDateTime">DeHL.DateTime.TDateTime</see> value.</summary>
    ///  <param name="ATime">A string that is converted to a date-time value using current locale.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException"><paramref name="ADateTime"/> cannot be converted to a date-time value.</exception>
    constructor Create(const ADateTime: String); overload;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDateTime">DeHL.DateTime.TDateTime</see> value.</summary>
    ///  <param name="ATime">A string that is converted to a date-time value.</param>
    ///  <param name="FormatSettings">Format settings to use when converting.</param>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException"><paramref name="ADateTime"/> cannot be converted to a date-time value.</exception>
    constructor Create(const ADateTime: String; const FormatSettings: TFormatSettings); overload;

    ///  <summary>Specifies the date.</summary>
    ///  <returns>The date part of this date-time value.</returns>
    property Date: TDate read GetDate;

    ///  <summary>Specifies the time.</summary>
    ///  <returns>The time part of this date-time value.</returns>
    property Time: TTime read GetTime;

    ///  <summary>Adds a number of years to this date-time.</summary>
    ///  <param name="AValue">The number of years to add. Can be a negative number.</param>
    ///  <returns>A new date-time value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddYears(const AValue: NativeInt): TDateTime;

    ///  <summary>Adds a number of months to this date-time.</summary>
    ///  <param name="AValue">The number of months to add. Can be a negative number.</param>
    ///  <returns>A new date-time value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddMonths(const AValue: NativeInt): TDateTime;

    ///  <summary>Adds a number of days to this date-time.</summary>
    ///  <param name="AValue">The number of days to add. Can be a negative number.</param>
    ///  <returns>A new date-time value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddDays(const AValue: NativeInt): TDateTime;

    ///  <summary>Adds a number of milliseconds to this date-time.</summary>
    ///  <param name="AValue">The number of milliseconds to add. Can be a negative number.</param>
    ///  <returns>A new date-time value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddMilliseconds(const AValue: NativeInt): TDateTime;

    ///  <summary>Adds a number of seconds to this date-time.</summary>
    ///  <param name="AValue">The number of seconds to add. Can be a negative number.</param>
    ///  <returns>A new date-time value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddSeconds(const AValue: NativeInt): TDateTime;

    ///  <summary>Adds a number of minutes to this date-time.</summary>
    ///  <param name="AValue">The number of minutes to add. Can be a negative number.</param>
    ///  <returns>A new date-time value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddMinutes(const AValue: NativeInt): TDateTime;

    ///  <summary>Adds a number of hours to this date-time.</summary>
    ///  <param name="AValue">The number of hours to add. Can be a negative number.</param>
    ///  <returns>A new date-time value containing the result of the operation.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentFormatException">Invalid date value is obtained.</exception>
    function AddHours(const AValue: NativeInt): TDateTime;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ADateTime">A Delphi <c>TDateTime</c> value.</param>
    ///  <returns>A date-time value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADateTime"/> contains an invalid value.</exception>
    class operator Implicit(const ADateTime: System.TDateTime): TDateTime;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ATime">A date-time value.</param>
    ///  <returns>A Delphi <c>TDateTime</c> value.</returns>
    class operator Implicit(const ADateTime: TDateTime): System.TDateTime;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ADateTime">A date-time value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting time value.</returns>
    class operator Add(const ADateTime: TDateTime; const ASpan: TTimeSpan): TDateTime;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ADateTime">A date-time value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting time value.</returns>
    class operator Add(const ASpan: TTimeSpan; const ADateTime: TDateTime): TDateTime;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ADateTime">A date-time value.</param>
    ///  <param name="ASpan">A time span value.</param>
    ///  <returns>The resulting time value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">The result of the operation is incorrect.</exception>
    class operator Subtract(const ADateTime: TDateTime; const ASpan: TTimeSpan): TDateTime;

    ///  <summary>Overloaded "-" operator.</summary>
    ///  <param name="ADateTime1">A date value.</param>
    ///  <param name="ADateTime2">A date value.</param>
    ///  <returns>The resulting date value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="ADateTime1"/> is less than <paramref name="ADateTime2"/>.</exception>
    class operator Subtract(const ADateTime1, ADateTime2: TDateTime): TTimeSpan;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ADateTime1">The value to compare.</param>
    ///  <param name="ADateTime2">The value to compare to.</param>
    ///  <returns><c>True</c> if the date-times are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ADateTime1, ADateTime2: TDateTime): Boolean;

    ///  <summary>Overloaded "&lt;&gt;" operator.</summary>
    ///  <param name="ADateTime1">The value to compare.</param>
    ///  <param name="ADateTime2">The value to compare to.</param>
    ///  <returns><c>True</c> if the date-times are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ADateTime1, ADateTime2: TDateTime): Boolean;

    ///  <summary>Overloaded "&gt;" operator.</summary>
    ///  <param name="ADateTime1">The value to compare.</param>
    ///  <param name="ADateTime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADateTime1"/> is greater than <paramref name="ADateTime2"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ADateTime1, ADateTime2: TDateTime): Boolean;

    ///  <summary>Overloaded "&gt;=" operator.</summary>
    ///  <param name="ADateTime1">The value to compare.</param>
    ///  <param name="ADateTime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADateTime1"/> is greater than or equal to <paramref name="ADateTime2"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ADateTime1, ADateTime2: TDateTime): Boolean;

    ///  <summary>Overloaded "&lt;" operator.</summary>
    ///  <param name="ADateTime1">The value to compare.</param>
    ///  <param name="ADateTime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADateTime1"/> is less than <paramref name="ADateTime2"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ADateTime1, ADateTime2: TDateTime): Boolean;

    ///  <summary>Overloaded "&lt;=" operator.</summary>
    ///  <param name="ADateTime1">The value to compare.</param>
    ///  <param name="ADateTime2">The value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ADateTime1"/> is less than or equal to <paramref name="ADateTime2"/>; <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ADateTime1, ADateTime2: TDateTime): Boolean;

    ///  <summary>Converts this date-time value to a string.</summary>
    ///  <returns>The string representation of this date-time value.</returns>
    function ToString(): String; overload;

    ///  <summary>Converts this date-time value to a string.</summary>
    ///  <param name="FormatSettings">The format settings used for conversion.</param>
    ///  <returns>The string representation of this date-time value.</returns>
    function ToString(const FormatSettings: TFormatSettings): String; overload;

    ///  <summary>Converts this date-time value to a string.</summary>
    ///  <param name="Format">The format string used for conversion.</param>
    ///  <returns>The string representation of this date-time value.</returns>
    function ToString(const Format: String): String; overload;

    ///  <summary>Converts this date-time value to a string.</summary>
    ///  <param name="Format">The format string used for conversion.</param>
    ///  <param name="FormatSettings">The format settings used for conversion.</param>
    ///  <returns>The string representation of this date-time value.</returns>
    function ToString(const Format: String; const FormatSettings: TFormatSettings): String; overload;

    ///  <summary>Converts this date-time value to UNIX notation.</summary>
    ///  <returns>An <c>Int64</c> value containing the number of seconds elapsed from the UNIX era.</returns>
    function ToUnixTime(): Int64;

    ///  <summary>Initializes a new <see cref="DeHL.DateTime|TDateTime">DeHL.DateTime.TDateTime</see> value.</summary>
    ///  <param name="UnixTime">A <c>Int64</c> value containing an UNIX time value.</param>
    ///  <returns>A new date-time value.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="UnixTime"/> cannot be converted to a date-time value.</exception>
    class function FromUnixTime(const UnixTime: Int64): TDateTime; static;

    ///  <summary>Returns the current date and time.</summary>
    ///  <returns>The date-time representing today.</returns>
    class property Now: TDateTime read GetNow;

    ///  <summary>Returns the current system date and time.</summary>
    ///  <returns>The date-time representing today in system time.</returns>
    class property SystemNow: TDateTime read GetSysTime;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <param name="ACompareOption">The comparison mode used by the type object's compare methods.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents
    ///  <see cref="DeHL.DateTime.TDateTime|TString">DeHL.DateTime.TDateTime</see> type.</returns>
    class function GetType(): IType<TDateTime>; static;
  end;

implementation
uses Windows;

type
  { Date Support }
  TDateType = class(TRecordType<TDate>)
  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TDate; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TDate; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: TDate): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: TDate): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: TDate): String; override;

    { Type information }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: TDate; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TDate): Boolean; override;
  end;

{ TDate }

constructor TDate.Create(const AYear, AMonth, ADay: Word);
begin
  if not IsValidDate(AYear, AMonth, ADay) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AYear/AMonth/ADay is wrong!');

  FYear := AYear;
  FMonth := AMonth;
  FDay := ADay;

  { Try to create a valid date - should throw an exception if it fails }
  FDateTime := EncodeDate(AYear, AMonth, ADay);

  { Get the DOW value }
  FDOW := ReadDOW(FDateTime);
end;

constructor TDate.Create(const ADateTime: System.TDateTime);
begin
  { Decode into fields - should throw exception if failed }
  DecodeDate(ADateTime, FYear, FMonth, FDay);

  if not IsValidDate(FYear, FMonth, FDay) then
     ExceptionHelper.Throw_InvalidArgumentFormatError('ADateTime');

  { Get the DOW value }
  FDOW := ReadDOW(ADateTime);

  FDateTime := ADateTime;
end;

constructor TDate.Create(const ADate: String);
begin
  { Convert from string - should throw exception if failed }
  try
    FDateTime := StrToDate(ADate);
  except
    on Exception do
       ExceptionHelper.Throw_InvalidArgumentFormatError('ADate');
  end;

  DecodeDate(FDateTime, FYear, FMonth, FDay);

  if not IsValidDate(FYear, FMonth, FDay) then
     ExceptionHelper.Throw_InvalidArgumentFormatError('ADate');

  { Get the DOW value }
  FDOW := ReadDOW(FDateTime);
end;

constructor TDate.Create(const ADate: String;
  const FormatSettings: TFormatSettings);
begin
  { Convert from string - should throw exception if failed }
  try
    FDateTime := StrToDate(ADate, FormatSettings);
  except
    on Exception do
       ExceptionHelper.Throw_InvalidArgumentFormatError('ADate');
  end;

  DecodeDate(FDateTime, FYear, FMonth, FDay);

  if not IsValidDate(FYear, FMonth, FDay) then
     ExceptionHelper.Throw_InvalidArgumentFormatError('ADate');

  { Get the DOW value }
  FDOW := ReadDOW(FDateTime);
end;

class constructor TDate.Create;
begin
  TType<TDate>.Register(TDateType);
end;

class destructor TDate.Destroy;
begin
  TType<TDate>.Unregister();
end;

class function TDate.GetDate: TDate;
begin
  { Forward to system function }
  Result := TDate.Create(SysUtils.Date());
end;

function TDate.GetIsLeapYear: Boolean;
begin
  { Pass over }
  Result := DateUtils.IsInLeapYear(FDateTime);
end;

function TDate.GetIsToday: Boolean;
begin
  { Pass over }
  Result := DateUtils.IsToday(FDateTime);
end;

class function TDate.GetSysDate: TDate;
var
  LTime: TSystemTime;
begin
  { Read the system time/date and convert }
  GetSystemTime(LTime);
  Result := TDate.Create(SystemTimeToDateTime(LTime));
end;

class function TDate.GetType: IType<TDate>;
begin
  Result := TDateType.Create();
end;

class operator TDate.GreaterThan(const ADate1, ADate2: TDate): Boolean;
begin
  { Simple comparison }
  Result := CompareDate(ADate1.FDateTime, ADate2.FDateTime) > 0;
end;

class operator TDate.GreaterThanOrEqual(const ADate1, ADate2: TDate): Boolean;
begin
  { Simple comparison }
  Result := CompareDate(ADate1.FDateTime, ADate2.FDateTime) >= 0;
end;

class operator TDate.Implicit(const ADate: TDate): System.TDateTime;
begin
  { Generate the System.TDateTime equivalent }
  Result := ADate.FDateTime;
end;

class operator TDate.Implicit(const ADateTime: System.TDateTime): TDate;
begin
  { Use the constructor }
  Result := TDate.Create(ADateTime);
end;

class operator TDate.LessThan(const ADate1, ADate2: TDate): Boolean;
begin
  { Simple comparison }
  Result := CompareDate(ADate1.FDateTime, ADate2.FDateTime) < 0;
end;

class operator TDate.LessThanOrEqual(const ADate1, ADate2: TDate): Boolean;
begin
  { Simple comparison }
  Result := CompareDate(ADate1.FDateTime, ADate2.FDateTime) <= 0;
end;

class operator TDate.NotEqual(const ADate1, ADate2: TDate): Boolean;
begin
  { Simple comparison }
  Result := CompareDate(ADate1.FDateTime, ADate2.FDateTime) <> 0;
end;

function TDate.ReadDOW(const ADateTime: System.TDateTime): TDayOfTheWeek;
const
  Map: array[1..7] of TDayOfTheWeek =
  (
    dowSunday,
    dowMonday,
    dowTuesday,
    dowWednesday,
    dowThursday,
    dowFriday,
    dowSaturday
  );
var
  Idx: Word;
begin
  Idx := DayOfWeek(ADateTime);
  ASSERT((Idx > 0) and (Idx < 8));
  Result := Map[Idx];
end;

class operator TDate.Equal(const ADate1, ADate2: TDate): Boolean;
begin
  { Simple comparison }
  Result := CompareDate(ADate1.FDateTime, ADate2.FDateTime) = 0;
end;

class operator TDate.Subtract(const ADate: TDate;
  const ASpan: TTimeSpan): TDate;
begin
  { Use supplied milliseconds value }
  try
    Result := TDate.Create(IncMilliSecond(ADate.FDateTime, -1 * Round(ASpan.TotalMilliseconds)));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('ASpan');
  end;
end;

class operator TDate.Subtract(const ADate1, ADate2: TDate): TTimeSpan;
begin
  if ADate1 < ADate2 then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ADate2');

  { Use supplied milliseconds value }
  Result := TTimeSpan.FromMilliseconds(MilliSecondsBetween(ADate1.FDateTime, ADate2.FDateTime));
end;

function TDate.ToString(const FormatSettings: TFormatSettings): String;
begin
  { Use system function to generate a string }
  Result := DateToStr(FDateTime, FormatSettings);
end;

function TDate.ToString: String;
begin
  { Use system function to generate a string }
  Result := DateToStr(FDateTime);
end;

class operator TDate.Add(const ASpan: TTimeSpan; const ADate: TDate): TDate;
begin
  { Use supplied milliseconds value }
  Result := TDate.Create(IncMilliSecond(ADate.FDateTime, Round(ASpan.TotalMilliseconds)));
end;

class operator TDate.Add(const ADate: TDate; const ASpan: TTimeSpan): TDate;
begin
  { Use supplied milliseconds value }
  Result := TDate.Create(IncMilliSecond(ADate.FDateTime, Round(ASpan.TotalMilliseconds)));
end;

function TDate.AddDays(const AValue: NativeInt): TDate;
begin
  { Create a new date +N }
  try
    Result := TDate.Create(IncDay(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDate.AddMonths(const AValue: NativeInt): TDate;
begin
  { Create a new date +N }
  try
    Result := TDate.Create(IncMonth(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDate.AddYears(const AValue: NativeInt): TDate;
begin
  { Create a new date +N }
  try
    Result := TDate.Create(IncYear(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

{ TDateType }

function TDateType.Compare(const AValue1, AValue2: TDate): NativeInt;
begin
  Result := CompareDate(AValue1.FDateTime, AValue2.FDateTime);
end;

procedure TDateType.DoDeserialize(const AInfo: TValueInfo; out AValue: TDate; const AContext: IDeserializationContext);
var
  LDT: System.TDateTime;
begin
  AContext.GetValue(AInfo, LDT);
  AValue := TDate.Create(LDT);
end;

procedure TDateType.DoSerialize(const AInfo: TValueInfo; const AValue: TDate; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue.FDateTime);
end;

function TDateType.Family: TTypeFamily;
begin
  Result := tfDate;
end;

function TDateType.GenerateHashCode(const AValue: TDate): NativeInt;
{$IF SizeOf(TDateTime) <= SizeOf(NativeInt)}
var
  X: TDateTime;
  LongOp: NativeInt absolute X;
begin
  X := AValue.FDateTime;

  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  X: TDateTime;
  LongOp: array[0..1] of Integer absolute X;
begin
  X := AValue.FDateTime;

  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TDateType.GetString(const AValue: TDate): String;
begin
  Result := DateToStr(AValue.FDateTime);
end;

function TDateType.TryConvertFromVariant(const AValue: Variant; out ORes: TDate): Boolean;
begin
  { May fail }
  try
    ORes := TDate.Create(System.TDateTime(AValue));
  except
    Exit(false);
  end;

  Result := true;
end;

function TDateType.TryConvertToVariant(const AValue: TDate; out ORes: Variant): Boolean;
begin
  { Simple assignment }
  ORes := AValue.FDateTime;
  Result := true;
end;


type
 { Time Support }
  TTimeType = class(TRecordType<TTime>)
  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TTime; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TTime; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: TTime): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: TTime): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: TTime): String; override;

    { Type information }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: TTime; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TTime): Boolean; override;
  end;

{ TTime }

constructor TTime.Create(const ADateTime: System.TDateTime);
begin
  { Crete from the given date }
  FDateTime := ADateTime;

  { Decode }
  DecodeTime(ADateTime, FHour, FMinute, FSecond, FMilli);

  if not IsValidTime(FHour, FMinute, FSecond, FMilli) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ADateTime');
end;

constructor TTime.Create(const AHour, AMinute, ASecond, AMilli: Word);
begin
  if not IsValidTime(AHour, AMinute, ASecond, AMilli) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AHour/AMinute/ASecond/AMilli');

  { Create a valid date-time - will throw exception if invalid}
  FDateTime := EncodeTime(AHour, AMinute, ASecond, AMilli);

  { Copy }
  FHour := AHour;
  FMinute := AMinute;
  FSecond := ASecond;
  FMilli := AMilli;
end;

class operator TTime.Add(const ASpan: TTimeSpan; const ATime: TTime): TTime;
begin
  { Create new Time by performing an Inc }
  Result := TTime.Create(IncMilliSecond(ATime.FDateTime, Round(ASpan.TotalMilliseconds)));
end;

class operator TTime.Add(const ATime: TTime; const ASpan: TTimeSpan): TTime;
begin
  { Create new Time by performing an Inc }
  Result := TTime.Create(IncMilliSecond(ATime.FDateTime, Round(ASpan.TotalMilliseconds)));
end;

function TTime.AddHours(const AValue: NativeInt): TTime;
begin
  { Simply increase hour }
  try
    Result := TTime.Create(IncHour(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TTime.AddMilliseconds(const AValue: NativeInt): TTime;
begin
  { Simply increase milli }
  try
    Result := TTime.Create(IncMilliSecond(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TTime.AddMinutes(const AValue: NativeInt): TTime;
begin
  { Simply increase minute }
  try
    Result := TTime.Create(IncMinute(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TTime.AddSeconds(const AValue: NativeInt): TTime;
begin
  { Simply increase second }
  try
    Result := TTime.Create(IncSecond(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

constructor TTime.Create(const ATime: String);
begin
  { Convert to datetime - will throw if erorr }
  try
    FDateTime := StrToTime(ATime);
  except
    on Exception do
       ExceptionHelper.Throw_InvalidArgumentFormatError('ATime');
  end;

  { Decode }
  DecodeTime(FDateTime, FHour, FMinute, FSecond, FMilli);
end;

class operator TTime.Equal(const ATime1, ATime2: TTime): Boolean;
begin
  { Simple check }
  Result := CompareTime(ATime1.FDateTime, ATime2.FDateTime) = 0;
end;

function TTime.GetIsPM: Boolean;
begin
  { Pass over }
  Result := DateUtils.IsPM(FDateTime);
end;

class function TTime.GetSysTime: TTime;
var
  STime: TSystemTime;
begin
  { Read the system time/date and convert }
  GetSystemTime(STime);
  Result := TTime.Create(SystemTimeToDateTime(STime));
end;

class function TTime.GetTime: TTime;
begin
  { Call delphi function }
  Result := SysUtils.Time();
end;

class function TTime.GetType: IType<TTime>;
begin
  Result := TTimeType.Create;
end;

class operator TTime.GreaterThan(const ATime1, ATime2: TTime): Boolean;
begin
  { Simple check }
  Result := CompareTime(ATime1.FDateTime, ATime2.FDateTime) > 0;
end;

class operator TTime.GreaterThanOrEqual(const ATime1, ATime2: TTime): Boolean;
begin
  { Simple check }
  Result := CompareTime(ATime1.FDateTime, ATime2.FDateTime) >= 0;
end;

class operator TTime.Implicit(const ADateTime: System.TDateTime): TTime;
begin
  { Call constructor }
  Result := TTime.Create(ADateTime);
end;

class operator TTime.Implicit(const ATime: TTime): System.TDateTime;
begin
  { Simple Copy }
  Result := ATime.FDateTime;
end;

class operator TTime.LessThan(const ATime1, ATime2: TTime): Boolean;
begin
  { Simple check }
  Result := CompareTime(ATime1.FDateTime, ATime2.FDateTime) < 0;
end;

class operator TTime.LessThanOrEqual(const ATime1, ATime2: TTime): Boolean;
begin
  { Simple check }
  Result := CompareTime(ATime1.FDateTime, ATime2.FDateTime) <= 0;
end;

class operator TTime.NotEqual(const ATime1, ATime2: TTime): Boolean;
begin
  { Simple check }
  Result := CompareTime(ATime1.FDateTime, ATime2.FDateTime) <> 0;
end;

class operator TTime.Subtract(const ATime1, ATime2: TTime): TTimeSpan;
begin
  { Create diff }
  Result := TTimeSpan.FromMilliseconds(MilliSecondsBetween(ATime1.FDateTime, ATime2.FDateTime));
end;

class operator TTime.Subtract(const ATime: TTime;
  const ASpan: TTimeSpan): TTime;
begin
  { Use Inc with negatve msecs as base }
  Result := TTime.Create(IncMilliSecond(ATime.FDateTime, -1 * Round(ASpan.TotalMilliseconds)));
end;

function TTime.ToString: String;
begin
  { Call delphi function }
  Result := TimeToStr(FDateTime);
end;

function TTime.ToString(const FormatSettings: TFormatSettings): String;
begin
  { Call delphi function }
  Result := TimeToStr(FDateTime, FormatSettings);
end;

constructor TTime.Create(const ATime: String;
  const FormatSettings: TFormatSettings);
begin
  { Convert to datetime - will throw if erorr }
  try
    FDateTime := StrToTime(ATime, FormatSettings);
  except
    on Exception do
       ExceptionHelper.Throw_InvalidArgumentFormatError('ATime');
  end;

  { Decode }
  DecodeTime(FDateTime, FHour, FMinute, FSecond, FMilli);
end;

class constructor TTime.Create;
begin
  TType<TTime>.Register(TTimeType);
end;

class destructor TTime.Destroy;
begin
  TType<TTime>.Unregister();
end;

{ TTimeType }

function TTimeType.Compare(const AValue1, AValue2: TTime): NativeInt;
begin
  Result := CompareTime(AValue1.FDateTime, AValue2.FDateTime);
end;

procedure TTimeType.DoDeserialize(const AInfo: TValueInfo; out AValue: TTime; const AContext: IDeserializationContext);
var
  LDT: System.TDateTime;
begin
  AContext.GetValue(AInfo, LDT);
  AValue := TTime.Create(LDT);
end;

procedure TTimeType.DoSerialize(const AInfo: TValueInfo; const AValue: TTime; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue.FDateTime);
end;

function TTimeType.Family: TTypeFamily;
begin
  Result := tfDate;
end;

function TTimeType.GenerateHashCode(const AValue: TTime): NativeInt;
{$IF SizeOf(TDateTime) <= SizeOf(NativeInt)}
var
  X: TDateTime;
  LongOp: NativeInt absolute X;
begin
  X := AValue.FDateTime;

  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  X: TDateTime;
  LongOp: array[0..1] of Integer absolute X;
begin
  X := AValue.FDateTime;

  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TTimeType.GetString(const AValue: TTime): String;
begin
  Result := TimeToStr(AValue.FDateTime);
end;

function TTimeType.TryConvertFromVariant(const AValue: Variant; out ORes: TTime): Boolean;
begin
  { May fail }
  try
    ORes := TTime.Create(System.TDateTime(AValue));
  except
    Exit(false);
  end;

  Result := true;
end;

function TTimeType.TryConvertToVariant(const AValue: TTime; out ORes: Variant): Boolean;
begin
  { Simple assignment }
  ORes := AValue.FDateTime;
  Result := true;
end;

type
 { Time Support }
  TDateTimeType = class(TRecordType<TDateTime>)
  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TDateTime; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TDateTime; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: TDateTime): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: TDateTime): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: TDateTime): String; override;

    { Type information }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: TDateTime; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TDateTime): Boolean; override;
  end;


{ TDateTime }

constructor TDateTime.Create(const ADateTime: String);
begin
  { Convert from string - should throw exception if failed }
  try
    FDateTime := StrToDateTime(ADateTime);
  except
    on Exception do
       ExceptionHelper.Throw_InvalidArgumentFormatError('ADateTime');
  end;
end;

constructor TDateTime.Create(const ADateTime: System.TDateTime);
begin
  { Just initialize internals }
  FDateTime := ADateTime;
end;

constructor TDateTime.Create(const AYear, AMonth, ADay, AHour, AMinute, ASecond,
  AMilli: Word);
begin
  if not IsValidDateTime(AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilli) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AYear/AMonth/ADay/AHour/AMinute/ASecond/AMilli');

  { Create form variables. Should throw if error. }
  FDateTime := EncodeDateTime(AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilli);
end;

class operator TDateTime.Add(const ASpan: TTimeSpan;
  const ADateTime: TDateTime): TDateTime;
begin
  { Use supplied milliseconds value }
  Result := TDateTime.Create(IncMilliSecond(ADateTime.FDateTime, Round(ASpan.TotalMilliseconds)));
end;

class operator TDateTime.Add(const ADateTime: TDateTime;
  const ASpan: TTimeSpan): TDateTime;
begin
  { Use supplied milliseconds value }
  Result := TDateTime.Create(IncMilliSecond(ADateTime.FDateTime, Round(ASpan.TotalMilliseconds)));
end;

function TDateTime.AddDays(const AValue: NativeInt): TDateTime;
begin
  { Create a new date +N }
  try
    Result := TDateTime.Create(IncDay(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDateTime.AddHours(const AValue: NativeInt): TDateTime;
begin
  { Create a new date +N }
  try
    Result := TDateTime.Create(IncHour(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDateTime.AddMilliseconds(const AValue: NativeInt): TDateTime;
begin
  { Create a new date +N }
  try
    Result := TDateTime.Create(IncMilliSecond(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDateTime.AddMinutes(const AValue: NativeInt): TDateTime;
begin
  { Create a new date +N }
  try
    Result := TDateTime.Create(IncMinute(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDateTime.AddMonths(const AValue: NativeInt): TDateTime;
begin
  { Create a new date +N }
  try
    Result := TDateTime.Create(IncMonth(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDateTime.AddSeconds(const AValue: NativeInt): TDateTime;
begin
  { Create a new date +N }
  try
    Result := TDateTime.Create(IncSecond(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

function TDateTime.AddYears(const AValue: NativeInt): TDateTime;
begin
  { Create a new date +N }
  try
    Result := TDateTime.Create(IncYear(FDateTime, AValue));
  except
    on Exception do
       ExceptionHelper.Throw_ArgumentOutOfRangeError('AValue');
  end;
end;

class operator TDateTime.Equal(const ADateTime1,
  ADateTime2: TDateTime): Boolean;
begin
  { Simple check }
  Result := CompareDateTime(ADateTime1.FDateTime, ADateTime2.FDateTime) = 0;
end;

class function TDateTime.FromUnixTime(const UnixTime: Int64): TDateTime;
begin
  { Simply call the sys function }
  Result := TDateTime.Create(UnixToDateTime(UnixTime));
end;

constructor TDateTime.Create(const ADateTime: String;
  const FormatSettings: TFormatSettings);
begin
  { Convert from string - should throw exception if failed }
  try
    FDateTime := StrToDateTime(ADateTime, FormatSettings);
  except
    on Exception do
       ExceptionHelper.Throw_InvalidArgumentFormatError('ADateTime');
  end;
end;

class constructor TDateTime.Create;
begin
  TType<TDateTime>.Register(TDateTimeType);
end;

class destructor TDateTime.Destroy;
begin
  TType<TDateTime>.Unregister();
end;

function TDateTime.GetDate: TDate;
begin
  { Pass internal field }
  Result := TDate.Create(FDateTime);
end;

class function TDateTime.GetNow: TDateTime;
begin
  { Get current Date }
  Result := TDateTime.Create(SysUtils.Now());
end;

class function TDateTime.GetSysTime: TDateTime;
var
  LTime: TSystemTime;
begin
  { Read the local time/date and convert }
  GetSystemTime(LTime);
  Result := TDateTime.Create(SystemTimeToDateTime(LTime));
end;

function TDateTime.GetTime: TTime;
begin
  { Pass internal field }
  Result := TTime.Create(FDateTime);
end;

class function TDateTime.GetType: IType<TDateTime>;
begin
  Result := TDateTimeType.Create;
end;

class operator TDateTime.GreaterThan(const ADateTime1,
  ADateTime2: TDateTime): Boolean;
begin
  { Simple check }
  Result := CompareDateTime(ADateTime1.FDateTime, ADateTime2.FDateTime) > 0;
end;

class operator TDateTime.GreaterThanOrEqual(const ADateTime1,
  ADateTime2: TDateTime): Boolean;
begin
  { Simple check }
  Result := CompareDateTime(ADateTime1.FDateTime, ADateTime2.FDateTime) >= 0;
end;

class operator TDateTime.Implicit(const ADateTime: TDateTime): System.TDateTime;
begin
  { Pass copy of internal field }
  Result := ADateTime.FDateTime;
end;

class operator TDateTime.Implicit(const ADateTime: System.TDateTime): TDateTime;
begin
  { Simple copy }
  Result := TDateTime.Create(ADateTime);
end;

class operator TDateTime.LessThan(const ADateTime1,
  ADateTime2: TDateTime): Boolean;
begin
  { Simple check }
  Result := CompareDateTime(ADateTime1.FDateTime, ADateTime2.FDateTime) < 0;
end;

class operator TDateTime.LessThanOrEqual(const ADateTime1,
  ADateTime2: TDateTime): Boolean;
begin
  { Simple check }
  Result := CompareDateTime(ADateTime1.FDateTime, ADateTime2.FDateTime) <= 0;
end;

class operator TDateTime.NotEqual(const ADateTime1,
  ADateTime2: TDateTime): Boolean;
begin
  { Simple check }
  Result := CompareDateTime(ADateTime1.FDateTime, ADateTime2.FDateTime) <> 0;
end;

class operator TDateTime.Subtract(const ADateTime: TDateTime;
  const ASpan: TTimeSpan): TDateTime;
begin
  { Use supplied milliseconds value }
  Result := TDateTime.Create(IncMilliSecond(ADateTime.FDateTime, -1 * Round(ASpan.TotalMilliseconds)));
end;

class operator TDateTime.Subtract(const ADateTime1,
  ADateTime2: TDateTime): TTimeSpan;
begin
  Result := TTimeSpan.FromMilliseconds(MilliSecondsBetween(ADateTime1.FDateTime, ADateTime2.FDateTime));
end;

function TDateTime.ToString: String;
begin
  { Use Delphi functions }
  Result := DateTimeToStr(FDateTime);
end;

function TDateTime.ToString(const FormatSettings: TFormatSettings): String;
begin
  { Use Delphi functions }
  Result := DateTimeToStr(FDateTime, FormatSettings);
end;

function TDateTime.ToString(const Format: String): String;
begin
  { Use Delphi functions }
  DateTimeToString(Result, Format, FDateTime);
end;

function TDateTime.ToString(const Format: String;
  const FormatSettings: TFormatSettings): String;
begin
  DateTimeToString(Result, Format, FDateTime, FormatSettings);
end;

function TDateTime.ToUnixTime: Int64;
begin
  { Call the sys function }
  Result := DateTimeToUnix(FDateTime);
end;

{ TDateTimeType }

function TDateTimeType.Compare(const AValue1, AValue2: TDateTime): NativeInt;
begin
  Result := CompareDateTime(AValue1.FDateTime, AValue2.FDateTime);
end;

procedure TDateTimeType.DoDeserialize(const AInfo: TValueInfo; out AValue: TDateTime; const AContext: IDeserializationContext);
var
  LDT: System.TDateTime;
begin
  AContext.GetValue(AInfo, LDT);
  AValue := TDateTime.Create(LDT);
end;

procedure TDateTimeType.DoSerialize(const AInfo: TValueInfo; const AValue: TDateTime; const AContext: ISerializationContext);
begin
  AContext.AddValue(AInfo, AValue.FDateTime);
end;

function TDateTimeType.Family: TTypeFamily;
begin
  Result := tfDate;
end;

function TDateTimeType.GenerateHashCode(const AValue: TDateTime): NativeInt;
{$IF SizeOf(TDateTime) <= SizeOf(NativeInt)}
var
  X: TDateTime;
  LongOp: NativeInt absolute X;
begin
  X := AValue.FDateTime;

  if AValue = 0 then
     Result := 0
  else
     Result := LongOp;
end;
{$ELSE}
var
  X: TDateTime;
  LongOp: array[0..1] of Integer absolute X;
begin
  X := AValue.FDateTime;

  if AValue = 0 then
     Result := 0
  else
     Result := LongOp[1] xor LongOp[0];
end;
{$IFEND}

function TDateTimeType.GetString(const AValue: TDateTime): String;
begin
  Result := DateTimeToStr(AValue.FDateTime);
end;

function TDateTimeType.TryConvertFromVariant(const AValue: Variant; out ORes: TDateTime): Boolean;
begin
  { May fail }
  try
    ORes := TDateTime.Create(System.TDateTime(AValue));
  except
    Exit(false);
  end;

  Result := true;
end;

function TDateTimeType.TryConvertToVariant(const AValue: TDateTime; out ORes: Variant): Boolean;
begin
  { Simple assignment }
  ORes := AValue.FDateTime;
  Result := true;
end;

end.
