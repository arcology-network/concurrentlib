package concurrentlib_test

import (
	"math/big"
	"testing"

	ethcommon "github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrentlib"
	"github.com/HPISTechnologies/concurrenturl"
	urlcommon "github.com/HPISTechnologies/concurrenturl/common"
	urltype "github.com/HPISTechnologies/concurrenturl/type"
	commutative "github.com/HPISTechnologies/concurrenturl/type/commutative"
	arbitrator "github.com/HPISTechnologies/urlarbitrator-engine/go-wrapper"
)

func detectConflict(transitions []urlcommon.UnivalueInterface) ([]uint32, []uint32, []bool) {
	length := len(transitions)
	txs := make([]uint32, length)
	paths := make([]string, length)
	reads := make([]uint32, length)
	writes := make([]uint32, length)
	addOrDelete := make([]bool, length)
	composite := make([]bool, length)
	for i, t := range transitions {
		txs[i] = t.(*urltype.Univalue).GetTx()
		paths[i] = t.(*urltype.Univalue).GetPath()
		reads[i] = t.(*urltype.Univalue).GetReads()
		writes[i] = t.(*urltype.Univalue).GetWrites()
		addOrDelete[i] = t.(*urltype.Univalue).IsAddOrDelete()
		composite[i] = t.(*urltype.Univalue).IsComposite()
	}

	engine := arbitrator.Start()
	arbitrator.Insert(engine, txs, paths, reads, writes, addOrDelete, composite)
	txs, groups, flags := arbitrator.Detect(engine, uint32(length))
	arbitrator.Clear(engine)
	return txs, groups, flags
}

func TestFixedLengthArrayConflict(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	arrayID := "arrayID"

	array := concurrentlib.NewFixedLengthArray(url, &txContext{index: 1})
	if !array.Create(account, arrayID, concurrentlib.DataTypeUint256, 2) {
		t.Error("Failed to create array.")
	}

	_, transitions := url.Export()
	if errs := url.Commit(transitions, []uint32{1}); len(errs) != 0 {
		t.Error("Failed to commit transitions.")
	}

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	array1 := concurrentlib.NewFixedLengthArray(url1, &txContext{index: 2})
	if !array1.SetElem(account, arrayID, 0, ethcommon.BytesToHash([]byte{2}).Bytes(), concurrentlib.DataTypeUint256) {
		t.Error("Failed to set element on array.")
	}

	accessRecords1, _ := url1.Export()
	t.Log("\n" + formatTransitions(accessRecords1))

	array2 := concurrentlib.NewFixedLengthArray(url2, &txContext{index: 3})
	if !array2.SetElem(account, arrayID, 1, ethcommon.BytesToHash([]byte{3}).Bytes(), concurrentlib.DataTypeUint256) {
		t.Error("Failed to set element on array.")
	}

	// url1.Print()
	accessRecords2, _ := url2.Export()
	t.Log("\n" + formatTransitions(accessRecords2))

	txs, groups, flags := detectConflict(append(accessRecords1, accessRecords2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSortedMapConflict(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	mapID := "mapID"

	sm := concurrentlib.NewSortedMap(url, &txContext{index: 1})
	if !sm.Create(account, mapID, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create map.")
	}

	_, transitions := url.Export()
	if errs := url.Commit(transitions, []uint32{1}); len(errs) != 0 {
		t.Error("Failed to commit transitions.")
	}

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)
	url3 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 2})
	if !sm1.SetValue(account, mapID, []byte("key1"), []byte("value1"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value on map.")
	}
	if !sm1.DeleteKey(account, mapID, []byte("key1"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to delete key on map.")
	}
	// if size := sm1.GetSize(account, mapID); size != 0 {
	// 	t.Errorf("Expected size = 0, got %v", size)
	// }
	records1, _ := url1.Export()
	t.Log("\n" + formatTransitions(records1))

	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 3})
	if !sm2.SetValue(account, mapID, []byte("key2"), []byte("value2"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value on map.")
	}
	records2, _ := url2.Export()
	t.Log("\n" + formatTransitions(records2))

	sm3 := concurrentlib.NewSortedMap(url3, &txContext{index: 4})
	if !sm3.SetValue(account, mapID, []byte("key3"), []byte("value3"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value on map.")
	}
	records3, _ := url3.Export()
	t.Log("\n" + formatTransitions(records3))

	txs, groups, flags := detectConflict(append(append(records1, records2...), records3...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestQueueConflict(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	queueID := "queueID"

	queue := concurrentlib.NewQueue(url, &txContext{index: 1})
	if !queue.Create(account, queueID, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create queue.")
	}

	_, transitions := url.Export()
	t.Log("\n" + formatTransitions(transitions))
	if errs := url.Commit(transitions, []uint32{1}); len(errs) != 0 {
		t.Error("Failed to commit transitions.")
	}

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(100), index: 2})
	if !queue1.Push(account, queueID, []byte("element1"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push element to queue.")
	}
	if _, ok := queue1.Pop(account, queueID, concurrentlib.DataTypeUint256); !ok {
		t.Error("Failed to pop element from queue.")
	}
	records1, _ := url1.Export()
	t.Log("\n" + formatTransitions(records1))

	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(100), index: 3})
	if !queue2.Push(account, queueID, []byte("element2"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push element to queue.")
	}
	records2, _ := url2.Export()
	t.Log("\n" + formatTransitions(records2))

	txs, groups, flags := detectConflict(append(records1, records2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 2 {
		t.Fail()
	}
}
