import { Tree, formatFiles, installPackagesTask, names } from '@nx/devkit';

interface ArgoAppGeneratorSchema {
  name: string;
  namespace?: string;
  source: string;
}

export default async function (tree: Tree, options: ArgoAppGeneratorSchema) {
  const name = names(options.name).fileName;

  // Create a simple ArgoCD application file
  const appContent = `apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${name}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${options.source}
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: ${options.namespace || 'dev'}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
`;

  tree.write(`infra/argocd/apps/${name}.yaml`, appContent);
  await formatFiles(tree);
  return () => installPackagesTask(tree);
}
