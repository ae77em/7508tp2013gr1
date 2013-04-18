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
	grabarLog "$mensaje"
	mensaje="[InstalarX] Log del Comando InstalarX: $CONFDIR/$logFile"
	grabarLog "$mensaje"
	mensaje="Directorio de Configuración: $CONFDIR"
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
	crearLog
	mensajesInicioLog

}
main
