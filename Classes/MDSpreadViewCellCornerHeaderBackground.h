//
//  MDSpreadViewCellCornerHeaderBackground.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/16/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpreadViewCellBackground.h"

@interface MDSpreadViewCellCornerHeaderBackground : MDSpreadViewCellBackground {
	UIImageView *backgroundTopLeft;
	UIImageView *backgroundBottomLeft;
	UIImageView *backgroundTopRight;
	UIImageView *backgroundBottomRight;
}

@end
