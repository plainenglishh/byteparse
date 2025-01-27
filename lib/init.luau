--[[
    plainenglishh/byteparse v1.0.0
   
    Pure-luau library for serialising and deserialising binary formats.
]]

--[[
    MIT License

    Copyright (c) 2025 plainenglish

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

--!native
--!optimize 2
--!strict
--!nolint LocalShadow

local _BYTEPARSE_VERSION = "v1.0.0";

export type u8 = number;
export type u16 = number;
export type u32 = number;
export type i8 = number;
export type i16 = number;
export type i32 = number;
export type f32 = number;
export type f64 = number;
export type varint = number;

export type Endianness = "le" | "be";

export type Serialisable = boolean | number | string | buffer | vector | nil | SerialisableArray | SerialisableTable;
export type SerialisableArray = {Serialisable};
export type SerialisableTable = {[Serialisable]: Serialisable};

local function warn_vector_lib()
    if type(vector) ~= "table" then
        print(`[byteparse WARN]: expected global 'vector' to be a table, got {type(vector)}`);
        if type(vector) == "function" then
            print(`[byteparse WARN]: this is likely caused by mlua, which sets 'vector' to a function instead of the builtin vector library. either switch runtimes or polyfill 'vector'`);
        end
    end
end

-- NIL terminates zarrays.
local TYPE_IDS = {
    NIL = 0,
    BOOLEAN = 1,
    NUMBER = 2,
    VECTOR = 3,
    STRING = 4,
    BUFFER = 5,
    TABLE = 6,  
};

local TABLE_FLAGS = {
    HAS_ARRAY = 0,
    HAS_DICT = 1,
};

local DEFAULT_EXPANSION_RATE = 1.25;

--[=[
    @interface TableParts
    .array {any}
    .hash {[any]: any}
    .array_size number
    .hash_size number
    @private
    @within byteparse
]=]
type TableParts = {
    array: {any},
    hash: {[any]: any},
    array_size: number,
    hash_size: number,
};

--[=[
    Library root.

    @class byteparse
]=]
local byteparse = {};

--[=[
    Utility function for extracting the hash and array parts from a table.

    @within byteparse
    @private
    @param tbl {[any]: any}
    @return TableParts
]=]
function byteparse.get_table_parts(tbl: {[any]: any})
    local array_part = {};
    local hash_part = {};
    local next_num = 0;

    local hash_size = 0;
    local array_size = 0;

    for k, v in tbl do
        if type(k) == "number" then
            next_num += 1;
            
            if next_num == k then
                array_size += 1;
                array_part[k] = v;
            else
                hash_part[k] = v;
            end
        else
            hash_size += 1;
            hash_part[k] = v;
        end
    end

    return {
        hash = if hash_size ~= 0 then hash_part else nil,
        array = if array_size ~= 0 then array_part else nil,
        hash_size = hash_size,
        array_size = array_size,
    };
end

--[=[
    Removes the first encountered null byte, and all following data, from a buffer.

    @param buf buffer
    @return buffer
]=]
function byteparse.trim_zbuffer(buf: buffer): buffer
    local cursor = 0;
    for i = 1, buffer.len(buf) do
        if buffer.readu8(buf, cursor) == 0 then
            local new_buf = buffer.create(cursor);
            buffer.copy(new_buf, 0, buf, 0, cursor);
            return new_buf;
        end
        cursor += 1;        
    end
    return buf;
end

--[=[
    Removes the first encountered null byte, and all following data, from a string.

    @param str string
    @return string
]=]
function byteparse.trim_zstring(str: string): string
    return string.gsub(str, "%z.+$", "");
end

--[=[
    The byteparse version.

    @within byteparse
    @prop version string
]=]
byteparse.version = _BYTEPARSE_VERSION;

--[=[
    Creates a blank writer instance.

    @param start_size number -- The initial size of the writer buffer.
    @param expansion_rate number? -- Specifies the expansion rate when attempting to write more data than the internal buffer can take.
    @return writer -- The new writer instance.
]=]
function byteparse.writer(start_size: number, expansion_rate: number?)
    warn_vector_lib();

    local expansion_rate = expansion_rate or DEFAULT_EXPANSION_RATE;

    local b = buffer.create(start_size);
    local cursor = 0;
    local written_size = 0;
    local vector_size = 3;
    
    --[=[
        writer instance used to serialise to binary formats.

        @class writer
    ]=]
    local writer = {};

    --[=[
        Resizes the internal buffer to a set amount.

        @within writer
        @param to number -- The new size.
    ]=]
    local function set_capacity(to: number)
        local new_b = buffer.create(to);
        buffer.copy(new_b, 0, b);
        b = new_b;
    end

    --[=[
        Ensures the internal buffer can handle `needed_size` more data by 
        expanding the capacity if necessary.

        Relative to the cursor.

        @within writer
        @param needed_size number -- The size amount needed.
    ]=]
    local function expand(needed_size: number)
        local size = buffer.len(b);
        if cursor + needed_size > size then
            set_capacity((size + needed_size) * expansion_rate);
        end 
    end

    --[=[
        Advances the write cursor by a set amount following a write.
        Sets the written_size accordingly.

        @within writer
        @ignore
        @param by number -- How much to advance the cursor.
    ]=]
    local function advance_write(by: number)
        cursor += by;

        if cursor > written_size then
            written_size = cursor;
        end
    end

    --[=[
        Sets the write cursor to a set position.

        @within writer
        @param to number -- The position to move to.
    ]=]
    local function set_cursor(to: number)
        cursor = to;
    end

    --[=[
        Gets the current cursor position.

        @within writer
        @return number -- The cursor position.
    ]=]
    local function get_cursor()
        return cursor;
    end

    --[=[
        Gets the current written size.

        @within writer
        @return number -- The current written size.
    ]=]
    local function get_size()
        return written_size;
    end

    --[=[
        Returns the internal buffer capacity.

        @within writer
    ]=]
    local function get_capacity()
        return buffer.len(b);
    end

    writer.set_capacity = set_capacity;
    writer.expand = expand;
    writer.set_cursor = set_cursor;
    writer.get_cursor = get_cursor;
    writer.get_capacity = get_capacity;
    writer.get_size = get_size;


    --[=[
        Sets the vector size. The given vector size cannot exceed the VMs
        'LUA_VECTOR_SIZE' size.

        @param to number -- The vector size, must be either 3 or 4.
    ]=]
    function writer.set_vector_size(to: number)
        if to ~= 3 and to ~= 4 then
            error("vector size must be either 3 or 4", 2);
        end

        vector_size = to;
    end

    --[=[
        Returns a buffer containing the written data.

        @return buffer -- The written data.
    ]=]
    function writer.to_buffer(): buffer
        local out_buf = buffer.create(written_size);
        buffer.copy(out_buf, 0, b, 0, written_size);
        return out_buf;
    end

    --[=[
        Returns a string containing the written data.

        @return buffer -- 
    ]=]
    function writer.to_string(): string
        return buffer.tostring(writer.to_buffer());
    end

    --[=[
        Writes an unsigned 8 bit integer. Wraps around if provided a number
        larger than 8 bits.
        
        @param value number -- The u8 value to write.
    ]=]
    function writer.write_u8(value: u8)
        expand(1);
        buffer.writeu8(b, cursor, value);
        advance_write(1);
    end

    --[=[
        Writes an unsigned 16 bit integer. Wraps around if provided a number
        larger than 16 bits.

        @param value number -- The u16 value to write.
    ]=]
    function writer.write_u16(value: u16)
        expand(2);
        buffer.writeu16(b, cursor, value);
        advance_write(2);
    end

    --[=[
        Writes an unsigned 32 bit integer. Wraps around if provided a number
        larger than 32 bits.

        @param value number -- The u32 value to write.
    ]=]
    function writer.write_u32(value: u32) 
        expand(4);
        buffer.writeu32(b, cursor, value);
        advance_write(4);
    end

    --[=[
        Writes an unsigned 8 bit integer. Wraps around if provided a number
        larger than 8 bits.

        @param value number -- The i8 value to write.
    ]=]
    function writer.write_i8(value: i8)
        expand(1);
        buffer.writei8(b, cursor, value);
        advance_write(1);
    end

    --[=[
        Writes an unsigned 16 bit integer. Wraps around if provided a number
        larger than 16 bits.

        @param value number -- The i16 value to write.
    ]=]
    function writer.write_i16(value: i16)
        expand(2);
        buffer.writei16(b, cursor, value);
        advance_write(2);
    end

    --[=[
        Writes an unsigned 32 bit integer. Wraps around if provided a number
        larger than 32 bits.

        @param value number -- The i32 value to write.
    ]=]
    function writer.write_i32(value: i32) 
        expand(4);
        buffer.writei32(b, cursor, value);
        advance_write(4);
    end

    --[=[
        Writes a 32 bit floating point number. Wraps around if provided a number
        larger than 32 bits.

        @param value number -- The f32 value to write.
    ]=]
    function writer.write_f32(value: f32)
        expand(4);
        buffer.writef32(b, cursor, value);
        advance_write(4);
    end

    --[=[
        Writes a 64 bit floating point number.

        @param value number -- The f64 value to write.
    ]=]
    function writer.write_f64(value: f64) 
        expand(8);
        buffer.writef64(b, cursor, value);
        advance_write(8);
    end

    --[=[
        Writes a ProtoBuf [Base 128 Variable-width integer](https://protobuf.dev/programming-guides/encoding/#varints).
    
        @param value number -- The varint to write.
    ]=]
    function writer.write_varint(value: varint) 
        local n = value;

        while n >= 0x80 do
            writer.write_u8(bit32.bor(0b1000_0000, n));
            n = bit32.rshift(n, 7);
        end
        
        writer.write_u8(n);
    end

    --[=[
        Writes a boolean.

        @param value boolean -- The boolean to write.
    ]=]
    function writer.write_bool(value: boolean)
        writer.write_u8(if value then 1 else 0);
    end

    --[=[
        Writes a null byte.
    ]=]
    function writer.write_null()
        writer.write_u8(0);
    end

    --[=[
        Writes a string without a prefixed length, optionally trimmed to a 
        maximum size.

        Note: You should ensure the binary format has a way of encoding the
        strings size, as this function writes the string raw and doesn't write
        any data a reader can use to determine the size.

        @param value string -- The string to write.
        @param size number? -- The maximum size of the string.
    ]=]
    function writer.write_string(value: string, size: number?)
        local size = size or #value;

        expand(size);
        buffer.writestring(b, cursor, value, size);
        advance_write(size);
    end

    --[=[
        Writes a length prefixed string.

        @param value string -- The string to write.
        @param size number? -- The maximum size of the string.
    ]=]
    function writer.write_lstring(value: string, size: number?)
        local size = size or #value;
        writer.write_varint(size);
        writer.write_string(value, size);
    end

    --[=[
        Writes a null terminated (C Style) string. 
        
        :::warning
        This function doesn't check whether the passed value is null-safe, and
        will write the entire string regardless of embedded null bytes.

        Consider wrapping the passed value with `byteparse.trim_zstring` if you
        can't be sure there are no embedded null bytes.
        :::

        @param value string -- The string to write.
        @param size number? -- The maximum size of the string.
    ]=]
    function writer.write_zstring(value: string, size: number?)
        writer.write_string(value, size);
        writer.write_null();
    end

    --[=[
        Writes a buffer without a prefixed length, optionally trimmed to a 
        maximum size.

        Note: You should ensure the binary format has a way of encoding the
        buffers size, as this function writes the buffer raw and doesn't write
        any data a reader can use to determine the size.

        @param value buffer -- The buffer to write.
        @param offset number? -- The starting offset from the buffer.
        @param size number? -- The amount of bytes from the buffer.
    ]=]
    function writer.write_buffer(value: buffer, offset: number?, size: number?)
        expand(buffer.len(value));
        buffer.copy(b, cursor, value, offset, size);
        advance_write((size or buffer.len(value) - (offset or 0)));
    end

    --[=[
        Writes a length prefixed buffer.

        @param value buffer -- The buffer to write.
        @param offset number? -- The starting offset from the buffer.
        @param size number? -- The amount of bytes from the buffer.
    ]=]
    function writer.write_lbuffer(value: buffer, offset: number?, size: number?)
        local size = size or buffer.len(value);
        writer.write_varint(size);
        writer.write_buffer(value, offset, size);
    end

    --[=[
        Writes a null terminated (C Style) buffer.
        
        Assumes the buffer is null safe.

        :::warning
        This function doesn't check whether the passed value is null-safe, and
        will write the entire buffer regardless of embedded null bytes.

        Consider wrapping the passed value with `byteparse.trim_zbuffer` if you
        can't be sure there are no embedded null bytes.
        :::

        @param value buffer -- The buffer to write.
        @param offset number? -- The starting offset from the buffer.
        @param size number? -- The amount of bytes from the buffer.
    ]=]
    function writer.write_zbuffer(value: buffer, offset: number?, size: number?)
        writer.write_buffer(value, offset, size);
        writer.write_null();
    end

    --[=[
        Writes a array without a prefixed length.

        Assumes the encoder function advances the cursor.

        Note: You should ensure the binary format has a way of encoding the
        arrays size, as this function doesn't write any data a reader can use
        to determine the size.

        @param value {T} -- The buffer to write.
        @param encoder (T, B...) -> () -- The encoder function.
        @param ... B... -- Additional data to pass to the encoder.
    ]=]
    function writer.write_array<T, B...>(value: {T}, encoder: (T) -> (), ...: B...)
        for _, v in value do
            encoder(v, ...);
        end
    end

    --[=[
        Writes a length prefixed array.

        Assumes the encoder function advances the cursor.

        @param value {T} -- The buffer to write.
        @param encoder (T, B...) -> () -- The encoder function.
        @param ... B... -- Additional data to pass to the encoder.
    ]=]
    function writer.write_larray<T, B...>(value: {T}, encoder: (T) -> (), ...: B...)
        writer.write_varint(#value);
        writer.write_array(value, encoder, ...);
    end

    --[=[
        Writes a null terminated array.

        Assumes the encoder function advances the cursor. The encoder function
        can freely emit null bytes **after** the first byte, provided it advances the cursor properly.

        @param value {T} -- The buffer to write.
        @param encoder (T, B...) -> () -- The encoder function.
        @param ... B... -- Additional data to pass to the encoder.
    ]=]
    function writer.write_zarray<T, B...>(value: {T}, encoder: (T) -> (), ...: B...)
        writer.write_array(value, encoder, ...);
        writer.write_null();
    end

    --[=[
        Writes a vector.

        @param value vector -- The vector to write.
    ]=]
    function writer.write_vector(value: vector)
        writer.write_f32(value.x);
        writer.write_f32(value.y);
        writer.write_f32(value.z);
        
        if vector_size == 4 then
            writer.write_f32((value :: any).w);
        end
    end

    --[=[
        Writes a serialisable table.

        @param value SerialisableTable -- The table to write.
    ]=]
    function writer.write_table(value: SerialisableTable)
        local parts = byteparse.get_table_parts(value);

        local flags = 0;

        if parts.array then
            flags = bit32.replace(flags, 1, TABLE_FLAGS.HAS_ARRAY, 1);
        end
        
        if parts.hash then
            flags = bit32.replace(flags, 1, TABLE_FLAGS.HAS_DICT, 1);
        end

        writer.write_u8(flags);

        if parts.array then
            writer.write_varint(parts.array_size);
            writer.write_array(parts.array, writer.write_any);
        end

        if parts.hash then
            writer.write_varint(parts.hash_size);
            for k, v in parts.hash do
                writer.write_any(k);
                writer.write_any(v);
            end
        end
    end

    --[=[
        Writes any serialisable type, with the Luau TValue prefixed.
    ]=]
    function writer.write_any(value: Serialisable)        
        if type(value) == "nil" then
            writer.write_u8(TYPE_IDS.NIL);
        elseif type(value) == "boolean" then
            writer.write_u8(TYPE_IDS.BOOLEAN);
            writer.write_bool(value);
        elseif type(value) == "number" then
            writer.write_u8(TYPE_IDS.NUMBER);
            writer.write_f64(value);
        elseif type(value) == "vector" then
            writer.write_u8(TYPE_IDS.VECTOR);
            writer.write_vector(value);
        elseif type(value) == "string" then
            writer.write_u8(TYPE_IDS.STRING);
            writer.write_lstring(value);
        elseif type(value) == "buffer" then
            writer.write_u8(TYPE_IDS.BUFFER);
            writer.write_lbuffer(value);
        elseif type(value) == "table" then
            writer.write_u8(TYPE_IDS.TABLE);
            writer.write_table(value);
        end
    end

    return writer;
end

--[=[
    Creates a reader instance from a buffer.

    @within byteparse
    @param b buffer -- The buffer to read from.
    @return reader -- The new reader instance.
]=]
function byteparse.reader(b: buffer)
    warn_vector_lib();

    local cursor = 0;
    local vector_size = 3;

    --[=[
        Advances the read cursor by a set amount following a read.

        @within reader
        @ignore
        @param by number -- How much to advance the cursor.
    ]=]
    local function advance(by: number)
        cursor += by;
    end

    --[=[
        Sets the read cursor to a set position.

        @within reader
        @param to number -- The position to move to.
    ]=]
    local function set_cursor(to: number)
        cursor = to;
    end

    --[=[
        Gets the current cursor position.

        @within reader
        @return number -- The cursor position.
    ]=]
    local function get_cursor()
        return cursor;
    end

    --[=[
        Reader instance used to deserialise to binary formats.

        @class reader
    ]=]
    local reader = {};

    reader.set_cursor = set_cursor;
    reader.get_cursor = get_cursor;

    --[=[
        Sets the vector size. The given vector size cannot exceed the VMs
        'LUA_VECTOR_SIZE' size.

        @within reader
        @param to number -- The vector size, must be either 3 or 4.
    ]=]
    function reader.set_vector_size(to: number)
        if to ~= 3 and to ~= 4 then
            error("vector size must be either 3 or 4", 2);
        end

        vector_size = to;
    end

    --[=[
        Reads an unsigned 8 bit integer.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_u8(): u8
        local value = buffer.readu8(b, cursor);
        advance(1);
        return value;
    end

    --[=[
        Reads an unsigned 16 bit integer.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_u16(): u16
        local value = buffer.readu16(b, cursor);
        advance(2);
        return value;
    end

    --[=[
        Reads an unsigned 32 bit integer.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_u32(): u32
        local value = buffer.readu32(b, cursor);
        advance(4);
        return value;
    end

    --[=[
        Reads a signed 8 bit integer.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_i8(): i8
        local value = buffer.readi8(b, cursor);
        advance(1);
        return value;
    end

    --[=[
        Reads a signed 16 bit integer.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_i16(): i16
        local value = buffer.readi16(b, cursor);
        advance(2);
        return value;
    end

    --[=[
        Reads a signed 32 bit integer.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_i32(): i32
        local value = buffer.readi32(b, cursor);
        advance(4);
        return value;
    end

    --[=[
        Reads a 32 bit floating point number.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_f32(): f32
        local value = buffer.readf32(b, cursor);
        advance(4);
        return value;
    end

    --[=[
        Reads a 64 bit floating point number.

        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_f64(): f64
        local value = buffer.readf64(b, cursor);
        advance(8);
        return value;
    end

    --[=[
        Reads a ProtoBuf [Base 128 Variable-width integer](https://protobuf.dev/programming-guides/encoding/#varints).
    
        @within reader
        @return number -- The read value.
    ]=]
    function reader.read_varint(): varint 
        -- Inspired by fiu's implementation
        local result = 0;
		for i = 0, 4 do
			local value = reader.read_u8();
			result = bit32.bor(result, bit32.lshift(bit32.band(value, 0x7F), i * 7));
			if not bit32.btest(value, 0x80) then
				break;
			end
		end
		return result;
    end

    --[=[
        Reads a boolean.

        @within reader
        @return boolean -- The read boolean.
    ]=]
    function reader.read_bool(): boolean
        return reader.read_u8() == 1;
    end

    --[=[
        Reads a string.

        @within reader
        @param length number? -- The string length.
        @return string -- The read string.
    ]=]
    function reader.read_string(length: number): string
        local value = buffer.readstring(b, cursor, length);
        advance(length);
        return value;
    end

    --[=[
        Reads a length prefixed string.

        @within reader
        @return string -- The read string.
    ]=]
    function reader.read_lstring(): string
        local length = reader.read_varint();
        return reader.read_string(length);
    end

    --[=[
        Reads a null terminated string.

        @within reader
        @return string -- The read string.
    ]=]
    function reader.read_zstring(): string
        local start = cursor;
        while true do
            local byte = reader.read_u8();
            if byte == 0 then
                return buffer.readstring(b, start, cursor - start - 1);
            else
                continue;
            end
        end
    end

    --[=[
        Reads a buffer.

        @within reader
        @return buffer -- The read buffer.
    ]=]
    function reader.read_buffer(length: number): buffer
        local value = buffer.create(length);
        buffer.copy(value, 0, b, cursor, length);
        advance(length);
        return value;
    end

    --[=[
        Reads a length prefixed buffer.
       
        @within reader
        @return buffer -- The read buffer.
    ]=]
    function reader.read_lbuffer(): buffer
        local length = reader.read_varint();
        return reader.read_buffer(length);
    end

    --[=[
        Reads a null terminated buffer.

        @within reader
        @return buffer -- The read buffer.
    ]=]
    function reader.read_zbuffer(): buffer
        local start = cursor;
        while true do
            if reader.read_u8() == 0 then
                local length = (cursor - 1) - start;
                local value = buffer.create(length);
                buffer.copy(value, 0, b, start, length);
                return value;
            else
                continue;
            end
        end
    end

    --[=[
        Reads an array of values.

        Assumes `decoder` advances the cursor.
        Stops reading if the decoder returns nil.

        @within reader
        @param size number -- Amount of values to read, or -1 to read until the decoder returns nil.
        @param decoder (B...) -> T? -- Function to read values, or terminate if nil is returned.
        @param ... B... -- Additional data to pass to the decoder.
        @return {T} -- Array of read values.
    ]=]
    function reader.read_array<T, B...>(size: number, decoder: (B...) -> T?, ...: B...): {T}
        local values = {};
        if size == -1 then
            while true do
                local next_value = decoder(...);
                if next_value then
                    table.insert(values, next_value);
                else
                    return values;
                end
            end
        else
            for i = 1, size do
                local next_value = decoder(...);
                if next_value then
                    table.insert(values, next_value);
                else
                    return values;
                end
            end
        end

        return values;
    end

    --[=[
        Reads a length prefixed array of values.

        Assumes `decoder` advances the cursor.
        Stops reading if the decoder returns nil.

        @within reader
        @param decoder (B...) -> T? -- Function to read values, or terminate if nil is returned.
        @param ... B... -- Additional data to pass to the decoder.
        @return {T} -- Array of read values.
    ]=]
    function reader.read_larray<T, B...>(decoder: (B...) -> T?, ...: B...): {T}
        local size = reader.read_varint();
        return reader.read_array(size, decoder, ...);
    end

    --[=[
        Reads a null terminated array of values.

        Assumes `decoder` advances the cursor.
        Stops reading if the next byte is `0`, or if the decoder returns nil.

        @within reader
        @param decoder (B...) -> T? -- Function to read values, or terminate if nil is returned.
        @param ... B... -- Additional data to pass to the decoder.
        @return {T} -- Array of read values.
    ]=]
    function reader.read_zarray<T, B...>(decoder: (B...) -> T?, ...: B...): {T}
        local values = {};
        while true do
            if buffer.readu8(b, cursor) == 0 then
                advance(1);
                return values;
            end

            local next_value = decoder(...);
            if next_value then
                table.insert(values, next_value);
            else
                return values;
            end
        end
    end

    --[=[
        Reads a vector.

        @within reader
        @return vector -- The read vector.
    ]=]
    function reader.read_vector(): vector
        local x = reader.read_f32();
        local y = reader.read_f32();
        local z = reader.read_f32();
        
        if vector_size == 4 then
            local w = reader.read_f32();
            return (vector.create :: any)(x, y, z, w);
        end

        return vector.create(x, y, z);
    end

    --[=[
        Reads a table.
    
        @within reader
        @return SerialisableTable -- The read table.
    ]=]
    function reader.read_table(): SerialisableTable
        local flags = reader.read_u8();
        local has_array = bit32.extract(flags, TABLE_FLAGS.HAS_ARRAY) == 1;
        local has_dict = bit32.extract(flags, TABLE_FLAGS.HAS_DICT) == 1;
        
        local values: {[Serialisable]: Serialisable} = {};

        if has_array then
            local size = reader.read_varint();
            for i = 1, size do
                values[i] = reader.read_any();
            end
        end

        if has_dict then
            local size = reader.read_varint();
            for i = 1, size do
                local k = reader.read_any();
                local v = reader.read_any();

                values[k] = v;
            end
        end

        return values;
    end

    --[=[
        Reads a type-prefixed value.

        @within reader
        @return Serialisable -- The read value.
    ]=]
    function reader.read_any(): Serialisable
        local type_id = reader.read_u8();

        if type_id == TYPE_IDS.NIL then
            return nil;
        elseif type_id == TYPE_IDS.BOOLEAN then
            return reader.read_bool();
        elseif type_id == TYPE_IDS.NUMBER then
            return reader.read_f64();
        elseif type_id == TYPE_IDS.VECTOR then
            return reader.read_vector();
        elseif type_id == TYPE_IDS.STRING then
            return reader.read_lstring();
        elseif type_id == TYPE_IDS.BUFFER then
            return reader.read_lbuffer();
        elseif type_id == TYPE_IDS.TABLE then
            return reader.read_table();
        end

        error(`[byteparse ERROR]: unknown type id {type_id} at cursor {cursor}`);
    end

    return reader;
end

return byteparse;
