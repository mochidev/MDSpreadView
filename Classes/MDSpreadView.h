//
//  MDSpreadView.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDSpreadView;

@protocol MDSpreadViewDelegate<NSObject, UIScrollViewDelegate>

@optional

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection;

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection;

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
//- (NSIndexPath *)spreadView:(MDSpreadView *)aSpreadView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (NSIndexPath *)spreadView:(MDSpreadView *)aSpreadView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
// Called after the user changes the selection.
- (void)spreadView:(MDSpreadView *)aSpreadView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)spreadView:(MDSpreadView *)aSpreadView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol MDSpreadViewDataSource<NSObject>

@required

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section;
- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section;

//- (UITableViewCell *)tableView:(MDSpreadView *)tableView cellForRowIndexPath:(NSIndexPath *)indexPath columnIndexPath:(NSIndexPath *)columnIndex;

@optional

- (NSInteger)numberOfColumnSectionsInSpreadView:(MDSpreadView *)aSpreadView;    // Default is 1 if not implemented
- (NSInteger)numberOfRowSectionsInSpreadView:(MDSpreadView *)aSpreadView;       // Default is 1 if not implemented

- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnSection:(NSIndexPath *)columnSection;
- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnIndex;
- (NSString *)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowIndex;

- (UIImage *)spreadView:(MDSpreadView *)aSpreadView imageForHeaderInRowSection:(NSInteger)section forColumnSection:(NSIndexPath *)columnSection;
- (UIImage *)spreadView:(MDSpreadView *)aSpreadView imageForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnIndex;
- (UIImage *)spreadView:(MDSpreadView *)aSpreadView imageForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowIndex;

@end

#pragma mark - MDSpreadView

@interface MDSpreadView : UIScrollView {
  @private
    id <MDSpreadViewDataSource> _dataSource;
    CGFloat rowHeight;
    CGFloat sectionRowHeaderHeight;
    CGFloat columnWidth;
    CGFloat sectionColumnHeaderWidth;
}

@property (nonatomic, assign) id <MDSpreadViewDataSource> dataSource;
@property (nonatomic, assign) id <MDSpreadViewDelegate> delegate;
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