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
  %structArg63 = alloca { ptr, ptr, ptr }, align 8
  %structArg = alloca { ptr, ptr, ptr }, align 8
  %.reloaded60 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded61 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded62 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded15 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
  %.reloaded16 = alloca { ptr, ptr, i64, [2 x i64], [2 x i64] }, align 8
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
  %53 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %54 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %55 = insertvalue { ptr, ptr, i64 } poison, ptr %53, 0
  %56 = insertvalue { ptr, ptr, i64 } %55, ptr %54, 1
  %57 = insertvalue { ptr, ptr, i64 } %56, i64 0, 2
  %58 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %59 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %60 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %61 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %62 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %63 = extractvalue { ptr, ptr, i64 } %57, 0
  %64 = extractvalue { ptr, ptr, i64 } %57, 1
  %65 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %63, 0
  %66 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %65, ptr %64, 1
  %67 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %66, i64 0, 2
  %68 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %67, i64 334, 3, 0
  %69 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, i64 1000, 4, 0
  %70 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, i64 1000, 3, 1
  %71 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %70, i64 1, 4, 1
  %72 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 0
  %73 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %74 = insertvalue { ptr, ptr, i64 } poison, ptr %72, 0
  %75 = insertvalue { ptr, ptr, i64 } %74, ptr %73, 1
  %76 = insertvalue { ptr, ptr, i64 } %75, i64 0, 2
  %77 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 2
  %78 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 0
  %79 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 1
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %81 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %82 = extractvalue { ptr, ptr, i64 } %76, 0
  %83 = extractvalue { ptr, ptr, i64 } %76, 1
  %84 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %82, 0
  %85 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %84, ptr %83, 1
  %86 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %85, i64 0, 2
  %87 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %86, i64 334, 3, 0
  %88 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %87, i64 1000, 4, 0
  %89 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %88, i64 1000, 3, 1
  %90 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %89, i64 1, 4, 1
  %91 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %92 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %93 = insertvalue { ptr, ptr, i64 } poison, ptr %91, 0
  %94 = insertvalue { ptr, ptr, i64 } %93, ptr %92, 1
  %95 = insertvalue { ptr, ptr, i64 } %94, i64 0, 2
  %96 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %97 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %98 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %99 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %100 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %101 = extractvalue { ptr, ptr, i64 } %95, 0
  %102 = extractvalue { ptr, ptr, i64 } %95, 1
  %103 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %101, 0
  %104 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %103, ptr %102, 1
  %105 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %104, i64 0, 2
  %106 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %105, i64 334, 3, 0
  %107 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %106, i64 1000, 4, 0
  %108 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %107, i64 1000, 3, 1
  %109 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %108, i64 1, 4, 1
  %110 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %111 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %112 = insertvalue { ptr, ptr, i64 } poison, ptr %110, 0
  %113 = insertvalue { ptr, ptr, i64 } %112, ptr %111, 1
  %114 = insertvalue { ptr, ptr, i64 } %113, i64 0, 2
  %115 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %116 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %117 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %118 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %119 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %120 = extractvalue { ptr, ptr, i64 } %114, 0
  %121 = extractvalue { ptr, ptr, i64 } %114, 1
  %122 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %120, 0
  %123 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %122, ptr %121, 1
  %124 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %123, i64 334000, 2
  %125 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %124, i64 333, 3, 0
  %126 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %125, i64 1000, 4, 0
  %127 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %126, i64 1000, 3, 1
  %128 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %127, i64 1, 4, 1
  %129 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 0
  %130 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %131 = insertvalue { ptr, ptr, i64 } poison, ptr %129, 0
  %132 = insertvalue { ptr, ptr, i64 } %131, ptr %130, 1
  %133 = insertvalue { ptr, ptr, i64 } %132, i64 0, 2
  %134 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 2
  %135 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 0
  %136 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 1
  %137 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %138 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %139 = extractvalue { ptr, ptr, i64 } %133, 0
  %140 = extractvalue { ptr, ptr, i64 } %133, 1
  %141 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %139, 0
  %142 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %141, ptr %140, 1
  %143 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %142, i64 334000, 2
  %144 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %143, i64 333, 3, 0
  %145 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %144, i64 1000, 4, 0
  %146 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %145, i64 1000, 3, 1
  %147 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %146, i64 1, 4, 1
  %148 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %149 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %150 = insertvalue { ptr, ptr, i64 } poison, ptr %148, 0
  %151 = insertvalue { ptr, ptr, i64 } %150, ptr %149, 1
  %152 = insertvalue { ptr, ptr, i64 } %151, i64 0, 2
  %153 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %154 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %155 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %156 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %157 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %158 = extractvalue { ptr, ptr, i64 } %152, 0
  %159 = extractvalue { ptr, ptr, i64 } %152, 1
  %160 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %158, 0
  %161 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %160, ptr %159, 1
  %162 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %161, i64 334000, 2
  %163 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %162, i64 333, 3, 0
  %164 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %163, i64 1000, 4, 0
  %165 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %164, i64 1000, 3, 1
  %166 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %165, i64 1, 4, 1
  %167 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 0
  %168 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %169 = insertvalue { ptr, ptr, i64 } poison, ptr %167, 0
  %170 = insertvalue { ptr, ptr, i64 } %169, ptr %168, 1
  %171 = insertvalue { ptr, ptr, i64 } %170, i64 0, 2
  %172 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %173 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 0
  %174 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 3, 1
  %175 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %176 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %177 = extractvalue { ptr, ptr, i64 } %171, 0
  %178 = extractvalue { ptr, ptr, i64 } %171, 1
  %179 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %177, 0
  %180 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %179, ptr %178, 1
  %181 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %180, i64 667000, 2
  %182 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %181, i64 333, 3, 0
  %183 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %182, i64 1000, 4, 0
  %184 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %183, i64 1000, 3, 1
  %185 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %184, i64 1, 4, 1
  %186 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 0
  %187 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %188 = insertvalue { ptr, ptr, i64 } poison, ptr %186, 0
  %189 = insertvalue { ptr, ptr, i64 } %188, ptr %187, 1
  %190 = insertvalue { ptr, ptr, i64 } %189, i64 0, 2
  %191 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 2
  %192 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 0
  %193 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 3, 1
  %194 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %195 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %196 = extractvalue { ptr, ptr, i64 } %190, 0
  %197 = extractvalue { ptr, ptr, i64 } %190, 1
  %198 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %196, 0
  %199 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %198, ptr %197, 1
  %200 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %199, i64 667000, 2
  %201 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %200, i64 333, 3, 0
  %202 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %201, i64 1000, 4, 0
  %203 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %202, i64 1000, 3, 1
  %204 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %203, i64 1, 4, 1
  %205 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %206 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %207 = insertvalue { ptr, ptr, i64 } poison, ptr %205, 0
  %208 = insertvalue { ptr, ptr, i64 } %207, ptr %206, 1
  %209 = insertvalue { ptr, ptr, i64 } %208, i64 0, 2
  %210 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %211 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %212 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %213 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %214 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %215 = extractvalue { ptr, ptr, i64 } %209, 0
  %216 = extractvalue { ptr, ptr, i64 } %209, 1
  %217 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %215, 0
  %218 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %217, ptr %216, 1
  %219 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %218, i64 667000, 2
  %220 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %219, i64 333, 3, 0
  %221 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %220, i64 1000, 4, 0
  %222 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %221, i64 1000, 3, 1
  %223 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %222, i64 1, 4, 1
  %224 = srem i32 0, %52
  %225 = icmp eq i32 %49, %224
  br i1 %225, label %226, label %227

