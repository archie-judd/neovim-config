# claude.nvim — Plugin Specification

A Neovim-native interface to the Claude Agent SDK. The plugin provides a chat UI with a read-only conversation buffer, a compose buffer for writing prompts, and contextual tooling for sharing code, files, and variables with Claude. It delegates all AI orchestration to the Agent SDK via a Node.js sidecar process.

---

## 1. Architecture

### 1.1 Overview

```
┌─────────────────────────────────────────┐
│ Neovim                                  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ Chat Buffer (read-only)           │  │
│  │ - Streamed conversation history   │  │
│  │ - Tool output in folds            │  │
│  │ - Edit proposals as summary lines │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ Compose Buffer (editable)         │  │
│  │ - nvim-cmp sources: /, @          │  │
│  │ - Variable expansion: ${...}      │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────┐               │
│  │ Transient Floats     │               │
│  │ - Diff review        │               │
│  │ - vim.ui.select      │               │
│  │ - Full tool output   │               │
│  └─────────────────────┘               │
│                                         │
└────────────┬────────────────────────────┘
             │ JSON-RPC over stdio
             │
┌────────────▼────────────────────────────┐
│ Node.js Sidecar                         │
│ - Claude Agent SDK                      │
│ - Session management                    │
│ - Streams messages back to Neovim       │
└─────────────────────────────────────────┘
```

### 1.2 Node.js Sidecar

The sidecar is a small Node.js process that wraps the Claude Agent SDK. Neovim communicates with it over stdio using JSON-RPC.

**Sidecar responsibilities:**
- Call `query()` from the Agent SDK with the user's prompt and options
- Stream message events (assistant text, tool use, tool results, permission requests) back to Neovim as JSON-RPC notifications
- Manage session IDs (create, resume, list)
- Expose available slash commands and their metadata

**Sidecar does NOT:**
- Manage UI, buffers, or windows
- Make decisions about how to render content
- Persist anything beyond what the SDK already persists

**JSON-RPC methods (Neovim → Sidecar):**
- `send_prompt(params: { prompt: string, session_id?: string, mode?: string })` — Send a prompt to Claude. Responses stream back as notifications.
- `respond_permission(params: { request_id: string, decision: "allow" | "deny" | "allow_always" })` — Respond to a permission request.
- `list_sessions(params: { cwd: string })` — List available sessions for the current project.
- `resume_session(params: { session_id: string })` — Resume a session and return its message history.
- `get_slash_commands()` — Return available slash commands with descriptions.
- `compact()` — Trigger manual context compaction.

**JSON-RPC notifications (Sidecar → Neovim):**
- `on_assistant_text(params: { text: string, done: boolean })` — Streaming text chunk from Claude. `done: true` on final chunk.
- `on_tool_use(params: { tool_name: string, tool_input: object, request_id: string })` — Claude wants to use a tool.
- `on_tool_result(params: { tool_name: string, summary: string, output: string })` — Result of a tool execution.
- `on_permission_request(params: { request_id: string, tool_name: string, tool_input: object, description: string })` — Claude needs approval to proceed.
- `on_error(params: { message: string })` — An error occurred.
- `on_session_info(params: { session_id: string, model: string, cost?: number })` — Session metadata updates.

### 1.3 Process Lifecycle

- The sidecar starts on first use (`:Claude` or any keybind that opens the chat).
- It runs for the lifetime of the Neovim session.
- On `VimLeavePre`, send a shutdown signal and wait briefly for cleanup.
- If the sidecar crashes, show an error in the chat buffer and allow restart via `:ClaudeRestart`.

---

## 2. UI Layout

### 2.1 Window Structure

The plugin opens a vertical split (configurable) containing two buffers stacked vertically:

```
┌─────────────────────────────────┐
│                                 │
│  Chat Buffer                    │
│  (read-only, scrollable)        │
│                                 │
│                                 │
├─────────────────────────────────┤
│  Compose Buffer (3-5 lines)     │
│  (editable, cmp-enabled)        │
└─────────────────────────────────┘
```

**Chat buffer:**
- `buftype=nofile`, `modifiable=false` (set temporarily modifiable when appending)
- Filetype: `claude-chat` (custom, for syntax highlighting and fold support)
- `foldmethod=marker` with custom fold markers for tool output
- Auto-scrolls to bottom during streaming (unless user has scrolled up)
- Keybind on tool summary lines to open full output in a float

**Compose buffer:**
- Normal editable buffer
- Filetype: `claude-prompt` (custom, for cmp source registration)
- Default height: 3 lines, expandable via keybind (toggle to ~15 lines)
- `<CR>` in normal mode sends the prompt (configurable)
- Buffer is cleared after sending

### 2.2 Chat Buffer Rendering

