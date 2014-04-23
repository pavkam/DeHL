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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.KeyValuePair;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Tuples;

type
  TTestKeyValuePair = class(TDeHLTestCase)
    procedure TestIntIntPair();
    procedure TestStringIntPair();

    procedure TestType;
  end;

implementation

{ TTestKVPair }

procedure TTestKeyValuePair.TestIntIntPair;
var
  Pair1, Pair2: KVPair<Integer, Integer>;
begin
  { First Pair }
  Pair1 := KVPair<Integer, Integer>.Create(60, -60);

  Check(Pair1.Key = 60, '(Int, Int) Key is invalid!');
  Check(Pair1.Value = -60, '(Int, Int) Value is invalid!');

  { Second Pair }
  Pair2 := KVPair.Create(Integer(60), Integer(-60));

  Check(Pair2.Key = 60, '(Int, Int) Key is invalid! (Copy)');
  Check(Pair2.Value = -60, '(Int, Int) Value is invalid! (Copy)');
end;

procedure TTestKeyValuePair.TestStringIntPair;
var
  Pair1, Pair2: KVPair<String, Integer>;
begin
  { First Pair }
  Pair1 := KVPair<String, Integer>.Create('Test', -60);

  Check(Pair1.Key = 'Test', '(String, Int) Key is invalid!');
  Check(Pair1.Value = -60, '(String, Int) Value is invalid!');

  { Second Pair }
  Pair2 := KVPair.Create('Test', Integer(-60));

  Check(Pair2.Key = 'Test', '(String, Int) Key is invalid! (Copy)');
  Check(Pair2.Value = -60, '(String, Int) Value is invalid! (Copy)');
end;

procedure TTestKeyValuePair.TestType;
var
  X, Y: KVPair<Integer, Integer>;
  Support: IType<KVPair<Integer, Integer>>;
  ObjSupport: IType<KVPair<Integer, Integer>>;

  PPSupport: IType<KVPair<String, Integer>>;
  PCSupport: IType<KVPair<TObject, String>>;
begin
  Support := KVPair.GetType<Integer, Integer>(TType<Integer>.Default, TType<Integer>.Default);
  ObjSupport := TType<KVPair<Integer, Integer>>.Default;

  PPSupport := KVPair.GetType<String, Integer>(TType<String>.Default, TType<Integer>.Default);
  PCSupport := KVPair.GetType<TObject, String>(TClassType<TObject>.Create(true), TType<String>.Default);

  X := KVPair<Integer, Integer>.Create(1, 0);
  Y := KVPair<Integer, Integer>.Create(0, 2);

  { Test null stuff }
  Check(Support.Compare(X, X) = 0, '(null) Expected Support.Compare(X, X) = 0 to be true!');
  Check(Support.Compare(Y, Y) = 0, '(null) Expected Support.Compare(Y, Y) = 0 to be true!');
  Check(Support.Compare(X, Y) > 0, '(null) Expected Support.Compare(X, Y) > 0 to be true!');
  Check(Support.Compare(Y, X) < 0, '(null) Expected Support.Compare(Y, X) < 0 to be true!');

  Check(Support.GenerateHashCode(X) = Support.GenerateHashCode(X), 'Expected Support.GenerateHashCode(X/X) to be stable!');
  Check(Support.GenerateHashCode(Y) = Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(Y/Y) to be stable!');
  Check(Support.GenerateHashCode(X) <> Support.GenerateHashCode(Y), 'Expected Support.GenerateHashCode(X/Y) to be stable!');

  Check(Support.GetString(X) = '<1, 0>', 'Expected Support.GetString(X) = "<1, 0>"');
  Check(Support.GetString(Y) = '<0, 2>', 'Expected Support.GetString(Y) = "<0, 2>"');

  Check(Support.Name = 'KVPair<System.Integer,System.Integer>', 'Type Name = "KVPair<System.Integer,System.Integer>"');
  Check(Support.TypeInfo = TypeInfo(KVPair<Integer, Integer>), 'Type information provider failed!');

  Check(Support.Size = SizeOf(KVPair<Integer, Integer>), 'Type Size = SizeOf(KVPair<Integer, Integer>)');
  Check(Support.Family = tfRecord, 'Type Family = tfRecord');

  Check(Support.Management() = tmNone, 'Type support = tmNone');
  Check(PPSupport.Management() = tmCompiler, 'PP: Type support = tmCompiler');
  Check(PCSupport.Management() = tmManual, 'PC: Type support = tmManual');

  Check(ObjSupport.GetString(X) = Support.GetString(X), 'CCTOR registration failed!');

  CheckException(ENilArgumentException,
    procedure()
    begin
      Support := KVPair.GetType<Integer, Integer>(nil, TType<Integer>.Default);
    end,
    'ENilArgumentException not thrown in ctor(nil, ...)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Support := KVPair.GetType<Integer, Integer>(TType<Integer>.Default, nil);
    end,
    'ENilArgumentException not thrown in ctor(..., nil)'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      Support := KVPair.GetType<Integer, Integer>(nil, nil);
    end,
    'ENilArgumentException not thrown in ctor(nil, nil)'
  );
end;

initialization
  TestFramework.RegisterTest(TTestKeyValuePair.Suite);

end.
