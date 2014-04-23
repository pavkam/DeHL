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
unit DeHL.Bytes;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.StrConsts,
     DeHL.Types,
     DeHL.Exceptions,
     DeHL.Cloning,
     DeHL.Serialization,
     DeHL.Collections.Base;

type
  ///  <summary>Stores a buffer of bytes and allows various operations to be performed on them.</summary>
  TBuffer = record
  private const
    CEmpty = RawByteString('');

  private type
    { The enumerator object }
    TEnumerator = class(TEnumerator<Byte>)
    private
      FBytes: RawByteString;
      FIndex: NativeInt;
      FCurrent: Byte;
    public
      { Constructor }
      constructor Create(const ABytes: RawByteString);

      function GetCurrent(): Byte; override;
      function MoveNext(): Boolean; override;
    end;

    TEnumerable = class(TEnexCollection<Byte>)
    private
      FBytes: RawByteString;

    protected
      { Implement to support count of elements }
      function GetCount(): NativeUInt; override;

    public
      { The constructor }
      constructor Create(const ABytes: RawByteString);

      { IEnumerable<T> }
      function GetEnumerator(): IEnumerator<Byte>; override;

      { Checks whether a collection is empty }
      function Empty(): Boolean; override;

      { Other Enex stuffz }
      function First(): Byte; override;
      function FirstOrDefault(const ADefault: Byte): Byte; override;
      function Last(): Byte; override;
      function LastOrDefault(const ADefault: Byte): Byte; override;
      function ElementAt(const Index: NativeUInt): Byte; override;
      function ElementAtOrDefault(const Index: NativeUInt; const ADefault: Byte): Byte; override;

      { Implement to support copy }
      procedure CopyTo(var AArray: array of Byte; const StartIndex: NativeUInt); override;
    end;

    class constructor Create;
    class destructor Destroy;

    class function GetEmpty: TBuffer; static; inline;
  private
    [CloneKind(ckReference)]
    FBytes: RawByteString;

    { Internals }
    function GetByte(const AIndex: NativeInt): Byte; inline;
    procedure SetByte(const AIndex: NativeInt; const AByte: Byte); inline;
    function GetLength: NativeUInt; inline;
    function GetIsEmpty: Boolean; inline;
    function GetFirstByteRef: PByte; inline;
  public
    ///  <summary>Creates a byte buffer from the given byte array.</summary>
    ///  <param name="ABytes">The bytes to be copied into the buffer.</param>
    constructor Create(const ABytes: array of Byte); overload;

    ///  <summary>Creates a byte buffer from the given <c>RawByteString</c>.</summary>
    ///  <param name="ARawString">The <c>RawByteString</c> to be copied into the buffer.</param>
    ///  <remarks>The contents of the string are interpreted as char to byte relationship. This means that
    ///  each charater in the string is copied into the buffer as its byte representation.</remarks>
    constructor Create(const ARawString: RawByteString); overload;

    ///  <summary>Returns an enumerator that can be used to traverse the buffer.</summary>
    ///  <returns>A <see cref="DeHL.Base|IEnumerator&lt;T&gt;">DeHL.Base.IEnumerator&lt;T&gt;</see> interface.</returns>
    ///  <remarks>The generated enumerator does not raise any exceptions if the contents of the buffer are changed while enumerating.
    ///  Actually the enumeration will continue on the unchanged contents.</remarks>
    function GetEnumerator(): IEnumerator<Byte>;

    ///  <summary>Returns a collection object that represents this buffer.</summary>
    ///  <remarks>A new collection is created each time you call this method.</remarks>
    ///  <returns>An <see cref="DeHL.Collections.Base|IEnexCollection&lt;T&gt;">DeHL.Collections.Base.IEnexCollection&lt;T&gt;</see>
    ///  representing the bytes in the buffer.</returns>
    function AsCollection(): IEnexCollection<Byte>;

    ///  <summary>Returns the number of bytes in the buffer.</summary>
    ///  <returns>The number of bytes in the buffer.</returns>
    property Length: NativeUInt read GetLength;

    ///  <summary>Default indexed property.</summary>
    ///  <param name="AIndex">The index from which to read or write the byte.</param>
    ///  <returns>The byte at the specified index.</returns>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="Index"/> is out of bounds.</exception>
    property Bytes[const AIndex: NativeInt]: Byte read GetByte write SetByte; default;

    ///  <summary>Checks whether the buffer is empty.</summary>
    ///  <returns><c>True</c> is the buffer is empty; <c>False</c> otherwise.</returns>
    property IsEmpty: Boolean read GetIsEmpty;

    ///  <summary>Returns the address of the first byte in the buffer.</summary>
    ///  <returns>A <c>PByte</c> value that references the firt byte in the buffer.</returns>
    ///  <remarks>When read, this property ensures that copy-on-write is performed on the buffer. A caller can
    ///  use the value of this property safely to perform direct memory manipulations.</remarks>
    property Ref: PByte read GetFirstByteRef;

    ///  <summary>Converts the buffer to a <c>RawByteString</c>.</summary>
    ///  <returns>A <c>RawByteString</c> value in which each character is byte in from this buffer.</returns>
    function ToRawByteString(): RawByteString; inline;

    ///  <summary>Converts the buffer to a <c>TBytes</c> array.</summary>
    ///  <returns>A <c>TBytes</c> value containing the bytes from this buffer.</returns>
    function ToBytes(): TBytes; inline;

    ///  <summary>Checks whether the buffer contains another buffer.</summary>
    ///  <param name="AWhat">The buffer to search for.</param>
    ///  <returns><c>True</c> if the buffer contains the given value; <c>False</c> otherwise.</returns>
    function Contains(const AWhat: TBuffer): Boolean; overload; inline;

    ///  <summary>Checks whether the buffer contains a byte.</summary>
    ///  <param name="AWhat">The byte to search for.</param>
    ///  <returns><c>True</c> if the buffer contains the given value; <c>False</c> otherwise.</returns>
    function Contains(const AWhat: Byte): Boolean; overload; inline;

    ///  <summary>Checks whether the buffer contains a <c>RawByteString</c>.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to search for.</param>
    ///  <returns><c>True</c> if the buffer contains the given value; <c>False</c> otherwise.</returns>
    function Contains(const AWhat: RawByteString): Boolean; overload; inline;

    ///  <summary>Finds the index of a buffer in this buffer.</summary>
    ///  <param name="AWhat">The buffer to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value, indicating the index at which
    ///  the value was found.</returns>
    function IndexOf(const AWhat: TBuffer): NativeInt; overload; inline;

    ///  <summary>Finds the index of a byte in this buffer.</summary>
    ///  <param name="AWhat">The byte to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value, indicating the index at which
    ///  the value was found.</returns>
    function IndexOf(const AWhat: Byte): NativeInt; overload;

    ///  <summary>Finds the index of a <c>RawByteString</c> in this buffer.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value, indicating the index at which
    ///  the value was found.</returns>
    function IndexOf(const AWhat: RawByteString): NativeInt; overload;

    ///  <summary>Finds the index of the last appearance of a buffer in this buffer.</summary>
    ///  <param name="AWhat">The buffer to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value, indicating the index at which
    ///  the value was found.</returns> }
    function LastIndexOf(const AWhat: TBuffer): NativeInt; overload; inline;

    ///  <summary>Finds the index of the last appearance of a byte in this buffer.</summary>
    ///  <param name="AWhat">The byte to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value, indicating the index at which
    ///  the value was found.</returns>
    function LastIndexOf(const AWhat: Byte): NativeInt; overload; inline;

    ///  <summary>Finds the index of the last appearance of a <c>RawByteString</c> in this buffer.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to search for.</param>
    ///  <returns><c>-1</c> if the value was not found; otherwise a positive value, indicating the index at which
    ///  the value was found.</returns>
    function LastIndexOf(const AWhat: RawByteString): NativeInt; overload; inline;

    ///  <summary>Checks whether the buffer starts with another buffer.</summary>
    ///  <param name="AWhat">The buffer to search for.</param>
    ///  <returns><c>True</c> if the buffer starts with the given value; <c>False</c> otherwise.</returns>
    function StartsWith(const AWhat: TBuffer): Boolean; overload; inline;

    ///  <summary>Checks whether the buffer starts with a byte.</summary>
    ///  <param name="AWhat">The byte to search for.</param>
    ///  <returns><c>True</c> if the buffer starts with the given value; <c>False</c> otherwise.</returns>
    function StartsWith(const AWhat: Byte): Boolean; overload; inline;

    ///  <summary>Checks whether the buffer starts with a <c>RawByteString</c>.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to search for.</param>
    ///  <returns><c>True</c> if the buffer starts with the given value; <c>False</c> otherwise.</returns>
    function StartsWith(const AWhat: RawByteString): Boolean; overload; inline;

    ///  <summary>Checks whether the buffer ends with another buffer.</summary>
    ///  <param name="AWhat">The buffer to search for.</param>
    ///  <returns><c>True</c> if the buffer ends with the given value; <c>False</c> otherwise.</returns>
    function EndsWith(const AWhat: TBuffer): Boolean; overload; inline;

    ///  <summary>Checks whether the buffer ends with a byte.</summary>
    ///  <param name="AWhat">The byte to search for.</param>
    ///  <returns><c>True</c> if the buffer ends with the given value; <c>False</c> otherwise.</returns>
    function EndsWith(const AWhat: Byte): Boolean; overload; inline;

    ///  <summary>Checks whether the buffer ends with a <c>RawByteString</c>.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to search for.</param>
    ///  <returns><c>True</c> if the buffer ends with the given value; <c>False</c> otherwise.</returns>
    function EndsWith(const AWhat: RawByteString): Boolean; overload; inline;

    ///  <summary>Copies a given number of bytes a new buffer.</summary>
    ///  <param name="AStart">The start index.</param>
    ///  <param name="ACount">The number of bytes.</param>
    ///  <returns>A <see cref="DeHL.Bytes|TBuffer">DeHL.Bytes.TBuffer</see> containing the copied bytes.</returns>
    ///  <remarks>This method copies <paramref name="ACount"/> bytes starting with <paramref name="AStart"/> index.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    function Copy(const AStart: NativeInt; const ACount: NativeUInt): TBuffer; overload;

    ///  <summary>Copies a given number of bytes a new buffer.</summary>
    ///  <param name="AStart">The start index.</param>
    ///  <returns>A <see cref="DeHL.Bytes|TBuffer">DeHL.Bytes.TBuffer</see> containing the copied bytes.</returns>
    ///  <remarks>This method copies all bytes starting with <paramref name="AStart"/> index.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStart"/> is out of bounds.</exception>
    function Copy(const AStart: NativeInt): TBuffer; overload;

    ///  <summary>Copies a given number of bytes to a a memory location.</summary>
    ///  <param name="ADestination">The destination address.</param>
    ///  <param name="AStart">The start index.</param>
    ///  <param name="ACount">The number of bytes.</param>
    ///  <remarks>This method copies <paramref name="ACount"/> bytes starting with <paramref name="AStart"/> index to the memory
    ///  location pointed to by <paramref name="ADestination"/>.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    procedure CopyTo(const ADestination: PByte; const AStart: NativeInt; const ACount: NativeUInt); overload;

    ///  <summary>Copies a given number of bytes to a a memory location.</summary>
    ///  <param name="ADestination">The destination address.</param>
    ///  <param name="AStart">The start index.</param>
    ///  <remarks>This method copies all bytes starting with <paramref name="AStart"/> index to the memory
    ///  location pointed to by <paramref name="ADestination"/>.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStart"/> is out of bounds.</exception>
    procedure CopyTo(const ADestination: PByte; const AStart: NativeInt); overload; inline;

    ///  <summary>Copies a given number of bytes to a a memory location.</summary>
    ///  <param name="ADestination">The destination address.</param>
    ///  <remarks>This method copies all bytes stored in the buffer to the memory
    ///  location pointed to by <paramref name="ADestination"/>.</remarks>
    procedure CopyTo(const ADestination: PByte); overload; inline;

    ///  <summary>Appends a buffer to this buffer.</summary>
    ///  <param name="AWhat">The buffer to append.</param>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Append(const AWhat: TBuffer); overload; inline;

    ///  <summary>Appends a <c>RawByteString</c> to this buffer.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to append.</param>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Append(const AWhat: RawByteString); overload; inline;

    ///  <summary>Appends a byte to this buffer.</summary>
    ///  <param name="AWhat">The byte to append.</param>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Append(const AWhat: Byte); overload; inline;

    ///  <summary>Inserts a buffer into this buffer.</summary>
    ///  <param name="AWhat">The buffer to insert.</param>
    ///  <param name="AIndex">The insertion index.</param>
    ///  <remarks>If the value of <paramref name="AIndex"/> is equal to the length of the buffer, the value is appended.
    ///  Copy-on-write is automatically invoked.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    procedure Insert(const AIndex: NativeInt; const AWhat: TBuffer); overload;

    ///  <summary>Inserts a <c>RawByteString</c> into this buffer.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to insert.</param>
    ///  <param name="AIndex">The insertion index.</param>
    ///  <remarks>If the value of <paramref name="AIndex"/> is equal to the length of the buffer, the value is appended.
    ///  Copy-on-write is automatically invoked.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    procedure Insert(const AIndex: NativeInt; const AWhat: RawByteString); overload;

    ///  <summary>Inserts a byte into this buffer.</summary>
    ///  <param name="AWhat">The byte to insert.</param>
    ///  <param name="AIndex">The insertion index.</param>
    ///  <remarks>If the value of <paramref name="AIndex"/> is equal to the length of the buffer, the value is appended.
    ///  Copy-on-write is automatically invoked.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AIndex"/> is out of bounds.</exception>
    procedure Insert(const AIndex: NativeInt; const AWhat: Byte); overload;

    ///  <summary>Replaces all encounters of a given value with another value.</summary>
    ///  <param name="AWhat">The byte to replace.</param>
    ///  <param name="AWith">The byte to replace with.</param>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Replace(const AWhat, AWith: Byte); overload;

    ///  <summary>Replaces all encounters of a given value with another value.</summary>
    ///  <param name="AWhat">The <c>RawByteString</c> to replace.</param>
    ///  <param name="AWith">The <c>RawByteString</c> to replace with.</param>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Replace(const AWhat, AWith: RawByteString); overload;

    ///  <summary>Replaces all encounters of a given value with another value.</summary>
    ///  <param name="AWhat">The buffer to replace.</param>
    ///  <param name="AWith">The buffer to replace with.</param>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Replace(const AWhat, AWith: TBuffer); overload;

    ///  <summary>Removes a part of the buffer.</summary>
    ///  <param name="AStart">The starting index.</param>
    ///  <param name="ACount">The number of bytes to remove.</param>
    ///  <remarks>This method removes <paramref name="ACount"/> bytes starting with <paramref name="AStart"/> index.
    ///  Copy-on-write is automatically invoked.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException">Parameter combination is incorrect.</exception>
    procedure Remove(const AStart: NativeInt; const ACount: NativeUInt); overload;

    ///  <summary>Removes a part of the buffer.</summary>
    ///  <param name="AStart">The starting index.</param>
    ///  <remarks>This method removes all bytes starting with <paramref name="AStart"/> index.
    ///  Copy-on-write is automatically invoked.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStart"/> is out of bounds.</exception>
    procedure Remove(const AStart: NativeInt); overload;

    ///  <summary>Reverses the buffer contents.</summary>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Reverse(); inline;

    ///  <summary>Clears the buffer setting its length to zero.</summary>
    ///  <remarks>Copy-on-write is automatically invoked.</remarks>
    procedure Clear(); inline;

    ///  <summary>Compares two buffers.</summary>
    ///  <param name="ALeft">The value to compare.</param>
    ///  <param name="ARight">The value to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - <paramref name="ALeft"/> is less than <paramref name="ARight"/>. If the result is zero -
    ///  <paramref name="ALeft"/> is equal to <paramref name="ARight"/>. And finally, if the result is greater than zero -
    ///  <paramref name="ALeft"/> is greater than <paramref name="ARight"/>.</returns>
    class function Compare(const ALeft, ARight: TBuffer): NativeInt; static;

    ///  <summary>Compares this buffer to another one.</summary>
    ///  <param name="ABuffer">The value to compare against.</param>
    ///  <returns>An integer value depicting the result of the comparison operation.
    ///  If the result is less than zero - this buffer is less than <paramref name="ABuffer"/>. If the result is zero -
    ///  this buffer is equal to <paramref name="ABuffer"/>. And finally, if the result is greater than zero -
    ///  this buffer is greater than <paramref name="ABuffer"/>.</returns>
    function CompareTo(const ABuffer: TBuffer): NativeInt; inline;

    ///  <summary>Checks two buffers for equality.</summary>
    ///  <param name="ALeft">First buffer.</param>
    ///  <param name="ARight">Second buffer.</param>
    ///  <returns><c>True</c> if the buffers are equal; <c>False</c> otherwise.</returns>
    class function Equal(const ALeft, ARight: TBuffer): Boolean; overload; static; inline;

    ///  <summary>Checks whether this buffer is equal to another buffer.</summary>
    ///  <param name="ABuffer">The buffer to compare with.</param>
    ///  <returns><c>True</c> if the buffers are equal; <c>False</c> otherwise.</returns>
    function EqualsWith(const ABuffer: TBuffer): Boolean; inline;

    ///  <summary>Returns an empty buffer.</summary>
    ///  <returns>A buffer that has no elements.</returns>
    class property Empty: TBuffer read GetEmpty;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ABuffer">A buffer.</param>
    ///  <returns>A <c>RawByteString</c> containing the bytes from buffer.</returns>
    class operator Implicit(const ABuffer: TBuffer): RawByteString; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ARawString">A <c>RawByteString</c>.</param>
    ///  <returns>A buffer containing the bytes from the <c>RawByteString</c>.</returns>
    class operator Implicit(const ARawString: RawByteString): TBuffer; inline;

    ///  <summary>Overloaded "Implicit" operator.</summary>
    ///  <param name="ABuffer">A buffer.</param>
    ///  <returns>A <c>Variant</c> array containing the bytes from the buffer.</returns>
    class operator Implicit(const ABuffer: TBuffer): Variant; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">A buffer.</param>
    ///  <param name="ARight">A buffer.</param>
    ///  <returns>A a new buffer containing the elements of both buffers.</returns>
    class operator Add(const ALeft, ARight: TBuffer): TBuffer; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">A buffer.</param>
    ///  <param name="ARight">A byte.</param>
    ///  <returns>A a new buffer containing the elements from the buffer with appended byte.</returns>
    class operator Add(const ALeft: TBuffer; const ARight: Byte): TBuffer; inline;

    ///  <summary>Overloaded "+" operator.</summary>
    ///  <param name="ALeft">A byte.</param>
    ///  <param name="ARight">A buffer.</param>
    ///  <returns>A a new buffer containing the elements from the buffer with prepended byte.</returns>
    class operator Add(const ALeft: Byte; const ARight: TBuffer): TBuffer; inline;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ALeft">A TBuffer.</param>
    ///  <param name="ARight">A buffer.</param>
    ///  <returns><c>True</c> if the buffers are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft: TBuffer; const ARight: TBuffer): Boolean; inline;

    ///  <summary>Overloaded "=" operator.</summary>
    ///  <param name="ALeft">A TBuffer.</param>
    ///  <param name="ARight">A buffer.</param>
    ///  <returns><c>True</c> if the buffers are not equal; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ALeft: TBuffer; const ARight: TBuffer): Boolean; inline;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents
    ///  <see cref="DeHL.Bytes|TBuffer">DeHL.Bytes.TBuffer</see> type.</returns>
    class function GetType(): IType<TBuffer>; static;
  end;


