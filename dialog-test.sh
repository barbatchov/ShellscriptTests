#!/bin/bash
setup=$(dialog \
  --stdout \
  --title 'Setup' \
  --inputbox 'Se voce tem usuario ssh, digite: [padrao]' \
  0 0)

File_GetSize()
{
  if [[ -f $1 ]] || [[ -d $1 ]]
  then
    du -c $1 | egrep total | sed 's/total//g' | egrep -o '[0-9]*'
  fi
}

Dialog_CopyTo()
{
  if [[ -d $1 ]] && [[ -d $2 ]]
  then
    total=$(File_GetSize $1)
    cp -r $1 $2
    cpid=$!
    trap "kill $cpid" 2 15
    
    (
      while running $cpid; do
        copied=$(File_GetSize $1)
        percentage=$((copied*100/total))
        echo $percentage
        sleep 1
      done
      
      echo 100
    ) | dialog --title='Coping...' --gauge "Coping $1 to $2" 8 40 0
  else
    dialog --msgbox  'Nothing to copy' 8 40
  fi
}

Dialog_MoveTo()
{
  if [[ -d $1 ]] && [[ -d $2 ]]
  then
    total=$(File_GetSize $1)
    mv -r $1 $2
    cpid=$!
    trap "kill $cpid" 2 15
    
    (
      while running $cpid; do
        copied=$(File_GetSize $1)
        percentage=$((copied*100/total))
        echo $percentage
        sleep 1
      done
      
      echo 100
    ) | dialog --title='Moving...' --gauge "Coping $1 to $2" 8 40 0
  else
    dialog --msgbox  'Nothing to move' 8 40
  fi
}

Dialog_CompactTo()
{
  if [[ -f $1 ]] || [[ -d $1 ]] && [[ $2 != "" ]]
  then
    total=$(File_GetSize $1)
    file="$2.tar.gz"
    tar czvf $file $1
    cpid=$!
    trap "kill $cpid" 2 15
    
    (
      while running $cpid; do
        copied=$(File_GetSize $file)
        percentage=$((copied*100/total))
        echo $percentage
        sleep 1
      done
      
      echo 100
    ) | dialog --title='Compacting...' --gauge "Compacting $1 to $file" 8 40 0
  else
    dialog --msgbox  'Nothing to compact' 8 40
  fi
}

Dialog_ConvertToBase64()
{
  if [[ -f $1 ]] || [[ -d $1 ]] && [[ $2 != "" ]]
  then
    total=$(File_GetSize $1)
    file="$2.base64"
    base64 $1 > $file
    cpid=$!
    trap "kill $cpid" 2 15
    
    (
      while running $cpid; do
        copied=$(File_GetSize $file)
        percentage=$((copied*100/total))
        echo $percentage
        sleep 1
      done
      
      echo 100
    ) | dialog --title='Converting...' --gauge "Converting base64 $1 to $file" 8 40 0
  else
    dialog --msgbox 'Nothing to convert' 8 40
  fi
}
