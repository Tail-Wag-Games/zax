import std/[macros, strutils],
       ../src/zax/hoodoo

# type
#   ecs_world_t* = pointer
#   ecs_stage_t* = pointer
#   ecs_table_t* = pointer

#   ecs_time_t* {.bycopy.} = object
#     sec*: uint32
#     nanosec*: uint32

#   ecs_mixins_t* = object
#   ecs_size_t* = int32
#   ecs_flags8_t* = uint16
#   ecs_flags16_t* = uint16
#   ecs_flags32_t* = uint32
#   ecs_flags64_t* = uint32
#   ecs_os_thread_t* = uint
#   ecs_os_cond_t* = uint
#   ecs_os_mutex_t* = uint
#   ecs_os_dl_t* = uint
#   ecs_os_sock_t* = uint
#   ecs_os_thread_id_t* = uint64
#   ecs_os_proc_t* = proc () {.cdecl.}
#   ecs_os_api_init_t* = proc () {.cdecl.}
#   ecs_os_api_fini_t* = proc () {.cdecl.}
#   ecs_os_api_malloc_t* = proc (size: ecs_size_t): pointer {.cdecl.}
#   ecs_os_api_free_t* = proc (`ptr`: pointer) {.cdecl.}
#   ecs_os_api_realloc_t* = proc (`ptr`: pointer;
#       size: ecs_size_t): pointer {.cdecl.}
#   ecs_os_api_calloc_t* = proc (size: ecs_size_t): pointer {.cdecl.}
#   ecs_os_api_strdup_t* = proc (str: cstring): cstring {.cdecl.}
#   ecs_os_thread_callback_t* = proc (a1: pointer): pointer {.cdecl.}
#   ecs_os_api_thread_new_t* = proc (callback: ecs_os_thread_callback_t;
#       param: pointer): ecs_os_thread_t {.cdecl.}
#   ecs_os_api_thread_join_t* = proc (thread: ecs_os_thread_t): pointer {.cdecl.}
#   ecs_os_api_thread_self_t* = proc (): ecs_os_thread_id_t {.cdecl.}
#   ecs_os_api_task_new_t* = proc (callback: ecs_os_thread_callback_t;
#       param: pointer): ecs_os_thread_t {.cdecl.}
#   ecs_os_api_task_join_t* = proc (thread: ecs_os_thread_t): pointer {.cdecl.}
#   ecs_os_api_ainc_t* = proc (value: ptr int32): int32 {.cdecl.}
#   ecs_os_api_lainc_t* = proc (value: ptr int64): int64 {.cdecl.}
#   ecs_os_api_mutex_new_t* = proc (): ecs_os_mutex_t {.cdecl.}
#   ecs_os_api_mutex_lock_t* = proc (mutex: ecs_os_mutex_t) {.cdecl.}
#   ecs_os_api_mutex_unlock_t* = proc (mutex: ecs_os_mutex_t) {.cdecl.}
#   ecs_os_api_mutex_free_t* = proc (mutex: ecs_os_mutex_t) {.cdecl.}
#   ecs_os_api_cond_new_t* = proc (): ecs_os_cond_t {.cdecl.}
#   ecs_os_api_cond_free_t* = proc (cond: ecs_os_cond_t) {.cdecl.}
#   ecs_os_api_cond_signal_t* = proc (cond: ecs_os_cond_t) {.cdecl.}
#   ecs_os_api_cond_broadcast_t* = proc (cond: ecs_os_cond_t) {.cdecl.}
#   ecs_os_api_cond_wait_t* = proc (cond: ecs_os_cond_t;
#       mutex: ecs_os_mutex_t) {.cdecl.}
#   ecs_os_api_sleep_t* = proc (sec: int32; nanosec: int32) {.cdecl.}
#   ecs_os_api_enable_high_timer_resolution_t * = proc (enable: bool) {.cdecl.}
#   ecs_os_api_get_time_t* = proc (time_out: ptr ecs_time_t) {.cdecl.}
#   ecs_os_api_now_t* = proc (): uint64 {.cdecl.}
#   ecs_os_api_log_t* = proc (level: int32; file: cstring; line: int32;
#       msg: cstring) {.cdecl.}
#   ecs_os_api_abort_t* = proc () {.cdecl.}
#   ecs_os_api_dlopen_t* = proc (libname: cstring): ecs_os_dl_t {.cdecl.}
#   ecs_os_api_dlproc_t* = proc (lib: ecs_os_dl_t;
#       procname: cstring): ecs_os_proc_t {.cdecl.}
#   ecs_os_api_dlclose_t* = proc (lib: ecs_os_dl_t) {.cdecl.}
#   ecs_os_api_module_to_path_t* = proc (module_id: cstring): cstring {.cdecl.}
#   ecs_os_api_perf_trace_t* = proc (filename: cstring; line: csize_t;
#       name: cstring) {.cdecl.}
#   ecs_os_api_t* {.bycopy.} = object
#     init*: ecs_os_api_init_t
#     fini*: ecs_os_api_fini_t
#     malloc*: ecs_os_api_malloc_t
#     realloc*: ecs_os_api_realloc_t
#     calloc*: ecs_os_api_calloc_t
#     free*: ecs_os_api_free_t
#     strdup*: ecs_os_api_strdup_t
#     thread_new*: ecs_os_api_thread_new_t
#     thread_join*: ecs_os_api_thread_join_t
#     thread_self*: ecs_os_api_thread_self_t
#     task_new*: ecs_os_api_thread_new_t
#     task_join*: ecs_os_api_thread_join_t
#     ainc*: ecs_os_api_ainc_t
#     adec*: ecs_os_api_ainc_t
#     lainc*: ecs_os_api_lainc_t
#     ladec*: ecs_os_api_lainc_t
#     mutex_new*: ecs_os_api_mutex_new_t
#     mutex_free*: ecs_os_api_mutex_free_t
#     mutex_lock*: ecs_os_api_mutex_lock_t
#     mutex_unlock*: ecs_os_api_mutex_lock_t
#     cond_new*: ecs_os_api_cond_new_t
#     cond_free*: ecs_os_api_cond_free_t
#     cond_signal*: ecs_os_api_cond_signal_t
#     cond_broadcast*: ecs_os_api_cond_broadcast_t
#     cond_wait*: ecs_os_api_cond_wait_t
#     sleep*: ecs_os_api_sleep_t
#     now*: ecs_os_api_now_t
#     get_time*: ecs_os_api_get_time_t
#     log*: ecs_os_api_log_t
#     abort*: ecs_os_api_abort_t
#     dlopen*: ecs_os_api_dlopen_t
#     dlproc*: ecs_os_api_dlproc_t
#     dlclose*: ecs_os_api_dlclose_t
#     module_to_dl*: ecs_os_api_module_to_path_t
#     module_to_etc*: ecs_os_api_module_to_path_t
#     perf_trace_push*: ecs_os_api_perf_trace_t
#     perf_trace_pop*: ecs_os_api_perf_trace_t
#     log_level*: int32
#     log_indent*: int32
#     log_last_error*: int32
#     log_last_timestamp*: int64
#     flags*: ecs_flags32_t
#     log_out*: ptr FILE

#   ecs_id_t* {.bycopy.} = uint64
#   ecs_entity_t* {.bycopy.} = ecs_id_t
#   ecs_type_t* {.bycopy.} = object
#     array*: ptr ecs_id_t
#     count*: int32

#   ecs_poly_t* = object

#   ecs_header_t* {.bycopy.} = object
#     magic*: int32
#     `type`*: int32
#     refcount*: int32
#     mixins*: ptr ecs_mixins_t

#   ecs_run_action_t* = proc (it: ptr ecs_iter_t) {.cdecl.}
#   ecs_iter_action_t* = proc (it: ptr ecs_iter_t) {.cdecl.}
#   ecs_iter_next_action_t* = proc (it: ptr ecs_iter_t): bool {.cdecl.}
#   ecs_iter_fini_action_t* = proc (it: ptr ecs_iter_t) {.cdecl.}
#   ecs_order_by_action_t* = proc (e1: ecs_entity_t; ptr1: pointer; e2: ecs_entity_t;
#                               ptr2: pointer): cint {.cdecl.}
#   ecs_sort_table_action_t* = proc (world: ecs_world_t; table: ptr ecs_table_t;
#                                 entities: ptr ecs_entity_t; `ptr`: pointer;
#                                 size: int32; lo: int32; hi: int32;
#                                 order_by: ecs_order_by_action_t) {.cdecl.}
#   ecs_group_by_action_t* = proc (world: ecs_world_t; table: ptr ecs_table_t;
#                               group_id: ecs_id_t;
#                                   ctx: pointer): uint64 {.cdecl.}
#   ecs_group_create_action_t* = proc (world: ecs_world_t; group_id: uint64;
#                                   group_by_ctx: pointer): pointer {.cdecl.}
#   ecs_group_delete_action_t* = proc (world: ecs_world_t; group_id: uint64;
#                                   group_ctx: pointer;
#                                       group_by_ctx: pointer) {.cdecl.}
#   ecs_module_action_t* = proc (world: ecs_world_t) {.cdecl.}
#   ecs_fini_action_t* = proc (world: ecs_world_t; ctx: pointer) {.cdecl.}
#   ecs_ctx_free_t* = proc (ctx: pointer) {.cdecl.}
#   ecs_compare_action_t* = proc (ptr1: pointer; ptr2: pointer): cint {.cdecl.}
#   ecs_hash_value_action_t* = proc (`ptr`: pointer): uint64 {.cdecl.}
#   ecs_xtor_t* = proc (`ptr`: pointer; count: int32;
#       type_info: ptr ecs_type_info_t) {.cdecl.}
#   ecs_copy_t* = proc (dst_ptr: pointer; src_ptr: pointer; count: int32;
#                    type_info: ptr ecs_type_info_t) {.cdecl.}
#   ecs_move_t* = proc (dst_ptr: pointer; src_ptr: pointer; count: int32;
#                    type_info: ptr ecs_type_info_t) {.cdecl.}
#   ecs_cmp_t* = proc (a_ptr: pointer; b_ptr: pointer;
#       type_info: ptr ecs_type_info_t): cint {.cdecl.}
#   ecs_equals_t* = proc (a_ptr: pointer; b_ptr: pointer;
#       type_info: ptr ecs_type_info_t): bool {.cdecl.}
#   flecs_poly_dtor_t* = proc (poly: ptr ecs_poly_t) {.cdecl.}
#   ecs_inout_kind_t* = enum
#     EcsInOutDefault, EcsInOutNone, EcsInOutFilter, EcsInOut, EcsIn, EcsOut
#   ecs_oper_kind_t* = enum
#     EcsAnd, EcsOr, EcsNot, EcsOptional, EcsAndFrom, EcsOrFrom, EcsNotFrom
#   ecs_query_cache_kind_t* = enum
#     EcsQueryCacheDefault, EcsQueryCacheAuto, EcsQueryCacheAll, EcsQueryCacheNone
#   ecs_term_ref_t* {.bycopy.} = object
#     id*: ecs_entity_t
#     name*: cstring

#   ecs_term_t* {.bycopy.} = object
#     id*: ecs_id_t
#     src*: ecs_term_ref_t
#     first*: ecs_term_ref_t
#     second*: ecs_term_ref_t
#     trav*: ecs_entity_t
#     inout*: int16
#     oper*: int16
#     field_index*: int8
#     flags*: ecs_flags16_t

#   ecs_query_t* {.bycopy.} = object
#     hdr*: ecs_header_t
#     terms*: array[32, ecs_term_t]
#     sizes*: array[32, int32]
#     ids*: array[32, ecs_id_t]
#     flags*: ecs_flags32_t
#     var_count*: int8
#     term_count*: int8
#     field_count*: int8
#     fixed_fields*: ecs_flags32_t
#     var_fields*: ecs_flags32_t
#     static_id_fields*: ecs_flags32_t
#     data_fields*: ecs_flags32_t
#     write_fields*: ecs_flags32_t
#     read_fields*: ecs_flags32_t
#     row_fields*: ecs_flags32_t
#     shared_readonly_fields*: ecs_flags32_t
#     set_fields*: ecs_flags32_t
#     cache_kind*: ecs_query_cache_kind_t
#     vars*: cstringArray
#     ctx*: pointer
#     binding_ctx*: pointer
#     entity*: ecs_entity_t
#     real_world*: ecs_world_t
#     world*: ecs_world_t
#     eval_count*: int32

#   ecs_observer_t* {.bycopy.} = object
#     hdr*: ecs_header_t
#     query*: ptr ecs_query_t
#     events*: array[(8), ecs_entity_t]
#     event_count*: int32
#     callback*: ecs_iter_action_t
#     run*: ecs_run_action_t
#     ctx*: pointer
#     callback_ctx*: pointer
#     run_ctx*: pointer
#     ctx_free*: ecs_ctx_free_t
#     callback_ctx_free*: ecs_ctx_free_t
#     run_ctx_free*: ecs_ctx_free_t
#     observable*: ptr ecs_observable_t
#     world*: ecs_world_t
#     entity*: ecs_entity_t

#   ecs_type_hooks_t* {.bycopy.} = object
#     ctor*: ecs_xtor_t
#     dtor*: ecs_xtor_t
#     copy*: ecs_copy_t
#     move*: ecs_move_t
#     copy_ctor*: ecs_copy_t
#     move_ctor*: ecs_move_t
#     ctor_move_dtor*: ecs_move_t
#     move_dtor*: ecs_move_t
#     cmp*: ecs_cmp_t
#     equals*: ecs_equals_t
#     flags*: ecs_flags32_t
#     on_add*: ecs_iter_action_t
#     on_set*: ecs_iter_action_t
#     on_remove*: ecs_iter_action_t
#     ctx*: pointer
#     binding_ctx*: pointer
#     lifecycle_ctx*: pointer
#     ctx_free*: ecs_ctx_free_t
#     binding_ctx_free*: ecs_ctx_free_t
#     lifecycle_ctx_free*: ecs_ctx_free_t

#   ecs_type_info_t* {.bycopy.} = object
#     size*: ecs_size_t
#     alignment*: ecs_size_t
#     hooks*: ecs_type_hooks_t
#     component*: ecs_entity_t
#     name*: cstring

#   ecs_vec_t* = object
#     `array`: pointer
#     count: int32
#     size: int32

#   ecs_sparse_t* = object
#     dense: ecs_vec_t
#     pages: ecs_vec_t
#     size: ecs_size_t
#     count: int32
#     max_id: uint64
#     allocator: ptr ecs_allocator_t
#     page_allocator: ptr ecs_block_allocator_t

#   ecs_block_allocator_block_t* = object
#     memory: pointer
#     next: ptr ecs_block_allocator_block_t

#   ecs_block_allocator_chunk_header_t* = object
#     next: ptr ecs_block_allocator_chunk_header_t

#   ecs_block_allocator_t* = object
#     head: ptr ecs_block_allocator_chunk_header_t
#     block_head: ptr ecs_block_allocator_block_t
#     chunk_size: int32
#     data_size: int32
#     chunks_per_block: int32
#     block_size: int32

#   ecs_allocator_t* = object
#     chunks: ecs_block_allocator_t
#     sizes: ecs_sparse_t

#   ecs_map_data_t* = uint64
#   ecs_map_key_t* = ecs_map_data_t
#   ecs_map_val_t* = ecs_map_data_t

#   ecs_bucket_entry_t* {.bycopy.} = object
#     key: ecs_map_key_t
#     value: ecs_map_val_t
#     next: ptr ecs_bucket_entry_t

#   ecs_bucket_t* {.bycopy.} = object
#     first: ptr ecs_bucket_entry_t

#   ecs_map_t* {.bycopy.} = object
#     buckets: ptr ecs_bucket_t
#     bucket_count: int32
#     count {.bitsize: 26.}: uint32
#     bucket_shift {.bitsize: 6.}: uint32
#     allocator: ptr ecs_allocator_t

#   ecs_event_id_record_t* {.bycopy.} = object
#     self*: ecs_map_t
#     self_up*: ecs_map_t
#     up*: ecs_map_t

#     observers*: ecs_map_t
#     set_observers*: ecs_map_t
#     entity_observers*: ecs_map_t
#     observer_count*: int32

#   ecs_event_record_t* {.bycopy.} = object
#     `any`*: ecs_event_id_record_t
#     wildcard*: ecs_event_id_record_t
#     wildcard_pair*: ecs_event_id_record_t
#     event_ids*: ecs_map_t
#     event*: ecs_entity_t

#   ecs_observable_t* {.bycopy.} = object
#     on_add*: ecs_event_record_t
#     on_remove*: ecs_event_record_t
#     on_set*: ecs_event_record_t
#     on_wildcard*: ecs_event_record_t
#     events*: ecs_sparse_t
#     last_observer_id*: uint64

#   ecs_table_range_t* {.bycopy.} = object
#     table*: ptr ecs_table_t
#     offset*: int32
#     count*: int32

#   ecs_var_t* {.bycopy.} = object
#     range*: ecs_table_range_t
#     entity*: ecs_entity_t

#   ecs_ref_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     id*: ecs_entity_t
#     table_id*: uint64
#     table_version*: uint32
#     record*: ptr ecs_record_t
#     `ptr`*: pointer

#   ecs_page_iter_t* {.bycopy.} = object
#     offset*: int32
#     limit*: int32
#     remaining*: int32

#   ecs_worker_iter_t* {.bycopy.} = object
#     index*: int32
#     count*: int32

#   ecs_table_cache_iter_t* {.bycopy.} = object
#     cur*: ptr ecs_table_cache_hdr_t
#     next*: ptr ecs_table_cache_hdr_t
#     iter_fill*: bool
#     iter_empty*: bool

#   ecs_each_iter_t* {.bycopy.} = object
#     it*: ecs_table_cache_iter_t
#     ids*: ecs_id_t
#     sources*: ecs_entity_t
#     sizes*: ecs_size_t
#     columns*: int32
#     trs*: ptr ecs_table_record_t

#   ecs_query_op_profile_t* {.bycopy.} = object
#     count*: array[2, int32]

#   ecs_var_id_t* = uint8
#   ecs_query_lbl_t* = int16
#   ecs_write_flags_t* = ecs_flags64_t

#   ecs_query_var_t* = pointer
#   ecs_query_op_t* = pointer
#   ecs_query_cache_table_match_t* = pointer

#   ecs_query_op_ctx_t* {.bycopy.} = object

#   ecs_query_iter_t* {.bycopy.} = object
#     query*: ptr ecs_query_t
#     `vars`*: ptr ecs_var_t
#     query_vars*: ptr ecs_query_var_t
#     ops*: ptr ecs_query_op_t
#     op_ctx*: ptr ecs_query_op_ctx_t
#     node*: ptr ecs_query_cache_table_match_t
#     prev*: ptr ecs_query_cache_table_match_t
#     last*: ptr ecs_query_cache_table_match_t
#     written*: ptr uint64
#     skip_count*: int32
#     profile*: ptr ecs_query_op_profile_t
#     op*: int16
#     sp*: int16

#   ecs_stack_page_t* {.bycopy.} = object
#     data*: pointer
#     next*: ptr ecs_stack_page_t
#     sp*: int16
#     id*: uint32

#   ecs_stack_cursor_t* {.bycopy.} = object
#     prev*: ptr ecs_stack_cursor_t
#     page*: ptr ecs_stack_page_t
#     sp*: int16
#     is_free*: bool

#   ecs_stack_t* {.bycopy.} = object
#     first*: ptr ecs_stack_page_t
#     tail_page*: ptr ecs_stack_page_t
#     tail_cursor*: ptr ecs_stack_cursor_t

#   ecs_iter_cache_t* {.bycopy.} = object
#     stack_cursor*: ptr ecs_stack_cursor_t
#     used*: ecs_flags8_t
#     allocated*: ecs_flags8_t

#   ecs_iter_private_iter_t* {.bycopy, union.} = object
#     query*: ecs_query_iter_t
#     page*: ecs_page_iter_t
#     worker*: ecs_worker_iter_t
#     each*: ecs_each_iter_t

#   ecs_iter_private_t* {.bycopy.} = object
#     iter*: ecs_iter_private_iter_t
#     entity_iter*: pointer
#     cache*: ecs_iter_cache_t

#   ecs_commands_t* {.bycopy.} = object
#     queue*: ecs_vec_t
#     stack*: ecs_stack_t
#     entries*: ecs_sparse_t

#   ecs_suspend_readonly_state_t* {.bycopy.} = object
#     is_readonly*: bool
#     is_deferred*: bool
#     cmd_flushing*: bool
#     defer_count*: int32
#     scope*: ecs_entity_t
#     with*: ecs_entity_t
#     cmd_stack*: array[2, ecs_commands_t]
#     cmd*: ptr ecs_commands_t
#     stage*: ptr ecs_stage_t

#   ecs_hm_bucket_t* {.bycopy.} = object
#     keys*: ecs_vec_t
#     values*: ecs_vec_t

