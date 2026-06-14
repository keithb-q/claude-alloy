import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  use: {
    baseURL: 'http://localhost:3001',
  },
  webServer: {
    command: 'npm run start --workspace=server',
    url: 'http://localhost:3001/api/health',
    reuseExistingServer: !process.env.CI,
  },
});
