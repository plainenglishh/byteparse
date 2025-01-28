--!optimize 2
--!native
--!nolint LocalShadow

local stdio = require("@lune/stdio");
local luau = require("@lune/luau");
local byteparse = require("../lib");

local tests = {};

local function bench(name: string, rept: number, range: {number}, fn: (start: () -> (), stop: () -> ()) -> (), trivia: string?)
    table.insert(tests, {
        name = `{name}`,
        fn = fn,
        rept = rept,
        trivia = trivia,
        range = {
            warn = range[1],
            fail = range[2],
        },
    });
end
local vec_warn;
if type(vector) == "function" then
    print("got mlua vector constructor, vector benchmarks may be inaccurate");
    vec_warn = "got mlua vector constructor, benchmark may be inaccurate";
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

local function buffer_from(hex: string, rep: number?)
    local rep = rep or 1;
    local hex = string.rep(hex, rep);
    local writer = byteparse.writer(100);
    for i = 1, #hex, 2  do
        local byte = tonumber(string.sub(hex, i, i + 1), 16) or error("expected hex value");
        writer.write_u8(byte);
    end
    return writer.to_buffer();
end

local function copy_buffer(buf)
    local new_buf = buffer.create(buffer.len(buf));
    buffer.copy(new_buf, 0, buf);
    return new_buf;
end

local function rep_buffer(buf, rep)
    local new_buf = buffer.create(buffer.len(buf) * rep);
    for i = 0, rep - 1 do
        buffer.copy(new_buf, i*buffer.len(buf), buf);
    end
    
    return new_buf;
end

print("creating sample data");

local DATASETS = {};

DATASETS.EMPTY_1GB = buffer.create(999_999_999);
DATASETS.VARINTS_1M = rep_buffer(buffer_from("9601", 1), 1_000_000);
DATASETS.STRINGS_1M_5_RAW = rep_buffer(buffer.fromstring("hello"), 1_000_000);
DATASETS.STRINGS_1M_5_L = rep_buffer(buffer.fromstring("\x05hello"), 1_000_000);
DATASETS.STRINGS_1M_5_Z = rep_buffer(buffer.fromstring("hell\0"), 1_000_000);

DATASETS.ARRAY_1M_U8_RAW = DATASETS.EMPTY_1GB;

DATASETS.ARRAY_1M_5_RAW = rep_buffer(buffer.fromstring("\00\00\00\00\00"), 1_000_000);
DATASETS.ARRAY_1M_5_L = rep_buffer(buffer.fromstring("\x05\00\00\00\00\00"), 1_000_000);
DATASETS.ARRAY_1M_5_Z = rep_buffer(buffer.fromstring("\00\00\00\00\00\00"), 1_000_000);

DATASETS.VECTOR_1M = rep_buffer(buffer_from("0000803F 00000040 00004040"), 1_000_000);
DATASETS.ANY_1M = rep_buffer(buffer_from("020000000000005940"), 1_000_000);

local tbl = byteparse.writer(0);
tbl.write_table({ 1, 2, 3, a = 1, b = 2, c = 3, })
DATASETS.TABLE_1M = rep_buffer(tbl.to_buffer(), 1_000_000);

print("");

--------------------------------------------------------------------------------

