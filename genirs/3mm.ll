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

define void @testFunc(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, ptr %5, ptr %6, i64 %7, i64 %8, i64 %9, i64 %10, i64 %11, ptr %12, ptr %13, i64 %14, i64 %15, i64 %16, i64 %17, i64 %18, ptr %19, ptr %20, i64 %21, i64 %22, i64 %23, i64 %24, i64 %25, ptr %26, ptr %27, i64 %28, i64 %29, i64 %30, i64 %31, i64 %32, ptr %33, ptr %34, i64 %35, i64 %36, i64 %37, i64 %38, i64 %39, ptr %40, ptr %41, i64 %42, i64 %43, i64 %44, i64 %45, i64 %46, ptr %47, ptr %48, i64 %49, i64 %50, i64 %51, i64 %52, i64 %53) {
  %structArg237 = alloca { ptr, ptr, ptr }, align 8
  %structArg235 = alloca { ptr, ptr, ptr }, align 8
  %structArg233 = alloca { ptr, ptr, ptr }, align 8
  %structArg231 = alloca { ptr, ptr, ptr }, align 8
  %structArg229 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded226 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded227 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded228 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded183 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded184 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded185 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded140 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded141 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded142 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded97 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded98 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded99 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded54 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded55 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded56 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded12 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded13 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %55 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %47, 0
  %56 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %55, ptr %48, 1
  %57 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %56, i64 %49, 2
  %58 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %57, i64 %50, 3, 0
  %59 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %58, i64 %52, 4, 0
  %60 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %59, i64 %51, 3, 1
  %61 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, i64 %53, 4, 1
  %62 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %40, 0
  %63 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %62, ptr %41, 1
  %64 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %63, i64 %42, 2
  %65 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %64, i64 %43, 3, 0
  %66 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %65, i64 %45, 4, 0
  %67 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %66, i64 %44, 3, 1
  %68 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %67, i64 %46, 4, 1
  %69 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %33, 0
  %70 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, ptr %34, 1
  %71 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %70, i64 %35, 2
  %72 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %71, i64 %36, 3, 0
  %73 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %72, i64 %38, 4, 0
  %74 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %73, i64 %37, 3, 1
  %75 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %74, i64 %39, 4, 1
  %76 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %26, 0
  %77 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %76, ptr %27, 1
  %78 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %77, i64 %28, 2
  %79 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %78, i64 %29, 3, 0
  %80 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %79, i64 %31, 4, 0
  %81 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %80, i64 %30, 3, 1
  %82 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %81, i64 %32, 4, 1
  %83 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %19, 0
  %84 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %83, ptr %20, 1
  %85 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %84, i64 %21, 2
  %86 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %85, i64 %22, 3, 0
  %87 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %86, i64 %24, 4, 0
  %88 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %87, i64 %23, 3, 1
  %89 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %88, i64 %25, 4, 1
  %90 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %12, 0
  %91 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %90, ptr %13, 1
  %92 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %91, i64 %14, 2
  %93 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %92, i64 %15, 3, 0
  %94 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %93, i64 %17, 4, 0
  %95 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %94, i64 %16, 3, 1
  %96 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %95, i64 %18, 4, 1
  %97 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %5, 0
  %98 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %97, ptr %6, 1
  %99 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %98, i64 %7, 2
  %100 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %99, i64 %8, 3, 0
  %101 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %100, i64 %10, 4, 0
  %102 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %101, i64 %9, 3, 1
  %103 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %102, i64 %11, 4, 1
  ;%104 = call i32 @MPI_Init(ptr null, ptr null)
  %105 = alloca i32, align 4
  %106 = call i32 @MPI_Comm_rank(ptr noundef @ompi_mpi_comm_world, ptr noundef %105)
  %107 = load i32, ptr %105, align 4
  %108 = alloca i32, align 4
  %109 = call i32 @MPI_Comm_size(ptr noundef @ompi_mpi_comm_world, ptr noundef %108)
  %110 = load i32, ptr %108, align 4
  %111 = srem i32 0, %110
  %112 = icmp eq i32 %107, %111
  br i1 %112, label %113, label %114

113:                                              ; preds = %54
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %96, ptr %.reloaded12, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %89, ptr %.reloaded13, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %113
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded12 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded12, ptr %gep_.reloaded12, align 8
  %gep_.reloaded13 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded13, ptr %gep_.reloaded13, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par, ptr %structArg)
  br label %omp.par.outlined.exit

omp.par.outlined.exit:                            ; preds = %omp_parallel
  br label %omp.par.exit.split

omp.par.exit.split:                               ; preds = %omp.par.outlined.exit
  br label %114

114:                                              ; preds = %omp.par.exit.split, %54
  %115 = srem i32 1, %110
  %116 = icmp eq i32 %107, %115
  br i1 %116, label %117, label %118

117:                                              ; preds = %114
  %omp_global_thread_num14 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %.reloaded54, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %96, ptr %.reloaded55, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %89, ptr %.reloaded56, align 8
  br label %omp_parallel230

omp_parallel230:                                  ; preds = %117
  %gep_.reloaded54 = getelementptr { ptr, ptr, ptr }, ptr %structArg229, i32 0, i32 0
  store ptr %.reloaded54, ptr %gep_.reloaded54, align 8
  %gep_.reloaded55 = getelementptr { ptr, ptr, ptr }, ptr %structArg229, i32 0, i32 1
  store ptr %.reloaded55, ptr %gep_.reloaded55, align 8
  %gep_.reloaded56 = getelementptr { ptr, ptr, ptr }, ptr %structArg229, i32 0, i32 2
  store ptr %.reloaded56, ptr %gep_.reloaded56, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.1, ptr %structArg229)
  br label %omp.par.outlined.exit53

omp.par.outlined.exit53:                          ; preds = %omp_parallel230
  br label %omp.par.exit.split52

omp.par.exit.split52:                             ; preds = %omp.par.outlined.exit53
  br label %118

118:                                              ; preds = %omp.par.exit.split52, %114
  %119 = srem i32 2, %110
  %120 = icmp eq i32 %107, %119
  br i1 %120, label %121, label %122

121:                                              ; preds = %118
  %omp_global_thread_num57 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %82, ptr %.reloaded97, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %75, ptr %.reloaded98, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, ptr %.reloaded99, align 8
  br label %omp_parallel232

omp_parallel232:                                  ; preds = %121
  %gep_.reloaded97 = getelementptr { ptr, ptr, ptr }, ptr %structArg231, i32 0, i32 0
  store ptr %.reloaded97, ptr %gep_.reloaded97, align 8
  %gep_.reloaded98 = getelementptr { ptr, ptr, ptr }, ptr %structArg231, i32 0, i32 1
  store ptr %.reloaded98, ptr %gep_.reloaded98, align 8
  %gep_.reloaded99 = getelementptr { ptr, ptr, ptr }, ptr %structArg231, i32 0, i32 2
  store ptr %.reloaded99, ptr %gep_.reloaded99, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.2, ptr %structArg231)
  br label %omp.par.outlined.exit96

omp.par.outlined.exit96:                          ; preds = %omp_parallel232
  br label %omp.par.exit.split95

omp.par.exit.split95:                             ; preds = %omp.par.outlined.exit96
  br label %122

122:                                              ; preds = %omp.par.exit.split95, %118
  %123 = srem i32 3, %110
  %124 = icmp eq i32 %107, %123
  br i1 %124, label %125, label %126

125:                                              ; preds = %122
  %omp_global_thread_num100 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %82, ptr %.reloaded140, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %75, ptr %.reloaded141, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, ptr %.reloaded142, align 8
  br label %omp_parallel234

omp_parallel234:                                  ; preds = %125
  %gep_.reloaded140 = getelementptr { ptr, ptr, ptr }, ptr %structArg233, i32 0, i32 0
  store ptr %.reloaded140, ptr %gep_.reloaded140, align 8
  %gep_.reloaded141 = getelementptr { ptr, ptr, ptr }, ptr %structArg233, i32 0, i32 1
  store ptr %.reloaded141, ptr %gep_.reloaded141, align 8
  %gep_.reloaded142 = getelementptr { ptr, ptr, ptr }, ptr %structArg233, i32 0, i32 2
  store ptr %.reloaded142, ptr %gep_.reloaded142, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.3, ptr %structArg233)
  br label %omp.par.outlined.exit139

omp.par.outlined.exit139:                         ; preds = %omp_parallel234
  br label %omp.par.exit.split138

omp.par.exit.split138:                            ; preds = %omp.par.outlined.exit139
  br label %126

126:                                              ; preds = %omp.par.exit.split138, %122
  %127 = srem i32 4, %110
  %128 = icmp eq i32 %107, %127
  br i1 %128, label %129, label %130

129:                                              ; preds = %126
  %omp_global_thread_num143 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, ptr %.reloaded183, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %.reloaded184, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %82, ptr %.reloaded185, align 8
  br label %omp_parallel236

