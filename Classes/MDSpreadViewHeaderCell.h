//
//  MDSpreadViewHeaderCell.h
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2011 Mochi Development, Inc. All rights reserved.
//

#import "MDSpreadViewCell.h"

typedef enum {
    MDSpreadViewHeaderCellStyleCorner,
    MDSpreadViewHeaderCellStyleRow,
    MDSpreadViewHeaderCellStyleColumn
} MDSpreadViewHeaderCellStyle;

@interface MDSpreadViewHeaderCell : MDSpreadViewCell

- (id)initWithStyle:(MDSpreadViewHeaderCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
