import {
    ApolloClient,
    InMemoryCache,
    HttpLink,
    ApolloProvider,
} from '@apollo/client'
import { setContext } from '@apollo/client/link/context'
import React from 'react'

const httpLink = new HttpLink({
    uri: 'http://localhost:3000/graphql', // Adjust the URI to match your backend
})

const authLink = setContext((_, { headers }) => {
    return {
        headers: {
            ...headers,
        },
    }
})

const client = new ApolloClient({
    link: authLink.concat(httpLink),
    cache: new InMemoryCache(),
})

export const ApolloProviderWithClient: React.FC = ({ children }) => (
    <ApolloProvider client={client}>{children}</ApolloProvider>
)

export default client
