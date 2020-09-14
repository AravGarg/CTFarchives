#include <map>
#include <memory>
#include <span>
#include <stdint.h>
#include <stdio.h>
#include <string>
#include <unistd.h>
#include <variant>
#include <vector>
#include <iostream>

using u8 = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;

//decoder function
std::vector<u8> base64_decode(const std::string &encoded) {
  std::vector<int> T(256, -1);
  for (int i = 0; i < 64; i++) {
    T["ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"[i]] =
        i;
  }

  std::vector<u8> out{};

  int val = 0, valb = -8;
  for (auto c : encoded) {
    if (T[c] == -1)
      break;
    val = (val << 6) + T[c];
    valb += 6;
    if (valb >= 0) {
      out.push_back(char((val >> valb) & 0xFF));
      valb -= 8;
    }
  }

  return out;
}
static std::string encoded{};
//read encoded data into encoded, return decoded data
std::vector<u8> read_base64_from_stdin() {
      char buffer[256] = {0};
      encoded = "";
      ssize_t read_amount = 0;
      while ((read_amount = read(STDIN_FILENO, buffer, sizeof(buffer))) > 0) {
        encoded += std::string(buffer, read_amount);
        if (encoded.size() > 2 && encoded[encoded.size() - 1] == '\n' &&
            encoded[encoded.size() - 2] == '\n') {
          break;
        }
      }
      return base64_decode(encoded);
}
/*
Feather load_feather_fs(const std::vector<u8> &blob){
  if (blob.size() < sizeof(layout::Header)) {
    printf("Filesystem blob too small!\n");
    abort();
  }

  const auto &header = *(const layout::Header *)(blob.data());

  if (header.magic != 0x52454854414546) {
    printf("Invalid magic: %llx\n", header.magic);
    abort();
  }
  if (header.num_segments > 100000) {
    printf("Too many segments: %zu (max: 100000)\n", header.num_segments);
    abort();
  }
  if (sizeof(layout::Header) + header.num_segments * sizeof(layout::Segment) >
      blob.size()) {
    printf("Segment table size is larger than size of blob\n");
    abort();
  }

  const auto *segment_region =
      (const layout::Segment *)(blob.data() + sizeof(layout::Header));
  std::span<const layout::Segment> segments(segment_region,
                                            header.num_segments);

  const auto *data_region = (const u8 *)&segment_region[header.num_segments];
  std::span<const u8> data(data_region, blob.data() + blob.size());

  u64 total_segments = std::count_if(
      segments.begin(), segments.end(), [](layout::Segment segment) {
        return segment.type != u32(Segment_Type::Label);
      });

  Feather feather{};
  while (feather.loaded_segments.size() != total_segments) {
    for (const auto &segment : segments) {
      if (feather.loaded_segments.contains(segment.id)) {
        continue;
      }

      auto contents = checked_subspan(data, segment.offset, segment.length);

      switch (segment.type) {
      case u32(Segment_Type::Directory): {
        if (segment.length < sizeof(layout::Directory)) {
          printf("Directory segment too small (%u vs %u)\n", segment.length,
                 sizeof(layout::Directory));
          abort();
        }

        const auto &directory_header =
            *(const layout::Directory *)(contents.data());
        std::span<const u8> name = checked_subspan(
            contents, sizeof(layout::Directory), directory_header.name_length);
        std::span<const u8> children_bytes = checked_subspan(
            contents, sizeof(layout::Directory) + directory_header.name_length,
            directory_header.num_entries * sizeof(u32));
        std::span<const u32> children((const u32 *)children_bytes.data(),
                                      children_bytes.size() / sizeof(u32));

        std::vector<Entry *> child_entries{};
        child_entries.reserve(children.size());
        bool missing_children = false;
        for (const auto child : children) {
          if (!feather.loaded_segments.contains(child)) {
            missing_children = true;
            break;
          }
          child_entries.push_back(feather.loaded_segments[child]);
        }
        if (missing_children) {
          continue;
        }

        feather.loaded_segments[segment.id] = Entry::make_directory(
            std::string_view((const char *)name.data(), name.size()),
            child_entries);
        if (name.empty()) {
          feather.root = feather.loaded_segments[segment.id];
        }
        break;
      }
      case u32(Segment_Type::File): {
        if (segment.length < sizeof(layout::File)) {
          printf("File segment too small (%u vs %u)\n", segment.length,
                 sizeof(layout::File));
          abort();
        }

        const auto &file_header = *(const layout::File *)(contents.data());
        std::span<const u8> name = checked_subspan(
            contents, sizeof(layout::File), file_header.name_length);
        std::span<const u8> file_contents = checked_subspan(
            contents, sizeof(layout::File) + file_header.name_length,
            file_header.contents_length);

        feather.loaded_segments[segment.id] = Entry::make_file(
            std::string_view((const char *)name.data(), name.size()),
            std::vector<u8>(file_contents.data(),
                            file_contents.data() + file_contents.size()));
        break;
      }
      case u32(Segment_Type::File_Clone): {
        if (segment.length < sizeof(layout::File_Clone)) {
          printf("File_Clone segment too small (%u vs %u)\n", segment.length,
                 sizeof(layout::File_Clone));
          abort();
        }

        const auto &file_clone_header =
            *(const layout::File_Clone *)(contents.data());
        std::span<const u8> name =
            checked_subspan(contents, sizeof(layout::File_Clone),
                            file_clone_header.name_length);
        auto target = file_clone_header.target_inode;

        if (!feather.loaded_segments.contains(target)) {
          continue;
        }

        feather.loaded_segments[segment.id] = Entry::make_file_clone(
            std::string_view((const char *)name.data(), name.size()), target);
        break;
      }
      case u32(Segment_Type::Symlink): {
        if (segment.length < sizeof(layout::Symlink)) {
          printf("Symlink segment too small (%u vs %u)\n", segment.length,
                 sizeof(layout::Symlink));
          abort();
        }

        const auto &symlink_header =
            *(const layout::Symlink *)(contents.data());
        std::span<const u8> name = checked_subspan(
            contents, sizeof(layout::Symlink), symlink_header.name_length);
        std::span<const u8> target = checked_subspan(
            contents, sizeof(layout::Symlink) + symlink_header.name_length,
            symlink_header.target_length);

        feather.loaded_segments[segment.id] = Entry::make_symlink(
            std::string_view((const char *)name.data(), name.size()),
            std::string_view((const char *)target.data(), target.size()));
        break;
      }
      case u32(Segment_Type::Hardlink): {
        if (segment.length < sizeof(layout::Hardlink)) {
          printf("Hardlink segment too small (%u vs %u)\n", segment.length,
                 sizeof(layout::Hardlink));
          abort();
        }

        const auto &hardlink_header =
            *(const layout::Hardlink *)(contents.data());
        std::span<const u8> name = checked_subspan(
            contents, sizeof(layout::Hardlink), hardlink_header.name_length);

        feather.loaded_segments[segment.id] = Entry::make_hardlink(
            std::string_view((const char *)name.data(), name.size()),
            hardlink_header.target);
        break;
      }
      case u32(Segment_Type::Label): {
        feather.label.assign(
            std::string_view((const char *)contents.data(), contents.size()));
        break;
      }
      default: {
        printf("Error: Invalid segment type: %u\n", segment.type);
        abort();
      }
      }
    }
  }

  for (const auto [id, entry] : feather.loaded_segments) {
    if (entry->name.empty()) {
      feather.root = entry;
      return feather;
    }
  }

  printf("Error: No filesystem root found\n");
  abort();
}*/
//main function
int main() {
  setvbuf(stdout, NULL, _IONBF, 0);

  puts("Please send a base64-encoded feather file, followed by two newlines:");
  auto file = read_base64_from_stdin();
  std::cout << file.size() << std::endl;
  puts("Loading Feather Filesystem...");
 // auto feather = load_feather_fs(file);
 // puts("Filesystem dump:");
  //feather.print_tree();
}
