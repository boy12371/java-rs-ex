node {
stage 'build'
openshiftBuild(buildConfig: 'v2', showBuildLogs: 'true')
stage 'deploy integration'
openshiftVerifyDeployment(deploymentConfig: 'v2')
stage 'test integration'
sh 'curl -i -s http://v2-eap-integration.192.168.122.109.xip.io/rest/json | head -1 |grep 200; exit $?'
stage 'promote to uat'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'v2', destinationAuthToken: '', destinationNamespace: 'eap-uat', namespace: 'eap-integration', srcStream: 'v2', srcTag: 'latest', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'eap-uat', namespace: 'eap-uat', srcStream: 'helloworld', srcTag: 'v2', verbose: 'false')
stage 'deploy uat'
openshiftVerifyDeployment(namespace: 'eap-uat', deploymentConfig: 'helloworld')
openshiftScale(namespace: 'eap-uat', deploymentConfig: 'helloworld',replicaCount: '2')
stage 'test uat'
sh 'curl -i -s http://helloworld-eap-uat.192.168.122.109.xip.io/rest/json | head -1 |grep 200; exit $?'
stage 'promote to production'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'v2', destinationAuthToken: '', destinationNamespace: 'eap-production', namespace: 'eap-uat', srcStream: 'helloworld', srcTag: 'v2', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'green', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'eap-production', namespace: 'eap-production', srcStream: 'helloworld', srcTag: 'v2', verbose: 'false')
stage 'deploy production'
openshiftVerifyDeployment(namespace: 'eap-production', deploymentConfig: 'green')
openshiftScale(namespace: 'eap-production', deploymentConfig: 'green', replicaCount: '2')
}
