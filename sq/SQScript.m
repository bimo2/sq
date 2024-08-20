//
//  SQScript.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-20.
//

#import <Foundation/Foundation.h>
#import "SQError.h"
#import "SQToken.h"

#import "SQScript.h"

@implementation SQScript

- (instancetype)initWithName:(NSString *)name info:(NSString *)info shell:(NSString *)shell commands:(NSArray *)commands {
    _name = name;
    _info = info;
    _shell = shell;
    _commands = commands.copy;
    
    return self;
}

- (NSString *)signature {
    NSString *result = [NSString stringWithString:self.name];
    NSArray *tokens = self.tokenize;
    
    for (SQToken *token in tokens) {
        NSString *format = token.isRequired ? @" <%@!>" : @" <%@>";
        
        result = [result stringByAppendingFormat:format, token.name];
    }
    
    return result;
}

- (NSArray *)replaceWithOptions:(NSArray *)options error:(NSError **)error {
    NSMutableArray *lines = [NSMutableArray arrayWithArray:self.commands];
    NSArray *tokens = self.tokenize;
    
    for (int i = 0; i < tokens.count; i++) {
        NSInteger index = tokens.count - (i + 1);
        SQToken *token = [tokens objectAtIndex:index];
        NSString *option = options.count > index ? [options objectAtIndex:index] : @"-";
        
        if (![option isEqualToString:@"-"]) {
            NSString *string = [option containsString:@" "] ? [NSString stringWithFormat:@"\"%@\"", option] : option;
            NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:string];
            
            [lines replaceObjectAtIndex:token.lineNumber withObject:update];
            
            continue;
        }
        
        if (token.isRequired) {
            *error = [NSError errorWithCode:SQREPLError reason:[NSString stringWithFormat:@"expected argument: %@", token.name]];
            
            return NSArray.array;
        }
        
        if (token.defaultValue) {
            NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:token.defaultValue];
            
            [lines replaceObjectAtIndex:token.lineNumber withObject:update];
            
            continue;
        }
        
        NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:@""];
        
        [lines replaceObjectAtIndex:token.lineNumber withObject:update];
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s\\s+(?=(?:[^\"]*(\")[^\"]*\\1)*[^\"]*$)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (NSMutableString *line in lines) [regex replaceMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@" "];
    
    return [NSArray arrayWithArray:lines];
}

- (NSArray *)tokenize {
    NSMutableArray *lines = [NSMutableArray arrayWithArray:self.commands];
    NSMutableArray *tokens = NSMutableArray.array;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(?<=#)((\\w+[!]?)|(\\w+ -> ([^\\s#]+|\"[^#]+\")))(?=#)#" options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (int i = 0; i < lines.count; i++) {
        NSString *line = [lines objectAtIndex:i];
        NSArray *matches = [regex matchesInString:line options:0 range:NSMakeRange(0, line.length)];
        
        for (NSTextCheckingResult *match in matches) {
            SQToken *token = [[SQToken alloc] initWithTextMatch:match line:line lineNumber:i];
            
            [tokens addObject:token];
        }
    }
    
    return [NSArray arrayWithArray:tokens];
}

@end
