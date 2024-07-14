import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'
import { createGlobalStyle } from 'styled-components'
import { ApolloProvider } from '@apollo/client'
import client from './apolloClient'

const GlobalStyle = createGlobalStyle`
    body {
        background-color: #002b36;
        margin: 0;
        color: #b58900;
        font-family: "Luxurious Roman", -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
    }
`

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <ApolloProvider client={client}>
            <GlobalStyle />
            <App />
        </ApolloProvider>
    </React.StrictMode>
)
