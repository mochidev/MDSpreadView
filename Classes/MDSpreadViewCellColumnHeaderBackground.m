//
//  MDSpreadViewCellColumnHeaderBackground.m
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

#import "MDSpreadViewCellColumnHeaderBackground.h"

@implementation MDSpreadViewCellColumnHeaderBackground

- (void)prepareBackground
{
	backgroundLeft = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MDSpreadViewColumnHeaderLeft.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 3, 2, 1)]
                                       highlightedImage:[[UIImage imageNamed:@"MDSpreadViewColumnHeaderLeftSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 3, 2, 1)]];
	[self addSubview:backgroundLeft];
    
	backgroundRight = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MDSpreadViewColumnHeaderRight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)]
                                        highlightedImage:[[UIImage imageNamed:@"MDSpreadViewColumnHeaderRightSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)]];
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
