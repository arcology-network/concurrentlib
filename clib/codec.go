package clib

// Encode v into byte array.
// func Encode(v interface{}) ([]byte, error) {
// 	var buf bytes.Buffer
// 	enc := gob.NewEncoder(&buf)
// 	err := enc.Encode(v)
// 	if err != nil {
// 		return nil, err
// 	}
// 	return buf.Bytes(), nil
// }
func Encode(v interface{}) ([]byte, error) {
	value := v.(int)
	return []byte{
		byte(value >> 56),
		byte((value & 0xff000000000000) >> 48),
		byte((value & 0xff0000000000) >> 40),
		byte((value & 0xff00000000) >> 32),
		byte((value & 0xff000000) >> 24),
		byte((value & 0xff0000) >> 16),
		byte((value & 0xff00) >> 8),
		byte(value & 0xff)}, nil
}

// Decode byte array to v.
// func Decode(bs []byte, v interface{}) error {
// 	dec := gob.NewDecoder(bytes.NewBuffer(bs))
// 	return dec.Decode(v)
// }
func Decode(bs []byte, v interface{}) error {
	*(v.(*int)) =
		(int(bs[0]) << 56) |
			(int(bs[1]) << 48) |
			(int(bs[2]) << 40) |
			(int(bs[3]) << 32) |
			(int(bs[4]) << 24) |
			(int(bs[5]) << 16) |
			(int(bs[6]) << 8) |
			(int(bs[7]))
	return nil
}
