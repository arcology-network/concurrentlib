package concurrentlib_test

import (
	"bytes"
	"fmt"
	"math/big"
	"testing"

	ethcommon "github.com/arcology/3rd-party/eth/common"
	"github.com/arcology/common-lib/types"
	"github.com/arcology/concurrentlib"
	"github.com/arcology/concurrenturl"
	urlcommon "github.com/arcology/concurrenturl/common"
	urltype "github.com/arcology/concurrenturl/type"
	commutative "github.com/arcology/concurrenturl/type/commutative"
	noncommutative "github.com/arcology/concurrenturl/type/noncommutative"
)

type txContext struct {
	height *big.Int
	index  uint32
}

func (context *txContext) GetHeight() *big.Int {
	return context.height
}

func (context *txContext) GetIndex() uint32 {
	return context.index
}

func formatValue(value interface{}) string {
	switch value.(type) {
	case *commutative.Meta:
		meta := value.(*commutative.Meta)
		var str string
		str += "{"
		for i, k := range meta.GetKeys() {
			str += k
			if i != len(meta.GetKeys())-1 {
				str += ", "
			}
		}
		str += "}"
		if len(meta.Added()) != 0 {
			str += " + {"
			for i, k := range meta.Added() {
				str += k
				if i != len(meta.Added())-1 {
					str += ", "
				}
			}
			str += "}"
		}
		if len(meta.Removed()) != 0 {
			str += " - {"
			for i, k := range meta.Removed() {
				str += k
				if i != len(meta.Removed())-1 {
					str += ", "
				}
			}
			str += "}"
		}
		return str
	case *noncommutative.Int64:
		return fmt.Sprintf(" = %v", int64(*value.(*noncommutative.Int64)))
	case *noncommutative.Bytes:
		return fmt.Sprintf(" = %v", []byte(*value.(*noncommutative.Bytes)))
	case *noncommutative.String:
		return fmt.Sprintf(" = %v", string(*value.(*noncommutative.String)))
	}
	return ""
}

func formatTransitions(transitions []urlcommon.UnivalueInterface) string {
	var str string
	for _, t := range transitions {
		str += fmt.Sprintf("[%v:%v,%v,%v,%v]%s%s\n", t.(*urltype.Univalue).GetTx(), t.(*urltype.Univalue).GetReads(), t.(*urltype.Univalue).GetWrites(), t.(*urltype.Univalue).AddOrDelete, t.(*urltype.Univalue).IsComposite(), t.(*urltype.Univalue).GetPath(), formatValue(t.(*urltype.Univalue).GetValue()))
	}
	return str
}

func TestFLABasic(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.ACCOUNT_BASE_URL)
	store.Save(urlcommon.ACCOUNT_BASE_URL, meta)
	url := concurrenturl.NewConcurrentUrl(store)

	account := types.Address("contractAddress")
	id := "arrayID"
	fla := concurrentlib.NewFixedLengthArray(url, &txContext{index: 1})
	if !fla.Create(account, id, concurrentlib.DataTypeUint256, 2) {
		t.Error("Failed to create array.")
	}

	if fla.Create(account, id, concurrentlib.DataTypeUint256, 2) {
		t.Error("Create an array twice.")
	}

	size := fla.GetSize(account, id)
	if size != 2 {
		t.Errorf("Expected size = 2, got %v.", size)
	}

	elem0, ok := fla.GetElem(account, id, 0, concurrentlib.DataTypeAddress)
	if ok || elem0 != nil {
		t.Error("Got unexpected element with wrong element type.")
	}

	elem0, ok = fla.GetElem(account, id, 0, concurrentlib.DataTypeUint256)
	if !ok || !bytes.Equal(elem0, ethcommon.Hash{}.Bytes()) {
		t.Errorf("Expected elem0 = %v, got %v.", ethcommon.Hash{}.Bytes(), elem0)
	}

	elem1, ok := fla.GetElem(account, id, 1, concurrentlib.DataTypeUint256)
	if !ok || !bytes.Equal(elem1, ethcommon.Hash{}.Bytes()) {
		t.Errorf("Expected elem1 = %v, got %v.", ethcommon.Hash{}.Bytes(), elem1)
	}

	elem2, ok := fla.GetElem(account, id, 2, concurrentlib.DataTypeUint256)
	if ok || elem2 != nil {
		t.Error("Got unexpected element with wrong index.")
	}

	if !fla.SetElem(account, id, 0, ethcommon.BytesToHash([]byte{1}).Bytes(), concurrentlib.DataTypeUint256) {
		t.Error("Failed to set element.")
	}

	elem0, ok = fla.GetElem(account, id, 0, concurrentlib.DataTypeUint256)
	if !ok || !bytes.Equal(elem0, ethcommon.BytesToHash([]byte{1}).Bytes()) {
		t.Errorf("Expected elem0 = %v, got %v.", ethcommon.BytesToHash([]byte{1}).Bytes(), elem0)
	}

	_, transitions := fla.Collect()
	t.Log("\n" + formatTransitions(transitions))
}
