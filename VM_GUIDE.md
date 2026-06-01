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

### B. Programmatic input and hotkeys (`--send`)
Sends text, Emacs hotkeys, or commands directly to the active `tmux` session. By default, all arguments are sent literally. You can explicitly switch to sending special keys using the `-K` option:

1. **Console commands (auto-Enter)** — if exactly one text argument is passed (without `-l` or `-K` flags), it behaves as a shortcut that types the text literally and automatically presses `Enter`:
   ```bash
   sbox-connect --send "ls -la"
   sbox-connect --send "make test"
   ```
2. **Hotkeys and special keys (using `-K`)** — switch to special keys mode to pass key combinations:
   ```bash
   sbox-connect --send -K C-x C-f         # Open file search dialog in Emacs
   sbox-connect --send -K C-x C-s         # Save buffer in Emacs
   sbox-connect --send -K C-g             # Cancel current operation in Emacs
   ```
3. **Mixed input (switching between `-l` and `-K`)** — send literal text and special keys in a single command chain:
   ```bash
   sbox-connect --send -K C-x C-f -l "test.org" -K Enter
   sbox-connect --send -l "Hello world" -K Enter
   ```

### C. Reading the session screen (`--read`)
Takes a text screenshot of the active `tmux` pane and prints it to the host terminal (highly useful for automated checks without logging in via SSH):
```bash
sbox-connect --read
```

> [!TIP]
> **Automation Details (`--send` vs `--read`):**
> * The `--send` mode (sending commands) automatically initializes and prepares the `shared` pane in tmux for input before sending.
> * The `--read` mode (reading the screen) strictly requires the `shared` session to be already active (since it captures the pane). If you want to read the screen immediately after the VM starts, first run any command via `--send` or enter the interactive mode.
