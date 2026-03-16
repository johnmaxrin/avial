; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

%struct.ident_t = type { i32, i32, i32, i32, ptr }

@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8

declare i32 @MPI_Send(ptr, i32, i32, i32, i32, i32)

declare i32 @MPI_Recv(ptr, i32, i32, i32, i32, i32, ptr)

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

define void @kernel_atax(i32 %0, i32 %1, ptr %2, ptr %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, ptr %19, ptr %20, i64 %21, i64 %22, i64 %23) {
  %structArg96 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg94 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr, ptr }, align 8
  %.reloaded90 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded91 = alloca i64, align 8
  %.reloaded92 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded93 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded49 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded50 = alloca i64, align 8
  %.reloaded51 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded52 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded9 = alloca i64, align 8
  %.reloaded10 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded11 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %25 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %9, 0
  %26 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %25, ptr %10, 1
  %27 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %26, i64 %11, 2
  %28 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %27, i64 %12, 3, 0
  %29 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %28, i64 %13, 4, 0
  %30 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %19, 0
  %31 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %30, ptr %20, 1
  %32 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %31, i64 %21, 2
  %33 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %32, i64 %22, 3, 0
  %34 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %33, i64 %23, 4, 0
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %2, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, ptr %3, 1
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %4, 2
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %5, 3, 0
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, i64 %7, 4, 0
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, i64 %6, 3, 1
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 %8, 4, 1
  %42 = call i32 @MPI_Init(ptr null, ptr null)
  %43 = alloca i32, align 4
  %44 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %43)
  %45 = load i32, ptr %43, align 4
  %46 = alloca i32, align 4
  %47 = call i32 @MPI_Comm_size(i32 1140850688, ptr %46)
  %48 = load i32, ptr %46, align 4
  br label %49

49:                                               ; preds = %385, %24
  %50 = phi i64 [ %386, %385 ], [ 0, %24 ]
  %51 = icmp slt i64 %50, 128
  br i1 %51, label %52, label %387

