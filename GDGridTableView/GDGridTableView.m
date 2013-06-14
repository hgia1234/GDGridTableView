//
//  SHCTableView.m
//  ClearStyle
//
//  Created by Gia on 12/19/12.
//  Copyright (c) 2012 Gia. All rights reserved.
//

#import "GDGridTableView.h"
#import "GDGridCell.h"

@interface GDGridTableView()


@property (nonatomic) float cellWidth;

@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, strong) NSMutableArray *insertIndexes;

@end

@implementation GDGridTableView {
    // a set of cells that are reuseable
    NSMutableSet* _reuseCells;
    // the Class which indicates the cell type
    Class _cellClass;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.alwaysBounceVertical = YES;
        self.bounces = YES;
        _reuseCells = [[NSMutableSet alloc] init];
        
    }
    return self;
}

- (void)setTableHeaderView:(UIView *)tableHeaderView{
    CGSize contentSize = self.contentSize;
    if (_tableHeaderView) {
        [_tableHeaderView removeFromSuperview];
        contentSize.height -= _tableHeaderView.frame.size.height;
    }
    _tableHeaderView = tableHeaderView;
    if (_tableHeaderView != nil) {
        [self addSubview:_tableHeaderView];
        contentSize.height += _tableHeaderView.frame.size.height;
    }
    self.contentSize = contentSize;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self refreshView];
}


- (void)reloadFrames{
    self.cellWidth = [_dataSource widthOfCell];
    int numberOfCells = [_dataSource numberOfCells];
    self.frames = [NSMutableArray arrayWithCapacity:numberOfCells];
    
    
    CGFloat lastLeftHeight = 0;
    CGFloat lastRightHeight = 0;
    for (int i = 0; i < numberOfCells; i++) {
        CGRect frame = CGRectZero;
        frame.size.height = [_dataSource heightOfCellAtIndex:i];
        frame.size.width = self.cellWidth;
        if (i == 0) {
            frame.origin.x = self.cellMargin.left + self.contentInset.left;
            frame.origin.y = self.tableHeaderView.frame.size.height + self.contentInset.top + self.cellMargin.top;
            
            lastLeftHeight = frame.origin.y + frame.size.height + self.cellMargin.bottom;
            lastRightHeight = self.tableHeaderView.frame.size.height + self.contentInset.top;
            
        }else{
            
            if (lastRightHeight >= lastLeftHeight) {
                //put cell to the left
                frame.origin.x = self.cellMargin.left + self.contentInset.left;
                frame.origin.y = lastLeftHeight + self.cellMargin.top;
                lastLeftHeight = frame.origin.y + frame.size.height + self.cellMargin.bottom;
            }else{
                //put cell to the right
                frame.origin.x = self.contentInset.left +
                self.cellMargin.left + self.cellWidth + self.cellMargin.right +
                self.cellMargin.left;
                
                frame.origin.y = lastRightHeight + self.cellMargin.top;
                lastRightHeight = frame.origin.y + frame.size.height + self.cellMargin.bottom;
            }
        }
        [self.frames addObject:NSStringFromCGRect(frame)];
    }
}

- (CGRect)frameOfCell:(int)index{
    if (index >= self.frames.count) {
        if (index < [_dataSource numberOfCells]) {
            [self reloadFrames];
        }else{
            return CGRectZero;
        }
    }
    CGRect frame = CGRectFromString(self.frames[index]);
    return frame;
}

- (GDGridCell *)cellForRowAtIndex:(int)index{
    for (GDGridCell *cell in [self visibleCells]) {
        if (cell.index == index) {
            return cell;
        }
    }
    return nil;
}