omp_parallel236:                                  ; preds = %129
  %gep_.reloaded183 = getelementptr { ptr, ptr, ptr }, ptr %structArg235, i32 0, i32 0
  store ptr %.reloaded183, ptr %gep_.reloaded183, align 8
  %gep_.reloaded184 = getelementptr { ptr, ptr, ptr }, ptr %structArg235, i32 0, i32 1
  store ptr %.reloaded184, ptr %gep_.reloaded184, align 8
  %gep_.reloaded185 = getelementptr { ptr, ptr, ptr }, ptr %structArg235, i32 0, i32 2
  store ptr %.reloaded185, ptr %gep_.reloaded185, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.4, ptr %structArg235)
  br label %omp.par.outlined.exit182

omp.par.outlined.exit182:                         ; preds = %omp_parallel236
  br label %omp.par.exit.split181

omp.par.exit.split181:                            ; preds = %omp.par.outlined.exit182
  br label %130

130:                                              ; preds = %omp.par.exit.split181, %126
  %131 = srem i32 5, %110
  %132 = icmp eq i32 %107, %131
  br i1 %132, label %133, label %134

133:                                              ; preds = %130
  %omp_global_thread_num186 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, ptr %.reloaded226, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %.reloaded227, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %82, ptr %.reloaded228, align 8
  br label %omp_parallel238

omp_parallel238:                                  ; preds = %133
  %gep_.reloaded226 = getelementptr { ptr, ptr, ptr }, ptr %structArg237, i32 0, i32 0
  store ptr %.reloaded226, ptr %gep_.reloaded226, align 8
  %gep_.reloaded227 = getelementptr { ptr, ptr, ptr }, ptr %structArg237, i32 0, i32 1
  store ptr %.reloaded227, ptr %gep_.reloaded227, align 8
  %gep_.reloaded228 = getelementptr { ptr, ptr, ptr }, ptr %structArg237, i32 0, i32 2
  store ptr %.reloaded228, ptr %gep_.reloaded228, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.5, ptr %structArg237)
  br label %omp.par.outlined.exit225

omp.par.outlined.exit225:                         ; preds = %omp_parallel238
  br label %omp.par.exit.split224

omp.par.exit.split224:                            ; preds = %omp.par.outlined.exit225
  br label %134

134:                                              ; preds = %omp.par.exit.split224, %130
  %135 = call i32 @MPI_Barrier(ptr noundef @ompi_mpi_comm_world)
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.5(ptr noalias %tid.addr187, ptr noalias %zero.addr188, ptr %0) #0 {
omp.par.entry189:
  %gep_.reloaded226 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded226 = load ptr, ptr %gep_.reloaded226, align 8
  %gep_.reloaded227 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded227 = load ptr, ptr %gep_.reloaded227, align 8
  %gep_.reloaded228 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded228 = load ptr, ptr %gep_.reloaded228, align 8
  %p.lastiter218 = alloca i32, align 4
  %p.lowerbound219 = alloca i64, align 8
  %p.upperbound220 = alloca i64, align 8
  %p.stride221 = alloca i64, align 8
  %tid.addr.local192 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr187, align 4
  store i32 %1, ptr %tid.addr.local192, align 4
  %tid193 = load i32, ptr %tid.addr.local192, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded226, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded227, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded228, align 8
  br label %omp.region.after_alloca199

omp.region.after_alloca199:                       ; preds = %omp.par.entry189
  br label %omp.region.after_alloca196

omp.region.after_alloca196:                       ; preds = %omp.region.after_alloca199
  br label %omp.par.region190

omp.par.region190:                                ; preds = %omp.region.after_alloca196
  br label %omp.par.region198

omp.par.region198:                                ; preds = %omp.par.region190
  br label %omp_loop.preheader200

omp_loop.preheader200:                            ; preds = %omp.par.region198
  store i64 0, ptr %p.lowerbound219, align 4
  store i64 63, ptr %p.upperbound220, align 4
  store i64 1, ptr %p.stride221, align 4
  %omp_global_thread_num222 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num222, i32 34, ptr %p.lastiter218, ptr %p.lowerbound219, ptr %p.upperbound220, ptr %p.stride221, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound219, align 4
  %6 = load i64, ptr %p.upperbound220, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header201

omp_loop.header201:                               ; preds = %omp_loop.inc204, %omp_loop.preheader200
  %omp_loop.iv207 = phi i64 [ 0, %omp_loop.preheader200 ], [ %omp_loop.next209, %omp_loop.inc204 ]
  br label %omp_loop.cond202

