#include <assert.h>

#import <Foundation/Foundation.h>

#import <SBPerceptron/SBPerceptron.h>
#import <SBAlphaBeta/SBAlphaBeta.h>

int main(int argc, char **argv)
{
    if (argc < 2) {
        NSLog(@"need some arguments");
        exit(-1);
    }
    
    id pool = [[NSAutoreleasePool alloc] init];
    id path = [NSString stringWithUTF8String:argv[1]];
    id trainingSet = [NSString stringWithContentsOfFile:path
        encoding:NSASCIIStringEncoding
        error:NULL];

    id lines = [trainingSet componentsSeparatedByString:@"\n"];
    [lines removeLastObject];

    id set = [NSMutableArray arrayWithCapacity:[lines count]];
    id o, iter = [lines objectEnumerator];
    while (o = [iter nextObject]) {
        id input = [o componentsSeparatedByString:@":"];
        id output = [NSArray arrayWithObject:[input lastObject]];
        [input removeLastObject];
        [set addObject:[NSArray arrayWithObjects:input, output, nil]];
    }

    id net = [SBPerceptron netWithLayers:@"42,70,1"];
    [net setOutputRangeMin:0.0 max:5000000.0];
    [net setProgressRate:10];
    [net setMomentumRate:0.3];
    [net setEpsilon:0.000001];
    [net trainWithData:set];
    id input = [[set lastObject] objectAtIndex:0];
    id output = [[set lastObject] lastObject];
    NSLog(@"%@:%@", output, [net computeOutput:input]);

    [pool release];
    return 0;
}
