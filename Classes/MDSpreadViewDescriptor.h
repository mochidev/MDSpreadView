//
//  MDSpreadViewDescriptor.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
//  Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.
//  
//  Also, it'd be super awesome if you credited this page in your about screen :)
//  

#import <Foundation/Foundation.h>
#import "NSIndexPath+MDSpreadView.h"
@class MDSpreadViewCell;
@class MDSpreadViewAxisDescriptor;

@interface MDSpreadViewDescriptor : NSObject {
    MDSpreadViewAxisDescriptor *columnAxis;
    MDSpreadViewAxisDescriptor *rowAxis;
    
    NSMutableArray *columns;
}
//@property (nonatomic, readonly) NSMutableArray *columnSections;
@property (nonatomic) NSUInteger columnSectionCount;
@property (nonatomic) NSUInteger rowSectionCount;
@property (nonatomic, readonly) CGFloat totalHeight;
@property (nonatomic, readonly) CGFloat totalWidth;

- (void)setColumnCount:(NSUInteger)count forSection:(NSUInteger)columnSection;
- (NSUInteger)columnCountForSection:(NSUInteger)columnSection;

- (void)setRowCount:(NSUInteger)count forSection:(NSUInteger)rowSection;
- (NSUInteger)rowCountForSection:(NSUInteger)rowSection;

// Expects linear index!
- (MDSpreadViewCell *)setCell:(MDSpreadViewCell *)cell forColumnIndex:(NSUInteger)columnIndex rowIndex:(NSUInteger)rowIndex;
- (MDSpreadViewCell *)cellForColumnIndex:(NSUInteger)columnIndex rowIndex:(NSUInteger)rowIndex;

- (MDSpreadViewCell *)setCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)setHeaderCell:(MDSpreadViewCell *)cell forRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)setHeaderCell:(MDSpreadViewCell *)cell forColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

- (MDSpreadViewCell *)cellForRowAtIndexPath:(NSIndexPath *)rowPath forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (MDSpreadViewCell *)cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSIndexPath *)rowPath;

- (void)setHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)rowPath;
- (void)setHeight:(CGFloat)height forHeaderRowInSection:(NSInteger)rowSection;
- (void)setWidth:(CGFloat)width forColumnAtIndexPath:(NSIndexPath *)columnPath;
- (void)setWidth:(CGFloat)width forHeaderColumnInSection:(NSInteger)columnSection;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)rowPath;
- (CGFloat)heightForHeaderRowInSection:(NSInteger)rowSection;
- (CGFloat)widthForColumnAtIndexPath:(NSIndexPath *)columnPath;
- (CGFloat)widthForHeaderColumnInSection:(NSInteger)columnSection;

- (CGFloat)heightForEntireRowSection:(NSInteger)rowSection;
- (CGFloat)widthForEntireColumnSection:(NSInteger)columnSection;

- (NSArray *)allCells;
- (NSArray *)clearAllCells;

- (NSArray *)allCellsForHeaderColumnForSection:(NSUInteger)columnSection;
- (NSArray *)allCellsForColumnAtIndexPath:(NSIndexPath *)columnPath;
- (NSArray *)clearHeaderColumnForSection:(NSUInteger)columnSection;
- (NSArray *)clearColumnAtIndexPath:(NSIndexPath *)columnPath;

@end
