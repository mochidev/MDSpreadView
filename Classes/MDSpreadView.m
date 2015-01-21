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

#pragma mark - Helper functions
// From https://gist.github.com/dimitribouniol/5085495

static CGFloat MDRound(CGFloat value)
{
    static CGFloat scale = 0;
    if (scale <= 0) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    return (CGFloat)round(((double)value)*((double)scale))/scale;
}

static CGFloat MDPixel()
{
    static CGFloat scale = 0;
    if (scale <= 0) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    return 1./scale;
}

#pragma mark - MDSpreadViewCellMap

@interface MDSpreadViewCellMap : NSObject {
  @private
    NSMutableArray *columns;
}

@property (nonatomic, readonly) NSUInteger rowCount;
@property (nonatomic, readonly) NSUInteger columnCount;
@property (nonatomic, readonly, getter = hasContent) BOOL content;

- (BOOL)getIndicesForCell:(MDSpreadViewCell *)cell row:(NSUInteger *)row column:(NSUInteger *)column;

- (NSArray *)rowAtIndex:(NSUInteger)index;
- (NSArray *)columnAtIndex:(NSUInteger)index;
@property (nonatomic, readonly) NSArray *allColumns;
@property (nonatomic, readonly) NSArray *allRows;
@property (nonatomic, readonly) NSArray *allCells; // No NSNulls in here

- (void)insertRowsBefore:(NSArray *)rows; // array of arrays
- (void)insertRowsAfter:(NSArray *)rows;
- (void)insertColumnsBefore:(NSArray *)columns;
- (void)insertColumnsAfter:(NSArray *)columns;

- (NSArray *)removeCellsBeforeRow:(NSUInteger)newFirstRow column:(NSUInteger)newFirstColumn;
- (NSArray *)removeCellsAfterRow:(NSUInteger)newLastRow column:(NSUInteger)newLastColumn;
- (NSArray *)removeAllCells;

@end

@implementation MDSpreadViewCellMap

- (instancetype)init
{
    if (self = [super init]) {
        columns = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)getIndicesForCell:(MDSpreadViewCell *)aCell row:(NSUInteger *)rowIndex column:(NSUInteger *)columnIndex
{
    *columnIndex = 0;
    for (NSMutableArray *column in columns) {
        *rowIndex = [column indexOfObjectIdenticalTo:aCell];
        if (*rowIndex != NSNotFound) {
            return YES;
        }
        (*columnIndex)++; // http://stackoverflow.com/a/3655755/1565236
    }
    *rowIndex = NSNotFound;
    *columnIndex = NSNotFound;
    return NO;
}

- (NSArray *)rowAtIndex:(NSUInteger)rowIndex
{
    NSMutableArray *newRow = [[NSMutableArray alloc] initWithCapacity:self.rowCount];
    
    NSAssert((rowIndex < _rowCount), @"row index %lu beyond bounds of cell map [0, %lu]", (unsigned long)rowIndex, (unsigned long)_rowCount);
    
    for (NSMutableArray *column in columns) {
        [newRow addObject:[column objectAtIndex:rowIndex]];
    }
    
    return newRow;
}

- (NSArray *)columnAtIndex:(NSUInteger)columnIndex
{
    NSAssert((columnIndex < _columnCount), @"column index %lu beyond bounds of cell map [0, %lu]", (unsigned long)columnIndex, (unsigned long)_columnCount);
    
    return [[columns objectAtIndex:columnIndex] copy];
}

- (NSArray *)allColumns
{
    return [columns copy];
}

- (NSArray *)allRows
{
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < _rowCount; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        for (NSUInteger j = 0; j < _columnCount; j++) {
            [row addObject:[[columns objectAtIndex:j] objectAtIndex:i]];
        }
        [rows addObject:row];
    }
    
    return rows;
}

- (NSArray *)allCells
{
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    
    for (NSArray *column in columns) {
        for (id cell in column) {
            if (cell != [NSNull null]) {
                [cells addObject:cell];
            }
        }
    }
    
    return cells;
}

- (BOOL)hasContent
{
    return (_rowCount > 0);
}

- (void)insertRowsBefore:(NSArray *)cellRows
{
    if (_columnCount == 0) {
        _columnCount = [[cellRows firstObject] count];
        
        for (NSUInteger i = 0; i < _columnCount; i++) {
            [columns addObject:[[NSMutableArray alloc] init]];
        }
    }
    
    NSUInteger numberOfNewRows = cellRows.count;
    NSUInteger columnIndex = 0;
    for (NSMutableArray *column in columns) {
        NSUInteger rowIndex = 0;
        for (NSArray *newRow in cellRows) {
            NSAssert(newRow.count == _columnCount, @"added row with %lu columns not %lu as in cell map", (unsigned long)newRow.count, (unsigned long)_columnCount);
            [column insertObject:[newRow objectAtIndex:columnIndex] atIndex:rowIndex];
            rowIndex++;
        }
        columnIndex++;
    }
    _rowCount += numberOfNewRows;
}

- (void)insertRowsAfter:(NSArray *)cellRows
{
    if (_columnCount == 0) {
        _columnCount = [[cellRows firstObject] count];
        
        for (NSUInteger i = 0; i < _columnCount; i++) {
            [columns addObject:[[NSMutableArray alloc] init]];
        }
    }
    
    NSUInteger numberOfNewRows = cellRows.count;
    NSUInteger columnIndex = 0;
    for (NSMutableArray *column in columns) {
        for (NSArray *newRow in cellRows) {
            NSAssert(newRow.count == _columnCount, @"added row with %lu columns not %lu as in cell map", (unsigned long)newRow.count, (unsigned long)_columnCount);
            [column addObject:[newRow objectAtIndex:columnIndex]];
        }
        columnIndex++;
    }
    _rowCount += numberOfNewRows;
}

- (void)insertColumnsBefore:(NSArray *)cellColumns
{
    if (_rowCount == 0) {
        _rowCount = [[cellColumns firstObject] count];
    }
    NSUInteger numberOfNewColumns = cellColumns.count;
    NSUInteger columnIndex = 0;
    for (NSArray *newColumn in cellColumns) {
        NSAssert(newColumn.count == _rowCount, @"added column with %lu rows not %lu as in cell map", (unsigned long)newColumn.count, (unsigned long)_rowCount);
        [columns insertObject:[newColumn mutableCopy] atIndex:columnIndex];
        columnIndex++;
    }
    _columnCount += numberOfNewColumns;
}

- (void)insertColumnsAfter:(NSArray *)cellColumns
{
    if (_rowCount == 0) {
        _rowCount = [[cellColumns firstObject] count];
    }
    NSUInteger numberOfNewColumns = cellColumns.count;
    for (NSArray *newColumn in cellColumns) {
        NSAssert(newColumn.count == _rowCount, @"added column with %lu rows not %lu as in cell map", (unsigned long)newColumn.count, (unsigned long)_rowCount);
        [columns addObject:[newColumn mutableCopy]];
    }
    _columnCount += numberOfNewColumns;
}

- (NSArray *)removeCellsBeforeRow:(NSUInteger)newFirstRow column:(NSUInteger)newFirstColumn
{
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    while (newFirstColumn && _columnCount) {
        [cellsToRemove addObjectsFromArray:[columns firstObject]];
        [columns removeObjectAtIndex:0];
        
        _columnCount--;
        if (_columnCount == 0) {
            _rowCount = 0;
            break;
        }
        newFirstColumn--;
    }
    
    while (newFirstRow && _rowCount) {
        for (NSMutableArray *column in columns) {
            [cellsToRemove addObject:[column firstObject]];
            [column removeObjectAtIndex:0];
        }
        
        _rowCount--;
        if (_rowCount == 0) {
            [columns removeAllObjects];
            _columnCount = 0;
            break;
        }
        newFirstRow--;
    }
    
    return cellsToRemove;
}

- (NSArray *)removeCellsAfterRow:(NSUInteger)newLastRow column:(NSUInteger)newLastColumn
{
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    NSInteger rowsToRemove = _rowCount - newLastRow - 1;
    if (rowsToRemove < 0) rowsToRemove = 0;
    
    NSInteger columnsToRemove = _columnCount - newLastColumn - 1;
    if (columnsToRemove < 0) columnsToRemove = 0;
    
    while (columnsToRemove && _columnCount) {
        [cellsToRemove addObjectsFromArray:[columns lastObject]];
        [columns removeLastObject];
        
        _columnCount--;
        if (_columnCount == 0) {
            _rowCount = 0;
            break;
        }
        columnsToRemove--;
    }
    
    while (rowsToRemove && _rowCount) {
        for (NSMutableArray *column in columns) {
            [cellsToRemove addObject:[column lastObject]];
            [column removeLastObject];
        }
        
        _rowCount--;
        if (_rowCount == 0) {
            [columns removeAllObjects];
            _columnCount = 0;
            break;
        }
        rowsToRemove--;
    }
    
    return cellsToRemove;
}

- (NSArray *)removeAllCells
{
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    for (NSMutableArray *column in columns) {
        [cellsToRemove addObjectsFromArray:column];
    }
    
    [columns removeAllObjects];
    
    _rowCount = 0;
    _columnCount = 0;
    
    return cellsToRemove;
}

@end

@interface MDSpreadViewCell ()

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, readwrite, assign) MDSpreadView *spreadView;
@property (nonatomic, retain) MDSortDescriptor *sortDescriptorPrototype;
@property (nonatomic) MDSpreadViewSortAxis defaultSortAxis;
- (void)_setSortIndicator:(MDSpreadViewCellSortIndicator)_sortIndicator sortAxis:(MDSpreadViewSortAxis)_sortAxis;

@property (nonatomic, readonly) UILongPressGestureRecognizer *_tapGesture;
@property (nonatomic, retain) MDIndexPath *_rowPath;
@property (nonatomic, retain) MDIndexPath *_columnPath;
@property (nonatomic) CGRect _pureFrame;

- (void)_updateSeparators;

@end

#pragma mark - MDSpreadViewSection

@interface MDSpreadViewSection : NSObject

@property (nonatomic) NSInteger numberOfCells;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat size;

@end

@implementation MDSpreadViewSection

@end

#pragma mark - MDSpreadViewSizeCache

@interface MDSpreadViewSizeCache : NSObject

@property (nonatomic, strong) MDIndexPath *indexPath;
@property (nonatomic) CGFloat size;
@property (nonatomic) NSUInteger sectionCount;

- (instancetype)initWithIndexPath:(MDIndexPath *)indexPath size:(CGFloat)size sectionCount:(NSUInteger)sectionCount;

@end

@implementation MDSpreadViewSizeCache

- (instancetype)initWithIndexPath:(MDIndexPath *)indexPath size:(CGFloat)size sectionCount:(NSUInteger)sectionCount
{
    if (self = [super init]) {
        self.indexPath = indexPath;
        self.size = size;
        self.sectionCount = sectionCount;
    }
    return self;
}

@end

#pragma mark - MDSpreadViewSelection

@interface MDSpreadViewSelection ()

@property (nonatomic, strong, readwrite) MDIndexPath *rowPath;
@property (nonatomic, strong, readwrite) MDIndexPath *columnPath;
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
    
    return pair;
}

- (BOOL)isEqual:(MDSpreadViewSelection *)object
{
    if ([object isKindOfClass:[MDSpreadViewSelection class]]) {
        if (self == object) return YES;
        return ([self.rowPath isEqual:object.rowPath] &&
                [self.columnPath isEqual:object.columnPath]);
    }
    return NO;
}

- (NSUInteger)hash // https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
{
    return ((((NSUInteger)self.rowPath.hash) << (CHAR_BIT * sizeof(NSUInteger)) / 2) | (((NSUInteger)self.rowPath.hash) >> ((CHAR_BIT * sizeof(NSUInteger)) - (CHAR_BIT * sizeof(NSUInteger)) / 2))) ^ self.columnPath.hash;
}


@end

#pragma mark - MDIndexPath

@implementation MDIndexPath

@synthesize section, row;

+ (MDIndexPath *)indexPathForColumn:(NSInteger)b inSection:(NSInteger)a
{
    MDIndexPath *path = [[self alloc] init];
    
    path->section = a;
    path->row = b;
    
    return path;
}

+ (MDIndexPath *)indexPathForRow:(NSInteger)b inSection:(NSInteger)a
{
    MDIndexPath *path = [[self alloc] init];
    
    path->section = a;
    path->row = b;
    
    return path;
}

- (NSInteger)column
{
    return row;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%ld, %ld]", (long)section, (long)row];
}

- (BOOL)isEqual:(id)object
{
    return [self isEqualToIndexPath:object];
}

- (BOOL)isEqualToIndexPath:(MDIndexPath *)object
{
    if (object == nil) return nil;
    return (object->section == self->section && object->row == self->row);
}

- (NSUInteger)hash // https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
{
    return ((((NSUInteger)row) << (CHAR_BIT * sizeof(NSUInteger)) / 2) | (((NSUInteger)row) >> ((CHAR_BIT * sizeof(NSUInteger)) - (CHAR_BIT * sizeof(NSUInteger)) / 2))) ^ section;
}

@end

#pragma mark - MDSortDescriptor

@interface MDSortDescriptor ()

@property (nonatomic, readwrite, strong) MDIndexPath *rowIndexPath;
@property (nonatomic, readwrite, strong) MDIndexPath *columnIndexPath;
@property (nonatomic, readwrite) NSInteger rowSection;
@property (nonatomic, readwrite) NSInteger columnSection;
@property (nonatomic, readwrite) MDSpreadViewSortAxis sortAxis;

@end

