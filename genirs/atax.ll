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

define void @kernel_atax(i32 %0, i32 %1, ptr %2, ptr %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, ptr %19, ptr %20, i64 %21, i64 %22, i64 %23) {
  %structArg142 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg140 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg138 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr, ptr }, align 8
  %.reloaded133 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded134 = alloca i64, align 8
  %.reloaded135 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded136 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded91 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded92 = alloca i64, align 8
  %.reloaded93 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded94 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
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
  %49 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %50 = getelementptr { ptr, ptr, i32, float }, ptr %49, i32 0, i32 0
  %51 = getelementptr { ptr, ptr, i32, float }, ptr %49, i32 0, i32 1
  %52 = getelementptr { ptr, ptr, i32, float }, ptr %49, i32 0, i32 2
  %53 = getelementptr { ptr, ptr, i32, float }, ptr %49, i32 0, i32 3
  store ptr @node_str_0, ptr %50, align 8
  store ptr @arch_str_0, ptr %51, align 8
  store i32 0, ptr %52, align 4
  store float 1.000000e+00, ptr %53, align 4
  %54 = getelementptr { ptr, ptr, i32, float }, ptr %49, i32 1
  %55 = getelementptr { ptr, ptr, i32, float }, ptr %54, i32 0, i32 0
  %56 = getelementptr { ptr, ptr, i32, float }, ptr %54, i32 0, i32 1
  %57 = getelementptr { ptr, ptr, i32, float }, ptr %54, i32 0, i32 2
  %58 = getelementptr { ptr, ptr, i32, float }, ptr %54, i32 0, i32 3
  store ptr @node_str_1, ptr %55, align 8
  store ptr @arch_str_1, ptr %56, align 8
  store i32 0, ptr %57, align 4
  store float 1.000000e+00, ptr %58, align 4
  %59 = getelementptr { ptr, ptr, i32, float }, ptr %49, i32 2
  %60 = getelementptr { ptr, ptr, i32, float }, ptr %59, i32 0, i32 0
  %61 = getelementptr { ptr, ptr, i32, float }, ptr %59, i32 0, i32 1
  %62 = getelementptr { ptr, ptr, i32, float }, ptr %59, i32 0, i32 2
  %63 = getelementptr { ptr, ptr, i32, float }, ptr %59, i32 0, i32 3
  store ptr @node_str_2, ptr %60, align 8
  store ptr @arch_str_2, ptr %61, align 8
  store i32 0, ptr %62, align 4
  store float 1.000000e+00, ptr %63, align 4
  %64 = getelementptr { ptr, ptr, i32, float }, ptr %49, i32 3
  %65 = getelementptr { ptr, ptr, i32, float }, ptr %64, i32 0, i32 0
  %66 = getelementptr { ptr, ptr, i32, float }, ptr %64, i32 0, i32 1
  %67 = getelementptr { ptr, ptr, i32, float }, ptr %64, i32 0, i32 2
  %68 = getelementptr { ptr, ptr, i32, float }, ptr %64, i32 0, i32 3
  store ptr @node_str_3, ptr %65, align 8
  store ptr @arch_str_3, ptr %66, align 8
  store i32 0, ptr %67, align 4
  store float 1.000000e+00, ptr %68, align 4
  %69 = alloca { i32, ptr }, i64 1, align 8
  %70 = getelementptr { i32, ptr }, ptr %69, i32 0, i32 0
  %71 = getelementptr { i32, ptr }, ptr %69, i32 0, i32 1
  store i32 4, ptr %70, align 4
  store ptr %49, ptr %71, align 8
  %72 = call ptr @malloc(i64 16)
  %73 = call ptr @malloc(i64 16)
  %74 = ptrtoint ptr %72 to i64
  %75 = ptrtoint ptr %73 to i64
  %76 = inttoptr i64 %74 to ptr
  %77 = inttoptr i64 %75 to ptr
  call void @buildRankNodeMaps(ptr %69, ptr %76, ptr %77)
  %78 = sext i32 %45 to i64
  %79 = getelementptr inbounds nuw i32, ptr %72, i64 %78
  %80 = load i32, ptr %79, align 4
  br label %81

81:                                               ; preds = %464, %24
  %82 = phi i64 [ %465, %464 ], [ 0, %24 ]
  %83 = icmp slt i64 %82, 128
  br i1 %83, label %84, label %466

