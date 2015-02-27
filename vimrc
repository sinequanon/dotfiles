"{{{ Preamble
    set nocompatible                                  "  Disable vi compatability. This must be first, because it changes other options as side effect.

    runtime bundle/vim-pathogen/autoload/pathogen.vim " Manually autoload pathogen from git submodule

    call pathogen#infect()                            " Execute pathogen to easily modify the runtime path to include all  plugins under the ~/.vim/bundle directory
    call pathogen#helptags()                          " Run :HelpTags from /doc in bundle directory

    syntax on
    filetype plugin indent on                   " Turn on plugin indent for each type
    if &diff                                    " I'm only interested in diff colours
        syntax on
    endif

    let mapleader=","                           " change the mapleader from \ to ,
"}}}

" {{{ Sets
    set hidden                                  " Sets buffers to hidden when abandoned
    set modelines=1
    set nowrap                                  " Don't wrap lines
    set textwidth=0                             " Allow any size of inserted text
    "set wrapmargin=5                            " Number of characters from the right window border where wrapping starts.
    set linebreak                               " Wrap between word boundaries
    set tabstop=4                               " A tab is four spaces
    set backspace=indent,eol,start              " Allow backspacing over everything in insert mode
    set expandtab                               " use spaces instead of tabs. Remove this to revert to tabs
    set autoindent                              " Always set autoindenting on
    set copyindent                              " Copy the previous indentation on autoindenting
    set smartindent                             " Automatically inserts indentation
    set cindent                                 " Like smart indent but stricter and more customizable
    set shiftwidth=4                            " Number of spaces to use for autoindenting
    set shiftround                              " Use multiple of shiftwidth when indenting with '<' and '>'
    set showmatch                               " Set show matching parenthesis
    set ignorecase                              " Ignore case when searching
    set smartcase                               " Ignore case if search pattern is all lowercase, case-sensitive otherwise
    set smarttab                                " Insert tabs on the start of a line according to shiftwidth, not tabstop
    set hlsearch                                " Highlight search terms
    set incsearch                               " Show search matches as you type
    set history=1000                            " Remember more commands and search history
    set undolevels=1000                         " Use many muchos levels of undo
    set undofile 			                    " Create an undo file
    set undodir=~/.vim/undo                     " Store undo files here
    set title                                   " Change the terminal's title
    set visualbell                              " Don't beep
    set noerrorbells                            " Don't beep
    set ruler				                    " Turn on the ruler
    set nojoinspaces
    set colorcolumn=120		                    " Turn on column line at 120 chars
    exec matchadd('ColorColumn' ,'\%121v', 100)
    set gdefault                                " Search/replace globally (on a line) by default
    set showcmd			                        " Show commands as you type
    set nobackup
    set noswapfile
    set directory=~/.vim/.tmp,~/tmp,/tmp        " Store swap files in one of these directories (in case swapfile is ever turned on)
    set fileformats="unix,dos,mac"
    set cmdheight=1                             " Use a status bar that is 1 lines high
    set wildmenu                                " Make tab completion for files/buffers act like bash
    set wildmode=list:longest                   " Show a list when pressing tab and complete first full match

    "Ignore these files when completing names
    set wildignore+=*/private/var/*,*/tmp/*,.svn,*.swp,CVS,.git,*.o,*.a,*.bak,*.class,*.mo,*.la,*.so,*.obj,*.pyc,*.swp,*.jpg,*.png,*.xpm,*.gif
    set mouse=a                                 " Enable mouse support
    set pastetoggle=<F2>
    "set relativenumber 		                    " Show numbers relative from each other's distance
    set laststatus=2                            " Status line gnarliness
    set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]
    set comments=sl:/*,mb:*,elx:*/              " Set comments
    set tags=./tags;./.tags;/                   " Look for ctags anywhere in the path up to the root
    set makeprg=ant                             " Use ant as the make executable
    set foldmethod=syntax                       " Sets folding method to syntax based on filetype
    set foldlevelstart=10                        " Sets some folds automatically closed
    set nofoldenable                            " Disable folding
    set noesckeys                               " Turn off escape keys
    set guifont=Menlo\ for\ Powerline:h13                       " Set the font size
    set autochdir                               " Current directory is always matching the  content of the active window
    set viminfo='20,<50,s10,h,%                 " Remember some stuff after quiting vim:  marks, registers, searches, buffer list
    set ofu=syntaxcomplete#Complete
    "set clipboard=unnamed                       " Now all operations work with the OS clipboard. No need for "+, "*
    "set switchbuf=usetab,newtab                 " Control buffer switching behavior. Switching to the existing tab if the buffer is open, or creating a new one if not.
    set sidescroll=5                            " Number of columns to scroll when margin is reached
    set encoding=utf-8                          " Default to UTF8
    set diffopt=iwhite                          " Ignore whitespace during vimdiffs
    set t_Co=256                                " Sets terminal colors to 256
    set diffopt+=iwhite                         " Tells vimdiff to ignore whitespace
    set diffexpr=""                             " Tells vimdiff to ignore ALL whitespace changes
    set cursorline                              " Turn on cursor line highlighting
    set autoread                                " Auto reads if file has been changed outside of vim
    set complete=.,b,u,]                        " Pull completion from keywords in the current file, other buffers (closed or still open), and from the current tags file.
    set timeoutlen=1000                         " Sets timeout for mapping delays
    set ttimeoutlen=0                           " Sets timeout for keycode delays
    set updatetime=1000                         " Change time in which swap file will be written to disk
