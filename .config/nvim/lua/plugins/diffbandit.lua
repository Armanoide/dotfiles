return {
  {
    'CoreyKaylor/diffbandit.nvim',
    cmd = {
      'DiffBandit',
      'DiffBanditBuffers',
      'DiffBanditFolderDiff',
      'DiffBanditGit',
      'DiffBanditGitCurrent',
      'DiffBanditCommitPanel',
      'DiffBanditGitMenu',
      'DiffBanditGitLog',
      'DiffBanditGitCommit',
      'DiffBanditGitCompare',
      'DiffBanditGitCheckout',
      'DiffBanditMerge',
    },
    keys = {
      { '<leader>gd', '<cmd>DiffBanditGit<cr>', desc = 'Diff working tree' },
      { '<leader>gf', '<cmd>DiffBanditGitCurrent<cr>', desc = 'Diff current file' },
      { '<leader>gH', '<cmd>DiffBanditGitLog<cr>', desc = 'Git log review' },
      { '<leader>gm', '<cmd>DiffBanditMerge<cr>', desc = 'Resolve merge conflict' },
    },
    opts = {},
  },
}
