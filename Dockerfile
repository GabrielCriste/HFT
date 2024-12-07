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
   xubuntu-icon-theme

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

# Cria o ambiente Conda baseado no arquivo environment.yml
USER $NB_USER
RUN conda env create --file /opt/install/environment.yml

# Altera para o diretório onde o ambiente foi criado e ativa o ambiente Conda
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate base && conda env update --file /opt/install/environment.yml

   
