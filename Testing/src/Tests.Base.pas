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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.Base;
interface
uses SysUtils,
     TypInfo,
     Rtti,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Collections.List;

type
  TTestBase = class(TDeHLTestCase)
  published
    procedure TestSimpleObjectCtor();
    procedure TestSingletonObject();
    procedure TestRefCountedObjectLife();
    procedure TestRefCountedObjectExtractReference();
    procedure TestRefCountedObjectKeepObjectAlive();
    procedure TestRefCountedObjectReleaseObject();
    procedure TestRefCountedObjectExceptions();
  end;

  TTestSingleton = class(TSingletonObject)
  public
    destructor Destroy(); override;
  end;

  ICheck = interface
    procedure CheckNotConstructing();
    procedure CheckRefCountEquals(const Cnt: Integer);
  end;

  TTestRefCountedObject = class(TRefCountedObject, ICheck)
  private
    FTest: TTestBase;

  public
    constructor Create(const Test: TTestBase);

    procedure CheckNotConstructing();
    procedure CheckRefCountEquals(const Cnt: Integer);

    destructor Destroy(); override;
  end;


type
  TTestActivator = class(TDeHLTestCase)
  published
    procedure Test_CreateInstace_ByName;
    procedure Test_CreateInstace_ByClass;
    procedure Test_CreateInstace_ByTypeInfo;
    procedure Test_CreateInstace_ByRttiObject;
  end;

  { Will be used in the tests of Activator }
  TDummyObject = class
    FMyCtorCalled: Boolean;

    constructor Create;
  end;

implementation

var
  TestDestroy: Integer;

{ TTestBase }

procedure TTestBase.TestRefCountedObjectKeepObjectAlive;
var
  Obj, Obj1, Obj2: TTestRefCountedObject;
  I1, I2: ICheck;
