package clib

import (
	"testing"

	"github.com/HPISTechnologies/common-lib/types"
)

var (
	scAddr    = types.Address("address")
	queueID   = "id"
	elemType  = DataTypeUint256
	wrongType = DataTypeBytes
)

func TestCreateQueueTwiceShouldFail(t *testing.T) {
	snapshot := NewSnapshot()
	queue := NewConcurrentQueue(0x0101, snapshot)

	ok := queue.Create(scAddr, queueID, elemType)
	if !ok {
		t.Error("Failed to create queue")
		return
	}

	ok = queue.Create(scAddr, queueID, elemType)
	if ok {
		t.Error("Create queue twice before commit should fail")
		return
	}

	_, qw := queue.Collect()
	snapshot.Commit(qwToWriteSet(qw))

	ok = queue.Create(scAddr, queueID, elemType)
	if ok {
		t.Error("Create queue twice after commit should fail")
		return
	}
}

func TestPushPopWrongTypeShouldFail(t *testing.T) {
	snapshot := NewSnapshot()
	queue := NewConcurrentQueue(0x0101, snapshot)

	ok := queue.Create(scAddr, queueID, elemType)
	if !ok {
		t.Error("Failed to create queue")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{1}, elemType)
	if !ok {
		t.Error("Failed to push data {1} to queue")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{2}, wrongType)
	if ok {
		t.Error("Push data of wrong type before commit should fail")
		return
	}

	_, ok = queue.Pop(scAddr, queueID, wrongType)
	if ok {
		t.Error("Pop data of wrong type before commit should fail")
		return
	}

	_, qw := queue.Collect()
	snapshot.Commit(qwToWriteSet(qw))

	ok = queue.Push(scAddr, queueID, []byte{2}, wrongType)
	if ok {
		t.Error("Push data of wrong type after commit should fail")
		return
	}

	_, ok = queue.Pop(scAddr, queueID, wrongType)
	if ok {
		t.Error("Pop data of wrong type after commit should fail")
		return
	}
}

func TestPopEmptyQueueShouldFail(t *testing.T) {
	snapshot := NewSnapshot()
	queue := NewConcurrentQueue(0x0101, snapshot)

	ok := queue.Create(scAddr, queueID, elemType)
	if !ok {
		t.Error("Failed to create queue")
		return
	}

	_, ok = queue.Pop(scAddr, queueID, elemType)
	if ok {
		t.Error("Pop from empty queue should fail")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{1}, elemType)
	if !ok {
		t.Error("Failed to push data {1} to queue")
		return
	}

	_, ok = queue.Pop(scAddr, queueID, elemType)
	if !ok {
		t.Error("Failed to pop data {1} from queue")
		return
	}

	_, ok = queue.Pop(scAddr, queueID, elemType)
	if ok {
		t.Error("Pop from empty queue should fail")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{2}, elemType)
	if !ok {
		t.Error("Failed to push data {2} to queue")
		return
	}

	_, qw := queue.Collect()
	snapshot.Commit(qwToWriteSet(qw))

	_, ok = queue.Pop(scAddr, queueID, elemType)
	if !ok {
		t.Error("Failed to pop data {2} from queue")
		return
	}

	_, ok = queue.Pop(scAddr, queueID, elemType)
	if ok {
		t.Error("Pop from empty queue should fail")
		return
	}
}

func TestPushAndPopOnEmptyQueue(t *testing.T) {
	snapshot := NewSnapshot()
	queue := NewConcurrentQueue(0x0101, snapshot)

	ok := queue.Create(scAddr, queueID, elemType)
	if !ok {
		t.Error("Failed to create queue")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{1}, elemType)
	if !ok {
		t.Error("Failed to push data {1} to queue")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{2}, elemType)
	if !ok {
		t.Error("Failed to push data {2} to queue")
		return
	}

	size := queue.GetSize(scAddr, queueID)
	if size != 2 {
		t.Errorf("GetSize returns wrong size, expected = 2, got = %v", size)
		return
	}

	v, ok := queue.Pop(scAddr, queueID, elemType)
	if !ok || v == nil || len(v) != 1 || v[0] != 1 {
		t.Error("Failed to pop data {1} from queue")
		return
	}

	size = queue.GetSize(scAddr, queueID)
	if size != 1 {
		t.Errorf("GetSize returns wrong size, expected = 1, got = %v", size)
		return
	}

	v, ok = queue.Pop(scAddr, queueID, elemType)
	if !ok || v == nil || len(v) != 1 || v[0] != 2 {
		t.Error("Failed to pop data {2} from queue")
		return
	}

	size = queue.GetSize(scAddr, queueID)
	if size != 0 {
		t.Errorf("GetSize returns wrong size, expected = 0, got = %v", size)
		return
	}
}

func TestPushAndPopOnNonEmptyQueue(t *testing.T) {
	snapshot := NewSnapshot()
	queue := NewConcurrentQueue(0x0101, snapshot)

	ok := queue.Create(scAddr, queueID, elemType)
	if !ok {
		t.Error("Failed to create queue")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{1}, elemType)
	if !ok {
		t.Error("Failed to push data {1} to queue")
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{2}, elemType)
	if !ok {
		t.Error("Failed to push data {2} to queue")
		return
	}

	_, qw := queue.Collect()
	snapshot.Commit(qwToWriteSet(qw))

	size := queue.GetSize(scAddr, queueID)
	if size != 2 {
		t.Errorf("GetSize returns wrong size, expected = 2, got = %v", size)
		return
	}

	v, ok := queue.Pop(scAddr, queueID, elemType)
	if !ok || v == nil || len(v) != 1 || v[0] != 1 {
		t.Error("Failed to pop data {1} from queue")
		return
	}

	size = queue.GetSize(scAddr, queueID)
	if size != 1 {
		t.Errorf("GetSize returns wrong size, expected = 1, got = %v", size)
		return
	}

	ok = queue.Push(scAddr, queueID, []byte{3}, elemType)
	if !ok {
		t.Error("Failed to push data {3} to queue")
		return
	}

	size = queue.GetSize(scAddr, queueID)
	if size != 2 {
		t.Errorf("GetSize returns wrong size, expected = 2, got = %v", size)
		return
	}

	v, ok = queue.Pop(scAddr, queueID, elemType)
	if !ok || v == nil || len(v) != 1 || v[0] != 2 {
		t.Error("Failed to pop data {2} from queue")
		return
	}

	size = queue.GetSize(scAddr, queueID)
	if size != 1 {
		t.Errorf("GetSize returns wrong size, expected = 1, got = %v", size)
		return
	}

	v, ok = queue.Pop(scAddr, queueID, elemType)
	if !ok || v == nil || len(v) != 1 || v[0] != 3 {
		t.Error("Failed to pop data {3} from queue")
		return
	}

	_, qw = queue.Collect()
	snapshot.Commit(qwToWriteSet(qw))

	size = queue.GetSize(scAddr, queueID)
	if size != 0 {
		t.Errorf("GetSize returns wrong size, expected 0, got %v", size)
		return
	}
}

func qwToWriteSet(queueWrites map[types.Address][]types.QueueWrite) map[types.Address]*types.WriteSet {
	ws := make(map[types.Address]*types.WriteSet)
	for addr, qws := range queueWrites {
		ws[addr] = &types.WriteSet{
			QueueWrites: qws,
		}
	}
	return ws
}
