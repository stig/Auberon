/*
Copyright (C) 2006 Stig Brautaset. All rights reserved.

This file is part of CocoaGames.

CocoaGames is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

CocoaGames is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with CocoaGames; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#import <Cocoa/Cocoa.h>

#import "Connect4NNEvaluator.h"
#import "Connect4State.h"
#import "AlphaBeta.h"

NSArray *breed(NSArray *parents)
{
    id children = [NSMutableArray array];
    int i, j, lim = ([parents count] * 3) / 4;
    for (i = 0; [children count] < [parents count]; i++) {
        if (i == lim)
            i = 0;
        do {
            j = (int)fabs( gaussrand() * [parents count] / 3.0 ) % [parents count];
        } while (i == j);
        id mother = [parents objectAtIndex:i];
        id father = [parents objectAtIndex:j];
        id child = [mother netFromBreedingWith:father];
        [child mutateWithRate:2.0 andRange:2.0];
        [children addObject:child];
    }
    return [parents arrayByAddingObjectsFromArray:children];
}

NSArray *cull(NSMutableArray *arr)
{
    arr = [[arr sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    id new = [NSMutableArray array];
    while ([new count] < [arr count]) {
        int cnt = [arr count];
        int i = (int)fabs( gaussrand() * cnt / 3.0 ) % cnt;
        [new addObject:[arr objectAtIndex:cnt - i - 1]];
        [arr removeObjectAtIndex:cnt - i - 1];
    }
    return new;
}

void write_generation_to_file(NSArray *arr, int gen)
{
    printf("writing generation: %u\n", gen);
    arr = [arr sortedArrayUsingSelector:@selector(compare:)];
    
    for (int i = 0; i < [arr count]; i++)
        fprintf(stderr, "%f\n", [[arr objectAtIndex:i] score]);

    [NSKeyedArchiver archiveRootObject:arr toFile:[NSString stringWithFormat:@"c4gen-%u.nn", gen]];
    [NSKeyedArchiver archiveRootObject:[arr lastObject] toFile:[NSString stringWithFormat:@"c4evaluator.nn", gen]];
}


void rate(NSArray *arr)
{
    id player[2], pa = [arr objectEnumerator];
    int moves = 0, ply = 0;
    
    /* reset scores */
    while (player[1] = [pa nextObject])
        [player[1] setScore:0];

    /* pit nets against eachther */
    fprintf(stderr, "Capital letter means player 1 (a) started\n");
    pa = [arr objectEnumerator];
    NSDate *date = [NSDate date];
    while (player[1] = [pa nextObject]) {
        int games = 5, game;
        for (game = 0; game < games; game++) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
            do { /* find an opponent */
                player[0] = [arr objectAtIndex:random() % [arr count]];
            } while (player[1] == player[0]);

            /* randomly select who starts */
            int p = random() % 2;
            int ch = p == 1 ? 'A' : 'a';
            id st = [[Connect4State new] autorelease];
            id g = [[AlphaBeta alloc] initWithState:st];
            
            do {
                [st setEvaluator:(player[p])];
                p = !p;
                st = [g iterativeSearchWithTime:0.3];
                moves++;
                ply += [g reachedPly];
            } while (![st gameOver]);
         
            int winner = [g winner];
            if (winner) {
                
                /* favour swift victories */
                float skew = pow(0.999, [g countMoves]);
                
                float sc = [player[winner-1] score];
                [player[winner-1] setScore:sc + 2 * skew];
                
                sc = [player[2-winner] score];
                [player[2-winner] setScore:sc - 1 * skew];
            }
            fputc(winner ? ch + winner - 1 : '-', stderr);
            
            [g release];
            [pool release];
        }
        fputc(',', stderr);
    }

    fprintf(stderr, " %.2f sec; avg ply: %.2lf; ", (double)-[date timeIntervalSinceNow], (float)ply/(float)moves);
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
        for (gen = 0; gen < 50; gen++) {
            [arr addObject:[[Connect4NNEvaluator new] autorelease]];
        }
        gen = 0;
    }
    [arr retain];

    if (!arr)
        [NSException raise:@"missing population" format:@"No population of NNs."];

    do {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];

        arr = breed([arr autorelease]);
        rate(arr);
        
        arr = cull(arr);
        write_generation_to_file(arr, ++gen);

        [arr retain];
        [pool release];
    } while (1);
    return 0;
}
