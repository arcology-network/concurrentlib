package concurrentlib_test

import (
	"bytes"
	"fmt"
	"math/big"
	"testing"

	ethcommon "github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrentlib"
	"github.com/HPISTechnologies/concurrenturl/v2"
	urlcommon "github.com/HPISTechnologies/concurrenturl/v2/common"
	urltype "github.com/HPISTechnologies/concurrenturl/v2/type"
	commutative "github.com/HPISTechnologies/concurrenturl/v2/type/commutative"
	noncommutative "github.com/HPISTechnologies/concurrenturl/v2/type/noncommutative"
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
		if len(meta.GetAdded()) != 0 {
			str += " + {"
			for i, k := range meta.GetAdded() {
				str += k
				if i != len(meta.GetAdded())-1 {
					str += ", "
				}
			}
			str += "}"
		}
		if len(meta.GetRemoved()) != 0 {
			str += " - {"
			for i, k := range meta.GetRemoved() {
				str += k
				if i != len(meta.GetRemoved())-1 {
					str += ", "
				}
			}
			str += "}"
		}
		return str
	case *noncommutative.Int64:
		return fmt.Sprintf(" = %v", int64(*value.(*noncommutative.Int64)))
	case *noncommutative.Bytes:
		return fmt.Sprintf(" = %v", value.(*noncommutative.Bytes).Data())
	case *noncommutative.String:
		return fmt.Sprintf(" = %v", string(*value.(*noncommutative.String)))
	}
	return ""
}

func formatTransitions(transitions []urlcommon.UnivalueInterface) string {
	var str string
	for _, t := range transitions {
		str += fmt.Sprintf("[%v:%v,%v,%v,%v]%s%s\n", t.(*urltype.Univalue).GetTx(), t.(*urltype.Univalue).Reads(), t.(*urltype.Univalue).Writes(), t.(*urltype.Univalue).Preexist(), t.(*urltype.Univalue).Composite(), t.(*urltype.Univalue).GetPath(), formatValue(t.(*urltype.Univalue).Value()))
	}
	return str
}

func TestFLABasic(t *testing.T) {
	store := urlcommon.NewDataStore()
	meta, _ := commutative.NewMeta(urlcommon.NewPlatform().Eth10Account())
	store.Save(urlcommon.NewPlatform().Eth10Account(), meta)
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

	_, transitions := url.Export(true)
	t.Log("\n" + formatTransitions(transitions))
}
