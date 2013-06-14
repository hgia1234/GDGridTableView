//
//  SHCTableView.h
//  ClearStyle
//
//  Created by Gia on 12/19/12.
//  Copyright (c) 2012 Gia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDGridCell;

@protocol GDGridTableViewDataSource <NSObject>
-(NSInteger)numberOfCells;
-(UIView *)cellForIndex:(NSInteger)index;
- (float)heightOfCellAtIndex:(NSInteger)index;
- (float)widthOfCell;

@end

@interface GDGridTableView : UIScrollView

// the object that acts as the data source for this table
@property (nonatomic, assign) id<GDGridTableViewDataSource> dataSource;
// the UIScrollView that hosts the table contents
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic) UIEdgeInsets cellMargin;

// dequeues a cell that can be reused
-(UIView*)dequeueReusableCell;

// registers a class for use as new cells
-(void)registerClassForCells:(Class)cellClass;

// an array of cells that are currently visible, sorted from top to bottom.
-(NSArray*)visibleCells;
-(NSArray *)indexPathsForVisibleCells;
-(int)indexForFirstFullyVisibleCells;
- (GDGridCell *)cellForRowAtIndex:(int)index;// returns nil if cell is not visible or index path is out of range
// forces the table to dispose of all the cells and re-build the table.
-(void)reloadData;

- (void)insertRowsAtIndexPath:(int)index;
- (void)deleteRowsAtIndexPaths:(int)index;

- (void)beginUpdates;
- (void)endUpdates;

- (void)scrollToCellAtIndex:(int)index animation:(BOOL)animation;


@end
