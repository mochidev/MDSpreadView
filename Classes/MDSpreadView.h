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

typedef NS_ENUM(NSUInteger, MDSpreadViewScrollPosition) {
    MDSpreadViewScrollPositionNone,
    MDSpreadViewScrollPositionAutomatic,
    MDSpreadViewScrollPositionTopLeft,
    MDSpreadViewScrollPositionTopMiddle,
    MDSpreadViewScrollPositionTopRight,
    MDSpreadViewScrollPositionCenterLeft,
    MDSpreadViewScrollPositionCenterMiddle,
    MDSpreadViewScrollPositionCenterRight,
    MDSpreadViewScrollPositionBottomLeft,
    MDSpreadViewScrollPositionBottomMiddle,
    MDSpreadViewScrollPositionBottomRight
};

typedef NS_ENUM(NSUInteger, MDSpreadViewSelectionMode) {
    MDSpreadViewSelectionModeNone,
    MDSpreadViewSelectionModeAutomatic,
    MDSpreadViewSelectionModeCell,
    MDSpreadViewSelectionModeRow,
    MDSpreadViewSelectionModeColumn,
    MDSpreadViewSelectionModeRowAndColumn
};

typedef NS_ENUM(NSUInteger, MDSpreadViewSortAxis) {
    MDSpreadViewSortNone,
    MDSpreadViewSortColumns,
    MDSpreadViewSortRows,
    MDSpreadViewSortBoth
};

typedef NS_ENUM(NSInteger, MDSpreadViewCellDomain) {
    MDSpreadViewCellDomainHeaders = -1,
    MDSpreadViewCellDomainCells = 0,
    MDSpreadViewCellDomainFooters = 1
};

typedef NS_ENUM(NSUInteger, MDSpreadViewCellResizing) {
    MDSpreadViewCellResizingNone,
    MDSpreadViewCellResizingUniform,
    MDSpreadViewCellResizingCellsOnly,
    MDSpreadViewCellResizingHeadersOnly,
    MDSpreadViewCellResizingFootersOnly,
    MDSpreadViewCellResizingFirstHeader,
    MDSpreadViewCellResizingLastFooter,
    MDSpreadViewCellResizingFirstCell,
    MDSpreadViewCellResizingLastCell
};

@class MDSpreadView;
@protocol MDSpreadViewDataSource;
@class MDSpreadViewCell;
@class MDIndexPath;
@class MDSpreadViewSelection;
@class MDSpreadViewCellMap;

#pragma mark - MDSpreadViewDelegate

@protocol MDSpreadViewDelegate<NSObject, UIScrollViewDelegate>

@optional

// Display customization

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection;

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forFooterInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forFooterInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forFooterInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

