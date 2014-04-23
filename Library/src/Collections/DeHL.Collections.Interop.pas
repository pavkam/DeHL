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

{$I ../DeHL.Defines.inc}
{$OPTIMIZATION OFF}
unit DeHL.Collections.Interop;
interface
uses
  SysUtils,
  Windows,
  Classes,
  WideStrings,
  Contnrs,
  DeHL.Base,
  DeHl.Box,
  DeHL.Arrays,
  DeHL.Exceptions,
  DeHL.Types,
  DeHL.Tuples,
  DeHL.Collections.Base,
  Generics.Collections;

type
  { A custom type used to wrap VCL collections }
  //TODO: doc me
  TVCLCollection = class sealed
  public
    { Statics allowing wrapping around generic VCL containers }
    //TODO: doc me
    class function Wrap<T>(const AEnumerable: TEnumerable<T>;
        const OwnsInstance: Boolean = false): IEnexCollection<T>; overload; static;

    //TODO: doc me
    class function Wrap<TKey, TValue>(const AEnumerable: TEnumerable<TPair<TKey, TValue>>;
        const OwnsInstance: Boolean = false): IEnexAssociativeCollection<TKey, TValue>; overload; static;

    { Classes: Static allowing wrapping of old-style VCL containers }
    //TODO: doc me
    class function Wrap(const AList: TList; const OwnsInstance: Boolean = false): IEnexCollection<Pointer>; overload; static;
    //TODO: doc me
    class function Wrap(const AStrings: TStrings; const OwnsInstance: Boolean = false): IEnexCollection<String>; overload; static;
    //TODO: doc me
    class function Wrap(const AStrings: TWideStrings; const OwnsInstance: Boolean = false): IEnexCollection<WideString>; overload; static;
    //TODO: doc me
    class function Wrap(const AList: TInterfaceList; const OwnsInstance: Boolean = false): IEnexCollection<IInterface>; overload; static;
    //TODO: doc me
    class function Wrap(const ACollection: TCollection; const OwnsInstance: Boolean = false): IEnexCollection<TCollectionItem>; overload; static;
    //TODO: doc me
    class function Wrap(const AComponent: TComponent; const OwnsInstance: Boolean = false): IEnexCollection<TComponent>; overload; static;

    { Contnrs: Static allowing wrapping of old-style VCL containers }
    //TODO: doc me
    class function Wrap(const AList: TObjectList; const OwnsInstance: Boolean = false): IEnexCollection<TObject>; overload; static;
    //TODO: doc me
    class function Wrap(const AList: TComponentList; const OwnsInstance: Boolean = false): IEnexCollection<TComponent>; overload; static;
    //TODO: doc me
    class function Wrap(const AList: TClassList; const OwnsInstance: Boolean = false): IEnexCollection<TClass>; overload; static;

    { Back-interop -- building up Generics.Collection containers out of Enex }
    //TODO: doc me
    class function From<T>(const ACollection: TCollection<T>): TEnumerable<T>; overload; static;
    //TODO: doc me
    class function From<TKey, TValue>(const ACollection: TCollection<KVPair<TKey, TValue>>): TEnumerable<TPair<TKey, TValue>>; overload; static;

    //TODO: doc me
    class function From<T>(const ACollection: IEnexCollection<T>): TEnumerable<T>; overload; static;
    //TODO: doc me
    class function From<TKey, TValue>(const ACollection: IEnexAssociativeCollection<TKey, TValue>): TEnumerable<TPair<TKey, TValue>>; overload;

  private type
    {$REGION 'Internal Collection Types'}
    { The "VCL Wrap" collection }
    TEnexVCLWrapCollection<T> = class sealed(TEnexCollection<T>)
    private
    type
      { The "VCL Wrap" enumerator }
      TEnumerator = class(DeHL.Collections.Base.TEnumerator<T>)
      private
        FEnum: TEnexVCLWrapCollection<T>;
        FIter: Generics.Collections.TEnumerator<T>;

      public
        { Constructor }
        constructor Create(const AEnum: TEnexVCLWrapCollection<T>);

        { Destructor }
        destructor Destroy(); override;

        function GetCurrent(): T; override;
        function MoveNext(): Boolean; override;
      end;

    var
      FEnum: Generics.Collections.TEnumerable<T>;
      FOwns: Boolean;

    public
      { Constructors }
      constructor Create(const AEnumerable: TEnumerable<T>; const AType: IType<T>; const OwnsInstance: Boolean); overload;

      { Destructor }
      destructor Destroy(); override;

      { IEnumerable<T> }
      function GetEnumerator(): IEnumerator<T>; override;
    end;

    { The "Assoc VCL Wrap" collection }
    TEnexAssociativeVCLWrapCollection<TKey, TValue> = class sealed(TEnexAssociativeCollection<TKey, TValue>)
    private
    type
      { The "Assoc VCL Wrap" enumerator }
      TEnumerator = class(DeHL.Collections.Base.TEnumerator<KVPair<TKey, TValue>>)
      private
        FEnum: TEnexAssociativeVCLWrapCollection<TKey, TValue>;
        FIter: TEnumerator<TPair<TKey, TValue>>;

      public
        { Constructor }
        constructor Create(const AEnum: TEnexAssociativeVCLWrapCollection<TKey, TValue>);

        { Destructor }
        destructor Destroy(); override;

        function GetCurrent(): KVPair<TKey, TValue>; override;
        function MoveNext(): Boolean; override;
      end;

    var
      FEnum: TEnumerable<TPair<TKey, TValue>>;
      FOwns: Boolean;

    public
      { Constructors }
      constructor Create(const AEnumerable: TEnumerable<TPair<TKey, TValue>>;
        const AKeyType: IType<TKey>; const AValueType: IType<TValue>; const OwnsInstance: Boolean); overload;

      { Destructor }
      destructor Destroy(); override;

      { IEnumerable<T> }
      function GetEnumerator(): IEnumerator<KVPair<TKey, TValue>>; override;
    end;

    { The "Old VCL Wrap" collection }
    TEnexOldVCLWrapCollection<E, I: class; T> = class sealed(TEnexCollection<T>)
    public type
      TExtractIterator = reference to function(const ACollection: E): I;
      TIterate = reference to function(const AIterator: I; out ARes: T): Boolean;

    private type
      { The "Old VCL Wrap" enumerator }
      TEnumerator = class(DeHL.Collections.Base.TEnumerator<T>)
      private
        FEnum: TEnexOldVCLWrapCollection<E, I, T>;
        FCurrent: T;
        FIter: I;

      public
        { Constructor }
        constructor Create(const AEnum: TEnexOldVCLWrapCollection<E, I, T>);

        { Destructor }
        destructor Destroy(); override;

        function GetCurrent(): T; override;
        function MoveNext(): Boolean; override;
      end;

    var
      FExtractIteratorProc: TExtractIterator;
      FIterateProc: TIterate;

      FCollection: E;
      FOwns: Boolean;

    public
      { Constructors }
      constructor Create(const ACollection: E; const AExtractIteratorProc: TExtractIterator;
        const AIterateProc: TIterate; const AType: IType<T>; const OwnsInstance: Boolean); overload;

      { Destructor }
      destructor Destroy(); override;

      { IEnumerable<T> }
      function GetEnumerator(): IEnumerator<T>; override;
    end;

    { The "Enex Wrap" collection }
    TVCLEnexWrapCollection<T> = class sealed(TEnumerable<T>)
    private
    type
      { The "Enex Wrap" enumerator }
      TEnumerator = class(TEnumerator<T>)
      private
        FEnum: TVCLEnexWrapCollection<T>;
        FIter: IEnumerator<T>;

      protected
        function DoGetCurrent: T; override;
        function DoMoveNext: Boolean; override;

      public
        { Constructor }
        constructor Create(const AEnum: TVCLEnexWrapCollection<T>);
      end;

    var
      FEnum: TCollection<T>;
      FDeleteEnum: Boolean;

    protected
      { Overriden from TEnumerator<T> (GC) }
      function DoGetEnumerator: TEnumerator<T>; override;

    public
      { Constructors }
      constructor Create(const ACollection: TCollection<T>); overload;
      constructor CreateIntf(const AEnumerable: IEnumerable<T>); overload;

      destructor Destroy(); override;
    end;

    { The "Enex Wrap" collection }
    TVCLAssociativeEnexWrapCollection<TKey, TValue> = class sealed(TEnumerable<TPair<TKey, TValue>>)
    private
    type
      { The "Enex Wrap" enumerator }
      TEnumerator = class(TEnumerator<TPair<TKey, TValue>>)
      private
        FEnum: TVCLAssociativeEnexWrapCollection<TKey, TValue>;
        FIter: IEnumerator<KVPair<TKey, TValue>>;

      protected
        function DoGetCurrent: TPair<TKey, TValue>; override;
        function DoMoveNext: Boolean; override;

      public
        { Constructor }
        constructor Create(const AEnum: TVCLAssociativeEnexWrapCollection<TKey, TValue>);
      end;

    var
      FEnum: TCollection<KVPair<TKey, TValue>>;
      FDeleteEnum: Boolean;

    protected
      { Overriden from TEnumerator<T> (GC) }
      function DoGetEnumerator: TEnumerator<TPair<TKey, TValue>>; override;

    public
      { Constructors }
      constructor Create(const ACollection: TCollection<KVPair<TKey, TValue>>); overload;
      constructor CreateIntf(const AEnumerable: IEnumerable<KVPair<TKey, TValue>>); overload;

      destructor Destroy(); override;
    end;
    {$ENDREGION}
  end;

  { The generic TStringList }
  //TODO: doc me
  TStringList<T> = class(TStringList)
  private
    FType: IType<T>;
    FSuppType: TSuppressedWrapperType<T>;

    { Getter and Setter for new Objects property }
    function GetBoxedValue(Index: Integer): T;
    procedure SetBoxedValue(Index: Integer; const Value: T);

  protected
    { Overriden from parent class }
    //TODO: doc me
    procedure PutObject(Index: Integer; AObject: TObject); override;

  public
    { Override constructors }
    //TODO: doc me
    constructor Create; overload;
    //TODO: doc me
    constructor Create(const AType: IType<T>; const OwnsObjects: Boolean = false); overload;
    //TODO: doc me
    constructor Create(OwnsObjects: Boolean); overload;

    { Override to support boxes properly }
    //TODO: doc me
    function AddObject(const S: string; AObject: TObject): Integer; overload; override;
    //TODO: doc me
    function AddObject(const S: string; const AValue: T): Integer; reintroduce; overload;

    //TODO: doc me
    procedure InsertObject(Index: Integer; const S: string; AObject: TObject); overload; override;
    //TODO: doc me
    procedure InsertObject(Index: Integer; const S: string; const AValue: T); reintroduce; overload;

    //TODO: doc me
    function IndexOfObject(AObject: TObject): Integer; overload; override;
    //TODO: doc me
    function IndexOfObject(const AValue: T): Integer; reintroduce; overload;

    { The Objects property holding the generic types }
    //TODO: doc me
    property Objects[Index: Integer]: T read GetBoxedValue write SetBoxedValue;
  end;

  { The generic TWideStringList }
  //TODO: doc me
  TWideStringList<T> = class(TWideStringList)
  private
    FType: IType<T>;
    FSuppType: TSuppressedWrapperType<T>;

    { Getter and Setter for new Objects property }
    //TODO: doc me
    function GetBoxedValue(Index: Integer): T;
    //TODO: doc me
    procedure SetBoxedValue(Index: Integer; const Value: T);

  protected
    { Overriden from parent class }
    //TODO: doc me
    procedure PutObject(Index: Integer; AObject: TObject); override;

  public
    { Override constructors }
    //TODO: doc me
    constructor Create; overload;
    //TODO: doc me
    constructor Create(const AType: IType<T>; const OwnsObjects: Boolean = false); overload;
    //TODO: doc me
    constructor Create(OwnsObjects: Boolean); overload;

    { Override to support boxes properly }
    //TODO: doc me
    function AddObject(const S: WideString; AObject: TObject): Integer; overload; override;
    //TODO: doc me
    function AddObject(const S: WideString; const AValue: T): Integer; reintroduce; overload;

    //TODO: doc me
    procedure InsertObject(Index: Integer; const S: WideString; AObject: TObject); overload; override;
    //TODO: doc me
    procedure InsertObject(Index: Integer; const S: WideString; const AValue: T); reintroduce; overload;

    //TODO: doc me
    function IndexOfObject(AObject: TObject): Integer; overload; override;
    //TODO: doc me
    function IndexOfObject(const AValue: T): Integer; reintroduce; overload;

    { The Objects property holding the generic types }
    //TODO: doc me
    property Objects[Index: Integer]: T read GetBoxedValue write SetBoxedValue;
  end;


