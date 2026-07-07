FROM eeacms/rsync AS runtime

WORKDIR /app
COPY scripts ./scripts
COPY ssh_host_keys ./ssh_host_keys
COPY ssh-key ./root/.ssh

EXPOSE 80
CMD ["client"]
