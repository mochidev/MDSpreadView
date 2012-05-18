//
//  MDSpreadView.h
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

@class MDSpreadView;
@protocol MDSpreadViewDataSource;
@class MDSpreadViewCell;
@class MDSpreadViewDescriptor;

#pragma mark - MDSpreadViewDelegate

@protocol MDSpreadViewDelegate<NSObject, UIScrollViewDelegate>

@optional

// Display customization

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath __attribute__((unavailable));

// Variable height support

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection; // pass 0 to hide header

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection; // pass 0 to hide header

// Accessories (disclosures). 

- (void)spreadView:(MDSpreadView *)aSpreadView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath __attribute__((unavailable));

// Selection

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)spreadView:(MDSpreadView *)aSpreadView willSelectRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath __attribute__((unavailable));
- (NSIndexPath *)spreadView:(MDSpreadView *)aSpreadView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath __attribute__((unavailable));

// Called after the user changes the selection.
- (void)spreadView:(MDSpreadView *)aSpreadView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath __attribute__((unavailable));

- (MDSpreadViewSelectionMode)spreadView:(MDSpreadView *)aSpreadView selectionModeForRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath __attribute__((unavailable));

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)spreadView:(MDSpreadView *)aSpreadView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath __attribute__((unavailable));
- (BOOL)spreadView:(MDSpreadView *)aSpreadView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath withSender:(id)sender __attribute__((unavailable));
- (void)spreadView:(MDSpreadView *)aSpreadView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath forColumnAtIndexPath:(NSIndexPath *)columnPath withSender:(id)sender __attribute__((unavailable));

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
    
    NSMutableSet *dequeuedCells;
    
    NSMutableArray *visibleCells; // array of array
    NSIndexPath *_visibleRowIndexPath;
    NSIndexPath *_visibleColumnIndexPath;
    CGRect visibleBounds;
    
    MDSpreadViewDescriptor *descriptor;
    
    NSUInteger selectedRow;
    NSUInteger selectedSection;
    
    UIView *anchorCell;
    UIView *anchorRowHeaderCell;
    UIView *anchorColumnHeaderCell;
    UIView *anchorCornerHeaderCell;
    
    BOOL implementsRowHeight;
    BOOL implementsRowHeaderHeight;
    BOOL implementsColumnWidth;
    BOOL implementsColumnHeaderWidth;
}

@property (nonatomic, assign) IBOutlet id <MDSpreadViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id <MDSpreadViewDelegate> delegate;

// Cell Dimensions
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat sectionRowHeaderHeight;
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic) CGFloat sectionColumnHeaderWidth;

@property (nonatomic, readwrite, retain) UIView *backgroundView __attribute__((unavailable)); // the background view will be automatically resized to track the size of the table view.  this will be placed as a subview of the table view behind all cells and headers/footers.  default may be non-nil for some devices.

// Data

- (void)reloadData;
// reloads everything from scratch. redisplays visible rows. because we only keep info about visible rows, this is cheap. will adjust offset if table shrinks

// Info

- (NSInteger)numberOfRowSections __attribute__((unavailable));
- (NSInteger)numberOfRowsInRowSection:(NSInteger)section __attribute__((unavailable));
- (NSInteger)numberOfColumnSections __attribute__((unavailable));
- (NSInteger)numberOfColumnsInColumnSection:(NSInteger)section __attribute__((unavailable));

- (CGRect)rectForRowSection:(NSInteger)rowSection columnSection:(NSInteger)columnSection __attribute__((unavailable));
// includes header, footer and all rows
//- (CGRect)rectForHeaderInSection:(NSInteger)section;
//- (CGRect)rectForFooterInSection:(NSInteger)section;
//- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)cellRectForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;

//- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;                         // returns nil if point is outside table
//- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell;                      // returns nil if cell is not visible
//- (NSArray *)indexPathsForRowsInRect:(CGRect)rect;                              // returns nil if rect not valid 

//- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;            // returns nil if cell is not visible or index path is out of range
//- (NSArray *)visibleCells;
//- (NSArray *)indexPathsForVisibleRows;

//- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
//- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

// Selection

@property (nonatomic) BOOL allowsSelection __attribute__((unavailable));
// default is YES. Controls whether rows can be selected when not in editing mode
@property (nonatomic) BOOL allowsMultipleSelection __attribute__((unavailable));
// default is NO. Controls whether multiple rows can be selected simultaneously

- (NSIndexPath *)rowIndexPathForSelectedCell __attribute__((unavailable));
// returns nil or index path representing section and row of selection.
- (NSArray *)rowIndexPathsForSelectedCells __attribute__((unavailable));
// returns nil or a set of index paths representing the sections and rows of the selection.
- (NSIndexPath *)columnIndexPathForSelectedCell __attribute__((unavailable));
// returns nil or index path representing section and row of selection.
- (NSArray *)columnIndexPathsForSelectedCells __attribute__((unavailable));
// returns nil or a set of index paths representing the sections and rows of the selection.

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition __attribute__((unavailable));
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated __attribute__((unavailable));

// Appearance

@property (nonatomic) MDSpreadViewCellSeparatorStyle separatorStyle __attribute__((unavailable));
// default is MDSpreadViewCellSeparatorStyleCorner
@property (nonatomic, retain) UIColor *separatorColor __attribute__((unavailable));
// default is the standard separator gray

- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
// Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.

@end

#pragma mark - MDSpreadViewDataSource

@protocol MDSpreadViewDataSource<NSObject>

@required

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section;
- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section;

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;

@optional

- (NSInteger)numberOfColumnSectionsInSpreadView:(MDSpreadView *)aSpreadView;
// Default is 1 if not implemented
- (NSInteger)numberOfRowSectionsInSpreadView:(MDSpreadView *)aSpreadView;
// Default is 1 if not implemented

- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

@end
