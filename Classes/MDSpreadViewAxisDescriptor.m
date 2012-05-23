//
//  MDSpreadViewAxisDescriptor.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 11/11/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewAxisDescriptor.h"
#import "MDSpreadViewSectionDescriptor.h"
#import "MDSpreadView.h"

@implementation MDSpreadViewAxisDescriptor

- (id)init
{
    if (self = [super init]) {
        sections = [[NSMutableArray alloc] init];
        cachedSize = 0;
    }
    return self;
}

- (void)setSectionCount:(NSUInteger)count
{
    if ([sections count] > count) {
        int difference = [sections count]-count;
        for (int i = 0; i < difference; i++) {
            MDSpreadViewSectionDescriptor *section = [sections lastObject];
            cachedSize -= section.sectionSize;
        }
        [sections removeObjectsInRange:NSMakeRange(count, difference)];
    } else {
        int difference = count-[sections count];
        for (int i = 0; i < difference; i++) {
            MDSpreadViewSectionDescriptor *section = [[MDSpreadViewSectionDescriptor alloc] init];
            MDSpreadViewSectionDescriptor *lastSection = [sections lastObject];
            if (lastSection)
                section.baseIndex = lastSection.baseIndex + lastSection.count + 2;
            [sections addObject:section];
            [section release];
        }
    }
}

- (NSUInteger)sectionCount
{
    return [sections count];
}

- (CGFloat)axisSize
{
    return cachedSize;
}

- (void)setCellCount:(NSUInteger)count forSectionAtIndex:(NSUInteger)index
{
    if (index < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index];
        NSInteger difference = section.count-count;
        cachedSize -= section.sectionSize;
        section.count = count;
        cachedSize += section.sectionSize;
        for (NSUInteger i = index+1; i < [sections count]; i++) {
            MDSpreadViewSectionDescriptor *nextSection = [sections objectAtIndex:i];
            nextSection.baseIndex -= difference;
        }
    }
}

- (NSUInteger)countOfSectionAtIndex:(NSUInteger)index
{
    if (index < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index];
        return section.count;
    }
    return 0;
}

- (CGFloat)sizeOfSectionAtIndex:(NSUInteger)index
{
    if (index < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index];
        return section.sectionSize;
    }
    return 0;
}

- (void)setSize:(CGFloat)size forCellAtIndexPath:(MDIndexPath *)index
{
    if (index.section < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index.section];
        cachedSize -= section.sectionSize;
        [section setSize:size forCellAtIndex:index.row];
        cachedSize += section.sectionSize;
    }
}

- (CGFloat)sizeOfCellAtIndex:(MDIndexPath *)index
{
    if (index.section < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index.section];
        return [section sizeOfCellAtIndex:index.row];
    }
    return 0;
}

- (void)setSize:(CGFloat)size forHeaderCellAtIndex:(NSUInteger)index
{
    if (index < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index];
        cachedSize = cachedSize-section.headerCellSize+size;
        [section setHeaderCellSize:size];
    }
}

- (CGFloat)sizeOfHeaderCellAtIndex:(NSUInteger)index
{
    if (index < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index];
        return section.headerCellSize;
    }
    return 0;
}

- (void)setSize:(CGFloat)size forFooterCellAtIndex:(NSUInteger)index
{
    if (index < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index];
        cachedSize = cachedSize-section.footerCellSize+size;
        [section setFooterCellSize:size];
    }
}

- (CGFloat)sizeOfFooterCellAtIndex:(NSUInteger)index
{
    if (index < [sections count]) {
        MDSpreadViewSectionDescriptor *section = [sections objectAtIndex:index];
        return section.footerCellSize;
    }
    return 0;
}


- (NSUInteger)linearIndexForCellAtIndexPath:(MDIndexPath *)index
{
    MDSpreadViewSectionDescriptor *section = nil;
    if (index.section < [sections count]) {
        section = [sections objectAtIndex:index.section];
    } else {
        section = [sections lastObject];
    }
    
    return section.baseIndex + 1 + index.row; // 1 for header
}

- (NSUInteger)linearIndexForHeaderAtIndex:(NSUInteger)index
{
    MDSpreadViewSectionDescriptor *section = nil;
    NSUInteger baseIndex = 0;
    if (index < [sections count]) {
        section = [sections objectAtIndex:index];
        baseIndex = section.baseIndex;
    } else {
        section = [sections lastObject];
        baseIndex = section.baseIndex + section.count + 2;
    }
    
    return baseIndex;
}

- (NSUInteger)linearIndexForFooterAtIndex:(NSUInteger)index
{
    MDSpreadViewSectionDescriptor *section = nil;
    NSUInteger baseIndex = 0;
    if (index < [sections count]) {
        section = [sections objectAtIndex:index];
        baseIndex = section.baseIndex + section.count + 1;
    } else {
        section = [sections lastObject];
        baseIndex = section.baseIndex + section.count + 3;
    }
    
    return baseIndex;
}

- (void)dealloc
{
    [sections release];
    [super dealloc];
}

@end
