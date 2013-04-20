#!/bin/perl

# abro los archivos para el reporte
sub abrirArchivosParaLeer{
	
	# Obtengo los parametros 
	my($pys,$ppi,$prestamos) = @_;

	# Abro los archivos correspondientes
	open (PYS,"<$pys") || die "ERROR: No se pudo abrir el archivo $pys.\n";
	open (PPI,"<$ppi") || die "ERROR: No se pudo abrir el archivo $ppi.\n";
	open (PRESTAMOS,"<$prestamos") || die "ERROR: No se pudo abir el archivo $prestamos.\n";
}

# muestro la ayuda
sub mostrarAyuda{
	
	if ( @_[0] cmp "" )
	{
		print "Uso: 	ReporteX <subcomando> [opciones] [argumenos]\n";
		print "Tipee: 'ReporteX -a subcomando' para obtener información\n";
		print "acerca del subcomando.\n\n";
		print "Subcomandos disponibles:\n";
		print " -a\n";
		print "	-cr\n";
		print "	-difabs\n";
		print "	-difporc\n";
		print " -g\n";
	}
	else
	{
		if ( @_[0] cmp "-a" )
		{
			print "Muestra información acerca del parámetro pasado como\n";
			print "parámetro. Si se escribe el subcomando sólo, muestra la\n";
			print "ayuda general.\n";
		}
		elsif ( @_[0] cmp "-cr" )
		{
			print "En construcción\n";
			print "\n";
			print "\n";
		}

	}
	
}

# programa principal
sub principal{
	
	if (@_[0] cmp "-a")
	{
		&mostrarAyuda;
	}
	else 
	{
	 	print "En construcción.\n";
	}

}

