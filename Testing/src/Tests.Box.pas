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

{$I ../Library/src/DeHL.Defines.inc}
unit Tests.Box;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Box;

type
  TTestBox = class(TDeHLTestCase)
  published
    procedure TestCreate;
    procedure TestHasBoxedValue;
    procedure TestTryPeek;
    procedure TestPeek;
    procedure TestTryUnbox;
    procedure TestUnbox;
    procedure TestUnboxAndFree;
    procedure TestCompareTo;
    procedure TestEquals;
    procedure TestGetHashCode;
    procedure TestToString;
    procedure TestClone;
    procedure TestType;

    procedure TestProperCleaning();
  end;


implementation

{ TTestBox }

procedure TTestBox.TestClone;
var
  LBox, LBoxCopy: TBox<Integer>;
  LIntf: IType<Integer>;
begin
  LIntf := TExType<Integer>.Create();
  LBox := TBox<Integer>.Create(LIntf, 100);

  LBoxCopy := LBox.Clone as TBox<Integer>;

  CheckEquals('>>100', LBoxCopy.ToString(), 'IType not copied to clone.');
  CheckEquals(LBox.HasBoxedValue, LBoxCopy.HasBoxedValue, 'Boxed flag not copied');
  CheckEquals(LBox.Peek, LBoxCopy.Peek, 'Boxed value not copied');

  LBoxCopy.Free;
  LBox.Unbox;

  LBoxCopy := LBox.Clone as TBox<Integer>;
  CheckEquals(LBox.HasBoxedValue, LBoxCopy.HasBoxedValue, 'Boxed flag not copied');

  LBox.Free;
  LBoxCopy.Free;
end;

procedure TTestBox.TestCompareTo;
var
  Box1, Box2, Box3: TBox<Integer>;
  BoxS: TBox<String>;
begin
  Box1 := TBox<Integer>.Create(100);
  Box2 := TBox<Integer>.Create(50);
  Box3 := TBox<Integer>.Create(1000);

  { ... }
  Check(Box1.CompareTo(Box1) = 0, 'Box1 == Box1');
  Check(Box1.CompareTo(100) = 0, 'Box1 == "100"');
  Check(Box1.CompareTo(101) < 0, 'Box1 < "101"');
  Check(Box1.CompareTo(99) > 0, 'Box1 > "99"');
  Check(Box1.CompareTo(Box3) < 0, 'Box1 < Box3');
  Check(Box3.CompareTo(Box1) > 0, 'Box3 > Box1');
  Check(Box1.CompareTo(Box2) > 0, 'Box1 > Box2');
  Check(Box2.CompareTo(Box1) < 0, 'Box2 < Box1');

  BoxS := TBox<String>.Create();

  Check(Box1.CompareTo(BoxS) <> 0, 'Box1 <> BoxS');
  Box1.Unbox;

  Check(Box1.CompareTo(Box2) <> 0, 'Box1 <> Box2');
  Check(Box2.CompareTo(Box1) <> 0, 'Box2 <> Box1');
  Check(Box1.CompareTo(1) <> 0, 'Box2 <> 1');

  BoxS.Free;
  Box1.Free;
  Box2.Free;
  Box3.Free;
end;

procedure TTestBox.TestCreate;
var
  Box: TBox<String>;
  CS, CU: IType<String>;
begin
  { Create two comparers }
  CS := TStringType.Unicode(false);
  CU := TStringType.Unicode(true);

  { Create a default/no comparer box }
  Box := TBox<String>.Create();
  Check(Box.Peek = '', 'Expected a nil value for Box');
  Box.Free;

  { Create a default/comparer box }
  Box := TBox<String>.Create(CS);
  Check(Box.Peek = '', 'Expected a nil value for Box');
  Box.Free;

  { Create a value/no comparer box }
  Box := TBox<String>.Create('Hello World');
  Check(Box.Peek = 'Hello World', 'Expected a "Hello World" value for Box');
  Check(Box.GetHashCode() = CS.GenerateHashCode('Hello World'), 'Expeted a correct hash code for "Hello World"');
  Box.Free;

  { Create a value/comparer box }
  Box := TBox<String>.Create(CU, 'Hello World');
  Check(Box.Peek = 'Hello World', 'Expected a "Hello World" value for Box');
  Check(Box.GetHashCode() = CU.GenerateHashCode('Hello World'), 'Expeted a correct hash code for "Hello World"');
  Box.Free;

  { Test exceptions }
  CheckException(ENilArgumentException,
    procedure() begin
      Box := TBox<String>.Create(nil, 'One');
    end,
    'ENilArgumentException not thrown in Create(nil, string)'
  );

  CheckException(ENilArgumentException,
    procedure() begin
      Box := TBox<String>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create(nil)'
  );