implementation

{ TVCLCollection }

class function TVCLCollection.Wrap(const AList: TList;
  const OwnsInstance: Boolean): IEnexCollection<Pointer>;
begin
  { Check arguments }
  if not Assigned(AList) then
    ExceptionHelper.Throw_ArgumentNilError('AList');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TList, TListEnumerator, Pointer>.Create(
    AList,
    function(const ACollection: TList): TListEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TListEnumerator; out ARes: Pointer): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<Pointer>.Default,
    OwnsInstance);
end;

class function TVCLCollection.Wrap(const AStrings: TStrings;
  const OwnsInstance: Boolean): IEnexCollection<String>;
begin
  { Check arguments }
  if not Assigned(AStrings) then
    ExceptionHelper.Throw_ArgumentNilError('AStrings');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TStrings, TStringsEnumerator, String>.Create(
    AStrings,
    function(const ACollection: TStrings): TStringsEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TStringsEnumerator; out ARes: String): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<String>.Default,
    OwnsInstance);
end;

class function TVCLCollection.Wrap(const AStrings: TWideStrings;
  const OwnsInstance: Boolean): IEnexCollection<WideString>;
begin
  { Check arguments }
  if not Assigned(AStrings) then
    ExceptionHelper.Throw_ArgumentNilError('AStrings');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TWideStrings, TWideStringsEnumerator, WideString>.Create(
    AStrings,
    function(const ACollection: TWideStrings): TWideStringsEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TWideStringsEnumerator; out ARes: WideString): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<WideString>.Default,
    OwnsInstance);
