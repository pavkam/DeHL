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
unit DeHL.Collections.SortedBag;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.StrConsts,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Collections.Base,
     DeHL.Collections.Abstract,
     DeHL.Collections.SortedDictionary;

type
  ///  <summary>The generic <c>bag</c> collection.</summary>
  ///  <remarks>This type uses an AVL tree to store its values.</remarks>
  TSortedBag<T> = class(TAbstractBag<T>)
  private var
    FAscSort: Boolean;

  protected
    ///  <summary>Called when the bag needs to initialize its internal dictionary.</summary>
    ///  <param name="AType">The type object describing the bag's elements.</param>
    ///  <remarks>This method creates an AVL-based dictionary used as the underlying back-end for the bag.</remarks>
    function CreateDictionary(const AType: IType<T>): IDictionary<T, NativeUInt>; override;

    ///  <summary>Called when the serialization process is about to begin.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    procedure StartSerializing(const AData: TSerializationData); override;

    ///  <summary>Called when the deserialization process is about to begin.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartDeserializing(const AData: TDeserializationData); override;

    ///  <summary>Called when the an element has been deserialized and needs to be inserted into the bag.</summary>
    ///  <param name="AElement">The element that was deserialized.</param>
    ///  <remarks>This method simply adds the element to the bag.</remarks>
    procedure DeserializeElement(const AElement: T); override;
  public
    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const ACollection: IEnumerable<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: array of T; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TDynamicArray<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <remarks>The default type object is requested.</remarks>
    constructor Create(const AArray: TFixedArray<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const ACollection: IEnumerable<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: array of T; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TDynamicArray<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the bag.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>; const AAscending: Boolean = true); overload;

  end;

  ///  <summary>The generic <c>bag</c> collection designed to store objects.</summary>
  ///  <remarks>This type uses an AVL tree to store its objects.</remarks>
  TObjectSortedBag<T: class> = class(TSortedBag<T>)
  private
    FWrapperType: TObjectWrapperType<T>;

    { Getters/Setters for OwnsObjects }
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);

  protected
    ///  <summary>Installs the type object.</summary>
    ///  <param name="AType">The type object to install.</param>
    ///  <remarks>This method installs a custom wrapper designed to suppress the cleanup of objects on request. Make sure to call this method in
    ///  descendant classes.</remarks>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    procedure InstallType(const AType: IType<T>); override;

  public
    ///  <summary>Specifies whether this bag owns the objects stored in it.</summary>
    ///  <returns><c>True</c> if the bag owns its objects; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the bag controls the life-time of the stored objects.</remarks>
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

{ TSortedBag<T> }

constructor TSortedBag<T>.Create(const AArray: TFixedArray<T>; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AArray);
end;

constructor TSortedBag<T>.Create(const AArray: TDynamicArray<T>; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AArray);
end;

constructor TSortedBag<T>.Create(const AType: IType<T>; const AArray: TFixedArray<T>; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AType, AArray);
end;

function TSortedBag<T>.CreateDictionary(const AType: IType<T>): IDictionary<T, NativeUInt>;
begin
  { Create a sorted dictionary }
  Result := TSortedDictionary<T, NativeUInt>.Create(AType, TType<NativeUInt>.Default, FAscSort);
end;

procedure TSortedBag<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Add(AElement);
end;

procedure TSortedBag<T>.StartDeserializing(const AData: TDeserializationData);
var
  LAsc: Boolean;
begin
  AData.GetValue(SSerAscendingKeys, LAsc);

  { Call the constructor in this instance to initialize myself first }
  Create(LAsc);
end;

procedure TSortedBag<T>.StartSerializing(const AData: TSerializationData);
begin
  { Write the ascending sign }
  AData.AddValue(SSerAscendingKeys, FAscSort);
end;

constructor TSortedBag<T>.Create(const AType: IType<T>; const AArray: TDynamicArray<T>; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AType, AArray);
end;

constructor TSortedBag<T>.Create(const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create();
end;

constructor TSortedBag<T>.Create(const ACollection: IEnumerable<T>; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(ACollection);
end;

constructor TSortedBag<T>.Create(const AType: IType<T>; const ACollection: IEnumerable<T>; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AType, ACollection);
end;

constructor TSortedBag<T>.Create(const AType: IType<T>; const AArray: array of T; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AType, AArray);
end;

constructor TSortedBag<T>.Create(const AType: IType<T>; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AType);
end;

constructor TSortedBag<T>.Create(const AArray: array of T; const AAscending: Boolean);
begin
  { Call upper constructor }
  FAscSort := AAscending;
  inherited Create(AArray);
end;

{ TObjectSortedBag<T> }

procedure TObjectSortedBag<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectSortedBag<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectSortedBag<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;

end.
