SECRETS_DIR="./.secrets/"
PRIVATE_KEY_FILE="${SECRETS_DIR}private.pem"
DB_USERNAME_FILE="${SECRETS_DIR}db_username.txt"
DB_PASSWORD_FILE="${SECRETS_DIR}db_password.txt"
OP_USERNAME_FILE="${SECRETS_DIR}op_username.txt"
OP_PASSWORD_FILE="${SECRETS_DIR}op_password.txt"

# $1 = file name
# $2 = secret length
function generate_secret {
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c $2 > $1
}

# Create secrets directory if not exists
[ ! -d "$SECRETS_DIR" ] && mkdir "$SECRETS_DIR"

# Create private key file if not exists
[ ! -f "$PRIVATE_KEY_FILE" ] && openssl genrsa -out "$PRIVATE_KEY_FILE" 2048

# Create DB username secret file if not exists
[ ! -f "$DB_USERNAME_FILE" ] && generate_secret "$DB_USERNAME_FILE" 14

# Create DB password secret file if not exists
[ ! -f "$DB_PASSWORD_FILE" ] && generate_secret "$DB_PASSWORD_FILE" 64

# Create OP username secret file if not exists
[ ! -f "$OP_USERNAME_FILE" ] && generate_secret "$OP_USERNAME_FILE" 14

# Create OP password secret file if not exists
[ ! -f "$OP_PASSWORD_FILE" ] && generate_secret "$OP_PASSWORD_FILE" 64
