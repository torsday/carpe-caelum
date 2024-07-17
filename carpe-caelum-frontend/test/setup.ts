// test/setup.ts
import { vi } from 'vitest'
import '@testing-library/jest-dom'

// Mock window.alert
globalThis.alert = vi.fn()

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: (query: string) => ({
        matches: false,
        media: query,
        onchange: null,
        addListener: vi.fn(), // Deprecated
        removeListener: vi.fn(), // Deprecated
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        dispatchEvent: vi.fn(),
    }),
})

// Mocking global objects if needed
globalThis.fetch = vi.fn()

// Mocking console methods to avoid cluttering the test output
globalThis.console.log = vi.fn()
globalThis.console.error = vi.fn()
globalThis.console.warn = vi.fn()
