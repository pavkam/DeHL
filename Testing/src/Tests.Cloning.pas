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
unit Tests.Cloning;
interface
uses SysUtils,
     Types,
     DateUtils,
     Math,
     Windows,
     Tests.Utils,
     TestFramework,
     DeHL.Cloning,
     Tests.Serialization.Gross;

type
  TTestCloning = class(TDeHLTestCase)
  private
    class function Replicate<T>(const AValue: T): T; static;

  published
    procedure Test_Simple;
    procedure Test_Integers;
    procedure Test_Floats;
    procedure Test_Strings;
    procedure Test_Booleans;
    procedure Test_Arrays;
    procedure Test_DTs;
    procedure Test_EnumsAndSets;
    procedure Test_ClassSelfRef;
    procedure Test_ClassNil;
    procedure Test_FlatArray;
    procedure Test_RecordSelfRef;
    procedure Test_DoubleRefs;
    procedure Test_ClassComplicated;
    procedure Test_ClassSameFields;
    procedure Test_ByReference;
    procedure Test_ByReference_Defaults;
    procedure Test_NonReplicable;
    procedure Test_InterfaceCopy;
    procedure Test_UStringCopy;
    procedure Test_AStringCopy;
    procedure Test_DynArrayCopy;
  end;

  TTestCloneableObject = class(TDeHLTestCase)
  published
    procedure Test_Clone;
    procedure Test_Clone_With_Intf;
    procedure Test_ICloneable_Deep;
  end;

type
  TBytes = array of Byte; // HACK, SysUtils.TBytes has no RTTI anymore :(

{ By-refence tests }
type
  PFormatSettings = ^TFormatSettings;
  TByRefTest = record
    [CloneKind(ckReference)]
    FObject: TObject;

    [CloneKind(ckReference)]
    FArray: TBytes;

    [CloneKind(ckReference)]
    FPtrArr: PFormatSettings;
  end;

  TDefaultsTest = record
    FObject: TObject;
    FArray: TBytes;
    FPtrArr: PFormatSettings;
  end;

{ Testing for non-replicable }
type
  TNonReplicableTest = record
    FString: String;

    [CloneKind(ckSkip)]
    FNonReplString: String;
  end;

type
  { Define a cloneable object }
  TMyCloneable = class(TCloneableObject)
    FData: String;

    [CloneKind(ckSkip)]
    FNoCopy: Integer;

    [CloneKind(ckReference)]
    FDynArray: TBytes;
  end;

  { Clone in clone test }
  TCoolCloneable = class(TCloneableObject)
    FIndex: Integer;

    [CloneKind(ckDeep)]
    FCloneMeToo: TCoolCloneable;

    function Clone(): TObject; override;
  end;

{ Flat tests }
type
  TFlatCopyTest = record
    [CloneKind(ckFlat)]
    FArr: array of TObject;
  end;

{ Double refs }
type
  TDoubleRefCopyTest = record
    [CloneKind(ckDeep)]
    FObj1: TObject;

    [CloneKind(ckReference)]
    FObj2: TObject;

    [CloneKind(ckDeep)]
    FRec1: PFormatSettings;

    [CloneKind(ckReference)]
    FRec2: PFormatSettings;

    [CloneKind(ckDeep)]
    FArr1: TBytes;

    [CloneKind(ckReference)]
    FArr2: TBytes;
  end;

implementation

{ TTestCloning }

class function TTestCloning.Replicate<T>(const AValue: T): T;
var
  LReplicator: TReplicator<T>;
begin
  LReplicator := TReplicator<T>.Create();

  try
    LReplicator.Replicate(AValue, Result);
  finally
    LReplicator.Free;
  end;
end;

procedure TTestCloning.Test_Arrays;
var
  LInput, LOutput: TArraysRecord;
begin
  LInput := TArraysRecord.Create;
  LOutput := Replicate<TArraysRecord>(LInput);
  LInput.CompareTo(LOutput);
end;

procedure TTestCloning.Test_AStringCopy;
var
  LInput, LOutput: AnsiString;
begin
  LInput := 'Test me!';
  LOutput := Replicate<AnsiString>(LInput);
  LInput := '';

  CheckEquals(1, StringRefCount(LOutput), 'StringRefCount(LOutput)');
  CheckEquals('Test me!', LOutput, 'LOutput');
end;

procedure TTestCloning.Test_Booleans;
var
  LInput, LOutput: TBooleanRecord;
begin
  LInput := TBooleanRecord.Create;
  LOutput := Replicate<TBooleanRecord>(LInput);
  LInput.CompareTo(LOutput);
end;

