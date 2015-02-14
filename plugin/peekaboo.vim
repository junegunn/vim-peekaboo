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

function! peekaboo#on()
  nnoremap <silent> " :<c-u>call peekaboo#peek(v:count1, 'quote',  0)<cr>
  xnoremap <silent> " :<c-u>call peekaboo#peek(v:count1, 'quote',  1)<cr>
  nnoremap <silent> @ :<c-u>call peekaboo#peek(v:count1, 'replay', 0)<cr>
  inoremap <silent> <c-r> <c-o>:call peekaboo#peek(1, 'ctrl-r',  0)<cr>
  return ''
endfunction

function! peekaboo#off()
  nunmap "
  xunmap "
  nunmap @
  iunmap <c-r>
endfunction

call peekaboo#on()

