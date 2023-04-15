# Minecraft Server via AWS Cloudformation
*(Made for Windows but Mac setup is similar, just cmds have different syntax)*
*(If you want my DOSKEY map for making alias cmds, see aliases.txt)*
- *https://superuser.com/questions/1134368/create-permanent-doskey-in-windows-cmd (helpful tutorial)*

## Setup

### Create ssh-key pair
- generate a private/public rsa ssh key so we'll be able to connect to the ec2 instance hosting our minecraft server later. *Make sure to remember where you save your private/public keys as we will use them to create an ec2 keypair*
- windows: use putty
    - putty will create a .ppk private key file, but to connect to aws ec2 instance we will need to convert this to a .pem extension file. You can use putty conversions to do this.
- mac: use keygen

### Upload ssh public key as ec2 keypair
- We will reference this later on our sam-minecraft.yaml cloudformation template
- Windows (path will be wherever your sshkey is located):
```
aws ec2 import-key-pair --key-name MinecraftServerKeyPair --public-key-material file://C:\Users\erict\.ssh\rsa_public
```
- After uploading this keypair, set the name you set as the KeyPair name as the KeyName for the ec2 instance. You can do this by updating the value in the params file

### Build New Stack
- First we must prep a few AWS services manually before we can create our new stack
- Create new minecraft server stack
```
make new-stack
```

### Attempt ssh into server
- Now the ec2 instance is running and has our KeyPair attached, we can attempt to ssh into the box
```
cd
ssh -i rsa_private.pem ec2-user@<Public ipv4 ip>
```
- There won't be anything here yet besides the linux system files, but we will change that shortly

### Install Java
- Use the commands in set_up_ec2_minecraft_server.sh to setup your ec2 instance with minecraft server files

### Start the Server
- Starting for the first time (make sure ec2 instance is running):
```
cd /opt/minecraft/server
java -jar server.jar --nogui # server.jar is what my jar file is called
vi eula.txt
########     You will have to change eula.txt (eula=false => eula=true)     ###########
########  without this change, the server will shut down after you start it ###########
```
- Starting Server
```
java -jar server.jar # This will take some time to set up server world and objects
```

### Managing the Minecraft Server UpTime
- Now we are ready to start our minecraft server via our lambda start_mc's api
- First make sure your ec2 instance has been stopped
- Next use this curl cmd in your terminal or cmd prompt to start our server. Replace strings in <> with your deployed infrastructure
    - 'api_gateway_id' can be found in AWS::API Gateway in the aws console
    - 'region' is wherever you're deploying. In this example, I'm in 'us-east-1'
    - 'stage_name' is the parameter you used when creating the lambda in the sam template 'StageName'
```shell
curl -X POST -H "Content-Type: application/json" -d '{}' https://<api_gateway_id>.execute-api.<region>.amazonaws.com/<stage_name>/start-mc-server
```
- So an example would be:
```shell
curl -X POST -H "Content-Type: application/json" -d '{}' https://ncr9e5i07k.execute-api.us-east-1.amazonaws.com/gang/start-mc-server
```

## Notes and Things to Keep in Mind
- Lambda Cloudwatch groups won't be created until the associated lambda is kicked off at least once
- Everytime we deploy a new stack, all of the generated infrastructure will be new, and with that, ids for the api gateway, etc will change.
