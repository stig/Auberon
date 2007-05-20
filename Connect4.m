/*
Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.

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
#import "Connect4State.h"

@implementation Connect4


- (void)resetGame
{
    id st = [[Connect4State new] autorelease];
    [self setAlphaBeta:[[SBAlphaBeta alloc] initWithState:st]];

    [super resetGame];
}

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setDelegate:self];
    [board setTheme:[NSImage imageNamed:@"classic"]];
    [self resetGame];
}

#pragma mark Actions

- (void)updateViews
{
    [board setBoard:[[self state] board]];
    [board setNeedsDisplay:YES];
    [[board window] display];
}

- (void)clickAtRow:(int)y col:(int)x
{
    [self move:[Connect4State moveWithCol:x]];
}

@end
