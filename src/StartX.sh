#! /bin/bash

# Parametro 1: comando invocante
# Parametro 2: comando a ejecutar
function StartX {

   source GlogX.sh; 

   if [ $# -eq 3 ]
   then
      return 1
   fi
   
   comando=$1
   comandoAEjecutar=$2

   nombreComando=$( echo "$comandoAEjecutar" | cut -f1 -d" ")
      
   var=`ps -fea | grep -v "grep" | grep -v "StartX" | grep "$nombreComando" | wc -l`
   if [ "$var" -ne 0 ]
   then
      GlogX "$comando.sh" "SE" "StartX.sh encuentra un proceso $nombreComando en ejecución" "$comando"
      return 1
   fi

   GlogX "$comando.sh" "I" "StartX.sh invoca a $nombreComando" "$comando"

   if [ $nombreComando == "DetectaX.sh" ]; then
	   $comandoAEjecutar &	
   else
	   $comandoAEjecutar
   fi
 
   return $!
   
}

StartX "$1" "$2"

