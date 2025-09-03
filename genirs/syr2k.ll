; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

%struct.ident_t = type { i32, i32, i32, i32, ptr }

@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

%struct.ompi_predefined_communicator_t = type opaque
@ompi_mpi_comm_world = external global %struct.ompi_predefined_communicator_t, align 1

define void @testFunc(i32 %0, i32 %1, float %2, float %3, ptr %4, ptr %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, ptr %11, ptr %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17, ptr %18, ptr %19, i64 %20, i64 %21, i64 %22, i64 %23, i64 %24) {
  %structArg141 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg139 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg137 = alloca { ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr }, align 8
  %.reloaded133 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded134 = alloca float, align 4
  %.reloaded135 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded136 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded89 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded90 = alloca float, align 4
  %.reloaded91 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded92 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded47 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded48 = alloca float, align 4
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded9 = alloca float, align 4
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %18, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, ptr %19, 1
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 2
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %21, 3, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %23, 4, 0
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %22, 3, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, i64 %24, 4, 1
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %11, 0
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, ptr %12, 1
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %13, 2
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %14, 3, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %16, 4, 0
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %15, 3, 1
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, i64 %17, 4, 1
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %4, 0
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, ptr %5, 1
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, i64 %6, 2
  %43 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, i64 %7, 3, 0
  %44 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %43, i64 %9, 4, 0
  %45 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, i64 %8, 3, 1
  %46 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, i64 %10, 4, 1
  %47 = call i32 @MPI_Init(ptr null, ptr null)
  %48 = alloca i32, align 4
  %49 = call i32 @MPI_Comm_rank(ptr noundef @ompi_mpi_comm_world, ptr noundef %48)
  %50 = load i32, ptr %48, align 4
  %51 = alloca i32, align 4
  %52 = call i32 @MPI_Comm_size(ptr noundef @ompi_mpi_comm_world, ptr noundef %51)
  %53 = load i32, ptr %51, align 4
  %54 = srem i32 0, %53
  %55 = icmp eq i32 %50, %54
  br i1 %55, label %56, label %57

56:                                               ; preds = %25
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %46, ptr %.reloaded, align 8
  store float %3, ptr %.reloaded9, align 4
  br label %omp_parallel

omp_parallel:                                     ; preds = %56
  %gep_.reloaded = getelementptr { ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded9 = getelementptr { ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded9, ptr %gep_.reloaded9, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par, ptr %structArg)
  br label %omp.par.outlined.exit

omp.par.outlined.exit:                            ; preds = %omp_parallel
  br label %omp.par.exit.split

omp.par.exit.split:                               ; preds = %omp.par.outlined.exit
  br label %57

57:                                               ; preds = %omp.par.exit.split, %25
  %58 = srem i32 1, %53
  %59 = icmp eq i32 %50, %58
  br i1 %59, label %60, label %61

60:                                               ; preds = %57
  %omp_global_thread_num10 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %46, ptr %.reloaded47, align 8
  store float %3, ptr %.reloaded48, align 4
  br label %omp_parallel138

omp_parallel138:                                  ; preds = %60
  %gep_.reloaded47 = getelementptr { ptr, ptr }, ptr %structArg137, i32 0, i32 0
  store ptr %.reloaded47, ptr %gep_.reloaded47, align 8
  %gep_.reloaded48 = getelementptr { ptr, ptr }, ptr %structArg137, i32 0, i32 1
  store ptr %.reloaded48, ptr %gep_.reloaded48, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.1, ptr %structArg137)
  br label %omp.par.outlined.exit46

omp.par.outlined.exit46:                          ; preds = %omp_parallel138
  br label %omp.par.exit.split45

omp.par.exit.split45:                             ; preds = %omp.par.outlined.exit46
  br label %61

61:                                               ; preds = %omp.par.exit.split45, %57
  %62 = srem i32 2, %53
  %63 = icmp eq i32 %50, %62
  br i1 %63, label %64, label %65

64:                                               ; preds = %61
  %omp_global_thread_num49 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, ptr %.reloaded89, align 8
  store float %2, ptr %.reloaded90, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %.reloaded91, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %46, ptr %.reloaded92, align 8
  br label %omp_parallel140

omp_parallel140:                                  ; preds = %64
  %gep_.reloaded89 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg139, i32 0, i32 0
  store ptr %.reloaded89, ptr %gep_.reloaded89, align 8
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg139, i32 0, i32 1
  store ptr %.reloaded90, ptr %gep_.reloaded90, align 8
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg139, i32 0, i32 2
  store ptr %.reloaded91, ptr %gep_.reloaded91, align 8
  %gep_.reloaded92 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg139, i32 0, i32 3
  store ptr %.reloaded92, ptr %gep_.reloaded92, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.2, ptr %structArg139)
  br label %omp.par.outlined.exit88

