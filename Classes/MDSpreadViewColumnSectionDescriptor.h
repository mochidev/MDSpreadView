//
//  MDSpreadViewColumnSectionDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDSpreadViewColumnDescriptor;

@interface MDSpreadViewColumnSectionDescriptor : NSObject {
    MDSpreadViewColumnDescriptor *headerColumn;
    NSMutableArray *columns;
}

@property (nonatomic, retain) MDSpreadViewColumnDescriptor *headerColumn;
@property (nonatomic, readonly) NSMutableArray *columns;
@property (nonatomic) NSUInteger count;

- (MDSpreadViewColumnDescriptor *)columnAtIndex:(NSUInteger)index;
- (void)setColumn:(MDSpreadViewColumnDescriptor *)column atIndex:(NSUInteger)index;

@end
