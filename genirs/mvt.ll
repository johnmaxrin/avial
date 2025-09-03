; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

%struct.ident_t = type { i32, i32, i32, i32, ptr }

@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

define void @testFunc(i32 %0, ptr %1, ptr %2, i64 %3, i64 %4, i64 %5, ptr %6, ptr %7, i64 %8, i64 %9, i64 %10, ptr %11, ptr %12, i64 %13, i64 %14, i64 %15, ptr %16, ptr %17, i64 %18, i64 %19, i64 %20, ptr %21, ptr %22, i64 %23, i64 %24, i64 %25, i64 %26, i64 %27) {
  %structArg135 = alloca { ptr, ptr, ptr }, align 8
  %structArg133 = alloca { ptr, ptr, ptr }, align 8
  %structArg131 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded128 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded129 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded130 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded88 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded89 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded90 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded48 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded49 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded50 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %.reloaded9 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded10 = alloca { ptr, ptr, i64, [1 x i64], [1 x i64] }, align 8
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %21, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, ptr %22, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %23, 2
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, i64 %24, 3, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, i64 %26, 4, 0
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %25, 3, 1
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %27, 4, 1
  %36 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %16, 0
  %37 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %36, ptr %17, 1
  %38 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %37, i64 %18, 2
  %39 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %38, i64 %19, 3, 0
  %40 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %39, i64 %20, 4, 0
  %41 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %11, 0
  %42 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %41, ptr %12, 1
  %43 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %42, i64 %13, 2
  %44 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %43, i64 %14, 3, 0
  %45 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %44, i64 %15, 4, 0
  %46 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %6, 0
  %47 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %46, ptr %7, 1
  %48 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %47, i64 %8, 2
  %49 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %48, i64 %9, 3, 0
  %50 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %49, i64 %10, 4, 0
  %51 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %1, 0
  %52 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %51, ptr %2, 1
  %53 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %52, i64 %3, 2
  %54 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %53, i64 %4, 3, 0
  %55 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %54, i64 %5, 4, 0
  %56 = call i32 @MPI_Init(ptr null, ptr null)
  %57 = alloca i32, align 4
  %58 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %57)
  %59 = load i32, ptr %57, align 4
  %60 = alloca i32, align 4
  %61 = call i32 @MPI_Comm_size(i32 1140850688, ptr %60)
  %62 = load i32, ptr %60, align 4
  %63 = srem i32 0, %62
  %64 = icmp eq i32 %59, %63
  br i1 %64, label %65, label %66

65:                                               ; preds = %28
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %55, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, ptr %.reloaded9, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %45, ptr %.reloaded10, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %65
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded9 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded9, ptr %gep_.reloaded9, align 8
  %gep_.reloaded10 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded10, ptr %gep_.reloaded10, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par, ptr %structArg)
  br label %omp.par.outlined.exit

omp.par.outlined.exit:                            ; preds = %omp_parallel
  br label %omp.par.exit.split

omp.par.exit.split:                               ; preds = %omp.par.outlined.exit
  br label %66

66:                                               ; preds = %omp.par.exit.split, %28
  %67 = srem i32 1, %62
  %68 = icmp eq i32 %59, %67
  br i1 %68, label %69, label %70

69:                                               ; preds = %66
  %omp_global_thread_num11 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %55, ptr %.reloaded48, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, ptr %.reloaded49, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %45, ptr %.reloaded50, align 8
  br label %omp_parallel132

omp_parallel132:                                  ; preds = %69
  %gep_.reloaded48 = getelementptr { ptr, ptr, ptr }, ptr %structArg131, i32 0, i32 0
  store ptr %.reloaded48, ptr %gep_.reloaded48, align 8
  %gep_.reloaded49 = getelementptr { ptr, ptr, ptr }, ptr %structArg131, i32 0, i32 1
  store ptr %.reloaded49, ptr %gep_.reloaded49, align 8
  %gep_.reloaded50 = getelementptr { ptr, ptr, ptr }, ptr %structArg131, i32 0, i32 2
  store ptr %.reloaded50, ptr %gep_.reloaded50, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.1, ptr %structArg131)
  br label %omp.par.outlined.exit47

