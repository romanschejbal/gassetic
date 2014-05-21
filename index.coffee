gassetic = require './gassetic'
yargs = require 'yargs'

env = yargs.argv.env || 'dev'

gassetic = new gassetic env
return gassetic.clean().then ->
	unless yargs.argv._[0] == 'clean'
		gassetic.build().then ->
			unless yargs.argv._[0] == 'build'
				gassetic.watch()
