//
//  MDSpreadViewRowSectionDescriptor.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewRowSectionDescriptor.h"
#import "MDSpreadViewCell.h"

@implementation MDSpreadViewRowSectionDescriptor

@synthesize cells, headerCell;

- (id)init
{
    if (self = [super init]) {
        cells = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count
{
    return [cells count];
}

- (void)setCount:(NSUInteger)count
{
    NSUInteger oldCount = [cells count];
    if (count > oldCount) {
        for (int i = 0; i < count-oldCount; i++) {
            [cells addObject:[NSNull null]];
        }
    } else if (count < oldCount) {
        [cells removeObjectsInRange:NSMakeRange(count, oldCount-count)];
    }
}

- (MDSpreadViewCell *)cellAtIndex:(NSUInteger)index
{
    if (index < [cells count]) {
        id obj = [cells objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}

- (void)setCell:(MDSpreadViewCell *)cell atIndex:(NSUInteger)index
{
    if (index > [cells count]) self.count = index+1;
    id obj = cell;
    if (!obj) obj = [NSNull null];
    [cells replaceObjectAtIndex:index withObject:obj];
}

- (void)dealloc
{
    [headerCell release];
    [cells release];
    [super dealloc];
}

@end