84:                                               ; preds = %81
  %85 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 0
  %86 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %87 = insertvalue { ptr, ptr, i64 } poison, ptr %85, 0
  %88 = insertvalue { ptr, ptr, i64 } %87, ptr %86, 1
  %89 = insertvalue { ptr, ptr, i64 } %88, i64 0, 2
  %90 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 2
  %91 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 0
  %92 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 1
  %93 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 0
  %94 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 1
  %95 = extractvalue { ptr, ptr, i64 } %89, 0
  %96 = extractvalue { ptr, ptr, i64 } %89, 1
  %97 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %95, 0
  %98 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %97, ptr %96, 1
  %99 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %98, i64 0, 2
  %100 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %99, i64 32, 3, 0
  %101 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %100, i64 128, 4, 0
  %102 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %101, i64 128, 3, 1
  %103 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %102, i64 1, 4, 1
  %104 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 0
  %105 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 1
  %106 = insertvalue { ptr, ptr, i64 } poison, ptr %104, 0
  %107 = insertvalue { ptr, ptr, i64 } %106, ptr %105, 1
  %108 = insertvalue { ptr, ptr, i64 } %107, i64 0, 2
  %109 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 2
  %110 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 3, 0
  %111 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 4, 0
  %112 = extractvalue { ptr, ptr, i64 } %108, 0
  %113 = extractvalue { ptr, ptr, i64 } %108, 1
  %114 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %112, 0
  %115 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %114, ptr %113, 1
  %116 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %115, i64 0, 2
  %117 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %116, i64 32, 3, 0
  %118 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %117, i64 1, 4, 0
  %119 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %120 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %121 = insertvalue { ptr, ptr, i64 } poison, ptr %119, 0
  %122 = insertvalue { ptr, ptr, i64 } %121, ptr %120, 1
  %123 = insertvalue { ptr, ptr, i64 } %122, i64 0, 2
  %124 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %125 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %126 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %127 = extractvalue { ptr, ptr, i64 } %123, 0
  %128 = extractvalue { ptr, ptr, i64 } %123, 1
  %129 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %127, 0
  %130 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %129, ptr %128, 1
  %131 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %130, i64 0, 2
  %132 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %131, i64 32, 3, 0
  %133 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %132, i64 1, 4, 0
  %134 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 0
  %135 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %136 = insertvalue { ptr, ptr, i64 } poison, ptr %134, 0
  %137 = insertvalue { ptr, ptr, i64 } %136, ptr %135, 1
  %138 = insertvalue { ptr, ptr, i64 } %137, i64 0, 2
  %139 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 2
  %140 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 0
  %141 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 1
  %142 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 0
  %143 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 1
  %144 = extractvalue { ptr, ptr, i64 } %138, 0
  %145 = extractvalue { ptr, ptr, i64 } %138, 1
  %146 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %144, 0
  %147 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, ptr %145, 1
  %148 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %147, i64 4096, 2
  %149 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %148, i64 32, 3, 0
  %150 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %149, i64 128, 4, 0
  %151 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %150, i64 128, 3, 1
  %152 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %151, i64 1, 4, 1
  %153 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 0
  %154 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 1
  %155 = insertvalue { ptr, ptr, i64 } poison, ptr %153, 0
  %156 = insertvalue { ptr, ptr, i64 } %155, ptr %154, 1
  %157 = insertvalue { ptr, ptr, i64 } %156, i64 0, 2
  %158 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 2
  %159 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 3, 0
  %160 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 4, 0
  %161 = extractvalue { ptr, ptr, i64 } %157, 0
  %162 = extractvalue { ptr, ptr, i64 } %157, 1
  %163 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %161, 0
  %164 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %163, ptr %162, 1
  %165 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %164, i64 32, 2
  %166 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %165, i64 32, 3, 0
  %167 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %166, i64 1, 4, 0
  %168 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %169 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %170 = insertvalue { ptr, ptr, i64 } poison, ptr %168, 0
  %171 = insertvalue { ptr, ptr, i64 } %170, ptr %169, 1
  %172 = insertvalue { ptr, ptr, i64 } %171, i64 0, 2
  %173 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %174 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %175 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %176 = extractvalue { ptr, ptr, i64 } %172, 0
  %177 = extractvalue { ptr, ptr, i64 } %172, 1
  %178 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %176, 0
  %179 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %178, ptr %177, 1
  %180 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %179, i64 32, 2
  %181 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %180, i64 32, 3, 0
  %182 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %181, i64 1, 4, 0
  %183 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 0
  %184 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %185 = insertvalue { ptr, ptr, i64 } poison, ptr %183, 0
  %186 = insertvalue { ptr, ptr, i64 } %185, ptr %184, 1
  %187 = insertvalue { ptr, ptr, i64 } %186, i64 0, 2
  %188 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 2
  %189 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 0
  %190 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 1
  %191 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 0
  %192 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 1
  %193 = extractvalue { ptr, ptr, i64 } %187, 0
  %194 = extractvalue { ptr, ptr, i64 } %187, 1
  %195 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %193, 0
  %196 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %195, ptr %194, 1
  %197 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %196, i64 8192, 2
  %198 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %197, i64 32, 3, 0
  %199 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %198, i64 128, 4, 0
  %200 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %199, i64 128, 3, 1
  %201 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %200, i64 1, 4, 1
  %202 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 0
  %203 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 1
  %204 = insertvalue { ptr, ptr, i64 } poison, ptr %202, 0
  %205 = insertvalue { ptr, ptr, i64 } %204, ptr %203, 1
  %206 = insertvalue { ptr, ptr, i64 } %205, i64 0, 2
  %207 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 2
  %208 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 3, 0
  %209 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 4, 0
  %210 = extractvalue { ptr, ptr, i64 } %206, 0
  %211 = extractvalue { ptr, ptr, i64 } %206, 1
  %212 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %210, 0
  %213 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %212, ptr %211, 1
  %214 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %213, i64 64, 2
  %215 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %214, i64 32, 3, 0
  %216 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %215, i64 1, 4, 0
  %217 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %218 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %219 = insertvalue { ptr, ptr, i64 } poison, ptr %217, 0
  %220 = insertvalue { ptr, ptr, i64 } %219, ptr %218, 1
  %221 = insertvalue { ptr, ptr, i64 } %220, i64 0, 2
  %222 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %223 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %224 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %225 = extractvalue { ptr, ptr, i64 } %221, 0
  %226 = extractvalue { ptr, ptr, i64 } %221, 1
  %227 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %225, 0
  %228 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %227, ptr %226, 1
  %229 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %228, i64 64, 2
  %230 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %229, i64 32, 3, 0
  %231 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %230, i64 1, 4, 0
  %232 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 0
  %233 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %234 = insertvalue { ptr, ptr, i64 } poison, ptr %232, 0
  %235 = insertvalue { ptr, ptr, i64 } %234, ptr %233, 1
  %236 = insertvalue { ptr, ptr, i64 } %235, i64 0, 2
  %237 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 2
  %238 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 0
  %239 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 3, 1
  %240 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 0
  %241 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 4, 1
  %242 = extractvalue { ptr, ptr, i64 } %236, 0
  %243 = extractvalue { ptr, ptr, i64 } %236, 1
  %244 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %242, 0
  %245 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %244, ptr %243, 1
  %246 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %245, i64 12288, 2
  %247 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %246, i64 32, 3, 0
  %248 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %247, i64 128, 4, 0
  %249 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %248, i64 128, 3, 1
  %250 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %249, i64 1, 4, 1
  %251 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 0
  %252 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 1
  %253 = insertvalue { ptr, ptr, i64 } poison, ptr %251, 0
  %254 = insertvalue { ptr, ptr, i64 } %253, ptr %252, 1
  %255 = insertvalue { ptr, ptr, i64 } %254, i64 0, 2
  %256 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 2
  %257 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 3, 0
  %258 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, 4, 0
  %259 = extractvalue { ptr, ptr, i64 } %255, 0
  %260 = extractvalue { ptr, ptr, i64 } %255, 1
  %261 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %259, 0
  %262 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %261, ptr %260, 1
  %263 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %262, i64 96, 2
  %264 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %263, i64 32, 3, 0
  %265 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %264, i64 1, 4, 0
  %266 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %267 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %268 = insertvalue { ptr, ptr, i64 } poison, ptr %266, 0
  %269 = insertvalue { ptr, ptr, i64 } %268, ptr %267, 1
  %270 = insertvalue { ptr, ptr, i64 } %269, i64 0, 2
  %271 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %272 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %273 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %274 = extractvalue { ptr, ptr, i64 } %270, 0
  %275 = extractvalue { ptr, ptr, i64 } %270, 1
  %276 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %274, 0
  %277 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %276, ptr %275, 1
  %278 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %277, i64 96, 2
  %279 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %278, i64 32, 3, 0
  %280 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %279, i64 1, 4, 0
  br label %281

