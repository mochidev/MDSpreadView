//
//  MDSpreadViewColumnDescriptor.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewColumnDescriptor.h"
#import "MDSpreadViewRowSectionDescriptor.h"

@implementation MDSpreadViewColumnDescriptor

@synthesize rowSections;

- (id)init
{
    if (self = [super init]) {
        rowSections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count
{
    return [rowSections count];
}

- (void)setCount:(NSUInteger)count
{
    NSUInteger oldCount = [rowSections count];
    if (count > oldCount) {
        for (int i = 0; i < count-oldCount; i++) {
            [rowSections addObject:[NSNull null]];
        }
    } else if (count < oldCount) {
        [rowSections removeObjectsInRange:NSMakeRange(count, oldCount-count)];
    }
}

- (MDSpreadViewRowSectionDescriptor *)cellAtIndex:(NSUInteger)index
{
    if (index < [rowSections count]) {
        id obj = [rowSections objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}

- (void)setSection:(MDSpreadViewRowSectionDescriptor *)section atIndex:(NSUInteger)index
{
    if (index > [rowSections count]) self.count = index+1;
    id obj = section;
    if (!obj) obj = [NSNull null];
    [rowSections replaceObjectAtIndex:index withObject:obj];
}

- (void)dealloc
{
    [rowSections release];
    [super dealloc];
}

@end
