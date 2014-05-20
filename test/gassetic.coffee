assert = require 'assert'
gulp = require 'gulp'
tap = require 'gulp-tap'
path = require 'path'
modules = {}
modules.coffee = require 'gulp-coffee'
modules.concat = require 'gulp-concat'

suite 'Gassetic', ->
	ga = null
	setup (done) ->
		Gassetic = require '../index'
		config =
			mimetypes:
				css:
					dev:
						outputFolder: './test/dest'
						webPath: '/web'
						tasks: [
							{ name: 'concat', args: '%filename%' }
						]
						htmlTag: '<script type="text/javascript" src="{{ asset("%path%") }}"></script>'
					files:
						'concated.css': [
							'./test/src/css/**/*.css'
						]
				coffee:
					dev:
						outputFolder: './test/dest'
						tasks: [
							{ name: 'coffee', args: { bare: true } }
						]
					files: {
						'coffee.js': [
							'./test/src/coffee/**/*.coffee'
						]
					}
				js:
					deps: ['coffee']
					dev:
						outputFolder: './test/dest'
						webPath: '/web'
						tasks: [
							{ name: 'concat', args: '%filename%' }
						]
					files: {
						'js.js': [
							'./test/src/js/**/*.js'
							'./test/dest/coffee.js/**/*.js'
						]
					}
			default: ['css', 'js']
			replacementPaths: [
				'./test/templates/**/*.html'
			]

		ga = new Gassetic config, 'dev', modules, false
		done()

	suite 'dependency test', ->
		test 'should return string coffee', ->
			deps = ga.findDependentTypes 'js'
			assert.equal deps[0], 'coffee'

	suite 'build test', ->
		test 'should clean destination files', (done) ->
			ga.clean().then ->
				files = []
				for type of ga.getMimetypes()
					ga.getDestinationPathsForType type
						.map (f) ->
							files.push f
				count = 0
				gulp.src files
					.pipe tap (file) ->
						count++
					.on 'end', ->
						assert.equal count, 0
						done()

		test 'should copy source files to destination folder', (done) ->
			ga.build().then (what) ->
				files = []
				for type of ga.getMimetypes()
					ga.getDestinationPathsForType type
						.map (f) ->
							files.push f

				cwd = ga.cwd()
				gulp.src files
					.pipe tap (file) ->
						relative = path.relative cwd, file.path
						files.splice files.indexOf(relative), 1
					.on 'end', ->
						assert.equal files.length, 0
						done()
