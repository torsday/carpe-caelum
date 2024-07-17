import { renderHook, act } from '@testing-library/react'
import useGeocodeLocation from '../../src/hooks/useGeocodeLocation'
import axios from 'axios'
import { vi, describe, it, expect, afterEach } from 'vitest'

vi.mock('axios')
vi.mock('lodash.debounce', () => ({
    default: vi.fn((fn) => fn),
}))

describe('useGeocodeLocation', () => {
    const setPosition = vi.fn()
    const setErrorMsg = vi.fn()
    const location = 'San Francisco'

    afterEach(() => {
        vi.clearAllMocks()
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
        await act(async () => {
            await result.current(location)
        })
        expect(setPosition).toHaveBeenCalledWith([37.7749, -122.4194])
        expect(setErrorMsg).toHaveBeenCalledWith('')
    })
})