// based on the current scroll location, recycles off-screen cells and
// creates new ones to fill the empty space.
-(void) refreshView {
    // set the scrollview height
    int numberOfCells = [_dataSource numberOfCells];
    
    // remove cells that are no longer visible
    
    for (UIView* cell in self.subviews) {
        if (![cell isKindOfClass:[GDGridCell class]]) {
            continue;
        }
        // is the cell off the top of the scrollview?
        if (cell.frame.origin.y + cell.frame.size.height  < self.contentOffset.y) {
            [self recycleCell:cell];
        }
        // is the cell off the bottom of the scrollview?
        if (cell.frame.origin.y > self.contentOffset.y + self.frame.size.height ) {
            [self recycleCell:cell];
        }
    }
    
    
    float maxHeight = 0;
    
    float yVisible = self.contentOffset.y;
    float endYVisible = yVisible + self.frame.size.height;
    if (self.frames.count != numberOfCells) {
        [self reloadFrames];
    }
    
    int i = 0;
    for (NSString *frameString in self.frames) {
        CGRect frame = CGRectFromString(frameString);
        float y = frame.origin.y;
        float endY = CGRectGetMaxY(frame);
        
        if (endY > maxHeight) {
            maxHeight = endY;
        }
        
        if (yVisible < endY && y < endYVisible) {
            
            GDGridCell* cell = [self cellForFrame:frame];
            
            if (!cell) {
                // create a new cell and add to the scrollview
                cell = (GDGridCell *)[_dataSource cellForIndex:i];
                cell.index = i;
                cell.frame = frame;
                [self insertSubview:cell atIndex:0];
            }
        }
        i++;
    }
    
    
    float contentHeight = maxHeight;
    self.contentSize = CGSizeMake(self.bounds.size.width,
                                  contentHeight);
}

// recycles a cell by adding it the set of reuse cells and removing it from the view
-(void) recycleCell:(UIView*)cell {
    [_reuseCells addObject:cell];
    [cell removeFromSuperview];
}

// returns the cell for the given frame, or nil if it doesn't exist
-(GDGridCell*) cellForFrame:(CGRect)frame {
    for (GDGridCell* cell in [self cellSubviews]) {
        if (CGRectEqualToRect(frame, cell.frame)) {
            return cell;
        }
    }
    return nil;
}

// returns the cell for the given row, or nil if it doesn't exist
-(UIView*) cellForIndex:(NSInteger)index {
    CGRect cellFrame = [self frameOfCell:index];
    for (UIView* cell in [self cellSubviews]) {
        if (CGRectEqualToRect(cellFrame, cell.frame)) {
            return cell;
        }
    }
    return nil;
}

// the scrollView subviews that are cells
-(NSArray*)cellSubviews {
    NSMutableArray* cells = [[NSMutableArray alloc] init];
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[GDGridCell class]]) {
            [cells addObject:subView];
        }
    }
    return cells;
}

-(void)registerClassForCells:(Class)cellClass {
    _cellClass = cellClass;
}

-(UIView*)dequeueReusableCell {
    // first obtain a cell from the reuse pool
    UIView* cell = [_reuseCells anyObject];
    if (cell) {
        //        NSLog(@"Returning a cell from the pool");
        [_reuseCells removeObject:cell];
    }
    // otherwise create a new cell
    if (!cell) {
        //        NSLog(@"Creating a new cell");
        cell = [[_cellClass alloc] init];
        cell.autoresizingMask = UIViewAutoresizingNone;
    }
    return cell;
}

#pragma mark - property setters
-(void)setDataSource:(id<GDGridTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self refreshView];
}


-(NSArray*) visibleCells {
    NSMutableArray* cells = [[NSMutableArray alloc] init];
    for (UIView* subView in [self cellSubviews]) {
        [cells addObject:subView];
    }
    NSArray* sortedCells = [cells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView* view1 = (UIView*)obj1;
        UIView* view2 = (UIView*)obj2;
        float resultY = view2.frame.origin.y - view1.frame.origin.y;
        float resultX = view2.frame.origin.x - view1.frame.origin.x;
        if (resultY > 0.0) {
            return NSOrderedAscending;
        } else if (resultY < 0.0){
            return NSOrderedDescending;
        } else {
            if (resultX > 0) {
                return NSOrderedAscending;
                
            }else if(resultX < 0){
                return NSOrderedDescending;
                
            }else{
                return NSOrderedSame;
                
            }
        }
    }];
    return sortedCells;
}


