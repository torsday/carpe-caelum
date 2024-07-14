import React from 'react'
import styled from 'styled-components'

const Form = styled.form`
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: 16px;
`

const InputContainer = styled.div`
    display: flex;
    align-items: center;
    margin-top: 16px;
    width: 100%;
    max-width: 500px;
    justify-content: center;
`

const Input = styled.input`
    padding: 8px;
    font-size: 16px;
    text-align: center;
    width: 40ch;
    margin-right: 8px;
`

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

interface FormComponentProps {
    location: string
    setLocation: React.Dispatch<React.SetStateAction<string>>
    handleGeolocation: () => void
    handleSubmit: (e: React.FormEvent) => void
}

const FormComponent: React.FC<FormComponentProps> = ({
    location,
    setLocation,
    handleGeolocation,
    handleSubmit,
}) => {
    return (
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
}

export default FormComponent
