//
//  MDSpreadViewCellBackground.m
//  MDSectionedTableViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewCellBackground.h"

@implementation MDSpreadViewCellBackground

@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		highlighted = NO;
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
        [self prepareBackground];
		[self layoutBackground];
    }
    return self;
}

- (void)setFrame:(CGRect)aRect
{
	[super setFrame:aRect];
	[self layoutBackground];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)prepareBackground
{
	
}

- (void)layoutBackground
{
	
}

- (void)setHighlighted:(BOOL)yn
{
	highlighted = yn;
}

@end
