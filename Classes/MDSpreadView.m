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

@interface MDSpreadView ()

- (void)_performInit;

- (CGFloat)_widthForColumnHeaderInSection:(NSInteger)columnSection;
- (CGFloat)_widthForColumnAtIndexPath:(NSIndexPath *)columnPath;
- (CGFloat)_heightForRowHeaderInSection:(NSInteger)rowSection;
- (CGFloat)_heightForRowAtIndexPath:(NSIndexPath *)rowPath;

- (NSInteger)_numberOfColumnsInSection:(NSInteger)section;
- (NSInteger)_numberOfRowsInSection:(NSInteger)section;
- (NSInteger)_numberOfColumnSections;
- (NSInteger)_numberOfRowSections;

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

-(void)_selectedRow:(id)sender;
-(void)_didSelectRowAtIndexPath:(NSIndexPath *)indexPath forColumnIndex:(NSIndexPath *)columnPath;

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
//    anchorCell.hidden = YES;
    [self addSubview:anchorCell];
    
    anchorColumnHeaderCell = [[UIView alloc] init];
//    anchorColumnHeaderCell.hidden = YES;
    [self addSubview:anchorColumnHeaderCell];
    
    anchorRowHeaderCell = [[UIView alloc] init];
//    anchorRowHeaderCell.hidden = YES;
    [self addSubview:anchorRowHeaderCell];
    
    anchorCornerHeaderCell = [[UIView alloc] init];
//    anchorCornerHeaderCell.hidden = YES;
    [self addSubview:anchorCornerHeaderCell];
}

- (id<MDSpreadViewDelegate>)delegate
{
    return (id<MDSpreadViewDelegate>)super.delegate;
}

- (void)setDelegate:(id<MDSpreadViewDelegate>)delegate
{
    super.delegate = delegate;
}


#pragma mark - Data

- (void)setRowHeight:(CGFloat)newHeight
{
    rowHeight = newHeight;
    
    if (implementsRowHeight) return;
    
    NSUInteger numberOfRowSections = descriptor.rowSectionCount;
    
    for (NSUInteger i = 0; i < numberOfRowSections; i++) {
        NSUInteger numberOfRows = [descriptor rowCountForSection:i];
        
        for (NSUInteger j = 0; j < numberOfRows; j++) {
            [descriptor setHeight:rowHeight forRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
        }
    }
    
    self.contentSize = CGSizeMake(descriptor.totalWidth-1, descriptor.totalHeight-1);
    [self layoutSubviews];
}

- (void)setSectionRowHeaderHeight:(CGFloat)newHeight
{
    sectionRowHeaderHeight = newHeight;
    
    if (implementsRowHeaderHeight) return;
    
    NSUInteger numberOfRowSections = descriptor.rowSectionCount;
    
    for (NSUInteger i = 0; i < numberOfRowSections; i++) {
        [descriptor setHeight:sectionRowHeaderHeight forHeaderRowInSection:i];
    }
    
    self.contentSize = CGSizeMake(descriptor.totalWidth-1, descriptor.totalHeight-1);
    [self layoutSubviews];
}

- (void)setColumnWidth:(CGFloat)newWidth
{
    columnWidth = newWidth;
    
    if (implementsColumnWidth) return;
    
    NSUInteger numberOfColumnSections = descriptor.columnSectionCount;
    
    for (NSUInteger i = 0; i < numberOfColumnSections; i++) {
        NSUInteger numberOfColumns = [descriptor columnCountForSection:i];
        
        for (NSUInteger j = 0; j < numberOfColumns; j++) {
            [descriptor setWidth:columnWidth forColumnAtIndexPath:[NSIndexPath indexPathForColumn:j inSection:i]];
        }
    }
    
    self.contentSize = CGSizeMake(descriptor.totalWidth-1, descriptor.totalHeight-1);
    [self layoutSubviews];
}

- (void)setSectionColumnHeaderWidth:(CGFloat)newWidth
{
    sectionColumnHeaderWidth = newWidth;
    
    NSUInteger numberOfColumnSections = descriptor.columnSectionCount;
    
    for (NSUInteger i = 0; i < numberOfColumnSections; i++) {
        [descriptor setWidth:sectionColumnHeaderWidth forHeaderColumnInSection:i];
    }
    
    self.contentSize = CGSizeMake(descriptor.totalWidth-1, descriptor.totalHeight-1);
    [self layoutSubviews];
}

- (void)reloadData
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    implementsRowHeight = YES;
    implementsRowHeaderHeight = YES;
    implementsColumnWidth = YES;
    implementsColumnHeaderWidth = YES;
    
    NSUInteger numberOfColumnSections = [self _numberOfColumnSections];
    NSUInteger numberOfRowSections = [self _numberOfRowSections];
    
    descriptor.columnSectionCount = numberOfColumnSections;
    descriptor.rowSectionCount = numberOfRowSections;
    
    for (NSUInteger i = 0; i < numberOfColumnSections; i++) {
        NSUInteger numberOfColumns = [self _numberOfColumnsInSection:i];
        
        [descriptor setColumnCount:numberOfColumns forSection:i];
        [descriptor setWidth:[self _widthForColumnHeaderInSection:i] forHeaderColumnInSection:i];
        
        for (NSUInteger j = 0; j < numberOfColumns; j++) {
            NSIndexPath *path = [NSIndexPath indexPathForColumn:j inSection:i];
            [descriptor setWidth:[self _widthForColumnAtIndexPath:path] forColumnAtIndexPath:path];
        }
    }
    
    for (NSUInteger i = 0; i < numberOfRowSections; i++) {
        NSUInteger numberOfRows = [self _numberOfRowsInSection:i];
        
        [descriptor setRowCount:numberOfRows forSection:i];
        [descriptor setHeight:[self _heightForRowHeaderInSection:i] forHeaderRowInSection:i];
        
        for (NSUInteger j = 0; j < numberOfRows; j++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:j inSection:i];
            [descriptor setHeight:[self _heightForRowAtIndexPath:path] forRowAtIndexPath:path];
        }
    }
    
    NSArray *allCells = [descriptor clearAllCells];
    for (MDSpreadViewCell *cell in allCells) {
        cell.hidden = YES;
    }
    [dequeuedCells addObjectsFromArray:allCells];
    
    self.contentSize = CGSizeMake(descriptor.totalWidth-1, descriptor.totalHeight-1);
    
