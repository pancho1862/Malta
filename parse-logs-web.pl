use warnings;
use strict;
use Benchmark;
use lib 'report-generator';
use lib 'common';
use lib 'configuration';
use lib 'writer';
use lib 'parser';
use lib 'merger';
require 'Configuration.pm';
require 'Strings.pm';
require 'Parser.pm';
require 'Files.pm';
require 'Hashes.pm';
#require 'HostsReportGenerator.pm';
require 'GlobalStatsReportGenerator.pm';
require 'PaginasReportGenerator.pm';
require 'StatusReportGenerator.pm';
require 'CategoriasReportGenerator.pm';
require 'CategoriaUsuarioReportGenerator.pm';
require 'CategoriaUsuarioPaginaReportGenerator.pm';
require 'SearchReportGenerator.pm';
require 'UsuarioTraficoReportGenerator.pm';
require 'PaginaUsuariosReportGenerator.pm';
require 'ReportWriter.pm';
require 'ReportMerger.pm';
require 'StatusReportMerger.pm';
require 'DescargasReportGenerator.pm';
require 'SimpleReportGenerator.pm';
require 'BrowserReportGenerator.pm';
require 'NoCategorizadosReportGenerator.pm';
require 'Level0ReportMerger.pm';
require 'Level1ReportMerger.pm';
require 'Level2ReportMerger.pm';
require 'Level3ReportMerger.pm';
require 'StatusReportMerger.pm';
use Log::Log4perl;
use Getopt::Std;

Log::Log4perl->init("configuration/log4perl.conf");
my $t0 = Benchmark->new;
my $conf = Configuration->instance;
my @reports = get_selected_reports();
our ($opt_f, $opt_w, $opt_i, $opt_o, $opt_d);
my @dates_to_parse;

parse_cmd_params('w:i:o:d:');

my $parser = Parser->new( report_generators => \@reports);
my @files = map {$conf->log_dir.$_} @{Files->list_files($conf->log_dir, $conf->web_file_patterns)};

$parser->parse_files(\@files, \@dates_to_parse);

ReportWriter->instance->write_version($conf->output_dir);

my $tf = Benchmark->new;
my $td = timediff($tf, $t0);

my $log = Log::Log4perl->get_logger("main");

$log->info("Done.");
$log->info("Time elapsed: ", timestr($td));

#***************************************************************************
#***************************************************************************
#***************************************************************************


sub parse_cmd_params {
	my ($params_string) = @_;
	getopts($params_string);
	$conf->web_file_patterns($opt_w) if $opt_w;
	$conf->fws_file_patterns('');
	$conf->log_dir($opt_i) if $opt_i;
	$conf->output_dir($opt_o) if $opt_o;
	die "You must specify the dates to be parsed (-d yyyy-mm-dd,yyyy-mm-dd,...)" unless $opt_d;
	my @dates = split ',', $opt_d;
	foreach my $date (@dates) {
		push @dates_to_parse, Date->new($date);
		Log::Log4perl->get_logger("main")->debug("Added date to parse: $date");
	}
}

sub get_selected_reports {
	#TODO: Implement a configuration to select which reports to generate
	
	my @reports;
	push (@reports, GlobalStatsReportGenerator->new);
	#push (@reports, HostsReportGenerator->new);
	push (@reports, PaginasReportGenerator->new);
	push (@reports, StatusReportGenerator->new);
	push (@reports, CategoriasReportGenerator->new);
	push (@reports, CategoriaUsuarioReportGenerator->new);
	push (@reports, CategoriaUsuarioPaginaReportGenerator->new);
	push (@reports, SearchReportGenerator->new);
	push (@reports, UsuarioTraficoReportGenerator->new);
	push (@reports, PaginaUsuariosReportGenerator->new);
	push (@reports, DescargasReportGenerator->new);
	push (@reports, NoCategorizadosReportGenerator->new);
	# Browsers report
	push (@reports, BrowserReportGenerator->new(field => 'c-agent'));
	
	# Clientes unicos
	push (@reports, SimpleReportGenerator->new(field => 'cs-username', file_name => 'clients.json' ));
	return @reports;
}