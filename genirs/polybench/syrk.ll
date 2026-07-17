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

define void @kernel_syrk(i32 %0, i32 %1, double %2, double %3, ptr %4, ptr %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, ptr %11, ptr %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17) {
  %structArg324 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg321 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg318 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg316 = alloca { ptr, ptr, ptr, ptr }, align 8
  %structArg314 = alloca { ptr, ptr, ptr }, align 8
  %structArg312 = alloca { ptr, ptr, ptr }, align 8
  %structArg310 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded306 = alloca i64, align 8
  %.reloaded307 = alloca double, align 8
  %.reloaded308 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded262 = alloca i64, align 8
  %.reloaded263 = alloca double, align 8
  %.reloaded264 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded218 = alloca i64, align 8
  %.reloaded219 = alloca double, align 8
  %.reloaded220 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded174 = alloca i64, align 8
  %.reloaded175 = alloca double, align 8
  %.reloaded176 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded130 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded131 = alloca i64, align 8
  %.reloaded132 = alloca double, align 8
  %.reloaded89 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded90 = alloca i64, align 8
  %.reloaded91 = alloca double, align 8
  %.reloaded48 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded49 = alloca i64, align 8
  %.reloaded50 = alloca double, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded9 = alloca i64, align 8
  %.reloaded10 = alloca double, align 8
  %19 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %4, 0
  %20 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %19, ptr %5, 1
  %21 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %20, i64 %6, 2
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %21, i64 %7, 3, 0
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, i64 %9, 4, 0
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, i64 %8, 3, 1
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, i64 %10, 4, 1
  %26 = call i32 @MPI_Init(ptr null, ptr null)
  %27 = alloca i32, align 4
  %28 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %27)
  %29 = load i32, ptr %27, align 4
  %30 = alloca i32, align 4
  %31 = call i32 @MPI_Comm_size(i32 1140850688, ptr %30)
  %32 = load i32, ptr %30, align 4
  %33 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %34 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 0
  %35 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 1
  %36 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 2
  %37 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 3
  store ptr @node_str_0, ptr %34, align 8
  store ptr @arch_str_0, ptr %35, align 8
  store i32 0, ptr %36, align 4
  store float 1.000000e+00, ptr %37, align 4
  %38 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 1
  %39 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 0
  %40 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 1
  %41 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 2
  %42 = getelementptr { ptr, ptr, i32, float }, ptr %38, i32 0, i32 3
  store ptr @node_str_1, ptr %39, align 8
  store ptr @arch_str_1, ptr %40, align 8
  store i32 0, ptr %41, align 4
  store float 1.000000e+00, ptr %42, align 4
  %43 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 2
  %44 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 0
  %45 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 1
  %46 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 2
  %47 = getelementptr { ptr, ptr, i32, float }, ptr %43, i32 0, i32 3
  store ptr @node_str_2, ptr %44, align 8
  store ptr @arch_str_2, ptr %45, align 8
  store i32 0, ptr %46, align 4
  store float 1.000000e+00, ptr %47, align 4
  %48 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 3
  %49 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 0
  %50 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 1
  %51 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 2
  %52 = getelementptr { ptr, ptr, i32, float }, ptr %48, i32 0, i32 3
  store ptr @node_str_3, ptr %49, align 8
  store ptr @arch_str_3, ptr %50, align 8
  store i32 0, ptr %51, align 4
  store float 1.000000e+00, ptr %52, align 4
  %53 = alloca { i32, ptr }, i64 1, align 8
  %54 = getelementptr { i32, ptr }, ptr %53, i32 0, i32 0
  %55 = getelementptr { i32, ptr }, ptr %53, i32 0, i32 1
  store i32 4, ptr %54, align 4
  store ptr %33, ptr %55, align 8
  %56 = call ptr @malloc(i64 16)
  %57 = call ptr @malloc(i64 16)
  %58 = ptrtoint ptr %56 to i64
  %59 = ptrtoint ptr %57 to i64
  %60 = inttoptr i64 %58 to ptr
  %61 = inttoptr i64 %59 to ptr
  call void @buildRankNodeMaps(ptr %53, ptr %60, ptr %61)
  %62 = sext i32 %29 to i64
  %63 = getelementptr inbounds nuw i32, ptr %56, i64 %62
  %64 = load i32, ptr %63, align 4
  br label %65

65:                                               ; preds = %539, %18
  %66 = phi i64 [ %540, %539 ], [ 0, %18 ]
  %67 = icmp slt i64 %66, 2600
  br i1 %67, label %68, label %541

68:                                               ; preds = %65
  %69 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %70 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %71 = insertvalue { ptr, ptr, i64 } poison, ptr %69, 0
  %72 = insertvalue { ptr, ptr, i64 } %71, ptr %70, 1
  %73 = insertvalue { ptr, ptr, i64 } %72, i64 0, 2
  %74 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %75 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %76 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %77 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %78 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %79 = extractvalue { ptr, ptr, i64 } %73, 0
  %80 = extractvalue { ptr, ptr, i64 } %73, 1
  %81 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %79, 0
  %82 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %81, ptr %80, 1
  %83 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %82, i64 0, 2
  %84 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %83, i64 650, 3, 0
  %85 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %84, i64 2600, 4, 0
  %86 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %85, i64 2600, 3, 1
  %87 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %86, i64 1, 4, 1
  %88 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %89 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %90 = insertvalue { ptr, ptr, i64 } poison, ptr %88, 0
  %91 = insertvalue { ptr, ptr, i64 } %90, ptr %89, 1
  %92 = insertvalue { ptr, ptr, i64 } %91, i64 0, 2
  %93 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %94 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %95 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %96 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %97 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %98 = extractvalue { ptr, ptr, i64 } %92, 0
  %99 = extractvalue { ptr, ptr, i64 } %92, 1
  %100 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %98, 0
  %101 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %100, ptr %99, 1
  %102 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %101, i64 1690000, 2
  %103 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %102, i64 650, 3, 0
  %104 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, i64 2600, 4, 0
  %105 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %104, i64 2600, 3, 1
  %106 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, i64 1, 4, 1
  %107 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %108 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %109 = insertvalue { ptr, ptr, i64 } poison, ptr %107, 0
  %110 = insertvalue { ptr, ptr, i64 } %109, ptr %108, 1
  %111 = insertvalue { ptr, ptr, i64 } %110, i64 0, 2
  %112 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %113 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %114 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %115 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %116 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %117 = extractvalue { ptr, ptr, i64 } %111, 0
  %118 = extractvalue { ptr, ptr, i64 } %111, 1
  %119 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %117, 0
  %120 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %119, ptr %118, 1
  %121 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %120, i64 3380000, 2
  %122 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %121, i64 650, 3, 0
  %123 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %122, i64 2600, 4, 0
  %124 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %123, i64 2600, 3, 1
  %125 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %124, i64 1, 4, 1
  %126 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %127 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %128 = insertvalue { ptr, ptr, i64 } poison, ptr %126, 0
  %129 = insertvalue { ptr, ptr, i64 } %128, ptr %127, 1
  %130 = insertvalue { ptr, ptr, i64 } %129, i64 0, 2
  %131 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %132 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %133 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %134 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %135 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %136 = extractvalue { ptr, ptr, i64 } %130, 0
  %137 = extractvalue { ptr, ptr, i64 } %130, 1
  %138 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %136, 0
  %139 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %138, ptr %137, 1
  %140 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %139, i64 5070000, 2
  %141 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %140, i64 650, 3, 0
  %142 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %141, i64 2600, 4, 0
  %143 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %142, i64 2600, 3, 1
  %144 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %143, i64 1, 4, 1
  %145 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %146 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %147 = insertvalue { ptr, ptr, i64 } poison, ptr %145, 0
  %148 = insertvalue { ptr, ptr, i64 } %147, ptr %146, 1
  %149 = insertvalue { ptr, ptr, i64 } %148, i64 0, 2
  %150 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %151 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %152 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %153 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %154 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %155 = extractvalue { ptr, ptr, i64 } %149, 0
  %156 = extractvalue { ptr, ptr, i64 } %149, 1
  %157 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %155, 0
  %158 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %157, ptr %156, 1
  %159 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %158, i64 0, 2
  %160 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %159, i64 500, 3, 0
  %161 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %160, i64 2600, 4, 0
  %162 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %161, i64 2600, 3, 1
  %163 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %162, i64 1, 4, 1
  %164 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %165 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %166 = insertvalue { ptr, ptr, i64 } poison, ptr %164, 0
  %167 = insertvalue { ptr, ptr, i64 } %166, ptr %165, 1
  %168 = insertvalue { ptr, ptr, i64 } %167, i64 0, 2
  %169 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %170 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %171 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %172 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %173 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %174 = extractvalue { ptr, ptr, i64 } %168, 0
  %175 = extractvalue { ptr, ptr, i64 } %168, 1
  %176 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %174, 0
  %177 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %176, ptr %175, 1
  %178 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %177, i64 1300000, 2
  %179 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %178, i64 500, 3, 0
  %180 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %179, i64 2600, 4, 0
  %181 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %180, i64 2600, 3, 1
  %182 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %181, i64 1, 4, 1
  %183 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %184 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %185 = insertvalue { ptr, ptr, i64 } poison, ptr %183, 0
  %186 = insertvalue { ptr, ptr, i64 } %185, ptr %184, 1
  %187 = insertvalue { ptr, ptr, i64 } %186, i64 0, 2
  %188 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %189 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %190 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %191 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %192 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %193 = extractvalue { ptr, ptr, i64 } %187, 0
  %194 = extractvalue { ptr, ptr, i64 } %187, 1
  %195 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %193, 0
  %196 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %195, ptr %194, 1
  %197 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %196, i64 2600000, 2
  %198 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %197, i64 500, 3, 0
  %199 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %198, i64 2600, 4, 0
  %200 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %199, i64 2600, 3, 1
  %201 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %200, i64 1, 4, 1
  %202 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %203 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %204 = insertvalue { ptr, ptr, i64 } poison, ptr %202, 0
  %205 = insertvalue { ptr, ptr, i64 } %204, ptr %203, 1
  %206 = insertvalue { ptr, ptr, i64 } %205, i64 0, 2
  %207 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %208 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %209 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %210 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %211 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %212 = extractvalue { ptr, ptr, i64 } %206, 0
  %213 = extractvalue { ptr, ptr, i64 } %206, 1
  %214 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %212, 0
  %215 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %214, ptr %213, 1
  %216 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %215, i64 3900000, 2
  %217 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %216, i64 500, 3, 0
  %218 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %217, i64 2600, 4, 0
  %219 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %218, i64 2600, 3, 1
  %220 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %219, i64 1, 4, 1
  %221 = icmp eq i32 %64, 0
  br i1 %221, label %222, label %223

