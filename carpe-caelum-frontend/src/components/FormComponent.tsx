import React from 'react'
import styled from 'styled-components'

// Styled component for the form
const Form = styled.form`
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: 16px;
`

// Styled component for the input container
const InputContainer = styled.div`
    display: flex;
    align-items: center;
    margin-top: 16px;
    width: 100%;
    max-width: 500px;
    justify-content: center;
`

// Styled component for the input field
const Input = styled.input`
    padding: 8px;
    font-size: 16px;
    text-align: center;
    width: 40ch;
    margin-right: 8px;
`

// Styled component for the button
const Button = styled.button`
    padding: 8px 16px;
    font-size: 16px;
    cursor: pointer;
    border: none;
    margin-top: ${(props) => (props.type === 'submit' ? '17px' : '0')};
    background-color: ${(props) =>
        props.type === 'submit' ? '#28A745' : '#007BFF'};
    color: white;

    &:hover {
        opacity: 0.8;
    }

    &:not(:last-child) {
        margin-left: 8px;
    }
`

// Define types for props
interface FormComponentProps {
    location: string
    setLocation: (location: string) => void
    handleGeolocation: () => void
    handleSubmit: (e: React.FormEvent) => void
}

// Functional component for the form
const FormComponent: React.FC<FormComponentProps> = ({
    location,
    setLocation,
    handleGeolocation,
    handleSubmit,
}) => (
    <Form onSubmit={handleSubmit}>
        <InputContainer>
            <Input
                type="text"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="Enter location"
            />
            <Button type="button" onClick={handleGeolocation}>
                Use My Location
            </Button>
        </InputContainer>
        <Button type="submit">Get Weather</Button>
    </Form>
)

export default FormComponent
