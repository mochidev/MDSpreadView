//
//  MDSpreadView.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
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

#import "MDSpreadView.h"
#import "NSIndexPath+MDSpreadView.h"
#import "MDSpreadViewCell.h"
#import "MDSpreadViewHeaderCell.h"
#import "MDSpreadViewDescriptor.h"
#import "MDSpreadViewColumnSectionDescriptor.h"
#import "MDSpreadViewColumnDescriptor.h"
#import "MDSpreadViewRowSectionDescriptor.h"

@interface MDSpreadView ()

- (void)_performInit;

- (CGFloat)_widthForColumnHeaderInSection:(NSInteger)columnSection;

- (NSInteger)_numberOfColumnsInSection:(NSInteger)section;
- (NSInteger)_numberOfRowsInSection:(NSInteger)section;
- (NSInteger)_numberOfColumnSections;
- (NSInteger)_numberOfRowSections;

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

@end

@implementation MDSpreadView

#pragma mark - Setup

@synthesize dataSource=_dataSource, rowHeight, columnWidth, sectionColumnHeaderWidth, sectionRowHeaderHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _performInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _performInit];
    }
    return self;
}

- (void)_performInit
{
    self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.directionalLockEnabled = YES;
    
    dequeuedCells = [[NSMutableSet alloc] init];
    descriptor = [[MDSpreadViewDescriptor alloc] init];
    
    rowHeight = 25;
    sectionRowHeaderHeight = 22;
    columnWidth = 220;
    sectionColumnHeaderWidth = 110;
    
    selectedRow = NSNotFound;
    selectedSection = NSNotFound;
    
    anchorCell = [[UIView alloc] init];
    anchorCell.hidden = YES;
    [self addSubview:anchorCell];
    [anchorCell release];
    
    anchorRowHeaderCell = [[UIView alloc] init];
    anchorRowHeaderCell.hidden = YES;
    [self addSubview:anchorRowHeaderCell];
    [anchorRowHeaderCell release];
    
    anchorColumnHeaderCell = [[UIView alloc] init];
    anchorColumnHeaderCell.hidden = YES;
    [self addSubview:anchorColumnHeaderCell];
    [anchorColumnHeaderCell release];
    
    anchorCornerHeaderCell = [[UIView alloc] init];
    anchorCornerHeaderCell.hidden = YES;
    [self addSubview:anchorCornerHeaderCell];
    [anchorCornerHeaderCell release];
}

- (id<MDSpreadViewDelegate>)delegate
{
    return (id<MDSpreadViewDelegate>)super.delegate;
}

- (void)setDelegate:(id<MDSpreadViewDelegate>)delegate
{
    super.delegate = delegate;
}

- (void)dealloc
{
    [descriptor release];
    [dequeuedCells release];
    [super dealloc];
}

#pragma mark - Data