#   ecs_hashmap_t* {.bycopy.} = object
#     hash*: ecs_hash_value_action_t
#     compare*: ecs_compare_action_t
#     key_size*: ecs_size_t
#     value_size*: ecs_size_t
#     hashmap_allocator*: ptr ecs_block_allocator_t
#     bucket_allocator*: ecs_block_allocator_t
#     impl*: ecs_map_t

#   ecs_map_iter_t* {.bycopy.} = object
#     map*: ecs_map_t
#     bucket*: ptr ecs_bucket_t
#     entry*: ptr ecs_bucket_entry_t
#     res*: ptr ecs_map_data_t

#   flecs_hashmap_iter_t* {.bycopy.} = object
#     it*: ecs_map_iter_t
#     bucket*: ptr ecs_hm_bucket_t
#     index*: int32

#   flecs_hashmap_result_t* {.bycopy.} = object
#     key*: pointer
#     value*: pointer
#     hash*: uint64

#   ecs_component_record_t* = object

#   ecs_record_t* {.bycopy.} = object
#     cdr*: ptr ecs_component_record_t
#     table*: ptr ecs_table_t
#     row*: uint32
#     dense*: int32

#   ecs_table_cache_t* {.bycopy.} = object

#   ecs_table_cache_hdr_t* {.bycopy.} = object
#     cache*: ptr ecs_table_cache_t
#     table*: ptr ecs_table_t
#     prev*, next*: ptr ecs_table_cache_hdr_t

#   ecs_table_record_t* {.bycopy.} = object
#     hdr*: ecs_table_cache_hdr_t
#     index*: int16
#     count*: int16
#     column*: int16

#   ecs_table_records_t* {.bycopy.} = object
#     array*: ptr ecs_table_record_t
#     count*: int32

#   ecs_value_t* {.bycopy.} = object
#     `type`*: ecs_entity_t
#     `ptr`*: pointer

#   ecs_entity_desc_t* {.bycopy.} = object
#     canary*: int32
#     id*: ecs_entity_t
#     parent*: ecs_entity_t
#     name*: cstring
#     sep*: cstring
#     root_sep*: cstring
#     symbol*: cstring
#     use_low_id*: bool
#     add*: ptr ecs_id_t
#     set*: ptr ecs_value_t
#     add_expr*: cstring

#   ecs_bulk_desc_t* {.bycopy.} = object
#     canary*: int32
#     entities*: ptr ecs_entity_t
#     count*: int32
#     ids*: array[(32), ecs_id_t]
#     data*: ptr pointer
#     table*: ptr ecs_table_t

#   ecs_component_desc_t* {.bycopy.} = object
#     canary*: int32
#     entity*: ecs_entity_t
#     typeInfo*: ecs_type_info_t

#   ecs_iter_t* {.bycopy.} = object
#     world*: ecs_world_t
#     real_world*: ecs_world_t
#     entities*: ptr ecs_entity_t
#     sizes*: ptr ecs_size_t
#     table*: ptr ecs_table_t
#     other_table*: ptr ecs_table_t
#     ids*: ptr ecs_id_t
#     variables*: ptr ecs_var_t
#     trs*: ptr ptr ecs_table_record_t
#     sources*: ptr ecs_entity_t
#     constrained_vars*: ecs_flags64_t
#     group_id*: uint64
#     set_fields*: ecs_flags32_t
#     ref_fields*: ecs_flags32_t
#     row_fields*: ecs_flags32_t
#     up_fields*: ecs_flags32_t
#     system*: ecs_entity_t
#     event*: ecs_entity_t
#     event_id*: ecs_id_t
#     event_cur*: int32
#     field_count*: int8
#     term_index*: int8
#     variable_count*: int8
#     query*: ptr ecs_query_t
#     variable_names*: cstringArray
#     param*: pointer
#     ctx*: pointer
#     binding_ctx*: pointer
#     callback_ctx*: pointer
#     run_ctx*: pointer
#     delta_time*: cfloat
#     delta_system_time*: cfloat
#     frame_offset*: int32
#     offset*: int32
#     count*: int32
#     flags*: ecs_flags32_t
#     interrupted_by*: ecs_entity_t
#     priv*: ecs_iter_private_t
#     next*: ecs_iter_next_action_t
#     callback*: ecs_iter_action_t
#     fini*: ecs_iter_fini_action_t
#     chain_it*: ptr ecs_iter_t

#   ecs_query_desc_t* {.bycopy.} = object
#     canary*: int32
#     terms*: array[32, ecs_term_t]
#     expr*: cstring
#     cache_kind*: ecs_query_cache_kind_t
#     flags*: ecs_flags32_t
#     order_by_callback*: ecs_order_by_action_t
#     order_by_table_callback*: ecs_sort_table_action_t
#     order_by*: ecs_entity_t
#     group_by*: ecs_id_t
#     group_by_callback*: ecs_group_by_action_t
#     on_group_create*: ecs_group_create_action_t
#     on_group_delete*: ecs_group_delete_action_t
#     group_by_ctx*: pointer
#     group_by_ctx_free*: ecs_ctx_free_t
#     ctx*: pointer
#     binding_ctx*: pointer
#     ctx_free*: ecs_ctx_free_t
#     binding_ctx_free*: ecs_ctx_free_t
#     entity*: ecs_entity_t

#   ecs_observer_desc_t* {.bycopy.} = object
#     canary*: int32
#     entity*: ecs_entity_t
#     query*: ecs_query_desc_t
#     events*: array[(8), ecs_entity_t]
#     yield_existing*: bool
#     callback*: ecs_iter_action_t
#     run*: ecs_run_action_t
#     ctx*: pointer
#     ctx_free*: ecs_ctx_free_t
#     callback_ctx*: pointer
#     callback_ctx_free*: ecs_ctx_free_t
#     run_ctx*: pointer
#     run_ctx_free*: ecs_ctx_free_t
#     observable*: ptr ecs_poly_t
#     last_event_id*: ptr int32
#     term_index*: int8
#     flags*: ecs_flags32_t

#   ecs_event_desc_t* {.bycopy.} = object
#     event*: ecs_entity_t
#     ids*: ptr ecs_type_t
#     table*: ptr ecs_table_t
#     other_table*: ptr ecs_table_t
#     offset*: int32
#     count*: int32
#     entity*: ecs_entity_t
#     param*: pointer
#     const_param*: pointer
#     observable*: ptr ecs_poly_t
#     flags*: ecs_flags32_t

#   ecs_build_info_t* {.bycopy.} = object
#     compiler*: cstring
#     addons*: cstringArray
#     version*: cstring
#     version_major*: int16
#     version_minor*: int16
#     version_patch*: int16
#     debug*: bool
#     sanitize*: bool
#     perf_trace*: bool

#   ecs_world_info_cmd_t* {.bycopy.} = object
#     add_count*: int64
#     remove_count*: int64
#     delete_count*: int64
#     clear_count*: int64
#     set_count*: int64
#     ensure_count*: int64
#     modified_count*: int64
#     discard_count*: int64
#     event_count*: int64
#     other_count*: int64
#     batched_entity_count*: int64
#     batched_command_count*: int64

#   ecs_world_info_t* {.bycopy.} = object
#     last_component_id*: ecs_entity_t
#     min_id*: ecs_entity_t
#     max_id*: ecs_entity_t
#     delta_time_raw*: cfloat
#     delta_time*: cfloat
#     time_scale*: cfloat
#     target_fps*: cfloat
#     frame_time_total*: cfloat
#     system_time_total*: cfloat
#     emit_time_total*: cfloat
#     merge_time_total*: cfloat
#     rematch_time_total*: cfloat
#     world_time_total*: cdouble
#     world_time_total_raw*: cdouble
#     frame_count_total*: int64
#     merge_count_total*: int64
#     eval_comp_monitors_total*: int64
#     rematch_count_total*: int64
#     id_create_total*: int64
#     id_delete_total*: int64
#     table_create_total*: int64
#     table_delete_total*: int64
#     pipeline_build_count_total*: int64
#     systems_ran_frame*: int64
#     observers_ran_frame*: int64
#     tag_id_count*: int32
#     component_id_count*: int32
#     pair_id_count*: int32
#     table_count*: int32
#     cmd*: ecs_world_info_cmd_t
#     name_prefix*: cstring

#   ecs_query_group_info_t* {.bycopy.} = object
#     match_count*: int32
#     table_count*: int32
#     ctx*: pointer

#   EcsIdentifier* {.bycopy.} = object
#     value*: cstring
#     length*: ecs_size_t
#     hash*: uint64
#     index_hash*: uint64
#     index*: ptr ecs_hashmap_t

#   EcsComponent* {.bycopy.} = object
#     size*: ecs_size_t
#     alignment*: ecs_size_t

#   EcsPoly* {.bycopy.} = object
#     poly*: ptr ecs_poly_t

#   EcsDefaultChildComponent* {.bycopy.} = object
#     component*: ecs_id_t

#   ecs_entities_t* {.bycopy.} = object
#     ids*: ptr ecs_entity_t
#     count*: int32
#     alive_count*: int32

#   ecs_delete_empty_tables_desc_t* {.bycopy.} = object
#     clear_generation*: uint16
#     delete_generation*: uint16
#     time_budget_seconds*: cdouble

#   ecs_query_count_t* {.bycopy.} = object
#     results*: int32
#     entities*: int32
#     tables*: int32
#     empty_tables*: int32

#   ecs_app_init_action_t* = proc (world: ecs_world_t): cint {.cdecl.}
#   ecs_app_desc_t* {.bycopy.} = object
#     target_fps*: cfloat
#     delta_time*: cfloat
#     threads*: int32
#     frames*: int32
#     enable_rest*: bool
#     enable_stats*: bool
#     port*: uint16
#     init*: ecs_app_init_action_t
#     ctx*: pointer

#   ecs_app_run_action_t* = proc (world: ecs_world_t;
#       desc: ptr ecs_app_desc_t): cint {.cdecl.}
#   ecs_app_frame_action_t* = proc (world: ecs_world_t;
#       desc: ptr ecs_app_desc_t): cint {.cdecl.}

#   ecs_http_server_t* {.bycopy.} = object

#   ecs_http_connection_t* {.bycopy.} = object
#     id*: uint64
#     server*: ptr ecs_http_server_t
#     host*: array[128, char]
#     port*: array[16, char]

#   ecs_http_key_value_t* {.bycopy.} = object
#     key*: cstring
#     value*: cstring

#   ecs_http_method_t* = enum
#     EcsHttpGet, EcsHttpPost, EcsHttpPut, EcsHttpDelete, EcsHttpOptions,
#     EcsHttpMethodUnsupported
#   ecs_http_request_t* {.bycopy.} = object
#     id*: uint64
#     `method`*: ecs_http_method_t
#     path*: cstring
#     body*: cstring
#     headers*: array[(32), ecs_http_key_value_t]
#     params*: array[(32), ecs_http_key_value_t]
#     header_count*: int32
#     param_count*: int32
#     conn*: ptr ecs_http_connection_t

#   ecs_strbuf_list_elem* {.bycopy.} = object
#     count*: int32
#     separator*: cstring

#   ecs_strbuf_t* {.bycopy.} = object
#     content*: ptr char
#     length*: ecs_size_t
#     size*: ecs_size_t
#     list_stack*: array[32, ecs_strbuf_list_elem]
#     list_sp*: int32
#     small_string*: array[512, char]

#   ecs_http_reply_t* {.bycopy.} = object
#     code*: cint
#     body*: ecs_strbuf_t
#     status*: cstring
#     content_type*: cstring
#     headers*: ecs_strbuf_t

#   ecs_http_reply_action_t* = proc (request: ptr ecs_http_request_t;
#                                 reply: ptr ecs_http_reply_t;
#                                     ctx: pointer): bool {.cdecl.}
#   ecs_http_server_desc_t* {.bycopy.} = object
#     callback*: ecs_http_reply_action_t
#     ctx*: pointer
#     port*: uint16
#     ipaddr*: cstring
#     send_queue_wait_ms*: int32
#     cache_timeout*: cdouble
#     cache_purge_timeout*: cdouble

#   EcsRest* {.bycopy.} = object
#     port*: uint16
#     ipaddr*: cstring
#     impl*: pointer


#   EcsTimer* {.bycopy.} = object
#     timeout*: cfloat
#     time*: cfloat
#     overshoot*: cfloat
#     fired_count*: int32
#     active*: bool
#     single_shot*: bool

#   EcsRateFilter* {.bycopy.} = object
#     src*: ecs_entity_t
#     rate*: int32
#     tick_count*: int32
#     time_elapsed*: cfloat


#   ecs_pipeline_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     query*: ecs_query_desc_t

#   EcsTickSource* {.bycopy.} = object
#     tick*: bool
#     time_elapsed*: cfloat

#   ecs_system_desc_t* {.bycopy.} = object
#     canary*: int32
#     entity*: ecs_entity_t
#     query*: ecs_query_desc_t
#     callback*: ecs_iter_action_t
#     run*: ecs_run_action_t
#     ctx*: pointer
#     ctx_free*: ecs_ctx_free_t
#     callback_ctx*: pointer
#     callback_ctx_free*: ecs_ctx_free_t
#     run_ctx*: pointer
#     run_ctx_free*: ecs_ctx_free_t
#     interval*: cfloat
#     rate*: int32
#     tick_source*: ecs_entity_t
#     multi_threaded*: bool
#     immediate*: bool

#   ecs_system_t* {.bycopy.} = object
#     hdr*: ecs_header_t
#     run*: ecs_run_action_t
#     action*: ecs_iter_action_t
#     query*: ptr ecs_query_t
#     query_entity*: ecs_entity_t
#     tick_source*: ecs_entity_t
#     multi_threaded*: bool
#     immediate*: bool
#     name*: cstring
#     ctx*: pointer
#     callback_ctx*: pointer
#     run_ctx*: pointer
#     ctx_free*: ecs_ctx_free_t
#     callback_ctx_free*: ecs_ctx_free_t
#     run_ctx_free*: ecs_ctx_free_t
#     time_spent*: cfloat
#     time_passed*: cfloat
#     last_frame*: int64
#     world*: ecs_world_t
#     entity*: ecs_entity_t
#     dtor*: flecs_poly_dtor_t

#   ecs_gauge_t* {.bycopy.} = object
#     avg*: array[(60), cfloat]
#     min*: array[(60), cfloat]
#     max*: array[(60), cfloat]

#   ecs_counter_t* {.bycopy.} = object
#     rate*: ecs_gauge_t
#     value*: array[(60), cdouble]

#   ecs_metric_t* {.bycopy, union.} = object
#     gauge*: ecs_gauge_t
#     counter*: ecs_counter_t

#   ecs_world_entities_stats_t* {.bycopy.} = object
#     count*: ecs_metric_t
#     not_alive_count*: ecs_metric_t

#   ecs_world_components_stats_t* {.bycopy.} = object
#     tag_count*: ecs_metric_t
#     component_count*: ecs_metric_t
#     pair_count*: ecs_metric_t
#     type_count*: ecs_metric_t
#     create_count*: ecs_metric_t
#     delete_count*: ecs_metric_t

#   ecs_world_tables_stats_t* {.bycopy.} = object
#     count*: ecs_metric_t
#     empty_count*: ecs_metric_t
#     create_count*: ecs_metric_t
#     delete_count*: ecs_metric_t

#   ecs_world_queries_stats_t* {.bycopy.} = object
#     query_count*: ecs_metric_t
#     observer_count*: ecs_metric_t
#     system_count*: ecs_metric_t

#   ecs_world_commands_stats_t* {.bycopy.} = object
#     add_count*: ecs_metric_t
#     remove_count*: ecs_metric_t
#     delete_count*: ecs_metric_t
#     clear_count*: ecs_metric_t
#     set_count*: ecs_metric_t
#     ensure_count*: ecs_metric_t
#     modified_count*: ecs_metric_t
#     other_count*: ecs_metric_t
#     discard_count*: ecs_metric_t
#     batched_entity_count*: ecs_metric_t
#     batched_count*: ecs_metric_t

#   ecs_world_frame_stats_t* {.bycopy.} = object
#     frame_count*: ecs_metric_t
#     merge_count*: ecs_metric_t
#     rematch_count*: ecs_metric_t
#     pipeline_build_count*: ecs_metric_t
#     systems_ran*: ecs_metric_t
#     observers_ran*: ecs_metric_t
#     event_emit_count*: ecs_metric_t

#   ecs_world_performance_stats_t* {.bycopy.} = object
#     world_time_raw*: ecs_metric_t
#     world_time*: ecs_metric_t
#     frame_time*: ecs_metric_t
#     system_time*: ecs_metric_t
#     emit_time*: ecs_metric_t
#     merge_time*: ecs_metric_t
#     rematch_time*: ecs_metric_t
#     fps*: ecs_metric_t
#     delta_time*: ecs_metric_t

#   ecs_world_memory_stats_t* {.bycopy.} = object
#     alloc_count*: ecs_metric_t
#     realloc_count*: ecs_metric_t
#     free_count*: ecs_metric_t
#     outstanding_alloc_count*: ecs_metric_t
#     block_alloc_count*: ecs_metric_t
#     block_free_count*: ecs_metric_t
#     block_outstanding_alloc_count*: ecs_metric_t
#     stack_alloc_count*: ecs_metric_t
#     stack_free_count*: ecs_metric_t
#     stack_outstanding_alloc_count*: ecs_metric_t

#   ecs_world_http_stats_t* {.bycopy.} = object
#     request_received_count*: ecs_metric_t
#     request_invalid_count*: ecs_metric_t
#     request_handled_ok_count*: ecs_metric_t
#     request_handled_error_count*: ecs_metric_t
#     request_not_handled_count*: ecs_metric_t
#     request_preflight_count*: ecs_metric_t
#     send_ok_count*: ecs_metric_t
#     send_error_count*: ecs_metric_t
#     busy_count*: ecs_metric_t

#   ecs_world_stats_t* {.bycopy.} = object
#     first*: int64
#     entities*: ecs_world_entities_stats_t
#     components*: ecs_world_components_stats_t
#     tables*: ecs_world_tables_stats_t
#     queries*: ecs_world_queries_stats_t
#     commands*: ecs_world_commands_stats_t
#     frame*: ecs_world_frame_stats_t
#     performance*: ecs_world_performance_stats_t
#     memory*: ecs_world_memory_stats_t
#     http*: ecs_world_http_stats_t
#     last*: int64
#     t*: int32

#   ecs_query_stats_t* {.bycopy.} = object
#     first*: int64
#     result_count*: ecs_metric_t
#     matched_table_count*: ecs_metric_t
#     matched_entity_count*: ecs_metric_t
#     last*: int64
#     t*: int32

#   ecs_system_stats_t* {.bycopy.} = object
#     first*: int64
#     time_spent*: ecs_metric_t
#     last*: int64
#     task*: bool
#     query*: ecs_query_stats_t

#   ecs_sync_stats_t* {.bycopy.} = object
#     first*: int64
#     time_spent*: ecs_metric_t
#     commands_enqueued*: ecs_metric_t
#     last*: int64
#     system_count*: int32
#     multi_threaded*: bool
#     immediate*: bool

#   ecs_pipeline_stats_t* {.bycopy.} = object
#     canary*: int8
#     systems*: ecs_vec_t
#     sync_points*: ecs_vec_t
#     t*: int32
#     system_count*: int32
#     active_system_count*: int32
#     rebuild_count*: int32

#   EcsStatsHeader* {.bycopy.} = object
#     elapsed*: cfloat
#     reduce_count*: int32

#   EcsWorldStats* {.bycopy.} = object
#     hdr*: EcsStatsHeader
#     stats*: ecs_world_stats_t

#   EcsSystemStats* {.bycopy.} = object
#     hdr*: EcsStatsHeader
#     stats*: ecs_map_t

#   EcsPipelineStats* {.bycopy.} = object
#     hdr*: EcsStatsHeader
#     stats*: ecs_map_t

#   EcsWorldSummary* {.bycopy.} = object
#     target_fps*: cdouble
#     time_scale*: cdouble
#     frame_time_total*: cdouble
#     system_time_total*: cdouble
#     merge_time_total*: cdouble
#     frame_time_last*: cdouble
#     system_time_last*: cdouble
#     merge_time_last*: cdouble
#     frame_count*: int64
#     command_count*: int64
#     build_info*: ecs_build_info_t

#   EcsMetricValue* {.bycopy.} = object
#     value*: cdouble

#   EcsMetricSource* {.bycopy.} = object
#     entity*: ecs_entity_t

#   ecs_metric_desc_t* {.bycopy.} = object
#     canary*: int32
#     entity*: ecs_entity_t
#     member*: ecs_entity_t
#     dotmember*: cstring
#     id*: ecs_id_t
#     targets*: bool
#     kind*: ecs_entity_t
#     brief*: cstring

#   EcsAlertInstance* {.bycopy.} = object
#     message*: cstring

#   EcsAlertsActive* {.bycopy.} = object
#     info_count*: int32
#     warning_count*: int32
#     error_count*: int32
#     alerts*: ecs_map_t

