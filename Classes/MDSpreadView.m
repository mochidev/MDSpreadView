//
//  MDSpreadView.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software, associated artwork, and documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//  2. Neither the name of Mochi Development, Inc. nor the names of its
//     contributors or products may be used to endorse or promote products
//     derived from this software without specific prior written permission.
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
#import "MDSpreadViewCell.h"
#import "MDSpreadViewHeaderCell.h"

@interface MDSpreadViewCell ()

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, readwrite, assign) MDSpreadView *spreadView;
@property (nonatomic, retain) MDSortDescriptor *sortDescriptorPrototype;
@property (nonatomic) MDSpreadViewSortAxis defaultSortAxis;

@property (nonatomic, readonly) UILongPressGestureRecognizer *_tapGesture;
@property (nonatomic, retain) MDIndexPath *_rowPath;
@property (nonatomic, retain) MDIndexPath *_columnPath;
@property (nonatomic) CGRect _pureFrame;

@end

@interface MDSpreadViewSection : NSObject {
    NSInteger numberOfCells;
    CGFloat offset;
    CGFloat size;
}

@property (nonatomic) NSInteger numberOfCells;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat size;

@end

@implementation MDSpreadViewSection

@synthesize numberOfCells, offset, size;

@end

@interface MDSpreadViewSelection ()

@property (nonatomic, retain, readwrite) MDIndexPath *rowPath;
@property (nonatomic, retain, readwrite) MDIndexPath *columnPath;
@property (nonatomic, readwrite) MDSpreadViewSelectionMode selectionMode;

@end

@implementation MDSpreadViewSelection

@synthesize rowPath, columnPath, selectionMode;

+ (id)selectionWithRow:(MDIndexPath *)row column:(MDIndexPath *)column mode:(MDSpreadViewSelectionMode)mode
{
    MDSpreadViewSelection *pair = [[self alloc] init];
    
    pair.rowPath = row;
    pair.columnPath = column;
    pair.selectionMode = mode;
    
    return [pair autorelease];
}

- (BOOL)isEqual:(MDSpreadViewSelection *)object
{
    if ([object isKindOfClass:[MDSpreadViewSelection class]]) {
        if (self == object) return YES;
        return (self.rowPath.row == object.rowPath.row &&
                self.rowPath.section == object.rowPath.section &&
                self.columnPath.column == object.columnPath.column &&
                self.columnPath.section == object.columnPath.section);
    }
    return NO;
}

- (void)dealloc
{
    [rowPath release];
    [columnPath release];
    [super dealloc];
}

@end

@interface MDIndexPath ()

- (MDIndexPath *)indexPathWithRowOffset:(NSInteger)offset inSpreadView:(MDSpreadView *)spreadView guard:(BOOL)yn;
- (MDIndexPath *)indexPathWithColumnOffset:(NSInteger)offset inSpreadView:(MDSpreadView *)spreadView guard:(BOOL)yn;

- (NSInteger)offsetBetweenRowIndexPath:(MDIndexPath *)indexPath inSpreadView:(MDSpreadView *)spreadView;
- (NSInteger)offsetBetweenColumnIndexPath:(MDIndexPath *)indexPath inSpreadView:(MDSpreadView *)spreadView;

@end

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

- (BOOL)isEqualToIndexPath:(MDIndexPath *)object
{
    return (object->section == self->section && object->row == self->row);
}

- (MDIndexPath *)indexPathWithRowOffset:(NSInteger)offset inSpreadView:(MDSpreadView *)spreadView guard:(BOOL)yn
{
    NSInteger newSection = section;
    NSInteger newRow = row;
    
    NSInteger numInSection = [spreadView numberOfRowsInRowSection:newSection];
    NSInteger numSections = [spreadView numberOfRowSections];
    
    if (offset >= 0) {
        for (int i = 0; i < offset; i++) {
            newRow++;
            if (newRow > numInSection) {
                if (newSection >= numSections-1) {
                    if (yn) {
                        newSection = numSections-1;
                        newRow = [spreadView numberOfRowsInRowSection:newSection];
                        break;
                    }
                } else {
                    newRow = -1;
                    newSection++;
                    numInSection = [spreadView numberOfRowsInRowSection:newSection];
                }
            }
        }
    } else {
        for (int i = 0; i < -offset; i++) {
            newRow--;
            if (newRow < -1) {
                if (newSection <= 0) {
                    if (yn) {
                        newSection = 0;
                        newRow = -1;
                        break;
                    }
                } else {
                    newSection--;
                    numInSection = [spreadView numberOfRowsInRowSection:newSection];
                    newRow = numInSection;
                }
            }
        }
    }
    return [MDIndexPath indexPathForRow:newRow inSection:newSection];
}

- (NSInteger)offsetBetweenRowIndexPath:(MDIndexPath *)indexPath inSpreadView:(MDSpreadView *)spreadView
{
    NSInteger numberOfSections = indexPath.section - section;
    
    NSInteger returnIndex = 0;
    
    if (numberOfSections == 0) {
        returnIndex += indexPath.row-row;
    } else if (numberOfSections > 0) {
        for (int i = section; i <= indexPath.section; i++) {
            if (i == section) {
                returnIndex += [spreadView numberOfRowsInRowSection:i]-row+1;
            } else if (i == indexPath.section) {
                returnIndex += indexPath.row + 1;
            } else {
                returnIndex += [spreadView numberOfRowsInRowSection:i] + 2;
            }
        }
    } else {
        for (int i = section; i >= indexPath.section; i--) {
            if (i == section) {
                returnIndex -= row+1;
            } else if (i == indexPath.section) {
                returnIndex -= [spreadView numberOfRowsInRowSection:i] - indexPath.row + 1;
            } else {
                returnIndex -= [spreadView numberOfRowsInRowSection:i] + 2;
            }
        }
    }
    
    return returnIndex;
}

- (MDIndexPath *)indexPathWithColumnOffset:(NSInteger)offset inSpreadView:(MDSpreadView *)spreadView guard:(BOOL)yn
{
    NSInteger newSection = section;
    NSInteger newRow = row;
    
    NSInteger numInSection = [spreadView numberOfColumnsInColumnSection:newSection];
    NSInteger numSections = [spreadView numberOfColumnSections];
    
    if (offset >= 0) {
        for (int i = 0; i < offset; i++) {
            newRow++;
            if (newRow > numInSection) {
                if (newSection >= numSections-1) {
                    if (yn) {
                        newSection = numSections-1;
                        newRow = [spreadView numberOfColumnsInColumnSection:newSection];
                        break;
                    }
                } else {
                    newRow = -1;
                    newSection++;
                    numInSection = [spreadView numberOfColumnsInColumnSection:newSection];
                }
            }
        }
    } else {
        for (int i = 0; i < -offset; i++) {
            newRow--;
            if (newRow < -1) {
                if (newSection <= 0) {
                    if (yn) {
                        newSection = 0;
                        newRow = -1;
                        break;
                    }
                } else {
                    newSection--;
                    numInSection = [spreadView numberOfColumnsInColumnSection:newSection];
                    newRow = numInSection;
                }
            }
        }
    }
    return [MDIndexPath indexPathForRow:newRow inSection:newSection];
}

- (NSInteger)offsetBetweenColumnIndexPath:(MDIndexPath *)indexPath inSpreadView:(MDSpreadView *)spreadView
{
    NSInteger numberOfSections = indexPath.section - section;
    
    NSInteger returnIndex = 0;
    
    if (numberOfSections == 0) {
        returnIndex += indexPath.row-row;
    } else if (numberOfSections > 0) {
        for (int i = section; i <= indexPath.section; i++) {
            if (i == section) {
                returnIndex += [spreadView numberOfColumnsInColumnSection:i]-row+1;
            } else if (i == indexPath.section) {
                returnIndex += indexPath.row + 1;
            } else {
                returnIndex += [spreadView numberOfColumnsInColumnSection:i] + 2;
            }
        }
    } else {
        for (int i = section; i >= indexPath.section; i--) {
            if (i == section) {
                returnIndex -= row+1;
            } else if (i == indexPath.section) {
                returnIndex -= [spreadView numberOfColumnsInColumnSection:i] - indexPath.row + 1;
            } else {
                returnIndex -= [spreadView numberOfColumnsInColumnSection:i] + 2;
            }
        }
    }
    
    return returnIndex;
}

@end

@interface MDSortDescriptor ()

@property (nonatomic, readwrite, retain) MDIndexPath *indexPath;
@property (nonatomic, readwrite) NSInteger section;
@property (nonatomic, readwrite) MDSpreadViewSortAxis sortAxis;

@end

@implementation MDSortDescriptor

