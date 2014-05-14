(function() {
  var assert, gulp, modules, path, tap;

  assert = require('assert');

  gulp = require('gulp');

  tap = require('gulp-tap');

  path = require('path');

  modules = {};

  modules.coffee = require('gulp-coffee');

  modules.concat = require('gulp-concat');

  suite('Gassetic', function() {
    var ga;
    ga = null;
    setup(function(done) {
      var Gassetic, config;
      Gassetic = require('../index');
      config = {
        mimetypes: {
          css: {
            dev: {
              outputFolder: './test/dest',
              webPath: '/web',
              tasks: [
                {
                  name: 'concat',
                  args: '%filename%'
                }
              ]
            },
            files: {
              'concated.css': ['./test/src/css/**/*.css']
            }
          },
          coffee: {
            dev: {
              outputFolder: './test/dest',
              tasks: [
                {
                  name: 'coffee',
                  args: {
                    bare: true
                  }
                }
              ]
            },
            files: {
              'coffee.js': ['./test/src/coffee/**/*.coffee']
            }
          },
          js: {
            deps: ['coffee'],
            dev: {
              outputFolder: './test/dest',
              webPath: '/web',
              tasks: [
                {
                  name: 'concat',
                  args: '%filename%'
                }
              ]
            },
            files: {
              'js.js': ['./test/src/js/**/*.js', './test/dest/coffee.js/**/*.js']
            }
          }
        },
        "default": ['css', 'js'],
        replacementPaths: [
          {
            src: './test/templates/**/*.html',
            dest: './test/templates'
          }
        ]
      };
      ga = new Gassetic(config, 'dev', modules, false);
      return done();
    });
    suite('dependency test', function() {
      return test('should return string coffee', function() {
        var deps;
        deps = ga.findDependentTypes('js');
        return assert.equal(deps[0], 'coffee');
      });
    });
    return suite('build test', function() {
      test('should clean destination files', function(done) {
        return ga.clean().on('end', function() {
          var count, files, type;
          files = [];
          for (type in ga.getMimetypes()) {
            ga.getDestinationPathsForType(type).map(function(f) {
              return files.push(f);
            });
          }
          count = 0;
          return gulp.src(files).pipe(tap(function(file) {
            return count++;
          })).on('end', function() {
            assert.equal(count, 0);
            return done();
          });
        });
      });
      return test('should copy source files to destination folder', function(done) {
        return ga.build().then(function(what) {
          var cwd, files, type;
          files = [];
          for (type in ga.getMimetypes()) {
            ga.getDestinationPathsForType(type).map(function(f) {
              return files.push(f);
            });
          }
          cwd = ga.cwd();
          return gulp.src(files).pipe(tap(function(file) {
            var relative;
            relative = path.relative(cwd, file.path);
            return files.splice(files.indexOf(relative), 1);
          })).on('end', function() {
            assert.equal(files.length, 0);
            ga.watch();
            return done();
          });
        });
      });
    });
  });

}).call(this);
