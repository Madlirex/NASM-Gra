cmake_minimum_required(VERSION 3.20)
project(Gra LANGUAGES ASM_NASM)

enable_language(ASM_NASM)

# Force 64-bit NASM
set(CMAKE_ASM_NASM_FLAGS "-f win64")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)


set(SRC ${CMAKE_SOURCE_DIR}/main.asm)
set(OUT ${CMAKE_SOURCE_DIR}/bin/gra.exe)

add_custom_target(gra_manual ALL
        COMMAND nasm -f win64 ${SRC} -o ${CMAKE_BINARY_DIR}/main.obj
        COMMAND gcc ${CMAKE_BINARY_DIR}/main.obj -o ${OUT}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Assembling and linking NASM manually"
)

