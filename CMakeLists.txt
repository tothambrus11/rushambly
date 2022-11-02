cmake_minimum_required(VERSION 3.22)

project(rushabmly C ASM)
set_property(SOURCE src/foo.s APPEND PROPERTY COMPILE_OPTIONS "-x" "assembler-with-cpp")

SET(GCC_COVERAGE_COMPILE_FLAGS "-no-pie")
SET(GCC_COVERAGE_LINK_FLAGS "-no-pie -lm")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${GCC_COVERAGE_COMPILE_FLAGS}")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${GCC_COVERAGE_LINK_FLAGS}")

find_package(SDL2 CONFIG REQUIRED)
find_package(sdl2-gfx CONFIG REQUIRED)
find_package(SDL2_mixer CONFIG REQUIRED)
find_package(SDL2_ttf CONFIG REQUIRED)

add_executable(rushabmly
        src/variables.s
        src/onTick.s
        src/main.s
        src/enemies.s
        src/intersection.s
        src/rackets.s
        src/outOfBounds.s
        src/isMiddle.s
        src/onInit.s
        src/onGameOver.s
        src/scoreText.s
        src/scoreManager.s
        )

target_include_directories(rushabmly
        PRIVATE
        ${SDL2_INCLUDE_DIRS}
        ${SDL2_GFX_INCLUDE_DIRS}
        ${SDL2_MIXER_INCLUDE_DIRS}
        ${SDL2_TTF_INCLUDE_DIRS}
        )
target_link_libraries(rushabmly
        m
        $<IF:$<TARGET_EXISTS:SDL2_mixer::SDL2_mixer>,SDL2_mixer::SDL2_mixer,SDL2_mixer::SDL2_mixer-static> SDL2::SDL2_gfx
        ${SDL2_LIBRARIES}
        SDL2::SDL2_gfx
        $<IF:$<TARGET_EXISTS:SDL2_ttf::SDL2_ttf>,SDL2_ttf::SDL2_ttf,SDL2_ttf::SDL2_ttf-static>
        )
