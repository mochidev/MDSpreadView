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

@implementation MDIndexPath

@synthesize section, row;

+ (MDIndexPath *)indexPathForColumn:(NSInteger)b inSection:(NSInteger)a
{
    MDIndexPath *path = [[self alloc] init];
    
    path->section = a;
    path->row = b;
    
    return [path autorelease];
}

+ (MDIndexPath *)indexPathForRow:(NSInteger)b inSection:(NSInteger)a
{
    MDIndexPath *path = [[self alloc] init];
    
    path->section = a;
    path->row = b;
    
    return [path autorelease];
}

- (NSInteger)column
{
    return row;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%d, %d]", section, row];
}

@end

@interface MDSpreadView ()

- (void)_performInit;

- (CGFloat)_widthForColumnHeaderInSection:(NSInteger)columnSection;
- (CGFloat)_widthForColumnAtIndexPath:(MDIndexPath *)columnPath;
- (CGFloat)_widthForColumnFooterInSection:(NSInteger)columnSection;
- (CGFloat)_heightForRowHeaderInSection:(NSInteger)rowSection;
- (CGFloat)_heightForRowAtIndexPath:(MDIndexPath *)rowPath;
- (CGFloat)_heightForRowFooterInSection:(NSInteger)rowSection;

- (NSInteger)_numberOfColumnsInSection:(NSInteger)section;
- (NSInteger)_numberOfRowsInSection:(NSInteger)section;
- (NSInteger)_numberOfColumnSections;
- (NSInteger)_numberOfRowSections;

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

- (void)_clearCell:(MDSpreadViewCell *)cell;
- (void)_clearCellsForColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)_clearCellsForRowAtIndexPath:(MDIndexPath *)rowPath;
- (void)_clearCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)_clearAllCells;

- (void)_layoutColumnAtIndexPath:(MDIndexPath *)columnPath withWidth:(CGFloat)width xOffset:(CGFloat)xOffset;
- (void)_layoutHeaderInColumnSection:(NSInteger)columnSection withWidth:(CGFloat)width xOffset:(CGFloat)xOffset;
- (void)_layoutFooterInColumnSection:(NSInteger)columnSection withWidth:(CGFloat)width xOffset:(CGFloat)xOffset;

- (void)_layoutRowAtIndexPath:(MDIndexPath *)rowPath withHeight:(CGFloat)height yOffset:(CGFloat)yOffset;
- (void)_layoutHeaderInRowSection:(NSInteger)rowSection withHeight:(CGFloat)height yOffset:(CGFloat)yOffset;
- (void)_layoutFooterInRowSection:(NSInteger)rowSection withHeight:(CGFloat)height yOffset:(CGFloat)yOffset;

- (NSInteger)_relativeIndexOfRowAtIndexPath:(MDIndexPath *)indexPath;
- (NSInteger)_relativeIndexOfColumnAtIndexPath:(MDIndexPath *)indexPath;

- (MDIndexPath *)_rowIndexPathFromRelativeIndex:(NSInteger)index;
- (MDIndexPath *)_columnIndexPathFromRelativeIndex:(NSInteger)index;

- (NSInteger)_relativeIndexOfHeaderRowInSection:(NSInteger)rowSection;
- (NSInteger)_relativeIndexOfHeaderColumnInSection:(NSInteger)columnSection;

@property (nonatomic, retain) MDIndexPath *_visibleRowIndexPath;
@property (nonatomic, retain) MDIndexPath *_visibleColumnIndexPath;

- (MDSpreadViewCell *)_visibleCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)_setVisibleCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

