# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Path, Utilities, and Constants Setup
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Path        = require "path"
Del         = require "del"
Gulp        = require "gulp"
Copy        = require "gulp-copy"
GulpWatch   = require "gulp-watch"
GulpCoffee  = require "gulp-coffee"
Concat      = require "gulp-concat"
Depends     = require "gulp-closure-deps"
Closure     = require "gulp-closure-compiler"

BASE_DIR          = Path.resolve __dirname
TEST_DIR          = Path.join BASE_DIR, "test"
COFFEE_DIR        = Path.join BASE_DIR, "coffee"
EXTERNAL_DIR      = Path.join BASE_DIR, "external"
COMPILED_JS_DIR   = Path.join BASE_DIR, "js"

CLOSURE_JAR       = Path.join BASE_DIR, "bower_components/closure-compiler/node_modules/google-closure-compiler/compiler.jar"

COFFEE_SRC        = Path.join COFFEE_DIR, "**/*.coffee"
COMPILED_JS_SRC   = Path.join COMPILED_JS_DIR, "**/*.js"
UNDERSCORE_LIBS   = Path.join EXTERNAL_DIR, "underscore.js"
KNOCKOUT_LIBS     = Path.join EXTERNAL_DIR, "knockout.js"
ASTJS_LIBS        = Path.join EXTERNAL_DIR, "ast.js"
EXTERNAL_LIBS     = [UNDERSCORE_LIBS,KNOCKOUT_LIBS,ASTJS_LIBS]

LIBRARY_NAME_DEV  = "coffee-sound.js"
LIBRARY_FILE_DEV  = Path.join BASE_DIR, LIBRARY_NAME_DEV
LIBRARY_NAME_MIN  = "coffee-sound.min.js"
LIBRARY_FILE_MIN  = Path.join BASE_DIR, LIBRARY_NAME_MIN
DEPS_NAME         = "deps.js"
DEPS_FILE         = Path.join COMPILED_JS_DIR, DEPS_NAME
BASE_NAME         = "base.js"
BASE_FILE         = Path.join EXTERNAL_DIR, BASE_NAME

doClosureCompile = (filename,formatting) ->
  args =
    compilerPath: CLOSURE_JAR
    fileName: filename
    compilerFlags:
      compilation_level: "SIMPLE_OPTIMIZATIONS"
      output_wrapper: "(function(){%output%})();"

  if formatting?
    args.compilerFlags.formatting = formatting

  Gulp.src([COMPILED_JS_SRC].concat(EXTERNAL_LIBS))
    .pipe(Closure(args))
    .pipe(Gulp.dest(BASE_DIR))

Gulp.task "default", ["package"]
Gulp.task "package", ["compile", "compile-closure"]
Gulp.task "compile", ["compile-coffee", "closure-deps", "compile-library"]
Gulp.task "clean", ["clean-closure"]

Gulp.task "compile-coffee", ->
  args = { bare : true }

  Gulp.src(COFFEE_SRC)
    .pipe(GulpCoffee(args))
    .pipe(Gulp.dest(COMPILED_JS_DIR))

Gulp.task "closure-deps", ["compile-coffee"], ->
  args =
    fileName: DEPS_NAME
    prefix: Path.relative(COMPILED_JS_DIR,BASE_DIR)

  Gulp.src([COMPILED_JS_SRC].concat(EXTERNAL_LIBS))
    .pipe(Depends(args))
    .pipe(Gulp.dest(COMPILED_JS_DIR))

  Gulp.src([BASE_FILE])
    .pipe(Gulp.dest(COMPILED_JS_DIR))

Gulp.task "clean-closure", ->
  Del [COMPILED_JS_DIR,DEPS_FILE,LIBRARY_FILE_DEV,LIBRARY_FILE_MIN]

Gulp.task "compile-closure", ["compile-coffee"], -> doClosureCompile(LIBRARY_NAME_DEV,"PRETTY_PRINT")
Gulp.task "compile-library", ["compile-coffee"], -> doClosureCompile(LIBRARY_NAME_MIN)

