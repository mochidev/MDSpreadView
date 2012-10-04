//
//  MDSpreadView.h
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

#import <UIKit/UIKit.h>
#import "MDSpreadViewCell.h"

typedef enum {
    MDSpreadViewScrollPositionNone,
    MDSpreadViewScrollPositionTopLeft,
    MDSpreadViewScrollPositionTopMiddle,
    MDSpreadViewScrollPositionTopRight,
    MDSpreadViewScrollPositionCenterLeft,
    MDSpreadViewScrollPositionCenterMiddle,
    MDSpreadViewScrollPositionCenterRight,
    MDSpreadViewScrollPositionBottomLeft,
    MDSpreadViewScrollPositionBottomMiddle,
    MDSpreadViewScrollPositionBottomRight
} MDSpreadViewScrollPosition;

typedef enum {
    MDSpreadViewSelectionModeNone,
    MDSpreadViewSelectionModeCell,        
    MDSpreadViewSelectionModeRow,    
    MDSpreadViewSelectionModeColumn,   
    MDSpreadViewSelectionModeRowAndColumn
} MDSpreadViewSelectionMode;

typedef enum {
    MDSpreadViewCellDomainHeaders = -1,
    MDSpreadViewCellDomainCells = 0,
    MDSpreadViewCellDomainFooters = 1
} MDSpreadViewCellDomain;

typedef enum {
    MDSpreadViewCellResizingNone,
    MDSpreadViewCellResizingUniform,
    MDSpreadViewCellResizingCellsOnly,
    MDSpreadViewCellResizingHeadersOnly,
    MDSpreadViewCellResizingFootersOnly,
    MDSpreadViewCellResizingFirstHeader,
    MDSpreadViewCellResizingLastFooter,
    MDSpreadViewCellResizingFirstCell,
    MDSpreadViewCellResizingLastCell
} MDSpreadViewCellResizing;

@class MDSpreadView;
@protocol MDSpreadViewDataSource;
@class MDSpreadViewCell;
@class MDIndexPath;
@class MDSpreadViewSelection;

#pragma mark - MDSpreadViewDelegate

@protocol MDSpreadViewDelegate<NSObject, UIScrollViewDelegate>

@optional

// Display customization

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

// Variable height support

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(MDIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection; // pass 0 to hide header

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(MDIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection; // pass 0 to hide header

// Accessories (disclosures). 

- (void)spreadView:(MDSpreadView *)aSpreadView accessoryButtonTappedForRowWithIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath __attribute__((unavailable));

// Selection

// Called before the user changes the selection. Return an array, or nil, to change the proposed selection.
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willSelectCellForSelection:(MDSpreadViewSelection *)selection;
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willDeselectCellForSelection:(MDSpreadViewSelection *)selection __attribute__((unavailable));

// Called after the user changes the selection.
- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView didDeselectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath __attribute__((unavailable));

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)spreadView:(MDSpreadView *)aSpreadView shouldShowMenuForRowAtIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath __attribute__((unavailable));
- (BOOL)spreadView:(MDSpreadView *)aSpreadView canPerformAction:(SEL)action forRowAtIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSender:(id)sender __attribute__((unavailable));
- (void)spreadView:(MDSpreadView *)aSpreadView performAction:(SEL)action forRowAtIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSender:(id)sender __attribute__((unavailable));

@end

extern NSString *MDSpreadViewSelectionDidChangeNotification __attribute__((unavailable));

#pragma mark - MDSpreadView

@interface MDSpreadView : UIScrollView {
  @private
    id <MDSpreadViewDataSource> _dataSource;
    
    CGFloat rowHeight;
    CGFloat sectionRowHeaderHeight;
    CGFloat columnWidth;
    CGFloat sectionColumnHeaderWidth;
    
    NSMutableSet *_dequeuedCells;
    
    NSMutableArray *visibleCells; // array of array
    MDIndexPath *_visibleRowIndexPath;
    MDIndexPath *_visibleColumnIndexPath;
    CGRect visibleBounds;
    
    NSMutableArray *_headerRowCells;
    NSMutableArray *_headerColumnCells;
    MDSpreadViewCell *_headerCornerCell;
    CGRect _headerBounds;
    
    MDIndexPath *_headerRowIndexPath;
    MDIndexPath *_headerColumnIndexPath;
    
    NSMutableArray *_rowSections;
    NSMutableArray *_columnSections;
    
    UIView *anchorCell;
    UIView *anchorRowHeaderCell;
    UIView *anchorColumnHeaderCell;
    UIView *anchorCornerHeaderCell;
    
    BOOL implementsRowHeight;
    BOOL implementsRowHeaderHeight;
    BOOL implementsColumnWidth;
    BOOL implementsColumnHeaderWidth;
    
    NSMutableArray *_selectedCells;
    MDSpreadViewSelection *_currentSelection;
    
    MDSpreadViewSelectionMode selectionMode;
    NSMutableArray *sortDescriptors;
    
    Class _defaultHeaderCornerCellClass;
    Class _defaultHeaderColumnCellClass;
    Class _defaultHeaderRowCellClass;
    Class _defaultCellClass;
    
    BOOL _didSetReloadData;
    
    BOOL allowsSelection;
    BOOL allowsMultipleSelection;
    
    MDSpreadViewCellResizing columnResizing;
    MDSpreadViewCellResizing rowResizing;
}

@property (nonatomic, assign) IBOutlet id <MDSpreadViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id <MDSpreadViewDelegate> delegate;

// Cell Dimensions
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat sectionRowHeaderHeight;
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic) CGFloat sectionColumnHeaderWidth;

