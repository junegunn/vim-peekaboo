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

let s:cpo_save = &cpo
set cpo&vim

" Default options
let s:default_delay = 0
let s:default_window = 'vertical botright 30new'
let s:default_compact = 0

let s:QUOTE  = '"'
let s:REPLAY = '@'
let s:CTRL_R = "\<c-r>"

let s:buf_peekaboo = 0

" Returns true if timed out
function! s:wait_with_timeout(timeout)
  let timeout = a:timeout
  while timeout >= 0
    if getchar(1)
      return 0
    endif
    if timeout > 0
      sleep 20m
    endif
    let timeout -= 20
  endwhile
  return 1
endfunction

" Checks if Peekaboo buffer is open
function! s:is_open()
  return s:buf_peekaboo
endfunction

" Closes peekaboo buffer
function! s:close()
  silent! execute 'bd' s:buf_peekaboo
  let s:buf_peekaboo = 0
  execute s:winrestcmd
endfunction

" Appends macro list for the specified group to Peekaboo window
function! s:append_group(title, regs)
  let compact = get(g:, 'peekaboo_compact', s:default_compact)
  if !compact | call append(line('$'), a:title.':') | endif
  for r in a:regs
    try
      if r == '%'     | let val = s:buf_current
      elseif r == '#' | let val = s:buf_alternate
      else            | let val = eval('@'.r)[:&columns]
      endif
      if empty(val)
        continue
      endif
      let s:regs[printf('%s', r)] = line('$')
      call append(line('$'), printf(' %s: %s', r, substitute(val, '^\s*', '', '')))
    catch
    endtry
  endfor
  if !compact | call append(line('$'), '') | endif
endfunction

" Opens peekaboo window
function! s:open(mode)
  let [s:buf_current, s:buf_alternate, s:winrestcmd] = [@%, @#, winrestcmd()]
  execute get(g:, 'peekaboo_window', s:default_window)
  let s:buf_peekaboo = bufnr('')
  setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  \ modifiable statusline=>\ Registers nocursorline nofoldenable
  if exists('&relativenumber')
    setlocal norelativenumber
  endif

  setfiletype peekaboo
  augroup peekaboo
    autocmd!
    autocmd CursorMoved <buffer> bd
  augroup END

  let s:regs = {}
  call s:append_group('Special', ['"', '*', '+', '-'])
  call s:append_group('Read-only', a:mode ==# s:REPLAY ? ['.', ':'] : ['.', '%', '#', '/', ':'])
  call s:append_group('Numbered', map(range(0, 9), 'string(v:val)'))
  call s:append_group('Named', map(range(97, 97 + 25), 'nr2char(v:val)'))
  normal! "_dd
endfunction

" Checks if the buffer for the position is visible on screen
function! s:is_visible(pos)
  return a:pos.tab == tabpagenr() && bufwinnr(a:pos.buf) != -1
endfunction

" Triggers gv to keep visual highlight on
function! s:gv(visualmode, visible)
  if a:visualmode && a:visible
    noautocmd wincmd p
    normal! gv
    redraw
    noautocmd wincmd p
  else
    redraw
  endif
endfunction

" Feeds the final key sequence
function! s:feed(count, mode, reg, rest)
  call feedkeys(a:count > 1 ? a:count : '', 'n')
  if a:mode ==# s:QUOTE
    call feedkeys('"'.a:reg, 'n')
    call feedkeys(a:rest)
  elseif a:mode ==# s:CTRL_R
    call feedkeys("\<c-r>".a:reg, 'n')
  else
    call feedkeys('@'.a:reg, 'n')
  endif
endfunction

let s:scroll = {
\ "\<up>":     "\<c-y>", "\<down>":     "\<c-e>",
\ "\<c-y>":    "\<c-y>", "\<c-e>":      "\<c-e>",
\ "\<c-u>":    "\<c-u>", "\<c-d>":      "\<c-d>",
\ "\<c-b>":    "\<c-b>", "\<c-f>":      "\<c-f>",
\ "\<pageup>": "\<c-b>", "\<pagedown>": "\<c-f>"
\ }

" Returns the position of the current buffer as a dictionary
function! s:getpos()
  return {'tab': tabpagenr(), 'buf': bufnr(''), 'win': winnr(), 'cnt': winnr('$')}
endfunction

function! peekaboo#peek(count, mode, visualmode)
  " First check if we should start peekaboo, if not just return the mode key
  let timeout = get(g:, 'peekaboo_delay', s:default_delay)
  if !s:wait_with_timeout(timeout)
    return a:mode
  endif

  let s:args = [a:count, a:mode, a:visualmode]
  return "\<Plug>(peekaboo)"
endfunction

function! peekaboo#aboo()
  let [cnt, mode, visualmode] = s:args

  if s:is_open()
    call s:close()
  endif

  let positions = { 'current': s:getpos() }
  call s:open(mode)
  let positions.peekaboo = s:getpos()

  let inplace = positions.current.tab == positions.peekaboo.tab &&
        \ positions.current.win == positions.peekaboo.win &&
        \ positions.current.cnt == positions.peekaboo.cnt
  let visible = !inplace && s:is_visible(positions.current)

  call s:gv(visualmode, visible)

  let [stl, lst] = [&showtabline, &laststatus]
  let zoom = 0
  try
    while 1
      let ch  = getchar()
      let reg = nr2char(ch)
      let key = get(s:scroll, ch, get(s:scroll, reg, ''))
      if !empty(key)
        execute 'normal!' key
        call s:gv(visualmode, visible)
        continue
      endif

      if zoom
        tab close
        let [&showtabline, &laststatus] = [stl, lst]
        call s:gv(visualmode, visible)
      endif
      if reg != ' '
        break
      endif
      if !zoom
        tab split
        set showtabline=0 laststatus=0
      endif
      let zoom = !zoom
      redraw
    endwhile

    let rest = ''
    if mode ==# s:QUOTE && has_key(s:regs, tolower(reg))
      let line = s:regs[tolower(reg)]
      execute line
      execute 'syntax region peekabooSelected start=/\%'.line.'l\%5c/ end=/$/'
      setlocal cursorline
      call setline(line('.'), substitute(getline('.'), ' .', ' '.reg, ''))
      call s:gv(visualmode, visible)
      let rest = nr2char(getchar())
    endif

    " - Make sure that we're back to the original tab/window/buffer
    "   - e.g. g:peekaboo_window = 'tabnew' / 'enew'
    if inplace
      noautocmd execute positions.current.win.'wincmd w'
      noautocmd execute 'buf' positions.current.buf
    else
      noautocmd execute 'tabnext' positions.current.tab
      call s:close()
      noautocmd execute positions.current.win.'wincmd w'
    endif
    if visualmode
      normal! gv
    endif
    call s:feed(cnt, mode, reg, rest)
  catch /^Vim:Interrupt$/
    return
  finally
    let [&showtabline, &laststatus] = [stl, lst]
    call s:close()
    redraw
  endtry
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
