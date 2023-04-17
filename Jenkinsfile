#!groovy
import groovy.json.JsonSlurperClassic
node {

    
    
         def toolbelt = tool 'sfdx'


        def JWT_KEY_CRED_ID=env.JWT_KEY_CRED_ID_Acamfull
def clientId = env.CLIENT_ID_Acamsfull
def sf_username=env.sf_username_Acamsfull
        
 stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Deploye Code') {
            if (isUnix()) {
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${clientId} --jwtkeyfile ${jwt_key_file} --username ${sf_username} --instanceurl https://test.salesforce.com --setdefaultdevhubusername"
        }else{
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${clientId} --jwtkeyfile ${jwt_key_file} --username ${sf_username} --instanceurl https://test.salesforce.com --setdefaultdevhubusername "
            }
            if (rc != 0) { error 'hub org authorization failed' }

			println rc}
			
			// need to pull out assigned username  force:source:deploy -x path/to/package.xml
			if (isUnix()) {
                sh 'ls -la'



			   rmsg = sh returnStdout: true, script: "${toolbelt}/sfdx  project deploy start -x manifest/package.xml  -o ${sf_username}"


			}else{
			   rmsg = bat returnStdout: true, script: "${toolbelt}/sfdx  force:source:deploy -checkonly manifest/package.xml  -u ${sf_username}"
			}
			   
    
    }
   
        }
    



