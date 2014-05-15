# gassetic

![build status](https://travis-ci.org/crossborne/gassetic.svg?branch=master)
![deps status](https://david-dm.org/crossborne/gassetic.png)

## Summary
Gassetic is a Symfony2 Assetic replacement which is based on gulp build tool for more comfortable development and dependency management

## Advantages over assetic
- css live reload (injects modified css files into page without refreshing page)
- easy to setup
- see it yourself!

## Installation

1) Create your gassetic config

### yaml example with gassetic.yml
```yml
mimetypes:
    css:
        dev:
            outputFolder: web/tmp/css
            webPath:      /tmp/css
            tasks:
                - { name: less }
        prod:
            outputFolder: web/compiled/css
            webPath:      /compiled/css
            tasks:
                - { name: less }
                - { name: minify }
                - { name: concat, args: '%filename%' }
        files:
            iido.css:
                - assets/css/animate.min.css
                - assets/css/swipebox.css
                - assets/css/less/iido/iido.less
                - assets/vendor/bootstrap-daterangepicker/daterangepicker-bs3.css
                - assets/vendor/bootstrap3-wysihtml5-bower/dist/bootstrap3-wysihtml5.css
                - assets/vendor/jquery-simplecolorpicker/jquery.simplecolorpicker.css
                - vendors/oh/emoji-bundle/Oh/EmojiBundle/vendor/emoji.css
        watch:
            - assets/**/*.less
            - assets/**/*.css

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

    js:
        deps:
            - coffee
        dev:
            outputFolder: web/tmp/js
            webPath:      /tmp/js
            tasks: []
        prod:
            outputFolder: web/compiled/js
            webPath:      /compiled/js
            tasks:
                - { name: concat, args: '%filename%' }
                - { name: uglify, args: { mangle: false } }
        files:
            jquery.js:
                - assets/vendor/jquery/jquery.js
            angular.js:
                - web/html5lightbox/html5lightbox.js
                - assets/vendor/angular/angular.js
                - assets/vendor/angular-route/angular-route.js
                - assets/vendor/angular-sanitize/angular-sanitize.js
                - assets/js/tmp/angularApp.js/**/*.js

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
		<!-- dev:iido.css --><!--endbuild-->
	{% else %}
		<!-- prod:iido.css --><!--endbuild-->
	{% endif %}



5) run ```gulp``` for watching and livereloading the files

6) run ```gulp build``` for production build

7) run ```gulp build --env=custom``` for custom build

Done.

#### @todo:
- better readme
- add custom script tags


The MIT License (MIT)

Copyright (c) 2014 Roman Schejbal
