//
//  SQContext.h
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#ifndef SQCONTEXT_H
#define SQCONTEXT_H

@interface SQContext : NSObject

@property (nonatomic) NSInteger version;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy, readonly) NSString *env;
@property (nonatomic, readonly) NSArray *binaries;
@property (nonatomic, readonly) NSArray *methods;

- (instancetype)initWithFileData:(NSData *)fileData error:(NSError **)error;

@end

#endif // SQCONTEXT_H
