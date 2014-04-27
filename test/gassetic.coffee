assert = require 'assert'
gulp = require 'gulp'

suite 'Gassetic', ->
	ga = null
	setup (done) ->
		Gassetic = require '../index'
		config =
			mimetypes:
				css:
					dev:
						outputFolder: ''
						tasks: []
					files:
						'concated.css': [
							'./src/**.coffee'
						]
				coffee:
					dev:
						outputFolder: ''
						tasks: []
					files: {}
				js:
					deps: ['coffee']
					dev:
						outputFolder: ''
						tasks: []
					files: {}
			default: ['css']

		ga = new Gassetic config, 'dev', {}
		done()

	suite 'dependency test', ->
		test 'should return coffee', ->
			deps = ga.findDependentTypes 'js'
			assert.equal deps[0], 'coffee'

	suite 'build test', ->
		test 'should clean destination files', (done) ->
			gulp.src ''
			done()

		test 'should create file', (done) ->
			#gulp.
			done()