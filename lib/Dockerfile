FROM scratch
ARG TARGETARCH

COPY swot-go.$TARGETARCH /app/swot-go
COPY ./domains /app/domains
COPY ./swot /app/swot
COPY ./swot.rb /app/

WORKDIR /app/
CMD ["/app/swot-go"]

EXPOSE 9900
