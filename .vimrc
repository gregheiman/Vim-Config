"{{{ " Plugins
""""""""""""""""""""""""""""""""""""""""""
" START Vim Plug Configuration 
filetype off " REQUIRED Disable file type for vim plug.
" Check for OS system in order to start vim-plug in
if has('win32') || has('win64')
let g:plugDirectory = '~/vimfiles/plugged'
else
let g:plugDirectory = '~/.vim/plugged'     
endif
call plug#begin(plugDirectory) " REQUIRED
Plug 'tpope/vim-dispatch' " Asynchronous make
Plug 'tpope/vim-fugitive' " Git wrapper
Plug 'tpope/vim-surround' " Easy surrounding of current selection
Plug 'airblade/vim-rooter' " Find project root automatically
Plug 'tmsvg/pear-tree' " Add auto pair support for delimiters
Plug 'lifepillar/vim-mucomplete' " Stop the Ctrl-X dance
Plug 'ludovicchabant/vim-gutentags' " Make working with tags nice
Plug 'gruvbox-community/gruvbox' " Gruvbox theme
call plug#end() " REQUIRED
filetype plugin indent on " REQUIRED Re-enable all that filetype goodness
"""" END Vim Plug Configuration 
"}}}"

"{{{ " Vim Configuration Setting
"""""""""""""""""""""""""""""""""""""
set nocompatible " Required to not be forced into vi mode
syntax on " Enable syntax highlighting
set mouse=a " Enable the mouse
set nowrap " No line wrapping
set autowriteall " Auto save on big events
set encoding=utf-8 fileformat=unix fileformats=unix,dos " Set default encoding and line ending
set path-=/usr/include " Remove /usr/include form path. Included for C langs. in ftplugin
set noshowmode " Disable the mode display below statusline
set backspace=indent,eol,start " Better backspace
set tags=./tags,tags " Set default tags file location
set omnifunc=syntaxcomplete#Complete " Enable general omnicomplete
set shortmess+=c " Stop completion messages in the command line
set completeopt=menuone,noselect " Configure completion menu to work as expected
set pumheight=25 " Set maximum height for popup menu
set number relativenumber " Show line numbers
set tabstop=4 shiftwidth=4 smarttab expandtab " Set proper 4 space tabs
set incsearch nohlsearch ignorecase smartcase " Set searching to only be case sensitive when the first letter is capitalized
set splitright splitbelow " Change default vsp and sp directions
set laststatus=2 " Always display the status line
set cursorline " Enable highlighting of the current line
set spell spelllang=en_us " Enable Vim's built in spell check and set the proper spell check language
set noswapfile undofile backup " No swaps. Persistent undo, create backups
set undodir=~/.vim-undo// backupdir=~/.vim-backup// " Save backups and undo files to constant location
set sessionoptions=curdir,folds,globals,options,tabpages,unix,slash " Set what is saved in session files
set colorcolumn=80 " Create line at 80 character mark
set background=dark " Set the background to be dark. Enables dark mode on themes that support both dark and light

nnoremap <Nop> "\"
let mapleader = "\\"

let g:tex_flavor='latex' " Set the global tex flavor

if has('autocmd')
    augroup Highlight " Set custom highlights. Stops plugins from messing with colors
        autocmd!
        autocmd ColorScheme * highlight! link SignColumn LineNr
        autocmd ColorScheme * highlight! link StatusLine LineNr
        autocmd ColorScheme * highlight StatusLineNC cterm=reverse gui=reverse
        autocmd ColorScheme * highlight! link TabLine LineNr
    augroup END
endif
colorscheme gruvbox " Set color theme

set guifont=Iosevka:h12 " Set Font and size

if has('win32') || has('win64') " Start Vim fullscreen
    autocmd GUIEnter * simalt ~x 
endif 

" Set true colors if supported. If not default to 256 colors
if (has("termguicolors"))
    " Fix alacritty and Vim not showing colorschemes right (Prob. a Vim issue)
    if !has('nvim') && &term == "alacritty"
        let &term = "xterm-256color"
    else
        set t_Co=256
    endif
    set termguicolors
endif

if executable('rg') " Use ripgrep if available
    set grepprg=rg\ --vimgrep\ $*
    set grepformat^=%f:%l:%c:%m 
endif

set clipboard+=unnamedplus " Use system clipboard
"}}}

"{{{ " Auto Commands
if has("autocmd")
    augroup SaveSessionIfExistsUponExit
        autocmd!
        autocmd VimLeavePre * call functions#UpdateSessionOnExit() " Autosave Session.vim file if it exists
    augroup END
    augroup CheckVimrcOnEnter
        autocmd!
        if has("job") || has("nvim")
            autocmd VimEnter * call functions#GitFetchVimrc() " Check if .vimrc needs to be updated on enter
        endif 
    augroup END
endif
"}}}

"{{{ " Custom Keybindings and Commands
""""""""""""""""""""""""""""""""""""""""""
" Toggle Netrw
nnoremap <silent> <F1> :call functions#ToggleNetrw()<CR>
inoremap <silent> <F1> <Esc>:call functions#ToggleNetrw()<CR>

" Keybinding for tabbing visual mode selection to automatically re-select the visual selection 
vnoremap > >gv 
vnoremap < <gv

" Change split navigation keys
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k   
nnoremap <C-l> <C-w>l

" Change mappings of buffer commands.
nnoremap ]b :bn<CR>
nnoremap [b :bp<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <silent> <leader>bg :call functions#GoToSpecifiedBuffer()<CR>
nnoremap <leader>bl :buffers<CR>

" Project wide search
nnoremap <leader>f :call functions#DetermineGrep("<C-r><C-w>")<CR>
vnoremap <leader>f :<C-u>call functions#GrepOperator(visualmode())<CR>
" Local replace all instances of a variable using Vim
nnoremap <leader>r :%s/\<<C-r><C-w>\>//gc<Left><Left><Left>
" Project wide replace
nnoremap <leader>R :call functions#DetermineGrep("<C-r><C-w>", '1')<CR>
vnoremap <leader>R :<C-u>call functions#GrepOperator(visualmode(), '1')<CR>

" Search for visually selected text in current file
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Auto jump back to the last spelling mistake and fix it
inoremap <silent> <C-s> <c-g>u<Esc>mm[s1z=`m<Esc>:delm m<CR>a<c-g>u

" Jump forward and backward to placeholders in abbreviations
inoremap <C-j> <Esc>/<++><CR><Esc>cf>
inoremap <C-k> <Esc>?<++><CR><Esc>cf>

" Set bindings for jumping to errors in quickfix list
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprev<CR>
nnoremap <silent> [Q :cfirst<CR>
nnoremap <silent> ]Q :clast<CR>
nnoremap co<CR> :Copen<CR>

" Set Escape to leave terminal mode
tnoremap <ESC> <C-\><C-n>

" Auto split the terminal and open it in current directory
command! -nargs=0 -bar Term let $VIM_DIR=expand('%:p:h') | silent exe 'sp' | silent exe 'term' | silent exe 'cd $VIM_DIR'

" Eat spaces (or any other char) for abbreviations
function! Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunction
"}}}

"{{{ " Custom Plugin Configuration Options
""""""""""""""""""""""""""""""""""""""""""""""""""
let g:netrw_banner = 0 " Get rid of banner in netrw
let g:netrw_keepdir = 0 " Netrw will change working directory every new file

" Status line
let g:currentmode={'n'  : 'NORMAL', 'v'  : 'VISUAL', 'V'  : 'V·Line', 
                    \ "\<C-V>" : 'V·Block', 'i'  : 'INSERT', 'R'  : 'R', 
                    \ 'Rv' : 'V·Replace', 'c'  : 'Command', 'r' : 'Replace', 
                    \ 't': 'Terminal'}
set statusline= " Clear the status line
set statusline+=\ %{toupper(g:currentmode[mode()])}\ \\| " Mode
set statusline+=\ %{fugitive#head()}\ \\| " Git branch
set statusline+=\ %t\ \\| " File name
set statusline+=\ %(\%m%r%h%w%) " Modified, Read-only, help display
set statusline+=%= " Right align
set statusline+=%Y " File format
set statusline+=\ \\|\ %{&ff} " Line endings
set statusline+=\ \\|\ %{&enc} " Encoding
set statusline+=\ \\|\ %l/%L " Current line/Total lines
set statusline+=\  " Extra space at the end

" Mucomplete configuration
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains = {
        \ 'default' : ['path', 'omni', 'tags', 'incl'],
        \ 'java'    : ['path', 'incl', 'keyp', 'tags'],
        \ 'latex'   : ['path', 'tags', 'keyp', 'uspl'],
        \ 'vim'     : ['path', 'cmd', 'keyp'],
        \ }
inoremap <silent> <plug>(MUcompleteFwdKey) <right>
imap <right> <plug>(MUcompleteCycFwd)
inoremap <silent> <plug>(MUcompleteBwdKey) <left>
imap <left> <plug>(MUcompleteCycBwd)

" Stop pear tree from hiding closing bracket till after leaving insert mode (breaks . command)
let g:pear_tree_repeatable_expand = 0

" Gutentags configuration
if has('win64') || has('win32') 
	let g:gutentags_ctags_executable = "C:/Users/heimangreg/Universal-Ctags/ctags.exe" 
    let g:gutentags_ctags_extra_args = [
        \ '--tag-relative=yes',
        \ '--fields=+ailmnS',
        \ '--exclude=*.db',
        \]
endif
let g:gutentags_project_root = ['Makefile', 'CMakeLists.txt', 'pom.xml', 'build.gradle', 'node_modules', 'src']

" Rooter configuration
let g:rooter_silent_chdir = 1
let g:rooter_patterns = ['CMakeLists.txt', 'pom.xml', 'build.gradle', 'src', 'node_modules']
let g:rooter_change_directory_for_non_project_files = 'current'
"}}}
