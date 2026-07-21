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

define void @kernel_doitgen(i32 %0, i32 %1, i32 %2, ptr %3, ptr %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, i64 %11, ptr %12, ptr %13, i64 %14, i64 %15, i64 %16, i64 %17, i64 %18, ptr %19, ptr %20, i64 %21, i64 %22, i64 %23, i64 %24, i64 %25, i64 %26, i64 %27) {
  %structArg184 = alloca { ptr, ptr, ptr }, align 8
  %structArg181 = alloca { ptr, ptr, ptr }, align 8
  %structArg178 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded175 = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %.reloaded176 = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %.reloaded123 = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %.reloaded124 = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %.reloaded71 = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %.reloaded72 = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %.reloaded21 = alloca { ptr, ptr, i64, [3 x i64], [3 x i64] }, align 8
  %29 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %19, 0
  %30 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %29, ptr %20, 1
  %31 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %30, i64 %21, 2
  %32 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %31, i64 %22, 3, 0
  %33 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %32, i64 %25, 4, 0
  %34 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %33, i64 %23, 3, 1
  %35 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %34, i64 %26, 4, 1
  %36 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %35, i64 %24, 3, 2
  %37 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %36, i64 %27, 4, 2
  %38 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %3, 0
  %39 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %38, ptr %4, 1
  %40 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %39, i64 %5, 2
  %41 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %40, i64 %6, 3, 0
  %42 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %41, i64 %9, 4, 0
  %43 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %42, i64 %7, 3, 1
  %44 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %43, i64 %10, 4, 1
  %45 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %44, i64 %8, 3, 2
  %46 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %45, i64 %11, 4, 2
  %47 = call i32 @MPI_Init(ptr null, ptr null)
  %48 = alloca i32, align 4
  %49 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %48)
  %50 = load i32, ptr %48, align 4
  %51 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %52 = getelementptr { ptr, ptr, i32, float }, ptr %51, i32 0, i32 0
  %53 = getelementptr { ptr, ptr, i32, float }, ptr %51, i32 0, i32 1
  %54 = getelementptr { ptr, ptr, i32, float }, ptr %51, i32 0, i32 2
  %55 = getelementptr { ptr, ptr, i32, float }, ptr %51, i32 0, i32 3
  store ptr @node_str_0, ptr %52, align 8
  store ptr @arch_str_0, ptr %53, align 8
  store i32 0, ptr %54, align 4
  store float 1.000000e+00, ptr %55, align 4
  %56 = getelementptr { ptr, ptr, i32, float }, ptr %51, i32 1
  %57 = getelementptr { ptr, ptr, i32, float }, ptr %56, i32 0, i32 0
  %58 = getelementptr { ptr, ptr, i32, float }, ptr %56, i32 0, i32 1
  %59 = getelementptr { ptr, ptr, i32, float }, ptr %56, i32 0, i32 2
  %60 = getelementptr { ptr, ptr, i32, float }, ptr %56, i32 0, i32 3
  store ptr @node_str_1, ptr %57, align 8
  store ptr @arch_str_1, ptr %58, align 8
  store i32 0, ptr %59, align 4
  store float 1.000000e+00, ptr %60, align 4
  %61 = getelementptr { ptr, ptr, i32, float }, ptr %51, i32 2
  %62 = getelementptr { ptr, ptr, i32, float }, ptr %61, i32 0, i32 0
  %63 = getelementptr { ptr, ptr, i32, float }, ptr %61, i32 0, i32 1
  %64 = getelementptr { ptr, ptr, i32, float }, ptr %61, i32 0, i32 2
  %65 = getelementptr { ptr, ptr, i32, float }, ptr %61, i32 0, i32 3
  store ptr @node_str_2, ptr %62, align 8
  store ptr @arch_str_2, ptr %63, align 8
  store i32 0, ptr %64, align 4
  store float 1.000000e+00, ptr %65, align 4
  %66 = getelementptr { ptr, ptr, i32, float }, ptr %51, i32 3
  %67 = getelementptr { ptr, ptr, i32, float }, ptr %66, i32 0, i32 0
  %68 = getelementptr { ptr, ptr, i32, float }, ptr %66, i32 0, i32 1
  %69 = getelementptr { ptr, ptr, i32, float }, ptr %66, i32 0, i32 2
  %70 = getelementptr { ptr, ptr, i32, float }, ptr %66, i32 0, i32 3
  store ptr @node_str_3, ptr %67, align 8
  store ptr @arch_str_3, ptr %68, align 8
  store i32 0, ptr %69, align 4
  store float 1.000000e+00, ptr %70, align 4
  %71 = alloca { i32, ptr }, i64 1, align 8
  %72 = getelementptr { i32, ptr }, ptr %71, i32 0, i32 0
  %73 = getelementptr { i32, ptr }, ptr %71, i32 0, i32 1
  store i32 4, ptr %72, align 4
  store ptr %51, ptr %73, align 8
  %74 = call ptr @malloc(i64 16)
  %75 = call ptr @malloc(i64 16)
  %76 = ptrtoint ptr %74 to i64
  %77 = ptrtoint ptr %75 to i64
  %78 = inttoptr i64 %76 to ptr
  %79 = inttoptr i64 %77 to ptr
  call void @buildRankNodeMaps(ptr %71, ptr %78, ptr %79)
  %80 = sext i32 %50 to i64
  %81 = getelementptr inbounds nuw i32, ptr %74, i64 %80
  %82 = load i32, ptr %81, align 4
  %83 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 0
  %84 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 1
  %85 = insertvalue { ptr, ptr, i64 } poison, ptr %83, 0
  %86 = insertvalue { ptr, ptr, i64 } %85, ptr %84, 1
  %87 = insertvalue { ptr, ptr, i64 } %86, i64 0, 2
  %88 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 2
  %89 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 0
  %90 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 1
  %91 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 2
  %92 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 0
  %93 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 1
  %94 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 2
  %95 = extractvalue { ptr, ptr, i64 } %87, 0
  %96 = extractvalue { ptr, ptr, i64 } %87, 1
  %97 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %95, 0
  %98 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %97, ptr %96, 1
  %99 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %98, i64 0, 2
  %100 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %99, i64 32, 3, 0
  %101 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %100, i64 16384, 4, 0
  %102 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %101, i64 128, 3, 1
  %103 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %102, i64 128, 4, 1
  %104 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %103, i64 128, 3, 2
  %105 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %104, i64 1, 4, 2
  %106 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 0
  %107 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 1
  %108 = insertvalue { ptr, ptr, i64 } poison, ptr %106, 0
  %109 = insertvalue { ptr, ptr, i64 } %108, ptr %107, 1
  %110 = insertvalue { ptr, ptr, i64 } %109, i64 0, 2
  %111 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 2
  %112 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 0
  %113 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 1
  %114 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 2
  %115 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 0
  %116 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 1
  %117 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 2
  %118 = extractvalue { ptr, ptr, i64 } %110, 0
  %119 = extractvalue { ptr, ptr, i64 } %110, 1
  %120 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %118, 0
  %121 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %120, ptr %119, 1
  %122 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %121, i64 0, 2
  %123 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %122, i64 32, 3, 0
  %124 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %123, i64 16384, 4, 0
  %125 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %124, i64 128, 3, 1
  %126 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %125, i64 128, 4, 1
  %127 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %126, i64 128, 3, 2
  %128 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %127, i64 1, 4, 2
  %129 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 0
  %130 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 1
  %131 = insertvalue { ptr, ptr, i64 } poison, ptr %129, 0
  %132 = insertvalue { ptr, ptr, i64 } %131, ptr %130, 1
  %133 = insertvalue { ptr, ptr, i64 } %132, i64 0, 2
  %134 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 2
  %135 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 0
  %136 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 1
  %137 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 2
  %138 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 0
  %139 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 1
  %140 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 2
  %141 = extractvalue { ptr, ptr, i64 } %133, 0
  %142 = extractvalue { ptr, ptr, i64 } %133, 1
  %143 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %141, 0
  %144 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %143, ptr %142, 1
  %145 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %144, i64 524288, 2
  %146 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %145, i64 32, 3, 0
  %147 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %146, i64 16384, 4, 0
  %148 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %147, i64 128, 3, 1
  %149 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %148, i64 128, 4, 1
  %150 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %149, i64 128, 3, 2
  %151 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %150, i64 1, 4, 2
  %152 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 0
  %153 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 1
  %154 = insertvalue { ptr, ptr, i64 } poison, ptr %152, 0
  %155 = insertvalue { ptr, ptr, i64 } %154, ptr %153, 1
  %156 = insertvalue { ptr, ptr, i64 } %155, i64 0, 2
  %157 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 2
  %158 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 0
  %159 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 1
  %160 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 2
  %161 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 0
  %162 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 1
  %163 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 2
  %164 = extractvalue { ptr, ptr, i64 } %156, 0
  %165 = extractvalue { ptr, ptr, i64 } %156, 1
  %166 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %164, 0
  %167 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %166, ptr %165, 1
  %168 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %167, i64 524288, 2
  %169 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %168, i64 32, 3, 0
  %170 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %169, i64 16384, 4, 0
  %171 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %170, i64 128, 3, 1
  %172 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %171, i64 128, 4, 1
  %173 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %172, i64 128, 3, 2
  %174 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %173, i64 1, 4, 2
  %175 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 0
  %176 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 1
  %177 = insertvalue { ptr, ptr, i64 } poison, ptr %175, 0
  %178 = insertvalue { ptr, ptr, i64 } %177, ptr %176, 1
  %179 = insertvalue { ptr, ptr, i64 } %178, i64 0, 2
  %180 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 2
  %181 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 0
  %182 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 1
  %183 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 2
  %184 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 0
  %185 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 1
  %186 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 2
  %187 = extractvalue { ptr, ptr, i64 } %179, 0
  %188 = extractvalue { ptr, ptr, i64 } %179, 1
  %189 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %187, 0
  %190 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %189, ptr %188, 1
  %191 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %190, i64 1048576, 2
  %192 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %191, i64 32, 3, 0
  %193 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %192, i64 16384, 4, 0
  %194 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %193, i64 128, 3, 1
  %195 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %194, i64 128, 4, 1
  %196 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %195, i64 128, 3, 2
  %197 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %196, i64 1, 4, 2
  %198 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 0
  %199 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 1
  %200 = insertvalue { ptr, ptr, i64 } poison, ptr %198, 0
  %201 = insertvalue { ptr, ptr, i64 } %200, ptr %199, 1
  %202 = insertvalue { ptr, ptr, i64 } %201, i64 0, 2
  %203 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 2
  %204 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 0
  %205 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 1
  %206 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 2
  %207 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 0
  %208 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 1
  %209 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 2
  %210 = extractvalue { ptr, ptr, i64 } %202, 0
  %211 = extractvalue { ptr, ptr, i64 } %202, 1
  %212 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %210, 0
  %213 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %212, ptr %211, 1
  %214 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %213, i64 1048576, 2
  %215 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %214, i64 32, 3, 0
  %216 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %215, i64 16384, 4, 0
  %217 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %216, i64 128, 3, 1
  %218 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %217, i64 128, 4, 1
  %219 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %218, i64 128, 3, 2
  %220 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %219, i64 1, 4, 2
  %221 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 0
  %222 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 1
  %223 = insertvalue { ptr, ptr, i64 } poison, ptr %221, 0
  %224 = insertvalue { ptr, ptr, i64 } %223, ptr %222, 1
  %225 = insertvalue { ptr, ptr, i64 } %224, i64 0, 2
  %226 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 2
  %227 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 0
  %228 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 1
  %229 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 2
  %230 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 0
  %231 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 1
  %232 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 2
  %233 = extractvalue { ptr, ptr, i64 } %225, 0
  %234 = extractvalue { ptr, ptr, i64 } %225, 1
  %235 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %233, 0
  %236 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %235, ptr %234, 1
  %237 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %236, i64 1572864, 2
  %238 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %237, i64 32, 3, 0
  %239 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %238, i64 16384, 4, 0
  %240 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %239, i64 128, 3, 1
  %241 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %240, i64 128, 4, 1
  %242 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %241, i64 128, 3, 2
  %243 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %242, i64 1, 4, 2
  %244 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 0
  %245 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 1
  %246 = insertvalue { ptr, ptr, i64 } poison, ptr %244, 0
  %247 = insertvalue { ptr, ptr, i64 } %246, ptr %245, 1
  %248 = insertvalue { ptr, ptr, i64 } %247, i64 0, 2
  %249 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 2
  %250 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 0
  %251 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 1
  %252 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 3, 2
  %253 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 0
  %254 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 1
  %255 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %37, 4, 2
  %256 = extractvalue { ptr, ptr, i64 } %248, 0
  %257 = extractvalue { ptr, ptr, i64 } %248, 1
  %258 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %256, 0
  %259 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %258, ptr %257, 1
  %260 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %259, i64 1572864, 2
  %261 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %260, i64 32, 3, 0
  %262 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %261, i64 16384, 4, 0
  %263 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %262, i64 128, 3, 1
  %264 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %263, i64 128, 4, 1
  %265 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %264, i64 128, 3, 2
  %266 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %265, i64 1, 4, 2
  %267 = icmp eq i32 %82, 0
  br i1 %267, label %268, label %269

