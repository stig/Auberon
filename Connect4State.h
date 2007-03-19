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

#import <SBAlphaBeta/SBAlphaBeta.h>

#define COLS 7
#define ROWS 6

@interface Connect4State : NSObject <SBMutableAlphaBetaState> {
    int player;
    unsigned board[ROWS][COLS];
}

+ (id)moveWithCol:(int)col;
- (int)winner;

/* for the View */
- (int)pieceAtRow:(int)row col:(int)col;
- (void)getRows:(int*)rows cols:(int*)cols;

@end
