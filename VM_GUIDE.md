# Sandbox (sbox) User Guide

> [!IMPORTANT]
> **Key Rule:** All project build, test, and debugging activities (including AI agent operations) must be executed **inside the virtual machine (VM)** to ensure the safety and security of the host.

---

## 1. Environment Setup and Startup
Build sbox-tools:
```bash
nix-build ~/sbox-tools/default.nix --no-out-link
```
and read the symlink path.

Subsequently, for convenience, all examples will omit the /nix/store prefix, but you must use the command with its full absolute prefix.

## 2. Secure Code Sharing (`/mnt/shared`)

The root of your host project **is not mounted** into the virtual machine to completely protect your `.git` files, configurations, and keys from accidental corruption or compromise by the guest.

* Instead, the guest OS sees the `/mnt/shared` folder in Read-Only mode.
* On the host, this folder is located at `.sbox-runtime/shared/`.
* You can use **Git Worktree** to safely pass code to the guest system without exposing the `.git` commits database itself:
  ```bash
  git worktree add .sbox-runtime/shared
  ```

## 3. `sbox-connect` Utility Modes

The `sbox-connect` utility is your primary control panel for the virtual machine from the host. Four modes are available:

### A. Interactive shared terminal login (tmux) for human users
Connects your terminal to a persistent interactive `tmux` session inside the VM:
```bash
sbox-connect
```
* **Session persistence:** If you close the terminal or lose connection, all processes inside the VM will continue running. The next time you run `sbox-connect`, you will return exactly to where you left off.
* **Pair Programming:** Multiple terminals on the host (both yours and the AI agent's) can connect to the same session simultaneously and see the shared screen in real-time.

### B. Programmatic input and hotkeys (`--run`)
Sends keypresses, Emacs hotkeys, or text commands directly to the active `tmux` session. Supports smart translation and **full support for Cyrillic (UTF-8)** without encoding issues:

1. **Console commands (auto-Enter)** — if exactly one text argument is passed, the script will type it literally and automatically press `Enter`:
   ```bash
   sbox-connect --run "ls -la"
   sbox-connect --run "make test"
   ```
2. **Hotkeys (no auto-Enter)** — pass key combinations without quotes as separate arguments:
   ```bash
   sbox-connect --run C-x C-f         # Open file search dialog in Emacs
   sbox-connect --run C-x C-s         # Save buffer in Emacs
   sbox-connect --run C-g             # Cancel current operation in Emacs
   ```
3. **Mixed input** — chain keys, text, and manual `Enter` together:
   ```bash
   sbox-connect --run C-x C-f "test.org" Enter
   sbox-connect --run "Hello, Sasha Djan!" Enter
   ```

### C. Reading the session screen (`--read`)
Takes a text screenshot of the active `tmux` pane and prints it to the host terminal (highly useful for automated checks without logging in via SSH):
```bash
sbox-connect --read
```

> [!TIP]
> **Automation Details (`--run` vs `--read`):**
> * The `--run` mode (sending commands) automatically initializes and prepares the `shared` pane in tmux for input before sending.
> * The `--read` mode (reading the screen) strictly requires the `shared` session to be already active (since it captures the pane). If you want to read the screen immediately after the VM starts, first run any command via `--run` or enter the interactive mode.
