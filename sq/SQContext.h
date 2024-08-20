//
//  SQContext.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-17.
//

#ifndef SQCONTEXT_H
#define SQCONTEXT_H

@interface SQContext : NSObject

@property (nonatomic, readonly) NSInteger version;
@property (nonatomic, copy, readonly) NSString *repo;
@property (nonatomic, readonly) NSArray *binaries;
@property (nonatomic, readonly) NSArray *scripts;

- (instancetype)initWithData:(NSData *)data error:(NSError **)error;

@end

#endif // SQCONTEXT_H