268:                                              ; preds = %28
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %128, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %105, ptr %.reloaded21, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %268
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded21 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded21, ptr %gep_.reloaded21, align 8
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %13, ptr %gep_, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_doitgen..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %269

269:                                              ; preds = %omp.par.exit, %28
  %270 = icmp eq i32 %82, 1
  br i1 %270, label %271, label %272

271:                                              ; preds = %269
  %omp_global_thread_num22 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %174, ptr %.reloaded71, align 8
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %151, ptr %.reloaded72, align 8
  br label %omp_parallel180

omp_parallel180:                                  ; preds = %271
  %gep_.reloaded71 = getelementptr { ptr, ptr, ptr }, ptr %structArg178, i32 0, i32 0
  store ptr %.reloaded71, ptr %gep_.reloaded71, align 8
  %gep_.reloaded72 = getelementptr { ptr, ptr, ptr }, ptr %structArg178, i32 0, i32 1
  store ptr %.reloaded72, ptr %gep_.reloaded72, align 8
  %gep_179 = getelementptr { ptr, ptr, ptr }, ptr %structArg178, i32 0, i32 2
  store ptr %13, ptr %gep_179, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_doitgen..omp_par.1, ptr %structArg178)
  br label %omp.par.exit28

omp.par.exit28:                                   ; preds = %omp_parallel180
  br label %272