procedure TTestCloning.Test_ByReference;
var
  LInput, LOutput: TByRefTest;
  LFmtSett: TFormatSettings;
begin
  LInput.FObject := TObject.Create;
  LInput.FArray := TBytes.Create(1, 2, 3);
  LInput.FPtrArr := @LFmtSett;

  try
    LOutput := Replicate<TByRefTest>(LInput);

    CheckTrue(LInput.FObject = LOutput.FObject, 'FObject not copied by ref');
    CheckTrue(Pointer(LInput.FArray) = Pointer(LOutput.FArray), 'FArray not copied by ref');
    CheckTrue(LInput.FPtrArr = LOutput.FPtrArr, 'FPtrArr not copied by ref');
  finally
    LInput.FObject.Free;
  end;
end;

procedure TTestCloning.Test_ByReference_Defaults;
var
  LInput, LOutput: TDefaultsTest;
  LFmtSett: TFormatSettings;
begin
  LInput.FObject := TObject.Create;
  LInput.FArray := TBytes.Create(1, 2, 3);
  LInput.FPtrArr := @LFmtSett;

  try
    LOutput := Replicate<TDefaultsTest>(LInput);

    CheckTrue(LInput.FObject = LOutput.FObject, 'FObject not copied by ref');
    CheckTrue(Pointer(LInput.FArray) <> Pointer(LOutput.FArray), 'FArray copied by ref');
    CheckTrue(Length(LInput.FArray) = Length(LOutput.FArray), 'FArray bad copied');
    CheckTrue(LInput.FPtrArr = LOutput.FPtrArr, 'FPtrArr not copied by ref');
  finally
    LInput.FObject.Free;
  end;
end;

procedure TTestCloning.Test_ClassComplicated;
var
  LInput, LOutput: TContainer;
begin
  LInput := TContainer.Create(true);
  LOutput := nil;
  try
    LOutput := TContainer(Replicate<TObject>(LInput));

    CheckTrue(LOutput <> nil, 'LOutput is nil');
    CheckTrue(LOutput is TContainer, 'LOutput is not TContainer');

    LOutput.Test(true);
  finally
    LInput.Free;
    LOutput.Free;
  end;
end;

procedure TTestCloning.Test_ClassNil;
var
  LOutput: TObject;
begin
  LOutput := Replicate<TObject>(nil);
  CheckTrue(LOutput = nil, 'LOutput is not nil');
end;

procedure TTestCloning.Test_ClassSameFields;
var
  LInput, LOutput: TInhDerived2;
begin
  LInput := TInhDerived2.Create();
  LOutput := nil;

  try
    LOutput := Replicate<TInhDerived2>(LInput);

    CheckTrue(LOutput <> nil, 'LOutXml is nil');

    LOutput.Test();
  finally
    LInput.Free;
    LOutput.Free;
  end;
end;

procedure TTestCloning.Test_ClassSelfRef;
var
  LInput, LOutput: TChainedClass;
begin
  LInput := TChainedClass.Create;

  LOutput := nil;

  try
    LOutput := Replicate<TChainedClass>(LInput);

    CheckTrue(LOutput <> nil, 'LOutput is nil');
    CheckTrue(LOutput.FSelf = LOutput, 'LOutput.FSelf <> LOutXml');
    CheckTrue(LOutput.FNil = nil, 'LOutput.FSelf <> nil');
  finally
    LInput.Free;
    LOutput.Free;
  end;
end;

procedure TTestCloning.Test_DoubleRefs;
var
  LInput, LOutput: TDoubleRefCopyTest;
  LFmt: TFormatSettings;
begin
  GetLocaleFormatSettings(GetThreadLocale(), LFmt);

  { Initialize }
  LInput.FObj1 := TObject.Create;
  LInput.FObj2 := LInput.FObj1;
  LInput.FRec1 := @LFmt;
  LInput.FRec2 := @LFmt;
  LInput.FArr1 := TBytes.Create(1);
  LInput.FArr2 := LInput.FArr1;

  try
    LOutput := Replicate<TDoubleRefCopyTest>(LInput);

    CheckTrue(LInput.FObj1 <> LOutput.FObj1, 'FObj should not be the same object!');
    CheckTrue(LOutput.FObj2 = LOutput.FObj1, 'Both references should FObj be the same.');

    CheckTrue(LInput.FRec1 <> LOutput.FRec1, 'FRec1 should not be the same object!');
    CheckTrue(LOutput.FRec1 = LOutput.FRec2, 'Both references should FRec be the same.');

    CheckTrue(Pointer(LInput.FArr1) <> Pointer(LOutput.FArr1), 'FArr should not be the same object!');
    CheckTrue(Pointer(LOutput.FArr2) = Pointer(LOutput.FArr2), 'Both references should FArr be the same.');
    CheckTrue(Length(LOutput.FArr2) = Length(LOutput.FArr2), 'Lengths of FArr be the same.');
  finally
    LInput.FObj1.Free;
    LOutput.FObj1.Free;
    Dispose(LOutput.FRec1);
  end;
