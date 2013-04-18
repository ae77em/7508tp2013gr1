#!/bin/bash

#===========================================================
# ARCHIVO: InstalarX.sh
#
# FIRMA: TODO:HACER!
#
# DESCRIPCION: TODO:HACER!
#
# AUTOR: Bayetto, Ignacio Javier. 
# PADRON: 88896
#
#===========================================================

#Verifica la existencia de directorio de arribos definido en el archivo de configuracion 
function chequearARRIDIR {

	if [ -z "$ARRIDIR" ]; then
		ARRIDIR="$grupo/arribos"
		arribos=1
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$ARRIDIR" ]; then
			arribos=1
			cantErrores=$[ $cantErrores + 1]
		fi
	fi

}

#Verifica la existencia de directorio de archivos ejecutables definido en el archivo de configuracion
function chequearBINDIR {

	if [ -z "$BINDIR" ]; then
		BINDIR="$grupo/bin"
		cantErrores=$[ $cantErrores + 1]
		ejecutables=0
	else
		if ! [ -d "$BINDIR" ]; then
			cantErrores=$[ $cantErrores + 1]
			ejecutables=0
		fi
	fi

}

#Verifica cuales son los componentes ya instalados
function chequearComponentesInstalados {
	
	#chequearDATASIZE
	chequearBINDIR
	chequearARRIDIR
	chequearACEPDIR
	chequearRECHDIR
	chequearPROCDIR
	chequearMAEDIR
	chequearLOGDIR
	chequearLOGEXT
	#chequearLOGSIZE

}

#Muestra mensaje inicio instalacion
function mostrarMensajeInicioInstalacion {
	echo '
************************************************************************
* TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 1
* A T E N C I O N: Al instalar TP SO7508 Primer Cuatrimestre 2013 UD.
* expresa aceptar los términos y condiciones del "ACUERDO DE LICENCIA DE
* SOFTWARE" incluído en este paquete.
************************************************************************
'
}

#Comienza la instalcion
function instalar {

	mostrarMensajeInicioInstalacion
	#TODO: CONTINUA!
}

#Inicializa las variables del directorio del archivo de configuracion
function inicializarVariablesDefault {

	GRUPO=$grupo
	CONFDIR=$GRUPO/conf
	#DATASIZE=100
	BINDIR=$GRUPO/bin
	ARRIDIR=$GRUPO/arribos
	ACEPDIR=$GRUPO/aceptados
	RECHDIR=$GRUPO/rechazados
	PROCDIR=$GRUPO/procesados
	MAEDIR=$GRUPO/mae
	LOGDIR=$GRUPO/log
	LOGEXT=.log
	#LOGSIZE=400
	
}

#Llama al log para grabar
function grabarLog {

	#TODO: hacer
	echo "[Glog] grabo :)"
}

#Crea el directorio y el archivo de configuracion si no existe
function crearDirectorioArchivoConfiguracion {

	mkdir -p $CONFDIR
	>>$CONFDIR/$confFile

}

#Crea el archivo de log
function crearLog {

	>>$CONFDIR/$logFile

	#TODO: Ver!
	#Doy permiso de ejecucion al log
	#chmod 777 -Tiene que haber un handler para el log
	
} 

#Graba mensajes de inicio en el log
function mensajesInicioLog {

	mensaje="[InstalarX] Inicio de Ejecución"
	echo $mensaje
	grabarLog "$mensaje"
	mensaje="[InstalarX] Log del Comando InstalarX: $CONFDIR/$logFile"
	echo $mensaje
	grabarLog "$mensaje"
	mensaje="Directorio de Configuración: $CONFDIR"
	echo $mensaje
	grabarLog "$mensaje"
	
	#TODO: SACAR
	echo "Grabo mensajes iniciales en el log"
}

function main {

	clear
	cd ..

	#grupo: path donde se encuentra el tp ../grupo1/
	grupo=$PWD/grupo1

	#TODO: Sacar
	echo "$grupo"

	#CONFDIR: ubicacion del directorio de configuracion
	CONFDIR=$grupo/conf
	
	#TODO: SACAR
	echo "$CONFDIR"

	#confFile: nombre archivo configuracion
	confFile="InstalarX.conf"

	#logFile: nombre archivo de log
	logFile="InstalarX.log"

	echo "************************************************************************
*   Bienvenido al Asistente de instalación del sistema ControlX        *
*   TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 1   *
************************************************************************"

	crearDirectorioArchivoConfiguracion
	#1 - Inicializar archivo de log
	crearLog
	#2 - Mostrar (y grabar en el log) donde se graba el log de la instalacion
	#3 - Mostrar (y grabar en el log) el nombre del directorio de configuracion
	mensajesInicioLog

	#4 - Detectar si el paquete ControlX o alguno de sus componentes ya esta instalado
	# Cuento la cantidad de lines del archivo de configuracion
	cantLineas=$(wc -l $CONFDIR/$confFile | awk '{print $1}')
	#echo $cantLineas
	if ["$cantLineas" -eq "0"];
	then 
		#5 - Aceptacion de terminos y condiciones
		inicializarVariablesDefault
		instalar
	else
		#4.1 - Verifico instalacion previa
		leerVariablesConfiguracion "$CONFDIR/$confFile"
		
		cantErrores=0
		arribos=0
		log=0
		rechazados=0
		reportes=0
		#tamanio=0
		extension=0
		tamanioLog=0
		maestros=1
		ejecutables=1

		chequearComponentesInstalados
}
main
