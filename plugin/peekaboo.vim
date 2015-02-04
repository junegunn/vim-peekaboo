" The MIT License (MIT)
"
" Copyright (c) 2015 Junegunn Choi
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

let s:cpo_save = &cpo
set cpo&vim

let s:peekaboo = 0

function! s:append_group(title, regs)
  call append(line('$'), a:title.':')
  for r in a:regs
    try
      let val = eval('@'.r)
      if empty(val)
        continue
      endif
      let s:regs[printf('%s', r)] = line('$')
      call append(line('$'), printf(' %s: %s', r, val))
    catch
    endtry
  endfor
  call append(line('$'), '')
endfunction

function! s:close()
  if s:peekaboo
    silent! execute 'bd' s:peekaboo
  endif
endfunction

function! s:init()
  call s:close()
  execute get(g:, 'peekaboo_window', 'vertical botright 30new')
  let s:peekaboo = bufnr('')
  setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
         \ modifiable statusline=>\ Registers nocursorline
  silent file peekaboo
  setfiletype peekaboo
  augroup peekaboo
    autocmd!
    autocmd CursorMoved <buffer> bd
  augroup END

  let s:regs = {}
  call s:append_group('Special', ['"', '*', '+', '/', '-', ':'])
  call s:append_group('Numbered', range(0, 9))
  call s:append_group('Named', map(range(97, 97 + 25), 'nr2char(v:val)'))
  normal! "_dd
endfunction

function! s:peekaboo(count, visualmode)
  call s:init()

  wincmd p
  if a:visualmode
    normal! gv
  endif
  redraw

  try
    let reg  = nr2char(getchar())
    let rest = ''
    let known = has_key(s:regs, reg)
    let upper = !known && has_key(s:regs, tolower(reg))
    if known || upper
      wincmd p
      let line = s:regs[tolower(reg)]
      execute 'normal!' line.'G'
      execute 'syntax region peekabooSelected start=/\%'.line.'l\%5c/ end=/$/'
      setlocal cursorline
      call setline(line('.'), substitute(getline('.'), ' .', ' '.reg, ''))
      wincmd p
      if a:visualmode
        normal! gv
      endif
      redraw
      let rest = nr2char(getchar())
    endif

    let seq = a:count > 1 ? a:count : ''
    if reg == '"'
      let seq .= "\<Plug>(peekaboo2)" . rest
    else
      let seq .= "\<Plug>(peekaboo1)" . reg . rest
    endif
    call feedkeys(seq)
  catch /^Vim:Interrupt$/
    return
  finally
    call s:close()
    redraw
  endtry
endfunction

nnoremap <silent> " :<c-u>call <sid>peekaboo(v:count1, 0)<cr>
xnoremap <silent> " :<c-u>call <sid>peekaboo(v:count1, 1)<cr>
nnoremap <Plug>(peekaboo1) "
nnoremap <Plug>(peekaboo2) ""
xnoremap <Plug>(peekaboo1) "
xnoremap <Plug>(peekaboo2) ""

let &cpo = s:cpo_save
unlet s:cpo_save

