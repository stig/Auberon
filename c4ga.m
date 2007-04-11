/*
Copyright (C) 2006-2007 Stig Brautaset. All rights reserved.

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

#import <Cocoa/Cocoa.h>
#import <SBAlphaBeta/SBAlphaBeta.h>
#import <SBPerceptron/SBPerceptron.h>

double sbp_gaussrand();

#import "Connect4State.h"


#define POPULATION_SIZE 25
#define GAMES 5

NSArray *breed(NSArray *parents)
{
    id children = [NSMutableArray array];
    unsigned i, j, lim = ([parents count] * 3) / 4;
    for (i = 0; [children count] < [parents count]; i++) {
        if (i == lim)
            i = 0;
        do {
            j = (unsigned)fabs( sbp_gaussrand() * [parents count] / 3.0 ) % [parents count];
        } while (i == j);
        id mother = [parents objectAtIndex:i];
        id father = [parents objectAtIndex:j];
        id child = [mother perceptronByBreedingWith:father mutationRate:2.0 scale:2.0];
        [children addObject:child];
    }
    return [parents arrayByAddingObjectsFromArray:children];
}

NSArray *cull(NSArray *pop)
{
    id population = [population mutableCopy];
    id new = [NSMutableArray array];
    while ([new count] < [population count]) {
        unsigned cnt = [population count];
        unsigned i = (unsigned)fabs( sbp_gaussrand() * cnt / 3.0 ) % cnt;
        id o = [population objectAtIndex:cnt - i - 1];
        [new addObject:o];
        [population removeObject:o];
    }
    return new;
}

void write_generation_to_file(NSArray *arr, int gen)
{
    printf("writing generation: %u\n", gen);
    [NSKeyedArchiver archiveRootObject:arr toFile:[NSString stringWithFormat:@"c4gen-%u.nn", gen]];
    [NSKeyedArchiver archiveRootObject:[arr lastObject] toFile:[NSString stringWithFormat:@"c4evaluator.nn", gen]];
}

void updateScore( NSMutableDictionary *dict, SBPerceptron *p, double score )
{
    id val = [dict objectForKey:p];
    if (val)
        score += [val doubleValue];
    [dict setObject: [NSNumber numberWithDouble:score] forKey:p];
}


NSDictionary *rate(NSArray *perceptrons)
{
    int moves, ply;
    id scores = [NSMutableDictionary dictionary];
    
    /* pit nets against eachther */
    fprintf(stderr, "Capital letter means player 1 (a) started\n");

    id opponents[2];
    NSDate *date = [NSDate date];
    
    /* Iterate over all the players.. */
    id perceptronEnumerator = [perceptrons objectEnumerator];
    while (opponents[1] = [perceptronEnumerator nextObject]) {
    
        /* Let them play a number of games */
        for (int i = 0; i < GAMES; i++) {
        
            /* Keep process smallish - reclaim autoreleased memory after each game */
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
            /* We'll accept any opponent except ourselves. */
            do {
                opponents[0] = [perceptrons objectAtIndex:random() % [perceptrons count]];
            } while (opponents[1] == opponents[0]);

            /* randomly select who starts */
            int player = random() % 2;
            int ch = player ? 'A' : 'a';
            
            id state = [[Connect4State new] autorelease];
            id ab = [SBAlphaBeta newWithState:state];
            
            do {
                [[ab currentState] setPerceptron:opponents[player]];
                player = !player;
                [ab applyMoveFromSearchWithInterval:0.3];

                /* for progress report */
                moves++;
                ply += [ab plyReachedForSearch];
            } while (![ab isGameOver]);
         
         
            int winner = [ab winner];
            if (winner) {
                
                /* favour swift victories */
                double skew = pow(0.999, [ab countMoves]);

                updateScore(scores, opponents[winner-1], 2.0 * skew );
                updateScore(scores, opponents[3-winner-1], -skew );
            }
            fputc(winner ? ch + winner - 1 : '-', stderr);
            
            [ab release];
            [pool release];
        }
        fputc(' ', stderr);
    }
    fprintf(stderr, " %.2f sec; avg ply: %.2lf; ",
        (double)-[date timeIntervalSinceNow], (float)ply/(float)moves);
    
    return scores;
}

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    srand(time(NULL));
    int gen;
    id arr;
    if (argc > 1) {
        gen = atoi(argv[1]);
        arr = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"c4gen-%u.nn", gen]];
    }
    else {
        arr = [NSMutableArray array];
        for (gen = 0; gen < POPULATION_SIZE; gen++) {
            [arr addObject:[SBPerceptron perceptronWithLayers:@"42,100,1"]];
        }
        gen = 0;
    }
    [arr retain];

    if (!arr)
        [NSException raise:@"missing population" format:@"No population of NNs."];

    do {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];

        arr = breed([arr autorelease]);
        NSDictionary *scores = rate(arr);
        
        arr = [scores keysSortedByValueUsingSelector:@selector(compare:)];
        arr = cull(arr);
        write_generation_to_file(arr, ++gen);

        [arr retain];
        [pool release];
    } while (1);
    
    [pool release];
    return 0;
}
