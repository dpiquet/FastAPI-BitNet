FROM python:3.9

WORKDIR /code

COPY ./app /code

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

RUN git clone --recursive https://github.com/microsoft/BitNet.git /tmp/BitNet && \
    cp -r /tmp/BitNet/* /code && \
    rm -rf /tmp/BitNet

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt && \
    pip install "fastapi[standard]" "uvicorn[standard]"

#RUN pip install -U "huggingface_hub[cli]"; \
#    huggingface-cli download 1bitLLM/bitnet_b1_58-large --local-dir models/bitnet_b1_58-large;

RUN pip install -U "huggingface_hub[cli]"; \
    huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir models/BitNet-b1.58-2B-4T;


RUN if [ -z "$(ls -A /code/models)" ]; then \
        echo "Error: No models found in /code/models" && exit 1; \
    fi


RUN if [ -d "/code/models/Llama3-8B-1.58-100B-tokens" ]; then \
        python /code/setup_env.py -md /code/models/Llama3-8B-1.58-100B-tokens -q i2_s --use-pretuned && \
        find /code/models/Llama3-8B-1.58-100B-tokens -type f -name "*f32*.gguf" -delete; \
    fi

RUN if [ -d "/code/models/bitnet_b1_58-large" ]; then \
        python /code/setup_env.py -md /code/models/bitnet_b1_58-large -q i2_s --use-pretuned && \
        find /code/models/bitnet_b1_58-large -type f -name "*f32*.gguf" -delete; \
    fi

RUN if [ -d "/code/models/bitnet_b1_58-3B" ]; then \
        python /code/setup_env.py -md /code/models/bitnet_b1_58-3B -q i2_s --use-pretuned && \
        find /code/models/bitnet_b1_58-3B -type f -name "*f32*.gguf" -delete; \
    fi

RUN if [ -d "/code/models/BitNet-b1.58-2B-4T" ]; then \
        python /code/setup_env.py -md /code/models/BitNet-b1.58-2B-4T -q i2_s; \
    fi

EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
