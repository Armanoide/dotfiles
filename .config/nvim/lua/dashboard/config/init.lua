-- Function to center a line
local function clean_line(s)
  -- strip ANSI, collapse tabs, trim right
  s = s:gsub("\27%[[0-9;]*m", ""):gsub("\t+", " "):gsub("%s+$", "")
  return s
end

-- helper: measure header width
-- helper: compute header width, capped
return {
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    enabled = true,
    init = false,
    priority = 1000,
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/snacks.nvim" },
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local header = require("dashboard.utils.dan_da_dan")

      -- Header
      dashboard.section.header.val = header.val
      dashboard.section.header.opts.hl = header.opts.hl
      header.load_hl()

      -- Buttons
      -- stylua: ignore
      dashboard.section.buttons.val = {
        dashboard.button("r", " " .. " Recent files", [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),
        dashboard.button("c", " " .. " Config", "<cmd> lua LazyVim.pick.config_files()() <cr>"),
        dashboard.button("x", " " .. " Lazy Extras", "<cmd> LazyExtras <cr>"),
        dashboard.button("l", "󰒲 " .. " Lazy", "<cmd> Lazy <cr>"),
        dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
      }

      -- Apply highlights
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end

      -- local Job = require("plenary.job")
      --
      -- -- Create a new section
      -- local github_section = {
      --   type = "text",
      --   val = { " GitHub Status: Fetching..." },
      --   opts = { hl = "AlphaGithub", position = "center" }
      -- }
      --
      -- -- Add it to the layout
      -- table.insert(dashboard.opts.layout, github_section)
      --
      -- local function header_width(header)
      --   local max_len = 0
      --   for _, line in ipairs(header.val or {}) do
      --     local clean = line:gsub("\27%[[0-9;]*m", "") -- strip ANSI
      --     max_len = math.max(max_len, #clean)
      --   end
      --   return math.min(max_len, 60) -- cap at 60 columns
      -- end
      --
      -- -- Async fetch
      -- Job:new({
      --   command = "gh",
      --   args = { "status", "--color=never" },
      --   on_exit = function(j)
      --     local ok, result = pcall(function() return j:result() end)
      --     if not ok or not result then result = {} end
      --
      --     -- collect cleaned lines
      --     local lines = {}
      --     for _, l in ipairs(result) do
      --       if type(l) == "string" then
      --         l = clean_line(l)
      --         if l ~= "" then table.insert(lines, l) end
      --       end
      --     end
      --
      --     vim.schedule(function()
      --       local counts = { issues = 0, prs = 0, reviews = 0 }
      --       local repo_activity, in_section = {}, nil
      --       local max_repo_len = math.floor((header_width(dashboard.section.header) or 60) * 0.9)
      --
      --       -- parse lines
      --       for _, line in ipairs(lines) do
      --         if line:find("Nothing here ^_^", 1, true) then
      --           -- skip placeholders
      --         else
      --           local low = line:lower()
      --           if low:match("^%s*assigned issues") then
      --             in_section = "issues"
      --           elseif low:match("^%s*assigned pull requests") then
      --             in_section = "prs"
      --           elseif low:match("^%s*review requests") then
      --             in_section = "reviews"
      --           elseif low:match("^%s*repository activity") then
      --             in_section = "activity"
      --           elseif in_section == "activity" then
      --             if #repo_activity < 2 then
      --               local clean = line
      --               if #clean > max_repo_len then
      --                 clean = clean:sub(1, max_repo_len) .. "…"
      --               end
      --               table.insert(repo_activity, clean)
      --             end
      --           elseif in_section == "issues" then
      --             counts.issues = counts.issues + 1
      --           elseif in_section == "prs" then
      --             counts.prs = counts.prs + 1
      --           elseif in_section == "reviews" then
      --             counts.reviews = counts.reviews + 1
      --           end
      --         end
      --       end
      --
      --       -- helper: center text to header width
      --       local function center_to_header(text)
      --         local width = header_width(dashboard.section.header) or 60
      --         local pad = math.floor((width - #text) / 2)
      --         return string.rep(" ", math.max(0, pad)) .. text
      --       end
      --
      --       local sep = string.rep("—", header_width(dashboard.section.header) or 60)
      --
      --       github_section.val = {
      --         sep,
      --         center_to_header("  Github Status"),
      --         sep,
      --         "",
      --         center_to_header(string.format("Issues [%d] | PR [%d] | Review [%d]", counts.issues, counts.prs,
      --           counts.reviews)),
      --         "",
      --         center_to_header("Repository Activity"),
      --         center_to_header(repo_activity[1] or "None"),
      --         center_to_header(repo_activity[2] or ""),
      --       }
      --
      --       pcall(vim.cmd.AlphaRedraw)
      --     end)
      --   end,
      -- }):start()

      -- Define colors
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#6a1b13", bold = true })
      vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#46806e", bold = true })
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#e2e8ea", italic = true })
      vim.api.nvim_set_hl(0, "AlphaGithub", { fg = "#787a76", italic = true })

      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          once = true,
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim aded "
            .. stats.loaded
            .. "/"
             .. stats.count
            .. " plugins in "
            .. ms
              .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
       })
    end,
  }
}
