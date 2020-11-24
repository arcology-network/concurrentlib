package clib

import (
	"github.com/HPISTechnologies/common-lib/types"
)

type newQueue struct {
	address  types.Address
	id       string
	elemType int
}

type ConcurrentQueue struct {
	euID         uint16
	snapshot     Snapshot
	readSet      map[types.Address][]types.QueueRead
	writeSet     map[types.Address][]types.QueueWrite
	headPos      map[types.Address]map[string]int
	newlyCreated []newQueue
	newlyPushed  map[types.Address]map[string][][]byte
}

func NewConcurrentQueue(euID uint16, snapshot Snapshot) *ConcurrentQueue {
	return &ConcurrentQueue{
		euID:         euID,
		snapshot:     snapshot,
		readSet:      make(map[types.Address][]types.QueueRead),
		writeSet:     make(map[types.Address][]types.QueueWrite),
		headPos:      make(map[types.Address]map[string]int),
		newlyCreated: make([]newQueue, 0, 8),
		newlyPushed:  make(map[types.Address]map[string][][]byte),
	}
}

func (queue *ConcurrentQueue) SetSnapShot(snapshot Snapshot) {
	queue.snapshot = snapshot
}

func (queue *ConcurrentQueue) Create(sc types.Address, id string, elemType int) bool {
	if queue.snapshot.IsQueueExist(sc, id) {
		return false
	}

	// Check the write set to see if the same queue has been created.
	if qws, ok := queue.writeSet[sc]; ok {
		for _, qw := range qws {
			if qw.Op == types.QueueOpCreate && qw.ID == id {
				return false
			}
		}
	}

	queue.newlyCreated = append(queue.newlyCreated, newQueue{sc, id, elemType})
	qw := types.QueueWrite{
		ID:    id,
		Op:    types.QueueOpCreate,
		Value: []byte{byte(elemType)},
	}
	queue.writeSet[sc] = append(queue.writeSet[sc], qw)
	return true
}

func (queue *ConcurrentQueue) GetSize(sc types.Address, id string) int {
	size := queue.getQueueSize(sc, id)
	if size != -1 {
		queue.readSet[sc] = append(queue.readSet[sc], types.QueueRead{
			ID:  id,
			Pos: types.QueuePosSize,
		})
	}

	currHead := queue.getCurrHead(sc, id)
	return size - currHead
}

func (queue *ConcurrentQueue) Push(sc types.Address, id string, value []byte, elemType int) bool {
	if queue.getQueueType(sc, id) != elemType {
		return false
	}

	qw := types.QueueWrite{
		ID:    id,
		Pos:   types.QueuePosTail,
		Op:    types.QueueOpPush,
		Value: value,
	}
	queue.writeSet[sc] = append(queue.writeSet[sc], qw)

	if _, ok := queue.newlyPushed[sc]; !ok {
		queue.newlyPushed[sc] = make(map[string][][]byte)
	}
	queue.newlyPushed[sc][id] = append(queue.newlyPushed[sc][id], value)
	return true
}

func (queue *ConcurrentQueue) Pop(sc types.Address, id string, elemType int) ([]byte, bool) {
	if queue.getQueueType(sc, id) != elemType {
		return nil, false
	}

	currPos := queue.getCurrHead(sc, id)
	value, ok := queue.getQueueElem(sc, id, currPos)
	if ok {
		// Update head position.
		if _, ok := queue.headPos[sc]; !ok {
			queue.headPos[sc] = make(map[string]int)
		}
		queue.headPos[sc][id] = currPos + 1

		qw := types.QueueWrite{
			ID:  id,
			Pos: types.QueuePosHead,
			Op:  types.QueueOpPop,
		}
		queue.writeSet[sc] = append(queue.writeSet[sc], qw)
	}
	return value, ok
}

func (queue *ConcurrentQueue) Collect() (map[types.Address][]types.QueueRead, map[types.Address][]types.QueueWrite) {
	rs, ws := queue.readSet, queue.writeSet
	queue.readSet = make(map[types.Address][]types.QueueRead)
	queue.writeSet = make(map[types.Address][]types.QueueWrite)
	queue.headPos = make(map[types.Address]map[string]int)
	queue.newlyCreated = queue.newlyCreated[:0]
	queue.newlyPushed = make(map[types.Address]map[string][][]byte)
	return rs, ws
}

func (queue *ConcurrentQueue) getQueueType(sc types.Address, id string) int {
	if t := queue.snapshot.GetQueueType(sc, id); t != DataTypeInvalid {
		return t
	}
	for _, entry := range queue.newlyCreated {
		if sc == entry.address && id == entry.id {
			return entry.elemType
		}
	}
	return DataTypeInvalid
}

func (queue *ConcurrentQueue) getQueueSize(sc types.Address, id string) int {
	sizeCommitted := queue.snapshot.GetQueueSize(sc, id)
	if sizeCommitted == -1 {
		isExist := false
		for _, entry := range queue.newlyCreated {
			if sc == entry.address && id == entry.id {
				isExist = true
				break
			}
		}
		if !isExist {
			return -1
		}
		sizeCommitted = 0
	}

	sizeUncommitted := 0
	if _, ok := queue.newlyPushed[sc]; ok {
		if _, ok := queue.newlyPushed[sc][id]; ok {
			sizeUncommitted = len(queue.newlyPushed[sc][id])
		}
	}

	return sizeCommitted + sizeUncommitted
}

func (queue *ConcurrentQueue) getQueueElem(sc types.Address, id string, index int) ([]byte, bool) {
	totalSize := queue.getQueueSize(sc, id)
	if index >= totalSize {
		return nil, false
	}

	committedSize := queue.snapshot.GetQueueSize(sc, id)
	if index < committedSize {
		return queue.snapshot.GetQueueElem(sc, id, index)
	}

	if committedSize == -1 {
		committedSize = 0
	}
	return queue.newlyPushed[sc][id][index-committedSize], true
}

func (queue *ConcurrentQueue) getCurrHead(sc types.Address, id string) int {
	currHead := 0
	if _, ok := queue.headPos[sc]; ok {
		if pos, ok := queue.headPos[sc][id]; ok {
			currHead = pos
		}
	}
	return currHead
}
