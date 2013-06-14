//
//  GDGridCell.m
//  TestGridFitTableView
//
//  Created by Gia on 2/27/13.
//  Copyright (c) 2013 Gia. All rights reserved.
//

#import "GDGridCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GDGridCell

- (id)init{
    self = [super initWithFrame:CGRectMake(0, 0, 160, 0)];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
}

+ (float)cellHeight:(id)data{
    return 0;
    
}


- (void)updateView:(id)data{
    
}

@end
