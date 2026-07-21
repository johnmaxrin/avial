; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

%struct.ident_t = type { i32, i32, i32, i32, ptr }

@arch_str_3 = internal constant [7 x i8] c"x86_64\00"
@node_str_3 = internal constant [6 x i8] c"node3\00"
@arch_str_2 = internal constant [7 x i8] c"x86_64\00"
@node_str_2 = internal constant [6 x i8] c"node2\00"
@arch_str_1 = internal constant [7 x i8] c"x86_64\00"
@node_str_1 = internal constant [6 x i8] c"node1\00"
@arch_str_0 = internal constant [7 x i8] c"x86_64\00"
@node_str_0 = internal constant [6 x i8] c"node0\00"
@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8

declare i32 @MPI_Send(ptr, i32, i32, i32, i32, i32)

declare i32 @MPI_Recv(ptr, i32, i32, i32, i32, i32, ptr)

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

declare ptr @malloc(i64)

declare void @buildRankNodeMaps(ptr, ptr, ptr)

define void @kernel_jacobi_2d(i32 %0, i32 %1, ptr %2, ptr %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, i64 %11, i64 %12, i64 %13, i64 %14, i64 %15) {
  %structArg324 = alloca { ptr, ptr }, align 8
  %structArg320 = alloca { ptr, ptr }, align 8
  %structArg316 = alloca { ptr, ptr }, align 8
  %structArg312 = alloca { ptr, ptr }, align 8
  %structArg308 = alloca { ptr, ptr }, align 8
  %structArg304 = alloca { ptr, ptr }, align 8
  %structArg300 = alloca { ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr }, align 8
  %17 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %9, 0
  %18 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %17, ptr %10, 1
  %19 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %18, i64 %11, 2
  %20 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %19, i64 %12, 3, 0
  %21 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %20, i64 %14, 4, 0
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %21, i64 %13, 3, 1
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, i64 %15, 4, 1
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %2, 0
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, ptr %3, 1
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, i64 %4, 2
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %5, 3, 0
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %7, 4, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %6, 3, 1
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %8, 4, 1
  %31 = call i32 @MPI_Init(ptr null, ptr null)
  %32 = alloca i32, align 4
  %33 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %32)
  %34 = load i32, ptr %32, align 4
  %35 = alloca i32, align 4
  %36 = call i32 @MPI_Comm_size(i32 1140850688, ptr %35)
  %37 = load i32, ptr %35, align 4
  %38 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %39 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 0
  %40 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 1
  %41 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 2
  %42 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 3
  store ptr @node_str_0, ptr %39, align 8
  store ptr @arch_str_0, ptr %40, align 8
  store i32 0, ptr %41, align 4
  store float 1.000000e+00, ptr %42, align 4
  %43 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 1
  %44 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 0
  %45 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 1
  %46 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 2
  %47 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 3
  store ptr @node_str_1, ptr %44, align 8
  store ptr @arch_str_1, ptr %45, align 8
  store i32 0, ptr %46, align 4
  store float 1.000000e+00, ptr %47, align 4
  %48 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 2
  %49 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 0
  %50 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 1
  %51 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 2
  %52 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 3
  store ptr @node_str_2, ptr %49, align 8
  store ptr @arch_str_2, ptr %50, align 8
  store i32 0, ptr %51, align 4
  store float 1.000000e+00, ptr %52, align 4
  %53 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 3
  %54 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 0
  %55 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 1
  %56 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 2
  %57 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 3
  store ptr @node_str_3, ptr %54, align 8
  store ptr @arch_str_3, ptr %55, align 8
  store i32 0, ptr %56, align 4
  store float 1.000000e+00, ptr %57, align 4
  %58 = alloca { i32, ptr }, i64 1, align 8
  %59 = getelementptr { i32, ptr }, ptr %58, i32 0, i32 0
  %60 = getelementptr { i32, ptr }, ptr %58, i32 0, i32 1
  store i32 4, ptr %59, align 4
  store ptr %38, ptr %60, align 8
  %61 = call ptr @malloc(i64 16)
  %62 = call ptr @malloc(i64 16)
  %63 = ptrtoint ptr %61 to i64
  %64 = ptrtoint ptr %62 to i64
  %65 = inttoptr i64 %63 to ptr
  %66 = inttoptr i64 %64 to ptr
  call void @buildRankNodeMaps(ptr %58, ptr %65, ptr %66)
  %67 = sext i32 %34 to i64
  %68 = getelementptr inbounds nuw i32, ptr %61, i64 %67
  %69 = load i32, ptr %68, align 4
  br label %70

70:                                               ; preds = %439, %16
  %71 = phi i64 [ %440, %439 ], [ 0, %16 ]
  %72 = icmp slt i64 %71, 300
  br i1 %72, label %73, label %441

73:                                               ; preds = %70
  %74 = icmp eq i32 %69, 0
  br i1 %74, label %75, label %76

75:                                               ; preds = %73
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel

omp_parallel:                                     ; preds = %75
  %gep_ = getelementptr { ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %3, ptr %gep_, align 8
  %gep_299 = getelementptr { ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %10, ptr %gep_299, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %76

76:                                               ; preds = %omp.par.exit, %73
  %77 = icmp eq i32 %69, 1
  br i1 %77, label %78, label %79

78:                                               ; preds = %76
  %omp_global_thread_num12 = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel303

omp_parallel303:                                  ; preds = %78
  %gep_301 = getelementptr { ptr, ptr }, ptr %structArg300, i32 0, i32 0
  store ptr %3, ptr %gep_301, align 8
  %gep_302 = getelementptr { ptr, ptr }, ptr %structArg300, i32 0, i32 1
  store ptr %10, ptr %gep_302, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par.1, ptr %structArg300)
  br label %omp.par.exit18

omp.par.exit18:                                   ; preds = %omp_parallel303
  br label %79

79:                                               ; preds = %omp.par.exit18, %76
  %80 = icmp eq i32 %69, 2
  br i1 %80, label %81, label %82

81:                                               ; preds = %79
  %omp_global_thread_num53 = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel307

omp_parallel307:                                  ; preds = %81
  %gep_305 = getelementptr { ptr, ptr }, ptr %structArg304, i32 0, i32 0
  store ptr %3, ptr %gep_305, align 8
  %gep_306 = getelementptr { ptr, ptr }, ptr %structArg304, i32 0, i32 1
  store ptr %10, ptr %gep_306, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par.2, ptr %structArg304)
  br label %omp.par.exit59

omp.par.exit59:                                   ; preds = %omp_parallel307
  br label %82

82:                                               ; preds = %omp.par.exit59, %79
  %83 = icmp eq i32 %69, 3
  br i1 %83, label %84, label %85

84:                                               ; preds = %82
  %omp_global_thread_num94 = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel311

omp_parallel311:                                  ; preds = %84
  %gep_309 = getelementptr { ptr, ptr }, ptr %structArg308, i32 0, i32 0
  store ptr %3, ptr %gep_309, align 8
  %gep_310 = getelementptr { ptr, ptr }, ptr %structArg308, i32 0, i32 1
  store ptr %10, ptr %gep_310, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par.3, ptr %structArg308)
  br label %omp.par.exit100

omp.par.exit100:                                  ; preds = %omp_parallel311
  br label %85

85:                                               ; preds = %omp.par.exit100, %82
  %86 = call i32 @MPI_Barrier(i32 1140850688)
  %87 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 0
  %88 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 1
  %89 = insertvalue { ptr, ptr, i64 } poison, ptr %87, 0
  %90 = insertvalue { ptr, ptr, i64 } %89, ptr %88, 1
  %91 = insertvalue { ptr, ptr, i64 } %90, i64 0, 2
  %92 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 2
  %93 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 0
  %94 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 1
  %95 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 0
  %96 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 1
  %97 = extractvalue { ptr, ptr, i64 } %91, 0
  %98 = extractvalue { ptr, ptr, i64 } %91, 1
  %99 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %97, 0
  %100 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %99, ptr %98, 1
  %101 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %100, i64 768, 2
  %102 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %101, i64 5, 3, 0
  %103 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %102, i64 128, 4, 0
  %104 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, i64 128, 3, 1
  %105 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %104, i64 1, 4, 1
  %106 = load i32, ptr %62, align 4
  %107 = getelementptr inbounds nuw i32, ptr %62, i32 1
  %108 = load i32, ptr %107, align 4
  %109 = icmp eq i32 %34, %106
  %110 = icmp eq i32 %34, %108
  br i1 %109, label %111, label %118