#   ecs_alert_severity_filter_t* {.bycopy.} = object
#     severity*: ecs_entity_t
#     with*: ecs_id_t
#     `var`*: cstring
#     var_index*: int32

#   ecs_alert_desc_t* {.bycopy.} = object
#     canary*: int32
#     entity*: ecs_entity_t
#     query*: ecs_query_desc_t
#     message*: cstring
#     doc_name*: cstring
#     brief*: cstring
#     severity*: ecs_entity_t
#     severity_filters*: array[(4), ecs_alert_severity_filter_t]
#     retain_period*: cfloat
#     member*: ecs_entity_t
#     id*: ecs_id_t
#     `var`*: cstring

#   ecs_from_json_desc_t* {.bycopy.} = object
#     name*: cstring
#     expr*: cstring
#     lookup_action*: proc (a1: ecs_world_t; value: cstring;
#         ctx: pointer): ecs_entity_t {.cdecl.}
#     lookup_ctx*: pointer
#     strict*: bool

#   ecs_entity_to_json_desc_t* {.bycopy.} = object
#     serialize_entity_id*: bool
#     serialize_doc*: bool
#     serialize_full_paths*: bool
#     serialize_inherited*: bool
#     serialize_values*: bool
#     serialize_builtin*: bool
#     serialize_type_info*: bool
#     serialize_alerts*: bool
#     serialize_refs*: ecs_entity_t
#     serialize_matches*: bool


#   ecs_iter_to_json_desc_t* {.bycopy.} = object
#     serialize_entity_ids*: bool
#     serialize_values*: bool
#     serialize_builtin*: bool
#     serialize_doc*: bool
#     serialize_full_paths*: bool
#     serialize_fields*: bool
#     serialize_inherited*: bool
#     serialize_table*: bool
#     serialize_type_info*: bool
#     serialize_field_info*: bool
#     serialize_query_info*: bool
#     serialize_query_plan*: bool
#     serialize_query_profile*: bool
#     dont_serialize_results*: bool
#     serialize_alerts*: bool
#     serialize_refs*: ecs_entity_t
#     serialize_matches*: bool
#     query*: ptr ecs_poly_t

#   ecs_world_to_json_desc_t* {.bycopy.} = object
#     serialize_builtin*: bool
#     serialize_modules*: bool

#   ecs_script_var_t* {.bycopy.} = object
#     name*: cstring
#     value*: ecs_value_t
#     type_info*: ptr ecs_type_info_t
#     sp*: int32
#     is_const*: bool

#   ecs_script_vars_t* {.bycopy.} = object
#     parent*: ptr ecs_script_vars_t
#     sp*: int32
#     var_index*: ecs_hashmap_t
#     vars*: ecs_vec_t
#     world*: ecs_world_t
#     stack*: ptr ecs_stack_t
#     cursor*: ptr ecs_stack_cursor_t
#     allocator*: ptr ecs_allocator_t

#   ecs_script_t* {.bycopy.} = object
#     world*: ecs_world_t
#     name*: cstring
#     code*: cstring

#   ecs_script_template_t* {.bycopy.} = object
#   ecs_script_runtime_t* {.bycopy.} = object

#   EcsScript* {.bycopy.} = object
#     script*: ptr ecs_script_t
#     `template`*: ptr ecs_script_template_t

#   ecs_function_ctx_t* {.bycopy.} = object
#     world*: ecs_world_t
#     function*: ecs_entity_t
#     ctx*: pointer

#   ecs_function_callback_t* = proc (ctx: ptr ecs_function_ctx_t; argc: int32;
#                                 argv: ptr ecs_value_t;
#                                     result: ptr ecs_value_t) {.cdecl.}
#   ecs_script_parameter_t* {.bycopy.} = object
#     name*: cstring
#     `type`*: ecs_entity_t

#   EcsScriptConstVar* {.bycopy.} = object
#     value*: ecs_value_t
#     type_info*: ptr ecs_type_info_t

#   EcsScriptFunction* {.bycopy.} = object
#     return_type*: ecs_entity_t
#     params*: ecs_vec_t
#     callback*: ecs_function_callback_t
#     ctx*: pointer

#   EcsScriptMethod* {.bycopy.} = object
#     return_type*: ecs_entity_t
#     params*: ecs_vec_t
#     callback*: ecs_function_callback_t
#     ctx*: pointer

#   ecs_script_eval_desc_t* {.bycopy.} = object
#     vars*: ptr ecs_script_vars_t
#     runtime*: ptr ecs_script_runtime_t

#   ecs_script_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     filename*: cstring
#     code*: cstring

#   ecs_expr_eval_desc_t* {.bycopy.} = object
#     name*: cstring
#     expr*: cstring
#     vars*: ptr ecs_script_vars_t
#     `type`*: ecs_entity_t
#     lookup_action*: proc (a1: ecs_world_t; value: cstring;
#         ctx: pointer): ecs_entity_t {.cdecl.}
#     lookup_ctx*: pointer
#     disable_folding*: bool
#     disable_dynamic_variable_binding*: bool
#     allow_unresolved_identifiers*: bool
#     runtime*: ptr ecs_script_runtime_t

#   ecs_const_var_desc_t* {.bycopy.} = object
#     name*: cstring
#     parent*: ecs_entity_t
#     `type`*: ecs_entity_t
#     value*: pointer

#   ecs_function_desc_t* {.bycopy.} = object
#     name*: cstring
#     parent*: ecs_entity_t
#     params*: array[(16), ecs_script_parameter_t]
#     return_type*: ecs_entity_t
#     callback*: ecs_function_callback_t
#     ctx*: pointer

#   EcsDocDescription* {.bycopy.} = object
#     value*: cstring

#   ptrdiff_t* = clong
#   wchar_t* = cint
#   max_align_t* = clongdouble
#   ecs_bool_t* = bool
#   ecs_char_t* = char
#   ecs_byte_t* = cuchar
#   ecs_u8_t* = uint8
#   ecs_u16_t* = uint16
#   ecs_u32_t* = uint32
#   ecs_u64_t* = uint64
#   ecs_uptr_t* = uint
#   ecs_i8_t* = int8
#   ecs_i16_t* = int16
#   ecs_i32_t* = int32
#   ecs_i64_t* = int64
#   ecs_iptr_t* = int
#   ecs_f32_t* = cfloat
#   ecs_f64_t* = cdouble
#   ecs_string_t* = cstring

#   ecs_type_kind_t* = enum
#     EcsPrimitiveType, EcsBitmaskType, EcsEnumType, EcsStructType, EcsArrayType,
#     EcsVectorType, EcsOpaqueType
#   EcsType* {.bycopy.} = object
#     kind*: ecs_type_kind_t
#     existing*: bool
#     partial*: bool

#   ecs_primitive_kind_t* = enum
#     EcsBool = 1, EcsChar, EcsByte, EcsU8, EcsU16, EcsU32, EcsU64, EcsI8, EcsI16, EcsI32,
#     EcsI64, EcsF32, EcsF64, EcsUPtr, EcsIPtr, EcsString, EcsEntity, EcsId
#   EcsPrimitive* {.bycopy.} = object
#     kind*: ecs_primitive_kind_t

#   EcsMember* {.bycopy.} = object
#     `type`*: ecs_entity_t
#     count*: int32
#     unit*: ecs_entity_t
#     offset*: int32
#     use_offset*: bool

#   ecs_member_value_range_t* {.bycopy.} = object
#     min*: cdouble
#     max*: cdouble

#   EcsMemberRanges* {.bycopy.} = object
#     value*: ecs_member_value_range_t
#     warning*: ecs_member_value_range_t
#     error*: ecs_member_value_range_t

#   ecs_member_t* {.bycopy.} = object
#     name*: cstring
#     `type`*: ecs_entity_t
#     count*: int32
#     offset*: int32
#     unit*: ecs_entity_t
#     use_offset*: bool
#     range*: ecs_member_value_range_t
#     error_range*: ecs_member_value_range_t
#     warning_range*: ecs_member_value_range_t
#     size*: ecs_size_t
#     member*: ecs_entity_t

#   EcsStruct* {.bycopy.} = object
#     members*: ecs_vec_t

#   ecs_enum_constant_t* {.bycopy.} = object
#     name*: cstring
#     value*: int64
#     value_unsigned*: uint64
#     constant*: ecs_entity_t

#   EcsEnum* {.bycopy.} = object
#     underlying_type*: ecs_entity_t
#     constants*: ecs_map_t

#   ecs_bitmask_constant_t* {.bycopy.} = object
#     name*: cstring
#     value*: ecs_flags64_t
#     unused*: int64
#     constant*: ecs_entity_t

#   EcsBitmask* {.bycopy.} = object
#     constants*: ecs_map_t

#   EcsArray* {.bycopy.} = object
#     `type`*: ecs_entity_t
#     count*: int32

#   EcsVector* {.bycopy.} = object
#     `type`*: ecs_entity_t

#   ecs_serializer_t* {.bycopy.} = object
#     value*: proc (ser: ptr ecs_serializer_t; `type`: ecs_entity_t;
#         value: pointer): cint {.cdecl.}
#     member*: proc (ser: ptr ecs_serializer_t; member: cstring): cint {.cdecl.}
#     world*: ecs_world_t
#     ctx*: pointer

#   ecs_meta_serialize_t* = proc (ser: ptr ecs_serializer_t;
#       src: pointer): cint {.cdecl.}
#   ecs_meta_serialize_member_t* = proc (ser: ptr ecs_serializer_t; src: pointer;
#                                     name: cstring): cint {.cdecl.}
#   ecs_meta_serialize_element_t* = proc (ser: ptr ecs_serializer_t; src: pointer;
#                                      elem: csize_t): cint {.cdecl.}
#   EcsOpaque* {.bycopy.} = object
#     as_type*: ecs_entity_t
#     serialize*: ecs_meta_serialize_t
#     serialize_member*: ecs_meta_serialize_member_t
#     serialize_element*: ecs_meta_serialize_element_t
#     assign_bool*: proc (dst: pointer; value: bool) {.cdecl.}
#     assign_char*: proc (dst: pointer; value: char) {.cdecl.}
#     assign_int*: proc (dst: pointer; value: int64) {.cdecl.}
#     assign_uint*: proc (dst: pointer; value: uint64) {.cdecl.}
#     assign_float*: proc (dst: pointer; value: cdouble) {.cdecl.}
#     assign_string*: proc (dst: pointer; value: cstring) {.cdecl.}
#     assign_entity*: proc (dst: pointer; world: ecs_world_t;
#         entity: ecs_entity_t) {.cdecl.}
#     assign_id*: proc (dst: pointer; world: ecs_world_t; id: ecs_id_t) {.cdecl.}
#     assign_null*: proc (dst: pointer) {.cdecl.}
#     clear*: proc (dst: pointer) {.cdecl.}
#     ensure_element*: proc (dst: pointer; elem: csize_t): pointer {.cdecl.}
#     ensure_member*: proc (dst: pointer; member: cstring): pointer {.cdecl.}
#     count*: proc (dst: pointer): csize_t {.cdecl.}
#     resize*: proc (dst: pointer; count: csize_t) {.cdecl.}

#   ecs_unit_translation_t* {.bycopy.} = object
#     factor*: int32
#     power*: int32

#   EcsUnit* {.bycopy.} = object
#     symbol*: cstring
#     prefix*: ecs_entity_t
#     base*: ecs_entity_t
#     over*: ecs_entity_t
#     translation*: ecs_unit_translation_t

#   EcsUnitPrefix* {.bycopy.} = object
#     symbol*: cstring
#     translation*: ecs_unit_translation_t

#   ecs_meta_type_op_kind_t* = enum
#     EcsOpArray, EcsOpVector, EcsOpOpaque, EcsOpPush, EcsOpPop, EcsOpScope,
#       EcsOpEnum,
#     EcsOpBitmask, EcsOpPrimitive, EcsOpBool, EcsOpChar, EcsOpByte, EcsOpU8,
#       EcsOpU16,
#     EcsOpU32, EcsOpU64, EcsOpI8, EcsOpI16, EcsOpI32, EcsOpI64, EcsOpF32,
#       EcsOpF64,
#     EcsOpUPtr, EcsOpIPtr, EcsOpString, EcsOpEntity, EcsOpId
#   ecs_meta_type_op_t* {.bycopy.} = object
#     kind*: ecs_meta_type_op_kind_t
#     offset*: ecs_size_t
#     count*: int32
#     name*: cstring
#     op_count*: int32
#     size*: ecs_size_t
#     `type`*: ecs_entity_t
#     member_index*: int32
#     members*: ptr ecs_hashmap_t

#   EcsTypeSerializer* {.bycopy.} = object
#     ops*: ecs_vec_t

#   ecs_meta_scope_t* {.bycopy.} = object
#     `type`*: ecs_entity_t
#     ops*: ptr ecs_meta_type_op_t
#     op_count*: int32
#     op_cur*: int32
#     elem_cur*: int32
#     prev_depth*: int32
#     `ptr`*: pointer
#     comp*: ptr EcsComponent
#     opaque*: ptr EcsOpaque
#     vector*: ptr ecs_vec_t
#     members*: ptr ecs_hashmap_t
#     is_collection*: bool
#     is_inline_array*: bool
#     is_empty_scope*: bool

#   ecs_meta_cursor_t* {.bycopy.} = object
#     world*: ecs_world_t
#     scope*: array[(32), ecs_meta_scope_t]
#     depth*: int32
#     valid*: bool
#     is_primitive_scope*: bool
#     lookup_action*: proc (a1: ecs_world_t; a2: cstring;
#         a3: pointer): ecs_entity_t {.cdecl.}
#     lookup_ctx*: pointer

#   ecs_primitive_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     kind*: ecs_primitive_kind_t

#   ecs_enum_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     constants*: array[(32), ecs_enum_constant_t]
#     underlying_type*: ecs_entity_t

#   ecs_bitmask_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     constants*: array[(32), ecs_bitmask_constant_t]

#   ecs_array_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     `type`*: ecs_entity_t
#     count*: int32

#   ecs_vector_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     `type`*: ecs_entity_t

#   ecs_struct_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     members*: array[(32), ecs_member_t]

#   ecs_opaque_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     `type`*: EcsOpaque

#   ecs_unit_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     symbol*: cstring
#     quantity*: ecs_entity_t
#     base*: ecs_entity_t
#     over*: ecs_entity_t
#     translation*: ecs_unit_translation_t
#     prefix*: ecs_entity_t

#   ecs_unit_prefix_desc_t* {.bycopy.} = object
#     entity*: ecs_entity_t
#     symbol*: cstring
#     translation*: ecs_unit_translation_t

# var ecs_os_api_malloc_count*: int64

# var ecs_os_api_realloc_count*: int64

# var ecs_os_api_calloc_count*: int64

# var ecs_os_api_free_count*: int64

# var ecs_os_api*: ecs_os_api_t

# proc ecs_os_init*() {.importc, cdecl.}
# proc ecs_os_fini*() {.importc, cdecl.}
# proc ecs_os_set_api*(os_api: ptr ecs_os_api_t) {.importc, cdecl.}
# proc ecs_os_get_api*(): ecs_os_api_t {.importc, cdecl.}
# proc ecs_os_set_api_defaults*() {.importc, cdecl.}
# proc ecs_os_dbg*(file: cstring; line: int32; msg: cstring) {.importc, cdecl.}
# proc ecs_os_trace*(file: cstring; line: int32; msg: cstring) {.importc, cdecl.}
# proc ecs_os_warn*(file: cstring; line: int32; msg: cstring) {.importc, cdecl.}
# proc ecs_os_err*(file: cstring; line: int32; msg: cstring) {.importc, cdecl.}
# proc ecs_os_fatal*(file: cstring; line: int32; msg: cstring) {.importc, cdecl.}
# proc ecs_os_strerror*(err: cint): cstring {.importc, cdecl.}
# proc ecs_os_strset*(str: cstringArray; value: cstring) {.importc, cdecl.}
# proc ecs_os_perf_trace_push*(file: cstring; line: csize_t;
#     name: cstring) {.importc, cdecl.}
# proc ecs_os_perf_trace_pop*(file: cstring; line: csize_t;
#     name: cstring) {.importc, cdecl.}
# proc ecs_sleepf*(t: cdouble) {.importc, cdecl.}
# proc ecs_time_measure*(start: ptr ecs_time_t): cdouble {.importc, cdecl.}
# proc ecs_time_sub*(t1: ecs_time_t; t2: ecs_time_t): ecs_time_t {.importc, cdecl.}
# proc ecs_time_to_double*(t: ecs_time_t): cdouble {.importc, cdecl.}
# proc ecs_os_memdup*(src: pointer; size: ecs_size_t): pointer {.importc, cdecl.}
# proc ecs_os_has_heap*(): bool {.importc, cdecl.}
# proc ecs_os_has_threading*(): bool {.importc, cdecl.}
# proc ecs_os_has_task_support*(): bool {.importc, cdecl.}
# proc ecs_os_has_time*(): bool {.importc, cdecl.}
# proc ecs_os_has_logging*(): bool {.importc, cdecl.}
# proc ecs_os_has_dl*(): bool {.importc, cdecl.}
# proc ecs_os_has_modules*(): bool {.importc, cdecl.}


# proc flecs_module_path_from_c*(c_name: cstring): cstring {.importc, cdecl.}
# proc flecs_default_ctor*(`ptr`: pointer; count: int32;
#                         type_info: ptr ecs_type_info_t) {.importc, cdecl.}
# proc flecs_vasprintf*(fmt: cstring): cstring {.importc, cdecl, varargs.}
# proc flecs_asprintf*(fmt: cstring): cstring {.importc, cdecl, varargs.}
# proc flecs_chresc*(`out`: cstring; `in`: char;
#     delimiter: char): cstring {.importc, cdecl.}
# proc flecs_chrparse*(`in`: cstring; `out`: cstring): cstring {.importc, cdecl.}
# proc flecs_stresc*(`out`: cstring; size: ecs_size_t; delimiter: char;
#     `in`: cstring): ecs_size_t {.importc, cdecl.}
# proc flecs_astresc*(delimiter: char; `in`: cstring): cstring {.importc, cdecl.}
# proc flecs_parse_ws_eol*(`ptr`: cstring): cstring {.importc, cdecl.}
# proc flecs_parse_digit*(`ptr`: cstring; token: cstring): cstring {.importc, cdecl.}
# proc flecs_to_snake_case*(str: cstring): cstring {.importc, cdecl.}

# proc flecs_suspend_readonly*(world: ecs_world_t;
#                             state: ptr ecs_suspend_readonly_state_t): ecs_world_t {.importc, cdecl.}
# proc flecs_resume_readonly*(world: ecs_world_t;
#                            state: ptr ecs_suspend_readonly_state_t) {.importc, cdecl.}
# proc flecs_table_observed_count*(table: ptr ecs_table_t): int32 {.importc, cdecl.}
# proc flecs_dump_backtrace*(stream: pointer) {.importc, cdecl.}
# proc flecs_poly_claim*(poly: ptr ecs_poly_t): int32 {.importc, cdecl.}
# proc flecs_poly_release*(poly: ptr ecs_poly_t): int32 {.importc, cdecl.}
# proc flecs_poly_refcount*(poly: ptr ecs_poly_t): int32 {.importc, cdecl.}
# proc flecs_component_ids_index_get*(): int32 {.importc, cdecl.}
# proc flecs_component_ids_get*(world: ecs_world_t;
#     index: int32): ecs_entity_t {.importc, cdecl.}
# proc flecs_component_ids_get_alive*(world: ecs_world_t;
#     index: int32): ecs_entity_t {.importc, cdecl.}
# proc flecs_component_ids_set*(world: ecs_world_t; index: int32;
#     id: ecs_entity_t) {.importc, cdecl.}
# proc flecs_hashmap_init*(hm: ptr ecs_hashmap_t; key_size: ecs_size_t;
#                          value_size: ecs_size_t; hash: ecs_hash_value_action_t;
#                          compare: ecs_compare_action_t;
#                          allocator: ptr ecs_allocator_t) {.importc, cdecl.}
# proc flecs_hashmap_fini*(map: ptr ecs_hashmap_t) {.importc, cdecl.}
# proc flecs_hashmap_get*(map: ptr ecs_hashmap_t; key_size: ecs_size_t; key: pointer;
#                         value_size: ecs_size_t): pointer {.importc, cdecl.}
# proc flecs_hashmap_ensure*(map: ptr ecs_hashmap_t; key_size: ecs_size_t;
#                            key: pointer;
#                                value_size: ecs_size_t): flecs_hashmap_result_t {.importc, cdecl.}
# proc flecs_hashmap_set*(map: ptr ecs_hashmap_t; key_size: ecs_size_t; key: pointer;
#                         value_size: ecs_size_t; value: pointer) {.importc, cdecl.}
# proc flecs_hashmap_remove*(map: ptr ecs_hashmap_t; key_size: ecs_size_t;
#                            key: pointer; value_size: ecs_size_t) {.importc, cdecl.}
# proc flecs_hashmap_remove_w_hash*(map: ptr ecs_hashmap_t; key_size: ecs_size_t;
#                                   key: pointer; value_size: ecs_size_t;
#                                   hash: uint64) {.importc, cdecl.}
# proc flecs_hashmap_get_bucket*(map: ptr ecs_hashmap_t;
#     hash: uint64): ptr ecs_hm_bucket_t {.importc, cdecl.}
# proc flecs_hm_bucket_remove*(map: ptr ecs_hashmap_t; bucket: ptr ecs_hm_bucket_t;
#                             hash: uint64; index: int32) {.importc, cdecl.}
# proc flecs_hashmap_copy*(dst: ptr ecs_hashmap_t;
#     src: ptr ecs_hashmap_t) {.importc, cdecl.}
# proc flecs_hashmap_iter*(map: ptr ecs_hashmap_t): flecs_hashmap_iter_t {.importc, cdecl.}
# proc flecs_hashmap_next*(it: ptr flecs_hashmap_iter_t; key_size: ecs_size_t;
#                          key_out: pointer;
#                              value_size: ecs_size_t): pointer {.importc, cdecl.}

