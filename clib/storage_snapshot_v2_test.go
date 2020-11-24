package clib

import (
	"bytes"
	"reflect"
	"testing"

	"github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
)

func TestSnapshotV2WithHashMap(t *testing.T) {
	snapshot := NewSnapshot().(*storageSnapshotV2)
	hashmap := NewConcurrentHashMap(0x0101, snapshot)
	sc := types.Address("addr")

	hashmap.Create(sc, "map1", DataTypeUint256, DataTypeUint256)
	hashmap.SetValue(sc, "map1", []byte("key1"), []byte("value1"), DataTypeUint256, DataTypeUint256)
	_, mws := hashmap.Collect()
	wss := hashmapWritesToWriteSets(mws)
	snapshot.Commit(wss)

	value, ok := hashmap.GetValue(sc, "map1", []byte("key1"), DataTypeUint256, DataTypeUint256)
	if !ok || bytes.Compare(value, []byte("value1")) != 0 {
		t.Error("Test Create and SetValue failed")
		return
	}

	hashmap.SetValue(sc, "map1", []byte("key2"), []byte("value2"), DataTypeUint256, DataTypeUint256)
	hashmap.DeleteKey(sc, "map1", []byte("key2"), DataTypeUint256)
	_, mws = hashmap.Collect()
	wss = hashmapWritesToWriteSets(mws)
	snapshot.Commit(wss)

	value, ok = hashmap.GetValue(sc, "map1", []byte("key2"), DataTypeUint256, DataTypeUint256)
	if !ok || bytes.Compare(value, common.Hash{}.Bytes()) != 0 {
		t.Error("Test SetValue and DeleteKey failed")
		return
	}
}

func TestTransientSnapshotV2WithHashMapForlevel(t *testing.T) {
	snapshot := NewSnapshot().(*storageSnapshotV2)
	transientSnapshot := snapshot.CreateTransientSnapshot()
	hashmap := NewConcurrentHashMap(0x0101, transientSnapshot)
	sc := types.Address("addr")

	hashmap.Create(sc, "map1", DataTypeUint256, DataTypeUint256)
	hashmap.SetValue(sc, "map1", []byte("key1"), []byte("value1"), DataTypeUint256, DataTypeUint256)
	_, mws := hashmap.Collect()
	wss := hashmapWritesToWriteSets(mws)
	transientSnapshot.Commit(wss)

	value, ok := hashmap.GetValue(sc, "map1", []byte("key1"), DataTypeUint256, DataTypeUint256)
	if !ok || bytes.Compare(value, []byte("value1")) != 0 {
		t.Error("Test Create and SetValue failed")
		return
	}

	transientSnapshot2 := transientSnapshot.CreateTransientSnapshotForApc()
	hashmap2 := NewConcurrentHashMap(0x0102, transientSnapshot2)
	sc2 := types.Address("addr2")

	hashmap2.Create(sc2, "map2", DataTypeUint256, DataTypeUint256)
	hashmap2.SetValue(sc2, "map2", []byte("key2"), []byte("value22"), DataTypeUint256, DataTypeUint256)
	_, mws2 := hashmap2.Collect()
	wss2 := hashmapWritesToWriteSets(mws2)
	transientSnapshot2.Commit(wss2)

	value, _ = transientSnapshot2.GetHashMapValue(sc2, "map2", "key2", DataTypeUint256, DataTypeUint256)
	if !reflect.DeepEqual(value, []byte("value22")) {
		t.Error("level2 data save or get err !", value, []byte("value22"))
	}

	value, _ = transientSnapshot.GetHashMapValue(sc, "map1", "key1", DataTypeUint256, DataTypeUint256)
	if !reflect.DeepEqual(value, []byte("value1")) {
		t.Error("level1 data save or get err !", value, []byte("value1"))
	}

	transientSnapshot2.Empty()
	transientSnapshot = nil

	value, _ = transientSnapshot2.GetHashMapValue(sc, "map1", "key1", DataTypeUint256, DataTypeUint256)
	if value != nil {
		t.Error("empty level1 data save or get err !", value)
	}

	value, _ = transientSnapshot2.GetHashMapValue(sc2, "map2", "key2", DataTypeUint256, DataTypeUint256)
	if !reflect.DeepEqual(value, []byte("value22")) {
		t.Error("empty level2 data save or get err !", value, []byte("value22"))
	}
}
func TestTransientSnapshotV2WithHashMap(t *testing.T) {
	snapshot := NewSnapshot().(*storageSnapshotV2)
	transientSnapshot := snapshot.CreateTransientSnapshot()
	hashmap := NewConcurrentHashMap(0x0101, transientSnapshot)
	sc := types.Address("addr")

	hashmap.Create(sc, "map1", DataTypeUint256, DataTypeUint256)
	hashmap.SetValue(sc, "map1", []byte("key1"), []byte("value1"), DataTypeUint256, DataTypeUint256)
	_, mws := hashmap.Collect()
	wss := hashmapWritesToWriteSets(mws)
	transientSnapshot.Commit(wss)

	value, ok := hashmap.GetValue(sc, "map1", []byte("key1"), DataTypeUint256, DataTypeUint256)
	if !ok || bytes.Compare(value, []byte("value1")) != 0 {
		t.Error("Test Create and SetValue failed")
		return
	}
	value, version := snapshot.GetHashMapValue(sc, "map1", "key1", DataTypeUint256, DataTypeUint256)
	if value != nil || version != types.InvalidVersion {
		t.Error("Unexpected change on Snapshot after Create and SetValue on TransientSnapshot")
		return
	}

	hashmap.SetValue(sc, "map1", []byte("key2"), []byte("value2"), DataTypeUint256, DataTypeUint256)
	hashmap.DeleteKey(sc, "map1", []byte("key2"), DataTypeUint256)
	_, mws = hashmap.Collect()
	wss = hashmapWritesToWriteSets(mws)
	transientSnapshot.Commit(wss)

	value, ok = hashmap.GetValue(sc, "map1", []byte("key2"), DataTypeUint256, DataTypeUint256)
	if !ok || bytes.Compare(value, common.Hash{}.Bytes()) != 0 {
		t.Error("Test SetValue and DeleteKey failed")
		return
	}
	value, version = snapshot.GetHashMapValue(sc, "map1", "key1", DataTypeUint256, DataTypeUint256)
	if value != nil || version != types.InvalidVersion {
		t.Error("Unexpected change on Snapshot after SetValue on DeleteKey on TransientSnapshot")
		return
	}

}

