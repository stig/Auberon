//
//  C4NNUnit.m
//  Auberon
//
//  Created by Stig Brautaset on 02/04/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "C4NNUnit.h"


@implementation C4NNUnit

- (void)setUp {
    perceptron = [SBPerceptron newWithLayers:@"42,100,1"];
    ab = [SBAlphaBeta newWithState:[[Connect4State new] autorelease]];
}

- (void)tearDown {
    [ab release];
    [perceptron release];
}

- (void)testPerceptronPresent
{
    for (int i = 0; i < 10; i++) {
        [ab applyMoveFromSearchWithPly:3];
//        NSLog(@"%f", [ab currentFitness]);
    }
    
    double fitness = [ab currentFitness];
    
    id state = [ab currentState];
    [state setPerceptron:perceptron];
    
    double fitness2 = [ab currentFitness];    
    STAssertEqualsWithAccuracy( fitness2, 0.0, 0.5, nil );
    STAssertTrue( fitness != fitness2, @"Fitnesses the same: %f", fitness2 );
    
    [state setPerceptron:nil];

    double fitness3 = [ab currentFitness];    
    STAssertEquals( fitness3, fitness, nil );
}


@end