111:                                              ; preds = %85
  %112 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, 1
  %113 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, 2
  %114 = getelementptr float, ptr %112, i64 %113
  %115 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, 3, 0
  %116 = trunc i64 %115 to i32
  %117 = call i32 @MPI_Recv(ptr %114, i32 %116, i32 1275069450, i32 %108, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %127

118:                                              ; preds = %85
  br i1 %110, label %119, label %126

119:                                              ; preds = %118
  %120 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, 1
  %121 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, 2
  %122 = getelementptr float, ptr %120, i64 %121
  %123 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, 3, 0
  %124 = trunc i64 %123 to i32
  %125 = call i32 @MPI_Send(ptr %122, i32 %124, i32 1275069450, i32 %106, i32 0, i32 1140850688)
  br label %126

126:                                              ; preds = %119, %118
  br label %127

127:                                              ; preds = %111, %126
  %128 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 0
  %129 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 1
  %130 = insertvalue { ptr, ptr, i64 } poison, ptr %128, 0
  %131 = insertvalue { ptr, ptr, i64 } %130, ptr %129, 1
  %132 = insertvalue { ptr, ptr, i64 } %131, i64 0, 2
  %133 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 2
  %134 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 0
  %135 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 1
  %136 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 0
  %137 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 1
  %138 = extractvalue { ptr, ptr, i64 } %132, 0
  %139 = extractvalue { ptr, ptr, i64 } %132, 1
  %140 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %138, 0
  %141 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %140, ptr %139, 1
  %142 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %141, i64 1408, 2
  %143 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %142, i64 4, 3, 0
  %144 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %143, i64 128, 4, 0
  %145 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %144, i64 128, 3, 1
  %146 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %145, i64 1, 4, 1
  %147 = load i32, ptr %62, align 4
  %148 = getelementptr inbounds nuw i32, ptr %62, i32 2
  %149 = load i32, ptr %148, align 4
  %150 = icmp eq i32 %34, %147
  %151 = icmp eq i32 %34, %149
  br i1 %150, label %152, label %159

152:                                              ; preds = %127
  %153 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, 1
  %154 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, 2
  %155 = getelementptr float, ptr %153, i64 %154
  %156 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, 3, 0
  %157 = trunc i64 %156 to i32
  %158 = call i32 @MPI_Recv(ptr %155, i32 %157, i32 1275069450, i32 %149, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %168

159:                                              ; preds = %127
  br i1 %151, label %160, label %167

160:                                              ; preds = %159
  %161 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, 1
  %162 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, 2
  %163 = getelementptr float, ptr %161, i64 %162
  %164 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, 3, 0
  %165 = trunc i64 %164 to i32
  %166 = call i32 @MPI_Send(ptr %163, i32 %165, i32 1275069450, i32 %147, i32 0, i32 1140850688)
  br label %167

167:                                              ; preds = %160, %159
  br label %168

168:                                              ; preds = %152, %167
  %169 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 0
  %170 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 1
  %171 = insertvalue { ptr, ptr, i64 } poison, ptr %169, 0
  %172 = insertvalue { ptr, ptr, i64 } %171, ptr %170, 1
  %173 = insertvalue { ptr, ptr, i64 } %172, i64 0, 2
  %174 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 2
  %175 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 0
  %176 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 1
  %177 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 0
  %178 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 1
  %179 = extractvalue { ptr, ptr, i64 } %173, 0
  %180 = extractvalue { ptr, ptr, i64 } %173, 1
  %181 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %179, 0
  %182 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %181, ptr %180, 1
  %183 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %182, i64 1920, 2
  %184 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %183, i64 4, 3, 0
  %185 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %184, i64 128, 4, 0
  %186 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, i64 128, 3, 1
  %187 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %186, i64 1, 4, 1
  %188 = load i32, ptr %62, align 4
  %189 = getelementptr inbounds nuw i32, ptr %62, i32 3
  %190 = load i32, ptr %189, align 4
  %191 = icmp eq i32 %34, %188
  %192 = icmp eq i32 %34, %190
  br i1 %191, label %193, label %200

193:                                              ; preds = %168
  %194 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, 1
  %195 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, 2
  %196 = getelementptr float, ptr %194, i64 %195
  %197 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, 3, 0
  %198 = trunc i64 %197 to i32
  %199 = call i32 @MPI_Recv(ptr %196, i32 %198, i32 1275069450, i32 %190, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %209

200:                                              ; preds = %168
  br i1 %192, label %201, label %208

201:                                              ; preds = %200
  %202 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, 1
  %203 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, 2
  %204 = getelementptr float, ptr %202, i64 %203
  %205 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, 3, 0
  %206 = trunc i64 %205 to i32
  %207 = call i32 @MPI_Send(ptr %204, i32 %206, i32 1275069450, i32 %188, i32 0, i32 1140850688)
  br label %208

208:                                              ; preds = %201, %200
  br label %209

209:                                              ; preds = %193, %208
  %210 = load i32, ptr %62, align 4
  %211 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 0
  %212 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 1
  %213 = insertvalue { ptr, ptr, i64 } poison, ptr %211, 0
  %214 = insertvalue { ptr, ptr, i64 } %213, ptr %212, 1
  %215 = insertvalue { ptr, ptr, i64 } %214, i64 0, 2
  %216 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 2
  %217 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 0
  %218 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 3, 1
  %219 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 0
  %220 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, 4, 1
  %221 = extractvalue { ptr, ptr, i64 } %215, 0
  %222 = extractvalue { ptr, ptr, i64 } %215, 1
  %223 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %221, 0
  %224 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, ptr %222, 1
  %225 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %224, i64 128, 2
  %226 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %225, i64 18, 3, 0
  %227 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %226, i64 128, 4, 0
  %228 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %227, i64 128, 3, 1
  %229 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %228, i64 1, 4, 1
  %230 = icmp eq i32 %34, %210
  br i1 %230, label %231, label %249

231:                                              ; preds = %209
  %232 = sext i32 %37 to i64
  br label %233

233:                                              ; preds = %246, %231
  %234 = phi i64 [ %247, %246 ], [ 0, %231 ]
  %235 = icmp slt i64 %234, %232
  br i1 %235, label %236, label %248

236:                                              ; preds = %233
  %237 = trunc i64 %234 to i32
  %238 = icmp ne i32 %237, %210
  br i1 %238, label %239, label %246

239:                                              ; preds = %236
  %240 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %229, 1
  %241 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %229, 2
  %242 = getelementptr float, ptr %240, i64 %241
  %243 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %229, 3, 0
  %244 = trunc i64 %243 to i32
  %245 = call i32 @MPI_Send(ptr %242, i32 %244, i32 1275069450, i32 %237, i32 0, i32 1140850688)
  br label %246

246:                                              ; preds = %239, %236
  %247 = add i64 %234, 1
  br label %233

248:                                              ; preds = %233
  br label %256

249:                                              ; preds = %209
  %250 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %229, 1
  %251 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %229, 2
  %252 = getelementptr float, ptr %250, i64 %251
  %253 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %229, 3, 0
  %254 = trunc i64 %253 to i32
  %255 = call i32 @MPI_Recv(ptr %252, i32 %254, i32 1275069450, i32 %210, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %256

256:                                              ; preds = %248, %249
  %257 = icmp eq i32 %69, 0
  br i1 %257, label %258, label %259

258:                                              ; preds = %256
  %omp_global_thread_num135 = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel315

omp_parallel315:                                  ; preds = %258
  %gep_313 = getelementptr { ptr, ptr }, ptr %structArg312, i32 0, i32 0
  store ptr %10, ptr %gep_313, align 8
  %gep_314 = getelementptr { ptr, ptr }, ptr %structArg312, i32 0, i32 1
  store ptr %3, ptr %gep_314, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par.4, ptr %structArg312)
  br label %omp.par.exit141

omp.par.exit141:                                  ; preds = %omp_parallel315
  br label %259

259:                                              ; preds = %omp.par.exit141, %256
  %260 = icmp eq i32 %69, 1
  br i1 %260, label %261, label %262

261:                                              ; preds = %259
  %omp_global_thread_num176 = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel319

omp_parallel319:                                  ; preds = %261
  %gep_317 = getelementptr { ptr, ptr }, ptr %structArg316, i32 0, i32 0
  store ptr %10, ptr %gep_317, align 8
  %gep_318 = getelementptr { ptr, ptr }, ptr %structArg316, i32 0, i32 1
  store ptr %3, ptr %gep_318, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par.5, ptr %structArg316)
  br label %omp.par.exit182

omp.par.exit182:                                  ; preds = %omp_parallel319
  br label %262

262:                                              ; preds = %omp.par.exit182, %259
  %263 = icmp eq i32 %69, 2
  br i1 %263, label %264, label %265

264:                                              ; preds = %262
  %omp_global_thread_num217 = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel323

omp_parallel323:                                  ; preds = %264
  %gep_321 = getelementptr { ptr, ptr }, ptr %structArg320, i32 0, i32 0
  store ptr %10, ptr %gep_321, align 8
  %gep_322 = getelementptr { ptr, ptr }, ptr %structArg320, i32 0, i32 1
  store ptr %3, ptr %gep_322, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par.6, ptr %structArg320)
  br label %omp.par.exit223

omp.par.exit223:                                  ; preds = %omp_parallel323
  br label %265

265:                                              ; preds = %omp.par.exit223, %262
  %266 = icmp eq i32 %69, 3
  br i1 %266, label %267, label %268

267:                                              ; preds = %265
  %omp_global_thread_num258 = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel327

omp_parallel327:                                  ; preds = %267
  %gep_325 = getelementptr { ptr, ptr }, ptr %structArg324, i32 0, i32 0
  store ptr %10, ptr %gep_325, align 8
  %gep_326 = getelementptr { ptr, ptr }, ptr %structArg324, i32 0, i32 1
  store ptr %3, ptr %gep_326, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_jacobi_2d..omp_par.7, ptr %structArg324)
  br label %omp.par.exit264