@synthesize indexPath, section, sortAxis;

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selectsWholeSpreadView:(BOOL)wholeView
{
    return [[[self alloc] initWithKey:key ascending:ascending selectsWholeSpreadView:wholeView] autorelease];
}

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector selectsWholeSpreadView:(BOOL)wholeView
{
    return [[[self alloc] initWithKey:key ascending:ascending selector:selector selectsWholeSpreadView:wholeView] autorelease];
}

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)cmptr selectsWholeSpreadView:(BOOL)wholeView
{
    return [[[self alloc] initWithKey:key ascending:ascending comparator:cmptr selectsWholeSpreadView:wholeView] autorelease];
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selectsWholeSpreadView:(BOOL)wholeView
{
    if (self = [super initWithKey:key ascending:ascending]) {
        if (wholeView) section = MDSpreadViewSelectWholeSpreadView;
    }
    return self;
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector selectsWholeSpreadView:(BOOL)wholeView
{
    if (self = [super initWithKey:key ascending:ascending selector:selector]) {
        if (wholeView) section = MDSpreadViewSelectWholeSpreadView;
    }
    return self;
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)cmptr selectsWholeSpreadView:(BOOL)wholeView
{
    if (self = [super initWithKey:key ascending:ascending comparator:cmptr]) {
        if (wholeView) section = MDSpreadViewSelectWholeSpreadView;
    }
    return self;
}

- (void)dealloc
{
    [indexPath release];
    [super dealloc];
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

- (void)_willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

- (void)_clearCell:(MDSpreadViewCell *)cell;
- (void)_clearCellsForColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)_clearCellsForRowAtIndexPath:(MDIndexPath *)rowPath;
- (void)_clearCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)_clearAllCells;

- (void)_layoutAddColumnCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain; // domain == 0 is cells, -1 headers, +1 footers
- (void)_layoutAddColumnCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain;
- (void)_layoutRemoveColumnCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain;
- (void)_layoutRemoveColumnCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain;

- (void)_layoutAddRowCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain;
- (void)_layoutAddRowCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain;
- (void)_layoutRemoveRowCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain;
- (void)_layoutRemoveRowCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain;

- (void)_layoutColumnAtIndexPath:(MDIndexPath *)columnPath withWidth:(CGFloat)width xOffset:(CGFloat)xOffset;
- (void)_layoutHeaderInColumnSection:(NSInteger)columnSection withWidth:(CGFloat)width xOffset:(CGFloat)xOffset;
- (void)_layoutFooterInColumnSection:(NSInteger)columnSection withWidth:(CGFloat)width xOffset:(CGFloat)xOffset;

- (void)_layoutRowAtIndexPath:(MDIndexPath *)rowPath withHeight:(CGFloat)height yOffset:(CGFloat)yOffset;
- (void)_layoutHeaderInRowSection:(NSInteger)rowSection withHeight:(CGFloat)height yOffset:(CGFloat)yOffset;
- (void)_layoutFooterInRowSection:(NSInteger)rowSection withHeight:(CGFloat)height yOffset:(CGFloat)yOffset;

- (NSInteger)_relativeIndexOfRowAtIndexPath:(MDIndexPath *)indexPath;
- (NSInteger)_relativeIndexOfColumnAtIndexPath:(MDIndexPath *)indexPath;

- (NSSet *)_allVisibleCells;

- (MDIndexPath *)_rowIndexPathFromRelativeIndex:(NSInteger)index;
- (MDIndexPath *)_columnIndexPathFromRelativeIndex:(NSInteger)index;

- (NSInteger)_relativeIndexOfHeaderRowInSection:(NSInteger)rowSection;
- (NSInteger)_relativeIndexOfHeaderColumnInSection:(NSInteger)columnSection;

- (void)_setNeedsReloadData;

@property (nonatomic, retain) MDIndexPath *_visibleRowIndexPath;
@property (nonatomic, retain) MDIndexPath *_visibleColumnIndexPath;

@property (nonatomic, retain) MDIndexPath *_headerRowIndexPath;
@property (nonatomic, retain) MDIndexPath *_headerColumnIndexPath;

@property (nonatomic, retain) MDSpreadViewCell *_headerCornerCell;

@property (nonatomic, retain) NSMutableArray *_rowSections;
@property (nonatomic, retain) NSMutableArray *_columnSections;

@property (nonatomic, retain) MDSpreadViewSelection *_currentSelection;

- (MDSpreadViewCell *)_visibleCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)_setVisibleCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

- (BOOL)_touchesBeganInCell:(MDSpreadViewCell *)cell;
- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell;
- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell;

- (void)_addSelection:(MDSpreadViewSelection *)selection;
- (void)_removeSelection:(MDSpreadViewSelection *)selection;

- (MDSpreadViewSelection *)_willSelectCellForSelection:(MDSpreadViewSelection *)selection;
- (void)_didSelectCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath;

@end

@implementation MDSpreadView

+ (NSDictionary *)MDAboutControllerTextCreditDictionary
{
    if (self == [MDSpreadView class]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Tables powered by MDSpreadView, available free on GitHub!", @"Text", @"https://github.com/mochidev/MDSpreadViewDemo", @"Link", nil];
    }
    return nil;
}

#pragma mark - Setup

@synthesize dataSource=_dataSource;
@synthesize rowHeight, columnWidth, sectionColumnHeaderWidth, sectionRowHeaderHeight, _visibleRowIndexPath, _visibleColumnIndexPath, _headerRowIndexPath, _headerColumnIndexPath, _headerCornerCell, sortDescriptors, selectionMode, _rowSections, _columnSections, _currentSelection, allowsMultipleSelection, allowsSelection, columnResizing, rowResizing;
@synthesize defaultCellClass=_defaultCellClass;
@synthesize defaultHeaderColumnCellClass=_defaultHeaderColumnCellClass;
@synthesize defaultHeaderRowCellClass=_defaultHeaderRowCellClass;
@synthesize defaultHeaderCornerCellClass=_defaultHeaderCornerCellClass;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
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
    
    _dequeuedCells = [[NSMutableSet alloc] init];
    visibleCells = [[NSMutableArray alloc] init];
    
    _headerColumnCells = [[NSMutableArray alloc] init];
    _headerRowCells = [[NSMutableArray alloc] init];
    
    rowHeight = 44; // 25
    sectionRowHeaderHeight = 22;
    columnWidth = 220;
    sectionColumnHeaderWidth = 110;
    
    _selectedCells = [[NSMutableArray alloc] init];
    selectionMode = MDSpreadViewSelectionModeCell;
    allowsSelection = YES;
    
    _defaultCellClass = [MDSpreadViewCell class];
    _defaultHeaderColumnCellClass = [MDSpreadViewHeaderCell class];
    _defaultHeaderCornerCellClass = [MDSpreadViewHeaderCell class];
    _defaultHeaderRowCellClass = [MDSpreadViewHeaderCell class];
    
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_rowSections release];
    [_columnSections release];
    [sortDescriptors release];
    [_headerColumnCells release];
    [_headerRowCells release];
    [_selectedCells release];
    [_currentSelection release];
    [_headerColumnIndexPath release];
    [_headerRowIndexPath release];
    [_headerCornerCell release];
    [_visibleRowIndexPath release];
    [_visibleColumnIndexPath release];
    [visibleCells release];
    [_dequeuedCells release];
    [super dealloc];
}

#pragma mark - Data

- (void)setRowHeight:(CGFloat)newHeight
{
    rowHeight = newHeight;
    
    if (implementsRowHeight) return;
    
    [self _setNeedsReloadData];
}

- (void)setSectionRowHeaderHeight:(CGFloat)newHeight
{
    sectionRowHeaderHeight = newHeight;
    
    if (implementsRowHeaderHeight) return;
    
    [self _setNeedsReloadData];
}

- (void)setColumnWidth:(CGFloat)newWidth
{
    columnWidth = newWidth;
    
    if (implementsColumnWidth) return;
    
    [self _setNeedsReloadData];
}

- (void)setSectionColumnHeaderWidth:(CGFloat)newWidth
{
    sectionColumnHeaderWidth = newWidth;
    
    if (implementsColumnHeaderWidth) return;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderCornerCellClass:(Class)aClass
{
    if (![aClass isSubclassOfClass:[MDSpreadViewCell class]]) [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass)];
                          
    _defaultHeaderCornerCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderColumnCellClass:(Class)aClass
{
    if (![aClass isSubclassOfClass:[MDSpreadViewCell class]]) [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass)];
    
    _defaultHeaderColumnCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderRowCellClass:(Class)aClass
{
    if (![aClass isSubclassOfClass:[MDSpreadViewCell class]]) [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass)];
    
    _defaultHeaderRowCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultCellClass:(Class)aClass
{
    if (![aClass isSubclassOfClass:[MDSpreadViewCell class]]) [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass)];
    
    _defaultCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)_setNeedsReloadData
{
    if (!_didSetReloadData) {
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
        _didSetReloadData = YES;
    }
}

- (void)reloadData
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadData) object:nil];
    _didSetReloadData = NO;
    
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
    
    CGPoint offset = self.contentOffset;
    
    NSMutableArray *newColumnSections = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < numberOfColumnSections; i++) {
        MDSpreadViewSection *sectionDescriptor = [[MDSpreadViewSection alloc] init];
        [newColumnSections addObject:sectionDescriptor];
        [sectionDescriptor release];
        
        NSUInteger numberOfColumns = [self _numberOfColumnsInSection:i];
        sectionDescriptor.numberOfCells = numberOfColumns;
        sectionDescriptor.offset = totalWidth;
        
        CGFloat width = [self _widthForColumnHeaderInSection:i];
        
        totalWidth += width;
        
        if (!_visibleColumnIndexPath && totalWidth > offset.x) {
            self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:i];
            visibleBounds.origin.x = totalWidth-width;
        }
        
        for (NSUInteger j = 0; j < numberOfColumns; j++) {
            CGFloat width = [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:j inSection:i]];
            totalWidth += width;
            
            if (!_visibleColumnIndexPath && totalWidth > offset.x) {
                self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:j inSection:i];
                visibleBounds.origin.x = totalWidth-width;
            }
        }
        
        sectionDescriptor.size = totalWidth - sectionDescriptor.offset;
    }
    
    // actually compare it at some point or something... not sure why actually
    self._columnSections = newColumnSections;
    [newColumnSections release];
    
    NSMutableArray *newRowSections = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < numberOfRowSections; i++) {
        MDSpreadViewSection *sectionDescriptor = [[MDSpreadViewSection alloc] init];
        [newRowSections addObject:sectionDescriptor];
        [sectionDescriptor release];
        
        NSUInteger numberOfRows = [self _numberOfRowsInSection:i];
        sectionDescriptor.numberOfCells = numberOfRows;
        sectionDescriptor.offset = totalHeight;
        
        CGFloat height = [self _heightForRowHeaderInSection:i];
        
        totalHeight += height;
        
        if (!_visibleRowIndexPath && totalHeight > offset.y) {
            self._visibleRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:i];
            visibleBounds.origin.y = totalHeight-height;
        }
        
        for (NSUInteger j = 0; j < numberOfRows; j++) {
            height = [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:j inSection:i]];
            totalHeight += height;
            
            if (!_visibleRowIndexPath && totalHeight > offset.y) {
                self._visibleRowIndexPath = [MDIndexPath indexPathForRow:j inSection:i];
                visibleBounds.origin.y = totalHeight-height;
            }
        }
        
        sectionDescriptor.size = totalHeight - sectionDescriptor.offset;
    }
    
    self._rowSections = newRowSections;
    [newRowSections release];
    
    if (!self._visibleColumnIndexPath) {
        visibleBounds.origin.x = 0;
        self._visibleColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:0];
    }
    
    if (!self._visibleRowIndexPath) {
        visibleBounds.origin.y = 0;
        self._visibleRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:0];
    }
    
