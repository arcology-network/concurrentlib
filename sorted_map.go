package concurrentlib

import (
	"encoding/hex"

	"github.com/arcology-network/common-lib/types"
	"github.com/arcology-network/concurrenturl/v2"
	commutative "github.com/arcology-network/concurrenturl/v2/type/commutative"
	noncommutative "github.com/arcology-network/concurrenturl/v2/type/noncommutative"
)

type SortedMap struct {
	url           *concurrenturl.ConcurrentUrl
	context       TxContext
	containerType int
}

func NewSortedMap(url *concurrenturl.ConcurrentUrl, context TxContext) *SortedMap {
	return &SortedMap{
		url:           url,
		context:       context,
		containerType: ContainerTypeSM,
	}
}

func (sm *SortedMap) Create(account types.Address, id string, keyType int, valueType int) bool {
	return sm.create(account, id, keyType, valueType)
}

func (sm *SortedMap) GetSize(account types.Address, id string) int {
	if !sm.typeCheckPassed(account, id, DataTypeInvalid, DataTypeInvalid) {
		return ContainerSizeInvalid
	}
	return sm.getSize(account, id)
}

func (sm *SortedMap) GetValue(account types.Address, id string, key []byte, keyType int, valueType int) ([]byte, bool) {
	if !sm.typeCheckPassed(account, id, keyType, valueType) {
		return nil, false
	}

	if value, err := sm.url.Read(sm.context.GetIndex(), getValuePath(sm.url, account, id, sm.getStoredKey(key))); err != nil {
		return nil, false
	} else if value == nil {
		return getDefaultValue(valueType)
	} else {
		return value.(*noncommutative.Bytes).Data(), true
	}
}

func (sm *SortedMap) SetValue(account types.Address, id string, key []byte, value []byte, keyType int, valueType int) bool {
	if !sm.typeCheckPassed(account, id, keyType, valueType) {
		return false
	}

	var storedValue interface{}
	if value != nil {
		storedValue = noncommutative.NewBytes(value)
	}
	if err := sm.url.Write(sm.context.GetIndex(), getValuePath(sm.url, account, id, sm.getStoredKey(key)), storedValue); err != nil {
		return false
	}
	return true
}

func (sm *SortedMap) GetKeys(account types.Address, id string, keyType int) ([][]byte, bool) {
	if !sm.typeCheckPassed(account, id, keyType, DataTypeInvalid) {
		return nil, false
	}

	return sm.getKeys(account, id)
}

func (sm *SortedMap) DeleteKey(account types.Address, id string, key []byte, keyType int) bool {
	return sm.SetValue(account, id, key, nil, keyType, DataTypeInvalid)
}

func (sm *SortedMap) create(account types.Address, id string, keyType int, valueType int) bool {
	if !makeStorageRootPath(sm.url, account, sm.context.GetIndex()) {
		return false
	}

	if !makeContainerRootPath(sm.url, account, id, sm.context.GetIndex()) {
		return false
	}

	// Write meta data.
	if err := sm.url.Write(sm.context.GetIndex(), getContainerTypePath(sm.url, account, id), noncommutative.NewInt64(int64(sm.containerType))); err != nil {
		return false
	}
	if err := sm.url.Write(sm.context.GetIndex(), getKeyTypePath(sm.url, account, id), noncommutative.NewInt64(int64(keyType))); err != nil {
		return false
	}
	if err := sm.url.Write(sm.context.GetIndex(), getValueTypePath(sm.url, account, id), noncommutative.NewInt64(int64(valueType))); err != nil {
		return false
	}
	return true
}

func (sm *SortedMap) getSize(account types.Address, id string) int {
	if value, err := sm.url.Read(sm.context.GetIndex(), getContainerRootPath(sm.url, account, id)); err != nil || value == nil {
		return ContainerSizeInvalid
	} else {
		return len(value.(*commutative.Meta).PeekKeys()) - 2
	}
}

func (sm *SortedMap) getKeyType(account types.Address, id string) int {
	if value, err := sm.url.Read(sm.context.GetIndex(), getKeyTypePath(sm.url, account, id)); err != nil || value == nil {
		return DataTypeInvalid
	} else {
		return int(*value.(*noncommutative.Int64))
	}
}

func (sm *SortedMap) getValueType(account types.Address, id string) int {
	if value, err := sm.url.Read(sm.context.GetIndex(), getValueTypePath(sm.url, account, id)); err != nil || value == nil {
		return DataTypeInvalid
	} else {
		return int(*value.(*noncommutative.Int64))
	}
}

func (sm *SortedMap) typeCheckPassed(account types.Address, id string, keyType int, valueType int) bool {
	if getContainerType(sm.url, account, id, sm.context.GetIndex()) != sm.containerType {
		return false
	}
	if keyType != DataTypeInvalid && sm.getKeyType(account, id) != keyType {
		return false
	}
	if valueType != DataTypeInvalid && sm.getValueType(account, id) != valueType {
		return false
	}
	return true
}

func (sm *SortedMap) getStoredKey(key []byte) string {
	return "$" + hex.EncodeToString(key)
}

func (sm *SortedMap) getKeys(account types.Address, id string) ([][]byte, bool) {
	if value, err := sm.url.Read(sm.context.GetIndex(), getContainerRootPath(sm.url, account, id)); err != nil || value == nil {
		return nil, false
	} else {
		keys := make([][]byte, 0, len(value.(*commutative.Meta).PeekKeys())-2)
		for _, key := range value.(*commutative.Meta).PeekKeys() {
			if len(key) > 1 {
				b, _ := hex.DecodeString(key[1:])
				keys = append(keys, b)
			}
		}
		return keys, true
	}
}

func (sm *SortedMap) peekKeys(account types.Address, id string) ([][]byte, bool) {
	if value, err := sm.url.TryRead(sm.context.GetIndex(), getContainerRootPath(sm.url, account, id)); err != nil || value == nil {
		return nil, false
	} else {
		keys := make([][]byte, 0, len(value.(*commutative.Meta).PeekKeys())-2)
		for _, key := range value.(*commutative.Meta).PeekKeys() {
			if len(key) > 1 {
				b, _ := hex.DecodeString(key[1:])
				keys = append(keys, b)
			}
		}
		return keys, true
	}
}

func (sm *SortedMap) getIterator(account types.Address, id string) (*commutative.Meta, bool) {
	if value, err := sm.url.Read(sm.context.GetIndex(), getContainerRootPath(sm.url, account, id)); err != nil || value == nil {
		return nil, false
	} else {
		value.(*commutative.Meta).LoadKeys()
		value.(*commutative.Meta).ResetIterator()
		return value.(*commutative.Meta), true
	}
}

func (sm *SortedMap) getNextKey(iterator *commutative.Meta) ([]byte, bool) {
	for {
		key := iterator.Next()
		if len(key) > 1 {
			b, _ := hex.DecodeString(key[1:])
			return b, true
		} else if len(key) == 0 {
			return nil, false
		}
	}
}
