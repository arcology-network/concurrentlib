package concurrentlib_test

import (
	"bytes"
	"math/big"
	"testing"

	"github.com/arcology-network/common-lib/types"
	"github.com/arcology-network/concurrentlib"
	"github.com/arcology-network/concurrenturl/v2"
	urlcommon "github.com/arcology-network/concurrenturl/v2/common"
	commutative "github.com/arcology-network/concurrenturl/v2/type/commutative"
)

func TestTransientDBBasic(t *testing.T) {
	persistentDB := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	persistentDB.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	transientDB := urlcommon.NewTransientDB(persistentDB)

	// transientDB := urlcommon.NewDataStore()
	// meta, _ := noncommutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	// transientDB.Save(urlcommon.ACCOUNT_BASE_URL, meta)

	url := concurrenturl.NewConcurrentUrl(transientDB)

	account1 := types.Address("contractAddress1")
	account2 := types.Address("contractAddress2")
	mapID1 := "mapID1"
	mapID2 := "mapID2"
	queueID := "queueID"

	context := &txContext{height: new(big.Int).SetUint64(100), index: 1}
	sm := concurrentlib.NewSortedMap(url, context)
	queue := concurrentlib.NewQueue(url, context)

	sm.Create(account1, mapID1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm.SetValue(account1, mapID1, []byte("key1"), []byte("value1"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm.SetValue(account1, mapID1, []byte("key2"), []byte("value2"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm.Create(account1, mapID2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress)
	sm.SetValue(account1, mapID2, []byte("key3"), []byte("value3"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress)
	sm.SetValue(account1, mapID2, []byte("key4"), []byte("value4"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress)
	queue.Create(account2, queueID, concurrentlib.DataTypeBytes)
	queue.Push(account2, queueID, []byte("elem1"), concurrentlib.DataTypeBytes)
	if queue.GetSize(account2, queueID) != 1 {
		t.Fail()
	}
	queue.Push(account2, queueID, []byte("elem2"), concurrentlib.DataTypeBytes)
	if queue.GetSize(account2, queueID) != 2 {
		t.Fail()
	}

	_, transitions := url.Export(true)
	t.Log("\n" + formatTransitions(transitions))
	url.Import(transitions)
	url.Commit([]uint32{1})

	url = concurrenturl.NewConcurrentUrl(transientDB)
	context = &txContext{height: new(big.Int).SetUint64(101), index: 1}
	sm = concurrentlib.NewSortedMap(url, context)
	queue = concurrentlib.NewQueue(url, context)

	if size := sm.GetSize(account1, mapID1); size != 2 {
		t.Errorf("SortedMap.GetSize(account1, mapID1) error, got %d, expected %d", size, 2)
		return
	}
	if value, ok := sm.GetValue(account1, mapID1, []byte("key1"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("value1")) {
		t.Fail()
	}
	if value, ok := sm.GetValue(account1, mapID1, []byte("key2"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("value2")) {
		t.Fail()
	}
	if sm.GetSize(account1, mapID2) != 2 {
		t.Fail()
	}
	if value, ok := sm.GetValue(account1, mapID2, []byte("key3"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress); !ok || !bytes.Equal(value, []byte("value3")) {
		t.Fail()
	}
	if value, ok := sm.GetValue(account1, mapID2, []byte("key4"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress); !ok || !bytes.Equal(value, []byte("value4")) {
		t.Fail()
	}
	if queue.GetSize(account2, queueID) != 2 {
		t.Fail()
	}

	sm.SetValue(account1, mapID1, []byte("key1"), []byte("newvalue1"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	if value, ok := sm.GetValue(account1, mapID1, []byte("key1"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("newvalue1")) {
		t.Fail()
	}
	sm.DeleteKey(account1, mapID1, []byte("key2"), concurrentlib.DataTypeUint256)
	if sm.GetSize(account1, mapID1) != 1 {
		t.Fail()
	}
	sm.SetValue(account1, mapID2, []byte("key5"), []byte("value5"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress)
	if value, ok := queue.Pop(account2, queueID, concurrentlib.DataTypeBytes); !ok || !bytes.Equal(value, []byte("elem1")) {
		t.Fail()
	}
	queue.Push(account2, queueID, []byte("elem3"), concurrentlib.DataTypeBytes)
	queue.Push(account2, queueID, []byte("elem4"), concurrentlib.DataTypeBytes)

	_, transitions = url.Export(true)
	t.Log("\n" + formatTransitions(transitions))
	url.Import(transitions)
	url.Commit([]uint32{1})

	url = concurrenturl.NewConcurrentUrl(transientDB)
	context = &txContext{height: new(big.Int).SetUint64(102), index: 1}
	sm = concurrentlib.NewSortedMap(url, context)
	queue = concurrentlib.NewQueue(url, context)

	if size := sm.GetSize(account1, mapID1); size != 1 {
		t.Errorf("SortedMap.GetSize(account1, mapID1) error, got %d, expected %d", size, 1)
		return
	}
	if value, ok := sm.GetValue(account1, mapID1, []byte("key1"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("newvalue1")) {
		t.Fail()
	}
	if sm.GetSize(account1, mapID2) != 3 {
		t.Fail()
	}
	if value, ok := sm.GetValue(account1, mapID2, []byte("key3"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress); !ok || !bytes.Equal(value, []byte("value3")) {
		t.Fail()
	}
	if value, ok := sm.GetValue(account1, mapID2, []byte("key4"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress); !ok || !bytes.Equal(value, []byte("value4")) {
		t.Fail()
	}
	if value, ok := sm.GetValue(account1, mapID2, []byte("key5"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress); !ok || !bytes.Equal(value, []byte("value5")) {
		t.Fail()
	}
	if queue.GetSize(account2, queueID) != 3 {
		t.Fail()
	}
	if value, ok := queue.Pop(account2, queueID, concurrentlib.DataTypeBytes); !ok {
		t.Error("Failed to pop element from queue.")
		return
	} else if !bytes.Equal(value, []byte("elem2")) {
		t.Errorf("Unexpected element got, expected: %v, got %v", []byte("elem2"), value)
		return
	}
	if queue.GetSize(account2, queueID) != 2 {
		t.Fail()
	}
	if value, ok := queue.Pop(account2, queueID, concurrentlib.DataTypeBytes); !ok || !bytes.Equal(value, []byte("elem3")) {
		t.Fail()
	}
	if queue.GetSize(account2, queueID) != 1 {
		t.Fail()
	}
	if value, ok := queue.Pop(account2, queueID, concurrentlib.DataTypeBytes); !ok || !bytes.Equal(value, []byte("elem4")) {
		t.Fail()
	}
	if queue.GetSize(account2, queueID) != 0 {
		t.Fail()
	}

	_, transitions = url.Export(true)
	t.Log("\n" + formatTransitions(transitions))
	url.Import(transitions)
	url.Commit([]uint32{1})

	url = concurrenturl.NewConcurrentUrl(transientDB)
	context = &txContext{height: new(big.Int).SetUint64(103), index: 1}
	// sm = concurrentlib.NewSortedMap(url, context)
	queue = concurrentlib.NewQueue(url, context)
	queue.Push(account2, queueID, []byte("elem5"), concurrentlib.DataTypeBytes)
	if value, ok := queue.Pop(account2, queueID, concurrentlib.DataTypeBytes); !ok || !bytes.Equal(value, []byte("elem5")) {
		t.Fail()
	}
}
