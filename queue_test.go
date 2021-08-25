package concurrentlib_test

import (
	"bytes"
	"math/big"
	"testing"

	ethcommon "github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrentlib"
	"github.com/HPISTechnologies/concurrenturl"
	urlcommon "github.com/HPISTechnologies/concurrenturl/common"
	commutative "github.com/HPISTechnologies/concurrenturl/type/commutative"
)

func TestQueueBasic(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	id := "queueID"
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(1000), index: 1})
	if !queue.Create(account, id, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create queue.")
	}

	if queue.Create(account, id, concurrentlib.DataTypeAddress) {
		t.Error("Create a queue twice.")
	}

	size := queue.GetSize(account, id)
	if size != 0 {
		t.Errorf("Expected size = 0, got %v.", size)
	}

	elem0 := ethcommon.BytesToHash([]byte{1}).Bytes()
	if !queue.Push(account, id, elem0, concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem0 to queue.")
	}

	elem1 := ethcommon.BytesToHash([]byte{2}).Bytes()
	if !queue.Push(account, id, elem1, concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem1 to queue.")
	}

	size = queue.GetSize(account, id)
	if size != 2 {
		t.Errorf("Expected size = 2, got %v.", size)
	}

	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || value == nil {
		t.Error("Failed to pop elememnt from queue.")
	} else if !bytes.Equal(elem0, value) {
		t.Errorf("Expected value = %v, got %v.", elem0, value)
	}

	size = queue.GetSize(account, id)
	if size != 1 {
		t.Errorf("Expected size = 1, got %v.", size)
	}

	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || value == nil {
		t.Error("Failed to pop element from queue.")
	} else if !bytes.Equal(elem1, value) {
		t.Errorf("Expected value = %v, got %v.", elem1, value)
	}

	size = queue.GetSize(account, id)
	if size != 0 {
		t.Errorf("Expected size = 0, got %v.", size)
	}

	_, transitions := queue.Collect()
	t.Log("\n" + formatTransitions(transitions))
}

func TestQueueOrder(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	id := "queueID"
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(1000), index: 1})
	if !queue.Create(account, id, concurrentlib.DataTypeUint256) {
		t.Error("Failed to create queue.")
	}

	if !queue.Push(account, id, []byte("elem1"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem1 to queue.")
	}
	if !queue.Push(account, id, []byte("elem2"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem2 to queue.")
	}

	queue = concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(1000), index: 2})
	if !queue.Push(account, id, []byte("elem3"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem3 to queue.")
	}
	if !queue.Push(account, id, []byte("elem4"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem4 to queue.")
	}

	queue = concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(1001), index: 1})
	if !queue.Push(account, id, []byte("elem5"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem5 to queue.")
	}
	if !queue.Push(account, id, []byte("elem6"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem6 to queue.")
	}

	queue = concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(1001), index: 2})
	if !queue.Push(account, id, []byte("elem7"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem7 to queue.")
	}
	if !queue.Push(account, id, []byte("elem8"), concurrentlib.DataTypeUint256) {
		t.Error("Failed to push elem8 to queue.")
	}

	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem1")) {
		t.Errorf("Expected value = elem1, got %v", string(value))
	}
	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem2")) {
		t.Errorf("Expected value = elem2, got %v", string(value))
	}
	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem3")) {
		t.Errorf("Expected value = elem3, got %v", string(value))
	}
	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem4")) {
		t.Errorf("Expected value = elem4, got %v", string(value))
	}
	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem5")) {
		t.Errorf("Expected value = elem5, got %v", string(value))
	}
	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem6")) {
		t.Errorf("Expected value = elem6, got %v", string(value))
	}
	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem7")) {
		t.Errorf("Expected value = elem7, got %v", string(value))
	}
	if value, ok := queue.Pop(account, id, concurrentlib.DataTypeUint256); !ok || !bytes.Equal(value, []byte("elem8")) {
		t.Errorf("Expected value = elem8, got %v", string(value))
	}

	accessRecords, _ := url.Export()
	t.Log("\n" + formatTransitions(accessRecords))
}

