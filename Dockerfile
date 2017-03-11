FROM resin/rpi-raspbian:latest

RUN apt-get update && \ 
	apt-get install -y --no-install-recommends \
        build-essential \
        curl \
		wget \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        unzip \
		vim \
		git \
		zsh \
		screen \
		tmux

RUN apt-get install -y --no-install-recommends \
		python3 \
		python3-dev \
		libblas-dev \
		liblapack-dev\
    	libatlas-base-dev \
		gfortran \
        python3-pip \
        tk-dev \
        python3-tk \
        pkg-config \
        libfreetype6-dev \
		libjpeg-dev \
		zlib1g-dev
RUN  apt-get clean && \
        rm -rf /var/lib/apt/lists/*

#RUN pip install -U distribute \
#        setuptools \
#        pip

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
        rm get-pip.py

RUN pip install -U --upgrade pip

RUN pip install -U distribute \
		setuptools \
       	ipykernel \
        jupyter \
        numpy \
        matplotlib 

RUN pip install -U scipy
RUN pip install -U scikit-image
RUN pip install -U scikit-learn
RUN pip install -U keras
RUN pip install -U pandas
RUN pip install -U statsmodels
RUN pip install -U xlrd
RUN pip install -U openpyxl

RUN python3 -m ipykernel.kernelspec

# Jupyter themes
RUN pip install -U jupyterthemes
RUN jt -t oceans16 -f roboto -fs 12 -tf roboto -tfs 13 -T

# Jupyter notebook config to accept password
COPY jupyter_notebook_config.py /root/.jupyter/

# Jupyter add gist button
RUN jupyter nbextension install https://rawgithub.com/minrk/ipython_extensions/master/nbextensions/gist.js
RUN jupyter nbextension enable gist

# Copy sample notebooks.
COPY notebooks /notebooks
COPY clone_ipython_notebooks.sh /notebooks

# Jupyter has issues with being run directly:
# https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /

# TensorFlow

RUN wget https://github.com/samjabrahams/tensorflow-on-raspberry-pi/releases/download/v1.0.0/tensorflow-1.0.0-cp34-cp34m-linux_armv7l.whl
RUN sudo pip3 install tensorflow-1.0.0-cp34-cp34m-linux_armv7l.whl
#ENV TENSORFLOW_VERSION 0.10.0rc0

#RUN pip --no-cache-dir install \
#        https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.10.0rc0-cp34-cp34m-linux_x86_64.whl

# Something Jupyter suggests to do:
# http://jupyter-notebook.readthedocs.io/en/latest/public_server.html#docker-cmd
#ENV TINI_VERSION v0.9.0
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
#RUN chmod +x /tini
#ENTRYPOINT ["/tini", "--"]

# Make zsh default
RUN chsh -s /usr/bin/zsh
# use grml zshrc (https://grml.org/zsh/)
RUN wget -O ~/.zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
RUN wget -O ~/.zshrc.local  http://git.grml.org/f/grml-etc-core/etc/skel/.zshrc
RUN echo "TERM=xterm-256color" >> ~/.zshrc

# tensorboard
EXPOSE 6006

# jupyter
EXPOSE 8888
EXPOSE 8889

WORKDIR "/notebooks"

#CMD ["/bin/bash"]
CMD ["/run_jupyter.sh"]
