This is an example of a custom task called 'shorter' which is passed as a callback to the 'rename' plugin

```yml
# gassetic.yml
requires:
  minify: gulp-minify-css
  concat: gulp-concat
  freeze: gulp-freeze
  rename: gulp-rename
  less: gulp-less
  uglify: gulp-uglify
  plumber: gulp-plumber
  shorter: tasks/shorter.js # custom task (see below)
mimetypes:
  less:
    prod:
      outputFolder: web/compiled/css
      webPath:      /compiled/css
      tasks:
        - { name: plumber }
        - { name: less }
        - { name: minify, args: { noAdvanced: true } }
        - { name: concat, args: '%filename%' }
        - { name: freeze }
        - { name: rename, callback: 'shorter' }
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

The custom task here receives the path to shorten
```js
// tasks/shorter.js
module.exports = function (path) {
	path.basename = path.basename.substr(0, path.basename.length - 27);
}
```
