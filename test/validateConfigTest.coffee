Gassetic = require '../index'

suite 'Config', ->
	suite 'mimetypes', ->
		test 'should throw error about missing mimetypes', (done) ->
			try
				gassetic = new Gassetic {}, 'dev', {}
			catch e
				done()

	suite 'default tasks', ->
		test 'should throw error about missing default tasks', (done) ->
			try
				gassetic = new Gassetic mimetypes: [], 'dev', {}
			catch e
				done()


	suite 'environments', ->
		test 'should throw error about missing envs', (done) ->
			try
				gassetic = new Gassetic {
					mimetypes:
						css: {}
					default: []
				}, 'dev', {}
			catch e
				done()

	suite 'tasks', ->
		test 'should throw error about missing task list', (done) ->
			try
				gassetic = new Gassetic {mimetypes: {
					css: {
						dev: {}
					}
					}, default: []}, 'dev', {}
			catch e
				done()

	suite 'tasks', ->
		test 'should throw error about wrong tasks for env', (done) ->
			try
				gassetic = new Gassetic {mimetypes: {
					css: {
						dev: {
							tasks: ['less']
						}
					}
					}, default: []}, 'dev', {}
			catch e
				done()

	suite 'files', ->
		test 'should throw error about missing file list for mimetype', (done) ->
			try
				gassetic = new Gassetic {mimetypes: {
					css: {
						dev: {
							tasks: [{name: 'less'}]
						}
					}
					}, default: []}, 'dev', {}
			catch e
				done()

	suite 'files', ->
		test 'should throw error about wrong file list for mimetype', (done) ->
			try
				gassetic = new Gassetic {mimetypes: {
					css: {
						dev: {
							tasks: [{name: 'less'}]
						}
						files: [ 'file' ]
					}
					}, default: ['css']}, 'dev', {}
			catch e
				done()

	suite 'files', ->
		test 'should throw error about missing outputFolder', (done) ->
			try
				gassetic = new Gassetic {mimetypes: {
					css: {
						dev: {
							tasks: [{name: 'less'}]
						}
						files: [ 'file' ]
					}
					}, default: ['css']}, 'dev', {}
			catch e
				done()

	suite 'ok', ->
		test 'should not throw an error', (done) ->
			try
				gassetic = new Gassetic {mimetypes:
					css:
						dev:
							outputFolder: ''
							tasks: []
						files: {}
				default: ['css']
				},'dev', {}
				done()
			catch e
				console.log e