222:                                              ; preds = %68
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %87, ptr %.reloaded, align 8
  store i64 %66, ptr %.reloaded9, align 4
  store double %3, ptr %.reloaded10, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %222
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded9 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded9, ptr %gep_.reloaded9, align 8
  %gep_.reloaded10 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded10, ptr %gep_.reloaded10, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %223

223:                                              ; preds = %omp.par.exit, %68
  %224 = icmp eq i32 %64, 1
  br i1 %224, label %225, label %226

225:                                              ; preds = %223
  %omp_global_thread_num11 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %106, ptr %.reloaded48, align 8
  store i64 %66, ptr %.reloaded49, align 4
  store double %3, ptr %.reloaded50, align 8
  br label %omp_parallel311

omp_parallel311:                                  ; preds = %225
  %gep_.reloaded48 = getelementptr { ptr, ptr, ptr }, ptr %structArg310, i32 0, i32 0
  store ptr %.reloaded48, ptr %gep_.reloaded48, align 8
  %gep_.reloaded49 = getelementptr { ptr, ptr, ptr }, ptr %structArg310, i32 0, i32 1
  store ptr %.reloaded49, ptr %gep_.reloaded49, align 8
  %gep_.reloaded50 = getelementptr { ptr, ptr, ptr }, ptr %structArg310, i32 0, i32 2
  store ptr %.reloaded50, ptr %gep_.reloaded50, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par.1, ptr %structArg310)
  br label %omp.par.exit17

omp.par.exit17:                                   ; preds = %omp_parallel311
  br label %226

226:                                              ; preds = %omp.par.exit17, %223
  %227 = icmp eq i32 %64, 2
  br i1 %227, label %228, label %229

228:                                              ; preds = %226
  %omp_global_thread_num52 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %125, ptr %.reloaded89, align 8
  store i64 %66, ptr %.reloaded90, align 4
  store double %3, ptr %.reloaded91, align 8
  br label %omp_parallel313

omp_parallel313:                                  ; preds = %228
  %gep_.reloaded89 = getelementptr { ptr, ptr, ptr }, ptr %structArg312, i32 0, i32 0
  store ptr %.reloaded89, ptr %gep_.reloaded89, align 8
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr }, ptr %structArg312, i32 0, i32 1
  store ptr %.reloaded90, ptr %gep_.reloaded90, align 8
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr }, ptr %structArg312, i32 0, i32 2
  store ptr %.reloaded91, ptr %gep_.reloaded91, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par.2, ptr %structArg312)
  br label %omp.par.exit58

omp.par.exit58:                                   ; preds = %omp_parallel313
  br label %229

229:                                              ; preds = %omp.par.exit58, %226
  %230 = icmp eq i32 %64, 3
  br i1 %230, label %231, label %232

231:                                              ; preds = %229
  %omp_global_thread_num93 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %144, ptr %.reloaded130, align 8
  store i64 %66, ptr %.reloaded131, align 4
  store double %3, ptr %.reloaded132, align 8
  br label %omp_parallel315

omp_parallel315:                                  ; preds = %231
  %gep_.reloaded130 = getelementptr { ptr, ptr, ptr }, ptr %structArg314, i32 0, i32 0
  store ptr %.reloaded130, ptr %gep_.reloaded130, align 8
  %gep_.reloaded131 = getelementptr { ptr, ptr, ptr }, ptr %structArg314, i32 0, i32 1
  store ptr %.reloaded131, ptr %gep_.reloaded131, align 8
  %gep_.reloaded132 = getelementptr { ptr, ptr, ptr }, ptr %structArg314, i32 0, i32 2
  store ptr %.reloaded132, ptr %gep_.reloaded132, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par.3, ptr %structArg314)
  br label %omp.par.exit99

omp.par.exit99:                                   ; preds = %omp_parallel315
  br label %232

232:                                              ; preds = %omp.par.exit99, %229
  %233 = call i32 @MPI_Barrier(i32 1140850688)
  %234 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %235 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %236 = insertvalue { ptr, ptr, i64 } poison, ptr %234, 0
  %237 = insertvalue { ptr, ptr, i64 } %236, ptr %235, 1
  %238 = insertvalue { ptr, ptr, i64 } %237, i64 0, 2
  %239 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %240 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %241 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %242 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %243 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %244 = extractvalue { ptr, ptr, i64 } %238, 0
  %245 = extractvalue { ptr, ptr, i64 } %238, 1
  %246 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %244, 0
  %247 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %246, ptr %245, 1
  %248 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %247, i64 1690000, 2
  %249 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %248, i64 650, 3, 0
  %250 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %249, i64 2600, 4, 0
  %251 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %250, i64 2600, 3, 1
  %252 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %251, i64 1, 4, 1
  %253 = load i32, ptr %57, align 4
  %254 = getelementptr inbounds nuw i32, ptr %57, i32 1
  %255 = load i32, ptr %254, align 4
  %256 = icmp eq i32 %29, %253
  %257 = icmp eq i32 %29, %255
  br i1 %256, label %258, label %265

