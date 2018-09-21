//
//  TTXMLParser.m
//  HTML2RT
//
//  Created by chudanqin on 2018/8/27.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "ONOXMLDocument.h"
#import "TTRichTextGenerator.h"
#import "TTXMLParser.h"

static void _traverseElem(ONOXMLElement *elem, TTHTMLParser *parser);

static void _traverseBodyElem(ONOXMLElement *elem, TTHTMLParser *parser);

@interface TTHTMLParser ()

@property (nonatomic) ONOXMLDocument *document;

@property (nonatomic) ONOXMLElement *bodyElement;

@property (nonatomic) TTRichTextConverter *richTextConverter;

@property (nonatomic) NSMutableArray<ONOXMLElement *> *displayableElems;

@property (nonatomic) dispatch_group_t dispatchGroup;

@property (nonatomic) dispatch_queue_t dispatchQueue;

@end

@implementation TTHTMLParser

+ (instancetype)instanceWithData:(NSData *)data delegate:(id<TTHTMLParserDelegate>)delegate error:(NSError *__autoreleasing *)error {
    ONOXMLDocument *doc = [ONOXMLDocument HTMLDocumentWithData:data error:error];
    if (doc == nil) {
        return nil;
    }
    TTHTMLParser *parser = [[TTHTMLParser alloc] init];
    parser.document = doc;
    parser.delegate = delegate;
    return parser;
}

- (void)dealloc
{
    NSLog(@"TTHTMLParser dealloc");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayableElems = [NSMutableArray array];
        _dispatchGroup = dispatch_group_create();
        _dispatchQueue = dispatch_queue_create("TTHTMLQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)start {
    dispatch_group_async(_dispatchGroup, _dispatchQueue, ^{
        _traverseElem(self.document.rootElement, self);
    });
}

- (void)onHeadElementFound:(ONOXMLElement *)elem {
    NSString *tag = [elem.tag lowercaseString];
    if ([tag isEqualToString:@"link"]) {
        NSDictionary *attrs = elem.attributes;
        if ([[attrs[@"rel"] lowercaseString] isEqualToString:@"stylesheet"] &&
            [[attrs[@"type"] lowercaseString] isEqualToString:@"text/css"]) {
            NSString *CSSHRef = attrs[@"href"];
            [_delegate parser:self needsCSSWithHyperRef:CSSHRef completion:^(const char *cssStr, NSURL *fileURL) {
                [self loadCSS:cssStr fileURL:fileURL];
            }];
        }
    }
}

- (void)onBodyElementFound:(ONOXMLElement *)elem {
    NSString *tag = [elem.tag lowercaseString];
    if ([tag isEqualToString:@"p"]) {
        [self convertTextElement:elem];
    } else if ([tag isEqualToString:@"img"]) {
        [self convertImageElement:elem];
    } else if ([tag length] > 1) {
        NSRange r = [tag rangeOfComposedCharacterSequenceAtIndex:0];
        NSString *substr = [tag substringWithRange:r];
        if ([substr isEqualToString:@"h"]) {
            NSScanner *scanner = [NSScanner scannerWithString:tag];
            scanner.scanLocation = 1;
            if ([scanner scanInt:NULL] && [scanner isAtEnd]) {
                [self convertTextElement:elem];
            }
        }
    }
}

- (void)convertTextElement:(ONOXMLElement *)elem {
    
}

- (void)convertImageElement:(ONOXMLElement *)elem {
    
}

- (void)loadCSS:(const char *)CSSString fileURL:(NSURL *)fileURL {
    dispatch_group_async(_dispatchGroup, _dispatchQueue, ^{
        if (CSSString == NULL) {
            self.richTextConverter = [TTRichTextConverter createWithCSSFileURL:fileURL];
        } else {
            self.richTextConverter = [TTRichTextConverter createWithCSSString:CSSString];
        }
        [self.richTextConverter preprocessCSS];
        _traverseBodyElem(self.bodyElement, self);
    });
    dispatch_group_notify(_dispatchGroup, _dispatchQueue, ^{
        
    });
}

@end

static void _traverseHeadElem(ONOXMLElement *elem, TTHTMLParser *parser) {
    [parser onHeadElementFound:elem];
    for (ONOXMLElement *childElem in elem.children) {
        _traverseHeadElem(childElem, parser);
    }
}

static void _traverseBodyElem(ONOXMLElement *elem, TTHTMLParser *parser) {
    [parser onBodyElementFound:elem];
    for (ONOXMLElement *childElem in elem.children) {
        _traverseBodyElem(childElem, parser);
    }
}

static void _traverseElem(ONOXMLElement *elem, TTHTMLParser *parser) {
    if (elem == nil) {
        return;
    }
    NSString *tag = [elem.tag lowercaseString];
    if ([tag isEqualToString:@"head"]) {
        _traverseHeadElem(elem, parser);
    } else if ([tag isEqualToString:@"body"]) {
        parser.bodyElement = elem;
//        _traverseBodyElem(elem, parser);
    } else {
        for (ONOXMLElement *childElem in elem.children) {
            _traverseElem(childElem, parser);
        }
    }
}
