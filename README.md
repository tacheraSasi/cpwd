# CPWD - Copy Present Working Directory

A simple Zig CLI tool to copy the absolute path of your current working directory to the clipboard. Supports macOS (`pbcopy`) and Linux (`wl-copy` or `xclip`).

## Features

- Auto-detects OS and clipboard tool.
- Prints confirmation with the copied path.
- Lightweight and fast.

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

## License

MIT.

---