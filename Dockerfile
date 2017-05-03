FROM ubuntu:trusty
ADD spin.bash /usr/bin/spin.bash

EXPOSE 8080
CMD ["/usr/bin/spin.bash"]
