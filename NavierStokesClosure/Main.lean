import NavierStokesClosure.Clay
import NavierStokes.ComparatorSolution
import Euler.Solution

/-!
# The closure

Every theorem here is a short consequence of the two theorems proved in the
formalization of OpenAI, *Finite time blowup for Navier–Stokes* (2026), and of the
Euler theorem of the companion paper. Those theorems are checked by Comparator
against the independent reference statement, with only the axioms `propext`,
`Quot.sound` and `Classical.choice`.
-/

namespace NavierStokesClosure

open NavierStokes.Comparator

/-- **Theorem A (Clay (C)).** For every positive viscosity, breakdown on ℝ³. -/
theorem clayC (ν : ℝ) (hν : 0 < ν) : ClayC ν :=
  NavierStokes.Comparator.navier_stokes_breakdown_R3 ν hν

/-- **Theorem B (Clay (D)).** For every positive viscosity, breakdown on the torus. -/
theorem clayD (ν : ℝ) (hν : 0 < ν) : ClayD ν :=
  NavierStokes.Comparator.navier_stokes_breakdown_periodic ν hν

/-- **Corollary 1.** Both breakdown statements hold at once. -/
theorem clayC_and_clayD (ν : ℝ) (hν : 0 < ν) : ClayC ν ∧ ClayD ν :=
  ⟨clayC ν hν, clayD ν hν⟩

/-- **Corollary 2 (the Millennium Prize problem).** For every positive viscosity,
one of Fefferman's four statements holds. -/
theorem millennium (ν : ℝ) (hν : 0 < ν) : MillenniumProblem ν :=
  Or.inr (Or.inr (Or.inl (clayC ν hν)))

/-- **Corollary 3.** Global regularity with a force fails on ℝ³, for every viscosity. -/
theorem not_forcedGlobalRegularityR3 (ν : ℝ) (hν : 0 < ν) :
    ¬ ForcedGlobalRegularityR3 ν :=
  (clayC_iff_not_forcedGlobalRegularityR3 ν).1 (clayC ν hν)

/-- **Corollary 4.** Global regularity with a force fails on the torus. -/
theorem not_forcedGlobalRegularityTorus (ν : ℝ) (hν : 0 < ν) :
    ¬ ForcedGlobalRegularityTorus ν :=
  (clayD_iff_not_forcedGlobalRegularityTorus ν).1 (clayD ν hν)

/-- **Corollary 5 (the Euler equation).** Some smooth, compactly supported starting
velocity has no global smooth solution of the unforced Euler equations in the energy
class. -/
theorem euler_breakdown :
    ∃ u₀ : EuclideanSpace ℝ (Fin 3) → EuclideanSpace ℝ (Fin 3),
      Euler.InitialVelocityConditionDecay u₀ ∧
      ¬ (∃ v p, Euler.EulerExistenceAndSmoothnessR3 u₀ v p) :=
  Euler.euler_breakdown_R3

end NavierStokesClosure
