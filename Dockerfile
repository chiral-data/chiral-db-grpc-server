# Builder Image
FROM rust:latest AS builder

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  g++ ca-certificates make libc6-dev \ 
  libprotobuf-dev protobuf-compiler

ENV CXX=g++
ENV USER=chiraldb
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"


WORKDIR /chiral-db-grpc

COPY ./chiral-db-grpc/ .

RUN cargo build --release 

# Server Image
FROM ubuntu:latest
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /chiral-db-grpc
COPY --from=builder /chiral-db-grpc/target/release/chiral-db-server ./
# COPY ./data/chembl_30_chemreps_10k.txt ./
COPY ./data/chembl_28_chemreps_9999.txt ./
USER chiraldb:chiraldb

# ENV CHRLDB_CHEMBL_TXTFILE='chembl_30_chemreps_10k.txt'
ENV CHRLDB_CHEMBL_TXTFILE='chembl_30_chemreps_9999.txt'
CMD ["/chiral-db-grpc/chiral-db-server"]