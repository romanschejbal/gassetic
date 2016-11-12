import yaml from 'js-yaml';
import fs from 'fs';

export const load = filename =>
  yaml.safeLoad(fs.readFileSync(filename, 'utf-8'));

export const validate = (configuration, env = 'dev') => {
  if (!configuration.requires)
    throw new Error('Missing "requires" section in config (leave blank if not needed)');

  if (!configuration.mimetypes)
    throw new Error('Missing "mimetypes" section in config');

  if (!configuration.default || !Array.isArray(configuration.default))
    throw new Error('Missing default tasks');

  if (!configuration.replacementPaths || !Array.isArray(configuration.replacementPaths))
    throw new Error('Missing replacementPaths');

  Object.keys(configuration.mimetypes).forEach(key => {
    if (!configuration.mimetypes[key][env])
      throw new Error(`Missing environment definition "${env}" in "${key}" mimetype`);

    if (!configuration.mimetypes[key][env].tasks)
      throw new Error(`Missing task list definition in "${env}" -> "${key}" mimetype (it can be empty array but must be defined)`);

    if (!configuration.mimetypes[key][env].outputFolder)
      throw new Error(`Missing outputFolder in "${env}" -> "${key}" mimetype`);

    configuration.mimetypes[key][env].tasks.forEach(task => {
      if (!task.name)
        throw new Error(`Invalid task definition in "${env}" -> "${key}" mimetype - the structure must be like this {name: coffee, args: { bare: true }}`);

      if (!configuration.requires[task.name.split('.').shift()])
        throw new Error(`Undefined task "${task.name}" in "${env}" -> "${key}" mimetype, please include it in the "requires" section`);
    });
  });
};
