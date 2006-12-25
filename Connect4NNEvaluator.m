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

#import "Connect4NNEvaluator.h"
#import "Connect4State.h"

@implementation Connect4NNEvaluator

- (id)init
{
    if (self = [super initWithLayers:[@"42,50,10,1" componentsSeparatedByString:@","]]) {
        score = 0.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        score = 0.0;
    }
    return self;
}

- (float)evaluate:(Connect4State *)s
{
    id input = [NSMutableArray array];
    int i, j;
    unsigned **board = [s board];
    for (i = 0; i < ROWS; i++)
        for (j = 0; j < COLS; j++)
            [input addObject:[NSNumber numberWithInt:board[i][j]]];
    
    return [[[self computeOutput:input] lastObject] floatValue] - 0.5;
}

- (void)setScore:(float)s
{
    score = s;
}

- (float)score
{
    return score;
}

- (NSComparisonResult)compare:(Connect4NNEvaluator *)nn
{
    if (score < [nn score])
        return NSOrderedAscending;
    
    else if  (score > [nn score])
        return NSOrderedDescending;
    
    else 
        return NSOrderedSame;
}

@end