52:                                               ; preds = %49
  %53 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 0
  %54 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %55 = insertvalue { ptr, ptr, i64 } poison, ptr %53, 0
  %56 = insertvalue { ptr, ptr, i64 } %55, ptr %54, 1
  %57 = insertvalue { ptr, ptr, i64 } %56, i64 0, 2
  %58 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 2
  %59 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 0
  %60 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 1
  %61 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 0
  %62 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 1
  %63 = extractvalue { ptr, ptr, i64 } %57, 0
  %64 = extractvalue { ptr, ptr, i64 } %57, 1
  %65 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %63, 0
  %66 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %65, ptr %64, 1
  %67 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %66, i64 0, 2
  %68 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %67, i64 43, 3, 0
  %69 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, i64 128, 4, 0
  %70 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, i64 128, 3, 1
  %71 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %70, i64 1, 4, 1
  %72 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 0
  %73 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 1
  %74 = insertvalue { ptr, ptr, i64 } poison, ptr %72, 0
  %75 = insertvalue { ptr, ptr, i64 } %74, ptr %73, 1
  %76 = insertvalue { ptr, ptr, i64 } %75, i64 0, 2
  %77 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 2
  %78 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 3, 0
  %79 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 4, 0
  %80 = extractvalue { ptr, ptr, i64 } %76, 0
  %81 = extractvalue { ptr, ptr, i64 } %76, 1
  %82 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %80, 0
  %83 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %82, ptr %81, 1
  %84 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %83, i64 0, 2
  %85 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %84, i64 43, 3, 0
  %86 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %85, i64 1, 4, 0
  %87 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %88 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %89 = insertvalue { ptr, ptr, i64 } poison, ptr %87, 0
  %90 = insertvalue { ptr, ptr, i64 } %89, ptr %88, 1
  %91 = insertvalue { ptr, ptr, i64 } %90, i64 0, 2
  %92 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %93 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %94 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %95 = extractvalue { ptr, ptr, i64 } %91, 0
  %96 = extractvalue { ptr, ptr, i64 } %91, 1
  %97 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %95, 0
  %98 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %97, ptr %96, 1
  %99 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %98, i64 0, 2
  %100 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %99, i64 43, 3, 0
  %101 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %100, i64 1, 4, 0
  %102 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 0
  %103 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %104 = insertvalue { ptr, ptr, i64 } poison, ptr %102, 0
  %105 = insertvalue { ptr, ptr, i64 } %104, ptr %103, 1
  %106 = insertvalue { ptr, ptr, i64 } %105, i64 0, 2
  %107 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 2
  %108 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 0
  %109 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 1
  %110 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 0
  %111 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 1
  %112 = extractvalue { ptr, ptr, i64 } %106, 0
  %113 = extractvalue { ptr, ptr, i64 } %106, 1
  %114 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %112, 0
  %115 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %114, ptr %113, 1
  %116 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %115, i64 5504, 2
  %117 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %116, i64 43, 3, 0
  %118 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %117, i64 128, 4, 0
  %119 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %118, i64 128, 3, 1
  %120 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %119, i64 1, 4, 1
  %121 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 0
  %122 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 1
  %123 = insertvalue { ptr, ptr, i64 } poison, ptr %121, 0
  %124 = insertvalue { ptr, ptr, i64 } %123, ptr %122, 1
  %125 = insertvalue { ptr, ptr, i64 } %124, i64 0, 2
  %126 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 2
  %127 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 3, 0
  %128 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 4, 0
  %129 = extractvalue { ptr, ptr, i64 } %125, 0
  %130 = extractvalue { ptr, ptr, i64 } %125, 1
  %131 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %129, 0
  %132 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %131, ptr %130, 1
  %133 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %132, i64 43, 2
  %134 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %133, i64 43, 3, 0
  %135 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %134, i64 1, 4, 0
  %136 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %137 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %138 = insertvalue { ptr, ptr, i64 } poison, ptr %136, 0
  %139 = insertvalue { ptr, ptr, i64 } %138, ptr %137, 1
  %140 = insertvalue { ptr, ptr, i64 } %139, i64 0, 2
  %141 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %142 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %143 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %144 = extractvalue { ptr, ptr, i64 } %140, 0
  %145 = extractvalue { ptr, ptr, i64 } %140, 1
  %146 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %144, 0
  %147 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %146, ptr %145, 1
  %148 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %147, i64 43, 2
  %149 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %148, i64 43, 3, 0
  %150 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %149, i64 1, 4, 0
  %151 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 0
  %152 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %153 = insertvalue { ptr, ptr, i64 } poison, ptr %151, 0
  %154 = insertvalue { ptr, ptr, i64 } %153, ptr %152, 1
  %155 = insertvalue { ptr, ptr, i64 } %154, i64 0, 2
  %156 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 2
  %157 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 0
  %158 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 1
  %159 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 0
  %160 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 1
  %161 = extractvalue { ptr, ptr, i64 } %155, 0
  %162 = extractvalue { ptr, ptr, i64 } %155, 1
  %163 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %161, 0
  %164 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %163, ptr %162, 1
  %165 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %164, i64 11008, 2
  %166 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %165, i64 42, 3, 0
  %167 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, i64 128, 4, 0
  %168 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %167, i64 128, 3, 1
  %169 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %168, i64 1, 4, 1
  %170 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 0
  %171 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 1
  %172 = insertvalue { ptr, ptr, i64 } poison, ptr %170, 0
  %173 = insertvalue { ptr, ptr, i64 } %172, ptr %171, 1
  %174 = insertvalue { ptr, ptr, i64 } %173, i64 0, 2
  %175 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 2
  %176 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 3, 0
  %177 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 4, 0
  %178 = extractvalue { ptr, ptr, i64 } %174, 0
  %179 = extractvalue { ptr, ptr, i64 } %174, 1
  %180 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %178, 0
  %181 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %180, ptr %179, 1
  %182 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %181, i64 86, 2
  %183 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %182, i64 42, 3, 0
  %184 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %183, i64 1, 4, 0
  %185 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %186 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %187 = insertvalue { ptr, ptr, i64 } poison, ptr %185, 0
  %188 = insertvalue { ptr, ptr, i64 } %187, ptr %186, 1
  %189 = insertvalue { ptr, ptr, i64 } %188, i64 0, 2
  %190 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %191 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %192 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %193 = extractvalue { ptr, ptr, i64 } %189, 0
  %194 = extractvalue { ptr, ptr, i64 } %189, 1
  %195 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %193, 0
  %196 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %195, ptr %194, 1
  %197 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %196, i64 86, 2
  %198 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %197, i64 42, 3, 0
  %199 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %198, i64 1, 4, 0
  br label %200