-(NSArray *)indexPathsForVisibleCells{
    NSArray *visibleCells = [self visibleCells];
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:visibleCells.count];
    for (GDGridCell *cell in visibleCells) {
        [indexes addObject:@(cell.index)];
    }
    return indexes;
}


-(int)indexForFirstFullyVisibleCells{
    NSArray *visibleCells = [self visibleCells];
    for (GDGridCell *cell in visibleCells) {
        if(cell.frame.origin.y>=self.contentOffset.y){
            return cell.index;
        }
    }
    return 0;
}

-(void)reloadData {
    // remove all subviews
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self reloadFrames];
    for (UIView *cell in [self cellSubviews]) {
        [self recycleCell:cell];
    }
    [self refreshView];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

#pragma mark - insert delete


- (void)insertRowsAtIndexPath:(int)index{
    [self.insertIndexes addObject:@(index)];
    
}

- (void)deleteRowsAtIndexPaths:(int)index{
    float delay = 0.0;
    
    // find the visible cells
    NSArray* visibleCells = [self visibleCells];
    bool startAnimating = false;
    
    // iterate over all of the cells
    int cellIndex = 0;
    for(GDGridCell* cell in visibleCells) {
        if (startAnimating) {
            [UIView animateWithDuration:0.3
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cell.frame = [self frameOfCell:cellIndex];
                             }
                             completion:^(BOOL finished){
                                 
                             }];
            delay+=0.03;
            cellIndex++;
        }else{
            // if you have reached the item that was deleted, start animating
            if (cell.index == index) {
                startAnimating = true;
                cell.hidden = YES;
                cellIndex = index;
            }
            
        }
        
    }
    
}

- (void)beginUpdates{
    [self reloadFrames];
    self.insertIndexes = nil;
    self.insertIndexes = [NSMutableArray array];
}


- (void)endUpdates{
    if (self.insertIndexes.count == 1) {
        [self reloadFrames];
        int index = [self.insertIndexes[0] intValue];
        int i = 0;
        for (NSString *frameString in self.frames) {
            i++;
        }
        
        NSArray* visibleCells = [self visibleCells];
        GDGridCell *lastCell = visibleCells.lastObject;
        if (lastCell && index > lastCell.index) {
            return;
        }
        float delay = 0;
        GDGridCell* insertCell = (GDGridCell *)[_dataSource cellForIndex:index];
        insertCell.index = index;
        insertCell.frame = [self frameOfCell:index];
        insertCell.alpha = 0;
        if (!insertCell.superview) {
            [self insertSubview:insertCell atIndex:0];
        }
        if (visibleCells.count == 0) {
            [UIView animateWithDuration:0.3
                                  delay:delay
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                     insertCell.alpha = 1;
                                 
                             }
                             completion:^(BOOL finished) {
                                     [self refreshView];
                                 
                             }];
        }else{
            for(GDGridCell* cell in visibleCells) {
                if (cell.index >= index) {
                    [UIView animateWithDuration:0.3
                                          delay:delay
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         cell.frame = [self frameOfCell:cell.index+1];
                                         if (cell == lastCell) {
                                             insertCell.alpha = 1;
                                         }
                                         NSLog(@"move index %d to %@",cell.index,NSStringFromCGRect(cell.frame));
                                         
                                     }
                                     completion:^(BOOL finished) {
                                         if (cell == lastCell) {
                                             [self refreshView];
                                         }
                                     }];
                    delay += 0.05;
                }
            }
        }
        
    }else if(self.insertIndexes.count == 0){
        [self refreshView];
    }else{
        [self reloadData];
    }
    
}

#pragma mark - scrolling


- (void)scrollToCellAtIndex:(int)index animation:(BOOL)animation{
    if (index<self.frames.count) {
        CGRect rect = CGRectFromString(self.frames[index]);
        [self scrollRectToVisible:rect animated:animation];
    }
}


@end
