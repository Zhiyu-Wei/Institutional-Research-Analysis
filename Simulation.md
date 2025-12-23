# Simulation Walkthrough

This document explains the simulation code and the figures it produces.  
The goal is to help readers understand (i) what the model is doing, (ii) how to run the simulation, and (iii) how to interpret the outputs.

---

## 1. High-level idea

We simulate a two-stage admission system with:

- **1,000 students** split into **10 latent ability levels** (T1–T10), each level has 100 students.
- **10 schools** labeled **S1–S10**, each school finally admits exactly **100 students**.
- A two-stage mechanism:
  1. **Stage 1 (early admission)**: students are ranked by an exam score with interview noise; schools admit in order S10 → S9 → … → S1.
  2. **Stage 2 (placement)**: students who decline Stage 1 participate in a second exam; remaining seats are filled by Stage 2 scores.

We vary a policy parameter:

- For a focal school **S_k**, set its Stage 1 quota to **x ∈ {1,…,100}**
- Keep other schools’ Stage 1 quotas fixed
- Repeat the process **Nsim** times for each (S_k, x)

---

## 2. Code map

### 2.1 Key objects

- `prob_mat` (10×10): probability matrix for generating exam scores conditional on latent ability.
- `F_fast_draws(x, whichF, n_rep)`: returns **n_rep** Monte Carlo outcomes for a given school `whichF` and quota `x`.
- `draws_by_S` (list of length 10): each element is a **Nsim×100** matrix, storing raw Monte Carlo results for one school.
- `out_mat` (10×100): mean outcomes, computed by column means of each `draws_by_S[[k]]`.

### 2.2 Recommended file structure

Suggested layout (you can adapt this):

- `R/`
  - `01_prob_matrix.R` — constructs `prob_mat`
  - `02_core_simulation.R` — defines `F_fast_draws()` and helpers
  - `03_parallel_run.R` — parallel execution (foreach + doParallel)
  - `04_plots.R` — plotting functions
- `figures/` — saved plots
- `Simulation.md` — this walkthrough

---

## 3. Step-by-step: what happens in one simulation run

This section explains one Monte Carlo draw for fixed `(S_k, x)`.

### 3.1 Generate latent ability

Each student has a fixed latent ability:

- `true_level = rep(1:10, each = 100)`

This does not change across simulations.

### 3.2 Stage 1 exam + interview noise

We first generate the Stage 1 exam score conditional on ability:

- For ability level k, sample scores in {1,…,10} with probabilities `prob_mat[k, ]`.

Then we add interview noise (a small Uniform perturbation grouped by score) to break ties and reflect randomness.

**Output at this stage:** a ranking score used to allocate Stage 1 offers.

### 3.3 Stage 1 admission: quota allocation

Schools admit in order **S10 → S1** using Stage 1 ranking.

- Stage 1 quotas are fixed except the focal school:
  - focal school S_k admits `x`
  - others admit a constant (e.g., 60)

This yields a vector `admit1` indicating the Stage 1 school assignment (or 0 if not admitted).

### 3.4 Decision to enter Stage 2

Students may decline their Stage 1 offer and enter Stage 2.  
The probability depends on the *gap* between admitted school and latent ability:

- If admitted to a school at least as good as their level → do not enter Stage 2
- If admitted “below expectation” → enter Stage 2 with higher probability
- If not admitted → enter Stage 2

This yields a binary indicator `retry`.

### 3.5 Stage 2 exam + placement

Only students with `retry = 1` take the Stage 2 exam (generated similarly using `prob_mat`), with an additional small random perturbation.

Remaining seats for each school are computed as:

- `remain = 100 - (# students who accepted Stage 1 offers)`

Then Stage 2 placements fill these remaining seats in order of Stage 2 ranking.

### 3.6 Outcome statistic

For the focal school **S_k**, we compute:

- the mean latent ability among final admitted students to S_k

That is one Monte Carlo draw.

---

## 4. What the simulation produces

### 4.1 Raw Monte Carlo matrices (Nsim×100 per school)

For each school S_k:

- rows = Monte Carlo repetition index (1…Nsim)
- columns = Stage 1 quota x (1…100)
- entries = final mean latent ability among admitted students to S_k

We store them as a list:

- `draws_by_S[["S1"]]`, …, `draws_by_S[["S10"]]`

### 4.2 Mean outcome matrix (10×100)

We compute:

- `out_mat[k, x] = mean(draws_by_S[[k]][, x])`

This is the main summary matrix for trends.

---

## 5. How to run

### 5.1 Minimal run (single school, single x)

```r
# Example: S9 with x = 50, run 1000 Monte Carlo draws
draws <- F_fast_draws(x = 50, whichF = 9, n_rep = 1000)
mean(draws)
quantile(draws, c(0.025, 0.975))