//    anchorCell.frame = CGRectMake(0, 0, calculatedSize.width, calculatedSize.height);
//    anchorColumnHeaderCell.frame = CGRectMake(0, 0, calculatedSize.width, calculatedSize.height);
//    anchorCornerHeaderCell.frame = CGRectMake(0, 0, calculatedSize.width, calculatedSize.height);
//    anchorRowHeaderCell.frame = CGRectMake(0, 0, calculatedSize.width, calculatedSize.height);
    
//    if (selectedSection != NSNotFound || selectedRow!= NSNotFound) {
//        if (selectedSection > numberOfSections || selectedRow > [self tableView:self numberOfRowsInSection:selectedSection]) {
//            [self deselectRow:selectedRow inSection:selectedSection];
//            [self tableView:self didSelectRow:selectedRow inSection:selectedSection];
//        }
//    }
    
    
    [self layoutSubviews];
    
    [CATransaction commit];
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView *returnValue = [anchorCornerHeaderCell hitTest:[anchorCornerHeaderCell convertPoint:point fromView:self] withEvent:event];
//    if (returnValue != anchorCornerHeaderCell) return returnValue;
//    
//    returnValue = [anchorRowHeaderCell hitTest:[anchorRowHeaderCell convertPoint:point fromView:self] withEvent:event];
//    if (returnValue != anchorRowHeaderCell) return returnValue;
//    
//    returnValue = [anchorColumnHeaderCell hitTest:[anchorColumnHeaderCell convertPoint:point fromView:self] withEvent:event];
//    if (returnValue != anchorColumnHeaderCell) return returnValue;
//    
//    returnValue = [anchorCell hitTest:[anchorCell convertPoint:point fromView:self] withEvent:event];
//    if (returnValue != anchorCell) return returnValue;
//    
//    return [super hitTest:point withEvent:event];
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [CATransaction setDisableActions:YES];
    
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
    CGFloat columnSectionWidth = 0;
    CGFloat rowSectionHeight = 0;
    
    BOOL hideRestOfColumns = NO;
    BOOL hideRestOfRows = NO;
    
    for (int columnSection = 0; columnSection < numberOfColumnSections; columnSection++) {
        hideRestOfRows = NO;
        NSUInteger numberOfColumns = [descriptor columnCountForSection:columnSection];
        cellOrigin.y = 0;
        
        headerWidth = [descriptor widthForHeaderColumnInSection:columnSection];
        columnSectionWidth = [descriptor widthForEntireColumnSection:columnSection];
        
        if (hideRestOfColumns || headerWidth == 0 || cellOrigin.x + headerWidth + columnSectionWidth < offset.x) {
            NSArray *allCells = [descriptor clearHeaderColumnForSection:columnSection];
            if (allCells) [dequeuedCells addObjectsFromArray:allCells];
        } else if (cellOrigin.x >= offset.x+boundsSize.width) {
            hideRestOfColumns = YES;
            NSArray *allCells = [descriptor clearHeaderColumnForSection:columnSection];
            if (allCells) [dequeuedCells addObjectsFromArray:allCells];
        } else {
            for (int rowSection = 0; rowSection < numberOfRowSections; rowSection++) {
                NSUInteger numberOfRows = [descriptor rowCountForSection:rowSection];
                cellFrame = CGRectZero;
                
                if (cellOrigin.x >= offset.x) {
                    cellFrame.origin.x = cellOrigin.x;
                } else if (cellOrigin.x + columnSectionWidth < offset.x) {
                    cellFrame.origin.x = cellOrigin.x + columnSectionWidth;
                } else {
                    cellFrame.origin.x = offset.x;
                }
                
                headerHeight = [descriptor heightForHeaderRowInSection:rowSection];
                rowSectionHeight = [descriptor heightForEntireRowSection:rowSection];
                
                if (hideRestOfRows || headerHeight == 0 || cellOrigin.y + headerHeight + rowSectionHeight < offset.y) {
                    MDSpreadViewCell *cell = [descriptor setHeaderCell:nil forRowSection:rowSection forColumnSection:columnSection];
                    if (cell) [dequeuedCells addObject:cell];
                } else if (cellOrigin.y >= offset.y+boundsSize.height) {
                    hideRestOfRows = YES;
                    MDSpreadViewCell *cell = [descriptor setHeaderCell:nil forRowSection:rowSection forColumnSection:columnSection];
                    if (cell) [dequeuedCells addObject:cell];
                } else {
                    MDSpreadViewCell *cell = [descriptor cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                    
                    if (!cell) {
                        cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                        [descriptor setHeaderCell:cell forRowSection:rowSection forColumnSection:columnSection];
                    }
                    
                    cellFrame.size = CGSizeMake(headerWidth, headerHeight);
                    
                    if (cellOrigin.y >= offset.y) {
                        cellFrame.origin.y = cellOrigin.y;
                    } else if (cellOrigin.y + rowSectionHeight < offset.y) {
                        cellFrame.origin.y = cellOrigin.y + rowSectionHeight;
                    } else {
                        cellFrame.origin.y = offset.y;
                    }
                    
                    [cell setFrame:cellFrame];
                    
                    cell.hidden = NO;
                    if ([cell superview] != self) {
//                        [anchorCornerHeaderCell addSubview:cell];
//                        [self insertSubview:cell atIndex:[self.subviews indexOfObjectIdenticalTo:anchorCornerHeaderCell]];
                        [self insertSubview:cell belowSubview:anchorCornerHeaderCell];
                    }
                }
                
                cellOrigin.y += headerHeight;
                cellFrame.size.width = headerWidth;
                
                for (int row = 0; row < numberOfRows; row++) {
                    NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:rowSection];
                    cellHeight = [descriptor heightForRowAtIndexPath:rowIndexPath];
                    cellFrame.size.height = cellHeight;
                    
                    if (hideRestOfRows || cellHeight == 0 || cellOrigin.y + cellHeight < offset.y) {
                        MDSpreadViewCell *cell = [descriptor setHeaderCell:nil forColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
                        if (cell) [dequeuedCells addObject:cell];
                    } else if (cellOrigin.y >= offset.y+boundsSize.height) {
                        hideRestOfRows = YES;
                        MDSpreadViewCell *cell = [descriptor setHeaderCell:nil forColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
                        if (cell) [dequeuedCells addObject:cell];
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
//                            [anchorColumnHeaderCell addSubview:cell];
//                            [self insertSubview:cell atIndex:[self.subviews indexOfObjectIdenticalTo:anchorColumnHeaderCell]];
                            [self insertSubview:cell belowSubview:anchorColumnHeaderCell];
                        }
                    }
                    cellOrigin.y += cellHeight;
                }
            }
        }
        
        cellOrigin.x += headerWidth;
        
        for (int column = 0; column < numberOfColumns; column++) {
            hideRestOfRows = NO;
            cellOrigin.y = 0;
            NSIndexPath *columnPath = [NSIndexPath indexPathForColumn:column inSection:columnSection];
            cellWidth = [descriptor widthForColumnAtIndexPath:columnPath];
            
            if (hideRestOfColumns || cellWidth == 0 || cellOrigin.x + cellWidth < offset.x) {
                NSArray *allCells = [descriptor clearColumnAtIndexPath:columnPath];
                if (allCells) [dequeuedCells addObjectsFromArray:allCells];
            } else if (cellOrigin.x >= offset.x+boundsSize.width) {
                hideRestOfColumns = YES;
                NSArray *allCells = [descriptor clearColumnAtIndexPath:columnPath];
                if (allCells) [dequeuedCells addObjectsFromArray:allCells];
            } else {
                for (int rowSection = 0; rowSection < numberOfRowSections; rowSection++) {
                    NSUInteger numberOfRows = [descriptor rowCountForSection:rowSection];
                    
                    headerHeight = [descriptor heightForHeaderRowInSection:rowSection];
                    rowSectionHeight = [descriptor heightForEntireRowSection:rowSection];
                    
                    if (hideRestOfRows || headerHeight == 0 || cellOrigin.y + headerHeight + rowSectionHeight < offset.y) {
                        MDSpreadViewCell *cell = [descriptor setHeaderCell:nil forRowSection:rowSection forColumnAtIndexPath:columnPath];
                        if (cell) [dequeuedCells addObject:cell];
                    } else if (cellOrigin.y >= offset.y+boundsSize.height) {
                        hideRestOfRows = YES;
                        MDSpreadViewCell *cell = [descriptor setHeaderCell:nil forRowSection:rowSection forColumnAtIndexPath:columnPath];
                        if (cell) [dequeuedCells addObject:cell];
                    } else {
                        MDSpreadViewCell *cell = [descriptor cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
                        
                        if (!cell) {
                            cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
                            [descriptor setHeaderCell:cell forRowSection:rowSection forColumnAtIndexPath:columnPath];
                        }
                        
                        cellFrame = CGRectMake(cellOrigin.x, 0, cellWidth, headerHeight);
                        
                        if (cellOrigin.y >= offset.y) {
                            cellFrame.origin.y = cellOrigin.y;
                        } else if (cellOrigin.y + rowSectionHeight < offset.y) {
                            cellFrame.origin.y = cellOrigin.y + rowSectionHeight;
                        } else {
                            cellFrame.origin.y = offset.y;
                        }
                        
                        [cell setFrame:cellFrame];
                        
                        cell.hidden = NO;
                        if ([cell superview] != self) {
//                            [anchorRowHeaderCell addSubview:cell];
//                            [self insertSubview:cell atIndex:[self.subviews indexOfObjectIdenticalTo:anchorRowHeaderCell]];
                            [self insertSubview:cell belowSubview:anchorRowHeaderCell];
                        }
                    }
                    
                    cellOrigin.y += headerHeight;
                    cellFrame = CGRectMake(cellOrigin.x, cellOrigin.y, cellWidth, cellHeight);
                    
                    for (int row = 0; row < numberOfRows; row++) {
                        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:rowSection];
                        cellHeight = [descriptor heightForRowAtIndexPath:rowIndexPath];
                        cellFrame.size.height = cellHeight;
                        
                        if (hideRestOfRows || cellHeight == 0 || cellOrigin.y + cellHeight < offset.y) {
                            MDSpreadViewCell *cell = [descriptor setCell:nil forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                            if (cell) [dequeuedCells addObject:cell];
                        } else if (cellOrigin.y >= offset.y+boundsSize.height) {
                            hideRestOfRows = YES;
                            MDSpreadViewCell *cell = [descriptor setCell:nil forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                            if (cell) [dequeuedCells addObject:cell];
                        } else {
                            MDSpreadViewCell *cell = [descriptor cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                            
                            if (!cell) {
                                cell = [self _cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                                [descriptor setCell:cell forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnPath];
                            }
                                
                            cellFrame.origin.y = cellOrigin.y;
                            [cell setFrame:cellFrame];
                                
                            cell.hidden = NO;
                            if ([cell superview] != self) {
//                                [anchorCell addSubview:cell];
//                                [self insertSubview:cell atIndex:[self.subviews indexOfObjectIdenticalTo:anchorCell]];
                                [self insertSubview:cell belowSubview:anchorCell];
                            }
                        }
                        cellOrigin.y += cellHeight;
                    }
                }
            }
            
            cellOrigin.x += cellWidth;
        }
    }
    
    [CATransaction commit];
    
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
        [dequeuedCells removeObject:dequeuedCell];
        [dequeuedCell prepareForReuse];
    }
    return dequeuedCell;
}

#pragma mark - Fetchers

#pragma Sizes
- (CGFloat)_widthForColumnHeaderInSection:(NSInteger)columnSection
{
    if (implementsColumnHeaderWidth && self.delegate && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnHeaderInSection:)]) {
        return [self.delegate spreadView:self widthForColumnHeaderInSection:columnSection];
    } else {
        implementsColumnHeaderWidth = NO;
    }
    
    return self.sectionColumnHeaderWidth;
}

- (CGFloat)_widthForColumnAtIndexPath:(NSIndexPath *)columnPath
{
    if (implementsColumnWidth && self.delegate && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnAtIndexPath:)]) {
        return [self.delegate spreadView:self widthForColumnAtIndexPath:columnPath];
    } else {
        implementsColumnWidth = NO;
    }
    
    return self.columnWidth;
}