281:                                              ; preds = %284, %84
  %282 = phi i64 [ %296, %284 ], [ 0, %84 ]
  %283 = icmp slt i64 %282, 128
  br i1 %283, label %284, label %297

284:                                              ; preds = %281
  %285 = getelementptr inbounds nuw float, ptr %15, i64 %282
  %286 = load float, ptr %285, align 4
  %287 = mul nuw nsw i64 %82, 128
  %288 = add nuw nsw i64 %287, %282
  %289 = getelementptr inbounds nuw float, ptr %3, i64 %288
  %290 = load float, ptr %289, align 4
  %291 = getelementptr inbounds nuw float, ptr %20, i64 %82
  %292 = load float, ptr %291, align 4
  %293 = fmul float %290, %292
  %294 = fadd float %286, %293
  %295 = getelementptr inbounds nuw float, ptr %15, i64 %282
  store float %294, ptr %295, align 4
  %296 = add i64 %282, 1
  br label %281

297:                                              ; preds = %281
  %298 = icmp eq i32 %80, 0
  br i1 %298, label %299, label %300

299:                                              ; preds = %297
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %133, ptr %.reloaded, align 8
  store i64 %82, ptr %.reloaded9, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %.reloaded10, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %118, ptr %.reloaded11, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %299
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
  br label %300

