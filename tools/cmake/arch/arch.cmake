include(get-target-arch)

message(STATUS "Fetching architecture")
get_target_arch(CACHEGRAND_ARCH_TARGET)
message(STATUS "Fetching architecture -- ${CACHEGRAND_ARCH_TARGET}")

include("arch-${CACHEGRAND_ARCH_TARGET}")

if (NOT HOST_HAS_AVX2)
    set(HOST_HAS_AVX2 0)
endif()
if (NOT HOST_HAS_AVX)
    set(HOST_HAS_AVX 0)
endif()
if (NOT HOST_HAS_CLFLUSHOPT)
    set(HOST_HAS_CLFLUSHOPT 0)
endif()
if (NOT HOST_HAS_SSE42)
    set(HOST_HAS_SSE42 0)
endif()
