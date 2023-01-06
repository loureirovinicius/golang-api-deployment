FROM golang@sha256:766625f2182dacec4c8774355a65a81a3b73acb0b4287b6a32a8efc185aede2c AS build
WORKDIR /go/src/crud/
COPY . ./
RUN go get -d .
RUN CGO_ENABLED=0 go build -a -o app .

FROM alpine@sha256:c0d488a800e4127c334ad20d61d7bc21b4097540327217dfab52262adc02380c
ENV GROUP=runners GID=22222 USER=app-runner-01 UID=11111
RUN addgroup --gid "$GID" "$GROUP" && \
    adduser \
    --disabled-password \
    -G "$GROUP" \
    -h /home/"$USER" \
    -u "$UID" \
    "$USER"
USER ${USER}
WORKDIR /home/${USER}/app/
COPY --from=build --chown=${USER}:${GROUP} /go/src/crud/app ./
EXPOSE 9000
ENTRYPOINT ["./app"]