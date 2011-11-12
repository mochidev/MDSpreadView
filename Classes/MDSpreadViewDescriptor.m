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
#import "MDSpreadViewCell.h"
#import "MDSpreadViewAxisDescriptor.h"

@implementation MDSpreadViewDescriptor

//@synthesize columnSections;

- (id)init
{
    if (self = [super init]) {
        columnSections = [[NSMutableArray alloc] init];
        
        columnAxis = [[MDSpreadViewAxisDescriptor alloc] init];
        rowAxis = [[MDSpreadViewAxisDescriptor alloc] init];
        
        cells = [[NSMutableDictionary alloc] init];
        columnCells = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [columnCells release];
    [cells release];
    [columnAxis release];
    [rowAxis release];
    [columnSections release];
    [super dealloc];
}

- (NSUInteger)columnSectionCount
{
    return columnAxis.sectionCount;
}

- (void)setColumnSectionCount:(NSUInteger)count
{
    columnAxis.sectionCount = count;
}

- (NSUInteger)rowSectionCount
{
    return rowAxis.sectionCount;
}

- (void)setRowSectionCount:(NSUInteger)count
{
    rowAxis.sectionCount = count;
}

- (void)setColumnCount:(NSUInteger)count forSection:(NSUInteger)columnSection
{
    [columnAxis setCellCount:count forSectionAtIndex:columnSection];
}

- (NSUInteger)columnCountForSection:(NSUInteger)columnSection
{
    return [columnAxis countOfSectionAtIndex:columnSection];
}

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection
{
    [rowAxis setCellCount:count forSectionAtIndex:rowSection];
}

- (NSUInteger)rowCountForSection:(NSUInteger)rowSection
{
    return [rowAxis countOfSectionAtIndex:rowSection];
}

- (void)setCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:[rowAxis linearIndexForCellAtIndexPath:rowPath] inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]];
    MDSpreadViewCell *oldCell = [cells objectForKey:path];
//    if (cell == [cells objectForKey:[NSIndexPath indexPathForRow:2 inSection:1]]) {
//        NSLog(@"[1, 2]: hash for path %@: %d", path, [path hash]);
//    }
    if (cell) {
        [cells setObject:cell forKey:path];
    } else {
        [cells removeObjectForKey:path];
    }
    
    if (oldCell != cell) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:path.section];
        [oldCell removeFromSuperview];
        [self removeCell:oldCell fromColumnIndexPath:indexPath];
        [self addCell:cell toColumnIndexPath:indexPath];
    }
}

- (void)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    MDSpreadViewCell *oldCell = [self cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
    if (cell) {
        [cells setObject:cell forKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForHeaderAtIndex:rowSection] inSection:[columnAxis linearIndexForHeaderAtIndex:columnSection]]];
    } else {
        [cells removeObjectForKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForHeaderAtIndex:rowSection] inSection:[columnAxis linearIndexForHeaderAtIndex:columnSection]]];
    }
    
    if (oldCell != cell) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForHeaderAtIndex:columnSection]];
        [oldCell removeFromSuperview];
        [self removeCell:oldCell fromColumnIndexPath:indexPath];
        [self addCell:cell toColumnIndexPath:indexPath];
    }
}

- (void)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewCell *oldCell = [self cellForHeaderInRowSection:section forColumnAtIndexPath:columnPath];
    if (cell) {
        [cells setObject:cell forKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForHeaderAtIndex:section] inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]]];
    } else {
        [cells removeObjectForKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForHeaderAtIndex:section] inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]]];
    }
    
    if (oldCell != cell) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]];
        [oldCell removeFromSuperview];
        [self removeCell:oldCell fromColumnIndexPath:indexPath];
        [self addCell:cell toColumnIndexPath:indexPath];
    }
}

