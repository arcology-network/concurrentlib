package clib

import (
	"bytes"
	"testing"

	"github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
)

var (
	arrayID   = "array-id"
	arraySize = 10
)

func TestCreateArrayTwiceShouldFail(t *testing.T) {
	snapshot := NewSnapshot()
	array := NewConcurrentArray(0x0101, snapshot)

	ok := array.Create(scAddr, arrayID, elemType, arraySize)
	if !ok {
		t.Error("Failed to create array")
		return
	}

	ok = array.Create(scAddr, arrayID, elemType, arraySize)
	if ok {
		t.Error("Create array twice before commit should fail")
		return
	}

	_, aw := array.Collect()
	snapshot.Commit(awToWriteSet(aw))

	ok = array.Create(scAddr, arrayID, elemType, arraySize)
	if ok {
		t.Error("Create array twice after commit should fail")
		return
	}
}

func TestArrayGetElem(t *testing.T) {
	snapshot := NewSnapshot()
	array := NewConcurrentArray(0x0101, snapshot)

	ok := array.Create(scAddr, arrayID, elemType, arraySize)
	if !ok {
		t.Error("Failed to create array")
		return
	}

	ok = array.SetElem(scAddr, arrayID, 0, []byte{1}, elemType)
	if !ok {
		t.Error("Failed to set index 0 to {1}")
		return
	}

	value, ok := array.GetElem(scAddr, arrayID, 0, elemType)
	if !ok || len(value) != 1 || value[0] != 1 {
		t.Error("Failed to get data before commit")
		return
	}

	_, aw := array.Collect()
	snapshot.Commit(awToWriteSet(aw))

	value, ok = array.GetElem(scAddr, arrayID, 0, elemType)
	if !ok || len(value) != 1 || value[0] != 1 {
		t.Error("Failed to get data after commit")
		return
	}
}

func TestGetSetWrongTypeShouldFail(t *testing.T) {
	snapshot := NewSnapshot()
	array := NewConcurrentArray(0x0101, snapshot)

	ok := array.Create(scAddr, arrayID, elemType, arraySize)
	if !ok {
		t.Error("Failed to create array")
		return
	}

	ok = array.SetElem(scAddr, arrayID, 0, []byte{1}, elemType)
	if !ok {
		t.Error("Failed to set index 0 to {1}")
		return
	}

	_, ok = array.GetElem(scAddr, arrayID, 0, wrongType)
	if ok {
		t.Error("Get data with wrong type before commit should fail")
		return
	}

	ok = array.SetElem(scAddr, arrayID, 0, []byte{2}, wrongType)
	if ok {
		t.Error("Set data with wrong type before commit should fail")
		return
	}

	_, aw := array.Collect()
	snapshot.Commit(awToWriteSet(aw))

	_, ok = array.GetElem(scAddr, arrayID, 0, wrongType)
	if ok {
		t.Error("Get data with wrong type after commit should fail")
		return
	}

	ok = array.SetElem(scAddr, arrayID, 0, []byte{2}, wrongType)
	if ok {
		t.Error("Set data with wrong type after commit should fail")
		return
	}
}

func TestArrayGetDefaultValue(t *testing.T) {
	snapshot := NewSnapshot()
	array := NewConcurrentArray(0x0101, snapshot)

	ok := array.Create(scAddr, "uint256array", DataTypeUint256, arraySize)
	if !ok {
		t.Error("Failed to create uint256 array")
		return
	}

	value, ok := array.GetElem(scAddr, "uint256array", 0, DataTypeUint256)
	if !ok || bytes.Compare(value, common.Hash{}.Bytes()) != 0 {
		t.Error("Failed to get default value of uint256 array before commit")
		return
	}

	ok = array.Create(scAddr, "addressarray", DataTypeAddress, arraySize)
	if !ok {
		t.Error("Failed to create address array")
		return
	}

	value, ok = array.GetElem(scAddr, "addressarray", 0, DataTypeAddress)
	if !ok || bytes.Compare(value, common.Address{}.Bytes()) != 0 {
		t.Error("Failed to get default value of address array before commit")
		return
	}

	ok = array.Create(scAddr, "bytesarray", DataTypeBytes, arraySize)
	if !ok {
		t.Error("Failed to create bytes array")
		return
	}

	value, ok = array.GetElem(scAddr, "bytesarray", 0, DataTypeBytes)
	if !ok || value != nil {
		t.Error("Failed to get default value of bytes array before commit")
		return
	}

	_, aw := array.Collect()
	snapshot.Commit(awToWriteSet(aw))

	value, ok = array.GetElem(scAddr, "uint256array", 0, DataTypeUint256)
	if !ok || bytes.Compare(value, common.Hash{}.Bytes()) != 0 {
		t.Error("Failed to get default value of uint256 array after commit")
		return
	}

	value, ok = array.GetElem(scAddr, "addressarray", 0, DataTypeAddress)
	if !ok || bytes.Compare(value, common.Address{}.Bytes()) != 0 {
		t.Error("Failed to get default value of address array after commit")
		return
	}

	value, ok = array.GetElem(scAddr, "bytesarray", 0, DataTypeBytes)
	if !ok || value != nil {
		t.Error("Failed to get default value of bytes array after commit")
		return
	}
}

func TestArrayGetSize(t *testing.T) {
	snapshot := NewSnapshot()
	array := NewConcurrentArray(0x0101, snapshot)

	ok := array.Create(scAddr, arrayID, elemType, arraySize)
	if !ok {
		t.Error("Failed to create array")
		return
	}

	if array.GetSize(scAddr, arrayID) != arraySize {
		t.Error("GetSize failed before commit")
		return
	}

	_, aw := array.Collect()
	snapshot.Commit(awToWriteSet(aw))

	if array.GetSize(scAddr, arrayID) != arraySize {
		t.Error("GetSize failed after commit")
		return
	}
}

func awToWriteSet(arrayWrites map[types.Address][]types.ArrayWrite) map[types.Address]*types.WriteSet {
	ws := make(map[types.Address]*types.WriteSet)
	for addr, aws := range arrayWrites {
		ws[addr] = &types.WriteSet{
			ArrayWrites: aws,
		}
	}
	return ws
}
