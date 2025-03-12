FROM qgis/qgis:release-3_16

RUN apt  update \
     && apt install -y git libqt5sql5-psql
RUN pip install pre-commit nose requests_mock pylint

COPY pg_service.conf /

RUN mkdir /app /cache
WORKDIR /app
RUN git init
RUN git config --global --add safe.directory /app

ENV PRE_COMMIT_HOME=/cache
COPY .pre-commit-config.yaml /app
RUN pre-commit

RUN chmod -R a+rwX /cache
