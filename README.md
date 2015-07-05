# SYNOPSIS

    use MLA::Time::InWords;

    print MLA::Time::InWords->time_ago_in_words(0), "\n";
    # 0 seconds ago, prints "less than 1 minute";

    print MLA::Time::InWords->time_ago_in_words(3600 * 4.6), "\n";
    # 16,560 seconds ago, prints "about 5 hours";

# DESCRIPTION

This a Perl port of the time\_ago\_in\_words() method from Rails.

Given a duration, in seconds, it returns the approximate duration in words.

From the Rail's docs:

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

# METHODS

- new

        MLA::Time::InWords->new(%options);

    Creates a new MLA::Time::InWords object.

- distance\_of\_time\_in\_words 

        MLA::Time::InWords->distance_of_time_in_words(
          from_time => time - 60,
          to_time => time,
          %options,
        );

    Returns the duration in seconds, to\_time - from\_time, as words.

- time\_ago\_in\_words

        MLA::Time::InWords->time_ago_in_words(
          from_time => time - 60,
          %options,
        );

    Same as distince\_of\_time\_in\_words except the current time is used 
    as the to\_time value.

# BUGS

There is some basic locale support but currently only
English is supported. Should be changed to use a real locale package, but not
sure what the best Perl module is for that currently.

# CREDITS

Ruby on Rails
[http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance\_of\_time\_in\_words](http://apidock.com/rails/v4.2.1/ActionView/Helpers/DateHelper/distance_of_time_in_words)

# AUTHOR

Maurice Aubrey
