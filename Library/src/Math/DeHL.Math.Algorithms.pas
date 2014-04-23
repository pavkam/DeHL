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
unit DeHL.Math.Algorithms;
interface
uses
  SysUtils,
  Math,
  DeHL.Base,
  DeHL.Types,
  DeHL.Exceptions,
  DeHL.Collections.Base,
  DeHL.Math.Types;

type
  ///  <summary>A static type that exposes several enumeration-based calculus methods.</summary>
  Accumulator = record
    ///  <summary>Calculates the sum of all elements in a collection.</summary>
    ///  <param name="ACollection">A collection that contains numerical values.</param>
    ///  <param name="AType">A type object that describes the numerical values in the collection.</param>
    ///  <returns>The sum of all elements.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeException"><c>T</c> is not a numerical type.</exception>
    class function Sum<T>(const ACollection: IEnexCollection<T>; const AType: IType<T>): T; overload; static;

    ///  <summary>Calculates the sum of all elements in a collection.</summary>
    ///  <param name="ACollection">A collection that contains numerical values.</param>
    ///  <returns>The sum of all elements.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeException"><c>T</c> is not a numerical type.</exception>
    class function Sum<T>(const ACollection: IEnexCollection<T>): T; overload; static;

    ///  <summary>Calculates the average of all elements in a collection.</summary>
    ///  <param name="ACollection">A collection that contains numerical values.</param>
    ///  <param name="AType">A type object that describes the numerical values in the collection.</param>
    ///  <returns>The average value.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeException"><c>T</c> is not a numerical type.</exception>
    class function Average<T>(const ACollection: IEnexCollection<T>; const AType: IType<T>): T; overload; static;

    ///  <summary>Calculates the average of all elements in a collection.</summary>
    ///  <param name="ACollection">A collection that contains numerical values.</param>
    ///  <returns>The average value.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ETypeException"><c>T</c> is not a numerical type.</exception>
    class function Average<T>(const ACollection: IEnexCollection<T>): T; overload; static;
  end;

  ///  <summary>A static type that exposes several utility methods for working with prime numbers.</summary>
  Prime = record
  public
    ///  <summary>Verifies whether a signed number is prime.</summary>
    ///  <param name="X">The number to verify.</param>
    ///  <returns><c>True</c> if the number is prime; <c>False</c> otherwise.</returns>
    class function IsPrime(const X: NativeInt): Boolean; static;

    ///  <summary>Returns the nearest prime using 1.75 progression step.</summary>
    ///  <param name="X">The number for which to obtain the closest prime.</param>
    ///  <returns>The closest prime.</returns>
    class function GetNearestProgressionPositive(const X: NativeInt): NativeInt; static;
  end;

implementation

{ Accumulator }

class function Accumulator.Average<T>(const ACollection: IEnexCollection<T>; const AType: IType<T>): T;
var
  Op: TFunc<T, T, T>;
  NaturalExtension: IUnsignedIntegerMathExtension<T>;
  RealExtension: IRealMathExtension<T>;
  Count: NativeUInt;
begin
  { Check arguments }
  if ACollection = nil then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Apply restrictions! }
  AType.RestrictTo([tfUnsignedInteger, tfSignedInteger, tfReal]);

  { Start at 1 }
  Count := 1;

  if AType.Family = tfReal then
  begin
    RealExtension := TMathExtension<T>.Real(AType);

    { Create an aggregator for numbers }
    Op := function(Arg1, Arg2: T): T begin
      Inc(Count);
      Exit(RealExtension.Add(Arg1, Arg2));
    end;

    { Aggregate }
    Result := ACollection.AggregateOrDefault(Op, RealExtension.Zero);

    { Calculate the division }
    Result := RealExtension.Divide(Result, AType.ConvertFromVariant(Count));
  end else
  begin
    NaturalExtension := TMathExtension<T>.Natural(AType);

    { Create an aggregator for numbers }
    Op := function(Arg1, Arg2: T): T begin
      Inc(Count);
      Exit(NaturalExtension.Add(Arg1, Arg2));
    end;

    { Aggregate }
    Result := ACollection.AggregateOrDefault(Op, NaturalExtension.Zero);

    { Calculate the division }
    Result := NaturalExtension.IntegralDivide(Result, AType.ConvertFromVariant(Count));
  end;
end;

class function Accumulator.Sum<T>(const ACollection: IEnexCollection<T>; const AType: IType<T>): T;
var
  Op: TFunc<T, T, T>;
  Extension: IMathExtension<T>;
