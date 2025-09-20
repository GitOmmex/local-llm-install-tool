# Local LLM Install Tool

## Overview
This tool automates the installation and setup of a local Large Language Model (LLM) environment on Windows. It detects your system's RAM and GPU VRAM, recommends an appropriate LLM model, and guides you through the installation of the required software and model files. The tool also downloads and sets up the Text Generation WebUI for easy model interaction.

## Features
- Detects system RAM and GPU VRAM automatically
- Recommends the best LLM model for your hardware
- Allows manual selection of LLM model
- Checks for Python installation and guides installation if missing
- Downloads and sets up Text Generation WebUI
- Downloads the selected LLM model files
- Sets up Python virtual environment and installs dependencies

## Supported LLM Models
- **Qwen3 4B Instruct 2507** (Recommended for systems with less than 12 GB combined memory)
- **GPT Oss 20B** (Recommended for systems with 12–64 GB combined memory)
- **GPT Oss 120B** (Recommended for systems with more than 64 GB combined memory)

## System Requirements
- **Operating System:** Windows 10/11
- **Python:** Version 3.8 or higher (automatically checked)
- **RAM:** Minimum 16 GB (more recommended for larger models)
- **GPU:** Dedicated Nvidia GPU recommended for optimal performance. Intel/AMD GPUs supported, but may have issues.
- **Disk Space:** At least 20 GB free (more for larger models)
- **Internet Connection:** Required for downloading model files and dependencies

## Usage
1. Download and extract this tool.
2. Run `install.bat` as Administrator.
3. Follow the prompts:
   - The tool will detect your hardware and recommend an LLM model.
   - You can accept the recommendation or manually select a model.
   - The tool will check for Python and guide you if it's missing.
   - The required files and dependencies will be downloaded and installed automatically.
4. After installation, run `start_windows.bat` in the `text-generation-webui-main` directory to launch the WebUI.

## Notes
- The tool will abort if Python is not installed and you choose not to install it.
- Model downloads may take time depending on your internet speed and model size.
- For best results, ensure your GPU drivers are up to date.

## License
See `LICENSE` for details.
