; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

%struct.ident_t = type { i32, i32, i32, i32, ptr }

@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8

%struct.ompi_predefined_communicator_t = type opaque
@ompi_mpi_comm_world = external global %struct.ompi_predefined_communicator_t, align 1

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)



define void @testFunc(i32 %0, i32 %1, i32 %2, i32 %3, float %4, float %5, ptr %6, ptr %7, i64 %8, i64 %9, i64 %10, i64 %11, i64 %12, ptr %13, ptr %14, i64 %15, i64 %16, i64 %17, i64 %18, i64 %19, ptr %20, ptr %21, i64 %22, i64 %23, i64 %24, i64 %25, i64 %26, ptr %27, ptr %28, i64 %29, i64 %30, i64 %31, i64 %32, i64 %33, ptr %34, ptr %35, i64 %36, i64 %37, i64 %38, i64 %39, i64 %40) {
  %structArg151 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg149 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg147 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr, ptr }, align 8
  %.reloaded143 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded144 = alloca float, align 4
  %.reloaded145 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded146 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded99 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded100 = alloca float, align 4
  %.reloaded101 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded102 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded55 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded56 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded57 = alloca float, align 4
  %.reloaded58 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded12 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded13 = alloca float, align 4
  %.reloaded14 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %34, 0
  %43 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, ptr %35, 1
  %44 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %43, i64 %36, 2
  %45 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, i64 %37, 3, 0
  %46 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, i64 %39, 4, 0
  %47 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %46, i64 %38, 3, 1
  %48 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %47, i64 %40, 4, 1
  %49 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %27, 0
  %50 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %49, ptr %28, 1
  %51 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %50, i64 %29, 2
  %52 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, i64 %30, 3, 0
  %53 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, i64 %32, 4, 0
  %54 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %53, i64 %31, 3, 1
  %55 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %54, i64 %33, 4, 1
  %56 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %20, 0
  %57 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %56, ptr %21, 1
  %58 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %57, i64 %22, 2
  %59 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %58, i64 %23, 3, 0
  %60 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %59, i64 %25, 4, 0
  %61 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, i64 %24, 3, 1
  %62 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, i64 %26, 4, 1
  %63 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %13, 0
  %64 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %63, ptr %14, 1
  %65 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %64, i64 %15, 2
  %66 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %65, i64 %16, 3, 0
  %67 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %66, i64 %18, 4, 0
  %68 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %67, i64 %17, 3, 1
  %69 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, i64 %19, 4, 1
  %70 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %6, 0
  %71 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %70, ptr %7, 1
  %72 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %71, i64 %8, 2
  %73 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %72, i64 %9, 3, 0
  %74 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %73, i64 %11, 4, 0
  %75 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %74, i64 %10, 3, 1
  %76 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %75, i64 %12, 4, 1
  ;%77 = call i32 @MPI_Init(ptr null, ptr null)
  %78 = alloca i32, align 4
  %79 = call i32 @MPI_Comm_rank(ptr noundef @ompi_mpi_comm_world, ptr noundef %78)
  %80 = load i32, ptr %78, align 4
  %81 = alloca i32, align 4
  %82 = call i32 @MPI_Comm_size(ptr noundef @ompi_mpi_comm_world, ptr noundef %81)
  %83 = load i32, ptr %81, align 4
  %84 = srem i32 0, %83
  %85 = icmp eq i32 %80, %84
  br i1 %85, label %86, label %87

86:                                               ; preds = %41
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %76, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, ptr %.reloaded12, align 8
  store float %4, ptr %.reloaded13, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %62, ptr %.reloaded14, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %86
  %gep_.reloaded = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded12 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded12, ptr %gep_.reloaded12, align 8
  %gep_.reloaded13 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded13, ptr %gep_.reloaded13, align 8
  %gep_.reloaded14 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 3
  store ptr %.reloaded14, ptr %gep_.reloaded14, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par, ptr %structArg)
  br label %omp.par.outlined.exit

omp.par.outlined.exit:                            ; preds = %omp_parallel
  br label %omp.par.exit.split

omp.par.exit.split:                               ; preds = %omp.par.outlined.exit
  br label %87

87:                                               ; preds = %omp.par.exit.split, %41
  %88 = srem i32 1, %83
  %89 = icmp eq i32 %80, %88
  br i1 %89, label %90, label %91

90:                                               ; preds = %87
  %omp_global_thread_num15 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %76, ptr %.reloaded55, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, ptr %.reloaded56, align 8
  store float %4, ptr %.reloaded57, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %62, ptr %.reloaded58, align 8
  br label %omp_parallel148

omp_parallel148:                                  ; preds = %90
  %gep_.reloaded55 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg147, i32 0, i32 0
  store ptr %.reloaded55, ptr %gep_.reloaded55, align 8
  %gep_.reloaded56 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg147, i32 0, i32 1
  store ptr %.reloaded56, ptr %gep_.reloaded56, align 8
  %gep_.reloaded57 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg147, i32 0, i32 2
  store ptr %.reloaded57, ptr %gep_.reloaded57, align 8
  %gep_.reloaded58 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg147, i32 0, i32 3
  store ptr %.reloaded58, ptr %gep_.reloaded58, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.1, ptr %structArg147)
  br label %omp.par.outlined.exit54

omp.par.outlined.exit54:                          ; preds = %omp_parallel148
  br label %omp.par.exit.split53

omp.par.exit.split53:                             ; preds = %omp.par.outlined.exit54
  br label %91

91:                                               ; preds = %omp.par.exit.split53, %87
  %92 = srem i32 2, %83
  %93 = icmp eq i32 %80, %92
  br i1 %93, label %94, label %95

94:                                               ; preds = %91
  %omp_global_thread_num59 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %48, ptr %.reloaded99, align 8
  store float %5, ptr %.reloaded100, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %76, ptr %.reloaded101, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %55, ptr %.reloaded102, align 8
  br label %omp_parallel150

omp_parallel150:                                  ; preds = %94
  %gep_.reloaded99 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg149, i32 0, i32 0
  store ptr %.reloaded99, ptr %gep_.reloaded99, align 8
  %gep_.reloaded100 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg149, i32 0, i32 1
  store ptr %.reloaded100, ptr %gep_.reloaded100, align 8
  %gep_.reloaded101 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg149, i32 0, i32 2
  store ptr %.reloaded101, ptr %gep_.reloaded101, align 8
  %gep_.reloaded102 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg149, i32 0, i32 3
  store ptr %.reloaded102, ptr %gep_.reloaded102, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.2, ptr %structArg149)
  br label %omp.par.outlined.exit98

omp.par.outlined.exit98:                          ; preds = %omp_parallel150
  br label %omp.par.exit.split97

omp.par.exit.split97:                             ; preds = %omp.par.outlined.exit98
  br label %95

95:                                               ; preds = %omp.par.exit.split97, %91
  %96 = srem i32 3, %83
  %97 = icmp eq i32 %80, %96
  br i1 %97, label %98, label %99

98:                                               ; preds = %95
  %omp_global_thread_num103 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %48, ptr %.reloaded143, align 8
  store float %5, ptr %.reloaded144, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %76, ptr %.reloaded145, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %55, ptr %.reloaded146, align 8
  br label %omp_parallel152

omp_parallel152:                                  ; preds = %98
  %gep_.reloaded143 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg151, i32 0, i32 0
  store ptr %.reloaded143, ptr %gep_.reloaded143, align 8
  %gep_.reloaded144 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg151, i32 0, i32 1
  store ptr %.reloaded144, ptr %gep_.reloaded144, align 8
  %gep_.reloaded145 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg151, i32 0, i32 2
  store ptr %.reloaded145, ptr %gep_.reloaded145, align 8
  %gep_.reloaded146 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg151, i32 0, i32 3
  store ptr %.reloaded146, ptr %gep_.reloaded146, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.3, ptr %structArg151)
  br label %omp.par.outlined.exit142

omp.par.outlined.exit142:                         ; preds = %omp_parallel152
  br label %omp.par.exit.split141

omp.par.exit.split141:                            ; preds = %omp.par.outlined.exit142
  br label %99

