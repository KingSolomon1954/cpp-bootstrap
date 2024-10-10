import os
from conan import ConanFile
# from conan.tools.cmake import cmake_layout
from conan.tools.cmake import CMake

class AppRecipe(ConanFile):
    name = "RedFlame"  # Is the library name published to Conan Center
    license = "MIT Software License"
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeToolchain", "CMakeDeps"

    def layout(self):
        self.folders.root = "../.."
        if self.settings.build_type == "Debug":
            btype = "debug"
        if self.settings.build_type == "Release":
            btype = "prod"
        self.folders.build = os.path.join("_build", btype)
        self.folders.generators = os.path.join("_build", btype, "generators")

    def requirements(self):
        # self.requires("gtest/[~1.12]")
        # self.requires("zlib/[~1.2]")
        # self.requires("bzip2/[~1.0]")
        self.requires("doctest/[~2.4.11]")
        
    def build_requirements(self):
        pass

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
