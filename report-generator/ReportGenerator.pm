package ReportGenerator;
use Mouse;
use URI;
require 'ReportWriter.pm';
require 'Date.pm';

#Habrá una subclase de esta por cada reporte

has 'writer' => (
	is  => 'rw',
	isa => 'ReportWriter',
);

has 'data_hash' => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub { my %hash = (); return \%hash }
);

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig(
		config => $_[0],
		writer => $_[1]
	);
};

sub write_report {
	my ( $self, $output_dir ) = @_;
	
	$self->writer->write_report($self->data_hash, $self, $output_dir, $self->get_file_name);

}

sub get_flatten_data {
	my ($self, $key) = @_;
	return DataHashFlatten->flatten( $self->get_level(), $self->data_hash->{$key},
		$self->get_fields() );
}

sub parse_values {

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se hacen cosas con los valores y se suman a hash_data
}

sub post_process {

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se calculan los porcentajes con los totales y todo eso
}

sub get_file_name {

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Devolver el nombre del archivo a escribir para cada reporte
}

sub parse_url {
	my ( $self, $url ) = @_;
	if ( $url !~ /.*\/\/.*/ ) {
		$url = "http://" . $url;
	}
	return URI->new($url);
}

sub get_trafico {
	my ( $self, $values ) = @_;
	return ( @$values[ $self->config->{fields}->{'cs-bytes'} ] +
		  @$values[ $self->config->{fields}->{'sc-bytes'} ] );
}

#Agregar acá métodos comunes a todos como es_acceso(), get_fecha(), etc.
1;