@implementation MDSortDescriptor

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selectsWholeSpreadView:(BOOL)wholeView
{
    return [[self alloc] initWithKey:key ascending:ascending selectsWholeSpreadView:wholeView];
}

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector selectsWholeSpreadView:(BOOL)wholeView
{
    return [[self alloc] initWithKey:key ascending:ascending selector:selector selectsWholeSpreadView:wholeView];
}

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)cmptr selectsWholeSpreadView:(BOOL)wholeView
{
    return [[self alloc] initWithKey:key ascending:ascending comparator:cmptr selectsWholeSpreadView:wholeView];
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selectsWholeSpreadView:(BOOL)wholeView
{
    if (self = [super initWithKey:key ascending:ascending]) {
        if (wholeView) {
            _rowSection = MDSpreadViewSelectWholeSpreadView;
            _columnSection = MDSpreadViewSelectWholeSpreadView;
        }
    }
    return self;
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector selectsWholeSpreadView:(BOOL)wholeView
{
    if (self = [super initWithKey:key ascending:ascending selector:selector]) {
        if (wholeView) {
            _rowSection = MDSpreadViewSelectWholeSpreadView;
            _columnSection = MDSpreadViewSelectWholeSpreadView;
        }
    }
    return self;
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)cmptr selectsWholeSpreadView:(BOOL)wholeView
{
    if (self = [super initWithKey:key ascending:ascending comparator:cmptr]) {
        if (wholeView) {
            _rowSection = MDSpreadViewSelectWholeSpreadView;
            _columnSection = MDSpreadViewSelectWholeSpreadView;
        }
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    MDSortDescriptor *sortDescriptor = [super copyWithZone:zone];
    sortDescriptor.rowIndexPath = self.rowIndexPath;
    sortDescriptor.columnIndexPath = self.columnIndexPath;
    sortDescriptor.rowSection = self.rowSection;
    sortDescriptor.rowSection = self.columnSection;
    sortDescriptor.sortAxis = self.sortAxis;
    
    return sortDescriptor;
}

- (instancetype)reversedSortDescriptor
{
    MDSortDescriptor *sortDescriptor = [super reversedSortDescriptor];
    sortDescriptor.rowIndexPath = self.rowIndexPath;
    sortDescriptor.columnIndexPath = self.columnIndexPath;
    sortDescriptor.rowSection = self.rowSection;
    sortDescriptor.columnSection = self.columnSection;
    sortDescriptor.sortAxis = self.sortAxis;
    
    return sortDescriptor;
}

@end

#pragma mark - MDSpreadView

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

- (void)_clearAllCells;

- (void)_setNeedsReloadData;

@property (nonatomic, strong) NSMutableArray *_rowSections;
@property (nonatomic, strong) NSMutableArray *_columnSections;

@property (nonatomic, strong) MDSpreadViewSelection *_currentSelection;

- (BOOL)_touchesBeganInCell:(MDSpreadViewCell *)cell;
- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell;
- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell;

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
@synthesize selectionMode, _rowSections, _columnSections;
@synthesize _currentSelection, allowsMultipleSelection, allowsSelection, columnResizing, rowResizing;

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
    
    _dequeuedCells = [[NSMutableArray alloc] init];
    
    mapForContent = [[MDSpreadViewCellMap alloc] init];
    mapForColumnHeaders = [[MDSpreadViewCellMap alloc] init];
    mapForRowHeaders = [[MDSpreadViewCellMap alloc] init];
    mapForCornerHeaders = [[MDSpreadViewCellMap alloc] init];
    
    _rowHeight = 44; // 25
    _sectionRowHeaderHeight = 22;
    _sectionRowFooterHeight = 22;
    _columnWidth = 220;
    _sectionColumnHeaderWidth = 110;
    _sectionColumnFooterWidth = 110;
    
    _separatorStyle = MDSpreadViewCellSeparatorStyleCorner;
    _separatorColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    _selectedCells = [[NSMutableArray alloc] init];
    _sortDescriptors = [[NSMutableArray alloc] init];
    
    _highlightMode = MDSpreadViewSelectionModeCell;
    selectionMode = MDSpreadViewSelectionModeAutomatic;
    allowsSelection = YES;
    allowsMultipleSelection = NO;
    
    _rowHeaderHighlightMode = MDSpreadViewSelectionModeRow;
    _columnHeaderHighlightMode = MDSpreadViewSelectionModeColumn;
    _cornerHeaderHighlightMode = MDSpreadViewSelectionModeCell;
    
    _rowHeaderSelectionMode = MDSpreadViewSelectionModeRow;
    _columnHeaderSelectionMode = MDSpreadViewSelectionModeColumn;
    _cornerHeaderSelectionMode = MDSpreadViewSelectionModeCell;
    
    _allowsRowHeaderSelection = NO;
    _allowsColumnHeaderSelection = NO;
    _allowsCornerHeaderSelection = NO;
    
    _autoAllowSortableHeaderSelection = YES;
    _preservesSortSelections = YES;
    
    _defaultCellClass = [MDSpreadViewCell class];
    _defaultHeaderColumnCellClass = [MDSpreadViewHeaderCell class];
    _defaultHeaderCornerCellClass = [MDSpreadViewHeaderCell class];
    _defaultHeaderRowCellClass = [MDSpreadViewHeaderCell class];
    
    _defaultHeaderRowFooterCornerCellClass = [MDSpreadViewHeaderCell class];
    _defaultHeaderColumnFooterCornerCellClass = [MDSpreadViewHeaderCell class];
    
    _defaultFooterColumnCellClass = [MDSpreadViewHeaderCell class];
    _defaultFooterCornerCellClass = [MDSpreadViewHeaderCell class];
    _defaultFooterRowCellClass = [MDSpreadViewHeaderCell class];
    
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
    [self _setNeedsReloadData];
    super.delegate = delegate;
}

- (void)setDataSource:(id<MDSpreadViewDataSource>)dataSource
{
    [self _setNeedsReloadData];
    _dataSource = dataSource;
}

- (void)dealloc
{
    [reloadTimer invalidate];
    reloadTimer = nil;
    preventReload = YES; // UIScrollView stupidly calls self.delegate = nil; instead of _delegate = nil, so we are forced to do this…
}

#pragma mark - Data

- (void)setRowHeight:(CGFloat)newHeight
{
    _rowHeight = newHeight;
    
    if (implementsRowHeight) return;
    
    [self _setNeedsReloadData];
}

- (void)setSectionRowHeaderHeight:(CGFloat)newHeight
{
    _sectionRowHeaderHeight = newHeight;
    
    didSetHeaderHeight = YES;
    if (implementsRowHeaderHeight) return;
    
    [self _setNeedsReloadData];
}

- (void)setSectionRowFooterHeight:(CGFloat)newHeight
{
    _sectionRowFooterHeight = newHeight;
    
    didSetFooterHeight = YES;
    if (implementsRowFooterHeight) return;
    
    [self _setNeedsReloadData];
}

- (void)setColumnWidth:(CGFloat)newWidth
{
    _columnWidth = newWidth;
    
    if (implementsColumnWidth) return;
    
    [self _setNeedsReloadData];
}

- (void)setSectionColumnHeaderWidth:(CGFloat)newWidth
{
    _sectionColumnHeaderWidth = newWidth;
    
    didSetHeaderWidth = YES;
    if (implementsColumnHeaderWidth) return;
    
    [self _setNeedsReloadData];
}

- (void)setSectionColumnFooterWidth:(CGFloat)newWidth
{
    _sectionColumnFooterWidth = newWidth;
    
    didSetFooterWidth = YES;
    if (implementsColumnFooterWidth) return;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderCornerCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultHeaderCornerCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderColumnCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultHeaderColumnCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderRowCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultHeaderRowCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultFooterCornerCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultFooterCornerCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultFooterColumnCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultFooterColumnCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultFooterRowCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultFooterRowCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderRowFooterCornerCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultHeaderRowFooterCornerCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultHeaderColumnFooterCornerCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultHeaderColumnFooterCornerCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)setDefaultCellClass:(Class)aClass
{
    NSAssert([aClass isSubclassOfClass:[MDSpreadViewCell class]], @"%@ is not a subclass of MDSpreadViewCell.", NSStringFromClass(aClass));
    
    _defaultCellClass = aClass;
    
    [self _setNeedsReloadData];
}

- (void)_setNeedsReloadData
{
    if (preventReload) return;
    if (!reloadTimer) {
        reloadTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(_reloadDataRightAway:) userInfo:nil repeats:NO];
    }
}

- (void)_reloadDataRightAway:(id)sender
{
    [self reloadData];
}

- (void)reloadData
{
    [reloadTimer invalidate];
    reloadTimer = nil;
    
    @autoreleasepool {
    
        implementsRowHeight = YES;
        implementsRowHeaderHeight = YES;
        implementsRowFooterHeight = YES;
        implementsColumnWidth = YES;
        implementsColumnHeaderWidth = YES;
        implementsColumnFooterWidth = YES;
        
        if ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnSection:)] || [_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInRowSection:forColumnSection:)]) {
            implementsRowHeaderData = YES;
            implementsColumnHeaderData = YES;
        } else {
            implementsRowHeaderData = ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnAtIndexPath:)] ||
                                       [_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInRowSection:forColumnAtIndexPath:)] ||
                                       [_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInRowSection:forColumnFooterSection:)]);
            
            implementsColumnHeaderData = ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInColumnSection:forRowAtIndexPath:)] ||
                                          [_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInColumnSection:forRowAtIndexPath:)] ||
                                          [_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInColumnSection:forRowFooterSection:)]);
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:cellForFooterInRowSection:forColumnSection:)] || [_dataSource respondsToSelector:@selector(spreadView:titleForFooterInRowSection:forColumnSection:)]) {
            implementsRowFooterData = YES;
            implementsColumnFooterData = YES;
        } else {
            implementsRowFooterData = ([_dataSource respondsToSelector:@selector(spreadView:cellForFooterInRowSection:forColumnAtIndexPath:)] ||
                                       [_dataSource respondsToSelector:@selector(spreadView:titleForFooterInRowSection:forColumnAtIndexPath:)] ||
                                       [_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInColumnSection:forRowFooterSection:)]);
            
            implementsColumnFooterData = ([_dataSource respondsToSelector:@selector(spreadView:cellForFooterInColumnSection:forRowAtIndexPath:)] ||
                                          [_dataSource respondsToSelector:@selector(spreadView:titleForFooterInColumnSection:forRowAtIndexPath:)] ||
                                          [_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInRowSection:forColumnFooterSection:)]);
        }
        
        NSUInteger numberOfColumnSections = [self _numberOfColumnSections];
        NSUInteger numberOfRowSections = [self _numberOfRowSections];
        
        CGFloat totalWidth = 0;
        CGFloat totalHeight = 0;
        
        [self _clearAllCells];
        
        minColumnIndexPath = nil;
        maxColumnIndexPath = nil;
        minRowIndexPath = nil;
        maxRowIndexPath = nil;
        
        NSMutableArray *newColumnSections = [[NSMutableArray alloc] init];
        
        for (NSUInteger i = 0; i < numberOfColumnSections; i++) {
            MDSpreadViewSection *sectionDescriptor = [[MDSpreadViewSection alloc] init];
            [newColumnSections addObject:sectionDescriptor];
            
            NSUInteger numberOfColumns = [self _numberOfColumnsInSection:i];
            sectionDescriptor.numberOfCells = numberOfColumns;
            sectionDescriptor.offset = totalWidth;
            
            totalWidth += [self _widthForColumnHeaderInSection:i];
            
            for (NSInteger j = 0; j < numberOfColumns; j++) {
                totalWidth += [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:j inSection:i]];
            }
            
            totalWidth += [self _widthForColumnFooterInSection:i];
            
            sectionDescriptor.size = totalWidth - sectionDescriptor.offset;
        }
        
        // maybe compare to the old value, and move existing cells if there are any
        columnSections = newColumnSections;
        
        NSMutableArray *newRowSections = [[NSMutableArray alloc] init];
        
        for (NSUInteger i = 0; i < numberOfRowSections; i++) {
            MDSpreadViewSection *sectionDescriptor = [[MDSpreadViewSection alloc] init];
            [newRowSections addObject:sectionDescriptor];
            
            NSUInteger numberOfRows = [self _numberOfRowsInSection:i];
            sectionDescriptor.numberOfCells = numberOfRows;
            sectionDescriptor.offset = totalHeight;
            
            totalHeight += [self _heightForRowHeaderInSection:i];
            
            for (NSInteger j = 0; j < numberOfRows; j++) {
                totalHeight += [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:j inSection:i]];
            }
            
            totalHeight += [self _heightForRowFooterInSection:i];
            
            sectionDescriptor.size = totalHeight - sectionDescriptor.offset;
        }
        
        rowSections = newRowSections;
        CGFloat pixel = MDPixel();
        
        if (_separatorStyle == MDSpreadViewCellSeparatorStyleCorner) {
            totalWidth = MAX(totalWidth - pixel, 0);
            totalHeight = MAX(totalHeight - pixel, 0);
        } else if (_separatorStyle == MDSpreadViewCellSeparatorStyleHorizontal) {
            totalHeight = MAX(totalHeight - pixel, 0);
        } else if (_separatorStyle == MDSpreadViewCellSeparatorStyleVertical) {
            totalWidth = MAX(totalWidth - pixel, 0);
        }
        
        self.contentSize = CGSizeMake(totalWidth, totalHeight);
    
//    if (selectedSection != NSNotFound || selectedRow!= NSNotFound) {
//        if (selectedSection > numberOfSections || selectedRow > [self tableView:self numberOfRowsInSection:selectedSection]) {
//            [self deselectRow:selectedRow inSection:selectedSection];
//            [self tableView:self didSelectRow:selectedRow inSection:selectedSection];
//        }
//    }
    
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
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

#pragma mark - Separators

- (void)setSeparatorStyle:(MDSpreadViewCellSeparatorStyle)separatorStyle
{
    if (_separatorStyle != separatorStyle) {
        _separatorStyle = separatorStyle;
        cachedSeparatorImage = nil;
        
        NSMutableSet *allCreatedCells = [NSMutableSet setWithArray:mapForContent.allCells];
        [allCreatedCells addObjectsFromArray:mapForColumnHeaders.allCells];
        [allCreatedCells addObjectsFromArray:mapForRowHeaders.allCells];
        [allCreatedCells addObjectsFromArray:mapForCornerHeaders.allCells];
        [allCreatedCells addObjectsFromArray:_dequeuedCells];
        
        for (MDSpreadViewCell *cell in allCreatedCells) {
            [cell _updateSeparators];
        }
        
        [self _setNeedsReloadData];
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    if (_separatorColor != separatorColor) {
        _separatorColor = separatorColor;
        cachedSeparatorImage = nil;
        
        NSMutableSet *allCreatedCells = [NSMutableSet setWithArray:mapForContent.allCells];
        [allCreatedCells addObjectsFromArray:mapForColumnHeaders.allCells];
        [allCreatedCells addObjectsFromArray:mapForRowHeaders.allCells];
        [allCreatedCells addObjectsFromArray:mapForCornerHeaders.allCells];
        [allCreatedCells addObjectsFromArray:_dequeuedCells];
        
        for (MDSpreadViewCell *cell in allCreatedCells) {
            [cell _updateSeparators];
        }
    }
}

- (UIImage *)_separatorImage
{
    if (!cachedSeparatorImage) {
        CGFloat pixel = MDPixel();
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 2), NO, 0);
        
        [_separatorColor setFill];
        
        if (_separatorStyle == MDSpreadViewCellSeparatorStyleCorner) {
            UIRectFill(CGRectMake(0, 2-pixel, 2, pixel));
            UIRectFill(CGRectMake(2-pixel, 0, pixel, 2));
        } else if (_separatorStyle == MDSpreadViewCellSeparatorStyleHorizontal) {
            UIRectFill(CGRectMake(0, 2-pixel, 2, pixel));
        } else if (_separatorStyle == MDSpreadViewCellSeparatorStyleVertical) {
            UIRectFill(CGRectMake(2-pixel, 0, pixel, 2));
        }
        
        cachedSeparatorImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 1)];
        UIGraphicsEndImageContext();
    }
    
    return cachedSeparatorImage;
}

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

//#define MDSpreadViewFrameTime

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (reloadTimer) {
        [self reloadData];
        return;
    }
    
/* OK, the general algorithm will be something like this:
 
 1. Calculate the current bounding rect of the content. That is to say, the:
        visibleBounds
        minRowIndexPath (inclusive)
        maxRowIndexPath (inclusive)
        minColumnIndexPath
        maxColumnIndexPath
    Practically, these bounds will be ever so slightly larger than the actual bounds, to accomodate for contentInset.
    While we are at it, we will cache widths and heights into two arrays, so they don't need to be re-calculated later.
    We will use the existing visibleBounds, along with references to cell sizes to calculate this.
    However, if the (min|max)*IndexPath is different than the existing (min|max)*IndexPath, the calculations
     for that dimension will be calculated based on the existing sections.
    Finally, don't forget to include the sizes of any headers and footers! Headers have an index or -1 while
     footers have an index of sectionCount+1.
 
    For a spread view with 2 column/row sections, with 3 and 4 items respectively, we will get this:
     C C C  C C C C
     C C C  C C C C
     C C C  C C C C
 
     C C C  C C C C
     C C C  C C C C
     C C C  C C C C
     C C C  C C C C
 
 2. Remove any *content* cells that are outside of these bounds.
    Although we probably don't have any yet, *content* cells will be arranged in a 2D array with markers to
     the current min/max index paths in each direction.
    If any dimension is empty, that dimension will be marked as voided.
    Space will *not* be skipped for any headers and footers in this structure.
 
 3. Add back new content cells until the structure is complete
 
 4. Based on this, we will now calculate the column header/footer min/max index paths.
    The only difference here is that we will round the first index path to the first/last columns of a section
     for the header and footer respectively.
    As before, we remove any header and footer that fall outside this range, and then add new ones
    This 2D structure will be similar, but will only have column headers and footers, alternating each column
     (It'll probably only be 2 or 3 columns wide, while having the same height as the main structure)
    If we add any headers before an existing one, or footers after the end of the last one, be sure to reset
     the frames of the affected cells (aka, they used to be pinned)
 
    Assuming everything fit on screen, we will get a structure similar to this:
     H F  H F
     H F  H F
     H F  H F
     H F  H F
     H F  H F
     H F  H F
     H F  H F
 
 5. From here, we locate the first header and last footer, and pin them to the current horizontal bounds
 
 6. Now, we do the same for the row headers and footers.
 
    Assuming everything fit on screen, we will get a structure similar to this:
     H H H H H H H
     F F F F F F F
 
     H H H H H H H
     F F F F F F F
 
 7. Finally, we will do a similar treatment for the header and footer corner cells.
 
    The headers and footers will assume this structure:
     H B  H B
     A F  A F
 
     H B  H B
     A F  A F
 
 Note: Maybe row/column headers and footers should be in different structures?
 
 
 */
    
    // STEP 1
    
#ifdef MDSpreadViewFrameTime
    CFAbsoluteTime frameTime = CFAbsoluteTimeGetCurrent();
