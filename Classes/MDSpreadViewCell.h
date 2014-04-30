//
//  MDSpreadViewCell.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
@class MDSpreadView, MDSortDescriptor, MDIndexPath;

typedef NS_ENUM(NSUInteger, MDSpreadViewCellStyle) {
    MDSpreadViewCellStyleDefault
};

typedef NS_ENUM(NSUInteger, MDSpreadViewCellSeparatorStyle) {
    MDSpreadViewCellSeparatorStyleNone,
    MDSpreadViewCellSeparatorStyleHorizontal,
    MDSpreadViewCellSeparatorStyleVertical,
    MDSpreadViewCellSeparatorStyleCorner
};

typedef NS_ENUM(NSUInteger, MDSpreadViewCellSelectionStyle) {
    MDSpreadViewCellSelectionStyleNone,
    MDSpreadViewCellSelectionStyleDefault
};

typedef NS_ENUM(NSUInteger, MDSpreadViewCellAccessoryType) {
    MDSpreadViewCellAccessoryNone,
    MDSpreadViewCellAccessoryDisclosureIndicator
};

typedef NS_ENUM(NSUInteger, MDSpreadViewCellSortIndicator) {
    MDSpreadViewCellSortIndicatorNone = 0,
    MDSpreadViewCellSortIndicatorAscending,
    MDSpreadViewCellSortIndicatorDescending
};

@interface MDSpreadViewCell : UIView <UIGestureRecognizerDelegate> {
  @public
    NSUInteger _reuseHash;
  @private
    UIView *backgroundView; // default is UIImageView
    UIView *highlightedBackgroundView;
    UILabel *textLabel;
    UILabel *detailTextLabel;
    NSString *reuseIdentifier;
    BOOL highlighted;
    NSInteger style;
    UIImageView *separators;
	
    id objectValue;

    MDIndexPath *_rowPath;
    MDIndexPath *_columnPath;
    UIGestureRecognizer *_tapGesture;
    BOOL _shouldCancelTouches;
}

// Designated initializer.  If the cell can be reused, you must pass in a reuse identifier.  You should use the same reuse identifier for all cells of the same form.
- (instancetype)initWithStyle:(MDSpreadViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property(nonatomic,readonly,copy) NSString *reuseIdentifier;
- (void)prepareForReuse;
// if the cell is reusable (has a reuse identifier), this is called just before the cell is returned from the table view method dequeueReusableCellWithIdentifier:.  If you override, you MUST call super.

@property (nonatomic, readonly) NSInteger style;

// Content.  These properties provide direct access to the internal label and image views used by the table view cell.  These should be used instead of the content properties below.
@property (nonatomic, readonly, retain) UIImageView *imageView __attribute__((unavailable));
// default is nil.  image view will be created if necessary.

@property (nonatomic, readonly, retain) UILabel *textLabel;
// default is nil.  label will be created if necessary.

@property (nonatomic, readonly, retain) UILabel *detailTextLabel;
// default is nil.  label will be created if necessary (and the current style supports a detail label).

// If you want to customize cells by simply adding additional views, you should add them to the content view so they will be positioned appropriately as the cell transitions into and out of editing mode.
@property (nonatomic, readonly, retain) UIView *contentView __attribute__((unavailable));

- (BOOL)hasSeparators; // returns YES. Subclasses can turn off separators completely here;

// Default is nil for cells in UITableViewStylePlain, and non-nil for UITableViewStyleGrouped. The 'backgroundView' will be added as a subview behind all other views.
@property (nonatomic, retain) UIView *backgroundView;

// Default is nil for cells in UITableViewStylePlain, and non-nil for UITableViewStyleGrouped. The 'selectedBackgroundView' will be added as a subview directly above the backgroundView if not nil, or behind all other views. It is added as a subview only when the cell is selected. Calling -setSelected:animated: will cause the 'selectedBackgroundView' to animate in and out with an alpha fade.
@property (nonatomic, retain) UIView *selectedBackgroundView;
@property (nonatomic, retain) UIView *highlightedBackgroundView;

@property (nonatomic) MDSpreadViewCellSelectionStyle selectionStyle;
// default is MDSpreadViewCellSelectionStyleDefault.
@property (nonatomic, getter=isSelected) BOOL selected;
// set selected state (title, image, background). default is NO. animated is NO
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
// set highlighted state (title, image, background). default is NO. animated is NO
- (void)setSelected:(BOOL)isSelected animated:(BOOL)animated;
// animate between regular and selected state
- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated;
// animate between regular and highlighted state

@property (nonatomic) MDSpreadViewCellAccessoryType accessoryType __attribute__((unavailable));
// default is UITableViewCellAccessoryNone. use to set standard type
@property (nonatomic, retain) UIView *accessoryView __attribute__((unavailable));
// if set, use custom view. ignore accessoryType. tracks if enabled can calls accessory action

@property (nonatomic, retain) id objectValue;
// default gets [objectValue description] and sets it on the title. To not set the title, either call super, then change the title to something else, or return nil in -textLabel.
// subclass -(void)setObjectValue:(id)anObject; calling supper to customize;
  

@end
