" Grammalecte: French Grammar checker.
" Maintainer:  Dominique Pellé <dominique.pelle@gmail.com>
" Screenshots: http://dominique.pelle.free.fr/pic/GrammalecteVimPlugin.png
" Last Change: 2020/10/30
"
" Description: {{{1
"
" This plugin integrates the Grammalecte French grammar checker into Vim.
"
" See doc/Grammalecte.txt for more details about how to use the Grammalecte
" plugin.
"
" See https://grammalecte.net for more information about Grammalecte.
"
" Implementation is quite similar to the LanguageTool vim plugin.
"
" License: {{{1
"
" The VIM LICENSE applies to Grammalecte.vim plugin
" (see ":help copyright" except use "Grammalecte.vim" instead of "Vim").
"
" Plugin set up {{{1
if &cp || exists("g:loaded_grammalecte")
 finish
endif

if !exists('*json_decode')
  echoerr 'Grammalecte plugin requires json_decode() available in Vim-7.4.1304 or newer with +eval feature.'
  finish
endif

let g:loaded_grammalecte = "1"

hi def link GrammalecteCmd           Comment
hi def link GrammalecteErrorCount    Title
hi def link GrammalecteLabel         Label
hi def link GrammalecteUrl           Underlined
hi def link GrammalecteGrammarError  Error
hi def link GrammalecteSpellingError WarningMsg

" Menu items {{{1
if has("gui_running") && has("menu") && &go =~# 'm'
  amenu <silent> &Plugin.Grammalecte.Chec&k :GrammalecteCheck<CR>
  amenu <silent> &Plugin.Grammalecte.Clea&r :GrammalecteClear<CR>
endif

" Defines commands {{{1
com! -nargs=0          GrammalecteClear :call grammalecte#Clear()
com! -nargs=0 -range=% GrammalecteCheck :call grammalecte#Check(<line1>,
                                                              \ <line2>)
" vim: fdm=marker
