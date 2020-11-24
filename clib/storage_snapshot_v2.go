package clib

import (
	"fmt"

	"github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
)

type versionedValue struct {
	version types.Version
	value   interface{}
}

type array struct {
	elemType int
	elems    [][]byte
}

type genericHashMap struct {
	keyType   int
	valueType int
	hashMap   map[string]versionedValue
}

type genericQueue struct {
	elemType int
	elems    [][]byte
}

type contractStorage struct {
	arrays   map[string]*array
	hashmaps map[string]*genericHashMap
	queues   map[string]*genericQueue
	defers   map[string]string
}

type storageSnapshotV2 struct {
	db map[types.Address]*contractStorage
}

// NewSnapshot returns an implementation of Snapshot interface.
func NewSnapshot() Snapshot {
	return &storageSnapshotV2{
		db: make(map[types.Address]*contractStorage),
	}
}

func (snapshot *storageSnapshotV2) IsArrayExist(sc types.Address, id string) bool {
	storage, ok := snapshot.db[sc]
	if !ok || storage.arrays == nil {
		return false
	}
	_, ok = storage.arrays[id]
	return ok
}

func (snapshot *storageSnapshotV2) GetArraySize(sc types.Address, id string) int {
	if !snapshot.IsArrayExist(sc, id) {
		return -1
	}
	return len(snapshot.db[sc].arrays[id].elems)
}

func (snapshot *storageSnapshotV2) GetArrayType(sc types.Address, id string) int {
	if !snapshot.IsArrayExist(sc, id) {
		return DataTypeInvalid
	}
	return snapshot.db[sc].arrays[id].elemType
}

func (snapshot *storageSnapshotV2) GetArrayElem(sc types.Address, id string, index int) ([]byte, bool) {
	if !snapshot.IsArrayExist(sc, id) {
		return nil, false
	}
	if len(snapshot.db[sc].arrays[id].elems)-1 < index {
		return nil, false
	}

	value := snapshot.db[sc].arrays[id].elems[index]
	if len(value) != 0 {
		return value, true
	}
	// Use default value.
	switch snapshot.db[sc].arrays[id].elemType {
	case DataTypeUint256:
		return common.Hash{}.Bytes(), true
	case DataTypeAddress:
		return common.Address{}.Bytes(), true
	default:
		return nil, true
	}
}

func (snapshot *storageSnapshotV2) CreateHashMap(sc types.Address, id string, keyType, valueType int) bool {
	// FIXME: handle duplicate creation.
	kt, vt := snapshot.GetHashMapType(sc, id)
	return kt == DataTypeInvalid && vt == DataTypeInvalid
}

func (snapshot *storageSnapshotV2) GetHashMapValue(sc types.Address, id string, key string, keyType, valueType int) ([]byte, types.Version) {
	storage, ok := snapshot.db[sc]
	if !ok || storage.hashmaps == nil {
		return nil, types.InvalidVersion
	}
	hashmap, ok := storage.hashmaps[id]
	if !ok || hashmap.keyType != keyType || hashmap.valueType != valueType {
		return nil, types.InvalidVersion
	}
	v, ok := hashmap.hashMap[key]
	if !ok || (v.version == 1 && v.value.([]byte) == nil) {
		// For fix size data types, return all-zero.
		// FIXME: handle variable length data types.
		switch valueType {
		case DataTypeUint256:
			return common.Hash{}.Bytes(), 1
		case DataTypeAddress:
			return common.Address{}.Bytes(), 1
		default:
			return nil, types.InvalidVersion
		}
	}
	return v.value.([]byte), v.version
}

func (snapshot *storageSnapshotV2) GetHashMapType(sc types.Address, id string) (int, int) {
	storage, ok := snapshot.db[sc]
	if !ok || storage.hashmaps == nil {
		return DataTypeInvalid, DataTypeInvalid
	}
	hashmap, ok := storage.hashmaps[id]
	if !ok {
		return DataTypeInvalid, DataTypeInvalid
	}
	return hashmap.keyType, hashmap.valueType
}

func (snapshot *storageSnapshotV2) IsHashMapKeyExist(sc types.Address, id string, key string) bool {
	storage, ok := snapshot.db[sc]
	if !ok || storage.hashmaps == nil {
		return false
	}
	hashmap, ok := storage.hashmaps[id]
	if !ok {
		return false
	}
	_, ok = hashmap.hashMap[key]
	return ok
}

