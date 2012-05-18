//
//  MDSpreadView.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
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

- (void)_clearCell:(MDSpreadViewCell *)cell;
- (void)_clearCellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (void)_clearAllCells;

- (NSInteger)_relativeIndexOfRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)_relativeIndexOfColumnAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)_relativeIndexOfHeaderRowInSection:(NSInteger)rowSection;
- (NSInteger)_relativeIndexOfHeaderColumnInSection:(NSInteger)columnSection;

@property (nonatomic, retain) NSIndexPath *_visibleRowIndexPath;
@property (nonatomic, retain) NSIndexPath *_visibleColumnIndexPath;

- (MDSpreadViewCell *)_visibleCellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (void)_setVisibleCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;

-(void)_selectedRow:(id)sender;
-(void)_didSelectRowAtIndexPath:(NSIndexPath *)indexPath forColumnIndex:(NSIndexPath *)columnPath;

@end

@implementation MDSpreadView

#pragma mark - Setup

@synthesize dataSource=_dataSource, rowHeight, columnWidth, sectionColumnHeaderWidth, sectionRowHeaderHeight, _visibleRowIndexPath, _visibleColumnIndexPath;

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
    visibleCells = [[NSMutableArray alloc] init];
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
    [anchorCell release];
    
    anchorColumnHeaderCell = [[UIView alloc] init];
//    anchorColumnHeaderCell.hidden = YES;
    [self addSubview:anchorColumnHeaderCell];
    [anchorColumnHeaderCell release];
    
    anchorRowHeaderCell = [[UIView alloc] init];
//    anchorRowHeaderCell.hidden = YES;
    [self addSubview:anchorRowHeaderCell];
    [anchorRowHeaderCell release];
    
    anchorCornerHeaderCell = [[UIView alloc] init];
//    anchorCornerHeaderCell.hidden = YES;
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
    [_visibleRowIndexPath release];
    [_visibleColumnIndexPath release];
    [visibleCells release];
    [descriptor release];
    [dequeuedCells release];
    [super dealloc];
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
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    implementsRowHeight = YES;
    implementsRowHeaderHeight = YES;
    implementsColumnWidth = YES;
    implementsColumnHeaderWidth = YES;
    
    NSUInteger numberOfColumnSections = [self _numberOfColumnSections];
    NSUInteger numberOfRowSections = [self _numberOfRowSections];
    
    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    
    [self _clearAllCells];
    [visibleCells removeAllObjects];
    
    visibleBounds.size = CGSizeZero;
    
    self._visibleColumnIndexPath = nil;
    self._visibleRowIndexPath = nil;
    
    for (NSUInteger i = 0; i < numberOfColumnSections; i++) {
        NSUInteger numberOfColumns = [self _numberOfColumnsInSection:i];
        
        totalWidth += [self _widthForColumnHeaderInSection:i];
        
        if (!_visibleColumnIndexPath && totalWidth > visibleBounds.origin.x) {
            self._visibleColumnIndexPath = [NSIndexPath indexPathForColumn:i inSection:-1];
        }
        
        for (NSUInteger j = 0; j < numberOfColumns; j++) {
            totalWidth += [self _widthForColumnAtIndexPath:[NSIndexPath indexPathForColumn:j inSection:i]];
            
            if (!_visibleColumnIndexPath && totalWidth > visibleBounds.origin.x) {
                self._visibleColumnIndexPath = [NSIndexPath indexPathForColumn:i inSection:j];
            }
        }
    }
    
    for (NSUInteger i = 0; i < numberOfRowSections; i++) {
        NSUInteger numberOfRows = [self _numberOfRowsInSection:i];
        
        totalHeight += [self _heightForRowHeaderInSection:i];
        
        if (!_visibleRowIndexPath && totalWidth > visibleBounds.origin.y) {
            self._visibleRowIndexPath = [NSIndexPath indexPathForRow:i inSection:-1];
        }
        
        for (NSUInteger j = 0; j < numberOfRows; j++) {
            totalHeight += [self _heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            if (!_visibleRowIndexPath && totalWidth > visibleBounds.origin.y) {
                self._visibleRowIndexPath = [NSIndexPath indexPathForRow:i inSection:-1];
            }
        }
    }
    
    if (!self._visibleColumnIndexPath) {
        visibleBounds.origin.x = 0;
        self._visibleColumnIndexPath = [NSIndexPath indexPathForColumn:0 inSection:-1];
    }
    
    if (!self._visibleRowIndexPath) {
        visibleBounds.origin.y = 0;
        self._visibleRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:-1];
    }
    
    self.contentOffset = visibleBounds.origin;
    self.contentSize = CGSizeMake(totalWidth-1, totalHeight-1);
    
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
    
    [pool drain];
    
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

