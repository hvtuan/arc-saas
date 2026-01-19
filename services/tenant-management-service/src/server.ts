// Copyright (c) 2023 Sourcefuse Technologies
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

/**
 * Server entry point for Tenant Management Service
 * This file bootstraps and starts the application
 */

import {ApplicationConfig} from '@loopback/core';
import {RestExplorerComponent} from '@loopback/rest-explorer';
import {TenantMgmtServiceApplication} from './application';

export {TenantMgmtServiceApplication};

export async function main(options: ApplicationConfig = {}) {
  // Set default options
  const opts: ApplicationConfig = {
    rest: {
      host: process.env.HOST || '0.0.0.0',
      port: +(process.env.PORT ?? 3005),
      ...options.rest,
    },
    ...options,
  };

  const app = new TenantMgmtServiceApplication(opts);

  // Enable embedded Swagger UI
  app.component(RestExplorerComponent);

  await app.boot();
  await app.start();

  const url = app.restServer.url;
  console.log(`Server is running at ${url}`);
  console.log(`Try ${url}/ping`);
  console.log(`OpenAPI spec at ${url}/openapi.json`);
  console.log(`API Explorer at ${url}/explorer`);

  return app;
}

// Start the application if this file is executed directly
if (require.main === module) {
  // Load environment variables
  require('dotenv-extended').load({
    schema: '.env.defaults',
    errorOnMissing: false,
    includeProcessEnv: true,
  });

  main().catch(err => {
    console.error('Cannot start the application.', err);
    process.exit(1);
  });
}
