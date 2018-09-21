//
//  TTTextLayout.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/6.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTextSlice.h"

@interface TTTextContainer : NSObject

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) UIEdgeInsets padding;

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, strong) NSArray<UIBezierPath *> *exclusionPaths;

@end

@interface TTTextLayout : NSObject

@property (nonatomic, readonly) TTTextContainer *textContainer;

@property (nonatomic, readonly) NSAttributedString *text;

@property (nonatomic, readonly) NSArray<TTTextSlice *> *textSlices;

+ (instancetype)textLayoutWithTextContainer:(TTTextContainer *)textContainer
                                       text:(NSAttributedString *)text;

@end