omp.par.outlined.exit88:                          ; preds = %omp_parallel140
  br label %omp.par.exit.split87

omp.par.exit.split87:                             ; preds = %omp.par.outlined.exit88
  br label %65

65:                                               ; preds = %omp.par.exit.split87, %61
  %66 = srem i32 3, %53
  %67 = icmp eq i32 %50, %66
  br i1 %67, label %68, label %69

68:                                               ; preds = %65
  %omp_global_thread_num93 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, ptr %.reloaded133, align 8
  store float %2, ptr %.reloaded134, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %.reloaded135, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %46, ptr %.reloaded136, align 8
  br label %omp_parallel142

omp_parallel142:                                  ; preds = %68
  %gep_.reloaded133 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg141, i32 0, i32 0
  store ptr %.reloaded133, ptr %gep_.reloaded133, align 8
  %gep_.reloaded134 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg141, i32 0, i32 1
  store ptr %.reloaded134, ptr %gep_.reloaded134, align 8
  %gep_.reloaded135 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg141, i32 0, i32 2
  store ptr %.reloaded135, ptr %gep_.reloaded135, align 8
  %gep_.reloaded136 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg141, i32 0, i32 3
  store ptr %.reloaded136, ptr %gep_.reloaded136, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.3, ptr %structArg141)
  br label %omp.par.outlined.exit132

omp.par.outlined.exit132:                         ; preds = %omp_parallel142
  br label %omp.par.exit.split131

omp.par.exit.split131:                            ; preds = %omp.par.outlined.exit132
  br label %69

69:                                               ; preds = %omp.par.exit.split131, %65
  %70 = call i32 @MPI_Barrier(ptr noundef @ompi_mpi_comm_world)
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.3(ptr noalias %tid.addr94, ptr noalias %zero.addr95, ptr %0) #0 {
omp.par.entry96:
  %gep_.reloaded133 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded133 = load ptr, ptr %gep_.reloaded133, align 8
  %gep_.reloaded134 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded134 = load ptr, ptr %gep_.reloaded134, align 8
  %gep_.reloaded135 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded135 = load ptr, ptr %gep_.reloaded135, align 8
  %gep_.reloaded136 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded136 = load ptr, ptr %gep_.reloaded136, align 8
  %p.lastiter125 = alloca i32, align 4
  %p.lowerbound126 = alloca i64, align 8
  %p.upperbound127 = alloca i64, align 8
  %p.stride128 = alloca i64, align 8
  %tid.addr.local99 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr94, align 4
  store i32 %1, ptr %tid.addr.local99, align 4
  %tid100 = load i32, ptr %tid.addr.local99, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded133, align 8
  %3 = load float, ptr %loadgep_.reloaded134, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded135, align 8
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded136, align 8
  br label %omp.region.after_alloca106

omp.region.after_alloca106:                       ; preds = %omp.par.entry96
  br label %omp.region.after_alloca103

omp.region.after_alloca103:                       ; preds = %omp.region.after_alloca106
  br label %omp.par.region97

omp.par.region97:                                 ; preds = %omp.region.after_alloca103
  br label %omp.par.region105

