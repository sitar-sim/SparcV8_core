# log_viewer/

A lightweight, self-contained, single-file browser tool for viewing SPARC
V8 instruction/state traces produced by `CoreLogger`
(`model/cpp_common_code/CoreLogger.h`) -- used by both `model/cpp_model`
and `model/sitar_model`, since both drive the same `SparcCore` and
therefore emit the same trace format.

## What's here

- **`viewer.html`** -- the viewer itself. A single HTML file, no build
  step, no external dependencies (works entirely offline, nothing is
  fetched from the network). Open it directly in any modern browser.
- **`sim_trace.tsv`** / **`sim_trace.objdump`** -- a small sample trace
  and its matching disassembly, generated from the bundled
  `test_simple_ADD` example (see below), so you can explore the viewer
  without building or running anything first.

## Trace format

Tab-separated, one row per architectural event (`FETCH`, `TRAP_RAISED`,
`TRAP_ENTER`, `MEM_READ`, `MEM_WRITE`, `ATOMIC`, `RESET`, `ANNUL`,
`HALT`, or a generic one-off): `seq`, `time`, `pc`, `event`, `detail`,
followed by the entire current-window processor state (PSR fields named
and in binary, general registers in hex). See `CoreLogger.h` for exactly
what each event logs and why. The viewer only requires `seq`/`time`/`pc`/
`event`/`detail` to be present -- any extra columns a future trace source
adds are simply ignored, not required.

## Viewing a trace

1. Build the cpp model with logging enabled, and run a test program:
   ```sh
   model/cpp_model/build.sh --logging
   model/cpp_model/sparc_cpp_sim model/cpp_model/test/test_simple_ADD.hex
   ```
   This writes `sparc_trace.log` into the current directory.
2. Open `log_viewer/viewer.html` in a browser (double-click it, or
   `open log_viewer/viewer.html` / `xdg-open log_viewer/viewer.html`).
3. Click **Load trace** and pick `sparc_trace.log`; click **Load
   objdump** and pick `model/cpp_model/test/test_simple_ADD.objdump`
   (the matching disassembly, committed alongside the test).

### Example: viewing the bundled `test_simple_ADD` example

From the repository root:

```sh
model/cpp_model/build.sh --logging
model/cpp_model/sparc_cpp_sim model/cpp_model/test/test_simple_ADD.hex
open log_viewer/viewer.html   # or: xdg-open log_viewer/viewer.html
```

Then in the viewer: **Load trace** -> `sparc_trace.log` (written into the
repository root, since that's where the command above was run from),
**Load objdump** -> `model/cpp_model/test/test_simple_ADD.objdump`.

### The same, via the sitar model

```sh
model/sitar_model/build.py --logging
model/sitar_model/executable/sitar_check_test \
    model/sitar_model/executable/test_simple_ADD.hex \
    model/sitar_model/executable/test_simple_ADD.expected
```

Writes `sparc_trace.log` (`sparcThread`'s trace, directly loadable, same
as above) and `sitar.log` (everything else Sitar logs -- see
`model/sitar_model/README.md`) into the current directory.

### Optional: serve it for auto-loading

If you'd rather not click through file pickers every time, serve the
directory containing both files and pass them as URL query parameters --
the viewer `fetch()`es them automatically on load:

```sh
cd log_viewer
python3 -m http.server 8000
```

then open `http://localhost:8000/viewer.html?trace=sim_trace.tsv` (the
bundled sample -- the viewer also automatically tries the same basename
with a `.objdump` extension, `sim_trace.objdump` here). For a freshly
generated trace, copy it (and its `.objdump`) into this directory first,
or point `?trace=` at a relative path if your server root already covers
both files. This only works over `http(s)`, not a plain `file://` URL --
browsers block a page from reading another local file just by name.

## Using the viewer

- **Search**: `field=value` (e.g. `PC=0x1c`, `l4=0x3434`, `T=56`) matches
  a specific column; plain text with no `=` searches every column for a
  substring.
- **prev / next**: step through search matches only. Use the **Up/Down**
  arrow keys to step through the trace row by row regardless of search.
- Click a row in the **Trace** panel to select it and see its state.
  Click a line in **Disassembly** to jump to the first trace row at that
  address.
- All three panels (Disassembly, Trace, State) are independently
  resizable -- drag the thin dividers between them.
- Light/dark theme toggle, top right.
