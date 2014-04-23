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
unit Tests.MathAlgorithms;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     DeHL.Types,
     DeHL.Collections.List,
     DeHL.Exceptions,
     DeHL.Math.Algorithms;

type
  TTestAlgorithms = class(TDeHLTestCase)
    procedure TestAccSum();
    procedure TestAccIntAvg();
    procedure TestAccDoubleAvg();
  end;

  TTestPrimes = class(TDeHLTestCase)
  published
    procedure TestIsPrime;
    procedure GetNearestProgressionPositive;
  end;


implementation

{ TTestAlgorithms }

procedure TTestAlgorithms.TestAccDoubleAvg;
const
  MaxNr = 100;

var
  AListFull, AListEmpty: TList<Double>;
  I: Integer;
  X, Sum, Avg: Double;

begin
  AListFull := TList<Double>.Create();
  AListEmpty := TList<Double>.Create();

  Sum := 0;

  for I := 0 to MaxNr - 1 do
  begin
    X := Random(MaxNr);
    Sum := Sum + X;
    AListFull.Add(X);
  end;

  Avg := Sum / MaxNr;

  Check(Accumulator.Average<Double>(AListFull, TType<Double>.Default) = Avg, '1. Accumulator.Average failed for Double');
  Check(Accumulator.Average<Double>(AListFull) = Avg, '2. Accumulator.Average failed for Integer');

  Check(Accumulator.Average<Double>(AListEmpty, TType<Double>.Default) = 0, '3. Accumulator.Average failed for Double');
  Check(Accumulator.Average<Double>(AListEmpty) = 0, '4. Accumulator.Average failed for Double');

  AListFull.Free;
  AListEmpty.Free;
end;

procedure TTestAlgorithms.TestAccIntAvg;
const
  MaxNr = 100;

var
  AListFull, AListEmpty: TList<Integer>;
  I, X, Sum, Avg: Integer;

begin
  AListFull := TList<Integer>.Create();
  AListEmpty := TList<Integer>.Create();

  Sum := 0;

  for I := 0 to MaxNr - 1 do
  begin
    X := Random(MaxNr);
    Sum := Sum + X;
    AListFull.Add(X);
  end;

  Avg := Sum div MaxNr;

  Check(Accumulator.Average<Integer>(AListFull, TType<Integer>.Default) = Avg, '1. Accumulator.Average failed for Integer');
  Check(Accumulator.Average<Integer>(AListFull) = Avg, '2. Accumulator.Average failed for Integer');

  Check(Accumulator.Average<Integer>(AListEmpty, TType<Integer>.Default) = 0, '3. Accumulator.Average failed for Integer');
  Check(Accumulator.Average<Integer>(AListEmpty) = 0, '4. Accumulator.Average failed for Integer');

  AListFull.Free;
  AListEmpty.Free;
end;

procedure TTestAlgorithms.TestAccSum;
const
  MaxNr = 100;

var
  AListFull, AListEmpty: TList<Integer>;
  I, X, Sum: Integer;

begin
  AListFull := TList<Integer>.Create();
  AListEmpty := TList<Integer>.Create();

  Sum := 0;

  for I := 0 to MaxNr - 1 do
  begin
    X := Random(MaxNr);
    Sum := Sum + X;
    AListFull.Add(X);
  end;

  Check(Accumulator.Sum<Integer>(AListFull, TType<Integer>.Default) = Sum, '1. Accumulator.Sum failed for Integer');
  Check(Accumulator.Sum<Integer>(AListFull) = Sum, '2. Accumulator.Sum failed for Integer');

  Check(Accumulator.Sum<Integer>(AListEmpty, TType<Integer>.Default) = 0, '3. Accumulator.Sum failed for Integer');
  Check(Accumulator.Sum<Integer>(AListEmpty) = 0, '4. Accumulator.Sum failed for Integer');

  AListFull.Free;
  AListEmpty.Free;
end;


{ TTestPrimes }

procedure TTestPrimes.TestIsPrime;
begin
  Check(not Prime.IsPrime(0), '0 must be prime!');
  Check(Prime.IsPrime(1), '1 must be prime!');
  Check(Prime.IsPrime(-1), '-1 must be prime!');
  Check(Prime.IsPrime(2), '2 must be prime!');
  Check(Prime.IsPrime(-2), '-2 must be prime!');
  Check(Prime.IsPrime(3), '3 must be prime!');
  Check(Prime.IsPrime(-3), '-3 must be prime!');
  Check(Prime.IsPrime(5), '5 must be prime!');
  Check(Prime.IsPrime(-5), '-5 must be prime!');
  Check(Prime.IsPrime(37), '37 must be prime!');
  Check(Prime.IsPrime(-37), '-37 must be prime!');

  Check(not Prime.IsPrime(4), '4 is not prime!');
  Check(not Prime.IsPrime(9), '9 is not prime!');
  Check(not Prime.IsPrime(-100), '-100 is not prime!');
end;

procedure TTestPrimes.GetNearestProgressionPositive;
const
  NrX = 108000;

var
  I, P : Integer;
begin

  for I := -NrX to NrX do
  begin
    P := Prime.GetNearestProgressionPositive(I);
    Check(P >= I, 'Prime size check failed at ' + IntToStr(I));

    if I < 0 then
       Check(P = 1, 'Negative values give 1 result for nearest prime.');
  end;

end;

initialization
  TestFramework.RegisterTest(TTestAlgorithms.Suite);
  TestFramework.RegisterTest(TTestPrimes.Suite);

end.