#pragma mark - Layout

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
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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
        [pool drain];
    }
    
    [CATransaction commit];
    
//    NSLog(@"views: %d", self.subviews.count);
}

- (CGRect)cellRectForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    NSUInteger numberOfColumnSections = [descriptor columnSectionCount];
    NSUInteger numberOfRowSections = [descriptor rowSectionCount];
    
    CGRect cellFrame = CGRectZero;
    
    for (int columnSection = 0; columnSection < numberOfColumnSections; columnSection++) {
        NSUInteger numberOfColumns = [descriptor columnCountForSection:columnSection];
        
        if (columnSection < columnPath.section) {
            cellFrame.origin.x += [descriptor widthForEntireColumnSection:columnSection];
        } else {
            cellFrame.origin.x += [descriptor widthForHeaderColumnInSection:columnSection];
            for (int column = 0; column < numberOfColumns; column++) {
                if (column < columnPath.column) {
                    cellFrame.origin.x += [descriptor widthForColumnAtIndexPath:[NSIndexPath indexPathForColumn:column inSection:columnSection]];
                } else {
                    cellFrame.size.width = [descriptor widthForColumnAtIndexPath:columnPath];
                    break;
                }
            }
            break;
        }
    }
    
    for (int rowSection = 0; rowSection < numberOfRowSections; rowSection++) {
        NSUInteger numberOfRows = [descriptor rowCountForSection:rowSection];
        
        if (rowSection < rowPath.section) {
            cellFrame.origin.y += [descriptor heightForEntireRowSection:rowSection];
        } else {
            cellFrame.origin.y += [descriptor heightForHeaderRowInSection:rowSection];
            for (int row = 0; row < numberOfRows; row++) {
                if (row < rowPath.row) {
                    cellFrame.origin.y += [descriptor heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:rowSection]];
                } else {
                    cellFrame.size.height = [descriptor heightForRowAtIndexPath:rowPath];
                    break;
                }
            }
            break;
        }
    }
    
    return cellFrame;
}

#pragma mark - Cell Management

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

- (NSInteger)_relativeIndexOfRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfSections = indexPath.section - _visibleRowIndexPath.section;
    
    NSInteger returnIndex = 0;
    
    if (numberOfSections == 0) {
        returnIndex += indexPath.row-_visibleRowIndexPath.row;
    } else if (numberOfSections > 0) {
        for (int i = _visibleRowIndexPath.section; i <= indexPath.section; i++) {
            if (i == _visibleRowIndexPath.section) {
                returnIndex += [self _numberOfRowsInSection:i]-_visibleRowIndexPath.row+1;
            } else if (i == indexPath.section) {
                returnIndex += indexPath.row + 1;
            } else {
                returnIndex += [self _numberOfRowsInSection:i] + 2;
            }
        }
    } else {
        for (int i = _visibleRowIndexPath.section; i >= indexPath.section; i--) {
            if (i == _visibleRowIndexPath.section) {
                returnIndex -= _visibleRowIndexPath.row+1;
            } else if (i == indexPath.section) {
                returnIndex -= [self _numberOfRowsInSection:i] - indexPath.row + 1;
            } else {
                returnIndex -= [self _numberOfRowsInSection:i] + 2;
            }
        }
    }
    
    return returnIndex;
}

- (NSInteger)_relativeIndexOfColumnAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfSections = indexPath.section - _visibleColumnIndexPath.section;
    
    NSInteger returnIndex = 0;
    
    if (numberOfSections == 0) {
        returnIndex += indexPath.column-_visibleColumnIndexPath.column;
    } else if (numberOfSections > 0) {
        for (int i = _visibleColumnIndexPath.section; i <= indexPath.section; i++) {
            if (i == _visibleColumnIndexPath.section) {
                returnIndex += [self _numberOfColumnsInSection:i]-_visibleColumnIndexPath.column+1;
            } else if (i == indexPath.section) {
                returnIndex += indexPath.column + 1;
            } else {
                returnIndex += [self _numberOfColumnsInSection:i] + 2;
            }
        }
    } else {
        for (int i = _visibleColumnIndexPath.section; i >= indexPath.section; i--) {
            if (i == _visibleColumnIndexPath.section) {
                returnIndex -= _visibleColumnIndexPath.column+1;
            } else if (i == indexPath.section) {
                returnIndex -= [self _numberOfColumnsInSection:i] - indexPath.column + 1;
            } else {
                returnIndex -= [self _numberOfColumnsInSection:i] + 2;
            }
        }
    }
    
    return returnIndex;
}

