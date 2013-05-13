#! /bin/bash

source GlogX.sh; 

CONFDIR=../conf

function validarInicio() {
   variables=(GRUPO BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE DATASIZE)
  
   for var in ${variables[*]}
   do
      res=`env | grep $var | cut -d"=" -f 2`
      if [ -z $res ]; then
         return 1
      fi
   done	

   return 0;
}

# Parametro 1: comando invocante
# Parametro 2: comando a ejecutar
function StartX {    
   validarInicio
   validacion1=$?

   if [ $# -eq 3 ]
   then
      return 1
   fi
   
   comando=$1
   comandoAEjecutar=$2

   nombreComando=$( echo "$comandoAEjecutar" | cut -f1 -d" ")

   if [ $validacion1 -eq 1 ] 
   then
      echo "Ambiente no inicializado. No se ejecutará el $nombreComando"
      exit 0
   fi
      
   var=`ps -fea | grep -v "grep" | grep -v "StartX" | grep "$nombreComando" | wc -l`
   if [ "$var" -ne 0 ]
   then
      GlogX "$comando" "SE" "StartX.sh encuentra un proceso $nombreComando en ejecución" "$comando"
      return 1
   fi

   GlogX "$comando" "I" "StartX.sh invoca a $nombreComando" "$comando"

   if [ $nombreComando == "DetectaX.sh" ]; then
	   $comandoAEjecutar &
   else
	   $comandoAEjecutar
   fi
 
   return $!
   
}

StartX "$1" "$2"

