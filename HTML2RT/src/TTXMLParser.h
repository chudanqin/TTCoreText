//
//  TTXMLParser.h
//  HTML2RT
//
//  Created by chudanqin on 2018/8/27.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTHTMLParser;

@protocol TTHTMLParserDelegate <NSObject>

- (void)parser:(TTHTMLParser *)parser needsCSSWithHyperRef:(NSString *)href completion:(void (^)(const char *cssStr, NSURL *fileURL))completion;

@end

@interface TTHTMLParser : NSObject

@property (nonatomic, weak) id<TTHTMLParserDelegate> delegate;

+ (instancetype)instanceWithData:(NSData *)data delegate:(id<TTHTMLParserDelegate>)delegate error:(NSError *__autoreleasing *)error;

- (void)start;

@end
