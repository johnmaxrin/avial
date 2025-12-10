; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare i32 @MPI_Send(ptr, i32, i32, i32, i32, i32)

declare i32 @MPI_Recv(ptr, i32, i32, i32, i32, i32, ptr)

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

define void @matmul(i32 %0, i32 %1, i32 %2, ptr %3, ptr %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, ptr %10, ptr %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, ptr %17, ptr %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23) {
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
  %48 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %47)
  %49 = load i32, ptr %47, align 4
  %50 = alloca i32, align 4
  %51 = call i32 @MPI_Comm_size(i32 1140850688, ptr %50)
  %52 = load i32, ptr %50, align 4
  %53 = srem i32 0, %52
  %54 = icmp eq i32 %49, %53
  br i1 %54, label %55, label %99

55:                                               ; preds = %24
  br label %56

56:                                               ; preds = %96, %55
  %57 = phi i64 [ %97, %96 ], [ 667, %55 ]
  %58 = icmp slt i64 %57, 1000
  br i1 %58, label %59, label %98

59:                                               ; preds = %56
  br label %60

60:                                               ; preds = %94, %59
  %61 = phi i64 [ %95, %94 ], [ 0, %59 ]
  %62 = icmp slt i64 %61, 1000
  br i1 %62, label %63, label %96

63:                                               ; preds = %60
  %64 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %65 = mul nuw nsw i64 %57, 1000
  %66 = add nuw nsw i64 %65, %61
  %67 = getelementptr inbounds nuw float, ptr %64, i64 %66
  store float 0.000000e+00, ptr %67, align 4
  br label %68

68:                                               ; preds = %71, %63
  %69 = phi i64 [ %93, %71 ], [ 0, %63 ]
  %70 = icmp slt i64 %69, 1000
  br i1 %70, label %71, label %94

71:                                               ; preds = %68
  %72 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %73 = mul nuw nsw i64 %57, 1000
  %74 = add nuw nsw i64 %73, %69
  %75 = getelementptr inbounds nuw float, ptr %72, i64 %74
  %76 = load float, ptr %75, align 4
  %77 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %78 = mul nuw nsw i64 %69, 1000
  %79 = add nuw nsw i64 %78, %61
  %80 = getelementptr inbounds nuw float, ptr %77, i64 %79
  %81 = load float, ptr %80, align 4
  %82 = fmul float %76, %81
  %83 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %84 = mul nuw nsw i64 %57, 1000
  %85 = add nuw nsw i64 %84, %61
  %86 = getelementptr inbounds nuw float, ptr %83, i64 %85
  %87 = load float, ptr %86, align 4
  %88 = fadd float %87, %82
  %89 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %90 = mul nuw nsw i64 %57, 1000
  %91 = add nuw nsw i64 %90, %61
  %92 = getelementptr inbounds nuw float, ptr %89, i64 %91
  store float %88, ptr %92, align 4
  %93 = add i64 %69, 1
  br label %68

94:                                               ; preds = %68
  %95 = add i64 %61, 1
  br label %60

96:                                               ; preds = %60
  %97 = add i64 %57, 1
  br label %56

98:                                               ; preds = %56
  br label %99

99:                                               ; preds = %98, %24
  %100 = srem i32 1, %52
  %101 = icmp eq i32 %49, %100
  br i1 %101, label %102, label %146

102:                                              ; preds = %99
  br label %103

103:                                              ; preds = %143, %102
  %104 = phi i64 [ %144, %143 ], [ 334, %102 ]
  %105 = icmp slt i64 %104, 667
  br i1 %105, label %106, label %145

106:                                              ; preds = %103
  br label %107

107:                                              ; preds = %141, %106
  %108 = phi i64 [ %142, %141 ], [ 0, %106 ]
  %109 = icmp slt i64 %108, 1000
  br i1 %109, label %110, label %143

110:                                              ; preds = %107
  %111 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %112 = mul nuw nsw i64 %104, 1000
  %113 = add nuw nsw i64 %112, %108
  %114 = getelementptr inbounds nuw float, ptr %111, i64 %113
  store float 0.000000e+00, ptr %114, align 4
  br label %115

115:                                              ; preds = %118, %110
  %116 = phi i64 [ %140, %118 ], [ 0, %110 ]
  %117 = icmp slt i64 %116, 1000
  br i1 %117, label %118, label %141

