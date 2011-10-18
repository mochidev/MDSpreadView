//
//  MDSpreadViewCell.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewCell.h"

@interface MDSpreadViewCell ()

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;

@end

@implementation MDSpreadViewCell

@synthesize backgroundView, highlighted, highlightedBackgroundView, reuseIdentifier, textLabel, style, objectValue;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"_MDDefaultCell"];
}

- (id)initWithStyle:(MDSpreadViewCellStyle)aStyle reuseIdentifier:(NSString *)aReuseIdentifier
{
    if (!aReuseIdentifier) return nil;
    if (self = [super initWithFrame:CGRectZero]) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.reuseIdentifier = aReuseIdentifier;
        style = aStyle;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCell.png"]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.contentStretch = CGRectMake(1./imageView.bounds.size.width, 1./imageView.bounds.size.height, 1./imageView.bounds.size.width, 1./imageView.bounds.size.height);
        self.backgroundView = imageView;
        [imageView release];
        
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCellSelected.png"]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.contentStretch = CGRectMake(1./imageView.bounds.size.width, 1./imageView.bounds.size.height, 1./imageView.bounds.size.width, 1./imageView.bounds.size.height);
        self.highlightedBackgroundView = imageView;
        [imageView release];
        
        UILabel *label = [[UILabel alloc] init];
		label.opaque = YES;
		label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:18];
		label.highlightedTextColor = [UIColor blackColor];
        self.textLabel = label;
        [label release];
    }
    return self;
}

- (void)setBackgroundView:(UIView *)aBackgroundView
{
    [backgroundView removeFromSuperview];
    [aBackgroundView retain];
    [backgroundView release];
    backgroundView = aBackgroundView;
    
    [self insertSubview:backgroundView atIndex:0];
    [self setNeedsLayout];
}

- (void)setHighlightedBackgroundView:(UIView *)aHighlightedBackgroundView
{
    [highlightedBackgroundView removeFromSuperview];
    [aHighlightedBackgroundView retain];
    [highlightedBackgroundView release];
    highlightedBackgroundView = aHighlightedBackgroundView;
    
    if (highlighted) {
        highlightedBackgroundView.alpha = 1;
    } else {
        highlightedBackgroundView.alpha = 0;
    }
    [self insertSubview:highlightedBackgroundView aboveSubview:self.backgroundView];
    [self setNeedsLayout];
}

- (void)setTextLabel:(UILabel *)aTextLabel
{
    [textLabel removeFromSuperview];
    [aTextLabel retain];
    [textLabel release];
    textLabel = aTextLabel;
    
    textLabel.highlighted = highlighted;
    [self addSubview:textLabel];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    backgroundView.frame = self.bounds;
    highlightedBackgroundView.frame = self.bounds;
    textLabel.frame = CGRectMake(10, 2, self.bounds.size.width-20, self.bounds.size.height-3);
}

- (void)setHighlighted:(BOOL)isHighlighted
{
    [self setHighlighted:isHighlighted animated:NO];
}

- (void)prepareForReuse
{
    self.highlighted = NO;
    self.textLabel.text = nil;
}

- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated
{
    highlighted = isHighlighted;
    
    textLabel.opaque = !isHighlighted;
    if (highlighted) {
        textLabel.backgroundColor = [UIColor clearColor];
    } else {
        textLabel.backgroundColor = [UIColor whiteColor];
    }
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            if (highlighted) {
                highlightedBackgroundView.alpha = 1;
            } else {
                highlightedBackgroundView.alpha = 0;
            }
            textLabel.highlighted = highlighted;
        }];
    } else {
        if (highlighted) {
            highlightedBackgroundView.alpha = 1;
        } else {
            highlightedBackgroundView.alpha = 0;
        }
        textLabel.highlighted = highlighted;
    }
}

- (id)objectValue
{
    return self.textLabel.text;
}

- (void)setObjectValue:(id)anObject
{
    [anObject retain];
    [objectValue release];
    objectValue = anObject;
    
    if ([objectValue isKindOfClass:[NSString class]]) {
        self.textLabel.text = objectValue;
    }
}

- (void)dealloc {
    [objectValue release];
    [backgroundView release];
    [highlightedBackgroundView release];
    [textLabel release];
    [reuseIdentifier release];
    [super dealloc];
}

@end