implementation
uses Variants;

type
  { TString type support }
  TBufferType = class sealed(TRecordType<TBuffer>)
  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: TBuffer; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: TBuffer; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: TBuffer): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: TBuffer): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: TBuffer): String; override;

    { Family override }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: TBuffer; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: TBuffer): Boolean; override;
  end;

{ TBuffer }

class operator TBuffer.Add(const ALeft: Byte; const ARight: TBuffer): TBuffer;
begin
  { Use Append }
  Result.FBytes := AnsiChar(ALeft);
  Result.Append(ARight.FBytes);
end;

class operator TBuffer.Add(const ALeft: TBuffer; const ARight: Byte): TBuffer;
begin
  { Use Append }
  Result.FBytes := ALeft.FBytes;
  Result.Append(ARight);
end;

class operator TBuffer.Add(const ALeft, ARight: TBuffer): TBuffer;
begin
  { Use Append }
  Result.FBytes := ALeft.FBytes;
  Result.Append(ARight.FBytes);
end;

procedure TBuffer.Append(const AWhat: RawByteString);
begin
  { Simple RTL string concat }
  FBytes := FBytes + AWhat;
end;

procedure TBuffer.Append(const AWhat: Byte);
begin
  { Simple RTL string concat }
  FBytes := FBytes + AnsiChar(AWhat);
