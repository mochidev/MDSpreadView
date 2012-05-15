//
//  MDSpreadViewCell.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
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

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

typedef enum {
    MDSpreadViewCellStyleDefault
} MDSpreadViewCellStyle;

@interface MDSpreadViewCell : UIView {
  @private
    UIView *backgroundView; // default is UIImageView
    UIView *highlightedBackgroundView;
    UILabel *textLabel;
    UILabel *detailTextLabel;
    NSString *reuseIdentifier;
    BOOL highlighted;
    NSInteger style;
	
    id objectValue;
	NSArray *indexes;

    UITapGestureRecognizer *tapGesture;
}

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *highlightedBackgroundView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UILabel *detailTextLabel;
@property (nonatomic, retain) id objectValue;
@property (nonatomic, readonly) NSInteger style;
@property (nonatomic, retain) NSArray *indexes;
@property (nonatomic, readonly) UITapGestureRecognizer *tapGesture;


- (id)initWithStyle:(MDSpreadViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
- (void)prepareForReuse;

@property (nonatomic, getter=isHighlighted) BOOL highlighted; 
- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated;  

@end
