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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.References;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.References;

type
  { Some obj to test with }
  TObj = class
  private
    FProc : TProc;

  public
    constructor Create(const AProc : TProc);
    destructor Destroy(); override;
  end;

  { A obj that contains an auoto pointer }
  TTest2 = class
  private
    FPtr : Scoped<TObj>;
  public
    constructor Create(const AProc : TProc);

  end;

type
  TTestReferences = class(TDeHLTestCase)
    procedure TestScopeObjectSimple();
    procedure TestScopeNilRef();
    procedure TestScopeClass();
    procedure TestSharedWeak();

    procedure TestType_Scoped;
    procedure TestType_Shared;
    procedure TestType_Weak;
  end;

implementation

{ TObj }

constructor TObj.Create(const AProc: TProc);
begin
  FProc := AProc;
end;

destructor TObj.Destroy;
begin
  FProc();
  inherited;
end;

{ TTest2 }

constructor TTest2.Create;
begin
  FPtr := TObj.Create(AProc);
end;

{ TTestReferences }

procedure TTestReferences.TestScopeClass;
var
  C : TTest2;
  Killed : Boolean;
begin
  Killed := False;
  C := TTest2.Create(procedure begin Killed := true; end);

  Check(not Killed, 'Not expected AutoPointer to be that stupid');

  C.Free;

  Check(Killed, 'Expected AutoPointer to free up resources when "parent" object dies');
end;

procedure TTestReferences.TestScopeNilRef;
var
  O : Scoped<TObj>;
begin
  try
    O := nil;
  except
    on Exception do
       Fail('No exception should be thrown in NIL implicit.');
  end;

  try
    O := nil;
  except
    on Exception do
       Fail('No exception should be thrown in second NIL implicit.');
  end;
end;

procedure TTestReferences.TestScopeObjectSimple;
var
  O      : Scoped<TObj>;
  B      : TObj;
  Killed : Boolean;
begin
  { Check the default value }
  Check(O.Ref = nil, 'O.Value expected to be nil!');
  CheckFalse(O.IsValid);

  { Check instantiation }
  Killed := false;

  B := TObj.Create(procedure begin Killed := true; end);
  O := B;

  CheckTrue(O.IsValid);
  Check(O.Ref = B, 'O.Value expected to be equal to B');

  { Make the object expire  }
  O := nil;

  Check(Killed, 'Object auto-cleanup failed!');
end;

procedure TTestReferences.TestSharedWeak;
var
  Obj: TObj;
  S1, S2: Shared<TObj>;
  W1, W2: Weak<TObj>;
  Killed : Boolean;
begin
  { Check the default value }
  Check(S1.Ref = nil, 'S1.Ref expected to be nil!');

  { Check instantiation }
  Killed := false;
  Obj := TObj.Create(procedure begin Killed := true; end);
  S1 := Obj;

  CheckTrue(S1.Ref = Obj);
  CheckTrue(S1.IsValid);
  CheckEquals(1, S1.UseCount);

  { Obtain a weak ref ... and others }
  CheckFalse(W1.IsValid);
  W1 := S1.ToWeak;

  S2 := W1;

  CheckFalse(W2.IsValid);
  W2 := S2;

  CheckTrue(S2.Ref = Obj);
  CheckTrue(S2.IsValid);

  CheckEquals(2, S1.UseCount);
  CheckEquals(2, S2.UseCount);

  { kill shareds }
  CheckFalse(Killed, 'no kill 1');
  S1 := nil;
  CheckFalse(Killed, 'no kill 2');
  S2 := nil;
  CheckTrue(Killed, 'must kill x');

  CheckFalse(W1.IsValid);
  CheckFalse(W2.IsValid);

  S1 := W1;
  S2 := W2;

  CheckFalse(S1.IsValid);
  CheckFalse(S2.IsValid);
  CheckEquals(0, S1.UseCount);
  CheckEquals(0, S2.UseCount);
  CheckTrue(S1.Ref = nil);
  CheckTrue(S1.Ref = nil);
end;

