# --- build stage -----------------------------------------------------------
FROM golang:1.22-alpine AS build
WORKDIR /src

# No external deps, so just copy source and build a static binary.
COPY go.mod main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /whoami .

# --- runtime stage ---------------------------------------------------------
# Distroless static: no shell, no package manager, ~2 MB base. Tiny image =
# fast Fargate pulls and a smaller attack surface.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /whoami /whoami

EXPOSE 8080
ENV PORT=8080
USER nonroot:nonroot
ENTRYPOINT ["/whoami"]