99:                                               ; preds = %omp.par.exit.split141, %95
  %100 = call i32 @MPI_Barrier(ptr noundef @ompi_mpi_comm_world)
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.3(ptr noalias %tid.addr104, ptr noalias %zero.addr105, ptr %0) #0 {
omp.par.entry106:
  %gep_.reloaded143 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded143 = load ptr, ptr %gep_.reloaded143, align 8
  %gep_.reloaded144 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded144 = load ptr, ptr %gep_.reloaded144, align 8
  %gep_.reloaded145 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded145 = load ptr, ptr %gep_.reloaded145, align 8
  %gep_.reloaded146 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded146 = load ptr, ptr %gep_.reloaded146, align 8
  %p.lastiter135 = alloca i32, align 4
  %p.lowerbound136 = alloca i64, align 8
  %p.upperbound137 = alloca i64, align 8
  %p.stride138 = alloca i64, align 8
  %tid.addr.local109 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr104, align 4
  store i32 %1, ptr %tid.addr.local109, align 4
  %tid110 = load i32, ptr %tid.addr.local109, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded143, align 8
  %3 = load float, ptr %loadgep_.reloaded144, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded145, align 8
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded146, align 8
  br label %omp.region.after_alloca116

omp.region.after_alloca116:                       ; preds = %omp.par.entry106
  br label %omp.region.after_alloca113

omp.region.after_alloca113:                       ; preds = %omp.region.after_alloca116
  br label %omp.par.region107

omp.par.region107:                                ; preds = %omp.region.after_alloca113
  br label %omp.par.region115

omp.par.region115:                                ; preds = %omp.par.region107
  br label %omp_loop.preheader117

omp_loop.preheader117:                            ; preds = %omp.par.region115
  store i64 0, ptr %p.lowerbound136, align 4
  store i64 499, ptr %p.upperbound137, align 4
  store i64 1, ptr %p.stride138, align 4
  %omp_global_thread_num139 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num139, i32 34, ptr %p.lastiter135, ptr %p.lowerbound136, ptr %p.upperbound137, ptr %p.stride138, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound136, align 4
  %7 = load i64, ptr %p.upperbound137, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header118

omp_loop.header118:                               ; preds = %omp_loop.inc121, %omp_loop.preheader117
  %omp_loop.iv124 = phi i64 [ 0, %omp_loop.preheader117 ], [ %omp_loop.next126, %omp_loop.inc121 ]
  br label %omp_loop.cond119

omp_loop.cond119:                                 ; preds = %omp_loop.header118
  %omp_loop.cmp125 = icmp ult i64 %omp_loop.iv124, %9
  br i1 %omp_loop.cmp125, label %omp_loop.body120, label %omp_loop.exit122

omp_loop.exit122:                                 ; preds = %omp_loop.cond119
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num139)
  %omp_global_thread_num140 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num140)
  br label %omp_loop.after123

omp_loop.after123:                                ; preds = %omp_loop.exit122
  br label %omp.region.cont114

omp.region.cont114:                               ; preds = %omp_loop.after123
  br label %omp.par.pre_finalize108

omp.par.pre_finalize108:                          ; preds = %omp.region.cont114
  br label %omp.par.outlined.exit142.exitStub

omp_loop.body120:                                 ; preds = %omp_loop.cond119
  %10 = add i64 %omp_loop.iv124, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.wsloop.region128

omp.wsloop.region128:                             ; preds = %omp_loop.body120
  br label %omp.wsloop.region129

