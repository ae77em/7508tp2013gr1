#!/bin/bash
#Definicion de funciones

source "$BINDIR/GlogX.sh";
source "$BINDIR/MoverX.sh";

#Valida si la inicializacion fue hecha correctamente
function validarInicio() {
  echo "TODO: Inicio validado"
  return 0;
}

#Verifica que el archivo aceptado no haya sido procesado anteriormente
function verificarDuplicado() {
  if [ ! -f $2/$1 ]
  then
    return 0
  else
    return 1
fi
}

#Determina el codigo del sistema a traves del nombre del archivo
function codigoSystem() {
  posicionSeparador1=`expr match $1 [Aa-Zz]*.-`
  posicionSeparador1=`expr $posicionSeparador1 + 1`
  posicionSeparador2=`expr match $1 [Aa-Zz]*.-[0-9]*.-`
  longCodigoSistema=`expr $posicionSeparador2 - $posicionSeparador1`
  codigoSistema=`expr substr $1 $posicionSeparador1 $longCodigoSistema`
  return $codigoSistema
}



#INTERPRETE

#Se valida si ya hay otro interprete corriendo y si el ambiente esta inicializado correctamente

CONFDIR=../conf

validarInicio
validacion1=$?


if [ $validacion1 -eq 0 ]
  then #Si no hay interprete y el ambiente es el correcto
  
      #Inicializar Log con "Inicio de interprete" y cantidad de archivos de entrada
      GlogX "Interprete.sh" "I" "Inicio de Interprete" "Interprete"
      archivosInput=`ls $ACEPDIR | wc -l` 
      GlogX "Interprete.sh" "I" "$archivosInput" "Interprete"
      
      
      #Procesamiento de archivos de $ACEPTDIR(Por cada archivo)
      registrosInput=0
      registrosOutput=0 
      
      for archivo in `ls $ACEPDIR`
      do
      
      caracter="~"
      posicion=`expr index $archivo $caracter`
      
       if [ $posicion != 0 ]
       then
         rm $ACEPDIR/$archivo
          
       else  
        
        #Verificar que el archivo no esta duplicado en PROCDIR
        verificarDuplicado $archivo $PROCDIR

        if [ $? -eq 0 ]   #Si no esta duplicado
          then
          
            #Determinar codigo de pais
	    #echo "ARCHIVO: $archivo"
            #longCodigoPais=`expr match $archivo [Aa-Zz]*`	
      	    #echo "LONGCODPAIS: $longCodigoPais"
            codigoPais=`expr substr $archivo 1 1`
    	    echo "CODIGOPAIS: $codigoPais"

            #Determinar codigo de sistema(Pasarlo a funcion codigoSistema)
            codigoSystem $archivo
            codigoSistema=$?

	    echo "CODIGOSISTEMA: $codigoSistema"


            #Determinar separadores	
            Linea=`grep $codigoPais'-'$codigoSistema $CONFDIR/T1.tab`

            posicionSepCampos=`expr match $Linea [Aa-Zz]*.-[0-9]*.-`
            posicionSepCampos=`expr $posicionSepCampos + 1`
            sepCampos=`expr substr $Linea $posicionSepCampos 1`

            posicionSepDec=`expr match $Linea [Aa-Zz]*.-[0-9]*.-.-`
            posicionSepDec=`expr $posicionSepDec + 1`
            sepDecimal=`expr substr $Linea $posicionSepDec 1`

            #Determinar campos  
            
            #Leer registro(Por cada registro)
            chmod 777 $PROCDIR
            touch auxiliar
  
	    while read linea
            do

             echo $linea > auxiliar         

             #interpretar fecha
             lineaFecha=`grep $codigoPais'-'$codigoSistema'-CTB_FE' $CONFDIR/T2.tab | cut -f 4 -d"-"`
             formatoFecha=`grep $codigoPais'-'$codigoSistema'-CTB_FE' $CONFDIR/T2.tab | cut -f 5 -d"-"` 
	           formatoFecha=${formatoFecha%%'.'*}	
             fecha=`cut -f $lineaFecha -d$sepCampos auxiliar`

	           if [ "$formatoFecha" = "ddmmyy8" ]
		         then 
		          dia=`expr substr $fecha 1 2`
              		  mes=`expr substr $fecha 3 2`
              		  anio=`expr substr $fecha 5 4`
		          else				
		          	if [ "$formatoFecha" = "ddmmyy10" ]
			        then 
		        	  dia=`expr substr $fecha 1 2`
           	    		  mes=`expr substr $fecha 4 2`
                		  anio=`expr substr $fecha 7 4`
	            	  	else
		         	  if [ "$formatoFecha" = "yymmdd8" ]
				     then 
		        	   	anio=`expr substr $fecha 1 4`
         	   	    		mes=`expr substr $fecha 5 2`
               	 		        dia=`expr substr $fecha 7 2`
	              		     else
					if [ "$formatoFecha" = "yymmdd10" ]
					then
					   	anio=`expr substr $fecha 1 4`
		 	   	    		mes=`expr substr $fecha 6 2`
		       	  			dia=`expr substr $fecha 9 2`
					else 
						GlogX "Interprete.sh" "E" "Formato de fecha invalido: $archivo" "Interprete"
						anio="AAAA"
		 	   	    		mes="MM"
		       	  			dia="DD"
					fi
		         	  fi 
              		  fi
	           fi

             #interpretar estado
             lineaEstado=`grep $codigoPais'-'$codigoSistema'-CTB_ESTADO' $CONFDIR/T2.tab | cut -f 4 -d"-"` 
             if [ -z $lineaEstado ]              
                then 
                  estado="Estado sin especificar"
                else
                  estado=`cut -f $lineaEstado -d$sepCampos auxiliar`
                  if [ -z $estado ]
                    then 
                      estado="Estado sin especificar" 
                  fi                        
             fi 
               
             #interpretar codigo prestamo
             lineaCodPres=`grep $codigoPais'-'$codigoSistema'-PRES_ID' $CONFDIR/T2.tab | cut -f 4 -d"-"`          
             if [ -z $lineaCodPres ]              
                then 
                  PRES_ID=0
                else
                  PRES_ID=`cut -f $lineaCodPres -d$sepCampos auxiliar`
                  if [ -z $PRES_ID ]
                    then 
                      PRES_ID=0 
                  fi                        
             fi 
                 
             #interpretar monto del prestamo
             lineaMT_pres=`grep $codigoPais'-'$codigoSistema'-MT_PRES' $CONFDIR/T2.tab | cut -f 4 -d"-"` 
             formatoNumerico=`grep $codigoPais'-'$codigoSistema'-MT_PRES' $CONFDIR/T2.tab | cut -f 5 -d"-"`  
             MT_PRES=`cut -f $lineaMT_pres -d$sepCampos auxiliar | tr -s $sepDecimal "."`
             if [ -z $lineaMT_pres ]              
                then 
                  MT_PRES=0
                else
                  MT_PRES=`cut -f $lineaMT_pres -d$sepCampos auxiliar | tr -s $sepDecimal "."`
                  if [ -z $MT_PRES ]
                    then 
                      MT_PRES=0
                  fi                        
             fi          
             MT_PRES=`echo $MT_PRES | sed 's/\r$//g'`
             
             #interpretar monto impago
             lineaMTimp=`grep $codigoPais'-'$codigoSistema'-MT_IMPAGO' $CONFDIR/T2.tab | cut -f 4 -d"-"`         
             if [ -z $lineaMTimp ]              
                then 
                  MT_IMP=0
                else
                  MT_IMP=`cut -f $lineaMTimp -d$sepCampos auxiliar | tr -s $sepDecimal "."`
                  if [ -z $MT_IMP ]
                    then 
                      MT_IMP=0
                  fi                        
             fi          
             MT_IMP=`echo $MT_IMP | sed 's/\r$//g'`
             
             #interpretar monto intereses devengados
             lineaMT_inde=`grep $codigoPais'-'$codigoSistema'-MT_INDE' $CONFDIR/T2.tab | cut -f 4 -d"-"`                       
             if [ -z $lineaMT_inde ]              
                then 
                  MT_INDE=0
                else
                  MT_INDE=`cut -f $lineaMT_inde -d$sepCampos auxiliar | tr -s $sepDecimal "."`
		
                  if [ -z $MT_INDE ]
                    then 
                      MT_INDE=0
                  fi                        
             fi          
             MT_INDE=`echo $MT_INDE | sed 's/\r$//g'`

             #interpretar monto intereses no devengados
             linea_innode=`grep $codigoPais'-'$codigoSistema'-MT_INNODE' $CONFDIR/T2.tab | cut -f 4 -d"-"`         
             if [ -z $linea_innode ]              
                then 
                  MT_INNODE=0
                else
                  MT_INNODE=`cut -f $linea_innode -d$sepCampos auxiliar | tr -s $sepDecimal "."`
                  if [ -z $MT_INNODE ]
                    then 
                      MT_INNODE=0 
                  fi                        
             fi
             MT_INNODE=`echo $MT_INNODE | sed 's/\r$//g'` 
              
             #interpretar monto debitado 
             lineaMT_deb=`grep $codigoPais'-'$codigoSistema'-MT_DEB' $CONFDIR/T2.tab | cut -f 4 -d"-"`          
             if [ -z $lineaMT_deb ]              
                then 
                  MT_DEB=0
                else
                  MT_DEB=`cut -f $lineaMT_deb -d$sepCampos auxiliar | tr -s $sepDecimal "."`
                  if [ -z $MT_DEB ]
                    then 
                      MT_DEB=0 
                  fi                        
             fi
             MT_DEB=`echo $MT_DEB | sed 's/\r$//g'`  
                      
             #Calcular monto restante              		     
             MT_REST=`echo "$MT_PRES + $MT_IMP + $MT_INDE + $MT_INNODE - $MT_DEB"| bc`	      
       echo $MT_RES	 
	
             #interpretar Id cliente
             lineaID_cliente=`grep $codigoPais'-'$codigoSistema'-PRES_CLI_ID' $CONFDIR/T2.tab | cut -f 4 -d"-"`        
             if [ -z $lineaID_cliente ]              
                then 
                  ID_cliente="99999999"
		  GlogX "Interprete.sh" "E" "ID de cliente sin especificar: $PRES_ID" "Interprete"
                else
                  ID_cliente=`cut -f $lineaID_cliente -d$sepCampos auxiliar`                   
             fi 
             echo $ID_cliente
             #interpretar CLiente
             lineaCliente=`grep $codigoPais'-'$codigoSistema'-PRES_CLI-' $CONFDIR/T2.tab | cut -f 4 -d"-"`                                   
             if [ -z $lineaCliente ]              
                then 
                  cliente="Cliente sin identificacion"
		  GlogX "Interprete.sh" "E" "Cliente sin especificar: $PRES_ID" "Interprete"
                else
                  cliente=`cut -f $lineaCliente -d$sepCampos auxiliar`                                         
             fi 
             echo $cliente
             #Fecha actual
             fechaActual=`date +%d/%m/%Y`
             
             #Usuario  
             usuario=`whoami`

             #Separacion del monto restante en parte entera y parte decimal
             posicionSeparador=`expr index $MT_REST '.'`
             if [ -z $posicionSeparador ]||[ $posicionSeparador -eq 0 ]
             then 
                MT_REST_ENT=$MT_REST
                MT_REST_DEC=0
             else
                if [ $posicionSeparador -eq 1 ]
                then 
                   MT_REST_ENT=0
                   posicionSeparador=`expr $posicionSeparador + 1`
                   MT_REST_DEC=`expr substr $MT_REST $posicionSeparador 2`
                else 
                   posicionSeparador=`expr $posicionSeparador + 1`
                   MT_REST_DEC=`expr substr $MT_REST $posicionSeparador 2`
                   posicionSeparador=`expr $posicionSeparador - 2`
                   MT_REST_ENT=`expr substr $MT_REST 1 $posicionSeparador`
                fi
             fi

             #Darle formato a los registros y guardar los correspondientes
             if [ $MT_REST_ENT -le 0 ]&&[ $MT_REST_DEC -le 0 ]
             then
	      GlogX "Interprete.sh" "I" "Prestamo $PRES_ID cancelado" "Interprete"
             else
               registro=`echo "$codigoSistema;$anio;$mes;$dia;$estado;$PRES_ID;$MT_PRES;$MT_IMP;$MT_INDE;$MT_INNODE;$MT_DEB;$MT_REST;$ID_cliente;"$cliente";$fechaActual;$usuario"`
               
               linePais=`grep $codigoPais $MAEDIR/p-s.mae`
               pais=`echo $linePais | cut -f 2 -d"-"`
               echo $registro >> $PROCDIR/prestamos.$pais
               registrosOutput=`expr $registrosOutput + 1`   
             fi
            registrosInput=`expr $registrosInput + 1`
		
            done < $ACEPDIR/$archivo

           rm auxiliar
            
              #Grabar en el log la cantidad de registros que entraron y la que salieron
                GlogX "Interprete.sh" "I" "Registros de Input: $registrosInput" "Interprete"
                GlogX "Interprete.sh" "I" "Registros de Output: $registrosOutput" "Interprete"
              #Mover archivo a $PROCDIR
                 MoverX "$ACEPDIR/$archivo" "$PROCDIR" "Interprete.sh"
              
          else  #En caso de estar 
	    GlogX "Interprete.sh" "I" "El archivo $achivo se encuentra duplicado" "Interprete"
            MoverX "$ACEPDIR/$archivo" "$RECHDIR" "Interprete.sh"
                           
          fi  
        fi
      done   
    #Grabar en el Log fin de interprete
         GlogX "Interprete.sh" "I" "Interprete finalizado" "Interprete"

    #echo $?
  else    
    GlogX "Interprete.sh" "SE" "Fallo la validacion previa al interprete" "Interprete"
fi 

    

