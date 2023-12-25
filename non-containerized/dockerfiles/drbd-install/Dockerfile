# docker run -e CHROOT=/host-root -v /:/host-root kvaps/drbd-install

FROM alpine
RUN apk add patch
ADD install-drbd.sh add-RHEL74-compat-hack.patch /
CMD ["/install-drbd.sh"]
