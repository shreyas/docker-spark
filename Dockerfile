FROM gettyimages/spark 
MAINTAINER Shreyas Kulkarni

# OpenSSH connection is needed for spark master to talk to workers
# we also need git and vim 
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install openssh-server git vim wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# start openssh server
#RUN service ssh start

#generate a local key
RUN ssh-keygen -t rsa -b 2048 -C spark_local -N '' -f ~/.ssh/local \
    && cp ~/.ssh/local.pub ~/.ssh/authorized_keys

# start ssh-agent and load the local key
#RUN echo "#!/bin/bash" >~/.ssh/sshagent.$(hostname) \
#    && ssh-agent >>~/.ssh/sshagent.$(hostname) \
#    && . ~/.ssh/sshagent.$(hostname) \
#    && ssh-add ~/.ssh/local

# setup our bootstrap for entrypoint
COPY bootstrap /usr/local/bin/start.spark
RUN chmod +x /usr/local/bin/start.spark

# setup spark env
RUN cp /usr/spark/conf/spark-env.sh.template /usr/spark/conf/spark-env.sh \
    && echo "export SPARK_EXECUTOR_INSTANCES=2" >>/usr/spark/conf/spark-env.sh \
    && echo "export JAVA_HOME=/usr/java" >>/usr/spark/conf/spark-env.sh

# export master and worker webui ports 
EXPOSE 8080 4040
EXPOSE 8081 8082 8083 8084

