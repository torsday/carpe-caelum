import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'
import dotenv from 'dotenv'
import process from 'process'

dotenv.config()

export default defineConfig({
    plugins: [react()],
    define: {
        'process.env': process.env,
    },
})
