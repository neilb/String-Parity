package String::Parity;

use strict;
use vars qw(
    $VERSION $Version $Revision
    @ISA @EXPORT @EXPORT_OK
    $even_parity $odd_parity $show_parity
);

require Exporter;

@ISA = qw(Exporter);

$Version = $VERSION = "1.31";
($Revision = substr(q$Revision: 1.7 $, 10)) =~ s/\s+$//;

@EXPORT = qw(
    setEvenParity setOddParity
    setMarkParity setSpaceParity
    EvenBytes OddBytes
    MarkBytes SpaceBytes
    isEvenParity isOddParity
    isMarkParity isSpaceParity
);

@EXPORT_OK = qw(
    showParity showMarkSpace
    $even_parity $odd_parity
    $show_parity $even_codes
);

my $even_bits = "\0";
my $odd_bits = "\200";
foreach (0 .. 7) {
    $even_bits .= $odd_bits;
    ($odd_bits = $even_bits) =~ tr/\0\200/\200\0/;
}

my $codes = pack('C*', (0 .. 255));
($even_parity = $codes ^ $even_bits) =~ s/(\W)/sprintf('\%o', ord $1)/eg;
($odd_parity = $codes ^ $odd_bits) =~ s/(\W)/sprintf('\%o', ord $1)/eg;
($show_parity = $even_bits) =~ tr /\0\200/eo/;

my $even_codes = '';
while ($even_bits =~ /\0/g) {
    $even_codes .= sprintf '\%o', (pos $even_bits) - 1;
}

eval <<EDQ;

    sub setEvenParity {
	my(\@s) = \@_;
	foreach (\@s) {
	    tr/\\0-\\377/$even_parity/;
	}
	wantarray ? \@s : join '', \@s;
    }

    sub setOddParity {
	my(\@s) = \@_;
	foreach (\@s) {
	    tr/\\0-\\377/$odd_parity/;
	}
	wantarray ? \@s : join '', \@s;
    }

    sub showParity {
	my(\@s) = \@_;
	foreach (\@s) {
	    tr/\\0-\\377/$show_parity/;
	}
	wantarray ? \@s : join '', \@s;
    }

    sub EvenBytes {
	my \$count = 0;
	foreach (\@_) {
	    \$count += tr/$even_codes//;
	}
	\$count;
    }

    sub OddBytes {
	my \$count = 0;
	foreach (\@_) {
	    \$count += tr/$even_codes//c;
	}
	\$count;
    }

EDQ
die $@ if $@;

sub isEvenParity {
    ! &OddBytes;
}

sub isOddParity {
    ! &EvenBytes;
}

sub setSpaceParity {
    my(@s) = @_;
    foreach (@s) {
	tr/\200-\377/\0-\177/;
    }
    wantarray ? @s : join '', @s;
}

sub setMarkParity {
    my(@s) = @_;
    foreach (@s) {
	tr/\0-\177/\200-\377/;
    }
    wantarray ? @s : join '', @s;
}

sub showMarkSpace {
    my(@s) = @_;
    foreach (@s) {
	tr/\0-\177/s/;
	tr/\200-\377/m/;
    }
    wantarray ? @s : join '', @s;
}

sub SpaceBytes {
    my $count = 0;
    foreach (@_) {
	$count += tr/\0-\177//;
    }
    $count;
}

sub MarkBytes {
    my $count = 0;
    foreach (@_) {
	$count += tr/\200-\377//;
    }
    $count;
}

sub isSpaceParity {
    ! &MarkBytes;
}

sub isMarkParity {
    ! &SpaceBytes;
}

1;

__END__

=head1 NAME

String::Parity, setEvenParity, setOddParity, setSpaceParity, setMarkParity,
isEvenParity, isOddParity isSpaceParity, isMarkParity,
EvenBytes, OddBytes, SpaceBytes, MarkBytes,
showParity, showMarkSpace - Parity (odd/even/mark/space) handling functions

=head1 SYNOPSIS

    use String::Parity;
    use String::Parity qw(:DEFAULT /show/);

=head1 DESCRIPTION

=over 8

=item setEvenParity LIST

Copies the elements of LIST to a new list and converts the new elements to
strings of bytes with even parity. In array context returns the new list.
In scalar context joins the elements of the new list into a single string
and returns the string.

=item setOddParity LIST

Like setEvenParity function, but converts to strings with odd parity.

=item setSpaceParity LIST

Like setEvenParity function, but converts to strings with space
(High bit cleared) parity.

=item setMarkParity LIST

Like setEvenParity function, but converts to strings with mark
(High bit set) parity.

=item EvenBytes LIST

Returns the number of even parity bytes in the elements of LIST.

=item OddBytes LIST

Returns the number of odd parity bytes in the elements of LIST.

=item SpaceBytes LIST

Returns the number of space parity bytes in the elements of LIST.

=item MarkBytes LIST

Returns the number of mark parity bytes in the elements of LIST.

=item isEvenParity LIST

Returns TRUE if the LIST contains no byte with odd parity, FALSE otherwise.

=item isOddParity LIST

Returns TRUE if the LIST contains no byte with even parity, FALSE otherwise.

=item isSpaceParity LIST

Returns TRUE if the LIST contains no byte with mark parity, FALSE otherwise.

=item isMarkParity LIST

Returns TRUE if the LIST contains no byte with space parity, FALSE otherwise.

=item showParity LIST

Like setEvenParity function, but converts bytes with even parity to 'e'
and other bytes to 'o'.
The function showParity must be imported by a specialised import list.

=item showMarkSpace LIST

Like setEvenParity function, but converts bytes with space parity to 's'
and other bytes to 'm'.
The function showMarkSpace must be imported by a specialised import list.

=back

=head1 NOTES

Don't use this module unless you have to communicate with some old device
or protocol. Please make your application 8 bit clean and use the
internationally standardised ISO-8859-1 character set.

=head1 AUTHOR

Winfried Koenig <win@in.rhein-main.de>

=head1 SEE ALSO

perl(1), Exporter(1)

=cut
