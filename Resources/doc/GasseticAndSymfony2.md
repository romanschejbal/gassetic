# Using Gassetic with Symfony2

Assetic has made it easy for Symfony2 developers to automatically process their frontend assets, but Assetic has some disadvantages. It is slow, doesn't manage dependencies and hard to debug. Gassetic is the next evolution of Assetic, using best practice tools for building assets and managing dependencies. It uses a node.js build tool called gulp.js to process a list of files, applying user-specified filters like less, uglify, concat etc and saving the generated tags in your templates. When used with a dependency manager like Bower, it becomes easy to install, update and manage your CSS and JS libraries.

## How Does it Work?

The majority of the configuration is in the gassetic.yml file. There are a number of environments that you can generate your assets in (for example 'prod' and 'dev'), then you can choose the gulp plugins to apply to each output file (for example less, minify), then specify the files that you would like to be processed. Gassetic then searches through your templates for the build string and replaces it with the generated tags and paths to the files.

## Installation

@todo

## Working with Environments

Gassetic can apply different filters depending on the environment, so that the files are still easy to debug in the dev environment and only minified in the prod environment.

In your Twig templates you can split out the dev and prod assets like this:

```twig
{% if app.environment == 'prod' %}
  <!-- prod:bootstrap.css --><!-- endbuild -->
  <!-- prod:frontend.css --><!-- endbuild -->
{% else %}
  <!-- dev:bootstrap.css --><!-- endbuild -->
  <!-- dev:frontend.css --><!-- endbuild -->
{% endif %}
```

## How to replace Assetic

Replacing Assetic is a relatively easy process

#### 1 Install your libraries via [Bower](http://bower.io/)

We install all our frontend assets to a folder called 'assets' in the root directory. You can install them to wherever you want.

```
bower search bootstrap
bower install bootstrap
```

#### 2 Change your Assetic code blocks

Your old code:

_layout.html.twig_
```twig
    {% javascripts
        '../vendor/twbs/bootstrap/js/bootstrap-transition.js'
        '../vendor/twbs/bootstrap/js/bootstrap-modal.js'
        '../vendor/twbs/bootstrap/js/bootstrap-button.js'
        '../vendor/twbs/bootstrap/js/bootstrap-alert.js'
        '../vendor/twbs/bootstrap/js/bootstrap-tooltip.js'
        '../vendor/twbs/bootstrap/js/bootstrap-carousel.js'
        '@MopaBootstrapBundle/Resources/public/js/mopabootstrap-collection.js'
        '../vendor/twbs/bootstrap/js/bootstrap-dropdown.js'
		'@LifoTypeaheadBundle/Resources/public/js/typeaheadbundle.js'
        output='js/compiled/main.js'
        filter='?yui_js'
    %}
    <script type="text/javascript" src="{{ asset_url }}"></script>
    {% endjavascripts %}
```

Your new code:

_layout.html.twig_
```twig
    {% if app.environment == 'prod' %}
        <!-- prod:bootstrap.js --><!-- endbuild -->
    {% else %}
        <!-- dev:bootstrap.js --><!-- endbuild -->a
    {% endif %}
```

_gassetic.yml_
```yaml
mimetypes:
    js:
        dev:
            outputFolder: web/tmp/js
            webPath:      /tmp/js
            tasks: []
        prod:
            outputFolder: web/compiled/js
            webPath:      /compiled/js
            tasks:
				# This task concats all the files into one
                - { name: concat, args: '%filename%' }
				# This task minifies the scripts
                - { name: uglify, args: { mangle: false } }
				# This is a cache busting gulp plugin that appends
				#  an md5 of the contents to the filename
                - { name: freeze }
        files:
            bootstrap.js:
                - assets/vendor/bootstrap/js/alert.js
                - assets/vendor/bootstrap/js/button.js
                - assets/vendor/bootstrap/js/carousel.js
                - assets/vendor/bootstrap/js/dropdown.js
                - assets/vendor/bootstrap/js/modal.js
                - assets/vendor/bootstrap/js/collapse.js
                - assets/vendor/bootstrap/js/tooltip.js
                - assets/vendor/bootstrap/js/popover.js
                - assets/vendor/bootstrap/js/transition.js
                - vendor/mopa/bootstrap-bundle/Mopa/Bundle/BootstrapBundle/Resources/public/js/mopabootstrap-collection.js
				- vendor/lifo/typeahead-bundle/Lifo/TypeaheadBundle/Resources/public/js/typeaheadbundle.js
```

#### 3. Run gulp

First build the dev environment

```
    gulp build --env=dev
```

And then gulp build for the prod environment

```
    gulp build --env=prod
```

The resulting output is:

```twig
    {% if app.environment == 'dev' %}
        <!-- dev:bootstrap.js -->
<script src="/tmp/js/bootstrap.js/alert.js"></script>
<script src="/tmp/js/bootstrap.js/button.js"></script>
<script src="/tmp/js/bootstrap.js/carousel.js"></script>
<script src="/tmp/js/bootstrap.js/dropdown.js"></script>
<script src="/tmp/js/bootstrap.js/modal.js"></script>
<script src="/tmp/js/bootstrap.js/collapse.js"></script>
<script src="/tmp/js/bootstrap.js/tooltip.js"></script>
<script src="/tmp/js/bootstrap.js/popover.js"></script>
<script src="/tmp/js/bootstrap.js/transition.js"></script>
<script src="/tmp/js/bootstrap.js/mopabootstrap-collection.js"></script>
<script src="/tmp/js/bootstrap.js/typeaheadbundle.js"></script>
<!-- endbuild -->
    {% else %}
        <!-- prod:bootstrap.js -->
<script src="/compiled/js/bootstrap.js/bootstrap_53fb1687a98969b989c30a866bb44e43567.js"></script>
<!-- endbuild -->
    {% endif %}
```

Because the dev environment keeps all your files separated, it makes it easy to debug individual scripts

*We recommend adding web/tmp to your .gitignore so that your dev assets are not committed*