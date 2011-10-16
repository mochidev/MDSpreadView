//
//  MDSpreadView.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDSpreadView;
@class MDSpreadViewCell;

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
}

@property (nonatomic, assign) IBOutlet id <MDSpreadViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id <MDSpreadViewDelegate> delegate;
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