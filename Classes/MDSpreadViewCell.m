//
//  MDSpreadViewCell.m
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

#import "MDSpreadViewCell.h"
#import "MDSpreadView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface MDSpreadViewCellTapGestureRecognizer : UIGestureRecognizer {
    CGPoint touchDown;
}

@end

@implementation MDSpreadViewCellTapGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.state = UIGestureRecognizerStateBegan;
    touchDown = [[touches anyObject] locationInView:self.view.window];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint newPoint = [[touches anyObject] locationInView:self.view.window];
    if (fabs(touchDown.x - newPoint.x) > 5 || fabs(touchDown.y - newPoint.y) > 5) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

@end

@interface MDSpreadViewCell () {
    UIView *_originalSelectedBackground;
}

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, readwrite, weak) MDSpreadView *spreadView;
@property (nonatomic, retain) MDSortDescriptor *sortDescriptorPrototype;
@property (nonatomic) MDSpreadViewSortAxis defaultSortAxis;
@property (nonatomic) MDSpreadViewCellSortIndicator _sortIndicator;
@property (nonatomic) MDSpreadViewSortAxis _sortAxis;
- (void)_setSortIndicator:(MDSpreadViewCellSortIndicator)_sortIndicator sortAxis:(MDSpreadViewSortAxis)_sortAxis;

@property (nonatomic, readonly) UIGestureRecognizer *_tapGesture;
@property (nonatomic, retain) MDIndexPath *_rowPath;
@property (nonatomic, retain) MDIndexPath *_columnPath;
@property (nonatomic) CGRect _pureFrame;

@end

@interface MDSpreadView ()

- (BOOL)_touchesBeganInCell:(MDSpreadViewCell *)cell;
- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell;
- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell;
- (UIImage *)_separatorImage;

@end

@implementation MDSpreadViewCell

@synthesize backgroundView, highlighted, highlightedBackgroundView, reuseIdentifier, textLabel, detailTextLabel, style, objectValue, _tapGesture, spreadView, _rowPath, _columnPath, _pureFrame;

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"_MDDefaultCell"];
}

- (instancetype)initWithStyle:(MDSpreadViewCellStyle)aStyle reuseIdentifier:(NSString *)aReuseIdentifier
{
    if (!aReuseIdentifier) return nil;
    if (self = [super initWithFrame:CGRectZero]) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.reuseIdentifier = aReuseIdentifier;
        self.multipleTouchEnabled = YES;
        //        self.layer.shouldRasterize = YES;
        //        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        style = aStyle;
        _selectionStyle = MDSpreadViewCellSelectionStyleDefault;
        
        if (NSClassFromString(@"UIMotionEffect")) {
            
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MDSpreadViewCell.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)]];
//            self.backgroundView = imageView;
            
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
            self.highlightedBackgroundView = view;
            
            UIView *selectedView = [[UIView alloc] init];
            _originalSelectedBackground = selectedView;
            selectedView.backgroundColor = [self.tintColor colorWithAlphaComponent:0.15];
            self.selectedBackgroundView = selectedView;
            
            UILabel *label = [[UILabel alloc] init];
            label.opaque = YES;
            label.backgroundColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:16];
            label.highlightedTextColor = [UIColor blackColor];
            self.textLabel = label;
            
            label = [[UILabel alloc] init];
            label.opaque = YES;
            label.backgroundColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:16];
            label.highlightedTextColor = [UIColor blackColor];
            self.detailTextLabel = label;
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MDSpreadViewCell.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)]];
            self.backgroundView = imageView;
            
            imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MDSpreadViewCellSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)]];
            self.highlightedBackgroundView = imageView;
            
            UILabel *label = [[UILabel alloc] init];
            label.opaque = YES;
            label.backgroundColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:18];
            label.highlightedTextColor = [UIColor blackColor];
            self.textLabel = label;
            
            label = [[UILabel alloc] init];
            label.opaque = YES;
            label.backgroundColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:18];
            label.highlightedTextColor = [UIColor blackColor];
            self.detailTextLabel = label;
        }
        
        if ([self hasSeparators]) {
            separators = [[UIImageView alloc] initWithFrame:self.bounds];
            [self addSubview:separators];
        }
        
        _tapGesture = [[MDSpreadViewCellTapGestureRecognizer alloc] init];
        _tapGesture.cancelsTouchesInView = NO;
        _tapGesture.delaysTouchesEnded = NO;
        _tapGesture.delegate = self;
        [_tapGesture addTarget:self action:@selector(_handleTap:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)dealloc {
    [self removeGestureRecognizer: _tapGesture];
    _tapGesture.delegate = nil;
}

- (void)setSpreadView:(MDSpreadView *)aSpreadView
{
    spreadView = aSpreadView;
    
    separators.image = [spreadView _separatorImage];
}

- (void)_updateSeparators
{
    separators.image = [spreadView _separatorImage];
}

- (BOOL)hasSeparators
{
    return YES;
}

- (void)setReuseIdentifier:(NSString *)anIdentifier
{
    if (reuseIdentifier != anIdentifier) {
        reuseIdentifier = anIdentifier;
        
        _reuseHash = [reuseIdentifier hash];
    }
}

- (void)_handleTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _shouldCancelTouches = ![spreadView _touchesBeganInCell:self];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (!_shouldCancelTouches)
            [spreadView _touchesEndedInCell:self];
        
        _shouldCancelTouches = NO;
    } else if (gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        if (!_shouldCancelTouches)
            [spreadView _touchesCancelledInCell:self];
        
        _shouldCancelTouches = NO;
    }
}

