#!/bin/bash
#setup=$(dialog \
#  --stdout \
#  --title 'Setup' \
#  --inputbox 'Se voce tem usuario ssh, digite: [padrao]' \
#  0 0)
  
##
# File_GetSize counts the size of a file or directory
#
# @param file Is the input file or directory
#
File_GetSize()
{
  if [[ -f $1 ]] || [[ -d $1 ]]
  then
  
    du -c $1 | egrep total | sed 's/total//g' | egrep -o '[0-9]*'
    
  else
  
    echo 0
    
  fi
}

##
# File_GetLines echoes the number of lines of a file
#
# @param file Is the input file
#
File_GetLines()
{

  if ! [ -f $1 ]
  then
    Dialog_Alert "Could not count from inexistent file"
    exit 1
  fi

  echo $(wc -l $1 | grep -o "[[:digit:]][[:digit:]]*" 2>/dev/null)
}

##
# String_GetLines echoes the number of lines of a string
#
# @param string Is the input string
#
String_GetLines()
{
  echo $(echo $1 | sed -n '$=' 2>/dev/null)
}

##
# Dialog_Alert pops an alert with string or file contents
# 
# @param content Can be string or file
#
Dialog_Alert()
{
  [[ $1 == "" ]] && exit 1

  content=$1
  lines=$(String_GetLines $1)

  [ -f $content ] && content="$(cat $content)" && lines=$(File_GetLines $conent)

  total=$(( $lines + 10 ))
  
  dialog --msgbox $1 $total 80
}

##
# Dialog_Gauge opens a gauge
#
# @param cpid       Is the pid
# @param title      Is the title
# @param content    Is the gauge content
# @param count_expr Is a command to execute
# @param total      Is the total
#
Dialog_Gauge()
{
  cpid=$1
  title=$2
  content=$3
  count_expr=$4
  total=$5
  
  if [[ $cpid == "" ]] || [[ $count_expr == "" ]] || [[ $total == "" ]]
  then
  
    dialog --msgbox 'Nothing to do without a cpid, count_expr or total.' 8 40
  
  else    
  
    trap "kill $cpid" 2 15
    (
      while kill -0 $cpid &>/dev/null
      do
        count=$(eval $count_expr)
        echo $((count*100/total))
        sleep 0.1
      done
      
      echo 100
    )  | dialog --title $title --gauge $content 8 40 0
    
  fi
}


##
# Dialog_CopyTo copies files with force mode to another place
#
# @param sourceFile      Is the source file or directory
# @param destinationfile Is the destination file or directory
#
Dialog_CopyTo()
{
  if [[ -d $1 ]] && [[ -d $2 ]]
  then
  
    total=$(File_GetSize $1)
    cp -rf $1 $2 &
    cpid=$!
    title="Coping..."
    content="Coping $1 to $2"
    count_expr="File_GetSize $2"

    Dialog_Gauge $cpid $title $content $count_expr $total
    
  else
  
    dialog --msgbox  'Nothing to copy' 8 40
    
  fi
}

##
# Dialog_MoveTo moves files with force mode to another place
#
# @param sourceFile      Is the source file or directory
# @param destinationfile Is the destination file or directory
#
Dialog_MoveTo()
{
  if [[ -d $1 ]] && [[ -d $2 ]]
  then
  
    total=$(File_GetSize $1)
    mv -rf $1 $2 &
    cpid=$!
    title="Moving..."
    content="Moving $1 to $2"
    count_expr="File_GetSize $2"

    Dialog_Gauge $cpid $title $content $count_expr $total
    
  else
  
    dialog --msgbox  'Nothing to move' 8 40
    
  fi
}

##
# Dialog_CompactTo compacts files on tar.gz
#
# @param sourceFile      Is the source file or directory
# @param destinationfile Is the destination file or directory
#
Dialog_CompactTo()
{
  if [[ -f $1 ]] || [[ -d $1 ]] && [[ $2 != "" ]]
  then
  
    total=$(File_GetSize $1)
    file="$2.tar.gz"
    tar czvf $file $1
    cpid=$!
    title="Compacting..."
    content="Compacting $1 to $file"
    count_expr="File_GetSize $file"

    Dialog_Gauge $cpid $title $content $count_expr $total
    
  else
  
    dialog --msgbox  'Nothing to compact' 8 40
    
  fi
}

##
# Dialog_ConvertToBase64 converts files on base64
#
# @param sourceFile      Is the source file or directory
# @param destinationfile Is the destination file or directory
#
Dialog_ConvertToBase64()
{
  if [[ -f $1 ]] || [[ -d $1 ]] && [[ $2 != "" ]]
  then
  
    total=$(File_GetSize $1)
    file="$2.base64"
    base64 $1 > $file
    cpid=$!
    title="Converting..."
    content="Converting base64 $1 to $file"
    count_expr="File_GetSize $file"

    Dialog_Gauge $cpid $title $content $count_expr $total
    
  else
  
    dialog --msgbox 'Nothing to convert' 8 40
    
  fi
}

Dialog_GitCloneTo()
{
  repo=$1
  cloneTo=$2
  title="Cloning..."

  if [[ $(echo $repo | grep ".git$" 2>/dev/null) ]] && [[ $cloneTo != "" ]]
  then
    git clone $repo > /tmp/dialog-gitcloneto.log&
    cpid=$!
    content=$(tail -f /tmp/dialog-gitcloneto.log)
    count_expr="0"
    total="100"

    Dialog_Gauge $cpid $title $content $count_expr $total
  else
  
    dialog --msgbox 'Nothing to clone' 8 40
    
  fi
}

