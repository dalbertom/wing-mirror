#!/usr/bin/perl

use strict;
use warnings;
goto part2;

my $date = `date -d yesterday +%Y-%m-%d`;
my @refs = `git for-each-ref --sort="-committerdate" --format="%(committerdate:short) %(refname)" refs/remotes`;
# chomp @refs;
chomp $date;
@refs = grep $_ =~ /$date/, @refs;
$_ = (split)[1] foreach @refs;

# Get files modified in branches updated today
die "$!" if -1 == system "rm -f thisids.txt thisfiles.txt thisbranch.txt";
open(my $fthisids, ">>", "thisids.txt") or die "$!";
open(my $fthisfiles, ">>", "thisfiles.txt") or die "$!";
open(my $fthisbranch, ">>", "thisbranch.txt") or die "$!";
foreach my $thisbranch (@refs) {
  my @thisfile = `git --no-pager diff --name-only master...$thisbranch -- *.java`;
  chomp @thisfile;
  foreach (@thisfile) {
    my $thispatchid = `git diff master...$thisbranch -- $_ | git patch-id`;
    chomp $thispatchid;
    print $fthisids "$thisbranch $thispatchid $_\n";
    print $fthisfiles "$_\n";

  }
  print $fthisbranch "$thisbranch\n";
}
close $fthisids;
close $fthisfiles;
close $fthisbranch;

# Get branches unmerged that are not stale
open(my $fthosebranches, ">", "thosebranches.txt") or die "$!";
print $fthosebranches `git branch -r --no-merged master | xargs -n 1 git log -1 --oneline --source --since=two.weeks.ago | awk '{print \$2}'`;
close $fthosebranches;
part2:
my @thosebranches = `git branch -r --no-merged master`;
foreach(@thosebranches) {
  print $_, "\n";
}
