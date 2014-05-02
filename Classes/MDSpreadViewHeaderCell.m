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

@interface MDSpreadViewHeaderCell () {
    UIView *_originalSelectedBackground;
}

@end

@implementation MDSpreadViewHeaderCell

@dynamic sortDescriptorPrototype, defaultSortAxis;

- (instancetype)initWithStyle:(MDSpreadViewHeaderCellStyle)aStyle reuseIdentifier:(NSString *)reuseIdentifier
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
        if (NSClassFromString(@"UIMotionEffect")) {
            self.clipsToBounds = NO;
            
            UIView *newBackground = [[UIView alloc] init];
            UIView *newHighlightedBackground = [[UIView alloc] init];
            UIView *newSelectedBackground = [[UIView alloc] init];
            newBackground.backgroundColor = [UIColor colorWithWhite:247./255. alpha:1];
            newHighlightedBackground.backgroundColor = [UIColor colorWithWhite:210./255. alpha:1.];
            newSelectedBackground.backgroundColor = [self.tintColor colorWithAlphaComponent:0.65];
            _originalSelectedBackground = newSelectedBackground;
            self.backgroundView = newBackground;
//            self.highlightedBackgroundView = newHighlightedBackground;
            self.selectedBackgroundView = newSelectedBackground;
            
            self.textLabel.font = [UIFont boldSystemFontOfSize:14];
            self.textLabel.backgroundColor = self.backgroundView.backgroundColor;
            self.textLabel.textColor = [UIColor blackColor];
            
            _sortIndicatorImage = [[UIImageView alloc] init];
            _sortIndicatorImage.contentMode = UIViewContentModeCenter;
            _sortIndicatorImage.hidden = YES;
            [self addSubview:_sortIndicatorImage];
        } else {
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
            
            self.textLabel.font = [UIFont boldSystemFontOfSize:18];
            self.textLabel.opaque = NO;
            self.textLabel.backgroundColor = nil;
            self.textLabel.textColor = [UIColor whiteColor];
            self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
            self.textLabel.shadowOffset = CGSizeMake(0, 1);
            self.textLabel.highlightedTextColor = [UIColor whiteColor];
        }
    }
    return self;
}

#pragma mark - Ovverides

- (BOOL)hasSeparators
{
    return NO;
}

