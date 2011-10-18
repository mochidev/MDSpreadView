//
//  MDSpreadViewRowSectionDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDSpreadViewCell;

@interface MDSpreadViewRowSectionDescriptor : NSObject {
    MDSpreadViewCell *headerCell;
    NSMutableArray *cells;
}

@property (nonatomic, retain) MDSpreadViewCell *headerCell;
@property (nonatomic, readonly) NSMutableArray *cells;
@property (nonatomic) NSUInteger count;

- (MDSpreadViewCell *)cellAtIndex:(NSUInteger)index;
- (void)setCell:(MDSpreadViewCell *)cell atIndex:(NSUInteger)index;

- (NSArray *)allCells;
- (void)clearAllCells;

@end