omp_loop.cond202:                                 ; preds = %omp_loop.header201
  %omp_loop.cmp208 = icmp ult i64 %omp_loop.iv207, %8
  br i1 %omp_loop.cmp208, label %omp_loop.body203, label %omp_loop.exit205

omp_loop.exit205:                                 ; preds = %omp_loop.cond202
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num222)
  %omp_global_thread_num223 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num223)
  br label %omp_loop.after206

omp_loop.after206:                                ; preds = %omp_loop.exit205
  br label %omp.region.cont197

omp.region.cont197:                               ; preds = %omp_loop.after206
  br label %omp.par.pre_finalize191

omp.par.pre_finalize191:                          ; preds = %omp.region.cont197
  br label %omp.par.outlined.exit225.exitStub

omp_loop.body203:                                 ; preds = %omp_loop.cond202
  %9 = add i64 %omp_loop.iv207, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.wsloop.region211

omp.wsloop.region211:                             ; preds = %omp_loop.body203
  br label %omp.wsloop.region212

omp.wsloop.region212:                             ; preds = %omp.wsloop.region216, %omp.wsloop.region211
  %12 = phi i64 [ %19, %omp.wsloop.region216 ], [ 0, %omp.wsloop.region211 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region213, label %omp.wsloop.region217

omp.wsloop.region217:                             ; preds = %omp.wsloop.region212
  br label %omp.region.cont210

omp.region.cont210:                               ; preds = %omp.wsloop.region217
  br label %omp_loop.inc204

omp_loop.inc204:                                  ; preds = %omp.region.cont210
  %omp_loop.next209 = add nuw i64 %omp_loop.iv207, 1
  br label %omp_loop.header201

omp.wsloop.region213:                             ; preds = %omp.wsloop.region212
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region214

omp.wsloop.region214:                             ; preds = %omp.wsloop.region215, %omp.wsloop.region213
  %17 = phi i64 [ %38, %omp.wsloop.region215 ], [ 0, %omp.wsloop.region213 ]
  %18 = icmp slt i64 %17, 128
  br i1 %18, label %omp.wsloop.region215, label %omp.wsloop.region216

omp.wsloop.region216:                             ; preds = %omp.wsloop.region214
  %19 = add i64 %12, 1
  br label %omp.wsloop.region212

omp.wsloop.region215:                             ; preds = %omp.wsloop.region214
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
  br label %omp.wsloop.region214

omp.par.outlined.exit225.exitStub:                ; preds = %omp.par.pre_finalize191
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.4(ptr noalias %tid.addr144, ptr noalias %zero.addr145, ptr %0) #0 {
omp.par.entry146:
  %gep_.reloaded183 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded183 = load ptr, ptr %gep_.reloaded183, align 8
  %gep_.reloaded184 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded184 = load ptr, ptr %gep_.reloaded184, align 8
  %gep_.reloaded185 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded185 = load ptr, ptr %gep_.reloaded185, align 8
  %p.lastiter175 = alloca i32, align 4
  %p.lowerbound176 = alloca i64, align 8
  %p.upperbound177 = alloca i64, align 8
  %p.stride178 = alloca i64, align 8
  %tid.addr.local149 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr144, align 4
  store i32 %1, ptr %tid.addr.local149, align 4
  %tid150 = load i32, ptr %tid.addr.local149, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded183, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded184, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded185, align 8
  br label %omp.region.after_alloca156

omp.region.after_alloca156:                       ; preds = %omp.par.entry146
  br label %omp.region.after_alloca153

omp.region.after_alloca153:                       ; preds = %omp.region.after_alloca156
  br label %omp.par.region147

omp.par.region147:                                ; preds = %omp.region.after_alloca153
  br label %omp.par.region155

omp.par.region155:                                ; preds = %omp.par.region147
  br label %omp_loop.preheader157

omp_loop.preheader157:                            ; preds = %omp.par.region155
  store i64 0, ptr %p.lowerbound176, align 4
  store i64 63, ptr %p.upperbound177, align 4
  store i64 1, ptr %p.stride178, align 4
  %omp_global_thread_num179 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num179, i32 34, ptr %p.lastiter175, ptr %p.lowerbound176, ptr %p.upperbound177, ptr %p.stride178, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound176, align 4
  %6 = load i64, ptr %p.upperbound177, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header158

omp_loop.header158:                               ; preds = %omp_loop.inc161, %omp_loop.preheader157
  %omp_loop.iv164 = phi i64 [ 0, %omp_loop.preheader157 ], [ %omp_loop.next166, %omp_loop.inc161 ]
  br label %omp_loop.cond159

omp_loop.cond159:                                 ; preds = %omp_loop.header158
  %omp_loop.cmp165 = icmp ult i64 %omp_loop.iv164, %8
  br i1 %omp_loop.cmp165, label %omp_loop.body160, label %omp_loop.exit162

omp_loop.exit162:                                 ; preds = %omp_loop.cond159
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num179)
  %omp_global_thread_num180 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num180)
  br label %omp_loop.after163