- (void)setHeaderCell:(MDSpreadViewCell *)cell forColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath
{
    MDSpreadViewCell *oldCell = [self cellForHeaderInColumnSection:section forRowAtIndexPath:rowPath];
    if (cell) {
        [cells setObject:cell forKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForCellAtIndexPath:rowPath] inSection:[columnAxis linearIndexForHeaderAtIndex:section]]];
    } else {
        [cells removeObjectForKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForCellAtIndexPath:rowPath] inSection:[columnAxis linearIndexForHeaderAtIndex:section]]];
    }
    
    if (oldCell != cell) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForHeaderAtIndex:section]];
        [oldCell removeFromSuperview];
        [self removeCell:oldCell fromColumnIndexPath:indexPath];
        [self addCell:cell toColumnIndexPath:indexPath];
    }
}

- (MDSpreadViewCell *)cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    return [cells objectForKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForCellAtIndexPath:rowPath] inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]]];
}

- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    return [cells objectForKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForHeaderAtIndex:rowSection] inSection:[columnAxis linearIndexForHeaderAtIndex:columnSection]]];
}

- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    return [cells objectForKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForHeaderAtIndex:section] inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]]];
}

- (MDSpreadViewCell *)cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath
{
    return [cells objectForKey:[NSIndexPath indexPathForRow:[rowAxis linearIndexForCellAtIndexPath:rowPath] inSection:[columnAxis linearIndexForHeaderAtIndex:section]]];
}

- (NSArray *)allCells
{
    return [cells allValues];
}

- (void)clearAllCells
{
    NSArray *allCells = [cells allValues];
    for (MDSpreadViewCell *cell in allCells) {
        [cell removeFromSuperview];
    }
    [cells removeAllObjects];
    [columnCells removeAllObjects];
}

- (void)addCell:(MDSpreadViewCell *)cell toColumnIndexPath:(NSIndexPath *)path
{
    if (!path) return;
    NSMutableArray *array = [columnCells objectForKey:path];
    if (!array) {
        array = [[NSMutableArray alloc] init];
        [columnCells setObject:array forKey:path];
        [array release];
    }
    if (cell)
        [array addObject:cell];
}

- (void)removeCell:(MDSpreadViewCell *)cell fromColumnIndexPath:(NSIndexPath *)path
{
    if (!path) return;
    NSMutableArray *array = [columnCells objectForKey:path];
    if (cell)
        [array removeObjectIdenticalTo:cell];
    if ([array count] == 0) {
        [columnCells removeObjectForKey:path];
    }
}

- (NSArray *)allCellsForHeaderColumnForSection:(NSUInteger)section
{
    return [columnCells objectForKey:[NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForHeaderAtIndex:section]]];
}

- (NSArray *)allCellsForColumnAtIndexPath:(NSIndexPath *)columnPath
{
    return [columnCells objectForKey:[NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]]];
}

- (void)clearHeaderColumnForSection:(NSUInteger)section
{
    NSMutableArray *headerColumnCells = [columnCells objectForKey:[NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForHeaderAtIndex:section]]];
    
    for (MDSpreadViewCell *cell in headerColumnCells) {
        [cells removeObjectsForKeys:[cells allKeysForObject:cell]];
        [cell removeFromSuperview];
    }
    [headerColumnCells removeAllObjects];
    [columnCells removeObjectForKey:[NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForHeaderAtIndex:section]]];
}

- (void)clearColumnAtIndexPath:(NSIndexPath *)columnPath
{
    NSMutableArray *indexPathColumnCells = [columnCells objectForKey:[NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]]];
    
    for (MDSpreadViewCell *cell in indexPathColumnCells) {
        [cells removeObjectsForKeys:[cells allKeysForObject:cell]];
        [cell removeFromSuperview];
    }
    [indexPathColumnCells removeAllObjects];
    [columnCells removeObjectForKey:[NSIndexPath indexPathForRow:0 inSection:[columnAxis linearIndexForCellAtIndexPath:columnPath]]];
}

@end
