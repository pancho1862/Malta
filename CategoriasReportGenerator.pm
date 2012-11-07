package CategoriasReportGenerator;
use Mouse;
use URI;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $action = @$values[ $self->config->{fields}->{'action'} ];
	my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
	if ($action eq 'Denied') {
		my $entry = $self->get_entry( $category );
		$entry->{ocurrencias} += 1;
	}
}

sub update_totals {
	my ($self) = @_;

	foreach my $categoria ( keys %{ $self->data_hash } ) {
		$self->data_hash->{$categoria}->{porcentaje} =
		  Utils->porcentaje( $self->data_hash->{$categoria}->{ocurrencias},
			$self->global_stats->{peticiones} );
	}
}

sub get_file_name {
	return "categorias.json";
}

sub get_entry {
	my ( $self, $categoria ) = @_;

	if ( !exists $self->data_hash->{$categoria} ) {
		$self->data_hash->{$categoria} = $self->new_entry;
	}

	return $self->data_hash->{$categoria};
}

sub new_entry {
	my ($self) = @_;
	my %entry = (
		ocurrencias => 0,
		porcentaje  => 0
	);
	return \%entry;
}
1;