258:                                              ; preds = %232
  %259 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, 1
  %260 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, 2
  %261 = getelementptr double, ptr %259, i64 %260
  %262 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, 3, 0
  %263 = trunc i64 %262 to i32
  %264 = call i32 @MPI_Recv(ptr %261, i32 %263, i32 1275070475, i32 %255, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %274

265:                                              ; preds = %232
  br i1 %257, label %266, label %273

266:                                              ; preds = %265
  %267 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, 1
  %268 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, 2
  %269 = getelementptr double, ptr %267, i64 %268
  %270 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, 3, 0
  %271 = trunc i64 %270 to i32
  %272 = call i32 @MPI_Send(ptr %269, i32 %271, i32 1275070475, i32 %253, i32 0, i32 1140850688)
  br label %273

273:                                              ; preds = %266, %265
  br label %274

274:                                              ; preds = %258, %273
  %275 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %276 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %277 = insertvalue { ptr, ptr, i64 } poison, ptr %275, 0
  %278 = insertvalue { ptr, ptr, i64 } %277, ptr %276, 1
  %279 = insertvalue { ptr, ptr, i64 } %278, i64 0, 2
  %280 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %281 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %282 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %283 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %284 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %285 = extractvalue { ptr, ptr, i64 } %279, 0
  %286 = extractvalue { ptr, ptr, i64 } %279, 1
  %287 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %285, 0
  %288 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %287, ptr %286, 1
  %289 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %288, i64 3380000, 2
  %290 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %289, i64 650, 3, 0
  %291 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %290, i64 2600, 4, 0
  %292 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %291, i64 2600, 3, 1
  %293 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %292, i64 1, 4, 1
  %294 = load i32, ptr %57, align 4
  %295 = getelementptr inbounds nuw i32, ptr %57, i32 2
  %296 = load i32, ptr %295, align 4
  %297 = icmp eq i32 %29, %294
  %298 = icmp eq i32 %29, %296
  br i1 %297, label %299, label %306

299:                                              ; preds = %274
  %300 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, 1
  %301 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, 2
  %302 = getelementptr double, ptr %300, i64 %301
  %303 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, 3, 0
  %304 = trunc i64 %303 to i32
  %305 = call i32 @MPI_Recv(ptr %302, i32 %304, i32 1275070475, i32 %296, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %315

306:                                              ; preds = %274
  br i1 %298, label %307, label %314

307:                                              ; preds = %306
  %308 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, 1
  %309 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, 2
  %310 = getelementptr double, ptr %308, i64 %309
  %311 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, 3, 0
  %312 = trunc i64 %311 to i32
  %313 = call i32 @MPI_Send(ptr %310, i32 %312, i32 1275070475, i32 %294, i32 0, i32 1140850688)
  br label %314

314:                                              ; preds = %307, %306
  br label %315

315:                                              ; preds = %299, %314
  %316 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %317 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %318 = insertvalue { ptr, ptr, i64 } poison, ptr %316, 0
  %319 = insertvalue { ptr, ptr, i64 } %318, ptr %317, 1
  %320 = insertvalue { ptr, ptr, i64 } %319, i64 0, 2
  %321 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %322 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %323 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %324 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %325 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %326 = extractvalue { ptr, ptr, i64 } %320, 0
  %327 = extractvalue { ptr, ptr, i64 } %320, 1
  %328 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %326, 0
  %329 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %328, ptr %327, 1
  %330 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %329, i64 5070000, 2
  %331 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %330, i64 650, 3, 0
  %332 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %331, i64 2600, 4, 0
  %333 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %332, i64 2600, 3, 1
  %334 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %333, i64 1, 4, 1
  %335 = load i32, ptr %57, align 4
  %336 = getelementptr inbounds nuw i32, ptr %57, i32 3
  %337 = load i32, ptr %336, align 4
  %338 = icmp eq i32 %29, %335
  %339 = icmp eq i32 %29, %337
  br i1 %338, label %340, label %347

340:                                              ; preds = %315
  %341 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %334, 1
  %342 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %334, 2
  %343 = getelementptr double, ptr %341, i64 %342
  %344 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %334, 3, 0
  %345 = trunc i64 %344 to i32
  %346 = call i32 @MPI_Recv(ptr %343, i32 %345, i32 1275070475, i32 %337, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %356

347:                                              ; preds = %315
  br i1 %339, label %348, label %355

348:                                              ; preds = %347
  %349 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %334, 1
  %350 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %334, 2
  %351 = getelementptr double, ptr %349, i64 %350
  %352 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %334, 3, 0
  %353 = trunc i64 %352 to i32
  %354 = call i32 @MPI_Send(ptr %351, i32 %353, i32 1275070475, i32 %335, i32 0, i32 1140850688)
  br label %355

355:                                              ; preds = %348, %347
  br label %356

356:                                              ; preds = %340, %355
  %357 = icmp eq i32 %64, 0
  br i1 %357, label %358, label %359

358:                                              ; preds = %356
  %omp_global_thread_num134 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %66, ptr %.reloaded174, align 4
  store double %2, ptr %.reloaded175, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %163, ptr %.reloaded176, align 8
  br label %omp_parallel317

omp_parallel317:                                  ; preds = %358
  %gep_.reloaded174 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg316, i32 0, i32 0
  store ptr %.reloaded174, ptr %gep_.reloaded174, align 8
  %gep_.reloaded175 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg316, i32 0, i32 1
  store ptr %.reloaded175, ptr %gep_.reloaded175, align 8
  %gep_.reloaded176 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg316, i32 0, i32 2
  store ptr %.reloaded176, ptr %gep_.reloaded176, align 8
  %gep_ = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg316, i32 0, i32 3
  store ptr %12, ptr %gep_, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par.4, ptr %structArg316)
  br label %omp.par.exit140

omp.par.exit140:                                  ; preds = %omp_parallel317
  br label %359

359:                                              ; preds = %omp.par.exit140, %356
  %360 = icmp eq i32 %64, 1
  br i1 %360, label %361, label %362

361:                                              ; preds = %359
  %omp_global_thread_num178 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %66, ptr %.reloaded218, align 4
  store double %2, ptr %.reloaded219, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %182, ptr %.reloaded220, align 8
  br label %omp_parallel320

omp_parallel320:                                  ; preds = %361
  %gep_.reloaded218 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg318, i32 0, i32 0
  store ptr %.reloaded218, ptr %gep_.reloaded218, align 8
  %gep_.reloaded219 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg318, i32 0, i32 1
  store ptr %.reloaded219, ptr %gep_.reloaded219, align 8
  %gep_.reloaded220 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg318, i32 0, i32 2
  store ptr %.reloaded220, ptr %gep_.reloaded220, align 8
  %gep_319 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg318, i32 0, i32 3
  store ptr %12, ptr %gep_319, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par.5, ptr %structArg318)
  br label %omp.par.exit184

omp.par.exit184:                                  ; preds = %omp_parallel320
  br label %362

362:                                              ; preds = %omp.par.exit184, %359
  %363 = icmp eq i32 %64, 2
  br i1 %363, label %364, label %365

364:                                              ; preds = %362
  %omp_global_thread_num222 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %66, ptr %.reloaded262, align 4
  store double %2, ptr %.reloaded263, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %201, ptr %.reloaded264, align 8
  br label %omp_parallel323

omp_parallel323:                                  ; preds = %364
  %gep_.reloaded262 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg321, i32 0, i32 0
  store ptr %.reloaded262, ptr %gep_.reloaded262, align 8
  %gep_.reloaded263 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg321, i32 0, i32 1
  store ptr %.reloaded263, ptr %gep_.reloaded263, align 8
  %gep_.reloaded264 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg321, i32 0, i32 2
  store ptr %.reloaded264, ptr %gep_.reloaded264, align 8
  %gep_322 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg321, i32 0, i32 3
  store ptr %12, ptr %gep_322, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par.6, ptr %structArg321)
  br label %omp.par.exit228

omp.par.exit228:                                  ; preds = %omp_parallel323
  br label %365

365:                                              ; preds = %omp.par.exit228, %362
  %366 = icmp eq i32 %64, 3
  br i1 %366, label %367, label %368

367:                                              ; preds = %365
  %omp_global_thread_num266 = call i32 @__kmpc_global_thread_num(ptr @1)
  store i64 %66, ptr %.reloaded306, align 4
  store double %2, ptr %.reloaded307, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %220, ptr %.reloaded308, align 8
  br label %omp_parallel326

omp_parallel326:                                  ; preds = %367
  %gep_.reloaded306 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 0
  store ptr %.reloaded306, ptr %gep_.reloaded306, align 8
  %gep_.reloaded307 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 1
  store ptr %.reloaded307, ptr %gep_.reloaded307, align 8
  %gep_.reloaded308 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 2
  store ptr %.reloaded308, ptr %gep_.reloaded308, align 8
  %gep_325 = getelementptr { ptr, ptr, ptr, ptr }, ptr %structArg324, i32 0, i32 3
  store ptr %12, ptr %gep_325, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_syrk..omp_par.7, ptr %structArg324)
  br label %omp.par.exit272

omp.par.exit272:                                  ; preds = %omp_parallel326
  br label %368

368:                                              ; preds = %omp.par.exit272, %365
  %369 = call i32 @MPI_Barrier(i32 1140850688)
  %370 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %371 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %372 = insertvalue { ptr, ptr, i64 } poison, ptr %370, 0
  %373 = insertvalue { ptr, ptr, i64 } %372, ptr %371, 1
  %374 = insertvalue { ptr, ptr, i64 } %373, i64 0, 2
  %375 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %376 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %377 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %378 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %379 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %380 = extractvalue { ptr, ptr, i64 } %374, 0
  %381 = extractvalue { ptr, ptr, i64 } %374, 1
  %382 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %380, 0
  %383 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %382, ptr %381, 1
  %384 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %383, i64 1300000, 2
  %385 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %384, i64 500, 3, 0
  %386 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %385, i64 2600, 4, 0
  %387 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %386, i64 2600, 3, 1
  %388 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %387, i64 1, 4, 1
  %389 = load i32, ptr %57, align 4
  %390 = getelementptr inbounds nuw i32, ptr %57, i32 1
  %391 = load i32, ptr %390, align 4
  %392 = icmp eq i32 %29, %389
  %393 = icmp eq i32 %29, %391
  br i1 %392, label %394, label %401

