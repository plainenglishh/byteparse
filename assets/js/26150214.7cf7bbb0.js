"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[968],{2641:e=>{e.exports=JSON.parse('{"functions":[{"name":"get_table_parts","desc":"Extracts the hash and array parts from a table.","params":[{"name":"tbl","desc":"","lua_type":"{[any]: any}"}],"returns":[{"desc":"","lua_type":"TableParts"}],"function_type":"static","private":true,"source":{"line":125,"path":"lib/init.luau"}},{"name":"trim_zbuffer","desc":"Removes the first encountered null byte (and all following data) from a buffer.","params":[{"name":"buf","desc":"","lua_type":"buffer"}],"returns":[{"desc":"","lua_type":"buffer"}],"function_type":"static","source":{"line":163,"path":"lib/init.luau"}},{"name":"trim_zstring","desc":"Removes the first encountered null byte (and all following data) from a string.","params":[{"name":"str","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"string"}],"function_type":"static","source":{"line":182,"path":"lib/init.luau"}},{"name":"zterm_string","desc":"Appends a null terminator to the end of a string.","params":[{"name":"str","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"string\\r\\n"}],"function_type":"static","source":{"line":190,"path":"lib/init.luau"}},{"name":"zterm_buffer","desc":"Appends a null terminator to the end of a buffer.","params":[{"name":"buf","desc":"","lua_type":"buffer"}],"returns":[{"desc":"","lua_type":"buffer\\r\\n"}],"function_type":"static","source":{"line":197,"path":"lib/init.luau"}},{"name":"buffer_from_hex","desc":"Creates a new buffer from a hexadecimal string, ignoring any characters that\\naren\'t [0-9A-Fa-f].","params":[{"name":"hex","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":207,"path":"lib/init.luau"}},{"name":"buffer_reverse","desc":"Reverses a range of values in a buffer in place.","params":[{"name":"b","desc":"","lua_type":"buffer"},{"name":"offset","desc":"","lua_type":"number?"},{"name":"count","desc":"","lua_type":"number?"}],"returns":[],"function_type":"static","source":{"line":222,"path":"lib/init.luau"}},{"name":"writer","desc":"Creates a writer instance with a given starting size and expansion rate.","params":[{"name":"start_size","desc":"","lua_type":"number"},{"name":"expansion_rate","desc":"Multiplier used to resize the internal buffer when attempting to write more data than the internal buffer can take.","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"writer"}],"function_type":"static","source":{"line":253,"path":"lib/init.luau"}},{"name":"reader","desc":"Creates a reader instance from a buffer.","params":[{"name":"b","desc":"","lua_type":"buffer"}],"returns":[{"desc":"The new reader instance.","lua_type":"reader"}],"function_type":"static","source":{"line":734,"path":"lib/init.luau"}}],"properties":[{"name":"version","desc":"The library version as a semver string. E.g `v1.0.0`","lua_type":"string","source":{"line":245,"path":"lib/init.luau"}}],"types":[{"name":"TableParts","desc":"","fields":[{"name":"array","lua_type":"{any}","desc":""},{"name":"hash","lua_type":"{[any]: any}","desc":""},{"name":"array_size","lua_type":"number","desc":""},{"name":"hash_size","lua_type":"number","desc":""}],"private":true,"source":{"line":93,"path":"lib/init.luau"}}],"name":"byteparse","desc":"Library root.","source":{"line":115,"path":"lib/init.luau"}}')}}]);