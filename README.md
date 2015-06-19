# Gassetic [![build status](https://travis-ci.org/romanschejbal/gassetic.svg?branch=master)](https://travis-ci.org/romanschejbal/gassetic) ![deps status](https://david-dm.org/romanschejbal/gassetic.png)


## Summary
Gassetic is an [Assetic](https://github.com/kriswallsmith/assetic) replacement which is based on the gulp build tool for more comfortable frontend development and dependency management

## Advantages over assetic
- Uses CSS [live reload](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei) (injects modified css files into page without refreshing page)
- Easy to setup
- Use a package manager like [Bower](http://bower.io/) for JS dependencies
- Use the [gulp.js](http://gulpjs.com/) ecosystem to build your frontend assets
- Less magic! Easy to follow development flow

## How it works

Gassetic makes it easy to manage your frontend assets. You can install JS and CSS libs through a package manager like [Bower](http://bower.io/) and then compile them using tools from [gulp.js](http://gulpjs.com)

Gassetic replaces ```"<!-- {env}:{filename} --><!-- endbuild -->"``` strings in your templates with your generated CSS and JS files. In your gassetic.yml file you can specify which files and tasks to run on the input files and the names of the output files.

[Gulp](http://gulpjs.com/plugins/) has literally hundreds of plugins that you can include in your gulpfile and process on your frontend assets.


## Installation

1) Create your gassetic config

### yaml example with gassetic.yml
```yml
requires:
    less: gulp-less
    minify: gulp-minify-css
    concat: gulp-concat
    uglify: gulp-uglify
mimetypes:
    # This section contains the formatters for the css files
    css:
        # In 'prod' mode, use these settings
        prod:
            outputFolder: web/compiled/css  # The output folder for your saving your compiled files
            webPath:      /compiled/css     # The web path for the compiled files
            # Run these tasks on your compiled files
            tasks:
                - { name: less }
                - { name: minify }
                - { name: concat, args: '%filename%' }
            htmlTag: '<link rel="stylesheet" type="text/css" href="{{ asset("%path%") }}">' # custom html tag

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

    # This section contains the formatters for your JS files
    js:
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
    - web/*.html
    - includes/**/*.html

default:
    - js
    - css
```

2) Within root of your project run:

	npm install gulp-less
    npm install gulp-minify-css
    npm install gulp-uglify
    npm install gulp-concat
    ... else that you need and have defined in the 'requires' section of the config

3) Update your templates from

	<link rel="stylesheet" ...

To:

    <!-- prod:frontend.css --><!-- endbuild -->

The strings "<!-- {environment}:{filename} --><!-- endbuild -->" will be searched for in the 'replacementPaths' list in the settings and replaced with the generated tags and files

4) install gassetic ```npm install -g gassetic```

5) run ```gassetic``` for watching and livereloading the files

6) run ```gassetic build --env=prod``` for production build

7) run ```gassetic build --env=custom``` for custom build

Done.

## More docs

- [Using Gassetic with Symfony2](https://github.com/romanschejbal/gassetic/blob/master/Resources/doc/GasseticAndSymfony2.md)
- [Advanced usage: Multiple environments](https://github.com/romanschejbal/gassetic/blob/master/Resources/doc/MultipleEnvironments.md)
- [Advanced usage: Managing dependencies](https://github.com/romanschejbal/gassetic/blob/master/Resources/doc/ManagingDependencies.md)
- [Advanced usage: Custom tasks](https://github.com/romanschejbal/gassetic/blob/master/Resources/doc/CustomTasks.md)
- [Advanced usage: Filtering tasks](https://github.com/romanschejbal/gassetic/blob/master/Resources/doc/FilteringTasks.md)
- [Advanced usage: Livereload port and parameters](https://github.com/romanschejbal/gassetic/blob/master/Resources/doc/LivereloadConfig.md)

## Contributions
### Launch tests
```sh
npm install
npm test
```

#### @todo:
- better readme

The MIT License (MIT)

Copyright (c) 2014 Roman Schejbal
