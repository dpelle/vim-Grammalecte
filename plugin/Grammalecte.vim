" Grammalecte: French Grammar checker.
" Maintainer:  Dominique Pellé <dominique.pelle@gmail.com>
" Screenshots: http://dominique.pelle.free.fr/pic/GrammalecteVimPlugin.png
" Last Change: 2017/01/11
" Version:     0.2
"
" Description: {{{1
"
" This plugin integrates the Grammalecte French grammar checker into Vim.
"
" See doc/Grammalecte.txt for more details about how to use the Grammalecte
" plugin.
"
" See http://dicollecte.org/grammalecte for more information about Grammalecte.
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

" Set up configuration.
" Returns 0 if success, < 0 in case of error.
function s:GrammalecteSetUp() "{{{1
  " The plugin deactivates a few Grammalecte rules by default. User
  " can override what rules to deactivate by specifying rule names to
  " disable, separated with space, in the option g:grammalecte_disable_rules.
  let s:grammalecte_disable_rules =
  \ exists("g:grammalecte_disable_rules")
  \ ? g:grammalecte_disable_rules
  \ : 'apostrophe_typographique apostrophe_typographique_après_t '
  \ . 'espaces_début_ligne espaces_milieu_ligne espaces_fin_de_ligne '
  \ . 'typo_points_suspension1 typo_tiret_incise '
  \ . 'nbsp_avant_double_ponctuation nbsp_avant_deux_points '
  \ . 'nbsp_après_chevrons_ouvrants nbsp_avant_chevrons_fermants1 '
  \ . 'unit_nbsp_avant_unités1 unit_nbsp_avant_unités2 '
  \ . 'unit_nbsp_avant_unités3'
  let s:grammalecte_win_height = exists("g:grammalecte_win_height")
  \ ? g:grammalecte_win_height
  \ : 14

  let s:grammalecte_cli_py = exists("g:grammalecte_cli_py")
  \ ? g:grammalecte_cli_py
  \ : $HOME . '/grammalecte/pythonpath/cli.py'

  if !filereadable(s:grammalecte_cli_py)
    " Hmmm, can't find the python file.  Try again with expand() in case user
    " set it up as: let g:python_cli_py = '$HOME/grammalecte/pythonpath/cli.py'
    let l:grammalecte_cli_py = expand(s:grammalecte_cli_py)
    if !filereadable(expand(l:grammalecte_cli_py))
      echomsg "Grammalecte cannot be found at: " . s:grammalecte_cli_py
      echomsg "You need to install Grammalecte and/or set up g:grammalecte_cli_py"
      echomsg "to indicate the location of the Grammalecte pythonpath/cli.py script."
      return -1
    endif
    let s:grammalecte_cli_py = l:grammalecte_cli_py
  endif

endfunction

" Jump to a grammar mistake (called when pressing <Enter>
" on a particular error in scratch buffer).
function <sid>JumpToCurrentError() "{{{1
  let l:save_cursor = getpos('.')
  norm! $
  if search('^Erreur : .*C$', 'beW') > 0
    let l:matches = matchlist(getline('.'), '^Erreur :\s\+\(\d\+/\d\+ \S\+ @ \)\(\d\+\)L \(\d\+\)C$')
    let l:line = l:matches[2]
    let l:col = l:matches[3]
    exe s:grammalecte_text_win . ' wincmd w'
    exe 'norm! ' . l:line . 'G0'
    if l:col > 0
      exe 'norm! ' . (l:col  - 1) . 'l'
    endif
    echon 'Jump to error ' . l:matches[1] . l:line . 'L ' . l:col . 'C'
    norm! zz
  else
    call setpos('.', l:save_cursor)
  endif
endfunction

