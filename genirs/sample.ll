; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

%0 = type { i64, i64, float, ptr, ptr, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, i64, i64 }
%struct.ident_t = type { i32, i32, i32, i32, ptr }

@matmul_kernel_binary = internal constant [6616 x i8] c"P\EDU\BA\01\00\10\00\C8\19\00\00\00\00\00\00\02\00\01\01@\00\00\00\E8\15\00\00\00\00\00\00\00\00\00\00\00\00\00\00\07\00\01\00=\00\00\00\00\00\00\00\00\00\00\00\11\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\7FELF\02\01\013\07\00\00\00\00\00\00\00\02\00\BE\00y\00\00\00\00\00\00\00\00\00\00\00@\15\00\00\00\00\00\00@\13\00\00\00\00\00\00=\05=\00@\008\00\03\00@\00\08\00\01\00\00.shstrtab\00.strtab\00.symtab\00.symtab_shndx\00.nv.uft.entry\00.nv.info\00.text.matmul_kernel\00.nv.info.matmul_kernel\00.nv.shared.matmul_kernel\00.nv.constant0.matmul_kernel\00\00.shstrtab\00.strtab\00.symtab\00.symtab_shndx\00.nv.uft.entry\00.nv.info\00matmul_kernel\00.text.matmul_kernel\00.nv.info.matmul_kernel\00.nv.shared.matmul_kernel\00.nv.constant0.matmul_kernel\00_param\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00N\00\00\00\03\00\07\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\92\00\00\00\03\00\06\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00@\00\00\00\12\10\07\00\00\00\00\00\00\00\00\00@\0D\00\00\00\00\00\00\04/\08\00\03\00\00\00\16\00\00\00\04#\08\00\03\00\00\00\00\00\00\00\04\12\08\00\03\00\00\00\00\00\00\00\04\11\08\00\03\00\00\00\00\00\00\00\047\04\00y\00\00\00\010\00\00\01*\00\00\04\0A\08\00\02\00\00\00@\01\C0\00\03\19\C0\00\04\17\0C\00\00\00\00\00\17\00\B8\00\00\F0!\00\04\17\0C\00\00\00\00\00\16\00\B0\00\00\F0!\00\04\17\0C\00\00\00\00\00\15\00\A8\00\00\F0!\00\04\17\0C\00\00\00\00\00\14\00\A0\00\00\F0!\00\04\17\0C\00\00\00\00\00\13\00\98\00\00\F0!\00\04\17\0C\00\00\00\00\00\12\00\90\00\00\F5!\00\04\17\0C\00\00\00\00\00\11\00\88\00\00\F5!\00\04\17\0C\00\00\00\00\00\10\00\80\00\00\F0!\00\04\17\0C\00\00\00\00\00\0F\00x\00\00\F0!\00\04\17\0C\00\00\00\00\00\0E\00p\00\00\F0!\00\04\17\0C\00\00\00\00\00\0D\00h\00\00\F0!\00\04\17\0C\00\00\00\00\00\0C\00`\00\00\F0!\00\04\17\0C\00\00\00\00\00\0B\00X\00\00\F5!\00\04\17\0C\00\00\00\00\00\0A\00P\00\00\F5!\00\04\17\0C\00\00\00\00\00\09\00H\00\00\F0!\00\04\17\0C\00\00\00\00\00\08\00@\00\00\F0!\00\04\17\0C\00\00\00\00\00\07\008\00\00\F0!\00\04\17\0C\00\00\00\00\00\06\000\00\00\F0!\00\04\17\0C\00\00\00\00\00\05\00(\00\00\F0!\00\04\17\0C\00\00\00\00\00\04\00 \00\00\F5!\00\04\17\0C\00\00\00\00\00\03\00\18\00\00\F5!\00\04\17\0C\00\00\00\00\00\02\00\10\00\00\F0\11\00\04\17\0C\00\00\00\00\00\01\00\08\00\00\F0!\00\04\17\0C\00\00\00\00\00\00\00\00\00\00\F0!\00\03\1B\FF\00\04\1D\04\00\18\00\00\00\04\1C\04\00\F8\0C\00\00\04\05\0C\00\01\00\00\00\01\00\00\00\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\F6\07\00\FE\00D\1C\00\01\00\87\00\80\07\98L\0B\00W\07\80\07\98L\00\00W\02\00\00\C8\F0\F1\07\E0\FF\00\C4?\08\0D\00\F7\0F\80\07\98\\\0E\00\F7\0F\80\07\98\\\05\00\07\05\80\7F\00N\F1\07\22\FE@\84\1F\00\02\00\07\05\80\7F\00N\03\00\07\05\80\7F\10O\06\00\07\05\80\7F\10N\F1\07\22\FE@\C4\1F\08\07\00\07\05\80\7F0N\09\00\17\05\80\7F\00N\0A\00\17\05\80\7F\10O\F1\07\82\FE@\84\1F\00\05\00\07\05\80\02(N\02\007\00\18\010[\04\00\A7\00\98\040[\F1\07 \FE\00\C4\1F\00\03\05g\00\A0\03\C0\\\00\02'\05\00\80\10L\05\F0\07\FA\00\00\00\01\F1\07@\FE\00\84\1F\00\06\F0\07\FA\00\00\00\01\0A\00G\07\80\07\98L\02\047\00\00\00\10\\\F1\07\22\FE@\C4\1F\08\03\00\07\FA\80\7F\006\04\00W\00\88\7F\00[\05\00g\00\88\7F [\F2\07\22\FE\00\8C\1F\00\09\00\07\FA\80\7F\006\02\027\05\00\08\10L\03\00\07\FA\80\01(6\F2\07 \FE@\CC\1F\00\09\00\07\FA\90\04 6\07\02\07\FA\80\7F\006\03\03G\00\A0\02\C0\\\F2\07\C0\FE\00\98\1F\00\00\09\87\05\00\80\10L\02\02\07\FA\90\03 6\02\03'\00\00\00\10\\\F1\07\C2\FE\00\D8\1F\00\08\02\97\05\00\08\10L\09\09g\06\00\80\10L\0C\02w\06\00\08\10L\F1\0F \FE\00\C4\1F\00\02\0D\07\00\00\81\D7[\07\00G\05\80\07\98L\10\00\F7\0F\80\07\98\\\F1\07 \FE\00\84\1F\00\0F\00\F7\0F\80\07\98\\\04\00\A7\00\80\07\98\\\05\00\B7\00\80\07\98\\\F2\07\02\FE\00\C4\03\00\03\0D\87 @\07\DF[\0D\0D\17\00\00\00\10\1C\07\02\07\00\00 \DC\EE\F5\07 \FE\00\D8\1F\00\11\00G\05\80\07\98L\0E\FF\E7\00\00\08\10\\\FF\0D\87\C1\FF\FF\1F\1C\ED\07\00\FE\00\D8\1F\00\0F\0E\F7\0F\80\0Bj[\06\10\97\00\00\80\10\\\13\04\07\00\00 \D4\EE\F2\0F\A0\F6\00\D8\1F\04\07\0F\C7\00\00\08\10\\\12\06\07\00\00 \D4\EE\12\127\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\12\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06G\00\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\FA\00 \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\87\00\00 \D4\EE\14\04\07\F4\01 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\C7\00\00 \D4\EE\12\04\07\EE\02 \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\07\01\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\E8\03 \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06G\01\00 \D4\EE\14\04\07\E2\04 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\87\01\00 \D4\EE\12\04\07\DC\05 \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\C7\01\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\D6\06 \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\07\02\00 \D4\EE\14\04\07\D0\07 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06G\02\00 \D4\EE\12\04\07\CA\08 \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\87\02\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\C4\09 \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\C7\02\00 \D4\EE\14\04\07\BE\0A \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\07\03\00 \D4\EE\12\04\07\B8\0B \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06G\03\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\B2\0C \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\87\03\00 \D4\EE\14\04\07\AC\0D \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\C7\03\00 \D4\EE\12\04\07\A6\0E \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\07\04\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\A0\0F \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06G\04\00 \D4\EE\14\04\07\9A\10 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\87\04\00 \D4\EE\12\04\07\94\11 \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\C7\04\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\8E\12 \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\07\05\00 \D4\EE\14\04\07\88\13 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06G\05\00 \D4\EE\12\04\07\82\14 \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\87\05\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07|\15 \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\C7\05\00 \D4\EE\14\04\07v\16 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\07\06\00 \D4\EE\12\04\07p\17 \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06G\06\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07j\18 \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\87\06\00 \D4\EE\14\04\07d\19 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\C7\06\00 \D4\EE\12\04\07^\1A \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\07\07\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07X\1B \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06G\07\00 \D4\EE\14\04\07R\1C \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\87\07\00 \D4\EE\12\04\07L\1D \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\C7\07\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07F\1E \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\07\08\00 \D4\EE\14\04\07@\1F \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06G\08\00 \D4\EE\12\04\07:  \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\87\08\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\074! \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\C7\08\00 \D4\EE\14\04\07.\22 \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\07\09\00 \D4\EE\12\04\07(# \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06G\09\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\22$ \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\87\09\00 \D4\EE\14\04\07\1C% \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\C7\09\00 \D4\EE\12\04\07\16& \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\07\0A\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\10' \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06G\0A\00 \D4\EE\14\04\07\0A( \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06\87\0A\00 \D4\EE\12\04\07\04) \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\C7\0A\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\FE) \D4\EE\12\127\01\00\00h\\\13\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\13\02\07\00\00 \DC\EE\12\06\07\0B\00 \D4\EE\14\04\07\F8* \D4\EE\F6\07A\FC\00\C4\1F\00\12\12G\01\00\00h\\\14\13'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07@\F6\00\D8\1F\04\11\06G\0B\00 \D4\EE\12\04\07\F2+ \D4\EE\11\11'\01\00\00h\\\F2\07 \FE\00\C4\1F\00\11\14\17\01\00\00X\\\11\02\07\00\00 \DC\EE\12\06\87\0B\00 \D4\EE\B2\07\C0\FC \C8\1F\00\13\04\07\EC, \D4\EE\12\127\01\00\00h\\\15\11'\01\00\00X\\\F1\07 \FE\00\C8\1E\00\15\02\07\00\00 \DC\EE\12\06\C7\0B\00 \D4\EE\13\04\07\E6- \D4\EE\F6\07A\FC\00\C4\1F\00\12\127\01\00\00h\\\14\15'\01\00\00X\\\14\02\07\00\00 \DC\EE\F1\07 \F6\00\B4\1F\00\11\06\07\0C\00 \D4\EE\12\04\07\E0. \D4\EE\10\10\87\0C\00\00\10\1C\F6\07A\FE\00\C4\1F\00\11\11'\01\00\00h\\\13\11G\01\00\00X\\\13\02\07\00\00 \DC\EE\F1\07 \16\00\84\1F\00\11\06G\0C\00 \D4\EE\12\04\07\DA/ \D4\EE\0F\FF\F7\00\00\08\10\\\F6\07 \FE\00\D8?\00\FF\10\07\06\FF\FF\1F\1C\07\0F\F7\0F\80\0Bj[\04\04\07\D40\00\10\1C\F7\07\C0\FE \88\1F\00\05\FFW\00\00\08\10\\\11\11'\01\00\00h\\\11\13\17\01\00\00X\\\F1\00\A0\FF\00\D8\1F\00\11\02\07\00\00 \DC\EE\0F\00\80S\FF\0F@\E2\0A\0AG\00\00\00\10\1C\F0\07\C0\FE\00\FC\1F\00\0B\FF\B7\00\00\08\10\\\0F\00\81H\FF\0F@\E2\0F\00\07\00\00\00\00\E3\FF\07\00\FC\00\80\1F\00\0F\00\07\FF\FF\0F@\E2\00\0F\07\00\00\00\B0P\00\0F\07\00\00\00\B0P\E0\07\00\FC\00\80\1F\00\00\0F\07\00\00\00\B0P\00\0F\07\00\00\00\B0P\00\0F\07\00\00\00\B0P\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\00\00\00\03\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00@\00\00\00\00\00\00\00\A0\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\0B\00\00\00\03\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\E0\00\00\00\00\00\00\00\B5\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\13\00\00\00\02\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\98\01\00\00\00\00\00\00`\00\00\00\00\00\00\00\02\00\00\00\03\00\00\00\08\00\00\00\00\00\00\00\18\00\00\00\00\00\00\007\00\00\00\00\00\00p\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\F8\01\00\00\00\00\00\000\00\00\00\00\00\00\00\05\00\00\00\00\00\00\00\04\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00T\00\00\00\00\00\00p\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00(\02\00\00\00\00\00\00\C4\01\00\00\00\00\00\00\05\00\00\00\07\00\00\00\04\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\84\00\00\00\01\00\00\00\02\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\EC\03\00\00\00\00\00\00\00\02\00\00\00\00\00\00\00\00\00\00\07\00\00\00\04\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00@\00\00\00\01\00\00\00\06\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\06\00\00\00\00\00\00@\0D\00\00\00\00\00\00\05\00\00\00\03\00\00\16 \00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\06\00\00\00\05\00\00\00@\15\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\A8\00\00\00\00\00\00\00\A8\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\01\00\00\00\05\00\00\00\EC\03\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00T\0F\00\00\00\00\00\00T\0F\00\00\00\00\00\00\08\00\00\00\00\00\00\00\01\00\00\00\05\00\00\00@\15\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\A8\00\00\00\00\00\00\00\A8\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\01\00\01\01H\00\00\00X\03\00\00\00\00\00\00R\03\00\00@\00\00\00\00\00\06\00=\00\00\00\00\00\00\00\00\00\00\00\11 \00\00\00\00\00\00\00\00\00\00\00\00\00\00>\09\00\00\00\00\00\00\00\00\00\00\00\00\00\00\F2 \0A\0A\0A\0A.version 6.0\0A.target sm_61\0A.address_size 64/\00\FA\19isible .entry matmul_kernel(\0A.param .u64\1B\00\11_\19\00?_0,#\00\0E\161#\00?f32#\00\02\1A2F\00\DF.ptr .align 11\00\02\1F31\00\1D\1F4\A8\00\0F\1F5#\00\0F\1F6#\00\0F\1F7#\00\0F\1F8#\00\0F\1F9\E0\00\1D/102\00\1E\1F1\87\00\0F/12$\00\10\1F3$\00\10\0F\7F\01\10\1F1\80\01\10/16\E6\00\1E\1F72\00\1E\0F\9F\01\10/19$\00\0F\1F2\1B\03\10\1F2\84\01\10\1F2\84\01\10\F1\0123\0A)\0A.maxntid 1,\03\00\F3\05\0A{\0A.reg .pred %p<3>;\12\00\87b32 %r<1\12\00\F2\0064 %rd<31>;\0A\0Aldr\00\03)\00O3, [w\00\02'];+\00\02B\00/14-\00\04\1F0-\00\01\1F5-\00\04\F3\054];\0Acvta.to.global.u3\00\226,:\00\0FN\00\00\1F7N\00\04\1F1{\00\01\1F8-\00\05\1F1|\00\07\129|\00\1E8O\00/20O\00\05\1F8O\00\06227,;\00q;\0Amov.ul\01\B14, %ctaid.x8\00\00-\00\03\1B\000d211\00\B34;\0Amad.lo.sH\00$2,z\01\05%\00\88d17;\0Amul'\00$3,.\00\954000;\0Aadd\1C\00\17,\\\01)23\1C\00'3,\FC\00\2223\AD\00\04F\01I3, 0\12\00\2228/\00\F5\023;\0A$L__BB0_1:\0Ashl!\00$5,(\00\192h\00&6,\8A\00d25;\0Ast0\01\00\86\02\10[\22\00\10]\1D\00\0A\82\00\132\94\01\0A\16\00230,b\01\03\16\00\01@\01\111\\\00\07\99\00(2:\80\00626,\EF\00!29\E4\01\07\81\00A%r5,\86\00>26]\1C\00\126\1C\00230]w\01!rn\ED\06B%r7,:\002%r6\EE\00\05\1A\00%8,\94\00\1F7\EE\00\07\1E8l\00\149\88\00/+4\8A\00\00$10\8B\00\10+\E7\01\0C\90\00211,C\00\00*\00\0B\92\00\02\8D\00\02\98\00\1F1\93\00\07\1A1\B8\01\03l\01\00\07\00\1D8X\02$9,\07\00\A28;\0Asetp.ne\A5\01%p1\1B\00\02\8F\02\95@%p1 bra \9F\01\0AK\00$8,\07\00\1A1\19\00$7,\07\00\1C4d\00\1624\00\04d\00\192d\00\C01;\0Aret;\0A\0A}\0A\00\00\00\00\00\00\00", align 8
@matmul_kernel_module = internal global ptr null
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 123, ptr @matmul_kernel_load, ptr null }]
@llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 123, ptr @matmul_kernel_unload, ptr null }]
@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8
@matmul_kernel_matmul_kernel_name = private unnamed_addr constant [14 x i8] c"matmul_kernel\00", align 1

