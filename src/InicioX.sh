#!/bin/bash

#===========================================================
# ARCHIVO: InicioX.sh
#
# FIRMA: . InicioX.sh
#
# DESCRIPCION: Comando encargado de inicializar el ambiente para correr CONTROLX
# \
# AUTOR: De Zan, Ignacio. 
# PADRON: 91525
#
#===========================================================

# Llama al log para grabar
# $2 = mensaje $1 = tipo (error, informativo, warning, etc)

function grabarLog {

   source GlogX.sh; GlogX "InicioX.sh" "$1" "$2" "InicioX"

}

# Chequea que existan los comandos en la carpeta BINDIR, 
# y tengan los permisos de ejecucion seteados,sino los setea.

function chequearComandos {

 for i in ${comandos[*]}
   do
     if [ -f $BINDIR/$i ]; then
          echo -e "El comando $i existe\n"
 
          if [ -x $BINDIR/$i ]; then 
            echo -e "y tiene permisos de ejecucion\n"
          else 
            chmod 777 $BINDIR/$i
            echo -e "`ls -l $BINDIR/$i` \n"
          fi
         
     else
        echo -e "El comando $i no existe\n" 
     fi
   done  
}

# Chequea que existan los maestros en la carpeta MAEDIR, 
# y tengan los permisos de lectura seteados,sino los setea.

function chequearMaestros {

 for i in PPI.mae p-s.mae
   do
     if [ -f $MAEDIR/$i ]; then
          echo -e "El archivo maestro $i existe\n"
 
          if [ -r $MAEDIR/$i ] &&  ! [ -w $MAEDIR/$i ]; then 
            echo -e "y tiene permisos de lectura, pero no escritura\n"
          else 
            chmod 444 $MAEDIR/$i
            echo -e `ls -l $MAEDIR/$i`
          fi
         
     else
        echo -e "El archivo maestro $i no existe\n" 
     fi
   done  

}

# Chequea que existan las tablas en la carpeta CONFDIR, 
# y tengan los permisos de lectura seteados,sino los setea.

function chequearTablas {

 for i in T2.tab T1.tab
   do
     if [ -f $CONFDIR/$i ]; then
          echo -e "El archivo maestro $i existe\n"
 
          if [ -r $CONFDIR/$i ] &&  ! [ -w $CONFDIR/$i ]; then 
            echo -e "y tiene permisos de lectura, pero no escritura\n"
          else 
            chmod 444 $CONFDIR/$i
            echo -e `ls -l $CONFDIR/$i`
          fi
         
     else
        echo -e "El archivo maestro $i no existe\n"
     fi
   done  

}

# Lee las variables de Config del archivo InstalX.conf

function setVariablesDeConfiguracion {
    
    export $2=`grep "$2" "$1" | cut -d"=" -f 2`
}

#Verifica que las variables de ambiente este seteadas

function chequearVarAmbiente {

   for var in ${variables[*]}
     do
       res=`env | grep $var | cut -d"=" -f 2`

       if [ -z "$res" ]; then

         echo -e "Falta la variable de ambiente $var, agregando...\n"

         setVariablesDeConfiguracion $CONFDIR/$confFile $var

         echo -e "Variable $var ahora esta agregada\n"

       else
         echo -e "La variable de ambiente $var=$res existe\n"
       fi      
   done
}

# Chequea que la carpeta donde se encuentran los comandos, este incluido en la variable PATH,
# para su correcta ejecucion, sino lo setea

function chequearPaths {
   
   ejec=`echo $PATH | grep $BINDIR`

  if [ -z "$ejec" ]; then

    echo -e "No esta el path de ejecutables, agregando...\n"
    
    export PATH=$PATH:$BINDIR
    
    echo -e "Agregado\n"

  else

    echo -e "El path de ejecutables esta seteado\n"
    
  fi 
}

#Valida que lo ingresado sea un valor numerico entero y mayor a cero
function validarNumerico {

  res=`echo "$1" | grep "[^0-9]"`
  if [ "$1" == "$res" ]; then
     echo "ERROR -  \"$1\" tiene que ser un número entero."
     #grabarLog "E" "\"$1\" tiene que ser un número entero."
     cond="error"
  fi
  if [ "$1" == "0" ];then
     echo "ERROR - el valor ingresado no puede ser cero."
     #grabarLog "E" "El valor ingresado no puede ser cero."
     cond="error"
  fi

  unset res
}