omp.wsloop.region129:                             ; preds = %omp.wsloop.region133, %omp.wsloop.region128
  %13 = phi i64 [ %25, %omp.wsloop.region133 ], [ 0, %omp.wsloop.region128 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.wsloop.region130, label %omp.wsloop.region134

omp.wsloop.region134:                             ; preds = %omp.wsloop.region129
  br label %omp.region.cont127

omp.region.cont127:                               ; preds = %omp.wsloop.region134
  br label %omp_loop.inc121

omp_loop.inc121:                                  ; preds = %omp.region.cont127
  %omp_loop.next126 = add nuw i64 %omp_loop.iv124, 1
  br label %omp_loop.header118

omp.wsloop.region130:                             ; preds = %omp.wsloop.region129
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = add nuw nsw i64 0, %13
  %17 = getelementptr float, ptr %15, i64 %16
  %18 = load float, ptr %17, align 4
  %19 = fmul float %18, %3
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %21 = add nuw nsw i64 0, %13
  %22 = getelementptr float, ptr %20, i64 %21
  store float %19, ptr %22, align 4
  br label %omp.wsloop.region131

omp.wsloop.region131:                             ; preds = %omp.wsloop.region132, %omp.wsloop.region130
  %23 = phi i64 [ %44, %omp.wsloop.region132 ], [ 0, %omp.wsloop.region130 ]
  %24 = icmp slt i64 %23, 1000
  br i1 %24, label %omp.wsloop.region132, label %omp.wsloop.region133

omp.wsloop.region133:                             ; preds = %omp.wsloop.region131
  %25 = add i64 %13, 1
  br label %omp.wsloop.region129

omp.wsloop.region132:                             ; preds = %omp.wsloop.region131
  %26 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %27 = add nuw nsw i64 0, %23
  %28 = getelementptr float, ptr %26, i64 %27
  %29 = load float, ptr %28, align 4
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %31 = mul nuw nsw i64 %23, 1000
  %32 = add nuw nsw i64 %31, %13
  %33 = getelementptr float, ptr %30, i64 %32
  %34 = load float, ptr %33, align 4
  %35 = fmul float %29, %34
  %36 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %37 = add nuw nsw i64 0, %13
  %38 = getelementptr float, ptr %36, i64 %37
  %39 = load float, ptr %38, align 4
  %40 = fadd float %39, %35
  %41 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %42 = add nuw nsw i64 0, %13
  %43 = getelementptr float, ptr %41, i64 %42
  store float %40, ptr %43, align 4
  %44 = add i64 %23, 1
  br label %omp.wsloop.region131

omp.par.outlined.exit142.exitStub:                ; preds = %omp.par.pre_finalize108
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.2(ptr noalias %tid.addr60, ptr noalias %zero.addr61, ptr %0) #0 {
omp.par.entry62:
  %gep_.reloaded99 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded99 = load ptr, ptr %gep_.reloaded99, align 8
  %gep_.reloaded100 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded100 = load ptr, ptr %gep_.reloaded100, align 8
  %gep_.reloaded101 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded101 = load ptr, ptr %gep_.reloaded101, align 8
  %gep_.reloaded102 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded102 = load ptr, ptr %gep_.reloaded102, align 8
  %p.lastiter91 = alloca i32, align 4
  %p.lowerbound92 = alloca i64, align 8
  %p.upperbound93 = alloca i64, align 8
  %p.stride94 = alloca i64, align 8
  %tid.addr.local65 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr60, align 4
  store i32 %1, ptr %tid.addr.local65, align 4
  %tid66 = load i32, ptr %tid.addr.local65, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded99, align 8
  %3 = load float, ptr %loadgep_.reloaded100, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded101, align 8
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded102, align 8
  br label %omp.region.after_alloca72

omp.region.after_alloca72:                        ; preds = %omp.par.entry62
  br label %omp.region.after_alloca69

omp.region.after_alloca69:                        ; preds = %omp.region.after_alloca72
  br label %omp.par.region63

omp.par.region63:                                 ; preds = %omp.region.after_alloca69
  br label %omp.par.region71

omp.par.region71:                                 ; preds = %omp.par.region63
  br label %omp_loop.preheader73

omp_loop.preheader73:                             ; preds = %omp.par.region71
  store i64 0, ptr %p.lowerbound92, align 4
  store i64 499, ptr %p.upperbound93, align 4
  store i64 1, ptr %p.stride94, align 4
  %omp_global_thread_num95 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num95, i32 34, ptr %p.lastiter91, ptr %p.lowerbound92, ptr %p.upperbound93, ptr %p.stride94, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound92, align 4
  %7 = load i64, ptr %p.upperbound93, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header74

omp_loop.header74:                                ; preds = %omp_loop.inc77, %omp_loop.preheader73
  %omp_loop.iv80 = phi i64 [ 0, %omp_loop.preheader73 ], [ %omp_loop.next82, %omp_loop.inc77 ]
  br label %omp_loop.cond75

omp_loop.cond75:                                  ; preds = %omp_loop.header74
  %omp_loop.cmp81 = icmp ult i64 %omp_loop.iv80, %9
  br i1 %omp_loop.cmp81, label %omp_loop.body76, label %omp_loop.exit78

omp_loop.exit78:                                  ; preds = %omp_loop.cond75
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num95)
  %omp_global_thread_num96 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num96)
  br label %omp_loop.after79

omp_loop.after79:                                 ; preds = %omp_loop.exit78
  br label %omp.region.cont70