end;

procedure TTestBox.TestEquals;
var
  Box1, Box2, Box3: TBox<String>;
  BoxI: TBox<Integer>;

  CS, CU: IType<String>;
begin
  { Create two comparers }
  CS := TStringType.Unicode(false);
  CU := TStringType.Unicode(true);

  Box1 := TBox<String>.Create('One');
  Box2 := TBox<String>.Create(CU, 'ONE');
  Box3 := TBox<String>.Create(CS, 'Two');

  { Box1 }
  Check(Box1.Equals(Box1), 'Box1 == Box1');
  Check(Box1.Equals('One'), 'Box1 == "One"');
  Check(not Box1.Equals('ONE'), 'Box1 != "ONE"');
  Check(not Box1.Equals(Box3), 'Box1 != Box3');

  { Box2 }
  Check(Box2.Equals(Box2), 'Box2 == Box2');
  Check(Box2.Equals(Box1), 'Box2 == Box1');
  Check(Box2.Equals('One'), 'Box2 == "One"');
  Check(Box2.Equals('ONE'), 'Box2 == "ONE"');
  Check(not Box2.Equals(Box3), 'Box2 != Box3');

  { Box3 }
  Check(Box3.Equals(Box3), 'Box3 == Box3');
  Check(not Box3.Equals(Box1), 'Box3 != Box1');
  Check(not Box3.Equals(Box2), 'Box3 != Box2');
  Check(Box3.Equals('Two'), 'Box3 == "Two"');
  Check(not Box3.Equals('ONE'), 'Box3 == "ONE"');

  BoxI := TBox<Integer>.Create(1);

  CheckFalse(Box1.Equals(BoxI));

  Box1.Unbox;
  CheckFalse(Box1.Equals(Box2));
  CheckFalse(Box2.Equals(Box1));
  CheckFalse(Box1.Equals('1'));

  BoxI.Free;
  Box1.Free;
  Box2.Free;
  Box3.Free;
end;

procedure TTestBox.TestGetHashCode;
var
  BoxS, BoxU, BoxU2: TBox<String>;
  CS, CU: IType<String>;
begin
  { Create two comparers }
  CS := TStringType.Unicode(false);
  CU := TStringType.Unicode(true);

  BoxS := TBox<String>.Create(CS, 'One');
  BoxU := TBox<String>.Create(CU, 'One');
  BoxU2 := TBox<String>.Create(CU, 'ONE');

  { Box3 }
  Check(BoxS.GetHashCode() = CS.GenerateHashCode('One'), 'BoxS hashcode failed!');
  Check(BoxU.GetHashCode() = CU.GenerateHashCode('one'), 'BoxU hashcode failed!');
  Check(BoxU2.GetHashCode() = CU.GenerateHashCode('oNE'), 'BoxU2 hashcode failed!');
  Check(BoxU2.GetHashCode() = BoxU.GetHashCode(), 'BoxU <> BoxU2 hash!');

  BoxS.Unbox;

  { Test exceptions }
  CheckException(EEmptyBoxException,
    procedure() begin
     BoxS.GetHashCode;
    end,
    'EEmptyBoxException not thrown in GetHashCode'
  );

  BoxS.Free;
  BoxU.Free;
  BoxU2.Free;
end;

procedure TTestBox.TestHasBoxedValue;
var
  Box: TBox<String>;
