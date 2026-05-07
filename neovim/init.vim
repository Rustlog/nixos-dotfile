" Enable syntax highlighting
syntax enable
" Set tab width to 4 spaces
set tabstop=4
" Set the shift width for indentation
set shiftwidth=4
" Use spaces instead of tabs
set expandtab
" Enable line numbering
set number
" Set relative line numbers
set relativenumber
" Set cursor style for different modes (Normal, Visual, etc.)
set guicursor=n-v-c-sm:block
" Disable sign column (useful for reducing screen clutter)
set signcolumn=no
" Enable 24-bit RGB color support for terminals
set termguicolors
" Set mouse to insert mode (enables copying)
set mouse=i
" Enable cursorline (optional)
set cursorline
" Enable filetype-specific plugins and indentation
filetype plugin indent on
" Set background dark
set background=dark
" prevent inode change
set backupcopy=yes
" enable folding
set foldmethod=indent
set foldlevel=40

" enable virtualedit
set virtualedit=block

" Enable swap files (saves the cursor position and other information)
set swapfile
" Enable shada (persistent history and cursor position saving)
set shada='1000,f0,h

" Set leader map
let mapleader = '\'

" Open new tab, switch to next tab, and close current tab
nnoremap <silent><leader>t :tabnew<CR>
nnoremap <silent><leader>n :tabnext<CR>
nnoremap <silent><leader>p :tabprevious<CR>
nnoremap <silent><leader>q :tabclose<CR>

" Move lines up/down in normal, visual, and insert modes
nnoremap <silent><A-j> :move .+1 <CR>==
vnoremap <silent><A-j> :move '>+1 <CR>gv=gv
inoremap <silent><A-j> <ESC>:move .+1 <CR>==gi

nnoremap <silent><A-k> :move .-2 <CR>==
vnoremap <silent><A-k> :move '<-2 <CR>gv=gv
inoremap <silent><A-k> <ESC>:move .-2 <CR>==gi

" Disable F1 key (bind to no operation)
nnoremap <silent> <F1> <Nop>
inoremap <silent> <F1> <Nop>
vnoremap <silent> <F1> <Nop>

" Create new line below (Shift + Enter)
nnoremap <silent><S-CR> :norm! o <CR>
" Create new line above (Ctrl + Shift + Enter)
nnoremap <silent><C-S-CR> :norm! O <CR>
" Toggle NerdTree with Ctrl + Space
nnoremap <silent><C-Space> :NERDTreeToggle<CR>

" Toggle wrap and nowrap with F2
nnoremap <silent><F2> :call ToggleWrap() <CR>

" Copy date & time into a register
function! CopyDateIntoRegister()
    let l:cmd_output = system('date +"%F %T"')
    let l:cmd_output = trim(l:cmd_output)
    call setreg('d', l:cmd_output)
endfunction

nnoremap <silent><leader>D :call CopyDateIntoRegister()<RETURN>
nnoremap <silent><leader>cr :for r in split('abcdefghijklmnopqrstuvwxyz1234567890/-', '\zs') <BAR> call setreg(r, '') <BAR> endfor <RETURN>

" Toggle wrap lines
function! ToggleWrap()
    if &wrap
        set nowrap
    else
        set wrap
    endif
endfunction
command! ToggleWrap :call ToggleWrap()

" Abort the commit message
command! GitAbort : !mv "%" "%.bak" | :q!

" Run C++ code
command! RunCpp w | execute
    \ '!clang -x c++ -pedantic -std=c++20 -lstdc++ -fno-elide-constructors -Wall -Wextra -O0 ' .
    \ shellescape(expand('%:p')) . ' -o ' . shellescape(expand('%:p:r')) . ' && ' .
    \ shellescape(expand('%:p:r')) . '; rm ' . shellescape(expand('%:p:r'))

" Run C code
command! RunC w | execute
    \ '!clang -x c -pedantic -Wall -Wextra -O0 ' . shellescape(expand('%:p')) . ' -o ' .
    \ shellescape(expand('%:p:r')) . ' && ' . shellescape(expand('%:p:r')) .
    \ ' ; rm ' . shellescape(expand('%:p:r'))

" Automatically jump to the last cursor position when reopening a file
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
    \ exe "norm! g`\" | zz" | endif
" autocmd BufRead,BufNewFile *.conf set filetype=dosini

" Plugin manager (lazy.vim)

lua <<EOF
local lazypath = "/usr/share/nvim/lazy_plugins/lazy.nvim"

-- Clone it as root
-- if vim.fn.getenv("UID") == 0 then
if (vim.uv or vim.loop).getuid() == 0 then
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        print("Cloning lazy.nvim system-wide into /usr/share/nvim/lazy_plugins ...")
        vim.fn.system({
            "git", "clone", "--depth=1", "--filter=blob:none", "--branch=stable",
            "https://github.com/folke/lazy.nvim.git", lazypath,
        })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_err_writeln("Failed to clone lazy.nvim system-wide")
            os.exit(1)
        end
    end