omp.par.exit264:                                  ; preds = %omp_parallel327
  br label %268

268:                                              ; preds = %omp.par.exit264, %265
  %269 = call i32 @MPI_Barrier(i32 1140850688)
  %270 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 0
  %271 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 1
  %272 = insertvalue { ptr, ptr, i64 } poison, ptr %270, 0
  %273 = insertvalue { ptr, ptr, i64 } %272, ptr %271, 1
  %274 = insertvalue { ptr, ptr, i64 } %273, i64 0, 2
  %275 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 2
  %276 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 0
  %277 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 1
  %278 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 0
  %279 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 1
  %280 = extractvalue { ptr, ptr, i64 } %274, 0
  %281 = extractvalue { ptr, ptr, i64 } %274, 1
  %282 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %280, 0
  %283 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %282, ptr %281, 1
  %284 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %283, i64 768, 2
  %285 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %284, i64 5, 3, 0
  %286 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %285, i64 128, 4, 0
  %287 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %286, i64 128, 3, 1
  %288 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %287, i64 1, 4, 1
  %289 = load i32, ptr %62, align 4
  %290 = getelementptr inbounds nuw i32, ptr %62, i32 1
  %291 = load i32, ptr %290, align 4
  %292 = icmp eq i32 %34, %289
  %293 = icmp eq i32 %34, %291
  br i1 %292, label %294, label %301