begin
  { Check default value }
  Box := TBox<String>.Create();
  Check(Box.HasBoxedValue, 'Expected Box('''') to be have a value');
  Box.Free;

  { Check default value with type }
  Box := TBox<String>.Create(TType<String>.Default);
  Check(Box.HasBoxedValue, 'Expected Box('''') to be have a value');
  Box.Free;

  { Check normal value }
  Box := TBox<String>.Create('Hello World!');
  Check(Box.HasBoxedValue, 'Expected Box(''Hello World'') to be have a value');
  Box.Free;

  { Check normal value with type }
  Box := TBox<String>.Create(TType<String>.Default, 'Hello World!');
  Check(Box.HasBoxedValue, 'Expected Box(''Hello World'') to be have a value');

  Box.Unbox;
  Check(not Box.HasBoxedValue, 'Expected HasBoxedValue to fail!');

  Box.Free;
end;

procedure TTestBox.TestPeek;
var
  Box: TBox<String>;
begin
  { Create a box with a value }
  Box := TBox<String>.Create('Testing');

  Check(Box.Peek() = 'Testing', 'Expected Peek() = "Testing"');
  Check(Box.HasBoxedValue, 'HasBoxedValue must be true');

  { Remove the value }
  Box.Unbox();

  { Test exceptions }
  CheckException(EEmptyBoxException,
    procedure() begin
      Box.Peek();
    end,
    'EEmptyBoxException not thrown in Peek()'
  );

  Box.Free;
end;

procedure TTestBox.TestProperCleaning;
var
  Box: TBox<Integer>;
  Cleanup: IType<Integer>;
  Died: Boolean;
  I: Integer;
begin
  Cleanup := TTestType<Integer>.Create(
    procedure(Arg1: Integer)
    begin
      Died := true;
    end);

  Died := false;
  Box := TBox<Integer>.Create(Cleanup, 1);

  Box.Peek;
  Check(not Died, 'Peek killed the value');

  Box.TryPeek(I);
  Check(not Died, 'TryPeek killed the value');

  Box.HasBoxedValue();
  Check(not Died, 'HasBoxedValue killed the value');

  Box.TryUnbox(I);
  Check(not Died, 'TryUnbox killed the value');

  Box.Free;
  Died := false;
  Box := TBox<Integer>.Create(Cleanup, 1);

  Box.Unbox();
  Check(not Died, 'Unbox killed the value');

  Box.Free;
  Check(not Died, 'Free killed the value');

  Died := false;
  Box := TBox<Integer>.Create(Cleanup, 1);

  Box.UnboxAndFree();
  Check(not Died, 'Unbox killed the value');

  Died := false;
  Box := TBox<Integer>.Create(Cleanup, 1);

  Box.CompareTo(1);
  Check(not Died, 'CompareTo killed the value');

  Box.CompareTo(Box);
  Check(not Died, 'CompareTo killed the value');

  Box.Equals(1);
  Check(not Died, 'Equals killed the value');

  Box.Equals(Box);
  Check(not Died, 'Equals killed the value');

  Box.GetHashCode();
  Check(not Died, 'GetHashCode killed the value');

  Box.ToString();
  Check(not Died, 'ToString killed the value');

  Box.Free;
  Check(Died, 'Free did not kill the value!');
end;

procedure TTestBox.TestToString;
var
  BoxS, BoxU, BoxU2: TBox<String>;
  CS, CU: IType<String>;
begin
  { Create two comparers }
  CS := TStringType.Unicode(false);
  CU := TStringType.Unicode(true);

  BoxS := TBox<String>.Create(CS, 'One');
  BoxU := TBox<String>.Create(CU, 'One');
  BoxU2 := TBox<String>.Create(CU, 'ONE');

  { Box3 }
  Check(BoxS.ToString() = 'One', 'BoxS ToString failed!');
  Check(BoxU.ToString() = 'One', 'BoxU ToString failed!');
  Check(BoxU2.ToString() = 'ONE', 'BoxU2 ToString failed!');

  BoxS.Unbox;

  { Test exceptions }
  CheckException(EEmptyBoxException,
    procedure() begin
     BoxS.ToString;
    end,
    'EEmptyBoxException not thrown in GetHashCode'
  );

  BoxS.Free;
  BoxU.Free;
  BoxU2.Free;
end;

procedure TTestBox.TestTryPeek;
var
  Box: TBox<String>;
  S: String;