else
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        print("Run neovim as root once to install it systemd-wide")
        print("\nPress any to exit...")
        vim.fn.getchar()
        -- os.exit(1)
    end
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    root          = "/usr/share/nvim/lazy_plugins",
    defaults      = { lazy = true },
    install       = { colorscheme = { "habamax" } },
    checker       = { enabled = false, notify = false }, -- Do not check for updates
    concurrency   = 20,

    spec = {
        -- core
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" }, event = "VeryLazy",
            opts = { options = { theme = "papercolor_dark" } }
        },
        { "nvim-telescope/telescope.nvim", dependencies = "nvim-lua/plenary.nvim", cmd = "Telescope" },

        -- Colorscheme
        { "morhetz/gruvbox", lazy = false },
        { "folke/tokyonight.nvim", name = "tokyonight", lazy = false },
        { "tomasr/molokai", lazy = false },

        -- LSP
        { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },

        -- Completion + UI
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
            },
            event = { "InsertEnter", "CmdlineEnter" },
            config = function()
                local cmp = require("cmp")
                cmp.setup({
                    mapping = cmp.mapping.preset.insert({
                        ["<CR>"]    = cmp.mapping.confirm({ select = true }),
                        ["<Tab>"]   = cmp.mapping.select_next_item(),
                        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    }),
                    sources = {
                        { name = "nvim_lsp" },
                        { name = "buffer" },
                        { name = "path" },
                    },
                })
            end
        },
    },
})

local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

local lsp_servers = {
    bashls  = { },
    ts_ls   = { },
    lua_ls  = { },
    nil_ls  = { },
    clangd  = { },
    gopls   = { },
    yamlls  = { },
    html    = { },
    cssls   = { },
    jsonls  = { },
    pyright = { },
    rust_analyzer         = { },
    nginx_language_server = { },
}

for server,config in pairs(lsp_servers) do
    config.capabilities = cmp_capabilities
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gl", vim.diagnostic.open_float)
  end,
})

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
    },
    signs = true,
    underline = true,
    float = {
        border = "rounded",
        source = true,
    },
})


EOF

" :) Afer plugins load

" colorscheme gruvbox
" colorscheme molokai
colorscheme gruvbox

" auto chmod logic
autocmd BufWritePost *.sh,*.py if getline(1) =~ '^#!' | silent !chmod +x '%' | endif

" Set colorscheme based on filetype
augroup ColorSchemeSelector
    autocmd FileType     iss    colorscheme molokai |
        \ highlight! ExtraWhitespace guibg=red ctermbg=red
augroup END

" highlight trailing whitespace with red
highlight! ExtraWhitespace guibg=red ctermbg=red
augroup HighlightWhitespace
    autocmd!
    autocmd ColorScheme * highlight! ExtraWhitespace guibg=red ctermbg=red
    autocmd BufWinEnter,BufReadPost * call clearmatches() |
        \ call matchadd('ExtraWhitespace', '\s\+$')
augroup END

" C tmeplate
autocmd BufNewFile *.c call setline(1, [
    \ '//usr/bin/env gcc -Wall -Wextra -Werror -Wpedantic -pedantic -O0 -o "${0%.*}.bin" "${0}" && "${0%.*}.bin"; rm -f "${0%.*}.bin"; exit 0',
    \ '',
    \ '# include <stdio.h>',
    \ '# include <stdlib.h>',
    \ '# include <stdint.h>',
    \ '',
    \ 'int main(void) {',
    \ '    fprintf(stdout, "%s\n", "Hello World!");',
    \ '    return EXIT_SUCCESS;',
    \ '}',
    \ ''
\])

" C++ tmeplate
autocmd BufNewFile *.cpp,*.cxx,*.cc,*.c++ call setline(1, [
    \ '//usr/bin/env g++ -Wall -Wextra -Werror -Wpedantic -pedantic -O0 -o "${0%.*}.bin" "${0}" && "${0%.*}.bin"; rm -f "${0%.*}.bin"; exit 0',
    \ '',
    \ '# include <iostream>',
    \ '# include <cstdlib>',
    \ '',
    \ 'int main(void) {',
    \ "    std::cout << \"Hello World!\" << '\\n';",
    \ '    return EXIT_SUCCESS;',
    \ '}',
    \ ''
\])

" Python tmeplate
autocmd BufNewFile *.py call setline(1, [
    \ "#!/usr/bin/env python3",
    \ "",
    \ "def main():",
    \ "    print()",
    \ "",
    \ "if __name__ == '__main__':",
    \ "    main()",
    \ ""
\])

" Bash tmeplate
autocmd BufNewFile *.bash call setline(1, [
    \ '#!/usr/bin/env bash',
    \ '',
    \ 'set -euo pipefail',
    \ '',
    \ 'function main() {',
    \ '    echo "Hello World!"',
    \ '}',
    \ '',
    \ 'main "${@}"',
    \ ''
\])