272:                                              ; preds = %omp.par.exit28, %269
  %273 = icmp eq i32 %82, 2
  br i1 %273, label %274, label %275

274:                                              ; preds = %272
  %omp_global_thread_num74 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %220, ptr %.reloaded123, align 8
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %197, ptr %.reloaded124, align 8
  br label %omp_parallel183

omp_parallel183:                                  ; preds = %274
  %gep_.reloaded123 = getelementptr { ptr, ptr, ptr }, ptr %structArg181, i32 0, i32 0
  store ptr %.reloaded123, ptr %gep_.reloaded123, align 8
  %gep_.reloaded124 = getelementptr { ptr, ptr, ptr }, ptr %structArg181, i32 0, i32 1
  store ptr %.reloaded124, ptr %gep_.reloaded124, align 8
  %gep_182 = getelementptr { ptr, ptr, ptr }, ptr %structArg181, i32 0, i32 2
  store ptr %13, ptr %gep_182, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_doitgen..omp_par.2, ptr %structArg181)
  br label %omp.par.exit80

omp.par.exit80:                                   ; preds = %omp_parallel183
  br label %275

275:                                              ; preds = %omp.par.exit80, %272
  %276 = icmp eq i32 %82, 3
  br i1 %276, label %277, label %278

277:                                              ; preds = %275
  %omp_global_thread_num126 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %266, ptr %.reloaded175, align 8
  store { ptr, ptr, i64, [3 x i64], [3 x i64] } %243, ptr %.reloaded176, align 8
  br label %omp_parallel186

omp_parallel186:                                  ; preds = %277
  %gep_.reloaded175 = getelementptr { ptr, ptr, ptr }, ptr %structArg184, i32 0, i32 0
  store ptr %.reloaded175, ptr %gep_.reloaded175, align 8
  %gep_.reloaded176 = getelementptr { ptr, ptr, ptr }, ptr %structArg184, i32 0, i32 1
  store ptr %.reloaded176, ptr %gep_.reloaded176, align 8
  %gep_185 = getelementptr { ptr, ptr, ptr }, ptr %structArg184, i32 0, i32 2
  store ptr %13, ptr %gep_185, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @kernel_doitgen..omp_par.3, ptr %structArg184)
  br label %omp.par.exit132

omp.par.exit132:                                  ; preds = %omp_parallel186
  br label %278

278:                                              ; preds = %omp.par.exit132, %275
  %279 = call i32 @MPI_Barrier(i32 1140850688)
  %280 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 0
  %281 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 1
  %282 = insertvalue { ptr, ptr, i64 } poison, ptr %280, 0
  %283 = insertvalue { ptr, ptr, i64 } %282, ptr %281, 1
  %284 = insertvalue { ptr, ptr, i64 } %283, i64 0, 2
  %285 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 2
  %286 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 0
  %287 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 1
  %288 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 2
  %289 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 0
  %290 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 1
  %291 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 2
  %292 = extractvalue { ptr, ptr, i64 } %284, 0
  %293 = extractvalue { ptr, ptr, i64 } %284, 1
  %294 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %292, 0
  %295 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %294, ptr %293, 1
  %296 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %295, i64 524288, 2
  %297 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %296, i64 32, 3, 0
  %298 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %297, i64 16384, 4, 0
  %299 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %298, i64 128, 3, 1
  %300 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %299, i64 128, 4, 1
  %301 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %300, i64 128, 3, 2
  %302 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %301, i64 1, 4, 2
  %303 = load i32, ptr %75, align 4
  %304 = getelementptr inbounds nuw i32, ptr %75, i32 1
  %305 = load i32, ptr %304, align 4
  %306 = icmp eq i32 %50, %303
  %307 = icmp eq i32 %50, %305
  br i1 %306, label %308, label %315

