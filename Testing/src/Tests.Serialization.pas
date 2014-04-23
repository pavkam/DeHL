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
unit Tests.Serialization;
interface
uses SysUtils,
     Classes,
     Tests.Utils,
     TestFramework,
     IniFiles,
     XmlDoc, XmlIntf,
     Rtti,
     TypInfo,
     DeHL.Base,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Serialization.Ini,
     DeHL.Serialization.Xml;

type
  TTestValueInfo = class(TDeHLTestCase)
  published
    procedure Test_Create_Type;
    procedure Test_Create_Field;
    procedure Test_Create_Field_Label;
    procedure Test_Create_Label;
    procedure Test_Create_Indexed;
  end;

type
  TTestIniSpecifics = class(TDeHLTestCase)
  published
    procedure Test_NoComplex;
    procedure Test_IniName_Element;
    procedure Test_KeyWords;
  end;

  TTestXmlSpecifics = class(TDeHLTestCase)
  published
    procedure Test_XSI_XSD;
    procedure Test_Clean;
    procedure Test_Attrs;
    procedure Test_XmlName_Element;
  end;


implementation

type
  TCrappyType = record
    FSome: Integer;
  end;

{ TTestValueInfo }

procedure TTestValueInfo.Test_Create_Field;
var
  LCtx: TRttiContext;
  LField: TRttiField;
  LInfo: TValueInfo;
begin
  LField := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      TValueInfo.Create(LField);
    end,
    'ENilArgumentException not thrown in constructor (nil rtti field).'
  );

  LField := LCtx.GetType(TypeInfo(TCrappyType)).GetField('FSome');
  LInfo := TValueInfo.Create(LField);

  CheckEquals(LInfo.Name, LField.Name);
  CheckTrue(LInfo.&Object = LField, 'Expected storage for the object');
end;

procedure TTestValueInfo.Test_Create_Field_Label;
var
  LCtx: TRttiContext;
  LField: TRttiField;
  LInfo: TValueInfo;
begin
  LField := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      TValueInfo.Create(LField, 'kkk');
    end,
    'ENilArgumentException not thrown in constructor (nil rtti field).'
  );

  LField := LCtx.GetType(TypeInfo(TCrappyType)).GetField('FSome');

  CheckException(ENilArgumentException,
    procedure()
    begin
      TValueInfo.Create(LField, '');
    end,
    'ENilArgumentException not thrown in constructor (nil rtti label).'
  );

  LInfo := TValueInfo.Create(LField, 'SomeLabel');

  CheckEquals(LInfo.Name, 'SomeLabel');
  CheckTrue(LInfo.&Object = LField, 'Expected storage for the object');
end;

procedure TTestValueInfo.Test_Create_Indexed;
var
  LInfo: TValueInfo;
begin
  LInfo := TValueInfo.Indexed;

  CheckEquals(LInfo.Name, '');
  CheckTrue(LInfo.&Object = nil, 'Expected no storage for the object');
end;

procedure TTestValueInfo.Test_Create_Label;
var
  LInfo: TValueInfo;
begin
  CheckException(ENilArgumentException,
    procedure()
    begin
      TValueInfo.Create('');
    end,
    'ENilArgumentException not thrown in constructor (nil string).'
  );

  LInfo := TValueInfo.Create('Label');

  CheckEquals(LInfo.Name, 'Label');
  CheckTrue(LInfo.&Object = nil, 'Expected no storage for the object');
end;

procedure TTestValueInfo.Test_Create_Type;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LInfo: TValueInfo;
begin
  LType := nil;

  CheckException(ENilArgumentException,
    procedure()
    begin
      TValueInfo.Create(LType);
    end,
    'ENilArgumentException not thrown in constructor (nil rtti type).'
  );

  LType := LCtx.GetType(TypeInfo(TCrappyType));
  LInfo := TValueInfo.Create(LType);

  CheckEquals(LInfo.Name, LType.Name);
  CheckTrue(LInfo.&Object = LType, 'Expected storage for the object');
end;

{ TTestIniSpecifics }

type
  [XmlName('i0', 'http://i0')]
  [IniName('i0')]
  TTestElement = type Integer;

  [XmlName('i1', 'http://i1')]
  [IniName('i1')]
  TIniNameTestRec = record
    [IniName]
    [XmlName]
    FField: String;

    [XmlName('i2', 'http://i2')]
    [IniName('i2')]
    LArr: array of TTestElement;

    [XmlArrayElement('a1')]
    [IniArrayElement('a1')]
    LArr2: array of TTestElement;
  end;

procedure TTestIniSpecifics.Test_IniName_Element;
var
  LIniFile: TMemIniFile;
  LIniSerializer: TIniSerializer<TIniNameTestRec>;
  LVal: TIniNameTestRec;
