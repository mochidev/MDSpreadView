//
//  MDSpreadViewDescriptor.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
//  Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.
//  
//  Also, it'd be super awesome if you credited this page in your about screen :)
//  

#import "MDSpreadViewDescriptor.h"
#import "MDSpreadViewColumnSectionDescriptor.h"
#import "MDSpreadViewColumnDescriptor.h"
#import "MDSpreadViewRowSectionDescriptor.h"

@implementation MDSpreadViewDescriptor

@synthesize columnSections;

- (id)init
{
    if (self = [super init]) {
        columnSections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)columnSectionCount
{
    return [columnSections count];
}

- (void)setColumnSectionCount:(NSUInteger)count
{
    NSUInteger oldCount = [columnSections count];
    if (count > oldCount) {
        for (int i = 0; i < count-oldCount; i++) {
            MDSpreadViewColumnSectionDescriptor *columnSectionDescriptor = [[MDSpreadViewColumnSectionDescriptor alloc] init];
            columnSectionDescriptor.rowSectionCount = rowSectionCount;
            [columnSections addObject:columnSectionDescriptor];
            [columnSectionDescriptor release];
        }
    } else if (count < oldCount) {
        [columnSections removeObjectsInRange:NSMakeRange(count, oldCount-count)];
    }
}

- (MDSpreadViewColumnSectionDescriptor *)sectionAtIndex:(NSUInteger)index
{
    if (index < [columnSections count]) {
        id obj = [columnSections objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}

- (void)setSection:(MDSpreadViewColumnSectionDescriptor *)section atIndex:(NSUInteger)index
{
    if (index >= [columnSections count]) self.columnSectionCount = index+1;
    id obj = section;
    if (!obj) {
        obj = [[[MDSpreadViewColumnSectionDescriptor alloc] init] autorelease];
        [(MDSpreadViewColumnSectionDescriptor *)obj setRowSectionCount:rowSectionCount];
    }
    [columnSections replaceObjectAtIndex:index withObject:obj];
}

- (void)dealloc
{
    [columnSections release];
    [super dealloc];
}

- (NSUInteger)rowSectionCount
{
    return rowSectionCount;
}

- (void)setRowSectionCount:(NSUInteger)count
{
    rowSectionCount = count;
    
    for (MDSpreadViewColumnSectionDescriptor *section in columnSections) {
        section.rowSectionCount = count;
    }
}

- (void)setColumnCount:(NSUInteger)count forSection:(NSUInteger)columnSection
{
    if (columnSection < columnSections.count) {
        MDSpreadViewColumnSectionDescriptor *section = [columnSections objectAtIndex:columnSection];
        section.columnCount = count;
    }
}

- (NSUInteger)columnCountForSection:(NSUInteger)columnSection
{
    if (columnSection < columnSections.count) {
        MDSpreadViewColumnSectionDescriptor *section = [columnSections objectAtIndex:columnSection];
        return section.columnCount;
    }
    return 0;
}

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection
{
    for (MDSpreadViewColumnSectionDescriptor *section in columnSections) {
        [section setRowCount:count forSection:rowSection];
    }
}

- (NSUInteger)rowCountForSection:(NSUInteger)rowSection
{
    if ([columnSections count] > 0) {
        return [(MDSpreadViewColumnSectionDescriptor *)[columnSections objectAtIndex:0] rowCountForSection:rowSection];
    }
    return 0;
}

- (void)setCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:columnPath.section];
    MDSpreadViewColumnDescriptor *column = [columnSection columnAtIndex:columnPath.column];
    MDSpreadViewRowSectionDescriptor *rowSection = [column sectionAtIndex:rowPath.section];
    [rowSection setCell:cell atIndex:rowPath.row];
}

- (void)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    MDSpreadViewColumnSectionDescriptor *columnSectionDesc = [columnSections objectAtIndex:columnSection];
    MDSpreadViewColumnDescriptor *column = columnSectionDesc.headerColumn;
    MDSpreadViewRowSectionDescriptor *rowSectionDesc = [column sectionAtIndex:rowSection];
    rowSectionDesc.headerCell = cell;
}

- (void)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:columnPath.section];
    MDSpreadViewColumnDescriptor *column = [columnSection columnAtIndex:columnPath.column];
    MDSpreadViewRowSectionDescriptor *rowSection = [column sectionAtIndex:section];
    rowSection.headerCell = cell;
}

- (void)setHeaderCell:(MDSpreadViewCell *)cell forColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:section];
    MDSpreadViewColumnDescriptor *column = columnSection.headerColumn;
    MDSpreadViewRowSectionDescriptor *rowSection = [column sectionAtIndex:rowPath.section];
    [rowSection setCell:cell atIndex:rowPath.row];
}

- (MDSpreadViewCell *)cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:columnPath.section];
    MDSpreadViewColumnDescriptor *column = [columnSection columnAtIndex:columnPath.column];
    MDSpreadViewRowSectionDescriptor *rowSection = [column sectionAtIndex:rowPath.section];
    return [rowSection cellAtIndex:rowPath.row];
}

- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    MDSpreadViewColumnSectionDescriptor *columnSectionDesc = [columnSections objectAtIndex:columnSection];
    MDSpreadViewColumnDescriptor *column = columnSectionDesc.headerColumn;
    MDSpreadViewRowSectionDescriptor *rowSectionDesc = [column sectionAtIndex:rowSection];
    return rowSectionDesc.headerCell;
}

- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:columnPath.section];
    MDSpreadViewColumnDescriptor *column = [columnSection columnAtIndex:columnPath.column];
    MDSpreadViewRowSectionDescriptor *rowSection = [column sectionAtIndex:section];
    return rowSection.headerCell;
}

- (MDSpreadViewCell *)cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:section];
    MDSpreadViewColumnDescriptor *column = columnSection.headerColumn;
    MDSpreadViewRowSectionDescriptor *rowSection = [column sectionAtIndex:rowPath.section];
    return [rowSection cellAtIndex:rowPath.row];
}

- (NSArray *)allCells
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    
    for (MDSpreadViewColumnSectionDescriptor *columnSection in columnSections) {
        [allCells addObjectsFromArray:[columnSection allCells]];
    }
    
    return [allCells autorelease];
}

- (void)clearAllCells
{
    for (MDSpreadViewColumnSectionDescriptor *columnSection in columnSections) {
        [columnSection clearAllCells];
    }
}

- (NSArray *)allCellsForHeaderColumnForSection:(NSUInteger)section
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:section];
    return [columnSection.headerColumn allCells];
}

- (NSArray *)allCellsForColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:columnPath.section];
    MDSpreadViewColumnDescriptor *column = [columnSection columnAtIndex:columnPath.column];
    return [column allCells];
}

- (void)clearHeaderColumnForSection:(NSUInteger)section
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:section];
    [columnSection.headerColumn clearAllCells];
}

- (void)clearColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewColumnSectionDescriptor *columnSection = [columnSections objectAtIndex:columnPath.section];
    MDSpreadViewColumnDescriptor *column = [columnSection columnAtIndex:columnPath.column];
    [column clearAllCells];
}

@end
