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
unit DeHL.Collections.SortedSet;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Types,
     DeHL.StrConsts,
     DeHL.Exceptions,
     DeHL.Arrays,
     DeHL.Serialization,
     DeHL.Collections.Base;

type
  ///  <summary>The generic <c>set</c> collection.</summary>
  ///  <remarks>This type uses an AVL tree to store its values.</remarks>
  TSortedSet<T> = class(TEnexCollection<T>, ISet<T>)
  private type
    {$REGION 'Internal Types'}
    TBalanceAct = (baStart, baLeft, baRight, baLoop, baEnd);

    { An internal node class }
    TNode = class
    private
      FKey: T;

      FParent,
       FLeft, FRight: TNode;

      FBalance: ShortInt;
    end;

    TEnumerator = class(TEnumerator<T>)
    private
      FVer: NativeUInt;
      FDict: TSortedSet<T>;
      FNext: TNode;
      FValue: T;

    public
      { Constructor }
      constructor Create(const ADict: TSortedSet<T>);

      { Destructor }
      destructor Destroy(); override;

      function GetCurrent(): T; override;
      function MoveNext(): Boolean; override;
    end;
    {$ENDREGION}

  private var
    FCount: NativeUInt;
    FVer: NativeUInt;
    FRoot: TNode;
    FSignFix: NativeInt;

    { Some internals }
    function FindNodeWithKey(const AValue: T): TNode;
    function FindLeftMostNode(): TNode;
    function FindRightMostNode(): TNode;
    function WalkToTheRight(const ANode: TNode): TNode;

    { ... }
    function MakeNode(const AValue: T; const ARoot: TNode): TNode;
    procedure RecursiveClear(const ANode: TNode);
    procedure ReBalanceSubTreeOnInsert(const ANode: TNode);
    procedure Insert(const AValue: T);

    { Removal }
    procedure BalanceTreesAfterRemoval(const ANode: TNode);
  protected
    ///  <summary>Called when the serialization process is about to begin.</summary>
    ///  <param name="AData">The serialization data exposing the context and other serialization options.</param>
    procedure StartSerializing(const AData: TSerializationData); override;

    ///  <summary>Called when the deserialization process is about to begin.</summary>
    ///  <param name="AData">The deserialization data exposing the context and other deserialization options.</param>
    ///  <exception cref="DeHL.Exceptions|ESerializationException">Default implementation.</exception>
    procedure StartDeserializing(const AData: TDeserializationData); override;

    ///  <summary>Called when the an element has been deserialized and needs to be inserted into the set.</summary>
    ///  <param name="AElement">The element that was deserialized.</param>
    ///  <remarks>This method simply adds the element to the set.</remarks>
    procedure DeserializeElement(const AElement: T); override;

    ///  <summary>Returns the number of elements in the set.</summary>
    ///  <returns>A positive value specifying the number of elements in the set.</returns>
    function GetCount(): NativeUInt; override;
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
    ///  <param name="AType">A type object decribing the elements in the set.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the set.</param>
    ///  <param name="ACollection">A collection to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="ACollection"/> is <c>nil</c>.</exception>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const ACollection: IEnumerable<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the set.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: array of T; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the set.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TDynamicArray<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Creates a new instance of this class.</summary>
    ///  <param name="AType">A type object decribing the elements in the set.</param>
    ///  <param name="AArray">An array to copy elements from.</param>
    ///  <param name="AAscending">Specifies whether the elements are kept sorted in ascending order. Default is <c>True</c>.</param>
    ///  <exception cref="DeHL.Exceptions|ENilArgumentException"><paramref name="AType"/> is <c>nil</c>.</exception>
    constructor Create(const AType: IType<T>; const AArray: TFixedArray<T>; const AAscending: Boolean = true); overload;

    ///  <summary>Destroys this instance.</summary>
    ///  <remarks>Do not call this method directly, call <c>Free</c> instead</remarks>
    destructor Destroy(); override;

    ///  <summary>Clears the contents of the set.</summary>
    ///  <remarks>This method clears the set and invokes type object's cleaning routines for each element.</remarks>
    procedure Clear();

    ///  <summary>Adds an element to the set.</summary>
    ///  <param name="AValue">The value to add.</param>
    ///  <remarks>If the set already contains the given value, nothing happens.</remarks>
    procedure Add(const AValue: T);

    ///  <summary>Removes a given value from the set.</summary>
    ///  <param name="AValue">The value to remove.</param>
    ///  <remarks>If the set does not contain the given value, nothing happens.</remarks>
    procedure Remove(const AValue: T);

    ///  <summary>Checks whether the set contains a given value.</summary>
    ///  <param name="AValue">The value to check.</param>
    ///  <returns><c>True</c> if the value was found in the set; <c>False</c> otherwise.</returns>
    function Contains(const AValue: T): Boolean;

    ///  <summary>Specifies the number of elements in the set.</summary>
    ///  <returns>A positive value specifying the number of elements in the set.</returns>
    property Count: NativeUInt read FCount;

    ///  <summary>Returns a new enumerator object used to enumerate this set.</summary>
    ///  <remarks>This method is usually called by compiler generated code. Its purpose is to create an enumerator
    ///  object that is used to actually traverse the set.</remarks>
    ///  <returns>An enumerator object.</returns>
    function GetEnumerator() : IEnumerator<T>; override;

    ///  <summary>Copies the values stored in the set to a given array.</summary>
    ///  <param name="AArray">An array where to copy the contents of the set.</param>
    ///  <param name="AStartIndex">The index into the array at which the copying begins.</param>
    ///  <remarks>This method assumes that <paramref name="AArray"/> has enough space to hold the contents of the set.</remarks>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfRangeException"><paramref name="AStartIndex"/> is out of bounds.</exception>
    ///  <exception cref="DeHL.Exceptions|EArgumentOutOfSpaceException">There array is not long enough.</exception>
    procedure CopyTo(var AArray: array of T; const StartIndex: NativeUInt); overload; override;

    ///  <summary>Checks whether the set is empty.</summary>
    ///  <returns><c>True</c> if the set is empty; <c>False</c> otherwise.</returns>
    ///  <remarks>This method is the recommended way of detecting if the set is empty.</remarks>
    function Empty(): Boolean; override;

    ///  <summary>Returns the biggest element.</summary>
    ///  <returns>An element from the set considered to have the biggest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The set is empty.</exception>
    function Max(): T; override;

    ///  <summary>Returns the smallest element.</summary>
    ///  <returns>An element from the set considered to have the smallest value.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The set is empty.</exception>
    function Min(): T; override;

    ///  <summary>Returns the first element.</summary>
    ///  <returns>The first element in the set.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The set is empty.</exception>
    function First(): T; override;

    ///  <summary>Returns the first element or a default if the set is empty.</summary>
    ///  <param name="ADefault">The default value returned if the set is empty.</param>
    ///  <returns>The first element in set if the set is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function FirstOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the last element.</summary>
    ///  <returns>The last element in the set.</returns>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The set is empty.</exception>
    function Last(): T; override;

    ///  <summary>Returns the last element or a default if the set is empty.</summary>
    ///  <param name="ADefault">The default value returned if the set is empty.</param>
    ///  <returns>The last element in set if the set is not empty; otherwise <paramref name="ADefault"/> is returned.</returns>
    function LastOrDefault(const ADefault: T): T; override;

    ///  <summary>Returns the single element stored in the set.</summary>
    ///  <returns>The element in set.</returns>
    ///  <remarks>This method checks if the set contains just one element, in which case it is returned.</remarks>
    ///  <exception cref="DeHL.Exceptions|ECollectionEmptyException">The set is empty.</exception>
    ///  <exception cref="DeHL.Exceptions|ECollectionNotOneException">There is more than one element in the set.</exception>
    function Single(): T; override;

    ///  <summary>Returns the single element stored in the set, or a default value.</summary>
    ///  <param name="ADefault">The default value returned if there is less or more elements in the set.</param>
    ///  <returns>The element in the set if the condition is satisfied; <paramref name="ADefault"/> is returned otherwise.</returns>
    ///  <remarks>This method checks if the set contains just one element, in which case it is returned. Otherwise
    ///  the value in <paramref name="ADefault"/> is returned.</remarks>
    function SingleOrDefault(const ADefault: T): T; override;
  end;

  ///  <summary>The generic <c>set</c> collection designed to store objects.</summary>
  ///  <remarks>This type uses an AVL tree to store its objects.</remarks>
  TObjectSortedSet<T: class> = class(TSortedSet<T>)
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
    ///  <summary>Specifies whether this set owns the objects stored in it.</summary>
    ///  <returns><c>True</c> if the set owns its objects; <c>False</c> otherwise.</returns>
    ///  <remarks>This property controls the way the set controls the life-time of the stored objects.</remarks>
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

