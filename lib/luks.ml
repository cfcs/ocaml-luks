let luks_MAGIC = "LUKS\xBA\xBE"
let luks_KEY_DISABLED = 57005l

open Rresult

type key_slot =
  { iterations: int32;
    salt: Cs.t;
    key_material_offset: int32;
    stripes: int32;
  }

let pp_key_slot fmt k =
  Fmt.pf fmt "Active: @[<v>iterations: %ld@,salt: %a@,key_material_offset: %ld\
              @,stripes: %ld@]"
    k.iterations Cstruct.hexdump_pp k.salt k.key_material_offset k.stripes

let pp_key_slots fmt slots =
  Fmt.pf fmt "@[<v>| %a@]"
    Fmt.(array ~sep:(unit "@,| ")
           (option ~none:(unit "Inactive") pp_key_slot)) slots

let parse_key_slot cs : (key_slot option,'e) result =
  let r = Cs.R.of_cs (`Msg "Couldn't parse LUKS key slot") cs in
  Cs.R.uint32 r >>| Int32.equal luks_KEY_DISABLED >>= function
  | true -> Ok None
  | false ->
  Cs.R.uint32 r >>= fun iterations ->
  Cs.R.cs r 32  >>= fun salt ->
  Cs.R.uint32 r >>= fun key_material_offset ->
  Cs.R.uint32 r >>| fun stripes ->
  Some {iterations;salt;key_material_offset;stripes;}

type phdr =
  { version: int;
    cipher_name: string;
    cipher_mode: string;
    hash_spec: string;
    payload_offset: int32;
    key_bytes: int32;
    mk_digest: Cs.t;
    mk_digest_salt: Cs.t;
    mk_digest_iter: int32;
    uuid: string;
    key_slots: key_slot option array;
  }

let pp_phdr_with_master_key fmt p =
  Fmt.pf fmt "@[<v>LUKS version: %d@,cipher name: %S, mode: %S\
              @,hash spec: %S\ payload offset: %ld key bytes: %ld\
              @,master key digest: %a@,master key digest salt: %a\
              @,master key digest iterations: %ld\
              @,UUID: %S\
              @,key slots: %a@]"
    p.version
    p.cipher_name
    p.cipher_mode
    p.hash_spec
    p.payload_offset
    p.key_bytes
    Cstruct.hexdump_pp p.mk_digest Cstruct.hexdump_pp p.mk_digest_salt
    p.mk_digest_iter
    p.uuid
    pp_key_slots p.key_slots

let pp_phdr fmt p =
  pp_phdr_with_master_key fmt
    {p with mk_digest = Cs.empty; mk_digest_salt = Cs.empty}

let parse_phdr cs =
  let r = Cs.R.of_cs (`Msg "Couldn't parse LUKS PHDR") cs in
  Cs.R.cs r 6 >>= Cs.e_equal_string (`Msg "Invalid magic") luks_MAGIC >>=fun()->
  Cs.R.uint16 r >>= fun version ->
  Cs.R.string_z r 32 >>= fun cipher_name ->
  Cs.R.string_z r 32 >>= fun cipher_mode ->
  Cs.R.string_z r 32 >>= fun hash_spec ->
  Cs.R.uint32 r >>= fun payload_offset ->
  Cs.R.uint32 r >>= fun key_bytes ->
  Cs.R.cs r 20  >>= fun mk_digest ->
  Cs.R.cs r 32  >>= fun mk_digest_salt ->
  Cs.R.uint32 r >>= fun mk_digest_iter ->
  Cs.R.string_z r 40  >>= fun uuid ->
  let key_slots = Array.make 8 None in
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 0 >>= fun () ->
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 1 >>= fun () ->
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 2 >>= fun () ->
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 3 >>= fun () ->
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 4 >>= fun () ->
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 5 >>= fun () ->
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 6 >>= fun () ->
  Cs.R.cs r 48  >>= parse_key_slot >>| Array.set key_slots 7 >>| fun () ->
  { version;
    cipher_name;
    cipher_mode;
    hash_spec;
    payload_offset;
    key_bytes;
    mk_digest;
    mk_digest_salt;
    mk_digest_iter;
    uuid;
    key_slots;
  }
