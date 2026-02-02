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

define void @matmul(i32 %0, i32 %1, i32 %2, ptr %3, ptr %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, ptr %10, ptr %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, ptr %17, ptr %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23) {
  %structArg111 = alloca { ptr, ptr, ptr }, align 8
  %structArg109 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded106 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded107 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded108 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded60 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded61 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded62 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded15 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded16 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %17, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, ptr %18, 1
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %19, 2
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 3, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %22, 4, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %21, 3, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %23, 4, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %10, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %11, 1
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %12, 2
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %13, 3, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %15, 4, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %14, 3, 1
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %16, 4, 1
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %3, 0
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, ptr %4, 1
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 %5, 2
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, i64 %6, 3, 0
  %43 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, i64 %8, 4, 0
  %44 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %43, i64 %7, 3, 1
  %45 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, i64 %9, 4, 1
  %46 = call i32 @MPI_Init(ptr null, ptr null)
  %47 = alloca i32, align 4
  %48 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %47)
  %49 = load i32, ptr %47, align 4
  %50 = alloca i32, align 4
  %51 = call i32 @MPI_Comm_size(i32 1140850688, ptr %50)
  %52 = load i32, ptr %50, align 4
  %53 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %54 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %55 = insertvalue { ptr, ptr, i64 } poison, ptr %53, 0
  %56 = insertvalue { ptr, ptr, i64 } %55, ptr %54, 1
  %57 = insertvalue { ptr, ptr, i64 } %56, i64 0, 2
  %58 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %59 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %60 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %61 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %62 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %63 = extractvalue { ptr, ptr, i64 } %57, 0
  %64 = extractvalue { ptr, ptr, i64 } %57, 1
  %65 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %63, 0
  %66 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %65, ptr %64, 1
  %67 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %66, i64 0, 2
  %68 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %67, i64 334, 3, 0
  %69 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, i64 1000, 4, 0
  %70 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, i64 1000, 3, 1
  %71 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %70, i64 1, 4, 1
  %72 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 0
  %73 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %74 = insertvalue { ptr, ptr, i64 } poison, ptr %72, 0
  %75 = insertvalue { ptr, ptr, i64 } %74, ptr %73, 1
  %76 = insertvalue { ptr, ptr, i64 } %75, i64 0, 2
  %77 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 2
  %78 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 0
  %79 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 1
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %81 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %82 = extractvalue { ptr, ptr, i64 } %76, 0
  %83 = extractvalue { ptr, ptr, i64 } %76, 1
  %84 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %82, 0
  %85 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %84, ptr %83, 1
  %86 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %85, i64 0, 2
  %87 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %86, i64 334, 3, 0
  %88 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %87, i64 1000, 4, 0
  %89 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %88, i64 1000, 3, 1
  %90 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %89, i64 1, 4, 1
  %91 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %92 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %93 = insertvalue { ptr, ptr, i64 } poison, ptr %91, 0
  %94 = insertvalue { ptr, ptr, i64 } %93, ptr %92, 1
  %95 = insertvalue { ptr, ptr, i64 } %94, i64 0, 2
  %96 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %97 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %98 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %99 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %100 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %101 = extractvalue { ptr, ptr, i64 } %95, 0
  %102 = extractvalue { ptr, ptr, i64 } %95, 1
  %103 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %101, 0
  %104 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %102, 1
  %105 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %104, i64 0, 2
  %106 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, i64 334, 3, 0
  %107 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %106, i64 1000, 4, 0
  %108 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %107, i64 1000, 3, 1
  %109 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %108, i64 1, 4, 1
  %110 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %111 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %112 = insertvalue { ptr, ptr, i64 } poison, ptr %110, 0
  %113 = insertvalue { ptr, ptr, i64 } %112, ptr %111, 1
  %114 = insertvalue { ptr, ptr, i64 } %113, i64 0, 2
  %115 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %116 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %117 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %118 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %119 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %120 = extractvalue { ptr, ptr, i64 } %114, 0
  %121 = extractvalue { ptr, ptr, i64 } %114, 1
  %122 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %120, 0
  %123 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %122, ptr %121, 1
  %124 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %123, i64 334000, 2
  %125 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %124, i64 333, 3, 0
  %126 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %125, i64 1000, 4, 0
  %127 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %126, i64 1000, 3, 1
  %128 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %127, i64 1, 4, 1
  %129 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 0
  %130 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %131 = insertvalue { ptr, ptr, i64 } poison, ptr %129, 0
  %132 = insertvalue { ptr, ptr, i64 } %131, ptr %130, 1
  %133 = insertvalue { ptr, ptr, i64 } %132, i64 0, 2
  %134 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 2
  %135 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 0
  %136 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 1
  %137 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %138 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %139 = extractvalue { ptr, ptr, i64 } %133, 0
  %140 = extractvalue { ptr, ptr, i64 } %133, 1
  %141 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %139, 0
  %142 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %141, ptr %140, 1
  %143 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %142, i64 334000, 2
  %144 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %143, i64 333, 3, 0
  %145 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %144, i64 1000, 4, 0
  %146 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %145, i64 1000, 3, 1
  %147 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, i64 1, 4, 1
  %148 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %149 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %150 = insertvalue { ptr, ptr, i64 } poison, ptr %148, 0
  %151 = insertvalue { ptr, ptr, i64 } %150, ptr %149, 1
  %152 = insertvalue { ptr, ptr, i64 } %151, i64 0, 2
  %153 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %154 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %155 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %156 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %157 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %158 = extractvalue { ptr, ptr, i64 } %152, 0
  %159 = extractvalue { ptr, ptr, i64 } %152, 1
  %160 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %158, 0
  %161 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %160, ptr %159, 1
  %162 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %161, i64 334000, 2
  %163 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %162, i64 333, 3, 0
  %164 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %163, i64 1000, 4, 0
  %165 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %164, i64 1000, 3, 1
  %166 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %165, i64 1, 4, 1
  %167 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %168 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %169 = insertvalue { ptr, ptr, i64 } poison, ptr %167, 0
  %170 = insertvalue { ptr, ptr, i64 } %169, ptr %168, 1
  %171 = insertvalue { ptr, ptr, i64 } %170, i64 0, 2
  %172 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %173 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %174 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %175 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %176 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %177 = extractvalue { ptr, ptr, i64 } %171, 0
  %178 = extractvalue { ptr, ptr, i64 } %171, 1
  %179 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %177, 0
  %180 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %179, ptr %178, 1
  %181 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %180, i64 667000, 2
  %182 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %181, i64 333, 3, 0
  %183 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %182, i64 1000, 4, 0
  %184 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %183, i64 1000, 3, 1
  %185 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %184, i64 1, 4, 1
  %186 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 0
  %187 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %188 = insertvalue { ptr, ptr, i64 } poison, ptr %186, 0
  %189 = insertvalue { ptr, ptr, i64 } %188, ptr %187, 1
  %190 = insertvalue { ptr, ptr, i64 } %189, i64 0, 2
  %191 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 2
  %192 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 0
  %193 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 1
  %194 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %195 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %196 = extractvalue { ptr, ptr, i64 } %190, 0
  %197 = extractvalue { ptr, ptr, i64 } %190, 1
  %198 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %196, 0
  %199 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %198, ptr %197, 1
  %200 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %199, i64 667000, 2
  %201 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %200, i64 333, 3, 0
  %202 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %201, i64 1000, 4, 0
  %203 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %202, i64 1000, 3, 1
  %204 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %203, i64 1, 4, 1
  %205 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %206 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %207 = insertvalue { ptr, ptr, i64 } poison, ptr %205, 0
  %208 = insertvalue { ptr, ptr, i64 } %207, ptr %206, 1
  %209 = insertvalue { ptr, ptr, i64 } %208, i64 0, 2
  %210 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %211 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %212 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %213 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %214 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %215 = extractvalue { ptr, ptr, i64 } %209, 0
  %216 = extractvalue { ptr, ptr, i64 } %209, 1
  %217 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %215, 0
  %218 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %217, ptr %216, 1
  %219 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %218, i64 667000, 2
  %220 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %219, i64 333, 3, 0
  %221 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %220, i64 1000, 4, 0
  %222 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %221, i64 1000, 3, 1
  %223 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %222, i64 1, 4, 1
  %224 = srem i32 0, %52
  %225 = icmp eq i32 %49, %224
  br i1 %225, label %226, label %227

