import { expect, it } from 'vite-plus/test'
import { gallery_count_for } from '../src/lib/gallery'

it.each([
  [1, 160, 24],
  [24, 160, 24],
  [25, 160, 48],
  [145, 160, 160],
  [24, 1, 1],
  [24, 0, 0],
])(
  `shows enough cards for a request of %i out of %i`,
  (required_count, total_count, expected_count) =>
    expect(gallery_count_for(required_count, total_count)).toBe(expected_count),
)
