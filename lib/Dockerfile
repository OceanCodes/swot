FROM scratch

COPY ./domains /app/domains
COPY ./swot /app/swot
COPY ./swot-go /app/


WORKDIR /app/
CMD ["swot-go"]

EXPOSE 9900
