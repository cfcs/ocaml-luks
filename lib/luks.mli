(** adapted from
    https://gitlab.com/cryptsetup/cryptsetup/wikis/LUKS-standard/on-disk-format.pdf *)

val luks_MAGIC : Cs.t
val luks_KEY_DISABLED : int32
val luks_KEY_ENABLED : int32

type key_slot =
  { iterations: int32;
    salt: Cs.t;
    key_material_offset: int32; (** sector where KM starts *)
    stripes: int32; (** count of "anti-forensic stripes" *)
  }

type phdr =
  { version: int;(** 0x00 or 0x01 *)
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
