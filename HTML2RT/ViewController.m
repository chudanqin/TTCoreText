//
//  ViewController.m
//  HTML2RT
//
//  Created by chudanqin on 2018/8/27.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "ViewController.h"
#import "TTLabel.h"
#import "TTLayoutManager.h"

@interface TTLabelCell : UICollectionViewCell
@property (nonatomic) TTLabel *label;
@end

@implementation TTLabelCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _label = [TTLabel new];
        _label.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = self.bounds;
}

@end

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSAttributedString *attributedText;

@property (nonatomic) TTLayoutManager *layoutManager;

@end

@implementation ViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:[TTLabelCell class] forCellWithReuseIdentifier:@"1"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tt" ofType:@"html"];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineBreakMode = NSLineBreakByCharWrapping;
    ps.alignment = NSTextAlignmentJustified;
    ps.lineSpacing = 5.0;
    _attributedText = [[NSAttributedString alloc] initWithString:text
                                                      attributes:@{
                                                                   NSFontAttributeName: [UIFont systemFontOfSize:15],
                                                                    NSForegroundColorAttributeName: [UIColor blackColor],
                                                                   NSParagraphStyleAttributeName: ps,
                                                                   }];
    
    
}

- (void)viewDidLayoutSubviews {
    if (_layoutManager == nil) {
        NSDate *date = [NSDate date];
        TTTextContainer *textContainer = [[TTTextContainer alloc] init];
        textContainer.size = _collectionView.bounds.size;
        textContainer.padding = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
        _layoutManager = [TTLayoutManager loadWithTextContainer:textContainer text:_attributedText];
        NSTimeInterval ti = [NSDate date].timeIntervalSince1970 - date.timeIntervalSince1970;
        NSLog(@"--%f", ti);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _layoutManager.textLayouts.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"1" forIndexPath:indexPath];
    cell.label.textLayout = _layoutManager.textLayouts[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

@end