#endif
    
    CGRect bounds = self.bounds;
    UIEdgeInsets insets = self.contentInset;
    CGRect insetBounds = UIEdgeInsetsInsetRect(bounds, insets);
    
    CGRect _visibleBounds = CGRectZero;
    
    NSInteger minRowSection = 0;
    NSInteger maxRowSection = 0;
    NSInteger minColumnSection = 0;
    NSInteger maxColumnSection = 0;
    
    NSInteger minRowIndex = -1;
    NSInteger maxRowIndex = -1;
    NSInteger minColumnIndex = -1;
    NSInteger maxColumnIndex = -1;
    
    NSInteger totalNumberOfColumnSections = [columnSections count];
    NSInteger totalNumberOfRowSections = [rowSections count];
    
    BOOL searchingForMax = NO;
    
    // find min/max row sections
    for (MDSpreadViewSection *section in rowSections) {
        CGFloat height = section.size;
        if (!searchingForMax) {
            if (_visibleBounds.origin.y + height > bounds.origin.y) {
                searchingForMax = YES;
                maxRowSection = minRowSection;
                _visibleBounds.size.height += height;
                continue;
            }
            _visibleBounds.origin.y += height;
            minRowSection++;
            if (minRowSection >= totalNumberOfRowSections) minRowSection = (totalNumberOfRowSections == 0) ? 0 : totalNumberOfRowSections - 1;
        } else {
            if (_visibleBounds.origin.y + _visibleBounds.size.height > bounds.origin.y + bounds.size.height) {
                break;
            }
            _visibleBounds.size.height += height;
            maxRowSection++;
        }
    }
    
    NSInteger numberOfRows = [self _numberOfRowsInSection:minRowSection];
    
    // find min row index
    for (NSInteger row = -1; row <= numberOfRows; row++) { // take into account header and footer
        CGFloat height = [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:row inSection:minRowSection]];
        
        if (height && _visibleBounds.origin.y + height > bounds.origin.y) {
            minRowIndex = row;
            break;
        }
        _visibleBounds.origin.y += height;
        _visibleBounds.size.height -= height;
        
    }
    
    numberOfRows = [self _numberOfRowsInSection:maxRowSection];
    
    // find max row index
    for (NSInteger row = numberOfRows; row >= -1; row--) { // take into account header and footer
        CGFloat height = [self _heightForRowAtIndexPath:[MDIndexPath indexPathForRow:row inSection:maxRowSection]];
        
        if (height && _visibleBounds.origin.y + _visibleBounds.size.height - height < bounds.origin.y + bounds.size.height) {
            maxRowIndex = row;
            break;
        }
        _visibleBounds.size.height -= height;
        
    }
    
//    NSLog(@"Row: [%d-%d, %d-%d]", minRowSection, minRowIndex, maxRowSection, maxRowIndex);
    
    searchingForMax = NO;
    
    // find min/max column sections
    for (MDSpreadViewSection *section in columnSections) {
        CGFloat width = section.size;
        if (!searchingForMax) {
            if (_visibleBounds.origin.x + width > bounds.origin.x) {
                searchingForMax = YES;
                maxColumnSection = minColumnSection;
                _visibleBounds.size.width += width;
                continue;
            }
            _visibleBounds.origin.x += width;
            minColumnSection++;
            if (minColumnSection >= totalNumberOfColumnSections) minColumnSection = (totalNumberOfColumnSections == 0) ? 0 : totalNumberOfColumnSections - 1;
        } else {
            if (_visibleBounds.origin.x + _visibleBounds.size.width > bounds.origin.x + bounds.size.width) {
                break;
            }
            _visibleBounds.size.width += width;
            maxColumnSection++;
        }
    }
    
    NSInteger numberOfColumns = [self _numberOfColumnsInSection:minColumnSection];
    
    // find min column index
    for (NSInteger column = -1; column <= numberOfColumns; column++) { // take into account header and footer
        CGFloat width = [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForRow:column inSection:minColumnSection]];
        
        if (width && _visibleBounds.origin.x + width > bounds.origin.x) {
            minColumnIndex = column;
            break;
        }
        _visibleBounds.origin.x += width;
        _visibleBounds.size.width -= width;
        
    }
    
    numberOfColumns = [self _numberOfColumnsInSection:maxColumnSection];
    
    // find max column index
    for (NSInteger column = numberOfColumns; column >= -1; column--) { // take into account header and footer
        CGFloat width = [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForRow:column inSection:maxColumnSection]];
        
        if (width && _visibleBounds.origin.x + _visibleBounds.size.width - width < bounds.origin.x + bounds.size.width) {
            maxColumnIndex = column;
            break;
        }
        _visibleBounds.size.width -= width;
        
    }
    
