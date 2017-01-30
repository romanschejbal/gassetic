import fs from 'fs';
import path from 'path';

describe('index', () => {
  const gassetic = () => require('./');

  beforeEach(() => {
    jest.resetModules();
  });

  describe('default', () => {
    let
      mockLoadFn,
      mockValidateFn,
      mockBabelModule,
      mockSassModule,
      delModule;

    beforeEach(() => {
      mockLoadFn = jest.fn(() => ({
        requires: {
          babel: 'gulp-babel',
          sass: 'gulp-sass',
          custom: 'custom'
        },
        mimetypes: {},
        default: []
      }));
      mockValidateFn = jest.fn();
      mockBabelModule = jest.fn();
      mockSassModule = jest.fn();
      delModule = jest.fn();

      jest.mock('./config', () => ({
        load: mockLoadFn,
        validate: mockValidateFn
      }));
      jest.mock('gulp-babel', mockBabelModule, { virtual: true });
      jest.mock('gulp-sass', mockSassModule, { virtual: true });
      jest.mock('custom', jest.fn(), { virtual: true });
      jest.mock('del', () => delModule);
    });

    it('loads configuration with default filename', () => {
      gassetic().default();
      expect(mockLoadFn).toHaveBeenCalledWith('gassetic.yml');
    });

    it('validates config', () => {
      gassetic().default();
      expect(mockValidateFn).toHaveBeenCalled();
    });

    it('loads modules specified inside "requires" section', () => {
      gassetic().default();
      expect(mockBabelModule).toHaveBeenCalled();
      expect(mockSassModule).toHaveBeenCalled();
    });

    it('deletes only user specified folders, not the outputFolder itself', () => {
      jest.mock('yargs', () => ({ argv: { _: ['clear'] } }));
      mockLoadFn = jest.fn(() => ({
        requires: {},
        mimetypes: {
          css: {
            dev: {
              files: {
                'test1.css': ['something.css'],
                'test2.css': ['something2.css']
              },
              tasks: [],
              outputFolder: 'dest'
            }
          }
        },
        default: ['css']
      }));
      gassetic().default();
      expect(delModule.mock.calls[0]).toEqual(['dest/test1.css']);
      expect(delModule.mock.calls[1]).toEqual(['dest/test2.css']);
    });
  });

  describe('getBuildSteps', () => {
    it('returns the correect order for buildSteps', () => {
      const steps = gassetic().getBuildSteps({
        mimetypes: {
          sass: {},
          css: { deps: ['sass'] },
          js: {}
        },
        default: ['css', 'js']
      });
      expect(steps).toEqual([
        ['sass', 'css'],
        ['js']
      ]);
    });

    it('returns the correct order for buildSteps recursively', () => {
      const steps = gassetic().getBuildSteps({
        mimetypes: {
          first: { deps: ['second'] },
          second: { deps: ['third'] },
          third: {}
        },
        default: ['first']
      });
      expect(steps).toEqual([
        ['third', 'second', 'first']
      ]);
    });

    it('returns the correct order for buildSteps recursively - advanced', () => {
      const steps = gassetic().getBuildSteps({
        mimetypes: {
          first: { deps: ['second'] },
          second: { deps: ['third', 'forth'] },
          third: {},
          forth: { deps: ['fifth'] },
          fifth: {}
        },
        default: ['first']
      });
      expect(steps).toEqual([
        ['fifth', 'forth', 'third', 'second', 'first']
      ]);
    });
  });

  describe('getTasks', () => {
    it('returns tasks for environment mapped to actual functions binded with arguments', () => {
      const modules = {
        babel: { doSomething: jest.fn(() => 1) },
        minify: jest.fn(() => 2),
        boo: { foo: { doo: jest.fn(() => 3) } }
      };
      const tasks = gassetic().getTasks(modules, {
        dev: {
          tasks: [
            { name: 'babel.doSomething' },
            { name: 'minify', args: { mini: true } },
            { name: 'boo.foo.doo', args: { a: 1, b: 2 } }
          ]
        }
      }, 'dev');
      expect(tasks).toEqual([
        { fn: modules.babel.doSomething, name: 'babel.doSomething' },
        { fn: modules.minify, args: { mini: true }, name: 'minify' },
        { fn: modules.boo.foo.doo, args: { a: 1, b: 2 }, name: 'boo.foo.doo' }
      ]);
    });

    it('returns custom callback when specified', () => {
      const modules = {
        babel: { doSomething: jest.fn(() => 1) },
        custom: jest.fn()
      };
      const tasks = gassetic().getTasks(modules, {
        dev: {
          tasks: [
            { name: 'babel', callback: 'custom' },
          ]
        }
      }, 'dev');
      expect(tasks).toEqual([
        { fn: modules.babel, callback: modules.custom, name: 'babel' },
      ]);
    });
  });

  describe('runTasks', () => {
    let src, pipe, dest;
    beforeEach(() => {
      src = jest.fn(() => ({ pipe }));
      pipe = jest.fn(() => ({ pipe, on: (event, cb) => cb() }));
      dest = jest.fn();
      jest.mock('gulp', () => ({ src, dest }));
    });

    it('runs all tasks on source files based on definition', () => {
      const tasks = [
        { fn: jest.fn(() => 1) },
        { fn: jest.fn(() => 2) }
      ];
      const outputFolder = './test';
      const webPath = '/web';
      gassetic().runTasks({
        'build.js': [
          './src/config/index.js',
          './src/config/index.spec.js'
        ]
      }, tasks, { outputFolder, webPath });
      expect(src).toHaveBeenCalledWith([
        './src/config/index.js',
        './src/config/index.spec.js'
      ]);
      expect(pipe).toHaveBeenCalledWith(1);
      expect(pipe).toHaveBeenCalledWith(2);
      expect(dest).toHaveBeenCalledWith(path.join(outputFolder, 'build.js'));
    });

    it('replaces arguments for filenames', () => {
      const tasks = [{ fn: jest.fn(), args: '%filename%' }];
      const outputFolder = './test';
      const webPath = '/web';
      gassetic().runTasks({
        'build.js': [
          './src/config/index.js',
          './src/config/index.spec.js'
        ]
      }, tasks, { outputFolder, webPath });
      expect(tasks[0].fn).toHaveBeenCalledWith('build.js');
    });

    it('passes in a callback if specified', () => {
      const mockCustomCallback = jest.fn();
      const tasks = [{ fn: jest.fn(), callback: mockCustomCallback }];
      const outputFolder = './test';
      const webPath = '/web';
      gassetic().runTasks({
        'build.js': [
          './src/config/index.js',
          './src/config/index.spec.js'
        ]
      }, tasks, { outputFolder, webPath });
      expect(tasks[0].fn).toHaveBeenCalledWith(mockCustomCallback);
    });

    it('returns files created', async () => {
      let i = 0;
      jest.mock('gulp-tap', () => (cb => [1, 2].forEach(() => cb({ path: `${process.cwd()}/test${++i}` }))));
      const tasks = [{ fn: jest.fn() }];
      const outputFolder = './test';
      const webPath = '/web';
      const files = await gassetic().runTasks({
        'build.js': [
          './src/config/index.js',
          './src/config/index.spec.js'
        ],
        'build.css': []
      }, tasks, { outputFolder, webPath });
      expect(files).toEqual({
        'build.js': ['/web/test1', '/web/test2'],
        'build.css': ['/web/test3', '/web/test4']
      });
    });

    it('uses forward slash for web filepath', async () => {
      let i = 0;
      jest.mock('gulp-tap', () => (cb => [1, 2].forEach(() => cb({ path: `${process.cwd().replace(/\//g, '\\')}\\test${++i}` }))));
      const tasks = [{ fn: jest.fn() }];
      const outputFolder = './test';
      const webPath = '/web';
      const files = await gassetic().runTasks({
        'build.js': [
          './src/config/index.js',
          './src/config/index.spec.js'
        ],
        'build.css': []
      }, tasks, { outputFolder, webPath });
      expect(files).toEqual({
        'build.js': ['/web/test1', '/web/test2'],
        'build.css': ['/web/test3', '/web/test4']
      });
    });
  });

  describe('replaceInTemplates', () => {
    it('replaces html comments with actual scripts', async () => {
      const template = `
        boo
        <!-- dev:build.js --><!-- endbuild -->
        foo
        <!-- dev:build.css -->
        <!-- endbuild -->
        pug
      `;
      const fsMock = {
        ...fs,
        readFileSync: jest.fn(() => template),
        writeFileSync: jest.fn()
      };
      jest.mock('fs', () => fsMock);
      await gassetic().replaceInTemplates(['./bin/*.js'], [{
        htmlTag: '<script src="%path%"></script>',
        files: {
          'build.js': ['./test1', './test2']
        }
      }, {
        htmlTag: '<link rel="stylesheet" type="text/css" href="{{ asset("%path%") }}">',
        files: {
          'build.css': ['./test1', './test2']
        }
      }], 'dev');
      expect(fsMock.readFileSync).toHaveBeenCalledWith('./bin/index.js', 'utf-8');
      expect(fsMock.writeFileSync).toHaveBeenCalledWith('./bin/index.js', `
        boo
        <!-- dev:build.js -->
          <script src="./test1"></script>
          <script src="./test2"></script>
        <!-- endbuild -->
        foo
        <!-- dev:build.css -->
          <link rel="stylesheet" type="text/css" href="{{ asset("./test1") }}">
          <link rel="stylesheet" type="text/css" href="{{ asset("./test2") }}">
        <!-- endbuild -->
        pug
      `);
    });

    it('if htmlTag is not provided, it uses default ones', async () => {
      const template = `
        boo
        <!-- dev:build.js --><!-- endbuild -->
        foo
        <!-- dev:build.css -->
        <!-- endbuild -->
        pug
      `;
      const fsMock = {
        ...fs,
        readFileSync: jest.fn(() => template),
        writeFileSync: jest.fn()
      };
      jest.mock('fs', () => fsMock);
      await gassetic().replaceInTemplates(['./bin/*.js'], [{
        files: {
          'build.js': ['./test1.js', './test2.js']
        }
      }, {
        files: {
          'build.css': ['./test1.css', './test2.css']
        }
      }], 'dev');
      expect(fsMock.readFileSync).toHaveBeenCalledWith('./bin/index.js', 'utf-8');
      expect(fsMock.writeFileSync).toHaveBeenCalledWith('./bin/index.js', `
        boo
        <!-- dev:build.js -->
          <script src="./test1.js"></script>
          <script src="./test2.js"></script>
        <!-- endbuild -->
        foo
        <!-- dev:build.css -->
          <link rel="stylesheet" type="text/css" href="./test1.css">
          <link rel="stylesheet" type="text/css" href="./test2.css">
        <!-- endbuild -->
        pug
      `);
    });
  });
});