end;

procedure TBuffer.Append(const AWhat: TBuffer);
begin
  { Simple RTL string concat }
  FBytes := FBytes + AWhat.FBytes;
end;

function TBuffer.AsCollection: IEnexCollection<Byte>;
begin
  { Create an enumerable object }
  Result := TEnumerable.Create(FBytes);
end;

procedure TBuffer.Clear;
begin
  { Simple as usual }
  FBytes := CEmpty;
end;

class function TBuffer.Compare(const ALeft, ARight: TBuffer): NativeInt;
var
  LL, LR: NativeInt;
begin
  LL := System.Length(ALeft.FBytes);
  LR := System.Length(ARight.FBytes);

  { Different lengths case }
  if LL <> LR then
    Exit(LL - LR);

  { Both are null and equal }
  if LL = 0 then
    Exit(0);

  { Actually compare this shit }
  Result := BinaryCompare(PAnsiChar(ALeft.FBytes), PAnsiChar(ARight.FBytes), LL);
end;

function TBuffer.CompareTo(const ABuffer: TBuffer): NativeInt;
begin
  { Call Compare }
  Result := Compare(Self, ABuffer);
end;

function TBuffer.Contains(const AWhat: Byte): Boolean;
begin
  { Call IndexOf }
  Result := IndexOf(AWhat) >= 0;
