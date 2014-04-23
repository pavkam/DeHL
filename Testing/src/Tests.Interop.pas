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
unit Tests.Interop;
interface
uses SysUtils,
     Classes,
     Contnrs,
     Generics.Collections,
     WideStrings,
     Tests.Utils,
     TestFramework,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Collections.Base,
     DeHL.Collections.List,
     DeHL.Collections.Dictionary,
     DeHL.Collections.Interop;

type
  TTestCollectionsInterop = class(TDeHLTestCase)
  published
    procedure TestWrapGCCollection();
    procedure TestWrapGCAssocCollection();
    procedure TestWrapList();
    procedure TestWrapObjectList();
    procedure TestWrapComponentList();
    procedure TestWrapClassList();
    procedure TestInterfaceList();
    procedure TestWrapStringList();
    procedure TestWrapWideStringList();
    procedure TestWrapTComponent();
    procedure TestWrapCollection();

    procedure TestFromDeHLCollection();
    procedure TestFromDeHLEnexCollection();
    procedure TestFromDeHLAssocCollection();
    procedure TestFromDeHLEnexAssocCollection();

    procedure TestInteropExceptions();
  end;

implementation

{ TTestCollectionsInterop }

procedure TTestCollectionsInterop.TestFromDeHLAssocCollection;
const
  NrElem = 100;

var
  Dict: TDictionary<Integer, Integer>;
  gDict: Generics.Collections.TDictionary<Integer, Integer>;
  I:Integer;

begin
  Dict := TDictionary<Integer, Integer>.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    Dict.Add(I, Random(MaxInt));

  { Copy to my list }
  gDict := Generics.Collections.TDictionary<Integer, Integer>.Create(TVCLCollection.From<Integer, Integer>(Dict));

  Check(gDict.Count = Dict.Count, 'Not all elements were copied!');

  for I in gDict.Keys do
    Check(gDict[I] = Dict[I], 'Copy failed!');

  Dict.Free;
  gDict.Free;
end;

procedure TTestCollectionsInterop.TestFromDeHLCollection;
const
  NrElem = 100;

var
  List: TList<Integer>;
  I:Integer;
  gList: Generics.Collections.TList<Integer>;

