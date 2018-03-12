TARGET ?= suse.de
CONCOURSE_SECRETS_FILE ?= ../cloudfoundry/secure/concourse-secrets.yml.gpg
TERRAFORM_DATA_DIR ?= ../cloudfoundry/engcloud.prv.suse.net/terraform

all: release develop regression

release: release-os-images release-stemcells release-fissile

release-os-images:
	bash -c "fly -t ${TARGET} set-pipeline -n -c release/os-images.yml -p bosh:release:os-images -l release/vars.yml -l shared_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE})"
	fly -t ${TARGET} unpause-pipeline -p bosh:release:os-images
	fly -t ${TARGET} expose-pipeline -p bosh:release:os-images

release-stemcells:
	bash -c "fly -t ${TARGET} set-pipeline -n -c release/stemcells.yml -p bosh:release:stemcells -l release/vars.yml -l shared_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE}) -l ${TERRAFORM_DATA_DIR}/release/vars.yml -v openstack-private-key-data=\"`gpg --decrypt --batch --no-tty ${TERRAFORM_DATA_DIR}/release/bosh.pem.gpg`\""
	fly -t ${TARGET} unpause-pipeline -p bosh:release:stemcells
	fly -t ${TARGET} expose-pipeline -p bosh:release:stemcells

release-fissile:
	bash -c "fly -t ${TARGET} set-pipeline -n -c fissile/pipeline.yml -p fissile:release -l release/vars.yml -l shared_vars.yml -l fissile/release_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE})"
	fly -t ${TARGET} unpause-pipeline -p fissile:release
	fly -t ${TARGET} expose-pipeline -p fissile:release

develop: develop-os-images develop-stemcells develop-fissile

develop-os-images:
	bash -c "fly -t ${TARGET} set-pipeline -n -c develop/os-images.yml -p bosh:develop:os-images -l develop/vars.yml -l shared_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE})"
	fly -t ${TARGET} unpause-pipeline -p bosh:develop:os-images
	fly -t ${TARGET} expose-pipeline -p bosh:develop:os-images

develop-stemcells:
	bash -c "fly -t ${TARGET} set-pipeline -n -c develop/stemcells.yml -p bosh:develop:stemcells -l develop/vars.yml -l shared_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE}) -l ${TERRAFORM_DATA_DIR}/develop/vars.yml -v openstack-private-key-data=\"`gpg --decrypt --batch --no-tty ${TERRAFORM_DATA_DIR}/develop/bosh.pem.gpg`\""
	fly -t ${TARGET} unpause-pipeline -p bosh:develop:stemcells
	fly -t ${TARGET} expose-pipeline -p bosh:develop:stemcells

develop-fissile:
	bash -c "fly -t ${TARGET} set-pipeline -n -c fissile/pipeline.yml -p fissile:develop  -l develop/vars.yml -l shared_vars.yml  -l fissile/develop_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE})"
	fly -t ${TARGET} unpause-pipeline -p fissile:develop
	fly -t ${TARGET} expose-pipeline -p fissile:develop

regression: regression-os-images regression-stemcells

regression-os-images:
	bash -c "fly -t ${TARGET} set-pipeline -n -c regression/os-images.yml -p bosh:regression:os-images -l regression/vars.yml -l shared_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE})"
	#fly -t ${TARGET} unpause-pipeline -p bosh:regression:os-images
	fly -t ${TARGET} expose-pipeline -p bosh:regression:os-images

regression-stemcells:
	bash -c "fly -t ${TARGET} set-pipeline -n -c regression/stemcells.yml -p bosh:regression:stemcells -l regression/vars.yml -l shared_vars.yml -l <(gpg --decrypt --batch --no-tty ${CONCOURSE_SECRETS_FILE})"
	#fly -t ${TARGET} unpause-pipeline -p bosh:regression:stemcells
	fly -t ${TARGET} expose-pipeline -p bosh:regression:stemcells
