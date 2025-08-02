import { Tree, formatFiles, installPackagesTask, names } from '@nx/devkit';

interface ServiceGeneratorSchema {
  name: string;
  language?: 'python' | 'node';
  database?: boolean;
}

export default async function (tree: Tree, options: ServiceGeneratorSchema) {
  const name = names(options.name).fileName;
  const targetDir = `apps/${name}`;

  // Create basic service structure
  const language = options.language || 'python';

  if (language === 'python') {
    // Create Python service files
    tree.write(`${targetDir}/src/main.py`, `#!/usr/bin/env python3
"""
${name} service
"""

def main():
    print("Hello from ${name}!")

if __name__ == "__main__":
    main()
`);

    tree.write(`${targetDir}/Dockerfile`, `FROM python:3.11-slim

WORKDIR /app
COPY src/ .
RUN pip install --no-cache-dir -r requirements.txt || true

CMD ["python", "main.py"]
`);

    tree.write(`${targetDir}/requirements.txt`, `# Add your Python dependencies here
fastapi==0.104.1
uvicorn==0.24.0
`);
  } else {
    // Create Node.js service files
    tree.write(`${targetDir}/src/main.ts`, `#!/usr/bin/env node
/**
 * ${name} service
 */

function main() {
    console.log("Hello from ${name}!");
}

if (require.main === module) {
    main();
}
`);

    tree.write(`${targetDir}/Dockerfile`, `FROM node:18-slim

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY src/ ./src/

CMD ["npm", "start"]
`);

    tree.write(`${targetDir}/package.json`, `{
  "name": "${name}",
  "version": "1.0.0",
  "main": "src/main.ts",
  "scripts": {
    "start": "node src/main.ts",
    "dev": "ts-node src/main.ts"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "ts-node": "^10.9.1",
    "typescript": "^5.0.0"
  }
}
`);
  }

  await formatFiles(tree);
  return () => installPackagesTask(tree);
}
