# Filtering tasks
This is an example of a filtered task. Only the less files will be piped in the less command.

```yml
# gassetic.yml
requires:
    minify: gulp-minify-css
    concat: gulp-concat
    less: gulp-less
mimetypes:
    less:
        prod:
            outputFolder: web/compiled/css
            webPath:      /compiled/css
            tasks:
                - { name: less, filter: ['*.less'] }
                - { name: minify, args: { noAdvanced: true } }
                - { name: concat, args: '%filename%' }
        files:
            slideshow.css:
                - assets/css/less/eventstagram/base.less
                - assets/vendor/jquery-simplecolorpicker/jquery.simplecolorpicker.css
                - vendors/oh/emoji-bundle/Oh/EmojiBundle/vendor/emoji.css

replacementPaths:
    - app/Resources/views/*.html.twig
    - src/**/*.html.twig

default:
    - less


```