#pragma mark - Sorting

- (void)_setSortIndicator:(MDSpreadViewCellSortIndicator)_sortIndicator sortAxis:(MDSpreadViewSortAxis)_sortAxis;
{
    self._sortIndicator = _sortIndicator;
    self._sortAxis = _sortAxis;
    
    [self updateSortIndicator:__sortIndicator sortAxis:__sortAxis];
}

- (void)updateSortIndicator:(MDSpreadViewCellSortIndicator)sortIndicator sortAxis:(MDSpreadViewSortAxis)sortAxis
{
    
}

#pragma mark - Background Views

- (void)setBackgroundView:(UIView *)aBackgroundView
{
    [backgroundView removeFromSuperview];
    backgroundView = aBackgroundView;
    
    [self insertSubview:backgroundView atIndex:0];
    [self setNeedsLayout];
}

- (void)setHighlightedBackgroundView:(UIView *)aHighlightedBackgroundView
{
    [highlightedBackgroundView removeFromSuperview];
    highlightedBackgroundView = aHighlightedBackgroundView;
    
    if (highlighted) {
        highlightedBackgroundView.alpha = 1;
        highlightedBackgroundView.hidden = NO;
    } else {
        highlightedBackgroundView.alpha = 0;
        highlightedBackgroundView.hidden = YES;
    }
    
    if (_selectedBackgroundView) {
        [self insertSubview:highlightedBackgroundView aboveSubview:_selectedBackgroundView];
    } else if (backgroundView) {
        [self insertSubview:highlightedBackgroundView aboveSubview:backgroundView];
    } else {
        [self insertSubview:highlightedBackgroundView atIndex:0];
    }
    
    [self setNeedsLayout];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView
{
    [_selectedBackgroundView removeFromSuperview];
    _selectedBackgroundView = selectedBackgroundView;
    
    if (_originalSelectedBackground != selectedBackgroundView) {
        _originalSelectedBackground = nil;
    }
    
    if (_selected) {
        _selectedBackgroundView.alpha = 1;
        _selectedBackgroundView.hidden = NO;
    } else {
        _selectedBackgroundView.alpha = 0;
        _selectedBackgroundView.hidden = YES;
    }
    
    if (backgroundView) {
        [self insertSubview:_selectedBackgroundView aboveSubview:backgroundView];
    } else {
        [self insertSubview:_selectedBackgroundView atIndex:0];
    }
    
    [self setNeedsLayout];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _originalSelectedBackground.backgroundColor = [self.tintColor colorWithAlphaComponent:0.15];
}

#pragma mark - Content Views

- (void)setTextLabel:(UILabel *)aTextLabel
{
    [textLabel removeFromSuperview];
    textLabel = aTextLabel;
    
    textLabel.highlighted = highlighted;
    [self addSubview:textLabel];
    [self setNeedsLayout];
}

- (void)setDetailTextLabel:(UILabel *)aTextLabel
{
    [detailTextLabel removeFromSuperview];
    detailTextLabel = aTextLabel;
    
    detailTextLabel.highlighted = highlighted;
    [self addSubview:detailTextLabel];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    backgroundView.frame = bounds;
    highlightedBackgroundView.frame = bounds;
    _selectedBackgroundView.frame = bounds;
    separators.frame = bounds;
    
    CGRect textLabelFrame = CGRectMake(10, 2, bounds.size.width-20, bounds.size.height-3);
    if (bounds.size.width < 20) {
        textLabelFrame.origin.x = 0;
        textLabelFrame.size.width = bounds.size.width;
    }
    if (bounds.size.height < 3) {
        textLabelFrame.origin.y = 0;
        textLabelFrame.size.height = bounds.size.height;
    }
    textLabel.frame = textLabelFrame;
}

- (void)prepareForReuse
{
    self.highlighted = NO;
    self.selected = NO;
    self.sortDescriptorPrototype = nil;
    self._sortIndicator = MDSpreadViewCellSortIndicatorNone;
//    self.objectValue = nil;
//    self.textLabel.text = nil;
//    self.detailTextLabel.text = nil;
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(self.frame, frame))
        [super setFrame:frame];
}

