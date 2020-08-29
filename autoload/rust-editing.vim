function! rust_editing#delete_previous_ampersand() " {{{
    let save_cursor = getcurpos()
    execute "normal! F&x"
    call setpos('.', save_cursor)
    normal! h
endfunction 
"}}}

function! rust_editing#add_ampersand_before() " {{{
    let save_cursor = getcurpos()
    execute "normal! viw\<Esc>`<i&\<Esc>"
    call setpos('.', save_cursor)
    normal! l
endfunction 
"}}}

function! rust_editing#delete_type_annotation() " {{{
    let save_cursor = getcurpos()
    normal! ^f:dt=
    execute "normal! i \<Esc>"
    call setpos('.', save_cursor)
endfunction 
"}}}

function! rust_editing#add_type_annotation() " {{{
    let save_cursor = getcurpos()
    normal! ^f=
    execute "normal! i: \<Esc>"
    startinsert
endfunction " }}}

function! rust_editing#toggle_mut() " {{{
    let save_cursor = getcurpos()
    normal! "zyiw
    if @z == "mut"
        normal! daw
        return
    elseif @z == "let"
        normal! w"zyiw
        if @z == "mut"
            normal! daw
        else
            execute "normal! imut \<Esc>"
        endif
        call setpos('.', save_cursor)
        return
    endif
    call setpos('.', save_cursor)

    " this can fail if at start of line
    execute "normal! viw\<Esc>`<b\"zyiw"
    if @z == "mut"
        normal! daw
        call setpos('.', save_cursor)
        normal! hhhh
    else
        call setpos('.', save_cursor)
        execute "normal! viw\<Esc>`<imut \<Esc>"
        call setpos('.', save_cursor)
        normal! llll
    endif
endfunction " }}}

function! rust_editing#extract_variable() " {{{
    let save_cursor = getcurpos()
    normal! gv"+y
    let expr = @+
    let var_name = input("new variable name: ")
    execute "normal! gvc" . var_name . "\<Esc>"
    let new_let_command = 'let ' . var_name . ' = ' . expr . ';'
    call setreg("+", new_let_command, "V")
    let @/ = expr
    let @v = var_name
    call setpos('.', save_cursor)
    set hlsearch
endfunction " }}}

function! rust_editing#inline_variable() " {{{
    normal! ^w"zyiw
    if @z == "mut"
        normal! w"zyiw
    endif
    let @/ = @z

    " copy expression in + register
    execute "normal! f=w\"+y/\\V;\<CR>"

    " remove initialization
    execute "normal! 0\"_d/\\V;\<CR>\"_dd"
endfunction " }}}

function! rust_editing#generate_struct() " {{{
    let save_cursor = getcurpos()
    call LanguageClient#textDocument_definition()
    " redrawing seems necessary. i don't know why.
    redraw
    sleep 50m
    normal! f{"zyi{
    call setpos('.', save_cursor)
    redraw
    sleep 50m
    execute "normal! A {\<CR>}\<Esc>k"
    normal! "zp
    call setpos('.', save_cursor)
    normal! '[mx']my
    :'x,'y global /\v.*/ execute "normal! $i \<Esc>"
    :'x,'y global /\v^\s*pub.*/ normal! ^daw
    call setpos('.', save_cursor)
    normal! +
endfunction " }}}

" We usually don't have the cursor on the definition of the enum.
" This is unlike for structs, so only store the block in the default register.
function! rust_editing#generate_enum() " {{{
    let save_cursor = getcurpos()
    normal! "yyiw
    let @y = @y . '::'
    call LanguageClient#textDocument_definition()
    " redrawing seems necessary. i don't know why.
    redraw
    sleep 50m
    normal! f{"zyi{
    call setpos('.', save_cursor)
    redraw
    sleep 50m
    execute "normal! A\<CR>{\<CR>}\<Esc>k"
    normal! "zp
    call setpos('.', save_cursor)
    normal! '[mx']my
    :'x,'y global /\v.*/ execute 'normal! f,x^"yP' . "A => todo!() ,\<Esc>"
    execute "normal! 'xkV'yj\"+d"
    call setpos('.', save_cursor)
endfunction " }}}

" Rust doesn't support named arguments, but we can at least
" copy the function definition
function! rust_editing#generate_function_call() " {{{
    let save_cursor = getcurpos()
    call LanguageClient#textDocument_definition()
    " redrawing seems necessary. i don't know why.
    redraw
    sleep 50m
    execute 'normal! ^v/\V{' . "\<CR>" . '"zy'
    call setpos('.', save_cursor)
    redraw
    sleep 50m
    execute "normal! O\<Esc>"
    normal! "zp
    :'[,'] global /\v.*/ execute "normal! I// \<Esc>"
    normal! +$
endfunction " }}}
