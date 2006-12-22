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

#import "Connect4StateUnit.h"
#import "Connect4NNEvaluator.h"


@implementation Connect4StateUnit

- (void)setUp
{
    s = [[Connect4State alloc] init];
}

- (void)tearDown
{
    [s release];
}

- (void)testMove
{
    Connect4Move *m;

    STAssertNotNil(m = [Connect4Move moveWithCol:3], nil);
    STAssertEquals([m col], (unsigned)3, nil);

    STAssertThrows([Connect4Move moveWithCol:9], @"failed to throw exception for invalid move");
    STAssertThrows([Connect4Move moveWithCol:-1], @"failed to throw exception for invalid move");
}

- (NSArray *)states
{
    return [NSArray arrayWithObjects:
        @"0000000 0000000 0000000 0000000 0000000 0000000",
        @"0000000 0000000 0000000 0000000 0000000 1000000",
        @"0000000 0000000 0000000 0000000 2000000 1000000",
        @"0000000 0000000 0000000 0000000 2000000 1100000",
        @"0000000 0000000 0000000 2000000 2000000 1100000",
        @"0000000 0000000 1000000 2000000 2000000 1100000",
        @"0000000 2000000 1000000 2000000 2000000 1100000",
        @"1000000 2000000 1000000 2000000 2000000 1100000",
        nil];
}

- (void)testApplyMoves
{
    NSArray *a = [self states];

    STAssertEqualObjects([s description], [a objectAtIndex:0], nil);
    STAssertEqualObjects([[s applyMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:1], nil);
    STAssertEqualObjects([[s applyMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:2], nil);
    STAssertEqualObjects([[s applyMove:[Connect4Move moveWithCol:1]] description], [a objectAtIndex:3], nil);
    STAssertEqualObjects([[s applyMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:4], nil);
    STAssertEqualObjects([[s applyMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:5], nil);
    STAssertEqualObjects([[s applyMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:6], nil);
    STAssertEqualObjects([[s applyMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:7], nil);
    STAssertThrows([s applyMove:[Connect4Move moveWithCol:0]], nil);
    STAssertEqualObjects([s description], [a objectAtIndex:7], nil);
}

- (void)testUndoMoves
{
    [self testApplyMoves];

    NSArray *a = [self states];
    STAssertEqualObjects([[s undoMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:6], nil);
    STAssertEqualObjects([[s undoMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:5], nil);
    STAssertEqualObjects([[s undoMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:4], nil);
    STAssertEqualObjects([[s undoMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:3], nil);
    STAssertEqualObjects([[s undoMove:[Connect4Move moveWithCol:1]] description], [a objectAtIndex:2], nil);
    STAssertEqualObjects([[s undoMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:1], nil);
    STAssertEqualObjects([[s undoMove:[Connect4Move moveWithCol:0]] description], [a objectAtIndex:0], nil);
}

- (void)testAvailableMoves
{
    NSArray *a;

    STAssertNotNil(a = [s movesAvailable], nil);
    STAssertEquals([a count], (unsigned)7, nil);

    int i;
    for (i = 0; i < 7; i++) {
        STAssertEquals([[a objectAtIndex:i] col], (unsigned)i, nil);
    }

    [self testApplyMoves];
    STAssertNotNil(a = [s movesAvailable], nil);
    STAssertEquals([a count], (unsigned)6, nil);
    for (i = 0; i < 6; i++) {
        STAssertEquals([[a objectAtIndex:i] col], (unsigned)i + 1, nil);
    }
    
    // make player 1 get a winning line
    [s applyMove:[Connect4Move moveWithCol:2]];
    [s applyMove:[Connect4Move moveWithCol:1]];
    [s applyMove:[Connect4Move moveWithCol:2]];
    [s applyMove:[Connect4Move moveWithCol:1]];
    [s applyMove:[Connect4Move moveWithCol:2]];
    [s applyMove:[Connect4Move moveWithCol:1]];
    
    STAssertNotNil(a = [s movesAvailable], nil);
    STAssertEquals([a count], (unsigned)0, nil);
}

- (void)testWeirdSearchCase
{
    NSArray *b = [NSArray arrayWithObjects:
        [@"1,1,0,0,0,0,0" componentsSeparatedByString:@","],
        [@"1,1,0,0,0,0,0" componentsSeparatedByString:@","],
        [@"2,1,1,0,0,0,0" componentsSeparatedByString:@","],
        [@"1,2,2,2,0,0,0" componentsSeparatedByString:@","],
        [@"1,2,2,2,0,0,0" componentsSeparatedByString:@","],
        [@"1,2,2,1,2,0,0" componentsSeparatedByString:@","],
        nil];
        
    unsigned **board = [s board];
    int i, j;
    for (i = 0; i < 6; i++)
        for (j = 0; j < 7; j++)
            board[i][j] = [[[b objectAtIndex:i] objectAtIndex:j] intValue];
    
    id g = [[AlphaBeta alloc] initWithState:s];
    STAssertEquals([g player], (int)1, @"player 1 to go");
    STAssertEquals([g winner], (int)0, @"no winner yet");
    STAssertEquals([[g movesAvailable] count], (unsigned)5, @"expected 5 moves");

    STAssertNotNil([g fixedDepthSearchWithPly:3], nil);
    STAssertEquals([g player], (int)2, @"player 1 to go");
    STAssertEquals([g winner], (int)0, @"no winner yet");
    STAssertEquals([[g movesAvailable] count], (unsigned)5, @"expected 5 moves");
}

- (void)testWinner
{
    [self testAvailableMoves];
    STAssertEquals([s winner], (int)1, @"player 1 won");
}

- (void)testApplyIllegalMove
{
    [self testAvailableMoves];
    STAssertThrows([s applyMove:[Connect4Move moveWithCol:6]], @"expected exception");
}

- (void)testFitness
{
    STAssertEqualsWithAccuracy([s currentFitness], (float)0.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:0]] currentFitness], (float)-3.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:0]] currentFitness], (float)-1.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:0]] currentFitness], (float)-3.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:0]] currentFitness], (float)0.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:1]] currentFitness], (float)-1026.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:4]] currentFitness], (float)1021.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:3]] currentFitness], (float)-59051.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:6]] currentFitness], (float)59049.0, 0.0001, nil);
    STAssertEqualsWithAccuracy([[s applyMove:[Connect4Move moveWithCol:2]] currentFitness], (float)-1048578.0, 0.0001, nil);
}

- (void)todoTestNNEvaluator
{
    id player[2] = {
        [[NSKeyedUnarchiver unarchiveObjectWithFile:@"c4evaluator.nn"] retain],
        [Connect4Evaluator new],
    };

    int ply, p;
    
    /* for player 1, then for player 2... */
    for (p = 1; p < 3; p++) {
    
        /* for ply 1 through 4... */
        for (ply = 1; ply < 5; ply++) {
            id st = [[Connect4State new] autorelease];
            id g = [[AlphaBeta alloc] initWithState:st];
            [st setPlayer:p];

            do {
                [st setEvaluator:player[ [g player] - 1 ]];
                [g fixedDepthSearchWithPly:ply];
            } while (![g isGameOver]);

            STAssertEquals([g winner], (int)1, nil);
            [g release];
        }
    }
}



@end
