gassetic = require './gassetic'
yargs = require 'yargs'

env = yargs.argv.env || 'dev'
config = yargs.argv.config || undefined
port = yargs.argv.port || undefined

gassetic = new gassetic env, port, config
return gassetic.clean().then ->
	switch yargs.argv._[0]
		when undefined
			gassetic.build().then ->
				gassetic.watch()
		when 'build'
			if yargs.argv._[1]?
				gassetic.build yargs.argv._[1]
			else
				do gassetic.build
		when 'clean'
			return true
		when 'clear'
			do gassetic.clear