- (void)updateSortIndicator:(MDSpreadViewCellSortIndicator)sortIndicator sortAxis:(MDSpreadViewSortAxis)sortAxis
{
    if (sortIndicator == MDSpreadViewCellSortIndicatorAscending) {
        _sortIndicatorImage.hidden = !self.selected;
        _sortIndicatorImage.image = (sortAxis == MDSpreadViewSortBoth) ? [[self class] _defaultDiagonalAscendingSortImage] : (sortAxis == MDSpreadViewSortColumns) ? [[self class] _defaultHorizontalAscendingSortImage] : [[self class] _defaultVerticalAscendingSortImage];
    } else if (sortIndicator == MDSpreadViewCellSortIndicatorDescending) {
        _sortIndicatorImage.hidden = !self.selected;
        _sortIndicatorImage.image = (sortAxis == MDSpreadViewSortBoth) ? [[self class] _defaultDiagonalDescendingSortImage] : (sortAxis == MDSpreadViewSortColumns) ? [[self class] _defaultHorizontalDescendingSortImage] : [[self class] _defaultVerticalDescendingSortImage];
    } else {
        _sortIndicatorImage.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _sortIndicatorImage.frame = CGRectMake(bounds.size.width - 32, 0, 32, bounds.size.height);
    
    if (self.selected && !self.sortIndicatorImage.hidden) {
        if (bounds.size.width - 28 - 32 > 42) {
            self.textLabel.frame = CGRectMake(14, 2, bounds.size.width - 28 - 32, bounds.size.height - 3);
        } else {
            self.textLabel.frame = CGRectMake(2, 2, bounds.size.width - 18, bounds.size.height - 3);
            _sortIndicatorImage.frame = CGRectMake(bounds.size.width - 26, 0, 32, bounds.size.height);
        }
    } else {
        self.textLabel.frame = CGRectMake(14, 2, bounds.size.width - 28, bounds.size.height - 3);
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.sortDescriptorPrototype = nil;
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView
{
    if (_originalSelectedBackground != selectedBackgroundView) {
        _originalSelectedBackground = nil;
    }
    
    [super setSelectedBackgroundView:selectedBackgroundView];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _originalSelectedBackground.backgroundColor = [self.tintColor colorWithAlphaComponent:0.65];
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

#pragma mark - Sort Images

+ (UIImage *)_defaultVerticalAscendingSortImage
{
    static UIImage *returnImage = nil;
    if (!returnImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0);
        
        [[UIColor colorWithWhite:0 alpha:0.4] setStroke];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineJoinMiter;
        bezierPath.lineCapStyle = kCGLineCapButt;
        bezierPath.lineWidth = 2;
        
        [bezierPath moveToPoint:CGPointMake(10, 13)];
        [bezierPath addLineToPoint:CGPointMake(16, 19)];
        [bezierPath addLineToPoint:CGPointMake(22, 13)];
        
        [bezierPath stroke];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return returnImage;
}

+ (UIImage *)_defaultVerticalDescendingSortImage
{
    static UIImage *returnImage = nil;
    if (!returnImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0);
        
        [[UIColor colorWithWhite:0 alpha:0.4] setStroke];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineJoinMiter;
        bezierPath.lineCapStyle = kCGLineCapButt;
        bezierPath.lineWidth = 2;
        
        [bezierPath moveToPoint:CGPointMake(10, 19)];
        [bezierPath addLineToPoint:CGPointMake(16, 13)];
        [bezierPath addLineToPoint:CGPointMake(22, 19)];
        
        [bezierPath stroke];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return returnImage;
}

+ (UIImage *)_defaultHorizontalAscendingSortImage
{
    static UIImage *returnImage = nil;
    if (!returnImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0);
        
        [[UIColor colorWithWhite:0 alpha:0.4] setStroke];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineJoinMiter;
        bezierPath.lineCapStyle = kCGLineCapButt;
        bezierPath.lineWidth = 2;
        
        [bezierPath moveToPoint:CGPointMake(13, 10)];
        [bezierPath addLineToPoint:CGPointMake(19, 16)];
        [bezierPath addLineToPoint:CGPointMake(13, 22)];
        
        [bezierPath stroke];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return returnImage;
}

+ (UIImage *)_defaultHorizontalDescendingSortImage
{
    static UIImage *returnImage = nil;
    if (!returnImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0);
        
        [[UIColor colorWithWhite:0 alpha:0.4] setStroke];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineJoinMiter;
        bezierPath.lineCapStyle = kCGLineCapButt;
        bezierPath.lineWidth = 2;
        
        [bezierPath moveToPoint:CGPointMake(19, 10)];
        [bezierPath addLineToPoint:CGPointMake(13, 16)];
        [bezierPath addLineToPoint:CGPointMake(19, 22)];
        
        [bezierPath stroke];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return returnImage;
}

+ (UIImage *)_defaultDiagonalAscendingSortImage
{
    static UIImage *returnImage = nil;
    if (!returnImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0);
        
        [[UIColor colorWithWhite:0 alpha:0.4] setStroke];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineJoinMiter;
        bezierPath.lineCapStyle = kCGLineCapButt;
        bezierPath.lineWidth = 2;
        
        [bezierPath moveToPoint:CGPointMake(12, 20)];
        [bezierPath addLineToPoint:CGPointMake(20, 20)];
        [bezierPath addLineToPoint:CGPointMake(20, 12)];
        
        [bezierPath stroke];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return returnImage;
}

+ (UIImage *)_defaultDiagonalDescendingSortImage
{
    static UIImage *returnImage = nil;
    if (!returnImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0);
        
        [[UIColor colorWithWhite:0 alpha:0.4] setStroke];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineJoinMiter;
        bezierPath.lineCapStyle = kCGLineCapButt;
        bezierPath.lineWidth = 2;
        
        [bezierPath moveToPoint:CGPointMake(20, 12)];
        [bezierPath addLineToPoint:CGPointMake(12, 12)];
        [bezierPath addLineToPoint:CGPointMake(12, 20)];
        
        [bezierPath stroke];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return returnImage;
}

@end
