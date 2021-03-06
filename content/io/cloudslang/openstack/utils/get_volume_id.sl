#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Retrieves the volume id from the response of the get_openstack_volumes operation of a given volume by name.
#
# Inputs:
#   - volume_body - response of get_openstack_servers operation
#   - volume_name - volume name
# Outputs:
#   - volume_id - ID of the specified volume
#   - return_result - was parsing was successful or not
#   - return_code - 0 if parsing was successful, -1 otherwise
#   - error_message - error message
# Results:
#   - SUCCESS - parsing was successful (returnCode == '0')
#   - FAILURE - otherwise
####################################################

namespace: io.cloudslang.openstack.utils

operation:
  name: get_volume_id
  inputs:
    - volume_body
    - volume_name
  action:
    python_script: |
      try:
        import json
        volumes = json.loads(volume_body)['volumes']
        matched_volume = next(volume for volume in volumes if volume['name'] == volume_name)
        volume_id = matched_volume['id']
        return_code = '0'
        return_result = 'Parsing successful.'
      except StopIteration:
        return_code = '-1'
        return_result = 'No volumes in list'
      except  ValueError:
        return_code = '-1'
        return_result = 'Parsing error.'

  outputs:
    - volume_id
    - return_result
    - return_code
    - error_message: return_result if return_code == '-1' else ''
  results:
    - SUCCESS: return_code == '0'
    - FAILURE