# proc ecs_record_find*(world: ecs_world_t;
#     entity: ecs_entity_t): ptr ecs_record_t {.importc, cdecl.}
# proc ecs_record_get_entity*(record: ptr ecs_record_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_write_begin*(world: ecs_world_t;
#     entity: ecs_entity_t): ptr ecs_record_t {.importc, cdecl.}
# proc ecs_write_end*(record: ptr ecs_record_t) {.importc, cdecl.}
# proc ecs_read_begin*(world: ecs_world_t;
#     entity: ecs_entity_t): ptr ecs_record_t {.importc, cdecl.}
# proc ecs_read_end*(record: ptr ecs_record_t) {.importc, cdecl.}
# proc ecs_record_get_id*(world: ecs_world_t; record: ptr ecs_record_t;
#     id: ecs_id_t): pointer {.importc, cdecl.}
# proc ecs_record_ensure_id*(world: ecs_world_t; record: ptr ecs_record_t;
#                           id: ecs_id_t): pointer {.importc, cdecl.}
# proc ecs_record_has_id*(world: ecs_world_t; record: ptr ecs_record_t;
#     id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_record_get_by_column*(record: ptr ecs_record_t; column: int32;
#                               size: csize_t): pointer {.importc, cdecl.}
# proc flecs_components_get*(world: ecs_world_t;
#     id: ecs_id_t): ptr ecs_component_record_t {.importc, cdecl.}
# proc flecs_component_get_table*(cdr: ptr ecs_component_record_t;
#                                table: ptr ecs_table_t): ptr ecs_table_record_t {.importc, cdecl.}
# proc flecs_component_iter*(cdr: ptr ecs_component_record_t;
#                           iter_out: ptr ecs_table_cache_iter_t): bool {.importc, cdecl.}
# proc flecs_component_next*(iter: ptr ecs_table_cache_iter_t): ptr ecs_table_record_t {.importc, cdecl.}

# proc flecs_table_records*(table: ptr ecs_table_t): ecs_table_records_t {.importc, cdecl.}



# proc ecs_init*(): ecs_world_t {.importc, cdecl.}
# proc ecs_mini*(): ecs_world_t {.importc, cdecl.}
# proc ecs_init_w_args*(argc: cint; argv: ptr cstring): ecs_world_t {.importc, cdecl.}
# proc ecs_fini*(world: ecs_world_t): cint {.importc, cdecl.}
# proc ecs_is_fini*(world: ecs_world_t): bool {.importc, cdecl.}
# proc ecs_atfini*(world: ecs_world_t; action: ecs_fini_action_t;
#     ctx: pointer) {.importc, cdecl.}

# proc ecs_get_entities*(world: ecs_world_t): ecs_entities_t {.importc, cdecl.}
# proc ecs_world_get_flags*(world: ecs_world_t): ecs_flags32_t {.importc, cdecl.}
# proc ecs_frame_begin*(world: ecs_world_t; delta_time: cfloat): cfloat {.importc, cdecl.}
# proc ecs_frame_end*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_run_post_frame*(world: ecs_world_t; action: ecs_fini_action_t;
#                         ctx: pointer) {.importc, cdecl.}
# proc ecs_quit*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_should_quit*(world: ecs_world_t): bool {.importc, cdecl.}
# proc ecs_measure_frame_time*(world: ecs_world_t; enable: bool) {.importc, cdecl.}
# proc ecs_measure_system_time*(world: ecs_world_t; enable: bool) {.importc, cdecl.}
# proc ecs_set_target_fps*(world: ecs_world_t; fps: cfloat) {.importc, cdecl.}
# proc ecs_set_default_query_flags*(world: ecs_world_t;
#     flags: ecs_flags32_t) {.importc, cdecl.}
# proc ecs_readonly_begin*(world: ecs_world_t;
#     multi_threaded: bool): bool {.importc, cdecl.}
# proc ecs_readonly_end*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_merge*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_defer_begin*(world: ecs_world_t): bool {.importc, cdecl.}
# proc ecs_is_deferred*(world: ecs_world_t): bool {.importc, cdecl.}
# proc ecs_defer_end*(world: ecs_world_t): bool {.importc, cdecl.}
# proc ecs_defer_suspend*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_defer_resume*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_set_stage_count*(world: ecs_world_t; stages: int32) {.importc, cdecl.}
# proc ecs_get_stage_count*(world: ecs_world_t): int32 {.importc, cdecl.}
# proc ecs_get_stage*(world: ecs_world_t; stage_id: int32): ecs_world_t {.importc, cdecl.}
# proc ecs_stage_is_readonly*(world: ecs_world_t): bool {.importc, cdecl.}
# proc ecs_stage_new*(world: ecs_world_t): ecs_world_t {.importc, cdecl.}
# proc ecs_stage_free*(stage: ecs_world_t) {.importc, cdecl.}
# proc ecs_stage_get_id*(world: ecs_world_t): int32 {.importc, cdecl.}
# proc ecs_set_ctx*(world: ecs_world_t; ctx: pointer;
#     ctx_free: ecs_ctx_free_t) {.importc, cdecl.}
# proc ecs_set_binding_ctx*(world: ecs_world_t; ctx: pointer;
#                          ctx_free: ecs_ctx_free_t) {.importc, cdecl.}
# proc ecs_get_ctx*(world: ecs_world_t): pointer {.importc, cdecl.}
# proc ecs_get_binding_ctx*(world: ecs_world_t): pointer {.importc, cdecl.}
# proc ecs_get_build_info*(): ptr ecs_build_info_t {.importc, cdecl.}
# proc ecs_get_world_info*(world: ecs_world_t): ptr ecs_world_info_t {.importc, cdecl.}
# proc ecs_dim*(world: ecs_world_t; entity_count: int32) {.importc, cdecl.}
# proc ecs_shrink*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_set_entity_range*(world: ecs_world_t; id_start: ecs_entity_t;
#                           id_end: ecs_entity_t) {.importc, cdecl.}
# proc ecs_enable_range_check*(world: ecs_world_t; enable: bool): bool {.importc, cdecl.}
# proc ecs_get_max_id*(world: ecs_world_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_run_aperiodic*(world: ecs_world_t; flags: ecs_flags32_t) {.importc, cdecl.}

# proc ecs_delete_empty_tables*(world: ecs_world_t;
#                              desc: ptr ecs_delete_empty_tables_desc_t): int32 {.importc, cdecl.}
# proc ecs_get_world*(poly: ptr ecs_poly_t): ecs_world_t {.importc, cdecl.}
# proc ecs_get_entity*(poly: ptr ecs_poly_t): ecs_entity_t {.importc, cdecl.}
# proc flecs_poly_is*(`object`: ptr ecs_poly_t; `type`: int32): bool {.importc, cdecl.}
# proc ecs_make_pair*(first: ecs_entity_t;
#     second: ecs_entity_t): ecs_id_t {.importc, cdecl.}
# proc ecs_new*(world: ecs_world_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_new_low_id*(world: ecs_world_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_new_w_id*(world: ecs_world_t; id: ecs_id_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_new_w_table*(world: ecs_world_t;
#     table: ptr ecs_table_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_entity_init*(world: ecs_world_t;
#     desc: ptr ecs_entity_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_bulk_init*(world: ecs_world_t; desc: ptr ecs_bulk_desc_t): ptr ecs_entity_t {.importc, cdecl.}
# proc ecs_bulk_new_w_id*(world: ecs_world_t; id: ecs_id_t;
#     count: int32): ptr ecs_entity_t {.importc, cdecl.}
# proc ecs_clone*(world: ecs_world_t; dst: ecs_entity_t; src: ecs_entity_t;
#                copy_value: bool): ecs_entity_t {.importc, cdecl.}
# proc ecs_delete*(world: ecs_world_t; entity: ecs_entity_t) {.importc, cdecl.}
# proc ecs_delete_with*(world: ecs_world_t; id: ecs_id_t) {.importc, cdecl.}
# proc ecs_add_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t) {.importc, cdecl.}
# proc ecs_remove_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t) {.importc, cdecl.}
# proc ecs_auto_override_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t) {.importc, cdecl.}
# proc ecs_clear*(world: ecs_world_t; entity: ecs_entity_t) {.importc, cdecl.}
# proc ecs_remove_all*(world: ecs_world_t; id: ecs_id_t) {.importc, cdecl.}
# proc ecs_set_with*(world: ecs_world_t; id: ecs_id_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_with*(world: ecs_world_t): ecs_id_t {.importc, cdecl.}
# proc ecs_enable*(world: ecs_world_t; entity: ecs_entity_t;
#     enabled: bool) {.importc, cdecl.}
# proc ecs_enable_id*(world: ecs_world_t; entity: ecs_entity_t; id: ecs_id_t;
#                    enable: bool) {.importc, cdecl.}
# proc ecs_is_enabled_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_get_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t): pointer {.importc, cdecl.}
# proc ecs_get_mut_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t): pointer {.importc, cdecl.}
# proc ecs_ensure_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t): pointer {.importc, cdecl.}
# proc ecs_ensure_modified_id*(world: ecs_world_t; entity: ecs_entity_t;
#                             id: ecs_id_t): pointer {.importc, cdecl.}
# proc ecs_ref_init_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t): ecs_ref_t {.importc, cdecl.}
# proc ecs_ref_get_id*(world: ecs_world_t; `ref`: ptr ecs_ref_t;
#     id: ecs_id_t): pointer {.importc, cdecl.}
# proc ecs_ref_update*(world: ecs_world_t; `ref`: ptr ecs_ref_t) {.importc, cdecl.}
# proc ecs_emplace_id*(world: ecs_world_t; entity: ecs_entity_t; id: ecs_id_t;
#                     is_new: ptr bool): pointer {.importc, cdecl.}
# proc ecs_modified_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t) {.importc, cdecl.}
# proc ecs_set_id*(world: ecs_world_t; entity: ecs_entity_t; id: ecs_id_t;
#                 size: csize_t; `ptr`: pointer) {.importc, cdecl.}
# proc ecs_is_valid*(world: ecs_world_t; e: ecs_entity_t): bool {.importc, cdecl.}
# proc ecs_is_alive*(world: ecs_world_t; e: ecs_entity_t): bool {.importc, cdecl.}
# proc ecs_strip_generation*(e: ecs_entity_t): ecs_id_t {.importc, cdecl.}
# proc ecs_get_alive*(world: ecs_world_t; e: ecs_entity_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_make_alive*(world: ecs_world_t; entity: ecs_entity_t) {.importc, cdecl.}
# proc ecs_make_alive_id*(world: ecs_world_t; id: ecs_id_t) {.importc, cdecl.}
# proc ecs_exists*(world: ecs_world_t; entity: ecs_entity_t): bool {.importc, cdecl.}
# proc ecs_set_version*(world: ecs_world_t; entity: ecs_entity_t) {.importc, cdecl.}
# proc ecs_get_type*(world: ecs_world_t; entity: ecs_entity_t): ptr ecs_type_t {.importc, cdecl.}
# proc ecs_get_table*(world: ecs_world_t; entity: ecs_entity_t): ptr ecs_table_t {.importc, cdecl.}
# proc ecs_type_str*(world: ecs_world_t; `type`: ptr ecs_type_t): cstring {.importc, cdecl.}
# proc ecs_table_str*(world: ecs_world_t; table: ptr ecs_table_t): cstring {.importc, cdecl.}
# proc ecs_entity_str*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_has_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_owns_id*(world: ecs_world_t; entity: ecs_entity_t;
#     id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_get_target*(world: ecs_world_t; entity: ecs_entity_t; rel: ecs_entity_t;
#                     index: int32): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_parent*(world: ecs_world_t;
#     entity: ecs_entity_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_target_for_id*(world: ecs_world_t; entity: ecs_entity_t;
#                            rel: ecs_entity_t;
#                                id: ecs_id_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_depth*(world: ecs_world_t; entity: ecs_entity_t;
#     rel: ecs_entity_t): int32 {.importc, cdecl.}
# proc ecs_count_id*(world: ecs_world_t; entity: ecs_id_t): int32 {.importc, cdecl.}
# proc ecs_get_name*(world: ecs_world_t; entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_get_symbol*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_set_name*(world: ecs_world_t; entity: ecs_entity_t;
#     name: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_set_symbol*(world: ecs_world_t; entity: ecs_entity_t;
#     symbol: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_set_alias*(world: ecs_world_t; entity: ecs_entity_t;
#     alias: cstring) {.importc, cdecl.}
# proc ecs_lookup*(world: ecs_world_t; path: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_lookup_child*(world: ecs_world_t; parent: ecs_entity_t;
#     name: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_lookup_path_w_sep*(world: ecs_world_t; parent: ecs_entity_t;
#                            path: cstring; sep: cstring; prefix: cstring;
#                            recursive: bool): ecs_entity_t {.importc, cdecl.}
# proc ecs_lookup_symbol*(world: ecs_world_t; symbol: cstring;
#                        lookup_as_path: bool;
#                            recursive: bool): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_path_w_sep*(world: ecs_world_t; parent: ecs_entity_t;
#                         child: ecs_entity_t; sep: cstring;
#                             prefix: cstring): cstring {.importc, cdecl.}
# proc ecs_get_path_w_sep_buf*(world: ecs_world_t; parent: ecs_entity_t;
#                             child: ecs_entity_t; sep: cstring; prefix: cstring;
#                             buf: ptr ecs_strbuf_t; escape: bool) {.importc, cdecl.}
# proc ecs_new_from_path_w_sep*(world: ecs_world_t; parent: ecs_entity_t;
#                              path: cstring; sep: cstring;
#                                  prefix: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_add_path_w_sep*(world: ecs_world_t; entity: ecs_entity_t;
#                         parent: ecs_entity_t; path: cstring; sep: cstring;
#                         prefix: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_set_scope*(world: ecs_world_t; scope: ecs_entity_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_scope*(world: ecs_world_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_set_name_prefix*(world: ecs_world_t;
#     prefix: cstring): cstring {.importc, cdecl.}
# proc ecs_set_lookup_path*(world: ecs_world_t;
#     lookup_path: ptr ecs_entity_t): ptr ecs_entity_t {.importc, cdecl.}
# proc ecs_get_lookup_path*(world: ecs_world_t): ptr ecs_entity_t {.importc, cdecl.}
# proc ecs_component_init*(world: ecs_world_t;
#     desc: ptr ecs_component_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_type_info*(world: ecs_world_t;
#     id: ecs_id_t): ptr ecs_type_info_t {.importc, cdecl.}
# proc ecs_set_hooks_id*(world: ecs_world_t; id: ecs_entity_t;
#                       hooks: ptr ecs_type_hooks_t) {.importc, cdecl.}
# proc ecs_get_hooks_id*(world: ecs_world_t;
#     id: ecs_entity_t): ptr ecs_type_hooks_t {.importc, cdecl.}
# proc ecs_id_is_tag*(world: ecs_world_t; id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_id_in_use*(world: ecs_world_t; id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_get_typeid*(world: ecs_world_t; id: ecs_id_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_id_match*(id: ecs_id_t; pattern: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_id_is_pair*(id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_id_is_wildcard*(id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_id_is_valid*(world: ecs_world_t; id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_id_get_flags*(world: ecs_world_t;
#     id: ecs_id_t): ecs_flags32_t {.importc, cdecl.}
# proc ecs_id_flag_str*(id_flags: ecs_id_t): cstring {.importc, cdecl.}
# proc ecs_id_str*(world: ecs_world_t; id: ecs_id_t): cstring {.importc, cdecl.}
# proc ecs_id_str_buf*(world: ecs_world_t; id: ecs_id_t;
#     buf: ptr ecs_strbuf_t) {.importc, cdecl.}
# proc ecs_id_from_str*(world: ecs_world_t; expr: cstring): ecs_id_t {.importc, cdecl.}
# proc ecs_term_ref_is_set*(id: ptr ecs_term_ref_t): bool {.importc, cdecl.}
# proc ecs_term_is_initialized*(term: ptr ecs_term_t): bool {.importc, cdecl.}
# proc ecs_term_match_this*(term: ptr ecs_term_t): bool {.importc, cdecl.}
# proc ecs_term_match_0*(term: ptr ecs_term_t): bool {.importc, cdecl.}
# proc ecs_term_str*(world: ecs_world_t; term: ptr ecs_term_t): cstring {.importc, cdecl.}
# proc ecs_query_str*(query: ptr ecs_query_t): cstring {.importc, cdecl.}
# proc ecs_each_id*(world: ecs_world_t; id: ecs_id_t): ecs_iter_t {.importc, cdecl.}
# proc ecs_each_next*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_children*(world: ecs_world_t; parent: ecs_entity_t): ecs_iter_t {.importc, cdecl.}
# proc ecs_children_next*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_query_init*(world: ecs_world_t;
#     desc: ptr ecs_query_desc_t): ptr ecs_query_t {.importc, cdecl.}
# proc ecs_query_fini*(query: ptr ecs_query_t) {.importc, cdecl.}
# proc ecs_query_find_var*(query: ptr ecs_query_t;
#     name: cstring): int32 {.importc, cdecl.}
# proc ecs_query_var_name*(query: ptr ecs_query_t;
#     var_id: int32): cstring {.importc, cdecl.}
# proc ecs_query_var_is_entity*(query: ptr ecs_query_t;
#     var_id: int32): bool {.importc, cdecl.}
# proc ecs_query_iter*(world: ecs_world_t;
#     query: ptr ecs_query_t): ecs_iter_t {.importc, cdecl.}
# proc ecs_query_next*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_query_has*(query: ptr ecs_query_t; entity: ecs_entity_t;
#     it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_query_has_table*(query: ptr ecs_query_t; table: ptr ecs_table_t;
#                          it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_query_has_range*(query: ptr ecs_query_t; range: ptr ecs_table_range_t;
#                          it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_query_match_count*(query: ptr ecs_query_t): int32 {.importc, cdecl.}
# proc ecs_query_plan*(query: ptr ecs_query_t): cstring {.importc, cdecl.}
# proc ecs_query_plan_w_profile*(query: ptr ecs_query_t;
#     it: ptr ecs_iter_t): cstring {.importc, cdecl.}
# proc ecs_query_args_parse*(query: ptr ecs_query_t; it: ptr ecs_iter_t;
#     expr: cstring): cstring {.importc, cdecl.}
# proc ecs_query_changed*(query: ptr ecs_query_t): bool {.importc, cdecl.}
# proc ecs_query_get*(world: ecs_world_t; query: ecs_entity_t): ptr ecs_query_t {.importc, cdecl.}
# proc ecs_iter_skip*(it: ptr ecs_iter_t) {.importc, cdecl.}
# proc ecs_iter_set_group*(it: ptr ecs_iter_t; group_id: uint64) {.importc, cdecl.}
# proc ecs_query_get_group_ctx*(query: ptr ecs_query_t;
#     group_id: uint64): pointer {.importc, cdecl.}
# proc ecs_query_get_group_info*(query: ptr ecs_query_t;
#     group_id: uint64): ptr ecs_query_group_info_t {.importc, cdecl.}

