/-
Copyright (C) 2024 Nicolas Canceill
This file is part of the `Little` library
GNU General Public License v3.0+
See COPYING.md or https://www.gnu.org/licenses/
-/

import Mathlib

/-!
# Little.Basic

This file provides Fermat's little theorem.

## Results

- `mod_add_pow` : if `p` is prime then `(m + n)ᵖ ≡ mᵖ + nᵖ [MOD p]`
- `mod_pow_Fermat`: if `p` is prime then `nᵖ ≡ n [MOD p]`

## Notes

You should use `Nat.ModEq.pow_totient` instead of `mod_pow_Fermat`.
-/

lemma mod_add_pow (hp : Nat.Prime p) : (m + n)^p ≡ m^p + n^p [MOD p] := by
  rewrite [add_pow, <-Finset.add_sum_erase _ _ (Finset.self_mem_range_succ _), Finset.range_succ]
  rewrite [Finset.erase_insert_eq_erase, Finset.erase_eq_of_not_mem Finset.not_mem_range_self]
  rewrite (occs := .pos [7]) [<-Nat.succ_pred (Nat.Prime.ne_zero hp)]
  rewrite [Nat.succ_eq_add_one, Finset.sum_range_succ', Nat.pred_eq_sub_one, tsub_self, tsub_zero]
  rewrite [pow_zero, pow_zero, Nat.choose_zero_right, Nat.choose_self, Nat.cast_id]
  rewrite [mul_one, mul_one, mul_one, one_mul, <-Nat.add_assoc, Nat.add_comm, <-Nat.add_assoc]
  rewrite (occs := .pos [2]) [Nat.add_comm, <-add_zero (m^p + n^p)]
  rw [Nat.ModEq, Nat.ModEq.add_left _ (Nat.modEq_zero_iff_dvd.mpr (Finset.dvd_sum _))]
  intro _ h
  apply Nat.dvd_trans (Nat.Prime.dvd_choose_self hp (Nat.succ_ne_zero _) _) (Nat.dvd_mul_left _ _)
  exact Nat.add_lt_of_lt_sub (Finset.mem_range.mp h)

/-- **Fermat's little theorem** -/
theorem mod_pow_Fermat (hp : Nat.Prime p) : n^p ≡ n [MOD p] := by
  let mod_eq (a b : ℕ) (h : a = b) := congrArg ((flip HMod.hMod) p) h
  induction n with
  | zero => exact mod_eq _ _ (Nat.zero_pow (Nat.Prime.pos hp))
  | succ _ ih => exact Nat.ModEq.trans (mod_add_pow hp) (Nat.ModEq.add ih (mod_eq _ _ (one_pow p)))
