//
//  NSIndexPath+MDSpreadView.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (MDSpreadView)

+ (NSIndexPath *)indexPathForColumn:(NSInteger)column inSection:(NSInteger)section;
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@property(nonatomic,readonly) NSInteger section;
@property(nonatomic,readonly) NSInteger row;
@property(nonatomic,readonly) NSInteger column;

@end