" Return a regular expression used to highlight a grammatical error
function s:GrammalecteHighlightRegex(start_line, end_line, start_column, end_column, underlined) "{{{1
  let l:start_col_idx = byteidx(getline(a:start_line), a:start_column - 1) + 1
  let l:end_col_idx   = byteidx(getline(a:end_line), a:end_column - 1) + 1

  return '\%' . a:start_line    . 'l'
  \    . '\%' . l:start_col_idx . 'c'
  \    . '\V' . substitute(escape(a:underlined, '\'), ' \+', '\\_\\s\\+', 'g')
  \    . '\%' . a:end_line      . 'l'
  \    . '\%' . l:end_col_idx   . 'c'
endfunction

" Compare errors by Y first and then by X as tie-breaker.
function s:CompareErrors(e1, e2) "{{{1
  return a:e1['nStartY'] == a:e2['nStartY'] ? a:e1['nStartX'] - a:e2['nStartX' ]
  \                                         : a:e1['nStartY'] - a:e2['nStartY']
endfunction

" This function performs grammar checking of text in the current buffer.
" It highlights grammar mistakes in current buffer and opens a scratch
" window with all errors found.  It also populates the location-list of
" the window with all errors.
" a:line1 and a:line2 parameters are the first and last line number of
" the range of line to check.
function s:GrammalecteCheck(line1, line2) "{{{1
  if s:GrammalecteSetUp() < 0
    return -1
  endif
  call s:GrammalecteClear()

  let s:grammalecte_text_win = winnr()
  sil %y
  botright new
  let s:grammalecte_error_buffer = bufnr('%')
  let l:tmpfilename = tempname()
  let l:tmperror    = tempname()
  sil put!

  let l:range = a:line1 . ',' . a:line2
  silent exe l:range . 'w!' . l:tmpfilename

  let l:grammalecte_cmd = 'python3 ' . s:grammalecte_cli_py
  \ . ' -f ' . l:tmpfilename
  \ . (empty(s:grammalecte_disable_rules) ? ' ' : (' -roff ' . s:grammalecte_disable_rules))
  \ . ' -j -cl -owe -ctx 2> ' . l:tmperror
  let l:errors_json = system(l:grammalecte_cmd)
  call delete(l:tmpfilename)
  if v:shell_error
    echoerr 'Command [' . l:grammalecte_cmd . '] failed with error: '
    \      . v:shell_error
    if filereadable(l:tmperror)
      echoerr string(readfile(l:tmperror))
    endif
    call delete(l:tmperror)
    call s:GrammalecteClear()
    return -1
  endif
  call delete(l:tmperror)

  %d
  try
    let l:errors = json_decode(l:errors_json)['data']
  catch
    echoerr "Error while decoding json output of Grammalecte. "
    \     . "Try running Grammalecte in command line to diagnose."
  endtry

  set bt=nofile
  setlocal nospell
  syn clear

  call matchadd('GrammalecteCmd', '\%1l')
  call matchadd('GrammalecteLabel', '^\(Message\|Contexte\|Correction\|Corrections\|URL\) :')
  call matchadd('GrammalecteErrorCount', '^Erreur :\s\+\d\+/\d\+')
  call matchadd('GrammalecteUrl', '^URL :\s*\zs.*')

  call append(0, '# ' . l:grammalecte_cmd)

  if s:grammalecte_win_height >= 0
    " First count the total number of grammar errors.
    let l:error_count = 0
    for l:errors_in_paragraph in l:errors
      let l:error_count += len(l:errors_in_paragraph['lGrammarErrors'])
    endfor

    " Format JSON output in a human readable way.
    let l:error_num = 1
    for l:errors_in_paragraph in l:errors
      let l:grammar_errors_in_paragraph  = l:errors_in_paragraph['lGrammarErrors']
      " Loop on errors in paragraph, ordered by their starting lines and starting columns.
      for l:grammar_error in sort(l:grammar_errors_in_paragraph, "s:CompareErrors")
        let l:line_num_start = l:grammar_error['nStartY'] + a:line1 - 1
        let l:line_num_end   = l:grammar_error['nEndY']   + a:line1 - 1
        let l:col_num_start  = l:grammar_error['nStartX'] + 1
        let l:col_num_end    = l:grammar_error['nEndX']   + 1
        let l:before         = l:grammar_error['sBefore']
        let l:after          = l:grammar_error['sAfter']
        let l:underlined     = l:grammar_error['sUnderlined']
        call append(line('$'), 'Erreur :      '
              \ . l:error_num . '/' . l:error_count . ' '
              \ . l:grammar_error['sRuleId'] . ' @ '
              \ . l:line_num_start . 'L '
              \ . l:col_num_start  . 'C')
        call append(line('$'), 'Message :     ' . l:grammar_error['sMessage'])
        call append(line('$'), 'Contexte :    ' . l:before . l:underlined . l:after)
        let l:re = '^\%' . line('$') . 'l'
              \ . '.\{' . (14 + strchars(l:before)) . '}'
              \ . '\zs.\{' . (strchars(l:underlined)) . '}'
        call matchadd('GrammalecteGrammarError', l:re)
        if !empty(l:grammar_error['aSuggestions'])
          if len(l:grammar_error['aSuggestions']) == 1
            call append(line('$'), 'Correction :  ' . l:grammar_error['aSuggestions'][0])
          else
            call append(line('$'), 'Corrections : ' . string(l:grammar_error['aSuggestions']))
          endif
        endif
        if !empty(l:grammar_error['URL'])
          call append(line('$'), 'URL :         ' . l:grammar_error['URL'])
        endif
        call append('$', '')
        let l:error_num = l:error_num + 1
      endfor
    endfor

    exe "norm! z" . s:grammalecte_win_height . "\<CR>"
    0
    map <silent> <buffer> <CR> :call <sid>JumpToCurrentError()<CR>
    redraw
    echon 'Press <Enter> on error in scratch buffer to jump its location'
    exe "norm! \<C-W>\<C-P>"
  else
    " Negative s:grammalecte_win_height -> no scratch window.
    bd!
    unlet! s:grammalecte_error_buffer
  endif

  " Highlight errors in original buffer and populate location list.
  setlocal errorformat=%f:%l:%c:%m
  for l:errors_in_paragraph in l:errors

    let l:grammar_errors_in_paragraph   = l:errors_in_paragraph['lGrammarErrors']
    for l:grammar_error in l:grammar_errors_in_paragraph
      let l:line_num_start = l:grammar_error['nStartY'] + a:line1 - 1
      let l:line_num_end   = l:grammar_error['nEndY']   + a:line1 - 1
      let l:col_num_start  = l:grammar_error['nStartX'] + 1
      let l:col_num_end    = l:grammar_error['nEndX']   + 1
      let l:re = s:GrammalecteHighlightRegex(l:line_num_start, l:line_num_end,
      \                                      l:col_num_start, l:col_num_end,
      \                                      l:grammar_error['sUnderlined'])
      call matchadd('GrammalecteGrammarError', l:re)
      laddexpr expand('%') . ':'
      \ . l:line_num_start . ':'  . l:col_num_start . ':'
      \ . l:grammar_error['sRuleId'] . ' ' . l:grammar_error['sMessage']
    endfor

    let l:spelling_errors_in_paragraph = l:errors_in_paragraph['lSpellingErrors']
    for l:spelling_error in l:spelling_errors_in_paragraph
      let l:line_num_start = l:spelling_error['nStartY'] + a:line1 - 1
      let l:line_num_end   = l:spelling_error['nEndY']   + a:line1 - 1
      let l:col_num_start  = l:spelling_error['nStartX'] + 1
      let l:col_num_end    = l:spelling_error['nEndX']   + 1
      let l:re = s:GrammalecteHighlightRegex(l:line_num_start, l:line_num_end,
      \                                      l:col_num_start, l:col_num_end,
      \                                      l:spelling_error['sValue'])
      call matchadd('GrammalecteSpellingError', l:re)
    endfor
  endfor
  return 0
endfunction

" This function clears syntax highlighting created by Grammalecte plugin
" and removes the scratch window containing grammar errors.
function s:GrammalecteClear() "{{{1
  if exists('s:grammalecte_error_buffer')
    if bufexists(s:grammalecte_error_buffer)
      sil! exe "bd! " . s:grammalecte_error_buffer
    endif
  endif
  if exists('s:grammalecte_text_win')
    let l:win = winnr()
    exe s:grammalecte_text_win . ' wincmd w'
    call setmatches(filter(getmatches(), 'v:val["group"] !~# "Grammalecte.*Error"'))
    lexpr ''
    lclose
    exe l:win . ' wincmd w'
  endif
  unlet! s:grammalecte_error_buffer
  unlet! s:grammalecte_error_win
  unlet! s:grammalecte_text_win
endfunction

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
com! -nargs=0          GrammalecteClear :call s:GrammalecteClear()
com! -nargs=0 -range=% GrammalecteCheck :call s:GrammalecteCheck(<line1>,
                                                               \ <line2>)
" vim: fdm=marker