294:                                              ; preds = %268
  %295 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %288, 1
  %296 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %288, 2
  %297 = getelementptr float, ptr %295, i64 %296
  %298 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %288, 3, 0
  %299 = trunc i64 %298 to i32
  %300 = call i32 @MPI_Recv(ptr %297, i32 %299, i32 1275069450, i32 %291, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %310

301:                                              ; preds = %268
  br i1 %293, label %302, label %309

302:                                              ; preds = %301
  %303 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %288, 1
  %304 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %288, 2
  %305 = getelementptr float, ptr %303, i64 %304
  %306 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %288, 3, 0
  %307 = trunc i64 %306 to i32
  %308 = call i32 @MPI_Send(ptr %305, i32 %307, i32 1275069450, i32 %289, i32 0, i32 1140850688)
  br label %309

309:                                              ; preds = %302, %301
  br label %310

310:                                              ; preds = %294, %309
  %311 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 0
  %312 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 1
  %313 = insertvalue { ptr, ptr, i64 } poison, ptr %311, 0
  %314 = insertvalue { ptr, ptr, i64 } %313, ptr %312, 1
  %315 = insertvalue { ptr, ptr, i64 } %314, i64 0, 2
  %316 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 2
  %317 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 0
  %318 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 1
  %319 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 0
  %320 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 1
  %321 = extractvalue { ptr, ptr, i64 } %315, 0
  %322 = extractvalue { ptr, ptr, i64 } %315, 1
  %323 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %321, 0
  %324 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %323, ptr %322, 1
  %325 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %324, i64 1408, 2
  %326 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %325, i64 4, 3, 0
  %327 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %326, i64 128, 4, 0
  %328 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %327, i64 128, 3, 1
  %329 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %328, i64 1, 4, 1
  %330 = load i32, ptr %62, align 4
  %331 = getelementptr inbounds nuw i32, ptr %62, i32 2
  %332 = load i32, ptr %331, align 4
  %333 = icmp eq i32 %34, %330
  %334 = icmp eq i32 %34, %332
  br i1 %333, label %335, label %342

335:                                              ; preds = %310
  %336 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %329, 1
  %337 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %329, 2
  %338 = getelementptr float, ptr %336, i64 %337
  %339 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %329, 3, 0
  %340 = trunc i64 %339 to i32
  %341 = call i32 @MPI_Recv(ptr %338, i32 %340, i32 1275069450, i32 %332, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %351

342:                                              ; preds = %310
  br i1 %334, label %343, label %350

343:                                              ; preds = %342
  %344 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %329, 1
  %345 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %329, 2
  %346 = getelementptr float, ptr %344, i64 %345
  %347 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %329, 3, 0
  %348 = trunc i64 %347 to i32
  %349 = call i32 @MPI_Send(ptr %346, i32 %348, i32 1275069450, i32 %330, i32 0, i32 1140850688)
  br label %350

350:                                              ; preds = %343, %342
  br label %351

351:                                              ; preds = %335, %350
  %352 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 0
  %353 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 1
  %354 = insertvalue { ptr, ptr, i64 } poison, ptr %352, 0
  %355 = insertvalue { ptr, ptr, i64 } %354, ptr %353, 1
  %356 = insertvalue { ptr, ptr, i64 } %355, i64 0, 2
  %357 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 2
  %358 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 0
  %359 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 1
  %360 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 0
  %361 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 1
  %362 = extractvalue { ptr, ptr, i64 } %356, 0
  %363 = extractvalue { ptr, ptr, i64 } %356, 1
  %364 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %362, 0
  %365 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %364, ptr %363, 1
  %366 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %365, i64 1920, 2
  %367 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %366, i64 4, 3, 0
  %368 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %367, i64 128, 4, 0
  %369 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %368, i64 128, 3, 1
  %370 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %369, i64 1, 4, 1
  %371 = load i32, ptr %62, align 4
  %372 = getelementptr inbounds nuw i32, ptr %62, i32 3
  %373 = load i32, ptr %372, align 4
  %374 = icmp eq i32 %34, %371
  %375 = icmp eq i32 %34, %373
  br i1 %374, label %376, label %383

376:                                              ; preds = %351
  %377 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 1
  %378 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 2
  %379 = getelementptr float, ptr %377, i64 %378
  %380 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 3, 0
  %381 = trunc i64 %380 to i32
  %382 = call i32 @MPI_Recv(ptr %379, i32 %381, i32 1275069450, i32 %373, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %392

383:                                              ; preds = %351
  br i1 %375, label %384, label %391

384:                                              ; preds = %383
  %385 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 1
  %386 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 2
  %387 = getelementptr float, ptr %385, i64 %386
  %388 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 3, 0
  %389 = trunc i64 %388 to i32
  %390 = call i32 @MPI_Send(ptr %387, i32 %389, i32 1275069450, i32 %371, i32 0, i32 1140850688)
  br label %391

391:                                              ; preds = %384, %383
  br label %392

392:                                              ; preds = %376, %391
  %393 = load i32, ptr %62, align 4
  %394 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 0
  %395 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 1
  %396 = insertvalue { ptr, ptr, i64 } poison, ptr %394, 0
  %397 = insertvalue { ptr, ptr, i64 } %396, ptr %395, 1
  %398 = insertvalue { ptr, ptr, i64 } %397, i64 0, 2
  %399 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 2
  %400 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 0
  %401 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 3, 1
  %402 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 0
  %403 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, 4, 1
  %404 = extractvalue { ptr, ptr, i64 } %398, 0
  %405 = extractvalue { ptr, ptr, i64 } %398, 1
  %406 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %404, 0
  %407 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %406, ptr %405, 1
  %408 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %407, i64 128, 2
  %409 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %408, i64 18, 3, 0
  %410 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %409, i64 128, 4, 0
  %411 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %410, i64 128, 3, 1
  %412 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %411, i64 1, 4, 1
  %413 = icmp eq i32 %34, %393
  br i1 %413, label %414, label %432

414:                                              ; preds = %392
  %415 = sext i32 %37 to i64
  br label %416

416:                                              ; preds = %429, %414
  %417 = phi i64 [ %430, %429 ], [ 0, %414 ]
  %418 = icmp slt i64 %417, %415
  br i1 %418, label %419, label %431

419:                                              ; preds = %416
  %420 = trunc i64 %417 to i32
  %421 = icmp ne i32 %420, %393
  br i1 %421, label %422, label %429

422:                                              ; preds = %419
  %423 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %412, 1
  %424 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %412, 2
  %425 = getelementptr float, ptr %423, i64 %424
  %426 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %412, 3, 0
  %427 = trunc i64 %426 to i32
  %428 = call i32 @MPI_Send(ptr %425, i32 %427, i32 1275069450, i32 %420, i32 0, i32 1140850688)
  br label %429

429:                                              ; preds = %422, %419
  %430 = add i64 %417, 1
  br label %416

431:                                              ; preds = %416
  br label %439

432:                                              ; preds = %392
  %433 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %412, 1
  %434 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %412, 2
  %435 = getelementptr float, ptr %433, i64 %434
  %436 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %412, 3, 0
  %437 = trunc i64 %436 to i32
  %438 = call i32 @MPI_Recv(ptr %435, i32 %437, i32 1275069450, i32 %393, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %439

439:                                              ; preds = %431, %432
  %440 = add i64 %71, 1
  br label %70

441:                                              ; preds = %70
  %442 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par.7(ptr noalias %tid.addr259, ptr noalias %zero.addr260, ptr %0) #0 {
omp.par.entry261:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter292 = alloca i32, align 4
  %p.lowerbound293 = alloca i64, align 8
  %p.upperbound294 = alloca i64, align 8
  %p.stride295 = alloca i64, align 8
  %tid.addr.local265 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr259, align 4
  store i32 %1, ptr %tid.addr.local265, align 4
  %tid266 = load i32, ptr %tid.addr.local265, align 4
  br label %omp.region.after_alloca272

omp.region.after_alloca272:                       ; preds = %omp.par.entry261
  br label %omp.region.after_alloca269

omp.region.after_alloca269:                       ; preds = %omp.region.after_alloca272
  br label %omp.par.region262

omp.par.region262:                                ; preds = %omp.region.after_alloca269
  br label %omp.par.region271

omp.par.region271:                                ; preds = %omp.par.region262
  br label %omp.wsloop.region274

omp.wsloop.region274:                             ; preds = %omp.par.region271
  br label %omp_loop.preheader275

omp_loop.preheader275:                            ; preds = %omp.wsloop.region274
  store i64 0, ptr %p.lowerbound293, align 4
  store i64 3, ptr %p.upperbound294, align 4
  store i64 1, ptr %p.stride295, align 4
  %omp_global_thread_num296 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num296, i32 34, ptr %p.lastiter292, ptr %p.lowerbound293, ptr %p.upperbound294, ptr %p.stride295, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound293, align 4
  %3 = load i64, ptr %p.upperbound294, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header276

omp_loop.header276:                               ; preds = %omp_loop.inc279, %omp_loop.preheader275
  %omp_loop.iv282 = phi i64 [ 0, %omp_loop.preheader275 ], [ %omp_loop.next284, %omp_loop.inc279 ]
  br label %omp_loop.cond277

omp_loop.cond277:                                 ; preds = %omp_loop.header276
  %omp_loop.cmp283 = icmp ult i64 %omp_loop.iv282, %5
  br i1 %omp_loop.cmp283, label %omp_loop.body278, label %omp_loop.exit280

omp_loop.exit280:                                 ; preds = %omp_loop.cond277
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num296)
  %omp_global_thread_num297 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num297)
  br label %omp_loop.after281

omp_loop.after281:                                ; preds = %omp_loop.exit280
  br label %omp.region.cont273

omp.region.cont273:                               ; preds = %omp_loop.after281
  br label %omp.region.cont270

omp.region.cont270:                               ; preds = %omp.region.cont273
  br label %omp.par.pre_finalize263

omp.par.pre_finalize263:                          ; preds = %omp.region.cont270
  br label %.fini298

.fini298:                                         ; preds = %omp.par.pre_finalize263
  br label %omp.par.exit264.exitStub

omp_loop.body278:                                 ; preds = %omp_loop.cond277
  %6 = add i64 %omp_loop.iv282, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 0
  br label %omp.loop_nest.region286

omp.loop_nest.region286:                          ; preds = %omp_loop.body278
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region287

omp.loop_nest.region287:                          ; preds = %omp.loop_nest.region286
  br label %omp.loop_nest.region288

omp.loop_nest.region288:                          ; preds = %omp.loop_nest.region289, %omp.loop_nest.region287
  %10 = phi i64 [ %19, %omp.loop_nest.region289 ], [ 1, %omp.loop_nest.region287 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region289, label %omp.loop_nest.region290

omp.loop_nest.region290:                          ; preds = %omp.loop_nest.region288
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region291

omp.loop_nest.region291:                          ; preds = %omp.loop_nest.region290
  br label %omp.region.cont285

omp.region.cont285:                               ; preds = %omp.loop_nest.region291
  br label %omp_loop.inc279

omp_loop.inc279:                                  ; preds = %omp.region.cont285
  %omp_loop.next284 = add nuw i64 %omp_loop.iv282, 1
  br label %omp_loop.header276

omp.loop_nest.region289:                          ; preds = %omp.loop_nest.region288
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = mul nuw nsw i64 %8, 128
  %17 = add nuw nsw i64 %16, %10
  %18 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %17
  store float %15, ptr %18, align 4
  %19 = add i64 %10, 1
  br label %omp.loop_nest.region288

omp.par.exit264.exitStub:                         ; preds = %.fini298
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par.6(ptr noalias %tid.addr218, ptr noalias %zero.addr219, ptr %0) #0 {
omp.par.entry220:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter251 = alloca i32, align 4
  %p.lowerbound252 = alloca i64, align 8
  %p.upperbound253 = alloca i64, align 8
  %p.stride254 = alloca i64, align 8
  %tid.addr.local224 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr218, align 4
  store i32 %1, ptr %tid.addr.local224, align 4
  %tid225 = load i32, ptr %tid.addr.local224, align 4
  br label %omp.region.after_alloca231

omp.region.after_alloca231:                       ; preds = %omp.par.entry220
  br label %omp.region.after_alloca228

omp.region.after_alloca228:                       ; preds = %omp.region.after_alloca231
  br label %omp.par.region221

omp.par.region221:                                ; preds = %omp.region.after_alloca228
  br label %omp.par.region230

omp.par.region230:                                ; preds = %omp.par.region221
  br label %omp.wsloop.region233

omp.wsloop.region233:                             ; preds = %omp.par.region230
  br label %omp_loop.preheader234

omp_loop.preheader234:                            ; preds = %omp.wsloop.region233
  store i64 0, ptr %p.lowerbound252, align 4
  store i64 3, ptr %p.upperbound253, align 4
  store i64 1, ptr %p.stride254, align 4
  %omp_global_thread_num255 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num255, i32 34, ptr %p.lastiter251, ptr %p.lowerbound252, ptr %p.upperbound253, ptr %p.stride254, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound252, align 4
  %3 = load i64, ptr %p.upperbound253, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header235

omp_loop.header235:                               ; preds = %omp_loop.inc238, %omp_loop.preheader234
  %omp_loop.iv241 = phi i64 [ 0, %omp_loop.preheader234 ], [ %omp_loop.next243, %omp_loop.inc238 ]
  br label %omp_loop.cond236

omp_loop.cond236:                                 ; preds = %omp_loop.header235
  %omp_loop.cmp242 = icmp ult i64 %omp_loop.iv241, %5
  br i1 %omp_loop.cmp242, label %omp_loop.body237, label %omp_loop.exit239

omp_loop.exit239:                                 ; preds = %omp_loop.cond236
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num255)
  %omp_global_thread_num256 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num256)
  br label %omp_loop.after240

omp_loop.after240:                                ; preds = %omp_loop.exit239
  br label %omp.region.cont232

omp.region.cont232:                               ; preds = %omp_loop.after240
  br label %omp.region.cont229

omp.region.cont229:                               ; preds = %omp.region.cont232
  br label %omp.par.pre_finalize222

omp.par.pre_finalize222:                          ; preds = %omp.region.cont229
  br label %.fini257

.fini257:                                         ; preds = %omp.par.pre_finalize222
  br label %omp.par.exit223.exitStub

omp_loop.body237:                                 ; preds = %omp_loop.cond236
  %6 = add i64 %omp_loop.iv241, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 0
  br label %omp.loop_nest.region245

omp.loop_nest.region245:                          ; preds = %omp_loop.body237
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region246

omp.loop_nest.region246:                          ; preds = %omp.loop_nest.region245
  br label %omp.loop_nest.region247

omp.loop_nest.region247:                          ; preds = %omp.loop_nest.region248, %omp.loop_nest.region246
  %10 = phi i64 [ %19, %omp.loop_nest.region248 ], [ 1, %omp.loop_nest.region246 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region248, label %omp.loop_nest.region249

omp.loop_nest.region249:                          ; preds = %omp.loop_nest.region247
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region250

omp.loop_nest.region250:                          ; preds = %omp.loop_nest.region249
  br label %omp.region.cont244

omp.region.cont244:                               ; preds = %omp.loop_nest.region250
  br label %omp_loop.inc238

omp_loop.inc238:                                  ; preds = %omp.region.cont244
  %omp_loop.next243 = add nuw i64 %omp_loop.iv241, 1
  br label %omp_loop.header235

omp.loop_nest.region248:                          ; preds = %omp.loop_nest.region247
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = mul nuw nsw i64 %8, 128
  %17 = add nuw nsw i64 %16, %10
  %18 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %17
  store float %15, ptr %18, align 4
  %19 = add i64 %10, 1
  br label %omp.loop_nest.region247

omp.par.exit223.exitStub:                         ; preds = %.fini257
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par.5(ptr noalias %tid.addr177, ptr noalias %zero.addr178, ptr %0) #0 {
omp.par.entry179:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter210 = alloca i32, align 4
  %p.lowerbound211 = alloca i64, align 8
  %p.upperbound212 = alloca i64, align 8
  %p.stride213 = alloca i64, align 8
  %tid.addr.local183 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr177, align 4
  store i32 %1, ptr %tid.addr.local183, align 4
  %tid184 = load i32, ptr %tid.addr.local183, align 4
  br label %omp.region.after_alloca190

omp.region.after_alloca190:                       ; preds = %omp.par.entry179
  br label %omp.region.after_alloca187

omp.region.after_alloca187:                       ; preds = %omp.region.after_alloca190
  br label %omp.par.region180

omp.par.region180:                                ; preds = %omp.region.after_alloca187
  br label %omp.par.region189

omp.par.region189:                                ; preds = %omp.par.region180
  br label %omp.wsloop.region192

omp.wsloop.region192:                             ; preds = %omp.par.region189
  br label %omp_loop.preheader193

omp_loop.preheader193:                            ; preds = %omp.wsloop.region192
  store i64 0, ptr %p.lowerbound211, align 4
  store i64 4, ptr %p.upperbound212, align 4
  store i64 1, ptr %p.stride213, align 4
  %omp_global_thread_num214 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num214, i32 34, ptr %p.lastiter210, ptr %p.lowerbound211, ptr %p.upperbound212, ptr %p.stride213, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound211, align 4
  %3 = load i64, ptr %p.upperbound212, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header194

omp_loop.header194:                               ; preds = %omp_loop.inc197, %omp_loop.preheader193
  %omp_loop.iv200 = phi i64 [ 0, %omp_loop.preheader193 ], [ %omp_loop.next202, %omp_loop.inc197 ]
  br label %omp_loop.cond195

omp_loop.cond195:                                 ; preds = %omp_loop.header194
  %omp_loop.cmp201 = icmp ult i64 %omp_loop.iv200, %5
  br i1 %omp_loop.cmp201, label %omp_loop.body196, label %omp_loop.exit198

omp_loop.exit198:                                 ; preds = %omp_loop.cond195
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num214)
  %omp_global_thread_num215 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num215)
  br label %omp_loop.after199