begin
  List := TList<Integer>.Create();

  { Fill in the DeHL container }
  for I := 0 to NrElem - 1 do
    List.Add(Random(MaxInt));

  { Copy to VCL list }
  gList := Generics.Collections.TList<Integer>.Create(TVCLCollection.From<Integer>(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestFromDeHLEnexAssocCollection;
const
  NrElem = 100;

var
  Dict: IDictionary<Integer, Integer>;
  gDict: Generics.Collections.TDictionary<Integer, Integer>;
  I:Integer;

begin
  Dict := TDictionary<Integer, Integer>.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    Dict.Add(I, Random(MaxInt));

  { Copy to my list }
  gDict := Generics.Collections.TDictionary<Integer, Integer>.Create(TVCLCollection.From<Integer, Integer>(Dict));

  Check(gDict.Count = Dict.Count, 'Not all elements were copied!');

  for I in gDict.Keys do
    Check(gDict[I] = Dict[I], 'Copy failed!');

  gDict.Free;
end;

procedure TTestCollectionsInterop.TestFromDeHLEnexCollection;
const
  NrElem = 100;

var
  List: IList<Integer>;
  I:Integer;
  gList: Generics.Collections.TList<Integer>;

begin
  List := TList<Integer>.Create();

  { Fill in the DeHL container }
  for I := 0 to NrElem - 1 do
    List.Add(Random(MaxInt));

  { Copy to VCL list }
  gList := Generics.Collections.TList<Integer>.Create(TVCLCollection.From<Integer>(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  gList.Free;
end;

procedure TTestCollectionsInterop.TestInterfaceList;
const
  NrElem = 100;

var
  List: TInterfaceList;
  I:Integer;
  gList: TList<IInterface>;

begin
  List := TInterfaceList.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(TInterfacedObject.Create());

  { Copy to my list }
  gList := TList<IInterface>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestInteropExceptions;
begin
  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap<Integer>(Generics.Collections.TList<Integer>(nil));
    end,
    'ENilArgumentException not thrown in GC Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap<Integer, Integer>(Generics.Collections.TDictionary<Integer, Integer>(nil));
    end,
    'ENilArgumentException not thrown in GC Assoc Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TList(nil));
    end,
    'ENilArgumentException not thrown in TList Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TStrings(nil));
    end,
    'ENilArgumentException not thrown in TStrings Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TWideStrings(nil));
    end,
    'ENilArgumentException not thrown in TWideStrings Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TInterfaceList(nil));
    end,
    'ENilArgumentException not thrown in TInterfaceList Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TCollection(nil));
    end,
    'ENilArgumentException not thrown in TCollection Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TComponent(nil));
    end,
    'ENilArgumentException not thrown in TComponent Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TObjectList(nil));
    end,
    'ENilArgumentException not thrown in TObjectList Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TComponentList(nil));
    end,
    'ENilArgumentException not thrown in TComponentList Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.Wrap(TClassList(nil));
    end,
    'ENilArgumentException not thrown in TClassList Wrap.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.From<Integer>(TList<Integer>(nil));
    end,
    'ENilArgumentException not thrown in TList From.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.From<Integer, Integer>(TDictionary<Integer, Integer>(nil));
    end,
    'ENilArgumentException not thrown in TDictionary From.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.From<Integer>(IList<Integer>(nil));
    end,
    'ENilArgumentException not thrown in IList From.'
  );

  CheckException(ENilArgumentException,
    procedure()
    begin
      TVCLCollection.From<Integer, Integer>(IDictionary<Integer, Integer>(nil));
    end,
    'ENilArgumentException not thrown in IDictionary From.'
  );
end;

procedure TTestCollectionsInterop.TestWrapClassList;
const
  NrElem = 100;

var
  List: TClassList;
  I:Integer;
  gList: TList<TClass>;

begin
  List := TClassList.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(Ptr(Random(MaxInt)));

  { Copy to my list }
  gList := TList<TClass>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapCollection;
const
  NrElem = 100;

var
  List: TCollection;
  I:Integer;
  gList: TList<TCollectionItem>;

begin
  List := TCollection.Create(TCollectionItem);

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add;

  { Copy to my list }
  gList := TList<TCollectionItem>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List.Items[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapComponentList;
const
  NrElem = 100;

var
  List: TComponentList;
  I:Integer;
  gList: TList<TComponent>;

begin
  List := TComponentList.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(TComponent.Create(nil));

  { Copy to my list }
  gList := TList<TComponent>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapGCAssocCollection;
const
  NrElem = 100;

var
  Dict: Generics.Collections.TDictionary<Integer, Integer>;
  I:Integer;
  gDict: TDictionary<Integer, Integer>;

begin
  Dict := Generics.Collections.TDictionary<Integer, Integer>.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    Dict.Add(I, Random(MaxInt));

  { Copy to my list }
  gDict := TDictionary<Integer, Integer>.Create(TVCLCollection.Wrap<Integer, Integer>(Dict));

  Check(gDict.Count = Dict.Count, 'Not all elements were copied!');

  for I in gDict.Keys do
    Check(gDict[I] = Dict[I], 'Copy failed!');

  Dict.Free;
  gDict.Free;
end;

procedure TTestCollectionsInterop.TestWrapGCCollection;
const
  NrElem = 100;

var
  List: Generics.Collections.TList<Integer>;
  I:Integer;
  gList: TList<Integer>;

begin
  List := Generics.Collections.TList<Integer>.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(Random(MaxInt));

  { Copy to my list }
  gList := TList<Integer>.Create(TVCLCollection.Wrap<Integer>(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapList;
const
  NrElem = 100;

var
  List: TList;
  I:Integer;
  gList: TList<Pointer>;

begin
  List := TList.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(Ptr(Random(MaxInt)));

  { Copy to my list }
  gList := TList<Pointer>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapObjectList;
const
  NrElem = 100;

var
  List: TObjectList;
  I:Integer;
  gList: TList<TObject>;

begin
  List := TObjectList.Create();
  List.OwnsObjects := false;

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(Ptr(Random(MaxInt)));

  { Copy to my list }
  gList := TList<TObject>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapStringList;
const
  NrElem = 100;

var
  List: TStringList;
  I:Integer;
  gList: TList<String>;

begin
  List := TStringList.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(IntToStr(Random(MaxInt)));

  { Copy to my list }
  gList := TList<String>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapTComponent;
const
  NrElem = 100;

var
  List: TComponent;
  I:Integer;
  gList: TList<TComponent>;

begin
  List := TComponent.Create(nil);

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    TComponent.Create(List);

  { Copy to my list }
  gList := TList<TComponent>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.ComponentCount, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List.Components[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

procedure TTestCollectionsInterop.TestWrapWideStringList;
const
  NrElem = 100;

var
  List: TWideStringList;
  I:Integer;
  gList: TList<WideString>;

begin
  List := TWideStringList.Create();

  { Fill in the VCL container }
  for I := 0 to NrElem - 1 do
    List.Add(IntToStr(Random(MaxInt)));

  { Copy to my list }
  gList := TList<WideString>.Create(TVCLCollection.Wrap(List));

  Check(gList.Count = List.Count, 'Not all elements were copied!');

  for I := 0 to NrElem - 1 do
    Check(gList[I] = List[I], 'Copy failed!');

  List.Free;
  gList.Free;
end;

initialization
  TestFramework.RegisterTest(TTestCollectionsInterop.Suite);

end.
