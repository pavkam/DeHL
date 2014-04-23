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

unit Tests.Utils;
interface
uses
  SysUtils, TestFramework,
  DeHL.Base,
  DeHL.Exceptions,
  DeHL.Types;

type
  TSimpleClosure = reference to procedure;
  TClassOfException = class of Exception;

  { Our test case }
  TDeHLTestCase = class(TTestCase)
  protected
    procedure CheckException(ExType : TClassOfException; Proc : TSimpleClosure; const Msg : String);
  end;

  { Our test type support }
  TTestType<T> = class(TType<T>, IType<T>)
  private
    FRealType: IType<T>;
    FCleanup: TProc<T>;
  public
    constructor Create(); overload; override;
    constructor Create(const CleanupProc: TProc<T>); reintroduce; overload;

    function Compare(const AValue1, AValue2 : T) : NativeInt; override;
    function GenerateHashCode(const AValue : T) : NativeInt; override;
    function GetString(const AValue : T) : String; override;
    function Management(): TTypeManagement; override;
    procedure Cleanup(var AValue: T); override;
  end;

  { Our test type support }
  TExType<T> = class(TType<T>)
  private
    FRealType: IType<T>;
  public
    constructor Create(); overload; override;

    function Compare(const AValue1, AValue2: T) : NativeInt; override;
    function GenerateHashCode(const AValue: T) : NativeInt; override;
    function GetString(const AValue: T) : String; override;
    function Management(): TTypeManagement; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: T; out ORes: Variant): Boolean; override;

    procedure Cleanup(var AValue: T); override;
  end;

  TTestObject = class
  private
    FBoolRef: PBoolean;
  public
    constructor Create(const BoolRef: PBoolean);
    destructor Destroy(); override;
  end;

implementation

{ TDeHLTestCase }

procedure TDeHLTestCase.CheckException(ExType: TClassOfException;
  Proc: TSimpleClosure; const Msg: String);
var
  bWasEx : Boolean;
begin
  bWasEx := False;

  try
    { Cannot self-link }
    Proc();
  except
    on E : Exception do
    begin
       if E is ExType then
          bWasEx := True;
    end;
  end;

  Check(bWasEx, Msg);
end;

{ TTestType<T> }

procedure TTestType<T>.Cleanup(var AValue: T);
begin
  FCleanup(AValue);
  FRealType.Cleanup(AValue);
end;

function TTestType<T>.Compare(const AValue1,
  AValue2: T): NativeInt;
begin
  Result := FRealType.Compare(AValue1, AValue2);
end;

constructor TTestType<T>.Create;
begin
  ExceptionHelper.Throw_DefaultConstructorNotAllowedError();
end;

constructor TTestType<T>.Create(
  const CleanupProc: TProc<T>);
begin
  FRealType := Default;
  FCleanup := CleanupProc;
end;

function TTestType<T>.GenerateHashCode(
  const AValue: T): NativeInt;
begin
  Result := FRealType.GenerateHashCode(AValue);
end;

function TTestType<T>.Management: TTypeManagement;
begin
  Result := tmManual;
end;

function TTestType<T>.GetString(
  const AValue: T): String;
begin
  Result := FRealType.GetString(AValue);
end;

{ TTestObject }

constructor TTestObject.Create(const BoolRef: PBoolean);
begin
  BoolRef^:= false;
  FBoolRef := BoolRef;
end;

destructor TTestObject.Destroy;
begin
  FBoolRef^ := true;
  inherited;
end;

{ TExType<T> }

procedure TExType<T>.Cleanup(var AValue: T);
begin
  FRealType.Cleanup(AValue);
end;

function TExType<T>.Compare(const AValue1, AValue2: T): NativeInt;
begin
  Result := FRealType.Compare(AValue1, AValue2);
end;

constructor TExType<T>.Create;
begin
  FRealType := Default;
end;

function TExType<T>.GenerateHashCode(const AValue: T): NativeInt;
begin
  Result := FRealType.GenerateHashCode(AValue);
end;

function TExType<T>.Management: TTypeManagement;
begin
  Result := tmManual;
end;

function TExType<T>.TryConvertToVariant(const AValue: T; out ORes: Variant): Boolean;
begin
  Result := FRealType.TryConvertToVariant(AValue, ORes);

  if Result then
    ORes := '>>' + ORes;
end;

function TExType<T>.GetString(const AValue: T): String;
begin
  Result := '>>' + FRealType.GetString(AValue);
end;

end.
