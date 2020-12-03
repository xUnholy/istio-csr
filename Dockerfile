FROM golang:1.15-alpine as build

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""

ENV GO111MODULE=on \
  CGO_ENABLED=0 \
  GOOS=${TARGETOS} \
  GOARCH=${TARGETARCH} \
  GOARM=${TARGETVARIANT}

WORKDIR /go/src/github.com/cert-manager/istio-csr/

COPY . .

RUN go build -o cert-manager-istio-agent ./cmd/.

FROM gcr.io/distroless/static@sha256:3cd546c0b3ddcc8cae673ed078b59067e22dea676c66bd5ca8d302aef2c6e845

LABEL description="istio certificate agent to serve certificate signing requests via cert-manager"

COPY --from=build --chown=nonroot /go/src/github.com/cert-manager/istio-csr/cert-manager-istio-agent /usr/bin/cert-manager-istio-agent

USER nonroot:nonroot

ENTRYPOINT ["/usr/bin/cert-manager-istio-agent"]
