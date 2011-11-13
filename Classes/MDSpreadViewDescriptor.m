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
        columnAxis = [[MDSpreadViewAxisDescriptor alloc] init];
        rowAxis = [[MDSpreadViewAxisDescriptor alloc] init];
        
        columns = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [columns release];
    [columnAxis release];
    [rowAxis release];
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

- (MDSpreadViewCell *)setCell:(MDSpreadViewCell *)cell forColumnIndex:(NSUInteger)columnIndex rowIndex:(NSUInteger)rowIndex
{
    NSInteger difference = columnIndex+1-[columns count];
    if (columnIndex >= [columns count]) {
        for (NSUInteger i = 0; i < difference; i++) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [columns addObject:array];
            [array release];
        }
    }
    
    NSMutableArray *rows = [columns objectAtIndex:columnIndex];
    difference = rowIndex+1-[rows count];
    if (rowIndex >= [rows count]) {
        for (NSUInteger i = 0; i < difference; i++) {
            [rows addObject:[NSNull null]];
        }
    }
    
    MDSpreadViewCell *oldCell = [rows objectAtIndex:rowIndex];
    if ((NSNull *)oldCell == [NSNull null]) {
        oldCell = nil;
    } else {
        [oldCell retain];
        oldCell.hidden = YES;
        [oldCell removeFromSuperview];
    }
    
    if (cell) {
        [rows replaceObjectAtIndex:rowIndex withObject:cell];
    } else {
        [rows replaceObjectAtIndex:rowIndex withObject:[NSNull null]];
    }
    return [oldCell autorelease];
}

- (MDSpreadViewCell *)cellForColumnIndex:(NSUInteger)columnIndex rowIndex:(NSUInteger)rowIndex
{
    if (columnIndex < [columns count]) {
        NSMutableArray *rows = [columns objectAtIndex:columnIndex];
        if (rowIndex < [rows count]) {
            MDSpreadViewCell *cell = [rows objectAtIndex:rowIndex];
            if ((NSNull *)cell != [NSNull null]) {
                return cell;
            }
        }
    }
    return nil;
}

- (MDSpreadViewCell *)setCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    return [self setCell:cell forColumnIndex:[columnAxis linearIndexForCellAtIndexPath:columnPath]
                                    rowIndex:[rowAxis linearIndexForCellAtIndexPath:rowPath]];
}

- (MDSpreadViewCell *)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    return [self setCell:cell forColumnIndex:[columnAxis linearIndexForHeaderAtIndex:columnSection]
                                    rowIndex:[rowAxis linearIndexForHeaderAtIndex:rowSection]];
}

- (MDSpreadViewCell *)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    return [self setCell:cell forColumnIndex:[columnAxis linearIndexForCellAtIndexPath:columnPath]
                                    rowIndex:[rowAxis linearIndexForHeaderAtIndex:section]];
}

- (MDSpreadViewCell *)setHeaderCell:(MDSpreadViewCell *)cell forColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath
{
    return [self setCell:cell forColumnIndex:[columnAxis linearIndexForHeaderAtIndex:section]
                                    rowIndex:[rowAxis linearIndexForCellAtIndexPath:rowPath]];
}

- (MDSpreadViewCell *)cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    return [self cellForColumnIndex:[columnAxis linearIndexForCellAtIndexPath:columnPath]
                           rowIndex:[rowAxis linearIndexForCellAtIndexPath:rowPath]];
}

- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    return [self cellForColumnIndex:[columnAxis linearIndexForHeaderAtIndex:columnSection]
                           rowIndex:[rowAxis linearIndexForHeaderAtIndex:rowSection]];
}

- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    return [self cellForColumnIndex:[columnAxis linearIndexForCellAtIndexPath:columnPath]
                           rowIndex:[rowAxis linearIndexForHeaderAtIndex:section]];
}

- (MDSpreadViewCell *)cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath
{
    return [self cellForColumnIndex:[columnAxis linearIndexForHeaderAtIndex:section]
                           rowIndex:[rowAxis linearIndexForCellAtIndexPath:rowPath]];
}

- (NSArray *)allCells
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    
    for (NSMutableArray *rowArray in columns) {
        for (id cell in rowArray) {
            if (cell != [NSNull null]) {
                [allCells addObject:cell];
            }
        }
    }
    
    return [allCells autorelease];
}

- (NSArray *)clearAllCells
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    
    for (NSMutableArray *rowArray in columns) {
        for (id cell in rowArray) {
            if (cell != [NSNull null]) {
                [allCells addObject:cell];
                [cell removeFromSuperview];
            }
        }
    }
    
    [columns removeAllObjects];
    return [allCells autorelease];
}

- (NSArray *)allCellsForHeaderColumnForSection:(NSUInteger)section
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    NSUInteger columnIndex = [columnAxis linearIndexForHeaderAtIndex:section];
    
    if (columnIndex < [columns count]) {
        NSMutableArray *rowArray = [columns objectAtIndex:columnIndex];
        
        for (id cell in rowArray) {
            if (cell != [NSNull null]) {
                [allCells addObject:cell];
            }
        }
    }
    
    return [allCells autorelease];
}

- (NSArray *)allCellsForColumnAtIndexPath:(NSIndexPath *)columnPath
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    NSUInteger columnIndex = [columnAxis linearIndexForCellAtIndexPath:columnPath];
    
    if (columnIndex < [columns count]) {
        NSMutableArray *rowArray = [columns objectAtIndex:columnIndex];
        
        for (id cell in rowArray) {
            if (cell != [NSNull null]) {
                [allCells addObject:cell];
            }
        }
    }
    
    return [allCells autorelease];
}

- (NSArray *)clearHeaderColumnForSection:(NSUInteger)section
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    NSUInteger columnIndex = [columnAxis linearIndexForHeaderAtIndex:section];
    
    if (columnIndex < [columns count]) {
        NSMutableArray *rowArray = [columns objectAtIndex:columnIndex];
        
        for (NSUInteger i = 0; i < [rowArray count]; i++) {
            MDSpreadViewCell *cell = [rowArray objectAtIndex:i];
            if ((NSNull *)cell != [NSNull null]) {
                [cell removeFromSuperview];
                cell.hidden = YES;
                [allCells addObject:cell];
                [rowArray replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        }
    }
    
    return [allCells autorelease];
}

- (NSArray *)clearColumnAtIndexPath:(NSIndexPath *)columnPath
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    NSUInteger columnIndex = [columnAxis linearIndexForCellAtIndexPath:columnPath];
    
    if (columnIndex < [columns count]) {
        NSMutableArray *rowArray = [columns objectAtIndex:columnIndex];
        
        for (NSUInteger i = 0; i < [rowArray count]; i++) {
            MDSpreadViewCell *cell = [rowArray objectAtIndex:i];
            if ((NSNull *)cell != [NSNull null]) {
                [cell removeFromSuperview];
                cell.hidden = YES;
                [allCells addObject:cell];
                [rowArray replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        }
    }
    
    return [allCells autorelease];
}

@end