omp_loop.after163:                                ; preds = %omp_loop.exit162
  br label %omp.region.cont154

omp.region.cont154:                               ; preds = %omp_loop.after163
  br label %omp.par.pre_finalize148

omp.par.pre_finalize148:                          ; preds = %omp.region.cont154
  br label %omp.par.outlined.exit182.exitStub

omp_loop.body160:                                 ; preds = %omp_loop.cond159
  %9 = add i64 %omp_loop.iv164, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 64
  br label %omp.wsloop.region168

omp.wsloop.region168:                             ; preds = %omp_loop.body160
  br label %omp.wsloop.region169

omp.wsloop.region169:                             ; preds = %omp.wsloop.region173, %omp.wsloop.region168
  %12 = phi i64 [ %19, %omp.wsloop.region173 ], [ 0, %omp.wsloop.region168 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region170, label %omp.wsloop.region174

omp.wsloop.region174:                             ; preds = %omp.wsloop.region169
  br label %omp.region.cont167

omp.region.cont167:                               ; preds = %omp.wsloop.region174
  br label %omp_loop.inc161

omp_loop.inc161:                                  ; preds = %omp.region.cont167
  %omp_loop.next166 = add nuw i64 %omp_loop.iv164, 1
  br label %omp_loop.header158

omp.wsloop.region170:                             ; preds = %omp.wsloop.region169
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region171

omp.wsloop.region171:                             ; preds = %omp.wsloop.region172, %omp.wsloop.region170
  %17 = phi i64 [ %38, %omp.wsloop.region172 ], [ 0, %omp.wsloop.region170 ]
  %18 = icmp slt i64 %17, 128
  br i1 %18, label %omp.wsloop.region172, label %omp.wsloop.region173

omp.wsloop.region173:                             ; preds = %omp.wsloop.region171
  %19 = add i64 %12, 1
  br label %omp.wsloop.region169

omp.wsloop.region172:                             ; preds = %omp.wsloop.region171
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
  br label %omp.wsloop.region171

omp.par.outlined.exit182.exitStub:                ; preds = %omp.par.pre_finalize148
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.3(ptr noalias %tid.addr101, ptr noalias %zero.addr102, ptr %0) #0 {
omp.par.entry103:
  %gep_.reloaded140 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded140 = load ptr, ptr %gep_.reloaded140, align 8
  %gep_.reloaded141 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded141 = load ptr, ptr %gep_.reloaded141, align 8
  %gep_.reloaded142 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded142 = load ptr, ptr %gep_.reloaded142, align 8
  %p.lastiter132 = alloca i32, align 4
  %p.lowerbound133 = alloca i64, align 8
  %p.upperbound134 = alloca i64, align 8
  %p.stride135 = alloca i64, align 8
  %tid.addr.local106 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr101, align 4
  store i32 %1, ptr %tid.addr.local106, align 4
  %tid107 = load i32, ptr %tid.addr.local106, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded140, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded141, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded142, align 8
  br label %omp.region.after_alloca113

omp.region.after_alloca113:                       ; preds = %omp.par.entry103
  br label %omp.region.after_alloca110

omp.region.after_alloca110:                       ; preds = %omp.region.after_alloca113
  br label %omp.par.region104

omp.par.region104:                                ; preds = %omp.region.after_alloca110
  br label %omp.par.region112

omp.par.region112:                                ; preds = %omp.par.region104
  br label %omp_loop.preheader114

omp_loop.preheader114:                            ; preds = %omp.par.region112
  store i64 0, ptr %p.lowerbound133, align 4
  store i64 63, ptr %p.upperbound134, align 4
  store i64 1, ptr %p.stride135, align 4
  %omp_global_thread_num136 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num136, i32 34, ptr %p.lastiter132, ptr %p.lowerbound133, ptr %p.upperbound134, ptr %p.stride135, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound133, align 4
  %6 = load i64, ptr %p.upperbound134, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header115

omp_loop.header115:                               ; preds = %omp_loop.inc118, %omp_loop.preheader114
  %omp_loop.iv121 = phi i64 [ 0, %omp_loop.preheader114 ], [ %omp_loop.next123, %omp_loop.inc118 ]
  br label %omp_loop.cond116

omp_loop.cond116:                                 ; preds = %omp_loop.header115
  %omp_loop.cmp122 = icmp ult i64 %omp_loop.iv121, %8
  br i1 %omp_loop.cmp122, label %omp_loop.body117, label %omp_loop.exit119

omp_loop.exit119:                                 ; preds = %omp_loop.cond116
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num136)
  %omp_global_thread_num137 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num137)
  br label %omp_loop.after120