-(void)_selectedRow:(id)sender;
-(void)_didSelectRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath;

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
            [descriptor setHeight:rowHeight forRowAtIndexPath:[MDIndexPath indexPathForRow:j inSection:i]];
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
            [descriptor setWidth:columnWidth forColumnAtIndexPath:[MDIndexPath indexPathForColumn:j inSection:i]];
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
            self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:i];
        }
        
        for (NSUInteger j = 0; j < numberOfColumns; j++) {
            totalWidth += [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:j inSection:i]];
            
            if (!_visibleColumnIndexPath && totalWidth > visibleBounds.origin.x) {
                self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:j inSection:i];
            }
        }
    }
    
    for (NSUInteger i = 0; i < numberOfRowSections; i++) {
        NSUInteger numberOfRows = [self _numberOfRowsInSection:i];
        
        totalHeight += [self _heightForRowHeaderInSection:i];
        
        if (!_visibleRowIndexPath && totalWidth > visibleBounds.origin.y) {
            self._visibleRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:i];
        }
        
        for (NSUInteger j = 0; j < numberOfRows; j++) {
            totalHeight += [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:j inSection:i]];
            
            if (!_visibleRowIndexPath && totalWidth > visibleBounds.origin.y) {
                self._visibleRowIndexPath = [MDIndexPath indexPathForRow:j inSection:i];
            }
        }
    }
    
    if (!self._visibleColumnIndexPath) {
        visibleBounds.origin.x = 0;
        self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:0];
    }
    
    if (!self._visibleRowIndexPath) {
        visibleBounds.origin.y = 0;
        self._visibleRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:0];
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
    
    NSUInteger numberOfColumnSections = [self _numberOfColumnSections];
    NSUInteger numberOfRowSections = [self _numberOfRowSections];
    
    CGFloat width;
    CGFloat height;
    MDIndexPath *lastIndexPath;
    
