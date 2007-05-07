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

@implementation Connect4

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"3",           @"ai_level",
        nil]];
}

- (void)resetGame
{
    [ab release];
    ab = [[SBAlphaBeta alloc] initWithState:
        [[Connect4State alloc] init]];
    level = [[NSUserDefaults standardUserDefaults] integerForKey:@"ai_level"];
    ai = 2;
    [self autoMove];
}

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setController:self];
    [board setTheme:[NSImage imageNamed:@"classic"]];
    [self resetGame];
}

- (void)dealloc
{
    [ab release];
    [super dealloc];
}

#pragma mark Alerts

/** Displays an alert when "Game Over" is detected. */
- (void)gameOverAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];

    int winner = [ab winner];
    NSString *msg = winner == ai ? @"You lost!" :
                    !winner      ? @"You managed a draw!" :
                                   @"You won!";
    
    [alert setMessageText:msg];
    [alert setInformativeText:@"Do you want to play another game?"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetGame];
    }
}

/** Displays an alert when the "New Game" action is chosen. */
- (void)newGameAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Start a new game"];
    [alert setInformativeText:@"Are you sure you want to terminate the current game and start a new one?"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetGame];
    }
}

#pragma mark IBActions

/** Performs undo twice (once for AI, once for human) 
and updates views in between. */
- (IBAction)undo:(id)sender
{
    [ab undoLastMove];
    [self updateViews];
    [ab undoLastMove];
    [self autoMove];
}

/** Initiate a new game. */
- (IBAction)newGame:(id)sender
{
    if ([ab countMoves]) {
        [self newGameAlert];
    }
    else {
        [self resetGame];
    }
}

#pragma mark Actions

/** Make the AI perform a move. */
- (void)aiMove
{
    id st = nil;
    if (level < 4) {
        st = [ab applyMoveFromSearchWithPly:level];
    } else {
        int ply = level * 10.0;
        NSTimeInterval interval = (NSTimeInterval)(ply * ply / 1000.0);
        st = [ab applyMoveFromSearchWithInterval:interval];
    }

    if (st) {
        [self autoMove];
    } else {
        NSLog(@"AI cannot move");
    }
}


/** Perform the given move. */
- (void)move:(id)m
{
    @try {
        [ab applyMove:m];
    }
    @catch (id any) {
        NSLog(@"Illegal move attempted: %@", m);
    }
    @finally {
        [self autoMove];
    }
}

/** Return the current state (pass-through to SBAlphaBeta). */
- (id)state
{
    return [ab currentState];
}

/** Figure out if the AI should move "by itself". */
- (void)autoMove
{
    [self updateViews];
    
    if ([ab isGameOver]) {
        [self gameOverAlert];
    }
    
    if (ai == [ab playerTurn]) {
        [progressIndicator startAnimation:self];
        [self aiMove];
        [progressIndicator stopAnimation:self];
        [self updateViews];
    }
}

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