308:                                              ; preds = %278
  %309 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %302, 1
  %310 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %302, 2
  %311 = getelementptr float, ptr %309, i64 %310
  %312 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %302, 3, 0
  %313 = trunc i64 %312 to i32
  %314 = call i32 @MPI_Recv(ptr %311, i32 %313, i32 1275069450, i32 %305, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %324

315:                                              ; preds = %278
  br i1 %307, label %316, label %323

316:                                              ; preds = %315
  %317 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %302, 1
  %318 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %302, 2
  %319 = getelementptr float, ptr %317, i64 %318
  %320 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %302, 3, 0
  %321 = trunc i64 %320 to i32
  %322 = call i32 @MPI_Send(ptr %319, i32 %321, i32 1275069450, i32 %303, i32 0, i32 1140850688)
  br label %323

323:                                              ; preds = %316, %315
  br label %324

324:                                              ; preds = %308, %323
  %325 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 0
  %326 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 1
  %327 = insertvalue { ptr, ptr, i64 } poison, ptr %325, 0
  %328 = insertvalue { ptr, ptr, i64 } %327, ptr %326, 1
  %329 = insertvalue { ptr, ptr, i64 } %328, i64 0, 2
  %330 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 2
  %331 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 0
  %332 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 1
  %333 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 2
  %334 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 0
  %335 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 1
  %336 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 2
  %337 = extractvalue { ptr, ptr, i64 } %329, 0
  %338 = extractvalue { ptr, ptr, i64 } %329, 1
  %339 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %337, 0
  %340 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %339, ptr %338, 1
  %341 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %340, i64 1048576, 2
  %342 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %341, i64 32, 3, 0
  %343 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %342, i64 16384, 4, 0
  %344 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %343, i64 128, 3, 1
  %345 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %344, i64 128, 4, 1
  %346 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %345, i64 128, 3, 2
  %347 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %346, i64 1, 4, 2
  %348 = load i32, ptr %75, align 4
  %349 = getelementptr inbounds nuw i32, ptr %75, i32 2
  %350 = load i32, ptr %349, align 4
  %351 = icmp eq i32 %50, %348
  %352 = icmp eq i32 %50, %350
  br i1 %351, label %353, label %360

353:                                              ; preds = %324
  %354 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %347, 1
  %355 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %347, 2
  %356 = getelementptr float, ptr %354, i64 %355
  %357 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %347, 3, 0
  %358 = trunc i64 %357 to i32
  %359 = call i32 @MPI_Recv(ptr %356, i32 %358, i32 1275069450, i32 %350, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %369

360:                                              ; preds = %324
  br i1 %352, label %361, label %368

361:                                              ; preds = %360
  %362 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %347, 1
  %363 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %347, 2
  %364 = getelementptr float, ptr %362, i64 %363
  %365 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %347, 3, 0
  %366 = trunc i64 %365 to i32
  %367 = call i32 @MPI_Send(ptr %364, i32 %366, i32 1275069450, i32 %348, i32 0, i32 1140850688)
  br label %368

368:                                              ; preds = %361, %360
  br label %369

369:                                              ; preds = %353, %368
  %370 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 0
  %371 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 1
  %372 = insertvalue { ptr, ptr, i64 } poison, ptr %370, 0
  %373 = insertvalue { ptr, ptr, i64 } %372, ptr %371, 1
  %374 = insertvalue { ptr, ptr, i64 } %373, i64 0, 2
  %375 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 2
  %376 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 0
  %377 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 1
  %378 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 3, 2
  %379 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 0
  %380 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 1
  %381 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %46, 4, 2
  %382 = extractvalue { ptr, ptr, i64 } %374, 0
  %383 = extractvalue { ptr, ptr, i64 } %374, 1
  %384 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } poison, ptr %382, 0
  %385 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %384, ptr %383, 1
  %386 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %385, i64 1572864, 2
  %387 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %386, i64 32, 3, 0
  %388 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %387, i64 16384, 4, 0
  %389 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %388, i64 128, 3, 1
  %390 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %389, i64 128, 4, 1
  %391 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %390, i64 128, 3, 2
  %392 = insertvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %391, i64 1, 4, 2
  %393 = load i32, ptr %75, align 4
  %394 = getelementptr inbounds nuw i32, ptr %75, i32 3
  %395 = load i32, ptr %394, align 4
  %396 = icmp eq i32 %50, %393
  %397 = icmp eq i32 %50, %395
  br i1 %396, label %398, label %405

398:                                              ; preds = %369
  %399 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %392, 1
  %400 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %392, 2
  %401 = getelementptr float, ptr %399, i64 %400
  %402 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %392, 3, 0
  %403 = trunc i64 %402 to i32
  %404 = call i32 @MPI_Recv(ptr %401, i32 %403, i32 1275069450, i32 %395, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %414

405:                                              ; preds = %369
  br i1 %397, label %406, label %413

406:                                              ; preds = %405
  %407 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %392, 1
  %408 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %392, 2
  %409 = getelementptr float, ptr %407, i64 %408
  %410 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %392, 3, 0
  %411 = trunc i64 %410 to i32
  %412 = call i32 @MPI_Send(ptr %409, i32 %411, i32 1275069450, i32 %393, i32 0, i32 1140850688)
  br label %413

413:                                              ; preds = %406, %405
  br label %414

414:                                              ; preds = %398, %413
  %415 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_doitgen..omp_par.3(ptr noalias %tid.addr127, ptr noalias %zero.addr128, ptr %0) #0 {
omp.par.entry129:
  %gep_.reloaded175 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded175 = load ptr, ptr %gep_.reloaded175, align 8, !align !1
  %gep_.reloaded176 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded176 = load ptr, ptr %gep_.reloaded176, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter169 = alloca i32, align 4
  %p.lowerbound170 = alloca i64, align 8
  %p.upperbound171 = alloca i64, align 8
  %p.stride172 = alloca i64, align 8
  %tid.addr.local133 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr127, align 4
  store i32 %1, ptr %tid.addr.local133, align 4
  %tid134 = load i32, ptr %tid.addr.local133, align 4
  %2 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded175, align 8
  %3 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded176, align 8
  br label %omp.region.after_alloca140

omp.region.after_alloca140:                       ; preds = %omp.par.entry129
  br label %omp.region.after_alloca137

omp.region.after_alloca137:                       ; preds = %omp.region.after_alloca140
  br label %omp.par.region130

omp.par.region130:                                ; preds = %omp.region.after_alloca137
  br label %omp.par.region139

omp.par.region139:                                ; preds = %omp.par.region130
  br label %omp.wsloop.region142

omp.wsloop.region142:                             ; preds = %omp.par.region139
  br label %omp_loop.preheader143

omp_loop.preheader143:                            ; preds = %omp.wsloop.region142
  store i64 0, ptr %p.lowerbound170, align 4
  store i64 31, ptr %p.upperbound171, align 4
  store i64 1, ptr %p.stride172, align 4
  %omp_global_thread_num173 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num173, i32 34, ptr %p.lastiter169, ptr %p.lowerbound170, ptr %p.upperbound171, ptr %p.stride172, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound170, align 4
  %5 = load i64, ptr %p.upperbound171, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header144

omp_loop.header144:                               ; preds = %omp_loop.inc147, %omp_loop.preheader143
  %omp_loop.iv150 = phi i64 [ 0, %omp_loop.preheader143 ], [ %omp_loop.next152, %omp_loop.inc147 ]
  br label %omp_loop.cond145

omp_loop.cond145:                                 ; preds = %omp_loop.header144
  %omp_loop.cmp151 = icmp ult i64 %omp_loop.iv150, %7
  br i1 %omp_loop.cmp151, label %omp_loop.body146, label %omp_loop.exit148

omp_loop.exit148:                                 ; preds = %omp_loop.cond145
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num173)
  %omp_global_thread_num174 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num174)
  br label %omp_loop.after149

omp_loop.after149:                                ; preds = %omp_loop.exit148
  br label %omp.region.cont141

omp.region.cont141:                               ; preds = %omp_loop.after149
  br label %omp.region.cont138

omp.region.cont138:                               ; preds = %omp.region.cont141
  br label %omp.par.pre_finalize131

omp.par.pre_finalize131:                          ; preds = %omp.region.cont138
  br label %.fini177

.fini177:                                         ; preds = %omp.par.pre_finalize131
  br label %omp.par.exit132.exitStub

omp_loop.body146:                                 ; preds = %omp_loop.cond145
  %8 = add i64 %omp_loop.iv150, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region154

omp.loop_nest.region154:                          ; preds = %omp_loop.body146
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region155

omp.loop_nest.region155:                          ; preds = %omp.loop_nest.region154
  br label %omp.loop_nest.region156

omp.loop_nest.region156:                          ; preds = %omp.loop_nest.region166, %omp.loop_nest.region155
  %12 = phi i64 [ %18, %omp.loop_nest.region166 ], [ 0, %omp.loop_nest.region155 ]
  %13 = icmp slt i64 %12, 64
  br i1 %13, label %omp.loop_nest.region157, label %omp.loop_nest.region167

omp.loop_nest.region167:                          ; preds = %omp.loop_nest.region156
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region168

omp.loop_nest.region168:                          ; preds = %omp.loop_nest.region167
  br label %omp.region.cont153

omp.region.cont153:                               ; preds = %omp.loop_nest.region168
  br label %omp_loop.inc147

omp_loop.inc147:                                  ; preds = %omp.region.cont153
  %omp_loop.next152 = add nuw i64 %omp_loop.iv150, 1
  br label %omp_loop.header144

omp.loop_nest.region157:                          ; preds = %omp.loop_nest.region156
  br label %omp.loop_nest.region158