do
    bench("library::reader::init::1gb", 20, {}, function(start, stop)
        start();
        byteparse.reader(DATASETS.EMPTY_1GB);
        stop();
    end);

    local function bench_read_n(t: string)
        bench(`library::reader::read_{t}::100kb`, 5, {}, function(start, stop)
            local reader = byteparse.reader(DATASETS.EMPTY_1GB);
            local read_fn = reader["read_"..t];
            start();
            for i = 1, 100_000 do
                read_fn();
            end
            stop();
        end);
    
        bench(`library::reader::read_{t}::1mb`, 5, {}, function(start, stop)
            local reader = byteparse.reader(DATASETS.EMPTY_1GB);
            local read_fn = reader["read_"..t];
            start();
            for i = 1, 1_000_000 do
                read_fn();
            end
            stop();
        end);

        bench(`library::reader::read_{t}::8.4mb`, 1, {}, function(start, stop)
            local reader = byteparse.reader(DATASETS.EMPTY_1GB);
            local read_fn = reader["read_"..t];
            start();
            for i = 1, 8_400_000 do
                read_fn();
            end
            stop();
        end, "1920 x 1080 raw RGBA pixel data");
    end
    
    bench_read_n("u8");
    bench_read_n("u16");
    bench_read_n("u32");
    bench_read_n("i8");
    bench_read_n("i16");
    bench_read_n("i32");
    bench_read_n("f32");
    bench_read_n("f64");
    bench_read_n("bool");

    bench(`library::reader::read_varint::100k`, 5, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.VARINTS_1M);
        start();
        for i = 1, 100_000 do
            reader.read_varint();
        end
        stop();
    end);

    bench(`library::reader::read_varint::1m`, 2, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.VARINTS_1M);
        start();
        for i = 1, 1_000_000 do
            reader.read_varint();
        end
        stop();
    end);

    bench(`library::reader::read_array::100k`, 5, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ARRAY_1M_5_RAW);
        start();
        for i = 1, 100_000 do
            reader.read_array(5, reader.read_u8);
        end
        stop();
    end, "tested as an array of u8s");
    
    bench(`library::reader::read_array::1m`, 2, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ARRAY_1M_5_RAW);
        start();
        for i = 1, 1_000_000 do
            reader.read_array(5, reader.read_u8);
        end
        stop();
    end, "tested as an array of u8s");
    
    bench(`library::reader::read_larray::100k`, 5, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ARRAY_1M_5_L);
        start();
        for i = 1, 100_000 do
            reader.read_larray(reader.read_u8);
        end
        stop();
    end, "tested as an array of u8s");
    
    bench(`library::reader::read_larray::1m`, 2, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ARRAY_1M_5_L);
        start();
        for i = 1, 1_000_000 do
            reader.read_larray(reader.read_u8);
        end
        stop();
    end, "tested as an array of u8s");
    
    bench(`library::reader::read_zarray::100k`, 5, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ARRAY_1M_5_Z);
        start();
        for i = 1, 100_000 do
            reader.read_zarray(reader.read_u8);
        end
        stop();
    end, "tested as an array of u8s");
    
    bench(`library::reader::read_zarray::1m`, 2, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ARRAY_1M_5_Z);
        start();
        for i = 1, 1_000_000 do
            reader.read_zarray(reader.read_u8);
        end
        stop();
    end, "tested as an array of u8s");

    bench(`library::reader::read_vector::100k`, 2, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.VECTOR_1M);
        start();
        for i = 1, 100_000 do
            reader.read_vector();
        end
        stop();
    end, vec_warn);
    
    bench(`library::reader::read_vector::1m`, 1, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.VECTOR_1M);
        start();
        for i = 1, 1_000_000 do
            reader.read_vector();
        end
        stop();
    end, vec_warn);

    bench(`library::reader::read_table::100k`, 2, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.TABLE_1M);
        start();
        for i = 1, 100_000 do
            reader.read_table();
        end
        stop();
    end);
    
    bench(`library::reader::read_table::1m`, 1, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.TABLE_1M);
        start();
        for i = 1, 1_000_000 do
            reader.read_table();
        end
        stop();
    end);

    bench(`library::reader::read_any::100k`, 2, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ANY_1M);
        start();
        for i = 1, 100_000 do
            reader.read_any();
        end
        stop();
    end, "tested with lua numbers (f64)");
    
    bench(`library::reader::read_any::1m`, 1, {}, function(start, stop)
        local reader = byteparse.reader(DATASETS.ANY_1M);
        start();
        for i = 1, 1_000_000 do
            reader.read_any();
        end
        stop();
    end, "tested with lua numbers (f64)");
end

do
    local function bench_write_n(t: string)
        bench(`library::writer::write_{t}::100k`, 5, {}, function(start, stop)
            local writer = byteparse.writer(999_999_999);
            local write_fn = writer["write_"..t];
            start();
            for i = 1, 100_000 do
                write_fn(0);
            end
            stop();
        end);
    
        bench(`library::writer::write_{t}::1m`, 5, {}, function(start, stop)
            local writer = byteparse.writer(999_999_999);
            local write_fn = writer["write_"..t];
            start();
            for i = 1, 1_000_000 do
                write_fn(0);
            end
            stop();
        end);

        bench(`library::writer::write_{t}::8.4m`, 1, {}, function(start, stop)
            local writer = byteparse.writer(999_999_999);
            local write_fn = writer["write_"..t];
            start();
            for i = 1, 8_400_000 do
                write_fn(0);
            end
            stop();
        end, "1920 x 1080 raw RGBA pixel data");
    end
end

do
    local buf = buffer.create(999_999_999);
    buffer.fill(buf, 0, 127);

    
end

--------------------------------------------------------------------------------

local function run_benches()
    local longest = 0;
    for _, bench in tests do
        if #bench.name > longest then
            longest = #bench.name;
        end
    end

    for _, bench in tests do
        stdio.write(string.format(`%-{longest}s .. `, bench.name));
        local avg = 0;

        for i = 1, bench.rept do
            local start;
            local stop;
            local function start_fn()
                start = os.clock();
            end
            local function stop_fn()
                stop = os.clock();
            end
    
            start = os.clock();
            bench.fn(start_fn, stop_fn);
            stop = stop or os.clock();
            avg += stop - start;
        end

        local time_taken = math.round((avg / bench.rept) * 1000 * 1000) / 1000;
        
        if time_taken >= (bench.range.fail or math.huge) then
            stdio.write(`{stdio.color("red")}{time_taken}ms{stdio.color("reset")} (fail_threshold={bench.range.fail})`); 
        elseif time_taken >= (bench.range.warn or math.huge) then
            stdio.write(`{stdio.color("yellow")}{time_taken}ms{stdio.color("reset")} (warning_threshold={bench.range.warn})`); 
        else
            stdio.write(`{stdio.color("green")}{time_taken}ms{stdio.color("reset")}`); 
        end

        if bench.trivia then
            stdio.write(`{stdio.style("dim")} -- {bench.trivia} {stdio.color("reset")}`);
        end

        stdio.write("\n");
    end
    
    print("\nbenches completed");
end

run_benches();