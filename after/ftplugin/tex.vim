" Set make program to rubber or latexmk pdf output
if executable('rubber')
    set makeprg=rubber\ --inplace\ --ps\ --pdf\ %:p
elseif executable('latexmk')
    set makeprg=latexmk\ -ps\ -pdf\ -pdfps\ %
endif 

" https://github.com/lervag/vimtex/blob/98327bfe0e599bf580e61cfaa6216c8d4177b23d/compiler/latexmk.vim
setlocal errorformat=%-P**%f
setlocal errorformat+=%-P**\"%f\"
setlocal errorformat+=%E!\ LaTeX\ %trror:\ %m
setlocal errorformat+=%E%f:%l:\ %m
setlocal errorformat+=%E!\ %m
setlocal errorformat+=%Z<argument>\ %m
setlocal errorformat+=%Cl.%l\ %m
setlocal errorformat+=%+WLaTeX\ Font\ Warning:\ %.%#line\ %l%.%#
setlocal errorformat+=%-CLaTeX\ Font\ Warning:\ %m
setlocal errorformat+=%-C(Font)%m
"setlocal errorformat+=%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#
"setlocal errorformat+=%+WLaTeX\ %.%#Warning:\ %m
"setlocal errorformat+=%+WOverfull\ %\\%\\hbox%.%#\ at\ lines\ %l--%*\\d
"setlocal errorformat+=%+WUnderfull\ %\\%\\hbox%.%#\ at\ lines\ %l--%*\\d
setlocal errorformat+=%+WPackage\ natbib\ Warning:\ %m\ on\ input\ line\ %l%.
setlocal errorformat+=%+WPackage\ biblatex\ Warning:\ %m
setlocal errorformat+=%-C(biblatex)%.%#in\ t%.%#
setlocal errorformat+=%-C(biblatex)%.%#Please\ v%.%#
setlocal errorformat+=%-C(biblatex)%.%#LaTeX\ a%.%#
setlocal errorformat+=%-C(biblatex)%m
setlocal errorformat+=%-Z(babel)%.%#input\ line\ %l.
setlocal errorformat+=%-C(babel)%m
setlocal errorformat+=%+WPackage\ hyperref\ Warning:\ %m
setlocal errorformat+=%-C(hyperref)%.%#on\ input\ line\ %l.
setlocal errorformat+=%-C(hyperref)%m
setlocal errorformat+=%+WPackage\ scrreprt\ Warning:\ %m
setlocal errorformat+=%-C(scrreprt)%m
setlocal errorformat+=%+WPackage\ fixltx2e\ Warning:\ %m
setlocal errorformat+=%-C(fixltx2e)%m
setlocal errorformat+=%+WPackage\ titlesec\ Warning:\ %m
setlocal errorformat+=%-C(titlesec)%m
setlocal errorformat+=%-G%.%#

nnoremap <silent> <F8> :call TexCompile()<CR>
inoremap <silent> <F8> <Esc>:call TexCompile()<CR>a

" Assign F9 to view the current LaTeX file
nnoremap <silent> <F9> :update<CR>:call TexView()<CR>
inoremap <silent> <F9> <Esc>:update<CR>:call TexView()<CR>a

" Compile and clean tex files before exiting
autocmd VimLeave * call execute(TexCompile()) | call execute("TexClean")

" View the current .tex file's pdf file if there is one
function! TexView()
    let s:texCurrentPDFFile = expand('%:t:r') . ".pdf"
    if glob(s:texCurrentPDFFile) != ""
        if has('unix') && executable('zathura')
            let s:command = printf('zathura ' . s:texCurrentPDFFile)
            if !has('nvim')
                let s:zathuraOpen = job_start(s:command)
            else
                let s:zathuraOpen = jobstart(s:command)
            endif
        elseif has('win32') || has('win64') && executable('sumatrapdf')
            let s:command = printf('sumatrapdf ' . s:texCurrentPDFFile)
            if !has('nvim')
                let s:sumatraOpen = job_start(s:command)
            else
                let s:sumatraOpen = jobstart(s:command)
            endif
        else
            echo "Could not find program to open .pdf file."
        endif
    else 
        echo "Could not find PDF file to open"
    endif