omp.par.outlined.exit47:                          ; preds = %omp_parallel132
  br label %omp.par.exit.split46

omp.par.exit.split46:                             ; preds = %omp.par.outlined.exit47
  br label %70

70:                                               ; preds = %omp.par.exit.split46, %66
  %71 = srem i32 2, %62
  %72 = icmp eq i32 %59, %71
  br i1 %72, label %73, label %74

73:                                               ; preds = %70
  %omp_global_thread_num51 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %50, ptr %.reloaded88, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, ptr %.reloaded89, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %40, ptr %.reloaded90, align 8
  br label %omp_parallel134

omp_parallel134:                                  ; preds = %73
  %gep_.reloaded88 = getelementptr { ptr, ptr, ptr }, ptr %structArg133, i32 0, i32 0
  store ptr %.reloaded88, ptr %gep_.reloaded88, align 8
  %gep_.reloaded89 = getelementptr { ptr, ptr, ptr }, ptr %structArg133, i32 0, i32 1
  store ptr %.reloaded89, ptr %gep_.reloaded89, align 8
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr }, ptr %structArg133, i32 0, i32 2
  store ptr %.reloaded90, ptr %gep_.reloaded90, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.2, ptr %structArg133)
  br label %omp.par.outlined.exit87

omp.par.outlined.exit87:                          ; preds = %omp_parallel134
  br label %omp.par.exit.split86

omp.par.exit.split86:                             ; preds = %omp.par.outlined.exit87
  br label %74

74:                                               ; preds = %omp.par.exit.split86, %70
  %75 = srem i32 3, %62
  %76 = icmp eq i32 %59, %75
  br i1 %76, label %77, label %78

77:                                               ; preds = %74
  %omp_global_thread_num91 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %50, ptr %.reloaded128, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, ptr %.reloaded129, align 8
  store { ptr, ptr, i64, [1 x i64], [1 x i64] } %40, ptr %.reloaded130, align 8
  br label %omp_parallel136

omp_parallel136:                                  ; preds = %77
  %gep_.reloaded128 = getelementptr { ptr, ptr, ptr }, ptr %structArg135, i32 0, i32 0
  store ptr %.reloaded128, ptr %gep_.reloaded128, align 8
  %gep_.reloaded129 = getelementptr { ptr, ptr, ptr }, ptr %structArg135, i32 0, i32 1
  store ptr %.reloaded129, ptr %gep_.reloaded129, align 8
  %gep_.reloaded130 = getelementptr { ptr, ptr, ptr }, ptr %structArg135, i32 0, i32 2
  store ptr %.reloaded130, ptr %gep_.reloaded130, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.3, ptr %structArg135)
  br label %omp.par.outlined.exit127

omp.par.outlined.exit127:                         ; preds = %omp_parallel136
  br label %omp.par.exit.split126

omp.par.exit.split126:                            ; preds = %omp.par.outlined.exit127
  br label %78

78:                                               ; preds = %omp.par.exit.split126, %74
  %79 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.3(ptr noalias %tid.addr92, ptr noalias %zero.addr93, ptr %0) #0 {
omp.par.entry94:
  %gep_.reloaded128 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded128 = load ptr, ptr %gep_.reloaded128, align 8
  %gep_.reloaded129 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded129 = load ptr, ptr %gep_.reloaded129, align 8
  %gep_.reloaded130 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded130 = load ptr, ptr %gep_.reloaded130, align 8
  %p.lastiter120 = alloca i32, align 4
  %p.lowerbound121 = alloca i64, align 8
  %p.upperbound122 = alloca i64, align 8
  %p.stride123 = alloca i64, align 8
  %tid.addr.local97 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr92, align 4
  store i32 %1, ptr %tid.addr.local97, align 4
  %tid98 = load i32, ptr %tid.addr.local97, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded128, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded129, align 8
  %4 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded130, align 8
  br label %omp.region.after_alloca104

