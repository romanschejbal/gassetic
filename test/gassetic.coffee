assert = require 'assert'
gulp = require 'gulp'
tap = require 'gulp-tap'
path = require 'path'

suite 'Gassetic', ->
	ga = null
	setup (done) ->
		Gassetic = require '../gassetic'
		config =
			requires:
				concat: 'gulp-concat'
				coffee: 'gulp-coffee'
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
				coffee2:
					dev:
						outputFolder: './test/dest'
						tasks: [
							{ name: 'coffee', args: { bare: true } }
						]
						autoRenaming: false
					files: {
						'coffee2.js': [
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
			default: ['css', 'js', 'coffee2']
			replacementPaths: [
				'./test/templates/**/*.html'
			]

		ga = new Gassetic 'dev', undefined, false
		ga.config = config
		ga.validateConfig()
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