//    NSLog(@"Column: [%d-%d, %d-%d]", minColumnSection, minColumnIndex, maxColumnSection, maxColumnIndex);
    
    // STEP 2
    
    // here, remove front columns and rows
    if (minColumnIndexPath) { // if this is nil, the others will be nil too
        
        // remove columns before
        NSInteger workingColumnSection = minColumnIndexPath.section;
        NSInteger workingColumnIndex = minColumnIndexPath.column;
        
        NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
        
        NSInteger preColumnDifference = 0;
        NSInteger preContentColumnDifference = 0;
        NSInteger preHeaderColumnDifference = 0;
        
        while ((workingColumnSection < minColumnSection && workingColumnIndex <= numberOfColumnsInSection) || (workingColumnSection == minColumnSection && workingColumnIndex < minColumnIndex)) { // go through sections
            if (workingColumnIndex > -1 && workingColumnIndex < numberOfColumnsInSection) {
                preContentColumnDifference++;
            } else if (workingColumnIndex == numberOfColumnsInSection) {
                preHeaderColumnDifference += 2;
            }
            
            preColumnDifference++;
            
            workingColumnIndex++;
            if (workingColumnIndex > numberOfColumnsInSection) {
                workingColumnIndex = -1;
                workingColumnSection++;
                if (workingColumnSection >= totalNumberOfColumnSections) break;
                numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
            }
            
        }
        
        // remove rows before
        NSInteger workingRowSection = minRowIndexPath.section;
        NSInteger workingRowIndex = minRowIndexPath.row;
        
        NSInteger numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
        
        NSInteger preRowDifference = 0;
        NSInteger preContentRowDifference = 0;
        NSInteger preHeaderRowDifference = 0;
        
        while ((workingRowSection < minRowSection && workingRowIndex <= numberOfRowsInSection) || (workingRowSection == minRowSection && workingRowIndex < minRowIndex)) { // go through sections
            if (workingRowIndex > -1 && workingRowIndex < numberOfRowsInSection) {
                preContentRowDifference++;
            } else if (workingRowIndex == numberOfRowsInSection) {
                preHeaderRowDifference += 2;
            }
            
            preRowDifference++;
            
            workingRowIndex++;
            if (workingRowIndex > numberOfRowsInSection) {
                workingRowIndex = -1;
                workingRowSection++;
                if (workingRowSection >= totalNumberOfRowSections) break;
                numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
            }
            
        }
        
//        NSLog(@"Removing [%d", preColumnDifference);
        
        if (preColumnDifference > 0 || preRowDifference > 0) {
            NSArray *oldCells = [mapForContent removeCellsBeforeRow:preContentRowDifference column:preContentColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            oldCells = [mapForColumnHeaders removeCellsBeforeRow:preContentRowDifference column:preHeaderColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            oldCells = [mapForRowHeaders removeCellsBeforeRow:preHeaderRowDifference column:preContentColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            oldCells = [mapForCornerHeaders removeCellsBeforeRow:preHeaderRowDifference column:preHeaderColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            if (preColumnDifference) {
                mapBounds.size.width = mapBounds.origin.x + mapBounds.size.width - _visibleBounds.origin.x;
                mapBounds.origin.x = _visibleBounds.origin.x;
                minColumnIndexPath = [MDIndexPath indexPathForColumn:minColumnIndex inSection:minColumnSection];
            }
            
            if (preRowDifference) {
                mapBounds.size.height = mapBounds.origin.y + mapBounds.size.height - _visibleBounds.origin.y;
                mapBounds.origin.y = _visibleBounds.origin.y;
                minRowIndexPath = [MDIndexPath indexPathForColumn:minRowIndex inSection:minRowSection];
            }
        }
    }
    
    // remove back columns and rows
    if (maxColumnIndexPath) { // if this is nil, the others will be nil too
    
        // remove columns after
        NSInteger workingColumnSection = maxColumnIndexPath.section;
        NSInteger workingColumnIndex = maxColumnIndexPath.column;
        
        NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
        
        NSInteger postColumnDifference = 0;
        NSInteger postContentColumnDifference = 0;
        NSInteger postHeaderColumnDifference = 0;
        
        while ((workingColumnSection > maxColumnSection && workingColumnIndex >= -1) || (workingColumnSection == maxColumnSection && workingColumnIndex > maxColumnIndex)) {
            if (workingColumnIndex > -1 && workingColumnIndex < numberOfColumnsInSection) {
                postContentColumnDifference++;
            } else if (workingColumnIndex == -1) {
                postHeaderColumnDifference += 2;
            }
            
            postColumnDifference++;
            
            workingColumnIndex--;
            if (workingColumnIndex < -1) {
                workingColumnSection--;
                if (workingColumnSection < 0) break;
                numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
                workingColumnIndex = numberOfColumnsInSection;
            }

        }
        
        // remove columns after
        NSInteger workingRowSection = maxRowIndexPath.section;
        NSInteger workingRowIndex = maxRowIndexPath.column;
        
        NSInteger numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
        
        NSInteger postRowDifference = 0;
        NSInteger postContentRowDifference = 0;
        NSInteger postHeaderRowDifference = 0;
        
        while ((workingRowSection > maxRowSection && workingRowIndex >= -1) || (workingRowSection == maxRowSection && workingRowIndex > maxRowIndex)) {
            if (workingRowIndex > -1 && workingRowIndex < numberOfRowsInSection) {
                postContentRowDifference++;
            } else if (workingRowIndex == -1) {
                postHeaderRowDifference += 2;
            }
            
            postRowDifference++;
            
            workingRowIndex--;
            if (workingRowIndex < -1) {
                workingRowSection--;
                if (workingRowSection < 0) break;
                numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
                workingRowIndex = numberOfRowsInSection;
            }
            
        }
        
//        NSLog(@"Removing %d]", postColumnDifference);
        
        if (postColumnDifference > 0 || postRowDifference > 0) {
            NSArray *oldCells = [mapForContent removeCellsAfterRow:mapForContent.rowCount - 1 - postContentRowDifference
                                                            column:mapForContent.columnCount - 1 - postContentColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            oldCells = [mapForColumnHeaders removeCellsAfterRow:mapForColumnHeaders.rowCount - 1 - postContentRowDifference
                                                         column:mapForColumnHeaders.columnCount - 1 - postHeaderColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            oldCells = [mapForRowHeaders removeCellsAfterRow:mapForRowHeaders.rowCount - 1 - postHeaderRowDifference
                                                      column:mapForRowHeaders.columnCount - 1 - postContentColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            oldCells = [mapForCornerHeaders removeCellsAfterRow:mapForCornerHeaders.rowCount - 1 - postHeaderRowDifference
                                                         column:mapForCornerHeaders.columnCount - 1 - postHeaderColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    [_dequeuedCells insertObject:cell atIndex:0];
                }
            }
            
            if (postColumnDifference) {
                mapBounds.size.width = _visibleBounds.origin.x + _visibleBounds.size.width - mapBounds.origin.x;
                maxColumnIndexPath = [MDIndexPath indexPathForColumn:maxColumnIndex inSection:maxColumnSection];
            }
            
            if (postRowDifference) {
                mapBounds.size.height = _visibleBounds.origin.y + _visibleBounds.size.height - mapBounds.origin.y;
                maxRowIndexPath = [MDIndexPath indexPathForRow:maxRowIndex inSection:maxRowSection];
            }
        }
    }
    
    // STEP 3
    
    // here, add rows, then columns
    
    // if there is already some content, add rows
    if ([mapForContent hasContent]) {
        
        NSInteger currentMinColumnSection = minColumnIndexPath.section;
        NSInteger currentMinColumnIndex = minColumnIndexPath.column;
        NSInteger currentMaxColumnSection = maxColumnIndexPath.section;
        NSInteger currentMaxColumnIndex = maxColumnIndexPath.column;
        
        // add rows before
        if ((minRowIndexPath.section > minRowSection) || (minRowIndexPath.section == minRowSection && minRowIndexPath.column > minRowIndex)) {
            
            NSInteger workingRowSection = minRowSection;
            NSInteger workingRowIndex = minRowIndex;
            
            NSInteger finalRowSection = minRowIndexPath.section;
            NSInteger finalRowIndex = minRowIndexPath.column;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            NSInteger numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
            
            while ((workingRowSection < finalRowSection && workingRowIndex <= numberOfRowsInSection) || (workingRowSection == finalRowSection && workingRowIndex < finalRowIndex)) { // go through sections
                if (workingRowSection >= totalNumberOfRowSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:currentMinColumnIndex andSection:currentMaxColumnSection index:currentMaxColumnIndex withTotalColumnSections:totalNumberOfColumnSections headersOnly:NO];
                }
                
                MDIndexPath *rowIndexPath = [MDIndexPath indexPathForRow:workingRowIndex inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:rowIndexPath];
                offset.x = mapBounds.origin.x;
                NSArray *row = [self _layoutRowAtIndexPath:rowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                  isHeader:NO headerContents:NO
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows addObject:row];
                }
                
                offset.y += height;
                
                workingRowIndex++;
                if (workingRowIndex > numberOfRowsInSection) {
                    workingRowIndex = -1;
                    workingRowSection++;
                    if (workingRowSection >= totalNumberOfRowSections) break;
                    numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
                }
            }
            
            [mapForContent insertRowsBefore:rows];
        }
        
        // add rows after
        if ((maxRowIndexPath.section < maxRowSection) || (maxRowIndexPath.section == maxRowSection && maxRowIndexPath.column < maxRowIndex)) {
            
            NSInteger workingRowSection = maxRowSection;
            NSInteger workingRowIndex = maxRowIndex;
            
            NSInteger finalRowSection = maxRowIndexPath.section;
            NSInteger finalRowIndex = maxRowIndexPath.column;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y + _visibleBounds.size.height);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            NSInteger numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
            
            while ((workingRowSection > finalRowSection && workingRowIndex >= -1) || (workingRowSection == finalRowSection && workingRowIndex > finalRowIndex)) { // go through sections
                if (workingRowSection >= totalNumberOfRowSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:currentMinColumnIndex andSection:currentMaxColumnSection index:currentMaxColumnIndex withTotalColumnSections:totalNumberOfColumnSections headersOnly:NO];
                }
                
                MDIndexPath *rowIndexPath = [MDIndexPath indexPathForRow:workingRowIndex inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:rowIndexPath];
                offset.y -= height;
                offset.x = mapBounds.origin.x;
                NSArray *row = [self _layoutRowAtIndexPath:rowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                  isHeader:NO headerContents:NO
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows insertObject:row atIndex:0];
                }
                
                workingRowIndex--;
                if (workingRowIndex < -1) {
                    workingRowSection--;
                    if (workingRowSection < 0) break;
                    numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
                    workingRowIndex = numberOfRowsInSection;
                }
            }
            
            [mapForContent insertRowsAfter:rows];
        }
        
        // add columns before
        if ((minColumnIndexPath.section > minColumnSection) || (minColumnIndexPath.section == minColumnSection && minColumnIndexPath.column > minColumnIndex)) {
            
            NSInteger workingColumnSection = minColumnSection;
            NSInteger workingColumnIndex = minColumnIndex;
            
            NSInteger finalColumnSection = minColumnIndexPath.section;
            NSInteger finalColumnIndex = minColumnIndexPath.column;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
            
            while ((workingColumnSection < finalColumnSection && workingColumnIndex <= numberOfColumnsInSection) || (workingColumnSection == finalColumnSection && workingColumnIndex < finalColumnIndex)) { // go through sections
                if (workingColumnSection >= totalNumberOfColumnSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:NO];
                }
                
                MDIndexPath *columnIndexPath = [MDIndexPath indexPathForRow:workingColumnIndex inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:columnIndexPath];
                offset.y = _visibleBounds.origin.y;
                NSArray *column = [self _layoutColumnAtIndexPath:columnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:NO headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns addObject:column];
                }
                
                offset.x += width;
                
                workingColumnIndex++;
                if (workingColumnIndex > numberOfColumnsInSection) {
                    workingColumnIndex = -1;
                    workingColumnSection++;
                    if (workingColumnSection >= totalNumberOfColumnSections) break;
                    numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
                }
            }
            
            [mapForContent insertColumnsBefore:columns];
        }
        
        // add columns after
        if ((maxColumnIndexPath.section < maxColumnSection) || (maxColumnIndexPath.section == maxColumnSection && maxColumnIndexPath.column < maxColumnIndex)) {
            
            NSInteger workingColumnSection = maxColumnSection;
            NSInteger workingColumnIndex = maxColumnIndex;
            
            NSInteger finalColumnSection = maxColumnIndexPath.section;
            NSInteger finalColumnIndex = maxColumnIndexPath.column;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x + _visibleBounds.size.width, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
            
            while ((workingColumnSection > finalColumnSection && workingColumnIndex >= -1) || (workingColumnSection == finalColumnSection && workingColumnIndex > finalColumnIndex)) { // go through sections
                if (workingColumnSection >= totalNumberOfColumnSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:NO];
                }
                
                MDIndexPath *columnIndexPath = [MDIndexPath indexPathForRow:workingColumnIndex inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:columnIndexPath];
                offset.x -= width;
                offset.y = _visibleBounds.origin.y;
                NSArray *column = [self _layoutColumnAtIndexPath:columnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:NO headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns insertObject:column atIndex:0];
                }
                
                workingColumnIndex--;
                if (workingColumnIndex < -1) {
                    workingColumnSection--;
                    if (workingColumnSection >= totalNumberOfColumnSections) break;
                    numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
                    workingColumnIndex = numberOfColumnsInSection;
                }
            }
            
            [mapForContent insertColumnsAfter:columns];
        }
        
    } else if (totalNumberOfColumnSections > 0 && totalNumberOfRowSections > 0) { // if there is nothing, start fresh, and do the whole thing in one go
        
        [mapForContent removeAllCells];
        
        NSInteger workingColumnSection = minColumnSection;
        NSInteger workingColumnIndex = minColumnIndex;
        
        CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
        
        while ((workingColumnSection < maxColumnSection && workingColumnIndex <= numberOfColumnsInSection) || (workingColumnSection == maxColumnSection && workingColumnIndex <= maxColumnIndex)) { // go through sections
            if (workingColumnSection >= totalNumberOfColumnSections) {
                NSAssert(NO, @"Shouldn't get here :/");
                break;
            }
            
            if (!rowSizesCache) {
                rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:NO];
            }
            
            MDIndexPath *columnIndexPath = [MDIndexPath indexPathForRow:workingColumnIndex inSection:workingColumnSection];
            CGFloat width = [self _widthForColumnAtIndexPath:columnIndexPath];
            offset.y = _visibleBounds.origin.y;
            NSArray *column = [self _layoutColumnAtIndexPath:columnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                    isHeader:NO headerContents:NO
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (column) {
                [columns addObject:column];
            }
            
            offset.x += width;
            
            workingColumnIndex++;
            if (workingColumnIndex > numberOfColumnsInSection) {
                workingColumnIndex = -1;
                workingColumnSection++;
                if (workingColumnSection >= totalNumberOfColumnSections) break;
                numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
            }
        }
        
        [mapForContent insertColumnsAfter:columns];
    }
    
    // STEP 4
    
    if ([mapForColumnHeaders hasContent]) {
        
        NSInteger currentMinColumnSection = minColumnIndexPath.section;
        NSInteger currentMaxColumnSection = maxColumnIndexPath.section;
        
        // add rows before
        if ((minRowIndexPath.section > minRowSection) || (minRowIndexPath.section == minRowSection && minRowIndexPath.column > minRowIndex)) {
            
            NSInteger workingRowSection = minRowSection;
            NSInteger workingRowIndex = minRowIndex;
            
            NSInteger finalRowSection = minRowIndexPath.section;
            NSInteger finalRowIndex = minRowIndexPath.column;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            NSInteger numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
            
            while ((workingRowSection < finalRowSection && workingRowIndex <= numberOfRowsInSection) || (workingRowSection == finalRowSection && workingRowIndex < finalRowIndex)) { // go through sections
                if (workingRowSection >= totalNumberOfRowSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:0
                                                                         andSection:currentMaxColumnSection index:0
                                                            withTotalColumnSections:totalNumberOfColumnSections headersOnly:YES];
                }
                
                MDIndexPath *rowIndexPath = [MDIndexPath indexPathForRow:workingRowIndex inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:rowIndexPath];
                NSArray *row = [self _layoutRowAtIndexPath:rowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                  isHeader:NO headerContents:YES
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows addObject:row];
                }
                
                offset.y += height;
                
                workingRowIndex++;
                if (workingRowIndex > numberOfRowsInSection) {
                    workingRowIndex = -1;
                    workingRowSection++;
                    if (workingRowSection >= totalNumberOfRowSections) break;
                    numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
                }
            }
            
            [mapForColumnHeaders insertRowsBefore:rows];
        }
        
        // add rows after
        if ((maxRowIndexPath.section < maxRowSection) || (maxRowIndexPath.section == maxRowSection && maxRowIndexPath.column < maxRowIndex)) {
            
            NSInteger workingRowSection = maxRowSection;
            NSInteger workingRowIndex = maxRowIndex;
            
            NSInteger finalRowSection = maxRowIndexPath.section;
            NSInteger finalRowIndex = maxRowIndexPath.column;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y + _visibleBounds.size.height);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            NSInteger numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
            
            while ((workingRowSection > finalRowSection && workingRowIndex >= -1) || (workingRowSection == finalRowSection && workingRowIndex > finalRowIndex)) { // go through sections
                if (workingRowSection >= totalNumberOfRowSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:0
                                                                         andSection:currentMaxColumnSection index:0
                                                            withTotalColumnSections:totalNumberOfColumnSections headersOnly:YES];
                }
                
                MDIndexPath *rowIndexPath = [MDIndexPath indexPathForRow:workingRowIndex inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:rowIndexPath];
                offset.y -= height;
                NSArray *row = [self _layoutRowAtIndexPath:rowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                  isHeader:NO headerContents:YES
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows insertObject:row atIndex:0];
                }
                
                workingRowIndex--;
                if (workingRowIndex < -1) {
                    workingRowSection--;
                    if (workingRowSection < 0) break;
                    numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
                    workingRowIndex = numberOfRowsInSection;
                }
            }
            
            [mapForColumnHeaders insertRowsAfter:rows];
        }
        
        // add columns before
        if (minColumnIndexPath.section > minColumnSection) {
            
            NSInteger workingColumnSection = minColumnSection;
            NSInteger finalColumnSection = minColumnIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            while (workingColumnSection < finalColumnSection) { // go through sections
                if (workingColumnSection >= totalNumberOfColumnSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:NO];
                }
                
                MDSpreadViewSection *currentSection = [columnSections objectAtIndex:workingColumnSection];
                
                NSInteger numberOfColumnsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:headerColumnIndexPath];
                offset.x = currentSection.offset;
                offset.y = _visibleBounds.origin.y;
                NSArray *header = [self _layoutColumnAtIndexPath:headerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (header) {
                    [columns addObject:header];
                }
                
                MDIndexPath *footerColumnIndexPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:workingColumnSection];
                width = [self _widthForColumnAtIndexPath:footerColumnIndexPath];
                offset.x = currentSection.offset + currentSection.size - width;
                offset.y = _visibleBounds.origin.y;
                NSArray *footer = [self _layoutColumnAtIndexPath:footerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (footer) {
                    [columns addObject:footer];
                }
                
                workingColumnSection++;
            }
            
            [mapForColumnHeaders insertColumnsBefore:columns];
        }
        
        // add columns after
        if (maxColumnIndexPath.section < maxColumnSection) {
            
            NSInteger workingColumnSection = maxColumnSection;
            NSInteger finalColumnSection = maxColumnIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            while (workingColumnSection > finalColumnSection) { // go through sections
                if (workingColumnSection < 0) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:NO];
                }
                
                MDSpreadViewSection *currentSection = [columnSections objectAtIndex:workingColumnSection];
                
                NSInteger numberOfColumnsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:headerColumnIndexPath];
                offset.x = currentSection.offset;
                offset.y = _visibleBounds.origin.y;
                NSArray *header = [self _layoutColumnAtIndexPath:headerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (header) {
                    [columns insertObject:header atIndex:0];
                }
                
                MDIndexPath *footerColumnIndexPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:workingColumnSection];
                width = [self _widthForColumnAtIndexPath:footerColumnIndexPath];
                offset.x = currentSection.offset + currentSection.size - width;
                offset.y = _visibleBounds.origin.y;
                NSArray *footer = [self _layoutColumnAtIndexPath:footerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (footer) {
                    [columns insertObject:footer atIndex:1];
                }
                
                workingColumnSection--;
            }
            
            [mapForColumnHeaders insertColumnsAfter:columns];
        }
        
    } else if (totalNumberOfColumnSections > 0 && totalNumberOfRowSections > 0) { // if there is nothing, start fresh, and do the whole thing in one go
        
        [mapForColumnHeaders removeAllCells];
        
        NSInteger workingColumnSection = minColumnSection;
        
        CGPoint offset = CGPointZero;
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        while (workingColumnSection <= maxColumnSection) { // go through sections
            if (workingColumnSection >= totalNumberOfColumnSections) {
                NSAssert(NO, @"Shouldn't get here :/");
                break;
            }
            
            if (!rowSizesCache) {
                rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:NO];
            }
            
            MDSpreadViewSection *currentSection = [columnSections objectAtIndex:workingColumnSection];
            
            NSInteger numberOfColumnsInSection = currentSection.numberOfCells;
            
            MDIndexPath *headerColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:workingColumnSection];
            CGFloat width = [self _widthForColumnAtIndexPath:headerColumnIndexPath];
            offset.x = currentSection.offset;
            offset.y = _visibleBounds.origin.y;
            NSArray *header = [self _layoutColumnAtIndexPath:headerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                    isHeader:YES headerContents:NO
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (header) {
                [columns addObject:header];
            }
            
            MDIndexPath *footerColumnIndexPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:workingColumnSection];
            width = [self _widthForColumnAtIndexPath:footerColumnIndexPath];
            offset.x = currentSection.offset + currentSection.size - width;
            offset.y = _visibleBounds.origin.y;
            NSArray *footer = [self _layoutColumnAtIndexPath:footerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                    isHeader:YES headerContents:NO
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (footer) {
                [columns addObject:footer];
            }
            
            workingColumnSection++;
        }
        
        [mapForColumnHeaders insertColumnsAfter:columns];
    }
    
    // STEP 5
    
    if ([mapForColumnHeaders hasContent]) {
        
        NSArray *columns = mapForColumnHeaders.allColumns;
        
        BOOL isHeader = YES;
        NSInteger workingColumnSection = minColumnSection;
        
        for (NSArray *column in columns) {
            NSAssert((workingColumnSection < totalNumberOfColumnSections), @"Over section bounds!");
            
            MDSpreadViewSection *currentSection = [columnSections objectAtIndex:workingColumnSection];
            CGFloat headerWidth = [self _widthForColumnHeaderInSection:workingColumnSection];
            CGFloat footerWidth = [self _widthForColumnFooterInSection:workingColumnSection];
            CGFloat sectionOffset = currentSection.offset;
            CGFloat sectionSize = currentSection.size;
            
            CGFloat newOffset = 0;
            
            if (isHeader) {
                if (sectionOffset + sectionSize - headerWidth - footerWidth < insetBounds.origin.x) {
                    newOffset = sectionOffset + sectionSize - headerWidth - footerWidth;
                } else if (sectionOffset < insetBounds.origin.x) {
                    newOffset = insetBounds.origin.x;
                } else {
                    newOffset = sectionOffset;
                }
            } else {
                if (sectionOffset + headerWidth + footerWidth > insetBounds.origin.x + insetBounds.size.width) {
                    newOffset = sectionOffset + headerWidth;
                } else if (sectionOffset + sectionSize > insetBounds.origin.x + insetBounds.size.width) {
                    newOffset = insetBounds.origin.x + insetBounds.size.width - footerWidth;
                } else {
                    newOffset = sectionOffset + sectionSize - footerWidth;
                }
                
                workingColumnSection++;
            }
            
            for (MDSpreadViewCell *cell in column) {
                if ((NSNull *)cell == [NSNull null]) continue;
                
                CGRect frame = cell._pureFrame;
                
                frame.origin.x = newOffset;
                
                cell.frame = frame;
            }
            
            isHeader = !isHeader;
        }
    }
    
    // STEP 6
    
    if ([mapForRowHeaders hasContent]) {
        
        NSInteger currentMinColumnSection = minColumnIndexPath.section;
        NSInteger currentMinColumnIndex = minColumnIndexPath.column;
        NSInteger currentMaxColumnSection = maxColumnIndexPath.section;
        NSInteger currentMaxColumnIndex = maxColumnIndexPath.column;
        
        // add rows before
        if (minRowIndexPath.section > minRowSection) {
            
            NSInteger workingRowSection = minRowSection;
            
            NSInteger finalRowSection = minRowIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            while (workingRowSection < finalRowSection) { // go through sections
                if (workingRowSection >= totalNumberOfRowSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:currentMinColumnIndex andSection:currentMaxColumnSection index:currentMaxColumnIndex withTotalColumnSections:totalNumberOfColumnSections headersOnly:NO];
                }
                
                MDSpreadViewSection *currentSection = [rowSections objectAtIndex:workingRowSection];
                
                NSInteger numberOfRowsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:headerRowIndexPath];
                offset.y = currentSection.offset;
                offset.x = mapBounds.origin.x;
                NSArray *header = [self _layoutRowAtIndexPath:headerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:NO
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (header) {
                    [rows addObject:header];
                }
                
                MDIndexPath *footerRowIndexPath = [MDIndexPath indexPathForRow:numberOfRowsInSection inSection:workingRowSection];
                height = [self _heightForRowAtIndexPath:footerRowIndexPath];
                offset.y = currentSection.offset + currentSection.size - height;
                offset.x = mapBounds.origin.x;
                NSArray *footer = [self _layoutRowAtIndexPath:footerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:NO
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (footer) {
                    [rows addObject:footer];
                }
                
                workingRowSection++;
            }
            
            [mapForRowHeaders insertRowsBefore:rows];
        }
        
        // add rows after
        if (maxRowIndexPath.section < maxRowSection) {
            
            NSInteger workingRowSection = maxRowSection;
            NSInteger finalRowSection = maxRowIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            while (workingRowSection > finalRowSection) { // go through sections
                if (workingRowSection < 0) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:currentMinColumnIndex andSection:currentMaxColumnSection index:currentMaxColumnIndex withTotalColumnSections:totalNumberOfColumnSections headersOnly:NO];
                }
                
                MDSpreadViewSection *currentSection = [rowSections objectAtIndex:workingRowSection];
                
                NSInteger numberOfRowsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:headerRowIndexPath];
                offset.y = currentSection.offset;
                offset.x = mapBounds.origin.x;
                NSArray *header = [self _layoutRowAtIndexPath:headerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:NO
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (header) {
                    [rows insertObject:header atIndex:0];
                }
                
                MDIndexPath *footerRowIndexPath = [MDIndexPath indexPathForRow:numberOfRowsInSection inSection:workingRowSection];
                height = [self _heightForRowAtIndexPath:footerRowIndexPath];
                offset.y = currentSection.offset + currentSection.size - height;
                offset.x = mapBounds.origin.x;
                NSArray *footer = [self _layoutRowAtIndexPath:footerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:NO
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (footer) {
                    [rows insertObject:footer atIndex:1];
                }
                
                workingRowSection--;
            }
            
            [mapForRowHeaders insertRowsAfter:rows];
        }
        
        // add columns before
        if ((minColumnIndexPath.section > minColumnSection) || (minColumnIndexPath.section == minColumnSection && minColumnIndexPath.column > minColumnIndex)) {
            
            NSInteger workingColumnSection = minColumnSection;
            NSInteger workingColumnIndex = minColumnIndex;
            
            NSInteger finalColumnSection = minColumnIndexPath.section;
            NSInteger finalColumnIndex = minColumnIndexPath.column;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
            
            while ((workingColumnSection < finalColumnSection && workingColumnIndex <= numberOfColumnsInSection) || (workingColumnSection == finalColumnSection && workingColumnIndex < finalColumnIndex)) { // go through sections
                if (workingColumnSection >= totalNumberOfColumnSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:YES];
                }
                
                MDIndexPath *columnIndexPath = [MDIndexPath indexPathForRow:workingColumnIndex inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:columnIndexPath];
                NSArray *column = [self _layoutColumnAtIndexPath:columnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:NO headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns addObject:column];
                }
                
                offset.x += width;
                
                workingColumnIndex++;
                if (workingColumnIndex > numberOfColumnsInSection) {
                    workingColumnIndex = -1;
                    workingColumnSection++;
                    if (workingColumnSection >= totalNumberOfColumnSections) break;
                    numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
                }
            }
            
            [mapForRowHeaders insertColumnsBefore:columns];
        }
        
        // add columns after
        if ((maxColumnIndexPath.section < maxColumnSection) || (maxColumnIndexPath.section == maxColumnSection && maxColumnIndexPath.column < maxColumnIndex)) {
            
            NSInteger workingColumnSection = maxColumnSection;
            NSInteger workingColumnIndex = maxColumnIndex;
            
            NSInteger finalColumnSection = maxColumnIndexPath.section;
            NSInteger finalColumnIndex = maxColumnIndexPath.column;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x + _visibleBounds.size.width, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
            
            while ((workingColumnSection > finalColumnSection && workingColumnIndex >= -1) || (workingColumnSection == finalColumnSection && workingColumnIndex > finalColumnIndex)) { // go through sections
                if (workingColumnSection >= totalNumberOfColumnSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:YES];
                }
                
                MDIndexPath *columnIndexPath = [MDIndexPath indexPathForRow:workingColumnIndex inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:columnIndexPath];
                offset.x -= width;
                NSArray *column = [self _layoutColumnAtIndexPath:columnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:NO headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns insertObject:column atIndex:0];
                }
                
                workingColumnIndex--;
                if (workingColumnIndex < -1) {
                    workingColumnSection--;
                    if (workingColumnSection >= totalNumberOfColumnSections) break;
                    numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
                    workingColumnIndex = numberOfColumnsInSection;
                }
            }
            
            [mapForRowHeaders insertColumnsAfter:columns];
        }
        
    } else if (totalNumberOfColumnSections > 0 && totalNumberOfRowSections > 0) { // if there is nothing, start fresh, and do the whole thing in one go
        
        [mapForRowHeaders removeAllCells];
        
        NSInteger workingColumnSection = minColumnSection;
        NSInteger workingColumnIndex = minColumnIndex;
        
        CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
        
        while ((workingColumnSection < maxColumnSection && workingColumnIndex <= numberOfColumnsInSection) || (workingColumnSection == maxColumnSection && workingColumnIndex <= maxColumnIndex)) { // go through sections
            if (workingColumnSection >= totalNumberOfColumnSections) {
                NSAssert(NO, @"Shouldn't get here :/");
                break;
            }
            
            if (!rowSizesCache) {
                rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:YES];
            }
            
            MDIndexPath *columnIndexPath = [MDIndexPath indexPathForRow:workingColumnIndex inSection:workingColumnSection];
            CGFloat width = [self _widthForColumnAtIndexPath:columnIndexPath];
            NSArray *column = [self _layoutColumnAtIndexPath:columnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                    isHeader:NO headerContents:YES
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (column) {
                [columns addObject:column];
            }
            
            offset.x += width;
            
            workingColumnIndex++;
            if (workingColumnIndex > numberOfColumnsInSection) {
                workingColumnIndex = -1;
                workingColumnSection++;
                if (workingColumnSection >= totalNumberOfColumnSections) break;
                numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
            }
        }
        
        [mapForRowHeaders insertColumnsAfter:columns];
    }
    
    // STEP 7
    
    if ([mapForRowHeaders hasContent]) {
        
        NSArray *rows = mapForRowHeaders.allRows;
        
        BOOL isHeader = YES;
        NSInteger workingRowSection = minRowSection;
        
        for (NSArray *row in rows) {
            NSAssert((workingRowSection < totalNumberOfRowSections), @"Over section bounds!");
            
            MDSpreadViewSection *currentSection = [rowSections objectAtIndex:workingRowSection];
            CGFloat headerHeight = [self _heightForRowHeaderInSection:workingRowSection];
            CGFloat footerHeight = [self _heightForRowFooterInSection:workingRowSection];
            CGFloat sectionOffset = currentSection.offset;
            CGFloat sectionSize = currentSection.size;
            
            CGFloat newOffset = 0;
            
            if (isHeader) {
                if (sectionOffset + sectionSize - headerHeight - footerHeight < insetBounds.origin.y) {
                    newOffset = sectionOffset + sectionSize - headerHeight - footerHeight;
                } else if (sectionOffset < insetBounds.origin.y) {
                    newOffset = insetBounds.origin.y;
                } else {
                    newOffset = sectionOffset;
                }
            } else {
                if (sectionOffset + headerHeight + footerHeight > insetBounds.origin.y + insetBounds.size.height) {
                    newOffset = sectionOffset + headerHeight;
                } else if (sectionOffset + sectionSize > insetBounds.origin.y + insetBounds.size.height) {
                    newOffset = insetBounds.origin.y + insetBounds.size.height - footerHeight;
                } else {
                    newOffset = sectionOffset + sectionSize - footerHeight;
                }
                
                workingRowSection++;
            }
            
            for (MDSpreadViewCell *cell in row) {
                if ((NSNull *)cell == [NSNull null]) continue;
                
                CGRect frame = cell._pureFrame;
                
                frame.origin.y = newOffset;
                
                cell.frame = frame;
            }
            
            isHeader = !isHeader;
        }
    }
    
    // STEP 8
    
    if ([mapForCornerHeaders hasContent]) {
        
        NSInteger currentMinColumnSection = minColumnIndexPath.section;
        NSInteger currentMaxColumnSection = maxColumnIndexPath.section;
        
        // add rows before
        if (minRowIndexPath.section > minRowSection) {
            
            NSInteger workingRowSection = minRowSection;
            
            NSInteger finalRowSection = minRowIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            while (workingRowSection < finalRowSection) { // go through sections
                if (workingRowSection >= totalNumberOfRowSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:0
                                                                         andSection:currentMaxColumnSection index:0
                                                            withTotalColumnSections:totalNumberOfColumnSections headersOnly:YES];
                }
                
                MDSpreadViewSection *currentSection = [rowSections objectAtIndex:workingRowSection];
                
                NSInteger numberOfRowsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:headerRowIndexPath];
                offset.y = currentSection.offset;
                offset.x = mapBounds.origin.x;
                NSArray *header = [self _layoutRowAtIndexPath:headerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:YES
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (header) {
                    [rows addObject:header];
                }
                
                MDIndexPath *footerRowIndexPath = [MDIndexPath indexPathForRow:numberOfRowsInSection inSection:workingRowSection];
                height = [self _heightForRowAtIndexPath:footerRowIndexPath];
                offset.y = currentSection.offset + currentSection.size - height;
                offset.x = mapBounds.origin.x;
                NSArray *footer = [self _layoutRowAtIndexPath:footerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:YES
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (footer) {
                    [rows addObject:footer];
                }
                
                workingRowSection++;
            }
            
            [mapForCornerHeaders insertRowsBefore:rows];
        }
        
        // add rows after
        if (maxRowIndexPath.section < maxRowSection) {
            
            NSInteger workingRowSection = maxRowSection;
            NSInteger finalRowSection = maxRowIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            while (workingRowSection > finalRowSection) { // go through sections
                if (workingRowSection < 0) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnSection index:0
                                                                         andSection:currentMaxColumnSection index:0
                                                            withTotalColumnSections:totalNumberOfColumnSections headersOnly:YES];
                }
                
                MDSpreadViewSection *currentSection = [rowSections objectAtIndex:workingRowSection];
                
                NSInteger numberOfRowsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerRowIndexPath = [MDIndexPath indexPathForRow:-1 inSection:workingRowSection];
                CGFloat height = [self _heightForRowAtIndexPath:headerRowIndexPath];
                offset.y = currentSection.offset;
                offset.x = mapBounds.origin.x;
                NSArray *header = [self _layoutRowAtIndexPath:headerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:YES
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (header) {
                    [rows insertObject:header atIndex:0];
                }
                
                MDIndexPath *footerRowIndexPath = [MDIndexPath indexPathForRow:numberOfRowsInSection inSection:workingRowSection];
                height = [self _heightForRowAtIndexPath:footerRowIndexPath];
                offset.y = currentSection.offset + currentSection.size - height;
                offset.x = mapBounds.origin.x;
                NSArray *footer = [self _layoutRowAtIndexPath:footerRowIndexPath numberOfRowsInSection:numberOfRowsInSection
                                                     isHeader:YES headerContents:YES
                                                       offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (footer) {
                    [rows insertObject:footer atIndex:1];
                }
                
                workingRowSection--;
            }
            
            [mapForCornerHeaders insertRowsAfter:rows];
        }

        // add columns before
        if (minColumnIndexPath.section > minColumnSection) {
            
            NSInteger workingColumnSection = minColumnSection;
            NSInteger finalColumnSection = minColumnIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            while (workingColumnSection < finalColumnSection) { // go through sections
                if (workingColumnSection >= totalNumberOfColumnSections) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex
                                                                   andSection:maxRowSection index:maxRowIndex
                                                         withTotalRowSections:totalNumberOfRowSections headersOnly:YES];
                }
                
                MDSpreadViewSection *currentSection = [columnSections objectAtIndex:workingColumnSection];
                
                NSInteger numberOfColumnsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:headerColumnIndexPath];
                offset.x = currentSection.offset;
                offset.y = _visibleBounds.origin.y;
                NSArray *header = [self _layoutColumnAtIndexPath:headerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (header) {
                    [columns addObject:header];
                }
                
                MDIndexPath *footerColumnIndexPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:workingColumnSection];
                width = [self _widthForColumnAtIndexPath:footerColumnIndexPath];
                offset.x = currentSection.offset + currentSection.size - width;
                offset.y = _visibleBounds.origin.y;
                NSArray *footer = [self _layoutColumnAtIndexPath:footerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (footer) {
                    [columns addObject:footer];
                }
                
                workingColumnSection++;
            }
            
            [mapForCornerHeaders insertColumnsBefore:columns];
        }
        
        // add columns after
        if (maxColumnIndexPath.section < maxColumnSection) {
            
            NSInteger workingColumnSection = maxColumnSection;
            NSInteger finalColumnSection = maxColumnIndexPath.section;
            
            CGPoint offset = CGPointZero;
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            while (workingColumnSection > finalColumnSection) { // go through sections
                if (workingColumnSection < 0) {
                    NSAssert(NO, @"Shouldn't get here :/");
                    break;
                }
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex
                                                                   andSection:maxRowSection index:maxRowIndex
                                                         withTotalRowSections:totalNumberOfRowSections headersOnly:YES];
                }
                
                MDSpreadViewSection *currentSection = [columnSections objectAtIndex:workingColumnSection];
                
                NSInteger numberOfColumnsInSection = currentSection.numberOfCells;
                
                MDIndexPath *headerColumnIndexPath = [MDIndexPath indexPathForColumn:-1 inSection:workingColumnSection];
                CGFloat width = [self _widthForColumnAtIndexPath:headerColumnIndexPath];
                offset.x = currentSection.offset;
                offset.y = _visibleBounds.origin.y;
                NSArray *header = [self _layoutColumnAtIndexPath:headerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (header) {
                    [columns insertObject:header atIndex:0];
                }
                
                MDIndexPath *footerColumnIndexPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:workingColumnSection];
                width = [self _widthForColumnAtIndexPath:footerColumnIndexPath];
                offset.x = currentSection.offset + currentSection.size - width;
                offset.y = _visibleBounds.origin.y;
                NSArray *footer = [self _layoutColumnAtIndexPath:footerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                        isHeader:YES headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (footer) {
                    [columns insertObject:footer atIndex:1];
                }
                
                workingColumnSection--;
            }
            
            [mapForCornerHeaders insertColumnsAfter:columns];
        }
        
    } else if (totalNumberOfColumnSections > 0 && totalNumberOfRowSections > 0) { // if there is nothing, start fresh, and do the whole thing in one go
        
        [mapForCornerHeaders removeAllCells];
        
        NSInteger workingColumnSection = minColumnSection;
        
        CGPoint offset = CGPointZero;
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        while (workingColumnSection <= maxColumnSection) { // go through sections
            if (workingColumnSection >= totalNumberOfColumnSections) {
                NSAssert(NO, @"Shouldn't get here :/");
                break;
            }
            
            if (!rowSizesCache) {
                rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowSection index:minRowIndex andSection:maxRowSection index:maxRowIndex withTotalRowSections:totalNumberOfRowSections headersOnly:YES];
            }
            
            MDSpreadViewSection *currentSection = [columnSections objectAtIndex:workingColumnSection];
            
            NSInteger numberOfColumnsInSection = currentSection.numberOfCells;
            
            MDIndexPath *headerColumnIndexPath = [MDIndexPath indexPathForRow:-1 inSection:workingColumnSection];
            CGFloat width = [self _widthForColumnAtIndexPath:headerColumnIndexPath];
            offset.x = currentSection.offset;
            offset.y = _visibleBounds.origin.y;
            NSArray *header = [self _layoutColumnAtIndexPath:headerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                    isHeader:YES headerContents:YES
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (header) {
                [columns addObject:header];
            }
            
            MDIndexPath *footerColumnIndexPath = [MDIndexPath indexPathForRow:numberOfColumnsInSection inSection:workingColumnSection];
            width = [self _widthForColumnAtIndexPath:footerColumnIndexPath];
            offset.x = currentSection.offset + currentSection.size - width;
            offset.y = _visibleBounds.origin.y;
            NSArray *footer = [self _layoutColumnAtIndexPath:footerColumnIndexPath numberOfColumnsInSection:numberOfColumnsInSection
                                                    isHeader:YES headerContents:YES
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (footer) {
                [columns addObject:footer];
            }
            
            workingColumnSection++;
        }
        
        [mapForCornerHeaders insertColumnsAfter:columns];
    }
    
    // STEP 9
    
    if ([mapForCornerHeaders hasContent]) {
        
        NSArray *columns = mapForCornerHeaders.allColumns;
        
        BOOL isColumnHeader = YES;
        NSInteger workingColumnSection = minColumnSection;
        
        for (NSArray *column in columns) {
            NSAssert((workingColumnSection < totalNumberOfColumnSections), @"Over section bounds!");
            
            MDSpreadViewSection *currentColumnSection = [columnSections objectAtIndex:workingColumnSection];
            CGFloat headerWidth = [self _widthForColumnHeaderInSection:workingColumnSection];
            CGFloat footerWidth = [self _widthForColumnFooterInSection:workingColumnSection];
            CGFloat sectionOffset = currentColumnSection.offset;
            CGFloat sectionSize = currentColumnSection.size;
            
            CGPoint newOffset = CGPointZero;
            
            if (isColumnHeader) {
                if (sectionOffset + sectionSize - headerWidth - footerWidth < insetBounds.origin.x) {
                    newOffset.x = sectionOffset + sectionSize - headerWidth - footerWidth;
                } else if (sectionOffset < insetBounds.origin.x) {
                    newOffset.x = insetBounds.origin.x;
                } else {
                    newOffset.x = sectionOffset;
                }
            } else {
                if (sectionOffset + headerWidth + footerWidth > insetBounds.origin.x + insetBounds.size.width) {
                    newOffset.x = sectionOffset + headerWidth;
                } else if (sectionOffset + sectionSize > insetBounds.origin.x + insetBounds.size.width) {
                    newOffset.x = insetBounds.origin.x + insetBounds.size.width - footerWidth;
                } else {
                    newOffset.x = sectionOffset + sectionSize - footerWidth;
                }
                
                workingColumnSection++;
            }
            
            BOOL isRowHeader = YES;
            NSInteger workingRowSection = minRowSection;
            
            for (MDSpreadViewCell *cell in column) {
                NSAssert((workingRowSection < totalNumberOfRowSections), @"Over section bounds!");
                
                MDSpreadViewSection *currentRowSection = [rowSections objectAtIndex:workingRowSection];
                CGFloat headerHeight = [self _heightForRowHeaderInSection:workingRowSection];
                CGFloat footerHeight = [self _heightForRowFooterInSection:workingRowSection];
                CGFloat sectionOffset = currentRowSection.offset;
                CGFloat sectionSize = currentRowSection.size;

                if (isRowHeader) {
                    if (sectionOffset + sectionSize - headerHeight - footerHeight < insetBounds.origin.y) {
                        newOffset.y = sectionOffset + sectionSize - headerHeight - footerHeight;
                    } else if (sectionOffset < insetBounds.origin.y) {
                        newOffset.y = insetBounds.origin.y;
                    } else {
                        newOffset.y = sectionOffset;
                    }
                } else {
                    if (sectionOffset + headerHeight + footerHeight > insetBounds.origin.y + insetBounds.size.height) {
                        newOffset.y = sectionOffset + headerHeight;
                    } else if (sectionOffset + sectionSize > insetBounds.origin.y + insetBounds.size.height) {
                        newOffset.y = insetBounds.origin.y + insetBounds.size.height - footerHeight;
                    } else {
                        newOffset.y = sectionOffset + sectionSize - footerHeight;
                    }
                    
                    workingRowSection++;
                }
                
                isRowHeader = !isRowHeader;
                
                if ((NSNull *)cell == [NSNull null]) continue;
                
                CGRect frame = cell._pureFrame;
                
                frame.origin = newOffset;
                
                cell.frame = frame;
            }
            
            isColumnHeader = !isColumnHeader;
        }
    }
    
    if (totalNumberOfColumnSections > 0 && totalNumberOfRowSections > 0) {
        mapBounds = _visibleBounds;
        minColumnIndexPath = [MDIndexPath indexPathForColumn:minColumnIndex inSection:minColumnSection];
        maxColumnIndexPath = [MDIndexPath indexPathForColumn:maxColumnIndex inSection:maxColumnSection];
        minRowIndexPath = [MDIndexPath indexPathForColumn:minRowIndex inSection:minRowSection];
        maxRowIndexPath = [MDIndexPath indexPathForColumn:maxRowIndex inSection:maxRowSection];
    }
    
//    NSLog(@" \n ");
//    NSLog(@"Min Target: [%d, %d] x [%d, %d]", minColumnSection, minColumnIndex, minRowSection, minRowIndex);
//    NSLog(@"Min Actual: [%d, %d] x [%d, %d]", minColumnIndexPath.section, minColumnIndexPath.column, minRowIndexPath.section, minRowIndexPath.row);
//    NSLog(@"Max Target: [%d, %d] x [%d, %d]", maxColumnSection, maxColumnIndex, maxRowSection, maxRowIndex);
//    NSLog(@"Max Actual: [%d, %d] x [%d, %d]", maxColumnIndexPath.section, maxColumnIndexPath.column, maxRowIndexPath.section, maxRowIndexPath.row);
    
    //    NSLog(@"%@", NSStringFromCGRect(self.bounds));
    
    //    CGRect _visibleBounds = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    
//    if (!dummyView) {
//        dummyView = [[UIView alloc] init];
//        dummyView.backgroundColor = [UIColor colorWithHue:(arc4random()%1000)/1000. saturation:1 brightness:1 alpha:0.1];
//        [self addSubview:dummyView];
//    }
//    dummyView.frame = _visibleBounds;
//    
//    if (!dummyViewB) {
//        dummyViewB = [[UIView alloc] init];
//        dummyViewB.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
//        [self addSubview:dummyViewB];
//    }
//    dummyViewB.frame = mapBounds;
   
#ifdef MDSpreadViewFrameTime
    NSLog(@"Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif

}

// Only call this if the frame is non-zero!!
- (MDSpreadViewCell *)_preparedCellForRowAtIndexPath:(MDIndexPath *)rowIndexPath forColumnAtIndexPath:(MDIndexPath *)columnIndexPath withRowSectionCount:(NSUInteger)rowSectionCount columnSectionCount:(NSUInteger)columnSectionCount frame:(CGRect)frame
{
    MDSpreadViewCell *cell = nil;
    UIView *anchor = nil;
    
    NSInteger row = rowIndexPath.row;
    NSInteger rowSection = rowIndexPath.section;
    NSInteger column = columnIndexPath.column;
    NSInteger columnSection = columnIndexPath.section;
    
    dequeuedCellSizeHint = frame.size;
    dequeuedCellRowIndexHint = rowIndexPath;
    dequeuedCellColumnIndexHint = columnIndexPath;
    
    if (row == -1 && column == -1) { // corner header
        cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
        anchor = anchorCornerHeaderCell;
    } else if (row == rowSectionCount && column == columnSectionCount) { // corner footer
        cell = [self _cellForFooterInRowSection:rowSection forColumnSection:columnSection];
        anchor = anchorCornerHeaderCell;
    } else if (row == -1 && column == columnSectionCount) { // header row footer column
        cell = [self _cellForHeaderInRowSection:rowSection forColumnFooterSection:columnSection];
        anchor = anchorCornerHeaderCell;
    } else if (row == rowSectionCount && column == -1) { // header column footer row
        cell = [self _cellForHeaderInColumnSection:columnSection forRowFooterSection:rowSection];
        anchor = anchorCornerHeaderCell;
    } else if (row == -1) { // header row
        cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnIndexPath];
        anchor = anchorRowHeaderCell;
    } else if (row == rowSectionCount) { // footer row
        cell = [self _cellForFooterInRowSection:rowSection forColumnAtIndexPath:columnIndexPath];
        anchor = anchorRowHeaderCell;
    } else if (column == -1) { // header column
        cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
        anchor = anchorColumnHeaderCell;
    } else if (column == columnSectionCount) { // footer column
        cell = [self _cellForFooterInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
        anchor = anchorColumnHeaderCell;
    } else { // content
        cell = [self _cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath];
        anchor = anchorCell;
    }
    
    cell._pureFrame = frame;
    cell.hidden = NO;
    
    BOOL shouldSelect = NO;
    
    for (MDSpreadViewSelection *selection in _selectedCells) {
        if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
        
        if ([cell._rowPath isEqualToIndexPath:selection.rowPath]) {
            if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldSelect = YES;
            }
        }
        
        if ([cell._columnPath isEqualToIndexPath:selection.columnPath]) {
            if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldSelect = YES;
            }
            
            if ([cell._rowPath isEqualToIndexPath:selection.rowPath] && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                shouldSelect = YES;
            }
        }
    }
    
    [cell setSelected:shouldSelect animated:NO];
    
    BOOL shouldHighlight = NO;
    
    if (_currentSelection && _currentSelection.selectionMode != MDSpreadViewSelectionModeNone && _currentSelection.selectionMode != MDSpreadViewSelectionModeAutomatic) {
    
        if ([cell._rowPath isEqualToIndexPath:_currentSelection.rowPath]) {
            if (_currentSelection.selectionMode == MDSpreadViewSelectionModeRow ||
                _currentSelection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldHighlight = YES;
            }
        }
        
        if ([cell._columnPath isEqualToIndexPath:_currentSelection.columnPath]) {
            if (_currentSelection.selectionMode == MDSpreadViewSelectionModeColumn ||
                _currentSelection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldHighlight = YES;
            }
            
            if ([cell._rowPath isEqualToIndexPath:_currentSelection.rowPath] && _currentSelection.selectionMode == MDSpreadViewSelectionModeCell) {
                shouldHighlight = YES;
            }
        }
    }
    
    [cell setHighlighted:shouldHighlight animated:NO];
    
    MDSpreadViewCellSortIndicator sortIndicator = MDSpreadViewCellSortIndicatorNone;
    MDSortDescriptor *cellSortDescriptorPrototype = [self _sortDescriptorForRowIndexPath:nil columnIndexPath:nil cell:cell prototype:nil];
    MDSortDescriptor *firstSortDescriptor = _sortDescriptors.firstObject;
    
    if (firstSortDescriptor && [cellSortDescriptorPrototype.key isEqualToString:firstSortDescriptor.key]) {
        if ([firstSortDescriptor ascending]) {
            sortIndicator = MDSpreadViewCellSortIndicatorAscending;
        } else {
            sortIndicator = MDSpreadViewCellSortIndicatorDescending;
        }
    }
    
    [cell _setSortIndicator:sortIndicator sortAxis:firstSortDescriptor.sortAxis];
    
    [self _willDisplayCell:cell forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath];
    
    if ([cell superview] != self) {
        [self insertSubview:cell belowSubview:anchor];
    }
    
    return cell;
}

