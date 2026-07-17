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

define void @kernel_syr2k(i32 %0, i32 %1, float %2, float %3, ptr %4, ptr %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, ptr %11, ptr %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17, ptr %18, ptr %19, i64 %20, i64 %21, i64 %22, i64 %23, i64 %24) {
  %structArg335 = alloca { ptr, ptr, ptr, ptr, ptr }, align 8
  %structArg331 = alloca { ptr, ptr, ptr, ptr, ptr }, align 8
  %structArg327 = alloca { ptr, ptr, ptr, ptr, ptr }, align 8
  %structArg324 = alloca { ptr, ptr, ptr, ptr, ptr }, align 8
  %structArg322 = alloca { ptr, ptr }, align 8
  %structArg320 = alloca { ptr, ptr }, align 8
  %structArg318 = alloca { ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr }, align 8
  %.reloaded314 = alloca i64, align 8
  %.reloaded315 = alloca float, align 4
  %.reloaded316 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded270 = alloca i64, align 8
  %.reloaded271 = alloca float, align 4
  %.reloaded272 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded226 = alloca i64, align 8
  %.reloaded227 = alloca float, align 4
  %.reloaded228 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded182 = alloca i64, align 8
  %.reloaded183 = alloca float, align 4
  %.reloaded184 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded139 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded140 = alloca float, align 4
  %.reloaded96 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded97 = alloca float, align 4
  %.reloaded53 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded54 = alloca float, align 4
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded12 = alloca float, align 4
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %4, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, ptr %5, 1
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %6, 2
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %7, 3, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %9, 4, 0
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %8, 3, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, i64 %10, 4, 1
  %33 = call i32 @MPI_Init(ptr null, ptr null)
  %34 = alloca i32, align 4
  %35 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %34)
  %36 = load i32, ptr %34, align 4
  %37 = alloca i32, align 4
  %38 = call i32 @MPI_Comm_size(i32 1140850688, ptr %37)
  %39 = load i32, ptr %37, align 4
  %40 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %41 = getelementptr { ptr, ptr, i32, float }, ptr %40, i32 0, i32 0
  %42 = getelementptr { ptr, ptr, i32, float }, ptr %40, i32 0, i32 1
  %43 = getelementptr { ptr, ptr, i32, float }, ptr %40, i32 0, i32 2
  %44 = getelementptr { ptr, ptr, i32, float }, ptr %40, i32 0, i32 3
  store ptr @node_str_0, ptr %41, align 8
  store ptr @arch_str_0, ptr %42, align 8
  store i32 0, ptr %43, align 4
  store float 1.000000e+00, ptr %44, align 4
  %45 = getelementptr { ptr, ptr, i32, float }, ptr %40, i32 1
  %46 = getelementptr { ptr, ptr, i32, float }, ptr %45, i32 0, i32 0
  %47 = getelementptr { ptr, ptr, i32, float }, ptr %45, i32 0, i32 1
  %48 = getelementptr { ptr, ptr, i32, float }, ptr %45, i32 0, i32 2
  %49 = getelementptr { ptr, ptr, i32, float }, ptr %45, i32 0, i32 3
  store ptr @node_str_1, ptr %46, align 8
  store ptr @arch_str_1, ptr %47, align 8
  store i32 0, ptr %48, align 4
  store float 1.000000e+00, ptr %49, align 4
  %50 = getelementptr { ptr, ptr, i32, float }, ptr %40, i32 2
  %51 = getelementptr { ptr, ptr, i32, float }, ptr %50, i32 0, i32 0
  %52 = getelementptr { ptr, ptr, i32, float }, ptr %50, i32 0, i32 1
  %53 = getelementptr { ptr, ptr, i32, float }, ptr %50, i32 0, i32 2
  %54 = getelementptr { ptr, ptr, i32, float }, ptr %50, i32 0, i32 3
  store ptr @node_str_2, ptr %51, align 8
  store ptr @arch_str_2, ptr %52, align 8
  store i32 0, ptr %53, align 4
  store float 1.000000e+00, ptr %54, align 4
  %55 = getelementptr { ptr, ptr, i32, float }, ptr %40, i32 3
  %56 = getelementptr { ptr, ptr, i32, float }, ptr %55, i32 0, i32 0
  %57 = getelementptr { ptr, ptr, i32, float }, ptr %55, i32 0, i32 1
  %58 = getelementptr { ptr, ptr, i32, float }, ptr %55, i32 0, i32 2
  %59 = getelementptr { ptr, ptr, i32, float }, ptr %55, i32 0, i32 3
  store ptr @node_str_3, ptr %56, align 8
  store ptr @arch_str_3, ptr %57, align 8
  store i32 0, ptr %58, align 4
  store float 1.000000e+00, ptr %59, align 4
  %60 = alloca { i32, ptr }, i64 1, align 8
  %61 = getelementptr { i32, ptr }, ptr %60, i32 0, i32 0
  %62 = getelementptr { i32, ptr }, ptr %60, i32 0, i32 1
  store i32 4, ptr %61, align 4
  store ptr %40, ptr %62, align 8
  %63 = call ptr @malloc(i64 16)
  %64 = call ptr @malloc(i64 16)
  %65 = ptrtoint ptr %63 to i64
  %66 = ptrtoint ptr %64 to i64
  %67 = inttoptr i64 %65 to ptr
  %68 = inttoptr i64 %66 to ptr
  call void @buildRankNodeMaps(ptr %60, ptr %67, ptr %68)
  %69 = sext i32 %36 to i64
  %70 = getelementptr inbounds nuw i32, ptr %63, i64 %69
  %71 = load i32, ptr %70, align 4
  %72 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %73 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %74 = insertvalue { ptr, ptr, i64 } poison, ptr %72, 0
  %75 = insertvalue { ptr, ptr, i64 } %74, ptr %73, 1
  %76 = insertvalue { ptr, ptr, i64 } %75, i64 0, 2
  %77 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %78 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %79 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %81 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %82 = extractvalue { ptr, ptr, i64 } %76, 0
  %83 = extractvalue { ptr, ptr, i64 } %76, 1
  %84 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %82, 0
  %85 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %84, ptr %83, 1
  %86 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %85, i64 0, 2
  %87 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %86, i64 250, 3, 0
  %88 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %87, i64 1000, 4, 0
  %89 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %88, i64 1000, 3, 1
  %90 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %89, i64 1, 4, 1
  %91 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %92 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %93 = insertvalue { ptr, ptr, i64 } poison, ptr %91, 0
  %94 = insertvalue { ptr, ptr, i64 } %93, ptr %92, 1
  %95 = insertvalue { ptr, ptr, i64 } %94, i64 0, 2
  %96 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %97 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %98 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %99 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %100 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %101 = extractvalue { ptr, ptr, i64 } %95, 0
  %102 = extractvalue { ptr, ptr, i64 } %95, 1
  %103 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %101, 0
  %104 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %102, 1
  %105 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %104, i64 250000, 2
  %106 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, i64 250, 3, 0
  %107 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %106, i64 1000, 4, 0
  %108 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %107, i64 1000, 3, 1
  %109 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %108, i64 1, 4, 1
  %110 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %111 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %112 = insertvalue { ptr, ptr, i64 } poison, ptr %110, 0
  %113 = insertvalue { ptr, ptr, i64 } %112, ptr %111, 1
  %114 = insertvalue { ptr, ptr, i64 } %113, i64 0, 2
  %115 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %116 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %117 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %118 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %119 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %120 = extractvalue { ptr, ptr, i64 } %114, 0
  %121 = extractvalue { ptr, ptr, i64 } %114, 1
  %122 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %120, 0
  %123 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %122, ptr %121, 1
  %124 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %123, i64 500000, 2
  %125 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %124, i64 250, 3, 0
  %126 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %125, i64 1000, 4, 0
  %127 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %126, i64 1000, 3, 1
  %128 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %127, i64 1, 4, 1
  %129 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %130 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %131 = insertvalue { ptr, ptr, i64 } poison, ptr %129, 0
  %132 = insertvalue { ptr, ptr, i64 } %131, ptr %130, 1
  %133 = insertvalue { ptr, ptr, i64 } %132, i64 0, 2
  %134 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %135 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %136 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %137 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %138 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %139 = extractvalue { ptr, ptr, i64 } %133, 0
  %140 = extractvalue { ptr, ptr, i64 } %133, 1
  %141 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %139, 0
  %142 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %141, ptr %140, 1
  %143 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %142, i64 750000, 2
  %144 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %143, i64 250, 3, 0
  %145 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %144, i64 1000, 4, 0
  %146 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %145, i64 1000, 3, 1
  %147 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, i64 1, 4, 1
  br label %148

148:                                              ; preds = %546, %25
  %149 = phi i64 [ %547, %546 ], [ 0, %25 ]
  %150 = icmp slt i64 %149, 1000
  br i1 %150, label %151, label %548

