; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

%struct.ident_t = type { i32, i32, i32, i32, ptr }

%struct.ompi_predefined_communicator_t = type opaque
@ompi_mpi_comm_world = external global %struct.ompi_predefined_communicator_t, align 1

@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

declare i32 @printf(i8*, ...)
@.str = constant [14 x i8] c"Hello, World!\00"

define void @testFunc(i32 %0, i32 %1, i32 %2, ptr %3, ptr %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, ptr %10, ptr %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, ptr %17, ptr %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23) {
  
  

  %structArg57 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded54 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded55 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded56 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded12 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded13 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %17, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, ptr %18, 1
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %19, 2
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 3, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %22, 4, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %21, 3, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %23, 4, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %10, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %11, 1
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %12, 2
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %13, 3, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %15, 4, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %14, 3, 1
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %16, 4, 1
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %3, 0
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, ptr %4, 1
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 %5, 2
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, i64 %6, 3, 0
  %43 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, i64 %8, 4, 0
  %44 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %43, i64 %7, 3, 1
  %45 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, i64 %9, 4, 1
  %46 = call i32 @MPI_Init(ptr null, ptr null)
  %47 = alloca i32, align 4
  %48 = call i32 @MPI_Comm_rank( ptr noundef @ompi_mpi_comm_world, ptr noundef %47)
  %49 = load i32, ptr %47, align 4
  %50 = alloca i32, align 4
  %51 = call i32 @MPI_Comm_size( ptr noundef @ompi_mpi_comm_world , ptr noundef %50)
  %52 = load i32, ptr %50, align 4
  %53 = sext i32 %0 to i64
  %54 = sext i32 %1 to i64
  %55 = sext i32 %2 to i64
  %56 = srem i32 0, %52
  %57 = icmp eq i32 %49, %56
  br i1 %57, label %58, label %59

58:                                               ; preds = %24
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, ptr %.reloaded12, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, ptr %.reloaded13, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %58
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded12 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded12, ptr %gep_.reloaded12, align 8
  %gep_.reloaded13 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded13, ptr %gep_.reloaded13, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par, ptr %structArg)
  br label %omp.par.outlined.exit

omp.par.outlined.exit:                            ; preds = %omp_parallel
  br label %omp.par.exit.split

omp.par.exit.split:                               ; preds = %omp.par.outlined.exit
  br label %59

59:                                               ; preds = %omp.par.exit.split, %24
  %60 = srem i32 1, %52
  %61 = icmp eq i32 %49, %60
  br i1 %61, label %62, label %63

62:                                               ; preds = %59
  %omp_global_thread_num14 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, ptr %.reloaded54, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, ptr %.reloaded55, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, ptr %.reloaded56, align 8
  br label %omp_parallel58

omp_parallel58:                                   ; preds = %62
  %gep_.reloaded54 = getelementptr { ptr, ptr, ptr }, ptr %structArg57, i32 0, i32 0
  store ptr %.reloaded54, ptr %gep_.reloaded54, align 8
  %gep_.reloaded55 = getelementptr { ptr, ptr, ptr }, ptr %structArg57, i32 0, i32 1
  store ptr %.reloaded55, ptr %gep_.reloaded55, align 8
  %gep_.reloaded56 = getelementptr { ptr, ptr, ptr }, ptr %structArg57, i32 0, i32 2
  store ptr %.reloaded56, ptr %gep_.reloaded56, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @testFunc..omp_par.1, ptr %structArg57)
  br label %omp.par.outlined.exit53

omp.par.outlined.exit53:                          ; preds = %omp_parallel58
  br label %omp.par.exit.split52

omp.par.exit.split52:                             ; preds = %omp.par.outlined.exit53
  br label %63

63:                                               ; preds = %omp.par.exit.split52, %59
  %64 = call i32 @MPI_Barrier(ptr noundef @ompi_mpi_comm_world)
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par.1(ptr noalias %tid.addr15, ptr noalias %zero.addr16, ptr %0) #0 {
omp.par.entry17:
  %gep_.reloaded54 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded54 = load ptr, ptr %gep_.reloaded54, align 8
  %gep_.reloaded55 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded55 = load ptr, ptr %gep_.reloaded55, align 8
  %gep_.reloaded56 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded56 = load ptr, ptr %gep_.reloaded56, align 8
  %p.lastiter46 = alloca i32, align 4
  %p.lowerbound47 = alloca i64, align 8
  %p.upperbound48 = alloca i64, align 8
  %p.stride49 = alloca i64, align 8
  %tid.addr.local20 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr15, align 4
  store i32 %1, ptr %tid.addr.local20, align 4
  %tid21 = load i32, ptr %tid.addr.local20, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded54, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded55, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded56, align 8
  br label %omp.region.after_alloca27

omp.region.after_alloca27:                        ; preds = %omp.par.entry17
  br label %omp.region.after_alloca24

omp.region.after_alloca24:                        ; preds = %omp.region.after_alloca27
  br label %omp.par.region18

omp.par.region18:                                 ; preds = %omp.region.after_alloca24
  br label %omp.par.region26

omp.par.region26:                                 ; preds = %omp.par.region18
  br label %omp_loop.preheader28