// default cell setters. must be subclasses of MDSpreadViewCell;
@property (nonatomic) Class defaultHeaderCornerCellClass;
@property (nonatomic) Class defaultHeaderColumnCellClass;
@property (nonatomic) Class defaultHeaderRowCellClass;
@property (nonatomic) Class defaultCellClass;

@property (nonatomic) MDSpreadViewCellResizing columnResizing __attribute__((unavailable));
@property (nonatomic) MDSpreadViewCellResizing rowResizing __attribute__((unavailable));

@property (nonatomic, readwrite, retain) UIView *backgroundView __attribute__((unavailable)); // the background view will be automatically resized to track the size of the table view.  this will be placed as a subview of the table view behind all cells and headers/footers.  default may be non-nil for some devices.

// Data

- (void)reloadData;
// reloads everything from scratch. redisplays visible rows. because we only keep info about visible rows, this is cheap. will adjust offset if table shrinks

// Info

- (NSInteger)numberOfRowSections;
- (NSInteger)numberOfRowsInRowSection:(NSInteger)section;
- (NSInteger)numberOfColumnSections;
- (NSInteger)numberOfColumnsInColumnSection:(NSInteger)section;

- (CGRect)rectForRowSection:(NSInteger)rowSection columnSection:(NSInteger)columnSection;
// includes header, footer and all rows
//- (CGRect)rectForHeaderInSection:(NSInteger)section;
//- (CGRect)rectForFooterInSection:(NSInteger)section;
//- (CGRect)rectForRowAtIndexPath:(MDIndexPath *)indexPath;
- (CGRect)cellRectForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

//- (MDIndexPath *)indexPathForRowAtPoint:(CGPoint)point;                         // returns nil if point is outside table
//- (MDIndexPath *)indexPathForCell:(UITableViewCell *)cell;                      // returns nil if cell is not visible
//- (NSArray *)indexPathsForRowsInRect:(CGRect)rect;                              // returns nil if rect not valid 

//- (UITableViewCell *)cellForRowAtIndexPath:(MDIndexPath *)indexPath;            // returns nil if cell is not visible or index path is out of range
//- (NSArray *)visibleCells;
//- (NSArray *)indexPathsForVisibleRows;

//- (void)scrollToRowAtIndexPath:(MDIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
//- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

// Selection

@property (nonatomic) MDSpreadViewSelectionMode selectionMode;
// the default selection mode. defaults to MDSpreadViewSelectionModeNone
@property (nonatomic) BOOL allowsSelection;
// default is YES. Controls whether rows can be selected when not in editing mode
@property (nonatomic) BOOL allowsMultipleSelection;
// default is NO. Controls whether multiple rows can be selected simultaneously

