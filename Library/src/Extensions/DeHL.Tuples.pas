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
unit DeHL.Tuples;
interface
uses
  SysUtils,
  DeHL.Base,
  DeHL.Exceptions,
  DeHL.StrConsts,
  DeHL.Types,
  DeHL.Serialization;

type
  ///  <summary>1-n tuple type.</summary>
  ///  <remarks>Values of this type can store one value.</remarks>
  Tuple<T1> = record
  private
    FValue1: T1;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a 1-n tuple with a given value.</summary>
    ///  <param name="AValue1">The value to store in the tuple.</param>
    constructor Create(const AValue1: T1);

    ///  <summary>Returns the first value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value1: T1 read FValue1;
  end;

  ///  <summary>2-n tuple type.</summary>
  ///  <remarks>Values of this type can store two values.</remarks>
  Tuple<T1, T2> = record
  private
    FValue1: T1;
    FValue2: T2;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a 2-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value to store in the tuple.</param>
    ///  <param name="AValue2">The second value to store in the tuple.</param>
    constructor Create(const AValue1: T1; const AValue2: T2);

    ///  <summary>Returns the first value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value1: T1 read FValue1;

    ///  <summary>Returns the second value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value2: T2 read FValue2;
  end;

  ///  <summary>3-n tuple type.</summary>
  ///  <remarks>Values of this type can store three values.</remarks>
  Tuple<T1, T2, T3> = record
  private
    FValue1: T1;
    FValue2: T2;
    FValue3: T3;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a 3-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value to store in the tuple.</param>
    ///  <param name="AValue2">The second value to store in the tuple.</param>
    ///  <param name="AValue3">The third value to store in the tuple.</param>
    constructor Create(const AValue1: T1; const AValue2: T2; const AValue3: T3);

    ///  <summary>Returns the first value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value1: T1 read FValue1;

    ///  <summary>Returns the second value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value2: T2 read FValue2;

    ///  <summary>Returns the third value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value3: T3 read FValue3;
  end;

  ///  <summary>4-n tuple type.</summary>
  ///  <remarks>Values of this type can store four values.</remarks>
  Tuple<T1, T2, T3, T4> = record
  private
    FValue1: T1;
    FValue2: T2;
    FValue3: T3;
    FValue4: T4;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a 4-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value to store in the tuple.</param>
    ///  <param name="AValue2">The second value to store in the tuple.</param>
    ///  <param name="AValue3">The third value to store in the tuple.</param>
    ///  <param name="AValue4">The fourth value to store in the tuple.</param>
    constructor Create(const AValue1: T1; const AValue2: T2; const AValue3: T3;
       const AValue4: T4);

    ///  <summary>Returns the first value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value1: T1 read FValue1;

    ///  <summary>Returns the second value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value2: T2 read FValue2;

    ///  <summary>Returns the third value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value3: T3 read FValue3;

    ///  <summary>Returns the fourth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value4: T4 read FValue4;
  end;

  ///  <summary>5-n tuple type.</summary>
  ///  <remarks>Values of this type can store five values.</remarks>
  Tuple<T1, T2, T3, T4, T5> = record
  private
    FValue1: T1;
    FValue2: T2;
    FValue3: T3;
    FValue4: T4;
    FValue5: T5;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a 5-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value to store in the tuple.</param>
    ///  <param name="AValue2">The second value to store in the tuple.</param>
    ///  <param name="AValue3">The third value to store in the tuple.</param>
    ///  <param name="AValue4">The fourth value to store in the tuple.</param>
    ///  <param name="AValue5">The fifth value to store in the tuple.</param>
    constructor Create(const AValue1: T1; const AValue2: T2; const AValue3: T3;
       const AValue4: T4; const AValue5: T5);

    ///  <summary>Returns the first value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value1: T1 read FValue1;

    ///  <summary>Returns the second value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value2: T2 read FValue2;

    ///  <summary>Returns the third value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value3: T3 read FValue3;

    ///  <summary>Returns the fourth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value4: T4 read FValue4;

    ///  <summary>Returns the fifth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value5: T5 read FValue5;
  end;

  ///  <summary>6-n tuple type.</summary>
  ///  <remarks>Values of this type can store six values.</remarks>
  Tuple<T1, T2, T3, T4, T5, T6> = record
  private
    FValue1: T1;
    FValue2: T2;
    FValue3: T3;
    FValue4: T4;
    FValue5: T5;
    FValue6: T6;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a 6-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value to store in the tuple.</param>
    ///  <param name="AValue2">The second value to store in the tuple.</param>
    ///  <param name="AValue3">The third value to store in the tuple.</param>
    ///  <param name="AValue4">The fourth value to store in the tuple.</param>
    ///  <param name="AValue5">The fifth value to store in the tuple.</param>
    ///  <param name="AValue6">The sixth value to store in the tuple.</param>
    constructor Create(const AValue1: T1; const AValue2: T2; const AValue3: T3;
       const AValue4: T4; const AValue5: T5; const AValue6: T6);

    ///  <summary>Returns the first value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value1: T1 read FValue1;

    ///  <summary>Returns the second value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value2: T2 read FValue2;

    ///  <summary>Returns the third value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value3: T3 read FValue3;

    ///  <summary>Returns the fourth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value4: T4 read FValue4;

    ///  <summary>Returns the fifth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value5: T5 read FValue5;

    ///  <summary>Returns the sixth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value6: T6 read FValue6;
  end;

  ///  <summary>7-n tuple type.</summary>
  ///  <remarks>Values of this type can store seven values.</remarks>
  Tuple<T1, T2, T3, T4, T5, T6, T7> = record
  private
    FValue1: T1;
    FValue2: T2;
    FValue3: T3;
    FValue4: T4;
    FValue5: T5;
    FValue6: T6;
    FValue7: T7;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a 7-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value to store in the tuple.</param>
    ///  <param name="AValue2">The second value to store in the tuple.</param>
    ///  <param name="AValue3">The third value to store in the tuple.</param>
    ///  <param name="AValue4">The fourth value to store in the tuple.</param>
    ///  <param name="AValue5">The fifth value to store in the tuple.</param>
    ///  <param name="AValue6">The sixth value to store in the tuple.</param>
    ///  <param name="AValue7">The seventh value to store in the tuple.</param>
    constructor Create(const AValue1: T1; const AValue2: T2; const AValue3: T3;
       const AValue4: T4; const AValue5: T5; const AValue6: T6; const AValue7: T7);

    ///  <summary>Returns the first value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value1: T1 read FValue1;

    ///  <summary>Returns the second value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value2: T2 read FValue2;

    ///  <summary>Returns the third value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value3: T3 read FValue3;

    ///  <summary>Returns the fourth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value4: T4 read FValue4;

    ///  <summary>Returns the fifth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value5: T5 read FValue5;

    ///  <summary>Returns the sixth value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value6: T6 read FValue6;

    ///  <summary>Returns the seventh value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value7: T7 read FValue7;
  end;

  ///  <summary>Helper type that contains static methods to ease the creation of tuples.</summary>
  Tuple = record
  private type
    T1TupleType<T1> = class(TRecordType<Tuple<T1>>)
    private
      F1Type: IType<T1>;
      FTypeManagement: TTypeManagement;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Tuple<T1>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Tuple<T1>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const A1Type: IType<T1>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Tuple<T1>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Tuple<T1>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Tuple<T1>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: Tuple<T1>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Tuple<T1>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1>): Boolean; override;
    end;

    T2TupleType<T1, T2> = class(TRecordType<Tuple<T1, T2>>)
    private
      F1Type: IType<T1>;
      F2Type: IType<T2>;

      FTypeManagement: TTypeManagement;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Tuple<T1, T2>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Tuple<T1, T2>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const A1Type: IType<T1>; const A2Type: IType<T2>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Tuple<T1, T2>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Tuple<T1, T2>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Tuple<T1, T2>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: Tuple<T1, T2>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Tuple<T1, T2>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1, T2>): Boolean; override;
    end;

    T3TupleType<T1, T2, T3> = class(TRecordType<Tuple<T1, T2, T3>>)
    private
      F1Type: IType<T1>;
      F2Type: IType<T2>;
      F3Type: IType<T3>;

      FTypeManagement: TTypeManagement;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const A1Type: IType<T1>; const A2Type: IType<T2>;
        const A3Type: IType<T3>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Tuple<T1, T2, T3>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Tuple<T1, T2, T3>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Tuple<T1, T2, T3>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: Tuple<T1, T2, T3>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Tuple<T1, T2, T3>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1, T2, T3>): Boolean; override;
    end;

    T4TupleType<T1, T2, T3, T4> = class(TRecordType<Tuple<T1, T2, T3, T4>>)
    private
      F1Type: IType<T1>;
      F2Type: IType<T2>;
      F3Type: IType<T3>;
      F4Type: IType<T4>;

      FTypeManagement: TTypeManagement;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3, T4>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const A1Type: IType<T1>; const A2Type: IType<T2>;
        const A3Type: IType<T3>; const A4Type: IType<T4>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Tuple<T1, T2, T3, T4>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Tuple<T1, T2, T3, T4>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Tuple<T1, T2, T3, T4>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: Tuple<T1, T2, T3, T4>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Tuple<T1, T2, T3, T4>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4>): Boolean; override;
    end;

    T5TupleType<T1, T2, T3, T4, T5> = class(TRecordType<Tuple<T1, T2, T3, T4, T5>>)
    private
      F1Type: IType<T1>;
      F2Type: IType<T2>;
      F3Type: IType<T3>;
      F4Type: IType<T4>;
      F5Type: IType<T5>;

      FTypeManagement: TTypeManagement;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3, T4, T5>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4, T5>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const A1Type: IType<T1>; const A2Type: IType<T2>;
        const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Tuple<T1, T2, T3, T4, T5>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Tuple<T1, T2, T3, T4, T5>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Tuple<T1, T2, T3, T4, T5>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: Tuple<T1, T2, T3, T4, T5>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Tuple<T1, T2, T3, T4, T5>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4, T5>): Boolean; override;
    end;

    T6TupleType<T1, T2, T3, T4, T5, T6> = class(TRecordType<Tuple<T1, T2, T3, T4, T5, T6>>)
    private
      F1Type: IType<T1>;
      F2Type: IType<T2>;
      F3Type: IType<T3>;
      F4Type: IType<T4>;
      F5Type: IType<T5>;
      F6Type: IType<T6>;

      FTypeManagement: TTypeManagement;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3, T4, T5, T6>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4, T5, T6>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const A1Type: IType<T1>; const A2Type: IType<T2>;
        const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>;
        const A6Type: IType<T6>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Tuple<T1, T2, T3, T4, T5, T6>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Tuple<T1, T2, T3, T4, T5, T6>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Tuple<T1, T2, T3, T4, T5, T6>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: Tuple<T1, T2, T3, T4, T5, T6>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Tuple<T1, T2, T3, T4, T5, T6>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4, T5, T6>): Boolean; override;
    end;

    T7TupleType<T1, T2, T3, T4, T5, T6, T7> = class(TRecordType<Tuple<T1, T2, T3, T4, T5, T6, T7>>)
    private
      F1Type: IType<T1>;
      F2Type: IType<T2>;
      F3Type: IType<T3>;
      F4Type: IType<T4>;
      F5Type: IType<T5>;
      F6Type: IType<T6>;
      F7Type: IType<T7>;

      FTypeManagement: TTypeManagement;

    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const A1Type: IType<T1>; const A2Type: IType<T2>;
        const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>;
        const A6Type: IType<T6>; const A7Type: IType<T7>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: Tuple<T1, T2, T3, T4, T5, T6, T7>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4, T5, T6, T7>): Boolean; override;
    end;

  public
    ///  <summary>Initializes a 1-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value stored in the tuple.</param>
    ///  <returns>A new tuple.</returns>
    class function Create<T1>(const AValue1: T1): Tuple<T1>; overload; static;

    ///  <summary>Initializes a 2-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value stored in the tuple.</param>
    ///  <param name="AValue2">The second value stored in the tuple.</param>
    ///  <returns>A new tuple.</returns>
    class function Create<T1, T2>(const AValue1: T1; const AValue2: T2): Tuple<T1, T2>; overload; static;

    ///  <summary>Initializes a 3-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value stored in the tuple.</param>
    ///  <param name="AValue2">The second value stored in the tuple.</param>
    ///  <param name="AValue3">The third value stored in the tuple.</param>
    ///  <returns>A new tuple.</returns>
    class function Create<T1, T2, T3>(const AValue1: T1; const AValue2: T2;
      const AValue3: T3): Tuple<T1, T2, T3>; overload; static;

    ///  <summary>Initializes a 4-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value stored in the tuple.</param>
    ///  <param name="AValue2">The second value stored in the tuple.</param>
    ///  <param name="AValue3">The third value stored in the tuple.</param>
    ///  <param name="AValue4">The fourth value stored in the tuple.</param>
    ///  <returns>A new tuple.</returns>
    class function Create<T1, T2, T3, T4>(const AValue1: T1; const AValue2: T2; const AValue3: T3;
      const AValue4: T4): Tuple<T1, T2, T3, T4>; overload; static;

    ///  <summary>Initializes a 5-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value stored in the tuple.</param>
    ///  <param name="AValue2">The second value stored in the tuple.</param>
    ///  <param name="AValue3">The third value stored in the tuple.</param>
    ///  <param name="AValue4">The fourth value stored in the tuple.</param>
    ///  <param name="AValue5">The fifth value stored in the tuple.</param>
    ///  <returns>A new tuple.</returns>
    class function Create<T1, T2, T3, T4, T5>(const AValue1: T1; const AValue2: T2; const AValue3: T3;
      const AValue4: T4; const AValue5: T5): Tuple<T1, T2, T3, T4, T5>; overload; static;

    ///  <summary>Initializes a 6-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value stored in the tuple.</param>
    ///  <param name="AValue2">The second value stored in the tuple.</param>
    ///  <param name="AValue3">The third value stored in the tuple.</param>
    ///  <param name="AValue4">The fourth value stored in the tuple.</param>
    ///  <param name="AValue5">The fifth value stored in the tuple.</param>
    ///  <param name="AValue6">The sixth value stored in the tuple.</param>
    ///  <returns>A new tuple.</returns>
    class function Create<T1, T2, T3, T4, T5, T6>(const AValue1: T1; const AValue2: T2;
      const AValue3: T3; const AValue4: T4; const AValue5: T5; const AValue6: T6): Tuple<T1, T2, T3, T4, T5, T6>; overload; static;

    ///  <summary>Initializes a 7-n tuple with the given values.</summary>
    ///  <param name="AValue1">The first value stored in the tuple.</param>
    ///  <param name="AValue2">The second value stored in the tuple.</param>
    ///  <param name="AValue3">The third value stored in the tuple.</param>
    ///  <param name="AValue4">The fourth value stored in the tuple.</param>
    ///  <param name="AValue5">The fifth value stored in the tuple.</param>
    ///  <param name="AValue6">The sixth value stored in the tuple.</param>
    ///  <param name="AValue7">The seventh value stored in the tuple.</param>
    ///  <returns>A new tuple.</returns>
    class function Create<T1, T2, T3, T4, T5, T6, T7>(const AValue1: T1; const AValue2: T2;
      const AValue3: T3; const AValue4: T4; const AValue5: T5; const AValue6: T6;
      const AValue7: T7): Tuple<T1, T2, T3, T4, T5, T6, T7>; overload; static;

    ///  <summary>Returns a type class that describes a 1-n tuple.</summary>
    ///  <param name="A1Type">The type class describing the first type.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|Tuple&lt;T1&gt;">DeHL.Tuples.Tuple&lt;T1&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A1Type"/> is <c>nil</c>.</exception>
    class function GetType<T1>(const A1Type: IType<T1>): IType<Tuple<T1>>; overload; static;

    ///  <summary>Returns a type class that describes a 2-n tuple.</summary>
    ///  <param name="A1Type">The type class describing the first type.</param>
    ///  <param name="A2Type">The type class describing the second type.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|Tuple&lt;T1, T2&gt;">DeHL.Tuples.Tuple&lt;T1, T2&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A1Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A2Type"/> is <c>nil</c>.</exception>
    class function GetType<T1, T2>(const A1Type: IType<T1>; const A2Type: IType<T2>): IType<Tuple<T1, T2>>; overload; static;

    ///  <summary>Returns a type class that describes a 3-n tuple.</summary>
    ///  <param name="A1Type">The type class describing the first type.</param>
    ///  <param name="A2Type">The type class describing the second type.</param>
    ///  <param name="A3Type">The type class describing the third type.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|Tuple&lt;T1, T2, T3&gt;">DeHL.Tuples.Tuple&lt;T1, T2, T3&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A1Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A2Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A3Type"/> is <c>nil</c>.</exception>
    class function GetType<T1, T2, T3>(const A1Type: IType<T1>; const A2Type: IType<T2>;
      const A3Type: IType<T3>): IType<Tuple<T1, T2, T3>>; overload; static;

    ///  <summary>Returns a type class that describes a 4-n tuple.</summary>
    ///  <param name="A1Type">The type class describing the first type.</param>
    ///  <param name="A2Type">The type class describing the second type.</param>
    ///  <param name="A3Type">The type class describing the third type.</param>
    ///  <param name="A4Type">The type class describing the fourth type.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|Tuple&lt;T1, T2, T3, T4&gt;">DeHL.Tuples.Tuple&lt;T1, T2, T3, T4&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A1Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A2Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A3Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A4Type"/> is <c>nil</c>.</exception>
    class function GetType<T1, T2, T3, T4>(const A1Type: IType<T1>; const A2Type: IType<T2>;
      const A3Type: IType<T3>; const A4Type: IType<T4>): IType<Tuple<T1, T2, T3, T4>>; overload; static;

    ///  <summary>Returns a type class that describes a 5-n tuple.</summary>
    ///  <param name="A1Type">The type class describing the first type.</param>
    ///  <param name="A2Type">The type class describing the second type.</param>
    ///  <param name="A3Type">The type class describing the third type.</param>
    ///  <param name="A4Type">The type class describing the fourth type.</param>
    ///  <param name="A5Type">The type class describing the fifth type.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|Tuple&lt;T1, T2, T3, T4, T5&gt;">DeHL.Tuples.Tuple&lt;T1, T2, T3, T4, T5&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A1Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A2Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A3Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A4Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A5Type"/> is <c>nil</c>.</exception>
    class function GetType<T1, T2, T3, T4, T5>(const A1Type: IType<T1>; const A2Type: IType<T2>;
      const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>): IType<Tuple<T1, T2, T3, T4, T5>>; overload; static;

    ///  <summary>Returns a type class that describes a 6-n tuple.</summary>
    ///  <param name="A1Type">The type class describing the first type.</param>
    ///  <param name="A2Type">The type class describing the second type.</param>
    ///  <param name="A3Type">The type class describing the third type.</param>
    ///  <param name="A4Type">The type class describing the fourth type.</param>
    ///  <param name="A5Type">The type class describing the fifth type.</param>
    ///  <param name="A6Type">The type class describing the sixth type.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|Tuple&lt;T1, T2, T3, T4, T5, T6&gt;">DeHL.Tuples.Tuple&lt;T1, T2, T3, T4, T5, T6&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A1Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A2Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A3Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A4Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A5Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A6Type"/> is <c>nil</c>.</exception>
    class function GetType<T1, T2, T3, T4, T5, T6>(const A1Type: IType<T1>; const A2Type: IType<T2>;
      const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>;
      const A6Type: IType<T6>): IType<Tuple<T1, T2, T3, T4, T5, T6>>; overload; static;

    ///  <summary>Returns a type class that describes a 7-n tuple.</summary>
    ///  <param name="A1Type">The type class describing the first type.</param>
    ///  <param name="A2Type">The type class describing the second type.</param>
    ///  <param name="A3Type">The type class describing the third type.</param>
    ///  <param name="A4Type">The type class describing the fourth type.</param>
    ///  <param name="A5Type">The type class describing the fifth type.</param>
    ///  <param name="A6Type">The type class describing the sixth type.</param>
    ///  <param name="A7Type">The type class describing the seventh type.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|Tuple&lt;T1, T2, T3, T4, T5, T6, T7&gt;">DeHL.Tuples.Tuple&lt;T1, T2, T3, T4, T5, T6, T7&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A1Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A2Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A3Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A4Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A5Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A6Type"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="A7Type"/> is <c>nil</c>.</exception>
    class function GetType<T1, T2, T3, T4, T5, T6, T7>(const A1Type: IType<T1>; const A2Type: IType<T2>;
      const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>;
      const A6Type: IType<T6>; const A7Type: IType<T7>): IType<Tuple<T1, T2, T3, T4, T5, T6, T7>>; overload; static;
  end;

