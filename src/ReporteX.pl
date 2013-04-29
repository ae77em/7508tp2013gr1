#!/usr/bin/perl

########################
#		       		   #
#  VARIABLES GLOBALES  #
#		       		   #
########################

$PAIS_ID="";   	# id del pais
$PAIS_DESC="";	# descripcion del pais
$SIS_ID="";	# id del sistema
$CTB_ANIO="";	# año contable
$CTB_MES="";    # mes contable
$PRES_ID="";	# id del préstamo

$MT_PRES=0;     # monto del préstamo
$MT_IMPAGO=0;	# monto impago
$MT_INDE=0;	# monto intereses devengados
$MT_INNODE=0;	# monto intereses no devengados
$MT_DEB=0;	# monto debitado
$MT_REST=0;	# monto restante

$periodo="";
$rango_periodos="";

%registros_ppi;
%registros_prestamos;

@reporte;

################
#	           #
#  SUBRUTINAS  #
#	           #
################

#
# Ayuda
#
sub mostrarAyuda{

	# obtengo el comando del cual quiere obtener ayuda.
	my $param = @_[0];
	chomp($param);

	if ( uc($param) eq "" )
	{
		print "Ayuda del Generador de reportes del grupo 1.\n";
		print "Modo de uso: 	ReporteX <subcomando> [opciones] [argumenos]\n";
		print "Tipee 'ReporteX -a <subcomando>' para obtener información acerca del subcomando.\n\n";
		print "Subcomandos disponibles:\n";
		print "	-a\n";
		print "	-cr\n";
		print "	-difabs\n";
		print "	-difporc\n";
		print "	-g\n";
	}
	elsif ( uc($param) eq uc("-a") )
	{
		print "Muestra información acerca del parámetro pasado como parámetro.\n";
		print "Si se escribe el subcomando sólo, muestra la ayuda general.\n";
	}
	elsif ( uc($param) eq uc("-cr") )
	{
		print "En construcción.\n";
		print "\n";
		print "\n";
	}
	elsif ( uc($param) eq uc("-difabs") )
	{
		print "En construcción.\n";
	}
	elsif ( uc($param) eq uc("-difporc") )
	{
		print "En construcción.\n";
	}

	elsif ( uc($param) eq uc("-g") )
	{
		print "En construcción.\n";
	}
	else 
	{
		print "El comando ingresado no existe para el Generador de reportes.\n";
	}
	
}

#
# Obtengo los valores del archivo de prestamos por pais
#
sub obtenerPrestamosPais{
	
	my @valores_registro;
	my $anio_ctb;
	my $mes_ctb;
	my $dia_ctb;
	my $fecha_grab;
	
	my $clave_p_p;
	my $aux;

	#  el archivo de prestamos.pais
	open(PRESTAMOS,"/home/esteban/Documentos/TPSSOO/PROCDIR/prestamos.".$PAIS_DESC);
		
	while(<PRESTAMOS>)
	{	
		chomp; # quito el eol

		# obtengo los datos y los almaceno en un array
		@valores_registro = split(';',$_);
		
		# tomo los datos necesarios para la comparacion
		$anio_ctb	= @valores_registro[1];
		$mes_ctb	= @valores_registro[2];
		$dia_ctb	= @valores_registro[3];
		$fecha_grab	= @valores_registro[14];

		# compongo la clave de busqueda
		$clave_p_p 	= $PRES_ID.$anio_ctb.$mes_ctb;

		# almaceno los valores en una estructura hash
		if ( exists $registros_prestamos{$clave_p_p} )
		{
			# obtengo los datos almacenados
			$aux = split(';',$registros_prestamos{$clave_p_p});		
			# si la fecha de grabacion del nuevo registro es mas actual lo almaceno
			if ( uc($aux[14]) lt uc($fecha_grab)  )
			{
				# borro y reinserto datos validos
				delete($registros_prestamos{$clave_p_p}); 
				$registros_prestamos{$clave_p_p} = $_;

			}
			# si no, no hago nada...
		}
		else
		{
			$registros_prestamos{$clave_p_p} = $_;
		}

	}

	close(PRESTAMOS);
	#print map "Hash: $_ = $registros_prestamos{$_}\n", keys %registros_prestamos;
}