func (snapshot *storageSnapshotV2) IsDeferCallExist(sc types.Address, id string) bool {
	storage, ok := snapshot.db[sc]
	if !ok || storage.defers == nil {
		return false
	}
	_, ok = storage.defers[id]
	return ok
}

func (snapshot *storageSnapshotV2) GetDeferCallSignature(sc types.Address, id string) string {
	storage, ok := snapshot.db[sc]
	if !ok || storage.defers == nil {
		return ""
	}
	sig, ok := storage.defers[id]
	if !ok {
		return ""
	}
	return sig
}

func (snapshot *storageSnapshotV2) IsQueueExist(sc types.Address, id string) bool {
	storage, ok := snapshot.db[sc]
	if !ok || storage.queues == nil {
		return false
	}
	_, ok = storage.queues[id]
	return ok
}

func (snapshot *storageSnapshotV2) GetQueueSize(sc types.Address, id string) int {
	if !snapshot.IsQueueExist(sc, id) {
		return -1
	}
	return len(snapshot.db[sc].queues[id].elems)
}

func (snapshot *storageSnapshotV2) Show() {
	fmt.Printf("github.com/HPISTechnologies/concurrentlib/clib/storage_snapshot_v2.go (storageSnapshotV2) show ---> \n")
	for addr, cs := range snapshot.db {
		fmt.Printf("++++++++++++++  addr=%v,\n", addr)
		for k, v := range cs.arrays {
			fmt.Printf("++++++++++++++  arrays k=%v,v=%v\n", k, v)
		}

		for k, v := range cs.defers {
			fmt.Printf("++++++++++++++  defers k=%v,v=%v\n", k, v)
		}

		for k, v := range cs.hashmaps {
			fmt.Printf("++++++++++++++  hashmaps k=%v,v=%v\n", k, v)
		}
		for k, v := range cs.queues {
			fmt.Printf("++++++++++++++  queues k=%v,v=%v\n", k, v)
		}
	}
}

func (snapshot *storageSnapshotV2) GetQueueType(sc types.Address, id string) int {
	if !snapshot.IsQueueExist(sc, id) {
		return DataTypeInvalid
	}
	return snapshot.db[sc].queues[id].elemType
}

func (snapshot *storageSnapshotV2) GetQueueElem(sc types.Address, id string, index int) ([]byte, bool) {
	if !snapshot.IsQueueExist(sc, id) {
		return nil, false
	}
	if len(snapshot.db[sc].queues[id].elems)-1 < index {
		return nil, false
	}
	return snapshot.db[sc].queues[id].elems[index], true
}

func (snapshot *storageSnapshotV2) GetQueueElemAll(sc types.Address, id string) ([][]byte, bool) {
	if !snapshot.IsQueueExist(sc, id) {
		return nil, false
	}
	return snapshot.db[sc].queues[id].elems, true
}

func (snapshot *storageSnapshotV2) Empty() {

}

