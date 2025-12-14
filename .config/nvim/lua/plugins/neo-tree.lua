return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<leader>fe", function() require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() }) end, desc = "Explorer NeoTree (Root Dir)" },
      { "<leader>fE", function() require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() }) end, desc = "Explorer NeoTree (cwd)" },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      -- THIS ENABLES THE VISUAL SELECTION
      enable_modified_markers = true,
      enable_git_status = true,
      default_component_configs = {
        git_status = {
          symbols = {
            unstaged = "❔",
            staged = "S",
          },
        },
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        -- This adds a visual 'check' or indicator when a node is selected
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight_opened_files = true,
        },
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",


          ["m"] = "move",
          ["a"] = "add",
          ["d"] = "delete",
          ["r"] = "rename",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              vim.fn.setreg("+", node:get_id(), "c")
              vim.notify("Path copied to clipboard")
            end,
            desc = "Copy Path",
          },
        },
      },
    },
    config = function(_, opts)
      local events = require("neo-tree.events")

      -- Xcodebuild synchronization logic
      local function sync_xcode(path, action)
        local status, projectManager = pcall(require, "xcodebuild.project.manager")
        if status then
          if action == "add" then
            projectManager.add_file(path, nil, { createGroups = true })
          elseif action == "delete" then
            projectManager.delete_file(path)
          end
        end
      end

      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        {
          event = events.FILE_MOVED,
          handler = function(data)
            Snacks.rename.on_rename_file(data.source, data.destination)
            -- Sync the move with Xcode (Delete old, Add new)
            sync_xcode(data.source, "delete")
            sync_xcode(data.destination, "add")
          end,
        },
        { event = events.FILE_RENAMED, handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end },
        { event = events.FILE_ADDED, handler = function(path) sync_xcode(path, "add") end },
        { event = events.FILE_DELETED, handler = function(path) sync_xcode(path, "delete") end },
      })

      require("neo-tree").setup(opts)
    end,
  },
}