//    NSLog(@"--");
//    NSLog(@"Current Visible Bounds: %@ in actual bounds: %@ offset: %@", NSStringFromCGRect(visibleBounds), NSStringFromCGSize(boundsSize), NSStringFromCGPoint(offset));
    
    @autoreleasepool {
        while (visibleBounds.origin.x > offset.x) { // add columns before
            NSInteger columnSection = self._visibleColumnIndexPath.section;
            NSInteger column = self._visibleColumnIndexPath.column - 1;
            NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
            
            if (column < -1) { // -1 for header
                columnSection--;
                totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
                column = totalInColumnSection; // size of count for eventual footer
            }
            
            if (columnSection < 0) break;
            
            MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:column inSection:columnSection];
            
            width = [self _widthForColumnAtIndexPath:columnPath];
            if (visibleBounds.size.height <= 0) visibleBounds.size.height = [self _heightForRowAtIndexPath:self._visibleRowIndexPath];
            
            visibleBounds.size.width += width;
            visibleBounds.origin.x -= width;
            
            if (column == -1) { // header
                [self _layoutHeaderInColumnSection:columnSection withWidth:width xOffset:visibleBounds.origin.x];
            } else if (column == totalInColumnSection) { // footer
                [self _layoutFooterInColumnSection:columnSection withWidth:width xOffset:visibleBounds.origin.x];
            } else { // cells
                [self _layoutColumnAtIndexPath:columnPath withWidth:width xOffset:visibleBounds.origin.x];
            }
            
//            NSLog(@"Adding cell %d,%d to the left (%d columns)", columnSection, column, visibleCells.count);
//            NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
        }
    }
    
    @autoreleasepool {
        lastIndexPath = self._visibleColumnIndexPath;
        width = [self _widthForColumnAtIndexPath:lastIndexPath];
        
        while (visibleBounds.origin.x+width < offset.x) { // delete left most column
            visibleBounds.size.width -= width;
            if (visibleBounds.size.width < 0) visibleBounds.size.width = 0;
            visibleBounds.origin.x += width;
            
//            MDIndexPath *firstIndexPath = self._visibleColumnIndexPath;
            [self _clearCellsForColumnAtIndexPath:lastIndexPath];
            
//            NSLog(@"Removing cell %d,%d from the left (%d columns)", firstIndexPath.section, firstIndexPath.column, visibleCells.count);
//            NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
            
            if (lastIndexPath == self._visibleColumnIndexPath) break;
            lastIndexPath = self._visibleColumnIndexPath;
            width = [self _widthForColumnAtIndexPath:lastIndexPath];
        }
    }
    
    @autoreleasepool {
        lastIndexPath = [self _columnIndexPathFromRelativeIndex:visibleCells.count-1];
        
        while (visibleBounds.origin.x+visibleBounds.size.width < offset.x+boundsSize.width) { // add columns after
            NSInteger columnSection = lastIndexPath.section;
            NSInteger column = lastIndexPath.column + 1; // get the next index
            NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
            
            if (column >= totalInColumnSection+1) { // +1 for eventual footer
                columnSection++;
                column = -1; // -1 for header
            }
            lastIndexPath = [MDIndexPath indexPathForColumn:column inSection:columnSection]; // set indexpath for next runthrough
            
            if (columnSection >= numberOfColumnSections) break;
            
            MDIndexPath *columnPath = lastIndexPath;
            
            CGFloat width = [self _widthForColumnAtIndexPath:columnPath];
            
            visibleBounds.size.width += width;
            if (visibleBounds.size.height <= 0) visibleBounds.size.height = [self _heightForRowAtIndexPath:self._visibleRowIndexPath];
            
            if (column == -1) { // header
                [self _layoutHeaderInColumnSection:columnSection withWidth:width xOffset:visibleBounds.origin.x+visibleBounds.size.width-width];
            } else if (column == totalInColumnSection) { // footer
                [self _layoutFooterInColumnSection:columnSection withWidth:width xOffset:visibleBounds.origin.x+visibleBounds.size.width-width];
            } else {
                [self _layoutColumnAtIndexPath:columnPath withWidth:width xOffset:visibleBounds.origin.x+visibleBounds.size.width-width];
            }
            
//            NSLog(@"Adding cell %d,%d to the right (%d columns)", columnSection, column, visibleCells.count);
//            NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
        }
    }
    
    
    @autoreleasepool {
        lastIndexPath = [self _columnIndexPathFromRelativeIndex:visibleCells.count-1];
        width = [self _widthForColumnAtIndexPath:lastIndexPath];
        
        while (visibleBounds.origin.x+visibleBounds.size.width-width > offset.x+boundsSize.width) { // delete right most column
            if (lastIndexPath.section == 0 && lastIndexPath.column < -1) break;
            
            visibleBounds.size.width -= width;
            if (visibleBounds.size.width < 0) visibleBounds.size.width = 0;
            
            [self _clearCellsForColumnAtIndexPath:lastIndexPath];
            
//            NSLog(@"Removing cell %d,%d from the right (%d columns)", lastIndexPath.section, lastIndexPath.column, visibleCells.count);
//            NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
            
            lastIndexPath = [self _columnIndexPathFromRelativeIndex:visibleCells.count-1];
            width = [self _widthForColumnAtIndexPath:lastIndexPath];
        }
    }
    
    @autoreleasepool {
        while (visibleBounds.origin.y > offset.y) { // add rows before
            NSInteger rowSection = self._visibleRowIndexPath.section;
            NSInteger row = self._visibleRowIndexPath.row - 1;
            NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
            
            if (row < -1) { // -1 for header
                rowSection--;
                totalInRowSection = [self _numberOfRowsInSection:rowSection];
                row = totalInRowSection; // count for eventual footer
            }
            
            if (rowSection < 0) break;
            
            MDIndexPath *rowPath = [MDIndexPath indexPathForRow:row inSection:rowSection];
            
            height = 0;
            
            if (visibleBounds.size.width) {
                height = [self _heightForRowAtIndexPath:rowPath];
            }
            
            visibleBounds.size.height += height;
            visibleBounds.origin.y -= height;
            
            if (row == -1) { // header
                [self _layoutHeaderInRowSection:rowSection withHeight:height yOffset:visibleBounds.origin.y];
            } else if (row == totalInRowSection) { // footer
                [self _layoutFooterInRowSection:rowSection withHeight:height yOffset:visibleBounds.origin.y];
            } else { // cells
                [self _layoutRowAtIndexPath:rowPath withHeight:height yOffset:visibleBounds.origin.y];
            }
            
//            NSLog(@"Adding cell %d,%d to the top (%d rows)", rowSection, row, [[visibleCells objectAtIndex:0] count]);
//            NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
        }
    }
    
    @autoreleasepool {
        lastIndexPath = self._visibleRowIndexPath;
        height = [self _heightForRowAtIndexPath:lastIndexPath];
        
        while (visibleBounds.origin.y+height < offset.y) { // delete top most row
            visibleBounds.size.height -= height;
            if (visibleBounds.size.height < 0) visibleBounds.size.height = 0;
            visibleBounds.origin.y += height;
            
//            MDIndexPath *firstIndexPath = [[self._visibleRowIndexPath retain] autorelease];
            [self _clearCellsForRowAtIndexPath:lastIndexPath];
            
//            NSLog(@"Removing cell %d,%d from the top (%d rows)", firstIndexPath.section, firstIndexPath.column, [[visibleCells objectAtIndex:0] count]);
//            NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
            
            if (lastIndexPath == self._visibleRowIndexPath) break;
            lastIndexPath = self._visibleRowIndexPath;
            height = [self _heightForRowAtIndexPath:lastIndexPath];
        }
    }
    
    if (visibleCells.count) {
        @autoreleasepool {
            lastIndexPath = [self _rowIndexPathFromRelativeIndex:[[visibleCells objectAtIndex:0] count]-1];
            
            while (visibleBounds.origin.y+visibleBounds.size.height < offset.y+boundsSize.height) { // add rows after
                NSInteger rowSection = lastIndexPath.section;
                NSInteger row = lastIndexPath.row + 1;
                NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
                
                if (row >= totalInRowSection+1) { // +1 for eventual footer
                    rowSection++;
                    row = -1; // -1 for header
                }
                
                lastIndexPath = [MDIndexPath indexPathForRow:row inSection:rowSection];
                
                if (rowSection >= numberOfRowSections) break;
                
                MDIndexPath *rowPath = lastIndexPath;
                
                height = 0;
                
                if (visibleBounds.size.width) {
                    height = [self _heightForRowAtIndexPath:rowPath];
                }
                
                visibleBounds.size.height += height;
                
                if (row == -1) { // header
                    [self _layoutHeaderInRowSection:rowSection withHeight:height yOffset:visibleBounds.origin.y+visibleBounds.size.height-height];
                } else if (row == totalInRowSection) { // footer
                    [self _layoutFooterInRowSection:rowSection withHeight:height yOffset:visibleBounds.origin.y+visibleBounds.size.height-height];
                } else {
                    [self _layoutRowAtIndexPath:rowPath withHeight:height yOffset:visibleBounds.origin.y+visibleBounds.size.height-height];
                }
            
//                NSLog(@"Adding cell %d,%d to the bottom (%d rows)", rowSection, row, [[visibleCells objectAtIndex:0] count]);
//                NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
            }
        }
    
        @autoreleasepool {
            lastIndexPath = [self _rowIndexPathFromRelativeIndex:[[visibleCells objectAtIndex:0] count]-1];
            height = [self _heightForRowAtIndexPath:lastIndexPath];
            
            while (visibleBounds.origin.y+visibleBounds.size.height-height > offset.y+boundsSize.height) { // delete bottom most row
                if (lastIndexPath.section == 0 && lastIndexPath.row < -1) break;
                
                visibleBounds.size.height -= height;
                if (visibleBounds.size.height < 0) visibleBounds.size.height = 0;
                
                [self _clearCellsForRowAtIndexPath:lastIndexPath];

//                NSLog(@"Removing cell %d,%d from the bottom (%d rows)", lastIndexPath.section, lastIndexPath.column, [[visibleCells objectAtIndex:0] count]);
//                NSLog(@"    Current Visible Bounds: %@ in {%@, %@}", NSStringFromCGRect(visibleBounds), NSStringFromCGPoint(offset), NSStringFromCGSize(boundsSize));
                
                lastIndexPath = [self _rowIndexPathFromRelativeIndex:[[visibleCells objectAtIndex:0] count]-1];
                height = [self _heightForRowAtIndexPath:lastIndexPath];
            }
        }
    }
    
    [CATransaction commit];
}

