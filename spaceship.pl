#!/usr/bin/perl

use strict;
use Time::HiRes "usleep";
$|++;    # Flush buffer after every write

use constant PREC          => 10;        # Precision
use constant STEP          => 300000;    # Microseconds between each time step
use constant WIDTH         => 75;        # Width of floor in characters
use constant HEIGHT        => 10;        # Height of game area in characters
use constant YPOS          => 2;         # Vertical position of the spaceship
use constant TIME          => 60;        # Total game time (in seconds)
use constant POSITION_FILE => $ARGV[0]
    ;  # Get accelerometer file from first program argument

my $ZERO_X = calibrate();         # Keep calibrated orientation for reference

use constant START => time();    # Keep initial timestamp in order to detect
                                 # end of game

run();

sub calibrate {
  print 'Calibrating. Put your laptop in flat position';
  for (my $i = 0 ; $i < 5 ; $i++) {
    print '.';
    usleep(500000);
  }
  print "\n";

  return (get_orientation())[0];
}

sub run {
  
  # Initialize empty array of enemies. There is at most one enemy per row,
  # at position $enemies[$i]. A value of -1 means no enemy in row.
  my @enemies;
  for (my $i = 0 ; $i < HEIGHT ; $i++) {
    $enemies[$i] = -1;
  }

  my $pos    = int(WIDTH / 2);   # Current horizontal position of spaceship
  my $points = 0;                # Current points

  while (1) {
    system("clear");
    $points += print_level($pos, @enemies);

    my $t = START + TIME - time();
    if ($t <= 0) {
      print "\nGame over. You got $points point(s)\n";
      exit();
    }
    else {
      printf("\n%2d:%2d - %d points\n", $t / 60, $t % 60, $points);
    }

    shift(@enemies);
    push(@enemies, int(rand(WIDTH - 1)));

    $pos += get_acceleration();
    $pos = 0         if $pos < 0;
    $pos = WIDTH - 1 if $pos >= WIDTH;

    usleep(STEP);
  }
}

sub print_level {
  (my $x, my @enemies) = @_;
  my $killed = 0;
  for (my $i = 0 ; $i < HEIGHT ; $i++) {
    my $pos = ($i == YPOS ? $x : -1);
    my $out = print_line($i, $pos, @enemies);
    $killed += $out;
    print "\n";
  }
  return $killed;
}

sub print_line {
  (my $num, my $pos, my @enemies) = @_;
  my $killed = 0;
  print "|";
  for (my $i = 0 ; $i < WIDTH ; $i++) {
    if ($enemies[$num] == $i) {
      if ($i != $pos) {
        print "*";
      }
      else {
        print "x";
        $killed++;
      }
    }
    elsif ($i == $pos) {
      print "v";
    }
    else {
      print " ";
    }
  }
  print "|";
  return $killed;
}

sub get_orientation {
  my $filename = POSITION_FILE || "/sys/devices/platform/applesmc.768/position";
  open(FILE, $filename) or die($! . ' -> ' . $filename);
  my $line = <FILE>;
  $line =~ /^\((.+),(.+),(.+)\)$/;
  close(FILE);
  my $x = $1;    #int$1/PREC);
  my $y = $2;    #int($2/PREC);
  my $z = $3;    #int($3/PREC);

  return $x, $y, $z;
}

sub get_acceleration {
  (my $x, my $y, my $z) = get_orientation();
  return int(($ZERO_X - $x) / PREC);
}
