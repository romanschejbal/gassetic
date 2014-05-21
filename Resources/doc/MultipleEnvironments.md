# Managing multiple environments with Gassetic

Most of the time you want to have different scripts for development and production environments. This makes it easy to debug in your dev environment while keeping the processed files for production.

```yaml
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
            htmlTag: '<script type="text/javascript" src="{{ asset("%path%") }}"></script>' # custom html tag

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
    - app/layouts/*.php
    - web/**/*.html

default:
    - js
    - css
```

This will replace the following strings with the generated files

```php
<?php if($environment == 'prod') : ?>
  <!-- prod:frontend.css --><!-- endbuild -->
<?php else: ?>
  <!-- dev:frontend.css --><!-- endbuild -->
<?php endif ?>

<?php if($environment == 'prod') : ?>
  <!-- prod:jquery.js --><!-- endbuild -->
  <!-- prod:app.js --><!-- endbuild -->
<?php else: ?>
  <!-- dev:jquery.js --><!-- endbuild -->
  <!-- dev:app.js --><!-- endbuild -->
<?php endif ?>
```