//    self.contentOffset = visibleBounds.origin;
    self.contentSize = CGSizeMake(totalWidth-1, totalHeight-1);
    
    self._headerRowIndexPath = nil;
    self._headerColumnIndexPath = nil;
    
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

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    
    CGPoint offset = self.contentOffset;
    UIEdgeInsets inset = self.contentInset;
    
//    NSLog(@"\n\n%f, %f (%f, %f)\n\n", offset.x, offset.y, inset.left, inset.top);
    if (offset.x <= 0 || offset.y <= 0) {
        if (offset.x <= 0) offset.x = -inset.left;
        if (offset.y <= 0) offset.y = -inset.top;
        
        self.contentOffset = offset;
    }
//    NSLog(@"\n\n%f, %f (%f, %f)\n\n", offset.x, offset.y, inset.left, inset.top);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:0];
//    [CATransaction setDisableActions:YES];
    
    CGPoint offset = self.contentOffset;
    CGSize boundsSize = self.bounds.size;
    
    if (boundsSize.width == 0 || boundsSize.height == 0) return;
    
//    NSLog(@"--");
//    NSLog(@"Current Visible Bounds: %@ in actual bounds: %@ offset: %@", NSStringFromCGRect(visibleBounds), NSStringFromCGSize(boundsSize), NSStringFromCGPoint(offset));
    
    [self _layoutRemoveColumnCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutAddColumnCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutRemoveColumnCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutAddColumnCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutRemoveColumnCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    
    [self _layoutRemoveRowCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutAddRowCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutRemoveRowCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutAddRowCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    [self _layoutRemoveRowCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainCells];
    
    NSSet *allCells = [self _allVisibleCells];
    
    for (MDSpreadViewCell *cell in allCells) {
        cell.hidden = !(cell.bounds.size.width && cell.bounds.size.height);
        
        if (_visibleColumnIndexPath.column == -1 && cell._columnPath.column == -1 && cell._columnPath.section == _visibleColumnIndexPath.section ) {
            cell.hidden = YES;
        }
        
        if (_visibleRowIndexPath.row == -1 && cell._rowPath.row == -1 && cell._rowPath.section == _visibleRowIndexPath.section ) {
            cell.hidden = YES;
        }
    }
    
    MDIndexPath *oldHeaderRowIndexPath = [[self._headerRowIndexPath retain] autorelease];
    MDIndexPath *oldHeaderColumnIndexPath = [[self._headerColumnIndexPath retain] autorelease];
    
    if (!oldHeaderRowIndexPath || oldHeaderRowIndexPath.section != _visibleRowIndexPath.section) {
        for (MDSpreadViewCell *cell in _headerRowCells) {
            cell.hidden = YES;
            [_dequeuedCells addObject:cell];
        }

        [_headerRowCells removeAllObjects];

        self._headerColumnIndexPath = self._visibleColumnIndexPath;

        _headerBounds.origin.x = visibleBounds.origin.x;
        _headerBounds.size.width = 0;
    }
    
    [self _layoutRemoveColumnCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutAddColumnCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutRemoveColumnCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutAddColumnCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutRemoveColumnCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    
    NSInteger rowSection = 0;
    NSInteger row = 0;
    NSInteger totalInRowSection = 0;
    
    NSMutableArray *headerCells = [[NSMutableArray alloc] initWithArray:_headerRowCells];
    MDIndexPath *currentIndexPath = self._visibleRowIndexPath;
    BOOL shouldContinue = ([self numberOfRowSections] > 0);
    CGFloat nextHeaderOffset = visibleBounds.origin.y;
    CGFloat currentHeaderOffset = 0;
    CGFloat yOffset = offset.y + self.contentInset.top;
    CGFloat height = 0;
    CGFloat currentYOffset = yOffset;
    
    while (shouldContinue) {
        shouldContinue = NO;
//        NSLog(@"A: %f", nextHeaderOffset);
        
        currentHeaderOffset = nextHeaderOffset;
        
        row = currentIndexPath.row;
        rowSection = currentIndexPath.section;
        totalInRowSection = [self _numberOfRowsInSection:rowSection];
        while (row != -1 || (row == currentIndexPath.row && rowSection == currentIndexPath.section)) {
            nextHeaderOffset += [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:row inSection:rowSection]];
            row++;
            if (row >= totalInRowSection+1) { // +1 for eventual footer
                rowSection++;
                totalInRowSection = [self _numberOfRowsInSection:rowSection];
                row = -1; // -1 for header
            }
        }
        rowSection = currentIndexPath.section;
        height = [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:-1 inSection:rowSection]];
        
//        NSLog(@"B: %f", nextHeaderOffset);
        
        if (currentHeaderOffset > currentYOffset) {
            currentYOffset = currentHeaderOffset;
        } else if (currentYOffset+height > nextHeaderOffset) {
//            if (rowSection+1 < [self numberOfRowSections]) {
////                nextHeight = [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:-1 inSection:rowSection+1]];
//                if (yOffset > nextHeaderOffset) {
//                    shouldContinue = YES;
//                }
//            }
            
            currentYOffset = nextHeaderOffset-height;
            yOffset = currentYOffset;
        } else {
            yOffset = currentYOffset;
        }
        if (currentYOffset < 0) currentYOffset = 0;
        if (yOffset < 0) yOffset = 0;
        
        
        
        for (MDSpreadViewCell *cell in headerCells) {
            CGRect frame = cell._pureFrame;
            frame.origin.y = currentYOffset;
            cell.frame = frame;
            cell.hidden = !(cell.bounds.size.width && cell.bounds.size.height);
        }
        
        if (headerCells.count > 0 && _headerColumnIndexPath.column == -1) {
            MDSpreadViewCell *corner = [headerCells objectAtIndex:0];
            corner.hidden = YES;
        }
        
        currentYOffset = offset.y + self.contentInset.top;
        currentIndexPath = [MDIndexPath indexPathForRow:-1 inSection:rowSection+1];
        [headerCells removeAllObjects];
        
        MDIndexPath *columnIndexPath = self._visibleColumnIndexPath;
        BOOL hasMoreCells = YES;
        
        while (hasMoreCells) {
            hasMoreCells = NO;
            MDSpreadViewCell *cell = [self _visibleCellForRowAtIndexPath:currentIndexPath forColumnAtIndexPath:columnIndexPath];
            
            if (cell) {
                [headerCells addObject:cell];
//                NSLog(@"Adding Cell");
            }
            
            MDIndexPath *newColumnIndexPath = [columnIndexPath indexPathWithColumnOffset:1 inSpreadView:self guard:YES];
//            NSLog(@"%@ vs %@", columnIndexPath, newColumnIndexPath);
            if (cell && columnIndexPath && ![columnIndexPath isEqualToIndexPath:newColumnIndexPath]) hasMoreCells = YES;
            columnIndexPath = newColumnIndexPath;
        }
        
        shouldContinue = [headerCells count] > 0;
        
//        NSLog(@"-----");
    }
    
//    NSInteger rowSection = self._visibleRowIndexPath.section;
//    NSInteger row = self._visibleRowIndexPath.row;
//    NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
//    
//    CGFloat nextHeaderOffset = visibleBounds.origin.y;
//    while (row != -1 || (row == self._visibleRowIndexPath.row && rowSection == self._visibleRowIndexPath.section)) {
//        nextHeaderOffset += [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:row inSection:rowSection]];
//        row++;
//        if (row >= totalInRowSection+1) { // +1 for eventual footer
//            rowSection++;
//            totalInRowSection = [self _numberOfRowsInSection:rowSection];
//            row = -1; // -1 for header
//        }
//    }
//    
//    CGFloat yOffset = offset.y + self.contentInset.top;
//    rowSection = _visibleRowIndexPath.section;
//    CGFloat height = [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:-1 inSection:rowSection]];
//    if (yOffset+height > nextHeaderOffset) {
//        yOffset = nextHeaderOffset-height;
//    }
//    if (yOffset < 0) yOffset = 0;
//    
//    for (MDSpreadViewCell *cell in _headerRowCells) {
//        CGRect frame = cell._pureFrame;
//        frame.origin.y = yOffset;
//        cell.frame = frame;
//        cell.hidden = !(cell.bounds.size.width && cell.bounds.size.height);
//    }
//    
//    if (_headerRowCells.count > 0 && _headerColumnIndexPath.column == -1) {
//        MDSpreadViewCell *corner = [_headerRowCells objectAtIndex:0];
//        corner.hidden = YES;
//    }
    
    if (!oldHeaderColumnIndexPath || oldHeaderColumnIndexPath.section != _visibleColumnIndexPath.section) {
        for (MDSpreadViewCell *cell in _headerColumnCells) {
            cell.hidden = YES;
            [_dequeuedCells addObject:cell];
        }

        [_headerColumnCells removeAllObjects];

        self._headerRowIndexPath = self._visibleRowIndexPath;

        _headerBounds.origin.y = visibleBounds.origin.y;
        _headerBounds.size.height = 0;
    }
    
    [self _layoutRemoveRowCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutAddRowCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutRemoveRowCellsBeforeWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutAddRowCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    [self _layoutRemoveRowCellsAfterWithOffset:offset size:boundsSize domain:MDSpreadViewCellDomainHeaders];
    
    NSInteger columnSection = self._visibleColumnIndexPath.section;
    NSInteger column = self._visibleColumnIndexPath.column;
    NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];

    nextHeaderOffset = visibleBounds.origin.x;
    while (column != -1 || (column == self._visibleColumnIndexPath.row && columnSection == self._visibleColumnIndexPath.section)) {
        nextHeaderOffset += [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:column inSection:columnSection]];
        column++;
        if (column >= totalInColumnSection+1) { // +1 for eventual footer
            columnSection++;
            totalInColumnSection = [self _numberOfRowsInSection:columnSection];
            column = -1; // -1 for header
        }
    }

    CGFloat xOffset = offset.x + self.contentInset.left;
    columnSection = _visibleColumnIndexPath.section;
    CGFloat width = [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:-1 inSection:columnSection]];
    if (xOffset+width > nextHeaderOffset) {
        xOffset = nextHeaderOffset-width;
    }
    if (xOffset < 0) xOffset = 0;
    
    for (MDSpreadViewCell *cell in _headerColumnCells) {
        CGRect frame = cell._pureFrame;
        frame.origin.x = xOffset;
        cell.frame = frame;
        cell.hidden = !(cell.bounds.size.width && cell.bounds.size.height);
    }
    
    if (_headerColumnCells.count > 0 && _headerRowIndexPath.column == -1) {
        MDSpreadViewCell *corner = [_headerColumnCells objectAtIndex:0];
        corner.hidden = YES;
    }
    
    if (!oldHeaderRowIndexPath ||
        !oldHeaderColumnIndexPath ||
        oldHeaderRowIndexPath.section != _visibleRowIndexPath.section ||
        oldHeaderColumnIndexPath.section != _visibleColumnIndexPath.section) {
        if (self._headerCornerCell) {
            self._headerCornerCell.hidden = YES;
            [_dequeuedCells addObject:self._headerCornerCell];
            self._headerCornerCell = nil;
        }
        
        width = [self _widthForColumnHeaderInSection:_visibleColumnIndexPath.section];
        height = [self _heightForRowHeaderInSection:_visibleRowIndexPath.section];
        
        self._headerCornerCell = [self _cellForHeaderInRowSection:_visibleRowIndexPath.section forColumnSection:_visibleColumnIndexPath.section];

        if (self._headerCornerCell) {
            self._headerCornerCell._pureFrame = CGRectMake(xOffset, yOffset, width, height);
            self._headerCornerCell.hidden = !(width && height);

            [self _willDisplayCell:self._headerCornerCell forRowAtIndexPath:_visibleRowIndexPath forColumnAtIndexPath:_visibleColumnIndexPath];

            [self insertSubview:self._headerCornerCell belowSubview:anchorCornerHeaderCell];
        }
    } else {
        CGRect frame = self._headerCornerCell._pureFrame;
        frame.origin.x = xOffset;
        frame.origin.y = yOffset;
        self._headerCornerCell.frame = frame;
    }
    
    NSMutableSet *allVisibleCells = [NSMutableSet setWithSet:allCells];
    [allVisibleCells addObjectsFromArray:_headerColumnCells];
    [allVisibleCells addObjectsFromArray:_headerRowCells];
    if (self._headerCornerCell) [allVisibleCells addObject:self._headerCornerCell];
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        cell.highlighted = NO;
        for (MDSpreadViewSelection *selection in _selectedCells) {
            if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
            
            if ([cell._rowPath isEqualToIndexPath:selection.rowPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    cell.highlighted = YES;
                }
            }
            
            if ([cell._columnPath isEqualToIndexPath:selection.columnPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    cell.highlighted = YES;
                }
                
                if ([cell._rowPath isEqualToIndexPath:selection.rowPath] && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                    cell.highlighted = YES;
                }
            }
        }
    }
    