declare i32 @MPI_Send(ptr, i32, i32, i32, i32, i32)

declare i32 @MPI_Recv(ptr, i32, i32, i32, i32, i32, ptr)

declare i32 @MPI_Barrier(i32)

declare i32 @MPI_Comm_size(i32, ptr)

declare i32 @MPI_Comm_rank(i32, ptr)

declare i32 @MPI_Init(ptr, ptr)

declare ptr @malloc(i64)

define void @matmul(i32 %0, i32 %1, i32 %2, ptr %3, ptr %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, ptr %10, ptr %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, ptr %17, ptr %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23) {
  %structArg61 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded59 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded60 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded15 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %17, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, ptr %18, 1
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %19, 2
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 3, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %22, 4, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %21, 3, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %23, 4, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %3, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %4, 1
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %5, 2
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %6, 3, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %8, 4, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %7, 3, 1
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %9, 4, 1
  %39 = call i32 @MPI_Init(ptr null, ptr null)
  %40 = alloca i32, align 4
  %41 = call i32 @MPI_Comm_rank(i32 1140850688, ptr %40)
  %42 = load i32, ptr %40, align 4
  %43 = alloca i32, align 4
  %44 = call i32 @MPI_Comm_size(i32 1140850688, ptr %43)
  %45 = load i32, ptr %43, align 4
  %46 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %47 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %48 = insertvalue { ptr, ptr, i64 } poison, ptr %46, 0
  %49 = insertvalue { ptr, ptr, i64 } %48, ptr %47, 1
  %50 = insertvalue { ptr, ptr, i64 } %49, i64 0, 2
  %51 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %52 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %53 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %54 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %55 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %56 = extractvalue { ptr, ptr, i64 } %50, 0
  %57 = extractvalue { ptr, ptr, i64 } %50, 1
  %58 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %56, 0
  %59 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %58, ptr %57, 1
  %60 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %59, i64 0, 2
  %61 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, i64 334, 3, 0
  %62 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, i64 1000, 4, 0
  %63 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %62, i64 1000, 3, 1
  %64 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %63, i64 1, 4, 1
  %65 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %66 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %67 = insertvalue { ptr, ptr, i64 } poison, ptr %65, 0
  %68 = insertvalue { ptr, ptr, i64 } %67, ptr %66, 1
  %69 = insertvalue { ptr, ptr, i64 } %68, i64 0, 2
  %70 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %71 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %72 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %73 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %74 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %75 = extractvalue { ptr, ptr, i64 } %69, 0
  %76 = extractvalue { ptr, ptr, i64 } %69, 1
  %77 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %75, 0
  %78 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %77, ptr %76, 1
  %79 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %78, i64 0, 2
  %80 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %79, i64 334, 3, 0
  %81 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %80, i64 1000, 4, 0
  %82 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %81, i64 1000, 3, 1
  %83 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %82, i64 1, 4, 1
  %84 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %85 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %86 = insertvalue { ptr, ptr, i64 } poison, ptr %84, 0
  %87 = insertvalue { ptr, ptr, i64 } %86, ptr %85, 1
  %88 = insertvalue { ptr, ptr, i64 } %87, i64 0, 2
  %89 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %90 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %91 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %92 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %93 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %94 = extractvalue { ptr, ptr, i64 } %88, 0
  %95 = extractvalue { ptr, ptr, i64 } %88, 1
  %96 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %94, 0
  %97 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %96, ptr %95, 1
  %98 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %97, i64 334000, 2
  %99 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %98, i64 333, 3, 0
  %100 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %99, i64 1000, 4, 0
  %101 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %100, i64 1000, 3, 1
  %102 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %101, i64 1, 4, 1
  %103 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %104 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %105 = insertvalue { ptr, ptr, i64 } poison, ptr %103, 0
  %106 = insertvalue { ptr, ptr, i64 } %105, ptr %104, 1
  %107 = insertvalue { ptr, ptr, i64 } %106, i64 0, 2
  %108 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %109 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %110 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %111 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %112 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %113 = extractvalue { ptr, ptr, i64 } %107, 0
  %114 = extractvalue { ptr, ptr, i64 } %107, 1
  %115 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %113, 0
  %116 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %115, ptr %114, 1
  %117 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %116, i64 334000, 2
  %118 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %117, i64 333, 3, 0
  %119 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %118, i64 1000, 4, 0
  %120 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %119, i64 1000, 3, 1
  %121 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %120, i64 1, 4, 1
  %122 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %123 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %124 = insertvalue { ptr, ptr, i64 } poison, ptr %122, 0
  %125 = insertvalue { ptr, ptr, i64 } %124, ptr %123, 1
  %126 = insertvalue { ptr, ptr, i64 } %125, i64 0, 2
  %127 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %128 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %129 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %130 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %131 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %132 = extractvalue { ptr, ptr, i64 } %126, 0
  %133 = extractvalue { ptr, ptr, i64 } %126, 1
  %134 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %132, 0
  %135 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %134, ptr %133, 1
  %136 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %135, i64 667000, 2
  %137 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %136, i64 333, 3, 0
  %138 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %137, i64 1000, 4, 0
  %139 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %138, i64 1000, 3, 1
  %140 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %139, i64 1, 4, 1
  %141 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %142 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %143 = insertvalue { ptr, ptr, i64 } poison, ptr %141, 0
  %144 = insertvalue { ptr, ptr, i64 } %143, ptr %142, 1
  %145 = insertvalue { ptr, ptr, i64 } %144, i64 0, 2
  %146 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %147 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %148 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %149 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %150 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %151 = extractvalue { ptr, ptr, i64 } %145, 0
  %152 = extractvalue { ptr, ptr, i64 } %145, 1
  %153 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %151, 0
  %154 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %153, ptr %152, 1
  %155 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %154, i64 667000, 2
  %156 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %155, i64 333, 3, 0
  %157 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %156, i64 1000, 4, 0
  %158 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %157, i64 1000, 3, 1
  %159 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %158, i64 1, 4, 1
  %160 = srem i32 0, %45
  %161 = icmp eq i32 %42, %160
  br i1 %161, label %162, label %163

162:                                              ; preds = %24
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %83, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %64, ptr %.reloaded15, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %162
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded15, ptr %gep_.reloaded15, align 8
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %11, ptr %gep_, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %163

163:                                              ; preds = %omp.par.exit, %24
  %164 = srem i32 1, %45
  %165 = icmp eq i32 %42, %164
  br i1 %165, label %166, label %167

166:                                              ; preds = %163
  %omp_global_thread_num16 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %121, ptr %.reloaded59, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %102, ptr %.reloaded60, align 8
  br label %omp_parallel63

omp_parallel63:                                   ; preds = %166
  %gep_.reloaded59 = getelementptr { ptr, ptr, ptr }, ptr %structArg61, i32 0, i32 0
  store ptr %.reloaded59, ptr %gep_.reloaded59, align 8
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %structArg61, i32 0, i32 1
  store ptr %.reloaded60, ptr %gep_.reloaded60, align 8
  %gep_62 = getelementptr { ptr, ptr, ptr }, ptr %structArg61, i32 0, i32 2
  store ptr %11, ptr %gep_62, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par.1, ptr %structArg61)
  br label %omp.par.exit22

