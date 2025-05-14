FROM python:3.9

WORKDIR /code

RUN apt-get update && apt-get install -y \
    wget \
    lsb-release \
    software-properties-common \
    gnupg \
    cmake \
    clang && \
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Cloning into a tmp dir as git can't clone into an existing dir
RUN git clone --recursive https://github.com/microsoft/BitNet.git /code

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

RUN pip install -U "huggingface_hub[cli]"; \
    huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir models/BitNet-b1.58-2B-4T; \
    python /code/setup_env.py -md /code/models/BitNet-b1.58-2B-4T -q i2_s;

EXPOSE 8080

CMD ["/code/build/bin/llama-server", "--host", "0.0.0.0", "--port", "8080", "--model", "models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf"]
