package MLA::Time::InWords;
# ABSTRACT: Convert duration in seconds to approximate time in words

# Port of Rails distance_of_time_in_words and time_ago_in_words
# http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance_of_time_in_words

use strict;
use warnings;
use v5.14;
no  warnings 'experimental::smartmatch';
use Carp;
use Lingua::EN::Inflexion qw/ noun /;
use Scalar::Util qw/ blessed /;

our $VERSION = '0.01';

use constant {
  MINUTES_IN_QUARTER_YEAR        => 131400, # 91.25 days
  MINUTES_IN_THREE_QUARTERS_YEAR => 394200, # 273.75 days
  MINUTES_IN_YEAR                => 525600,
};


sub new {
  my $class = shift;

  $class = ref($class) || $class;
  my $self = bless {}, $class;

  while (@_) {
    my ($method, $val) = splice @_, 0, 2;
    $self->$method(ref $val eq 'ARRAY' ? @$val : $val);
  }

  return $self;
}


{
  use Lingua::EN::Inflexion qw/ noun /;

  my $pluralize = sub {
    my $word = noun($_[0]);
    return $_[1] == 1 ? $word->singular : $word->plural;
  };

  my %en = (
    about_x_hours => sub {
      "about $_[0]", $pluralize->('hour', $_[0])
    },

    about_x_months => sub {
      "about $_[0]", $pluralize->('month', $_[0])
    },

    about_x_years => sub {
      "about $_[0]", $pluralize->('year', $_[0])
    },

    almost_x_years => sub {
      "almost $_[0]", $pluralize->('year', $_[0])
    },

    half_a_minute => sub { 'half a minute' },

    less_than_x_minutes => sub {
      "less than $_[0]", $pluralize->('minute', $_[0]) 
    },

    less_than_x_seconds => sub {
      "less than $_[0]", $pluralize->('second', $_[0]) 
    },

    over_x_years => sub {
      "over $_[0]", $pluralize->('year', $_[0]) 
    },

    x_days => sub {
      $_[0], $pluralize->('day', $_[0])
    },

    x_minutes => sub {
      $_[0], $pluralize->('minute', $_[0])
    },

    x_months => sub {
      $_[0], $pluralize->('month', $_[0])
    },
  );

  my $en_locale = sub {
    my $string_id = shift;
    my %args = @_;

    my $sub = $en{ $string_id }
      or croak "unknown locale string id '$string_id' for english";
    return join ' ', $sub->($args{count});
  };

  sub locale {
    my $self = shift;

    return $en_locale unless blessed $self;

    $self->{locale} = shift // $en_locale if @_;
    return $self->{locale} // $en_locale;
  }
}


sub distance_of_time_in_words {
  my $self = shift;
  my %args = (@_ % 2 ? (from_time => @_) : @_);

  defined $args{from_time} or croak 'no from_time supplied';
  $args{to_time} //= 0;

  my $from_time = abs $args{from_time};
  my $to_time = abs $args{to_time};

  # If either is an object, try to convert to epoch seconds
  foreach ($from_time, $to_time) {
    next unless blessed $_;

    if ($_->can('epoch')) {
      $_ = $_->epoch;
    }
  }

  ($from_time, $to_time) = ($to_time, $from_time) if $from_time > $to_time;

  my $round = sub { int($_[0] + 0.5) };

  my $diff = $to_time - $from_time;
  my $minutes = $round->($diff / 60);
  my $seconds = $round->($diff);

  my $locale = $self->locale;

  foreach ($minutes) {
    when ([0..1]) {
      unless ($args{include_seconds}) {
        return $minutes == 0 ?
          $locale->('less_than_x_minutes', count => 1) :
          $locale->('x_minutes', count => $minutes)
        ;
      }

      foreach ($seconds) {
        return $locale->('less_than_x_seconds', count => 5)  when ([0..4]);
        return $locale->('less_than_x_seconds', count => 10) when ([5..9]);
        return $locale->('less_than_x_seconds', count => 20) when ([10..19]);
        return $locale->('half_a_minute', count => 20)       when ([20..39]);
        return $locale->('less_than_x_minutes', count => 1)  when ([40..59]);
        return $locale->('x_minutes', count => 1);
      }
    }

    when ([2..44]) {
      return $locale->('x_minutes', count => $minutes);
    }

    when ([45..89]) {
      return $locale->('about_x_hours', count => 1);
    }

    # 90 mins up to 24 hours
    when ([90..1439]) {
      return $locale->('about_x_hours', count => $round->($minutes/60.0));
    }

    # 24 hours up to 42 hours
    when ([1440..2519]) {
      return $locale->('x_days', count => 1);
    }

    # 42 hours up to 30 days
    when ([2520..43199]) {
      return $locale->('x_days', count => $round->($minutes / 1440));
    }

    # 30 days up to 60 days
    when ([43200..86399]) {
      return $locale->('about_x_months', count => $round->($minutes / 43200));
    }

    # 60 days up to 365 days
    when ([86400..525600]) {
      return $locale->('x_months', count => $round->($minutes / 43200));
    }

    default {
      # XXX does not implement leap year stuff that Rails implementation has

      my $remainder = $minutes % MINUTES_IN_YEAR;
      my $years = int($minutes / MINUTES_IN_YEAR);

      if ($remainder < MINUTES_IN_QUARTER_YEAR) {
        return $locale->('about_x_years', count => $years);
      }

      if ($remainder < MINUTES_IN_THREE_QUARTERS_YEAR) {
        return $locale->('over_x_years', count => $years);
      }
   
      return $locale->('almost_x_years', count => $years + 1); 
    }
  }
}


