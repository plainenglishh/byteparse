# Changelog

-----

## v1.1.0

### Added

- Added a `size` parameter to `reader::read_zstring` and `reader::read_zbuffer` to advance the cursor past an entire string buffer while disregarding data past the first null byte;
- Added the ability to silence warnings (i.e mlua vector global warning) with `_G.BYTEPARSE_SUPPRESS_WARNINGS`;
- Added `zterm_string` and `zterm_buffer` utility functions to create null terminated strings/buffers from a given input, used internally by `writer::write_z*`;
- Added basic benchmarks (note: only `reader::read_*` functions are benchmarked at the moment).

### Changes

- The `size` parameter of `writer::write_string` and `writer::write_buffer` now pad the end of a string with an empty buffer, (`writer::write_{z,l}buffer` and `writer::write_{z,l}string` use these functions internally, meaning they too inherit this behaviour);
- Tests now ensure the raw binary contents emitted by `writer::write_*` functions are correct.

### Fixed

- Removed debug print from `reader::read_zstring` that was mistakenly left in.

-----

## v1.0.0

### Added

- The library