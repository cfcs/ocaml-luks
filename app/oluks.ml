open Rresult

let cs_of_file name =
  Fpath.of_string name >>= Bos.OS.File.read >>| Cs.of_string
  |> R.reword_error (fun _ -> `Msg "Can't open file for reading")

let do_info _ target =
  cs_of_file target >>= fun header_cs ->
  Luks.parse_phdr header_cs >>| fun phdr ->
  Logs.app (fun m -> m "%a" Luks.pp_phdr phdr)

open Cmdliner

let docs = Manpage.s_options
let sdocs = Manpage.s_common_options

let setup_log =
  let _setup_log (style_renderer:Fmt.style_renderer option) level : unit =
    Fmt_tty.setup_std_outputs ?style_renderer () ;
    Logs.set_level level ;
    Logs.set_reporter (Logs_fmt.reporter ())
  in
  Term.(const _setup_log $ Fmt_cli.style_renderer ~docs:sdocs ()
                        $ Logs_cli.level ~docs:sdocs ())

let target =
  let doc = "Path to target file" in
  Arg.(required & pos 0 (some string) None & info [] ~docv:"FILE" ~docs ~doc)

let info_cmd =
  let doc = "Pretty-print the LUKS header contained in a file" in
  let man = [] in
  Term.(term_result (const do_info $ setup_log $ target)),
  Term.info "oluks" ~doc ~sdocs ~exits:Term.default_exits ~man
    ~man_xrefs:[`Tool "cryptsetup"]

let cmds = [info_cmd]

let () =
  Term.(exit @@ eval info_cmd)
