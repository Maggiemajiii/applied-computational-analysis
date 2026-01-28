#!/bin/bash
# Script to run MATLAB HW02_Solution.m from terminal
# Usage: ./run_matlab.sh

# Navigate to the matlab directory
cd "$(dirname "$0")/matlab"

# Run MATLAB script
# Method 1: Using -batch (recommended, non-interactive, exits after completion)
matlab -batch "run('HW02_Solution.m')"

# Alternative Method 2: Using -r (older syntax, may keep MATLAB open)
# matlab -nodisplay -nosplash -r "run('HW02_Solution.m'); exit;"

echo "MATLAB script completed. Check the figures/ directory for output."
