import { Tree } from '@nx/devkit';
import { createTreeWithEmptyWorkspace } from '@nx/devkit/testing';
import { argoAppGenerator, serviceGenerator, vaultSecretGenerator } from './index';

describe('nx-homelab-plugin generators', () => {
    let tree: Tree;

    beforeEach(() => {
        tree = createTreeWithEmptyWorkspace({ layout: 'apps-libs' });
    });

    describe('argo-app generator', () => {
        it('should create an ArgoCD application manifest with provided source and namespace', async () => {
            await argoAppGenerator(tree, { name: 'my-app', source: 'https://github.com/example/repo', namespace: 'dev' });

            const path = 'infra/argocd/apps/my-app.yaml';
            expect(tree.exists(path)).toBe(true);
            const content = tree.read(path)!.toString();
            expect(content).toContain('kind: Application');
            expect(content).toContain('name: my-app');
            expect(content).toContain('repoURL: https://github.com/example/repo');
            expect(content).toContain('namespace: dev');
        });
    });

    describe('service generator', () => {
        it('should scaffold a Python service by default', async () => {
            await serviceGenerator(tree, { name: 'api' });
            expect(tree.exists('apps/api/src/main.py')).toBe(true);
            expect(tree.exists('apps/api/Dockerfile')).toBe(true);
            expect(tree.exists('apps/api/requirements.txt')).toBe(true);
            const py = tree.read('apps/api/src/main.py')!.toString();
            expect(py).toContain('def main()');
        });

        it('should scaffold a Node service when language=node', async () => {
            await serviceGenerator(tree, { name: 'web', language: 'node' });
            expect(tree.exists('apps/web/src/main.ts')).toBe(true);
            expect(tree.exists('apps/web/Dockerfile')).toBe(true);
            expect(tree.exists('apps/web/package.json')).toBe(true);
            const ts = tree.read('apps/web/src/main.ts')!.toString();
            expect(ts).toContain('console.log("Hello from web!")');
        });
    });

    describe('vault-secret generator', () => {
        it('should create policy and setup script with capabilities', async () => {
            await vaultSecretGenerator(tree, { path: 'secret/data/myapp', policy: 'read,write' });
            const dir = 'infra/vault-policies/secret_data_myapp';
            const policyPath = `${dir}/policy.hcl`;
            const scriptPath = `${dir}/setup.sh`;

            expect(tree.exists(policyPath)).toBe(true);
            expect(tree.exists(scriptPath)).toBe(true);
            const policy = tree.read(policyPath)!.toString();
            expect(policy).toContain('path "secret/data/myapp"');
            expect(policy).toContain('capabilities = ["read","write"]');
            const script = tree.read(scriptPath)!.toString();
            expect(script).toContain('vault policy write secret_data_myapp policy.hcl');
        });
    });
});