omp.loop_nest.region158:                          ; preds = %omp.loop_nest.region162, %omp.loop_nest.region157
  %14 = phi i64 [ %44, %omp.loop_nest.region162 ], [ 0, %omp.loop_nest.region157 ]
  %15 = icmp slt i64 %14, 32
  br i1 %15, label %omp.loop_nest.region159, label %omp.loop_nest.region163

omp.loop_nest.region163:                          ; preds = %omp.loop_nest.region158
  br label %omp.loop_nest.region164

omp.loop_nest.region164:                          ; preds = %omp.loop_nest.region165, %omp.loop_nest.region163
  %16 = phi i64 [ %34, %omp.loop_nest.region165 ], [ 0, %omp.loop_nest.region163 ]
  %17 = icmp slt i64 %16, 128
  br i1 %17, label %omp.loop_nest.region165, label %omp.loop_nest.region166

omp.loop_nest.region166:                          ; preds = %omp.loop_nest.region164
  %18 = add i64 %12, 1
  br label %omp.loop_nest.region156

omp.loop_nest.region165:                          ; preds = %omp.loop_nest.region164
  %19 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %20 = getelementptr float, ptr %19, i32 1572864
  %21 = mul nuw nsw i64 %10, 16384
  %22 = mul nuw nsw i64 %12, 128
  %23 = add nuw nsw i64 %21, %22
  %24 = add nuw nsw i64 %23, %16
  %25 = getelementptr inbounds nuw float, ptr %20, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %28 = getelementptr float, ptr %27, i32 1572864
  %29 = mul nuw nsw i64 %10, 16384
  %30 = mul nuw nsw i64 %12, 128
  %31 = add nuw nsw i64 %29, %30
  %32 = add nuw nsw i64 %31, %16
  %33 = getelementptr inbounds nuw float, ptr %28, i64 %32
  store float %26, ptr %33, align 4
  %34 = add i64 %16, 1
  br label %omp.loop_nest.region164

omp.loop_nest.region159:                          ; preds = %omp.loop_nest.region158
  %35 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %36 = getelementptr float, ptr %35, i32 1572864
  %37 = mul nuw nsw i64 %10, 16384
  %38 = mul nuw nsw i64 %12, 128
  %39 = add nuw nsw i64 %37, %38
  %40 = add nuw nsw i64 %39, %14
  %41 = getelementptr inbounds nuw float, ptr %36, i64 %40
  store float 0.000000e+00, ptr %41, align 4
  br label %omp.loop_nest.region160

omp.loop_nest.region160:                          ; preds = %omp.loop_nest.region161, %omp.loop_nest.region159
  %42 = phi i64 [ %74, %omp.loop_nest.region161 ], [ 0, %omp.loop_nest.region159 ]
  %43 = icmp slt i64 %42, 32
  br i1 %43, label %omp.loop_nest.region161, label %omp.loop_nest.region162

omp.loop_nest.region162:                          ; preds = %omp.loop_nest.region160
  %44 = add i64 %14, 1
  br label %omp.loop_nest.region158

omp.loop_nest.region161:                          ; preds = %omp.loop_nest.region160
  %45 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %46 = getelementptr float, ptr %45, i32 1572864
  %47 = mul nuw nsw i64 %10, 16384
  %48 = mul nuw nsw i64 %12, 128
  %49 = add nuw nsw i64 %47, %48
  %50 = add nuw nsw i64 %49, %14
  %51 = getelementptr inbounds nuw float, ptr %46, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %54 = getelementptr float, ptr %53, i32 1572864
  %55 = mul nuw nsw i64 %10, 16384
  %56 = mul nuw nsw i64 %12, 128
  %57 = add nuw nsw i64 %55, %56
  %58 = add nuw nsw i64 %57, %42
  %59 = getelementptr inbounds nuw float, ptr %54, i64 %58
  %60 = load float, ptr %59, align 4
  %61 = mul nuw nsw i64 %42, 128
  %62 = add nuw nsw i64 %61, %14
  %63 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %62
  %64 = load float, ptr %63, align 4
  %65 = fmul float %60, %64
  %66 = fadd float %52, %65
  %67 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %68 = getelementptr float, ptr %67, i32 1572864
  %69 = mul nuw nsw i64 %10, 16384
  %70 = mul nuw nsw i64 %12, 128
  %71 = add nuw nsw i64 %69, %70
  %72 = add nuw nsw i64 %71, %14
  %73 = getelementptr inbounds nuw float, ptr %68, i64 %72
  store float %66, ptr %73, align 4
  %74 = add i64 %42, 1
  br label %omp.loop_nest.region160

omp.par.exit132.exitStub:                         ; preds = %.fini177
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_doitgen..omp_par.2(ptr noalias %tid.addr75, ptr noalias %zero.addr76, ptr %0) #0 {
omp.par.entry77:
  %gep_.reloaded123 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded123 = load ptr, ptr %gep_.reloaded123, align 8, !align !1
  %gep_.reloaded124 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded124 = load ptr, ptr %gep_.reloaded124, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter117 = alloca i32, align 4
  %p.lowerbound118 = alloca i64, align 8
  %p.upperbound119 = alloca i64, align 8
  %p.stride120 = alloca i64, align 8
  %tid.addr.local81 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr75, align 4
  store i32 %1, ptr %tid.addr.local81, align 4
  %tid82 = load i32, ptr %tid.addr.local81, align 4
  %2 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded123, align 8
  %3 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded124, align 8
  br label %omp.region.after_alloca88

omp.region.after_alloca88:                        ; preds = %omp.par.entry77
  br label %omp.region.after_alloca85

omp.region.after_alloca85:                        ; preds = %omp.region.after_alloca88
  br label %omp.par.region78

omp.par.region78:                                 ; preds = %omp.region.after_alloca85
  br label %omp.par.region87

omp.par.region87:                                 ; preds = %omp.par.region78
  br label %omp.wsloop.region90

omp.wsloop.region90:                              ; preds = %omp.par.region87
  br label %omp_loop.preheader91

omp_loop.preheader91:                             ; preds = %omp.wsloop.region90
  store i64 0, ptr %p.lowerbound118, align 4
  store i64 31, ptr %p.upperbound119, align 4
  store i64 1, ptr %p.stride120, align 4
  %omp_global_thread_num121 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num121, i32 34, ptr %p.lastiter117, ptr %p.lowerbound118, ptr %p.upperbound119, ptr %p.stride120, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound118, align 4
  %5 = load i64, ptr %p.upperbound119, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header92

omp_loop.header92:                                ; preds = %omp_loop.inc95, %omp_loop.preheader91
  %omp_loop.iv98 = phi i64 [ 0, %omp_loop.preheader91 ], [ %omp_loop.next100, %omp_loop.inc95 ]
  br label %omp_loop.cond93

omp_loop.cond93:                                  ; preds = %omp_loop.header92
  %omp_loop.cmp99 = icmp ult i64 %omp_loop.iv98, %7
  br i1 %omp_loop.cmp99, label %omp_loop.body94, label %omp_loop.exit96

