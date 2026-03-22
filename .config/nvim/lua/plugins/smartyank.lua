-- Enhances the default yank (copy) behavior:
-- - Automatically highlights yanked text
-- - Integrates with system clipboard (works over SSH, tmux, remote sessions)
-- - Makes copy/paste more reliable and visually clear
return {
  {
    "ibhagwan/smartyank.nvim",
    -- Forces the use of OSC 52, which is the only protocol
    -- capable of traversing Docker -> SSH -> Mac
    osc52 = {
      enabled = true,
    },
    -- copy to the system registry at the same time
    clipboard = {
      enabled = true,
    },
  },
}