omp_loop.after199:                                ; preds = %omp_loop.exit198
  br label %omp.region.cont191

omp.region.cont191:                               ; preds = %omp_loop.after199
  br label %omp.region.cont188

omp.region.cont188:                               ; preds = %omp.region.cont191
  br label %omp.par.pre_finalize181

omp.par.pre_finalize181:                          ; preds = %omp.region.cont188
  br label %.fini216

.fini216:                                         ; preds = %omp.par.pre_finalize181
  br label %omp.par.exit182.exitStub

omp_loop.body196:                                 ; preds = %omp_loop.cond195
  %6 = add i64 %omp_loop.iv200, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 0
  br label %omp.loop_nest.region204

omp.loop_nest.region204:                          ; preds = %omp_loop.body196
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region205

omp.loop_nest.region205:                          ; preds = %omp.loop_nest.region204
  br label %omp.loop_nest.region206

omp.loop_nest.region206:                          ; preds = %omp.loop_nest.region207, %omp.loop_nest.region205
  %10 = phi i64 [ %19, %omp.loop_nest.region207 ], [ 1, %omp.loop_nest.region205 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region207, label %omp.loop_nest.region208

omp.loop_nest.region208:                          ; preds = %omp.loop_nest.region206
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region209

omp.loop_nest.region209:                          ; preds = %omp.loop_nest.region208
  br label %omp.region.cont203

omp.region.cont203:                               ; preds = %omp.loop_nest.region209
  br label %omp_loop.inc197

omp_loop.inc197:                                  ; preds = %omp.region.cont203
  %omp_loop.next202 = add nuw i64 %omp_loop.iv200, 1
  br label %omp_loop.header194

omp.loop_nest.region207:                          ; preds = %omp.loop_nest.region206
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = mul nuw nsw i64 %8, 128
  %17 = add nuw nsw i64 %16, %10
  %18 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %17
  store float %15, ptr %18, align 4
  %19 = add i64 %10, 1
  br label %omp.loop_nest.region206

omp.par.exit182.exitStub:                         ; preds = %.fini216
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par.4(ptr noalias %tid.addr136, ptr noalias %zero.addr137, ptr %0) #0 {
omp.par.entry138:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter169 = alloca i32, align 4
  %p.lowerbound170 = alloca i64, align 8
  %p.upperbound171 = alloca i64, align 8
  %p.stride172 = alloca i64, align 8
  %tid.addr.local142 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr136, align 4
  store i32 %1, ptr %tid.addr.local142, align 4
  %tid143 = load i32, ptr %tid.addr.local142, align 4
  br label %omp.region.after_alloca149

omp.region.after_alloca149:                       ; preds = %omp.par.entry138
  br label %omp.region.after_alloca146

omp.region.after_alloca146:                       ; preds = %omp.region.after_alloca149
  br label %omp.par.region139

omp.par.region139:                                ; preds = %omp.region.after_alloca146
  br label %omp.par.region148

omp.par.region148:                                ; preds = %omp.par.region139
  br label %omp.wsloop.region151

omp.wsloop.region151:                             ; preds = %omp.par.region148
  br label %omp_loop.preheader152

omp_loop.preheader152:                            ; preds = %omp.wsloop.region151
  store i64 0, ptr %p.lowerbound170, align 4
  store i64 3, ptr %p.upperbound171, align 4
  store i64 1, ptr %p.stride172, align 4
  %omp_global_thread_num173 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num173, i32 34, ptr %p.lastiter169, ptr %p.lowerbound170, ptr %p.upperbound171, ptr %p.stride172, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound170, align 4
  %3 = load i64, ptr %p.upperbound171, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header153

omp_loop.header153:                               ; preds = %omp_loop.inc156, %omp_loop.preheader152
  %omp_loop.iv159 = phi i64 [ 0, %omp_loop.preheader152 ], [ %omp_loop.next161, %omp_loop.inc156 ]
  br label %omp_loop.cond154

omp_loop.cond154:                                 ; preds = %omp_loop.header153
  %omp_loop.cmp160 = icmp ult i64 %omp_loop.iv159, %5
  br i1 %omp_loop.cmp160, label %omp_loop.body155, label %omp_loop.exit157

omp_loop.exit157:                                 ; preds = %omp_loop.cond154
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num173)
  %omp_global_thread_num174 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num174)
  br label %omp_loop.after158