omp.region.after_alloca104:                       ; preds = %omp.par.entry94
  br label %omp.region.after_alloca101

omp.region.after_alloca101:                       ; preds = %omp.region.after_alloca104
  br label %omp.par.region95

omp.par.region95:                                 ; preds = %omp.region.after_alloca101
  br label %omp.par.region103

omp.par.region103:                                ; preds = %omp.par.region95
  br label %omp_loop.preheader105

omp_loop.preheader105:                            ; preds = %omp.par.region103
  store i64 0, ptr %p.lowerbound121, align 4
  store i64 63, ptr %p.upperbound122, align 4
  store i64 1, ptr %p.stride123, align 4
  %omp_global_thread_num124 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num124, i32 34, ptr %p.lastiter120, ptr %p.lowerbound121, ptr %p.upperbound122, ptr %p.stride123, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound121, align 4
  %6 = load i64, ptr %p.upperbound122, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header106

omp_loop.header106:                               ; preds = %omp_loop.inc109, %omp_loop.preheader105
  %omp_loop.iv112 = phi i64 [ 0, %omp_loop.preheader105 ], [ %omp_loop.next114, %omp_loop.inc109 ]
  br label %omp_loop.cond107

omp_loop.cond107:                                 ; preds = %omp_loop.header106
  %omp_loop.cmp113 = icmp ult i64 %omp_loop.iv112, %8
  br i1 %omp_loop.cmp113, label %omp_loop.body108, label %omp_loop.exit110

omp_loop.exit110:                                 ; preds = %omp_loop.cond107
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num124)
  %omp_global_thread_num125 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num125)
  br label %omp_loop.after111

omp_loop.after111:                                ; preds = %omp_loop.exit110
  br label %omp.region.cont102

omp.region.cont102:                               ; preds = %omp_loop.after111
  br label %omp.par.pre_finalize96

omp.par.pre_finalize96:                           ; preds = %omp.region.cont102
  br label %omp.par.outlined.exit127.exitStub

omp_loop.body108:                                 ; preds = %omp_loop.cond107
  %9 = add i64 %omp_loop.iv112, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.wsloop.region116

omp.wsloop.region116:                             ; preds = %omp_loop.body108
  br label %omp.wsloop.region117

