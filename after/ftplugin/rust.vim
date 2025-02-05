" Pear Tree - A painless, powerful Vim auto-pair plugin
" Maintainer: Thomas Savage <thomasesavage@gmail.com>
" Version: 0.8
" License: MIT
" Website: https://github.com/tmsvg/pear-tree

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('b:undo_ftplugin')
    let b:undo_ftplugin .= ' | unlet! b:pear_tree_pairs'
else
    let b:undo_ftplugin = 'unlet! b:pear_tree_pairs'
endif

let b:pear_tree_pairs = extend(deepcopy(g:pear_tree_pairs), {
            \ "```": {'closer': "```"},
            \ }, 'keep')

" Rust prefixes lifetime variables and loop labels with a single quote which
" should not be automatically closed. The 'not_at' patterns for the single quote
" pair here prevent inserting a closing quote if the text before the cursor is
" an opening angle bracket with zero or more following lifetime paramaters, or
" if the character immediately before the cursor is an ampersand.
let s:patterns = ['<\s*\(''\s*[a-z]\s*,\s*\)*',
                \ '&']
if has_key(b:pear_tree_pairs, '''')
    let b:pear_tree_pairs['''']['not_at'] = get(b:pear_tree_pairs[''''], 'not_at', []) + s:patterns
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo
