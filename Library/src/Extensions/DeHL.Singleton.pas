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

{$I ../DeHL.Defines.inc}
unit DeHL.Singleton;
interface
uses DeHL.Base,
     DeHL.Types,
     DeHL.Collections.Dictionary;

var
  ///  <summary>An internal dictionary. Do not modify in any circumstances!</summary>
  __DeHL__Singleton: TDictionary<Pointer, TObject>;

type
  ///  <summary>A static singleton container.</summary>
  ///  <remarks>This type is not designed to be used as a value. It is designed to expose
  ///  a single property that allows access to the object that needs to act as a singleton. The normal use case
  ///  would look something like <c>Singleton&lt;TFoo&gt;.Instance.Bar();</c></remarks>
  Singleton<T: class, constructor> = record
  private class var
    FObject: T;

    { Class constructor }
    class constructor Create;
  public
    ///  <summary>Returns the singleton instance of the given <c>T</c> type</summary>
    ///  <returns>An instance to an object that is created a single time during the application lifetime.</returns>
    ///  <remarks>The class of type <c>T</c> must define a default parameterless constructor that will be invoked when
    ///  the instance of that class is created. Also note that the class should not depend on the initialization order of units,
    ///  since there is no predictable order in which the singleton instance is created.</remarks>
    class property Instance: T read FObject;
  end;

implementation

{ Singleton<T> }

class constructor Singleton<T>.Create;
var
  LTypeInfo: Pointer;
begin
  LTypeInfo := TType<Singleton<T>>.Default.TypeInfo;

  { Use the global dictionary to store/find the objects }
  if not __DeHL__Singleton.TryGetValue(LTypeInfo, TObject(FObject)) then
  begin
    FObject := T.Create();
    __DeHL__Singleton.Add(LTypeInfo, TObject(FObject));
  end;
end;

initialization
  { Initialize the specialized dictionary with class aouto-cleanup option }
  __DeHL__Singleton := TDictionary<Pointer, TObject>.Create(TType<Pointer>.Standard, TClassType<TObject>.Create(true));

finalization
  { Free the dictionary, and it will free all created objects with it }
  __DeHL__Singleton.Free;

end.