# proc ecs_query_count*(query: ptr ecs_query_t): ecs_query_count_t {.importc, cdecl.}
# proc ecs_query_is_true*(query: ptr ecs_query_t): bool {.importc, cdecl.}
# proc ecs_query_get_cache_query*(query: ptr ecs_query_t): ptr ecs_query_t {.importc, cdecl.}
# proc ecs_emit*(world: ecs_world_t; desc: ptr ecs_event_desc_t) {.importc, cdecl.}
# proc ecs_enqueue*(world: ecs_world_t; desc: ptr ecs_event_desc_t) {.importc, cdecl.}
# proc ecs_observer_init*(world: ecs_world_t;
#     desc: ptr ecs_observer_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_observer_get*(world: ecs_world_t;
#     observer: ecs_entity_t): ptr ecs_observer_t {.importc, cdecl.}
# proc ecs_iter_next*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_iter_fini*(it: ptr ecs_iter_t) {.importc, cdecl.}
# proc ecs_iter_count*(it: ptr ecs_iter_t): int32 {.importc, cdecl.}
# proc ecs_iter_is_true*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_iter_first*(it: ptr ecs_iter_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_iter_set_var*(it: ptr ecs_iter_t; var_id: int32;
#     entity: ecs_entity_t) {.importc, cdecl.}
# proc ecs_iter_set_var_as_table*(it: ptr ecs_iter_t; var_id: int32;
#                                table: ptr ecs_table_t) {.importc, cdecl.}
# proc ecs_iter_set_var_as_range*(it: ptr ecs_iter_t; var_id: int32;
#                                range: ptr ecs_table_range_t) {.importc, cdecl.}
# proc ecs_iter_get_var*(it: ptr ecs_iter_t;
#     var_id: int32): ecs_entity_t {.importc, cdecl.}
# proc ecs_iter_get_var_as_table*(it: ptr ecs_iter_t;
#     var_id: int32): ptr ecs_table_t {.importc, cdecl.}
# proc ecs_iter_get_var_as_range*(it: ptr ecs_iter_t;
#     var_id: int32): ecs_table_range_t {.importc, cdecl.}
# proc ecs_iter_var_is_constrained*(it: ptr ecs_iter_t;
#     var_id: int32): bool {.importc, cdecl.}
# proc ecs_iter_changed*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_iter_str*(it: ptr ecs_iter_t): cstring {.importc, cdecl.}
# proc ecs_page_iter*(it: ptr ecs_iter_t; offset: int32;
#     limit: int32): ecs_iter_t {.importc, cdecl.}
# proc ecs_page_next*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_worker_iter*(it: ptr ecs_iter_t; index: int32;
#     count: int32): ecs_iter_t {.importc, cdecl.}
# proc ecs_worker_next*(it: ptr ecs_iter_t): bool {.importc, cdecl.}
# proc ecs_field_w_size*(it: ptr ecs_iter_t; size: csize_t;
#     index: int8): pointer {.importc, cdecl.}
# proc ecs_field_at_w_size*(it: ptr ecs_iter_t; size: csize_t; index: int8;
#     row: int32): pointer {.importc, cdecl.}
# proc ecs_field_is_readonly*(it: ptr ecs_iter_t; index: int8): bool {.importc, cdecl.}
# proc ecs_field_is_writeonly*(it: ptr ecs_iter_t; index: int8): bool {.importc, cdecl.}
# proc ecs_field_is_set*(it: ptr ecs_iter_t; index: int8): bool {.importc, cdecl.}
# proc ecs_field_id*(it: ptr ecs_iter_t; index: int8): ecs_id_t {.importc, cdecl.}
# proc ecs_field_column*(it: ptr ecs_iter_t; index: int8): int32 {.importc, cdecl.}
# proc ecs_field_src*(it: ptr ecs_iter_t; index: int8): ecs_entity_t {.importc, cdecl.}
# proc ecs_field_size*(it: ptr ecs_iter_t; index: int8): csize_t {.importc, cdecl.}
# proc ecs_field_is_self*(it: ptr ecs_iter_t; index: int8): bool {.importc, cdecl.}
# proc ecs_table_get_type*(table: ptr ecs_table_t): ptr ecs_type_t {.importc, cdecl.}
# proc ecs_table_get_type_index*(world: ecs_world_t; table: ptr ecs_table_t;
#                               id: ecs_id_t): int32 {.importc, cdecl.}
# proc ecs_table_get_column_index*(world: ecs_world_t; table: ptr ecs_table_t;
#                                 id: ecs_id_t): int32 {.importc, cdecl.}
# proc ecs_table_column_count*(table: ptr ecs_table_t): int32 {.importc, cdecl.}
# proc ecs_table_type_to_column_index*(table: ptr ecs_table_t;
#     index: int32): int32 {.importc, cdecl.}
# proc ecs_table_column_to_type_index*(table: ptr ecs_table_t;
#     index: int32): int32 {.importc, cdecl.}
# proc ecs_table_get_column*(table: ptr ecs_table_t; index: int32;
#     offset: int32): pointer {.importc, cdecl.}
# proc ecs_table_get_id*(world: ecs_world_t; table: ptr ecs_table_t; id: ecs_id_t;
#                       offset: int32): pointer {.importc, cdecl.}
# proc ecs_table_get_column_size*(table: ptr ecs_table_t;
#     index: int32): csize_t {.importc, cdecl.}
# proc ecs_table_count*(table: ptr ecs_table_t): int32 {.importc, cdecl.}
# proc ecs_table_size*(table: ptr ecs_table_t): int32 {.importc, cdecl.}
# proc ecs_table_entities*(table: ptr ecs_table_t): ptr ecs_entity_t {.importc, cdecl.}
# proc ecs_table_has_id*(world: ecs_world_t; table: ptr ecs_table_t;
#     id: ecs_id_t): bool {.importc, cdecl.}
# proc ecs_table_get_depth*(world: ecs_world_t; table: ptr ecs_table_t;
#                          rel: ecs_entity_t): int32 {.importc, cdecl.}
# proc ecs_table_add_id*(world: ecs_world_t; table: ptr ecs_table_t;
#     id: ecs_id_t): ptr ecs_table_t {.importc, cdecl.}
# proc ecs_table_find*(world: ecs_world_t; ids: ptr ecs_id_t;
#     id_count: int32): ptr ecs_table_t {.importc, cdecl.}
# proc ecs_table_remove_id*(world: ecs_world_t; table: ptr ecs_table_t;
#     id: ecs_id_t): ptr ecs_table_t {.importc, cdecl.}
# proc ecs_table_lock*(world: ecs_world_t; table: ptr ecs_table_t) {.importc, cdecl.}
# proc ecs_table_unlock*(world: ecs_world_t; table: ptr ecs_table_t) {.importc, cdecl.}
# proc ecs_table_has_flags*(table: ptr ecs_table_t;
#     flags: ecs_flags32_t): bool {.importc, cdecl.}
# proc ecs_table_swap_rows*(world: ecs_world_t; table: ptr ecs_table_t;
#                          row_1: int32; row_2: int32) {.importc, cdecl.}
# proc ecs_commit*(world: ecs_world_t; entity: ecs_entity_t;
#                 record: ptr ecs_record_t; table: ptr ecs_table_t;
#                 added: ptr ecs_type_t; removed: ptr ecs_type_t): bool {.importc, cdecl.}
# proc ecs_search*(world: ecs_world_t; table: ptr ecs_table_t; id: ecs_id_t;
#                 id_out: ptr ecs_id_t): int32 {.importc, cdecl.}
# proc ecs_search_offset*(world: ecs_world_t; table: ptr ecs_table_t;
#                        offset: int32; id: ecs_id_t;
#                            id_out: ptr ecs_id_t): int32 {.importc, cdecl.}
# proc ecs_search_relation*(world: ecs_world_t; table: ptr ecs_table_t;
#                          offset: int32; id: ecs_id_t; rel: ecs_entity_t;
#                          flags: ecs_flags64_t; subject_out: ptr ecs_entity_t;
#                          id_out: ptr ecs_id_t;
#                              tr_out: ptr ptr ecs_table_record_t): int32 {.importc, cdecl.}
# proc ecs_table_clear_entities*(world: ecs_world_t;
#     table: ptr ecs_table_t) {.importc, cdecl.}
# proc ecs_value_init*(world: ecs_world_t; `type`: ecs_entity_t;
#     `ptr`: pointer): cint {.importc, cdecl.}
# proc ecs_value_init_w_type_info*(world: ecs_world_t; ti: ptr ecs_type_info_t;
#                                 `ptr`: pointer): cint {.importc, cdecl.}
# proc ecs_value_new*(world: ecs_world_t; `type`: ecs_entity_t): pointer {.importc, cdecl.}
# proc ecs_value_new_w_type_info*(world: ecs_world_t;
#     ti: ptr ecs_type_info_t): pointer {.importc, cdecl.}
# proc ecs_value_fini_w_type_info*(world: ecs_world_t; ti: ptr ecs_type_info_t;
#                                 `ptr`: pointer): cint {.importc, cdecl.}
# proc ecs_value_fini*(world: ecs_world_t; `type`: ecs_entity_t;
#     `ptr`: pointer): cint {.importc, cdecl.}
# proc ecs_value_free*(world: ecs_world_t; `type`: ecs_entity_t;
#     `ptr`: pointer): cint {.importc, cdecl.}
# proc ecs_value_copy_w_type_info*(world: ecs_world_t; ti: ptr ecs_type_info_t;
#                                 dst: pointer; src: pointer): cint {.importc, cdecl.}
# proc ecs_value_copy*(world: ecs_world_t; `type`: ecs_entity_t; dst: pointer;
#                     src: pointer): cint {.importc, cdecl.}
# proc ecs_value_move_w_type_info*(world: ecs_world_t; ti: ptr ecs_type_info_t;
#                                 dst: pointer; src: pointer): cint {.importc, cdecl.}
# proc ecs_value_move*(world: ecs_world_t; `type`: ecs_entity_t; dst: pointer;
#                     src: pointer): cint {.importc, cdecl.}
# proc ecs_value_move_ctor_w_type_info*(world: ecs_world_t;
#                                      ti: ptr ecs_type_info_t; dst: pointer;
#                                      src: pointer): cint {.importc, cdecl.}
# proc ecs_value_move_ctor*(world: ecs_world_t; `type`: ecs_entity_t; dst: pointer;
#                          src: pointer): cint {.importc, cdecl.}
# proc ecs_deprecated*(file: cstring; line: int32; msg: cstring) {.importc, cdecl.}
# proc ecs_log_push*(level: int32) {.importc, cdecl.}
# proc ecs_log_pop*(level: int32) {.importc, cdecl.}
# proc ecs_should_log*(level: int32): bool {.importc, cdecl.}
# proc ecs_strerror*(error_code: int32): cstring {.importc, cdecl.}
# proc ecs_print*(level: int32; file: cstring; line: int32;
#     fmt: cstring) {.importc, cdecl, varargs.}
# proc ecs_printv*(level: cint; file: cstring; line: int32;
#     fmt: cstring) {.importc, cdecl.}
# proc ecs_log*(level: int32; file: cstring; line: int32; fmt: cstring) {.importc,
#     cdecl, varargs.}
# proc ecs_logv*(level: cint; file: cstring; line: int32; fmt: cstring) {.importc,
#     cdecl, varargs.}
# proc ecs_abort*(error_code: int32; file: cstring; line: int32; fmt: cstring) {.
#     importc, cdecl, varargs.}
# proc ecs_assert_log*(error_code: int32; condition_str: cstring; file: cstring;
#                      line: int32; fmt: cstring) {.importc, cdecl, varargs.}
# proc ecs_parser_error*(name: cstring; expr: cstring; column: int64;
#     fmt: cstring) {.
#     importc, cdecl, varargs.}
# proc ecs_parser_errorv*(name: cstring; expr: cstring; column: int64;
#     fmt: cstring) {.importc, cdecl, varargs.}
# proc ecs_parser_warning*(name: cstring; expr: cstring; column: int64;
#     fmt: cstring) {.
#     importc, cdecl, varargs.}
# proc ecs_parser_warningv*(name: cstring; expr: cstring; column: int64;
#     fmt: cstring) {.importc, cdecl, varargs.}
# proc ecs_log_set_level*(level: cint): cint {.importc, cdecl.}
# proc ecs_log_get_level*(): cint {.importc, cdecl.}
# proc ecs_log_enable_colors*(enabled: bool): bool {.importc, cdecl.}
# proc ecs_log_enable_timestamp*(enabled: bool): bool {.importc, cdecl.}
# proc ecs_log_enable_timedelta*(enabled: bool): bool {.importc, cdecl.}
# proc ecs_log_last_error*(): cint {.importc, cdecl.}
# proc ecs_app_run*(world: ecs_world_t; desc: ptr ecs_app_desc_t): cint {.importc, cdecl.}
# proc ecs_app_run_frame*(world: ecs_world_t;
#     desc: ptr ecs_app_desc_t): cint {.importc, cdecl.}
# proc ecs_app_set_run_action*(callback: ecs_app_run_action_t): cint {.importc, cdecl.}
# proc ecs_app_set_frame_action*(callback: ecs_app_frame_action_t): cint {.importc, cdecl.}

# var ecs_http_request_received_count*: int64

# var ecs_http_request_invalid_count*: int64

# var ecs_http_request_handled_ok_count*: int64

# var ecs_http_request_handled_error_count*: int64

# var ecs_http_request_not_handled_count*: int64

# var ecs_http_request_preflight_count*: int64

# var ecs_http_send_ok_count*: int64

# var ecs_http_send_error_count*: int64

# var ecs_http_busy_count*: int64

# proc ecs_http_server_init*(desc: ptr ecs_http_server_desc_t): ptr ecs_http_server_t {.importc, cdecl.}
# proc ecs_http_server_fini*(server: ptr ecs_http_server_t) {.importc, cdecl.}
# proc ecs_http_server_start*(server: ptr ecs_http_server_t): cint {.importc, cdecl.}
# proc ecs_http_server_dequeue*(server: ptr ecs_http_server_t;
#     delta_time: cfloat) {.importc, cdecl.}
# proc ecs_http_server_stop*(server: ptr ecs_http_server_t) {.importc, cdecl.}
# proc ecs_http_server_http_request*(srv: ptr ecs_http_server_t; req: cstring;
#                                   len: ecs_size_t;
#                                       reply_out: ptr ecs_http_reply_t): cint {.importc, cdecl.}
# proc ecs_http_server_request*(srv: ptr ecs_http_server_t; `method`: cstring;
#                              req: cstring; body: cstring;
#                              reply_out: ptr ecs_http_reply_t): cint {.importc, cdecl.}
# proc ecs_http_server_ctx*(srv: ptr ecs_http_server_t): pointer {.importc, cdecl.}
# proc ecs_http_get_header*(req: ptr ecs_http_request_t;
#     name: cstring): cstring {.importc, cdecl.}
# proc ecs_http_get_param*(req: ptr ecs_http_request_t;
#     name: cstring): cstring {.importc, cdecl.}

# proc ecs_rest_server_init*(world: ecs_world_t;
#     desc: ptr ecs_http_server_desc_t): ptr ecs_http_server_t {.importc, cdecl.}
# proc ecs_rest_server_fini*(srv: ptr ecs_http_server_t) {.importc, cdecl.}
# proc FlecsRestImport*(world: ecs_world_t) {.importc, cdecl.}


# proc ecs_set_timeout*(world: ecs_world_t; tick_source: ecs_entity_t;
#                      timeout: cfloat): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_timeout*(world: ecs_world_t;
#     tick_source: ecs_entity_t): cfloat {.importc, cdecl.}
# proc ecs_set_interval*(world: ecs_world_t; tick_source: ecs_entity_t;
#                       interval: cfloat): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_interval*(world: ecs_world_t;
#     tick_source: ecs_entity_t): cfloat {.importc, cdecl.}
# proc ecs_start_timer*(world: ecs_world_t; tick_source: ecs_entity_t) {.importc, cdecl.}
# proc ecs_stop_timer*(world: ecs_world_t; tick_source: ecs_entity_t) {.importc, cdecl.}
# proc ecs_reset_timer*(world: ecs_world_t; tick_source: ecs_entity_t) {.importc, cdecl.}
# proc ecs_randomize_timers*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_set_rate*(world: ecs_world_t; tick_source: ecs_entity_t; rate: int32;
#                   source: ecs_entity_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_set_tick_source*(world: ecs_world_t; system: ecs_entity_t;
#                          tick_source: ecs_entity_t) {.importc, cdecl.}
# proc FlecsTimerImport*(world: ecs_world_t) {.importc, cdecl.}


# proc ecs_pipeline_init*(world: ecs_world_t;
#     desc: ptr ecs_pipeline_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_set_pipeline*(world: ecs_world_t; pipeline: ecs_entity_t) {.importc, cdecl.}
# proc ecs_get_pipeline*(world: ecs_world_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_progress*(world: ecs_world_t; delta_time: cfloat): bool {.importc, cdecl.}
# proc ecs_set_time_scale*(world: ecs_world_t; scale: cfloat) {.importc, cdecl.}
# proc ecs_reset_clock*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_run_pipeline*(world: ecs_world_t; pipeline: ecs_entity_t;
#                       delta_time: cfloat) {.importc, cdecl.}
# proc ecs_set_threads*(world: ecs_world_t; threads: int32) {.importc, cdecl.}
# proc ecs_set_task_threads*(world: ecs_world_t; task_threads: int32) {.importc, cdecl.}
# proc ecs_using_task_threads*(world: ecs_world_t): bool {.importc, cdecl.}
# proc FlecsPipelineImport*(world: ecs_world_t) {.importc, cdecl.}


# proc ecs_system_init*(world: ecs_world_t;
#     desc: ptr ecs_system_desc_t): ecs_entity_t {.importc, cdecl.}


# proc ecs_system_get*(world: ecs_world_t;
#     system: ecs_entity_t): ptr ecs_system_t {.importc, cdecl.}
# proc ecs_run*(world: ecs_world_t; system: ecs_entity_t; delta_time: cfloat;
#              param: pointer): ecs_entity_t {.importc, cdecl.}
# proc ecs_run_worker*(world: ecs_world_t; system: ecs_entity_t;
#                     stage_current: int32; stage_count: int32;
#                     delta_time: cfloat; param: pointer): ecs_entity_t {.importc, cdecl.}
# proc FlecsSystemImport*(world: ecs_world_t) {.importc, cdecl.}

# proc ecs_world_stats_get*(world: ecs_world_t;
#     stats: ptr ecs_world_stats_t) {.importc, cdecl.}
# proc ecs_world_stats_reduce*(dst: ptr ecs_world_stats_t;
#     src: ptr ecs_world_stats_t) {.importc, cdecl.}
# proc ecs_world_stats_reduce_last*(stats: ptr ecs_world_stats_t;
#                                  old: ptr ecs_world_stats_t;
#                                      count: int32) {.importc, cdecl.}
# proc ecs_world_stats_repeat_last*(stats: ptr ecs_world_stats_t) {.importc, cdecl.}
# proc ecs_world_stats_copy_last*(dst: ptr ecs_world_stats_t;
#                                src: ptr ecs_world_stats_t) {.importc, cdecl.}
# proc ecs_world_stats_log*(world: ecs_world_t;
#     stats: ptr ecs_world_stats_t) {.importc, cdecl.}
# proc ecs_query_stats_get*(world: ecs_world_t; query: ptr ecs_query_t;
#                          stats: ptr ecs_query_stats_t) {.importc, cdecl.}
# proc ecs_query_cache_stats_reduce*(dst: ptr ecs_query_stats_t;
#                                   src: ptr ecs_query_stats_t) {.importc, cdecl.}
# proc ecs_query_cache_stats_reduce_last*(stats: ptr ecs_query_stats_t;
#                                        old: ptr ecs_query_stats_t;
#                                            count: int32) {.importc, cdecl.}
# proc ecs_query_cache_stats_repeat_last*(stats: ptr ecs_query_stats_t) {.importc, cdecl.}
# proc ecs_query_cache_stats_copy_last*(dst: ptr ecs_query_stats_t;
#                                      src: ptr ecs_query_stats_t) {.importc, cdecl.}
# proc ecs_system_stats_get*(world: ecs_world_t; system: ecs_entity_t;
#                           stats: ptr ecs_system_stats_t): bool {.importc, cdecl.}
# proc ecs_system_stats_reduce*(dst: ptr ecs_system_stats_t;
#                              src: ptr ecs_system_stats_t) {.importc, cdecl.}
# proc ecs_system_stats_reduce_last*(stats: ptr ecs_system_stats_t;
#                                   old: ptr ecs_system_stats_t;
#                                       count: int32) {.importc, cdecl.}
# proc ecs_system_stats_repeat_last*(stats: ptr ecs_system_stats_t) {.importc, cdecl.}
# proc ecs_system_stats_copy_last*(dst: ptr ecs_system_stats_t;
#                                 src: ptr ecs_system_stats_t) {.importc, cdecl.}
# proc ecs_pipeline_stats_get*(world: ecs_world_t; pipeline: ecs_entity_t;
#                             stats: ptr ecs_pipeline_stats_t): bool {.importc, cdecl.}
# proc ecs_pipeline_stats_fini*(stats: ptr ecs_pipeline_stats_t) {.importc, cdecl.}
# proc ecs_pipeline_stats_reduce*(dst: ptr ecs_pipeline_stats_t;
#                                src: ptr ecs_pipeline_stats_t) {.importc, cdecl.}
# proc ecs_pipeline_stats_reduce_last*(stats: ptr ecs_pipeline_stats_t;
#                                     old: ptr ecs_pipeline_stats_t;
#                                         count: int32) {.importc, cdecl.}
# proc ecs_pipeline_stats_repeat_last*(stats: ptr ecs_pipeline_stats_t) {.importc, cdecl.}
# proc ecs_pipeline_stats_copy_last*(dst: ptr ecs_pipeline_stats_t;
#                                   src: ptr ecs_pipeline_stats_t) {.importc, cdecl.}
# proc ecs_metric_reduce*(dst: ptr ecs_metric_t; src: ptr ecs_metric_t; t_dst: int32;
#                        t_src: int32) {.importc, cdecl.}
# proc ecs_metric_reduce_last*(m: ptr ecs_metric_t; t: int32;
#     count: int32) {.importc, cdecl.}
# proc ecs_metric_copy*(m: ptr ecs_metric_t; dst: int32; src: int32) {.importc, cdecl.}
# var FLECS_IDFlecsStatsID*: ecs_entity_t

