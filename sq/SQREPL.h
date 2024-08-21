//
//  SQREPL.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#ifndef SQREPL_H
#define SQREPL_H

@interface SQREPL : NSObject

@property (nonatomic, copy) NSString *path;

- (instancetype)initWitPath:(NSString *)path error:(NSError **)error;

- (void)docs;

- (void)version;

- (void)cloneGitRepositoryWithURL:(NSString *)url error:(NSError **)error;

- (void)writeDefaultSQFileWithFileManager:(NSFileManager *)fileManager error:(NSError **)error;

- (void)evaluateWithName:(NSString *)name options:(NSArray *)options error:(NSError **)error;

@end

#endif // SQREPL_H
