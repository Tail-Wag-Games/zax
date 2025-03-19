#include <stdint.h>

#include "c89atomic/c89atomic.h"

typedef c89atomic_uint32    zax_atomic_uint32;
typedef c89atomic_uint64    zax_atomic_uint64;

#define zax_atomic_order_c11_value(_o) = c89atomic_##_o


typedef enum zax_atomic_memory_order
{
    ZAX_ATOMIC_MEMORYORDER_RELAXED zax_atomic_order_c11_value(memory_order_relaxed),
    ZAX_ATOMIC_MEMORYORDER_CONSUME zax_atomic_order_c11_value(memory_order_consume),
    ZAX_ATOMIC_MEMORYORDER_ACQUIRE zax_atomic_order_c11_value(memory_order_acquire),
    ZAX_ATOMIC_MEMORYORDER_RELEASE zax_atomic_order_c11_value(memory_order_release),
    ZAX_ATOMIC_MEMORYORDER_ACQREL zax_atomic_order_c11_value(memory_order_acq_rel),
    ZAX_ATOMIC_MEMORYORDER_SEQCST zax_atomic_order_c11_value(memory_order_seq_cst)
} zax_atomic_memory_order;

uint32_t zax_atomic_exchange32_explicit(zax_atomic_uint32* a, uint32_t b, zax_atomic_memory_order order)
{
    return c89atomic_exchange_explicit_32(a, b, order);
}

void zax_atomic_store32_explicit(zax_atomic_uint32* a, uint32_t b, zax_atomic_memory_order order)
{
    c89atomic_store_explicit_32(a, b, order);
}

uint32_t zax_atomic_load32_explicit(zax_atomic_uint32* a, zax_atomic_memory_order order)
{
    return c89atomic_load_explicit_32(a, order);
}

uint32_t zax_atomic_fetch_add32(zax_atomic_uint32* a, uint32_t b)
{
    return c89atomic_fetch_add_32(a, b);
}

uint32_t zax_atomic_fetch_sub32(zax_atomic_uint32* a, uint32_t b)
{
    return c89atomic_fetch_sub_32(a, b);
}
