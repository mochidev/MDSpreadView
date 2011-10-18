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
        headerColumn = [[MDSpreadViewColumnDescriptor alloc] init];
    }
    return self;
}

- (NSUInteger)columnCount
{
    return [columns count];
}

- (void)setColumnCount:(NSUInteger)count
{
    NSUInteger oldCount = [columns count];
    if (count > oldCount) {
        for (int i = 0; i < count-oldCount; i++) {
            MDSpreadViewColumnDescriptor *columnDescriptor = [[MDSpreadViewColumnDescriptor alloc] init];
            columnDescriptor.count = rowSectionCount;
            [columns addObject:columnDescriptor];
            [columnDescriptor release];
        }
    } else if (count < oldCount) {
        [columns removeObjectsInRange:NSMakeRange(count, oldCount-count)];
    }
}

- (NSUInteger)rowSectionCount
{
    return rowSectionCount;
}

- (void)setRowSectionCount:(NSUInteger)count
{
    rowSectionCount = count;
    self.headerColumn.count = count;
    for (MDSpreadViewColumnDescriptor *column in columns) {
        column.count = count;
    }
}

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection
{
    for (MDSpreadViewColumnDescriptor *column in columns) {
        [column setRowCount:count forSection:rowSection];
    }
}

- (NSUInteger)rowCountForSection:(NSUInteger)rowSection
{
    if ([columns count] > 0) {
        return [(MDSpreadViewColumnDescriptor *)[columns objectAtIndex:0] rowCountForSection:rowSection];
    }
    return 0;
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
    if (index >= [columns count]) self.columnCount = index+1;
    id obj = column;
    if (!obj) {
        obj = [[[MDSpreadViewColumnDescriptor alloc] init] autorelease];
        [(MDSpreadViewColumnDescriptor *)obj setCount:rowSectionCount];
    }
    [columns replaceObjectAtIndex:index withObject:obj];
}

- (void)dealloc
{
    [headerColumn release];
    [columns release];
    [super dealloc];
}

- (NSArray *)allCells
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    
    [allCells addObjectsFromArray:[self.headerColumn allCells]];
    
    for (MDSpreadViewColumnDescriptor *column in columns) {
        [allCells addObjectsFromArray:[column allCells]];
    }
    
    return [allCells autorelease];
}

- (void)clearAllCells
{
    for (MDSpreadViewColumnDescriptor *column in columns) {
        [column clearAllCells];
    }
}

@end
