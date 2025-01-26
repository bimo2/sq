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

- (instancetype)initWithData:(NSData *)data error:(NSError **)error;

@end

#endif // SQCONTEXT_H