118:                                              ; preds = %115
  %119 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %120 = mul nuw nsw i64 %104, 1000
  %121 = add nuw nsw i64 %120, %116
  %122 = getelementptr inbounds nuw float, ptr %119, i64 %121
  %123 = load float, ptr %122, align 4
  %124 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %125 = mul nuw nsw i64 %116, 1000
  %126 = add nuw nsw i64 %125, %108
  %127 = getelementptr inbounds nuw float, ptr %124, i64 %126
  %128 = load float, ptr %127, align 4
  %129 = fmul float %123, %128
  %130 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %131 = mul nuw nsw i64 %104, 1000
  %132 = add nuw nsw i64 %131, %108
  %133 = getelementptr inbounds nuw float, ptr %130, i64 %132
  %134 = load float, ptr %133, align 4
  %135 = fadd float %134, %129
  %136 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %137 = mul nuw nsw i64 %104, 1000
  %138 = add nuw nsw i64 %137, %108
  %139 = getelementptr inbounds nuw float, ptr %136, i64 %138
  store float %135, ptr %139, align 4
  %140 = add i64 %116, 1
  br label %115

141:                                              ; preds = %115
  %142 = add i64 %108, 1
  br label %107

143:                                              ; preds = %107
  %144 = add i64 %104, 1
  br label %103

145:                                              ; preds = %103
  br label %146

146:                                              ; preds = %145, %99
  %147 = srem i32 2, %52
  %148 = icmp eq i32 %49, %147
  br i1 %148, label %149, label %193

149:                                              ; preds = %146
  br label %150

150:                                              ; preds = %190, %149
  %151 = phi i64 [ %191, %190 ], [ 0, %149 ]
  %152 = icmp slt i64 %151, 334
  br i1 %152, label %153, label %192

153:                                              ; preds = %150
  br label %154

154:                                              ; preds = %188, %153
  %155 = phi i64 [ %189, %188 ], [ 0, %153 ]
  %156 = icmp slt i64 %155, 1000
  br i1 %156, label %157, label %190

157:                                              ; preds = %154
  %158 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %159 = mul nuw nsw i64 %151, 1000
  %160 = add nuw nsw i64 %159, %155
  %161 = getelementptr inbounds nuw float, ptr %158, i64 %160
  store float 0.000000e+00, ptr %161, align 4
  br label %162

162:                                              ; preds = %165, %157
  %163 = phi i64 [ %187, %165 ], [ 0, %157 ]
  %164 = icmp slt i64 %163, 1000
  br i1 %164, label %165, label %188

165:                                              ; preds = %162
  %166 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %167 = mul nuw nsw i64 %151, 1000
  %168 = add nuw nsw i64 %167, %163
  %169 = getelementptr inbounds nuw float, ptr %166, i64 %168
  %170 = load float, ptr %169, align 4
  %171 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %172 = mul nuw nsw i64 %163, 1000
  %173 = add nuw nsw i64 %172, %155
  %174 = getelementptr inbounds nuw float, ptr %171, i64 %173
  %175 = load float, ptr %174, align 4
  %176 = fmul float %170, %175
  %177 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %178 = mul nuw nsw i64 %151, 1000
  %179 = add nuw nsw i64 %178, %155
  %180 = getelementptr inbounds nuw float, ptr %177, i64 %179
  %181 = load float, ptr %180, align 4
  %182 = fadd float %181, %176
  %183 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %184 = mul nuw nsw i64 %151, 1000
  %185 = add nuw nsw i64 %184, %155
  %186 = getelementptr inbounds nuw float, ptr %183, i64 %185
  store float %182, ptr %186, align 4
  %187 = add i64 %163, 1
  br label %162

188:                                              ; preds = %162
  %189 = add i64 %155, 1
  br label %154

190:                                              ; preds = %154
  %191 = add i64 %151, 1
  br label %150

192:                                              ; preds = %150
  br label %193

193:                                              ; preds = %192, %146
  %194 = call i32 @MPI_Barrier(i32 1140850688)
  %195 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %196 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %197 = insertvalue { ptr, ptr, i64 } poison, ptr %195, 0
  %198 = insertvalue { ptr, ptr, i64 } %197, ptr %196, 1
  %199 = insertvalue { ptr, ptr, i64 } %198, i64 0, 2
  %200 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %201 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %202 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %203 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %204 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %205 = extractvalue { ptr, ptr, i64 } %199, 0
  %206 = extractvalue { ptr, ptr, i64 } %199, 1
  %207 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %205, 0
  %208 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %207, ptr %206, 1
  %209 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %208, i64 667000, 2
  %210 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %209, i64 333000, 3, 0
  %211 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %210, i64 1000, 4, 0
  %212 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %211, i64 1000, 3, 1
  %213 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %212, i64 1, 4, 1
  %214 = icmp eq i32 %49, 0
  br i1 %214, label %215, label %226

215:                                              ; preds = %193
  %216 = srem i32 0, %52
  %217 = icmp ne i32 %216, 0
  br i1 %217, label %218, label %225

