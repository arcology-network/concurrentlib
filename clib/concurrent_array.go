package clib

import (
	"github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
)

type dirtyElem struct {
	address types.Address
	id      string
	index   int
	value   []byte
}

type newArray struct {
	address  types.Address
	id       string
	elemType int
	size     int
}

// ConcurrentArray provides a system level shared array which could be
// operated on concurrently in multiple execution units.
type ConcurrentArray struct {
	euID         uint16
	snapshot     Snapshot
	readSet      map[types.Address][]types.ArrayRead
	writeSet     map[types.Address][]types.ArrayWrite
	dirties      []dirtyElem
	newlyCreated []newArray
}

// NewConcurrentArray creates a ConcurrentArray instance with the euID.
// The instance should only be used by the execution unit who owns the euID.
func NewConcurrentArray(euID uint16, snapshot Snapshot) *ConcurrentArray {
	return &ConcurrentArray{
		euID:         euID,
		snapshot:     snapshot,
		readSet:      make(map[types.Address][]types.ArrayRead),
		writeSet:     make(map[types.Address][]types.ArrayWrite),
		dirties:      make([]dirtyElem, 0, 100),
		newlyCreated: make([]newArray, 0, 8),
	}
}

func (ca *ConcurrentArray) SetSnapShot(snapshot Snapshot) {
	ca.snapshot = snapshot
}

func (ca *ConcurrentArray) getElemFromDirtiesV2(sc types.Address, id string, index int) ([]byte, bool) {
	for _, dirty := range ca.dirties {
		if sc == dirty.address && id == dirty.id && index == dirty.index {
			return dirty.value, true
		}
	}
	return nil, false
}

func (ca *ConcurrentArray) setElemToDirtiesV2(sc types.Address, id string, index int, value []byte) {
	ca.dirties = append(ca.dirties, dirtyElem{
		address: sc,
		id:      id,
		index:   index,
		value:   value,
	})
}

// Create a new shared array and record the action as write access, returns false if it already exists.
func (ca *ConcurrentArray) Create(sc types.Address, id string, elemType int, size int) bool {
	if ca.snapshot.IsArrayExist(sc, id) {
		return false
	}

	for _, nc := range ca.newlyCreated {
		if nc.address == sc && nc.id == id {
			return false
		}
	}

	ca.newlyCreated = append(ca.newlyCreated, newArray{sc, id, elemType, size})
	// FIXME!
	// Version != 0 means this is an array creation.
	aw := types.ArrayWrite{
		ArrayAccess: types.ArrayAccess{
			ID:    id,
			Index: elemType,
		},
		Version: types.Version(size),
	}
	ca.writeSet[sc] = append(ca.writeSet[sc], aw)
	return true
}

func (ca *ConcurrentArray) GetSize(sc types.Address, id string) int {
	return ca.getArraySize(sc, id)
}

// GetElem gets specific element from StorageSnapshot and record the access.
// But if it's available in dirties, no record need to be added.
func (ca *ConcurrentArray) GetElem(sc types.Address, id string, index int, elemType int) ([]byte, bool) {
	if ca.getArrayType(sc, id) != elemType {
		return nil, false
	}

	value, ok := ca.getElemFromDirtiesV2(sc, id, index)
	if ok {
		return value, true
	}

	for _, entry := range ca.newlyCreated {
		if entry.address == sc && entry.id == id {
			// Use default value.
			switch entry.elemType {
			case DataTypeUint256:
				return common.Hash{}.Bytes(), true
			case DataTypeAddress:
				return common.Address{}.Bytes(), true
			default:
				return nil, true
			}
		}
	}

	value, ok = ca.snapshot.GetArrayElem(sc, id, index)
	if !ok {
		return nil, false
	}

	ar := types.ArrayRead{
		ArrayAccess: types.ArrayAccess{
			ID:    id,
			Index: index,
		},
		// Version: 0,
	}
	ca.readSet[sc] = append(ca.readSet[sc], ar)
	return value, true
}

// SetElem records the write access and add it to dirties in case it's not an append.
func (ca *ConcurrentArray) SetElem(sc types.Address, id string, index int, value []byte, elemType int) bool {
	if ca.getArrayType(sc, id) != elemType {
		return false
	}

	if index < 0 || ca.getArraySize(sc, id) <= index {
		return false
	}

	aw := types.ArrayWrite{
		ArrayAccess: types.ArrayAccess{
			ID:    id,
			Index: index,
		},
		Value:   value,
		Version: 0,
	}
	ca.writeSet[sc] = append(ca.writeSet[sc], aw)
	ca.setElemToDirtiesV2(sc, id, index, value)
	return true
}

// Collect read set and write set once per transaction, reset all the states.
func (ca *ConcurrentArray) Collect() (map[types.Address][]types.ArrayRead, map[types.Address][]types.ArrayWrite) {
	rs, ws := ca.readSet, ca.writeSet
	ca.readSet = make(map[types.Address][]types.ArrayRead)
	ca.writeSet = make(map[types.Address][]types.ArrayWrite)
	ca.dirties = ca.dirties[:0]
	ca.newlyCreated = ca.newlyCreated[:0]
	return rs, ws
}

func (ca *ConcurrentArray) getArrayType(sc types.Address, id string) int {
	if t := ca.snapshot.GetArrayType(sc, id); t != DataTypeInvalid {
		return t
	}
	for _, entry := range ca.newlyCreated {
		if sc == entry.address && id == entry.id {
			return entry.elemType
		}
	}
	return DataTypeInvalid
}

func (ca *ConcurrentArray) getArraySize(sc types.Address, id string) int {
	if size := ca.snapshot.GetArraySize(sc, id); size != -1 {
		return size
	}
	for _, entry := range ca.newlyCreated {
		if sc == entry.address && id == entry.id {
			return entry.size
		}
	}
	return -1
}