end;

class function TVCLCollection.Wrap<T>(const AEnumerable: TEnumerable<T>; const OwnsInstance: Boolean): IEnexCollection<T>;
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  Result := TEnexVCLWrapCollection<T>.Create(AEnumerable, TType<T>.Default, OwnsInstance);
end;

class function TVCLCollection.Wrap<TKey, TValue>(
  const AEnumerable: TEnumerable<TPair<TKey, TValue>>;
  const OwnsInstance: Boolean): IEnexAssociativeCollection<TKey, TValue>;
begin
  { Check arguments }
  if not Assigned(AEnumerable) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  Result := TEnexAssociativeVCLWrapCollection<TKey, TValue>.Create(AEnumerable, TType<TKey>.Default, TType<TValue>.Default, OwnsInstance);
end;

class function TVCLCollection.Wrap(const AList: TInterfaceList;
  const OwnsInstance: Boolean): IEnexCollection<IInterface>;
begin
  { Check arguments }
  if not Assigned(AList) then
    ExceptionHelper.Throw_ArgumentNilError('AList');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TInterfaceList, TInterfaceListEnumerator, IInterface>.Create(
    AList,
    function(const ACollection: TInterfaceList): TInterfaceListEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TInterfaceListEnumerator; out ARes: IInterface): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<IInterface>.Default,
    OwnsInstance);
