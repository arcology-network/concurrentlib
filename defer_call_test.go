package concurrentlib_test

import (
	"testing"

	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrentlib"
	"github.com/HPISTechnologies/concurrenturl"
	urlcommon "github.com/HPISTechnologies/concurrenturl/common"
	commutative "github.com/HPISTechnologies/concurrenturl/type/commutative"
)

func TestDeferBasic(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	id := "deferID"
	sig := "defer(string)"
	dc := concurrentlib.NewDeferCall(url, &txContext{index: 1})
	if !dc.Create(account, id, sig) {
		t.Fail()
	}

	if dc.Create(account, id, sig) {
		t.Fail()
	}

	accesses, transitions := url.Export()
	t.Log("\n" + formatTransitions(accesses))
	t.Log("\n" + formatTransitions(transitions))

	url.Commit(transitions, []uint32{1})
	url = concurrenturl.NewConcurrentUrl(store)
	dc = concurrentlib.NewDeferCall(url, &txContext{index: 2})
	if !dc.IsExist(account, id) {
		t.Fail()
	}
	if v := dc.GetSignature(account, id); v != sig {
		t.Fail()
	}
}
