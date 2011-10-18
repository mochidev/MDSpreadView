//
//  MDSpreadViewDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSIndexPath+MDSpreadView.h"
@class MDSpreadViewColumnSectionDescriptor;
@class MDSpreadViewCell;

@interface MDSpreadViewDescriptor : NSObject {
    NSMutableArray *columnSections;
    
    NSUInteger rowSectionCount;
}
@property (nonatomic, readonly) NSMutableArray *columnSections;
@property (nonatomic) NSUInteger columnSectionCount;
@property (nonatomic) NSUInteger rowSectionCount;

- (MDSpreadViewColumnSectionDescriptor *)sectionAtIndex:(NSUInteger)index;
- (void)setSection:(MDSpreadViewColumnSectionDescriptor *)section atIndex:(NSUInteger)index;

- (void)setColumnCount:(NSUInteger)count forSection:(NSUInteger)columnSection;
- (NSUInteger)columnCountForSection:(NSUInteger)columnSection;

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection;
- (NSUInteger)rowCountForSection:(NSUInteger)rowSection;

- (void)setCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (void)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (void)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (void)setHeaderCell:(MDSpreadViewCell *)cell forColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

- (MDSpreadViewCell *)cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

- (NSArray *)allCells;
- (void)clearAllCells;

- (NSArray *)allCellsForHeaderColumnForSection:(NSUInteger)columnSection;
- (NSArray *)allCellsForColumnAtIndexPath:(NSIndexPath *)columnPath;
- (void)clearHeaderColumnForSection:(NSUInteger)columnSection;
- (void)clearColumnAtIndexPath:(NSIndexPath *)columnPath;

@end
