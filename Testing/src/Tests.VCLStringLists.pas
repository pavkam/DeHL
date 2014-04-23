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
unit Tests.VCLStringLists;
interface
uses SysUtils,
     Classes,
     Contnrs,
     Generics.Collections,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHl.Box,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.Base,
     DeHL.Collections.Interop;

type
  TTestVCLStringLists = class(TDeHLTestCase)
  published
    { TStringList }
    procedure TestSListCreation;
    procedure TestSListAddObject;
    procedure TestSListIndexOfObject;
    procedure TestSListInsertObject;
    procedure TestSListObjects;
    procedure TestSListBoxingAspects;
    procedure TestSListCorrectAssociation;
    procedure TestSListCleanup;
    procedure TestSListExceptions;

    { TWideStringList }
    procedure TestWSListCreation;
    procedure TestWSListAddObject;
    procedure TestWSListIndexOfObject;
    procedure TestWSListInsertObject;
    procedure TestWSListObjects;
    procedure TestWSListBoxingAspects;
    procedure TestWSListCorrectAssociation;
    procedure TestWSListCleanup;
    procedure TestWSListExceptions;
  end;

implementation

{ TTestVCLStringLists }

procedure TTestVCLStringLists.TestSListAddObject;
var
  List: TStringList<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  Check(List.AddObject('One', 1) = 0, 'Return value at One failed');
  Check(List.AddObject('Two', 2) = 1, 'Return value at Two failed');

  { And now add using the old method }
  Check(List.AddObject('Three', TBox<Integer>.Create(3)) = 2, 'Return value at Three failed');
  Check(List.AddObject('Four', TBox<Integer>.Create(4)) = 3, 'Return value at Four failed');

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');
  Check(List.Objects[2] = 3, 'Expected List[2] = 3');
  Check(List.Objects[3] = 4, 'Expected List[3] = 4');

  List.Free;
end;

procedure TTestVCLStringLists.TestSListBoxingAspects;
var
  List: TStringList<Integer>;
  Box: TBox<Integer>;
begin
  { Check with empty ctor }
  List := TStringList<Integer>.Create();
  List.AddObject('One', 1);
  List.AddObject('Two', 2);
  List.AddObject('Three', 3);
  List.AddObject('Four', 4);

  Box := TBox<Integer>(TStringList(List).Objects[0]);
  Box.Unbox;

  Check(List.IndexOfObject(Box) = 0, 'Expected to find an unboxed box');
  Check(List.IndexOfObject(1) = -1, 'Not expected to find 1 in the list');
  Check(List.Objects[0] = 0, 'Expected to retrieve 0 at position 0 (unboxed)');

  List.Free;
end;

procedure TTestVCLStringLists.TestSListCleanup;
var
  List : TStringList<Integer>;
  ElemCache: Integer;
begin
  ElemCache := 0;

  { Create a new ATree }
  List := TStringList<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end), false
  );

  List.AddObject('One', 1);
  List.AddObject('Two', 2);
  List.Objects[0] := -1;

  List.Clear();
  Check(ElemCache = 0, 'One should not have been cleaned up!');

  List.Free;
  Check(ElemCache = 0, 'One should not have been cleaned up!');

  { Create a new ATree }
  List := TStringList<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end), true
  );

  List.AddObject('One', 1);
  List.Objects[0] := -1;
  Check(ElemCache = 1, '1 should have been cleaned up!');

  List.Clear;
  Check(ElemCache = 0, '-1 should have been cleaned up!');

  List.AddObject('10', 10);
  List.InsertObject(0, '20', 20);
  List.AddObject('30', 30);
  List.Add('Lol');

  List.Free;
  Check(ElemCache = 60, 'All should have been cleaned up!');
end;

procedure TTestVCLStringLists.TestSListCorrectAssociation;
var
  List: TStringList<Integer>;
begin
  { Check with empty ctor }
  List := TStringList<Integer>.Create();
  List.AddObject('One', 1);
  Check(List.Objects[List.IndexOf('One')] = 1, 'Expected IndexOf/Objects to be correct for "One"');

  List.Free;
end;

procedure TTestVCLStringLists.TestSListCreation;
var
  List: TStringList<Integer>;
begin
  { Check with empty ctor }
  List := TStringList<Integer>.Create();
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');

  List.Free;

  { Check with give type support }
  List := TStringList<Integer>.Create(TType<Integer>.Default, false);
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');

  List.Free;

  { Check with give given owns objects }
  List := TStringList<Integer>.Create(true);
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');

  List.Free;
end;

procedure TTestVCLStringLists.TestSListExceptions;
var
  List: TStringList<Integer>;
