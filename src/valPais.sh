#!/bin/bash
function validar()
{

if [[ $# != 4 ]]
then
	echo "Error en cantidad de parametros en el validar, no se pueden validar sistema y pais"
	exit 20
fi

pais="$1"
sistema="$2"
archPath="$PWD/$3"
archivo="$4"
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
	return 0
fi

if [[ "$paisEncontrado" = false ]] && [[ "$sistemaEncontrado" = false ]] 
then
	GlogX "DetectaX.sh" "E" "Error en archivo $archivo: No existe ni sistema ni pais" "DetectaX"
	return 1
fi

if [[ "$paisEncontrado" = false ]]
then
	GlogX "DetectaX.sh" "E" "Error en archivo $archivo: No existe pais" "DetectaX"
	return 2
fi

if [[ "$sistemaEncontrado" = false ]]
then
	GlogX "DetectaX.sh" "E" "Error en archivo $archivo: No existe sistema" "DetectaX"
	return 3
fi

if [[ "$paisEncontrado" = true ]] && [[ "$sistemaEncontrado" = true ]] 
then
	 GlogX "DetectaX.sh" "E" "Error en archivo $archivo: No existe combinacion pais-sistema" "DetectaX"
	 return 4
fi


}


