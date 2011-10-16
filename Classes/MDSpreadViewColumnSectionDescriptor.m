//
//  MDSpreadViewColumnSectionDescriptor.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewColumnSectionDescriptor.h"
#import "MDSpreadViewColumnDescriptor.h"

@implementation MDSpreadViewColumnSectionDescriptor

@synthesize columns, headerColumn;

- (id)init
{
    if (self = [super init]) {
        columns = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count
{
    return [columns count];
}

- (void)setCount:(NSUInteger)count
{
    NSUInteger oldCount = [columns count];
    if (count > oldCount) {
        for (int i = 0; i < count-oldCount; i++) {
            [columns addObject:[NSNull null]];
        }
    } else if (count < oldCount) {
        [columns removeObjectsInRange:NSMakeRange(count, oldCount-count)];
    }
}

- (MDSpreadViewColumnDescriptor *)columnAtIndex:(NSUInteger)index
{
    if (index < [columns count]) {
        id obj = [columns objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}

- (void)setColumn:(MDSpreadViewColumnDescriptor *)column atIndex:(NSUInteger)index
{
    if (index > [columns count]) self.count = index+1;
    id obj = column;
    if (!obj) obj = [NSNull null];
    [columns replaceObjectAtIndex:index withObject:obj];
}

- (void)dealloc
{
    [headerColumn release];
    [columns release];
    [super dealloc];
}

@end
