namespace layout {
struct Header {
  u64 magic;
  u32 num_segments;
} __attribute__((packed));

struct Segment {
  u32 type;
  u32 id;
  u32 offset;
  u32 length;
} __attribute__((packed));

struct Directory {
  u32 name_length;
  u32 num_entries;
  /* u8 name[] */
  /* u32 entries[] */
} __attribute__((packed));

struct File {
  u32 name_length;
  u32 contents_length;
  /* u8 name[] */
  /* u8 contents[] */
} __attribute__((packed));

struct File_Clone {
  u32 name_length;
  u32 target_inode;
  /* u8 name[] */
} __attribute__((packed));

struct Symlink {
  u32 name_length;
  u32 target_length;
  /* u8 name[] */
  /* u8 target[] */
} __attribute__((packed));

struct Hardlink {
  u32 name_length;
  u32 target;
  /* u8 name[] */
} __attribute__((packed));
} // namespace layout

enum class Segment_Type {
  Directory = 0,
  File = 1,
  File_Clone = 2,
  Symlink = 3,
  Hardlink = 4,
  Label = 5,
};

