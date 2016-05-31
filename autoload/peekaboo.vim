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
let s:disable_duration = 200

function! s:append_group(title, regs)
  let compact = get(g:, 'peekaboo_compact', 0)
  if !compact | call append(line('$'), a:title.':') | endif
  for r in a:regs
    try
      if r == '%'     | let val = s:cur
      elseif r == '#' | let val = s:alt
      else            | let val = eval('@'.r)
      endif
      if empty(val)
        continue
      endif
      let s:regs[printf('%s', r)] = line('$')
      call append(line('$'), printf(' %s: %s', r, val))
    catch
    endtry
  endfor
  if !compact | call append(line('$'), '') | endif
endfunction

function! s:close()
  if s:peekaboo
    silent! execute 'bd' s:peekaboo
  endif
endfunction

function! s:diff_ms(since)
  let [sec, usec] = map(split(reltimestr(reltime(a:since)), '[^0-9]'), 'str2nr(v:val)')
  let usec = sec * 1000000 + usec
  return usec / 1000
endfunction

function! s:gets_nodelay()
  let s = ''
  while 1
    let c = getchar(0)
    if !c
      break
    endif
    let s .= nr2char(c)
  endwhile
  return s
endfunction

function! s:init(mode)
  call s:close()
  if exists('s:disabled')
    if s:diff_ms(s:disabled) < s:disable_duration
      let s:disabled = reltime()
      return [0, s:gets_nodelay()]
    endif
    unlet s:disabled
  endif

  let delay = get(g:, 'peekaboo_delay', 0)
  while delay > 0
    let delay -= 50
    let c = getchar(0)
    if c
      return [0, nr2char(c)]
    endif
    sleep 50m
  endwhile

  let [s:cur, s:alt] = [@%, @#]
  execute get(g:, 'peekaboo_window', 'vertical botright 30new')
  let s:peekaboo = bufnr('')
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
  call s:append_group('Read-only', a:mode ==# 'replay' ? ['.', ':'] : ['.', '%', '#', '/', ':'])
  call s:append_group('Numbered', map(range(0, 9), 'string(v:val)'))
  call s:append_group('Named', map(range(97, 97 + 25), 'nr2char(v:val)'))
  normal! "_dd
  return [1, '']
endfunction

function! s:visible(pos)
  return a:pos.tab == tabpagenr() && bufwinnr(a:pos.buf) != -1 && !s:inplace
endfunction

function! s:move(pos)
  if a:pos.tab != tabpagenr()
    noautocmd execute 'normal!' (a:pos.tab).'gt'
  endif
  noautocmd execute bufwinnr(a:pos.buf).'wincmd w'
endfunction

function! s:back(visualmode)
  if s:visible(s:win.current)
    call s:move(s:win.current)
    if a:visualmode
      normal! gv
    endif
  endif
  redraw
endfunction

function! s:feed(count, mode, reg, rest)
  call feedkeys(a:count > 1 ? a:count : '', 'n')
  if a:mode ==# 'quote'
    call feedkeys('"'.a:reg, 'n')
    call feedkeys(a:rest)
  elseif a:mode ==# 'ctrl-r'
    call feedkeys("\<c-r>".a:reg, 'n')
  else
    let s:disabled = reltime()
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

function! s:getpos()
  return {'tab': tabpagenr(), 'buf': bufnr(''), 'win': winnr(), 'cnt': winnr('$')}
endfunction

function! peekaboo#peek(count, mode, visualmode)
  let s:win = { 'current': s:getpos() }
  let [ok, str] = s:init(a:mode)
  let s:win.peekaboo = s:getpos()
  let s:inplace = s:win.current.tab == s:win.peekaboo.tab &&
                \ s:win.current.win == s:win.peekaboo.win &&
                \ s:win.current.cnt == s:win.peekaboo.cnt
  if !ok
    if a:visualmode
      normal! gv
    endif
    return s:feed(a:count, a:mode, str, '')
  endif
  call s:back(a:visualmode)

  let [stl, lst] = [&showtabline, &laststatus]
  let zoom = 0
  try
    while 1
      let ch  = getchar()
      let reg = nr2char(ch)
      let key = get(s:scroll, ch, get(s:scroll, reg, ''))
      if !empty(key)
        call s:move(s:win.peekaboo)
        execute 'normal!' key
        call s:back(a:visualmode)
        continue
      endif

      if zoom
        tab close
        let [&showtabline, &laststatus] = [stl, lst]
        call s:back(a:visualmode)
      endif
      if reg != ' '
        break
      endif
      if !zoom
        call s:move(s:win.peekaboo)
        tab split
        set showtabline=0 laststatus=0
      endif
      let zoom = !zoom
      redraw
    endwhile

    let rest = ''
    if a:mode ==# 'quote' && has_key(s:regs, tolower(reg))
      call s:move(s:win.peekaboo)
      let line = s:regs[tolower(reg)]
      execute 'normal!' line.'G'
      execute 'syntax region peekabooSelected start=/\%'.line.'l\%5c/ end=/$/'
      setlocal cursorline
      call setline(line('.'), substitute(getline('.'), ' .', ' '.reg, ''))
      call s:back(a:visualmode)
      let rest = nr2char(getchar())
    endif

    " - Make sure that we're back to the original tab/window/buffer
    "   - e.g. g:peekaboo_window = 'tabnew' / 'enew'
    if s:inplace
      noautocmd execute s:win.peekaboo.win.'wincmd w'
      noautocmd execute 'buf' s:win.current.buf
    else
      call s:move(s:win.current)
    endif
    if a:visualmode
      normal! gv
    endif
    call s:feed(a:count, a:mode, reg, rest)
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
