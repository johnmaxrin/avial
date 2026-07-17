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

define void @kernel_floyd_warshall(i32 %0, ptr %1, ptr %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7) {
  %9 = call i32 @MPI_Init(ptr null, ptr null)
  %10 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %11 = getelementptr { ptr, ptr, i32, float }, ptr %10, i32 0, i32 0
  %12 = getelementptr { ptr, ptr, i32, float }, ptr %10, i32 0, i32 1
  %13 = getelementptr { ptr, ptr, i32, float }, ptr %10, i32 0, i32 2
  %14 = getelementptr { ptr, ptr, i32, float }, ptr %10, i32 0, i32 3
  store ptr @node_str_0, ptr %11, align 8
  store ptr @arch_str_0, ptr %12, align 8
  store i32 0, ptr %13, align 4
  store float 1.000000e+00, ptr %14, align 4
  %15 = getelementptr { ptr, ptr, i32, float }, ptr %10, i32 1
  %16 = getelementptr { ptr, ptr, i32, float }, ptr %15, i32 0, i32 0
  %17 = getelementptr { ptr, ptr, i32, float }, ptr %15, i32 0, i32 1
  %18 = getelementptr { ptr, ptr, i32, float }, ptr %15, i32 0, i32 2
  %19 = getelementptr { ptr, ptr, i32, float }, ptr %15, i32 0, i32 3
  store ptr @node_str_1, ptr %16, align 8
  store ptr @arch_str_1, ptr %17, align 8
  store i32 0, ptr %18, align 4
  store float 1.000000e+00, ptr %19, align 4
  %20 = getelementptr { ptr, ptr, i32, float }, ptr %10, i32 2
  %21 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 0
  %22 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 1
  %23 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 2
  %24 = getelementptr { ptr, ptr, i32, float }, ptr %20, i32 0, i32 3
  store ptr @node_str_2, ptr %21, align 8
  store ptr @arch_str_2, ptr %22, align 8
  store i32 0, ptr %23, align 4
  store float 1.000000e+00, ptr %24, align 4
  %25 = getelementptr { ptr, ptr, i32, float }, ptr %10, i32 3
  %26 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 0
  %27 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 1
  %28 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 2
  %29 = getelementptr { ptr, ptr, i32, float }, ptr %25, i32 0, i32 3
  store ptr @node_str_3, ptr %26, align 8
  store ptr @arch_str_3, ptr %27, align 8
  store i32 0, ptr %28, align 4
  store float 1.000000e+00, ptr %29, align 4
  %30 = alloca { i32, ptr }, i64 1, align 8
  %31 = getelementptr { i32, ptr }, ptr %30, i32 0, i32 0
  %32 = getelementptr { i32, ptr }, ptr %30, i32 0, i32 1
  store i32 4, ptr %31, align 4
  store ptr %10, ptr %32, align 8
  %33 = call ptr @malloc(i64 16)
  %34 = call ptr @malloc(i64 16)
  %35 = ptrtoint ptr %33 to i64
  %36 = ptrtoint ptr %34 to i64
  %37 = inttoptr i64 %35 to ptr
  %38 = inttoptr i64 %36 to ptr
  call void @buildRankNodeMaps(ptr %30, ptr %37, ptr %38)
  br label %39

39:                                               ; preds = %89, %8
  %40 = phi i64 [ %90, %89 ], [ 0, %8 ]
  %41 = icmp slt i64 %40, 128
  br i1 %41, label %42, label %91

42:                                               ; preds = %39
  br label %43

43:                                               ; preds = %87, %42
  %44 = phi i64 [ %88, %87 ], [ 0, %42 ]
  %45 = icmp slt i64 %44, 128
  br i1 %45, label %46, label %89

46:                                               ; preds = %43
  br label %47

47:                                               ; preds = %82, %46
  %48 = phi i64 [ %86, %82 ], [ 0, %46 ]
  %49 = icmp slt i64 %48, 128
  br i1 %49, label %50, label %87

50:                                               ; preds = %47
  %51 = mul nuw nsw i64 %44, 128
  %52 = add nuw nsw i64 %51, %48
  %53 = getelementptr inbounds nuw float, ptr %2, i64 %52
  %54 = load float, ptr %53, align 4
  %55 = mul nuw nsw i64 %44, 128
  %56 = add nuw nsw i64 %55, %40
  %57 = getelementptr inbounds nuw float, ptr %2, i64 %56
  %58 = load float, ptr %57, align 4
  %59 = mul nuw nsw i64 %40, 128
  %60 = add nuw nsw i64 %59, %48
  %61 = getelementptr inbounds nuw float, ptr %2, i64 %60
  %62 = load float, ptr %61, align 4
  %63 = fadd float %58, %62
  %64 = fcmp olt float %54, %63
  br i1 %64, label %65, label %70

65:                                               ; preds = %50
  %66 = mul nuw nsw i64 %44, 128
  %67 = add nuw nsw i64 %66, %48
  %68 = getelementptr inbounds nuw float, ptr %2, i64 %67
  %69 = load float, ptr %68, align 4
  br label %80

70:                                               ; preds = %50
  %71 = mul nuw nsw i64 %44, 128
  %72 = add nuw nsw i64 %71, %40
  %73 = getelementptr inbounds nuw float, ptr %2, i64 %72
  %74 = load float, ptr %73, align 4
  %75 = mul nuw nsw i64 %40, 128
  %76 = add nuw nsw i64 %75, %48
  %77 = getelementptr inbounds nuw float, ptr %2, i64 %76
  %78 = load float, ptr %77, align 4
  %79 = fadd float %74, %78
  br label %80

80:                                               ; preds = %65, %70
  %81 = phi float [ %79, %70 ], [ %69, %65 ]
  br label %82

82:                                               ; preds = %80
  %83 = mul nuw nsw i64 %44, 128
  %84 = add nuw nsw i64 %83, %48
  %85 = getelementptr inbounds nuw float, ptr %2, i64 %84
  store float %81, ptr %85, align 4
  %86 = add i64 %48, 1
  br label %47

87:                                               ; preds = %47
  %88 = add i64 %44, 1
  br label %43

89:                                               ; preds = %43
  %90 = add i64 %40, 1
  br label %39

91:                                               ; preds = %39
  %92 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
