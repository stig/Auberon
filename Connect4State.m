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

#import "Connect4Evaluator.h"

@implementation Connect4State

- (id)init
{
    if (self = [super init]) {
        board = NSZoneMalloc([self zone], ROWS * (sizeof(unsigned int*)));
        if (!board) {
            [NSException raise:@"oom" format:@"meh. can't get memory."];
        }
        
        board[0] = NSZoneMalloc([self zone], ROWS * COLS * sizeof(unsigned int));
        if (!board[0]) {
            free(board);
            [NSException raise:@"oom" format:@"meh. can't get memory."];
        }
        
        int i, j;
        for (i = 1; i < ROWS; i++) {
            board[i] = board[0] + i * COLS;
        }
        
        for (i = 0; i < ROWS; i++) {
            for (j = 0; j < COLS; j++) {
                board[i][j] = 0;
            }
        }    
        [self setEvaluator:[[Connect4Evaluator new] autorelease]];
        player = 1;
    }
    return self;
}

- (void)dealloc
{
   [evaluator release];
   free(board[0]);
   free(board);
   [super dealloc];
}

- (void)setEvaluator:(id)e
{
    if (evaluator != e) {
        [evaluator release];
        evaluator = [e retain];
    }
}

- (id)evaluator
{
    return evaluator;
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
    if (!m)
        [NSException raise:@"illegal move" format:@"Null pointer is not a legal move"];
    
    if ([self gameOver]) {
        [NSException raise:@"gameover" format:@"Cannot continue moving on endstate (winner: %u): %@", [self winner], m];
    }

    if (board[0][col]) {
        [NSException raise:@"illegal move" format:@"Space already occupied: %@", m];
    }

    /* starting at i=1 looks like a bug at first glance (and 2nd, and 3rd, ...) 
       but should be correct. We have already ascertained that i=0 is free, above.
       Now we're just checking how far down we have to drop the disk. */
    int i;
    for (i = 1; i < ROWS && board[i][col] == 0; i++)
        ;
    board[i - 1][col] = player;
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
    for (i = 0; i < ROWS && board[i][col] == 0; i++)
        ;
    
    if (!board[i][col]) {
        [NSException raise:@"illegal move" format:@"Space already empty"];
    }
    
    board[i][col] = 0;
    player = 3 - player;
    return self;
}

- (float)currentFitness
{
    if (evaluator)
        return [evaluator evaluate: self];
    [NSException raise:@"grahaha!" format:@"no evaluator present"];
    return 0;
}

- (NSString *)description
{
    NSMutableString *s = [NSMutableString string];
    int i, j;
    for (i = 0; i < ROWS; i++) {

        /* horizontally? */
        for (j = 0; j < COLS; j++) {
            [s appendFormat:@"%d", board[i][j]];
        }
        if (i < ROWS - 1) {
            [s appendFormat:@" "];
        }
    }
    return s;
}

- (NSString *)asString
{
    NSMutableString *s = [NSMutableString string];
    int i, j;
    for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLS; j++) {
            [s appendFormat:@"%d:", board[i][j]];
        }
    }
    [s appendFormat:@"%lf", [self currentFitness]];
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

- (void)setPlayer:(int)p
{
    if (p < 1 || p > 2)
        [NSException raise:@"invalid player" format:@"player must be 1 or 2"];
    player = p;
}

- (int)player
{
    return player;
}

- (int)rows
{
    return ROWS;
}

- (int)cols
{
    return COLS;
}

- (unsigned int **)board
{
    return board;
}

@end
