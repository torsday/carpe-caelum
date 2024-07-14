// env.d.ts
declare namespace NodeJS {
    interface ProcessEnv {
        VITE_THUNDERFOREST_API_KEY: string
        VITE_MAPBOX_API_TOKEN: string
    }
}