300:                                              ; preds = %omp.par.exit, %297
  %301 = icmp eq i32 %80, 1
  br i1 %301, label %302, label %303

302:                                              ; preds = %300
  %omp_global_thread_num12 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %182, ptr %.reloaded49, align 8
  store i64 %82, ptr %.reloaded50, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %152, ptr %.reloaded51, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %167, ptr %.reloaded52, align 8
  br label %omp_parallel139

omp_parallel139:                                  ; preds = %302
  %gep_.reloaded49 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg138, i32 0, i32 0
  store ptr %.reloaded49, ptr %gep_.reloaded49, align 8
  %gep_.reloaded50 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg138, i32 0, i32 1
  store ptr %.reloaded50, ptr %gep_.reloaded50, align 8
  %gep_.reloaded51 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg138, i32 0, i32 2
  store ptr %.reloaded51, ptr %gep_.reloaded51, align 8
  %gep_.reloaded52 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg138, i32 0, i32 3
  store ptr %.reloaded52, ptr %gep_.reloaded52, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_atax..omp_par.1, ptr %structArg138)
  br label %omp.par.exit18

omp.par.exit18:                                   ; preds = %omp_parallel139
  br label %303

303:                                              ; preds = %omp.par.exit18, %300
  %304 = icmp eq i32 %80, 2
  br i1 %304, label %305, label %306

305:                                              ; preds = %303
  %omp_global_thread_num54 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %231, ptr %.reloaded91, align 8
  store i64 %82, ptr %.reloaded92, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %201, ptr %.reloaded93, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %216, ptr %.reloaded94, align 8
  br label %omp_parallel141

omp_parallel141:                                  ; preds = %305
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg140, i32 0, i32 0
  store ptr %.reloaded91, ptr %gep_.reloaded91, align 8
  %gep_.reloaded92 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg140, i32 0, i32 1
  store ptr %.reloaded92, ptr %gep_.reloaded92, align 8
  %gep_.reloaded93 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg140, i32 0, i32 2
  store ptr %.reloaded93, ptr %gep_.reloaded93, align 8
  %gep_.reloaded94 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg140, i32 0, i32 3
  store ptr %.reloaded94, ptr %gep_.reloaded94, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_atax..omp_par.2, ptr %structArg140)
  br label %omp.par.exit60

omp.par.exit60:                                   ; preds = %omp_parallel141
  br label %306

306:                                              ; preds = %omp.par.exit60, %303
  %307 = icmp eq i32 %80, 3
  br i1 %307, label %308, label %309

308:                                              ; preds = %306
  %omp_global_thread_num96 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %280, ptr %.reloaded133, align 8
  store i64 %82, ptr %.reloaded134, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %250, ptr %.reloaded135, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %265, ptr %.reloaded136, align 8
  br label %omp_parallel143

omp_parallel143:                                  ; preds = %308
  %gep_.reloaded133 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg142, i32 0, i32 0
  store ptr %.reloaded133, ptr %gep_.reloaded133, align 8
  %gep_.reloaded134 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg142, i32 0, i32 1
  store ptr %.reloaded134, ptr %gep_.reloaded134, align 8
  %gep_.reloaded135 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg142, i32 0, i32 2
  store ptr %.reloaded135, ptr %gep_.reloaded135, align 8
  %gep_.reloaded136 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg142, i32 0, i32 3
  store ptr %.reloaded136, ptr %gep_.reloaded136, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_atax..omp_par.3, ptr %structArg142)
  br label %omp.par.exit102

omp.par.exit102:                                  ; preds = %omp_parallel143
  br label %309

309:                                              ; preds = %omp.par.exit102, %306
  %310 = call i32 @MPI_Barrier(i32 1140850688)
  %311 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %312 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %313 = insertvalue { ptr, ptr, i64 } poison, ptr %311, 0
  %314 = insertvalue { ptr, ptr, i64 } %313, ptr %312, 1
  %315 = insertvalue { ptr, ptr, i64 } %314, i64 0, 2
  %316 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %317 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %318 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %319 = extractvalue { ptr, ptr, i64 } %315, 0
  %320 = extractvalue { ptr, ptr, i64 } %315, 1
  %321 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %319, 0
  %322 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %321, ptr %320, 1
  %323 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %322, i64 32, 2
  %324 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %323, i64 32, 3, 0
  %325 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %324, i64 1, 4, 0
  %326 = load i32, ptr %73, align 4
  %327 = getelementptr inbounds nuw i32, ptr %73, i32 1
  %328 = load i32, ptr %327, align 4
  %329 = icmp eq i32 %45, %326
  %330 = icmp eq i32 %45, %328
  br i1 %329, label %331, label %338

