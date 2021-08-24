package concurrentlib

import (
	"encoding/binary"

	"github.com/arcology/common-lib/types"
	"github.com/arcology/concurrenturl"
	urlcommon "github.com/arcology/concurrenturl/common"
)

type Queue struct {
	url     *concurrenturl.ConcurrentUrl
	context TxContext
	counter uint32
	sm      *SortedMap
}

func NewQueue(url *concurrenturl.ConcurrentUrl, context TxContext) *Queue {
	sm := NewSortedMap(url, context)
	sm.containerType = ContainerTypeQueue
	return &Queue{
		url:     url,
		context: context,
		sm:      sm,
	}
}

func (queue *Queue) Create(account types.Address, id string, elemType int) bool {
	return queue.sm.create(account, id, DataTypeBytes, elemType)
}

func (queue *Queue) GetSize(account types.Address, id string) int {
	return queue.sm.GetSize(account, id)
}

func (queue *Queue) Push(account types.Address, id string, value []byte, elemType int) bool {
	ok := queue.sm.SetValue(account, id, []byte(queue.getStoredKey()), value, DataTypeBytes, elemType)
	queue.counter++
	return ok
}

func (queue *Queue) Pop(account types.Address, id string, elemType int) ([]byte, bool) {
	if !queue.sm.typeCheckPassed(account, id, DataTypeBytes, elemType) {
		return nil, false
	}

	keys, ok := queue.sm.getKeys(account, id)
	if !ok || len(keys) == 0 {
		return nil, false
	}

	elem, ok := queue.sm.GetValue(account, id, keys[0], DataTypeBytes, elemType)
	if !ok {
		return nil, false
	}

	if !queue.sm.SetValue(account, id, keys[0], nil, DataTypeBytes, elemType) {
		return nil, false
	}
	// Tricky! Update meta data.
	queue.sm.getSize(account, id)
	return elem, true
}

func (queue *Queue) Collect() ([]urlcommon.UnivalueInterface, []urlcommon.UnivalueInterface) {
	return queue.url.Export()
}

func (queue *Queue) getStoredKey() string {
	b := make([]byte, 8, 16)
	binary.BigEndian.PutUint64(b, queue.context.GetHeight().Uint64())

	bi := make([]byte, 4)
	binary.BigEndian.PutUint32(bi, queue.context.GetIndex())
	b = append(b, bi...)

	bc := make([]byte, 4)
	binary.BigEndian.PutUint32(bc, queue.counter)
	b = append(b, bc...)

	return string(b)
}
