# Imagem base do Jupyter com Python 3.7.6
FROM jupyter/base-notebook:python-3.7.6

# Mude para o usuário root para instalar dependências do sistema
USER root

# Atualiza pacotes e instala dependências do sistema
RUN apt-get -y update \
 && apt-get install -y dbus-x11 \
   firefox \
   xfce4 \
   xfce4-panel \
   xfce4-session \
   xfce4-settings \
   xorg \
   xubuntu-icon-theme \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala o TurboVNC
ARG TURBOVNC_VERSION=2.2.6
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get install -y -q ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get remove -y -q light-locker && \
   rm ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Garante que diretórios e arquivos têm permissões adequadas
RUN chown -R $NB_UID:$NB_GID $HOME

# Copia o código-fonte para o contêiner
ADD . /opt/install
RUN fix-permissions /opt/install

# Mude para o usuário padrão do notebook
USER $NB_USER

# Instala dependências Python a partir do requirements.txt
RUN cd /opt/install && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
    