//    [CATransaction commit];
}

- (void)_layoutAddColumnCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    if (domain == MDSpreadViewCellDomainCells) {
    CGFloat width = 0;
    
    while (visibleBounds.origin.x > offset.x) { // add columns before
        @autoreleasepool {
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
            
            if (column == -1) {
                visibleBounds.origin.x = [[_columnSections objectAtIndex:columnSection] offset];
            }
            
            if (column == -1) { // header
                [self _layoutHeaderInColumnSection:columnSection withWidth:width xOffset:visibleBounds.origin.x];
            } else if (column == totalInColumnSection) { // footer
                [self _layoutFooterInColumnSection:columnSection withWidth:width xOffset:visibleBounds.origin.x];
            } else { // cells
                [self _layoutColumnAtIndexPath:columnPath withWidth:width xOffset:visibleBounds.origin.x];
            }
        }
    }
    } else if (domain == MDSpreadViewCellDomainHeaders) {
        CGFloat width = 0;
        MDIndexPath *rowPath = [MDIndexPath indexPathForRow:-1 inSection:self._visibleRowIndexPath.section];
        NSInteger rowSection = rowPath.section;
        CGFloat height = [self _heightForRowAtIndexPath:rowPath];
        
        if (height > 0) while (_headerBounds.origin.x > offset.x) { // add columns before
            @autoreleasepool {
                NSInteger columnSection = self._headerColumnIndexPath.section;
                NSInteger column = self._headerColumnIndexPath.column - 1;
                NSInteger totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
                
                if (column < -1) { // -1 for header
                    columnSection--;
                    totalInColumnSection = [self _numberOfColumnsInSection:columnSection];
                    column = totalInColumnSection; // size of count for eventual footer
                }
                
                if (columnSection < 0) break;
                
                MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:column inSection:columnSection];
                
                width = [self _widthForColumnAtIndexPath:columnPath];
//                if (_headerBounds.size.height <= 0) _headerBounds.size.height = [self _heightForRowAtIndexPath:self._headerRowIndexPath];
                
                _headerBounds.size.width += width;
                _headerBounds.origin.x -= width;
                
                MDSpreadViewCell *cell = nil;
                UIView *anchor;
                
                if (column == -1) {
                    _headerBounds.origin.x = [[_columnSections objectAtIndex:columnSection] offset];
                }
                
                if (column == -1) { // header
                    cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                    anchor = anchorCornerHeaderCell;
                } else if (column == totalInColumnSection) { // footer
                    cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                    anchor = anchorCornerHeaderCell;
                } else { // cells
                    cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
                    anchor = anchorRowHeaderCell;
                }
                
                if (cell) {
                    cell._pureFrame = CGRectMake(_headerBounds.origin.x, 0, width, height);
                    cell.hidden = !(width && height);

                    [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];

                    if ([cell superview] != self)
                        [self insertSubview:cell belowSubview:anchor];
                    [_headerRowCells insertObject:cell atIndex:0];
                    self._headerColumnIndexPath = columnPath;
                }
            }
        }
    }
}

- (void)_layoutAddColumnCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    if (domain == MDSpreadViewCellDomainCells) {
    @autoreleasepool {
        NSUInteger numberOfColumnSections = [self _numberOfColumnSections];
    
        MDIndexPath *lastIndexPath = [[[self _columnIndexPathFromRelativeIndex:visibleCells.count-1] retain] autorelease];
//        int numberOfPasses = 0;
        
//        NSLog(@"Count: %d, %@", visibleCells.count, _visibleColumnIndexPath);
//        
//        NSLog(@"Adding From %@", lastIndexPath);
        
        while (visibleBounds.origin.x+visibleBounds.size.width < offset.x+size.width) { // add columns after
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
        }
        
//        NSLog(@"         To %@", [self _columnIndexPathFromRelativeIndex:visibleCells.count-1]);
    }
    } else if (domain == MDSpreadViewCellDomainHeaders) @autoreleasepool {
        NSUInteger numberOfColumnSections = [self _numberOfColumnSections];
        MDIndexPath *rowPath = [MDIndexPath indexPathForRow:-1 inSection:self._visibleRowIndexPath.section];
        NSInteger rowSection = rowPath.section;
        CGFloat height = [self _heightForRowAtIndexPath:rowPath];
        
        MDIndexPath *lastIndexPath = [self._headerColumnIndexPath indexPathWithColumnOffset:_headerRowCells.count-1 inSpreadView:self guard:NO];
        
        //        NSLog(@"Count: %d, %@", visibleCells.count, _visibleColumnIndexPath);
        //
        //        NSLog(@"Adding From %@", lastIndexPath);
        
        if (height > 0) while (_headerBounds.origin.x+_headerBounds.size.width < offset.x+size.width) { // add columns after
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
            
            _headerBounds.size.width += width;
            
            MDSpreadViewCell *cell = nil;
            UIView *anchor;
            
            if (column == -1) { // header
                cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                anchor = anchorCornerHeaderCell;
            } else if (column == totalInColumnSection) { // footer
                cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                anchor = anchorCornerHeaderCell;
            } else { // cells
                cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnPath];
                anchor = anchorRowHeaderCell;
            }
            
            if (cell) {
                cell._pureFrame = CGRectMake(_headerBounds.origin.x+_headerBounds.size.width-width, 0, width, height);
                cell.hidden = !(width && height);
                
                [self _willDisplayCell:cell forRowAtIndexPath:[MDIndexPath indexPathForRow:-1 inSection:rowSection] forColumnAtIndexPath:columnPath];
                
                if ([cell superview] != self)
                    [self insertSubview:cell belowSubview:anchor];
                [_headerRowCells addObject:cell];
            }
        }
        
        //        NSLog(@"         To %@", [self _columnIndexPathFromRelativeIndex:visibleCells.count-1]);
    
    }
}

