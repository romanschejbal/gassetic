# necessary deps
gulp = require 'gulp'
gutil = require 'gulp-util'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'

# modules
modules = {}

reporter = 'spec'

gulp.task 'default', ['test'], ->
	#reporter = 'min'
	gulp.watch ['index.coffee', 'test/*.coffee'], ['test'], ->
		gutil.log '...'

gulp.task 'test', () ->
	gulp.src 'test/*.coffee'
		.pipe coffee()
		.pipe gulp.dest 'test'
		.pipe mocha reporter: reporter, ui: 'tdd'