omp_loop.after158:                                ; preds = %omp_loop.exit157
  br label %omp.region.cont150

omp.region.cont150:                               ; preds = %omp_loop.after158
  br label %omp.region.cont147

omp.region.cont147:                               ; preds = %omp.region.cont150
  br label %omp.par.pre_finalize140

omp.par.pre_finalize140:                          ; preds = %omp.region.cont147
  br label %.fini175

.fini175:                                         ; preds = %omp.par.pre_finalize140
  br label %omp.par.exit141.exitStub

omp_loop.body155:                                 ; preds = %omp_loop.cond154
  %6 = add i64 %omp_loop.iv159, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 1
  br label %omp.loop_nest.region163

omp.loop_nest.region163:                          ; preds = %omp_loop.body155
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region164

omp.loop_nest.region164:                          ; preds = %omp.loop_nest.region163
  br label %omp.loop_nest.region165

omp.loop_nest.region165:                          ; preds = %omp.loop_nest.region166, %omp.loop_nest.region164
  %10 = phi i64 [ %19, %omp.loop_nest.region166 ], [ 1, %omp.loop_nest.region164 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region166, label %omp.loop_nest.region167

omp.loop_nest.region167:                          ; preds = %omp.loop_nest.region165
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region168

omp.loop_nest.region168:                          ; preds = %omp.loop_nest.region167
  br label %omp.region.cont162

omp.region.cont162:                               ; preds = %omp.loop_nest.region168
  br label %omp_loop.inc156

omp_loop.inc156:                                  ; preds = %omp.region.cont162
  %omp_loop.next161 = add nuw i64 %omp_loop.iv159, 1
  br label %omp_loop.header153

omp.loop_nest.region166:                          ; preds = %omp.loop_nest.region165
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = mul nuw nsw i64 %8, 128
  %17 = add nuw nsw i64 %16, %10
  %18 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %17
  store float %15, ptr %18, align 4
  %19 = add i64 %10, 1
  br label %omp.loop_nest.region165

omp.par.exit141.exitStub:                         ; preds = %.fini175
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par.3(ptr noalias %tid.addr95, ptr noalias %zero.addr96, ptr %0) #0 {
omp.par.entry97:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter128 = alloca i32, align 4
  %p.lowerbound129 = alloca i64, align 8
  %p.upperbound130 = alloca i64, align 8
  %p.stride131 = alloca i64, align 8
  %tid.addr.local101 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr95, align 4
  store i32 %1, ptr %tid.addr.local101, align 4
  %tid102 = load i32, ptr %tid.addr.local101, align 4
  br label %omp.region.after_alloca108

omp.region.after_alloca108:                       ; preds = %omp.par.entry97
  br label %omp.region.after_alloca105

omp.region.after_alloca105:                       ; preds = %omp.region.after_alloca108
  br label %omp.par.region98

omp.par.region98:                                 ; preds = %omp.region.after_alloca105
  br label %omp.par.region107

omp.par.region107:                                ; preds = %omp.par.region98
  br label %omp.wsloop.region110

omp.wsloop.region110:                             ; preds = %omp.par.region107
  br label %omp_loop.preheader111

omp_loop.preheader111:                            ; preds = %omp.wsloop.region110
  store i64 0, ptr %p.lowerbound129, align 4
  store i64 3, ptr %p.upperbound130, align 4
  store i64 1, ptr %p.stride131, align 4
  %omp_global_thread_num132 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num132, i32 34, ptr %p.lastiter128, ptr %p.lowerbound129, ptr %p.upperbound130, ptr %p.stride131, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound129, align 4
  %3 = load i64, ptr %p.upperbound130, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header112

omp_loop.header112:                               ; preds = %omp_loop.inc115, %omp_loop.preheader111
  %omp_loop.iv118 = phi i64 [ 0, %omp_loop.preheader111 ], [ %omp_loop.next120, %omp_loop.inc115 ]
  br label %omp_loop.cond113

omp_loop.cond113:                                 ; preds = %omp_loop.header112
  %omp_loop.cmp119 = icmp ult i64 %omp_loop.iv118, %5
  br i1 %omp_loop.cmp119, label %omp_loop.body114, label %omp_loop.exit116

omp_loop.exit116:                                 ; preds = %omp_loop.cond113
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num132)
  %omp_global_thread_num133 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num133)
  br label %omp_loop.after117

omp_loop.after117:                                ; preds = %omp_loop.exit116
  br label %omp.region.cont109

omp.region.cont109:                               ; preds = %omp_loop.after117
  br label %omp.region.cont106

omp.region.cont106:                               ; preds = %omp.region.cont109
  br label %omp.par.pre_finalize99

omp.par.pre_finalize99:                           ; preds = %omp.region.cont106
  br label %.fini134

.fini134:                                         ; preds = %omp.par.pre_finalize99
  br label %omp.par.exit100.exitStub

omp_loop.body114:                                 ; preds = %omp_loop.cond113
  %6 = add i64 %omp_loop.iv118, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 0
  br label %omp.loop_nest.region122

omp.loop_nest.region122:                          ; preds = %omp_loop.body114
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region123

omp.loop_nest.region123:                          ; preds = %omp.loop_nest.region122
  br label %omp.loop_nest.region124

