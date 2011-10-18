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
            MDSpreadViewRowSectionDescriptor *rowSectionDescriptor = [[MDSpreadViewRowSectionDescriptor alloc] init];
            [rowSections addObject:rowSectionDescriptor];
            [rowSectionDescriptor release];
        }
    } else if (count < oldCount) {
        [rowSections removeObjectsInRange:NSMakeRange(count, oldCount-count)];
    }
}

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection
{
    if (rowSection < rowSections.count) {
        MDSpreadViewRowSectionDescriptor *section = [rowSections objectAtIndex:rowSection];
        section.count = count;
    }
}

- (NSUInteger)rowCountForSection:(NSUInteger)rowSection
{
    if (rowSection < rowSections.count) {
        MDSpreadViewRowSectionDescriptor *section = [rowSections objectAtIndex:rowSection];
        return section.count;
    }
    return 0;
}

- (MDSpreadViewRowSectionDescriptor *)sectionAtIndex:(NSUInteger)index
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
    if (index >= [rowSections count]) self.count = index+1;
    id obj = section;
    if (!obj) obj = [NSNull null];
    [rowSections replaceObjectAtIndex:index withObject:obj];
}

- (void)dealloc
{
    [rowSections release];
    [super dealloc];
}

- (NSArray *)allCells
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    
    for (MDSpreadViewRowSectionDescriptor *rowSection in rowSections) {
        [allCells addObjectsFromArray:[rowSection allCells]];
    }
    
    return [allCells autorelease];
}

- (void)clearAllCells
{
    for (MDSpreadViewRowSectionDescriptor *rowSection in rowSections) {
        [rowSection clearAllCells];
    }
}

@end
