# Base image
FROM jupyter/base-notebook:python-3.7.6

# Trocar para o usuário root para instalar pacotes do sistema
USER root

# Atualizar e instalar pacotes necessários
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    dbus-x11 \
    firefox \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instalar TurboVNC
ARG TURBOVNC_VERSION=2.2.6
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
    apt-get install -y ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
    apt-get remove -y light-locker && \
    rm -f turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
    ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Corrigir permissões em diretórios afetados
RUN chown -R $NB_UID:$NB_GID $HOME

# Adicionar os arquivos do projeto ao contêiner
ADD . /opt/install
RUN fix-permissions /opt/install

# Mudar de volta para o usuário padrão do Jupyter
USER $NB_USER

# Atualizar ou criar o ambiente Conda
RUN cd /opt/install && conda env update -n base --file environment.yml
