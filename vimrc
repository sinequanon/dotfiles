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
  set textwidth=0                      " Allow any size of inserted text
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
  set tags=./tags;./.tags;/            " Look for ctags anywhere in the path up to the root
  set makeprg=ant                      " Use ant as the make executable
  set foldmethod=syntax                " Sets folding method to syntax based on filetype
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
  set cursorline                       " Turn on cursor line highlighting
  set autoread                         " Auto reads if file has been changed outside of vim. Use in conjunction with checktime
  set complete=.,b,u,]                 " Pull completion from keywords in the current file, other buffers (closed or still open), and from the current tags file.
  set timeoutlen=500                   " Sets timeout for mapping delays
  set ttimeoutlen=0                    " Sets timeout for keycode delays
  set updatetime=500                   " Change time in which swap file will be written to disk
  set lazyredraw                       " Screen is not redrawn while executing macros, registers, etc
  set bufhidden=unload                 " Unload buffer when hidden
" }}}

" {{{ Remappings
  " Maps semicolon to colon key for easier command typing
  nnoremap ; :

  " Always show multiple ctag definitions if it exists instead of jumping to the
  " first definition
  nnoremap <c-]> g<c-]>
  inoremap <c-]> g<c-]>

  " Free search
  nnoremap <f3> :Ggr -i --untracked<space>
  " Search word under cursor
  nnoremap <S-f3> :Ggr -i --untracked<space><cword><cr>

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

  " Use H and L to get to the beginning and end of the text on a line
  noremap H ^
  noremap L g_

  " Strip trailing whitespace
  nnoremap <leader>W mz:%s/\s\+$//<cr>:let @/=''<cr>`z

  " Tell vim about ctrl + arrow keys while in tmux
  if &term == "tmux-256color"
    map <esc>[1;5A <C-Up>
    map <esc>[1;5B <C-Down>
    map <esc>[1;5C <C-Right>
    map <esc>[1;5D <C-Left>
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
  nnoremap <leader><leader>q :q<CR>

  " Complete whole filenames/lines with a quicker shortcut key in insert mode
  " imap <C-f> <C-x><C-f>
  " imap <C-l> <C-x><C-l>

  " Use ,d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the yanked stack (also, in visual mode)
  nmap <silent> <leader>d "_d
  vmap <silent> <leader>d "_d

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
  nnoremap <Space> za
  vnoremap <Space> za

  " Visually select the text that was last edited/pasted
  nmap gV `[v`]

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
  nnoremap <leader>sr yiw[{V%::s/<c-r>0//gic<left><left><left><left>

  " Global refactoring of page scope
  nnoremap <leader>sR yiw:%s/<c-r>0//gic<left><left><left><left>

  " Select function
  nnoremap <leader>vf [{V]}

  " Select previously pasted text in visual mode
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

  " Insert newline without entering insert mode
  nmap <silent> <cr><cr> i<cr><Esc>

  " delete surrounding function
  nmap <silent> dsf ds)db

  " close tags
  " Copied from ragtag
  inoremap <silent> ,,/ <Esc>ciW<Lt><C-R>"></<C-R>"><Esc>F<i

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
  imap <leader>c <c-o>ma<c-o>A,<c-o>`a
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
      \ set formatprg=prettier-eslint\ --stdin
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

    " Make QuickFix window always on the bottom taking the whole horizontal space
    autocmd FileType qf wincmd J

    " Redraw screen whenever focus is set to buffer
    autocmd FocusGained * :redraw!

    " Move the preview window to the bottom regardless of splits
    autocmd WinEnter * if &previewwindow | wincmd J | endif

    " Autosave a file when you leave insert mode or when the user hasn't pressed a key for allotted updatetime
    " autocmd InsertLeave,CursorHold * nested if expand('%') != '' | update | endif

    " Automatically source vimrc on save.
    autocmd! BufWritePost $MYVIMRC source $MYVIMRC
    " Auto reload vimrc
    " au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif

    autocmd BufWritePost *.js,*.jsx call prettier#run(1)

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
    autocmd BufReadPost * normal `"
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
  colorscheme palenight
  let g:palenight_terminal_italics=1

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
  hi Label gui=italic cterm=italic
  hi Statement gui=italic cterm=italic
  hi Type gui=italic cterm=italic
  hi htmlArg gui=italic cterm=italic
  hi javaScriptReserved gui=italic cterm=italic
  hi javascriptImport gui=italic cterm=italic
  hi jsClassKeyword gui=italic cterm=italic
  hi jsConditional gui=italic cterm=italic
  hi jsDocTags gui=italic cterm=italic
  hi jsExport gui=italic cterm=italic
  hi jsExportDefault gui=italic cterm=italic
  hi jsExtendsKeyword gui=italic cterm=italic
  hi jsFrom gui=italic cterm=italic
  hi jsModuleAs gui=italic cterm=italic
  hi jsStorageClass gui=italic cterm=italic

  " Setup from MacVim
  if has("gui_running")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
      set macligatures
      " set guifont=OperatorMonoSSmLig\ Nerd\ Font:h15 " Set the font size
      set guifont=Operator\ Mono\ SSm\ Lig\ Medium\ Nerd\ Font\ Complete:h15 " Set font size
      " Turn off gui scrollbars
      set guioptions-=r
      set guioptions-=L
      set linespace=6
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
  nnoremap <leader>w :vsplit<cr>
  nnoremap <leader>- :split<cr>
  nnoremap <C-l> <c-w>l
  nnoremap <C-h> <c-w>h
  nnoremap <C-j> <c-w>j
  nnoremap <C-k> <c-w>k
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
  function! ExtractVariable()
    try
      let save_a = @a
      let variable = input('Variable name: ')
      normal! gv"ay
      execute "normal! gvc" . variable
      execute "normal! O" . variable . " = " . @a
    finally
      let @a = save_a
    endtry
  endfunction
  xnoremap <Leader>e <ESC>:call ExtractVariable()<CR>
" }}}

" Plugins {{{
  " {{{ Silver Searcher
    " Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
    if executable('ag')
        let g:ackprg = 'ag --nogroup --column'

        " Use Ag over Grep
        set grepprg=ag\ --nogroup\ --nocolor

        " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
        let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    endif
  " }}}

  " {{{ plugin : Fugitive.vim
    " git diff current file vs HEAD
    nnoremap <silent> <leader>gd :Gdiff<cr>
    " turn off vim diff and delete diff buffer
    " nnoremap <silent> <leader>gD :diffoff!<cr><c-w>h:bd<cr>
    " nnoremap <silent> <leader>gD <c-w><c-o>":diffoff!<cr><c-w>h<c-w>c<cr>
    nnoremap <silent> <leader>gD <c-w>h<c-w>c<cr>
    " git status
    nnoremap <silent> <leader>gs :Gstatus<cr>
    " git blame
    nnoremap <silent> <leader>gb :Gblame<cr>
    " git log
    nnoremap <silent> <leader>gl :Glog<cr><cr>
    " git edit
    nnoremap <silent> <leader>ge :Gedit<cr>
  " }}}

  " {{{ plugin : ctrlp.vim
    let g:ctrlp_working_path_mode = 'rw'
    let g:ctrlp_custom_ignore = '\v[\/](node_modules|bower_components|target|dist|jsdoc|generated)|(\.(swp|ico|git|svn))$'
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

  " {{{ plugin : UltiSnips
    let g:UltiSnipsJumpForwardTrigger='<tab>'
    let g:UltiSnipsJumpBackwardTrigger='<s-tab>'
  " }}}

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
    if has('gui_running')
      " let g:airline_theme='solarized'
      let g:airline_theme='hybrid'
    else
      " let g:airline_theme='molokai'
      let g:airline_theme='hybrid'
    endif
  " }}}

  " {{{ plugin : netrw
    " Allow netrw to remove non-empty local directories
    let g:netrw_localrmdir='trash'
  " }}}

  "{{{ plugin: ale
    let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
    let g:ale_fix_on_save = 1
    let g:ale_lint_delay = 10

    let g:ale_fixers = {
          \   'javascript': ['prettier-eslint'],
          \}
  "}}}

  "{{{ Oceanic Next
    let g:oceanic_next_terminal_bold = 1
    let g:oceanic_next_terminal_italic = 1
  "}}}
  "
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

  "{{{ Base 16 Material
    let g:enable_bold_font = 1
    let g:enable_italic_font = 1
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
" vim:foldmethod=marker:foldlevel=0
