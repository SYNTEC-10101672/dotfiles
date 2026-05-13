-- ============================================================================
-- Git 整合設定 (gitsigns)
-- ============================================================================

local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
  return
end

gitsigns.setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil,
  max_file_length = 40000,
  preview_config = {
    border = "rounded",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },

  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    -- Actions
    map("n", "<leader>hs", gs.stage_hunk)
    map("n", "<leader>hr", gs.reset_hunk)
    map("v", "<leader>hs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end)
    map("v", "<leader>hr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end)
    map("n", "<leader>hS", gs.stage_buffer)
    map("n", "<leader>hu", gs.undo_stage_hunk)
    map("n", "<leader>hR", gs.reset_buffer)
    map("n", "<leader>hp", gs.preview_hunk)
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end)
    map("n", "<leader>tb", gs.toggle_current_line_blame)
    map("n", "<leader>hd", gs.diffthis)
    map("n", "<leader>hD", function()
      gs.diffthis("~")
    end)
    map("n", "<leader>td", gs.toggle_deleted)

    local NULL_SHA = string.rep("0", 40)
    local function blame_commit_diff()
      local line = vim.fn.line(".")
      local abs_file = vim.api.nvim_buf_get_name(bufnr)
      local file_dir = vim.fn.fnamemodify(abs_file, ":h")

      -- git tree refs require path relative to git root, not absolute path
      local git_rel = vim.fn.trim(vim.fn.system(
        "git -C " .. vim.fn.shellescape(file_dir) .. " ls-files --full-name -- " .. vim.fn.shellescape(abs_file)
      ))
      if git_rel == "" then
        vim.notify("File not tracked by git", vim.log.levels.WARN)
        return
      end

      local hash = vim.fn.trim(vim.fn.system(
        string.format("git -C %s blame --porcelain -L %d,%d -- %s | head -1 | awk '{print $1}'",
          vim.fn.shellescape(file_dir), line, line, vim.fn.shellescape(abs_file))
      ))
      if hash == "" or hash == NULL_SHA then
        vim.notify("Line not committed yet", vim.log.levels.WARN)
        return
      end

      -- hash^ may not have this file if hash is the first commit introducing it
      vim.fn.system(
        "git -C " .. vim.fn.shellescape(file_dir) ..
        " cat-file -e " .. vim.fn.shellescape(hash .. "^:" .. git_rel) .. " 2>/dev/null"
      )
      if vim.v.shell_error ~= 0 then
        vim.notify("First commit of this file — no parent to diff against", vim.log.levels.INFO)
        return
      end

      -- open blob at hash so Gvdiffsplit diffs hash^ against hash, not the working tree
      vim.cmd("Gedit " .. hash .. ":" .. vim.fn.fnameescape(git_rel))
      vim.cmd("Gvdiffsplit " .. hash .. "^")
    end
    map("n", "<leader>hv", blame_commit_diff, { desc = "Blame commit diff" })

    -- Text object
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
  end,
})
