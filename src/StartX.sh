#! /bin/bash

# Parametro 1: comando invocante
# Parametro 2: comando a ejecutar
function StartX {

   if [ $# -eq 3 ]
   then
      return 1
   fi
   
   comando=$1
   comandoAEjecutar=$2
   
   nombreComando=$( echo "$comandoAEjecutar" | cut -f1 -d" ")	
   
   var=`ps -fea | grep -v "grep" | grep "$nombreComando" | wc -l`

   if [ "$var" -ne 0 ]
   then
      return 1
   fi

   $comandoAEjecutar &
   return $!	

}

StartX $1 $2 
