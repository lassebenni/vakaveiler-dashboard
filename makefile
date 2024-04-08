# Targets
.PHONY: build tag push run download-cloudrun update-cloudrun execute-cloudrun

# Variables
IMAGE_NAME := vakaveiler-dashboard

GCR_IMAGE := eu.gcr.io/lasse-benninga-sndbx-y/$(IMAGE_NAME)

IMAGE_LATEST_HASH = $(shell gcloud container images describe $(GCR_IMAGE):latest --format="value(image_summary.fully_qualified_digest)")
TAG := latest

CLOUDRUN_JOB_NAME := vakaveiler-dashboard

build:
	docker build \
		--platform linux/amd64 \
		-t $(IMAGE_NAME) .
tag:
	docker tag $(IMAGE_NAME) $(GCR_IMAGE):$(TAG)

push:
	docker push $(GCR_IMAGE):$(TAG)

run:
	docker run \
	--platform linux/amd64 \
	--privileged \
	-it \
	--rm \
	-p 80:80 \
	$(IMAGE_NAME)

download-db:
	rm auctions.duckdb || true
	# gsutil cp gs://lasse-benninga-sndbx-y-vakantieveilingen/veilingen.sqlite analysis/veilingen.sqlite
	duckdb auctions.duckdb -c '.read analysis/duckdb_query.sql'

cloudrun-download:
	gcloud run services describe $(CLOUDRUN_JOB_NAME) --format export  |\
		sed -e 's|eu.gcr.io.*|$(IMAGE_LATEST_HASH)|g' > cloudrun/$(CLOUDRUN_JOB_NAME).yaml

cloudrun-update:
	gcloud run services replace cloudrun/$(CLOUDRUN_JOB_NAME).yaml