type
  ///  <summary>2-n tuple type designed specifically to hold a key-value pair..</summary>
  ///  <remarks>Values of this type can store a key and a value associated with that key.</remarks>
  KVPair<TKey, TValue> = record
  private
    FKey: TKey;
    FValue: TValue;

    class constructor Create();
    class destructor Destroy();
  public
    ///  <summary>Initializes a key-value pair tuple with the given values.</summary>
    ///  <param name="AKey">The key to store in the tuple.</param>
    ///  <param name="AValue">The value to store in the tuple.</param>
    constructor Create(const AKey: TKey; const AValue: TValue);

    ///  <summary>Returns the key stored in the tuple.</summary>
    ///  <returns>The stored key.</returns>
    property Key: TKey read FKey;

    ///  <summary>Returns the value stored in the tuple.</summary>
    ///  <returns>The stored value.</returns>
    property Value: TValue read FValue;
  end;

  ///  <summary>Helper type that exposes sttaic methods to ease the creation of key-value pairs.</summary>
  KVPair = record
  private type
    TKVPairType<TKey, TValue> = class(TRecordType<KVPair<TKey, TValue>>)
    private
      FKeyType: IType<TKey>;
      FValueType: IType<TValue>;

      FTypeManagement: TTypeManagement;
    protected
      { Serialization }
      procedure DoSerialize(const AInfo: TValueInfo; const AValue: KVPair<TKey, TValue>;
        const AContext: ISerializationContext); override;

      procedure DoDeserialize(const AInfo: TValueInfo; out AValue: KVPair<TKey, TValue>;
        const AContext: IDeserializationContext); override;

    public
      { Constructors }
      constructor Create(); overload; override;
      constructor Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>); reintroduce; overload;

      { Comparator }
      function Compare(const AValue1, AValue2: KVPair<TKey, TValue>): NativeInt; override;

      { Hash code provider }
      function GenerateHashCode(const AValue: KVPair<TKey, TValue>): NativeInt; override;

      { Get String representation }
      function GetString(const AValue: KVPair<TKey, TValue>): String; override;

      { Type management }
      function Management(): TTypeManagement; override;

      { Cleanup / management }
      procedure Cleanup(var AValue: KVPair<TKey, TValue>); override;

      { Variant Conversion }
      function TryConvertToVariant(const AValue: KVPair<TKey, TValue>; out ORes: Variant): Boolean; override;
      function TryConvertFromVariant(const AValue: Variant; out ORes: KVPair<TKey, TValue>): Boolean; override;
    end;

  public
    ///  <summary>Initializes a key-value pair tuple with the given values.</summary>
    ///  <param name="AKey">The key to store in the tuple.</param>
    ///  <param name="AValue">The value to store in the tuple.</param>
    ///  <returns>A new key-value pair.</returns>
    class function Create<TKey, TValue>(const AKey: TKey; const AValue: TValue): KVPair<TKey, TValue>; overload; static;

    ///  <summary>Returns a type class that describes a key-value pair tuple.</summary>
    ///  <param name="AKeyType">The type class describing the key.</param>
    ///  <param name="AValueType">The type class describing the value.</param>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;"</see> that represents
    ///  <see cref="DeHL.Tuples|KVPair&lt;TKey, TValue&gt;">DeHL.Tuples.KVPair&lt;TKey, TValue&gt;</see> type.</returns>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AKeyType"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AValueType"/> is <c>nil</c>.</exception>
    class function GetType<TKey, TValue>(const AKeyType: IType<TKey>; const AValueType: IType<TValue>): IType<KVPair<TKey, TValue>>; overload; static;
  end;