394:                                              ; preds = %368
  %395 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %388, 1
  %396 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %388, 2
  %397 = getelementptr double, ptr %395, i64 %396
  %398 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %388, 3, 0
  %399 = trunc i64 %398 to i32
  %400 = call i32 @MPI_Recv(ptr %397, i32 %399, i32 1275070475, i32 %391, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %410

401:                                              ; preds = %368
  br i1 %393, label %402, label %409

402:                                              ; preds = %401
  %403 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %388, 1
  %404 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %388, 2
  %405 = getelementptr double, ptr %403, i64 %404
  %406 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %388, 3, 0
  %407 = trunc i64 %406 to i32
  %408 = call i32 @MPI_Send(ptr %405, i32 %407, i32 1275070475, i32 %389, i32 0, i32 1140850688)
  br label %409

409:                                              ; preds = %402, %401
  br label %410

410:                                              ; preds = %394, %409
  %411 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %412 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %413 = insertvalue { ptr, ptr, i64 } poison, ptr %411, 0
  %414 = insertvalue { ptr, ptr, i64 } %413, ptr %412, 1
  %415 = insertvalue { ptr, ptr, i64 } %414, i64 0, 2
  %416 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %417 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %418 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %419 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %420 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %421 = extractvalue { ptr, ptr, i64 } %415, 0
  %422 = extractvalue { ptr, ptr, i64 } %415, 1
  %423 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %421, 0
  %424 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %423, ptr %422, 1
  %425 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %424, i64 2600000, 2
  %426 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %425, i64 500, 3, 0
  %427 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %426, i64 2600, 4, 0
  %428 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %427, i64 2600, 3, 1
  %429 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %428, i64 1, 4, 1
  %430 = load i32, ptr %57, align 4
  %431 = getelementptr inbounds nuw i32, ptr %57, i32 2
  %432 = load i32, ptr %431, align 4
  %433 = icmp eq i32 %29, %430
  %434 = icmp eq i32 %29, %432
  br i1 %433, label %435, label %442

435:                                              ; preds = %410
  %436 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %429, 1
  %437 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %429, 2
  %438 = getelementptr double, ptr %436, i64 %437
  %439 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %429, 3, 0
  %440 = trunc i64 %439 to i32
  %441 = call i32 @MPI_Recv(ptr %438, i32 %440, i32 1275070475, i32 %432, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %451

442:                                              ; preds = %410
  br i1 %434, label %443, label %450

443:                                              ; preds = %442
  %444 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %429, 1
  %445 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %429, 2
  %446 = getelementptr double, ptr %444, i64 %445
  %447 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %429, 3, 0
  %448 = trunc i64 %447 to i32
  %449 = call i32 @MPI_Send(ptr %446, i32 %448, i32 1275070475, i32 %430, i32 0, i32 1140850688)
  br label %450

450:                                              ; preds = %443, %442
  br label %451

451:                                              ; preds = %435, %450
  %452 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %453 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %454 = insertvalue { ptr, ptr, i64 } poison, ptr %452, 0
  %455 = insertvalue { ptr, ptr, i64 } %454, ptr %453, 1
  %456 = insertvalue { ptr, ptr, i64 } %455, i64 0, 2
  %457 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %458 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %459 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %460 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %461 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %462 = extractvalue { ptr, ptr, i64 } %456, 0
  %463 = extractvalue { ptr, ptr, i64 } %456, 1
  %464 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %462, 0
  %465 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %464, ptr %463, 1
  %466 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %465, i64 3900000, 2
  %467 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %466, i64 500, 3, 0
  %468 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %467, i64 2600, 4, 0
  %469 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %468, i64 2600, 3, 1
  %470 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %469, i64 1, 4, 1
  %471 = load i32, ptr %57, align 4
  %472 = getelementptr inbounds nuw i32, ptr %57, i32 3
  %473 = load i32, ptr %472, align 4
  %474 = icmp eq i32 %29, %471
  %475 = icmp eq i32 %29, %473
  br i1 %474, label %476, label %483

476:                                              ; preds = %451
  %477 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %470, 1
  %478 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %470, 2
  %479 = getelementptr double, ptr %477, i64 %478
  %480 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %470, 3, 0
  %481 = trunc i64 %480 to i32
  %482 = call i32 @MPI_Recv(ptr %479, i32 %481, i32 1275070475, i32 %473, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %492

483:                                              ; preds = %451
  br i1 %475, label %484, label %491

484:                                              ; preds = %483
  %485 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %470, 1
  %486 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %470, 2
  %487 = getelementptr double, ptr %485, i64 %486
  %488 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %470, 3, 0
  %489 = trunc i64 %488 to i32
  %490 = call i32 @MPI_Send(ptr %487, i32 %489, i32 1275070475, i32 %471, i32 0, i32 1140850688)
  br label %491

491:                                              ; preds = %484, %483
  br label %492

492:                                              ; preds = %476, %491
  %493 = load i32, ptr %57, align 4
  %494 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 0
  %495 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 1
  %496 = insertvalue { ptr, ptr, i64 } poison, ptr %494, 0
  %497 = insertvalue { ptr, ptr, i64 } %496, ptr %495, 1
  %498 = insertvalue { ptr, ptr, i64 } %497, i64 0, 2
  %499 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 2
  %500 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 0
  %501 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 3, 1
  %502 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 0
  %503 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, 4, 1
  %504 = extractvalue { ptr, ptr, i64 } %498, 0
  %505 = extractvalue { ptr, ptr, i64 } %498, 1
  %506 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %504, 0
  %507 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %506, ptr %505, 1
  %508 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %507, i64 0, 2
  %509 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %508, i64 2000, 3, 0
  %510 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %509, i64 2600, 4, 0
  %511 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %510, i64 2600, 3, 1
  %512 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %511, i64 1, 4, 1
  %513 = icmp eq i32 %29, %493
  br i1 %513, label %514, label %532

514:                                              ; preds = %492
  %515 = sext i32 %32 to i64
  br label %516

516:                                              ; preds = %529, %514
  %517 = phi i64 [ %530, %529 ], [ 0, %514 ]
  %518 = icmp slt i64 %517, %515
  br i1 %518, label %519, label %531

519:                                              ; preds = %516
  %520 = trunc i64 %517 to i32
  %521 = icmp ne i32 %520, %493
  br i1 %521, label %522, label %529

522:                                              ; preds = %519
  %523 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %512, 1
  %524 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %512, 2
  %525 = getelementptr double, ptr %523, i64 %524
  %526 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %512, 3, 0
  %527 = trunc i64 %526 to i32
  %528 = call i32 @MPI_Send(ptr %525, i32 %527, i32 1275070475, i32 %520, i32 0, i32 1140850688)
  br label %529

529:                                              ; preds = %522, %519
  %530 = add i64 %517, 1
  br label %516

531:                                              ; preds = %516
  br label %539

532:                                              ; preds = %492
  %533 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %512, 1
  %534 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %512, 2
  %535 = getelementptr double, ptr %533, i64 %534
  %536 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %512, 3, 0
  %537 = trunc i64 %536 to i32
  %538 = call i32 @MPI_Recv(ptr %535, i32 %537, i32 1275070475, i32 %493, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %539

539:                                              ; preds = %531, %532
  %540 = add i64 %66, 1
  br label %65

541:                                              ; preds = %65
  %542 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par.7(ptr noalias %tid.addr267, ptr noalias %zero.addr268, ptr %0) #0 {
omp.par.entry269:
  %gep_.reloaded306 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded306 = load ptr, ptr %gep_.reloaded306, align 8, !align !1
  %gep_.reloaded307 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded307 = load ptr, ptr %gep_.reloaded307, align 8, !align !1
  %gep_.reloaded308 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded308 = load ptr, ptr %gep_.reloaded308, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter300 = alloca i32, align 4
  %p.lowerbound301 = alloca i64, align 8
  %p.upperbound302 = alloca i64, align 8
  %p.stride303 = alloca i64, align 8
  %tid.addr.local273 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr267, align 4
  store i32 %1, ptr %tid.addr.local273, align 4
  %tid274 = load i32, ptr %tid.addr.local273, align 4
  %2 = load i64, ptr %loadgep_.reloaded306, align 4
  %3 = load double, ptr %loadgep_.reloaded307, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded308, align 8
  br label %omp.region.after_alloca280

omp.region.after_alloca280:                       ; preds = %omp.par.entry269
  br label %omp.region.after_alloca277

omp.region.after_alloca277:                       ; preds = %omp.region.after_alloca280
  br label %omp.par.region270

omp.par.region270:                                ; preds = %omp.region.after_alloca277
  br label %omp.par.region279

omp.par.region279:                                ; preds = %omp.par.region270
  br label %omp.wsloop.region282

omp.wsloop.region282:                             ; preds = %omp.par.region279
  br label %omp_loop.preheader283

omp_loop.preheader283:                            ; preds = %omp.wsloop.region282
  store i64 0, ptr %p.lowerbound301, align 4
  store i64 499, ptr %p.upperbound302, align 4
  store i64 1, ptr %p.stride303, align 4
  %omp_global_thread_num304 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num304, i32 34, ptr %p.lastiter300, ptr %p.lowerbound301, ptr %p.upperbound302, ptr %p.stride303, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound301, align 4
  %6 = load i64, ptr %p.upperbound302, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header284

omp_loop.header284:                               ; preds = %omp_loop.inc287, %omp_loop.preheader283
  %omp_loop.iv290 = phi i64 [ 0, %omp_loop.preheader283 ], [ %omp_loop.next292, %omp_loop.inc287 ]
  br label %omp_loop.cond285

omp_loop.cond285:                                 ; preds = %omp_loop.header284
  %omp_loop.cmp291 = icmp ult i64 %omp_loop.iv290, %8
  br i1 %omp_loop.cmp291, label %omp_loop.body286, label %omp_loop.exit288

omp_loop.exit288:                                 ; preds = %omp_loop.cond285
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num304)
  %omp_global_thread_num305 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num305)
  br label %omp_loop.after289

omp_loop.after289:                                ; preds = %omp_loop.exit288
  br label %omp.region.cont281

omp.region.cont281:                               ; preds = %omp_loop.after289
  br label %omp.region.cont278

omp.region.cont278:                               ; preds = %omp.region.cont281
  br label %omp.par.pre_finalize271

omp.par.pre_finalize271:                          ; preds = %omp.region.cont278
  br label %.fini309

.fini309:                                         ; preds = %omp.par.pre_finalize271
  br label %omp.par.exit272.exitStub

omp_loop.body286:                                 ; preds = %omp_loop.cond285
  %9 = add i64 %omp_loop.iv290, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region294

omp.loop_nest.region294:                          ; preds = %omp_loop.body286
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region295

omp.loop_nest.region295:                          ; preds = %omp.loop_nest.region294
  br label %omp.loop_nest.region296

omp.loop_nest.region296:                          ; preds = %omp.loop_nest.region297, %omp.loop_nest.region295
  %13 = phi i64 [ %37, %omp.loop_nest.region297 ], [ 0, %omp.loop_nest.region295 ]
  %14 = icmp slt i64 %13, 2600
  br i1 %14, label %omp.loop_nest.region297, label %omp.loop_nest.region298

omp.loop_nest.region298:                          ; preds = %omp.loop_nest.region296
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region299

omp.loop_nest.region299:                          ; preds = %omp.loop_nest.region298
  br label %omp.region.cont293

omp.region.cont293:                               ; preds = %omp.loop_nest.region299
  br label %omp_loop.inc287

omp_loop.inc287:                                  ; preds = %omp.region.cont293
  %omp_loop.next292 = add nuw i64 %omp_loop.iv290, 1
  br label %omp_loop.header284

omp.loop_nest.region297:                          ; preds = %omp.loop_nest.region296
  %15 = mul nuw nsw i64 %2, 2000
  %16 = add nuw nsw i64 %15, %11
  %17 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %16
  %18 = load double, ptr %17, align 8
  %19 = fmul double %3, %18
  %20 = mul nuw nsw i64 %13, 2000
  %21 = add nuw nsw i64 %20, %11
  %22 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %21
  %23 = load double, ptr %22, align 8
  %24 = fmul double %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = getelementptr double, ptr %25, i32 3900000
  %27 = mul nuw nsw i64 %2, 2600
  %28 = add nuw nsw i64 %27, %13
  %29 = getelementptr inbounds nuw double, ptr %26, i64 %28
  %30 = load double, ptr %29, align 8
  %31 = fadd double %30, %24
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %33 = getelementptr double, ptr %32, i32 3900000
  %34 = mul nuw nsw i64 %2, 2600
  %35 = add nuw nsw i64 %34, %13
  %36 = getelementptr inbounds nuw double, ptr %33, i64 %35
  store double %31, ptr %36, align 8
  %37 = add i64 %13, 1
  br label %omp.loop_nest.region296

omp.par.exit272.exitStub:                         ; preds = %.fini309
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par.6(ptr noalias %tid.addr223, ptr noalias %zero.addr224, ptr %0) #0 {
omp.par.entry225:
  %gep_.reloaded262 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded262 = load ptr, ptr %gep_.reloaded262, align 8, !align !1
  %gep_.reloaded263 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded263 = load ptr, ptr %gep_.reloaded263, align 8, !align !1
  %gep_.reloaded264 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded264 = load ptr, ptr %gep_.reloaded264, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter256 = alloca i32, align 4
  %p.lowerbound257 = alloca i64, align 8
  %p.upperbound258 = alloca i64, align 8
  %p.stride259 = alloca i64, align 8
  %tid.addr.local229 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr223, align 4
  store i32 %1, ptr %tid.addr.local229, align 4
  %tid230 = load i32, ptr %tid.addr.local229, align 4
  %2 = load i64, ptr %loadgep_.reloaded262, align 4
  %3 = load double, ptr %loadgep_.reloaded263, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded264, align 8
  br label %omp.region.after_alloca236

omp.region.after_alloca236:                       ; preds = %omp.par.entry225
  br label %omp.region.after_alloca233

omp.region.after_alloca233:                       ; preds = %omp.region.after_alloca236
  br label %omp.par.region226

omp.par.region226:                                ; preds = %omp.region.after_alloca233
  br label %omp.par.region235

omp.par.region235:                                ; preds = %omp.par.region226
  br label %omp.wsloop.region238

omp.wsloop.region238:                             ; preds = %omp.par.region235
  br label %omp_loop.preheader239

omp_loop.preheader239:                            ; preds = %omp.wsloop.region238
  store i64 0, ptr %p.lowerbound257, align 4
  store i64 499, ptr %p.upperbound258, align 4
  store i64 1, ptr %p.stride259, align 4
  %omp_global_thread_num260 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num260, i32 34, ptr %p.lastiter256, ptr %p.lowerbound257, ptr %p.upperbound258, ptr %p.stride259, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound257, align 4
  %6 = load i64, ptr %p.upperbound258, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header240

omp_loop.header240:                               ; preds = %omp_loop.inc243, %omp_loop.preheader239
  %omp_loop.iv246 = phi i64 [ 0, %omp_loop.preheader239 ], [ %omp_loop.next248, %omp_loop.inc243 ]
  br label %omp_loop.cond241

omp_loop.cond241:                                 ; preds = %omp_loop.header240
  %omp_loop.cmp247 = icmp ult i64 %omp_loop.iv246, %8
  br i1 %omp_loop.cmp247, label %omp_loop.body242, label %omp_loop.exit244

omp_loop.exit244:                                 ; preds = %omp_loop.cond241
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num260)
  %omp_global_thread_num261 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num261)
  br label %omp_loop.after245

