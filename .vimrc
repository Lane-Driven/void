"============================================================
"	Performance and core options
"============================================================
let mapleader = " "
let maplocalleader = " "

nnoremap <Space> <Nop>
vnoremap <Space> <Nop>
nnoremap J <Nop>
vnoremap J <Nop>
inoremap <C-e> <Esc>zti

set nocompatible
syntax on
filetype plugin indent on

set number
set relativenumber
set cursorline
set hidden

set wrap
set linebreak
set nolist
set scrolloff=10

set termguicolors
set updatetime=300
set signcolumn=yes
set noswapfile

set clipboard=unnamedplus
set mouse=a

set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent
set cindent

set ignorecase
set smartcase
set incsearch
set hlsearch

set splitbelow
set splitright

call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'tpope/vim-fugitive'

Plug 'tpope/vim-commentary'

Plug 'tpope/vim-surround'

Plug 'jiangmiao/auto-pairs'

Plug 'joshdick/onedark.vim'

call plug#end()

colorscheme onedark

let NERDTreeQuitOnOpen=1

nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>rg :Rg<CR>
nnoremap <leader>ff :Files<CR> 

nnoremap <leader>w :w<CR>
nmap <leader>q :q<CR>
nmap <leader>Q :qa!<CR>

nnoremap <leader>h :nohl<CR>

nnoremap <leader>n :NERDTreeToggle<CR>

nnoremap H 0
vnoremap H 0
nnoremap L $
vnoremap L $

nnoremap <C-u> <C-u>zz
nnoremap <C-d>