omp.par.region105:                                ; preds = %omp.par.region97
  br label %omp_loop.preheader107

omp_loop.preheader107:                            ; preds = %omp.par.region105
  store i64 0, ptr %p.lowerbound126, align 4
  store i64 63, ptr %p.upperbound127, align 4
  store i64 1, ptr %p.stride128, align 4
  %omp_global_thread_num129 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num129, i32 34, ptr %p.lastiter125, ptr %p.lowerbound126, ptr %p.upperbound127, ptr %p.stride128, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound126, align 4
  %7 = load i64, ptr %p.upperbound127, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header108

omp_loop.header108:                               ; preds = %omp_loop.inc111, %omp_loop.preheader107
  %omp_loop.iv114 = phi i64 [ 0, %omp_loop.preheader107 ], [ %omp_loop.next116, %omp_loop.inc111 ]
  br label %omp_loop.cond109

omp_loop.cond109:                                 ; preds = %omp_loop.header108
  %omp_loop.cmp115 = icmp ult i64 %omp_loop.iv114, %9
  br i1 %omp_loop.cmp115, label %omp_loop.body110, label %omp_loop.exit112

omp_loop.exit112:                                 ; preds = %omp_loop.cond109
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num129)
  %omp_global_thread_num130 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num130)
  br label %omp_loop.after113

omp_loop.after113:                                ; preds = %omp_loop.exit112
  br label %omp.region.cont104

omp.region.cont104:                               ; preds = %omp_loop.after113
  br label %omp.par.pre_finalize98

omp.par.pre_finalize98:                           ; preds = %omp.region.cont104
  br label %omp.par.outlined.exit132.exitStub

omp_loop.body110:                                 ; preds = %omp_loop.cond109
  %10 = add i64 %omp_loop.iv114, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.wsloop.region118

omp.wsloop.region118:                             ; preds = %omp_loop.body110
  br label %omp.wsloop.region119

omp.wsloop.region119:                             ; preds = %omp.wsloop.region123, %omp.wsloop.region118
  %13 = phi i64 [ %17, %omp.wsloop.region123 ], [ 0, %omp.wsloop.region118 ]
  %14 = icmp slt i64 %13, 128
  br i1 %14, label %omp.wsloop.region120, label %omp.wsloop.region124

omp.wsloop.region124:                             ; preds = %omp.wsloop.region119
  br label %omp.region.cont117

omp.region.cont117:                               ; preds = %omp.wsloop.region124
  br label %omp_loop.inc111

omp_loop.inc111:                                  ; preds = %omp.region.cont117
  %omp_loop.next116 = add nuw i64 %omp_loop.iv114, 1
  br label %omp_loop.header108

omp.wsloop.region120:                             ; preds = %omp.wsloop.region119
  br label %omp.wsloop.region121

omp.wsloop.region121:                             ; preds = %omp.wsloop.region122, %omp.wsloop.region120
  %15 = phi i64 [ %56, %omp.wsloop.region122 ], [ 0, %omp.wsloop.region120 ]
  %16 = icmp slt i64 %15, 128
  br i1 %16, label %omp.wsloop.region122, label %omp.wsloop.region123

omp.wsloop.region123:                             ; preds = %omp.wsloop.region121
  %17 = add i64 %13, 1
  br label %omp.wsloop.region119

