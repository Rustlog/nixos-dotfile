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

" Enable swap files (saves the cursor position and other information)
set swapfile
" Enable shada (persistent history and cursor position saving)
set shada='1000,f0,h

" Set leader map
let mapleader = '\'

" Open new tab, switch to next tab, and close current tab
nnoremap <silent><leader>t :tabnew<CR>
nnoremap <silent><leader>n :tabmove<CR>
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

" Toggle wrap and nowrap with F2
nnoremap <silent><F2> :call ToggleWrap() <CR>

" Toggle wrap lines
function! ToggleWrap()
    if &wrap
        set nowrap
    else
        set wrap
    endif
endfunction
command! ToggleWrap :call ToggleWrap()

" Run C++ code
command! RunCpp w | execute '!gcc -x c++ -pedantic -std=c++20 -lstdc++ -fno-elide-constructors -Wall -Wextra -O0 ' . shellescape(expand('%:p')) . ' -o ' . shellescape(expand('%:p:r')) . ' && ' . shellescape(expand('%:p:r')) . ' ; rm ' . shellescape(expand('%:p:r'))

" Run C code
command! RunC w | execute '!gcc -pedantic -Wall -Wextra -O0 ' . shellescape(expand('%:p')) . ' -o ' . shellescape(expand('%:p:r')) . ' && ' . shellescape(expand('%:p:r')) . ' ; rm ' . shellescape(expand('%:p:r'))

" Abort the commit message
command! GitAbort : !mv "%" "%.bak" | :q!

" Automatically jump to the last cursor position when reopening a file
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "norm! g`\" | zz" | endif
" autocmd BufRead,BufNewFile *.conf set filetype=dosini

" C tmeplate
autocmd BufNewFile *.c call setline(1, [
    \ '//usr/bin/env gcc -Wall -pedantic -O0 -o "${0%.*}_bin" "${0}" && "${0%.*}_bin"; rm "${0%.*}_bin" 2> /dev/null; exit 0',
    \ '',
    \ '# include <stdio.h>',
    \ '',
    \ '# define EXIT_SUCCESS 0',
    \ '# define EXIT_FAILURE 1',
    \ '',
    \ 'int main(void) {',
    \ '    printf("Hello World!\n");',
    \ '    return EXIT_SUCCESS;',
    \ '}',
    \ ''
\])