Messages are rendered as blocks separated by blank lines. Each block has a role marker.

```
## You

Refactor the auth module to use JWT tokens instead of session cookies.
Context: @src/auth/session.ts, @src/middleware/auth.ts

## Claude

I'll refactor the auth module. Let me start by reading the current implementation.

▶ Read src/auth/session.ts (87 lines) ··········· {{{tool
[full file contents here, hidden by fold]
}}}tool

▶ Read src/middleware/auth.ts (42 lines) ········ {{{tool
[full file contents here, hidden by fold]
}}}tool

I can see the session-based approach. Here's my plan:

1. Replace `express-session` with `jsonwebtoken`
2. ...

▶ Edit src/auth/session.ts ······················ [Review]
▶ Edit src/middleware/auth.ts ··················· [Review]
▶ Ran npm test (14 passed, 0 failed) ··········· {{{tool
[full test output here, hidden by fold]
}}}tool

All tests pass. The refactoring is complete.
```

**Rendering rules:**
- Assistant text is rendered as markdown (treesitter `markdown` injection if possible).
- Tool use events render as a single summary line: `▶ {tool_name} {brief_description}`.
- Tool results for read-only tools (Read, Glob, Grep, Bash) are appended inside fold markers and auto-folded.
- Tool results for edit tools (Edit, Write) render as a summary line with a `[Review]` marker. Pressing `<CR>` or `gd` on this line opens the diff float.
- Permission requests pause streaming and trigger `vim.ui.select` or the diff float (see §4).
- Streaming text appends character-by-character or chunk-by-chunk. The buffer auto-scrolls unless the user's cursor is above the last visible line.

### 2.3 Syntax Highlighting

Define highlights for the `claude-chat` filetype:

- `ClaudeChatUser` — "## You" header (bold, accent color)
- `ClaudeChatAssistant` — "## Claude" header (bold, different accent)
- `ClaudeChatToolLine` — `▶ ...` summary lines (dimmed)
- `ClaudeChatReview` — `[Review]` marker (standout, actionable)
- `ClaudeChatFoldText` — custom `foldtext` showing the summary line cleanly
- Markdown content inherits from treesitter markdown highlighting

---

## 3. Compose Buffer & Input

### 3.1 Sending Prompts

- `<CR>` in normal mode sends the buffer contents as a prompt.
- `<S-CR>` or `<C-CR>` inserts a newline (for multi-line prompts).
- After sending, the buffer is cleared and the prompt appears in the chat buffer under `## You`.
- While Claude is responding, the compose buffer remains editable but sending is disabled (queued or rejected with a message).

### 3.2 Completion Sources (nvim-cmp)

Register two custom cmp sources for the `claude-prompt` filetype:

**Slash commands (`/`):**
- Trigger: `/` as the first character on a line.
- Source: query the sidecar's `get_slash_commands()` on plugin init, cache the results.
- Items: `{ label = "/plan", detail = "Switch to plan mode" }`, etc.
- Include both built-in commands (`/plan`, `/compact`, `/clear`, `/model`) and custom commands from `.claude/commands/`.

**File references (`@`):**
- Trigger: `@` character.
- Source: async file finder scoped to the project root (git root or cwd).
- Use `vim.fn.glob()` or `plenary.scandir` for file listing, with fuzzy matching.
- On completion, inserts `@path/to/file` into the prompt.
- Respect `.gitignore` for filtering.

### 3.3 Variable Expansion

The compose buffer supports `${...}` variables that are expanded before sending to the sidecar.

**Built-in variables:**
- `${git_diff}` — Output of `git diff` (staged + unstaged)
- `${git_diff_staged}` — Output of `git diff --staged`
- `${git_log}` — Recent git log (last 10 commits, one-line format)
- `${selection}` — The most recent visual selection (see §3.4)
- `${file}` — The full contents of the current file (the file that was focused before opening the chat)
- `${filetype}` — The filetype of the current file
- `${diagnostics}` — LSP diagnostics for the current file

Variables are expanded by the Lua plugin before being sent to the sidecar. Unknown variables are left as-is (not an error).

### 3.4 Visual Selection Context

From any buffer, the user can visually select code and invoke a keybind (default `<leader>cs`) to:

1. Yank the selection with file path and line numbers.
2. Open the chat UI (if not already open).
3. Insert a context block into the compose buffer:

```
`src/auth/session.ts:12-45`
```typescript
[selected code here]
`` `
```

The user can then type their prompt below this block.

### 3.5 Telescope Multi-Select

A keybind (default `<leader>cf`) opens a Telescope picker for project files. Multi-select is enabled. On confirm, the selected file paths are inserted into the compose buffer as `@path/to/file` references, one per line.