- (void)_layoutRemoveColumnCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    CGFloat width = 0;
    MDIndexPath *indexPathToRemove = nil;
    MDIndexPath *nextIndexPathToRemove = nil;
    
    if (domain == MDSpreadViewCellDomainCells) @autoreleasepool {
        indexPathToRemove = [[self._visibleColumnIndexPath retain] autorelease];
        width = [self _widthForColumnAtIndexPath:indexPathToRemove];
        
        while (visibleBounds.origin.x+width < offset.x) { // delete left most column
            visibleBounds.size.width -= width;
            if (visibleBounds.size.width < 0) visibleBounds.size.width = 0;
            visibleBounds.origin.x += width;
            
            if (indexPathToRemove.column == -1) {
                visibleBounds.origin.x = [[_columnSections objectAtIndex:indexPathToRemove.section] offset] + width;
            }
            
            if (visibleCells.count > 0)
                [self _clearCellsForColumnAtIndexPath:indexPathToRemove];
            
            nextIndexPathToRemove = [indexPathToRemove indexPathWithColumnOffset:1 inSpreadView:self guard:YES];
            if ([indexPathToRemove isEqualToIndexPath:nextIndexPathToRemove]) break;
            
            indexPathToRemove = nextIndexPathToRemove;
            width = [self _widthForColumnAtIndexPath:indexPathToRemove];
        }
        
        if (visibleCells.count == 0)
            self._visibleColumnIndexPath = indexPathToRemove;
        
    } else if (domain == MDSpreadViewCellDomainHeaders) @autoreleasepool {
        indexPathToRemove = [[self._headerColumnIndexPath retain] autorelease];
        width = [self _widthForColumnAtIndexPath:indexPathToRemove];
        
        while (_headerBounds.origin.x+width < offset.x) { // delete left most column
            _headerBounds.size.width -= width;
            if (_headerBounds.size.width < 0) _headerBounds.size.width = 0;
            _headerBounds.origin.x += width;
            
            if (indexPathToRemove.column == -1) {
                _headerBounds.origin.x = [[_columnSections objectAtIndex:indexPathToRemove.section] offset] + width;
            }
            
            if (_headerRowCells.count > 0) {
                MDSpreadViewCell *cell = [_headerRowCells objectAtIndex:0];
                [_dequeuedCells addObject:cell];
                cell.hidden = YES;
                [_headerRowCells removeObjectAtIndex:0];
                self._headerColumnIndexPath = [indexPathToRemove indexPathWithColumnOffset:1 inSpreadView:self guard:NO];
            }
            
            nextIndexPathToRemove = [indexPathToRemove indexPathWithColumnOffset:1 inSpreadView:self guard:YES];
            if ([indexPathToRemove isEqualToIndexPath:nextIndexPathToRemove]) break;
            
            indexPathToRemove = nextIndexPathToRemove;
            width = [self _widthForColumnAtIndexPath:indexPathToRemove];
        }
        
        if (_headerRowCells.count == 0)
            self._headerColumnIndexPath = indexPathToRemove;
    }
}

- (void)_layoutRemoveColumnCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    CGFloat width = 0;
    MDIndexPath *lastIndexPath = nil;
    MDIndexPath *last2IndexPath = nil;
    MDIndexPath *nextIndexPath = nil;
    
    if (domain == MDSpreadViewCellDomainCells) @autoreleasepool {
        lastIndexPath = [self _columnIndexPathFromRelativeIndex:visibleCells.count-1];
        last2IndexPath = self._visibleColumnIndexPath;
        width = [self _widthForColumnAtIndexPath:lastIndexPath];
        
        while (visibleBounds.origin.x+visibleBounds.size.width-width > offset.x+size.width) { // delete right most column
            if (lastIndexPath.section == 0 && lastIndexPath.column < -1) break;
            
            visibleBounds.size.width -= width;
            if (visibleBounds.size.width < 0) {
                visibleBounds.origin.x += visibleBounds.size.width;
                visibleBounds.size.width = 0;
                
                if (lastIndexPath.column == -1) {
                    visibleBounds.origin.x = [[_columnSections objectAtIndex:lastIndexPath.section] offset];
                }
            }
            
            if (visibleCells.count > 0)
                [self _clearCellsForColumnAtIndexPath:lastIndexPath];
            
            nextIndexPath = [lastIndexPath indexPathWithColumnOffset:-1 inSpreadView:self guard:YES];
            last2IndexPath = lastIndexPath;
            if ([lastIndexPath isEqualToIndexPath:nextIndexPath]) break;
            lastIndexPath = nextIndexPath;
            width = [self _widthForColumnAtIndexPath:lastIndexPath];
        }
        
        if ([visibleCells count] == 0)
            self._visibleColumnIndexPath = last2IndexPath;
        
    } else if (domain == MDSpreadViewCellDomainHeaders) @autoreleasepool {
        lastIndexPath = [_headerColumnIndexPath indexPathWithColumnOffset:_headerRowCells.count-1 inSpreadView:self guard:NO];
        last2IndexPath = self._headerColumnIndexPath;
        width = [self _widthForColumnAtIndexPath:lastIndexPath];
        
        while (_headerBounds.origin.x+_headerBounds.size.width-width > offset.x+size.width) { // delete right most column
            if (lastIndexPath.section == 0 && lastIndexPath.column < -1) break;
            
            _headerBounds.size.width -= width;
            if (_headerBounds.size.width < 0) {
                _headerBounds.origin.x += _headerBounds.size.width;
                _headerBounds.size.width = 0;
                
                if (lastIndexPath.column == -1) {
                    _headerBounds.origin.x = [[_columnSections objectAtIndex:lastIndexPath.section] offset];
                }
            }
            
            if (_headerRowCells.count > 0) {
                NSInteger index = [self._headerColumnIndexPath offsetBetweenColumnIndexPath:lastIndexPath inSpreadView:self];
                if (index >= 0 && index < _headerRowCells.count) {
                    MDSpreadViewCell *cell = [_headerRowCells objectAtIndex:index];
                    [_dequeuedCells addObject:cell];
                    cell.hidden = YES;
                    [_headerRowCells removeObjectAtIndex:index];
                }
            }
            
            nextIndexPath = [lastIndexPath indexPathWithColumnOffset:-1 inSpreadView:self guard:YES];
            last2IndexPath = lastIndexPath;
            if ([lastIndexPath isEqualToIndexPath:nextIndexPath]) break;
            lastIndexPath = nextIndexPath;
            width = [self _widthForColumnAtIndexPath:lastIndexPath];
        }
        
        if ([_headerRowCells count] == 0)
            self._headerColumnIndexPath = last2IndexPath;
    }
}

- (void)_layoutAddRowCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    CGFloat height = 0;
//    MDIndexPath *lastIndexPath = nil;
    
    if (domain == MDSpreadViewCellDomainCells) {
    
    while (visibleBounds.origin.y > offset.y) { // add rows before
        @autoreleasepool {
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
            
//            if (lastIndexPath == rowPath) break;
//            lastIndexPath = rowPath;
            
            height = 0;
            
            if (visibleBounds.size.width) {
                height = [self _heightForRowAtIndexPath:rowPath];
            }
            
            visibleBounds.size.height += height;
            visibleBounds.origin.y -= height;
            
            if (row == -1) {
                visibleBounds.origin.y = [[_rowSections objectAtIndex:rowSection] offset];
            }
            
            if (row == -1) { // header
                [self _layoutHeaderInRowSection:rowSection withHeight:height yOffset:visibleBounds.origin.y];
            } else if (row == totalInRowSection) { // footer
                [self _layoutFooterInRowSection:rowSection withHeight:height yOffset:visibleBounds.origin.y];
            } else { // cells
                [self _layoutRowAtIndexPath:rowPath withHeight:height yOffset:visibleBounds.origin.y];
            }
        }
    }
    } else if (domain == MDSpreadViewCellDomainHeaders) {
        MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:-1 inSection:self._visibleColumnIndexPath.section];
        NSInteger columnSection = columnPath.section;
        CGFloat width = [self _widthForColumnAtIndexPath:columnPath];
        
        if (width > 0) while (_headerBounds.origin.y > offset.y) { // add columns before
            @autoreleasepool {
                NSInteger rowSection = self._headerRowIndexPath.section;
                NSInteger row = self._headerRowIndexPath.row - 1;
                NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
                
                if (row < -1) { // -1 for header
                    rowSection--;
                    totalInRowSection = [self _numberOfRowsInSection:rowSection];
                    row = totalInRowSection; // count for eventual footer
                }
                
                if (rowSection < 0) break;
                
                MDIndexPath *rowPath = [MDIndexPath indexPathForRow:row inSection:rowSection];
                
//                if (lastIndexPath == rowPath) break;
//                lastIndexPath = rowPath;
                
                height = [self _heightForRowAtIndexPath:rowPath];
                
                _headerBounds.size.height += height;
                _headerBounds.origin.y -= height;
                
                MDSpreadViewCell *cell = nil;
                UIView *anchor;
                
                if (row == -1) {
                    _headerBounds.origin.y = [[_rowSections objectAtIndex:rowSection] offset];
                }
                
                if (row == -1) { // header
                    cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                    anchor = anchorCornerHeaderCell;
                } else if (row == totalInRowSection) { // footer
                    cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                    anchor = anchorCornerHeaderCell;
                } else { // cells
                    cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowPath];
                    anchor = anchorColumnHeaderCell;
                }
                
                if (cell) {
                    cell._pureFrame = CGRectMake(0, _headerBounds.origin.y, width, height);
                    cell.hidden = !(width && height);
                    
                    [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
                    
                    if ([cell superview] != self)
                        [self insertSubview:cell belowSubview:anchor];
                    [_headerColumnCells insertObject:cell atIndex:0];
                    self._headerRowIndexPath = rowPath;
                }
            }
        }
    }
}

- (void)_layoutAddRowCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    if (domain == MDSpreadViewCellDomainCells) {
    NSUInteger numberOfRowSections = [self _numberOfRowSections];
    
    CGFloat height = 0;
    MDIndexPath *lastIndexPath = nil;
    
    if (visibleCells.count) {
        @autoreleasepool {
            lastIndexPath = [self _rowIndexPathFromRelativeIndex:[[visibleCells objectAtIndex:0] count]-1];
            
            while (visibleBounds.origin.y+visibleBounds.size.height < offset.y+size.height) { // add rows after
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
            }
        }
    }
    } else if (domain == MDSpreadViewCellDomainHeaders) @autoreleasepool {
        NSUInteger numberOfRowSections = [self _numberOfRowSections];
        MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:-1 inSection:self._visibleColumnIndexPath.section];
        NSInteger columnSection = columnPath.section;
        CGFloat width = [self _widthForColumnAtIndexPath:columnPath];
        
        MDIndexPath *lastIndexPath = [self._headerRowIndexPath indexPathWithRowOffset:_headerColumnCells.count-1 inSpreadView:self guard:NO];
        
        if (width > 0) while (_headerBounds.origin.y+_headerBounds.size.height < offset.y+size.height) { // add columns after
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
            
            CGFloat height = [self _heightForRowAtIndexPath:rowPath];
            
            _headerBounds.size.height += height;
            
            MDSpreadViewCell *cell = nil;
            UIView *anchor;
            
            if (row == -1) { // header
                cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                anchor = anchorCornerHeaderCell;
            } else if (row == totalInRowSection) { // footer
                cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
                anchor = anchorCornerHeaderCell;
            } else { // cells
                cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowPath];
                anchor = anchorColumnHeaderCell;
            }
            
            if (cell) {
                cell._pureFrame = CGRectMake(0, _headerBounds.origin.y+_headerBounds.size.height-height, width, height);
                cell.hidden = !(width && height);
                
                [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
                
                if ([cell superview] != self)
                    [self insertSubview:cell belowSubview:anchor];
                [_headerColumnCells addObject:cell];
            }
        }
    }
}

