# Carpe Caelum

Seize the Sky

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Purpose](#purpose)
- [Demo](#demo)
  - [UI](#ui)
  - [GraphQL](#graphql)
- [Key Design Choices](#key-design-choices)
- [Design Overview](#design-overview)
  - [Backend](#backend)
  - [Frontend](#frontend)
  - [Systems Design Considerations](#systems-design-considerations)
    - [Backend](#backend-1)
    - [Frontend](#frontend-1)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Redis](#redis)
    - [Starting Redis](#starting-redis)
    - [Monitoring Redis](#monitoring-redis)
  - [Rails Backend](#rails-backend)
    - [Starting the Server](#starting-the-server)
    - [Running Tests](#running-tests)
    - [Linting](#linting)
  - [React Frontend](#react-frontend)
    - [Starting the Development Server](#starting-the-development-server)
    - [Running Tests](#running-tests-1)
    - [Linting](#linting-1)
- [With More Time...](#with-more-time)


---

## Purpose

- Get the weather for anywhere you can click or address you can search.

## Demo

_Click images below for video_

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
- **Architecture**: Follows Domain-Driven Design (DDD) and adheres to SOLID principles.
- **API Functionality**: Utilizes Tomorrow.IO to retrieve weather data.
- **Data Store**: Utilizes Redis for weather data storage, keyed by coordinates and time. Redis is chosen for its speed and built-in expiration.
- **RBS and Steep** for type checking.

### Frontend

- **React**
- **GraphQL**
- **Geolocation API**: Facilitates location lookup. MapBox is used here.
- **Map API**: Utilizes Thunderforest API.
- **Styling**: Uses styled-components, aligning with React’s ethos of encapsulated components.

### Systems Design Considerations

#### Backend

- **Scalability**:
    - **Ruby on Rails**: Provides rapid development capabilities and can scale with appropriate optimizations.
    - **Redis**: Efficiently handles large volumes of weather data, providing quick read/write operations.

- **Resiliency**:
    - **Redis**: Supports persistence and replication, enhancing fault tolerance and data reliability.
    - **Domain-Driven Design (DDD)**: Encourages separation of concerns, making the system more robust, easier to maintain, and easier for large teams to build upon.

- **Performance**:
    - **Redis**: Chosen for its speed and ability to handle high throughput, ensuring low-latency access to weather data.

- **Maintainability**:
    - **SOLID principles**: Ensures clean, modular, and maintainable code.
    - **RBS and Steep**: Enhances type safety, reducing runtime errors and improving code reliability.

- **Security**:
    - Not focusing on this for this particular exercise.

#### Frontend

- **Scalability**:
    - **React and GraphQL**: Scalable technologies that can handle increasing frontend complexity and data requirements.

- **Performance**:
    - **GraphQL**: Efficient data fetching, reducing over-fetching and under-fetching issues.

- **Maintainability**:
    - **Styled-components**: Promotes encapsulated styling, making components easier to manage and modify.

## Getting Started

### Prerequisites

- Redis
- Ruby / Rails
- Node / NVM
- API Keys for: MapBox, Thunderforest, Tomorrow.IO

### Redis

#### Starting Redis

```sh
cd carpe_caelum_api
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
cd carpe_caelum_api
rails s
```

#### Running Tests

From the Rails root directory:

```sh
cd carpe_caelum_api
bundle exec rspec spec
bundle exec rspec spec --format documentation
```

#### Linting

```sh
steep check
```

```sh
bundle exec rubocop
bundle exec rails_best_practices .
bundle exec rubocop -A
```

### React Frontend

#### Starting the Development Server

```sh
cd carpe-caelum-frontend
npm run dev
```

#### Running Tests


#### Linting

Lint, Prettyfy, and fix what you can

```sh
npm run lint
```

## With More Time...

- **Test Coverage**: Increase the scope and depth of testing.
- **Error Handling**: Implement more detailed exception handling and HTTP status code responses.
- **Cache Indicator UI**: I chose not to implement a UI feature indicating whether data was retrieved from the cache. This decision was based on time constraints and feeling I've expressed enough in the code to show the flow of how it would be done.
- **Consider Testing FE**: As it's a small app, I wouldn't spend too much time on testing the frontend extensively. However, adding some basic unit tests for critical components and integration tests for key user flows would be beneficial.

# CI

- Issues are tracked.
- PRs come from Issues
- PRs require (my own) approval befor merging, plus passing the CI tests.
- main branch can only be altered via PRs.

