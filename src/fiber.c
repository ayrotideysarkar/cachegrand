/**
 * Copyright (C) 2020-2021 Daniele Salvatore Albano
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the BSD license.  See the LICENSE file for details.
 **/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <errno.h>

#include "misc.h"
#include "exttypes.h"
#include "xalloc.h"
#include "log/log.h"
#include "fatal.h"

#include "fiber.h"

#define TAG "fiber"

void fiber_stack_protection(
        fiber_t* fiber,
        bool enable) {
    int stack_usage_flags = enable ? PROT_NONE : PROT_READ | PROT_WRITE;

    if (mprotect(fiber->stack_base, xalloc_get_page_size(), stack_usage_flags) != 0) {
        if (errno == ENOMEM) {
            fatal(TAG, "Unable to protect/unprotect fiber stack, review the value of /proc/sys/vm/max_map_count");
        }

        fatal(TAG, "Unable to protect/unprotect fiber stack");
    }
}

fiber_t* fiber_new(
        size_t stack_size,
        fiber_start_fp_t* fiber_start_fp,
        void* user_data) {
    fiber_t* fiber = xalloc_alloc_zero(sizeof(fiber_t));
    void* stack_base = xalloc_alloc_aligned_zero(xalloc_get_page_size(), stack_size);

    // Align the stack_pointer to 16 bytes and leave the 128 bytes red zone free as per ABI requirements
    void* stack_pointer = (void*)((uintptr_t)(stack_base + stack_size) & -16L) - 128;

    stack -= 128;

    fiber->start_fp = fiber_start_fp;
    fiber->start_fp_user_data = user_data;
    fiber->stack_size = stack_size;
    fiber->stack_base = stack_base;
    fiber->stack_pointer = stack_pointer;

    // Set the initial fp and rsp of the fiber
    fiber->context.rip = fiber->start_fp; // this or the stack_base? who knows :|
    fiber->context.rsp = fiber->stack_pointer;

    fiber_stack_protection(fiber, true);

    return fiber;
}

void fiber_free(
        fiber_t* fiber) {
    fiber_stack_protection(fiber, false);

    xalloc_free(fiber->stack_base);
    xalloc_free(fiber);
}

void fiber_context_get(
        fiber_t* fiber_context) {
    _fiber_context_get(fiber_context);
}

void fiber_context_set(
        fiber_t* fiber_context) {
    _fiber_context_set(fiber_context);
}
