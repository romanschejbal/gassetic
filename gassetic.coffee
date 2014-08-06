clean = require 'gulp-clean'
frep = require "gulp-frep"
gulp = require "gulp"
gutil = require "gulp-util"
rename = require 'gulp-rename'
livereload = require "gulp-livereload"
git = require 'gulp-git'
path = require "path"
tap = require 'gulp-tap'
q = require 'q'
fs = require 'fs'
jsYaml = require 'js-yaml'

module.exports = class Gassetic
	constructor: (@env, @port, @log = true) ->
		@loadConfig()
		@includeModules()
		@validateConfig()

	###
		self explanatory
	###
	loadConfig: () ->
		@config = jsYaml.safeLoad fs.readFileSync 'gassetic.yml', 'utf8'

	###
		self explanatory
	###
	validateConfig: () ->
		if !@getMimetypes()?
			throw 'missing mimetypes in config'
		if !@getDefaultTypes()?
			throw 'missing default task in config'
		for key of @getMimetypes()
			if !@getMimetypes()[key][@env]?
				throw 'missing environment ' + @env + ' in ' + key + ' mimetype'
			if !@getMimetypes()[key][@env].tasks?
				throw 'missing task list for ' + @env + ' environment in ' + key + ' mimetype (it can be empty array but must be defined)'
			for task in @getMimetypes()[key][@env].tasks
				if !task.name
					throw 'invalid task "' + task.toString() + '" for ' + key + ' in ' + @env + ' environment, the structure must be like is {name: coffee, args: { bare: true }}'
				if !@config.requires or @getModuleMethod(@modules, task.name) == undefined
					throw 'undefined task ' + task.name
			if !@getMimetypes()[key].files?
				throw 'missing file list for ' + key + ' mimetype'

			src = @getSourceFilesForType key
			what = Object.prototype.toString
			if what.call(src) != '[object Object]'
				throw 'wrong file list for ' + key + ' mimetype'
			for file of src
				if what.call(file) != '[object String]'
					throw 'invalid file "' + file + '" for ' + key + ' in ' + @env + ' environment'

			if !@getMimetypes()[key][@env].outputFolder?
				throw 'missing outputFolder path in ' + key + ' ' + @env

	includeModules: () ->
		@modules = {}
		module.paths.unshift path.join @cwd(), 'node_modules'
		module.paths.unshift @cwd()
		for key, value of @config.requires
			@modules[key] = require value

	###
		@return {Object} mimetypes
	###
	getMimetypes: () ->
		@config.mimetypes

	###
		@return {Array} default tasks
	###
	getDefaultTypes: () ->
		@config.default

	###
	###
	getSourceFilesForType: (type) ->
		@getMimetypes()[type].files

	clean: () ->
		result = q.defer()
		files = []
		for type of @getMimetypes()
			@getDestinationPathsForType type
				.map (f) ->
					files.push f
		gulp.src(files, read: false).pipe(clean(force: true)).on 'end', ->
			result.resolve true
		result.promise

	getDestinationPathsForType: (type) ->
		paths = []
		for key, value of @getMimetypes()[type].files
			paths.push path.join @getMimetypes()[type][@env].outputFolder, key
		paths

	###
		Builds all
	###
	build: (type = null) ->
		@replaces = {}
		@watchFiles = []
		@gitAdd = []
		finalPromise = q.defer()
		promises = []
		if type == null
			for type in @getDefaultTypes()
				promises.push @buildType type
		else
			promises.push @buildType type
		done = q.all promises
		done.then =>
			@replaceInFiles @replaces
				.then ->
					finalPromise.resolve true
		finalPromise.promise

	cwd: () ->
		process.cwd()

	###
		Builds one type defined in config
	###
	buildType: (type) ->
		buildOne = (type) =>
			@replaces[type] = {}
			all = []
			tasks = @getMimetypes()[type][@env].tasks
			gutil.log 'Processing:', gutil.colors.magenta(type), 'with', gutil.colors.gray(
				(tasks.map (t) -> t.name + '(' + (if t.args then JSON.stringify(t.args) else '') + ')').join(', ')
			) if @log
			for destFilename of @getSourceFilesForType type
				all.push @buildFiles type, destFilename
			q.all all

		result = q.defer()
		deps = @findDependentTypes type
		if deps.length > 0
			all = []
			while deps.length > 0
				next = deps.shift()
				all.push @buildType next
			q.all all
				.then () =>
					buildOne.call @, type
						.then () ->
							result.resolve true
		else
			buildOne.call @, type
				.then () ->
					result.resolve true
		return result.promise

	###*
	###
	buildFiles: (type, destinationFilenameConfigKey) ->
		@replaces[type][destinationFilenameConfigKey] = []
		result = q.defer()
		tasks = @getMimetypes()[type][@env].tasks
		gutil.log ' -', gutil.colors.cyan(destinationFilenameConfigKey) if @log
		sourceFiles = @getMimetypes()[type].files[destinationFilenameConfigKey]
		destination = path.join @getMimetypes()[type][@env].outputFolder, destinationFilenameConfigKey
		pipe = gulp.src sourceFiles
		if @isDev() and (@getMimetypes()[type][@env].autoRenaming == undefined or @getMimetypes()[type][@env].autoRenaming == true)
			i = 0
			pipe = pipe.pipe rename (path) ->
				path.basename += '_' + i++
				path
		tasks.map (t) =>
			if !@getModuleMethod(@modules, t.name)?
				gutil.log gutil.colors.red 'calling ' + t.name + ' task but it has not been defined, add it into the requires array'
			if t.args?
				if typeof t.args == 'string' or typeof t.args == 'number' or (typeof t.args == 'object' and t.args.length == undefined)
					pipe = pipe.pipe @getModuleMethod(@modules, t.name) [@replaceArgs(t.args, destinationFilenameConfigKey)]...
				else
					pipe = pipe.pipe @getModuleMethod(@modules, t.name) @replaceArgs(t.args, destinationFilenameConfigKey)...
			else if t.callback?
				pipe = pipe.pipe @getModuleMethod(@modules, t.name) [@modules[t.callback]]...
			else
				pipe = pipe.pipe @getModuleMethod(@modules, t.name).call @
		pipe = pipe.pipe gulp.dest destination
			.pipe tap (f) =>
				if @getMimetypes()[type][@env].webPath
					webPath = f.path.substring (path.join(@cwd(), @getMimetypes()[type][@env].outputFolder)).length + 1
					webPath = path.join @getMimetypes()[type][@env].webPath, webPath
					@replaces[type][destinationFilenameConfigKey].push webPath
				@watchFiles.push f.path
				if @getMimetypes()[type][@env].autoGitAdd
					@gitAdd.push f.path
			.on 'end', ->
				result.resolve true
		return result.promise

	getModuleMethod: (module, taskName) ->
		levels = taskName.split '.'
		while levels.length > 0
			module = module[levels.shift()]
		module

	replaceArgs: (args, filename) ->
		string = JSON.stringify args
		string = string.replace '%filename%', filename
		JSON.parse string

	replaceInFiles: (replacements, callback) ->
		regexs = []
		for type of replacements
			for one of replacements[type]
				scripts = '\n'
				for filename in replacements[type][one]
					scripts += @buildScriptString(type, filename) + '\n'
				regexs.push
					pattern: new RegExp("<!-- " + @env + ':' + one + " -->([\\s\\S]*?)<!-- endbuild -->", "ig")
					replacement: "<!-- " + @env + ":" + one + " -->" + scripts + "<!-- endbuild -->"

		allfiles = []
		progress = []
		i = 0
		# find the templates first
		gulp.src @config.replacementPaths, read: false
			.pipe tap (file) =>
				allfiles.push file.path
				if @config.autoGitAdd
					@gitAdd.push file.path
			.on 'end', =>
				# do the replace
				for file in allfiles
					result = q.defer()
					progress.push result.promise
					((file, deferred) =>
						pipe = gulp.src file
							.pipe frep regexs
							.pipe gulp.dest path.dirname file
							.on 'end', =>
								deferred.resolve true
					) file, result
				if @gitAdd.length > 0
					gulp.src @gitAdd
						.pipe git.add()
		return q.all progress

	buildScriptString: (type, fileWebPath) ->
		fileWebPath = fileWebPath.replace /\\/g, '/' # windows workaround
		if @getMimetypes()[type][@env].htmlTag?
			return @getMimetypes()[type][@env].htmlTag.replace /%path%/g, fileWebPath
		else
			ext = path.extname fileWebPath
			switch ext
				when ".css"
					str = "<link rel=\"stylesheet\" href=\"" + fileWebPath + "\" />"
				when ".js"
					str = "<script src=\"" + fileWebPath + "\"></script>"
				else
					str = '<!-- extension not supported -->'
			str

	###
		Finds dependent types for type that needs to be run first
		@param {string} type
		@param {boolean} recursive
		@return {Array} dependency types
	###
	findDependentTypes: (type, recursive) ->
		deps = []
		if @config.mimetypes[type].deps?
			for d in @config.mimetypes[type].deps
				deps.push d
				if recursive
					deps = deps.concat @findDependentTypes d
		deps

	watch: () ->
		server = livereload @port

		toWatch = []
		for type in @getDefaultTypes()
			toWatch.push type
			for d in @findDependentTypes type, true
				if toWatch.indexOf(d) == -1
					toWatch.push d

		for type in toWatch
			if @getMimetypes()[type].watch?
				@watchSources @getMimetypes()[type].watch, type
			else
				for destinationFile of @getMimetypes()[type].files
					sources = @getMimetypes()[type].files[destinationFile]
					@watchSources sources, type, destinationFile

		gulp.watch @watchFiles
			.on 'change', (e) =>
				gutil.log gutil.colors.yellow new Date() if @log
				gutil.log gutil.colors.blue e.path if @log
				server.changed e.path

	watchSources: (sources, type, destinationFile = '*') ->
		gutil.log 'Watching', gutil.colors.cyan(sources.length), gutil.colors.magenta(type), 'paths for', gutil.colors.green(destinationFile), '...' if @log
		gulp.watch sources
			.on 'change', (e) =>
				if destinationFile != '*'
					destFiles = [destinationFile]
				else
					destFiles = []
					for f of @getMimetypes()[type].files
						destFiles.push f
				for f in destFiles
					@buildFiles type, f

	isDev: () ->
		@env == 'dev'
