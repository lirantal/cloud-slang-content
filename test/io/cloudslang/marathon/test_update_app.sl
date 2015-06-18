#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################

namespace: io.cloudslang.marathon

imports:
  marathon: io.cloudslang.marathon

flow:
  name: test_update_app
  inputs:
    - marathon_host
    - marathon_port:
        required: false
    - proxyHost
    - proxyPort:
        required: false
    - json_file_for_creation
    - json_file_for_update
    - app_id
  workflow:
    - create_marathon_app:
         do:
           marathon.create_app:
             - marathon_host
             - marathon_port:
                required: false
             - proxyHost
             - proxyPort:
                required: false
             - json_file: json_file_for_creation
         navigate:
           SUCCESS: update_marathon_app
           FAILURE: FAIL_TO_CREATE
    - update_marathon_app:
        do:
          marathon.update_app:
            - marathon_host
            - marathon_port:
                required: false
            - proxyHost
            - proxyPort:
                required: false
            - json_file: json_file_for_update
            - app_id
        navigate:
          SUCCESS: delete_marathon_app
          FAILURE: FAIL_TO_UPDATE
    - delete_marathon_app:
        do:
          marathon.delete_app:
             - marathon_host
             - marathon_port:
                required: false
             - proxyHost
             - proxyPort:
                required: false
             - app_id
        navigate:
          SUCCESS: SUCCESS
          FAILURE: FAIL_TO_DELETE
  results:
    - SUCCESS
    - FAIL_TO_CREATE
    - FAIL_TO_DELETE
    - FAIL_TO_UPDATE