implementation
uses Variants;

{ Tuple<T> }

constructor Tuple<T1>.Create(const AValue1: T1);
begin
  FValue1 := AValue1;
end;

class constructor Tuple<T1>.Create;
begin
  { Register custom type }
  if not TType<Tuple<T1>>.IsRegistered then
    TType<Tuple<T1>>.Register(Tuple.T1TupleType<T1>);
end;

class destructor Tuple<T1>.Destroy;
begin
  { Unregister custom type }
  if TType<Tuple<T1>>.IsRegistered then
    TType<Tuple<T1>>.Unregister();
end;

{ Tuple<T1, T2> }

constructor Tuple<T1, T2>.Create(const AValue1: T1; const AValue2: T2);
begin
  FValue1 := AValue1;
  FValue2 := AValue2;
end;

class constructor Tuple<T1, T2>.Create;
begin
  { Register custom type }
  if not TType<Tuple<T1, T2>>.IsRegistered then
    TType<Tuple<T1, T2>>.Register(Tuple.T2TupleType<T1, T2>);
end;

class destructor Tuple<T1, T2>.Destroy;
begin
  { Unregister custom type }
  if TType<Tuple<T1, T2>>.IsRegistered then
    TType<Tuple<T1, T2>>.Unregister();
end;

{ KVPair<TKey, TValue> }

class constructor KVPair<TKey, TValue>.Create;
begin
  { Register custom type }
  if not TType<KVPair<TKey, TValue>>.IsRegistered then
    TType<KVPair<TKey, TValue>>.Register(KVPair.TKVPairType<TKey, TValue>);
end;

constructor KVPair<TKey, TValue>.Create(const AKey: TKey; const AValue: TValue);
begin
  FKey := AKey;
  FValue := AValue;
end;

class destructor KVPair<TKey, TValue>.Destroy;
begin
  { Unregister custom type }
  if TType<KVPair<TKey, TValue>>.IsRegistered then
    TType<KVPair<TKey, TValue>>.Unregister();
end;

{ Tuple<T1, T2, T3> }

constructor Tuple<T1, T2, T3>.Create(const AValue1: T1; const AValue2: T2;
  const AValue3: T3);
begin
  FValue1 := AValue1;
  FValue2 := AValue2;
  FValue3 := AValue3;
end;

class constructor Tuple<T1, T2, T3>.Create;
begin
  { Register custom type }
  if not TType<Tuple<T1, T2, T3>>.IsRegistered then
    TType<Tuple<T1, T2, T3>>.Register(Tuple.T3TupleType<T1, T2, T3>);
end;

class destructor Tuple<T1, T2, T3>.Destroy;
begin
  { Unregister custom type }
  if TType<Tuple<T1, T2, T3>>.IsRegistered then
    TType<Tuple<T1, T2, T3>>.Unregister();
end;

{ Tuple<T1, T2, T3, T4> }

constructor Tuple<T1, T2, T3, T4>.Create(const AValue1: T1; const AValue2: T2;
  const AValue3: T3; const AValue4: T4);
begin
  FValue1 := AValue1;
  FValue2 := AValue2;
  FValue3 := AValue3;
  FValue4 := AValue4;
end;

class constructor Tuple<T1, T2, T3, T4>.Create;
begin
  { Register custom type }
  if not TType<Tuple<T1, T2, T3, T4>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4>>.Register(Tuple.T4TupleType<T1, T2, T3, T4>);
end;

class destructor Tuple<T1, T2, T3, T4>.Destroy;
begin
  { Unregister custom type }
  if TType<Tuple<T1, T2, T3, T4>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4>>.Unregister();
end;

{ Tuple<T1, T2, T3, T4, T5> }

constructor Tuple<T1, T2, T3, T4, T5>.Create(const AValue1: T1;
  const AValue2: T2; const AValue3: T3; const AValue4: T4; const AValue5: T5);
begin
  FValue1 := AValue1;
  FValue2 := AValue2;
  FValue3 := AValue3;
  FValue4 := AValue4;
  FValue5 := AValue5;
end;