func TestQueueCreateTwoDiffQueuesInSameAccount(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	account := types.Address("contractAddress")
	id1 := "queue1"
	id2 := "queue2"

	url := concurrenturl.NewConcurrentUrl(store)
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	queue.Create(account, "somequeue", concurrentlib.DataTypeUint256)
	_, transitions := url.Export()
	t.Log("\n" + formatTransitions(transitions))
	url.Commit(transitions, []uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	queue1.Create(account, id1, concurrentlib.DataTypeUint256)
	queue2.Create(account, id2, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export()
	ar2, _ := url2.Export()

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

func TestQueueCreateAndPush(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	account := types.Address("contractAddress")
	id1 := "queue1"
	id2 := "queue2"

	url := concurrenturl.NewConcurrentUrl(store)
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	queue.Create(account, id1, concurrentlib.DataTypeUint256)
	_, transitions := url.Export()
	url.Commit(transitions, []uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	queue1.Push(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256)
	queue2.Create(account, id2, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export()
	ar2, _ := url2.Export()

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

func TestQueueCreateAndPop(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	account := types.Address("contractAddress")
	id1 := "queue1"
	id2 := "queue2"

	url := concurrenturl.NewConcurrentUrl(store)
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	queue.Create(account, id1, concurrentlib.DataTypeUint256)
	queue.Push(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256)
	_, transitions := url.Export()
	url.Commit(transitions, []uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	queue1.Pop(account, id1, concurrentlib.DataTypeUint256)
	queue2.Create(account, id2, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export()
	ar2, _ := url2.Export()

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

func TestQueueCreateAndGetSize(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	account := types.Address("contractAddress")
	id1 := "queue1"
	id2 := "queue2"

	url := concurrenturl.NewConcurrentUrl(store)
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	queue.Create(account, id1, concurrentlib.DataTypeUint256)
	_, transitions := url.Export()
	url.Commit(transitions, []uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	queue1.GetSize(account, id1)
	queue2.Create(account, id2, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export()
	ar2, _ := url2.Export()

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

func TestQueuePushAndPush(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	account := types.Address("contractAddress")
	id1 := "queue1"

	url := concurrenturl.NewConcurrentUrl(store)
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	queue.Create(account, id1, concurrentlib.DataTypeUint256)
	_, transitions := url.Export()
	url.Commit(transitions, []uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	queue1.Push(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256)
	queue2.Push(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export()
	ar2, _ := url2.Export()

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

func TestQueuePushAndPop(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	account := types.Address("contractAddress")
	id1 := "queue1"

	url := concurrenturl.NewConcurrentUrl(store)
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	queue.Create(account, id1, concurrentlib.DataTypeUint256)
	queue.Push(account, id1, []byte("initvalue"), concurrentlib.DataTypeUint256)
	_, transitions := url.Export()
	url.Commit(transitions, []uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	queue1.Push(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256)
	queue2.Pop(account, id1, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export()
	ar2, _ := url2.Export()

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

func TestQueuePopAndPop(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	account := types.Address("contractAddress")
	id1 := "queue1"

	url := concurrenturl.NewConcurrentUrl(store)
	queue := concurrentlib.NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	queue.Create(account, id1, concurrentlib.DataTypeUint256)
	queue.Push(account, id1, []byte("initvalue"), concurrentlib.DataTypeUint256)
	_, transitions := url.Export()
	url.Commit(transitions, []uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	queue1 := concurrentlib.NewQueue(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	queue2 := concurrentlib.NewQueue(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	queue1.Pop(account, id1, concurrentlib.DataTypeUint256)
	queue2.Pop(account, id1, concurrentlib.DataTypeUint256)

	ar1, _ := url1.Export()
	ar2, _ := url2.Export()

	t.Log("\n" + formatTransitions(ar1))
	t.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	t.Log(txs)
	t.Log(groups)
	t.Log(flags)
	if len(txs) != 4 {
		t.Fail()
	}
}
