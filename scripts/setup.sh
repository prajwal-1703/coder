#!/bin/bash
# =============================================================================
#  setup.sh — Full project setup script
#  Usage: bash scripts/setup.sh
#
#  Prerequisites:
#    1. Place your .env file in the project root before running.
#       The .env file must contain:
#         HUGGING_FACE_HUB_TOKEN=hf_xxx...
#         MODEL_NAME=Qwen/Qwen3-32B
#         EMBEDDING_MODEL_NAME=BAAI/bge-large-en-v1.5
#         VLLM_PORT=8000
#         WEBUI_PORT=3000
#    2. Docker and Docker Compose must be installed and running.
#    3. NVIDIA Container Toolkit must be installed (for GPU access).
#    4. git and git-lfs must be installed.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; exit 1; }
step()    { echo -e "\n${BOLD}──────────────────────────────────────────${RESET}"; echo -e "${BOLD}$*${RESET}"; }

# ── Step 0: Sanity checks ─────────────────────────────────────────────────────
step "Step 0: Checking prerequisites"

ENV_FILE="$PROJECT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    error ".env file not found at $ENV_FILE\nPlease create it before running this script.\nSee .env.example for required fields."
fi

command -v docker &>/dev/null   || error "Docker is not installed or not in PATH."
docker info &>/dev/null          || error "Docker daemon is not running. Start Docker and try again."
command -v git &>/dev/null       || error "git is not installed."
command -v git-lfs &>/dev/null   || error "git-lfs is not installed. Run: apt install git-lfs && git lfs install"

success "All prerequisites satisfied."

# Load .env variables
set -a; source "$ENV_FILE"; set +a

if [ -z "$HUGGING_FACE_HUB_TOKEN" ]; then
    error "HUGGING_FACE_HUB_TOKEN is not set in .env"
fi
success ".env loaded. HF token found."

# ── Step 1: Download models via git + LFS ─────────────────────────────────────
step "Step 1: Downloading AI models (this may take a long time)"

git lfs install --skip-repo 2>/dev/null || true

clone_model() {
    local repo="$1"
    local dest="$2"
    local display_name
    display_name="$(basename "$dest")"

    info "Model: $display_name"
    if [ -d "$dest/.git" ]; then
        warn "  Already exists — pulling LFS files..."
        git -C "$dest" lfs pull
    else
        info "  Cloning from huggingface.co..."
        GIT_LFS_SKIP_SMUDGE=1 git clone \
            "https://user:${HUGGING_FACE_HUB_TOKEN}@huggingface.co/${repo}" \
            "$dest"
        info "  Pulling LFS files (large binary weights)..."
        cd "$dest" && git lfs pull && cd "$PROJECT_DIR"
    fi
    success "  $display_name — done."
}

clone_model "BAAI/bge-large-en-v1.5" "$PROJECT_DIR/models/bge-large-en-v1.5"
clone_model "Qwen/Qwen3-32B"         "$PROJECT_DIR/models/Qwen3-32B"

# ── Step 2: Pull Docker images ────────────────────────────────────────────────
step "Step 2: Pulling Docker images"

cd "$PROJECT_DIR"
docker compose --env-file .env pull
success "Docker images pulled."

# ── Step 3: Start the stack ───────────────────────────────────────────────────
step "Step 3: Starting services"

docker compose --env-file .env up -d
success "Services started."

# ── Step 4: Status ────────────────────────────────────────────────────────────
step "Step 4: Checking container status"

echo ""
docker compose --env-file .env ps
echo ""

WEBUI_PORT="${WEBUI_PORT:-3000}"
echo -e "${GREEN}${BOLD}Setup complete!${RESET}"
echo -e "  Open-WebUI  →  ${CYAN}http://localhost:${WEBUI_PORT}${RESET}"
echo -e "  vLLM API    →  ${CYAN}http://localhost:8000/v1${RESET}"
echo -e "  Embeddings  →  ${CYAN}http://localhost:8080${RESET}"
echo ""
echo -e "${YELLOW}Note: vLLM may take 2-5 minutes to load the model before the UI becomes usable.${RESET}"
