" The MIT License (MIT)
"
" Copyright (c) 2017 Junegunn Choi
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

function! peekaboo#on()
  if get(b:, 'peekaboo_on', 0)
    return
  endif

  let prefix = get(g:, 'peekaboo_prefix', '')
  let ins_prefix = get(g:, 'peekaboo_ins_prefix', '')
  execute 'nnoremap <buffer> <silent> '.prefix.'" :<c-u>call peekaboo#peek(v:count1, ''quote'',  0)<cr>'
  execute 'xnoremap <buffer> <silent> '.prefix.'" :<c-u>call peekaboo#peek(v:count1, ''quote'',  1)<cr>'
  execute 'nnoremap <buffer> <silent> '.prefix.'@ :<c-u>call peekaboo#peek(v:count1, ''replay'', 0)<cr>'
  execute 'inoremap <buffer> <silent> '.ins_prefix.'<c-r> <c-\><c-o>:call peekaboo#peek(1, ''ctrl-r'',  0)<cr>'
  let b:peekaboo_on = 1
  return ''
endfunction

function! peekaboo#off()
  let prefix = get(g:, 'peekaboo_prefix', '')
  let ins_prefix = get(g:, 'peekaboo_ins_prefix', '')
  execute 'nunmap <buffer> '.prefix.'"'
  execute 'xunmap <buffer> '.prefix.'"'
  execute 'nunmap <buffer> '.prefix.'@'
  execute 'iunmap <buffer> '.ins_prefix.'<c-r>'
  let b:peekaboo_on = 0
endfunction

augroup peekaboo_init
  autocmd!
  autocmd BufEnter * if !exists('*getcmdwintype') || empty(getcmdwintype()) | call peekaboo#on() | endif
augroup END