331:                                              ; preds = %309
  %332 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %325, 1
  %333 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %325, 2
  %334 = getelementptr float, ptr %332, i64 %333
  %335 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %325, 3, 0
  %336 = trunc i64 %335 to i32
  %337 = call i32 @MPI_Recv(ptr %334, i32 %336, i32 1275069450, i32 %328, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %347

338:                                              ; preds = %309
  br i1 %330, label %339, label %346

339:                                              ; preds = %338
  %340 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %325, 1
  %341 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %325, 2
  %342 = getelementptr float, ptr %340, i64 %341
  %343 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %325, 3, 0
  %344 = trunc i64 %343 to i32
  %345 = call i32 @MPI_Send(ptr %342, i32 %344, i32 1275069450, i32 %326, i32 0, i32 1140850688)
  br label %346

346:                                              ; preds = %339, %338
  br label %347

347:                                              ; preds = %331, %346
  %348 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %349 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %350 = insertvalue { ptr, ptr, i64 } poison, ptr %348, 0
  %351 = insertvalue { ptr, ptr, i64 } %350, ptr %349, 1
  %352 = insertvalue { ptr, ptr, i64 } %351, i64 0, 2
  %353 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %354 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %355 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %356 = extractvalue { ptr, ptr, i64 } %352, 0
  %357 = extractvalue { ptr, ptr, i64 } %352, 1
  %358 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %356, 0
  %359 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %358, ptr %357, 1
  %360 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %359, i64 64, 2
  %361 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %360, i64 32, 3, 0
  %362 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %361, i64 1, 4, 0
  %363 = load i32, ptr %73, align 4
  %364 = getelementptr inbounds nuw i32, ptr %73, i32 2
  %365 = load i32, ptr %364, align 4
  %366 = icmp eq i32 %45, %363
  %367 = icmp eq i32 %45, %365
  br i1 %366, label %368, label %375

368:                                              ; preds = %347
  %369 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %362, 1
  %370 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %362, 2
  %371 = getelementptr float, ptr %369, i64 %370
  %372 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %362, 3, 0
  %373 = trunc i64 %372 to i32
  %374 = call i32 @MPI_Recv(ptr %371, i32 %373, i32 1275069450, i32 %365, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %384

375:                                              ; preds = %347
  br i1 %367, label %376, label %383

376:                                              ; preds = %375
  %377 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %362, 1
  %378 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %362, 2
  %379 = getelementptr float, ptr %377, i64 %378
  %380 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %362, 3, 0
  %381 = trunc i64 %380 to i32
  %382 = call i32 @MPI_Send(ptr %379, i32 %381, i32 1275069450, i32 %363, i32 0, i32 1140850688)
  br label %383

383:                                              ; preds = %376, %375
  br label %384

384:                                              ; preds = %368, %383
  %385 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %386 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %387 = insertvalue { ptr, ptr, i64 } poison, ptr %385, 0
  %388 = insertvalue { ptr, ptr, i64 } %387, ptr %386, 1
  %389 = insertvalue { ptr, ptr, i64 } %388, i64 0, 2
  %390 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %391 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %392 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %393 = extractvalue { ptr, ptr, i64 } %389, 0
  %394 = extractvalue { ptr, ptr, i64 } %389, 1
  %395 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %393, 0
  %396 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %395, ptr %394, 1
  %397 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %396, i64 96, 2
  %398 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %397, i64 32, 3, 0
  %399 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %398, i64 1, 4, 0
  %400 = load i32, ptr %73, align 4
  %401 = getelementptr inbounds nuw i32, ptr %73, i32 3
  %402 = load i32, ptr %401, align 4
  %403 = icmp eq i32 %45, %400
  %404 = icmp eq i32 %45, %402
  br i1 %403, label %405, label %412

405:                                              ; preds = %384
  %406 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %399, 1
  %407 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %399, 2
  %408 = getelementptr float, ptr %406, i64 %407
  %409 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %399, 3, 0
  %410 = trunc i64 %409 to i32
  %411 = call i32 @MPI_Recv(ptr %408, i32 %410, i32 1275069450, i32 %402, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %421

412:                                              ; preds = %384
  br i1 %404, label %413, label %420

413:                                              ; preds = %412
  %414 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %399, 1
  %415 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %399, 2
  %416 = getelementptr float, ptr %414, i64 %415
  %417 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %399, 3, 0
  %418 = trunc i64 %417 to i32
  %419 = call i32 @MPI_Send(ptr %416, i32 %418, i32 1275069450, i32 %400, i32 0, i32 1140850688)
  br label %420

420:                                              ; preds = %413, %412
  br label %421

421:                                              ; preds = %405, %420
  %422 = load i32, ptr %73, align 4
  %423 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 0
  %424 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 1
  %425 = insertvalue { ptr, ptr, i64 } poison, ptr %423, 0
  %426 = insertvalue { ptr, ptr, i64 } %425, ptr %424, 1
  %427 = insertvalue { ptr, ptr, i64 } %426, i64 0, 2
  %428 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 2
  %429 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 3, 0
  %430 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %34, 4, 0
  %431 = extractvalue { ptr, ptr, i64 } %427, 0
  %432 = extractvalue { ptr, ptr, i64 } %427, 1
  %433 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %431, 0
  %434 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %433, ptr %432, 1
  %435 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %434, i64 0, 2
  %436 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %435, i64 128, 3, 0
  %437 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %436, i64 1, 4, 0
  %438 = icmp eq i32 %45, %422
  br i1 %438, label %439, label %457

439:                                              ; preds = %421
  %440 = sext i32 %48 to i64
  br label %441

441:                                              ; preds = %454, %439
  %442 = phi i64 [ %455, %454 ], [ 0, %439 ]
  %443 = icmp slt i64 %442, %440
  br i1 %443, label %444, label %456

444:                                              ; preds = %441
  %445 = trunc i64 %442 to i32
  %446 = icmp ne i32 %445, %422
  br i1 %446, label %447, label %454

447:                                              ; preds = %444
  %448 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %437, 1
  %449 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %437, 2
  %450 = getelementptr float, ptr %448, i64 %449
  %451 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %437, 3, 0
  %452 = trunc i64 %451 to i32
  %453 = call i32 @MPI_Send(ptr %450, i32 %452, i32 1275069450, i32 %445, i32 0, i32 1140850688)
  br label %454

454:                                              ; preds = %447, %444
  %455 = add i64 %442, 1
  br label %441

456:                                              ; preds = %441
  br label %464

457:                                              ; preds = %421
  %458 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %437, 1
  %459 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %437, 2
  %460 = getelementptr float, ptr %458, i64 %459
  %461 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %437, 3, 0
  %462 = trunc i64 %461 to i32
  %463 = call i32 @MPI_Recv(ptr %460, i32 %462, i32 1275069450, i32 %422, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %464

464:                                              ; preds = %456, %457
  %465 = add i64 %82, 1
  br label %81

466:                                              ; preds = %81
  %467 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_atax..omp_par.3(ptr noalias %tid.addr97, ptr noalias %zero.addr98, ptr %0) #0 {
omp.par.entry99:
  %gep_.reloaded133 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded133 = load ptr, ptr %gep_.reloaded133, align 8, !align !1
  %gep_.reloaded134 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded134 = load ptr, ptr %gep_.reloaded134, align 8, !align !1
  %gep_.reloaded135 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded135 = load ptr, ptr %gep_.reloaded135, align 8, !align !1
  %gep_.reloaded136 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded136 = load ptr, ptr %gep_.reloaded136, align 8, !align !1
  %p.lastiter127 = alloca i32, align 4
  %p.lowerbound128 = alloca i64, align 8
  %p.upperbound129 = alloca i64, align 8
  %p.stride130 = alloca i64, align 8
  %tid.addr.local103 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr97, align 4
  store i32 %1, ptr %tid.addr.local103, align 4
  %tid104 = load i32, ptr %tid.addr.local103, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded133, align 8
  %3 = load i64, ptr %loadgep_.reloaded134, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded135, align 8
  %5 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded136, align 8
  br label %omp.region.after_alloca110

omp.region.after_alloca110:                       ; preds = %omp.par.entry99
  br label %omp.region.after_alloca107

omp.region.after_alloca107:                       ; preds = %omp.region.after_alloca110
  br label %omp.par.region100

omp.par.region100:                                ; preds = %omp.region.after_alloca107
  br label %omp.par.region109

omp.par.region109:                                ; preds = %omp.par.region100
  br label %omp.wsloop.region112

omp.wsloop.region112:                             ; preds = %omp.par.region109
  br label %omp_loop.preheader113

omp_loop.preheader113:                            ; preds = %omp.wsloop.region112
  store i64 0, ptr %p.lowerbound128, align 4
  store i64 31, ptr %p.upperbound129, align 4
  store i64 1, ptr %p.stride130, align 4
  %omp_global_thread_num131 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num131, i32 34, ptr %p.lastiter127, ptr %p.lowerbound128, ptr %p.upperbound129, ptr %p.stride130, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound128, align 4
  %7 = load i64, ptr %p.upperbound129, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header114

omp_loop.header114:                               ; preds = %omp_loop.inc117, %omp_loop.preheader113
  %omp_loop.iv120 = phi i64 [ 0, %omp_loop.preheader113 ], [ %omp_loop.next122, %omp_loop.inc117 ]
  br label %omp_loop.cond115

omp_loop.cond115:                                 ; preds = %omp_loop.header114
  %omp_loop.cmp121 = icmp ult i64 %omp_loop.iv120, %9
  br i1 %omp_loop.cmp121, label %omp_loop.body116, label %omp_loop.exit118

omp_loop.exit118:                                 ; preds = %omp_loop.cond115
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num131)
  %omp_global_thread_num132 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num132)
  br label %omp_loop.after119

omp_loop.after119:                                ; preds = %omp_loop.exit118
  br label %omp.region.cont111

omp.region.cont111:                               ; preds = %omp_loop.after119
  br label %omp.region.cont108

omp.region.cont108:                               ; preds = %omp.region.cont111
  br label %omp.par.pre_finalize101

omp.par.pre_finalize101:                          ; preds = %omp.region.cont108
  br label %.fini137

.fini137:                                         ; preds = %omp.par.pre_finalize101
  br label %omp.par.exit102.exitStub

omp_loop.body116:                                 ; preds = %omp_loop.cond115
  %10 = add i64 %omp_loop.iv120, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.loop_nest.region124

omp.loop_nest.region124:                          ; preds = %omp_loop.body116
  %13 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region125

omp.loop_nest.region125:                          ; preds = %omp.loop_nest.region124
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 96
  %16 = getelementptr inbounds nuw float, ptr %15, i64 %3
  %17 = load float, ptr %16, align 4
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %19 = getelementptr float, ptr %18, i32 12288
  %20 = mul nuw nsw i64 %3, 128
  %21 = add nuw nsw i64 %20, %12
  %22 = getelementptr inbounds nuw float, ptr %19, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, 1
  %25 = getelementptr float, ptr %24, i32 96
  %26 = getelementptr inbounds nuw float, ptr %25, i64 %12
  %27 = load float, ptr %26, align 4
  %28 = fmul float %23, %27
  %29 = fadd float %17, %28
  %30 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %31 = getelementptr float, ptr %30, i32 96
  %32 = getelementptr inbounds nuw float, ptr %31, i64 %3
  store float %29, ptr %32, align 4
  call void @llvm.stackrestore.p0(ptr %13)
  br label %omp.loop_nest.region126

omp.loop_nest.region126:                          ; preds = %omp.loop_nest.region125
  br label %omp.region.cont123

omp.region.cont123:                               ; preds = %omp.loop_nest.region126
  br label %omp_loop.inc117

omp_loop.inc117:                                  ; preds = %omp.region.cont123
  %omp_loop.next122 = add nuw i64 %omp_loop.iv120, 1
  br label %omp_loop.header114

omp.par.exit102.exitStub:                         ; preds = %.fini137
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_atax..omp_par.2(ptr noalias %tid.addr55, ptr noalias %zero.addr56, ptr %0) #0 {
omp.par.entry57:
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded91 = load ptr, ptr %gep_.reloaded91, align 8, !align !1
  %gep_.reloaded92 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded92 = load ptr, ptr %gep_.reloaded92, align 8, !align !1
  %gep_.reloaded93 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded93 = load ptr, ptr %gep_.reloaded93, align 8, !align !1
  %gep_.reloaded94 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_.reloaded94 = load ptr, ptr %gep_.reloaded94, align 8, !align !1
  %p.lastiter85 = alloca i32, align 4
  %p.lowerbound86 = alloca i64, align 8
  %p.upperbound87 = alloca i64, align 8
  %p.stride88 = alloca i64, align 8
  %tid.addr.local61 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr55, align 4
  store i32 %1, ptr %tid.addr.local61, align 4
  %tid62 = load i32, ptr %tid.addr.local61, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded91, align 8
  %3 = load i64, ptr %loadgep_.reloaded92, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded93, align 8
  %5 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded94, align 8
  br label %omp.region.after_alloca68

omp.region.after_alloca68:                        ; preds = %omp.par.entry57
  br label %omp.region.after_alloca65

omp.region.after_alloca65:                        ; preds = %omp.region.after_alloca68
  br label %omp.par.region58

omp.par.region58:                                 ; preds = %omp.region.after_alloca65
  br label %omp.par.region67

omp.par.region67:                                 ; preds = %omp.par.region58
  br label %omp.wsloop.region70

omp.wsloop.region70:                              ; preds = %omp.par.region67
  br label %omp_loop.preheader71

omp_loop.preheader71:                             ; preds = %omp.wsloop.region70
  store i64 0, ptr %p.lowerbound86, align 4
  store i64 31, ptr %p.upperbound87, align 4
  store i64 1, ptr %p.stride88, align 4
  %omp_global_thread_num89 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num89, i32 34, ptr %p.lastiter85, ptr %p.lowerbound86, ptr %p.upperbound87, ptr %p.stride88, i64 1, i64 0)
  %6 = load i64, ptr %p.lowerbound86, align 4
  %7 = load i64, ptr %p.upperbound87, align 4
  %8 = sub i64 %7, %6
  %9 = add i64 %8, 1
  br label %omp_loop.header72

omp_loop.header72:                                ; preds = %omp_loop.inc75, %omp_loop.preheader71
  %omp_loop.iv78 = phi i64 [ 0, %omp_loop.preheader71 ], [ %omp_loop.next80, %omp_loop.inc75 ]
  br label %omp_loop.cond73

omp_loop.cond73:                                  ; preds = %omp_loop.header72
  %omp_loop.cmp79 = icmp ult i64 %omp_loop.iv78, %9
  br i1 %omp_loop.cmp79, label %omp_loop.body74, label %omp_loop.exit76

omp_loop.exit76:                                  ; preds = %omp_loop.cond73
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num89)
  %omp_global_thread_num90 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num90)
  br label %omp_loop.after77

