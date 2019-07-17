# vimfiles

Contains 5 custom plugins and 2 colorschemes.

Plugins:
- method-textobj (300 lines) - Provides textobjects bound by default to `im`,
  `am`, `iM` and `aM`
- mru.vim (100 lines) - Small mru plugin via `:MRU` and `:MRUD`
- statusline.vim (100 lines) - Allows statusline to display current file path
  relative to it's working directory
- search.vim (100 lines) - Upgrades the `s` command in visual mode. After
  pressing `s` and doing the replacement, the `@/` register get’s loaded with
  the changed text. The `.` command repeats the change for the next match. This
  is useful for renaming. Depends on the plugin romainl/vim-cool for
  highlighting.
- modified version of romainl’s plugin `vim-cool`. works with `search.vim` to
  turn off highlighting when cursor moves away from match.

Colorschemes:
- apprentice+apprentice\_extended - Combination of the apprentice colorscheme and
  Jonathan Blow's emacs colorscheme
- strawberry+strawberry\_extended - Modified pink, light colorscheme