class constructor Tuple<T1, T2, T3, T4, T5>.Create;
begin
  { Register custom type }
  if not TType<Tuple<T1, T2, T3, T4, T5>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4, T5>>.Register(Tuple.T5TupleType<T1, T2, T3, T4, T5>);
end;

class destructor Tuple<T1, T2, T3, T4, T5>.Destroy;
begin
  { Unregister custom type }
  if TType<Tuple<T1, T2, T3, T4, T5>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4, T5>>.Unregister();
end;

{ Tuple<T1, T2, T3, T4, T5, T6> }

constructor Tuple<T1, T2, T3, T4, T5, T6>.Create(const AValue1: T1;
  const AValue2: T2; const AValue3: T3; const AValue4: T4; const AValue5: T5;
  const AValue6: T6);
begin
  FValue1 := AValue1;
  FValue2 := AValue2;
  FValue3 := AValue3;
  FValue4 := AValue4;
  FValue5 := AValue5;
  FValue6 := AValue6;
end;

class constructor Tuple<T1, T2, T3, T4, T5, T6>.Create;
begin
  { Register custom type }
  if not TType<Tuple<T1, T2, T3, T4, T5, T6>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4, T5, T6>>.Register(Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>);
end;

class destructor Tuple<T1, T2, T3, T4, T5, T6>.Destroy;
begin
  { Unregister custom type }
  if TType<Tuple<T1, T2, T3, T4, T5, T6>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4, T5, T6>>.Unregister();
end;

{ Tuple<T1, T2, T3, T4, T5, T6, T7> }

constructor Tuple<T1, T2, T3, T4, T5, T6, T7>.Create(const AValue1: T1;
  const AValue2: T2; const AValue3: T3; const AValue4: T4; const AValue5: T5;
  const AValue6: T6; const AValue7: T7);
begin
  FValue1 := AValue1;
  FValue2 := AValue2;
  FValue3 := AValue3;
  FValue4 := AValue4;
  FValue5 := AValue5;
  FValue6 := AValue6;
  FValue7 := AValue7;
end;

class constructor Tuple<T1, T2, T3, T4, T5, T6, T7>.Create;
begin
  { Register custom type }
  if not TType<Tuple<T1, T2, T3, T4, T5, T6, T7>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4, T5, T6, T7>>.Register(Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>);
end;

class destructor Tuple<T1, T2, T3, T4, T5, T6, T7>.Destroy;
begin
  { Unregister custom type }
  if TType<Tuple<T1, T2, T3, T4, T5, T6, T7>>.IsRegistered then
    TType<Tuple<T1, T2, T3, T4, T5, T6, T7>>.Unregister();
end;

{ Tuple }

class function Tuple.Create<T1>(const AValue1: T1): Tuple<T1>;
begin
  Result.FValue1 := AValue1;
end;

class function Tuple.Create<T1, T2>(const AValue1: T1; const AValue2: T2): Tuple<T1, T2>;
begin
  Result.FValue1 := AValue1;
  Result.FValue2 := AValue2;
end;

class function Tuple.Create<T1, T2, T3>(const AValue1: T1; const AValue2: T2;
  const AValue3: T3): Tuple<T1, T2, T3>;
begin
  Result.FValue1 := AValue1;
  Result.FValue2 := AValue2;
  Result.FValue3 := AValue3;
end;

class function Tuple.Create<T1, T2, T3, T4>(const AValue1: T1; const AValue2: T2;
  const AValue3: T3; const AValue4: T4): Tuple<T1, T2, T3, T4>;
begin
  Result.FValue1 := AValue1;
  Result.FValue2 := AValue2;
  Result.FValue3 := AValue3;
  Result.FValue4 := AValue4;
end;

class function Tuple.Create<T1, T2, T3, T4, T5>(const AValue1: T1; const AValue2: T2;
  const AValue3: T3; const AValue4: T4;
  const AValue5: T5): Tuple<T1, T2, T3, T4, T5>;
begin
  Result.FValue1 := AValue1;
  Result.FValue2 := AValue2;
  Result.FValue3 := AValue3;
  Result.FValue4 := AValue4;
  Result.FValue5 := AValue5;
end;

class function Tuple.Create<T1, T2, T3, T4, T5, T6>(const AValue1: T1; const AValue2: T2;
  const AValue3: T3; const AValue4: T4; const AValue5: T5;
  const AValue6: T6): Tuple<T1, T2, T3, T4, T5, T6>;
begin
  Result.FValue1 := AValue1;
  Result.FValue2 := AValue2;
  Result.FValue3 := AValue3;
  Result.FValue4 := AValue4;
  Result.FValue5 := AValue5;
  Result.FValue6 := AValue6;
end;

class function Tuple.Create<T1, T2, T3, T4, T5, T6, T7>(const AValue1: T1; const AValue2: T2;
  const AValue3: T3; const AValue4: T4; const AValue5: T5; const AValue6: T6;
  const AValue7: T7): Tuple<T1, T2, T3, T4, T5, T6, T7>;
begin
  Result.FValue1 := AValue1;
  Result.FValue2 := AValue2;
  Result.FValue3 := AValue3;
  Result.FValue4 := AValue4;
  Result.FValue5 := AValue5;
  Result.FValue6 := AValue6;
  Result.FValue7 := AValue7;
end;

class function Tuple.GetType<T1>(const A1Type: IType<T1>): IType<Tuple<T1>>;
begin
  Result := T1TupleType<T1>.Create(A1Type);
end;

class function Tuple.GetType<T1, T2>(const A1Type: IType<T1>; const A2Type: IType<T2>): IType<Tuple<T1, T2>>;
begin
  Result := T2TupleType<T1, T2>.Create(A1Type, A2Type);
end;

class function Tuple.GetType<T1, T2, T3>(const A1Type: IType<T1>; const A2Type: IType<T2>;
  const A3Type: IType<T3>): IType<Tuple<T1, T2, T3>>;
begin
  Result := T3TupleType<T1, T2, T3>.Create(A1Type, A2Type, A3Type);
end;

class function Tuple.GetType<T1, T2, T3, T4>(const A1Type: IType<T1>; const A2Type: IType<T2>;
  const A3Type: IType<T3>; const A4Type: IType<T4>): IType<Tuple<T1, T2, T3, T4>>;
begin
  Result := T4TupleType<T1, T2, T3, T4>.Create(A1Type, A2Type, A3Type, A4Type);
end;

class function Tuple.GetType<T1, T2, T3, T4, T5>(const A1Type: IType<T1>; const A2Type: IType<T2>;
  const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>): IType<Tuple<T1, T2, T3, T4, T5>>;
begin
  Result := T5TupleType<T1, T2, T3, T4, T5>.Create(A1Type, A2Type, A3Type, A4Type, A5Type);
end;

class function Tuple.GetType<T1, T2, T3, T4, T5, T6>(const A1Type: IType<T1>; const A2Type: IType<T2>;
  const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>;
  const A6Type: IType<T6>): IType<Tuple<T1, T2, T3, T4, T5, T6>>;
begin
  Result := T6TupleType<T1, T2, T3, T4, T5, T6>.Create(A1Type, A2Type, A3Type, A4Type, A5Type, A6Type);
end;

class function Tuple.GetType<T1, T2, T3, T4, T5, T6, T7>(const A1Type: IType<T1>; const A2Type: IType<T2>;
  const A3Type: IType<T3>; const A4Type: IType<T4>; const A5Type: IType<T5>;
  const A6Type: IType<T6>; const A7Type: IType<T7>): IType<Tuple<T1, T2, T3, T4, T5, T6, T7>>;
begin
  Result := T7TupleType<T1, T2, T3, T4, T5, T6, T7>.Create(A1Type, A2Type, A3Type, A4Type, A5Type, A6Type, A7Type);
end;

{ Tuple.T1TupleType<T1> }

procedure Tuple.T1TupleType<T1>.Cleanup(var AValue: Tuple<T1>);
begin
  if Management = tmManual then
  begin
    if F1Type.Management = tmManual then
      F1Type.Cleanup(AValue.FValue1);
  end;
end;

function Tuple.T1TupleType<T1>.Compare(const AValue1, AValue2: Tuple<T1>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := F1Type.Compare(AValue1.FValue1, AValue2.FValue1);
end;

constructor Tuple.T1TupleType<T1>.Create(const A1Type: IType<T1>);
begin
  inherited Create();

  if A1Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A1Type');

  { Obtain the type classes }
  F1Type := A1Type;

  { If at least one is manual, declare as manual }
  if (F1Type.Management = tmManual) then
    FTypeManagement := tmManual
  else if F1Type.Management = tmCompiler then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

constructor Tuple.T1TupleType<T1>.Create;
begin
  Create(TType<T1>.Default);
end;

procedure Tuple.T1TupleType<T1>.DoDeserialize(const AInfo: TValueInfo;
  out AValue: Tuple<T1>; const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the tuple }
  F1Type.Deserialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);

  AContext.EndComplexType();
end;

procedure Tuple.T1TupleType<T1>.DoSerialize(const AInfo: TValueInfo;
  const AValue: Tuple<T1>; const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the tuple }
  F1Type.Serialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);

  AContext.EndComplexType();
end;

function Tuple.T1TupleType<T1>.GenerateHashCode(const AValue: Tuple<T1>): NativeInt;
begin
  Result := F1Type.GenerateHashCode(AValue.FValue1);
end;

function Tuple.T1TupleType<T1>.GetString(const AValue: Tuple<T1>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S1Tuple, [F1Type.GetString(AValue.FValue1)]);
end;