func (snapshot *storageSnapshotV2) Commit(writes map[types.Address]*types.WriteSet) bool {
	for addr, ws := range writes {
		storage, ok := snapshot.db[addr]
		if !ok {
			storage = &contractStorage{
				arrays:   make(map[string]*array),
				hashmaps: make(map[string]*genericHashMap),
				queues:   make(map[string]*genericQueue),
				defers:   make(map[string]string),
			}
			snapshot.db[addr] = storage
		}

		for _, aw := range ws.ArrayWrites {
			// Create new array.
			if aw.Version != 0 {
				if _, ok := storage.arrays[aw.ID]; ok {
					panic(fmt.Sprintf("Cannot create array(%v) on contract(%x) twice.", aw.ID, addr))
				}
				storage.arrays[aw.ID] = &array{
					elemType: aw.Index,
					elems:    make([][]byte, int(aw.Version)),
				}
				continue
			}
			storage.arrays[aw.ID].elems[aw.Index] = aw.Value
		}

		for _, mw := range ws.HashMapWrites {
			// Create new hashmap.
			if (mw.Version & types.VersionMask) == 0 {
				if _, ok := storage.hashmaps[mw.ID]; ok {
					panic(fmt.Sprintf("Cannot create hashmap(%v) on contract(%v) twice.", mw.ID, addr))
				}
				storage.hashmaps[mw.ID] = &genericHashMap{
					keyType:   int([]byte(mw.Key)[0]),
					valueType: int([]byte(mw.Key)[1]),
					hashMap:   make(map[string]versionedValue),
				}
				continue
			}
			storage.hashmaps[mw.ID].hashMap[mw.Key] = versionedValue{
				version: mw.Version,
				value:   mw.Value,
			}
		}

		for _, qw := range ws.QueueWrites {
			if qw.Op == types.QueueOpCreate { // Create new queue.
				if _, ok := storage.queues[qw.ID]; ok {
					panic(fmt.Sprintf("Cannot create queue(%v) on contract(%v) twice.", qw.ID, addr))
				}
				storage.queues[qw.ID] = &genericQueue{
					elemType: int(qw.Value[0]),
				}
			} else if qw.Op == types.QueueOpPush && qw.Pos == types.QueuePosTail { // Push back.
				storage.queues[qw.ID].elems = append(storage.queues[qw.ID].elems, qw.Value)
			} else if qw.Op == types.QueueOpPop && qw.Pos == types.QueuePosHead { // Pop front.
				if len(storage.queues[qw.ID].elems) < 1 {
					//panic(fmt.Sprintf("Pop on empty queue(%v)", qw.ID))
				} else {
					storage.queues[qw.ID].elems = storage.queues[qw.ID].elems[1:]
				}

			} else {
				panic(fmt.Sprintf("Unsupported operation(%v,%v) on queue(%v)", qw.Op, qw.Pos, qw.ID))
			}
		}

		for _, dw := range ws.DeferCallWrites {
			// Create new defer call.
			if _, ok := storage.defers[dw.DeferID]; ok {
				panic(fmt.Sprintf("Cannot create defer call(%v) on contract(%v) twice.", dw.DeferID, addr))
			}
			storage.defers[dw.DeferID] = dw.Signature
		}
	}
	return true
}

func (snapshot *storageSnapshotV2) CreateTransientSnapshot() Snapshot {
	return &transientSnapshotV2{
		storageSnapshotV2: NewSnapshot().(*storageSnapshotV2),
		committed:         snapshot,
		isApcCache:        false,
	}
}
func (snapshot *storageSnapshotV2) CreateTransientSnapshotForApc() Snapshot {
	return &transientSnapshotV2{
		storageSnapshotV2: NewSnapshot().(*storageSnapshotV2),
		committed:         snapshot,
		isApcCache:        true,
	}
}

type transientSnapshotV2 struct {
	*storageSnapshotV2
	committed  *storageSnapshotV2
	isApcCache bool
}

func (snapshot *transientSnapshotV2) IsArrayExist(sc types.Address, id string) bool {
	if snapshot.storageSnapshotV2.IsArrayExist(sc, id) {
		return true
	}
	return snapshot.committed.IsArrayExist(sc, id)
}

func (snapshot *transientSnapshotV2) GetArraySize(sc types.Address, id string) int {
	if size := snapshot.storageSnapshotV2.GetArraySize(sc, id); size != -1 {
		return size
	}
	return snapshot.committed.GetArraySize(sc, id)
}

func (snapshot *transientSnapshotV2) GetArrayType(sc types.Address, id string) int {
	if t := snapshot.storageSnapshotV2.GetArrayType(sc, id); t != DataTypeInvalid {
		return t
	}
	return snapshot.committed.GetArrayType(sc, id)
}

func (snapshot *transientSnapshotV2) GetArrayElem(sc types.Address, id string, index int) ([]byte, bool) {
	if value, ok := snapshot.storageSnapshotV2.GetArrayElem(sc, id, index); ok && len(value) != 0 {
		return value, ok
	}
	if snapshot.isApcCache && snapshot.committed == nil {
		return nil, false
	} else {
		return snapshot.committed.GetQueueElem(sc, id, index)
	}

}

func (snapshot *transientSnapshotV2) CreateHashMap(sc types.Address, id string, keyType, valueType int) bool {
	if !snapshot.storageSnapshotV2.CreateHashMap(sc, id, keyType, valueType) {
		return false
	}
	return snapshot.committed.CreateHashMap(sc, id, keyType, valueType)
}

