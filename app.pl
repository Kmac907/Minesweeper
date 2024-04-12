use strict;
use warnings;

# Function to print the game board
sub print_board {
    my ($board) = @_;

    # Print column numbers
    print "    ";
    for my $col (0 .. $#$board) {
        printf "%3d ", $col;  # Added an extra space after the number
    }
    print "\n";

    # Print top border
    print "   +" . ("---+" x scalar(@$board)) . "\n";

    # Print rows
    for my $row (0 .. $#$board) {
        # Print row number
        printf "%2d |", $row;

        # Print cells
        for my $col (0 .. $#$board) {
            if ($board->[$row][$col]{revealed}) {
                if ($board->[$row][$col]{value} eq 'X') {
                    printf " %s ", $board->[$row][$col]{value};
                } else {
                    printf " %d ", $board->[$row][$col]{value};  # Adjusted spacing
                }
            } elsif ($board->[$row][$col]{flag}) {
                print " F ";
            } else {
                print "   ";
            }
            print "|";  # Vertical separator
        }

        # Print new line and separator
        print "\n   +" . ("---+" x scalar(@$board)) . "\n";
    }
}

# Function to initialize the game board with specified difficulty
sub init_board {
    my ($size, $difficulty) = @_;

    my $num_mines;
    if ($difficulty eq 'easy') {
        $num_mines = int($size * $size * 0.15);
    } elsif ($difficulty eq 'medium') {
        $num_mines = int($size * $size * 0.20);
    } elsif ($difficulty eq 'hard') {
        $num_mines = int($size * $size * 0.30);
    } else {
        die "Invalid difficulty level!";
    }

    my @board;
    for my $i (0 .. $size - 1) {
        for my $j (0 .. $size - 1) {
            $board[$i][$j] = {
                value => 0,
                revealed => 0,
                is_mine => 0,
                flag => 0
            };
        }
    }

    # Place mines randomly
    my $mines_placed = 0;
    while ($mines_placed < $num_mines) {
        my $x = int(rand($size));
        my $y = int(rand($size));
        unless ($board[$x][$y]{is_mine}) {
            $board[$x][$y]{is_mine} = 1;
            $mines_placed++;
        }
    }

    # Calculate adjacent mines count
    for my $i (0 .. $size - 1) {
        for my $j (0 .. $size - 1) {
            if ($board[$i][$j]{is_mine}) {
                for my $di (-1, 0, 1) {
                    for my $dj (-1, 0, 1) {
                        next if $di == 0 && $dj == 0;
                        my $ni = $i + $di;
                        my $nj = $j + $dj;
                        next if $ni < 0 || $nj < 0 || $ni >= $size || $nj >= $size;
                        $board[$ni][$nj]{value}++;
                    }
                }
            }
        }
    }

    return \@board;
}

# Function to reveal cell
sub reveal {
    my ($board, $x, $y) = @_;

    if ($board->[$x][$y]{revealed}) {
        print "This cell is already revealed!\n";
        return;
    }

    $board->[$x][$y]{revealed} = 1;

    if ($board->[$x][$y]{is_mine}) {
        print "Game Over! You hit a mine!\n";
        print_board($board);
        exit;
    }

    if ($board->[$x][$y]{value} == 0) {
        for my $di (-1, 0, 1) {
            for my $dj (-1, 0, 1) {
                next if $di == 0 && $dj == 0;
                my $ni = $x + $di;
                my $nj = $y + $dj;
                next if $ni < 0 || $nj < 0 || $ni >= @$board || $nj >= @{$board->[0]};
                reveal($board, $ni, $nj) unless $board->[$ni][$nj]{revealed};
            }
        }
    }
}

# Function to place or remove flag
sub toggle_flag {
    my ($board, $x, $y) = @_;

    $board->[$x][$y]{flag} = !$board->[$x][$y]{flag};
}

# Main game loop
sub play_game {
    my ($size, $difficulty) = @_;

    my $board = init_board($size, $difficulty);

    while (1) {
        print_board($board);
        print "Enter 'R row col' to reveal a cell, 'F row col' to place or remove a flag, and 'Q' to quit: ";
        my $input = <STDIN>;
        chomp($input);
        my ($action, $x, $y) = split(' ', $input);
        
        if ($action eq 'R') {
            if ($x !~ /^\d+$/ || $y !~ /^\d+$/ || $x < 0 || $y < 0 || $x >= $size || $y >= $size) {
                print "Invalid input. Please enter valid row and column numbers.\n";
                next;
            }
            reveal($board, $x, $y);
        } elsif ($action eq 'F') {
            if ($x !~ /^\d+$/ || $y !~ /^\d+$/ || $x < 0 || $y < 0 || $x >= $size || $y >= $size) {
                print "Invalid input. Please enter valid row and column numbers.\n";
                next;
            }
            toggle_flag($board, $x, $y);
        } elsif ($action eq 'Q') {
            print "Quitting game...\n";
            last;
        } else {
            print "Invalid action. Please enter 'R row col', 'F row col', or 'Q'.\n";
        }
        
        my $remaining_cells = 0;
        for my $i (0 .. $size - 1) {
            for my $j (0 .. $size - 1) {
                $remaining_cells++ unless $board->[$i][$j]{revealed};
            }
        }
        if ($remaining_cells == 0) {
            print_board($board);
            print "Congratulations! You win!\n";
            last;
        }
    }
}

# Start the game
print "Welcome to Minesweeper!\n";
print "Choose your difficulty level (easy, medium, hard): ";
my $difficulty = lc(<STDIN>);
chomp($difficulty);

print "Enter the size of the board: ";
my $size = <STDIN>;
chomp($size);

play_game($size, $difficulty);
