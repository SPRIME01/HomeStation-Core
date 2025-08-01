import { Tree, formatFiles, installPackagesTask, names } from '@nrwl/devkit';
import { join } from 'path';
import { ServiceGeneratorSchema } from './schema';

export default async function (tree: Tree, options: ServiceGeneratorSchema) {
  const name = names(options.name).fileName;
  const targetDir = `apps/${name}`;
  tree.generateFiles(join(__dirname, 'files'), targetDir, {
    tmpl: '',
    name,
    language: options.language,
    database: options.database
  });
  await formatFiles(tree);
  return () => installPackagesTask(tree);
}