omp.wsloop.region122:                             ; preds = %omp.wsloop.region121
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %19 = add nuw nsw i64 0, %15
  %20 = getelementptr float, ptr %18, i64 %19
  %21 = load float, ptr %20, align 4
  %22 = fmul float %3, %21
  %23 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %24 = mul nuw nsw i64 %13, 128
  %25 = add nuw nsw i64 %24, %15
  %26 = getelementptr float, ptr %23, i64 %25
  %27 = load float, ptr %26, align 4
  %28 = fmul float %22, %27
  %29 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %30 = add nuw nsw i64 0, %13
  %31 = getelementptr float, ptr %29, i64 %30
  %32 = load float, ptr %31, align 4
  %33 = fadd float %32, %28
  %34 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %35 = add nuw nsw i64 0, %13
  %36 = getelementptr float, ptr %34, i64 %35
  store float %33, ptr %36, align 4
  %37 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %38 = add nuw nsw i64 0, %15
  %39 = getelementptr float, ptr %37, i64 %38
  %40 = load float, ptr %39, align 4
  %41 = fmul float %3, %40
  %42 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %43 = mul nuw nsw i64 %13, 128
  %44 = add nuw nsw i64 %43, %15
  %45 = getelementptr float, ptr %42, i64 %44
  %46 = load float, ptr %45, align 4
  %47 = fmul float %41, %46
  %48 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %49 = add nuw nsw i64 0, %13
  %50 = getelementptr float, ptr %48, i64 %49
  %51 = load float, ptr %50, align 4
  %52 = fadd float %51, %47
  %53 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %54 = add nuw nsw i64 0, %13
  %55 = getelementptr float, ptr %53, i64 %54
  store float %52, ptr %55, align 4
  %56 = add i64 %15, 1
  br label %omp.wsloop.region121

omp.par.outlined.exit132.exitStub:                ; preds = %omp.par.pre_finalize98
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.2(ptr noalias %tid.addr50, ptr noalias %zero.addr51, ptr %0) #0 {
omp.par.entry52:
  %gep_.reloaded89 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded89 = load ptr, ptr %gep_.reloaded89, align 8
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded90 = load ptr, ptr %gep_.reloaded90, align 8
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded91 = load ptr, ptr %gep_.reloaded91, align 8
  %gep_.reloaded92 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded92 = load ptr, ptr %gep_.reloaded92, align 8
  %p.lastiter81 = alloca i32, align 4
  %p.lowerbound82 = alloca i64, align 8
  %p.upperbound83 = alloca i64, align 8
  %p.stride84 = alloca i64, align 8
  %tid.addr.local55 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr50, align 4
  store i32 %1, ptr %tid.addr.local55, align 4
  %tid56 = load i32, ptr %tid.addr.local55, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded89, align 8
  %3 = load float, ptr %loadgep_.reloaded90, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded91, align 8
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded92, align 8
  br label %omp.region.after_alloca62

omp.region.after_alloca62:                        ; preds = %omp.par.entry52
  br label %omp.region.after_alloca59

omp.region.after_alloca59:                        ; preds = %omp.region.after_alloca62
  br label %omp.par.region53

omp.par.region53:                                 ; preds = %omp.region.after_alloca59
  br label %omp.par.region61

omp.par.region61:                                 ; preds = %omp.par.region53
  br label %omp_loop.preheader63

omp_loop.preheader63:                             ; preds = %omp.par.region61
  store i64 0, ptr %p.lowerbound82, align 4
  store i64 63, ptr %p.upperbound83, align 4
  store i64 1, ptr %p.stride84, align 4
  %omp_global_thread_num85 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num85, i32 34, ptr %p.lastiter81, ptr %p.lowerbound82, ptr %p.upperbound83, ptr %p.stride84, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound82, align 4
  %7 = load i64, ptr %p.upperbound83, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header64

omp_loop.header64:                                ; preds = %omp_loop.inc67, %omp_loop.preheader63
  %omp_loop.iv70 = phi i64 [ 0, %omp_loop.preheader63 ], [ %omp_loop.next72, %omp_loop.inc67 ]
  br label %omp_loop.cond65

omp_loop.cond65:                                  ; preds = %omp_loop.header64
  %omp_loop.cmp71 = icmp ult i64 %omp_loop.iv70, %9
  br i1 %omp_loop.cmp71, label %omp_loop.body66, label %omp_loop.exit68

omp_loop.exit68:                                  ; preds = %omp_loop.cond65
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num85)
  %omp_global_thread_num86 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num86)
  br label %omp_loop.after69

omp_loop.after69:                                 ; preds = %omp_loop.exit68
  br label %omp.region.cont60