function Tuple.T1TupleType<T1>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function Tuple.T1TupleType<T1>.TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 1) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := F1Type.TryConvertFromVariant(AValue[LBound], ORes.FValue1);
  end else
    Result := false;
end;

function Tuple.T1TupleType<T1>.TryConvertToVariant(const AValue: Tuple<T1>; out ORes: Variant): Boolean;
var
  L1: Variant;
begin
  if F1Type.TryConvertToVariant(AValue.FValue1, L1) then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1]);
    Result := true;
  end else
    Result := false;
end;

{ Tuple.T2TupleType<T1, T2> }

procedure Tuple.T2TupleType<T1, T2>.Cleanup(var AValue: Tuple<T1, T2>);
begin
  if Management = tmManual then
  begin
    if F1Type.Management = tmManual then
      F1Type.Cleanup(AValue.FValue1);

    if F2Type.Management = tmManual then
      F2Type.Cleanup(AValue.FValue2);
  end;
end;

function Tuple.T2TupleType<T1, T2>.Compare(const AValue1, AValue2: Tuple<T1, T2>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := F1Type.Compare(AValue1.FValue1, AValue2.FValue1);

  if Result = 0 then
    Result := F2Type.Compare(AValue1.FValue2, AValue2.FValue2);
end;

constructor Tuple.T2TupleType<T1, T2>.Create;
begin
  Create(TType<T1>.Default, TType<T2>.Default);
end;

constructor Tuple.T2TupleType<T1, T2>.Create(const A1Type: IType<T1>; const A2Type: IType<T2>);
begin
  inherited Create();

  if A1Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A1Type');

  if A2Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A2Type');

  { Obtain the type classes }
  F1Type := A1Type;
  F2Type := A2Type;

  { If at least one is manual, declare as manual }
  if (F1Type.Management = tmManual) or
     (F2Type.Management = tmManual)
  then
    FTypeManagement := tmManual
  else if (F1Type.Management = tmCompiler) or
          (F2Type.Management = tmCompiler)
  then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

procedure Tuple.T2TupleType<T1, T2>.DoDeserialize(const AInfo: TValueInfo;
  out AValue: Tuple<T1, T2>; const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the tuple }
  F1Type.Deserialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Deserialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);

  AContext.EndComplexType();
end;

procedure Tuple.T2TupleType<T1, T2>.DoSerialize(const AInfo: TValueInfo;
  const AValue: Tuple<T1, T2>; const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the tuple }
  F1Type.Serialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Serialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);

  AContext.EndComplexType();
end;

function Tuple.T2TupleType<T1, T2>.GenerateHashCode(const AValue: Tuple<T1, T2>): NativeInt;
begin
  Result := F1Type.GenerateHashCode(AValue.FValue1) xor
            F2Type.GenerateHashCode(AValue.FValue2);
end;

function Tuple.T2TupleType<T1, T2>.GetString(const AValue: Tuple<T1, T2>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S2Tuple, [
    F1Type.GetString(AValue.FValue1),
    F2Type.GetString(AValue.FValue2)
  ]);
end;

function Tuple.T2TupleType<T1, T2>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function Tuple.T2TupleType<T1, T2>.TryConvertFromVariant(const AValue: Variant; out ORes: Tuple<T1, T2>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 2) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := F1Type.TryConvertFromVariant(AValue[LBound], ORes.FValue1) and
              F2Type.TryConvertFromVariant(AValue[LBound + 1], ORes.FValue2);
  end else
    Result := false;
end;

function Tuple.T2TupleType<T1, T2>.TryConvertToVariant(const AValue: Tuple<T1, T2>; out ORes: Variant): Boolean;
var
  L1, L2: Variant;
begin
  if F1Type.TryConvertToVariant(AValue.FValue1, L1) and
     F2Type.TryConvertToVariant(AValue.FValue2, L2)
  then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1, L2]);
    Result := true;
  end else
    Result := false;
end;

{ Tuple.T3TupleType<T1, T2, T3> }

procedure Tuple.T3TupleType<T1, T2, T3>.Cleanup(var AValue: Tuple<T1, T2, T3>);
begin
  if Management = tmManual then
  begin
    if F1Type.Management = tmManual then
      F1Type.Cleanup(AValue.FValue1);

    if F2Type.Management = tmManual then
      F2Type.Cleanup(AValue.FValue2);

    if F3Type.Management = tmManual then
      F3Type.Cleanup(AValue.FValue3);
  end;
end;

function Tuple.T3TupleType<T1, T2, T3>.Compare(const AValue1, AValue2: Tuple<T1, T2, T3>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := F1Type.Compare(AValue1.FValue1, AValue2.FValue1);

  if Result = 0 then
    Result := F2Type.Compare(AValue1.FValue2, AValue2.FValue2);

  if Result = 0 then
    Result := F3Type.Compare(AValue1.FValue3, AValue2.FValue3);
end;

constructor Tuple.T3TupleType<T1, T2, T3>.Create;
begin
  Create(TType<T1>.Default, TType<T2>.Default, TType<T3>.Default);
end;

constructor Tuple.T3TupleType<T1, T2, T3>.Create(const A1Type: IType<T1>; const A2Type: IType<T2>; const A3Type: IType<T3>);
begin
  inherited Create();

  if A1Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A1Type');

  if A2Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A2Type');

  if A3Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A3Type');

  { Obtain the type classes }
  F1Type := A1Type;
  F2Type := A2Type;
  F3Type := A3Type;

  { If at least one is manual, declare as manual }
  if (F1Type.Management = tmManual) or
     (F2Type.Management = tmManual) or
     (F3Type.Management = tmManual)
  then
    FTypeManagement := tmManual
  else if (F1Type.Management = tmCompiler) or
          (F2Type.Management = tmCompiler) or
          (F3Type.Management = tmCompiler)
  then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

procedure Tuple.T3TupleType<T1, T2, T3>.DoDeserialize(const AInfo: TValueInfo;
  out AValue: Tuple<T1, T2, T3>; const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the tuple }
  F1Type.Deserialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Deserialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Deserialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);

  AContext.EndComplexType();
end;

procedure Tuple.T3TupleType<T1, T2, T3>.DoSerialize(const AInfo: TValueInfo;
  const AValue: Tuple<T1, T2, T3>; const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the tuple }
  F1Type.Serialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Serialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Serialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);

  AContext.EndComplexType();
end;

function Tuple.T3TupleType<T1, T2, T3>.GenerateHashCode(const AValue: Tuple<T1, T2, T3>): NativeInt;
begin
  Result := F1Type.GenerateHashCode(AValue.FValue1) xor
            F2Type.GenerateHashCode(AValue.FValue2) xor
            F3Type.GenerateHashCode(AValue.FValue3);
end;

function Tuple.T3TupleType<T1, T2, T3>.GetString(const AValue: Tuple<T1, T2, T3>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S3Tuple, [
    F1Type.GetString(AValue.FValue1),
    F2Type.GetString(AValue.FValue2),
    F3Type.GetString(AValue.FValue3)
  ]);
end;

function Tuple.T3TupleType<T1, T2, T3>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function Tuple.T3TupleType<T1, T2, T3>.TryConvertFromVariant(
  const AValue: Variant; out ORes: Tuple<T1, T2, T3>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 3) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := F1Type.TryConvertFromVariant(AValue[LBound], ORes.FValue1) and
              F2Type.TryConvertFromVariant(AValue[LBound + 1], ORes.FValue2) and
              F3Type.TryConvertFromVariant(AValue[LBound + 2], ORes.FValue3);
  end else
    Result := false;
end;

function Tuple.T3TupleType<T1, T2, T3>.TryConvertToVariant(
  const AValue: Tuple<T1, T2, T3>; out ORes: Variant): Boolean;
var
  L1, L2, L3: Variant;
begin
  if F1Type.TryConvertToVariant(AValue.FValue1, L1) and
     F2Type.TryConvertToVariant(AValue.FValue2, L2) and
     F3Type.TryConvertToVariant(AValue.FValue3, L3)
  then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1, L2, L3]);
    Result := true;
  end else
    Result := false;
end;

{ Tuple.T4TupleType<T1, T2, T3, T4> }

procedure Tuple.T4TupleType<T1, T2, T3, T4>.Cleanup(
  var AValue: Tuple<T1, T2, T3, T4>);
begin
  if Management = tmManual then
  begin
    if F1Type.Management = tmManual then
      F1Type.Cleanup(AValue.FValue1);

    if F2Type.Management = tmManual then
      F2Type.Cleanup(AValue.FValue2);

    if F3Type.Management = tmManual then
      F3Type.Cleanup(AValue.FValue3);

    if F4Type.Management = tmManual then
      F4Type.Cleanup(AValue.FValue4);
  end;
end;