- (void)_layoutRemoveRowCellsBeforeWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    CGFloat height = 0;
    MDIndexPath *indexPathToRemove = nil;
    MDIndexPath *nextIndexPathToRemove = nil;
    NSInteger numberOfRowSections = [self _numberOfRowSections];
    
    if (domain == MDSpreadViewCellDomainCells) @autoreleasepool {
        indexPathToRemove = [[self._visibleRowIndexPath retain] autorelease];
        height = [self _heightForRowAtIndexPath:indexPathToRemove];
        
        while (visibleBounds.origin.y+height < offset.y) { // delete top most row
            visibleBounds.size.height -= height;
            if (visibleBounds.size.height < 0) visibleBounds.size.height = 0;
            visibleBounds.origin.y += height;
            
            if (indexPathToRemove.row == -1) {
                if (indexPathToRemove.section >= [_rowSections count]) break; // NOT A VERY GOOD FIX!!!
                visibleBounds.origin.y = [[_rowSections objectAtIndex:indexPathToRemove.section] offset] + height;
            }
            
//            if ([[visibleCells objectAtIndex:0] count] == 0)
                [self _clearCellsForRowAtIndexPath:indexPathToRemove];
            
            nextIndexPathToRemove = [indexPathToRemove indexPathWithRowOffset:1 inSpreadView:self guard:YES];
            if ([indexPathToRemove isEqualToIndexPath:nextIndexPathToRemove]) break;
            
            indexPathToRemove = nextIndexPathToRemove;
            height = [self _heightForRowAtIndexPath:indexPathToRemove];
        }
        
        if (visibleCells.count && [[visibleCells objectAtIndex:0] count] == 0)
            self._visibleRowIndexPath = indexPathToRemove;
        
    } else if (domain == MDSpreadViewCellDomainHeaders) @autoreleasepool {
        indexPathToRemove = [[self._headerRowIndexPath retain] autorelease];
        height = [self _heightForRowAtIndexPath:indexPathToRemove];
        
        while (_headerBounds.origin.y+height < offset.y) { // delete left most column
            if (indexPathToRemove.section >= numberOfRowSections) break;
            
            _headerBounds.size.height -= height;
            if (_headerBounds.size.height < 0) _headerBounds.size.height = 0;
            _headerBounds.origin.y += height;
            
            if (indexPathToRemove.row == -1) {
                _headerBounds.origin.y = [[_rowSections objectAtIndex:indexPathToRemove.section] offset] + height;
            }
            
            if (_headerColumnCells.count > 0) {
                MDSpreadViewCell *cell = [_headerColumnCells objectAtIndex:0];
                [_dequeuedCells addObject:cell];
                cell.hidden = YES;
                [_headerColumnCells removeObjectAtIndex:0];
                self._headerRowIndexPath = [indexPathToRemove indexPathWithRowOffset:1 inSpreadView:self guard:NO];
            }
            
            nextIndexPathToRemove = [indexPathToRemove indexPathWithRowOffset:1 inSpreadView:self guard:YES];
            if ([indexPathToRemove isEqualToIndexPath:nextIndexPathToRemove]) break;
            
            indexPathToRemove = nextIndexPathToRemove;
            height = [self _heightForRowAtIndexPath:indexPathToRemove];
        }
        
        if (_headerColumnCells.count == 0)
            self._headerRowIndexPath = indexPathToRemove;
    }
}

- (void)_layoutRemoveRowCellsAfterWithOffset:(CGPoint)offset size:(CGSize)size domain:(MDSpreadViewCellDomain)domain
{
    CGFloat height = 0;
    MDIndexPath *lastIndexPath = nil;
    MDIndexPath *last2IndexPath = nil;
    MDIndexPath *nextIndexPath = nil;
    
    if (domain == MDSpreadViewCellDomainCells && visibleCells.count) @autoreleasepool {
        lastIndexPath = [self _rowIndexPathFromRelativeIndex:[[visibleCells objectAtIndex:0] count]-1];
        last2IndexPath = self._visibleRowIndexPath;
        height = [self _heightForRowAtIndexPath:lastIndexPath];
        
        while (visibleBounds.origin.y+visibleBounds.size.height-height > offset.y+size.height) { // delete bottom most row
            if (lastIndexPath.section == 0 && lastIndexPath.row < -1) break;
            
            visibleBounds.size.height -= height;
            if (visibleBounds.size.height < 0) {
                visibleBounds.origin.y += visibleBounds.size.height;
                visibleBounds.size.height = 0;
                
                if (lastIndexPath.row == -1) {
                    visibleBounds.origin.y = [[_rowSections objectAtIndex:lastIndexPath.section] offset];
                }
            }
            
            if ([[visibleCells objectAtIndex:0] count] > 0)
                [self _clearCellsForRowAtIndexPath:lastIndexPath];
            
            nextIndexPath = [lastIndexPath indexPathWithRowOffset:-1 inSpreadView:self guard:YES];
            last2IndexPath = lastIndexPath;
            if ([lastIndexPath isEqualToIndexPath:nextIndexPath]) break;
            lastIndexPath = nextIndexPath;
            height = [self _heightForRowAtIndexPath:lastIndexPath];
        }
        
        if ([[visibleCells objectAtIndex:0] count] == 0)
            self._visibleRowIndexPath = last2IndexPath;
        
    } else if (domain == MDSpreadViewCellDomainHeaders) @autoreleasepool {
        lastIndexPath = [_headerRowIndexPath indexPathWithRowOffset:_headerColumnCells.count-1 inSpreadView:self guard:NO];
        last2IndexPath = self._headerRowIndexPath;
        height = [self _heightForRowAtIndexPath:lastIndexPath];
        
        while (_headerBounds.origin.y+_headerBounds.size.height-height > offset.y+size.height) { // delete bottom most row
            if (lastIndexPath.section == 0 && lastIndexPath.row < -1) break;
            
            _headerBounds.size.height -= height;
            if (_headerBounds.size.height < 0) {
                _headerBounds.origin.y += _headerBounds.size.height;
                _headerBounds.size.height = 0;
                
                if (lastIndexPath.row == -1) {
                    _headerBounds.origin.y = [[_rowSections objectAtIndex:lastIndexPath.section] offset];
                }
            }
            
            if (_headerColumnCells.count > 0) {
                NSInteger index = [self._headerRowIndexPath offsetBetweenRowIndexPath:lastIndexPath inSpreadView:self];
                if (index >= 0 && index < _headerColumnCells.count) {
                    MDSpreadViewCell *cell = [_headerColumnCells objectAtIndex:index];
                    [_dequeuedCells addObject:cell];
                    cell.hidden = YES;
                    [_headerColumnCells removeObjectAtIndex:index];
                }
            }
            
            nextIndexPath = [lastIndexPath indexPathWithRowOffset:-1 inSpreadView:self guard:YES];
            last2IndexPath = lastIndexPath;
            if ([lastIndexPath isEqualToIndexPath:nextIndexPath]) break;
            lastIndexPath = nextIndexPath;
            height = [self _heightForRowAtIndexPath:lastIndexPath];
        }
        
        if (_headerColumnCells.count == 0 && last2IndexPath != nil)
            self._headerRowIndexPath = last2IndexPath;
    }
}

