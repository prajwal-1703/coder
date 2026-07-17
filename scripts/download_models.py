import os
from huggingface_hub import snapshot_download

print("Downloading BAAI/bge-large-en-v1.5...")
snapshot_download(repo_id="BAAI/bge-large-en-v1.5", cache_dir="/data")
print("Successfully downloaded BAAI/bge-large-en-v1.5")

print("Downloading Qwen/Qwen3-32B-Instruct...")
snapshot_download(repo_id="Qwen/Qwen3-32B-Instruct", cache_dir="/data")
print("Successfully downloaded Qwen/Qwen3-32B-Instruct")