200:                                              ; preds = %203, %52
  %201 = phi i64 [ %215, %203 ], [ 0, %52 ]
  %202 = icmp slt i64 %201, 128
  br i1 %202, label %203, label %216

203:                                              ; preds = %200
  %204 = getelementptr inbounds nuw float, ptr %15, i64 %201
  %205 = load float, ptr %204, align 4
  %206 = mul nuw nsw i64 %50, 128
  %207 = add nuw nsw i64 %206, %201
  %208 = getelementptr inbounds nuw float, ptr %3, i64 %207
  %209 = load float, ptr %208, align 4
  %210 = getelementptr inbounds nuw float, ptr %20, i64 %50
  %211 = load float, ptr %210, align 4
  %212 = fmul float %209, %211
  %213 = fadd float %205, %212
  %214 = getelementptr inbounds nuw float, ptr %15, i64 %201
  store float %213, ptr %214, align 4
  %215 = add i64 %201, 1
  br label %200

216:                                              ; preds = %200
  %217 = srem i32 0, %48
  %218 = icmp eq i32 %45, %217
  br i1 %218, label %219, label %220

219:                                              ; preds = %216
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %101, ptr %.reloaded, align 8
  store i64 %50, ptr %.reloaded9, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %71, ptr %.reloaded10, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %86, ptr %.reloaded11, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %219
  %gep_.reloaded = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded9 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded9, ptr %gep_.reloaded9, align 8
  %gep_.reloaded10 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded10, ptr %gep_.reloaded10, align 8
  %gep_.reloaded11 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg, i32 0, i32 3
  store ptr %.reloaded11, ptr %gep_.reloaded11, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_atax..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %220

220:                                              ; preds = %omp.par.exit, %216
  %221 = srem i32 1, %48
  %222 = icmp eq i32 %45, %221
  br i1 %222, label %223, label %224

223:                                              ; preds = %220
  %omp_global_thread_num12 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %150, ptr %.reloaded49, align 8
  store i64 %50, ptr %.reloaded50, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %120, ptr %.reloaded51, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %135, ptr %.reloaded52, align 8
  br label %omp_parallel95

omp_parallel95:                                   ; preds = %223
  %gep_.reloaded49 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg94, i32 0, i32 0
  store ptr %.reloaded49, ptr %gep_.reloaded49, align 8
  %gep_.reloaded50 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg94, i32 0, i32 1
  store ptr %.reloaded50, ptr %gep_.reloaded50, align 8
  %gep_.reloaded51 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg94, i32 0, i32 2
  store ptr %.reloaded51, ptr %gep_.reloaded51, align 8
  %gep_.reloaded52 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg94, i32 0, i32 3
  store ptr %.reloaded52, ptr %gep_.reloaded52, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_atax..omp_par.1, ptr %structArg94)
  br label %omp.par.exit18

omp.par.exit18:                                   ; preds = %omp_parallel95
  br label %224

