package concurrentlib_test

import (
	"bytes"
	"math/big"
	"reflect"
	"testing"

	cachedstorage "github.com/arcology-network/common-lib/cachedstorage"
	"github.com/arcology-network/common-lib/types"
	"github.com/arcology-network/concurrentlib"
	"github.com/arcology-network/concurrenturl/v2"
	urlcommon "github.com/arcology-network/concurrenturl/v2/common"
	commutative "github.com/arcology-network/concurrenturl/v2/type/commutative"
)

var (
	account = types.Address("contractAddress")
	id1     = "array1"
)

func TestDynamicArrayPushBackAndPushBackNoConf(t *testing.T) {
	tc := setup(t, []string{})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayPushBackAndPopBackOldConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPopBackOldAndPopBackOldConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPushBackAndPopBackNewConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("someothervalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPopBackOldAndPopBackNewConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("someothervalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPopBackNewAndPopBackNewConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array1.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("somevalue")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("someothervalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPushBackAndPopFrontConf1Elem(t *testing.T) {
	tc := setup(t, []string{"initvalue"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopFront(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPushBackAndPopFrontNoConf2Elem(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopFront(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayPopFrontAndPopBackOldNoConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}
	if elem, err := tc.array2.PopFront(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayPopFrontAndPopBackNewConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.PopFront(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("someothervalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPopFrontAndPopFrontConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.PopFront(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}
	if elem, err := tc.array2.PopFront(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayPopFrontAndGetConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.Get(account, id1, 1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}
	if elem, err := tc.array2.PopFront(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayGetOldAndPushBackNoConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array1.Get(account, id1, 1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayGetNewAndPushBackConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array1.Get(account, id1, 2, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("somevalue")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

// No init values compared to TestDynamicArrayGetNewAndPushBackConf.
func TestDynamicArrayGetNewAndPushBackConf2(t *testing.T) {
	tc := setup(t, nil)

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array1.Get(account, id1, 0, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("somevalue")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

func TestDynamicArrayGetOldAndPopBackOldNoConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.Get(account, id1, 0, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayGetOldAndPopBackNewNoConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1"})

	if elem, err := tc.array1.Get(account, id1, 0, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.PopBack(account, id1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("someothervalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayGetOldAndGetOldNoConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.Get(account, id1, 0, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue1")) {
		t.Fail()
	}
	if elem, err := tc.array2.Get(account, id1, 1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayGetOldAndGetNewNoConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if elem, err := tc.array1.Get(account, id1, 1, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("initvalue2")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.Get(account, id1, 2, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("someothervalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{})
}

func TestDynamicArrayGetNewAndGetNewConf(t *testing.T) {
	tc := setup(t, []string{"initvalue1", "initvalue2"})

	if !tc.array1.PushBack(account, id1, []byte("somevalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array1.Get(account, id1, 2, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("somevalue")) {
		t.Fail()
	}
	if !tc.array2.PushBack(account, id1, []byte("someothervalue"), concurrentlib.DataTypeUint256) {
		t.Fail()
	}
	if elem, err := tc.array2.Get(account, id1, 2, concurrentlib.DataTypeUint256); err != nil || !bytes.Equal(elem, []byte("someothervalue")) {
		t.Fail()
	}

	tc.arbitrate([]uint32{2})
}

type dynamicArrayTestCase struct {
	store  *cachedstorage.DataStore
	url1   *concurrenturl.ConcurrentUrl
	url2   *concurrenturl.ConcurrentUrl
	array1 *concurrentlib.DynamicArray
	array2 *concurrentlib.DynamicArray
	tb     testing.TB
}

func (tc *dynamicArrayTestCase) arbitrate(conflictedTxs []uint32) {
	ar1, _ := tc.url1.Export(true)
	ar2, _ := tc.url2.Export(true)

	tc.tb.Log("\n" + formatTransitions(ar1))
	tc.tb.Log("\n" + formatTransitions(ar2))
	txs, groups, flags := detectConflict(append(ar1, ar2...))
	tc.tb.Log(txs)
	tc.tb.Log(groups)
	tc.tb.Log(flags)
	if !reflect.DeepEqual(txs, conflictedTxs) {
		tc.tb.Fail()
	}
}

func setup(t *testing.T, initValues []string) *dynamicArrayTestCase {
	store := cachedstorage.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Inject(urlcommon.NewPlatform().Eth10Account(), meta)
	account := types.Address("contractAddress")
	id1 := "array1"

	url := concurrenturl.NewConcurrentUrl(store)
	array := concurrentlib.NewDynamicArray(url, &txContext{height: new(big.Int).SetUint64(100), index: 1})
	array.Create(account, id1, concurrentlib.DataTypeUint256)
	for _, v := range initValues {
		array.PushBack(account, id1, []byte(v), concurrentlib.DataTypeUint256)
	}
	_, transitions := url.Export(true)
	url.Import(transitions)
	url.PostImport()
	url.Commit([]uint32{1})

	url1 := concurrenturl.NewConcurrentUrl(store)
	url2 := concurrenturl.NewConcurrentUrl(store)

	array1 := concurrentlib.NewDynamicArray(url1, &txContext{height: new(big.Int).SetUint64(101), index: 1})
	array2 := concurrentlib.NewDynamicArray(url2, &txContext{height: new(big.Int).SetUint64(101), index: 2})

	return &dynamicArrayTestCase{
		store:  store,
		url1:   url1,
		url2:   url2,
		array1: array1,
		array2: array2,
		tb:     t,
	}
}
