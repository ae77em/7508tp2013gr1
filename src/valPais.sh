#!/bin/bash
function validar()
{

if [[ $# != 2 ]]
then
	echo "error en cantidad de parametros, no se pueden validar sistema y pais"
	exit 20
fi

pais=$1
sistema=$2
archPath=$PWD/$3
paisEncontrado=false
sistemaEncontrado=false
combinacionEncontrada=false

for i in $(sed "s%^\([A-Z]-[0-9]\)\(-.*$\)%\1%g" $3)
do
	codPais=$(echo "$i" | cut -s -f1 -d'-' )
	codSistema=$(echo "$i" | cut -s -f3 -d'-' )

	if [[ "$pais" = "$codPais" ]] && [[ "$sistema" = "$codSistema" ]]
	then
		combinacionEncontrada=true
		break
	fi
	
	if [[ "$paisEncontrado" = false ]] && [[ "$pais" = "$codPais" ]]
	then
		paisEncontrado=true
	fi

	if [[ "$sistemaEncontrado" = false ]] && [[ "$sistema" = "$codSistema" ]]
	then
		sistemaEncontrado=true
	fi

done

if [[ "$combinacionEncontrada" = true ]]
then
	echo "Valido"
	exit 0
fi

if [[ "$paisEncontrado" = false ]] && [[ "$sistemaEncontrado" = false ]] 
then
	echo "No existe ni sistema ni pais"
	exit 1
fi

if [[ "$paisEncontrado" = false ]]
then
	echo "No existe pais"
	exit 2
fi

if [[ "$sistemaEncontrado" = false ]]
then
	echo "No existe sistema"
	exit 3
fi

if [[ "$paisEncontrado" = true ]] && [[ "$sistemaEncontrado" = true ]] 
then
	echo "No existe combinacion"
fi


}


