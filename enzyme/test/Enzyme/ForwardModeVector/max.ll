; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -instsimplify -simplifycfg -S | FileCheck %s; fi
; RUN: %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,instsimplify,%simplifycfg)" -enzyme-preopt=false -S | FileCheck %s

%struct.Gradients = type { double, double }

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(double (double, double)*, ...)

; Function Attrs: norecurse nounwind readnone uwtable
define dso_local double @max(double %x, double %y) #0 {
entry:
  %cmp = fcmp fast ogt double %x, %y
  %cond = select i1 %cmp, double %x, double %y
  ret double %cond
}

; Function Attrs: nounwind uwtable
define dso_local %struct.Gradients @test_derivative(double %x, double %y) local_unnamed_addr #1 {
entry:
  %0 = tail call %struct.Gradients (double (double, double)*, ...) @__enzyme_fwddiff(double (double, double)* nonnull @max, metadata !"enzyme_width", i64 2, double %x, double 1.0, double 0.0, double %y, double 0.0, double 1.0)
  ret %struct.Gradients %0
}

; CHECK: define {{[^@]+}}@fwddiffe2max(double [[X:%.*]], [2 x double] %"x'", double [[Y:%.*]], [2 x double] %"y'") 
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp fast ogt double [[X]], [[Y]]
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [2 x double] %"x'", 0
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue [2 x double] %"y'", 0
; CHECK-NEXT:    %"cond'ipse" = select {{(fast )?}}i1 [[CMP]], double [[TMP0]], double [[TMP1]]
; CHECK-NEXT:    [[TMP2:%.*]] = insertvalue [2 x double] undef, double %"cond'ipse", 0
; CHECK-NEXT:    [[TMP3:%.*]] = extractvalue [2 x double] %"x'", 1
; CHECK-NEXT:    [[TMP4:%.*]] = extractvalue [2 x double] %"y'", 1
; CHECK-NEXT:    %"cond'ipse1" = select {{(fast )?}}i1 [[CMP]], double [[TMP3]], double [[TMP4]]
; CHECK-NEXT:    [[TMP5:%.*]] = insertvalue [2 x double] [[TMP2]], double %"cond'ipse1", 1
; CHECK-NEXT:    ret [2 x double] [[TMP5]]
;
