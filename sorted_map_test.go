package concurrentlib_test

import (
	"bytes"
	"testing"

	ethcommon "github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrentlib"
	"github.com/HPISTechnologies/concurrenturl/v2"
	urlcommon "github.com/HPISTechnologies/concurrenturl/v2/common"
	commutative "github.com/HPISTechnologies/concurrenturl/v2/type/commutative"
)

func TestSMBasic(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	id := "mapID"
	sm := concurrentlib.NewSortedMap(url, &txContext{index: 1})
	if !sm.Create(account, id, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create map.")
	}

	if sm.Create(account, id, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Create a map twice.")
	}

	size := sm.GetSize(account, id)
	if size != 0 {
		t.Errorf("Expected size = 0, got %v.", size)
	}

	key1 := []byte("abc")
	value1 := ethcommon.BytesToHash([]byte{100}).Bytes()
	if !sm.SetValue(account, id, key1, value1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value.")
	}

	key2 := []byte("def")
	value2 := ethcommon.BytesToHash([]byte{101}).Bytes()
	if sm.SetValue(account, id, key2, value2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeAddress) {
		t.Error("Successfully set value with wrong type.")
	}

	if !sm.SetValue(account, id, key2, value2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Error("Failed to set value.")
	}

	if value, ok := sm.GetValue(account, id, key1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || value == nil {
		t.Error("Failed to get value.")
	} else if !bytes.Equal(value1, value) {
		t.Errorf("Expected value = %v, got %v.", value1, value)
	}

	if value, ok := sm.GetValue(account, id, key2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256); !ok || value == nil {
		t.Error("Failed to get value.")
	} else if !bytes.Equal(value2, value) {
		t.Errorf("Expected value = %v, got %v.", value2, value)
	}

	size = sm.GetSize(account, id)
	if size != 2 {
		t.Errorf("Expected size = 2, got %v.", size)
	}

	if keys, ok := sm.GetKeys(account, id, concurrentlib.DataTypeUint256); !ok || len(keys) != 2 || !bytes.Equal(key1, keys[0]) || !bytes.Equal(key2, keys[1]) {
		t.Errorf("Expected keys = %v, got %v.", [][]byte{key1, key2}, keys)
	}

	if !sm.DeleteKey(account, id, key1, concurrentlib.DataTypeUint256) {
		t.Error("Failed to delete key.")
	}

	size = sm.GetSize(account, id)
	if size != 1 {
		t.Errorf("Expected size = 1, got %v", size)
	}

	// _, transitions := sm.Collect()
	// t.Log("\n" + formatTransitions(transitions))
	accessRecords, _ := url.Export(true)
	t.Log("\n" + formatTransitions(accessRecords))
}

func TestSMCreateTwoMapsInDiffAccounts(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account1 := types.Address("contractAddress1")
	account2 := types.Address("contractAddress2")
	id1 := "map1"

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.Create(account1, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.Create(account2, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMCreateTwoDiffMapsInSameAccount(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, "somemap", concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	t.Log("\n" + formatTransitions(transitions))
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMCreateAndAddKey(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm2.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm1.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMCreateAndDeleteExistKey(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm2.DeleteKey(account, id1, []byte("somekey"), concurrentlib.DataTypeUint256)
	sm1.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMCreateAndDeleteNonexistKey(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm2.DeleteKey(account, id1, []byte("somekey"), concurrentlib.DataTypeUint256)
	sm1.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMCreateAndUpdateKey(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.SetValue(account, id1, []byte("somekey"), []byte("someothervalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMCreateAndGetSize(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.GetSize(account, id1)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMCreateAndAddThenDelete(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.DeleteKey(account, id1, []byte("somekey"), concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 0 {
		t.Fail()
	}
}

func TestSMAddKeyAndDeleteNonexistKey(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.DeleteKey(account, id1, []byte("somekey"), concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 2 {
		t.Fail()
	}
}

func TestSMAddKeyAndGetSize(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm2.GetSize(account, id1)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 2 {
		t.Fail()
	}
}

func TestSMAddThenDeleteAndGetSize(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	sm1.SetValue(account, id1, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm1.DeleteKey(account, id1, []byte("somekey"), concurrentlib.DataTypeUint256)
	sm2.GetSize(account, id1)

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 2 {
		t.Fail()
	}
}

func TestSMCreateAndSetKeyToSameMap(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "map1"
	id2 := "map2"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id1, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	sm1 := concurrentlib.NewSortedMap(url1, &txContext{index: 1})
	sm2 := concurrentlib.NewSortedMap(url2, &txContext{index: 2})

	if !sm1.Create(account, id2, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Log("Create map2 failed.")
		return
	}
	if sm2.SetValue(account, id2, []byte("somekey"), []byte("somevalue"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256) {
		t.Log("Successfully set value on nonexist map.")
		return
	}

	ar1, _ := url1.Export(true)
	ar2, _ := url2.Export(true)

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 2 {
		t.Fail()
	}
}

func TestExportDoNotContainKeysInMetadata(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id := "mapID"

	// Make sure the account exists.
	url := concurrenturl.NewConcurrentUrl(store)
	sm := concurrentlib.NewSortedMap(url, &txContext{})
	sm.Create(account, id, concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	sm.SetValue(account, id, []byte("key1"), []byte("value1"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	_, transitions := url.Export(true)
	url.Commit(transitions, []uint32{0})

	url = concurrenturl.NewConcurrentUrl(store)
	sm = concurrentlib.NewSortedMap(url, &txContext{index: 1})
	sm.SetValue(account, id, []byte("key2"), []byte("value2"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	_, transitions = url.Export(true)
	t.Log("\n" + formatTransitions(transitions))
	url.Commit(transitions, []uint32{1})

	url = concurrenturl.NewConcurrentUrl(store)
	sm = concurrentlib.NewSortedMap(url, &txContext{index: 2})
	sm.SetValue(account, id, []byte("key3"), []byte("value3"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)
	keys, _ := sm.GetKeys(account, id, concurrentlib.DataTypeUint256)
	t.Log(keys)
	sm.SetValue(account, id, []byte("key4"), []byte("value4"), concurrentlib.DataTypeUint256, concurrentlib.DataTypeUint256)

	_, transitions = url.Export(true)
	t.Log("\n" + formatTransitions(transitions))
}
