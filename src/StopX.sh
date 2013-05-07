#! /bin/bash

# Parametro: id del proceso a finalizar
function StopX {
   if [ $_ -eq 2 ]
   then
      return 1
   fi
   
   proceso=$1
   
   # Chequeo que el proceso exista
   if [ `ps | awk '{ print $1 }' | grep $proceso | wc -l` -eq 0 ]
   then
      return 1
   fi
   
   kill $proceso
   
   return 0
}

StopX $1
