import glob from 'glob';
import gulp from 'gulp';
import gutil from 'gulp-util';
import tap from 'gulp-tap';
import fs from 'fs';
import path from 'path';
import del from 'del';
import yargs from 'yargs';
import { load, validate } from './config/index.js';

// entry
export default async () => {
  const startTime = new Date();
  gutil.log(gutil.colors.blue('Loading gassetic.yml'));

  try {
    const env = yargs.argv.env || 'dev';

    const config = load('gassetic.yml');
    validate(config);

    const steps = getBuildSteps(config);

    // clear
    await Promise.all(steps.map(async deps =>
      Promise.all(deps.map(async dep =>
        del(config.mimetypes[dep][env].outputFolder)))));

    if (yargs.argv._[0] === 'clear')
      return;

    if (steps.length == 0)
      return;

    const modules = Object.entries(config.requires)
      .reduce((registry, [moduleKey, module]) => ({
        ...registry,
        [moduleKey]: require(module.startsWith('./') && path.join(process.cwd(), module) || module)
      }), {});

    const allFiles = (await Promise.all(steps.map(async deps => {
      const replacements = [];
      for (const dep of deps) {
        try {
          const tasks = getTasks(modules, config.mimetypes[dep], env);
          gutil.log(`${gutil.colors.yellow('▸ compiling')} ${gutil.colors.cyan(dep)}`);
          const files = await runTasks(config.mimetypes[dep].files, tasks, config.mimetypes[dep][env]);
          gutil.log(`${gutil.colors.green('✓')} finished ${gutil.colors.cyan(dep)}`);
          replacements.push({ htmlTag: config.mimetypes[dep][env].htmlTag, files });

          Object.entries(config.mimetypes[dep].files).map(([key, files]) =>
            gulp.watch(config.mimetypes[dep].watch || files, async () => {
              gutil.log(`${gutil.colors.yellow('▸ compiling')} ${gutil.colors.cyan(dep)}`);
              await runTasks({
                [key]: files
              }, tasks, config.mimetypes[dep][env]);
              gutil.log(`${gutil.colors.green('✓')} finished ${gutil.colors.cyan(dep)}`);
            }));

        } catch (e) {
          gutil.log(gutil.colors.red(e));
        }
      }
      return replacements;
    })))
      .reduce((a, b) => a.concat(b))
      .filter(a => a.htmlTag);

    gutil.log(gutil.colors.blue('Updating templates'));
    await replaceInTemplates(config.replacementPaths, allFiles, env);
    gutil.log(gutil.colors.green(`Done in ${Math.round((new Date() - startTime) / 100) / 10}s 👍`));
  } catch (e) {
    return gutil.log(gutil.colors.red(e));
  }
};

// steps
export const getBuildSteps = config =>
  config.default.map(mimetype => {
    return getBuildStepDependency(config, mimetype);
  });

const getBuildStepDependency = (config, mimetype) =>
  (config.mimetypes[mimetype].deps || [])
    .reduce((final, dep) => getBuildStepDependency(config, dep).concat(final), [])
    .concat([mimetype]);

// tasks
export const getTasks = (modules, mimetype, environment) =>
  mimetype[environment].tasks.map(task => {
    if (task.callback) {
      task.callback = modules[task.callback];
    }
    return task;
  }).map(({ name, ...task }) => ({
    ...task,
    fn: getModuleFunction(modules, name),
  }));

const getModuleFunction = (modules, taskName) =>
  taskName.split('.').reduce((scope, taskPart) => scope[taskPart], modules);

export const runTasks = async (files, tasks, { outputFolder, webPath }) =>
  (await Promise.all(Object.keys(files).map(destFilename => new Promise((resolve, reject) => {
    try {
      const filesCreated = [];
      tasks.reduce(
        (pipe, nextTask) => pipe.pipe(nextTask.callback ? nextTask.fn(nextTask.callback) : replaceArguments(nextTask, { filename: destFilename })()),
        gulp.src(files[destFilename])
      )
      .pipe(tap(file => {
        const fileWebPath = webPath + file.path.substring(path.join(process.cwd()).length);
        filesCreated.push(fileWebPath);
      }))
      .pipe(gulp.dest(outputFolder))
      .on('end', () => resolve({ [destFilename]: filesCreated }));
    } catch (e) {
      reject(e);
    }
  })))).reduce((all, next) => ({ ...all, ...next }), {});

const replaceArguments = ({ fn, args }, { filename }) => () =>
  fn(JSON.parse(JSON.stringify(args || '').replace('%filename%', filename)));

// replacement paths
export const replaceInTemplates = (replacementPaths, files, environment) =>
  new Promise(async (resolve, reject) => {
    try {
      const templates = (await Promise.all(replacementPaths.map(globPromised))).reduce((a, b) => a.concat(b));
      templates.forEach(template => {
        const content = files.reduce((newContent, mimetype) =>
          Object.entries(mimetype.files).reduce((newContent, [destFilename, files]) => {
            const scripts = files.map(path => mimetype.htmlTag.replace('%path%', path));
            return newContent.replace(
              new RegExp(`([ \t]*)<!-- ${environment}:${destFilename} -->([\\s\\S]*?)<!-- endbuild -->`, 'ig'),
              `$1<!-- ${environment}:${destFilename} -->\n$1${scripts.map(script => '  ' + script).join(`\n$1`)}\n$1<!-- endbuild -->`
            );
          }, newContent),
          fs.readFileSync(template, 'utf-8'));
        fs.writeFileSync(template, content);
      });
      resolve();
    } catch (e) {
      reject(e);
    }
  });

const globPromised = pattern =>
  new Promise(resolve => glob(pattern, {}, (err, matches) => resolve(matches)));