omp_loop.after77:                                 ; preds = %omp_loop.exit76
  br label %omp.region.cont69

omp.region.cont69:                                ; preds = %omp_loop.after77
  br label %omp.region.cont66

omp.region.cont66:                                ; preds = %omp.region.cont69
  br label %omp.par.pre_finalize59

omp.par.pre_finalize59:                           ; preds = %omp.region.cont66
  br label %.fini95

.fini95:                                          ; preds = %omp.par.pre_finalize59
  br label %omp.par.exit60.exitStub

omp_loop.body74:                                  ; preds = %omp_loop.cond73
  %10 = add i64 %omp_loop.iv78, %6
  %11 = mul i64 %10, 1
  %12 = add i64 %11, 0
  br label %omp.loop_nest.region82

omp.loop_nest.region82:                           ; preds = %omp_loop.body74
  %13 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region83

omp.loop_nest.region83:                           ; preds = %omp.loop_nest.region82
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 64
  %16 = getelementptr inbounds nuw float, ptr %15, i64 %3
  %17 = load float, ptr %16, align 4
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %19 = getelementptr float, ptr %18, i32 8192
  %20 = mul nuw nsw i64 %3, 128
  %21 = add nuw nsw i64 %20, %12
  %22 = getelementptr inbounds nuw float, ptr %19, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, 1
  %25 = getelementptr float, ptr %24, i32 64
  %26 = getelementptr inbounds nuw float, ptr %25, i64 %12
  %27 = load float, ptr %26, align 4
  %28 = fmul float %23, %27
  %29 = fadd float %17, %28
  %30 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %31 = getelementptr float, ptr %30, i32 64
  %32 = getelementptr inbounds nuw float, ptr %31, i64 %3
  store float %29, ptr %32, align 4
  call void @llvm.stackrestore.p0(ptr %13)
  br label %omp.loop_nest.region84

