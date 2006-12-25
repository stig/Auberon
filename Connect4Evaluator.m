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

#import "Connect4Evaluator.h"

@implementation Connect4Evaluator

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

- (float)evaluate:(Connect4State *)state
{
    int i, j, k;
    unsigned int **board = [state board];
    int rows = [state rows];
    int cols = [state cols];
    int player = [state player];
 
    float score = 0.0;
    
    /* four-in-a-row vertically? */
    for (i = 0; i < rows; i++) {
        for (j = 0; j < cols - WINDOW + 1; j++) {
            int counts[3] = {0};
            for (k = 0; k < WINDOW; k++) {
                counts[board[i][j + k]]++;
            }
            score += calcScore(player, counts);
        }
    }
    
    for (i = 0; i < rows - WINDOW + 1; i++) {

        /* horizontally? */
        for (j = 0; j < cols; j++) {
            int counts[3] = {0};
            for (k = 0; k < WINDOW; k++) {
                counts[board[i + k][j]]++;
            }
            score += calcScore(player, counts);
        }

        /* how about diagonally? */
        for (j = 0; j < cols - WINDOW + 1; j++) {
            int counts1[3] = {0};
            int counts2[3] = {0};
            for (k = 0; k < WINDOW; k++) {
                counts1[board[i + k][j + k]]++;
                counts2[board[rows - 1 - i - k][j + k]]++;
            }
            score += calcScore(player, counts1);
            score += calcScore(player, counts2);
        }
    }
    
    return score;
}

@end
