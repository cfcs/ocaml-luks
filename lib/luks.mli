type key_slot =
  { iterations: int32;
    salt: Cs.t;
    key_material_offset: int32;
    stripes: int32;
  }

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

val parse_phdr : Cs.t -> (phdr, [> `Msg of string ]) Result.result
val pp_key_slot : Format.formatter -> key_slot -> unit
val pp_key_slots : Format.formatter -> key_slot option array -> unit
val pp_phdr : Format.formatter -> phdr -> unit
val pp_phdr_with_master_key : Format.formatter -> phdr -> unit
