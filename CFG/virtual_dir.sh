set_env(){
    #update to a full path
    export dir_self=`pwd`
    print_color  33 "[ROBOT] I am in directory: " 
    pv1 "$dir_self"
}

step(){
    local str="$1"
    echo >&2   "[step] $str"
    eval "$str"
}

steps(){
    step    set_env
    local     file_meta=$dir_self/meta.txt
    local item1=''
    local item2=''
    if [ -f $file_meta ];then
        while read line;do
            item1=`cat $line | cut -d':' -f1` 
            item2=`cat $line | cut -d':' -f2` 
            if [ -n "$item1" ] && [ -n "$item2" ];then
            cmd="export ${item1}=${item2}"
            echo "[cmd] $cmd"
            eval "$cmd"
        fi
        done < $file_meta

        if [ -d $dir_self/BANK ];then
            step    menu_generate_file_list
            local str_choose=$(    step    menu_present )
            print_color 32 "[str_choose] $str_choose"
            sleep 1
            dir_next="$dir_self/BANK/$str_choose"
            extract_next $dir_next
        else
            print_color 31 "[BANK] dir not found --> robot understand that this directory hasn't got another menu"
        fi
    else
        gvim $file_meta
    fi

}


cmd=steps
eval "$cmd"
#popd >/dev/null
