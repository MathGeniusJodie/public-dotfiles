local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"neovim/nvim-lspconfig",
	"nvim-treesitter/nvim-treesitter",
	"zbirenbaum/copilot.lua"
})

require("copilot").setup({
	suggestion = {
		auto_trigger = true,
		keymap = {
			accept = false
		}
	}
})

vim.keymap.set('i', '<Tab>', function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, { desc = "Super Tab" })

-- sane defaults
vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.swapfile = false
vim.opt.lazyredraw = true

-- personal preferences
vim.opt.laststatus = 0
vim.opt.statusline = "%="
vim.opt.list = true
vim.opt.listchars = {tab = ":  ", trail = "·"}
vim.opt.fillchars = {vert = "│", horiz= "─", stl = " ", stlnc = " "}
vim.opt.signcolumn= "no"
vim.opt.winbar = "%{%v:lua.JodieBuffline()%}"
vim.opt.termguicolors = true

vim.opt.clipboard = "unnamedplus"
vim.keymap.set("v", "<BS>", '"_d')

-- todo use autocmd to update this
vim.loop.new_timer():start(0, 1000, vim.schedule_wrap(function()
	vim.opt.winbar = "%{%v:lua.JodieBuffline()%}"
end))


function CloseTab(index)
	vim.cmd("bd! "..index)
end

function SwitchBuff(encoded)
	local index = math.floor(encoded/2048)
	local current_win = encoded%2048
	vim.api.nvim_set_current_win(current_win)
	vim.api.nvim_set_current_buf(index)
	--vim.cmd("b "..index)
end

function SwitchWin(current_win)
	vim.api.nvim_set_current_win(current_win)
end

function SplitWin(current_win)
	vim.api.nvim_set_current_win(current_win)
	vim.cmd("split")
end

function VsplitWin(current_win)
	vim.api.nvim_set_current_win(current_win)
	vim.cmd("vsplit")
end

function CloseWin(current_win)
	vim.api.nvim_win_close(current_win,false)
end

function TermWin(current_win)
	vim.api.nvim_set_current_win(current_win)
	vim.cmd("terminal")
end

function JodieBuffline()
	local current_win = vim.api.nvim_get_current_win()
	local s = '%#TabLineFill# '

	for index = 1, vim.fn.bufnr('$') do
		local bufnr = index
		pcall(function()
			if vim.bo[bufnr] ~= nil and vim.bo[bufnr].buflisted and (index==vim.fn.bufnr() or vim.fn.bufwinnr(bufnr) == -1) then
				local bufname = vim.fn.bufname(bufnr)
				local bufmodified = vim.fn.getbufvar(bufnr, '&mod')

				s = s .. '%' .. (index*2048+current_win) .. '@v:lua.SwitchBuff@'
				if index == vim.fn.bufnr() then
					s = s .. '%#TabLineSel#'
				else
					s = s .. '%#TabLine#'
				end

				s = s .. ' '

				if bufname ~= '' then
					s = s .. vim.fn.fnamemodify(bufname, ':t')
				else
					s = s .. "unnamed file"
				end

				s = s .. '%X'

				if bufmodified == 1 then
					if index == vim.fn.bufnr() then
						s = s..'%#Redfg# •'
					else
						s = s..'%#RedfgBlabg# •'
					end
				else
					s = s .. ' %' .. index .. '@v:lua.CloseTab@✕%X'
				end
				s = s..' '
			end
		end)
	end
	s = s .. "%#TabLineFill#%"..current_win.."@v:lua.SwitchWin@%=%X%#TabLine#"
	s = s .. "%"..current_win.."@v:lua.TermWin@>%X "
	s = s .. "%"..current_win.."@v:lua.SplitWin@−%X "
	s = s .. "%"..current_win.."@v:lua.VsplitWin@/%X "
	if vim.fn.winnr("$") > 1 then
		s = s .. "%"..current_win.."@v:lua.CloseWin@✕%X "
	end
	return s
end

--[[
-- tab completion without copilot
local previous_character_is_nonword = function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	if col == 0 then
		return true
	end
	local char = line:sub(col, col+1)
	return char==" " or char==nil or char =="\t"
end

complete_or_tab = function()
	if previous_character_is_nonword() then
		return "<Tab>"
	else
		return "<C-x><C-o>"
	end
end

vim.keymap.set("i", "<Tab>", "v:lua.complete_or_tab()", {expr=true})
--]]

