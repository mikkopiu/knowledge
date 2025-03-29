#!/usr/bin/env -S pnpm exec tsx

/**
 * Given a cluster, service & expected version (read from tag `version`),
 * waits for an ECS deployment using the deployment circuit breaker with
 * automatic rollbacks to either finish successfully or to get rolled back.
 *
 * Rolled back deployments are considered a failure
 */

import {
  DescribeServicesCommand,
  DescribeTaskDefinitionCommand,
  ECSClient,
} from "@aws-sdk/client-ecs";
import arg from "arg";
import path from "node:path";

export async function findDeploymentByVersion({
  ecsClient,
  cluster,
  serviceName,
  expectedVersion,
}: {
  ecsClient: ECSClient;
  cluster: string;
  serviceName: string;
  expectedVersion: string;
}): Promise<string> {
  const { services } = await ecsClient.send(
    new DescribeServicesCommand({ cluster, services: [serviceName] }),
  );
  const service = services?.[0];
  if (!service?.deployments?.length)
    throw new Error("No deployments found for service");

  for (const deployment of service.deployments) {
    const { taskDefinition: taskDefArn } = deployment;
    const { tags } = await ecsClient.send(
      new DescribeTaskDefinitionCommand({
        taskDefinition: taskDefArn,
        include: ["TAGS"],
      }),
    );

    const versionTag = tags?.find((tag) => tag.key === "version");
    if (versionTag?.value === expectedVersion) {
      if (!deployment.id) throw new Error("Deployment ID is undefined");
      return deployment.id;
    }
  }

  throw new Error(
    `No deployment found with task definition version=${expectedVersion}`,
  );
}

export async function waitForDeployment({
  ecsClient,
  cluster,
  serviceName,
  deploymentId,
  signal,
}: {
  ecsClient: ECSClient;
  cluster: string;
  serviceName: string;
  deploymentId: string;
  signal: AbortSignal;
}) {
  const signalPromise = new Promise<never>((_, reject) => {
    signal.addEventListener(
      "abort",
      () => {
        reject(new Error("Timed out waiting for deployment to complete"));
      },
      { once: true },
    );
  });

  const checkDeployment = async () => {
    while (true) {
      signal.throwIfAborted();

      const { services } = await ecsClient.send(
        new DescribeServicesCommand({ cluster, services: [serviceName] }),
        { abortSignal: signal },
      );
      const service = services?.[0];
      if (!service) throw new Error("Service not found");

      const deployment = service.deployments?.find(
        (d) => d.id === deploymentId,
      );

      if (!deployment)
        throw new Error(`Deployment ID ${deploymentId} not found`);

      if (deployment.rolloutState === "COMPLETED") {
        console.log("INFO: ✅ Deployment succeeded");
        return;
      }

      if (deployment.rolloutState === "FAILED") {
        throw new Error("Deployment failed/rolled back");
      }

      // Wait before next check
      await new Promise((res) => setTimeout(res, 10_000));
    }
  };

  return Promise.race([checkDeployment(), signalPromise]);
}

async function main() {
  const args = arg({
    "--help": Boolean,
    "--cluster": String,
    "--service": String,
    "--version": String,
    "--timeout-seconds": Number,
  });

  const {
    "--help": helpPls,
    "--cluster": cluster,
    "--service": serviceName,
    "--version": expectedVersion,
    "--timeout-seconds": timeoutSeconds = 600,
  } = args;

  if (helpPls) {
    console.info(
      `Usage: ./${path.basename(__filename)} --cluster my-cluster --service my-service --version 1.2.3 [--timeout-seconds 10]`,
    );
    process.exit(0);
  }

  if (!cluster || !serviceName || !expectedVersion) {
    throw new Error(
      "ERROR: --cluster, --service and --version are required arguments.",
    );
  }

  console.log(
    `INFO: 🤖 Waiting for deployment of ${serviceName}@${expectedVersion} in cluster ${cluster}`,
  );

  const client = new ECSClient({});

  const deploymentId = await findDeploymentByVersion({
    ecsClient: client,
    cluster,
    serviceName,
    expectedVersion,
  });

  await waitForDeployment({
    ecsClient: client,
    cluster,
    serviceName,
    deploymentId,
    signal: AbortSignal.timeout(timeoutSeconds * 1_000),
  });
  console.log("🎉 Deployment completed successfully");
}

if (module === require.main) {
  main()
    .catch((err) => {
      console.error(
        `ERROR: ${err instanceof Error ? err.message : `An unknown error occurred: ${err}`}`,
      );
      process.exit(1);
    })
    .then(() => {
      process.exit(0);
    });
}
