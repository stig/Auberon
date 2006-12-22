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

#import "Connect4.h"
#import "BoardView.h"
#import <SBAlphaBeta/SBAlphaBeta.h>
#import "Connect4State.h"
#import "Connect4Move.h"

@implementation Connect4


- (void)resetGame
{
    [ab release];
    ab = [[SBAlphaBeta alloc] initWithState:
        [[Connect4State new] autorelease]];
    
    [aiButton setEnabled:YES];
    [aiButton setState:NSOffState];
    [self changeAi:aiButton];
    [self changeLevel:levelStepper];
    
/* Not yet.
    id path = [[NSBundle mainBundle] pathForResource:@"c4evaluator" ofType:@"nn"];
    id this = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!this)
        [NSException raise:@"no-nn-evaluator" format:@"no NN evaluator found"];
*/
    [self autoMove];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self resetGame];
}

- (void)updateViews
{
    [turn setStringValue: ai == [ab player] ? @"Auberon is thinking..." : @"Your move"];
    [aiButton setEnabled: [ab countMoves] ? NO : YES];
    [levelStepper setEnabled: [ab countMoves] ? NO : YES];
    
    [board setState:[self buildState]];
    [board setNeedsDisplay:YES];
    [[board window] display];
}

- (void)clickAtRow:(int)y col:(int)x
{
    [self move:[Connect4Move moveWithCol:x]];
}

@end
