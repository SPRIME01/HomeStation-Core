import { Tree, formatFiles, installPackagesTask, names } from '@nrwl/devkit';
import { join } from 'path';
import { ArgoAppGeneratorSchema } from './schema';

export default async function (tree: Tree, options: ArgoAppGeneratorSchema) {
  const name = names(options.name).fileName;
  tree.generateFiles(join(__dirname, 'files'), `infra/argocd/${name}`, {
    tmpl: '',
    name,
    namespace: options.namespace,
    source: options.source
  });
  await formatFiles(tree);
  return () => installPackagesTask(tree);
}
