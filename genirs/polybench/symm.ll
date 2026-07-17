; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@arch_str_3 = internal constant [7 x i8] c"x86_64\00"
@node_str_3 = internal constant [6 x i8] c"node3\00"
@arch_str_2 = internal constant [7 x i8] c"x86_64\00"
@node_str_2 = internal constant [6 x i8] c"node2\00"
@arch_str_1 = internal constant [7 x i8] c"x86_64\00"
@node_str_1 = internal constant [6 x i8] c"node1\00"
@arch_str_0 = internal constant [7 x i8] c"x86_64\00"
@node_str_0 = internal constant [6 x i8] c"node0\00"

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Init(ptr, ptr)

declare ptr @malloc(i64)

declare void @buildRankNodeMaps(ptr, ptr, ptr)

define void @kernel_symm(i32 %0, i32 %1, float %2, float %3, ptr %4, ptr %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, ptr %11, ptr %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17, ptr %18, ptr %19, i64 %20, i64 %21, i64 %22, i64 %23, i64 %24) {
  %26 = call i32 @MPI_Init(ptr null, ptr null)
  %27 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %28 = getelementptr { ptr, ptr, i32, float }, ptr %27, i32 0, i32 0
  %29 = getelementptr { ptr, ptr, i32, float }, ptr %27, i32 0, i32 1
  %30 = getelementptr { ptr, ptr, i32, float }, ptr %27, i32 0, i32 2
  %31 = getelementptr { ptr, ptr, i32, float }, ptr %27, i32 0, i32 3
  store ptr @node_str_0, ptr %28, align 8
  store ptr @arch_str_0, ptr %29, align 8
  store i32 0, ptr %30, align 4
  store float 1.000000e+00, ptr %31, align 4
  %32 = getelementptr { ptr, ptr, i32, float }, ptr %27, i32 1
  %33 = getelementptr { ptr, ptr, i32, float }, ptr %32, i32 0, i32 0
  %34 = getelementptr { ptr, ptr, i32, float }, ptr %32, i32 0, i32 1
  %35 = getelementptr { ptr, ptr, i32, float }, ptr %32, i32 0, i32 2
  %36 = getelementptr { ptr, ptr, i32, float }, ptr %32, i32 0, i32 3
  store ptr @node_str_1, ptr %33, align 8
  store ptr @arch_str_1, ptr %34, align 8
  store i32 0, ptr %35, align 4
  store float 1.000000e+00, ptr %36, align 4
  %37 = getelementptr { ptr, ptr, i32, float }, ptr %27, i32 2
  %38 = getelementptr { ptr, ptr, i32, float }, ptr %37, i32 0, i32 0
  %39 = getelementptr { ptr, ptr, i32, float }, ptr %37, i32 0, i32 1
  %40 = getelementptr { ptr, ptr, i32, float }, ptr %37, i32 0, i32 2
  %41 = getelementptr { ptr, ptr, i32, float }, ptr %37, i32 0, i32 3
  store ptr @node_str_2, ptr %38, align 8
  store ptr @arch_str_2, ptr %39, align 8
  store i32 0, ptr %40, align 4
  store float 1.000000e+00, ptr %41, align 4
  %42 = getelementptr { ptr, ptr, i32, float }, ptr %27, i32 3
  %43 = getelementptr { ptr, ptr, i32, float }, ptr %42, i32 0, i32 0
  %44 = getelementptr { ptr, ptr, i32, float }, ptr %42, i32 0, i32 1
  %45 = getelementptr { ptr, ptr, i32, float }, ptr %42, i32 0, i32 2
  %46 = getelementptr { ptr, ptr, i32, float }, ptr %42, i32 0, i32 3
  store ptr @node_str_3, ptr %43, align 8
  store ptr @arch_str_3, ptr %44, align 8
  store i32 0, ptr %45, align 4
  store float 1.000000e+00, ptr %46, align 4
  %47 = alloca { i32, ptr }, i64 1, align 8
  %48 = getelementptr { i32, ptr }, ptr %47, i32 0, i32 0
  %49 = getelementptr { i32, ptr }, ptr %47, i32 0, i32 1
  store i32 4, ptr %48, align 4
  store ptr %27, ptr %49, align 8
  %50 = call ptr @malloc(i64 16)
  %51 = call ptr @malloc(i64 16)
  %52 = ptrtoint ptr %50 to i64
  %53 = ptrtoint ptr %51 to i64
  %54 = inttoptr i64 %52 to ptr
  %55 = inttoptr i64 %53 to ptr
  call void @buildRankNodeMaps(ptr %47, ptr %54, ptr %55)
  br label %56

56:                                               ; preds = %121, %25
  %57 = phi i64 [ %122, %121 ], [ 0, %25 ]
  %58 = icmp slt i64 %57, 1000
  br i1 %58, label %59, label %123

59:                                               ; preds = %56
  br label %60

60:                                               ; preds = %98, %59
  %61 = phi i64 [ %120, %98 ], [ 0, %59 ]
  %62 = icmp slt i64 %61, 1000
  br i1 %62, label %63, label %121

63:                                               ; preds = %60
  br label %64

64:                                               ; preds = %68, %63
  %65 = phi i64 [ %97, %68 ], [ 0, %63 ]
  %66 = phi float [ %96, %68 ], [ 0.000000e+00, %63 ]
  %67 = icmp slt i64 %65, %57
  br i1 %67, label %68, label %98

68:                                               ; preds = %64
  %69 = mul nuw nsw i64 %65, 1000
  %70 = add nuw nsw i64 %69, %57
  %71 = getelementptr inbounds nuw float, ptr %12, i64 %70
  %72 = load float, ptr %71, align 4
  %73 = fmul float %2, %72
  %74 = mul nuw nsw i64 %57, 1000
  %75 = add nuw nsw i64 %74, %61
  %76 = getelementptr inbounds nuw float, ptr %19, i64 %75
  %77 = load float, ptr %76, align 4
  %78 = fmul float %73, %77
  %79 = mul nuw nsw i64 %65, 1000
  %80 = add nuw nsw i64 %79, %61
  %81 = getelementptr inbounds nuw float, ptr %5, i64 %80
  %82 = load float, ptr %81, align 4
  %83 = fadd float %82, %78
  %84 = mul nuw nsw i64 %65, 1000
  %85 = add nuw nsw i64 %84, %61
  %86 = getelementptr inbounds nuw float, ptr %5, i64 %85
  store float %83, ptr %86, align 4
  %87 = mul nuw nsw i64 %65, 1000
  %88 = add nuw nsw i64 %87, %61
  %89 = getelementptr inbounds nuw float, ptr %19, i64 %88
  %90 = load float, ptr %89, align 4
  %91 = mul nuw nsw i64 %65, 1000
  %92 = add nuw nsw i64 %91, %57
  %93 = getelementptr inbounds nuw float, ptr %12, i64 %92
  %94 = load float, ptr %93, align 4
  %95 = fmul float %90, %94
  %96 = fadd float %66, %95
  %97 = add i64 %65, 1
  br label %64

98:                                               ; preds = %64
  %99 = mul nuw nsw i64 %57, 1000
  %100 = add nuw nsw i64 %99, %61
  %101 = getelementptr inbounds nuw float, ptr %5, i64 %100
  %102 = load float, ptr %101, align 4
  %103 = fmul float %3, %102
  %104 = mul nuw nsw i64 %57, 1000
  %105 = add nuw nsw i64 %104, %57
  %106 = getelementptr inbounds nuw float, ptr %12, i64 %105
  %107 = load float, ptr %106, align 4
  %108 = fmul float %2, %107
  %109 = mul nuw nsw i64 %57, 1000
  %110 = add nuw nsw i64 %109, %61
  %111 = getelementptr inbounds nuw float, ptr %19, i64 %110
  %112 = load float, ptr %111, align 4
  %113 = fmul float %108, %112
  %114 = fadd float %103, %113
  %115 = fmul float %2, %66
  %116 = fadd float %114, %115
  %117 = mul nuw nsw i64 %57, 1000
  %118 = add nuw nsw i64 %117, %61
  %119 = getelementptr inbounds nuw float, ptr %5, i64 %118
  store float %116, ptr %119, align 4
  %120 = add i64 %61, 1
  br label %60

121:                                              ; preds = %60
  %122 = add i64 %57, 1
  br label %56

123:                                              ; preds = %56
  %124 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
