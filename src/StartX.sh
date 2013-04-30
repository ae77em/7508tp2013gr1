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
   
   if [ `ps | grep $comandoAEjecutar | wc -l` -ne 0 ]
   then
      return 1
   fi
   
   return `$comandoAEjecutar &`
}
