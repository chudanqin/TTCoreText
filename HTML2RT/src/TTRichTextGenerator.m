//
//  TTRichTextGenerator.m
//  HTML2RT
//
//  Created by chudanqin on 2018/8/27.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "parser.h"
#import "KatanaObjC.h"
#import "TTRichTextGenerator.h"

@interface TTCSSSingleRuleWrapper : NSObject

@property (nonatomic, assign) KatanaSelector *selector;

@property (nonatomic, assign) KatanaArray *declarations;

@end

@implementation TTCSSSingleRuleWrapper
@end

@interface TTCSSDeclarationWrapper : NSObject
@end

@interface TTRichTextConverter ()

@property (nonatomic) KatanaOutput *output;

@property (nonatomic) NSMutableDictionary<NSString *, id> *simpleSelectorRules;

@end

@implementation TTRichTextConverter

+ (instancetype)createWithCSSFileURL:(NSURL *)fileURL {
    if (fileURL.isFileURL) {
        const char *path = [fileURL.path fileSystemRepresentation];
        FILE *fp = fopen(path, "r");
        if (fp != NULL) {
            KatanaOutput *output = katana_parse_in(fp);
            fclose(fp);
            if (output != nil) {
                return [[self alloc] initWithOutput:output];
            }
        }
    }
    return nil;
}

+ (instancetype)createWithCSSString:(const char *)cssStr {
    KatanaOutput *output = katana_parse(cssStr, strlen(cssStr), KatanaParserModeStylesheet);
    if (output != nil) {
        return [[self alloc] initWithOutput:output];
    }
    return nil;
}

- (void)dealloc {
    katana_destroy_output(_output);
}

- (instancetype)initWithOutput:(KatanaOutput *)output {
    NSCParameterAssert(output != NULL);
    self = [super init];
    if (self != nil) {
        _output = output;
        _simpleSelectorRules = [NSMutableDictionary dictionaryWithCapacity:13];
    }
    return self;
}

- (void)preprocessCSS {
//    katana_dump_output(_output);
    
    KatanaParser parser;
    parser.options = &kKatanaDefaultOptions;
    KatanaStylesheet *sheet = _output->stylesheet;
    /** WARNING omit imports
     *  sheet->imports
     */
    for (size_t i = 0; i < sheet->rules.length; ++i) {
        KatanaStyleRule *rule = sheet->rules.data[i];
        if (rule->declarations->length == 0) {
            continue;
        }
        KatanaArray *selectors = rule->selectors;
        for (size_t k = 0; k < selectors->length; k++) {
//            katana_print_selector(parser, selectors->data[k]);
            KatanaSelector *sel = selectors->data[k];
            NSString *key = [self testSimpleSelector:sel];
            if ([key length] > 0) {
                TTCSSSingleRuleWrapper *srw = [[TTCSSSingleRuleWrapper alloc] init];
                srw.selector = sel;
                srw.declarations = rule->declarations;
                _simpleSelectorRules[key] = srw;
            }
        }
    }
}

- (void)foundDeclaration:(KatanaDeclaration *)decl {
    if (decl->values->length == 0) {
        return;
    }
    
}

- (NSString *)testSimpleSelector:(KatanaSelector *)sel {
    NSMutableString *key = [NSMutableString stringWithCapacity:10];
    KatanaSelector *cs = sel;
    while (YES) {
        switch (cs->match) {
            case KatanaSelectorMatchTag:
                objc_appendKatanaQualifiedName(key, cs->tag);
                break;
            case KatanaSelectorMatchId:
                [key appendFormat:@"#%s", cs->data->value];
                break;
            case KatanaSelectorMatchClass:
                [key appendFormat:@".%s", cs->data->value];
                break;
            default:
                return nil;
        }
        if (cs->relation != KatanaSelectorRelationSubSelector) {
            return nil;
        }
        if (cs->tagHistory == NULL) {
            break;
        }
        cs = cs->tagHistory;
    }
    return key;
}

- (void)matchElement:(ONOXMLElement *)elem {
    NSDictionary *attrs = elem.attributes;
    NSString *ID = attrs[@"id"];
    NSString *class = attrs[@"class"];
    NSString *tag = elem.tag;
    if (ID != nil) {
        
    }
}

@end
