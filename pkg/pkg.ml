#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let cli = Conf.with_pkg ~default:false "cli"

let () =
  Pkg.describe "luks" @@ fun _c ->
  let cli = Conf.value _c cli in
  Ok [ Pkg.lib "pkg/META"
     ; Pkg.mllib "lib/luks.mllib"
     ; Pkg.bin ~cond:cli "app/oluks" ]
