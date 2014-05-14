(function() {
  var Gassetic;

  Gassetic = require('../index');

  suite('Config', function() {
    test('should throw error about missing mimetypes', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({}, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    test('should throw error about missing default tasks', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({
          mimetypes: []
        }, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    test('should throw error about missing envs', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({
          mimetypes: {
            css: {}
          },
          "default": []
        }, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    test('should throw error about missing task list', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({
          mimetypes: {
            css: {
              dev: {}
            }
          },
          "default": []
        }, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    test('should throw error about wrong tasks for env', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({
          mimetypes: {
            css: {
              dev: {
                tasks: ['less']
              }
            }
          },
          "default": []
        }, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    test('should throw error about missing file list for mimetype', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({
          mimetypes: {
            css: {
              dev: {
                tasks: [
                  {
                    name: 'less'
                  }
                ]
              }
            }
          },
          "default": []
        }, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    test('should throw error about wrong file list for mimetype', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({
          mimetypes: {
            css: {
              dev: {
                tasks: [
                  {
                    name: 'less'
                  }
                ]
              },
              files: ['file']
            }
          },
          "default": ['css']
        }, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    test('should throw error about missing outputFolder', function(done) {
      var e, gassetic;
      try {
        return gassetic = new Gassetic({
          mimetypes: {
            css: {
              dev: {
                tasks: [
                  {
                    name: 'less'
                  }
                ]
              },
              files: ['file']
            }
          },
          "default": ['css']
        }, 'dev', {});
      } catch (_error) {
        e = _error;
        return done();
      }
    });
    return test('should not throw an error', function(done) {
      var e, gassetic;
      try {
        gassetic = new Gassetic({
          mimetypes: {
            css: {
              dev: {
                outputFolder: '',
                tasks: []
              },
              files: {}
            }
          },
          "default": ['css']
        }, 'dev', {});
        return done();
      } catch (_error) {
        e = _error;
        return console.log(e);
      }
    });
  });

}).call(this);
