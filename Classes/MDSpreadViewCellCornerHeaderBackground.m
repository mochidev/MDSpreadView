//
//  MDSpreadViewCellCornerHeaderBackground.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software, associated artwork, and documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//  2. Neither the name of Mochi Development, Inc. nor the names of its
//     contributors or products may be used to endorse or promote products
//     derived from this software without specific prior written permission.
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

#import "MDSpreadViewCellCornerHeaderBackground.h"

@implementation MDSpreadViewCellCornerHeaderBackground

- (void)prepareBackground
{
	backgroundTopLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCornerTopLeft.png"]
                                          highlightedImage:[UIImage imageNamed:@"MDSpreadViewCornerTopLeftSelected.png"]];
    backgroundTopLeft.contentMode = UIViewContentModeScaleToFill;
    backgroundTopLeft.contentStretch = CGRectMake(3./backgroundTopLeft.bounds.size.width, 3./backgroundTopLeft.bounds.size.height, 1./backgroundTopLeft.bounds.size.width, 1./backgroundTopLeft.bounds.size.height);
	[self addSubview:backgroundTopLeft];
	[backgroundTopLeft release];
	
	backgroundTopRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCornerTopRight.png"]
                                           highlightedImage:[UIImage imageNamed:@"MDSpreadViewCornerTopRightSelected.png"]];
    backgroundTopRight.contentMode = UIViewContentModeScaleToFill;
    backgroundTopRight.contentStretch = CGRectMake(2./backgroundTopRight.bounds.size.width, 3./backgroundTopRight.bounds.size.height, 1./backgroundTopRight.bounds.size.width, 1./backgroundTopRight.bounds.size.height);
	[self addSubview:backgroundTopRight];
	[backgroundTopRight release];
	
	backgroundBottomLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCornerBottomLeft.png"]
                                             highlightedImage:[UIImage imageNamed:@"MDSpreadViewCornerBottomLeftSelected.png"]];
    backgroundBottomLeft.contentMode = UIViewContentModeScaleToFill;
    backgroundBottomLeft.contentStretch = CGRectMake(3./backgroundBottomLeft.bounds.size.width, 2./backgroundBottomLeft.bounds.size.height, 1./backgroundBottomLeft.bounds.size.width, 1./backgroundBottomLeft.bounds.size.height);
	[self addSubview:backgroundBottomLeft];
	[backgroundBottomLeft release];
	
	backgroundBottomRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCornerBottomRight.png"]
                                              highlightedImage:[UIImage imageNamed:@"MDSpreadViewCornerBottomRightSelected.png"]];
    backgroundBottomRight.contentMode = UIViewContentModeScaleToFill;
    backgroundBottomRight.contentStretch = CGRectMake(6./backgroundBottomRight.bounds.size.width, 6./backgroundBottomRight.bounds.size.height, 1./backgroundBottomRight.bounds.size.width, 1./backgroundBottomRight.bounds.size.height);
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
