#!/bin/bash

#===========================================================
# ARCHIVO: InicioX.sh
#
# FIRMA: TODO:HACER!
#
# DESCRIPCION: TODO:HACER!
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
          echo "El comando $i existe"
 
          if [ -x $BINDIR/$i ]; then 
            echo "y tiene permisos de ejecucion"
          else 
            chmod 777 $BINDIR/$i
            echo `ls -l $BINDIR/$i`
          fi
         
     else
        echo "El comando $i no existe" 
     fi
   done  
}

# Chequea que existan los maestros en la carpeta MAEDIR, 
# y tengan los permisos de lectura seteados,sino los setea.

function chequearMaestros {

 for i in PPI.mae p-s.mae
   do
     if [ -f $MAEDIR/$i ]; then
          echo "El archivo maestro $i existe"
 
          if [ -r $MAEDIR/$i ] &&  ! [ -w $MAEDIR/$i ]; then 
            echo "y tiene permisos de lectura, pero no escritura"
          else 
            chmod 444 $MAEDIR/$i
            echo `ls -l $MAEDIR/$i`
          fi
         
     else
        echo "El archivo maestro $i no existe" 
     fi
   done  

}

# Chequea que existan las tablas en la carpeta CONFDIR, 
# y tengan los permisos de lectura seteados,sino los setea.

function chequearTablas {

 for i in T2.tab T1.tab
   do
     if [ -f $CONFDIR/$i ]; then
          echo "El archivo maestro $i existe"
 
          if [ -r $CONFDIR/$i ] &&  ! [ -w $CONFDIR/$i ]; then 
            echo "y tiene permisos de lectura, pero no escritura"
          else 
            chmod 444 $CONFDIR/$i
            echo `ls -l $CONFDIR/$i`
          fi
         
     else
        echo "El archivo maestro $i no existe"
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

         echo "Falta la variable de ambiente $var, agregando..."

         setVariablesDeConfiguracion $CONFDIR/$confFile $var

         echo "Variable $var ahora esta agregada"

       else
         echo "La variable de ambiente $var=$res existe"
       fi      
   done
}

# Chequea que la carpeta donde se encuentran los comandos, este incluido en la variable PATH,
# para su correcta ejecucion, sino lo setea

function chequearPaths {
   
   ejec=`echo $PATH | grep $BINDIR`

  if [ -z "$ejec" ]; then

    echo "No esta el path de ejecutables, agregando..."
    
    export PATH=$PATH:$BINDIR
    
    echo "Agregado"

  else

    echo "El path de ejecutables esta seteado"
    
  fi 
}

# Funcion que pide por teclado la cantidad de loops que quiere que haga el DetectaX

function ingresarCantLoop {
 
 echo "Cantidad de ciclos de DetectaX ? (100 ciclos)"
 read CANLOOP

 while [ $CANLOOP -le 0 ]
   do
     echo "Por favor ingrese un numero positivo"
     read CANLOOP  
   done
}

# Funcion que pide por teclado el tiempo de espera que quiere que tenga el DetectaX

function ingresartEspera {
 
 echo "Tiempo de espera entre ciclos? (1 minuto)"
 read TESPERA

 while [ $TESPERA -lt 1 ]
   do
     echo "Por favor ingrese un numero mayor a un minuto"
     read TESPERA  
   done
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
        procssid=`ps | grep 'DetectaX' | cut -d" " -f2`

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

Demonio corriendo bajo el no.: <$procssid>
	"

	echo "$mensaje"
	grabarLog "INFORMATIVO" "$mensaje"

}


#Funcion principal

function main {
  
  variables=(GRUPO BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE DATASIZE)
 
  comandos=(InicioX.sh DetectaX.sh Interprete.sh ReporteX.pl MoverX.sh StartX.sh StopX.sh GlogX.sh VlogX.sh)

  CONFDIR=$GRUPO/conf

  confFile=InstalarX.conf
  
  chequearVarAmbiente
  
  chequearPaths
  chequearComandos
  
  grabarLog "INFORMATIVO" "Inicio de ejecucion"

  chequearMaestros
  chequearTablas
 
  ingresarCantLoop
  ingresartEspera
    
  lanzarDetectaX
    
  if [ $? == 1 ]; then

     msj="Usted ha elegido no arrancar DetectaX, para hacerlo manualmente debe hacerlo de la siguiente manera: 
             
              Uso: DetectaX.sh CANTLOOP TESPERA
             
              CANTLOOP es la cantidad de ciclos (debe ser un numero entero positivo) que quiere que ejecute el demonio,
              y TESPERA es el tiempo (mayor a 1 minuto) de espera entre cada ciclo."
      
     echo $msj
     grabarLog "INFORMATIVO" "$msj" 

   # else
        # va con StarX.sh 
   # 	chequearDetectaX
   #      if [ $? == 1 ]; then
   #         echo "El proceso DetectaX ya se esta ejecutando"
   #      else
   #         echo "El proceso DetectaX no se esta ejecutando"        
   #         ./DetectaX.sh "$CANLOOP" "$TESPERA"     # Lanza el demonio (tengo que ejecutarlo con & ???)
   #      fi
   

   fi

   mostrarMensajeInstalacionFinalizada
}

main
