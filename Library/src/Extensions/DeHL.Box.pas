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
unit DeHL.Box;
interface
uses
  SysUtils,
  DeHL.Base,
  DeHL.Cloning,
  DeHL.Types,
  DeHL.StrConsts,
  DeHL.Serialization,
  DeHL.Exceptions;

type
  ///  <summary>Defines basic type-agnostic traits that are shared across all objects that implement the boxing concept.</summary>
  IBox = interface
    ///  <summary>Verifies whether the box contains a value.</summary>
    ///  <returns><c>True</c> if the box contains a value; <c>False</c> otherwise.</returns>
    ///  <remarks>A box is only "valid" if it contains a value. Trying to retreive a value from an "invalid" box
    ///  results in an exception (or undefined behavior).</remarks>
    function HasBoxedValue(): Boolean;

    ///  <summary>Compares the value in the box object to the value in another box object.</summary>
    ///  <param name="Obj">The instance to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - the value is less than <paramref name="Obj"/>. If the result is zero -
    ///  the value is equal to <paramref name="Obj"/>. And finally, if the result is greater than zero - the value is greater
    ///  than <paramref name="Obj"/>.</returns>
    function CompareTo(Obj: TObject): Integer; overload;

    ///  <summary>Checks the value in the box object for eqaulity with the value in another box object.</summary>
    ///  <param name="Obj">The instance to compare against.</param>
    ///  <returns><c>True</c> is the values in both boxes are equal; <c>False</c> otherwise.</returns>
    function Equals(Obj: TObject): Boolean; overload;

    ///  <summary>Calculates the hash code of the boxed value.</summary>
    ///  <returns>An <c>integer</c> value specifying the value's hash code.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    function GetHashCode(): Integer;

    ///  <summary>Generates the string representation of the boxed value.</summary>
    ///  <returns>An <c>string</c> value.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    function ToString(): String;
  end;

  ///  <summary>Defines basic type-dependant traits that are shared across all objects that implement the boxing concept.</summary>
  IBox<T> = interface(IBox)
    ///  <summary>Tries to retrieve the boxed value without emptying the box.</summary>
    ///  <param name="AValue">The value stored in the box if the operation succeeds; undefined value otherwise.</param>
    ///  <returns><c>True</c> if the box is non-empty and the value was retreived. <c>False</c> is returned if the box
    ///  is empty and the value was not retreived.</returns>
    function TryPeek(out AValue: T): Boolean;

    ///  <summary>Retreives the boxed value without emptying the box.</summary>
    ///  <returns>The boxed value.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    function Peek(): T;

    ///  <summary>Tries to retreive the boxed value and empties the box.</summary>
    ///  <param name="AValue">The value stored in the box if the operation succeeds; undefined value otherwise.</param>
    ///  <returns><c>True</c> if the box was non-empty and the value was retreived. <c>False</c> is returned if the box
    ///  is already empty and the value was not retreived.</returns>
    ///  <remarks>If this operation succeded, the box is marked as empty and all subsequent operations on it may fail.</remarks>
    function TryUnbox(out AValue: T): Boolean;

    ///  <summary>Retreives the boxed value and empties the box.</summary>
    ///  <returns>The boxed value.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    function Unbox(): T;

    ///  <summary>Compares the value in the box to another value.</summary>
    ///  <param name="Value">The value to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - the boxed value is less than <paramref name="Value"/>. If the result is zero -
    ///  the boxed value is equal to <paramref name="Value"/>. And finally, if the result is greater than zero - the boxed value is greater
    ///  than <paramref name="Value"/>.</returns>
    function CompareTo(Value: T): Integer; overload;

    ///  <summary>Checks whether the boxed balue value is equal to another value.</summary>
    ///  <param name="Value">The value to compare against.</param>
    ///  <returns><c>True</c> is the values are equal; <c>False</c> otherwise.</returns>
    function Equals(Value: T): Boolean; overload;
  end;

  ///  <summary>Base for all box implementations.</summary>
  ///  <remarks>This class is not generic and only exposes the methods that do not
  ///  require compile-time knowledge about the actual type the box is storing.</remarks>
  TBox = class abstract(TRefCountedObject, IBox, IComparable, ISerializable, ICloneable)
  protected
    ///  <summary>Called by the serialization process when the box is serialized.</summary>
    ///  <remarks>This method is expected to be implemented in descending classes.</remarks>
    ///  <param name="AData">The serialization data block.</param>
    procedure Serialize(const AData: TSerializationData); virtual; abstract;

    ///  <summary>Called by the deserialization process when the box needs to be deserialized.</summary>
    ///  <remarks>This method is expected to be implemented in descending classes.</remarks>
    ///  <param name="AData">The deserialization data block.</param>
    procedure Deserialize(const AData: TDeserializationData); virtual; abstract;
  public
    ///  <summary>Verifies whether the box contains a value.</summary>
    ///  <returns><c>True</c> if the box contains a value; <c>False</c> otherwise.</returns>
    ///  <remarks>A box is only "valid" if it contains a value. Trying to retreive a value from an "invalid" box
    ///  results in <see cref="DeHL.Exceptions|EEmptyBoxException">DeHL.Exceptions.EEmptyBoxException</see> being thrown.</remarks>
    function HasBoxedValue(): Boolean; virtual; abstract;

    ///  <summary>Compares the value in the this box to the value in another (compatible) box.</summary>
    ///  <param name="Obj">The box to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - the value is less than <paramref name="Obj"/>. If the result is zero -
    ///  the value is equal to <paramref name="Obj"/>. And finally, if the result is greater than zero - the value is greater
    ///  than <paramref name="Obj"/>.</returns>
    ///  <remarks>This method is expected to be implemented in descending classes.</remarks>
    function CompareTo(Obj: TObject): Integer; virtual; abstract;

    ///  <summary>Creates an exact copy of this box.</summary>
    ///  <returns>Another box that stores the same value as this box.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">This box is empty.</exception>
    ///  <remarks>This method is expected to be implemented in descending classes.</remarks>
    function Clone(): TObject; virtual; abstract;
  end;

  ///  <summary>Stores any value (primitives, classes, interfaces, etc.).</summary>
  ///  <remarks>This class can be used to store any value. It becomes useful when an object is required
  ///  but the values operated upon are not objects. For an example consult
  ///  <see cref="DeHL.Collections.Interop|TStringList&lt;T&gt;">DeHL.Collections.Interop.TStringList&lt;T&gt;</see> which derives
  ///  from the standard RTL <c>TStringList</c> but allows pairing strings with any value, not just objects.</remarks>
  TBox<T> = class sealed(TBox, IBox<T>, IComparable<T>, IEquatable<T>)
  private
    FValue: T;
    FIsBoxed: Boolean;
    FType: IType<T>;

  protected
    ///  <summary>Called by the serialization process when the box is serialized.</summary>
    ///  <param name="AData">The serialization data block.</param>
    procedure Serialize(const AData: TSerializationData); override;

    ///  <summary>Called by the deserialization process when the box needs to be deserialized.</summary>
    ///  <param name="AData">The deserialization data block.</param>
    procedure Deserialize(const AData: TDeserializationData); override;

  public
    ///  <summary>Creates an instance of <see cref="DeHL.Box|TBox&lt;T&gt;">DeHL.Box.TBox&lt;T&gt;</see> class.</summary>
    ///  <param name="AType">The type object describing the stored value.</param>
    ///  <param name="AValue">The initial (and the only) value of the box.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> in <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AValue: T); overload;

    ///  <summary>Creates an instance of <see cref="DeHL.Box|TBox&lt;T&gt;">DeHL.Box.TBox&lt;T&gt;</see> class.</summary>
    ///  <param name="AValue">The initial (and the only) value of the box.</param>
    ///  <remarks>If the caller requires to create a large number of boxes, it must use the contructor that accepts the
    ///  <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> as the first parameter. This is due to the fact
    ///  that this contructor will request a new type object each time it is invoked, thus slowing things down a bit.</remarks>
    constructor Create(const AValue: T); overload;

    ///  <summary>Creates an instance of <see cref="DeHL.Box|TBox&lt;T&gt;">DeHL.Box.TBox&lt;T&gt;</see> class.</summary>
    ///  <param name="AType">The type object describing the stored value.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> in <c>nil</c>.</exception>
    ///  <remarks>The box is created non-empty. The stored value is the default value for the given generic argument
    /// (ex. <c>0</c> for <c>Integer</c>).</remarks>
    constructor Create(const AType: IType<T>); overload;

    ///  <summary>Creates an instance of <see cref="DeHL.Box|TBox&lt;T&gt;">DeHL.Box.TBox&lt;T&gt;</see> class.</summary>
    ///  <remarks>The box is created non-empty. The stored value is the default value for the given generic argument
    /// (ex. <c>0</c> for <c>Integer</c>).</remarks>
    constructor Create(); overload;

    ///  <summary>Verifies whether the box contains a value.</summary>
    ///  <returns><c>True</c> if the box contains a value; <c>False</c> otherwise.</returns>
    ///  <remarks>A box is only "valid" if it contains a value. Trying to retreive a value from an "invalid" box
    ///  results in <see cref="DeHL.Exceptions|EEmptyBoxException">DeHL.Exceptions.EEmptyBoxException</see> being thrown.</remarks>
    function HasBoxedValue(): Boolean; override;

    ///  <summary>Tries to retrieve the boxed value without emptying the box.</summary>
    ///  <param name="AValue">The value stored in the box if the operation succeeds; undefined value otherwise.</param>
    ///  <returns><c>True</c> if the box is non-empty and the value was retreived. <c>False</c> is returned if the box
    ///  is empty and the value was not retreived.</returns>
    function TryPeek(out AValue: T): Boolean; inline;

    ///  <summary>Retreives the boxed value without emptying the box.</summary>
    ///  <returns>The boxed value.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The is empty.</exception>
    function Peek(): T; inline;

    ///  <summary>Tries to retreive the boxed value and empties the box.</summary>
    ///  <param name="AValue">The value stored in the box if the operation succeeds; undefined value otherwise.</param>
    ///  <returns><c>True</c> if the box was non-empty and the value was retreived. <c>False</c> is returned if the box
    ///  is already empty and the value was not retreived.</returns>
    ///  <remarks>If this operation succeded, the box is marked as empty and all subsequent operations on it may fail.</remarks>
    function TryUnbox(out AValue: T): Boolean; inline;

    ///  <summary>Retreives the boxed value and empties the box.</summary>
    ///  <returns>The boxed value.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    ///  <remarks>After the call to this method, the box is marked as empty and all subsequent operations on it may fail.</remarks>
    function Unbox(): T; inline;

    ///  <summary>Retreives the boxed value and frees this box object.</summary>
    ///  <returns>The boxed value.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    ///  <remarks>If an exception is thrown, the box is not freed.</remarks>
    function UnboxAndFree(): T; inline;

    ///  <summary>Compares the value in the this box to the value in another (compatible) box.</summary>
    ///  <param name="Obj">The box to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - the value is less than <paramref name="Obj"/>. If the result is zero -
    ///  the value is equal to <paramref name="Obj"/>. And finally, if the result is greater than zero - the value is greater
    ///  than <paramref name="Obj"/>.</returns>
    ///  <remarks>The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that describes the stored value
    ///  is used to perform this operation.</remarks>
    function CompareTo(Obj: TObject): Integer; overload; override;

    ///  <summary>Compares the value in the box to another value.</summary>
    ///  <param name="Value">The value to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - the boxed value is less than <paramref name="Value"/>. If the result is zero -
    ///  the boxed value is equal to <paramref name="Value"/>. And finally, if the result is greater than zero - the boxed value is greater
    ///  than <paramref name="Value"/>.</returns>
    ///  <remarks>The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that describes the stored value
    ///  is used to perform this operation.</remarks>
    function CompareTo(Value: T): Integer; reintroduce; overload; inline;

    ///  <summary>Checks whether the boxed balue value is equal to another value.</summary>
    ///  <param name="Value">The value to compare against.</param>
    ///  <returns><c>True</c> is the values are equal; <c>False</c> otherwise.</returns>
    ///  <remarks>The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that describes the stored value
    ///  is used to perform this operation.</remarks>
    function Equals(Value: T): Boolean; reintroduce; overload; inline;

    ///  <summary>Checks the value in the box object for eqaulity with the value in another box object.</summary>
    ///  <param name="Obj">The instance to compare against.</param>
    ///  <returns><c>True</c> is the values in both boxes are equal; <c>False</c> otherwise.</returns>
    ///  <remarks>The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that describes the stored value
    ///  is used to perform this operation.</remarks>
    function Equals(Obj: TObject): Boolean; overload; override;

    ///  <summary>Calculates the hash code of the boxed value.</summary>
    ///  <returns>An <c>integer</c> value specifying the value's hash code.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    ///  <remarks>The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that describes the stored value
    ///  is used to perform this operation.</remarks>
    function GetHashCode(): Integer; override;

    ///  <summary>Generates the string representation of the boxed value.</summary>
    ///  <returns>An <c>string</c> value.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">The box is empty.</exception>
    ///  <remarks>The <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that describes the stored value
    ///  is used to perform this operation.</remarks>
    function ToString(): String; override;

    ///  <summary>Creates an exact copy of this box.</summary>
    ///  <returns>Another box that stores the same value as this box.</returns>
    ///  <exception cref="DeHL.Exceptions|EEmptyBoxException">This box is empty.</exception>
    function Clone(): TObject; override;

    ///  <summary>Destroys the current instance.</summary>
    ///  <remarks>Do not call this method directly; call <see cref="System.TObject.Free">System.TObject.Free</see> instead.</remarks>
    destructor Destroy(); override;
  end;

