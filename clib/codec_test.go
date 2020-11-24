package clib_test

import (
	"testing"

	"github.com/HPISTechnologies/concurrentlib/clib"
)

func TestEncodeDecodeInt(t *testing.T) {
	i := 0x778899aabbccddee
	bs, err := clib.Encode(i)
	if err != nil {
		t.Error("Encode int failed: ", err)
	}

	var ii int
	err = clib.Decode(bs, &ii)
	if err != nil {
		t.Error("Decode int failed: ", err)
	}

	if i != ii {
		t.Error("i != ii, i = ", i, ", ii = ", ii)
	}
}

func BenchmarkEncodeDecodeInt(b *testing.B) {
	for i := 0; i < b.N; i++ {
		i := 1
		bs, err := clib.Encode(i)
		if err != nil {
			b.Error("Encode int failed: ", err)
		}

		var ii int
		err = clib.Decode(bs, &ii)
		if err != nil {
			b.Error("Decode int failed: ", err)
		}

		if i != ii {
			b.Error("i != ii, i = ", i, ", ii = ", ii)
		}
	}
}
