---
--- LAZY.NVIM BOOTSTRAPPER
---

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{ "neovim/nvim-lspconfig" },
		{
		  	"nvim-tree/nvim-tree.lua",
		  	dependencies = { "nvim-tree/nvim-web-devicons" },
		  	config = function()
				require("nvim-tree").setup({
					sync_root_with_cwd = true,
					modified = {
						enable = true,
						show_on_dirs = true,
						show_on_open_dirs = false,
					  },
					filters = {
						dotfiles = false,
						git_ignored = false,
					},
					view = {
						width = 25,
						preserve_window_proportions = true,
					},
					renderer = {
						icons = {
							glyphs = {
								git = {
									unstaged = "",
								},
								modified = "[+]",
							}
						}
					}
				})
			end
		},
		{ "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000, commit = "d11b3d0" },
		{ "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
		{
			"sainnhe/everforest",
			priority = 1000,
			lazy = false,
			commit = "b03a031",
			config = function()
				vim.g.everforest_background = 'hard'
				vim.g.everforest_enable_italic = 1
				vim.g.everforest_transparent_background = 1
				vim.cmd.colorscheme("everforest")
			end,
		},
		{
			"andweeb/presence.nvim",
			commit = "87c857a",
			config = function()
				require("presence").setup({
					neovim_image_text = "NEOVIM",
					main_image = "file",
					show_time = true,

					editing_text = "editing %s",
					file_explorer_text = "browsing...",
					workspace_text = "repository: %s"
				})
			end
		},
		{
			'nvim-telescope/telescope.nvim', version = '*',
			dependencies = {
				'nvim-lua/plenary.nvim',
			},
			config = function()
				require("telescope").setup({
					pickers = {
						colorscheme = {
							ignore_builtins = true,
							enable_preview = true,
						}
					}
				})
			end
		},
		{ "mason-org/mason.nvim", opts = {} },
  	},
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})

---
--- LSP
---

local lsp_servers = { "lua_ls", "clangd", "pyright", "luau_lsp", "rust_analyzer" }
local lsp_server_overrides = {
	["lua_ls"] = {
		settings = {
			Lua = {
				diagnostics = { globals = {"vim"} },
			},
		},
	},
	["luau_lsp"] = {
		cmd = {
            "luau-lsp",
            "lsp",
            "--definitions=globalTypes.d.luau",
        },
		settings = {
			luau = {
				sourcemap = {
					enabled=true,
					autogenerate = false,
					rojoProjectFile = "default.project.json",
				},
				completion = {
					imports = { enabled = true },
				},
				diagnostics = {
					strictDatamodelTypes = true,
				}
			}
		}
	}
}
for _, server in ipairs(lsp_servers) do
	local opts = lsp_server_overrides[server] or {}
	vim.lsp.config(server, opts)
	vim.lsp.enable(server)
end
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        -- Sets the omnifunc to use LSP completion
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        -- Optional: Move your Rename and Diagnostics keybinds here 
        -- so they only exist when an LSP is actually active!
        local opts = { buffer = bufnr }
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    end,
})

---
--- OTHER CONFIG
---

-- Line Number --
vim.opt.number = true -- enable line number
vim.o.relativenumber = true -- enable relative number
vim.o.cursorline = true -- enable highlighted cursor line

-- Indentation --
vim.o.tabstop = 4     -- number of spaces in a tab
vim.o.shiftwidth = 4  -- number of spaces for auto-indentation
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- File Handling --
vim.opt.autoread = true -- Update editor when file is altered externally
vim.opt.undofile = true -- Save undo history
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Undo history directory

-- Copying, Pasting, Yanking & Clipboard --
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete without yanking" })

-- Disable NetRw inplace of NvimTree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--
-- TERMINAL
--
-- Remove line number in terminal
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    command = "setlocal nonumber norelativenumber",
})
local term_buf = nil
local term_win = nil
function ToggleTerminal()
	-- If window is open on screen, close it.
	if term_win and vim.api.nvim_win_is_valid(term_win) then
		vim.api.nvim_win_close(term_win, true)
		term_win = nil
	else -- Otherwise, open up empty space at the bottom
		vim.cmd("belowright 10split")
		-- Bring up old terminal buffer if it exists
		if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
			vim.api.nvim_win_set_buf(0, term_buf)
		else -- if not, open a new terminal instance
			vim.cmd("term")
			term_buf = vim.api.nvim_get_current_buf()
		end
		term_win = vim.api.nvim_get_current_win()
		vim.cmd("startinsert") -- Automatically put us into terminal mode hehe
	end