- (void)_layoutColumnAtIndexPath:(MDIndexPath *)columnPath withWidth:(CGFloat)width xOffset:(CGFloat)xOffset
{
    NSInteger rowSection = self._visibleRowIndexPath.section;
    NSInteger row = self._visibleRowIndexPath.row;
    NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
    
    CGFloat constructedHeight = 0;
    UIView *anchor = anchorCell;
    
    while (constructedHeight < visibleBounds.size.height) {
        MDIndexPath *rowPath = [MDIndexPath indexPathForRow:row inSection:rowSection];
        MDSpreadViewCell *cell = nil;
        
        if (row == -1) { // header
            cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
            anchor = anchorRowHeaderCell;
        } else if (row == totalInRowSection) { // footer
            cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
            anchor = anchorRowHeaderCell;
        } else {
            cell = [self _cellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
            anchor = anchorCell;
        }
        
        [self _setVisibleCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
        CGFloat height = [self _heightForRowAtIndexPath:rowPath];
        
        [cell setFrame:CGRectMake(xOffset, visibleBounds.origin.y+constructedHeight, width, height)];
        constructedHeight += height;
        
        cell.hidden = !(width && height);
        if ([cell superview] != self) {
            [self insertSubview:cell belowSubview:anchor];
        }
        
        row++;
        if (row >= totalInRowSection+1) { // +1 for eventual footer
            rowSection++;
            totalInRowSection = [self _numberOfRowsInSection:rowSection];
            row = -1; // -1 for header
        }
    }
}

- (void)_layoutHeaderInColumnSection:(NSInteger)columnSection withWidth:(CGFloat)width xOffset:(CGFloat)xOffset
{
    NSInteger rowSection = self._visibleRowIndexPath.section;
    NSInteger row = self._visibleRowIndexPath.row;
    NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
    
    CGFloat constructedHeight = 0;
    UIView *anchor = anchorColumnHeaderCell;
    MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:-1 inSection:columnSection];
    
    while (constructedHeight < visibleBounds.size.height) {
        MDIndexPath *rowPath = [MDIndexPath indexPathForRow:row inSection:rowSection];
        MDSpreadViewCell *cell = nil;
        
        if (row == -1) { // header
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else if (row == totalInRowSection) { // footer
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else {
            cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowPath];
            anchor = anchorColumnHeaderCell;
        }
        
        [self _setVisibleCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
        CGFloat height = [self _heightForRowAtIndexPath:rowPath];
        
        [cell setFrame:CGRectMake(xOffset, visibleBounds.origin.y+constructedHeight, width, height)];
        constructedHeight += height;
        
        cell.hidden = !(width && height);
        if ([cell superview] != self) {
            [self insertSubview:cell belowSubview:anchor];
        }
        
        row++;
        if (row >= totalInRowSection+1) { // +1 for eventual footer
            rowSection++;
            totalInRowSection = [self _numberOfRowsInSection:rowSection];
            row = -1; // -1 for header
        }
    }
}

- (void)_layoutFooterInColumnSection:(NSInteger)columnSection withWidth:(CGFloat)width xOffset:(CGFloat)xOffset
{
    NSInteger rowSection = self._visibleRowIndexPath.section;
    NSInteger row = self._visibleRowIndexPath.row;
    NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
    
    CGFloat constructedHeight = 0;
    UIView *anchor = anchorColumnHeaderCell;
    MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:[self _numberOfColumnsInSection:columnSection] inSection:columnSection];
    
    while (constructedHeight < visibleBounds.size.height) {
        MDIndexPath *rowPath = [MDIndexPath indexPathForRow:row inSection:rowSection];
        MDSpreadViewCell *cell = nil;
        
        if (row == -1) { // header
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else if (row == totalInRowSection) { // footer
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else {
            cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowPath];
            anchor = anchorColumnHeaderCell;
        }
        
        [self _setVisibleCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
        CGFloat height = [self _heightForRowAtIndexPath:rowPath];
        
        [cell setFrame:CGRectMake(xOffset, visibleBounds.origin.y+constructedHeight, width, height)];
        constructedHeight += height;
        
        cell.hidden = !(width && height);
        if ([cell superview] != self) {
            [self insertSubview:cell belowSubview:anchor];
        }
        
        row++;
        if (row >= totalInRowSection+1) { // +1 for eventual footer
            rowSection++;
            totalInRowSection = [self _numberOfRowsInSection:rowSection];
            row = -1; // -1 for header
        }
    }
}

- (void)_layoutRowAtIndexPath:(MDIndexPath *)rowPath withHeight:(CGFloat)height yOffset:(CGFloat)yOffset
{
    NSInteger columnSection = self._visibleColumnIndexPath.section;
    NSInteger column = self._visibleColumnIndexPath.column;
    NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
    
    CGFloat constructedWidth = 0;
    UIView *anchor = anchorCell;
    
    while (constructedWidth < visibleBounds.size.width) {
        MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:column inSection:columnSection];
        MDSpreadViewCell *cell = nil;
        
        if (column == -1) { // header
            cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowPath];
            anchor = anchorColumnHeaderCell;
        } else if (column == totalInColumnSection) { // footer
            cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowPath];
            anchor = anchorColumnHeaderCell;
        } else {
            cell = [self _cellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
            anchor = anchorCell;
        }
        
        [self _setVisibleCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
        CGFloat width = [self _widthForColumnAtIndexPath:columnPath];
        
        [cell setFrame:CGRectMake(visibleBounds.origin.x+constructedWidth, yOffset, width, height)];
        constructedWidth += width;
        
        cell.hidden = !(width && height);
        if ([cell superview] != self) {
            [self insertSubview:cell belowSubview:anchor];
        }
        
        column++;
        if (column >= totalInColumnSection+1) { // +1 for eventual footer
            columnSection++;
            totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
            column = -1; // -1 for header
        }
    }
}

- (void)_layoutHeaderInRowSection:(NSInteger)rowSection withHeight:(CGFloat)height yOffset:(CGFloat)yOffset
{
    NSInteger columnSection = self._visibleColumnIndexPath.section;
    NSInteger column = self._visibleColumnIndexPath.column;
    NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
    
    CGFloat constructedWidth = 0;
    UIView *anchor = anchorColumnHeaderCell;
    MDIndexPath *rowPath = [MDIndexPath indexPathForRow:-1 inSection:rowSection];
    
    while (constructedWidth < visibleBounds.size.width) {
        MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:column inSection:columnSection];
        MDSpreadViewCell *cell = nil;
        
        if (column == -1) { // header
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else if (column == totalInColumnSection) { // footer
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else {
            cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
            anchor = anchorColumnHeaderCell;
        }
        
        [self _setVisibleCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
        CGFloat width = [self _widthForColumnAtIndexPath:columnPath];
        
        [cell setFrame:CGRectMake(visibleBounds.origin.x+constructedWidth, yOffset, width, height)];
        constructedWidth += width;
        
        cell.hidden = !(width && height);
        if ([cell superview] != self) {
            [self insertSubview:cell belowSubview:anchor];
        }
        
        column++;
        if (column >= totalInColumnSection+1) { // +1 for eventual footer
            columnSection++;
            totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
            column = -1; // -1 for header
        }
    }
}
- (void)_layoutFooterInRowSection:(NSInteger)rowSection withHeight:(CGFloat)height yOffset:(CGFloat)yOffset
{
    NSInteger columnSection = self._visibleColumnIndexPath.section;
    NSInteger column = self._visibleColumnIndexPath.column;
    NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
    
    CGFloat constructedWidth = 0;
    UIView *anchor = anchorColumnHeaderCell;
    MDIndexPath *rowPath = [MDIndexPath indexPathForRow:[self _numberOfRowsInSection:rowSection] inSection:rowSection];
    
    while (constructedWidth < visibleBounds.size.width) {
        MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:column inSection:columnSection];
        MDSpreadViewCell *cell = nil;
        
        if (column == -1) { // header
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else if (column == totalInColumnSection) { // footer
            cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
            anchor = anchorCornerHeaderCell;
        } else {
            cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
            anchor = anchorColumnHeaderCell;
        }
        
        [self _setVisibleCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
        CGFloat width = [self _widthForColumnAtIndexPath:columnPath];
        
        [cell setFrame:CGRectMake(visibleBounds.origin.x+constructedWidth, yOffset, width, height)];
        constructedWidth += width;
        
        cell.hidden = !(width && height);
        if ([cell superview] != self) {
            [self insertSubview:cell belowSubview:anchor];
        }
        
        column++;
        if (column >= totalInColumnSection+1) { // +1 for eventual footer
            columnSection++;
            totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
            column = -1; // -1 for header
        }
    }
}

- (CGRect)cellRectForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
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
                    cellFrame.origin.x += [descriptor widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:column inSection:columnSection]];
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
                    cellFrame.origin.y += [descriptor heightForRowAtIndexPath:[MDIndexPath indexPathForRow:row inSection:rowSection]];
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

- (NSInteger)_relativeIndexOfRowAtIndexPath:(MDIndexPath *)indexPath
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

- (NSInteger)_relativeIndexOfColumnAtIndexPath:(MDIndexPath *)indexPath
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

- (MDIndexPath *)_rowIndexPathFromRelativeIndex:(NSInteger)index
{
    NSInteger rowSection = self._visibleRowIndexPath.section;
    NSInteger row = self._visibleRowIndexPath.row;
    NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
    
    if (index == -1) {
        return [MDIndexPath indexPathForRow:row-1 inSection:rowSection];
    }
    
    for (int i = 0; i < index; i++) {
        row++;
        if (row >= totalInRowSection+1) { // +1 for eventual footer
            rowSection++;
            totalInRowSection = [self _numberOfRowsInSection:rowSection];
            row = -1; // -1 for header
        }
    }
    
    return [MDIndexPath indexPathForRow:row inSection:rowSection];
}

- (MDIndexPath *)_columnIndexPathFromRelativeIndex:(NSInteger)index
{
    NSInteger columnSection = self._visibleColumnIndexPath.section;
    NSInteger column = self._visibleColumnIndexPath.column;
    NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
    
    if (index == -1) {
        return [MDIndexPath indexPathForColumn:column-1 inSection:columnSection];
    }
    
    for (int i = 0; i < index; i++) {
        column++;
        if (column >= totalInColumnSection+1) { // +1 for eventual footer
            columnSection++;
            totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
            column = -1; // -1 for header
        }
    }
    
    return [MDIndexPath indexPathForColumn:column inSection:columnSection];
}

- (NSInteger)_relativeIndexOfHeaderRowInSection:(NSInteger)rowSection
{
    return [self _relativeIndexOfRowAtIndexPath:[MDIndexPath indexPathForRow:-1 inSection:rowSection]];
}

- (NSInteger)_relativeIndexOfHeaderColumnInSection:(NSInteger)columnSection
{
    return [self _relativeIndexOfColumnAtIndexPath:[MDIndexPath indexPathForColumn:-1 inSection:columnSection]];
}

- (MDSpreadViewCell *)_visibleCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
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

- (void)_setVisibleCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
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
                [visibleCells addObject:array];
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
                [column addObject:null];
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
                    
                        self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:column inSection:section];
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
                    
                    self._visibleRowIndexPath = [MDIndexPath indexPathForColumn:row inSection:section];
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

- (void)_clearCellsForColumnAtIndexPath:(MDIndexPath *)columnPath
{
    NSInteger xIndex = [self _relativeIndexOfColumnAtIndexPath:columnPath];
    
    if (xIndex < 0 || xIndex >= visibleCells.count) {
        return;
    }
    
    NSMutableArray *column = [visibleCells objectAtIndex:xIndex];
    
    for (MDSpreadViewCell *cell in column) {
        if ((NSNull *)cell != [NSNull null]) {
            [cell removeFromSuperview];
            cell.hidden = YES;
            [dequeuedCells addObject:cell];
        }
    }
    
    [column removeAllObjects];
    
    if (xIndex == 0 || xIndex == visibleCells.count-1) {
        BOOL foundCell = NO;
        
        // non recursive, so we don't go deleting too much
        NSMutableArray *columnToCheck = [visibleCells objectAtIndex:xIndex];
        if (xIndex > 0) xIndex--; // prepare for next run through
        
        for (id cell in columnToCheck) {
            if ((NSNull *)cell != [NSNull null]) {
                foundCell = YES;
                break;
            }
        }
        
        if (!foundCell) {
            [visibleCells removeObjectIdenticalTo:columnToCheck];
            
            if (xIndex == 0) {
                NSInteger section = self._visibleColumnIndexPath.section;
                NSInteger column = self._visibleColumnIndexPath.column + 1;
                NSInteger totalInSection = [self _numberOfColumnsInSection:section];
                
                if (column >= totalInSection+1) { // +1 for eventual footer
                    section++;
                    column = -1; // -1 for header
                }
                
                self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:column inSection:section];
            }
        }
    }
}

- (void)_clearCellsForRowAtIndexPath:(MDIndexPath *)rowPath
{
    NSInteger yIndex = [self _relativeIndexOfRowAtIndexPath:rowPath];
    
    if (yIndex < 0 || visibleCells.count == 0) {
        return;
    }
    
    for (NSMutableArray *column in visibleCells) {
        if (yIndex >= column.count) {
            break;
        } else if (yIndex == column.count-1) {
            MDSpreadViewCell *cell = [column objectAtIndex:yIndex];
            
            if ((NSNull *)cell != [NSNull null]) {
                [cell removeFromSuperview];
                cell.hidden = YES;
                [dequeuedCells addObject:cell];
            }
            
            [column removeObjectAtIndex:yIndex];
        } else {
            MDSpreadViewCell *cell = [column objectAtIndex:yIndex];
            
            if ((NSNull *)cell != [NSNull null]) {
                [cell removeFromSuperview];
                cell.hidden = YES;
                [dequeuedCells addObject:cell];
            }
            
            [column replaceObjectAtIndex:yIndex withObject:[NSNull null]];
        }
    }
    
    if (yIndex == 0) {
        BOOL foundCell = NO;
        
        for (NSMutableArray *columnToCheck in visibleCells) {
            if (columnToCheck.count) {
                NSNull *cell = [columnToCheck objectAtIndex:0];
                
                if (cell != [NSNull null]) {
                    foundCell = YES;
                    break;
                }
            }
        }
        
        if (!foundCell) {
            for (NSMutableArray *columnToCheck in visibleCells) {
                if (columnToCheck.count)
                    [columnToCheck removeObjectAtIndex:0];
            }
            
            NSInteger section = self._visibleRowIndexPath.section;
            NSInteger row = self._visibleRowIndexPath.row + 1;
            NSInteger totalInSection = [self _numberOfRowsInSection:section];
            
            if (row >= totalInSection+1) { // +1 for eventual footer
                section++;
                row = -1; // -1 for header
            }
            
            self._visibleRowIndexPath = [MDIndexPath indexPathForRow:row inSection:section];
        }
    }
}

- (void)_clearCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
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

- (CGFloat)_widthForColumnAtIndexPath:(MDIndexPath *)columnPath
{
    if (columnPath.column == -1) return [self _widthForColumnHeaderInSection:columnPath.section];
    else if (columnPath.column == [self _numberOfColumnsInSection:columnPath.section]) return [self _widthForColumnFooterInSection:columnPath.section];
    
    if (implementsColumnWidth && self.delegate && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnAtIndexPath:)]) {
        return [self.delegate spreadView:self widthForColumnAtIndexPath:columnPath];
    } else {
        implementsColumnWidth = NO;
    }
    
    return self.columnWidth;
}

- (CGFloat)_widthForColumnFooterInSection:(NSInteger)columnSection
{
    return 0;
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

- (CGFloat)_heightForRowAtIndexPath:(MDIndexPath *)rowPath
{
    if (rowPath.row == -1) return [self _heightForRowHeaderInSection:rowPath.section];
    else if (rowPath.row == [self _numberOfRowsInSection:rowPath.section]) return [self _heightForRowFooterInSection:rowPath.section];
    
    if (implementsRowHeight && self.delegate && [self.delegate respondsToSelector:@selector(spreadView:heightForRowAtIndexPath:)]) {
        return [self.delegate spreadView:self heightForRowAtIndexPath:rowPath];
    } else {
        implementsRowHeight = NO;
    }
    
    return self.rowHeight;
}

- (CGFloat)_heightForRowFooterInSection:(NSInteger)rowSection
{
    return 0;
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

- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath
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

- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath
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

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
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

- (void)_didSelectRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(spreadView:didSelectRowAtIndexPath:forColumnAtIndexPath:)])
		[self.delegate spreadView:self didSelectRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
	
}


- (MDIndexPath *)indexPathForSelectedRow
{
    return [MDIndexPath indexPathForRow:selectedRow inSection:selectedSection];
}

//- (void)selectRowAtIndexPath:(MDIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
//{
//    
//}
//
//- (void)deselectRowAtIndexPath:(MDIndexPath *)indexPath animated:(BOOL)animated
//{
//    
//}

@end