# var FLECS_IDEcsWorldStatsID*: ecs_entity_t

# var FLECS_IDEcsWorldSummaryID*: ecs_entity_t

# var FLECS_IDEcsSystemStatsID*: ecs_entity_t

# var FLECS_IDEcsPipelineStatsID*: ecs_entity_t

# var EcsPeriod1s*: ecs_entity_t

# var EcsPeriod1m*: ecs_entity_t

# var EcsPeriod1h*: ecs_entity_t

# var EcsPeriod1d*: ecs_entity_t

# var EcsPeriod1w*: ecs_entity_t


# proc FlecsStatsImport*(world: ecs_world_t) {.importc, cdecl.}
# var FLECS_IDFlecsMetricsID*: ecs_entity_t

# var
#   EcsMetric*: ecs_entity_t
#   FLECS_IDEcsMetricID*: ecs_entity_t

# var
#   EcsCounter*: ecs_entity_t
#   FLECS_IDEcsCounterID*: ecs_entity_t

# var
#   EcsCounterIncrement*: ecs_entity_t
#   FLECS_IDEcsCounterIncrementID*: ecs_entity_t

# var
#   EcsCounterId*: ecs_entity_t
#   FLECS_IDEcsCounterIdID*: ecs_entity_t

# var
#   EcsGauge*: ecs_entity_t
#   FLECS_IDEcsGaugeID*: ecs_entity_t

# var
#   EcsMetricInstance*: ecs_entity_t
#   FLECS_IDEcsMetricInstanceID*: ecs_entity_t

# var FLECS_IDEcsMetricValueID*: ecs_entity_t

# var FLECS_IDEcsMetricSourceID*: ecs_entity_t


# proc ecs_metric_init*(world: ecs_world_t;
#     desc: ptr ecs_metric_desc_t): ecs_entity_t {.importc, cdecl.}
# proc FlecsMetricsImport*(world: ecs_world_t) {.importc, cdecl.}
# var FLECS_IDFlecsAlertsID*: ecs_entity_t

# var FLECS_IDEcsAlertID*: ecs_entity_t

# var FLECS_IDEcsAlertInstanceID*: ecs_entity_t

# var FLECS_IDEcsAlertsActiveID*: ecs_entity_t

# var FLECS_IDEcsAlertTimeoutID*: ecs_entity_t

# var
#   EcsAlertInfo*: ecs_entity_t
#   FLECS_IDEcsAlertInfoID*: ecs_entity_t

# var
#   EcsAlertWarning*: ecs_entity_t
#   FLECS_IDEcsAlertWarningID*: ecs_entity_t

# var
#   EcsAlertError*: ecs_entity_t
#   FLECS_IDEcsAlertErrorID*: ecs_entity_t

# var
#   EcsAlertCritical*: ecs_entity_t
#   FLECS_IDEcsAlertCriticalID*: ecs_entity_t


# proc ecs_alert_init*(world: ecs_world_t;
#     desc: ptr ecs_alert_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_get_alert_count*(world: ecs_world_t; entity: ecs_entity_t;
#                          alert: ecs_entity_t): int32 {.importc, cdecl.}
# proc ecs_get_alert*(world: ecs_world_t; entity: ecs_entity_t;
#     alert: ecs_entity_t): ecs_entity_t {.importc, cdecl.}
# proc FlecsAlertsImport*(world: ecs_world_t) {.importc, cdecl.}

# proc ecs_ptr_from_json*(world: ecs_world_t; `type`: ecs_entity_t; `ptr`: pointer;
#                        json: cstring; desc: ptr ecs_from_json_desc_t): cstring {.importc, cdecl.}
# proc ecs_entity_from_json*(world: ecs_world_t; entity: ecs_entity_t;
#                           json: cstring;
#                               desc: ptr ecs_from_json_desc_t): cstring {.importc, cdecl.}
# proc ecs_world_from_json*(world: ecs_world_t; json: cstring;
#                          desc: ptr ecs_from_json_desc_t): cstring {.importc, cdecl.}
# proc ecs_world_from_json_file*(world: ecs_world_t; filename: cstring;
#                               desc: ptr ecs_from_json_desc_t): cstring {.importc, cdecl.}
# proc ecs_array_to_json*(world: ecs_world_t; `type`: ecs_entity_t; data: pointer;
#                        count: int32): cstring {.importc, cdecl.}
# proc ecs_array_to_json_buf*(world: ecs_world_t; `type`: ecs_entity_t;
#                            data: pointer; count: int32;
#                                buf_out: ptr ecs_strbuf_t): cint {.importc, cdecl.}
# proc ecs_ptr_to_json*(world: ecs_world_t; `type`: ecs_entity_t;
#     data: pointer): cstring {.importc, cdecl.}
# proc ecs_ptr_to_json_buf*(world: ecs_world_t; `type`: ecs_entity_t; data: pointer;
#                          buf_out: ptr ecs_strbuf_t): cint {.importc, cdecl.}
# proc ecs_type_info_to_json*(world: ecs_world_t;
#     `type`: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_type_info_to_json_buf*(world: ecs_world_t; `type`: ecs_entity_t;
#                                buf_out: ptr ecs_strbuf_t): cint {.importc, cdecl.}

# proc ecs_entity_to_json*(world: ecs_world_t; entity: ecs_entity_t;
#                         desc: ptr ecs_entity_to_json_desc_t): cstring {.importc, cdecl.}
# proc ecs_entity_to_json_buf*(world: ecs_world_t; entity: ecs_entity_t;
#                             buf_out: ptr ecs_strbuf_t;
#                             desc: ptr ecs_entity_to_json_desc_t): cint {.importc, cdecl.}

# proc ecs_iter_to_json*(iter: ptr ecs_iter_t;
#     desc: ptr ecs_iter_to_json_desc_t): cstring {.importc, cdecl.}
# proc ecs_iter_to_json_buf*(iter: ptr ecs_iter_t; buf_out: ptr ecs_strbuf_t;
#                           desc: ptr ecs_iter_to_json_desc_t): cint {.importc, cdecl.}

# proc ecs_world_to_json*(world: ecs_world_t;
#     desc: ecs_world_to_json_desc_t): cstring {.importc, cdecl.}
# proc ecs_world_to_json_buf*(world: ecs_world_t; buf_out: ptr ecs_strbuf_t;
#                            desc: ecs_world_to_json_desc_t): cint {.importc, cdecl.}
# var EcsUnitPrefixes*: ecs_entity_t

# var EcsYocto*: ecs_entity_t

# var EcsZepto*: ecs_entity_t

# var EcsAtto*: ecs_entity_t

# var EcsFemto*: ecs_entity_t

# var EcsPico*: ecs_entity_t

# var EcsNano*: ecs_entity_t

# var EcsMicro*: ecs_entity_t

# var EcsMilli*: ecs_entity_t

# var EcsCenti*: ecs_entity_t

# var EcsDeci*: ecs_entity_t

# var EcsDeca*: ecs_entity_t

# var EcsHecto*: ecs_entity_t

# var EcsKilo*: ecs_entity_t

# var EcsMega*: ecs_entity_t

# var EcsGiga*: ecs_entity_t

# var EcsTera*: ecs_entity_t

# var EcsPeta*: ecs_entity_t

# var EcsExa*: ecs_entity_t

# var EcsZetta*: ecs_entity_t

# var EcsYotta*: ecs_entity_t

# var EcsKibi*: ecs_entity_t

# var EcsMebi*: ecs_entity_t

# var EcsGibi*: ecs_entity_t

# var EcsTebi*: ecs_entity_t

# var EcsPebi*: ecs_entity_t

# var EcsExbi*: ecs_entity_t

# var EcsZebi*: ecs_entity_t

# var EcsYobi*: ecs_entity_t

# var EcsDuration*: ecs_entity_t

# var EcsPicoSeconds*: ecs_entity_t

# var EcsNanoSeconds*: ecs_entity_t

# var EcsMicroSeconds*: ecs_entity_t

# var EcsMilliSeconds*: ecs_entity_t

# var EcsSeconds*: ecs_entity_t

# var EcsMinutes*: ecs_entity_t

# var EcsHours*: ecs_entity_t

# var EcsDays*: ecs_entity_t

# var EcsTime*: ecs_entity_t

# var EcsDate*: ecs_entity_t

# var EcsMass*: ecs_entity_t

# var EcsGrams*: ecs_entity_t

# var EcsKiloGrams*: ecs_entity_t

# var EcsElectricCurrent*: ecs_entity_t

# var EcsAmpere*: ecs_entity_t

# var EcsAmount*: ecs_entity_t

# var EcsMole*: ecs_entity_t

# var EcsLuminousIntensity*: ecs_entity_t

# var EcsCandela*: ecs_entity_t

# var EcsForce*: ecs_entity_t

# var EcsNewton*: ecs_entity_t

# var EcsLength*: ecs_entity_t

# var EcsMeters*: ecs_entity_t

# var EcsPicoMeters*: ecs_entity_t

# var EcsNanoMeters*: ecs_entity_t

# var EcsMicroMeters*: ecs_entity_t

# var EcsMilliMeters*: ecs_entity_t

# var EcsCentiMeters*: ecs_entity_t

# var EcsKiloMeters*: ecs_entity_t

# var EcsMiles*: ecs_entity_t

# var EcsPixels*: ecs_entity_t

# var EcsPressure*: ecs_entity_t

# var EcsPascal*: ecs_entity_t

# var EcsBar*: ecs_entity_t

# var EcsSpeed*: ecs_entity_t

# var EcsMetersPerSecond*: ecs_entity_t

# var EcsKiloMetersPerSecond*: ecs_entity_t

# var EcsKiloMetersPerHour*: ecs_entity_t

# var EcsMilesPerHour*: ecs_entity_t

# var EcsTemperature*: ecs_entity_t

# var EcsKelvin*: ecs_entity_t

# var EcsCelsius*: ecs_entity_t

# var EcsFahrenheit*: ecs_entity_t

# var EcsData*: ecs_entity_t

# var EcsBits*: ecs_entity_t

# var EcsKiloBits*: ecs_entity_t

# var EcsMegaBits*: ecs_entity_t

# var EcsGigaBits*: ecs_entity_t

# var EcsBytes*: ecs_entity_t

# var EcsKiloBytes*: ecs_entity_t

# var EcsMegaBytes*: ecs_entity_t

# var EcsGigaBytes*: ecs_entity_t

# var EcsKibiBytes*: ecs_entity_t

# var EcsMebiBytes*: ecs_entity_t

# var EcsGibiBytes*: ecs_entity_t

# var EcsDataRate*: ecs_entity_t

# var EcsBitsPerSecond*: ecs_entity_t

# var EcsKiloBitsPerSecond*: ecs_entity_t

# var EcsMegaBitsPerSecond*: ecs_entity_t

# var EcsGigaBitsPerSecond*: ecs_entity_t

# var EcsBytesPerSecond*: ecs_entity_t

# var EcsKiloBytesPerSecond*: ecs_entity_t

# var EcsMegaBytesPerSecond*: ecs_entity_t

# var EcsGigaBytesPerSecond*: ecs_entity_t

# var EcsAngle*: ecs_entity_t

# var EcsRadians*: ecs_entity_t

# var EcsDegrees*: ecs_entity_t

# var EcsFrequency*: ecs_entity_t

# var EcsHertz*: ecs_entity_t

# var EcsKiloHertz*: ecs_entity_t

# var EcsMegaHertz*: ecs_entity_t

# var EcsGigaHertz*: ecs_entity_t

# var EcsUri*: ecs_entity_t

# var EcsUriHyperlink*: ecs_entity_t

# var EcsUriImage*: ecs_entity_t

# var EcsUriFile*: ecs_entity_t

# var EcsColor*: ecs_entity_t

# var EcsColorRgb*: ecs_entity_t

# var EcsColorHsl*: ecs_entity_t

# var EcsColorCss*: ecs_entity_t

# var EcsAcceleration*: ecs_entity_t

# var EcsPercentage*: ecs_entity_t

# var EcsBel*: ecs_entity_t

# var EcsDeciBel*: ecs_entity_t

# proc FlecsUnitsImport*(world: ecs_world_t) {.importc, cdecl.}
# var FLECS_IDEcsScriptID*: ecs_entity_t

# var
#   EcsScriptTemplate*: ecs_entity_t
#   FLECS_IDEcsScriptTemplateID*: ecs_entity_t

# var FLECS_IDEcsScriptConstVarID*: ecs_entity_t

# var FLECS_IDEcsScriptFunctionID*: ecs_entity_t

# var FLECS_IDEcsScriptMethodID*: ecs_entity_t


# proc ecs_script_parse*(world: ecs_world_t; name: cstring; code: cstring;
#                       desc: ptr ecs_script_eval_desc_t): ptr ecs_script_t {.importc, cdecl.}
# proc ecs_script_eval*(script: ptr ecs_script_t;
#     desc: ptr ecs_script_eval_desc_t): cint {.importc, cdecl.}
# proc ecs_script_free*(script: ptr ecs_script_t) {.importc, cdecl.}
# proc ecs_script_run*(world: ecs_world_t; name: cstring;
#     code: cstring): cint {.importc, cdecl.}
# proc ecs_script_run_file*(world: ecs_world_t;
#     filename: cstring): cint {.importc, cdecl.}
# proc ecs_script_runtime_new*(): ptr ecs_script_runtime_t {.importc, cdecl.}
# proc ecs_script_runtime_free*(runtime: ptr ecs_script_runtime_t) {.importc, cdecl.}
# proc ecs_script_ast_to_buf*(script: ptr ecs_script_t; buf: ptr ecs_strbuf_t;
#                            colors: bool): cint {.importc, cdecl.}
# proc ecs_script_ast_to_str*(script: ptr ecs_script_t;
#     colors: bool): cstring {.importc, cdecl.}

# proc ecs_script_init*(world: ecs_world_t;
#     desc: ptr ecs_script_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_script_update*(world: ecs_world_t; script: ecs_entity_t;
#                        instance: ecs_entity_t; code: cstring): cint {.importc, cdecl.}
# proc ecs_script_clear*(world: ecs_world_t; script: ecs_entity_t;
#                       instance: ecs_entity_t) {.importc, cdecl.}
# proc ecs_script_vars_init*(world: ecs_world_t): ptr ecs_script_vars_t {.importc, cdecl.}
# proc ecs_script_vars_fini*(vars: ptr ecs_script_vars_t) {.importc, cdecl.}
# proc ecs_script_vars_push*(parent: ptr ecs_script_vars_t): ptr ecs_script_vars_t {.importc, cdecl.}
# proc ecs_script_vars_pop*(vars: ptr ecs_script_vars_t): ptr ecs_script_vars_t {.importc, cdecl.}
# proc ecs_script_vars_declare*(vars: ptr ecs_script_vars_t;
#     name: cstring): ptr ecs_script_var_t {.importc, cdecl.}
# proc ecs_script_vars_define_id*(vars: ptr ecs_script_vars_t; name: cstring;
#                                `type`: ecs_entity_t): ptr ecs_script_var_t {.importc, cdecl.}
# proc ecs_script_vars_lookup*(vars: ptr ecs_script_vars_t;
#     name: cstring): ptr ecs_script_var_t {.importc, cdecl.}
# proc ecs_script_vars_from_sp*(vars: ptr ecs_script_vars_t;
#     sp: int32): ptr ecs_script_var_t {.importc, cdecl.}
# proc ecs_script_vars_print*(vars: ptr ecs_script_vars_t) {.importc, cdecl.}
# proc ecs_script_vars_set_size*(vars: ptr ecs_script_vars_t;
#     count: int32) {.importc, cdecl.}
# proc ecs_script_vars_from_iter*(it: ptr ecs_iter_t; vars: ptr ecs_script_vars_t;
#                                offset: cint) {.importc, cdecl.}

# proc ecs_expr_run*(world: ecs_world_t; `ptr`: cstring; value: ptr ecs_value_t;
#                   desc: ptr ecs_expr_eval_desc_t): cstring {.importc, cdecl.}
# proc ecs_expr_parse*(world: ecs_world_t; expr: cstring;
#                     desc: ptr ecs_expr_eval_desc_t): ptr ecs_script_t {.importc, cdecl.}
# proc ecs_expr_eval*(script: ptr ecs_script_t; value: ptr ecs_value_t;
#                    desc: ptr ecs_expr_eval_desc_t): cint {.importc, cdecl.}
# proc ecs_script_string_interpolate*(world: ecs_world_t; str: cstring;
#                                    vars: ptr ecs_script_vars_t): cstring {.importc, cdecl.}

# proc ecs_const_var_init*(world: ecs_world_t;
#     desc: ptr ecs_const_var_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_function_init*(world: ecs_world_t;
#     desc: ptr ecs_function_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_method_init*(world: ecs_world_t;
#     desc: ptr ecs_function_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_ptr_to_expr*(world: ecs_world_t; `type`: ecs_entity_t;
#     data: pointer): cstring {.importc, cdecl.}
# proc ecs_ptr_to_expr_buf*(world: ecs_world_t; `type`: ecs_entity_t; data: pointer;
#                          buf: ptr ecs_strbuf_t): cint {.importc, cdecl.}
# proc ecs_ptr_to_str*(world: ecs_world_t; `type`: ecs_entity_t;
#     data: pointer): cstring {.importc, cdecl.}
# proc ecs_ptr_to_str_buf*(world: ecs_world_t; `type`: ecs_entity_t; data: pointer;
#                         buf: ptr ecs_strbuf_t): cint {.importc, cdecl.}

# proc FlecsScriptImport*(world: ecs_world_t) {.importc, cdecl.}

# proc ecs_doc_set_uuid*(world: ecs_world_t; entity: ecs_entity_t;
#     uuid: cstring) {.importc, cdecl.}
# proc ecs_doc_set_name*(world: ecs_world_t; entity: ecs_entity_t;
#     name: cstring) {.importc, cdecl.}
# proc ecs_doc_set_brief*(world: ecs_world_t; entity: ecs_entity_t;
#                        description: cstring) {.importc, cdecl.}
# proc ecs_doc_set_detail*(world: ecs_world_t; entity: ecs_entity_t;
#                         description: cstring) {.importc, cdecl.}
# proc ecs_doc_set_link*(world: ecs_world_t; entity: ecs_entity_t;
#     link: cstring) {.importc, cdecl.}
# proc ecs_doc_set_color*(world: ecs_world_t; entity: ecs_entity_t;
#     color: cstring) {.importc, cdecl.}
# proc ecs_doc_get_uuid*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_doc_get_name*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_doc_get_brief*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_doc_get_detail*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_doc_get_link*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc ecs_doc_get_color*(world: ecs_world_t;
#     entity: ecs_entity_t): cstring {.importc, cdecl.}
# proc FlecsDocImport*(world: ecs_world_t) {.importc, cdecl.}

# const
#   EcsTypeKindLast* = EcsOpaqueType

# const
#   EcsPrimitiveKindLast* = EcsId

# const
#   EcsMetaTypeOpKindLast* = EcsOpId

