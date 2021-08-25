package concurrentlib

import (
	"github.com/arcology/common-lib/types"
	"github.com/arcology/concurrenturl/v2"
	noncommutative "github.com/arcology/concurrenturl/v2/type/noncommutative"
)

type FixedLengthArray struct {
	url     *concurrenturl.ConcurrentUrl
	context TxContext
}

func NewFixedLengthArray(url *concurrenturl.ConcurrentUrl, context TxContext) *FixedLengthArray {
	return &FixedLengthArray{
		url:     url,
		context: context,
	}
}

func (array *FixedLengthArray) Create(account types.Address, id string, elemType int, size int) bool {
	if !makeStorageRootPath(array.url, account, array.context.GetIndex()) {
		return false
	}

	if !makeContainerRootPath(array.url, account, id, array.context.GetIndex()) {
		return false
	}

	// Write meta data.
	if err := array.url.Write(array.context.GetIndex(), getContainerTypePath(array.url, account, id), noncommutative.NewInt64(int64(ContainerTypeFLA))); err != nil {
		return false
	}
	if err := array.url.Write(array.context.GetIndex(), getSizePath(array.url, account, id), noncommutative.NewInt64(int64(size))); err != nil {
		return false
	}
	if err := array.url.Write(array.context.GetIndex(), getValueTypePath(array.url, account, id), noncommutative.NewInt64(int64(elemType))); err != nil {
		return false
	}
	return true
}

func (array *FixedLengthArray) GetSize(account types.Address, id string) int {
	if !array.typeCheckPassed(account, id, DataTypeInvalid) {
		return ContainerSizeInvalid
	}
	return array.getSize(account, id)
}

func (array *FixedLengthArray) GetElem(account types.Address, id string, index int, elemType int) ([]byte, bool) {
	if !array.typeCheckPassed(account, id, elemType) || !(index < array.getSize(account, id)) {
		return nil, false
	}

	if value, err := array.url.Read(array.context.GetIndex(), getValuePath(array.url, account, id, index)); err != nil {
		return nil, false
	} else if value == nil {
		return getDefaultValue(elemType)
	} else {
		return value.(*noncommutative.Bytes).Data(), true
	}
}

func (array *FixedLengthArray) SetElem(account types.Address, id string, index int, value []byte, elemType int) bool {
	if !array.typeCheckPassed(account, id, elemType) || !(index < array.getSize(account, id)) {
		return false
	}

	if err := array.url.Write(array.context.GetIndex(), getValuePath(array.url, account, id, index), noncommutative.NewBytes(value)); err != nil {
		return false
	}
	return true
}

func (array *FixedLengthArray) getSize(account types.Address, id string) int {
	if value, err := array.url.Read(array.context.GetIndex(), getSizePath(array.url, account, id)); err != nil || value == nil {
		return ContainerSizeInvalid
	} else {
		return int(*value.(*noncommutative.Int64))
	}
}

func (array *FixedLengthArray) getElementType(account types.Address, id string) int {
	if value, err := array.url.Read(array.context.GetIndex(), getValueTypePath(array.url, account, id)); err != nil || value == nil {
		return DataTypeInvalid
	} else {
		return int(*value.(*noncommutative.Int64))
	}
}

func (array *FixedLengthArray) typeCheckPassed(account types.Address, id string, elemType int) bool {
	if getContainerType(array.url, account, id, array.context.GetIndex()) != ContainerTypeFLA {
		return false
	}
	if elemType != DataTypeInvalid && array.getElementType(account, id) != elemType {
		return false
	}
	return true
}
