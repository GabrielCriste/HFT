# Usa a imagem base do Jupyter com Python 3.7.6
FROM jupyter/base-notebook:python-3.7.6

# Defina o usuário como root para instalar pacotes no sistema
USER root

# Atualiza o sistema e instala pacotes necessários
RUN apt-get -y update \
 && apt-get install -y dbus-x11 \
   firefox \
   xfce4 \
   xfce4-panel \
   xfce4-session \
   xfce4-settings \
   xorg \
   xubuntu-icon-theme \
   wget \
   bzip2 \
   ca-certificates \
   curl

# Instala o Conda manualmente
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -f -p /opt/conda && \
    rm miniconda.sh

# Adiciona Conda ao PATH
ENV PATH /opt/conda/bin:$PATH

# Remove light-locker para evitar bloqueio de tela
ARG TURBOVNC_VERSION=2.2.6
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get install -y -q ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get remove -y -q light-locker && \
   rm ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Corrige permissões dos arquivos no diretório HOME
RUN chown -R $NB_UID:$NB_GID $HOME

# Copia os arquivos locais para o diretório /opt/install no container
ADD . /opt/install

# Ajusta permissões de arquivos copiados
RUN fix-permissions /opt/install

# Cria o ambiente Conda baseado no arquivo environment.yml em um diretório específico
USER $NB_USER
RUN conda env create -f /opt/install/environment.yml --prefix /opt/conda/envs/myenv

# Alternativa: Ativa o ambiente Conda diretamente (não é necessário no Dockerfile, mas pode ser feito na execução)
CMD ["bash"]

