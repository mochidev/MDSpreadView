//
//  NSIndexPath+MDSpreadView.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
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