226:                                              ; preds = %24
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %109, ptr %.reloaded, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %90, ptr %.reloaded15, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %71, ptr %.reloaded16, align 8
  br label %omp_parallel

omp_parallel:                                     ; preds = %226
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 0
  store ptr %.reloaded, ptr %gep_.reloaded, align 8
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 1
  store ptr %.reloaded15, ptr %gep_.reloaded15, align 8
  %gep_.reloaded16 = getelementptr { ptr, ptr, ptr }, ptr %structArg, i32 0, i32 2
  store ptr %.reloaded16, ptr %gep_.reloaded16, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  br label %227

227:                                              ; preds = %omp.par.exit, %24
  %228 = srem i32 1, %52
  %229 = icmp eq i32 %49, %228
  br i1 %229, label %230, label %231

230:                                              ; preds = %227
  %omp_global_thread_num17 = call i32 @__kmpc_global_thread_num(ptr @1)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %166, ptr %.reloaded60, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %147, ptr %.reloaded61, align 8
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %128, ptr %.reloaded62, align 8
  br label %omp_parallel64

omp_parallel64:                                   ; preds = %230
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %structArg63, i32 0, i32 0
  store ptr %.reloaded60, ptr %gep_.reloaded60, align 8
  %gep_.reloaded61 = getelementptr { ptr, ptr, ptr }, ptr %structArg63, i32 0, i32 1
  store ptr %.reloaded61, ptr %gep_.reloaded61, align 8
  %gep_.reloaded62 = getelementptr { ptr, ptr, ptr }, ptr %structArg63, i32 0, i32 2
  store ptr %.reloaded62, ptr %gep_.reloaded62, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @matmul..omp_par.1, ptr %structArg63)
  br label %omp.par.exit23

