# instalar CLI
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# configuracion
# aws configure

AWS Access Key ID: Escribe tu clave de acceso (ej. AKIAIOSFODNN7EXAMPLE).AWS Secret Access Key: Escribe tu clave secreta (ej. wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY).Default region name: Escribe la región de AWS donde trabajarás por defecto (ej. us-east-1 o us-west-2).Default output format: Escribe el formato de salida de los datos. Se recomienda usar json.
# check connection
aws sts get-caller-identity