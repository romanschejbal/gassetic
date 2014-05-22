# Managing dependencies with Gassetic

If you need some preprocessing of files (for example coffeescript) then you can add the dependency using the 'deps' option:

```yml
requires:
    coffee: gulp-coffee
    concat: gulp-concat
    uglify: gulp-uglify
mimetypes:
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
replacementPaths:
    - web/*.html

default:
    - js
```