226:                                              ; preds = %24
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %90, ptr %.reloaded15, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %71, ptr %.reloaded16, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %226
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded15, ptr %gep_.reloaded15, align 8
  %gep_.reloaded16 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded16, ptr %gep_.reloaded16, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %227

227:                                              ; preds = %omp.par.exit, %24
  %228 = srem i32 1, %52
  %229 = icmp eq i32 %49, %228
  br i1 %229, label %230, label %231

230:                                              ; preds = %227
  %omp_global_thread_num17 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, ptr %.reloaded60, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %147, ptr %.reloaded61, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %128, ptr %.reloaded62, align 8
  br label %omp_parallel110

omp_parallel110:                                  ; preds = %230
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %structArg109, i32 0, i32 0
  store ptr %.reloaded60, ptr %gep_.reloaded60, align 8
  %gep_.reloaded61 = getelementptr { ptr, ptr, ptr }, ptr %structArg109, i32 0, i32 1
  store ptr %.reloaded61, ptr %gep_.reloaded61, align 8
  %gep_.reloaded62 = getelementptr { ptr, ptr, ptr }, ptr %structArg109, i32 0, i32 2
  store ptr %.reloaded62, ptr %gep_.reloaded62, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par.1, ptr %structArg109)
  br label %omp.par.exit23