omp_loop.exit96:                                  ; preds = %omp_loop.cond93
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num121)
  %omp_global_thread_num122 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num122)
  br label %omp_loop.after97

omp_loop.after97:                                 ; preds = %omp_loop.exit96
  br label %omp.region.cont89

omp.region.cont89:                                ; preds = %omp_loop.after97
  br label %omp.region.cont86

omp.region.cont86:                                ; preds = %omp.region.cont89
  br label %omp.par.pre_finalize79

omp.par.pre_finalize79:                           ; preds = %omp.region.cont86
  br label %.fini125

.fini125:                                         ; preds = %omp.par.pre_finalize79
  br label %omp.par.exit80.exitStub

omp_loop.body94:                                  ; preds = %omp_loop.cond93
  %8 = add i64 %omp_loop.iv98, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region102

omp.loop_nest.region102:                          ; preds = %omp_loop.body94
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region103

omp.loop_nest.region103:                          ; preds = %omp.loop_nest.region102
  br label %omp.loop_nest.region104

omp.loop_nest.region104:                          ; preds = %omp.loop_nest.region114, %omp.loop_nest.region103
  %12 = phi i64 [ %18, %omp.loop_nest.region114 ], [ 0, %omp.loop_nest.region103 ]
  %13 = icmp slt i64 %12, 64
  br i1 %13, label %omp.loop_nest.region105, label %omp.loop_nest.region115

omp.loop_nest.region115:                          ; preds = %omp.loop_nest.region104
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region116

omp.loop_nest.region116:                          ; preds = %omp.loop_nest.region115
  br label %omp.region.cont101

omp.region.cont101:                               ; preds = %omp.loop_nest.region116
  br label %omp_loop.inc95

omp_loop.inc95:                                   ; preds = %omp.region.cont101
  %omp_loop.next100 = add nuw i64 %omp_loop.iv98, 1
  br label %omp_loop.header92

omp.loop_nest.region105:                          ; preds = %omp.loop_nest.region104
  br label %omp.loop_nest.region106

omp.loop_nest.region106:                          ; preds = %omp.loop_nest.region110, %omp.loop_nest.region105
  %14 = phi i64 [ %44, %omp.loop_nest.region110 ], [ 0, %omp.loop_nest.region105 ]
  %15 = icmp slt i64 %14, 32
  br i1 %15, label %omp.loop_nest.region107, label %omp.loop_nest.region111

omp.loop_nest.region111:                          ; preds = %omp.loop_nest.region106
  br label %omp.loop_nest.region112

omp.loop_nest.region112:                          ; preds = %omp.loop_nest.region113, %omp.loop_nest.region111
  %16 = phi i64 [ %34, %omp.loop_nest.region113 ], [ 0, %omp.loop_nest.region111 ]
  %17 = icmp slt i64 %16, 128
  br i1 %17, label %omp.loop_nest.region113, label %omp.loop_nest.region114

omp.loop_nest.region114:                          ; preds = %omp.loop_nest.region112
  %18 = add i64 %12, 1
  br label %omp.loop_nest.region104

omp.loop_nest.region113:                          ; preds = %omp.loop_nest.region112
  %19 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %20 = getelementptr float, ptr %19, i32 1048576
  %21 = mul nuw nsw i64 %10, 16384
  %22 = mul nuw nsw i64 %12, 128
  %23 = add nuw nsw i64 %21, %22
  %24 = add nuw nsw i64 %23, %16
  %25 = getelementptr inbounds nuw float, ptr %20, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %28 = getelementptr float, ptr %27, i32 1048576
  %29 = mul nuw nsw i64 %10, 16384
  %30 = mul nuw nsw i64 %12, 128
  %31 = add nuw nsw i64 %29, %30
  %32 = add nuw nsw i64 %31, %16
  %33 = getelementptr inbounds nuw float, ptr %28, i64 %32
  store float %26, ptr %33, align 4
  %34 = add i64 %16, 1
  br label %omp.loop_nest.region112

omp.loop_nest.region107:                          ; preds = %omp.loop_nest.region106
  %35 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %36 = getelementptr float, ptr %35, i32 1048576
  %37 = mul nuw nsw i64 %10, 16384
  %38 = mul nuw nsw i64 %12, 128
  %39 = add nuw nsw i64 %37, %38
  %40 = add nuw nsw i64 %39, %14
  %41 = getelementptr inbounds nuw float, ptr %36, i64 %40
  store float 0.000000e+00, ptr %41, align 4
  br label %omp.loop_nest.region108

omp.loop_nest.region108:                          ; preds = %omp.loop_nest.region109, %omp.loop_nest.region107
  %42 = phi i64 [ %74, %omp.loop_nest.region109 ], [ 0, %omp.loop_nest.region107 ]
  %43 = icmp slt i64 %42, 32
  br i1 %43, label %omp.loop_nest.region109, label %omp.loop_nest.region110

omp.loop_nest.region110:                          ; preds = %omp.loop_nest.region108
  %44 = add i64 %14, 1
  br label %omp.loop_nest.region106

omp.loop_nest.region109:                          ; preds = %omp.loop_nest.region108
  %45 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %46 = getelementptr float, ptr %45, i32 1048576
  %47 = mul nuw nsw i64 %10, 16384
  %48 = mul nuw nsw i64 %12, 128
  %49 = add nuw nsw i64 %47, %48
  %50 = add nuw nsw i64 %49, %14
  %51 = getelementptr inbounds nuw float, ptr %46, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %54 = getelementptr float, ptr %53, i32 1048576
  %55 = mul nuw nsw i64 %10, 16384
  %56 = mul nuw nsw i64 %12, 128
  %57 = add nuw nsw i64 %55, %56
  %58 = add nuw nsw i64 %57, %42
  %59 = getelementptr inbounds nuw float, ptr %54, i64 %58
  %60 = load float, ptr %59, align 4
  %61 = mul nuw nsw i64 %42, 128
  %62 = add nuw nsw i64 %61, %14
  %63 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %62
  %64 = load float, ptr %63, align 4
  %65 = fmul float %60, %64
  %66 = fadd float %52, %65
  %67 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %68 = getelementptr float, ptr %67, i32 1048576
  %69 = mul nuw nsw i64 %10, 16384
  %70 = mul nuw nsw i64 %12, 128
  %71 = add nuw nsw i64 %69, %70
  %72 = add nuw nsw i64 %71, %14
  %73 = getelementptr inbounds nuw float, ptr %68, i64 %72
  store float %66, ptr %73, align 4
  %74 = add i64 %42, 1
  br label %omp.loop_nest.region108

omp.par.exit80.exitStub:                          ; preds = %.fini125
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_doitgen..omp_par.1(ptr noalias %tid.addr23, ptr noalias %zero.addr24, ptr %0) #0 {
omp.par.entry25:
  %gep_.reloaded71 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded71 = load ptr, ptr %gep_.reloaded71, align 8, !align !1
  %gep_.reloaded72 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded72 = load ptr, ptr %gep_.reloaded72, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter65 = alloca i32, align 4
  %p.lowerbound66 = alloca i64, align 8
  %p.upperbound67 = alloca i64, align 8
  %p.stride68 = alloca i64, align 8
  %tid.addr.local29 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr23, align 4
  store i32 %1, ptr %tid.addr.local29, align 4
  %tid30 = load i32, ptr %tid.addr.local29, align 4
  %2 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded71, align 8
  %3 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded72, align 8
  br label %omp.region.after_alloca36

