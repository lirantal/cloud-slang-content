#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Deletes an OpenStack volume.
#
# Inputs:
#   - host - OpenStack machine host
#   - blockstorage_port - optional - port used for creating volumes on OpenStack - Default: 8776
#   - token - OpenStack token obtained after authentication
#   - tenant - OpenStack tenantID obtained after authentication
#   - volume_id - ID of volume to be deleted
#   - proxy_host - optional - proxy server used to access the web site - Default: none
#   - proxy_port - optional - proxy server port - Default: none
# Outputs:
#   - return_result - response of the operation
#   - status_code - normal status code is 202
#   - error_message: returnResult if statusCode != 202
# Results:
#   - SUCCESS - operation succeeded (statusCode == '202')
#   - FAILURE - otherwise
####################################################

namespace: io.cloudslang.openstack.blockstorage

operation:
  name: delete_openstack_volume
  inputs:
    - host
    - blockstorage_port:
        default: "'8776'"
    - token
    - tenant
    - volume_id
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxyHost:
        default: "proxy_host if proxy_host else ''"
        overridable: false
    - proxyPort:
        default: "proxy_port if proxy_port else ''"
        overridable: false
    - headers:
        default: "'X-AUTH-TOKEN:' + token"
        overridable: false
    - url:
        default: "'http://'+ host + ':' + blockstorage_port + '/v2/' + tenant + '/volumes/' + volume_id"
        overridable: false
    - method:
        default: "'delete'"
        overridable: false
  action:
    java_action:
      className: io.cloudslang.content.httpclient.HttpClientAction
      methodName: execute
  outputs:
    - return_result: "'' if 'returnResult' not in locals() else returnResult"
    - status_code: statusCode
    - error_message: returnResult if statusCode != '202' else ''
  results:
    - SUCCESS: "'statusCode' in locals() and statusCode == '202'"
    - FAILURE