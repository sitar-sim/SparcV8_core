" Vim syntax file for mcode, the APARA engine's assembly language.
" Install: copy to ~/.vim/syntax/mcode.vim, and add to ~/.vimrc
"     au BufRead,BufNewFile *.mcode set filetype=mcode
" (Ref compiler/apara/README.md.)

if exists("b:current_syntax")
  finish
endif

syn match   mcodeComment   "//.*$" contains=mcodeDirective
syn match   mcodeDirective "//@.*$" contained
syn match   mcodeBundle    "||\|;"
syn match   mcodeLabel     "^\s*\a[A-Za-z0-9_.]*\ze\s*:"
syn match   mcodeRegister  "\$r\d\+\>"
syn match   mcodeType      "\$v\=[iuf]\d\+\>"
syn match   mcodeKeyword   "\$\(ld\|st\|cast\|cmov\|pack\|set\|slice\|dot\|fsqrt\|vreduce\|v\|call\|return\|goto\|null\|halt\)\>"
syn match   mcodeFlag      "\$\(accumulate\|replicate\)\>"
syn match   mcodeNumber    "\<_h\x\+\>\|-\=\<\d\+\>"
syn match   mcodeOperator  "++\|--\|==\|>=\|<=\|!=\|<<\|>>\|\~[|&^]\|[?+*/|&^<>-]"

hi def link mcodeComment   Comment
hi def link mcodeDirective PreProc
hi def link mcodeBundle    Special
hi def link mcodeLabel     Label
hi def link mcodeRegister  Identifier
hi def link mcodeType      Type
hi def link mcodeKeyword   Statement
hi def link mcodeFlag      Statement
hi def link mcodeNumber    Number
hi def link mcodeOperator  Operator

let b:current_syntax = "mcode"