omp.region.cont60:                                ; preds = %omp_loop.after69
  br label %omp.par.pre_finalize54

omp.par.pre_finalize54:                           ; preds = %omp.region.cont60
  br label %omp.par.outlined.exit88.exitStub

omp_loop.body66:                                  ; preds = %omp_loop.cond65
  %10 = add i64 %omp_loop.iv70, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 64
  br label %omp.wsloop.region74

omp.wsloop.region74:                              ; preds = %omp_loop.body66
  br label %omp.wsloop.region75

omp.wsloop.region75:                              ; preds = %omp.wsloop.region79, %omp.wsloop.region74
  %13 = phi i64 [ %17, %omp.wsloop.region79 ], [ 0, %omp.wsloop.region74 ]
  %14 = icmp slt i64 %13, 128
  br i1 %14, label %omp.wsloop.region76, label %omp.wsloop.region80

omp.wsloop.region80:                              ; preds = %omp.wsloop.region75
  br label %omp.region.cont73

omp.region.cont73:                                ; preds = %omp.wsloop.region80
  br label %omp_loop.inc67

omp_loop.inc67:                                   ; preds = %omp.region.cont73
  %omp_loop.next72 = add nuw i64 %omp_loop.iv70, 1
  br label %omp_loop.header64

omp.wsloop.region76:                              ; preds = %omp.wsloop.region75
  br label %omp.wsloop.region77

omp.wsloop.region77:                              ; preds = %omp.wsloop.region78, %omp.wsloop.region76
  %15 = phi i64 [ %56, %omp.wsloop.region78 ], [ 0, %omp.wsloop.region76 ]
  %16 = icmp slt i64 %15, 128
  br i1 %16, label %omp.wsloop.region78, label %omp.wsloop.region79

omp.wsloop.region79:                              ; preds = %omp.wsloop.region77
  %17 = add i64 %13, 1
  br label %omp.wsloop.region75

omp.wsloop.region78:                              ; preds = %omp.wsloop.region77
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %19 = add nuw nsw i64 0, %15
  %20 = getelementptr float, ptr %18, i64 %19
  %21 = load float, ptr %20, align 4
  %22 = fmul float %3, %21
  %23 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %24 = mul nuw nsw i64 %13, 128
  %25 = add nuw nsw i64 %24, %15
  %26 = getelementptr float, ptr %23, i64 %25
  %27 = load float, ptr %26, align 4
  %28 = fmul float %22, %27
  %29 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %30 = add nuw nsw i64 0, %13
  %31 = getelementptr float, ptr %29, i64 %30
  %32 = load float, ptr %31, align 4
  %33 = fadd float %32, %28
  %34 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %35 = add nuw nsw i64 0, %13
  %36 = getelementptr float, ptr %34, i64 %35
  store float %33, ptr %36, align 4
  %37 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %38 = add nuw nsw i64 0, %15
  %39 = getelementptr float, ptr %37, i64 %38
  %40 = load float, ptr %39, align 4
  %41 = fmul float %3, %40
  %42 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %43 = mul nuw nsw i64 %13, 128
  %44 = add nuw nsw i64 %43, %15
  %45 = getelementptr float, ptr %42, i64 %44
  %46 = load float, ptr %45, align 4
  %47 = fmul float %41, %46
  %48 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %49 = add nuw nsw i64 0, %13
  %50 = getelementptr float, ptr %48, i64 %49
  %51 = load float, ptr %50, align 4
  %52 = fadd float %51, %47
  %53 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %54 = add nuw nsw i64 0, %13
  %55 = getelementptr float, ptr %53, i64 %54
  store float %52, ptr %55, align 4
  %56 = add i64 %15, 1
  br label %omp.wsloop.region77

