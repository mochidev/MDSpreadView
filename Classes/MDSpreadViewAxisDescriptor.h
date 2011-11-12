//
//  MDSpreadViewAxisDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 11/11/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDSpreadViewAxisDescriptor : NSObject {
    CGFloat cachedSize;
    NSMutableArray *sections;
}

@property (nonatomic) NSUInteger sectionCount;
@property (nonatomic, readonly) CGFloat axisSize;

- (void)setCellCount:(NSUInteger)count forSectionAtIndex:(NSUInteger)index;
- (NSUInteger)countOfSectionAtIndex:(NSUInteger)index;

- (CGFloat)sizeOfSectionAtIndex:(NSUInteger)index;

- (void)setSize:(CGFloat)size forCellAtIndexPath:(NSIndexPath *)index;
- (CGFloat)sizeOfCellAtIndex:(NSIndexPath *)index;

- (void)setSize:(CGFloat)size forHeaderCellAtIndexPath:(NSUInteger)index;
- (CGFloat)sizeOfHeaderCellAtIndex:(NSUInteger)index;

- (void)setSize:(CGFloat)size forFooterCellAtIndexPath:(NSUInteger)index;
- (CGFloat)sizeOfFooterCellAtIndex:(NSUInteger)index;

- (NSUInteger)linearIndexForCellAtIndexPath:(NSIndexPath *)index;
- (NSUInteger)linearIndexForHeaderAtIndex:(NSUInteger)index;
- (NSUInteger)linearIndexForFooterAtIndex:(NSUInteger)index;

@end
