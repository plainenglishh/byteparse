--!nolint LocalShadow

local stdio = require("@lune/stdio");
local luau = require("@lune/luau");
local serde = require("@lune/serde");
local byteparse = require("../lib");

local function assert_tbl_eq(a: any, b: any): boolean
    return assert(serde.encode("json", a) == serde.encode("json", b), "tables arent equal");
end

local tests = {};

type TestFn = (name: string, fn: () -> ()) -> ();
type TestGroupFn = (name: string, fn: (test: TestFn, test_group: TestGroupFn) -> ()) -> ();

local function test(name: string, fn: () -> ())
    table.insert(tests, {
        name = `{name}`,
        fn = fn,
    });
end

if type(vector) == "function" then
    local env = luau.load("return getfenv;")()(1);

    env.vector = {
        create = function(x: number, y: number, z: number, w: number)
            return setmetatable({
                x = x or 0,
                y = y or 0,
                z = z or 0,
                w = w or 0,
            }, {
                __eq = function(a, b)
                    return (a.x == b.x) and (a.y == b.y) and (a.z == b.z) and (a.w == b.w);
                end,
                __type = "vector",
            });
        end,
    };
end

local function assert_buffer_eq(buf: buffer, eq_to: string)
    local eq_to = string.gsub(eq_to, "%X", "");
    local bytes = {};
    
    for i = 1, #eq_to, 2  do
        local byte = tonumber(string.sub(eq_to, i, i + 1), 16) or error("expected hex value");
        table.insert(bytes, byte);
    end

    if buffer.len(buf) ~= #bytes then
        error(`buffers should be of equal length, a = {buffer.len(buf)}, b = {#bytes}`);
    end

    for i = 0, buffer.len(buf) - 1 do
        local a = buffer.readu8(buf, i);
        local b = bytes[i + 1];
        if a ~= b then
            error(`expected byte at offset {i} to be {string.format("%02X", b)}, got {string.format("%02X", a)} instead`)
        end
    end
end

local function dump(buf: buffer|string)
    local buf = if type(buf) == "string" then buffer.fromstring(buf) else buf;
    local str = "";
    for i = 0, buffer.len(buf) - 1 do
        str ..= string.format("%02X ", buffer.readu8(buf, i));
    end
    return (str);
end

local function buffer_from(hex: string)
    local writer = byteparse.writer(100);
    for i = 1, #hex, 2  do
        local byte = tonumber(string.sub(hex, i, i + 1), 16) or error("expected hex value");
        writer.write_u8(byte);
    end
    return writer.to_buffer();
end

--------------------------------------------------------------------------------

--// Library Unit Tests

test("library::get_table_parts", function()
    local a_parts = byteparse.get_table_parts({1, 1, 1, 1, 1});

    assert(a_parts.array, `'a_parts' should have an array`);
    assert(not a_parts.hash, `'a_parts' should not have a dictionary`);
    assert(a_parts.array_size == 5, `'a_parts.array_size' should be 5`);
    assert(a_parts.hash_size == 0, `'a_parts.hash_size' should be 0`);

    local b_parts = byteparse.get_table_parts({ a = 1, b = 1, c = 1, d = 1, e = 1});

    assert(not b_parts.array, `'b_parts' should not have an array`);
    assert(b_parts.hash, `'b_parts' should have a dictionary`);
    assert(b_parts.array_size == 0, `'b_parts.array_size' should be 0`);
    assert(b_parts.hash_size == 5, `'b_parts.hash_size' should be 5`);

    local c_parts = byteparse.get_table_parts({ a = 1, b = 1, 1, 2});

    assert(c_parts.array, `'c_parts' should have an array`);
    assert(c_parts.hash, `'c_parts' should have a dictionary`);
    assert(c_parts.array_size == 2, `'c_parts.array_size' should be 2`);
    assert(c_parts.hash_size == 2, `'c_parts.hash_size' should be 2`);
end);

test("library::trim_zbuffer", function()
    local a = byteparse.trim_zbuffer(buffer.fromstring("helloworld\0ahhh!!!"));
    assert(buffer.tostring(a) == "helloworld", "a should equal 'helloworld'");

    local b = byteparse.trim_zbuffer(buffer.fromstring("helloworld"));
    assert(buffer.tostring(b) == "helloworld", "b should equal 'helloworld'");
end);

test("library::trim_zstring", function()
    local a = byteparse.trim_zstring("helloworld\0ahhh!!!");
    assert(a == "helloworld", "a should equal 'helloworld'");

    local b = byteparse.trim_zstring("helloworld");
    assert(b == "helloworld", "b should equal 'helloworld'");
end);

test("library::zterm_string", function()
    assert(byteparse.zterm_string("a"), "a\0");
end);

