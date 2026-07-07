FROM scratch
ARG TARGETARCH

COPY swot-go.$TARGETARCH /app/swot-go
COPY ./domains /app/domains
COPY ./swot /app/swot
COPY ./swot.rb /app/

WORKDIR /app/
CMD ["/app/swot-go"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=15 \
  CMD ["/app/swot-go", "healthcheck"]

EXPOSE 9900