omp.wsloop.region117:                             ; preds = %omp.wsloop.region118, %omp.wsloop.region116
  %12 = phi i64 [ %29, %omp.wsloop.region118 ], [ 0, %omp.wsloop.region116 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region118, label %omp.wsloop.region119

omp.wsloop.region119:                             ; preds = %omp.wsloop.region117
  br label %omp.region.cont115

omp.region.cont115:                               ; preds = %omp.wsloop.region119
  br label %omp_loop.inc109

omp_loop.inc109:                                  ; preds = %omp.region.cont115
  %omp_loop.next114 = add nuw i64 %omp_loop.iv112, 1
  br label %omp_loop.header106

omp.wsloop.region118:                             ; preds = %omp.wsloop.region117
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i64 0
  %16 = load float, ptr %15, align 4
  %17 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %18 = mul nuw nsw i64 %12, 128
  %19 = add nuw nsw i64 %18, 0
  %20 = getelementptr float, ptr %17, i64 %19
  %21 = load float, ptr %20, align 4
  %22 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, 1
  %23 = getelementptr float, ptr %22, i64 %12
  %24 = load float, ptr %23, align 4
  %25 = fmul float %21, %24
  %26 = fadd float %16, %25
  %27 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %28 = getelementptr float, ptr %27, i64 0
  store float %26, ptr %28, align 4
  %29 = add i64 %12, 1
  br label %omp.wsloop.region117

omp.par.outlined.exit127.exitStub:                ; preds = %omp.par.pre_finalize96
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.2(ptr noalias %tid.addr52, ptr noalias %zero.addr53, ptr %0) #0 {
omp.par.entry54:
  %gep_.reloaded88 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded88 = load ptr, ptr %gep_.reloaded88, align 8
  %gep_.reloaded89 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded89 = load ptr, ptr %gep_.reloaded89, align 8
  %gep_.reloaded90 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded90 = load ptr, ptr %gep_.reloaded90, align 8
  %p.lastiter80 = alloca i32, align 4
  %p.lowerbound81 = alloca i64, align 8
  %p.upperbound82 = alloca i64, align 8
  %p.stride83 = alloca i64, align 8
  %tid.addr.local57 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr52, align 4
  store i32 %1, ptr %tid.addr.local57, align 4
  %tid58 = load i32, ptr %tid.addr.local57, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded88, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded89, align 8
  %4 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded90, align 8
  br label %omp.region.after_alloca64

omp.region.after_alloca64:                        ; preds = %omp.par.entry54
  br label %omp.region.after_alloca61

omp.region.after_alloca61:                        ; preds = %omp.region.after_alloca64
  br label %omp.par.region55

omp.par.region55:                                 ; preds = %omp.region.after_alloca61
  br label %omp.par.region63

omp.par.region63:                                 ; preds = %omp.par.region55
  br label %omp_loop.preheader65

omp_loop.preheader65:                             ; preds = %omp.par.region63
  store i64 0, ptr %p.lowerbound81, align 4
  store i64 63, ptr %p.upperbound82, align 4
  store i64 1, ptr %p.stride83, align 4
  %omp_global_thread_num84 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num84, i32 34, ptr %p.lastiter80, ptr %p.lowerbound81, ptr %p.upperbound82, ptr %p.stride83, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound81, align 4
  %6 = load i64, ptr %p.upperbound82, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header66

omp_loop.header66:                                ; preds = %omp_loop.inc69, %omp_loop.preheader65
  %omp_loop.iv72 = phi i64 [ 0, %omp_loop.preheader65 ], [ %omp_loop.next74, %omp_loop.inc69 ]
  br label %omp_loop.cond67

omp_loop.cond67:                                  ; preds = %omp_loop.header66
  %omp_loop.cmp73 = icmp ult i64 %omp_loop.iv72, %8
  br i1 %omp_loop.cmp73, label %omp_loop.body68, label %omp_loop.exit70

omp_loop.exit70:                                  ; preds = %omp_loop.cond67
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num84)
  %omp_global_thread_num85 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num85)
  br label %omp_loop.after71

omp_loop.after71:                                 ; preds = %omp_loop.exit70
  br label %omp.region.cont62

omp.region.cont62:                                ; preds = %omp_loop.after71
  br label %omp.par.pre_finalize56

omp.par.pre_finalize56:                           ; preds = %omp.region.cont62
  br label %omp.par.outlined.exit87.exitStub

omp_loop.body68:                                  ; preds = %omp_loop.cond67
  %9 = add i64 %omp_loop.iv72, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 64
  br label %omp.wsloop.region76

omp.wsloop.region76:                              ; preds = %omp_loop.body68
  br label %omp.wsloop.region77

