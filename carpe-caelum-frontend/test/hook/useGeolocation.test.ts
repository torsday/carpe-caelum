import { renderHook } from '@testing-library/react'
import useGeocodeLocation from '../../src/hooks/useGeocodeLocation'
import axios from 'axios'
import { vi, describe, it, expect, beforeEach } from 'vitest'

vi.mock('axios')
vi.mock('lodash.debounce', () => ({
    default: vi.fn((fn) => fn), // This makes debounce a pass-through function
}))

describe('useGeocodeLocation', () => {
    const setPosition = vi.fn()
    const setErrorMsg = vi.fn()
    const location = 'San Francisco'

    beforeEach(() => {
        vi.clearAllMocks()
        vi.stubEnv('VITE_MAPBOX_API_TOKEN', 'fake-token')
    })

    it('should set position on successful geocode', async () => {
        const mockData = {
            data: {
                features: [
                    {
                        center: [-122.4194, 37.7749],
                    },
                ],
            },
        }
        vi.mocked(axios.get).mockResolvedValue(mockData)

        const { result } = renderHook(() =>
            useGeocodeLocation(setPosition, setErrorMsg)
        )

        await result.current(location)

        expect(axios.get).toHaveBeenCalledWith(
            `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(location)}.json`,
            {
                params: {
                    access_token: 'fake-token',
                },
            }
        )
        expect(setPosition).toHaveBeenCalledWith([37.7749, -122.4194])
        expect(setErrorMsg).toHaveBeenCalledWith('')
    })

    it('should set error message when location is not found', async () => {
        const mockData = {
            data: {
                features: [],
            },
        }
        vi.mocked(axios.get).mockResolvedValue(mockData)

        const { result } = renderHook(() =>
            useGeocodeLocation(setPosition, setErrorMsg)
        )

        await result.current(location)

        expect(setPosition).not.toHaveBeenCalled()
        expect(setErrorMsg).toHaveBeenCalledWith(
            'Location not found. Please try again.'
        )
    })

    it('should set error message on geocode failure', async () => {
        vi.mocked(axios.get).mockRejectedValue(new Error('Network error'))

        const { result } = renderHook(() =>
            useGeocodeLocation(setPosition, setErrorMsg)
        )

        await result.current(location)

        expect(setPosition).not.toHaveBeenCalled()
        expect(setErrorMsg).toHaveBeenCalledWith(
            'Error geocoding location. Please try again.'
        )
    })
})
