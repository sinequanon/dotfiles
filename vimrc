"{{{ Preamble
  set nocompatible                                  " Disable vi compatability. This must be first, because it changes other options as side effect.

  runtime bundle/vim-pathogen/autoload/pathogen.vim " Manually autoload pathogen from git submodule

  call pathogen#infect()                            " Execute pathogen to easily modify the runtime path to include all  plugins under the ~/.vim/bundle directory
  call pathogen#helptags()                          " Run :HelpTags from /doc in bundle directory

  syntax on
  filetype plugin indent on                         " Turn on plugin indent for each type
  if &diff                                          " I'm only interested in diff colours
      syntax on
  endif

  let mapleader=","                           " change the mapleader from \ to ,
"}}}

" {{{ Sets
  set hidden                           " Sets buffers to hidden when abandoned
  set modelines=1
  set nowrap                           " Don't wrap lines
  set textwidth=100                    " Allow any size of inserted text
  set wrapmargin=5                     " Number of characters from the right window border where wrapping starts.
  set linebreak                        " Wrap between word boundaries
  set tabstop=4                        " A tab is four spaces
  set backspace=indent,eol,start       " Allow backspacing over everything in insert mode
  set expandtab                        " use spaces instead of tabs. Remove this to revert to tabs
  set autoindent                       " Always set autoindenting on
  set copyindent                       " Copy the previous indentation on autoindenting
  set smartindent                      " Automatically inserts indentation
  set cindent                          " Like smart indent but stricter and more customizable
  set shiftwidth=2                     " Number of spaces to use for autoindenting
  set shiftround                       " Use multiple of shiftwidth when indenting with '<' and '>'
  set showmatch                        " Set show matching parenthesis
  set ignorecase                       " Ignore case when searching
  set smartcase                        " Ignore case if search pattern is all lowercase, case-sensitive otherwise
  set smarttab                         " Insert tabs on the start of a line according to shiftwidth, not tabstop
  set hlsearch                         " Highlight search terms
  set incsearch                        " Show search matches as you type
  set history=1000                     " Remember more commands and search history
  set undolevels=1000                  " Use many muchos levels of undo
  set undofile                         " Create an undo file
  set undodir=~/.vim/undo              " Store undo files here
  set title                            " Change the terminal's title
  set visualbell                       " Don't beep
  set noerrorbells                     " Don't beep
  set ruler                            " Turn on the ruler
  set nojoinspaces
  set colorcolumn=100                  " Turn on column line at 120 chars
  exec matchadd('ColorColumn','\%121v', 100)
  set showcmd                          " Show commands as you type
  set nobackup
  set noswapfile
  set directory=~/.vim/.tmp,~/tmp,/tmp " Store swap files in one of these directories (in case swapfile is ever turned on)
  set fileformats="unix,dos,mac"
  set cmdheight=1                      " Use a status bar that is 1 lines high
  set wildmenu                         " Make tab completion for files/buffers act like bash
  set wildmode=list:longest            " Show a list when pressing tab and complete first full match

  "Ignore these files when completing names
  set wildignore+=*/private/var/*,*/tmp/*,.svn,*.swp,CVS,.git,*.o,*.a,*.bak,*.class,*.mo,*.la,*.so,*.obj,*.pyc,*.swp,*.jpg,*.png,*.xpm,*.gif
  set mouse=a                          " Enable mouse support
  " set relativenumber                   " Show numbers relative from each other's distance
  set laststatus=2                     " Status line gnarliness
  set statusline=%F%m%r%h%w\(%{&ff}){%Y}\ [%l,%v][%p%%]
  set comments=sl:/*,mb:*,elx:*/       " Set comments
  set tags=./tags;./*.tags;/            " Look for ctags anywhere in the path up to the root
  set makeprg=ant                      " Use ant as the make executable
  set foldmethod=indent                " Sets folding method to indent for speed
  set foldlevelstart=10                " Sets some folds automatically closed
  set nofoldenable                     " Disable folding
  if has("gui_running")
    set noesckeys                      " Turn off escape keys
  endif
  set guifont=Operator\ Mono\ SSm\ Lig\ Medium\ Nerd\ Font\ Complete:h15 " Set font size
  set autochdir                        " Current directory is always matching the  content of the active window
  set viminfo='20,<50,s10,h,%          " Remember some stuff after quiting vim:  marks, registers, searches, buffer list
  set ofu=syntaxcomplete#Complete
  set clipboard=unnamed                " Now all operations work with the OS clipboard. No need for "+, "*
  "set switchbuf=usetab,newtab                 " Control buffer switching behavior. Switching to the existing tab if the buffer is open, or creating a new one if not.
  set sidescroll=5                     " Number of columns to scroll when margin is reached
  set encoding=UTF-8                   " UTF-8 encoding when displayed
  set fileencoding=UTF-8               " UTF-8 encoding when written to file
  " set diffopt=iwhite                          " Ignore whitespace during vimdiffs
  "set t_Co=256                                " Sets terminal colors to 256
  set diffopt+=iwhite                  " Tells vimdiff to ignore whitespace
  set diffexpr=""                      " Tells vimdiff to ignore ALL whitespace changes
  set nocursorline                       " Turn off cursor line highlighting. This speeds up rendering
  set autoread                         " Auto reads if file has been changed outside of vim. Use in conjunction with checktime
  set complete=.,b,u,]                 " Pull completion from keywords in the current file, other buffers (closed or still open), and from the current tags file.
  set timeoutlen=500                   " Sets timeout for mapping delays
  set ttimeoutlen=0                    " Sets timeout for keycode delays
  set updatetime=500                   " Change time in which swap file will be written to disk
  set lazyredraw                       " Screen is not redrawn while executing macros, registers, etc
  set bufhidden=unload                 " Unload buffer when hidden
  set ttyfast
  set path+=**                         " Set recursive file finding
" }}}

" {{{ Remappings
  " Maps semicolon to colon key for easier command typing
  nnoremap ; :

  " Always show multiple ctag definitions if it exists instead of jumping to the
  " first definition
  nnoremap <c-]> g<c-]>
  " inoremap <c-]> g<c-]>

  " Free search
  nnoremap <leader>/ :Ggr -i --untracked<space>
  " Search word under cursor
  nnoremap <leader>? :Ggr -i --untracked<space><cword><cr>

  "This will disable the arrow keys while you’re in normal mode to help you learn to use hjkl.
  "nnoremap <up> <nop>
  "nnoremap <down> <nop>
  "nnoremap <left> <nop>
  "nnoremap <right> <nop>
  "inoremap <up> <nop>
  "inoremap <down> <nop>
  "inoremap <left> <nop>
  "inoremap <right> <nop>

  " Remap j and k to act as expected when used on long, wrapped, lines
  nnoremap <buffer> <silent> j gj
  nnoremap <buffer> <silent> k gk
  " Heavy handedly fix ligature redraw issues
  "https://github.com/macvim-dev/macvim/issues/476
  " nnoremap <buffer> <silent> k gk:redraw!<CR>
  " nnoremap <buffer> <silent> j gj:redraw!<CR>
  " nnoremap <buffer> <silent> h h:redraw!<CR>
  " nnoremap <buffer> <silent> l l:redraw!<CR>

  " Use H and L to get to the beginning and end of the text on a line
  noremap H ^
  noremap L g_

  " Strip trailing whitespace
  " nnoremap <leader>W mz:%s/\s\+$//<cr>:let @/=''<cr>`z

  " Tell vim about ctrl + arrow keys and shift keys while in tmux
  if &term == "tmux-256color" || &term == "xterm-256color"
    map <esc>[1;5A <C-Up>
    map <esc>[1;5B <C-Down>
    map <esc>[1;5C <C-Right>
    map <esc>[1;5D <C-Left>
    map <esc>[1;2A <S-Up>
    map <esc>[1;2B <S-Down>
    map <esc>[1;2C <S-Right>
    map <esc>[1;2D <S-Left>
    map <esc>[1;2R <S-F3>
  endif

  " Left-Right text block movement in normal and visual mode
  vnoremap > >gv
  vnoremap < <gv
  nmap <C-right> >>
  nmap <C-left> <<
  vnoremap <C-right> >gv
  vnoremap <C-left> <gv
  vnoremap = =gv

  " Up-Down text block moving using unimpaired plugin
  nmap <C-up> [e
  nmap <C-down> ]e
  vmap <C-up> [egv
  vmap <C-down> ]egv
  "vmap <S-j> ]egv
  "vmap <S-k> [egv

  " Uppercase the last word from insert mode - useful for constants
  "inoremap <C-u> <esc>viwUea

  "don't move the cursor after pasting (by jumping to back start of previously changed text)
  "noremap p p`[
  "noremap P P`[
  "noremap p ]p
  "noremap P ]P

  " Go to end of pasted text
  "noremap p gp
  "noremap P gP

  " Enable magic mode when doing searches
  nnoremap / /\v
  vnoremap / /\v

  " Clear highlighted searches
  nnoremap <silent> <leader><space> :nohlsearch<CR>

  " Edit the vimrc file
  nnoremap <leader>v :e $MYVIMRC<CR>

  "Easy save files
  map <silent> <leader>s :update<CR>
  map <silent> <leader>S :wa<CR>
  " inoremap <silent> <leader><leader>s <esc>:update<CR>

  "Change inner word in insert mode
  " inoremap ciw <esc>ciw<esc>

  " Use Q for formatting the current paragraph (or selection)
  vmap Q gq
  nmap Q gqap

  " Quickly close the current window
  nnoremap <leader>w :q<CR>

  " Complete whole filenames/lines with a quicker shortcut key in insert mode
  " imap <C-f> <C-x><C-f>
  " imap <C-l> <C-x><C-l>

  " Use ,d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the yanked stack (also, in visual mode)
  nmap <silent> <leader>d "_d
  nmap <silent> <leader>dd "_dd
  xmap <silent> <leader>d "_d

  " Don't pollute the default register with simple cuts
  noremap x "_x
  noremap X "_X

  " Quick yanking to the end of the line
  nmap Y y$

  " Quickly get out of insert mode without your fingers having to leave the
  " home row (either use 'jj' or 'jk')
  inoremap jj <Esc>l
  "inoremap ii <Esc>l
  "inoremap kk <Esc>l
  "inoremap uu <Esc>l
  "inoremap hh  <Esc>l

  " Pull word under cursor into LHS of a substitute (for quick search and
  " replace)
  nmap <leader>z :%s#\<<c-r>=expand("<cword>")<CR>\>#

  " Folding
  " nnoremap <Space> za
  " vnoremap <Space> za

  " Visually select the text that was last edited/pasted
  nnoremap gV `[v`]
  " Paste contents of clipboard, select pasted and adjust indents
  nnoremap <leader>p p`[v`]=
  nnoremap <leader>P P`[v`]=

  " Easy map adding semicolon, dot, or comma to the ends of functions
  "inoremap ;<cr> <end>;
  "inoremap .<cr> <end>.
  "inoremap ,<cr> <end>,
  " inoremap ;<bs> <esc>maA;<esc>`ali
  " inoremap .<bs> <esc>maA.<esc>`ali
  " inoremap ,<bs> <esc>maA,<esc>`ali
  "inoremap ;;<cr> <down><end>;
  "inoremap ..<cr> <down><end>.
  "inoremap ,,<cr> <down><end>,
  " Add punctuation then go back to last position
  " inoremap ;;<bs> <space><esc>]}a;<esc>''i
  " inoremap ..<bs> <space><esc>]}a.<esc>''i
  " inoremap ,,<bs> <space><esc>]}a,<esc>''i
  " Add punctuation with carriage return below then go back to last position
  " inoremap ;;<bs><bs> <space><esc>]}a;<cr><esc>''i
  " inoremap ..<bs><bs> <space><esc>]}a.<cr><esc>''i
  " inoremap ,,<bs><bs> <space><esc>]}a,<cr><esc>''i
  " Add return to end of block
  " inoremap <cr><cr><bs> <space><esc>]}o<esc>''i

  " Open previously opened buffer using tab
  "nnoremap <tab> :b#<cr>

  " Duplicate visual selection
  vnoremap <leader>p y'>p
  vnoremap <leader>P y'>P

  " Local refactoring of function scope
  " nnoremap <leader>sr yiw[{V%::s/<c-r>0//gic<left><left><left><left>

  " Global refactoring of page scope
  " nnoremap <leader>sR yiw:%s/<c-r>0//gic<left><left><left><left>

  " Select function
  " nnoremap <leader>vf [{V]}

  " Select previously pasted text in visual mode
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

  " Insert newline without entering insert mode
  nmap <silent> <cr><cr> i<cr><Esc>

  " delete surrounding function
  " nmap <silent> dsf ds)db

  " close tags
  " Copied from ragtag
  " inoremap <silent> ,,/ <Esc>ciW<Lt><C-R>"></<C-R>"><Esc>F<i

  " Disable ex mode
  nnoremap gQ <nop>

  " Taken from last edit marker plugin
  " Automatically adds a global mark whenever you leave Insert mode, so you can
  " easily return to text you were last working on, even if you have moved to a
  " different buffer!  I tend to need this after I have been navigating around
  " files to do some research.  This saves us from hitting Ctrl-O repeatedly!
  nmap <leader><leader>y g'Z

  nnoremap <silent> <f7> :SortCssBraceContents<cr>

  " Neovim / OSX incorrectly maps backspace with ctrl-H. Instead of a custom
  " terminfo solution, just remap in vimrc
  " https://github.com/neovim/neovim/issues/2048#issuecomment-78534227
  " if has('nvim')
  "   nmap <BS> <C-W>h
  " endif

  " Insert comma at end of line
  " imap <leader>c <c-o>ma<c-o>A,<c-o>`a

  " Cycle through the line number mode
  nnoremap <leader>n :let [&nu, &rnu] = [!&rnu, &nu+&rnu==1]<cr>
" }}}

" {{{ Commands
  command! SortCssBraceContents :g#\({\n\)\@<=#.,/\.*[{}]\@=/-1 sort

  " Create a custom command for silently opening a quick fix window after
  " git grep
  command! -nargs=+ Ggr pclose | execute 'silent Ggrep!' <q-args> | cw | redraw!
" }}}

" {{{ Autogroups
  augroup configgroup
    autocmd!

    " Autocomplete most file types
    autocmd FileType javascript
      \ set omnifunc=javascriptcomplete#CompleteJS |
      " \ set formatprg=prettier-eslint\ --parser\ babylon\ --print-width\ 100\ --stdin
    autocmd FileType python
      \ set omnifunc=pythoncomplete#Complete |
      \ set expandtab
    autocmd FileType html
      \ set omnifunc=htmlcomplete#CompleteTags |
      \ set listchars-=tab:>.
    autocmd FileType xml
      \ set omnifunc=xmlcomplete#CompleteTags |
      \ set listchars-=tab:>.
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
    autocmd FileType php set omnifunc=phpcomplete#CompletePHP
    autocmd FileType c set omnifunc=ccomplete#Complete

    "scss and less support
    autocmd BufNewFile,BufRead *.scss set filetype=scss
    autocmd BufNewFile,BufRead *.less set filetype=less

    " reloads changed buffers outside of the editor
    autocmd BufNewFile,BufRead * :checktime
  augroup end

  augroup otherstuff
    autocmd!
    " Auto open quick fix window after any grep command. Mosty for GitGrep
    autocmd QuickFixCmdPost *grep* cwindow

    " Make the QuickFix window automatically appear if :make has any errors
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost    l* nested lwindow
    autocmd VimEnter            * nested cwindow

    " Make QuickFix window always on the bottom taking the whole horizontal space
    autocmd FileType qf wincmd J

    " Redraw screen whenever focus is set to buffer
    autocmd FocusGained * :redraw!

    " Move the preview window to the bottom regardless of splits
    autocmd WinEnter * if &previewwindow | wincmd J | endif

    " Autosave a file when you leave insert mode or when the user hasn't pressed a key for allotted updatetime
    " autocmd InsertLeave,CursorHold * nested if expand('%') != '' | update | endif

    " Automatically source vimrc on save.
    " use nested to allow other events to cascade
    " Better to use *vimrc instead of $MYVIMRC here since vimrc is usually a symlink to vimrc
    autocmd! BufWritePost *vimrc nested source %
    " Auto reload vimrc
    " au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif

    " autocmd BufWritePost *.js,*.jsx nested call prettier#run(1)
    " Running before saving, changing text or leaving insert mode
    " autocmd BufWritePre,TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue call prettier#run(1)

    "Maps 'K' to open vim help for the word under cursor when editing vim files. This already is the system default
    "on Windows, but it needs to be added explicitly on Linux / OS X.
    autocmd FileType vim setlocal keywordprg=:help

    " Commenting blocks of code instead of using NERDCommenter
    "autocmd FileType c,cpp,java,scala,javascript let b:comment_leader = '// '
    "autocmd FileType sh,ruby,python              let b:comment_leader = '# '
    "autocmd FileType conf,fstab                  let b:comment_leader = '# '
    "autocmd FileType tex                         let b:comment_leader = '% '
    "autocmd FileType mail                        let b:comment_leader = '> '
    "autocmd FileType vim                         let b:comment_leader = '" '
    "noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
    "noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
    "autocmd FileType javascript.jsx :call rainbow#toggle()
    "autocmd FileType javascript :call rainbow#toggle()
    "autocmd FileType javascript syntax clear jsFuncBlock
    " Trim whitespace on save
    autocmd BufWritePre * %s/\s\+$//e

    " Return cursor to previous location on load
    " autocmd BufReadPost * normal `"
  augroup end

  augroup LastEditMarker
    autocmd!
    autocmd InsertLeave * normal mZ
  augroup END
  " }}}

" {{{ Color schemes

  if (has("termguicolors"))
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
  endif
  set background=dark
  " colorscheme base16-railscasts
  " colorscheme jellybeans
  "let g:hybrid_custom_term_colors = 1
  " colorscheme hybrid_material
  " colorscheme base16-material
  " let g:palenight_terminal_italics=1
  " colorscheme palenight
  let g:gruvbox_italic=1
  let g:gruvbox_italicize_strings=1
  let g:gruvbox_improved_strings=0
  colorscheme gruvbox

  "highlight clear SignColumn
  "highlight VertSplit    ctermbg=236
  "highlight ColorColumn  ctermbg=237
  "highlight LineNr       ctermbg=236 ctermfg=240
  "highlight CursorLineNr ctermbg=236 ctermfg=240
  "highlight CursorLine   ctermbg=236
  "highlight StatusLineNC ctermbg=238 ctermfg=0
  "highlight StatusLine   ctermbg=240 ctermfg=12
  "highlight IncSearch    ctermbg=3   ctermfg=1
  "highlight Search       ctermbg=1   ctermfg=3
  "highlight Visual       ctermbg=3   ctermfg=0
  "highlight Pmenu        ctermbg=240 ctermfg=12
  "highlight PmenuSel     ctermbg=3   ctermfg=1
  "highlight SpellBad     ctermbg=0   ctermfg=1

  " See https://gist.github.com/hew/4356975264a2ac3334272e71c6938535
  " to get this working on new setups
  hi Comment gui=italic cterm=italic
  " hi Label gui=italic cterm=italic
  " hi Statement gui=italic cterm=italic
  " hi Type gui=italic cterm=italic
  " hi htmlArg gui=italic cterm=italic
  " hi javaScriptReserved gui=italic cterm=italic
  " hi javascriptImport guifg=NONE guibg=NONE ctermbg=NONE ctermfg=NONE gui=italic cterm=italic
  " hi jsClassKeyword gui=italic cterm=italic
  " hi jsConditional gui=italic cterm=italic
  " hi jsDocTags gui=italic cterm=italic
  " hi jsExport gui=italic cterm=italic
  " hi jsExportDefault gui=italic cterm=italic
  " hi jsExtendsKeyword gui=italic cterm=italic
  " hi jsFrom gui=italic cterm=italic
  " hi jsModuleAs gui=italic cterm=italic
  " hi jsStorageClass gui=italic cterm=italic
  " hi Keyword gui=italic cterm=italic

  " Setup from MacVim
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    if has("gui_running")
      set macligatures
      set guifont=Operator\ Mono\ SSm\ Lig\ Book\ Nerd\ Font\ Complete:h15 " Set font size
      set linespace=10
      " Remove all scrollbars
      set guioptions=
    endif
  elseif s:uname == "Linux\n"
    " Set IBeam shape in insert mode, underline shape in replace mode and block shape in normal mode.
    " For VTE terminals
    let &t_SI = "\<Esc>[6 q"
    let &t_SR = "\<Esc>[4 q"
    let &t_EI = "\<Esc>[2 q"
    set guicursor+=a:blinkon0
    if has("gui_running")
      set guifont=OperatorMonoSSmLig\ Nerd\ Font\ 16
      set linespace=10
      " Turn off cursor blinking
      " Remove right-hand scrollbar
      " set guioptions-=r
      " Remove left-hand scrollbar
      " set guioptions-=L
      " Remove menu bar
      " set guioptions-=m
      " Remove tool bar
      " set guioptions-=T
      " Do not source the menu options at all. This removes the weird gaps
      " in the chrome
      " set guioptions-=M
      " Remove all scrollbars
      set guioptions=
      set linespace=6
      " Support ligatures from a special build
      " See https://github.com/gasparch/vim8-ligatures-package
      let g:gtk_nocache=[0x00000000, 0xfc00ffff, 0xf8000001, 0x78000001]
    endif
  endif

  " Configure colorcolumn
  "highlight ColorColumn ctermbg=235 guibg=#2f1111
  " Highlight column 80 and everything past column 120
  let &colorcolumn="100,".join(range(120,999),",")
" }}}

" {{{ Windows
  "{{{ Splits
      set equalalways                 " Automatically size splits equally
      set splitbelow                  " Create vsplits below current split
      set splitright                  " Create splits right of current split

      " Resize splits when window is resized
      augroup resized
          autocmd!
          au VimResized * exe "normal! \<c-w>="
      augroup END
  " }}}

  " Easy window navigation
  nnoremap <silent> <leader><enter> :vsplit<cr>
  nnoremap <silent> <leader>- :split<cr>
  " nnoremap <C-l> <c-w>l
  " nnoremap <C-h> <c-w>h
  " nnoremap <C-j> <c-w>j
  " nnoremap <C-k> <c-w>k
  nnoremap <silent><space>l :wincmd l<cr>
  nnoremap <silent><space>h :wincmd h<cr>
  nnoremap <silent><space>j :wincmd j<cr>
  nnoremap <silent><space>k :wincmd k<cr>
  nnoremap <leader>wl <c-w>l
  nnoremap <leader>wh <c-w>h
  nnoremap <leader>wj <c-w>j
  nnoremap <leader>wk <c-w>k

  " Easy pane resizing
  nnoremap <silent> <S-Left> 5<C-w>>
  nnoremap <silent> <S-Right> 5<C-w><
  nnoremap <silent> <S-Down> 5<C-W>-
  nnoremap <silent> <S-Up> 3<C-W>+
" }}}

" {{{ Functions
  " Extract variable
  " function! ExtractVariable()
  "   try
  "     let save_a = @a
  "     let variable = input('Variable name: ')
  "     normal! gv"ay
  "     execute "normal! gvc" . variable
  "     execute "normal! O" . variable . " = " . @a
  "   finally
  "     let @a = save_a
  "   endtry
  " endfunction
  " xnoremap <Leader>e <ESC>:call ExtractVariable()<CR>
" }}}

" Plugins {{{
  " {{{ Silver Searcher
    " Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
    " if executable('ag')
    "     let g:ackprg = 'ag --nogroup --column'

    "     " Use Ag over Grep
    "     set grepprg=ag\ --nogroup\ --nocolor

    "     " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    "     let g:ctrlp_user_command = 'ag %s -l --hidden --nocolor -g ""'
    "     " let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
    "     let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
    "     let g:ctrlp_use_caching = 0
    "     " let g:ctrlp_match_window='bottom,order:btt,min:1,max:20,results:20'
    " endif
  " }}}

  " {{{ RipGrep
    if executable('rg')
      set grepprg=rg\ --vimgrep
      let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
      let g:ctrlp_use_caching = 0
      let g:ctrlp_working_path_mode = 'ra'
      let g:ctrlp_switch_buffer = 'et'
      let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
    endif
  " }}}

  " {{{ plugin : Fugitive.vim
    " git diff current file vs HEAD
    nnoremap <silent> <leader>gd :Gvdiffsplit!<cr>
    " turn off vim diff and delete diff buffer
    " nnoremap <silent> <leader>gD :diffoff!<cr><c-w>h:bd<cr>
    " nnoremap <silent> <leader>gD <c-w><c-o>":diffoff!<cr><c-w>h<c-w>c<cr>
    " Assuming focus was in the current non-git buffer, otherwise append a :Gedit before the <cr>
    nnoremap <silent> <leader>gD <c-W><c-O><cr>
    " git status
    nnoremap <silent> <leader>gs :Gstatus<cr>
    " git blame
    nnoremap <silent> <leader>gb :Git blame<cr>
    " git log
    nnoremap <silent> <leader>gl :0Glog<cr><cr>
    " git edit
    nnoremap <silent> <leader>ge :Gedit<cr>
    " function! XZY(...)
    "   let n = get(a:, 1, 0)
    "   echo "a:0". a:0
    "   echo "n: '".n."'"
    "   if 'n' == ""
    "     echo "nada"
    "   endif

    "   if exists('n')
    "     echo "you pressed " .n
    "   else
    "     echo "you pressed nothing"
    "   endif
    " endfunction
    " Git edit current file 3 previous versions ago
    " :Gedit! !~3:%
    nnoremap <silent> <leader>gx :exe join(["Gedit !~",nr2char(getchar()),":%"], "")<cr>
    " Git diff current file 5 versions ago
    " :Gdiff  !~5
    nnoremap <silent> <leader>gv :exe join(["Gvdiffsplit! !~",nr2char(getchar())], "")<cr>
  " }}}

  " {{{ plugin : ctrlp.vim
    let g:ctrlp_working_path_mode = 'ra'
    let g:ctrlp_root_markers = ['.git', '.vscode']
    let g:ctrlp_custom_ignore = '\v[\/](node_modules|bower_components|target|dist|jsdoc|generated)|(\.(swp|ico|git|svn))$'
    let g:ctrlp_show_hidden = 1
    nnoremap <leader>f :CtrlP<cr>
    nnoremap <leader>b :CtrlPBuffer<cr>
    nnoremap <leader>m :CtrlPMRUFiles<cr>
  " }}}

  " {{{ plugin : GitGutter
    au VimEnter * highlight clear SignColumn
    set signcolumn=yes
    " Ignore whitespace
    let g:gitgutter_diff_args= '-w'
  " }}}

  " {{{ plugin : Airline
    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    let g:airline_powerline_fonts = 1
    let g:airline#extensions#branch#enabled = 1
    let g:airline#extensions#hunks#enabled = 1
    let g:airline#extensions#hunks#hunk_symbols = ['+', '~', '-']
    let g:airline#extensions#whitespace#enabled = 0

    " powerline symbols
    " let g:airline_left_sep = ''
    " let g:airline_left_alt_sep = ''
    " let g:airline_right_sep = ''
    " let g:airline_right_alt_sep = ''
    " let g:airline_symbols.branch = ''
    " let g:airline_symbols.readonly = ''
    " let g:airline_symbols.linenr = ''
  " }}}

  " {{{ plugin : vim-indent-guides
    " Set guide size to be narrower than default shift width
    let g:indent_guides_guide_size = 1
    nnoremap <silent> <leader>ig :IndentGuidesToggle<cr>
  " }}}

  " {{{ plugin : ListToggle
    "let g:lt_height = 10
  " }}}

  " {{{ plugin: CoC

    " coc config
    let g:coc_global_extensions = [
      \ 'coc-snippets',
      \ 'coc-pairs',
      \ 'coc-tsserver',
      \ 'coc-eslint',
      \ 'coc-prettier',
      \ 'coc-json',
      \ ]

    " Use <C-l> for trigger snippet expand.
    imap <C-l> <Plug>(coc-snippets-expand)

    " Use <C-j> for select text for visual placeholder of snippet.
    vmap <C-j> <Plug>(coc-snippets-select)

    " Use <C-j> for jump to next placeholder, it's default of coc.nvim
    let g:coc_snippet_next = '<c-j>'

    " Use <C-k> for jump to previous placeholder, it's default of coc.nvim
    let g:coc_snippet_prev = '<c-k>'

    " Use <C-j> for both expand and jump (make expand higher priority.)
    imap <C-j> <Plug>(coc-snippets-expand-jump)

    " Use <leader>x for convert visual selected code to snippet
    xmap <leader>x  <Plug>(coc-convert-snippet)
    inoremap <silent><expr> <TAB>
          \ pumvisible() ? coc#_select_confirm() :
          \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()

    " Use <Tab> and <S-Tab> to navigate the completion list
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    let g:coc_snippet_next = '<tab>'
    " Use <c-space> to trigger completion.
    if has('nvim')
      inoremap <silent><expr> <c-space> coc#refresh()
    else
      inoremap <silent><expr> <c-@> coc#refresh()
    endif

    " Make <CR> auto-select the first completion item and notify coc.nvim to
    " format on enter, <cr> could be remapped by other vim plugin
    inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
      else
        execute '!' . &keywordprg . " " . expand('<cword>')
      endif
    endfunction

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)

    " Formatting selected code.
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>af  <Plug>(coc-format-selected)

    augroup mygroup
      autocmd!
      " Setup formatexpr specified filetype(s).
      autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
      " Update signature help on jump placeholder.
      autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " Applying codeAction to the selected region.
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " Remap keys for applying codeAction to the current buffer.
    nmap <leader>ac  <Plug>(coc-codeaction)
    " Apply AutoFix to problem on the current line.
    nmap <leader>qf  <Plug>(coc-fix-current)
    " Format file
    nmap <silent> <leader>pf :Prettier<cr>

    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

    " Use TAB for selections ranges.
    " Requires 'textDocument/selectionRange' support of language server.
    nmap <silent> <Tab> <Plug>(coc-range-select)
    xmap <silent> <Tab> <Plug>(coc-range-select)
    xmap <silent> <S-Tab> <Plug>(coc-range-select-backward)

    " Add `:Format` command to format current buffer.
    command! -nargs=0 Format :call CocAction('format')

    " Add `:Fold` command to fold current buffer.
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " Add `:Prettier` command to format using linter
    command! -nargs=0 Prettier :CocCommand prettier.formatFile

    " Add `:OR` command for organize imports of the current buffer.
    command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
    nnoremap <silent> <leader>oi :OR<cr>
    " Mappings for CoCList
    " Show all diagnostics.
    nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
    " Manage extensions.
    nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
    " Show commands.
    nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
    " Find symbol of current document.
    nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
    " Search workspace symbols.
    nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
    " Do default action for next item.
    nnoremap <silent><nowait> <space>n  :<C-u>CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent><nowait> <space>p  :<C-u>CocPrev<CR>
    " Resume latest coc list.
    nnoremap <silent><nowait> <space>r  :<C-u>CocListResume<CR>
  "}}}

  " {{{ plugin : javascript
    let javascript_enable_domhtmlcss  = 1
  " }}}

  " {{{ plugin : vim-hybrid
      let g:hybrid_custom_term_colors = 1
  " }}}

  " {{{ plugin : nerdcomment
    let g:NERDSpaceDelims = 1
  " }}}

  " {{{ plugin : airline-theme
    let g:airline_theme='solarized'
  " }}}

  " {{{ plugin : netrw
    " Allow netrw to remove non-empty local directories
    let g:netrw_localrmdir='trash'
    " let g:netrw_banner=1
  " }}}

  "{{{ Javascript libraries syntax
    let g:used_javascript_libs = 'lo-dash,react '
  " }}}

  "{{{ Javascript plugin
    let g:javascript_plugin_jsdoc = 1
    set conceallevel=1
  "}}}

  "{{{ Rainbow parens
    let g:rainbow_active = 1
  "}}}

  "{{{ Startify enable devicons
    function! StartifyEntryFormat()
      return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
    endfunction
  "}}}

  "{{{ devicons
    set ambiwidth=double
  "}}}

  "{{{ Easy Align
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)

    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
  "}}}

  "{{{ vim-sideways
    nnoremap <leader>( :SidewaysLeft<cr>
    nnoremap <leader>) :SidewaysRight<cr>
    " Create inner and outer function arguments you can perform things like cia daa et al.
    omap aa <Plug>SidewaysArgumentTextobjA
    xmap aa <Plug>SidewaysArgumentTextobjA
    omap ia <Plug>SidewaysArgumentTextobjI
    xmap ia <Plug>SidewaysArgumentTextobjI
  "}}}

  "{{{
    nnoremap <leader>u :MundoToggle<cr>
  "}}}

  "{{{ which-key
    let g:maplocalleader="\<space>"               " local leader
    call which_key#register('<Space>', "g:which_key_space_map")
    call which_key#register(',', "g:which_key_comma_map")
    nnoremap <silent> <leader> :<c-u>WhichKey ','<CR>
    xnoremap <silent> <leader> :<c-u>WhichKeyVisual ','<CR>
    nnoremap <silent> <localleader> :<c-u>WhichKey '<space>'<CR>
    xnoremap <silent> <localleader> :<c-u>WhichKeyVisual '<space>'<CR>
    let g:which_key_space_map = {
    \ 'h': [':wincmd h', 'Window left'],
    \ 'l': [':wincmd l', 'Window right'],
    \ 'j': [':wincmd j', 'Window below'],
    \ 'k': [':wincmd k', 'Window up']
    \ }

    let g:which_key_comma_map = {
    \ ',y': ["g'Z", 'Go to last edit marker'],
    \ '-': [':split', 'Horizontal split buffer'],
    \ '/': [':Ggr -i --untracked<space>', 'Git grep search'],
    \ '<CR>': [':vsplit', 'Vertical split buffer'],
    \ '?': [':Ggr -i --untracked<space><cword><cr>', 'Git grep search word under cursor'],
    \ 'P': ["y'>P", 'Duplicate visual selection'],
    \ 'S': [':wa', 'Save All Buffers'],
    \ 'd': ['"_d', 'Delete without adding to yanked stack'],
    \ 'dd': ['"_dd', 'Delete without adding to yanked stack'],
    \ 'gp': ["'`[' . strpart(getregtype(), 0, 1) . '`]'",'Select previously pasted text'],
    \ 'n': [':let [&nu, &rnu] = [!&rnu, &nu+&rnu==1]<cr>', 'Toggle line number modes'],
    \ 'p': ["y'>p", 'Duplicate visual selection'],
    \ 'qf': ['<Plug>(coc-fix-current)', 'CoC Quick Fix'],
    \ 's': [':update', 'Save Buffer'],
    \ 'w': [':q', 'Close buffer'],
    \ 'z': [':%s#\<<c-r>=expand("<cword>")<CR>\>#', 'Search and replace word under cursor'],
    \ }

    let g:which_key_comma_map.c = {
    \ 'name': 'NERDCommenter'
    \ }

    let g:which_key_comma_map.g = {
    \ 'name': 'Fugitive'
    \ }

    let g:which_key_comma_map.h = {
    \ 'name': 'GitGutter'
    \ }

    let g:which_key_comma_map.a = {
    \ 'name': 'CoC Codeaction'
    \ }
  "}}}

  "{{{ CtrlSF
    " Set working directory to project root where VCS (.git) file is located"
    let g:ctrlsf_default_root = 'project'
    " Auto focus to search results pane when complete
    let g:ctrlsf_auto_focus = {
    \ "at": "done",
    \ "duration_less_than": 1000
    \ }
    nnoremap <F3> :CtrlSF <space>
  "}}}"
" vim:foldmethod=marker:foldlevel=0