- (CGFloat)_heightForRowHeaderInSection:(NSInteger)rowSection
{
    if (implementsRowHeaderHeight && self.delegate && [self.delegate respondsToSelector:@selector(spreadView:heightForRowHeaderInSection:)]) {
        return [self.delegate spreadView:self heightForRowHeaderInSection:rowSection];
    } else {
        implementsRowHeaderHeight = NO;
    }
    
    return self.sectionRowHeaderHeight;
}

- (CGFloat)_heightForRowAtIndexPath:(NSIndexPath *)rowPath
{
    if (implementsRowHeight && self.delegate && [self.delegate respondsToSelector:@selector(spreadView:heightForRowAtIndexPath:)]) {
        return [self.delegate spreadView:self heightForRowAtIndexPath:rowPath];
    } else {
        implementsRowHeight = NO;
    }
    
    return self.rowHeight;
}

#pragma Counts
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

#pragma Cells
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    MDSpreadViewCell *returnValue = nil;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnSection:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_MDDefaultHeaderCornerCell";
        
        MDSpreadViewHeaderCell *cell = (MDSpreadViewHeaderCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                  reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Corner Header %d-%d", columnSection+1, rowSection+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
    
    [returnValue setNeedsLayout];
    
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
            cell = [[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleColumn
                                                  reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Column Header %d (%d-%d)", section+1, rowPath.section+1, rowPath.row+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
    
    [returnValue setNeedsLayout];
    
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
            cell = [[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleRow
                                                  reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Row Header %d (%d-%d)", section+1, columnPath.section+1, columnPath.row+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
    
    [returnValue setNeedsLayout];
    
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
            cell = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Test Row %d-%d (%d-%d)", rowPath.section+1, rowPath.row+1, columnPath.section+1, columnPath.row+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
	
	[returnValue setIndexes:[NSArray arrayWithObjects:rowPath,columnPath, nil]];

    
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_selectedRow:)];
	[returnValue addGestureRecognizer:tapGesture];
	
    [returnValue setNeedsLayout];
    
    return returnValue;
}

-(void)_selectedRow:(id)sender{
	MDSpreadViewCell *cell = (MDSpreadViewCell *)[sender view];
	if ([[cell indexes] count] > 1){
	[self _didSelectRowAtIndexPath:[[cell indexes] objectAtIndex:0] forColumnIndex:[[cell indexes] objectAtIndex:1]];
	}
}


//
//- (void)tableView:(MDSectionedTableView *)tableView didSelectRow:(NSUInteger)row inSection:(NSUInteger)section
//{
//    if (delegate && [delegate respondsToSelector:@selector(tableView:didSelectRow:inSection:)])
//        [delegate tableView:tableView didSelectRow:row inSection:section];
//}

#pragma mark - Selection

-(void)_didSelectRowAtIndexPath:(NSIndexPath *)indexPath forColumnIndex:(NSIndexPath *)columnPath{
	if (self.delegate && [self.delegate respondsToSelector:@selector(spreadView:didSelectRowAtIndexPath:forColumnIndex:)])
		[self.delegate spreadView:self didSelectRowAtIndexPath:indexPath forColumnIndex:columnPath];
	
}


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
