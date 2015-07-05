package Time::Ago;
# ABSTRACT: Approximate duration in words

# Port of Rails distance_of_time_in_words and time_ago_in_words
# http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance_of_time_in_words

use strict;
use warnings;
use Carp;
use Scalar::Util qw/ blessed /;

our $VERSION = '0.06';

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
  my $pluralize = sub {
    my $singular = shift;
    my $count    = shift;

    return 1 == $count ? $singular : "${singular}s";
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
      $_[0] == 1 ? 'less than a minute' : "less than $_[0] minutes";
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

    $self->{locale} = shift || $en_locale if @_;
    return $self->{locale} || $en_locale;
  }
}


sub in_words {
  my $self = shift;
  my %args = (@_ % 2 ? (duration => @_) : @_);

  defined $args{duration} or croak 'no duration supplied';
  my $duration = $args{duration}; 

  if (blessed $duration) {
    if ($duration->can('epoch')) {
      $duration = time - $duration->epoch;
    }
  }

  my $round = sub { int($_[0] + 0.5) };

  $duration = abs $duration;
  my $mins = $round->($duration / 60);
  my $secs = $round->($duration);

  my $locale = $args{locale} || $self->locale;

  if ($mins <= 1) {
    unless ($args{include_seconds}) {
      return $mins == 0 ?
        $locale->('less_than_x_minutes', count => 1) :
        $locale->('x_minutes', count => $mins)
      ;
    }

    return $locale->('less_than_x_seconds', count => 5)  if $secs <= 4;
    return $locale->('less_than_x_seconds', count => 10) if $secs <= 9;
    return $locale->('less_than_x_seconds', count => 20) if $secs <= 19;
    return $locale->('half_a_minute', count => 20)       if $secs <= 39;
    return $locale->('less_than_x_minutes', count => 1)  if $secs <= 59;
    return $locale->('x_minutes', count => 1);
  }

  return $locale->('x_minutes', count => $mins) if $mins <= 44;
  return $locale->('about_x_hours', count => 1) if $mins <= 89;

  # 90 mins up to 24 hours
  if ($mins <= 1439) {
    return $locale->('about_x_hours', count => $round->($mins/60));
  }

  # 24 hours up to 42 hours
  return $locale->('x_days', count => 1) if $mins <= 2519;

  # 42 hours up to 30 days
  return $locale->('x_days', count => $round->($mins / 1440)) if $mins <= 43199;

  # 30 days up to 60 days
  if ($mins <= 86399) {
    return $locale->('about_x_months', count => $round->($mins / 43200));
  }

  # 60 days up to 365 days
  if ($mins <= 525600) {
    return $locale->('x_months', count => $round->($mins / 43200));
  }

  # XXX does not implement leap year stuff that Rails implementation has

  my $remainder = $mins % MINUTES_IN_YEAR;
  my $years     = int($mins / MINUTES_IN_YEAR);

  if ($remainder < MINUTES_IN_QUARTER_YEAR) {
    return $locale->('about_x_years', count => $years);
  }

  if ($remainder < MINUTES_IN_THREE_QUARTERS_YEAR) {
    return $locale->('over_x_years', count => $years);
  }
  
  return $locale->('almost_x_years', count => $years + 1); 
}


1;

__END__

=pod

=head1 SYNOPSIS

  use Time::Ago;

  print Time::Ago->in_words(0), "\n";
  # 0 seconds ago, prints "less than 1 minute";

  print Time::Ago->in_words(3600 * 4.6), "\n";
  # 16,560 seconds ago, prints "about 5 hours";
  
=head1 DESCRIPTION

Given a duration, in seconds, returns a readable approximation.
This a Perl port of the time_ago_in_words() helper from Rails.

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

=item in_words 

  Time::Ago->in_words(30); # returns "1 minute"
  Time::Ago->in_words(3600 * 24 * 365 * 10); # returns "about 10 years"

Given a duration, in seconds, returns a readable approximation in words.

As a convenience, if the duration is an object with an epoch() interface
(as provided by Time::Piece or DateTime), the current time minus the
object's epoch() seconds is used.

=back

=head1 BUGS

There is some rudimentary locale support but currently only English is
implemented. It should be changed to use a real locale package, but not
sure what a good Perl module is for that currently.

The rails' implementation includes logic for leap years depending on the
parameters supplied. We have no equivalent support although it would be
simple to add if anyone cares.

=head1 CREDITS

Ruby on Rails DateHelper
L<http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance_of_time_in_words>

=head1 SEE ALSO

Github repository L<https://github.com/mla/time-ago>

L<Time::Duration>

=cut 
