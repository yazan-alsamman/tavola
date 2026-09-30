/// Operational table status from `TableResponseDto.status`.
///
/// `unrecognized` is only for a non-empty value outside the API enum.
/// A payload that omits `status` is not this value.
enum TableStatus {
  available,
  occupied,
  cleaning,
  disabled,
  reserved,
  merged,
  unrecognized,
}
