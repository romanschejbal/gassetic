# Gassetic [![build status](https://travis-ci.org/crossborne/gassetic.svg?branch=master)](https://travis-ci.org/crossborne/gassetic) ![deps status](https://david-dm.org/crossborne/gassetic.png)


## Summary
Gassetic is a Symfony2 Assetic replacement which is based on the gulp build tool for more 
comfortable frontend development and dependency management

## Advantages over assetic
- CSS live reload (injects modified css files into page without refreshing page)
- Easy to setup
- Use a package manager like [Bower](http://bower.io/) for JS dependencies
- Use the [gulp.js](http://gulpjs.com/) ecosystem to build your frontend assets
- Less magic! Easy to follow development flow

## How it works

Gassetic makes it easy to manage your frontend assets. You can install JS and CSS libs
through a package manager like [Bower](http://bower.io/) and then compile them using tools
from [gulp.js](http://gulpjs.com)

Gassetic replaces "<!-- {env}:{filename} --><!-- endbuild -->" strings in your 
templates with your generated CSS and JS files. In your gassetic.yml file you can 
specify which files and tasks to run on the input files and the names of the output
files.

[Gulp](http://gulpjs.com/plugins/) has literally hundreds of plugins that you can include in your
gulpfile and process on your frontend assets.


## Installation

1) Create your gassetic config

### yaml example with gassetic.yml
```yml
mimetypes:
    # This section contains the formatters for the css files
    css:
        # In 'dev' mode, use these settings
        dev:
            outputFolder: web/tmp/css  # The output files will be saved here
                                       #   (Add the tmp folder to gitignore so that your
                                       #   dev files aren't pushed to your repo)
            webPath:      /tmp/css     # The path used for the frontend
            # This is the list of tasks to run on the files
            # You can add gulp 
            tasks:
                - { name: less }
        # In 'prod' mode, use these settings
        prod:
            outputFolder: web/compiled/css  # The output folder for your saving your compiled files
            webPath:      /compiled/css     # The web path for the compiled files
            # Run these tasks on your compiled files
            tasks:
                - { name: less }
                - { name: minify }
                - { name: concat, args: '%filename%' }
                
        # This is the list of source files to apply the above settings
        files:
            frontend.css: # This is the output filename
                - assets/css/animate.min.css
                - assets/css/swipebox.css
                - assets/vendor/bootstrap-daterangepicker/daterangepicker-bs3.css
                - assets/vendor/bootstrap3-wysihtml5-bower/dist/bootstrap3-wysihtml5.css
                - assets/vendor/jquery-simplecolorpicker/jquery.simplecolorpicker.css
                - vendors/oh/emoji-bundle/Oh/EmojiBundle/vendor/emoji.css
            backend.css:
                - assets/vendor/bootstrap-daterangepicker/daterangepicker-bs3.css
                - assets/css/backend.css
                
        # Watch these files for changes (optional)
        watch:
            - assets/**/*.less
            - assets/**/*.css
            
    # This section contains the settings for your coffee files (optional)
    coffee:
        dev:
            outputFolder: assets/js/tmp
            tasks:
                - { name: coffee, args: { bare: true } }
                - { name: concat, args: '%filename%' }
        prod:
            outputFolder: assets/js/tmp
            tasks:
                - { name: coffee, args: { bare: true } }
                - { name: concat, args: '%filename%' }
        files:
            angularApp.js:
                - assets/angular/*.coffee
                - assets/angular/controllers/*.coffee
                - assets/angular/directives/*.coffee
                - assets/angular/services/*.coffee

    # This section contains the formatters for your JS files
    js:
        # This ensures the other media types are formatted before this (optional)
        deps:
            - coffee
        dev:
            outputFolder: web/tmp/js       # Save the files here
            webPath:      /tmp/js          # Specify the web path
            tasks: []                      # Don't apply any tasks
        prod:
            outputFolder: web/compiled/js  # Save the files here
            webPath:      /compiled/js     # Specify the web path
            tasks:
                - { name: concat, args: '%filename%' }
                - { name: uglify, args: { mangle: false } }
        
        # Here is a list of files to apply the above tasks to
        files:
            jquery.js: # This is the output filename
                - assets/vendor/jquery/jquery.js
            app.js:
                - web/html5lightbox/html5lightbox.js
                - assets/vendor/angular/angular.js
                - assets/vendor/angular-route/angular-route.js
                - assets/vendor/angular-sanitize/angular-sanitize.js
                - assets/js/tmp/angularApp.js/**/*.js

# This is the list of files/paths to search and find the replacement tags to insert the
# generated <script> or stylesheet tags
replacementPaths:
    - app/Resources/views/*.html.twig
    - src/**/*.html.twig

default:
    - js
    - css
```

2) Create ```gulpfile.js```
```js
var coffee, config, env, fs, gassetic, gulp, gutil, jsYaml, less, modules, yargs;
fs = require("fs");
gulp = require("gulp");
gutil = require("gulp-util");
jsYaml = require("js-yaml");
yargs = require("yargs");
gassetic = require("gassetic");

// install all the modules you need with npm install $module --save
modules = {};
modules.concat = require("gulp-concat");
modules.coffee = coffee = require("gulp-coffee");
modules.less = less = require("gulp-less");
modules.minify = require("gulp-minify-css");
modules.uglify = require("gulp-uglify");

// load the config
config = jsYaml.safeLoad(fs.readFileSync('gassetic.yml', 'utf8'));

env = yargs.argv.env || 'prod';

gulp.task('default', function() {
	var ga = new gassetic(config, 'dev', modules);
	ga.clean().then(function() {
		ga.build().then(function() {
			ga.watch();
		});
	});
});

gulp.task('build', function() {
	var ga = new gassetic(config, env, modules);
	ga.clean().then(function() {
		ga.build();
	});
});

gulp.task('clean', function() {
  var ga = new gassetic(config, env, modules);
  ga.clean();
});

```

3) Within root of your project run:

	npm install gassetic --save

4) Update your templates from

	<link rel="stylesheet" ...

To:

	{% if env == 'prod' %}
		<!-- dev:frontend.css --><!--endbuild-->
	{% else %}
		<!-- prod:frontend.css --><!--endbuild-->
	{% endif %}

The strings "<!-- {environment}:{filename} --><!-- endbuild -->" will be
searched for in the 'replacementPaths' list in the settings and replaced
with the generated tags and files

5) run ```gulp``` for watching and livereloading the files

6) run ```gulp build``` for production build

7) run ```gulp build --env=custom``` for custom build

Done.

#### @todo:
- better readme
- add custom script tags


The MIT License (MIT)

Copyright (c) 2014 Roman Schejbal
