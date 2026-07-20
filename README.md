# CPWD - Copy Present Working Directory

A simple Zig CLI tool to copy the absolute path of your current working directory to the clipboard. Supports macOS (`pbcopy`) and Linux (`wl-copy` or `xclip`).

## Features

- Auto-detects OS and clipboard tool.
- Prints confirmation with the copied path.
- Lightweight and fast.
- Minimal memory footprint — see [Memory Usage](#memory-usage).

## Prerequisites

- **macOS**: Built-in `pbcopy`.
- **Linux**:
  - Wayland: `wl-clipboard` (`sudo apt install wl-clipboard`).
  - X11: `xclip` (`sudo apt install xclip`).

## Build & Install

1. Ensure Zig 0.15+ is installed.
2. Clone or save `src/main.zig`.
3. Build: `zig build` (or `zig build-exe src/main.zig`).
4. Install: `sudo ./cpwd /usr/local/bin/`.
5. Run: `cpwd` → Path copied! (e.g., `Copied: /home/user/project`).

## Usage

```bash
cpwd
```

Paste with `Cmd+V` (macOS) or `Ctrl+V` (Linux).

## Memory Usage

Memory is kept to the practical minimum for this tool:

| Allocation | Size | Details |
|---|---|---|
| `write_buf` | `max_path_bytes + 16` | Stack buffer sized to hold the full output line (`"Copied: "` + path + `"\n"`) in a single write, avoiding flush overhead. `max_path_bytes` is platform-dependent (1024 on macOS, 4096 on Linux). |
| `read_buf` | 256 bytes | Stdin is never read, so only a minimal allocation is kept for the console I/O API. |
| CWD path | Allocated and freed per invocation | The working directory path is heap-allocated via `currentPathAlloc` and freed with `defer` before the process exits. |

No persistent heap allocations, no dynamic growth, and no unnecessary copies. The binary itself is also kept lean by using only the Zig standard library.

## License

MIT.

---