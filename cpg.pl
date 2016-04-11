#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use File::Copy 'copy';
use File::Copy::Recursive 'rcopy';

my $iter;
my $fmt;
my $last_dir;
my $dir = '.';
my (@file, @dir, @other);

print "f/d?\n>> ";
chomp(my $init = <STDIN>);

if ($init eq 'f') {
    $fmt = 'file'
}
elsif ($init eq 'd') {
    $fmt = 'dir'
}
else {
    say "Exit.";
    exit;
}
iter($fmt);

say "Put the words before & after.";
chomp(my $get = <STDIN>);

unless ($get =~ /\A(q|e|quit|exit)\z/) {
    chomp $get;
    my ($before, $after);
    if ($get =~ /\A(\S+)(( +(\S+))+)/) {
        $before = $1;
        $after = $2;
        my @after = split / /, $after;

        my @match = ();
        my @source = ();
        my $source = '';
        my $f = sub{
            $source = shift;
            if ($source =~ /$before/) {
            push @source, "$dir/$source";
                for (@after) {
                    next if ($_ eq '');
                    my $new = $source;
                    $new =~ s/$before/$_/;
                    if (-f $dir.'/'.$new) {
                        say "$new is already exist.";
                        next;
                    }
                    push @match, "$dir/$new";
                }
            }
        };
        opendir (my $iter, $dir) or die;
        for $source (readdir $iter) {
            next if ($source =~ /^\./);
            if ($fmt eq 'file') {
                if (-f $dir.'/'.$source) {
                    $f->($source);
                }
            }
            elsif ($fmt eq 'dir') {
                if (-d $dir.'/'.$source) {
                    $f->($source);
                }
            }
        }
        closedir $iter;
        if (scalar(@match) > 0) {
            say "Copy it OK? [y/N]\n";
            say "from:";
            for (@source) {
                say "\t$_";
            }
            say "to:";
            for (@match) {
                say "\t$_";
            }
            my $source = '';
            my $c = sub {
                $source = shift;
                if ($source =~ /$before/) {
                    for (@after) {
                        next if ($_ eq '');
                        my $new = $source;
                        $new =~ s/$before/$_/;
                        if ($fmt eq 'file'){
                            copy($source, $new) or die $!;
                        }
                        elsif ($fmt eq 'dir'){
                            mkdir($new) unless (-d $new);
                            rcopy($source, $new) or die $!;
                        }
                    }
                }
            };
            chomp(my $result = <STDIN>);
            if ($result =~ /\A(y|yes)\z/) {
                opendir (my $iter, $dir) or die;
                for $source (readdir $iter) {
                    next if ($source =~ /^\./);
                    if ($fmt eq 'file'){
                        if (-f $dir.'/'.$source) {
                            $c->($source);
                        }
                    }
                    elsif ($fmt eq 'dir'){
                        if (-d $dir.'/'.$source) {
                            $c->($source);
                        }
                    }
                }
                closedir $iter;
            } else {
                say "Nothing changes.\n";
            }
        } else {
            say "Not matched.\n";
        }
    } else {
        say "Exit.";
    }
    iter(1);
    exit;
} else {
    say "Exit.";
}

sub iter {
    my $fmt = shift;
    (@file, @dir, @other) = '';
    opendir (my $iter, $dir) or die;
        for (readdir $iter) {
            next if ($_ =~ /\A\./);
            if (-f $dir.'/'.$_) {
                push @file, "\tfile: $dir/$_\n";
            } elsif (-d $dir.'/'.$_) {
                push @dir, "\tdir: $dir/$_\n";
                $last_dir = $_;
            } else {
                push @other, "\tother: $dir/$_\n";
            }
        }
    closedir $iter;

    say 'ls:';
    if ($fmt eq 'dir') {
        print @dir;
    }
    elsif ($fmt eq 'file') {
        print @file;
    }
    else {
        print @dir;
        print @file;
        print @other;
    }
    print "\n";
}
