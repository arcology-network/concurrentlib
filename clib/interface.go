package clib

import (
	"github.com/HPISTechnologies/common-lib/types"
)

type Snapshot interface {
	IsArrayExist(sc types.Address, id string) bool
	GetArraySize(sc types.Address, id string) int
	GetArrayType(sc types.Address, id string) int
	GetArrayElem(sc types.Address, id string, index int) ([]byte, bool)

	CreateHashMap(sc types.Address, id string, keyType, valueType int) bool
	GetHashMapValue(sc types.Address, id string, key string, keyType, valueType int) ([]byte, types.Version)
	GetHashMapType(sc types.Address, id string) (int, int)
	IsHashMapKeyExist(sc types.Address, id string, key string) bool

	IsDeferCallExist(sc types.Address, id string) bool
	GetDeferCallSignature(sc types.Address, id string) string

	IsQueueExist(sc types.Address, id string) bool
	GetQueueSize(sc types.Address, id string) int
	GetQueueType(sc types.Address, id string) int
	GetQueueElem(sc types.Address, id string, index int) ([]byte, bool)
	GetQueueElemAll(sc types.Address, id string) ([][]byte, bool)

	Commit(writes map[types.Address]*types.WriteSet) bool
	Show()
	CreateTransientSnapshot() Snapshot
	CreateTransientSnapshotForApc() Snapshot

	Empty()
}