end

--
-- COMPLETION
--
vim.cmd('filetype plugin on') -- needed for omni completion
vim.o.omnifunc = 'syntaxcomplete#Complete'
-- Optional: enable spell checking for spell completion
-- vim.o.spell = true -- Enable spell checking
vim.o.wildmenu = true
vim.o.wildmode = 'list:longest'
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.pumheight = 7 -- Number of items to show


--
-- THEME & COLOURS
--
-- Load theme from ~/.config/nvim/current_theme.txt
local theme_file_path = vim.fs.joinpath(vim.fn.stdpath("config"), "current_theme.txt")
local function load_theme_from_file()
	local f = io.open(theme_file_path, "r")

	local extracted_theme = nil
	local theme_exists = nil
	if f then
		extracted_theme = f:read("*all"):gsub("%s+", "")
		f:close()
		theme_exists = pcall(vim.cmd.colorscheme, extracted_theme)
	end

	-- if file does not exist -> create file with 'default' theme
	-- if theme is not found -> write file with 'default theme
	if not extracted_theme or not theme_exists then
		local f_write = io.open(theme_file_path, "w")
		if f_write then
			f_write:write("default")
			f_write:close()
			vim.cmd.colorscheme("default")
			return
		else
			print("Unable to access " .. theme_file_path)
			vim.cmd.colorscheme("default")
			return
		end
	end
end
load_theme_from_file()

-- Border lines
vim.opt.fillchars = {
  stl = ' ',       -- Active statusline blank space
  stlnc = ' ',     -- Inactive statusline blank space
  vert = "│",      -- Vertical separators
  horiz = "─",     -- Horizontal separators
  horizup = "┴",
  horizdown = "┬",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}
-- standard terminal colours defined by the theme
local function apply_custom_colours()
	local line_nr_hl_fg = vim.api.nvim_get_hl(0, { name = "LineNr", link = false }).fg -- Get line number highlight
	local status_ln_bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg -- Status line background
	-- Default to moonfly colours if not defined 
	local term_bla = vim.g.terminal_color_0 or "#323437"
	local term_red = vim.g.terminal_color_1 or "#ff5d5d"
	local term_gre = vim.g.terminal_color_2 or "#8cc85f"
	local term_yel = vim.g.terminal_color_3 or "#e3c78a"
	local term_blu = vim.g.terminal_color_4 or "#80a0ff"
	local term_mag = vim.g.terminal_color_5 or "#cf87e8"
	local term_cya = vim.g.terminal_color_6 or "#79dac8"
	local term_whi = vim.g.terminal_color_7 or "#c6c6c6"

	vim.api.nvim_set_hl(0, "StatusNormal", { fg = term_bla, bg = term_whi, bold = true })
	vim.api.nvim_set_hl(0, "StatusInsert", { fg = term_bla, bg = term_blu, bold = true })
	vim.api.nvim_set_hl(0, "StatusVisual", { fg = term_bla, bg = term_mag, bold = true })
	vim.api.nvim_set_hl(0, "StatusReplace", { fg = term_bla, bg = term_yel, bold = true })
	vim.api.nvim_set_hl(0, "StatusNormal_Round", { fg = term_whi, bg = status_ln_bg, bold = true })
	vim.api.nvim_set_hl(0, "StatusInsert_Round", { fg = term_blu, bg = status_ln_bg, bold = true })
	vim.api.nvim_set_hl(0, "StatusVisual_Round", { fg = term_mag, bg = status_ln_bg, bold = true })
	vim.api.nvim_set_hl(0, "StatusReplace_Round", { fg = term_yel, bg = status_ln_bg, bold = true })

	vim.api.nvim_set_hl(0, "WinSeparator", { fg = line_nr_hl_fg, bg = "none" })

	-- Write this themes name to ~/.config/nvim/current_theme.txt
	local f = io.open(theme_file_path, "w")
	if f then
		f:write(vim.g.colors_name)
		f:close()
	end