omp_loop.after120:                                ; preds = %omp_loop.exit119
  br label %omp.region.cont111

omp.region.cont111:                               ; preds = %omp_loop.after120
  br label %omp.par.pre_finalize105

omp.par.pre_finalize105:                          ; preds = %omp.region.cont111
  br label %omp.par.outlined.exit139.exitStub

omp_loop.body117:                                 ; preds = %omp_loop.cond116
  %9 = add i64 %omp_loop.iv121, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.wsloop.region125

omp.wsloop.region125:                             ; preds = %omp_loop.body117
  br label %omp.wsloop.region126

omp.wsloop.region126:                             ; preds = %omp.wsloop.region130, %omp.wsloop.region125
  %12 = phi i64 [ %19, %omp.wsloop.region130 ], [ 0, %omp.wsloop.region125 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region127, label %omp.wsloop.region131

omp.wsloop.region131:                             ; preds = %omp.wsloop.region126
  br label %omp.region.cont124

omp.region.cont124:                               ; preds = %omp.wsloop.region131
  br label %omp_loop.inc118

omp_loop.inc118:                                  ; preds = %omp.region.cont124
  %omp_loop.next123 = add nuw i64 %omp_loop.iv121, 1
  br label %omp_loop.header115

omp.wsloop.region127:                             ; preds = %omp.wsloop.region126
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region128

omp.wsloop.region128:                             ; preds = %omp.wsloop.region129, %omp.wsloop.region127
  %17 = phi i64 [ %38, %omp.wsloop.region129 ], [ 0, %omp.wsloop.region127 ]
  %18 = icmp slt i64 %17, 128
  br i1 %18, label %omp.wsloop.region129, label %omp.wsloop.region130

omp.wsloop.region130:                             ; preds = %omp.wsloop.region128
  %19 = add i64 %12, 1
  br label %omp.wsloop.region126

omp.wsloop.region129:                             ; preds = %omp.wsloop.region128
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
  br label %omp.wsloop.region128

omp.par.outlined.exit139.exitStub:                ; preds = %omp.par.pre_finalize105
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.2(ptr noalias %tid.addr58, ptr noalias %zero.addr59, ptr %0) #0 {
omp.par.entry60:
  %gep_.reloaded97 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded97 = load ptr, ptr %gep_.reloaded97, align 8
  %gep_.reloaded98 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded98 = load ptr, ptr %gep_.reloaded98, align 8
  %gep_.reloaded99 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded99 = load ptr, ptr %gep_.reloaded99, align 8
  %p.lastiter89 = alloca i32, align 4
  %p.lowerbound90 = alloca i64, align 8
  %p.upperbound91 = alloca i64, align 8
  %p.stride92 = alloca i64, align 8
  %tid.addr.local63 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr58, align 4
  store i32 %1, ptr %tid.addr.local63, align 4
  %tid64 = load i32, ptr %tid.addr.local63, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded97, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded98, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded99, align 8
  br label %omp.region.after_alloca70

omp.region.after_alloca70:                        ; preds = %omp.par.entry60
  br label %omp.region.after_alloca67

omp.region.after_alloca67:                        ; preds = %omp.region.after_alloca70
  br label %omp.par.region61

omp.par.region61:                                 ; preds = %omp.region.after_alloca67
  br label %omp.par.region69

omp.par.region69:                                 ; preds = %omp.par.region61
  br label %omp_loop.preheader71

omp_loop.preheader71:                             ; preds = %omp.par.region69
  store i64 0, ptr %p.lowerbound90, align 4
  store i64 63, ptr %p.upperbound91, align 4
  store i64 1, ptr %p.stride92, align 4
  %omp_global_thread_num93 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num93, i32 34, ptr %p.lastiter89, ptr %p.lowerbound90, ptr %p.upperbound91, ptr %p.stride92, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound90, align 4
  %6 = load i64, ptr %p.upperbound91, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header72

omp_loop.header72:                                ; preds = %omp_loop.inc75, %omp_loop.preheader71
  %omp_loop.iv78 = phi i64 [ 0, %omp_loop.preheader71 ], [ %omp_loop.next80, %omp_loop.inc75 ]
  br label %omp_loop.cond73

omp_loop.cond73:                                  ; preds = %omp_loop.header72
  %omp_loop.cmp79 = icmp ult i64 %omp_loop.iv78, %8
  br i1 %omp_loop.cmp79, label %omp_loop.body74, label %omp_loop.exit76

omp_loop.exit76:                                  ; preds = %omp_loop.cond73
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num93)
  %omp_global_thread_num94 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num94)
  br label %omp_loop.after77

