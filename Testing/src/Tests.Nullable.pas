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
unit Tests.Nullable;
interface

uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Math.BigCardinal,
     DeHL.Nullable;

type
  TTestNullable = class(TDeHLTestCase)
    procedure TestCreate();
    procedure TestIsNull();
    procedure TestMakeNull();
    procedure TestValue();
    procedure TestValueOrDefault();
    procedure TestImplicits();
    procedure TestExceptions();
    procedure TestType();
  end;

implementation


{ TTestNullable }

procedure TTestNullable.TestCreate;
var
  X: Nullable<Integer>;
begin
  Check(X.IsNull, 'X should be NULL by default!');

  X := Nullable<Integer>.Create(10);
  Check(not X.IsNull, 'X should not be NULL after creation!');
  Check(X.Value = 10, 'X should be equal to 10');
end;

procedure TTestNullable.TestExceptions;
var
  X: Nullable<Double>;
  I: Double;
begin
  CheckException(ENullValueException,
    procedure()
    begin
      X.Value;
    end,
    'ENullValueException not thrown in X.Value (default)'
  );

  CheckException(ENullValueException,
    procedure()
    begin
      I := X;
    end,
    'ENullValueException not thrown in I := X (default)'
  );

  X := 1.1;
  X.MakeNull();

  CheckException(ENullValueException,
    procedure()
    begin
      X.Value;
    end,
    'ENullValueException not thrown in X.Value (MakeNull)'
  );

  CheckException(ENullValueException,
    procedure()
    begin
      I := X;
    end,
    'ENullValueException not thrown in I := X (MakeNull)'
  );
end;

procedure TTestNullable.TestImplicits;
var
  X: Nullable<Integer>;
  I: Integer;
begin
  X := 100;
  Check(not X.IsNull, 'X should not be NULL after implicit!');
  Check(X.Value = 100, 'X should be equal to 100');

  I := X;
  Check(not X.IsNull, 'X should not be NULL after implicit assignment!');
  Check(I = 100, 'I should be equal to 100');

  X := X;
  Check(not X.IsNull, 'X should not be NULL after implicit X = X assignment!');
  Check(X.Value = 100, 'X should be equal to 100');
end;

procedure TTestNullable.TestIsNull;
var
  X, Y: Nullable<Integer>;
begin
  Check(X.IsNull, 'X should be NULL by default!');

  Y := X;
  Check(Y.IsNull, 'Y should be NULL after assignment from X!');

  X.MakeNull();
  Check(X.IsNull, 'X should be NULL after MakeNull by default!');

  X := 10;
  Check(not X.IsNull, 'X should not be NULL after assignment');

  X.MakeNull();
  Check(X.IsNull, 'X should be NULL after MakeNull');
end;

procedure TTestNullable.TestMakeNull;
var
  X: Nullable<String>;
begin
  Check(X.IsNull, 'X should be NULL by default!');
  X := 'Hello';

  Check(not X.IsNull, 'X should not be NULL after assignment!');

  X.MakeNull();
  Check(X.IsNull, 'X should be NULL after MakeNull!');
end;

procedure TTestNullable.TestType;
var
  Support: IType<Nullable<BigCardinal>>;
  X, Y: Nullable<BigCardinal>;
begin
  { TEST WITH A MANAGED TYPE }
  Support := TNullableType<BigCardinal>.Create();

  { Test null stuff }
  Check(Support.Compare(X, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(X/Y) to be stable!');
  Check(Support.GetString(X) = '0', 'Expected Support.GetString(X) = "0"');
  Check(Support.GetString(Y) = '0', 'Expected Support.GetString(Y) = "0"');

  X := BigCardinal.Parse('39712903721983712893712893712893718927389217312321893712986487234623785');
  Y := BigCardinal.Parse('29712903721983712893712893712893718927389217312321893712986487234623785');

  { Test stuff }
  Check(Support.Compare(X, X) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, 'Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(X, Y) > 0, 'Expected Support.Compare(X, Y) > 0 to be true!');
  Check(Support.Compare(Y, X) < 0, 'Expected Support.Compare(Y, X) < 0 to be true!');

  Check(Support.AreEqual(X, X), 'Expected Support.AreEqual(X, X) to be true!');
  Check(Support.AreEqual(Y, Y), 'Expected Support.AreEqual(Y, Y) to be true!');
  Check(not Support.AreEqual(X, Y), 'Expected Support.AreEqual(X, Y) to be false!');

  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X) to be stable!');
  Check(Support.GenerateHashCode(Y) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(Y) to be stable!');
  Check(Support.GenerateHashCode(Y) <> Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X/Y) to be different!');

  Check(Support.GetString(X) = '39712903721983712893712893712893718927389217312321893712986487234623785', 'Expected Support.GetString(X) = "39712903721983712893712893712893718927389217312321893712986487234623785"');
  Check(Support.GetString(Y) = '29712903721983712893712893712893718927389217312321893712986487234623785', 'Expected Support.GetString(Y) = "29712903721983712893712893712893718927389217312321893712986487234623785"');

  Check(Support.Name = 'Nullable<DeHL.Math.BigCardinal.BigCardinal>', 'Type Name = "Nullable<DeHL.Math.BigCardinal.BigCardinal>"');
  Check(Support.Size = SizeOf(Nullable<BigCardinal>), 'Type Size = SizeOf(Nullable<BigCardinal>)');
  Check(Support.TypeInfo = TypeInfo(Nullable<BigCardinal>), 'Type information provider failed!');
  Check(Support.Family = tfUnknown, 'Type Family = tfUnknown');

  Check(Support.Management() = tmCompiler, 'Type support = tmCompiler');

  Check(TType<Nullable<BigCardinal>>.Default.GetString(X) = Support.GetString(X), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      Support := TNullableType<BigCardinal>.Create(nil);
    end,
    'ENilArgumentException not thrown in ctor(nil)'
  );
end;

procedure TTestNullable.TestValue;
var
  X: Nullable<String>;
begin
  X.Value := 'Hello!';

  Check(X.Value = 'Hello!', 'Value expected to be "Hello!"');
  Check(not X.IsNull, 'X should not be null');

  X.Value := X.Value + ' World!';
  Check(X.Value = 'Hello! World!', 'Invalid cummulative value');
end;

procedure TTestNullable.TestValueOrDefault;
var
  X: Nullable<String>;
begin
  X := 'Hello';
  Check(X.ValueOrDefault = 'Hello', 'Expected the normal value to be retrieved');

  X.MakeNull;
  Check(X.ValueOrDefault = '', 'Expected the default value to be retrieved');
end;

initialization
  TestFramework.RegisterTest(TTestNullable.Suite);

end.
