#!/usr/bin/perl

use strict;
use POSIX qw(strftime);
use CGI;
use JSON::PP;
use HTML::Entities;

# Set webserver's environment variable DATALIB to somewhere safe to store data files.

my $classfile = "$ENV{'DATALIB'}/classfile.tsv";
my $logfile = "$ENV{'DATALIB'}/logfile.txt";

    my $q = CGI->new;

    print $q->header("application/json");
    my $s = $q->param('s');
    my $c = $q->param('c');

    my ($nusnet, $time, $sig) = split(/;/, $s);
    $nusnet = uc $nusnet;

    my $ltime = localtime($time);

    my $nusnet_ = encode_entities($nusnet);
    my $s_ = encode_entities($s);
    my $status = 0;
    my $html = <<EOM;
<h3>Verify Status</h3>
EOM

    my $name_;
    my $extra;

    open CLASSFILE, "<$classfile" || die;
    while (<CLASSFILE>) {
        chomp;
        my @args = split/\t/;
        if ($args[0] eq $nusnet) {
            $name_ = encode_entities($args[1]);
            $extra = $args[2];
            last;
        }
    }
    close CLASSFILE;

    if (!defined $name_) {
        $html .= <<EOM;
<p>NUSNET ID: $nusnet_</p>
<p style="color: red; font-weight: bold;">*NOT FOUND*</p>
<button data-role="button" class="ui-button" id="cb-clear">Clear</button>
EOM
        $status = -1;
    }
    elsif (!$c) {
        $html .= <<EOM;
<p>NUSNET ID: $nusnet_ ($name_)</p>
<img src="$extra" alt="" />
<button data-role="button" class="ui-button" id="cb-confirm">CONFIRM</button>
<button data-role="button" class="ui-button" id="cb-clear">Clear</button>
<button hidden="hidden" name="cb-content" id="cb-content" value="$s_" />
EOM
    }
    else {
        open LOGFILE, ">>$logfile" || die;
        my $time_str =  strftime "%b %d %T", localtime;
        print LOGFILE "$time_str - $nusnet_\n";
        close LOGFILE;
        $html .= <<EOM;
<p>CONFIRMED: $nusnet_ ($name_)</p>
<button data-role="button" class="ui-button" id="cb-clear">Clear</button>
EOM
        status => 0
    }

    my $r = {
        html => $html,
        status => $status 
    };

    my $json = JSON::PP->new->ascii->pretty->allow_nonref;

    print $json->encode($r);