function Tuple.T4TupleType<T1, T2, T3, T4>.Compare(const AValue1,
  AValue2: Tuple<T1, T2, T3, T4>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := F1Type.Compare(AValue1.FValue1, AValue2.FValue1);

  if Result = 0 then
    Result := F2Type.Compare(AValue1.FValue2, AValue2.FValue2);

  if Result = 0 then
    Result := F3Type.Compare(AValue1.FValue3, AValue2.FValue3);

  if Result = 0 then
    Result := F4Type.Compare(AValue1.FValue4, AValue2.FValue4);
end;

constructor Tuple.T4TupleType<T1, T2, T3, T4>.Create;
begin
  Create(TType<T1>.Default, TType<T2>.Default,
    TType<T3>.Default, TType<T4>.Default);
end;

constructor Tuple.T4TupleType<T1, T2, T3, T4>.Create(const A1Type: IType<T1>;
  const A2Type: IType<T2>; const A3Type: IType<T3>; const A4Type: IType<T4>);
begin
  inherited Create();

  if A1Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A1Type');

  if A2Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A2Type');

  if A3Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A3Type');

  if A4Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A4Type');

  { Obtain the type classes }
  F1Type := A1Type;
  F2Type := A2Type;
  F3Type := A3Type;
  F4Type := A4Type;

  { If at least one is manual, declare as manual }
  if (F1Type.Management = tmManual) or
     (F2Type.Management = tmManual) or
     (F3Type.Management = tmManual) or
     (F4Type.Management = tmManual)
  then
    FTypeManagement := tmManual
  else if (F1Type.Management = tmCompiler) or
          (F2Type.Management = tmCompiler) or
          (F3Type.Management = tmCompiler) or
          (F4Type.Management = tmCompiler)
  then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

procedure Tuple.T4TupleType<T1, T2, T3, T4>.DoDeserialize(
  const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4>;
  const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the tuple }
  F1Type.Deserialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Deserialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Deserialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Deserialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);

  AContext.EndComplexType();
end;

procedure Tuple.T4TupleType<T1, T2, T3, T4>.DoSerialize(const AInfo: TValueInfo;
  const AValue: Tuple<T1, T2, T3, T4>; const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the tuple }
  F1Type.Serialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Serialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Serialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Serialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);

  AContext.EndComplexType();
end;

function Tuple.T4TupleType<T1, T2, T3, T4>.GenerateHashCode(
  const AValue: Tuple<T1, T2, T3, T4>): NativeInt;
begin
  Result := F1Type.GenerateHashCode(AValue.FValue1) xor
            F2Type.GenerateHashCode(AValue.FValue2) xor
            F3Type.GenerateHashCode(AValue.FValue3) xor
            F4Type.GenerateHashCode(AValue.FValue4);
end;

function Tuple.T4TupleType<T1, T2, T3, T4>.GetString(
  const AValue: Tuple<T1, T2, T3, T4>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S4Tuple, [
    F1Type.GetString(AValue.FValue1),
    F2Type.GetString(AValue.FValue2),
    F3Type.GetString(AValue.FValue3),
    F4Type.GetString(AValue.FValue4)
  ]);
end;

function Tuple.T4TupleType<T1, T2, T3, T4>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function Tuple.T4TupleType<T1, T2, T3, T4>.TryConvertFromVariant(
  const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 4) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := F1Type.TryConvertFromVariant(AValue[LBound], ORes.FValue1) and
              F2Type.TryConvertFromVariant(AValue[LBound + 1], ORes.FValue2) and
              F3Type.TryConvertFromVariant(AValue[LBound + 2], ORes.FValue3) and
              F4Type.TryConvertFromVariant(AValue[LBound + 3], ORes.FValue4);
  end else
    Result := false;
end;

function Tuple.T4TupleType<T1, T2, T3, T4>.TryConvertToVariant(
  const AValue: Tuple<T1, T2, T3, T4>; out ORes: Variant): Boolean;
var
  L1, L2, L3, L4: Variant;
begin
  if F1Type.TryConvertToVariant(AValue.FValue1, L1) and
     F2Type.TryConvertToVariant(AValue.FValue2, L2) and
     F3Type.TryConvertToVariant(AValue.FValue3, L3) and
     F4Type.TryConvertToVariant(AValue.FValue4, L4)
  then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1, L2, L3, L4]);
    Result := true;
  end else
    Result := false;
end;

{ Tuple.T5TupleType<T1, T2, T3, T4, T5> }

procedure Tuple.T5TupleType<T1, T2, T3, T4, T5>.Cleanup(
  var AValue: Tuple<T1, T2, T3, T4, T5>);
begin
  if Management = tmManual then
  begin
    if F1Type.Management = tmManual then
      F1Type.Cleanup(AValue.FValue1);

    if F2Type.Management = tmManual then
      F2Type.Cleanup(AValue.FValue2);

    if F3Type.Management = tmManual then
      F3Type.Cleanup(AValue.FValue3);

    if F4Type.Management = tmManual then
      F4Type.Cleanup(AValue.FValue4);

    if F5Type.Management = tmManual then
      F5Type.Cleanup(AValue.FValue5);
  end;
end;

function Tuple.T5TupleType<T1, T2, T3, T4, T5>.Compare(const AValue1,
  AValue2: Tuple<T1, T2, T3, T4, T5>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := F1Type.Compare(AValue1.FValue1, AValue2.FValue1);

  if Result = 0 then
    Result := F2Type.Compare(AValue1.FValue2, AValue2.FValue2);

  if Result = 0 then
    Result := F3Type.Compare(AValue1.FValue3, AValue2.FValue3);

  if Result = 0 then
    Result := F4Type.Compare(AValue1.FValue4, AValue2.FValue4);

  if Result = 0 then
    Result := F5Type.Compare(AValue1.FValue5, AValue2.FValue5);
end;

constructor Tuple.T5TupleType<T1, T2, T3, T4, T5>.Create;
begin
  Create(TType<T1>.Default, TType<T2>.Default,
    TType<T3>.Default, TType<T4>.Default, TType<T5>.Default);
end;

constructor Tuple.T5TupleType<T1, T2, T3, T4, T5>.Create(
  const A1Type: IType<T1>; const A2Type: IType<T2>; const A3Type: IType<T3>;
  const A4Type: IType<T4>; const A5Type: IType<T5>);
begin
  inherited Create();

  if A1Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A1Type');

  if A2Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A2Type');

  if A3Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A3Type');

  if A4Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A4Type');

  if A5Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A5Type');

  { Obtain the type classes }
  F1Type := A1Type;
  F2Type := A2Type;
  F3Type := A3Type;
  F4Type := A4Type;
  F5Type := A5Type;

  { If at least one is manual, declare as manual }
  if (F1Type.Management = tmManual) or
     (F2Type.Management = tmManual) or
     (F3Type.Management = tmManual) or
     (F4Type.Management = tmManual) or
     (F5Type.Management = tmManual)
  then
    FTypeManagement := tmManual
  else if (F1Type.Management = tmCompiler) or
          (F2Type.Management = tmCompiler) or
          (F3Type.Management = tmCompiler) or
          (F4Type.Management = tmCompiler) or
          (F5Type.Management = tmCompiler)
  then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

procedure Tuple.T5TupleType<T1, T2, T3, T4, T5>.DoDeserialize(
  const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4, T5>;
  const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the tuple }
  F1Type.Deserialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Deserialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Deserialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Deserialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);
  F5Type.Deserialize(TValueInfo.Create(SValue5), AValue.FValue5, AContext);

  AContext.EndComplexType();
end;

procedure Tuple.T5TupleType<T1, T2, T3, T4, T5>.DoSerialize(
  const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3, T4, T5>;
  const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the tuple }
  F1Type.Serialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Serialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Serialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Serialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);
  F5Type.Serialize(TValueInfo.Create(SValue5), AValue.FValue5, AContext);

  AContext.EndComplexType();
end;

function Tuple.T5TupleType<T1, T2, T3, T4, T5>.GenerateHashCode(
  const AValue: Tuple<T1, T2, T3, T4, T5>): NativeInt;
begin
  Result := F1Type.GenerateHashCode(AValue.FValue1) xor
            F2Type.GenerateHashCode(AValue.FValue2) xor
            F3Type.GenerateHashCode(AValue.FValue3) xor
            F4Type.GenerateHashCode(AValue.FValue4) xor
            F5Type.GenerateHashCode(AValue.FValue5);
end;

function Tuple.T5TupleType<T1, T2, T3, T4, T5>.GetString(
  const AValue: Tuple<T1, T2, T3, T4, T5>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S5Tuple, [
    F1Type.GetString(AValue.FValue1),
    F2Type.GetString(AValue.FValue2),
    F3Type.GetString(AValue.FValue3),
    F4Type.GetString(AValue.FValue4),
    F5Type.GetString(AValue.FValue5)
  ]);
end;

function Tuple.T5TupleType<T1, T2, T3, T4, T5>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function Tuple.T5TupleType<T1, T2, T3, T4, T5>.TryConvertFromVariant(
  const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4, T5>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 5) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := F1Type.TryConvertFromVariant(AValue[LBound], ORes.FValue1) and
              F2Type.TryConvertFromVariant(AValue[LBound + 1], ORes.FValue2) and
              F3Type.TryConvertFromVariant(AValue[LBound + 2], ORes.FValue3) and
              F4Type.TryConvertFromVariant(AValue[LBound + 3], ORes.FValue4) and
              F5Type.TryConvertFromVariant(AValue[LBound + 4], ORes.FValue5);
  end else
    Result := false;
end;

function Tuple.T5TupleType<T1, T2, T3, T4, T5>.TryConvertToVariant(
  const AValue: Tuple<T1, T2, T3, T4, T5>; out ORes: Variant): Boolean;
var
  L1, L2, L3, L4, L5: Variant;
begin
  if F1Type.TryConvertToVariant(AValue.FValue1, L1) and
     F2Type.TryConvertToVariant(AValue.FValue2, L2) and
     F3Type.TryConvertToVariant(AValue.FValue3, L3) and
     F4Type.TryConvertToVariant(AValue.FValue4, L4) and
     F5Type.TryConvertToVariant(AValue.FValue5, L5)
  then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1, L2, L3, L4, L5]);
    Result := true;
  end else
    Result := false;
end;

{ Tuple.T6TupleType<T1, T2, T3, T4, T5, T6> }