end;

class function TVCLCollection.Wrap(const ACollection: TCollection;
  const OwnsInstance: Boolean): IEnexCollection<TCollectionItem>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('AList');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TCollection, TCollectionEnumerator, TCollectionItem>.Create(
    ACollection,
    function(const ACollection: TCollection): TCollectionEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TCollectionEnumerator; out ARes: TCollectionItem): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<TCollectionItem>.Default,
    OwnsInstance);
end;

class function TVCLCollection.Wrap(const AComponent: TComponent;
  const OwnsInstance: Boolean): IEnexCollection<TComponent>;
begin
  { Check arguments }
  if not Assigned(AComponent) then
    ExceptionHelper.Throw_ArgumentNilError('AList');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TComponent, TComponentEnumerator, TComponent>.Create(
    AComponent,
    function(const ACollection: TComponent): TComponentEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TComponentEnumerator; out ARes: TComponent): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<TComponent>.Default,
    OwnsInstance);
end;

class function TVCLCollection.Wrap(const AList: TObjectList;
  const OwnsInstance: Boolean): IEnexCollection<TObject>;
begin
  { Check arguments }
  if not Assigned(AList) then
    ExceptionHelper.Throw_ArgumentNilError('AList');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TList, TListEnumerator, TObject>.Create(
    AList,
    function(const ACollection: TList): TListEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TListEnumerator; out ARes: TObject): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<TObject>.Default,
    OwnsInstance);
end;

class function TVCLCollection.Wrap(const AList: TComponentList;
  const OwnsInstance: Boolean): IEnexCollection<TComponent>;
