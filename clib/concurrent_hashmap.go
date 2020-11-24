package clib

import (
	"github.com/HPISTechnologies/common-lib/types"
)

const (
	DataTypeInvalid = iota
	DataTypeAddress
	DataTypeUint256
	DataTypeBytes
)

type dirtyValue struct {
	address types.Address
	id      string
	key     string
	value   []byte
}

type newMap struct {
	address   types.Address
	id        string
	keyType   int
	valueType int
}

type ConcurrentHashMap struct {
	euID         uint16
	snapshot     Snapshot
	readSet      map[types.Address][]types.HashMapRead
	writeSet     map[types.Address][]types.HashMapWrite
	dirties      []dirtyValue
	newlyCreated []newMap
}

func (chm *ConcurrentHashMap) getValueFromDirties(sc types.Address, id string, key string) ([]byte, bool) {
	// We need to scan the dirties in reverse order to get the latest value.
	for i := len(chm.dirties) - 1; i >= 0; i-- {
		if chm.dirties[i].address == sc && chm.dirties[i].id == id && chm.dirties[i].key == key {
			return chm.dirties[i].value, true
		}
	}
	return nil, false
}

func (chm *ConcurrentHashMap) setValueToDirties(sc types.Address, id string, key string, value []byte) {
	chm.dirties = append(chm.dirties, dirtyValue{
		address: sc,
		id:      id,
		key:     key,
		value:   value,
	})
}

func NewConcurrentHashMap(euID uint16, snapshot Snapshot) *ConcurrentHashMap {
	return &ConcurrentHashMap{
		euID:         euID,
		snapshot:     snapshot,
		readSet:      make(map[types.Address][]types.HashMapRead),
		writeSet:     make(map[types.Address][]types.HashMapWrite),
		dirties:      make([]dirtyValue, 0, 100),
		newlyCreated: make([]newMap, 0, 8),
	}
}

func (chm *ConcurrentHashMap) SetSnapShot(snapshot Snapshot) {
	chm.snapshot = snapshot
}

func (chm *ConcurrentHashMap) Create(sc types.Address, id string, keyType, valueType int) bool {
	for _, entry := range chm.newlyCreated {
		if sc == entry.address && id == entry.id {
			return false
		}
	}
	if ok := chm.snapshot.CreateHashMap(sc, id, keyType, valueType); !ok {
		return false
	}

	chm.newlyCreated = append(chm.newlyCreated, newMap{sc, id, keyType, valueType})
	hmw := types.HashMapWrite{
		HashMapAccess: types.HashMapAccess{
			ID: id,
			// FIXME!
			Key: string([]byte{byte(keyType), byte(valueType)}),
		},
		Version: types.Version(uint64(chm.euID) << 48),
	}
	chm.writeSet[sc] = append(chm.writeSet[sc], hmw)
	return true
}

func (chm *ConcurrentHashMap) GetValue(sc types.Address, id string, key []byte, keyType, valueType int) ([]byte, bool) {
	if kt, vt := chm.getHashMapType(sc, id); kt != keyType || vt != valueType {
		return nil, false
	}

	value, ok := chm.getValueFromDirties(sc, id, string(key))
	if ok {
		return value, true
	}

	value, _ = chm.snapshot.GetHashMapValue(sc, id, string(key), keyType, valueType)
	// value, version := chm.snapshot.GetHashMapValue(sc, id, string(key), keyType, valueType)
	// Access a non-exist key is not an error.
	// if version == types.InvalidVersion {
	// 	return nil, false
	// }

	hmr := types.HashMapRead{
		HashMapAccess: types.HashMapAccess{
			ID:  id,
			Key: string(key),
		},
		// Version: version,
	}
	chm.readSet[sc] = append(chm.readSet[sc], hmr)
	return value, true
}

func (chm *ConcurrentHashMap) SetValue(sc types.Address, id string, key, value []byte, keyType, valueType int) bool {
	if kt, vt := chm.getHashMapType(sc, id); kt != keyType || vt != valueType {
		return false
	}

	_, version := chm.snapshot.GetHashMapValue(sc, id, string(key), keyType, valueType)
	hmw := types.HashMapWrite{
		HashMapAccess: types.HashMapAccess{
			ID:  id,
			Key: string(key),
		},
		Value:   value,
		Version: types.Version(uint64(chm.euID)<<48 + uint64(version&types.VersionMask) + 1),
	}
	chm.writeSet[sc] = append(chm.writeSet[sc], hmw)

	chm.setValueToDirties(sc, id, string(key), value)
	return true
}

// TODO: the keyType is useless.
func (chm *ConcurrentHashMap) DeleteKey(sc types.Address, id string, key []byte, keyType int) bool {
	// If the key isn't exist, there's nothing to do for us.
	if !chm.snapshot.IsHashMapKeyExist(sc, id, string(key)) {
		if _, ok := chm.getValueFromDirties(sc, id, string(key)); !ok {
			return true
		}
	}

	hmw := types.HashMapWrite{
		HashMapAccess: types.HashMapAccess{
			ID:  id,
			Key: string(key),
		},
		Value:   nil,
		Version: 1,
	}
	chm.writeSet[sc] = append(chm.writeSet[sc], hmw)

	chm.setValueToDirties(sc, id, string(key), nil)
	return true
}

func (chm *ConcurrentHashMap) Collect() (map[types.Address][]types.HashMapRead, map[types.Address][]types.HashMapWrite) {
	rs, ws := chm.readSet, chm.writeSet
	chm.readSet = make(map[types.Address][]types.HashMapRead)
	chm.writeSet = make(map[types.Address][]types.HashMapWrite)
	chm.dirties = chm.dirties[:0]
	chm.newlyCreated = chm.newlyCreated[:0]
	return rs, ws
}

func (chm *ConcurrentHashMap) getHashMapType(sc types.Address, id string) (int, int) {
	if kt, vt := chm.snapshot.GetHashMapType(sc, id); kt != DataTypeInvalid && vt != DataTypeInvalid {
		return kt, vt
	}
	for _, entry := range chm.newlyCreated {
		if sc == entry.address && id == entry.id {
			return entry.keyType, entry.valueType
		}
	}
	return DataTypeInvalid, DataTypeInvalid
}
