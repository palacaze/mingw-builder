# MinGW Builder

A set of scripts I wrote a few years ago to compile C++ software dependencies with MinGW on Windows.

MinGW Builder takes inspiration from Gentoo's Portage package manager, but can only build and install packages.

The scripts are not usable as-is and depend on a few other tools, namely:

- Git for Windows
- CMake
- Ninja build
- Qtbinpatcher if needed
- 7z
- UPX

I have no use for it anymore and now rely solely on CMake for software development and dependency building. See my other project [Gateau cmake modules](https://github.com/palacaze/gateau)) for more details.

