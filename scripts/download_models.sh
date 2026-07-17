#!/bin/bash
set -e

MIRROR="https://hf-mirror.com"
DATA_DIR="${1:-/data}"

# Install git-lfs if not present
if ! command -v git-lfs &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq git-lfs curl
    git lfs install
fi

clone_model() {
    local repo="$1"
    local dest="$2"
    echo ">>> Cloning $repo into $dest ..."
    if [ -d "$dest/.git" ]; then
        echo "    Already exists, pulling latest..."
        git -C "$dest" pull
    else
        # Use huggingface.co directly with token embedded in URL (mirror doesn't support token auth)
        local auth_url="https://user:${HF_TOKEN}@huggingface.co/${repo}"
        GIT_LFS_SKIP_SMUDGE=1 git clone "$auth_url" "$dest"
        cd "$dest" && git lfs pull && cd -
    fi
    echo ">>> Done: $repo"
}

mkdir -p "$DATA_DIR"

clone_model "BAAI/bge-large-en-v1.5"   "$DATA_DIR/bge-large-en-v1.5"
clone_model "Qwen/Qwen3-32B-Instruct"   "$DATA_DIR/Qwen3-32B-Instruct"

echo ""
echo "All models downloaded successfully to $DATA_DIR"
