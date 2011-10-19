//
//  MDSpreadViewRowSectionDescriptor.m
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

#import "MDSpreadViewRowSectionDescriptor.h"
#import "MDSpreadViewCell.h"

@implementation MDSpreadViewRowSectionDescriptor

@synthesize cells, headerCell;

- (id)init
{
    if (self = [super init]) {
        cells = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count
{
    return [cells count];
}

- (void)setCount:(NSUInteger)count
{
    NSUInteger oldCount = [cells count];
    if (count > oldCount) {
        for (int i = 0; i < count-oldCount; i++) {
            [cells addObject:[NSNull null]];
        }
    } else if (count < oldCount) {
        for (int i = count; i < oldCount; i++) {
            id cell = [cells objectAtIndex:i];
            if (cell != [NSNull null])
                [cell removeFromSuperview];
        }
        [cells removeObjectsInRange:NSMakeRange(count, oldCount-count)];
    }
}

- (MDSpreadViewCell *)cellAtIndex:(NSUInteger)index
{
    if (index < [cells count]) {
        id obj = [cells objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}

- (void)setCell:(MDSpreadViewCell *)cell atIndex:(NSUInteger)index
{
    if (index >= [cells count]) self.count = index+1;
    id obj = cell;
    if (!obj) obj = [NSNull null];
    [cells replaceObjectAtIndex:index withObject:obj];
}

- (void)dealloc
{
    [headerCell release];
    [cells release];
    [super dealloc];
}

- (NSArray *)allCells
{
    NSMutableArray *allCells = [[NSMutableArray alloc] init];
    
    if (self.headerCell) {
        [allCells addObject:headerCell];
    }
    
    for (MDSpreadViewCell *cell in cells) {
        if ((NSNull *)cell != [NSNull null]) {
            [allCells addObject:cell];
        }
    }
    
    return [allCells autorelease];
}

- (void)clearAllCells
{
    NSUInteger oldCount = self.count;
    self.count = 0;
    self.count = oldCount;
    [self.headerCell removeFromSuperview];
    self.headerCell = nil;
}

@end