omp.region.cont70:                                ; preds = %omp_loop.after79
  br label %omp.par.pre_finalize64

omp.par.pre_finalize64:                           ; preds = %omp.region.cont70
  br label %omp.par.outlined.exit98.exitStub

omp_loop.body76:                                  ; preds = %omp_loop.cond75
  %10 = add i64 %omp_loop.iv80, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 500
  br label %omp.wsloop.region84

omp.wsloop.region84:                              ; preds = %omp_loop.body76
  br label %omp.wsloop.region85

omp.wsloop.region85:                              ; preds = %omp.wsloop.region89, %omp.wsloop.region84
  %13 = phi i64 [ %25, %omp.wsloop.region89 ], [ 0, %omp.wsloop.region84 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.wsloop.region86, label %omp.wsloop.region90

omp.wsloop.region90:                              ; preds = %omp.wsloop.region85
  br label %omp.region.cont83

omp.region.cont83:                                ; preds = %omp.wsloop.region90
  br label %omp_loop.inc77

omp_loop.inc77:                                   ; preds = %omp.region.cont83
  %omp_loop.next82 = add nuw i64 %omp_loop.iv80, 1
  br label %omp_loop.header74

omp.wsloop.region86:                              ; preds = %omp.wsloop.region85
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = add nuw nsw i64 0, %13
  %17 = getelementptr float, ptr %15, i64 %16
  %18 = load float, ptr %17, align 4
  %19 = fmul float %18, %3
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %21 = add nuw nsw i64 0, %13
  %22 = getelementptr float, ptr %20, i64 %21
  store float %19, ptr %22, align 4
  br label %omp.wsloop.region87

omp.wsloop.region87:                              ; preds = %omp.wsloop.region88, %omp.wsloop.region86
  %23 = phi i64 [ %44, %omp.wsloop.region88 ], [ 0, %omp.wsloop.region86 ]
  %24 = icmp slt i64 %23, 1000
  br i1 %24, label %omp.wsloop.region88, label %omp.wsloop.region89

omp.wsloop.region89:                              ; preds = %omp.wsloop.region87
  %25 = add i64 %13, 1
  br label %omp.wsloop.region85

omp.wsloop.region88:                              ; preds = %omp.wsloop.region87
  %26 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %27 = add nuw nsw i64 0, %23
  %28 = getelementptr float, ptr %26, i64 %27
  %29 = load float, ptr %28, align 4
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %31 = mul nuw nsw i64 %23, 1000
  %32 = add nuw nsw i64 %31, %13
  %33 = getelementptr float, ptr %30, i64 %32
  %34 = load float, ptr %33, align 4
  %35 = fmul float %29, %34
  %36 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %37 = add nuw nsw i64 0, %13
  %38 = getelementptr float, ptr %36, i64 %37
  %39 = load float, ptr %38, align 4
  %40 = fadd float %39, %35
  %41 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %42 = add nuw nsw i64 0, %13
  %43 = getelementptr float, ptr %41, i64 %42
  store float %40, ptr %43, align 4
  %44 = add i64 %23, 1
  br label %omp.wsloop.region87

omp.par.outlined.exit98.exitStub:                 ; preds = %omp.par.pre_finalize64
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.1(ptr noalias %tid.addr16, ptr noalias %zero.addr17, ptr %0) #0 {
omp.par.entry18:
  %gep_.reloaded55 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded55 = load ptr, ptr %gep_.reloaded55, align 8
  %gep_.reloaded56 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded56 = load ptr, ptr %gep_.reloaded56, align 8
  %gep_.reloaded57 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded57 = load ptr, ptr %gep_.reloaded57, align 8
  %gep_.reloaded58 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded58 = load ptr, ptr %gep_.reloaded58, align 8
  %p.lastiter47 = alloca i32, align 4
  %p.lowerbound48 = alloca i64, align 8
  %p.upperbound49 = alloca i64, align 8
  %p.stride50 = alloca i64, align 8
  %tid.addr.local21 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr16, align 4
  store i32 %1, ptr %tid.addr.local21, align 4
  %tid22 = load i32, ptr %tid.addr.local21, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded55, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded56, align 8
  %4 = load float, ptr %loadgep_.reloaded57, align 4
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded58, align 8
  br label %omp.region.after_alloca28

omp.region.after_alloca28:                        ; preds = %omp.par.entry18
  br label %omp.region.after_alloca25

omp.region.after_alloca25:                        ; preds = %omp.region.after_alloca28
  br label %omp.par.region19

omp.par.region19:                                 ; preds = %omp.region.after_alloca25
  br label %omp.par.region27

omp.par.region27:                                 ; preds = %omp.par.region19
  br label %omp_loop.preheader29

omp_loop.preheader29:                             ; preds = %omp.par.region27
  store i64 0, ptr %p.lowerbound48, align 4
  store i64 499, ptr %p.upperbound49, align 4
  store i64 1, ptr %p.stride50, align 4
  %omp_global_thread_num51 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num51, i32 34, ptr %p.lastiter47, ptr %p.lowerbound48, ptr %p.upperbound49, ptr %p.stride50, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound48, align 4
  %7 = load i64, ptr %p.upperbound49, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header30

omp_loop.header30:                                ; preds = %omp_loop.inc33, %omp_loop.preheader29
  %omp_loop.iv36 = phi i64 [ 0, %omp_loop.preheader29 ], [ %omp_loop.next38, %omp_loop.inc33 ]
  br label %omp_loop.cond31

omp_loop.cond31:                                  ; preds = %omp_loop.header30
  %omp_loop.cmp37 = icmp ult i64 %omp_loop.iv36, %9
  br i1 %omp_loop.cmp37, label %omp_loop.body32, label %omp_loop.exit34

omp_loop.exit34:                                  ; preds = %omp_loop.cond31
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num51)
  %omp_global_thread_num52 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num52)
  br label %omp_loop.after35

