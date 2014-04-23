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

{$I ../DeHL.Defines.inc}
unit DeHL.Parallel.Base;
interface
uses
  DeHL.Base,
  DeHL.Types,
  DeHL.Exceptions;

type
  { Accepts a pointer to user data and should return an exit code }
  TPoolWorkerMethod = function(): NativeInt of object;
  TPoolWorkerProc = reference to function(const AData: Pointer): NativeInt;

  { Represents a task that is running in the thread pool }
  IThreadPoolTask = interface
    { Result query }
    function IsWaiting: Boolean;
    function IsRunning: Boolean;
    function HasFinished: Boolean;
    function ResultCode: NativeInt;

    { Signals and related }
    function WaitForInfinite(): NativeInt; overload;
    function WaitFor(const ATimeOutMSec: NativeUInt; out AResultCode: NativeInt): Boolean; overload;

    { Cancels the current task }
    function Cancel(): NativeInt;

    { Terminates the task. This is a hard cancel! Do not use it }
    procedure Terminate;
  end;

  { Base pool interface }
  IThreadPool = interface
    { Queue and related }
    function EnqueueWorkItem(const AWorker: TPoolWorkerMethod): IThreadPoolTask; overload;
    function EnqueueWorkItem(const AWorker: TPoolWorkerProc; const AData: Pointer): IThreadPoolTask; overload;

    { Thread counts }
    function GetMaxThreadCount: NativeUInt;
    function GetThreadCount: NativeUInt;
    function GetIdleThreadCount: NativeUInt;
    function GetBusyThreadCount: NativeUInt;

    property MaxThreadCount: NativeUInt read GetMaxThreadCount;
    property ThreadCount: NativeUInt read GetThreadCount;
    property IdleThreadCount: NativeUInt read GetIdleThreadCount;
    property BusyThreadCount: NativeUInt read GetBusyThreadCount;
  end;

  { Basic thread pool }
  TTreadPool = class(TRefCountedObject, IThreadPool)
  private class var
    FPool: IThreadPool;

    class constructor Create();
    class destructor Destroy();
  private

  protected
    function GetMaxThreadCount: NativeUInt;
    function GetThreadCount: NativeUInt;
    function GetIdleThreadCount: NativeUInt;
    function GetBusyThreadCount: NativeUInt;

  public
    { Construction and destruction }
    constructor Create(); overload;
    constructor Create(const AMaxThreads: NativeUInt); overload;

    destructor Destroy(); override;

    { The work stuffz }
    function EnqueueWorkItem(const AWorker: TPoolWorkerMethod): IThreadPoolTask; overload;
    function EnqueueWorkItem(const AWorker: TPoolWorkerProc; const AData: Pointer): IThreadPoolTask; overload;

    { Properties }
    property MaxThreadCount: NativeUInt read GetMaxThreadCount;
    property ThreadCount: NativeUInt read GetThreadCount;
    property IdleThreadCount: NativeUInt read GetIdleThreadCount;
    property BusyThreadCount: NativeUInt read GetBusyThreadCount;

    { Globals }
    class property Global: IThreadPool read FPool;
  end;

implementation
uses SyncObjs;

type
  { Internal only }
  TThreadPoolTask = class(TRefCountedObject, IThreadPoolTask)
  public
    { Result query }
    function IsWaiting: Boolean;
    function IsRunning: Boolean;
    function HasFinished: Boolean;
    function ResultCode: NativeInt;

    { Signals and related }
    function WaitForInfinite(): NativeInt; overload;
    function WaitFor(const ATimeOutMSec: NativeUInt; out AResultCode: NativeInt): Boolean; overload;

    { Cancels the current task }
    function Cancel(): NativeInt;

    { Terminates the task. This is a hard cancel! Do not use it }
    procedure Terminate;
  end;


{ TThreadPoolTask }

function TThreadPoolTask.Cancel: NativeInt;
begin

end;

function TThreadPoolTask.HasFinished: Boolean;
begin

end;

function TThreadPoolTask.IsRunning: Boolean;
begin

end;

function TThreadPoolTask.IsWaiting: Boolean;
begin

end;

function TThreadPoolTask.ResultCode: NativeInt;
begin

end;

procedure TThreadPoolTask.Terminate;
begin

end;

function TThreadPoolTask.WaitFor(const ATimeOutMSec: NativeUInt;
  out AResultCode: NativeInt): Boolean;
begin

end;

function TThreadPoolTask.WaitForInfinite: NativeInt;
begin

end;


{ TTreadPool }

class constructor TTreadPool.Create;
begin
  { Create with default settings }
  FPool := TTreadPool.Create();
end;

constructor TTreadPool.Create;
begin

end;

constructor TTreadPool.Create(const AMaxThreads: NativeUInt);
begin

end;

class destructor TTreadPool.Destroy;
begin
  FPool := nil;
end;

destructor TTreadPool.Destroy;
begin

  inherited;
end;

function TTreadPool.EnqueueWorkItem(const AWorker: TPoolWorkerMethod): IThreadPoolTask;
begin

end;

function TTreadPool.EnqueueWorkItem(const AWorker: TPoolWorkerProc; const AData: Pointer): IThreadPoolTask;
begin

end;

function TTreadPool.GetBusyThreadCount: NativeUInt;
begin

end;

function TTreadPool.GetIdleThreadCount: NativeUInt;
begin

end;

function TTreadPool.GetMaxThreadCount: NativeUInt;
begin

end;

function TTreadPool.GetThreadCount: NativeUInt;
begin

end;

end.
