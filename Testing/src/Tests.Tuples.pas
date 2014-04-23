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
unit Tests.Tuples;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Tuples;

type
  TTestTuple1 = class(TDeHLTestCase)
    procedure TestInt();
    procedure TestString();

    procedure TestType();
  end;

type
  TTestTuple2 = class(TDeHLTestCase)
    procedure TestIntInt();
    procedure TestStringInt();

    procedure TestType();
  end;

type
  TTestTuple3 = class(TDeHLTestCase)
    procedure TestIntIntInt();
    procedure TestStringIntString();

    procedure TestType();
  end;

type
  TTestTuple4 = class(TDeHLTestCase)
    procedure TestIntIntIntBool();
    procedure TestStringIntStringBool();

    procedure TestType();
  end;

type
  TTestTuple5 = class(TDeHLTestCase)
    procedure TestIntIntIntBoolSet();
    procedure TestStringIntStringBoolSet();

    procedure TestType();
  end;

type
  TTestTuple6 = class(TDeHLTestCase)
    procedure TestIntIntIntBoolSetByte();
    procedure TestStringIntStringBoolSetVar();

    procedure TestType();
  end;

type
  TTestTuple7 = class(TDeHLTestCase)
    procedure TestIntIntIntBoolSetByteInt();
    procedure TestStringIntStringBoolSetVarInt();

    procedure TestType();
  end;

type
  TTestSet = set of (option1, option2);

implementation


{ TTestTuple1 }

procedure TTestTuple1.TestInt;
var
  L1, L2: Tuple<Integer>;
