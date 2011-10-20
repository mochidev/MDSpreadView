//
//  MDSpreadViewColumnSectionDescriptor.m
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
        return [columns objectAtIndex:index];
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