omp.region.after_alloca36:                        ; preds = %omp.par.entry25
  br label %omp.region.after_alloca33

omp.region.after_alloca33:                        ; preds = %omp.region.after_alloca36
  br label %omp.par.region26

omp.par.region26:                                 ; preds = %omp.region.after_alloca33
  br label %omp.par.region35

omp.par.region35:                                 ; preds = %omp.par.region26
  br label %omp.wsloop.region38

omp.wsloop.region38:                              ; preds = %omp.par.region35
  br label %omp_loop.preheader39

omp_loop.preheader39:                             ; preds = %omp.wsloop.region38
  store i64 0, ptr %p.lowerbound66, align 4
  store i64 31, ptr %p.upperbound67, align 4
  store i64 1, ptr %p.stride68, align 4
  %omp_global_thread_num69 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num69, i32 34, ptr %p.lastiter65, ptr %p.lowerbound66, ptr %p.upperbound67, ptr %p.stride68, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound66, align 4
  %5 = load i64, ptr %p.upperbound67, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header40

omp_loop.header40:                                ; preds = %omp_loop.inc43, %omp_loop.preheader39
  %omp_loop.iv46 = phi i64 [ 0, %omp_loop.preheader39 ], [ %omp_loop.next48, %omp_loop.inc43 ]
  br label %omp_loop.cond41

omp_loop.cond41:                                  ; preds = %omp_loop.header40
  %omp_loop.cmp47 = icmp ult i64 %omp_loop.iv46, %7
  br i1 %omp_loop.cmp47, label %omp_loop.body42, label %omp_loop.exit44

omp_loop.exit44:                                  ; preds = %omp_loop.cond41
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num69)
  %omp_global_thread_num70 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num70)
  br label %omp_loop.after45

omp_loop.after45:                                 ; preds = %omp_loop.exit44
  br label %omp.region.cont37

omp.region.cont37:                                ; preds = %omp_loop.after45
  br label %omp.region.cont34

omp.region.cont34:                                ; preds = %omp.region.cont37
  br label %omp.par.pre_finalize27

omp.par.pre_finalize27:                           ; preds = %omp.region.cont34
  br label %.fini73

.fini73:                                          ; preds = %omp.par.pre_finalize27
  br label %omp.par.exit28.exitStub

omp_loop.body42:                                  ; preds = %omp_loop.cond41
  %8 = add i64 %omp_loop.iv46, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region50

omp.loop_nest.region50:                           ; preds = %omp_loop.body42
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region51

omp.loop_nest.region51:                           ; preds = %omp.loop_nest.region50
  br label %omp.loop_nest.region52

omp.loop_nest.region52:                           ; preds = %omp.loop_nest.region62, %omp.loop_nest.region51
  %12 = phi i64 [ %18, %omp.loop_nest.region62 ], [ 0, %omp.loop_nest.region51 ]
  %13 = icmp slt i64 %12, 64
  br i1 %13, label %omp.loop_nest.region53, label %omp.loop_nest.region63

omp.loop_nest.region63:                           ; preds = %omp.loop_nest.region52
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region64

omp.loop_nest.region64:                           ; preds = %omp.loop_nest.region63
  br label %omp.region.cont49

omp.region.cont49:                                ; preds = %omp.loop_nest.region64
  br label %omp_loop.inc43

omp_loop.inc43:                                   ; preds = %omp.region.cont49
  %omp_loop.next48 = add nuw i64 %omp_loop.iv46, 1
  br label %omp_loop.header40

omp.loop_nest.region53:                           ; preds = %omp.loop_nest.region52
  br label %omp.loop_nest.region54

omp.loop_nest.region54:                           ; preds = %omp.loop_nest.region58, %omp.loop_nest.region53
  %14 = phi i64 [ %44, %omp.loop_nest.region58 ], [ 0, %omp.loop_nest.region53 ]
  %15 = icmp slt i64 %14, 32
  br i1 %15, label %omp.loop_nest.region55, label %omp.loop_nest.region59

omp.loop_nest.region59:                           ; preds = %omp.loop_nest.region54
  br label %omp.loop_nest.region60

omp.loop_nest.region60:                           ; preds = %omp.loop_nest.region61, %omp.loop_nest.region59
  %16 = phi i64 [ %34, %omp.loop_nest.region61 ], [ 0, %omp.loop_nest.region59 ]
  %17 = icmp slt i64 %16, 128
  br i1 %17, label %omp.loop_nest.region61, label %omp.loop_nest.region62

omp.loop_nest.region62:                           ; preds = %omp.loop_nest.region60
  %18 = add i64 %12, 1
  br label %omp.loop_nest.region52

omp.loop_nest.region61:                           ; preds = %omp.loop_nest.region60
  %19 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %20 = getelementptr float, ptr %19, i32 524288
  %21 = mul nuw nsw i64 %10, 16384
  %22 = mul nuw nsw i64 %12, 128
  %23 = add nuw nsw i64 %21, %22
  %24 = add nuw nsw i64 %23, %16
  %25 = getelementptr inbounds nuw float, ptr %20, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %28 = getelementptr float, ptr %27, i32 524288
  %29 = mul nuw nsw i64 %10, 16384
  %30 = mul nuw nsw i64 %12, 128
  %31 = add nuw nsw i64 %29, %30
  %32 = add nuw nsw i64 %31, %16
  %33 = getelementptr inbounds nuw float, ptr %28, i64 %32
  store float %26, ptr %33, align 4
  %34 = add i64 %16, 1
  br label %omp.loop_nest.region60

omp.loop_nest.region55:                           ; preds = %omp.loop_nest.region54
  %35 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %36 = getelementptr float, ptr %35, i32 524288
  %37 = mul nuw nsw i64 %10, 16384
  %38 = mul nuw nsw i64 %12, 128
  %39 = add nuw nsw i64 %37, %38
  %40 = add nuw nsw i64 %39, %14
  %41 = getelementptr inbounds nuw float, ptr %36, i64 %40
  store float 0.000000e+00, ptr %41, align 4
  br label %omp.loop_nest.region56

omp.loop_nest.region56:                           ; preds = %omp.loop_nest.region57, %omp.loop_nest.region55
  %42 = phi i64 [ %74, %omp.loop_nest.region57 ], [ 0, %omp.loop_nest.region55 ]
  %43 = icmp slt i64 %42, 32
  br i1 %43, label %omp.loop_nest.region57, label %omp.loop_nest.region58

omp.loop_nest.region58:                           ; preds = %omp.loop_nest.region56
  %44 = add i64 %14, 1
  br label %omp.loop_nest.region54

