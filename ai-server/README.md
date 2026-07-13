# AI Inference Server

A self-hosted AI inference platform for software development, utilizing vLLM and Open WebUI over Docker Compose.

## Architecture

- **OS**: Ubuntu Server LTS
- **Engine**: vLLM (runs Qwen-Coder models efficiently on NVIDIA GPUs)
- **Frontend**: Open WebUI
- **Embeddings**: Text Embeddings Inference (TEI)

## Prerequisites

1. Ubuntu Server with NVIDIA drivers installed
2. Docker and Docker Compose plugin installed
3. NVIDIA Container Toolkit installed (for GPU support in Docker)
4. (Optional) Tailscale installed for remote access

## Setup

1. Check your `.env` file to ensure ports and model names are correct.
2. Ensure you have your `HUGGING_FACE_HUB_TOKEN` if you are using gated models (like Meta-Llama, some Qwen models, etc).
3. Bring up the stack:

```bash
docker compose up -d
```

## Access

- **Open WebUI**: `http://<server-ip>:3000`
- **vLLM API**: `http://<server-ip>:8000/v1`

## IDE Integration (VS Code / Continue)

In your `Continue` extension settings (`config.json`), configure your model as follows:

```json
{
  "models": [
    {
      "title": "Local Qwen Coder",
      "provider": "openai",
      "model": "Qwen/Qwen2.5-Coder-32B-Instruct",
      "apiBase": "http://<tailscale-ip>:8000/v1",
      "apiKey": "sk-dummy-key"
    }
  ]
}
```