- (NSArray *)_generateColumnSizeCacheBetweenSection:(NSInteger)minColumnSection index:(NSInteger)minColumnIndex andSection:(NSInteger)maxColumnSection index:(NSInteger)maxColumnIndex withTotalColumnSections:(NSInteger)totalNumberOfColumnSections headersOnly:(BOOL)headersOnly
{
    NSMutableArray *columnSizesCache = [[NSMutableArray alloc] init];
    
    if (headersOnly) {
        minColumnIndex = -1;
        maxColumnIndex = [(MDSpreadViewSection *)[columnSections objectAtIndex:maxColumnSection] numberOfCells];
    }
    
    NSInteger workingColumnSection = minColumnSection;
    NSInteger workingColumnIndex = minColumnIndex;
    NSInteger numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
    
    while ((workingColumnSection < maxColumnSection && workingColumnIndex <= numberOfColumnsInSection) || (workingColumnSection == maxColumnSection && workingColumnIndex <= maxColumnIndex)) { // go through sections
        if (workingColumnSection >= totalNumberOfColumnSections) {
            NSAssert(NO, @"Shouldn't get here :/");
            break;
        }
        
        MDIndexPath *indexPath = [MDIndexPath indexPathForColumn:workingColumnIndex inSection:workingColumnSection];
        
        if (!headersOnly || (workingColumnIndex == -1 || workingColumnIndex == numberOfColumnsInSection))
            [columnSizesCache addObject:[[MDSpreadViewSizeCache alloc] initWithIndexPath:indexPath size:[self _widthForColumnAtIndexPath:indexPath] sectionCount:numberOfColumnsInSection]];
        
        workingColumnIndex++;
        if (workingColumnIndex > numberOfColumnsInSection) {
            workingColumnIndex = -1;
            workingColumnSection++;
            if (workingColumnSection >= totalNumberOfColumnSections) break;
            numberOfColumnsInSection = [(MDSpreadViewSection *)[columnSections objectAtIndex:workingColumnSection] numberOfCells];
        }
    }
    
    return columnSizesCache;
}