end
apply_custom_colours() -- Call on startup
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_custom_colours })


--
-- STATUS LINE & COMMAND LINE
--
-- use global status line
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
local mode_names = {
    ['n']  = 'normal',
    ['i']  = 'insert',
    ['v']  = 'visual',
    ['V']  = 'V-line',
    ['\22'] = '^V-block',
    ['t']  = 'terminal',
	['nt'] = 'normal (terminal)',
	['R'] = 'Replace',
	['ic'] = 'insert (completion)',
}
function MyStatusLine()
    local mode = vim.api.nvim_get_mode().mode
    local mode_hl = "StatusNormal"
    if mode == 'i' or mode == "t" or mode == 'ic' then -- Insert and insert in terminal buffers
        mode_hl = "StatusInsert"
    elseif mode == "v" or mode == "V" or mode == "\22" then -- Visual, visual line, visual block
        mode_hl = "StatusVisual"
    elseif mode == 'R' then
        mode_hl = "StatusReplace"
    end
	local mode_name = mode_names[mode] or mode

	local readonly_text = ""
	if vim.bo.readonly then
		readonly_text = "[READ ONLY!]"
	end

    -- Return the string with the highlight tag
    -- %f is filename, %m is modified, %= is align right
	return string.format(
        "%%#%s# %s %%#%s_Round#%%#StatusLine# %%f %%m %s %%= line %%l/%%L chara %%c ",
        mode_hl, mode_name, mode_hl, readonly_text
    )
end
vim.opt.statusline = "%!v:lua.MyStatusLine()"

--
-- KEYBINDS
--
-- Leader Keybinds
vim.g.mapleader = " "
vim.api.nvim_set_keymap('n', '<leader>ct', ':Telescope colorscheme<CR>', { noremap = true, silent = true }) -- CHANGE THEME
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle NvimTree' })

local cheatsheet_path = vim.fs.joinpath(vim.fn.stdpath("config"), "cheatsheet.md")
vim.api.nvim_set_keymap('n', '<leader>cs', ':tabedit ' .. cheatsheet_path .. '<CR>', { noremap = true, silent = true }) -- CHEATSHEET

vim.keymap.set('n', '<leader>t', ToggleTerminal, {silent = true}) -- TERMINAL

local config_path = vim.fs.joinpath(vim.fn.stdpath("config"), "init.lua")
vim.api.nvim_set_keymap('n', '<leader>co', ':e ' .. config_path .. '<CR>', { noremap = true, silent = true }) -- CONFIG

vim.api.nvim_set_keymap('n', '<leader>do', '<Cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true }) -- DIAGNOSTICS OPEN
-- Insert-mode Keybinds
vim.api.nvim_set_keymap('i', '<C-Space>', '<C-x><C-o>', { noremap = true, silent = true }) -- SUGGESTIONS
-- Terminal-mode Keybinds
vim.api.nvim_set_keymap('t', '<C-Esc>', [[<C-\><C-n>]], { noremap = true, silent = true }) -- ESCAPE
vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], { silent = true })
-- Rename Symbols
--vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP rename' })
--
-- DIAGNOSTICS
--
vim.diagnostic.config({
	virtual_text = true, -- Inline diagnostics
  	signs = true, -- Show symbols in gutter
	underline = true,
  	update_in_insert = false,
})
local original_open_float = vim.diagnostic.open_float
vim.diagnostic.open_float = function(bufnr, opts)
  opts = opts or {}
  opts.border    = opts.border or "rounded"
  opts.focusable = opts.focusable or false
  opts.source    = opts.source or "always"
  opts.header    = opts.header or "DIAGNOSTICS"
  opts.prefix    = opts.prefix or "* "
	vim.cmd [[
		highlight! link NormalFloat Normal
	  	highlight! link FloatBorder Comment
	]]
  return original_open_float(bufnr, opts)
end