end;

procedure TTestCloning.Test_DTs;
var
  LInput, LOutput: TDateTimeRecord;
begin
  LInput := TDateTimeRecord.Create;
  LOutput := Replicate<TDateTimeRecord>(LInput);
  LInput.CompareTo(LOutput);
end;

procedure TTestCloning.Test_DynArrayCopy;
var
  LInput, LOutput: TBytes;
begin
  LInput := TBytes.Create(1, 2, 3);
  LOutput := Replicate<TBytes>(LInput);
  LInput := nil;

  CheckEquals(3, Length(LOutput), 'Length(LOutput)');
  CheckEquals(1, LOutput[0], 'LOutput[0]');
  CheckEquals(2, LOutput[1], 'LOutput[1]');
  CheckEquals(3, LOutput[2], 'LOutput[2]');
end;

procedure TTestCloning.Test_EnumsAndSets;
var
  LInput, LOutput: TEnumSetRecord;
begin
  LInput := TEnumSetRecord.Create;
  LOutput := Replicate<TEnumSetRecord>(LInput);
  LInput.CompareTo(LOutput);
end;

procedure TTestCloning.Test_FlatArray;
var
  LInput, LOutput: TFlatCopyTest;
begin
  SetLength(LInput.FArr, 1);
  LInput.FArr[0] := TObject.Create;

  try
    LOutput := Replicate<TFlatCopyTest>(LInput);

    CheckEquals(1, Length(LOutput.FArr), 'Length of FArr');
    CheckTrue(Pointer(LInput.FArr) <> Pointer(LOutput.FArr), 'Same array FArr');
    CheckTrue(LInput.FArr[0] = LOutput.FArr[0], 'The actual object');
  finally
    LInput.FArr[0].Free;
  end;
end;

procedure TTestCloning.Test_Floats;
var
  LInput, LOutput: TFloatsRecord;
begin
  LInput := TFloatsRecord.Create;
  LOutput := Replicate<TFloatsRecord>(LInput);
  LInput.CompareTo(LOutput);
end;

procedure TTestCloning.Test_Integers;
var
  LInput, LOutput: TIntsRecord;
begin
  LInput := TIntsRecord.Create;
  LOutput := Replicate<TIntsRecord>(LInput);
  LInput.CompareTo(LOutput);
end;

procedure TTestCloning.Test_InterfaceCopy;
var
  LObj: TInterfacedObject;
  LInput, LOutput: IInterface;
begin
  LObj := TInterfacedObject.Create;
  LInput := LObj;

  LOutput := Replicate<IInterface>(LInput);

  CheckTrue(Pointer(LInput) = Pointer(LOutput), 'Interface not copied properly.');
  CheckEquals(2, LObj.RefCount, 'Interface''s RefCount not adjusted.');
end;

procedure TTestCloning.Test_NonReplicable;
var
  LInput, LOutput: TNonReplicableTest;
begin
  LInput.FString := 'Hello Dudes!';
  LInput.FNonReplString := 'No copy me!';

  LOutput := Replicate<TNonReplicableTest>(LInput);

  CheckTrue(LInput.FString = LOutput.FString, 'FString not copied!');
  CheckTrue(LOutput.FNonReplString = '', 'FNonReplString was copied!');
end;

procedure TTestCloning.Test_RecordSelfRef;
var
  LInput, LOutput: PLinkedItem;
begin
  New(LInput);
  LInput.FData := 'Hello World!';
  LInput.FSelf := LInput;
  LInput.FNil := nil;

  LOutput := nil;
  try
    LOutput := Replicate<PLinkedItem>(LInput);

    CheckTrue(LOutput <> nil, 'LOutput is nil');
    CheckTrue(LOutput^.FSelf = LOutput, 'LOutput.FSelf <> LOutput');
    CheckTrue(LOutput^.FNil = nil, 'LOutput.FSelf <> nil');
  finally
    Dispose(LInput);

    if LOutput <> nil then
      Dispose(LOutput);
  end;
end;

procedure TTestCloning.Test_Simple;
var
  LInput, LOutput: Integer;
begin
  LInput := -100;
  LOutput := Replicate<Integer>(LInput);
  CheckEquals(LInput, LOutput, '(Integer)');
end;

procedure TTestCloning.Test_UStringCopy;
var
  LInput, LOutput: String;