- (NSArray *)_generateRowSizeCacheBetweenSection:(NSInteger)minRowSection index:(NSInteger)minRowIndex andSection:(NSInteger)maxRowSection index:(NSInteger)maxRowIndex withTotalRowSections:(NSInteger)totalNumberOfRowSections headersOnly:(BOOL)headersOnly
{
    NSMutableArray *rowSizesCache = [[NSMutableArray alloc] init];
    
    if (headersOnly) {
        minRowIndex = -1;
        maxRowIndex = [(MDSpreadViewSection *)[rowSections objectAtIndex:maxRowSection] numberOfCells];
    }
    
    NSInteger workingRowSection = minRowSection;
    NSInteger workingRowIndex = minRowIndex;
    NSInteger numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
    
    while ((workingRowSection < maxRowSection && workingRowIndex <= numberOfRowsInSection) || (workingRowSection == maxRowSection && workingRowIndex <= maxRowIndex)) { // go through sections
        if (workingRowSection >= totalNumberOfRowSections) {
            NSAssert(NO, @"Shouldn't get here :/");
            break;
        }
        
        MDIndexPath *indexPath = [MDIndexPath indexPathForRow:workingRowIndex inSection:workingRowSection];
        
        if (!headersOnly || (workingRowIndex == -1 || workingRowIndex == numberOfRowsInSection))
            [rowSizesCache addObject:[[MDSpreadViewSizeCache alloc] initWithIndexPath:indexPath size:[self _heightForRowAtIndexPath:indexPath] sectionCount:numberOfRowsInSection]];
        
        workingRowIndex++;
        if (workingRowIndex > numberOfRowsInSection) {
            workingRowIndex = -1;
            workingRowSection++;
            if (workingRowSection >= totalNumberOfRowSections) break;
            numberOfRowsInSection = [(MDSpreadViewSection *)[rowSections objectAtIndex:workingRowSection] numberOfCells];
        }
    }
    
    return rowSizesCache;
}

- (NSArray *)_layoutColumnAtIndexPath:(MDIndexPath *)columnIndexPath numberOfColumnsInSection:(NSInteger)numberOfColumnsInSection
                             isHeader:(BOOL)isHeader headerContents:(BOOL)headerContents
                               offset:(CGPoint)offset width:(CGFloat)width rowSizesCache:(NSArray *)rowSizesCache
{
    NSInteger workingColumnIndex = columnIndexPath.column;
    
    NSMutableArray *column = [[NSMutableArray alloc] init];
    
    CGRect frame = CGRectZero;
    frame.origin = offset;
    frame.size.width = width;
    
    if ((workingColumnIndex >= 0 && workingColumnIndex < numberOfColumnsInSection) || isHeader) {
        if (width > 0) {
            for (MDSpreadViewSizeCache *aSizeCache in rowSizesCache) {
                MDIndexPath *rowIndexPath = aSizeCache.indexPath;
                NSUInteger numberOfRowsInSection = aSizeCache.sectionCount;
                
                CGFloat height = aSizeCache.size;
                frame.size.height = height;
                
                if (headerContents) {
                    MDSpreadViewSection *currentSection = [rowSections objectAtIndex:rowIndexPath.section];
                    
                    if (rowIndexPath.row == -1) {
                        frame.origin.y = currentSection.offset;
                    } else {
                        frame.origin.y = currentSection.offset + currentSection.size - height;
                    }
                }
                
                NSInteger row = rowIndexPath.row;
                
                if ((row >= 0 && row < numberOfRowsInSection) || headerContents) {
                    if (height > 0 && width > 0) {
                        [column addObject:[self _preparedCellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath
                                                           withRowSectionCount:numberOfRowsInSection columnSectionCount:numberOfColumnsInSection
                                                                         frame:frame]];
                    } else {
                        [column addObject:[NSNull null]];
                    }
                }
                
                frame.origin.y += height;
            }
        } else {
            for (MDSpreadViewSizeCache *aSizeCache in rowSizesCache) {
                MDIndexPath *rowIndexPath = aSizeCache.indexPath;
                NSUInteger numberOfRowsInSection = aSizeCache.sectionCount;
                NSInteger row = rowIndexPath.row;
                
                if ((row >= 0 && row < numberOfRowsInSection) || headerContents) {
                    [column addObject:[NSNull null]];
                }
            }
        }
        
        return column;
    }
    
    return nil;
}

- (NSArray *)_layoutRowAtIndexPath:(MDIndexPath *)rowIndexPath numberOfRowsInSection:(NSInteger)numberOfRowsInSection
                          isHeader:(BOOL)isHeader headerContents:(BOOL)headerContents
                            offset:(CGPoint)offset height:(CGFloat)height columnSizesCache:(NSArray *)columnSizesCache
{
    NSInteger workingRowIndex = rowIndexPath.row;
    
    NSMutableArray *row = [[NSMutableArray alloc] init];
    
    CGRect frame = CGRectZero;
    frame.origin = offset;
    frame.size.height = height;
    
    if ((workingRowIndex >= 0 && workingRowIndex < numberOfRowsInSection) || isHeader) {
        if (height > 0) {
            for (MDSpreadViewSizeCache *aSizeCache in columnSizesCache) {
                MDIndexPath *columnIndexPath = aSizeCache.indexPath;
                NSUInteger numberOfColumnsInSection = aSizeCache.sectionCount;
                
                CGFloat width = aSizeCache.size;
                frame.size.width = width;
                
                if (headerContents) {
                    MDSpreadViewSection *currentSection = [columnSections objectAtIndex:columnIndexPath.section];
                    
                    if (columnIndexPath.column == -1) {
                        frame.origin.x = currentSection.offset;
                    } else {
                        frame.origin.x = currentSection.offset + currentSection.size - width;
                    }
                }
                
                NSInteger column = columnIndexPath.column;
                
                if ((column >= 0 && column < numberOfColumnsInSection) || headerContents) {
                    if (width > 0 && height > 0) {
                        [row addObject:[self _preparedCellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath
                                                        withRowSectionCount:numberOfRowsInSection columnSectionCount:numberOfColumnsInSection
                                                                      frame:frame]];
                    } else {
                        [row addObject:[NSNull null]];
                    }
                }
                
                frame.origin.x += width;
            }
        } else {
            for (MDSpreadViewSizeCache *aSizeCache in columnSizesCache) {
                MDIndexPath *columnIndexPath = aSizeCache.indexPath;
                NSUInteger numberOfColumnsInSection = aSizeCache.sectionCount;
                NSInteger column = columnIndexPath.column;
                
                if ((column >= 0 && column < numberOfColumnsInSection) || headerContents) {
                    [row addObject:[NSNull null]];
                }
            }
        }
        
        return row;
    }
    
    return nil;
}

- (CGRect)rectForRowSection:(NSInteger)rowSection columnSection:(NSInteger)columnSection
{
    if (!rowSections || !columnSections ||
        rowSection < 0 || rowSection >= rowSections.count ||
        columnSection < 0 || columnSection >= columnSections.count) return CGRectNull;
    
    MDSpreadViewSection *column = [columnSections objectAtIndex:columnSection];
    MDSpreadViewSection *row = [rowSections objectAtIndex:rowSection];
    
    return CGRectMake(column.offset, row.offset, column.size, row.size);
}

- (CGRect)cellRectForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    if (!rowSections || !columnSections ||
        rowPath.section < 0 || rowPath.section >= rowSections.count ||
        columnPath.section < 0 || columnPath.section >= columnSections.count) return CGRectNull;
    
    MDSpreadViewSection *columnSection = [columnSections objectAtIndex:columnPath.section];
    MDSpreadViewSection *rowSection = [rowSections objectAtIndex:rowPath.section];
    
    if (rowPath.row < -1 || rowPath.row > rowSection.numberOfCells ||
        columnPath.column < -1 || columnPath.column > columnSection.numberOfCells) return CGRectNull;
    
    CGRect rect = CGRectMake(columnSection.offset, rowSection.offset, [self _widthForColumnAtIndexPath:columnPath], [self _heightForRowAtIndexPath:rowPath]);
    
    for (int i = -1; i < columnPath.column; i++) {
        rect.origin.x += [self _widthForColumnAtIndexPath:[MDIndexPath indexPathForColumn:i inSection:columnPath.section]];
    }
    
    for (int i = -1; i < rowPath.row; i++) {
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
        if (aCell->_reuseHash == _reuseHash && [aCell._rowPath isEqualToIndexPath:dequeuedCellRowIndexHint] && [aCell._columnPath isEqualToIndexPath:dequeuedCellColumnIndexHint]) {
            dequeuedCell = aCell;
            break;
        }
    }
    
    if (!dequeuedCell) for (MDSpreadViewCell *aCell in _dequeuedCells) {
        if (aCell->_reuseHash == _reuseHash && CGSizeEqualToSize(aCell.frame.size, dequeuedCellSizeHint)) {
            dequeuedCell = aCell;
            break;
        }
    }
    
    if (!dequeuedCell) for (MDSpreadViewCell *aCell in _dequeuedCells) {
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
        [_dequeuedCells removeObject:dequeuedCell];
        [dequeuedCell prepareForReuse];
    }
    return dequeuedCell;
}