implementation

{ TBox<T> }

constructor TBox<T>.Create(const AValue: T);
begin
  { Call upper constructor }
  Create(TType<T>.Default, AValue);
end;

function TBox<T>.Clone: TObject;
begin
  { Clone me! }
  Result := TBox<T>.Create(FType, FValue);
  TBox<T>(Result).FIsBoxed := FIsBoxed;
end;

function TBox<T>.CompareTo(Value: T): Integer;
begin
  { Use the provided type class }
  if not FIsBoxed then
    Result := 1
  else
    Result := FType.Compare(FValue, Value);
end;

function TBox<T>.CompareTo(Obj: TObject): Integer;
begin
  if Self = Obj then
    Result := 0
  else if (Obj = nil) or not Obj.InheritsFrom(Self.ClassType) or
    not FIsBoxed or not (TBox<T>(Obj).FIsBoxed) then
    Result := 1
  else
    Result := FType.Compare(FValue, TBox<T>(Obj).FValue);
end;

constructor TBox<T>.Create;
begin
  { Call upper constructor }
  Create(TType<T>.Default, default(T));
end;

constructor TBox<T>.Create(const AType: IType<T>; const AValue: T);
begin
  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Copy the value in }
  FValue := AValue;
  FIsBoxed := true;
  FType := AType;
