"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[976],{2053:(n,r,e)=>{e.r(r),e.d(r,{assets:()=>c,contentTitle:()=>l,default:()=>x,frontMatter:()=>d,metadata:()=>i,toc:()=>o});const i=JSON.parse('{"id":"intro","title":"Datatypes","description":"Introduction","source":"@site/docs/intro.md","sourceDirName":".","slug":"/intro","permalink":"/byteparse/docs/intro","draft":false,"unlisted":false,"editUrl":"https://github.com/plainenglishh/byteparse/edit/main/docs/intro.md","tags":[],"version":"current","sidebarPosition":1,"frontMatter":{"sidebar_position":1},"sidebar":"defaultSidebar"}');var s=e(4848),t=e(8453);const d={sidebar_position:1},l="Datatypes",c={},o=[{value:"Introduction",id:"introduction",level:2},{value:"Types",id:"types",level:2},{value:"u8",id:"u8",level:3},{value:"u16",id:"u16",level:3},{value:"u32",id:"u32",level:3},{value:"i8",id:"i8",level:3},{value:"i16",id:"i16",level:3},{value:"i32",id:"i32",level:3},{value:"f32",id:"f32",level:3},{value:"f64",id:"f64",level:3},{value:"varint",id:"varint",level:3},{value:"bool",id:"bool",level:3},{value:"null",id:"null",level:3},{value:"string",id:"string",level:3},{value:"lstring",id:"lstring",level:3},{value:"zstring",id:"zstring",level:3},{value:"array",id:"array",level:3},{value:"larray",id:"larray",level:3},{value:"zarray",id:"zarray",level:3},{value:"buffer",id:"buffer",level:3},{value:"lbuffer",id:"lbuffer",level:3},{value:"zbuffer",id:"zbuffer",level:3},{value:"vector",id:"vector",level:3},{value:"table",id:"table",level:3},{value:"any",id:"any",level:3}];function h(n){const r={a:"a",code:"code",h1:"h1",h2:"h2",h3:"h3",header:"header",p:"p",pre:"pre",strong:"strong",table:"table",tbody:"tbody",td:"td",th:"th",thead:"thead",tr:"tr",...(0,t.R)(),...n.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(r.header,{children:(0,s.jsx)(r.h1,{id:"datatypes",children:"Datatypes"})}),"\n",(0,s.jsx)(r.h2,{id:"introduction",children:"Introduction"}),"\n",(0,s.jsx)(r.h2,{id:"types",children:"Types"}),"\n",(0,s.jsx)(r.h3,{id:"u8",children:"u8"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An unsigned 8 bit integer. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 1 Byte",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"u16",children:"u16"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An unsigned 16 bit integer. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 2 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"u32",children:"u32"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An unsigned 32 bit integer. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 4 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"i8",children:"i8"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An signed 8 bit integer. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 1 Byte",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"i16",children:"i16"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An signed 16 bit integer. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 2 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"i32",children:"i32"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An signed 32 bit integer. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 4 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"f32",children:"f32"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An 32 IEEE 754 floating point. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 4 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"f64",children:"f64"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An 32 IEEE 754 floating point. ",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 8 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Native",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"varint",children:"varint"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A ProtoBuf ",(0,s.jsx)(r.a,{href:"https://protobuf.dev/programming-guides/encoding/#varints",children:"Base 128 Variable-width integer"}),".",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 1..10 bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," See ",(0,s.jsx)(r.a,{href:"https://protobuf.dev/programming-guides/encoding/#varints",children:"https://protobuf.dev/programming-guides/encoding/#varints"}),(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"bool",children:"bool"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A boolean value (1/0)",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 1 Byte",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Encoded as either a ",(0,s.jsx)(r.code,{children:"0"})," or ",(0,s.jsx)(r.code,{children:"1"})," ",(0,s.jsx)(r.code,{children:"u8"}),(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"null",children:"null"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A null byte (0)",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 1 Byte",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Encoded as a ",(0,s.jsx)(r.code,{children:"0"})," ",(0,s.jsx)(r.code,{children:"u8"}),(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"string",children:"string"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A raw string",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," String written directly with no further metadata",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"lstring",children:"lstring"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A length-prefixed string",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 0..10 + 0..2^64 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," String written directly with a ",(0,s.jsx)(r.code,{children:"varint"})," prefixed, denoting length",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"zstring",children:"zstring"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A null terminated string",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," String written directly followed by a null byte",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"array",children:"array"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," An array of serialisable values",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Array written directly with no further metadata",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"larray",children:"larray"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A length-prefixed array of serialisable values",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 0..10 + 0..2^64 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Array written directly with a ",(0,s.jsx)(r.code,{children:"varint"})," prefixed, denoting length",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"zarray",children:"zarray"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A null terminated array of serialisable values",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," String written directly followed by a null byte",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"buffer",children:"buffer"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A raw buffer",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Buffer written directly with no further metadata",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"lbuffer",children:"lbuffer"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A length-prefixed buffer",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 0..10 + 0..2^64 Bytes",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Buffer written directly with a ",(0,s.jsx)(r.code,{children:"varint"})," prefixed, denoting length",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"zbuffer",children:"zbuffer"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A null terminated buffer",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," Buffer written directly followed by a null byte",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"vector",children:"vector"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A 3 or 4-width vector",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," 12 or 16 Bytes, depending on vector size",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," 3 or 4 ",(0,s.jsx)(r.code,{children:"f32"}),"s",(0,s.jsx)("br",{})]}),"\n",(0,s.jsx)(r.h3,{id:"table",children:"table"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," A serialisable luau table",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})]}),"\n",(0,s.jsx)(r.pre,{children:(0,s.jsx)(r.code,{children:"has_array = u1\r\nhas_dict = u1\r\n\r\nif has_array then\r\n    array_length = varint\r\n    ...array_value = any -- (repeated for 1..array_length)\r\nend\r\n\r\nif has_dict then\r\n    dict_length = varint\r\n    ... {\r\n        key = any\r\n        value = any\r\n    } -- (repeated for 1..dict_length)\r\nend\n"})}),"\n",(0,s.jsx)(r.h3,{id:"any",children:"any"}),"\n",(0,s.jsxs)(r.p,{children:[(0,s.jsx)(r.strong,{children:"Description:"})," Any serialisable luau value",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Size:"})," Any",(0,s.jsx)("br",{}),"\r\n",(0,s.jsx)(r.strong,{children:"Encoding:"})," A Type ID followed by a the values",(0,s.jsx)("br",{})]}),"\n",(0,s.jsxs)(r.table,{children:[(0,s.jsx)(r.thead,{children:(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.th,{children:"Type"}),(0,s.jsx)(r.th,{children:"Type ID"}),(0,s.jsx)(r.th,{children:"Encoded As"})]})}),(0,s.jsxs)(r.tbody,{children:[(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.td,{children:"nil"}),(0,s.jsx)(r.td,{children:"0"}),(0,s.jsx)(r.td,{children:"Nothing"})]}),(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.td,{children:"boolean"}),(0,s.jsx)(r.td,{children:"1"}),(0,s.jsx)(r.td,{children:(0,s.jsx)(r.code,{children:"u8"})})]}),(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.td,{children:"number"}),(0,s.jsx)(r.td,{children:"2"}),(0,s.jsx)(r.td,{children:(0,s.jsx)(r.code,{children:"f64"})})]}),(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.td,{children:"vector"}),(0,s.jsx)(r.td,{children:"3"}),(0,s.jsx)(r.td,{children:(0,s.jsx)(r.code,{children:"vector"})})]}),(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.td,{children:"string"}),(0,s.jsx)(r.td,{children:"4"}),(0,s.jsx)(r.td,{children:(0,s.jsx)(r.code,{children:"lstring"})})]}),(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.td,{children:"buffer"}),(0,s.jsx)(r.td,{children:"5"}),(0,s.jsx)(r.td,{children:(0,s.jsx)(r.code,{children:"lstring"})})]}),(0,s.jsxs)(r.tr,{children:[(0,s.jsx)(r.td,{children:"table"}),(0,s.jsx)(r.td,{children:"6"}),(0,s.jsx)(r.td,{children:(0,s.jsx)(r.code,{children:"table"})})]})]})]})]})}function x(n={}){const{wrapper:r}={...(0,t.R)(),...n.components};return r?(0,s.jsx)(r,{...n,children:(0,s.jsx)(h,{...n})}):h(n)}},8453:(n,r,e)=>{e.d(r,{R:()=>d,x:()=>l});var i=e(6540);const s={},t=i.createContext(s);function d(n){const r=i.useContext(t);return i.useMemo((function(){return"function"==typeof n?n(r):{...r,...n}}),[r,n])}function l(n){let r;return r=n.disableParentContext?"function"==typeof n.components?n.components(s):n.components||s:d(n.components),i.createElement(t.Provider,{value:r},n.children)}}}]);