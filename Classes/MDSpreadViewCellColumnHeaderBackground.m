//
//  MDSpreadViewCellColumnHeaderBackground.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewCellColumnHeaderBackground.h"

@implementation MDSpreadViewCellColumnHeaderBackground

- (void)prepareBackground
{
	backgroundLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderLeft.png"]
                                       highlightedImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderLeftSelected.png"]];
    backgroundLeft.contentMode = UIViewContentModeScaleToFill;
    backgroundLeft.contentStretch = CGRectMake(3./backgroundLeft.bounds.size.width, 2./backgroundLeft.bounds.size.height, 1./backgroundLeft.bounds.size.width, 1./backgroundLeft.bounds.size.height);
	[self addSubview:backgroundLeft];
	[backgroundLeft release];
    
	backgroundRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderRight.png"]
                                        highlightedImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderRightSelected.png"]];
    backgroundRight.contentMode = UIViewContentModeScaleToFill;
    backgroundRight.contentStretch = CGRectMake(2./backgroundRight.bounds.size.width, 2./backgroundRight.bounds.size.height, 1./backgroundRight.bounds.size.width, 1./backgroundRight.bounds.size.height);
	[self addSubview:backgroundRight];
	[backgroundRight release];
}

- (void)layoutBackground
{
	CGFloat half = floor(self.bounds.size.width/2.);
	backgroundLeft.frame = CGRectMake(-1, 0, self.bounds.size.width+1-half, self.bounds.size.height);
	backgroundRight.frame = CGRectMake(self.bounds.size.width-half, 0, half, self.bounds.size.height);
}

- (void)setHighlighted:(BOOL)yn
{
	[super setHighlighted:yn];
	
	backgroundLeft.highlighted = yn;
	backgroundRight.highlighted = yn;
}

@end