begin
  LVal.FField := 'One';
  SetLength(LVal.LArr, 2);
  LVal.LArr[0] := 100;
  LVal.LArr[1] := 101;

  SetLength(LVal.LArr2, 1);
  LVal.LArr2[0] := 800;

  { Create the serializer and an XML document }
  LIniSerializer := TIniSerializer<TIniNameTestRec>.Create();
  LIniFile := TMemIniFile.Create('_no_file_', TEncoding.UTF8);
  try
    { Serialize the structure }
    LIniSerializer.Serialize(LVal, LIniFile);

    CheckTrue(LIniFile.SectionExists('i1'), 'TIniNameTestRec (i1)');
    CheckTrue(LIniFile.ValueExists('i1', 'FField'), 'i1.FField');

    CheckTrue(LIniFile.SectionExists('i1\i2'), 'LArr (i2)');
    CheckFalse(LIniFile.ValueExists('i1', 'i2'), 'i1.i2');
    CheckFalse(LIniFile.ValueExists('i1', 'i2'), 'i1.i2');

    CheckTrue(LIniFile.ValueExists('i1\i2', 'i00'), 'i2[0] (i0 + 0)');
    CheckTrue(LIniFile.ValueExists('i1\i2', 'i01'), 'i2[1] (i0 + 1)');

    CheckTrue(LIniFile.SectionExists('i1\LArr2'), 'LArr2');
    CheckFalse(LIniFile.ValueExists('i1', 'LArr2'), 'i1.LArr2');

    CheckTrue(LIniFile.ValueExists('i1\LArr2', 'a10'), 'i2[0] (a1 + 0)');
  finally
    LIniFile.Free;
    LIniSerializer.Free;
  end;
end;

type
  T_Class = class
    FRec: record
      X: Integer;
    end;

    FNilArr: array of String;
    FArr: array of String;
  end;

procedure TTestIniSpecifics.Test_KeyWords;
var
  LIniFile: TMemIniFile;
  LIniSerializer: TIniSerializer<T_Class>;
  Rep, FromRep: T_Class;
begin
  { Create the serializer and an XML document }
  LIniSerializer := TIniSerializer<T_Class>.Create();
  LIniFile := TMemIniFile.Create('_no_file_', TEncoding.UTF8);
  Rep := T_Class.Create;
  SetLength(Rep.FArr, 1);
  Rep.FArr[0] := 'Lol';

  FromRep := nil;

  LIniSerializer.SectionPathSeparator := '#';
  LIniSerializer.ClassIdentifierValueName := 'C_TEST';
  LIniSerializer.ReferenceIdValueName := 'R_TEST';
  LIniSerializer.ArrayLengthValueName := 'L_TEST';

  try
    { Serialize the structure }
    LIniSerializer.Serialize(Rep, LIniFile);
    CheckTrue(LIniFile.SectionExists('T_Class') , 'Primary section');
    CheckTrue(LIniFile.ValueExists('T_Class', 'C_TEST') , 'Class Id');
    CheckTrue(LIniFile.ValueExists('T_Class', 'R_TEST') , 'Class RefId');
    CheckTrue(LIniFile.ValueExists('T_Class', 'FNilArr') , 'Nil array in class');

    CheckTrue(LIniFile.SectionExists('T_Class#FArr') , 'Array section');
    CheckTrue(LIniFile.ValueExists('T_Class#FArr', 'R_TEST') , 'Array RefId');
    CheckTrue(LIniFile.ValueExists('T_Class#FArr', 'L_TEST') , 'Array length');

    LIniSerializer.Deserialize(FromRep, LIniFile);

    CheckTrue(FromRep <> nil, 'Deserialized value should not be nil');
  finally
    FromRep.Free;
    Rep.Free;
    LIniFile.Free;
    LIniSerializer.Free;
  end;
end;

procedure TTestIniSpecifics.Test_NoComplex;
var
  LIniFile: TMemIniFile;
  LIniSerializer: TIniSerializer<Integer>;
  LSections: TStrings;
begin
  { Create the serializer and an XML document }
  LIniSerializer := TIniSerializer<Integer>.Create();
  LIniFile := TMemIniFile.Create('_no_file_', TEncoding.UTF8);
  LSections := TStringList.Create;

  try
    { Serialize the structure }
    LIniSerializer.Serialize(100, LIniFile);
    LIniFile.ReadSections(LSections);

    CheckEquals(1, LSections.Count, 'Count of expected sections');
    CheckEquals('', LSections[0], 'The primary section');
  finally
    LSections.Free;
    LIniFile.Free;
    LIniSerializer.Free;
  end;
end;

{ TTestXmlSpecifics }

type
  TInnerArray = array of string;
  TOuterArray = array of TInnerArray;

  [XmlName('XMLClass', 'http://test.com')]
  TXmlTestClass = class
    [XmlAttribute]
    FAttrStr: String;

    [XmlElement]
    FElemStr: String;

    [XmlElement]
    [XmlName('ArrayTest', 'http://array.test.com')]
    [XmlArrayElement('Element')]
    FSomeArray: TOuterArray;
  end;

procedure TTestXmlSpecifics.Test_Attrs;
var
  LXml: String;
  LInst: TXmlTestClass;
  LXmlFile: IXMLDocument;
  LXmlSerializer: TXmlSerializer<TXmlTestClass>;
