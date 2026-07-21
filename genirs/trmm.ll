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

define void @kernel_trmm(i32 %0, float %1, ptr %2, ptr %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, i64 %11, i64 %12, i64 %13, i64 %14, i64 %15) {
  %17 = call i32 @MPI_Init(ptr null, ptr null)
  %18 = alloca { ptr, ptr, i32, float }, i64 4, align 8
  %19 = getelementptr { ptr, ptr, i32, float }, ptr %18, i32 0, i32 0
  %20 = getelementptr { ptr, ptr, i32, float }, ptr %18, i32 0, i32 1
  %21 = getelementptr { ptr, ptr, i32, float }, ptr %18, i32 0, i32 2
  %22 = getelementptr { ptr, ptr, i32, float }, ptr %18, i32 0, i32 3
  store ptr @node_str_0, ptr %19, align 8
  store ptr @arch_str_0, ptr %20, align 8
  store i32 0, ptr %21, align 4
  store float 1.000000e+00, ptr %22, align 4
  %23 = getelementptr { ptr, ptr, i32, float }, ptr %18, i32 1
  %24 = getelementptr { ptr, ptr, i32, float }, ptr %23, i32 0, i32 0
  %25 = getelementptr { ptr, ptr, i32, float }, ptr %23, i32 0, i32 1
  %26 = getelementptr { ptr, ptr, i32, float }, ptr %23, i32 0, i32 2
  %27 = getelementptr { ptr, ptr, i32, float }, ptr %23, i32 0, i32 3
  store ptr @node_str_1, ptr %24, align 8
  store ptr @arch_str_1, ptr %25, align 8
  store i32 0, ptr %26, align 4
  store float 1.000000e+00, ptr %27, align 4
  %28 = getelementptr { ptr, ptr, i32, float }, ptr %18, i32 2
  %29 = getelementptr { ptr, ptr, i32, float }, ptr %28, i32 0, i32 0
  %30 = getelementptr { ptr, ptr, i32, float }, ptr %28, i32 0, i32 1
  %31 = getelementptr { ptr, ptr, i32, float }, ptr %28, i32 0, i32 2
  %32 = getelementptr { ptr, ptr, i32, float }, ptr %28, i32 0, i32 3
  store ptr @node_str_2, ptr %29, align 8
  store ptr @arch_str_2, ptr %30, align 8
  store i32 0, ptr %31, align 4
  store float 1.000000e+00, ptr %32, align 4
  %33 = getelementptr { ptr, ptr, i32, float }, ptr %18, i32 3
  %34 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 0
  %35 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 1
  %36 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 2
  %37 = getelementptr { ptr, ptr, i32, float }, ptr %33, i32 0, i32 3
  store ptr @node_str_3, ptr %34, align 8
  store ptr @arch_str_3, ptr %35, align 8
  store i32 0, ptr %36, align 4
  store float 1.000000e+00, ptr %37, align 4
  %38 = alloca { i32, ptr }, i64 1, align 8
  %39 = getelementptr { i32, ptr }, ptr %38, i32 0, i32 0
  %40 = getelementptr { i32, ptr }, ptr %38, i32 0, i32 1
  store i32 4, ptr %39, align 4
  store ptr %18, ptr %40, align 8
  %41 = call ptr @malloc(i64 16)
  %42 = call ptr @malloc(i64 16)
  %43 = ptrtoint ptr %41 to i64
  %44 = ptrtoint ptr %42 to i64
  %45 = inttoptr i64 %43 to ptr
  %46 = inttoptr i64 %44 to ptr
  call void @buildRankNodeMaps(ptr %38, ptr %45, ptr %46)
  br label %47

47:                                               ; preds = %80, %16
  %48 = phi i64 [ %81, %80 ], [ 1, %16 ]
  %49 = icmp slt i64 %48, 1000
  br i1 %49, label %50, label %82

50:                                               ; preds = %47
  br label %51

51:                                               ; preds = %78, %50
  %52 = phi i64 [ %79, %78 ], [ 0, %50 ]
  %53 = icmp slt i64 %52, 1000
  br i1 %53, label %54, label %80

54:                                               ; preds = %51
  br label %55

55:                                               ; preds = %58, %54
  %56 = phi i64 [ %77, %58 ], [ 0, %54 ]
  %57 = icmp slt i64 %56, %48
  br i1 %57, label %58, label %78

58:                                               ; preds = %55
  %59 = mul nuw nsw i64 %48, 1000
  %60 = add nuw nsw i64 %59, %56
  %61 = getelementptr inbounds nuw float, ptr %3, i64 %60
  %62 = load float, ptr %61, align 4
  %63 = fmul float %1, %62
  %64 = mul nuw nsw i64 %52, 1000
  %65 = add nuw nsw i64 %64, %56
  %66 = getelementptr inbounds nuw float, ptr %10, i64 %65
  %67 = load float, ptr %66, align 4
  %68 = fmul float %63, %67
  %69 = mul nuw nsw i64 %48, 1000
  %70 = add nuw nsw i64 %69, %52
  %71 = getelementptr inbounds nuw float, ptr %10, i64 %70
  %72 = load float, ptr %71, align 4
  %73 = fadd float %72, %68
  %74 = mul nuw nsw i64 %48, 1000
  %75 = add nuw nsw i64 %74, %52
  %76 = getelementptr inbounds nuw float, ptr %10, i64 %75
  store float %73, ptr %76, align 4
  %77 = add i64 %56, 1
  br label %55

78:                                               ; preds = %55
  %79 = add i64 %52, 1
  br label %51

80:                                               ; preds = %51
  %81 = add i64 %48, 1
  br label %47

82:                                               ; preds = %47
  %83 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