omp_loop.preheader28:                             ; preds = %omp.par.region26
  store i64 0, ptr %p.lowerbound47, align 4
  store i64 14, ptr %p.upperbound48, align 4
  store i64 1, ptr %p.stride49, align 4
  %omp_global_thread_num50 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num50, i32 34, ptr %p.lastiter46, ptr %p.lowerbound47, ptr %p.upperbound48, ptr %p.stride49, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound47, align 4
  %6 = load i64, ptr %p.upperbound48, align 4
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
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num50)
  %omp_global_thread_num51 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num51)
  br label %omp_loop.after34

omp_loop.after34:                                 ; preds = %omp_loop.exit33
  br label %omp.region.cont25

omp.region.cont25:                                ; preds = %omp_loop.after34
  br label %omp.par.pre_finalize19

omp.par.pre_finalize19:                           ; preds = %omp.region.cont25
  br label %omp.par.outlined.exit53.exitStub

omp_loop.body31:                                  ; preds = %omp_loop.cond30
  %9 = add i64 %omp_loop.iv35, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.wsloop.region39

omp.wsloop.region39:                              ; preds = %omp_loop.body31
  br label %omp.wsloop.region40

omp.wsloop.region40:                              ; preds = %omp.wsloop.region44, %omp.wsloop.region39
  %12 = phi i64 [ %19, %omp.wsloop.region44 ], [ 0, %omp.wsloop.region39 ]
  %13 = icmp slt i64 %12, 20
  br i1 %13, label %omp.wsloop.region41, label %omp.wsloop.region45

omp.wsloop.region45:                              ; preds = %omp.wsloop.region40
  br label %omp.region.cont38

omp.region.cont38:                                ; preds = %omp.wsloop.region45
  br label %omp_loop.inc32

omp_loop.inc32:                                   ; preds = %omp.region.cont38
  %omp_loop.next37 = add nuw i64 %omp_loop.iv35, 1
  br label %omp_loop.header29

omp.wsloop.region41:                              ; preds = %omp.wsloop.region40
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region42

omp.wsloop.region42:                              ; preds = %omp.wsloop.region43, %omp.wsloop.region41
  %17 = phi i64 [ %38, %omp.wsloop.region43 ], [ 0, %omp.wsloop.region41 ]
  %18 = icmp slt i64 %17, 10
  br i1 %18, label %omp.wsloop.region43, label %omp.wsloop.region44

omp.wsloop.region44:                              ; preds = %omp.wsloop.region42
  %19 = add i64 %12, 1
  br label %omp.wsloop.region40

omp.wsloop.region43:                              ; preds = %omp.wsloop.region42
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
  br label %omp.wsloop.region42

omp.par.outlined.exit53.exitStub:                 ; preds = %omp.par.pre_finalize19
  ret void
}

; Function Attrs: nounwind
define internal void @testFunc..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8
  %gep_.reloaded12 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded12 = load ptr, ptr %gep_.reloaded12, align 8
  %gep_.reloaded13 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded13 = load ptr, ptr %gep_.reloaded13, align 8
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded12, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded13, align 8
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
  store i64 14, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num10 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num10, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
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
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num10)
  %omp_global_thread_num11 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num11)
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
  %11 = add i64 %10, 15
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp_loop.body
  br label %omp.wsloop.region4

omp.wsloop.region4:                               ; preds = %omp.wsloop.region8, %omp.wsloop.region
  %12 = phi i64 [ %19, %omp.wsloop.region8 ], [ 0, %omp.wsloop.region ]
  %13 = icmp slt i64 %12, 20
  br i1 %13, label %omp.wsloop.region5, label %omp.wsloop.region9

omp.wsloop.region9:                               ; preds = %omp.wsloop.region4
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp.wsloop.region9
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont3
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.wsloop.region5:                               ; preds = %omp.wsloop.region4
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = add nuw nsw i64 0, %12
  %16 = getelementptr float, ptr %14, i64 %15
  store float 0.000000e+00, ptr %16, align 4
  br label %omp.wsloop.region6

omp.wsloop.region6:                               ; preds = %omp.wsloop.region7, %omp.wsloop.region5
  %17 = phi i64 [ %38, %omp.wsloop.region7 ], [ 0, %omp.wsloop.region5 ]
  %18 = icmp slt i64 %17, 10
  br i1 %18, label %omp.wsloop.region7, label %omp.wsloop.region8

omp.wsloop.region8:                               ; preds = %omp.wsloop.region6
  %19 = add i64 %12, 1
  br label %omp.wsloop.region4

omp.wsloop.region7:                               ; preds = %omp.wsloop.region6
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %21 = add nuw nsw i64 0, %17
  %22 = getelementptr float, ptr %20, i64 %21
  %23 = load float, ptr %22, align 4
  %24 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %25 = mul nuw nsw i64 %17, 128
  %26 = add nuw nsw i64 %25, %12
  %27 = getelementptr float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = fmul float %23, %28
  %30 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %31 = add nuw nsw i64 0, %12
  %32 = getelementptr float, ptr %30, i64 %31
  %33 = load float, ptr %32, align 4
  %34 = fadd float %33, %29
  %35 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %36 = add nuw nsw i64 0, %12
  %37 = getelementptr float, ptr %35, i64 %36
  store float %34, ptr %37, align 4
  %38 = add i64 %17, 1
  br label %omp.wsloop.region6

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