end;

constructor TBox<T>.Create(const AType: IType<T>);
begin
  { Call upper constructor }
  Create(AType, default(T));
end;

procedure TBox<T>.Deserialize(const AData: TDeserializationData);
var
  LValueInfo: TValueInfo;
begin
  LValueInfo := TValueInfo.Create(SSerValue);

  { Restore the Type }
  FType := TType<T>.Default;

  { Get the "boxed" flag }
  AData.GetValue(SIsDefined, FIsBoxed);

  { Deserialize if required }
  if FIsBoxed then
    FType.Deserialize(SSerValue, FValue, AData);
end;

destructor TBox<T>.Destroy;
begin
  { If the value is still boxed in, clean it up on destruction }
  if (FIsBoxed) and (FType <> nil) and (FType.Management = tmManual) then
    FType.Cleanup(FValue);

  inherited;
end;

function TBox<T>.Equals(Value: T): Boolean;
begin
  Result := FIsBoxed and FType.AreEqual(FValue, Value);
end;

function TBox<T>.Equals(Obj: TObject): Boolean;
begin
  if Self = Obj then
    Result := True
  else if Obj = nil then
    Result := False
  else if not Obj.InheritsFrom(Self.ClassType) then
    Result := False
  else
    Result := FIsBoxed and (TBox<T>(Obj).FIsBoxed) and
      FType.AreEqual(FValue, TBox<T>(Obj).FValue);
