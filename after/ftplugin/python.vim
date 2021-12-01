" Assign makeprg
set makeprg=python3\ ./%:p

" Assign F8 to run the current Python file
nnoremap <F8> :update<CR>:silent make<CR>
inoremap <F8> <Esc>:update<CR>:silent make<CR><i>

if exists("g:lsp_loaded")
        call g:On_lsp_buffer_enabled()
endif
