(*
* Copyright (c) 2008-2010, Ciobanu Alexandru
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

{$I DeHL.Defines.inc}
unit DeHL.Exceptions;
interface
uses SysUtils;

type
  ///  <summary>Represents all exceptions that are thrown when the type system is involved.</summary>
  ETypeException = class(Exception);

  ///  <summary>Represents all exceptions that are thrown when the type extension system is involved.</summary>
  ETypeExtensionException = class(Exception);

  ///  <summary>Thrown when the type conversion is impossible.</summary>
  ETypeConversionNotSupported = class(ETypeException);

  ///  <summary>Thrown when a Variant array cannot be created from a dynamic array of a given type.</summary>
  ETypeIncompatibleWithVariantArray = class(ETypeException);

  ///  <summary>Thrown when an attempt to call an unsupported default parameterless constructor is made.</summary>
  EDefaultConstructorNotAllowed = class(Exception);

  ///  <summary>Thrown when attempting to access a <c>NULL</c> nullable value.</summary>
  ENullValueException = class(Exception);

  ///  <summary>Thrown when attempting to access a <c>NULL</c> box value.</summary>
  EEmptyBoxException = class(Exception);

  ///  <summary>Thrown when a required argument is <c>nil</c> (but should not be).</summary>
  ENilArgumentException = class(EArgumentException);

  ///  <summary>Thrown when a given argument combination specifies a smaller range than required.</summary>
  ///  <remarks>This exception is usually used by collections. The exception is thrown when there is not enough
  ///  space in an array to copy the values to.</remarks>
  EArgumentOutOfSpaceException = class(EArgumentOutOfRangeException);

  ///  <summary>Thrown when attempting to compare two objects of different classes.</summary>
  ENotSameTypeArgumentException = class(EArgumentException);

  ///  <summary>Thrown when a <see cref="DeHL.Base|TRefCountedObject">DeHL.Base.TRefCountedObject</see> tries to keep itself alive.</summary>
  ECannotSelfReferenceException = class(Exception);

  ///  <summary>Represents all exceptions that are thrown when collections are involved.</summary>
  ECollectionException = class(Exception);

  ///  <summary>Thrown when an enumerator detects that the enumerated collection was changed.</summary>
  ECollectionChangedException = class(ECollectionException);

  ///  <summary>Thrown when a collection was identified to be empty (and it shouldn't have been).</summary>
  ECollectionEmptyException = class(ECollectionException);

  ///  <summary>Thrown when a collection was expected to have only one exception.</summary>
  ECollectionNotOneException = class(ECollectionException);

  ///  <summary>Thrown when a predicated applied to a collection generates a void collection.</summary>
  ECollectionFilteredEmptyException = class(ECollectionException);

  ///  <summary>Thrown when trying to add a key-value pair into a collection that already has that key
  ///  in it.</summary>
  EDuplicateKeyException = class(ECollectionException);

  ///  <summary>Thrown when the key (of a pair) is not found in the collection.</summary>
  EKeyNotFoundException = class(ECollectionException);

  ///  <summary>Thrown when trying to operate on an element that is not a part of the parent collection.</summary>
  EElementNotPartOfCollection = class(ECollectionException);

  ///  <summary>Thrown when trying to add an element to a collection that already has it.</summary>
  EElementAlreadyInACollection = class(ECollectionException);

  ///  <summary>Thrown when trying to set the element to a collection's occupied position.</summary>
  EPositionOccupiedException = class(ECollectionException);

  ///  <summary>Thrown when an argument is not in the desired format.</summary>
  EArgumentFormatException = class(Exception);

  ///  <summary>Represents all exceptions that are thrown when the serialization system is involved.</summary>
  ESerializationException = class(Exception);

  ///  <summary>Thrown when the value of a given field cannot be deserialized.</summary>
  EFieldMissingException = class(ESerializationException);

  ///  <summary>Thrown when a value cannot be properly serialized.</summary>
  ESerializationValueException = class(ESerializationException);

  ///  <summary>Thrown when reference serialization errors occur.</summary>
  ESerializationReferenceException = class(ESerializationException);

  ///  <summary>A static class that offers methods for throwing DeHL exceptions.</summary>
  ///  <remarks><see cref="DeHL.Exceptions|ExceptionHelper">DeHL.Exceptions.ExceptionHelper</see> is used internally in DeHL to
  ///  throw all kinds of exceptions. This class is useful because it separates the exceptions
  ///  (including the messages) from the rest of the code.</remarks>
  ExceptionHelper = class sealed
  public
    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_NoDefaultTypeError(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CustomTypeHasNoRTTI();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_RuntimeTypeRestrictionFailed(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CustomTypeAlreadyRegistered(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CustomTypeNotYetRegistered(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ConversionNotSupported(const ToTypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_TypeIncompatibleWithVariantArray(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_MissingFieldError(const TypeName, FieldName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_Unserializable(const EntityName, TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_MarkedUnserializable(const EntityName, TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_WrongOrMissingRTTI(const EntityName, TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_InvalidSerializationIdentifier(const IdName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ValueSerializationFailed(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_UnexpectedDeserializationEntity(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_InvalidDeserializationValue(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_BinaryValueSizeMismatch(const EntityName, TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_UnexpectedReferencedType(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ExpectedReferencedType(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_BadSerializationContext(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_MissingCompositeType();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_InvalidArray(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_DeserializationReadError(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ReferencePointNotYetDeserialized(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_RefRegisteredOrIsNil(const EntityName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ClassNotFound(const EntityName, ClassName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_NullValueRequested();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_TheBoxIsEmpty();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_TypeExtensionAlreadyRegistered(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_TypeExtensionNotYetRegistered(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_InvalidFloatParam(const ArgName: string);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_NeedsRounding();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_OverflowError();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_DivByZeroError();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_NoMathExtensionForType(const TypeName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_DefaultConstructorNotAllowedError();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CannotSelfReferenceError();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ArgumentNotSameTypeError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ArgumentNilError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ArgumentOutOfRangeError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ArgumentOutOfSpaceError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_InvalidArgumentFormatError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ArgumentConverError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CollectionChangedError();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CollectionEmptyError();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CollectionHasMoreThanOneElement();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_CollectionHasNoFilteredElements();

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_DuplicateKeyError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_KeyNotFoundError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ElementNotPartOfCollectionError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_ElementAlreadyPartOfCollectionError(const ArgName: String);

    ///  <summary>Internal method. Do not call directly!</summary>
    ///  <remarks>The interface of this function may change in the future.</remarks>
    class procedure Throw_PositionOccupiedError();
  end;

implementation
uses
  DeHL.StrConsts;

{ ExceptionHelper }

class procedure ExceptionHelper.Throw_ArgumentNilError(const ArgName: String);
begin
  raise ENilArgumentException.CreateFmt(SNilArgument, [ArgName]);
end;

class procedure ExceptionHelper.Throw_ArgumentNotSameTypeError(const ArgName: String);
begin
  raise ENotSameTypeArgumentException.CreateFmt(SNotSameTypeArgument, [ArgName]);
end;

class procedure ExceptionHelper.Throw_ArgumentOutOfRangeError(const ArgName: String);
begin
  raise EArgumentOutOfRangeException.CreateFmt(SOutOfRangeArgument, [ArgName]);
end;

class procedure ExceptionHelper.Throw_ArgumentOutOfSpaceError(const ArgName: String);
begin
  raise EArgumentOutOfSpaceException.CreateFmt(SOutOfSpaceArgument, [ArgName]);
end;

class procedure ExceptionHelper.Throw_BadSerializationContext(const EntityName: String);
begin
  raise ESerializationException.CreateFmt(SBadSerializationContext, [EntityName]);
end;

class procedure ExceptionHelper.Throw_CannotSelfReferenceError;
begin
  raise ECannotSelfReferenceException.Create(SCannotSelfReference);
end;

class procedure ExceptionHelper.Throw_ClassNotFound(const EntityName, ClassName: String);
begin
  raise ESerializationReferenceException.CreateFmt(SClassNotFound, [EntityName, ClassName]);
end;

class procedure ExceptionHelper.Throw_CollectionChangedError;
begin
  raise ECollectionChangedException.Create(SParentCollectionChanged);
end;

class procedure ExceptionHelper.Throw_CollectionEmptyError;
begin
  raise ECollectionEmptyException.Create(SEmptyCollection);
end;

class procedure ExceptionHelper.Throw_CollectionHasMoreThanOneElement;
begin
  raise ECollectionNotOneException.Create(SCollectionHasMoreThanOneElements);
end;

class procedure ExceptionHelper.Throw_CollectionHasNoFilteredElements;
begin
  raise ECollectionFilteredEmptyException.Create(SCollectionHasNoFilteredElements);
end;

class procedure ExceptionHelper.Throw_ConversionNotSupported(const ToTypeName: String);
begin
  raise ETypeConversionNotSupported.CreateFmt(STypeConversionNotSupported, [ToTypeName]);
end;

class procedure ExceptionHelper.Throw_CustomTypeAlreadyRegistered(const TypeName: String);
begin
  raise ETypeException.CreateFmt(SCustomTypeAlreadyRegistered, [TypeName]);
end;

class procedure ExceptionHelper.Throw_CustomTypeHasNoRTTI;
begin
  raise ETypeException.Create(SCustomTypeHasNoRTTI);
end;

class procedure ExceptionHelper.Throw_CustomTypeNotYetRegistered(const TypeName: String);
begin
  raise ETypeException.CreateFmt(SCustomTypeNotYetRegistered, [TypeName]);
end;

class procedure ExceptionHelper.Throw_ArgumentConverError(const ArgName: String);
begin
  raise EConvertError.CreateFmt(SConvertProblemArgument, [ArgName]);
end;

class procedure ExceptionHelper.Throw_DefaultConstructorNotAllowedError;
begin
  raise EDefaultConstructorNotAllowed.Create(SDefaultParameterlessCtorNotAllowed);
end;

class procedure ExceptionHelper.Throw_DeserializationReadError(const EntityName: String);
begin
  raise ESerializationException.CreateFmt(SDeserializationReadError, [EntityName]);
end;

class procedure ExceptionHelper.Throw_DivByZeroError();
begin
  raise EDivByZero.Create(SDivisionByZero);
end;

class procedure ExceptionHelper.Throw_DuplicateKeyError(const ArgName: String);
begin
  raise EDuplicateKeyException.CreateFmt(SDuplicateKey, [ArgName]);
end;

class procedure ExceptionHelper.Throw_ElementAlreadyPartOfCollectionError(const ArgName: String);
begin
  raise EElementAlreadyInACollection.CreateFmt(SElementAlreadyInAnotherCollection, [ArgName]);
end;

class procedure ExceptionHelper.Throw_ElementNotPartOfCollectionError(const ArgName: String);
begin
  raise EElementNotPartOfCollection.CreateFmt(SElementNotInCollection, [ArgName]);
end;

class procedure ExceptionHelper.Throw_ExpectedReferencedType(const EntityName: String);
begin
  raise ESerializationException.CreateFmt(SExpectedReferencedType, [EntityName]);
end;

class procedure ExceptionHelper.Throw_InvalidArgumentFormatError(const ArgName: String);
begin
  raise EArgumentFormatException.CreateFmt(SBrokenFormatArgument, [ArgName]);
end;

class procedure ExceptionHelper.Throw_InvalidArray(const EntityName: String);
begin
  raise ESerializationException.CreateFmt(SInvalidArray, [EntityName]);
end;

class procedure ExceptionHelper.Throw_InvalidDeserializationValue(const EntityName: String);
begin
  raise ESerializationValueException.CreateFmt(SInvalidDeserializationValue, [EntityName]);
end;

class procedure ExceptionHelper.Throw_InvalidFloatParam(const ArgName: string);
begin
  raise EInvalidOp.CreateFmt(SInvalidFloatParam, [ArgName]);
end;

class procedure ExceptionHelper.Throw_InvalidSerializationIdentifier(const IdName: String);
begin
  raise ESerializationException.CreateFmt(SInvalidSerializationIdentifier, [IdName]);
end;

class procedure ExceptionHelper.Throw_KeyNotFoundError(const ArgName: String);
begin
  raise EKeyNotFoundException.CreateFmt(SKeyNotFound, [ArgName]);
end;

class procedure ExceptionHelper.Throw_MissingCompositeType;
begin
  raise EFieldMissingException.Create(SMissingCompositeType);
end;

class procedure ExceptionHelper.Throw_MissingFieldError(const TypeName, FieldName: String);
begin
  raise EFieldMissingException.CreateFmt(SNoSuchField, [TypeName, FieldName]);
end;

class procedure ExceptionHelper.Throw_NeedsRounding;
begin
  raise EInvalidOp.Create(SNeedsRounding);
end;

class procedure ExceptionHelper.Throw_NoDefaultTypeError(const TypeName: String);
begin
  raise ETypeException.CreateFmt(SNoDefaultType, [TypeName]);
end;

class procedure ExceptionHelper.Throw_UnexpectedDeserializationEntity(const EntityName: String);
begin
  raise ESerializationValueException.CreateFmt(SUnexpectedDeserializationEntity, [EntityName]);
end;

class procedure ExceptionHelper.Throw_NoMathExtensionForType(const TypeName: String);
begin
  raise ETypeExtensionException.CreateFmt(SNoMathExtensionForType, [TypeName]);
end;

class procedure ExceptionHelper.Throw_MarkedUnserializable(const EntityName, TypeName: String);
begin
  raise ESerializationException.CreateFmt(SMarkedUnserializable, [EntityName, TypeName]);
end;

class procedure ExceptionHelper.Throw_NullValueRequested;
begin
  raise ENullValueException.Create(SNullValueRequested);
end;

class procedure ExceptionHelper.Throw_OverflowError();
begin
  raise EOverflow.Create(SArithmeticOverflow);
end;

class procedure ExceptionHelper.Throw_PositionOccupiedError;
begin
  raise EPositionOccupiedException.Create(SRequestedPositionIsOccupied);
end;

class procedure ExceptionHelper.Throw_ReferencePointNotYetDeserialized(const EntityName: String);
begin
  raise ESerializationReferenceException.CreateFmt(SReferencePointNotYetDeserialized, [EntityName]);
end;

class procedure ExceptionHelper.Throw_RefRegisteredOrIsNil(const EntityName: String);
begin
  raise ESerializationReferenceException.CreateFmt(SRefRegisteredOrIsNil, [EntityName]);
end;

class procedure ExceptionHelper.Throw_RuntimeTypeRestrictionFailed(const TypeName: String);
begin
  raise ETypeException.CreateFmt(SRuntimeTypeRestrictionFailed, [TypeName]);
end;

class procedure ExceptionHelper.Throw_TheBoxIsEmpty;
begin
  raise EEmptyBoxException.Create(STheBoxIsEmpty);
end;

class procedure ExceptionHelper.Throw_TypeExtensionAlreadyRegistered(const TypeName: String);
begin
  raise ETypeExtensionException.CreateFmt(SExtensionTypeAlreadyRegistered, [TypeName]);
end;

class procedure ExceptionHelper.Throw_TypeExtensionNotYetRegistered(const TypeName: String);
begin
  raise ETypeExtensionException.CreateFmt(SExtensionTypeNotYetRegistered, [TypeName]);
end;

class procedure ExceptionHelper.Throw_TypeIncompatibleWithVariantArray(const TypeName: String);
begin
  raise ETypeIncompatibleWithVariantArray.CreateFmt(STypeIncompatibleWithVariantArray, [TypeName]);
end;

class procedure ExceptionHelper.Throw_UnexpectedReferencedType(const EntityName: String);
begin
  raise ESerializationException.CreateFmt(SUnexpectedReferencedType, [EntityName]);
end;

class procedure ExceptionHelper.Throw_Unserializable(const EntityName, TypeName: String);
begin
  raise ESerializationException.CreateFmt(SUnserializable, [EntityName, TypeName]);
end;

class procedure ExceptionHelper.Throw_ValueSerializationFailed(const TypeName: String);
begin
  raise ESerializationException.CreateFmt(SValueSerializationFailed, [TypeName]);
end;

class procedure ExceptionHelper.Throw_WrongOrMissingRTTI(const EntityName, TypeName: String);
begin
  raise ESerializationException.CreateFmt(SWrongOrMissingRTTI, [EntityName, TypeName]);
end;

class procedure ExceptionHelper.Throw_BinaryValueSizeMismatch(const EntityName, TypeName: String);
begin
  raise ESerializationValueException.CreateFmt(SBinaryValueSizeMismatch, [EntityName, TypeName]);
end;

end.
