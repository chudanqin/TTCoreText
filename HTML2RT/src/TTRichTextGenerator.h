//
//  TTRichTextGenerator.h
//  HTML2RT
//
//  Created by chudanqin on 2018/8/27.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOXMLDocument.h"

@interface TTRichTextConverter : NSObject

+ (instancetype)createWithCSSFileURL:(NSURL *)fileURL;

+ (instancetype)createWithCSSString:(const char *)cssStr;

- (void)preprocessCSS;

@end
