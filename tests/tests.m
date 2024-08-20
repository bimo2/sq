//
//  tests.m
//  tests
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <XCTest/XCTest.h>
#import "define.h"
#import "SQContext.h"
#import "testing.h"

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
    XCTAssertEqualObjects(context.repo, @"objc");
    XCTAssertEqual(context.binaries.count, 2);
    XCTAssertEqual(context.scripts.count, 4);
}

@end
