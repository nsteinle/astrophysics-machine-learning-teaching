#!/usr/bin/env bash
# =============================================================================
#  PTA Lab — Environment Setup Script
# Nathan Steinle
#
#  Usage:
#      bash setup.sh
#
#  What this does:
#    1. Creates a Python virtual environment called  pta_env/
#    2. Installs all required packages via pip (no conda, no C compilation)
#    3. Registers a Jupyter kernel for the environment
#
#  Requirements: Python 3.9-3.12, pip, internet access.
#  Run time: ~3-5 minutes.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/pta_env"
REQ_FILE="${SCRIPT_DIR}/requirements.txt"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()  { echo -e "\n${GREEN}== $* ${NC}"; }
warn() { echo -e "${YELLOW}  W  $*${NC}"; }
die()  { echo -e "${RED}  X  ERROR: $*${NC}"; exit 1; }

# prerequisites
log "Checking prerequisites"
command -v python3 &>/dev/null || die "python3 not found. Install Python 3.9+ first."
echo "  Python: $(python3 --version)  at $(which python3)"
[ -f "$REQ_FILE" ] || die "requirements.txt not found in $SCRIPT_DIR"
echo "  requirements.txt found."

# Step 1: create venv
log "Step 1 of 3 -- Creating virtual environment: $ENV_DIR"
if [ -d "$ENV_DIR" ]; then
    echo "  Already exists -- skipping. To rebuild: rm -rf $ENV_DIR && bash setup.sh"
else
    python3 -m venv "$ENV_DIR"
    echo "  Created."
fi
source "$ENV_DIR/bin/activate"
echo "  Activated: $(which python)"

# Step 2: install packages
log "Step 2 of 3 -- Installing packages via pip (~300 MB)"
pip install --upgrade pip --quiet
pip install -r "$REQ_FILE"
echo "  All packages installed."

# Step 3: register kernel
log "Step 3 of 3 -- Registering Jupyter kernel"
python -m ipykernel install --user --name pta_lab --display-name "PTA Lab (Python 3)"
echo "  Kernel 'pta_lab' registered."

# Smoke test
log "Verifying key imports"
python - << 'PYEOF'
import sys
failed = []
tests = [
    ('numpy',      'import numpy'),
    ('scipy',      'import scipy'),
    ('matplotlib', 'import matplotlib'),
    ('astropy',    'import astropy'),
    ('pint',       'import pint'),
    ('hasasia',    'import hasasia.sensitivity'),
    ('holodeck',   'import holodeck'),
]
for name, stmt in tests:
    try:
        exec(stmt)
        print(f'  OK {name}')
    except Exception as e:
        print(f'  FAIL {name}: {e}')
        failed.append(name)
if failed:
    print(f'\nFAILED: {failed}')
    sys.exit(1)
else:
    print('\n  All imports OK.')
PYEOF

log "Setup complete!"
cat << MSG

  Each session:
    source pta_env/bin/activate
    jupyter lab PTA_Lab_Student.ipynb

  Select kernel:  Kernel > Change Kernel > PTA Lab (Python 3)
  Deactivate:     deactivate

MSG
