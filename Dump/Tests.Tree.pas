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
unit Tests.Tree;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.Tree,
     DeHL.Collections.Base,
     DeHL.Collections.List,
     DeHL.Arrays;

type
  TTestTree = class(TDeHLTestCase)
  published
    procedure Test_Create_Value;
    procedure Test_Create_Tree;
    procedure Test_Create_Type_Value;
    procedure Test_Create_Type_Tree;
    procedure Test_Add;
    procedure Test_Clear;
    procedure Test_Remove;
    procedure Test_Contains;
    procedure Test_Find;
    procedure Test_Count;
    procedure Test_Root;
    procedure Test_CopyTo;
    procedure Test_Empty;
    procedure Test_Enumerator;
  end;

implementation

{ TTestTree }

procedure TTestTree.Test_Add;
var
  LTree, LTree2: TTree<Integer>;
begin
  LTree := TTree<Integer>.Create(0);
  LTree2 := TTree<Integer>.Create(0);

  LTree.Add(LTree.Root, 1);
  LTree.Add(LTree.Root, 2);
  LTree.Add(LTree.Root.Children.First, 3);

  CheckEquals(1, LTree.Root.Children.First.Value);
  CheckEquals(2, LTree.Root.Children.Last.Value);
  CheckEquals(3, LTree.Root.Children.First.Children.First.Value);

  CheckException(Exception,
    procedure()
    begin
      LTree.Add(nil, 4);
    end,
    'Exception not thrown in AddLeft (1)!'
  );

  CheckException(Exception,
    procedure()
    var
      LNode: TTreeNode<Integer>;
    begin
      LNode := TTreeNode<Integer>.Create(12, LTree2);

      try
        LTree.Add(LNode, 4);
      finally
        LNode.Free;
      end;
    end,
    'Exception not thrown in AddLeft (2)!'
  );

  CheckException(Exception,
    procedure()
    var
      LNode: TTreeNode<Integer>;
    begin
      LNode := TTreeNode<Integer>.Create(12, LTree);

      try
        LTree.Add(LNode, 4);
      finally
        LNode.Free;
      end;
    end,
    'Exception not thrown in AddLeft (3)!'
  );

  LTree.Free;
  LTree2.Free;
end;

procedure TTestTree.Test_Clear;
var
  LTree: TTree<Integer>;
begin
  LTree := TTree<Integer>.Create(100);
  LTree.Clear;

  CheckTrue(LTree.Root = nil);

  //TODO: implement me + implement proper root setting

  LTree.Free;
end;

procedure TTestTree.Test_Contains;
var
  LTree: TTree<Integer>;
begin
  LTree := TTree<Integer>.Create(100);
  LTree.Add(LTree.Root, 99);
end;

procedure TTestTree.Test_CopyTo;
begin

end;

procedure TTestTree.Test_Count;
begin

end;

procedure TTestTree.Test_Create_Tree;
begin

end;

procedure TTestTree.Test_Create_Type_Tree;
begin

end;

procedure TTestTree.Test_Create_Type_Value;
begin

end;

procedure TTestTree.Test_Create_Value;
begin

end;

procedure TTestTree.Test_Empty;
begin

end;

procedure TTestTree.Test_Enumerator;
begin

end;

procedure TTestTree.Test_Find;
begin

end;

procedure TTestTree.Test_Remove;
begin

end;

procedure TTestTree.Test_Root;
begin

end;

initialization
  TestFramework.RegisterTest(TTestTree.Suite);

end.

