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

gulp.task 'testt', ->
	testConfig =
		mimetypes:
			css:
				dev:
					outputFolder: 'tmp'
					webPath: '/tmp'
					tasks: [
						'test'
					]
				prod:
					outputFolder: 'tmp'
					webPath: '/tmp'
				files:
					'final.css': [
						'tmp/lesstest.less'
					]
		default: [
			'css'
		]

	ga = new Gassetic testConfig, 'dev', modules


