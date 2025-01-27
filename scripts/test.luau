local stdio = require("@lune/stdio");
local luau = require("@lune/luau");
local serde = require("@lune/serde");
local byteparse = require("../lib");

local function tbl_eq(a: any, b: any): boolean
    return serde.encode("json", a) == serde.encode("json", b);
end

local tests = {};

local function test(name: string, fn: () -> ())
    table.insert(tests, {
        name = `byteparse::{name}`,
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
                end
            });
        end,
    };
end

--------------------------------------------------------------------------------

--// Utility Functions

test("get_table_parts", function()
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

test("trim_zbuffer", function()
    local a = byteparse.trim_zbuffer(buffer.fromstring("helloworld\0ahhh!!!"));
    assert(buffer.tostring(a) == "helloworld", "a should equal 'helloworld'");

    local b = byteparse.trim_zbuffer(buffer.fromstring("helloworld"));
    assert(buffer.tostring(b) == "helloworld", "b should equal 'helloworld'");
end);

test("trim_zstring", function()
    local a = byteparse.trim_zstring("helloworld\0ahhh!!!");
    assert(a == "helloworld", "a should equal 'helloworld'");

    local b = byteparse.trim_zstring("helloworld");
    assert(b == "helloworld", "b should equal 'helloworld'");
end);

test("{writer,reader}::new", function()
    byteparse.reader(byteparse.writer(1000).to_buffer());
end);

test("writer::{set,get}_capacity", function()
    local writer = byteparse.writer(0);
    writer.set_capacity(10);
    assert(writer.get_capacity() == 10, "capacity should've been set to 10");
end);

test("writer::expand", function()
    local writer = byteparse.writer(0);
    writer.expand(10);
    assert(writer.get_capacity() ~= 10, "capacity should've been increased");
end);

test("{writer,reader}::{set,get}_cursor", function()
    local writer = byteparse.writer(0);
    writer.set_cursor(10);
    assert(writer.get_cursor() == 10, "cursor should've been set to 10");

    local reader = byteparse.reader(buffer.create(100));
    reader.set_cursor(10);
    assert(reader.get_cursor() == 10, "cursor should've been set to 10");
end);

test("{writer,reader}::set_vector_size", function()
    local writer = byteparse.writer(0);
    writer.set_vector_size(4);
    local reader = byteparse.reader(buffer.create(100));
    reader.set_vector_size(4);
end);

test("writer::to_buffer", function()
    local writer = byteparse.writer(1000);
    writer.write_u8(255);
    local buf = writer.to_buffer();
    assert(buffer.readu8(buf, 0) == 255, "first byte should be 255");
end);

test("writer::to_string", function()
    local writer = byteparse.writer(1000);
    writer.write_string("helloworld");
    assert(writer.to_string() == "helloworld", "string should be 'helloworld'");
end);

test("{writer,reader}::{write,read}_u8", function()
    local writer = byteparse.writer(1);
    writer.write_u8(100);
    writer.write_u8(50);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_u8() == 100, "first u8 should be 100");
    assert(reader.read_u8() == 50, "second u8 should be 50");
end);

test("{writer,reader}::{write,read}_u16", function()
    local writer = byteparse.writer(1);
    writer.write_u16(10000);
    writer.write_u16(5000);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_u16() == 10000, "first u16 should be 10000");
    assert(reader.read_u16() == 5000, "second u16 should be 5000");
end);

test("{writer,reader}::{write,read}_u32", function()
    local writer = byteparse.writer(1);
    writer.write_u32(1000000);
    writer.write_u32(500000);    
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_u32() == 1000000, "first u32 should be 1000000");
    assert(reader.read_u32() == 500000, "second u32 should be 500000");
end);

test("{writer,reader}::{write,read}_i8", function()
    local writer = byteparse.writer(1);
    writer.write_i8(-100);
    writer.write_i8(-50);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_i8() == -100, "first i8 should be -100");
    assert(reader.read_i8() == -50, "second i8 should be -50");
end);

