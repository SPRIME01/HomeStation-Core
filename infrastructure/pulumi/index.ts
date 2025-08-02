import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Configuration
const config = new pulumi.Config();
const kubeconfig = config.get("kubeconfig") || process.env.KUBECONFIG;

// Kubernetes provider
const provider = new k8s.Provider("homelab-k8s", {
    kubeconfig: kubeconfig,
});

// Create namespaces
const namespaces = [
    "traefik-system",
    "argocd",
    "vault",
    "supabase",
    "monitoring",
    "apps"
];

const createdNamespaces = namespaces.map(name =>
    new k8s.core.v1.Namespace(name, {
        metadata: { name },
    }, { provider })
);

// Export important information
export const kubernetesProvider = provider;
export const createdNamespaceNames = createdNamespaces.map(ns => ns.metadata.name);

// Example: Traefik configuration (could move current ArgoCD setup here)
export const traefikConfig = {
    chart: "traefik",
    version: "25.0.0",
    repository: "https://traefik.github.io/charts",
    namespace: "traefik-system",
    values: {
        ingressRoute: {
            dashboard: {
                enabled: true
            }
        },
        ports: {
            web: {
                redirectTo: {
                    port: "websecure"
                }
            },
            websecure: {
                tls: {
                    enabled: true
                }
            }
        },
        additionalArguments: [
            "--certificatesresolvers.letsencrypt.acme.email=admin@homestation.local",
            "--certificatesresolvers.letsencrypt.acme.storage=/data/acme.json",
            "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
        ]
    }
};

// Future: Uncomment to deploy Traefik via Pulumi instead of ArgoCD
// const traefik = new k8s.helm.v3.Chart("traefik", {
//     chart: traefikConfig.chart,
//     version: traefikConfig.version,
//     fetchOpts: {
//         repo: traefikConfig.repository,
//     },
//     namespace: traefikConfig.namespace,
//     values: traefikConfig.values,
// }, { provider, dependsOn: createdNamespaces });

console.log("🏗️  Homelab infrastructure defined with Pulumi");
console.log("📦 Namespaces:", namespaces.join(", "));
console.log("🔧 Run 'pulumi up' to deploy infrastructure");