omp_loop.after77:                                 ; preds = %omp_loop.exit76
  br label %omp.region.cont68

omp.region.cont68:                                ; preds = %omp_loop.after77
  br label %omp.par.pre_finalize62

omp.par.pre_finalize62:                           ; preds = %omp.region.cont68
  br label %omp.par.outlined.exit96.exitStub

omp_loop.body74:                                  ; preds = %omp_loop.cond73
  %9 = add i64 %omp_loop.iv78, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 64
  br label %omp.wsloop.region82

omp.wsloop.region82:                              ; preds = %omp_loop.body74
  br label %omp.wsloop.region83

omp.wsloop.region83:                              ; preds = %omp.wsloop.region87, %omp.wsloop.region82
  %12 = phi i64 [ %19, %omp.wsloop.region87 ], [ 0, %omp.wsloop.region82 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region84, label %omp.wsloop.region88

omp.wsloop.region88:                              ; preds = %omp.wsloop.region83
  br label %omp.region.cont81

omp.region.cont81:                                ; preds = %omp.wsloop.region88
  br label %omp_loop.inc75

omp_loop.inc75:                                   ; preds = %omp.region.cont81
  %omp_loop.next80 = add nuw i64 %omp_loop.iv78, 1
  br label %omp_loop.header72

omp.wsloop.region84:                              ; preds = %omp.wsloop.region83
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region85

omp.wsloop.region85:                              ; preds = %omp.wsloop.region86, %omp.wsloop.region84
  %17 = phi i64 [ %38, %omp.wsloop.region86 ], [ 0, %omp.wsloop.region84 ]
  %18 = icmp slt i64 %17, 128
  br i1 %18, label %omp.wsloop.region86, label %omp.wsloop.region87

omp.wsloop.region87:                              ; preds = %omp.wsloop.region85
  %19 = add i64 %12, 1
  br label %omp.wsloop.region83

omp.wsloop.region86:                              ; preds = %omp.wsloop.region85
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
  br label %omp.wsloop.region85

omp.par.outlined.exit96.exitStub:                 ; preds = %omp.par.pre_finalize62
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.1(ptr noalias %tid.addr15, ptr noalias %zero.addr16, ptr %0) #0 {
omp.par.entry17:
  %gep_.reloaded54 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded54 = load ptr, ptr %gep_.reloaded54, align 8
  %gep_.reloaded55 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded55 = load ptr, ptr %gep_.reloaded55, align 8
  %gep_.reloaded56 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded56 = load ptr, ptr %gep_.reloaded56, align 8
  %p.lastiter46 = alloca i32, align 4
  %p.lowerbound47 = alloca i64, align 8
  %p.upperbound48 = alloca i64, align 8
  %p.stride49 = alloca i64, align 8
  %tid.addr.local20 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr15, align 4
  store i32 %1, ptr %tid.addr.local20, align 4
  %tid21 = load i32, ptr %tid.addr.local20, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded54, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded55, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded56, align 8
  br label %omp.region.after_alloca27

omp.region.after_alloca27:                        ; preds = %omp.par.entry17
  br label %omp.region.after_alloca24

omp.region.after_alloca24:                        ; preds = %omp.region.after_alloca27
  br label %omp.par.region18

omp.par.region18:                                 ; preds = %omp.region.after_alloca24
  br label %omp.par.region26

omp.par.region26:                                 ; preds = %omp.par.region18
  br label %omp_loop.preheader28

omp_loop.preheader28:                             ; preds = %omp.par.region26
  store i64 0, ptr %p.lowerbound47, align 4
  store i64 63, ptr %p.upperbound48, align 4
  store i64 1, ptr %p.stride49, align 4
  %omp_global_thread_num50 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num50, i32 34, ptr %p.lastiter46, ptr %p.lowerbound47, ptr %p.upperbound48, ptr %p.stride49, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound47, align 4
  %6 = load i64, ptr %p.upperbound48, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header29

omp_loop.header29:                                ; preds = %omp_loop.inc32, %omp_loop.preheader28
  %omp_loop.iv35 = phi i64 [ 0, %omp_loop.preheader28 ], [ %omp_loop.next37, %omp_loop.inc32 ]
  br label %omp_loop.cond30

omp_loop.cond30:                                  ; preds = %omp_loop.header29
  %omp_loop.cmp36 = icmp ult i64 %omp_loop.iv35, %8
  br i1 %omp_loop.cmp36, label %omp_loop.body31, label %omp_loop.exit33

omp_loop.exit33:                                  ; preds = %omp_loop.cond30
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num50)
  %omp_global_thread_num51 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num51)
  br label %omp_loop.after34