begin
  { First Pair }
  L1 := Tuple<Integer>.Create(60);

  Check(L1.Value1 = 60, '(Int) 1 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1);

  Check(L2.Value1 = 60, '(Int) 1 is invalid! (Copy)');
end;

procedure TTestTuple1.TestString;
var
  L1, L2 : Tuple<String>;
begin
  { First Pair }
  L1 := Tuple<String>.Create('Test');

  Check(L1.Value1 = 'Test', '(String) 1 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1);

  Check(L2.Value1 = 'Test', '(String) 1 is invalid! (Copy)');
end;

procedure TTestTuple1.TestType;
var
  nX, nY: Tuple<Integer>;

  LNone: IType<Tuple<Integer>>;
  LCompiler: IType<Tuple<String>>;
  LManual, LObjNone: IType<Tuple<TObject>>;
begin
  { Initialize stuff }
  LNone := TType<Tuple<Integer>>.Default;
  LCompiler := TType<Tuple<String>>.Default;
  LManual := Tuple.GetType<TObject>(TClassType<TObject>.Create(true));
  LObjNone := TType<Tuple<TObject>>.Default;

  nX := Tuple<Integer>.Create(1);
  nY := Tuple<Integer>.Create(0);

  { Test null stuff }
  Check(LNone.Compare(nX, nX) = 0, '(null) Expected LNone.Compare(X, X) = 0 to be true!');
  Check(LNone.Compare(nY, nY) = 0, '(null) Expected LNone.Compare(Y, Y) = 0 to be true!');
  Check(LNone.Compare(nX, nY) > 0, '(null) Expected LNone.Compare(X, Y) > 0 to be true!');
  Check(LNone.Compare(nY, nX) < 0, '(null) Expected LNone.Compare(Y, X) < 0 to be true!');

  Check(LNone.GenerateHashCode(nX) = LNone.GenerateHashCode(nX), 'Expected LNone.GenerateHashCode(X/X) to be stable!');
  Check(LNone.GenerateHashCode(nY) = LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(Y/Y) to be stable!');
  Check(LNone.GenerateHashCode(nX) <> LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(X/Y) to be stable!');

  Check(LNone.GetString(nX) = '<1>', 'Expected LNone.GetString(X) = "<1>"');
  Check(LNone.GetString(nY) = '<0>', 'Expected LNone.GetString(Y) = "<0>"');

  Check(LNone.Name = 'Tuple<System.Integer>', 'Type Name = "Tuple<System.Integer>"');
  Check(LNone.TypeInfo = TypeInfo(Tuple<Integer>), 'Type information provider failed!');
  Check(LNone.Size = SizeOf(Tuple<Integer>), 'Type Size = SizeOf(Tuple<Integer>)');
  Check(LNone.Family = tfRecord, 'Type Family = tfRecord');
  Check(LNone.Management = tmNone, 'Type support = tmNone');

  Check(LCompiler.Management = tmCompiler, 'LCompiler: Type support = tmCompiler');
  Check(LManual.Management = tmManual, 'LManual: Type support = tmManual');
  Check(LObjNone.Management = tmNone, 'LObjNone: Type support = tmNone');

  Check(LObjNone.GetString(Tuple.Create<TObject>(Self)) = LManual.GetString(Tuple.Create<TObject>(Self)), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      LManual := Tuple.GetType<TObject>(nil);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );
end;

{ TTestTuple2 }

procedure TTestTuple2.TestIntInt;
var
  L1, L2: Tuple<Integer, Integer>;
begin
  { First Pair }
  L1 := Tuple<Integer, Integer>.Create(60, -60);

  Check(L1.Value1 = 60, '(Int, Int) 1 is invalid!');
  Check(L1.Value2 = -60, '(Int, Int) 2 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2);

  Check(L2.Value1 = 60, '(Int, Int) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(Int, Int) 2 is invalid! (Copy)');
end;

procedure TTestTuple2.TestStringInt;
var
  L1, L2 : Tuple<String, Integer>;
begin
  { First Pair }
  L1 := Tuple<String, Integer>.Create('Test', -60);

  Check(L1.Value1 = 'Test', '(String, Int) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int) 2 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2);

  Check(L2.Value1 = 'Test', '(String, Int) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int) 2 is invalid! (Copy)');
end;

procedure TTestTuple2.TestType;
var
  nX, nY: Tuple<Integer, Integer>;

  LNone: IType<Tuple<Integer, Integer>>;
  LCompiler: IType<Tuple<String, Integer>>;
  LManual, LObjNone: IType<Tuple<TObject, Integer>>;
begin
  { Initialize stuff }
  LNone := TType<Tuple<Integer, Integer>>.Default;
  LCompiler := TType<Tuple<String, Integer>>.Default;
  LManual := Tuple.GetType<TObject, Integer>(TClassType<TObject>.Create(true), TType<Integer>.Default);
  LObjNone := TType<Tuple<TObject, Integer>>.Default;

  nX := Tuple<Integer, Integer>.Create(1, 0);
  nY := Tuple<Integer, Integer>.Create(0, 2);

  { Test null stuff }
  Check(LNone.Compare(nX, nX) = 0, '(null) Expected LNone.Compare(X, X) = 0 to be true!');
  Check(LNone.Compare(nY, nY) = 0, '(null) Expected LNone.Compare(Y, Y) = 0 to be true!');
  Check(LNone.Compare(nX, nY) > 0, '(null) Expected LNone.Compare(X, Y) > 0 to be true!');
  Check(LNone.Compare(nY, nX) < 0, '(null) Expected LNone.Compare(Y, X) < 0 to be true!');

  Check(LNone.GenerateHashCode(nX) = LNone.GenerateHashCode(nX), 'Expected LNone.GenerateHashCode(X/X) to be stable!');
  Check(LNone.GenerateHashCode(nY) = LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(Y/Y) to be stable!');
  Check(LNone.GenerateHashCode(nX) <> LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(X/Y) to be stable!');

  Check(LNone.GetString(nX) = '<1, 0>', 'Expected LNone.GetString(X) = "<1, 0>"');
  Check(LNone.GetString(nY) = '<0, 2>', 'Expected LNone.GetString(Y) = "<0, 2>"');

  Check(LNone.Name = 'Tuple<System.Integer,System.Integer>', 'Type Name = "Tuple<System.Integer,System.Integer>"');
  Check(LNone.TypeInfo = TypeInfo(Tuple<Integer, Integer>), 'Type information provider failed!');
  Check(LNone.Size = SizeOf(Tuple<Integer, Integer>), 'Type Size = SizeOf(Tuple<Integer, Integer>)');
  Check(LNone.Family = tfRecord, 'Type Family = tfRecord');
  Check(LNone.Management = tmNone, 'Type support = tmNone');

  Check(LCompiler.Management = tmCompiler, 'LCompiler: Type support = tmCompiler');
  Check(LManual.Management = tmManual, 'LManual: Type support = tmManual');
  Check(LObjNone.Management = tmNone, 'LObjNone: Type support = tmNone');

  Check(LObjNone.GetString(Tuple.Create<TObject, Integer>(Self, 100)) =
        LManual.GetString(Tuple.Create<TObject, Integer>(Self, 100)), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer>(nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer>(TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );
end;

{ TTestTuple3 }

procedure TTestTuple3.TestIntIntInt;
var
  L1, L2: Tuple<Integer, Integer, Integer>;
begin
  { First Pair }
  L1 := Tuple<Integer, Integer, Integer>.Create(60, -60, 99);

  Check(L1.Value1 = 60, '(Int, Int, Int) 1 is invalid!');
  Check(L1.Value2 = -60, '(Int, Int, Int) 2 is invalid!');
  Check(L1.Value3 = 99, '(Int, Int, Int) 3 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3);

  Check(L2.Value1 = 60, '(Int, Int, Int) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(Int, Int, Int) 2 is invalid! (Copy)');
  Check(L2.Value3 = 99, '(Int, Int, Int) 3 is invalid! (Copy)');
end;

procedure TTestTuple3.TestStringIntString;
var
  L1, L2: Tuple<String, Integer, String>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String>.Create('Test', -60, 'BLAH');

  Check(L1.Value1 = 'Test', '(String, Int, String) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String) 3 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3);

  Check(L2.Value1 = 'Test', '(String, Int, String) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String) 3 is invalid! (Copy)');
end;

procedure TTestTuple3.TestType;
var
  _: IType<Integer>;
  nX, nY: Tuple<Integer, Integer, Integer>;

  LNone: IType<Tuple<Integer, Integer, Integer>>;
  LCompiler: IType<Tuple<String, Integer, Integer>>;
  LManual, LObjNone: IType<Tuple<TObject, Integer, Integer>>;
begin
  { Initialize stuff }
  _ := TType<Integer>.Default;
  LNone := TType<Tuple<Integer, Integer, Integer>>.Default;
  LCompiler := TType<Tuple<String, Integer, Integer>>.Default;
  LManual := Tuple.GetType<TObject, Integer, Integer>(TClassType<TObject>.Create(true), _, _);
  LObjNone := TType<Tuple<TObject, Integer, Integer>>.Default;

  nX := Tuple<Integer, Integer, Integer>.Create(1, 0, -1);
  nY := Tuple<Integer, Integer, Integer>.Create(0, 2, 4);

  { Test null stuff }
  Check(LNone.Compare(nX, nX) = 0, '(null) Expected LNone.Compare(X, X) = 0 to be true!');
  Check(LNone.Compare(nY, nY) = 0, '(null) Expected LNone.Compare(Y, Y) = 0 to be true!');
  Check(LNone.Compare(nX, nY) > 0, '(null) Expected LNone.Compare(X, Y) > 0 to be true!');
  Check(LNone.Compare(nY, nX) < 0, '(null) Expected LNone.Compare(Y, X) < 0 to be true!');

  Check(LNone.GenerateHashCode(nX) = LNone.GenerateHashCode(nX), 'Expected LNone.GenerateHashCode(X/X) to be stable!');
  Check(LNone.GenerateHashCode(nY) = LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(Y/Y) to be stable!');
  Check(LNone.GenerateHashCode(nX) <> LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(X/Y) to be stable!');

  Check(LNone.GetString(nX) = '<1, 0, -1>', 'Expected LNone.GetString(X) = "<1, 0>"');
  Check(LNone.GetString(nY) = '<0, 2, 4>', 'Expected LNone.GetString(Y) = "<0, 2>"');

  Check(LNone.Name = 'Tuple<System.Integer,System.Integer,System.Integer>',
    'Type Name = "Tuple<System.Integer,System.Integer,System.Integer>"');
  Check(LNone.TypeInfo = TypeInfo(Tuple<Integer, Integer, Integer>), 'Type information provider failed!');
  Check(LNone.Size = SizeOf(Tuple<Integer, Integer, Integer>), 'Type Size = SizeOf(Tuple<Integer, Integer>)');
  Check(LNone.Family = tfRecord, 'Type Family = tfRecord');
  Check(LNone.Management = tmNone, 'Type support = tmNone');

  Check(LCompiler.Management = tmCompiler, 'LCompiler: Type support = tmCompiler');
  Check(LManual.Management = tmManual, 'LManual: Type support = tmManual');
  Check(LObjNone.Management = tmNone, 'LObjNone: Type support = tmNone');

  Check(LObjNone.GetString(Tuple.Create<TObject, Integer, Integer>(Self, 100, 50)) =
        LManual.GetString(Tuple.Create<TObject, Integer, Integer>(Self, 100, 50)), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer>(nil, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer>(_, nil, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer>(_, _, nil);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );
end;

{ TTestTuple4 }

procedure TTestTuple4.TestIntIntIntBool;
var
  L1, L2: Tuple<Integer, Integer, Integer, Boolean>;
begin
  { First Pair }
  L1 := Tuple<Integer, Integer, Integer, Boolean>.Create(60, -60, 99, true);

  Check(L1.Value1 = 60, '(Int, Int, Int, Bool) 1 is invalid!');
  Check(L1.Value2 = -60, '(Int, Int, Int, Bool) 2 is invalid!');
  Check(L1.Value3 = 99, '(Int, Int, Int, Bool) 3 is invalid!');
  Check(L1.Value4 = true, '(Int, Int, Int, Bool) 4 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4);

  Check(L2.Value1 = 60, '(Int, Int, Int, Bool) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(Int, Int, Int, Bool) 2 is invalid! (Copy)');
  Check(L2.Value3 = 99, '(Int, Int, Int, Bool) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(Int, Int, Int, Bool) 4 is invalid! (Copy)');
end;

procedure TTestTuple4.TestStringIntStringBool;
var
  L1, L2: Tuple<String, Integer, String, Boolean>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String, Boolean>.Create('Test', -60, 'BLAH', true);

  Check(L1.Value1 = 'Test', '(String, Int, String, Bool) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String, Bool) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String, Bool) 3 is invalid!');
  Check(L1.Value4 = true, '(String, Int, String, Bool) 4 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4);

  Check(L2.Value1 = 'Test', '(String, Int, String, Bool) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String, Bool) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String, Bool) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(String, Int, String, Bool) 4 is invalid! (Copy)');
end;

procedure TTestTuple4.TestType;
var
  _: IType<Integer>;
  nX, nY: Tuple<Integer, Integer, Integer, Integer>;

  LNone: IType<Tuple<Integer, Integer, Integer, Integer>>;
  LCompiler: IType<Tuple<String, Integer, Integer, Integer>>;
  LManual, LObjNone: IType<Tuple<TObject, Integer, Integer, Integer>>;
begin
  { Initialize stuff }
  _ := TType<Integer>.Default;
  LNone := TType<Tuple<Integer, Integer, Integer, Integer>>.Default;
  LCompiler := TType<Tuple<String, Integer, Integer, Integer>>.Default;
  LManual := Tuple.GetType<TObject, Integer, Integer, Integer>(TClassType<TObject>.Create(true), _, _, _);
  LObjNone := TType<Tuple<TObject, Integer, Integer, Integer>>.Default;

  nX := Tuple<Integer, Integer, Integer, Integer>.Create(1, 0, -1, 8);
  nY := Tuple<Integer, Integer, Integer, Integer>.Create(0, 2, 4, 8);

  { Test null stuff }
  Check(LNone.Compare(nX, nX) = 0, '(null) Expected LNone.Compare(X, X) = 0 to be true!');
  Check(LNone.Compare(nY, nY) = 0, '(null) Expected LNone.Compare(Y, Y) = 0 to be true!');
  Check(LNone.Compare(nX, nY) > 0, '(null) Expected LNone.Compare(X, Y) > 0 to be true!');
  Check(LNone.Compare(nY, nX) < 0, '(null) Expected LNone.Compare(Y, X) < 0 to be true!');

  Check(LNone.GenerateHashCode(nX) = LNone.GenerateHashCode(nX), 'Expected LNone.GenerateHashCode(X/X) to be stable!');
  Check(LNone.GenerateHashCode(nY) = LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(Y/Y) to be stable!');
  Check(LNone.GenerateHashCode(nX) <> LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(X/Y) to be stable!');

  Check(LNone.GetString(nX) = '<1, 0, -1, 8>', 'Expected LNone.GetString(X) = "<1, 0>"');
  Check(LNone.GetString(nY) = '<0, 2, 4, 8>', 'Expected LNone.GetString(Y) = "<0, 2>"');

  Check(LNone.Name = 'Tuple<System.Integer,System.Integer,System.Integer,System.Integer>',
    'Type Name = "Tuple<System.Integer,System.Integer,System.Integer,System.Integer>"');
  Check(LNone.TypeInfo = TypeInfo(Tuple<Integer, Integer, Integer, Integer>), 'Type information provider failed!');
  Check(LNone.Size = SizeOf(Tuple<Integer, Integer, Integer, Integer>), 'Type Size = SizeOf(Tuple<Integer, Integer, Integer, Integer>)');
  Check(LNone.Family = tfRecord, 'Type Family = tfRecord');
  Check(LNone.Management = tmNone, 'Type support = tmNone');

  Check(LCompiler.Management = tmCompiler, 'LCompiler: Type support = tmCompiler');
  Check(LManual.Management = tmManual, 'LManual: Type support = tmManual');
  Check(LObjNone.Management = tmNone, 'LObjNone: Type support = tmNone');

  Check(LObjNone.GetString(Tuple.Create<TObject, Integer, Integer, Integer>(Self, 100, 50, 0)) =
        LManual.GetString(Tuple.Create<TObject, Integer, Integer, Integer>(Self, 100, 50, 0)), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer>(nil, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer>(_, nil, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer>(_, _, nil, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer>(_, _, _, nil);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );
end;

{ TTestTuple5 }

procedure TTestTuple5.TestIntIntIntBoolSet;
var
  L1, L2: Tuple<String, Integer, String, Boolean, TTestSet>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String, Boolean, TTestSet>.Create('Test', -60, 'BLAH', true, [option2]);

  Check(L1.Value1 = 'Test', '(String, Int, String, Bool) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String, Bool) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String, Bool) 3 is invalid!');
  Check(L1.Value4 = true, '(String, Int, String, Bool) 4 is invalid!');
  Check(L1.Value5 = [option2], '(String, Int, String, Bool, Set) 5 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4, L1.Value5);

  Check(L2.Value1 = 'Test', '(String, Int, String, Bool) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String, Bool) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String, Bool) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(String, Int, String, Bool) 4 is invalid! (Copy)');
  Check(L2.Value5 = [option2], '(String, Int, String, Bool, Set) 5 is invalid! (Copy)');
end;

procedure TTestTuple5.TestStringIntStringBoolSet;
var
  L1, L2: Tuple<String, Integer, String, Boolean, TTestSet>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String, Boolean, TTestSet>.Create('Test', -60, 'BLAH', true, [option2]);

  Check(L1.Value1 = 'Test', '(String, Int, String, Bool Set) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String, Bool Set) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String, Bool Set) 3 is invalid!');
  Check(L1.Value4 = true, '(String, Int, String, Bool Set) 4 is invalid!');
  Check(L1.Value5 = [option2], '(String, Int, String, Bool Set) 5 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4, L1.Value5);

  Check(L2.Value1 = 'Test', '(String, Int, String, Bool Set) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String, Bool Set) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String, Bool Set) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(String, Int, String, Bool Set) 4 is invalid! (Copy)');
  Check(L2.Value5 = [option2], '(String, Int, String, Bool Set) 5 is invalid! (Copy)');
end;

procedure TTestTuple5.TestType;
var
  _: IType<Integer>;
  nX, nY: Tuple<Integer, Integer, Integer, Integer, Integer>;

  LNone: IType<Tuple<Integer, Integer, Integer, Integer, Integer>>;
  LCompiler: IType<Tuple<String, Integer, Integer, Integer, Integer>>;
  LManual, LObjNone: IType<Tuple<TObject, Integer, Integer, Integer, Integer>>;
begin
  { Initialize stuff }
  _ := TType<Integer>.Default;
  LNone := TType<Tuple<Integer, Integer, Integer, Integer, Integer>>.Default;
  LCompiler := TType<Tuple<String, Integer, Integer, Integer, Integer>>.Default;
  LManual := Tuple.GetType<TObject, Integer, Integer, Integer, Integer>(TClassType<TObject>.Create(true), _, _, _, _);
  LObjNone := TType<Tuple<TObject, Integer, Integer, Integer, Integer>>.Default;

  nX := Tuple<Integer, Integer, Integer, Integer, Integer>.Create(1, 0, -1, 8, 0);
  nY := Tuple<Integer, Integer, Integer, Integer, Integer>.Create(0, 2, 4, 8, 1);

  { Test null stuff }
  Check(LNone.Compare(nX, nX) = 0, '(null) Expected LNone.Compare(X, X) = 0 to be true!');
  Check(LNone.Compare(nY, nY) = 0, '(null) Expected LNone.Compare(Y, Y) = 0 to be true!');
  Check(LNone.Compare(nX, nY) > 0, '(null) Expected LNone.Compare(X, Y) > 0 to be true!');
  Check(LNone.Compare(nY, nX) < 0, '(null) Expected LNone.Compare(Y, X) < 0 to be true!');

  Check(LNone.GenerateHashCode(nX) = LNone.GenerateHashCode(nX), 'Expected LNone.GenerateHashCode(X/X) to be stable!');
  Check(LNone.GenerateHashCode(nY) = LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(Y/Y) to be stable!');
  Check(LNone.GenerateHashCode(nX) <> LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(X/Y) to be stable!');

  Check(LNone.GetString(nX) = '<1, 0, -1, 8, 0>', 'Expected LNone.GetString(X) = "<1, 0>"');
  Check(LNone.GetString(nY) = '<0, 2, 4, 8, 1>', 'Expected LNone.GetString(Y) = "<0, 2>"');

  Check(LNone.Name = 'Tuple<System.Integer,System.Integer,System.Integer,System.Integer,System.Integer>',
    'Type Name = "Tuple<System.Integer,System.Integer,System.Integer,System.Integer,System.Integer>"');
  Check(LNone.TypeInfo = TypeInfo(Tuple<Integer, Integer, Integer, Integer, Integer>), 'Type information provider failed!');
  Check(LNone.Size = SizeOf(Tuple<Integer, Integer, Integer, Integer, Integer>), 'Type Size = SizeOf(Tuple<Integer, Integer, Integer, Integer, Integer>)');
  Check(LNone.Family = tfRecord, 'Type Family = tfRecord');
  Check(LNone.Management = tmNone, 'Type support = tmNone');

  Check(LCompiler.Management = tmCompiler, 'LCompiler: Type support = tmCompiler');
  Check(LManual.Management = tmManual, 'LManual: Type support = tmManual');
  Check(LObjNone.Management = tmNone, 'LObjNone: Type support = tmNone');

  Check(LObjNone.GetString(Tuple.Create<TObject, Integer, Integer, Integer, Integer>(Self, 100, 50, 0, 7)) =
        LManual.GetString(Tuple.Create<TObject, Integer, Integer, Integer, Integer>(Self, 100, 50, 0, 7)), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer>(nil, _, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer>(_, nil, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer>(_, _, nil, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer>(_, _, _, nil, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer>(_, _, _, _, nil);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );
end;

{ TTestTuple6 }

procedure TTestTuple6.TestIntIntIntBoolSetByte;
var
  L1, L2: Tuple<String, Integer, String, Boolean, TTestSet, Byte>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String, Boolean, TTestSet, Byte>.Create('Test', -60, 'BLAH', true, [option2], 155);

  Check(L1.Value1 = 'Test', '(String, Int, String, Bool, Byte) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String, Bool, Byte) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String, Bool, Byte) 3 is invalid!');
  Check(L1.Value4 = true, '(String, Int, String, Bool, Byte) 4 is invalid!');
  Check(L1.Value5 = [option2], '(String, Int, String, Bool, Set, Byte) 5 is invalid!');
  Check(L1.Value6 = 155, '(String, Int, String, Bool, Set, Byte) 6 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4, L1.Value5, L1.Value6);

  Check(L2.Value1 = 'Test', '(String, Int, String, Bool, Byte) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String, Bool, Byte) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String, Bool, Byte) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(String, Int, String, Bool, Byte) 4 is invalid! (Copy)');
  Check(L2.Value5 = [option2], '(String, Int, String, Bool, Set, Byte) 5 is invalid! (Copy)');
  Check(L2.Value6 = 155, '(String, Int, String, Bool, Set, Byte) 6 is invalid! (Copy)');
end;

procedure TTestTuple6.TestStringIntStringBoolSetVar;
var
  L1, L2: Tuple<String, Integer, String, Boolean, TTestSet, Variant>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String, Boolean, TTestSet, Variant>.Create('Test', -60, 'BLAH', true, [option2], '0');

  Check(L1.Value1 = 'Test', '(String, Int, String, Bool, Set, Var) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String, Bool, Set, Var) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String, Bool, Set, Var) 3 is invalid!');
  Check(L1.Value4 = true, '(String, Int, String, Bool, Set, Var) 4 is invalid!');
  Check(L1.Value5 = [option2], '(String, Int, String, Bool, Set, Var) 5 is invalid!');
  Check(L1.Value6 = 0, '(String, Int, String, Bool, Set, Var) 6 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4, L1.Value5, L1.Value6);

  Check(L2.Value1 = 'Test', '(String, Int, String, Bool, Set, Var) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String, Bool, Set, Var) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String, Bool, Set, Var) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(String, Int, String, Bool, Set, Var) 4 is invalid! (Copy)');
  Check(L2.Value5 = [option2], '(String, Int, String, Bool, Set, Var) 5 is invalid! (Copy)');
  Check(L1.Value6 = 0, '(String, Int, String, Bool, Set, Var) 6 is invalid!');
end;

procedure TTestTuple6.TestType;
var
  _: IType<Integer>;
  nX, nY: Tuple<Integer, Integer, Integer, Integer, Integer, Integer>;

  LNone: IType<Tuple<Integer, Integer, Integer, Integer, Integer, Integer>>;
  LCompiler: IType<Tuple<String, Integer, Integer, Integer, Integer, Integer>>;
  LManual, LObjNone: IType<Tuple<TObject, Integer, Integer, Integer, Integer, Integer>>;
begin
  { Initialize stuff }
  _ := TType<Integer>.Default;
  LNone := TType<Tuple<Integer, Integer, Integer, Integer, Integer, Integer>>.Default;
  LCompiler := TType<Tuple<String, Integer, Integer, Integer, Integer, Integer>>.Default;
  LManual := Tuple.GetType<TObject, Integer, Integer, Integer, Integer, Integer>(TClassType<TObject>.Create(true), _, _, _, _, _);
  LObjNone := TType<Tuple<TObject, Integer, Integer, Integer, Integer, Integer>>.Default;

  nX := Tuple<Integer, Integer, Integer, Integer, Integer, Integer>.Create(1, 0, -1, 8, 0, 22222);
  nY := Tuple<Integer, Integer, Integer, Integer, Integer, Integer>.Create(0, 2, 4, 8, 1, 33333);

  { Test null stuff }
  Check(LNone.Compare(nX, nX) = 0, '(null) Expected LNone.Compare(X, X) = 0 to be true!');
  Check(LNone.Compare(nY, nY) = 0, '(null) Expected LNone.Compare(Y, Y) = 0 to be true!');
  Check(LNone.Compare(nX, nY) > 0, '(null) Expected LNone.Compare(X, Y) > 0 to be true!');
  Check(LNone.Compare(nY, nX) < 0, '(null) Expected LNone.Compare(Y, X) < 0 to be true!');

  Check(LNone.GenerateHashCode(nX) = LNone.GenerateHashCode(nX), 'Expected LNone.GenerateHashCode(X/X) to be stable!');
  Check(LNone.GenerateHashCode(nY) = LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(Y/Y) to be stable!');
  Check(LNone.GenerateHashCode(nX) <> LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(X/Y) to be stable!');

  Check(LNone.GetString(nX) = '<1, 0, -1, 8, 0, 22222>', 'Expected LNone.GetString(X) = "<1, 0>"');
  Check(LNone.GetString(nY) = '<0, 2, 4, 8, 1, 33333>', 'Expected LNone.GetString(Y) = "<0, 2>"');

  Check(LNone.Name = 'Tuple<System.Integer,System.Integer,System.Integer,System.Integer,System.Integer,System.Integer>',
    'Type Name = "Tuple<System.Integer,System.Integer,System.Integer,System.Integer,System.Integer,System.Integer>"');
  Check(LNone.TypeInfo = TypeInfo(Tuple<Integer, Integer, Integer, Integer, Integer, Integer>), 'Type information provider failed!');
  Check(LNone.Size = SizeOf(Tuple<Integer, Integer, Integer, Integer, Integer, Integer>), 'Type Size = SizeOf(Tuple<Integer, Integer, Integer, Integer, Integer, Integer>)');
  Check(LNone.Family = tfRecord, 'Type Family = tfRecord');
  Check(LNone.Management = tmNone, 'Type support = tmNone');

  Check(LCompiler.Management = tmCompiler, 'LCompiler: Type support = tmCompiler');
  Check(LManual.Management = tmManual, 'LManual: Type support = tmManual');
  Check(LObjNone.Management = tmNone, 'LObjNone: Type support = tmNone');

  Check(LObjNone.GetString(Tuple.Create<TObject, Integer, Integer, Integer, Integer, Integer>(Self, 100, 50, 0, 7, 22)) =
        LManual.GetString(Tuple.Create<TObject, Integer, Integer, Integer, Integer, Integer>(Self, 100, 50, 0, 7, 22)), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer>(nil, _, _, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer>(_, nil, _, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer>(_, _, nil, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer>(_, _, _, nil, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer>(_, _, _, _, nil, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer>(_, _, _, _, _, nil);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );
end;

{ TTestTuple7 }

procedure TTestTuple7.TestIntIntIntBoolSetByteInt;
var
  L1, L2: Tuple<String, Integer, String, Boolean, TTestSet, Byte, Integer>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String, Boolean, TTestSet, Byte, Integer>.Create('Test', -60, 'BLAH', true, [option2], 155, MaxInt);

  Check(L1.Value1 = 'Test', '(String, Int, String, Bool, Byte, Int) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String, Bool, Byte, Int) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String, Bool, Byte, Int) 3 is invalid!');
  Check(L1.Value4 = true, '(String, Int, String, Bool, Byte, Int) 4 is invalid!');
  Check(L1.Value5 = [option2], '(String, Int, String, Bool, Set, Byte, Int) 5 is invalid!');
  Check(L1.Value6 = 155, '(String, Int, String, Bool, Set, Byte, Int) 6 is invalid!');
  Check(L1.Value7 = MaxInt, '(String, Int, String, Bool, Set, Byte, Int) 7 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4, L1.Value5, L1.Value6, L1.Value7);

  Check(L2.Value1 = 'Test', '(String, Int, String, Bool, Byte, Int) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String, Bool, Byte, Int) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String, Bool, Byte, Int) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(String, Int, String, Bool, Byte, Int) 4 is invalid! (Copy)');
  Check(L2.Value5 = [option2], '(String, Int, String, Bool, Set, Byte, Int) 5 is invalid! (Copy)');
  Check(L2.Value6 = 155, '(String, Int, String, Bool, Set, Byte, Int) 6 is invalid! (Copy)');
  Check(L1.Value7 = MaxInt, '(String, Int, String, Bool, Set, Byte, Int) 7 is invalid!');
end;

procedure TTestTuple7.TestStringIntStringBoolSetVarInt;
var
  L1, L2: Tuple<String, Integer, String, Boolean, TTestSet, Variant, Integer>;
begin
  { First Pair }
  L1 := Tuple<String, Integer, String, Boolean, TTestSet, Variant, Integer>.Create('Test', -60, 'BLAH', true, [option2], '0', MaxInt);

  Check(L1.Value1 = 'Test', '(String, Int, String, Bool, Set, Var) 1 is invalid!');
  Check(L1.Value2 = -60, '(String, Int, String, Bool, Set, Var) 2 is invalid!');
  Check(L1.Value3 = 'BLAH', '(String, Int, String, Bool, Set, Var) 3 is invalid!');
  Check(L1.Value4 = true, '(String, Int, String, Bool, Set, Var) 4 is invalid!');
  Check(L1.Value5 = [option2], '(String, Int, String, Bool, Set, Var) 5 is invalid!');
  Check(L1.Value6 = 0, '(String, Int, String, Bool, Set, Var) 6 is invalid!');
  Check(L1.Value7 = MaxInt, '(String, Int, String, Bool, Set, Var, Int) 7 is invalid!');

  { Second Pair }
  L2 := Tuple.Create(L1.Value1, L1.Value2, L1.Value3, L1.Value4, L1.Value5, L1.Value6, L1.Value7);

  Check(L2.Value1 = 'Test', '(String, Int, String, Bool, Set, Var) 1 is invalid! (Copy)');
  Check(L2.Value2 = -60, '(String, Int, String, Bool, Set, Var) 2 is invalid! (Copy)');
  Check(L2.Value3 = 'BLAH', '(String, Int, String, Bool, Set, Var) 3 is invalid! (Copy)');
  Check(L2.Value4 = true, '(String, Int, String, Bool, Set, Var) 4 is invalid! (Copy)');
  Check(L2.Value5 = [option2], '(String, Int, String, Bool, Set, Var) 4 is invalid! (Copy)');
  Check(L1.Value6 = 0, '(String, Int, String, Bool, Set, Var) 4 is invalid!');
  Check(L1.Value7 = MaxInt, '(String, Int, String, Bool, Set, Var, Int) 7 is invalid!');
end;

procedure TTestTuple7.TestType;
var
  _: IType<Integer>;
  nX, nY: Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>;

  LNone: IType<Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>>;
  LCompiler: IType<Tuple<String, Integer, Integer, Integer, Integer, Integer, Integer>>;
  LManual, LObjNone: IType<Tuple<TObject, Integer, Integer, Integer, Integer, Integer, Integer>>;
begin
  { Initialize stuff }
  _ := TType<Integer>.Default;
  LNone := TType<Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>>.Default;
  LCompiler := TType<Tuple<String, Integer, Integer, Integer, Integer, Integer, Integer>>.Default;
  LManual := Tuple.GetType<TObject, Integer, Integer, Integer, Integer, Integer, Integer>(TClassType<TObject>.Create(true), _, _, _, _, _, _);
  LObjNone := TType<Tuple<TObject, Integer, Integer, Integer, Integer, Integer, Integer>>.Default;

  nX := Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>.Create(1, 0, -1, 8, 0, 22222, 1);
  nY := Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>.Create(0, 2, 4, 8, 1, 33333, 1);

  { Test null stuff }
  Check(LNone.Compare(nX, nX) = 0, '(null) Expected LNone.Compare(X, X) = 0 to be true!');
  Check(LNone.Compare(nY, nY) = 0, '(null) Expected LNone.Compare(Y, Y) = 0 to be true!');
  Check(LNone.Compare(nX, nY) > 0, '(null) Expected LNone.Compare(X, Y) > 0 to be true!');
  Check(LNone.Compare(nY, nX) < 0, '(null) Expected LNone.Compare(Y, X) < 0 to be true!');

  Check(LNone.GenerateHashCode(nX) = LNone.GenerateHashCode(nX), 'Expected LNone.GenerateHashCode(X/X) to be stable!');
  Check(LNone.GenerateHashCode(nY) = LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(Y/Y) to be stable!');
  Check(LNone.GenerateHashCode(nX) <> LNone.GenerateHashCode(nY), 'Expected LNone.GenerateHashCode(X/Y) to be stable!');

  Check(LNone.GetString(nX) = '<1, 0, -1, 8, 0, 22222, 1>', 'Expected LNone.GetString(X) = "<1, 0>"');
  Check(LNone.GetString(nY) = '<0, 2, 4, 8, 1, 33333, 1>', 'Expected LNone.GetString(Y) = "<0, 2>"');

  Check(LNone.Name = 'Tuple<System.Integer,System.Integer,System.Integer,System.Integer,System.Integer,System.Integer,System.Integer>',
    'Type Name = "Tuple<System.Integer,System.Integer,System.Integer,System.Integer,System.Integer,System.Integer,System.Integer>"');
  Check(LNone.TypeInfo = TypeInfo(Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>), 'Type information provider failed!');
  Check(LNone.Size = SizeOf(Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>), 'Type Size = SizeOf(Tuple<Integer, Integer, Integer, Integer, Integer, Integer, Integer>)');
  Check(LNone.Family = tfRecord, 'Type Family = tfRecord');
  Check(LNone.Management = tmNone, 'Type support = tmNone');

  Check(LCompiler.Management = tmCompiler, 'LCompiler: Type support = tmCompiler');
  Check(LManual.Management = tmManual, 'LManual: Type support = tmManual');
  Check(LObjNone.Management = tmNone, 'LObjNone: Type support = tmNone');

  Check(LObjNone.GetString(Tuple.Create<TObject, Integer, Integer, Integer, Integer, Integer, Integer>(Self, 100, 50, 0, 7, 22, 2)) =
        LManual.GetString(Tuple.Create<TObject, Integer, Integer, Integer, Integer, Integer, Integer>(Self, 100, 50, 0, 7, 22, 2)), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(nil, _, _, _, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(_, nil, _, _, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(_, _, nil, _, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(_, _, _, nil, _, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(_, _, _, _, nil, _, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(_, _, _, _, _, nil, _);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      LNone := Tuple.GetType<Integer, Integer, Integer, Integer, Integer, Integer, Integer>(_, _, _, _, _, _, nil);
    end,
    'ENilArgumentException not thrown in GetType(nil, ...)'
  );
end;

initialization
  TestFramework.RegisterTest(TTestTuple1.Suite);
  TestFramework.RegisterTest(TTestTuple2.Suite);
  TestFramework.RegisterTest(TTestTuple3.Suite);
  TestFramework.RegisterTest(TTestTuple4.Suite);
  TestFramework.RegisterTest(TTestTuple5.Suite);
  TestFramework.RegisterTest(TTestTuple6.Suite);
  TestFramework.RegisterTest(TTestTuple7.Suite);

end.
