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
    
    NSUInteger rowSectionCount;
}

@property (nonatomic, retain) MDSpreadViewColumnDescriptor *headerColumn;
@property (nonatomic, readonly) NSMutableArray *columns;
@property (nonatomic) NSUInteger columnCount;
@property (nonatomic) NSUInteger rowSectionCount;

- (MDSpreadViewColumnDescriptor *)columnAtIndex:(NSUInteger)index;
- (void)setColumn:(MDSpreadViewColumnDescriptor *)column atIndex:(NSUInteger)index;

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection;
- (NSUInteger)rowCountForSection:(NSUInteger)rowSection;

- (NSArray *)allCells;
- (void)clearAllCells;

@end
