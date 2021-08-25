package concurrentlib_test

import (
	"bytes"
	"math/big"
	"testing"

	ethcommon "github.com/arcology/3rd-party/eth/common"
	"github.com/arcology/common-lib/types"
	"github.com/arcology/concurrentlib"
	"github.com/arcology/concurrenturl/v2"
	urlcommon "github.com/arcology/concurrenturl/v2/common"
	commutative "github.com/arcology/concurrenturl/v2/type/commutative"
)

func TestContainersBasic(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account1 := types.Address("contractAddress1")
	account2 := types.Address("contractAddress2")
	arrayID1 := "arrayID1"
	arrayID2 := "arrayID2"
	map1 := "mapID1"
	map2 := "mapID2"
	queue1 := "queueID1"
	queue2 := "queueID2"

	array := concurrentlib.NewFixedLengthArray(url, &txContext{index: 1})
	if !array.Create(account1, arrayID1, concurrentlib.DataTypeUint256, 11) {
		t.Error("Failed to create array11.")
	}
	value1 := ethcommon.BytesToHash([]byte{1}).Bytes()
	if !array.SetElem(account1, arrayID1, 1, value1, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set element on array11.")
	}
	if !array.Create(account1, arrayID2, concurrentlib.DataTypeUint256, 12) {
		t.Error("Failed to create array12.")
	}
	value2 := ethcommon.BytesToHash([]byte{2}).Bytes()
	if !array.SetElem(account1, arrayID2, 2, value2, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set element on array12.")
	}
	if !array.Create(account2, arrayID1, concurrentlib.DataTypeUint256, 21) {
		t.Error("Failed to create array21.")
	}
	value3 := ethcommon.BytesToHash([]byte{3}).Bytes()
	if !array.SetElem(account2, arrayID1, 3, value3, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set element on array21.")
	}
	if !array.Create(account2, arrayID2, concurrentlib.DataTypeUint256, 22) {
		t.Error("Failed to create array22.")
	}
	value4 := ethcommon.BytesToHash([]byte{4}).Bytes()
	if !array.SetElem(account2, arrayID2, 4, value4, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set element on array22.")
	}

	sm := concurrentlib.NewSortedMap(url, &txContext{index: 1})
	if !sm.Create(account1, map1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create map11.")
	}
	if !sm.SetValue(account1, map1, []byte("key11"), []byte("value11"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value on map11.")
	}
	if !sm.Create(account1, map2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create map12.")
	}
	if !sm.SetValue(account1, map2, []byte("key12"), []byte("value12"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value on map12.")
	}
	if !sm.Create(account2, map1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create map21.")
	}
	if !sm.SetValue(account2, map1, []byte("key21"), []byte("value21"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value on map21.")
	}
	if !sm.Create(account2, map2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create map22.")
	}
	if !sm.SetValue(account2, map2, []byte("key22"), []byte("value22"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value on map22.")
	}

	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	if !queue.Create(account1, queue1, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create queue11.")
	}
	elem11 := []byte("queue11elem1")
	if !queue.Push(account1, queue1, elem11, concurrentlib.DataTypeUint256) {
		t.Error("Failed to push element1 to queue11.")
	}
	elem12 := []byte("queue11elem2")
	if !queue.Push(account1, queue1, elem12, concurrentlib.DataTypeUint256) {
		t.Error("Failed to push element2 to queue11.")
	}
	if value, ok := queue.Pop(account1, queue1, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, elem11) {
		t.Error("Failed to pop element from queue11.")
	}
	if !queue.Create(account1, queue2, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create queue12.")
	}
	if !queue.Create(account2, queue1, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create queue21.")
	}
	elem21 := []byte("queue21elem1")
	if !queue.Push(account2, queue1, elem21, concurrentlib.DataTypeUint256) {
		t.Error("Failed to push element1 to queue21.")
	}
	elem22 := []byte("queue21elem2")
	if !queue.Push(account2, queue1, elem22, concurrentlib.DataTypeUint256) {
		t.Error("Failed to push element2 to queue21.")
	}
	if value, ok := queue.Pop(account2, queue1, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, elem21) {
		t.Error("Failed to pop element from queue21.")
	}
	if !queue.Create(account2, queue2, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create queue22.")
	}

	_, transitions := url.Export(true)
	t.Log("\n" + formatTransitions(transitions))

	if errs := url.Commit(transitions, []uint32{1}); len(errs) != 0 {
		t.Error("Failed to commit transitions.")
	}

	if value, ok := array.GetElem(account1, arrayID1, 1, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, value1) {
		t.Errorf("Expected value1 = %v, got %v.", value1, value)
	}
	if value, ok := array.GetElem(account1, arrayID2, 2, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, value2) {
		t.Errorf("Expected value2 = %v, got %v.", value2, value)
	}
	if value, ok := array.GetElem(account2, arrayID1, 3, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, value3) {
		t.Errorf("Expected value3 = %v, got %v.", value3, value)
	}
	if value, ok := array.GetElem(account2, arrayID2, 4, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, value4) {
		t.Errorf("Expected value4 = %v, got %v.", value4, value)
	}

	if value, ok := sm.GetValue(account1, map1, []byte("key11"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("value11")) {
		t.Errorf("Expected value11 = %v, got %v.", []byte("value11"), value)
	}
	if value, ok := sm.GetValue(account1, map2, []byte("key12"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("value12")) {
		t.Errorf("Expected value12 = %v, got %v.", []byte("value12"), value)
	}
	if value, ok := sm.GetValue(account2, map1, []byte("key21"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("value21")) {
		t.Errorf("Expected value21 = %v, got %v.", []byte("value21"), value)
	}
	if value, ok := sm.GetValue(account2, map2, []byte("key22"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("value22")) {
		t.Errorf("Expected value22 = %v, got %v.", []byte("value22"), value)
	}

	if value, ok := queue.Pop(account1, queue1, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, elem12) {
		t.Errorf("Expected elem12 = %v, got %v.", elem12, value)
	}
	if value, ok := queue.Pop(account2, queue1, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, elem22) {
		t.Errorf("Expected elem22 = %v, got %v.", elem22, value)
	}
}
