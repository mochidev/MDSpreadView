//
//  MDSpreadViewHeaderCell.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewHeaderCell.h"
#import "MDSpreadViewCellBackground.h"
#import "MDSpreadViewCellRowHeaderBackground.h"
#import "MDSpreadViewCellColumnHeaderBackground.h"
#import "MDSpreadViewCellCornerHeaderBackground.h"

@implementation MDSpreadViewHeaderCell

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
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor whiteColor];
		self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
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
    [super setHighlighted:isHighlighted animated:animated];
    
    self.textLabel.opaque = NO;
    self.textLabel.backgroundColor = [UIColor clearColor];
}

@end