- (void)set_pureFrame:(CGRect)pureFrame
{
    _pureFrame = pureFrame;
    self.frame = _pureFrame;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    if (!backgroundView && (!(highlighted || _selected) || _selectionStyle == MDSpreadViewCellSelectionStyleNone)) {
        textLabel.opaque = (self.backgroundColor && self.backgroundColor != [UIColor clearColor]);
        detailTextLabel.opaque = (self.backgroundColor && self.backgroundColor != [UIColor clearColor]);
        
        textLabel.backgroundColor = self.backgroundColor;
        detailTextLabel.backgroundColor = self.backgroundColor;
    } else {
        textLabel.opaque = NO;
        detailTextLabel.opaque = NO;
        
        textLabel.backgroundColor = [UIColor clearColor];
        detailTextLabel.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - State

- (void)setHighlighted:(BOOL)isHighlighted
{
    [self setHighlighted:isHighlighted animated:NO];
}

- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated
{
    if (highlighted != isHighlighted) {
        highlighted = isHighlighted;
        
        void (^animations)(void) = NULL;
        
        if (highlighted && _selectionStyle > MDSpreadViewCellSelectionStyleNone) {
            highlightedBackgroundView.hidden = NO;
            
            animations = ^() {
                highlightedBackgroundView.alpha = 1;
                textLabel.highlighted = YES;
                detailTextLabel.highlighted = YES;
                [self layoutIfNeeded];
            };
        } else {
            animations = ^() {
                highlightedBackgroundView.alpha = 0;
                textLabel.highlighted = NO;
                detailTextLabel.highlighted = NO;
                [self layoutIfNeeded];
            };
        }
        
        void (^completion)(BOOL) = NULL;
        
        if ((highlighted || _selected) && _selectionStyle > MDSpreadViewCellSelectionStyleNone) {
            textLabel.opaque = NO;
            detailTextLabel.opaque = NO;
            
            textLabel.backgroundColor = [UIColor clearColor];
            detailTextLabel.backgroundColor = [UIColor clearColor];
            
            completion = ^(BOOL finished) {
                if (!highlighted || _selectionStyle == MDSpreadViewCellSelectionStyleNone) {
                    highlightedBackgroundView.hidden = YES;
                }
            };
        } else {
            completion = ^(BOOL finished) {
                if (finished && !backgroundView && (!(highlighted || _selected) || _selectionStyle == MDSpreadViewCellSelectionStyleNone)) {
                    textLabel.opaque = (self.backgroundColor && self.backgroundColor != [UIColor clearColor]);
                    detailTextLabel.opaque = (self.backgroundColor && self.backgroundColor != [UIColor clearColor]);
                    
                    textLabel.backgroundColor = self.backgroundColor;
                    detailTextLabel.backgroundColor = self.backgroundColor;
                }
            };
        }
        
        if (animated) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
        } else {
            animations();
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)isSelected animated:(BOOL)animated
{
    if (_selected != isSelected) {
        _selected = isSelected;
        
        void (^animations)(void) = NULL;
        
        if (_selected && _selectionStyle > MDSpreadViewCellSelectionStyleNone) {
            _selectedBackgroundView.hidden = NO;
            
            animations = ^() {
                _selectedBackgroundView.alpha = 1;
                [self layoutIfNeeded];
            };
        } else {
            animations = ^() {
                _selectedBackgroundView.alpha = 0;
                [self layoutIfNeeded];
            };
        }
        
        void (^completion)(BOOL) = NULL;
        
        if ((highlighted || _selected) && _selectionStyle > MDSpreadViewCellSelectionStyleNone) {
            textLabel.opaque = NO;
            detailTextLabel.opaque = NO;
            
            textLabel.backgroundColor = [UIColor clearColor];
            detailTextLabel.backgroundColor = [UIColor clearColor];
            
            completion = ^(BOOL finished) {
                if (!_selected || _selectionStyle == MDSpreadViewCellSelectionStyleNone) {
                    _selectedBackgroundView.hidden = YES;
                }
            };
        } else {
            completion = ^(BOOL finished) {
                if (finished && !backgroundView && (!(highlighted || _selected) || _selectionStyle == MDSpreadViewCellSelectionStyleNone)) {
                    textLabel.opaque = (self.backgroundColor && self.backgroundColor != [UIColor clearColor]);
                    detailTextLabel.opaque = (self.backgroundColor && self.backgroundColor != [UIColor clearColor]);
                    
                    textLabel.backgroundColor = self.backgroundColor;
                    detailTextLabel.backgroundColor = self.backgroundColor;
                }
                
                if (!_selected || _selectionStyle == MDSpreadViewCellSelectionStyleNone) {
                    _selectedBackgroundView.hidden = YES;
                }
            };
        }
        
        if (animated) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
        } else {
            animations();
        }
        
        [self updateSortIndicator:__sortIndicator sortAxis:__sortAxis];
    }
}

- (void)setSelectionStyle:(MDSpreadViewCellSelectionStyle)selectionStyle
{
    if (_selectionStyle != selectionStyle) {
        _selectionStyle = selectionStyle;
        
        if (_selected && _selectionStyle > MDSpreadViewCellSelectionStyleNone) {
            _selectedBackgroundView.alpha = 1;
            _selectedBackgroundView.hidden = NO;
        } else {
            _selectedBackgroundView.alpha = 0;
            _selectedBackgroundView.hidden = YES;
        }
    }
}

#pragma mark - Value

- (void)setObjectValue:(id)anObject
{
    if (anObject != objectValue) {
        objectValue = anObject;
    
        if ([objectValue respondsToSelector:@selector(description)]) {
            self.textLabel.text = [objectValue description];
        }
    }
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    if (detailTextLabel.text) {
        return [NSString stringWithFormat:@"%@, %@", self.detailTextLabel.text, self.textLabel.text];
    }
    
    return textLabel.text;
}

- (NSString *)accessibilityHint
{
    return @"Double tap to show more information.";
}

- (UIAccessibilityTraits)accessibilityTraits
{
    if (self.highlighted) {
        return UIAccessibilityTraitSelected;
    }
    return UIAccessibilityTraitNone;
}

@end