begin
  { Check arguments }
  if not Assigned(AList) then
    ExceptionHelper.Throw_ArgumentNilError('AList');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TList, TListEnumerator, TComponent>.Create(
    AList,
    function(const ACollection: TList): TListEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TListEnumerator; out ARes: TComponent): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<TComponent>.Default,
    OwnsInstance);
end;

class function TVCLCollection.From<T>(const ACollection: TCollection<T>): TEnumerable<T>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  Result := TVCLEnexWrapCollection<T>.Create(ACollection);
end;

class function TVCLCollection.From<TKey, TValue>(
  const ACollection: TCollection<KVPair<TKey, TValue>>): TEnumerable<TPair<TKey, TValue>>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('ACollection');

  Result := TVCLAssociativeEnexWrapCollection<TKey, TValue>.Create(ACollection);
end;

class function TVCLCollection.From<TKey, TValue>(
  const ACollection: IEnexAssociativeCollection<TKey, TValue>): TEnumerable<TPair<TKey, TValue>>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  Result := TVCLAssociativeEnexWrapCollection<TKey, TValue>.CreateIntf(ACollection);
end;

class function TVCLCollection.From<T>(const ACollection: IEnexCollection<T>): TEnumerable<T>;
begin
  { Check arguments }
  if not Assigned(ACollection) then
    ExceptionHelper.Throw_ArgumentNilError('AEnumerable');

  Result := TVCLEnexWrapCollection<T>.CreateIntf(ACollection);
end;

class function TVCLCollection.Wrap(const AList: TClassList;
  const OwnsInstance: Boolean): IEnexCollection<TClass>;
begin
  { Check arguments }
  if not Assigned(AList) then
    ExceptionHelper.Throw_ArgumentNilError('AList');

  { Generate a cool inline wrapper }
  Result := TEnexOldVCLWrapCollection<TList, TListEnumerator, TClass>.Create(
    AList,
    function(const ACollection: TList): TListEnumerator begin Exit(ACollection.GetEnumerator()); end,
    function(const AIterator: TListEnumerator; out ARes: TClass): Boolean begin
      Result := AIterator.MoveNext();

      if Result then
        ARes := AIterator.Current;
    end,
    TType<TClass>.Default,
    OwnsInstance);
end;

{ TEnexVCLWrapCollection<T> }

constructor TVCLCollection.TEnexVCLWrapCollection<T>.Create(const AEnumerable: TEnumerable<T>;
  const AType: IType<T>; const OwnsInstance: Boolean);
begin
  FEnum := AEnumerable;
  FOwns := OwnsInstance;

  InstallType(AType);
end;

destructor TVCLCollection.TEnexVCLWrapCollection<T>.Destroy;
begin
  { Destroy the VCL enumerable if required }
  if FOwns then
    FEnum.Free;

  inherited;
end;

function TVCLCollection.TEnexVCLWrapCollection<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

{ TEnexVCLWrapCollection<T>.TEnumerator }

constructor TVCLCollection.TEnexVCLWrapCollection<T>.TEnumerator.Create(const AEnum: TEnexVCLWrapCollection<T>);
begin
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
end;

destructor TVCLCollection.TEnexVCLWrapCollection<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);

  FIter.Free;
  inherited;
end;

function TVCLCollection.TEnexVCLWrapCollection<T>.TEnumerator.GetCurrent: T;
begin
  Result := FIter.Current;
end;

function TVCLCollection.TEnexVCLWrapCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  Result := FIter.MoveNext;
end;

{ TEnexAssociativeVCLWrapCollection<TKey, TValue> }

constructor TVCLCollection.TEnexAssociativeVCLWrapCollection<TKey, TValue>.Create(
  const AEnumerable: TEnumerable<TPair<TKey, TValue>>;
  const AKeyType: IType<TKey>; const AValueType: IType<TValue>;
  const OwnsInstance: Boolean);
begin
  FEnum := AEnumerable;
  FOwns := OwnsInstance;

  { Install types }
  InstallTypes(AKeyType, AValueType);
end;

destructor TVCLCollection.TEnexAssociativeVCLWrapCollection<TKey, TValue>.Destroy;
begin
  if FOwns then
    FEnum.Free;

  inherited;
end;

