# FROM ubuntu:latest # pick up ubuntu from buildenv
FROM ingomuellernet/buildenv-jitq:2021-09-03

ENV USER=dkoutsou
ENV GROUP=$USER

RUN apt-get update && apt-get install -y locales
ENV LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen --purge $LANG && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG LC_ALL=$LC_ALL LANGUAGE=$LANGUAGE

RUN apt-get update && apt-get install -y \
      #build-essential \ # let's skip these defaults and
                         # make sure that everything comes from
                         # buildenv
      software-properties-common \
      manpages \
      tzdata \
      psmisc \
      curl \
      git \
      wget \
      tmux \
      vim \
      time \
      graphviz \
      zsh \
      sudo

ENV TZ 'Europe/Zurich'
RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Add the workstation user, add to sudoers
RUN useradd -m -U -s /bin/bash $USER
RUN mkdir /home/$USER/.ssh && \
    chown $USER:$GROUP /home/$USER/.ssh && \
    chmod 700 /home/$USER/.ssh
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY ./jitq/requirements.txt /tmp
COPY ./jitq/requirements-top-level.txt /tmp

RUN pip3 install -r /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements-top-level.txt

WORKDIR /home/$USER
VOLUME /home/$USER
VOLUME /home/$USER/.ssh

COPY .bashrc /home/$USER/.bashrc

ENV TERM=xterm-256color

USER $USER
CMD ["ssh-agent", "tmux"]
