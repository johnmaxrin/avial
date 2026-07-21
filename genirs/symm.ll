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

56:                                               ; preds = %122, %25
  %57 = phi i64 [ %123, %122 ], [ 0, %25 ]
  %58 = icmp slt i64 %57, 1000
  br i1 %58, label %59, label %124

59:                                               ; preds = %56
  br label %60

60:                                               ; preds = %99, %59
  %61 = phi i64 [ %121, %99 ], [ 0, %59 ]
  %62 = icmp slt i64 %61, 1000
  br i1 %62, label %63, label %122

63:                                               ; preds = %60
  %64 = add i64 %61, -1
  br label %65

65:                                               ; preds = %69, %63
  %66 = phi i64 [ %98, %69 ], [ 0, %63 ]
  %67 = phi float [ %97, %69 ], [ 0.000000e+00, %63 ]
  %68 = icmp slt i64 %66, %64
  br i1 %68, label %69, label %99

69:                                               ; preds = %65
  %70 = mul nuw nsw i64 %66, 1000
  %71 = add nuw nsw i64 %70, %57
  %72 = getelementptr inbounds nuw float, ptr %12, i64 %71
  %73 = load float, ptr %72, align 4
  %74 = fmul float %2, %73
  %75 = mul nuw nsw i64 %57, 1000
  %76 = add nuw nsw i64 %75, %61
  %77 = getelementptr inbounds nuw float, ptr %19, i64 %76
  %78 = load float, ptr %77, align 4
  %79 = fmul float %74, %78
  %80 = mul nuw nsw i64 %66, 1000
  %81 = add nuw nsw i64 %80, %61
  %82 = getelementptr inbounds nuw float, ptr %5, i64 %81
  %83 = load float, ptr %82, align 4
  %84 = fadd float %83, %79
  %85 = mul nuw nsw i64 %66, 1000
  %86 = add nuw nsw i64 %85, %61
  %87 = getelementptr inbounds nuw float, ptr %5, i64 %86
  store float %84, ptr %87, align 4
  %88 = mul nuw nsw i64 %66, 1000
  %89 = add nuw nsw i64 %88, %61
  %90 = getelementptr inbounds nuw float, ptr %19, i64 %89
  %91 = load float, ptr %90, align 4
  %92 = mul nuw nsw i64 %66, 1000
  %93 = add nuw nsw i64 %92, %57
  %94 = getelementptr inbounds nuw float, ptr %12, i64 %93
  %95 = load float, ptr %94, align 4
  %96 = fmul float %91, %95
  %97 = fadd float %67, %96
  %98 = add i64 %66, 1
  br label %65

99:                                               ; preds = %65
  %100 = mul nuw nsw i64 %57, 1000
  %101 = add nuw nsw i64 %100, %61
  %102 = getelementptr inbounds nuw float, ptr %5, i64 %101
  %103 = load float, ptr %102, align 4
  %104 = fmul float %3, %103
  %105 = mul nuw nsw i64 %57, 1000
  %106 = add nuw nsw i64 %105, %57
  %107 = getelementptr inbounds nuw float, ptr %12, i64 %106
  %108 = load float, ptr %107, align 4
  %109 = fmul float %2, %108
  %110 = mul nuw nsw i64 %57, 1000
  %111 = add nuw nsw i64 %110, %61
  %112 = getelementptr inbounds nuw float, ptr %19, i64 %111
  %113 = load float, ptr %112, align 4
  %114 = fmul float %109, %113
  %115 = fadd float %104, %114
  %116 = fmul float %2, %67
  %117 = fadd float %115, %116
  %118 = mul nuw nsw i64 %57, 1000
  %119 = add nuw nsw i64 %118, %61
  %120 = getelementptr inbounds nuw float, ptr %5, i64 %119
  store float %117, ptr %120, align 4
  %121 = add i64 %61, 1
  br label %60

122:                                              ; preds = %60
  %123 = add i64 %57, 1
  br label %56

124:                                              ; preds = %56
  %125 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