function TVCLCollection.TEnexAssociativeVCLWrapCollection<TKey, TValue>.GetEnumerator: IEnumerator<KVPair<TKey, TValue>>;
begin
  Result := TEnumerator.Create(Self);
end;

{ TEnexAssociativeVCLWrapCollection<TKey, TValue>.TEnumerator }

constructor TVCLCollection.TEnexAssociativeVCLWrapCollection<TKey, TValue>.TEnumerator.Create(
  const AEnum: TEnexAssociativeVCLWrapCollection<TKey, TValue>);
begin
  FEnum := AEnum;
  KeepObjectAlive(FEnum);

  FIter := AEnum.FEnum.GetEnumerator();
end;

destructor TVCLCollection.TEnexAssociativeVCLWrapCollection<TKey, TValue>.TEnumerator.Destroy;
begin
  ReleaseObject(FEnum);

  FIter.Free;
  inherited;
end;

function TVCLCollection.TEnexAssociativeVCLWrapCollection<TKey, TValue>.TEnumerator.GetCurrent: KVPair<TKey, TValue>;
begin
  Result := KVPair.Create<TKey, TValue>(FIter.Current.Key, FIter.Current.Value);
end;

function TVCLCollection.TEnexAssociativeVCLWrapCollection<TKey, TValue>.TEnumerator.MoveNext: Boolean;
begin
  Result := FIter.MoveNext;
end;

{ TEnexOldVCLWrapCollection<E, I, T> }

constructor TVCLCollection.TEnexOldVCLWrapCollection<E, I, T>.Create(const ACollection: E;
  const AExtractIteratorProc: TExtractIterator; const AIterateProc: TIterate;
  const AType: IType<T>; const OwnsInstance: Boolean);
begin
  FCollection := ACollection;
  FExtractIteratorProc := AExtractIteratorProc;
  FIterateProc := AIterateProc;
  FOwns := OwnsInstance;

  InstallType(AType);
end;

destructor TVCLCollection.TEnexOldVCLWrapCollection<E, I, T>.Destroy;
begin
  if FOwns then
    FCollection.Free;

  inherited;
end;

function TVCLCollection.TEnexOldVCLWrapCollection<E, I, T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

{ TEnexOldVCLWrapCollection<E, I, T>.TEnumerator }

constructor TVCLCollection.TEnexOldVCLWrapCollection<E, I, T>.TEnumerator.Create(const AEnum: TEnexOldVCLWrapCollection<E, I, T>);
begin
  FEnum := AEnum;
  KeepObjectAlive(AEnum);
  FCurrent := default(T);

  { Obtain iterator }
  FIter := AEnum.FExtractIteratorProc(FEnum.FCollection);
end;

destructor TVCLCollection.TEnexOldVCLWrapCollection<E, I, T>.TEnumerator.Destroy;
begin
  FIter.Free;
  inherited;
end;

function TVCLCollection.TEnexOldVCLWrapCollection<E, I, T>.TEnumerator.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TVCLCollection.TEnexOldVCLWrapCollection<E, I, T>.TEnumerator.MoveNext: Boolean;
begin
  { Move next }
  Result := FEnum.FIterateProc(FIter, FCurrent);
end;

{ TVCLEnexWrapCollection<T> }

constructor TVCLCollection.TVCLEnexWrapCollection<T>.Create(const ACollection: TCollection<T>);
begin
  FEnum := ACollection;
  FDeleteEnum := false;
end;

constructor TVCLCollection.TVCLEnexWrapCollection<T>.CreateIntf(const AEnumerable: IEnumerable<T>);
begin
  { Call the upper constructor }
  try
    Create(TEnexWrapCollection<T>.Create(AEnumerable, TType<T>.Default));
  finally
    { Mark enumerable to be deleted }
    FDeleteEnum := true;
  end;
end;

destructor TVCLCollection.TVCLEnexWrapCollection<T>.Destroy;
begin
  if FDeleteEnum then
    FEnum.Free;

  inherited;
end;

function TVCLCollection.TVCLEnexWrapCollection<T>.DoGetEnumerator: TEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

{ TVCLEnexWrapCollection<T>.TEnumerator }

constructor TVCLCollection.TVCLEnexWrapCollection<T>.TEnumerator.Create(const AEnum: TVCLEnexWrapCollection<T>);
begin
  FEnum := AEnum;
  FIter := AEnum.FEnum.GetEnumerator();
end;

