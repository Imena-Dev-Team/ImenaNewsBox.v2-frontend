import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /**
   * Emits `.next/standalone`: a self-contained server with only the files and
   * `node_modules` it actually needs. The production Docker image runs that
   * instead of installing dependencies, which keeps the image small.
   * @see https://nextjs.org/docs/app/api-reference/config/next-config-js/output
   */
  output: "standalone",
};

export default nextConfig;