--[[
	/* 8 normal colors */
0	"#000000",
1	"#c82829",
2	"#718c00",
3	"#f5871f",
4	"#4271ae",
5	"#8959a8",
6	"#3e999f",
7	"#eeeeec",
	/* 8 bright colors */
8	"#555555",
9	"#cc6666",
10	"#b5bd68",
11	"#f0c674",
12	"#81a2be",
13	"#b294bb",
14	"#8abeb7",
15	"#ffffff",
--]]


vim.api.nvim_exec([[

hi DiffAdd      ctermfg=0    ctermbg=10 guifg=#000000 guibg=#b5bd68
hi DiffChange   ctermfg=0    ctermbg=11 guifg=#000000 guibg=#f0c674
hi DiffDelete   ctermfg=0    ctermbg=9 guifg=#000000 guibg=#cc6666
hi DiffText     ctermfg=0    ctermbg=11   cterm=bold guifg=#000000 guibg=#f0c674 gui=bold

hi Visual       ctermfg=NONE ctermbg=NONE cterm=inverse
hi Search       ctermfg=0    ctermbg=11  cterm=bold guifg=#000000 guibg=#f0c674

hi LineNr       ctermfg=8   guifg=#555555
hi CursorLineNr ctermfg=7   guifg=#eeeeec
hi Comment      ctermfg=8   guifg=#555555
hi ColorColumn  ctermfg=7    ctermbg=8  guifg=#eeeeec guibg=#555555
hi Folded       ctermfg=7    ctermbg=8  guifg=#eeeeec guibg=#555555
hi FoldColumn   ctermfg=7    ctermbg=8  guifg=#eeeeec guibg=#555555
hi Pmenu        ctermfg=15   ctermbg=8	 guifg=#ffffff guibg=#555555
hi PmenuSel     ctermfg=8    ctermbg=15  guifg=#555555 guibg=#ffffff
hi SpellCap     ctermfg=7    ctermbg=8  guifg=#eeeeec guibg=#555555
hi StatusLine   ctermfg=5   ctermbg=0    cterm=bold guifg=#000000 guibg=#000000 gui=bold
hi StatusLineNC ctermfg=5    ctermbg=0    cterm=bold guifg=#000000 guibg=#000000 gui=bold
hi SignColumn                ctermbg=8   guibg=#555555

hi Constant       ctermfg=9  guifg=#cc6666
hi Identifier     cterm=NONE ctermfg=7  guifg=#eeeeec gui=NONE
hi PreProc        ctermfg=13 guifg=#b294bb
hi Special        ctermfg=13 guifg=#b294bb
hi Statement      cterm=None ctermfg=11 guifg=#f0c674
hi Title          ctermfg=13 cterm=bold guifg=#b294bb gui=bold
hi Type           ctermfg=10 guifg=#b5bd68
hi Underlined     cterm=underline gui=underline
hi TabLineFill    ctermfg=8 ctermbg=7 guifg=#555555 guibg=#eeeeec
hi TabLine        cterm=bold ctermfg=7 ctermbg=8 guifg=#eeeeec guibg=#555555 gui=bold
hi TabLineSel     cterm=bold ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000 gui=bold
hi NonText        ctermfg=8 guifg=#555555
hi Comment        ctermfg=8 cterm=italic guifg=#555555 gui=italic
hi Normal         ctermfg=7 guifg=#eeeeec 
hi MsgArea        cterm=bold ctermfg=none gui=bold
hi VertSplit      ctermbg=0 ctermfg=8 guibg=NONE guifg=#555555

hi Redfg ctermfg=9 guifg=#cc6666
hi Grefg ctermfg=10 guifg=#b5bd68
hi Yelfg ctermfg=11 guifg=#f0c674
hi RedfgBlabg ctermbg=8 ctermfg=9 guibg=#555555 guifg=#cc6666

autocmd BufRead,BufNewFile * set laststatus=0

hi DiagnosticSignError ctermbg=9 ctermfg=9 cterm=bold guibg=#cc6666 guifg=#cc6666 gui=bold
hi DiagnosticSignWarn ctermbg=11 ctermfg=11 cterm=bold guibg=#f0c674 guifg=#f0c674 gui=bold
hi DiagnosticSignInfo ctermbg=10 ctermfg=10 cterm=bold guibg=#b5bd68 guifg=#b5bd68 gui=bold
hi DiagnosticSignHint ctermbg=13 ctermfg=13 cterm=bold guibg=#b294bb guifg=#b294bb gui=bold
hi SignColumn ctermbg=8 guibg=#555555
hi DiagnosticUnnecessary cterm=strikethrough gui=strikethrough

]], false)