224:                                              ; preds = %omp.par.exit18, %220
  %225 = srem i32 2, %48
  %226 = icmp eq i32 %45, %225
  br i1 %226, label %227, label %228

227:                                              ; preds = %224
  %omp_global_thread_num53 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %199, ptr %.reloaded90, align 8
  store i64 %50, ptr %.reloaded91, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %169, ptr %.reloaded92, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %184, ptr %.reloaded93, align 8
  br label %omp_parallel97

omp_parallel97:                                   ; preds = %227
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg96, i32 0, i32 0
  store ptr %.reloaded90, ptr %gep_.reloaded90, align 8
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg96, i32 0, i32 1
  store ptr %.reloaded91, ptr %gep_.reloaded91, align 8
  %gep_.reloaded92 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg96, i32 0, i32 2
  store ptr %.reloaded92, ptr %gep_.reloaded92, align 8
  %gep_.reloaded93 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg96, i32 0, i32 3
  store ptr %.reloaded93, ptr %gep_.reloaded93, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_atax..omp_par.2, ptr %structArg96)
  br label %omp.par.exit59

omp.par.exit59:                                   ; preds = %omp_parallel97
  br label %228

228:                                              ; preds = %omp.par.exit59, %224
  %229 = call i32 @MPI_Barrier(i32 1140850688)
  %230 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %231 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %232 = insertvalue { ptr, ptr, i64 } poison, ptr %230, 0
  %233 = insertvalue { ptr, ptr, i64 } %232, ptr %231, 1
  %234 = insertvalue { ptr, ptr, i64 } %233, i64 0, 2
  %235 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %236 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %237 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %238 = extractvalue { ptr, ptr, i64 } %234, 0
  %239 = extractvalue { ptr, ptr, i64 } %234, 1
  %240 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %238, 0
  %241 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %240, ptr %239, 1
  %242 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %241, i64 0, 2
  %243 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %242, i64 43, 3, 0
  %244 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %243, i64 1, 4, 0
  %245 = icmp eq i32 %45, 0
  br i1 %245, label %246, label %257

246:                                              ; preds = %228
  %247 = srem i32 0, %48
  %248 = icmp ne i32 %247, 0
  br i1 %248, label %249, label %256