omp_loop.after245:                                ; preds = %omp_loop.exit244
  br label %omp.region.cont237

omp.region.cont237:                               ; preds = %omp_loop.after245
  br label %omp.region.cont234

omp.region.cont234:                               ; preds = %omp.region.cont237
  br label %omp.par.pre_finalize227

omp.par.pre_finalize227:                          ; preds = %omp.region.cont234
  br label %.fini265

.fini265:                                         ; preds = %omp.par.pre_finalize227
  br label %omp.par.exit228.exitStub

omp_loop.body242:                                 ; preds = %omp_loop.cond241
  %9 = add i64 %omp_loop.iv246, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region250

omp.loop_nest.region250:                          ; preds = %omp_loop.body242
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region251

omp.loop_nest.region251:                          ; preds = %omp.loop_nest.region250
  br label %omp.loop_nest.region252

omp.loop_nest.region252:                          ; preds = %omp.loop_nest.region253, %omp.loop_nest.region251
  %13 = phi i64 [ %37, %omp.loop_nest.region253 ], [ 0, %omp.loop_nest.region251 ]
  %14 = icmp slt i64 %13, 2600
  br i1 %14, label %omp.loop_nest.region253, label %omp.loop_nest.region254

omp.loop_nest.region254:                          ; preds = %omp.loop_nest.region252
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region255

omp.loop_nest.region255:                          ; preds = %omp.loop_nest.region254
  br label %omp.region.cont249

omp.region.cont249:                               ; preds = %omp.loop_nest.region255
  br label %omp_loop.inc243

omp_loop.inc243:                                  ; preds = %omp.region.cont249
  %omp_loop.next248 = add nuw i64 %omp_loop.iv246, 1
  br label %omp_loop.header240

omp.loop_nest.region253:                          ; preds = %omp.loop_nest.region252
  %15 = mul nuw nsw i64 %2, 2000
  %16 = add nuw nsw i64 %15, %11
  %17 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %16
  %18 = load double, ptr %17, align 8
  %19 = fmul double %3, %18
  %20 = mul nuw nsw i64 %13, 2000
  %21 = add nuw nsw i64 %20, %11
  %22 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %21
  %23 = load double, ptr %22, align 8
  %24 = fmul double %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = getelementptr double, ptr %25, i32 2600000
  %27 = mul nuw nsw i64 %2, 2600
  %28 = add nuw nsw i64 %27, %13
  %29 = getelementptr inbounds nuw double, ptr %26, i64 %28
  %30 = load double, ptr %29, align 8
  %31 = fadd double %30, %24
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %33 = getelementptr double, ptr %32, i32 2600000
  %34 = mul nuw nsw i64 %2, 2600
  %35 = add nuw nsw i64 %34, %13
  %36 = getelementptr inbounds nuw double, ptr %33, i64 %35
  store double %31, ptr %36, align 8
  %37 = add i64 %13, 1
  br label %omp.loop_nest.region252