begin
  LInst := TXmlTestClass.Create;
  LInst.FAttrStr := 'string in attr';
  LInst.FElemStr := 'string in element';
  LInst.FSomeArray := TOuterArray.Create(TInnerArray.Create('one', 'two'), nil, TInnerArray.Create('John'));

  { Create the serializer and an XML document }
  LXmlSerializer := TXmlSerializer<TXmlTestClass>.Create();
  LXmlSerializer.XSD := '';
  LXmlSerializer.XSI := '';

  LXmlFile := TXMLDocument.Create(nil);
  LXmlFile.Active := true;

  { Serialize the instance }
  try
    LXmlSerializer.Serialize(LInst, LXmlFile.Node);
    LXmlFile.SaveToXml(LXml);

    CheckEquals('<XMLClass xmlns="http://test.com" xmlns:DeHL="http://alex.ciobanu.org/DeHL.Serialization.XML" ' +
                'DeHL:class="Tests.Serialization.TXmlTestClass" DeHL:refid="1" FAttrStr="string in attr" ' +
                'xmlns:NS1="http://array.test.com"><FElemStr>string in element</FElemStr><NS1:ArrayTest ' +
                'DeHL:count="3" DeHL:refid="2"><NS1:TInnerArray DeHL:count="2" DeHL:refid="3"><NS1:string>one</NS1:string>' +
                '<NS1:string>two</NS1:string></NS1:TInnerArray><NS1:TInnerArray DeHL:refto="0"/><NS1:TInnerArray '+
                'DeHL:count="1" DeHL:refid="4"><NS1:string>John</NS1:string></NS1:TInnerArray></NS1:ArrayTest></XMLClass>',
                Trim(LXml));
  finally
    LXmlSerializer.Free;
    LInst.Free;
  end;
end;

procedure TTestXmlSpecifics.Test_Clean;
var
  LXml: String;
  LXmlFile: IXMLDocument;
  LXmlSerializer: TXmlSerializer<Integer>;
begin
  { Create the serializer and an XML document }
  LXmlSerializer := TXmlSerializer<Integer>.Create();
  LXmlFile := TXMLDocument.Create(nil);
  LXmlFile.Active := true;

  LXmlSerializer.XSD := '';
  LXmlSerializer.XSI := '';

  { Serialize the instance }
  try
    LXmlSerializer.Serialize(100, LXmlFile.Node);
    LXmlFile.SaveToXml(LXml);

    CheckEquals('<Integer>100</Integer>', Trim(LXml));
  finally
    LXmlSerializer.Free;
  end;
end;

procedure TTestXmlSpecifics.Test_XmlName_Element;
var
  LXml: String;
  LVal: TIniNameTestRec;
  LXmlFile: IXMLDocument;
  LXmlSerializer: TXmlSerializer<TIniNameTestRec>;
begin
  LVal.FField := 'One';
  SetLength(LVal.LArr, 2);
  LVal.LArr[0] := 100;
  LVal.LArr[1] := 101;

  SetLength(LVal.LArr2, 1);
  LVal.LArr2[0] := 800;

  { Create the serializer and an XML document }
  LXmlSerializer := TXmlSerializer<TIniNameTestRec>.Create();
  LXmlSerializer.XSD := '';
  LXmlSerializer.XSI := '';

  LXmlFile := TXMLDocument.Create(nil);
  LXmlFile.Active := true;

  { Serialize the instance }
  try
    LXmlSerializer.Serialize(LVal, LXmlFile.Node);
    LXmlFile.SaveToXml(LXml);

    CheckEquals('<i1 xmlns="http://i1" xmlns:NS1="http://i2" xmlns:DeHL="http://alex.ciobanu.org/' +
                'DeHL.Serialization.XML" xmlns:NS2="http://i0"><FField>One</FField><NS1:i2 DeHL:count="2" ' +
                'DeHL:refid="1"><NS2:i0>100</NS2:i0><NS2:i0>101</NS2:i0></NS1:i2><LArr2 DeHL:count="1" ' +
                'DeHL:refid="2"><NS2:a1>800</NS2:a1></LArr2></i1>',
                Trim(LXml));
  finally
    LXmlSerializer.Free;
  end;
end;

procedure TTestXmlSpecifics.Test_XSI_XSD;
var
  LXml: String;
  LXmlFile: IXMLDocument;
  LXmlSerializer: TXmlSerializer<Integer>;
begin
  { Create the serializer and an XML document }
  LXmlSerializer := TXmlSerializer<Integer>.Create();
  LXmlFile := TXMLDocument.Create(nil);
  LXmlFile.Active := true;

  { Serialize the instance }
  try
    LXmlSerializer.Serialize(100, LXmlFile.Node);
    LXmlFile.SaveToXml(LXml);

    CheckEquals('<Integer xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
      'xmlns:xsd="http://www.w3.org/2001/XMLSchema">100</Integer>', Trim(LXml));
  finally
    LXmlSerializer.Free;
  end;
end;

initialization
  TestFramework.RegisterTest(TTestValueInfo.Suite);
  TestFramework.RegisterTest(TTestIniSpecifics.Suite);
  TestFramework.RegisterTest(TTestXmlSpecifics.Suite);

end.
