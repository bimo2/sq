//
//  define.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#ifndef DEFINE_H
#define DEFINE_H

#define SQ_FILE ".sq"
#define SQ_DOCS_URL "https://github.com/bimo2/sq"
#define SQ_SCHEMA 0

#define VERSION "0.1"
#define BUILD_VERSION "1A"

#ifndef BUILD_NUMBER
#define BUILD_NUMBER 0
#endif

#define SQ_DEFAULT \
"sq: 0,\n" \
"git: '%@',\n" \
"require: [\n" \
"  'git',\n" \
"  'nano',\n" \
"],\n" \
"cli: {\n" \
"  install: {\n" \
"    d: 'install ...',\n" \
"    sh: [\n" \
"      'echo pkg install -d objc',\n" \
"      'echo download http://127.0.0.1/sdk'\n" \
"    ]\n" \
"  },\n" \
"  dev: {\n" \
"    d: 'dev ...',\n" \
"    sh: 'echo serve -p #port -> 4000#'\n" \
"  },\n" \
"  build: {\n" \
"    d: 'build ...',\n" \
"    sh: 'echo compile -o #bin!#'\n" \
"  },\n" \
"  test: {\n" \
"    d: 'test ...',\n" \
"    sh: 'echo test #suite#'\n" \
"  }\n" \
"}\n"

#endif // DEFINE_H
