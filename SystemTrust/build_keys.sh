#!/bin/sh
# dont run more than once or you'll overwrite your trust keys

set -e

[ -f MachinaTrustKey.private.pem ] && echo "MachinaTrustKey already exists. aborting." && exit 1
[ -f OTATrustKey.private.pem ] && echo "OTATrustKey already exists. aborting." && exit 1
[ -f IntegrityTrustKey.private.pem ] && echo "IntegrityTrustKey already exists. aborting." && exit 1
[ -f SignedDriverKey.private.pem ] && echo "SignedDriverKey already exists. aborting." && exit 1
[ -f SecureBootKey.private.pem ] && echo "SecureBootKey already exists. aborting." && exit 1

echo "generating trust keys..."

openssl genpkey -algorithm Ed25519 -out MachinaTrustKey.private.pem
openssl pkey -in MachinaTrustKey.private.pem -pubout -out MachinaTrustKey.public.pem

openssl genpkey -algorithm Ed25519 -out OTATrustKey.private.pem
openssl pkey -in OTATrustKey.private.pem -pubout -out OTATrustKey.public.pem

openssl genpkey -algorithm Ed25519 -out IntegrityTrustKey.private.pem
openssl pkey -in IntegrityTrustKey.private.pem -pubout -out IntegrityTrustKey.public.pem

openssl genpkey -algorithm Ed25519 -out SignedDriverKey.private.pem
openssl pkey -in SignedDriverKey.private.pem -pubout -out SignedDriverKey.public.pem

openssl genpkey -algorithm Ed25519 -out SecureBootKey.private.pem
openssl pkey -in SecureBootKey.private.pem -pubout -out SecureBootKey.public.pem

echo "done."
