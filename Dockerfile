# ------------------------
# Step 1: Build zfs_exporter binary
# ------------------------
FROM golang:1.24 AS builder

ARG ZFS_EXPORTER_VERSION=v2.3.11
WORKDIR /app

# Clone repository and build image
RUN git clone https://github.com/pdf/zfs_exporter.git . \
    && git checkout ${ZFS_EXPORTER_VERSION} \
    && go build -o zfs_exporter .


# ------------------------
# Step 2: Build image
# ------------------------
FROM debian:bookworm-slim

LABEL maintainer="Urkaz"
LABEL description="Prometheus ZFS Exporter"
ARG ZFS_EXPORTER_VERSION=v2.3.11
ENV ZFS_EXPORTER_VERSION=${ZFS_EXPORTER_VERSION}

# Add backports repo to install zfsutils
RUN echo "deb http://ftp.debian.org/debian bookworm-backports main contrib" > /etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get install -y zfsutils-linux \
    && rm -rf /var/lib/apt/lists/*

# Copy zfs_exporter binary from build from step 1
COPY --from=builder /app/zfs_exporter /usr/local/bin/zfs_exporter

# Default Prometheus port
EXPOSE 9134

# Run
ENTRYPOINT ["/usr/local/bin/zfs_exporter"]
CMD []