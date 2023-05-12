
// imported
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
#include "stb/stb_image.h"

// Is exported
// todo: rename name and folder
#include <lib_raster_image_loader/raster_image_loader.hpp>

#include <iostream>

void load_image(const std::string& fname) {
  std::cout << fname << std::endl;
}
