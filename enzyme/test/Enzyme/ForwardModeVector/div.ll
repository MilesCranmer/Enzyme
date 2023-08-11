; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -early-cse -instsimplify -simplifycfg -S | FileCheck %s; fi
; RUN: %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,early-cse,instsimplify,%simplifycfg)" -enzyme-preopt=false -S | FileCheck %s

%struct.Gradients = type { double, double }

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(double (double,double)*, ...)

; Function Attrs: noinline nounwind readnone uwtable
define double @tester(double %x, double %y) {
entry:
  %0 = fdiv fast double %x, %y
  ret double %0
}

define %struct.Gradients @test_derivative(double %x, double %y) {
entry:
  %0 = tail call %struct.Gradients (double (double, double)*, ...) @__enzyme_fwddiff(double (double, double)* nonnull @tester, metadata !"enzyme_width", i64 2, double %x, double 0.0, double 1.0, double %y, double 1.0, double 0.0)
  ret %struct.Gradients %0
}


; CHECK: define internal [2 x double] @fwddiffe2tester(double %x, [2 x double] %"x'", double %y, [2 x double] %"y'")
; CHECK-NEXT: entry:
; CHECK-NEXT:   %[[i0:.+]] = extractvalue [2 x double] %"x'", 0
; CHECK-NEXT:   %[[i2:.+]] = fmul fast double %[[i0]], %y
; CHECK-NEXT:   %[[i5:.+]] = extractvalue [2 x double] %"x'", 1
; CHECK-NEXT:   %[[i7:.+]] = fmul fast double %[[i5]], %y
; CHECK-NEXT:   %[[i1:.+]] = extractvalue [2 x double] %"y'", 0
; CHECK-NEXT:   %[[i3:.+]] = fmul fast double %[[i1]], %x
; CHECK-NEXT:   %[[i6:.+]] = extractvalue [2 x double] %"y'", 1
; CHECK-NEXT:   %[[i8:.+]] = fmul fast double %[[i6]], %x
; CHECK-NEXT:   %[[i4:.+]] = fsub fast double %[[i2]], %[[i3]]
; CHECK-NEXT:   %[[i9:.+]] = fsub fast double %[[i7]], %[[i8]]
; CHECK-NEXT:   %[[i10:.+]] = fmul fast double %y, %y
; CHECK-NEXT:   %[[i11:.+]] = fdiv fast double %[[i4]], %[[i10]]
; CHECK-NEXT:   %[[i12:.+]] = insertvalue [2 x double] undef, double %[[i11]], 0
; CHECK-NEXT:   %[[i13:.+]] = fdiv fast double %[[i9]], %[[i10]]
; CHECK-NEXT:   %[[i14:.+]] = insertvalue [2 x double] %[[i12]], double %[[i13]], 1
; CHECK-NEXT:   ret [2 x double] %[[i14]]
; CHECK-NEXT: }