end;

function TBuffer.Contains(const AWhat: TBuffer): Boolean;
begin
  { Call IndexOf }
  Result := IndexOf(AWhat) >= 0;
end;

function TBuffer.Contains(const AWhat: RawByteString): Boolean;
begin
  { Call IndexOf }
  Result := IndexOf(AWhat) >= 0;
end;

function TBuffer.Copy(const AStart: NativeInt): TBuffer;
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + 1;
  LLength := System.Length(FBytes);

{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStart');
{$ENDIF}

  Result.FBytes := System.Copy(FBytes, LIndex, LLength);
end;

procedure TBuffer.CopyTo(const ADestination: PByte; const AStart: NativeInt; const ACount: NativeUInt);
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + 1;
  LLength := System.Length(FBytes);

{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStart');

  if (LIndex + NativeInt(ACount) - 1) > LLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');
{$ENDIF}

  Move(FBytes[LIndex], ADestination^, ACount);
end;

procedure TBuffer.CopyTo(const ADestination: PByte; const AStart: NativeInt);
begin
  { Call the better CopyTo }
  CopyTo(ADestination, AStart, System.Length(FBytes) - AStart);
end;

procedure TBuffer.CopyTo(const ADestination: PByte);
begin
  { Call the other CopyTo }
  CopyTo(ADestination, 0);
end;

function TBuffer.Copy(const AStart: NativeInt; const ACount: NativeUInt): TBuffer;
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + 1;
  LLength := System.Length(FBytes);

{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AStart');

  if (LIndex + NativeInt(ACount) - 1) > LLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');
{$ENDIF}

  Result.FBytes := System.Copy(FBytes, LIndex, ACount);
end;

class constructor TBuffer.Create;
begin
  { Register custom type }
  if not TType<TBuffer>.IsRegistered then
    TType<TBuffer>.Register(TBufferType);
end;

constructor TBuffer.Create(const ABytes: array of Byte);
var
  LByteLen: NativeInt;
begin
  { Set the length of the internal string }
  LByteLen := System.Length(ABytes);
  System.SetLength(FBytes, LByteLen);

  { And move the contents over }
  if LByteLen > 0 then
    Move(ABytes[0], FBytes[1], LByteLen);
end;

constructor TBuffer.Create(const ARawString: RawByteString);
begin
  { Simply assign. RTL will take care of uniquiness }
  FBytes := ARawString;
end;

class destructor TBuffer.Destroy;
begin
  { Unregister custom type }
  if TType<TBuffer>.IsRegistered then
    TType<TBuffer>.Unregister();
end;

function TBuffer.EndsWith(const AWhat: RawByteString): Boolean;
var
  LMyLen, LWhatLen: NativeInt;
begin
  LMyLen := System.Length(FBytes);
  LWhatLen := System.Length(AWhat);

  { Check if we should continue }
  if (LWhatLen > LMyLen) or (LMyLen = 0) or (LWhatLen = 0) then
    Exit(false);

  { Perform a binary comparison from the end }
  Result := BinaryCompare(PAnsiChar(FBytes) + LMyLen - LWhatLen, PAnsiChar(AWhat), LWhatLen) = 0;
end;

function TBuffer.EndsWith(const AWhat: Byte): Boolean;
var
  LLength: NativeInt;
begin
  LLength := System.Length(FBytes);

  { Siple byte check }
  Result := (LLength > 0) and (FBytes[LLength] = AnsiChar(AWhat));
end;

function TBuffer.EndsWith(const AWhat: TBuffer): Boolean;
begin
  { Call RawByteString version }
  Result := EndsWith(AWhat.FBytes);
end;

class operator TBuffer.Equal(const ALeft, ARight: TBuffer): Boolean;
begin
  { Use the comparison operation }
  Result := Compare(ALeft, ARight) = 0;
end;

class function TBuffer.Equal(const ALeft, ARight: TBuffer): Boolean;
begin
  { Use the comparison operation }
  Result := Compare(ALeft, ARight) = 0;
end;

function TBuffer.EqualsWith(const ABuffer: TBuffer): Boolean;
begin
  { Use the comparison operation }
  Result := Compare(Self, ABuffer) = 0;
end;

function TBuffer.GetByte(const AIndex: NativeInt): Byte;
var
  LIndex: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AIndex + 1;

  { Get the byte }
{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > System.Length(FBytes)) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
{$ENDIF}

  Result := Byte(FBytes[LIndex]);
end;

class function TBuffer.GetEmpty: TBuffer;
begin
  { That's quite it }
  Result.FBytes := CEmpty;
end;

function TBuffer.GetEnumerator: IEnumerator<Byte>;
begin
  { Create an enumerator object }
  Result := TEnumerator.Create(FBytes);
end;

function TBuffer.GetFirstByteRef: PByte;
begin
  UniqueString(AnsiString(FBytes));
  Result := PByte(PAnsiChar(FBytes));
end;

function TBuffer.GetIsEmpty: Boolean;
begin
  { Check for emptiness }
  Result := System.Length(FBytes) = 0;
end;

function TBuffer.GetLength: NativeUInt;
begin
  { Get the length }
  Result := System.Length(FBytes);
end;

class function TBuffer.GetType: IType<TBuffer>;
begin
  { Create and return the type instance }
  Result := TBufferType.Create();
end;

class operator TBuffer.Implicit(const ABuffer: TBuffer): RawByteString;
begin
  { Return the internal raw byte string }
  Result := ABuffer.FBytes;
end;

class operator TBuffer.Implicit(const ABuffer: TBuffer): Variant;
begin
  { Generate a variant array of bytes }
  Result := ABuffer.ToBytes();
end;

class operator TBuffer.Implicit(const ARawString: RawByteString): TBuffer;
begin
  { Assign the string dorectly into the result }
  Result.FBytes := ARawString;
end;

function TBuffer.IndexOf(const AWhat: Byte): NativeInt;
var
  I, L: NativeInt;
begin
  Result := -1;
  L := System.Length(FBytes);

  { Search for that fabled byte }
  if L > 0 then
    for I := 1 to L do
      if FBytes[I] = AnsiChar(AWhat) then
        Exit(I - 1);
end;

function TBuffer.IndexOf(const AWhat: TBuffer): NativeInt;
begin
  { Call the RawByteString version }
  Result := IndexOf(AWhat.FBytes);
end;

function TBuffer.IndexOf(const AWhat: RawByteString): NativeInt;
var
  I: NativeInt;
  L, LW: NativeInt;
begin
  { Prepare! Calculate lengths }
  L := System.Length(FBytes);
  LW := System.Length(AWhat);

  Result := -1; // Nothing.

  { Do not continue if there are no substrings or the string is empty }
  if (L = 0) or (LW > L) or (LW = 0) then
    Exit;

  { Start from the beggining and try to search for what we need }
  for I := 1 to (L - LW + 1) do
    if BinaryCompare(PAnsiChar(FBytes) + I - 1, PAnsiChar(AWhat), LW) = 0 then
      Exit(I - 1);
end;

procedure TBuffer.Insert(const AIndex: NativeInt; const AWhat: TBuffer);
begin
  { Call the RawByteString version }
  Insert(AIndex, AWhat.FBytes);
end;

procedure TBuffer.Insert(const AIndex: NativeInt; const AWhat: RawByteString);
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AIndex + 1;
  LLength := System.Length(FBytes);

{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > (LLength + 1)) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
{$ENDIF}

  { Assign and unique-fy }
  System.Insert(AWhat, FBytes, LIndex);
end;

procedure TBuffer.Insert(const AIndex: NativeInt; const AWhat: Byte);
begin
  { Call the RawByteString version }
  Insert(AIndex, RawByteString(AnsiChar(AWhat)));
end;

function TBuffer.LastIndexOf(const AWhat: Byte): NativeInt;
var
  I, L: NativeInt;
begin
  Result := -1;
  L := System.Length(FBytes);

  { Search for that fabled byte }
  if L > 0 then
    for I := L downto 1 do
      if FBytes[I] = AnsiChar(AWhat) then
        Exit(I - 1);
end;

function TBuffer.LastIndexOf(const AWhat: TBuffer): NativeInt;
begin
  { Call the RawByteString version }
  Result := LastIndexOf(AWhat.FBytes);
end;

function TBuffer.LastIndexOf(const AWhat: RawByteString): NativeInt;
var
  I: NativeInt;
  L, LW: NativeInt;
begin
  { Prepare! Calculate lengths }
  L := System.Length(FBytes);
  LW := System.Length(AWhat);

  { Special case of nil string }
  Result := - 1; // Nothing.

  { Do not continue if there are no substrings or the string is empty }
  if (L = 0) or (LW > L) or (LW = 0) then
    Exit;

  { Start from the beggining and try to search for what we need }
  for I := (L - LW + 1) downto 1 do
    if BinaryCompare(PAnsiChar(FBytes) + I - 1, PAnsiChar(AWhat), LW) = 0 then Exit(I - 1);
end;

class operator TBuffer.NotEqual(const ALeft, ARight: TBuffer): Boolean;
begin
  { Use Compare }
  Result := Compare(ALeft, ARight) <> 0;
end;

procedure TBuffer.Remove(const AStart: NativeInt);
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + 1;
  LLength := System.Length(FBytes);

{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
{$ENDIF}

  System.Delete(FBytes, LIndex, LLength);
end;

procedure TBuffer.Remove(const AStart: NativeInt; const ACount: NativeUInt);
var
  LIndex, LLength: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AStart + 1;
  LLength := System.Length(FBytes);

{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > LLength) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');

  if (LIndex + NativeInt(ACount) - 1) > LLength then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('ACount');
{$ENDIF}

  System.Delete(FBytes, LIndex, ACount);
end;

procedure TBuffer.Replace(const AWhat, AWith: Byte);
var
  I: NativeInt;
begin
  { Copy the string }
  for I := 1 to System.Length(FBytes) do
    if FBytes[I] = AnsiChar(AWhat) then
      FBytes[I] := AnsiChar(AWith);
end;

procedure TBuffer.Replace(const AWhat, AWith: RawByteString);
var
  LResult: RawByteString;
  LLength, LWhatLen, I, L: NativeInt;
begin
  { Init }
  LResult := CEmpty;
  LLength := System.Length(FBytes);
  LWhatLen := System.Length(AWhat);

  { Nothing to do? }
  if (LLength = 0) or (LWhatLen = 0) or (LWhatLen > LLength) then
    Exit;

  L := 1;

  { Start from the beggining abd do search }
  for I := 1 to (LLength - LWhatLen + 1) do
    if BinaryCompare(PAnsiChar(FBytes) + I - 1, PAnsiChar(AWhat), LWhatLen) = 0 then
    begin
      LResult := LResult + System.Copy(FBytes, L, (I - L)) + AWith;
      L := I + LWhatLen;
    end;

  if L < LLength then
    LResult := LResult + System.Copy(FBytes, L, MaxInt);

  { Change internal FBytes for the new buffer }
  FBytes := LResult;
end;

procedure TBuffer.Replace(const AWhat, AWith: TBuffer);
begin
  { Call RawByteString version }
  Replace(AWhat.FBytes, AWith.FBytes);
end;

procedure TBuffer.Reverse;
var
  I, L: NativeInt;
  B: AnsiChar;
begin
  L := System.Length(FBytes);

  for I := 1 to (L div 2) do
  begin
    B := FBytes[I];
    FBytes[I] := FBytes[L - I + 1];
    FBytes[L - I + 1] := B;
  end;
end;

procedure TBuffer.SetByte(const AIndex: NativeInt; const AByte: Byte);
var
  LIndex: NativeInt;
begin
  { Calculate the index proper }
  LIndex := AIndex + 1;

  { Get the byte }
{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > System.Length(FBytes)) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('AIndex');
{$ENDIF}

  FBytes[LIndex] := AnsiChar(AByte);
end;

function TBuffer.StartsWith(const AWhat: TBuffer): Boolean;
begin
  { Call RawByteString version }
  Result := StartsWith(AWhat.FBytes);
end;

function TBuffer.StartsWith(const AWhat: RawByteString): Boolean;
var
  LMyLen, LWhatLen: NativeInt;
begin
  LMyLen := System.Length(FBytes);
  LWhatLen := System.Length(AWhat);

  { Check if we should continue }
  if (LWhatLen > LMyLen) or (LMyLen = 0) or (LWhatLen = 0) then
    Exit(false);

  { Perform a binary comparison from the end }
  Result := BinaryCompare(PAnsiChar(FBytes), PAnsiChar(AWhat), LWhatLen) = 0;
end;

function TBuffer.StartsWith(const AWhat: Byte): Boolean;
begin
  { Direct comparison }
  Result := false;

  if System.Length(FBytes) > 0 then
    Result := FBytes[1] = AnsiChar(AWhat);
end;

function TBuffer.ToBytes: TBytes;
var
  L: NativeInt;
begin
  { Allocate space and copy the bytes }
  L := System.Length(FBytes);
  System.SetLength(Result, L);

  if L > 0 then
    Move(FBytes[1], Result[0], L);
end;

function TBuffer.ToRawByteString: RawByteString;
begin
  { Retuirn the internal string }
  Result := FBytes;
end;

{ TBufferType }

function TBufferType.Compare(const AValue1, AValue2: TBuffer): NativeInt;
begin
  Result := TBuffer.Compare(AValue1, AValue2);
end;

procedure TBufferType.DoDeserialize(const AInfo: TValueInfo; out AValue: TBuffer; const AContext: IDeserializationContext);
var
  LName: String;
  LValue: RawByteString;
begin
  LName := AInfo.Name;

  AContext.GetBinaryValue(AInfo,
    function(const ASize: NativeUInt): Pointer
    begin
      { Setup the raw byte string}
      SetLength(LValue, ASize);

      { Supply the pointer }
      Result := Addr(LValue[1]);
    end
  );

  { Finally set the out pointer }
  AValue.FBytes := LValue;
end;

procedure TBufferType.DoSerialize(const AInfo: TValueInfo; const AValue: TBuffer; const AContext: ISerializationContext);
begin
  { Write as binary block! }
  AContext.AddBinaryValue(AInfo, AValue.FBytes[1], Length(AValue.FBytes));
end;

function TBufferType.Family: TTypeFamily;
begin
  { It's a string after all ... }
  Result := tfString;
end;

function TBufferType.GenerateHashCode(const AValue: TBuffer): NativeInt;
begin
  Result := BinaryHash(@(AValue.FBytes[1]), Length(AValue.FBytes));
end;

function TBufferType.GetString(const AValue: TBuffer): String;
begin
  Result := Format(SElementCount, [Length(AValue.FBytes)]);
end;

function TBufferType.TryConvertFromVariant(const AValue: Variant; out ORes: TBuffer): Boolean;
var
  LBytes: TBytes;
begin
  try
    LBytes := AValue;
    ORes := TBuffer.Create(LBytes);

    Result := true;
  except
    Result := false;
  end;
end;

function TBufferType.TryConvertToVariant(const AValue: TBuffer; out ORes: Variant): Boolean;
begin
  try
    ORes := AValue;
    Result := true;
  except
    Result := false;
  end;
end;

{ TBuffer.TEnumerator }

constructor TBuffer.TEnumerator.Create(const ABytes: RawByteString);
begin
  FBytes := ABytes;
  FCurrent := 0;
  FIndex := 0;
end;

function TBuffer.TEnumerator.GetCurrent: Byte;
begin
  Result := FCurrent;
end;

function TBuffer.TEnumerator.MoveNext: Boolean;
begin
  { Check for end }
  Inc(FIndex);
  Result := FIndex <= System.Length(FBytes);

  { Read current }
  if Result then
    FCurrent := Byte(FBytes[FIndex]);
end;

{ TBuffer.TEnumerable }

procedure TBuffer.TEnumerable.CopyTo(var AArray: array of Byte; const StartIndex: NativeUInt);
begin
  if StartIndex >= NativeUInt(System.Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(System.Length(AArray)) - StartIndex) < Count then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  { Move the chars }
  Move(FBytes[1], AArray[StartIndex], Count);
end;

constructor TBuffer.TEnumerable.Create(const ABytes: RawByteString);
begin
  inherited Create();

  { Simpla }
  FBytes := ABytes;
end;

function TBuffer.TEnumerable.ElementAt(const Index: NativeUInt): Byte;
var
  LIndex: NativeInt;
begin
  { Calculate the index proper }
  LIndex := Index + 1;

  { Get the char }
{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > System.Length(FBytes)) or (LIndex < 1) then
     ExceptionHelper.Throw_ArgumentOutOfRangeError('Index');
{$ENDIF}

  Result := Byte(FBytes[LIndex]);
end;

function TBuffer.TEnumerable.ElementAtOrDefault(const Index: NativeUInt; const ADefault: Byte): Byte;
var
  LIndex: NativeInt;
begin
  { Calculate the index proper }
  LIndex := Index + 1;

  { Get the char }
{$IFDEF TBUFFER_CHECK_RANGES}
  if (LIndex > System.Length(FBytes)) or (LIndex < 1) then
     Exit(ADefault);
{$ENDIF}

  Result := Byte(FBytes[LIndex]);
end;

function TBuffer.TEnumerable.Empty: Boolean;
begin
  Result := System.Length(FBytes) = 0;
end;

function TBuffer.TEnumerable.First: Byte;
begin
  Result := ElementAt(0);
end;

function TBuffer.TEnumerable.FirstOrDefault(const ADefault: Byte): Byte;
begin
  Result := ElementAtOrDefault(0, ADefault);
end;

function TBuffer.TEnumerable.GetCount: NativeUInt;
begin
  Result := System.Length(FBytes);
end;

function TBuffer.TEnumerable.GetEnumerator: IEnumerator<Byte>;
begin
  Result := TEnumerator.Create(FBytes);
end;

function TBuffer.TEnumerable.Last: Byte;
begin
  Result := ElementAt(Count - 1);
end;

function TBuffer.TEnumerable.LastOrDefault(const ADefault: Byte): Byte;
begin
  Result := ElementAtOrDefault(Count - 1, ADefault);
end;

end.
