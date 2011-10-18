//
//  MDSpreadViewColumnDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDSpreadViewRowSectionDescriptor;

@interface MDSpreadViewColumnDescriptor : NSObject {
    NSMutableArray *rowSections;
}
@property (nonatomic, readonly) NSMutableArray *rowSections;
@property (nonatomic) NSUInteger count;

- (MDSpreadViewRowSectionDescriptor *)sectionAtIndex:(NSUInteger)index;
- (void)setSection:(MDSpreadViewRowSectionDescriptor *)section atIndex:(NSUInteger)index;

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection;
- (NSUInteger)rowCountForSection:(NSUInteger)rowSection;

- (NSArray *)allCells;
- (void)clearAllCells;

@end