omp.loop_nest.region57:                           ; preds = %omp.loop_nest.region56
  %45 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %46 = getelementptr float, ptr %45, i32 524288
  %47 = mul nuw nsw i64 %10, 16384
  %48 = mul nuw nsw i64 %12, 128
  %49 = add nuw nsw i64 %47, %48
  %50 = add nuw nsw i64 %49, %14
  %51 = getelementptr inbounds nuw float, ptr %46, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %54 = getelementptr float, ptr %53, i32 524288
  %55 = mul nuw nsw i64 %10, 16384
  %56 = mul nuw nsw i64 %12, 128
  %57 = add nuw nsw i64 %55, %56
  %58 = add nuw nsw i64 %57, %42
  %59 = getelementptr inbounds nuw float, ptr %54, i64 %58
  %60 = load float, ptr %59, align 4
  %61 = mul nuw nsw i64 %42, 128
  %62 = add nuw nsw i64 %61, %14
  %63 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %62
  %64 = load float, ptr %63, align 4
  %65 = fmul float %60, %64
  %66 = fadd float %52, %65
  %67 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %68 = getelementptr float, ptr %67, i32 524288
  %69 = mul nuw nsw i64 %10, 16384
  %70 = mul nuw nsw i64 %12, 128
  %71 = add nuw nsw i64 %69, %70
  %72 = add nuw nsw i64 %71, %14
  %73 = getelementptr inbounds nuw float, ptr %68, i64 %72
  store float %66, ptr %73, align 4
  %74 = add i64 %42, 1
  br label %omp.loop_nest.region56

omp.par.exit28.exitStub:                          ; preds = %.fini73
  ret void
}

; Function Attrs: nounwind
define internal void @kernel_doitgen..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded21 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded21 = load ptr, ptr %gep_.reloaded21, align 8, !align !1
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
  %2 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load { ptr, ptr, i64, [3 x i64], [3 x i64] }, ptr %loadgep_.reloaded21, align 8
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
  %omp_global_thread_num19 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num19, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
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
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num19)
  %omp_global_thread_num20 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num20)
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

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region16, %omp.loop_nest.region5
  %12 = phi i64 [ %18, %omp.loop_nest.region16 ], [ 0, %omp.loop_nest.region5 ]
  %13 = icmp slt i64 %12, 64
  br i1 %13, label %omp.loop_nest.region7, label %omp.loop_nest.region17

omp.loop_nest.region17:                           ; preds = %omp.loop_nest.region6
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region18

omp.loop_nest.region18:                           ; preds = %omp.loop_nest.region17
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region18
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.loop_nest.region7:                            ; preds = %omp.loop_nest.region6
  br label %omp.loop_nest.region8

omp.loop_nest.region8:                            ; preds = %omp.loop_nest.region12, %omp.loop_nest.region7
  %14 = phi i64 [ %41, %omp.loop_nest.region12 ], [ 0, %omp.loop_nest.region7 ]
  %15 = icmp slt i64 %14, 32
  br i1 %15, label %omp.loop_nest.region9, label %omp.loop_nest.region13

omp.loop_nest.region13:                           ; preds = %omp.loop_nest.region8
  br label %omp.loop_nest.region14

omp.loop_nest.region14:                           ; preds = %omp.loop_nest.region15, %omp.loop_nest.region13
  %16 = phi i64 [ %32, %omp.loop_nest.region15 ], [ 0, %omp.loop_nest.region13 ]
  %17 = icmp slt i64 %16, 128
  br i1 %17, label %omp.loop_nest.region15, label %omp.loop_nest.region16

omp.loop_nest.region16:                           ; preds = %omp.loop_nest.region14
  %18 = add i64 %12, 1
  br label %omp.loop_nest.region6

omp.loop_nest.region15:                           ; preds = %omp.loop_nest.region14
  %19 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %20 = mul nuw nsw i64 %10, 16384
  %21 = mul nuw nsw i64 %12, 128
  %22 = add nuw nsw i64 %20, %21
  %23 = add nuw nsw i64 %22, %16
  %24 = getelementptr inbounds nuw float, ptr %19, i64 %23
  %25 = load float, ptr %24, align 4
  %26 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %27 = mul nuw nsw i64 %10, 16384
  %28 = mul nuw nsw i64 %12, 128
  %29 = add nuw nsw i64 %27, %28
  %30 = add nuw nsw i64 %29, %16
  %31 = getelementptr inbounds nuw float, ptr %26, i64 %30
  store float %25, ptr %31, align 4
  %32 = add i64 %16, 1
  br label %omp.loop_nest.region14

omp.loop_nest.region9:                            ; preds = %omp.loop_nest.region8
  %33 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %34 = mul nuw nsw i64 %10, 16384
  %35 = mul nuw nsw i64 %12, 128
  %36 = add nuw nsw i64 %34, %35
  %37 = add nuw nsw i64 %36, %14
  %38 = getelementptr inbounds nuw float, ptr %33, i64 %37
  store float 0.000000e+00, ptr %38, align 4
  br label %omp.loop_nest.region10

omp.loop_nest.region10:                           ; preds = %omp.loop_nest.region11, %omp.loop_nest.region9
  %39 = phi i64 [ %68, %omp.loop_nest.region11 ], [ 0, %omp.loop_nest.region9 ]
  %40 = icmp slt i64 %39, 32
  br i1 %40, label %omp.loop_nest.region11, label %omp.loop_nest.region12

omp.loop_nest.region12:                           ; preds = %omp.loop_nest.region10
  %41 = add i64 %14, 1
  br label %omp.loop_nest.region8

omp.loop_nest.region11:                           ; preds = %omp.loop_nest.region10
  %42 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %43 = mul nuw nsw i64 %10, 16384
  %44 = mul nuw nsw i64 %12, 128
  %45 = add nuw nsw i64 %43, %44
  %46 = add nuw nsw i64 %45, %14
  %47 = getelementptr inbounds nuw float, ptr %42, i64 %46
  %48 = load float, ptr %47, align 4
  %49 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %3, 1
  %50 = mul nuw nsw i64 %10, 16384
  %51 = mul nuw nsw i64 %12, 128
  %52 = add nuw nsw i64 %50, %51
  %53 = add nuw nsw i64 %52, %39
  %54 = getelementptr inbounds nuw float, ptr %49, i64 %53
  %55 = load float, ptr %54, align 4
  %56 = mul nuw nsw i64 %39, 128
  %57 = add nuw nsw i64 %56, %14
  %58 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %57
  %59 = load float, ptr %58, align 4
  %60 = fmul float %55, %59
  %61 = fadd float %48, %60
  %62 = extractvalue { ptr, ptr, i64, [3 x i64], [3 x i64] } %2, 1
  %63 = mul nuw nsw i64 %10, 16384
  %64 = mul nuw nsw i64 %12, 128
  %65 = add nuw nsw i64 %63, %64
  %66 = add nuw nsw i64 %65, %14
  %67 = getelementptr inbounds nuw float, ptr %62, i64 %66
  store float %61, ptr %67, align 4
  %68 = add i64 %39, 1
  br label %omp.loop_nest.region10

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
