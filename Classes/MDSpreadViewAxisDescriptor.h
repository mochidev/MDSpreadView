//
//  MDSpreadViewAxisDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 11/11/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDIndexPath;

@interface MDSpreadViewAxisDescriptor : NSObject {
    CGFloat cachedSize;
    NSMutableArray *sections;
}

@property (nonatomic) NSUInteger sectionCount;
@property (nonatomic, readonly) CGFloat axisSize;

- (void)setCellCount:(NSUInteger)count forSectionAtIndex:(NSUInteger)index;
- (NSUInteger)countOfSectionAtIndex:(NSUInteger)index;

- (CGFloat)sizeOfSectionAtIndex:(NSUInteger)index;

- (void)setSize:(CGFloat)size forCellAtIndexPath:(MDIndexPath *)index;
- (CGFloat)sizeOfCellAtIndex:(MDIndexPath *)index;

- (void)setSize:(CGFloat)size forHeaderCellAtIndex:(NSUInteger)index;
- (CGFloat)sizeOfHeaderCellAtIndex:(NSUInteger)index;

- (void)setSize:(CGFloat)size forFooterCellAtIndex:(NSUInteger)index;
- (CGFloat)sizeOfFooterCellAtIndex:(NSUInteger)index;

- (NSUInteger)linearIndexForCellAtIndexPath:(MDIndexPath *)index;
- (NSUInteger)linearIndexForHeaderAtIndex:(NSUInteger)index;
- (NSUInteger)linearIndexForFooterAtIndex:(NSUInteger)index;

@end