# proc ecs_meta_cursor*(world: ecs_world_t; `type`: ecs_entity_t;
#     `ptr`: pointer): ecs_meta_cursor_t {.importc, cdecl.}
# proc ecs_meta_get_ptr*(cursor: ptr ecs_meta_cursor_t): pointer {.importc, cdecl.}
# proc ecs_meta_next*(cursor: ptr ecs_meta_cursor_t): cint {.importc, cdecl.}
# proc ecs_meta_elem*(cursor: ptr ecs_meta_cursor_t; elem: int32): cint {.importc, cdecl.}
# proc ecs_meta_member*(cursor: ptr ecs_meta_cursor_t;
#     name: cstring): cint {.importc, cdecl.}
# proc ecs_meta_dotmember*(cursor: ptr ecs_meta_cursor_t;
#     name: cstring): cint {.importc, cdecl.}
# proc ecs_meta_push*(cursor: ptr ecs_meta_cursor_t): cint {.importc, cdecl.}
# proc ecs_meta_pop*(cursor: ptr ecs_meta_cursor_t): cint {.importc, cdecl.}
# proc ecs_meta_is_collection*(cursor: ptr ecs_meta_cursor_t): bool {.importc, cdecl.}
# proc ecs_meta_get_type*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_meta_get_unit*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_meta_get_member*(cursor: ptr ecs_meta_cursor_t): cstring {.importc, cdecl.}
# proc ecs_meta_get_member_id*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_meta_set_bool*(cursor: ptr ecs_meta_cursor_t;
#     value: bool): cint {.importc, cdecl.}
# proc ecs_meta_set_char*(cursor: ptr ecs_meta_cursor_t;
#     value: char): cint {.importc, cdecl.}
# proc ecs_meta_set_int*(cursor: ptr ecs_meta_cursor_t;
#     value: int64): cint {.importc, cdecl.}
# proc ecs_meta_set_uint*(cursor: ptr ecs_meta_cursor_t;
#     value: uint64): cint {.importc, cdecl.}
# proc ecs_meta_set_float*(cursor: ptr ecs_meta_cursor_t;
#     value: cdouble): cint {.importc, cdecl.}
# proc ecs_meta_set_string*(cursor: ptr ecs_meta_cursor_t;
#     value: cstring): cint {.importc, cdecl.}
# proc ecs_meta_set_string_literal*(cursor: ptr ecs_meta_cursor_t;
#     value: cstring): cint {.importc, cdecl.}
# proc ecs_meta_set_entity*(cursor: ptr ecs_meta_cursor_t;
#     value: ecs_entity_t): cint {.importc, cdecl.}
# proc ecs_meta_set_id*(cursor: ptr ecs_meta_cursor_t;
#     value: ecs_id_t): cint {.importc, cdecl.}
# proc ecs_meta_set_null*(cursor: ptr ecs_meta_cursor_t): cint {.importc, cdecl.}
# proc ecs_meta_set_value*(cursor: ptr ecs_meta_cursor_t;
#     value: ptr ecs_value_t): cint {.importc, cdecl.}
# proc ecs_meta_get_bool*(cursor: ptr ecs_meta_cursor_t): bool {.importc, cdecl.}
# proc ecs_meta_get_char*(cursor: ptr ecs_meta_cursor_t): char {.importc, cdecl.}
# proc ecs_meta_get_int*(cursor: ptr ecs_meta_cursor_t): int64 {.importc, cdecl.}
# proc ecs_meta_get_uint*(cursor: ptr ecs_meta_cursor_t): uint64 {.importc, cdecl.}
# proc ecs_meta_get_float*(cursor: ptr ecs_meta_cursor_t): cdouble {.importc, cdecl.}
# proc ecs_meta_get_string*(cursor: ptr ecs_meta_cursor_t): cstring {.importc, cdecl.}
# proc ecs_meta_get_entity*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_meta_get_id*(cursor: ptr ecs_meta_cursor_t): ecs_id_t {.importc, cdecl.}
# proc ecs_meta_ptr_to_float*(type_kind: ecs_primitive_kind_t;
#     `ptr`: pointer): cdouble {.importc, cdecl.}

# proc ecs_primitive_init*(world: ecs_world_t;
#     desc: ptr ecs_primitive_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_enum_init*(world: ecs_world_t; desc: ptr ecs_enum_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_bitmask_init*(world: ecs_world_t;
#     desc: ptr ecs_bitmask_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_array_init*(world: ecs_world_t;
#     desc: ptr ecs_array_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_vector_init*(world: ecs_world_t;
#     desc: ptr ecs_vector_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_struct_init*(world: ecs_world_t;
#     desc: ptr ecs_struct_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_opaque_init*(world: ecs_world_t;
#     desc: ptr ecs_opaque_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_unit_init*(world: ecs_world_t; desc: ptr ecs_unit_desc_t): ecs_entity_t {.importc, cdecl.}

# proc ecs_unit_prefix_init*(world: ecs_world_t;
#     desc: ptr ecs_unit_prefix_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_quantity_init*(world: ecs_world_t;
#     desc: ptr ecs_entity_desc_t): ecs_entity_t {.importc, cdecl.}
# proc FlecsMetaImport*(world: ecs_world_t) {.importc, cdecl.}
# proc ecs_meta_from_desc*(world: ecs_world_t; component: ecs_entity_t;
#                         kind: ecs_type_kind_t; desc: cstring): cint {.importc, cdecl.}
# proc ecs_set_os_api_impl*() {.importc, cdecl.}
# proc ecs_import*(world: ecs_world_t; module: ecs_module_action_t;
#                 module_name: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_import_c*(world: ecs_world_t; module: ecs_module_action_t;
#                   module_name_c: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_import_from_library*(world: ecs_world_t; library_name: cstring;
#                              module_name: cstring): ecs_entity_t {.importc, cdecl.}
# proc ecs_module_init*(world: ecs_world_t; c_name: cstring;
#                      desc: ptr ecs_component_desc_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_cpp_get_type_name*(type_name: cstring; func_name: cstring; len: csize_t;
#                            front_len: csize_t): cstring {.importc, cdecl.}
# proc ecs_cpp_get_symbol_name*(symbol_name: cstring; type_name: cstring;
#     len: csize_t): cstring {.importc, cdecl.}
# proc ecs_cpp_get_constant_name*(constant_name: cstring; func_name: cstring;
#                                len: csize_t;
#                                    back_len: csize_t): cstring {.importc, cdecl.}
# proc ecs_cpp_trim_module*(world: ecs_world_t;
#     type_name: cstring): cstring {.importc, cdecl.}
# proc ecs_cpp_component_register*(world: ecs_world_t; id: ecs_entity_t;
#                                 ids_index: int32; name: cstring;
#                                 cpp_name: cstring; cpp_symbol: cstring;
#                                 size: csize_t; alignment: csize_t;
#                                 is_component: bool; explicit_registration: bool;
#                                 registered_out: ptr bool;
#                                     existing_out: ptr bool): ecs_entity_t {.importc, cdecl.}
# proc ecs_cpp_enum_init*(world: ecs_world_t; id: ecs_entity_t;
#                        underlying_type: ecs_entity_t) {.importc, cdecl.}
# proc ecs_cpp_enum_constant_register*(world: ecs_world_t; parent: ecs_entity_t;
#                                     id: ecs_entity_t; name: cstring;
#                                         value: pointer;
#                                     value_type: ecs_entity_t;
#                                         value_size: csize_t): ecs_entity_t {.importc, cdecl.}
# proc ecs_cpp_last_member*(world: ecs_world_t;
#     `type`: ecs_entity_t): ptr ecs_member_t {.importc, cdecl.}

# type
#   World* = ecs_world_t
#   Entity* = ecs_entity_t
#   EntityDesc* = ecs_entity_desc_t
#   ComponentDesc* = ecs_component_desc_t

# proc init*(): World {.importc: "ecs_init", cdecl.}
# proc new*(w: World): Entity {.importc: "ecs_new", cdecl.}
# proc delete*(w: World; e: Entity) {.importc: "ecs_delete", cdecl.}
# proc isAlive*(w: World; e: Entity): bool {.importc: "ecs_is_alive", cdecl.}

type
  ecs_bool_t* = bool
  ecs_char_t* = char
  ecs_byte_t* = cuchar
  ecs_u8_t* = uint8
  ecs_u16_t* = uint16
  ecs_u32_t* = uint32
  ecs_u64_t* = uint64
  ecs_uptr_t* = uint
  ecs_i8_t* = int8
  ecs_i16_t* = int16
  ecs_i32_t* = int32
  ecs_i64_t* = int64
  ecs_iptr_t* = int
  ecs_f32_t* = cfloat
  ecs_f64_t* = cdouble
  ecs_string_t* = cstring
  ecs_flags8_t* = uint8
  ecs_flags16_t* = uint16
  ecs_flags32_t* = uint32
  ecs_flags64_t* = uint64
  ecs_size_t* = int32
  ecs_id_t* = uint64
  ecs_entity_t* = ecs_id_t

  ecs_world_t* = object
  ecs_iter_t* = object

  ecs_type_kind_t* = enum
    EcsPrimitiveType, EcsBitmaskType, EcsEnumType, EcsStructType, EcsArrayType,
    EcsVectorType, EcsOpaqueType
  EcsType* {.bycopy.} = object
    kind*: ecs_type_kind_t
    existing*: bool
    partial*: bool

  ecs_primitive_kind_t* = enum
    Ecsbool = 1, EcsChar, EcsByte, EcsU8, EcsU16, EcsU32, EcsU64, EcsI8, EcsI16, EcsI32,
    EcsI64, EcsF32, EcsF64, EcsUPtr, EcsIPtr, EcsString, EcsEntity, EcsId
  EcsPrimitive* {.bycopy.} = object
    kind*: ecs_primitive_kind_t

  EcsMember* {.bycopy.} = object
    typeInfo*: ecs_entity_t
    count*: int32
    unit*: ecs_entity_t
    offset*: int32
    use_offset*: bool

  ecs_member_value_range_t* {.bycopy.} = object
    min*: cdouble
    max*: cdouble

  EcsMemberRanges* {.bycopy.} = object
    value*: ecs_member_value_range_t
    warning*: ecs_member_value_range_t
    error*: ecs_member_value_range_t

  ecs_member_t* {.bycopy.} = object
    name*: cstring
    typeInfo*: ecs_entity_t
    count*: int32
    offset*: int32
    unit*: ecs_entity_t
    use_offset*: bool
    range*: ecs_member_value_range_t
    error_range*: ecs_member_value_range_t
    warning_range*: ecs_member_value_range_t
    size*: ecs_size_t
    member*: ecs_entity_t

  ecs_vec_t* {.bycopy.} = object
    arr*: pointer
    count*: int32
    size*: int32

  EcsStruct* {.bycopy.} = object
    members*: ecs_vec_t

  ecs_enum_constant_t* {.bycopy.} = object
    name*: cstring
    value*: int64
    value_unsigned*: uint64
    constant*: ecs_entity_t

  ecs_map_data_t* = uint64
  ecs_map_key_t* = ecs_map_data_t
  ecs_map_val_t* = ecs_map_data_t

  ecs_bucket_entry_t* {.bycopy.} = object
    key*: ecs_map_key_t
    value*: ecs_map_val_t
    next*: ptr ecs_bucket_entry_t

  ecs_bucket_t* {.bycopy.} = object
    first*: ptr ecs_bucket_entry_t

  ecs_block_allocator_block_t* {.bycopy.} = object
    memory*: pointer
    next*: ptr ecs_block_allocator_block_t

  ecs_block_allocator_chunk_header_t* {.bycopy.} = object
    next*: ptr ecs_block_allocator_chunk_header_t

  ecs_block_allocator_t* {.bycopy.} = object
    head*: ptr ecs_block_allocator_chunk_header_t
    blockHead*: ptr ecs_block_allocator_block_t
    chunk_size*: int32
    data_size*: int32
    chunks_per_block*: int32
    block_size*: int32

  ecs_sparse_t* {.bycopy.} = object
    dense*: ecs_vec_t
    pages*: ecs_vec_t
    size*: ecs_size_t
    count*: int32
    max_id*: uint64
    allocator*: ptr ecs_allocator_t
    page_allocator*: ptr ecs_block_allocator_t

  ecs_allocator_t* {.bycopy.} = object
    chunks*: ecs_block_allocator_t
    size*: ecs_sparse_t

  ecs_map_t* {.bycopy.} = object
    buckets*: ptr ecs_bucket_t
    bucket_count*: int32
    count* {.bitsize: 26.}: uint
    bucket_shift* {.bitsize: 6.}: uint
    allocator*: ptr ecs_allocator_t

  EcsEnum* {.bycopy.} = object
    underlying_type*: ecs_entity_t
    constants*: ecs_map_t

  ecs_bitmask_constant_t* {.bycopy.} = object
    name*: cstring
    value*: ecs_flags64_t
    unused*: int64
    constant*: ecs_entity_t

  EcsBitmask* {.bycopy.} = object
    constants*: ecs_map_t

  EcsArray* {.bycopy.} = object
    typeInfo*: ecs_entity_t
    count*: int32

  EcsVector* {.bycopy.} = object
    typeInfo*: ecs_entity_t

  ecs_serializer_t* {.bycopy.} = object
    value*: proc (ser: ptr ecs_serializer_t; typeInfo: ecs_entity_t;
        value: pointer): cint
    member*: proc (ser: ptr ecs_serializer_t; member: cstring): cint
    world*: ptr ecs_world_t
    ctx*: pointer


const
  EcsTypeKindLast* = EcsOpaqueType

const
  EcsPrimitiveKindLast* = EcsId

type
  ecs_meta_serialize_t* = proc (ser: ptr ecs_serializer_t; src: pointer): cint
  ecs_meta_serialize_member_t* = proc (ser: ptr ecs_serializer_t; src: pointer;
                                    name: cstring): cint {.cdecl.}
  ecs_meta_serialize_element_t* = proc (ser: ptr ecs_serializer_t; src: pointer;
                                     elem: csize_t): cint {.cdecl.}
  EcsOpaque* {.bycopy.} = object
    as_type*: ecs_entity_t
    serialize*: ecs_meta_serialize_t
    serialize_member*: ecs_meta_serialize_member_t
    serialize_element*: ecs_meta_serialize_element_t
    assign_bool*: proc (dst: pointer; value: bool)
    assign_char*: proc (dst: pointer; value: char)
    assign_int*: proc (dst: pointer; value: int64)
    assign_uint*: proc (dst: pointer; value: uint64)
    assign_float*: proc (dst: pointer; value: cdouble)
    assign_string*: proc (dst: pointer; value: cstring)
    assign_entity*: proc (dst: pointer; world: ptr ecs_world_t;
        entity: ecs_entity_t)
    assign_id*: proc (dst: pointer; world: ptr ecs_world_t; id: ecs_id_t)
    assign_null*: proc (dst: pointer)
    clear*: proc (dst: pointer)
    ensure_element*: proc (dst: pointer; elem: csize_t): pointer
    ensure_member*: proc (dst: pointer; member: cstring): pointer
    count*: proc (dst: pointer): csize_t
    resize*: proc (dst: pointer; count: csize_t)

  ecs_unit_translation_t* {.bycopy.} = object
    factor*: int32
    power*: int32

  EcsUnit* {.bycopy.} = object
    symbol*: cstring
    prefix*: ecs_entity_t
    base*: ecs_entity_t
    over*: ecs_entity_t
    translation*: ecs_unit_translation_t

  EcsUnitPrefix* {.bycopy.} = object
    symbol*: cstring
    translation*: ecs_unit_translation_t

  ecs_compare_action_t* = proc(p1, p2: pointer): int {.cdecl.}
  ecs_hash_value_action_t* = proc(p: pointer): uint64 {.cdecl.}

  ecs_hashmap_t* {.bycopy.} = object
    hash*: ecs_hash_value_action_t
    compare*: ecs_compare_action_t
    key_size*: ecs_size_t
    value_size*: ecs_size_t
    hashmap_allocator*: ptr ecs_block_allocator_t
    bucket_allocator*: ecs_block_allocator_t
    impl*: ecs_map_t

  ecs_meta_type_op_kind_t* = enum
    EcsOpArray, EcsOpVector, EcsOpOpaque, EcsOpPush, EcsOpPop, EcsOpScope,
      EcsOpEnum,
    EcsOpBitmask, EcsOpPrimitive, EcsOpbool, EcsOpChar, EcsOpByte, EcsOpU8,
      EcsOpU16,
    EcsOpU32, EcsOpU64, EcsOpI8, EcsOpI16, EcsOpI32, EcsOpI64, EcsOpF32,
      EcsOpF64,
    EcsOpUPtr, EcsOpIPtr, EcsOpString, EcsOpEntity, EcsOpId
  ecs_meta_type_op_t* {.bycopy.} = object
    kind*: ecs_meta_type_op_kind_t
    offset*: ecs_size_t
    count*: int32
    name*: cstring
    op_count*: int32
    size*: ecs_size_t
    typeInfo*: ecs_entity_t
    member_index*: int32
    members*: ptr ecs_hashmap_t

  EcsTypeSerializer* {.bycopy.} = object
    ops*: ecs_vec_t


const
  EcsMetaTypeOpKindLast* = EcsOpId

type
  EcsComponent* {.bycopy.} = object
    size*: ecs_size_t
    alignment*: ecs_size_t

  ecs_meta_scope_t* {.bycopy.} = object
    typeInfo*: ecs_entity_t
    ops*: ptr ecs_meta_type_op_t
    op_count*: int32
    op_cur*: int32
    elem_cur*: int32
    prev_depth*: int32
    `ptr`*: pointer
    comp*: ptr EcsComponent
    opaque*: ptr EcsOpaque
    vector*: ptr ecs_vec_t
    members*: ptr ecs_hashmap_t
    is_collection*: bool
    is_inline_array*: bool
    is_empty_scope*: bool

  ecs_meta_cursor_t* {.bycopy.} = object
    world*: ptr ecs_world_t
    scope*: array[(32), ecs_meta_scope_t]
    depth*: int32
    valid*: bool
    is_primitive_scope*: bool
    lookup_action*: proc (a1: ptr ecs_world_t; a2: cstring;
        a3: pointer): ecs_entity_t
    lookup_ctx*: pointer

  ecs_value_t* {.bycopy.} = object
    typeInfo*: ecs_entity_t
    `ptr`*: pointer

  ecs_entity_desc_t* {.bycopy.} = object
    canary: int32
    id*: ecs_entity_t
    parent*: ecs_entity_t
    name*: cstring
    sep*: cstring
    root_sep*: cstring
    symbol*: cstring
    use_low_id*: bool
    `add`*: ptr ecs_id_t
    `set`*: ptr ecs_value_t
    add_expr*: cstring


proc ecs_meta_cursor*(world: ptr ecs_world_t; typeInfo: ecs_entity_t;
    `ptr`: pointer): ecs_meta_cursor_t {.importc.}
proc ecs_meta_get_ptr*(cursor: ptr ecs_meta_cursor_t): pointer {.importc.}
proc ecs_meta_next*(cursor: ptr ecs_meta_cursor_t): cint {.importc.}
proc ecs_meta_elem*(cursor: ptr ecs_meta_cursor_t;
    elem: int32): cint {.importc.}
proc ecs_meta_member*(cursor: ptr ecs_meta_cursor_t;
    name: cstring): cint {.importc.}
proc ecs_meta_dotmember*(cursor: ptr ecs_meta_cursor_t;
    name: cstring): cint {.importc.}
proc ecs_meta_push*(cursor: ptr ecs_meta_cursor_t): cint {.importc.}
proc ecs_meta_pop*(cursor: ptr ecs_meta_cursor_t): cint {.importc.}
proc ecs_meta_is_collection*(cursor: ptr ecs_meta_cursor_t): bool {.importc.}
proc ecs_meta_get_type*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc.}
proc ecs_meta_get_unit*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc.}
proc ecs_meta_get_member*(cursor: ptr ecs_meta_cursor_t): cstring {.importc.}
proc ecs_meta_get_member_id*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc.}
proc ecs_meta_set_bool*(cursor: ptr ecs_meta_cursor_t;
    value: bool): cint {.importc.}
proc ecs_meta_set_char*(cursor: ptr ecs_meta_cursor_t;
    value: char): cint {.importc.}
proc ecs_meta_set_int*(cursor: ptr ecs_meta_cursor_t;
    value: int64): cint {.importc.}
proc ecs_meta_set_uint*(cursor: ptr ecs_meta_cursor_t;
    value: uint64): cint {.importc.}
proc ecs_meta_set_float*(cursor: ptr ecs_meta_cursor_t;
    value: cdouble): cint {.importc.}
proc ecs_meta_set_string*(cursor: ptr ecs_meta_cursor_t;
    value: cstring): cint {.importc.}
proc ecs_meta_set_string_literal*(cursor: ptr ecs_meta_cursor_t;
    value: cstring): cint {.importc.}
proc ecs_meta_set_entity*(cursor: ptr ecs_meta_cursor_t;
    value: ecs_entity_t): cint {.importc.}
proc ecs_meta_set_id*(cursor: ptr ecs_meta_cursor_t;
    value: ecs_id_t): cint {.importc.}
proc ecs_meta_set_null*(cursor: ptr ecs_meta_cursor_t): cint {.importc.}
proc ecs_meta_set_value*(cursor: ptr ecs_meta_cursor_t;
    value: ptr ecs_value_t): cint {.importc.}
proc ecs_meta_get_bool*(cursor: ptr ecs_meta_cursor_t): bool {.importc.}
proc ecs_meta_get_char*(cursor: ptr ecs_meta_cursor_t): char {.importc.}
proc ecs_meta_get_int*(cursor: ptr ecs_meta_cursor_t): int64 {.importc.}
proc ecs_meta_get_uint*(cursor: ptr ecs_meta_cursor_t): uint64 {.importc.}
proc ecs_meta_get_float*(cursor: ptr ecs_meta_cursor_t): cdouble {.importc.}
proc ecs_meta_get_string*(cursor: ptr ecs_meta_cursor_t): cstring {.importc.}
proc ecs_meta_get_entity*(cursor: ptr ecs_meta_cursor_t): ecs_entity_t {.importc.}
proc ecs_meta_get_id*(cursor: ptr ecs_meta_cursor_t): ecs_id_t {.importc.}
proc ecs_meta_ptr_to_float*(type_kind: ecs_primitive_kind_t;
    `ptr`: pointer): cdouble {.importc.}
