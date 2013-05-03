#!/bin/sh
#Definicion de funciones

#Valida si hay otro interprete corriendo
validarInterprete() {
  SERVICE='interpretar.sh'
  if ps ax | grep -v grep | grep $SERVICE > /dev/null
    then
      echo "ERROR: Hay otro interprete ejecutandose"
      return 1
    else
      echo "Interprete validado"
      return 0
  fi
}

#Valida si la inicializacion fue hecha correctamente
validarInicio() {
  echo "Inicio validado"
  return 0;
}

#Verifica que el archivo aceptado no haya sido procesado anteriormente
verificarDuplicado() {
  if [ ! -f $2/$1 ]
  then
    return 0
  else
    return 1
fi
}

#Determina el codigo del sistema a traves del nombre del archivo
codigoSystem() {
  posicionSeparador1=`expr match $1 [Aa-Zz]*.-`
  posicionSeparador1=`expr $posicionSeparador1 + 1`
  posicionSeparador2=`expr match $1 [Aa-Zz]*.-[0-9]*.-`
  longCodigoSistema=`expr $posicionSeparador2 - $posicionSeparador1`
  codigoSistema=`expr substr $1 $posicionSeparador1 $longCodigoSistema`
  return $codigoSistema
}



#INTERPRETE

#Se valida si ya hay otro interprete corriendo y si el ambiente esta inicializado correctamente

validarInterprete
validacion1=$?
validarInicio
validacion2=$?