begin
  LInput := 'Test me!';
  LOutput := Replicate<String>(LInput);
  LInput := '';

  CheckEquals(1, StringRefCount(LOutput), 'StringRefCount(LOutput)');
  CheckEquals('Test me!', LOutput, 'LOutput');
end;

procedure TTestCloning.Test_Strings;
var
  LInput, LOutput: TStringsRecord;
begin
  LInput := TStringsRecord.Create;
  LOutput := Replicate<TStringsRecord>(LInput);
  LInput.CompareTo(LOutput);
end;

{ TTestCloneableObject }

procedure TTestCloneableObject.Test_Clone;
var
  LObj, LCopy: TMyCloneable;
begin
  LObj := TMyCloneable.Create;
  LObj.FData := 'Some data';
  LObj.FNoCopy := 100;
  LObj.FDynArray := TBytes.Create(1, 2, 3, 4);

  { Clone }
  LCopy := LObj.Clone() as TMyCloneable;

  CheckTrue(LCopy <> nil, 'LCopy is nil');
  CheckEquals(0, LObj.RefCount, 'LObj.RefCount');
  CheckEquals(0, LCopy.RefCount, 'LCopy.RefCount');
  CheckEquals(LObj.FData, LCopy.FData, 'LObj.FData <> LCopy.FData');
  CheckNotEquals(LObj.FNoCopy, LCopy.FNoCopy, 'LObj.FNoCopy = LCopy.FNoCopy');
  CheckTrue(Pointer(LObj.FDynArray) = Pointer(LCopy.FDynArray), 'LObj.FDynArray <> LCopy.FDynArray');

  LObj.Free;
  LCopy.Free;
end;


procedure TTestCloneableObject.Test_Clone_With_Intf;
var
  LObj, LCopy: TMyCloneable;
  LIntf: ICloneable;
begin
  LObj := TMyCloneable.Create;
  LObj.FData := 'Some data';
  LObj.FNoCopy := 100;
  LObj.FDynArray := TBytes.Create(1, 2, 3, 4);
  LIntf := LObj;

  { Clone }
  LCopy := LIntf.Clone() as TMyCloneable;

  CheckTrue(LCopy <> nil, 'LCopy is nil');
  CheckEquals(1, LObj.RefCount, 'LObj.RefCount');
  CheckEquals(0, LCopy.RefCount, 'LCopy.RefCount');
  CheckEquals(LObj.FData, LCopy.FData, 'LObj.FData <> LCopy.FData');
  CheckNotEquals(LObj.FNoCopy, LCopy.FNoCopy, 'LObj.FNoCopy = LCopy.FNoCopy');
  CheckTrue(Pointer(LObj.FDynArray) = Pointer(LCopy.FDynArray), 'LObj.FDynArray <> LCopy.FDynArray');

  LCopy.Free;
end;

procedure TTestCloneableObject.Test_ICloneable_Deep;
var
  LObj, LCopy: TCoolCloneable;
begin
  LObj := TCoolCloneable.Create;
  LObj.FCloneMeToo := TCoolCloneable.Create;
  LObj.FCloneMeToo.FIndex := 99;
  LCopy := nil;

  try
    { Clone }
    LCopy := LObj.Clone() as TCoolCloneable;

    CheckTrue(LCopy <> nil, 'LCopy is nil');
    CheckTrue(LCopy.FCloneMeToo <> nil, 'LCopy.FCloneMeToos is nil');

    CheckEquals(0, LObj.RefCount, 'LCopy.RefCount');
    CheckEquals(0, LObj.FCloneMeToo.RefCount, 'LCopy.FCloneMeToo.RefCount');

    CheckEquals(1, LCopy.FIndex, 'LCopy.FIndex <> 1');
    CheckEquals(100, LCopy.FCloneMeToo.FIndex, 'LCopy.FCloneMeToo.FIndex <> 100');

    CheckEquals(0, LObj.FIndex, 'LObj.FIndex <> 0');
    CheckEquals(99, LObj.FCloneMeToo.FIndex, 'LObj.FCloneMeToo.FIndex <> 99');
  finally
    LObj.FCloneMeToo.Free;
    LObj.Free;

    if LCopy <> nil then
      LCopy.FCloneMeToo.Free;
    LCopy.Free;
  end;
end;

{ TCoolCloneable }

function TCoolCloneable.Clone: TObject;
begin
  Result := inherited Clone();
  TCoolCloneable(Result).FIndex := FIndex + 1;
end;

initialization
  TestFramework.RegisterTest(TTestCloning.Suite);
  TestFramework.RegisterTest(TTestCloneableObject.Suite);

end.
