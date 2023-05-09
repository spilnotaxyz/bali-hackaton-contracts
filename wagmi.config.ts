import { defineConfig } from '@wagmi/cli';
import { foundry, react } from '@wagmi/cli/plugins';

export default defineConfig({
  out: '../bali-hackaton/lib/wagmi.hooks.ts',
  plugins: [
    foundry({
      project: '.',
      include: ['Partnership.sol/**'],
      forge: {
        build: true,
      },
    }),
    react({
      useContractEvent: false,
      useContract: false,
      useContractItemEvent: false,
    }),
  ],
});
