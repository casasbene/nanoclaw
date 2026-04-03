/**
 * Container runtime abstraction for NanoClaw.
 * BYPASS MODE: All Docker-specific logic is disabled. Agents run natively via Node.js.
 */
import os from 'os';

import { logger } from './logger.js';

/** The container runtime binary name (kept for API compatibility). */
export const CONTAINER_RUNTIME_BIN = 'docker';

/** CLI args needed for the container to resolve the host gateway. */
export function hostGatewayArgs(): string[] {
  if (os.platform() === 'linux') {
    return ['--add-host=host.docker.internal:host-gateway'];
  }
  return [];
}

/** Returns CLI args for a readonly bind mount. */
export function readonlyMountArgs(
  hostPath: string,
  containerPath: string,
): string[] {
  return ['-v', `${hostPath}:${containerPath}:ro`];
}

/** Stop a container by name. In bypass mode, this is a no-op. */
export function stopContainer(_name: string): void {
  // Bypass mode: agents run as child processes, not Docker containers.
  // The parent process uses container.kill() directly.
  logger.debug('stopContainer called in bypass mode (no-op)');
}

/** Ensure the container runtime is running, starting it if needed. */
export function ensureContainerRuntimeRunning(): void {
  // Docker bypass mode: agents run natively via Node.js — no Docker check needed.
  logger.info('Container runtime check skipped (bypass mode: agents run natively via Node.js)');
}

/** Kill orphaned NanoClaw containers from previous runs. */
export function cleanupOrphans(): void {
  // Bypass mode: no Docker containers to clean up.
  // Child processes are tracked and cleaned up by the Node.js process manager.
  logger.debug('cleanupOrphans skipped (bypass mode)');
}
