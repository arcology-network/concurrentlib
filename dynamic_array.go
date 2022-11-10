package concurrentlib

import (
	"encoding/binary"
	"encoding/hex"
	"errors"

	cmntyp "github.com/arcology-network/common-lib/types"
	url "github.com/arcology-network/concurrenturl/v2"
	commutative "github.com/arcology-network/concurrenturl/v2/type/commutative"
)

var (
	ErrDynArrayTypeMismatch    = errors.New("dynamic array type error")
	ErrDynArrayIndexOutOfRange = errors.New("dynamic array index error")
	ErrDynArrayBadData         = errors.New("dynamic array internal error")
)

type DynamicArray struct {
	url             *url.ConcurrentUrl
	context         TxContext
	counter         uint32
	sm              *SortedMap
	bufferedKeys    map[string][][]byte
	bufferedNewKeys map[string][][]byte
}

func NewDynamicArray(url *url.ConcurrentUrl, context TxContext) *DynamicArray {
	sm := NewSortedMap(url, context)
	sm.containerType = ContainerTypeQueue
	return &DynamicArray{
		url:             url,
		context:         context,
		sm:              sm,
		bufferedKeys:    make(map[string][][]byte),
		bufferedNewKeys: make(map[string][][]byte),
	}
}

func (array *DynamicArray) Create(account cmntyp.Address, id string, elemType int) bool {
	return array.sm.create(account, id, DataTypeBytes, elemType)
}

func (array *DynamicArray) GetSize(account cmntyp.Address, id string) int {
	return array.sm.GetSize(account, id)
}

func (array *DynamicArray) PushBack(account cmntyp.Address, id string, value []byte, elemType int) bool {
	// Init bufferedKeys before any write operation.
	lastKey, exist := array.getNthKey(account, id, -1)

	key := array.getStoredKey()
	if !array.sm.SetValue(account, id, []byte(key), value, DataTypeBytes, elemType) {
		return false
	}

	// Access the last element of the array to avoid pop back operation.
	if exist {
		array.sm.GetValue(account, id, lastKey, DataTypeBytes, elemType)
	}

	array.pushBackKey(account, id, []byte(key))
	array.counter++
	return true
}

func (array *DynamicArray) PopBack(account cmntyp.Address, id string, elemType int) ([]byte, error) {
	if !array.sm.typeCheckPassed(account, id, DataTypeBytes, elemType) {
		return nil, ErrDynArrayTypeMismatch
	}

	key, ok := array.getNthKey(account, id, -1)
	if !ok {
		return nil, ErrDynArrayIndexOutOfRange
	}

	elem, ok := array.sm.GetValue(account, id, key, DataTypeBytes, elemType)
	if !ok {
		return nil, ErrDynArrayBadData
	}

	if !array.sm.SetValue(account, id, key, nil, DataTypeBytes, elemType) {
		return nil, ErrDynArrayBadData
	}

	array.popBackKey(account, id)
	return elem, nil
}

func (array *DynamicArray) PopFront(account cmntyp.Address, id string, elemType int) ([]byte, error) {
	if !array.sm.typeCheckPassed(account, id, DataTypeBytes, elemType) {
		return nil, ErrDynArrayTypeMismatch
	}

	key, ok := array.getNthKey(account, id, 0)
	if !ok {
		return nil, ErrDynArrayIndexOutOfRange
	}

	elem, ok := array.sm.GetValue(account, id, key, DataTypeBytes, elemType)
	if !ok {
		return nil, ErrDynArrayBadData
	}

	if !array.sm.SetValue(account, id, key, nil, DataTypeBytes, elemType) {
		return nil, ErrDynArrayBadData
	}

	array.popFrontKey(account, id)
	return elem, nil
}

