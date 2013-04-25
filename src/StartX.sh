#! /bin/bash

# Parametro 1: comando invocante
# Parametro 1: comando a ejecutar
function StartX {
   if [ $_ -eq 3 ]
   then
      return 1
   fi
   
   comando=$1
   comandoAEjecutar=$2
   
   if [ `ps | grep $comandoAEjecutar | wc -l` -ne 0 ]
   then
      return 1
   fi
   
   return `$comandoAEjecutar &`
}
