#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes "usleep";
use Term::ReadKey;

ReadMode 4;
$|++;

use constant STEP    => 5;
use constant MS_IN_S => 1000000;

my $FILE = $ARGV[0] || '/tmp/position';
my $X = 0;
my $Y = 0;
my $Z = 0;

print "Use left and right arrows to update horizontal tilt. Press 'q' to exit.\n";
print_pos();

my $key;

while (1) {
  if (defined($key = ReadKey(-1))) {

    if ('q' eq $key) {
      update(0, 0, 0);
      print_pos();
      print "\nBye\n";
      last;
    }
    elsif (27 == ord($key)) {
      ReadKey(-1);
      my $other = ReadKey(-1);
      if (68 == ord($other)) {
        update($X + STEP, $Y, $Z);
      }
      else {
        update($X - STEP, $Y, $Z);
      }
      print_pos();
    }

  }

  usleep(0.1 * MS_IN_S);
}

ReadMode(0);

sub print_pos {
  print "\r(${X}, ${Y}, ${Z})    ";
}

sub update {
  ($X, $Y, $Z) = @_;
  my $line = "($X, $Y, $Z)\n";
  my $fh;
  if (!open($fh, '>', $FILE)) {
  	ReadMode(0);
  	die "\nCould not open file '$FILE' $!"
  };
  print $fh $line;
  close $fh;
}
