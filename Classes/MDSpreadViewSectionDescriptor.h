//
//  MDSpreadViewSectionDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 11/11/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDSpreadViewCellDescriptor;

@interface MDSpreadViewSectionDescriptor : NSObject {
    CGFloat cachedSize;
    NSMutableArray *cells;
    MDSpreadViewCellDescriptor *headerCell;
    MDSpreadViewCellDescriptor *footerCell;
    
    NSUInteger baseIndex;
}

@property (nonatomic) NSUInteger baseIndex;
@property (nonatomic) NSUInteger count;
@property (nonatomic, readonly) CGFloat sectionSize;
@property (nonatomic) CGFloat headerCellSize;
@property (nonatomic) CGFloat footerCellSize;

- (void)setSize:(CGFloat)size forCellAtIndex:(NSUInteger)index;
- (CGFloat)sizeOfCellAtIndex:(NSUInteger)index;

@end