#
# Obtengo los valores del archivo de prestamos personales impagos
#
sub obtenerPrestamosImpagos{

	my @valores_registro;
	my @aux;
	
	my $reg;
	my $clave_ppi;

	#print "periodo al entrar a subrutina: $periodo\n";

	# inicializo los valores para los cálculos	
	$MT_PRES=0;
	$MT_IMPAGO=0;
	$MT_INDE=0;
	$MT_INNODE=0;
	$MT_DEB=0;
	$MT_REST=0;

	# abro el archivo maestro (PPI)
	open (PPI,"/home/esteban/Documentos/TPSSOO/MAEDIR/PPI.mae") || die "ERROR: No puedo abrir el fichero PPI.\n";
	
	# realizo la lectura para ver que registros coinciden con el filtro
	while (<PPI>)
	{
		chomp; # quito el eol

		# guardo los valores en una cadena
		@valores_registro = split(';',$_);
			
		# verifico que cumpla todas las condiciones
	 	if ( uc($PAIS_ID) ne uc(@valores_registro[0])){ next; }
		if ( $SIS_ID ne "" ) 
		{
			if ( uc($SIS_ID) ne uc(@valores_registro[1]) ){ next; }
		}
	 	if ( $CTB_ANIO ne "" )
		{
			if ( uc($CTB_ANIO) ne uc(@valores_registro[2])){ next; }
		}
	 	if ( $periodo ne "" )
		{
			if ( uc($periodo) ne uc(@valores_registro[2]."/".@valores_registro[3])){ next; }
		}
	 	if ( $rango_periodos ne "" )
		{
			if ( uc(substr($rango_periodos,0,7)) gt uc(@valores_registro[2]."/".@valores_registro[3])
			   || uc(substr($rango_periodos,8,7)) lt uc(@valores_registro[2]."/".@valores_registro[3])){ next; }
		}
		
		# obtengo el id del prestamo	 
		$PRES_ID = @valores_registro[7];

		# obtengo los valores y con ellos hago los calculos
		$MT_PRES    = sprintf("%.2f",@valores_registro[9]);
		$MT_IMPAGO  = sprintf("%.2f",@valores_registro[10]);
		$MT_INDE    = sprintf("%.2f",@valores_registro[11]);
		$MT_INNODE  = sprintf("%.2f",@valores_registro[12]);
		$MT_DEB     = sprintf("%.2f",@valores_registro[13]);
		
		# calculo el monto restante
		$MT_REST    = sprintf("%.2f",$MT_PRES + $MT_IMPAGO + $MT_INDE + $MT_INNODE - $MT_DEB);
		
		# agrego a los valores el monto restante
		push(@valores_registro,$MT_REST);

		# almaceno el array en un string
		$reg = join(';',@valores_registro);
		
		# creo la clave del registro
		$clave_ppi = $PRES_ID.@valores_registro[2].@valores_registro[3];
		#print "Clave: $clave_ppi\n";
		
		# guardo los valores obtenidos en una estructura hash
		if ( ! exists $registros_ppi{$clave_ppi} )
		{
			#print "reg ppi: $reg\n";
			$registros_ppi{$clave_ppi} = $reg;
			#print "Registro insertado: $reg\n";
		}		
	}

	# cierro el archivo
	close(PPI);

	#print map "Hash: $_ = $registros_ppi{$_}\n", keys %registros_ppi;
}

#
# Calculo y muestro la recomendacion
#
sub mostrarRecomendacion{

	my @reg_ppi;
	my @reg_p_p;
	my @aux;

	my $linea;
	my $recomendacion;

	# recorro los datos y voy viendo si es necesario el recalculo
	foreach my $llave (keys %registros_ppi)
	{
		#print "Llave ppi $llave\n";
		# me fijo que exista en ambos archivos
		if ( exists ($registros_prestamos{$llave}))
		{
			# obtengo los datos del registro
			@reg_p_p = split(";",$registros_prestamos{$llave});
			@reg_ppi = split(";",$registros_ppi{$llave});

			#print "reg_p_p: $registros_prestamos{$llave}\n";
			#print "reg_ppi: $registros_ppi{$llave}\n";

			# defino si hay que hacer recalculo o no
			if ( ( $reg_ppi[5] eq "SMOR" && $reg_p_p[4] ne "SMOR" ) || ( $reg_ppi[14] lt $reg_p_p[11]  ) )
			{
				$recomendacion = "RECALCULO";
			}	
			else
			{
				$recomendacion = "BUENO";
			}
			
			$linea = $reg_ppi[7].";".$reg_p_p[12].";".$reg_ppi[5].";".$reg_p_p[4].";".$reg_ppi[14].";".$reg_p_p[11].";".$recomendacion;
			
			push (@aux,$linea);
			
			 "Linea reporte: $linea\n";
		}
	}	
	
	# ordeno el reporte alfabéticamente
	@aux = sort { lc($a) cmp lc($b) } @aux;
	
	# meto el auxiliar en el reporte
	foreach $linea (@aux)
	{
			my @aux2;
			@aux2 = split(";",$linea);
			@aux2 = reverse(@aux2);
			push (@reporte,@aux2[0]); # recomendacion
			push (@reporte,@aux2[1]); # mt rest pais
			push (@reporte,@aux2[2]); # mt rest mae
			push (@reporte,@aux2[3]); # estado cont pais
			push (@reporte,@aux2[4]); # estado cont mae
			push (@reporte,@aux2[5]); # cliente
			push (@reporte,@aux2[6]); # prestamo
	}
	
	# imprimo la cabecera
	printf ("%-17s","Prestamo");
	printf ("%-17s","Cliente");
	printf ("%-17s","Est. Cont. Mae.");	
	printf ("%-17s","Est. Cont. Pais");	
	printf ("%-17s","Mt. Rest. Mae.");	
	printf ("%-17s","Mt. Rest. Pais");
	printf ("%-17s","Recomendacion");
	print "\n";
	
	# muestro el reporte
	@reporte = reverse(@reporte);
	my $cantCol = 0;
	foreach $elem (@reporte)
	{
			chomp;
			printf ("%-17s",$elem);
			$cantCol++;
			
			# paso al siguiente renglon
			if ( $cantCol == 7 )
			{
				print "\n";
				$cantCol = 0;
			}
	}
	
}

