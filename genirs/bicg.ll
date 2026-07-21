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

define void @kernel_bicg(i32 %0, i32 %1, ptr %2, ptr %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, ptr %19, ptr %20, i64 %21, i64 %22, i64 %23, ptr %24, ptr %25, i64 %26, i64 %27, i64 %28) {
  %30 = call i32 @MPI_Init(ptr null, ptr null)
  %31 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %32 = getelementptr { ptr, ptr, i32, float }, ptr %31, i32 0, i32 0
  %33 = getelementptr { ptr, ptr, i32, float }, ptr %31, i32 0, i32 1
  %34 = getelementptr { ptr, ptr, i32, float }, ptr %31, i32 0, i32 2
  %35 = getelementptr { ptr, ptr, i32, float }, ptr %31, i32 0, i32 3
  store ptr @node_str_0, ptr %32, align 8
  store ptr @arch_str_0, ptr %33, align 8
  store i32 0, ptr %34, align 4
  store float 1.000000e+00, ptr %35, align 4
  %36 = getelementptr { ptr, ptr, i32, float }, ptr %31, i32 1
  %37 = getelementptr { ptr, ptr, i32, float }, ptr %36, i32 0, i32 0
  %38 = getelementptr { ptr, ptr, i32, float }, ptr %36, i32 0, i32 1
  %39 = getelementptr { ptr, ptr, i32, float }, ptr %36, i32 0, i32 2
  %40 = getelementptr { ptr, ptr, i32, float }, ptr %36, i32 0, i32 3
  store ptr @node_str_1, ptr %37, align 8
  store ptr @arch_str_1, ptr %38, align 8
  store i32 0, ptr %39, align 4
  store float 1.000000e+00, ptr %40, align 4
  %41 = getelementptr { ptr, ptr, i32, float }, ptr %31, i32 2
  %42 = getelementptr { ptr, ptr, i32, float }, ptr %41, i32 0, i32 0
  %43 = getelementptr { ptr, ptr, i32, float }, ptr %41, i32 0, i32 1
  %44 = getelementptr { ptr, ptr, i32, float }, ptr %41, i32 0, i32 2
  %45 = getelementptr { ptr, ptr, i32, float }, ptr %41, i32 0, i32 3
  store ptr @node_str_2, ptr %42, align 8
  store ptr @arch_str_2, ptr %43, align 8
  store i32 0, ptr %44, align 4
  store float 1.000000e+00, ptr %45, align 4
  %46 = getelementptr { ptr, ptr, i32, float }, ptr %31, i32 3
  %47 = getelementptr { ptr, ptr, i32, float }, ptr %46, i32 0, i32 0
  %48 = getelementptr { ptr, ptr, i32, float }, ptr %46, i32 0, i32 1
  %49 = getelementptr { ptr, ptr, i32, float }, ptr %46, i32 0, i32 2
  %50 = getelementptr { ptr, ptr, i32, float }, ptr %46, i32 0, i32 3
  store ptr @node_str_3, ptr %47, align 8
  store ptr @arch_str_3, ptr %48, align 8
  store i32 0, ptr %49, align 4
  store float 1.000000e+00, ptr %50, align 4
  %51 = alloca { i32, ptr }, i64 1, align 8
  %52 = getelementptr { i32, ptr }, ptr %51, i32 0, i32 0
  %53 = getelementptr { i32, ptr }, ptr %51, i32 0, i32 1
  store i32 4, ptr %52, align 4
  store ptr %31, ptr %53, align 8
  %54 = call ptr @malloc(i64 16)
  %55 = call ptr @malloc(i64 16)
  %56 = ptrtoint ptr %54 to i64
  %57 = ptrtoint ptr %55 to i64
  %58 = inttoptr i64 %56 to ptr
  %59 = inttoptr i64 %57 to ptr
  call void @buildRankNodeMaps(ptr %51, ptr %58, ptr %59)
  br label %60

60:                                               ; preds = %92, %29
  %61 = phi i64 [ %93, %92 ], [ 0, %29 ]
  %62 = icmp slt i64 %61, 1000
  br i1 %62, label %63, label %94

63:                                               ; preds = %60
  %64 = getelementptr inbounds nuw float, ptr %15, i64 %61
  store float 0.000000e+00, ptr %64, align 4
  br label %65

65:                                               ; preds = %68, %63
  %66 = phi i64 [ %91, %68 ], [ 0, %63 ]
  %67 = icmp slt i64 %66, 1000
  br i1 %67, label %68, label %92

68:                                               ; preds = %65
  %69 = getelementptr inbounds nuw float, ptr %10, i64 %66
  %70 = load float, ptr %69, align 4
  %71 = getelementptr inbounds nuw float, ptr %25, i64 %61
  %72 = load float, ptr %71, align 4
  %73 = mul nuw nsw i64 %61, 1000
  %74 = add nuw nsw i64 %73, %66
  %75 = getelementptr inbounds nuw float, ptr %3, i64 %74
  %76 = load float, ptr %75, align 4
  %77 = fmul float %72, %76
  %78 = fadd float %70, %77
  %79 = getelementptr inbounds nuw float, ptr %10, i64 %66
  store float %78, ptr %79, align 4
  %80 = getelementptr inbounds nuw float, ptr %15, i64 %61
  %81 = load float, ptr %80, align 4
  %82 = mul nuw nsw i64 %61, 1000
  %83 = add nuw nsw i64 %82, %66
  %84 = getelementptr inbounds nuw float, ptr %3, i64 %83
  %85 = load float, ptr %84, align 4
  %86 = getelementptr inbounds nuw float, ptr %20, i64 %66
  %87 = load float, ptr %86, align 4
  %88 = fmul float %85, %87
  %89 = fadd float %81, %88
  %90 = getelementptr inbounds nuw float, ptr %15, i64 %61
  store float %89, ptr %90, align 4
  %91 = add i64 %66, 1
  br label %65

92:                                               ; preds = %65
  %93 = add i64 %61, 1
  br label %60

94:                                               ; preds = %60
  %95 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
