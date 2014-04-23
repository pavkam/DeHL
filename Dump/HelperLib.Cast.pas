(*
* Copyright (c) 2008, Ciobanu Alexandru
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

unit HelperLib.Cast;
interface
uses SysUtils;

type
  Cast = record
  public
    class function ToString(const AParam : SmallInt) : String; overload; inline; static;
    class function ToString(const AParam : Byte) : String; overload; inline; static;
    class function ToString(const AParam : ShortInt) : String; overload; inline; static;
    class function ToString(const AParam : Word) : String; overload; inline; static;
    class function ToString(const AParam : Cardinal) : String; overload; inline; static;
    class function ToString(const AParam : Integer) : String; overload; inline; static;
    class function ToString(const AParam : UInt64) : String; overload; inline; static;
    class function ToString(const AParam : Int64) : String; overload; inline; static;

    class function ToString(const AParam : Single) : String; overload; inline; static;
    class function ToString(const AParam : Single; const FormatSettings : TFormatSettings) : String; overload; inline; static;
    class function ToString(const AParam : Real) : String; overload; inline; static;
    class function ToString(const AParam : Real; const FormatSettings : TFormatSettings) : String; overload; inline; static;
    class function ToString(const AParam : Real48) : String; overload; inline; static;
    class function ToString(const AParam : Real48; const FormatSettings : TFormatSettings) : String; overload; inline; static;
    class function ToString(const AParam : Double) : String; overload; inline; static;
    class function ToString(const AParam : Double; const FormatSettings : TFormatSettings) : String; overload; inline; static;
    class function ToString(const AParam : Extended) : String; overload; inline; static;
    class function ToString(const AParam : Extended; const FormatSettings : TFormatSettings) : String; overload; inline; static;
    class function ToString(const AParam : Currency) : String; overload; inline; static;
    class function ToString(const AParam : Currency; const FormatSettings : TFormatSettings) : String; overload; inline; static;
    class function ToString(const AParam : Comp) : String; overload; inline; static;
    class function ToString(const AParam : Comp; const FormatSettings : TFormatSettings) : String; overload; inline; static;



    class function ToString(const AParam : ShortString) : String; overload; inline; static;
    class function ToString(const AParam : String) : String; overload; inline; static;
    class function ToString(const AParam : Char) : String; overload; inline; static;
    class function ToString(const AParam : PChar) : String; overload; inline; static;

    class function ToString(const AParam : Boolean) : String; overload; inline; static;
    class function ToString(const AParam : ByteBool) : String; overload; inline; static;
    class function ToString(const AParam : WordBool) : String; overload; inline; static;
    class function ToString(const AParam : LongBool) : String; overload; inline; static;

    class function ToString(const AParam : Pointer) : String; overload; inline; static;
  end;

implementation

{ Cast }

class function Cast.ToString(const AParam: Integer): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: Real): String;
begin
  Result := FloatToStr(AParam);
end;

class function Cast.ToString(const AParam: Single): String;
begin
  Result := FloatToStr(AParam);
end;

class function Cast.ToString(const AParam: Int64): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: Extended): String;
begin
  Result := FloatToStr(AParam);
end;

class function Cast.ToString(const AParam: Double): String;
begin
  Result := FloatToStr(AParam);
end;

class function Cast.ToString(const AParam: Real48): String;
begin
  Result := FloatToStr(AParam);
end;

class function Cast.ToString(const AParam: ShortInt): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: Byte): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: SmallInt): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: UInt64): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: Cardinal): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: Word): String;
begin
  Result := IntToStr(AParam);
end;

class function Cast.ToString(const AParam: Currency): String;
begin
  Result := FloatToStr(AParam);
end;

class function Cast.ToString(const AParam: ByteBool): String;
begin
  Result := BoolToStr(AParam, true);
end;

class function Cast.ToString(const AParam: Boolean): String;
begin
  Result := BoolToStr(AParam, true);
end;

class function Cast.ToString(const AParam: PChar): String;
begin
  Result := AParam;
end;

class function Cast.ToString(const AParam: Pointer): String;
begin
  Result := IntToStr(Integer(AParam));
end;

class function Cast.ToString(const AParam: Real48;
  const FormatSettings: TFormatSettings): String;
begin
  Result := FloatToStr(AParam, FormatSettings);
end;

class function Cast.ToString(const AParam: Real;
  const FormatSettings: TFormatSettings): String;
begin
  Result := FloatToStr(AParam, FormatSettings);
end;

class function Cast.ToString(const AParam: Single;
  const FormatSettings: TFormatSettings): String;
begin
  Result := FloatToStr(AParam, FormatSettings);
end;

class function Cast.ToString(const AParam: Double;
  const FormatSettings: TFormatSettings): String;
begin
  Result := FloatToStr(AParam, FormatSettings);
end;

class function Cast.ToString(const AParam: Comp;
  const FormatSettings: TFormatSettings): String;
begin
  Result := FloatToStr(AParam, FormatSettings);
end;

class function Cast.ToString(const AParam: Currency;
  const FormatSettings: TFormatSettings): String;
begin
  Result := FloatToStr(AParam, FormatSettings);
end;

class function Cast.ToString(const AParam: Extended;
  const FormatSettings: TFormatSettings): String;
begin
  Result := FloatToStr(AParam, FormatSettings);
end;

class function Cast.ToString(const AParam: Comp): String;
begin
  Result := FloatToStr(AParam);
end;

class function Cast.ToString(const AParam: LongBool): String;
begin
  Result := BoolToStr(AParam, true);
end;

class function Cast.ToString(const AParam: WordBool): String;
begin
  Result := BoolToStr(AParam, true);
end;

class function Cast.ToString(const AParam: ShortString): String;
begin
  Result := String(AParam);
end;

class function Cast.ToString(const AParam: Char): String;
begin
  Result := AParam;
end;

class function Cast.ToString(const AParam: String): String;
begin
  Result := AParam;
end;

end.
