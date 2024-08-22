//
//  tests.m
//  tests
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <XCTest/XCTest.h>
#import "define.h"
#import "testing.h"
#import "SQContext.h"
#import "SQScript.h"

@interface Tests : XCTestCase

@property (nonatomic) NSBundle *bundle;
@property (nonatomic) NSFileManager *fileManager;

@end

@implementation Tests

- (void)setUp {
    _bundle = [NSBundle bundleForClass:self.class];
    _fileManager = NSFileManager.defaultManager;
}

- (void)test_findSQFile {
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@".sq" withExtension:nil];
    NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSString *file = [[NSFileManager.defaultManager currentDirectoryPath] stringByAppendingPathComponent:@SQ_FILE];
    
    [json writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    char *path = NULL;
    
    find(&path);
    
    XCTAssertEqualObjects(@".sq", [NSString stringWithCString:path encoding:NSUTF8StringEncoding].lastPathComponent);
    
    __weak Tests *weakSelf = self;
    
    [self addTeardownBlock:^{
        [weakSelf.fileManager removeItemAtPath:file error:nil];
        free(path);
    }];
}

- (void)test_findSQFile_recursive {
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@".sq" withExtension:nil];
    NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSString *directory = [self.fileManager.currentDirectoryPath stringByAppendingPathComponent:@"/folder"];
    NSString *file = [self.fileManager.currentDirectoryPath stringByAppendingPathComponent:@SQ_FILE];
    
    [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    [json writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.fileManager changeCurrentDirectoryPath:directory];
    
    char *path = NULL;
    
    find(&path);
    
    XCTAssertEqualObjects(@".sq", [NSString stringWithCString:path encoding:NSUTF8StringEncoding].lastPathComponent);
    
    __weak Tests *weakSelf = self;
    
    [self addTeardownBlock:^{
        [weakSelf.fileManager removeItemAtPath:file error:nil];
        free(path);
    }];
}

- (void)test_findSQFile_git {
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@".sq" withExtension:nil];
    NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSString *directory = [self.fileManager.currentDirectoryPath stringByAppendingPathComponent:@"/folder"];
    NSString *file = [self.fileManager.currentDirectoryPath stringByAppendingPathComponent:@SQ_FILE];
    NSString *gitFile = [directory stringByAppendingPathComponent:@".git"];
    
    [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    [json writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.fileManager createFileAtPath:gitFile contents:nil attributes:nil];
    [self.fileManager changeCurrentDirectoryPath:directory];
    
    char *path = NULL;
    
    find(&path);
    
    XCTAssert(path == NULL);
    
    __weak Tests *weakSelf = self;
    
    [self addTeardownBlock:^{
        [weakSelf.fileManager removeItemAtPath:file error:nil];
        [weakSelf.fileManager removeItemAtPath:gitFile error:nil];
        free(path);
    }];
}

- (void)test_defaultSQFile_valid {
    NSError *error;
    NSString *contents = [NSString stringWithFormat:@SQ_DEFAULT, @"objc"];
    SQContext *context = [[SQContext alloc] initWithData:[contents dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    
    XCTAssertNil(error);
    XCTAssertEqual(context.version, 0);
    XCTAssertEqualObjects(context.project, @"objc");
    XCTAssertEqual(context.binaries.count, 2);
    XCTAssertEqual(context.scripts.count, 4);
}

- (void)test_tokenizeOptions {
    NSArray *commands = @[ @"git add #file#", @"git commit -m #message#", @"git push" ];
    SQScript *script = [[SQScript alloc] initWithName:@"test" info:nil shell:@"sh" commands:commands];
    NSError *error;
    
    NSArray *result = [script replaceWithOptions:@[] secrets:NSDictionary.dictionary error:&error];
    NSArray *expected = @[ @"git add", @"git commit -m", @"git push" ];
    
    XCTAssertEqualObjects(result, expected);
    
    NSArray *result2 = [script replaceWithOptions:@[ @"readme.txt", @"update readme" ] secrets:NSDictionary.dictionary error:&error];
    NSArray *expected2 = @[ @"git add readme.txt", @"git commit -m \"update readme\"", @"git push" ];
    
    XCTAssertEqualObjects(result2, expected2);
    
    NSArray *result3 = [script replaceWithOptions:@[ @"-", @"update readme" ] secrets:NSDictionary.dictionary error:&error];
    NSArray *expected3 = @[ @"git add", @"git commit -m \"update readme\"", @"git push" ];
    
    XCTAssertEqualObjects(result3, expected3);
}

- (void)test_tokenizeOptions_required {
    NSArray *commands = @[ @"git add #file -> .#", @"git commit -m #message!#", @"git push #flag#" ];
    SQScript *script = [[SQScript alloc] initWithName:@"test" info:nil shell:@"sh" commands:commands];
    NSError *error;
    
    NSArray *result = [script replaceWithOptions:@[ @"readme.txt", @"update readme" ] secrets:NSDictionary.dictionary error:&error];
    NSArray *expected = @[ @"git add readme.txt", @"git commit -m \"update readme\"", @"git push" ];
    
    XCTAssertEqualObjects(result, expected);
    
    NSArray *result2 = [script replaceWithOptions:@[ @"readme.txt" ] secrets:NSDictionary.dictionary error:&error];
    NSArray *expected2 = NSArray.array;
    
    XCTAssertEqualObjects(result2, expected2);
    
    NSArray *result3 = [script replaceWithOptions:@[ @"-", @"update readme", @"-f" ] secrets:NSDictionary.dictionary error:&error];
    NSArray *expected3 = @[ @"git add .", @"git commit -m \"update readme\"", @"git push -f" ];
    
    XCTAssertEqualObjects(result3, expected3);
}

- (void)test_tokenizeOptions_secrets {
    NSArray *commands = @[ @"git add #file -> .#", @"git commit -m #message!#", @"git config user.email &EMAIL", @"git push #flag#" ];
    SQScript *script = [[SQScript alloc] initWithName:@"test" info:nil shell:@"sh" commands:commands];
    NSError *error;
    
    NSArray *result = [script replaceWithOptions:@[ @"-", @"update readme" ] secrets:@{ @"EMAIL" : @"bimal@squareup.com" } error:&error];
    NSArray *expected = @[ @"git add .", @"git commit -m \"update readme\"", @"git config user.email bimal@squareup.com", @"git push" ];
    
    XCTAssertEqualObjects(result, expected);
}

@end