- (void)_layoutColumnAtIndexPath:(MDIndexPath *)columnPath withWidth:(CGFloat)width xOffset:(CGFloat)xOffset
{
    NSInteger rowSection = self._visibleRowIndexPath.section;
    NSInteger row = self._visibleRowIndexPath.row;
    NSInteger totalInRowSection = [self _numberOfRowsInSection:rowSection];
    NSInteger totalRowSections = [self _numberOfRowSections];
    
    CGFloat constructedHeight = 0;
    UIView *anchor;
    
    while (constructedHeight < visibleBounds.size.height) {
        if (rowSection >= totalRowSections) break;
        
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
        
        cell._pureFrame = CGRectMake(xOffset, visibleBounds.origin.y+constructedHeight, width, height);
        constructedHeight += height;
        
        cell.hidden = !(width && height);
        
        [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
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
    NSInteger totalRowSections = [self _numberOfRowSections];
    
    CGFloat constructedHeight = 0;
    UIView *anchor;
    MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:-1 inSection:columnSection];
    
    while (constructedHeight < visibleBounds.size.height) {
        if (rowSection >= totalRowSections) break;
        
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
        
        cell._pureFrame = CGRectMake(xOffset, visibleBounds.origin.y+constructedHeight, width, height);
        constructedHeight += height;
        
        cell.hidden = !(width && height);
        
        [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
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
    NSInteger totalRowSections = [self _numberOfRowSections];
    
    CGFloat constructedHeight = 0;
    UIView *anchor;
    MDIndexPath *columnPath = [MDIndexPath indexPathForColumn:[self _numberOfColumnsInSection:columnSection] inSection:columnSection];
    
    while (constructedHeight < visibleBounds.size.height) {
        if (rowSection >= totalRowSections) break;
        
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
        
        cell._pureFrame = CGRectMake(xOffset, visibleBounds.origin.y+constructedHeight, width, height);
        constructedHeight += height;
        
        cell.hidden = !(width && height);
        
        [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
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
    NSInteger totalColumnSections = [self _numberOfColumnSections];
    
    CGFloat constructedWidth = 0;
    UIView *anchor;
    
    while (constructedWidth < visibleBounds.size.width) {
        if (columnSection >= totalColumnSections) break;
        
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
        
        cell._pureFrame = CGRectMake(visibleBounds.origin.x+constructedWidth, yOffset, width, height);
        constructedWidth += width;
        
        cell.hidden = !(width && height);
        
        [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
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
    NSInteger totalColumnSections = [self _numberOfColumnSections];
    
    CGFloat constructedWidth = 0;
    UIView *anchor;
    MDIndexPath *rowPath = [MDIndexPath indexPathForRow:-1 inSection:rowSection];
    
    while (constructedWidth < visibleBounds.size.width) {
        if (columnSection >= totalColumnSections) break;
        
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
        
        cell._pureFrame = CGRectMake(visibleBounds.origin.x+constructedWidth, yOffset, width, height);
        constructedWidth += width;
        
        cell.hidden = !(width && height);
        
        [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
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
    NSInteger totalColumnSections = [self _numberOfColumnSections];
    
    CGFloat constructedWidth = 0;
    UIView *anchor;
    MDIndexPath *rowPath = [MDIndexPath indexPathForRow:[self _numberOfRowsInSection:rowSection] inSection:rowSection];
    
    while (constructedWidth < visibleBounds.size.width) {
        if (columnSection >= totalColumnSections) break;
        
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
        
        cell._pureFrame = CGRectMake(visibleBounds.origin.x+constructedWidth, yOffset, width, height);
        constructedWidth += width;
        
        cell.hidden = !(width && height);
        
        [self _willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
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

- (CGRect)rectForRowSection:(NSInteger)rowSection columnSection:(NSInteger)columnSection
{
    if (!_rowSections || !_columnSections ||
        rowSection < 0 || rowSection >= [self numberOfRowSections] ||
        columnSection < 0 || columnSection >= [self numberOfColumnSections]) return CGRectNull;
    
    MDSpreadViewSection *column = [_columnSections objectAtIndex:columnSection];
    MDSpreadViewSection *row = [_rowSections objectAtIndex:rowSection];
    
    return CGRectMake(column.offset, row.offset, column.size, row.size);
}

- (CGRect)cellRectForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    if (!_rowSections || !_columnSections ||
        rowPath.section < 0 || rowPath.section >= [self numberOfRowSections] ||
        columnPath.section < 0 || columnPath.section >= [self numberOfColumnSections]) return CGRectNull;
    
    MDSpreadViewSection *columnSection = [_columnSections objectAtIndex:columnPath.section];
    MDSpreadViewSection *rowSection = [_rowSections objectAtIndex:rowPath.section];
    
    if (rowPath.row < -1 || rowPath.row > rowSection.numberOfCells ||
        columnPath.column < -1 || columnPath.column > columnSection.numberOfCells) return CGRectNull;
    
    CGRect rect = CGRectMake(columnSection.offset, rowSection.offset, [self _widthForColumnAtIndexPath:columnPath], [self _heightForRowAtIndexPath:rowPath]);
    
    if (columnPath.column >= 0)
        rect.origin.x += [self _widthForColumnHeaderInSection:columnPath.section];
    
    for (int i = 0; i < columnPath.column; i++) {
        rect.origin.x += [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:i inSection:columnPath.section]];
    }
    
    if (rowPath.row >= 0)
        rect.origin.y += [self _heightForRowHeaderInSection:rowPath.section];
    
    for (int i = 0; i < rowPath.row; i++) {
        rect.origin.y += [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:i inSection:rowPath.section]];
    }
    
    return rect;
}

#pragma mark - Cell Management

- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    MDSpreadViewCell *dequeuedCell = nil;
    NSUInteger _reuseHash = [identifier hash];
    for (MDSpreadViewCell *aCell in _dequeuedCells) {
        if (aCell->_reuseHash == _reuseHash) {
            dequeuedCell = aCell;
            break;
        }
    }
    
//    for (MDSpreadViewCell *aCell in _dequeuedCells) {
//        if ([aCell.reuseIdentifier isEqualToString:identifier]) {
//            dequeuedCell = aCell;
//            break;
//        }
//    }
    if (dequeuedCell) {
        [dequeuedCell retain];
        [_dequeuedCells removeObject:dequeuedCell];
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

- (NSSet *)_allVisibleCells
{
    NSMutableSet *allCells = [[NSMutableSet alloc] init];
    
    for (NSArray *column in visibleCells) {
        for (id cell in column) {
            if (cell != [NSNull null]) {
                [allCells addObject:cell];
            }
        }
    }
    
    return [allCells autorelease];
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
            for (NSMutableArray *column in visibleCells) {
                for (int i = 0; i < count; i++) {
                    [column insertObject:[NSNull null] atIndex:0];
                }
            }
            self._visibleRowIndexPath = rowPath;
            yIndex = 0;
        } else if (yIndex >= [column count]) {
            NSUInteger count = yIndex+1-[column count];
            for (int i = 0; i < count; i++) {
                NSNull *null = [NSNull null];
                [column addObject:null];
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
    if (!cell) return;
//    [cell removeFromSuperview];
    cell.hidden = YES;
    [_dequeuedCells addObject:cell];
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
//            [cell removeFromSuperview];
            cell.hidden = YES;
            [_dequeuedCells addObject:cell];
        }
    }
    
    [column removeAllObjects];
    
    if (xIndex == visibleCells.count-1) {
        [visibleCells removeLastObject];
    } else if (xIndex == 0) {
        [visibleCells removeObjectAtIndex:0];
        
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
//                [cell removeFromSuperview];
                cell.hidden = YES;
                [_dequeuedCells addObject:cell];
            }
            
            [column removeObjectAtIndex:yIndex];
        } else {
            MDSpreadViewCell *cell = [column objectAtIndex:yIndex];
            
            if ((NSNull *)cell != [NSNull null]) {
//                [cell removeFromSuperview];
                cell.hidden = YES;
                [_dequeuedCells addObject:cell];
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
    
//    [cell removeFromSuperview];
    cell.hidden = YES;
    [_dequeuedCells addObject:cell];
}

- (void)_clearAllCells
{
    for (NSMutableArray *array in visibleCells) {
        for (MDSpreadViewCell *cell in array) {
            if ((NSNull *)cell != [NSNull null]) {
//                [cell removeFromSuperview];
                cell.hidden = YES;
                [_dequeuedCells addObject:cell];
            }
        }
    }
}

#pragma mark - Fetchers

#pragma mark — Sizes
- (CGFloat)_widthForColumnHeaderInSection:(NSInteger)columnSection
{
    if (columnSection < 0 || columnSection >= [self _numberOfColumnSections]) return 0;
    
    if (implementsColumnHeaderWidth && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnHeaderInSection:)]) {
        return [self.delegate spreadView:self widthForColumnHeaderInSection:columnSection];
    } else {
        implementsColumnHeaderWidth = NO;
    }
    
    return self.sectionColumnHeaderWidth;
}

- (CGFloat)_widthForColumnAtIndexPath:(MDIndexPath *)columnPath
{
    if (columnPath.column < 0) return [self _widthForColumnHeaderInSection:columnPath.section];
    else if (columnPath.column >= [self _numberOfColumnsInSection:columnPath.section]) return [self _widthForColumnFooterInSection:columnPath.section];
    
    if (implementsColumnWidth && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnAtIndexPath:)]) {
        return [self.delegate spreadView:self widthForColumnAtIndexPath:columnPath];
    } else {
        implementsColumnWidth = NO;
    }
    
    return self.columnWidth;
}

- (CGFloat)_widthForColumnFooterInSection:(NSInteger)columnSection
{
    if (columnSection < 0 || columnSection >= [self _numberOfColumnSections]) return 0;
    
    return 0;
}

- (CGFloat)_heightForRowHeaderInSection:(NSInteger)rowSection
{
    if (rowSection < 0 || rowSection >= [self _numberOfRowSections]) return 0;
    
    if (implementsRowHeaderHeight && [self.delegate respondsToSelector:@selector(spreadView:heightForRowHeaderInSection:)]) {
        return [self.delegate spreadView:self heightForRowHeaderInSection:rowSection];
    } else {
        implementsRowHeaderHeight = NO;
    }
    
    return self.sectionRowHeaderHeight;
}

- (CGFloat)_heightForRowAtIndexPath:(MDIndexPath *)rowPath
{
    if (rowPath.row < 0) return [self _heightForRowHeaderInSection:rowPath.section];
    else if (rowPath.row >= [self _numberOfRowsInSection:rowPath.section]) return [self _heightForRowFooterInSection:rowPath.section];
    
    if (implementsRowHeight && [self.delegate respondsToSelector:@selector(spreadView:heightForRowAtIndexPath:)]) {
        return [self.delegate spreadView:self heightForRowAtIndexPath:rowPath];
    } else {
        implementsRowHeight = NO;
    }
    
    return self.rowHeight;
}

- (CGFloat)_heightForRowFooterInSection:(NSInteger)rowSection
{
    if (rowSection < 0 || rowSection >= [self _numberOfRowSections]) return 0;
    
    return 0;
}

#pragma mark — Counts
- (NSInteger)numberOfRowSections
{
    if (_rowSections) return [_rowSections count];
    else return [self _numberOfRowSections];
}

- (NSInteger)numberOfRowsInRowSection:(NSInteger)section
{
    if (_rowSections && section < [_rowSections count]) return [[_rowSections objectAtIndex:section] numberOfCells];
    else return [self _numberOfRowsInSection:section];
}

- (NSInteger)numberOfColumnSections
{
    if (_columnSections) return [_columnSections count];
    else return [self _numberOfColumnSections];
}

- (NSInteger)numberOfColumnsInColumnSection:(NSInteger)section
{
    if (_columnSections && section < [_columnSections count]) return [[_columnSections objectAtIndex:section] numberOfCells];
    else return [self _numberOfColumnsInSection:section];
}

- (NSInteger)_numberOfColumnsInSection:(NSInteger)section
{
    if (section < 0 || section >= [self _numberOfColumnSections]) return 0;
    
    NSInteger returnValue = 0;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:numberOfColumnsInSection:)])
        returnValue = [_dataSource spreadView:self numberOfColumnsInSection:section];
    
    return returnValue;
}

- (NSInteger)_numberOfRowsInSection:(NSInteger)section
{
    if (section < 0 || section >= [self _numberOfRowSections]) return 0;
    
    NSInteger returnValue = 0;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:numberOfRowsInSection:)])
        returnValue = [_dataSource spreadView:self numberOfRowsInSection:section];
    
    return returnValue;
}