omp.loop_nest.region84:                           ; preds = %omp.loop_nest.region83
  br label %omp.region.cont81

omp.region.cont81:                                ; preds = %omp.loop_nest.region84
  br label %omp_loop.inc75

omp_loop.inc75:                                   ; preds = %omp.region.cont81
  %omp_loop.next80 = add nuw i64 %omp_loop.iv78, 1
  br label %omp_loop.header72

omp.par.exit60.exitStub:                          ; preds = %.fini95
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
  store i64 31, ptr %p.upperbound45, align 4
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
  br label %.fini53

.fini53:                                          ; preds = %omp.par.pre_finalize17
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
  %15 = getelementptr float, ptr %14, i32 32
  %16 = getelementptr inbounds nuw float, ptr %15, i64 %3
  %17 = load float, ptr %16, align 4
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %19 = getelementptr float, ptr %18, i32 4096
  %20 = mul nuw nsw i64 %3, 128
  %21 = add nuw nsw i64 %20, %12
  %22 = getelementptr inbounds nuw float, ptr %19, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, 1
  %25 = getelementptr float, ptr %24, i32 32
  %26 = getelementptr inbounds nuw float, ptr %25, i64 %12
  %27 = load float, ptr %26, align 4
  %28 = fmul float %23, %27
  %29 = fadd float %17, %28
  %30 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %31 = getelementptr float, ptr %30, i32 32
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

omp.par.exit18.exitStub:                          ; preds = %.fini53
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
  store i64 31, ptr %p.upperbound, align 4
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
  br label %.fini

.fini:                                            ; preds = %omp.par.pre_finalize
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
!1 = !{i64 8}
!2 = !{!3}
!3 = !{i64 2, i64 -1, i64 -1, i1 true}
