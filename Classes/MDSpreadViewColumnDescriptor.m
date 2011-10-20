//
//  MDSpreadViewColumnDescriptor.m
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
        return [rowSections objectAtIndex:index];
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