function TVCLCollection.TVCLEnexWrapCollection<T>.TEnumerator.DoGetCurrent: T;
begin
  Result := FIter.Current;
end;

function TVCLCollection.TVCLEnexWrapCollection<T>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := FIter.MoveNext();
end;

{ TVCLAssociativeEnexWrapCollection<TKey, TValue> }

constructor TVCLCollection.TVCLAssociativeEnexWrapCollection<TKey, TValue>.Create(
  const ACollection: TCollection<KVPair<TKey, TValue>>);
begin
  FEnum := ACollection;
  FDeleteEnum := false;
end;

constructor TVCLCollection.TVCLAssociativeEnexWrapCollection<TKey, TValue>.CreateIntf(
  const AEnumerable: IEnumerable<KVPair<TKey, TValue>>);
begin
  { Call the upper constructor }
  try
    Create(TEnexWrapCollection<KVPair<TKey, TValue>>.Create(AEnumerable, TType<KVPair<TKey, TValue>>.Default));
  finally
    { Mark enumerable to be deleted }
    FDeleteEnum := true;
  end;
end;

destructor TVCLCollection.TVCLAssociativeEnexWrapCollection<TKey, TValue>.Destroy;
begin
  if FDeleteEnum then
    FEnum.Free;

  inherited;
end;

function TVCLCollection.TVCLAssociativeEnexWrapCollection<TKey, TValue>.DoGetEnumerator: TEnumerator<TPair<TKey, TValue>>;
begin
  Result := TEnumerator.Create(Self);
end;

{ TVCLAssociativeEnexWrapCollection<TKey, TValue>.TEnumerator }

constructor TVCLCollection.TVCLAssociativeEnexWrapCollection<TKey, TValue>.TEnumerator.Create(
  const AEnum: TVCLAssociativeEnexWrapCollection<TKey, TValue>);
begin
  FEnum := AEnum;
  FIter := AEnum.FEnum.GetEnumerator();
end;

function TVCLCollection.TVCLAssociativeEnexWrapCollection<TKey, TValue>.TEnumerator.DoGetCurrent: TPair<TKey, TValue>;
begin
  Result.Key := FIter.Current.Key;
  Result.Value := FIter.Current.Value;
end;

function TVCLCollection.TVCLAssociativeEnexWrapCollection<TKey, TValue>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := FIter.MoveNext();
end;

{ TStringList<T> }

constructor TStringList<T>.Create;
begin
  { Call upper constructor }
  Create(TType<T>.Default, false);
end;

constructor TStringList<T>.Create(OwnsObjects: Boolean);
begin
  { Call upper constructor }
  Create(TType<T>.Default, OwnsObjects);
end;

constructor TStringList<T>.Create(const AType: IType<T>; const OwnsObjects: Boolean);
begin
  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Create an intermediary SUPP type }
  FSuppType := TSuppressedWrapperType<T>.Create(AType);
  FSuppType.AllowCleanup := OwnsObjects;
  FType := FSuppType;

  { Call inherited constructor -- always owns objects since those are MINE! }
  inherited Create(true);
end;

function TStringList<T>.AddObject(const S: string; const AValue: T): Integer;
begin
  { Call the inherited method }
  Result := inherited AddObject(S, TBox<T>.Create(FType, AValue));
end;

function TStringList<T>.AddObject(const S: string; AObject: TObject): Integer;
begin
  { Verify arguments }

