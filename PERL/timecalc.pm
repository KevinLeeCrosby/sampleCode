package gmt; # days, hours, minutes, seconds, and milliseconds

use strict;
use POSIX qw(floor ceil);


use overload
        '+' => '_add',
        '-' => '_subtract',
      'neg' => '_negate',
      'abs' => '_absolute',
       '==' => '_equal',
       '!=' => '_not_equal',
        '<' => '_less_than',
       '<=' => '_less_than_or_equal',
        '>' => '_greater_than',
       '>=' => '_greater_than_or_equal',
       'eq' => '_equal',
       'ne' => '_not_equal',
       'lt' => '_less_than',
       'le' => '_less_than_or_equal',
       'gt' => '_greater_than',
       'ge' => '_greater_than_or_equal',
      q("") => '_quote',
        '!' => '_units',
        '~' => '_append_units',
        '=' => '_clone',
 'fallback' =>  undef;


my $units = "GMT";


sub _units {
  my ($vector,$argument,$flag) = @_;
  my ($class) = ref($vector) || $vector;
  my ($units) = $class->units();

  return($units);
}


sub units {
  return $units;
}


sub _append_units {
  my ($vector,$argument,$flag) = @_;
  my ($class) = ref($vector) || $vector;
  my ($cunits) = $class->cunits();
  my ($s) = sprintf "%s %s", $vector, $cunits;

  return($s);
}


sub cunits { # center units
  my ($vector,$argument,$flag) = @_;
  my ($class) = ref($vector) || $vector;
  my ($units) = $class->units();
  my ($whitespace) = 5 - length($units);
  my ($head) = ceil($whitespace/2);
  my ($tail) = floor($whitespace/2);
  my ($s) = sprintf "%s%s%s", (" " x $head), $units, (" " x $tail);

  return($s);
}



sub modvector {
  my ($vector) = shift;
  my ($temp) = $vector->new(365, 24, 60, 60, 1000);
  return($temp);
}


sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $vector = [ ];
 
  while ( @_ < 5 ) {
    unshift @_, 0;
  }

  $#$vector = 5 - 1; # Lengthens the array
  for (my $i = 0; $i < 5; $i++) {
    $vector->[$i] = $_[$i];
  }
  
  #print "Creating new vector [@$vector].\n\n";
  
  bless($vector, $class);

  return($vector);
}


sub newstr {
  my $proto  = shift;
  my $class  = ref($proto) || $proto;
  my $string = shift;
  $string =~ s/^[^.?\d]+//g; # remove leading garbage
  $string =~ s/\D+$//g;      # remove trailing garbage
  my @array = split /\D+/, $string;
  my @array2 = split /(\D+)/, $string;

  my $vector = $class->new(@array);
  
  $vector->justify()
    if (( @array == 2 || $array2[-4] ne '.' ) && $array2[-2] eq '.');
  # for thousandths, milliseconds with single decimal point

  $vector = $vector + $vector->new(); # adjust units by adding to zero

  return($vector);
}


sub copy
{
    my ($b,$a) = @_;

    for (my $i = 0; $i < 5; $i++) {
      $b->[$i] = $a->[$i];
    }

    #my $r1 = []; # New array ref
    #my $r2 = $a->[0];
    ##   my $r2 = $a;
    #@$r1 = @$r2; # Copy whole array directly
    #$b->[0] = $r1;
    ##   $b = $r1;
}


sub _clone
{
    my ($vector,$argument,$flag) = @_;
#   my ($name) = "'='"; #&_trace($name,$vector,$argument,$flag);
    my ($temp);

    $temp = $vector->new(0,0,0,0,0);
    $temp->copy($vector);
    return($temp);
}


sub clone {
  my ($vector) = @_;
  my ($temp);
  
  $temp = $vector->new(0,0,0,0,0);
  $temp->copy($vector);
  return($temp);
}


sub _quote {
  my ($vector,$argument,$flag) = @_;
  my ($s);
  my ($mod) = $vector->modvector()->[4];
  my ($temp) = $vector->clone();

  $temp->[4] = floor($temp->[4] + 0.5);

  if ($temp->[4] >= $mod) {
    my ($one_second) = $temp->new(qw(00 00 00 01 00));
    $temp->[4] -= $mod * floor($temp->[4] / $mod);
    #$temp->[4] = $temp->[4] % $mod;
    $temp += $one_second;
  }

  $s = sprintf('%03d', $temp->[0]);
  for ( my $i = 1; $i < 4; $i++) {
    $s .= sprintf(':%02d', $temp->[$i]);
  }
  $s .= sprintf('.%03.0f', $temp->[4]);
  return($s);
}


