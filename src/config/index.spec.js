import { load, validate } from './';

describe('config', () => {
  const configFilename = './src/config/config-sample.yml';

  it('throws an error when loading non-existing config', () => {
    const loadFn = () => load('blah');
    expect(loadFn).toThrow();
  });

  it('loads config', () => {
    const loadFn = () => load(configFilename);
    expect(loadFn).not.toThrow();
  });

  it('requires loads properly', () => {
    const config = load(configFilename);
    expect(config.requires).toBeDefined();
    [
      ['coffee', 'gulp-coffee'],
      ['concat', 'gulp-concat'],
      ['sourcemaps', 'gulp-sourcemaps'],
      ['plumber', 'gulp-plumber'],
      ['sass', 'gulp-sass'],
    ].forEach(pair => expect(config.requires[pair[0]]).toBe(pair[1]));
  });

  it('successfully validates config', () => {
    const config = load(configFilename);
    expect(() => validate(config)).not.toThrow();
  });

  describe('shouts when mandatory props are missing', () => {
    it('missing requires', () => {
      const config = load(configFilename);
      delete config.requires;
      expect(() => validate(config)).toThrowError('Missing "requires" section in config (leave blank if not needed)');
    });

    it('missing mimetypes', () => {
      const config = load(configFilename);
      delete config.mimetypes;
      expect(() => validate(config)).toThrowError('Missing "mimetypes" section in config');
    });

    it('missing environment definition for a mimetype', () => {
      const config = load(configFilename);
      delete config.mimetypes.css.dev;
      expect(() => validate(config)).toThrowError('Missing environment definition "dev" in "css" mimetype');
    });

    it('missing task list definition for a mimetype', () => {
      const config = load(configFilename);
      delete config.mimetypes.css.dev.tasks;
      expect(() => validate(config)).toThrowError('Missing task list definition in "dev" -> "css" mimetype (it can be empty array but must be defined)');
    });

    it('invalid task definition for a mimetype', () => {
      const config = load(configFilename);
      delete config.mimetypes.css.dev.tasks[0].name;
      expect(() => validate(config)).toThrowError('Invalid task definition in "dev" -> "css" mimetype - the structure must be like this {name: coffee, args: { bare: true }}');
    });

    it('undefined task definition for a mimetype', () => {
      const config = load(configFilename);
      config.requires = [];
      expect(() => validate(config)).toThrowError('Undefined task "plumber" in "dev" -> "css" mimetype, please include it in the "requires" section');
    });

    it('missing output folder for a mimetype', () => {
      const config = load(configFilename);
      delete config.mimetypes.css.dev.outputFolder;
      expect(() => validate(config)).toThrowError('Missing outputFolder in "dev" -> "css" mimetype');
    });

    it('missing replacementPaths', () => {
      const config = load(configFilename);
      delete config.replacementPaths;
      expect(() => validate(config)).toThrowError('Missing replacementPaths');
    });

    it('missing default tasks', () => {
      const config = load(configFilename);
      delete config.default;
      expect(() => validate(config)).toThrowError('Missing default tasks');
    });
  });
});