- (MDIndexPath *)rowIndexPathForSelectedCell __attribute__((unavailable));
// returns nil or index path representing section and row of selection.
- (NSArray *)rowIndexPathsForSelectedCells __attribute__((unavailable));
// returns nil or a set of index paths representing the sections and rows of the selection.
- (MDIndexPath *)columnIndexPathForSelectedCell __attribute__((unavailable));
// returns nil or index path representing section and row of selection.
- (NSArray *)columnIndexPathsForSelectedCells __attribute__((unavailable));
// returns nil or a set of index paths representing the sections and rows of the selection.

- (void)selectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSelectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition;
// scroll position only works with MDSpreadViewScrollPositionNone for now
- (void)deselectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath animated:(BOOL)animated;

// Appearance

@property (nonatomic) MDSpreadViewCellSeparatorStyle separatorStyle __attribute__((unavailable));
// default is MDSpreadViewCellSeparatorStyleCorner
@property (nonatomic, retain) UIColor *separatorColor __attribute__((unavailable));
// default is the standard separator gray

- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
// Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.

// Sorting

@property (nonatomic, copy) NSArray *sortDescriptors;
// Calling -setSortDescriptors: may have the side effect of calling -spreadView:sortDescriptorsDidChange: on the -dataSource/

@end

#pragma mark - MDSpreadViewDataSource

@protocol MDSpreadViewDataSource<NSObject>

@required

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section;
- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section;

@optional

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

- (NSInteger)numberOfColumnSectionsInSpreadView:(MDSpreadView *)aSpreadView;
// Default is 1 if not implemented
- (NSInteger)numberOfRowSectionsInSpreadView:(MDSpreadView *)aSpreadView;
// Default is 1 if not implemented

// shorthands for fast cell generation
// not called if cells are manually geneated
// renerally, return an NSString, but just about anything that returns description can be used,
// or can also be something that a custom cell defines
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;
- (id)spreadView:(MDSpreadView *)aSpreadView objectValueForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

// manual cell generation. returning nil creates one for you
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

- (void)spreadView:(MDSpreadView *)aSpreadView sortDescriptorsDidChange:(NSArray *)oldDescriptors;
// This is the indication that sorting needs to be done.  Typically the data source will sort its data, reload, and adjust selections.

@end

@interface MDIndexPath : NSObject {
    NSInteger section;
    NSInteger row;
}

+ (MDIndexPath *)indexPathForColumn:(NSInteger)column inSection:(NSInteger)section;
+ (MDIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@property (nonatomic,readonly) NSInteger section;
@property (nonatomic,readonly) NSInteger row;
@property (nonatomic,readonly) NSInteger column;

- (BOOL)isEqualToIndexPath:(MDIndexPath *)object;

@end

enum {MDSpreadViewSelectWholeSpreadView = -1};

@interface MDSortDescriptor : NSSortDescriptor {
    MDIndexPath *indexPath;
    NSInteger section;
    MDSpreadViewSortAxis sortAxis;
}

@property (nonatomic, readonly, retain) MDIndexPath *indexPath;
// index path for sort header
@property (nonatomic, readonly) NSInteger section;
// the section to sort, or MDSpreadViewSelectWholeSpreadView to sort the whole spread view
@property (nonatomic, readonly) MDSpreadViewSortAxis sortAxis;
// which direction this sort applies to.

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selectsWholeSpreadView:(BOOL)wholeView;
+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector selectsWholeSpreadView:(BOOL)wholeView;
+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)cmptr selectsWholeSpreadView:(BOOL)wholeView;

// keys may be key paths
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selectsWholeSpreadView:(BOOL)wholeView;
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector selectsWholeSpreadView:(BOOL)wholeView;
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)cmptr selectsWholeSpreadView:(BOOL)wholeView;

@end

@interface MDSpreadViewSelection : NSObject {
    MDIndexPath *rowPath;
    MDIndexPath *columnPath;
    MDSpreadViewSelectionMode selectionMode;
}

@property (nonatomic, retain, readonly) MDIndexPath *rowPath;
@property (nonatomic, retain, readonly) MDIndexPath *columnPath;
@property (nonatomic, readonly) MDSpreadViewSelectionMode selectionMode;

+ (id)selectionWithRow:(MDIndexPath *)row column:(MDIndexPath *)column mode:(MDSpreadViewSelectionMode)mode;

@end