sub _add {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'+'"; #&_trace($name,$vector,$argument,$flag);
  my ($temp);
  
  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    if (defined $flag) {
      $temp = $vector->new(0,0,0,0,0);
      $temp->add($vector,$argument);
      return($temp);
    }
    else {
      $vector->add($vector,$argument);
      return($vector);
    }
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub add {
  my ($c, $a, $b) = @_;
  my ($temp, $q);

  $temp=$c->modvector();

  $c->[4] = $a->[4] + $b->[4];
  for (my $i = 3; $i >= 0; $i--) {
    $q = floor($c->[$i+1] / $temp->[$i+1]);
    #$c->[$i] = $a->[$i] + $b->[$i] + floor($c->[$i+1] / $temp->[$i+1]);
    #$c->[$i+1] = $c->[$i+1] % $temp->[$i+1];
    $c->[$i] = $a->[$i] + $b->[$i] + $q;
    $c->[$i+1] -= $temp->[$i+1] * $q;
  }
  $q = floor($c->[0] / $temp->[0]);
  #$c->[0] = $c->[0] % $temp->[0];
  $c->[0] -= $temp->[0] * $q;
}


sub _subtract {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'-'"; #&_trace($name,$vector,$argument,$flag);
  my ($temp);

  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    if (defined $flag) {
      $temp = $vector->new(0,0,0,0,0);
      $temp->subtract($vector,$argument);
      return($temp);
    }
    else {
      $vector->subtract($vector,$argument);
      return($vector);
    }
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub subtract {
  my ($c, $a, $b) = @_;
  my ($temp, $q);

  $temp=$c->modvector();

  $c->[4] = $a->[4] - $b->[4];
  for (my $i = 3; $i >= 0; $i--) {
    $q = floor($c->[$i+1] / $temp->[$i+1]);
    #$c->[$i] = $a->[$i] - $b->[$i] + floor($c->[$i+1] / $temp->[$i+1]);
    #$c->[$i+1] = $c->[$i+1] % $temp->[$i+1];
    $c->[$i] = $a->[$i] - $b->[$i] + $q;
    $c->[$i+1] -= $temp->[$i+1] * $q;
  }
  $q = floor($c->[0] / $temp->[0]);
  #$c->[0] = $c->[0] % $temp->[0];
  $c->[0] -= $temp->[0] * $q;
}


sub _negate {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "neg"; #&_trace($name,$object,$argument,$flag);

  my ($temp) = $vector->new(0,0,0,0,0);
  $temp = $temp->negate($vector);

  return($temp);
}


sub negate {
  my ($b, $a) = @_;
  my ($zero) = $a->new(0,0,0,0,0);

  $b = $zero - $a;
}


sub _absolute {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "abs"; #&_trace($name,$object,$argument,$flag);

  my ($temp) = $vector->new(0,0,0,0,0);
  $temp = $temp->absolute($vector);

  return($temp);
}


sub absolute {
  my ($b, $a) = @_;

  $b = ( $a <= -$a ? $a : -$a ); # biased toward smaller times (closer to 0).
}


sub _equal {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'=='"; #&_trace($name,$object,$argument,$flag);
  my ($temp);

  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    $temp = $vector->equal($vector,$argument);
    return($temp);
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub equal {
  my ($c, $a, $b) = @_;
  my ($i) = 0;

  do {
    $c = ($a->[$i] == $b->[$i]);
  } until (!$c || ++$i > 4);

  return ($c);
}


sub _not_equal {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'!='"; #&_trace($name,$object,$argument,$flag);
  my ($temp);

  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    $temp = $vector->not_equal($vector,$argument);
    return($temp);
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub not_equal {
  my ($c, $a, $b) = @_;
  my ($i) = 0;

  do {
    $c = ($a->[$i] != $b->[$i]);
  } until ($c || ++$i > 4);

  return ($c);
}


sub _less_than {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'<'"; #&_trace($name,$object,$argument,$flag);
  my ($temp);

  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    $temp = $vector->less_than($vector,$argument);
    return($temp);
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub less_than {
  my ($c, $a, $b) = @_;
  my ($i) = 0;

  do {
    $c = ($a->[$i] < $b->[$i]);
  } until ($a->[$i] != $b->[$i] || ++$i > 4);

  return ($c);
}


sub _less_than_or_equal {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'<='"; #&_trace($name,$object,$argument,$flag);
  my ($temp);

  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    $temp = $vector->less_than_or_equal($vector,$argument);
    return($temp);
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub less_than_or_equal {
  my ($c, $a, $b) = @_;
  my ($i) = 0;

  do {
    $c = ($a->[$i] <= $b->[$i]);
  } until ($a->[$i] != $b->[$i] || ++$i > 4);

  return ($c);
}


sub _greater_than {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'>'"; #&_trace($name,$object,$argument,$flag);
  my ($temp);

  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    $temp = $vector->greater_than($vector,$argument);
    return($temp);
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub greater_than {
  my ($c, $a, $b) = @_;
  my ($i) = 0;

  do {
    $c = ($a->[$i] > $b->[$i]);
  } until ($a->[$i] != $b->[$i] || ++$i > 4);

  return ($c);
}


sub _greater_than_or_equal {
  my ($vector,$argument,$flag) = @_;
  my ($name) = "'>='"; #&_trace($name,$object,$argument,$flag);
  my ($temp);

  if ((defined $argument) && ref($argument) &&
      (ref($argument) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/)) {
    ($vector, $argument) = $vector->resolve($argument);
    $temp = $vector->greater_than_or_equal($vector,$argument);
    return($temp);
  }
  else {
    die "Vector $name: wrong argument type";
  }
}


sub greater_than_or_equal {
  my ($c, $a, $b) = @_;
  my ($i) = 0;

  do {
    $c = ($a->[$i] >= $b->[$i]);
  } until ($a->[$i] != $b->[$i] || ++$i > 4);

  return ($c);
}


sub resolve {
  my ($a, $b) = @_;
  my ($ca) = ref($a) || $a;
  my ($cb) = ref($b) || $b;
  my ($ta) = $a->clone();
  my ($tb) = $b->clone();

  $ca->isa($cb) ? ($ta = $a->convert($cb)) : ($tb = $b->convert($ca))
    unless $ca eq $cb;

  return ($ta, $tb)
}


sub convert {
  my ($vector, $argument) = @_;
  $argument = 'gmt' unless defined $argument;
  my ($class) = ref($vector) || $vector;
  my ($newclass) = ref($argument) || $argument;
  my ($moda) = $class->modvector()->[4];
  my ($modb) = $newclass->modvector()->[4];
  my ($temp) = $vector->clone();

  bless($temp, $newclass);

  if ($moda != $modb) {
    $temp->[4] = $temp->[4] / $moda * $modb;
    if ($temp->[4] >= $modb) {
      my ($one_second) = $newclass->new(qw(00 00 00 01 00));
      $temp->[4] -= $modb * floor($temp->[4] / $modb);
      #$temp->[4] = $temp->[4] % $modb;
      $temp += $one_second;
    }
  }

  return ($temp);
}


sub getseconds {
  my ($a) = shift;
  my ($temp);

  $temp=$a->modvector();

  my ($sum) = $a->[0];

  for (my $i = 1; $i < 4; $i++) {
    $sum = $sum * $temp->[$i] + $a->[$i];
  }
  $sum += $a->[4] / $temp->[4]; # account for fractional seconds

  return ($sum);
}


sub justify {
  my ($a) = shift;
  my ($ms) = $a->[4];

  $a->[4] = $ms * 10**(3 - length($ms)); # add trailing zeros if necessary
}


##############################################################################

package vigmt; # days, hours, minutes, seconds, and milliseconds

use base ("gmt"); # inherit properties of other class

use strict;
#use POSIX qw(floor ceil);


my $units = "viGMT";


sub units {
  return $units;
}


##############################################################################


package tcr; # days, hours, minutes, seconds, and frames

use base ("vigmt"); # inherit properties of other class

use strict;
use POSIX qw(floor ceil);


my $units = "TCR";


sub units {
  return $units;
}


sub modvector {
  my ($vector) = shift;
  my ($temp) = $vector->new(365, 24, 60, 60, 29.97);
  return($temp);
}


sub _quote {
  my ($vector,$argument,$flag) = @_;
  my ($s);
  my ($mod) = floor($vector->modvector()->[4] + 0.5); # round modulus
  my ($temp) = $vector->clone();

  $temp->[4] = floor($temp->[4] + 0.5);

  if ($temp->[4] >= $mod) {
    my ($one_second) = $temp->new(qw(00 00 00 01 00));
    $temp->[4] -= $mod * floor($temp->[4] / $mod);
    #$temp->[4] = $temp->[4] % $mod;
    $temp += $one_second;
  }
  
  $s = sprintf('%03d', $temp->[0]);
  for ( my $i = 1; $i < 4; $i++) {
    $s .= sprintf(':%02d', $temp->[$i]);
  }
  $s .= sprintf(':%02df', $temp->[4]);
  return ($s);
}


sub getframes {
  my ($a) = shift;
  my ($temp);

  $temp=$a->modvector();

  my ($sum) = $a->[0];

  for (my $i = 1; $i < 5; $i++) {
    $sum = $sum * $temp->[$i] + $a->[$i];
  }
  $sum = floor($sum + 0.5); # round

  return ($sum);
}


sub justify {
  my ($a) = shift; # no justification necessary for frames
}


##############################################################################

package input; # 

use base ("tcr"); # inherit properties of other class

use strict;

sub newstr {
  my $proto  = shift;
  my $string = shift;
  my @array = split /(\D+)/, $string;
  my $class = q(gmt); # default class

  $class = q(vigmt) if $array[-1] =~ /^\s*v/i;
  $class = q(tcr) if $array[-1] =~ /^\s*[ft]/i;

  my $vector = $class->newstr($string);

  return($vector);
}





##############################################################################

1; # return true so programs can "use" this