begin
  { Create a box with a value }
  Box := TBox<String>.Create('Testing');

  Check(Box.TryPeek(S), 'TryPeek should not have failed!');
  Check(S = 'Testing', 'Expected S = "Testing"');
  Check(Box.HasBoxedValue, 'HasBoxedValue must be true');

  { Remove the value }
  Box.Unbox();
  Check(not Box.TryPeek(S), 'TryPeek should have failed!');

  Box.Free;
end;

procedure TTestBox.TestTryUnbox;
var
  Box: TBox<String>;
  S: String;
begin
  { Create a box with a value }
  Box := TBox<String>.Create('Testing');

  Check(Box.TryUnbox(S), 'TryPeek whould not have failed!');
  Check(S = 'Testing', 'Expected S = "Testing"');
  Check(not Box.HasBoxedValue, 'HasBoxedValue must be false');

  { Remove the value }
  Check(not Box.TryUnbox(S), 'TryUnbox should have failed!');

  Box.Free;
end;

procedure TTestBox.TestType;
var
  Support, Support2: IType<TBox<Integer>>;
  Box1, Box2: TBox<Integer>;
begin
  Support := TType<TBox<Integer>>.Default;
  Support2 := TClassType<TBox<Integer>>.Create(true);

  Box1 := TBox<Integer>.Create(10);
  Box2 := TBox<Integer>.Create(20);

  Check(Support.Compare(Box1, Box2) < 0, 'Compare(Box1, Box2) was expected to be less than 0');
  Check(Support.Compare(Box2, Box1) > 0, 'Compare(Box2, Box1) was expected to be bigger than 0');
  Check(Support.Compare(Box1, Box1) = 0, 'Compare(Box1, Box1) was expected to be  0');

  Check(Support.AreEqual(Box1, Box1), 'AreEqual(Box1, Box1) was expected to be true');
  Check(not Support.AreEqual(Box1, Box2), 'AreEqual(Box1, Box2) was expected to be false');

  Check(Support.GenerateHashCode(Box1) <> Support.GenerateHashCode(Box2), 'GenerateHashCode(Box1)/Box2 were expected to be different');
  Check(Support.Management() = tmNone, 'Type support = tmNone');
  Check(Support2.Management() = tmManual, 'Type support = tmManual');

  Check(Support.Name = 'TBox<System.Integer>', 'Type Name = "TBox<System.Integer>"');
  Check(Support.Size = 4, 'Type Size = 4 (size of pointer)');
  Check(Support.TypeInfo = TypeInfo(TBox<Integer>), 'Type information provider failed!');
  Check(Support.Family = tfClass, 'Type Family = tfClass');

  Check(Support.GetString(Box1) = Box1.ToString(), 'Invalid string was generated!');
  Check(Support.GetString(Box1) = '10', 'Invalid string was generated!');

  Support2.Cleanup(Box1);
  Support2.Cleanup(Box2);

  Check(Box1 = nil, 'Support did not cleanup the Box1');
  Check(Box2 = nil, 'Support did not cleanup the Box2');
end;

procedure TTestBox.TestUnbox;
var
  Box: TBox<String>;
begin
  { Create a box with a value }
  Box := TBox<String>.Create('Testing');

  Check(Box.Unbox() = 'Testing', 'Expected Peek() = "Testing"');
  Check(not Box.HasBoxedValue, 'HasBoxedValue must be false');

  { Test exceptions }
  CheckException(EEmptyBoxException,
    procedure() begin
      Box.Unbox();
    end,
    'EEmptyBoxException not thrown in Unbox()'
  );

  Box.Free;
end;

procedure TTestBox.TestUnboxAndFree;
var
  Box: TBox<Integer>;
begin
  { Do da dew 1 }
  Box := TBox<Integer>.Create(100);
  Check(Box.UnboxAndFree() = 100, 'Unboxing and freeing failed!');

  { Do da dew 2 }
  Box := TBox<Integer>.Create(100);
  Box.Unbox();

  { Test exceptions }
  CheckException(EEmptyBoxException,
    procedure() begin
      Box.UnboxAndFree();
    end,
    'EEmptyBoxException not thrown in UnboxAndFree()'
  );
end;

initialization
  TestFramework.RegisterTest(TTestBox.Suite);

end.
