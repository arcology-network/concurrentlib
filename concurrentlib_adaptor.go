package concurrentlib

import (
	"math/big"

	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrenturl"
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

type ConcurrentlibAdaptor struct {
	url       *concurrenturl.ConcurrentUrl
	array     *FixedLengthArray
	queue     *Queue
	sortedmap *SortedMap
}

func NewConcurrentlibAdaptor(url *concurrenturl.ConcurrentUrl) *ConcurrentlibAdaptor {
	return &ConcurrentlibAdaptor{
		array:     NewFixedLengthArray(url, &txContext{index: 1}),
		queue:     NewQueue(url, &txContext{height: new(big.Int).SetUint64(100), index: 1}),
		sortedmap: NewSortedMap(url, &txContext{index: 1}),
	}
}

func (adaptor *ConcurrentlibAdaptor) GetArrayValue(account types.Address, id string, index int) []byte {
	elemType := adaptor.array.getElementType(account, id)
	if data, ok := adaptor.array.GetElem(account, id, index, elemType); ok {
		return data
	} else {
		return nil
	}
}

func (adaptor *ConcurrentlibAdaptor) GetMapValue(account types.Address, id string, key []byte) []byte {
	keyType := adaptor.sortedmap.getKeyType(account, id)
	valueType := adaptor.sortedmap.getValueType(account, id)

	if data, ok := adaptor.sortedmap.GetValue(account, id, key, keyType, valueType); ok {
		return data
	} else {
		return nil
	}
}
func (adaptor *ConcurrentlibAdaptor) GetQueueValue(account types.Address, id string, key []byte) []byte {
	keyType := DataTypeBytes
	valueType := adaptor.queue.sm.getValueType(account, id)
	if data, ok := adaptor.queue.sm.GetValue(account, id, key, keyType, valueType); ok {
		return data
	} else {
		return nil
	}
}
