(*
* Copyright (c) 2008, Susnea Andrei
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
* THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

unit Tests.BitSet;
interface
uses SysUtils, TestFramework,
     HelperLib.TypeSupport,
     HelperLib.Collections.Dictionary,
     HelperLib.Collections.KeyValuePair,
     HelperLib.Collections.Map,
     HelperLib.Collections.BitSet,
     HelperLib.Collections.Exceptions;

type
 TExceptionClosure = reference to procedure;
 TClassOfException = class of Exception;

 TTestBitSet = class(TTestCase)
 private
   procedure CheckException(ExType : TClassOfException; Proc : TExceptionClosure; const Msg : String);

 published
   procedure TestCreationAndDestroy();
   procedure TestInsertAddRemoveResetCount();
   procedure TestEnumerator();
   procedure TestExceptions();
   procedure TestBigCounts();
 end;

implementation

{ TTestBitSet }

procedure TTestBitSet.CheckException(ExType: TClassOfException;
  Proc: TExceptionClosure; const Msg: String);
begin

end;

procedure TTestBitSet.TestBigCounts;
begin

end;

procedure TTestBitSet.TestCreationAndDestroy;
var
  BS : HBitSet;
begin
  BS := HBitSet.Create($FFF);

  BS.Reset();

end;

procedure TTestBitSet.TestEnumerator;
begin

end;

procedure TTestBitSet.TestExceptions;
begin

end;

procedure TTestBitSet.TestInsertAddRemoveResetCount;
begin

end;

initialization
  TestFramework.RegisterTest(TTestBitSet.Suite);

end.
