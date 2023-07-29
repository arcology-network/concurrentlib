module github.com/arcology-network/concurrentlib

go 1.19

replace github.com/arcology-network/common-lib => ../common-lib/

replace github.com/arcology-network/concurrenturl => ../concurrenturl/

replace github.com/arcology-network/urlarbitrator-engine => ../urlarbitrator-engine/

replace github.com/arcology-network/evm => ../evm/

require (
	github.com/arcology-network/3rd-party v0.0.0-20221110004651-3ae5c3009a22
	github.com/arcology-network/common-lib v0.0.0-00010101000000-000000000000
	github.com/arcology-network/concurrenturl v0.0.0-00010101000000-000000000000
	github.com/arcology-network/urlarbitrator-engine v0.0.0-00010101000000-000000000000
// github.com/arcology-network/common-lib v0.0.0-20221124074600-09b0a62272cb
// github.com/arcology-network/concurrenturl v1.7.1
// github.com/arcology-network/urlarbitrator-engine v1.7.1
)

require (
	github.com/arcology-network/evm v0.0.0-00010101000000-000000000000 // indirect
	github.com/btcsuite/btcd/btcec/v2 v2.2.0 // indirect
	github.com/decred/dcrd/dcrec/secp256k1/v4 v4.0.1 // indirect
	github.com/holiman/uint256 v1.2.2-0.20230321075855-87b91420868c // indirect
)

require (
	github.com/AndreasBriese/bbloom v0.0.0-20190825152654-46b345b51c96 // indirect
	// github.com/arcology-network/evm v0.0.0-20221110011616-1cdc0ab27c8e // indirect
	github.com/btcsuite/btcd v0.20.1-beta // indirect
	github.com/cespare/xxhash v1.1.0 // indirect
	github.com/dgraph-io/badger v1.6.2 // indirect
	github.com/dgraph-io/ristretto v0.0.2 // indirect
	github.com/dustin/go-humanize v1.0.0 // indirect
	github.com/elliotchance/orderedmap v1.5.0 // indirect
	github.com/golang/protobuf v1.5.2 // indirect
	github.com/google/uuid v1.3.0 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/spaolacci/murmur3 v1.1.0 // indirect
	golang.org/x/crypto v0.2.0 // indirect
	golang.org/x/exp v0.0.0-20230206171751-46f607a40771 // indirect
	golang.org/x/net v0.8.0 // indirect
	golang.org/x/sys v0.6.0 // indirect
	google.golang.org/protobuf v1.28.1 // indirect
)