omp.loop_nest.region124:                          ; preds = %omp.loop_nest.region125, %omp.loop_nest.region123
  %10 = phi i64 [ %46, %omp.loop_nest.region125 ], [ 1, %omp.loop_nest.region123 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region125, label %omp.loop_nest.region126

omp.loop_nest.region126:                          ; preds = %omp.loop_nest.region124
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region127

omp.loop_nest.region127:                          ; preds = %omp.loop_nest.region126
  br label %omp.region.cont121

omp.region.cont121:                               ; preds = %omp.loop_nest.region127
  br label %omp_loop.inc115

omp_loop.inc115:                                  ; preds = %omp.region.cont121
  %omp_loop.next120 = add nuw i64 %omp_loop.iv118, 1
  br label %omp_loop.header112

omp.loop_nest.region125:                          ; preds = %omp.loop_nest.region124
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = add i64 %10, -1
  %17 = mul nuw nsw i64 %8, 128
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %18
  %20 = load float, ptr %19, align 4
  %21 = fadd float %15, %20
  %22 = add i64 %10, 1
  %23 = mul nuw nsw i64 %8, 128
  %24 = add nuw nsw i64 %23, %22
  %25 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = fadd float %21, %26
  %28 = add i64 %8, 1
  %29 = mul nuw nsw i64 %28, 128
  %30 = add nuw nsw i64 %29, %10
  %31 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %30
  %32 = load float, ptr %31, align 4
  %33 = fadd float %27, %32
  %34 = add i64 %8, -1
  %35 = mul nuw nsw i64 %34, 128
  %36 = add nuw nsw i64 %35, %10
  %37 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %33, %38
  %40 = fpext float %39 to double
  %41 = fmul double %40, 2.000000e-01
  %42 = fptrunc double %41 to float
  %43 = mul nuw nsw i64 %8, 128
  %44 = add nuw nsw i64 %43, %10
  %45 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %44
  store float %42, ptr %45, align 4
  %46 = add i64 %10, 1
  br label %omp.loop_nest.region124

omp.par.exit100.exitStub:                         ; preds = %.fini134
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par.2(ptr noalias %tid.addr54, ptr noalias %zero.addr55, ptr %0) #0 {
omp.par.entry56:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter87 = alloca i32, align 4
  %p.lowerbound88 = alloca i64, align 8
  %p.upperbound89 = alloca i64, align 8
  %p.stride90 = alloca i64, align 8
  %tid.addr.local60 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr54, align 4
  store i32 %1, ptr %tid.addr.local60, align 4
  %tid61 = load i32, ptr %tid.addr.local60, align 4
  br label %omp.region.after_alloca67

omp.region.after_alloca67:                        ; preds = %omp.par.entry56
  br label %omp.region.after_alloca64

omp.region.after_alloca64:                        ; preds = %omp.region.after_alloca67
  br label %omp.par.region57

omp.par.region57:                                 ; preds = %omp.region.after_alloca64
  br label %omp.par.region66

omp.par.region66:                                 ; preds = %omp.par.region57
  br label %omp.wsloop.region69

omp.wsloop.region69:                              ; preds = %omp.par.region66
  br label %omp_loop.preheader70

omp_loop.preheader70:                             ; preds = %omp.wsloop.region69
  store i64 0, ptr %p.lowerbound88, align 4
  store i64 3, ptr %p.upperbound89, align 4
  store i64 1, ptr %p.stride90, align 4
  %omp_global_thread_num91 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num91, i32 34, ptr %p.lastiter87, ptr %p.lowerbound88, ptr %p.upperbound89, ptr %p.stride90, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound88, align 4
  %3 = load i64, ptr %p.upperbound89, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header71

omp_loop.header71:                                ; preds = %omp_loop.inc74, %omp_loop.preheader70
  %omp_loop.iv77 = phi i64 [ 0, %omp_loop.preheader70 ], [ %omp_loop.next79, %omp_loop.inc74 ]
  br label %omp_loop.cond72

omp_loop.cond72:                                  ; preds = %omp_loop.header71
  %omp_loop.cmp78 = icmp ult i64 %omp_loop.iv77, %5
  br i1 %omp_loop.cmp78, label %omp_loop.body73, label %omp_loop.exit75

omp_loop.exit75:                                  ; preds = %omp_loop.cond72
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num91)
  %omp_global_thread_num92 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num92)
  br label %omp_loop.after76

omp_loop.after76:                                 ; preds = %omp_loop.exit75
  br label %omp.region.cont68

omp.region.cont68:                                ; preds = %omp_loop.after76
  br label %omp.region.cont65

omp.region.cont65:                                ; preds = %omp.region.cont68
  br label %omp.par.pre_finalize58

omp.par.pre_finalize58:                           ; preds = %omp.region.cont65
  br label %.fini93

.fini93:                                          ; preds = %omp.par.pre_finalize58
  br label %omp.par.exit59.exitStub

omp_loop.body73:                                  ; preds = %omp_loop.cond72
  %6 = add i64 %omp_loop.iv77, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 0
  br label %omp.loop_nest.region81

omp.loop_nest.region81:                           ; preds = %omp_loop.body73
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region82

omp.loop_nest.region82:                           ; preds = %omp.loop_nest.region81
  br label %omp.loop_nest.region83

omp.loop_nest.region83:                           ; preds = %omp.loop_nest.region84, %omp.loop_nest.region82
  %10 = phi i64 [ %46, %omp.loop_nest.region84 ], [ 1, %omp.loop_nest.region82 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region84, label %omp.loop_nest.region85

omp.loop_nest.region85:                           ; preds = %omp.loop_nest.region83
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region86

omp.loop_nest.region86:                           ; preds = %omp.loop_nest.region85
  br label %omp.region.cont80

omp.region.cont80:                                ; preds = %omp.loop_nest.region86
  br label %omp_loop.inc74

omp_loop.inc74:                                   ; preds = %omp.region.cont80
  %omp_loop.next79 = add nuw i64 %omp_loop.iv77, 1
  br label %omp_loop.header71

omp.loop_nest.region84:                           ; preds = %omp.loop_nest.region83
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = add i64 %10, -1
  %17 = mul nuw nsw i64 %8, 128
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %18
  %20 = load float, ptr %19, align 4
  %21 = fadd float %15, %20
  %22 = add i64 %10, 1
  %23 = mul nuw nsw i64 %8, 128
  %24 = add nuw nsw i64 %23, %22
  %25 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = fadd float %21, %26
  %28 = add i64 %8, 1
  %29 = mul nuw nsw i64 %28, 128
  %30 = add nuw nsw i64 %29, %10
  %31 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %30
  %32 = load float, ptr %31, align 4
  %33 = fadd float %27, %32
  %34 = add i64 %8, -1
  %35 = mul nuw nsw i64 %34, 128
  %36 = add nuw nsw i64 %35, %10
  %37 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %33, %38
  %40 = fpext float %39 to double
  %41 = fmul double %40, 2.000000e-01
  %42 = fptrunc double %41 to float
  %43 = mul nuw nsw i64 %8, 128
  %44 = add nuw nsw i64 %43, %10
  %45 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %44
  store float %42, ptr %45, align 4
  %46 = add i64 %10, 1
  br label %omp.loop_nest.region83

omp.par.exit59.exitStub:                          ; preds = %.fini93
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par.1(ptr noalias %tid.addr13, ptr noalias %zero.addr14, ptr %0) #0 {
omp.par.entry15:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter46 = alloca i32, align 4
  %p.lowerbound47 = alloca i64, align 8
  %p.upperbound48 = alloca i64, align 8
  %p.stride49 = alloca i64, align 8
  %tid.addr.local19 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr13, align 4
  store i32 %1, ptr %tid.addr.local19, align 4
  %tid20 = load i32, ptr %tid.addr.local19, align 4
  br label %omp.region.after_alloca26

omp.region.after_alloca26:                        ; preds = %omp.par.entry15
  br label %omp.region.after_alloca23

omp.region.after_alloca23:                        ; preds = %omp.region.after_alloca26
  br label %omp.par.region16

omp.par.region16:                                 ; preds = %omp.region.after_alloca23
  br label %omp.par.region25

omp.par.region25:                                 ; preds = %omp.par.region16
  br label %omp.wsloop.region28

omp.wsloop.region28:                              ; preds = %omp.par.region25
  br label %omp_loop.preheader29

omp_loop.preheader29:                             ; preds = %omp.wsloop.region28
  store i64 0, ptr %p.lowerbound47, align 4
  store i64 4, ptr %p.upperbound48, align 4
  store i64 1, ptr %p.stride49, align 4
  %omp_global_thread_num50 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num50, i32 34, ptr %p.lastiter46, ptr %p.lowerbound47, ptr %p.upperbound48, ptr %p.stride49, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound47, align 4
  %3 = load i64, ptr %p.upperbound48, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header30

omp_loop.header30:                                ; preds = %omp_loop.inc33, %omp_loop.preheader29
  %omp_loop.iv36 = phi i64 [ 0, %omp_loop.preheader29 ], [ %omp_loop.next38, %omp_loop.inc33 ]
  br label %omp_loop.cond31

omp_loop.cond31:                                  ; preds = %omp_loop.header30
  %omp_loop.cmp37 = icmp ult i64 %omp_loop.iv36, %5
  br i1 %omp_loop.cmp37, label %omp_loop.body32, label %omp_loop.exit34

omp_loop.exit34:                                  ; preds = %omp_loop.cond31
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num50)
  %omp_global_thread_num51 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num51)
  br label %omp_loop.after35

