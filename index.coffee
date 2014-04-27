concat = require "gulp-concat"
clean = require 'gulp-clean'
frep = require "gulp-frep"
fs = require "fs"
gulp = require "gulp"
gutil = require "gulp-util"
livereload = require "gulp-livereload"
path = require "path"

module.exports = class Gassetic
  constructor: (@config, @env, @modules) ->
    @validateConfig()

  ###
    self explanatory
  ###
  validateConfig: () ->
    if !@getMimetypes()?
      throw 'missing mimetypes in config'
    if !@getDefaultTasks()?
      throw 'missing default task in config'
    for key of @getMimetypes()
      if !@getMimetypes()[key][@env]?
        throw 'missing environment ' + @env + ' in ' + key + ' mimetype'
      if !@getMimetypes()[key][@env].tasks?
        throw 'missing task list for ' + @env + ' environment in ' + key + ' mimetype (it can be empty array but must be defined)'
      for task in @getMimetypes()[key][@env].tasks
        if !task.name
          throw 'invalid task "' + task.toString() + '" for ' + key + ' in ' + @env + ' environment, the structure must be like is {name: coffee, args: { bare: true }}'
      if !@getMimetypes()[key].files?
        throw 'missing file list for ' + key + ' mimetype'

      if !@getMimetypes()[key][@env].outputFolder?
        throw 'missing outputFolder path in ' + key + ' ' + @env

      src = @getSourceFilesForType key
      what = Object.prototype.toString
      if what.call(src) != '[object Object]'
        throw 'wrong file list for ' + key + ' mimetype'
      for file of src
        if what.call(file) != '[object String]'
          throw 'invalid file "' + file + '" for ' + key + ' in ' + @env + ' environment'

  ###
    @return {Object} mimetypes
  ###
  getMimetypes: () ->
    @config.mimetypes

  ###
    @return {Array} default tasks
  ###
  getDefaultTasks: () ->
    @config.default

  ###
  ###
  getSourceFilesForType: (type) ->
    @getMimetypes()[type].files

  clean: () ->
    gulp.src([
      config.CSS_LIVE_OUTPUT_FOLDER
      config.JS_LIVE_OUTPUT_FOLDER
    ],
      read: false
    ).pipe(clean(force: true)).pipe gulp.dest("./")

  ###
    Builds all
  ###
  build: () ->
    finish = () ->
      replaceInFiles ENV, ->
        done()

    alreadyProcessed = []
    runningTasks = 0
    for type in @getDefaultTasks()
      ((type) ->
        buildType = ->
          for destFilename of config.mimetypes[type].files
            runningTasks++
            buildFile type, destFilename
              .on 'end', ->
                if --runningTasks == 0
                  finish()

        runningSubTasks = 0
        deps = findDependentTasks type
        for d in deps
          if alreadyProcessed.indexOf(d) == -1
            alreadyProcessed.push d
            for destFilename of config.mimetypes[d].files
              runningSubTasks++
              buildFile d, destFilename
                .on 'end', ->
                  if --runningSubTasks == 0
                    buildType()
        if runningSubTasks == 0
          buildType()
      ) type

  ###
    Builds one type defined in config
  ###
  buildType: (type) ->
    for destFilename of @getSourceFilesForType(type)
      runningTasks++
      buildFile type, destFilename

  ###
  ###
  buildFile = (type, destinationFilenameConfigKey) ->
    tasks = config.mimetypes[type][ENV].tasks
    gutil.log 'Processing:', gutil.colors.magenta(type), 'with', gutil.colors.gray(
      (tasks.map (t) -> t.name + '(' + (if t.args then JSON.stringify(t.args) else '') + ')').join(', ')
    )
    sourceFiles = getSourceFiles type, destinationFilenameConfigKey
    destinationFilePath = path.join config.mimetypes[type][ENV].outputFolder, destinationFilenameConfigKey
    gutil.log ' -', gutil.colors.cyan(destinationFilenameConfigKey), '->', gutil.colors.green(destinationFilePath)
    for srcFilename in sourceFiles
      gutil.log gutil.colors.gray('    - ' + srcFilename)
    pipe = gulp.src sourceFiles
    for task in tasks
      if task.args?
        pipe = pipe.pipe modules[task.name] [task.args]...
      else
        pipe = pipe.pipe modules[task.name].call @
    pipe = pipe.pipe concat destinationFilenameConfigKey
    pipe.pipe gulp.dest config.mimetypes[type][ENV].outputFolder

  ###
    Finds dependent types for type that needs to be run first
    @param {string} type
    @return {Array} dependency types
  ###
  findDependentTypes: (type) ->
    deps = []
    if @config.mimetypes[type].deps?
      for d in @config.mimetypes[type].deps
        deps.push d
        deps = deps.concat @findDependentTypes d
    deps.reverse()

