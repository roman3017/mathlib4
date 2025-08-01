/-
Copyright (c) 2019 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/
import Mathlib.CategoryTheory.FinCategory.AsType
import Mathlib.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathlib.CategoryTheory.Limits.Shapes.Equalizers
import Mathlib.CategoryTheory.Limits.Shapes.WidePullbacks
import Mathlib.CategoryTheory.Limits.Shapes.Pullback.HasPullback
import Mathlib.Data.Fintype.Option

/-!
# Categories with finite limits.

A typeclass for categories with all finite (co)limits.
-/


universe w' w v' u' v u

noncomputable section

open CategoryTheory

namespace CategoryTheory.Limits

variable (C : Type u) [Category.{v} C]

-- We can't just made this an `abbreviation`
-- because of https://github.com/leanprover-community/lean/issues/429
/-- A category has all finite limits if every functor `J ⥤ C` with a `FinCategory J`
instance and `J : Type` has a limit.

This is often called 'finitely complete'.
-/
class HasFiniteLimits : Prop where
  /-- `C` has all limits over any type `J` whose objects and morphisms lie in the same universe
  and which has `FinType` objects and morphisms -/
  out (J : Type) [𝒥 : SmallCategory J] [@FinCategory J 𝒥] : @HasLimitsOfShape J 𝒥 C _

instance (priority := 100) hasLimitsOfShape_of_hasFiniteLimits [HasFiniteLimits C] (J : Type w)
    [SmallCategory J] [FinCategory J] : HasLimitsOfShape J C := by
  apply @hasLimitsOfShape_of_equivalence _ _ _ _ _ _ (FinCategory.equivAsType J) ?_
  apply HasFiniteLimits.out