omp.par.exit228.exitStub:                         ; preds = %.fini265
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par.5(ptr noalias %tid.addr179, ptr noalias %zero.addr180, ptr %0) #0 {
omp.par.entry181:
  %gep_.reloaded218 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded218 = load ptr, ptr %gep_.reloaded218, align 8, !align !1
  %gep_.reloaded219 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded219 = load ptr, ptr %gep_.reloaded219, align 8, !align !1
  %gep_.reloaded220 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded220 = load ptr, ptr %gep_.reloaded220, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter212 = alloca i32, align 4
  %p.lowerbound213 = alloca i64, align 8
  %p.upperbound214 = alloca i64, align 8
  %p.stride215 = alloca i64, align 8
  %tid.addr.local185 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr179, align 4
  store i32 %1, ptr %tid.addr.local185, align 4
  %tid186 = load i32, ptr %tid.addr.local185, align 4
  %2 = load i64, ptr %loadgep_.reloaded218, align 4
  %3 = load double, ptr %loadgep_.reloaded219, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded220, align 8
  br label %omp.region.after_alloca192

omp.region.after_alloca192:                       ; preds = %omp.par.entry181
  br label %omp.region.after_alloca189

omp.region.after_alloca189:                       ; preds = %omp.region.after_alloca192
  br label %omp.par.region182

omp.par.region182:                                ; preds = %omp.region.after_alloca189
  br label %omp.par.region191

omp.par.region191:                                ; preds = %omp.par.region182
  br label %omp.wsloop.region194

omp.wsloop.region194:                             ; preds = %omp.par.region191
  br label %omp_loop.preheader195

omp_loop.preheader195:                            ; preds = %omp.wsloop.region194
  store i64 0, ptr %p.lowerbound213, align 4
  store i64 499, ptr %p.upperbound214, align 4
  store i64 1, ptr %p.stride215, align 4
  %omp_global_thread_num216 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num216, i32 34, ptr %p.lastiter212, ptr %p.lowerbound213, ptr %p.upperbound214, ptr %p.stride215, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound213, align 4
  %6 = load i64, ptr %p.upperbound214, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header196

omp_loop.header196:                               ; preds = %omp_loop.inc199, %omp_loop.preheader195
  %omp_loop.iv202 = phi i64 [ 0, %omp_loop.preheader195 ], [ %omp_loop.next204, %omp_loop.inc199 ]
  br label %omp_loop.cond197

omp_loop.cond197:                                 ; preds = %omp_loop.header196
  %omp_loop.cmp203 = icmp ult i64 %omp_loop.iv202, %8
  br i1 %omp_loop.cmp203, label %omp_loop.body198, label %omp_loop.exit200

omp_loop.exit200:                                 ; preds = %omp_loop.cond197
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num216)
  %omp_global_thread_num217 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num217)
  br label %omp_loop.after201

omp_loop.after201:                                ; preds = %omp_loop.exit200
  br label %omp.region.cont193

omp.region.cont193:                               ; preds = %omp_loop.after201
  br label %omp.region.cont190

omp.region.cont190:                               ; preds = %omp.region.cont193
  br label %omp.par.pre_finalize183

omp.par.pre_finalize183:                          ; preds = %omp.region.cont190
  br label %.fini221

.fini221:                                         ; preds = %omp.par.pre_finalize183
  br label %omp.par.exit184.exitStub

omp_loop.body198:                                 ; preds = %omp_loop.cond197
  %9 = add i64 %omp_loop.iv202, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region206

omp.loop_nest.region206:                          ; preds = %omp_loop.body198
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region207

omp.loop_nest.region207:                          ; preds = %omp.loop_nest.region206
  br label %omp.loop_nest.region208

omp.loop_nest.region208:                          ; preds = %omp.loop_nest.region209, %omp.loop_nest.region207
  %13 = phi i64 [ %37, %omp.loop_nest.region209 ], [ 0, %omp.loop_nest.region207 ]
  %14 = icmp slt i64 %13, 2600
  br i1 %14, label %omp.loop_nest.region209, label %omp.loop_nest.region210

omp.loop_nest.region210:                          ; preds = %omp.loop_nest.region208
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region211

omp.loop_nest.region211:                          ; preds = %omp.loop_nest.region210
  br label %omp.region.cont205

omp.region.cont205:                               ; preds = %omp.loop_nest.region211
  br label %omp_loop.inc199

omp_loop.inc199:                                  ; preds = %omp.region.cont205
  %omp_loop.next204 = add nuw i64 %omp_loop.iv202, 1
  br label %omp_loop.header196

omp.loop_nest.region209:                          ; preds = %omp.loop_nest.region208
  %15 = mul nuw nsw i64 %2, 2000
  %16 = add nuw nsw i64 %15, %11
  %17 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %16
  %18 = load double, ptr %17, align 8
  %19 = fmul double %3, %18
  %20 = mul nuw nsw i64 %13, 2000
  %21 = add nuw nsw i64 %20, %11
  %22 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %21
  %23 = load double, ptr %22, align 8
  %24 = fmul double %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = getelementptr double, ptr %25, i32 1300000
  %27 = mul nuw nsw i64 %2, 2600
  %28 = add nuw nsw i64 %27, %13
  %29 = getelementptr inbounds nuw double, ptr %26, i64 %28
  %30 = load double, ptr %29, align 8
  %31 = fadd double %30, %24
  %32 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %33 = getelementptr double, ptr %32, i32 1300000
  %34 = mul nuw nsw i64 %2, 2600
  %35 = add nuw nsw i64 %34, %13
  %36 = getelementptr inbounds nuw double, ptr %33, i64 %35
  store double %31, ptr %36, align 8
  %37 = add i64 %13, 1
  br label %omp.loop_nest.region208

omp.par.exit184.exitStub:                         ; preds = %.fini221
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par.4(ptr noalias %tid.addr135, ptr noalias %zero.addr136, ptr %0) #0 {
omp.par.entry137:
  %gep_.reloaded174 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded174 = load ptr, ptr %gep_.reloaded174, align 8, !align !1
  %gep_.reloaded175 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded175 = load ptr, ptr %gep_.reloaded175, align 8, !align !1
  %gep_.reloaded176 = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded176 = load ptr, ptr %gep_.reloaded176, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter168 = alloca i32, align 4
  %p.lowerbound169 = alloca i64, align 8
  %p.upperbound170 = alloca i64, align 8
  %p.stride171 = alloca i64, align 8
  %tid.addr.local141 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr135, align 4
  store i32 %1, ptr %tid.addr.local141, align 4
  %tid142 = load i32, ptr %tid.addr.local141, align 4
  %2 = load i64, ptr %loadgep_.reloaded174, align 4
  %3 = load double, ptr %loadgep_.reloaded175, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded176, align 8
  br label %omp.region.after_alloca148

omp.region.after_alloca148:                       ; preds = %omp.par.entry137
  br label %omp.region.after_alloca145

omp.region.after_alloca145:                       ; preds = %omp.region.after_alloca148
  br label %omp.par.region138

omp.par.region138:                                ; preds = %omp.region.after_alloca145
  br label %omp.par.region147

omp.par.region147:                                ; preds = %omp.par.region138
  br label %omp.wsloop.region150

omp.wsloop.region150:                             ; preds = %omp.par.region147
  br label %omp_loop.preheader151

omp_loop.preheader151:                            ; preds = %omp.wsloop.region150
  store i64 0, ptr %p.lowerbound169, align 4
  store i64 499, ptr %p.upperbound170, align 4
  store i64 1, ptr %p.stride171, align 4
  %omp_global_thread_num172 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num172, i32 34, ptr %p.lastiter168, ptr %p.lowerbound169, ptr %p.upperbound170, ptr %p.stride171, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound169, align 4
  %6 = load i64, ptr %p.upperbound170, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header152

omp_loop.header152:                               ; preds = %omp_loop.inc155, %omp_loop.preheader151
  %omp_loop.iv158 = phi i64 [ 0, %omp_loop.preheader151 ], [ %omp_loop.next160, %omp_loop.inc155 ]
  br label %omp_loop.cond153

omp_loop.cond153:                                 ; preds = %omp_loop.header152
  %omp_loop.cmp159 = icmp ult i64 %omp_loop.iv158, %8
  br i1 %omp_loop.cmp159, label %omp_loop.body154, label %omp_loop.exit156

