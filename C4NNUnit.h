//
//  C4NNUnit.h
//  Auberon
//
//  Created by Stig Brautaset on 02/04/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Connect4State.h"


@interface C4NNUnit : SenTestCase {
    SBAlphaBeta *ab;
    SBPerceptron *perceptron;
}

@end
