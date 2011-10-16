//
//  NSIndexPath+MDSpreadView.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "NSIndexPath+MDSpreadView.h"

@implementation NSIndexPath (MDSpreadView)

+ (NSIndexPath *)indexPathForColumn:(NSInteger)column inSection:(NSInteger)section
{
    NSUInteger indexes[2];
    indexes[0] = section;
    indexes[1] = column;
    
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section
{
    NSUInteger indexes[2];
    indexes[0] = section;
    indexes[1] = row;
    
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (NSInteger)row
{
    return [self indexAtPosition:1];
}

- (NSInteger)column
{
    return [self indexAtPosition:1];
}

- (NSInteger)section
{
    return [self indexAtPosition:0];
}

@end