endfunction
" Clean the tex directory
if executable('rubber')
    command! TexClean silent execute '!rubber --clean' expand("%:p") | silent execute 'redraw!' | echo "Cleaned the directory"
elseif executable('latexmk')
    command! TexClean silent execute '!latexmk -c' | silent execute 'redraw!' | echo "Cleaned the directory"
endif 
" Only compile if tex file is present
function! TexCompile()
    if glob('*.tex') != ""
        execute("update")
        silent execute("make")
    else
        echohl WarningMsg | "No Tex file present. Will not compile." | echohl None
    endif
    return
endfunction

" Abbreviations
" Article boilerplate
iabbrev <buffer> article \documentclass[letterpaper,12pt]{article}<CR><CR>\title{<++>}<CR>\author{<++>}<CR>\date{<++>}<CR><CR>\begin{document}<CR>\maketitle<CR><++><CR>\end{document}<Esc>/<++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Begin and end boilerplate
iabbrev <buffer> beg \begin{<beg++>}<CR><++><CR>\end{<++>}<ESC>/<beg++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Itemize begin boilerplate
iabbrev <buffer> begitem \begin{itemize}<CR><i++><CR><BS><BS>\end{itemize}<ESC>/<i++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" 2 column table boilerplate
iabbrev <buffer> 2ctable \begin{center}<CR>\begin{tabular}{\|c\|c\|}<CR><2c++><CR>\end{tabular}<CR>\end{center}<Esc>/<2c++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Table boilerplate
iabbrev <buffer> table \begin{center}<CR>\begin{tabular}{<ta++>}<CR><++><CR>\end{tabular}<CR>\end{center}<Esc>/<ta++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Italicize words
iabbrev <buffer> emph \emph{<e++>}<++><Esc>/<e++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Bold words
iabbrev <buffer> bold \textbf{<b++>}<++><Esc>/<b++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>

" Math Abbreviations
" Add text inside of math
iabbrev <buffer> textrm \textrm{<rm++>}<++><Esc>/<rm++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Inline math
iabbrev <buffer> mk $<m++>$<++><Esc>/<m++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Line math
iabbrev <buffer> dm \[\]<++><Esc>bf[a<CR><CR><Up><Tab><Tab><Tab><Tab><C-R>=Eatchar('\s')<CR>
" Vector
iabbrev <buffer> vec \vec{<v++>}<++><Esc>/<v++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Square
iabbrev <buffer> #r ^2<C-R>=Eatchar('\s')<CR>
" Cube
iabbrev <buffer> #c ^3<C-R>=Eatchar('\s')<CR>
" Superscript
iabbrev <buffer> #S ^{<S++>}<++><Esc>/<S++><CR><Esc>/<S++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>>
" Subscript
iabbrev <buffer> #s _{<s++>}<++><Esc>/<s++><CR><Esc>/<s++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Fraction
iabbrev <buffer> fr \frac{<f++>}{<++>}<++><Esc>/<f++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Hat
iabbrev <buffer> hat \hat{<h++>}<++><Esc>/<h++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Limit
iabbrev <buffer> lim \lim_{<l++>}<++><Esc>/<l++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Summation
iabbrev <buffer> summ \sum_{<u++>}^{<++>}<Esc>/<u++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Integral
iabbrev <buffer> inte \int_<in++>^<++><Esc>/<in++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>
" Square root
iabbrev <buffer> sqrt \sqrt{<sq++>}<++><Esc>/<sq++><CR><Esc>cf><C-R>=Eatchar('\s')<CR>

" Symbol Abbreviations
" Lower case theta
iabbrev <buffer> theta \theta<Left><Right><C-R>=Eatchar('\s')<CR>
" Lower case pi
iabbrev <buffer> pi \pi<Left><Right><C-R>=Eatchar('\s')<CR>
" Upper case delta
iabbrev <buffer> Delta \Delta<Left><Right><C-R>=Eatchar('\s')<CR>

