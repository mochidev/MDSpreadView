//
//  MDSpreadViewCellCornerHeaderBackground.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewCellCornerHeaderBackground.h"

@implementation MDSpreadViewCellCornerHeaderBackground

- (void)prepareBackground
{
	UIImage *topLeft = [UIImage imageNamed:@"MDSpreadViewCornerTopLeft.png"];
	backgroundTopLeft = [[UIImageView alloc] initWithImage:topLeft highlightedImage:topLeft];
    backgroundTopLeft.contentMode = UIViewContentModeScaleToFill;
    backgroundTopLeft.contentStretch = CGRectMake(2./backgroundTopLeft.bounds.size.width, 2./backgroundTopLeft.bounds.size.height, 1./backgroundTopLeft.bounds.size.width, 1./backgroundTopLeft.bounds.size.height);
	[self addSubview:backgroundTopLeft];
	[backgroundTopLeft release];
	
	UIImage *topRight = [UIImage imageNamed:@"MDSpreadViewCornerTopRight.png"];
	backgroundTopRight = [[UIImageView alloc] initWithImage:topRight highlightedImage:topRight];
    backgroundTopRight.contentMode = UIViewContentModeScaleToFill;
    backgroundTopRight.contentStretch = CGRectMake(1./backgroundTopRight.bounds.size.width, 2./backgroundTopRight.bounds.size.height, 1./backgroundTopRight.bounds.size.width, 1./backgroundTopRight.bounds.size.height);
	[self addSubview:backgroundTopRight];
	[backgroundTopRight release];
	
	UIImage *bottomLeft = [UIImage imageNamed:@"MDSpreadViewCornerBottomLeft.png"];
	backgroundBottomLeft = [[UIImageView alloc] initWithImage:bottomLeft highlightedImage:bottomLeft];
    backgroundBottomLeft.contentMode = UIViewContentModeScaleToFill;
    backgroundBottomLeft.contentStretch = CGRectMake(2./backgroundBottomLeft.bounds.size.width, 1./backgroundBottomLeft.bounds.size.height, 1./backgroundBottomLeft.bounds.size.width, 1./backgroundBottomLeft.bounds.size.height);
	[self addSubview:backgroundBottomLeft];
	[backgroundBottomLeft release];
	
	UIImage *bottomRight = [UIImage imageNamed:@"MDSpreadViewCornerBottomRight.png"];
	backgroundBottomRight = [[UIImageView alloc] initWithImage:bottomRight highlightedImage:bottomRight];
    backgroundBottomRight.contentMode = UIViewContentModeScaleToFill;
    backgroundBottomRight.contentStretch = CGRectMake(5./backgroundBottomRight.bounds.size.width, 5./backgroundBottomRight.bounds.size.height, 1./backgroundBottomRight.bounds.size.width, 1./backgroundBottomRight.bounds.size.height);
	[self addSubview:backgroundBottomRight];
	[backgroundBottomRight release];
}

- (void)layoutBackground
{
	CGFloat halfY = floor(self.bounds.size.height/2.);
	CGFloat halfX = floor(self.bounds.size.width/2.);
	backgroundTopLeft.frame = CGRectMake(-1, -1, self.bounds.size.width+1-halfX, self.bounds.size.height+1-halfY);
	backgroundTopRight.frame = CGRectMake(self.bounds.size.width-halfX, -1, halfX+1, self.bounds.size.height+1-halfY);
	backgroundBottomLeft.frame = CGRectMake(-1, self.bounds.size.height-halfY, self.bounds.size.width+1-halfX, halfY+1);
	backgroundBottomRight.frame = CGRectMake(self.bounds.size.width-halfX, self.bounds.size.height-halfY, halfX+1, halfY+1);
}

- (void)setHighlighted:(BOOL)yn
{
	[super setHighlighted:yn];
	
	backgroundTopLeft.highlighted = yn;
	backgroundBottomLeft.highlighted = yn;
	backgroundTopRight.highlighted = yn;
	backgroundBottomRight.highlighted = yn;
}

@end
