package Class::Constant;

use warnings;
use strict;

our $VERSION = '0.01';

my %ordinal_for_data;
my %data_by_ordinal;

sub import {
    my ($pkg, @args) = @_;

    my $caller = caller;

    $ordinal_for_data{$caller} ||= 0;

    my $start_ordinal = $ordinal_for_data{$caller};

    my %data;
    my $value = 0;
    for my $arg (@args) {
        if ($arg =~ /^[A-Z-_]+$/) {
            if (exists $data{name}) {
                my %data_copy = %data;
                $data_by_ordinal{$caller}->[$data{ordinal}] = \%data_copy;
            }

            %data = ();

            $data{name} = $arg;

            $data{ordinal} = $ordinal_for_data{$caller};
            $ordinal_for_data{$caller}++;

            $data{object} = bless [ $caller, $data{ordinal} ], "Class::Constant::Value";

            $data{value} = $value;
            $value++;

            next;
        }

        $data{value} = $value = $arg;
        $value++;
    }

    if (exists $data{name}) {
        my %data_copy = %data;
        $data_by_ordinal{$caller}->[$data{ordinal}] = \%data_copy;
    }

    for my $ordinal ($start_ordinal .. $ordinal_for_data{$caller}-1) {
        my $data = $data_by_ordinal{$caller}->[$ordinal];

        do {
            no strict "refs";
            *{$caller."::".$data->{name}} = sub { $data->{object} };
        };
    }

    if ($start_ordinal == 0 and $ordinal_for_data{$caller} > 0) {
        do {
            no strict "refs";
            *{$caller."::by_ordinal"} = sub {
                return if @_ < 2;
                return $data_by_ordinal{$caller}->[$_[1]]->{object};
            };
        };
    }
}


package Class::Constant::Value;

use Scalar::Util qw(refaddr);

use overload
    q{""} => sub {
        return "$data_by_ordinal{$_[0]->[0]}->[$_[0]->[1]]->{value}";
    },
    q{==} => sub {
        return ref $_[0] and ref $_[1] and refaddr $_[0] == refaddr $_[1] ? 1 : 0;
    },
    q{!=} => sub {
        return ref $_[0] and ref $_[1] and refaddr $_[0] == refaddr $_[1] ? 0 : 1;
    };

sub get_ordinal {
    return $_[0]->[1];
}

1;

__END__

=head1 NAME

Class::Constant - Build constant classes

=head1 SYNOPSIS

=head1 DESCRIPTION

Class::Constant allows you to declaratively created so-called "constant
classes" (something like "typesafe enumerations" in Java).

The simplest example of creating a constant class is like so:

    package Direction;
    use Class::Constant NORTH, SOUTH, EAST, WEST;

You'd might then use this in your application like so:

    use Direction;
    
    my $facing = Direction::NORTH;
    
    ...

    if ($facing == Direction::SOUTH) {
        move_south();
    }

Each constant has an internal ordinal value. These values are unique
per-package, and are generated sequentially. So in the example above, the
constants would have the following ordinal values:

    NORTH   0
    SOUTH   1
    EAST    2
    WEST    3

You can get the ordinal value for a constant using the C<get_ordinal> method:

    my $ordinal = SOUTH->get_ordinal;

Additionally, you can get a constant value back given the ordinal value using
the C<by_ordinal> method:

    my $direction = Direction->by_ordinal(2);

By default, objects stringify to their ordinal value. You set your own string
for any given constant like so:

    use Class::Constant
        NORTH => "north",
        SOUTH => "south",
        EAST  => "east",
        WEST  => "west;

    ...

    print "You are facing $facing.\n";

=head1 AUTHOR

Robert Norris (rob@cataclysm.cx)

=head1 BUGS

This documentation probably sucks; I found it exceptionally difficult to
explain what I was trying to do here.

=head1 COPYRIGHT

Copyright (c) 2006 Robert Norris. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.