test("{writer,reader}::{write,read}_i16", function()
    local writer = byteparse.writer(1);
    writer.write_i16(-10000);
    writer.write_i16(-5000);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_i16() == -10000, "first i16 should be -10000");
    assert(reader.read_i16() == -5000, "second i16 should be -5000");
end);

test("{writer,reader}::{write,read}_i32", function()
    local writer = byteparse.writer(1);
    writer.write_i32(-1000000);
    writer.write_i32(-500000);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_i32() == -1000000, "first i32 should be -1000000");
    assert(reader.read_i32() == -500000, "second i32 should be -500000");
end);

test("{writer,reader}::{write,read}_f32", function()
    local writer = byteparse.writer(1);
    writer.write_f32(12);
    writer.write_f32(-11);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_f32() == 12, "first f32 should be 12");
    assert(reader.read_f32() == -11, "second f32 should be -11");
end);

test("{writer,reader}::{write,read}_f64", function()
    local writer = byteparse.writer(1);
    writer.write_f64(12);
    writer.write_f64(-11);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_f64() == 12, "first f64 should be 12");
    assert(reader.read_f64() == -11, "second f64 should be -11");
end);

test("{writer,reader}::{write,read}_varint", function()
    local writer = byteparse.writer(1);
    writer.write_varint(1583252);
    writer.write_varint(235266);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_varint() == 1583252, "first varint should be 1583252");
    assert(reader.read_varint() == 235266, "second varint should be 235266");
end);

test("{writer,reader}::{write,read}_bool", function()
    local writer = byteparse.writer(1);
    writer.write_bool(false);
    writer.write_bool(true);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_bool() == false, "first bool should be false");
    assert(reader.read_bool() == true, "second bool should be true");
end);

test("writer::write_null", function()
    local writer = byteparse.writer(1);
    writer.write_null();
    writer.write_null();
    local buf = writer.to_buffer();
    assert(buffer.readu8(buf, 0) == 0, "first byte should be 0");
    assert(buffer.readu8(buf, 1) == 0, "second byte should be 0");
end);

test("{writer,reader}::{write,read}_string", function()
    local writer = byteparse.writer(1);
    writer.write_string("first");
    writer.write_string("second");
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_string(5) == "first", "first string should be 'first''");
    assert(reader.read_string(6) == "second", "second string should be 'second'");
end);

test("{writer,reader}::{write,read}_lstring", function()
    local writer = byteparse.writer(1);
    writer.write_lstring("first");
    writer.write_lstring("second");
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_lstring() == "first", "first string should be 'first''");
    assert(reader.read_lstring() == "second", "second string should be 'second'");
end);

test("{writer,reader}::{write,read}_zstring", function()
    local writer = byteparse.writer(1);
    writer.write_zstring("first");
    writer.write_zstring("second");
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_zstring() == "first", "first string should be 'first''");
    assert(reader.read_zstring() == "second", "second string should be 'second'");
end);

test("{writer,reader}::{write,read}_buffer", function()
    local writer = byteparse.writer(1);
    writer.write_buffer(buffer.fromstring("first"));
    writer.write_buffer(buffer.fromstring("second"));
    local reader = byteparse.reader(writer.to_buffer());
    assert(buffer.tostring(reader.read_buffer(5)) == "first", "first buffer should be 'first''");
    assert(buffer.tostring(reader.read_buffer(6)) == "second", "second buffer should be 'second'");
end);

test("{writer,reader}::{write,read}_lbuffer", function()
    local writer = byteparse.writer(1);
    writer.write_lbuffer(buffer.fromstring("first"));
    writer.write_lbuffer(buffer.fromstring("second"));
    local reader = byteparse.reader(writer.to_buffer());
    assert(buffer.tostring(reader.read_lbuffer()) == "first", "first buffer should be 'first''");
    assert(buffer.tostring(reader.read_lbuffer()) == "second", "second buffer should be 'second'");
end);

test("{writer,reader}::{write,read}_zbuffer", function()
    local writer = byteparse.writer(1);
    writer.write_zbuffer(buffer.fromstring("first"));
    writer.write_zbuffer(buffer.fromstring("second"));
    local reader = byteparse.reader(writer.to_buffer());
    assert(buffer.tostring(reader.read_zbuffer()) == "first", "first buffer should be 'first''");
    assert(buffer.tostring(reader.read_zbuffer()) == "second", "second buffer should be 'second'");
end);