{ TSortedSet<T> }

procedure TSortedSet<T>.Add(const AValue: T);
begin
  { Insert the value }
  Insert(AValue);
end;

procedure TSortedSet<T>.BalanceTreesAfterRemoval(const ANode: TNode);
var
  CurrentAct: TBalanceAct;
  LNode, XNode,
    SNode, WNode,
      YNode: TNode;
begin
  { Initiliaze ... }
  CurrentAct := TBalanceAct.baStart;
  LNode := ANode;

  { Continue looping until end is declared }
  while CurrentAct <> TBalanceAct.baEnd do
  begin
    case CurrentAct of

      { START MODE }
      TBalanceAct.baStart:
      begin
        if LNode.FRight = nil then
        begin
          { Exclude myself! }
          if LNode.FLeft <> nil then
            LNode.FLeft.FParent := LNode.FParent;

          { I'm root! nothing to do here }
          if LNode.FParent = nil then
          begin
            FRoot := LNode.FLeft;

            { DONE! }
            CurrentAct := TBalanceAct.baEnd;
            continue;
          end;

          { ... }
          if LNode = LNode.FParent.FLeft then
          begin
            LNode.FParent.FLeft := LNode.FLeft;
            YNode := LNode.FParent;
          end else
          begin
            LNode.FParent.FRight := LNode.FLeft;
            YNode := LNode.FParent;

            { RIGHT! }
            CurrentAct := TBalanceAct.baRight;
            continue;
          end;
        end else if LNode.FRight.FLeft = nil then
        begin
          { Case 1, RIGHT, NO LEFT }
          if LNode.FLeft <> nil then
          begin
            LNode.FLeft.FParent := LNode.FRight;
            LNode.FRight.FLeft := LNode.FLeft;
          end;

          LNode.FRight.FBalance := LNode.FBalance;
          LNode.FRight.FParent := LNode.FParent;

          if LNode.FParent = nil then
            FRoot := LNode.FRight
          else
          begin
            if LNode = LNode.FParent.FLeft then
              LNode.FParent.FLeft := LNode.FRight
            else
              LNode.FParent.FRight := LNode.FRight;
          end;

          YNode := LNode.FRight;

          { RIGHT! }
          CurrentAct := TBalanceAct.baRight;
          continue;
        end else
        begin
          { Case 3: RIGHT+LEFT }
          SNode := LNode.FRight.FLeft;

          while SNode.FLeft <> nil do
            SNode := SNode.FLeft;

          if LNode.FLeft <> nil then
          begin
            LNode.FLeft.FParent := SNode;
            SNode.FLeft := LNode.FLeft;
          end;

          SNode.FParent.FLeft := SNode.FRight;

          if SNode.FRight <> nil then
            SNode.FRight.FParent := SNode.FParent;

          LNode.FRight.FParent := SNode;
          SNode.FRight := LNode.FRight;

          YNode := SNode.FParent;

          SNode.FBalance := LNode.FBalance;
          SNode.FParent := LNode.FParent;

          if LNode.FParent = nil then
            FRoot := SNode
          else
          begin
            if LNode = LNode.FParent.FLeft then
              LNode.FParent.FLeft := SNode
            else
              LNode.FParent.FRight := SNode;
          end;
        end;

        { LEFT! }
        CurrentAct := TBalanceAct.baLeft;
        continue;
      end; { baStart }

      { LEFT BALANCING MODE }
      TBalanceAct.baLeft:
      begin
        Inc(YNode.FBalance);

        if YNode.FBalance = 1 then
        begin
          { DONE! }
          CurrentAct := TBalanceAct.baEnd;
          continue;
        end
        else if YNode.FBalance = 2 then
        begin
          XNode := YNode.FRight;

          if XNode.FBalance = -1 then
          begin
            WNode := XNode.FLeft;
            WNode.FParent := YNode.FParent;

            if YNode.FParent = nil then
              FRoot := WNode
            else
            begin
              if YNode.FParent.FLeft = YNode then
                YNode.FParent.FLeft := WNode
              else
                YNode.FParent.FRight := WNode;
            end;

            XNode.FLeft := WNode.FRight;

            if XNode.FLeft <> nil then
              XNode.FLeft.FParent := XNode;

            YNode.FRight := WNode.FLeft;

            if YNode.FRight <> nil then
              YNode.FRight.FParent := YNode;

            WNode.FRight := XNode;
            WNode.FLeft := YNode;

            XNode.FParent := WNode;
            YNode.FParent := WNode;

            if WNode.FBalance = 1 then
            begin
              XNode.FBalance := 0;
              YNode.FBalance := -1;
            end else if WNode.FBalance = 0 then
            begin
              XNode.FBalance := 0;
              YNode.FBalance := 0;
            end else
            begin
              XNode.FBalance := 1;
              YNode.FBalance := 0;
            end;

            WNode.FBalance := 0;
            YNode := WNode;
          end else
          begin
            XNode.FParent := YNode.FParent;

            if YNode.FParent <> nil then
            begin
              if YNode.FParent.FLeft = YNode then
                YNode.FParent.FLeft := XNode
              else
                YNode.FParent.FRight := XNode;
            end else
              FRoot := XNode;

            YNode.FRight := XNode.FLeft;

            if YNode.FRight <> nil then
              YNode.FRight.FParent := YNode;

            XNode.FLeft := YNode;
            YNode.FParent := XNode;

            if XNode.FBalance = 0 then
            begin
              XNode.FBalance := -1;
              YNode.FBalance := 1;

              { DONE! }
              CurrentAct := TBalanceAct.baEnd;
              continue;
            end else
            begin
              XNode.FBalance := 0;
              YNode.FBalance := 0;

              YNode := XNode;
            end;
          end;
        end;

        { LOOP! }
        CurrentAct := TBalanceAct.baLoop;
        continue;
      end; { baLeft }

      { RIGHT BALANCING MODE }
      TBalanceAct.baRight:
      begin
        Dec(YNode.FBalance);

        if YNode.FBalance = -1 then
        begin
          { DONE! }
          CurrentAct := TBalanceAct.baEnd;
          continue;
        end
        else if YNode.FBalance = -2 then
        begin
          XNode := YNode.FLeft;

          if XNode.FBalance = 1 then
          begin
            WNode := XNode.FRight;
            WNode.FParent := YNode.FParent;

            if YNode.FParent = nil then
              FRoot := WNode
            else
            begin
              if YNode.FParent.FLeft = YNode then
                YNode.FParent.FLeft := WNode
              else
                YNode.FParent.FRight := WNode;
            end;

            XNode.FRight := WNode.FLeft;

            if XNode.FRight <> nil then
              XNode.FRight.FParent := XNode;

            YNode.FLeft := WNode.FRight;

            if YNode.FLeft <> nil then
              YNode.FLeft.FParent := YNode;

            WNode.FLeft := XNode;
            WNode.FRight := YNode;

            XNode.FParent := WNode;
            YNode.FParent := WNode;

            if WNode.FBalance = -1 then
            begin
              XNode.FBalance := 0;
              YNode.FBalance := 1;
            end else if WNode.FBalance = 0 then
            begin
              XNode.FBalance := 0;
              YNode.FBalance := 0;
            end else
            begin
              XNode.FBalance := -1;
              YNode.FBalance := 0;
            end;

            WNode.FBalance := 0;
            YNode := WNode;
          end else
          begin
            XNode.FParent := YNode.FParent;

            if YNode.FParent <> nil then
            begin
              if YNode.FParent.FLeft = YNode then
                YNode.FParent.FLeft := XNode
              else
                YNode.FParent.FRight := XNode
            end else
              FRoot := XNode;

            YNode.FLeft := XNode.FRight;

            if YNode.FLeft <> nil then
              YNode.FLeft.FParent := YNode;

            XNode.FRight := YNode;
            YNode.FParent := XNode;

            if XNode.FBalance = 0 then
            begin
              XNode.FBalance := 1;
              YNode.FBalance := -1;

              { END! }
              CurrentAct := TBalanceAct.baEnd;
              continue;
            end else
            begin
              XNode.FBalance := 0;
              YNode.FBalance := 0;

              YNode := XNode;
            end;
          end;
        end;

        { LOOP! }
        CurrentAct := TBalanceAct.baLoop;
        continue;
      end; { baRight }

      TBalanceAct.baLoop:
      begin
        { Verify continuation }
        if YNode.FParent <> nil then
        begin
          if YNode = YNode.FParent.FLeft then
          begin
            YNode := YNode.FParent;

            { LEFT! }
            CurrentAct := TBalanceAct.baLeft;
            continue;
          end;

          YNode := YNode.FParent;

          { RIGHT! }
          CurrentAct := TBalanceAct.baRight;
          continue;
        end;

        { END! }
        CurrentAct := TBalanceAct.baEnd;
        continue;
      end;
    end; { Case }
  end; { While }
end;

procedure TSortedSet<T>.Clear;
begin
  if FRoot <> nil then
  begin
    RecursiveClear(FRoot);
    FRoot := nil;

    { Update markers }
    Inc(FVer);
    FCount := 0;
  end;
end;

function TSortedSet<T>.Contains(const AValue: T): Boolean;
begin
  Result := FindNodeWithKey(AValue) <> nil;
end;

procedure TSortedSet<T>.CopyTo(var AArray: array of T; const StartIndex: NativeUInt);
var
  X: NativeInt;
  LNode: TNode;
begin
  { Check for indexes }
  if StartIndex >= NativeUInt(Length(AArray)) then
    ExceptionHelper.Throw_ArgumentOutOfRangeError('StartIndex');

  if (NativeUInt(Length(AArray)) - StartIndex) < FCount then
     ExceptionHelper.Throw_ArgumentOutOfSpaceError('AArray');

  X := StartIndex;

  { Find the left-most node }
  LNode := FindLeftMostNode();

  while (LNode <> nil) do
  begin
    { Get the key }
    AArray[X] := LNode.FKey;

    { Navigate further in the tree }
    LNode := WalkToTheRight(LNode);

    { Increment the index }
    Inc(X);
  end;
end;

constructor TSortedSet<T>.Create(const AAscending: Boolean);
begin
  Create(TType<T>.Default, AAscending);
end;

constructor TSortedSet<T>.Create(const ACollection: IEnumerable<T>;
  const AAscending: Boolean);
begin
  Create(TType<T>.Default, ACollection, AAscending);
end;

constructor TSortedSet<T>.Create(const AType: IType<T>;
  const ACollection: IEnumerable<T>; const AAscending: Boolean);
var
  V: T;
begin
  { Call upper constructor }
  Create(AType, AAscending);

  if (ACollection = nil) then
     ExceptionHelper.Throw_ArgumentNilError('ACollection');

  { Pump in all items }
  for V in ACollection do
  begin
    Add(V);
  end;
end;

constructor TSortedSet<T>.Create(const AType: IType<T>; const AAscending: Boolean);
begin
  { Initialize instance }
  if (AType = nil) then
     ExceptionHelper.Throw_ArgumentNilError('AType');

  InstallType(AType);

  FVer := 0;
  FCount := 0;

  if AAscending then
    FSignFix := 1
  else
    FSignFix := -1;
end;

procedure TSortedSet<T>.DeserializeElement(const AElement: T);
begin
  { Simple as hell ... }
  Add(AElement);
end;

destructor TSortedSet<T>.Destroy;
begin
  { Clear first }
  Clear();

  inherited;
end;

function TSortedSet<T>.Empty: Boolean;
begin
  Result := (FRoot = nil);
end;

function TSortedSet<T>.FindLeftMostNode: TNode;
begin
  { Start with root }
  Result := FRoot;

  { And go to maximum left }
  if Result <> nil then
  begin
    while Result.FLeft <> nil do
      Result := Result.FLeft;
  end;
end;

function TSortedSet<T>.FindNodeWithKey(const AValue: T): TNode;
var
  LNode: TNode;
  Compare: NativeInt;
begin
  { Get root }
  LNode := FRoot;

  while LNode <> nil do
  begin
	  Compare := ElementType.Compare(AValue, LNode.FKey) * FSignFix;

    { Navigate left, right or find! }
    if Compare < 0 then
      LNode := LNode.FLeft
    else if Compare > 0 then
      LNode := LNode.FRight
    else
      Exit(LNode);
  end;

  { Did not find anything ... }
  Result := nil;
end;

function TSortedSet<T>.FindRightMostNode: TNode;
begin
  { Start with root }
  Result := FRoot;

  { And go to maximum left }
  if Result <> nil then
  begin
    while Result.FRight <> nil do
      Result := Result.FRight;
  end;
end;

function TSortedSet<T>.First: T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FindLeftMostNode().FKey
end;

function TSortedSet<T>.FirstOrDefault(const ADefault: T): T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    Result := ADefault
  else
    Result := FindLeftMostNode().FKey
end;

function TSortedSet<T>.GetCount: NativeUInt;
begin
  Result := FCount;
end;

function TSortedSet<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

procedure TSortedSet<T>.Insert(const AValue: T);
var
  LNode: TNode;
  Compare: NativeInt;
begin
  { First one get special treatment! }
  if FRoot = nil then
  begin
    FRoot := MakeNode(AValue, nil);

    { Increase markers }
    Inc(FCount);
    Inc(FVer);

    { [ADDED NEW] Exit function }
    Exit;
  end;

  { Get root }
  LNode := FRoot;

  while true do
  begin
	  Compare := ElementType.Compare(AValue, LNode.FKey) * FSignFix;

    if Compare < 0 then
    begin
      if LNode.FLeft <> nil then
        LNode := LNode.FLeft
      else
      begin
        { Create a new node }
        LNode.FLeft := MakeNode(AValue, LNode);
        Dec(LNode.FBalance);

        { [ADDED NEW] Exit function! }
        break;
      end;
    end else if Compare > 0 then
    begin
      if LNode.FRight <> nil then
        LNode := LNode.FRight
      else
      begin
        LNode.FRight := MakeNode(AValue, LNode);
        Inc(LNode.FBalance);

        { [ADDED NEW] Exit function! }
        break;
      end;
    end else
    begin
      { Found a node with the same key. }
      { [NOTHING] Exit function }
      Exit();
    end;
  end;

  { Rebalance the tree }
  ReBalanceSubTreeOnInsert(LNode);

  Inc(FCount);
  Inc(FVer);
end;

function TSortedSet<T>.Last: T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    ExceptionHelper.Throw_CollectionEmptyError();

  Result := FindRightMostNode().FKey
end;

function TSortedSet<T>.LastOrDefault(const ADefault: T): T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    Result := ADefault
  else
    Result := FindRightMostNode().FKey
end;

function TSortedSet<T>.MakeNode(const AValue: T; const ARoot: TNode): TNode;
begin
  Result := TNode.Create();
  Result.FKey := AValue;
  Result.FParent := ARoot;
end;

function TSortedSet<T>.Max: T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    ExceptionHelper.Throw_CollectionEmptyError();

  if FSignFix = 1 then
    Result := FindRightMostNode().FKey
  else
    Result := FindLeftMostNode().FKey;
end;

function TSortedSet<T>.Min: T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    ExceptionHelper.Throw_CollectionEmptyError();

  if FSignFix = 1 then
    Result := FindLeftMostNode().FKey
  else
    Result := FindRightMostNode().FKey;
end;

procedure TSortedSet<T>.ReBalanceSubTreeOnInsert(const ANode: TNode);
var
  LNode, XNode, WNode: TNode;
  Compare: NativeInt;
begin
  (*
    DISCLAIMER: I HAVE LITTLE TO ABSOLUTELY NO IDEA HOW THIS SPAGETTI WORKS!
    DO NOT BLAME ME :D (Alex).
  *)

  LNode := ANode;

  { Re-balancing the tree! }
  while ((LNode.FBalance <> 0) and (LNode.FParent <> nil)) do
  begin
    if (LNode.FParent.FLeft = LNode) then
      Dec(LNode.FParent.FBalance)
    else
      Inc(LNode.FParent.FBalance);

    { Move up }
    LNode := LNode.FParent;

    if (LNode.FBalance = -2) then
    begin
      XNode := LNode.FLeft;

      if (XNode.FBalance = -1) then
      begin
        XNode.FParent := LNode.FParent;

        if (LNode.FParent = nil) then
          FRoot := XNode
        else
        begin
          if (LNode.FParent.FLeft = LNode) then
            LNode.FParent.FLeft := XNode
          else
            LNode.FParent.FRight := XNode;
        end;

        LNode.FLeft := XNode.FRight;

        if LNode.FLeft <> nil then
          LNode.FLeft.FParent := LNode;

        XNode.FRight := LNode;
        LNode.FParent := XNode;

        XNode.FBalance := 0;
        LNode.FBalance := 0;
      end else
      begin
        WNode := XNode.FRight;
        WNode.FParent := LNode.FParent;

        if LNode.FParent = nil then
          FRoot := WNode
        else
        begin
          if LNode.FParent.FLeft = LNode then
            LNode.FParent.FLeft := WNode
          else
            LNode.FParent.FRight := WNode;
        end;

        XNode.FRight := WNode.FLeft;

        if XNode.FRight <> nil then
          XNode.FRight.FParent := XNode;

        LNode.FLeft := WNode.FRight;

        if LNode.FLeft <> nil then
          LNode.FLeft.FParent := LNode;

        WNode.FLeft := XNode;
        WNode.FRight := LNode;

        XNode.FParent := WNode;
        LNode.FParent := WNode;

        { Apply proper balancing }
        if WNode.FBalance = -1 then
        begin
          XNode.FBalance := 0;
          LNode.FBalance := 1;
        end else if WNode.FBalance = 0 then
        begin
          XNode.FBalance := 0;
          LNode.FBalance := 0;
        end else
        begin
          XNode.FBalance := -1;
          LNode.FBalance := 0;
        end;

        WNode.FBalance := 0;
      end;

      break;
    end else if LNode.FBalance = 2 then
    begin
      XNode := LNode.FRight;

      if XNode.FBalance = 1 then
      begin
        XNode.FParent := LNode.FParent;

        if LNode.FParent = nil then
          FRoot := XNode
        else
        begin
          if LNode.FParent.FLeft = LNode then
            LNode.FParent.FLeft := XNode
          else
            LNode.FParent.FRight := XNode;
        end;

        LNode.FRight := XNode.FLeft;

        if LNode.FRight <> nil then
          LNode.FRight.FParent := LNode;

        XNode.FLeft := LNode;
        LNode.FParent := XNode;

        XNode.FBalance := 0;
        LNode.FBalance := 0;
      end else
      begin
        WNode := XNode.FLeft;
        WNode.FParent := LNode.FParent;

        if LNode.FParent = nil then
          FRoot := WNode
        else
        begin
          if LNode.FParent.FLeft = LNode then
            LNode.FParent.FLeft := WNode
          else
            LNode.FParent.FRight := WNode;
        end;

        XNode.FLeft := WNode.FRight;

        if XNode.FLeft <> nil then
          XNode.FLeft.FParent := XNode;

        LNode.FRight := WNode.FLeft;

        if LNode.FRight <> nil then
          LNode.FRight.FParent := LNode;

        WNode.FRight := XNode;
        WNode.FLeft := LNode;

        XNode.FParent := WNode;
        LNode.FParent := WNode;

        if WNode.FBalance = 1 then
        begin
          XNode.FBalance := 0;
          LNode.FBalance := -1;
        end else if WNode.FBalance = 0 then
        begin
          XNode.FBalance := 0;
          LNode.FBalance := 0;
        end else
        begin
          XNode.FBalance := 1;
          LNode.FBalance := 0;
        end;

        WNode.FBalance := 0;
      end;

      break;
    end;
  end;

end;

procedure TSortedSet<T>.Remove(const AValue: T);
var
  LNode: TNode;

begin
  { Get root }
  LNode := FindNodeWithKey(AValue);

  { Remove and rebalance the tree accordingly }
  if LNode = nil then
    Exit;

  { .. Do da dew! }
  BalanceTreesAfterRemoval(LNode);

  { Kill the node }
  LNode.Free;

  Dec(FCount);
  Inc(FVer);
end;

function TSortedSet<T>.Single: T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    ExceptionHelper.Throw_CollectionEmptyError();

  { Check for more than one }
  if (FRoot.FLeft <> nil) or (FRoot.FRight <> nil) then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement();

  Result := FRoot.FKey;
end;

function TSortedSet<T>.SingleOrDefault(const ADefault: T): T;
begin
  { Check there are elements in the set }
  if FRoot = nil then
    Exit(ADefault);

  { Check for more than one }
  if (FRoot.FLeft <> nil) or (FRoot.FRight <> nil) then
    ExceptionHelper.Throw_CollectionHasMoreThanOneElement();

  Result := FRoot.FKey;
end;

procedure TSortedSet<T>.StartDeserializing(const AData: TDeserializationData);
var
  LAsc: Boolean;
begin
  AData.GetValue(SSerAscendingKeys, LAsc);

  { Call the constructor in this instance to initialize myself first }
  Create(LAsc);
end;

procedure TSortedSet<T>.StartSerializing(const AData: TSerializationData);
begin
  { Write the ascending sign }
  AData.AddValue(SSerAscendingKeys, FSignFix = 1);
end;

procedure TSortedSet<T>.RecursiveClear(const ANode: TNode);
begin
  if ANode.FLeft <> nil then
    RecursiveClear(ANode.FLeft);

  if ANode.FRight <> nil then
    RecursiveClear(ANode.FRight);

  { Cleanup for Key/Value }
  if ElementType.Management = tmManual then
    ElementType.Cleanup(ANode.FKey);

  { Finally, free the node itself }
  ANode.Free;
end;

function TSortedSet<T>.WalkToTheRight(const ANode: TNode): TNode;
begin
  Result := ANode;

  if Result = nil then
    Exit;

  { Navigate further in the tree }
  if Result.FRight = nil then
  begin
    while ((Result.FParent <> nil) and (Result = Result.FParent.FRight)) do
      Result := Result.FParent;

    Result := Result.FParent;
  end else
  begin
    Result := Result.FRight;

    while Result.FLeft <> nil do
      Result := Result.FLeft;
  end;
end;

constructor TSortedSet<T>.Create(const AArray: array of T; const AAscending: Boolean);
begin
  Create(TType<T>.Default, AArray, AAscending);
end;

constructor TSortedSet<T>.Create(const AType: IType<T>; const AArray: array of T;
  const AAscending: Boolean);
var
  I: NativeInt;
begin
  { Call upper constructor }
  Create(AType, AAscending);

  { Copy all items in }
  for I := 0 to Length(AArray) - 1 do
  begin
    Add(AArray[I]);
  end;
end;

constructor TSortedSet<T>.Create(const AArray: TDynamicArray<T>; const AAscending: Boolean);
begin
  Create(TType<T>.Default, AArray, AAscending);
end;

constructor TSortedSet<T>.Create(const AArray: TFixedArray<T>; const AAscending: Boolean);
begin
  Create(TType<T>.Default, AArray, AAscending);
end;

constructor TSortedSet<T>.Create(const AType: IType<T>;
  const AArray: TDynamicArray<T>; const AAscending: Boolean);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType, AAscending);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Add(AArray[I]);
    end;