func (snapshot *transientSnapshotV2) GetHashMapValue(sc types.Address, id string, key string, keyType, valueType int) ([]byte, types.Version) {
	if value, version := snapshot.storageSnapshotV2.GetHashMapValue(sc, id, key, keyType, valueType); version != types.InvalidVersion {
		return value, version
	}
	if snapshot.isApcCache && snapshot.committed == nil {
		return nil, types.Version(0)
	} else {
		return snapshot.committed.GetHashMapValue(sc, id, key, keyType, valueType)
	}
}

func (snapshot *transientSnapshotV2) GetHashMapType(sc types.Address, id string) (int, int) {
	if kt, vt := snapshot.storageSnapshotV2.GetHashMapType(sc, id); kt != DataTypeInvalid && vt != DataTypeInvalid {
		return kt, vt
	}
	if snapshot.isApcCache && snapshot.committed == nil {
		return -1, -1
	} else {
		return snapshot.committed.GetHashMapType(sc, id)
	}
}

func (snapshot *transientSnapshotV2) IsHashMapKeyExist(sc types.Address, id string, key string) bool {
	if snapshot.storageSnapshotV2.IsHashMapKeyExist(sc, id, key) {
		return true
	}
	return snapshot.committed.IsHashMapKeyExist(sc, id, key)
}

func (snapshot *transientSnapshotV2) IsDeferCallExist(sc types.Address, id string) bool {
	if snapshot.storageSnapshotV2.IsDeferCallExist(sc, id) {
		return true
	}
	return snapshot.committed.IsDeferCallExist(sc, id)
}

func (snapshot *transientSnapshotV2) GetDeferCallSignature(sc types.Address, id string) string {
	if sig := snapshot.storageSnapshotV2.GetDeferCallSignature(sc, id); sig != "" {
		return sig
	}
	return snapshot.committed.GetDeferCallSignature(sc, id)
}

func (snapshot *transientSnapshotV2) IsQueueExist(sc types.Address, id string) bool {
	if snapshot.storageSnapshotV2.IsQueueExist(sc, id) {
		return true
	}
	return snapshot.committed.IsQueueExist(sc, id)
}

func (snapshot *transientSnapshotV2) GetQueueSize(sc types.Address, id string) int {
	if size := snapshot.storageSnapshotV2.GetQueueSize(sc, id); size != -1 {
		return size
	}
	return snapshot.committed.GetQueueSize(sc, id)
}
func (snapshot *transientSnapshotV2) Show() {
	fmt.Printf("github.com/HPISTechnologies/concurrentlib/clib/storage_snapshot_v2.go (transientSnapshotV2) show ---> \n")
	for addr, cs := range snapshot.db {
		fmt.Printf("++++++++++++++  addr=%v,\n", addr)
		for k, v := range cs.arrays {
			fmt.Printf("++++++++++++++  arrays k=%v,v=%v\n", k, v)
		}

		for k, v := range cs.defers {
			fmt.Printf("++++++++++++++  defers k=%v,v=%v\n", k, v)
		}

		for k, v := range cs.hashmaps {
			fmt.Printf("++++++++++++++  hashmaps k=%v,v=%v\n", k, v)
		}
		for k, v := range cs.queues {
			fmt.Printf("++++++++++++++  queues k=%v,v=%v\n", k, v)
		}
	}
	snapshot.committed.Show()
}

func (snapshot *transientSnapshotV2) GetQueueType(sc types.Address, id string) int {
	if t := snapshot.storageSnapshotV2.GetQueueType(sc, id); t != DataTypeInvalid {
		return t
	}
	return snapshot.committed.GetQueueType(sc, id)
}

func (snapshot *transientSnapshotV2) GetQueueElem(sc types.Address, id string, index int) ([]byte, bool) {
	if value, ok := snapshot.storageSnapshotV2.GetQueueElem(sc, id, index); ok {
		return value, ok
	}
	if snapshot.isApcCache && snapshot.committed == nil {
		return nil, false
	} else {
		return snapshot.committed.GetQueueElem(sc, id, index)
	}
}
func (snapshot *transientSnapshotV2) GetQueueElemAll(sc types.Address, id string) ([][]byte, bool) {
	if value, ok := snapshot.storageSnapshotV2.GetQueueElemAll(sc, id); ok {
		return value, ok
	}
	return snapshot.committed.GetQueueElemAll(sc, id)
}

