#!/usr/bin/perl -wnl

next unless /(..).*\1/;
next unless /(.).\1/;

print $_;
$count++;

END{print $count}