end;

constructor TSortedSet<T>.Create(const AType: IType<T>;
  const AArray: TFixedArray<T>;
  const AAscending: Boolean);
var
  I: NativeUInt;
begin
  { Call upper constructor }
  Create(AType, AAscending);

  { Copy all items in }
  if AArray.Length > 0 then
    for I := 0 to AArray.Length - 1 do
    begin
      Add(AArray[I]);
    end;
end;

{ TSortedSet<T>.TEnumerator }

constructor TSortedSet<T>.TEnumerator.Create(const ADict: TSortedSet<T>);
begin
  { Initialize }
  FDict := ADict;
  KeepObjectAlive(FDict);

  FNext := ADict.FindLeftMostNode();

  FVer := ADict.FVer;
end;

destructor TSortedSet<T>.TEnumerator.Destroy;
begin
  ReleaseObject(FDict);
  inherited;
end;

function TSortedSet<T>.TEnumerator.GetCurrent: T;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  Result := FValue;
end;

function TSortedSet<T>.TEnumerator.MoveNext: Boolean;
begin
  if FVer <> FDict.FVer then
     ExceptionHelper.Throw_CollectionChangedError();

  { Do not continue on last node }
  if FNext = nil then
    Exit(false);

  { Get the current value }
  FValue := FNext.FKey;

  { Navigate further in the tree }
  FNext := FDict.WalkToTheRight(FNext);

  Result := true;
end;

{ TObjectSortedSet<T> }

procedure TObjectSortedSet<T>.InstallType(const AType: IType<T>);
begin
  { Create a wrapper over the real type class and switch it }
  FWrapperType := TObjectWrapperType<T>.Create(AType);

  { Install overridden type }
  inherited InstallType(FWrapperType);
end;

function TObjectSortedSet<T>.GetOwnsObjects: Boolean;
begin
  Result := FWrapperType.AllowCleanup;
end;

procedure TObjectSortedSet<T>.SetOwnsObjects(const Value: Boolean);
begin
  FWrapperType.AllowCleanup := Value;
end;


end.