- (void)_clearAllCells
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:[mapForContent removeAllCells]];
    [array addObjectsFromArray:[mapForColumnHeaders removeAllCells]];
    [array addObjectsFromArray:[mapForRowHeaders removeAllCells]];
    [array addObjectsFromArray:[mapForCornerHeaders removeAllCells]];
    
    for (MDSpreadViewCell *cell in array) {
        if ((NSNull *)cell != [NSNull null]) {
            cell.hidden = YES;
            [_dequeuedCells insertObject:cell atIndex:0];
        }
    }
}

- (MDSpreadViewCell *)cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:mapForContent.allCells];
    [allVisibleCells addObjectsFromArray:mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForCornerHeaders.allCells];
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        if ([cell._rowPath isEqualToIndexPath:rowPath] && [cell._columnPath isEqualToIndexPath:columnPath]) {
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - Fetchers

#pragma mark — Sizes
- (CGFloat)_widthForColumnHeaderInSection:(NSInteger)columnSection
{
    if (columnSection < 0 || columnSection >= [self _numberOfColumnSections]) return 0;
    
    if (implementsColumnHeaderWidth && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnHeaderInSection:)]) {
        return MDRound([self.delegate spreadView:self widthForColumnHeaderInSection:columnSection]);
    } else {
        implementsColumnHeaderWidth = NO;
    }
    
    if (!didSetHeaderWidth && !implementsColumnHeaderData) return 0;
    
    return MDRound(self.sectionColumnHeaderWidth);
}

- (CGFloat)_widthForColumnAtIndexPath:(MDIndexPath *)columnPath
{
    if (columnPath.column < 0) return [self _widthForColumnHeaderInSection:columnPath.section];
    else if (columnPath.column >= [self _numberOfColumnsInSection:columnPath.section]) return [self _widthForColumnFooterInSection:columnPath.section];
    
    if (implementsColumnWidth && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnAtIndexPath:)]) {
        return MDRound([self.delegate spreadView:self widthForColumnAtIndexPath:columnPath]);
    } else {
        implementsColumnWidth = NO;
    }
    
    return MDRound(self.columnWidth);
}

- (CGFloat)_widthForColumnFooterInSection:(NSInteger)columnSection
{
    if (columnSection < 0 || columnSection >= [self _numberOfColumnSections]) return 0;
    
    if (implementsColumnFooterWidth && [self.delegate respondsToSelector:@selector(spreadView:widthForColumnFooterInSection:)]) {
        return MDRound([self.delegate spreadView:self widthForColumnFooterInSection:columnSection]);
    } else {
        implementsColumnFooterWidth = NO;
    }
    
    if (!didSetFooterWidth && !implementsColumnFooterData) return 0;
    
    return MDRound(self.sectionColumnFooterWidth);
}

- (CGFloat)_heightForRowHeaderInSection:(NSInteger)rowSection
{
    if (rowSection < 0 || rowSection >= [self _numberOfRowSections]) return 0;
    
    if (implementsRowHeaderHeight && [self.delegate respondsToSelector:@selector(spreadView:heightForRowHeaderInSection:)]) {
        return MDRound([self.delegate spreadView:self heightForRowHeaderInSection:rowSection]);
    } else {
        implementsRowHeaderHeight = NO;
    }
    
    if (!didSetHeaderHeight && !implementsRowHeaderData) return 0;
    
    return MDRound(self.sectionRowHeaderHeight);
}

- (CGFloat)_heightForRowAtIndexPath:(MDIndexPath *)rowPath
{
    if (rowPath.row < 0) return [self _heightForRowHeaderInSection:rowPath.section];
    else if (rowPath.row >= [self _numberOfRowsInSection:rowPath.section]) return [self _heightForRowFooterInSection:rowPath.section];
    
    if (implementsRowHeight && [self.delegate respondsToSelector:@selector(spreadView:heightForRowAtIndexPath:)]) {
        return MDRound([self.delegate spreadView:self heightForRowAtIndexPath:rowPath]);
    } else {
        implementsRowHeight = NO;
    }
    
    return MDRound(self.rowHeight);
}

- (CGFloat)_heightForRowFooterInSection:(NSInteger)rowSection
{
    if (rowSection < 0 || rowSection >= [self _numberOfRowSections]) return 0;
    
    if (implementsRowFooterHeight && [self.delegate respondsToSelector:@selector(spreadView:heightForRowFooterInSection:)]) {
        return MDRound([self.delegate spreadView:self heightForRowFooterInSection:rowSection]);
    } else {
        implementsRowFooterHeight = NO;
    }
    
    if (!didSetFooterHeight && !implementsRowFooterData) return 0;
    
    return MDRound(self.sectionRowFooterHeight);
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
        returnValue = MAX([_dataSource spreadView:self numberOfColumnsInSection:section], 0);
    
    return returnValue;
}

- (NSInteger)_numberOfRowsInSection:(NSInteger)section
{
    if (section < 0 || section >= [self _numberOfRowSections]) return 0;
    
    NSInteger returnValue = 0;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:numberOfRowsInSection:)])
        returnValue = MAX([_dataSource spreadView:self numberOfRowsInSection:section], 0);
    
    return returnValue;
}

- (NSInteger)_numberOfColumnSections
{
    NSInteger returnValue = 1;
    
    if ([_dataSource respondsToSelector:@selector(numberOfColumnSectionsInSpreadView:)])
        returnValue = MAX([_dataSource numberOfColumnSectionsInSpreadView:self], 0);
    
    return returnValue;
}

- (NSInteger)_numberOfRowSections
{
    NSInteger returnValue = 1;
    
    if ([_dataSource respondsToSelector:@selector(numberOfRowSectionsInSpreadView:)])
        returnValue = MAX([_dataSource numberOfRowSectionsInSpreadView:self], 0);
    
    return returnValue;
}

#pragma mark — Cells
- (void)_willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    NSInteger numberOfRowsInSection = [[rowSections objectAtIndex:rowPath.section] numberOfCells];
    NSInteger numberOfColumnsInSection = [[columnSections objectAtIndex:columnPath.section] numberOfCells];
    
    NSAssert((rowPath.row >= -1 && rowPath.row <= numberOfRowsInSection && columnPath.column >= -1 && columnPath.column <= numberOfColumnsInSection), @"Trying to display an out of range cell");
    
    if (rowPath.row == -1 && columnPath.column == -1) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInRowSection:forColumnSection:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInRowSection:rowPath.section forColumnSection:columnPath.section];
    } else if (rowPath.row == numberOfRowsInSection && columnPath.column == numberOfColumnsInSection) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forFooterInRowSection:forColumnSection:)])
            [self.delegate spreadView:self willDisplayCell:cell forFooterInRowSection:rowPath.section forColumnSection:columnPath.section];
    } else if (rowPath.row == -1 && columnPath.column == numberOfColumnsInSection) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInRowSection:forColumnFooterSection:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInRowSection:rowPath.section forColumnFooterSection:columnPath.section];
    } else if (rowPath.row == numberOfRowsInSection && columnPath.column == -1) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInColumnSection:forRowFooterSection:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInColumnSection:columnPath.section forRowFooterSection:rowPath.section];
    } else if (rowPath.row == -1) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInRowSection:forColumnAtIndexPath:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInRowSection:rowPath.section forColumnAtIndexPath:columnPath];
    } else if (rowPath.row == numberOfRowsInSection) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forFooterInRowSection:forColumnAtIndexPath:)])
            [self.delegate spreadView:self willDisplayCell:cell forFooterInRowSection:rowPath.section forColumnAtIndexPath:columnPath];
    } else if (columnPath.column == -1) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forHeaderInColumnSection:forRowAtIndexPath:)])
            [self.delegate spreadView:self willDisplayCell:cell forHeaderInColumnSection:columnPath.section forRowAtIndexPath:rowPath];
    } else if (columnPath.column == numberOfColumnsInSection) {
        if ([self.delegate respondsToSelector:@selector(spreadView:willDisplayCell:forFooterInColumnSection:forRowAtIndexPath:)])
            [self.delegate spreadView:self willDisplayCell:cell forFooterInColumnSection:columnPath.section forRowAtIndexPath:rowPath];
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
            cell = [(MDSpreadViewHeaderCell *)[_defaultHeaderCornerCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                                                  reuseIdentifier:cellIdentifier];
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

- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection
{
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnFooterSection:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:rowSection forColumnFooterSection:columnSection];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultHeaderRowFooterCornerCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [(MDSpreadViewHeaderCell *)[_defaultHeaderRowFooterCornerCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                                                           reuseIdentifier:cellIdentifier];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInRowSection:forColumnFooterSection:)])
            cell.objectValue = [_dataSource spreadView:self titleForHeaderInRowSection:rowSection forColumnFooterSection:columnSection];
        
        returnValue = cell;
    }
    
    NSInteger numberOfColumnsInSection = [[columnSections objectAtIndex:columnSection] numberOfCells];
	
    returnValue.spreadView = self;
	returnValue._rowPath = [MDIndexPath indexPathForRow:-1 inSection:rowSection];
    returnValue._columnPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:columnSection];
    
    [returnValue setNeedsLayout];
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection
{
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInColumnSection:forRowFooterSection:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInColumnSection:columnSection forRowFooterSection:rowSection];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultColumnFooterCornerCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [(MDSpreadViewHeaderCell *)[_defaultHeaderColumnFooterCornerCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                                                              reuseIdentifier:cellIdentifier];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForHeaderInColumnSection:forRowFooterSection:)])
            cell.objectValue = [_dataSource spreadView:self titleForHeaderInColumnSection:columnSection forRowFooterSection:rowSection];
        
        returnValue = cell;
    }
    
    NSInteger numberOfRowsInSection = [[rowSections objectAtIndex:rowSection] numberOfCells];
	
    returnValue.spreadView = self;
	returnValue._rowPath = [MDIndexPath indexPathForRow:numberOfRowsInSection inSection:rowSection];
    returnValue._columnPath = [MDIndexPath indexPathForColumn:-1 inSection:columnSection];
    
    [returnValue setNeedsLayout];
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForFooterInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForFooterInRowSection:forColumnSection:)])
        returnValue = [_dataSource spreadView:self cellForFooterInRowSection:rowSection forColumnSection:columnSection];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultFooterCornerCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [(MDSpreadViewHeaderCell *)[_defaultFooterCornerCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleCorner
                                                                                  reuseIdentifier:cellIdentifier];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForFooterInRowSection:forColumnSection:)])
            cell.objectValue = [_dataSource spreadView:self titleForFooterInRowSection:rowSection forColumnSection:columnSection];
        
        returnValue = cell;
    }
    
    NSInteger numberOfRowsInSection = [[rowSections objectAtIndex:rowSection] numberOfCells];
    NSInteger numberOfColumnsInSection = [[columnSections objectAtIndex:columnSection] numberOfCells];
	
    returnValue.spreadView = self;
	returnValue._rowPath = [MDIndexPath indexPathForRow:numberOfRowsInSection inSection:rowSection];
    returnValue._columnPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:columnSection];
    
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
            cell = [(MDSpreadViewHeaderCell *)[_defaultHeaderColumnCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleColumn
                                                                                  reuseIdentifier:cellIdentifier];
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

- (MDSpreadViewCell *)_cellForFooterInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath
{
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForFooterInColumnSection:forRowAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForFooterInColumnSection:section forRowAtIndexPath:rowPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultFooterColumnCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [(MDSpreadViewHeaderCell *)[_defaultFooterColumnCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleColumn
                                                                                  reuseIdentifier:cellIdentifier];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForFooterInColumnSection:forRowAtIndexPath:)])
            cell.objectValue = [_dataSource spreadView:self titleForFooterInColumnSection:section forRowAtIndexPath:rowPath];
        
        returnValue = cell;
    }
    
    NSInteger numberOfColumnsInSection = [[columnSections objectAtIndex:section] numberOfCells];
	
    returnValue.spreadView = self;
	returnValue._rowPath = rowPath;
    returnValue._columnPath = [MDIndexPath indexPathForColumn:numberOfColumnsInSection inSection:section];
    
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
            cell = [(MDSpreadViewHeaderCell *)[_defaultHeaderRowCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleRow
                                                                               reuseIdentifier:cellIdentifier];
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

- (MDSpreadViewCell *)_cellForFooterInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForFooterInRowSection:forColumnAtIndexPath:)])
        returnValue = [_dataSource spreadView:self cellForFooterInRowSection:section forColumnAtIndexPath:columnPath];
    
    if (!returnValue) {
        static NSString *cellIdentifier = @"_kMDDefaultFooterRowCell";
        
        MDSpreadViewCell *cell = (MDSpreadViewCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [(MDSpreadViewHeaderCell *)[_defaultFooterRowCellClass alloc] initWithStyle:MDSpreadViewHeaderCellStyleRow
                                                                               reuseIdentifier:cellIdentifier];
        }
        
        if ([_dataSource respondsToSelector:@selector(spreadView:titleForFooterInRowSection:forColumnAtIndexPath:)])
            cell.objectValue = [_dataSource spreadView:self titleForFooterInRowSection:section forColumnAtIndexPath:columnPath];
        
        returnValue = cell;
    }
    
    NSInteger numberOfRowsInSection = [[rowSections objectAtIndex:section] numberOfCells];
	
    returnValue.spreadView = self;
	returnValue._rowPath = [MDIndexPath indexPathForRow:numberOfRowsInSection inSection:section];
    returnValue._columnPath = columnPath;
    
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
            cell = [(MDSpreadViewCell *)[_defaultCellClass alloc] initWithStyle:MDSpreadViewCellStyleDefault
                                                                reuseIdentifier:cellIdentifier];
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
    MDSpreadViewSelectionMode resolvedSelectionMode = MDSpreadViewSelectionModeAutomatic;
    
    BOOL override = NO;
    MDSortDescriptor *sortDescriptorPrototype = nil;
    if (_autoAllowSortableHeaderSelection) {
        sortDescriptorPrototype = [self _sortDescriptorForRowIndexPath:nil columnIndexPath:nil cell:cell prototype:nil];
        if (sortDescriptorPrototype) {
            override = YES;
            
            resolvedSelectionMode = MDSpreadViewSelectionModeCell + sortDescriptorPrototype.sortAxis;
        }
    }
    
    if (!allowsSelection && !override) return NO;
    
    MDIndexPath *rowPath = cell._rowPath;
    MDIndexPath *columnPath = cell._columnPath;
    NSInteger row = rowPath.row;
    NSInteger rowSection = rowPath.section;
    NSInteger column = columnPath.column;
    NSInteger columnSection = columnPath.section;
    NSUInteger rowSectionCount = [(MDSpreadViewSection *)[rowSections objectAtIndex:rowSection] numberOfCells];
    NSUInteger columnSectionCount = [(MDSpreadViewSection *)[columnSections objectAtIndex:columnSection] numberOfCells];
    
    if ((row == -1 && column == -1) ||
        (row == rowSectionCount && column == columnSectionCount) ||
        (row == -1 && column == columnSectionCount) ||
        (row == rowSectionCount && column == -1)) { // corner header
        
        if (!_allowsCornerHeaderSelection && !override) {
            return NO;
        }
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _cornerHeaderHighlightMode;
        }
    } else if (row == -1 || row == rowSectionCount) { // header row
        
        if (!_allowsColumnHeaderSelection && !override) {
            return NO;
        }
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _columnHeaderHighlightMode;
        }
    } else if (column == -1 || column == columnSectionCount) { // header column
        
        if (!_allowsRowHeaderSelection && !override) {
            return NO;
        }
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _rowHeaderHighlightMode;
        }
    }
    
    if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
        resolvedSelectionMode = _highlightMode;
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = MDSpreadViewSelectionModeNone;
        }
    }
    
    MDSpreadViewSelection *selection = [MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:resolvedSelectionMode];
    self._currentSelection = [self _willHighlightCellWithSelection:selection];
    
    if (self._currentSelection) {
        [self _setSelection:self._currentSelection highlighted:YES animated:NO];
        return YES;
    } else {
        return NO;
    }
}

- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell
{
    if (!self._currentSelection) return;
    
    [self _setSelection:self._currentSelection highlighted:NO animated:YES];
    
    MDSpreadViewSelectionMode resolvedSelectionMode = MDSpreadViewSelectionModeAutomatic;
    
    MDSortDescriptor *sortDescriptorPrototype = nil;
    if (_autoAllowSortableHeaderSelection) {
        if ([(MDSpreadViewHeaderCell *)cell respondsToSelector:@selector(sortDescriptorPrototype)] && [(MDSpreadViewHeaderCell *)cell sortDescriptorPrototype]) {
            sortDescriptorPrototype = [(MDSpreadViewHeaderCell *)cell sortDescriptorPrototype];
            
            resolvedSelectionMode = MDSpreadViewSelectionModeCell + sortDescriptorPrototype.sortAxis;
        }
    }
    
    MDIndexPath *rowPath = cell._rowPath;
    MDIndexPath *columnPath = cell._columnPath;
    NSInteger row = rowPath.row;
    NSInteger rowSection = rowPath.section;
    NSInteger column = columnPath.column;
    NSInteger columnSection = columnPath.section;
    NSUInteger rowSectionCount = [(MDSpreadViewSection *)[rowSections objectAtIndex:rowSection] numberOfCells];
    NSUInteger columnSectionCount = [(MDSpreadViewSection *)[columnSections objectAtIndex:columnSection] numberOfCells];
    
    if ((row == -1 && column == -1) ||
        (row == rowSectionCount && column == columnSectionCount) ||
        (row == -1 && column == columnSectionCount) ||
        (row == rowSectionCount && column == -1)) { // corner header
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _cornerHeaderHighlightMode;
        }
    } else if (row == -1 || row == rowSectionCount) { // header row
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _columnHeaderHighlightMode;
        }
    } else if (column == -1 || column == columnSectionCount) { // header column
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _rowHeaderHighlightMode;
        }
    }
    
    if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
        resolvedSelectionMode = _highlightMode;
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = MDSpreadViewSelectionModeNone;
        }
    }
    
    MDSpreadViewSelection *selection = [MDSpreadViewSelection selectionWithRow:self._currentSelection.rowPath
                                                                        column:self._currentSelection.columnPath
                                                                          mode:resolvedSelectionMode];
    
    MDSpreadViewSelection *newSelection = [self _willSelectCellForSelection:selection];
    if (selection != newSelection) {
        cell = nil; // FIXME: Fetch actual cell in this case
    }
    
    [self _didUnhighlightCellForRowAtIndexPath:self._currentSelection.rowPath forColumnIndex:self._currentSelection.columnPath];
    
    MDSortDescriptor *sortDescriptor = [self _sortDescriptorForRowIndexPath:newSelection.rowPath columnIndexPath:newSelection.columnPath cell:cell prototype:nil];
    _currentSortDescriptor = sortDescriptor;
    
    if (newSelection) {
        [self _addSelection:newSelection animated:YES notify:YES];
        [self _didSelectCellForRowAtIndexPath:self._currentSelection.rowPath forColumnIndex:self._currentSelection.columnPath];
    }
    self._currentSelection = nil;
    
    [self _addSortDescriptor:sortDescriptor];
}

- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell
{
    if (!self._currentSelection) return;
    
    [self _setSelection:self._currentSelection highlighted:NO animated:NO];
    [self _didUnhighlightCellForRowAtIndexPath:self._currentSelection.rowPath forColumnIndex:self._currentSelection.columnPath];
    
    self._currentSelection = nil;
}

- (void)_addSelection:(MDSpreadViewSelection *)selection animated:(BOOL)animated notify:(BOOL)notify
{
    NSUInteger index = [_selectedCells indexOfObject:selection];
    while (index != NSNotFound) {
        [_selectedCells removeObjectAtIndex:index];
        index = [_selectedCells indexOfObject:selection];
    }
    
    [_selectedCells addObject:selection];
    
    if (!allowsMultipleSelection) {
        NSMutableArray *bucket = [[NSMutableArray alloc] initWithCapacity:_selectedCells.count];
        
        for (MDSpreadViewSelection *oldSelection in _selectedCells) {
            if (![oldSelection isEqual:selection]) {
                [bucket addObject:oldSelection];
            }
        }
        
        MDSortDescriptor *firstDescriptor = (_currentSortDescriptor) ? _currentSortDescriptor : _sortDescriptors.firstObject;
        if (_preservesSortSelections && firstDescriptor) {
            MDSpreadViewSelection *sortSelection = nil;
            
            for (MDSpreadViewSelection *oldSelection in bucket) {
                if ([oldSelection.rowPath isEqualToIndexPath:firstDescriptor.rowIndexPath] && [oldSelection.columnPath isEqualToIndexPath:firstDescriptor.columnIndexPath]) {
                    sortSelection = oldSelection;
                    break;
                }
            }
            
            if (sortSelection) [bucket removeObject:sortSelection];
        }
        
        [self _removeSelections:bucket animated:YES notify:YES];
        return;
    }
    
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:mapForContent.allCells];
    [allVisibleCells addObjectsFromArray:mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForCornerHeaders.allCells];
    
    BOOL shouldSelect = NO;
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        shouldSelect = NO;
        for (MDSpreadViewSelection *selection in _selectedCells) {
            if (selection.selectionMode == MDSpreadViewSelectionModeNone || selection.selectionMode == MDSpreadViewSelectionModeAutomatic) continue;
            
            if ([cell._rowPath isEqualToIndexPath:selection.rowPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
            }
            
            if ([cell._columnPath isEqualToIndexPath:selection.columnPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
                
                if ([cell._rowPath isEqualToIndexPath:selection.rowPath] && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                    shouldSelect = YES;
                }
            }
        }
        [cell setSelected:shouldSelect animated:animated];
    }
}

- (void)_removeSelection:(MDSpreadViewSelection *)selection animated:(BOOL)animated notify:(BOOL)notify
{
    if (selection) [self _removeSelections:@[selection] animated:animated notify:notify];
}

- (void)_removeSelections:(NSArray *)selections animated:(BOOL)animated notify:(BOOL)notify
{
    NSMutableSet *deselectedSet = [NSMutableSet setWithArray:_selectedCells];
    [deselectedSet intersectSet:[NSSet setWithArray:selections]];
    
    [_selectedCells removeObjectsInArray:selections];
    
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:mapForContent.allCells];
    [allVisibleCells addObjectsFromArray:mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForCornerHeaders.allCells];
    
    BOOL shouldSelect = NO;
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        shouldSelect = NO;
        for (MDSpreadViewSelection *selection in _selectedCells) {
            if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
            
            if ([cell._rowPath isEqualToIndexPath:selection.rowPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
            }
            
            if ([cell._columnPath isEqualToIndexPath:selection.columnPath]) {
                if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
                
                if ([cell._rowPath isEqualToIndexPath:selection.rowPath] && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                    shouldSelect = YES;
                }
            }
        }
        [cell setSelected:shouldSelect animated:animated];
    }
    
    if (notify) for (MDSpreadViewSelection *selection in deselectedSet) {
        [self _didDeselectCellForRowAtIndexPath:selection.rowPath forColumnIndex:selection.columnPath];
    }
}

- (void)_setSelection:(MDSpreadViewSelection *)selection highlighted:(BOOL)highlighted animated:(BOOL)animated
{
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:mapForContent.allCells];
    [allVisibleCells addObjectsFromArray:mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForCornerHeaders.allCells];
    
    BOOL shouldHighlight = NO;
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        shouldHighlight = NO;
        
        if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
        
        if ([cell._rowPath isEqualToIndexPath:selection.rowPath]) {
            if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldHighlight = YES;
            }
        }
        
        if ([cell._columnPath isEqualToIndexPath:selection.columnPath]) {
            if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldHighlight = YES;
            }
            
            if ([cell._rowPath isEqualToIndexPath:selection.rowPath] && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                shouldHighlight = YES;
            }
        }
    
        [cell setHighlighted:(shouldHighlight && highlighted) animated:animated];
    }
}

- (void)selectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSelectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition
{
    [self _addSelection:[MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:mode] animated:animated notify:NO];
    
//    if (mode != MDSpreadViewScrollPositionNone) {
//        [self scrollToCell...];
//    }
}

- (void)deselectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath animated:(BOOL)animated
{
    [self _removeSelection:[MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:MDSpreadViewSelectionModeNone] animated:animated notify:NO];
}

- (MDSpreadViewSelection *)_willHighlightCellWithSelection:(MDSpreadViewSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(spreadView:willHighlightCellWithSelection:)])
        selection = [self.delegate spreadView:self willHighlightCellWithSelection:selection];
    
    return selection;
}

- (void)_didHighlightCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
	if ([self.delegate respondsToSelector:@selector(spreadView:didHighlightCellForRowAtIndexPath:forColumnAtIndexPath:)])
		[self.delegate spreadView:self didHighlightCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}

- (MDSpreadViewSelection *)_willSelectCellForSelection:(MDSpreadViewSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(spreadView:willSelectCellWithSelection:)])
        selection = [self.delegate spreadView:self willSelectCellWithSelection:selection];
    
    return selection;
}

- (void)_didUnhighlightCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
	if ([self.delegate respondsToSelector:@selector(spreadView:didUnhighlightCellForRowAtIndexPath:forColumnAtIndexPath:)])
		[self.delegate spreadView:self didUnhighlightCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}

- (void)_didSelectCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
	if ([self.delegate respondsToSelector:@selector(spreadView:didSelectCellForRowAtIndexPath:forColumnAtIndexPath:)])
		[self.delegate spreadView:self didSelectCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}

- (MDSpreadViewSelection *)_willDeselectCellWithSelection:(MDSpreadViewSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(spreadView:willDeselectCellWithSelection:)])
        selection = [self.delegate spreadView:self willDeselectCellWithSelection:selection];
    
    return selection;
}

- (void)_didDeselectCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
	if ([self.delegate respondsToSelector:@selector(spreadView:didDeselectCellForRowAtIndexPath:forColumnAtIndexPath:)])
		[self.delegate spreadView:self didDeselectCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}

#pragma mark - Sorting

- (void)sortCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath withPrototypeSortDescriptor:(MDSortDescriptor *)prototypeSortDescriptor selectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition
{
    MDSortDescriptor *sortDescriptor = [self _sortDescriptorForRowIndexPath:rowPath columnIndexPath:columnPath cell:nil prototype:prototypeSortDescriptor];
    _currentSortDescriptor = sortDescriptor;
    
    [self _addSelection:[MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:mode] animated:animated notify:NO];
    
    [self _addSortDescriptor:sortDescriptor];
}

- (MDSortDescriptor *)_sortDescriptorForRowIndexPath:(MDIndexPath *)rowIndexPath columnIndexPath:(MDIndexPath *)columnIndexPath cell:(MDSpreadViewCell *)cell prototype:(MDSortDescriptor *)prototype
{
    MDSortDescriptor *sortDescriptor = nil;
    
    if (cell) rowIndexPath = cell._rowPath;
    if (cell) columnIndexPath = cell._columnPath;
    NSInteger row = rowIndexPath.row;
    NSInteger rowSection = rowIndexPath.section;
    NSInteger column = columnIndexPath.column;
    NSInteger columnSection = columnIndexPath.section;
    NSUInteger rowSectionCount = [self numberOfRowsInRowSection:rowSection];
    NSUInteger columnSectionCount = [self numberOfColumnsInColumnSection:columnSection];
    
    MDSpreadViewSortAxis sortAxis = MDSpreadViewSortNone;
    
    if (row == -1 && column == -1) { // corner header
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForHeaderInRowSection:forColumnSection:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForHeaderInRowSection:rowSection forColumnSection:columnSection];
            sortAxis = MDSpreadViewSortBoth;
        }
    } else if (row == rowSectionCount && column == columnSectionCount) { // corner footer
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForFooterInRowSection:forColumnSection:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForFooterInRowSection:rowSection forColumnSection:columnSection];
            sortAxis = MDSpreadViewSortBoth;
        }
    } else if (row == -1 && column == columnSectionCount) { // header row footer column
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForHeaderInRowSection:forColumnFooterSection:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForHeaderInRowSection:rowSection forColumnFooterSection:columnSection];
            sortAxis = MDSpreadViewSortBoth;
        }
    } else if (row == rowSectionCount && column == -1) { // header column footer row
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForHeaderInColumnSection:forRowFooterSection:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForHeaderInColumnSection:columnSection forRowFooterSection:rowSection];
            sortAxis = MDSpreadViewSortBoth;
        }
    } else if (row == -1) { // header row
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForHeaderInRowSection:forColumnAtIndexPath:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForHeaderInRowSection:rowSection forColumnAtIndexPath:columnIndexPath];
            sortAxis = MDSpreadViewSortRows;
        }
    } else if (row == rowSectionCount) { // footer row
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForFooterInRowSection:forColumnAtIndexPath:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForFooterInRowSection:rowSection forColumnAtIndexPath:columnIndexPath];
            sortAxis = MDSpreadViewSortRows;
        }
    } else if (column == -1) { // header column
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForHeaderInColumnSection:forRowAtIndexPath:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForHeaderInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
            sortAxis = MDSpreadViewSortColumns;
        }
    } else if (column == columnSectionCount) { // footer column
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorPrototypeForFooterInColumnSection:forRowAtIndexPath:)]) {
            sortDescriptor = [self.dataSource spreadView:self sortDescriptorPrototypeForFooterInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
            sortAxis = MDSpreadViewSortColumns;
        }
    }
    
    if (!sortDescriptor && cell) {
        sortDescriptor = cell.sortDescriptorPrototype;
        if (cell.defaultSortAxis != MDSpreadViewSortNone) {
            sortAxis = cell.defaultSortAxis;
        }
    } else if (!sortDescriptor && prototype) {
        sortDescriptor = prototype;
    }
    
    if (sortDescriptor.rowSection != MDSpreadViewSelectWholeSpreadView) {
        sortDescriptor.rowSection = rowSection;
    }
    
    if (sortDescriptor.columnSection != MDSpreadViewSelectWholeSpreadView) {
        sortDescriptor.columnSection = columnSection;
    }
    
    sortDescriptor.sortAxis = sortAxis;
    
    sortDescriptor.rowIndexPath = rowIndexPath;
    sortDescriptor.columnIndexPath = columnIndexPath;
    
    return sortDescriptor;
}

- (void)_addSortDescriptor:(MDSortDescriptor *)sortDescriptor
{
    if (!sortDescriptor) return;
    
    NSArray *oldDescriptors = self.sortDescriptors;
    
    NSMutableArray *matchingSortDescryptors = [[NSMutableArray alloc] init];
    
    for (MDSortDescriptor *descriptor in _sortDescriptors) {
        if ([descriptor.key isEqualToString:sortDescriptor.key]) {
            [matchingSortDescryptors addObject:descriptor];
        }
    }
    
    if (matchingSortDescryptors.count) {
        MDSortDescriptor *firstDescriptor = matchingSortDescryptors.firstObject;
        
        if ([_sortDescriptors indexOfObject:firstDescriptor] == 0 && firstDescriptor.ascending == sortDescriptor.ascending) {
            sortDescriptor = [sortDescriptor reversedSortDescriptor];
        } else if ([_sortDescriptors indexOfObject:firstDescriptor] != 0 && firstDescriptor.ascending != sortDescriptor.ascending) {
            sortDescriptor = [sortDescriptor reversedSortDescriptor];
        }
    }
    
    [_sortDescriptors removeObjectsInArray:matchingSortDescryptors];
    [_sortDescriptors insertObject:sortDescriptor atIndex:0];
    _currentSortDescriptor = nil;
    
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:mapForCornerHeaders.allCells];
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        MDSpreadViewCellSortIndicator sortIndicator = MDSpreadViewCellSortIndicatorNone;
        MDSortDescriptor *cellSortDescriptorPrototype = [self _sortDescriptorForRowIndexPath:nil columnIndexPath:nil cell:cell prototype:nil];
        
        if ([cellSortDescriptorPrototype.key isEqualToString:sortDescriptor.key]) {
            if ([sortDescriptor ascending]) {
                sortIndicator = MDSpreadViewCellSortIndicatorAscending;
            } else {
                sortIndicator = MDSpreadViewCellSortIndicatorDescending;
            }
        }
        
        [cell _setSortIndicator:sortIndicator sortAxis:sortDescriptor.sortAxis];
    }
    
    if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorsDidChange:)]) {
        [self.dataSource spreadView:self sortDescriptorsDidChange:oldDescriptors];
    }
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors
{
    if (_sortDescriptors != sortDescriptors) {
        NSArray *oldDescriptors = _sortDescriptors;
        _sortDescriptors = [sortDescriptors mutableCopy];
        
        if ([self.dataSource respondsToSelector:@selector(spreadView:sortDescriptorsDidChange:)]) {
            [self.dataSource spreadView:self sortDescriptorsDidChange:oldDescriptors];
        }
    }
}

- (NSArray *)sortDescriptors
{
    return [_sortDescriptors copy];
}

@end