begin
  CheckException(ENilArgumentException,
    procedure()
    begin
      TStringList<Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create.'
  );

  { ... }
  List := TStringList<Integer>.Create();

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      List.AddObject('One', List);
    end,
    'ENotSameTypeArgumentException not thrown in AddObject.'
  );

  List.AddObject('One', 1);

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      TStringList(List).Objects[0] := List;
    end,
    'ENotSameTypeArgumentException not thrown in Objects (old).'
  );

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      List.IndexOfObject(List);
    end,
    'ENotSameTypeArgumentException not thrown in IndexOfObject.'
  );

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      List.InsertObject(0, 'AnotherOne', List);
    end,
    'ENotSameTypeArgumentException not thrown in IndexOfObject.'
  );

  List.Free;
end;

procedure TTestVCLStringLists.TestSListIndexOfObject;
var
  List: TStringList<Integer>;
  o: TBox<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  { And now add using the old method }
  o := TBox<Integer>.Create(3);
  List.AddObject('Three', o);
  List.AddObject('Four', TBox<Integer>.Create(4));

  Check(List.IndexOfObject(1) = 0, 'Expected IndexOfObject(1) = 0');
  Check(List.IndexOfObject(2) = 1, 'Expected IndexOfObject(2) = 1');
  Check(List.IndexOfObject(3) = 2, 'Expected IndexOfObject(3) = 2');
  Check(List.IndexOfObject(4) = 3, 'Expected IndexOfObject(4) = 3');
  Check(List.IndexOfObject(o) = 2, 'Expected IndexOfObject(o) = 2');

  { Get the object at index 1 }
  o := TBox<Integer>(TStringList(List).Objects[1]);
  Check(List.IndexOfObject(o) = 1, 'Expected IndexOfObject(o) = 1');

  List.Free;
end;

procedure TTestVCLStringLists.TestSListInsertObject;
var
  List: TStringList<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  List.InsertObject(0, 'One', 1);
  List.InsertObject(1, 'Two', 2);

  { And now add using the old method }
  List.InsertObject(2, 'Three', TBox<Integer>.Create(3));
  List.InsertObject(0, 'MinusOne', TBox<Integer>.Create(-1));

  Check(List.Objects[0] = -1, 'Expected List[0] = -1');
  Check(List.Objects[1] = 1, 'Expected List[1] = 1');
  Check(List.Objects[2] = 2, 'Expected List[2] = 2');
  Check(List.Objects[3] = 3, 'Expected List[3] = 3');

  List.Free;
end;

procedure TTestVCLStringLists.TestSListObjects;
var
  List: TStringList<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  List.AddObject('One', 1);
  List.AddObject('Two', 2);
  List.AddObject('Three', 3);
  List.AddObject('Four', TBox<Integer>.Create(4));

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');
  Check(List.Objects[2] = 3, 'Expected List[2] = 3');
  Check(List.Objects[3] = 4, 'Expected List[3] = 4');

  Check(TBox<Integer>(TStringList(List).Objects[3]).Peek = 4, 'Expected List[3] (Peek) = 4');

  List.Free;
end;


procedure TTestVCLStringLists.TestWSListAddObject;
var
  List: TStringList<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  Check(List.AddObject('One', 1) = 0, 'Return value at One failed');
  Check(List.AddObject('Two', 2) = 1, 'Return value at Two failed');

  { And now add using the old method }
  Check(List.AddObject('Three', TBox<Integer>.Create(3)) = 2, 'Return value at Three failed');
  Check(List.AddObject('Four', TBox<Integer>.Create(4)) = 3, 'Return value at Four failed');

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');
  Check(List.Objects[2] = 3, 'Expected List[2] = 3');
  Check(List.Objects[3] = 4, 'Expected List[3] = 4');

  List.Free;
end;

procedure TTestVCLStringLists.TestWSListBoxingAspects;
var
  List: TStringList<Integer>;
  Box: TBox<Integer>;
begin
  { Check with empty ctor }
  List := TStringList<Integer>.Create();
  List.AddObject('One', 1);
  List.AddObject('Two', 2);
  List.AddObject('Three', 3);
  List.AddObject('Four', 4);

  Box := TBox<Integer>(TStringList(List).Objects[0]);
  Box.Unbox;

  Check(List.IndexOfObject(Box) = 0, 'Expected to find an unboxed box');
  Check(List.IndexOfObject(1) = -1, 'Not expected to find 1 in the list');
  Check(List.Objects[0] = 0, 'Expected to retrieve 0 at position 0 (unboxed)');

  List.Free;
end;

procedure TTestVCLStringLists.TestWSListCleanup;
var
  List : TStringList<Integer>;
  ElemCache: Integer;
begin
  ElemCache := 0;

  { Create a new ATree }
  List := TStringList<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end), false
  );

  List.AddObject('One', 1);
  List.AddObject('Two', 2);
  List.Objects[0] := -1;

  List.Clear();
  Check(ElemCache = 0, 'One should not have been cleaned up!');

  List.Free;
  Check(ElemCache = 0, 'One should not have been cleaned up!');

  { Create a new ATree }
  List := TStringList<Integer>.Create(
    TTestType<Integer>.Create(procedure(Arg1: Integer) begin
      Inc(ElemCache, Arg1);
    end), true
  );

  List.AddObject('One', 1);
  List.Objects[0] := -1;
  Check(ElemCache = 1, '1 should have been cleaned up!');

  List.Clear;
  Check(ElemCache = 0, '-1 should have been cleaned up!');

  List.AddObject('10', 10);
  List.InsertObject(0, '20', 20);
  List.AddObject('30', 30);
  List.Add('Lol');

  List.Free;
  Check(ElemCache = 60, 'All should have been cleaned up!');
