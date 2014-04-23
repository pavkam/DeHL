(*
* Copyright (c) 2009-2010, Ciobanu Alexandru
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
unit DeHL.Conversion;
interface
uses SysUtils,
     TypInfo,
     DeHL.Base,
     DeHL.Types,
     DeHL.Cloning,
     DeHL.StrConsts,
     DeHL.Exceptions;

type
  ///  <summary>Defines basic traits that all converters must implement.</summary>
  ///  <remarks>This interface defines only two methods that allow converting from values of type
  ///  <c>T1</c> to values of type <c>T2</c>.</remarks>
  IConverter<T1, T2> = interface
    ///  <summary>Tries to convert a value of type <c>T1</c> to a value of type <c>T2</c>.</summary>
    ///  <param name="AFrom">The value to convert.</param>
    ///  <param name="ATo">The output converted value.</param>
    ///  <returns><c>True</c> if the conversion was succeseful; <c>False</c> otherwise.</returns>
    function TryConvert(const AFrom: T1; out ATo: T2): Boolean;

    ///  <summary>Converts a value of type <c>T1</c> to a value of type <c>T2</c>.</summary>
    ///  <param name="AFrom">The value to convert.</param>
    ///  <returns>The output converted value.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported">The conversion failed.</exception>
    function Convert(const AFrom: T1): T2;
  end;

  ///  <summary>Procedural type that defines a converter method.</summary>
  ///  <param name="AFrom">The value to convert.</param>
  ///  <param name="ATo">The output converted value.</param>
  ///  <returns><c>True</c> if the conversion was succeseful; <c>False</c> otherwise.</returns>
  ///  <remarks>Procedures of this type can be registered with
  ///  <see cref="DeHL.Conversion|TConverter&lt;TIn, TOut&gt;">DeHL.Conversion.TConverter&lt;TIn, TOut&gt;</see>
  ///  to provide direct type-to-type conversion.</remarks>
  TConvertProc<TIn, TOut> = reference to function(const AIn: TIn; out AOut: TOut): Boolean;

  ///  <summary>Non-generic class that holds the type-to-type converter mappings.</summary>
  ///  <remarks>This class has no direct purpose. Its primary use is to hold converter mappings.</remarks>
  TConverter = class(TSimpleObject)
  private class var
    FMapping: TCorePointerDictionary;

    { ... }
    class constructor Create;
    class destructor Destroy;

    { Internal only obviously }
    class function GetConverter(const AFrom, ATo: PTypeInfo): IInterface;
    class procedure SetConverter(const AFrom, ATo: PTypeInfo; const AProc: IInterface);

    { Stock converters. Registering most conversions that are possible in RTL,
      minus the ones that do not make sense. }
    class procedure RegisterByte();
    class procedure RegisterShortInt();
    class procedure RegisterWord();
    class procedure RegisterSmallInt();
    class procedure RegisterLongWord();
    class procedure RegisterLongInt();
    class procedure RegisterUInt64();
    class procedure RegisterInt64();
    class procedure RegisterSingle();
    class procedure RegisterDouble();
    class procedure RegisterExtended();
    class procedure RegisterComp();
    class procedure RegisterCurrency();
    class procedure RegisterAnsiChar();
    class procedure RegisterWideChar();
    class procedure RegisterShortString();
    class procedure RegisterAnsiString();
    class procedure RegisterWideString();
    class procedure RegisterUnicodeString();
    class procedure RegisterBoolean();
    class procedure RegisterByteBool();
    class procedure RegisterWordBool();
    class procedure RegisterLongBool();
    class procedure RegisterPointer();
    class procedure RegisterUCS4Char();
    class procedure RegisterUCS4String();
    class procedure RegisterInterface();
    class procedure RegisterMetaclass();
    class procedure RegisterClass();
    class procedure RegisterDate();
    class procedure RegisterTime();
    class procedure RegisterDateTime();
  end;

  ///  <summary>Provides type-to-type conversion support.</summary>
  ///  <remarks>Instances of this type can be used to convert from any generic type to another generic type
  ///  (provided a conversion between the two exists). If no direct conversion between two types exist,
  ///  the variant conversion is used instead.</remarks>
  TConverter<TIn, TOut> = class sealed(TRefCountedObject, IConverter<TIn, TOut>, ICloneable)
  private
    FConvertProc: TConvertProc<TIn, TOut>;
    FInType: IType<TIn>;
    FOutType: IType<TOut>;

    { Internal helpers }
    class function TryMapTypeToStandard(const AInType: PTypeInfo; out AStdType: PTypeInfo): Boolean;
    procedure SelectConverterProc;

    class function GetConverter: TConvertProc<TIn, TOut>; static;
    class procedure SetConverter(const Value: TConvertProc<TIn, TOut>); static;

    class function AsIntf(const AAnonMethod): Pointer;
  public
    ///  <summary>Creates a new instance of <see cref="DeHL.Conversion|TConverter&lt;TIn, TOut&gt;">DeHL.Conversion.TConverter&lt;TIn, TOut&gt;</see> class.</summary>
    ///  <param name="AInType">A type class describing the input values.</param>
    ///  <param name="AOutType">A type class describing the output values.</param>
    ///  <remarks>Use this constructor if you try to convert from or to a type that defines custom
    ///  variant conversion support.</remarks>
    constructor Create(const AInType: IType<TIn>; const AOutType: IType<TOut>); overload;

    ///  <summary>Creates a new instance of <see cref="DeHL.Conversion|TConverter&lt;TIn, TOut&gt;">DeHL.Conversion.TConverter&lt;TIn, TOut&gt;</see> class.</summary>
    ///  <remarks>The default type classes are used.</remarks>
    constructor Create(); overload;

    ///  <summary>Converts a value of type <c>TIn</c> to a value of type <c>TOut</c>.</summary>
    ///  <param name="AFrom">The value to convert.</param>
    ///  <returns>The output converted value.</returns>
    ///  <exception cref="DeHL.Exceptions|ETypeConversionNotSupported">The conversion failed.</exception>
    function Convert(const AIn: TIn): TOut;

    ///  <summary>Tries to convert a value of type <c>TIn</c> to a value of type <c>TOut</c>.</summary>
    ///  <param name="AFrom">The value to convert.</param>
    ///  <param name="ATo">The output converted value.</param>
    ///  <returns><c>True</c> if the conversion was succeseful; <c>False</c> otherwise.</returns>
    function TryConvert(const AIn: TIn; out AOut: TOut): Boolean;

    ///  <summary>Creates a perfect copy of this object converter.</summary>
    ///  <returns>A new converter.</returns>
    function Clone(): TObject;

    ///  <summary>Specifies the direct converter method.</summary>
    ///  <param name="AFrom">The value to convert.</param>
    ///  <param name="ATo">The output converted value.</param>
    ///  <returns><c>True</c> if the conversion was succeseful; <c>False</c> otherwise.</returns>
    class property Method: TConvertProc<TIn, TOut> read GetConverter write SetConverter;
  end;

implementation
uses Character, DateUtils;

{ TConverter<TIn, TOut> }

class function TConverter<TIn, TOut>.AsIntf(const AAnonMethod): Pointer;
begin
  Pointer(Result) := Pointer(AAnonMethod);
end;

function TConverter<TIn, TOut>.Clone: TObject;
begin
  { Copy myself }
  Result := TConverter<TIn, TOut>.Create(FInType, FOutType);
end;

function TConverter<TIn, TOut>.Convert(const AIn: TIn): TOut;
begin
  if not TryConvert(AIn, Result) then
    ExceptionHelper.Throw_ConversionNotSupported(FOutType.Name);
end;

constructor TConverter<TIn, TOut>.Create;
begin
  { Default types }
  Create(TType<TIn>.Default, TType<TOut>.Default);
end;

class function TConverter<TIn, TOut>.GetConverter: TConvertProc<TIn, TOut>;
var
  LInPtr, LOutPtr: PTypeInfo;
begin
  LInPtr := TypeInfo(TIn);
  LOutPtr := TypeInfo(TOut);

  if (LInPtr = nil) or (LOutPtr = nil) then
    ExceptionHelper.Throw_CustomTypeHasNoRTTI();

  Result := TConvertProc<TIn, TOut>(TConverter.GetConverter(LInPtr, LOutPtr));
end;

constructor TConverter<TIn, TOut>.Create(const AInType: IType<TIn>; const AOutType: IType<TOut>);
begin
  { Check parameters }
  if AInType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AInType');

  if AOutType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AOutType');

  { Copy references }
  FInType := AInType;
  FOutType := AOutType;

  { Select the converter procedure }
  SelectConverterProc();
end;

procedure TConverter<TIn, TOut>.SelectConverterProc;
var
  LInStd, LOutStd: PTypeInfo;
  LClass: TClass;
  LGUID: TGUID;
  LData: PTypeData;
begin
  { Step 0/0. If it's the same type make up a simple passthrough method }
  if (FInType.TypeInfo = FOutType.TypeInfo) then
  begin
    FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: TIn; out AOut: TIn): Boolean
    begin
      AOut := AIn;
      Exit(true);
    end);

    { And that's it in this case }
    Exit;
  end;

  { Step 0/1. Check if both types have type information. If not, use their Variant conversions }
  if (FInType.TypeInfo = nil) or (FOutType.TypeInfo = nil) then
  begin
    FConvertProc := function(const AIn: TIn; out AOut: TOut): Boolean
    var
      LIntermediate: Variant;
    begin
      { Convert through variants if possible of course }
      Result := FInType.TryConvertToVariant(AIn, LIntermediate) and
                FOutType.TryConvertFromVariant(LIntermediate, AOut);
    end;

    { And that's it in this case }
    Exit;
  end;

  { Step 1. Try to find a direct mapping between TIn and TOut }
  FConvertProc := TConvertProc<TIn, TOut>(TConverter.GetConverter(FInType.TypeInfo, FOutType.TypeInfo));

  { Check that we found it and exit! }
  if Assigned(FConvertProc) then
    Exit;

  { Step 2. There is no direct conversion. Check for special cases that cannot be mapped directly. }

  {  Conversion Class -> Class  }
  if (FInType.TypeInfo^.Kind = tkClass) and (FOutType.TypeInfo.Kind = tkClass) then
  begin
    LData := GetTypeData(FOutType.TypeInfo);

    if LData <> nil then
    begin
      LClass := LData^.ClassType;
      FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: TObject; out AOut: TObject): Boolean
      begin
        Result := (AIn = nil) or (AIn.ClassType.InheritsFrom(LClass));
        if Result then
          AOut := AIn;
      end);

      Exit;
    end;
  end;

  {  Conversion Class -> Interface  }
  if (FInType.TypeInfo^.Kind = tkClass) and (FOutType.TypeInfo.Kind = tkInterface) then
  begin
    LData := GetTypeData(FOutType.TypeInfo);
    if LData <> nil then
    begin
      LGUID := LData^.Guid;
      FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: TObject; out AOut: IInterface): Boolean
      begin
        if Assigned(AIn) then
        begin
          { First check if support is there the call Supports }
          Result := Supports(AIn.ClassType, LGUID) and Supports(AIn, LGUID, AOut);
        end else
        begin
          AOut := nil;
          Result := true;
        end;
      end);

      Exit;
    end;
  end;

  {  Conversion ClassRef -> ClassRef  }
  if (FInType.TypeInfo^.Kind = tkClassRef) and (FOutType.TypeInfo.Kind = tkClassRef) then
  begin
    LData := GetTypeData(FOutType.TypeInfo);
    if (LData <> nil) and (LData^.InstanceType <> nil) and (LData^.InstanceType^ <> nil) then
      LData := GetTypeData(LData^.InstanceType^);

    if LData <> nil then
      LClass := LData^.ClassType;

    if (LData <> nil) and (LClass <> nil) then
    begin
      FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: TClass; out AOut: TClass): Boolean
      begin
        Result := (AIn = nil) or (AIn.InheritsFrom(LClass));
        if Result then
          AOut := AIn;
      end);

      Exit;
    end;
  end;

  {  Conversion Class -> ClassRef  }
  if (FInType.TypeInfo^.Kind = tkClass) and (FOutType.TypeInfo.Kind = tkClassRef) then
  begin
    LData := GetTypeData(FOutType.TypeInfo);
    if (LData <> nil) and (LData^.InstanceType <> nil) and (LData^.InstanceType^ <> nil) then
      LData := GetTypeData(LData^.InstanceType^);

    if LData <> nil then
      LClass := LData^.ClassType;

    if (LData <> nil) and (LClass <> nil) then
    begin
      FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: TObject; out AOut: TClass): Boolean
      begin
        Result := (AIn = nil) or (AIn.InheritsFrom(LClass));
        if Result then
          if AIn <> nil then
            AOut := AIn.ClassType
          else
            AOut := nil;
      end);

      Exit;
    end;
  end;

  {  Conversion Interface -> Interface  }
  if (FInType.TypeInfo^.Kind = tkInterface) and (FOutType.TypeInfo.Kind = tkInterface) then
  begin
    LData := GetTypeData(FOutType.TypeInfo);
    if LData <> nil then
    begin
      LGUID := LData^.Guid;
      FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: IInterface; out AOut: IInterface): Boolean
      begin
        if Assigned(AIn) then
        begin
          Result := Supports(AIn, LGUID, AOut);
        end else
        begin
          AOut := nil;
          Result := true;
        end;
      end);

      Exit;
    end;
  end;

  { Step 3. There are no special cases left to tackle. Let's find the equivalent standard type for
    TIn and use it for what we need }

  if TryMapTypeToStandard(FInType.TypeInfo, LInStd) then
  begin
    FConvertProc := TConvertProc<TIn, TOut>(TConverter.GetConverter(LInStd, FOutType.TypeInfo));

    if Assigned(FConvertProc) then
      Exit;
  end else
    LInStd := nil;

  { Step 4. Bah! Let's use the same logic on TOut then }

  if TryMapTypeToStandard(FOutType.TypeInfo, LOutStd) then
  begin
    FConvertProc := TConvertProc<TIn, TOut>(TConverter.GetConverter(FInType.TypeInfo, LOutStd));

    if Assigned(FConvertProc) then
      Exit;
  end else
    LOutStd := nil;

  { Step 5/0. Maybe both TIn and TOut map to teh same standard type? }
  if (LInStd <> nil) and (LOutStd = LInStd) then
  begin
    FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: TIn; out AOut: TIn): Boolean
    begin
      AOut := AIn;
      Exit(true);
    end);

    { And that's it in this case }
    Exit;
  end;

  { Step 5/1. Oh my god! Let's use only standards when converting (if possible) }
  if (LInStd <> nil) and (LOutStd <> nil) then
  begin
    FConvertProc := TConvertProc<TIn, TOut>(TConverter.GetConverter(LInStd, LOutStd));

    if Assigned(FConvertProc) then
      Exit;
  end;

  { Step 6. Maybe it's TIn -> Variant? }
  if FOutType.TypeInfo^.Kind = tkVariant then
  begin
    FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: TIn; out AOut: Variant): Boolean
    begin
      { Convert to variant using TType's standards }
      Result := FInType.TryConvertToVariant(AIn, AOut);
    end);

    Exit;
  end;

  { Step 7. Maybe it's Variant -> TOut? }
  if FInType.TypeInfo^.Kind = tkVariant then
  begin
    FConvertProc := TConvertProc<TIn, TOut>(function(const AIn: Variant; out AOut: TOut): Boolean
    begin
      { Convert to variant using TType's standards }
      Result := FOutType.TryConvertFromVariant(AIn, AOut);
    end);

    Exit;
  end;

  { Step 8. OK, this is getting ridiculous! Fuck it, use full variant conversion }
  FConvertProc := function(const AIn: TIn; out AOut: TOut): Boolean
  var
    LIntermediate: Variant;
  begin
    { Convert through variants if possible of course }
    Result :=
      FInType.TryConvertToVariant(AIn, LIntermediate) and
      FOutType.TryConvertFromVariant(LIntermediate, AOut);
  end;

end;

class procedure TConverter<TIn, TOut>.SetConverter(const Value: TConvertProc<TIn, TOut>);
var
  LInPtr, LOutPtr: PTypeInfo;
begin
  LInPtr := TypeInfo(TIn);
  LOutPtr := TypeInfo(TOut);

  if (LInPtr = nil) or (LOutPtr = nil) then
    ExceptionHelper.Throw_CustomTypeHasNoRTTI();

  TConverter.SetConverter(LInPtr, LOutPtr, IInterface(AsIntf(Value)));
end;

function TConverter<TIn, TOut>.TryConvert(const AIn: TIn; out AOut: TOut): Boolean;
begin
  { Simply call the converter method to do the actual job. }
  Result := FConvertProc(AIn, AOut);
end;

class function TConverter<TIn, TOut>.TryMapTypeToStandard(const AInType: PTypeInfo; out AStdType: PTypeInfo): Boolean;
var
  LData: PTypeData;
begin
  AStdType := nil;
  LData := GetTypeData(AInType);

  case AInType^.Kind of
    tkInteger:
    begin
      ASSERT(LData <> nil);

      case LData^.OrdType of
        otSByte:
          AStdType := TypeInfo(ShortInt);
        otUByte:
          AStdType := TypeInfo(Byte);
        otSWord:
          AStdType := TypeInfo(SmallInt);
        otUWord:
          AStdType := TypeInfo(Word);
        otSLong:
          AStdType := TypeInfo(LongInt);
        otULong:
          AStdType := TypeInfo(LongWord);
      end;
    end;

    tkChar:
      AStdType := TypeInfo(AnsiChar);

    tkFloat:
    begin
      ASSERT(LData <> nil);

      case LData^.FloatType of
        ftSingle:
          AStdType := TypeInfo(Single);
        ftExtended:
          AStdType := TypeInfo(Extended);
        ftDouble:
          AStdType := TypeInfo(Double);
        ftComp:
          AStdType := TypeInfo(Comp);
        ftCurr:
          AStdType := TypeInfo(Currency);
      end;
    end;

    tkString:
      AStdType := TypeInfo(ShortString);

    tkClass:
      AStdType := TypeInfo(TObject);

    tkWChar:
      AStdType := TypeInfo(WideChar);

    tkLString:
      AStdType := TypeInfo(AnsiString);

    tkWString:
      AStdType := TypeInfo(WideString);

    tkInterface:
      AStdType := TypeInfo(IInterface);

    tkInt64:
    begin
      ASSERT(LData <> nil);

      if LData^.MaxInt64Value > LData^.MinInt64Value then
         AStdType := TypeInfo(Int64)
      else
         AStdType := TypeInfo(UInt64);
    end;

    tkUString:
      AStdType := TypeInfo(UnicodeString);

    tkClassRef:
      AStdType := TypeInfo(TClass);

    tkPointer:
      AStdType := TypeInfo(Pointer);
  end;

  Result := (AStdType <> nil);
end;

{ TConverter }

class constructor TConverter.Create;
begin
  FMapping := TCorePointerDictionary.Create();

  { Fill in the standard methods }
  RegisterByte();
  RegisterShortInt();
  RegisterWord();
  RegisterSmallInt();
  RegisterLongWord();
  RegisterLongInt();
  RegisterUInt64();
  RegisterInt64();
  RegisterSingle();
  RegisterDouble();
  RegisterExtended();
  RegisterComp();
  RegisterCurrency();
  RegisterAnsiChar();
  RegisterWideChar();
  RegisterShortString();
  RegisterAnsiString();
  RegisterWideString();
  RegisterUnicodeString();
  RegisterBoolean();
  RegisterByteBool();
  RegisterWordBool();
  RegisterLongBool();
  RegisterPointer();
  RegisterUCS4Char();
  RegisterUCS4String();
  RegisterInterface();
  RegisterMetaclass();
  RegisterClass();
  RegisterDate();
  RegisterTime();
  RegisterDateTime();
end;

class destructor TConverter.Destroy;
begin
  { Kill all convertions }
  FMapping.Clear(nil, procedure(Arg1: Pointer)
  begin
    if Arg1 <> nil then
    begin
      { Clear out the stored interfaces }
      TCorePointerDictionary(Arg1).Clear(nil, procedure(Arg2: Pointer)
      begin
        { simple }
        IInterface(Arg2)._Release;
      end);

      { Free the sub-dictionary }
      TCorePointerDictionary(Arg1).Free;
    end;
  end);

  { Free the mapping dictionary }
  FMapping.Free;
end;


class function TConverter.GetConverter(const AFrom, ATo: PTypeInfo): IInterface;
var
  LSub2: TCorePointerDictionary;
  LWas: Pointer;
begin
  { These should be checked upper in the call chain }
  ASSERT(AFrom <> ATo);
  ASSERT(AFrom <> nil);
  ASSERT(ATo <> nil);

  MonitorEnter(TConverter.FMapping);
  try
    if TConverter.FMapping.TryGetValue(AFrom, Pointer(LSub2)) and LSub2.TryGetValue(ATo, LWas) then
      Result := IInterface(LWas)
    else
      Result := nil;

  finally
    MonitorExit(TConverter.FMapping)
  end;
end;

class procedure TConverter.RegisterAnsiChar;
begin
  SetConverter(TypeInfo(AnsiChar), TypeInfo(ShortString),
   IInterface(function(const AIn: AnsiChar; out AOut: ShortString): Boolean
      begin
{$IFDEF BUG_ANSI_CHAR_IMPLICIT_STRING_OP}
        AOut := ShortString(AIn);
{$ELSE}
        AOut := AIn;
{$ENDIF}
        Exit(true);
      end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(WideChar),
   IInterface(function(const AIn: AnsiChar; out AOut: WideChar): Boolean
     begin AOut := string(AIn)[1]; Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(AnsiString),
   IInterface(function(const AIn: AnsiChar; out AOut: AnsiString): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(WideString),
   IInterface(function(const AIn: AnsiChar; out AOut: WideString): Boolean
     begin AOut := string(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(UnicodeString),
   IInterface(function(const AIn: AnsiChar; out AOut: UnicodeString): Boolean
     begin AOut := string(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(UCS4String),
   IInterface(function(const AIn: AnsiChar; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(string(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(Pointer),
   IInterface(function(const AIn: AnsiChar; out AOut: Pointer): Boolean
     begin AOut := Ptr(Byte(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(Boolean),
   IInterface(function(const AIn: AnsiChar; out AOut: Boolean): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(ByteBool),
   IInterface(function(const AIn: AnsiChar; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(WordBool),
   IInterface(function(const AIn: AnsiChar; out AOut: WordBool): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(LongBool),
   IInterface(function(const AIn: AnsiChar; out AOut: LongBool): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(ShortInt),
   IInterface(function(const AIn: AnsiChar; out AOut: ShortInt): Boolean
     begin AOut := ShortInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(SmallInt),
   IInterface(function(const AIn: AnsiChar; out AOut: SmallInt): Boolean
     begin AOut := SmallInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(Word),
   IInterface(function(const AIn: AnsiChar; out AOut: Word): Boolean
     begin AOut := Word(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(LongInt),
   IInterface(function(const AIn: AnsiChar; out AOut: LongInt): Boolean
     begin AOut := LongInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(LongWord),
   IInterface(function(const AIn: AnsiChar; out AOut: LongWord): Boolean
     begin AOut := LongWord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(Int64),
   IInterface(function(const AIn: AnsiChar; out AOut: Int64): Boolean
     begin AOut := Int64(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiChar), TypeInfo(UInt64),
   IInterface(function(const AIn: AnsiChar; out AOut: UInt64): Boolean
     begin AOut := UInt64(AIn); Exit(true); end)
  );
end;

class procedure TConverter.RegisterAnsiString;
begin
  SetConverter(TypeInfo(AnsiString), TypeInfo(AnsiChar),
   IInterface(function(const AIn: AnsiString; out AOut: AnsiChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := AIn[1];
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(WideChar),
   IInterface(function(const AIn: AnsiString; out AOut: WideChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := string(AIn)[1];
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(UCS4Char),
   IInterface(function(const AIn: AnsiString; out AOut: UCS4Char): Boolean
     var
       LTemp: UCS4String;
     begin
       LTemp := UnicodeStringToUCS4String(string(AIn));
       Result := (Length(LTemp) = 2);
       if Result then
         AOut := LTemp[0];
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(ShortString),
   IInterface(function(const AIn: AnsiString; out AOut: ShortString): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(WideString),
   IInterface(function(const AIn: AnsiString; out AOut: WideString): Boolean
     begin AOut := string(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(UnicodeString),
   IInterface(function(const AIn: AnsiString; out AOut: UnicodeString): Boolean
     begin AOut := string(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(UCS4String),
   IInterface(function(const AIn: AnsiString; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(string(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(TDate),
   IInterface(function(const AIn: AnsiString; out AOut: TDate): Boolean
     begin
       Result := TryStrToDate(string(AIn), TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(TTime),
   IInterface(function(const AIn: AnsiString; out AOut: TTime): Boolean
     begin
       Result := TryStrToTime(string(AIn), TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(TDateTime),
   IInterface(function(const AIn: AnsiString; out AOut: TDateTime): Boolean
     begin
       Result := TryStrToDateTime(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Boolean),
   IInterface(function(const AIn: AnsiString; out AOut: Boolean): Boolean
     begin
       Result := TryStrToBool(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(ByteBool),
   IInterface(function(const AIn: AnsiString; out AOut: ByteBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(WordBool),
   IInterface(function(const AIn: AnsiString; out AOut: WordBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(LongBool),
   IInterface(function(const AIn: AnsiString; out AOut: LongBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Pointer),
   IInterface(function(const AIn: AnsiString; out AOut: Pointer): Boolean
     var
{$IF SizeOf(Pointer) = SizeOf(Integer)}
       LTemp: Integer;
{$ELSE}
       LTemp: Int64;
{$IFEND}
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := Ptr(LTemp);
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Byte),
   IInterface(function(const AIn: AnsiString; out AOut: Byte): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(ShortInt),
   IInterface(function(const AIn: AnsiString; out AOut: ShortInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(SmallInt),
   IInterface(function(const AIn: AnsiString; out AOut: SmallInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Word),
   IInterface(function(const AIn: AnsiString; out AOut: Word): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(LongInt),
   IInterface(function(const AIn: AnsiString; out AOut: LongInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(LongWord),
   IInterface(function(const AIn: AnsiString; out AOut: LongWord): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Int64),
   IInterface(function(const AIn: AnsiString; out AOut: Int64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(UInt64),
   IInterface(function(const AIn: AnsiString; out AOut: UInt64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Single),
   IInterface(function(const AIn: AnsiString; out AOut: Single): Boolean
     begin
       Result := TryStrToFloat(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Double),
   IInterface(function(const AIn: AnsiString; out AOut: Double): Boolean
     begin
       Result := TryStrToFloat(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Extended),
   IInterface(function(const AIn: AnsiString; out AOut: Extended): Boolean
     begin
       Result := TryStrToFloat(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Comp),
   IInterface(function(const AIn: AnsiString; out AOut: Comp): Boolean
     var
       LTemp: Double;
     begin
       Result := TryStrToFloat(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(AnsiString), TypeInfo(Currency),
   IInterface(function(const AIn: AnsiString; out AOut: Currency): Boolean
     var
       LTemp: Extended;
     begin
       Result := TryStrToFloat(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );
end;

class procedure TConverter.RegisterBoolean;
begin
  SetConverter(TypeInfo(Boolean), TypeInfo(ShortString),
   IInterface(function(const AIn: Boolean; out AOut: ShortString): Boolean
     begin AOut := ShortString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(AnsiString),
   IInterface(function(const AIn: Boolean; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(WideString),
   IInterface(function(const AIn: Boolean; out AOut: WideString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Boolean; out AOut: UnicodeString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(UCS4String),
   IInterface(function(const AIn: Boolean; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(ByteBool),
   IInterface(function(const AIn: Boolean; out AOut: ByteBool): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(WordBool),
   IInterface(function(const AIn: Boolean; out AOut: WordBool): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(LongBool),
   IInterface(function(const AIn: Boolean; out AOut: LongBool): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Byte),
   IInterface(function(const AIn: Boolean; out AOut: Byte): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(ShortInt),
   IInterface(function(const AIn: Boolean; out AOut: ShortInt): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(SmallInt),
   IInterface(function(const AIn: Boolean; out AOut: SmallInt): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Word),
   IInterface(function(const AIn: Boolean; out AOut: Word): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(LongInt),
   IInterface(function(const AIn: Boolean; out AOut: LongInt): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(LongWord),
   IInterface(function(const AIn: Boolean; out AOut: LongWord): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Int64),
   IInterface(function(const AIn: Boolean; out AOut: Int64): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(UInt64),
   IInterface(function(const AIn: Boolean; out AOut: UInt64): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Single),
   IInterface(function(const AIn: Boolean; out AOut: Single): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Double),
   IInterface(function(const AIn: Boolean; out AOut: Double): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Extended),
   IInterface(function(const AIn: Boolean; out AOut: Extended): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Comp),
   IInterface(function(const AIn: Boolean; out AOut: Comp): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Boolean), TypeInfo(Currency),
   IInterface(function(const AIn: Boolean; out AOut: Currency): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );
end;

class procedure TConverter.RegisterByte;
begin
  SetConverter(TypeInfo(Byte), TypeInfo(AnsiChar),
   IInterface(function(const AIn: Byte; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(WideChar),
   IInterface(function(const AIn: Byte; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Pointer),
   IInterface(function(const AIn: Byte; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(ShortString),
   IInterface(function(const AIn: Byte; out AOut: ShortString): Boolean
     begin AOut := ShortString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(AnsiString),
   IInterface(function(const AIn: Byte; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(WideString),
   IInterface(function(const AIn: Byte; out AOut: WideString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Byte; out AOut: UnicodeString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(UCS4String),
   IInterface(function(const AIn: Byte; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Boolean),
   IInterface(function(const AIn: Byte; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(ByteBool),
   IInterface(function(const AIn: Byte; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(WordBool),
   IInterface(function(const AIn: Byte; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(LongBool),
   IInterface(function(const AIn: Byte; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(ShortInt),
   IInterface(function(const AIn: Byte; out AOut: ShortInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(SmallInt),
   IInterface(function(const AIn: Byte; out AOut: SmallInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Word),
   IInterface(function(const AIn: Byte; out AOut: Word): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(LongInt),
   IInterface(function(const AIn: Byte; out AOut: LongInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(LongWord),
   IInterface(function(const AIn: Byte; out AOut: LongWord): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Int64),
   IInterface(function(const AIn: Byte; out AOut: Int64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(UInt64),
   IInterface(function(const AIn: Byte; out AOut: UInt64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Single),
   IInterface(function(const AIn: Byte; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Double),
   IInterface(function(const AIn: Byte; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Extended),
   IInterface(function(const AIn: Byte; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Comp),
   IInterface(function(const AIn: Byte; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(Currency),
   IInterface(function(const AIn: Byte; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterByteBool;
begin
  SetConverter(TypeInfo(ByteBool), TypeInfo(ShortString),
   IInterface(function(const AIn: ByteBool; out AOut: ShortString): Boolean
     begin AOut := ShortString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(AnsiString),
   IInterface(function(const AIn: ByteBool; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(WideString),
   IInterface(function(const AIn: ByteBool; out AOut: WideString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(UnicodeString),
   IInterface(function(const AIn: ByteBool; out AOut: UnicodeString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(UCS4String),
   IInterface(function(const AIn: ByteBool; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Boolean),
   IInterface(function(const AIn: ByteBool; out AOut: Boolean): ByteBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(WordBool),
   IInterface(function(const AIn: ByteBool; out AOut: WordBool): ByteBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(LongBool),
   IInterface(function(const AIn: ByteBool; out AOut: LongBool): ByteBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Byte),
   IInterface(function(const AIn: ByteBool; out AOut: Byte): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(ShortInt),
   IInterface(function(const AIn: ByteBool; out AOut: ShortInt): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(SmallInt),
   IInterface(function(const AIn: ByteBool; out AOut: SmallInt): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Word),
   IInterface(function(const AIn: ByteBool; out AOut: Word): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(LongInt),
   IInterface(function(const AIn: ByteBool; out AOut: LongInt): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(LongWord),
   IInterface(function(const AIn: ByteBool; out AOut: LongWord): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Int64),
   IInterface(function(const AIn: ByteBool; out AOut: Int64): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(UInt64),
   IInterface(function(const AIn: ByteBool; out AOut: UInt64): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Single),
   IInterface(function(const AIn: ByteBool; out AOut: Single): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Double),
   IInterface(function(const AIn: ByteBool; out AOut: Double): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Extended),
   IInterface(function(const AIn: ByteBool; out AOut: Extended): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Comp),
   IInterface(function(const AIn: ByteBool; out AOut: Comp): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ByteBool), TypeInfo(Currency),
   IInterface(function(const AIn: ByteBool; out AOut: Currency): ByteBool
     begin AOut := Ord(AIn); Exit(true); end)
  );
end;

class procedure TConverter.RegisterClass;
begin
  SetConverter(TypeInfo(TObject), TypeInfo(ShortString),
   IInterface(function(const AIn: TObject; out AOut: ShortString): Boolean
     begin
       if Assigned(AIn) then
         AOut := ShortString(AIn.ToString())
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TObject), TypeInfo(AnsiString),
   IInterface(function(const AIn: TObject; out AOut: AnsiString): Boolean
     begin
       if Assigned(AIn) then
         AOut := AnsiString(AIn.ToString())
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TObject), TypeInfo(WideString),
   IInterface(function(const AIn: TObject; out AOut: WideString): Boolean
     begin
       if Assigned(AIn) then
         AOut := AIn.ToString()
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TObject), TypeInfo(UnicodeString),
   IInterface(function(const AIn: TObject; out AOut: UnicodeString): Boolean
     begin
       if Assigned(AIn) then
         AOut := AIn.ToString()
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TObject), TypeInfo(UCS4String),
   IInterface(function(const AIn: TObject; out AOut: UCS4String): Boolean
     begin
       if Assigned(AIn) then
         AOut := UnicodeStringToUCS4String(AIn.ToString())
       else
         AOut := UnicodeStringToUCS4String('');
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TObject), TypeInfo(Pointer),
   IInterface(function(const AIn: TObject; out AOut: Pointer): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(TObject), TypeInfo(TClass),
   IInterface(function(const AIn: TObject; out AOut: TClass): Boolean
     begin
       if AIn <> nil then
         AOut := AIn.ClassType
       else
         AOut := nil;
       Exit(true);
     end)
  );
end;

class procedure TConverter.RegisterComp;
begin
  SetConverter(TypeInfo(Comp), TypeInfo(ShortString),
   IInterface(function(const AIn: Comp; out AOut: ShortString): Boolean
     begin AOut := ShortString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(AnsiString),
   IInterface(function(const AIn: Comp; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(WideString),
   IInterface(function(const AIn: Comp; out AOut: WideString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Comp; out AOut: UnicodeString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(UCS4String),
   IInterface(function(const AIn: Comp; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Boolean),
   IInterface(function(const AIn: Comp; out AOut: Boolean): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(ByteBool),
   IInterface(function(const AIn: Comp; out AOut: ByteBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(WordBool),
   IInterface(function(const AIn: Comp; out AOut: WordBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(LongBool),
   IInterface(function(const AIn: Comp; out AOut: LongBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(ShortInt),
   IInterface(function(const AIn: Comp; out AOut: ShortInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Byte),
   IInterface(function(const AIn: Comp; out AOut: Byte): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(SmallInt),
   IInterface(function(const AIn: Comp; out AOut: SmallInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Word),
   IInterface(function(const AIn: Comp; out AOut: Word): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(LongInt),
   IInterface(function(const AIn: Comp; out AOut: LongInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(LongWord),
   IInterface(function(const AIn: Comp; out AOut: LongWord): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Int64),
   IInterface(function(const AIn: Comp; out AOut: Int64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(UInt64),
   IInterface(function(const AIn: Comp; out AOut: UInt64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Single),
   IInterface(function(const AIn: Comp; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Double),
   IInterface(function(const AIn: Comp; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Extended),
   IInterface(function(const AIn: Comp; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Comp), TypeInfo(Currency),
   IInterface(function(const AIn: Comp; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterCurrency;
begin
  SetConverter(TypeInfo(Currency), TypeInfo(ShortString),
   IInterface(function(const AIn: Currency; out AOut: ShortString): Boolean
     begin AOut := ShortString(CurrToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(AnsiString),
   IInterface(function(const AIn: Currency; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(CurrToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(WideString),
   IInterface(function(const AIn: Currency; out AOut: WideString): Boolean
     begin AOut := CurrToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Currency; out AOut: UnicodeString): Boolean
     begin AOut := CurrToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(UCS4String),
   IInterface(function(const AIn: Currency; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Boolean),
   IInterface(function(const AIn: Currency; out AOut: Boolean): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(ByteBool),
   IInterface(function(const AIn: Currency; out AOut: ByteBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(WordBool),
   IInterface(function(const AIn: Currency; out AOut: WordBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(LongBool),
   IInterface(function(const AIn: Currency; out AOut: LongBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(ShortInt),
   IInterface(function(const AIn: Currency; out AOut: ShortInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Byte),
   IInterface(function(const AIn: Currency; out AOut: Byte): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(SmallInt),
   IInterface(function(const AIn: Currency; out AOut: SmallInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Word),
   IInterface(function(const AIn: Currency; out AOut: Word): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(LongInt),
   IInterface(function(const AIn: Currency; out AOut: LongInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(LongWord),
   IInterface(function(const AIn: Currency; out AOut: LongWord): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Int64),
   IInterface(function(const AIn: Currency; out AOut: Int64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(UInt64),
   IInterface(function(const AIn: Currency; out AOut: UInt64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Single),
   IInterface(function(const AIn: Currency; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Double),
   IInterface(function(const AIn: Currency; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Extended),
   IInterface(function(const AIn: Currency; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Currency), TypeInfo(Comp),
   IInterface(function(const AIn: Currency; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterDate;
begin
  SetConverter(TypeInfo(TDate), TypeInfo(ShortString),
   IInterface(function(const AIn: TDate; out AOut: ShortString): Boolean
     begin AOut := ShortString(DateToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(TDate), TypeInfo(AnsiString),
   IInterface(function(const AIn: TDate; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(DateToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(TDate), TypeInfo(WideString),
   IInterface(function(const AIn: TDate; out AOut: WideString): Boolean
     begin AOut := DateToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(TDate), TypeInfo(UnicodeString),
   IInterface(function(const AIn: TDate; out AOut: UnicodeString): Boolean
     begin AOut := DateToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(TDate), TypeInfo(UCS4String),
   IInterface(function(const AIn: TDate; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(DateToStr(AIn)); Exit(true); end)
  );
end;

class procedure TConverter.RegisterDateTime;
begin
  SetConverter(TypeInfo(TDateTime), TypeInfo(ShortString),
   IInterface(function(const AIn: TDateTime; out AOut: ShortString): Boolean
     begin AOut := ShortString(DateTimeToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(TDateTime), TypeInfo(AnsiString),
   IInterface(function(const AIn: TDateTime; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(DateTimeToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(TDateTime), TypeInfo(WideString),
   IInterface(function(const AIn: TDateTime; out AOut: WideString): Boolean
     begin AOut := DateTimeToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(TDateTime), TypeInfo(UnicodeString),
   IInterface(function(const AIn: TDateTime; out AOut: UnicodeString): Boolean
     begin AOut := DateTimeToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(TDateTime), TypeInfo(UCS4String),
   IInterface(function(const AIn: TDateTime; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(DateTimeToStr(AIn)); Exit(true); end)
  );
end;

class procedure TConverter.RegisterDouble;
begin
  SetConverter(TypeInfo(Double), TypeInfo(ShortString),
   IInterface(function(const AIn: Double; out AOut: ShortString): Boolean
     begin AOut := ShortString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(AnsiString),
   IInterface(function(const AIn: Double; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(WideString),
   IInterface(function(const AIn: Double; out AOut: WideString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Double; out AOut: UnicodeString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(UCS4String),
   IInterface(function(const AIn: Double; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Boolean),
   IInterface(function(const AIn: Double; out AOut: Boolean): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(ByteBool),
   IInterface(function(const AIn: Double; out AOut: ByteBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(WordBool),
   IInterface(function(const AIn: Double; out AOut: WordBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(LongBool),
   IInterface(function(const AIn: Double; out AOut: LongBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(ShortInt),
   IInterface(function(const AIn: Double; out AOut: ShortInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Byte),
   IInterface(function(const AIn: Double; out AOut: Byte): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(SmallInt),
   IInterface(function(const AIn: Double; out AOut: SmallInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Word),
   IInterface(function(const AIn: Double; out AOut: Word): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(LongInt),
   IInterface(function(const AIn: Double; out AOut: LongInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(LongWord),
   IInterface(function(const AIn: Double; out AOut: LongWord): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Int64),
   IInterface(function(const AIn: Double; out AOut: Int64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(UInt64),
   IInterface(function(const AIn: Double; out AOut: UInt64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Single),
   IInterface(function(const AIn: Double; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Extended),
   IInterface(function(const AIn: Double; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Comp),
   IInterface(function(const AIn: Double; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Double), TypeInfo(Currency),
   IInterface(function(const AIn: Double; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterExtended;
begin
  SetConverter(TypeInfo(Extended), TypeInfo(ShortString),
   IInterface(function(const AIn: Extended; out AOut: ShortString): Boolean
     begin AOut := ShortString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(AnsiString),
   IInterface(function(const AIn: Extended; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(WideString),
   IInterface(function(const AIn: Extended; out AOut: WideString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Extended; out AOut: UnicodeString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Boolean),
   IInterface(function(const AIn: Extended; out AOut: Boolean): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(ByteBool),
   IInterface(function(const AIn: Extended; out AOut: ByteBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(WordBool),
   IInterface(function(const AIn: Extended; out AOut: WordBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(LongBool),
   IInterface(function(const AIn: Extended; out AOut: LongBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(ShortInt),
   IInterface(function(const AIn: Extended; out AOut: ShortInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Byte),
   IInterface(function(const AIn: Extended; out AOut: Byte): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(SmallInt),
   IInterface(function(const AIn: Extended; out AOut: SmallInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Word),
   IInterface(function(const AIn: Extended; out AOut: Word): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(LongInt),
   IInterface(function(const AIn: Extended; out AOut: LongInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(LongWord),
   IInterface(function(const AIn: Extended; out AOut: LongWord): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Int64),
   IInterface(function(const AIn: Extended; out AOut: Int64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(UInt64),
   IInterface(function(const AIn: Extended; out AOut: UInt64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Single),
   IInterface(function(const AIn: Extended; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Double),
   IInterface(function(const AIn: Extended; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Comp),
   IInterface(function(const AIn: Extended; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Extended), TypeInfo(Currency),
   IInterface(function(const AIn: Extended; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterPointer;
begin
  SetConverter(TypeInfo(Pointer), TypeInfo(ShortString),
   IInterface(function(const AIn: Pointer; out AOut: ShortString): Boolean
     begin AOut := ShortString(UIntToStr(NativeUInt(AIn))); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(AnsiString),
   IInterface(function(const AIn: Pointer; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(UIntToStr(NativeUInt(AIn))); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(WideString),
   IInterface(function(const AIn: Pointer; out AOut: WideString): Boolean
     begin AOut := UIntToStr(NativeUInt(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Pointer; out AOut: UnicodeString): Boolean
     begin AOut := UIntToStr(NativeUInt(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(UCS4String),
   IInterface(function(const AIn: Pointer; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(UIntToStr(NativeUInt(AIn))); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(Boolean),
   IInterface(function(const AIn: Pointer; out AOut: Boolean): Boolean
     begin AOut := (AIn <> nil); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(ByteBool),
   IInterface(function(const AIn: Pointer; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> nil); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(WordBool),
   IInterface(function(const AIn: Pointer; out AOut: WordBool): Boolean
     begin AOut := (AIn <> nil); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(LongBool),
   IInterface(function(const AIn: Pointer; out AOut: LongBool): Boolean
     begin AOut := (AIn <> nil); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(ShortInt),
   IInterface(function(const AIn: Pointer; out AOut: ShortInt): Boolean
     begin AOut := ShortInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(Byte),
   IInterface(function(const AIn: Pointer; out AOut: Byte): Boolean
     begin AOut := Byte(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(SmallInt),
   IInterface(function(const AIn: Pointer; out AOut: SmallInt): Boolean
     begin AOut := SmallInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(Word),
   IInterface(function(const AIn: Pointer; out AOut: Word): Boolean
     begin AOut := Word(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(LongInt),
   IInterface(function(const AIn: Pointer; out AOut: LongInt): Boolean
     begin AOut := LongInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Byte), TypeInfo(LongWord),
   IInterface(function(const AIn: Byte; out AOut: LongWord): Boolean
     begin AOut := LongWord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(Int64),
   IInterface(function(const AIn: Pointer; out AOut: Int64): Boolean
     begin AOut := Int64(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(UInt64),
   IInterface(function(const AIn: Pointer; out AOut: UInt64): Boolean
     begin AOut := UInt64(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(TObject),
   IInterface(function(const AIn: Pointer; out AOut: TObject): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(IInterface),
   IInterface(function(const AIn: Pointer; out AOut: IInterface): Boolean
     begin AOut := IInterface(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Pointer), TypeInfo(TClass),
   IInterface(function(const AIn: Pointer; out AOut: TClass): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterShortInt;
begin
  SetConverter(TypeInfo(ShortInt), TypeInfo(AnsiChar),
   IInterface(function(const AIn: ShortInt; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(WideChar),
   IInterface(function(const AIn: ShortInt; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Pointer),
   IInterface(function(const AIn: ShortInt; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(ShortString),
   IInterface(function(const AIn: ShortInt; out AOut: ShortString): Boolean
     begin AOut := ShortString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(AnsiString),
   IInterface(function(const AIn: ShortInt; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(WideString),
   IInterface(function(const AIn: ShortInt; out AOut: WideString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(UnicodeString),
   IInterface(function(const AIn: ShortInt; out AOut: UnicodeString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(UCS4String),
   IInterface(function(const AIn: ShortInt; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Boolean),
   IInterface(function(const AIn: ShortInt; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(ByteBool),
   IInterface(function(const AIn: ShortInt; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(WordBool),
   IInterface(function(const AIn: ShortInt; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(LongBool),
   IInterface(function(const AIn: ShortInt; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Byte),
   IInterface(function(const AIn: ShortInt; out AOut: Byte): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(SmallInt),
   IInterface(function(const AIn: ShortInt; out AOut: SmallInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Word),
   IInterface(function(const AIn: ShortInt; out AOut: Word): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(LongInt),
   IInterface(function(const AIn: ShortInt; out AOut: LongInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(LongWord),
   IInterface(function(const AIn: ShortInt; out AOut: LongWord): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Int64),
   IInterface(function(const AIn: ShortInt; out AOut: Int64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(UInt64),
   IInterface(function(const AIn: ShortInt; out AOut: UInt64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Single),
   IInterface(function(const AIn: ShortInt; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Double),
   IInterface(function(const AIn: ShortInt; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Extended),
   IInterface(function(const AIn: ShortInt; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Comp),
   IInterface(function(const AIn: ShortInt; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortInt), TypeInfo(Currency),
   IInterface(function(const AIn: ShortInt; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterShortString;
begin
  SetConverter(TypeInfo(ShortString), TypeInfo(AnsiChar),
   IInterface(function(const AIn: ShortString; out AOut: AnsiChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := AIn[1];
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(WideChar),
   IInterface(function(const AIn: ShortString; out AOut: WideChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := string(AIn)[1];
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(UCS4Char),
   IInterface(function(const AIn: ShortString; out AOut: UCS4Char): Boolean
     var
       LTemp: UCS4String;
     begin
       LTemp := UnicodeStringToUCS4String(string(AIn));
       Result := (Length(LTemp) = 2);
       if Result then
         AOut := LTemp[0];
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(AnsiString),
   IInterface(function(const AIn: ShortString; out AOut: AnsiString): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(WideString),
   IInterface(function(const AIn: ShortString; out AOut: WideString): Boolean
     begin AOut := string(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(UnicodeString),
   IInterface(function(const AIn: ShortString; out AOut: UnicodeString): Boolean
     begin AOut := string(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(UCS4String),
   IInterface(function(const AIn: ShortString; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(string(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(TDate),
   IInterface(function(const AIn: ShortString; out AOut: TDate): Boolean
     begin
       Result := TryStrToDate(string(AIn), TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(TTime),
   IInterface(function(const AIn: ShortString; out AOut: TTime): Boolean
     begin
       Result := TryStrToTime(string(AIn), TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(TDateTime),
   IInterface(function(const AIn: ShortString; out AOut: TDateTime): Boolean
     begin
       Result := TryStrToDateTime(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Boolean),
   IInterface(function(const AIn: ShortString; out AOut: Boolean): Boolean
     begin
       Result := TryStrToBool(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(ByteBool),
   IInterface(function(const AIn: ShortString; out AOut: ByteBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(WordBool),
   IInterface(function(const AIn: ShortString; out AOut: WordBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(LongBool),
   IInterface(function(const AIn: ShortString; out AOut: LongBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Pointer),
   IInterface(function(const AIn: ShortString; out AOut: Pointer): Boolean
     var
{$IF SizeOf(Pointer) = SizeOf(Integer)}
       LTemp: Integer;
{$ELSE}
       LTemp: Int64;
{$IFEND}
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := Ptr(LTemp);
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Byte),
   IInterface(function(const AIn: ShortString; out AOut: Byte): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(ShortInt),
   IInterface(function(const AIn: ShortString; out AOut: ShortInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(SmallInt),
   IInterface(function(const AIn: ShortString; out AOut: SmallInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Word),
   IInterface(function(const AIn: ShortString; out AOut: Word): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(LongInt),
   IInterface(function(const AIn: ShortString; out AOut: LongInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(LongWord),
   IInterface(function(const AIn: ShortString; out AOut: LongWord): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Int64),
   IInterface(function(const AIn: ShortString; out AOut: Int64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(UInt64),
   IInterface(function(const AIn: ShortString; out AOut: UInt64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Single),
   IInterface(function(const AIn: ShortString; out AOut: Single): Boolean
     begin
       Result := TryStrToFloat(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Double),
   IInterface(function(const AIn: ShortString; out AOut: Double): Boolean
     begin
       Result := TryStrToFloat(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Extended),
   IInterface(function(const AIn: ShortString; out AOut: Extended): Boolean
     begin
       Result := TryStrToFloat(string(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Comp),
   IInterface(function(const AIn: ShortString; out AOut: Comp): Boolean
     var
       LTemp: Double;
     begin
       Result := TryStrToFloat(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(ShortString), TypeInfo(Currency),
   IInterface(function(const AIn: ShortString; out AOut: Currency): Boolean
     var
       LTemp: Extended;
     begin
       Result := TryStrToFloat(string(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );
end;

class procedure TConverter.RegisterSingle;
begin
  SetConverter(TypeInfo(Single), TypeInfo(ShortString),
   IInterface(function(const AIn: Single; out AOut: ShortString): Boolean
     begin AOut := ShortString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(AnsiString),
   IInterface(function(const AIn: Single; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(WideString),
   IInterface(function(const AIn: Single; out AOut: WideString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Single; out AOut: UnicodeString): Boolean
     begin AOut := FloatToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(UCS4String),
   IInterface(function(const AIn: Single; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(FloatToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Boolean),
   IInterface(function(const AIn: Single; out AOut: Boolean): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(ByteBool),
   IInterface(function(const AIn: Single; out AOut: ByteBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(WordBool),
   IInterface(function(const AIn: Single; out AOut: WordBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(LongBool),
   IInterface(function(const AIn: Single; out AOut: LongBool): Boolean
     begin AOut := (Round(AIn) <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(ShortInt),
   IInterface(function(const AIn: Single; out AOut: ShortInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Byte),
   IInterface(function(const AIn: Single; out AOut: Byte): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(SmallInt),
   IInterface(function(const AIn: Single; out AOut: SmallInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Word),
   IInterface(function(const AIn: Single; out AOut: Word): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(LongInt),
   IInterface(function(const AIn: Single; out AOut: LongInt): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(LongWord),
   IInterface(function(const AIn: Single; out AOut: LongWord): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Int64),
   IInterface(function(const AIn: Single; out AOut: Int64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(UInt64),
   IInterface(function(const AIn: Single; out AOut: UInt64): Boolean
     begin AOut := Round(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Double),
   IInterface(function(const AIn: Single; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Extended),
   IInterface(function(const AIn: Single; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Comp),
   IInterface(function(const AIn: Single; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Single), TypeInfo(Currency),
   IInterface(function(const AIn: Single; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterSmallInt;
begin
  SetConverter(TypeInfo(SmallInt), TypeInfo(AnsiChar),
   IInterface(function(const AIn: SmallInt; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(WideChar),
   IInterface(function(const AIn: SmallInt; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Pointer),
   IInterface(function(const AIn: SmallInt; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(ShortString),
   IInterface(function(const AIn: SmallInt; out AOut: ShortString): Boolean
     begin AOut := ShortString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(AnsiString),
   IInterface(function(const AIn: SmallInt; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(WideString),
   IInterface(function(const AIn: SmallInt; out AOut: WideString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(UnicodeString),
   IInterface(function(const AIn: SmallInt; out AOut: UnicodeString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(UCS4String),
   IInterface(function(const AIn: SmallInt; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Boolean),
   IInterface(function(const AIn: SmallInt; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(ByteBool),
   IInterface(function(const AIn: SmallInt; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(WordBool),
   IInterface(function(const AIn: SmallInt; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(LongBool),
   IInterface(function(const AIn: SmallInt; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(ShortInt),
   IInterface(function(const AIn: SmallInt; out AOut: ShortInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Byte),
   IInterface(function(const AIn: SmallInt; out AOut: Byte): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Word),
   IInterface(function(const AIn: SmallInt; out AOut: Word): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(LongInt),
   IInterface(function(const AIn: SmallInt; out AOut: LongInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(LongWord),
   IInterface(function(const AIn: SmallInt; out AOut: LongWord): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Int64),
   IInterface(function(const AIn: SmallInt; out AOut: Int64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(UInt64),
   IInterface(function(const AIn: SmallInt; out AOut: UInt64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Single),
   IInterface(function(const AIn: SmallInt; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Double),
   IInterface(function(const AIn: SmallInt; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Extended),
   IInterface(function(const AIn: SmallInt; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Comp),
   IInterface(function(const AIn: SmallInt; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(SmallInt), TypeInfo(Currency),
   IInterface(function(const AIn: SmallInt; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterTime;
begin
  SetConverter(TypeInfo(TTime), TypeInfo(ShortString),
   IInterface(function(const AIn: TTime; out AOut: ShortString): Boolean
     begin AOut := ShortString(TimeToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(TTime), TypeInfo(AnsiString),
   IInterface(function(const AIn: TTime; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(TimeToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(TTime), TypeInfo(WideString),
   IInterface(function(const AIn: TTime; out AOut: WideString): Boolean
     begin AOut := TimeToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(TTime), TypeInfo(UnicodeString),
   IInterface(function(const AIn: TTime; out AOut: UnicodeString): Boolean
     begin AOut := TimeToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(TTime), TypeInfo(UCS4String),
   IInterface(function(const AIn: TTime; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(TimeToStr(AIn)); Exit(true); end)
  );
end;

class procedure TConverter.RegisterUCS4Char;
begin
  SetConverter(TypeInfo(UCS4Char), TypeInfo(ShortString),
   IInterface(function(const AIn: UCS4Char; out AOut: ShortString): Boolean
     begin AOut := ShortString(ConvertFromUtf32(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4Char), TypeInfo(AnsiString),
   IInterface(function(const AIn: UCS4Char; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(ConvertFromUtf32(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4Char), TypeInfo(WideString),
   IInterface(function(const AIn: UCS4Char; out AOut: WideString): Boolean
     begin AOut := ConvertFromUtf32(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4Char), TypeInfo(UnicodeString),
   IInterface(function(const AIn: UCS4Char; out AOut: UnicodeString): Boolean
     begin AOut := ConvertFromUtf32(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4Char), TypeInfo(UCS4String),
   IInterface(function(const AIn: UCS4Char; out AOut: UCS4String): Boolean
     begin SetLength(AOut, 2); AOut[0] := AIn; AOut[1] := 0; Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4Char), TypeInfo(WideChar),
   IInterface(function(const AIn: UCS4Char; out AOut: WideChar): Boolean
     begin AOut := ConvertFromUtf32(AIn)[1]; Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4Char), TypeInfo(AnsiChar),
   IInterface(function(const AIn: UCS4Char; out AOut: AnsiChar): Boolean
     begin AOut := AnsiString(ConvertFromUtf32(AIn))[1]; Exit(true); end)
  );
end;

class procedure TConverter.RegisterUCS4String;
begin
  SetConverter(TypeInfo(UCS4String), TypeInfo(AnsiChar),
   IInterface(function(const AIn: UCS4String; out AOut: AnsiChar): Boolean
     var
       LTemp: AnsiString;
     begin
       LTemp := AnsiString(UCS4StringToUnicodeString(AIn));
       Result := (Length(LTemp) = 1);
       if Result then
         AOut := LTemp[1];
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(WideChar),
   IInterface(function(const AIn: UCS4String; out AOut: WideChar): Boolean
     var
       LTemp: UnicodeString;
     begin
       LTemp := UCS4StringToUnicodeString(AIn);
       Result := (Length(LTemp) = 1);
       if Result then
         AOut := LTemp[1];
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(UCS4Char),
   IInterface(function(const AIn: UCS4String; out AOut: UCS4Char): Boolean
     begin
       Result := (Length(AIn) = 2);
       if Result then
         AOut := AIn[0];
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(ShortString),
   IInterface(function(const AIn: UCS4String; out AOut: ShortString): Boolean
     begin AOut := ShortString(UCS4StringToUnicodeString(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(AnsiString),
   IInterface(function(const AIn: UCS4String; out AOut: ShortString): Boolean
     begin AOut := AnsiString(UCS4StringToUnicodeString(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(WideString),
   IInterface(function(const AIn: UCS4String; out AOut: WideString): Boolean
     begin AOut := UCS4StringToUnicodeString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(UnicodeString),
   IInterface(function(const AIn: UCS4String; out AOut: UnicodeString): Boolean
     begin AOut := UCS4StringToUnicodeString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(TDate),
   IInterface(function(const AIn: UCS4String; out AOut: TDate): Boolean
     begin
       Result := TryStrToDate(UCS4StringToUnicodeString(AIn), TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(TTime),
   IInterface(function(const AIn: UCS4String; out AOut: TTime): Boolean
     begin
       Result := TryStrToTime(UCS4StringToUnicodeString(AIn), TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(TDateTime),
   IInterface(function(const AIn: UCS4String; out AOut: TDateTime): Boolean
     begin
       Result := TryStrToDateTime(UCS4StringToUnicodeString(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Boolean),
   IInterface(function(const AIn: UCS4String; out AOut: Boolean): Boolean
     begin
       Result := TryStrToBool(UCS4StringToUnicodeString(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(ByteBool),
   IInterface(function(const AIn: UCS4String; out AOut: ByteBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(WordBool),
   IInterface(function(const AIn: UCS4String; out AOut: WordBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(LongBool),
   IInterface(function(const AIn: UCS4String; out AOut: LongBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Pointer),
   IInterface(function(const AIn: UCS4String; out AOut: Pointer): Boolean
     var
{$IF SizeOf(Pointer) = SizeOf(Integer)}
       LTemp: Integer;
{$ELSE}
       LTemp: Int64;
{$IFEND}
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := Ptr(LTemp);
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Byte),
   IInterface(function(const AIn: UCS4String; out AOut: Byte): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(ShortInt),
   IInterface(function(const AIn: UCS4String; out AOut: ShortInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(SmallInt),
   IInterface(function(const AIn: UCS4String; out AOut: SmallInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Word),
   IInterface(function(const AIn: UCS4String; out AOut: Word): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(LongInt),
   IInterface(function(const AIn: UCS4String; out AOut: LongInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(LongWord),
   IInterface(function(const AIn: UCS4String; out AOut: LongWord): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Int64),
   IInterface(function(const AIn: UCS4String; out AOut: Int64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(UInt64),
   IInterface(function(const AIn: UCS4String; out AOut: UInt64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Single),
   IInterface(function(const AIn: UCS4String; out AOut: Single): Boolean
     begin
       Result := TryStrToFloat(UCS4StringToUnicodeString(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Double),
   IInterface(function(const AIn: UCS4String; out AOut: Double): Boolean
     begin
       Result := TryStrToFloat(UCS4StringToUnicodeString(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Extended),
   IInterface(function(const AIn: UCS4String; out AOut: Extended): Boolean
     begin
       Result := TryStrToFloat(UCS4StringToUnicodeString(AIn), AOut);
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Comp),
   IInterface(function(const AIn: UCS4String; out AOut: Comp): Boolean
     var
       LTemp: Double;
     begin
       Result := TryStrToFloat(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UCS4String), TypeInfo(Currency),
   IInterface(function(const AIn: UCS4String; out AOut: Currency): Boolean
     var
       LTemp: Extended;
     begin
       Result := TryStrToFloat(UCS4StringToUnicodeString(AIn), LTemp);
       if Result then
         AOut := LTemp;
     end)
  );
end;

class procedure TConverter.RegisterUInt64;
begin
  SetConverter(TypeInfo(UInt64), TypeInfo(AnsiChar),
   IInterface(function(const AIn: UInt64; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(WideChar),
   IInterface(function(const AIn: UInt64; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Pointer),
   IInterface(function(const AIn: UInt64; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(ShortString),
   IInterface(function(const AIn: UInt64; out AOut: ShortString): Boolean
     begin AOut := ShortString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(AnsiString),
   IInterface(function(const AIn: UInt64; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(WideString),
   IInterface(function(const AIn: UInt64; out AOut: WideString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(UnicodeString),
   IInterface(function(const AIn: UInt64; out AOut: UnicodeString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(UCS4String),
   IInterface(function(const AIn: UInt64; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Boolean),
   IInterface(function(const AIn: UInt64; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(ByteBool),
   IInterface(function(const AIn: UInt64; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(WordBool),
   IInterface(function(const AIn: UInt64; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(LongBool),
   IInterface(function(const AIn: UInt64; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(ShortInt),
   IInterface(function(const AIn: UInt64; out AOut: ShortInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Byte),
   IInterface(function(const AIn: UInt64; out AOut: Byte): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(SmallInt),
   IInterface(function(const AIn: UInt64; out AOut: SmallInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Word),
   IInterface(function(const AIn: UInt64; out AOut: Word): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(LongInt),
   IInterface(function(const AIn: UInt64; out AOut: LongInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(LongWord),
   IInterface(function(const AIn: UInt64; out AOut: LongWord): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Int64),
   IInterface(function(const AIn: UInt64; out AOut: Int64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Single),
   IInterface(function(const AIn: UInt64; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Double),
   IInterface(function(const AIn: UInt64; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Extended),
   IInterface(function(const AIn: UInt64; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Comp),
   IInterface(function(const AIn: UInt64; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UInt64), TypeInfo(Currency),
   IInterface(function(const AIn: UInt64; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterUnicodeString;
begin
  SetConverter(TypeInfo(UnicodeString), TypeInfo(AnsiChar),
   IInterface(function(const AIn: UnicodeString; out AOut: AnsiChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := AnsiString(AIn)[1];
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(WideChar),
   IInterface(function(const AIn: UnicodeString; out AOut: WideChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := AIn[1];
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(UCS4Char),
   IInterface(function(const AIn: UnicodeString; out AOut: UCS4Char): Boolean
     var
       LTemp: UCS4String;
     begin
       LTemp := UnicodeStringToUCS4String(AIn);
       Result := (Length(LTemp) = 2);
       if Result then
         AOut := LTemp[0];
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(ShortString),
   IInterface(function(const AIn: UnicodeString; out AOut: ShortString): Boolean
     begin AOut := ShortString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(AnsiString),
   IInterface(function(const AIn: UnicodeString; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(WideString),
   IInterface(function(const AIn: UnicodeString; out AOut: WideString): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(UCS4String),
   IInterface(function(const AIn: UnicodeString; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(TDate),
   IInterface(function(const AIn: UnicodeString; out AOut: TDate): Boolean
     begin
       Result := TryStrToDate(AIn, TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(TTime),
   IInterface(function(const AIn: UnicodeString; out AOut: TTime): Boolean
     begin
       Result := TryStrToTime(AIn, TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(TDateTime),
   IInterface(function(const AIn: UnicodeString; out AOut: TDateTime): Boolean
     begin
       Result := TryStrToDateTime(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Boolean),
   IInterface(function(const AIn: UnicodeString; out AOut: Boolean): Boolean
     begin
       Result := TryStrToBool(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(ByteBool),
   IInterface(function(const AIn: UnicodeString; out AOut: ByteBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(WordBool),
   IInterface(function(const AIn: UnicodeString; out AOut: WordBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(LongBool),
   IInterface(function(const AIn: UnicodeString; out AOut: LongBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Pointer),
   IInterface(function(const AIn: UnicodeString; out AOut: Pointer): Boolean
     var
{$IF SizeOf(Pointer) = SizeOf(Integer)}
       LTemp: Integer;
{$ELSE}
       LTemp: Int64;
{$IFEND}
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := Ptr(LTemp);
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Byte),
   IInterface(function(const AIn: UnicodeString; out AOut: Byte): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(ShortInt),
   IInterface(function(const AIn: UnicodeString; out AOut: ShortInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(SmallInt),
   IInterface(function(const AIn: UnicodeString; out AOut: SmallInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Word),
   IInterface(function(const AIn: UnicodeString; out AOut: Word): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(LongInt),
   IInterface(function(const AIn: UnicodeString; out AOut: LongInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(LongWord),
   IInterface(function(const AIn: UnicodeString; out AOut: LongWord): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Int64),
   IInterface(function(const AIn: UnicodeString; out AOut: Int64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(UInt64),
   IInterface(function(const AIn: UnicodeString; out AOut: UInt64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Single),
   IInterface(function(const AIn: UnicodeString; out AOut: Single): Boolean
     begin
       Result := TryStrToFloat(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Double),
   IInterface(function(const AIn: UnicodeString; out AOut: Double): Boolean
     begin
       Result := TryStrToFloat(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Extended),
   IInterface(function(const AIn: UnicodeString; out AOut: Extended): Boolean
     begin
       Result := TryStrToFloat(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Comp),
   IInterface(function(const AIn: UnicodeString; out AOut: Comp): Boolean
     var
       LTemp: Double;
     begin
       Result := TryStrToFloat(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(UnicodeString), TypeInfo(Currency),
   IInterface(function(const AIn: UnicodeString; out AOut: Currency): Boolean
     var
       LTemp: Extended;
     begin
       Result := TryStrToFloat(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );
end;

class procedure TConverter.RegisterWideChar;
begin
  SetConverter(TypeInfo(WideChar), TypeInfo(ShortString),
   IInterface(function(const AIn: WideChar; out AOut: ShortString): Boolean
     begin AOut := ShortString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(AnsiString),
   IInterface(function(const AIn: WideChar; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(WideString),
   IInterface(function(const AIn: WideChar; out AOut: WideString): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(UnicodeString),
   IInterface(function(const AIn: WideChar; out AOut: UnicodeString): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(UCS4String),
   IInterface(function(const AIn: WideChar; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(AnsiChar),
   IInterface(function(const AIn: WideChar; out AOut: AnsiChar): Boolean
     begin AOut := AnsiString(AIn)[1]; Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(Pointer),
   IInterface(function(const AIn: WideChar; out AOut: Pointer): Boolean
     begin AOut := Ptr(Byte(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(Boolean),
   IInterface(function(const AIn: WideChar; out AOut: Boolean): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(ByteBool),
   IInterface(function(const AIn: WideChar; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(WordBool),
   IInterface(function(const AIn: WideChar; out AOut: WordBool): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(LongBool),
   IInterface(function(const AIn: WideChar; out AOut: LongBool): Boolean
     begin AOut := (AIn <> #0); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(ShortInt),
   IInterface(function(const AIn: WideChar; out AOut: ShortInt): Boolean
     begin AOut := ShortInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(SmallInt),
   IInterface(function(const AIn: WideChar; out AOut: SmallInt): Boolean
     begin AOut := SmallInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(Word),
   IInterface(function(const AIn: WideChar; out AOut: Word): Boolean
     begin AOut := Word(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(LongInt),
   IInterface(function(const AIn: WideChar; out AOut: LongInt): Boolean
     begin AOut := LongInt(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(LongWord),
   IInterface(function(const AIn: WideChar; out AOut: LongWord): Boolean
     begin AOut := LongWord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(Int64),
   IInterface(function(const AIn: WideChar; out AOut: Int64): Boolean
     begin AOut := Int64(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideChar), TypeInfo(UInt64),
   IInterface(function(const AIn: WideChar; out AOut: UInt64): Boolean
     begin AOut := UInt64(AIn); Exit(true); end)
  );
end;

class procedure TConverter.RegisterWideString;
begin
  SetConverter(TypeInfo(WideString), TypeInfo(AnsiChar),
   IInterface(function(const AIn: WideString; out AOut: AnsiChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := AnsiString(AIn)[1];
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(WideChar),
   IInterface(function(const AIn: WideString; out AOut: WideChar): Boolean
     begin
       Result := (Length(AIn) = 1);
       if Result then
         AOut := AIn[1];
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(UCS4Char),
   IInterface(function(const AIn: WideString; out AOut: UCS4Char): Boolean
     var
       LTemp: UCS4String;
     begin
       LTemp := UnicodeStringToUCS4String(AIn);
       Result := (Length(LTemp) = 2);
       if Result then
         AOut := LTemp[0];
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(ShortString),
   IInterface(function(const AIn: WideString; out AOut: ShortString): Boolean
     begin AOut := ShortString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(AnsiString),
   IInterface(function(const AIn: WideString; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(UnicodeString),
   IInterface(function(const AIn: WideString; out AOut: UnicodeString): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(UCS4String),
   IInterface(function(const AIn: WideString; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(TDate),
   IInterface(function(const AIn: WideString; out AOut: TDate): Boolean
     begin
       Result := TryStrToDate(AIn, TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(TTime),
   IInterface(function(const AIn: WideString; out AOut: TTime): Boolean
     begin
       Result := TryStrToTime(AIn, TDateTime(AOut));
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(TDateTime),
   IInterface(function(const AIn: WideString; out AOut: TDateTime): Boolean
     begin
       Result := TryStrToDateTime(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Boolean),
   IInterface(function(const AIn: WideString; out AOut: Boolean): Boolean
     begin
       Result := TryStrToBool(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(ByteBool),
   IInterface(function(const AIn: WideString; out AOut: ByteBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(WordBool),
   IInterface(function(const AIn: WideString; out AOut: WordBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(LongBool),
   IInterface(function(const AIn: WideString; out AOut: LongBool): Boolean
     var
       LTemp: Boolean;
     begin
       Result := TryStrToBool(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Pointer),
   IInterface(function(const AIn: WideString; out AOut: Pointer): Boolean
     var
{$IF SizeOf(Pointer) = SizeOf(Integer)}
       LTemp: Integer;
{$ELSE}
       LTemp: Int64;
{$IFEND}
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := Ptr(LTemp);
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Byte),
   IInterface(function(const AIn: WideString; out AOut: Byte): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(ShortInt),
   IInterface(function(const AIn: WideString; out AOut: ShortInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(SmallInt),
   IInterface(function(const AIn: WideString; out AOut: SmallInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Word),
   IInterface(function(const AIn: WideString; out AOut: Word): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(LongInt),
   IInterface(function(const AIn: WideString; out AOut: LongInt): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(LongWord),
   IInterface(function(const AIn: WideString; out AOut: LongWord): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Int64),
   IInterface(function(const AIn: WideString; out AOut: Int64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(UInt64),
   IInterface(function(const AIn: WideString; out AOut: UInt64): Boolean
     var
       LTemp: Integer;
     begin
       Result := TryStrToInt(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Single),
   IInterface(function(const AIn: WideString; out AOut: Single): Boolean
     begin
       Result := TryStrToFloat(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Double),
   IInterface(function(const AIn: WideString; out AOut: Double): Boolean
     begin
       Result := TryStrToFloat(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Extended),
   IInterface(function(const AIn: WideString; out AOut: Extended): Boolean
     begin
       Result := TryStrToFloat(AIn, AOut);
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Comp),
   IInterface(function(const AIn: WideString; out AOut: Comp): Boolean
     var
       LTemp: Double;
     begin
       Result := TryStrToFloat(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );

  SetConverter(TypeInfo(WideString), TypeInfo(Currency),
   IInterface(function(const AIn: WideString; out AOut: Currency): Boolean
     var
       LTemp: Extended;
     begin
       Result := TryStrToFloat(AIn, LTemp);
       if Result then
         AOut := LTemp;
     end)
  );
end;

class procedure TConverter.RegisterWord;
begin
  SetConverter(TypeInfo(Word), TypeInfo(AnsiChar),
   IInterface(function(const AIn: Word; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(WideChar),
   IInterface(function(const AIn: Word; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Pointer),
   IInterface(function(const AIn: Word; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(ShortString),
   IInterface(function(const AIn: Word; out AOut: ShortString): Boolean
     begin AOut := ShortString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(AnsiString),
   IInterface(function(const AIn: Word; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(WideString),
   IInterface(function(const AIn: Word; out AOut: WideString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Word; out AOut: UnicodeString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(UCS4String),
   IInterface(function(const AIn: Word; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Boolean),
   IInterface(function(const AIn: Word; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(ByteBool),
   IInterface(function(const AIn: Word; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(WordBool),
   IInterface(function(const AIn: Word; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(LongBool),
   IInterface(function(const AIn: Word; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(ShortInt),
   IInterface(function(const AIn: Word; out AOut: ShortInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Byte),
   IInterface(function(const AIn: Word; out AOut: Byte): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(SmallInt),
   IInterface(function(const AIn: Word; out AOut: SmallInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(LongInt),
   IInterface(function(const AIn: Word; out AOut: LongInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(LongWord),
   IInterface(function(const AIn: Word; out AOut: LongWord): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Int64),
   IInterface(function(const AIn: Word; out AOut: Int64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(UInt64),
   IInterface(function(const AIn: Word; out AOut: UInt64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Single),
   IInterface(function(const AIn: Word; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Double),
   IInterface(function(const AIn: Word; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Extended),
   IInterface(function(const AIn: Word; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Comp),
   IInterface(function(const AIn: Word; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Word), TypeInfo(Currency),
   IInterface(function(const AIn: Word; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterWordBool;
begin
  SetConverter(TypeInfo(WordBool), TypeInfo(ShortString),
   IInterface(function(const AIn: WordBool; out AOut: ShortString): Boolean
     begin AOut := ShortString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(AnsiString),
   IInterface(function(const AIn: WordBool; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(WideString),
   IInterface(function(const AIn: WordBool; out AOut: WideString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(UnicodeString),
   IInterface(function(const AIn: WordBool; out AOut: UnicodeString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(UCS4String),
   IInterface(function(const AIn: WordBool; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Boolean),
   IInterface(function(const AIn: WordBool; out AOut: Boolean): WordBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(ByteBool),
   IInterface(function(const AIn: WordBool; out AOut: ByteBool): WordBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(LongBool),
   IInterface(function(const AIn: WordBool; out AOut: LongBool): WordBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Byte),
   IInterface(function(const AIn: WordBool; out AOut: Byte): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(ShortInt),
   IInterface(function(const AIn: WordBool; out AOut: ShortInt): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(SmallInt),
   IInterface(function(const AIn: WordBool; out AOut: SmallInt): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Word),
   IInterface(function(const AIn: WordBool; out AOut: Word): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(LongInt),
   IInterface(function(const AIn: WordBool; out AOut: LongInt): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(LongWord),
   IInterface(function(const AIn: WordBool; out AOut: LongWord): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Int64),
   IInterface(function(const AIn: WordBool; out AOut: Int64): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(UInt64),
   IInterface(function(const AIn: WordBool; out AOut: UInt64): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Single),
   IInterface(function(const AIn: WordBool; out AOut: Single): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Double),
   IInterface(function(const AIn: WordBool; out AOut: Double): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Extended),
   IInterface(function(const AIn: WordBool; out AOut: Extended): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Comp),
   IInterface(function(const AIn: WordBool; out AOut: Comp): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(WordBool), TypeInfo(Currency),
   IInterface(function(const AIn: WordBool; out AOut: Currency): WordBool
     begin AOut := Ord(AIn); Exit(true); end)
  );
end;

class procedure TConverter.RegisterInt64;
begin
  SetConverter(TypeInfo(Int64), TypeInfo(AnsiChar),
   IInterface(function(const AIn: Int64; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(WideChar),
   IInterface(function(const AIn: Int64; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Pointer),
   IInterface(function(const AIn: Int64; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(ShortString),
   IInterface(function(const AIn: Int64; out AOut: ShortString): Boolean
     begin AOut := ShortString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(AnsiString),
   IInterface(function(const AIn: Int64; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(WideString),
   IInterface(function(const AIn: Int64; out AOut: WideString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(UnicodeString),
   IInterface(function(const AIn: Int64; out AOut: UnicodeString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(UCS4String),
   IInterface(function(const AIn: Int64; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Boolean),
   IInterface(function(const AIn: Int64; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(ByteBool),
   IInterface(function(const AIn: Int64; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(WordBool),
   IInterface(function(const AIn: Int64; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(LongBool),
   IInterface(function(const AIn: Int64; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(ShortInt),
   IInterface(function(const AIn: Int64; out AOut: ShortInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Byte),
   IInterface(function(const AIn: Int64; out AOut: Byte): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(SmallInt),
   IInterface(function(const AIn: Int64; out AOut: SmallInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Word),
   IInterface(function(const AIn: Int64; out AOut: Word): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(LongInt),
   IInterface(function(const AIn: Int64; out AOut: LongInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(LongWord),
   IInterface(function(const AIn: Int64; out AOut: LongWord): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(UInt64),
   IInterface(function(const AIn: Int64; out AOut: UInt64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Single),
   IInterface(function(const AIn: Int64; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Double),
   IInterface(function(const AIn: Int64; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Extended),
   IInterface(function(const AIn: Int64; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Comp),
   IInterface(function(const AIn: Int64; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(Int64), TypeInfo(Currency),
   IInterface(function(const AIn: Int64; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterInterface;
begin
  SetConverter(TypeInfo(IInterface), TypeInfo(Variant),
   IInterface(function(const AIn: IInterface; out AOut: Variant): Boolean
    var
      LDisp: IDispatch;
    begin
      if Assigned(AIn) then
      begin
        Result := Supports(AIn, IDispatch, LDisp);

        if Result then
          AOut := LDisp;
      end else
      begin
        VarClear(AOut);
        Result := true;
      end;
    end)
  );

  SetConverter(TypeInfo(IInterface), TypeInfo(OleVariant),
   IInterface(function(const AIn: IInterface; out AOut: OleVariant): Boolean
    var
      LDisp: IDispatch;
    begin
      if Assigned(AIn) then
      begin
        Result := Supports(AIn, IDispatch, LDisp);

        if Result then
          AOut := LDisp;
      end else
      begin
        VarClear(AOut);
        Result := true;
      end;
    end)
  );

  SetConverter(TypeInfo(IInterface), TypeInfo(Pointer),
   IInterface(function(const AIn: IInterface; out AOut: Pointer): Boolean
     begin AOut := Pointer(AIn); Exit(true); end)
  );
end;

class procedure TConverter.RegisterLongBool;
begin
  SetConverter(TypeInfo(LongBool), TypeInfo(ShortString),
   IInterface(function(const AIn: LongBool; out AOut: ShortString): Boolean
     begin AOut := ShortString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(AnsiString),
   IInterface(function(const AIn: LongBool; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(WideString),
   IInterface(function(const AIn: LongBool; out AOut: WideString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(UnicodeString),
   IInterface(function(const AIn: LongBool; out AOut: UnicodeString): Boolean
     begin AOut := BoolToStr(AIn, true); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(UCS4String),
   IInterface(function(const AIn: LongBool; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(BoolToStr(AIn, true)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Boolean),
   IInterface(function(const AIn: LongBool; out AOut: Boolean): LongBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(ByteBool),
   IInterface(function(const AIn: LongBool; out AOut: ByteBool): LongBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(WordBool),
   IInterface(function(const AIn: LongBool; out AOut: WordBool): LongBool
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Byte),
   IInterface(function(const AIn: LongBool; out AOut: Byte): Boolean
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(ShortInt),
   IInterface(function(const AIn: LongBool; out AOut: ShortInt): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(SmallInt),
   IInterface(function(const AIn: LongBool; out AOut: SmallInt): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Word),
   IInterface(function(const AIn: LongBool; out AOut: Word): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(LongInt),
   IInterface(function(const AIn: LongBool; out AOut: LongInt): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(LongWord),
   IInterface(function(const AIn: LongBool; out AOut: LongWord): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Int64),
   IInterface(function(const AIn: LongBool; out AOut: Int64): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(UInt64),
   IInterface(function(const AIn: LongBool; out AOut: UInt64): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Single),
   IInterface(function(const AIn: LongBool; out AOut: Single): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Double),
   IInterface(function(const AIn: LongBool; out AOut: Double): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Extended),
   IInterface(function(const AIn: LongBool; out AOut: Extended): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Comp),
   IInterface(function(const AIn: LongBool; out AOut: Comp): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongBool), TypeInfo(Currency),
   IInterface(function(const AIn: LongBool; out AOut: Currency): LongBool
     begin AOut := Ord(AIn); Exit(true); end)
  );
end;

class procedure TConverter.RegisterLongInt;
begin
  SetConverter(TypeInfo(LongInt), TypeInfo(AnsiChar),
   IInterface(function(const AIn: LongInt; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(WideChar),
   IInterface(function(const AIn: LongInt; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Pointer),
   IInterface(function(const AIn: LongInt; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(ShortString),
   IInterface(function(const AIn: LongInt; out AOut: ShortString): Boolean
     begin AOut := ShortString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(AnsiString),
   IInterface(function(const AIn: LongInt; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(WideString),
   IInterface(function(const AIn: LongInt; out AOut: WideString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(UnicodeString),
   IInterface(function(const AIn: LongInt; out AOut: UnicodeString): Boolean
     begin AOut := IntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(UCS4String),
   IInterface(function(const AIn: LongInt; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(IntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Boolean),
   IInterface(function(const AIn: LongInt; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(ByteBool),
   IInterface(function(const AIn: LongInt; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(WordBool),
   IInterface(function(const AIn: LongInt; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(LongBool),
   IInterface(function(const AIn: LongInt; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(ShortInt),
   IInterface(function(const AIn: LongInt; out AOut: ShortInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Byte),
   IInterface(function(const AIn: LongInt; out AOut: Byte): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(SmallInt),
   IInterface(function(const AIn: LongInt; out AOut: SmallInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Word),
   IInterface(function(const AIn: LongInt; out AOut: Word): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(LongWord),
   IInterface(function(const AIn: LongInt; out AOut: LongWord): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Int64),
   IInterface(function(const AIn: LongInt; out AOut: Int64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(UInt64),
   IInterface(function(const AIn: LongInt; out AOut: UInt64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Single),
   IInterface(function(const AIn: LongInt; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Double),
   IInterface(function(const AIn: LongInt; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Extended),
   IInterface(function(const AIn: LongInt; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Comp),
   IInterface(function(const AIn: LongInt; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongInt), TypeInfo(Currency),
   IInterface(function(const AIn: LongInt; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterLongWord;
begin
  SetConverter(TypeInfo(LongWord), TypeInfo(AnsiChar),
   IInterface(function(const AIn: LongWord; out AOut: AnsiChar): Boolean
     begin AOut := AnsiChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(WideChar),
   IInterface(function(const AIn: LongWord; out AOut: WideChar): Boolean
     begin AOut := WideChar(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Pointer),
   IInterface(function(const AIn: LongWord; out AOut: Pointer): Boolean
     begin AOut := Ptr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(ShortString),
   IInterface(function(const AIn: LongWord; out AOut: ShortString): Boolean
     begin AOut := ShortString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(AnsiString),
   IInterface(function(const AIn: LongWord; out AOut: AnsiString): Boolean
     begin AOut := AnsiString(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(WideString),
   IInterface(function(const AIn: LongWord; out AOut: WideString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(UnicodeString),
   IInterface(function(const AIn: LongWord; out AOut: UnicodeString): Boolean
     begin AOut := UIntToStr(AIn); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(UCS4String),
   IInterface(function(const AIn: LongWord; out AOut: UCS4String): Boolean
     begin AOut := UnicodeStringToUCS4String(UIntToStr(AIn)); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Boolean),
   IInterface(function(const AIn: LongWord; out AOut: Boolean): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(ByteBool),
   IInterface(function(const AIn: LongWord; out AOut: ByteBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(WordBool),
   IInterface(function(const AIn: LongWord; out AOut: WordBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(LongBool),
   IInterface(function(const AIn: LongWord; out AOut: LongBool): Boolean
     begin AOut := (AIn <> 0); Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(ShortInt),
   IInterface(function(const AIn: LongWord; out AOut: ShortInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Byte),
   IInterface(function(const AIn: LongWord; out AOut: Byte): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(SmallInt),
   IInterface(function(const AIn: LongWord; out AOut: SmallInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Word),
   IInterface(function(const AIn: LongWord; out AOut: Word): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(LongInt),
   IInterface(function(const AIn: LongWord; out AOut: LongInt): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Int64),
   IInterface(function(const AIn: LongWord; out AOut: Int64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(UInt64),
   IInterface(function(const AIn: LongWord; out AOut: UInt64): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Single),
   IInterface(function(const AIn: LongWord; out AOut: Single): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Double),
   IInterface(function(const AIn: LongWord; out AOut: Double): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Extended),
   IInterface(function(const AIn: LongWord; out AOut: Extended): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Comp),
   IInterface(function(const AIn: LongWord; out AOut: Comp): Boolean
     begin AOut := AIn; Exit(true); end)
  );

  SetConverter(TypeInfo(LongWord), TypeInfo(Currency),
   IInterface(function(const AIn: LongWord; out AOut: Currency): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.RegisterMetaclass;
begin
  SetConverter(TypeInfo(TClass), TypeInfo(ShortString),
   IInterface(function(const AIn: TClass; out AOut: ShortString): Boolean
     begin
       if Assigned(AIn) then
         AOut := ShortString(AIn.UnitName + '.' + AIn.ClassName)
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TClass), TypeInfo(AnsiString),
   IInterface(function(const AIn: TClass; out AOut: AnsiString): Boolean
     begin
       if Assigned(AIn) then
         AOut := AnsiString(AIn.UnitName + '.' + AIn.ClassName)
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TClass), TypeInfo(WideString),
   IInterface(function(const AIn: TClass; out AOut: WideString): Boolean
     begin
       if Assigned(AIn) then
         AOut := AIn.UnitName + '.' + AIn.ClassName
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TClass), TypeInfo(UnicodeString),
   IInterface(function(const AIn: TClass; out AOut: UnicodeString): Boolean
     begin
       if Assigned(AIn) then
         AOut := AIn.UnitName + '.' + AIn.ClassName
       else
         AOut := '';
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TClass), TypeInfo(UCS4String),
   IInterface(function(const AIn: TClass; out AOut: UCS4String): Boolean
     begin
       if Assigned(AIn) then
         AOut := UnicodeStringToUCS4String(AIn.UnitName + '.' + AIn.ClassName)
       else
         AOut := UnicodeStringToUCS4String('');
       Exit(true);
     end)
  );

  SetConverter(TypeInfo(TClass), TypeInfo(Pointer),
   IInterface(function(const AIn: TClass; out AOut: Pointer): Boolean
     begin AOut := AIn; Exit(true); end)
  );
end;

class procedure TConverter.SetConverter(const AFrom, ATo: PTypeInfo; const AProc: IInterface);
var
  LSub2: TCorePointerDictionary;
  LWas: IInterface;
begin
  { These should be checked upper in the call chain }
  ASSERT(AFrom <> ATo);
  ASSERT(AFrom <> nil);
  ASSERT(ATo <> nil);

  MonitorEnter(TConverter.FMapping);
  try
    if (not TConverter.FMapping.TryGetValue(AFrom, Pointer(LSub2))) then
    begin
      LSub2 := TCorePointerDictionary.Create();
      TConverter.FMapping.Add(AFrom, LSub2);
    end;

    { Extract the encloded interface if there's any }
    LSub2.TryGetValue(ATo, Pointer(LWas));

    if AProc <> nil then
    begin
      { Set the new interface, if it's not nil }
      LSub2[ATo] := Pointer(AProc);
      AProc._AddRef;
    end else
      LSub2.Remove(ATo); // or remove the entry
  finally
    MonitorExit(TConverter.FMapping)
  end;
end;

end.