" }}}

" {{{ Remappings
    " Maps semicolon to colon key for easier command typing
    nnoremap ; :

    " Always show multiple ctag definitions if it exists instead of jumping to the
    " first definition
    nnoremap <c-]> g<c-]>
    inoremap <c-]> g<c-]>

    " Use Ggrep for searching
    nnoremap <f3> :Ggrep -i 

    "This will disable the arrow keys while you’re in normal mode to help you learn to use hjkl.
    nnoremap <up> <nop>
    nnoremap <down> <nop>
    nnoremap <left> <nop>
    nnoremap <right> <nop>
    inoremap <up> <nop>
    inoremap <down> <nop>
    inoremap <left> <nop>
    inoremap <right> <nop>

    " Remap j and k to act as expected when used on long, wrapped, lines
    nnoremap j gj
    nnoremap k gk

    " Use H and L to get to the beginning and end of the text on a line
    noremap H ^
    noremap L g_

    " Strip trailing whitespace
    nnoremap <leader>W mz:%s/\s\+$//<cr>:let @/=''<cr>`z

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
    vmap <S-j> ]egv
    vmap <S-k> [egv

    " Uppercase the last word from insert mode - useful for constants
    "inoremap <C-u> <esc>viwUea

    "don't move the cursor after pasting (by jumping to back start of previously changed text)
    noremap p p`[
    noremap P P`[

    " Go to end of pasted text
    "noremap p gp
    "noremap P gP

    " Enable magic mode when doing searches
    "nnoremap / /\v
    "vnoremap / /\v

    " Clear highlighted searches
    nnoremap <silent> <leader><space> :nohlsearch<CR>

    " Edit the vimrc file
    nnoremap <leader>V :so ~/.vimrc<CR>
    nnoremap <leader>v :e ~/.vimrc<CR>

    "Easy save files
    map <silent> <leader><leader>s :update<CR>
    inoremap <silent> <leader><leader>s <esc>:update<CR>

    "Change inner word in insert mode
    inoremap ciw <esc>ciw<esc>

    " Use Q for formatting the current paragraph (or selection)
    vmap Q gq
    nmap Q gqap

    " Quickly close the current window
    nnoremap <leader><leader>q :q<CR>

    " Complete whole filenames/lines with a quicker shortcut key in insert mode
    imap <C-f> <C-x><C-f>
    imap <C-l> <C-x><C-l>

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
    inoremap ;<cr> <end>;
    inoremap .<cr> <end>.
    inoremap ,<cr> <end>,
    inoremap ;<bs> <esc>maA;<esc>`ali
    inoremap .<bs> <esc>maA.<esc>`ali
    inoremap ,<bs> <esc>maA,<esc>`ali
    inoremap ;;<cr> <down><end>;
    inoremap ..<cr> <down><end>.
    inoremap ,,<cr> <down><end>,
    inoremap ;;<bs> <down><end>;<up><end>
    inoremap ..<bs> <down><end>.<up><end>
    inoremap ,,<bs> <down><end>,<up><end>

    " Open previously opened buffer using tab
    "nnoremap <tab> :b#<cr>

    " Duplicate visual selection
    vnoremap <leader>p y'>p
    vnoremap <leader>P y'>P

    " Local refactoring of function scope
    nnoremap <leader>sr yiw[{V%::s/<c-r>0//gic<left><left><left><left>

    " Global refactoring of page scope
    nnoremap <leader>sR yiw:%s/<c-r>0//gic<left><left><left><left>
" }}}

" {{{ Autogroups
    augroup configgroup
        autocmd!
        autocmd filetype python set expandtab
        autocmd filetype html,xml set listchars-=tab:>.

        " Autocomplete most file types
        autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python set omnifunc=pythoncomplete#Complete
        autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
        autocmd FileType css set omnifunc=csscomplete#CompleteCSS
        autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
        autocmd FileType php set omnifunc=phpcomplete#CompletePHP
        autocmd FileType c set omnifunc=ccomplete#Complete

        "scss support
        autocmd BufNewFile,BufRead *.scss set filetype=scss
        autocmd BufNewFile,BufRead * :checktime

        " Auto open quick fix window after any grep command. Mosty for GitGrep
        autocmd QuickFixCmdPost *grep* cwindow

        " Redraw screen whenever focus is set to buffer
        autocmd FocusGained * :redraw!

        " Move the preview window to the bottom regardless of splits
        autocmd WinEnter * if &previewwindow | wincmd J | endif

        " Auto save a file when you leave insert mode or when the user hasn't pressed a key for allotted updatetime
        autocmd InsertLeave,CursorHold * if expand('%') != '' | update | endif

        " Automatically source vimrc on save.
        autocmd! BufWritePost $MYVIMRC source $MYVIMRC

        "Maps 'K' to open vim help for the word under cursor when editing vim files. This already is the system default
        "on Windows, but it needs to be added explicitly on Linux / OS X.
        autocmd FileType vim setlocal keywordprg=:help
    augroup end
" }}}


" {{{ Color schemes
    set background=dark
    colorscheme jellybeans "base16-railscasts

    highlight clear SignColumn
    highlight VertSplit    ctermbg=236
    highlight ColorColumn  ctermbg=237
    highlight LineNr       ctermbg=236 ctermfg=240
    highlight CursorLineNr ctermbg=236 ctermfg=240
    highlight CursorLine   ctermbg=236
    highlight StatusLineNC ctermbg=238 ctermfg=0
    highlight StatusLine   ctermbg=240 ctermfg=12
    highlight IncSearch    ctermbg=3   ctermfg=1
    highlight Search       ctermbg=1   ctermfg=3
    highlight Visual       ctermbg=3   ctermfg=0
    highlight Pmenu        ctermbg=240 ctermfg=12
    highlight PmenuSel     ctermbg=3   ctermfg=1
    highlight SpellBad     ctermbg=0   ctermfg=1

    " Setup from MacVim
    if has("gui_running")
        let s:uname = system("uname")
        if s:uname == "Darwin\n"

            set guifont=Droid\ Sans\ Mono\ for\ Powerline:h14

            " Turn off gui scrollbars
            set guioptions-=r
            set guioptions-=L

        endif
    endif
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
    nnoremap <leader>s :split<cr>
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
" }}}

" Plugins {{{
    " {{{ plugin : tagbar
        " Toggle tagbar
        nmap <silent> <F9> :TagbarToggle<CR>
        let g:tagbar_type_groovy = {
            \ 'ctagstype' : 'groovy',
            \ 'kinds'     : [
                \ 'p:package',
                \ 'c:class',
                \ 'i:interface',
                \ 'f:function',
                \ 'i:private variables',
                \ 'o:protected variables',
                \ 'u:public variables',
        \ ]
        \ }

        let g:tagbar_type_markdown = {
        \ 'ctagstype' : 'markdown',
        \ 'kinds' : [
            \ 'h:Heading_L1',
            \ 'i:Heading_L2',
            \ 'k:Heading_L3'
        \ ]
        \ }

    " }}}

    " {{{ plugin : NERDTree
        nnoremap <silent> <leader>n :NERDTreeToggle<cr>
        let NERDTreeMinimalUI=1
        let NERDTreeDirArrows=1
        nnoremap <leader>ns :NERDTreeFind<cr>
        augroup NerdTree
            autocmd!
            au FileType nerdtree setlocal nolist
        augroup END
    " }}}

    " {{{ plugin : Syntastic
        let g:syntastic_enable_signs=1
        let g:syntastic_auto_jump=0
        let g:syntastic_auto_loc_list=2
        "let g:syntastic_disabled_filetypes = ['scss', 'css']
        let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['javascript', 'java','groovy'], 'passive_filetypes': ['less', 'css', 'scss'] }
        "Make syntastic use jsxhint instead of the default jshint
        let g:syntastic_javascript_checkers = ['jsxhint']
        nnoremap <silent> <F4> :SyntasticCheck<cr>
    " }}}

    " {{{ plugin : Gundo
        nnoremap <Leader>u :GundoToggle<cr>
    " }}}

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

    " {{{ Tmux
        " Fix Cursor in TMUX
        if exists('$TMUX')
            let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
            let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
        else
            let &t_SI = "\<Esc>]50;CursorShape=1\x7"
            let &t_EI = "\<Esc>]50;CursorShape=0\x7"
        endif
        if &term =~ '^screen'
            " tmux will send xterm-style keys when its xterm-keys option is on
            execute "set <xUp>=\e[1;*A"
            execute "set <xDown>=\e[1;*B"
            execute "set <xRight>=\e[1;*C"
            execute "set <xLeft>=\e[1;*D"
        endif
    " }}}

    " {{{ plugin : javascript
        let javascript_enable_domhtmlcss = 1
        let g:javascript_conceal = 1
        let b:javascript_fold = 1
        " Allow plugin to conceal js keywords and phrases by turning on
        " conceallevel
        set conceallevel=1
    " }}}

    " {{{ plugin : Fugitive.vim
        " git diff current file vs HEAD
        nnoremap <silent> <leader>gd :Gdiff<cr>
        " turn off vim diff and delete diff buffer
        " nnoremap <silent> <leader>gD :diffoff!<cr><c-w>h:bd<cr>
        nnoremap <silent> <leader>gD :diffoff!<cr><c-w>h<c-w>c<cr>
        " git status
        nnoremap <silent> <leader>gs :Gstatus<cr>
    " }}}

    " {{{ plugin : ctrlp.vim
        let g:ctrlp_working_path_mode = 'rw'
        let g:ctrlp_custom_ignore = '\.(git|hg|svn)$\|web$'
        nnoremap <leader>f :CtrlP<cr>
        nnoremap <leader>b :CtrlPBuffer<cr>
        nnoremap <leader>m :CtrlPMRUFiles<cr>
    " }}}

    " {{{ plugin : GitGutter
        au VimEnter * highlight clear SignColumn
    " }}}

    " {{{ plugin : Sideways
        nnoremap <silent> <leader>( :SidewaysLeft<cr>
        nnoremap <silent> <leader>) :SidewaysRight<cr>
    " }}}

    " {{{ plugin : Airline
        if !exists('g:airline_symbols')
            let g:airline_symbols = {}
        endif

        let g:airline_powerline_fonts = 1
        let g:airline#extensions#branch#enabled = 1
        let g:airline#extensions#syntastic#enabled = 1
        let g:airline#extensions#hunks#enabled = 1
        let g:airline#extensions#hunks#hunk_symbols = ['+', '~', '-']
        let g:airline#extensions#whitespace#enabled = 0

        " powerline symbols
        let g:airline_left_sep = ''
        let g:airline_left_alt_sep = ''
        let g:airline_right_sep = ''
        let g:airline_right_alt_sep = ''
        let g:airline_symbols.branch = ''
        let g:airline_symbols.readonly = ''
        let g:airline_symbols.linenr = ''
    " }}}

    " {{{ plugin : Easy align
        " Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
        vmap <Enter> <Plug>(EasyAlign)

        " Start interactive EasyAlign for a motion/text object (e.g. <Leader>aip)
        nmap <Leader>a <Plug>(EasyAlign)
    " }}}

    " {{{ plugin : Tern JS
        nnoremap <Leader>tt :TernType<CR>
        nnoremap <Leader>tf :TernDef<CR>
        nnoremap <Leader>td :TernDoc<CR>
        nnoremap <Leader>tR :TernRename<CR>
        nnoremap <Leader>tr :TernRefs<CR>
        " Display argument type hints when cursore is left over a function
        let g:tern_show_argument_hints = 'on_hold'
    " }}}

    " {{{ plugin : vim-indent-guides
        " Set guide size to be narrower than default shift width
        let g:indent_guides_guide_size = 1
    " }}}

    " {{{ plugin : ListToggle
        "let g:lt_height = 10
    " }}}

    " {{{ plugin : BufSurf
        " Overriding unimpaired mapping of :bnext and :bprevious
        nnoremap ]b :BufSurfForward<cr>
        nnoremap [b :BufSurfBack<cr>
    " }}}

    " {{{ plugin : UltiSnips
        let g:UltiSnipsJumpForwardTrigger='<tab>'
        let g:UltiSnipsJumpBackwardTrigger='<s-tab>'
    " }}}

    " {{{ plugin : Incsearch
	    let g:incsearch#magic = '\v' " very magic
        map /  <Plug>(incsearch-forward)
        map ?  <Plug>(incsearch-backward)
        map g/ <Plug>(incsearch-stay)
    " }}}

    " {{{ plugin : auto-pairs
        let g:AutoPairsShortcutFastWrap = 'å'
        let g:AutoPairsShortcutBackInsert = 'â'
        let g:AutoPairsShortcutJump = 'î'
        let g:AutoPairsFlyMode = 1
    " }}}
" }}}
" vim:foldmethod=marker:foldlevel=0
