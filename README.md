# Carpe Caelum

Seize the Sky

---

## Purpose

- Get the weather for anywher you can click or address you can search.

## Presentation

### UI

[![Carpe Caelum UI](https://img.youtube.com/vi/83ozblglHic/0.jpg)](https://youtu.be/83ozblglHic)

### GraphQL

[![Carpe Caelum GraphQL](https://img.youtube.com/vi/MsEosOgBj_0/0.jpg)](https://youtu.be/MsEosOgBj_0)

## Key Design Choices

- **Latitude and Longitude for Caching**: Instead of using zip codes, I opted to use latitude and longitude for cache keys. This is particularly beneficial for outdoor activities such as hiking, backpacking, and boating, where precise locations are more relevant.
- **Extended Weather Data Fields**: Although not all fields are currently utilized, I gather additional weather data for future project enhancements. In a production environment, I would restrict data gathering to necessary fields to reduce complexity for other developers.

## Design Overview

### Backend

- **Ruby on Rails**
- **Architecture**: Follows Domain Driven Design and adheres to SOLID principles.
- **API Functionality**: Utilizes Tomorrow.IO to get weather data.
- **Data Store**: Utilizes Redis for weather data storage, keyed by coordinates and time. Redis is chosen for its speed and built-in expiration.
- **RBS and Steep** for type checking.

### Frontend

- **React**
- **GraphQL**
- **File Structure**: Simplified due to backend-centric focus. Future iterations would modularize components into separate files.
- **Geolocation API**: Facilitates location lookup. MapBox is used here.
- **Map API**: Utilizing Thunderforest API.
- **Styling**: Uses styled-components, aligning with React’s ethos of encapsulated components.

## Getting Started

### Prerequisites

- Redis
- Ruby / Rails
- Node / NVM

### Setting Up Redis

#### Starting Redis

```sh
brew services start redis # or redis-server
```

#### Monitoring Redis

```sh
redis-cli monitor
```

### Rails Backend

#### Starting the Server

Navigate to the Rails root directory:

```sh
rails s
```

#### Running Tests

From the Rails root directory:

```sh
bundle exec rspec spec
bundle exec rspec spec --format documentation
```

### React Frontend

#### Starting the Development Server

```sh
npm run dev
```

## With more time...

- **Frontend Refactor**: Modularize components into individual files for better maintainability.
- **Test Coverage**: Increase the scope and depth of testing.
- **Error Handling**: Implement more detailed exception handling and HTTP status code responses.
- **Cache Indicator UI**: I chose not to implement a UI feature indicating whether data was retrieved from the cache. This decision was based on time constraints and feeling I've expressed enough in the code to show the flow of how it would be done.

