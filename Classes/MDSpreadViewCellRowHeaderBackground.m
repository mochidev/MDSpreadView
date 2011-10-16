//
//  MDSpreadViewCellRowHeaderBackground.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewCellRowHeaderBackground.h"

@implementation MDSpreadViewCellRowHeaderBackground

- (void)prepareBackground
{
	UIImage *top = [UIImage imageNamed:@"MDSpreadViewRowHeaderTop.png"];
	backgroundTop = [[UIImageView alloc] initWithImage:top highlightedImage:top];
    backgroundTop.contentMode = UIViewContentModeScaleToFill;
    backgroundTop.contentStretch = CGRectMake(1./backgroundTop.bounds.size.width, 2./backgroundTop.bounds.size.height, 1./backgroundTop.bounds.size.width, 1./backgroundTop.bounds.size.height);
	[self addSubview:backgroundTop];
	[backgroundTop release];
    
	UIImage *bottom = [UIImage imageNamed:@"MDSpreadViewRowHeaderBottom.png"];
	backgroundBottom = [[UIImageView alloc] initWithImage:bottom highlightedImage:bottom];
    backgroundBottom.contentMode = UIViewContentModeScaleToFill;
    backgroundBottom.contentStretch = CGRectMake(1./backgroundBottom.bounds.size.width, 1./backgroundBottom.bounds.size.height, 1./backgroundBottom.bounds.size.width, 1./backgroundBottom.bounds.size.height);
	[self addSubview:backgroundBottom];
	[backgroundBottom release];
}

- (void)layoutBackground
{
	CGFloat half = floor(self.bounds.size.height/2.);
	backgroundBottom.frame = CGRectMake(0, self.bounds.size.height-half, self.bounds.size.width, half);
	backgroundTop.frame = CGRectMake(0, -1, self.bounds.size.width, self.bounds.size.height+1-half);
}

- (void)setHighlighted:(BOOL)yn
{
	[super setHighlighted:yn];
	
	backgroundTop.highlighted = yn;
	backgroundBottom.highlighted = yn;
}

@end
