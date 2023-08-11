; RUN: if [ %llvmver -lt 14 ] && [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -instsimplify -adce -loop-deletion -correlated-propagation -simplifycfg -S | FileCheck %s -check-prefixes LLVM13,SHARED; fi
; RUN: if [ %llvmver -ge 14 ] && [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -instsimplify -adce -loop-deletion -correlated-propagation -simplifycfg -S | FileCheck %s -check-prefixes LLVM14,SHARED; fi

; RUN: if [ %llvmver -lt 14 ]; then %opt < %s %newLoadEnzyme -enzyme-preopt=false -passes="enzyme,function(mem2reg,instsimplify,adce,loop(loop-deletion),correlated-propagation,%simplifycfg)" -S | FileCheck %s -check-prefixes LLVM13,SHARED; fi
; RUN: if [ %llvmver -ge 14 ]; then %opt < %s %newLoadEnzyme -enzyme-preopt=false -passes="enzyme,function(mem2reg,instsimplify,adce,loop(loop-deletion),correlated-propagation,%simplifycfg)" -S | FileCheck %s -check-prefixes LLVM14,SHARED; fi


source_filename = "/mnt/Data/git/Enzyme/enzyme/test/Integration/taylorlog.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE*, align 8
@.str = private unnamed_addr constant [68 x i8] c"Assertion Failed: fabs( [%s = %g] - [%s = %g] ) > %g at %s:%d (%s)\0A\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"ret\00", align 1
@.str.2 = private unnamed_addr constant [4 x i8] c"2.0\00", align 1
@.str.3 = private unnamed_addr constant [57 x i8] c"/mnt/Data/git/Enzyme/enzyme/test/Integration/taylorlog.c\00", align 1
@__PRETTY_FUNCTION__.main = private unnamed_addr constant [23 x i8] c"int main(int, char **)\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** nocapture readnone %argv) local_unnamed_addr #0 {
entry:
  %call = tail call fast double @__enzyme_autodiff(i8* bitcast (double (double, i64)* @taylorlog to i8*), double 5.000000e-01, i64 10000) #6
  %sub = fadd fast double %call, -2.000000e+00
  %0 = tail call fast double @llvm.fabs.f64(double %sub)
  %cmp = fcmp fast ogt double %0, 0x3E7AD7F29ABCAF48
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !2
  %call1 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %1, i8* getelementptr inbounds ([68 x i8], [68 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.1, i64 0, i64 0), double %call, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.2, i64 0, i64 0), double 2.000000e+00, double 0x3E7AD7F29ABCAF48, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @.str.3, i64 0, i64 0), i32 31, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @__PRETTY_FUNCTION__.main, i64 0, i64 0)) #7
  tail call void @abort() #8
  unreachable

if.end:                                           ; preds = %entry
  ret i32 0
}

declare dso_local double @__enzyme_autodiff(i8*, double, i64) local_unnamed_addr #1

; Function Attrs: nounwind readnone uwtable
define internal double @taylorlog(double %x, i64 %SINCOSN) #2 {
entry:
  ; %cmp8 = icmp eq i32 1, 0
  switch i64 %SINCOSN, label %for.body.preheader [
    i64 0, label %for.cond.cleanup
    i64 1, label %ifone
  ]

for.body.preheader:                               ; preds = %entry
  br label %for.body

ifone:
  br label %for.cond.cleanup

for.body:                                         ; preds = %for.body, %for.body.preheader.new
  %i = phi i64 [ 1, %for.body.preheader ], [ %inc, %for.body ]
  %sum.09 = phi double [ 0.000000e+00, %for.body.preheader ], [ %add, %for.body ]
  %conv = sitofp i64 %i to double
  %a2 = tail call fast double @llvm.pow.f64(double %x, double %conv)
  %div = fdiv fast double %a2, %conv
  %add = fadd fast double %div, %sum.09
  %inc = add nuw nsw i64 %i, 1
  %niter.ncmp = icmp eq i64 %inc, %SINCOSN
  br i1 %niter.ncmp, label %for.cond.cleanup, label %for.body

for.cond.cleanup:                                 ; preds = %for.cond.cleanup.loopexit.epilog-lcssa, %for.cond.cleanup.loopexit.unr-lcssa, %entry
  %total = phi double [ 0.000000e+00, %entry ], [ %x, %ifone ], [ %add, %for.body ]
  ret double %total
}

; Function Attrs: nounwind readnone speculatable
declare double @llvm.fabs.f64(double) #3

; Function Attrs: nounwind
declare dso_local i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture readonly, ...) local_unnamed_addr #4

; Function Attrs: noreturn nounwind
declare dso_local void @abort() local_unnamed_addr #5

