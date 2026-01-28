# MA563 HW2 Solution

This directory contains the complete solution to Homework 2 for MA563 Applied Computational Analysis.

## Directory Structure

```
MA563HW2/
├── HW2.Rmd              # Main R Markdown document (renders to PDF)
├── matlab/              # MATLAB code directory
│   ├── HW02_Solution.m  # Main script to generate all figures
│   ├── newt_polyval.m   # Newton form evaluation function
│   ├── divided_diff.m   # Divided difference computation
│   └── chebyshev_nodes.m # Chebyshev node generation
└── figures/             # Generated figures (auto-created)
    ├── Q2_comparison.png
    ├── Q3a_runge.png
    ├── Q3b_chebyshev.png
    └── Q3c_spline.png
```

## Usage

### Step 1: Generate Figures (Run MATLAB)

1. Open MATLAB
2. Navigate to this directory: `cd MA563HW2`
3. Run the main script: `run('matlab/HW02_Solution.m')`

This will:
- Execute all computations
- Generate all figures
- Save figures to `figures/` directory (both PNG and PDF formats)

### Step 2: Render R Markdown Document

1. Open R or RStudio
2. Navigate to this directory
3. Render the document:
   ```r
   rmarkdown::render("HW2.Rmd")
   ```

The rendered PDF will include:
- All theoretical explanations
- MATLAB code (displayed, not executed)
- Generated figures automatically included

## Features

- **Clean separation**: MATLAB code in `matlab/`, figures in `figures/`
- **R Markdown**: Professional formatting with LaTeX math
- **Code display**: MATLAB chunks show code without execution (`eval=FALSE`)
- **Figure integration**: Uses `include_graphics()` to automatically include generated figures
- **Runnable MATLAB**: Complete script that generates all results

## Notes

- The R Markdown file displays MATLAB code but doesn't execute it
- To actually run the code, use the MATLAB script in `matlab/HW02_Solution.m`
- Figures are generated in both PNG (for display) and PDF (for publication) formats
- The `run-matlab` chunk in `HW2.Rmd` is provided for reference but disabled by default