- (NSInteger)_relativeIndexOfHeaderRowInSection:(NSInteger)rowSection
{
    return [self _relativeIndexOfRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:rowSection]];
}

- (NSInteger)_relativeIndexOfHeaderColumnInSection:(NSInteger)columnSection
{
    return [self _relativeIndexOfColumnAtIndexPath:[NSIndexPath indexPathForColumn:-1 inSection:columnSection]];
}

- (MDSpreadViewCell *)_visibleCellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    NSInteger xIndex = [self _relativeIndexOfColumnAtIndexPath:columnPath];
    NSInteger yIndex = [self _relativeIndexOfRowAtIndexPath:rowPath];
    
    if (xIndex < 0 || yIndex < 0 || xIndex >= visibleCells.count) {
        return nil;
    }
    
    NSMutableArray *column = [visibleCells objectAtIndex:xIndex];
    
    if (yIndex >= column.count) {
        return nil;
    }
    
    id cell = [column objectAtIndex:yIndex];
    
    if ((NSNull *)cell != [NSNull null]) {
        return cell;
    }
    
    return nil;
}

- (void)_setVisibleCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    NSInteger xIndex = [self _relativeIndexOfColumnAtIndexPath:columnPath];
    NSInteger yIndex = [self _relativeIndexOfRowAtIndexPath:rowPath];
    
    if (cell) {
        if (xIndex < 0) {
            NSUInteger count = -xIndex;
            for (int i = 0; i < count; i++) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [visibleCells insertObject:array atIndex:0];
                [array release];
            }
            self._visibleColumnIndexPath = columnPath;
            xIndex = 0;
        } else if (xIndex >= [visibleCells count]) {
            NSUInteger count = xIndex+1-[visibleCells count];
            for (int i = 0; i < count; i++) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [visibleCells insertObject:array atIndex:0];
                [array release];
            }
        }
        
        NSMutableArray *column = [visibleCells objectAtIndex:xIndex];
        
        if (yIndex < 0) {
            NSUInteger count = -yIndex;
            for (int i = 0; i < count; i++) {
                NSNull *null = [NSNull null];
                [column insertObject:null atIndex:0];
                [null release];
            }
            self._visibleRowIndexPath = rowPath;
            yIndex = 0;
        } else if (yIndex >= [column count]) {
            NSUInteger count = yIndex+1-[column count];
            for (int i = 0; i < count; i++) {
                NSNull *null = [NSNull null];
                [column insertObject:null atIndex:0];
                [null release];
            }
        }
        
        [column replaceObjectAtIndex:yIndex withObject:cell];
    } else {
        if (xIndex < 0 || yIndex < 0 || xIndex >= visibleCells.count) {
            return;
        }
        
        NSMutableArray *column = [visibleCells objectAtIndex:xIndex];
        
        if (yIndex >= column.count) {
            return;
        } else if (yIndex == column.count-1) {
            [column removeLastObject];
        } else {
            NSNull *null = [NSNull null];
            [column replaceObjectAtIndex:yIndex withObject:null];
            [null release];
        }
        
        if (xIndex == 0 || xIndex == visibleCells.count-1) {
            BOOL foundCell = NO;
            
            while (!foundCell) {
                NSMutableArray *columnToCheck = [visibleCells objectAtIndex:xIndex];
                if (xIndex > 0) xIndex--; // prepare for next run through
                
                for (id cell in columnToCheck) {
                    if ((NSNull *)cell != [NSNull null]) {
                        foundCell = YES;
                        break;
                    }
                }
                
                if (!foundCell) {
                    [visibleCells removeObject:columnToCheck];
                    
                    if (xIndex == 0) {
                        NSInteger section = self._visibleColumnIndexPath.section;
                        NSInteger column = self._visibleColumnIndexPath.column + 1;
                        NSInteger totalInSection = [self _numberOfColumnsInSection:section];
                        
                        if (column >= totalInSection+1) { // +1 for eventual footer
                            section++;
                            column = -1; // -1 for header
                        }
                    
                        self._visibleColumnIndexPath = [NSIndexPath indexPathForColumn:column inSection:section];
                    }
                }
            }
        }
        
        if (yIndex == 0) {
            BOOL foundCell = NO;
            
            while (!foundCell) {
                for (NSMutableArray *columnToCheck in visibleCells) {
                    NSNull *cell = [columnToCheck objectAtIndex:0];
                    
                    if (cell != [NSNull null]) {
                        foundCell = YES;
                        break;
                    }
                }
                
                if (!foundCell) {
                    for (NSMutableArray *columnToCheck in visibleCells) {
                        [columnToCheck removeObjectAtIndex:0];
                    }
                    
                    NSInteger section = self._visibleRowIndexPath.section;
                    NSInteger row = self._visibleRowIndexPath.row + 1;
                    NSInteger totalInSection = [self _numberOfRowsInSection:section];
                    
                    if (row >= totalInSection+1) { // +1 for eventual footer
                        section++;
                        row = -1; // -1 for header
                    }
                    
                    self._visibleRowIndexPath = [NSIndexPath indexPathForColumn:row inSection:section];
                }
            }
        }
    }
}