end;

function TBox<T>.GetHashCode: Integer;
begin
  { Verify that we actually have a boxed value }
  if not FIsBoxed then
    ExceptionHelper.Throw_TheBoxIsEmpty();

  { Use the provided type class }
  Result := FType.GenerateHashCode(FValue);
end;

function TBox<T>.HasBoxedValue: Boolean;
begin
  Result := FIsBoxed;
end;

function TBox<T>.Peek: T;
begin
  { Verify that we actually have a boxed value }
  if not FIsBoxed then
    ExceptionHelper.Throw_TheBoxIsEmpty();

  { Only peek, but do not unbox the value }
  Result := FValue;
end;

procedure TBox<T>.Serialize(const AData: TSerializationData);
begin
  { Only serialize the value if it is set }
  AData.AddValue(SIsDefined, FIsBoxed);

  { Write the value down }
  if FIsBoxed then
    FType.Serialize(SSerValue, FValue, AData)
  else
    FType.Serialize(SSerValue, default(T), AData);
end;

function TBox<T>.ToString: string;
begin
  { Verify that we actually have a boxed value }
  if not FIsBoxed then
    ExceptionHelper.Throw_TheBoxIsEmpty();

  { Use the provided type class }
  Result := FType.GetString(FValue);
end;

function TBox<T>.TryPeek(out AValue: T): Boolean;
begin
  { Return the value and verify that it is boxed }
  Result := FIsBoxed;

  if Result then
    AValue := FValue;
end;

function TBox<T>.TryUnbox(out AValue: T): Boolean;
begin
  { Peek the value}
  Result := TryPeek(AValue);

  { Mark as unboxed }
  FIsBoxed := false;
end;

function TBox<T>.Unbox: T;
begin
  { Return the value by peeking }
  Result := Peek();

  { Mark this instance as used }
  FIsBoxed := false;
end;

function TBox<T>.UnboxAndFree: T;
begin
  { Grab the value by unboxing it }
  Result := Unbox();

  { And free the instance }
  Destroy();
end;

end.
