" Simple, modern vim config - no plugins required
" Just drop this in ~/.vimrc

" ============================================
" VISUAL IMPROVEMENTS
" ============================================

" Enable syntax highlighting
syntax enable

" Show line numbers (relative + current line absolute)
set number

" Highlight current line subtly
set cursorline

" Use a nice colorscheme (built-in, no plugins needed)
set background=dark
colorscheme slate

" True color support (makes colors look better in modern terminals)
if has('termguicolors')
  set termguicolors
endif

" Always show the status bar
set laststatus=2

" Nicer status line (shows file, modified status, position)
set statusline=%f\ %m%r%h%w%=%l/%L\ col\ %c\ %p%%

" Show matching brackets when cursor is on them
set showmatch

" ============================================
" BEHAVIOR THAT JUST MAKES SENSE
" ============================================

" Mouse support (click to position cursor, scroll, select)
set mouse=a

" Use system clipboard (yank/paste works with Cmd+C/Cmd+V)
set clipboard=unnamedplus

" Backspace works like you'd expect
set backspace=indent,eol,start

" Searching
set ignorecase      " Case insensitive search...
set smartcase       " ...unless you use capitals
set incsearch       " Show matches as you type
set hlsearch        " Highlight all matches

" Press Escape to clear search highlighting
nnoremap <Esc> :nohlsearch<CR><Esc>

" ============================================
" INDENTATION (2-space, like most JS/TS/web)
" ============================================

set expandtab       " Use spaces, not tabs
set tabstop=2       " Tab = 2 spaces
set shiftwidth=2    " Indent = 2 spaces
set softtabstop=2   " Backspace removes 2 spaces
set autoindent      " Keep indent from previous line
set smartindent     " Auto-indent after {, etc.

" ============================================
" QUALITY OF LIFE
" ============================================

" Don't create backup/swap files everywhere
set nobackup
set nowritebackup
set noswapfile

" Undo persists after closing file
if has('persistent_undo')
  set undofile
  set undodir=~/.vim/undo
  silent !mkdir -p ~/.vim/undo
endif

" Remember cursor position when reopening files
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Faster escape from insert mode (no delay)
set ttimeoutlen=10

" Show incomplete commands in bottom right
set showcmd

" Tab completion in command mode (like bash)
set wildmenu
set wildmode=longest:full,full

" Scroll before hitting the edge
set scrolloff=8
set sidescrolloff=8

" Split windows open to right/below (more natural)
set splitright
set splitbelow

" Line wrapping that doesn't break words
set wrap
set linebreak

" Show invisible characters (optional - uncomment if you want)
" set list
" set listchars=tab:→\ ,trail:·,extends:›,precedes:‹

" ============================================
" FILE TYPE SPECIFIC (optional tweaks)
" ============================================

" 4-space indent for Python
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4

" 4-space indent for Go
autocmd FileType go setlocal tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab
