//
//  MDSpreadViewHeaderCell.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
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

#import "MDSpreadViewHeaderCell.h"
#import "MDSpreadViewCellBackground.h"
#import "MDSpreadViewCellRowHeaderBackground.h"
#import "MDSpreadViewCellColumnHeaderBackground.h"
#import "MDSpreadViewCellCornerHeaderBackground.h"

@implementation MDSpreadViewHeaderCell

@dynamic sortDescriptorPrototype, defaultSortAxis;

- (id)initWithStyle:(MDSpreadViewHeaderCellStyle)aStyle reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!reuseIdentifier) {
        if (aStyle == MDSpreadViewHeaderCellStyleCorner) {
            reuseIdentifier = @"_MDDefaultHeaderCornerCell";
        } else if (aStyle == MDSpreadViewHeaderCellStyleRow) {
            reuseIdentifier = @"_MDDefaultHeaderRowCell";
        } else if (aStyle == MDSpreadViewHeaderCellStyleColumn) {
            reuseIdentifier = @"_MDDefaultHeaderColumnCell";
        }
    }
    if (self = [super initWithStyle:(MDSpreadViewCellStyle)aStyle reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = NO;
        self.backgroundColor = nil;
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        MDSpreadViewCellBackground *newBackground = nil;
        MDSpreadViewCellBackground *newSelectedBackground = nil;
        if (aStyle == MDSpreadViewHeaderCellStyleCorner) {
            newBackground = [[MDSpreadViewCellCornerHeaderBackground alloc] init];
            newSelectedBackground = [[MDSpreadViewCellCornerHeaderBackground alloc] init];
        } else if (aStyle == MDSpreadViewHeaderCellStyleRow) {
            newBackground = [[MDSpreadViewCellRowHeaderBackground alloc] init];
            newSelectedBackground = [[MDSpreadViewCellRowHeaderBackground alloc] init];
        } else if (aStyle == MDSpreadViewHeaderCellStyleColumn) {
            newBackground = [[MDSpreadViewCellColumnHeaderBackground alloc] init];
            newSelectedBackground = [[MDSpreadViewCellColumnHeaderBackground alloc] init];
        }
        
        newSelectedBackground.highlighted = YES;
        self.backgroundView = newBackground;
        self.highlightedBackgroundView = newSelectedBackground;
        [newBackground release];
        [newSelectedBackground release];
        
		self.textLabel.font = [UIFont boldSystemFontOfSize:18];
		self.textLabel.opaque = NO;
		self.textLabel.backgroundColor = nil;
		self.textLabel.textColor = [UIColor whiteColor];
		self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(14, 2, self.bounds.size.width-28, self.bounds.size.height-3);
}

- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated
{
    if (self.highlighted != isHighlighted) {
        [super setHighlighted:isHighlighted animated:animated];
    
        self.textLabel.opaque = NO;
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
}
- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    if (self.style == MDSpreadViewHeaderCellStyleColumn) {
        return [NSString stringWithFormat:@"%@ Row", self.textLabel.text];
    } else {
        return [NSString stringWithFormat:@"%@ Column", self.textLabel.text];
    }
    
    return self.textLabel.text;
}

- (NSString *)accessibilityHint
{
    return @"";
//    return @"Double tap to sort.";
}

//- (UIAccessibilityTraits)accessibilityTraits
//{
//    if (self.highlighted) {
//        return UIAccessibilityTraitSelected|UIAccessibilityTraitButton;
//    }
//    return UIAccessibilityTraitButton;
//}

@end