procedure Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.Cleanup(
  var AValue: Tuple<T1, T2, T3, T4, T5, T6>);
begin
  if Management = tmManual then
  begin
    if F1Type.Management = tmManual then
      F1Type.Cleanup(AValue.FValue1);

    if F2Type.Management = tmManual then
      F2Type.Cleanup(AValue.FValue2);

    if F3Type.Management = tmManual then
      F3Type.Cleanup(AValue.FValue3);

    if F4Type.Management = tmManual then
      F4Type.Cleanup(AValue.FValue4);

    if F5Type.Management = tmManual then
      F5Type.Cleanup(AValue.FValue5);

    if F6Type.Management = tmManual then
      F6Type.Cleanup(AValue.FValue6);
  end;
end;

function Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.Compare(const AValue1,
  AValue2: Tuple<T1, T2, T3, T4, T5, T6>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := F1Type.Compare(AValue1.FValue1, AValue2.FValue1);

  if Result = 0 then
    Result := F2Type.Compare(AValue1.FValue2, AValue2.FValue2);

  if Result = 0 then
    Result := F3Type.Compare(AValue1.FValue3, AValue2.FValue3);

  if Result = 0 then
    Result := F4Type.Compare(AValue1.FValue4, AValue2.FValue4);

  if Result = 0 then
    Result := F5Type.Compare(AValue1.FValue5, AValue2.FValue5);

  if Result = 0 then
    Result := F6Type.Compare(AValue1.FValue6, AValue2.FValue6);
end;

constructor Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.Create;
begin
  Create(TType<T1>.Default, TType<T2>.Default,
    TType<T3>.Default, TType<T4>.Default, TType<T5>.Default, TType<T6>.Default);
end;

constructor Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.Create(
  const A1Type: IType<T1>; const A2Type: IType<T2>; const A3Type: IType<T3>;
  const A4Type: IType<T4>; const A5Type: IType<T5>; const A6Type: IType<T6>);
begin
  inherited Create();

  if A1Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A1Type');

  if A2Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A2Type');

  if A3Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A3Type');

  if A4Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A4Type');

  if A5Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A5Type');

  if A6Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A6Type');

  { Obtain the type classes }
  F1Type := A1Type;
  F2Type := A2Type;
  F3Type := A3Type;
  F4Type := A4Type;
  F5Type := A5Type;
  F6Type := A6Type;

  { If at least one is manual, declare as manual }
  if (F1Type.Management = tmManual) or
     (F2Type.Management = tmManual) or
     (F3Type.Management = tmManual) or
     (F4Type.Management = tmManual) or
     (F5Type.Management = tmManual) or
     (F6Type.Management = tmManual)
  then
    FTypeManagement := tmManual
  else if (F1Type.Management = tmCompiler) or
          (F2Type.Management = tmCompiler) or
          (F3Type.Management = tmCompiler) or
          (F4Type.Management = tmCompiler) or
          (F5Type.Management = tmCompiler) or
          (F6Type.Management = tmCompiler)
  then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

procedure Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.DoDeserialize(
  const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4, T5, T6>;
  const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the tuple }
  F1Type.Deserialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Deserialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Deserialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Deserialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);
  F5Type.Deserialize(TValueInfo.Create(SValue5), AValue.FValue5, AContext);
  F6Type.Deserialize(TValueInfo.Create(SValue6), AValue.FValue6, AContext);

  AContext.EndComplexType();
end;

procedure Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.DoSerialize(
  const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3, T4, T5, T6>;
  const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the tuple }
  F1Type.Serialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Serialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Serialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Serialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);
  F5Type.Serialize(TValueInfo.Create(SValue5), AValue.FValue5, AContext);
  F6Type.Serialize(TValueInfo.Create(SValue6), AValue.FValue6, AContext);

  AContext.EndComplexType();
end;

function Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.GenerateHashCode(
  const AValue: Tuple<T1, T2, T3, T4, T5, T6>): NativeInt;
begin
  Result := F1Type.GenerateHashCode(AValue.FValue1) xor
            F2Type.GenerateHashCode(AValue.FValue2) xor
            F3Type.GenerateHashCode(AValue.FValue3) xor
            F4Type.GenerateHashCode(AValue.FValue4) xor
            F5Type.GenerateHashCode(AValue.FValue5) xor
            F6Type.GenerateHashCode(AValue.FValue6);
end;

function Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.GetString(
  const AValue: Tuple<T1, T2, T3, T4, T5, T6>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S6Tuple, [
    F1Type.GetString(AValue.FValue1),
    F2Type.GetString(AValue.FValue2),
    F3Type.GetString(AValue.FValue3),
    F4Type.GetString(AValue.FValue4),
    F5Type.GetString(AValue.FValue5),
    F6Type.GetString(AValue.FValue6)
  ]);
end;

function Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.TryConvertFromVariant(
  const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4, T5, T6>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 6) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := F1Type.TryConvertFromVariant(AValue[LBound], ORes.FValue1) and
              F2Type.TryConvertFromVariant(AValue[LBound + 1], ORes.FValue2) and
              F3Type.TryConvertFromVariant(AValue[LBound + 2], ORes.FValue3) and
              F4Type.TryConvertFromVariant(AValue[LBound + 3], ORes.FValue4) and
              F5Type.TryConvertFromVariant(AValue[LBound + 4], ORes.FValue5) and
              F6Type.TryConvertFromVariant(AValue[LBound + 5], ORes.FValue6);
  end else
    Result := false;
end;

function Tuple.T6TupleType<T1, T2, T3, T4, T5, T6>.TryConvertToVariant(
  const AValue: Tuple<T1, T2, T3, T4, T5, T6>; out ORes: Variant): Boolean;
var
  L1, L2, L3, L4, L5, L6: Variant;
begin
  if F1Type.TryConvertToVariant(AValue.FValue1, L1) and
     F2Type.TryConvertToVariant(AValue.FValue2, L2) and
     F3Type.TryConvertToVariant(AValue.FValue3, L3) and
     F4Type.TryConvertToVariant(AValue.FValue4, L4) and
     F5Type.TryConvertToVariant(AValue.FValue5, L5) and
     F6Type.TryConvertToVariant(AValue.FValue6, L6)
  then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1, L2, L3, L4, L5, L6]);
    Result := true;
  end else
    Result := false;
end;

{ Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7> }

procedure Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.Cleanup(
  var AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>);
begin
  if Management = tmManual then
  begin
    if F1Type.Management = tmManual then
      F1Type.Cleanup(AValue.FValue1);

    if F2Type.Management = tmManual then
      F2Type.Cleanup(AValue.FValue2);

    if F3Type.Management = tmManual then
      F3Type.Cleanup(AValue.FValue3);

    if F4Type.Management = tmManual then
      F4Type.Cleanup(AValue.FValue4);

    if F5Type.Management = tmManual then
      F5Type.Cleanup(AValue.FValue5);

    if F6Type.Management = tmManual then
      F6Type.Cleanup(AValue.FValue6);

    if F7Type.Management = tmManual then
      F7Type.Cleanup(AValue.FValue7);
  end;
end;

function Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.Compare(const AValue1,
  AValue2: Tuple<T1, T2, T3, T4, T5, T6, T7>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := F1Type.Compare(AValue1.FValue1, AValue2.FValue1);

  if Result = 0 then
    Result := F2Type.Compare(AValue1.FValue2, AValue2.FValue2);

  if Result = 0 then
    Result := F3Type.Compare(AValue1.FValue3, AValue2.FValue3);

  if Result = 0 then
    Result := F4Type.Compare(AValue1.FValue4, AValue2.FValue4);

  if Result = 0 then
    Result := F5Type.Compare(AValue1.FValue5, AValue2.FValue5);

  if Result = 0 then
    Result := F6Type.Compare(AValue1.FValue6, AValue2.FValue6);

  if Result = 0 then
    Result := F7Type.Compare(AValue1.FValue7, AValue2.FValue7);
end;

constructor Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.Create;
begin
  Create(TType<T1>.Default, TType<T2>.Default,
    TType<T3>.Default, TType<T4>.Default, TType<T5>.Default, TType<T6>.Default,
    TType<T7>.Default);
end;

constructor Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.Create(
  const A1Type: IType<T1>; const A2Type: IType<T2>; const A3Type: IType<T3>;
  const A4Type: IType<T4>; const A5Type: IType<T5>; const A6Type: IType<T6>;
  const A7Type: IType<T7>);
begin
  inherited Create();

  if A1Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A1Type');

  if A2Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A2Type');

  if A3Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A3Type');

  if A4Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A4Type');

  if A5Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A5Type');

  if A6Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A6Type');

  if A7Type = nil then
    ExceptionHelper.Throw_ArgumentNilError('A7Type');

  { Obtain the type classes }
  F1Type := A1Type;
  F2Type := A2Type;
  F3Type := A3Type;
  F4Type := A4Type;
  F5Type := A5Type;
  F6Type := A6Type;
  F7Type := A7Type;

  { If at least one is manual, declare as manual }
  if (F1Type.Management = tmManual) or
     (F2Type.Management = tmManual) or
     (F3Type.Management = tmManual) or
     (F4Type.Management = tmManual) or
     (F5Type.Management = tmManual) or
     (F6Type.Management = tmManual) or
     (F7Type.Management = tmManual)
  then
    FTypeManagement := tmManual
  else if (F1Type.Management = tmCompiler) or
          (F2Type.Management = tmCompiler) or
          (F3Type.Management = tmCompiler) or
          (F4Type.Management = tmCompiler) or
          (F5Type.Management = tmCompiler) or
          (F6Type.Management = tmCompiler) or
          (F7Type.Management = tmCompiler)
  then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

procedure Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.DoDeserialize(
  const AInfo: TValueInfo; out AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>;
  const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the tuple }
  F1Type.Deserialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Deserialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Deserialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Deserialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);
  F5Type.Deserialize(TValueInfo.Create(SValue5), AValue.FValue5, AContext);
  F6Type.Deserialize(TValueInfo.Create(SValue6), AValue.FValue6, AContext);
  F7Type.Deserialize(TValueInfo.Create(SValue7), AValue.FValue7, AContext);

  AContext.EndComplexType();