omp.wsloop.region77:                              ; preds = %omp.wsloop.region78, %omp.wsloop.region76
  %12 = phi i64 [ %29, %omp.wsloop.region78 ], [ 0, %omp.wsloop.region76 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region78, label %omp.wsloop.region79

omp.wsloop.region79:                              ; preds = %omp.wsloop.region77
  br label %omp.region.cont75

omp.region.cont75:                                ; preds = %omp.wsloop.region79
  br label %omp_loop.inc69

omp_loop.inc69:                                   ; preds = %omp.region.cont75
  %omp_loop.next74 = add nuw i64 %omp_loop.iv72, 1
  br label %omp_loop.header66

omp.wsloop.region78:                              ; preds = %omp.wsloop.region77
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i64 0
  %16 = load float, ptr %15, align 4
  %17 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %18 = mul nuw nsw i64 %12, 128
  %19 = add nuw nsw i64 %18, 0
  %20 = getelementptr float, ptr %17, i64 %19
  %21 = load float, ptr %20, align 4
  %22 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, 1
  %23 = getelementptr float, ptr %22, i64 %12
  %24 = load float, ptr %23, align 4
  %25 = fmul float %21, %24
  %26 = fadd float %16, %25
  %27 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %28 = getelementptr float, ptr %27, i64 0
  store float %26, ptr %28, align 4
  %29 = add i64 %12, 1
  br label %omp.wsloop.region77

omp.par.outlined.exit87.exitStub:                 ; preds = %omp.par.pre_finalize56
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.1(ptr noalias %tid.addr12, ptr noalias %zero.addr13, ptr %0) #0 {
omp.par.entry14:
  %gep_.reloaded48 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded48 = load ptr, ptr %gep_.reloaded48, align 8
  %gep_.reloaded49 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded49 = load ptr, ptr %gep_.reloaded49, align 8
  %gep_.reloaded50 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded50 = load ptr, ptr %gep_.reloaded50, align 8
  %p.lastiter40 = alloca i32, align 4
  %p.lowerbound41 = alloca i64, align 8
  %p.upperbound42 = alloca i64, align 8
  %p.stride43 = alloca i64, align 8
  %tid.addr.local17 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr12, align 4
  store i32 %1, ptr %tid.addr.local17, align 4
  %tid18 = load i32, ptr %tid.addr.local17, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded48, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded49, align 8
  %4 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded50, align 8
  br label %omp.region.after_alloca24

omp.region.after_alloca24:                        ; preds = %omp.par.entry14
  br label %omp.region.after_alloca21

omp.region.after_alloca21:                        ; preds = %omp.region.after_alloca24
  br label %omp.par.region15

omp.par.region15:                                 ; preds = %omp.region.after_alloca21
  br label %omp.par.region23

omp.par.region23:                                 ; preds = %omp.par.region15
  br label %omp_loop.preheader25

omp_loop.preheader25:                             ; preds = %omp.par.region23
  store i64 0, ptr %p.lowerbound41, align 4
  store i64 63, ptr %p.upperbound42, align 4
  store i64 1, ptr %p.stride43, align 4
  %omp_global_thread_num44 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num44, i32 34, ptr %p.lastiter40, ptr %p.lowerbound41, ptr %p.upperbound42, ptr %p.stride43, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound41, align 4
  %6 = load i64, ptr %p.upperbound42, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header26

omp_loop.header26:                                ; preds = %omp_loop.inc29, %omp_loop.preheader25
  %omp_loop.iv32 = phi i64 [ 0, %omp_loop.preheader25 ], [ %omp_loop.next34, %omp_loop.inc29 ]
  br label %omp_loop.cond27

omp_loop.cond27:                                  ; preds = %omp_loop.header26
  %omp_loop.cmp33 = icmp ult i64 %omp_loop.iv32, %8
  br i1 %omp_loop.cmp33, label %omp_loop.body28, label %omp_loop.exit30

omp_loop.exit30:                                  ; preds = %omp_loop.cond27
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num44)
  %omp_global_thread_num45 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num45)
  br label %omp_loop.after31

omp_loop.after31:                                 ; preds = %omp_loop.exit30
  br label %omp.region.cont22

omp.region.cont22:                                ; preds = %omp_loop.after31
  br label %omp.par.pre_finalize16

omp.par.pre_finalize16:                           ; preds = %omp.region.cont22
  br label %omp.par.outlined.exit47.exitStub

omp_loop.body28:                                  ; preds = %omp_loop.cond27
  %9 = add i64 %omp_loop.iv32, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.wsloop.region36

omp.wsloop.region36:                              ; preds = %omp_loop.body28
  br label %omp.wsloop.region37

