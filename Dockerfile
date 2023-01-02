# Base off the lastest ubuntu image
FROM ubuntu:18.04

# Metadata
LABEL maintainer="jakob.pennington@gmail.com"

# Environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND=noninteractive

#Set up environment
WORKDIR /root/workspace
RUN mkdir ${HOME}/toolkit \
    && mkdir ${HOME}/wordlists

# Add a volume
VOLUME ["/root/workspace"]

# Install base packages
# This list should be stable to optimise docker builds
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    curl \
    dnsutils \
    gcc \
    git \
    gnupg \
    iputils-ping \
    jq \
    locales \
    make \
    nano \
    net-tools \
    perl \
    python \
    python-pip \
    python3 \
    python3-pip \
    ssh \
    tmux \
    tzdata \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Add Kali pagkages list
RUN sh -c "echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' > /etc/apt/sources.list.d/kali.list" \
    && wget 'https://archive.kali.org/archive-key.asc' \
    && apt-key add archive-key.asc

# The important part (fonts)
RUN locale-gen "en_US.UTF-8" \
    && LC_ALL=en_US.UTF-8 \
    && LANG=en_US.UTF-8 \
    && cd ${HOME}/toolkit \
    && git clone https://github.com/powerline/fonts.git --depth=1 \
    && sh fonts/install.sh \
    && rm -rf fonts

# Install dependencies
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    libpcap-dev \
    python3.7 \
    xauth

# Install essential tools
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    amass \
    awscli \
    dirb \
    dnsrecon \
    ftp \
    hydra \
    masscan \
    nikto \
    nmap \
    sqlmap \
    theharvester \
    whois \
    wpscan

# go
RUN cd /opt \
    && wget https://dl.google.com/go/go1.19.4.linux-amd64.tar.gz \
    && tar -xvf go1.19.4.linux-amd64.tar.gz \
    && rm -rf /opt/go1.19.4.linux-amd64.tar.gz \
    && mv go /usr/local
ENV GOROOT /usr/local/go
ENV GOPATH /root/go
ENV PATH ${GOPATH}/bin:${GOROOT}/bin:${PATH}

# configure python(s)
RUN python -m pip install --upgrade setuptools && python3 -m pip install --upgrade setuptools && python3.7 -m pip install --upgrade setuptools && python3 -m pip install --upgrade wheel

# install pip modules
RUN python3 -m pip install \
    loguru \
    pandas \
    slack-webhook \
    xmltodict

# Install odbc driver and pyodbc
# From https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update -y \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17 unixodbc-dev python3-setuptools python3-dev \
    && python3 -m pip install pyodbc


# chaos client - projectdiscovery.io
RUN go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
# fuff
RUN go install github.com/ffuf/ffuf@latest
# gron
RUN go install github.com/tomnomnom/gron@latest
# hakrawler
RUN go install github.com/hakluke/hakrawler@latest
# httprobe
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
# subfinder
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
#nuclei
RUN go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
#naabu
RUN go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
#mapcider
RUN go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest
#katana
RUN go install github.com/projectdiscovery/katana/cmd/katana@latest
#dnsx
RUN go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
#uncover
RUN go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest
#asnmap
RUN go install github.com/projectdiscovery/asnmap/cmd/asnmap@latest
#gobuster
RUN go install github.com/OJ/gobuster/v3@latest
#gau
RUN go install github.com/lc/gau/v2/cmd/gau@latest
#wayback
RUN go install github.com/tomnomnom/waybackurls@latest
#unfurl
RUN go install github.com/tomnomnom/unfurl@latest
#puredns
RUN go install github.com/d3mondev/puredns/v2@latest
#gotator
RUN go install -v https://github.com/Josue87/gotator@latest

# Set up personal configuration
RUN cd ${HOME}/toolkit \
    && git clone https://github.com/JakobRPennington/config.git \
    && cd config \
    && chmod +x setup-linux.sh \
    && ./setup-linux.sh

# Run with ZSH
CMD ["/usr/bin/zsh","-l"]