omp_loop.after34:                                 ; preds = %omp_loop.exit33
  br label %omp.region.cont25

omp.region.cont25:                                ; preds = %omp_loop.after34
  br label %omp.par.pre_finalize19

omp.par.pre_finalize19:                           ; preds = %omp.region.cont25
  br label %omp.par.outlined.exit53.exitStub

omp_loop.body31:                                  ; preds = %omp_loop.cond30
  %9 = add i64 %omp_loop.iv35, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.wsloop.region39

omp.wsloop.region39:                              ; preds = %omp_loop.body31
  br label %omp.wsloop.region40

omp.wsloop.region40:                              ; preds = %omp.wsloop.region44, %omp.wsloop.region39
  %12 = phi i64 [ %19, %omp.wsloop.region44 ], [ 0, %omp.wsloop.region39 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region41, label %omp.wsloop.region45

omp.wsloop.region45:                              ; preds = %omp.wsloop.region40
  br label %omp.region.cont38

omp.region.cont38:                                ; preds = %omp.wsloop.region45
  br label %omp_loop.inc32

omp_loop.inc32:                                   ; preds = %omp.region.cont38
  %omp_loop.next37 = add nuw i64 %omp_loop.iv35, 1
  br label %omp_loop.header29

omp.wsloop.region41:                              ; preds = %omp.wsloop.region40
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region42

omp.wsloop.region42:                              ; preds = %omp.wsloop.region43, %omp.wsloop.region41
  %17 = phi i64 [ %38, %omp.wsloop.region43 ], [ 0, %omp.wsloop.region41 ]
  %18 = icmp slt i64 %17, 128
  br i1 %18, label %omp.wsloop.region43, label %omp.wsloop.region44

omp.wsloop.region44:                              ; preds = %omp.wsloop.region42
  %19 = add i64 %12, 1
  br label %omp.wsloop.region40

omp.wsloop.region43:                              ; preds = %omp.wsloop.region42
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
  br label %omp.wsloop.region42

omp.par.outlined.exit53.exitStub:                 ; preds = %omp.par.pre_finalize19
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8
  %gep_.reloaded12 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded12 = load ptr, ptr %gep_.reloaded12, align 8
  %gep_.reloaded13 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded13 = load ptr, ptr %gep_.reloaded13, align 8
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
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded13, align 8
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
  %omp_global_thread_num10 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num10, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound, align 4
  %6 = load i64, ptr %p.upperbound, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header

omp_loop.header:                                  ; preds = %omp_loop.inc, %omp_loop.preheader
  %omp_loop.iv = phi i64 [ 0, %omp_loop.preheader ], [ %omp_loop.next, %omp_loop.inc ]
  br label %omp_loop.cond

omp_loop.cond:                                    ; preds = %omp_loop.header
  %omp_loop.cmp = icmp ult i64 %omp_loop.iv, %8
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
  %9 = add i64 %omp_loop.iv, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 64
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp_loop.body
  br label %omp.wsloop.region4

omp.wsloop.region4:                               ; preds = %omp.wsloop.region8, %omp.wsloop.region
  %12 = phi i64 [ %19, %omp.wsloop.region8 ], [ 0, %omp.wsloop.region ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region5, label %omp.wsloop.region9

omp.wsloop.region9:                               ; preds = %omp.wsloop.region4
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp.wsloop.region9
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont3
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.wsloop.region5:                               ; preds = %omp.wsloop.region4
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region6

omp.wsloop.region6:                               ; preds = %omp.wsloop.region7, %omp.wsloop.region5
  %17 = phi i64 [ %38, %omp.wsloop.region7 ], [ 0, %omp.wsloop.region5 ]
  %18 = icmp slt i64 %17, 128
  br i1 %18, label %omp.wsloop.region7, label %omp.wsloop.region8

omp.wsloop.region8:                               ; preds = %omp.wsloop.region6
  %19 = add i64 %12, 1
  br label %omp.wsloop.region4

omp.wsloop.region7:                               ; preds = %omp.wsloop.region6
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
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
