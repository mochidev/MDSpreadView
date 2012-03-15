//
//  MDSpreadViewCellRowHeaderBackground.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
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

#import "MDSpreadViewCellRowHeaderBackground.h"

@implementation MDSpreadViewCellRowHeaderBackground

- (void)prepareBackground
{
	backgroundTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewRowHeaderTop.png"]
                                      highlightedImage:[UIImage imageNamed:@"MDSpreadViewRowHeaderTopSelected.png"]];
    backgroundTop.contentMode = UIViewContentModeScaleToFill;
    backgroundTop.contentStretch = CGRectMake(2./backgroundTop.bounds.size.width, 3./backgroundTop.bounds.size.height, 1./backgroundTop.bounds.size.width, 1./backgroundTop.bounds.size.height);
	[self addSubview:backgroundTop];
    
	backgroundBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewRowHeaderBottom.png"]
                                         highlightedImage:[UIImage imageNamed:@"MDSpreadViewRowHeaderBottomSelected.png"]];
    backgroundBottom.contentMode = UIViewContentModeScaleToFill;
    backgroundBottom.contentStretch = CGRectMake(2./backgroundBottom.bounds.size.width, 2./backgroundBottom.bounds.size.height, 1./backgroundBottom.bounds.size.width, 1./backgroundBottom.bounds.size.height);
	[self addSubview:backgroundBottom];
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
