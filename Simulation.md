## Simulation

In this simulation, our goal is to construct a probability-based representation of students’ exam performance and use it as the foundation for subsequent sampling and analysis.

We begin by loading the required packages for parallel computation and reproducible simulations. We then source a set of custom functions hosted on GitHub, including a utility for constructing the probability matrix. The resulting object, `prob_mat`, characterizes the distribution of **student ability levels (T1–T10)** across **exam outcomes (S1–S10)** and serves as the core input for the simulation study.


```r
library(doParallel)
library(foreach)
library(doRNG)

source(
  "https://raw.githubusercontent.com/Zhiyu-Wei/Institutional-Research-Analysis/main/function.R"
)

prob_mat <- build_prob_mat()
```
### Probability Matrix (prob_mat)

Rows correspond to student ability levels (T1–T10), columns correspond to exam outcomes (10–1), and each entry represents the probability that a student at a given ability level attains a particular exam outcome. Each row therefore forms a valid probability distribution over exam outcomes.

|        | 10     | 9     | 8     | 7     | 6     | 5     | 4     | 3     | 2     | 1    |
|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
| T1 | 0.7202 | 0.2138 | 0.0660 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| T2 | 0.2378 | 0.5357 | 0.1974 | 0.0290 | 0.0001 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| T3 | 0.0143 | 0.2446 | 0.5509 | 0.1349 | 0.0553 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| T4 | 0.0014 | 0.0134 | 0.2293 | 0.5164 | 0.2240 | 0.0156 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| T5 | 0.0000 | 0.0016 | 0.0788 | 0.3156 | 0.5863 | 0.0177 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| T6 | 0.0000 | 0.0009 | 0.0475 | 0.1568 | 0.2468 | 0.5283 | 0.0107 | 0.0089 | 0.0001 | 0.0000 |
| T7 | 0.0000 | 0.0000 | 0.0010 | 0.0097 | 0.0503 | 0.3743 | 0.5533 | 0.0113 | 0.0001 | 0.0000 |
| T8 | 0.0000 | 0.0000 | 0.0009 | 0.0092 | 0.0476 | 0.1571 | 0.2472 | 0.5291 | 0.0089 | 0.0000 |
| T9 | 0.0000 | 0.0000 | 0.0001 | 0.0011 | 0.0072 | 0.0327 | 0.1101 | 0.2872 | 0.5469 | 0.0148 |
| T10| 0.0000 | 0.0000 | 0.0000 | 0.0002 | 0.0012 | 0.0064 | 0.0258 | 0.0857 | 0.2475 | 0.6331 |