###
buildFile = (type, destinationFilenameConfigKey) ->
  tasks = config.mimetypes[type][ENV].tasks
  gutil.log 'Processing:', gutil.colors.magenta(type), 'with', gutil.colors.gray(
    (tasks.map (t) -> t.name + '(' + (if t.args then JSON.stringify(t.args) else '') + ')').join(', ')
  )
  sourceFiles = getSourceFiles type, destinationFilenameConfigKey
  destinationFilePath = path.join config.mimetypes[type][ENV].outputFolder, destinationFilenameConfigKey
  gutil.log ' -', gutil.colors.cyan(destinationFilenameConfigKey), '->', gutil.colors.green(destinationFilePath)
  for srcFilename in sourceFiles
    gutil.log gutil.colors.gray('    - ' + srcFilename)
  pipe = gulp.src sourceFiles
  for task in tasks
    if task.args?
      pipe = pipe.pipe modules[task.name] [task.args]...
    else
      pipe = pipe.pipe modules[task.name].call @
  pipe = pipe.pipe concat destinationFilenameConfigKey
  pipe.pipe gulp.dest config.mimetypes[type][ENV].outputFolder

getSourceFiles = (type, destinationFilenameConfigKey) ->
  config.mimetypes[type].files[destinationFilenameConfigKey]

buildScriptString = (fileWebPath) ->
  ext = path.extname fileWebPath
  switch ext
    when ".css"
      str = "<link rel=\"stylesheet\" href=\"" + fileWebPath + "\" />"
    when ".js"
      str = "<script src=\"" + fileWebPath + "\"></script>"
    else
      str = '<!-- extension not supported -->'
  str

replaceInFiles = (searchString, callback) ->
  replacements = []
  for type of config.mimetypes
    for file of config.mimetypes[type].files
      if config.mimetypes[type][ENV].webPath?
        webPath = config.mimetypes[type][ENV].webPath
        fileWebPath = path.join webPath, file
        replacements.push
          pattern: new RegExp("<!-- " + searchString + ":" + file + " -->([\\s\\S]*?)<!-- endbuild -->", "ig")
          replacement: "<!-- " + searchString + ":" + file + " -->" + buildScriptString(fileWebPath) + "<!-- endbuild -->"

  sectionCounting = 0
  for section in config.replacementFiles
    sectionCounting++
    ((section) ->
      gulp.src section.src
        .pipe frep replacements
        .pipe gulp.dest section.dest
        .on 'end', ->
          gutil.log 'Replacing in', gutil.colors.blue(section.src)
          if --sectionCounting == 0
            callback.call()
    ) section

# THE DEFAULT TASK
gulp.task 'default', (done) ->
  finish = () ->
    replaceInFiles ENV, ->
      done()

  alreadyProcessed = []
  runningTasks = 0
  for type in config.default
    ((type) ->
      buildType = ->
        for destFilename of config.mimetypes[type].files
          runningTasks++
          buildFile type, destFilename
            .on 'end', ->
              if --runningTasks == 0
                finish()

      runningSubTasks = 0
      deps = findDependentTasks type
      for d in deps
        if alreadyProcessed.indexOf(d) == -1
          alreadyProcessed.push d
          for destFilename of config.mimetypes[d].files
            runningSubTasks++
            buildFile d, destFilename
              .on 'end', ->
                if --runningSubTasks == 0
                  buildType()
      if runningSubTasks == 0
        buildType()
    ) type

# WATCH TASK
gulp.task 'watch', ['default'], () ->
  server = livereload()
  watchIt = (sources, type, destFile) ->
    gutil.log 'Watching', gutil.colors.cyan(sources.length), gutil.colors.magenta(type), 'paths for', gutil.colors.green(destFile), '...'
    gulp.watch sources
      .on 'change', (e) ->
        if destFile != '*'
          destFiles = [destFile]
        else
          destFiles = []
          for f of config.mimetypes[type].files
            destFiles.push f
        for f in destFiles
            buildFile type, f

  # create array of types to watch
  allTypes = []
  for type in config.default
    allTypes.push type
    for d in findDependentTasks(type)
      if allTypes.indexOf(d) == -1
        allTypes.push d

  # watch sources
  for type in allTypes
    if config.mimetypes[type].watch?
      watchIt config.mimetypes[type].watch, type, '*'
      continue
    for destFile of config.mimetypes[type].files
      sources = getSourceFiles(type, destFile)
      ((type, destFile) ->
        watchIt sources, type, destFile
      ) type, destFile

  # watch destination and notify livereload
  for type in allTypes
    for destFile of config.mimetypes[type].files
      relativePath = path.join config.mimetypes[type][ENV].outputFolder, destFile
      if config.mimetypes[type][ENV].webPath?
        gulp.watch relativePath
          .on 'change', (e) ->
            gutil.log gutil.colors.yellow new Date()
            gutil.log gutil.colors.blue e.path
            server.changed e.path

gulp.task "clean", ->
  return
  gulp.src([
    config.CSS_LIVE_OUTPUT_FOLDER
    config.JS_LIVE_OUTPUT_FOLDER
  ],
    read: false
  ).pipe(clean(force: true)).pipe gulp.dest("./")
###