#
# Reporte de comparacion para el recalculo.
#
sub reporteComparacionRecalculo{
	
	my @valores_registro;	

	my $pais;
	my $sistema;
	my $anio;
	my $parametro;

	my $subs;
	
 	# inicializo las variables globales
	$PAIS_ID="";
	$PAIS_DESC="";
	$SIS_ID="";
	$CTB_ANIO="";
	$CTB_MES=""; 
	$PRES_ID="";

	# tomo los parametros y los convierto a strings
	my $aux = join(' ',@_); 
	# quito caracter de eol
	chomp($aux);
	# paso parametros a array
	my @parametros = split(/ /,$aux);
	# elimino el comando correspondiente a la subrutina
	splice(@parametros, 0, 1);

	# me fijo los parametros enviados
	foreach $parametro( @parametros )
	{
		# el primer parametro es el pais, que no lleva identificador
		# porque va siempre...si no encuentra un igual antes, es ese...
		if ( $parametro !~ m/=/)
		{
			$PAIS_DESC = $parametro;
		}
		elsif ( $parametro =~ m/-s=/)
		{
			$SIS_ID = substr $parametro, index($parametro,'=')+1, (length $parametro)-3;
		}
		elsif ( $parametro =~ m/-a=/)
		{
			$CTB_ANIO = substr $parametro, index($parametro,'=')+1, (length $parametro)-3;
		}
		
		elsif ( $parametro =~ m/-p=/)
		{
			$periodo = substr $parametro, index($parametro,'=')+1, (length $parametro)-3;			
		}
		elsif ( $parametro =~ m/-rp=/)
		{
			$rango_periodos = substr $parametro, index($parametro,'=')+1, (length $parametro)-4;							
		}
		else
		{
			print "El parametro $parametro es incorrecto.\n";
			return(0);
		}
	}

	# obtengo los valores del archivo de paises y  sistemas
	open (P_S,"/home/esteban/Documentos/TPSSOO/MAEDIR/p-s.mae");
	
	# busco el codigo del pais ingresado
	while (<P_S>)
	{
		@valores_registro = split('-',$_);

		if( uc(@valores_registro[1]) eq uc($PAIS_DESC)  )
		{
			$PAIS_ID = @valores_registro[0];
			$PAIS_DESC = @valores_registro[1];
			last;
		}			
	}

	# si no se encontro el país, salgo de la subrutina
	if ( $PAIS_ID eq "" )
	{
		print "El país ingresado no está en la base de datos.";
		return(0);
	}
	
	
	# paso a minusculas la descripcion del pais (para abrir el archivo de prestamos)
	$PAIS_DESC =~ tr/A-Z/a-z/;

	# obtengo los prestamos impagos segun los filtros
	&obtenerPrestamosImpagos;

	# obtengo los prestamos de cada pais
	&obtenerPrestamosPais;

	# muestro los resultados y recomendaciones
	&mostrarRecomendacion;

}	
# analizo los valores de los parametros que me pasaron
sub analizarParametros{
	
	#inicializo las variables	
	my $rta = "s";
	my $cmd;
	my $pmt;
	my $respuestaIncorrecta = 1;

	# obtengo los valores pasados como parametros
	$cmd = @_[0];
	
	if ($cmd eq "-a")
	{
		&mostrarAyuda(@_[1]);				
	}
	elsif ($cmd eq "-cr" ) 
	{
		&reporteComparacionRecalculo(@_);
	}
	else 
	{
		print "El comando es incorrecto.\n";
	}
	
	while ( $respuestaIncorrecta )
	{
		print "\n¿Desea realizar otra consulta? (s/n):";
		$rta = <STDIN>;
		chomp($rta);
		print "rta=$rta\n";

		if ( uc($rta) eq uc("n") )
		{
			return(0);
			last;
		}
		elsif ( uc($rta) eq uc("s") ) 
		{
			return(1);
			last;
		}
		else
		{
			print "¡Respuesta incorrecta!";
		}
	}
}

######################
#		     #
# PROGRAMA PRINCIPAL #
#		     #
######################

	# tomo los parametros y los convierto a strings
	my $aux = join(' ',@ARGV); 
	# quito caracter de eol
	chomp($aux);
	# paso parametros a array
	my @parametros = split(/ /,$aux);
	
	# muestra resultado de consultas, hasta que 
	# el usuario indique que quiere terminar
	my $seguir = &analizarParametros(@parametros);
	while ( $seguir )
	{	
		print "./ReporteX.pl ";
		$aux = <STDIN>;
		chomp($aux);
		@parametros = split(/ /,$aux);
		$seguir = &analizarParametros(@parametros);			
	}



