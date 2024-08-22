//
//  define.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#ifndef DEFINE_H
#define DEFINE_H

#define ENV_FILE ".env"

#define SQ_FILE ".sq"
#define SQ_DOCS_URL "https://github.com/bimo2/sq"
#define SQ_SCHEMA 0

#define VERSION "0.2"
#define BUILD_VERSION "2A"

#ifndef BUILD_NUMBER
#define BUILD_NUMBER 0
#endif

#define PRINT(cstring) printf("%s\n", cstring)
#define PRINT_HEADER(cstring) printf("\033[1msq\033[0m %s\n", cstring)
#define PRINT_INFO(title, cstring) printf("\033[1m%s\033[0m %s\n", title, cstring)
#define PRINT_TIME(double) printf("\033[1;92m\u2713\033[0;92m %.3fs\033[0m\n", double)
#define PRINT_ERROR(cstring) printf("\033[1;91m\u2717\033[0;91m %s\033[0m\n", cstring)
#define PRINT_COMMAND(cstring) printf("\n> \033[1m%s\033[0m\n\n", cstring)
#define PRINT_FILE printf("\n\033[1m\u231C     \u231D\n  .sq  \n\u231E     \u231F\033[0m\n\n")

#define SQ_DEFAULT \
"sq: 0,\n" \
"git: '%@',\n" \
"require: [\n" \
"  'git',\n" \
"  'nano'\n" \
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
