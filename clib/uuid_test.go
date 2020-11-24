package clib

import (
	"testing"
)

func TestUUIDGen(t *testing.T) {
	sha256 := UUIDGen([]byte("123"), 1, []byte("456"), []byte{7, 8, 9}, []byte("abc"))
	t.Log(sha256)
}