# Funcion que pide por teclado la cantidad de loops que quiere que haga el DetectaX

function ingresarCantLoop {
 
 cond="error"
 while [ $cond == "error" ]
 do
     echo "Cantidad de ciclos de DetectaX ? (100 ciclos)"
     read CANLOOP
     cond="ok"
     validarNumerico $CANLOOP

 done
 unset cond

}

# Funcion que pide por teclado el tiempo de espera que quiere que tenga el DetectaX

function ingresartEspera {
 
 cond="error"
 while [ $cond == "error" ]
   do
     echo "Tiempo de espera entre ciclos? (1 minuto)"
     read TESPERA
     cond="ok"
     validarNumerico $TESPERA

 done
 unset cond

}

# Chequea si el proceso DetectaX ya esta corriendo

function chequearDetectaX {

 resultado=`ps -A | grep "DetectaX.sh"`

 if [ -z "$resultado" ]; then
   return 0
 else
   return 1
 fi
}

# Pregunta si se desea iniciar el comando DetectaX, y actua segun la respuesta. 

function lanzarDetectaX {
 
  echo "Desea efectuar la activación de DetectaX? [s/n]"
  read resp

  while [ "$resp" != "s" ]
   do
     if [ "$resp" == "n" ]; then
       return 1
     fi

     echo "Ingrese una respuesta valida"
     read resp

   done
  return 0
}

function mostrarMensajeInstalacionFinalizada {

	dirconf=`ls $CONFDIR`
	dirbin=`ls $BINDIR`
	dirmae=`ls $MAEDIR`

        #procssid=`ps | grep 'DetectaX' | cut -d" " -f2`

	mensaje="
TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 01.

Librería del sistema: $CONFDIR

Archivos: 
$dirconf


Ejecutables: $BINDIR

Archivos: 
$dirbin


Archivos maestros: $MAEDIR

Archivos: 
$dirmae


Directorio de arribo de archivos externos: $ARRIDIR

Archivos externos aceptados: $ACEPDIR

Archivos externos rechazados: $RECHDIR

Archivos procesados: $PROCDIR

Reportes de salida: $REPODIR

Logs de auditoría del Sistema: $LOGDIR/InicioX$LOGEXT

Estado del Sistema: INICIALIZADO

Demonio corriendo bajo el no.: <$procssid> "

	echo "$mensaje"
	grabarLog "I" "$mensaje"

}


#Funcion principal

function main {
  
  variables=(GRUPO BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE DATASIZE)
 
  comandos=(InicioX.sh DetectaX.sh Interprete.sh ReporteX.pl MoverX.sh StartX.sh StopX.sh GlogX.sh VlogX.sh)
  CONFDIR=../conf

  confFile=InstalarX.conf
  
  chequearVarAmbiente
  
  chequearPaths
  chequearComandos
  
  grabarLog "I" "Inicio de ejecucion"

  chequearMaestros
  chequearTablas
 
  ingresarCantLoop
  ingresartEspera
 
 lanzarDetectaX
    
  if [ $? == 1 ]; then

     msj="Usted ha elegido no arrancar DetectaX, para hacerlo manualmente debe hacerlo de la siguiente manera: \n
             
          Uso: DetectaX.sh CANTLOOP TESPERA \n
             
          CANTLOOP es la cantidad de ciclos (debe ser un numero entero positivo) que quiere que ejecute el demonio, \n
          y TESPERA es el tiempo (mayor a 1 minuto) de espera entre cada ciclo.\n"
      
     echo -e $msj
     grabarLog "I" "$msj" 
   
   else
        #source "$BINDIR/StartX.sh";
	StartX.sh "InicioX" "DetectaX.sh $CANLOOP $TESPERA"
	procssid=$(ps | grep "DetectaX" | cut -f1 -d' ')
   fi
   
   mostrarMensajeInstalacionFinalizada
}

main
