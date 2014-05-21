Gassetic = require '../gassetic'
assert = require 'assert'

suite 'Config', ->
	test 'should throw error about missing mimetypes', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config = {}
			gassetic.validateConfig()
		catch e
			assert.equal e, 'missing mimetypes in config'
			done()

	test 'should throw error about missing default tasks', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config = mimetypes: []
			gassetic.validateConfig()
		catch e
			assert.equal e, 'missing default task in config'
			done()

	test 'should throw error about missing envs', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config =
				mimetypes:
					css: {}
				default: []
			gassetic.validateConfig()
		catch e
			assert.equal e, 'missing environment dev in css mimetype'
			done()

	test 'should throw error about missing task list', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config =
				mimetypes: {
					css: {
						dev: {}
					}
				}
				default: []
			gassetic.validateConfig()
		catch e
			assert.equal e, 'missing task list for dev environment in css mimetype (it can be empty array but must be defined)'
			done()

	test 'should throw error about wrong tasks for env', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config =
				mimetypes:
					css: {
						dev: {
							tasks: ['less']
						}
					}
				default: []
			gassetic.validateConfig()
		catch e
			assert.equal e, 'invalid task \"less\" for css in dev environment, the structure must be like is {name: coffee, args: { bare: true }}'
			done()

	test 'should throw error about missing file list for mimetype', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config = {mimetypes: {
				css: {
					dev: {
						tasks: [{name: 'less'}]
					}
				}
				}, default: []}
			gassetic.validateConfig()
		catch e
			assert.equal e, 'missing file list for css mimetype'
			done()

	test 'should throw error about wrong file list for mimetype', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config = {mimetypes: {
				css: {
					dev: {
						tasks: [{name: 'less'}]
					}
					files: [ 'file' ]
				}
				}, default: ['css']}
			gassetic.validateConfig()
		catch e
			assert.equal e, 'wrong file list for css mimetype'
			done()

	test 'should throw error about missing outputFolder', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config = {mimetypes: {
				css: {
					dev: {
						tasks: [{name: 'less'}]
					}
					files: {}
				}
				}, default: ['css']}
			gassetic.validateConfig()
		catch e
			assert.equal e, 'missing outputFolder path in css dev'
			done()

	test 'should not throw an error', (done) ->
		try
			gassetic = new Gassetic 'dev'
			gassetic.config =
				mimetypes:
					css:
						dev:
							outputFolder: ''
							tasks: []
						files: {}
				default: ['css']
			gassetic.validateConfig()
			done()
		catch e
