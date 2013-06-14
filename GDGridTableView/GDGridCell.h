//
//  GDGridCell.h
//  TestGridFitTableView
//
//  Created by Gia on 2/27/13.
//  Copyright (c) 2013 Gia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDGridCell : UIView

@property (nonatomic) int index;
@property (nonatomic) BOOL loaded;

+ (float)cellHeight:(id)data;

@end