omp_loop.exit156:                                 ; preds = %omp_loop.cond153
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num172)
  %omp_global_thread_num173 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num173)
  br label %omp_loop.after157

omp_loop.after157:                                ; preds = %omp_loop.exit156
  br label %omp.region.cont149

omp.region.cont149:                               ; preds = %omp_loop.after157
  br label %omp.region.cont146

omp.region.cont146:                               ; preds = %omp.region.cont149
  br label %omp.par.pre_finalize139

omp.par.pre_finalize139:                          ; preds = %omp.region.cont146
  br label %.fini177

.fini177:                                         ; preds = %omp.par.pre_finalize139
  br label %omp.par.exit140.exitStub

omp_loop.body154:                                 ; preds = %omp_loop.cond153
  %9 = add i64 %omp_loop.iv158, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region162

omp.loop_nest.region162:                          ; preds = %omp_loop.body154
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region163

omp.loop_nest.region163:                          ; preds = %omp.loop_nest.region162
  br label %omp.loop_nest.region164

omp.loop_nest.region164:                          ; preds = %omp.loop_nest.region165, %omp.loop_nest.region163
  %13 = phi i64 [ %35, %omp.loop_nest.region165 ], [ 0, %omp.loop_nest.region163 ]
  %14 = icmp slt i64 %13, 2600
  br i1 %14, label %omp.loop_nest.region165, label %omp.loop_nest.region166

omp.loop_nest.region166:                          ; preds = %omp.loop_nest.region164
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region167

omp.loop_nest.region167:                          ; preds = %omp.loop_nest.region166
  br label %omp.region.cont161

omp.region.cont161:                               ; preds = %omp.loop_nest.region167
  br label %omp_loop.inc155

omp_loop.inc155:                                  ; preds = %omp.region.cont161
  %omp_loop.next160 = add nuw i64 %omp_loop.iv158, 1
  br label %omp_loop.header152

omp.loop_nest.region165:                          ; preds = %omp.loop_nest.region164
  %15 = mul nuw nsw i64 %2, 2000
  %16 = add nuw nsw i64 %15, %11
  %17 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %16
  %18 = load double, ptr %17, align 8
  %19 = fmul double %3, %18
  %20 = mul nuw nsw i64 %13, 2000
  %21 = add nuw nsw i64 %20, %11
  %22 = getelementptr inbounds nuw double, ptr %loadgep_, i64 %21
  %23 = load double, ptr %22, align 8
  %24 = fmul double %19, %23
  %25 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %26 = mul nuw nsw i64 %2, 2600
  %27 = add nuw nsw i64 %26, %13
  %28 = getelementptr inbounds nuw double, ptr %25, i64 %27
  %29 = load double, ptr %28, align 8
  %30 = fadd double %29, %24
  %31 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %32 = mul nuw nsw i64 %2, 2600
  %33 = add nuw nsw i64 %32, %13
  %34 = getelementptr inbounds nuw double, ptr %31, i64 %33
  store double %30, ptr %34, align 8
  %35 = add i64 %13, 1
  br label %omp.loop_nest.region164

omp.par.exit140.exitStub:                         ; preds = %.fini177
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par.3(ptr noalias %tid.addr94, ptr noalias %zero.addr95, ptr %0) #0 {
omp.par.entry96:
  %gep_.reloaded130 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded130 = load ptr, ptr %gep_.reloaded130, align 8, !align !1
  %gep_.reloaded131 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded131 = load ptr, ptr %gep_.reloaded131, align 8, !align !1
  %gep_.reloaded132 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded132 = load ptr, ptr %gep_.reloaded132, align 8, !align !1
  %p.lastiter124 = alloca i32, align 4
  %p.lowerbound125 = alloca i64, align 8
  %p.upperbound126 = alloca i64, align 8
  %p.stride127 = alloca i64, align 8
  %tid.addr.local100 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr94, align 4
  store i32 %1, ptr %tid.addr.local100, align 4
  %tid101 = load i32, ptr %tid.addr.local100, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded130, align 8
  %3 = load i64, ptr %loadgep_.reloaded131, align 4
  %4 = load double, ptr %loadgep_.reloaded132, align 8
  br label %omp.region.after_alloca107

omp.region.after_alloca107:                       ; preds = %omp.par.entry96
  br label %omp.region.after_alloca104

omp.region.after_alloca104:                       ; preds = %omp.region.after_alloca107
  br label %omp.par.region97

omp.par.region97:                                 ; preds = %omp.region.after_alloca104
  br label %omp.par.region106

omp.par.region106:                                ; preds = %omp.par.region97
  br label %omp.wsloop.region109

omp.wsloop.region109:                             ; preds = %omp.par.region106
  br label %omp_loop.preheader110

omp_loop.preheader110:                            ; preds = %omp.wsloop.region109
  store i64 0, ptr %p.lowerbound125, align 4
  store i64 649, ptr %p.upperbound126, align 4
  store i64 1, ptr %p.stride127, align 4
  %omp_global_thread_num128 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num128, i32 34, ptr %p.lastiter124, ptr %p.lowerbound125, ptr %p.upperbound126, ptr %p.stride127, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound125, align 4
  %6 = load i64, ptr %p.upperbound126, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header111

omp_loop.header111:                               ; preds = %omp_loop.inc114, %omp_loop.preheader110
  %omp_loop.iv117 = phi i64 [ 0, %omp_loop.preheader110 ], [ %omp_loop.next119, %omp_loop.inc114 ]
  br label %omp_loop.cond112

omp_loop.cond112:                                 ; preds = %omp_loop.header111
  %omp_loop.cmp118 = icmp ult i64 %omp_loop.iv117, %8
  br i1 %omp_loop.cmp118, label %omp_loop.body113, label %omp_loop.exit115

omp_loop.exit115:                                 ; preds = %omp_loop.cond112
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num128)
  %omp_global_thread_num129 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num129)
  br label %omp_loop.after116

omp_loop.after116:                                ; preds = %omp_loop.exit115
  br label %omp.region.cont108

omp.region.cont108:                               ; preds = %omp_loop.after116
  br label %omp.region.cont105

omp.region.cont105:                               ; preds = %omp.region.cont108
  br label %omp.par.pre_finalize98

omp.par.pre_finalize98:                           ; preds = %omp.region.cont105
  br label %.fini133

.fini133:                                         ; preds = %omp.par.pre_finalize98
  br label %omp.par.exit99.exitStub

omp_loop.body113:                                 ; preds = %omp_loop.cond112
  %9 = add i64 %omp_loop.iv117, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region121

omp.loop_nest.region121:                          ; preds = %omp_loop.body113
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region122

omp.loop_nest.region122:                          ; preds = %omp.loop_nest.region121
  %13 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %14 = getelementptr double, ptr %13, i32 5070000
  %15 = mul nuw nsw i64 %3, 2600
  %16 = add nuw nsw i64 %15, %11
  %17 = getelementptr inbounds nuw double, ptr %14, i64 %16
  %18 = load double, ptr %17, align 8
  %19 = fmul double %18, %4
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %21 = getelementptr double, ptr %20, i32 5070000
  %22 = mul nuw nsw i64 %3, 2600
  %23 = add nuw nsw i64 %22, %11
  %24 = getelementptr inbounds nuw double, ptr %21, i64 %23
  store double %19, ptr %24, align 8
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region123

omp.loop_nest.region123:                          ; preds = %omp.loop_nest.region122
  br label %omp.region.cont120

omp.region.cont120:                               ; preds = %omp.loop_nest.region123
  br label %omp_loop.inc114

omp_loop.inc114:                                  ; preds = %omp.region.cont120
  %omp_loop.next119 = add nuw i64 %omp_loop.iv117, 1
  br label %omp_loop.header111

omp.par.exit99.exitStub:                          ; preds = %.fini133
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par.2(ptr noalias %tid.addr53, ptr noalias %zero.addr54, ptr %0) #0 {
omp.par.entry55:
  %gep_.reloaded89 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded89 = load ptr, ptr %gep_.reloaded89, align 8, !align !1
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded90 = load ptr, ptr %gep_.reloaded90, align 8, !align !1
  %gep_.reloaded91 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded91 = load ptr, ptr %gep_.reloaded91, align 8, !align !1
  %p.lastiter83 = alloca i32, align 4
  %p.lowerbound84 = alloca i64, align 8
  %p.upperbound85 = alloca i64, align 8
  %p.stride86 = alloca i64, align 8
  %tid.addr.local59 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr53, align 4
  store i32 %1, ptr %tid.addr.local59, align 4
  %tid60 = load i32, ptr %tid.addr.local59, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded89, align 8
  %3 = load i64, ptr %loadgep_.reloaded90, align 4
  %4 = load double, ptr %loadgep_.reloaded91, align 8
  br label %omp.region.after_alloca66

