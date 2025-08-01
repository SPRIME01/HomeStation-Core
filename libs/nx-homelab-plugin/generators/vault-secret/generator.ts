import { Tree, formatFiles, installPackagesTask } from '@nrwl/devkit';
import { join } from 'path';
import { VaultSecretGeneratorSchema } from './schema';

export default async function (tree: Tree, options: VaultSecretGeneratorSchema) {
  const dir = `infra/vault-policies/${options.path.replace('/', '_')}`;
  tree.generateFiles(join(__dirname, 'files'), dir, {
    tmpl: '',
    path: options.path,
    policy: options.policy
  });
  await formatFiles(tree);
  return () => installPackagesTask(tree);
}
