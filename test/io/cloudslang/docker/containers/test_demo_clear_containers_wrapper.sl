#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################

namespace: io.cloudslang.docker.containers

imports:
  docker_containers_examples: io.cloudslang.docker.containers.examples
  images: io.cloudslang.docker.images
  maintenance: io.cloudslang.docker.maintenance
  strings: io.cloudslang.base.strings
  print: io.cloudslang.base.print

flow:
  name: test_demo_clear_containers_wrapper
  inputs:
    - host
    - port:
        required: false
    - username
    - password:
        required: false
    - private_key_file:
        required: false
    - linked_image: "'meirwa/spring-boot-tomcat-mysql-app'"
    - linked_container_cmd:
        required: false
    - linked_container_name: "'spring-boot-tomcat-mysql-app'"

  workflow:
    - pre_test_cleanup:
         do:
           maintenance.clear_host:
             - docker_host: host
             - port:
                 required: false
             - docker_username: username
             - docker_password:
                 default: password
                 required: false
             - private_key_file:
                 required: false
         navigate:
           SUCCESS: start_mysql_container
           FAILURE: MACHINE_IS_NOT_CLEAN

    - start_mysql_container:
        do:
          docker_containers_examples.create_db_container:
            - host
            - port:
                required: false
            - username
            - password:
                required: false
            - private_key_file:
                required: false
        publish:
          - db_IP
        navigate:
          SUCCESS: pull_linked_image
          FAILURE: FAIL_TO_START_MYSQL_CONTAINER

    - pull_linked_image:
        do:
          images.pull_image:
            - image_name: linked_image
            - host
            - port:
                required: false
            - username
            - password:
                required: false
            - privateKeyFile:
                default: private_key_file
                required: false
        publish:
          - error_message
        navigate:
          SUCCESS: start_linked_container
          FAILURE: print_pull_linked_image_error

    - print_pull_linked_image_error:
        do:
          print.print_text:
            - text: error_message
        navigate:
          SUCCESS: FAIL_TO_PULL_LINKED_CONTAINER

    - start_linked_container:
        do:
          start_linked_container:
            - dbContainerIp: db_IP
            - dbContainerName: "'mysqldb'"
            - imageName: linked_image
            - containerName: linked_container_name
            - linkParams: "dbContainerName + ':mysql'"
            - cmdParams: "'-e DB_URL=' + dbContainerIp + ' -p ' + '8080' + ':8080'"
            - container_cmd:
                default: linked_container_cmd
                required: false
            - host
            - port:
                required: false
            - username
            - password:
                required: false
            - privateKeyFile:
                default: private_key_file
                required: false
            - timeout:
                default: "'30000000'"
        publish:
          - container_ID
          - error_message

    - demo_clear_containers_wrapper:
        do:
          docker_containers_examples.demo_clear_containers_wrapper:
            - db_container_ID: "'mysqldb'"
            - linked_container_ID: linked_container_name
            - docker_host: host
            - port:
                required: false
            - docker_username: username
            - docker_password:
                default: password
                required: false
            - private_key_file:
                required: false
        navigate:
          SUCCESS: verify
          FAILURE: FAILURE

    - verify:
        do:
          get_all_containers:
            - host
            - port:
                required: false
            - username
            - password:
                required: false
            - private_key_file:
                required: false
            - all_containers: true
        publish:
          - all_containers: container_list

    - compare:
        do:
          strings.string_equals:
            - first_string: all_containers
            - second_string: "''"
        navigate:
          SUCCESS: clear_docker_host
          FAILURE: FAILURE

    - clear_docker_host:
        do:
         clear_containers:
           - docker_host: host
           - port:
               required: false
           - docker_username: username
           - docker_password:
               default: password
               required: false
           - private_key_file:
               required: false
        navigate:
         SUCCESS: SUCCESS
         FAILURE: MACHINE_IS_NOT_CLEAN

  results:
    - SUCCESS
    - FAILURE
    - MACHINE_IS_NOT_CLEAN
    - FAIL_TO_START_MYSQL_CONTAINER
    - FAIL_TO_PULL_LINKED_CONTAINER