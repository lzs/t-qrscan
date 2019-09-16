#!/usr/bin/perl

use CGI;
use JSON::PP;
use HTML::Entities;

    my $q = CGI->new;

    print $q->header("application/json");
    my $s = $q->param('s');
    my $c = $q->param('c');

    my ($nusnet, $time, $sig) = split(/;/, $s);

    my $ltime = localtime($time);

    my $s_ = encode_entities($s);
    my $html = '';

    if (!$c) {
        $html = <<EOM;
<p>Read from QR-code: $s_</p>
<button data-role="button" class="ui-button" id="cb-confirm">CONFIRM</button>
<button data-role="button" class="ui-button" id="cb-clear">Clear</button>
<input type="hidden" name="cb-content" id="cb-content" value="$s_" />
EOM
    }
    else {
        $html = <<EOM;
<p>CONFIRMED: $s_</p>
<button data-role="button" class="ui-button" id="cb-clear">Clear</button>
EOM
        status => 0
    }

    my $r = {
        html => $html,
        status => 0
    };

    $json = JSON::PP->new->ascii->pretty->allow_nonref;

    print $json->encode($r);