test("library::zterm_buffer", function()
    assert_buffer_eq(byteparse.zterm_buffer(buffer_from("FF")), "FF00");
end);

test("library::{writer,reader}::new", function()
    byteparse.reader(byteparse.writer(1000).to_buffer());
end);

test("library::writer::{set,get}_capacity", function()
    local writer = byteparse.writer(0);
    writer.set_capacity(10);
    assert(writer.get_capacity() == 10, "capacity should've been set to 10");
end);

test("library::writer::expand", function()
    local writer = byteparse.writer(0);
    writer.expand(10);
    assert(writer.get_capacity() ~= 10, "capacity should've been increased");
end);

test("library::{writer,reader}::{set,get}_cursor", function()
    local writer = byteparse.writer(0);
    writer.set_cursor(10);
    assert(writer.get_cursor() == 10, "cursor should've been set to 10");

    local reader = byteparse.reader(buffer.create(100));
    reader.set_cursor(10);
    assert(reader.get_cursor() == 10, "cursor should've been set to 10");
end);

test("library::{writer,reader}::set_vector_size", function()
    local writer = byteparse.writer(0);
    writer.set_vector_size(4);
    local reader = byteparse.reader(buffer.create(100));
    reader.set_vector_size(4);
end);

test("library::writer::to_buffer", function()
    local writer = byteparse.writer(1000);
    writer.write_u8(255);
    local buf = writer.to_buffer();
    assert(buffer.readu8(buf, 0) == 255, "first byte should be 255");
end);

test("library::writer::to_string", function()
    local writer = byteparse.writer(1000);
    writer.write_string("helloworld");
    assert(writer.to_string() == "helloworld", "string should be 'helloworld'");
end);

test("library::{writer,reader}::{write,read}_u8", function()
    local writer = byteparse.writer(1);
    writer.write_u8(100);
    writer.write_u8(50);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "64 32");

    local reader = byteparse.reader(buf);
    assert(reader.read_u8() == 100, "first u8 should be 100");
    assert(reader.read_u8() == 50, "second u8 should be 50");
end);

test("library::{writer,reader}::{write,read}_u16", function()
    local writer = byteparse.writer(1);
    writer.write_u16(10000);
    writer.write_u16(5000);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "1027 8813");

    local reader = byteparse.reader(buf);
    assert(reader.read_u16() == 10000, "first u16 should be 10000");
    assert(reader.read_u16() == 5000, "second u16 should be 5000");
end);

test("library::{writer,reader}::{write,read}_u32", function()
    local writer = byteparse.writer(1);
    writer.write_u32(1000000);
    writer.write_u32(500000);    

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "40420F00 20A10700");

    local reader = byteparse.reader(buf);
    assert(reader.read_u32() == 1000000, "first u32 should be 1000000");
    assert(reader.read_u32() == 500000, "second u32 should be 500000");
end);

test("library::{writer,reader}::{write,read}_i8", function()
    local writer = byteparse.writer(1);
    writer.write_i8(-100);
    writer.write_i8(-50);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "9C CE");

    local reader = byteparse.reader(buf);
    assert(reader.read_i8() == -100, "first i8 should be -100");
    assert(reader.read_i8() == -50, "second i8 should be -50");
end);

test("library::{writer,reader}::{write,read}_i16", function()
    local writer = byteparse.writer(1);
    writer.write_i16(-10000);
    writer.write_i16(-5000);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "F0D8 78EC");

    local reader = byteparse.reader(buf);
    assert(reader.read_i16() == -10000, "first i16 should be -10000");
    assert(reader.read_i16() == -5000, "second i16 should be -5000");
end);

test("library::{writer,reader}::{write,read}_i32", function()
    local writer = byteparse.writer(1);
    writer.write_i32(-1000000);
    writer.write_i32(-500000);
    
    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "C0BDF0FF E05EF8FF");

    local reader = byteparse.reader(buf);
    assert(reader.read_i32() == -1000000, "first i32 should be -1000000");
    assert(reader.read_i32() == -500000, "second i32 should be -500000");
end);

test("library::{writer,reader}::{write,read}_f32", function()
    local writer = byteparse.writer(1);
    writer.write_f32(12);
    writer.write_f32(-11);
        
    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "00004041 000030C1");

    local reader = byteparse.reader(buf);
    assert(reader.read_f32() == 12, "first f32 should be 12");
    assert(reader.read_f32() == -11, "second f32 should be -11");
end);

