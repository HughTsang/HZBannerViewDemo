//
//  HZBannerView.m
//
//  Created by zenghz on 2017/4/18.
//  Copyright © 2017年 Personal. All rights reserved.
//
//  [GitHub地址](https://github.com/Null-Coder/HZBannerViewDemo.git)

#import "HZBannerView.h"
#import "HZBannerViewFlowLayout.h"
#import "HZBannerCell.h"
#import "HZBannerModel.h"

//居中卡片宽度与据屏幕宽度比例
static CGFloat const CardWidthScale = 0.7f;
static CGFloat const CardHeightScale = 0.9f;
//默认定时器时间
static CGFloat const DefaultTime = 3.0f;

static NSString * const reusedID = @"HZBannerCellID";

@interface HZBannerView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSInteger _currentIndex;
    CGFloat _dragStartX;
    CGFloat _dragEndX;
}
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) UIImageView *imageView;//虚化背景
@property (nonatomic, strong) NSTimer *timer;//定时器

@end

@implementation HZBannerView

#pragma mark - 懒加载
- (UIImageView *)imageView{
    
    return _imageView = _imageView ?: ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        
        UIBlurEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = imageView.bounds;
        [imageView addSubview:effectView];
        imageView;
    });
}

- (HZBannerViewFlowLayout *)flowLayout{
    
    HZBannerViewFlowLayout *flowLayout = [[HZBannerViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake([self cellWidth],self.bounds.size.height * CardHeightScale)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumLineSpacing:[self cellMargin]];
    return flowLayout;
}

- (UICollectionView *)collection{
    
    return _collection = _collection ?: ({
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[self flowLayout]];
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerClass:[HZBannerCell class] forCellWithReuseIdentifier:reusedID];
        [collectionView setUserInteractionEnabled:YES];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self addSubview:collectionView];
        collectionView;
    });
}

#pragma mark - 构造方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

#pragma mark Setter
- (void)setModels:(NSArray *)models{
    
    if (models.count == 0) {
        return;
    }
    //处理模型 实现无限滚动
    NSMutableArray *modelsM = @[].mutableCopy;
    [modelsM addObjectsFromArray:models];
    
    if (modelsM.count >= 3) {
        
        HZBannerModel *first = modelsM.firstObject;
        HZBannerModel *seconed = modelsM[1];
        HZBannerModel *last = modelsM.lastObject;
        HZBannerModel *lastTwo = modelsM[models.count - 2];
        
        [modelsM insertObject:last atIndex:0];
        [modelsM insertObject:lastTwo atIndex:0];
        
        [modelsM addObject:first];
        [modelsM addObject:seconed];
    }else if (modelsM.count == 2) {
     
        HZBannerModel *first = modelsM.firstObject;
        HZBannerModel *seconed = modelsM.lastObject;
        HZBannerModel *last = modelsM.lastObject;
        HZBannerModel *lastTwo = modelsM.firstObject;
        
        [modelsM insertObject:last atIndex:0];
        [modelsM insertObject:lastTwo atIndex:0];
        
        [modelsM addObject:first];
        [modelsM addObject:seconed];
    }else if (modelsM.count == 1) {
    
        HZBannerModel *first = modelsM.firstObject;
        HZBannerModel *seconed = modelsM.firstObject;
        HZBannerModel *last = modelsM.lastObject;
        HZBannerModel *lastTwo = models.lastObject;
        
        [modelsM insertObject:last atIndex:0];
        [modelsM insertObject:lastTwo atIndex:0];
        
        [modelsM addObject:first];
        [modelsM addObject:seconed];
    }

    _models = modelsM;
    
    //设置初始位置
    if (models.count > 0) {
        
        HZBannerModel *model = _models.firstObject;
        self.imageView.image = [UIImage imageNamed:model.picture];
        _currentIndex = 2;
        [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        //开启定时器
        [self startTimer];
    }
}

#pragma mark - CollectionDelegate
//配置cell居中
- (void)fixCellToCenter {
    
    //最小滚动距离
    float dragMiniDistance = self.bounds.size.width/20.0f;
    if (_dragStartX -  _dragEndX >= dragMiniDistance) {
        _currentIndex -= 1;//向右
    }else if(_dragEndX -  _dragStartX >= dragMiniDistance){
        _currentIndex += 1;//向左
    }
    NSInteger maxIndex = [self.collection numberOfItemsInSection:0] - 1;
    _currentIndex = _currentIndex <= 0 ? 0 : _currentIndex;
    _currentIndex = _currentIndex >= maxIndex ? maxIndex : _currentIndex;
    
    [self scrollToCenter];
}

- (void)scrollToCenter {
    
    [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    HZBannerModel *model = _models[_currentIndex];
    self.imageView.image = [UIImage imageNamed:model.picture];
    
    //如果是最后一张图
    if (_currentIndex == self.models.count - 1 ) {
        
        _currentIndex = 2;
        [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        HZBannerModel *model = _models[_currentIndex];
        self.imageView.image = [UIImage imageNamed:model.picture];
        return;
    }
    //第一张图
    else if (_currentIndex == 1) {
        
        _currentIndex = self.models.count - 3;
        [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        HZBannerModel *model = _models[_currentIndex];
        self.imageView.image = [UIImage imageNamed:model.picture];
        return;
    }
}

#pragma mark - CollectionDataSource

//卡片宽度
- (CGFloat)cellWidth {
    return self.bounds.size.width * CardWidthScale;
}

//卡片间隔
- (CGFloat)cellMargin {
    return (self.bounds.size.width - [self cellWidth])/4;
}

//设置左右缩进
- (CGFloat)collectionInset {
    
    return self.bounds.size.width/2.0f - [self cellWidth]/2.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, [self collectionInset], 0, [self collectionInset]);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    HZBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedID forIndexPath:indexPath];
    cell.model = _models[indexPath.row];
    return cell;
}

#pragma mark- --------定时器相关方法--------
#pragma mark 设置定时器时间
- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    [self startTimer];
}

- (void)startTimer {
    //如果只有一张图片，则直接返回，不开启定时器
    if (_models.count <= 1) return;
    //如果定时器已开启，先停止再重新开启
    if (self.timer){
        [self stopTimer];
    }
    NSTimeInterval timeInterval = _timeInterval ? (_timeInterval >= 1 ?: 1) : DefaultTime;
    self.timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextPage {
    
    _currentIndex += 1;

    [self scrollToCenter];
}

#pragma mark - UIScrollViewDelegate
//手指拖动开始
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    _dragStartX = scrollView.contentOffset.x;
    [self stopTimer];
}

//手指拖动停止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    _dragEndX = scrollView.contentOffset.x;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fixCellToCenter];
    });
    
    [self startTimer];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _currentIndex = indexPath.row;
    [self scrollToCenter];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(HZBannerView:didSelectedAt:)]) {
        [self.delegate HZBannerView:self didSelectedAt:indexPath.row];
    }
}




@end
