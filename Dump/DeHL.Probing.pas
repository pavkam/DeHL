(*
* Copyright (c) 2009, Ciobanu Alexandru
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

{$I defines.inc}
unit DeHL.Probing;
interface
{$IFDEF EXTENDED_RTTI}
uses
  SysUtils,
  Rtti,
  DeHL.Base,
  DeHL.Exceptions,
  DeHL.Types;

type
  { Special type used for class/record field retrieval }
  Field<T, TField> = record
  private type
    TFunctorType = (ftLower, ftLowerOrEqual, ftGreater, ftGreaterOrEqual, ftEqual);

  private class var
    FRttiContext: TRttiContext;

    class function GetValue(const AInstance: Pointer; const AField: TRttiField): TField; static; inline;
    class function MakeFunctor(const AType: TFunctorType; const AName: String; const AValue: TField): TFunc<T, Boolean>; static;
  public
    class function Lower(const AName: String; const AValue: TField): TFunc<T, Boolean>; static; inline;
    class function LowerOrEqual(const AName: String; const AValue: TField): TFunc<T, Boolean>; static; inline;
    class function Greater(const AName: String; const AValue: TField): TFunc<T, Boolean>; static; inline;
    class function GreaterOrEqual(const AName: String; const AValue: TField): TFunc<T, Boolean>; static; inline;
    class function Equal(const AName: String; const AValue: TField): TFunc<T, Boolean>; static; inline;
  end;

implementation

{ Field<T, TField> }

class function Field<T, TField>.Equal(const AName: String; const AValue: TField): TFunc<T, Boolean>;
begin
  { Call the factory method }
  Result := MakeFunctor(ftEqual, AName, AValue);
end;

class function Field<T, TField>.Lower(const AName: String; const AValue: TField): TFunc<T, Boolean>;
begin
  { Call the factory method }
  Result := MakeFunctor(ftLower, AName, AValue);
end;

class function Field<T, TField>.GetValue(const AInstance: Pointer; const AField: TRttiField): TField;
begin
  Result := AField.GetValue(AInstance).AsType<TField>();
end;

class function Field<T, TField>.Greater(const AName: String; const AValue: TField): TFunc<T, Boolean>;
begin
  { Call the factory method }
  Result := MakeFunctor(ftGreater, AName, AValue);
end;

class function Field<T, TField>.LowerOrEqual(const AName: String; const AValue: TField): TFunc<T, Boolean>;
begin
  { Call the factory method }
  Result := MakeFunctor(ftLowerOrEqual, AName, AValue);
end;

class function Field<T, TField>.MakeFunctor(const AType: TFunctorType; const AName: String; const AValue: TField): TFunc<T, Boolean>;
var
  LType: IType<T>;
  LFieldType: IType<TField>;
  LField: TRttiField;
begin
  { Obtain the type support for T: expected to be record }
  LType := TType<T>.Default;
  LFieldType := TType<TField>.Default;

  if LType.TypeInfo = nil then
    ExceptionHelper.Throw_MissingFieldError(LType.Name, LFieldType.Name);

  { Obtain the Rtti information }
  LField := FRttiContext.GetType(LType.TypeInfo).GetField(AName);

  if LField = nil then
    ExceptionHelper.Throw_MissingFieldError(LType.Name, LFieldType.Name);

  { Generate the anonymous procedure }
  case AType of
    ftLower:
      Result := function(Arg1: T): Boolean begin Exit(LFieldType.Compare(GetValue(@Arg1, LField), AValue) < 0); end;

    ftLowerOrEqual:
      Result := function(Arg1: T): Boolean begin Exit(LFieldType.Compare(GetValue(@Arg1, LField), AValue) <= 0); end;

    ftGreater:
      Result := function(Arg1: T): Boolean begin Exit(LFieldType.Compare(GetValue(@Arg1, LField), AValue) > 0); end;

    ftGreaterOrEqual:
      Result := function(Arg1: T): Boolean begin Exit(LFieldType.Compare(GetValue(@Arg1, LField), AValue) >= 0); end;

    ftEqual:
      Result := function(Arg1: T): Boolean begin Exit(LFieldType.AreEqual(GetValue(@Arg1, LField), AValue)); end;
  end;
end;

class function Field<T, TField>.GreaterOrEqual(const AName: String; const AValue: TField): TFunc<T, Boolean>;
begin
  { Call the factory method }
  Result := MakeFunctor(ftGreaterOrEqual, AName, AValue);
end;
{$ELSE}
implementation
{$ENDIF}

end.
