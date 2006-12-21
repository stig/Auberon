/*
Copyright (C) 2006 Stig Brautaset. All rights reserved.

This file is part of Auberon.

Auberon is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

Auberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Auberon; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#import "Connect4State.h"
#import "Connect4Move.h"

#define WINDOW 4

@implementation Connect4State

- (id)init
{
    if (self = [super init]) {
        player = 1;
    }
    return self;
}

- (BOOL)gameOver
{
    int i, j = 0;
 
    /* no legal moves left? Then game is over, regardless. */
    for (i = 0; i < COLS; i++)
        if (board[0][i])
            j++;
    if (j == COLS)
        return YES;

    if ([self winner])
        return YES;
    return NO;
}

- (int)winner
{
    int i, j, k, t, t2;
    
    /* four-in-a-row vertically? */
    for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLS - WINDOW + 1; j++) {
            t = 3;
            for (k = 0; k < WINDOW; k++)
                t &= board[i][j + k];
            if (t)
                return t;
        }
    }
    
    for (i = 0; i < ROWS - WINDOW + 1; i++) {

        /* horizontally? */
        for (j = 0; j < COLS; j++) {
            t = 3;
            for (k = 0; k < WINDOW; k++)
                t &= board[i + k][j];
            if (t)
                return t;
        }

        /* how about diagonally? */
        for (j = 0; j < COLS - WINDOW + 1; j++) {
            t = t2 = 3;
            for (k = 0; k < WINDOW; k++) {
                t  &= board[i + k][j + k];
                t2 &= board[ROWS - 1 - i - k][j + k];
            }
            if (t)
                return t;
            if (t2)
                return t2;
        }
    }
    
    return 0;
}

- (id)applyMove:(id)m
{
    unsigned col = [m col];
    
    if ([self gameOver]) {
        [NSException raise:@"gameover" format:@"Cannot continue moving on endstate"];
    }
    
    if (board[0][col]) {
        [NSException raise:@"illegal move" format:@"Space already occupied"];
    }
    
    int i;
    for (i = 1; board[i][col] == 0 && i < ROWS; i++)
        ;
    i--;
    
    board[i][col] = player;
    player = 3 - player;
    return self;
}

- (NSArray *)movesAvailable
{
    NSMutableArray *a = [NSMutableArray array];
    
    if ([self gameOver]) {
        return a;
    }
    
    int i;
    for (i = 0; i < COLS; i++) {
        if (board[0][i] == 0) {
            [a addObject:[Connect4Move moveWithCol:i]];
        }
    }
    return a;
}

- (id)undoMove:(id)m
{
    unsigned col = [m col];
    
    int i;
    for (i = 0; board[i][col] == 0 && i < ROWS; i++)
        ;
    
    if (!board[i][col]) {
        [NSException raise:@"illegal move" format:@"Space already empty"];
    }
    
    board[i][col] = 0;
    player = 3 - player;
    return self;
}

static int calcScore(int me, int counts[3])
{
    int you = 3 - me;
    int score = 0;
    if (counts[me] && !counts[you]) {
        score += pow(counts[me], 10);
    }
    else if (!counts[me] && counts[you]) {
        score -= pow(counts[you], 10);
    }
    return score;
}

- (float)currentFitness
{
    int i, j, k;
    float score = 0.0;

    /* four-in-a-row vertically? */
    for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLS - WINDOW + 1; j++) {
            int counts[3] = {0};
            for (k = 0; k < WINDOW; k++) {
                counts[board[i][j + k]]++;
            }
            score += calcScore(player, counts);
        }
    }
    
    for (i = 0; i < ROWS - WINDOW + 1; i++) {

        /* horizontally? */
        for (j = 0; j < COLS; j++) {
            int counts[3] = {0};
            for (k = 0; k < WINDOW; k++) {
                counts[board[i + k][j]]++;
            }
            score += calcScore(player, counts);
        }

        /* how about diagonally? */
        for (j = 0; j < COLS - WINDOW + 1; j++) {
            int counts1[3] = {0};
            int counts2[3] = {0};
            for (k = 0; k < WINDOW; k++) {
                counts1[board[i + k][j + k]]++;
                counts2[board[ROWS - 1 - i - k][j + k]]++;
            }
            score += calcScore(player, counts1);
            score += calcScore(player, counts2);
        }
    }
    
    return score;
}

- (NSString *)description
{
    NSMutableString *s = [NSMutableString string];
    int i, j;
    for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLS; j++) {
            [s appendFormat:@"%d", board[i][j]];
        }
        if (i < ROWS - 1) {
            [s appendFormat:@" "];
        }
    }
    return s;
}

- (int)pieceAtRow:(int)r col:(int)c
{
    return board[r][c];
}

- (void)getRows:(int *)rows cols:(int *)cols
{
    *rows = ROWS;
    *cols = COLS;
}

- (int)player
{
    return player;
}

@end
