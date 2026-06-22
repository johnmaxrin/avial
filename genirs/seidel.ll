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

define void @kernel_seidel_2d(i32 %0, i32 %1, ptr %2, ptr %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8) {
  %10 = call i32 @MPI_Init(ptr null, ptr null)
  %11 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %12 = getelementptr { ptr, ptr, i32, float }, ptr %11, i32 0, i32 0
  %13 = getelementptr { ptr, ptr, i32, float }, ptr %11, i32 0, i32 1
  %14 = getelementptr { ptr, ptr, i32, float }, ptr %11, i32 0, i32 2
  %15 = getelementptr { ptr, ptr, i32, float }, ptr %11, i32 0, i32 3
  store ptr @node_str_0, ptr %12, align 8
  store ptr @arch_str_0, ptr %13, align 8
  store i32 0, ptr %14, align 4
  store float 1.000000e+00, ptr %15, align 4
  %16 = getelementptr { ptr, ptr, i32, float }, ptr %11, i32 1
  %17 = getelementptr { ptr, ptr, i32, float }, ptr %16, i32 0, i32 0
  %18 = getelementptr { ptr, ptr, i32, float }, ptr %16, i32 0, i32 1
  %19 = getelementptr { ptr, ptr, i32, float }, ptr %16, i32 0, i32 2
  %20 = getelementptr { ptr, ptr, i32, float }, ptr %16, i32 0, i32 3
  store ptr @node_str_1, ptr %17, align 8
  store ptr @arch_str_1, ptr %18, align 8
  store i32 0, ptr %19, align 4
  store float 1.000000e+00, ptr %20, align 4
  %21 = getelementptr { ptr, ptr, i32, float }, ptr %11, i32 2
  %22 = getelementptr { ptr, ptr, i32, float }, ptr %21, i32 0, i32 0
  %23 = getelementptr { ptr, ptr, i32, float }, ptr %21, i32 0, i32 1
  %24 = getelementptr { ptr, ptr, i32, float }, ptr %21, i32 0, i32 2
  %25 = getelementptr { ptr, ptr, i32, float }, ptr %21, i32 0, i32 3
  store ptr @node_str_2, ptr %22, align 8
  store ptr @arch_str_2, ptr %23, align 8
  store i32 0, ptr %24, align 4
  store float 1.000000e+00, ptr %25, align 4
  %26 = getelementptr { ptr, ptr, i32, float }, ptr %11, i32 3
  %27 = getelementptr { ptr, ptr, i32, float }, ptr %26, i32 0, i32 0
  %28 = getelementptr { ptr, ptr, i32, float }, ptr %26, i32 0, i32 1
  %29 = getelementptr { ptr, ptr, i32, float }, ptr %26, i32 0, i32 2
  %30 = getelementptr { ptr, ptr, i32, float }, ptr %26, i32 0, i32 3
  store ptr @node_str_3, ptr %27, align 8
  store ptr @arch_str_3, ptr %28, align 8
  store i32 0, ptr %29, align 4
  store float 1.000000e+00, ptr %30, align 4
  %31 = alloca { i32, ptr }, i64 1, align 8
  %32 = getelementptr { i32, ptr }, ptr %31, i32 0, i32 0
  %33 = getelementptr { i32, ptr }, ptr %31, i32 0, i32 1
  store i32 4, ptr %32, align 4
  store ptr %11, ptr %33, align 8
  %34 = call ptr @malloc(i64 16)
  %35 = call ptr @malloc(i64 16)
  %36 = ptrtoint ptr %34 to i64
  %37 = ptrtoint ptr %35 to i64
  %38 = inttoptr i64 %36 to ptr
  %39 = inttoptr i64 %37 to ptr
  call void @buildRankNodeMaps(ptr %31, ptr %38, ptr %39)
  br label %40

40:                                               ; preds = %117, %9
  %41 = phi i64 [ %118, %117 ], [ 0, %9 ]
  %42 = icmp slt i64 %41, 20
  br i1 %42, label %43, label %119

43:                                               ; preds = %40
  br label %44

44:                                               ; preds = %115, %43
  %45 = phi i64 [ %116, %115 ], [ 1, %43 ]
  %46 = icmp slt i64 %45, 127
  br i1 %46, label %47, label %117

47:                                               ; preds = %44
  br label %48

48:                                               ; preds = %51, %47
  %49 = phi i64 [ %114, %51 ], [ 1, %47 ]
  %50 = icmp slt i64 %49, 127
  br i1 %50, label %51, label %115

51:                                               ; preds = %48
  %52 = add i64 %45, -1
  %53 = add i64 %49, -1
  %54 = mul nuw nsw i64 %52, 128
  %55 = add nuw nsw i64 %54, %53
  %56 = getelementptr inbounds nuw float, ptr %3, i64 %55
  %57 = load float, ptr %56, align 4
  %58 = add i64 %45, -1
  %59 = mul nuw nsw i64 %58, 128
  %60 = add nuw nsw i64 %59, %49
  %61 = getelementptr inbounds nuw float, ptr %3, i64 %60
  %62 = load float, ptr %61, align 4
  %63 = fadd float %57, %62
  %64 = add i64 %45, -1
  %65 = add i64 %49, 1
  %66 = mul nuw nsw i64 %64, 128
  %67 = add nuw nsw i64 %66, %65
  %68 = getelementptr inbounds nuw float, ptr %3, i64 %67
  %69 = load float, ptr %68, align 4
  %70 = fadd float %63, %69
  %71 = add i64 %49, -1
  %72 = mul nuw nsw i64 %45, 128
  %73 = add nuw nsw i64 %72, %71
  %74 = getelementptr inbounds nuw float, ptr %3, i64 %73
  %75 = load float, ptr %74, align 4
  %76 = fadd float %70, %75
  %77 = mul nuw nsw i64 %45, 128
  %78 = add nuw nsw i64 %77, %49
  %79 = getelementptr inbounds nuw float, ptr %3, i64 %78
  %80 = load float, ptr %79, align 4
  %81 = fadd float %76, %80
  %82 = add i64 %49, 1
  %83 = mul nuw nsw i64 %45, 128
  %84 = add nuw nsw i64 %83, %82
  %85 = getelementptr inbounds nuw float, ptr %3, i64 %84
  %86 = load float, ptr %85, align 4
  %87 = fadd float %81, %86
  %88 = add i64 %45, 1
  %89 = add i64 %49, -1
  %90 = mul nuw nsw i64 %88, 128
  %91 = add nuw nsw i64 %90, %89
  %92 = getelementptr inbounds nuw float, ptr %3, i64 %91
  %93 = load float, ptr %92, align 4
  %94 = fadd float %87, %93
  %95 = add i64 %45, 1
  %96 = mul nuw nsw i64 %95, 128
  %97 = add nuw nsw i64 %96, %49
  %98 = getelementptr inbounds nuw float, ptr %3, i64 %97
  %99 = load float, ptr %98, align 4
  %100 = fadd float %94, %99
  %101 = add i64 %45, 1
  %102 = add i64 %49, 1
  %103 = mul nuw nsw i64 %101, 128
  %104 = add nuw nsw i64 %103, %102
  %105 = getelementptr inbounds nuw float, ptr %3, i64 %104
  %106 = load float, ptr %105, align 4
  %107 = fadd float %100, %106
  %108 = fpext float %107 to double
  %109 = fdiv double %108, 9.000000e+00
  %110 = fptrunc double %109 to float
  %111 = mul nuw nsw i64 %45, 128
  %112 = add nuw nsw i64 %111, %49
  %113 = getelementptr inbounds nuw float, ptr %3, i64 %112
  store float %110, ptr %113, align 4
  %114 = add i64 %49, 1
  br label %48

115:                                              ; preds = %48
  %116 = add i64 %45, 1
  br label %44

117:                                              ; preds = %44
  %118 = add i64 %41, 1
  br label %40

119:                                              ; preds = %40
  %120 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
