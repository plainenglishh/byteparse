---
sidebar_position: 1
---

# Datatypes

## Introduction

## Types

### u8
**Description:** An unsigned 8 bit integer. <br/>
**Size:** 1 Byte<br/>
**Encoding:** Native<br/>

### u16
**Description:** An unsigned 16 bit integer. <br/>
**Size:** 2 Bytes<br/>
**Encoding:** Native<br/>

### u32
**Description:** An unsigned 32 bit integer. <br/>
**Size:** 4 Bytes<br/>
**Encoding:** Native<br/>

### i8
**Description:** An signed 8 bit integer. <br/>
**Size:** 1 Byte<br/>
**Encoding:** Native<br/>

### i16
**Description:** An signed 16 bit integer. <br/>
**Size:** 2 Bytes<br/>
**Encoding:** Native<br/>

### i32
**Description:** An signed 32 bit integer. <br/>
**Size:** 4 Bytes<br/>
**Encoding:** Native<br/>

### f32
**Description:** An 32 IEEE 754 floating point. <br/>
**Size:** 4 Bytes<br/>
**Encoding:** Native<br/>

### f64
**Description:** An 32 IEEE 754 floating point. <br/>
**Size:** 8 Bytes<br/>
**Encoding:** Native<br/>

### varint
**Description:** A ProtoBuf [Base 128 Variable-width integer](https://protobuf.dev/programming-guides/encoding/#varints).<br/>
**Size:** 1..10 bytes<br/>
**Encoding:** See https://protobuf.dev/programming-guides/encoding/#varints<br/>

### bool
**Description:** A boolean value (1/0)<br/>
**Size:** 1 Byte<br/>
**Encoding:** Encoded as either a `0` or `1` `u8`<br/>

### null
**Description:** A null byte (0)<br/>
**Size:** 1 Byte<br/>
**Encoding:** Encoded as a `0` `u8`<br/>

### string
**Description:** A raw string<br/>
**Size:** Any<br/>
**Encoding:** String written directly with no further metadata<br/>

### lstring
**Description:** A length-prefixed string<br/>
**Size:** 0..10 + 0..2^64 Bytes<br/>
**Encoding:** String written directly with a `varint` prefixed, denoting length<br/>

### zstring
**Description:** A null terminated string<br/>
**Size:** Any<br/>
**Encoding:** String written directly followed by a null byte<br/>

### array
**Description:** An array of serialisable values<br/>
**Size:** Any<br/>
**Encoding:** Array written directly with no further metadata<br/>

### larray
**Description:** A length-prefixed array of serialisable values<br/>
**Size:** 0..10 + 0..2^64 Bytes<br/>
**Encoding:** Array written directly with a `varint` prefixed, denoting length<br/>

### zarray
**Description:** A null terminated array of serialisable values<br/>
**Size:** Any<br/>
**Encoding:** String written directly followed by a null byte<br/>

### buffer
**Description:** A raw buffer<br/>
**Size:** Any<br/>
**Encoding:** Buffer written directly with no further metadata<br/>

### lbuffer
**Description:** A length-prefixed buffer<br/>
**Size:** 0..10 + 0..2^64 Bytes<br/>
**Encoding:** Buffer written directly with a `varint` prefixed, denoting length<br/>

### zbuffer
**Description:** A null terminated buffer<br/>
**Size:** Any<br/>
**Encoding:** Buffer written directly followed by a null byte<br/>

### vector
**Description:** A 3 or 4-width vector<br/>
**Size:** 12 or 16 Bytes, depending on vector size<br/>
**Encoding:** 3 or 4 `f32`s<br/>

### table
**Description:** A serialisable luau table<br/>
**Size:** Any<br/>
**Encoding:** 
```
has_array = u1
has_dict = u1

if has_array then
    array_length = varint
    ...array_value = any -- (repeated for 1..array_length)
end

if has_dict then
    dict_length = varint
    ... {
        key = any
        value = any
    } -- (repeated for 1..dict_length)
end
```

### any
**Description:** Any serialisable luau value<br/>
**Size:** Any<br/>
**Encoding:** A Type ID followed by a the values<br/>
|Type|Type ID|Encoded As|
|-|-|-|
|nil|0|Nothing|
|boolean|1|`u8`|
|number|2|`f64`|
|vector|3|`vector`|
|string|4|`lstring`|
|buffer|5|`lstring`|
|table|6|`table`|