249:                                              ; preds = %246
  %250 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %244, 1
  %251 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %244, 2
  %252 = getelementptr float, ptr %250, i64 %251
  %253 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %244, 3, 0
  %254 = trunc i64 %253 to i32
  %255 = call i32 @MPI_Recv(ptr %252, i32 %254, i32 1275069450, i32 %247, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %256

256:                                              ; preds = %249, %246
  br label %268

257:                                              ; preds = %228
  %258 = srem i32 0, %48
  %259 = icmp eq i32 %45, %258
  br i1 %259, label %260, label %267

260:                                              ; preds = %257
  %261 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %244, 1
  %262 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %244, 2
  %263 = getelementptr float, ptr %261, i64 %262
  %264 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %244, 3, 0
  %265 = trunc i64 %264 to i32
  %266 = call i32 @MPI_Send(ptr %263, i32 %265, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %267

267:                                              ; preds = %260, %257
  br label %268

268:                                              ; preds = %256, %267
  %269 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %270 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %271 = insertvalue { ptr, ptr, i64 } poison, ptr %269, 0
  %272 = insertvalue { ptr, ptr, i64 } %271, ptr %270, 1
  %273 = insertvalue { ptr, ptr, i64 } %272, i64 0, 2
  %274 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %275 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %276 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %277 = extractvalue { ptr, ptr, i64 } %273, 0
  %278 = extractvalue { ptr, ptr, i64 } %273, 1
  %279 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %277, 0
  %280 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %279, ptr %278, 1
  %281 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %280, i64 43, 2
  %282 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %281, i64 43, 3, 0
  %283 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %282, i64 1, 4, 0
  %284 = icmp eq i32 %45, 0
  br i1 %284, label %285, label %296

285:                                              ; preds = %268
  %286 = srem i32 1, %48
  %287 = icmp ne i32 %286, 0
  br i1 %287, label %288, label %295

288:                                              ; preds = %285
  %289 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %283, 1
  %290 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %283, 2
  %291 = getelementptr float, ptr %289, i64 %290
  %292 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %283, 3, 0
  %293 = trunc i64 %292 to i32
  %294 = call i32 @MPI_Recv(ptr %291, i32 %293, i32 1275069450, i32 %286, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %295

295:                                              ; preds = %288, %285
  br label %307

296:                                              ; preds = %268
  %297 = srem i32 1, %48
  %298 = icmp eq i32 %45, %297
  br i1 %298, label %299, label %306

299:                                              ; preds = %296
  %300 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %283, 1
  %301 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %283, 2
  %302 = getelementptr float, ptr %300, i64 %301
  %303 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %283, 3, 0
  %304 = trunc i64 %303 to i32
  %305 = call i32 @MPI_Send(ptr %302, i32 %304, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %306

306:                                              ; preds = %299, %296
  br label %307

307:                                              ; preds = %295, %306
  %308 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %309 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %310 = insertvalue { ptr, ptr, i64 } poison, ptr %308, 0
  %311 = insertvalue { ptr, ptr, i64 } %310, ptr %309, 1
  %312 = insertvalue { ptr, ptr, i64 } %311, i64 0, 2
  %313 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %314 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %315 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %316 = extractvalue { ptr, ptr, i64 } %312, 0
  %317 = extractvalue { ptr, ptr, i64 } %312, 1
  %318 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %316, 0
  %319 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %318, ptr %317, 1
  %320 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %319, i64 86, 2
  %321 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %320, i64 42, 3, 0
  %322 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %321, i64 1, 4, 0
  %323 = icmp eq i32 %45, 0
  br i1 %323, label %324, label %335

324:                                              ; preds = %307
  %325 = srem i32 2, %48
  %326 = icmp ne i32 %325, 0
  br i1 %326, label %327, label %334

327:                                              ; preds = %324
  %328 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %322, 1
  %329 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %322, 2
  %330 = getelementptr float, ptr %328, i64 %329
  %331 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %322, 3, 0
  %332 = trunc i64 %331 to i32
  %333 = call i32 @MPI_Recv(ptr %330, i32 %332, i32 1275069450, i32 %325, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %334

334:                                              ; preds = %327, %324
  br label %346

335:                                              ; preds = %307
  %336 = srem i32 2, %48
  %337 = icmp eq i32 %45, %336
  br i1 %337, label %338, label %345

338:                                              ; preds = %335
  %339 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %322, 1
  %340 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %322, 2
  %341 = getelementptr float, ptr %339, i64 %340
  %342 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %322, 3, 0
  %343 = trunc i64 %342 to i32
  %344 = call i32 @MPI_Send(ptr %341, i32 %343, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %345

345:                                              ; preds = %338, %335
  br label %346

346:                                              ; preds = %334, %345
  %347 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %348 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %349 = insertvalue { ptr, ptr, i64 } poison, ptr %347, 0
  %350 = insertvalue { ptr, ptr, i64 } %349, ptr %348, 1
  %351 = insertvalue { ptr, ptr, i64 } %350, i64 0, 2
  %352 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %353 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %354 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %355 = extractvalue { ptr, ptr, i64 } %351, 0
  %356 = extractvalue { ptr, ptr, i64 } %351, 1
  %357 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %355, 0
  %358 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %357, ptr %356, 1
  %359 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %358, i64 0, 2
  %360 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %359, i64 128, 3, 0
  %361 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %360, i64 1, 4, 0
  %362 = icmp eq i32 %45, 0
  br i1 %362, label %363, label %378

363:                                              ; preds = %346
  %364 = sext i32 %48 to i64
  br label %365

365:                                              ; preds = %368, %363
  %366 = phi i64 [ %376, %368 ], [ 1, %363 ]
  %367 = icmp slt i64 %366, %364
  br i1 %367, label %368, label %377

368:                                              ; preds = %365
  %369 = trunc i64 %366 to i32
  %370 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %361, 1
  %371 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %361, 2
  %372 = getelementptr float, ptr %370, i64 %371
  %373 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %361, 3, 0
  %374 = trunc i64 %373 to i32
  %375 = call i32 @MPI_Send(ptr %372, i32 %374, i32 1275069450, i32 %369, i32 0, i32 1140850688)
  %376 = add i64 %366, 1
  br label %365

377:                                              ; preds = %365
  br label %385

378:                                              ; preds = %346
  %379 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %361, 1
  %380 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %361, 2
  %381 = getelementptr float, ptr %379, i64 %380
  %382 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %361, 3, 0
  %383 = trunc i64 %382 to i32
  %384 = call i32 @MPI_Recv(ptr %381, i32 %383, i32 1275069450, i32 0, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %385

385:                                              ; preds = %377, %378
  %386 = add i64 %50, 1
  br label %49

387:                                              ; preds = %49
  %388 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_atax..omp_par.2(ptr noalias %tid.addr54, ptr noalias %zero.addr55, ptr %0) #0 {
omp.par.entry56:
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded90 = load ptr, ptr %gep_.reloaded90, align 8, !align !1
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded91 = load ptr, ptr %gep_.reloaded91, align 8, !align !1
  %gep_.reloaded92 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded92 = load ptr, ptr %gep_.reloaded92, align 8, !align !1
  %gep_.reloaded93 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded93 = load ptr, ptr %gep_.reloaded93, align 8, !align !1
  %p.lastiter84 = alloca i32, align 4
  %p.lowerbound85 = alloca i64, align 8
  %p.upperbound86 = alloca i64, align 8
  %p.stride87 = alloca i64, align 8
  %tid.addr.local60 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr54, align 4
  store i32 %1, ptr %tid.addr.local60, align 4
  %tid61 = load i32, ptr %tid.addr.local60, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded90, align 8
  %3 = load i64, ptr %loadgep_.reloaded91, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded92, align 8
  %5 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded93, align 8
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
  store i64 0, ptr %p.lowerbound85, align 4
  store i64 41, ptr %p.upperbound86, align 4
  store i64 1, ptr %p.stride87, align 4
  %omp_global_thread_num88 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num88, i32 34, ptr %p.lastiter84, ptr %p.lowerbound85, ptr %p.upperbound86, ptr %p.stride87, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound85, align 4
  %7 = load i64, ptr %p.upperbound86, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header71

omp_loop.header71:                                ; preds = %omp_loop.inc74, %omp_loop.preheader70
  %omp_loop.iv77 = phi i64 [ 0, %omp_loop.preheader70 ], [ %omp_loop.next79, %omp_loop.inc74 ]
  br label %omp_loop.cond72

omp_loop.cond72:                                  ; preds = %omp_loop.header71
  %omp_loop.cmp78 = icmp ult i64 %omp_loop.iv77, %9
  br i1 %omp_loop.cmp78, label %omp_loop.body73, label %omp_loop.exit75

omp_loop.exit75:                                  ; preds = %omp_loop.cond72
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num88)
  %omp_global_thread_num89 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num89)
  br label %omp_loop.after76

omp_loop.after76:                                 ; preds = %omp_loop.exit75
  br label %omp.region.cont68

omp.region.cont68:                                ; preds = %omp_loop.after76
  br label %omp.region.cont65

omp.region.cont65:                                ; preds = %omp.region.cont68
  br label %omp.par.pre_finalize58

omp.par.pre_finalize58:                           ; preds = %omp.region.cont65
  br label %omp.par.exit59.exitStub

omp_loop.body73:                                  ; preds = %omp_loop.cond72
  %10 = add i64 %omp_loop.iv77, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.loop_nest.region81

omp.loop_nest.region81:                           ; preds = %omp_loop.body73
  %13 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region82

omp.loop_nest.region82:                           ; preds = %omp.loop_nest.region81
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 86
  %16 = getelementptr inbounds nuw float, ptr %15, i64 %3
  %17 = load float, ptr %16, align 4
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %19 = getelementptr float, ptr %18, i32 11008
  %20 = mul nuw nsw i64 %3, 128
  %21 = add nuw nsw i64 %20, %12
  %22 = getelementptr inbounds nuw float, ptr %19, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, 1
  %25 = getelementptr float, ptr %24, i32 86
  %26 = getelementptr inbounds nuw float, ptr %25, i64 %12
  %27 = load float, ptr %26, align 4
  %28 = fmul float %23, %27
  %29 = fadd float %17, %28
  %30 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %31 = getelementptr float, ptr %30, i32 86
  %32 = getelementptr inbounds nuw float, ptr %31, i64 %3
  store float %29, ptr %32, align 4
  call void @llvm.stackrestore.p0(ptr %13)
  br label %omp.loop_nest.region83

omp.loop_nest.region83:                           ; preds = %omp.loop_nest.region82
  br label %omp.region.cont80

omp.region.cont80:                                ; preds = %omp.loop_nest.region83
  br label %omp_loop.inc74

omp_loop.inc74:                                   ; preds = %omp.region.cont80
  %omp_loop.next79 = add nuw i64 %omp_loop.iv77, 1
  br label %omp_loop.header71

omp.par.exit59.exitStub:                          ; preds = %omp.par.pre_finalize58
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_atax..omp_par.1(ptr noalias %tid.addr13, ptr noalias %zero.addr14, ptr %0) #0 {
omp.par.entry15:
  %gep_.reloaded49 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded49 = load ptr, ptr %gep_.reloaded49, align 8, !align !1
  %gep_.reloaded50 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded50 = load ptr, ptr %gep_.reloaded50, align 8, !align !1
  %gep_.reloaded51 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded51 = load ptr, ptr %gep_.reloaded51, align 8, !align !1
  %gep_.reloaded52 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded52 = load ptr, ptr %gep_.reloaded52, align 8, !align !1
  %p.lastiter43 = alloca i32, align 4
  %p.lowerbound44 = alloca i64, align 8
  %p.upperbound45 = alloca i64, align 8
  %p.stride46 = alloca i64, align 8
  %tid.addr.local19 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr13, align 4
  store i32 %1, ptr %tid.addr.local19, align 4
  %tid20 = load i32, ptr %tid.addr.local19, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded49, align 8
  %3 = load i64, ptr %loadgep_.reloaded50, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded51, align 8
  %5 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded52, align 8
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
  store i64 0, ptr %p.lowerbound44, align 4
  store i64 42, ptr %p.upperbound45, align 4
  store i64 1, ptr %p.stride46, align 4
  %omp_global_thread_num47 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num47, i32 34, ptr %p.lastiter43, ptr %p.lowerbound44, ptr %p.upperbound45, ptr %p.stride46, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound44, align 4
  %7 = load i64, ptr %p.upperbound45, align 4
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
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num47)
  %omp_global_thread_num48 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num48)
  br label %omp_loop.after35

omp_loop.after35:                                 ; preds = %omp_loop.exit34
  br label %omp.region.cont27

omp.region.cont27:                                ; preds = %omp_loop.after35
  br label %omp.region.cont24

omp.region.cont24:                                ; preds = %omp.region.cont27
  br label %omp.par.pre_finalize17

omp.par.pre_finalize17:                           ; preds = %omp.region.cont24
  br label %omp.par.exit18.exitStub

omp_loop.body32:                                  ; preds = %omp_loop.cond31
  %10 = add i64 %omp_loop.iv36, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.loop_nest.region40

omp.loop_nest.region40:                           ; preds = %omp_loop.body32
  %13 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region41

omp.loop_nest.region41:                           ; preds = %omp.loop_nest.region40
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 43
  %16 = getelementptr inbounds nuw float, ptr %15, i64 %3
  %17 = load float, ptr %16, align 4
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %19 = getelementptr float, ptr %18, i32 5504
  %20 = mul nuw nsw i64 %3, 128
  %21 = add nuw nsw i64 %20, %12
  %22 = getelementptr inbounds nuw float, ptr %19, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, 1
  %25 = getelementptr float, ptr %24, i32 43
  %26 = getelementptr inbounds nuw float, ptr %25, i64 %12
  %27 = load float, ptr %26, align 4
  %28 = fmul float %23, %27
  %29 = fadd float %17, %28
  %30 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %31 = getelementptr float, ptr %30, i32 43
  %32 = getelementptr inbounds nuw float, ptr %31, i64 %3
  store float %29, ptr %32, align 4
  call void @llvm.stackrestore.p0(ptr %13)
  br label %omp.loop_nest.region42

omp.loop_nest.region42:                           ; preds = %omp.loop_nest.region41
  br label %omp.region.cont39

omp.region.cont39:                                ; preds = %omp.loop_nest.region42
  br label %omp_loop.inc33

omp_loop.inc33:                                   ; preds = %omp.region.cont39
  %omp_loop.next38 = add nuw i64 %omp_loop.iv36, 1
  br label %omp_loop.header30

omp.par.exit18.exitStub:                          ; preds = %omp.par.pre_finalize17
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_atax..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded9 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded9 = load ptr, ptr %gep_.reloaded9, align 8, !align !1
  %gep_.reloaded10 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded10 = load ptr, ptr %gep_.reloaded10, align 8, !align !1
  %gep_.reloaded11 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded11 = load ptr, ptr %gep_.reloaded11, align 8, !align !1
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load i64, ptr %loadgep_.reloaded9, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded10, align 8
  %5 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded11, align 8
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
  store i64 42, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num7 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num7, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
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
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num7)
  %omp_global_thread_num8 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num8)
  br label %omp_loop.after

omp_loop.after:                                   ; preds = %omp_loop.exit
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp_loop.after
  br label %omp.region.cont

omp.region.cont:                                  ; preds = %omp.region.cont3
  br label %omp.par.pre_finalize

omp.par.pre_finalize:                             ; preds = %omp.region.cont
  br label %omp.par.exit.exitStub

omp_loop.body:                                    ; preds = %omp_loop.cond
  %10 = add i64 %omp_loop.iv, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body
  %13 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region5

omp.loop_nest.region5:                            ; preds = %omp.loop_nest.region
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr inbounds nuw float, ptr %14, i64 %3
  %16 = load float, ptr %15, align 4
  %17 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %18 = mul nuw nsw i64 %3, 128
  %19 = add nuw nsw i64 %18, %12
  %20 = getelementptr inbounds nuw float, ptr %17, i64 %19
  %21 = load float, ptr %20, align 4
  %22 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, 1
  %23 = getelementptr inbounds nuw float, ptr %22, i64 %12
  %24 = load float, ptr %23, align 4
  %25 = fmul float %21, %24
  %26 = fadd float %16, %25
  %27 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %28 = getelementptr inbounds nuw float, ptr %27, i64 %3
  store float %26, ptr %28, align 4
  call void @llvm.stackrestore.p0(ptr %13)
  br label %omp.loop_nest.region6

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region5
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region6
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.par.exit.exitStub:                            ; preds = %omp.par.pre_finalize
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
!1 = !{i64 8}
!2 = !{!3}
!3 = !{i64 2, i64 -1, i64 -1, i1 true}
