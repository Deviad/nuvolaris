#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
if ! which kind >/dev/null
then echo "Please install Kind from https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
     exit 1
fi
if test "$1" == "destroy"
then kind delete clusters kind
     exit 0
fi
if kind get clusters | grep kind >/dev/null
then kubectl --kubeconfig=kubeconfig get nodes
else cat <<EOF >$$.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraPortMappings:
  - containerPort: 30232
    hostPort: 3232
    protocol: TCP
  - containerPort: 30233
    hostPort: 3233
    protocol: TCP
  - containerPort: 30896
    hostPort: 7896
    protocol: TCP  
EOF
kind create cluster --wait=1m --config="$$.yaml"
rm "$$.yaml"
fi
kind get kubeconfig >kubeconfig