begin
  { Check arguments }
  if ACollection = nil then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Apply restrictions! }
  AType.RestrictTo([tfUnsignedInteger, tfSignedInteger, tfReal]);

  { Obtain the extension for natural numbers }
  Extension := TMathExtension<T>.Common(AType);

  { Create an aggregator for numbers }
  Op := function(Arg1, Arg2: T): T begin
    Exit(Extension.Add(Arg1, Arg2));
  end;

  { Apply aggregator }
  Result := ACollection.AggregateOrDefault(Op, Extension.Zero);
end;

class function Accumulator.Average<T>(const ACollection: IEnexCollection<T>): T;
begin
  Result := Average<T>(ACollection, TType<T>.Default);
end;

class function Accumulator.Sum<T>(const ACollection: IEnexCollection<T>): T;
begin
  Result := Sum<T>(ACollection, TType<T>.Default);
end;

const
  { Array containing prime numbers calculated by a progression of 1.175 from the last prime }
  ProgPrimeArray1175 : array[0 .. 116] of NativeInt = (
    $00000003, $00000005, $00000007, $0000000B, $0000000D, $00000011, $00000017, $0000001D, $00000025,
    $0000002B, $00000035, $00000043, $0000004F, $00000061, $0000007F, $00000095, $000000B3, $000000D3,
    $000000FB, $00000133, $0000016F, $000001AF, $000001FD, $00000257, $000002C5, $00000347, $000003DF,
    $00000493, $00000565, $0000065B, $00000779, $000008CB, $00000A57, $00000C2F, $00000E57, $000010E7,
    $000013DF, $0000175D, $00001B7F, $00002051, $000025F9, $00002C9F, $00003481, $00003DB5, $00004897,
    $0000554F, $00006443, $000075D1, $00008A77, $0000A2B3, $0000BF33, $0000E0B7, $00010811, $00013649,
    $00016C99, $0001AC69, $0001F769, $00024F85, $0002B709, $000330AF, $0003BFA7, $000467A7, $00052D0B,
    $000614F5, $00072581, $000865C1, $0009DE0D, $000B9849, $000D9FBD, $0010021D, $0012CF49, $001619FB,
    $0019F84F, $001E83C9, $0023DAE7, $002A2143, $003180B3, $003A2A6D, $00445849, $00504E4B, $005E5C29,
    $006EDF8B, $008246C9, $00991339, $00B3DD01, $00D356EF, $00F85307, $0123C7F7, $0156D7C3, $0192D723,
    $01D9566D, $022C2BF3, $028D8073, $02FFDD79, $03863DEF, $0424225F, $04DDA865, $05B7A5DD, $06B7C94F,
    $07E4BFBF, $0946614D, $0AE5E591, $0CCE210F, $0F0BCD41, $11ADDE0F, $14C5E4F1, $186886A9, $1CAE04B7,
    $21B2DF39, $27989327, $2E8679BB, $36AACF1B, $403BE6AB, $4B79957F, $58AEDC8D, $6833DCDD, $7A702395);

{ Prime }
class function Prime.GetNearestProgressionPositive(const X: NativeInt): NativeInt;
var
  I: NativeInt;
begin
  { Exit with 1 on negative numbers since that is the closes one }
  if X < 0 then
    Exit(1);

  { Lookup the most rapid solutions }
  for I := 0 to Length(ProgPrimeArray1175) - 1 do
  begin
    Result := ProgPrimeArray1175[I];

    { Stop on first found number which is bigger than X }
    if Result >= X then
       Exit;
  end;

  { Generate on the fly }
  I := (X or 1);

  while I < (MaxInt - 1) do
  begin
    { Use a step of 2 }
    Inc(I, 2);

    { If we found a prime number exit directly }
    if IsPrime(I) then
      Exit(I);
  end;

  { The unpropable case ... }
  Result := X;
end;

class function Prime.IsPrime(const X: NativeInt): Boolean;
var
  Rs, I, XX: NativeInt;
begin
  { Get the absolute value }
  XX := Abs(X);

  { Check whether the number is not Odd, and returns true if it is 2 }
  if not Odd(XX) then
    Exit(XX = 2);

  Rs := Round(Sqrt(XX));

  { Start at 3 }
  I := 3;

  { Loop from 3 to X/2 }
  while I <= Rs do
  begin
    { Check the number divides by something in between }
    if (XX mod I) = 0 then
      Exit(false);

    { Increment by two, }
    Inc(I, 2);
  end;

  Result := True;
end;


end.
