# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.19

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /home/uia67865/devel/tools/cmake/3.19.2/bin/cmake

# The command to remove a file.
RM = /home/uia67865/devel/tools/cmake/3.19.2/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/uia67865/.emacs.d/elpa/vterm-20211226.817

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/uia67865/.emacs.d/elpa/vterm-20211226.817/build

# Utility rule file for run.

# Include the progress variables for this target.
include CMakeFiles/run.dir/progress.make

CMakeFiles/run: ../vterm-module.so
	emacs -Q -L /home/uia67865/.emacs.d/elpa/vterm-20211226.817 -L /home/uia67865/.emacs.d/elpa/vterm-20211226.817/build --eval \(require\ \'vterm\) --eval \(vterm\)

run: CMakeFiles/run
run: CMakeFiles/run.dir/build.make

.PHONY : run

# Rule to build all files generated by this target.
CMakeFiles/run.dir/build: run

.PHONY : CMakeFiles/run.dir/build

CMakeFiles/run.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/run.dir/cmake_clean.cmake
.PHONY : CMakeFiles/run.dir/clean

CMakeFiles/run.dir/depend:
	cd /home/uia67865/.emacs.d/elpa/vterm-20211226.817/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/uia67865/.emacs.d/elpa/vterm-20211226.817 /home/uia67865/.emacs.d/elpa/vterm-20211226.817 /home/uia67865/.emacs.d/elpa/vterm-20211226.817/build /home/uia67865/.emacs.d/elpa/vterm-20211226.817/build /home/uia67865/.emacs.d/elpa/vterm-20211226.817/build/CMakeFiles/run.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/run.dir/depend

