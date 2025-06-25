# Change Log

-----

## v1.3.1

### Fixed

- Fixed type refinement issue in `writer.write_optional`.

-----

## v1.3.0

### Fixed

- Fixed types for writer/reader functions that accept a writer/reader callback.
- Fixed types to work with the new solver.

-----

## v1.2.1

### Removed

- Removed vector lib warning.

-----

## v1.2.0

### Added

- Added `writer.write_optional` and `reader.read_optional` to write and read potentially absent values;
- Added a `buffer_from_hex` utility function to create buffers from a hex string;
- Added a `buffer_reverse` utility function to reverse the contents of a buffer;
- Added a `vector_size` parameter to `writer.write_vector` and `reader.read_vector` to override the writer/readers default value.

### Changes

- Renamed 'encoder' and 'decoder' callbacks to 'writer_callback' and 'reader_callback' callbacks to better indicate their purpose;
- Renamed `{writer,reader}.set_vector_size` to `{writer,reader}.set_default_vector_size`;
- Vector lib warnings now only fire once, instead of every time.

-----

## v1.1.0

### Added

- Added a `size` parameter to `reader.read_zstring` and `reader.read_zbuffer` to advance the cursor past an entire string buffer while disregarding data past the first null byte;
- Added the ability to silence warnings (i.e mlua vector global warning) with `_G.BYTEPARSE_SUPPRESS_WARNINGS`;
- Added `zterm_string` and `zterm_buffer` utility functions to create null terminated strings/buffers from a given input, used internally by `writer.write_z*`;
- Added basic benchmarks (note: only `reader.read_*` functions are benchmarked at the moment).

### Changes

- The `size` parameter of `writer.write_string` and `writer.write_buffer` now pad the end of a string with an empty buffer, (`writer.write_{z,l}buffer` and `writer.write_{z,l}string` use these functions internally, meaning they too inherit this behaviour);
- Tests now ensure the raw binary contents emitted by `writer.write_*` functions are correct.

### Fixed

- Removed debug print from `reader.read_zstring` that was mistakenly left in.

-----

## v1.0.0

### Added

- The library