#import "Connect4State.h"

void f(NSMutableSet *set, id s, long *states)
{
    id pool = [[NSAutoreleasePool alloc] init];
    id m, iter = [[s movesAvailable] objectEnumerator];
    while (m = [iter nextObject]) {
        [s applyMove:m];
        if ([set count] < 10000)
            f(set, s, states);
        [s undoMove:m];
    }
    
    [set addObject:[s asString]];
    if (!(++*states % 10000))
        fprintf(stderr, "Tried %ld states; found %d unique\n", *states, [set count]);
    
    [pool release];
}


int main(void)
{
    id pool = [[NSAutoreleasePool alloc] init];
    long states = 0;
    NSMutableSet *set = [NSMutableSet set];
    f(set, [Connect4State new], &states);
    
    id o, iter = [set objectEnumerator];
    while (o = [iter nextObject])
        printf("%s\n", [o UTF8String]);
        
    [pool release];
    return 1;
}
