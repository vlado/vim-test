function! test#strategy#vimscript(cmd) abort
  execute a:cmd
endfunction

function! test#strategy#basic(cmd) abort
  if s:restorescreen()
    execute '!'.s:pretty_command(a:cmd)
  else
    execute '!'.a:cmd
  endif
endfunction

function! test#strategy#neovim(cmd) abort
  enew | call termopen(a:cmd) | startinsert
endfunction

function! test#strategy#neoterm(cmd) abort
  execute 'T '.a:cmd
endfunction

function! test#strategy#vtr(cmd) abort
  call VtrSendCommand(s:pretty_command(a:cmd), 1)
endfunction

function! test#strategy#dispatch(cmd) abort
  execute 'Dispatch '.a:cmd
endfunction

function! test#strategy#vimux(cmd) abort
  call VimuxRunCommand(s:pretty_command(a:cmd))
endfunction

function! test#strategy#tslime(cmd) abort
  call Send_to_Tmux(s:pretty_command(a:cmd)."\n")
endfunction

function! test#strategy#terminal(cmd) abort
  call s:execute_script('osx_terminal', s:pretty_command(a:cmd))
endfunction

function! test#strategy#iterm(cmd) abort
  call s:execute_script('osx_iterm', s:pretty_command(a:cmd))
endfunction

function! test#strategy#vagrant(cmd) abort
  let vagrant_project = get(matchlist(s:cat('Vagrantfile'), '\vconfig\.vm.synced_folder ["''].+[''"], ["''](.+)[''"]'), 1)

  if empty(vagrant_project)
    if empty(glob('Vagrantfile'))
      echoerr "Vagrantfile wasn't found"
    else
      echoerr "Cannot find Vagrant project root"
    endif
    return
  endif

  let cmd = "vagrant ssh --command ".shellescape('cd '.vagrant_project.'; '.a:cmd)

  call test#strategy#basic(cmd)
endfunction

function! s:execute_script(name, cmd) abort
  let script_path = g:test#plugin_path . '/bin/' . a:name
  let cmd = join([script_path, shellescape(a:cmd)])
  execute 'silent !'.cmd
endfunction

function! s:pretty_command(cmd) abort
  let clear = !s:Windows() ? 'clear' : 'cls'
  let echo  = !s:Windows() ? 'echo -e '.shellescape(a:cmd) : 'Echo '.shellescape(a:cmd)

  return join([l:clear, l:echo, a:cmd], '; ')
endfunction

function! s:Windows() abort
  return has('win32') && fnamemodify(&shell, ':t') ==? 'cmd.exe'
endfunction

function! s:restorescreen() abort
  if s:Windows()
    return &restorescreen
  else
    return !empty(&t_ti) || !empty(&t_te)
  endif
endfunction

function! s:cat(filename) abort
  if s:Windows()
    return system('type '.a:filename)
  else
    return system('cat '.a:filename)
  endif
endfunction