begin
  { ------------ No Interfaces, No destroy ----------- }
  TestDestroy := 0;

  Obj := TTestRefCountedObject.Create(Self);
  Obj1 := TTestRefCountedObject.Create(Self);
  Obj2 := TTestRefCountedObject.Create(Self);

  { Register for keep-alive }
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);

  Obj.Free;
  Check(TestDestroy = 1, 'Only Obj expected to be gone!');

  { ------------ Interfaces, No chain -------------}
  TestDestroy := 0;
  Obj := TTestRefCountedObject.Create(Self);
  I1 := Obj1;
  I2 := Obj2;

  { Should not allow Obj1 and 2 to be killed! }
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);

  I1 := nil;
  I2 := nil;

  Check(TestDestroy = 0, 'Expected no deaths while keeping alive!');

  Obj.Free;
  Check(TestDestroy = 3, 'Expected all objects to be killed!');

  { ------------ Interfaces, Chain -------------}
  TestDestroy := 0;
  Obj := TTestRefCountedObject.Create(Self);
  Obj1 := TTestRefCountedObject.Create(Self);
  Obj2 := TTestRefCountedObject.Create(Self);

  I1 := Obj1;
  I2 := Obj2;

  { Should not allow Obj1 and 2 to be killed! }
  Obj.KeepObjectAlive(Obj1);
  Obj1.KeepObjectAlive(Obj2);

  I1 := nil;
  I2 := nil;

  Check(TestDestroy = 0, 'Expected no deaths while keeping alive!');

  Obj.Free;
  Check(TestDestroy = 3, 'Expected all objects to be killed!');

  { ------------ Test nil's ------------ }
  TestDestroy := 0;
  Obj := TTestRefCountedObject.Create(Self);

  Obj.KeepObjectAlive(nil);
  Obj.KeepObjectAlive(nil);
  Obj.KeepObjectAlive(nil);

  Obj.Free;

  Check(TestDestroy = 1, 'Expected Obj to die properly!');
end;

procedure TTestBase.TestRefCountedObjectLife;
var
  Obj: TTestRefCountedObject;
  I, I1: ICheck;
begin
  { First types of checks }
  Obj := TTestRefCountedObject.Create(Self);
  Obj.CheckNotConstructing();
  Obj.CheckRefCountEquals(0);
  Obj.Free;

  { Interface checks }
  I := TTestRefCountedObject.Create(Self);
  I.CheckNotConstructing();
  I.CheckRefCountEquals(1);

  I1 := I;
  I.CheckRefCountEquals(2);

  I1 := nil;
  I.CheckRefCountEquals(1);

  I := nil;
end;

procedure TTestBase.TestRefCountedObjectReleaseObject;
var
  Obj, Obj1, Obj2: TTestRefCountedObject;
  I1, I2: ICheck;
begin
  { ------------ No Interfaces, No destroy ----------- }
  TestDestroy := 0;

  Obj := TTestRefCountedObject.Create(Self);
  Obj1 := TTestRefCountedObject.Create(Self);
  Obj2 := TTestRefCountedObject.Create(Self);

  { Register for keep-alive }
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);

  Obj.ReleaseObject(Obj1);
  Obj.ReleaseObject(Obj2);

  Obj.Free;

  Check(TestDestroy = 1, 'Only Obj expected to be gone!');

  { ------------ No Interfaces, Destroy ----------- }
  TestDestroy := 0;

  Obj := TTestRefCountedObject.Create(Self);

  { Register for keep-alive }
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);

  Obj.ReleaseObject(Obj1, true);
  Obj.ReleaseObject(Obj2, true);

  Obj.Free;

  Check(TestDestroy = 3, 'Only Obj, Obj1, Obj2 expected to be gone!');

  { ------------ Interfaces, Destroy ----------- }
  TestDestroy := 0;

  Obj := TTestRefCountedObject.Create(Self);
  Obj1 := TTestRefCountedObject.Create(Self);
  Obj2 := TTestRefCountedObject.Create(Self);

  I1 := Obj1;
  I2 := Obj2;

  { Register for keep-alive }
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);

  I1 := nil;
  I2 := nil;

  Obj.ReleaseObject(Obj1);
  Obj.ReleaseObject(Obj2);

  Check(TestDestroy = 2, 'Only Obj1, Obj2 expected to be gone!');

  Obj.Free;
  Check(TestDestroy = 3, 'All Obj, Obj1, Obj2 expected to be gone!');

  { ------------ Lots of Interfaces, Destroy ----------- }
  TestDestroy := 0;

  Obj := TTestRefCountedObject.Create(Self);
  Obj1 := TTestRefCountedObject.Create(Self);
  Obj2 := TTestRefCountedObject.Create(Self);

  I1 := Obj1;
  I2 := Obj2;

  { Register for keep-alive }
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);
  Obj.KeepObjectAlive(Obj1);
  Obj.KeepObjectAlive(Obj2);

  I1 := nil;
  I2 := nil;

  Obj.ReleaseObject(Obj1);
  Obj.ReleaseObject(Obj2);
  Check(TestDestroy = 0, 'Nothing should be gone!');

  Obj.ReleaseObject(Obj1);
  Obj.ReleaseObject(Obj2);
  Check(TestDestroy = 0, 'Nothing should be gone!');

  Obj.Free;
  Check(TestDestroy = 3, 'All Obj, Obj1, Obj2 expected to be gone!');
end;


procedure TTestBase.TestRefCountedObjectExceptions;
var
  Obj: TTestRefCountedObject;
begin
  Obj := TTestRefCountedObject.Create(self);

  CheckException(ECannotSelfReferenceException,
    procedure() begin
      Obj.KeepObjectAlive(Obj);
    end,
    'ECannotSelfReferenceException not thrown in KeepObjectAlive()'
  );

  CheckException(ECannotSelfReferenceException,
    procedure() begin
      Obj.ReleaseObject(Obj);
    end,
    'ECannotSelfReferenceException not thrown in ReleaseObject()'
  );

  Obj.Free;
end;

procedure TTestBase.TestRefCountedObjectExtractReference;
var
  Obj: TTestRefCountedObject;
  I: ICheck;
begin
  Obj := TTestRefCountedObject.Create(Self);
  Check(Obj.ExtractReference = nil, 'Expected nil!');

  I := Obj;
  Check(Obj.ExtractReference <> nil, 'Expected not nil!');

  I := nil;
end;

procedure TTestBase.TestSimpleObjectCtor;
begin
  CheckException(EDefaultConstructorNotAllowed,
    procedure() begin
      TSimpleObject.Create();
    end,
    'EDefaultConstructorNotAllowed not thrown in Create()'
  );
end;

procedure TTestBase.TestSingletonObject;
var
  Obj: TTestSingleton;
  I: IInterface;