// Variable height support

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(MDIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection; // pass 0 to hide header
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowFooterInSection:(NSInteger)rowSection; // pass 0 to hide footer

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(MDIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection; // pass 0 to hide header
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnFooterInSection:(NSInteger)columnSection; // pass 0 to hide header

// Accessories (disclosures). 

- (void)spreadView:(MDSpreadView *)aSpreadView accessoryButtonTappedForRowWithIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath __attribute__((unavailable));

// Selection

// Called just after the user touches down on a cell. Return a new selection, or nil, to change the proposed highlight.
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willHighlightCellWithSelection:(MDSpreadViewSelection *)selection;

// Called after the user lifts their finger.
- (void)spreadView:(MDSpreadView *)aSpreadView didHighlightCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView didUnhighlightCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

// Called before the user changes the selection. Return a new selection, or nil, to change the proposed selection.
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willSelectCellWithSelection:(MDSpreadViewSelection *)selection;
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willDeselectCellWithSelection:(MDSpreadViewSelection *)selection;

// Called after the user changes the selection.
- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView didDeselectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)spreadView:(MDSpreadView *)aSpreadView shouldShowMenuForRowAtIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath __attribute__((unavailable));
- (BOOL)spreadView:(MDSpreadView *)aSpreadView canPerformAction:(SEL)action forRowAtIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSender:(id)sender __attribute__((unavailable));
- (void)spreadView:(MDSpreadView *)aSpreadView performAction:(SEL)action forRowAtIndexPath:(MDIndexPath *)indexPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSender:(id)sender __attribute__((unavailable));

@end

extern NSString *MDSpreadViewSelectionDidChangeNotification __attribute__((unavailable));

#pragma mark - MDSpreadView

@interface MDSpreadView : UIScrollView {
  @private
    id <MDSpreadViewDataSource> __weak _dataSource;
    
    NSMutableArray *_dequeuedCells;
    
    // New algorithm
    
    MDSpreadViewCellMap *mapForContent;
    MDSpreadViewCellMap *mapForColumnHeaders;
    MDSpreadViewCellMap *mapForRowHeaders;
    MDSpreadViewCellMap *mapForCornerHeaders;
    CGRect mapBounds;
    
    MDIndexPath *minColumnIndexPath;
    MDIndexPath *maxColumnIndexPath;
    MDIndexPath *minRowIndexPath;
    MDIndexPath *maxRowIndexPath;
    
    NSMutableArray *columnSections;
    NSMutableArray *rowSections;
    
//    UIView *dummyView;
//    UIView *dummyViewB;
    
    CGSize dequeuedCellSizeHint;
    MDIndexPath *dequeuedCellRowIndexHint;
    MDIndexPath *dequeuedCellColumnIndexHint;
    
    UIImage *cachedSeparatorImage;
    
    MDSortDescriptor *_currentSortDescriptor;
    
    // Done with new algorithm
    
    NSMutableArray *_rowSections;
    NSMutableArray *_columnSections;
    
    UIView *anchorCell;
    UIView *anchorRowHeaderCell;
    UIView *anchorColumnHeaderCell;
    UIView *anchorCornerHeaderCell;
    
    BOOL implementsRowHeight;
    BOOL implementsRowHeaderHeight;
    BOOL implementsRowFooterHeight;
    BOOL implementsColumnWidth;
    BOOL implementsColumnHeaderWidth;
    BOOL implementsColumnFooterWidth;
    
    BOOL implementsRowHeaderData;
    BOOL implementsRowFooterData;
    BOOL implementsColumnHeaderData;
    BOOL implementsColumnFooterData;
    
    BOOL didSetHeaderHeight;
    BOOL didSetFooterHeight;
    BOOL didSetHeaderWidth;
    BOOL didSetFooterWidth;
    
    NSMutableArray *_selectedCells;
    MDSpreadViewSelection *_currentSelection;
    
    MDSpreadViewSelectionMode selectionMode;
    NSMutableArray *_sortDescriptors;
    
    NSTimer *reloadTimer;
    BOOL preventReload;
    
    BOOL allowsSelection;
    BOOL allowsMultipleSelection;
    
    MDSpreadViewCellResizing columnResizing;
    MDSpreadViewCellResizing rowResizing;
}

@property (nonatomic, weak) IBOutlet id <MDSpreadViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <MDSpreadViewDelegate> delegate;

// Cell Dimensions. The header and footers will report their values, but they will only be used if you
// implement a data source method for those cells. Otherwise, set them here and they will be used.
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat sectionRowHeaderHeight;
@property (nonatomic) CGFloat sectionRowFooterHeight;
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic) CGFloat sectionColumnHeaderWidth;
@property (nonatomic) CGFloat sectionColumnFooterWidth;

// default cell setters. must be subclasses of MDSpreadViewCell;
@property (nonatomic, weak) Class defaultHeaderCornerCellClass; // header column, header row
@property (nonatomic, weak) Class defaultHeaderColumnCellClass; // header column, content row
@property (nonatomic, weak) Class defaultHeaderColumnFooterCornerCellClass; // header column, footer row

@property (nonatomic, weak) Class defaultHeaderRowCellClass; // header row
@property (nonatomic, weak) Class defaultCellClass; // content row
@property (nonatomic, weak) Class defaultFooterRowCellClass; // footer row

@property (nonatomic, weak) Class defaultHeaderRowFooterCornerCellClass; // footer column, header row
@property (nonatomic, weak) Class defaultFooterColumnCellClass; // footer column, content row
@property (nonatomic, weak) Class defaultFooterCornerCellClass; // footer column, footer row

@property (nonatomic) MDSpreadViewCellResizing columnResizing __attribute__((unavailable));
@property (nonatomic) MDSpreadViewCellResizing rowResizing __attribute__((unavailable));

@property (nonatomic, readwrite, strong) UIView *backgroundView __attribute__((unavailable)); // the background view will be automatically resized to track the size of the table view.  this will be placed as a subview of the table view behind all cells and headers/footers.  default may be non-nil for some devices.

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

- (MDSpreadViewCell *)cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;            // returns nil if cell is not visible or index path is out of range
//- (NSArray *)visibleCells;
//- (NSArray *)indexPathsForVisibleRows;

//- (void)scrollToRowAtIndexPath:(MDIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
//- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

// Selection

@property (nonatomic) MDSpreadViewSelectionMode highlightMode;
// the default highlight mode. defaults to MDSpreadViewSelectionModeCell. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as MDSpreadViewSelectionModeNone.
@property (nonatomic) MDSpreadViewSelectionMode selectionMode;
// the default selection mode. defaults to MDSpreadViewSelectionModeAutomatic. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as highlightMode.
@property (nonatomic) BOOL allowsSelection;
// default is YES. Controls whether rows can be selected when not in editing mode
@property (nonatomic) BOOL preservesSortSelections;
// default is YES. If a selection is related to a sort, and allowsMultipleSelection is NO, any other non-selection will not deselect that selection, while any other sort selection on the same axis will.
@property (nonatomic) BOOL allowsMultipleSelection;
// default is NO. Controls whether multiple rows can be selected simultaneously