omp.par.exit23:                                   ; preds = %omp_parallel64
  br label %231

231:                                              ; preds = %omp.par.exit23, %227
  %232 = srem i32 2, %52
  %233 = icmp eq i32 %49, %232
  br i1 %233, label %234, label %321

234:                                              ; preds = %231
  %235 = call ptr @malloc(i64 1332000)
  %236 = call ptr @malloc(i64 1332000)
  %237 = call ptr @malloc(i64 1332000)
  %238 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 3, 0
  %239 = mul i64 %238, 1
  %240 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 3, 1
  %241 = mul i64 %239, %240
  %242 = mul i64 %241, 4
  %243 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 1
  %244 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 2
  %245 = getelementptr float, ptr %243, i64 %244
  call void @llvm.memcpy.p0.p0.i64(ptr %235, ptr %245, i64 %242, i1 false)
  %246 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, 3, 0
  %247 = mul i64 %246, 1
  %248 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, 3, 1
  %249 = mul i64 %247, %248
  %250 = mul i64 %249, 4
  %251 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, 1
  %252 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %185, 2
  %253 = getelementptr float, ptr %251, i64 %252
  call void @llvm.memcpy.p0.p0.i64(ptr %236, ptr %253, i64 %250, i1 false)
  %254 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, 3, 0
  %255 = mul i64 %254, 1
  %256 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, 3, 1
  %257 = mul i64 %255, %256
  %258 = mul i64 %257, 4
  %259 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, 1
  %260 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, 2
  %261 = getelementptr float, ptr %259, i64 %260
  call void @llvm.memcpy.p0.p0.i64(ptr %237, ptr %261, i64 %258, i1 false)
  %262 = call ptr @mgpuStreamCreate()
  %263 = call ptr @mgpuMemAlloc(i64 1332000, ptr %262, i8 0)
  %264 = call ptr @mgpuMemAlloc(i64 1332000, ptr %262, i8 0)
  %265 = call ptr @mgpuMemAlloc(i64 1332000, ptr %262, i8 0)
  call void @mgpuMemcpy(ptr %263, ptr %235, i64 1332000, ptr %262)
  call void @mgpuMemcpy(ptr %264, ptr %236, i64 1332000, ptr %262)
  call void @mgpuMemcpy(ptr %265, ptr %237, i64 1332000, ptr %262)
  %266 = alloca %0, align 8
  %267 = alloca ptr, i64 24, align 8
  %268 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 0
  store i64 1, ptr %268, align 4
  %269 = getelementptr ptr, ptr %267, i32 0
  store ptr %268, ptr %269, align 8
  %270 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 1
  store i64 0, ptr %270, align 4
  %271 = getelementptr ptr, ptr %267, i32 1
  store ptr %270, ptr %271, align 8
  %272 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 2
  store float 0.000000e+00, ptr %272, align 4
  %273 = getelementptr ptr, ptr %267, i32 2
  store ptr %272, ptr %273, align 8
  %274 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 3
  store ptr %263, ptr %274, align 8
  %275 = getelementptr ptr, ptr %267, i32 3
  store ptr %274, ptr %275, align 8
  %276 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 4
  store ptr %263, ptr %276, align 8
  %277 = getelementptr ptr, ptr %267, i32 4
  store ptr %276, ptr %277, align 8
  %278 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 5
  store i64 0, ptr %278, align 4
  %279 = getelementptr ptr, ptr %267, i32 5
  store ptr %278, ptr %279, align 8
  %280 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 6
  store i64 333, ptr %280, align 4
  %281 = getelementptr ptr, ptr %267, i32 6
  store ptr %280, ptr %281, align 8
  %282 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 7
  store i64 1000, ptr %282, align 4
  %283 = getelementptr ptr, ptr %267, i32 7
  store ptr %282, ptr %283, align 8
  %284 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 8
  store i64 1000, ptr %284, align 4
  %285 = getelementptr ptr, ptr %267, i32 8
  store ptr %284, ptr %285, align 8
  %286 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 9
  store i64 1, ptr %286, align 4
  %287 = getelementptr ptr, ptr %267, i32 9
  store ptr %286, ptr %287, align 8
  %288 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 10
  store ptr %265, ptr %288, align 8
  %289 = getelementptr ptr, ptr %267, i32 10
  store ptr %288, ptr %289, align 8
  %290 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 11
  store ptr %265, ptr %290, align 8
  %291 = getelementptr ptr, ptr %267, i32 11
  store ptr %290, ptr %291, align 8
  %292 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 12
  store i64 0, ptr %292, align 4
  %293 = getelementptr ptr, ptr %267, i32 12
  store ptr %292, ptr %293, align 8
  %294 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 13
  store i64 333, ptr %294, align 4
  %295 = getelementptr ptr, ptr %267, i32 13
  store ptr %294, ptr %295, align 8
  %296 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 14
  store i64 1000, ptr %296, align 4
  %297 = getelementptr ptr, ptr %267, i32 14
  store ptr %296, ptr %297, align 8
  %298 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 15
  store i64 1000, ptr %298, align 4
  %299 = getelementptr ptr, ptr %267, i32 15
  store ptr %298, ptr %299, align 8
  %300 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 16
  store i64 1, ptr %300, align 4
  %301 = getelementptr ptr, ptr %267, i32 16
  store ptr %300, ptr %301, align 8
  %302 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 17
  store ptr %264, ptr %302, align 8
  %303 = getelementptr ptr, ptr %267, i32 17
  store ptr %302, ptr %303, align 8
  %304 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 18
  store ptr %264, ptr %304, align 8
  %305 = getelementptr ptr, ptr %267, i32 18
  store ptr %304, ptr %305, align 8
  %306 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 19
  store i64 0, ptr %306, align 4
  %307 = getelementptr ptr, ptr %267, i32 19
  store ptr %306, ptr %307, align 8
  %308 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 20
  store i64 333, ptr %308, align 4
  %309 = getelementptr ptr, ptr %267, i32 20
  store ptr %308, ptr %309, align 8
  %310 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 21
  store i64 1000, ptr %310, align 4
  %311 = getelementptr ptr, ptr %267, i32 21
  store ptr %310, ptr %311, align 8
  %312 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 22
  store i64 1000, ptr %312, align 4
  %313 = getelementptr ptr, ptr %267, i32 22
  store ptr %312, ptr %313, align 8
  %314 = getelementptr inbounds nuw %0, ptr %266, i32 0, i32 23
  store i64 1, ptr %314, align 4
  %315 = getelementptr ptr, ptr %267, i32 23
  store ptr %314, ptr %315, align 8
  %316 = load ptr, ptr @matmul_kernel_module, align 8
  %317 = call ptr @mgpuModuleGetFunction(ptr %316, ptr @matmul_kernel_matmul_kernel_name)
  call void @mgpuLaunchKernel(ptr %317, i64 333, i64 1, i64 1, i64 1, i64 1, i64 1, i32 0, ptr %262, ptr %267, ptr null, i64 24)
  call void @mgpuMemcpy(ptr %235, ptr %263, i64 1332000, ptr %262)
  call void @mgpuStreamSynchronize(ptr %262)
  call void @mgpuStreamDestroy(ptr %262)
  %318 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 1
  %319 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %223, 2
  %320 = getelementptr float, ptr %318, i64 %319
  call void @llvm.memcpy.p0.p0.i64(ptr %320, ptr %235, i64 1332000, i1 false)
  br label %321

