# ================================
# Build image
# ================================
FROM vapor/swift:5.1 as build
WORKDIR /build

RUN apt-get -qq update && apt-get -q -y install \
  libgd-dev \
  && rm -r /var/lib/apt/lists/*

# Copy entire repo into container
COPY . .

# Compile with optimizations
RUN swift build \
	--enable-test-discovery \
	-c release \
	-Xswiftc -g

# ================================
# Run image
# ================================
FROM vapor/ubuntu:18.04
WORKDIR /run

RUN apt-get -qq update && apt-get -q -y install \
  libgd-dev \
  && rm -r /var/lib/apt/lists/*

COPY --from=build /build/.build/release /run
COPY --from=build /usr/lib/swift/ /usr/lib/swift/
COPY --from=build /build/Public /run/Public
COPY --from=build /build/Resources /run/Resources

ENTRYPOINT ["./Run", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
