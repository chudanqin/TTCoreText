//
//  TTBookViewController.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/4.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTPageCell.h"
#import "YYText.h"
#import "TTBookViewController.h"

@interface TTBookViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, unsafe_unretained) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSArray<YYTextLayout *> *textLayouts;

@property (nonatomic) NSArray<NSAttributedString *> *textSlices;

@end

@implementation TTBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    UINib *nib = [UINib nibWithNibName:@"TTPageCell" bundle:[NSBundle mainBundle]];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    
    NSString *textPath = [[NSBundle mainBundle] pathForResource:@"tt" ofType:@"html"];
    NSString *str = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:NULL];
    if (str != nil) {
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.lineSpacing = 5.0;
        ps.alignment = NSTextAlignmentJustified;
//        ps.lineBreakMode = NSLineBreakByWordWrapping;
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:str
                                                                   attributes:@{
                                                                                NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                                                                                NSForegroundColorAttributeName: [UIColor blueColor],
                                                                                NSParagraphStyleAttributeName: ps,
                                                                                }];
        [self initPagesWithText:text];
    }
}

- (void)initPagesWithText:(NSAttributedString *)text {
    NSUInteger length = text.length;
    NSRange range = NSMakeRange(0, length);
    NSMutableArray *textLayouts = [NSMutableArray array];
    NSMutableArray *textSlices = [NSMutableArray array];
    CGSize size = self.view.bounds.size;
    while (YES) {
        YYTextContainer *tc = [YYTextContainer containerWithSize:size];
        YYTextLayout *tl = [YYTextLayout layoutWithContainer:tc text:text range:range];
        if (tc == nil || tl == nil || tl.range.length == 0) {
            return;
        }
//        NSLog(@"-- %@", NSStringFromRange(tl.range));
        NSUInteger l = NSMaxRange(tl.visibleRange);
        if (l >= NSMaxRange(range)) {
            break;
        }
        
        NSAttributedString *slice = nil;
//        if (textSlices.count == 0)
//            slice = [text attributedSubstringFromRange:NSMakeRange(tl.visibleRange.location, tl.visibleRange.length + 1)];
//        else
            slice = [text attributedSubstringFromRange:tl.visibleRange];
        [textSlices addObject:slice];
        
        range.location = l;
        range.length = length - l;
        [textLayouts addObject:tl];
    }
    _textLayouts = textLayouts;
    _textSlices = textSlices;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _textLayouts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTPageCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.attributedText = _textSlices[indexPath.row];
    cell.label.textVerticalAlignment = YYTextVerticalAlignmentTop;
    cell.label.textAlignment = NSTextAlignmentJustified;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    YYTextView *label = [(TTPageCell *)cell label];
    NSLog(@"-- %@", label);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

@end
