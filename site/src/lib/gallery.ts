export const gallery_batch_size = 24

export const gallery_count_for = (required_count: number, total_count: number) =>
  Math.min(
    total_count,
    Math.ceil(required_count / gallery_batch_size) * gallery_batch_size,
  )