" C++ tmeplate
autocmd BufNewFile *.cpp,*.cxx,*.cc,*.c++ call setline(1, [
    \ '//usr/bin/env gcc -lstdc++ -Wall -pedantic -O0 -o "${0%.*}_bin" "${0}" && "${0%.*}_bin"; rm "${0%.*}_bin" 2> /dev/null; exit 0',
    \ '',
    \ '# include <iostream>',
    \ '',
    \ '# define EXIT_SUCCESS 0',
    \ '# define EXIT_FAILURE 1',
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
autocmd BufNewFile *.sh call setline(1, [
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

" Plugin manager (lazy.vim)

lua <<EOF

local lazypath = "/usr/share/nvim/lazy_plugins/lazy.nvim"

-- Clone it as root
if vim.fn.getenv('UID') == 0 then
    if vim.loop.fs_stat(lazypath) then
        print("Cloning lazy.nvim system-wide into /usr/share/nvim/lazy_plugins ...")
      vim.fn.system({
          "git", "clone", "--filter=blob:none", "--branch=stable",
          "https://github.com/folke/lazy.nvim.git", lazypath,
      })
      if vim.v.shell_error ~= 0 then
          vim.api.nvim_err_writeln("Failed to clone lazy.nvim system-wide")
          os.exit(1)
      end
    end
else
    if not vim.loop.fs_stat(lazypath) then
        print("Run neovim as root once to install it systemd-wide")
        print("\nPress any to exit...")
        vim.fn.getchar()
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
      -- Core plugins
        { "octol/vim-cpp-enhanced-highlight",                                                               },
        { "nvim-lua/plenary.nvim",                                                                          },
        { "tpope/vim-commentary",             event = "VeryLazy"                                            },
        { "nvim-telescope/telescope.nvim",    dependencies = { "nvim-lua/plenary.nvim" },
        cmd =  "Telescope", keys = { { "<C-n>", "<cmd>Telescope find_files<CR>" , desc = "Find files"}}     },
        { "nvim-lualine/lualine.nvim",        dependencies = { "nvim-tree/nvim-web-devicons" },
                                              event = "VeryLazy",
                                              opts = {
                                                  options = { theme = "papercolor_dark" }
                                              }                                                             },
        { "nvim-telescope/telescope.nvim",    dependencies = "nvim-lua/plenary.nvim"                        },
        { "echasnovski/mini.align",           branch = "stable", config = true                              },
        { "puremourning/vimspector"                                                                         },
        { "MeanderingProgrammer/render-markdown.nvim",
                                              ft = {"markdown","quarto"}, config = true                     },
        -- COLORSCHEMES
        { "folke/tokyonight.nvim", lazy = false, priority = 1000, name = "tokyonight"                       },
        { "morhetz/gruvbox", lazy = false, priority = 1000                                                  },
        { "tomasr/molokai", lazy = false, priority = 1000                                                   },
        { "ricardoraposo/nightwolf.nvim", lazy = false, priority = 1000                                     },
        { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000                             },

        -- Native lsp stack
        { "williamboman/mason.nvim", config = true                                                          },
        { "williamboman/mason-lspconfig.nvim"                                                               },
        { "neovim/nvim-lspconfig"                                                                           },

        -- COMPLETION (Enter confirms)
        { "hrsh7th/nvim-cmp", event = "InsertEnter", dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
          }, config = function()
            local cmp = require("cmp")
            cmp.setup{
              snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
              mapping = cmp.mapping.preset.insert({
                ["<CR>"]  = cmp.mapping.confirm({ select = true }),  -- Enter = confirm
                ["<Tab>"] = cmp.mapping.select_next_item(),
                ["<S-Tab>"] = cmp.mapping.select_prev_item(),
              }),
              sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
              },
            }
          end,
        },

        -- Auto-install servers + keymaps
        { "williamboman/mason-lspconfig.nvim", config = function()
            require("mason-lspconfig").setup{
              ensure_installed = {
                "lua_ls", "ts_ls", "pyright", "rust_analyzer",
                "gopls", "bashls", "html", "cssls", "jsonls",
                "clangd", "volar", "sqlls", "cmake",
              },
              automatic_installation = true,
            }

            local lspconfig = require("lspconfig")
            local servers = {
                "lua_ls", "ts_ls", "pyright", "rust_analyzer",
                "gopls", "bashls", "html", "cssls", "jsonls",
                "clangd", "volar", "sqlls", "cmake",
                }
            for _, server in ipairs(servers) do
              lspconfig[server].setup{}
            end

            lsp.config.clangd.setup {
                "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu"
            }

            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(ev)
                local map = function(k, cmd, desc)
                  vim.keymap.set("n", k, cmd, { buffer = ev.buf, desc = "LSP: " .. desc })
                end
                map("gd", vim.lsp.buf.definition, "Goto definition")
                map("gr", vim.lsp.buf.references, "References")
                map("K",  vim.lsp.buf.hover, "Hover")
                map("<leader>rn", vim.lsp.buf.rename, "Rename")
                map("<leader>ca", vim.lsp.buf.code_action, "Code action")
              end,
            })
          end,
        },
    }

})
EOF

" :) Afer plugins load

" colorscheme gruvbox
" colorscheme molokai
colorscheme tokyonight-night

" auto chmod logic
autocmd BufWritePost *.sh,*.py if getline(1) =~ '^#!' | silent !chmod +x '%' | endif

" Set colorscheme based on filetype
augroup ColorSchemeSelector
    autocmd FileType     sh,zsh,bash                colorscheme nightwolf-dark-gray
    autocmd FileType     c,cpp                      colorscheme tokyonight-moon
    autocmd FileType     iss                        colorscheme molokai
augroup END

