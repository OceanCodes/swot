FROM scratch

COPY ./domains /app/domains
COPY ./swot /app/swot
COPY ./swot.rb /app/
COPY ./swot-go /app/


WORKDIR /app/
CMD ["/app/swot-go"]

EXPOSE 9900