151:                                              ; preds = %148
  %152 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %153 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %154 = insertvalue { ptr, ptr, i64 } poison, ptr %152, 0
  %155 = insertvalue { ptr, ptr, i64 } %154, ptr %153, 1
  %156 = insertvalue { ptr, ptr, i64 } %155, i64 0, 2
  %157 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %158 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %159 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %160 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %161 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %162 = extractvalue { ptr, ptr, i64 } %156, 0
  %163 = extractvalue { ptr, ptr, i64 } %156, 1
  %164 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %162, 0
  %165 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %164, ptr %163, 1
  %166 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %165, i64 0, 2
  %167 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, i64 250, 3, 0
  %168 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %167, i64 1000, 4, 0
  %169 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %168, i64 1000, 3, 1
  %170 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %169, i64 1, 4, 1
  %171 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %172 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %173 = insertvalue { ptr, ptr, i64 } poison, ptr %171, 0
  %174 = insertvalue { ptr, ptr, i64 } %173, ptr %172, 1
  %175 = insertvalue { ptr, ptr, i64 } %174, i64 0, 2
  %176 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %177 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %178 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %179 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %180 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %181 = extractvalue { ptr, ptr, i64 } %175, 0
  %182 = extractvalue { ptr, ptr, i64 } %175, 1
  %183 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %181, 0
  %184 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %183, ptr %182, 1
  %185 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %184, i64 250000, 2
  %186 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, i64 250, 3, 0
  %187 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %186, i64 1000, 4, 0
  %188 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, i64 1000, 3, 1
  %189 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %188, i64 1, 4, 1
  %190 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %191 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %192 = insertvalue { ptr, ptr, i64 } poison, ptr %190, 0
  %193 = insertvalue { ptr, ptr, i64 } %192, ptr %191, 1
  %194 = insertvalue { ptr, ptr, i64 } %193, i64 0, 2
  %195 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %196 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %197 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %198 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %199 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %200 = extractvalue { ptr, ptr, i64 } %194, 0
  %201 = extractvalue { ptr, ptr, i64 } %194, 1
  %202 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %200, 0
  %203 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %202, ptr %201, 1
  %204 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %203, i64 500000, 2
  %205 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, i64 250, 3, 0
  %206 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %205, i64 1000, 4, 0
  %207 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %206, i64 1000, 3, 1
  %208 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %207, i64 1, 4, 1
  %209 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %210 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %211 = insertvalue { ptr, ptr, i64 } poison, ptr %209, 0
  %212 = insertvalue { ptr, ptr, i64 } %211, ptr %210, 1
  %213 = insertvalue { ptr, ptr, i64 } %212, i64 0, 2
  %214 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %215 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %216 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %217 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %218 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %219 = extractvalue { ptr, ptr, i64 } %213, 0
  %220 = extractvalue { ptr, ptr, i64 } %213, 1
  %221 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %219, 0
  %222 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %221, ptr %220, 1
  %223 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %222, i64 750000, 2
  %224 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, i64 250, 3, 0
  %225 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %224, i64 1000, 4, 0
  %226 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %225, i64 1000, 3, 1
  %227 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %226, i64 1, 4, 1
  %228 = icmp eq i32 %71, 0
  br i1 %228, label %229, label %230

229:                                              ; preds = %151
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %90, ptr %.reloaded, align 8
  store float %3, ptr %.reloaded12, align 4
  br label %omp_parallel

omp_parallel:                                     ; preds = %229
  %gep_.reloaded = getelementptr { ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded12 = getelementptr { ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded12, ptr %gep_.reloaded12, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %230

230:                                              ; preds = %omp.par.exit, %151
  %231 = icmp eq i32 %71, 1
  br i1 %231, label %232, label %233

232:                                              ; preds = %230
  %omp_global_thread_num13 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, ptr %.reloaded53, align 8
  store float %3, ptr %.reloaded54, align 4
  br label %omp_parallel319

omp_parallel319:                                  ; preds = %232
  %gep_.reloaded53 = getelementptr { ptr, ptr }, ptr %structArg318, i32 0, i32 0
  store ptr %.reloaded53, ptr %gep_.reloaded53, align 8
  %gep_.reloaded54 = getelementptr { ptr, ptr }, ptr %structArg318, i32 0, i32 1
  store ptr %.reloaded54, ptr %gep_.reloaded54, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par.1, ptr %structArg318)
  br label %omp.par.exit19

omp.par.exit19:                                   ; preds = %omp_parallel319
  br label %233

233:                                              ; preds = %omp.par.exit19, %230
  %234 = icmp eq i32 %71, 2
  br i1 %234, label %235, label %236

235:                                              ; preds = %233
  %omp_global_thread_num56 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %128, ptr %.reloaded96, align 8
  store float %3, ptr %.reloaded97, align 4
  br label %omp_parallel321

omp_parallel321:                                  ; preds = %235
  %gep_.reloaded96 = getelementptr { ptr, ptr }, ptr %structArg320, i32 0, i32 0
  store ptr %.reloaded96, ptr %gep_.reloaded96, align 8
  %gep_.reloaded97 = getelementptr { ptr, ptr }, ptr %structArg320, i32 0, i32 1
  store ptr %.reloaded97, ptr %gep_.reloaded97, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par.2, ptr %structArg320)
  br label %omp.par.exit62

omp.par.exit62:                                   ; preds = %omp_parallel321
  br label %236

236:                                              ; preds = %omp.par.exit62, %233
  %237 = icmp eq i32 %71, 3
  br i1 %237, label %238, label %239

238:                                              ; preds = %236
  %omp_global_thread_num99 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %147, ptr %.reloaded139, align 8
  store float %3, ptr %.reloaded140, align 4
  br label %omp_parallel323

omp_parallel323:                                  ; preds = %238
  %gep_.reloaded139 = getelementptr { ptr, ptr }, ptr %structArg322, i32 0, i32 0
  store ptr %.reloaded139, ptr %gep_.reloaded139, align 8
  %gep_.reloaded140 = getelementptr { ptr, ptr }, ptr %structArg322, i32 0, i32 1
  store ptr %.reloaded140, ptr %gep_.reloaded140, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par.3, ptr %structArg322)
  br label %omp.par.exit105

omp.par.exit105:                                  ; preds = %omp_parallel323
  br label %239

239:                                              ; preds = %omp.par.exit105, %236
  %240 = call i32 @MPI_Barrier(i32 1140850688)
  %241 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %242 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %243 = insertvalue { ptr, ptr, i64 } poison, ptr %241, 0
  %244 = insertvalue { ptr, ptr, i64 } %243, ptr %242, 1
  %245 = insertvalue { ptr, ptr, i64 } %244, i64 0, 2
  %246 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %247 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %248 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %249 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %250 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %251 = extractvalue { ptr, ptr, i64 } %245, 0
  %252 = extractvalue { ptr, ptr, i64 } %245, 1
  %253 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %251, 0
  %254 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %253, ptr %252, 1
  %255 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %254, i64 250000, 2
  %256 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, i64 250, 3, 0
  %257 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %256, i64 1000, 4, 0
  %258 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %257, i64 1000, 3, 1
  %259 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %258, i64 1, 4, 1
  %260 = load i32, ptr %64, align 4
  %261 = getelementptr inbounds nuw i32, ptr %64, i32 1
  %262 = load i32, ptr %261, align 4
  %263 = icmp eq i32 %36, %260
  %264 = icmp eq i32 %36, %262
  br i1 %263, label %265, label %272