- (void)_clearCell:(MDSpreadViewCell *)cell
{
    [cell removeFromSuperview];
    cell.hidden = YES;
    [dequeuedCells addObject:cell];
}

- (void)_clearCellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath
{
    MDSpreadViewCell *cell = [self _visibleCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    
    [cell removeFromSuperview];
    cell.hidden = YES;
    [dequeuedCells addObject:cell];
}

- (void)_clearAllCells
{
    for (NSMutableArray *array in visibleCells) {
        for (MDSpreadViewCell *cell in array) {
            if ((NSNull *)cell != [NSNull null]) {
                [cell removeFromSuperview];
                cell.hidden = YES;
                [dequeuedCells addObject:cell];
            }
        }
    }
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
            cell = [[[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                  reuseIdentifier:cellIdentifier] autorelease];
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
            cell = [[[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleColumn
                                                  reuseIdentifier:cellIdentifier] autorelease];
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
            cell = [[[MDSpreadViewHeaderCell alloc] initWithStyle:MDSpreadViewHeaderCellStyleRow
                                                  reuseIdentifier:cellIdentifier] autorelease];
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
            cell = [[[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"##Test Row %d-%d (%d-%d)", rowPath.section+1, rowPath.row+1, columnPath.section+1, columnPath.row+1];
        // actually, fetch title.
        
        returnValue = cell;
    }
	
	[returnValue setIndexes:[NSArray arrayWithObjects:rowPath, columnPath, nil]];
    
    [returnValue.tapGesture removeTarget:nil action:NULL];
    [returnValue.tapGesture addTarget:self action:@selector(_selectedRow:)];
	
    [returnValue setNeedsLayout];
    
    return returnValue;
}

- (void)_selectedRow:(id)sender
{
	MDSpreadViewCell *cell = (MDSpreadViewCell *)[sender view];
	if ([[cell indexes] count] > 1) {
        [self _didSelectRowAtIndexPath:[[cell indexes] objectAtIndex:0]
                        forColumnIndex:[[cell indexes] objectAtIndex:1]];
	}
}


//
//- (void)tableView:(MDSectionedTableView *)tableView didSelectRow:(NSUInteger)row inSection:(NSUInteger)section
//{
//    if (delegate && [delegate respondsToSelector:@selector(tableView:didSelectRow:inSection:)])
//        [delegate tableView:tableView didSelectRow:row inSection:section];
//}

#pragma mark - Selection

- (void)_didSelectRowAtIndexPath:(NSIndexPath *)indexPath forColumnIndex:(NSIndexPath *)columnPath
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(spreadView:didSelectRowAtIndexPath:forColumnAtIndexPath:)])
		[self.delegate spreadView:self didSelectRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
	
}


- (NSIndexPath *)indexPathForSelectedRow
{
    return [NSIndexPath indexPathForRow:selectedRow inSection:selectedSection];
}

//- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
//{
//    
//}
//
//- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
//{
//    
//}

@end