test("library::{writer,reader}::{write,read}_f64", function()
    local writer = byteparse.writer(1);
    writer.write_f64(12);
    writer.write_f64(-11);
        
    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "0000000000002840 00000000000026C0");

    local reader = byteparse.reader(buf);
    assert(reader.read_f64() == 12, "first f64 should be 12");
    assert(reader.read_f64() == -11, "second f64 should be -11");
end);

test("library::{writer,reader}::{write,read}_varint", function()
    local writer = byteparse.writer(1);
    writer.write_varint(150);
    writer.write_varint(1);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "9601 01");

    local reader = byteparse.reader(buf);
    assert(reader.read_varint() == 150, "first varint should be 1583252");
    assert(reader.read_varint() == 1, "second varint should be 235266");
end);

test("library::{writer,reader}::{write,read}_bool", function()
    local writer = byteparse.writer(1);
    writer.write_bool(false);
    writer.write_bool(true);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "00 01");

    local reader = byteparse.reader(buf);
    assert(reader.read_bool() == false, "first bool should be false");
    assert(reader.read_bool() == true, "second bool should be true");
end);

test("library::writer::write_null", function()
    local writer = byteparse.writer(1);
    writer.write_null();
    writer.write_null();

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "00 00");
end);

test("library::{writer,reader}::{write,read}_string", function()
    local writer = byteparse.writer(1);
    writer.write_string("first");
    writer.write_string("second", 10);
    writer.write_string("third", 4);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, `6669727374 7365636f6e6400000000 74686972`);

    local reader = byteparse.reader(buf);
    assert(reader.read_string(5) == "first", "first string should be 'first''");
    assert(reader.read_string(10) == "second\0\0\0\0", "second string should be 'second\\0\\0\\0\\0'");
    assert(reader.read_string(4) == "thir", "third string should be 'thir'");
end);

test("library::{writer,reader}::{write,read}_lstring", function()
    local writer = byteparse.writer(1);
    writer.write_lstring("first");
    writer.write_lstring("second", 10);
    writer.write_lstring("third", 4);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, `056669727374 0A7365636f6e6400000000 0474686972`);

    local reader = byteparse.reader(buf);
    assert(reader.read_lstring() == "first", "first string should be 'first''");
    assert(reader.read_lstring() == "second\0\0\0\0", "second string should be 'second\\0\\0\\0\\0'");
    assert(reader.read_lstring() == "thir", "third string should be 'thir'");

end);

test("library::{writer,reader}::{write,read}_zstring", function()
    local writer = byteparse.writer(1);
    writer.write_zstring("first"); -- Should be followed by one null byte
    writer.write_zstring("second", 10); -- Rest of the buffer should be filled with nulls
    writer.write_zstring("third", 4); -- Last byte should be trimmed and replaced with null

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, `666972737400 7365636f6e6400000000 74686900`);

    local reader = byteparse.reader(buf);
    assert(reader.read_zstring() == "first", "first string should be 'first''");
    assert(reader.read_zstring(10) == "second", "second string should be 'second'");
    assert(reader.read_zstring(4) == "thi", "third string should be 'thi'");
end);

test("library::{writer,reader}::{write,read}_buffer", function()
    local writer = byteparse.writer(1);
    writer.write_buffer(buffer_from("00010203"));
    writer.write_buffer(buffer_from("04050607"));
    
    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "00010203 04050607")
    
    local reader = byteparse.reader(writer.to_buffer());
    assert_buffer_eq(reader.read_buffer(4), "00010203");
    assert_buffer_eq(reader.read_buffer(4), "04050607");
end);

test("library::{writer,reader}::{write,read}_lbuffer", function()
    local writer = byteparse.writer(1);
    writer.write_lbuffer(buffer_from("1A2A3A4A"));
    writer.write_lbuffer(buffer_from("1A2A"));
    
    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "041A2A3A4A 021A2A")
    
    local reader = byteparse.reader(writer.to_buffer());
    assert_buffer_eq(reader.read_lbuffer(), "1A2A3A4A");
    assert_buffer_eq(reader.read_lbuffer(), "1A2A");
end);

test("library::{writer,reader}::{write,read}_zbuffer", function()
    local writer = byteparse.writer(1);
    writer.write_zbuffer(buffer_from("1A2A3A4A"));
    writer.write_zbuffer(buffer_from("1A2A"));
    
    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "1A2A3A4A00 1A2A00")
    
    local reader = byteparse.reader(writer.to_buffer());
    assert_buffer_eq(reader.read_zbuffer(), "1A2A3A4A");
    assert_buffer_eq(reader.read_zbuffer(), "1A2A");
end);

