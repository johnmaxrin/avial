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

define void @kernel_trisolv(i32 %0, ptr %1, ptr %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, ptr %8, ptr %9, i64 %10, i64 %11, i64 %12, ptr %13, ptr %14, i64 %15, i64 %16, i64 %17) {
  %19 = call i32 @MPI_Init(ptr null, ptr null)
  %20 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %21 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 0
  %22 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 1
  %23 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 2
  %24 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 3
  store ptr @node_str_0, ptr %21, align 8
  store ptr @arch_str_0, ptr %22, align 8
  store i32 0, ptr %23, align 4
  store float 1.000000e+00, ptr %24, align 4
  %25 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 1
  %26 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 0
  %27 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 1
  %28 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 2
  %29 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 3
  store ptr @node_str_1, ptr %26, align 8
  store ptr @arch_str_1, ptr %27, align 8
  store i32 0, ptr %28, align 4
  store float 1.000000e+00, ptr %29, align 4
  %30 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 2
  %31 = getelementptr { ptr, ptr, i32, float }, ptr %30, i32 0, i32 0
  %32 = getelementptr { ptr, ptr, i32, float }, ptr %30, i32 0, i32 1
  %33 = getelementptr { ptr, ptr, i32, float }, ptr %30, i32 0, i32 2
  %34 = getelementptr { ptr, ptr, i32, float }, ptr %30, i32 0, i32 3
  store ptr @node_str_2, ptr %31, align 8
  store ptr @arch_str_2, ptr %32, align 8
  store i32 0, ptr %33, align 4
  store float 1.000000e+00, ptr %34, align 4
  %35 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 3
  %36 = getelementptr { ptr, ptr, i32, float }, ptr %35, i32 0, i32 0
  %37 = getelementptr { ptr, ptr, i32, float }, ptr %35, i32 0, i32 1
  %38 = getelementptr { ptr, ptr, i32, float }, ptr %35, i32 0, i32 2
  %39 = getelementptr { ptr, ptr, i32, float }, ptr %35, i32 0, i32 3
  store ptr @node_str_3, ptr %36, align 8
  store ptr @arch_str_3, ptr %37, align 8
  store i32 0, ptr %38, align 4
  store float 1.000000e+00, ptr %39, align 4
  %40 = alloca { i32, ptr }, i64 1, align 8
  %41 = getelementptr { i32, ptr }, ptr %40, i32 0, i32 0
  %42 = getelementptr { i32, ptr }, ptr %40, i32 0, i32 1
  store i32 4, ptr %41, align 4
  store ptr %20, ptr %42, align 8
  %43 = call ptr @malloc(i64 16)
  %44 = call ptr @malloc(i64 16)
  %45 = ptrtoint ptr %43 to i64
  %46 = ptrtoint ptr %44 to i64
  %47 = inttoptr i64 %45 to ptr
  %48 = inttoptr i64 %46 to ptr
  call void @buildRankNodeMaps(ptr %40, ptr %47, ptr %48)
  br label %49

49:                                               ; preds = %72, %18
  %50 = phi i64 [ %81, %72 ], [ 0, %18 ]
  %51 = icmp slt i64 %50, 1000
  br i1 %51, label %52, label %82

52:                                               ; preds = %49
  %53 = getelementptr inbounds nuw float, ptr %14, i64 %50
  %54 = load float, ptr %53, align 4
  %55 = getelementptr inbounds nuw float, ptr %9, i64 %50
  store float %54, ptr %55, align 4
  br label %56

56:                                               ; preds = %59, %52
  %57 = phi i64 [ %71, %59 ], [ 0, %52 ]
  %58 = icmp slt i64 %57, %50
  br i1 %58, label %59, label %72

59:                                               ; preds = %56
  %60 = getelementptr inbounds nuw float, ptr %9, i64 %50
  %61 = load float, ptr %60, align 4
  %62 = mul nuw nsw i64 %50, 1000
  %63 = add nuw nsw i64 %62, %57
  %64 = getelementptr inbounds nuw float, ptr %2, i64 %63
  %65 = load float, ptr %64, align 4
  %66 = getelementptr inbounds nuw float, ptr %9, i64 %57
  %67 = load float, ptr %66, align 4
  %68 = fmul float %65, %67
  %69 = fsub float %61, %68
  %70 = getelementptr inbounds nuw float, ptr %9, i64 %50
  store float %69, ptr %70, align 4
  %71 = add i64 %57, 1
  br label %56

72:                                               ; preds = %56
  %73 = getelementptr inbounds nuw float, ptr %9, i64 %50
  %74 = load float, ptr %73, align 4
  %75 = mul nuw nsw i64 %50, 1000
  %76 = add nuw nsw i64 %75, %50
  %77 = getelementptr inbounds nuw float, ptr %2, i64 %76
  %78 = load float, ptr %77, align 4
  %79 = fdiv float %74, %78
  %80 = getelementptr inbounds nuw float, ptr %9, i64 %50
  store float %79, ptr %80, align 4
  %81 = add i64 %50, 1
  br label %49

82:                                               ; preds = %49
  %83 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
