struct Feather {
  std::map<u32, Entry *> loaded_segments{};
  std::string label{""};
  Entry *root{nullptr};

  void print_tree(Entry *entry, u64 depth);
  void print_tree() {
    printf("Tree with label %s:", label.c_str());
    print_tree(root, 0);
  }
};

enum class Segment_Type {
  Directory = 0,
  File = 1,
  File_Clone = 2,
  Symlink = 3,
  Hardlink = 4,
  Label = 5,
};

struct Entry {
  struct Directory {
    std::vector<Entry *> entries;
  };
  struct File {
    std::vector<u8> contents;
  };
  struct File_Clone {
    u32 source_inode;
    std::vector<u8> cached_file_contents;
  };
  struct Symlink {
    std::string target;
    Entry *target_inode_cache;
  };
  struct Hardlink {
    u32 target;
    Entry *target_inode_cache;
  };
  using Value = std::variant<Directory, File, File_Clone, Symlink, Hardlink>;

