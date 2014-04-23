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
unit DeHL.Cloning;
interface
uses TypInfo,
     Rtti,
     DeHL.Base;

type
  ///  <summary>Implement in classes that provide cloning support.</summary>
  ///  <remakrs>Objects that implement this interface must be able to copy their states
  ///  perfectly to new instances.</remarks>
  ICloneable = interface
    ['{0BAD52F9-DEBF-454F-B046-72CD497F71FC}']

    ///  <summary>Creates a perfect copy of this object.</summary>
    ///  <returns>A new perfect copy of this object.</returns>
    function Clone(): TObject;
  end;

  ///  <summary>Defines possible cloning options for reference-based types</summary>
  ///  <remarks>This type is used by the automatic object replication process to
  ///  decide how to copy reference-based types (ex. dynamic arrays, objects).</remarks>
  TCloneKind = (
    ///  <summary>The field will not be copied at all.</summary>
    ckSkip,
    ///  <summary>Copy the reference (pointer) and not the contents. Applies to objects, ^records and dynamic arrays.</summary>
    ///  <remarks>This mode is the default for objects and ^records.</remarks>
    ckReference,
    ///  <summary>Follow the classes dynamic arrays and ^records deeply.</summary>
    ///  <remarks>If this mode is used, a new object, ^record or array is created in the copy,
    ///  and the contents of that type if copied over.</remarks>
    ckDeep,
    ///  <summary>Follow the classes dynamic arrays and ^records deeply.</summary>
    ///  <remarks>This mode is exactly the same as <c>ckDeep</c> with the exception that the elements of
    ///  the array (in case an array is copied) are copied as <c>ckReference</c> and not <c>ckDeep</c>.</remarks>
    ckFlat
  );

  ///  <summary>Annotate to describe how a filed replication is perfored.</summary>
  ///  <remarks>By default the automated replication process copies all objects, records and arrays deeply.
  ///  This mode can be overridden by annotating this attribute on a field. For example, annotating <c>[CloneKind(ckSkip)]</c>
  ///  on a field will make the replication engine skip it entirely.</remarks>
  CloneKind = class sealed(TCustomAttribute)
  private
    FCloneKind: TCloneKind;

  public
    ///  <summary>Creates a new instance of <see cref="DeHL.Cloning|CloneKind">DeHL.Cloning.CloneKind</see> class</summary>
    ///  <param name="AKind">A <see cref="DeHL.Cloning|TCloneKind">DeHL.Cloning.TCloneKind</see> value specifying how
    ///  the replicator engine treats the annotated field.</param>
    ///  <remarks>Do not call this method in code. It is only practical when use as attribute.</remarks>
    constructor Create(const AKind: TCloneKind);
  end;

  ///  <summary>Procedural type used by <see cref="DeHL.Cloning|TReplicator&lt;T&gt;">DeHL.Cloning.TReplicator&lt;T&gt;</see> to notify
  ///  field cloning.</summary>
  ///  <param name="Sender">The replicator engine that initiated the event.</param>
  ///  <param name="AType">The RTTI type object of the cloned field.</param>
  ///  <param name="AField">The field's RTTI object.</param>
  ///  <param name="ASource">The address of source field.</param>
  ///  <param name="ADest">The address of destination field.</param>
  ///  <param name="APocessed">The callee must set this parameter to <c>True</c> to signal the replicator engine that the callee cloned it.</param>
  TOnCloneFieldEvent = procedure(Sender: TObject; const AType: TRttiType; const AField: TRttiField;
    const ASource, ADest: Pointer; var APocessed: Boolean) of object;

  ///  <summary>Provides support for cloning any value of any type to another value of that type.</summary>
  ///  <remarks>This class can be used to clone any type, but it is most useful to clone complex types such as
  ///  classes and record. <see cref="DeHL.Cloning|CloneKind">DeHL.Cloning.CloneKind</see> attribute is used
  ///  to change the behavior of the field cloning process.</remarks>
  TReplicator<T> = class sealed(TRefCountedObject)
  private type
    { Define local types used internally }
    PObject = ^TObject;
    PInterface = ^IInterface;
    PMethod = ^TMethod;
    PClass = ^TClass;
    TDummyArray = array of Byte;
    PDummyArray = ^TDummyArray;

  private
    FOnCloneField: TOnCloneFieldEvent;
    FContext: TRttiContext;
    FObjectMap, FRecordMap,
      FDynArrayMap: TCorePointerDictionary;

    FRootType: TRttiType;

    { Same as TClassType<T>.InternalGetInterface }
    procedure InternalGetCloneable(const AObject: TObject; var AOut: Pointer);

    { Dictionary Helpers }
    procedure RegisterClassMapping(const ASource, ADest: TObject); inline;
    procedure RegisterRecordMapping(const ASource, ADest: Pointer); inline;
    procedure RegisterDynArrayMapping(const ASource, ADest: Pointer); inline;

    function TryGetClassMapping(const ASource: TObject; out ADest: TObject): Boolean; inline;
    function TryGetRecordMapping(const ASource: Pointer; out ADest: Pointer): Boolean; inline;
    function TryGetDynArrayMapping(const ASource: Pointer; out ADest: TDummyArray): Boolean; inline;

    { Replication }
    procedure DoReplicate(const AInput: T; out AOutput: T; const AUseIntf: Boolean); overload;
{$HINTS OFF}
    procedure DoReplicate(const AInPtr, AOutPtr: Pointer; const AType: TRttiType;
      const AKind: TCloneKind; const AUseIntf: Boolean);  overload;
{$HINTS ON}
    procedure DoReplicateFields(const ABaseInPtr, ABaseOutPtr: Pointer; const AType: TRttiType);
    procedure DoReplicateArray(const AFirstElemInPtr, AFirstElemOutPtr: Pointer; const AElements: NativeUInt;
       const AElemType: TRttiType; const AGoDeep: Boolean);
  public
    { Constructor/Destructor }
    constructor Create;
    destructor Destroy; override;

    ///  <summary>Creates a new instance of <see cref="DeHL.Cloning|TReplicator&gt;T&lt;>">DeHL.Cloning.TReplicator&gt;T&lt;</see> class.</summary>
    ///  <param name="AInput">The input value.</param>
    ///  <param name="AOutput">The output value.</param>
    ///  <remarks>Upon exit from this method, <paramref name="AOutput"/> should contain the copy of <paramref name="AInput"/>.</remarks>
    procedure Replicate(const AInput: T; out AOutput: T);

    ///  <summary>Event triggered on before each field copy operation.</summary>
    ///  <param name="Sender">The replicator engine that initiated the event.</param>
    ///  <param name="AType">The RTTI type object of the cloned field.</param>
    ///  <param name="AField">The field's RTTI object.</param>
    ///  <param name="ASource">The address of source field.</param>
    ///  <param name="ADest">The address of destination field.</param>
    ///  <param name="APocessed">The callee must set this parameter to <c>True</c> to signal the replicator engine that the callee cloned it.</param>
    property OnCloneField: TOnCloneFieldEvent read FOnCloneField write FOnCloneField;
  end;

  ///  <summary>Base for all objects that need automated cloning support.</summary>
  ///  <remarks>Descending classes do no need to implement anything at all except annotating fields with
  ///  <see cref="DeHL.Cloning|CloneKind">DeHL.Cloning.CloneKind</see> attribute where needed.</remarks>
  TCloneableObject = class(TRefCountedObject, ICloneable)
  private
    [CloneKind(ckSkip)]
    FReplicator: TReplicator<TCloneableObject>;

  public
    ///  <summary>Finalizes the internals of the <see cref="DeHL.Cloning|TCloneableObject">DeHL.Cloning.TCloneableObject</see> objects.</summary>
    ///  <remarks>Do not call this method directly. It is a part of object destruction process.</remarks>
    procedure BeforeDestruction; override;

    ///  <summary>Creates a perfect copy of this object using automated replication.</summary>
    ///  <returns>A new perfect copy of this object.</returns>
    function Clone(): TObject; virtual;
  end;