lemma hasFiniteLimits_of_hasLimitsOfSize [HasLimitsOfSize.{v', u'} C] :
    HasFiniteLimits C where
  out := fun J hJ hJ' =>
    haveI := hasLimitsOfSizeShrink.{0, 0} C
    let F := @FinCategory.equivAsType J (@FinCategory.fintypeObj J hJ hJ') hJ hJ'
    @hasLimitsOfShape_of_equivalence (@FinCategory.AsType J (@FinCategory.fintypeObj J hJ hJ'))
    (@FinCategory.categoryAsType J (@FinCategory.fintypeObj J hJ hJ') hJ hJ') _ _ J hJ F _

/-- If `C` has all limits, it has finite limits. -/
instance (priority := 100) hasFiniteLimits_of_hasLimits [HasLimits C] : HasFiniteLimits C :=
  hasFiniteLimits_of_hasLimitsOfSize C

instance (priority := 90) hasFiniteLimits_of_hasLimitsOfSize₀ [HasLimitsOfSize.{0, 0} C] :
    HasFiniteLimits C :=
  hasFiniteLimits_of_hasLimitsOfSize C

/-- We can always derive `HasFiniteLimits C` by providing limits at an
arbitrary universe. -/
theorem hasFiniteLimits_of_hasFiniteLimits_of_size
    (h : ∀ (J : Type w) {𝒥 : SmallCategory J} (_ : @FinCategory J 𝒥), HasLimitsOfShape J C) :
    HasFiniteLimits C where
  out := fun J hJ hhJ => by
    haveI := h (ULiftHom.{w} (ULift.{w} J)) <| @CategoryTheory.finCategoryUlift J hJ hhJ
    have l : @Equivalence J (ULiftHom (ULift J)) hJ
                          (@ULiftHom.category (ULift J) (@uliftCategory J hJ)) :=
      @ULiftHomULiftCategory.equiv J hJ
    apply @hasLimitsOfShape_of_equivalence (ULiftHom (ULift J))
      (@ULiftHom.category (ULift J) (@uliftCategory J hJ)) C _ J hJ
      (@Equivalence.symm J hJ (ULiftHom (ULift J))
      (@ULiftHom.category (ULift J) (@uliftCategory J hJ)) l) _
    /- Porting note: tried to factor out (@instCategoryULiftHom (ULift J) (@uliftCategory J hJ)
    but when doing that would then find the instance and say it was not definitionally equal to
    the provided one (the same thing factored out) -/

/-- A category has all finite colimits if every functor `J ⥤ C` with a `FinCategory J`
instance and `J : Type` has a colimit.

This is often called 'finitely cocomplete'.
-/
class HasFiniteColimits : Prop where
  /-- `C` has all colimits over any type `J` whose objects and morphisms lie in the same universe
  and which has `Fintype` objects and morphisms -/
  out (J : Type) [𝒥 : SmallCategory J] [@FinCategory J 𝒥] : @HasColimitsOfShape J 𝒥 C _

-- See note [instance argument order]
instance (priority := 100) hasColimitsOfShape_of_hasFiniteColimits [HasFiniteColimits C]
    (J : Type w) [SmallCategory J] [FinCategory J] : HasColimitsOfShape J C := by
  refine @hasColimitsOfShape_of_equivalence _ _ _ _ _ _ (FinCategory.equivAsType J) ?_
  apply HasFiniteColimits.out

lemma hasFiniteColimits_of_hasColimitsOfSize [HasColimitsOfSize.{v', u'} C] :
    HasFiniteColimits C where
  out := fun J hJ hJ' =>
    haveI := hasColimitsOfSizeShrink.{0, 0} C
    let F := @FinCategory.equivAsType J (@FinCategory.fintypeObj J hJ hJ') hJ hJ'
    @hasColimitsOfShape_of_equivalence (@FinCategory.AsType J (@FinCategory.fintypeObj J hJ hJ'))
    (@FinCategory.categoryAsType J (@FinCategory.fintypeObj J hJ hJ') hJ hJ') _ _ J hJ F _

instance (priority := 100) hasFiniteColimits_of_hasColimits [HasColimits C] : HasFiniteColimits C :=
  hasFiniteColimits_of_hasColimitsOfSize C

instance (priority := 90) hasFiniteColimits_of_hasColimitsOfSize₀ [HasColimitsOfSize.{0, 0} C] :
    HasFiniteColimits C :=
  hasFiniteColimits_of_hasColimitsOfSize C

/-- We can always derive `HasFiniteColimits C` by providing colimits at an
arbitrary universe. -/
theorem hasFiniteColimits_of_hasFiniteColimits_of_size
    (h : ∀ (J : Type w) {𝒥 : SmallCategory J} (_ : @FinCategory J 𝒥), HasColimitsOfShape J C) :
    HasFiniteColimits C where
  out := fun J hJ hhJ => by
    haveI := h (ULiftHom.{w} (ULift.{w} J)) <| @CategoryTheory.finCategoryUlift J hJ hhJ
    have l : @Equivalence J (ULiftHom (ULift J)) hJ
                           (@ULiftHom.category (ULift J) (@uliftCategory J hJ)) :=
      @ULiftHomULiftCategory.equiv J hJ
    apply @hasColimitsOfShape_of_equivalence (ULiftHom (ULift J))
      (@ULiftHom.category (ULift J) (@uliftCategory J hJ)) C _ J hJ
      (@Equivalence.symm J hJ (ULiftHom (ULift J))
      (@ULiftHom.category (ULift J) (@uliftCategory J hJ)) l) _

section

open WalkingParallelPair WalkingParallelPairHom

instance fintypeWalkingParallelPair : Fintype WalkingParallelPair where
  elems := [WalkingParallelPair.zero, WalkingParallelPair.one].toFinset
  complete x := by cases x <;> simp

-- attribute [local tidy] tactic.case_bash Porting note: no tidy; no case_bash

instance instFintypeWalkingParallelPairHom (j j' : WalkingParallelPair) :
    Fintype (WalkingParallelPairHom j j') where
  elems :=
    WalkingParallelPair.recOn j
      (WalkingParallelPair.recOn j' [WalkingParallelPairHom.id zero].toFinset
        [left, right].toFinset)
      (WalkingParallelPair.recOn j' ∅ [WalkingParallelPairHom.id one].toFinset)
  complete := by
    rintro (_ | _) <;> simp
    cases j <;> simp
end

instance : FinCategory WalkingParallelPair where
  fintypeObj := fintypeWalkingParallelPair
  fintypeHom := instFintypeWalkingParallelPairHom -- Porting note: could not be inferred

/-- Equalizers are finite limits, so if `C` has all finite limits, it also has all equalizers -/
example [HasFiniteLimits C] : HasEqualizers C := by infer_instance

/-- Coequalizers are finite colimits, of if `C` has all finite colimits, it also has all
    coequalizers -/
example [HasFiniteColimits C] : HasCoequalizers C := by infer_instance

variable {J : Type v}

-- attribute [local tidy] tactic.case_bash Porting note: no tidy; no case_bash

namespace WidePullbackShape

instance fintypeObj [Fintype J] : Fintype (WidePullbackShape J) :=
  inferInstanceAs <| Fintype (Option _)

instance fintypeHom (j j' : WidePullbackShape J) : Fintype (j ⟶ j') where
  elems := by
    obtain - | j' := j'
    · obtain - | j := j
      · exact {Hom.id none}
      · exact {Hom.term j}
    · by_cases h : some j' = j
      · rw [h]
        exact {Hom.id j}
      · exact ∅
  complete := by
    rintro (_ | _)
    · cases j <;> simp
    · simp

end WidePullbackShape

namespace WidePushoutShape

instance fintypeObj [Fintype J] : Fintype (WidePushoutShape J) := by
  rw [WidePushoutShape]; infer_instance

instance fintypeHom (j j' : WidePushoutShape J) : Fintype (j ⟶ j') where
  elems := by
    obtain - | j := j
    · obtain - | j' := j'
      · exact {Hom.id none}
      · exact {Hom.init j'}
    · by_cases h : some j = j'
      · rw [h]
        exact {Hom.id j'}
      · exact ∅
  complete := by
    rintro (_ | _)
    · cases j <;> simp
    · simp

end WidePushoutShape

instance finCategoryWidePullback [Fintype J] : FinCategory (WidePullbackShape J) where
  fintypeHom := WidePullbackShape.fintypeHom

instance finCategoryWidePushout [Fintype J] : FinCategory (WidePushoutShape J) where
  fintypeHom := WidePushoutShape.fintypeHom

-- We can't just made this an `abbreviation`
-- because of https://github.com/leanprover-community/lean/issues/429
/-- `HasFiniteWidePullbacks` represents a choice of wide pullback
for every finite collection of morphisms
-/
class HasFiniteWidePullbacks : Prop where
  /-- `C` has all wide pullbacks for any Finite `J` -/
  out (J : Type) [Finite J] : HasLimitsOfShape (WidePullbackShape J) C

instance hasLimitsOfShape_widePullbackShape (J : Type) [Finite J] [HasFiniteWidePullbacks C] :
    HasLimitsOfShape (WidePullbackShape J) C := by
  haveI := @HasFiniteWidePullbacks.out C _ _ J
  infer_instance

/-- `HasFiniteWidePushouts` represents a choice of wide pushout
for every finite collection of morphisms
-/
class HasFiniteWidePushouts : Prop where
  /-- `C` has all wide pushouts for any Finite `J` -/
  out (J : Type) [Finite J] : HasColimitsOfShape (WidePushoutShape J) C

instance hasColimitsOfShape_widePushoutShape (J : Type) [Finite J] [HasFiniteWidePushouts C] :
    HasColimitsOfShape (WidePushoutShape J) C := by
  haveI := @HasFiniteWidePushouts.out C _ _ J
  infer_instance

/-- Finite wide pullbacks are finite limits, so if `C` has all finite limits,
it also has finite wide pullbacks
-/
instance (priority := 900) hasFiniteWidePullbacks_of_hasFiniteLimits [HasFiniteLimits C] :
    HasFiniteWidePullbacks C :=
  ⟨fun J _ => by cases nonempty_fintype J; exact HasFiniteLimits.out _⟩

/-- Finite wide pushouts are finite colimits, so if `C` has all finite colimits,
it also has finite wide pushouts
-/
instance (priority := 900) hasFiniteWidePushouts_of_has_finite_limits [HasFiniteColimits C] :
    HasFiniteWidePushouts C :=
  ⟨fun J _ => by cases nonempty_fintype J; exact HasFiniteColimits.out _⟩

instance fintypeWalkingPair : Fintype WalkingPair where
  elems := {WalkingPair.left, WalkingPair.right}
  complete x := by cases x <;> simp

/-- Pullbacks are finite limits, so if `C` has all finite limits, it also has all pullbacks -/
example [HasFiniteWidePullbacks C] : HasPullbacks C := by infer_instance

/-- Pushouts are finite colimits, so if `C` has all finite colimits, it also has all pushouts -/
example [HasFiniteWidePushouts C] : HasPushouts C := by infer_instance

end CategoryTheory.Limits
