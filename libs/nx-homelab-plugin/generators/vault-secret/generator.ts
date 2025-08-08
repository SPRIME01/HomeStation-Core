import { Tree, formatFiles, installPackagesTask } from '@nx/devkit';

interface VaultSecretGeneratorSchema {
  path: string;
  policy: string;
}

export default async function (tree: Tree, options: VaultSecretGeneratorSchema) {
  const safeName = options.path.replace(/\//g, '_');
  const dir = `infra/vault-policies/${safeName}`;

  // Create Vault policy file
  const policyContent = `# Policy for ${options.path}
path "${options.path}" {
  capabilities = ${JSON.stringify(options.policy.split(',').map(p => p.trim()))}
}

path "${options.path}/*" {
  capabilities = ${JSON.stringify(options.policy.split(',').map(p => p.trim()))}
}
`;

  tree.write(`${dir}/policy.hcl`, policyContent);

  // Create a simple setup script
  const setupScript = `#!/bin/bash
# Setup script for ${options.path}
vault policy write ${safeName} policy.hcl
echo "Policy created for path: ${options.path}"
`;

  tree.write(`${dir}/setup.sh`, setupScript);

  await formatFiles(tree);
  return () => installPackagesTask(tree);
}