if [ $validacion1 -eq 0 ]&&[ $validacion2 -eq 0 ]
  then #Si no hay interprete y el ambiente es el correcto
  
      #Inicializar Log con "Inicio de interprete" y cantidad de archivos de entrada
      #Tarea realizada por medio de la funcion GlogX
      archivosInput=`ls $ACEPDIR | wc -l` 
      
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
            longCodigoPais=`expr match $archivo [Aa-Zz]*`
            codigoPais=`expr substr $archivo 1 $longCodigoPais`

            #Determinar codigo de sistema(Pasarlo a funcion codigoSistema)
            codigoSystem $archivo
            codigoSistema=$?

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
             fecha=`cut -f $lineaFecha -d$sepCampos auxiliar`

	           if [ $formatoFecha = "ddmmyy8." ]
		         then 
		          dia=`expr substr $fecha 1 2`
              mes=`expr substr $fecha 3 2`
              anio=`expr substr $fecha 5 4`
	           else
		          if [ $formatoFecha = "ddmmyy10." ]
			        then 
		        	  dia=`expr substr $fecha 1 2`
           	    mes=`expr substr $fecha 4 2`
                anio=`expr substr $fecha 7 4`
	            else
		         	  if [ $formatoFecha = "yymmdd8." ]
				        then 
		        	   	anio=`expr substr $fecha 1 4`
         	   	    mes=`expr substr $fecha 5 2`
               	  dia=`expr substr $fecha 7 2`
	              else
		        	   	anio=`expr substr $fecha 1 4`
         	   	    mes=`expr substr $fecha 6 2`
               	  dia=`expr substr $fecha 9 2`
		         	  fi 
              fi
	           fi

             #interpretar estado
             lineaEstado=`grep $codigoPais'-'$codigoSistema'-CTB_ESTADO' $CONFDIR/T2.tab | cut -f 4 -d"-"`
             estado=`cut -f $lineaEstado -d$sepCampos auxiliar`  
             if [ -z $lineaEstado ]||[ -z $estado ]
             then 
              estado=0                         
             fi  
                     
             #interpretar codigo prestamo
             lineaCodPres=`grep $codigoPais'-'$codigoSistema'-PRES_ID' $CONFDIR/T2.tab | cut -f 4 -d"-"`          
             PRES_ID=`cut -f $lineaCodPres -d$sepCampos auxiliar`
             if [ -z $lineaCodPres ]||[ -z $PRES_ID ]
             then 
              PRES_ID=0           
             fi 
                                
             #interpretar monto del prestamo
             lineaMT_pres=`grep $codigoPais'-'$codigoSistema'-MT_PRES' $CONFDIR/T2.tab | cut -f 4 -d"-"` 
             formatoNumerico=`grep $codigoPais'-'$codigoSistema'-MT_PRES' $CONFDIR/T2.tab | cut -f 5 -d"-"`  
             MT_PRES=`cut -f $lineaMT_pres -d$sepCampos auxiliar | tr -s $sepDecimal "."`
             if [ -z $lineaMT_pres ]||[ -z $MT_PRES ]
             then 
              MT_PRES=0           
             fi          
             
             #interpretar monto impago
             lineaMTimp=`grep $codigoPais'-'$codigoSistema'-MT_IMPAGO' $CONFDIR/T2.tab | cut -f 4 -d"-"`         
             MT_IMP=`cut -f $lineaMTimp -d$sepCampos auxiliar | tr -s $sepDecimal "."`
             if [ -z $lineaMTimp ]||[ -z $MT_IMP ] 
             then 
              MT_IMP=0             
             fi          
             
             #interpretar monto intereses devengados
             lineaMT_inde=`grep $codigoPais'-'$codigoSistema'-MT_INDE' $CONFDIR/T2.tab | cut -f 4 -d"-"`          
             MT_INDE=`cut -f $lineaMT_inde -d$sepCampos auxiliar | tr -s $sepDecimal "."`
             if [ -z $lineaMT_inde ]||[ -z $MT_INDE ]
             then 
              MT_INDE=0           
             fi          
             
             #interpretar monto intereses no devengados
             linea_innode=`grep $codigoPais'-'$codigoSistema'-MT_INNODE' $CONFDIR/T2.tab | cut -f 4 -d"-"`         
             MT_INNODE=`cut -f $linea_innode -d$sepCampos auxiliar | tr -s $sepDecimal "."`
             if [ -z $linea_innode ]||[ -z $MT_INNODE ]
             then 
              MT_INNODE=0           
             fi 
               
             #interpretar monto debitado 
             lineaMT_deb=`grep $codigoPais'-'$codigoSistema'-MT_DEB' $CONFDIR/T2.tab | cut -f 4 -d"-"`          
             MT_DEB=`cut -f $lineaMT_deb -d$sepCampos auxiliar | tr -s $sepDecimal "."`
             if [ -z $lineaMT_deb ]||[ -z $MT_DEB ]
             then 
              MT_DEB=0           
             fi
                        
             #Calcular monto restante 
             posicionSeparador=`expr index $formatoNumerico "."`
             posicionSeparador=`expr $posicionSeparador + 1`
             longDec=`expr substr $formatoNumerico $posicionSeparador ${#formatoNumerico}`					     
             MT_REST=`echo "scale=2; $MT_PRES + $MT_IMP + $MT_INDE + $MT_INNODE - $MT_DEB" | bc`
             echo $MT_REST 
        
             #interpretar Id cliente
             lineaID_cliente=`grep $codigoPais'-'$codigoSistema'-PRES_CLI_ID' $CONFDIR/T2.tab | cut -f 4 -d"-"`          
             ID_cliente=`cut -f $lineaID_cliente -d$sepCampos auxiliar`
             if [ -z $lineaID_cliente ]||[ -z $ID_cliente ]
             then 
              ID_cliente="99999999"           
             fi 
             
             #interpretar CLiente
             lineaCliente=`grep $codigoPais'-'$codigoSistema'-PRES_CLI-' $CONFDIR/T2.tab | cut -f 4 -d"-"`          
             cliente=`cut -f $lineaCliente -d$sepCampos auxiliar`                          
             if [ -z $lineaCliente ]||[ -z "$cliente" ]
             then 
              cliente="Cliente sin identificar"           
             fi 
             
             #Fecha actual
             fechaActual=`date +%d/%m/%Y`
             
             #Usuario  
             usuario=`logname`
             
             #Separacion del monto restante en parte entera y parte decimal
             posicionSeparador=`expr index $MT_REST '.'`

             if [ -z $posicionSeparador ] 
             then 
                MT_REST_ENT=$MT_REST
                MT_REST_DEC=`expr 1 - 1` 
             else
                posicionSeparador=`expr $posicionSeparador + 1`
                MT_REST_DEC=`expr substr $MT_REST $posicionSeparador $longDec`
                posicionSeparador=`expr $posicionSeparador - 2`
                MT_REST_ENT=`expr substr $MT_REST 1 $posicionSeparador`
             fi
             
             #Darle formato a los registros y guardar los correspondientes
             if [ $MT_REST_ENT -le 0 ]&&[ $MT_REST_DEC -le 0 ]
             then
              echo "Prestamo $PRES_ID cancelado"
             else
               registro=`echo "$codigoSistema;$anio;$mes;$dia;$estado;$PRES_ID;$MT_PRES;$MT_IMP;$MT_INDE;$MT_INNODE;$MT_DEB;$MT_REST;$ID_cliente;"$cliente";$fechaActual;$usuario"`
               
               linePais=`grep $codigoPais $CONFDIR/p-s.mae`
               pais=`echo $linePais | cut -f 2 -d"-"`
               echo $registro >> $PROCDIR/prestamos.$pais
               registrosOutput=`expr $registrosOutput + 1`   
             fi
            registrosInput=`expr $registrosInput + 1`
            done < $ACEPDIR/$archivo
            
            rm auxiliar
            
              #Grabar en el log la cantidad de registros que entraron y la que salieron
                #Tarea realizada por medio de la funcion GlogX
                
              #Mover archivo a $PROCDIR
                #Tarea realizada por medio del moverX
              
          else  #En caso de estar duplicado
            #Escribe en el log por medio de GlogX "DUPLICADO:archivo" y mueve el archivo a
            #$RECHDIR por medio de MoverX 
            echo "Duplicado"                                
          fi  
        fi
      done   
    #Grabar en el Log fin de interprete
        #Tarea realizada por medio de la funcion GlogX

    #echo $?
  else    
    echo "Fallo la validacion previa a ejecutar el interprete"
fi 

    

