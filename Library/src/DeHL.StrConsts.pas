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
unit DeHL.StrConsts;
interface

(*
   General warning: Do not rely on the strings defined in this file for your application.
   These strings may change; their names may change or many of them may even go away without any
   notice!

   This file is for internal DeHL use only!
*)

resourcestring
  SNeedsRounding = 'The BigDecimal division operation failed. Rounding was not requested but it is necessary!';
  SInvalidFloatParam = 'The value of parameter %s is NaN, Infinity, or cannot be represented properly.';
  SFutureException = 'Exception of class %s and message "%s" is raised during future evaluation.';
  SClassNotFound = 'Class "%s" (as specified by "%s") could not be found in this application.';
  SDeserializationReadError = '"%s" could not be read properly. Either the data is corrupt or storage end reached!';
  SExpectedReferencedType = 'The complex type being deserialized was stored without reference. The current "%s" entity expects a referenced type.';
  SUnexpectedReferencedType = 'The complex type being deserialized was stored as reference. The current "%s" entity expects a static type.';
  SBinaryValueSizeMismatch = 'The expected size of "%s" (type "%s") entity differs from the size reported by the serializer!';
  SMissingCompositeType = 'The current context of the serialization engine is corrupted! Expected to have a root type, but it''s nil!';
  SReferencePointNotYetDeserialized = 'The entity referenced by "%s" is not yet deserialized!';
  SRefRegisteredOrIsNil = 'Reference "%s" is already registered in the serializer or is a nil value!';
  SUnexpectedDeserializationEntity = 'Deserializing "%s" failed. Serializer reported that the value is missing or is not maching the read entity!';
  SInvalidDeserializationValue = 'Failed to deserialize "%s". The types are different!';
  SInvalidArray = 'Failed to process array %s. The number of declared elements differs from the actual number of elements!';
  SMarkedUnserializable = 'Class or record identified by "%s" cannot be serialized because its type "%s" was annotated with the [NonSerialized] attribute!';
  SInvalidSerializationIdentifier = '"%s" does not represent a valid identifier in the current serializer or was already used!';
  SBadSerializationContext = 'Serialization engine left in broken state at "%s".';
  SWrongOrMissingRTTI = 'Value "%s" of type "%s" cannot be serialized because it has missing or incomplete RTTI!';
  SUnserializable = 'The entity %s of type %s does not define any serialization/deserialization method!';
  SValueSerializationFailed = 'Serialization of a value of type %s failed!';
  SDefaultParameterlessCtorNotAllowed = 'Default parameterless constructor not allowed!';
  SCannotSelfReference = 'The object cannot self-reference!';
  STypeIncompatibleWithVariantArray = 'Cannot combine type %s with a variant array!';
  SNoSuchField = 'Field "%s" not found in type "%s"; or type "%s" is not a record or class.';
  SNilArgument = 'Argument "%s" is nil. Expected a normal non-disposed object!';
  SNotSameTypeArgument = 'Argument "%s" is of a different type!';
  SNullValueRequested = 'Requested value cannot be retrieved because the value is nil.';
  STheBoxIsEmpty = 'Cannot perform the operation because the box contains no valid value! It was previously unboxed!';
  SConvertProblemArgument = 'Argument "%s" cannot be converted to the desired format!';
  SOutOfRangeArgument = 'Argument "%s" is out of range. An argument that falls into the required range of values is expected!';
  SOutOfSpaceArgument = 'Argument "%s" does not have enough space to hold the result!';
  SParentCollectionChanged = 'Parent collection has changed. Cannot continue the operation!';
  SKeyNotFound = 'The key given by the "%s" argument was not found in the collection!';
  SDuplicateKey = 'The key given by the "%s" argument was already registered in the collection!';
  SEmptyCollection = 'The collection is empty! The operation cannot be performed!';
  SCollectionHasMoreThanOneElements = 'The collection has more than one element!';
  SCollectionHasNoFilteredElements = 'The applied predicate generates a void collection.';
  SElementNotInCollection = 'The element given in the "%s" parameter is not a part of this collection!';
  SElementAlreadyInAnotherCollection = 'The element given in the "%s" parameter is already a part of another collection!';
  SRequestedPositionIsOccupied = 'The requested position in the collection is already occupied by another element!';
  SBrokenFormatArgument = 'Argument "%s" has an invalid format and cannot be used!';
  SCustomTypeNotYetRegistered = 'Custom type support for type "%s" is not registered!';
  SCustomTypeAlreadyRegistered = 'Custom type support for type "%s" is already registered!';
  SExtensionTypeAlreadyRegistered = 'Type "%s" has an extension class already registered!';
  SExtensionTypeNotYetRegistered  = 'Type "%s" has no extension class registered!';
  SNoMathExtensionForType = 'Type "%s" has no associated mathematical extension!';
  SCustomTypeHasNoRTTI = 'Custom type to be registered has no attached RTTI!';
  SRuntimeTypeRestrictionFailed = 'Run-time type restriction failed for "%s" type!';
  STimeSupportFormat = '%d Days, %d Hours, %d Minutes, %d Seconds, %d Milliseconds';
  SDivisionByZero = 'Division by zero!';
  SArithmeticOverflow = 'Arithmetic overflow encountered!';
  SNoDefaultType = 'No default type support could be created for the "%s" generic type!';
  STypeConversionNotSupported = 'Converting to type %s failed!';

{ Internal usage }
resourcestring
  SAddress = '(Reference: 0x%8X)';
  SByteCount = '(%d Bytes)';
  SElementCount = '(%d Elements)';
  S1Tuple = '<%s>';
  S2Tuple = '<%s, %s>';
  S3Tuple = '<%s, %s, %s>';
  S4Tuple = '<%s, %s, %s, %s>';
  S5Tuple = '<%s, %s, %s, %s, %s>';
  S6Tuple = '<%s, %s, %s, %s, %s, %s>';
  S7Tuple = '<%s, %s, %s, %s, %s, %s, %s>';

{ XML serialization }
resourcestring
  SXSDAttr = 'xsd';
  SXSIAttr = 'xsi';
  SReferenceIdAttribute = 'refid';
  SReferenceToAttribute = 'refto';
  SClassAttribute = 'class';
  SElementsAttribute = 'count';
  SXSI = 'http://www.w3.org/2001/XMLSchema-instance';
  SXSD = 'http://www.w3.org/2001/XMLSchema';
  SSerializerNamespacePrefix = 'DeHL';
  SSerializerNamespace = 'http://alex.ciobanu.org/DeHL.Serialization.XML';

{ Ini serialization }
resourcestring
  SSectionPathSeparator = '\';
  SClassIdentifierValueName = '#class#';
  SReferenceIdValueName = '#ref#';
  SArrayLengthValueName = '#length#';

{ All Kind of serialization }
resourcestring
  SScale = 'Scale';
  SSign = 'Sign';
  SPrecision = 'Precision';
  SUnscaledValue = 'Unscaled';
  SMagnitude = 'Magnitude';
  SValue1 = 'Value1';
  SValue2 = 'Value2';
  SValue3 = 'Value3';
  SValue4 = 'Value4';
  SValue5 = 'Value5';
  SValue6 = 'Value6';
  SValue7 = 'Value7';
  SSerKey = 'Key';
  SSerValue = 'Value';
  SSerPair = 'Pair';
  SIsDefined = 'Defined';
  SSerElements = 'Elements';
  SSerAscendingKeys = 'KeySort';
  SSerAscendingValues = 'ValSort';

implementation

end.
