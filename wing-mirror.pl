#!/usr/bin/perl

use strict;
use warnings;

goto phase2;

my $date = `date -d yesterday +%Y-%m-%d`;
my @refs = `git for-each-ref --sort="-committerdate" --format="%(committerdate:short) %(refname)" refs/remotes`;
# chomp @refs;
chomp $date;
@refs = grep $_ =~ /$date/, @refs;
$_ = (split)[1] foreach @refs;

# Get files modified in branches updated today
my @thisids = ();
my @thisfiles = ();
my @thisbranch = ();
foreach my $ref (@refs) {
  my @thisfile = `git --no-pager diff --name-only master...$ref -- *.java`;
  chomp @thisfile;
  foreach (@thisfile) {
    my $thispatchid = `git diff master...$ref -- $_ | git patch-id`;
    chomp $thispatchid;
    push @thisids, "$ref $thispatchid $_";
    push @thisfiles, $_;

  }
  push @thisbranch, $ref;
}
@thisfiles = sort @thisfiles;

# Get branches unmerged that are not stale
phase2:
my @thosebranches = `git branch -r --no-merged master`;
my @nonstale = ();
foreach(@thosebranches) {
  my @arr = split;
  my $var = $arr[$#arr];
#  $var = `git log -1 --oneline --source --since=two.weeks.ago $var`;
  $var = `git log -1 --oneline --source --since=two.days.ago $var`;
  if (length($var) > 0) {
    @arr = split(/\s/, $var);
    $var = $arr[1];
    push @nonstale, $var;
  }
}
@thosebranches = @nonstale;
my %branches = ();
foreach my $thatbranch (@thosebranches) {
  my @thosefiles = `git diff --name-only master...$thatbranch -- *.java`;
  foreach my $thatfile (@thosefiles) {
    my @tuple = ($branches{$thatfile}, $thatbranch);
    print @tuple;
    $branches{$thatfile} = (@tuple);
  } 
}
print $branches{(keys %branches)[1]};

# Get files modified in unmerged branches
foreach my $thisfile (@thisfiles) {
  
}