func (snapshot *transientSnapshotV2) Commit(writes map[types.Address]*types.WriteSet) bool {
	for addr, ws := range writes {
		storage, ok := snapshot.db[addr]
		if !ok {
			storage = &contractStorage{
				arrays:   make(map[string]*array),
				hashmaps: make(map[string]*genericHashMap),
				queues:   make(map[string]*genericQueue),
				defers:   make(map[string]string),
			}
			snapshot.db[addr] = storage
		}

		for _, aw := range ws.ArrayWrites {
			// Create new array.
			if aw.Version != 0 {
				if _, ok := storage.arrays[aw.ID]; ok {
					panic(fmt.Sprintf("Cannot create hashmap(%v) on contract(%v) twice.", aw.ID, addr))
				}
				storage.arrays[aw.ID] = &array{
					elemType: aw.Index,
					elems:    make([][]byte, int(aw.Version)),
				}
				continue
			}
			// Meta data completion.
			if _, ok := storage.arrays[aw.ID]; !ok {
				t := snapshot.committed.GetArrayType(addr, aw.ID)
				size := snapshot.committed.GetArraySize(addr, aw.ID)
				storage.arrays[aw.ID] = &array{
					elemType: t,
					elems:    make([][]byte, size),
				}
				copy(storage.arrays[aw.ID].elems, snapshot.committed.db[addr].arrays[aw.ID].elems)
			}
			storage.arrays[aw.ID].elems[aw.Index] = aw.Value
		}

		for _, mw := range ws.HashMapWrites {
			// Create new hashmap.
			if (mw.Version & types.VersionMask) == 0 {
				if _, ok := storage.hashmaps[mw.ID]; ok {
					panic(fmt.Sprintf("Cannot create hashmap(%v) on contract(%v) twice.", mw.ID, addr))
				}
				storage.hashmaps[mw.ID] = &genericHashMap{
					keyType:   int([]byte(mw.Key)[0]),
					valueType: int([]byte(mw.Key)[1]),
					hashMap:   make(map[string]versionedValue),
				}
				continue
			}
			// Meta data completion.
			if _, ok := storage.hashmaps[mw.ID]; !ok {
				kt, vt := snapshot.committed.GetHashMapType(addr, mw.ID)
				storage.hashmaps[mw.ID] = &genericHashMap{
					keyType:   kt,
					valueType: vt,
					hashMap:   make(map[string]versionedValue),
				}
			}
			storage.hashmaps[mw.ID].hashMap[mw.Key] = versionedValue{
				version: mw.Version,
				value:   mw.Value,
			}
		}

		for _, qw := range ws.QueueWrites {
			if qw.Op == types.QueueOpCreate { // Create new queue.
				if _, ok := storage.queues[qw.ID]; ok {
					panic(fmt.Sprintf("Cannot create queue(%v) on contract(%v) twice.", qw.ID, addr))
				}
				storage.queues[qw.ID] = &genericQueue{
					elemType: int(qw.Value[0]),
				}
			} else {
				// Meta data completion.
				if _, ok := storage.queues[qw.ID]; !ok {
					elemType := snapshot.committed.GetQueueType(addr, qw.ID)
					storage.queues[qw.ID] = &genericQueue{
						elemType: elemType,
						elems:    make([][]byte, 0),
					}
				}
				if qw.Op == types.QueueOpPush && qw.Pos == types.QueuePosTail { // Push back.
					storage.queues[qw.ID].elems = append(storage.queues[qw.ID].elems, qw.Value)
				} else if qw.Op == types.QueueOpPop && qw.Pos == types.QueuePosHead { // Pop front.
					if len(storage.queues[qw.ID].elems) < 1 {
						panic(fmt.Sprintf("Pop on empty queue(%v)", qw.ID))
					}
					storage.queues[qw.ID].elems = storage.queues[qw.ID].elems[1:]
				} else {
					panic(fmt.Sprintf("Unsupported operation(%v,%v) on queue(%v)", qw.Op, qw.Pos, qw.ID))
				}
			}
		}

		for _, dw := range ws.DeferCallWrites {
			// Create new defer call.
			if _, ok := storage.defers[dw.DeferID]; ok {
				panic(fmt.Sprintf("Cannot create defer call(%v) on contract(%v) twice.", dw.DeferID, addr))
			}
			storage.defers[dw.DeferID] = dw.Signature
		}
	}
	return true
}
func (snapshot *transientSnapshotV2) Empty() {
	snapshot.committed = nil
}

func (snapshot *transientSnapshotV2) CreateTransientSnapshot() Snapshot {
	return snapshot
}
