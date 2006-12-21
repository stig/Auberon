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

#import "Connect4Move.h"


@implementation Connect4Move


+ (id)moveWithCol:(unsigned)col
{
    return [[[self alloc] initWithCol:col] autorelease];
}

- (id)initWithCol:(unsigned)col
{
    if (self = [super init]) {
        if (col > 6 || col < 0) {
            [NSException raise:@"illegal move"
                        format:@"move not in the legal range"];
        }
        column = col;
    }
    return self;
}

- (unsigned)col
{
    return column;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%u)", column];
}

@end
