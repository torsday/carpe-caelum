import { FlatCompat } from '@eslint/eslintrc'
import js from '@eslint/js'
import globals from 'globals'
import ts from '@typescript-eslint/eslint-plugin'
import parser from '@typescript-eslint/parser'
import reactPlugin from 'eslint-plugin-react'
import reactHooks from 'eslint-plugin-react-hooks'
import prettierPlugin from 'eslint-plugin-prettier'
import prettierConfig from 'eslint-config-prettier'
import process from 'process'

// Initialize compatibility helper
const compat = new FlatCompat({
    baseDirectory: process.cwd(),
    recommendedConfig: js.configs.recommended,
})

export default [
    {
        files: ['**/*.{js,mjs,cjs,ts,jsx,tsx}'],
        languageOptions: {
            parser: parser,
            parserOptions: {
                ecmaFeatures: { jsx: true },
                ecmaVersion: 'latest',
                sourceType: 'module',
            },
            globals: globals.browser,
        },
        settings: {
            react: {
                version: 'detect',
            },
        },
        plugins: {
            '@typescript-eslint': ts,
            react: reactPlugin,
            'react-hooks': reactHooks,
            prettier: prettierPlugin,
        },
        rules: {
            ...js.configs.recommended.rules,
            ...ts.configs.recommended.rules,
            ...reactPlugin.configs.recommended.rules,
            ...reactHooks.configs.recommended.rules,
            'prettier/prettier': 'error',
            '@typescript-eslint/no-unused-vars': [
                'error',
                { argsIgnorePattern: '^_' },
            ],
            '@typescript-eslint/no-explicit-any': 'error',
            'no-undef': 'error',
            'react/prop-types': 'off',
            'react-hooks/exhaustive-deps': 'warn',
        },
    },
    // Prettier configuration
    ...compat.config(prettierConfig),
]