sub time_ago_in_words {
  my $self = shift;

  $self->distance_of_time_in_words(@_, to_time => 0);
}

1;

__END__

=pod

=head1 NAME

MLA::Time::InWords - Convert duration in seconds to approximate time in words

=head1 SYNOPSIS

  use MLA::Time::InWords;

  print MLA::Time::InWords->time_ago_in_words(0), "\n";
  # 0 seconds ago, prints "less than 1 minute";

  print MLA::Time::InWords->time_ago_in_words(3600 * 4.6), "\n";
  # 16,560 seconds ago, prints "about 5 hours";

=head1 DESCRIPTION

This a Perl port of the time_ago_in_words() method from Rails.

Given a duration, in seconds, it returns the approximate duration in words.

From Rails' docs:

  0 <-> 29 secs
    less than a minute

  30 secs <-> 1 min, 29 secs
    1 minute

  1 min, 30 secs <-> 44 mins, 29 secs
    [2..44] minutes

  44 mins, 30 secs <-> 89 mins, 29 secs
    about 1 hour

  89 mins, 30 secs <-> 23 hrs, 59 mins, 29 secs
    about [2..24] hours

  23 hrs, 59 mins, 30 secs <-> 41 hrs, 59 mins, 29 secs
    1 day

  41 hrs, 59 mins, 30 secs <-> 29 days, 23 hrs, 59 mins, 29 secs
    [2..29] days

  29 days, 23 hrs, 59 mins, 30 secs <-> 44 days, 23 hrs, 59 mins, 29 secs
    about 1 month

  44 days, 23 hrs, 59 mins, 30 secs <-> 59 days, 23 hrs, 59 mins, 29 secs
    about 2 months

  59 days, 23 hrs, 59 mins, 30 secs <-> 1 yr minus 1 sec
    [2..12] months

  1 yr <-> 1 yr, 3 months
    about 1 year

  1 yr, 3 months <-> 1 yr, 9 months
    over 1 year

  1 yr, 9 months <-> 2 yr minus 1 sec
    almost 2 years

  2 yrs <-> max time or date
    (same rules as 1 yr)

=head1 METHODS

=over 4

=item new

  MLA::Time::InWords->new(%options);

Creates a new MLA::Time::InWords object.

=item distance_of_time_in_words 

  MLA::Time::InWords->distance_of_time_in_words(
    from_time => time - 60,
    to_time => time,
    %options,
  );

Returns the duration in seconds, to_time - from_time, as words.

=item time_ago_in_words

  MLA::Time::InWords->time_ago_in_words(
    from_time => time - 60,
    %options,
  );

Same as distince_of_time_in_words except the current time is used 
as the to_time value.

=back

=head1 BUGS

There is some basic locale support but currently only
English is supported. Should be changed to use a real locale package, but not
sure what the best Perl module is for that currently.

=head1 CREDITS

Ruby on Rails
L<http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance_of_time_in_words>

=head1 AUTHOR

Maurice Aubrey

=head1 SEE ALSO

Github repository L<https://github.com/mla/mla-time-inwords>

L<Time::Duration>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut 
