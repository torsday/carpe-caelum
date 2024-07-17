import { defineConfig } from 'vitest/config'

export default defineConfig({
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: './test/setup.ts',
        coverage: {
            reporter: ['text', 'json', 'html'],
            include: ['src/**/*.{ts,tsx}'],
            exclude: ['node_modules', 'test/**/*'],
        },
        // Additional options for better control and debugging
        reporters: 'default',
        watch: false,
        isolate: true,
    },
})