321:                                              ; preds = %234, %231
  %322 = call i32 @MPI_Barrier(i32 1140850688)
  %323 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %324 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %325 = insertvalue { ptr, ptr, i64 } poison, ptr %323, 0
  %326 = insertvalue { ptr, ptr, i64 } %325, ptr %324, 1
  %327 = insertvalue { ptr, ptr, i64 } %326, i64 0, 2
  %328 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %329 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %330 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %331 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %332 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %333 = extractvalue { ptr, ptr, i64 } %327, 0
  %334 = extractvalue { ptr, ptr, i64 } %327, 1
  %335 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %333, 0
  %336 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %335, ptr %334, 1
  %337 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %336, i64 0, 2
  %338 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %337, i64 334000, 3, 0
  %339 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %338, i64 1000, 4, 0
  %340 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %339, i64 1000, 3, 1
  %341 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %340, i64 1, 4, 1
  %342 = icmp eq i32 %49, 0
  br i1 %342, label %343, label %354

343:                                              ; preds = %321
  %344 = srem i32 0, %52
  %345 = icmp ne i32 %344, 0
  br i1 %345, label %346, label %353

346:                                              ; preds = %343
  %347 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 1
  %348 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 2
  %349 = getelementptr float, ptr %347, i64 %348
  %350 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 3, 0
  %351 = trunc i64 %350 to i32
  %352 = call i32 @MPI_Recv(ptr %349, i32 %351, i32 1275069450, i32 %344, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %353

353:                                              ; preds = %346, %343
  br label %365

354:                                              ; preds = %321
  %355 = srem i32 0, %52
  %356 = icmp eq i32 %49, %355
  br i1 %356, label %357, label %364

357:                                              ; preds = %354
  %358 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 1
  %359 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 2
  %360 = getelementptr float, ptr %358, i64 %359
  %361 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %341, 3, 0
  %362 = trunc i64 %361 to i32
  %363 = call i32 @MPI_Send(ptr %360, i32 %362, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %364

364:                                              ; preds = %357, %354
  br label %365

365:                                              ; preds = %353, %364
  %366 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %367 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %368 = insertvalue { ptr, ptr, i64 } poison, ptr %366, 0
  %369 = insertvalue { ptr, ptr, i64 } %368, ptr %367, 1
  %370 = insertvalue { ptr, ptr, i64 } %369, i64 0, 2
  %371 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %372 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %373 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %374 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %375 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %376 = extractvalue { ptr, ptr, i64 } %370, 0
  %377 = extractvalue { ptr, ptr, i64 } %370, 1
  %378 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %376, 0
  %379 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %378, ptr %377, 1
  %380 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %379, i64 334000, 2
  %381 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %380, i64 333000, 3, 0
  %382 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %381, i64 1000, 4, 0
  %383 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %382, i64 1000, 3, 1
  %384 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %383, i64 1, 4, 1
  %385 = icmp eq i32 %49, 0
  br i1 %385, label %386, label %397

386:                                              ; preds = %365
  %387 = srem i32 1, %52
  %388 = icmp ne i32 %387, 0
  br i1 %388, label %389, label %396

389:                                              ; preds = %386
  %390 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %384, 1
  %391 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %384, 2
  %392 = getelementptr float, ptr %390, i64 %391
  %393 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %384, 3, 0
  %394 = trunc i64 %393 to i32
  %395 = call i32 @MPI_Recv(ptr %392, i32 %394, i32 1275069450, i32 %387, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %396

396:                                              ; preds = %389, %386
  br label %408

397:                                              ; preds = %365
  %398 = srem i32 1, %52
  %399 = icmp eq i32 %49, %398
  br i1 %399, label %400, label %407

400:                                              ; preds = %397
  %401 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %384, 1
  %402 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %384, 2
  %403 = getelementptr float, ptr %401, i64 %402
  %404 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %384, 3, 0
  %405 = trunc i64 %404 to i32
  %406 = call i32 @MPI_Send(ptr %403, i32 %405, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %407

407:                                              ; preds = %400, %397
  br label %408

408:                                              ; preds = %396, %407
  %409 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 0
  %410 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %411 = insertvalue { ptr, ptr, i64 } poison, ptr %409, 0
  %412 = insertvalue { ptr, ptr, i64 } %411, ptr %410, 1
  %413 = insertvalue { ptr, ptr, i64 } %412, i64 0, 2
  %414 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 2
  %415 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 0
  %416 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 3, 1
  %417 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 0
  %418 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 4, 1
  %419 = extractvalue { ptr, ptr, i64 } %413, 0
  %420 = extractvalue { ptr, ptr, i64 } %413, 1
  %421 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %419, 0
  %422 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %421, ptr %420, 1
  %423 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %422, i64 667000, 2
  %424 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %423, i64 333000, 3, 0
  %425 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %424, i64 1000, 4, 0
  %426 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %425, i64 1000, 3, 1
  %427 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %426, i64 1, 4, 1
  %428 = icmp eq i32 %49, 0
  br i1 %428, label %429, label %440

429:                                              ; preds = %408
  %430 = srem i32 2, %52
  %431 = icmp ne i32 %430, 0
  br i1 %431, label %432, label %439

432:                                              ; preds = %429
  %433 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %427, 1
  %434 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %427, 2
  %435 = getelementptr float, ptr %433, i64 %434
  %436 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %427, 3, 0
  %437 = trunc i64 %436 to i32
  %438 = call i32 @MPI_Recv(ptr %435, i32 %437, i32 1275069450, i32 %430, i32 0, i32 1140850688, ptr inttoptr (i64 1 to ptr))
  br label %439

439:                                              ; preds = %432, %429
  br label %451

440:                                              ; preds = %408
  %441 = srem i32 2, %52
  %442 = icmp eq i32 %49, %441
  br i1 %442, label %443, label %450

443:                                              ; preds = %440
  %444 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %427, 1
  %445 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %427, 2
  %446 = getelementptr float, ptr %444, i64 %445
  %447 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %427, 3, 0
  %448 = trunc i64 %447 to i32
  %449 = call i32 @MPI_Send(ptr %446, i32 %448, i32 1275069450, i32 0, i32 0, i32 1140850688)
  br label %450

450:                                              ; preds = %443, %440
  br label %451

451:                                              ; preds = %439, %450
  %452 = call i32 @MPI_Barrier(i32 1140850688)
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par.1(ptr noalias %tid.addr18, ptr noalias %zero.addr19, ptr %0) #0 {
omp.par.entry20:
  %gep_.reloaded60 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded60 = load ptr, ptr %gep_.reloaded60, align 8, !align !1
  %gep_.reloaded61 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded61 = load ptr, ptr %gep_.reloaded61, align 8, !align !1
  %gep_.reloaded62 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded62 = load ptr, ptr %gep_.reloaded62, align 8, !align !1
  %p.lastiter54 = alloca i32, align 4
  %p.lowerbound55 = alloca i64, align 8
  %p.upperbound56 = alloca i64, align 8
  %p.stride57 = alloca i64, align 8
  %tid.addr.local24 = alloca i32, align 4
  %1 = load i32, ptr %tid.addr18, align 4
  store i32 %1, ptr %tid.addr.local24, align 4
  %tid25 = load i32, ptr %tid.addr.local24, align 4
  %2 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded60, align 8
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded61, align 8
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded62, align 8
  br label %omp.region.after_alloca31

omp.region.after_alloca31:                        ; preds = %omp.par.entry20
  br label %omp.region.after_alloca28

omp.region.after_alloca28:                        ; preds = %omp.region.after_alloca31
  br label %omp.par.region21

omp.par.region21:                                 ; preds = %omp.region.after_alloca28
  br label %omp.par.region30

omp.par.region30:                                 ; preds = %omp.par.region21
  br label %omp.wsloop.region33

omp.wsloop.region33:                              ; preds = %omp.par.region30
  br label %omp_loop.preheader34

omp_loop.preheader34:                             ; preds = %omp.wsloop.region33
  store i64 0, ptr %p.lowerbound55, align 4
  store i64 332, ptr %p.upperbound56, align 4
  store i64 1, ptr %p.stride57, align 4
  %omp_global_thread_num58 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num58, i32 34, ptr %p.lastiter54, ptr %p.lowerbound55, ptr %p.upperbound56, ptr %p.stride57, i64 1, i64 0)
  %5 = load i64, ptr %p.lowerbound55, align 4
  %6 = load i64, ptr %p.upperbound56, align 4
  %7 = sub i64 %6, %5
  %8 = add i64 %7, 1
  br label %omp_loop.header35

omp_loop.header35:                                ; preds = %omp_loop.inc38, %omp_loop.preheader34
  %omp_loop.iv41 = phi i64 [ 0, %omp_loop.preheader34 ], [ %omp_loop.next43, %omp_loop.inc38 ]
  br label %omp_loop.cond36

omp_loop.cond36:                                  ; preds = %omp_loop.header35
  %omp_loop.cmp42 = icmp ult i64 %omp_loop.iv41, %8
  br i1 %omp_loop.cmp42, label %omp_loop.body37, label %omp_loop.exit39

omp_loop.exit39:                                  ; preds = %omp_loop.cond36
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num58)
  %omp_global_thread_num59 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num59)
  br label %omp_loop.after40

omp_loop.after40:                                 ; preds = %omp_loop.exit39
  br label %omp.region.cont32

omp.region.cont32:                                ; preds = %omp_loop.after40
  br label %omp.region.cont29

omp.region.cont29:                                ; preds = %omp.region.cont32
  br label %omp.par.pre_finalize22

omp.par.pre_finalize22:                           ; preds = %omp.region.cont29
  br label %omp.par.exit23.exitStub

omp_loop.body37:                                  ; preds = %omp_loop.cond36
  %9 = add i64 %omp_loop.iv41, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region45

omp.loop_nest.region45:                           ; preds = %omp_loop.body37
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region46

omp.loop_nest.region46:                           ; preds = %omp.loop_nest.region45
  br label %omp.loop_nest.region47

omp.loop_nest.region47:                           ; preds = %omp.loop_nest.region51, %omp.loop_nest.region46
  %13 = phi i64 [ %22, %omp.loop_nest.region51 ], [ 0, %omp.loop_nest.region46 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region48, label %omp.loop_nest.region52

omp.loop_nest.region52:                           ; preds = %omp.loop_nest.region47
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region53

omp.loop_nest.region53:                           ; preds = %omp.loop_nest.region52
  br label %omp.region.cont44

omp.region.cont44:                                ; preds = %omp.loop_nest.region53
  br label %omp_loop.inc38

omp_loop.inc38:                                   ; preds = %omp.region.cont44
  %omp_loop.next43 = add nuw i64 %omp_loop.iv41, 1
  br label %omp_loop.header35

omp.loop_nest.region48:                           ; preds = %omp.loop_nest.region47
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = getelementptr float, ptr %15, i32 334000
  %17 = mul nuw nsw i64 %11, 1000
  %18 = add nuw nsw i64 %17, %13
  %19 = getelementptr inbounds nuw float, ptr %16, i64 %18
  store float 0.000000e+00, ptr %19, align 4
  br label %omp.loop_nest.region49

omp.loop_nest.region49:                           ; preds = %omp.loop_nest.region50, %omp.loop_nest.region48
  %20 = phi i64 [ %48, %omp.loop_nest.region50 ], [ 0, %omp.loop_nest.region48 ]
  %21 = icmp slt i64 %20, 1000
  br i1 %21, label %omp.loop_nest.region50, label %omp.loop_nest.region51

omp.loop_nest.region51:                           ; preds = %omp.loop_nest.region49
  %22 = add i64 %13, 1
  br label %omp.loop_nest.region47

omp.loop_nest.region50:                           ; preds = %omp.loop_nest.region49
  %23 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %24 = getelementptr float, ptr %23, i32 334000
  %25 = mul nuw nsw i64 %11, 1000
  %26 = add nuw nsw i64 %25, %20
  %27 = getelementptr inbounds nuw float, ptr %24, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %30 = getelementptr float, ptr %29, i32 334000
  %31 = mul nuw nsw i64 %20, 1000
  %32 = add nuw nsw i64 %31, %13
  %33 = getelementptr inbounds nuw float, ptr %30, i64 %32
  %34 = load float, ptr %33, align 4
  %35 = fmul float %28, %34
  %36 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %37 = getelementptr float, ptr %36, i32 334000
  %38 = mul nuw nsw i64 %11, 1000
  %39 = add nuw nsw i64 %38, %13
  %40 = getelementptr inbounds nuw float, ptr %37, i64 %39
  %41 = load float, ptr %40, align 4
  %42 = fadd float %41, %35
  %43 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %44 = getelementptr float, ptr %43, i32 334000
  %45 = mul nuw nsw i64 %11, 1000
  %46 = add nuw nsw i64 %45, %13
  %47 = getelementptr inbounds nuw float, ptr %44, i64 %46
  store float %42, ptr %47, align 4
  %48 = add i64 %20, 1
  br label %omp.loop_nest.region49

omp.par.exit23.exitStub:                          ; preds = %omp.par.pre_finalize22
  ret void
}

; Function Attrs: nounwind
define internal void @matmul..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_.reloaded = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %loadgep_.reloaded = load ptr, ptr %gep_.reloaded, align 8, !align !1
  %gep_.reloaded15 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %loadgep_.reloaded15 = load ptr, ptr %gep_.reloaded15, align 8, !align !1
  %gep_.reloaded16 = getelementptr { ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %loadgep_.reloaded16 = load ptr, ptr %gep_.reloaded16, align 8, !align !1
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
  %4 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %loadgep_.reloaded16, align 8
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
  %9 = add i64 %omp_loop.iv, %5
  %10 = mul i64 %9, 1
  %11 = add i64 %10, 0
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body
  %12 = call ptr @llvm.stacksave.p0()
  br label %omp.loop_nest.region5

omp.loop_nest.region5:                            ; preds = %omp.loop_nest.region
  br label %omp.loop_nest.region6

omp.loop_nest.region6:                            ; preds = %omp.loop_nest.region10, %omp.loop_nest.region5
  %13 = phi i64 [ %21, %omp.loop_nest.region10 ], [ 0, %omp.loop_nest.region5 ]
  %14 = icmp slt i64 %13, 1000
  br i1 %14, label %omp.loop_nest.region7, label %omp.loop_nest.region11

omp.loop_nest.region11:                           ; preds = %omp.loop_nest.region6
  call void @llvm.stackrestore.p0(ptr %12)
  br label %omp.loop_nest.region12

omp.loop_nest.region12:                           ; preds = %omp.loop_nest.region11
  br label %omp.region.cont4

omp.region.cont4:                                 ; preds = %omp.loop_nest.region12
  br label %omp_loop.inc

omp_loop.inc:                                     ; preds = %omp.region.cont4
  %omp_loop.next = add nuw i64 %omp_loop.iv, 1
  br label %omp_loop.header

omp.loop_nest.region7:                            ; preds = %omp.loop_nest.region6
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %16 = mul nuw nsw i64 %11, 1000
  %17 = add nuw nsw i64 %16, %13
  %18 = getelementptr inbounds nuw float, ptr %15, i64 %17
  store float 0.000000e+00, ptr %18, align 4
  br label %omp.loop_nest.region8

omp.loop_nest.region8:                            ; preds = %omp.loop_nest.region9, %omp.loop_nest.region7
  %19 = phi i64 [ %43, %omp.loop_nest.region9 ], [ 0, %omp.loop_nest.region7 ]
  %20 = icmp slt i64 %19, 1000
  br i1 %20, label %omp.loop_nest.region9, label %omp.loop_nest.region10

omp.loop_nest.region10:                           ; preds = %omp.loop_nest.region8
  %21 = add i64 %13, 1
  br label %omp.loop_nest.region6

omp.loop_nest.region9:                            ; preds = %omp.loop_nest.region8
  %22 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %23 = mul nuw nsw i64 %11, 1000
  %24 = add nuw nsw i64 %23, %19
  %25 = getelementptr inbounds nuw float, ptr %22, i64 %24
  %26 = load float, ptr %25, align 4
  %27 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %4, 1
  %28 = mul nuw nsw i64 %19, 1000
  %29 = add nuw nsw i64 %28, %13
  %30 = getelementptr inbounds nuw float, ptr %27, i64 %29
  %31 = load float, ptr %30, align 4
  %32 = fmul float %26, %31
  %33 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %34 = mul nuw nsw i64 %11, 1000
  %35 = add nuw nsw i64 %34, %13
  %36 = getelementptr inbounds nuw float, ptr %33, i64 %35
  %37 = load float, ptr %36, align 4
  %38 = fadd float %37, %32
  %39 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %2, 1
  %40 = mul nuw nsw i64 %11, 1000
  %41 = add nuw nsw i64 %40, %13
  %42 = getelementptr inbounds nuw float, ptr %39, i64 %41
  store float %38, ptr %42, align 4
  %43 = add i64 %19, 1
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
declare !callback !2 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind willreturn }
attributes #2 = { convergent nounwind }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{i64 8}
!2 = !{!3}
!3 = !{i64 2, i64 -1, i64 -1, i1 true}
