import { useCallback } from 'react'
import axios from 'axios'
import debounce from 'lodash.debounce'
import { DEBOUNCE_DELAY } from '../constants'

/**
 * Custom hook for geocoding a location string and setting the position.
 *
 * @param setPosition - Function to set the position state with latitude and longitude.
 * @param setErrorMsg - Function to set the error message state.
 * @returns A debounced function to geocode a location string.
 */
const useGeocodeLocation = (
    setPosition: (position: [number, number] | null) => void,
    setErrorMsg: (msg: string) => void
) => {
    /**
     * Geocodes the given location string and updates the position state.
     *
     * @param location - The location string to geocode.
     * @returns A promise that resolves when the geocoding is complete.
     */
    const geocodeLocation = async (location: string) => {
        try {
            const response = await axios.get(
                `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(location)}.json`,
                {
                    params: {
                        access_token: import.meta.env.VITE_MAPBOX_API_TOKEN,
                    },
                }
            )

            const data = response.data
            console.log('Geocoding response data:', data)

            if (data.features && data.features.length > 0) {
                const { center } = data.features[0]
                const [lon, lat] = center
                setPosition([lat, lon])
                setErrorMsg('') // Clear any previous error message
            } else {
                console.warn('Location not found.')
                setErrorMsg('Location not found. Please try again.')
            }
        } catch (error) {
            console.error('Error geocoding location:', error)
            setErrorMsg('Error geocoding location. Please try again.')
        }
    }

    /**
     * Debounced version of the geocodeLocation function to prevent excessive API calls.
     *
     * @returns A debounced function that geocodes a location string.
     */
    const debouncedGeocodeLocation = useCallback(
        debounce(geocodeLocation, DEBOUNCE_DELAY),
        []
    )

    return debouncedGeocodeLocation
}

export default useGeocodeLocation