omp.par.exit22:                                   ; preds = %omp_parallel63
  br label %167

167:                                              ; preds = %omp.par.exit22, %163
  %168 = srem i32 2, %45
  %169 = icmp eq i32 %42, %168
  br i1 %169, label %170, label %264

170:                                              ; preds = %167
  %171 = call ptr @malloc(i64 1332000)
  %172 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %159, 3, 0
  %173 = mul i64 %172, 1
  %174 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %159, 3, 1
  %175 = mul i64 %173, %174
  %176 = mul i64 %175, 4
  %177 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %159, 1
  %178 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %159, 2
  %179 = getelementptr float, ptr %177, i64 %178
  call void @llvm.memcpy.p0.p0.i64(ptr %171, ptr %179, i64 %176, i1 false)
  %180 = call ptr @mgpuStreamCreate()
  %181 = call ptr @mgpuMemAlloc(i64 1332000, ptr %180, i8 0)
  call void @mgpuMemcpy(ptr %181, ptr %171, i64 1332000, ptr %180)
  call void @mgpuStreamSynchronize(ptr %180)
  call void @mgpuStreamDestroy(ptr %180)
  %182 = call ptr @malloc(i64 1332000)
  %183 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %140, 3, 0
  %184 = mul i64 %183, 1
  %185 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %140, 3, 1
  %186 = mul i64 %184, %185
  %187 = mul i64 %186, 4
  %188 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %140, 1
  %189 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %140, 2
  %190 = getelementptr float, ptr %188, i64 %189
  call void @llvm.memcpy.p0.p0.i64(ptr %182, ptr %190, i64 %187, i1 false)
  %191 = call ptr @mgpuStreamCreate()
  %192 = call ptr @mgpuMemAlloc(i64 1332000, ptr %191, i8 0)
  call void @mgpuMemcpy(ptr %192, ptr %182, i64 1332000, ptr %191)
  call void @mgpuStreamSynchronize(ptr %191)
  call void @mgpuStreamDestroy(ptr %191)
  %193 = mul i64 %13, 1000
  %194 = getelementptr float, ptr null, i64 %193
  %195 = ptrtoint ptr %194 to i64
  %196 = call ptr @malloc(i64 %195)
  %197 = mul i64 %13, 1
  %198 = mul i64 %197, %14
  %199 = mul i64 %198, 4
  %200 = getelementptr float, ptr %11, i64 %12
  call void @llvm.memcpy.p0.p0.i64(ptr %196, ptr %200, i64 %199, i1 false)
  %201 = call ptr @mgpuStreamCreate()
  %202 = mul i64 %13, 1000
  %203 = getelementptr float, ptr null, i64 %202
  %204 = ptrtoint ptr %203 to i64
  %205 = call ptr @mgpuMemAlloc(i64 %204, ptr %201, i8 0)
  %206 = mul i64 %13, 1000
  %207 = getelementptr float, ptr null, i64 %206
  %208 = ptrtoint ptr %207 to i64
  call void @mgpuMemcpy(ptr %205, ptr %196, i64 %208, ptr %201)
  %209 = alloca %0, align 8
  %210 = alloca ptr, i64 24, align 8
  %211 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 0
  store i64 1, ptr %211, align 4
  %212 = getelementptr ptr, ptr %210, i32 0
  store ptr %211, ptr %212, align 8
  %213 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 1
  store i64 0, ptr %213, align 4
  %214 = getelementptr ptr, ptr %210, i32 1
  store ptr %213, ptr %214, align 8
  %215 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 2
  store float 0.000000e+00, ptr %215, align 4
  %216 = getelementptr ptr, ptr %210, i32 2
  store ptr %215, ptr %216, align 8
  %217 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 3
  store ptr %181, ptr %217, align 8
  %218 = getelementptr ptr, ptr %210, i32 3
  store ptr %217, ptr %218, align 8
  %219 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 4
  store ptr %181, ptr %219, align 8
  %220 = getelementptr ptr, ptr %210, i32 4
  store ptr %219, ptr %220, align 8
  %221 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 5
  store i64 0, ptr %221, align 4
  %222 = getelementptr ptr, ptr %210, i32 5
  store ptr %221, ptr %222, align 8
  %223 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 6
  store i64 333, ptr %223, align 4
  %224 = getelementptr ptr, ptr %210, i32 6
  store ptr %223, ptr %224, align 8
  %225 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 7
  store i64 1000, ptr %225, align 4
  %226 = getelementptr ptr, ptr %210, i32 7
  store ptr %225, ptr %226, align 8
  %227 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 8
  store i64 1000, ptr %227, align 4
  %228 = getelementptr ptr, ptr %210, i32 8
  store ptr %227, ptr %228, align 8
  %229 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 9
  store i64 1, ptr %229, align 4
  %230 = getelementptr ptr, ptr %210, i32 9
  store ptr %229, ptr %230, align 8
  %231 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 10
  store ptr %192, ptr %231, align 8
  %232 = getelementptr ptr, ptr %210, i32 10
  store ptr %231, ptr %232, align 8
  %233 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 11
  store ptr %192, ptr %233, align 8
  %234 = getelementptr ptr, ptr %210, i32 11
  store ptr %233, ptr %234, align 8
  %235 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 12
  store i64 0, ptr %235, align 4
  %236 = getelementptr ptr, ptr %210, i32 12
  store ptr %235, ptr %236, align 8
  %237 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 13
  store i64 333, ptr %237, align 4
  %238 = getelementptr ptr, ptr %210, i32 13
  store ptr %237, ptr %238, align 8
  %239 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 14
  store i64 1000, ptr %239, align 4
  %240 = getelementptr ptr, ptr %210, i32 14
  store ptr %239, ptr %240, align 8
  %241 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 15
  store i64 1000, ptr %241, align 4
  %242 = getelementptr ptr, ptr %210, i32 15
  store ptr %241, ptr %242, align 8
  %243 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 16
  store i64 1, ptr %243, align 4
  %244 = getelementptr ptr, ptr %210, i32 16
  store ptr %243, ptr %244, align 8
  %245 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 17
  store ptr %205, ptr %245, align 8
  %246 = getelementptr ptr, ptr %210, i32 17
  store ptr %245, ptr %246, align 8
  %247 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 18
  store ptr %205, ptr %247, align 8
  %248 = getelementptr ptr, ptr %210, i32 18
  store ptr %247, ptr %248, align 8
  %249 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 19
  store i64 0, ptr %249, align 4
  %250 = getelementptr ptr, ptr %210, i32 19
  store ptr %249, ptr %250, align 8
  %251 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 20
  store i64 %13, ptr %251, align 4
  %252 = getelementptr ptr, ptr %210, i32 20
  store ptr %251, ptr %252, align 8
  %253 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 21
  store i64 1000, ptr %253, align 4
  %254 = getelementptr ptr, ptr %210, i32 21
  store ptr %253, ptr %254, align 8
  %255 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 22
  store i64 1000, ptr %255, align 4
  %256 = getelementptr ptr, ptr %210, i32 22
  store ptr %255, ptr %256, align 8
  %257 = getelementptr inbounds nuw %0, ptr %209, i32 0, i32 23
  store i64 1, ptr %257, align 4
  %258 = getelementptr ptr, ptr %210, i32 23
  store ptr %257, ptr %258, align 8
  %259 = load ptr, ptr @matmul_kernel_module, align 8
  %260 = call ptr @mgpuModuleGetFunction(ptr %259, ptr @matmul_kernel_matmul_kernel_name)
  call void @mgpuLaunchKernel(ptr %260, i64 333, i64 1, i64 1, i64 1, i64 1, i64 1, i32 0, ptr %201, ptr %210, ptr null, i64 24)
  call void @mgpuMemcpy(ptr %171, ptr %181, i64 1332000, ptr %201)
  call void @mgpuStreamSynchronize(ptr %201)
  call void @mgpuStreamDestroy(ptr %201)
  %261 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %159, 1
  %262 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %159, 2
  %263 = getelementptr float, ptr %261, i64 %262
  call void @llvm.memcpy.p0.p0.i64(ptr %263, ptr %171, i64 1332000, i1 false)
  br label %264

