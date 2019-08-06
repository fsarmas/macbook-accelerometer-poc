#!/usr/bin/perl

use strict;
use Time::HiRes "usleep";
$|++;                  # Flush buffer after every write

use constant PREC     => 10;     # Precision
use constant STEP     => 100000; # Microseconds between each time step
use constant WIDTH    => 75;     # Width of floor in characters
use constant FRICTION => 1;      # Speed will decrease in that number each step

my $POSITION_FILE = $ARGV[0];
(my $X, my $Y, my $Z) = get_position();
my $POS   = int(WIDTH / 2);
my $FLOOR = 0;
my $SPEED = 0;

my @level = [ [1,10],
              [11,21],
              [70],
              [2],
              [36],
              [35, 74],
              [1,10],
              [11,21] ];

while (1) {
  system("clear");
  print_level($FLOOR, $POS, @level);
  detect_completed($FLOOR, @level);
  $FLOOR++ if detect_gap($POS, $FLOOR, @level);
  $SPEED += 2*get_movement($X, $Y, $Z);
  $SPEED -= FRICTION if $SPEED > 0;
  $SPEED += FRICTION if $SPEED < 0;
  $POS += $SPEED;
  if ($POS < 0) {
    $POS = 0;
    $SPEED = 0;
  } elsif ($POS >= WIDTH) {
    $POS = WIDTH - 1 ;
    $SPEED = 0;
  }
  usleep(STEP);
}

sub detect_completed {
  (my $floor, my $level_r) = @_;
  if ($floor >= @{$level_r}) {
    print "Congratulations! You got it.\n";
    exit(0);
  }
}

sub get_movement {
  (my $x, my $y, my $z) = get_position();

  if ($x - $X > 2 * PREC) {    # Left movement
    return -1;
  }
  elsif ($x - $X < -2 * PREC) {    # Right movement
    return 1;
  }
  else {
    return 0;
  }
}

sub detect_gap {
  (my $pos, my $floor, my $level_r) = @_;
  my @level = @{$level_r};
  return 1 if in_array($level[$floor], $pos);
}

sub print_level {
  (my $y, my $x, my $level_r) = @_;
  my @level = @{$level_r};
  for (my $i = 0 ; $i < scalar @level ; $i++) {
    my $pos = ($i == $y ? $x : -1);
    print_line($level[$i], $pos);
    print "\n";
  }
}

sub print_line {
  (my $gaps_r, my $pos) = @_;
  print "|";
  for (my $i = 0 ; $i < WIDTH ; $i++) {
    if ($i == $pos) {
      print "O";
    }
    elsif (in_array($gaps_r, $i)) {
      print " ";
    }
    else {
      print "_";
    }
  }
  print "|";
}

sub get_position {
  my $filename = $POSITION_FILE || "/sys/devices/platform/applesmc.768/position";
  open(FILE, $filename) or die($! . ' -> ' . $filename);
  my $line = <FILE>;
  $line =~ /^\((.+),(.+),(.+)\)$/;
  close(FILE);
  my $x = int($1 / PREC) * PREC;
  my $y = int($2 / PREC) * PREC;
  my $z = int($3 / PREC) * PREC;

  return $x, $y, $z;
}

sub in_array {
  (my $array_r, my $element) = @_;
  my @array = @{$array_r};
  foreach (@array) {
    return 1 if $_ == $element;
  }
  return 0;
}