This is for bulk context attachment, complementing the inline `@` completion for single files.

---

## 4. Permission System

### 4.1 Permission Flow

When the sidecar emits `on_permission_request`, the plugin must collect a decision before the conversation can continue.

**For non-edit tools** (Bash, WebSearch, etc.):
- Show `vim.ui.select` with options: `["Allow", "Allow Always", "Deny"]`.
- Include the tool name and a description (e.g., `Bash: npm test`).
- Send the decision back via `respond_permission`.

**For edit tools** (Edit, Write):
- Open the diff review float (see §4.2).
- The float includes keybinds for Accept / Reject.
- On accept, send `allow` via `respond_permission`.
- On reject, send `deny` via `respond_permission`.

### 4.2 Diff Review Float

When Claude proposes a file edit and needs approval, the plugin opens a floating window with a vertical diff.

**Layout:**

```
┌─ Proposed Edit: src/auth/session.ts ─────────┐
│                                               │
│  current file     │  proposed change          │
│  (read-only)      │  (read-only)              │
│                   │                           │
│  :diffthis        │  :diffthis                │
│                   │                           │
├───────────────────────────────────────────────┤
│  [a]ccept  [r]eject  [q]uit (same as reject)  │
└───────────────────────────────────────────────┘
```

**Implementation:**
- Create a floating window sized to 80% of the editor.
- Inside the float, create two vertical splits.
- Left: load the current file contents into a scratch buffer.
- Right: load the proposed file contents (from the tool input) into a scratch buffer.
- Run `:diffthis` on both buffers.
- Map `a` to accept (close float, send allow), `r`/`q` to reject (close float, send deny).
- Both buffers are `nomodifiable`.
- On close, clean up all buffers and restore focus to the compose buffer.

**Edge cases:**
- New file creation: left side shows an empty buffer, right side shows the proposed contents. Skip `:diffthis`, just show the new file.
- File deletion: show the current file on the left, empty on the right, with a confirmation prompt.
- Multiple edits in sequence: each one opens a new float after the previous is dismissed.

---

## 5. Session Management

### 5.1 Session Scoping

Sessions are scoped to the project root (git root, or cwd if no git repo). The sidecar passes the cwd to the Agent SDK, which handles session persistence internally.

The plugin maintains a lightweight index file at `<project_root>/.claude/nvim-sessions.json`:

```json
[
  {
    "session_id": "abc123",
    "label": "JWT refactor",
    "created_at": "2026-03-19T10:30:00Z",
    "last_used_at": "2026-03-19T11:45:00Z",
    "first_prompt": "Refactor the auth module to use JWT tokens"
  }
]
```

### 5.2 Commands

- `:Claude` — Open the chat UI. Resumes the most recent session, or starts a new one if none exists.
- `:ClaudeNew` — Start a new session (clears chat buffer, gets a new session ID).
- `:ClaudeSessions` — Open a Telescope picker listing sessions for the current project. Selecting one resumes it and replays message history into the chat buffer.
- `:ClaudeRestart` — Kill and restart the sidecar process.
- `:ClaudeClose` — Close the chat UI but keep the sidecar running (session is preserved).

### 5.3 Session Switching

When resuming a session:
1. Clear the chat buffer.
2. Call `resume_session` on the sidecar with the session ID.
3. The sidecar returns the message history.
4. Replay all messages into the chat buffer using the same rendering logic as live streaming (but without delays).
5. All folds are set up as they would be during a live session.

---

## 6. Configuration

```lua
require("claude").setup({
  -- UI
  window = {
    position = "right",      -- "right", "left", "bottom", "float"
    width = 0.35,            -- fraction of editor width (for left/right)
    height = 0.4,            -- fraction of editor height (for bottom)
    compose_height = 3,      -- default compose buffer height in lines
    compose_height_expanded = 15,
  },

  -- Agent SDK options
  sdk = {
    model = "sonnet",        -- default model
    permission_mode = "default", -- "default", "acceptEdits", "bypassPermissions"
    allowed_tools = nil,     -- nil means all defaults; or a list like {"Read", "Edit", "Bash"}
    setting_sources = { "project" }, -- load CLAUDE.md, skills, hooks from filesystem
  },

  -- Keymaps (set to false to disable)
  keymaps = {
    toggle = "<leader>cc",       -- toggle chat UI
    send = "<CR>",               -- send prompt (normal mode in compose buffer)
    new_session = "<leader>cn",  -- new session
    sessions = "<leader>cs",     -- session picker
    send_selection = "<leader>cs", -- send visual selection to compose buffer
    file_picker = "<leader>cf",  -- telescope file picker for context
    expand_compose = "<leader>ce", -- toggle compose buffer height
    scroll_up = "<C-u>",        -- scroll chat buffer up (from compose buffer)
    scroll_down = "<C-d>",      -- scroll chat buffer down (from compose buffer)
  },

  -- Diff review float
  diff = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
    keymaps = {
      accept = "a",
      reject = "r",
      quit = "q",
    },
  },

  -- Variables
  variables = {
    git_diff = "git diff",
    git_diff_staged = "git diff --staged",
    git_log = "git log --oneline -10",
    -- users can add custom variables as shell commands
  },
})
```

