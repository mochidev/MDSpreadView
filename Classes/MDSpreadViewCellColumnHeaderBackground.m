//
//  MDSpreadViewCellColumnHeaderBackground.m
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

#import "MDSpreadViewCellColumnHeaderBackground.h"

@implementation MDSpreadViewCellColumnHeaderBackground

- (void)prepareBackground
{
	backgroundLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderLeft.png"]
                                       highlightedImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderLeftSelected.png"]];
    backgroundLeft.contentMode = UIViewContentModeScaleToFill;
    backgroundLeft.contentStretch = CGRectMake(3./backgroundLeft.bounds.size.width, 2./backgroundLeft.bounds.size.height, 1./backgroundLeft.bounds.size.width, 1./backgroundLeft.bounds.size.height);
	[self addSubview:backgroundLeft];
    
	backgroundRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderRight.png"]
                                        highlightedImage:[UIImage imageNamed:@"MDSpreadViewColumnHeaderRightSelected.png"]];
    backgroundRight.contentMode = UIViewContentModeScaleToFill;
    backgroundRight.contentStretch = CGRectMake(2./backgroundRight.bounds.size.width, 2./backgroundRight.bounds.size.height, 1./backgroundRight.bounds.size.width, 1./backgroundRight.bounds.size.height);
	[self addSubview:backgroundRight];
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