omp.wsloop.region37:                              ; preds = %omp.wsloop.region38, %omp.wsloop.region36
  %12 = phi i64 [ %28, %omp.wsloop.region38 ], [ 0, %omp.wsloop.region36 ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region38, label %omp.wsloop.region39

omp.wsloop.region39:                              ; preds = %omp.wsloop.region37
  br label %omp.region.cont35

omp.region.cont35:                                ; preds = %omp.wsloop.region39
  br label %omp_loop.inc29

omp_loop.inc29:                                   ; preds = %omp.region.cont35
  %omp_loop.next34 = add nuw i64 %omp_loop.iv32, 1
  br label %omp_loop.header26

omp.wsloop.region38:                              ; preds = %omp.wsloop.region37
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i64 0
  %16 = load float, ptr %15, align 4
  %17 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %18 = add nuw nsw i64 0, %12
  %19 = getelementptr float, ptr %17, i64 %18
  %20 = load float, ptr %19, align 4
  %21 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, 1
  %22 = getelementptr float, ptr %21, i64 %12
  %23 = load float, ptr %22, align 4
  %24 = fmul float %20, %23
  %25 = fadd float %16, %24
  %26 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %27 = getelementptr float, ptr %26, i64 0
  store float %25, ptr %27, align 4
  %28 = add i64 %12, 1
  br label %omp.wsloop.region37

omp.par.outlined.exit47.exitStub:                 ; preds = %omp.par.pre_finalize16
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8
  %gep_.reloaded9 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded9 = load ptr, ptr %gep_.reloaded9, align 8
  %gep_.reloaded10 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded10 = load ptr, ptr %gep_.reloaded10, align 8
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded9, align 8
  %4 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %loadgep_.reloaded10, align 8
  br label %omp.region.after_alloca2

omp.region.after_alloca2:                         ; preds = %omp.par.entry
  br label %omp.region.after_alloca

omp.region.after_alloca:                          ; preds = %omp.region.after_alloca2
  br label %omp.par.region

omp.par.region:                                   ; preds = %omp.region.after_alloca
  br label %omp.par.region1

omp.par.region1:                                  ; preds = %omp.par.region
  br label %omp_loop.preheader

omp_loop.preheader:                               ; preds = %omp.par.region1
  store i64 0, ptr %p.lowerbound, align 4
  store i64 63, ptr %p.upperbound, align 4
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
  br label %omp.region.cont

omp.region.cont:                                  ; preds = %omp_loop.after
  br label %omp.par.pre_finalize

omp.par.pre_finalize:                             ; preds = %omp.region.cont
  br label %omp.par.outlined.exit.exitStub

omp_loop.body:                                    ; preds = %omp_loop.cond
  %9 = add i64 %omp_loop.iv, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 64
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp_loop.body
  br label %omp.wsloop.region4

omp.wsloop.region4:                               ; preds = %omp.wsloop.region5, %omp.wsloop.region
  %12 = phi i64 [ %28, %omp.wsloop.region5 ], [ 0, %omp.wsloop.region ]
  %13 = icmp slt i64 %12, 128
  br i1 %13, label %omp.wsloop.region5, label %omp.wsloop.region6

omp.wsloop.region6:                               ; preds = %omp.wsloop.region4
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp.wsloop.region6
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont3
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.wsloop.region5:                               ; preds = %omp.wsloop.region4
  %14 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i64 0
  %16 = load float, ptr %15, align 4
  %17 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %18 = add nuw nsw i64 0, %12
  %19 = getelementptr float, ptr %17, i64 %18
  %20 = load float, ptr %19, align 4
  %21 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, 1
  %22 = getelementptr float, ptr %21, i64 %12
  %23 = load float, ptr %22, align 4
  %24 = fmul float %20, %23
  %25 = fadd float %16, %24
  %26 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, 1
  %27 = getelementptr float, ptr %26, i64 0
  store float %25, ptr %27, align 4
  %28 = add i64 %12, 1
  br label %omp.wsloop.region4

omp.par.outlined.exit.exitStub:                   ; preds = %omp.par.pre_finalize
  ret void
}

; Function Attrs: nounwind
declare i32 @__kmpc_global_thread_num(ptr) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_init_8u(ptr, i32, i32, ptr, ptr, ptr, ptr, i64, i64) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_fini(ptr, i32) #0

; Function Attrs: convergent nounwind
declare void @__kmpc_barrier(ptr, i32) #1

; Function Attrs: nounwind
declare !callback !1 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { convergent nounwind }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{!2}
!2 = !{i64 2, i64 -1, i64 -1, i1 true}
