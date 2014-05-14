#!/bin/bash -e
set -o nounset
path=${1:-$PWD}
#trace echo "[path] $path"
pushd "$path" >/dev/null


dereference(){
print_color 31 1>&2 "dereference got $1"
 local    var_content_may_not_exist=$1
    #$1"
  local   pointer='var_content_may_not_exist'
    local str=$( eval  "echo  \$$pointer")
    notify-send "content" "$str"
    echo "$str"
}
trace(){
    echo "$@" >>/tmp/trace
}
ensure_tag_exist(){
    local tag_name="$1"
    echo "[tag_name] $tag_name"
    #    echo "[handler] $handler"
    local str_res="$( dereference $tag_name)"
#$tag_name`
echo "[$tag_name ] content: $str_res"
    if [  -n "$str_res" ];then
        print_color 32 "[tag exist] $tag_name"
        #        eval " echo \"[tag content] \$$tag_name\""
    else
        print_color 31 "tag not exist $tag_name"
        update_clipboard "vi $file_meta"
        exit 0
    fi
}

menu_present(){
    local text="${text:-text1}"
    local column_name="${column:-column1}"
    if [ -s $file_list ];then
        trace  "[ok] file exist: " "$file_list"
        local cmd="cat $file_list | zenity --list --text=\"$text\" --column=\"$column_name\" --print-column=1 $ZENITY"
        trace "[cmd] $cmd"
        local str=$( eval "$cmd" )
        echo "$str"
    else
        echo "[error] file-list : " "$file_list"
        echo file without content
    fi
}

remove_trailing(){
    #remove trailing
    local str="$@"
    echo "$str" | sed -e 's/^ *//g' -e 's/ *$//g'
}

set_env(){
    export    file_self=${BASH_SOURCE:-$0}
    export     dir_self=`where_am_i $file_self`
    local filename=`basename $file_self`
    export     file_menuer=$dir_self/$filename
    #export     dir_self1=`dirname $file_self`
    trace    echo "[dir_self] $dir_self"
    trace   echo "[file_menuer] $file_menuer"
    #    echo "[dir_self1] $dir_self1"
    export ZENITY="--height=400"
    export GXMESSAGE="-ontop -sticky -wrap -timeout 10"

}   
sourcing(){
    #source $dir_self/CFG/helper.cfg
    #source $dir_self/CFG/extract.cfg
    echo 
}
#exporting(){
#for  the next generations:
# export   dir_cfg=$dir_self/CFG
#   file_helper=$dir_cfg/helper.cfg
#   file_extract=$dir_cfg/extract.cfg
#}

parse_meta(){
    clear
    local    file_meta=$1
    local item1=''
    local item2=''
    if [ -f $file_meta ];then
        while read line;do
            item1=`echo $line | cut -d':' -f1` 
            item2=`echo $line | cut -d':' -f2` 
            item2=$( remove_trailing "$item2" )
            if [ -n "$item1" ] && [ -n "$item2" ];then
                cmd="export ${item1}=\"${item2}\""
                print_color 35   "[parse_meta] $cmd"
                eval "$cmd"
            fi
        done <$file_meta
    fi

    ensure_tag_exist hanlder
    ensure_tag_exist listing
}


update_clipboard(){
    echo updating_clipboard
    echo "$@" | xsel --clipboard
}
ensure_dir_exist(){
    local dir=$1
    if [ -d "$dir" ];then
        trace         print_color 32 "[dir exist] $dir"
        return 0
    else
        print_color 31 "dir not exist: $dir"
        return 1
    fi

}
ensure_file_exist(){
    local file=$1
    if [ -f $file ];then
        trace    print_color 32 "[file exist] $file"
    else
        print_color 31 "[Error] file not exist: $file"
        update_clipboard "vi $file"
        exit 1 
    fi
}
step(){
    local str="$1"
    echo >&2   "[step] $str"
    eval "$str"
}

steps(){
    #step    set_env
    set_env
    local     file_meta=$path/meta.txt
    local     file_list=$path/list.txt
    local dir_next=$path/BANK
    print_color 32  step1
    ensure_file_exist $file_meta
    ensure_dir_exist $dir_next
    print_color 32 step2
    parse_meta $file_meta
    if [ ! -f $file_list ];then
        eval "$listing"
    fi
    ensure_file_exist $file_list
    print_color 32 step3
    pick_from_menu
}
handle_dir(){
    local dir=$1
    extract_next_dir "$dir"
}
handle_file(){
    local file=$1
    $handler "$file"
}


handle_the_truth(){
    local str="$1"
    local item=$path/BANK/$str
    print_color 31 "[item] $item"
    if  [ -f $item ];then
        handle_file "$item"
    elif [ -d $item ];then
        handle_dir "$item"
    else
        print_color 31 "[Error] not a file, not a dir"
    fi
}

pick_from_menu(){
    print_color 34 "[Pick From Memu]"
    local str_result=$(menu_present)
    if [ -n "$str_result" ];then
        handle_the_truth "$str_result"
    else
        print_color "[ ESCAPING]"
        return 0
    fi
}
extract_next_dir(){
    #clear
    local dir=$1
    print_color 35 "[Enter Next Directory]"
    update_clipboard "vi $dir"
    print_color 33  "$dir"
    pushd "$dir" >/dev/null
    local cmd="$file_menuer $dir"
    print_color 36 "[cmd] $cmd"
    print_color 36 "[pwd] $PWD"
    eval  "$cmd"
    popd >/dev/null
}

set_env
sourcing
#exporting
steps
popd >/dev/null