218:                                              ; preds = %215
  %219 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %213, 1
  %220 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %213, 2
  %221 = getelementptr float, ptr %219, i64 %220
  %222 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %213, 3, 0
  %223 = trunc i64 %222 to i32
  %224 = call i32 @MPI_Recv(ptr %221, i32 %223, i32 1275069450, i32 %216, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %225

225:                                              ; preds = %218, %215, %229, %226
  br label %236

226:                                              ; preds = %193
  %227 = srem i32 0, %52
  %228 = icmp eq i32 %49, %227
  br i1 %228, label %229, label %225

229:                                              ; preds = %226
  %230 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %213, 1
  %231 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %213, 2
  %232 = getelementptr float, ptr %230, i64 %231
  %233 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %213, 3, 0
  %234 = trunc i64 %233 to i32
  %235 = call i32 @MPI_Send(ptr %232, i32 %234, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %225

236:                                              ; preds = %225
  %237 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %238 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %239 = insertvalue { ptr, ptr, i64 } poison, ptr %237, 0
  %240 = insertvalue { ptr, ptr, i64 } %239, ptr %238, 1
  %241 = insertvalue { ptr, ptr, i64 } %240, i64 0, 2
  %242 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %243 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %244 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %245 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %246 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %247 = extractvalue { ptr, ptr, i64 } %241, 0
  %248 = extractvalue { ptr, ptr, i64 } %241, 1
  %249 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %247, 0
  %250 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %249, ptr %248, 1
  %251 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %250, i64 334000, 2
  %252 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %251, i64 333000, 3, 0
  %253 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, i64 1000, 4, 0
  %254 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %253, i64 1000, 3, 1
  %255 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %254, i64 1, 4, 1
  %256 = icmp eq i32 %49, 0
  br i1 %256, label %257, label %268

257:                                              ; preds = %236
  %258 = srem i32 1, %52
  %259 = icmp ne i32 %258, 0
  br i1 %259, label %260, label %267

260:                                              ; preds = %257
  %261 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 1
  %262 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 2
  %263 = getelementptr float, ptr %261, i64 %262
  %264 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 3, 0
  %265 = trunc i64 %264 to i32
  %266 = call i32 @MPI_Recv(ptr %263, i32 %265, i32 1275069450, i32 %258, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %267

267:                                              ; preds = %260, %257, %271, %268
  br label %278

268:                                              ; preds = %236
  %269 = srem i32 1, %52
  %270 = icmp eq i32 %49, %269
  br i1 %270, label %271, label %267

271:                                              ; preds = %268
  %272 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 1
  %273 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 2
  %274 = getelementptr float, ptr %272, i64 %273
  %275 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 3, 0
  %276 = trunc i64 %275 to i32
  %277 = call i32 @MPI_Send(ptr %274, i32 %276, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %267

278:                                              ; preds = %267
  %279 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %280 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %281 = insertvalue { ptr, ptr, i64 } poison, ptr %279, 0
  %282 = insertvalue { ptr, ptr, i64 } %281, ptr %280, 1
  %283 = insertvalue { ptr, ptr, i64 } %282, i64 0, 2
  %284 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %285 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %286 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %287 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %288 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %289 = extractvalue { ptr, ptr, i64 } %283, 0
  %290 = extractvalue { ptr, ptr, i64 } %283, 1
  %291 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %289, 0
  %292 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %291, ptr %290, 1
  %293 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %292, i64 0, 2
  %294 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %293, i64 334000, 3, 0
  %295 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %294, i64 1000, 4, 0
  %296 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %295, i64 1000, 3, 1
  %297 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %296, i64 1, 4, 1
  %298 = icmp eq i32 %49, 0
  br i1 %298, label %299, label %310

299:                                              ; preds = %278
  %300 = srem i32 2, %52
  %301 = icmp ne i32 %300, 0
  br i1 %301, label %302, label %309

302:                                              ; preds = %299
  %303 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, 1
  %304 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, 2
  %305 = getelementptr float, ptr %303, i64 %304
  %306 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, 3, 0
  %307 = trunc i64 %306 to i32
  %308 = call i32 @MPI_Recv(ptr %305, i32 %307, i32 1275069450, i32 %300, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %309

309:                                              ; preds = %302, %299, %313, %310
  br label %320

310:                                              ; preds = %278
  %311 = srem i32 2, %52
  %312 = icmp eq i32 %49, %311
  br i1 %312, label %313, label %309

313:                                              ; preds = %310
  %314 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, 1
  %315 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, 2
  %316 = getelementptr float, ptr %314, i64 %315
  %317 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %297, 3, 0
  %318 = trunc i64 %317 to i32
  %319 = call i32 @MPI_Send(ptr %316, i32 %318, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %309

320:                                              ; preds = %309
  %321 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
