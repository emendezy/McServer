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
- Starting for the first time:
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

### Finish Setting up SES service
- We will be using the AWS SES service to start our EC2 instance. This means we will need to register our the Recipient email attached to our RecieptRule
- Go to AWS console -> SES -> Verified Identities
    - Create a new identity, select email type unless you want to use a domain instead
    - Accept the confirmation email and you're all set here
- TODO: Lambda can start the EC2 instance but the SES service isn't working as intended
Notes:
- We could use an api gateway attached to the lambda instead
- Then users could send a curl request
```shell
curl -X POST -H "Content-Type: application/json" -d '{"INSTANCE_ID":"i-0b500200f9d291f35"}' https://sq8wo7aqc3.execute-api.us-east-1.amazonaws.com/gang/start-emendez-mc-server

# currently getting response {"message": "Internal server error"}

```