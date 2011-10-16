//
//  MDSpreadViewCell.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MDSpreadViewCellStyleDefault
} MDSpreadViewCellStyle;

@interface MDSpreadViewCell : UIView {
  @private
    UIView *backgroundView; // default is UIImageView
    UIView *highlightedBackgroundView;
    UILabel *textLabel;
    NSString *reuseIdentifier;
    BOOL highlighted;
    
    NSInteger style;
}

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *highlightedBackgroundView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) id objectValue;
@property (nonatomic, readonly) NSInteger style;

- (id)initWithStyle:(MDSpreadViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
- (void)prepareForReuse;

@property (nonatomic, getter=isHighlighted) BOOL highlighted; 
- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated;  

@end
