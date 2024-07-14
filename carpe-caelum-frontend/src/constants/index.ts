/**
 * The number of decimal places to use for latitude and longitude precision.
 * This level of precision is more than sufficient for weather needs.
 */
export const LAT_LON_PRECISION = 6

/**
 * The delay in milliseconds to use for debouncing user input.
 * This helps to reduce the number of API calls by only making a request
 * after the user has stopped typing for the specified duration.
 */
export const DEBOUNCE_DELAY = 1000
