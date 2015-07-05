# NAME

Time::Ago - Approximate duration in words

# VERSION

version 0.01

# SYNOPSIS

    use Time::Ago;

    print Time::Ago->in_words(0), "\n";
    # 0 seconds ago, prints "less than 1 minute";

    print Time::Ago->in_words(3600 * 4.6), "\n";
    # 16,560 seconds ago, prints "about 5 hours";

# DESCRIPTION

This a Perl port of the time\_ago\_in\_words() helper from Rails.
Given a duration, in seconds, it returns a readable approximation.

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

# NAME

Time::Ago - Approximate duration in words

# METHODS

- in\_words 

        Time::Ago->in_words(30); # returns "1 minute"
        Time::Ago->in_words(60 * 60 * 24 * 365 * 10); # returns "about 10 years"

    Given a duration, in seconds, returns a readable approximation in words.

    As a convenience, if the duration is an object with an epoch() interface
    (as provided by Time::Piece or DateTime), the duration is computed as the
    current time minus the object's epoch() seconds.

# BUGS

There is some rudimentary locale support but currently only English is
implemented. It should be changed to use a real locale package, but not
sure what a good Perl module is for that currently.

The rails' implementation includes logic for leap years depending on the
parameters supplied. We have no equivalent support although it would be
simple to add if anyone cares.

# CREDITS

Ruby on Rails DateHelper
[http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance\_of\_time\_in\_words](http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance_of_time_in_words)

# AUTHOR

Maurice Aubrey

# SEE ALSO

Github repository [https://github.com/mla/time-ago](https://github.com/mla/time-ago)

[Time::Duration](https://metacpan.org/pod/Time::Duration)

# LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

# AUTHOR

Maurice Aubrey <maurice.aubrey@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Maurice Aubrey.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
