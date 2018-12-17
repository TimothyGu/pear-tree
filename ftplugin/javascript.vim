" Pear Tree - A painless, powerful Vim auto-pair plugin
" Maintainer: Thomas Savage <thomasesavage@gmail.com>
" Version: 0.6
" License: MIT
" Website: https://github.com/tmsvg/pear-tree


let s:save_cpo = &cpoptions
set cpoptions&vim

if !exists('b:pear_tree_pairs')
    let b:pear_tree_pairs = extend(deepcopy(g:pear_tree_pairs), {
                \ '`': {'closer': '`'},
                \ '/\*\*': {'closer': '\*/'}
                \ }, 'keep')
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo
