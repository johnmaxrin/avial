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

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

declare ptr @malloc(i64)

declare void @buildRankNodeMaps(ptr, ptr, ptr)

define void @matmul(i32 %0, i32 %1, i32 %2, ptr %3, ptr %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, ptr %10, ptr %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, ptr %17, ptr %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23) {
  %structArg160 = alloca { ptr, ptr, ptr }, align 8
  %structArg157 = alloca { ptr, ptr, ptr }, align 8
  %structArg154 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded151 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded152 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded105 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded106 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded59 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded60 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded15 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %17, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, ptr %18, 1
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %19, 2
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 3, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %22, 4, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %21, 3, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %23, 4, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %3, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %4, 1
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %5, 2
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %6, 3, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %8, 4, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %7, 3, 1
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %9, 4, 1
  %39 = call i32 @MPI_Init(ptr null, ptr null)
  %40 = alloca i32, align 4
  %41 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %40)
  %42 = load i32, ptr %40, align 4
  %43 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %44 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 0
  %45 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 1
  %46 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 2
  %47 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 3
  store ptr @node_str_0, ptr %44, align 8
  store ptr @arch_str_0, ptr %45, align 8
  store i32 0, ptr %46, align 4
  store float 1.000000e+00, ptr %47, align 4
  %48 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 1
  %49 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 0
  %50 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 1
  %51 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 2
  %52 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 3
  store ptr @node_str_1, ptr %49, align 8
  store ptr @arch_str_1, ptr %50, align 8
  store i32 0, ptr %51, align 4
  store float 1.000000e+00, ptr %52, align 4
  %53 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 2
  %54 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 0
  %55 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 1
  %56 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 2
  %57 = getelementptr { ptr, ptr, i32, float }, ptr %53, i32 0, i32 3
  store ptr @node_str_2, ptr %54, align 8
  store ptr @arch_str_2, ptr %55, align 8
  store i32 0, ptr %56, align 4
  store float 1.000000e+00, ptr %57, align 4
  %58 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 3
  %59 = getelementptr { ptr, ptr, i32, float }, ptr %58, i32 0, i32 0
  %60 = getelementptr { ptr, ptr, i32, float }, ptr %58, i32 0, i32 1
  %61 = getelementptr { ptr, ptr, i32, float }, ptr %58, i32 0, i32 2
  %62 = getelementptr { ptr, ptr, i32, float }, ptr %58, i32 0, i32 3
  store ptr @node_str_3, ptr %59, align 8
  store ptr @arch_str_3, ptr %60, align 8
  store i32 0, ptr %61, align 4
  store float 1.000000e+00, ptr %62, align 4
  %63 = alloca { i32, ptr }, i64 1, align 8
  %64 = getelementptr { i32, ptr }, ptr %63, i32 0, i32 0
  %65 = getelementptr { i32, ptr }, ptr %63, i32 0, i32 1
  store i32 4, ptr %64, align 4
  store ptr %43, ptr %65, align 8
  %66 = call ptr @malloc(i64 16)
  %67 = call ptr @malloc(i64 16)
  %68 = ptrtoint ptr %66 to i64
  %69 = ptrtoint ptr %67 to i64
  %70 = inttoptr i64 %68 to ptr
  %71 = inttoptr i64 %69 to ptr
  call void @buildRankNodeMaps(ptr %63, ptr %70, ptr %71)
  %72 = sext i32 %42 to i64
  %73 = getelementptr inbounds nuw i32, ptr %66, i64 %72
  %74 = load i32, ptr %73, align 4
  %75 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %76 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %77 = insertvalue { ptr, ptr, i64 } poison, ptr %75, 0
  %78 = insertvalue { ptr, ptr, i64 } %77, ptr %76, 1
  %79 = insertvalue { ptr, ptr, i64 } %78, i64 0, 2
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %81 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %82 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %83 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %84 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %85 = extractvalue { ptr, ptr, i64 } %79, 0
  %86 = extractvalue { ptr, ptr, i64 } %79, 1
  %87 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %85, 0
  %88 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %87, ptr %86, 1
  %89 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %88, i64 0, 2
  %90 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %89, i64 250, 3, 0
  %91 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %90, i64 1000, 4, 0
  %92 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %91, i64 1000, 3, 1
  %93 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %92, i64 1, 4, 1
  %94 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %95 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %96 = insertvalue { ptr, ptr, i64 } poison, ptr %94, 0
  %97 = insertvalue { ptr, ptr, i64 } %96, ptr %95, 1
  %98 = insertvalue { ptr, ptr, i64 } %97, i64 0, 2
  %99 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %100 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %101 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %102 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %103 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %104 = extractvalue { ptr, ptr, i64 } %98, 0
  %105 = extractvalue { ptr, ptr, i64 } %98, 1
  %106 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %104, 0
  %107 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %106, ptr %105, 1
  %108 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %107, i64 0, 2
  %109 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %108, i64 250, 3, 0
  %110 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, i64 1000, 4, 0
  %111 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %110, i64 1000, 3, 1
  %112 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %111, i64 1, 4, 1
  %113 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %114 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %115 = insertvalue { ptr, ptr, i64 } poison, ptr %113, 0
  %116 = insertvalue { ptr, ptr, i64 } %115, ptr %114, 1
  %117 = insertvalue { ptr, ptr, i64 } %116, i64 0, 2
  %118 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %119 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %120 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %121 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %122 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %123 = extractvalue { ptr, ptr, i64 } %117, 0
  %124 = extractvalue { ptr, ptr, i64 } %117, 1
  %125 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %123, 0
  %126 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %125, ptr %124, 1
  %127 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %126, i64 250000, 2
  %128 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %127, i64 250, 3, 0
  %129 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %128, i64 1000, 4, 0
  %130 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %129, i64 1000, 3, 1
  %131 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %130, i64 1, 4, 1
  %132 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %133 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %134 = insertvalue { ptr, ptr, i64 } poison, ptr %132, 0
  %135 = insertvalue { ptr, ptr, i64 } %134, ptr %133, 1
  %136 = insertvalue { ptr, ptr, i64 } %135, i64 0, 2
  %137 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %138 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %139 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %140 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %141 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %142 = extractvalue { ptr, ptr, i64 } %136, 0
  %143 = extractvalue { ptr, ptr, i64 } %136, 1
  %144 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %142, 0
  %145 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %144, ptr %143, 1
  %146 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %145, i64 250000, 2
  %147 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, i64 250, 3, 0
  %148 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %147, i64 1000, 4, 0
  %149 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %148, i64 1000, 3, 1
  %150 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %149, i64 1, 4, 1
  %151 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %152 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %153 = insertvalue { ptr, ptr, i64 } poison, ptr %151, 0
  %154 = insertvalue { ptr, ptr, i64 } %153, ptr %152, 1
  %155 = insertvalue { ptr, ptr, i64 } %154, i64 0, 2
  %156 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %157 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %158 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %159 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %160 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %161 = extractvalue { ptr, ptr, i64 } %155, 0
  %162 = extractvalue { ptr, ptr, i64 } %155, 1
  %163 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %161, 0
  %164 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %163, ptr %162, 1
  %165 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %164, i64 500000, 2
  %166 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %165, i64 250, 3, 0
  %167 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, i64 1000, 4, 0
  %168 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %167, i64 1000, 3, 1
  %169 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %168, i64 1, 4, 1
  %170 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %171 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %172 = insertvalue { ptr, ptr, i64 } poison, ptr %170, 0
  %173 = insertvalue { ptr, ptr, i64 } %172, ptr %171, 1
  %174 = insertvalue { ptr, ptr, i64 } %173, i64 0, 2
  %175 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %176 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %177 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %178 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %179 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %180 = extractvalue { ptr, ptr, i64 } %174, 0
  %181 = extractvalue { ptr, ptr, i64 } %174, 1
  %182 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %180, 0
  %183 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %182, ptr %181, 1
  %184 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %183, i64 500000, 2
  %185 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %184, i64 250, 3, 0
  %186 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, i64 1000, 4, 0
  %187 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %186, i64 1000, 3, 1
  %188 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %187, i64 1, 4, 1
  %189 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %190 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %191 = insertvalue { ptr, ptr, i64 } poison, ptr %189, 0
  %192 = insertvalue { ptr, ptr, i64 } %191, ptr %190, 1
  %193 = insertvalue { ptr, ptr, i64 } %192, i64 0, 2
  %194 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %195 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %196 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %197 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %198 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %199 = extractvalue { ptr, ptr, i64 } %193, 0
  %200 = extractvalue { ptr, ptr, i64 } %193, 1
  %201 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %199, 0
  %202 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %201, ptr %200, 1
  %203 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %202, i64 750000, 2
  %204 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %203, i64 250, 3, 0
  %205 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, i64 1000, 4, 0
  %206 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %205, i64 1000, 3, 1
  %207 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %206, i64 1, 4, 1
  %208 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %209 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %210 = insertvalue { ptr, ptr, i64 } poison, ptr %208, 0
  %211 = insertvalue { ptr, ptr, i64 } %210, ptr %209, 1
  %212 = insertvalue { ptr, ptr, i64 } %211, i64 0, 2
  %213 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %214 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %215 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %216 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %217 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %218 = extractvalue { ptr, ptr, i64 } %212, 0
  %219 = extractvalue { ptr, ptr, i64 } %212, 1
  %220 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %218, 0
  %221 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %220, ptr %219, 1
  %222 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %221, i64 750000, 2
  %223 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %222, i64 250, 3, 0
  %224 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, i64 1000, 4, 0
  %225 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %224, i64 1000, 3, 1
  %226 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %225, i64 1, 4, 1
  %227 = icmp eq i32 %74, 0
  br i1 %227, label %228, label %229

228:                                              ; preds = %24
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %112, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %93, ptr %.reloaded15, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %228
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded15, ptr %gep_.reloaded15, align 8
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %11, ptr %gep_, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %229

229:                                              ; preds = %omp.par.exit, %24
  %230 = icmp eq i32 %74, 1
  br i1 %230, label %231, label %232

231:                                              ; preds = %229
  %omp_global_thread_num16 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %150, ptr %.reloaded59, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %131, ptr %.reloaded60, align 8
  br label %omp_parallel156

omp_parallel156:                                  ; preds = %231
  %gep_.reloaded59 = getelementptr { ptr, ptr, ptr }, ptr %structArg154, i32 0, i32 0
  store ptr %.reloaded59, ptr %gep_.reloaded59, align 8
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %structArg154, i32 0, i32 1
  store ptr %.reloaded60, ptr %gep_.reloaded60, align 8
  %gep_155 = getelementptr { ptr, ptr, ptr }, ptr %structArg154, i32 0, i32 2
  store ptr %11, ptr %gep_155, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par.1, ptr %structArg154)
  br label %omp.par.exit22

omp.par.exit22:                                   ; preds = %omp_parallel156
  br label %232

232:                                              ; preds = %omp.par.exit22, %229
  %233 = icmp eq i32 %74, 2
  br i1 %233, label %234, label %235

234:                                              ; preds = %232
  %omp_global_thread_num62 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %188, ptr %.reloaded105, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %169, ptr %.reloaded106, align 8
  br label %omp_parallel159

omp_parallel159:                                  ; preds = %234
  %gep_.reloaded105 = getelementptr { ptr, ptr, ptr }, ptr %structArg157, i32 0, i32 0
  store ptr %.reloaded105, ptr %gep_.reloaded105, align 8
  %gep_.reloaded106 = getelementptr { ptr, ptr, ptr }, ptr %structArg157, i32 0, i32 1
  store ptr %.reloaded106, ptr %gep_.reloaded106, align 8
  %gep_158 = getelementptr { ptr, ptr, ptr }, ptr %structArg157, i32 0, i32 2
  store ptr %11, ptr %gep_158, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par.2, ptr %structArg157)
  br label %omp.par.exit68

omp.par.exit68:                                   ; preds = %omp_parallel159
  br label %235

235:                                              ; preds = %omp.par.exit68, %232
  %236 = icmp eq i32 %74, 3
  br i1 %236, label %237, label %238

237:                                              ; preds = %235
  %omp_global_thread_num108 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %226, ptr %.reloaded151, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %207, ptr %.reloaded152, align 8
  br label %omp_parallel162

omp_parallel162:                                  ; preds = %237
  %gep_.reloaded151 = getelementptr { ptr, ptr, ptr }, ptr %structArg160, i32 0, i32 0
  store ptr %.reloaded151, ptr %gep_.reloaded151, align 8
  %gep_.reloaded152 = getelementptr { ptr, ptr, ptr }, ptr %structArg160, i32 0, i32 1
  store ptr %.reloaded152, ptr %gep_.reloaded152, align 8
  %gep_161 = getelementptr { ptr, ptr, ptr }, ptr %structArg160, i32 0, i32 2
  store ptr %11, ptr %gep_161, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par.3, ptr %structArg160)
  br label %omp.par.exit114

omp.par.exit114:                                  ; preds = %omp_parallel162
  br label %238

238:                                              ; preds = %omp.par.exit114, %235
  %239 = call i32 @MPI_Barrier(i32 1140850688)
  %240 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %241 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %242 = insertvalue { ptr, ptr, i64 } poison, ptr %240, 0
  %243 = insertvalue { ptr, ptr, i64 } %242, ptr %241, 1
  %244 = insertvalue { ptr, ptr, i64 } %243, i64 0, 2
  %245 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %246 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %247 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %248 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %249 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %250 = extractvalue { ptr, ptr, i64 } %244, 0
  %251 = extractvalue { ptr, ptr, i64 } %244, 1
  %252 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %250, 0
  %253 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, ptr %251, 1
  %254 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %253, i64 250000, 2
  %255 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %254, i64 250, 3, 0
  %256 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, i64 1000, 4, 0
  %257 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %256, i64 1000, 3, 1
  %258 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %257, i64 1, 4, 1
  %259 = load i32, ptr %67, align 4
  %260 = getelementptr inbounds nuw i32, ptr %67, i32 1
  %261 = load i32, ptr %260, align 4
  %262 = icmp eq i32 %42, %259
  %263 = icmp eq i32 %42, %261
  br i1 %262, label %264, label %271

264:                                              ; preds = %238
  %265 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %258, 1
  %266 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %258, 2
  %267 = getelementptr float, ptr %265, i64 %266
  %268 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %258, 3, 0
  %269 = trunc i64 %268 to i32
  %270 = call i32 @MPI_Recv(ptr %267, i32 %269, i32 1275069450, i32 %261, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %280

271:                                              ; preds = %238
  br i1 %263, label %272, label %279

272:                                              ; preds = %271
  %273 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %258, 1
  %274 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %258, 2
  %275 = getelementptr float, ptr %273, i64 %274
  %276 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %258, 3, 0
  %277 = trunc i64 %276 to i32
  %278 = call i32 @MPI_Send(ptr %275, i32 %277, i32 1275069450, i32 %259, i32 0, i32 1140850688)
  br label %279

279:                                              ; preds = %272, %271
  br label %280

280:                                              ; preds = %264, %279
  %281 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %282 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %283 = insertvalue { ptr, ptr, i64 } poison, ptr %281, 0
  %284 = insertvalue { ptr, ptr, i64 } %283, ptr %282, 1
  %285 = insertvalue { ptr, ptr, i64 } %284, i64 0, 2
  %286 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %287 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %288 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %289 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %290 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %291 = extractvalue { ptr, ptr, i64 } %285, 0
  %292 = extractvalue { ptr, ptr, i64 } %285, 1
  %293 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %291, 0
  %294 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, ptr %292, 1
  %295 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %294, i64 500000, 2
  %296 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %295, i64 250, 3, 0
  %297 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %296, i64 1000, 4, 0
  %298 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, i64 1000, 3, 1
  %299 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %298, i64 1, 4, 1
  %300 = load i32, ptr %67, align 4
  %301 = getelementptr inbounds nuw i32, ptr %67, i32 2
  %302 = load i32, ptr %301, align 4
  %303 = icmp eq i32 %42, %300
  %304 = icmp eq i32 %42, %302
  br i1 %303, label %305, label %312

305:                                              ; preds = %280
  %306 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %299, 1
  %307 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %299, 2
  %308 = getelementptr float, ptr %306, i64 %307
  %309 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %299, 3, 0
  %310 = trunc i64 %309 to i32
  %311 = call i32 @MPI_Recv(ptr %308, i32 %310, i32 1275069450, i32 %302, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %321

312:                                              ; preds = %280
  br i1 %304, label %313, label %320

313:                                              ; preds = %312
  %314 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %299, 1
  %315 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %299, 2
  %316 = getelementptr float, ptr %314, i64 %315
  %317 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %299, 3, 0
  %318 = trunc i64 %317 to i32
  %319 = call i32 @MPI_Send(ptr %316, i32 %318, i32 1275069450, i32 %300, i32 0, i32 1140850688)
  br label %320

320:                                              ; preds = %313, %312
  br label %321

321:                                              ; preds = %305, %320
  %322 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %323 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %324 = insertvalue { ptr, ptr, i64 } poison, ptr %322, 0
  %325 = insertvalue { ptr, ptr, i64 } %324, ptr %323, 1
  %326 = insertvalue { ptr, ptr, i64 } %325, i64 0, 2
  %327 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %328 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %329 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %330 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %331 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %332 = extractvalue { ptr, ptr, i64 } %326, 0
  %333 = extractvalue { ptr, ptr, i64 } %326, 1
  %334 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %332, 0
  %335 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %334, ptr %333, 1
  %336 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %335, i64 750000, 2
  %337 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %336, i64 250, 3, 0
  %338 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %337, i64 1000, 4, 0
  %339 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %338, i64 1000, 3, 1
  %340 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %339, i64 1, 4, 1
  %341 = load i32, ptr %67, align 4
  %342 = getelementptr inbounds nuw i32, ptr %67, i32 3
  %343 = load i32, ptr %342, align 4
  %344 = icmp eq i32 %42, %341
  %345 = icmp eq i32 %42, %343
  br i1 %344, label %346, label %353

346:                                              ; preds = %321
  %347 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, 1
  %348 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, 2
  %349 = getelementptr float, ptr %347, i64 %348
  %350 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, 3, 0
  %351 = trunc i64 %350 to i32
  %352 = call i32 @MPI_Recv(ptr %349, i32 %351, i32 1275069450, i32 %343, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %362

353:                                              ; preds = %321
  br i1 %345, label %354, label %361

354:                                              ; preds = %353
  %355 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, 1
  %356 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, 2
  %357 = getelementptr float, ptr %355, i64 %356
  %358 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, 3, 0
  %359 = trunc i64 %358 to i32
  %360 = call i32 @MPI_Send(ptr %357, i32 %359, i32 1275069450, i32 %341, i32 0, i32 1140850688)
  br label %361

361:                                              ; preds = %354, %353
  br label %362

362:                                              ; preds = %346, %361
  %363 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par.3(ptr noalias %tid.addr109, ptr noalias %zero.addr110, ptr %0) #0 {
omp.par.entry111:
  %gep_.reloaded151 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded151 = load ptr, ptr %gep_.reloaded151, align 8, !align !1
  %gep_.reloaded152 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded152 = load ptr, ptr %gep_.reloaded152, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter145 = alloca i32, align 4
  %p.lowerbound146 = alloca i64, align 8
  %p.upperbound147 = alloca i64, align 8
  %p.stride148 = alloca i64, align 8
  %tid.addr.local115 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr109, align 4
  store i32 %1, ptr %tid.addr.local115, align 4
  %tid116 = load i32, ptr %tid.addr.local115, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded151, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded152, align 8
  br label %omp.region.after_alloca122

omp.region.after_alloca122:                       ; preds = %omp.par.entry111
  br label %omp.region.after_alloca119

omp.region.after_alloca119:                       ; preds = %omp.region.after_alloca122
  br label %omp.par.region112

omp.par.region112:                                ; preds = %omp.region.after_alloca119
  br label %omp.par.region121

omp.par.region121:                                ; preds = %omp.par.region112
  br label %omp.wsloop.region124

omp.wsloop.region124:                             ; preds = %omp.par.region121
  br label %omp_loop.preheader125

omp_loop.preheader125:                            ; preds = %omp.wsloop.region124
  store i64 0, ptr %p.lowerbound146, align 4
  store i64 249, ptr %p.upperbound147, align 4
  store i64 1, ptr %p.stride148, align 4
  %omp_global_thread_num149 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num149, i32 34, ptr %p.lastiter145, ptr %p.lowerbound146, ptr %p.upperbound147, ptr %p.stride148, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound146, align 4
  %5 = load i64, ptr %p.upperbound147, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header126

omp_loop.header126:                               ; preds = %omp_loop.inc129, %omp_loop.preheader125
  %omp_loop.iv132 = phi i64 [ 0, %omp_loop.preheader125 ], [ %omp_loop.next134, %omp_loop.inc129 ]
  br label %omp_loop.cond127

omp_loop.cond127:                                 ; preds = %omp_loop.header126
  %omp_loop.cmp133 = icmp ult i64 %omp_loop.iv132, %7
  br i1 %omp_loop.cmp133, label %omp_loop.body128, label %omp_loop.exit130

omp_loop.exit130:                                 ; preds = %omp_loop.cond127
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num149)
  %omp_global_thread_num150 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num150)
  br label %omp_loop.after131

omp_loop.after131:                                ; preds = %omp_loop.exit130
  br label %omp.region.cont123

omp.region.cont123:                               ; preds = %omp_loop.after131
  br label %omp.region.cont120

omp.region.cont120:                               ; preds = %omp.region.cont123
  br label %omp.par.pre_finalize113

omp.par.pre_finalize113:                          ; preds = %omp.region.cont120
  br label %.fini153

.fini153:                                         ; preds = %omp.par.pre_finalize113
  br label %omp.par.exit114.exitStub

omp_loop.body128:                                 ; preds = %omp_loop.cond127
  %8 = add i64 %omp_loop.iv132, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region136

omp.loop_nest.region136:                          ; preds = %omp_loop.body128
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region137

omp.loop_nest.region137:                          ; preds = %omp.loop_nest.region136
  br label %omp.loop_nest.region138

omp.loop_nest.region138:                          ; preds = %omp.loop_nest.region142, %omp.loop_nest.region137
  %12 = phi i64 [ %21, %omp.loop_nest.region142 ], [ 0, %omp.loop_nest.region137 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region139, label %omp.loop_nest.region143

omp.loop_nest.region143:                          ; preds = %omp.loop_nest.region138
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region144

omp.loop_nest.region144:                          ; preds = %omp.loop_nest.region143
  br label %omp.region.cont135

omp.region.cont135:                               ; preds = %omp.loop_nest.region144
  br label %omp_loop.inc129

omp_loop.inc129:                                  ; preds = %omp.region.cont135
  %omp_loop.next134 = add nuw i64 %omp_loop.iv132, 1
  br label %omp_loop.header126

omp.loop_nest.region139:                          ; preds = %omp.loop_nest.region138
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 750000
  %16 = mul nuw nsw i64 %10, 1000
  %17 = add nuw nsw i64 %16, %12
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  store float 0.000000e+00, ptr %18, align 4
  br label %omp.loop_nest.region140

omp.loop_nest.region140:                          ; preds = %omp.loop_nest.region141, %omp.loop_nest.region139
  %19 = phi i64 [ %45, %omp.loop_nest.region141 ], [ 0, %omp.loop_nest.region139 ]
  %20 = icmp slt i64 %19, 1000
  br i1 %20, label %omp.loop_nest.region141, label %omp.loop_nest.region142

omp.loop_nest.region142:                          ; preds = %omp.loop_nest.region140
  %21 = add i64 %12, 1
  br label %omp.loop_nest.region138

omp.loop_nest.region141:                          ; preds = %omp.loop_nest.region140
  %22 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %23 = getelementptr float, ptr %22, i32 750000
  %24 = mul nuw nsw i64 %10, 1000
  %25 = add nuw nsw i64 %24, %19
  %26 = getelementptr inbounds nuw float, ptr %23, i64 %25
  %27 = load float, ptr %26, align 4
  %28 = mul nuw nsw i64 %19, 1000
  %29 = add nuw nsw i64 %28, %12
  %30 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %29
  %31 = load float, ptr %30, align 4
  %32 = fmul float %27, %31
  %33 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %34 = getelementptr float, ptr %33, i32 750000
  %35 = mul nuw nsw i64 %10, 1000
  %36 = add nuw nsw i64 %35, %12
  %37 = getelementptr inbounds nuw float, ptr %34, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %38, %32
  %40 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %41 = getelementptr float, ptr %40, i32 750000
  %42 = mul nuw nsw i64 %10, 1000
  %43 = add nuw nsw i64 %42, %12
  %44 = getelementptr inbounds nuw float, ptr %41, i64 %43
  store float %39, ptr %44, align 4
  %45 = add i64 %19, 1
  br label %omp.loop_nest.region140

omp.par.exit114.exitStub:                         ; preds = %.fini153
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par.2(ptr noalias %tid.addr63, ptr noalias %zero.addr64, ptr %0) #0 {
omp.par.entry65:
  %gep_.reloaded105 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded105 = load ptr, ptr %gep_.reloaded105, align 8, !align !1
  %gep_.reloaded106 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded106 = load ptr, ptr %gep_.reloaded106, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter99 = alloca i32, align 4
  %p.lowerbound100 = alloca i64, align 8
  %p.upperbound101 = alloca i64, align 8
  %p.stride102 = alloca i64, align 8
  %tid.addr.local69 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr63, align 4
  store i32 %1, ptr %tid.addr.local69, align 4
  %tid70 = load i32, ptr %tid.addr.local69, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded105, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded106, align 8
  br label %omp.region.after_alloca76

omp.region.after_alloca76:                        ; preds = %omp.par.entry65
  br label %omp.region.after_alloca73

omp.region.after_alloca73:                        ; preds = %omp.region.after_alloca76
  br label %omp.par.region66

omp.par.region66:                                 ; preds = %omp.region.after_alloca73
  br label %omp.par.region75

omp.par.region75:                                 ; preds = %omp.par.region66
  br label %omp.wsloop.region78

omp.wsloop.region78:                              ; preds = %omp.par.region75
  br label %omp_loop.preheader79

omp_loop.preheader79:                             ; preds = %omp.wsloop.region78
  store i64 0, ptr %p.lowerbound100, align 4
  store i64 249, ptr %p.upperbound101, align 4
  store i64 1, ptr %p.stride102, align 4
  %omp_global_thread_num103 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num103, i32 34, ptr %p.lastiter99, ptr %p.lowerbound100, ptr %p.upperbound101, ptr %p.stride102, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound100, align 4
  %5 = load i64, ptr %p.upperbound101, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header80

omp_loop.header80:                                ; preds = %omp_loop.inc83, %omp_loop.preheader79
  %omp_loop.iv86 = phi i64 [ 0, %omp_loop.preheader79 ], [ %omp_loop.next88, %omp_loop.inc83 ]
  br label %omp_loop.cond81

omp_loop.cond81:                                  ; preds = %omp_loop.header80
  %omp_loop.cmp87 = icmp ult i64 %omp_loop.iv86, %7
  br i1 %omp_loop.cmp87, label %omp_loop.body82, label %omp_loop.exit84

omp_loop.exit84:                                  ; preds = %omp_loop.cond81
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num103)
  %omp_global_thread_num104 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num104)
  br label %omp_loop.after85

omp_loop.after85:                                 ; preds = %omp_loop.exit84
  br label %omp.region.cont77

omp.region.cont77:                                ; preds = %omp_loop.after85
  br label %omp.region.cont74

omp.region.cont74:                                ; preds = %omp.region.cont77
  br label %omp.par.pre_finalize67

omp.par.pre_finalize67:                           ; preds = %omp.region.cont74
  br label %.fini107

.fini107:                                         ; preds = %omp.par.pre_finalize67
  br label %omp.par.exit68.exitStub

omp_loop.body82:                                  ; preds = %omp_loop.cond81
  %8 = add i64 %omp_loop.iv86, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region90

omp.loop_nest.region90:                           ; preds = %omp_loop.body82
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region91

omp.loop_nest.region91:                           ; preds = %omp.loop_nest.region90
  br label %omp.loop_nest.region92

omp.loop_nest.region92:                           ; preds = %omp.loop_nest.region96, %omp.loop_nest.region91
  %12 = phi i64 [ %21, %omp.loop_nest.region96 ], [ 0, %omp.loop_nest.region91 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region93, label %omp.loop_nest.region97

omp.loop_nest.region97:                           ; preds = %omp.loop_nest.region92
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region98

omp.loop_nest.region98:                           ; preds = %omp.loop_nest.region97
  br label %omp.region.cont89

omp.region.cont89:                                ; preds = %omp.loop_nest.region98
  br label %omp_loop.inc83

omp_loop.inc83:                                   ; preds = %omp.region.cont89
  %omp_loop.next88 = add nuw i64 %omp_loop.iv86, 1
  br label %omp_loop.header80

omp.loop_nest.region93:                           ; preds = %omp.loop_nest.region92
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 500000
  %16 = mul nuw nsw i64 %10, 1000
  %17 = add nuw nsw i64 %16, %12
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  store float 0.000000e+00, ptr %18, align 4
  br label %omp.loop_nest.region94

omp.loop_nest.region94:                           ; preds = %omp.loop_nest.region95, %omp.loop_nest.region93
  %19 = phi i64 [ %45, %omp.loop_nest.region95 ], [ 0, %omp.loop_nest.region93 ]
  %20 = icmp slt i64 %19, 1000
  br i1 %20, label %omp.loop_nest.region95, label %omp.loop_nest.region96

omp.loop_nest.region96:                           ; preds = %omp.loop_nest.region94
  %21 = add i64 %12, 1
  br label %omp.loop_nest.region92

omp.loop_nest.region95:                           ; preds = %omp.loop_nest.region94
  %22 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %23 = getelementptr float, ptr %22, i32 500000
  %24 = mul nuw nsw i64 %10, 1000
  %25 = add nuw nsw i64 %24, %19
  %26 = getelementptr inbounds nuw float, ptr %23, i64 %25
  %27 = load float, ptr %26, align 4
  %28 = mul nuw nsw i64 %19, 1000
  %29 = add nuw nsw i64 %28, %12
  %30 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %29
  %31 = load float, ptr %30, align 4
  %32 = fmul float %27, %31
  %33 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %34 = getelementptr float, ptr %33, i32 500000
  %35 = mul nuw nsw i64 %10, 1000
  %36 = add nuw nsw i64 %35, %12
  %37 = getelementptr inbounds nuw float, ptr %34, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %38, %32
  %40 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %41 = getelementptr float, ptr %40, i32 500000
  %42 = mul nuw nsw i64 %10, 1000
  %43 = add nuw nsw i64 %42, %12
  %44 = getelementptr inbounds nuw float, ptr %41, i64 %43
  store float %39, ptr %44, align 4
  %45 = add i64 %19, 1
  br label %omp.loop_nest.region94

omp.par.exit68.exitStub:                          ; preds = %.fini107
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par.1(ptr noalias %tid.addr17, ptr noalias %zero.addr18, ptr %0) #0 {
omp.par.entry19:
  %gep_.reloaded59 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded59 = load ptr, ptr %gep_.reloaded59, align 8, !align !1
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded60 = load ptr, ptr %gep_.reloaded60, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter53 = alloca i32, align 4
  %p.lowerbound54 = alloca i64, align 8
  %p.upperbound55 = alloca i64, align 8
  %p.stride56 = alloca i64, align 8
  %tid.addr.local23 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr17, align 4
  store i32 %1, ptr %tid.addr.local23, align 4
  %tid24 = load i32, ptr %tid.addr.local23, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded59, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded60, align 8
  br label %omp.region.after_alloca30

omp.region.after_alloca30:                        ; preds = %omp.par.entry19
  br label %omp.region.after_alloca27

omp.region.after_alloca27:                        ; preds = %omp.region.after_alloca30
  br label %omp.par.region20

omp.par.region20:                                 ; preds = %omp.region.after_alloca27
  br label %omp.par.region29

omp.par.region29:                                 ; preds = %omp.par.region20
  br label %omp.wsloop.region32

omp.wsloop.region32:                              ; preds = %omp.par.region29
  br label %omp_loop.preheader33

omp_loop.preheader33:                             ; preds = %omp.wsloop.region32
  store i64 0, ptr %p.lowerbound54, align 4
  store i64 249, ptr %p.upperbound55, align 4
  store i64 1, ptr %p.stride56, align 4
  %omp_global_thread_num57 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num57, i32 34, ptr %p.lastiter53, ptr %p.lowerbound54, ptr %p.upperbound55, ptr %p.stride56, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound54, align 4
  %5 = load i64, ptr %p.upperbound55, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header34

omp_loop.header34:                                ; preds = %omp_loop.inc37, %omp_loop.preheader33
  %omp_loop.iv40 = phi i64 [ 0, %omp_loop.preheader33 ], [ %omp_loop.next42, %omp_loop.inc37 ]
  br label %omp_loop.cond35

omp_loop.cond35:                                  ; preds = %omp_loop.header34
  %omp_loop.cmp41 = icmp ult i64 %omp_loop.iv40, %7
  br i1 %omp_loop.cmp41, label %omp_loop.body36, label %omp_loop.exit38

omp_loop.exit38:                                  ; preds = %omp_loop.cond35
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num57)
  %omp_global_thread_num58 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num58)
  br label %omp_loop.after39

omp_loop.after39:                                 ; preds = %omp_loop.exit38
  br label %omp.region.cont31

omp.region.cont31:                                ; preds = %omp_loop.after39
  br label %omp.region.cont28

omp.region.cont28:                                ; preds = %omp.region.cont31
  br label %omp.par.pre_finalize21

omp.par.pre_finalize21:                           ; preds = %omp.region.cont28
  br label %.fini61

.fini61:                                          ; preds = %omp.par.pre_finalize21
  br label %omp.par.exit22.exitStub

omp_loop.body36:                                  ; preds = %omp_loop.cond35
  %8 = add i64 %omp_loop.iv40, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region44

omp.loop_nest.region44:                           ; preds = %omp_loop.body36
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region45

omp.loop_nest.region45:                           ; preds = %omp.loop_nest.region44
  br label %omp.loop_nest.region46

omp.loop_nest.region46:                           ; preds = %omp.loop_nest.region50, %omp.loop_nest.region45
  %12 = phi i64 [ %21, %omp.loop_nest.region50 ], [ 0, %omp.loop_nest.region45 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region47, label %omp.loop_nest.region51

omp.loop_nest.region51:                           ; preds = %omp.loop_nest.region46
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region52

omp.loop_nest.region52:                           ; preds = %omp.loop_nest.region51
  br label %omp.region.cont43

omp.region.cont43:                                ; preds = %omp.loop_nest.region52
  br label %omp_loop.inc37

omp_loop.inc37:                                   ; preds = %omp.region.cont43
  %omp_loop.next42 = add nuw i64 %omp_loop.iv40, 1
  br label %omp_loop.header34

omp.loop_nest.region47:                           ; preds = %omp.loop_nest.region46
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 250000
  %16 = mul nuw nsw i64 %10, 1000
  %17 = add nuw nsw i64 %16, %12
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  store float 0.000000e+00, ptr %18, align 4
  br label %omp.loop_nest.region48

omp.loop_nest.region48:                           ; preds = %omp.loop_nest.region49, %omp.loop_nest.region47
  %19 = phi i64 [ %45, %omp.loop_nest.region49 ], [ 0, %omp.loop_nest.region47 ]
  %20 = icmp slt i64 %19, 1000
  br i1 %20, label %omp.loop_nest.region49, label %omp.loop_nest.region50

omp.loop_nest.region50:                           ; preds = %omp.loop_nest.region48
  %21 = add i64 %12, 1
  br label %omp.loop_nest.region46

omp.loop_nest.region49:                           ; preds = %omp.loop_nest.region48
  %22 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %23 = getelementptr float, ptr %22, i32 250000
  %24 = mul nuw nsw i64 %10, 1000
  %25 = add nuw nsw i64 %24, %19
  %26 = getelementptr inbounds nuw float, ptr %23, i64 %25
  %27 = load float, ptr %26, align 4
  %28 = mul nuw nsw i64 %19, 1000
  %29 = add nuw nsw i64 %28, %12
  %30 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %29
  %31 = load float, ptr %30, align 4
  %32 = fmul float %27, %31
  %33 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %34 = getelementptr float, ptr %33, i32 250000
  %35 = mul nuw nsw i64 %10, 1000
  %36 = add nuw nsw i64 %35, %12
  %37 = getelementptr inbounds nuw float, ptr %34, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %38, %32
  %40 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %41 = getelementptr float, ptr %40, i32 250000
  %42 = mul nuw nsw i64 %10, 1000
  %43 = add nuw nsw i64 %42, %12
  %44 = getelementptr inbounds nuw float, ptr %41, i64 %43
  store float %39, ptr %44, align 4
  %45 = add i64 %19, 1
  br label %omp.loop_nest.region48

omp.par.exit22.exitStub:                          ; preds = %.fini61
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded15 = load ptr, ptr %gep_.reloaded15, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
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
  %omp_global_thread_num13 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num13, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
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

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region10, %omp.loop_nest.region5
  %12 = phi i64 [ %20, %omp.loop_nest.region10 ], [ 0, %omp.loop_nest.region5 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region7, label %omp.loop_nest.region11

omp.loop_nest.region11:                           ; preds = %omp.loop_nest.region6
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region12

omp.loop_nest.region12:                           ; preds = %omp.loop_nest.region11
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region12
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.loop_nest.region7:                            ; preds = %omp.loop_nest.region6
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = mul nuw nsw i64 %10, 1000
  %16 = add nuw nsw i64 %15, %12
  %17 = getelementptr inbounds nuw float, ptr %14, i64 %16
  store float 0.000000e+00, ptr %17, align 4
  br label %omp.loop_nest.region8

omp.loop_nest.region8:                            ; preds = %omp.loop_nest.region9, %omp.loop_nest.region7
  %18 = phi i64 [ %41, %omp.loop_nest.region9 ], [ 0, %omp.loop_nest.region7 ]
  %19 = icmp slt i64 %18, 1000
  br i1 %19, label %omp.loop_nest.region9, label %omp.loop_nest.region10

omp.loop_nest.region10:                           ; preds = %omp.loop_nest.region8
  %20 = add i64 %12, 1
  br label %omp.loop_nest.region6

omp.loop_nest.region9:                            ; preds = %omp.loop_nest.region8
  %21 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %22 = mul nuw nsw i64 %10, 1000
  %23 = add nuw nsw i64 %22, %18
  %24 = getelementptr inbounds nuw float, ptr %21, i64 %23
  %25 = load float, ptr %24, align 4
  %26 = mul nuw nsw i64 %18, 1000
  %27 = add nuw nsw i64 %26, %12
  %28 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %27
  %29 = load float, ptr %28, align 4
  %30 = fmul float %25, %29
  %31 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %32 = mul nuw nsw i64 %10, 1000
  %33 = add nuw nsw i64 %32, %12
  %34 = getelementptr inbounds nuw float, ptr %31, i64 %33
  %35 = load float, ptr %34, align 4
  %36 = fadd float %35, %30
  %37 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %38 = mul nuw nsw i64 %10, 1000
  %39 = add nuw nsw i64 %38, %12
  %40 = getelementptr inbounds nuw float, ptr %37, i64 %39
  store float %36, ptr %40, align 4
  %41 = add i64 %18, 1
  br label %omp.loop_nest.region8

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
declare !callback !3 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind willreturn }
attributes #2 = { convergent nounwind }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{i64 8}
!2 = !{i64 1}
!3 = !{!4}
!4 = !{i64 2, i64 -1, i64 -1, i1 true}