265:                                              ; preds = %239
  %266 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %259, 1
  %267 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %259, 2
  %268 = getelementptr float, ptr %266, i64 %267
  %269 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %259, 3, 0
  %270 = trunc i64 %269 to i32
  %271 = call i32 @MPI_Recv(ptr %268, i32 %270, i32 1275069450, i32 %262, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %281

272:                                              ; preds = %239
  br i1 %264, label %273, label %280

273:                                              ; preds = %272
  %274 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %259, 1
  %275 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %259, 2
  %276 = getelementptr float, ptr %274, i64 %275
  %277 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %259, 3, 0
  %278 = trunc i64 %277 to i32
  %279 = call i32 @MPI_Send(ptr %276, i32 %278, i32 1275069450, i32 %260, i32 0, i32 1140850688)
  br label %280

280:                                              ; preds = %273, %272
  br label %281

281:                                              ; preds = %265, %280
  %282 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %283 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %284 = insertvalue { ptr, ptr, i64 } poison, ptr %282, 0
  %285 = insertvalue { ptr, ptr, i64 } %284, ptr %283, 1
  %286 = insertvalue { ptr, ptr, i64 } %285, i64 0, 2
  %287 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %288 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %289 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %290 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %291 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %292 = extractvalue { ptr, ptr, i64 } %286, 0
  %293 = extractvalue { ptr, ptr, i64 } %286, 1
  %294 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %292, 0
  %295 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %294, ptr %293, 1
  %296 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %295, i64 500000, 2
  %297 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %296, i64 250, 3, 0
  %298 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, i64 1000, 4, 0
  %299 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %298, i64 1000, 3, 1
  %300 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %299, i64 1, 4, 1
  %301 = load i32, ptr %64, align 4
  %302 = getelementptr inbounds nuw i32, ptr %64, i32 2
  %303 = load i32, ptr %302, align 4
  %304 = icmp eq i32 %36, %301
  %305 = icmp eq i32 %36, %303
  br i1 %304, label %306, label %313

306:                                              ; preds = %281
  %307 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %300, 1
  %308 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %300, 2
  %309 = getelementptr float, ptr %307, i64 %308
  %310 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %300, 3, 0
  %311 = trunc i64 %310 to i32
  %312 = call i32 @MPI_Recv(ptr %309, i32 %311, i32 1275069450, i32 %303, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %322

313:                                              ; preds = %281
  br i1 %305, label %314, label %321

314:                                              ; preds = %313
  %315 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %300, 1
  %316 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %300, 2
  %317 = getelementptr float, ptr %315, i64 %316
  %318 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %300, 3, 0
  %319 = trunc i64 %318 to i32
  %320 = call i32 @MPI_Send(ptr %317, i32 %319, i32 1275069450, i32 %301, i32 0, i32 1140850688)
  br label %321

321:                                              ; preds = %314, %313
  br label %322

322:                                              ; preds = %306, %321
  %323 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %324 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %325 = insertvalue { ptr, ptr, i64 } poison, ptr %323, 0
  %326 = insertvalue { ptr, ptr, i64 } %325, ptr %324, 1
  %327 = insertvalue { ptr, ptr, i64 } %326, i64 0, 2
  %328 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %329 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %330 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %331 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %332 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %333 = extractvalue { ptr, ptr, i64 } %327, 0
  %334 = extractvalue { ptr, ptr, i64 } %327, 1
  %335 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %333, 0
  %336 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %335, ptr %334, 1
  %337 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %336, i64 750000, 2
  %338 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %337, i64 250, 3, 0
  %339 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %338, i64 1000, 4, 0
  %340 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %339, i64 1000, 3, 1
  %341 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, i64 1, 4, 1
  %342 = load i32, ptr %64, align 4
  %343 = getelementptr inbounds nuw i32, ptr %64, i32 3
  %344 = load i32, ptr %343, align 4
  %345 = icmp eq i32 %36, %342
  %346 = icmp eq i32 %36, %344
  br i1 %345, label %347, label %354

347:                                              ; preds = %322
  %348 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 1
  %349 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 2
  %350 = getelementptr float, ptr %348, i64 %349
  %351 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 3, 0
  %352 = trunc i64 %351 to i32
  %353 = call i32 @MPI_Recv(ptr %350, i32 %352, i32 1275069450, i32 %344, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %363

354:                                              ; preds = %322
  br i1 %346, label %355, label %362

355:                                              ; preds = %354
  %356 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 1
  %357 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 2
  %358 = getelementptr float, ptr %356, i64 %357
  %359 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 3, 0
  %360 = trunc i64 %359 to i32
  %361 = call i32 @MPI_Send(ptr %358, i32 %360, i32 1275069450, i32 %342, i32 0, i32 1140850688)
  br label %362

362:                                              ; preds = %355, %354
  br label %363

363:                                              ; preds = %347, %362
  %364 = icmp eq i32 %71, 0
  br i1 %364, label %365, label %366

365:                                              ; preds = %363
  %omp_global_thread_num142 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %149, ptr %.reloaded182, align 4
  store float %2, ptr %.reloaded183, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %170, ptr %.reloaded184, align 8
  br label %omp_parallel326

omp_parallel326:                                  ; preds = %365
  %gep_.reloaded182 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 0
  store ptr %.reloaded182, ptr %gep_.reloaded182, align 8
  %gep_.reloaded183 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 1
  store ptr %.reloaded183, ptr %gep_.reloaded183, align 8
  %gep_.reloaded184 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 2
  store ptr %.reloaded184, ptr %gep_.reloaded184, align 8
  %gep_ = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 3
  store ptr %12, ptr %gep_, align 8
  %gep_325 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 4
  store ptr %19, ptr %gep_325, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par.4, ptr %structArg324)
  br label %omp.par.exit148

omp.par.exit148:                                  ; preds = %omp_parallel326
  br label %366

366:                                              ; preds = %omp.par.exit148, %363
  %367 = icmp eq i32 %71, 1
  br i1 %367, label %368, label %369

368:                                              ; preds = %366
  %omp_global_thread_num186 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %149, ptr %.reloaded226, align 4
  store float %2, ptr %.reloaded227, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %189, ptr %.reloaded228, align 8
  br label %omp_parallel330

omp_parallel330:                                  ; preds = %368
  %gep_.reloaded226 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg327, i32 0, i32 0
  store ptr %.reloaded226, ptr %gep_.reloaded226, align 8
  %gep_.reloaded227 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg327, i32 0, i32 1
  store ptr %.reloaded227, ptr %gep_.reloaded227, align 8
  %gep_.reloaded228 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg327, i32 0, i32 2
  store ptr %.reloaded228, ptr %gep_.reloaded228, align 8
  %gep_328 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg327, i32 0, i32 3
  store ptr %12, ptr %gep_328, align 8
  %gep_329 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg327, i32 0, i32 4
  store ptr %19, ptr %gep_329, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par.5, ptr %structArg327)
  br label %omp.par.exit192

omp.par.exit192:                                  ; preds = %omp_parallel330
  br label %369

369:                                              ; preds = %omp.par.exit192, %366
  %370 = icmp eq i32 %71, 2
  br i1 %370, label %371, label %372

371:                                              ; preds = %369
  %omp_global_thread_num230 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %149, ptr %.reloaded270, align 4
  store float %2, ptr %.reloaded271, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %208, ptr %.reloaded272, align 8
  br label %omp_parallel334

omp_parallel334:                                  ; preds = %371
  %gep_.reloaded270 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg331, i32 0, i32 0
  store ptr %.reloaded270, ptr %gep_.reloaded270, align 8
  %gep_.reloaded271 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg331, i32 0, i32 1
  store ptr %.reloaded271, ptr %gep_.reloaded271, align 8
  %gep_.reloaded272 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg331, i32 0, i32 2
  store ptr %.reloaded272, ptr %gep_.reloaded272, align 8
  %gep_332 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg331, i32 0, i32 3
  store ptr %12, ptr %gep_332, align 8
  %gep_333 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg331, i32 0, i32 4
  store ptr %19, ptr %gep_333, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par.6, ptr %structArg331)
  br label %omp.par.exit236

omp.par.exit236:                                  ; preds = %omp_parallel334
  br label %372

372:                                              ; preds = %omp.par.exit236, %369
  %373 = icmp eq i32 %71, 3
  br i1 %373, label %374, label %375

374:                                              ; preds = %372
  %omp_global_thread_num274 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %149, ptr %.reloaded314, align 4
  store float %2, ptr %.reloaded315, align 4
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %227, ptr %.reloaded316, align 8
  br label %omp_parallel338

omp_parallel338:                                  ; preds = %374
  %gep_.reloaded314 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg335, i32 0, i32 0
  store ptr %.reloaded314, ptr %gep_.reloaded314, align 8
  %gep_.reloaded315 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg335, i32 0, i32 1
  store ptr %.reloaded315, ptr %gep_.reloaded315, align 8
  %gep_.reloaded316 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg335, i32 0, i32 2
  store ptr %.reloaded316, ptr %gep_.reloaded316, align 8
  %gep_336 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg335, i32 0, i32 3
  store ptr %12, ptr %gep_336, align 8
  %gep_337 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %structArg335, i32 0, i32 4
  store ptr %19, ptr %gep_337, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syr2k..omp_par.7, ptr %structArg335)
  br label %omp.par.exit280

omp.par.exit280:                                  ; preds = %omp_parallel338
  br label %375

375:                                              ; preds = %omp.par.exit280, %372
  %376 = call i32 @MPI_Barrier(i32 1140850688)
  %377 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %378 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %379 = insertvalue { ptr, ptr, i64 } poison, ptr %377, 0
  %380 = insertvalue { ptr, ptr, i64 } %379, ptr %378, 1
  %381 = insertvalue { ptr, ptr, i64 } %380, i64 0, 2
  %382 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %383 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %384 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %385 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %386 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %387 = extractvalue { ptr, ptr, i64 } %381, 0
  %388 = extractvalue { ptr, ptr, i64 } %381, 1
  %389 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %387, 0
  %390 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %389, ptr %388, 1
  %391 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %390, i64 250000, 2
  %392 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %391, i64 250, 3, 0
  %393 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %392, i64 1000, 4, 0
  %394 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %393, i64 1000, 3, 1
  %395 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %394, i64 1, 4, 1
  %396 = load i32, ptr %64, align 4
  %397 = getelementptr inbounds nuw i32, ptr %64, i32 1
  %398 = load i32, ptr %397, align 4
  %399 = icmp eq i32 %36, %396
  %400 = icmp eq i32 %36, %398
  br i1 %399, label %401, label %408

401:                                              ; preds = %375
  %402 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %395, 1
  %403 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %395, 2
  %404 = getelementptr float, ptr %402, i64 %403
  %405 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %395, 3, 0
  %406 = trunc i64 %405 to i32
  %407 = call i32 @MPI_Recv(ptr %404, i32 %406, i32 1275069450, i32 %398, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %417

408:                                              ; preds = %375
  br i1 %400, label %409, label %416

409:                                              ; preds = %408
  %410 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %395, 1
  %411 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %395, 2
  %412 = getelementptr float, ptr %410, i64 %411
  %413 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %395, 3, 0
  %414 = trunc i64 %413 to i32
  %415 = call i32 @MPI_Send(ptr %412, i32 %414, i32 1275069450, i32 %396, i32 0, i32 1140850688)
  br label %416

416:                                              ; preds = %409, %408
  br label %417

417:                                              ; preds = %401, %416
  %418 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %419 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %420 = insertvalue { ptr, ptr, i64 } poison, ptr %418, 0
  %421 = insertvalue { ptr, ptr, i64 } %420, ptr %419, 1
  %422 = insertvalue { ptr, ptr, i64 } %421, i64 0, 2
  %423 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %424 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %425 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %426 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %427 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %428 = extractvalue { ptr, ptr, i64 } %422, 0
  %429 = extractvalue { ptr, ptr, i64 } %422, 1
  %430 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %428, 0
  %431 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %430, ptr %429, 1
  %432 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %431, i64 500000, 2
  %433 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %432, i64 250, 3, 0
  %434 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %433, i64 1000, 4, 0
  %435 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %434, i64 1000, 3, 1
  %436 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %435, i64 1, 4, 1
  %437 = load i32, ptr %64, align 4
  %438 = getelementptr inbounds nuw i32, ptr %64, i32 2
  %439 = load i32, ptr %438, align 4
  %440 = icmp eq i32 %36, %437
  %441 = icmp eq i32 %36, %439
  br i1 %440, label %442, label %449

442:                                              ; preds = %417
  %443 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %436, 1
  %444 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %436, 2
  %445 = getelementptr float, ptr %443, i64 %444
  %446 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %436, 3, 0
  %447 = trunc i64 %446 to i32
  %448 = call i32 @MPI_Recv(ptr %445, i32 %447, i32 1275069450, i32 %439, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %458

449:                                              ; preds = %417
  br i1 %441, label %450, label %457

450:                                              ; preds = %449
  %451 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %436, 1
  %452 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %436, 2
  %453 = getelementptr float, ptr %451, i64 %452
  %454 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %436, 3, 0
  %455 = trunc i64 %454 to i32
  %456 = call i32 @MPI_Send(ptr %453, i32 %455, i32 1275069450, i32 %437, i32 0, i32 1140850688)
  br label %457

457:                                              ; preds = %450, %449
  br label %458

458:                                              ; preds = %442, %457
  %459 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %460 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %461 = insertvalue { ptr, ptr, i64 } poison, ptr %459, 0
  %462 = insertvalue { ptr, ptr, i64 } %461, ptr %460, 1
  %463 = insertvalue { ptr, ptr, i64 } %462, i64 0, 2
  %464 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %465 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %466 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %467 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %468 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %469 = extractvalue { ptr, ptr, i64 } %463, 0
  %470 = extractvalue { ptr, ptr, i64 } %463, 1
  %471 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %469, 0
  %472 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %471, ptr %470, 1
  %473 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %472, i64 750000, 2
  %474 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %473, i64 250, 3, 0
  %475 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %474, i64 1000, 4, 0
  %476 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %475, i64 1000, 3, 1
  %477 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %476, i64 1, 4, 1
  %478 = load i32, ptr %64, align 4
  %479 = getelementptr inbounds nuw i32, ptr %64, i32 3
  %480 = load i32, ptr %479, align 4
  %481 = icmp eq i32 %36, %478
  %482 = icmp eq i32 %36, %480
  br i1 %481, label %483, label %490

483:                                              ; preds = %458
  %484 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %477, 1
  %485 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %477, 2
  %486 = getelementptr float, ptr %484, i64 %485
  %487 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %477, 3, 0
  %488 = trunc i64 %487 to i32
  %489 = call i32 @MPI_Recv(ptr %486, i32 %488, i32 1275069450, i32 %480, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %499

490:                                              ; preds = %458
  br i1 %482, label %491, label %498

491:                                              ; preds = %490
  %492 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %477, 1
  %493 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %477, 2
  %494 = getelementptr float, ptr %492, i64 %493
  %495 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %477, 3, 0
  %496 = trunc i64 %495 to i32
  %497 = call i32 @MPI_Send(ptr %494, i32 %496, i32 1275069450, i32 %478, i32 0, i32 1140850688)
  br label %498

498:                                              ; preds = %491, %490
  br label %499

499:                                              ; preds = %483, %498
  %500 = load i32, ptr %64, align 4
  %501 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 0
  %502 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 1
  %503 = insertvalue { ptr, ptr, i64 } poison, ptr %501, 0
  %504 = insertvalue { ptr, ptr, i64 } %503, ptr %502, 1
  %505 = insertvalue { ptr, ptr, i64 } %504, i64 0, 2
  %506 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 2
  %507 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 0
  %508 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 3, 1
  %509 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 0
  %510 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, 4, 1
  %511 = extractvalue { ptr, ptr, i64 } %505, 0
  %512 = extractvalue { ptr, ptr, i64 } %505, 1
  %513 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %511, 0
  %514 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %513, ptr %512, 1
  %515 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %514, i64 0, 2
  %516 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %515, i64 1000, 3, 0
  %517 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %516, i64 1000, 4, 0
  %518 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %517, i64 1000, 3, 1
  %519 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %518, i64 1, 4, 1
  %520 = icmp eq i32 %36, %500
  br i1 %520, label %521, label %539

521:                                              ; preds = %499
  %522 = sext i32 %39 to i64
  br label %523

523:                                              ; preds = %536, %521
  %524 = phi i64 [ %537, %536 ], [ 0, %521 ]
  %525 = icmp slt i64 %524, %522
  br i1 %525, label %526, label %538

526:                                              ; preds = %523
  %527 = trunc i64 %524 to i32
  %528 = icmp ne i32 %527, %500
  br i1 %528, label %529, label %536

529:                                              ; preds = %526
  %530 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %519, 1
  %531 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %519, 2
  %532 = getelementptr float, ptr %530, i64 %531
  %533 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %519, 3, 0
  %534 = trunc i64 %533 to i32
  %535 = call i32 @MPI_Send(ptr %532, i32 %534, i32 1275069450, i32 %527, i32 0, i32 1140850688)
  br label %536

536:                                              ; preds = %529, %526
  %537 = add i64 %524, 1
  br label %523

538:                                              ; preds = %523
  br label %546

539:                                              ; preds = %499
  %540 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %519, 1
  %541 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %519, 2
  %542 = getelementptr float, ptr %540, i64 %541
  %543 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %519, 3, 0
  %544 = trunc i64 %543 to i32
  %545 = call i32 @MPI_Recv(ptr %542, i32 %544, i32 1275069450, i32 %500, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %546

546:                                              ; preds = %538, %539
  %547 = add i64 %149, 1
  br label %148

548:                                              ; preds = %148
  %549 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par.7(ptr noalias %tid.addr275, ptr noalias %zero.addr276, ptr %0) #0 {
omp.par.entry277:
  %gep_.reloaded314 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded314 = load ptr, ptr %gep_.reloaded314, align 8, !align !1
  %gep_.reloaded315 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded315 = load ptr, ptr %gep_.reloaded315, align 8, !align !2
  %gep_.reloaded316 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded316 = load ptr, ptr %gep_.reloaded316, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !3
  %gep_1 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 4
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !3
  %p.lastiter308 = alloca i32, align 4
  %p.lowerbound309 = alloca i64, align 8
  %p.upperbound310 = alloca i64, align 8
  %p.stride311 = alloca i64, align 8
  %tid.addr.local281 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr275, align 4
  store i32 %1, ptr %tid.addr.local281, align 4
  %tid282 = load i32, ptr %tid.addr.local281, align 4
  %2 = load i64, ptr %loadgep_.reloaded314, align 4
  %3 = load float, ptr %loadgep_.reloaded315, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded316, align 8
  br label %omp.region.after_alloca288

omp.region.after_alloca288:                       ; preds = %omp.par.entry277
  br label %omp.region.after_alloca285

omp.region.after_alloca285:                       ; preds = %omp.region.after_alloca288
  br label %omp.par.region278

omp.par.region278:                                ; preds = %omp.region.after_alloca285
  br label %omp.par.region287

omp.par.region287:                                ; preds = %omp.par.region278
  br label %omp.wsloop.region290

omp.wsloop.region290:                             ; preds = %omp.par.region287
  br label %omp_loop.preheader291

omp_loop.preheader291:                            ; preds = %omp.wsloop.region290
  store i64 0, ptr %p.lowerbound309, align 4
  store i64 249, ptr %p.upperbound310, align 4
  store i64 1, ptr %p.stride311, align 4
  %omp_global_thread_num312 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num312, i32 34, ptr %p.lastiter308, ptr %p.lowerbound309, ptr %p.upperbound310, ptr %p.stride311, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound309, align 4
  %6 = load i64, ptr %p.upperbound310, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header292

omp_loop.header292:                               ; preds = %omp_loop.inc295, %omp_loop.preheader291
  %omp_loop.iv298 = phi i64 [ 0, %omp_loop.preheader291 ], [ %omp_loop.next300, %omp_loop.inc295 ]
  br label %omp_loop.cond293

omp_loop.cond293:                                 ; preds = %omp_loop.header292
  %omp_loop.cmp299 = icmp ult i64 %omp_loop.iv298, %8
  br i1 %omp_loop.cmp299, label %omp_loop.body294, label %omp_loop.exit296

omp_loop.exit296:                                 ; preds = %omp_loop.cond293
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num312)
  %omp_global_thread_num313 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num313)
  br label %omp_loop.after297

omp_loop.after297:                                ; preds = %omp_loop.exit296
  br label %omp.region.cont289

omp.region.cont289:                               ; preds = %omp_loop.after297
  br label %omp.region.cont286

omp.region.cont286:                               ; preds = %omp.region.cont289
  br label %omp.par.pre_finalize279

omp.par.pre_finalize279:                          ; preds = %omp.region.cont286
  br label %.fini317

.fini317:                                         ; preds = %omp.par.pre_finalize279
  br label %omp.par.exit280.exitStub

omp_loop.body294:                                 ; preds = %omp_loop.cond293
  %9 = add i64 %omp_loop.iv298, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region302

omp.loop_nest.region302:                          ; preds = %omp_loop.body294
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region303

omp.loop_nest.region303:                          ; preds = %omp.loop_nest.region302
  br label %omp.loop_nest.region304

omp.loop_nest.region304:                          ; preds = %omp.loop_nest.region305, %omp.loop_nest.region303
  %13 = phi i64 [ %59, %omp.loop_nest.region305 ], [ 0, %omp.loop_nest.region303 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region305, label %omp.loop_nest.region306

omp.loop_nest.region306:                          ; preds = %omp.loop_nest.region304
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region307

omp.loop_nest.region307:                          ; preds = %omp.loop_nest.region306
  br label %omp.region.cont301

omp.region.cont301:                               ; preds = %omp.loop_nest.region307
  br label %omp_loop.inc295

omp_loop.inc295:                                  ; preds = %omp.region.cont301
  %omp_loop.next300 = add nuw i64 %omp_loop.iv298, 1
  br label %omp_loop.header292

omp.loop_nest.region305:                          ; preds = %omp.loop_nest.region304
  %15 = mul nuw nsw i64 %2, 1000
  %16 = add nuw nsw i64 %15, %13
  %17 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %16
  %18 = load float, ptr %17, align 4
  %19 = fmul float %3, %18
  %20 = mul nuw nsw i64 %11, 1000
  %21 = add nuw nsw i64 %20, %13
  %22 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = fmul float %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = getelementptr float, ptr %25, i32 750000
  %27 = mul nuw nsw i64 %2, 1000
  %28 = add nuw nsw i64 %27, %11
  %29 = getelementptr inbounds nuw float, ptr %26, i64 %28
  %30 = load float, ptr %29, align 4
  %31 = fadd float %30, %24
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %33 = getelementptr float, ptr %32, i32 750000
  %34 = mul nuw nsw i64 %2, 1000
  %35 = add nuw nsw i64 %34, %11
  %36 = getelementptr inbounds nuw float, ptr %33, i64 %35
  store float %31, ptr %36, align 4
  %37 = mul nuw nsw i64 %2, 1000
  %38 = add nuw nsw i64 %37, %13
  %39 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %38
  %40 = load float, ptr %39, align 4
  %41 = fmul float %3, %40
  %42 = mul nuw nsw i64 %11, 1000
  %43 = add nuw nsw i64 %42, %13
  %44 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %43
  %45 = load float, ptr %44, align 4
  %46 = fmul float %41, %45
  %47 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %48 = getelementptr float, ptr %47, i32 750000
  %49 = mul nuw nsw i64 %2, 1000
  %50 = add nuw nsw i64 %49, %11
  %51 = getelementptr inbounds nuw float, ptr %48, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = fadd float %52, %46
  %54 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %55 = getelementptr float, ptr %54, i32 750000
  %56 = mul nuw nsw i64 %2, 1000
  %57 = add nuw nsw i64 %56, %11
  %58 = getelementptr inbounds nuw float, ptr %55, i64 %57
  store float %53, ptr %58, align 4
  %59 = add i64 %13, 1
  br label %omp.loop_nest.region304

omp.par.exit280.exitStub:                         ; preds = %.fini317
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par.6(ptr noalias %tid.addr231, ptr noalias %zero.addr232, ptr %0) #0 {
omp.par.entry233:
  %gep_.reloaded270 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded270 = load ptr, ptr %gep_.reloaded270, align 8, !align !1
  %gep_.reloaded271 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded271 = load ptr, ptr %gep_.reloaded271, align 8, !align !2
  %gep_.reloaded272 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded272 = load ptr, ptr %gep_.reloaded272, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !3
  %gep_1 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 4
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !3
  %p.lastiter264 = alloca i32, align 4
  %p.lowerbound265 = alloca i64, align 8
  %p.upperbound266 = alloca i64, align 8
  %p.stride267 = alloca i64, align 8
  %tid.addr.local237 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr231, align 4
  store i32 %1, ptr %tid.addr.local237, align 4
  %tid238 = load i32, ptr %tid.addr.local237, align 4
  %2 = load i64, ptr %loadgep_.reloaded270, align 4
  %3 = load float, ptr %loadgep_.reloaded271, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded272, align 8
  br label %omp.region.after_alloca244

omp.region.after_alloca244:                       ; preds = %omp.par.entry233
  br label %omp.region.after_alloca241

omp.region.after_alloca241:                       ; preds = %omp.region.after_alloca244
  br label %omp.par.region234

omp.par.region234:                                ; preds = %omp.region.after_alloca241
  br label %omp.par.region243

omp.par.region243:                                ; preds = %omp.par.region234
  br label %omp.wsloop.region246

omp.wsloop.region246:                             ; preds = %omp.par.region243
  br label %omp_loop.preheader247

omp_loop.preheader247:                            ; preds = %omp.wsloop.region246
  store i64 0, ptr %p.lowerbound265, align 4
  store i64 249, ptr %p.upperbound266, align 4
  store i64 1, ptr %p.stride267, align 4
  %omp_global_thread_num268 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num268, i32 34, ptr %p.lastiter264, ptr %p.lowerbound265, ptr %p.upperbound266, ptr %p.stride267, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound265, align 4
  %6 = load i64, ptr %p.upperbound266, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header248

omp_loop.header248:                               ; preds = %omp_loop.inc251, %omp_loop.preheader247
  %omp_loop.iv254 = phi i64 [ 0, %omp_loop.preheader247 ], [ %omp_loop.next256, %omp_loop.inc251 ]
  br label %omp_loop.cond249

omp_loop.cond249:                                 ; preds = %omp_loop.header248
  %omp_loop.cmp255 = icmp ult i64 %omp_loop.iv254, %8
  br i1 %omp_loop.cmp255, label %omp_loop.body250, label %omp_loop.exit252

omp_loop.exit252:                                 ; preds = %omp_loop.cond249
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num268)
  %omp_global_thread_num269 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num269)
  br label %omp_loop.after253

omp_loop.after253:                                ; preds = %omp_loop.exit252
  br label %omp.region.cont245

omp.region.cont245:                               ; preds = %omp_loop.after253
  br label %omp.region.cont242

omp.region.cont242:                               ; preds = %omp.region.cont245
  br label %omp.par.pre_finalize235

omp.par.pre_finalize235:                          ; preds = %omp.region.cont242
  br label %.fini273

.fini273:                                         ; preds = %omp.par.pre_finalize235
  br label %omp.par.exit236.exitStub

omp_loop.body250:                                 ; preds = %omp_loop.cond249
  %9 = add i64 %omp_loop.iv254, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region258

omp.loop_nest.region258:                          ; preds = %omp_loop.body250
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region259

omp.loop_nest.region259:                          ; preds = %omp.loop_nest.region258
  br label %omp.loop_nest.region260

omp.loop_nest.region260:                          ; preds = %omp.loop_nest.region261, %omp.loop_nest.region259
  %13 = phi i64 [ %59, %omp.loop_nest.region261 ], [ 0, %omp.loop_nest.region259 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region261, label %omp.loop_nest.region262

omp.loop_nest.region262:                          ; preds = %omp.loop_nest.region260
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region263

omp.loop_nest.region263:                          ; preds = %omp.loop_nest.region262
  br label %omp.region.cont257

omp.region.cont257:                               ; preds = %omp.loop_nest.region263
  br label %omp_loop.inc251

omp_loop.inc251:                                  ; preds = %omp.region.cont257
  %omp_loop.next256 = add nuw i64 %omp_loop.iv254, 1
  br label %omp_loop.header248

omp.loop_nest.region261:                          ; preds = %omp.loop_nest.region260
  %15 = mul nuw nsw i64 %2, 1000
  %16 = add nuw nsw i64 %15, %13
  %17 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %16
  %18 = load float, ptr %17, align 4
  %19 = fmul float %3, %18
  %20 = mul nuw nsw i64 %11, 1000
  %21 = add nuw nsw i64 %20, %13
  %22 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = fmul float %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = getelementptr float, ptr %25, i32 500000
  %27 = mul nuw nsw i64 %2, 1000
  %28 = add nuw nsw i64 %27, %11
  %29 = getelementptr inbounds nuw float, ptr %26, i64 %28
  %30 = load float, ptr %29, align 4
  %31 = fadd float %30, %24
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %33 = getelementptr float, ptr %32, i32 500000
  %34 = mul nuw nsw i64 %2, 1000
  %35 = add nuw nsw i64 %34, %11
  %36 = getelementptr inbounds nuw float, ptr %33, i64 %35
  store float %31, ptr %36, align 4
  %37 = mul nuw nsw i64 %2, 1000
  %38 = add nuw nsw i64 %37, %13
  %39 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %38
  %40 = load float, ptr %39, align 4
  %41 = fmul float %3, %40
  %42 = mul nuw nsw i64 %11, 1000
  %43 = add nuw nsw i64 %42, %13
  %44 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %43
  %45 = load float, ptr %44, align 4
  %46 = fmul float %41, %45
  %47 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %48 = getelementptr float, ptr %47, i32 500000
  %49 = mul nuw nsw i64 %2, 1000
  %50 = add nuw nsw i64 %49, %11
  %51 = getelementptr inbounds nuw float, ptr %48, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = fadd float %52, %46
  %54 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %55 = getelementptr float, ptr %54, i32 500000
  %56 = mul nuw nsw i64 %2, 1000
  %57 = add nuw nsw i64 %56, %11
  %58 = getelementptr inbounds nuw float, ptr %55, i64 %57
  store float %53, ptr %58, align 4
  %59 = add i64 %13, 1
  br label %omp.loop_nest.region260

omp.par.exit236.exitStub:                         ; preds = %.fini273
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par.5(ptr noalias %tid.addr187, ptr noalias %zero.addr188, ptr %0) #0 {
omp.par.entry189:
  %gep_.reloaded226 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded226 = load ptr, ptr %gep_.reloaded226, align 8, !align !1
  %gep_.reloaded227 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded227 = load ptr, ptr %gep_.reloaded227, align 8, !align !2
  %gep_.reloaded228 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded228 = load ptr, ptr %gep_.reloaded228, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !3
  %gep_1 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 4
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !3
  %p.lastiter220 = alloca i32, align 4
  %p.lowerbound221 = alloca i64, align 8
  %p.upperbound222 = alloca i64, align 8
  %p.stride223 = alloca i64, align 8
  %tid.addr.local193 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr187, align 4
  store i32 %1, ptr %tid.addr.local193, align 4
  %tid194 = load i32, ptr %tid.addr.local193, align 4
  %2 = load i64, ptr %loadgep_.reloaded226, align 4
  %3 = load float, ptr %loadgep_.reloaded227, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded228, align 8
  br label %omp.region.after_alloca200

omp.region.after_alloca200:                       ; preds = %omp.par.entry189
  br label %omp.region.after_alloca197

omp.region.after_alloca197:                       ; preds = %omp.region.after_alloca200
  br label %omp.par.region190

omp.par.region190:                                ; preds = %omp.region.after_alloca197
  br label %omp.par.region199

omp.par.region199:                                ; preds = %omp.par.region190
  br label %omp.wsloop.region202

omp.wsloop.region202:                             ; preds = %omp.par.region199
  br label %omp_loop.preheader203

omp_loop.preheader203:                            ; preds = %omp.wsloop.region202
  store i64 0, ptr %p.lowerbound221, align 4
  store i64 249, ptr %p.upperbound222, align 4
  store i64 1, ptr %p.stride223, align 4
  %omp_global_thread_num224 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num224, i32 34, ptr %p.lastiter220, ptr %p.lowerbound221, ptr %p.upperbound222, ptr %p.stride223, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound221, align 4
  %6 = load i64, ptr %p.upperbound222, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header204

omp_loop.header204:                               ; preds = %omp_loop.inc207, %omp_loop.preheader203
  %omp_loop.iv210 = phi i64 [ 0, %omp_loop.preheader203 ], [ %omp_loop.next212, %omp_loop.inc207 ]
  br label %omp_loop.cond205

omp_loop.cond205:                                 ; preds = %omp_loop.header204
  %omp_loop.cmp211 = icmp ult i64 %omp_loop.iv210, %8
  br i1 %omp_loop.cmp211, label %omp_loop.body206, label %omp_loop.exit208

omp_loop.exit208:                                 ; preds = %omp_loop.cond205
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num224)
  %omp_global_thread_num225 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num225)
  br label %omp_loop.after209

omp_loop.after209:                                ; preds = %omp_loop.exit208
  br label %omp.region.cont201

omp.region.cont201:                               ; preds = %omp_loop.after209
  br label %omp.region.cont198

omp.region.cont198:                               ; preds = %omp.region.cont201
  br label %omp.par.pre_finalize191

omp.par.pre_finalize191:                          ; preds = %omp.region.cont198
  br label %.fini229

.fini229:                                         ; preds = %omp.par.pre_finalize191
  br label %omp.par.exit192.exitStub

omp_loop.body206:                                 ; preds = %omp_loop.cond205
  %9 = add i64 %omp_loop.iv210, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region214

omp.loop_nest.region214:                          ; preds = %omp_loop.body206
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region215

omp.loop_nest.region215:                          ; preds = %omp.loop_nest.region214
  br label %omp.loop_nest.region216

omp.loop_nest.region216:                          ; preds = %omp.loop_nest.region217, %omp.loop_nest.region215
  %13 = phi i64 [ %59, %omp.loop_nest.region217 ], [ 0, %omp.loop_nest.region215 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region217, label %omp.loop_nest.region218

omp.loop_nest.region218:                          ; preds = %omp.loop_nest.region216
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region219

omp.loop_nest.region219:                          ; preds = %omp.loop_nest.region218
  br label %omp.region.cont213

omp.region.cont213:                               ; preds = %omp.loop_nest.region219
  br label %omp_loop.inc207

omp_loop.inc207:                                  ; preds = %omp.region.cont213
  %omp_loop.next212 = add nuw i64 %omp_loop.iv210, 1
  br label %omp_loop.header204

omp.loop_nest.region217:                          ; preds = %omp.loop_nest.region216
  %15 = mul nuw nsw i64 %2, 1000
  %16 = add nuw nsw i64 %15, %13
  %17 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %16
  %18 = load float, ptr %17, align 4
  %19 = fmul float %3, %18
  %20 = mul nuw nsw i64 %11, 1000
  %21 = add nuw nsw i64 %20, %13
  %22 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = fmul float %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = getelementptr float, ptr %25, i32 250000
  %27 = mul nuw nsw i64 %2, 1000
  %28 = add nuw nsw i64 %27, %11
  %29 = getelementptr inbounds nuw float, ptr %26, i64 %28
  %30 = load float, ptr %29, align 4
  %31 = fadd float %30, %24
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %33 = getelementptr float, ptr %32, i32 250000
  %34 = mul nuw nsw i64 %2, 1000
  %35 = add nuw nsw i64 %34, %11
  %36 = getelementptr inbounds nuw float, ptr %33, i64 %35
  store float %31, ptr %36, align 4
  %37 = mul nuw nsw i64 %2, 1000
  %38 = add nuw nsw i64 %37, %13
  %39 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %38
  %40 = load float, ptr %39, align 4
  %41 = fmul float %3, %40
  %42 = mul nuw nsw i64 %11, 1000
  %43 = add nuw nsw i64 %42, %13
  %44 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %43
  %45 = load float, ptr %44, align 4
  %46 = fmul float %41, %45
  %47 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %48 = getelementptr float, ptr %47, i32 250000
  %49 = mul nuw nsw i64 %2, 1000
  %50 = add nuw nsw i64 %49, %11
  %51 = getelementptr inbounds nuw float, ptr %48, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = fadd float %52, %46
  %54 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %55 = getelementptr float, ptr %54, i32 250000
  %56 = mul nuw nsw i64 %2, 1000
  %57 = add nuw nsw i64 %56, %11
  %58 = getelementptr inbounds nuw float, ptr %55, i64 %57
  store float %53, ptr %58, align 4
  %59 = add i64 %13, 1
  br label %omp.loop_nest.region216

omp.par.exit192.exitStub:                         ; preds = %.fini229
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par.4(ptr noalias %tid.addr143, ptr noalias %zero.addr144, ptr %0) #0 {
omp.par.entry145:
  %gep_.reloaded182 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded182 = load ptr, ptr %gep_.reloaded182, align 8, !align !1
  %gep_.reloaded183 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded183 = load ptr, ptr %gep_.reloaded183, align 8, !align !2
  %gep_.reloaded184 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded184 = load ptr, ptr %gep_.reloaded184, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !3
  %gep_1 = getelementptr { ptr, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 4
  %loadgep_2 = load ptr, ptr %gep_1, align 8, !align !3
  %p.lastiter176 = alloca i32, align 4
  %p.lowerbound177 = alloca i64, align 8
  %p.upperbound178 = alloca i64, align 8
  %p.stride179 = alloca i64, align 8
  %tid.addr.local149 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr143, align 4
  store i32 %1, ptr %tid.addr.local149, align 4
  %tid150 = load i32, ptr %tid.addr.local149, align 4
  %2 = load i64, ptr %loadgep_.reloaded182, align 4
  %3 = load float, ptr %loadgep_.reloaded183, align 4
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded184, align 8
  br label %omp.region.after_alloca156

omp.region.after_alloca156:                       ; preds = %omp.par.entry145
  br label %omp.region.after_alloca153

omp.region.after_alloca153:                       ; preds = %omp.region.after_alloca156
  br label %omp.par.region146

omp.par.region146:                                ; preds = %omp.region.after_alloca153
  br label %omp.par.region155

omp.par.region155:                                ; preds = %omp.par.region146
  br label %omp.wsloop.region158

omp.wsloop.region158:                             ; preds = %omp.par.region155
  br label %omp_loop.preheader159

omp_loop.preheader159:                            ; preds = %omp.wsloop.region158
  store i64 0, ptr %p.lowerbound177, align 4
  store i64 249, ptr %p.upperbound178, align 4
  store i64 1, ptr %p.stride179, align 4
  %omp_global_thread_num180 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num180, i32 34, ptr %p.lastiter176, ptr %p.lowerbound177, ptr %p.upperbound178, ptr %p.stride179, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound177, align 4
  %6 = load i64, ptr %p.upperbound178, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header160

omp_loop.header160:                               ; preds = %omp_loop.inc163, %omp_loop.preheader159
  %omp_loop.iv166 = phi i64 [ 0, %omp_loop.preheader159 ], [ %omp_loop.next168, %omp_loop.inc163 ]
  br label %omp_loop.cond161

omp_loop.cond161:                                 ; preds = %omp_loop.header160
  %omp_loop.cmp167 = icmp ult i64 %omp_loop.iv166, %8
  br i1 %omp_loop.cmp167, label %omp_loop.body162, label %omp_loop.exit164

omp_loop.exit164:                                 ; preds = %omp_loop.cond161
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num180)
  %omp_global_thread_num181 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num181)
  br label %omp_loop.after165

omp_loop.after165:                                ; preds = %omp_loop.exit164
  br label %omp.region.cont157

omp.region.cont157:                               ; preds = %omp_loop.after165
  br label %omp.region.cont154

omp.region.cont154:                               ; preds = %omp.region.cont157
  br label %omp.par.pre_finalize147

omp.par.pre_finalize147:                          ; preds = %omp.region.cont154
  br label %.fini185

.fini185:                                         ; preds = %omp.par.pre_finalize147
  br label %omp.par.exit148.exitStub

omp_loop.body162:                                 ; preds = %omp_loop.cond161
  %9 = add i64 %omp_loop.iv166, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region170

omp.loop_nest.region170:                          ; preds = %omp_loop.body162
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region171

omp.loop_nest.region171:                          ; preds = %omp.loop_nest.region170
  br label %omp.loop_nest.region172

omp.loop_nest.region172:                          ; preds = %omp.loop_nest.region173, %omp.loop_nest.region171
  %13 = phi i64 [ %55, %omp.loop_nest.region173 ], [ 0, %omp.loop_nest.region171 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region173, label %omp.loop_nest.region174

omp.loop_nest.region174:                          ; preds = %omp.loop_nest.region172
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region175

omp.loop_nest.region175:                          ; preds = %omp.loop_nest.region174
  br label %omp.region.cont169

omp.region.cont169:                               ; preds = %omp.loop_nest.region175
  br label %omp_loop.inc163

omp_loop.inc163:                                  ; preds = %omp.region.cont169
  %omp_loop.next168 = add nuw i64 %omp_loop.iv166, 1
  br label %omp_loop.header160

omp.loop_nest.region173:                          ; preds = %omp.loop_nest.region172
  %15 = mul nuw nsw i64 %2, 1000
  %16 = add nuw nsw i64 %15, %13
  %17 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %16
  %18 = load float, ptr %17, align 4
  %19 = fmul float %3, %18
  %20 = mul nuw nsw i64 %11, 1000
  %21 = add nuw nsw i64 %20, %13
  %22 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = fmul float %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = mul nuw nsw i64 %2, 1000
  %27 = add nuw nsw i64 %26, %11
  %28 = getelementptr inbounds nuw float, ptr %25, i64 %27
  %29 = load float, ptr %28, align 4
  %30 = fadd float %29, %24
  %31 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %32 = mul nuw nsw i64 %2, 1000
  %33 = add nuw nsw i64 %32, %11
  %34 = getelementptr inbounds nuw float, ptr %31, i64 %33
  store float %30, ptr %34, align 4
  %35 = mul nuw nsw i64 %2, 1000
  %36 = add nuw nsw i64 %35, %13
  %37 = getelementptr inbounds nuw float, ptr %loadgep_2, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fmul float %3, %38
  %40 = mul nuw nsw i64 %11, 1000
  %41 = add nuw nsw i64 %40, %13
  %42 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %41
  %43 = load float, ptr %42, align 4
  %44 = fmul float %39, %43
  %45 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %46 = mul nuw nsw i64 %2, 1000
  %47 = add nuw nsw i64 %46, %11
  %48 = getelementptr inbounds nuw float, ptr %45, i64 %47
  %49 = load float, ptr %48, align 4
  %50 = fadd float %49, %44
  %51 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %52 = mul nuw nsw i64 %2, 1000
  %53 = add nuw nsw i64 %52, %11
  %54 = getelementptr inbounds nuw float, ptr %51, i64 %53
  store float %50, ptr %54, align 4
  %55 = add i64 %13, 1
  br label %omp.loop_nest.region172

omp.par.exit148.exitStub:                         ; preds = %.fini185
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par.3(ptr noalias %tid.addr100, ptr noalias %zero.addr101, ptr %0) #0 {
omp.par.entry102:
  %gep_.reloaded139 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded139 = load ptr, ptr %gep_.reloaded139, align 8, !align !1
  %gep_.reloaded140 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded140 = load ptr, ptr %gep_.reloaded140, align 8, !align !2
  %p.lastiter133 = alloca i32, align 4
  %p.lowerbound134 = alloca i64, align 8
  %p.upperbound135 = alloca i64, align 8
  %p.stride136 = alloca i64, align 8
  %tid.addr.local106 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr100, align 4
  store i32 %1, ptr %tid.addr.local106, align 4
  %tid107 = load i32, ptr %tid.addr.local106, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded139, align 8
  %3 = load float, ptr %loadgep_.reloaded140, align 4
  br label %omp.region.after_alloca113

omp.region.after_alloca113:                       ; preds = %omp.par.entry102
  br label %omp.region.after_alloca110

omp.region.after_alloca110:                       ; preds = %omp.region.after_alloca113
  br label %omp.par.region103

omp.par.region103:                                ; preds = %omp.region.after_alloca110
  br label %omp.par.region112

omp.par.region112:                                ; preds = %omp.par.region103
  br label %omp.wsloop.region115

omp.wsloop.region115:                             ; preds = %omp.par.region112
  br label %omp_loop.preheader116

omp_loop.preheader116:                            ; preds = %omp.wsloop.region115
  store i64 0, ptr %p.lowerbound134, align 4
  store i64 249, ptr %p.upperbound135, align 4
  store i64 1, ptr %p.stride136, align 4
  %omp_global_thread_num137 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num137, i32 34, ptr %p.lastiter133, ptr %p.lowerbound134, ptr %p.upperbound135, ptr %p.stride136, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound134, align 4
  %5 = load i64, ptr %p.upperbound135, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header117

omp_loop.header117:                               ; preds = %omp_loop.inc120, %omp_loop.preheader116
  %omp_loop.iv123 = phi i64 [ 0, %omp_loop.preheader116 ], [ %omp_loop.next125, %omp_loop.inc120 ]
  br label %omp_loop.cond118

omp_loop.cond118:                                 ; preds = %omp_loop.header117
  %omp_loop.cmp124 = icmp ult i64 %omp_loop.iv123, %7
  br i1 %omp_loop.cmp124, label %omp_loop.body119, label %omp_loop.exit121

omp_loop.exit121:                                 ; preds = %omp_loop.cond118
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num137)
  %omp_global_thread_num138 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num138)
  br label %omp_loop.after122

omp_loop.after122:                                ; preds = %omp_loop.exit121
  br label %omp.region.cont114

omp.region.cont114:                               ; preds = %omp_loop.after122
  br label %omp.region.cont111

omp.region.cont111:                               ; preds = %omp.region.cont114
  br label %omp.par.pre_finalize104

omp.par.pre_finalize104:                          ; preds = %omp.region.cont111
  br label %.fini141

.fini141:                                         ; preds = %omp.par.pre_finalize104
  br label %omp.par.exit105.exitStub

omp_loop.body119:                                 ; preds = %omp_loop.cond118
  %8 = add i64 %omp_loop.iv123, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region127

omp.loop_nest.region127:                          ; preds = %omp_loop.body119
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region128

omp.loop_nest.region128:                          ; preds = %omp.loop_nest.region127
  br label %omp.loop_nest.region129

omp.loop_nest.region129:                          ; preds = %omp.loop_nest.region130, %omp.loop_nest.region128
  %12 = phi i64 [ %26, %omp.loop_nest.region130 ], [ 0, %omp.loop_nest.region128 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region130, label %omp.loop_nest.region131

omp.loop_nest.region131:                          ; preds = %omp.loop_nest.region129
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region132

omp.loop_nest.region132:                          ; preds = %omp.loop_nest.region131
  br label %omp.region.cont126

omp.region.cont126:                               ; preds = %omp.loop_nest.region132
  br label %omp_loop.inc120

omp_loop.inc120:                                  ; preds = %omp.region.cont126
  %omp_loop.next125 = add nuw i64 %omp_loop.iv123, 1
  br label %omp_loop.header117

omp.loop_nest.region130:                          ; preds = %omp.loop_nest.region129
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 750000
  %16 = mul nuw nsw i64 %10, 1000
  %17 = add nuw nsw i64 %16, %12
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  %19 = load float, ptr %18, align 4
  %20 = fmul float %19, %3
  %21 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %22 = getelementptr float, ptr %21, i32 750000
  %23 = mul nuw nsw i64 %10, 1000
  %24 = add nuw nsw i64 %23, %12
  %25 = getelementptr inbounds nuw float, ptr %22, i64 %24
  store float %20, ptr %25, align 4
  %26 = add i64 %12, 1
  br label %omp.loop_nest.region129

omp.par.exit105.exitStub:                         ; preds = %.fini141
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par.2(ptr noalias %tid.addr57, ptr noalias %zero.addr58, ptr %0) #0 {
omp.par.entry59:
  %gep_.reloaded96 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded96 = load ptr, ptr %gep_.reloaded96, align 8, !align !1
  %gep_.reloaded97 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded97 = load ptr, ptr %gep_.reloaded97, align 8, !align !2
  %p.lastiter90 = alloca i32, align 4
  %p.lowerbound91 = alloca i64, align 8
  %p.upperbound92 = alloca i64, align 8
  %p.stride93 = alloca i64, align 8
  %tid.addr.local63 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr57, align 4
  store i32 %1, ptr %tid.addr.local63, align 4
  %tid64 = load i32, ptr %tid.addr.local63, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded96, align 8
  %3 = load float, ptr %loadgep_.reloaded97, align 4
  br label %omp.region.after_alloca70

omp.region.after_alloca70:                        ; preds = %omp.par.entry59
  br label %omp.region.after_alloca67

omp.region.after_alloca67:                        ; preds = %omp.region.after_alloca70
  br label %omp.par.region60

omp.par.region60:                                 ; preds = %omp.region.after_alloca67
  br label %omp.par.region69

omp.par.region69:                                 ; preds = %omp.par.region60
  br label %omp.wsloop.region72

omp.wsloop.region72:                              ; preds = %omp.par.region69
  br label %omp_loop.preheader73

omp_loop.preheader73:                             ; preds = %omp.wsloop.region72
  store i64 0, ptr %p.lowerbound91, align 4
  store i64 249, ptr %p.upperbound92, align 4
  store i64 1, ptr %p.stride93, align 4
  %omp_global_thread_num94 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num94, i32 34, ptr %p.lastiter90, ptr %p.lowerbound91, ptr %p.upperbound92, ptr %p.stride93, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound91, align 4
  %5 = load i64, ptr %p.upperbound92, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header74

omp_loop.header74:                                ; preds = %omp_loop.inc77, %omp_loop.preheader73
  %omp_loop.iv80 = phi i64 [ 0, %omp_loop.preheader73 ], [ %omp_loop.next82, %omp_loop.inc77 ]
  br label %omp_loop.cond75

omp_loop.cond75:                                  ; preds = %omp_loop.header74
  %omp_loop.cmp81 = icmp ult i64 %omp_loop.iv80, %7
  br i1 %omp_loop.cmp81, label %omp_loop.body76, label %omp_loop.exit78

omp_loop.exit78:                                  ; preds = %omp_loop.cond75
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num94)
  %omp_global_thread_num95 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num95)
  br label %omp_loop.after79