omp_loop.after35:                                 ; preds = %omp_loop.exit34
  br label %omp.region.cont26

omp.region.cont26:                                ; preds = %omp_loop.after35
  br label %omp.par.pre_finalize20

omp.par.pre_finalize20:                           ; preds = %omp.region.cont26
  br label %omp.par.outlined.exit54.exitStub

omp_loop.body32:                                  ; preds = %omp_loop.cond31
  %10 = add i64 %omp_loop.iv36, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.wsloop.region40

omp.wsloop.region40:                              ; preds = %omp_loop.body32
  br label %omp.wsloop.region41

omp.wsloop.region41:                              ; preds = %omp.wsloop.region45, %omp.wsloop.region40
  %13 = phi i64 [ %20, %omp.wsloop.region45 ], [ 0, %omp.wsloop.region40 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.wsloop.region42, label %omp.wsloop.region46

omp.wsloop.region46:                              ; preds = %omp.wsloop.region41
  br label %omp.region.cont39

omp.region.cont39:                                ; preds = %omp.wsloop.region46
  br label %omp_loop.inc33

omp_loop.inc33:                                   ; preds = %omp.region.cont39
  %omp_loop.next38 = add nuw i64 %omp_loop.iv36, 1
  br label %omp_loop.header30

omp.wsloop.region42:                              ; preds = %omp.wsloop.region41
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = add nuw nsw i64 0, %13
  %17 = getelementptr float, ptr %15, i64 %16
  store float 0.000000e+00, ptr %17, align 4
  br label %omp.wsloop.region43

omp.wsloop.region43:                              ; preds = %omp.wsloop.region44, %omp.wsloop.region42
  %18 = phi i64 [ %40, %omp.wsloop.region44 ], [ 0, %omp.wsloop.region42 ]
  %19 = icmp slt i64 %18, 1000
  br i1 %19, label %omp.wsloop.region44, label %omp.wsloop.region45

omp.wsloop.region45:                              ; preds = %omp.wsloop.region43
  %20 = add i64 %13, 1
  br label %omp.wsloop.region41

omp.wsloop.region44:                              ; preds = %omp.wsloop.region43
  %21 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %22 = add nuw nsw i64 0, %18
  %23 = getelementptr float, ptr %21, i64 %22
  %24 = load float, ptr %23, align 4
  %25 = fmul float %4, %24
  %26 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %27 = mul nuw nsw i64 %18, 1000
  %28 = add nuw nsw i64 %27, %13
  %29 = getelementptr float, ptr %26, i64 %28
  %30 = load float, ptr %29, align 4
  %31 = fmul float %25, %30
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %33 = add nuw nsw i64 0, %13
  %34 = getelementptr float, ptr %32, i64 %33
  %35 = load float, ptr %34, align 4
  %36 = fadd float %35, %31
  %37 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %38 = add nuw nsw i64 0, %13
  %39 = getelementptr float, ptr %37, i64 %38
  store float %36, ptr %39, align 4
  %40 = add i64 %18, 1
  br label %omp.wsloop.region43

omp.par.outlined.exit54.exitStub:                 ; preds = %omp.par.pre_finalize20
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8
  %gep_.reloaded12 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded12 = load ptr, ptr %gep_.reloaded12, align 8
  %gep_.reloaded13 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded13 = load ptr, ptr %gep_.reloaded13, align 8
  %gep_.reloaded14 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded14 = load ptr, ptr %gep_.reloaded14, align 8
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded12, align 8
  %4 = load float, ptr %loadgep_.reloaded13, align 4
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded14, align 8
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
  store i64 499, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num10 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num10, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound, align 4
  %7 = load i64, ptr %p.upperbound, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header

omp_loop.header:                                  ; preds = %omp_loop.inc, %omp_loop.preheader
  %omp_loop.iv = phi i64 [ 0, %omp_loop.preheader ], [ %omp_loop.next, %omp_loop.inc ]
  br label %omp_loop.cond

omp_loop.cond:                                    ; preds = %omp_loop.header
  %omp_loop.cmp = icmp ult i64 %omp_loop.iv, %9
  br i1 %omp_loop.cmp, label %omp_loop.body, label %omp_loop.exit

omp_loop.exit:                                    ; preds = %omp_loop.cond
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num10)
  %omp_global_thread_num11 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num11)
  br label %omp_loop.after