omp.par.outlined.exit88.exitStub:                 ; preds = %omp.par.pre_finalize54
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.1(ptr noalias %tid.addr11, ptr noalias %zero.addr12, ptr %0) #0 {
omp.par.entry13:
  %gep_.reloaded47 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded47 = load ptr, ptr %gep_.reloaded47, align 8
  %gep_.reloaded48 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded48 = load ptr, ptr %gep_.reloaded48, align 8
  %p.lastiter39 = alloca i32, align 4
  %p.lowerbound40 = alloca i64, align 8
  %p.upperbound41 = alloca i64, align 8
  %p.stride42 = alloca i64, align 8
  %tid.addr.local16 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr11, align 4
  store i32 %1, ptr %tid.addr.local16, align 4
  %tid17 = load i32, ptr %tid.addr.local16, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded47, align 8
  %3 = load float, ptr %loadgep_.reloaded48, align 4
  br label %omp.region.after_alloca23

omp.region.after_alloca23:                        ; preds = %omp.par.entry13
  br label %omp.region.after_alloca20

omp.region.after_alloca20:                        ; preds = %omp.region.after_alloca23
  br label %omp.par.region14

omp.par.region14:                                 ; preds = %omp.region.after_alloca20
  br label %omp.par.region22

omp.par.region22:                                 ; preds = %omp.par.region14
  br label %omp_loop.preheader24

omp_loop.preheader24:                             ; preds = %omp.par.region22
  store i64 0, ptr %p.lowerbound40, align 4
  store i64 63, ptr %p.upperbound41, align 4
  store i64 1, ptr %p.stride42, align 4
  %omp_global_thread_num43 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num43, i32 34, ptr %p.lastiter39, ptr %p.lowerbound40, ptr %p.upperbound41, ptr %p.stride42, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound40, align 4
  %5 = load i64, ptr %p.upperbound41, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header25

omp_loop.header25:                                ; preds = %omp_loop.inc28, %omp_loop.preheader24
  %omp_loop.iv31 = phi i64 [ 0, %omp_loop.preheader24 ], [ %omp_loop.next33, %omp_loop.inc28 ]
  br label %omp_loop.cond26

omp_loop.cond26:                                  ; preds = %omp_loop.header25
  %omp_loop.cmp32 = icmp ult i64 %omp_loop.iv31, %7
  br i1 %omp_loop.cmp32, label %omp_loop.body27, label %omp_loop.exit29

omp_loop.exit29:                                  ; preds = %omp_loop.cond26
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num43)
  %omp_global_thread_num44 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num44)
  br label %omp_loop.after30

omp_loop.after30:                                 ; preds = %omp_loop.exit29
  br label %omp.region.cont21

omp.region.cont21:                                ; preds = %omp_loop.after30
  br label %omp.par.pre_finalize15

omp.par.pre_finalize15:                           ; preds = %omp.region.cont21
  br label %omp.par.outlined.exit46.exitStub

omp_loop.body27:                                  ; preds = %omp_loop.cond26
  %8 = add i64 %omp_loop.iv31, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.wsloop.region35

omp.wsloop.region35:                              ; preds = %omp_loop.body27
  br label %omp.wsloop.region36

omp.wsloop.region36:                              ; preds = %omp.wsloop.region37, %omp.wsloop.region35
  %11 = phi i64 [ %21, %omp.wsloop.region37 ], [ 0, %omp.wsloop.region35 ]
  %12 = icmp slt i64 %11, 128
  br i1 %12, label %omp.wsloop.region37, label %omp.wsloop.region38

omp.wsloop.region38:                              ; preds = %omp.wsloop.region36
  br label %omp.region.cont34

omp.region.cont34:                                ; preds = %omp.wsloop.region38
  br label %omp_loop.inc28

omp_loop.inc28:                                   ; preds = %omp.region.cont34
  %omp_loop.next33 = add nuw i64 %omp_loop.iv31, 1
  br label %omp_loop.header25

