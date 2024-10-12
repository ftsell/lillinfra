FROM docker.io/debian
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&\
    apt-get install -y --no-install-recommends git pre-commit curl python3 python3-pip &&\
    curl -LsSf https://astral.sh/ruff/install.sh | sh
ENV PATH=$PATH:/root/.cargo/bin
