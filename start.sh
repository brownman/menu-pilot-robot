#!/bin/bash -e
#depend_package: zenity
dir_self=`dirname $0`
source $dir_self/CFG/helper.cfg
source $dir_self/CFG/extract.cfg

#for  the next generations:
dir_cfg=$dir_self/CFG
file_virtual_dir=$dir_cfg/virtual_dir.sh
file_helper=$dir_cfg/helper.cfg
file_extract=$dir_cfg/extract.cfg
echo "[FILE_EXTRACT] $file_extract"
extract_next $dir_self
