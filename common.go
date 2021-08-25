package concurrentlib

import (
	"fmt"
	"math/big"

	"github.com/HPISTechnologies/3rd-party/eth/common"
	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrenturl/v2"
	commutative "github.com/HPISTechnologies/concurrenturl/v2/type/commutative"
	noncommutative "github.com/HPISTechnologies/concurrenturl/v2/type/noncommutative"
)

const (
	DataTypeInvalid = iota
	DataTypeAddress
	DataTypeUint256
	DataTypeBytes
)

const (
	ContainerTypeInvalid = iota
	ContainerTypeFLA
	ContainerTypeSM
	ContainerTypeQueue
)

const (
	ContainerSizeInvalid = -1
)

type TxContext interface {
	GetHeight() *big.Int
	GetIndex() uint32
}

func getDefaultValue(dataType int) ([]byte, bool) {
	switch dataType {
	case DataTypeAddress:
		return common.Address{}.Bytes(), true
	case DataTypeUint256:
		return common.Hash{}.Bytes(), true
	default:
		return nil, true
	}
}

func getAccountRootPath(url *concurrenturl.ConcurrentUrl, account types.Address) string {
	return url.Platform.Eth10Account() + string(account) + "/"
}

func getStorageRootPath(url *concurrenturl.ConcurrentUrl, account types.Address) string {
	return getAccountRootPath(url, account) + "storage/containers/"
}

func getDeferRootPath(url *concurrenturl.ConcurrentUrl, account types.Address) string {
	return getAccountRootPath(url, account) + "defer/"
}

func getDeferCallPath(url *concurrenturl.ConcurrentUrl, account types.Address, id string) string {
	return getDeferRootPath(url, account) + id
}

func getContainerRootPath(url *concurrenturl.ConcurrentUrl, account types.Address, id string) string {
	return getStorageRootPath(url, account) + id + "/"
}

func getContainerTypeRootPath(url *concurrenturl.ConcurrentUrl, account types.Address) string {
	return getStorageRootPath(url, account) + "!/"
}

func getContainerTypePath(url *concurrenturl.ConcurrentUrl, account types.Address, id string) string {
	return getContainerTypeRootPath(url, account) + id
}

func getSizePath(url *concurrenturl.ConcurrentUrl, account types.Address, id string) string {
	return getContainerRootPath(url, account, id) + "#"
}

func getKeyTypePath(url *concurrenturl.ConcurrentUrl, account types.Address, id string) string {
	return getContainerRootPath(url, account, id) + "!"
}

func getValueTypePath(url *concurrenturl.ConcurrentUrl, account types.Address, id string) string {
	return getContainerRootPath(url, account, id) + "@"
}

func getValuePath(url *concurrenturl.ConcurrentUrl, account types.Address, id string, key interface{}) string {
	return fmt.Sprintf("%s%v", getContainerRootPath(url, account, id), key)
}

func getContainerType(url *concurrenturl.ConcurrentUrl, account types.Address, id string, txIndex uint32) int {
	if value, err := url.Read(txIndex, getContainerTypePath(url, account, id)); err != nil || value == nil {
		return ContainerTypeInvalid
	} else {
		return int(*value.(*noncommutative.Int64))
	}
}

func makeStorageRootPath(url *concurrenturl.ConcurrentUrl, account types.Address, txIndex uint32) bool {
	accountRoot := getAccountRootPath(url, account)
	if value, err := url.TryRead(txIndex, accountRoot); err != nil {
		return false
	} else if value == nil { // The account didn't exist.
		if err := url.Preload(txIndex, url.Platform.Eth10(), string(account)); err != nil {
			return false
		}
		// if err := url.Initialize(url.Platform.Eth10(), string(account)); err != nil {
		// 	return false
		// }
	}

	// storageRoot := getStorageRootPath(url, account)
	// if value, err := url.Read(txIndex, storageRoot); err != nil {
	// 	return false
	// } else if value == nil { // No containers in this account.
	// 	if path, err := noncommutative.NewMeta(storageRoot); err != nil {
	// 		return false
	// 	} else if err := url.Write(txIndex, storageRoot, path); err != nil {
	// 		return false
	// 	}

	// 	containerTypeRoot := getContainerTypeRootPath(url, account)
	// 	if path, err := noncommutative.NewMeta(containerTypeRoot); err != nil {
	// 		return false
	// 	} else if err := url.Write(txIndex, containerTypeRoot, path); err != nil {
	// 		return false
	// 	}
	// }
	return true
}

func makeContainerRootPath(url *concurrenturl.ConcurrentUrl, account types.Address, id string, txIndex uint32) bool {
	containerRoot := getContainerRootPath(url, account, id)
	if value, err := url.TryRead(txIndex, containerRoot); err != nil || value != nil {
		return false
	}

	if path, err := commutative.NewMeta(containerRoot); err != nil {
		return false
	} else if err := url.Write(txIndex, containerRoot, path); err != nil {
		return false
	}
	return true
}
