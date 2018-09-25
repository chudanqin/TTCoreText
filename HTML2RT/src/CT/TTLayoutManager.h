//
//  TTLayoutManager.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/25.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTTextLayout.h"

@class TTLayoutManager;

@protocol TTLayoutManagerDelegate <NSObject>

- (TTTextContainer *)layoutManager:(TTLayoutManager *)layoutManager willLoadText:(NSAttributedString *)text range:(CFRange)range pageIndex:(NSUInteger)pageIndex;

@end

@interface TTLayoutManager : NSObject

@property (nonatomic, weak) id<TTLayoutManagerDelegate> delegate;

@property (nonatomic, readonly) NSAttributedString *text;

@property (nonatomic, readonly) CFRange range;

@property (nonatomic, readonly) NSArray<TTTextLayout *> *textLayouts;

+ (instancetype)textLayoutWithText:(NSAttributedString *)text
                             range:(CFRange)range
                          delegate:(id<TTLayoutManagerDelegate>)delegate;

+ (instancetype)loadWithTextContainer:(TTTextContainer *)textContainer
                                 text:(NSAttributedString *)text;

- (BOOL)reload;

@end