; Function Attrs: nounwind readnone speculatable
declare double @llvm.pow.f64(double, double) #3

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #2 = { nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #3 = { nounwind readnone speculatable }
attributes #4 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #5 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #6 = { nounwind }
attributes #7 = { cold }
attributes #8 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.1.0 "}
!2 = !{!3, !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}

; SHARED: define internal { double } @diffetaylorlog(double %x, i64 %SINCOSN, double %differeturn)
; SHARED-NEXT: entry:
; SHARED-DAG:    %[[zcmp:.+]] = icmp eq i64 1, %SINCOSN
; SHARED-DAG:    %[[or1:.+]] = icmp eq i64 0, %SINCOSN
; SHARED-DAG:    %[[or2:.+]] = icmp eq i64 1, %SINCOSN
; todo note both * chars should be one of the 1 == SINCOS
; SHARED-DAG:    %[[orcmp:.+]] = or i1 %[[or1]], %{{.+}}
; SHARED-NEXT:   %4 = select{{( fast)?}} i1 %[[orcmp]], double 0.000000e+00, double %differeturn
; SHARED-NEXT:   %5 = select{{( fast)?}} i1 %{{.+}}, double %differeturn, double 0.000000e+00
; LLVM13-NEXT:   %switch = icmp ult i64 %SINCOSN, 2
; LLVM13-NEXT:   br i1 %switch, label %invertentry, label %invertfor.cond.cleanup.loopexit
; LLVM14-NEXT:   switch i64 %SINCOSN, label %invertfor.cond.cleanup.loopexit [
; LLVM14-NEXT:     i64 0, label %invertentry
; LLVM14-NEXT:     i64 1, label %invertentry
; LLVM14-NEXT:   ]

; NOTE: There is one incoming entry in predecessors() for each outgoing target in switch, even if the targets are the same

; LLVM13: invertentry:                                      ; preds = %entry, %invertfor.body
; LLVM14: invertentry:                                      ; preds = %entry, %invertfor.body, %entry
; LLVM13-NEXT:   %"x'de.0" = phi double [ %[[i11:.+]], %invertfor.body ], [ %5, %entry ]
; LLVM14-NEXT:   %"x'de.0" = phi double [ %5, %entry ], [ %[[i11:.+]], %invertfor.body ], [ %5, %entry ]
; SHARED-NEXT:   %6 = insertvalue { double } undef, double %"x'de.0", 0
; SHARED-NEXT:   ret { double } %6

; SHARED: invertfor.body:                                   ; preds = %invertfor.cond.cleanup.loopexit, %incinvertfor.body
; SHARED-NEXT:   %"x'de.1" = phi double [ %5, %invertfor.cond.cleanup.loopexit ], [ %[[i11]], %incinvertfor.body ]
; SHARED-NEXT:   %"iv'ac.0" = phi i64 [ %_unwrap, %invertfor.cond.cleanup.loopexit ], [ %[[i14:.+]], %incinvertfor.body ]
; SHARED-NEXT:   %iv.next_unwrap = add nuw nsw i64 %"iv'ac.0", 1
; SHARED-NEXT:   %conv_unwrap = sitofp i64 %iv.next_unwrap to double
; SHARED-NEXT:   %[[d0diffea2:.+]] = fdiv fast double %4, %conv_unwrap
; SHARED-NEXT:   %[[i7:.+]] = fsub fast double %conv_unwrap, 1.000000e+00
; SHARED-NEXT:   %[[i8:.+]] = call fast double @llvm.pow.f64(double %x, double %[[i7]])
; SHARED-NEXT:   %[[i9:.+]] = fmul fast double %conv_unwrap, %[[i8]]
; SHARED-NEXT:   %[[i10:.+]] = fmul fast double %[[d0diffea2]], %[[i9]]
; SHARED-NEXT:   %[[i11]] = fadd fast double %"x'de.1", %[[i10]]
; SHARED-NEXT:   %[[i12:.+]] = icmp eq i64 %"iv'ac.0", 0
; SHARED-NEXT:   %[[i13:.+]] = select{{( fast)?}} i1 %[[i12]], double 0.000000e+00, double %4
; SHARED-NEXT:   br i1 %[[i12]], label %invertentry, label %incinvertfor.body

; SHARED: incinvertfor.body:                                ; preds = %invertfor.body
; SHARED-NEXT:   %[[i14]] = add nsw i64 %"iv'ac.0", -1
; SHARED-NEXT:   br label %invertfor.body

; SHARED: invertfor.cond.cleanup.loopexit:                  ; preds = %entry
; SHARED-NEXT:   %_unwrap = add i64 %SINCOSN, -2
; SHARED-NEXT:   br label %invertfor.body
; SHARED-NEXT: }
