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

{$I ../DeHL.Defines.inc}
unit DeHL.Parallel.Future;
interface
uses
  SysUtils,
  DeHL.Base,
  DeHL.Types,
  DeHL.Parallel.Base,
  DeHL.Exceptions;

type
  { The procedure executed by a "future" object }
  TFutureProc<T> = reference to function(): T;

  { The future evaluator }
  TFuture<T> = record
  private type
    TFutureInternal = class(TRefCountedObject)
    private
      FTask: IThreadPoolTask;
      FProc: TFutureProc<T>;
      FResult: T;
      FExcClass: TClass;
      FExcMsg: string;

      function ThreadedCall(): NativeInt;
    end;

  private
    FMarker: IInterface;
    FObj: TFutureInternal;

    function GetFutureResult: T;
  public
    { Constructor, should be invoked when the calculation should be done }
    constructor Create(const AProc: TFutureProc<T>);

    { Result property }
    property Value: T read GetFutureResult;
  end;

implementation

{ TFuture<T> }

constructor TFuture<T>.Create(const AProc: TFutureProc<T>);
begin
  if not Assigned(AProc) then
    ExceptionHelper.Throw_ArgumentNilError('AProc');

  { Initialize this future }
  FObj := TFutureInternal.Create();
  FObj.FTask := TTreadPool.Global.EnqueueWorkItem(FObj.ThreadedCall);
  FMarker := FObj;
end;

function TFuture<T>.GetFutureResult: T;
var
  LTask: IThreadPoolTask;
begin
  { Check params }
  if not Assigned(FMarker) then
    ExceptionHelper.Throw_NullValueRequested();

  { If no task is assigned, it means the evaluation finished. Return the result directly. }
  if FObj.FTask <> nil then
  begin
    { Move the task reference into local scope so that after the execution of this
      method, the thread pool task is released back to the pool for reusal. Use a bit of
      a Pointer hack to avoid unnecessary add/release ref calls }
    Pointer(LTask) := Pointer(FObj.FTask);
    Pointer(FObj.FTask) := nil;

    { Wait for the task to complete. If we returned -1, it means we're screwed. }
    if LTask.WaitForInfinite() = -1 then
      ExceptionHelper.Throw_FutureException(FObj.FExcClass.ClassName, FObj.FExcMsg);
  end;

  { The result! }
  Result := FObj.FResult;
end;

function TFuture<T>.TFutureInternal.ThreadedCall(): NativeInt;
begin
  Result := 0; // All OK

  { Call the delegated function here }
  try
    FResult := FProc();
  except
    on E: Exception do
    begin
      Result := -1; // Failed with exception
      FExcClass := E.ClassType;
      FExcMsg := E.Message;
    end;
  end;
end;

end.