- (void)reloadData
{
    CGSize calculatedSize = CGSizeZero;
    
    NSUInteger numberOfColumnSections = [self _numberOfColumnSections];
    NSUInteger numberOfRowSections = [self _numberOfRowSections];
    
    descriptor.columnSectionCount = numberOfColumnSections;
    descriptor.rowSectionCount = numberOfRowSections;
    
    for (NSUInteger i = 0; i < numberOfColumnSections; i++) {
        NSUInteger numberOfColumns = [self _numberOfColumnsInSection:i];
        calculatedSize.width += self.sectionColumnHeaderWidth + numberOfColumns*self.columnWidth;
        [descriptor setColumnCount:numberOfColumns forSection:i];
    }
    
    for (NSUInteger i = 0; i < numberOfRowSections; i++) {
        NSUInteger numberOfRows = [self _numberOfRowsInSection:i];
        calculatedSize.height += self.sectionRowHeaderHeight + numberOfRows*self.rowHeight;
        [descriptor setRowCount:numberOfRows forSection:i];
    }
    
    NSArray *allCells = [descriptor allCells];
    for (MDSpreadViewCell *cell in allCells) {
        cell.hidden = YES;
    }
    [dequeuedCells addObjectsFromArray:allCells];
    [descriptor clearAllCells];
    
    calculatedSize.width -= 1;
    calculatedSize.height -= 1;
    
    self.contentSize = calculatedSize;
    
//    if (selectedSection != NSNotFound || selectedRow!= NSNotFound) {
//        if (selectedSection > numberOfSections || selectedRow > [self tableView:self numberOfRowsInSection:selectedSection]) {
//            [self deselectRow:selectedRow inSection:selectedSection];
//            [self tableView:self didSelectRow:selectedRow inSection:selectedSection];
//        }
//    }
    
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint offset = self.contentOffset;
    CGSize boundsSize = self.bounds.size;
    
    NSUInteger numberOfColumnSections = [descriptor columnSectionCount];
    NSUInteger numberOfRowSections = [descriptor rowSectionCount];
    
    CGPoint cellOrigin = CGPointZero;
    CGRect cellFrame;
    
    CGFloat headerWidth = self.sectionColumnHeaderWidth;
    CGFloat headerHeight = self.sectionRowHeaderHeight;
    CGFloat cellWidth = self.columnWidth;
    CGFloat cellHeight = self.rowHeight;
    
    for (int columnSection = 0; columnSection < numberOfColumnSections; columnSection++) {
//        headerWidth = [self _widthForColumnHeaderInSection:section];
        NSUInteger numberOfColumns = [descriptor columnCountForSection:columnSection];
        cellOrigin.y = 0;
        
        if (cellOrigin.x + headerWidth + cellWidth * numberOfColumns < offset.x || cellOrigin.x >= offset.x+boundsSize.width) {
            NSArray *allCells = [descriptor allCellsForHeaderColumnForSection:columnSection];
            for (MDSpreadViewCell *cell in allCells) {
                cell.hidden = YES;
            }
            if (allCells) [dequeuedCells addObjectsFromArray:allCells];
            [descriptor clearHeaderColumnForSection:columnSection];
        } else {
            for (int rowSection = 0; rowSection < numberOfRowSections; rowSection++) {
                NSUInteger numberOfRows = [descriptor rowCountForSection:rowSection];
                cellFrame = CGRectZero;
                
                if (cellOrigin.x >= offset.x) {
                    cellFrame.origin.x = cellOrigin.x;
                } else if (cellOrigin.x + cellWidth * numberOfColumns < offset.x) {
                    cellFrame.origin.x = cellOrigin.x + cellWidth * numberOfColumns;
                } else {
                    cellFrame.origin.x = offset.x;
                }
                
                if (cellOrigin.y + headerHeight + cellHeight * numberOfRows < offset.y || cellOrigin.y >= offset.y+boundsSize.height) {
                    MDSpreadViewCell *cell = [descriptor cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                    cell.hidden = YES;
                    if (cell) [dequeuedCells addObject:cell];
                    [descriptor setHeaderCell:nil forRowSection:rowSection forColumnSection:columnSection];
                } else {
                    MDSpreadViewCell *cell = [descriptor cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                    
                    if (!cell) {
                        cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                        [descriptor setHeaderCell:cell forRowSection:rowSection forColumnSection:columnSection];
                    }
                    
                    cellFrame.size = CGSizeMake(headerWidth, headerHeight);
                    
                    if (cellOrigin.y >= offset.y) {
                        cellFrame.origin.y = cellOrigin.y;
                    } else if (cellOrigin.y + cellHeight * numberOfRows < offset.y) {
                        cellFrame.origin.y = cellOrigin.y + cellHeight * numberOfRows;
                    } else {
                        cellFrame.origin.y = offset.y;
                    }
                    
                    [cell setFrame:cellFrame];
                    
                    cell.hidden = NO;
                    if ([cell superview] != self) {
                        [self insertSubview:cell aboveSubview:anchorCornerHeaderCell];
                    }
                }
                
                cellOrigin.y += headerHeight;
                cellFrame.size = CGSizeMake(headerWidth, cellHeight);
                
                for (int row = 0; row < numberOfRows; row++) {
                    NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:rowSection];
                    if (cellOrigin.y + cellHeight < offset.y || cellOrigin.y >= offset.y+boundsSize.height) {
                        MDSpreadViewCell *cell = [descriptor cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
                        cell.hidden = YES;
                        if (cell) [dequeuedCells addObject:cell];
                        [descriptor setHeaderCell:nil forColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
                    } else {
                        MDSpreadViewCell *cell = [descriptor cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
                        
                        if (!cell) {
                            cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
                            [descriptor setHeaderCell:cell forColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
                        }
                        
                        cellFrame.origin.y = cellOrigin.y;
                        
                        [cell setFrame:cellFrame];
                        
                        cell.hidden = NO;
                        if ([cell superview] != self) {
                            [self insertSubview:cell aboveSubview:anchorColumnHeaderCell];
                        }
                    }
                    cellOrigin.y += cellHeight;
                }
            }
        }
        
        cellOrigin.x += headerWidth;
        
        for (int column = 0; column < numberOfColumns; column++) {
            cellOrigin.y = 0;
            NSIndexPath *columnPath = [NSIndexPath indexPathForColumn:column inSection:columnSection];
            if (cellOrigin.x + columnWidth < offset.x || cellOrigin.x >= offset.x+boundsSize.width) {
                NSArray *allCells = [descriptor allCellsForColumnAtIndexPath:columnPath];
                for (MDSpreadViewCell *cell in allCells) {
                    cell.hidden = YES;
                }
                if (allCells) [dequeuedCells addObjectsFromArray:allCells];
                [descriptor clearColumnAtIndexPath:columnPath];
            } else {
                for (int rowSection = 0; rowSection < numberOfRowSections; rowSection++) {
                    NSUInteger numberOfRows = [descriptor rowCountForSection:rowSection];
                    if (cellOrigin.y + headerHeight + cellHeight * numberOfRows < offset.y || cellOrigin.y >= offset.y+boundsSize.height) {
                        MDSpreadViewCell *cell = [descriptor cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
                        cell.hidden = YES;
                        if (cell) [dequeuedCells addObject:cell];
                        [descriptor setHeaderCell:nil forRowSection:rowSection forColumnAtIndexPath:columnPath];
                    } else {
                        MDSpreadViewCell *cell = [descriptor cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
                        
                        if (!cell) {
                            cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
                            [descriptor setHeaderCell:cell forRowSection:rowSection forColumnAtIndexPath:columnPath];
                        }
                        
                        cellFrame = CGRectMake(cellOrigin.x, 0, cellWidth, headerHeight);
                        
                        if (cellOrigin.y >= offset.y) {
                            cellFrame.origin.y = cellOrigin.y;
                        } else if (cellOrigin.y + cellHeight * numberOfRows < offset.y) {
                            cellFrame.origin.y = cellOrigin.y + cellHeight * numberOfRows;
                        } else {
                            cellFrame.origin.y = offset.y;
                        }
                        
                        [cell setFrame:cellFrame];
                        
                        cell.hidden = NO;
                        if ([cell superview] != self) {
                            [self insertSubview:cell aboveSubview:anchorRowHeaderCell];
                        }
                    }
                    
                    cellOrigin.y += headerHeight;
                    cellFrame = CGRectMake(cellOrigin.x, cellOrigin.y, cellWidth, cellHeight);
                    
                    for (int row = 0; row < numberOfRows; row++) {
                        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:rowSection];
                        if (cellOrigin.y + rowHeight < offset.y || cellOrigin.y >= offset.y+boundsSize.height) {
                            MDSpreadViewCell *cell = [descriptor cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                            cell.hidden = YES;
                            if (cell) [dequeuedCells addObject:cell];
                            [descriptor setCell:nil forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                        } else {
                            MDSpreadViewCell *cell = [descriptor cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                            
                            if (!cell) {
                                cell = [self _cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                                [descriptor setCell:cell forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                                
                                cellFrame.origin.y = cellOrigin.y;
                                [cell setFrame:cellFrame];
                                
                                cell.hidden = NO;
                                [self insertSubview:cell aboveSubview:anchorCell];
                            } else {
                                cell.hidden = NO;
                            }
                        }
                        cellOrigin.y += cellHeight;
                    }
                }
            }
            
            cellOrigin.x += cellWidth;
        }
    }
    
//    NSLog(@"views: %d", self.subviews.count);
}

- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    MDSpreadViewCell *dequeuedCell = nil;
    for (MDSpreadViewCell *aCell in dequeuedCells) {
        if ([aCell.reuseIdentifier isEqualToString:identifier]) {
            dequeuedCell = aCell;
            break;
        }
    }
    if (dequeuedCell) {
        [dequeuedCell retain];
        [dequeuedCells removeObject:dequeuedCell];
        [dequeuedCell prepareForReuse];
    }
    return [dequeuedCell autorelease];
}

#pragma mark - Fetchers

- (CGFloat)_widthForColumnHeaderInSection:(NSInteger)columnSection
{
    NSInteger returnValue = self.sectionColumnHeaderWidth;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnHeaderInSection:)])
        returnValue = [self.delegate spreadView:self widthForColumnHeaderInSection:columnSection];
    
    return returnValue;
}

- (NSInteger)_numberOfColumnsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(spreadView:numberOfColumnsInSection:)])
        returnValue = [_dataSource spreadView:self numberOfColumnsInSection:section];
    
    return returnValue;
}

- (NSInteger)_numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(spreadView:numberOfRowsInSection:)])
        returnValue = [_dataSource spreadView:self numberOfRowsInSection:section];
    
    return returnValue;
}

- (NSInteger)_numberOfColumnSections
{
    NSInteger returnValue = 1;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfColumnSectionsInSpreadView:)])
        returnValue = [_dataSource numberOfColumnSectionsInSpreadView:self];
    
    return returnValue;
}

