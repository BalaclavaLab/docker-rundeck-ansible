FROM java:8-jre-alpine

ENV RDECK_BASE=/opt/rundeck RDECK_VERSION=2.6.7 RDECK_SHA=3507dd797691fd314d12eb46374dd37724d00da2

COPY ec2.ini /etc/ansible/

RUN mkdir -p ${RDECK_BASE}/libext \
  && wget -O ${RDECK_BASE}/rundeck.jar http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-${RDECK_VERSION}.jar \
  && echo "${RDECK_SHA}  ${RDECK_BASE}/rundeck.jar" | sha1sum -c \
  && wget -P ${RDECK_BASE}/libext https://github.com/Batix/rundeck-ansible-plugin/releases/download/1.2.3/ansible-plugin-1.2.3.jar \

  # Without this kostylj Rundeck fails to start if db encryption is enabled.
  && unzip -p ${RDECK_BASE}/rundeck.jar pkgs/webapp/WEB-INF/rundeck/plugins/rundeck-jasypt-encryption-plugin-${RDECK_VERSION}.jar > ${RDECK_BASE}/libext/rundeck-jasypt-encryption-plugin-${RDECK_VERSION}.jar \

  # Install Ansible
  && apk add --no-cache py-pip python-dev musl-dev gcc libffi-dev openssl-dev \
  && pip install boto paramiko PyYAML Jinja2 httplib2 six ansible \
  && wget -O /etc/ansible/hosts https://raw.github.com/ansible/ansible/devel/contrib/inventory/ec2.py \
  && chmod +x /etc/ansible/hosts

EXPOSE 4440

VOLUME ["/opt/ansible", \
        "${RDECK_BASE}/etc", \
	"${RDECK_BASE}/var/logs", \
	"${RDECK_BASE}/server/logs", \
        "${RDECK_BASE}/server/config"]

ENTRYPOINT ["java","-jar","/opt/rundeck/rundeck.jar"]