procedure TTestReferences.TestType_Scoped;
var
  X, Y: Scoped<TObject>;
  Support: IType<Scoped<TObject>>;
  ObjSupport: IType<TObject>;
begin
  Support := Reference.GetScopedType<TObject>;
  ObjSupport := TType<TObject>.Default;

  { Test null stuff }
  Check(Support.Compare(X, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(X/Y) to be stable!');

  Check(Support.GetString(X) = ObjSupport.GetString(nil), 'Expected Support.GetString(X) = ObjSupport.GetString(nil)');
  Check(Support.GetString(Y) = ObjSupport.GetString(nil), 'Expected Support.GetString(Y) = ObjSupport.GetString(nil)');

  X := TObject.Create();
  Y := TObject.Create();

  { Test stuff }
  Check(Support.Compare(X, X) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(X, Y) = ObjSupport.Compare(X, Y), 'Expected Support.Compare(X, Y) = ObjSupport.Compare(X, Y) to be true!');
  Check(Support.Compare(Y, X) = ObjSupport.Compare(Y, X), 'Expected Support.Compare(Y, X) = ObjSupport.Compare(Y, X) to be true!');

  Check(Support.AreEqual(X, X), 'Expected Support.AreEqual(X, X) to be true!');
  Check(Support.AreEqual(Y, Y), 'Expected Support.AreEqual(Y, Y) to be true!');
  Check(not Support.AreEqual(X, Y), 'Expected Support.AreEqual(X, Y) to be false!');

  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X) to be stable!');
  Check(Support.GenerateHashCode(Y) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(Y) to be stable!');
  Check(Support.GenerateHashCode(Y) <> Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X/Y) to be different!');

  Check(Support.GetString(X) = ObjSupport.GetString(X), 'Expected Support.GetString(X) = ObjSupport.GetString(X)');
  Check(Support.GetString(Y) = ObjSupport.GetString(Y), 'Expected Support.GetString(Y) = ObjSupport.GetString(Y)');

  Check(Support.Name = 'Scoped<System.TObject>', 'Type Name = "Scoped<System.TObject>"');
  Check(Support.Size = SizeOf(Scoped<TObject>), 'Type Size = SizeOf(Scoped<TObject>)');
  Check(Support.TypeInfo = TypeInfo(Scoped<TObject>), 'Type information provider failed!');
  Check(Support.Family = tfRecord, 'Type Family = tfRecord');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(TType<Scoped<TObject>>.Default.GetString(X) = Support.GetString(X), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      Support := Reference.GetScopedType<TObject>(nil);
    end,
    'ENilArgumentException not thrown in ctor(nil)'
  );
end;

procedure TTestReferences.TestType_Shared;
var
  X, Y: Shared<TObject>;
  Support: IType<Shared<TObject>>;
  ObjSupport: IType<TObject>;
begin
  Support := Reference.GetSharedType<TObject>;
  ObjSupport := TType<TObject>.Default;

  { Test null stuff }
  Check(Support.Compare(X, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(X/Y) to be stable!');

  Check(Support.GetString(X) = ObjSupport.GetString(nil), 'Expected Support.GetString(X) = ObjSupport.GetString(nil)');
  Check(Support.GetString(Y) = ObjSupport.GetString(nil), 'Expected Support.GetString(Y) = ObjSupport.GetString(nil)');

  X := TObject.Create();
  Y := TObject.Create();

  { Test stuff }
  Check(Support.Compare(X, X) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(X, Y) = ObjSupport.Compare(X, Y), 'Expected Support.Compare(X, Y) = ObjSupport.Compare(X, Y) to be true!');
  Check(Support.Compare(Y, X) = ObjSupport.Compare(Y, X), 'Expected Support.Compare(Y, X) = ObjSupport.Compare(Y, X) to be true!');

  Check(Support.AreEqual(X, X), 'Expected Support.AreEqual(X, X) to be true!');
  Check(Support.AreEqual(Y, Y), 'Expected Support.AreEqual(Y, Y) to be true!');
  Check(not Support.AreEqual(X, Y), 'Expected Support.AreEqual(X, Y) to be false!');

  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X) to be stable!');
  Check(Support.GenerateHashCode(Y) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(Y) to be stable!');
  Check(Support.GenerateHashCode(Y) <> Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X/Y) to be different!');

  Check(Support.GetString(X) = ObjSupport.GetString(X), 'Expected Support.GetString(X) = ObjSupport.GetString(X)');
  Check(Support.GetString(Y) = ObjSupport.GetString(Y), 'Expected Support.GetString(Y) = ObjSupport.GetString(Y)');

  Check(Support.Name = 'Shared<System.TObject>', 'Type Name = "Shared<System.TObject>"');
  Check(Support.Size = SizeOf(Shared<TObject>), 'Type Size = SizeOf(Shared<TObject>)');
  Check(Support.TypeInfo = TypeInfo(Shared<TObject>), 'Type information provider failed!');
  Check(Support.Family = tfRecord, 'Type Family = tfRecord');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(TType<Shared<TObject>>.Default.GetString(X) = Support.GetString(X), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      Support := Reference.GetSharedType<TObject>(nil);
    end,
    'ENilArgumentException not thrown in ctor(nil)'
  );
end;

procedure TTestReferences.TestType_Weak;
var
  zX, zY: Shared<TObject>;
  X, Y: Weak<TObject>;
  Support: IType<Weak<TObject>>;
  ObjSupport: IType<TObject>;
begin
  Support := Reference.GetWeakType<TObject>;
  ObjSupport := TType<TObject>.Default;

  { Test null stuff }
  Check(Support.Compare(X, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(X/Y) to be stable!');

  Check(Support.GetString(X) = ObjSupport.GetString(nil), 'Expected Support.GetString(X) = ObjSupport.GetString(nil)');
  Check(Support.GetString(Y) = ObjSupport.GetString(nil), 'Expected Support.GetString(Y) = ObjSupport.GetString(nil)');

  zX := Reference.Shared(TObject.Create()); X := zX;
  zY := Reference.Shared(TObject.Create()); Y := zY;

  { Test stuff }
  Check(Support.Compare(X, X) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(X, Y) = ObjSupport.Compare(Shared<TObject>(X), Shared<TObject>(Y)), 'Expected Support.Compare(X, Y) = ObjSupport.Compare(X, Y) to be true!');
  Check(Support.Compare(Y, X) = ObjSupport.Compare(Shared<TObject>(Y), Shared<TObject>(X)), 'Expected Support.Compare(Y, X) = ObjSupport.Compare(Y, X) to be true!');

  Check(Support.AreEqual(X, X), 'Expected Support.AreEqual(X, X) to be true!');
  Check(Support.AreEqual(Y, Y), 'Expected Support.AreEqual(Y, Y) to be true!');
  Check(not Support.AreEqual(X, Y), 'Expected Support.AreEqual(X, Y) to be false!');

  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X) to be stable!');
  Check(Support.GenerateHashCode(Y) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(Y) to be stable!');
  Check(Support.GenerateHashCode(Y) <> Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X/Y) to be different!');

  Check(Support.GetString(X) = ObjSupport.GetString(Shared<TObject>(X)), 'Expected Support.GetString(X) = ObjSupport.GetString(X)');
  Check(Support.GetString(Y) = ObjSupport.GetString(Shared<TObject>(Y)), 'Expected Support.GetString(Y) = ObjSupport.GetString(Y)');

  Check(Support.Name = 'Weak<System.TObject>', 'Type Name = "Weak<System.TObject>"');
  Check(Support.Size = SizeOf(Weak<TObject>), 'Type Size = SizeOf(Weak<TObject>)');
  Check(Support.TypeInfo = TypeInfo(Weak<TObject>), 'Type information provider failed!');
  Check(Support.Family = tfRecord, 'Type Family = tfRecord');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(TType<Weak<TObject>>.Default.GetString(X) = Support.GetString(X), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      Support := Reference.GetWeakType<TObject>(nil);
    end,
    'ENilArgumentException not thrown in ctor(nil)'
  );
end;

initialization
  TestFramework.RegisterTest(TTestReferences.Suite);

end.
