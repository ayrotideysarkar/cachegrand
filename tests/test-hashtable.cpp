#include "catch.hpp"

#include "hashtable/hashtable.h"
#include "hashtable/hashtable_config.h"
#include "hashtable/hashtable_data.h"
#include "hashtable/hashtable_support.h"
#include "hashtable/hashtable_gc.h"
#include "hashtable/hashtable_op_get.h"
#include "hashtable/hashtable_op_set.h"

#include "test-hashtable.h"

TEST_CASE("hashtable.c", "[hashtable]") {
    SECTION("hashtable_init") {
        HASHTABLE_INIT(buckets_initial_count_5, false, {
            REQUIRE(hashtable != NULL);
        })
    }
}
