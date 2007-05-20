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

#import "Connect4StateUnit.h"


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
    STAssertThrows([Connect4State moveWithCol:9], @"failed to throw exception for invalid move");
    STAssertThrows([Connect4State moveWithCol:-1], @"failed to throw exception for invalid move");
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

- (void)testtransformWithMoves
{
    NSArray *a = [self states];

    STAssertEqualObjects([s description], [a objectAtIndex:0], nil);
    id moves = [@"0,0,1,0,0,0,0" componentsSeparatedByString:@","];
    for (int i = 0; i < [moves count]; i++) {
        [s transformWithMove:[moves objectAtIndex:i]];
        STAssertEqualObjects([s description], [a objectAtIndex:i+1], nil);
    }
    STAssertThrows([s transformWithMove:[Connect4State moveWithCol:0]], nil);
    STAssertEqualObjects([s description], [a objectAtIndex:7], nil);
}

- (void)testUndoMoves
{
    [self testtransformWithMoves];

    NSArray *a = [self states];
    id moves = [@"0,0,1,0,0,0,0" componentsSeparatedByString:@","];
    for (int i = 6; i >= 0; i--) {
        [s undoTransformWithMove:[moves objectAtIndex:i]];
        STAssertEqualObjects([s description], [a objectAtIndex:i], nil);
    }
}

- (void)testAvailableMoves
{
    NSArray *a;

    STAssertNotNil(a = [s movesAvailable], nil);
    STAssertEquals([a count], (unsigned)7, nil);

    for (int i = 0; i < 7; i++) {
        STAssertEquals([[a objectAtIndex:i] intValue], i, nil);
    }

    [self testtransformWithMoves];
    STAssertNotNil(a = [s movesAvailable], nil);
    STAssertEquals([a count], (unsigned)6, nil);
    for (int i = 0; i < 6; i++) {
        STAssertEquals([[a objectAtIndex:i] intValue], i + 1, nil);
    }
    
    // make player 1 get a winning line
    [s transformWithMove:[Connect4State moveWithCol:2]];
    [s transformWithMove:[Connect4State moveWithCol:1]];
    [s transformWithMove:[Connect4State moveWithCol:2]];
    [s transformWithMove:[Connect4State moveWithCol:1]];
    [s transformWithMove:[Connect4State moveWithCol:2]];
    [s transformWithMove:[Connect4State moveWithCol:1]];
    
    STAssertNotNil(a = [s movesAvailable], nil);
    STAssertEquals([a count], (unsigned)0, nil);
}

- (void)testWinner
{
    [self testAvailableMoves];
    STAssertEquals(s->player, (int)2, nil);
    STAssertEquals([s endStateScore], (double)-1.0, @"player 1 won");
}

- (void)testApplyIllegalMove
{
    [self testAvailableMoves];
    STAssertThrows([s transformWithMove:[Connect4State moveWithCol:6]], @"expected exception");
}

- (void)testFitness
{
    STAssertEqualsWithAccuracy([s currentFitness], (double)0.0, 0.0001, nil);
    id moves   = [@"0,0,0,0,1,4,3,6,2" componentsSeparatedByString:@","];
    id fitness = [@"-3,-1,-3,0,-1026,1021,-59051,59049,-1048578" componentsSeparatedByString:@","];
    for (int i = 0; i < [moves count]; i++) {
        [s transformWithMove:[moves objectAtIndex:i]];
        STAssertEqualsWithAccuracy([s currentFitness], [[fitness objectAtIndex:i] doubleValue], 0.0001, nil);
    }
}

@end