func (array *DynamicArray) Get(account cmntyp.Address, id string, index int, elemType int) ([]byte, error) {
	if !array.sm.typeCheckPassed(account, id, DataTypeBytes, elemType) {
		return nil, ErrDynArrayTypeMismatch
	}

	key, ok := array.getNthKey(account, id, index)
	if !ok {
		return nil, ErrDynArrayIndexOutOfRange
	}

	elem, ok := array.sm.GetValue(account, id, key, DataTypeBytes, elemType)
	if !ok {
		return nil, ErrDynArrayBadData
	}

	// Access the first element of the array to avoid pop front operation.
	if index > 0 {
		key, _ := array.getNthKey(account, id, 0)
		array.sm.GetValue(account, id, key, DataTypeBytes, elemType)
	}

	return elem, nil
}

func (array *DynamicArray) getNthKey(account cmntyp.Address, id string, n int) ([]byte, bool) {
	if array.bufferedKeys[string(account)+id] == nil {
		keys, _ := (*array.url.Store()).CacheRetrive(
			getContainerRootPath(array.url, account, id),
			func(v interface{}) interface{} {
				if v == nil {
					return nil
				}

				keys := make([][]byte, 0, len(v.(*commutative.Meta).PeekKeys())-2)
				for _, key := range v.(*commutative.Meta).PeekKeys() {
					if len(key) > 1 {
						b, _ := hex.DecodeString(key[1:])
						keys = append(keys, b)
					}
				}
				return keys
			},
		)

		if keys == nil {
			return nil, false
		}
		array.bufferedKeys[string(account)+id] = keys.([][]byte)
	}

	if n == -1 {
		n = len(array.bufferedKeys[string(account)+id]) + len(array.bufferedNewKeys[string(account)+id]) - 1
		if n == -1 {
			return nil, false
		}
	}

	if n >= len(array.bufferedKeys[string(account)+id])+len(array.bufferedNewKeys[string(account)+id]) {
		return nil, false
	}

	if n >= len(array.bufferedKeys[string(account)+id]) {
		// Read meta data.
		array.sm.getSize(account, id)
		return array.bufferedNewKeys[string(account)+id][n-len(array.bufferedKeys[string(account)+id])], true
	} else {
		return array.bufferedKeys[string(account)+id][n], true
	}
}

func (array *DynamicArray) pushBackKey(account cmntyp.Address, id string, key []byte) {
	array.bufferedNewKeys[string(account)+id] = append(array.bufferedNewKeys[string(account)+id], key)
}

func (array *DynamicArray) popBackKey(account cmntyp.Address, id string) {
	if len(array.bufferedNewKeys[string(account)+id]) > 0 {
		// Read meta data.
		array.sm.getSize(account, id)
		array.bufferedNewKeys[string(account)+id] =
			array.bufferedNewKeys[string(account)+id][:len(array.bufferedNewKeys[string(account)+id])-1]
	} else {
		array.bufferedKeys[string(account)+id] =
			array.bufferedKeys[string(account)+id][:len(array.bufferedKeys[string(account)+id])-1]
	}
}

func (array *DynamicArray) popFrontKey(account cmntyp.Address, id string) {
	if len(array.bufferedKeys[string(account)+id]) > 0 {
		array.bufferedKeys[string(account)+id] = array.bufferedKeys[string(account)+id][1:]
	} else if len(array.bufferedNewKeys[string(account)+id]) > 0 {
		// Read meta data.
		array.sm.getSize(account, id)
		array.bufferedNewKeys[string(account)+id] = array.bufferedNewKeys[string(account)+id][1:]
	}
}

func (array *DynamicArray) getStoredKey() string {
	b := make([]byte, 8, 16)
	binary.BigEndian.PutUint64(b, array.context.GetHeight().Uint64())

	bi := make([]byte, 4)
	binary.BigEndian.PutUint32(bi, array.context.GetIndex())
	b = append(b, bi...)

	bc := make([]byte, 4)
	binary.BigEndian.PutUint32(bc, array.counter)
	b = append(b, bc...)

	return string(b)
}