implementation
uses Windows; // used for Interlocked (fix me!)

{ TReplicator<T> }

constructor TReplicator<T>.Create;
begin
  inherited;

  FContext := TRttiContext.Create;
  FRootType := FContext.GetType(TypeInfo(T));
end;

destructor TReplicator<T>.Destroy;
begin
  FContext.Free;

  { Free only if created obviously }
  FObjectMap.Free;
  FDynArrayMap.Free;
  FRecordMap.Free;

  inherited;
end;

procedure TReplicator<T>.DoReplicate(const AInPtr, AOutPtr: Pointer; const AType: TRttiType;
  const AKind: TCloneKind; const AUseIntf: Boolean);
var
  LLen: LongInt;
  LRefType: TRttiType;
  LTypeData: PTypeData;
  LCloneable: ICloneable;
begin
  case AType.TypeKind of
    { Simple types that can be copied by memory move directly }
    tkUnknown, tkInteger, tkEnumeration, tkFloat, tkSet:
    begin
      { Check most common cases }
      case AType.TypeSize of
        SizeOf(Byte):
          PByte(AOutPtr)^ := PByte(AInPtr)^;

        SizeOf(Word):
          PWord(AOutPtr)^ := PWord(AInPtr)^;

        SizeOf(LongWord):
          PLongWord(AOutPtr)^ := PLongWord(AInPtr)^;

        SizeOf(UInt64):
          PUInt64(AOutPtr)^ := PUInt64(AInPtr)^;
        else
          Move(AInPtr^, AOutPtr^, AType.TypeSize); // Other cases
      end;
    end;

    { Method }
    tkMethod:
      PMethod(AOutPtr)^ := PMethod(AInPtr)^;

    { Procedure }
    tkProcedure:
      PPointer(AOutPtr)^ := PPointer(AInPtr)^;

    { Class reference }
    tkClassRef:
      PClass(AOutPtr)^ := PClass(AInPtr)^;

    { AnsiChar }
    tkChar:
      PAnsiChar(AOutPtr)^ := PAnsiChar(AInPtr)^;

    { WideChar }
    tkWChar:
      PWideChar(AOutPtr)^ := PWideChar(AInPtr)^;

    { Int64 and UInt64 }
    tkInt64:
      PInt64(AOutPtr)^ := PInt64(AInPtr)^;

    { Short string }
    tkString:
      PShortString(AOutPtr)^ := PShortString(AInPtr)^;

    { Ansi string copy + ref count }
    tkLString:
      PAnsiString(AOutPtr)^ := PAnsiString(AInPtr)^;

    { Unicode string copy + ref count }
    tkUString:
      PUnicodeString(AOutPtr)^ := PUnicodeString(AInPtr)^;

    { Wide string copy }
    tkWString:
      PWideString(AOutPtr)^ := PWideString(AInPtr)^;

    { Variant copy }
    tkVariant:
      PVariant(AOutPtr)^ := PVariant(AInPtr)^;

    { Interface copy }
    tkInterface:
      PInterface(AOutPtr)^ := PInterface(AInPtr)^;

    { Class, Copy fileds also }
    tkClass:
    begin
      if not TryGetClassMapping(PObject(AInPtr)^, PObject(AOutPtr)^) then
      begin
        { Check if only a copy-ref is required }
        if (AKind = ckReference) or (PPointer(AInPtr)^ = nil) then
          PObject(AOutPtr)^ := PObject(AInPtr)^
        else
        begin
          { Try to obtain an ICloneable (only if specified so) }
          if AUseIntf then
            InternalGetCloneable(PObject(AInPtr)^, Pointer(LCloneable));

          if LCloneable <> nil then
          begin
            PObject(AOutPtr)^ := LCloneable.Clone();
            Pointer(LCloneable) := nil; // Disable interface
          end else
          begin
            { Create a new instance of the same object. We will copy everything
              over so don't call a constructor. }
            PPointer(AOutPtr)^ := PObject(AInPtr)^.ClassType.NewInstance;

            { Update maps }
            RegisterClassMapping(PPointer(AInPtr)^, PPointer(AOutPtr)^);

            { Replicate each field }
            DoReplicateFields(PPointer(AInPtr)^, PPointer(AOutPtr)^, FContext.GetType(PObject(AInPtr)^.ClassType));
          end;
        end;
      end;
    end;

    { Record, copy fields also }
    tkRecord:
      DoReplicateFields(AInPtr, AOutPtr, AType);

    { Static Array }
    tkArray:
    begin
      { Get element type }
      LRefType := TRttiArrayType(AType).ElementType;

      { Replicate if the element type is known. Otherwise do a move. }
      if LRefType <> nil then
        DoReplicateArray(AInPtr, AOutPtr, TRttiArrayType(AType).TotalElementCount, TRttiArrayType(AType).ElementType, (AKind <> ckFlat))
      else
        Move(AInPtr^, AOutPtr^, AType.TypeSize);
    end;

    tkDynArray:
    begin
      { Check if we have a mapping }
      if not TryGetDynArrayMapping(PPointer(AInPtr)^, PDummyArray(AOutPtr)^) then
      begin
        { Check if a copy-ref is required }
        if (AKind = ckReference) or (PPointer(AInPtr)^ = nil) then
          PDummyArray(AOutPtr)^ := PDummyArray(AInPtr)^
        else begin
          { Obtain the type of elements }
          LTypeData := GetTypeData(AType.Handle);

          if (LTypeData <> nil) and (LTypeData^.elType <> nil) and (LTypeData^.elType^ <> nil) then
            LRefType := FContext.GetType(LTypeData^.elType^)
          else
            LRefType := TRttiDynamicArrayType(AType).ElementType;

          { Create a new dynamic array }
          LLen := DynArraySize(PPointer(AInPtr)^);
          DynArraySetLength(PPointer(AOutPtr)^, AType.Handle, 1, @LLen);

          { Update maps }
          RegisterDynArrayMapping(PPointer(AInPtr)^, PPointer(AOutPtr)^);

          { Copy the elements over if the type is known, otherwise Move memory }
          if LRefType <> nil then
            DoReplicateArray(PPointer(AInPtr)^, PPointer(AOutPtr)^, LLen, LRefType, (AKind <> ckFlat))
          else
            Move(PPointer(AInPtr)^, PPointer(AOutPtr)^, LLen * TRttiDynamicArrayType(AType).ElementSize);
        end;
      end;
    end;

    { Pointer. First check to see if it's ref to record. }
    tkPointer:
    begin
      LRefType := TRttiPointerType(AType).ReferredType;

      if (LRefType <> nil) and (LRefType.TypeKind = tkRecord) then
      begin
        if not TryGetRecordMapping(PPointer(AInPtr)^, PPointer(AOutPtr)^) then
        begin
          { Check if only a copy-by-ref is required }
          if (AKind = ckReference) or (PPointer(AInPtr)^ = nil) then
            PPointer(AOutPtr)^ := PPointer(AInPtr)^
          else begin
            { Allocate memory and initialize it }
            GetMem(PPointer(AOutPtr)^, LRefType.TypeSize);
            InitializeArray(PPointer(AOutPtr)^, LRefType.Handle, 1);

            { Update maps }
            RegisterRecordMapping(PPointer(AInPtr)^, PPointer(AOutPtr)^);

            { Replicate each field }
            DoReplicateFields(PPointer(AInPtr)^, PPointer(AOutPtr)^, LRefType);
          end;
        end;
      end else
       PPointer(AOutPtr)^ := PPointer(AInPtr)^; // Copy pointer value...
    end;
  end;
end;

procedure TReplicator<T>.DoReplicate(const AInput: T; out AOutput: T; const AUseIntf: Boolean);
begin
  { Clear x <=> y maps }
  if FObjectMap <> nil then
    FObjectMap.Clear;

  if FRecordMap <> nil then
    FRecordMap.Clear;

  if FDynArrayMap <> nil then
    FDynArrayMap.Clear;

  { Call internal helper. Start with default. }
  DoReplicate(@AInput, @AOutput, FRootType, ckFlat, AUseIntf);
end;

procedure TReplicator<T>.DoReplicateArray(const AFirstElemInPtr,
  AFirstElemOutPtr: Pointer; const AElements: NativeUInt;
  const AElemType: TRttiType; const AGoDeep: Boolean);
var
  LCurrIn, LCurrOut: PByte;
  I: NativeUInt;
begin
  { Continue only if we have count > 0. Otherwise it's a NOP }
  if AElements > 0 then
  begin
    { For simple types, just use Move(). No need for complex operations }
    if AElemType.TypeKind in [tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
      tkSet, tkMethod, tkWChar, tkInt64, tkClassRef, tkProcedure] then
      Move(AFirstElemInPtr^, AFirstElemOutPtr^, AElements * NativeUInt(AElemType.TypeSize))
    else begin
      { Put cursors to the start pointers }
      LCurrIn := AFirstElemInPtr;
      LCurrOut := AFirstElemOutPtr;

      { Now, actually copy }
      for I := 0 to AElements - 1 do
      begin
        { Replicate element -- Either deep or shallow. }
        if AGoDeep then
          DoReplicate(LCurrIn, LCurrOut, AElemType, ckDeep, true)
        else
          DoReplicate(LCurrIn, LCurrOut, AElemType, ckReference, true);

        { Increase pointers }
        Inc(LCurrIn, AElemType.TypeSize);
        Inc(LCurrOut, AElemType.TypeSize);
      end;
    end;
  end;
end;

procedure TReplicator<T>.DoReplicateFields(const ABaseInPtr, ABaseOutPtr: Pointer; const AType: TRttiType);
var
  LAttr: TCustomAttribute;
  LField: TRttiField;
  LInFieldPtr, LOutFieldPtr: Pointer;
  LKind: TCloneKind;
  LContinue: Boolean;
begin
  { Iterate over each field }
  for LField in AType.GetFields do
  begin
    { Set default. Arrays - flat. Classes and ^Records - by reference. }
    if (LField.FieldType <> nil) and (LField.FieldType.TypeKind in [tkArray, tkDynArray]) then
      LKind := ckFlat
    else
      LKind := ckReference;

    { Check for attributes }
    for LAttr in LField.GetAttributes() do
      if LAttr is CloneKind then
        LKind := CloneKind(LAttr).FCloneKind;

    { Skip this field? }
    if LKind = ckSkip then
      Continue;

    { Calculate offsets }
    LInFieldPtr := Ptr(NativeInt(ABaseInPtr) + LField.Offset);
    LOutFieldPtr := Ptr(NativeInt(ABaseOutPtr) + LField.Offset);

    { Call the user handler for this one }
    if Assigned(FOnCloneField) then
    begin
      LContinue := true;
      FOnCloneField(Self, AType, LField, LInFieldPtr, LOutFieldPtr, LContinue);

      { Skip default processing if said so }
      if not LContinue then
        Continue;
    end;

    { Replicate field. If type unknown, skip it (don't fail). }
    if LField.FieldType <> nil then
      DoReplicate(LInFieldPtr, LOutFieldPtr, LField.FieldType, LKind, true);
  end;
end;

procedure TReplicator<T>.InternalGetCloneable(const AObject: TObject; var AOut: Pointer);
var
  LIntfEntry: PInterfaceEntry;

begin
  AOut := nil;

  { Nothing on nil object }
  if AObject = nil then
    Exit;

  { Obtain the interface entry }
  LIntfEntry := AObject.GetInterfaceEntry(ICloneable);

  { If there is such an interface and it has an Object offset, get it }
  if (LIntfEntry <> nil) and (LIntfEntry^.IOffset <> 0) then
    AOut := Pointer(Integer(AObject) + LIntfEntry^.IOffset);

  { Note: No AddRef is performed since we have no idea if the object
    has ref cont > 0 already! We're only using the "pseudo-intf" entry }
end;

procedure TReplicator<T>.RegisterClassMapping(const ASource, ADest: TObject);
begin
  { Create the dictionary if it's not created yet. }
  if FObjectMap = nil then
    FObjectMap := TCorePointerDictionary.Create();

  { Register }
  FObjectMap.Add(ASource, ADest);
end;

procedure TReplicator<T>.RegisterDynArrayMapping(const ASource, ADest: Pointer);
begin
  { Create the dictionary if it's not created yet. }
  if FRecordMap = nil then
    FRecordMap := TCorePointerDictionary.Create();

  { Register }
  FRecordMap.Add(ASource, ADest);
end;

procedure TReplicator<T>.RegisterRecordMapping(const ASource, ADest: Pointer);
begin
  { Create the dictionary if it's not created yet. }
  if FRecordMap = nil then
    FRecordMap := TCorePointerDictionary.Create();

  { Register }
  FRecordMap.Add(ASource, ADest);
end;

procedure TReplicator<T>.Replicate(const AInput: T; out AOutput: T);
begin
  { Call internal helper. Start with default. }
  DoReplicate(AInput, AOutput, true);
end;

function TReplicator<T>.TryGetDynArrayMapping(const ASource: Pointer; out ADest: TDummyArray): Boolean;
var
  LDummy: TDummyArray;
begin
  { Check that dictionary actually exists. }
  if FDynArrayMap = nil then
    Exit(false);

  { Try get value. }
  Result := FDynArrayMap.TryGetValue(ASource, Pointer(LDummy));

  { Use an intermediate array variable. This way we assign it the pointer. Then we
    assign the dummy array to the output array, thus increasing it's ref count +1 and obtaining what we
    actually want. }
  ADest := LDummy;
end;

function TReplicator<T>.TryGetClassMapping(const ASource: TObject; out ADest: TObject): Boolean;
begin
  { Check that dictionary actually exists. }
  if FObjectMap = nil then
    Exit(false);

  { Try get value. }
  Result := FObjectMap.TryGetValue(ASource, Pointer(ADest));
end;

function TReplicator<T>.TryGetRecordMapping(const ASource: Pointer; out ADest: Pointer): Boolean;
begin
  { Check that dictionary actually exists. }
  if FRecordMap = nil then
    Exit(false);

  { Try get value. }
  Result := FRecordMap.TryGetValue(ASource, ADest);
end;

{ TCloneableObject }

procedure TCloneableObject.BeforeDestruction;
begin
  inherited;

  { Destroy the replicator instance, if it was created. }
  FReplicator.Free;
end;

function TCloneableObject.Clone: TObject;
var
  LLocal: TObject;
begin
  { Try to create instance (only if required) }
  if FReplicator = nil then
  begin
    LLocal := TReplicator<TCloneableObject>.Create();

    { Use interlocked for thread safety }
    if InterlockedCompareExchangePointer(Pointer(FReplicator), Pointer(LLocal), nil) <> nil then
      LLocal.Free;
  end;

  { Lock the replicator for other threads! }
  MonitorEnter(FReplicator);
  try
    { Replicate self. Disable ICloneable usage. }
    FReplicator.DoReplicate(Self, TCloneableObject(Result), false);

    { Set the ref count of the resulting object to zero }
    TCloneableObject(Result).FRefCount := 0;
  finally
    MonitorExit(FReplicator);
  end;
end;

{ CloneKind }

constructor CloneKind.Create(const AKind: TCloneKind);
begin
  FCloneKind := AKind;
end;

end.
