gassetic = require './gassetic'
yargs = require 'yargs'

env = yargs.argv.env || 'dev'
port = yargs.argv.port || undefined

gassetic = new gassetic env, port
return gassetic.clean().then ->
	unless yargs.argv._[0] == 'clean'
		if yargs.argv._[1]?
			gassetic.build yargs.argv._[1]
		else
			gassetic.build().then ->
				unless yargs.argv._[0] == 'build'
					gassetic.watch()