omp.par.exit23:                                   ; preds = %omp_parallel110
  br label %231

231:                                              ; preds = %omp.par.exit23, %227
  %232 = srem i32 2, %52
  %233 = icmp eq i32 %49, %232
  br i1 %233, label %234, label %235

234:                                              ; preds = %231
  %omp_global_thread_num63 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, ptr %.reloaded106, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, ptr %.reloaded107, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, ptr %.reloaded108, align 8
  br label %omp_parallel112

omp_parallel112:                                  ; preds = %234
  %gep_.reloaded106 = getelementptr { ptr, ptr, ptr }, ptr %structArg111, i32 0, i32 0
  store ptr %.reloaded106, ptr %gep_.reloaded106, align 8
  %gep_.reloaded107 = getelementptr { ptr, ptr, ptr }, ptr %structArg111, i32 0, i32 1
  store ptr %.reloaded107, ptr %gep_.reloaded107, align 8
  %gep_.reloaded108 = getelementptr { ptr, ptr, ptr }, ptr %structArg111, i32 0, i32 2
  store ptr %.reloaded108, ptr %gep_.reloaded108, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par.2, ptr %structArg111)
  br label %omp.par.exit69

omp.par.exit69:                                   ; preds = %omp_parallel112
  br label %235

235:                                              ; preds = %omp.par.exit69, %231
  %236 = call i32 @MPI_Barrier(i32 1140850688)
  %237 = icmp eq i32 %49, 0
  br i1 %237, label %238, label %249

238:                                              ; preds = %235
  %239 = srem i32 0, %52
  %240 = icmp ne i32 %239, 0
  br i1 %240, label %241, label %248

