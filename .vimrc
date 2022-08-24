set tabstop=2
set shiftwidth=2
set expandtab

set mouse=a
set number
autocmd VimEnter * NERDTree

if (empty($TMUX))
  if (has("termguicolors"))
    set termguicolors
  endif
endif

call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'vimsence/vimsence'
Plug 'jiangmiao/auto-pairs'
Plug 'frazrepo/vim-rainbow'
Plug 'joshdick/onedark.vim'
call plug#end()

let g:airline_theme='onedark'
let g:onedark_termcolors=256
let g:onedark_hide_endofbuffer = 1

syntax on
colorscheme onedark

