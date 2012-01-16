//
//  MDSpreadView.h
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

#import <UIKit/UIKit.h>

@class MDSpreadView;
@class MDSpreadViewCell;
@class MDSpreadViewDescriptor;

@protocol MDSpreadViewDelegate<NSObject, UIScrollViewDelegate>

@optional

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection; // pass 0 to hide header

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection; // pass 0 to hide header

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
//- (NSIndexPath *)spreadView:(MDSpreadView *)aSpreadView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (NSIndexPath *)spreadView:(MDSpreadView *)aSpreadView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
// Called after the user changes the selection.
- (void)spreadView:(MDSpreadView *)aSpreadView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forColumnIndex:(NSIndexPath *)columnPath;
//- (void)spreadView:(MDSpreadView *)aSpreadView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol MDSpreadViewDataSource<NSObject>

@required

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section;
- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section;

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;

@optional

- (NSInteger)numberOfColumnSectionsInSpreadView:(MDSpreadView *)aSpreadView;    // Default is 1 if not implemented
- (NSInteger)numberOfRowSectionsInSpreadView:(MDSpreadView *)aSpreadView;       // Default is 1 if not implemented

- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

@end

#pragma mark - MDSpreadView

@interface MDSpreadView : UIScrollView {
  @private
    id <MDSpreadViewDataSource> _dataSource;
    
    CGFloat rowHeight;
    CGFloat sectionRowHeaderHeight;
    CGFloat columnWidth;
    CGFloat sectionColumnHeaderWidth;
    
    NSMutableSet *dequeuedCells;
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

- (void)reloadData;
- (NSIndexPath *)indexPathForSelectedRow; 
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end