---

## 7. Dependencies

**Required:**
- Neovim >= 0.10
- Node.js >= 18 (for the sidecar)
- `@anthropic-ai/claude-agent-sdk` (npm, installed by the plugin or by the user)
- An Anthropic API key (set via `ANTHROPIC_API_KEY`)

**Optional but recommended:**
- `nvim-cmp` — for `/` and `@` completion in the compose buffer
- `telescope.nvim` — for session picker and bulk file selection
- `dressing.nvim` — for improved `vim.ui.select` appearance
- `nvim-treesitter` — for markdown highlighting in the chat buffer

---

## 8. File Structure

```
claude.nvim/
├── lua/
│   └── claude/
│       ├── init.lua              -- setup(), public API
│       ├── config.lua            -- configuration merging and defaults
│       ├── sidecar.lua           -- sidecar process management, JSON-RPC
│       ├── ui/
│       │   ├── layout.lua        -- window/buffer creation and management
│       │   ├── chat.lua          -- chat buffer rendering, folds, highlighting
│       │   ├── compose.lua       -- compose buffer logic, variable expansion
│       │   └── diff.lua          -- diff review floating window
│       ├── context/
│       │   ├── selection.lua     -- visual selection capture
│       │   ├── variables.lua     -- variable expansion (${git_diff}, etc.)
│       │   └── files.lua         -- file reference resolution
│       ├── completion/
│       │   ├── slash.lua         -- cmp source for slash commands
│       │   └── files.lua         -- cmp source for @file references
│       ├── sessions.lua          -- session index management
│       └── telescope/
│           ├── sessions.lua      -- telescope picker for sessions
│           └── files.lua         -- telescope picker for bulk file attach
├── sidecar/
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts              -- entry point, JSON-RPC server over stdio
│       ├── agent.ts              -- Agent SDK wrapper, query/session management
│       ├── protocol.ts           -- JSON-RPC message types and handlers
│       └── permissions.ts        -- permission request forwarding
├── syntax/
│   └── claude-chat.vim           -- syntax highlighting for chat buffer
├── ftplugin/
│   ├── claude-chat.lua           -- buffer-local settings for chat
│   └── claude-prompt.lua         -- buffer-local settings for compose
└── plugin/
    └── claude.lua                -- command definitions (:Claude, :ClaudeNew, etc.)
```

---

## 9. Implementation Notes

### 9.1 Streaming

The sidecar streams `on_assistant_text` notifications as chunks arrive from the SDK. The Lua side appends text to the chat buffer in a `vim.schedule` callback to avoid race conditions with the event loop.

During streaming:
- Set the chat buffer to modifiable, append text, set it back to nomodifiable.
- Track whether the user has scrolled up. If not, auto-scroll to the bottom after each append.
- The compose buffer remains fully functional during streaming.

### 9.2 Fold Management

Tool output is wrapped in fold markers as it is appended to the chat buffer:

```
▶ Read src/utils.ts (42 lines) {{{tool
[contents]
}}}tool
```

Immediately after appending the closing marker, set the fold to closed via `vim.cmd(":{line_start},{line_end}foldclose")`.

Custom `foldtext` function returns the first line of the fold (the summary line) for a clean appearance.

### 9.3 Scroll Anchoring

Before appending to the chat buffer, check if the user's view includes the last line:

```lua
local win = chat_window_id
local last_line = vim.api.nvim_buf_line_count(chat_buf)
local visible_end = vim.fn.line("w$", win)
local should_scroll = (visible_end >= last_line - 1)
```

After appending, if `should_scroll`, set the cursor to the new last line.

### 9.4 JSON-RPC over Stdio

Use `vim.loop.spawn` to start the sidecar, with `stdio = {stdin_pipe, stdout_pipe, stderr_pipe}`.

Read stdout line-by-line (newline-delimited JSON). Each line is a JSON-RPC message. Parse with `vim.json.decode`, dispatch based on `method` field.

Write to stdin with `stdin_pipe:write(vim.json.encode(message) .. "\n")`.

### 9.5 Sidecar Installation

On first run, check if `sidecar/node_modules` exists. If not, run `npm install` in the sidecar directory. Show a progress message in the chat buffer. This is a one-time setup.
