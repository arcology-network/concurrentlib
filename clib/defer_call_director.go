package clib

import (
	"github.com/HPISTechnologies/common-lib/types"
)

type DeferCallDirector struct {
	snapshot     Snapshot
	newlyCreated map[types.Address][]types.DeferCallWrite
}

func NewDeferCallDirector(snapshot Snapshot) *DeferCallDirector {
	return &DeferCallDirector{
		snapshot:     snapshot,
		newlyCreated: make(map[types.Address][]types.DeferCallWrite),
	}
}

func (dcd *DeferCallDirector) SetSnapShot(snapshot Snapshot) {
	dcd.snapshot = snapshot
}

func (dcd *DeferCallDirector) Create(sc types.Address, id, signature string) bool {
	if writes, ok := dcd.newlyCreated[sc]; ok {
		for _, w := range writes {
			if w.DeferID == id {
				return false
			}
		}
	}

	if dcd.snapshot.IsDeferCallExist(sc, id) {
		return false
	}

	dcd.newlyCreated[sc] = append(dcd.newlyCreated[sc], types.DeferCallWrite{
		DeferID:   id,
		Signature: signature,
	})
	return true
}

func (dcd *DeferCallDirector) IsExist(sc types.Address, id string) bool {
	// DeferCall cannot be accessed in the same block after creation.
	return dcd.snapshot.IsDeferCallExist(sc, id)
}

func (dcd *DeferCallDirector) GetSignature(sc types.Address, id string) string {
	// DeferCall cannot be accessed in the same block after creation.
	return dcd.snapshot.GetDeferCallSignature(sc, id)
}

func (dcd *DeferCallDirector) Invoke() {
	panic("not implemented")
}

func (dcd *DeferCallDirector) Collect() map[types.Address][]types.DeferCallWrite {
	dcw := dcd.newlyCreated
	dcd.newlyCreated = make(map[types.Address][]types.DeferCallWrite)
	return dcw
}
