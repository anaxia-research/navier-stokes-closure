import NavierStokes.ComparatorDefinitions

/-!
# The Clay problem, in plain words

This file states the Navier–Stokes existence and smoothness problem exactly as
C. Fefferman wrote it for the Clay Mathematics Institute (2000, with the 2022 errata
on the periodic pressure). Fefferman asks for a proof of one of four statements,
called (A), (B), (C) and (D), for a viscosity `ν > 0` in three space dimensions.

* (A) Existence and smoothness on ℝ³: every nice starting velocity, with no force,
  has a smooth solution for all time with bounded energy.
* (B) Existence and smoothness on the torus ℝ³/ℤ³: the same for periodic data.
* (C) Breakdown on ℝ³: some nice starting velocity and some nice force have no such
  solution.
* (D) Breakdown on the torus: the same for periodic data and periodic force.

The words "nice", "smooth solution" and "bounded energy" are the structures of
`NavierStokes.ComparatorDefinitions`, which repeat word for word the reference
statement of the Formal Conjectures project (Google DeepMind), itself a line-by-line
transcription of Fefferman's conditions (1)–(11).
-/

namespace NavierStokesClosure

open NavierStokes.Comparator

/-- Three-dimensional Euclidean space. -/
local notation "ℝ³" => EuclideanSpace ℝ (Fin 3)

/-- The zero force. -/
def noForce : ℝ³ → ℝ → ℝ³ := fun _ _ => 0

/-- Clay statement (A) for the viscosity `ν`. -/
def ClayA (ν : ℝ) : Prop :=
  ∀ u₀ : ℝ³ → ℝ³, InitialVelocityConditionDecay u₀ →
    ∃ v p, NavierStokesExistenceAndSmoothnessRn ν u₀ noForce v p

/-- Clay statement (B) for the viscosity `ν`. -/
def ClayB (ν : ℝ) : Prop :=
  ∀ u₀ : ℝ³ → ℝ³, InitialVelocityConditionPeriodic u₀ →
    ∃ v p, NavierStokesExistenceAndSmoothnessPeriodic ν u₀ noForce v p

/-- Clay statement (C) for the viscosity `ν`. -/
def ClayC (ν : ℝ) : Prop :=
  ∃ (u₀ : ℝ³ → ℝ³) (f : ℝ³ → ℝ → ℝ³),
    InitialVelocityConditionDecay u₀ ∧ ForceConditionDecay f ∧
    ¬ (∃ v p, NavierStokesExistenceAndSmoothnessRn ν u₀ f v p)

/-- Clay statement (D) for the viscosity `ν`. -/
def ClayD (ν : ℝ) : Prop :=
  ∃ (u₀ : ℝ³ → ℝ³) (f : ℝ³ → ℝ → ℝ³),
    InitialVelocityConditionPeriodic u₀ ∧ ForceConditionPeriodic f ∧
    ¬ (∃ v p, NavierStokesExistenceAndSmoothnessPeriodic ν u₀ f v p)

/-- The Millennium Prize problem for the viscosity `ν`: one of (A), (B), (C), (D). -/
def MillenniumProblem (ν : ℝ) : Prop := ClayA ν ∨ ClayB ν ∨ ClayC ν ∨ ClayD ν

/-- Global regularity for the forced problem on ℝ³: every nice datum and every nice
force have a smooth solution for all time with bounded energy. -/
def ForcedGlobalRegularityR3 (ν : ℝ) : Prop :=
  ∀ (u₀ : ℝ³ → ℝ³) (f : ℝ³ → ℝ → ℝ³),
    InitialVelocityConditionDecay u₀ → ForceConditionDecay f →
    ∃ v p, NavierStokesExistenceAndSmoothnessRn ν u₀ f v p

/-- Global regularity for the forced problem on the torus. -/
def ForcedGlobalRegularityTorus (ν : ℝ) : Prop :=
  ∀ (u₀ : ℝ³ → ℝ³) (f : ℝ³ → ℝ → ℝ³),
    InitialVelocityConditionPeriodic u₀ → ForceConditionPeriodic f →
    ∃ v p, NavierStokesExistenceAndSmoothnessPeriodic ν u₀ f v p

/-- Breakdown (C) is exactly the failure of forced global regularity on ℝ³. -/
theorem clayC_iff_not_forcedGlobalRegularityR3 (ν : ℝ) :
    ClayC ν ↔ ¬ ForcedGlobalRegularityR3 ν := by
  constructor
  · rintro ⟨u₀, f, hu, hf, hno⟩ hall
    exact hno (hall u₀ f hu hf)
  · intro h
    by_contra hC
    apply h
    intro u₀ f hu hf
    by_contra hno
    exact hC ⟨u₀, f, hu, hf, hno⟩

/-- Breakdown (D) is exactly the failure of forced global regularity on the torus. -/
theorem clayD_iff_not_forcedGlobalRegularityTorus (ν : ℝ) :
    ClayD ν ↔ ¬ ForcedGlobalRegularityTorus ν := by
  constructor
  · rintro ⟨u₀, f, hu, hf, hno⟩ hall
    exact hno (hall u₀ f hu hf)
  · intro h
    by_contra hD
    apply h
    intro u₀ f hu hf
    by_contra hno
    exact hD ⟨u₀, f, hu, hf, hno⟩

end NavierStokesClosure
