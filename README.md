# Monte Carlo Simulation of Two-Stage University Admissions

## Overview

This repository presents a Monte Carlo simulation framework designed to study how admission strategies affect the academic composition of admitted students under a two-stage university admission system.

In many higher education systems, student admission is conducted through multiple channels. In Taiwan, for example, universities admit students through an early admission stage (e.g., application-based or exam-based screening) followed by a later centralized placement stage. A key strategic decision for universities is how many students to admit in the first stage. While admitting more students early may secure enrollment, it can also alter the composition of candidates remaining for the second stage and ultimately affect the quality and stability of admitted cohorts.

The consequences of this trade-off are not immediately obvious. Increasing early admission quotas may reduce competition in later stages, but high-performing students who are admitted elsewhere in the first stage may opt out of the second stage entirely. As a result, the final intake may include students with lower academic standing, even for top-ranked schools. These structural effects are difficult to isolate using real-world data alone, motivating a simulation-based approach.

This project develops a fully reproducible Monte Carlo framework to explore these dynamics in a controlled setting.

---

## Core Research Question

The simulation is designed to address the following questions:

- How does the number of students admitted in the first stage affect the **final average academic level** of a school’s admitted cohort?
- How stable are the outcomes under repeated realizations of the admission process?
- Do schools of different rankings respond differently to changes in early admission quotas?
- Does admission policy influence not only the expected outcome but also its **uncertainty**?

---

## Simulation Design

### Students

- The population consists of 1,000 students.
- Each student has an unobserved latent academic ability, categorized into 10 levels (T1–T10).
- Each ability level contains the same number of students.
- Academic ability is fixed and does not change across simulations.

### Schools

- There are 10 schools, labeled S1 (lowest-ranked) through S10 (highest-ranked).
- Each school ultimately admits exactly 100 students.
- School rankings are fixed and serve only as identifiers.

### Admission Mechanism

Admission proceeds in two stages:

1. **First-stage admission**  
   Students are ranked based on exam performance with an added random perturbation to reflect stochastic factors such as interviews or test-day variability. Schools admit students sequentially according to their rankings and assigned quotas.

2. **Second-stage placement**  
   Students who decline first-stage offers enter a centralized placement process. The probability of declining an offer depends on the gap between a student’s latent ability and the school they were admitted to. Remaining seats are filled based on second-stage exam performance.

All stochastic components and behavioral rules are explicitly specified and held fixed across experiments.

---

## Policy Variation

For each school \( S_k \) (k = 1, …, 10), the simulation varies the number of students admitted in the first stage:

- The focal school admits \( x = 1, \dots, 100 \) students in the first stage.
- All other schools keep their first-stage quotas fixed.
- For each combination of \( (S_k, x) \), the admission process is repeated 1,000 times.

This design allows us to isolate the effect of early admission quotas on each school while keeping the broader system unchanged.

---

## Outputs and Visualization

The simulation produces multiple layers of output:

1. **Average outcomes**  
   A 10 × 100 matrix summarizing the mean academic level of admitted students for each school and each first-stage quota.

2. **Monte Carlo realizations**  
   For each school, a 1,000 × 100 matrix storing the result of every individual simulation run, enabling analysis of variability and risk.

3. **Uncertainty assessment**  
   Pointwise 95% Monte Carlo intervals are constructed to illustrate the dispersion of outcomes under repeated admissions.

These results are visualized using trend curves, point clouds of individual simulations, and confidence bands.

---

## Why This Matters

Rather than focusing on a single optimal policy, this simulation highlights the structural consequences of admission decisions. The results show that admission strategies can affect not only the expected academic level of admitted students but also the stability and uncertainty of outcomes. In some cases, admitting more students early may lead to lower average quality or greater variability in final enrollment.

By making all assumptions explicit and the code fully reproducible, this project provides a flexible platform for exploring admission policies and their unintended effects.
