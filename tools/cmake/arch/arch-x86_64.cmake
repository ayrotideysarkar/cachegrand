include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)

EXEC_PROGRAM(cat ARGS "/proc/cpuinfo" OUTPUT_VARIABLE CPUINFO)

check_c_compiler_flag(-mavx2                              COMPILER_HAS_MAVX2_FLAG)
check_c_compiler_flag(-mavx                               COMPILER_HAS_MAVX_FLAG)
check_c_compiler_flag(-msse42                             COMPILER_HAS_MSSE42_FLAG)
check_c_compiler_flag(-mno-avx256-split-unaligned-load    COMPILER_HAS_MNO_AVX256_SPLIT_UNALIGNED_LOAD_FLAG)
check_c_compiler_flag(-mbmi                               COMPILER_HAS_MBMI_FLAG)
check_c_compiler_flag(-mlzcnt                             COMPILER_HAS_MLZCNT_FLAG)
check_c_compiler_flag(-mclflushopt                        COMPILER_HAS_CLFLUSHOPT_FLAG)

# Check if the host has AVX2
if (COMPILER_HAS_MAVX2_FLAG)
    set(OLD_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
    list(APPEND CMAKE_REQUIRED_FLAGS "-mavx2")
    check_c_source_runs("
#include <stdint.h>
#include <immintrin.h>
int main() {
    uint32_t hash1 = 1234;
    uint32_t hash2 = 4321;
    __m256i cmp_vector1 = _mm256_set1_epi32(hash1);
    __m256i cmp_vector2 = _mm256_set1_epi32(hash2);
    __m256i result_mask_vector = _mm256_cmpeq_epi32(cmp_vector1, cmp_vector2);
    return 0;
}"
            HOST_HAS_AVX2)
    set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS})
endif()

# Check if the host has AVX
if (COMPILER_HAS_MAVX_FLAG)
    set(OLD_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
    list(APPEND CMAKE_REQUIRED_FLAGS "-mavx -mno-avx2")
    check_c_source_runs("
#include <stdint.h>
#include <immintrin.h>
int main() {
    uint32_t hash1 = 1234;
    uint32_t hash2 = 4321;
    __m256 cmp_vector1 = _mm256_castsi256_ps(_mm256_set1_epi32(hash1));
    __m256 cmp_vector2 = _mm256_castsi256_ps(_mm256_set1_epi32(hash2));
    __m256 result_mask_vector = _mm256_cmp_ps(cmp_vector1, cmp_vector2, _CMP_EQ_OQ);
    return 0;
}"
            HOST_HAS_AVX)
    set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS})

    if (NOT HOST_HAS_AVX)
        set(HOST_HAS_AVX 0)
    endif()
endif()

# Check if the host has CLFLUSHOPT
if (COMPILER_HAS_CLFLUSHOPT_FLAG)
    set(OLD_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
    list(APPEND CMAKE_REQUIRED_FLAGS "-mclflushopt")
    check_c_source_runs("
#include <immintrin.h>
int main() {
    char temp[64] = {0};
    _mm_clflushopt(&temp);
    return 0;
}"
            HOST_HAS_CLFLUSHOPT)
    set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS})

    if (NOT HOST_HAS_CLFLUSHOPT)
        set(HOST_HAS_CLFLUSHOPT 0)
    endif()
endif()

# Check if the host has SSE4.2
message(STATUS "Performing Test HOST_HAS_SSE42")

string(REGEX REPLACE "^.*(sse4_2).*$" "\\1" SSE_THERE ${CPUINFO})
STRING(COMPARE EQUAL "sse4_2" "${SSE_THERE}" SSE42_TRUE)
IF (SSE42_TRUE)
    set(HOST_HAS_SSE42 1)
    message(STATUS "Performing Test HOST_HAS_SSE42 - Success")
ELSE (SSE42_TRUE)
    set(HOST_HAS_SSE42 0)
    message(STATUS "Performing Test HOST_HAS_SSE42 - Failure")
ENDIF (SSE42_TRUE)