end;

procedure TTestVCLStringLists.TestWSListCorrectAssociation;
var
  List: TStringList<Integer>;
begin
  { Check with empty ctor }
  List := TStringList<Integer>.Create();
  List.AddObject('One', 1);
  Check(List.Objects[List.IndexOf('One')] = 1, 'Expected IndexOf/Objects to be correct for "One"');

  List.Free;
end;

procedure TTestVCLStringLists.TestWSListCreation;
var
  List: TStringList<Integer>;
begin
  { Check with empty ctor }
  List := TStringList<Integer>.Create();
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');

  List.Free;

  { Check with give type support }
  List := TStringList<Integer>.Create(TType<Integer>.Default, false);
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');

  List.Free;

  { Check with give given owns objects }
  List := TStringList<Integer>.Create(true);
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');

  List.Free;
end;

procedure TTestVCLStringLists.TestWSListExceptions;
var
  List: TStringList<Integer>;
begin
  CheckException(ENilArgumentException,
    procedure()
    begin
      TStringList<Integer>.Create(nil);
    end,
    'ENilArgumentException not thrown in Create.'
  );

  { ... }
  List := TStringList<Integer>.Create();

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      List.AddObject('One', List);
    end,
    'ENotSameTypeArgumentException not thrown in AddObject.'
  );

  List.AddObject('One', 1);

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      TStringList(List).Objects[0] := List;
    end,
    'ENotSameTypeArgumentException not thrown in Objects (old).'
  );

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      List.IndexOfObject(List);
    end,
    'ENotSameTypeArgumentException not thrown in IndexOfObject.'
  );

  CheckException(ENotSameTypeArgumentException,
    procedure()
    begin
      List.InsertObject(0, 'AnotherOne', List);
    end,
    'ENotSameTypeArgumentException not thrown in IndexOfObject.'
  );

  List.Free;
end;

procedure TTestVCLStringLists.TestWSListIndexOfObject;
var
  List: TStringList<Integer>;
  o: TBox<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  List.AddObject('One', 1);
  List.AddObject('Two', 2);

  { And now add using the old method }
  o := TBox<Integer>.Create(3);
  List.AddObject('Three', o);
  List.AddObject('Four', TBox<Integer>.Create(4));

  Check(List.IndexOfObject(1) = 0, 'Expected IndexOfObject(1) = 0');
  Check(List.IndexOfObject(2) = 1, 'Expected IndexOfObject(2) = 1');
  Check(List.IndexOfObject(3) = 2, 'Expected IndexOfObject(3) = 2');
  Check(List.IndexOfObject(4) = 3, 'Expected IndexOfObject(4) = 3');
  Check(List.IndexOfObject(o) = 2, 'Expected IndexOfObject(o) = 2');

  { Get the object at index 1 }
  o := TBox<Integer>(TStringList(List).Objects[1]);
  Check(List.IndexOfObject(o) = 1, 'Expected IndexOfObject(o) = 1');

  List.Free;
end;

procedure TTestVCLStringLists.TestWSListInsertObject;
var
  List: TStringList<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  List.InsertObject(0, 'One', 1);
  List.InsertObject(1, 'Two', 2);

  { And now add using the old method }
  List.InsertObject(2, 'Three', TBox<Integer>.Create(3));
  List.InsertObject(0, 'MinusOne', TBox<Integer>.Create(-1));

  Check(List.Objects[0] = -1, 'Expected List[0] = -1');
  Check(List.Objects[1] = 1, 'Expected List[1] = 1');
  Check(List.Objects[2] = 2, 'Expected List[2] = 2');
  Check(List.Objects[3] = 3, 'Expected List[3] = 3');

  List.Free;
end;

procedure TTestVCLStringLists.TestWSListObjects;
var
  List: TStringList<Integer>;
begin
  { ... }
  List := TStringList<Integer>.Create();

  { Add normally }
  List.AddObject('One', 1);
  List.AddObject('Two', 2);
  List.AddObject('Three', 3);
  List.AddObject('Four', TBox<Integer>.Create(4));

  Check(List.Objects[0] = 1, 'Expected List[0] = 1');
  Check(List.Objects[1] = 2, 'Expected List[1] = 2');
  Check(List.Objects[2] = 3, 'Expected List[2] = 3');
  Check(List.Objects[3] = 4, 'Expected List[3] = 4');

  Check(TBox<Integer>(TStringList(List).Objects[3]).Peek = 4, 'Expected List[3] (Peek) = 4');

  List.Free;
end;

initialization
  TestFramework.RegisterTest(TTestVCLStringLists.Suite);

end.