omp_loop.after:                                   ; preds = %omp_loop.exit
  br label %omp.region.cont

omp.region.cont:                                  ; preds = %omp_loop.after
  br label %omp.par.pre_finalize

omp.par.pre_finalize:                             ; preds = %omp.region.cont
  br label %omp.par.outlined.exit.exitStub

omp_loop.body:                                    ; preds = %omp_loop.cond
  %10 = add i64 %omp_loop.iv, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 500
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp_loop.body
  br label %omp.wsloop.region4

omp.wsloop.region4:                               ; preds = %omp.wsloop.region8, %omp.wsloop.region
  %13 = phi i64 [ %20, %omp.wsloop.region8 ], [ 0, %omp.wsloop.region ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.wsloop.region5, label %omp.wsloop.region9

omp.wsloop.region9:                               ; preds = %omp.wsloop.region4
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp.wsloop.region9
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont3
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.wsloop.region5:                               ; preds = %omp.wsloop.region4
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = add nuw nsw i64 0, %13
  %17 = getelementptr float, ptr %15, i64 %16
  store float 0.000000e+00, ptr %17, align 4
  br label %omp.wsloop.region6

omp.wsloop.region6:                               ; preds = %omp.wsloop.region7, %omp.wsloop.region5
  %18 = phi i64 [ %40, %omp.wsloop.region7 ], [ 0, %omp.wsloop.region5 ]
  %19 = icmp slt i64 %18, 1000
  br i1 %19, label %omp.wsloop.region7, label %omp.wsloop.region8

omp.wsloop.region8:                               ; preds = %omp.wsloop.region6
  %20 = add i64 %13, 1
  br label %omp.wsloop.region4

omp.wsloop.region7:                               ; preds = %omp.wsloop.region6
  %21 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %22 = add nuw nsw i64 0, %18
  %23 = getelementptr float, ptr %21, i64 %22
  %24 = load float, ptr %23, align 4
  %25 = fmul float %4, %24
  %26 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %27 = mul nuw nsw i64 %18, 1000
  %28 = add nuw nsw i64 %27, %13
  %29 = getelementptr float, ptr %26, i64 %28
  %30 = load float, ptr %29, align 4
  %31 = fmul float %25, %30
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %33 = add nuw nsw i64 0, %13
  %34 = getelementptr float, ptr %32, i64 %33
  %35 = load float, ptr %34, align 4
  %36 = fadd float %35, %31
  %37 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %38 = add nuw nsw i64 0, %13
  %39 = getelementptr float, ptr %37, i64 %38
  store float %36, ptr %39, align 4
  %40 = add i64 %18, 1
  br label %omp.wsloop.region6

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