{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  { Call ingerited method }
  Result := inherited AddObject(S, AObject);
end;

function TStringList<T>.GetBoxedValue(Index: Integer): T;
var
  Box: TBox<T>;
begin
  { Get the actual object/box }
  Box := TBox<T>(GetObject(Index));

  { Try to get the stuff out -- using TryPeek since the caller may have unboxed the value earlier }
  if (Box = nil) or (not Box.TryPeek(Result)) then
    Result := default(T);
end;

function TStringList<T>.IndexOfObject(AObject: TObject): Integer;
begin
  { Verify arguments }
{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  Result := inherited IndexOfObject(AObject);
end;

function TStringList<T>.IndexOfObject(const AValue: T): Integer;
begin
  { Search for the value's index }
  for Result := 0 to GetCount - 1 do
    if FType.AreEqual(GetBoxedValue(Result), AValue) then Exit;

  Result := -1;
end;

procedure TStringList<T>.InsertObject(Index: Integer; const S: string; AObject: TObject);
begin
  { Verify arguments }
{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  { Call ingerited method }
  inherited InsertObject(Index, S, AObject);
end;

procedure TStringList<T>.InsertObject(Index: Integer; const S: string; const AValue: T);
begin
  { Call the inherited method }
  inherited InsertObject(Index, S, TBox<T>.Create(FType, AValue));
end;

procedure TStringList<T>.PutObject(Index: Integer; AObject: TObject);
begin
  { Verify arguments }
{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  inherited PutObject(Index, AObject);
end;

procedure TStringList<T>.SetBoxedValue(Index: Integer; const Value: T);
var
  Box: TBox<T>;
begin
  { Get the object/box occupying the spot }
  Box := TBox<T>(GetObject(Index));

  { Free the previous box }
  if Box <> nil then
    Box.Free;

  { Call the inherited method }
  PutObject(Index, TBox<T>.Create(FType, Value));
end;

{ TWideStringList<T> }

constructor TWideStringList<T>.Create;
begin
  { Call upper constructor }
  Create(TType<T>.Default, false);
end;

constructor TWideStringList<T>.Create(OwnsObjects: Boolean);
begin
  { Call upper constructor }
  Create(TType<T>.Default, OwnsObjects);
end;

constructor TWideStringList<T>.Create(const AType: IType<T>; const OwnsObjects: Boolean);
begin
  if AType = nil then
    ExceptionHelper.Throw_ArgumentNilError('AType');

  { Create an intermediary SUPP type }
  FSuppType := TSuppressedWrapperType<T>.Create(AType);
  FSuppType.AllowCleanup := OwnsObjects;
  FType := FSuppType;

  { Call inherited constructor -- always owns objects since those are MINE! }
  inherited Create(true);
end;

function TWideStringList<T>.AddObject(const S: WideString; const AValue: T): Integer;
begin
  { Call the inherited method }
  Result := inherited AddObject(S, TBox<T>.Create(FType, AValue));
end;

function TWideStringList<T>.AddObject(const S: WideString; AObject: TObject): Integer;
begin
  { Verify arguments }
{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  { Call ingerited method }
  Result := inherited AddObject(S, AObject);
end;

function TWideStringList<T>.GetBoxedValue(Index: Integer): T;
var
  Box: TBox<T>;
begin
  { Get the actual object/box }
  Box := TBox<T>(GetObject(Index));

  { Try to get the stuff out -- using TryPeek since the caller may have unboxed the value earlier }
  if (Box = nil) or (not Box.TryPeek(Result)) then
    Result := default(T);
end;

function TWideStringList<T>.IndexOfObject(AObject: TObject): Integer;
begin
  { Verify arguments }
{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  Result := inherited IndexOfObject(AObject);
end;

function TWideStringList<T>.IndexOfObject(const AValue: T): Integer;
begin
  { Search for the value's index }
  for Result := 0 to GetCount - 1 do
    if FType.AreEqual(GetBoxedValue(Result), AValue) then Exit;

  Result := -1;
end;

procedure TWideStringList<T>.InsertObject(Index: Integer; const S: WideString; AObject: TObject);
begin
  { Verify arguments }
{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  { Call ingerited method }
  inherited InsertObject(Index, S, AObject);
end;

procedure TWideStringList<T>.InsertObject(Index: Integer; const S: WideString; const AValue: T);
begin
  { Call the inherited method }
  inherited InsertObject(Index, S, TBox<T>.Create(FType, AValue));
end;

procedure TWideStringList<T>.PutObject(Index: Integer; AObject: TObject);
begin
  { Verify arguments }
{$IFDEF BUG_IS_OP_CLASS}
  if (AObject <> nil) and (not AObject.InheritsFrom(TBox<T>)) then
{$ELSE}
  if (AObject <> nil) and not (AObject is TBox<T>) then
{$ENDIF}
    ExceptionHelper.Throw_ArgumentNotSameTypeError('AObject');

  inherited PutObject(Index, AObject);
end;

procedure TWideStringList<T>.SetBoxedValue(Index: Integer; const Value: T);
var
  Box: TBox<T>;
begin
  { Get the object/box occupying the spot }
  Box := TBox<T>(GetObject(Index));

  { Free the previous box }
  if Box <> nil then
    Box.Free;

  { Call the inherited method }
  PutObject(Index, TBox<T>.Create(FType, Value));
end;

end.
