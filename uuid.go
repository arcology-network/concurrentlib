package concurrentlib

import (
	"crypto/sha256"
)

func UUIDGen(origin []byte, nonce uint64, contract []byte, input []byte, txhash, blockhash []byte) []byte {
	// var data []byte
	// data = append(data, txhash...)
	// data = append(data, blockhash...)
	// data = append(data, contract...)
	// data = append(data, origin...)
	// nonceBytes := make([]byte, 8)
	// binary.BigEndian.PutUint64(nonceBytes, nonce)
	// data = append(data, nonceBytes...)
	// data = append(data, input...)
	// ret := sha256.Sum256(data)
	ret := sha256.Sum256(txhash)
	return ret[:]
}