264:                                              ; preds = %170, %167
  %265 = call i32 @MPI_Barrier(i32 1140850688)
  %266 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %267 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %268 = insertvalue { ptr, ptr, i64 } poison, ptr %266, 0
  %269 = insertvalue { ptr, ptr, i64 } %268, ptr %267, 1
  %270 = insertvalue { ptr, ptr, i64 } %269, i64 0, 2
  %271 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %272 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %273 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %274 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %275 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %276 = extractvalue { ptr, ptr, i64 } %270, 0
  %277 = extractvalue { ptr, ptr, i64 } %270, 1
  %278 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %276, 0
  %279 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %278, ptr %277, 1
  %280 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %279, i64 0, 2
  %281 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %280, i64 334000, 3, 0
  %282 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %281, i64 1000, 4, 0
  %283 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %282, i64 1000, 3, 1
  %284 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %283, i64 1, 4, 1
  %285 = icmp eq i32 %42, 0
  br i1 %285, label %286, label %297

286:                                              ; preds = %264
  %287 = srem i32 0, %45
  %288 = icmp ne i32 %287, 0
  br i1 %288, label %289, label %296

289:                                              ; preds = %286
  %290 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %284, 1
  %291 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %284, 2
  %292 = getelementptr float, ptr %290, i64 %291
  %293 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %284, 3, 0
  %294 = trunc i64 %293 to i32
  %295 = call i32 @MPI_Recv(ptr %292, i32 %294, i32 1275069450, i32 %287, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %296

296:                                              ; preds = %289, %286
  br label %308

297:                                              ; preds = %264
  %298 = srem i32 0, %45
  %299 = icmp eq i32 %42, %298
  br i1 %299, label %300, label %307

300:                                              ; preds = %297
  %301 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %284, 1
  %302 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %284, 2
  %303 = getelementptr float, ptr %301, i64 %302
  %304 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %284, 3, 0
  %305 = trunc i64 %304 to i32
  %306 = call i32 @MPI_Send(ptr %303, i32 %305, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %307

307:                                              ; preds = %300, %297
  br label %308

308:                                              ; preds = %296, %307
  %309 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %310 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %311 = insertvalue { ptr, ptr, i64 } poison, ptr %309, 0
  %312 = insertvalue { ptr, ptr, i64 } %311, ptr %310, 1
  %313 = insertvalue { ptr, ptr, i64 } %312, i64 0, 2
  %314 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %315 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %316 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %317 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %318 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %319 = extractvalue { ptr, ptr, i64 } %313, 0
  %320 = extractvalue { ptr, ptr, i64 } %313, 1
  %321 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %319, 0
  %322 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %321, ptr %320, 1
  %323 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %322, i64 334000, 2
  %324 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %323, i64 333000, 3, 0
  %325 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %324, i64 1000, 4, 0
  %326 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %325, i64 1000, 3, 1
  %327 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %326, i64 1, 4, 1
  %328 = icmp eq i32 %42, 0
  br i1 %328, label %329, label %340

329:                                              ; preds = %308
  %330 = srem i32 1, %45
  %331 = icmp ne i32 %330, 0
  br i1 %331, label %332, label %339

332:                                              ; preds = %329
  %333 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %327, 1
  %334 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %327, 2
  %335 = getelementptr float, ptr %333, i64 %334
  %336 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %327, 3, 0
  %337 = trunc i64 %336 to i32
  %338 = call i32 @MPI_Recv(ptr %335, i32 %337, i32 1275069450, i32 %330, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %339

339:                                              ; preds = %332, %329
  br label %351

340:                                              ; preds = %308
  %341 = srem i32 1, %45
  %342 = icmp eq i32 %42, %341
  br i1 %342, label %343, label %350

343:                                              ; preds = %340
  %344 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %327, 1
  %345 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %327, 2
  %346 = getelementptr float, ptr %344, i64 %345
  %347 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %327, 3, 0
  %348 = trunc i64 %347 to i32
  %349 = call i32 @MPI_Send(ptr %346, i32 %348, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %350

350:                                              ; preds = %343, %340
  br label %351

351:                                              ; preds = %339, %350
  %352 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %353 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %354 = insertvalue { ptr, ptr, i64 } poison, ptr %352, 0
  %355 = insertvalue { ptr, ptr, i64 } %354, ptr %353, 1
  %356 = insertvalue { ptr, ptr, i64 } %355, i64 0, 2
  %357 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %358 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %359 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %360 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %361 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %362 = extractvalue { ptr, ptr, i64 } %356, 0
  %363 = extractvalue { ptr, ptr, i64 } %356, 1
  %364 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %362, 0
  %365 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %364, ptr %363, 1
  %366 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %365, i64 667000, 2
  %367 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %366, i64 333000, 3, 0
  %368 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %367, i64 1000, 4, 0
  %369 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %368, i64 1000, 3, 1
  %370 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %369, i64 1, 4, 1
  %371 = icmp eq i32 %42, 0
  br i1 %371, label %372, label %383

372:                                              ; preds = %351
  %373 = srem i32 2, %45
  %374 = icmp ne i32 %373, 0
  br i1 %374, label %375, label %382

375:                                              ; preds = %372
  %376 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 1
  %377 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 2
  %378 = getelementptr float, ptr %376, i64 %377
  %379 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 3, 0
  %380 = trunc i64 %379 to i32
  %381 = call i32 @MPI_Recv(ptr %378, i32 %380, i32 1275069450, i32 %373, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %382

382:                                              ; preds = %375, %372
  br label %394

383:                                              ; preds = %351
  %384 = srem i32 2, %45
  %385 = icmp eq i32 %42, %384
  br i1 %385, label %386, label %393

386:                                              ; preds = %383
  %387 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 1
  %388 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 2
  %389 = getelementptr float, ptr %387, i64 %388
  %390 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %370, 3, 0
  %391 = trunc i64 %390 to i32
  %392 = call i32 @MPI_Send(ptr %389, i32 %391, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %393

393:                                              ; preds = %386, %383
  br label %394

394:                                              ; preds = %382, %393
  %395 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par.1(ptr noalias %tid.addr17, ptr noalias %zero.addr18, ptr %0) #0 {
omp.par.entry19:
  %gep_.reloaded59 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded59 = load ptr, ptr %gep_.reloaded59, align 8, !align !1
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded60 = load ptr, ptr %gep_.reloaded60, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter53 = alloca i32, align 4
  %p.lowerbound54 = alloca i64, align 8
  %p.upperbound55 = alloca i64, align 8
  %p.stride56 = alloca i64, align 8
  %tid.addr.local23 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr17, align 4
  store i32 %1, ptr %tid.addr.local23, align 4
  %tid24 = load i32, ptr %tid.addr.local23, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded59, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded60, align 8
  br label %omp.region.after_alloca30

omp.region.after_alloca30:                        ; preds = %omp.par.entry19
  br label %omp.region.after_alloca27

omp.region.after_alloca27:                        ; preds = %omp.region.after_alloca30
  br label %omp.par.region20

omp.par.region20:                                 ; preds = %omp.region.after_alloca27
  br label %omp.par.region29

omp.par.region29:                                 ; preds = %omp.par.region20
  br label %omp.wsloop.region32

omp.wsloop.region32:                              ; preds = %omp.par.region29
  br label %omp_loop.preheader33

omp_loop.preheader33:                             ; preds = %omp.wsloop.region32
  store i64 0, ptr %p.lowerbound54, align 4
  store i64 332, ptr %p.upperbound55, align 4
  store i64 1, ptr %p.stride56, align 4
  %omp_global_thread_num57 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num57, i32 34, ptr %p.lastiter53, ptr %p.lowerbound54, ptr %p.upperbound55, ptr %p.stride56, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound54, align 4
  %5 = load i64, ptr %p.upperbound55, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header34

omp_loop.header34:                                ; preds = %omp_loop.inc37, %omp_loop.preheader33
  %omp_loop.iv40 = phi i64 [ 0, %omp_loop.preheader33 ], [ %omp_loop.next42, %omp_loop.inc37 ]
  br label %omp_loop.cond35

omp_loop.cond35:                                  ; preds = %omp_loop.header34
  %omp_loop.cmp41 = icmp ult i64 %omp_loop.iv40, %7
  br i1 %omp_loop.cmp41, label %omp_loop.body36, label %omp_loop.exit38

omp_loop.exit38:                                  ; preds = %omp_loop.cond35
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num57)
  %omp_global_thread_num58 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num58)
  br label %omp_loop.after39

omp_loop.after39:                                 ; preds = %omp_loop.exit38
  br label %omp.region.cont31

omp.region.cont31:                                ; preds = %omp_loop.after39
  br label %omp.region.cont28

omp.region.cont28:                                ; preds = %omp.region.cont31
  br label %omp.par.pre_finalize21

omp.par.pre_finalize21:                           ; preds = %omp.region.cont28
  br label %omp.par.exit22.exitStub

omp_loop.body36:                                  ; preds = %omp_loop.cond35
  %8 = add i64 %omp_loop.iv40, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region44

omp.loop_nest.region44:                           ; preds = %omp_loop.body36
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region45

omp.loop_nest.region45:                           ; preds = %omp.loop_nest.region44
  br label %omp.loop_nest.region46

omp.loop_nest.region46:                           ; preds = %omp.loop_nest.region50, %omp.loop_nest.region45
  %12 = phi i64 [ %21, %omp.loop_nest.region50 ], [ 0, %omp.loop_nest.region45 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region47, label %omp.loop_nest.region51

omp.loop_nest.region51:                           ; preds = %omp.loop_nest.region46
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region52

omp.loop_nest.region52:                           ; preds = %omp.loop_nest.region51
  br label %omp.region.cont43

omp.region.cont43:                                ; preds = %omp.loop_nest.region52
  br label %omp_loop.inc37

omp_loop.inc37:                                   ; preds = %omp.region.cont43
  %omp_loop.next42 = add nuw i64 %omp_loop.iv40, 1
  br label %omp_loop.header34

omp.loop_nest.region47:                           ; preds = %omp.loop_nest.region46
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = getelementptr float, ptr %14, i32 334000
  %16 = mul nuw nsw i64 %10, 1000
  %17 = add nuw nsw i64 %16, %12
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  store float 0.000000e+00, ptr %18, align 4
  br label %omp.loop_nest.region48

omp.loop_nest.region48:                           ; preds = %omp.loop_nest.region49, %omp.loop_nest.region47
  %19 = phi i64 [ %45, %omp.loop_nest.region49 ], [ 0, %omp.loop_nest.region47 ]
  %20 = icmp slt i64 %19, 1000
  br i1 %20, label %omp.loop_nest.region49, label %omp.loop_nest.region50

omp.loop_nest.region50:                           ; preds = %omp.loop_nest.region48
  %21 = add i64 %12, 1
  br label %omp.loop_nest.region46

omp.loop_nest.region49:                           ; preds = %omp.loop_nest.region48
  %22 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %23 = getelementptr float, ptr %22, i32 334000
  %24 = mul nuw nsw i64 %10, 1000
  %25 = add nuw nsw i64 %24, %19
  %26 = getelementptr inbounds nuw float, ptr %23, i64 %25
  %27 = load float, ptr %26, align 4
  %28 = mul nuw nsw i64 %19, 1000
  %29 = add nuw nsw i64 %28, %12
  %30 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %29
  %31 = load float, ptr %30, align 4
  %32 = fmul float %27, %31
  %33 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %34 = getelementptr float, ptr %33, i32 334000
  %35 = mul nuw nsw i64 %10, 1000
  %36 = add nuw nsw i64 %35, %12
  %37 = getelementptr inbounds nuw float, ptr %34, i64 %36
  %38 = load float, ptr %37, align 4
  %39 = fadd float %38, %32
  %40 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %41 = getelementptr float, ptr %40, i32 334000
  %42 = mul nuw nsw i64 %10, 1000
  %43 = add nuw nsw i64 %42, %12
  %44 = getelementptr inbounds nuw float, ptr %41, i64 %43
  store float %39, ptr %44, align 4
  %45 = add i64 %19, 1
  br label %omp.loop_nest.region48

omp.par.exit22.exitStub:                          ; preds = %omp.par.pre_finalize21
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded15 = load ptr, ptr %gep_.reloaded15, align 8, !align !1
  %gep_ = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !2
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded15, align 8
  br label %omp.region.after_alloca2

omp.region.after_alloca2:                         ; preds = %omp.par.entry
  br label %omp.region.after_alloca

omp.region.after_alloca:                          ; preds = %omp.region.after_alloca2
  br label %omp.par.region

omp.par.region:                                   ; preds = %omp.region.after_alloca
  br label %omp.par.region1

omp.par.region1:                                  ; preds = %omp.par.region
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp.par.region1
  br label %omp_loop.preheader

omp_loop.preheader:                               ; preds = %omp.wsloop.region
  store i64 0, ptr %p.lowerbound, align 4
  store i64 333, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num13 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num13, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
  %4 = load i64, ptr %p.lowerbound, align 4
  %5 = load i64, ptr %p.upperbound, align 4
  %6 = sub i64 %5, %4
  %7 = add i64 %6, 1
  br label %omp_loop.header

omp_loop.header:                                  ; preds = %omp_loop.inc, %omp_loop.preheader
  %omp_loop.iv = phi i64 [ 0, %omp_loop.preheader ], [ %omp_loop.next, %omp_loop.inc ]
  br label %omp_loop.cond

omp_loop.cond:                                    ; preds = %omp_loop.header
  %omp_loop.cmp = icmp ult i64 %omp_loop.iv, %7
  br i1 %omp_loop.cmp, label %omp_loop.body, label %omp_loop.exit

omp_loop.exit:                                    ; preds = %omp_loop.cond
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num13)
  %omp_global_thread_num14 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num14)
  br label %omp_loop.after

omp_loop.after:                                   ; preds = %omp_loop.exit
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp_loop.after
  br label %omp.region.cont

omp.region.cont:                                  ; preds = %omp.region.cont3
  br label %omp.par.pre_finalize

omp.par.pre_finalize:                             ; preds = %omp.region.cont
  br label %omp.par.exit.exitStub

omp_loop.body:                                    ; preds = %omp_loop.cond
  %8 = add i64 %omp_loop.iv, %4
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body
  %11 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region5

omp.loop_nest.region5:                            ; preds = %omp.loop_nest.region
  br label %omp.loop_nest.region6

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region10, %omp.loop_nest.region5
  %12 = phi i64 [ %20, %omp.loop_nest.region10 ], [ 0, %omp.loop_nest.region5 ]
  %13 = icmp slt i64 %12, 1000
  br i1 %13, label %omp.loop_nest.region7, label %omp.loop_nest.region11

omp.loop_nest.region11:                           ; preds = %omp.loop_nest.region6
  call void @llvm.stackrestore.p0(ptr %11)
  br label %omp.loop_nest.region12

omp.loop_nest.region12:                           ; preds = %omp.loop_nest.region11
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region12
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.loop_nest.region7:                            ; preds = %omp.loop_nest.region6
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %15 = mul nuw nsw i64 %10, 1000
  %16 = add nuw nsw i64 %15, %12
  %17 = getelementptr inbounds nuw float, ptr %14, i64 %16
  store float 0.000000e+00, ptr %17, align 4
  br label %omp.loop_nest.region8

omp.loop_nest.region8:                            ; preds = %omp.loop_nest.region9, %omp.loop_nest.region7
  %18 = phi i64 [ %41, %omp.loop_nest.region9 ], [ 0, %omp.loop_nest.region7 ]
  %19 = icmp slt i64 %18, 1000
  br i1 %19, label %omp.loop_nest.region9, label %omp.loop_nest.region10

omp.loop_nest.region10:                           ; preds = %omp.loop_nest.region8
  %20 = add i64 %12, 1
  br label %omp.loop_nest.region6

omp.loop_nest.region9:                            ; preds = %omp.loop_nest.region8
  %21 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %22 = mul nuw nsw i64 %10, 1000
  %23 = add nuw nsw i64 %22, %18
  %24 = getelementptr inbounds nuw float, ptr %21, i64 %23
  %25 = load float, ptr %24, align 4
  %26 = mul nuw nsw i64 %18, 1000
  %27 = add nuw nsw i64 %26, %12
  %28 = getelementptr inbounds nuw float, ptr %loadgep_, i64 %27
  %29 = load float, ptr %28, align 4
  %30 = fmul float %25, %29
  %31 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %32 = mul nuw nsw i64 %10, 1000
  %33 = add nuw nsw i64 %32, %12
  %34 = getelementptr inbounds nuw float, ptr %31, i64 %33
  %35 = load float, ptr %34, align 4
  %36 = fadd float %35, %30
  %37 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %38 = mul nuw nsw i64 %10, 1000
  %39 = add nuw nsw i64 %38, %12
  %40 = getelementptr inbounds nuw float, ptr %37, i64 %39
  store float %36, ptr %40, align 4
  %41 = add i64 %18, 1
  br label %omp.loop_nest.region8

omp.par.exit.exitStub:                            ; preds = %omp.par.pre_finalize
  ret void
}

declare ptr @mgpuStreamCreate()

declare ptr @mgpuMemAlloc(i64, ptr, i8)

declare void @mgpuMemcpy(ptr, ptr, i64, ptr)

declare void @mgpuStreamSynchronize(ptr)

declare void @mgpuStreamDestroy(ptr)

define internal void @matmul_kernel_load() section ".text.startup" {
entry:
  %0 = call ptr @mgpuModuleLoad(ptr @matmul_kernel_binary, i64 6616)
  store ptr %0, ptr @matmul_kernel_module, align 8
  ret void
}

declare ptr @mgpuModuleLoad(ptr, i64)

define internal void @matmul_kernel_unload() section ".text.startup" {
entry:
  %0 = load ptr, ptr @matmul_kernel_module, align 8
  call void @mgpuModuleUnload(ptr %0)
  ret void
}

declare void @mgpuModuleUnload(ptr)

; Function Attrs: nounwind
declare i32 @__kmpc_global_thread_num(ptr) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #1

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore.p0(ptr) #1

; Function Attrs: nounwind
declare void @__kmpc_for_static_init_8u(ptr, i32, i32, ptr, ptr, ptr, ptr, i64, i64) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_fini(ptr, i32) #0

; Function Attrs: convergent nounwind
declare void @__kmpc_barrier(ptr, i32) #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #3

declare ptr @mgpuModuleGetFunction(ptr, ptr)

declare void @mgpuLaunchKernel(ptr, i64, i64, i64, i64, i64, i64, i32, ptr, ptr, ptr, i64)

; Function Attrs: nounwind
declare !callback !3 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind willreturn }
attributes #2 = { convergent nounwind }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{i64 8}
!2 = !{i64 1}
!3 = !{!4}
!4 = !{i64 2, i64 -1, i64 -1, i1 true}