omp_loop.after79:                                 ; preds = %omp_loop.exit78
  br label %omp.region.cont71

omp.region.cont71:                                ; preds = %omp_loop.after79
  br label %omp.region.cont68

omp.region.cont68:                                ; preds = %omp.region.cont71
  br label %omp.par.pre_finalize61

omp.par.pre_finalize61:                           ; preds = %omp.region.cont68
  br label %.fini98

.fini98:                                          ; preds = %omp.par.pre_finalize61
  br label %omp.par.exit62.exitStub

omp_loop.body76:                                  ; preds = %omp_loop.cond75
  %8 = add i64 %omp_loop.iv80, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region84

omp.loop_nest.region84:                           ; preds = %omp_loop.body76
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region85

omp.loop_nest.region85:                           ; preds = %omp.loop_nest.region84
  br label %omp.loop_nest.region86

omp.loop_nest.region86:                           ; preds = %omp.loop_nest.region87, %omp.loop_nest.region85
  %12 = phi i64 [ %26, %omp.loop_nest.region87 ], [ 0, %omp.loop_nest.region85 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region87, label %omp.loop_nest.region88

omp.loop_nest.region88:                           ; preds = %omp.loop_nest.region86
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region89

omp.loop_nest.region89:                           ; preds = %omp.loop_nest.region88
  br label %omp.region.cont83

omp.region.cont83:                                ; preds = %omp.loop_nest.region89
  br label %omp_loop.inc77

omp_loop.inc77:                                   ; preds = %omp.region.cont83
  %omp_loop.next82 = add nuw i64 %omp_loop.iv80, 1
  br label %omp_loop.header74

omp.loop_nest.region87:                           ; preds = %omp.loop_nest.region86
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 500000
  %16 = mul nuw nsw i64 %10, 1000
  %17 = add nuw nsw i64 %16, %12
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  %19 = load float, ptr %18, align 4
  %20 = fmul float %19, %3
  %21 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %22 = getelementptr float, ptr %21, i32 500000
  %23 = mul nuw nsw i64 %10, 1000
  %24 = add nuw nsw i64 %23, %12
  %25 = getelementptr inbounds nuw float, ptr %22, i64 %24
  store float %20, ptr %25, align 4
  %26 = add i64 %12, 1
  br label %omp.loop_nest.region86

omp.par.exit62.exitStub:                          ; preds = %.fini98
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par.1(ptr noalias %tid.addr14, ptr noalias %zero.addr15, ptr %0) #0 {
omp.par.entry16:
  %gep_.reloaded53 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded53 = load ptr, ptr %gep_.reloaded53, align 8, !align !1
  %gep_.reloaded54 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded54 = load ptr, ptr %gep_.reloaded54, align 8, !align !2
  %p.lastiter47 = alloca i32, align 4
  %p.lowerbound48 = alloca i64, align 8
  %p.upperbound49 = alloca i64, align 8
  %p.stride50 = alloca i64, align 8
  %tid.addr.local20 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr14, align 4
  store i32 %1, ptr %tid.addr.local20, align 4
  %tid21 = load i32, ptr %tid.addr.local20, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded53, align 8
  %3 = load float, ptr %loadgep_.reloaded54, align 4
  br label %omp.region.after_alloca27

omp.region.after_alloca27:                        ; preds = %omp.par.entry16
  br label %omp.region.after_alloca24

omp.region.after_alloca24:                        ; preds = %omp.region.after_alloca27
  br label %omp.par.region17

omp.par.region17:                                 ; preds = %omp.region.after_alloca24
  br label %omp.par.region26

omp.par.region26:                                 ; preds = %omp.par.region17
  br label %omp.wsloop.region29

omp.wsloop.region29:                              ; preds = %omp.par.region26
  br label %omp_loop.preheader30

omp_loop.preheader30:                             ; preds = %omp.wsloop.region29
  store i64 0, ptr %p.lowerbound48, align 4
  store i64 249, ptr %p.upperbound49, align 4
  store i64 1, ptr %p.stride50, align 4
  %omp_global_thread_num51 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num51, i32 34, ptr %p.lastiter47, ptr %p.lowerbound48, ptr %p.upperbound49, ptr %p.stride50, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound48, align 4
  %5 = load i64, ptr %p.upperbound49, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header31

omp_loop.header31:                                ; preds = %omp_loop.inc34, %omp_loop.preheader30
  %omp_loop.iv37 = phi i64 [ 0, %omp_loop.preheader30 ], [ %omp_loop.next39, %omp_loop.inc34 ]
  br label %omp_loop.cond32

omp_loop.cond32:                                  ; preds = %omp_loop.header31
  %omp_loop.cmp38 = icmp ult i64 %omp_loop.iv37, %7
  br i1 %omp_loop.cmp38, label %omp_loop.body33, label %omp_loop.exit35

omp_loop.exit35:                                  ; preds = %omp_loop.cond32
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num51)
  %omp_global_thread_num52 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num52)
  br label %omp_loop.after36

omp_loop.after36:                                 ; preds = %omp_loop.exit35
  br label %omp.region.cont28

omp.region.cont28:                                ; preds = %omp_loop.after36
  br label %omp.region.cont25

omp.region.cont25:                                ; preds = %omp.region.cont28
  br label %omp.par.pre_finalize18

omp.par.pre_finalize18:                           ; preds = %omp.region.cont25
  br label %.fini55

.fini55:                                          ; preds = %omp.par.pre_finalize18
  br label %omp.par.exit19.exitStub

omp_loop.body33:                                  ; preds = %omp_loop.cond32
  %8 = add i64 %omp_loop.iv37, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region41

omp.loop_nest.region41:                           ; preds = %omp_loop.body33
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region42

omp.loop_nest.region42:                           ; preds = %omp.loop_nest.region41
  br label %omp.loop_nest.region43

omp.loop_nest.region43:                           ; preds = %omp.loop_nest.region44, %omp.loop_nest.region42
  %12 = phi i64 [ %26, %omp.loop_nest.region44 ], [ 0, %omp.loop_nest.region42 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region44, label %omp.loop_nest.region45

omp.loop_nest.region45:                           ; preds = %omp.loop_nest.region43
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region46

omp.loop_nest.region46:                           ; preds = %omp.loop_nest.region45
  br label %omp.region.cont40

omp.region.cont40:                                ; preds = %omp.loop_nest.region46
  br label %omp_loop.inc34

omp_loop.inc34:                                   ; preds = %omp.region.cont40
  %omp_loop.next39 = add nuw i64 %omp_loop.iv37, 1
  br label %omp_loop.header31

omp.loop_nest.region44:                           ; preds = %omp.loop_nest.region43
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 250000
  %16 = mul nuw nsw i64 %10, 1000
  %17 = add nuw nsw i64 %16, %12
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  %19 = load float, ptr %18, align 4
  %20 = fmul float %19, %3
  %21 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %22 = getelementptr float, ptr %21, i32 250000
  %23 = mul nuw nsw i64 %10, 1000
  %24 = add nuw nsw i64 %23, %12
  %25 = getelementptr inbounds nuw float, ptr %22, i64 %24
  store float %20, ptr %25, align 4
  %26 = add i64 %12, 1
  br label %omp.loop_nest.region43

omp.par.exit19.exitStub:                          ; preds = %.fini55
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syr2k..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded12 = getelementptr { ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded12 = load ptr, ptr %gep_.reloaded12, align 8, !align !2
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load float, ptr %loadgep_.reloaded12, align 4
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
  store i64 249, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num10 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num10, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
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
  %8 = add i64 %omp_loop.iv, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region5

omp.loop_nest.region5:                            ; preds = %omp.loop_nest.region
  br label %omp.loop_nest.region6

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region7, %omp.loop_nest.region5
  %12 = phi i64 [ %24, %omp.loop_nest.region7 ], [ 0, %omp.loop_nest.region5 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region7, label %omp.loop_nest.region8

omp.loop_nest.region8:                            ; preds = %omp.loop_nest.region6
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region9

omp.loop_nest.region9:                            ; preds = %omp.loop_nest.region8
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region9
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.loop_nest.region7:                            ; preds = %omp.loop_nest.region6
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = mul nuw nsw i64 %10, 1000
  %16 = add nuw nsw i64 %15, %12
  %17 = getelementptr inbounds nuw float, ptr %14, i64 %16
  %18 = load float, ptr %17, align 4
  %19 = fmul float %18, %3
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %21 = mul nuw nsw i64 %10, 1000
  %22 = add nuw nsw i64 %21, %12
  %23 = getelementptr inbounds nuw float, ptr %20, i64 %22
  store float %19, ptr %23, align 4
  %24 = add i64 %12, 1
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
declare !callback !4 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind willreturn }
attributes #2 = { convergent nounwind }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{i64 8}
!2 = !{i64 4}
!3 = !{i64 1}
!4 = !{!5}
!5 = !{i64 2, i64 -1, i64 -1, i1 true}
