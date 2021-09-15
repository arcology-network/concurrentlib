module github.com/arcology-network/concurrentlib

go 1.13

require (
	github.com/arcology-network/3rd-party v0.9.2-0.20210626004852-924da2642860
	github.com/arcology-network/common-lib v0.9.2-0.20210910023057-e170e0ae1807
	github.com/arcology-network/concurrenturl v0.0.0-20210913021258-ef03ce074986
	github.com/arcology-network/urlarbitrator-engine v0.0.0-20210827014224-c260f4efc3f7
	github.com/google/uuid v1.3.0 // indirect
	golang.org/x/crypto v0.0.0-20210817164053-32db794688a5 // indirect
)

//replace github.com/arcology-network/concurrenturl => ../concurrenturl/

//replace github.com/arcology-network/common-lib => ../common-lib/

//replace github.com/arcology-network/urlarbitrator-engine => ../urlarbitrator-engine/