- (NSInteger)_numberOfRowSections
{
    NSInteger returnValue = 1;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfRowSectionsInSpreadView:)])
        returnValue = [_dataSource numberOfRowSectionsInSpreadView:self];
    
    return returnValue;
}


- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    MDSpreadViewCell *returnValue = nil;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnSection:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_MDDefaultHeaderCornerCell";
        
        MDSpreadViewHeaderCell *cell = (MDSpreadViewHeaderCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                  reuseIdentifier:cellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Corner Header %d-%d", columnSection+1, rowSection+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath
{
    MDSpreadViewCell *returnValue = nil;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInColumnSection:forRowAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInColumnSection:section forRowAtIndexPath:rowPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_MDDefaultHeaderColumnCell";
        
        MDSpreadViewHeaderCell *cell = (MDSpreadViewHeaderCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleColumn
                                                  reuseIdentifier:cellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Column Header %d (%d-%d)", section+1, rowPath.section+1, rowPath.row+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewCell *returnValue = nil;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:section forColumnAtIndexPath:columnPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_MDDefaultHeaderRowCell";
        
        MDSpreadViewHeaderCell *cell = (MDSpreadViewHeaderCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleRow
                                                  reuseIdentifier:cellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Row Header %d (%d-%d)", section+1, columnPath.section+1, columnPath.row+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewCell *returnValue = nil;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(spreadView:cellForRowAtIndexPath:forColumnAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_MDDefaultCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Test Row %d-%d (%d-%d)", rowPath.section+1, rowPath.row+1, columnPath.section+1, columnPath.row+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
    
    return returnValue;
}

//
//- (void)tableView:(MDSectionedTableView *)tableView didSelectRow:(NSUInteger)row inSection:(NSUInteger)section
//{
//    if (delegate && [delegate respondsToSelector:@selector(tableView:didSelectRow:inSection:)])
//        [delegate tableView:tableView didSelectRow:row inSection:section];
//}

#pragma mark - Selection

- (NSIndexPath *)indexPathForSelectedRow
{
    return [NSIndexPath indexPathForRow:selectedRow inSection:selectedSection];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    
}

@end
