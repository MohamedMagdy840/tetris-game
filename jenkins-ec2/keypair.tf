#tls
#key-pair
#tls-private-key to add in locall
#in userdata of bastion echo command add the file of private key in bastion file

resource "tls_private_key" "keys" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = tls_private_key.keys.public_key_openssh
}

resource "local_file" "private_key" {
  filename = "./private_key.pem"
  content  = tls_private_key.keys.private_key_pem
}