test("library::{writer,reader}::{write,read}_array", function()
    local array_1 = table.create(10, 5);
    local array_2 = table.create(5, 9);
    
    local writer = byteparse.writer(1);
    writer.write_array(array_1, writer.write_u8);
    writer.write_array(array_2, writer.write_u8);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "05050505050505050505 0909090909")

    local reader = byteparse.reader(buf);
    assert_tbl_eq(reader.read_array(10, reader.read_u8), array_1);
    assert_tbl_eq(reader.read_array(5, reader.read_u8), array_2);
end);

test("library::{writer,reader}::{write,read}_larray", function()
    local array_1 = table.create(10, 5);
    local array_2 = table.create(5, 9);
    
    local writer = byteparse.writer(1);
    writer.write_larray(array_1, writer.write_u8);
    writer.write_larray(array_2, writer.write_u8);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "0A05050505050505050505 050909090909")

    local reader = byteparse.reader(buf);
    assert_tbl_eq(reader.read_larray(reader.read_u8), array_1);
    assert_tbl_eq(reader.read_larray(reader.read_u8), array_2);
end);

test("library::{writer,reader}::{write,read}_zarray", function()
    local array_1 = table.create(10, 5);
    local array_2 = table.create(5, 9);
    
    local writer = byteparse.writer(1);
    writer.write_zarray(array_1, writer.write_u8);
    writer.write_zarray(array_2, writer.write_u8);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "0505050505050505050500 090909090900")

    local reader = byteparse.reader(buf);
    assert_tbl_eq(reader.read_zarray(reader.read_u8), array_1);
    assert_tbl_eq(reader.read_zarray(reader.read_u8), array_2);
end);

test("library::{writer,reader}::{write,read}_vector", function()
    local vector_1 = vector.create(1, 2, 3);
    local vector_2 = vector.create(3, 2, 1);

    local writer = byteparse.writer(1);
    writer.set_vector_size(3);
    writer.write_vector(vector_1);
    writer.write_vector(vector_2);
    
    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "0000803F 00000040 00004040  00004040 00000040 0000803F")
    
    local reader = byteparse.reader(buf);
    assert(reader.read_vector() == vector_1, "first vector should equal vector_2");
    assert(reader.read_vector() == vector_2, "first vector should equal vector_1");
end);

test("library::{writer,reader}::{write,read}_table", function()
    local table_1 = {1, 2};
    local table_2 = {a = 1, b = 2};
    local table_3 = {1, 2, a = 1, b = 2};

    local writer = byteparse.writer(0);
    writer.write_table(table_1);
    writer.write_table(table_2);
    writer.write_table(table_3);

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "{01 {02 02000000000000F03F 020000000000000040}} {02 {02 040161 02000000000000F03F 040162 020000000000000040}} {03 {02 02000000000000F03F 020000000000000040} {02 040161 02000000000000F03F 040162 020000000000000040}}");

    local reader = byteparse.reader(buf);
    assert_tbl_eq(reader.read_table(), table_1);
    assert_tbl_eq(reader.read_table(), table_2);
    assert_tbl_eq(reader.read_table(), table_3);
end);

test("library::{writer,reader}::{write,read}_any", function()
    local writer = byteparse.writer(0);
    writer.write_any(nil);
    writer.write_any(true);
    writer.write_any(100);
    writer.write_any(vector.create(1, 2, 3));
    writer.write_any("ahhh!!!");
    writer.write_any(buffer.fromstring("helloworld"));
    writer.write_any({1});

    local buf = writer.to_buffer();
    assert_buffer_eq(buf, "00 0101 020000000000005940 030000803F0000004000004040 040761686868212121 050A68656C6C6F776F726C64 06010102000000000000F03F");

    local reader = byteparse.reader(buf);
    assert(reader.read_any() == nil);
    assert(reader.read_any() == true);
    assert(reader.read_any() == 100);
    assert(assert_tbl_eq(reader.read_any(), vector.create(1, 2, 3)));
    assert(reader.read_any() == "ahhh!!!");
    assert(buffer.tostring(reader.read_any() :: any) == "helloworld");
    assert_tbl_eq(reader.read_any(), {1});
end);

--------------------------------------------------------------------------------

local function run_tests()
    local tests_passing = true;

    local longest = 0;
    for _, test in tests do
        if #test.name > longest then
            longest = #test.name;
        end
    end

    for _, test in tests do
        stdio.write(string.format(`%-{longest}s .. `, test.name));
        local ok, err = pcall(test.fn :: any);
        if ok then
            stdio.write(`{stdio.color("green")}pass{stdio.color("reset")}\n`);
        else
            tests_passing = false;
            stdio.write(`{stdio.color("red")}fail{stdio.color("reset")}\n`);
            print(tostring(err):split("\n")[1]);
        end
    end
    
    print("");
    
    if tests_passing then
        print("tests passed");
    else 
        error("tests failed");
    end
end

run_tests();