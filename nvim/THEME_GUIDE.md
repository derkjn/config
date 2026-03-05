# Theme Customization Guide

## Everforest Theme Options

Your theme is now set to **"hard"** (darkest) background. You can customize it further:

### Background Options
```lua
-- In ~/.config/nvim/lua/plugins/colorscheme.lua

"soft"    -- Lightest, more contrast
"medium"  -- Middle (original setting)
"hard"    -- Darkest (current, recommended for dark environments)
```

### Color Palette Control
Edit `~/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      -- Background darkness: "soft", "medium", or "hard"
      vim.g.everforest_background = "hard"
      
      -- Performance optimization
      vim.g.everforest_better_performance = 1
      
      -- Enable/disable italics
      vim.g.everforest_enable_italic = 1
      
      -- Apply the theme
      vim.cmd.colorscheme("everforest")
    end,
  },
}
```

## Complete Customization Options

### Italics Control
```lua
vim.g.everforest_enable_italic = 0  -- Disable italics
vim.g.everforest_enable_italic = 1  -- Enable italics (default)
```

### Contrast Adjustment
```bash
# To further customize, edit after setting the theme:
vim.cmd("highlight Normal ctermbg=NONE guibg=NONE")  -- Transparent background
vim.cmd("highlight SignColumn guibg=NONE")            -- Transparent sign column
```

## If Text Is Still Too Bright/Dark

### Make Everything Darker (harder to read)
```lua
vim.g.everforest_background = "hard"
vim.g.everforest_dim_foreground = 1
```

### Make Text Brighter (easier on eyes)
```lua
vim.g.everforest_background = "soft"
```

### Alternative: Different Theme Entirely
Try one of these in `~/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
-- Replace "sainnhe/everforest" with one of these:
"EdenEast/nightfox.nvim"        -- Modern, clean themes
"catppuccin/nvim"                -- Warm, pleasant colors
"folke/tokyonight.nvim"           -- Dark, vibrant
"dracula/vim"                      -- High contrast
"gruvbox-community/gruvbox"       -- Warm retro theme
```

## Reload Theme in Neovim

After making changes, you can reload without restarting:

```vim
:colorscheme everforest        " Reload current theme
:Lazy reload colorscheme       " Reload plugin config
```

Or restart Neovim:
```bash
nvim .
```

## Visual Terminal Background Matching

For the best experience, ensure your terminal's background color matches everforest "hard":

```
Background RGB: #1e2326 or #2d353b
```

Configure in your terminal settings:
- **GNOME Terminal**: Preferences → Color
- **Alacritty**: Set in alacritty.yml
- **Kitty**: Set in kitty.conf
- **Warp**: Set in terminal settings

## Current Setup Status

✅ **Theme**: Everforest (hard background - darkest)
✅ **Status**: Ready to use
✅ **Neovim**: v0.12.0+
✅ **Performance**: Optimized

To verify everything loads correctly:
```bash
nvim --version
nvim +quit  # Should start and quit cleanly
```

---

**Pro Tip**: Most "brightness" issues come from:
1. Terminal background not matching theme
2. Font rendering (try enabling bold or adjusting contrast)
3. Monitor brightness/contrast settings

Adjust those before trying different themes!