test("{writer,reader}::{write,read}_array", function()
    local array_1 = table.create(10, 5);
    local array_2 = table.create(10, 9);
    local writer = byteparse.writer(1);
    writer.write_array(array_1, writer.write_u8);
    writer.write_array(array_2, writer.write_u8);
    local reader = byteparse.reader(writer.to_buffer());
    assert(table.concat(reader.read_array(10, reader.read_u8)) == table.concat(array_1), "first array should be equal to array_1");
    assert(table.concat(reader.read_array(10, reader.read_u8)) == table.concat(array_2), "second array should be equal to array_2");
end);

test("{writer,reader}::{write,read}_larray", function()
    local array_1 = table.create(10, 5);
    local array_2 = table.create(10, 9);
    local writer = byteparse.writer(1);
    writer.write_larray(array_1, writer.write_u8);
    writer.write_larray(array_2, writer.write_u8);
    local reader = byteparse.reader(writer.to_buffer());
    assert(table.concat(reader.read_larray(reader.read_u8)) == table.concat(array_1), "first array should be equal to array_1");
    assert(table.concat(reader.read_larray(reader.read_u8)) == table.concat(array_2), "second array should be equal to array_2");
end);

test("{writer,reader}::{write,read}_zarray", function()
    local array_1 = table.create(10, 5);
    local array_2 = table.create(10, 9);
    local writer = byteparse.writer(1);
    writer.write_zarray(array_1, writer.write_u8);
    writer.write_zarray(array_2, writer.write_u8);
    local reader = byteparse.reader(writer.to_buffer());
    assert(table.concat(reader.read_zarray(reader.read_u8)) == table.concat(array_1), "first array should be equal to array_1");
    assert(table.concat(reader.read_zarray(reader.read_u8)) == table.concat(array_2), "second array should be equal to array_2");
end);

test("{writer,reader}::{write,read}_vector", function()
    local vector_1 = vector.create(1, 2, 3);
    local vector_2 = vector.create(3, 2, 1);
    local writer = byteparse.writer(1);
    writer.write_vector(vector_1);
    writer.write_vector(vector_2);
    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_vector() == vector_1, "first vector should equal vector_2");
    assert(reader.read_vector() == vector_2, "first vector should equal vector_1");
end);

test("{writer,reader}::{write,read}_table", function()
    local table_1 = {1, 2, 3};
    local table_2 = {a = 1, b = 2, c = 3};
    local table_3 = {1, 2, 3, a = 1, b = 2, c = 3};
    local writer = byteparse.writer(0);
    writer.write_table(table_1);
    writer.write_table(table_2);
    writer.write_table(table_3);
    local reader = byteparse.reader(writer.to_buffer());
    assert(tbl_eq(reader.read_table(), table_1), "first table should equal table_1");
    assert(tbl_eq(reader.read_table(), table_2), "second table should equal table_2");
    assert(tbl_eq(reader.read_table(), table_3), "third table should equal table_3");
end);

test("{writer,reader}::{write,read}_any", function()
    local writer = byteparse.writer(0);
    writer.write_any(nil);
    writer.write_any(true);
    writer.write_any(100);
    writer.write_any(vector.create(1, 2, 3));
    writer.write_any("ahhh!!!");
    writer.write_any(buffer.fromstring("helloworld"));
    writer.write_any({a = 1, b = 1, c = 1});

    local reader = byteparse.reader(writer.to_buffer());
    assert(reader.read_any() == nil);
    assert(reader.read_any() == true);
    assert(reader.read_any() == 100);
    assert(tbl_eq(reader.read_any(), vector.create(1, 2, 3)));
    assert(reader.read_any() == "ahhh!!!");
    assert(buffer.tostring(reader.read_any() :: any) == "helloworld");
    assert(tbl_eq(reader.read_any(), {a = 1, b = 1, c = 1}));
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