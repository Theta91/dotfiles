" .vimrc
" Cody Voight
"vim:ft=vimrc:

" -- Basics
  filetype plugin indent on
  call pathogen#infect()

  if has('gui_running')
    set guicursor=a:blinkon0-hor5-Cursor
    set guifont=Monaco\ 8.5
  endif
  set nocompatible
  set modelines=0

  syntax on              " syntax highlighting on
  colorscheme wombat256mod
  set background=dark
  let mapleader=","
  let maplocalleader=","
  let g:LustyJugglerSuppressRubyWarning = 1

  let g:tex_flavor              = 'latex'
" -- LaTeX Suite
"  set grepprg=grep\ -nH\ $*
"  let g:Tex_DefaultTargetFormat = 'pdf'
"  let g:Tex_CompileRule_pdf     = 'latexmk $*'
"  set iskeyword+=:
" -- LaTeX-Box
  set grepprg=grep\ -nH\ $*
  let g:LatexBox_completion_close_braces = 1
  let g:LatexBox_output_type             = "pdf"
  let g:LatexBox_viewer                  = "llpp"
  let g:LatexBox_autojump                = 1

" -- General
  set noerrorbells       " don't make noise
  set title              " 
  set pastetoggle=<F2>   " 

  set encoding=utf-8
  set hidden
  set wildmenu
  set wildmode=list:longest
  set ttyfast
  set backspace=indent,eol,start
  set laststatus=2
  set relativenumber

  nnoremap <up> <nop>
  nnoremap <down> <nop>
  nnoremap <left> <nop>
  nnoremap <right> <nop>
  inoremap <up> <nop>
  inoremap <down> <nop>
  inoremap <left> <nop>
  inoremap <right> <nop>
  nnoremap j gj
  nnoremap k gk

" -- Vim UI
  set cursorline         " highlight current line
  set list               "
  set listchars=trail:-  " show trailing spaces
  set matchtime=5        " how many tenths of a second to blink
                         " matching brackets
  set nostartofline      " leave cursor where it was
  set novisualbell       " don't blink
  set number             " turn on line numbers
  set numberwidth=3      " up to 9999 lines
  set ruler              " always show current positions along the
                         " bottom
  set scrolloff=10        " keep 5 lines (top/bottom) for scope
  set showcmd            " show the command being typed
  set showmatch          " show matching brackets
  set showmode           " show which mode we're in
  " set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
  "              | | | | |  |   |      |  |     |    |
  "              | | | | |  |   |      |  |     |    + current 
  "              | | | | |  |   |      |  |     |       column
  "              | | | | |  |   |      |  |     +-- current line
  "              | | | | |  |   |      |  +-- current % into file
  "              | | | | |  |   |      +-- current syntax in 
  "              | | | | |  |   |          square brackets
  "              | | | | |  |   +-- current fileformat
  "              | | | | |  +-- number of lines
  "              | | | | +-- preview flag in square brackets
  "              | | | +-- help flag in square brackets
  "              | | +-- readonly flag in square brackets
  "              | +-- rodified flag in square brackets
  "              +-- full path to file in the buffer

" -- Text Formatting/Layout
  set formatoptions=rq  " automatically insert comment leader on return, and
                        " let gq format comments
  set ignorecase        " case insensitive by default
  set infercase         " case inferred by default
  set smartcase         " if there are caps, go case-sensitive
  set gdefault
  set incsearch
  set showmatch
  set hlsearch
  nnoremap <leader><space> :noh<cr>
  nnoremap <tab> %
  vnoremap <tab> %
  nnoremap ; :
  inoremap jj <ESC>
  nnoremap <leader>w <C-w>v<C-w>l
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
  set hlsearch          " highlight search terms
  set tabstop=2         " how many spaces to insert for a tab
  set shiftwidth=2      " auto-indent amount when using cindent, >>, <<, etc.
  set softtabstop=2     " how many spaces to insert for a tab
  set expandtab         " automatically expands tabs to space
  set autoindent
