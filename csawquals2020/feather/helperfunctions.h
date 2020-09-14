std::span<T> checked_subspan(const std::span<T> span, u64 offset, u64 length) {
  if (offset <= span.size() && offset + length <= span.size() &&
      offset <= offset + length) {
    return span.subspan(offset, length);
  }
  printf("Invalid subspan for span of size %zu: offset: %zu, length: %zu\n",
         span.size(), offset, length);
  abort();
}
