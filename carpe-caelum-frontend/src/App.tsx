import React from 'react';
import LocationForm from './LocationForm';
import styled from 'styled-components';

const AppContainer = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
`;

const App: React.FC = () => {
  return (
    <AppContainer>
      <LocationForm />
    </AppContainer>
  );
};

export default App;