begin
  TestDestroy := 0;

  Obj := TTestSingleton.Create;

  { Get and lose reference }
  I := Obj;
  I := nil;

  Check(TestDestroy = 0, 'Should not have died!');

  Obj._AddRef();
  Obj._Release();

  Check(TestDestroy = 0, 'Should not have died!');

  Obj.Free;
  Check(TestDestroy = 1, 'Should have died!');
end;

{ TTestSingleton }

destructor TTestSingleton.Destroy;
begin
  Inc(TestDestroy);
  inherited;
end;

{ TTestRefCountedObject }

procedure TTestRefCountedObject.CheckNotConstructing;
begin
  FTest.Check(not Constructing, 'Should not be checked as Constructing!');
end;

procedure TTestRefCountedObject.CheckRefCountEquals(const Cnt: Integer);
begin
  FTest.Check(RefCount = Cnt, 'RefCount is not what it was expected to be!');
end;

constructor TTestRefCountedObject.Create(const Test: TTestBase);
begin
  Test.Check(Constructing, 'Should be checked as Constructing!');
  Test.Check(RefCount = 1, 'Ref count should be 1');
  Test.Check(ExtractReference = nil, 'No reference should be expected in ctor!');

  FTest := Test;
end;

destructor TTestRefCountedObject.Destroy;
begin
  FTest.Check(not Constructing, 'Should not be checked as Constructing!');
  Inc(TestDestroy);

  inherited;
end;


{ TDummyObject }

constructor TDummyObject.Create;
begin
  FMyCtorCalled := true;
end;

{ TTestActivator }

procedure TTestActivator.Test_CreateInstace_ByClass;
var
  LInst: TObject;
begin
  { Build the lookup string }
  LInst := Activator.CreateInstance(TDummyObject);

  CheckTrue(LInst is TDummyObject, 'Not the object that was expceted');
  CheckTrue(TDummyObject(LInst).FMyCtorCalled, 'Local constructor not called');

  { Error case }
  CheckException(ENilArgumentException,
    procedure() begin
      Activator.CreateInstance(TClass(nil));
    end,
    'ENilArgumentException not thrown in CreateInstance(). nil class type.'
  );
end;

procedure TTestActivator.Test_CreateInstace_ByName;
var
  LName: String;
  LInst: TObject;
begin
  { Build the lookup string }
  LName := TDummyObject.UnitName + '.' + TDummyObject.ClassName;
  LInst := Activator.CreateInstance(LName);

  CheckTrue(LInst is TDummyObject, 'Not the object that was expceted');
  CheckTrue(TDummyObject(LInst).FMyCtorCalled, 'Local constructor not called');

  { Error case }
  CheckException(ENilArgumentException,
    procedure() begin
      Activator.CreateInstance('');
    end,
    'ENilArgumentException not thrown in CreateInstance(). Bad string.'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      Activator.CreateInstance('SomeUnit.NotExistingClass');
    end,
    'ENilArgumentException not thrown in CreateInstance(). Bad string.'
  );
end;

procedure TTestActivator.Test_CreateInstace_ByRttiObject;
var
  LInst: TObject;
  LCtx: TRttiContext;
begin
  { Build the lookup string }
  LInst := Activator.CreateInstance(TRttiInstanceType(LCtx.GetType(TDummyObject)));

  CheckTrue(LInst is TDummyObject, 'Not the object that was expceted');
  CheckTrue(TDummyObject(LInst).FMyCtorCalled, 'Local constructor not called');

  { Error case }
  CheckException(ENilArgumentException,
    procedure() begin
      Activator.CreateInstance(TRttiInstanceType(nil));
    end,
    'ENilArgumentException not thrown in CreateInstance(). nil rtti type.'
  );
end;

procedure TTestActivator.Test_CreateInstace_ByTypeInfo;
var
  LInst: TObject;
begin
  { Build the lookup string }
  LInst := Activator.CreateInstance(TDummyObject.ClassInfo);

  CheckTrue(LInst is TDummyObject, 'Not the object that was expceted');
  CheckTrue(TDummyObject(LInst).FMyCtorCalled, 'Local constructor not called');

  { Error case }
  CheckException(ENilArgumentException,
    procedure() begin
      Activator.CreateInstance(PTypeInfo(nil));
    end,
    'ENilArgumentException not thrown in CreateInstance(). nil type info.'
  );
end;

initialization
  TestFramework.RegisterTest(TTestBase.Suite);
  TestFramework.RegisterTest(TTestActivator.Suite);

end.