241:                                              ; preds = %238
  %242 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, 1
  %243 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, 2
  %244 = getelementptr float, ptr %242, i64 %243
  %245 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, 3, 0
  %246 = trunc i64 %245 to i32
  %247 = call i32 @MPI_Recv(ptr %244, i32 %246, i32 1275069450, i32 %239, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %248

248:                                              ; preds = %241, %238
  br label %260

249:                                              ; preds = %235
  %250 = srem i32 0, %52
  %251 = icmp eq i32 %49, %250
  br i1 %251, label %252, label %259

252:                                              ; preds = %249
  %253 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, 1
  %254 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, 2
  %255 = getelementptr float, ptr %253, i64 %254
  %256 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, 3, 0
  %257 = trunc i64 %256 to i32
  %258 = call i32 @MPI_Send(ptr %255, i32 %257, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %259

259:                                              ; preds = %252, %249
  br label %260

260:                                              ; preds = %248, %259
  %261 = icmp eq i32 %49, 0
  br i1 %261, label %262, label %273

262:                                              ; preds = %260
  %263 = srem i32 1, %52
  %264 = icmp ne i32 %263, 0
  br i1 %264, label %265, label %272

265:                                              ; preds = %262
  %266 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, 1
  %267 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, 2
  %268 = getelementptr float, ptr %266, i64 %267
  %269 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, 3, 0
  %270 = trunc i64 %269 to i32
  %271 = call i32 @MPI_Recv(ptr %268, i32 %270, i32 1275069450, i32 %263, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %272

272:                                              ; preds = %265, %262
  br label %284

273:                                              ; preds = %260
  %274 = srem i32 1, %52
  %275 = icmp eq i32 %49, %274
  br i1 %275, label %276, label %283

276:                                              ; preds = %273
  %277 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, 1
  %278 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, 2
  %279 = getelementptr float, ptr %277, i64 %278
  %280 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, 3, 0
  %281 = trunc i64 %280 to i32
  %282 = call i32 @MPI_Send(ptr %279, i32 %281, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %283

283:                                              ; preds = %276, %273
  br label %284

284:                                              ; preds = %272, %283
  %285 = icmp eq i32 %49, 0
  br i1 %285, label %286, label %297

286:                                              ; preds = %284
  %287 = srem i32 2, %52
  %288 = icmp ne i32 %287, 0
  br i1 %288, label %289, label %296

289:                                              ; preds = %286
  %290 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 1
  %291 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 2
  %292 = getelementptr float, ptr %290, i64 %291
  %293 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 3, 0
  %294 = trunc i64 %293 to i32
  %295 = call i32 @MPI_Recv(ptr %292, i32 %294, i32 1275069450, i32 %287, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %296

296:                                              ; preds = %289, %286
  br label %308

297:                                              ; preds = %284
  %298 = srem i32 2, %52
  %299 = icmp eq i32 %49, %298
  br i1 %299, label %300, label %307

300:                                              ; preds = %297
  %301 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 1
  %302 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 2
  %303 = getelementptr float, ptr %301, i64 %302
  %304 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 3, 0
  %305 = trunc i64 %304 to i32
  %306 = call i32 @MPI_Send(ptr %303, i32 %305, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %307

307:                                              ; preds = %300, %297
  br label %308

308:                                              ; preds = %296, %307
  %309 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par.2(ptr noalias %tid.addr64, ptr noalias %zero.addr65, ptr %0) #0 {
omp.par.entry66:
  %gep_.reloaded106 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded106 = load ptr, ptr %gep_.reloaded106, align 8, !align !1
  %gep_.reloaded107 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded107 = load ptr, ptr %gep_.reloaded107, align 8, !align !1
  %gep_.reloaded108 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded108 = load ptr, ptr %gep_.reloaded108, align 8, !align !1
  %p.lastiter100 = alloca i32, align 4
  %p.lowerbound101 = alloca i64, align 8
  %p.upperbound102 = alloca i64, align 8
  %p.stride103 = alloca i64, align 8
  %tid.addr.local70 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr64, align 4
  store i32 %1, ptr %tid.addr.local70, align 4
  %tid71 = load i32, ptr %tid.addr.local70, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded106, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded107, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded108, align 8
  br label %omp.region.after_alloca77

omp.region.after_alloca77:                        ; preds = %omp.par.entry66
  br label %omp.region.after_alloca74

omp.region.after_alloca74:                        ; preds = %omp.region.after_alloca77
  br label %omp.par.region67

omp.par.region67:                                 ; preds = %omp.region.after_alloca74
  br label %omp.par.region76

omp.par.region76:                                 ; preds = %omp.par.region67
  br label %omp.wsloop.region79

omp.wsloop.region79:                              ; preds = %omp.par.region76
  br label %omp_loop.preheader80

omp_loop.preheader80:                             ; preds = %omp.wsloop.region79
  store i64 0, ptr %p.lowerbound101, align 4
  store i64 332, ptr %p.upperbound102, align 4
  store i64 1, ptr %p.stride103, align 4
  %omp_global_thread_num104 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num104, i32 34, ptr %p.lastiter100, ptr %p.lowerbound101, ptr %p.upperbound102, ptr %p.stride103, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound101, align 4
  %6 = load i64, ptr %p.upperbound102, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header81

omp_loop.header81:                                ; preds = %omp_loop.inc84, %omp_loop.preheader80
  %omp_loop.iv87 = phi i64 [ 0, %omp_loop.preheader80 ], [ %omp_loop.next89, %omp_loop.inc84 ]
  br label %omp_loop.cond82

omp_loop.cond82:                                  ; preds = %omp_loop.header81
  %omp_loop.cmp88 = icmp ult i64 %omp_loop.iv87, %8
  br i1 %omp_loop.cmp88, label %omp_loop.body83, label %omp_loop.exit85

omp_loop.exit85:                                  ; preds = %omp_loop.cond82
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num104)
  %omp_global_thread_num105 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num105)
  br label %omp_loop.after86

omp_loop.after86:                                 ; preds = %omp_loop.exit85
  br label %omp.region.cont78

omp.region.cont78:                                ; preds = %omp_loop.after86
  br label %omp.region.cont75

omp.region.cont75:                                ; preds = %omp.region.cont78
  br label %omp.par.pre_finalize68

omp.par.pre_finalize68:                           ; preds = %omp.region.cont75
  br label %omp.par.exit69.exitStub

omp_loop.body83:                                  ; preds = %omp_loop.cond82
  %9 = add i64 %omp_loop.iv87, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region91

omp.loop_nest.region91:                           ; preds = %omp_loop.body83
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region92

omp.loop_nest.region92:                           ; preds = %omp.loop_nest.region91
  br label %omp.loop_nest.region93

omp.loop_nest.region93:                           ; preds = %omp.loop_nest.region97, %omp.loop_nest.region92
  %13 = phi i64 [ %22, %omp.loop_nest.region97 ], [ 0, %omp.loop_nest.region92 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region94, label %omp.loop_nest.region98

omp.loop_nest.region98:                           ; preds = %omp.loop_nest.region93
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region99

omp.loop_nest.region99:                           ; preds = %omp.loop_nest.region98
  br label %omp.region.cont90

omp.region.cont90:                                ; preds = %omp.loop_nest.region99
  br label %omp_loop.inc84

omp_loop.inc84:                                   ; preds = %omp.region.cont90
  %omp_loop.next89 = add nuw i64 %omp_loop.iv87, 1
  br label %omp_loop.header81

omp.loop_nest.region94:                           ; preds = %omp.loop_nest.region93
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = getelementptr float, ptr %15, i32 667000
  %17 = mul nuw nsw i64 %11, 1000
  %18 = add nuw nsw i64 %17, %13
  %19 = getelementptr inbounds nuw float, ptr %16, i64 %18
  store float 0.000000e+00, ptr %19, align 4
  br label %omp.loop_nest.region95

omp.loop_nest.region95:                           ; preds = %omp.loop_nest.region96, %omp.loop_nest.region94
  %20 = phi i64 [ %48, %omp.loop_nest.region96 ], [ 0, %omp.loop_nest.region94 ]
  %21 = icmp slt i64 %20, 1000
  br i1 %21, label %omp.loop_nest.region96, label %omp.loop_nest.region97

omp.loop_nest.region97:                           ; preds = %omp.loop_nest.region95
  %22 = add i64 %13, 1
  br label %omp.loop_nest.region93

omp.loop_nest.region96:                           ; preds = %omp.loop_nest.region95
  %23 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %24 = getelementptr float, ptr %23, i32 667000
  %25 = mul nuw nsw i64 %11, 1000
  %26 = add nuw nsw i64 %25, %20
  %27 = getelementptr inbounds nuw float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %30 = getelementptr float, ptr %29, i32 667000
  %31 = mul nuw nsw i64 %20, 1000
  %32 = add nuw nsw i64 %31, %13
  %33 = getelementptr inbounds nuw float, ptr %30, i64 %32
  %34 = load float, ptr %33, align 4
  %35 = fmul float %28, %34
  %36 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %37 = getelementptr float, ptr %36, i32 667000
  %38 = mul nuw nsw i64 %11, 1000
  %39 = add nuw nsw i64 %38, %13
  %40 = getelementptr inbounds nuw float, ptr %37, i64 %39
  %41 = load float, ptr %40, align 4
  %42 = fadd float %41, %35
  %43 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %44 = getelementptr float, ptr %43, i32 667000
  %45 = mul nuw nsw i64 %11, 1000
  %46 = add nuw nsw i64 %45, %13
  %47 = getelementptr inbounds nuw float, ptr %44, i64 %46
  store float %42, ptr %47, align 4
  %48 = add i64 %20, 1
  br label %omp.loop_nest.region95

omp.par.exit69.exitStub:                          ; preds = %omp.par.pre_finalize68
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par.1(ptr noalias %tid.addr18, ptr noalias %zero.addr19, ptr %0) #0 {
omp.par.entry20:
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded60 = load ptr, ptr %gep_.reloaded60, align 8, !align !1
  %gep_.reloaded61 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded61 = load ptr, ptr %gep_.reloaded61, align 8, !align !1
  %gep_.reloaded62 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded62 = load ptr, ptr %gep_.reloaded62, align 8, !align !1
  %p.lastiter54 = alloca i32, align 4
  %p.lowerbound55 = alloca i64, align 8
  %p.upperbound56 = alloca i64, align 8
  %p.stride57 = alloca i64, align 8
  %tid.addr.local24 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr18, align 4
  store i32 %1, ptr %tid.addr.local24, align 4
  %tid25 = load i32, ptr %tid.addr.local24, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded60, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded61, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded62, align 8
  br label %omp.region.after_alloca31

omp.region.after_alloca31:                        ; preds = %omp.par.entry20
  br label %omp.region.after_alloca28

omp.region.after_alloca28:                        ; preds = %omp.region.after_alloca31
  br label %omp.par.region21

omp.par.region21:                                 ; preds = %omp.region.after_alloca28
  br label %omp.par.region30

omp.par.region30:                                 ; preds = %omp.par.region21
  br label %omp.wsloop.region33

omp.wsloop.region33:                              ; preds = %omp.par.region30
  br label %omp_loop.preheader34

omp_loop.preheader34:                             ; preds = %omp.wsloop.region33
  store i64 0, ptr %p.lowerbound55, align 4
  store i64 332, ptr %p.upperbound56, align 4
  store i64 1, ptr %p.stride57, align 4
  %omp_global_thread_num58 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num58, i32 34, ptr %p.lastiter54, ptr %p.lowerbound55, ptr %p.upperbound56, ptr %p.stride57, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound55, align 4
  %6 = load i64, ptr %p.upperbound56, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header35

omp_loop.header35:                                ; preds = %omp_loop.inc38, %omp_loop.preheader34
  %omp_loop.iv41 = phi i64 [ 0, %omp_loop.preheader34 ], [ %omp_loop.next43, %omp_loop.inc38 ]
  br label %omp_loop.cond36

omp_loop.cond36:                                  ; preds = %omp_loop.header35
  %omp_loop.cmp42 = icmp ult i64 %omp_loop.iv41, %8
  br i1 %omp_loop.cmp42, label %omp_loop.body37, label %omp_loop.exit39

omp_loop.exit39:                                  ; preds = %omp_loop.cond36
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num58)
  %omp_global_thread_num59 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num59)
  br label %omp_loop.after40

omp_loop.after40:                                 ; preds = %omp_loop.exit39
  br label %omp.region.cont32

omp.region.cont32:                                ; preds = %omp_loop.after40
  br label %omp.region.cont29

omp.region.cont29:                                ; preds = %omp.region.cont32
  br label %omp.par.pre_finalize22

omp.par.pre_finalize22:                           ; preds = %omp.region.cont29
  br label %omp.par.exit23.exitStub

omp_loop.body37:                                  ; preds = %omp_loop.cond36
  %9 = add i64 %omp_loop.iv41, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region45

omp.loop_nest.region45:                           ; preds = %omp_loop.body37
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region46

omp.loop_nest.region46:                           ; preds = %omp.loop_nest.region45
  br label %omp.loop_nest.region47

omp.loop_nest.region47:                           ; preds = %omp.loop_nest.region51, %omp.loop_nest.region46
  %13 = phi i64 [ %22, %omp.loop_nest.region51 ], [ 0, %omp.loop_nest.region46 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region48, label %omp.loop_nest.region52

omp.loop_nest.region52:                           ; preds = %omp.loop_nest.region47
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region53

omp.loop_nest.region53:                           ; preds = %omp.loop_nest.region52
  br label %omp.region.cont44

omp.region.cont44:                                ; preds = %omp.loop_nest.region53
  br label %omp_loop.inc38

omp_loop.inc38:                                   ; preds = %omp.region.cont44
  %omp_loop.next43 = add nuw i64 %omp_loop.iv41, 1
  br label %omp_loop.header35

omp.loop_nest.region48:                           ; preds = %omp.loop_nest.region47
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = getelementptr float, ptr %15, i32 334000
  %17 = mul nuw nsw i64 %11, 1000
  %18 = add nuw nsw i64 %17, %13
  %19 = getelementptr inbounds nuw float, ptr %16, i64 %18
  store float 0.000000e+00, ptr %19, align 4
  br label %omp.loop_nest.region49

omp.loop_nest.region49:                           ; preds = %omp.loop_nest.region50, %omp.loop_nest.region48
  %20 = phi i64 [ %48, %omp.loop_nest.region50 ], [ 0, %omp.loop_nest.region48 ]
  %21 = icmp slt i64 %20, 1000
  br i1 %21, label %omp.loop_nest.region50, label %omp.loop_nest.region51

omp.loop_nest.region51:                           ; preds = %omp.loop_nest.region49
  %22 = add i64 %13, 1
  br label %omp.loop_nest.region47

omp.loop_nest.region50:                           ; preds = %omp.loop_nest.region49
  %23 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %24 = getelementptr float, ptr %23, i32 334000
  %25 = mul nuw nsw i64 %11, 1000
  %26 = add nuw nsw i64 %25, %20
  %27 = getelementptr inbounds nuw float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %30 = getelementptr float, ptr %29, i32 334000
  %31 = mul nuw nsw i64 %20, 1000
  %32 = add nuw nsw i64 %31, %13
  %33 = getelementptr inbounds nuw float, ptr %30, i64 %32
  %34 = load float, ptr %33, align 4
  %35 = fmul float %28, %34
  %36 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %37 = getelementptr float, ptr %36, i32 334000
  %38 = mul nuw nsw i64 %11, 1000
  %39 = add nuw nsw i64 %38, %13
  %40 = getelementptr inbounds nuw float, ptr %37, i64 %39
  %41 = load float, ptr %40, align 4
  %42 = fadd float %41, %35
  %43 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %44 = getelementptr float, ptr %43, i32 334000
  %45 = mul nuw nsw i64 %11, 1000
  %46 = add nuw nsw i64 %45, %13
  %47 = getelementptr inbounds nuw float, ptr %44, i64 %46
  store float %42, ptr %47, align 4
  %48 = add i64 %20, 1
  br label %omp.loop_nest.region49

omp.par.exit23.exitStub:                          ; preds = %omp.par.pre_finalize22
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded15 = load ptr, ptr %gep_.reloaded15, align 8, !align !1
  %gep_.reloaded16 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded16 = load ptr, ptr %gep_.reloaded16, align 8, !align !1
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded15, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded16, align 8
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
  store i64 333, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num13 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num13, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
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
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num13)
  %omp_global_thread_num14 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num14)
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
  %9 = add i64 %omp_loop.iv, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region5

omp.loop_nest.region5:                            ; preds = %omp.loop_nest.region
  br label %omp.loop_nest.region6

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region10, %omp.loop_nest.region5
  %13 = phi i64 [ %21, %omp.loop_nest.region10 ], [ 0, %omp.loop_nest.region5 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region7, label %omp.loop_nest.region11

omp.loop_nest.region11:                           ; preds = %omp.loop_nest.region6
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region12

omp.loop_nest.region12:                           ; preds = %omp.loop_nest.region11
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region12
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.loop_nest.region7:                            ; preds = %omp.loop_nest.region6
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = mul nuw nsw i64 %11, 1000
  %17 = add nuw nsw i64 %16, %13
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  store float 0.000000e+00, ptr %18, align 4
  br label %omp.loop_nest.region8

omp.loop_nest.region8:                            ; preds = %omp.loop_nest.region9, %omp.loop_nest.region7
  %19 = phi i64 [ %43, %omp.loop_nest.region9 ], [ 0, %omp.loop_nest.region7 ]
  %20 = icmp slt i64 %19, 1000
  br i1 %20, label %omp.loop_nest.region9, label %omp.loop_nest.region10

omp.loop_nest.region10:                           ; preds = %omp.loop_nest.region8
  %21 = add i64 %13, 1
  br label %omp.loop_nest.region6

omp.loop_nest.region9:                            ; preds = %omp.loop_nest.region8
  %22 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %23 = mul nuw nsw i64 %11, 1000
  %24 = add nuw nsw i64 %23, %19
  %25 = getelementptr inbounds nuw float, ptr %22, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %28 = mul nuw nsw i64 %19, 1000
  %29 = add nuw nsw i64 %28, %13
  %30 = getelementptr inbounds nuw float, ptr %27, i64 %29
  %31 = load float, ptr %30, align 4
  %32 = fmul float %26, %31
  %33 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %34 = mul nuw nsw i64 %11, 1000
  %35 = add nuw nsw i64 %34, %13
  %36 = getelementptr inbounds nuw float, ptr %33, i64 %35
  %37 = load float, ptr %36, align 4
  %38 = fadd float %37, %32
  %39 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %40 = mul nuw nsw i64 %11, 1000
  %41 = add nuw nsw i64 %40, %13
  %42 = getelementptr inbounds nuw float, ptr %39, i64 %41
  store float %38, ptr %42, align 4
  %43 = add i64 %19, 1
  br label %omp.loop_nest.region8

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