omp.wsloop.region37:                              ; preds = %omp.wsloop.region36
  %13 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %14 = add nuw nsw i64 0, %11
  %15 = getelementptr float, ptr %13, i64 %14
  %16 = load float, ptr %15, align 4
  %17 = fmul float %16, %3
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %19 = add nuw nsw i64 0, %11
  %20 = getelementptr float, ptr %18, i64 %19
  store float %17, ptr %20, align 4
  %21 = add i64 %11, 1
  br label %omp.wsloop.region36

omp.par.outlined.exit46.exitStub:                 ; preds = %omp.par.pre_finalize15
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8
  %gep_.reloaded9 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded9 = load ptr, ptr %gep_.reloaded9, align 8
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load float, ptr %loadgep_.reloaded9, align 4
  br label %omp.region.after_alloca2

omp.region.after_alloca2:                         ; preds = %omp.par.entry
  br label %omp.region.after_alloca

omp.region.after_alloca:                          ; preds = %omp.region.after_alloca2
  br label %omp.par.region

omp.par.region:                                   ; preds = %omp.region.after_alloca
  br label %omp.par.region1

omp.par.region1:                                  ; preds = %omp.par.region
  br label %omp_loop.preheader

omp_loop.preheader:                               ; preds = %omp.par.region1
  store i64 0, ptr %p.lowerbound, align 4
  store i64 63, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num7 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num7, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound, align 4
  %5 = load i64, ptr %p.upperbound, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header

omp_loop.header:                                  ; preds = %omp_loop.inc, %omp_loop.preheader
  %omp_loop.iv = phi i64 [ 0, %omp_loop.preheader ], [ %omp_loop.next, %omp_loop.inc ]
  br label %omp_loop.cond

omp_loop.cond:                                    ; preds = %omp_loop.header
  %omp_loop.cmp = icmp ult i64 %omp_loop.iv, %7
  br i1 %omp_loop.cmp, label %omp_loop.body, label %omp_loop.exit

omp_loop.exit:                                    ; preds = %omp_loop.cond
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num7)
  %omp_global_thread_num8 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num8)
  br label %omp_loop.after

omp_loop.after:                                   ; preds = %omp_loop.exit
  br label %omp.region.cont

omp.region.cont:                                  ; preds = %omp_loop.after
  br label %omp.par.pre_finalize

omp.par.pre_finalize:                             ; preds = %omp.region.cont
  br label %omp.par.outlined.exit.exitStub

omp_loop.body:                                    ; preds = %omp_loop.cond
  %8 = add i64 %omp_loop.iv, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 64
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp_loop.body
  br label %omp.wsloop.region4

omp.wsloop.region4:                               ; preds = %omp.wsloop.region5, %omp.wsloop.region
  %11 = phi i64 [ %21, %omp.wsloop.region5 ], [ 0, %omp.wsloop.region ]
  %12 = icmp slt i64 %11, 128
  br i1 %12, label %omp.wsloop.region5, label %omp.wsloop.region6

omp.wsloop.region6:                               ; preds = %omp.wsloop.region4
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp.wsloop.region6
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont3
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.wsloop.region5:                               ; preds = %omp.wsloop.region4
  %13 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %14 = add nuw nsw i64 0, %11
  %15 = getelementptr float, ptr %13, i64 %14
  %16 = load float, ptr %15, align 4
  %17 = fmul float %16, %3
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %19 = add nuw nsw i64 0, %11
  %20 = getelementptr float, ptr %18, i64 %19
  store float %17, ptr %20, align 4
  %21 = add i64 %11, 1
  br label %omp.wsloop.region4

omp.par.outlined.exit.exitStub:                   ; preds = %omp.par.pre_finalize
  ret void
}

; Function Attrs: nounwind
declare i32 @__kmpc_global_thread_num(ptr) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_init_8u(ptr, i32, i32, ptr, ptr, ptr, ptr, i64, i64) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_fini(ptr, i32) #0

; Function Attrs: convergent nounwind
declare void @__kmpc_barrier(ptr, i32) #1

; Function Attrs: nounwind
declare !callback !1 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { convergent nounwind }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{!2}
!2 = !{i64 2, i64 -1, i64 -1, i1 true}