- (NSInteger)_numberOfColumnSections
{
    NSInteger returnValue = 1;
    
    if ([_dataSource respondsToSelector:@selector(numberOfColumnSectionsInSpreadView:)])
        returnValue = [_dataSource numberOfColumnSectionsInSpreadView:self];
    
    return returnValue;
}

- (NSInteger)_numberOfRowSections
{
    NSInteger returnValue = 1;
    
    if ([_dataSource respondsToSelector:@selector(numberOfRowSectionsInSpreadView:)])
        returnValue = [_dataSource numberOfRowSectionsInSpreadView:self];
    
    return returnValue;
}

#pragma mark — Cells
- (void)_willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    if (rowPath.row <= 0 && columnPath.column <= 0) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInRowSection:forColumnSection:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInRowSection:rowPath.section forColumnSection:columnPath.section];
    } else if (rowPath.row <= 0) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInRowSection:forColumnAtIndexPath:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInRowSection:rowPath.section forColumnAtIndexPath:columnPath];
    } else if (columnPath.column <= 0) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInColumnSection:forRowAtIndexPath:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInColumnSection:columnPath.section forRowAtIndexPath:rowPath];
    } else {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forRowAtIndexPath:forColumnAtIndexPath:)])
            [self.delegate spreadView:self willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    }
}

- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
//    NSLog(@"Getting header cell %d %d", rowSection, columnSection);
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnSection:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultHeaderCornerCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[_defaultHeaderCornerCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                         reuseIdentifier:cellIdentifier] autorelease];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInRowSection:forColumnSection:)])
            cell.objectValue = [_dataSource spreadView:self titleForHeaderInRowSection:rowSection forColumnSection:columnSection];
        
        returnValue = cell;
    }
	
    returnValue.spreadView = self;
	returnValue._rowPath = [MDIndexPath indexPathForRow:-1 inSection:rowSection];
    returnValue._columnPath = [MDIndexPath indexPathForColumn:-1 inSection:columnSection];
//    [returnValue._tapGesture removeTarget:nil action:NULL];
//    [returnValue._tapGesture addTarget:self action:@selector(_selectCell:)];
    
    [returnValue setNeedsLayout];
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath
{
//    NSLog(@"Getting header cell %@ %d", rowPath, section);
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInColumnSection:forRowAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInColumnSection:section forRowAtIndexPath:rowPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultHeaderColumnCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[_defaultHeaderColumnCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleColumn
                                                         reuseIdentifier:cellIdentifier] autorelease];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInColumnSection:forRowAtIndexPath:)])
            cell.objectValue = [_dataSource spreadView:self titleForHeaderInColumnSection:section forRowAtIndexPath:rowPath];
        
        returnValue = cell;
    }
	
    returnValue.spreadView = self;
	returnValue._rowPath = rowPath;
    returnValue._columnPath = [MDIndexPath indexPathForColumn:-1 inSection:section];
//    [returnValue._tapGesture removeTarget:nil action:NULL];
//    [returnValue._tapGesture addTarget:self action:@selector(_selectCell:)];
    
    [returnValue setNeedsLayout];
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath
{
//    NSLog(@"Getting header cell %d %@", section, columnPath);
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:section forColumnAtIndexPath:columnPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultHeaderRowCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[_defaultHeaderRowCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleRow
                                                      reuseIdentifier:cellIdentifier] autorelease];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInRowSection:forColumnAtIndexPath:)])
            cell.objectValue = [_dataSource spreadView:self titleForHeaderInRowSection:section forColumnAtIndexPath:columnPath];
        
        returnValue = cell;
    }
	
    returnValue.spreadView = self;
	returnValue._rowPath = [MDIndexPath indexPathForRow:-1 inSection:section];
    returnValue._columnPath = columnPath;
//    [returnValue._tapGesture removeTarget:nil action:NULL];
//    [returnValue._tapGesture addTarget:self action:@selector(_selectCell:)];
    
    [returnValue setNeedsLayout];
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
//    NSLog(@"Getting cell %@ %@", rowPath, columnPath);
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForRowAtIndexPath:forColumnAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[_defaultCellClass alloc] initWithStyle:MDSpreadViewCellStyleDefault
                                             reuseIdentifier:cellIdentifier] autorelease];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:objectValueForRowAtIndexPath:forColumnAtIndexPath:)])
            cell.objectValue = [_dataSource spreadView:self objectValueForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
        
        returnValue = cell;
    }
    
    returnValue.spreadView = self;
	returnValue._rowPath = rowPath;
    returnValue._columnPath = columnPath;
	
    [returnValue setNeedsLayout];
    
    return returnValue;
}

#pragma mark - Selection

- (BOOL)_touchesBeganInCell:(MDSpreadViewCell *)cell
{
    if (!allowsSelection) return NO;
    
    MDSpreadViewSelection *selection = [MDSpreadViewSelection selectionWithRow:cell._rowPath column:cell._columnPath mode:self.selectionMode];
    self._currentSelection = [self _willSelectCellForSelection:selection];
    
    if (self._currentSelection) {
        [self _addSelection:self._currentSelection];
        return YES;
    } else {
        return NO;
    }
}

- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell
{
    [self _addSelection:[MDSpreadViewSelection selectionWithRow:self._currentSelection.rowPath
                                                         column:self._currentSelection.columnPath
                                                           mode:self._currentSelection.selectionMode]];
    [self _didSelectCellForRowAtIndexPath:self._currentSelection.rowPath forColumnIndex:self._currentSelection.columnPath];
    self._currentSelection = nil;
}

- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell
{
    [self _removeSelection:self._currentSelection];
    self._currentSelection = nil;
}

- (void)_addSelection:(MDSpreadViewSelection *)selection
{
    if (selection != _currentSelection) {
        NSUInteger index = [_selectedCells indexOfObject:selection];
        if (index != NSNotFound) {
            [_selectedCells replaceObjectAtIndex:index withObject:selection];
        } else {
            [_selectedCells addObject:selection];
        }
    }
    
    if (!allowsMultipleSelection) {
        NSMutableArray *bucket = [[NSMutableArray alloc] initWithCapacity:_selectedCells.count];
        
        for (MDSpreadViewSelection *oldSelection in _selectedCells) {
            if (oldSelection != selection) {
                [bucket addObject:oldSelection];
            }
        }
        
        for (MDSpreadViewSelection *oldSelection in bucket) {
            [self _removeSelection:oldSelection];
        }
        
        [bucket release];
    }
    
    
    NSMutableArray *allSelections = [[_selectedCells mutableCopy] autorelease];
    if (_currentSelection) [allSelections addObject:_currentSelection];
    NSMutableSet *allVisibleCells = [NSMutableSet setWithSet:[self _allVisibleCells]];
    [allVisibleCells addObjectsFromArray:_headerColumnCells];
    [allVisibleCells addObjectsFromArray:_headerRowCells];
    if (self._headerCornerCell) [allVisibleCells addObject:self._headerCornerCell];
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        cell.highlighted = NO;
        for (MDSpreadViewSelection *selection in allSelections) {
            if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
            
            if ([cell._rowPath isEqualToIndexPath:selection.rowPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    cell.highlighted = YES;
                }
            }
            
            if ([cell._columnPath isEqualToIndexPath:selection.columnPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    cell.highlighted = YES;
                }
                
                if ([cell._rowPath isEqualToIndexPath:selection.rowPath] && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                    cell.highlighted = YES;
                }
            }
        }
    }
}

- (void)_removeSelection:(MDSpreadViewSection *)selection
{
    [_selectedCells removeObject:selection];
    
    NSMutableSet *allVisibleCells = [NSMutableSet setWithSet:[self _allVisibleCells]];
    [allVisibleCells addObjectsFromArray:_headerColumnCells];
    [allVisibleCells addObjectsFromArray:_headerRowCells];
    if (self._headerCornerCell) [allVisibleCells addObject:self._headerCornerCell];
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        cell.highlighted = NO;
        for (MDSpreadViewSelection *selection in _selectedCells) {
            if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
            
            if ([cell._rowPath isEqualToIndexPath:selection.rowPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    cell.highlighted = YES;
                }
            }
            
            if ([cell._columnPath isEqualToIndexPath:selection.columnPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    cell.highlighted = YES;
                }
                
                if ([cell._rowPath isEqualToIndexPath:selection.rowPath] && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                    cell.highlighted = YES;
                }
            }
        }
    }
}

- (void)selectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSelectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition
{
    [self _addSelection:[MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:mode]];
    
//    if (mode != MDSpreadViewScrollPositionNone) {
//        [self scrollToCell...];
//    }
}

- (void)deselectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath animated:(BOOL)animated
{
    [self _removeSelection:[MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:MDSpreadViewSelectionModeNone]];
}

- (MDSpreadViewSelection *)_willSelectCellForSelection:(MDSpreadViewSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(spreadView:willSelectCellForSelection:)])
        selection = [self.delegate spreadView:self willSelectCellForSelection:selection];
    
    return selection;
}

- (void)_didSelectCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
	if ([self.delegate respondsToSelector:@selector(spreadView:didSelectCellForRowAtIndexPath:forColumnAtIndexPath:)])
		[self.delegate spreadView:self didSelectCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}


@end
