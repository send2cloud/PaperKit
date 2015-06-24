//
//  PKViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKViewController.h"

#pragma mark - PKForegroundCollectionViewCell

@interface PKForegroundCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIViewController *viewController;

@end

@implementation PKForegroundCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
@end

#pragma mark - PKForegroundCollectionView

@interface PKForegroundCollectionView : UICollectionView

@end

@implementation PKForegroundCollectionView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    CGPoint screenPoint = [self convertPoint:point toView:self.superview];
    
    PKForegroundCollectionViewCell *cell = (PKForegroundCollectionViewCell *)[self cellForItemAtIndexPath:[self indexPathForItemAtPoint:point]];
    PKCollectionViewController *viewController = (PKCollectionViewController *)cell.viewController;
    if (CGRectContainsPoint(viewController.collectionView.frame, screenPoint)) {
        return view;
    }
    
    return nil;
}

@end



@interface PKViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic) PKForegroundCollectionView *foregroundCollectionView;

@end

@implementation PKViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        _layout = [UICollectionViewFlowLayout new];
        _layout.minimumInteritemSpacing = 0;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = [UIScreen mainScreen].bounds.size;
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        _layout.sectionInset = UIEdgeInsetsZero;
        _selectedCategory = 0;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    
    _foregroundCollectionView = [[PKForegroundCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    _foregroundCollectionView.pagingEnabled = YES;
    _foregroundCollectionView.delegate = self;
    _foregroundCollectionView.dataSource = self;
    _foregroundCollectionView.showsHorizontalScrollIndicator = NO;
    _foregroundCollectionView.showsVerticalScrollIndicator = NO;
    _foregroundCollectionView.alwaysBounceHorizontal = NO;
    _foregroundCollectionView.alwaysBounceVertical = NO;
    _foregroundCollectionView.backgroundColor = [UIColor clearColor];
    _foregroundCollectionView.opaque = NO;
    _foregroundCollectionView.scrollEnabled = NO;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:self.layout];
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.alwaysBounceVertical = NO;
    
    [self.view addSubview:_collectionView];
    [self.view addSubview:_foregroundCollectionView];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.foregroundCollectionView registerClass:[PKForegroundCollectionViewCell class] forCellWithReuseIdentifier:@"PKForegroundCollectionViewCell"];
    
}

- (void)viewWillLayoutSubviews
{
    _collectionView.contentInset = UIEdgeInsetsZero;
    _foregroundCollectionView.contentInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PKCollectionViewController *)viewControllerAtIndex:(NSInteger)index
{
    PKForegroundCollectionViewCell *cell = (PKForegroundCollectionViewCell *)[self.foregroundCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell.viewController) {
        return (PKCollectionViewController *)cell.viewController;
    }
    
    
    PKCollectionViewController *viewController = [PKCollectionViewController new];
    viewController.collectionView.delegate = self;
    viewController.collectionView.dataSource = self;
    [self regisiterCellToCollectionView:(PKCollectionView *)viewController.collectionView];
    
    return viewController;
}

- (void)regisiterCellToCollectionView:(PKCollectionView *)collectionView
{
    //override method
}

- (PKCollectionViewController *)parentViewControllerAtCollectionView:(UICollectionView *)collectionView
{
    NSArray *cells = [self.foregroundCollectionView visibleCells];
    __block PKCollectionViewController *controller = nil;
    [cells enumerateObjectsUsingBlock:^(PKForegroundCollectionViewCell *cell, NSUInteger idx, BOOL * __nonnull stop) {
        PKCollectionViewController *viewController = (PKCollectionViewController *)cell.viewController;
        if (viewController.collectionView == collectionView) {
            controller = viewController;
            *stop = YES;
        }
    }];
    
    return controller;
}

- (PKContentViewController *)collectionView:(PKCollectionView *)collectionView contentViewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    //override method
    PKCollectionViewCell *cell = (PKCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.viewController) {
        return (PKContentViewController *)cell.viewController;
    }
    
    PKContentViewController *viewController = [PKContentViewController new];
    return viewController;
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.collectionView == collectionView || self.foregroundCollectionView == collectionView) {
        return 10;
    }
    
    return 6;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.foregroundCollectionView == collectionView) {
        PKCollectionViewController *viewController = [self viewControllerAtIndex:indexPath.item];
        if (![self.childViewControllers containsObject:viewController]) {
            [self addChildViewController:viewController];
            [cell addSubview:viewController.view];
            [viewController didMoveToParentViewController:self];
            ((PKForegroundCollectionViewCell *)cell).viewController = viewController;
        }
        return;
    }
    
    if (self.collectionView == collectionView) {
        return;
    }

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.foregroundCollectionView == collectionView) {
        PKCollectionViewController *viewController = (PKCollectionViewController *)((PKForegroundCollectionViewCell *)cell).viewController;
        if ([self.childViewControllers containsObject:viewController]) {
            [viewController willMoveToParentViewController:self];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
    
    if (self.collectionView == collectionView) {
        return;
    }

    PKContentViewController *viewController = (PKContentViewController *)((PKCollectionViewCell *)cell).viewController;
    if ([self.childViewControllers containsObject:viewController]) {
        PKForegroundCollectionViewCell *foregroundCell = (PKForegroundCollectionViewCell *)[self.foregroundCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedCategory inSection:0]];
        
        [viewController willMoveToParentViewController:foregroundCell.viewController];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.collectionView == collectionView) {
        UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
        NSInteger i = [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
        UIColor *color = [UIColor colorWithHue:(floorf(indexPath.row)/i) saturation:0.8 brightness:0.75 alpha:1.0];
        cell.backgroundColor = color;
        return cell;
    }
    
    // foreground
    if (self.foregroundCollectionView == collectionView) {
        PKForegroundCollectionViewCell *cell = (PKForegroundCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PKForegroundCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
    
    // Content
    PKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PKCollectionViewCell" forIndexPath:indexPath];
    //PKForegroundCollectionViewCell *foregroundCell = (PKForegroundCollectionViewCell *)[self.foregroundCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedCategory inSection:0]];
    PKCollectionViewController *parentViewController = [self parentViewControllerAtCollectionView:collectionView];
    PKContentViewController *viewController = [self collectionView:(PKCollectionView *)collectionView contentViewControllerAtIndexPath:indexPath];
    
    if (![parentViewController.childViewControllers containsObject:viewController]) {
        [parentViewController addChildViewController:viewController];
        [cell addSubview:viewController.view];
        [parentViewController didMoveToParentViewController:self];
        ((PKCollectionViewCell *)cell).viewController = viewController;
    }
    
    return cell;
    
    
    return nil;
}


@end