func TestSnapshotV2WithDeferCall(t *testing.T) {
	snapshot := NewSnapshot().(*storageSnapshotV2)
	deferCall := NewDeferCallDirector(snapshot)
	sc := types.Address("addr")

	deferCall.Create(sc, "defer", "deferFun(string)")
	if deferCall.IsExist(sc, "defer") {
		t.Error("DeferCall cannot be accessed in the same block after creation")
		return
	}
	dws := deferCall.Collect()
	wss := deferCallWritesToWriteSets(dws)
	snapshot.Commit(wss)

	sig := deferCall.GetSignature(sc, "defer")
	if sig != "deferFun(string)" {
		t.Error("Checking signature failed")
		return
	}
}

func TestTransientSnapshotV2WithDeferCall(t *testing.T) {
	snapshot := NewSnapshot().(*storageSnapshotV2)
	transientSnapshot := snapshot.CreateTransientSnapshot()
	deferCall := NewDeferCallDirector(transientSnapshot)
	sc := types.Address("addr")

	deferCall.Create(sc, "defer", "deferFun(string)")
	if deferCall.IsExist(sc, "defer") {
		t.Error("DeferCall cannot be accessed in the same block after creation")
		return
	}
	dws := deferCall.Collect()
	wss := deferCallWritesToWriteSets(dws)
	transientSnapshot.Commit(wss)

	sig := deferCall.GetSignature(sc, "defer")
	if sig != "deferFun(string)" {
		t.Error("Checking signature failed")
		return
	}
	if snapshot.IsDeferCallExist(sc, "defer") {
		t.Error("Unexpected change on Snapshot")
		return
	}
}

func hashmapWritesToWriteSets(mws map[types.Address][]types.HashMapWrite) map[types.Address]*types.WriteSet {
	ret := make(map[types.Address]*types.WriteSet)
	for addr, mw := range mws {
		if _, ok := ret[addr]; !ok {
			ret[addr] = &types.WriteSet{
				HashMapWrites: mw,
			}
		} else {
			ret[addr].HashMapWrites = append(ret[addr].HashMapWrites, mw...)
		}
	}
	return ret
}

func deferCallWritesToWriteSets(dws map[types.Address][]types.DeferCallWrite) map[types.Address]*types.WriteSet {
	ret := make(map[types.Address]*types.WriteSet)
	for addr, dw := range dws {
		if _, ok := ret[addr]; !ok {
			ret[addr] = &types.WriteSet{
				DeferCallWrites: dw,
			}
		} else {
			ret[addr].DeferCallWrites = append(ret[addr].DeferCallWrites, dw...)
		}
	}
	return ret
}
