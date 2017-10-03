A small utility to pretty-print LUKS headers.

## Building

```
opam pin add -n cs 'https://github.com/cfcs/ocaml-cs.git'
opam install bos cmdliner cs cstruct fmt fpath hex logs rresult topkg
ocaml pkg/pkg.ml build --with-cli true
```

## Example
```
./_build/app/oluks.native AAA
LUKS version: 1
cipher name: "aes", mode: "xts-plain64"
hash spec: "sha256" payload offset: 4096 key bytes: 32
master key digest: 
master key digest salt: 
master key digest iterations: 294500
UUID: "c854737f-1880-4345-9b7a-5f0b0791a416"
key slots: | Active: iterations: 2340570
                     salt: 35 4d 26 bb 7e a8 0e ee 97 56 bb c4 36 66 25 ea 
                           89 a9 06 f8 9e a9 ca 56 5a ea 2a b8 72 2d 95 5b 
                     key_material_offset: 8
                     stripes: 4000
           | Inactive
           | Inactive
           | Inactive
           | Inactive
           | Inactive
           | Inactive
           | Inactive
```