end;

procedure Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.DoSerialize(
  const AInfo: TValueInfo; const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>;
  const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the tuple }
  F1Type.Serialize(TValueInfo.Create(SValue1), AValue.FValue1, AContext);
  F2Type.Serialize(TValueInfo.Create(SValue2), AValue.FValue2, AContext);
  F3Type.Serialize(TValueInfo.Create(SValue3), AValue.FValue3, AContext);
  F4Type.Serialize(TValueInfo.Create(SValue4), AValue.FValue4, AContext);
  F5Type.Serialize(TValueInfo.Create(SValue5), AValue.FValue5, AContext);
  F6Type.Serialize(TValueInfo.Create(SValue6), AValue.FValue6, AContext);
  F7Type.Serialize(TValueInfo.Create(SValue7), AValue.FValue7, AContext);

  AContext.EndComplexType();
end;

function Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.GenerateHashCode(
  const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>): NativeInt;
begin
  Result := F1Type.GenerateHashCode(AValue.FValue1) xor
            F2Type.GenerateHashCode(AValue.FValue2) xor
            F3Type.GenerateHashCode(AValue.FValue3) xor
            F4Type.GenerateHashCode(AValue.FValue4) xor
            F5Type.GenerateHashCode(AValue.FValue5) xor
            F6Type.GenerateHashCode(AValue.FValue6) xor
            F7Type.GenerateHashCode(AValue.FValue7);
end;

function Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.GetString(
  const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S7Tuple, [
    F1Type.GetString(AValue.FValue1),
    F2Type.GetString(AValue.FValue2),
    F3Type.GetString(AValue.FValue3),
    F4Type.GetString(AValue.FValue4),
    F5Type.GetString(AValue.FValue5),
    F6Type.GetString(AValue.FValue6),
    F7Type.GetString(AValue.FValue7)
  ]);
end;

function Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.TryConvertFromVariant(
  const AValue: Variant; out ORes: Tuple<T1, T2, T3, T4, T5, T6, T7>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 7) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := F1Type.TryConvertFromVariant(AValue[LBound], ORes.FValue1) and
              F2Type.TryConvertFromVariant(AValue[LBound + 1], ORes.FValue2) and
              F3Type.TryConvertFromVariant(AValue[LBound + 2], ORes.FValue3) and
              F4Type.TryConvertFromVariant(AValue[LBound + 3], ORes.FValue4) and
              F5Type.TryConvertFromVariant(AValue[LBound + 4], ORes.FValue5) and
              F6Type.TryConvertFromVariant(AValue[LBound + 5], ORes.FValue6) and
              F7Type.TryConvertFromVariant(AValue[LBound + 6], ORes.FValue7);
  end else
    Result := false;
end;

function Tuple.T7TupleType<T1, T2, T3, T4, T5, T6, T7>.TryConvertToVariant(
  const AValue: Tuple<T1, T2, T3, T4, T5, T6, T7>; out ORes: Variant): Boolean;
var
  L1, L2, L3, L4, L5, L6, L7: Variant;
begin
  if F1Type.TryConvertToVariant(AValue.FValue1, L1) and
     F2Type.TryConvertToVariant(AValue.FValue2, L2) and
     F3Type.TryConvertToVariant(AValue.FValue3, L3) and
     F4Type.TryConvertToVariant(AValue.FValue4, L4) and
     F5Type.TryConvertToVariant(AValue.FValue5, L5) and
     F6Type.TryConvertToVariant(AValue.FValue6, L6) and
     F7Type.TryConvertToVariant(AValue.FValue7, L7)
  then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1, L2, L3, L4, L5, L6, L7]);
    Result := true;
  end else
    Result := false;
end;

{ KVPair }

class function KVPair.Create<TKey, TValue>(const AKey: TKey; const AValue: TValue): KVPair<TKey, TValue>;
begin
  Result.FKey := AKey;
  Result.FValue := AValue;
end;

class function KVPair.GetType<TKey, TValue>(const AKeyType: IType<TKey>; const AValueType: IType<TValue>): IType<KVPair<TKey, TValue>>;
begin
  Result := TKVPairType<TKey, TValue>.Create(AKeyType, AValueType);
end;

{ KVPair.TKVPairType<TKey, TValue> }

procedure KVPair.TKVPairType<TKey, TValue>.Cleanup(var AValue: KVPair<TKey, TValue>);
begin
  if Management = tmManual then
  begin
    if FKeyType.Management = tmManual then
      FKeyType.Cleanup(AValue.FKey);

    if FValueType.Management = tmManual then
      FValueType.Cleanup(AValue.FValue);
  end;
end;

function KVPair.TKVPairType<TKey, TValue>.Compare(const AValue1, AValue2: KVPair<TKey, TValue>): NativeInt;
begin
  { First compare the keys and only then the values }
  Result := FKeyType.Compare(AValue1.FKey, AValue2.FKey);

  if Result = 0 then
    Result := FValueType.Compare(AValue1.FValue, AValue2.FValue);
end;

constructor KVPair.TKVPairType<TKey, TValue>.Create;
begin
  Create(TType<TKey>.Default, TType<TValue>.Default);
end;

constructor KVPair.TKVPairType<TKey, TValue>.Create(const AKeyType: IType<TKey>; const AValueType: IType<TValue>);
begin
  inherited Create();

  if AKeyType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AKeyType');

  if AValueType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AValueType');

  { Obtain the type classes }
  FKeyType := AKeyType;
  FValueType := AValueType;

  { If at least one is manual, declare as manual }
  if (FKeyType.Management = tmManual) or
     (FValueType.Management = tmManual)
  then
    FTypeManagement := tmManual
  else if (FKeyType.Management = tmCompiler) or
          (FValueType.Management = tmCompiler)
  then
    FTypeManagement := tmCompiler
  else
    FTypeManagement := tmNone;
end;

procedure KVPair.TKVPairType<TKey, TValue>.DoDeserialize(const AInfo: TValueInfo;
  out AValue: KVPair<TKey, TValue>; const AContext: IDeserializationContext);
begin
  AContext.ExpectRecordType(AInfo);

  { Deserialize each element of the KVPair }
  FKeyType.Deserialize(TValueInfo.Create(SSerKey), AValue.FKey, AContext);
  FValueType.Deserialize(TValueInfo.Create(SSerValue), AValue.FValue, AContext);

  AContext.EndComplexType();
end;

procedure KVPair.TKVPairType<TKey, TValue>.DoSerialize(const AInfo: TValueInfo;
  const AValue: KVPair<TKey, TValue>; const AContext: ISerializationContext);
begin
  AContext.StartRecordType(AInfo);

  { Serialize each element of the KVPair }
  FKeyType.Serialize(TValueInfo.Create(SSerKey), AValue.FKey, AContext);
  FValueType.Serialize(TValueInfo.Create(SSerValue), AValue.FValue, AContext);

  AContext.EndComplexType();
end;

function KVPair.TKVPairType<TKey, TValue>.GenerateHashCode(const AValue: KVPair<TKey, TValue>): NativeInt;
begin
  Result := FKeyType.GenerateHashCode(AValue.FKey) xor
            FValueType.GenerateHashCode(AValue.FValue);
end;

function KVPair.TKVPairType<TKey, TValue>.GetString(const AValue: KVPair<TKey, TValue>): String;
begin
  { Combine the strings of both key and value into one }
  Result := Format(S2Tuple, [
    FKeyType.GetString(AValue.FKey),
    FValueType.GetString(AValue.FValue)
  ]);
end;

function KVPair.TKVPairType<TKey, TValue>.Management: TTypeManagement;
begin
  Result := FTypeManagement;
end;

function KVPair.TKVPairType<TKey, TValue>.TryConvertFromVariant(const AValue: Variant; out ORes: KVPair<TKey, TValue>): Boolean;
var
  LVarType: TVarType;
  LBound: NativeInt;
begin
  LVarType := VarType(AValue);

  if (LVarType = (varArray or varVariant)) and (VarArrayDimCount(AValue) = 1) and
     ((VarArrayHighBound(AValue, 1) - VarArrayLowBound(AValue, 1) + 1) = 2) then
  begin
    LBound := VarArrayLowBound(AValue, 1);

    { This is a variant array, let's crack it open }
    Result := FKeyType.TryConvertFromVariant(AValue[LBound], ORes.FKey) and
              FValueType.TryConvertFromVariant(AValue[LBound + 1], ORes.FValue);
  end else
    Result := false;
end;

function KVPair.TKVPairType<TKey, TValue>.TryConvertToVariant(const AValue: KVPair<TKey, TValue>; out ORes: Variant): Boolean;
var
  L1, L2: Variant;
begin
  if FKeyType.TryConvertToVariant(AValue.FKey, L1) and
     FValueType.TryConvertToVariant(AValue.FValue, L2)
  then
  begin
    { Create the variant array }
    ORes := VarArrayOf([L1, L2]);
    Result := true;
  end else
    Result := false;
end;

end.
