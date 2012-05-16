//
//  MDSpreadViewSectionDescriptor.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 11/11/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewSectionDescriptor.h"
#import "MDSpreadViewCellDescriptor.h"

@implementation MDSpreadViewSectionDescriptor

@synthesize baseIndex;

- (id)init
{
    if (self = [super init]) {
        cells = [[NSMutableArray alloc] init];
        headerCell = [[MDSpreadViewCellDescriptor alloc] init];
        footerCell = [[MDSpreadViewCellDescriptor alloc] init];
        cachedSize = 0;
    }
    return self;
}

- (void)setCount:(NSUInteger)count
{
    if ([cells count] > count) {
        int difference = [cells count]-count;
        for (int i = 0; i < difference; i++) {
            MDSpreadViewCellDescriptor *cell = [cells lastObject];
            cachedSize -= cell.size;
        }
        [cells removeObjectsInRange:NSMakeRange(count, difference)];
    } else {
        int difference = count-[cells count];
        for (int i = 0; i < difference; i++) {
            MDSpreadViewCellDescriptor *cell = [[MDSpreadViewCellDescriptor alloc] init];
            [cells addObject:cell];
            [cell release];
        }
    }
}

- (NSUInteger)count
{
    return [cells count];
}

- (CGFloat)sectionSize
{
    return cachedSize;
}

- (CGFloat)headerCellSize
{
    return headerCell.size;
}

- (void)setHeaderCellSize:(CGFloat)headerCellSize
{
    headerCell.size = headerCellSize;
}

- (CGFloat)footerCellSize
{
    return footerCell.size;
}

- (void)setFooterCellSize:(CGFloat)footerCellSize
{
    footerCell.size = footerCellSize;
}

- (void)setSize:(CGFloat)size forCellAtIndex:(NSUInteger)index
{
    if (index < [cells count]) {
        MDSpreadViewCellDescriptor *cell = [cells objectAtIndex:index];
        cachedSize = cachedSize-cell.size+size;
        cell.size = size;
    }
}

- (CGFloat)sizeOfCellAtIndex:(NSUInteger)index
{
    if (index < [cells count]) {
        MDSpreadViewCellDescriptor *cell = [cells objectAtIndex:index];
        return cell.size;
    }
    return 0;
}

- (void)dealloc
{
    [cells release];
    [headerCell release];
    [footerCell release];
    [super dealloc];
}

@end
