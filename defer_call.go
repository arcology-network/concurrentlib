package concurrentlib

import (
	"github.com/HPISTechnologies/common-lib/types"
	"github.com/HPISTechnologies/concurrenturl"
	noncommutative "github.com/HPISTechnologies/concurrenturl/type/noncommutative"
)

type DeferCall struct {
	url     *concurrenturl.ConcurrentUrl
	context TxContext
}

func NewDeferCall(url *concurrenturl.ConcurrentUrl, context TxContext) *DeferCall {
	return &DeferCall{
		url:     url,
		context: context,
	}
}

func (dc *DeferCall) Create(account types.Address, id, sig string) bool {
	if !makeStorageRootPath(dc.url, account, dc.context.GetIndex()) {
		return false
	}

	if value, err := dc.url.Read(dc.context.GetIndex(), getDeferCallPath(dc.url, account, id)); err != nil {
		return false
	} else if value != nil {
		return false
	} else {
		if err := dc.url.Write(dc.context.GetIndex(), getDeferCallPath(dc.url, account, id), noncommutative.NewString(sig)); err != nil {
			return false
		}
	}
	return true
}

func (dc *DeferCall) IsExist(account types.Address, id string) bool {
	if value, err := dc.url.Read(dc.context.GetIndex(), getDeferCallPath(dc.url, account, id)); err != nil {
		panic(err)
	} else {
		return value != nil
	}
}

func (dc *DeferCall) GetSignature(account types.Address, id string) string {
	if value, err := dc.url.Read(dc.context.GetIndex(), getDeferCallPath(dc.url, account, id)); err != nil {
		panic(err)
	} else if value == nil {
		return ""
	} else {
		return string(*value.(*noncommutative.String))
	}
}
