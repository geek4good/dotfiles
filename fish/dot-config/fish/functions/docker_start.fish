function docker_start
    limactl start docker
    set -gx DOCKER_HOST (limactl list docker --format 'unix://{{.Dir}}/sock/docker.sock')
end
