FROM python:3.13

# 既存のパッケージインストール
RUN apt-get update && apt-get install -y \
    jq \
    wget \
    gettext \
    zip \
    less \
    vim \
    git \
    docker.io \
    curl \
    gnupg \
    awscli \
    && rm -rf /var/lib/apt/lists/*

# Terraformのインストール
RUN wget https://releases.hashicorp.com/terraform/1.10.0/terraform_1.10.0_linux_arm64.zip && \
    unzip ./terraform_1.10.0_linux_arm64.zip -d /usr/local/bin/

# Pythonパッケージのインストール
COPY ./requirements.txt /src/terraform/requirements.txt
RUN pip install -r /src/terraform/requirements.txt

CMD ["/bin/bash"]