omp_loop.after35:                                 ; preds = %omp_loop.exit34
  br label %omp.region.cont27

omp.region.cont27:                                ; preds = %omp_loop.after35
  br label %omp.region.cont24

omp.region.cont24:                                ; preds = %omp.region.cont27
  br label %omp.par.pre_finalize17

omp.par.pre_finalize17:                           ; preds = %omp.region.cont24
  br label %.fini52

.fini52:                                          ; preds = %omp.par.pre_finalize17
  br label %omp.par.exit18.exitStub

omp_loop.body32:                                  ; preds = %omp_loop.cond31
  %6 = add i64 %omp_loop.iv36, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 0
  br label %omp.loop_nest.region40

omp.loop_nest.region40:                           ; preds = %omp_loop.body32
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region41

omp.loop_nest.region41:                           ; preds = %omp.loop_nest.region40
  br label %omp.loop_nest.region42

omp.loop_nest.region42:                           ; preds = %omp.loop_nest.region43, %omp.loop_nest.region41
  %10 = phi i64 [ %46, %omp.loop_nest.region43 ], [ 1, %omp.loop_nest.region41 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region43, label %omp.loop_nest.region44

omp.loop_nest.region44:                           ; preds = %omp.loop_nest.region42
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region45

omp.loop_nest.region45:                           ; preds = %omp.loop_nest.region44
  br label %omp.region.cont39

omp.region.cont39:                                ; preds = %omp.loop_nest.region45
  br label %omp_loop.inc33

omp_loop.inc33:                                   ; preds = %omp.region.cont39
  %omp_loop.next38 = add nuw i64 %omp_loop.iv36, 1
  br label %omp_loop.header30

omp.loop_nest.region43:                           ; preds = %omp.loop_nest.region42
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = add i64 %10, -1
  %17 = mul nuw nsw i64 %8, 128
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %18
  %20 = load float, ptr %19, align 4
  %21 = fadd float %15, %20
  %22 = add i64 %10, 1
  %23 = mul nuw nsw i64 %8, 128
  %24 = add nuw nsw i64 %23, %22
  %25 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = fadd float %21, %26
  %28 = add i64 %8, 1
  %29 = mul nuw nsw i64 %28, 128
  %30 = add nuw nsw i64 %29, %10
  %31 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %30
  %32 = load float, ptr %31, align 4
  %33 = fadd float %27, %32
  %34 = add i64 %8, -1
  %35 = mul nuw nsw i64 %34, 128
  %36 = add nuw nsw i64 %35, %10
  %37 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %33, %38
  %40 = fpext float %39 to double
  %41 = fmul double %40, 2.000000e-01
  %42 = fptrunc double %41 to float
  %43 = mul nuw nsw i64 %8, 128
  %44 = add nuw nsw i64 %43, %10
  %45 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %44
  store float %42, ptr %45, align 4
  %46 = add i64 %10, 1
  br label %omp.loop_nest.region42

omp.par.exit18.exitStub:                          ; preds = %.fini52
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_jacobi_2d..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_ = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %gep_1 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !1
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  br label %omp.region.after_alloca2

omp.region.after_alloca2:                         ; preds = %omp.par.entry
  br label %omp.region.after_alloca

omp.region.after_alloca:                          ; preds = %omp.region.after_alloca2
  br label %omp.par.region

omp.par.region:                                   ; preds = %omp.region.after_alloca
  br label %omp.par.region1

omp.par.region1:                                  ; preds = %omp.par.region
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp.par.region1
  br label %omp_loop.preheader

omp_loop.preheader:                               ; preds = %omp.wsloop.region
  store i64 0, ptr %p.lowerbound, align 4
  store i64 3, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num10 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num10, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound, align 4
  %3 = load i64, ptr %p.upperbound, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_loop.header

omp_loop.header:                                  ; preds = %omp_loop.inc, %omp_loop.preheader
  %omp_loop.iv = phi i64 [ 0, %omp_loop.preheader ], [ %omp_loop.next, %omp_loop.inc ]
  br label %omp_loop.cond

omp_loop.cond:                                    ; preds = %omp_loop.header
  %omp_loop.cmp = icmp ult i64 %omp_loop.iv, %5
  br i1 %omp_loop.cmp, label %omp_loop.body, label %omp_loop.exit

omp_loop.exit:                                    ; preds = %omp_loop.cond
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num10)
  %omp_global_thread_num11 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num11)
  br label %omp_loop.after

omp_loop.after:                                   ; preds = %omp_loop.exit
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp_loop.after
  br label %omp.region.cont

omp.region.cont:                                  ; preds = %omp.region.cont3
  br label %omp.par.pre_finalize

omp.par.pre_finalize:                             ; preds = %omp.region.cont
  br label %.fini

.fini:                                            ; preds = %omp.par.pre_finalize
  br label %omp.par.exit.exitStub

omp_loop.body:                                    ; preds = %omp_loop.cond
  %6 = add i64 %omp_loop.iv, %2
  %7 = mul i64 %6, 1
  %8 = add i64 %7, 1
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body
  %9 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region5

omp.loop_nest.region5:                            ; preds = %omp.loop_nest.region
  br label %omp.loop_nest.region6

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region7, %omp.loop_nest.region5
  %10 = phi i64 [ %46, %omp.loop_nest.region7 ], [ 1, %omp.loop_nest.region5 ]
  %11 = icmp slt i64 %10, 19
  br i1 %11, label %omp.loop_nest.region7, label %omp.loop_nest.region8

omp.loop_nest.region8:                            ; preds = %omp.loop_nest.region6
  call void @llvm.stackrestore.p0(ptr %9)
  br label %omp.loop_nest.region9

omp.loop_nest.region9:                            ; preds = %omp.loop_nest.region8
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region9
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.loop_nest.region7:                            ; preds = %omp.loop_nest.region6
  %12 = mul nuw nsw i64 %8, 128
  %13 = add nuw nsw i64 %12, %10
  %14 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %13
  %15 = load float, ptr %14, align 4
  %16 = add i64 %10, -1
  %17 = mul nuw nsw i64 %8, 128
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %18
  %20 = load float, ptr %19, align 4
  %21 = fadd float %15, %20
  %22 = add i64 %10, 1
  %23 = mul nuw nsw i64 %8, 128
  %24 = add nuw nsw i64 %23, %22
  %25 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = fadd float %21, %26
  %28 = add i64 %8, 1
  %29 = mul nuw nsw i64 %28, 128
  %30 = add nuw nsw i64 %29, %10
  %31 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %30
  %32 = load float, ptr %31, align 4
  %33 = fadd float %27, %32
  %34 = add i64 %8, -1
  %35 = mul nuw nsw i64 %34, 128
  %36 = add nuw nsw i64 %35, %10
  %37 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %33, %38
  %40 = fpext float %39 to double
  %41 = fmul double %40, 2.000000e-01
  %42 = fptrunc double %41 to float
  %43 = mul nuw nsw i64 %8, 128
  %44 = add nuw nsw i64 %43, %10
  %45 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %44
  store float %42, ptr %45, align 4
  %46 = add i64 %10, 1
  br label %omp.loop_nest.region6

omp.par.exit.exitStub:                            ; preds = %.fini
  ret void
}

; Function Attrs: nounwind
declare i32 @__kmpc_global_thread_num(ptr) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #1

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore.p0(ptr) #1

; Function Attrs: nounwind
declare void @__kmpc_for_static_init_8u(ptr, i32, i32, ptr, ptr, ptr, ptr, i64, i64) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_fini(ptr, i32) #0

; Function Attrs: convergent nounwind
declare void @__kmpc_barrier(ptr, i32) #2

; Function Attrs: nounwind
declare !callback !2 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind willreturn }
attributes #2 = { convergent nounwind }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{i64 1}
!2 = !{!3}
!3 = !{i64 2, i64 -1, i64 -1, i1 true}
