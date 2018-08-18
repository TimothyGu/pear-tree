if exists('g:loaded_pear_tree') || v:version < 704 || &compatible
    finish
endif
let g:loaded_pear_tree = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

if !exists('g:pear_tree_pairs')
    let g:pear_tree_pairs = {
                \ '(': {'closer': ')'},
                \ '[': {'closer': ']'},
                \ '{': {'closer': '}'},
                \ "'": {'closer': "'", 'not_in': ['String']},
                \ '"': {'closer': '"', 'not_in': ['String']}
                \ }
endif

if !exists('g:pear_tree_ft_disabled')
    let g:pear_tree_ft_disabled = []
endif

if !exists('g:pear_tree_smart_backspace')
    let g:pear_tree_smart_backspace = 0
endif

if !exists('g:pear_tree_smart_openers')
    let g:pear_tree_smart_openers = 0
endif

if !exists('g:pear_tree_smart_closers')
    let g:pear_tree_smart_closers = 0
endif


function! s:BufferEnable()
    if exists('b:pear_tree_enabled') && b:pear_tree_enabled
        return
    elseif exists('s:saved_mappings')
        for [l:map, l:map_arg] in items(s:saved_mappings)
            execute 'imap <buffer> ' . l:map . ' ' . l:map_arg
        endfor
    else
        call s:CreatePlugMappings()
        call s:MapDefaults()
    endif
    let b:pear_tree_enabled = 1
endfunction


function! s:BufferDisable()
    if !(exists('b:pear_tree_enabled') && b:pear_tree_enabled)
        return
    endif
    let s:saved_mappings = {}
    for l:map in map(split(execute('imap'), '\n'), 'split(v:val, ''\s\+'')[1]')
        let l:map_arg = maparg(l:map, 'i')
        if l:map_arg =~# '^<Plug>(PearTree\w\+\S*)'
            let s:saved_mappings[l:map] = l:map_arg
            execute 'silent! iunmap <buffer> ' . l:map
        endif
    endfor
    let b:pear_tree_enabled = 0
endfunction


function! s:CreatePlugMappings()
    let l:pairs = get(b:, 'pear_tree_pairs', get(g:, 'pear_tree_pairs'))
    for [l:opener, l:closer] in map(items(l:pairs), '[v:val[0][-1:], v:val[1].closer]')
        let l:escaped_opener = substitute(l:opener, "'", "''", 'g')
        execute 'inoremap <silent> <expr> <buffer> '
                    \ . '<Plug>(PearTreeOpener_' . l:opener . ') '
                    \ . 'pear_tree#insert_mode#TerminateOpener('''
                    \ . l:escaped_opener . ''')'

        if strlen(l:closer) == 1 && !has_key(l:pairs, l:closer)
            let l:escaped_closer = substitute(l:closer, "'", "''", 'g')
            execute 'inoremap <silent> <expr> <buffer> '
                        \ . '<Plug>(PearTreeCloser_' . l:closer . ') '
                        \ . 'pear_tree#insert_mode#HandleCloser('''
                        \ . l:escaped_closer . ''')'
        endif
    endfor
    inoremap <silent> <expr> <Plug>(PearTreeBackspace) pear_tree#Backspace()
    inoremap <silent> <expr> <Plug>(PearTreeJump) pear_tree#JumpOut()
    inoremap <silent> <expr> <Plug>(PearTreeJNR) pear_tree#JumpNReturn()
    inoremap <silent> <expr> <Plug>(PearTreeExpand) pear_tree#PrepareExpansion()
    inoremap <silent> <expr> <Plug>(PearTreeExpandOne) pear_tree#ExpandOne()
    inoremap <silent> <expr> <Plug>(PearTreeFinishExpansion) pear_tree#Expand()
endfunction


function! s:MapDefaults()
    let l:pairs = get(b:, 'pear_tree_pairs', get(g:, 'pear_tree_pairs'))
    for l:closer in map(values(l:pairs), 'v:val.closer')
        let l:closer_plug = '<Plug>(PearTreeCloser_' . l:closer . ')'
        if mapcheck(l:closer_plug, 'i') !=# '' && !hasmapto(l:closer_plug, 'i')
            execute 'imap <buffer> ' . l:closer . ' ' l:closer_plug
        endif
    endfor
    for l:opener in map(keys(l:pairs), 'v:val[-1:]')
        let l:opener_plug = '<Plug>(PearTreeOpener_' . l:opener . ')'
        if !hasmapto(l:opener_plug, 'i')
            execute 'imap <buffer> ' . l:opener . ' ' l:opener_plug
        endif
    endfor

    if !hasmapto('<Plug>(PearTreeBackspace)', 'i')
        imap <buffer> <BS> <Plug>(PearTreeBackspace)
    endif
    if !hasmapto('<Plug>(PearTreeExpand)', 'i')
        imap <buffer> <CR> <Plug>(PearTreeExpand)
    endif
    if !hasmapto('<Plug>(PearTreeFinishExpansion)', 'i')
        imap <buffer> <ESC> <Plug>(PearTreeFinishExpansion)
    endif
    if !hasmapto('<Plug>(PearTreeJump)', 'i')
        imap <buffer> <C-l> <Plug>(PearTreeJump)
    endif
endfunction


command -bar PearTreeEnable call s:BufferEnable()
command -bar PearTreeDisable call s:BufferDisable()

augroup pear_tree
    autocmd!
    autocmd BufRead,BufNewFile *
                \ if index(g:pear_tree_ft_disabled, &filetype) == -1 |
                \       call <SID>BufferEnable() |
                \ endif
    autocmd InsertEnter *
                \ if exists('b:pear_tree_enabled') && b:pear_tree_enabled |
                \       call pear_tree#insert_mode#Prepare() |
                \ endif
    autocmd CursorMovedI,InsertEnter *
                \ if exists('b:pear_tree_enabled') && b:pear_tree_enabled |
                \       call pear_tree#insert_mode#OnCursorMovedI() |
                \ endif
    autocmd InsertCharPre *
                \ if exists('b:pear_tree_enabled') && b:pear_tree_enabled |
                \       call pear_tree#insert_mode#OnInsertCharPre() |
                \ endif
augroup END

let &cpoptions = s:save_cpo
unlet s:save_cpo