omp.region.after_alloca66:                        ; preds = %omp.par.entry55
  br label %omp.region.after_alloca63

omp.region.after_alloca63:                        ; preds = %omp.region.after_alloca66
  br label %omp.par.region56

omp.par.region56:                                 ; preds = %omp.region.after_alloca63
  br label %omp.par.region65

omp.par.region65:                                 ; preds = %omp.par.region56
  br label %omp.wsloop.region68

omp.wsloop.region68:                              ; preds = %omp.par.region65
  br label %omp_loop.preheader69

omp_loop.preheader69:                             ; preds = %omp.wsloop.region68
  store i64 0, ptr %p.lowerbound84, align 4
  store i64 649, ptr %p.upperbound85, align 4
  store i64 1, ptr %p.stride86, align 4
  %omp_global_thread_num87 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num87, i32 34, ptr %p.lastiter83, ptr %p.lowerbound84, ptr %p.upperbound85, ptr %p.stride86, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound84, align 4
  %6 = load i64, ptr %p.upperbound85, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header70

omp_loop.header70:                                ; preds = %omp_loop.inc73, %omp_loop.preheader69
  %omp_loop.iv76 = phi i64 [ 0, %omp_loop.preheader69 ], [ %omp_loop.next78, %omp_loop.inc73 ]
  br label %omp_loop.cond71

omp_loop.cond71:                                  ; preds = %omp_loop.header70
  %omp_loop.cmp77 = icmp ult i64 %omp_loop.iv76, %8
  br i1 %omp_loop.cmp77, label %omp_loop.body72, label %omp_loop.exit74

omp_loop.exit74:                                  ; preds = %omp_loop.cond71
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num87)
  %omp_global_thread_num88 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num88)
  br label %omp_loop.after75

omp_loop.after75:                                 ; preds = %omp_loop.exit74
  br label %omp.region.cont67

omp.region.cont67:                                ; preds = %omp_loop.after75
  br label %omp.region.cont64

omp.region.cont64:                                ; preds = %omp.region.cont67
  br label %omp.par.pre_finalize57

omp.par.pre_finalize57:                           ; preds = %omp.region.cont64
  br label %.fini92

.fini92:                                          ; preds = %omp.par.pre_finalize57
  br label %omp.par.exit58.exitStub

omp_loop.body72:                                  ; preds = %omp_loop.cond71
  %9 = add i64 %omp_loop.iv76, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region80

omp.loop_nest.region80:                           ; preds = %omp_loop.body72
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region81

omp.loop_nest.region81:                           ; preds = %omp.loop_nest.region80
  %13 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %14 = getelementptr double, ptr %13, i32 3380000
  %15 = mul nuw nsw i64 %3, 2600
  %16 = add nuw nsw i64 %15, %11
  %17 = getelementptr inbounds nuw double, ptr %14, i64 %16
  %18 = load double, ptr %17, align 8
  %19 = fmul double %18, %4
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %21 = getelementptr double, ptr %20, i32 3380000
  %22 = mul nuw nsw i64 %3, 2600
  %23 = add nuw nsw i64 %22, %11
  %24 = getelementptr inbounds nuw double, ptr %21, i64 %23
  store double %19, ptr %24, align 8
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region82

omp.loop_nest.region82:                           ; preds = %omp.loop_nest.region81
  br label %omp.region.cont79

omp.region.cont79:                                ; preds = %omp.loop_nest.region82
  br label %omp_loop.inc73

omp_loop.inc73:                                   ; preds = %omp.region.cont79
  %omp_loop.next78 = add nuw i64 %omp_loop.iv76, 1
  br label %omp_loop.header70

omp.par.exit58.exitStub:                          ; preds = %.fini92
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par.1(ptr noalias %tid.addr12, ptr noalias %zero.addr13, ptr %0) #0 {
omp.par.entry14:
  %gep_.reloaded48 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded48 = load ptr, ptr %gep_.reloaded48, align 8, !align !1
  %gep_.reloaded49 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded49 = load ptr, ptr %gep_.reloaded49, align 8, !align !1
  %gep_.reloaded50 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded50 = load ptr, ptr %gep_.reloaded50, align 8, !align !1
  %p.lastiter42 = alloca i32, align 4
  %p.lowerbound43 = alloca i64, align 8
  %p.upperbound44 = alloca i64, align 8
  %p.stride45 = alloca i64, align 8
  %tid.addr.local18 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr12, align 4
  store i32 %1, ptr %tid.addr.local18, align 4
  %tid19 = load i32, ptr %tid.addr.local18, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded48, align 8
  %3 = load i64, ptr %loadgep_.reloaded49, align 4
  %4 = load double, ptr %loadgep_.reloaded50, align 8
  br label %omp.region.after_alloca25

omp.region.after_alloca25:                        ; preds = %omp.par.entry14
  br label %omp.region.after_alloca22

omp.region.after_alloca22:                        ; preds = %omp.region.after_alloca25
  br label %omp.par.region15

omp.par.region15:                                 ; preds = %omp.region.after_alloca22
  br label %omp.par.region24

omp.par.region24:                                 ; preds = %omp.par.region15
  br label %omp.wsloop.region27

omp.wsloop.region27:                              ; preds = %omp.par.region24
  br label %omp_loop.preheader28

omp_loop.preheader28:                             ; preds = %omp.wsloop.region27
  store i64 0, ptr %p.lowerbound43, align 4
  store i64 649, ptr %p.upperbound44, align 4
  store i64 1, ptr %p.stride45, align 4
  %omp_global_thread_num46 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num46, i32 34, ptr %p.lastiter42, ptr %p.lowerbound43, ptr %p.upperbound44, ptr %p.stride45, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound43, align 4
  %6 = load i64, ptr %p.upperbound44, align 4
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
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num46)
  %omp_global_thread_num47 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num47)
  br label %omp_loop.after34

omp_loop.after34:                                 ; preds = %omp_loop.exit33
  br label %omp.region.cont26

omp.region.cont26:                                ; preds = %omp_loop.after34
  br label %omp.region.cont23

omp.region.cont23:                                ; preds = %omp.region.cont26
  br label %omp.par.pre_finalize16

omp.par.pre_finalize16:                           ; preds = %omp.region.cont23
  br label %.fini51

.fini51:                                          ; preds = %omp.par.pre_finalize16
  br label %omp.par.exit17.exitStub

omp_loop.body31:                                  ; preds = %omp_loop.cond30
  %9 = add i64 %omp_loop.iv35, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region39

omp.loop_nest.region39:                           ; preds = %omp_loop.body31
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region40

omp.loop_nest.region40:                           ; preds = %omp.loop_nest.region39
  %13 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %14 = getelementptr double, ptr %13, i32 1690000
  %15 = mul nuw nsw i64 %3, 2600
  %16 = add nuw nsw i64 %15, %11
  %17 = getelementptr inbounds nuw double, ptr %14, i64 %16
  %18 = load double, ptr %17, align 8
  %19 = fmul double %18, %4
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %21 = getelementptr double, ptr %20, i32 1690000
  %22 = mul nuw nsw i64 %3, 2600
  %23 = add nuw nsw i64 %22, %11
  %24 = getelementptr inbounds nuw double, ptr %21, i64 %23
  store double %19, ptr %24, align 8
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region41

omp.loop_nest.region41:                           ; preds = %omp.loop_nest.region40
  br label %omp.region.cont38

omp.region.cont38:                                ; preds = %omp.loop_nest.region41
  br label %omp_loop.inc32

omp_loop.inc32:                                   ; preds = %omp.region.cont38
  %omp_loop.next37 = add nuw i64 %omp_loop.iv35, 1
  br label %omp_loop.header29

omp.par.exit17.exitStub:                          ; preds = %.fini51
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_syrk..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded9 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded9 = load ptr, ptr %gep_.reloaded9, align 8, !align !1
  %gep_.reloaded10 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded10 = load ptr, ptr %gep_.reloaded10, align 8, !align !1
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load i64, ptr %loadgep_.reloaded9, align 4
  %4 = load double, ptr %loadgep_.reloaded10, align 8
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
  store i64 649, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num7 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num7, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
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
  %9 = add i64 %omp_loop.iv, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region5

omp.loop_nest.region5:                            ; preds = %omp.loop_nest.region
  %13 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %14 = mul nuw nsw i64 %3, 2600
  %15 = add nuw nsw i64 %14, %11
  %16 = getelementptr inbounds nuw double, ptr %13, i64 %15
  %17 = load double, ptr %16, align 8
  %18 = fmul double %17, %4
  %19 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %20 = mul nuw nsw i64 %3, 2600
  %21 = add nuw nsw i64 %20, %11
  %22 = getelementptr inbounds nuw double, ptr %19, i64 %21
  store double %18, ptr %22, align 8
  call void @llvm.stackrestore.p0(ptr %12)
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
