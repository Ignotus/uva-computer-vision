cmake_minimum_required(VERSION 2.8.12)
project(final)

find_package(OpenCV REQUIRED)
find_package(PCL REQUIRED COMPONENTS common io visualization)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fexceptions")

include_directories(${PCL_INCLUDE_DIRS} ${OpenCV_INCLUDE_DIRS})
link_directories(${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})
add_executable(final main.cpp Frame3D/FileUtils.cpp  Frame3D/Frame3D.cpp)
message(STATUS "${OpenCV_INCLUDE_DIRS}")
message(STATUS "${OpenCV_LIBS}")
target_link_libraries(final ${PCL_COMMON_LIBRARIES} ${PCL_IO_LIBRARIES} ${PCL_VISUALIZATION_LIBRARIES} ${OpenCV_LIBS})