type
  ecs_primitive_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    kind*: ecs_primitive_kind_t


proc ecs_primitive_init*(world: ptr ecs_world_t;
    desc: ptr ecs_primitive_desc_t): ecs_entity_t {.importc.}
type
  ecs_enum_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    constants*: array[(32), ecs_enum_constant_t]
    underlying_type*: ecs_entity_t


proc ecs_enum_init*(world: ptr ecs_world_t;
    desc: ptr ecs_enum_desc_t): ecs_entity_t {.importc.}
type
  ecs_bitmask_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    constants*: array[(32), ecs_bitmask_constant_t]


proc ecs_bitmask_init*(world: ptr ecs_world_t;
    desc: ptr ecs_bitmask_desc_t): ecs_entity_t {.importc.}
type
  ecs_array_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    typeInfo*: ecs_entity_t
    count*: int32


proc ecs_array_init*(world: ptr ecs_world_t;
    desc: ptr ecs_array_desc_t): ecs_entity_t {.importc.}
type
  ecs_vector_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    typeInfo*: ecs_entity_t


proc ecs_vector_init*(world: ptr ecs_world_t;
    desc: ptr ecs_vector_desc_t): ecs_entity_t {.importc.}
type
  ecs_struct_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    members*: array[(32), ecs_member_t]


proc ecs_struct_init*(world: ptr ecs_world_t;
    desc: ptr ecs_struct_desc_t): ecs_entity_t {.importc.}
type
  ecs_opaque_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    typeInfo*: EcsOpaque


proc ecs_opaque_init*(world: ptr ecs_world_t;
    desc: ptr ecs_opaque_desc_t): ecs_entity_t {.importc.}
type
  ecs_unit_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    symbol*: cstring
    quantity*: ecs_entity_t
    base*: ecs_entity_t
    over*: ecs_entity_t
    translation*: ecs_unit_translation_t
    prefix*: ecs_entity_t


proc ecs_unit_init*(world: ptr ecs_world_t;
    desc: ptr ecs_unit_desc_t): ecs_entity_t {.importc.}
type
  ecs_unit_prefix_desc_t* {.bycopy.} = object
    entity*: ecs_entity_t
    symbol*: cstring
    translation*: ecs_unit_translation_t

  ecs_module_action_t* = proc(world: ptr ecs_world_t) {.cdecl.}

  ecs_ctx_free_t* = proc(ctx: pointer) {.cdecl.}
  ecs_xtor_t* = proc(p: pointer; count: int32;
      type_info: ptr ecs_type_info_t) {.cdecl.}
  ecs_copy_t* = proc(dstp, srcp: pointer; count: int32;
      type_info: ptr ecs_type_info_t) {.cdecl.}
  ecs_move_t* = proc(dstp, srcp: pointer; count: int32;
      type_info: ptr ecs_type_info_t) {.cdecl.}
  ecs_cmp_t* = proc(aptr, bptr: pointer; count: int32;
      type_info: ptr ecs_type_info_t): int {.cdecl.}
  ecs_equals_t* = proc(aptr, bptr: pointer; count: int32;
      type_info: ptr ecs_type_info_t): bool {.cdecl.}
  ecs_iter_action_t* = proc(it: ptr ecs_iter_t) {.cdecl.}

  ecs_type_hooks_t* {.bycopy.} = object
    ctor*: ecs_xtor_t
    dtor*: ecs_xtor_t
    copy*: ecs_copy_t
    move*: ecs_move_t

    copy_ctor*: ecs_copy_t
    move_ctor*: ecs_move_t
    ctor_move_dtor*: ecs_move_t
    move_dtor*: ecs_move_t
    `cmp`*: ecs_cmp_t
    equals*: ecs_equals_t
    flags*: ecs_flags32_t
    on_add*: ecs_iter_action_t
    on_set*: ecs_iter_action_t
    on_remove*: ecs_iter_action_t
    ctx*: pointer
    binding_ctx*: pointer
    lifecycle_ctx*: pointer
    ctx_free*: ecs_ctx_free_t
    binding_ctx_free*: ecs_ctx_free_t
    lifecycle_ctx_free*: ecs_ctx_free_t

  ecs_type_info_t* {.bycopy.} = object
    size*: ecs_size_t
    alignment*: ecs_size_t
    hooks*: ecs_type_hooks_t
    component*: ecs_entity_t
    name*: cstring

  ecs_component_desc_t* {.bycopy.} = object
    canary: int32
    entity*: ecs_entity_t
    typeInfo*: ecs_type_info_t


proc ecs_unit_prefix_init*(world: ptr ecs_world_t;
    desc: ptr ecs_unit_prefix_desc_t): ecs_entity_t {.importc.}
proc ecs_quantity_init*(world: ptr ecs_world_t;
    desc: ptr ecs_entity_desc_t): ecs_entity_t {.importc.}
proc FlecsMetaImport*(world: ptr ecs_world_t) {.importc.}
proc ecs_meta_from_desc*(world: ptr ecs_world_t; component: ecs_entity_t;
                        kind: ecs_type_kind_t; desc: cstring): cint {.importc, discardable.}
proc ecs_set_os_api_impl*() {.importc.}
proc ecs_import*(world: ptr ecs_world_t; module: ecs_module_action_t;
                module_name: cstring): ecs_entity_t {.importc.}
proc ecs_import_c*(world: ptr ecs_world_t; module: ecs_module_action_t;
                  module_name_c: cstring): ecs_entity_t {.importc.}
proc ecs_import_from_library*(world: ptr ecs_world_t; library_name: cstring;
                             module_name: cstring): ecs_entity_t {.importc.}
proc ecs_module_init*(world: ptr ecs_world_t; c_name: cstring;
                     desc: ptr ecs_component_desc_t): ecs_entity_t {.importc.}
proc ecs_cpp_get_type_name*(type_name: cstring; func_name: cstring; len: csize_t;
                           front_len: csize_t): cstring {.importc.}
proc ecs_cpp_get_symbol_name*(symbol_name: cstring; type_name: cstring;
    len: csize_t): cstring {.importc.}
proc ecs_cpp_get_constant_name*(constant_name: cstring; func_name: cstring;
                               len: csize_t;
                                   back_len: csize_t): cstring {.importc.}
proc ecs_cpp_trim_module*(world: ptr ecs_world_t;
    type_name: cstring): cstring {.importc.}
proc ecs_cpp_component_register*(world: ptr ecs_world_t; id: ecs_entity_t;
                                ids_index: int32; name: cstring;
                                cpp_name: cstring; cpp_symbol: cstring;
                                size: csize_t; alignment: csize_t;
                                is_component: bool; explicit_registration: bool;
                                registered_out: ptr bool;
                                    existing_out: ptr bool): ecs_entity_t {.importc.}
proc ecs_cpp_enum_init*(world: ptr ecs_world_t; id: ecs_entity_t;
                       underlying_type: ecs_entity_t) {.importc.}
proc ecs_cpp_enum_constant_register*(world: ptr ecs_world_t; parent: ecs_entity_t;
                                    id: ecs_entity_t; name: cstring;
                                        value: pointer;
                                    value_type: ecs_entity_t;
                                        value_size: csize_t): ecs_entity_t {.importc.}
proc ecs_cpp_last_member*(world: ptr ecs_world_t;
    typeInfo: ecs_entity_t): ptr ecs_member_t {.importc.}

type
  ecs_time_t* {.bycopy.} = object
    sec*: uint32
    nanosec*: uint32

  ecs_os_thread_t* = uint
  ecs_os_cond_t* = uint
  ecs_os_mutex_t* = uint
  ecs_os_dl_t* = uint
  ecs_os_sock_t* = uint
  ecs_os_thread_id_t* = uint64
  ecs_os_proc_t* = proc () {.cdecl.}
  ecs_os_api_init_t* = proc () {.cdecl.}
  ecs_os_api_fini_t* = proc () {.cdecl.}
  ecs_os_api_malloc_t* = proc (size: ecs_size_t): pointer {.cdecl.}
  ecs_os_api_free_t* = proc (`ptr`: pointer) {.cdecl.}
  ecs_os_api_realloc_t* = proc (`ptr`: pointer;
      size: ecs_size_t): pointer {.cdecl.}
  ecs_os_api_calloc_t* = proc (size: ecs_size_t): pointer {.cdecl.}
  ecs_os_api_strdup_t* = proc (str: cstring): cstring {.cdecl.}
  ecs_os_thread_callback_t* = proc (a1: pointer): pointer {.cdecl.}
  ecs_os_api_thread_new_t* = proc (callback: ecs_os_thread_callback_t;
      param: pointer): ecs_os_thread_t {.cdecl.}
  ecs_os_api_thread_join_t* = proc (thread: ecs_os_thread_t): pointer {.cdecl.}
  ecs_os_api_thread_self_t* = proc (): ecs_os_thread_id_t {.cdecl.}
  ecs_os_api_task_new_t* = proc (callback: ecs_os_thread_callback_t;
      param: pointer): ecs_os_thread_t {.cdecl.}
  ecs_os_api_task_join_t* = proc (thread: ecs_os_thread_t): pointer {.cdecl.}
  ecs_os_api_ainc_t* = proc (value: ptr int32): int32 {.cdecl.}
  ecs_os_api_lainc_t* = proc (value: ptr int64): int64 {.cdecl.}
  ecs_os_api_mutex_new_t* = proc (): ecs_os_mutex_t {.cdecl.}
  ecs_os_api_mutex_lock_t* = proc (mutex: ecs_os_mutex_t) {.cdecl.}
  ecs_os_api_mutex_unlock_t* = proc (mutex: ecs_os_mutex_t) {.cdecl.}
  ecs_os_api_mutex_free_t* = proc (mutex: ecs_os_mutex_t) {.cdecl.}
  ecs_os_api_cond_new_t* = proc (): ecs_os_cond_t {.cdecl.}
  ecs_os_api_cond_free_t* = proc (cond: ecs_os_cond_t) {.cdecl.}
  ecs_os_api_cond_signal_t* = proc (cond: ecs_os_cond_t) {.cdecl.}
  ecs_os_api_cond_broadcast_t* = proc (cond: ecs_os_cond_t) {.cdecl.}
  ecs_os_api_cond_wait_t* = proc (cond: ecs_os_cond_t;
      mutex: ecs_os_mutex_t) {.cdecl.}
  ecs_os_api_sleep_t* = proc (sec: int32; nanosec: int32) {.cdecl.}
  ecs_os_api_enable_high_timer_resolution_t * = proc (enable: bool) {.cdecl.}
  ecs_os_api_get_time_t* = proc (time_out: ptr ecs_time_t) {.cdecl.}
  ecs_os_api_now_t* = proc (): uint64 {.cdecl.}
  ecs_os_api_log_t* = proc (level: int32; file: cstring; line: int32;
      msg: cstring) {.cdecl.}
  ecs_os_api_abort_t* = proc () {.cdecl.}
  ecs_os_api_dlopen_t* = proc (libname: cstring): ecs_os_dl_t {.cdecl.}
  ecs_os_api_dlproc_t* = proc (lib: ecs_os_dl_t;
      procname: cstring): ecs_os_proc_t {.cdecl.}
  ecs_os_api_dlclose_t* = proc (lib: ecs_os_dl_t) {.cdecl.}
  ecs_os_api_module_to_path_t* = proc (module_id: cstring): cstring {.cdecl.}
  ecs_os_api_perf_trace_t* = proc (filename: cstring; line: csize_t;
      name: cstring) {.cdecl.}
  ecs_os_api_t* {.bycopy.} = object
    init*: ecs_os_api_init_t
    fini*: ecs_os_api_fini_t
    malloc*: ecs_os_api_malloc_t
    realloc*: ecs_os_api_realloc_t
    calloc*: ecs_os_api_calloc_t
    free*: ecs_os_api_free_t
    strdup*: ecs_os_api_strdup_t
    thread_new*: ecs_os_api_thread_new_t
    thread_join*: ecs_os_api_thread_join_t
    thread_self*: ecs_os_api_thread_self_t
    task_new*: ecs_os_api_thread_new_t
    task_join*: ecs_os_api_thread_join_t
    ainc*: ecs_os_api_ainc_t
    adec*: ecs_os_api_ainc_t
    lainc*: ecs_os_api_lainc_t
    ladec*: ecs_os_api_lainc_t
    mutex_new*: ecs_os_api_mutex_new_t
    mutex_free*: ecs_os_api_mutex_free_t
    mutex_lock*: ecs_os_api_mutex_lock_t
    mutex_unlock*: ecs_os_api_mutex_lock_t
    cond_new*: ecs_os_api_cond_new_t
    cond_free*: ecs_os_api_cond_free_t
    cond_signal*: ecs_os_api_cond_signal_t
    cond_broadcast*: ecs_os_api_cond_broadcast_t
    cond_wait*: ecs_os_api_cond_wait_t
    sleep*: ecs_os_api_sleep_t
    now*: ecs_os_api_now_t
    get_time*: ecs_os_api_get_time_t
    log*: ecs_os_api_log_t
    abort*: ecs_os_api_abort_t
    dlopen*: ecs_os_api_dlopen_t
    dlproc*: ecs_os_api_dlproc_t
    dlclose*: ecs_os_api_dlclose_t
    module_to_dl*: ecs_os_api_module_to_path_t
    module_to_etc*: ecs_os_api_module_to_path_t
    perf_trace_push*: ecs_os_api_perf_trace_t
    perf_trace_pop*: ecs_os_api_perf_trace_t
    log_level*: int32
    log_indent*: int32
    log_last_error*: int32
    log_last_timestamp*: int64
    flags*: ecs_flags32_t
    log_out*: ptr FILE

var ecs_os_api* = ecs_os_api_t(

)

proc ecs_init*(): ptr ecs_world_t {.importc, cdecl.}
proc ecs_entity_init*(world: ptr ecs_world_t;
    desc: ptr ecs_entity_desc_t): ecs_entity_t {.importc, cdecl.}
proc ecs_component_init*(world: ptr ecs_world_t;
    desc: ptr ecs_component_desc_t): ecs_entity_t {.importc, cdecl.}
proc ecs_is_valid*(world: ptr ecs_world_t; e: ecs_entity_t): bool {.importc, cdecl.}
proc ecs_get_name*(world: ptr ecs_world_t;
    entity: ecs_entity_t): cstring {.importc, cdecl.}
proc ecs_get_symbol*(world: ptr ecs_world_t;
    entity: ecs_entity_t): cstring {.importc, cdecl.}
proc ecs_new*(world: ptr ecs_world_t): ecs_entity_t {.importc, cdecl.}
proc ecs_set_id*(world: ptr ecs_world_t; entity: ecs_entity_t; id: ecs_id_t;
                size: csize_t; `ptr`: pointer) {.importc, cdecl.}
proc ecs_get_id*(world: ptr ecs_world_t; entity: ecs_entity_t;
    id: ecs_id_t): pointer {.importc, cdecl.}
proc ecs_id_from_str*(world: ptr ecs_world_t;
    expr: cstring): ecs_id_t {.importc, cdecl.}

proc ecs_os_init*() {.importc, cdecl.}
proc ecs_os_fini*() {.importc, cdecl.}

type
  World* = ecs_world_t
  Entity* = ecs_entity_t
  EntityDesc* = ecs_entity_desc_t
  ComponentDesc* = ecs_component_desc_t

macro defineComponent(world, id: untyped): untyped =
  var
    componentName = $`id`
    componentId = ident("FLECS_ID" & componentName & "ID")

  result = quote do:
    var
      desc: ComponentDesc
      eDesc: EntityDesc

    eDesc.id = `componentId`
    eDesc.useLowId = true
    eDesc.name = `componentName`
    eDesc.symbol = `componentName`
    desc.entity = ecs_entity_init(`world`, addr(eDesc))
    desc.typeInfo.size = int32(sizeof(`id`))
    desc.typeInfo.alignment = int32(alignof(`id`))
    `componentId` = ecs_component_init(`world`, addr(desc))
    assert(`componentId` != 0)
  echo repr result

template component*(world, id: untyped): untyped =
  var
    `FLECS_ID id ID` {.inject, exportc: "$1_".}: Entity
    `id` {.inject.}: Entity
  defineComponent(world, `id`)

macro join(prefix, infix, suffix: untyped): untyped =
  newIdentNode($`prefix` & $`infix` & $`suffix`)

template metaComponent*(world, name: untyped): untyped =
  defineComponent(world, name)
  ecs_meta_from_desc(world, id(name), `name Kind`, `name Desc`)

macro struct*(name, body: untyped): untyped =
  let
    typeName = newIdentNode($`name`)
    entityName = newIdentNode("FLECS_ID" & $`name` & "ID_")
    descIdent = newIdentNode("FLECS__" & $`name` & "_desc")
    kindIdent = newIdentNode("FLECS__" & $`name` & "_kind")

  var
    i = 0
    desc = "{"
    recList = nnkRecList.newTree()
  for child in body.children:
    if child.kind == nnkCall:
      let
        memberName = $child[0]
        memberType = $child[1][0]

      recList.add(
        nnkIdentDefs.newTree(
          newIdentNode(memberName),
          newIdentNode(memberType),
          newEmptyNode()
        )
      )

      desc &= memberType & " " & memberName & ";"
      if i < body.len() - 1:
        desc &= " "
      else:
        desc &= "}"

      inc(i)

  result = newNimNode(nnkStmtList)
  add(result, nnkStmtList.newTree(
    nnkVarSection.newTree(
      nnkIdentDefs.newTree(
        nnkPragmaExpr.newTree(
          newIdentNode("FLECS_ID" & $name & "ID"),
          nnkPragma.newTree(
            newIdentNode("zState"),
            nnkExprColonExpr.newTree(
              newIdentNode("exportc"),
              newLit("$1_")
    )
  )
    ),
    newIdentNode("Entity"),
    newEmptyNode()
  ),
      nnkIdentDefs.newTree(
        nnkPragmaExpr.newTree(
          newIdentNode($name & "Desc"),
          nnkPragma.newTree(
            newIdentNode("zState"),
            nnkExprColonExpr.newTree(
              newIdentNode("exportc"),
              newLit("FLECS__" & $name & "_desc")
    )
  )
    ),
    newIdentNode("cstring"),
    newLit(desc)
  ),
      nnkIdentDefs.newTree(
        nnkPragmaExpr.newTree(
          newIdentNode($name & "Kind"),
          nnkPragma.newTree(
            newIdentNode("zState"),
            nnkExprColonExpr.newTree(
              newIdentNode("exportc"),
              newLit("FLECS__" & $name & "_kind")
    )
  )
    ),
    newIdentNode("ecs_type_kind_t"),
    newIdentNode("EcsStructType")
  )
    )
  )
  )
  # result.add quote do:
  #   var
  #     `entityName` {.zState, exportc: "foo_".}: Entity
  #     `descIdent` {.zState.}: cstring = `desc`
  #     `kindIdent` {.zState.}: ecs_type_kind_t = EcsStructType

  result.add(
    nnkTypeSection.newTree(
      nnkTypeDef.newTree(
        nnkPostfix.newTree(
          newIdentNode("*"),
          typeName,
    ),
    newEmptyNode(),
    nnkObjectTy.newTree(
      newEmptyNode(),
      newEmptyNode(),
      recList
    )
  )
    )
  )
  echo repr result

macro defineEntity*(world, id: untyped; args: varargs[untyped]): untyped =
  let
    entityName = $`id`
    entityId = ident("FLECS_ID" & entityName & "ID")

  var addExpr = ""
  for i, arg in args:
    addExpr = if i > 0: join([addExpr, $arg], ", ") else: $arg

  result = quote do:
    var desc: EntityDesc

    desc.id = `id`
    desc.addExpr = cstring(`addExpr`)
    `id` = ecs_entity_init(`world`, addr(desc))
    `entityId` = `id`
    assert(`id` != 0)

template entity*(world, id: untyped; args: varargs[untyped]): untyped =
  var
    `FLECS_ID id ID` {.inject, exportc: "$1_".}: Entity
    `id` {.inject.}: Entity
  defineEntity(world, `id`, args)

macro get*(world, entity, T: untyped): untyped =
  let
    id = ident("FLECS_ID" & $`T` & "ID")
  result = quote do:
    cast[ptr `T`](ecs_get_id(`world`, `entity`, `id`))

template set*(world, entity, id, name, val: untyped): untyped =
  var vVal = val
  ecs_set_id(world, entity, id, uint(sizeof(name)), addr(vVal))

template id*(n: untyped): untyped =
  `FLECS_ID n ID`

when defined(host):
  {.passC: "-g -O0".}
  {.passC: "-DFLECS_NO_CPP".}
  {.compile: "./flecs/distr/flecs.c".}

when isMainModule:
  echo sizeof(EcsIdentifier)