@property (nonatomic) MDSpreadViewSelectionMode rowHeaderHighlightMode; // defaults to MDSpreadViewSelectionModeRow
@property (nonatomic) MDSpreadViewSelectionMode columnHeaderHighlightMode; // defaults to MDSpreadViewSelectionModeColumn
@property (nonatomic) MDSpreadViewSelectionMode cornerHeaderHighlightMode; // defaults to MDSpreadViewSelectionModeCell
// the default highlight mode for header cells. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as  highlightMode.

@property (nonatomic) MDSpreadViewSelectionMode rowHeaderSelectionMode; // defaults to MDSpreadViewSelectionModeRow
@property (nonatomic) MDSpreadViewSelectionMode columnHeaderSelectionMode; // defaults to MDSpreadViewSelectionModeColumn
@property (nonatomic) MDSpreadViewSelectionMode cornerHeaderSelectionMode; // defaults to MDSpreadViewSelectionModeCell
// the default selection mode for header cells. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as selectionMode.

// Allow headers to be highlighted, and eventually selected. Defaults to NO. These apply for footers as well
@property (nonatomic) BOOL allowsRowHeaderSelection;
@property (nonatomic) BOOL allowsColumnHeaderSelection;
@property (nonatomic) BOOL allowsCornerHeaderSelection;

// Overrides the above values with the sort prototype for the header. This includes the selection modes. If you want to further costomize this behavior, ovveride the delegate methods related to highlighting and selection.
@property (nonatomic) BOOL autoAllowSortableHeaderSelection; // default is YES

- (NSArray *)selections __attribute__((unavailable));
// array of MDSpreadViewSelection's

- (MDIndexPath *)rowIndexPathForSelectedCell __attribute__((unavailable));
// returns nil or index path representing section and row of selection.
- (NSArray *)rowIndexPathsForSelectedCells __attribute__((unavailable));
// returns nil or a set of index paths representing the sections and rows of the selection.
- (MDIndexPath *)columnIndexPathForSelectedCell __attribute__((unavailable));
// returns nil or index path representing section and row of selection.
- (NSArray *)columnIndexPathsForSelectedCells __attribute__((unavailable));
// returns nil or a set of index paths representing the sections and rows of the selection.

- (void)sortCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath withPrototypeSortDescriptor:(MDSortDescriptor *)prototypeSortDescriptor selectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition;

- (void)selectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath withSelectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition;
// scroll position only works with MDSpreadViewScrollPositionNone for now
- (void)deselectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath animated:(BOOL)animated;

// Appearance

@property (nonatomic) MDSpreadViewCellSeparatorStyle separatorStyle;
// default is MDSpreadViewCellSeparatorStyleCorner
@property (nonatomic, strong) UIColor *separatorColor;
// default is the standard separator gray

- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
// Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.

// Sorting

@property (nonatomic, copy) NSArray *sortDescriptors;
// Calling -setSortDescriptors: may have the side effect of calling -spreadView:sortDescriptorsDidChange: on the -dataSource.

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
// generally, return an NSString, but just about anything that returns description can be used,
// or can also be something that a custom cell defines
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

- (id)spreadView:(MDSpreadView *)aSpreadView objectValueForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection;

- (id)spreadView:(MDSpreadView *)aSpreadView titleForFooterInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForFooterInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForFooterInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

// manual cell generation. returning nil creates one for you
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection;

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForFooterInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForFooterInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForFooterInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

// sorting. Set these if you only use the "title" getters, or return nil
- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;

- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection;
- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection;

- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForFooterInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForFooterInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (MDSortDescriptor *)spreadView:(MDSpreadView *)aSpreadView sortDescriptorPrototypeForFooterInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath;
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

@interface MDSortDescriptor : NSSortDescriptor <NSCopying>

@property (nonatomic, readonly, strong) MDIndexPath *rowIndexPath;
@property (nonatomic, readonly, strong) MDIndexPath *columnIndexPath;
// index path for sort header
@property (nonatomic, readonly) NSInteger rowSection;
@property (nonatomic, readonly) NSInteger columnSection;
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

@property (nonatomic, strong, readonly) MDIndexPath *rowPath;
@property (nonatomic, strong, readonly) MDIndexPath *columnPath;
@property (nonatomic, readonly) MDSpreadViewSelectionMode selectionMode;

+ (id)selectionWithRow:(MDIndexPath *)row column:(MDIndexPath *)column mode:(MDSpreadViewSelectionMode)mode;

@end

